From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 30/32] [TIPC] Fixed link switchover bugs
Date: Thu, 22 Jun 2006 15:59:43 +0200
Message-ID: <1150984787672-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:59834 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030635AbWFVN7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:54 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Incorporates several related fixes:
- switchover now occurs when switching from an active link to a standby link
- failure of a standby link no longer initiates switchover
- links now display correct # of received packtes following reactivation

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/link.c |   30 ++++++++++++++++++++++++------
 net/tipc/node.c |    7 +++++--
 net/tipc/node.h |    2 ++
 3 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index d7668b8..d646580 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -690,6 +690,7 @@ void tipc_link_reset(struct link *l_ptr)
 	struct sk_buff *buf;
 	u32 prev_state = l_ptr->state;
 	u32 checkpoint = l_ptr->next_in_no;
+	int was_active_link = tipc_link_is_active(l_ptr);
 	
 	msg_set_session(l_ptr->pmsg, msg_session(l_ptr->pmsg) + 1);
 
@@ -711,7 +712,7 @@ #if 0
 	tipc_printf(TIPC_CONS, "\nReset link <%s>\n", l_ptr->name);
 	dbg_link_dump();
 #endif
-	if (tipc_node_has_active_links(l_ptr->owner) &&
+	if (was_active_link && tipc_node_has_active_links(l_ptr->owner) &&
 	    l_ptr->owner->permit_changeover) {
 		l_ptr->reset_checkpoint = checkpoint;
 		l_ptr->exp_msg_count = START_CHANGEOVER;
@@ -754,7 +755,7 @@ #endif
 
 static void link_activate(struct link *l_ptr)
 {
-	l_ptr->next_in_no = 1;
+	l_ptr->next_in_no = l_ptr->stats.recv_info = 1;
 	tipc_node_link_up(l_ptr->owner, l_ptr);
 	tipc_bearer_add_dest(l_ptr->b_ptr, l_ptr->addr);
 	link_send_event(tipc_cfg_link_event, l_ptr, 1);
@@ -2303,12 +2304,18 @@ void tipc_link_tunnel(struct link *l_ptr
 	u32 length = msg_size(msg);
 
 	tunnel = l_ptr->owner->active_links[selector & 1];
-	if (!tipc_link_is_up(tunnel))
+	if (!tipc_link_is_up(tunnel)) {
+		warn("Link changeover error, "
+		     "tunnel link no longer available\n");
 		return;
+	}
 	msg_set_size(tunnel_hdr, length + INT_H_SIZE);
 	buf = buf_acquire(length + INT_H_SIZE);
-	if (!buf)
+	if (!buf) {
+		warn("Link changeover error, "
+		     "unable to send tunnel msg\n");
 		return;
+	}
 	memcpy(buf->data, (unchar *)tunnel_hdr, INT_H_SIZE);
 	memcpy(buf->data + INT_H_SIZE, (unchar *)msg, length);
 	dbg("%c->%c:", l_ptr->b_ptr->net_plane, tunnel->b_ptr->net_plane);
@@ -2328,19 +2335,23 @@ void tipc_link_changeover(struct link *l
 	u32 msgcount = l_ptr->out_queue_size;
 	struct sk_buff *crs = l_ptr->first_out;
 	struct link *tunnel = l_ptr->owner->active_links[0];
-	int split_bundles = tipc_node_has_redundant_links(l_ptr->owner);
 	struct tipc_msg tunnel_hdr;
+	int split_bundles;
 
 	if (!tunnel)
 		return;
 
-	if (!l_ptr->owner->permit_changeover)
+	if (!l_ptr->owner->permit_changeover) {
+		warn("Link changeover error, "
+		     "peer did not permit changeover\n");
 		return;
+	}
 
 	msg_init(&tunnel_hdr, CHANGEOVER_PROTOCOL,
 		 ORIGINAL_MSG, TIPC_OK, INT_H_SIZE, l_ptr->addr);
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
 	msg_set_msgcnt(&tunnel_hdr, msgcount);
+	dbg("Link changeover requires %u tunnel messages\n", msgcount);
 
 	if (!l_ptr->first_out) {
 		struct sk_buff *buf;
@@ -2360,6 +2371,9 @@ void tipc_link_changeover(struct link *l
 		return;
 	}
 
+	split_bundles = (l_ptr->owner->active_links[0] != 
+			 l_ptr->owner->active_links[1]);
+
 	while (crs) {
 		struct tipc_msg *msg = buf_msg(crs);
 
@@ -2497,11 +2511,13 @@ static int link_recv_changeover_msg(stru
 		     dest_link->name);
 		tipc_link_reset(dest_link);
 		dest_link->exp_msg_count = msg_count;
+		dbg("Expecting %u tunnelled messages\n", msg_count);
 		if (!msg_count)
 			goto exit;
 	} else if (dest_link->exp_msg_count == START_CHANGEOVER) {
 		msg_dbg(tunnel_msg, "BLK/FIRST/<REC<");
 		dest_link->exp_msg_count = msg_count;
+		dbg("Expecting %u tunnelled messages\n", msg_count);
 		if (!msg_count)
 			goto exit;
 	}
@@ -2509,6 +2525,8 @@ static int link_recv_changeover_msg(stru
 	/* Receive original message */
 
 	if (dest_link->exp_msg_count == 0) {
+		warn("Link switchover error, "
+		     "got too many tunnelled messages\n");
 		msg_dbg(tunnel_msg, "OVERDUE/DROP/<REC<");
 		dbg_print_link(dest_link, "LINK:");
 		goto exit;
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 5f09754..ce9678e 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -125,6 +125,8 @@ void tipc_node_link_up(struct node *n_pt
 {
 	struct link **active = &n_ptr->active_links[0];
 
+	n_ptr->working_links++;
+
 	info("Established link <%s> on network plane %c\n",
 	     l_ptr->name, l_ptr->b_ptr->net_plane);
 	
@@ -185,6 +187,8 @@ void tipc_node_link_down(struct node *n_
 {
 	struct link **active;
 
+	n_ptr->working_links--;
+
 	if (!tipc_link_is_active(l_ptr)) {
 		info("Lost standby link <%s> on network plane %c\n",
 		     l_ptr->name, l_ptr->b_ptr->net_plane);
@@ -214,8 +218,7 @@ int tipc_node_has_active_links(struct no
 
 int tipc_node_has_redundant_links(struct node *n_ptr)
 {
-	return (tipc_node_has_active_links(n_ptr) &&
-		(n_ptr->active_links[0] != n_ptr->active_links[1]));
+	return (n_ptr->working_links > 1);
 }
 
 static int tipc_node_has_active_routes(struct node *n_ptr)
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 781126e..a07cc79 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -51,6 +51,7 @@ #include "bearer.h"
  * @nsub: list of "node down" subscriptions monitoring node
  * @active_links: pointers to active links to node
  * @links: pointers to all links to node
+ * @working_links: number of working links to node (both active and standby)
  * @link_cnt: number of links to node
  * @permit_changeover: non-zero if node has redundant links to this system
  * @routers: bitmap (used for multicluster communication)
@@ -76,6 +77,7 @@ struct node {
 	struct link *active_links[2];
 	struct link *links[MAX_BEARERS];
 	int link_cnt;
+	int working_links;
 	int permit_changeover;
 	u32 routers[512/32];
 	int last_router;
-- 
1.4.0

