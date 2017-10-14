From: Koichiro Den <den@klaipeden.com>
Subject: [net-next 2/3] tcp: do not tcp_collapse once SYN or FIN found
Date: Sat, 14 Oct 2017 16:27:44 +0900
Message-ID: <20171014072745.23462-3-den@klaipeden.com>
References: <20171014072745.23462-1-den@klaipeden.com>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21408 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751737AbdJNH2A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 03:28:00 -0400
In-Reply-To: <20171014072745.23462-1-den@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 9f5afeae5152 ("tcp: use an RB tree for ooo receive queue")
applied, we no longer need to continue to search for the starting
point once we encounter FIN packet. Same reasoning for SYN packet
since commit 9d691539eea2d ("tcp: do not enqueue skb with SYN flag"),
that would help us with error message when actual receiving.

Signed-off-by: Koichiro Den <den@klaipeden.com>
---
 net/ipv4/tcp_input.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1d785b5bf62d..1a74457db0f3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4775,6 +4775,14 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list, struct rb_root *root,
 	 */
 restart:
 	for (end_of_skbs = true; skb != NULL && skb != tail; skb = n) {
+		/* If list is ooo queue, it will get purged when
+		 * this FIN will get moved to sk_receive_queue.
+		 * SYN packet is not expected here. We will get
+		 * error message when actual receiving.
+		 */
+		if (TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_FIN | TCPHDR_SYN))
+			return;
+
 		n = tcp_skb_next(skb, list);
 
 		/* No new bits? It is possible on ofo queue. */
@@ -4786,13 +4794,11 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list, struct rb_root *root,
 		}
 
 		/* The first skb to collapse is:
-		 * - not SYN/FIN and
 		 * - bloated or contains data before "start" or
 		 *   overlaps to the next one.
 		 */
-		if (!(TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)) &&
-		    (tcp_win_from_space(skb->truesize) > skb->len ||
-		     before(TCP_SKB_CB(skb)->seq, start))) {
+		if (tcp_win_from_space(skb->truesize) > skb->len ||
+		    before(TCP_SKB_CB(skb)->seq, start)) {
 			end_of_skbs = false;
 			break;
 		}
@@ -4807,7 +4813,6 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list, struct rb_root *root,
 		start = TCP_SKB_CB(skb)->end_seq;
 	}
 	if (end_of_skbs ||
-	    (TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)) ||
 	    (TCP_SKB_CB(skb)->seq == start && TCP_SKB_CB(skb)->end_seq == end))
 		return;
 
@@ -4845,9 +4850,7 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list, struct rb_root *root,
 			}
 			if (!before(start, TCP_SKB_CB(skb)->end_seq)) {
 				skb = tcp_collapse_one(sk, skb, list, root);
-				if (!skb ||
-				    skb == tail ||
-				    (TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)))
+				if (!skb || skb == tail)
 					goto end;
 			}
 		}
-- 
2.9.4
