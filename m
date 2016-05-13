From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: minor optimizations around tcp_hdr() usage
Date: Fri, 13 May 2016 09:16:40 -0700
Message-ID: <1463156200.23934.199.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36589 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbcEMQQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 12:16:43 -0400
Received: by mail-pf0-f196.google.com with SMTP id g132so9659369pfb.3
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 09:16:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_hdr() is slightly more expensive than using skb->data in contexts
where we know they point to the same byte.

In receive path, tcp_v4_rcv() and tcp_v6_rcv() are in this situation,
as tcp header has not been pulled yet.

In output path, the same can be said when we just pushed the tcp header
in the skb, in tcp_transmit_skb() and tcp_make_synack()

Also factorize the two checks for tcb->tcp_flags & TCPHDR_SYN in
tcp_transmit_skb() and pass tcp header pointer to tcp_ecn_send(),
so that compiler can further optimize and avoid a reload.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c   |    6 +++---
 net/ipv4/tcp_output.c |   30 ++++++++++++++----------------
 net/ipv6/tcp_ipv6.c   |    6 +++---
 3 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8219d0d8dc8370d0d3e6fc4cd17b4925617968ab..3708de2a66833cf1d4a221a2b6ce3923bde978c4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1556,9 +1556,9 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct tcphdr)))
 		goto discard_it;
 
-	th = tcp_hdr(skb);
+	th = (const struct tcphdr *)skb->data;
 
-	if (th->doff < sizeof(struct tcphdr) / 4)
+	if (unlikely(th->doff < sizeof(struct tcphdr) / 4))
 		goto bad_packet;
 	if (!pskb_may_pull(skb, th->doff * 4))
 		goto discard_it;
@@ -1571,7 +1571,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (skb_checksum_init(skb, IPPROTO_TCP, inet_compute_pseudo))
 		goto csum_error;
 
-	th = tcp_hdr(skb);
+	th = (const struct tcphdr *)skb->data;
 	iph = ip_hdr(skb);
 	/* This is tricky : We move IPCB at its correct location into TCP_SKB_CB()
 	 * barrier() makes sure compiler wont play fool^Waliasing games.
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8daefd8b1b495f23e45b6c9e6b70525715498c08..fc5bebf6bed1d1d45802a05da4076d7df481defe 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -364,7 +364,7 @@ tcp_ecn_make_synack(const struct request_sock *req, struct tcphdr *th)
  * be sent.
  */
 static void tcp_ecn_send(struct sock *sk, struct sk_buff *skb,
-				int tcp_header_len)
+			 struct tcphdr *th, int tcp_header_len)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -375,7 +375,7 @@ static void tcp_ecn_send(struct sock *sk, struct sk_buff *skb,
 			INET_ECN_xmit(sk);
 			if (tp->ecn_flags & TCP_ECN_QUEUE_CWR) {
 				tp->ecn_flags &= ~TCP_ECN_QUEUE_CWR;
-				tcp_hdr(skb)->cwr = 1;
+				th->cwr = 1;
 				skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
 			}
 		} else if (!tcp_ca_needs_ecn(sk)) {
@@ -383,7 +383,7 @@ static void tcp_ecn_send(struct sock *sk, struct sk_buff *skb,
 			INET_ECN_dontxmit(sk);
 		}
 		if (tp->ecn_flags & TCP_ECN_DEMAND_CWR)
-			tcp_hdr(skb)->ece = 1;
+			th->ece = 1;
 	}
 }
 
@@ -954,7 +954,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 
 	/* Build TCP header and checksum it. */
-	th = tcp_hdr(skb);
+	th = (struct tcphdr *)skb->data;
 	th->source		= inet->inet_sport;
 	th->dest		= inet->inet_dport;
 	th->seq			= htonl(tcb->seq);
@@ -962,14 +962,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	*(((__be16 *)th) + 6)	= htons(((tcp_header_size >> 2) << 12) |
 					tcb->tcp_flags);
 
-	if (unlikely(tcb->tcp_flags & TCPHDR_SYN)) {
-		/* RFC1323: The window in SYN & SYN/ACK segments
-		 * is never scaled.
-		 */
-		th->window	= htons(min(tp->rcv_wnd, 65535U));
-	} else {
-		th->window	= htons(tcp_select_window(sk));
-	}
 	th->check		= 0;
 	th->urg_ptr		= 0;
 
@@ -986,9 +978,15 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 	tcp_options_write((__be32 *)(th + 1), tp, &opts);
 	skb_shinfo(skb)->gso_type = sk->sk_gso_type;
-	if (likely((tcb->tcp_flags & TCPHDR_SYN) == 0))
-		tcp_ecn_send(sk, skb, tcp_header_size);
-
+	if (likely(!(tcb->tcp_flags & TCPHDR_SYN))) {
+		th->window      = htons(tcp_select_window(sk));
+		tcp_ecn_send(sk, skb, th, tcp_header_size);
+	} else {
+		/* RFC1323: The window in SYN & SYN/ACK segments
+		 * is never scaled.
+		 */
+		th->window	= htons(min(tp->rcv_wnd, 65535U));
+	}
 #ifdef CONFIG_TCP_MD5SIG
 	/* Calculate the MD5 hash, as we have all we need now */
 	if (md5) {
@@ -3038,7 +3036,7 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
 
-	th = tcp_hdr(skb);
+	th = (struct tcphdr *)skb->data;
 	memset(th, 0, sizeof(struct tcphdr));
 	th->syn = 1;
 	th->ack = 1;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c4efaa97280c20918866e3311bb756abf0a325c4..79e33e02f11accfd5a6c8cf2751df0a8793ab016 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1369,9 +1369,9 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct tcphdr)))
 		goto discard_it;
 
-	th = tcp_hdr(skb);
+	th = (const struct tcphdr *)skb->data;
 
-	if (th->doff < sizeof(struct tcphdr)/4)
+	if (unlikely(th->doff < sizeof(struct tcphdr)/4))
 		goto bad_packet;
 	if (!pskb_may_pull(skb, th->doff*4))
 		goto discard_it;
@@ -1379,7 +1379,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	if (skb_checksum_init(skb, IPPROTO_TCP, ip6_compute_pseudo))
 		goto csum_error;
 
-	th = tcp_hdr(skb);
+	th = (const struct tcphdr *)skb->data;
 	hdr = ipv6_hdr(skb);
 
 lookup:
