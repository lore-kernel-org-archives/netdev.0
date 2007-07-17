From: Johannes Berg <johannes@sipsolutions.net>
Subject: [patch 2/3] netlink: allow removing multicast groups
Date: Tue, 17 Jul 2007 14:27:08 +0200
Message-ID: <20070717123643.626951000@sipsolutions.net>
References: <20070717122706.899784000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Zhang Rui <rui.zhang@intel.com>, jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42493 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754508AbXGQMmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 08:42:14 -0400
Content-Disposition: inline; filename=021-netlink-mc-groups.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow kicking listeners out of a multicast group when necessary
(for example if that group is going to be removed.)

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 include/linux/netlink.h  |    1 +
 net/netlink/af_netlink.c |   47 ++++++++++++++++++++++++++++++++++-------------
 2 files changed, 35 insertions(+), 13 deletions(-)

--- wireless-dev.orig/include/linux/netlink.h	2007-07-17 14:05:30.720964463 +0200
+++ wireless-dev/include/linux/netlink.h	2007-07-17 14:05:31.250964463 +0200
@@ -162,6 +162,7 @@ extern struct sock *netlink_kernel_creat
 					  struct mutex *cb_mutex,
 					  struct module *module);
 extern int netlink_change_ngroups(int unit, unsigned int groups);
+extern void netlink_clear_multicast_users(int unit, unsigned int group);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
--- wireless-dev.orig/net/netlink/af_netlink.c	2007-07-17 14:05:30.720964463 +0200
+++ wireless-dev/net/netlink/af_netlink.c	2007-07-17 14:05:31.250964463 +0200
@@ -1027,6 +1027,24 @@ void netlink_set_err(struct sock *ssk, u
 	read_unlock(&nl_table_lock);
 }
 
+static void netlink_update_socket_mc(struct netlink_sock *nlk,
+				     unsigned int group,
+				     int is_new)
+{
+	int old, new = !!is_new, subscriptions;
+
+	netlink_table_grab();
+	old = test_bit(group - 1, nlk->groups);
+	subscriptions = nlk->subscriptions - old + new;
+	if (new)
+		__set_bit(group - 1, nlk->groups);
+	else
+		__clear_bit(group - 1, nlk->groups);
+	netlink_update_subscriptions(&nlk->sk, subscriptions);
+	netlink_update_listeners(&nlk->sk);
+	netlink_table_ungrab();
+}
+
 static int netlink_setsockopt(struct socket *sock, int level, int optname,
 			      char __user *optval, int optlen)
 {
@@ -1052,9 +1070,6 @@ static int netlink_setsockopt(struct soc
 		break;
 	case NETLINK_ADD_MEMBERSHIP:
 	case NETLINK_DROP_MEMBERSHIP: {
-		unsigned int subscriptions;
-		int old, new = optname == NETLINK_ADD_MEMBERSHIP ? 1 : 0;
-
 		if (!netlink_capable(sock, NL_NONROOT_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
@@ -1062,16 +1077,8 @@ static int netlink_setsockopt(struct soc
 			return err;
 		if (!val || val - 1 >= nlk->ngroups)
 			return -EINVAL;
-		netlink_table_grab();
-		old = test_bit(val - 1, nlk->groups);
-		subscriptions = nlk->subscriptions - old + new;
-		if (new)
-			__set_bit(val - 1, nlk->groups);
-		else
-			__clear_bit(val - 1, nlk->groups);
-		netlink_update_subscriptions(sk, subscriptions);
-		netlink_update_listeners(sk);
-		netlink_table_ungrab();
+		netlink_update_socket_mc(nlk, val,
+					 optname == NETLINK_ADD_MEMBERSHIP);
 		err = 0;
 		break;
 	}
@@ -1372,6 +1379,20 @@ int netlink_change_ngroups(int unit, uns
 }
 EXPORT_SYMBOL(netlink_change_ngroups);
 
+void netlink_clear_multicast_users(int unit, unsigned int group)
+{
+	struct sock *sk;
+	struct hlist_node *node;
+
+	read_lock(&nl_table_lock);
+
+	sk_for_each_bound(sk, node, &nl_table[unit].mc_list)
+		netlink_update_socket_mc(nlk_sk(sk), group, 0);
+
+	read_unlock(&nl_table_lock);
+}
+EXPORT_SYMBOL(netlink_clear_multicast_users);
+
 void netlink_set_nonroot(int protocol, unsigned int flags)
 {
 	if ((unsigned int)protocol < MAX_LINKS)

-- 

