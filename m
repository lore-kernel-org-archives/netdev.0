From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 08/16] tipc: make tipc node table aware of net namespace
Date: Fri, 9 Jan 2015 15:27:05 +0800
Message-ID: <1420788433-17960-9-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Tero.Aho@coriant.com>,
	<Paul.Gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	<richard.alpe@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:64489 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902AbbAIH2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 02:28:07 -0500
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Global variables associated with node table are below:
- node table list (node_htable)
- node hash table list (tipc_node_list)
- node table lock (node_list_lock)
- node number counter (tipc_num_nodes)
- node link number counter (tipc_num_links)

To make node table support namespace, above global variables must be
moved to tipc_net structure in order to keep secret for different
namespaces. As a consequence, these variables are allocated and
initialized when namespace is created, and deallocated when namespace
is destroyed. After the change, functions associated with these
variables have to utilize a namespace pointer to access them. So
adding namespace pointer as a parameter of these functions is the
major change made in the commit.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/addr.h       |    2 +
 net/tipc/bcast.c      |   24 ++++-----
 net/tipc/bcast.h      |    4 +-
 net/tipc/bearer.c     |   25 +++++-----
 net/tipc/bearer.h     |    4 +-
 net/tipc/config.c     |   21 +++++---
 net/tipc/core.c       |    4 +-
 net/tipc/core.h       |    9 ++++
 net/tipc/discover.c   |    4 +-
 net/tipc/link.c       |  107 ++++++++++++++++++++++++----------------
 net/tipc/link.h       |   24 +++++----
 net/tipc/name_distr.c |   57 ++++++++++++----------
 net/tipc/name_distr.h |   10 ++--
 net/tipc/name_table.c |   16 +++---
 net/tipc/name_table.h |    8 +--
 net/tipc/net.c        |   11 +++--
 net/tipc/net.h        |    2 +-
 net/tipc/node.c       |  130 ++++++++++++++++++++++++++-----------------------
 net/tipc/node.h       |   35 +++++++------
 net/tipc/socket.c     |   72 ++++++++++++++++-----------
 net/tipc/socket.h     |    4 +-
 21 files changed, 329 insertions(+), 244 deletions(-)

diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index 60b00ab..3e1f18e 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -40,6 +40,8 @@
 #define TIPC_ZONE_MASK		0xff000000u
 #define TIPC_CLUSTER_MASK	0xfffff000u
 
+extern u32 tipc_own_addr __read_mostly;
+
 static inline u32 tipc_zone_mask(u32 addr)
 {
 	return addr & TIPC_ZONE_MASK;
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index f982311..816c0e4 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -232,13 +232,12 @@ static void bclink_retransmit_pkt(u32 after, u32 to)
  *
  * Called with no locks taken
  */
-void tipc_bclink_wakeup_users(void)
+void tipc_bclink_wakeup_users(struct net *net)
 {
 	struct sk_buff *skb;
 
 	while ((skb = skb_dequeue(&bclink->link.waiting_sks)))
-		tipc_sk_rcv(skb);
-
+		tipc_sk_rcv(net, skb);
 }
 
 /**
@@ -385,9 +384,9 @@ void tipc_bclink_update_link_state(struct net *net, struct tipc_node *n_ptr,
  * Delay any upcoming NACK by this node if another node has already
  * requested the first message this node is going to ask for.
  */
-static void bclink_peek_nack(struct tipc_msg *msg)
+static void bclink_peek_nack(struct net *net, struct tipc_msg *msg)
 {
-	struct tipc_node *n_ptr = tipc_node_find(msg_destnode(msg));
+	struct tipc_node *n_ptr = tipc_node_find(net, msg_destnode(msg));
 
 	if (unlikely(!n_ptr))
 		return;
@@ -404,11 +403,12 @@ static void bclink_peek_nack(struct tipc_msg *msg)
 
 /* tipc_bclink_xmit - broadcast buffer chain to all nodes in cluster
  *                    and to identified node local sockets
+ * @net: the applicable net namespace
  * @list: chain of buffers containing message
  * Consumes the buffer chain, except when returning -ELINKCONG
  * Returns 0 if success, otherwise errno: -ELINKCONG,-EHOSTUNREACH,-EMSGSIZE
  */
-int tipc_bclink_xmit(struct sk_buff_head *list)
+int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list)
 {
 	int rc = 0;
 	int bc = 0;
@@ -443,7 +443,7 @@ int tipc_bclink_xmit(struct sk_buff_head *list)
 
 	/* Deliver message clone */
 	if (likely(!rc))
-		tipc_sk_mcast_rcv(skb);
+		tipc_sk_mcast_rcv(net, skb);
 	else
 		kfree_skb(skb);
 
@@ -491,7 +491,7 @@ void tipc_bclink_rcv(struct net *net, struct sk_buff *buf)
 	if (msg_mc_netid(msg) != tn->net_id)
 		goto exit;
 
-	node = tipc_node_find(msg_prevnode(msg));
+	node = tipc_node_find(net, msg_prevnode(msg));
 	if (unlikely(!node))
 		goto exit;
 
@@ -514,7 +514,7 @@ void tipc_bclink_rcv(struct net *net, struct sk_buff *buf)
 			tipc_bclink_unlock();
 		} else {
 			tipc_node_unlock(node);
-			bclink_peek_nack(msg);
+			bclink_peek_nack(net, msg);
 		}
 		goto exit;
 	}
@@ -532,7 +532,7 @@ receive:
 			tipc_bclink_unlock();
 			tipc_node_unlock(node);
 			if (likely(msg_mcast(msg)))
-				tipc_sk_mcast_rcv(buf);
+				tipc_sk_mcast_rcv(net, buf);
 			else
 				kfree_skb(buf);
 		} else if (msg_user(msg) == MSG_BUNDLER) {
@@ -542,7 +542,7 @@ receive:
 			bcl->stats.recv_bundled += msg_msgcnt(msg);
 			tipc_bclink_unlock();
 			tipc_node_unlock(node);
-			tipc_link_bundle_rcv(buf);
+			tipc_link_bundle_rcv(net, buf);
 		} else if (msg_user(msg) == MSG_FRAGMENTER) {
 			tipc_buf_append(&node->bclink.reasm_buf, &buf);
 			if (unlikely(!buf && !node->bclink.reasm_buf))
@@ -563,7 +563,7 @@ receive:
 			bclink_accept_pkt(node, seqno);
 			tipc_bclink_unlock();
 			tipc_node_unlock(node);
-			tipc_named_rcv(buf);
+			tipc_named_rcv(net, buf);
 		} else {
 			tipc_bclink_lock();
 			bclink_accept_pkt(node, seqno);
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index a5fd224..fd0d17a 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -101,8 +101,8 @@ int  tipc_bclink_reset_stats(void);
 int  tipc_bclink_set_queue_limits(u32 limit);
 void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action);
 uint  tipc_bclink_get_mtu(void);
-int tipc_bclink_xmit(struct sk_buff_head *list);
-void tipc_bclink_wakeup_users(void);
+int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list);
+void tipc_bclink_wakeup_users(struct net *net);
 int tipc_nl_add_bc_link(struct tipc_nl_msg *msg);
 
 #endif
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index cdd3033..a735c08 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -69,7 +69,8 @@ static const struct nla_policy tipc_nl_media_policy[TIPC_NLA_MEDIA_MAX + 1] = {
 
 struct tipc_bearer __rcu *bearer_list[MAX_BEARERS + 1];
 
-static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down);
+static void bearer_disable(struct net *net, struct tipc_bearer *b_ptr,
+			   bool shutting_down);
 
 /**
  * tipc_media_find - locates specified media object by name
@@ -364,7 +365,7 @@ restart:
 
 	res = tipc_disc_create(net, b_ptr, &b_ptr->bcast_addr);
 	if (res) {
-		bearer_disable(b_ptr, false);
+		bearer_disable(net, b_ptr, false);
 		pr_warn("Bearer <%s> rejected, discovery object creation failed\n",
 			name);
 		return -EINVAL;
@@ -384,7 +385,7 @@ restart:
 static int tipc_reset_bearer(struct net *net, struct tipc_bearer *b_ptr)
 {
 	pr_info("Resetting bearer <%s>\n", b_ptr->name);
-	tipc_link_reset_list(b_ptr->identity);
+	tipc_link_reset_list(net, b_ptr->identity);
 	tipc_disc_reset(net, b_ptr);
 	return 0;
 }
@@ -394,14 +395,15 @@ static int tipc_reset_bearer(struct net *net, struct tipc_bearer *b_ptr)
  *
  * Note: This routine assumes caller holds RTNL lock.
  */
-static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down)
+static void bearer_disable(struct net *net, struct tipc_bearer *b_ptr,
+			   bool shutting_down)
 {
 	u32 i;
 
 	pr_info("Disabling bearer <%s>\n", b_ptr->name);
 	b_ptr->media->disable_media(b_ptr);
 
-	tipc_link_delete_list(b_ptr->identity, shutting_down);
+	tipc_link_delete_list(net, b_ptr->identity, shutting_down);
 	if (b_ptr->link_req)
 		tipc_disc_delete(b_ptr->link_req);
 
@@ -414,7 +416,7 @@ static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down)
 	kfree_rcu(b_ptr, rcu);
 }
 
-int tipc_disable_bearer(const char *name)
+int tipc_disable_bearer(struct net *net, const char *name)
 {
 	struct tipc_bearer *b_ptr;
 	int res;
@@ -424,7 +426,7 @@ int tipc_disable_bearer(const char *name)
 		pr_warn("Attempt to disable unknown bearer <%s>\n", name);
 		res = -EINVAL;
 	} else {
-		bearer_disable(b_ptr, false);
+		bearer_disable(net, b_ptr, false);
 		res = 0;
 	}
 	return res;
@@ -593,7 +595,7 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 		break;
 	case NETDEV_UNREGISTER:
 	case NETDEV_CHANGENAME:
-		bearer_disable(b_ptr, false);
+		bearer_disable(dev_net(dev), b_ptr, false);
 		break;
 	}
 	return NOTIFY_OK;
@@ -626,7 +628,7 @@ void tipc_bearer_cleanup(void)
 	dev_remove_pack(&tipc_packet_type);
 }
 
