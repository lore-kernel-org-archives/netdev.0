From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 12/24] [IPSEC]: Forbid BEET + ipcomp for now
Date: Wed, 07 Nov 2007 22:08:28 +0800
Message-ID: <E1Ipla0-0001HT-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3560 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758570AbXKGOIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:08:46 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Forbid BEET + ipcomp for now

While BEET can theoretically work with IPComp the current code can't do that
because it tries to construct a BEET mode tunnel type which doesn't (and
cannot) exist.  In fact as it is it won't even attach a tunnel object at
all for BEET which is bogus.

To support this fully we'd also need to change the policy checks on input
to recognise a plain tunnel as a legal variant of an optional BEET transform.

This patch simply fails such constructions for now.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/ipcomp.c  |   20 ++++++++++++--------
 net/ipv6/ipcomp6.c |   19 ++++++++-----------
 2 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index ca1b5fd..afcdbf4 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -181,7 +181,6 @@ static void ipcomp4_err(struct sk_buff *skb, u32 info)
 static struct xfrm_state *ipcomp_tunnel_create(struct xfrm_state *x)
 {
 	struct xfrm_state *t;
-	u8 mode = XFRM_MODE_TUNNEL;
 
 	t = xfrm_state_alloc();
 	if (t == NULL)
@@ -192,9 +191,7 @@ static struct xfrm_state *ipcomp_tunnel_create(struct xfrm_state *x)
 	t->id.daddr.a4 = x->id.daddr.a4;
 	memcpy(&t->sel, &x->sel, sizeof(t->sel));
 	t->props.family = AF_INET;
-	if (x->props.mode == XFRM_MODE_BEET)
-		mode = x->props.mode;
-	t->props.mode = mode;
+	t->props.mode = x->props.mode;
 	t->props.saddr.a4 = x->props.saddr.a4;
 	t->props.flags = x->props.flags;
 
@@ -388,15 +385,22 @@ static int ipcomp_init_state(struct xfrm_state *x)
 	if (x->encap)
 		goto out;
 
+	x->props.header_len = 0;
+	switch (x->props.mode) {
+	case XFRM_MODE_TRANSPORT:
+		break;
+	case XFRM_MODE_TUNNEL:
+		x->props.header_len += sizeof(struct iphdr);
+		break;
+	default:
+		goto out;
+	}
+
 	err = -ENOMEM;
 	ipcd = kzalloc(sizeof(*ipcd), GFP_KERNEL);
 	if (!ipcd)
 		goto out;
 
-	x->props.header_len = 0;
-	if (x->props.mode == XFRM_MODE_TUNNEL)
-		x->props.header_len += sizeof(struct iphdr);
-
 	mutex_lock(&ipcomp_resource_mutex);
 	if (!ipcomp_alloc_scratches())
 		goto error;
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 85eb479..eca0595 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -189,7 +189,6 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 static struct xfrm_state *ipcomp6_tunnel_create(struct xfrm_state *x)
 {
 	struct xfrm_state *t = NULL;
-	u8 mode = XFRM_MODE_TUNNEL;
 
 	t = xfrm_state_alloc();
 	if (!t)
@@ -203,9 +202,7 @@ static struct xfrm_state *ipcomp6_tunnel_create(struct xfrm_state *x)
 	memcpy(t->id.daddr.a6, x->id.daddr.a6, sizeof(struct in6_addr));
 	memcpy(&t->sel, &x->sel, sizeof(t->sel));
 	t->props.family = AF_INET6;
-	if (x->props.mode == XFRM_MODE_BEET)
-		mode = x->props.mode;
-	t->props.mode = mode;
+	t->props.mode = x->props.mode;
 	memcpy(t->props.saddr.a6, x->props.saddr.a6, sizeof(struct in6_addr));
 
 	if (xfrm_init_state(t))
@@ -404,22 +401,22 @@ static int ipcomp6_init_state(struct xfrm_state *x)
 	if (x->encap)
 		goto out;
 
-	err = -ENOMEM;
-	ipcd = kzalloc(sizeof(*ipcd), GFP_KERNEL);
-	if (!ipcd)
-		goto out;
-
 	x->props.header_len = 0;
 	switch (x->props.mode) {
-	case XFRM_MODE_BEET:
 	case XFRM_MODE_TRANSPORT:
 		break;
 	case XFRM_MODE_TUNNEL:
 		x->props.header_len += sizeof(struct ipv6hdr);
+		break;
 	default:
-		goto error;
+		goto out;
 	}
 
+	err = -ENOMEM;
+	ipcd = kzalloc(sizeof(*ipcd), GFP_KERNEL);
+	if (!ipcd)
+		goto out;
+
 	mutex_lock(&ipcomp6_resource_mutex);
 	if (!ipcomp6_alloc_scratches())
 		goto error;
