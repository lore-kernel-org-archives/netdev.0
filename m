From: Cong Wang <amwang@redhat.com>
Subject: [Patch] net: allow calling rtmsg_ifinfo() in atomic
Date: Tue, 14 Aug 2012 18:28:16 +0800
Message-ID: <1344940096-5548-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <edumazet@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752937Ab2HNK26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2012 06:28:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Against net tree.)

When running 'systemctl restart network.service', I got the following
warning:

 [ 1123.199677] 
 [ 1123.310275] ===============================
 [ 1123.442202] [ INFO: suspicious RCU usage. ]
 [ 1123.558207] 3.6.0-rc1+ #109 Not tainted
 [ 1123.665204] -------------------------------
 [ 1123.768254] include/linux/rcupdate.h:430 Illegal context switch in RCU read-side critical section!
 [ 1123.992320] 
 [ 1123.992320] other info that might help us debug this:
 [ 1123.992320] 
 [ 1124.307382] 
 [ 1124.307382] rcu_scheduler_active = 1, debug_locks = 0
 [ 1124.522220] 2 locks held by sysctl/5710:
 [ 1124.648364]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81768498>] rtnl_trylock+0x15/0x17
 [ 1124.882211]  #1:  (rcu_read_lock){.+.+.+}, at: [<ffffffff81871df8>] rcu_lock_acquire+0x0/0x29
 [ 1125.085209] 
 [ 1125.085209] stack backtrace:
 [ 1125.332213] Pid: 5710, comm: sysctl Not tainted 3.6.0-rc1+ #109
 [ 1125.441291] Call Trace:
 [ 1125.545281]  [<ffffffff8109d915>] lockdep_rcu_suspicious+0x109/0x112
 [ 1125.667212]  [<ffffffff8107c240>] rcu_preempt_sleep_check+0x45/0x47
 [ 1125.781838]  [<ffffffff8107c260>] __might_sleep+0x1e/0x19b
 [ 1125.900306]  [<ffffffff8113e4a2>] slab_pre_alloc_hook+0x2d/0x38
 [ 1126.012217]  [<ffffffff817508f4>] ? __alloc_skb+0x4c/0x1a2
 [ 1126.115156]  [<ffffffff811411ea>] kmem_cache_alloc_node+0x2c/0x1c2
 [ 1126.260520]  [<ffffffff8109cae1>] ? lock_is_held+0x8a/0x95
 [ 1126.391261]  [<ffffffff817508f4>] ? __alloc_skb+0x4c/0x1a2
 [ 1126.515221]  [<ffffffff817508f4>] __alloc_skb+0x4c/0x1a2
 [ 1126.615272]  [<ffffffff8176778b>] ? if_nlmsg_size+0x164/0x19b
 [ 1126.741293]  [<ffffffff8176718e>] nlmsg_new+0x14/0x16
 [ 1126.863267]  [<ffffffff8176994d>] rtmsg_ifinfo+0x3b/0xcd
 [ 1126.982196]  [<ffffffff8109cae1>] ? lock_is_held+0x8a/0x95
 [ 1127.102201]  [<ffffffff81769a0f>] rtnetlink_event+0x30/0x34
 [ 1127.229490]  [<ffffffff8198a241>] notifier_call_chain+0x96/0xcd
 [ 1127.338260]  [<ffffffff810760b3>] raw_notifier_call_chain+0x14/0x16
 [ 1127.445223]  [<ffffffff81757ac5>] call_netdevice_notifiers+0x4a/0x4f
 [ 1127.560195]  [<ffffffff81757ffb>] netdev_features_change+0x16/0x18
 [ 1127.668273]  [<ffffffff8175e0ee>] netdev_update_features+0x20/0x25
 [ 1127.772188]  [<ffffffff8175e125>] dev_disable_lro+0x32/0x6b
 [ 1127.885174]  [<ffffffff81872d26>] dev_forward_change+0x30/0xcb
 [ 1128.013214]  [<ffffffff818738c4>] addrconf_forward_change+0x85/0xc5
 [ 1128.118328]  [<ffffffff818739bc>] addrconf_sysctl_forward+0xb8/0x108
 [ 1128.278964]  [<ffffffff81873904>] ? addrconf_forward_change+0xc5/0xc5
 [ 1128.383230]  [<ffffffff811af269>] proc_sys_call_handler+0x8a/0xb8
 [ 1128.475407]  [<ffffffff811af2ab>] proc_sys_write+0x14/0x16
 [ 1128.578263]  [<ffffffff81152a9e>] vfs_write+0xaf/0xf6
 [ 1128.674728]  [<ffffffff81153edf>] ? fget_light+0x3a/0xa1
 [ 1128.790492]  [<ffffffff81152c99>] sys_write+0x4d/0x74
 [ 1128.902165]  [<ffffffff8112040e>] ? do_anonymous_page+0x162/0x1d6
 [ 1129.017203]  [<ffffffff8198dea9>] system_call_fastpath+0x16/0x1b

This is due to that we call rtmsg_ifinfo() with RCU read lock held,
and because rtmsg_ifinfo() may block, this is invalid.

