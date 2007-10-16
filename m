From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 10/12] [IPSEC]: Disallow combinations of RO and AH/ESP/IPCOMP
Date: Tue, 16 Oct 2007 22:33:18 +0800
Message-ID: <E1IhnTy-0003HM-00@gondolin.me.apana.org.au>
References: <20071016141843.GA11956@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3003 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932828AbXJPOxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:53:48 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1Ihnnk-0001GY-Rl
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 00:53:45 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Disallow combinations of RO and AH/ESP/IPCOMP

Combining RO and AH/ESP/IPCOMP does not make sense.  So this patch adds a
check in the state initialisation function to prevent this.

This allows us to safely remove the mode input function of RO since it
can never be called anymore.  Indeed, if somehow it does get called we'll
know about it through an OOPS instead of it slipping past silently.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/ah6.c           |    9 ++++++++-
 net/ipv6/esp6.c          |    9 ++++++++-
 net/ipv6/ipcomp6.c       |    9 ++++++++-
 net/ipv6/xfrm6_mode_ro.c |    9 ---------
 4 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index a8221d1..67cd066 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -477,8 +477,15 @@ static int ah6_init_state(struct xfrm_state *x)
 
 	x->props.header_len = XFRM_ALIGN8(sizeof(struct ip_auth_hdr) +
 					  ahp->icv_trunc_len);
-	if (x->props.mode == XFRM_MODE_TUNNEL)
+	switch (x->props.mode) {
+	case XFRM_MODE_BEET:
+	case XFRM_MODE_TRANSPORT:
+		break;
+	case XFRM_MODE_TUNNEL:
 		x->props.header_len += sizeof(struct ipv6hdr);
+	default:
+		goto error;
+	}
 	x->data = ahp;
 
 	return 0;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 9eb9285..b071543 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -354,8 +354,15 @@ static int esp6_init_state(struct xfrm_state *x)
 				    (x->ealg->alg_key_len + 7) / 8))
 		goto error;
 	x->props.header_len = sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
-	if (x->props.mode == XFRM_MODE_TUNNEL)
+	switch (x->props.mode) {
+	case XFRM_MODE_BEET:
+	case XFRM_MODE_TRANSPORT:
+		break;
+	case XFRM_MODE_TUNNEL:
 		x->props.header_len += sizeof(struct ipv6hdr);
+	default:
+		goto error;
+	}
 	x->data = esp;
 	return 0;
 
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 28fc8ed..80ef2a1 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -411,8 +411,15 @@ static int ipcomp6_init_state(struct xfrm_state *x)
 		goto out;
 
 	x->props.header_len = 0;
-	if (x->props.mode == XFRM_MODE_TUNNEL)
+	switch (x->props.mode) {
+	case XFRM_MODE_BEET:
+	case XFRM_MODE_TRANSPORT:
+		break;
+	case XFRM_MODE_TUNNEL:
 		x->props.header_len += sizeof(struct ipv6hdr);
+	default:
+		goto error;
+	}
 
 	mutex_lock(&ipcomp6_resource_mutex);
 	if (!ipcomp6_alloc_scratches())
diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
index 957ae36..a7bc8c6 100644
--- a/net/ipv6/xfrm6_mode_ro.c
+++ b/net/ipv6/xfrm6_mode_ro.c
@@ -58,16 +58,7 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 	return 0;
 }
 
-/*
- * Do nothing about routing optimization header unlike IPsec.
- */
-static int xfrm6_ro_input(struct xfrm_state *x, struct sk_buff *skb)
-{
-	return 0;
-}
-
 static struct xfrm_mode xfrm6_ro_mode = {
-	.input = xfrm6_ro_input,
 	.output = xfrm6_ro_output,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_ROUTEOPTIMIZATION,
