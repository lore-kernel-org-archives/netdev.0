From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 4/6] tcp: fix behavior for epoll edge trigger
Date: Fri, 15 May 2015 12:39:28 -0700
Message-ID: <1431718770-3815-5-git-send-email-edumazet@google.com>
References: <1431718770-3815-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>, Jason Baron <jbaron@akamai.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:33070 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934138AbbEOTkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 15:40:37 -0400
Received: by igdh15 with SMTP id h15so88467igd.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 12:40:37 -0700 (PDT)
In-Reply-To: <1431718770-3815-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under memory pressure, tcp_sendmsg() can fail to queue a packet
while no packet is present in write queue. If we return -EAGAIN
with no packet in write queue, no ACK packet will ever come
to raise EPOLLOUT.

We need to allow one skb per TCP socket, and make sure that
tcp sockets can release their forward allocations under pressure.

This is a followup to commit 790ba4566c1a ("tcp: set SOCK_NOSPACE
under memory pressure")

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ecccfdc50d76..9eabfd3e0925 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -815,9 +815,20 @@ struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp)
 	/* The TCP header must be at least 32-bit aligned.  */
 	size = ALIGN(size, 4);
 
+	if (unlikely(tcp_under_memory_pressure(sk)))
+		sk_mem_reclaim_partial(sk);
+
 	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
-	if (skb) {
-		if (sk_wmem_schedule(sk, skb->truesize)) {
+	if (likely(skb)) {
+		bool mem_schedule;
+
+		if (skb_queue_len(&sk->sk_write_queue) == 0) {
+			mem_schedule = true;
+			sk_forced_mem_schedule(sk, skb->truesize);
+		} else {
+			mem_schedule = sk_wmem_schedule(sk, skb->truesize);
+		}
+		if (likely(mem_schedule)) {
 			skb_reserve(skb, sk->sk_prot->max_header);
 			/*
 			 * Make sure that we have exactly size bytes
-- 
2.2.0.rc0.207.ga3a616c
