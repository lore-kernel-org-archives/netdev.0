From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/11] [IPSEC]: Add missing BEET checks
Date: Wed, 17 Oct 2007 22:34:15 +0800
Message-ID: <E1Ii9yR-0006HT-00@gondolin.me.apana.org.au>
References: <20071017142940.GA23879@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1127 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757430AbXJQOeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 10:34:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Add missing BEET checks

Currently BEET mode does not reinject the packet back into the stack
like tunnel mode does.  Since BEET should behave just like tunnel mode
this is incorrect.

This patch fixes this by introducing a flags field to xfrm_mode that
tells the IPsec code whether it should terminate and reinject the packet
back into the stack.

It then sets the flag for BEET and tunnel mode.

I've also added a number of missing BEET checks elsewhere where we check
whether a given mode is a tunnel or not.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h           |    6 ++++++
 net/ipv4/xfrm4_input.c       |    2 +-
 net/ipv4/xfrm4_mode_beet.c   |    1 +
 net/ipv4/xfrm4_mode_tunnel.c |    1 +
 net/ipv4/xfrm4_output.c      |    2 +-
 net/ipv4/xfrm4_policy.c      |    2 +-
 net/ipv6/xfrm6_input.c       |    2 +-
 net/ipv6/xfrm6_mode_beet.c   |    1 +
 net/ipv6/xfrm6_mode_tunnel.c |    1 +
 net/ipv6/xfrm6_output.c      |    2 +-
 net/ipv6/xfrm6_policy.c      |    3 +--
 net/ipv6/xfrm6_state.c       |    6 ++++--
 net/xfrm/xfrm_output.c       |    2 +-
 net/xfrm/xfrm_policy.c       |    6 ++++--
 14 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 7f156a0..2143f29 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -314,6 +314,12 @@ struct xfrm_mode {
 
 	struct module *owner;
 	unsigned int encap;
+	int flags;
+};
+
+/* Flags for xfrm_mode. */
+enum {
+	XFRM_MODE_FLAG_TUNNEL = 1,
 };
 
 extern int xfrm_register_mode(struct xfrm_mode *mode, int family);
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 5cb0b59..bc5dc07 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -94,7 +94,7 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		if (x->mode->input(x, skb))
 			goto drop;
 
