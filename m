From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: gro: Fix use after free in tcp_gro_receive
Date: Fri, 17 Apr 2009 17:25:53 +0800
Message-ID: <20090417092553.GA1601@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mark Wagner <mwagner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38365 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752123AbZDQJZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 05:25:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

gro: Fix use after free in tcp_gro_receive

After calling skb_gro_receive skb->len can no longer be relied
on since if the skb was merged using frags, then its pages will
have been removed and the length reduced.

This caused tcp_gro_receive to prematurely end merging which
resulted in suboptimal performance with ixgbe.

The fix is to store skb->len on the stack.

Reported-by: Mark Wagner <mwagner@redhat.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index fafbec8..1d7f49c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2511,6 +2511,7 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	struct sk_buff *p;
 	struct tcphdr *th;
 	struct tcphdr *th2;
+	unsigned int len;
 	unsigned int thlen;
 	unsigned int flags;
 	unsigned int mss = 1;
@@ -2531,6 +2532,7 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 	skb_gro_pull(skb, thlen);
 
+	len = skb_gro_len(skb);
 	flags = tcp_flag_word(th);
 
 	for (; (p = *head); head = &p->next) {
@@ -2561,7 +2563,7 @@ found:
 
 	mss = skb_shinfo(p)->gso_size;
 
-	flush |= (skb_gro_len(skb) > mss) | !skb_gro_len(skb);
+	flush |= (len > mss) | !len;
 	flush |= (ntohl(th2->seq) + skb_gro_len(p)) ^ ntohl(th->seq);
 
 	if (flush || skb_gro_receive(head, skb)) {
@@ -2574,7 +2576,7 @@ found:
 	tcp_flag_word(th2) |= flags & (TCP_FLAG_FIN | TCP_FLAG_PSH);
 
 out_check_final:
-	flush = skb_gro_len(skb) < mss;
+	flush = len < mss;
 	flush |= flags & (TCP_FLAG_URG | TCP_FLAG_PSH | TCP_FLAG_RST |
 			  TCP_FLAG_SYN | TCP_FLAG_FIN);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