-void tipc_bearer_stop(void)
+void tipc_bearer_stop(struct net *net)
 {
 	struct tipc_bearer *b_ptr;
 	u32 i;
@@ -634,7 +636,7 @@ void tipc_bearer_stop(void)
 	for (i = 0; i < MAX_BEARERS; i++) {
 		b_ptr = rtnl_dereference(bearer_list[i]);
 		if (b_ptr) {
-			bearer_disable(b_ptr, true);
+			bearer_disable(net, b_ptr, true);
 			bearer_list[i] = NULL;
 		}
 	}
@@ -772,6 +774,7 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 	char *name;
 	struct tipc_bearer *bearer;
 	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
+	struct net *net = genl_info_net(info);
 
 	if (!info->attrs[TIPC_NLA_BEARER])
 		return -EINVAL;
@@ -794,7 +797,7 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 	}
 
-	bearer_disable(bearer, false);
+	bearer_disable(net, bearer, false);
 	rtnl_unlock();
 
 	return 0;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 43f683a..91a8eee 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -168,7 +168,7 @@ extern struct tipc_bearer __rcu *bearer_list[];
 void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr);
 int tipc_enable_bearer(struct net *net, const char *bearer_name,
 		       u32 disc_domain, u32 priority);
-int tipc_disable_bearer(const char *name);
+int tipc_disable_bearer(struct net *net, const char *name);
 
 /*
  * Routines made available to TIPC by supported media types
@@ -205,7 +205,7 @@ struct tipc_bearer *tipc_bearer_find(const char *name);
 struct tipc_media *tipc_media_find(const char *name);
 int tipc_bearer_setup(void);
 void tipc_bearer_cleanup(void);
-void tipc_bearer_stop(void);
+void tipc_bearer_stop(struct net *net);
 void tipc_bearer_send(u32 bearer_id, struct sk_buff *buf,
 		      struct tipc_media_addr *dest);
 
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 28d4272..cf2d417 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -150,12 +150,12 @@ static struct sk_buff *cfg_enable_bearer(struct net *net)
 	return tipc_cfg_reply_none();
 }
 
-static struct sk_buff *cfg_disable_bearer(void)
+static struct sk_buff *cfg_disable_bearer(struct net *net)
 {
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_BEARER_NAME))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 
-	if (tipc_disable_bearer((char *)TLV_DATA(req_tlv_area)))
+	if (tipc_disable_bearer(net, (char *)TLV_DATA(req_tlv_area)))
 		return tipc_cfg_reply_error_string("unable to disable bearer");
 
 	return tipc_cfg_reply_none();
@@ -232,16 +232,20 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 		rep_tlv_buf = tipc_cfg_reply_none();
 		break;
 	case TIPC_CMD_GET_NODES:
-		rep_tlv_buf = tipc_node_get_nodes(req_tlv_area, req_tlv_space);
+		rep_tlv_buf = tipc_node_get_nodes(net, req_tlv_area,
+						  req_tlv_space);
 		break;
 	case TIPC_CMD_GET_LINKS:
-		rep_tlv_buf = tipc_node_get_links(req_tlv_area, req_tlv_space);
+		rep_tlv_buf = tipc_node_get_links(net, req_tlv_area,
+						  req_tlv_space);
 		break;
 	case TIPC_CMD_SHOW_LINK_STATS:
-		rep_tlv_buf = tipc_link_cmd_show_stats(req_tlv_area, req_tlv_space);
+		rep_tlv_buf = tipc_link_cmd_show_stats(net, req_tlv_area,
+						       req_tlv_space);
 		break;
 	case TIPC_CMD_RESET_LINK_STATS:
-		rep_tlv_buf = tipc_link_cmd_reset_stats(req_tlv_area, req_tlv_space);
+		rep_tlv_buf = tipc_link_cmd_reset_stats(net, req_tlv_area,
+							req_tlv_space);
 		break;
 	case TIPC_CMD_SHOW_NAME_TABLE:
 		rep_tlv_buf = tipc_nametbl_get(req_tlv_area, req_tlv_space);
@@ -261,13 +265,14 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 	case TIPC_CMD_SET_LINK_TOL:
 	case TIPC_CMD_SET_LINK_PRI:
 	case TIPC_CMD_SET_LINK_WINDOW:
-		rep_tlv_buf = tipc_link_cmd_config(req_tlv_area, req_tlv_space, cmd);
+		rep_tlv_buf = tipc_link_cmd_config(net, req_tlv_area,
+						   req_tlv_space, cmd);
 		break;
 	case TIPC_CMD_ENABLE_BEARER:
 		rep_tlv_buf = cfg_enable_bearer(net);
 		break;
 	case TIPC_CMD_DISABLE_BEARER:
-		rep_tlv_buf = cfg_disable_bearer();
+		rep_tlv_buf = cfg_disable_bearer(net);
 		break;
 	case TIPC_CMD_SET_NODE_ADDR:
 		rep_tlv_buf = cfg_set_own_addr(net);
diff --git a/net/tipc/core.c b/net/tipc/core.c
index a230248..7b84439 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -57,12 +57,15 @@ static int __net_init tipc_init_net(struct net *net)
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
 	tn->net_id = 4711;
+	INIT_LIST_HEAD(&tn->node_list);
+	spin_lock_init(&tn->node_list_lock);
 
 	return 0;
 }
 
 static void __net_exit tipc_exit_net(struct net *net)
 {
+	tipc_net_stop(net);
 }
 
 static struct pernet_operations tipc_net_ops = {
@@ -144,7 +147,6 @@ out_pernet:
 static void __exit tipc_exit(void)
 {
 	unregister_pernet_subsys(&tipc_net_ops);
-	tipc_net_stop();
 	tipc_bearer_cleanup();
 	tipc_netlink_stop();
 	tipc_subscr_stop();
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 106e815..4fb1133 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -59,6 +59,8 @@
 #include <linux/etherdevice.h>
 #include <net/netns/generic.h>
 
+#include "node.h"
+
 #define TIPC_MOD_VER "2.0.0"
 
 int tipc_snprintf(char *buf, int len, const char *fmt, ...);
@@ -78,6 +80,13 @@ extern int tipc_random __read_mostly;
 
 struct tipc_net {
 	int net_id;
+
+	/* Node table and node list */
+	spinlock_t node_list_lock;
+	struct hlist_head node_htable[NODE_HTABLE_SIZE];
+	struct list_head node_list;
+	u32 num_nodes;
+	u32 num_links;
 };
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 246a237..f0fd8b4 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -162,9 +162,9 @@ void tipc_disc_rcv(struct net *net, struct sk_buff *buf,
 		return;
 
 	/* Locate, or if necessary, create, node: */
-	node = tipc_node_find(onode);
+	node = tipc_node_find(net, onode);
 	if (!node)
-		node = tipc_node_create(onode);
+		node = tipc_node_create(net, onode);
 	if (!node)
 		return;
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 248813c..f650565 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -114,7 +114,8 @@ static void link_reset_statistics(struct tipc_link *l_ptr);
 static void link_print(struct tipc_link *l_ptr, const char *str);
 static void tipc_link_sync_xmit(struct tipc_link *l);
 static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf);
-static int tipc_link_input(struct tipc_link *l, struct sk_buff *buf);
+static int tipc_link_input(struct net *net, struct tipc_link *l,
+			   struct sk_buff *buf);
 static int tipc_link_prepare_input(struct net *net, struct tipc_link *l,
 				   struct sk_buff **buf);
 
@@ -310,13 +311,15 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	return l_ptr;
 }
 
-void tipc_link_delete_list(unsigned int bearer_id, bool shutting_down)
+void tipc_link_delete_list(struct net *net, unsigned int bearer_id,
+			   bool shutting_down)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_link *l_ptr;
 	struct tipc_node *n_ptr;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
