From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/15] tipc: Ensure broadcast link re-acquires node after link failure
Date: Mon,  6 Feb 2012 19:52:37 -0500
Message-ID: <1328575968-20643-5-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50168 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab2BGAxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:10 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Fix a bug that can prevent TIPC from sending broadcast messages to a node
if contact with the node is lost and then regained. The problem occurs if
the broadcast link first clears the flag indicating the node is part of the
link's distribution set (when it loses contact with the node), and later
fails to restore the flag (when contact is regained); restoration fails
if contact with the node is regained by implicit unicast link activation
triggered by the arrival of a data message, rather than explicitly by the
arrival of a link activation message.

The broadcast link now uses separate fields to track whether a node is
theoretically capable of receiving broadcast messages versus whether it is
actually part of the link's distribution set. The former member is updated
by the receipt of link protocol messages, which can occur at any time; the
latter member is updated only when contact with the node is gained or lost.
This change also permits the simplification of several conditional
expressions since the broadcast link's "supported" field can now only be
set if there are working links to the associated node.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    5 +++--
 net/tipc/node.c |    3 ++-
 net/tipc/node.h |    4 +++-
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 4ea6cad..3405f56 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1502,6 +1502,7 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
 		info("Multicast link info for %s\n", addr_string);
+		info("Supportable: %d,  ", n_ptr->bclink.supportable);
 		info("Supported: %d,  ", n_ptr->bclink.supported);
 		info("Acked: %u\n", n_ptr->bclink.acked);
 		info("Last in: %u,  ", n_ptr->bclink.last_in);
@@ -1736,7 +1737,7 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 
 		/* Release acked messages */
 
-		if (tipc_node_is_up(n_ptr) && n_ptr->bclink.supported)
+		if (n_ptr->bclink.supported)
 			tipc_bclink_acknowledge(n_ptr, msg_bcast_ack(msg));
 
 		crs = l_ptr->first_out;
@@ -2126,7 +2127,7 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 		} else {
 			l_ptr->max_pkt = l_ptr->max_pkt_target;
 		}
-		l_ptr->owner->bclink.supported = (max_pkt_info != 0);
+		l_ptr->owner->bclink.supportable = (max_pkt_info != 0);
 
 		/* Synchronize broadcast link info, if not done previously */
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 6b226fa..9196f94 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -306,8 +306,9 @@ static void node_established_contact(struct tipc_node *n_ptr)
 	/* Syncronize broadcast acks */
 	n_ptr->bclink.acked = tipc_bclink_get_last_sent();
 
-	if (n_ptr->bclink.supported) {
+	if (n_ptr->bclink.supportable) {
 		tipc_bclink_add_node(n_ptr->addr);
+		n_ptr->bclink.supported = 1;
 		if (n_ptr->addr < tipc_own_addr)
 			tipc_own_tag++;
 	}
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 0b1c5f8..90689f4 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -62,6 +62,7 @@
  * @link_cnt: number of links to node
  * @permit_changeover: non-zero if node has redundant links to this system
  * @bclink: broadcast-related info
+ *    @supportable: non-zero if node supports TIPC b'cast link capability
  *    @supported: non-zero if node supports TIPC b'cast capability
  *    @acked: sequence # of last outbound b'cast message acknowledged by node
  *    @last_in: sequence # of last in-sequence b'cast message received from node
@@ -86,7 +87,8 @@ struct tipc_node {
 	int block_setup;
 	int permit_changeover;
 	struct {
-		int supported;
+		u8 supportable;
+		u8 supported;
 		u32 acked;
 		u32 last_in;
 		u32 gap_after;
-- 
1.7.9
