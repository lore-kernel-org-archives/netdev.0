From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/15] tipc: Prevent transmission of outdated link protocol messages
Date: Mon,  6 Feb 2012 19:52:35 -0500
Message-ID: <1328575968-20643-3-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50167 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023Ab2BGAxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:10 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Ensures that a link endpoint discards any previously deferred link
protocol message whenever it attempts to send a new one.

Previously, it was possible for a link protocol message that was unsent
due to congestion to be transmitted after newer protocol messages had
been sent. The stale link protocol message might then cause the receiving
link endpoint to malfunction because of its outdated conent.

Thanks to Osamu Kaminuma [okaminum@avaya.com] for diagnosing the problem
and contributing a prototype patch.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |   53 +++++++++++++++++++++++++++--------------------------
 1 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index c317abf..bee316c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1954,6 +1954,13 @@ void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ,
 	u32 msg_size = sizeof(l_ptr->proto_msg);
 	int r_flag;
 
+	/* Discard any previous message that was deferred due to congestion */
+
+	if (l_ptr->proto_msg_queue) {
+		buf_discard(l_ptr->proto_msg_queue);
+		l_ptr->proto_msg_queue = NULL;
+	}
+
 	if (link_blocked(l_ptr))
 		return;
 
@@ -1962,6 +1969,8 @@ void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ,
 	if ((l_ptr->owner->block_setup) && (msg_typ != RESET_MSG))
 		return;
 
+	/* Create protocol message with "out-of-sequence" sequence number */
+
 	msg_set_type(msg, msg_typ);
 	msg_set_net_plane(msg, l_ptr->b_ptr->net_plane);
 	msg_set_bcast_ack(msg, mod(l_ptr->owner->bclink.last_in));
@@ -2018,44 +2027,36 @@ void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ,
 	r_flag = (l_ptr->owner->working_links > tipc_link_is_up(l_ptr));
 	msg_set_redundant_link(msg, r_flag);
 	msg_set_linkprio(msg, l_ptr->priority);
-
-	/* Ensure sequence number will not fit : */
+	msg_set_size(msg, msg_size);
 
 	msg_set_seqno(msg, mod(l_ptr->next_out_no + (0xffff/2)));
 
-	/* Congestion? */
-
-	if (tipc_bearer_congested(l_ptr->b_ptr, l_ptr)) {
-		if (!l_ptr->proto_msg_queue) {
-			l_ptr->proto_msg_queue =
-				tipc_buf_acquire(sizeof(l_ptr->proto_msg));
-		}
-		buf = l_ptr->proto_msg_queue;
-		if (!buf)
-			return;
-		skb_copy_to_linear_data(buf, msg, sizeof(l_ptr->proto_msg));
-		return;
-	}
-
-	/* Message can be sent */
-
 	buf = tipc_buf_acquire(msg_size);
 	if (!buf)
 		return;
 
 	skb_copy_to_linear_data(buf, msg, sizeof(l_ptr->proto_msg));
-	msg_set_size(buf_msg(buf), msg_size);
 
-	if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
-		l_ptr->unacked_window = 0;
-		buf_discard(buf);
+	/* Defer message if bearer is already congested */
+
+	if (tipc_bearer_congested(l_ptr->b_ptr, l_ptr)) {
+		l_ptr->proto_msg_queue = buf;
+		return;
+	}
+
+	/* Defer message if attempting to send results in bearer congestion */
+
+	if (!tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
+		tipc_bearer_schedule(l_ptr->b_ptr, l_ptr);
+		l_ptr->proto_msg_queue = buf;
+		l_ptr->stats.bearer_congs++;
 		return;
 	}
 
-	/* New congestion */
-	tipc_bearer_schedule(l_ptr->b_ptr, l_ptr);
-	l_ptr->proto_msg_queue = buf;
-	l_ptr->stats.bearer_congs++;
+	/* Discard message if it was sent successfully */
+
+	l_ptr->unacked_window = 0;
+	buf_discard(buf);
 }
 
 /*
-- 
1.7.9
