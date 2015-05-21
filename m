From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/7] ipsec: Add IV generator information to xfrm_state
Date: Thu, 21 May 2015 18:43:57 +0800
Message-ID: <E1YvNxF-00062v-3b@gondolin.me.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:33869 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754216AbbEUKoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 06:44:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds IV generator information to xfrm_state.  This
is currently obtained from our own list of algorithm descriptions.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h   |    1 +
 net/key/af_key.c     |    1 +
 net/xfrm/xfrm_user.c |   40 +++++++++++++++++++++++++++++++---------
 3 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 30bca86..f0ee97e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -168,6 +168,7 @@ struct xfrm_state {
 	struct xfrm_algo	*ealg;
 	struct xfrm_algo	*calg;
 	struct xfrm_algo_aead	*aead;
+	const char		*geniv;
 
 	/* Data for encapsulator */
 	struct xfrm_encap_tmpl	*encap;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index f0d52d7..3c5b8ce 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1190,6 +1190,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 				memcpy(x->ealg->alg_key, key+1, keysize);
 			}
 			x->props.ealgo = sa->sadb_sa_encrypt;
+			x->geniv = a->uinfo.encr.geniv;
 		}
 	}
 	/* x->algo.flags = sa->sadb_sa_flags; */
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2091664..bd16c6c 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -289,6 +289,31 @@ static int attach_one_algo(struct xfrm_algo **algpp, u8 *props,
 	return 0;
 }
 
+static int attach_crypt(struct xfrm_state *x, struct nlattr *rta)
+{
+	struct xfrm_algo *p, *ualg;
+	struct xfrm_algo_desc *algo;
+
+	if (!rta)
+		return 0;
+
+	ualg = nla_data(rta);
+
+	algo = xfrm_ealg_get_byname(ualg->alg_name, 1);
+	if (!algo)
+		return -ENOSYS;
+	x->props.ealgo = algo->desc.sadb_alg_id;
+
+	p = kmemdup(ualg, xfrm_alg_len(ualg), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	strcpy(p->alg_name, algo->name);
+	x->ealg = p;
+	x->geniv = algo->uinfo.encr.geniv;
+	return 0;
+}
+
 static int attach_auth(struct xfrm_algo_auth **algpp, u8 *props,
 		       struct nlattr *rta)
 {
@@ -349,8 +374,7 @@ static int attach_auth_trunc(struct xfrm_algo_auth **algpp, u8 *props,
 	return 0;
 }
 
-static int attach_aead(struct xfrm_algo_aead **algpp, u8 *props,
-		       struct nlattr *rta)
+static int attach_aead(struct xfrm_state *x, struct nlattr *rta)
 {
 	struct xfrm_algo_aead *p, *ualg;
 	struct xfrm_algo_desc *algo;
@@ -363,14 +387,15 @@ static int attach_aead(struct xfrm_algo_aead **algpp, u8 *props,
 	algo = xfrm_aead_get_byname(ualg->alg_name, ualg->alg_icv_len, 1);
 	if (!algo)
 		return -ENOSYS;
-	*props = algo->desc.sadb_alg_id;
+	x->props.ealgo = algo->desc.sadb_alg_id;
 
 	p = kmemdup(ualg, aead_len(ualg), GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
 	strcpy(p->alg_name, algo->name);
-	*algpp = p;
+	x->aead = p;
+	x->geniv = algo->uinfo.aead.geniv;
 	return 0;
 }
 
@@ -515,8 +540,7 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 	if (attrs[XFRMA_SA_EXTRA_FLAGS])
 		x->props.extra_flags = nla_get_u32(attrs[XFRMA_SA_EXTRA_FLAGS]);
 
-	if ((err = attach_aead(&x->aead, &x->props.ealgo,
-			       attrs[XFRMA_ALG_AEAD])))
+	if ((err = attach_aead(x, attrs[XFRMA_ALG_AEAD])))
 		goto error;
 	if ((err = attach_auth_trunc(&x->aalg, &x->props.aalgo,
 				     attrs[XFRMA_ALG_AUTH_TRUNC])))
@@ -526,9 +550,7 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 				       attrs[XFRMA_ALG_AUTH])))
 			goto error;
 	}
-	if ((err = attach_one_algo(&x->ealg, &x->props.ealgo,
-				   xfrm_ealg_get_byname,
-				   attrs[XFRMA_ALG_CRYPT])))
+	if ((err = attach_crypt(x, attrs[XFRMA_ALG_CRYPT])))
 		goto error;
 	if ((err = attach_one_algo(&x->calg, &x->props.calgo,
 				   xfrm_calg_get_byname,
