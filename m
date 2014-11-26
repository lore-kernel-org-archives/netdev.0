From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 04/11] tipc: clean up the process
	of link pushing packets
Date: Wed, 26 Nov 2014 11:41:48 +0800
Message-ID: <1416973315-6047-5-git-send-email-ying.xue@windriver.com>
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

In original tipc_link_push_packet(), it pushes messages from protocol
message queue, retransmission queue and next_out queue. But as the two
first queues are removed, we can simplify its relevant code through
deleting tipc_link_push_queue().

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c |    2 +-
 net/tipc/link.c  |   62 +++++++++++++++++++-----------------------------------
 net/tipc/link.h  |    2 +-
 3 files changed, 24 insertions(+), 42 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 556b26a..2764884 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -307,7 +307,7 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 	/* Try resolving broadcast link congestion, if necessary */
 
 	if (unlikely(bcl->next_out)) {
-		tipc_link_push_queue(bcl);
+		tipc_link_push_packets(bcl);
 		bclink_set_last_sent();
 	}
 	if (unlikely(released && !skb_queue_empty(&bcl->waiting_sks)))
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 4b7cbfd..470f053 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -149,18 +149,6 @@ static void link_init_max_pkt(struct tipc_link *l_ptr)
 	l_ptr->max_pkt_probes = 0;
 }
 
-static u32 link_next_sent(struct tipc_link *l_ptr)
-{
-	if (l_ptr->next_out)
-		return buf_seqno(l_ptr->next_out);
-	return mod(l_ptr->next_out_no);
-}
-
-static u32 link_last_sent(struct tipc_link *l_ptr)
-{
-	return mod(link_next_sent(l_ptr) - 1);
-}
-
 /*
  *  Simple non-static link routines (i.e. referenced outside this file)
  */
@@ -222,7 +210,7 @@ static void link_timeout(struct tipc_link *l_ptr)
 	link_state_event(l_ptr, TIMEOUT_EVT);
 
 	if (l_ptr->next_out)
-		tipc_link_push_queue(l_ptr);
+		tipc_link_push_packets(l_ptr);
 
 	tipc_node_unlock(l_ptr->owner);
 }
@@ -864,43 +852,37 @@ static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf)
 }
 
 /*
- * tipc_link_push_packet: Push one unsent packet to the media
+ * tipc_link_push_packets - push unsent packets to bearer
+ *
+ * Push out the unsent messages of a link where congestion
+ * has abated. Node is locked.
+ *
+ * Called with node locked
  */
-static u32 tipc_link_push_packet(struct tipc_link *l_ptr)
+void tipc_link_push_packets(struct tipc_link *l_ptr)
 {
-	struct sk_buff *buf = l_ptr->next_out;
+	struct sk_buff *skb;
+	struct tipc_msg *msg;
+	u32 next, first;
 
-	/* Send one deferred data message, if send window not full: */
-	if (buf) {
-		struct tipc_msg *msg = buf_msg(buf);
-		u32 next = msg_seqno(msg);
-		u32 first = buf_seqno(l_ptr->first_out);
+	while (l_ptr->next_out) {
+		skb = l_ptr->next_out;
+		msg = buf_msg(skb);
+		next = msg_seqno(msg);
+		first = buf_seqno(l_ptr->first_out);
 
 		if (mod(next - first) < l_ptr->queue_limit[0]) {
 			msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
 			msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
-			tipc_bearer_send(l_ptr->bearer_id, buf,
-					 &l_ptr->media_addr);
 			if (msg_user(msg) == MSG_BUNDLER)
 				msg_set_type(msg, BUNDLE_CLOSED);
-			l_ptr->next_out = buf->next;
-			return 0;
+			tipc_bearer_send(l_ptr->bearer_id, skb,
+					 &l_ptr->media_addr);
+			l_ptr->next_out = skb->next;
+		} else {
+			break;
 		}
 	}
-	return 1;
-}
-
-/*
- * push_queue(): push out the unsent messages of a link where
- *               congestion has abated. Node is locked
- */
-void tipc_link_push_queue(struct tipc_link *l_ptr)
-{
-	u32 res;
-
-	do {
-		res = tipc_link_push_packet(l_ptr);
-	} while (!res);
 }
 
 void tipc_link_reset_all(struct tipc_node *node)
@@ -1164,7 +1146,7 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 
 		/* Try sending any messages link endpoint has pending */
 		if (unlikely(l_ptr->next_out))
-			tipc_link_push_queue(l_ptr);
+			tipc_link_push_packets(l_ptr);
 
 		if (released && !skb_queue_empty(&l_ptr->waiting_sks)) {
 			link_prepare_wakeup(l_ptr);
diff --git a/net/tipc/link.h b/net/tipc/link.h
index cc816aa..1681076 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -227,7 +227,7 @@ u32 tipc_link_get_max_pkt(u32 dest, u32 selector);
 void tipc_link_bundle_rcv(struct sk_buff *buf);
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
 			  u32 gap, u32 tolerance, u32 priority, u32 acked_mtu);
-void tipc_link_push_queue(struct tipc_link *l_ptr);
+void tipc_link_push_packets(struct tipc_link *l_ptr);
 u32 tipc_link_defer_pkt(struct sk_buff **head, struct sk_buff **tail,
 			struct sk_buff *buf);
 void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window);
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
