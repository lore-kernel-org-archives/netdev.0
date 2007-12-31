From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Fix transport-mode async resume on intput without netfilter
Date: Mon, 31 Dec 2007 11:31:18 +1100
Message-ID: <20071231003117.GA595@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2665 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755787AbXLaAbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2007 19:31:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

Found another bug on the input path when NETFILTER is off.

[IPSEC]: Fix transport-mode async resume on intput without netfilter

When netfilter is off the transport-mode async resumption doesn't work
because we don't push back the IP header.  This patch fixes that by
moving most of the code outside of ifdef NETFILTER since the only part
that's not common is the short-circuit in the protocol handler.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 33f990d..390dcb1 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -51,7 +51,11 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 
 	iph->protocol = XFRM_MODE_SKB_CB(skb)->protocol;
 
-#ifdef CONFIG_NETFILTER
+#ifndef CONFIG_NETFILTER
+	if (!async)
+		return -iph->protocol;
+#endif
+
 	__skb_push(skb, skb->data - skb_network_header(skb));
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
@@ -59,12 +63,6 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 	NF_HOOK(PF_INET, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 		xfrm4_rcv_encap_finish);
 	return 0;
-#else
-	if (async)
-		return xfrm4_rcv_encap_finish(skb);
-
-	return -iph->protocol;
-#endif
 }
 
 /* If it's a keepalive packet, then just eat it.
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 063ce6e..a4714d7 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -34,19 +34,17 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 	skb_network_header(skb)[IP6CB(skb)->nhoff] =
 		XFRM_MODE_SKB_CB(skb)->protocol;
 
-#ifdef CONFIG_NETFILTER
+#ifndef CONFIG_NETFILTER
+	if (!async)
+		return 1;
+#endif
+
 	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
 
 	NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 		ip6_rcv_finish);
 	return -1;
-#else
-	if (async)
-		return ip6_rcv_finish(skb);
-
-	return 1;
-#endif
 }
 
 int xfrm6_rcv(struct sk_buff *skb)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
