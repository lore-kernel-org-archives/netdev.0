From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/2] [IPSEC]: Add async resume support on input
Date: Wed, 14 Nov 2007 14:28:34 +0800
Message-ID: <20071114062834.GB11173@gondor.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au> <E1IplaD-0001J4-00@gondolin.me.apana.org.au> <20071113.214609.04000914.davem@davemloft.net> <20071114062758.GA11173@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2809 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758431AbXKNG2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 01:28:37 -0500
Content-Disposition: inline
In-Reply-To: <20071114062758.GA11173@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Add async resume support on input

This patch adds support for async resumptions on input.  To do so, the
transform would return -EINPROGRESS and subsequently invoke the function
xfrm_input_resume to resume processing.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h     |    1 +
 net/ipv4/xfrm4_input.c |    3 +++
 net/ipv6/xfrm6_input.c |    3 +++
 net/xfrm/xfrm_input.c  |   38 +++++++++++++++++++++++++++++++++-----
 4 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 8023795..944fdad 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1138,6 +1138,7 @@ extern int xfrm_init_state(struct xfrm_state *x);
 extern int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi,
 		      int encap_type);
+extern int xfrm_input_resume(struct sk_buff *skb, int nexthdr);
 extern int xfrm_output_resume(struct sk_buff *skb, int err);
 extern int xfrm_output(struct sk_buff *skb);
 extern int xfrm4_extract_header(struct sk_buff *skb);
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index b19890f..cd25351 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -61,6 +61,9 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 		xfrm4_rcv_encap_finish);
 	return 0;
 #else
+	if (async)
+		return xfrm4_rcv_encap_finish(skb);
+
 	return -nexthdr;
 #endif
 }
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 5c006c8..e317d08 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -41,6 +41,9 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 		ip6_rcv_finish);
 	return -1;
 #else
+	if (async)
+		return ip6_rcv_finish(skb);
+
 	return 1;
 #endif
 }
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index cce9d45..96f42c1 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -101,8 +101,17 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	int err;
 	__be32 seq;
 	struct xfrm_state *x;
+	xfrm_address_t *daddr;
 	int decaps = 0;
-	unsigned int daddroff = XFRM_SPI_SKB_CB(skb)->daddroff;
+	int async = 0;
+
+	/* A negative encap_type indicates async resumption. */
+	if (encap_type < 0) {
+		async = 1;
+		x = skb->sp->xvec[skb->sp->len - 1];
+		seq = XFRM_SKB_CB(skb)->seq;
+		goto resume;
+	}
 
 	/* Allocate new secpath or COW existing one. */
 	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
@@ -116,6 +125,9 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		skb->sp = sp;
 	}
 
+	daddr = (xfrm_address_t *)(skb_network_header(skb) +
+				   XFRM_SPI_SKB_CB(skb)->daddroff);
+
 	seq = 0;
 	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
 		goto drop;
@@ -124,9 +136,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		if (skb->sp->len == XFRM_MAX_DEPTH)
 			goto drop;
 
-		x = xfrm_state_lookup((xfrm_address_t *)
-				      (skb_network_header(skb) + daddroff),
-				      spi, nexthdr, AF_INET);
+		x = xfrm_state_lookup(daddr, spi, nexthdr, AF_INET);
 		if (x == NULL)
 			goto drop;
 
@@ -147,8 +157,14 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		spin_unlock(&x->lock);
 
+		XFRM_SKB_CB(skb)->seq = seq;
+
 		nexthdr = x->type->input(x, skb);
 
+		if (nexthdr == -EINPROGRESS)
+			return 0;
+
+resume:
 		spin_lock(&x->lock);
 		if (nexthdr <= 0) {
 			if (nexthdr == -EBADMSG)
@@ -177,6 +193,12 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			break;
 		}
 
+		/*
+		 * We need the inner address.  However, we only get here for
+		 * transport mode so the outer address is identical.
+		 */
+		daddr = &x->id.daddr;
+
 		err = xfrm_parse_spi(skb, nexthdr, &spi, &seq);
 		if (err < 0)
 			goto drop;
@@ -190,7 +212,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		netif_rx(skb);
 		return 0;
 	} else {
-		return x->inner_mode->afinfo->transport_finish(skb, 0);
+		return x->inner_mode->afinfo->transport_finish(skb, async);
 	}
 
 drop_unlock:
@@ -201,6 +223,12 @@ drop:
 }
 EXPORT_SYMBOL(xfrm_input);
 
+int xfrm_input_resume(struct sk_buff *skb, int nexthdr)
+{
+	return xfrm_input(skb, nexthdr, 0, -1);
+}
+EXPORT_SYMBOL(xfrm_input_resume);
+
 void __init xfrm_input_init(void)
 {
 	secpath_cachep = kmem_cache_create("secpath_cache",
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