-		if (x->props.mode == XFRM_MODE_TUNNEL) {
+		if (x->mode->flags & XFRM_MODE_FLAG_TUNNEL) {
 			decaps = 1;
 			break;
 		}
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index 73d2338..e42e122 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -114,6 +114,7 @@ static struct xfrm_mode xfrm4_beet_mode = {
 	.output = xfrm4_beet_output,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_BEET,
+	.flags = XFRM_MODE_FLAG_TUNNEL,
 };
 
 static int __init xfrm4_beet_init(void)
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 1ae9d32..e4deecb 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -139,6 +139,7 @@ static struct xfrm_mode xfrm4_tunnel_mode = {
 	.output = xfrm4_tunnel_output,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_TUNNEL,
+	.flags = XFRM_MODE_FLAG_TUNNEL,
 };
 
 static int __init xfrm4_tunnel_init(void)
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index a4edd66..dcbc274 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -47,7 +47,7 @@ static inline int xfrm4_output_one(struct sk_buff *skb)
 	struct iphdr *iph;
 	int err;
 
-	if (x->props.mode == XFRM_MODE_TUNNEL) {
+	if (x->mode->flags & XFRM_MODE_FLAG_TUNNEL) {
 		err = xfrm4_tunnel_check_size(skb);
 		if (err)
 			goto error_nolock;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 329825c..2373d67 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -117,7 +117,7 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 
-		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL) {
+		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
 			unsigned short encap_family = xfrm[i]->props.family;
 			switch (encap_family) {
 			case AF_INET:
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index b1201c3..c6ee1a3 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -71,7 +71,7 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 		if (x->mode->input(x, skb))
 			goto drop;
 
-		if (x->props.mode == XFRM_MODE_TUNNEL) { /* XXX */
+		if (x->mode->flags & XFRM_MODE_FLAG_TUNNEL) {
 			decaps = 1;
 			break;
 		}
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index 13bb1e8..2bfb4f0 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -79,6 +79,7 @@ static struct xfrm_mode xfrm6_beet_mode = {
 	.output = xfrm6_beet_output,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_BEET,
+	.flags = XFRM_MODE_FLAG_TUNNEL,
 };
 
 static int __init xfrm6_beet_init(void)
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index ea22838..fd84e22 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -118,6 +118,7 @@ static struct xfrm_mode xfrm6_tunnel_mode = {
 	.output = xfrm6_tunnel_output,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_TUNNEL,
+	.flags = XFRM_MODE_FLAG_TUNNEL,
 };
 
 static int __init xfrm6_tunnel_init(void)
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index a5a32c1..c9f42d1 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -50,7 +50,7 @@ static inline int xfrm6_output_one(struct sk_buff *skb)
 	struct ipv6hdr *iph;
 	int err;
 
-	if (x->props.mode == XFRM_MODE_TUNNEL) {
+	if (x->mode->flags & XFRM_MODE_FLAG_TUNNEL) {
 		err = xfrm6_tunnel_check_size(skb);
 		if (err)
 			goto error_nolock;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 15aa4c5..dc4bdcb 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -178,8 +178,7 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		__xfrm6_bundle_len_inc(&header_len, &nfheader_len, xfrm[i]);
 		trailer_len += xfrm[i]->props.trailer_len;
 
-		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL ||
-		    xfrm[i]->props.mode == XFRM_MODE_ROUTEOPTIMIZATION) {
+		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
 			unsigned short encap_family = xfrm[i]->props.family;
 			switch(encap_family) {
 			case AF_INET:
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index cdadb48..e644c80 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -93,7 +93,8 @@ __xfrm6_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n)
 	/* Rule 4: select IPsec tunnel */
 	for (i = 0; i < n; i++) {
 		if (src[i] &&
-		    src[i]->props.mode == XFRM_MODE_TUNNEL) {
+		    (src[i]->props.mode == XFRM_MODE_TUNNEL ||
+		     src[i]->props.mode == XFRM_MODE_BEET)) {
 			dst[j++] = src[i];
 			src[i] = NULL;
 		}
@@ -146,7 +147,8 @@ __xfrm6_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n)
 	/* Rule 3: select IPsec tunnel */
 	for (i = 0; i < n; i++) {
 		if (src[i] &&
-		    src[i]->mode == XFRM_MODE_TUNNEL) {
+		    (src[i]->mode == XFRM_MODE_TUNNEL ||
+		     src[i]->mode == XFRM_MODE_BEET)) {
 			dst[j++] = src[i];
 			src[i] = NULL;
 		}
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 0eb3377..8bf71ba 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -82,7 +82,7 @@ int xfrm_output(struct sk_buff *skb)
 		}
 		dst = skb->dst;
 		x = dst->xfrm;
-	} while (x && (x->props.mode != XFRM_MODE_TUNNEL));
+	} while (x && !(x->mode->flags & XFRM_MODE_FLAG_TUNNEL));
 
 	err = 0;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ca24c90..1d66fb4 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1940,7 +1940,8 @@ int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
 		if (xdst->genid != dst->xfrm->genid)
 			return 0;
 
-		if (strict && fl && dst->xfrm->props.mode != XFRM_MODE_TUNNEL &&
+		if (strict && fl &&
+		    !(dst->xfrm->mode->flags & XFRM_MODE_FLAG_TUNNEL) &&
 		    !xfrm_state_addr_flow_check(dst->xfrm, fl, family))
 			return 0;
 
@@ -2291,7 +2292,8 @@ static int xfrm_policy_migrate(struct xfrm_policy *pol,
 			if (!migrate_tmpl_match(mp, &pol->xfrm_vec[i]))
 				continue;
 			n++;
-			if (pol->xfrm_vec[i].mode != XFRM_MODE_TUNNEL)
+			if (pol->xfrm_vec[i].mode != XFRM_MODE_TUNNEL &&
+			    pol->xfrm_vec[i].mode != XFRM_MODE_BEET)
 				continue;
 			/* update endpoints */
 			memcpy(&pol->xfrm_vec[i].id.daddr, &mp->new_daddr,
