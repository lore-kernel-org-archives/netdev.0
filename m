From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 2/3] xfrm: Store aalg in xfrm_state with a user specified truncation length
Date: Wed, 25 Nov 2009 11:29:52 +0100
Message-ID: <1bc7bcf0473c908d7df0333c799302b0ee7dc059.1259142145.git.martin@strongswan.org>
References: <cover.1259142145.git.martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaes.ch ([213.133.111.41]:55419 "EHLO zaes.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758592AbZKYKxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2009 05:53:34 -0500
In-Reply-To: <cover.1259142145.git.martin@strongswan.org>
In-Reply-To: <cover.1259142145.git.martin@strongswan.org>
References: <cover.1259142145.git.martin@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a xfrm_state requires an authentication algorithm specified
either as xfrm_algo or as xfrm_algo_auth with a specific truncation
length. For compatibility, both attributes are dumped to userspace,
and we also accept both attributes, but prefer the new syntax.

If no truncation length is specified, or the authentication algorithm
is specified using xfrm_algo, the truncation length from the algorithm
description in the kernel is used.

Signed-off-by: Martin Willi <martin@strongswan.org>
---
 include/net/xfrm.h    |   12 ++++-
 net/xfrm/xfrm_state.c |    2 +-
 net/xfrm/xfrm_user.c  |  129 ++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 133 insertions(+), 10 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 223e90a..762327d 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -160,7 +160,7 @@ struct xfrm_state
 	struct xfrm_lifetime_cfg lft;
 
 	/* Data for transformer */
-	struct xfrm_algo	*aalg;
+	struct xfrm_algo_auth	*aalg;
 	struct xfrm_algo	*ealg;
 	struct xfrm_algo	*calg;
 	struct xfrm_algo_aead	*aead;
@@ -1541,12 +1541,22 @@ static inline int xfrm_alg_len(struct xfrm_algo *alg)
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
 
+static inline int xfrm_alg_auth_len(struct xfrm_algo_auth *alg)
+{
+	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
+}
+
 #ifdef CONFIG_XFRM_MIGRATE
 static inline struct xfrm_algo *xfrm_algo_clone(struct xfrm_algo *orig)
 {
 	return kmemdup(orig, xfrm_alg_len(orig), GFP_KERNEL);
 }
 
+static inline struct xfrm_algo_auth *xfrm_algo_auth_clone(struct xfrm_algo_auth *orig)
+{
+	return kmemdup(orig, xfrm_alg_auth_len(orig), GFP_KERNEL);
+}
+
 static inline void xfrm_states_put(struct xfrm_state **states, int n)
 {
 	int i;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f2f7c63..67121ce 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1110,7 +1110,7 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 	x->props.saddr = orig->props.saddr;
 
 	if (orig->aalg) {
-		x->aalg = xfrm_algo_clone(orig->aalg);
+		x->aalg = xfrm_algo_auth_clone(orig->aalg);
 		if (!x->aalg)
 			goto error;
 	}
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index b95a2d6..fb42d77 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -62,6 +62,22 @@ static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 	return 0;
 }
 
+static int verify_auth_trunc(struct nlattr **attrs)
+{
+	struct nlattr *rt = attrs[XFRMA_ALG_AUTH_TRUNC];
+	struct xfrm_algo_auth *algp;
+
+	if (!rt)
+		return 0;
+
+	algp = nla_data(rt);
+	if (nla_len(rt) < xfrm_alg_auth_len(algp))
+		return -EINVAL;
+
+	algp->alg_name[CRYPTO_MAX_ALG_NAME - 1] = '\0';
+	return 0;
+}
+
 static int verify_aead(struct nlattr **attrs)
 {
 	struct nlattr *rt = attrs[XFRMA_ALG_AEAD];
@@ -128,7 +144,8 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 	err = -EINVAL;
 	switch (p->id.proto) {
 	case IPPROTO_AH:
-		if (!attrs[XFRMA_ALG_AUTH]	||
+		if ((!attrs[XFRMA_ALG_AUTH]	&&
+		     !attrs[XFRMA_ALG_AUTH_TRUNC]) ||
 		    attrs[XFRMA_ALG_AEAD]	||
 		    attrs[XFRMA_ALG_CRYPT]	||
 		    attrs[XFRMA_ALG_COMP])
@@ -139,10 +156,12 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		if (attrs[XFRMA_ALG_COMP])
 			goto out;
 		if (!attrs[XFRMA_ALG_AUTH] &&
+		    !attrs[XFRMA_ALG_AUTH_TRUNC] &&
 		    !attrs[XFRMA_ALG_CRYPT] &&
 		    !attrs[XFRMA_ALG_AEAD])
 			goto out;
 		if ((attrs[XFRMA_ALG_AUTH] ||
+		     attrs[XFRMA_ALG_AUTH_TRUNC] ||
 		     attrs[XFRMA_ALG_CRYPT]) &&
 		    attrs[XFRMA_ALG_AEAD])
 			goto out;
@@ -152,6 +171,7 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		if (!attrs[XFRMA_ALG_COMP]	||
 		    attrs[XFRMA_ALG_AEAD]	||
 		    attrs[XFRMA_ALG_AUTH]	||
+		    attrs[XFRMA_ALG_AUTH_TRUNC]	||
 		    attrs[XFRMA_ALG_CRYPT])
 			goto out;
 		break;
@@ -161,6 +181,7 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 	case IPPROTO_ROUTING:
 		if (attrs[XFRMA_ALG_COMP]	||
 		    attrs[XFRMA_ALG_AUTH]	||
+		    attrs[XFRMA_ALG_AUTH_TRUNC]	||
 		    attrs[XFRMA_ALG_AEAD]	||
 		    attrs[XFRMA_ALG_CRYPT]	||
 		    attrs[XFRMA_ENCAP]		||
@@ -176,6 +197,8 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 
 	if ((err = verify_aead(attrs)))
 		goto out;
+	if ((err = verify_auth_trunc(attrs)))
+		goto out;
 	if ((err = verify_one_alg(attrs, XFRMA_ALG_AUTH)))
 		goto out;
 	if ((err = verify_one_alg(attrs, XFRMA_ALG_CRYPT)))
@@ -229,6 +252,66 @@ static int attach_one_algo(struct xfrm_algo **algpp, u8 *props,
 	return 0;
 }
 
+static int attach_auth(struct xfrm_algo_auth **algpp, u8 *props,
+		       struct nlattr *rta)
+{
+	struct xfrm_algo *ualg;
+	struct xfrm_algo_auth *p;
+	struct xfrm_algo_desc *algo;
+
+	if (!rta)
+		return 0;
+
+	ualg = nla_data(rta);
+
+	algo = xfrm_aalg_get_byname(ualg->alg_name, 1);
+	if (!algo)
+		return -ENOSYS;
+	*props = algo->desc.sadb_alg_id;
+
+	p = kmalloc(sizeof(*p) + (ualg->alg_key_len + 7) / 8, GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	strcpy(p->alg_name, algo->name);
+	p->alg_key_len = ualg->alg_key_len;
+	p->alg_trunc_len = algo->uinfo.auth.icv_truncbits;
+	memcpy(p->alg_key, ualg->alg_key, (ualg->alg_key_len + 7) / 8);
+
+	*algpp = p;
+	return 0;
+}
+
+static int attach_auth_trunc(struct xfrm_algo_auth **algpp, u8 *props,
+			     struct nlattr *rta)
+{
+	struct xfrm_algo_auth *p, *ualg;
+	struct xfrm_algo_desc *algo;
+
+	if (!rta)
+		return 0;
+
+	ualg = nla_data(rta);
+
+	algo = xfrm_aalg_get_byname(ualg->alg_name, 1);
+	if (!algo)
+		return -ENOSYS;
+	if (ualg->alg_trunc_len > algo->uinfo.auth.icv_fullbits)
+		return -EINVAL;
+	*props = algo->desc.sadb_alg_id;
+
+	p = kmemdup(ualg, xfrm_alg_auth_len(ualg), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	strcpy(p->alg_name, algo->name);
+	if (!p->alg_trunc_len)
+		p->alg_trunc_len = algo->uinfo.auth.icv_truncbits;
+
+	*algpp = p;
+	return 0;
+}
+
 static int attach_aead(struct xfrm_algo_aead **algpp, u8 *props,
 		       struct nlattr *rta)
 {
@@ -332,10 +415,14 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 	if ((err = attach_aead(&x->aead, &x->props.ealgo,
 			       attrs[XFRMA_ALG_AEAD])))
 		goto error;
-	if ((err = attach_one_algo(&x->aalg, &x->props.aalgo,
-				   xfrm_aalg_get_byname,
-				   attrs[XFRMA_ALG_AUTH])))
+	if ((err = attach_auth_trunc(&x->aalg, &x->props.aalgo,
+				     attrs[XFRMA_ALG_AUTH_TRUNC])))
 		goto error;
+	if (!x->props.aalgo) {
+		if ((err = attach_auth(&x->aalg, &x->props.aalgo,
+				       attrs[XFRMA_ALG_AUTH])))
+			goto error;
+	}
 	if ((err = attach_one_algo(&x->ealg, &x->props.ealgo,
 				   xfrm_ealg_get_byname,
 				   attrs[XFRMA_ALG_CRYPT])))
@@ -548,6 +635,24 @@ static int copy_sec_ctx(struct xfrm_sec_ctx *s, struct sk_buff *skb)
 	return 0;
 }
 
+static int copy_to_user_auth(struct xfrm_algo_auth *auth, struct sk_buff *skb)
+{
+	struct xfrm_algo *algo;
+	struct nlattr *nla;
+
+	nla = nla_reserve(skb, XFRMA_ALG_AUTH,
+			  sizeof(*algo) + (auth->alg_key_len + 7) / 8);
+	if (!nla)
+		return -EMSGSIZE;
+
+	algo = nla_data(nla);
+	strcpy(algo->alg_name, auth->alg_name);
+	memcpy(algo->alg_key, auth->alg_key, (auth->alg_key_len + 7) / 8);
+	algo->alg_key_len = auth->alg_key_len;
+
+	return 0;
+}
+
 /* Don't change this without updating xfrm_sa_len! */
 static int copy_to_user_state_extra(struct xfrm_state *x,
 				    struct xfrm_usersa_info *p,
@@ -563,8 +668,13 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 
 	if (x->aead)
 		NLA_PUT(skb, XFRMA_ALG_AEAD, aead_len(x->aead), x->aead);
-	if (x->aalg)
-		NLA_PUT(skb, XFRMA_ALG_AUTH, xfrm_alg_len(x->aalg), x->aalg);
+	if (x->aalg) {
+		if (copy_to_user_auth(x->aalg, skb))
+			goto nla_put_failure;
+
+		NLA_PUT(skb, XFRMA_ALG_AUTH_TRUNC,
+			xfrm_alg_auth_len(x->aalg), x->aalg);
+	}
 	if (x->ealg)
 		NLA_PUT(skb, XFRMA_ALG_CRYPT, xfrm_alg_len(x->ealg), x->ealg);
 	if (x->calg)
@@ -2117,8 +2227,11 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 	size_t l = 0;
 	if (x->aead)
 		l += nla_total_size(aead_len(x->aead));
-	if (x->aalg)
-		l += nla_total_size(xfrm_alg_len(x->aalg));
+	if (x->aalg) {
+		l += nla_total_size(sizeof(struct xfrm_algo) +
+				    (x->aalg->alg_key_len + 7) / 8);
+		l += nla_total_size(xfrm_alg_auth_len(x->aalg));
+	}
 	if (x->ealg)
 		l += nla_total_size(xfrm_alg_len(x->ealg));
 	if (x->calg)
-- 
1.6.3.3

