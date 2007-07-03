From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink: allow removing multicast groups
Date: Tue, 03 Jul 2007 12:09:23 +0200
Message-ID: <1183457363.3841.2.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net>
	 <1183122920.4089.63.camel@johannes.berg>  <468507C9.2000800@trash.net>
	 <1183124085.4089.66.camel@johannes.berg>  <46850CB8.8000509@trash.net>
	 <1183124981.4089.69.camel@johannes.berg>  <46850EDE.5020804@trash.net>
	 <1183125924.4089.73.camel@johannes.berg>
	 <1183126739.4089.76.camel@johannes.berg>
	 <1183129006.4089.84.camel@johannes.berg>
	 <1183217536.5165.25.camel@localhost>
	 <1183365821.4089.94.camel@johannes.berg>  <4688F612.1060408@trash.net>
	 <1183386883.4089.120.camel@johannes.ber g>  <46890DF8.2020706@trash.net>
	 <1183387687.4089.124.camel@johannes.berg>
	 <1183414370.4089.141.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:34077 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758707AbXGCLx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 07:53:59 -0400
In-Reply-To: <1183414370.4089.141.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow kicking listeners out of a multicast group when necessary
(for example if that group is going to be removed.)

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 include/linux/netlink.h  |    1 +
 net/netlink/af_netlink.c |   47 ++++++++++++++++++++++++++++++++++-------------
 2 files changed, 35 insertions(+), 13 deletions(-)

--- wireless-dev.orig/include/linux/netlink.h	2007-07-03 11:54:21.818696328 +0200
+++ wireless-dev/include/linux/netlink.h	2007-07-03 11:54:32.638696328 +0200
@@ -162,6 +162,7 @@ extern struct sock *netlink_kernel_creat
 					  struct mutex *cb_mutex,
 					  struct module *module);
 extern int netlink_change_ngroups(int unit, unsigned int groups);
+extern void netlink_clear_multicast_users(int unit, unsigned int group);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
--- wireless-dev.orig/net/netlink/af_netlink.c	2007-07-03 11:54:21.908696328 +0200
+++ wireless-dev/net/netlink/af_netlink.c	2007-07-03 11:54:32.638696328 +0200
@@ -1015,6 +1015,24 @@ void netlink_set_err(struct sock *ssk, u
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
@@ -1040,9 +1058,6 @@ static int netlink_setsockopt(struct soc
 		break;
 	case NETLINK_ADD_MEMBERSHIP:
 	case NETLINK_DROP_MEMBERSHIP: {
-		unsigned int subscriptions;
-		int old, new = optname == NETLINK_ADD_MEMBERSHIP ? 1 : 0;
-
 		if (!netlink_capable(sock, NL_NONROOT_RECV))
 			return -EPERM;
 		err = netlink_realloc_groups(sk);
@@ -1050,16 +1065,8 @@ static int netlink_setsockopt(struct soc
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
@@ -1359,6 +1366,20 @@ int netlink_change_ngroups(int unit, uns
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


