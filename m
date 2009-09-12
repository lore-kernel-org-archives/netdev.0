From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2] genetlink: fix netns vs. netlink table locking
Date: Sat, 12 Sep 2009 07:03:15 -0600
Message-ID: <1252760595.23427.20.camel@johannes.local>
References: <1252425578.3806.22.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:34854 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695AbZILNDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Sep 2009 09:03:18 -0400
In-Reply-To: <1252425578.3806.22.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since my commits introducing netns awareness into
genetlink we can get this problem:

BUG: scheduling while atomic: modprobe/1178/0x00000002
2 locks held by modprobe/1178:
 #0:  (genl_mutex){+.+.+.}, at: [<ffffffff8135ee1a>] genl_register_mc_grou
 #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff8135eeb5>] genl_register_mc_g
Pid: 1178, comm: modprobe Not tainted 2.6.31-rc8-wl-34789-g95cb731-dirty #
Call Trace:
 [<ffffffff8103e285>] __schedule_bug+0x85/0x90
 [<ffffffff81403138>] schedule+0x108/0x588
 [<ffffffff8135b131>] netlink_table_grab+0xa1/0xf0
 [<ffffffff8135c3a7>] netlink_change_ngroups+0x47/0x100
 [<ffffffff8135ef0f>] genl_register_mc_group+0x12f/0x290

because I overlooked that netlink_table_grab() will
schedule, thinking it was just the rwlock. However,
in the contention case, that isn't actually true.

Fix this by letting the code grab the netlink table
lock first and then the RCU for netns protection.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
v2: rebase over removal of netlink_change_ngroups EXPORT_SYMBOL

 include/linux/netlink.h  |    4 +++
 net/netlink/af_netlink.c |   51 ++++++++++++++++++++++++++---------------------
 net/netlink/genetlink.c  |    5 +++-
 3 files changed, 37 insertions(+), 23 deletions(-)

--- wireless-testing.orig/include/linux/netlink.h	2009-09-12 06:58:44.000000000 -0600
+++ wireless-testing/include/linux/netlink.h	2009-09-12 06:58:53.000000000 -0600
@@ -176,12 +176,16 @@ struct netlink_skb_parms
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
 
+extern void netlink_table_grab(void);
+extern void netlink_table_ungrab(void);
+
 extern struct sock *netlink_kernel_create(struct net *net,
 					  int unit,unsigned int groups,
 					  void (*input)(struct sk_buff *skb),
 					  struct mutex *cb_mutex,
 					  struct module *module);
 extern void netlink_kernel_release(struct sock *sk);
+extern int __netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern void netlink_clear_multicast_users(struct sock *sk, unsigned int group);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
--- wireless-testing.orig/net/netlink/af_netlink.c	2009-09-12 06:58:46.000000000 -0600
+++ wireless-testing/net/netlink/af_netlink.c	2009-09-12 06:58:53.000000000 -0600
@@ -177,9 +177,11 @@ static void netlink_sock_destruct(struct
  * this, _but_ remember, it adds useless work on UP machines.
  */
 
-static void netlink_table_grab(void)
+void netlink_table_grab(void)
 	__acquires(nl_table_lock)
 {
+	might_sleep();
+
 	write_lock_irq(&nl_table_lock);
 
 	if (atomic_read(&nl_table_users)) {
@@ -200,7 +202,7 @@ static void netlink_table_grab(void)
 	}
 }
 
-static void netlink_table_ungrab(void)
+void netlink_table_ungrab(void)
 	__releases(nl_table_lock)
 {
 	write_unlock_irq(&nl_table_lock);
@@ -1549,37 +1551,21 @@ static void netlink_free_old_listeners(s
 	kfree(lrh->ptr);
 }
 
-/**
- * netlink_change_ngroups - change number of multicast groups
- *
- * This changes the number of multicast groups that are available
- * on a certain netlink family. Note that it is not possible to
- * change the number of groups to below 32. Also note that it does
- * not implicitly call netlink_clear_multicast_users() when the
- * number of groups is reduced.
- *
- * @sk: The kernel netlink socket, as returned by netlink_kernel_create().
- * @groups: The new number of groups.
- */
-int netlink_change_ngroups(struct sock *sk, unsigned int groups)
+int __netlink_change_ngroups(struct sock *sk, unsigned int groups)
 {
 	unsigned long *listeners, *old = NULL;
 	struct listeners_rcu_head *old_rcu_head;
 	struct netlink_table *tbl = &nl_table[sk->sk_protocol];
-	int err = 0;
 
 	if (groups < 32)
 		groups = 32;
 
-	netlink_table_grab();
 	if (NLGRPSZ(tbl->groups) < NLGRPSZ(groups)) {
 		listeners = kzalloc(NLGRPSZ(groups) +
 				    sizeof(struct listeners_rcu_head),
 				    GFP_ATOMIC);
-		if (!listeners) {
-			err = -ENOMEM;
-			goto out_ungrab;
-		}
+		if (!listeners)
+			return -ENOMEM;
 		old = tbl->listeners;
 		memcpy(listeners, old, NLGRPSZ(tbl->groups));
 		rcu_assign_pointer(tbl->listeners, listeners);
@@ -1597,8 +1583,29 @@ int netlink_change_ngroups(struct sock *
 	}
 	tbl->groups = groups;
 
- out_ungrab:
+	return 0;
+}
+
+/**
+ * netlink_change_ngroups - change number of multicast groups
+ *
+ * This changes the number of multicast groups that are available
+ * on a certain netlink family. Note that it is not possible to
+ * change the number of groups to below 32. Also note that it does
+ * not implicitly call netlink_clear_multicast_users() when the
+ * number of groups is reduced.
+ *
+ * @sk: The kernel netlink socket, as returned by netlink_kernel_create().
+ * @groups: The new number of groups.
+ */
+int netlink_change_ngroups(struct sock *sk, unsigned int groups)
+{
+	int err;
+
+	netlink_table_grab();
+	err = __netlink_change_ngroups(sk, groups);
 	netlink_table_ungrab();
+
 	return err;
 }
 
--- wireless-testing.orig/net/netlink/genetlink.c	2009-09-12 06:58:46.000000000 -0600
+++ wireless-testing/net/netlink/genetlink.c	2009-09-12 06:58:53.000000000 -0600
@@ -176,9 +176,10 @@ int genl_register_mc_group(struct genl_f
 	if (family->netnsok) {
 		struct net *net;
 
+		netlink_table_grab();
 		rcu_read_lock();
 		for_each_net_rcu(net) {
-			err = netlink_change_ngroups(net->genl_sock,
+			err = __netlink_change_ngroups(net->genl_sock,
 					mc_groups_longs * BITS_PER_LONG);
 			if (err) {
 				/*
@@ -188,10 +189,12 @@ int genl_register_mc_group(struct genl_f
 				 * increased on some sockets which is ok.
 				 */
 				rcu_read_unlock();
+				netlink_table_ungrab();
 				goto out;
 			}
 		}
 		rcu_read_unlock();
+		netlink_table_ungrab();
 	} else {
 		err = netlink_change_ngroups(init_net.genl_sock,
 					     mc_groups_longs * BITS_PER_LONG);


