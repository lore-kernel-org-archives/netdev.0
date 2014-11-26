From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 03/11] tipc: remove
	retransmission queue
Date: Wed, 26 Nov 2014 11:41:47 +0800
Message-ID: <1416973315-6047-4-git-send-email-ying.xue@windriver.com>
References: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

TIPC retransmission queue is intended to record which messages
should be retransmitted when bearer is not congested. However,
as the retransmission queue becomes useless with the removal of
bearer congestion mechanism, it should be removed.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |   35 +----------------------------------
 net/tipc/link.h |    4 ----
 2 files changed, 1 insertion(+), 38 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 450ed0c..4b7cbfd 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -458,8 +458,6 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 		skb_queue_splice_init(&l_ptr->waiting_sks, &owner->waiting_sks);
 		owner->action_flags |= TIPC_WAKEUP_USERS;
 	}
-	l_ptr->retransm_queue_head = 0;
-	l_ptr->retransm_queue_size = 0;
 	l_ptr->last_out = NULL;
 	l_ptr->first_out = NULL;
 	l_ptr->next_out = NULL;
@@ -870,38 +868,9 @@ static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf)
  */
 static u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 {
-	struct sk_buff *buf = l_ptr->first_out;
-	u32 r_q_size = l_ptr->retransm_queue_size;
-	u32 r_q_head = l_ptr->retransm_queue_head;
-
-	/* Step to position where retransmission failed, if any,    */
-	/* consider that buffers may have been released in meantime */
-	if (r_q_size && buf) {
-		u32 last = lesser(mod(r_q_head + r_q_size),
-				  link_last_sent(l_ptr));
-		u32 first = buf_seqno(buf);
-
-		while (buf && less(first, r_q_head)) {
-			first = mod(first + 1);
-			buf = buf->next;
-		}
-		l_ptr->retransm_queue_head = r_q_head = first;
-		l_ptr->retransm_queue_size = r_q_size = mod(last - first);
-	}
-
-	/* Continue retransmission now, if there is anything: */
-	if (r_q_size && buf) {
-		msg_set_ack(buf_msg(buf), mod(l_ptr->next_in_no - 1));
-		msg_set_bcast_ack(buf_msg(buf), l_ptr->owner->bclink.last_in);
-		tipc_bearer_send(l_ptr->bearer_id, buf, &l_ptr->media_addr);
-		l_ptr->retransm_queue_head = mod(++r_q_head);
-		l_ptr->retransm_queue_size = --r_q_size;
-		l_ptr->stats.retransmitted++;
-		return 0;
-	}
+	struct sk_buff *buf = l_ptr->next_out;
 
 	/* Send one deferred data message, if send window not full: */
-	buf = l_ptr->next_out;
 	if (buf) {
 		struct tipc_msg *msg = buf_msg(buf);
 		u32 next = msg_seqno(msg);
@@ -1025,8 +994,6 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *buf,
 		retransmits--;
 		l_ptr->stats.retransmitted++;
 	}
-
-	l_ptr->retransm_queue_head = l_ptr->retransm_queue_size = 0;
 }
 
 /**
diff --git a/net/tipc/link.h b/net/tipc/link.h
index fb3f99b..cc816aa 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -130,8 +130,6 @@ struct tipc_stats {
  * @oldest_deferred_in: ptr to first inbound message in queue
  * @newest_deferred_in: ptr to last inbound message in queue
  * @unacked_window: # of inbound messages rx'd without ack'ing back to peer
- * @retransm_queue_size: number of messages to retransmit
- * @retransm_queue_head: sequence number of first message to retransmit
  * @next_out: ptr to first unsent outbound message in queue
  * @waiting_sks: linked list of sockets waiting for link congestion to abate
  * @long_msg_seq_no: next identifier to use for outbound fragmented messages
@@ -190,8 +188,6 @@ struct tipc_link {
 	u32 unacked_window;
 
 	/* Congestion handling */
-	u32 retransm_queue_size;
-	u32 retransm_queue_head;
 	struct sk_buff *next_out;
 	struct sk_buff_head waiting_sks;
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
