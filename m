From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH net-next 3/8] bridge: Check return of dev_set_promiscuity
Date: Fri, 20 Jun 2008 10:32:27 +0800
Message-ID: <485B16BB.1000604@cn.fujitsu.com>
References: <485AFFE4.4000300@cn.fujitsu.com> <20080619181819.15b2cc9d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52707 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751821AbYFTCgW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 22:36:22 -0400
In-Reply-To: <20080619181819.15b2cc9d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger said the following on 2008-6-20 9:18:
> On Fri, 20 Jun 2008 08:55:00 +0800
> Wang Chen <wangchen@cn.fujitsu.com> wrote:
> 
>> dev_set_promiscuity/allmulti might overflow.
>> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
>> dev_set_promiscuity/allmulti return error number if overflow happened.
>>
>> Here, we check the positive increment for promiscuity to get error return.
>>
>> BTW, I have to add a function to handle cleanup for br_sysfs_addif().
>> I know Stephen has removed br_sysfs_removeif() to keep kobjects in use
>> even if not using sysfs.
>> But here we have a new br_sysfs_removeif() which only cleanup the sysfs
>> and doesn't touch kobjects.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> Not that hard way please. Instead just rearrange the order of setup to avoid having to
> do the things that are harder to unwind. Sysfs calls seem to be more fragile/error
> prone than the simple counters.
> 

Yes. Thank you for the good advice.
And, Can I add a SOF of you?

---
dev_set_promiscuity/allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check the positive increment for promiscuity to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/bridge/br_if.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c2397f5..805dbb7 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -375,6 +375,10 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 
+	err = dev_set_promiscuity(dev, 1);
+	if (err)
+		goto put_back;
+
 	err = kobject_init_and_add(&p->kobj, &brport_ktype, &(dev->dev.kobj),
 				   SYSFS_BRIDGE_PORT_ATTR);
 	if (err)
@@ -389,7 +393,6 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 		goto err2;
 
 	rcu_assign_pointer(dev->br_port, p);
-	dev_set_promiscuity(dev, 1);
 
 	list_add_rcu(&p->list, &br->port_list);
 
@@ -418,6 +421,7 @@ err0:
 	kobject_put(&p->kobj);
 
 put_back:
+	dev_set_promiscuity(dev, -1);
 	dev_put(dev);
 	return err;
 }
-- 
1.5.3.4

