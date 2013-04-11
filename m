From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] xfrm: allow to avoid copying DSCP during encapsulation
Date: Thu, 11 Apr 2013 09:56:08 +0200
Message-ID: <1365666969-22645-2-git-send-email-steffen.klassert@secunet.com>
References: <1365666969-22645-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56590 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153Ab3DKH4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 03:56:25 -0400
In-Reply-To: <1365666969-22645-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

By default, DSCP is copying during encapsulation.
Copying the DSCP in IPsec tunneling may be a bit dangerous because packets with
different DSCP may get reordered relative to each other in the network and then
dropped by the remote IPsec GW if the reordering becomes too big compared to the
replay window.

It is possible to avoid this copy with netfilter rules, but it's very convenient
to be able to configure it for each SA directly.

This patch adds a toogle for this purpose. By default, it's not set to maintain
backward compatibility.

Field flags in struct xfrm_usersa_info is full, hence I add a new attribute.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h           |    1 +
 include/uapi/linux/xfrm.h    |    3 +++
 net/ipv4/ipcomp.c            |    1 +
 net/ipv4/xfrm4_mode_tunnel.c |    8 ++++++--
 net/ipv6/xfrm6_mode_tunnel.c |    7 +++++--
 net/xfrm/xfrm_state.c        |    1 +
 net/xfrm/xfrm_user.c         |   13 +++++++++++++
 7 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 24c8886..ae16531 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -162,6 +162,7 @@ struct xfrm_state {
 		xfrm_address_t	saddr;
 		int		header_len;
 		int		trailer_len;
+		u32		extra_flags;
 	} props;
 
 	struct xfrm_lifetime_cfg lft;
diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 28e493b..a8cd6a4 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -297,6 +297,7 @@ enum xfrm_attr_type_t {
 	XFRMA_MARK,		/* struct xfrm_mark */
 	XFRMA_TFCPAD,		/* __u32 */
 	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
+	XFRMA_SA_EXTRA_FLAGS,	/* __u32 */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -367,6 +368,8 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_ESN		128
 };
 
+#define XFRM_SA_XFLAG_DONT_ENCAP_DSCP	1
+
 struct xfrm_usersa_id {
 	xfrm_address_t			daddr;
 	__be32				spi;
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index f01d1b1..59cb8c7 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -75,6 +75,7 @@ static struct xfrm_state *ipcomp_tunnel_create(struct xfrm_state *x)
 	t->props.mode = x->props.mode;
 	t->props.saddr.a4 = x->props.saddr.a4;
 	t->props.flags = x->props.flags;
+	t->props.extra_flags = x->props.extra_flags;
 	memcpy(&t->mark, &x->mark, sizeof(t->mark));
 
 	if (xfrm_init_state(t))
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index fe5189e..eb1dd4d 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -103,8 +103,12 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	top_iph->protocol = xfrm_af2proto(skb_dst(skb)->ops->family);
 
-	/* DS disclosed */
-	top_iph->tos = INET_ECN_encapsulate(XFRM_MODE_SKB_CB(skb)->tos,
+	/* DS disclosing depends on XFRM_SA_XFLAG_DONT_ENCAP_DSCP */
+	if (x->props.extra_flags & XFRM_SA_XFLAG_DONT_ENCAP_DSCP)
+		top_iph->tos = 0;
+	else
+		top_iph->tos = XFRM_MODE_SKB_CB(skb)->tos;
+	top_iph->tos = INET_ECN_encapsulate(top_iph->tos,
 					    XFRM_MODE_SKB_CB(skb)->tos);
 
 	flags = x->props.flags;
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 9bf6a74..4770d51 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -49,8 +49,11 @@ static int xfrm6_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	       sizeof(top_iph->flow_lbl));
 	top_iph->nexthdr = xfrm_af2proto(skb_dst(skb)->ops->family);
 
-	dsfield = XFRM_MODE_SKB_CB(skb)->tos;
-	dsfield = INET_ECN_encapsulate(dsfield, dsfield);
+	if (x->props.extra_flags & XFRM_SA_XFLAG_DONT_ENCAP_DSCP)
+		dsfield = 0;
+	else
+		dsfield = XFRM_MODE_SKB_CB(skb)->tos;
+	dsfield = INET_ECN_encapsulate(dsfield, XFRM_MODE_SKB_CB(skb)->tos);
 	if (x->props.flags & XFRM_STATE_NOECN)
 		dsfield &= ~INET_ECN_MASK;
 	ipv6_change_dsfield(top_iph, 0, dsfield);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 2c341bd..78f66fa 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1187,6 +1187,7 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 		goto error;
 
 	x->props.flags = orig->props.flags;
+	x->props.extra_flags = orig->props.extra_flags;
 
 	x->curlft.add_time = orig->curlft.add_time;
 	x->km.state = orig->km.state;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index fbd9e6c..204cba1 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -515,6 +515,9 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 
 	copy_from_user_state(x, p);
 
+	if (attrs[XFRMA_SA_EXTRA_FLAGS])
+		x->props.extra_flags = nla_get_u32(attrs[XFRMA_SA_EXTRA_FLAGS]);
+
 	if ((err = attach_aead(&x->aead, &x->props.ealgo,
 			       attrs[XFRMA_ALG_AEAD])))
 		goto error;
@@ -779,6 +782,13 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 
 	copy_to_user_state(x, p);
 
+	if (x->props.extra_flags) {
+		ret = nla_put_u32(skb, XFRMA_SA_EXTRA_FLAGS,
+				  x->props.extra_flags);
+		if (ret)
+			goto out;
+	}
+
 	if (x->coaddr) {
 		ret = nla_put(skb, XFRMA_COADDR, sizeof(*x->coaddr), x->coaddr);
 		if (ret)
@@ -2302,6 +2312,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_MARK]		= { .len = sizeof(struct xfrm_mark) },
 	[XFRMA_TFCPAD]		= { .type = NLA_U32 },
 	[XFRMA_REPLAY_ESN_VAL]	= { .len = sizeof(struct xfrm_replay_state_esn) },
+	[XFRMA_SA_EXTRA_FLAGS]	= { .type = NLA_U32 },
 };
 
 static struct xfrm_link {
@@ -2495,6 +2506,8 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 				    x->security->ctx_len);
 	if (x->coaddr)
 		l += nla_total_size(sizeof(*x->coaddr));
+	if (x->props.extra_flags)
+		l += nla_total_size(sizeof(x->props.extra_flags));
 
 	/* Must count x->lastused as it may become non-zero behind our back. */
 	l += nla_total_size(sizeof(u64));
-- 
1.7.9.5
