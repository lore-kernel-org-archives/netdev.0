From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 22/24] [IPSEC]: Store xfrm states in security path directly
Date: Wed, 07 Nov 2007 22:08:39 +0800
Message-ID: <E1IplaB-0001In-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3756 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758020AbXKGO0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:26:23 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Store xfrm states in security path directly

As it is xfrm_input first collects a list of xfrm states on the stack
before storing them in the packet's security path just before it returns.
For async crypto, this construction presents an obstacle since we may
need to leave the loop after each transform.

In fact, it's much easier to just skip the stack completely and always
store to the security path.  This is proven by the fact that this patch
actually shrinks the code.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/xfrm/xfrm_input.c |   42 +++++++++++++++---------------------------
 1 files changed, 15 insertions(+), 27 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index b980095..587f347 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -100,19 +100,29 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 {
 	int err;
 	__be32 seq;
-	struct xfrm_state *xfrm_vec[XFRM_MAX_DEPTH];
 	struct xfrm_state *x;
-	int xfrm_nr = 0;
 	int decaps = 0;
 	unsigned int nhoff = XFRM_SPI_SKB_CB(skb)->nhoff;
 	unsigned int daddroff = XFRM_SPI_SKB_CB(skb)->daddroff;
 
+	/* Allocate new secpath or COW existing one. */
+	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
+		struct sec_path *sp;
+
+		sp = secpath_dup(skb->sp);
+		if (!sp)
+			goto drop;
+		if (skb->sp)
+			secpath_put(skb->sp);
+		skb->sp = sp;
+	}
+
 	seq = 0;
 	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
 		goto drop;
 
 	do {
-		if (xfrm_nr == XFRM_MAX_DEPTH)
+		if (skb->sp->len == XFRM_MAX_DEPTH)
 			goto drop;
 
 		x = xfrm_state_lookup((xfrm_address_t *)
@@ -121,6 +131,8 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		if (x == NULL)
 			goto drop;
 
+		skb->sp->xvec[skb->sp->len++] = x;
+
 		spin_lock(&x->lock);
 		if (unlikely(x->km.state != XFRM_STATE_VALID))
 			goto drop_unlock;
@@ -151,8 +163,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		spin_unlock(&x->lock);
 
-		xfrm_vec[xfrm_nr++] = x;
-
 		if (x->inner_mode->input(x, skb))
 			goto drop;
 
@@ -166,24 +176,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop;
 	} while (!err);
 
-	/* Allocate new secpath or COW existing one. */
-
-	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
-		struct sec_path *sp;
-		sp = secpath_dup(skb->sp);
-		if (!sp)
-			goto drop;
-		if (skb->sp)
-			secpath_put(skb->sp);
-		skb->sp = sp;
-	}
-	if (xfrm_nr + skb->sp->len > XFRM_MAX_DEPTH)
-		goto drop;
-
-	memcpy(skb->sp->xvec + skb->sp->len, xfrm_vec,
-	       xfrm_nr * sizeof(xfrm_vec[0]));
-	skb->sp->len += xfrm_nr;
-
 	nf_reset(skb);
 
 	if (decaps) {
@@ -197,11 +189,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 drop_unlock:
 	spin_unlock(&x->lock);
-	xfrm_state_put(x);
 drop:
-	while (--xfrm_nr >= 0)
-		xfrm_state_put(xfrm_vec[xfrm_nr]);
-
 	kfree_skb(skb);
 	return 0;
 }