+	list_for_each_entry_rcu(n_ptr, &tn->node_list, list) {
 		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->links[bearer_id];
 		if (l_ptr) {
@@ -451,13 +454,14 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	link_reset_statistics(l_ptr);
 }
 
-void tipc_link_reset_list(unsigned int bearer_id)
+void tipc_link_reset_list(struct net *net, unsigned int bearer_id)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_link *l_ptr;
 	struct tipc_node *n_ptr;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
+	list_for_each_entry_rcu(n_ptr, &tn->node_list, list) {
 		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->links[bearer_id];
 		if (l_ptr)
@@ -773,16 +777,18 @@ static int __tipc_link_xmit_skb(struct tipc_link *link, struct sk_buff *skb)
 	return __tipc_link_xmit(link, &head);
 }
 
-int tipc_link_xmit_skb(struct sk_buff *skb, u32 dnode, u32 selector)
+int tipc_link_xmit_skb(struct net *net, struct sk_buff *skb, u32 dnode,
+		       u32 selector)
 {
 	struct sk_buff_head head;
 
 	skb2list(skb, &head);
-	return tipc_link_xmit(&head, dnode, selector);
+	return tipc_link_xmit(net, &head, dnode, selector);
 }
 
 /**
  * tipc_link_xmit() is the general link level function for message sending
+ * @net: the applicable net namespace
  * @list: chain of buffers containing message
  * @dsz: amount of user data to be sent
  * @dnode: address of destination node
@@ -790,13 +796,14 @@ int tipc_link_xmit_skb(struct sk_buff *skb, u32 dnode, u32 selector)
  * Consumes the buffer chain, except when returning -ELINKCONG
  * Returns 0 if success, otherwise errno: -ELINKCONG,-EHOSTUNREACH,-EMSGSIZE
  */
-int tipc_link_xmit(struct sk_buff_head *list, u32 dnode, u32 selector)
+int tipc_link_xmit(struct net *net, struct sk_buff_head *list, u32 dnode,
+		   u32 selector)
 {
 	struct tipc_link *link = NULL;
 	struct tipc_node *node;
 	int rc = -EHOSTUNREACH;
 
-	node = tipc_node_find(dnode);
+	node = tipc_node_find(net, dnode);
 	if (node) {
 		tipc_node_lock(node);
 		link = node->active_links[selector & 1];
@@ -813,7 +820,7 @@ int tipc_link_xmit(struct sk_buff_head *list, u32 dnode, u32 selector)
 		 * buffer, we just need to dequeue one SKB buffer from the
 		 * head list.
 		 */
-		return tipc_sk_rcv(__skb_dequeue(list));
+		return tipc_sk_rcv(net, __skb_dequeue(list));
 	}
 	__skb_queue_purge(list);
 
@@ -1066,7 +1073,7 @@ static int link_recv_buf_validate(struct sk_buff *buf)
 
 /**
  * tipc_rcv - process TIPC packets/messages arriving from off-node
- * @net: net namespace handler
+ * @net: the applicable net namespace
  * @skb: TIPC packet
  * @b_ptr: pointer to bearer message arrived on
  *
@@ -1112,7 +1119,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 			goto discard;
 
 		/* Locate neighboring node that sent message */
-		n_ptr = tipc_node_find(msg_prevnode(msg));
+		n_ptr = tipc_node_find(net, msg_prevnode(msg));
 		if (unlikely(!n_ptr))
 			goto discard;
 		tipc_node_lock(n_ptr);
@@ -1203,7 +1210,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 		}
 		tipc_node_unlock(n_ptr);
 
-		if (tipc_link_input(l_ptr, skb) != 0)
+		if (tipc_link_input(net, l_ptr, skb) != 0)
 			goto discard;
 		continue;
 unlock_discard:
@@ -1263,7 +1270,8 @@ static int tipc_link_prepare_input(struct net *net, struct tipc_link *l,
 /**
  * tipc_link_input - Deliver message too higher layers
  */
-static int tipc_link_input(struct tipc_link *l, struct sk_buff *buf)
+static int tipc_link_input(struct net *net, struct tipc_link *l,
+			   struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
 	int res = 0;
@@ -1274,13 +1282,13 @@ static int tipc_link_input(struct tipc_link *l, struct sk_buff *buf)
 	case TIPC_HIGH_IMPORTANCE:
 	case TIPC_CRITICAL_IMPORTANCE:
 	case CONN_MANAGER:
-		tipc_sk_rcv(buf);
+		tipc_sk_rcv(net, buf);
 		break;
 	case NAME_DISTRIBUTOR:
-		tipc_named_rcv(buf);
+		tipc_named_rcv(net, buf);
 		break;
 	case MSG_BUNDLER:
-		tipc_link_bundle_rcv(buf);
+		tipc_link_bundle_rcv(net, buf);
 		break;
 	default:
 		res = -EINVAL;
@@ -1855,7 +1863,7 @@ exit:
 /*
  *  Bundler functionality:
  */
-void tipc_link_bundle_rcv(struct sk_buff *buf)
+void tipc_link_bundle_rcv(struct net *net, struct sk_buff *buf)
 {
 	u32 msgcount = msg_msgcnt(buf_msg(buf));
 	u32 pos = INT_H_SIZE;
@@ -1872,13 +1880,13 @@ void tipc_link_bundle_rcv(struct sk_buff *buf)
 		pos += align(msg_size(omsg));
 		if (msg_isdata(omsg)) {
 			if (unlikely(msg_type(omsg) == TIPC_MCAST_MSG))
-				tipc_sk_mcast_rcv(obuf);
+				tipc_sk_mcast_rcv(net, obuf);
 			else
-				tipc_sk_rcv(obuf);
+				tipc_sk_rcv(net, obuf);
 		} else if (msg_user(omsg) == CONN_MANAGER) {
-			tipc_sk_rcv(obuf);
+			tipc_sk_rcv(net, obuf);
 		} else if (msg_user(omsg) == NAME_DISTRIBUTOR) {
-			tipc_named_rcv(obuf);
+			tipc_named_rcv(net, obuf);
 		} else {
 			pr_warn("Illegal bundled msg: %u\n", msg_user(omsg));
 			kfree_skb(obuf);
@@ -1919,14 +1927,17 @@ void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window)
 }
 
 /* tipc_link_find_owner - locate owner node of link by link's name
+ * @net: the applicable net namespace
  * @name: pointer to link name string
  * @bearer_id: pointer to index in 'node->links' array where the link was found.
  *
  * Returns pointer to node owning the link, or 0 if no matching link is found.
  */
-static struct tipc_node *tipc_link_find_owner(const char *link_name,
+static struct tipc_node *tipc_link_find_owner(struct net *net,
+					      const char *link_name,
 					      unsigned int *bearer_id)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_link *l_ptr;
 	struct tipc_node *n_ptr;
 	struct tipc_node *found_node = NULL;
@@ -1934,7 +1945,7 @@ static struct tipc_node *tipc_link_find_owner(const char *link_name,
 
 	*bearer_id = 0;
 	rcu_read_lock();
-	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
+	list_for_each_entry_rcu(n_ptr, &tn->node_list, list) {
 		tipc_node_lock(n_ptr);
 		for (i = 0; i < MAX_BEARERS; i++) {
 			l_ptr = n_ptr->links[i];
@@ -1978,6 +1989,7 @@ static int link_value_is_valid(u16 cmd, u32 new_value)
 
 /**
  * link_cmd_set_value - change priority/tolerance/window for link/bearer/media
+ * @net: the applicable net namespace
  * @name: ptr to link, bearer, or media name
  * @new_value: new value of link, bearer, or media setting
  * @cmd: which link, bearer, or media attribute to set (TIPC_CMD_SET_LINK_*)
@@ -1986,7 +1998,8 @@ static int link_value_is_valid(u16 cmd, u32 new_value)
  *
  * Returns 0 if value updated and negative value on error.
  */
-static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
+static int link_cmd_set_value(struct net *net, const char *name, u32 new_value,
+			      u16 cmd)
 {
 	struct tipc_node *node;
 	struct tipc_link *l_ptr;
@@ -1995,7 +2008,7 @@ static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
 	int bearer_id;
 	int res = 0;
 
-	node = tipc_link_find_owner(name, &bearer_id);
+	node = tipc_link_find_owner(net, name, &bearer_id);
 	if (node) {
 		tipc_node_lock(node);
 		l_ptr = node->links[bearer_id];
@@ -2063,8 +2076,8 @@ static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
 	return res;
 }
 
-struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space,
-				     u16 cmd)
+struct sk_buff *tipc_link_cmd_config(struct net *net, const void *req_tlv_area,
+				     int req_tlv_space, u16 cmd)
 {
 	struct tipc_link_config *args;
 	u32 new_value;
@@ -2088,7 +2101,7 @@ struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space
 						   " (cannot change setting on broadcast link)");
 	}
 
-	res = link_cmd_set_value(args->name, new_value, cmd);
+	res = link_cmd_set_value(net, args->name, new_value, cmd);
 	if (res)
 		return tipc_cfg_reply_error_string("cannot change link setting");
 
@@ -2106,7 +2119,9 @@ static void link_reset_statistics(struct tipc_link *l_ptr)
 	l_ptr->stats.recv_info = l_ptr->next_in_no;
 }
 
-struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_space)
+struct sk_buff *tipc_link_cmd_reset_stats(struct net *net,
+					  const void *req_tlv_area,
+					  int req_tlv_space)
 {
 	char *link_name;
 	struct tipc_link *l_ptr;
@@ -2122,7 +2137,7 @@ struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_
 			return tipc_cfg_reply_error_string("link not found");
 		return tipc_cfg_reply_none();
 	}
-	node = tipc_link_find_owner(link_name, &bearer_id);
+	node = tipc_link_find_owner(net, link_name, &bearer_id);
 	if (!node)
 		return tipc_cfg_reply_error_string("link not found");
 
@@ -2147,13 +2162,15 @@ static u32 percent(u32 count, u32 total)
 
 /**
  * tipc_link_stats - print link statistics
+ * @net: the applicable net namespace
  * @name: link name
  * @buf: print buffer area
  * @buf_size: size of print buffer area
  *
  * Returns length of print buffer data string (or 0 if error)
  */
-static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
+static int tipc_link_stats(struct net *net, const char *name, char *buf,
+			   const u32 buf_size)
 {
 	struct tipc_link *l;
 	struct tipc_stats *s;
@@ -2166,7 +2183,7 @@ static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
 	if (!strcmp(name, tipc_bclink_name))
 		return tipc_bclink_stats(buf, buf_size);
 
-	node = tipc_link_find_owner(name, &bearer_id);
+	node = tipc_link_find_owner(net, name, &bearer_id);
 	if (!node)
 		return 0;
 
@@ -2243,7 +2260,9 @@ static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
 	return ret;
 }
 
-struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_space)
+struct sk_buff *tipc_link_cmd_show_stats(struct net *net,
+					 const void *req_tlv_area,
+					 int req_tlv_space)
 {
 	struct sk_buff *buf;
 	struct tlv_desc *rep_tlv;
@@ -2261,7 +2280,7 @@ struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_s
 	rep_tlv = (struct tlv_desc *)buf->data;
 	pb = TLV_DATA(rep_tlv);
 	pb_len = ULTRA_STRING_MAX_LEN;
-	str_len = tipc_link_stats((char *)TLV_DATA(req_tlv_area),
+	str_len = tipc_link_stats(net, (char *)TLV_DATA(req_tlv_area),
 				  pb, pb_len);
 	if (!str_len) {
 		kfree_skb(buf);
@@ -2343,6 +2362,7 @@ int tipc_nl_link_set(struct sk_buff *skb, struct genl_info *info)
 	struct tipc_link *link;
 	struct tipc_node *node;
 	struct nlattr *attrs[TIPC_NLA_LINK_MAX + 1];
+	struct net *net = genl_info_net(info);
 
 	if (!info->attrs[TIPC_NLA_LINK])
 		return -EINVAL;
@@ -2358,7 +2378,7 @@ int tipc_nl_link_set(struct sk_buff *skb, struct genl_info *info)
 
 	name = nla_data(attrs[TIPC_NLA_LINK_NAME]);
 
-	node = tipc_link_find_owner(name, &bearer_id);
+	node = tipc_link_find_owner(net, name, &bearer_id);
 	if (!node)
 		return -EINVAL;
 
@@ -2567,6 +2587,8 @@ static int __tipc_nl_add_node_links(struct tipc_nl_msg *msg,
 
 int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct net *net = sock_net(skb->sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_node *node;
 	struct tipc_nl_msg msg;
 	u32 prev_node = cb->args[0];
@@ -2584,7 +2606,7 @@ int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	rcu_read_lock();
 
 	if (prev_node) {
-		node = tipc_node_find(prev_node);
+		node = tipc_node_find(net, prev_node);
 		if (!node) {
 			/* We never set seq or call nl_dump_check_consistent()
 			 * this means that setting prev_seq here will cause the
@@ -2596,7 +2618,8 @@ int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			goto out;
 		}
 
-		list_for_each_entry_continue_rcu(node, &tipc_node_list, list) {
+		list_for_each_entry_continue_rcu(node, &tn->node_list,
+						 list) {
 			tipc_node_lock(node);
 			err = __tipc_nl_add_node_links(&msg, node, &prev_link);
 			tipc_node_unlock(node);
@@ -2610,7 +2633,7 @@ int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (err)
 			goto out;
 
-		list_for_each_entry_rcu(node, &tipc_node_list, list) {
+		list_for_each_entry_rcu(node, &tn->node_list, list) {
 			tipc_node_lock(node);
 			err = __tipc_nl_add_node_links(&msg, node, &prev_link);
 			tipc_node_unlock(node);
@@ -2633,6 +2656,7 @@ out:
 
 int tipc_nl_link_get(struct sk_buff *skb, struct genl_info *info)
 {
+	struct net *net = genl_info_net(info);
 	struct sk_buff *ans_skb;
 	struct tipc_nl_msg msg;
 	struct tipc_link *link;
@@ -2645,7 +2669,7 @@ int tipc_nl_link_get(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 
 	name = nla_data(info->attrs[TIPC_NLA_LINK_NAME]);
-	node = tipc_link_find_owner(name, &bearer_id);
+	node = tipc_link_find_owner(net, name, &bearer_id);
 	if (!node)
 		return -EINVAL;
 
@@ -2687,6 +2711,7 @@ int tipc_nl_link_reset_stats(struct sk_buff *skb, struct genl_info *info)
 	struct tipc_link *link;
 	struct tipc_node *node;
 	struct nlattr *attrs[TIPC_NLA_LINK_MAX + 1];
+	struct net *net = genl_info_net(info);
 
 	if (!info->attrs[TIPC_NLA_LINK])
 		return -EINVAL;
@@ -2709,7 +2734,7 @@ int tipc_nl_link_reset_stats(struct sk_buff *skb, struct genl_info *info)
 		return 0;
 	}
 
-	node = tipc_link_find_owner(link_name, &bearer_id);
+	node = tipc_link_find_owner(net, link_name, &bearer_id);
 	if (!node)
 		return -EINVAL;
 
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 692268d..380e27e 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -200,27 +200,31 @@ struct tipc_port;
 struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 			      struct tipc_bearer *b_ptr,
 			      const struct tipc_media_addr *media_addr);
-void tipc_link_delete_list(unsigned int bearer_id, bool shutting_down);
+void tipc_link_delete_list(struct net *net, unsigned int bearer_id,
+			   bool shutting_down);
 void tipc_link_failover_send_queue(struct tipc_link *l_ptr);
 void tipc_link_dup_queue_xmit(struct tipc_link *l_ptr, struct tipc_link *dest);
 void tipc_link_reset_fragments(struct tipc_link *l_ptr);
 int tipc_link_is_up(struct tipc_link *l_ptr);
 int tipc_link_is_active(struct tipc_link *l_ptr);
 void tipc_link_purge_queues(struct tipc_link *l_ptr);
-struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area,
-				     int req_tlv_space,
-				     u16 cmd);
-struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area,
+struct sk_buff *tipc_link_cmd_config(struct net *net, const void *req_tlv_area,
+				     int req_tlv_space, u16 cmd);
+struct sk_buff *tipc_link_cmd_show_stats(struct net *net,
+					 const void *req_tlv_area,
 					 int req_tlv_space);
-struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area,
+struct sk_buff *tipc_link_cmd_reset_stats(struct net *net,
+					  const void *req_tlv_area,
 					  int req_tlv_space);
 void tipc_link_reset_all(struct tipc_node *node);
 void tipc_link_reset(struct tipc_link *l_ptr);
-void tipc_link_reset_list(unsigned int bearer_id);
-int tipc_link_xmit_skb(struct sk_buff *skb, u32 dest, u32 selector);
-int tipc_link_xmit(struct sk_buff_head *list, u32 dest, u32 selector);
+void tipc_link_reset_list(struct net *net, unsigned int bearer_id);
+int tipc_link_xmit_skb(struct net *net, struct sk_buff *skb, u32 dest,
+		       u32 selector);
+int tipc_link_xmit(struct net *net, struct sk_buff_head *list, u32 dest,
+		   u32 selector);
 int __tipc_link_xmit(struct tipc_link *link, struct sk_buff_head *list);
-void tipc_link_bundle_rcv(struct sk_buff *buf);
+void tipc_link_bundle_rcv(struct net *net, struct sk_buff *buf);
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
 			  u32 gap, u32 tolerance, u32 priority, u32 acked_mtu);
 void tipc_link_push_packets(struct tipc_link *l_ptr);
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index ba6083d..d40df58 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -81,14 +81,15 @@ static struct sk_buff *named_prepare_buf(u32 type, u32 size, u32 dest)
 	return buf;
 }
 
-void named_cluster_distribute(struct sk_buff *skb)
+void named_cluster_distribute(struct net *net, struct sk_buff *skb)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff *oskb;
 	struct tipc_node *node;
 	u32 dnode;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(node, &tipc_node_list, list) {
+	list_for_each_entry_rcu(node, &tn->node_list, list) {
 		dnode = node->addr;
 		if (in_own_node(dnode))
 			continue;
@@ -98,7 +99,7 @@ void named_cluster_distribute(struct sk_buff *skb)
 		if (!oskb)
 			break;
 		msg_set_destnode(buf_msg(oskb), dnode);
-		tipc_link_xmit_skb(oskb, dnode, dnode);
+		tipc_link_xmit_skb(net, oskb, dnode, dnode);
 	}
 	rcu_read_unlock();
 
@@ -160,13 +161,14 @@ struct sk_buff *tipc_named_withdraw(struct publication *publ)
  * @dnode: node to be updated
  * @pls: linked list of publication items to be packed into buffer chain
  */
-static void named_distribute(struct sk_buff_head *list, u32 dnode,
-			     struct list_head *pls)
+static void named_distribute(struct net *net, struct sk_buff_head *list,
+			     u32 dnode, struct list_head *pls)
 {
 	struct publication *publ;
 	struct sk_buff *skb = NULL;
 	struct distr_item *item = NULL;
-	uint msg_dsz = (tipc_node_get_mtu(dnode, 0) / ITEM_SIZE) * ITEM_SIZE;
+	uint msg_dsz = (tipc_node_get_mtu(net, dnode, 0) / ITEM_SIZE) *
+			ITEM_SIZE;
 	uint msg_rem = msg_dsz;
 
 	list_for_each_entry(publ, pls, local_list) {
@@ -202,30 +204,31 @@ static void named_distribute(struct sk_buff_head *list, u32 dnode,
 /**
  * tipc_named_node_up - tell specified node about all publications by this node
  */
-void tipc_named_node_up(u32 dnode)
+void tipc_named_node_up(struct net *net, u32 dnode)
 {
 	struct sk_buff_head head;
 
 	__skb_queue_head_init(&head);
 
 	rcu_read_lock();
-	named_distribute(&head, dnode,
+	named_distribute(net, &head, dnode,
 			 &tipc_nametbl->publ_list[TIPC_CLUSTER_SCOPE]);
-	named_distribute(&head, dnode,
+	named_distribute(net, &head, dnode,
 			 &tipc_nametbl->publ_list[TIPC_ZONE_SCOPE]);
 	rcu_read_unlock();
 
-	tipc_link_xmit(&head, dnode, dnode);
+	tipc_link_xmit(net, &head, dnode, dnode);
 }
 
-static void tipc_publ_subscribe(struct publication *publ, u32 addr)
+static void tipc_publ_subscribe(struct net *net, struct publication *publ,
+				u32 addr)
 {
 	struct tipc_node *node;
 
 	if (in_own_node(addr))
 		return;
 
-	node = tipc_node_find(addr);
+	node = tipc_node_find(net, addr);
 	if (!node) {
 		pr_warn("Node subscription rejected, unknown node 0x%x\n",
 			addr);
@@ -237,11 +240,12 @@ static void tipc_publ_subscribe(struct publication *publ, u32 addr)
 	tipc_node_unlock(node);
 }
 
-static void tipc_publ_unsubscribe(struct publication *publ, u32 addr)
+static void tipc_publ_unsubscribe(struct net *net, struct publication *publ,
+				  u32 addr)
 {
 	struct tipc_node *node;
 
-	node = tipc_node_find(addr);
+	node = tipc_node_find(net, addr);
 	if (!node)
 		return;
 
@@ -256,7 +260,7 @@ static void tipc_publ_unsubscribe(struct publication *publ, u32 addr)
  * Invoked for each publication issued by a newly failed node.
  * Removes publication structure from name table & deletes it.
  */
-static void tipc_publ_purge(struct publication *publ, u32 addr)
+static void tipc_publ_purge(struct net *net, struct publication *publ, u32 addr)
 {
 	struct publication *p;
 
@@ -264,7 +268,7 @@ static void tipc_publ_purge(struct publication *publ, u32 addr)
 	p = tipc_nametbl_remove_publ(publ->type, publ->lower,
 				     publ->node, publ->ref, publ->key);
 	if (p)
-		tipc_publ_unsubscribe(p, addr);
+		tipc_publ_unsubscribe(net, p, addr);
 	spin_unlock_bh(&tipc_nametbl_lock);
 
 	if (p != publ) {
@@ -277,12 +281,12 @@ static void tipc_publ_purge(struct publication *publ, u32 addr)
 	kfree_rcu(p, rcu);
 }
 
-void tipc_publ_notify(struct list_head *nsub_list, u32 addr)
+void tipc_publ_notify(struct net *net, struct list_head *nsub_list, u32 addr)
 {
 	struct publication *publ, *tmp;
 
 	list_for_each_entry_safe(publ, tmp, nsub_list, nodesub_list)
-		tipc_publ_purge(publ, addr);
+		tipc_publ_purge(net, publ, addr);
 }
 
 /**
@@ -292,7 +296,8 @@ void tipc_publ_notify(struct list_head *nsub_list, u32 addr)
  * tipc_nametbl_lock must be held.
  * Returns the publication item if successful, otherwise NULL.
  */
-static bool tipc_update_nametbl(struct distr_item *i, u32 node, u32 dtype)
+static bool tipc_update_nametbl(struct net *net, struct distr_item *i,
+				u32 node, u32 dtype)
 {
 	struct publication *publ = NULL;
 
@@ -302,7 +307,7 @@ static bool tipc_update_nametbl(struct distr_item *i, u32 node, u32 dtype)
 						TIPC_CLUSTER_SCOPE, node,
 						ntohl(i->ref), ntohl(i->key));
 		if (publ) {
-			tipc_publ_subscribe(publ, node);
+			tipc_publ_subscribe(net, publ, node);
 			return true;
 		}
 	} else if (dtype == WITHDRAWAL) {
@@ -310,7 +315,7 @@ static bool tipc_update_nametbl(struct distr_item *i, u32 node, u32 dtype)
 						node, ntohl(i->ref),
 						ntohl(i->key));
 		if (publ) {
-			tipc_publ_unsubscribe(publ, node);
+			tipc_publ_unsubscribe(net, publ, node);
 			kfree_rcu(publ, rcu);
 			return true;
 		}
@@ -343,7 +348,7 @@ static void tipc_named_add_backlog(struct distr_item *i, u32 type, u32 node)
  * tipc_named_process_backlog - try to process any pending name table updates
  * from the network.
  */
-void tipc_named_process_backlog(void)
+void tipc_named_process_backlog(struct net *net)
 {
 	struct distr_queue_item *e, *tmp;
 	char addr[16];
@@ -351,7 +356,7 @@ void tipc_named_process_backlog(void)
 
 	list_for_each_entry_safe(e, tmp, &tipc_dist_queue, next) {
 		if (time_after(e->expires, now)) {
-			if (!tipc_update_nametbl(&e->i, e->node, e->dtype))
+			if (!tipc_update_nametbl(net, &e->i, e->node, e->dtype))
 				continue;
 		} else {
 			tipc_addr_string_fill(addr, e->node);
@@ -369,7 +374,7 @@ void tipc_named_process_backlog(void)
 /**
  * tipc_named_rcv - process name table update message sent by another node
  */
-void tipc_named_rcv(struct sk_buff *buf)
+void tipc_named_rcv(struct net *net, struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
 	struct distr_item *item = (struct distr_item *)msg_data(msg);
@@ -378,11 +383,11 @@ void tipc_named_rcv(struct sk_buff *buf)
 
 	spin_lock_bh(&tipc_nametbl_lock);
 	while (count--) {
-		if (!tipc_update_nametbl(item, node, msg_type(msg)))
+		if (!tipc_update_nametbl(net, item, node, msg_type(msg)))
 			tipc_named_add_backlog(item, msg_type(msg), node);
 		item++;
 	}
-	tipc_named_process_backlog();
+	tipc_named_process_backlog(net);
 	spin_unlock_bh(&tipc_nametbl_lock);
 	kfree_skb(buf);
 }
diff --git a/net/tipc/name_distr.h b/net/tipc/name_distr.h
index cef55ce..8039d84 100644
--- a/net/tipc/name_distr.h
+++ b/net/tipc/name_distr.h
@@ -69,11 +69,11 @@ struct distr_item {
 
 struct sk_buff *tipc_named_publish(struct publication *publ);
 struct sk_buff *tipc_named_withdraw(struct publication *publ);
-void named_cluster_distribute(struct sk_buff *buf);
-void tipc_named_node_up(u32 dnode);
-void tipc_named_rcv(struct sk_buff *buf);
+void named_cluster_distribute(struct net *net, struct sk_buff *buf);
+void tipc_named_node_up(struct net *net, u32 dnode);
+void tipc_named_rcv(struct net *net, struct sk_buff *buf);
 void tipc_named_reinit(void);
-void tipc_named_process_backlog(void);
-void tipc_publ_notify(struct list_head *nsub_list, u32 addr);
+void tipc_named_process_backlog(struct net *net);
+void tipc_publ_notify(struct net *net, struct list_head *nsub_list, u32 addr);
 
 #endif
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index c8df022..cf17790 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -650,8 +650,9 @@ exit:
 /*
  * tipc_nametbl_publish - add name publication to network name tables
  */
-struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
-					 u32 scope, u32 port_ref, u32 key)
+struct publication *tipc_nametbl_publish(struct net *net, u32 type, u32 lower,
+					 u32 upper, u32 scope, u32 port_ref,
+					 u32 key)
 {
 	struct publication *publ;
 	struct sk_buff *buf = NULL;
@@ -670,19 +671,20 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 		tipc_nametbl->local_publ_count++;
 		buf = tipc_named_publish(publ);
 		/* Any pending external events? */
-		tipc_named_process_backlog();
+		tipc_named_process_backlog(net);
 	}
 	spin_unlock_bh(&tipc_nametbl_lock);
 
 	if (buf)
-		named_cluster_distribute(buf);
+		named_cluster_distribute(net, buf);
 	return publ;
 }
 
 /**
  * tipc_nametbl_withdraw - withdraw name publication from network name tables
  */
-int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
+int tipc_nametbl_withdraw(struct net *net, u32 type, u32 lower, u32 ref,
+			  u32 key)
 {
 	struct publication *publ;
 	struct sk_buff *skb = NULL;
@@ -693,7 +695,7 @@ int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 		tipc_nametbl->local_publ_count--;
 		skb = tipc_named_withdraw(publ);
 		/* Any pending external events? */
-		tipc_named_process_backlog();
+		tipc_named_process_backlog(net);
 		list_del_init(&publ->pport_list);
 		kfree_rcu(publ, rcu);
 	} else {
@@ -704,7 +706,7 @@ int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 	spin_unlock_bh(&tipc_nametbl_lock);
 
 	if (skb) {
-		named_cluster_distribute(skb);
+		named_cluster_distribute(net, skb);
 		return 1;
 	}
 	return 0;
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index 5f0dee9..efccaca 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -104,9 +104,11 @@ struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space);
 u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *node);
 int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 			      struct tipc_port_list *dports);
-struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
-					 u32 scope, u32 port_ref, u32 key);
-int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key);
+struct publication *tipc_nametbl_publish(struct net *net, u32 type, u32 lower,
+					 u32 upper, u32 scope, u32 port_ref,
+					 u32 key);
+int tipc_nametbl_withdraw(struct net *net, u32 type, u32 lower, u32 ref,
+			  u32 key);
 struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
 					     u32 scope, u32 node, u32 ref,
 					     u32 key);
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 5ce9d62..de18aac 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -121,7 +121,7 @@ int tipc_net_start(struct net *net, u32 addr)
 	if (res)
 		return res;
 
-	tipc_nametbl_publish(TIPC_CFG_SRV, tipc_own_addr, tipc_own_addr,
+	tipc_nametbl_publish(net, TIPC_CFG_SRV, tipc_own_addr, tipc_own_addr,
 			     TIPC_ZONE_SCOPE, 0, tipc_own_addr);
 
 	pr_info("Started in network mode\n");
@@ -131,16 +131,17 @@ int tipc_net_start(struct net *net, u32 addr)
 	return 0;
 }
 
-void tipc_net_stop(void)
+void tipc_net_stop(struct net *net)
 {
 	if (!tipc_own_addr)
 		return;
 
-	tipc_nametbl_withdraw(TIPC_CFG_SRV, tipc_own_addr, 0, tipc_own_addr);
+	tipc_nametbl_withdraw(net, TIPC_CFG_SRV, tipc_own_addr, 0,
+			      tipc_own_addr);
 	rtnl_lock();
-	tipc_bearer_stop();
+	tipc_bearer_stop(net);
 	tipc_bclink_stop();
-	tipc_node_stop();
+	tipc_node_stop(net);
 	rtnl_unlock();
 
 	pr_info("Left network mode\n");
diff --git a/net/tipc/net.h b/net/tipc/net.h
index 2c4812f..77a7a11 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -41,7 +41,7 @@
 
 int tipc_net_start(struct net *net, u32 addr);
 
-void tipc_net_stop(void);
+void tipc_net_stop(struct net *net);
 
 int tipc_nl_net_dump(struct sk_buff *skb, struct netlink_callback *cb);
 int tipc_nl_net_set(struct sk_buff *skb, struct genl_info *info);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 8d353ec..a0ca1ac 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -40,17 +40,9 @@
 #include "name_distr.h"
 #include "socket.h"
 
-#define NODE_HTABLE_SIZE 512
-
 static void node_lost_contact(struct tipc_node *n_ptr);
 static void node_established_contact(struct tipc_node *n_ptr);
 
-static struct hlist_head node_htable[NODE_HTABLE_SIZE];
-LIST_HEAD(tipc_node_list);
-static u32 tipc_num_nodes;
-static u32 tipc_num_links;
-static DEFINE_SPINLOCK(node_list_lock);
-
 struct tipc_sock_conn {
 	u32 port;
 	u32 peer_port;
@@ -78,15 +70,17 @@ static unsigned int tipc_hashfn(u32 addr)
 /*
  * tipc_node_find - locate specified node object, if it exists
  */
-struct tipc_node *tipc_node_find(u32 addr)
+struct tipc_node *tipc_node_find(struct net *net, u32 addr)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_node *node;
 
 	if (unlikely(!in_own_cluster_exact(addr)))
 		return NULL;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(node, &node_htable[tipc_hashfn(addr)], hash) {
+	hlist_for_each_entry_rcu(node, &tn->node_htable[tipc_hashfn(addr)],
+				 hash) {
 		if (node->addr == addr) {
 			rcu_read_unlock();
 			return node;
@@ -96,20 +90,22 @@ struct tipc_node *tipc_node_find(u32 addr)
 	return NULL;
 }
 
-struct tipc_node *tipc_node_create(u32 addr)
+struct tipc_node *tipc_node_create(struct net *net, u32 addr)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_node *n_ptr, *temp_node;
 
-	spin_lock_bh(&node_list_lock);
+	spin_lock_bh(&tn->node_list_lock);
 
 	n_ptr = kzalloc(sizeof(*n_ptr), GFP_ATOMIC);
 	if (!n_ptr) {
-		spin_unlock_bh(&node_list_lock);
+		spin_unlock_bh(&tn->node_list_lock);
 		pr_warn("Node creation failed, no memory\n");
 		return NULL;
 	}
 
 	n_ptr->addr = addr;
+	n_ptr->net = net;
 	spin_lock_init(&n_ptr->lock);
 	INIT_HLIST_NODE(&n_ptr->hash);
 	INIT_LIST_HEAD(&n_ptr->list);
@@ -118,9 +114,9 @@ struct tipc_node *tipc_node_create(u32 addr)
 	skb_queue_head_init(&n_ptr->waiting_sks);
 	__skb_queue_head_init(&n_ptr->bclink.deferred_queue);
 
-	hlist_add_head_rcu(&n_ptr->hash, &node_htable[tipc_hashfn(addr)]);
+	hlist_add_head_rcu(&n_ptr->hash, &tn->node_htable[tipc_hashfn(addr)]);
 
-	list_for_each_entry_rcu(temp_node, &tipc_node_list, list) {
+	list_for_each_entry_rcu(temp_node, &tn->node_list, list) {
 		if (n_ptr->addr < temp_node->addr)
 			break;
 	}
@@ -128,32 +124,33 @@ struct tipc_node *tipc_node_create(u32 addr)
 	n_ptr->action_flags = TIPC_WAIT_PEER_LINKS_DOWN;
 	n_ptr->signature = INVALID_NODE_SIG;
 
-	tipc_num_nodes++;
+	tn->num_nodes++;
 
-	spin_unlock_bh(&node_list_lock);
+	spin_unlock_bh(&tn->node_list_lock);
 	return n_ptr;
 }
 
-static void tipc_node_delete(struct tipc_node *n_ptr)
+static void tipc_node_delete(struct tipc_net *tn, struct tipc_node *n_ptr)
 {
 	list_del_rcu(&n_ptr->list);
 	hlist_del_rcu(&n_ptr->hash);
 	kfree_rcu(n_ptr, rcu);
 
-	tipc_num_nodes--;
+	tn->num_nodes--;
 }
 
-void tipc_node_stop(void)
+void tipc_node_stop(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_node *node, *t_node;
 
-	spin_lock_bh(&node_list_lock);
-	list_for_each_entry_safe(node, t_node, &tipc_node_list, list)
-		tipc_node_delete(node);
-	spin_unlock_bh(&node_list_lock);
+	spin_lock_bh(&tn->node_list_lock);
+	list_for_each_entry_safe(node, t_node, &tn->node_list, list)
+		tipc_node_delete(tn, node);
+	spin_unlock_bh(&tn->node_list_lock);
 }
 
-int tipc_node_add_conn(u32 dnode, u32 port, u32 peer_port)
+int tipc_node_add_conn(struct net *net, u32 dnode, u32 port, u32 peer_port)
 {
 	struct tipc_node *node;
 	struct tipc_sock_conn *conn;
@@ -161,7 +158,7 @@ int tipc_node_add_conn(u32 dnode, u32 port, u32 peer_port)
 	if (in_own_node(dnode))
 		return 0;
 
-	node = tipc_node_find(dnode);
+	node = tipc_node_find(net, dnode);
 	if (!node) {
 		pr_warn("Connecting sock to node 0x%x failed\n", dnode);
 		return -EHOSTUNREACH;
@@ -179,7 +176,7 @@ int tipc_node_add_conn(u32 dnode, u32 port, u32 peer_port)
 	return 0;
 }
 
-void tipc_node_remove_conn(u32 dnode, u32 port)
+void tipc_node_remove_conn(struct net *net, u32 dnode, u32 port)
 {
 	struct tipc_node *node;
 	struct tipc_sock_conn *conn, *safe;
@@ -187,7 +184,7 @@ void tipc_node_remove_conn(u32 dnode, u32 port)
 	if (in_own_node(dnode))
 		return;
 
-	node = tipc_node_find(dnode);
+	node = tipc_node_find(net, dnode);
 	if (!node)
 		return;
 
@@ -201,7 +198,7 @@ void tipc_node_remove_conn(u32 dnode, u32 port)
 	tipc_node_unlock(node);
 }
 
-void tipc_node_abort_sock_conns(struct list_head *conns)
+void tipc_node_abort_sock_conns(struct net *net, struct list_head *conns)
 {
 	struct tipc_sock_conn *conn, *safe;
 	struct sk_buff *buf;
@@ -212,7 +209,7 @@ void tipc_node_abort_sock_conns(struct list_head *conns)
 				      conn->peer_node, conn->port,
 				      conn->peer_port, TIPC_ERR_NO_NODE);
 		if (likely(buf))
-			tipc_sk_rcv(buf);
+			tipc_sk_rcv(net, buf);
 		list_del(&conn->list);
 		kfree(conn);
 	}
@@ -342,24 +339,27 @@ int tipc_node_is_up(struct tipc_node *n_ptr)
 
 void tipc_node_attach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
+	struct tipc_net *tn = net_generic(n_ptr->net, tipc_net_id);
+
 	n_ptr->links[l_ptr->bearer_id] = l_ptr;
-	spin_lock_bh(&node_list_lock);
-	tipc_num_links++;
-	spin_unlock_bh(&node_list_lock);
+	spin_lock_bh(&tn->node_list_lock);
+	tn->num_links++;
+	spin_unlock_bh(&tn->node_list_lock);
 	n_ptr->link_cnt++;
 }
 
 void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
+	struct tipc_net *tn = net_generic(n_ptr->net, tipc_net_id);
 	int i;
 
 	for (i = 0; i < MAX_BEARERS; i++) {
 		if (l_ptr != n_ptr->links[i])
 			continue;
 		n_ptr->links[i] = NULL;
-		spin_lock_bh(&node_list_lock);
-		tipc_num_links--;
-		spin_unlock_bh(&node_list_lock);
+		spin_lock_bh(&tn->node_list_lock);
+		tn->num_links--;
+		spin_unlock_bh(&tn->node_list_lock);
 		n_ptr->link_cnt--;
 	}
 }
@@ -414,8 +414,10 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 			       TIPC_NOTIFY_NODE_DOWN;
 }
 
-struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
+struct sk_buff *tipc_node_get_nodes(struct net *net, const void *req_tlv_area,
+				    int req_tlv_space)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	u32 domain;
 	struct sk_buff *buf;
 	struct tipc_node *n_ptr;
@@ -430,20 +432,20 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (network address)");
 
-	spin_lock_bh(&node_list_lock);
-	if (!tipc_num_nodes) {
-		spin_unlock_bh(&node_list_lock);
+	spin_lock_bh(&tn->node_list_lock);
+	if (!tn->num_nodes) {
+		spin_unlock_bh(&tn->node_list_lock);
 		return tipc_cfg_reply_none();
 	}
 
 	/* For now, get space for all other nodes */
-	payload_size = TLV_SPACE(sizeof(node_info)) * tipc_num_nodes;
+	payload_size = TLV_SPACE(sizeof(node_info)) * tn->num_nodes;
 	if (payload_size > 32768u) {
-		spin_unlock_bh(&node_list_lock);
+		spin_unlock_bh(&tn->node_list_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (too many nodes)");
 	}
-	spin_unlock_bh(&node_list_lock);
+	spin_unlock_bh(&tn->node_list_lock);
 
 	buf = tipc_cfg_reply_alloc(payload_size);
 	if (!buf)
@@ -451,7 +453,7 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 
 	/* Add TLVs for all nodes in scope */
 	rcu_read_lock();
-	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
+	list_for_each_entry_rcu(n_ptr, &tn->node_list, list) {
 		if (!tipc_in_scope(domain, n_ptr->addr))
 			continue;
 		node_info.addr = htonl(n_ptr->addr);
@@ -463,8 +465,10 @@ struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 	return buf;
 }
 
-struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
+struct sk_buff *tipc_node_get_links(struct net *net, const void *req_tlv_area,
+				    int req_tlv_space)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	u32 domain;
 	struct sk_buff *buf;
 	struct tipc_node *n_ptr;
@@ -482,15 +486,15 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 	if (!tipc_own_addr)
 		return tipc_cfg_reply_none();
 
-	spin_lock_bh(&node_list_lock);
+	spin_lock_bh(&tn->node_list_lock);
 	/* Get space for all unicast links + broadcast link */
-	payload_size = TLV_SPACE((sizeof(link_info)) * (tipc_num_links + 1));
+	payload_size = TLV_SPACE((sizeof(link_info)) * (tn->num_links + 1));
 	if (payload_size > 32768u) {
-		spin_unlock_bh(&node_list_lock);
+		spin_unlock_bh(&tn->node_list_lock);
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (too many links)");
 	}
-	spin_unlock_bh(&node_list_lock);
+	spin_unlock_bh(&tn->node_list_lock);
 
 	buf = tipc_cfg_reply_alloc(payload_size);
 	if (!buf)
@@ -504,7 +508,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 
 	/* Add TLVs for any other links in scope */
 	rcu_read_lock();
-	list_for_each_entry_rcu(n_ptr, &tipc_node_list, list) {
+	list_for_each_entry_rcu(n_ptr, &tn->node_list, list) {
 		u32 i;
 
 		if (!tipc_in_scope(domain, n_ptr->addr))
@@ -534,10 +538,11 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
  *
  * Returns 0 on success
  */
-int tipc_node_get_linkname(u32 bearer_id, u32 addr, char *linkname, size_t len)
+int tipc_node_get_linkname(struct net *net, u32 bearer_id, u32 addr,
+			   char *linkname, size_t len)
 {
 	struct tipc_link *link;
-	struct tipc_node *node = tipc_node_find(addr);
+	struct tipc_node *node = tipc_node_find(net, addr);
 
 	if ((bearer_id >= MAX_BEARERS) || !node)
 		return -EINVAL;
@@ -554,6 +559,7 @@ int tipc_node_get_linkname(u32 bearer_id, u32 addr, char *linkname, size_t len)
 
 void tipc_node_unlock(struct tipc_node *node)
 {
+	struct net *net = node->net;
 	LIST_HEAD(nsub_list);
 	LIST_HEAD(conn_sks);
 	struct sk_buff_head waiting_sks;
@@ -585,26 +591,26 @@ void tipc_node_unlock(struct tipc_node *node)
 	spin_unlock_bh(&node->lock);
 
 	while (!skb_queue_empty(&waiting_sks))
-		tipc_sk_rcv(__skb_dequeue(&waiting_sks));
+		tipc_sk_rcv(net, __skb_dequeue(&waiting_sks));
 
 	if (!list_empty(&conn_sks))
-		tipc_node_abort_sock_conns(&conn_sks);
+		tipc_node_abort_sock_conns(net, &conn_sks);
 
 	if (!list_empty(&nsub_list))
-		tipc_publ_notify(&nsub_list, addr);
+		tipc_publ_notify(net, &nsub_list, addr);
 
 	if (flags & TIPC_WAKEUP_BCAST_USERS)
-		tipc_bclink_wakeup_users();
+		tipc_bclink_wakeup_users(net);
 
 	if (flags & TIPC_NOTIFY_NODE_UP)
-		tipc_named_node_up(addr);
+		tipc_named_node_up(net, addr);
 
 	if (flags & TIPC_NOTIFY_LINK_UP)
-		tipc_nametbl_publish(TIPC_LINK_STATE, addr, addr,
+		tipc_nametbl_publish(net, TIPC_LINK_STATE, addr, addr,
 				     TIPC_NODE_SCOPE, link_id, addr);
 
 	if (flags & TIPC_NOTIFY_LINK_DOWN)
-		tipc_nametbl_withdraw(TIPC_LINK_STATE, addr,
+		tipc_nametbl_withdraw(net, TIPC_LINK_STATE, addr,
 				      link_id, addr);
 }
 
@@ -645,6 +651,8 @@ msg_full:
 int tipc_nl_node_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int err;
+	struct net *net = sock_net(skb->sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	int done = cb->args[0];
 	int last_addr = cb->args[1];
 	struct tipc_node *node;
@@ -659,7 +667,7 @@ int tipc_nl_node_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	rcu_read_lock();
 
-	if (last_addr && !tipc_node_find(last_addr)) {
+	if (last_addr && !tipc_node_find(net, last_addr)) {
 		rcu_read_unlock();
 		/* We never set seq or call nl_dump_check_consistent() this
 		 * means that setting prev_seq here will cause the consistence
@@ -671,7 +679,7 @@ int tipc_nl_node_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		return -EPIPE;
 	}
 
-	list_for_each_entry_rcu(node, &tipc_node_list, list) {
+	list_for_each_entry_rcu(node, &tn->node_list, list) {
 		if (last_addr) {
 			if (node->addr == last_addr)
 				last_addr = 0;
diff --git a/net/tipc/node.h b/net/tipc/node.h
index cbe0e95..43ef88e 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -42,10 +42,10 @@
 #include "bearer.h"
 #include "msg.h"
 
-/*
- * Out-of-range value for node signature
- */
-#define INVALID_NODE_SIG 0x10000
+/* Out-of-range value for node signature */
+#define INVALID_NODE_SIG	0x10000
+
+#define NODE_HTABLE_SIZE	512
 
 /* Flags used to take different actions according to flag type
  * TIPC_WAIT_PEER_LINKS_DOWN: wait to see that peer's links are down
@@ -90,6 +90,7 @@ struct tipc_node_bclink {
  * struct tipc_node - TIPC node structure
  * @addr: network address of node
  * @lock: spinlock governing access to structure
+ * @net: the applicable net namespace
  * @hash: links to adjacent nodes in unsorted hash chain
  * @active_links: pointers to active links to node
  * @links: pointers to all links to node
@@ -106,6 +107,7 @@ struct tipc_node_bclink {
 struct tipc_node {
 	u32 addr;
 	spinlock_t lock;
+	struct net *net;
 	struct hlist_node hash;
 	struct tipc_link *active_links[2];
 	u32 act_mtus[2];
@@ -123,23 +125,24 @@ struct tipc_node {
 	struct rcu_head rcu;
 };
 
-extern struct list_head tipc_node_list;
-
-struct tipc_node *tipc_node_find(u32 addr);
-struct tipc_node *tipc_node_create(u32 addr);
-void tipc_node_stop(void);
+struct tipc_node *tipc_node_find(struct net *net, u32 addr);
+struct tipc_node *tipc_node_create(struct net *net, u32 addr);
+void tipc_node_stop(struct net *net);
 void tipc_node_attach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 int tipc_node_active_links(struct tipc_node *n_ptr);
 int tipc_node_is_up(struct tipc_node *n_ptr);
-struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space);
-struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space);
-int tipc_node_get_linkname(u32 bearer_id, u32 node, char *linkname, size_t len);
+struct sk_buff *tipc_node_get_links(struct net *net, const void *req_tlv_area,
+				    int req_tlv_space);
+struct sk_buff *tipc_node_get_nodes(struct net *net, const void *req_tlv_area,
+				    int req_tlv_space);
+int tipc_node_get_linkname(struct net *net, u32 bearer_id, u32 node,
+			   char *linkname, size_t len);
 void tipc_node_unlock(struct tipc_node *node);
-int tipc_node_add_conn(u32 dnode, u32 port, u32 peer_port);
-void tipc_node_remove_conn(u32 dnode, u32 port);
+int tipc_node_add_conn(struct net *net, u32 dnode, u32 port, u32 peer_port);
+void tipc_node_remove_conn(struct net *net, u32 dnode, u32 port);
 
 int tipc_nl_node_dump(struct sk_buff *skb, struct netlink_callback *cb);
 
@@ -154,12 +157,12 @@ static inline bool tipc_node_blocked(struct tipc_node *node)
 		TIPC_NOTIFY_NODE_DOWN | TIPC_WAIT_OWN_LINKS_DOWN));
 }
 
-static inline uint tipc_node_get_mtu(u32 addr, u32 selector)
+static inline uint tipc_node_get_mtu(struct net *net, u32 addr, u32 selector)
 {
 	struct tipc_node *node;
 	u32 mtu;
 
-	node = tipc_node_find(addr);
+	node = tipc_node_find(net, addr);
 
 	if (likely(node))
 		mtu = node->act_mtus[selector & 1];
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index c58f66b..6883145 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -257,7 +257,7 @@ static void tsk_rej_rx_queue(struct sock *sk)
 
 	while ((skb = __skb_dequeue(&sk->sk_receive_queue))) {
 		if (tipc_msg_reverse(skb, &dnode, TIPC_ERR_NO_PORT))
-			tipc_link_xmit_skb(skb, dnode, 0);
+			tipc_link_xmit_skb(sock_net(sk), skb, dnode, 0);
 	}
 }
 
@@ -473,6 +473,7 @@ static void tipc_sk_callback(struct rcu_head *head)
 static int tipc_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
+	struct net *net = sock_net(sk);
 	struct tipc_sock *tsk;
 	struct sk_buff *skb;
 	u32 dnode, probing_state;
@@ -503,10 +504,10 @@ static int tipc_release(struct socket *sock)
 			    (sock->state == SS_CONNECTED)) {
 				sock->state = SS_DISCONNECTING;
 				tsk->connected = 0;
-				tipc_node_remove_conn(dnode, tsk->portid);
+				tipc_node_remove_conn(net, dnode, tsk->portid);
 			}
 			if (tipc_msg_reverse(skb, &dnode, TIPC_ERR_NO_PORT))
-				tipc_link_xmit_skb(skb, dnode, 0);
+				tipc_link_xmit_skb(net, skb, dnode, 0);
 		}
 	}
 
@@ -521,8 +522,8 @@ static int tipc_release(struct socket *sock)
 				      tsk_peer_port(tsk),
 				      tsk->portid, TIPC_ERR_NO_PORT);
 		if (skb)
-			tipc_link_xmit_skb(skb, dnode, tsk->portid);
-		tipc_node_remove_conn(dnode, tsk->portid);
+			tipc_link_xmit_skb(net, skb, dnode, tsk->portid);
+		tipc_node_remove_conn(net, dnode, tsk->portid);
 	}
 
 	/* Discard any remaining (connection-based) messages in receive queue */
@@ -725,6 +726,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 			  struct msghdr *msg, size_t dsz, long timeo)
 {
 	struct sock *sk = sock->sk;
+	struct net *net = sock_net(sk);
 	struct tipc_msg *mhdr = &tipc_sk(sk)->phdr;
 	struct sk_buff_head head;
 	uint mtu;
@@ -747,7 +749,7 @@ new_mtu:
 		return rc;
 
 	do {
-		rc = tipc_bclink_xmit(&head);
+		rc = tipc_bclink_xmit(net, &head);
 		if (likely(rc >= 0)) {
 			rc = dsz;
 			break;
@@ -766,7 +768,7 @@ new_mtu:
 
 /* tipc_sk_mcast_rcv - Deliver multicast message to all destination sockets
  */
-void tipc_sk_mcast_rcv(struct sk_buff *buf)
+void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
 	struct tipc_port_list dports = {0, NULL, };
@@ -798,7 +800,7 @@ void tipc_sk_mcast_rcv(struct sk_buff *buf)
 				continue;
 			}
 			msg_set_destport(msg, item->ports[i]);
-			tipc_sk_rcv(b);
+			tipc_sk_rcv(net, b);
 		}
 	}
 	tipc_port_list_free(&dports);
@@ -886,6 +888,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	DECLARE_SOCKADDR(struct sockaddr_tipc *, dest, m->msg_name);
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
+	struct net *net = sock_net(sk);
 	struct tipc_msg *mhdr = &tsk->phdr;
 	u32 dnode, dport;
 	struct sk_buff_head head;
@@ -960,7 +963,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 new_mtu:
-	mtu = tipc_node_get_mtu(dnode, tsk->portid);
+	mtu = tipc_node_get_mtu(net, dnode, tsk->portid);
 	__skb_queue_head_init(&head);
 	rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, &head);
 	if (rc < 0)
@@ -969,7 +972,7 @@ new_mtu:
 	do {
 		skb = skb_peek(&head);
 		TIPC_SKB_CB(skb)->wakeup_pending = tsk->link_cong;
-		rc = tipc_link_xmit(&head, dnode, tsk->portid);
+		rc = tipc_link_xmit(net, &head, dnode, tsk->portid);
 		if (likely(rc >= 0)) {
 			if (sock->state != SS_READY)
 				sock->state = SS_CONNECTING;
@@ -1038,6 +1041,7 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 			    struct msghdr *m, size_t dsz)
 {
 	struct sock *sk = sock->sk;
+	struct net *net = sock_net(sk);
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_msg *mhdr = &tsk->phdr;
 	struct sk_buff_head head;
@@ -1081,7 +1085,7 @@ next:
 		goto exit;
 	do {
 		if (likely(!tsk_conn_cong(tsk))) {
-			rc = tipc_link_xmit(&head, dnode, portid);
+			rc = tipc_link_xmit(net, &head, dnode, portid);
 			if (likely(!rc)) {
 				tsk->sent_unacked++;
 				sent += send;
@@ -1090,7 +1094,8 @@ next:
 				goto next;
 			}
 			if (rc == -EMSGSIZE) {
-				tsk->max_pkt = tipc_node_get_mtu(dnode, portid);
+				tsk->max_pkt = tipc_node_get_mtu(net, dnode,
+								 portid);
 				goto next;
 			}
 			if (rc != -ELINKCONG)
@@ -1132,6 +1137,7 @@ static int tipc_send_packet(struct kiocb *iocb, struct socket *sock,
 static void tipc_sk_finish_conn(struct tipc_sock *tsk, u32 peer_port,
 				u32 peer_node)
 {
+	struct net *net = sock_net(&tsk->sk);
 	struct tipc_msg *msg = &tsk->phdr;
 
 	msg_set_destnode(msg, peer_node);
@@ -1145,8 +1151,8 @@ static void tipc_sk_finish_conn(struct tipc_sock *tsk, u32 peer_port,
 	tsk->connected = 1;
 	if (!mod_timer(&tsk->timer, jiffies + tsk->probing_intv))
 		sock_hold(&tsk->sk);
-	tipc_node_add_conn(peer_node, tsk->portid, peer_port);
-	tsk->max_pkt = tipc_node_get_mtu(peer_node, tsk->portid);
+	tipc_node_add_conn(net, peer_node, tsk->portid, peer_port);
+	tsk->max_pkt = tipc_node_get_mtu(net, peer_node, tsk->portid);
 }
 
 /**
@@ -1245,6 +1251,7 @@ static int tipc_sk_anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 
 static void tipc_sk_send_ack(struct tipc_sock *tsk, uint ack)
 {
+	struct net *net = sock_net(&tsk->sk);
 	struct sk_buff *skb = NULL;
 	struct tipc_msg *msg;
 	u32 peer_port = tsk_peer_port(tsk);
@@ -1258,7 +1265,7 @@ static void tipc_sk_send_ack(struct tipc_sock *tsk, uint ack)
 		return;
 	msg = buf_msg(skb);
 	msg_set_msgcnt(msg, ack);
-	tipc_link_xmit_skb(skb, dnode, msg_link_selector(msg));
+	tipc_link_xmit_skb(net, skb, dnode, msg_link_selector(msg));
 }
 
 static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
@@ -1551,6 +1558,7 @@ static void tipc_data_ready(struct sock *sk)
 static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 {
 	struct sock *sk = &tsk->sk;
+	struct net *net = sock_net(sk);
 	struct socket *sock = sk->sk_socket;
 	struct tipc_msg *msg = buf_msg(*buf);
 	int retval = -TIPC_ERR_NO_PORT;
@@ -1566,7 +1574,7 @@ static int filter_connect(struct tipc_sock *tsk, struct sk_buff **buf)
 				sock->state = SS_DISCONNECTING;
 				tsk->connected = 0;
 				/* let timer expire on it's own */
-				tipc_node_remove_conn(tsk_peer_node(tsk),
+				tipc_node_remove_conn(net, tsk_peer_node(tsk),
 						      tsk->portid);
 			}
 			retval = TIPC_OK;
@@ -1737,7 +1745,7 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 	if ((rc < 0) && !tipc_msg_reverse(skb, &onode, -rc))
 		return 0;
 
-	tipc_link_xmit_skb(skb, onode, 0);
+	tipc_link_xmit_skb(sock_net(sk), skb, onode, 0);
 
 	return 0;
 }
@@ -1748,7 +1756,7 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
  * Consumes buffer
  * Returns 0 if success, or errno: -EHOSTUNREACH
  */
-int tipc_sk_rcv(struct sk_buff *skb)
+int tipc_sk_rcv(struct net *net, struct sk_buff *skb)
 {
 	struct tipc_sock *tsk;
 	struct sock *sk;
@@ -1785,7 +1793,7 @@ exit:
 	if ((rc < 0) && !tipc_msg_reverse(skb, &dnode, -rc))
 		return -EHOSTUNREACH;
 
-	tipc_link_xmit_skb(skb, dnode, 0);
+	tipc_link_xmit_skb(net, skb, dnode, 0);
 	return (rc < 0) ? -EHOSTUNREACH : 0;
 }
 
@@ -2042,6 +2050,7 @@ exit:
 static int tipc_shutdown(struct socket *sock, int how)
 {
 	struct sock *sk = sock->sk;
+	struct net *net = sock_net(sk);
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct sk_buff *skb;
 	u32 dnode;
@@ -2065,8 +2074,9 @@ restart:
 				goto restart;
 			}
 			if (tipc_msg_reverse(skb, &dnode, TIPC_CONN_SHUTDOWN))
-				tipc_link_xmit_skb(skb, dnode, tsk->portid);
-			tipc_node_remove_conn(dnode, tsk->portid);
+				tipc_link_xmit_skb(net, skb, dnode,
+						   tsk->portid);
+			tipc_node_remove_conn(net, dnode, tsk->portid);
 		} else {
 			dnode = tsk_peer_node(tsk);
 			skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
@@ -2074,11 +2084,11 @@ restart:
 					      0, dnode, tipc_own_addr,
 					      tsk_peer_port(tsk),
 					      tsk->portid, TIPC_CONN_SHUTDOWN);
-			tipc_link_xmit_skb(skb, dnode, tsk->portid);
+			tipc_link_xmit_skb(net, skb, dnode, tsk->portid);
 		}
 		tsk->connected = 0;
 		sock->state = SS_DISCONNECTING;
-		tipc_node_remove_conn(dnode, tsk->portid);
+		tipc_node_remove_conn(net, dnode, tsk->portid);
 		/* fall through */
 
 	case SS_DISCONNECTING:
@@ -2130,7 +2140,7 @@ static void tipc_sk_timeout(unsigned long data)
 	}
 	bh_unlock_sock(sk);
 	if (skb)
-		tipc_link_xmit_skb(skb, peer_node, tsk->portid);
+		tipc_link_xmit_skb(sock_net(sk), skb, peer_node, tsk->portid);
 exit:
 	sock_put(sk);
 }
@@ -2138,6 +2148,7 @@ exit:
 static int tipc_sk_publish(struct tipc_sock *tsk, uint scope,
 			   struct tipc_name_seq const *seq)
 {
+	struct net *net = sock_net(&tsk->sk);
 	struct publication *publ;
 	u32 key;
 
@@ -2147,7 +2158,7 @@ static int tipc_sk_publish(struct tipc_sock *tsk, uint scope,
 	if (key == tsk->portid)
 		return -EADDRINUSE;
 
-	publ = tipc_nametbl_publish(seq->type, seq->lower, seq->upper,
+	publ = tipc_nametbl_publish(net, seq->type, seq->lower, seq->upper,
 				    scope, tsk->portid, key);
 	if (unlikely(!publ))
 		return -EINVAL;
@@ -2161,6 +2172,7 @@ static int tipc_sk_publish(struct tipc_sock *tsk, uint scope,
 static int tipc_sk_withdraw(struct tipc_sock *tsk, uint scope,
 			    struct tipc_name_seq const *seq)
 {
+	struct net *net = sock_net(&tsk->sk);
 	struct publication *publ;
 	struct publication *safe;
 	int rc = -EINVAL;
@@ -2175,12 +2187,12 @@ static int tipc_sk_withdraw(struct tipc_sock *tsk, uint scope,
 				continue;
 			if (publ->upper != seq->upper)
 				break;
-			tipc_nametbl_withdraw(publ->type, publ->lower,
+			tipc_nametbl_withdraw(net, publ->type, publ->lower,
 					      publ->ref, publ->key);
 			rc = 0;
 			break;
 		}
-		tipc_nametbl_withdraw(publ->type, publ->lower,
+		tipc_nametbl_withdraw(net, publ->type, publ->lower,
 				      publ->ref, publ->key);
 		rc = 0;
 	}
@@ -2492,8 +2504,9 @@ static int tipc_getsockopt(struct socket *sock, int lvl, int opt,
 	return put_user(sizeof(value), ol);
 }
 
-static int tipc_ioctl(struct socket *sk, unsigned int cmd, unsigned long arg)
+static int tipc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
+	struct sock *sk = sock->sk;
 	struct tipc_sioc_ln_req lnr;
 	void __user *argp = (void __user *)arg;
 
@@ -2501,7 +2514,8 @@ static int tipc_ioctl(struct socket *sk, unsigned int cmd, unsigned long arg)
 	case SIOCGETLINKNAME:
 		if (copy_from_user(&lnr, argp, sizeof(lnr)))
 			return -EFAULT;
-		if (!tipc_node_get_linkname(lnr.bearer_id & 0xffff, lnr.peer,
+		if (!tipc_node_get_linkname(sock_net(sk),
+					    lnr.bearer_id & 0xffff, lnr.peer,
 					    lnr.linkname, TIPC_MAX_LINK_NAME)) {
 			if (copy_to_user(argp, &lnr, sizeof(lnr)))
 				return -EFAULT;
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index 46bc370..eb15c31 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -49,9 +49,9 @@ int tipc_sock_create_local(int type, struct socket **res);
 void tipc_sock_release_local(struct socket *sock);
 int tipc_sock_accept_local(struct socket *sock, struct socket **newsock,
 			   int flags);
-int tipc_sk_rcv(struct sk_buff *buf);
+int tipc_sk_rcv(struct net *net, struct sk_buff *buf);
 struct sk_buff *tipc_sk_socks_show(void);
-void tipc_sk_mcast_rcv(struct sk_buff *buf);
+void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *buf);
 void tipc_sk_reinit(void);
 int tipc_sk_rht_init(void);
 void tipc_sk_rht_destroy(void);
-- 
1.7.9.5
