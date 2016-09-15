From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: prepare skbs for better sack shifting
Date: Thu, 15 Sep 2016 09:33:02 -0700
Message-ID: <1473957182.22679.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34034 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751731AbcIOQdF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 12:33:05 -0400
Received: by mail-pf0-f196.google.com with SMTP id 21so981240pfy.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 09:33:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

With large BDP TCP flows and lossy networks, it is very important
to keep a low number of skbs in the write queue.

RACK and SACK processing can perform a linear scan of it.

We should avoid putting any payload in skb->head, so that SACK
shifting can be done if needed.

With this patch, we allow to pack ~0.5 MB per skb instead of
the 64KB initially cooked at tcp_sendmsg() time.

This gives a reduction of number of skbs in write queue by eight.
tcp_rack_detect_loss() likes this.

We still allow payload in skb->head for first skb put in the queue,
to not impact RPC workloads.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp.c |   31 ++++++++++++++++++++++++-------
 1 file changed, 24 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a13fcb369f52fe85def7c9d856259bc0509f3453..7dae800092e62cec330544851289d20a68642561 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1020,17 +1020,31 @@ int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 }
 EXPORT_SYMBOL(tcp_sendpage);
 
-static inline int select_size(const struct sock *sk, bool sg)
+/* Do not bother using a page frag for very small frames.
+ * But use this heuristic only for the first skb in write queue.
+ *
+ * Having no payload in skb->head allows better SACK shifting
+ * in tcp_shift_skb_data(), reducing sack/rack overhead, because
+ * write queue has less skbs.
+ * Each skb can hold up to MAX_SKB_FRAGS * 32Kbytes, or ~0.5 MB.
+ * This also speeds up tso_fragment(), since it wont fallback
+ * to tcp_fragment().
+ */
+static int linear_payload_sz(bool first_skb)
+{
+	if (first_skb)
+		return SKB_WITH_OVERHEAD(2048 - MAX_TCP_HEADER);
+	return 0;
+}
+
+static int select_size(const struct sock *sk, bool sg, bool first_skb)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	int tmp = tp->mss_cache;
 
 	if (sg) {
 		if (sk_can_gso(sk)) {
-			/* Small frames wont use a full page:
-			 * Payload will immediately follow tcp header.
-			 */
-			tmp = SKB_WITH_OVERHEAD(2048 - MAX_TCP_HEADER);
+			tmp = linear_payload_sz(first_skb);
 		} else {
 			int pgbreak = SKB_MAX_HEAD(MAX_TCP_HEADER);
 
@@ -1161,6 +1175,8 @@ restart:
 		}
 
 		if (copy <= 0 || !tcp_skb_can_collapse_to(skb)) {
+			bool first_skb;
+
 new_segment:
 			/* Allocate new segment. If the interface is SG,
 			 * allocate skb fitting to single page.
@@ -1172,10 +1188,11 @@ new_segment:
 				process_backlog = false;
 				goto restart;
 			}
+			first_skb = skb_queue_empty(&sk->sk_write_queue);
 			skb = sk_stream_alloc_skb(sk,
-						  select_size(sk, sg),
+						  select_size(sk, sg, first_skb),
 						  sk->sk_allocation,
-						  skb_queue_empty(&sk->sk_write_queue));
+						  first_skb);
 			if (!skb)
 				goto wait_for_memory;
 
