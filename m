From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net-next v3] tcp: use tcp_flags in tcp_data_queue()
Date: Wed, 24 Sep 2014 22:17:02 +0800
Message-ID: <ba777860fdfc42d53ecd35bdac5d81ca5a9872eb.1411568111.git.panweiping3@gmail.com>
References: <1411564948.15395.31.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28069 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753117AbaIXORx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 10:17:53 -0400
In-Reply-To: <1411564948.15395.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a cleanup which follows the idea in commit e11ecddf5128 (tcp: use
TCP_SKB_CB(skb)->tcp_flags in input path),
and it may reduce register pressure since skb->cb[] access is fast,
bacause skb is probably in a register.

v2: remove variable th
v3: reword the changelog

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/ipv4/tcp_input.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 13f3da4..a51663f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4339,7 +4339,6 @@ err:
 
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
-	const struct tcphdr *th = tcp_hdr(skb);
 	struct tcp_sock *tp = tcp_sk(sk);
 	int eaten = -1;
 	bool fragstolen = false;
@@ -4348,7 +4347,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 
 	skb_dst_drop(skb);
-	__skb_pull(skb, th->doff * 4);
+	__skb_pull(skb, tcp_hdr(skb)->doff * 4);
 
 	TCP_ECN_accept_cwr(tp, skb);
 
@@ -4392,7 +4391,7 @@ queue_and_out:
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		if (skb->len)
 			tcp_event_data_recv(sk, skb);
-		if (th->fin)
+		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 			tcp_fin(sk);
 
 		if (!skb_queue_empty(&tp->out_of_order_queue)) {
-- 
1.7.4
