From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 02/11] tipc: remove protocol message queue
Date: Wed, 26 Nov 2014 11:41:46 +0800
Message-ID: <1416973315-6047-3-git-send-email-ying.xue@windriver.com>
References: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <richard.alpe@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:43985 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbaKZDmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 22:42:18 -0500
In-Reply-To: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TIPC protocol message queue is intended to save one protocol message
when bearer is congested so that the message stored in the queue can
be immediately transmitted when bearer congestion is released. However,
as now the protocol queue has no mission any more with the removal of
bearer congestion mechanism, it should be removed.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |   22 ----------------------
 net/tipc/link.h |    2 --
 2 files changed, 24 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 4738cb1..450ed0c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -421,8 +421,6 @@ void tipc_link_purge_queues(struct tipc_link *l_ptr)
 	kfree_skb_list(l_ptr->oldest_deferred_in);
 	kfree_skb_list(l_ptr->first_out);
 	tipc_link_reset_fragments(l_ptr);
-	kfree_skb(l_ptr->proto_msg_queue);
-	l_ptr->proto_msg_queue = NULL;
 }
 
 void tipc_link_reset(struct tipc_link *l_ptr)
@@ -455,8 +453,6 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 
 	/* Clean up all queues: */
 	link_release_outqueue(l_ptr);
-	kfree_skb(l_ptr->proto_msg_queue);
-	l_ptr->proto_msg_queue = NULL;
 	kfree_skb_list(l_ptr->oldest_deferred_in);
 	if (!skb_queue_empty(&l_ptr->waiting_sks)) {
 		skb_queue_splice_init(&l_ptr->waiting_sks, &owner->waiting_sks);
@@ -904,18 +900,6 @@ static u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 		return 0;
 	}
 
-	/* Send deferred protocol message, if any: */
-	buf = l_ptr->proto_msg_queue;
-	if (buf) {
-		msg_set_ack(buf_msg(buf), mod(l_ptr->next_in_no - 1));
-		msg_set_bcast_ack(buf_msg(buf), l_ptr->owner->bclink.last_in);
-		tipc_bearer_send(l_ptr->bearer_id, buf, &l_ptr->media_addr);
-		l_ptr->unacked_window = 0;
-		kfree_skb(buf);
-		l_ptr->proto_msg_queue = NULL;
-		return 0;
-	}
-
 	/* Send one deferred data message, if send window not full: */
 	buf = l_ptr->next_out;
 	if (buf) {
@@ -1446,12 +1430,6 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 	u32 msg_size = sizeof(l_ptr->proto_msg);
 	int r_flag;
 
-	/* Discard any previous message that was deferred due to congestion */
-	if (l_ptr->proto_msg_queue) {
-		kfree_skb(l_ptr->proto_msg_queue);
-		l_ptr->proto_msg_queue = NULL;
-	}
-
 	/* Don't send protocol message during link changeover */
 	if (l_ptr->exp_msg_count)
 		return;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index f463e7b..fb3f99b 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -130,7 +130,6 @@ struct tipc_stats {
  * @oldest_deferred_in: ptr to first inbound message in queue
  * @newest_deferred_in: ptr to last inbound message in queue
  * @unacked_window: # of inbound messages rx'd without ack'ing back to peer
- * @proto_msg_queue: ptr to (single) outbound control message
  * @retransm_queue_size: number of messages to retransmit
  * @retransm_queue_head: sequence number of first message to retransmit
  * @next_out: ptr to first unsent outbound message in queue
@@ -191,7 +190,6 @@ struct tipc_link {
 	u32 unacked_window;
 
 	/* Congestion handling */
-	struct sk_buff *proto_msg_queue;
 	u32 retransm_queue_size;
 	u32 retransm_queue_head;
 	struct sk_buff *next_out;
-- 
1.7.9.5
