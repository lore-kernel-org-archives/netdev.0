From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net] tipc: fix a potential deadlock
Date: Mon, 20 Oct 2014 14:44:25 +0800
Message-ID: <1413787465-14600-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60973 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbaJTGon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 02:44:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Locking dependency detected below possible unsafe locking scenario:

           CPU0                          CPU1
T0:  tipc_named_rcv()                tipc_rcv()
T1:  [grab nametble write lock]*     [grab node lock]*
T2:  tipc_update_nametbl()           tipc_node_link_up()
T3:  tipc_nodesub_subscribe()        tipc_nametbl_publish()
T4:  [grab node lock]*               [grab nametble write lock]*

The opposite order of holding nametbl write lock and node lock on
above two different paths may result in a deadlock. If we move the
the updating of the name table after link state named out of node
lock, the reverse order of holding locks will be eliminated, and
as a result, the deadlock risk.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c   |   46 ++++++++++++++++++++++++++++------------------
 net/tipc/node.h   |    7 ++++++-
 net/tipc/socket.c |    2 +-
 3 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 90cee4a..5781634 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -219,11 +219,11 @@ void tipc_node_abort_sock_conns(struct list_head *conns)
 void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
 	struct tipc_link **active = &n_ptr->active_links[0];
-	u32 addr = n_ptr->addr;
 
 	n_ptr->working_links++;
-	tipc_nametbl_publish(TIPC_LINK_STATE, addr, addr, TIPC_NODE_SCOPE,
-			     l_ptr->bearer_id, addr);
+	n_ptr->action_flags |= TIPC_NOTIFY_LINK_UP;
+	n_ptr->link_id = l_ptr->peer_bearer_id << 16 | l_ptr->bearer_id;
+
 	pr_info("Established link <%s> on network plane %c\n",
 		l_ptr->name, l_ptr->net_plane);
 
@@ -284,10 +284,10 @@ static void node_select_active_links(struct tipc_node *n_ptr)
 void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
 	struct tipc_link **active;
-	u32 addr = n_ptr->addr;
 
 	n_ptr->working_links--;
-	tipc_nametbl_withdraw(TIPC_LINK_STATE, addr, l_ptr->bearer_id, addr);
+	n_ptr->action_flags |= TIPC_NOTIFY_LINK_DOWN;
+	n_ptr->link_id = l_ptr->peer_bearer_id << 16 | l_ptr->bearer_id;
 
 	if (!tipc_link_is_active(l_ptr)) {
 		pr_info("Lost standby link <%s> on network plane %c\n",
@@ -552,28 +552,30 @@ void tipc_node_unlock(struct tipc_node *node)
 	LIST_HEAD(conn_sks);
 	struct sk_buff_head waiting_sks;
 	u32 addr = 0;
-	unsigned int flags = node->action_flags;
+	int flags = node->action_flags;
+	u32 link_id = 0;
 
-	if (likely(!node->action_flags)) {
+	if (likely(!flags)) {
 		spin_unlock_bh(&node->lock);
 		return;
 	}
 
+	addr = node->addr;
+	link_id = node->link_id;
 	__skb_queue_head_init(&waiting_sks);
-	if (node->action_flags & TIPC_WAKEUP_USERS) {
+
+	if (flags & TIPC_WAKEUP_USERS)
 		skb_queue_splice_init(&node->waiting_sks, &waiting_sks);
-		node->action_flags &= ~TIPC_WAKEUP_USERS;
-	}
-	if (node->action_flags & TIPC_NOTIFY_NODE_DOWN) {
+
+	if (flags & TIPC_NOTIFY_NODE_DOWN) {
 		list_replace_init(&node->nsub, &nsub_list);
 		list_replace_init(&node->conn_sks, &conn_sks);
-		node->action_flags &= ~TIPC_NOTIFY_NODE_DOWN;
 	}
-	if (node->action_flags & TIPC_NOTIFY_NODE_UP) {
-		node->action_flags &= ~TIPC_NOTIFY_NODE_UP;
-		addr = node->addr;
-	}
-	node->action_flags &= ~TIPC_WAKEUP_BCAST_USERS;
+	node->action_flags &= ~(TIPC_WAKEUP_USERS | TIPC_NOTIFY_NODE_DOWN |
+				TIPC_NOTIFY_NODE_UP | TIPC_NOTIFY_LINK_UP |
+				TIPC_NOTIFY_LINK_DOWN |
+				TIPC_WAKEUP_BCAST_USERS);
+
 	spin_unlock_bh(&node->lock);
 
 	while (!skb_queue_empty(&waiting_sks))
@@ -588,6 +590,14 @@ void tipc_node_unlock(struct tipc_node *node)
 	if (flags & TIPC_WAKEUP_BCAST_USERS)
 		tipc_bclink_wakeup_users();
 
-	if (addr)
+	if (flags & TIPC_NOTIFY_NODE_UP)
 		tipc_named_node_up(addr);
+
+	if (flags & TIPC_NOTIFY_LINK_UP)
+		tipc_nametbl_publish(TIPC_LINK_STATE, addr, addr,
+				     TIPC_NODE_SCOPE, link_id, addr);
+
+	if (flags & TIPC_NOTIFY_LINK_DOWN)
+		tipc_nametbl_withdraw(TIPC_LINK_STATE, addr,
+				      link_id, addr);
 }
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 67513c3..04e9145 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -53,6 +53,7 @@
  * TIPC_WAIT_OWN_LINKS_DOWN: wait until peer node is declared down
  * TIPC_NOTIFY_NODE_DOWN: notify node is down
  * TIPC_NOTIFY_NODE_UP: notify node is up
+ * TIPC_DISTRIBUTE_NAME: publish or withdraw link state name type
  */
 enum {
 	TIPC_WAIT_PEER_LINKS_DOWN	= (1 << 1),
@@ -60,7 +61,9 @@ enum {
 	TIPC_NOTIFY_NODE_DOWN		= (1 << 3),
 	TIPC_NOTIFY_NODE_UP		= (1 << 4),
 	TIPC_WAKEUP_USERS		= (1 << 5),
-	TIPC_WAKEUP_BCAST_USERS		= (1 << 6)
+	TIPC_WAKEUP_BCAST_USERS		= (1 << 6),
+	TIPC_NOTIFY_LINK_UP		= (1 << 7),
+	TIPC_NOTIFY_LINK_DOWN		= (1 << 8)
 };
 
 /**
@@ -100,6 +103,7 @@ struct tipc_node_bclink {
  * @working_links: number of working links to node (both active and standby)
  * @link_cnt: number of links to node
  * @signature: node instance identifier
+ * @link_id: local and remote bearer ids of changing link, if any
  * @nsub: list of "node down" subscriptions monitoring node
  * @rcu: rcu struct for tipc_node
  */
@@ -116,6 +120,7 @@ struct tipc_node {
 	int link_cnt;
 	int working_links;
 	u32 signature;
+	u32 link_id;
 	struct list_head nsub;
 	struct sk_buff_head waiting_sks;
 	struct list_head conn_sks;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 75275c5..3043f10 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2673,7 +2673,7 @@ static int tipc_ioctl(struct socket *sk, unsigned int cmd, unsigned long arg)
 	case SIOCGETLINKNAME:
 		if (copy_from_user(&lnr, argp, sizeof(lnr)))
 			return -EFAULT;
-		if (!tipc_node_get_linkname(lnr.bearer_id, lnr.peer,
+		if (!tipc_node_get_linkname(lnr.bearer_id & 0xffff, lnr.peer,
 					    lnr.linkname, TIPC_MAX_LINK_NAME)) {
 			if (copy_to_user(argp, &lnr, sizeof(lnr)))
 				return -EFAULT;
-- 
1.7.9.5
