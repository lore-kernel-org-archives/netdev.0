From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 14/16] xfrm: Prepare the GRO codepath for hardware offloading.
Date: Thu, 20 Apr 2017 10:55:13 +0200
Message-ID: <1492678515-14347-15-git-send-email-steffen.klassert@secunet.com>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51666 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S970099AbdDTI5r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 04:57:47 -0400
In-Reply-To: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On IPsec hardware offloading, we already get a secpath with
valid state attached when the packet enters the GRO handlers.
So check for hardware offload and skip the state lookup in this
case.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4_offload.c | 42 ++++++++++++++++++++++-------------------
 net/ipv6/esp6_offload.c | 42 ++++++++++++++++++++++-------------------
 net/xfrm/xfrm_input.c   | 50 ++++++++++++++++++++++++-------------------------
 3 files changed, 71 insertions(+), 63 deletions(-)

diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
index 1e39564..f3e33c2 100644
--- a/net/ipv4/esp4_offload.c
+++ b/net/ipv4/esp4_offload.c
@@ -43,27 +43,31 @@ static struct sk_buff **esp4_gro_receive(struct sk_buff **head,
 	if ((err = xfrm_parse_spi(skb, IPPROTO_ESP, &spi, &seq)) != 0)
 		goto out;
 
-	err = secpath_set(skb);
-	if (err)
-		goto out;
-
-	if (skb->sp->len == XFRM_MAX_DEPTH)
-		goto out;
-
-	x = xfrm_state_lookup(dev_net(skb->dev), skb->mark,
-			      (xfrm_address_t *)&ip_hdr(skb)->daddr,
-			      spi, IPPROTO_ESP, AF_INET);
-	if (!x)
-		goto out;
-
-	skb->sp->xvec[skb->sp->len++] = x;
-	skb->sp->olen++;
-
 	xo = xfrm_offload(skb);
-	if (!xo) {
-		xfrm_state_put(x);
-		goto out;
+	if (!xo || !(xo->flags & CRYPTO_DONE)) {
+		err = secpath_set(skb);
+		if (err)
+			goto out;
+
+		if (skb->sp->len == XFRM_MAX_DEPTH)
+			goto out;
+
+		x = xfrm_state_lookup(dev_net(skb->dev), skb->mark,
+				      (xfrm_address_t *)&ip_hdr(skb)->daddr,
+				      spi, IPPROTO_ESP, AF_INET);
+		if (!x)
+			goto out;
+
+		skb->sp->xvec[skb->sp->len++] = x;
+		skb->sp->olen++;
+
+		xo = xfrm_offload(skb);
+		if (!xo) {
+			xfrm_state_put(x);
+			goto out;
+		}
 	}
+
 	xo->flags |= XFRM_GRO;
 
 	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = NULL;
diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
index 06e9721..1cceeee 100644
--- a/net/ipv6/esp6_offload.c
+++ b/net/ipv6/esp6_offload.c
@@ -45,27 +45,31 @@ static struct sk_buff **esp6_gro_receive(struct sk_buff **head,
 	if ((err = xfrm_parse_spi(skb, IPPROTO_ESP, &spi, &seq)) != 0)
 		goto out;
 
-	err = secpath_set(skb);
-	if (err)
-		goto out;
-
-	if (skb->sp->len == XFRM_MAX_DEPTH)
-		goto out;
-
-	x = xfrm_state_lookup(dev_net(skb->dev), skb->mark,
-			      (xfrm_address_t *)&ipv6_hdr(skb)->daddr,
-			      spi, IPPROTO_ESP, AF_INET6);
-	if (!x)
-		goto out;
-
-	skb->sp->xvec[skb->sp->len++] = x;
-	skb->sp->olen++;
-
 	xo = xfrm_offload(skb);
-	if (!xo) {
-		xfrm_state_put(x);
-		goto out;
+	if (!xo || !(xo->flags & CRYPTO_DONE)) {
+		err = secpath_set(skb);
+		if (err)
+			goto out;
+
+		if (skb->sp->len == XFRM_MAX_DEPTH)
+			goto out;
+
+		x = xfrm_state_lookup(dev_net(skb->dev), skb->mark,
+				      (xfrm_address_t *)&ipv6_hdr(skb)->daddr,
+				      spi, IPPROTO_ESP, AF_INET6);
+		if (!x)
+			goto out;
+
+		skb->sp->xvec[skb->sp->len++] = x;
+		skb->sp->olen++;
+
+		xo = xfrm_offload(skb);
+		if (!xo) {
+			xfrm_state_put(x);
+			goto out;
+		}
 	}
+
 	xo->flags |= XFRM_GRO;
 
 	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 = NULL;
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 362d655..21c6cc9 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -223,38 +223,38 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			seq = XFRM_SKB_CB(skb)->seq.input.low;
 			goto resume;
 		}
+
 		/* encap_type < -1 indicates a GRO call. */
 		encap_type = 0;
 		seq = XFRM_SPI_SKB_CB(skb)->seq;
-		goto lock;
-	}
-
-	if (xo && (xo->flags & CRYPTO_DONE)) {
-		crypto_done = true;
-		x = xfrm_input_state(skb);
-		family = XFRM_SPI_SKB_CB(skb)->family;
 
-		if (!(xo->status & CRYPTO_SUCCESS)) {
-			if (xo->status &
-			    (CRYPTO_TRANSPORT_AH_AUTH_FAILED |
-			     CRYPTO_TRANSPORT_ESP_AUTH_FAILED |
-			     CRYPTO_TUNNEL_AH_AUTH_FAILED |
-			     CRYPTO_TUNNEL_ESP_AUTH_FAILED)) {
-
-				xfrm_audit_state_icvfail(x, skb,
-							 x->type->proto);
-				x->stats.integrity_failed++;
-				XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEPROTOERROR);
+		if (xo && (xo->flags & CRYPTO_DONE)) {
+			crypto_done = true;
+			x = xfrm_input_state(skb);
+			family = XFRM_SPI_SKB_CB(skb)->family;
+
+			if (!(xo->status & CRYPTO_SUCCESS)) {
+				if (xo->status &
+				    (CRYPTO_TRANSPORT_AH_AUTH_FAILED |
+				     CRYPTO_TRANSPORT_ESP_AUTH_FAILED |
+				     CRYPTO_TUNNEL_AH_AUTH_FAILED |
+				     CRYPTO_TUNNEL_ESP_AUTH_FAILED)) {
+
+					xfrm_audit_state_icvfail(x, skb,
+								 x->type->proto);
+					x->stats.integrity_failed++;
+					XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEPROTOERROR);
+					goto drop;
+				}
+
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMINBUFFERERROR);
 				goto drop;
 			}
 
-			XFRM_INC_STATS(net, LINUX_MIB_XFRMINBUFFERERROR);
-			goto drop;
-		}
-
-		if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0) {
-			XFRM_INC_STATS(net, LINUX_MIB_XFRMINHDRERROR);
-			goto drop;
+			if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0) {
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMINHDRERROR);
+				goto drop;
+			}
 		}
 
 		goto lock;
-- 
2.7.4
