From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/14] tipc: Fix premature broadcast advertisement by sending node
Date: Tue, 17 Aug 2010 17:00:09 -0400
Message-ID: <1282078816-11844-8-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57129 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab0HQVAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:25 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Prevent a TIPC node from sending out a LINK_STATE message
advertising a broadcast message that it is in the process
of sending, but has not yet actually sent.  Previously, it was
possible for a link timeout to occur in between the time the
broadcast link updated its "last message sent" counter and the
time the broadcast message was passed to the broadcast bearer
for transmission.  This ensures that the code which issues
the LINK_STATE message isn't informed of the new message until
the broadcast bearer has had a chance to send it.

Note: The "last message sent" value is stored in the "fsm_msg_count"
field of the link structure used by the broadcast link.  Since the
broadcast link doesn't utilize the normal link FSM, this field can
be re-used rather than adding a new field to the broadcast link.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   30 +++++++++++++++++++-----------
 1 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 42b1737..eefdd1a 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -143,6 +143,19 @@ static void bcbuf_decr_acks(struct sk_buff *buf)
 }
 
 
+static void bclink_set_last_sent(void)
+{
+	if (bcl->next_out)
+		bcl->fsm_msg_cnt = mod(buf_seqno(bcl->next_out) - 1);
+	else
+		bcl->fsm_msg_cnt = mod(bcl->next_out_no - 1);
+}
+
+u32 tipc_bclink_get_last_sent(void)
+{
+	return bcl->fsm_msg_cnt;
+}
+
 /**
  * bclink_set_gap - set gap according to contents of current deferred pkt queue
  *
@@ -237,8 +250,10 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 
 	/* Try resolving broadcast link congestion, if necessary */
 
-	if (unlikely(bcl->next_out))
+	if (unlikely(bcl->next_out)) {
 		tipc_link_push_queue(bcl);
+		bclink_set_last_sent();
+	}
 	if (unlikely(released && !list_empty(&bcl->waiting_ports)))
 		tipc_link_wakeup_ports(bcl, 0);
 	spin_unlock_bh(&bc_lock);
@@ -394,8 +409,10 @@ int tipc_bclink_send_msg(struct sk_buff *buf)
 	res = tipc_link_send_buf(bcl, buf);
 	if (unlikely(res == -ELINKCONG))
 		buf_discard(buf);
-	else
+	else {
 		bcl->stats.sent_info++;
+		bclink_set_last_sent();
+	}
 
 	if (bcl->out_queue_size > bcl->stats.max_queue_sz)
 		bcl->stats.max_queue_sz = bcl->out_queue_size;
@@ -529,15 +546,6 @@ receive:
 	tipc_node_unlock(node);
 }
 
-u32 tipc_bclink_get_last_sent(void)
-{
-	u32 last_sent = mod(bcl->next_out_no - 1);
-
-	if (bcl->next_out)
-		last_sent = mod(buf_seqno(bcl->next_out) - 1);
-	return last_sent;
-}
-
 u32 tipc_bclink_acks_missing(struct tipc_node *n_ptr)
 {
 	return (n_ptr->bclink.supported &&
-- 
1.7.2.1

