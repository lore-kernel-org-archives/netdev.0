From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: add a force_schedule argument to
 sk_stream_alloc_skb()
Date: Tue, 19 May 2015 13:26:55 -0700
Message-ID: <1432067215.621.70.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36004 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbbESU05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:26:57 -0400
Received: by igbpi8 with SMTP id pi8so85804799igb.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 13:26:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit 8e4d980ac215 ("tcp: fix behavior for epoll edge trigger")
we fixed a possible hang of TCP sockets under memory pressure,
by allowing sk_stream_alloc_skb() to use sk_forced_mem_schedule()
if no packet is in socket write queue.

It turns out there are other cases where we want to force memory
schedule :

tcp_fragment() & tso_fragment() need to split a big TSO packet into
two smaller ones. If we block here because of TCP memory pressure,
we can effectively block TCP socket from sending new data.
If no further ACK is coming, this hang would be definitive, and socket
has no chance to effectively reduce its memory usage.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h    |    3 ++-
 net/ipv4/tcp.c        |   19 +++++++++++--------
 net/ipv4/tcp_output.c |   10 +++++-----
 3 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 4581a60636f880b2ba8f0e6574c96772202ebddb..26c1c3171e004eb6bf7afa5f8a0b8f6672cb590f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2025,7 +2025,8 @@ static inline void sk_stream_moderate_sndbuf(struct sock *sk)
 	}
 }
 
-struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp);
+struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp,
+				    bool force_schedule);
 
 /**
  * sk_page_frag - return an appropriate page_frag
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c724195e586287760e9406c3bccde4b3d0c0c75e..3defa6671439017b22c56eab2901f7c117429e28 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -808,7 +808,8 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 }
 EXPORT_SYMBOL(tcp_splice_read);
 
-struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
+struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp,
+				    bool force_schedule)
 {
 	struct sk_buff *skb;
 
@@ -820,15 +821,15 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
 
 	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
 	if (likely(skb)) {
-		bool mem_schedule;
+		bool mem_scheduled;
 
-		if (skb_queue_len(&sk->sk_write_queue) == 0) {
-			mem_schedule = true;
+		if (force_schedule) {
+			mem_scheduled = true;
 			sk_forced_mem_schedule(sk, skb->truesize);
 		} else {
-			mem_schedule = sk_wmem_schedule(sk, skb->truesize);
+			mem_scheduled = sk_wmem_schedule(sk, skb->truesize);
 		}
-		if (likely(mem_schedule)) {
+		if (likely(mem_scheduled)) {
 			skb_reserve(skb, sk->sk_prot->max_header);
 			/*
 			 * Make sure that we have exactly size bytes
@@ -918,7 +919,8 @@ new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
 
-			skb = sk_stream_alloc_skb(sk, 0, sk->sk_allocation);
+			skb = sk_stream_alloc_skb(sk, 0, sk->sk_allocation,
+						  skb_queue_empty(&sk->sk_write_queue));
 			if (!skb)
 				goto wait_for_memory;
 
@@ -1154,7 +1156,8 @@ new_segment:
 
 			skb = sk_stream_alloc_skb(sk,
 						  select_size(sk, sg),
-						  sk->sk_allocation);
+						  sk->sk_allocation,
+						  skb_queue_empty(&sk->sk_write_queue));
 			if (!skb)
 				goto wait_for_memory;
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 08c2cc40b26d65227eccaf3b5a068c16cef62fa1..3361da802de481793ab0a8bbaf014497d917626e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1163,7 +1163,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 		return -ENOMEM;
 
 	/* Get a new skb... force flag on. */
-	buff = sk_stream_alloc_skb(sk, nsize, gfp);
+	buff = sk_stream_alloc_skb(sk, nsize, gfp, true);
 	if (!buff)
 		return -ENOMEM; /* We'll just try again later. */
 
@@ -1722,7 +1722,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 	if (skb->len != skb->data_len)
 		return tcp_fragment(sk, skb, len, mss_now, gfp);
 
-	buff = sk_stream_alloc_skb(sk, 0, gfp);
+	buff = sk_stream_alloc_skb(sk, 0, gfp, true);
 	if (unlikely(!buff))
 		return -ENOMEM;
 
@@ -1941,7 +1941,7 @@ static int tcp_mtu_probe(struct sock *sk)
 	}
 
 	/* We're allowed to probe.  Build it now. */
-	nskb = sk_stream_alloc_skb(sk, probe_size, GFP_ATOMIC);
+	nskb = sk_stream_alloc_skb(sk, probe_size, GFP_ATOMIC, false);
 	if (!nskb)
 		return -1;
 	sk->sk_wmem_queued += nskb->truesize;
@@ -3177,7 +3177,7 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 	/* limit to order-0 allocations */
 	space = min_t(size_t, space, SKB_MAX_HEAD(MAX_TCP_HEADER));
 
-	syn_data = sk_stream_alloc_skb(sk, space, sk->sk_allocation);
+	syn_data = sk_stream_alloc_skb(sk, space, sk->sk_allocation, false);
 	if (!syn_data)
 		goto fallback;
 	syn_data->ip_summed = CHECKSUM_PARTIAL;
@@ -3243,7 +3243,7 @@ int tcp_connect(struct sock *sk)
 		return 0;
 	}
 
-	buff = sk_stream_alloc_skb(sk, 0, sk->sk_allocation);
+	buff = sk_stream_alloc_skb(sk, 0, sk->sk_allocation, true);
 	if (unlikely(!buff))
 		return -ENOBUFS;
 
