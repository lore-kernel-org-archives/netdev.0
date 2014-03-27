From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: generalize MAX_TCP_HEADER usage
Date: Thu, 27 Mar 2014 13:19:06 -0700
Message-ID: <1395951546.12610.317.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:43225 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756679AbaC0UTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 16:19:08 -0400
Received: by mail-pb0-f41.google.com with SMTP id jt11so3981483pbb.14
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 13:19:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

There are a lot of call sites in TCP stack assuming maximal size of
headers is MAX_TCP_HEADER.

Both IPv6 and IPv4 share same max_header, so we can avoid some picky
usages in TCP stack and use a constant.

In tcp_xmit_size_goal() for example we do not care if we reserve 100
extra bytes, this has little/no impact on the max number of segments per
GSO packet. (Note that sk_stream_alloc_skb() uses MAX_TCP_HEADER
anyway...)

tcp_connect() do not need to allocate 15 bytes more than MAX_TCP_HEADER,
it is cooking a SYN packet without payload.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c        |   12 ++++--------
 net/ipv4/tcp_output.c |    3 +--
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4bd6d52eeffb..c5a3c0876e80 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -802,10 +802,10 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
 	/* The TCP header must be at least 32-bit aligned.  */
 	size = ALIGN(size, 4);
 
-	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
+	skb = alloc_skb_fclone(size + MAX_TCP_HEADER, gfp);
 	if (skb) {
 		if (sk_wmem_schedule(sk, skb->truesize)) {
-			skb_reserve(skb, sk->sk_prot->max_header);
+			skb_reserve(skb, MAX_TCP_HEADER);
 			/*
 			 * Make sure that we have exactly size bytes
 			 * available to the caller, no more, no less.
@@ -830,12 +830,8 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 	xmit_size_goal = mss_now;
 
 	if (large_allowed && sk_can_gso(sk)) {
-		u32 gso_size, hlen;
-
-		/* Maybe we should/could use sk->sk_prot->max_header here ? */
-		hlen = inet_csk(sk)->icsk_af_ops->net_header_len +
-		       inet_csk(sk)->icsk_ext_hdr_len +
-		       tp->tcp_header_len;
+		const u32 hlen = MAX_TCP_HEADER;
+		u32 gso_size;
 
 		/* Goal is to send at least one packet per ms,
 		 * not one big TSO packet every 100 ms.
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 699fb102e971..b528dea70392 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3023,11 +3023,10 @@ int tcp_connect(struct sock *sk)
 		return 0;
 	}
 
-	buff = alloc_skb_fclone(MAX_TCP_HEADER + 15, sk->sk_allocation);
+	buff = alloc_skb_fclone(MAX_TCP_HEADER, sk->sk_allocation);
 	if (unlikely(buff == NULL))
 		return -ENOBUFS;
 
-	/* Reserve space for headers. */
 	skb_reserve(buff, MAX_TCP_HEADER);
 
 	tcp_init_nondata_skb(buff, tp->write_seq++, TCPHDR_SYN);
