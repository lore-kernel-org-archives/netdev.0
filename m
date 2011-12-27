From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 18/23] tipc: Ensure broadcast link spinlock is held when updating node map
Date: Tue, 27 Dec 2011 12:39:37 -0500
Message-ID: <1325007582-31610-19-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39488 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754827Ab1L0RkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:08 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Fixes oversight that allowed broadcast link node map to be updated without
first taking the broadcast link spinlock that protects the map. As part
of this fix the node map has been incorporated into the broadcast link
structure to make the need for such protection more evident.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   24 ++++++++++++++++++------
 net/tipc/bcast.h |    4 ++--
 net/tipc/node.c  |    4 ++--
 3 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 738cb64..5ca8fdd 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -87,6 +87,7 @@ struct bcbearer {
  * struct bclink - link used for broadcast messages
  * @link: (non-standard) broadcast link structure
  * @node: (non-standard) node structure representing b'cast link's peer node
+ * @bcast_nodes: map of broadcast-capable nodes
  * @retransmit_to: node that most recently requested a retransmit
  *
  * Handles sequence numbering, fragmentation, bundling, etc.
@@ -95,6 +96,7 @@ struct bcbearer {
 struct bclink {
 	struct link link;
 	struct tipc_node node;
+	struct tipc_node_map bcast_nodes;
 	struct tipc_node *retransmit_to;
 };
 
@@ -107,9 +109,6 @@ static struct link *bcl = &bcast_link.link;
 
 static DEFINE_SPINLOCK(bc_lock);
 
-/* broadcast-capable node map */
-struct tipc_node_map tipc_bcast_nmap;
-
 const char tipc_bclink_name[] = "broadcast-link";
 
 static void tipc_nmap_diff(struct tipc_node_map *nm_a,
@@ -136,6 +135,19 @@ static void bcbuf_decr_acks(struct sk_buff *buf)
 	bcbuf_set_acks(buf, bcbuf_acks(buf) - 1);
 }
 
+void tipc_bclink_add_node(u32 addr)
+{
+	spin_lock_bh(&bc_lock);
+	tipc_nmap_add(&bclink->bcast_nodes, addr);
+	spin_unlock_bh(&bc_lock);
+}
+
+void tipc_bclink_remove_node(u32 addr)
+{
+	spin_lock_bh(&bc_lock);
+	tipc_nmap_remove(&bclink->bcast_nodes, addr);
+	spin_unlock_bh(&bc_lock);
+}
 
 static void bclink_set_last_sent(void)
 {
@@ -575,13 +587,13 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 	if (likely(!msg_non_seq(buf_msg(buf)))) {
 		struct tipc_msg *msg;
 
-		bcbuf_set_acks(buf, tipc_bcast_nmap.count);
+		bcbuf_set_acks(buf, bclink->bcast_nodes.count);
 		msg = buf_msg(buf);
 		msg_set_non_seq(msg, 1);
 		msg_set_mc_netid(msg, tipc_net_id);
 		bcl->stats.sent_info++;
 
-		if (WARN_ON(!tipc_bcast_nmap.count)) {
+		if (WARN_ON(!bclink->bcast_nodes.count)) {
 			dump_stack();
 			return 0;
 		}
@@ -589,7 +601,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 
 	/* Send buffer over bearers until all targets reached */
 
-	bcbearer->remains = tipc_bcast_nmap;
+	bcbearer->remains = bclink->bcast_nodes;
 
 	for (bp_index = 0; bp_index < MAX_BEARERS; bp_index++) {
 		struct tipc_bearer *p = bcbearer->bpairs[bp_index].primary;
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 0b04443..3c37fdb 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -51,8 +51,6 @@ struct tipc_node_map {
 	u32 map[MAX_NODES / WSIZE];
 };
 
-extern struct tipc_node_map tipc_bcast_nmap;
-
 #define PLSIZE 32
 
 /**
@@ -90,6 +88,8 @@ void tipc_port_list_free(struct port_list *pl_ptr);
 
 void tipc_bclink_init(void);
 void tipc_bclink_stop(void);
+void tipc_bclink_add_node(u32 addr);
+void tipc_bclink_remove_node(u32 addr);
 struct tipc_node *tipc_bclink_retransmit_to(void);
 void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked);
 int  tipc_bclink_send_msg(struct sk_buff *buf);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 27b4bb0..1861ae9 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -307,7 +307,7 @@ static void node_established_contact(struct tipc_node *n_ptr)
 	n_ptr->bclink.acked = tipc_bclink_get_last_sent();
 
 	if (n_ptr->bclink.supported) {
-		tipc_nmap_add(&tipc_bcast_nmap, n_ptr->addr);
+		tipc_bclink_add_node(n_ptr->addr);
 		if (n_ptr->addr < tipc_own_addr)
 			tipc_own_tag++;
 	}
@@ -350,7 +350,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 			n_ptr->bclink.defragm = NULL;
 		}
 
-		tipc_nmap_remove(&tipc_bcast_nmap, n_ptr->addr);
+		tipc_bclink_remove_node(n_ptr->addr);
 		tipc_bclink_acknowledge(n_ptr,
 					mod(n_ptr->bclink.acked + 10000));
 		if (n_ptr->addr < tipc_own_addr)
-- 
1.7.4.4
