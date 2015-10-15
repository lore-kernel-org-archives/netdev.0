From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 3/7] tipc: improve sequence
	number checking
Date: Thu, 15 Oct 2015 14:52:42 -0400
Message-ID: <1444935166-12745-4-git-send-email-jon.maloy@ericsson.com>
References: <1444935166-12745-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1444935166-12745-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The sequence number of an incoming packet is currently only checked
for less than, equality to, or bigger than the next expected number,
meaning that the receive window in practice becomes one half sequence
number cycle, or U16_MAX/2. This does not make sense, and may not even
be safe if there are extreme delays in the network. Any packet sent by
the peer during the ongoing cycle must belong inside his current send
window, or should otherwise be dropped if possible.

Since a link endpoint cannot know its peer's current send window, it
has to base this sanity check on a worst-case assumption, i.e., that
the peer is using a maximum sized window of 8191 packets. Using this
assumption, we now add a check that the sequence number is not bigger
than next_expected + TIPC_MAX_LINK_WIN. We also re-order the checks
done, so that the receive window test is performed before the gap test.
This way, we are guaranteed that no packet with illegal sequence numbers
are ever added to the deferred queue.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c | 26 ++++++++++++--------------
 net/tipc/link.h |  2 +-
 2 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 8e23ab5..2b549f6 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1077,13 +1077,14 @@ int tipc_link_rcv(struct tipc_link *l, struct sk_buff *skb,
 {
 	struct sk_buff_head *defq = &l->deferdq;
 	struct tipc_msg *hdr;
-	u16 seqno, rcv_nxt;
+	u16 seqno, rcv_nxt, win_lim;
 	int rc = 0;
 
 	do {
 		hdr = buf_msg(skb);
 		seqno = msg_seqno(hdr);
 		rcv_nxt = l->rcv_nxt;
+		win_lim = rcv_nxt + TIPC_MAX_LINK_WIN;
 
 		/* Verify and update link state */
 		if (unlikely(msg_user(hdr) == LINK_PROTOCOL))
@@ -1098,6 +1099,12 @@ int tipc_link_rcv(struct tipc_link *l, struct sk_buff *skb,
 		/* Don't send probe at next timeout expiration */
 		l->silent_intv_cnt = 0;
 
+		/* Drop if outside receive window */
+		if (unlikely(less(seqno, rcv_nxt) || more(seqno, win_lim))) {
+			l->stats.duplicates++;
+			goto drop;
+		}
+
 		/* Forward queues and wake up waiting users */
 		if (likely(tipc_link_release_pkts(l, msg_ack(hdr)))) {
 			tipc_link_advance_backlog(l, xmitq);
@@ -1105,29 +1112,20 @@ int tipc_link_rcv(struct tipc_link *l, struct sk_buff *skb,
 				link_prepare_wakeup(l);
 		}
 
-		/* Defer reception if there is a gap in the sequence */
-		if (unlikely(less(rcv_nxt, seqno))) {
+		/* Defer delivery if sequence gap */
+		if (unlikely(seqno != rcv_nxt)) {
 			__tipc_skb_queue_sorted(defq, skb);
 			tipc_link_build_nack_msg(l, xmitq);
 			break;
 		}
 
-		/* Drop if packet already received */
-		if (unlikely(more(rcv_nxt, seqno))) {
-			l->stats.duplicates++;
-			goto drop;
-		}
-
-		/* Packet can be delivered */
+		/* Deliver packet */
 		l->rcv_nxt++;
 		l->stats.recv_info++;
-
 		if (!tipc_data_input(l, skb, l->inputq))
 			rc = tipc_link_input(l, skb, l->inputq);
-		if (rc)
+		if (unlikely(rc))
 			break;
-
-		/* Ack at regular intervals */
 		if (unlikely(++l->rcv_unacked >= TIPC_MIN_LINK_WIN))
 			tipc_link_build_ack_msg(l, xmitq);
 
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 39ff8b6..7a1ad42 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -185,7 +185,7 @@ struct tipc_link {
 	} backlog[5];
 	u16 snd_nxt;
 	u16 last_retransm;
-	u32 window;
+	u16 window;
 	u32 stale_count;
 
 	/* Reception */
-- 
1.9.1


------------------------------------------------------------------------------
