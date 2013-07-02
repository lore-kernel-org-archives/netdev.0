From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: rtnl_lock deadlock on 3.10
Date: Tue, 2 Jul 2013 13:38:26 +0000 (UTC)
Message-ID: <kqul4h$ib8$1@ger.gmane.org>
References: <20130701145456.GA7756@sbohrermbp13-local.rgmadvisors.com>
 <20130702082818.GA26178@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:33395 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976Ab3GBNin (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jul 2013 09:38:43 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Uu0n3-0000qI-67
	for netdev@vger.kernel.org; Tue, 02 Jul 2013 15:38:41 +0200
Received: from 182.246.110.202 ([182.246.110.202])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 15:38:41 +0200
Received: from xiyou.wangcong by 182.246.110.202 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 15:38:41 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Jul 2013 at 08:28 GMT, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> On Mon, Jul 01, 2013 at 09:54:56AM -0500, Shawn Bohrer wrote:
>> I've managed to hit a deadlock at boot a couple times while testing
>> the 3.10 rc kernels.  It seems to always happen when my network
>> devices are initializing.  This morning I updated to v3.10 and made a
>> few config tweaks and so far I've hit it 4 out of 5 reboots.  It looks
>> like most processes are getting stuck on rtnl_lock.  Below is a boot
>> log with the soft lockup prints.  Please let know if there is any
>> other information I can provide:
>
> Could you try a build with CONFIG_LOCKDEP enabled?
>

The problem is clear: ib_register_device() is called with rtnl_lock,
but itself needs device_mutex, however, ib_register_client() first
acquires device_mutex, then indirectly calls register_netdev() which
takes rtnl_lock. Deadlock!

One possible fix is always taking rtnl_lock before taking
device_mutex, something like below:

diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 18c1ece..890870b 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -381,6 +381,7 @@ int ib_register_client(struct ib_client *client)
 {
 	struct ib_device *device;
 
+	rtnl_lock();
 	mutex_lock(&device_mutex);
 
 	list_add_tail(&client->list, &client_list);
@@ -389,6 +390,7 @@ int ib_register_client(struct ib_client *client)
 			client->add(device);
 
 	mutex_unlock(&device_mutex);
+	rtnl_unlock();
 
 	return 0;
 }
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index b6e049a..5a7a048 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1609,7 +1609,7 @@ static struct net_device *ipoib_add_port(const char *format,
 		goto event_failed;
 	}
 
-	result = register_netdev(priv->dev);
+	result = register_netdevice(priv->dev);
 	if (result) {
 		printk(KERN_WARNING "%s: couldn't register ipoib port %d; error %d\n",
 		       hca->name, port, result);
