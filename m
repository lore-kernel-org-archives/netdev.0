From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next] fix rtnl notification in atomic context
Date: Wed, 23 Oct 2013 16:02:42 -0700
Message-ID: <1382569362-4820-1-git-send-email-ast@plumgrid.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <amwang@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:62636 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165Ab3JWXCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 19:02:46 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so1598533pab.20
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 16:02:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 991fb3f74c "dev: always advertise rx_flags changes via netlink"
introduced rtnl notification from __dev_set_promiscuity(),
which can be called in atomic context.

Steps to reproduce:
ip tuntap add dev tap1 mode tap
ifconfig tap1 up
tcpdump -nei tap1 &
ip tuntap del dev tap1 mode tap

[  271.627994] device tap1 left promiscuous mode
[  271.639897] BUG: sleeping function called from invalid context at mm/slub.c:940
[  271.664491] in_atomic(): 1, irqs_disabled(): 0, pid: 3394, name: ip
[  271.677525] INFO: lockdep is turned off.
[  271.690503] CPU: 0 PID: 3394 Comm: ip Tainted: G        W    3.12.0-rc3+ #73
[  271.703996] Hardware name: System manufacturer System Product Name/P8Z77 WS, BIOS 3007 07/26/2012
[  271.731254]  ffffffff81a58506 ffff8807f0d57a58 ffffffff817544e5 ffff88082fa0f428
[  271.760261]  ffff8808071f5f40 ffff8807f0d57a88 ffffffff8108bad1 ffffffff81110ff8
[  271.790683]  0000000000000010 00000000000000d0 00000000000000d0 ffff8807f0d57af8
[  271.822332] Call Trace:
[  271.838234]  [<ffffffff817544e5>] dump_stack+0x55/0x76
[  271.854446]  [<ffffffff8108bad1>] __might_sleep+0x181/0x240
[  271.870836]  [<ffffffff81110ff8>] ? rcu_irq_exit+0x68/0xb0
[  271.887076]  [<ffffffff811a80be>] kmem_cache_alloc_node+0x4e/0x2a0
[  271.903368]  [<ffffffff810b4ddc>] ? vprintk_emit+0x1dc/0x5a0
[  271.919716]  [<ffffffff81614d67>] ? __alloc_skb+0x57/0x2a0
[  271.936088]  [<ffffffff810b4de0>] ? vprintk_emit+0x1e0/0x5a0
[  271.952504]  [<ffffffff81614d67>] __alloc_skb+0x57/0x2a0
[  271.968902]  [<ffffffff8163a0b2>] rtmsg_ifinfo+0x52/0x100
[  271.985302]  [<ffffffff8162ac6d>] __dev_notify_flags+0xad/0xc0
[  272.001642]  [<ffffffff8162ad0c>] __dev_set_promiscuity+0x8c/0x1c0
[  272.017917]  [<ffffffff81731ea5>] ? packet_notifier+0x5/0x380
[  272.033961]  [<ffffffff8162b109>] dev_set_promiscuity+0x29/0x50
[  272.049855]  [<ffffffff8172e937>] packet_dev_mc+0x87/0xc0
[  272.065494]  [<ffffffff81732052>] packet_notifier+0x1b2/0x380
[  272.080915]  [<ffffffff81731ea5>] ? packet_notifier+0x5/0x380
[  272.096009]  [<ffffffff81761c66>] notifier_call_chain+0x66/0x150
[  272.110803]  [<ffffffff8108503e>] __raw_notifier_call_chain+0xe/0x10
[  272.125468]  [<ffffffff81085056>] raw_notifier_call_chain+0x16/0x20
[  272.139984]  [<ffffffff81620190>] call_netdevice_notifiers_info+0x40/0x70
[  272.154523]  [<ffffffff816201d6>] call_netdevice_notifiers+0x16/0x20
[  272.168552]  [<ffffffff816224c5>] rollback_registered_many+0x145/0x240
[  272.182263]  [<ffffffff81622641>] rollback_registered+0x31/0x40
[  272.195369]  [<ffffffff816229c8>] unregister_netdevice_queue+0x58/0x90
[  272.208230]  [<ffffffff81547ca0>] __tun_detach+0x140/0x340
[  272.220686]  [<ffffffff81547ed6>] tun_chr_close+0x36/0x60

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 drivers/net/bonding/bond_main.c |    4 ++--
 include/linux/rtnetlink.h       |    2 +-
 net/core/dev.c                  |   16 ++++++++--------
 net/core/rtnetlink.c            |    9 +++++----
 4 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2daa066..a141f40 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1213,7 +1213,7 @@ static int bond_master_upper_dev_link(struct net_device *bond_dev,
 	if (err)
 		return err;
 	slave_dev->flags |= IFF_SLAVE;
-	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE);
+	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL);
 	return 0;
 }
 
