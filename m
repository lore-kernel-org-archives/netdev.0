From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] netns: avoid allocating idr when dumping info
Date: Thu, 26 Feb 2015 22:32:56 -0800
Message-ID: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:43749 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbbB0GdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 01:33:11 -0500
Received: by paceu11 with SMTP id eu11so20239839pac.10
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 22:33:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can allocate the peer netns id when creating the link
instead of when dumping the link.

This fixes the following kernel warning:

 ===============================
 [ INFO: suspicious RCU usage. ]
 3.19.0+ #805 Tainted: G        W
 -------------------------------
 include/linux/rcupdate.h:538 Illegal context switch in RCU read-side critical section!

 other info that might help us debug this:

 rcu_scheduler_active = 1, debug_locks = 0
 2 locks held by ip/771:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8182b8f4>] netlink_dump+0x21/0x26c
  #1:  (rcu_read_lock){......}, at: [<ffffffff817d785b>] rcu_read_lock+0x0/0x6e

 stack backtrace:
 CPU: 3 PID: 771 Comm: ip Tainted: G        W       3.19.0+ #805
 Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
  0000000000000001 ffff8800d51e7718 ffffffff81a27457 0000000029e729e6
  ffff8800d6108000 ffff8800d51e7748 ffffffff810b539b ffffffff820013dd
  00000000000001c8 0000000000000000 ffff8800d7448088 ffff8800d51e7758
 Call Trace:
  [<ffffffff81a27457>] dump_stack+0x4c/0x65
  [<ffffffff810b539b>] lockdep_rcu_suspicious+0x107/0x110
  [<ffffffff8109796f>] rcu_preempt_sleep_check+0x45/0x47
  [<ffffffff8109e457>] ___might_sleep+0x1d/0x1cb
  [<ffffffff8109e67d>] __might_sleep+0x78/0x80
  [<ffffffff814b9b1f>] idr_alloc+0x45/0xd1
  [<ffffffff810cb7ab>] ? rcu_read_lock_held+0x3b/0x3d
  [<ffffffff814b9f9d>] ? idr_for_each+0x53/0x101
  [<ffffffff817c1383>] alloc_netid+0x61/0x69
  [<ffffffff817c14c3>] __peernet2id+0x79/0x8d
  [<ffffffff817c1ab7>] peernet2id+0x13/0x1f
  [<ffffffff817d8673>] rtnl_fill_ifinfo+0xa8d/0xc20
  [<ffffffff810b17d9>] ? __lock_is_held+0x39/0x52
  [<ffffffff817d894f>] rtnl_dump_ifinfo+0x149/0x213
  [<ffffffff8182b9c2>] netlink_dump+0xef/0x26c
  [<ffffffff8182bcba>] netlink_recvmsg+0x17b/0x2c5
  [<ffffffff817b0adc>] __sock_recvmsg+0x4e/0x59
  [<ffffffff817b1b40>] sock_recvmsg+0x3f/0x51
  [<ffffffff817b1f9a>] ___sys_recvmsg+0xf6/0x1d9
  [<ffffffff8115dc67>] ? handle_pte_fault+0x6e1/0xd3d
  [<ffffffff8100a3a0>] ? native_sched_clock+0x35/0x37
  [<ffffffff8109f45b>] ? sched_clock_local+0x12/0x72
  [<ffffffff8109f6ac>] ? sched_clock_cpu+0x9e/0xb7
  [<ffffffff810cb7ab>] ? rcu_read_lock_held+0x3b/0x3d
  [<ffffffff811abde8>] ? __fcheck_files+0x4c/0x58
  [<ffffffff811ac556>] ? __fget_light+0x2d/0x52
  [<ffffffff817b376f>] __sys_recvmsg+0x42/0x60
  [<ffffffff817b379f>] SyS_recvmsg+0x12/0x1c

Fixes: commit d37512a277dfb2cef ("rtnl: add link netns id to interface messages")
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/net_namespace.h | 14 +++++++++++++-
 net/core/net_namespace.c    | 14 ++------------
 net/core/rtnetlink.c        | 11 +++++++++--
 3 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 36faf49..25ac2e0 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -27,6 +27,7 @@
 #include <net/netns/nftables.h>
 #include <net/netns/xfrm.h>
 #include <linux/ns_common.h>
+#include <uapi/linux/net_namespace.h>
 
 struct user_namespace;
 struct proc_dir_entry;
@@ -291,7 +292,18 @@ static inline struct net *read_pnet(struct net * const *pnet)
 #define __net_initconst	__initconst
 #endif
 
-int peernet2id(struct net *net, struct net *peer);
+int __peernet2id(struct net *net, struct net *peer, bool alloc);
+
+/* This function returns the id of a peer netns. If no id is assigned, one will
+ * be allocated and returned.
+ */
+static inline int peernet2id(struct net *net, struct net *peer)
+{
+	int id = __peernet2id(net, peer, true);
+
+	return id >= 0 ? id : NETNSA_NSID_NOT_ASSIGNED;
+}
+
 struct net *get_net_ns_by_id(struct net *net, int id);
 
 struct pernet_operations {
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index cb5290b..9ff2164 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -175,7 +175,7 @@ static int net_eq_idr(int id, void *net, void *peer)
 	return 0;
 }
 
-static int __peernet2id(struct net *net, struct net *peer, bool alloc)
+int __peernet2id(struct net *net, struct net *peer, bool alloc)
 {
 	int id = idr_for_each(&net->netns_ids, net_eq_idr, peer);
 
@@ -192,17 +192,7 @@ static int __peernet2id(struct net *net, struct net *peer, bool alloc)
 
 	return -ENOENT;
 }
-
-/* This function returns the id of a peer netns. If no id is assigned, one will
- * be allocated and returned.
- */
-int peernet2id(struct net *net, struct net *peer)
-{
-	int id = __peernet2id(net, peer, true);
-
-	return id >= 0 ? id : NETNSA_NSID_NOT_ASSIGNED;
-}
-EXPORT_SYMBOL(peernet2id);
+EXPORT_SYMBOL(__peernet2id);
 
 struct net *get_net_ns_by_id(struct net *net, int id)
 {
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1385de0..a4348ac 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1175,8 +1175,10 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		struct net *link_net = dev->rtnl_link_ops->get_link_net(dev);
 
 		if (!net_eq(dev_net(dev), link_net)) {
-			int id = peernet2id(dev_net(dev), link_net);
+			int id = __peernet2id(dev_net(dev), link_net, false);
 
+			if (id < 0)
+				id = NETNSA_NSID_NOT_ASSIGNED;
 			if (nla_put_s32(skb, IFLA_LINK_NETNSID, id))
 				goto nla_put_failure;
 		}
@@ -2142,7 +2144,12 @@ replay:
 		dev->ifindex = ifm->ifi_index;
 
 		if (ops->newlink) {
-			err = ops->newlink(link_net ? : net, dev, tb, data);
+			struct net *src_net = link_net ?: net;
+
+			if (ops->get_link_net && !net_eq(src_net, dev_net(dev)))
+				(void)peernet2id(dev_net(dev), src_net);
+
+			err = ops->newlink(src_net, dev, tb, data);
 			/* Drivers should call free_netdev() in ->destructor
 			 * and unregister it on failure after registration
 			 * so that device could be finally freed in rtnl_unlock.
-- 
1.8.1.4
