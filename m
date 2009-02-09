From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/4] gro: Optimise TCP packet reception
Date: Mon, 09 Feb 2009 15:00:40 +1100
Message-ID: <E1LWNK4-0000o0-5h@gondolin.me.apana.org.au>
References: <20090209035930.GA2988@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34972 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753894AbZBIEAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2009 23:00:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Optimise TCP packet reception

As this function can be called more than half a million times for
10GbE, it's important to optimise it as much as we can.

This patch uses bit ops to logical ops, as well as open coding
memcmp to exploit alignment properties.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/tcp.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 73266b7..90b2f3c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2478,9 +2478,9 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	struct tcphdr *th2;
 	unsigned int thlen;
 	unsigned int flags;
-	unsigned int total;
 	unsigned int mss = 1;
 	int flush = 1;
+	int i;
 
 	th = skb_gro_header(skb, sizeof(*th));
 	if (unlikely(!th))
@@ -2504,7 +2504,7 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 		th2 = tcp_hdr(p);
 
-		if (th->source != th2->source || th->dest != th2->dest) {
+		if ((th->source ^ th2->source) | (th->dest ^ th2->dest)) {
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
@@ -2519,14 +2519,15 @@ found:
 	flush |= flags & TCP_FLAG_CWR;
 	flush |= (flags ^ tcp_flag_word(th2)) &
 		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH);
-	flush |= th->ack_seq != th2->ack_seq || th->window != th2->window;
-	flush |= memcmp(th + 1, th2 + 1, thlen - sizeof(*th));
+	flush |= (th->ack_seq ^ th2->ack_seq) | (th->window ^ th2->window);
+	for (i = sizeof(*th); !flush && i < thlen; i += 4)
+		flush |= *(u32 *)((u8 *)th + i) ^
+			 *(u32 *)((u8 *)th2 + i);
 
-	total = skb_gro_len(p);
 	mss = skb_shinfo(p)->gso_size;
 
-	flush |= skb_gro_len(skb) > mss || !skb_gro_len(skb);
-	flush |= ntohl(th2->seq) + total != ntohl(th->seq);
+	flush |= (skb_gro_len(skb) > mss) | !skb_gro_len(skb);
+	flush |= (ntohl(th2->seq) + skb_gro_len(p)) ^ ntohl(th->seq);
 
 	if (flush || skb_gro_receive(head, skb)) {
 		mss = 1;
