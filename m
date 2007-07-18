From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2 2/3] netlink: allow removing multicast groups
Date: Wed, 18 Jul 2007 15:37:40 +0200
Message-ID: <1184765860.3864.8.camel@johannes.berg>
References: <20070717122706.899784000@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Zhang Rui <rui.zhang@intel.com>, jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60856 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756039AbXGRPnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 11:43:09 -0400
In-Reply-To: <20070717122706.899784000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow kicking listeners out of a multicast group when necessary
(for example if that group is going to be removed.)

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
Changes: incorporate Patrick's comments, add kernel-doc.

 include/linux/netlink.h  |    1 
 net/netlink/af_netlink.c |   57 +++++++++++++++++++++++++++++++++++++----------
 2 files changed, 46 insertions(+), 12 deletions(-)

--- wireless-dev.orig/include/linux/netlink.h	2007-07-18 15:01:06.042900849 +0200
+++ wireless-dev/include/linux/netlink.h	2007-07-18 15:01:22.542900849 +0200
@@ -162,6 +162,7 @@ extern struct sock *netlink_kernel_creat
 					  struct mutex *cb_mutex,
 					  struct module *module);
 extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
+extern void netlink_clear_multicast_users(struct sock *sk, unsigned int group);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
--- wireless-dev.orig/net/netlink/af_netlink.c	2007-07-18 15:01:10.482900849 +0200
+++ wireless-dev/net/netlink/af_netlink.c	2007-07-18 15:02:09.642900849 +0200
@@ -1027,6 +1027,23 @@ void netlink_set_err(struct sock *ssk, u
 	read_unlock(&nl_table_lock);
 }
 
+/* must be called with netlink table grabbed */
+static void netlink_update_socket_mc(struct netlink_sock *nlk,
+				     unsigned int group,
+				     int is_new)
+{
+	int old, new = !!is_new, subscriptions;
+
+	old = test_bit(group - 1, nlk->groups);
+	subscriptions = nlk->subscriptions - old + new;
+	if (new)
+		__set_bit(group - 1, nlk->groups);
+	else
+		__clear_bit(group - 1, nlk->groups);
+	netlink_update_subscriptions(&nlk->sk, subscriptions);
+	netlink_update_listeners(&nlk->sk);
+}
+
 static int netlink_setsockopt(struct socket *sock, int level, int optname,
 			      char __user *optval, int optlen)
 {
@@ -1052,9 +1069,6 @@ static int netlink_setsockopt(struct soc
 		break;
 	case NETLINK_ADD_MEMBERSHIP:
 	case NETLINK_DROP_MEMBERSHIP: {
-		unsigned int subscriptions;
-		int old, new = optname == NETLINK_ADD_MEMBERSHIP ? 1 : 0;
-
 		if (!netlink_capable(sock, NL_NONROOT_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
@@ -1063,14 +1077,8 @@ static int netlink_setsockopt(struct soc
 		if (!val || val - 1 >= nlk->ngroups)
 			return -EINVAL;
 		netlink_table_grab();
-		old = test_bit(val - 1, nlk->groups);
-		subscriptions = nlk->subscriptions - old + new;
-		if (new)
-			__set_bit(val - 1, nlk->groups);
-		else
-			__clear_bit(val - 1, nlk->groups);
-		netlink_update_subscriptions(sk, subscriptions);
-		netlink_update_listeners(sk);
+		netlink_update_socket_mc(nlk, val,
+					 optname == NETLINK_ADD_MEMBERSHIP);
 		netlink_table_ungrab();
 		err = 0;
 		break;
@@ -1351,7 +1359,9 @@ out_sock_release:
  *
  * This changes the number of multicast groups that are available
  * on a certain netlink family. Note that it is not possible to
- * change the number of groups to below 32.
+ * change the number of groups to below 32. Also note that it does
+ * not implicitly call netlink_clear_multicast_users() when the
+ * number of groups is reduced.
  *
  * @sk: The kernel netlink socket, as returned by netlink_kernel_create().
  * @groups: The new number of groups.
@@ -1386,6 +1396,29 @@ int netlink_change_ngroups(struct sock *
 }
 EXPORT_SYMBOL(netlink_change_ngroups);
 
+/**
+ * netlink_clear_multicast_users - kick off multicast listeners
+ *
+ * This function removes all listeners from the given group.
+ * @ksk: The kernel netlink socket, as returned by
+ *	netlink_kernel_create().
+ * @group: The multicast group to clear.
+ */
+void netlink_clear_multicast_users(struct sock *ksk, unsigned int group)
+{
+	struct sock *sk;
+	struct hlist_node *node;
+	struct netlink_table *tbl = &nl_table[ksk->sk_protocol];
+
+	netlink_table_grab();
+
+	sk_for_each_bound(sk, node, &tbl->mc_list)
+		netlink_update_socket_mc(nlk_sk(sk), group, 0);
+
+	netlink_table_ungrab();
+}
+EXPORT_SYMBOL(netlink_clear_multicast_users);
+
 void netlink_set_nonroot(int protocol, unsigned int flags)
 {
 	if ((unsigned int)protocol < MAX_LINKS)


