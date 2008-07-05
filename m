From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH v2] xfrm: Fix inter family IPsec tunnel handling again
Date: Sat, 5 Jul 2008 09:19:50 +0200
Message-ID: <20080705071950.GA26532@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:59769 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750848AbYGEHT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jul 2008 03:19:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the selector family initialization behind the check for AF_UNSPEC
and call xfrm_ip2inner_mode() in any case. So the selector family is
intitalized and we can choose for the right inner_mode.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c |   19 ++++---------------
 net/xfrm/xfrm_state.c |    2 ++
 net/xfrm/xfrm_user.c  |    4 ----
 3 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 7527940..d220ecf 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -91,11 +91,9 @@ int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb)
 	if (err)
 		return err;
 
-	if (x->sel.family == AF_UNSPEC) {
-		inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
-		if (inner_mode == NULL)
-			return -EAFNOSUPPORT;
-	}
+	inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
+	if (inner_mode == NULL)
+		return -EAFNOSUPPORT;
 
 	skb->protocol = inner_mode->afinfo->eth_proto;
 	return inner_mode->input2(x, skb);
@@ -108,7 +106,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	__be32 seq;
 	struct xfrm_state *x;
 	xfrm_address_t *daddr;
-	struct xfrm_mode *inner_mode;
 	unsigned int family;
 	int decaps = 0;
 	int async = 0;
@@ -215,15 +212,7 @@ resume:
 
 		XFRM_MODE_SKB_CB(skb)->protocol = nexthdr;
 
-		inner_mode = x->inner_mode;
-
-		if (x->sel.family == AF_UNSPEC) {
-			inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
-			if (inner_mode == NULL)
-				goto drop;
-		}
-
-		if (inner_mode->input(x, skb)) {
+		if (x->inner_mode->input(x, skb)) {
 			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEMODEERROR);
 			goto drop;
 		}
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 72fddaf..9ea1008 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2030,6 +2030,8 @@ int xfrm_init_state(struct xfrm_state *x)
 			x->inner_mode = inner_mode_iaf;
 			x->inner_mode_iaf = inner_mode;
 		}
+
+		x->sel.family = family;
 	}
 
 	x->type = xfrm_get_type(x->id.proto, family);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index b976d9e..dae0956 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -276,10 +276,6 @@ static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *
 	x->props.family = p->family;
 	memcpy(&x->props.saddr, &p->saddr, sizeof(x->props.saddr));
 	x->props.flags = p->flags;
-
-	if (!x->sel.family)
-		x->sel.family = p->family;
-
 }
 
 /*
-- 
1.5.3