This patch fixes it by allowing callees to specify GFP when
calling it. In this case, netdev_features_change() calls it
with GFP_ATOMIC.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Eric Dumazet <edumazet@google.com> 
Cc: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index db71c4a..8d5b0b0 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -621,7 +621,8 @@ extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
 extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
 			      u32 id, long expires, u32 error);
 
-extern void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change);
+extern void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change,
+			 gfp_t flags);
 
 /* RTNL is used as a global lock for all changes to network configuration  */
 extern void rtnl_lock(void);
diff --git a/net/core/dev.c b/net/core/dev.c
index a39354e..8c44e4c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1089,6 +1089,7 @@ int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
 void netdev_features_change(struct net_device *dev)
 {
 	call_netdevice_notifiers(NETDEV_FEAT_CHANGE, dev);
+	rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_ATOMIC);
 }
 EXPORT_SYMBOL(netdev_features_change);
 
@@ -1104,7 +1105,7 @@ void netdev_state_change(struct net_device *dev)
 {
 	if (dev->flags & IFF_UP) {
 		call_netdevice_notifiers(NETDEV_CHANGE, dev);
-		rtmsg_ifinfo(RTM_NEWLINK, dev, 0);
+		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 	}
 }
 EXPORT_SYMBOL(netdev_state_change);
@@ -1204,7 +1205,7 @@ int dev_open(struct net_device *dev)
 	if (ret < 0)
 		return ret;
 
-	rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
+	rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING, GFP_KERNEL);
 	call_netdevice_notifiers(NETDEV_UP, dev);
 
 	return ret;
@@ -1277,7 +1278,7 @@ static int dev_close_many(struct list_head *head)
 	__dev_close_many(head);
 
 	list_for_each_entry(dev, head, unreg_list) {
-		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
+		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING, GFP_KERNEL);
 		call_netdevice_notifiers(NETDEV_DOWN, dev);
 	}
 
@@ -4482,7 +4483,7 @@ int netdev_set_bond_master(struct net_device *slave, struct net_device *master)
 	else
 		slave->flags &= ~IFF_SLAVE;
 
-	rtmsg_ifinfo(RTM_NEWLINK, slave, IFF_SLAVE);
+	rtmsg_ifinfo(RTM_NEWLINK, slave, IFF_SLAVE, GFP_KERNEL);
 	return 0;
 }
 EXPORT_SYMBOL(netdev_set_bond_master);
@@ -4776,7 +4777,7 @@ int dev_change_flags(struct net_device *dev, unsigned int flags)
 
 	changes = old_flags ^ dev->flags;
 	if (changes)
-		rtmsg_ifinfo(RTM_NEWLINK, dev, changes);
+		rtmsg_ifinfo(RTM_NEWLINK, dev, changes, GFP_KERNEL);
 
 	__dev_notify_flags(dev, old_flags);
 	return ret;
@@ -5289,7 +5290,7 @@ static void rollback_registered_many(struct list_head *head)
 
 		if (!dev->rtnl_link_ops ||
 		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
-			rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
+			rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
 
 		/*
 		 *	Flush the unicast and multicast chains
@@ -5643,7 +5644,7 @@ int register_netdevice(struct net_device *dev)
 	 */
 	if (!dev->rtnl_link_ops ||
 	    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
-		rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U);
+		rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U, GFP_KERNEL);
 
 out:
 	return ret;
@@ -6227,7 +6228,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	*/
 	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
-	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
+	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
 
 	/*
 	 *	Flush the unicast and multicast chains
@@ -6260,7 +6261,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	 *	Prevent userspace races by waiting until the network
 	 *	device is fully setup before sending notifications.
 	 */
-	rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U);
+	rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U, GFP_KERNEL);
 
 	synchronize_net();
 	err = 0;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2c5a0a0..ab214ce 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1631,7 +1631,7 @@ int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm)
 	}
 
 	dev->rtnl_link_state = RTNL_LINK_INITIALIZED;
-	rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U);
+	rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U, GFP_KERNEL);
 
 	__dev_notify_flags(dev, old_flags);
 	return 0;
@@ -1962,14 +1962,14 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change)
+void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change, gfp_t flags)
 {
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 	size_t if_info_size;
 
-	skb = nlmsg_new((if_info_size = if_nlmsg_size(dev, 0)), GFP_KERNEL);
+	skb = nlmsg_new((if_info_size = if_nlmsg_size(dev, 0)), flags);
 	if (skb == NULL)
 		goto errout;
 
@@ -1980,7 +1980,7 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change)
 		kfree_skb(skb);
 		goto errout;
 	}
-	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_KERNEL);
+	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
 	return;
 errout:
 	if (err < 0)
@@ -2359,9 +2359,10 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_UNREGISTER_BATCH:
 	case NETDEV_RELEASE:
 	case NETDEV_JOIN:
+	case NETDEV_FEAT_CHANGE:
 		break;
 	default:
-		rtmsg_ifinfo(RTM_NEWLINK, dev, 0);
+		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
 	}
 	return NOTIFY_DONE;
