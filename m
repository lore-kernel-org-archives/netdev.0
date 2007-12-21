From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH] [XFRM] MIPv6: Fix to input RO state correctly.
Date: Fri, 21 Dec 2007 12:40:48 +0900
Message-ID: <11982084484155-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:58061 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755248AbXLUEJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:09:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable spin_lock during xfrm_type.input() function.
Follow design as IPsec inbound does.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/ipv6/xfrm6_input.c |   54 +++++++++++++++++++++++++----------------------
 1 files changed, 29 insertions(+), 25 deletions(-)

diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 74f3aac..f835ab4 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -63,10 +63,26 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 	struct xfrm_state *x = NULL;
 	int wildcard = 0;
 	xfrm_address_t *xany;
-	struct xfrm_state *xfrm_vec_one = NULL;
 	int nh = 0;
 	int i = 0;
 
+	/* Allocate new secpath or COW existing one. */
+	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
+		struct sec_path *sp;
+
+		sp = secpath_dup(skb->sp);
+		if (!sp) {
+			goto drop;
+		}
+		if (skb->sp)
+			secpath_put(skb->sp);
+		skb->sp = sp;
+	}
+
+	if (1 + skb->sp->len == XFRM_MAX_DEPTH) {
+		goto drop;
+	}
+
 	xany = (xfrm_address_t *)&in6addr_any;
 
 	for (i = 0; i < 3; i++) {
@@ -119,47 +135,35 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 			continue;
 		}
 
+		spin_unlock(&x->lock);
+
 		nh = x->type->input(x, skb);
 		if (nh <= 0) {
-			spin_unlock(&x->lock);
 			xfrm_state_put(x);
 			x = NULL;
 			continue;
 		}
 
-		x->curlft.bytes += skb->len;
-		x->curlft.packets++;
-
-		spin_unlock(&x->lock);
-
-		xfrm_vec_one = x;
+		/* Found a state */
 		break;
 	}
 
-	if (!xfrm_vec_one)
+	if (!x) {
 		goto drop;
-
-	/* Allocate new secpath or COW existing one. */
-	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
-		struct sec_path *sp;
-		sp = secpath_dup(skb->sp);
-		if (!sp)
-			goto drop;
-		if (skb->sp)
-			secpath_put(skb->sp);
-		skb->sp = sp;
 	}
 
-	if (1 + skb->sp->len > XFRM_MAX_DEPTH)
-		goto drop;
+	skb->sp->xvec[skb->sp->len++] = x;
+
+	spin_lock(&x->lock);
 
-	skb->sp->xvec[skb->sp->len] = xfrm_vec_one;
-	skb->sp->len ++;
+	x->curlft.bytes += skb->len;
+	x->curlft.packets++;
+
+	spin_unlock(&x->lock);
 
 	return 1;
+
 drop:
-	if (xfrm_vec_one)
-		xfrm_state_put(xfrm_vec_one);
 	return -1;
 }
 
-- 
1.4.4.2

