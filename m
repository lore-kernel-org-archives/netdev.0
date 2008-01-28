From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [INET]: Prevent out-of-sync truesize on ip_fragment slow path
Date: Mon, 28 Jan 2008 22:12:59 +1100
Message-ID: <20080128111259.GA6490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49481 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750750AbYA1LNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 06:13:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

[INET]: Prevent out-of-sync truesize on ip_fragment slow path

When ip_fragment has to hit the slow path the value of skb->truesize
may go out of sync because we would have updated it without changing
the packet length.  This violates the constraints on truesize.

This patch postpones the update of skb->truesize to prevent this.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index fd99fbd..76ec973 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -462,6 +462,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 	if (skb_shinfo(skb)->frag_list) {
 		struct sk_buff *frag;
 		int first_len = skb_pagelen(skb);
+		int truesizes = 0;
 
 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||
@@ -485,7 +486,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 				sock_hold(skb->sk);
 				frag->sk = skb->sk;
 				frag->destructor = sock_wfree;
-				skb->truesize -= frag->truesize;
+				truesizes += frag->truesize;
 			}
 		}
 
@@ -496,6 +497,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 		frag = skb_shinfo(skb)->frag_list;
 		skb_shinfo(skb)->frag_list = NULL;
 		skb->data_len = first_len - skb_headlen(skb);
+		skb->truesize -= truesizes;
 		skb->len = first_len;
 		iph->tot_len = htons(first_len);
 		iph->frag_off = htons(IP_MF);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6338a9c..bb9b183 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -609,6 +609,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 	if (skb_shinfo(skb)->frag_list) {
 		int first_len = skb_pagelen(skb);
+		int truesizes = 0;
 
 		if (first_len - hlen > mtu ||
 		    ((first_len - hlen) & 7) ||
@@ -631,7 +632,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 				sock_hold(skb->sk);
 				frag->sk = skb->sk;
 				frag->destructor = sock_wfree;
-				skb->truesize -= frag->truesize;
+				truesizes += frag->truesize;
 			}
 		}
 
@@ -662,6 +663,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 		first_len = skb_pagelen(skb);
 		skb->data_len = first_len - skb_headlen(skb);
+		skb->truesize -= truesizes;
 		skb->len = first_len;
 		ipv6_hdr(skb)->payload_len = htons(first_len -
 						   sizeof(struct ipv6hdr));