@@ -1222,7 +1222,7 @@ static void bond_upper_dev_unlink(struct net_device *bond_dev,
 {
 	netdev_upper_dev_unlink(slave_dev, bond_dev);
 	slave_dev->flags &= ~IFF_SLAVE;
-	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE);
+	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL);
 }
 
 /* enslave device <slave> to bond device <master> */
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index f28544b..939428a 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -15,7 +15,7 @@ extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
 extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
 			      u32 id, long expires, u32 error);
 
-extern void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change);
+void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change, gfp_t flags);
 
 /* RTNL is used as a global lock for all changes to network configuration  */
 extern void rtnl_lock(void);
diff --git a/net/core/dev.c b/net/core/dev.c
index 0918aad..5d7e821 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1203,7 +1203,7 @@ void netdev_state_change(struct net_device *dev)
 {
 	if (dev->flags & IFF_UP) {
 		call_netdevice_notifiers(NETDEV_CHANGE, dev);
-		rtmsg_ifinfo(RTM_NEWLINK, dev, 0);
+		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 	}
 }
 EXPORT_SYMBOL(netdev_state_change);
@@ -1293,7 +1293,7 @@ int dev_open(struct net_device *dev)
 	if (ret < 0)
 		return ret;
 
-	rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
+	rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING, GFP_KERNEL);
 	call_netdevice_notifiers(NETDEV_UP, dev);
 
 	return ret;
@@ -1371,7 +1371,7 @@ static int dev_close_many(struct list_head *head)
 	__dev_close_many(head);
 
 	list_for_each_entry_safe(dev, tmp, head, close_list) {
-		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
+		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING, GFP_KERNEL);
 		call_netdevice_notifiers(NETDEV_DOWN, dev);
 		list_del_init(&dev->close_list);
 	}
@@ -5257,7 +5257,7 @@ void __dev_notify_flags(struct net_device *dev, unsigned int old_flags,
 	unsigned int changes = dev->flags ^ old_flags;
 
 	if (gchanges)
-		rtmsg_ifinfo(RTM_NEWLINK, dev, gchanges);
+		rtmsg_ifinfo(RTM_NEWLINK, dev, gchanges, GFP_ATOMIC);
 
 	if (changes & IFF_UP) {
 		if (dev->flags & IFF_UP)
@@ -5489,7 +5489,7 @@ static void rollback_registered_many(struct list_head *head)
 
 		if (!dev->rtnl_link_ops ||
 		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
-			rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
+			rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
 
 		/*
 		 *	Flush the unicast and multicast chains
@@ -5888,7 +5888,7 @@ int register_netdevice(struct net_device *dev)
 	 */
 	if (!dev->rtnl_link_ops ||
 	    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
-		rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U);
+		rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U, GFP_KERNEL);
 
 out:
 	return ret;
@@ -6500,7 +6500,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 	rcu_barrier();
 	call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
-	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
+	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
 
 	/*
 	 *	Flush the unicast and multicast chains
@@ -6539,7 +6539,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	 *	Prevent userspace races by waiting until the network
 	 *	device is fully setup before sending notifications.
 	 */
-	rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U);
+	rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U, GFP_KERNEL);
 
 	synchronize_net();
 	err = 0;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4aedf03..cf67144 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1984,14 +1984,15 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change)
+void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
+		  gfp_t flags)
 {
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 	size_t if_info_size;
 
-	skb = nlmsg_new((if_info_size = if_nlmsg_size(dev, 0)), GFP_KERNEL);
+	skb = nlmsg_new((if_info_size = if_nlmsg_size(dev, 0)), flags);
 	if (skb == NULL)
 		goto errout;
 
@@ -2002,7 +2003,7 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change)
 		kfree_skb(skb);
 		goto errout;
 	}
-	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_KERNEL);
+	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
 	return;
 errout:
 	if (err < 0)
@@ -2716,7 +2717,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_JOIN:
 		break;
 	default:
-		rtmsg_ifinfo(RTM_NEWLINK, dev, 0);
+		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
 	}
 	return NOTIFY_DONE;
-- 
1.7.9.5
