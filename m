From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] genetlink: fix netns vs. netlink table locking (2)
Date: Wed, 23 Sep 2009 11:34:30 +0200
Message-ID: <1253698470.4458.48.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59861 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbZIWJea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 05:34:30 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <johannes@sipsolutions.net>)
	id 1MqOF6-0001tD-IA
	for netdev@vger.kernel.org; Wed, 23 Sep 2009 11:34:33 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit d136f1bd366fdb7e747ca7e0218171e7a00a98a5,
there's a bug when unregistering a generic netlink family,
which is caught by the might_sleep() added in that commit:

    BUG: sleeping function called from invalid context at net/netlink/af_netlink.c:183
    in_atomic(): 1, irqs_disabled(): 0, pid: 1510, name: rmmod
    2 locks held by rmmod/1510:
     #0:  (genl_mutex){+.+.+.}, at: [<ffffffff8138283b>] genl_unregister_family+0x2b/0x130
     #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff8138270c>] __genl_unregister_mc_group+0x1c/0x120
    Pid: 1510, comm: rmmod Not tainted 2.6.31-wl #444
    Call Trace:
     [<ffffffff81044ff9>] __might_sleep+0x119/0x150
     [<ffffffff81380501>] netlink_table_grab+0x21/0x100
     [<ffffffff813813a3>] netlink_clear_multicast_users+0x23/0x60
     [<ffffffff81382761>] __genl_unregister_mc_group+0x71/0x120
     [<ffffffff81382866>] genl_unregister_family+0x56/0x130
     [<ffffffffa0007d85>] nl80211_exit+0x15/0x20 [cfg80211]
     [<ffffffffa000005a>] cfg80211_exit+0x1a/0x40 [cfg80211]

Fix in the same way by grabbing the netlink table lock
before doing rcu_read_lock().

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 include/linux/netlink.h  |    1 +
 net/netlink/af_netlink.c |   19 +++++++++++--------
 net/netlink/genetlink.c  |    4 +++-
 3 files changed, 15 insertions(+), 9 deletions(-)

--- wireless-testing.orig/include/linux/netlink.h	2009-09-23 11:15:56.000000000 +0200
+++ wireless-testing/include/linux/netlink.h	2009-09-23 11:16:14.000000000 +0200
@@ -187,6 +187,7 @@ extern struct sock *netlink_kernel_creat
 extern void netlink_kernel_release(struct sock *sk);
 extern int __netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
+extern void __netlink_clear_multicast_users(struct sock *sk, unsigned int group);
 extern void netlink_clear_multicast_users(struct sock *sk, unsigned int group);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
--- wireless-testing.orig/net/netlink/af_netlink.c	2009-09-23 11:09:44.000000000 +0200
+++ wireless-testing/net/netlink/af_netlink.c	2009-09-23 11:14:52.000000000 +0200
@@ -1610,6 +1610,16 @@ int netlink_change_ngroups(struct sock *
 }
 EXPORT_SYMBOL(netlink_change_ngroups);
 
+void __netlink_clear_multicast_users(struct sock *ksk, unsigned int group)
+{
+	struct sock *sk;
+	struct hlist_node *node;
+	struct netlink_table *tbl = &nl_table[ksk->sk_protocol];
+
+	sk_for_each_bound(sk, node, &tbl->mc_list)
+		netlink_update_socket_mc(nlk_sk(sk), group, 0);
+}
+
 /**
  * netlink_clear_multicast_users - kick off multicast listeners
  *
@@ -1620,15 +1630,8 @@ EXPORT_SYMBOL(netlink_change_ngroups);
  */
 void netlink_clear_multicast_users(struct sock *ksk, unsigned int group)
 {
-	struct sock *sk;
-	struct hlist_node *node;
-	struct netlink_table *tbl = &nl_table[ksk->sk_protocol];
-
 	netlink_table_grab();
-
-	sk_for_each_bound(sk, node, &tbl->mc_list)
-		netlink_update_socket_mc(nlk_sk(sk), group, 0);
-
+	__netlink_clear_multicast_users(ksk, group);
 	netlink_table_ungrab();
 }
 EXPORT_SYMBOL(netlink_clear_multicast_users);
--- wireless-testing.orig/net/netlink/genetlink.c	2009-09-23 11:09:46.000000000 +0200
+++ wireless-testing/net/netlink/genetlink.c	2009-09-23 11:16:50.000000000 +0200
@@ -220,10 +220,12 @@ static void __genl_unregister_mc_group(s
 	struct net *net;
 	BUG_ON(grp->family != family);
 
+	netlink_table_grab();
 	rcu_read_lock();
 	for_each_net_rcu(net)
-		netlink_clear_multicast_users(net->genl_sock, grp->id);
+		__netlink_clear_multicast_users(net->genl_sock, grp->id);
 	rcu_read_unlock();
+	netlink_table_ungrab();
 
 	clear_bit(grp->id, mc_groups);
 	list_del(&grp->list);


