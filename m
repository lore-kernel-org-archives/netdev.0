From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v3] rtnetlink: delay RTM_DELLINK notification until after ndo_uninit()
Date: Tue,  2 Dec 2014 23:24:57 -0800
Message-ID: <1417591497-24246-1-git-send-email-maheshb@google.com>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:64941 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbaLCHZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 02:25:01 -0500
Received: by mail-ob0-f201.google.com with SMTP id nt9so647087obb.4
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 23:25:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 56bfa7ee7c ("unregister_netdevice : move RTM_DELLINK to
until after ndo_uninit") tried to do this ealier but while doing so
it created a problem. Unfortunately the delayed rtmsg_ifinfo() also
delayed call to fill_info(). So this translated into asking driver
to remove private state and then query it's private state. This
could have catastropic consequences.

This change breaks the rtmsg_ifinfo() into two parts - one takes the
precise snapshot of the device by called fill_info() before calling
the ndo_uninit() and the second part sends the notification using
collected snapshot.

It was brought to notice when last link is deleted from an ipvlan device
when it has free-ed the port and the subsequent .fill_info() call is
trying to get the info from the port.

kernel: [  255.139429] ------------[ cut here ]------------
kernel: [  255.139439] WARNING: CPU: 12 PID: 11173 at net/core/rtnetlink.c:2238 rtmsg_ifinfo+0x100/0x110()
kernel: [  255.139493] Modules linked in: ipvlan bonding w1_therm ds2482 wire cdc_acm ehci_pci ehci_hcd i2c_dev i2c_i801 i2c_core msr cpuid bnx2x ptp pps_core mdio libcrc32c
kernel: [  255.139513] CPU: 12 PID: 11173 Comm: ip Not tainted 3.18.0-smp-DEV #167
kernel: [  255.139514] Hardware name: Intel RML,PCH/Ibis_QC_18, BIOS 1.0.10 05/15/2012
kernel: [  255.139515]  0000000000000009 ffff880851b6b828 ffffffff815d87f4 00000000000000e0
kernel: [  255.139516]  0000000000000000 ffff880851b6b868 ffffffff8109c29c 0000000000000000
kernel: [  255.139518]  00000000ffffffa6 00000000000000d0 ffffffff81aaf580 0000000000000011
kernel: [  255.139520] Call Trace:
kernel: [  255.139527]  [<ffffffff815d87f4>] dump_stack+0x46/0x58
kernel: [  255.139531]  [<ffffffff8109c29c>] warn_slowpath_common+0x8c/0xc0
kernel: [  255.139540]  [<ffffffff8109c2ea>] warn_slowpath_null+0x1a/0x20
kernel: [  255.139544]  [<ffffffff8150d570>] rtmsg_ifinfo+0x100/0x110
kernel: [  255.139547]  [<ffffffff814f78b5>] rollback_registered_many+0x1d5/0x2d0
kernel: [  255.139549]  [<ffffffff814f79cf>] unregister_netdevice_many+0x1f/0xb0
kernel: [  255.139551]  [<ffffffff8150acab>] rtnl_dellink+0xbb/0x110
kernel: [  255.139553]  [<ffffffff8150da90>] rtnetlink_rcv_msg+0xa0/0x240
kernel: [  255.139557]  [<ffffffff81329283>] ? rhashtable_lookup_compare+0x43/0x80
kernel: [  255.139558]  [<ffffffff8150d9f0>] ? __rtnl_unlock+0x20/0x20
kernel: [  255.139562]  [<ffffffff8152cb11>] netlink_rcv_skb+0xb1/0xc0
kernel: [  255.139563]  [<ffffffff8150a495>] rtnetlink_rcv+0x25/0x40
kernel: [  255.139565]  [<ffffffff8152c398>] netlink_unicast+0x178/0x230
kernel: [  255.139567]  [<ffffffff8152c75f>] netlink_sendmsg+0x30f/0x420
kernel: [  255.139571]  [<ffffffff814e0b0c>] sock_sendmsg+0x9c/0xd0
kernel: [  255.139575]  [<ffffffff811d1d7f>] ? rw_copy_check_uvector+0x6f/0x130
kernel: [  255.139577]  [<ffffffff814e11c9>] ? copy_msghdr_from_user+0x139/0x1b0
kernel: [  255.139578]  [<ffffffff814e1774>] ___sys_sendmsg+0x304/0x310
kernel: [  255.139581]  [<ffffffff81198723>] ? handle_mm_fault+0xca3/0xde0
kernel: [  255.139585]  [<ffffffff811ebc4c>] ? destroy_inode+0x3c/0x70
kernel: [  255.139589]  [<ffffffff8108e6ec>] ? __do_page_fault+0x20c/0x500
kernel: [  255.139597]  [<ffffffff811e8336>] ? dput+0xb6/0x190
kernel: [  255.139606]  [<ffffffff811f05f6>] ? mntput+0x26/0x40
kernel: [  255.139611]  [<ffffffff811d2b94>] ? __fput+0x174/0x1e0
kernel: [  255.139613]  [<ffffffff814e2129>] __sys_sendmsg+0x49/0x90
kernel: [  255.139615]  [<ffffffff814e2182>] SyS_sendmsg+0x12/0x20
kernel: [  255.139617]  [<ffffffff815df092>] system_call_fastpath+0x12/0x17
kernel: [  255.139619] ---[ end trace 5e6703e87d984f6b ]---

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
Reported-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
Cc: David S. Miller <davem@davemloft.net>
---
v1:
	Initial version
v2:
	Keep the rtmsg_ifinfo() return type as it is but break the function into
	two minimizing the changes all over places
v3:
	Corrected an error in the code.
---
 include/linux/rtnetlink.h |  5 +++++
 net/core/dev.c            | 12 +++++++++---
 net/core/rtnetlink.c      | 27 +++++++++++++++++++++++----
 3 files changed, 37 insertions(+), 7 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 6cacbce1a06c..19dc0bce9c2b 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -17,6 +17,11 @@ extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
 			      u32 id, long expires, u32 error);
 
 void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change, gfp_t flags);
+struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
+				       unsigned change, gfp_t flags);
+void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev,
+		       gfp_t flags);
+
 
 /* RTNL is used as a global lock for all changes to network configuration  */
 extern void rtnl_lock(void);
diff --git a/net/core/dev.c b/net/core/dev.c
index ac4836241a96..98f6563b68b6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5925,6 +5925,8 @@ static void rollback_registered_many(struct list_head *head)
 	synchronize_net();
 
 	list_for_each_entry(dev, head, unreg_list) {
+		struct sk_buff *skb = NULL;
+
 		/* Shutdown queueing discipline. */
 		dev_shutdown(dev);
 
@@ -5934,6 +5936,11 @@ static void rollback_registered_many(struct list_head *head)
 		*/
 		call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 
+		if (!dev->rtnl_link_ops ||
+		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
+			skb = rtmsg_ifinfo_build_skb(RTM_DELLINK, dev, ~0U,
+						     GFP_KERNEL);
+
 		/*
 		 *	Flush the unicast and multicast chains
 		 */
@@ -5943,9 +5950,8 @@ static void rollback_registered_many(struct list_head *head)
 		if (dev->netdev_ops->ndo_uninit)
 			dev->netdev_ops->ndo_uninit(dev);
 
-		if (!dev->rtnl_link_ops ||
-		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
-			rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
+		if (skb)
+			rtmsg_ifinfo_send(skb, dev, GFP_KERNEL);
 
 		/* Notifier chain MUST detach us all upper devices. */
 		WARN_ON(netdev_has_any_upper_dev(dev));
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b9b7dfaf202b..88787c10b8a6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2220,8 +2220,8 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
-		  gfp_t flags)
+struct sk_buff *rtmsg_ifinfo_build_skb(int type, struct net_device *dev,
+				       unsigned int change, gfp_t flags)
 {
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
@@ -2239,11 +2239,30 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
 		kfree_skb(skb);
 		goto errout;
 	}
-	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
-	return;
+	return skb;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(net, RTNLGRP_LINK, err);
+	return NULL;
+}
+EXPORT_SYMBOL(rtmsg_ifinfo_build_skb);
+
+void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev, gfp_t flags)
+{
+	struct net *net = dev_net(dev);
+
+	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
+}
+EXPORT_SYMBOL(rtmsg_ifinfo_send);
+
+void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
+		  gfp_t flags)
+{
+	struct sk_buff *skb;
+
+	skb = rtmsg_ifinfo_build_skb(type, dev, change, flags);
+	if (skb)
+		rtmsg_ifinfo_send(skb, dev, flags);
 }
 EXPORT_SYMBOL(rtmsg_ifinfo);
 
-- 
2.2.0.rc0.207.ga3a616c
