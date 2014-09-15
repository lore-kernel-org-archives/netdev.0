From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/3] tcp: use TCP_SKB_CB(skb)->tcp_flags in input path
Date: Sun, 14 Sep 2014 19:56:18 -0700
Message-ID: <1410749780-30613-2-git-send-email-edumazet@google.com>
References: <1410749780-30613-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:47354 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206AbaIOC44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 22:56:56 -0400
Received: by mail-vc0-f202.google.com with SMTP id le20so329233vcb.5
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 19:56:55 -0700 (PDT)
In-Reply-To: <1410749780-30613-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Input path of TCP do not currently uses TCP_SKB_CB(skb)->tcp_flags,
which is only used in output path.

tcp_recvmsg(), looks at tcp_hdr(skb)->syn for every skb found in receive queue,
and it is unfortunate because this bit is located in a cache line right before
the payload.

We can simplify TCP by copying tcp flags into TCP_SKB_CB(skb)->tcp_flags.

This patch does so, and avoids the cache line miss in tcp_recvmsg()

Following patches will
- allow a segment with FIN being coalesced in tcp_try_coalesce()
- simplify tcp_collapse() by not copying the headers.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c       | 18 ++++++++++--------
 net/ipv4/tcp_input.c | 10 +++++-----
 net/ipv4/tcp_ipv4.c  |  1 +
 net/ipv6/tcp_ipv6.c  |  1 +
 4 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 541f26a67ba2..070aeff1b131 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1510,9 +1510,9 @@ static struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off)
 
 	while ((skb = skb_peek(&sk->sk_receive_queue)) != NULL) {
 		offset = seq - TCP_SKB_CB(skb)->seq;
-		if (tcp_hdr(skb)->syn)
+		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
 			offset--;
-		if (offset < skb->len || tcp_hdr(skb)->fin) {
+		if (offset < skb->len || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)) {
 			*off = offset;
 			return skb;
 		}
@@ -1585,7 +1585,7 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 			if (offset + 1 != skb->len)
 				continue;
 		}
-		if (tcp_hdr(skb)->fin) {
+		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN) {
 			sk_eat_skb(sk, skb, false);
 			++seq;
 			break;
@@ -1722,11 +1722,11 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				break;
 
 			offset = *seq - TCP_SKB_CB(skb)->seq;
-			if (tcp_hdr(skb)->syn)
+			if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
 				offset--;
 			if (offset < skb->len)
 				goto found_ok_skb;
-			if (tcp_hdr(skb)->fin)
+			if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 				goto found_fin_ok;
 			WARN(!(flags & MSG_PEEK),
 			     "recvmsg bug 2: copied %X seq %X rcvnxt %X fl %X\n",
@@ -1959,7 +1959,7 @@ skip_copy:
 		if (used + offset < skb->len)
 			continue;
 
-		if (tcp_hdr(skb)->fin)
+		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 			goto found_fin_ok;
 		if (!(flags & MSG_PEEK)) {
 			sk_eat_skb(sk, skb, copied_early);
@@ -2160,8 +2160,10 @@ void tcp_close(struct sock *sk, long timeout)
 	 *  reader process may not have drained the data yet!
 	 */
 	while ((skb = __skb_dequeue(&sk->sk_receive_queue)) != NULL) {
-		u32 len = TCP_SKB_CB(skb)->end_seq - TCP_SKB_CB(skb)->seq -
-			  tcp_hdr(skb)->fin;
+		u32 len = TCP_SKB_CB(skb)->end_seq - TCP_SKB_CB(skb)->seq;
+
+		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
+			len--;
 		data_was_unread += len;
 		__kfree_skb(skb);
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f97003ad0af5..8f639a4face9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4093,7 +4093,7 @@ static void tcp_ofo_queue(struct sock *sk)
 		__skb_unlink(skb, &tp->out_of_order_queue);
 		__skb_queue_tail(&sk->sk_receive_queue, skb);
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
-		if (tcp_hdr(skb)->fin)
+		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 			tcp_fin(sk);
 	}
 }
@@ -4513,7 +4513,7 @@ restart:
 		 * - bloated or contains data before "start" or
 		 *   overlaps to the next one.
 		 */
-		if (!tcp_hdr(skb)->syn && !tcp_hdr(skb)->fin &&
+		if (!(TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)) &&
 		    (tcp_win_from_space(skb->truesize) > skb->len ||
 		     before(TCP_SKB_CB(skb)->seq, start))) {
 			end_of_skbs = false;
@@ -4532,7 +4532,8 @@ restart:
 		/* Decided to skip this, advance start seq. */
 		start = TCP_SKB_CB(skb)->end_seq;
 	}
-	if (end_of_skbs || tcp_hdr(skb)->syn || tcp_hdr(skb)->fin)
+	if (end_of_skbs ||
+	    (TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)))
 		return;
 
 	while (before(start, end)) {
@@ -4579,8 +4580,7 @@ restart:
 				skb = tcp_collapse_one(sk, skb, list);
 				if (!skb ||
 				    skb == tail ||
-				    tcp_hdr(skb)->syn ||
-				    tcp_hdr(skb)->fin)
+				    (TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)))
 					return;
 			}
 		}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7881b96d2b72..006b045716d8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1638,6 +1638,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
 				    skb->len - th->doff * 4);
 	TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
+	TCP_SKB_CB(skb)->tcp_flags = tcp_flag_byte(th);
 	TCP_SKB_CB(skb)->tcp_tw_isn = 0;
 	TCP_SKB_CB(skb)->ip_dsfield = ipv4_get_dsfield(iph);
 	TCP_SKB_CB(skb)->sacked	 = 0;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1835480336ac..de51a88bec6f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1415,6 +1415,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
 				    skb->len - th->doff*4);
 	TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
+	TCP_SKB_CB(skb)->tcp_flags = tcp_flag_byte(th);
 	TCP_SKB_CB(skb)->tcp_tw_isn = 0;
 	TCP_SKB_CB(skb)->ip_dsfield = ipv6_get_dsfield(hdr);
 	TCP_SKB_CB(skb)->sacked = 0;
-- 
2.1.0.rc2.206.gedb03e5
