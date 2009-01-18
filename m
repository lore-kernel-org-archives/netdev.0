From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/3] gro: Fix handling of complete checksums in IPv6
Date: Sun, 18 Jan 2009 16:46:16 +1100
Message-ID: <20090118054616.GA24899@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56410 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752296AbZARFqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 00:46:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

Here are three bug fixes for GRO.

The first one makes sure we don't penalise CHECKSUM_COMPLETE
drivers for doing the right thing.

gro: Fix handling of complete checksums in IPv6

We need to perform skb_postpull_rcsum after pulling the IPv6
header in order to maintain the correctness of the complete
checksum.

This patch also adds a missing iph reload after pulling.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 94f74f5..c802bc1 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -797,6 +797,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	unsigned int nlen;
 	int flush = 1;
 	int proto;
+	__wsum csum;
 
 	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
 		goto out;
@@ -808,6 +809,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 
 	rcu_read_lock();
 	proto = ipv6_gso_pull_exthdrs(skb, iph->nexthdr);
+	iph = ipv6_hdr(skb);
 	IPV6_GRO_CB(skb)->proto = proto;
 	ops = rcu_dereference(inet6_protos[proto]);
 	if (!ops || !ops->gro_receive)
@@ -839,8 +841,13 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 
 	NAPI_GRO_CB(skb)->flush |= flush;
 
+	csum = skb->csum;
+	skb_postpull_rcsum(skb, iph, skb_network_header_len(skb));
+
 	pp = ops->gro_receive(head, skb);
 
+	skb->csum = csum;
+
 out_unlock:
 	rcu_read_unlock();

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
