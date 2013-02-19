From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PPPOE lockdep report  in dev_queue_xmit+0x8b8/0x900
Date: Tue, 19 Feb 2013 10:42:03 -0800
Message-ID: <1361299323.19353.156.camel@edumazet-glaptop>
References: <1361209421.9147.12.camel@d2>
	 <1361217052.19353.101.camel@edumazet-glaptop> <1361272221.2282.5.camel@d2>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Yanko Kaneti <yaneti@declera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:44474 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932823Ab3BSSmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 13:42:06 -0500
Received: by mail-da0-f42.google.com with SMTP id z17so3088629dal.1
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 10:42:05 -0800 (PST)
In-Reply-To: <1361272221.2282.5.camel@d2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Tue, 2013-02-19 at 13:10 +0200, Yanko Kaneti wrote:

> 
> It looks like it has done the job. I am running a kernel with the patch
> and workload that otherwise inevitably triggers the splat and so far it
> has been quiet.
> 

Thanks for testing.

David, there was a typo in the changelog : team should be replaced by
ppp.

[PATCH v2] ppp: set qdisc_tx_busylock to avoid LOCKDEP splat

If a qdisc is installed on a ppp device, its possible to get
a lockdep splat under stress, because nested dev_queue_xmit() can
lock busylock a second time (on a different device, so its a false
positive)

Avoid this problem using a distinct lock_class_key for ppp
devices.

Reported-by: Yanko Kaneti <yaneti@declera.com>
Tested-by: Yanko Kaneti <yaneti@declera.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ppp/ppp_generic.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 4fd754e..3db9131 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1058,7 +1058,15 @@ ppp_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats64)
 	return stats64;
 }
 
+static struct lock_class_key ppp_tx_busylock;
+static int ppp_dev_init(struct net_device *dev)
+{
+	dev->qdisc_tx_busylock = &ppp_tx_busylock;
+	return 0;
+}
+
 static const struct net_device_ops ppp_netdev_ops = {
+	.ndo_init	 = ppp_dev_init,
 	.ndo_start_xmit  = ppp_start_xmit,
 	.ndo_do_ioctl    = ppp_net_ioctl,
 	.ndo_get_stats64 = ppp_get_stats64,
