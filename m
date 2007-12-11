From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/3] [IPSEC]: Add support for combined mode algorithms
Date: Tue, 11 Dec 2007 12:23:45 +0800
Message-ID: <E1J1wen-0002rA-00@gondolin.me.apana.org.au>
References: <20071211042312.GA10911@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2274 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751773AbXLKEXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 23:23:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[IPSEC]: Add support for combined mode algorithms

This patch adds support for combined mode algorithms with GCM being the
first algorithm supported.

Combined mode algorithms can be added through the xfrm_user interface
using the new algorithm payload type XFRMA_ALG_AEAD.  Each algorithms
is identified by its name and the ICV length.

For the purposes of matching algorithms in xfrm_tmpl structures, combined
mode algorithms are occupy the same name space as encryption algorithms.
This is in line with how they are negotiated using IKE.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/pfkeyv2.h |    3 +
 include/linux/xfrm.h    |    8 ++++
 include/net/xfrm.h      |   16 ++++++++
 net/ipv4/esp4.c         |   71 ++++++++++++++++++++++++++++++-------
 net/ipv6/esp6.c         |   77 ++++++++++++++++++++++++++++++++---------
 net/xfrm/xfrm_algo.c    |   90 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_user.c    |   69 +++++++++++++++++++++++++++++++++++-
 7 files changed, 303 insertions(+), 31 deletions(-)

diff --git a/include/linux/pfkeyv2.h b/include/linux/pfkeyv2.h
index d9db5f6..fb4649e 100644
--- a/include/linux/pfkeyv2.h
+++ b/include/linux/pfkeyv2.h
@@ -298,6 +298,9 @@ struct sadb_x_sec_ctx {
 #define SADB_X_EALG_BLOWFISHCBC		7
 #define SADB_EALG_NULL			11
 #define SADB_X_EALG_AESCBC		12
+#define SADB_X_EALG_AES_GCM_ICV8	18
+#define SADB_X_EALG_AES_GCM_ICV12	19
+#define SADB_X_EALG_AES_GCM_ICV16	20
 #define SADB_X_EALG_CAMELLIACBC		22
 #define SADB_EALG_MAX                   253 /* last EALG */
 /* private allocations should use 249-255 (RFC2407) */
diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index b58adc5..df2e62a 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -96,6 +96,13 @@ struct xfrm_algo {
 	char	alg_key[0];
 };
 
+struct xfrm_algo_aead {
+	char	alg_name[64];
+	int	alg_key_len;	/* in bits */
+	int	alg_icv_len;	/* in bits */
+	char	alg_key[0];
+};
+
 struct xfrm_stats {
 	__u32	replay_window;
 	__u32	replay;
@@ -269,6 +276,7 @@ enum xfrm_attr_type_t {
 	XFRMA_LASTUSED,
 	XFRMA_POLICY_TYPE,	/* struct xfrm_userpolicy_type */
 	XFRMA_MIGRATE,
+	XFRMA_ALG_AEAD,		/* struct xfrm_algo_aead */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index c49fe0f..92ee8e5 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -145,6 +145,7 @@ struct xfrm_state
 	struct xfrm_algo	*aalg;
 	struct xfrm_algo	*ealg;
 	struct xfrm_algo	*calg;
+	struct xfrm_algo_aead	*aead;
 
 	/* Data for encapsulator */
 	struct xfrm_encap_tmpl	*encap;
@@ -1021,6 +1022,10 @@ static inline int xfrm_id_proto_match(u8 proto, u8 userproto)
 /*
  * xfrm algorithm information
  */
+struct xfrm_algo_aead_info {
+	u16 icv_truncbits;
+};
+
 struct xfrm_algo_auth_info {
 	u16 icv_truncbits;
 	u16 icv_fullbits;
@@ -1035,11 +1040,20 @@ struct xfrm_algo_comp_info {
 	u16 threshold;
 };
 
+enum {
+	XFRM_ALGO_AEAD,
+	XFRM_ALGO_AUTH,
+	XFRM_ALGO_ENCR,
+	XFRM_ALGO_COMP,
+};
+
 struct xfrm_algo_desc {
 	char *name;
 	char *compat;
 	u8 available:1;
+	u16 type;
 	union {
+		struct xfrm_algo_aead_info aead;
 		struct xfrm_algo_auth_info auth;
 		struct xfrm_algo_encr_info encr;
 		struct xfrm_algo_comp_info comp;
@@ -1241,6 +1255,8 @@ extern struct xfrm_algo_desc *xfrm_calg_get_byid(int alg_id);
 extern struct xfrm_algo_desc *xfrm_aalg_get_byname(char *name, int probe);
 extern struct xfrm_algo_desc *xfrm_ealg_get_byname(char *name, int probe);
 extern struct xfrm_algo_desc *xfrm_calg_get_byname(char *name, int probe);
+extern struct xfrm_algo_desc *xfrm_aead_get_byname(char *name, int icv_len,
+						   int probe);
 
 struct hash_desc;
 struct scatterlist;
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index c1f5936..45fa230 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -412,32 +412,53 @@ static void esp_destroy(struct xfrm_state *x)
 	kfree(esp);
 }
 
-static int esp_init_state(struct xfrm_state *x)
+static int esp_init_aead(struct xfrm_state *x)
 {
-	struct esp_data *esp = NULL;
+	struct esp_data *esp = x->data;
+	struct crypto_aead *aead;
+	int err;
+
+	aead = crypto_alloc_aead(x->aead->alg_name, 0, 0);
+	err = PTR_ERR(aead);
+	if (IS_ERR(aead))
+		goto error;
+
+	esp->aead = aead;
+
+	err = crypto_aead_setkey(aead, x->aead->alg_key,
+				 (x->aead->alg_key_len + 7) / 8);
+	if (err)
+		goto error;
+
+	err = crypto_aead_setauthsize(aead, x->aead->alg_icv_len / 8);
+	if (err)
+		goto error;
+
+error:
+	return err;
+}
+
+static int esp_init_authenc(struct xfrm_state *x)
+{
+	struct esp_data *esp = x->data;
 	struct crypto_aead *aead;
 	struct crypto_authenc_key_param *param;
 	struct rtattr *rta;
 	char *key;
 	char *p;
 	char authenc_name[CRYPTO_MAX_ALG_NAME];
-	u32 align;
 	unsigned int keylen;
 	int err;
 
+	err = -EINVAL;
 	if (x->ealg == NULL)
-		return -EINVAL;
+		goto error;
 
+	err = -ENAMETOOLONG;
 	if (snprintf(authenc_name, CRYPTO_MAX_ALG_NAME, "authenc(%s,%s)",
                      x->aalg ? x->aalg->alg_name : "digest_null",
                      x->ealg->alg_name) >= CRYPTO_MAX_ALG_NAME)
-		return -ENAMETOOLONG;
-
-	esp = kzalloc(sizeof(*esp), GFP_KERNEL);
-	if (esp == NULL)
-		return -ENOMEM;
-
-	x->data = esp;
+		goto error;
 
 	aead = crypto_alloc_aead(authenc_name, 0, 0);
 	err = PTR_ERR(aead);
@@ -485,8 +506,6 @@ static int esp_init_state(struct xfrm_state *x)
 			goto free_key;
 	}
 
-	esp->padlen = 0;
-
 	param->enckeylen = cpu_to_be32((x->ealg->alg_key_len + 7) / 8);
 	memcpy(p, x->ealg->alg_key, (x->ealg->alg_key_len + 7) / 8);
 
@@ -495,9 +514,35 @@ static int esp_init_state(struct xfrm_state *x)
 free_key:
 	kfree(key);
 
+error:
+	return err;
+}
+
+static int esp_init_state(struct xfrm_state *x)
+{
+	struct esp_data *esp;
+	struct crypto_aead *aead;
+	u32 align;
+	int err;
+
+	esp = kzalloc(sizeof(*esp), GFP_KERNEL);
+	if (esp == NULL)
+		return -ENOMEM;
+
+	x->data = esp;
+
+	if (x->aead)
+		err = esp_init_aead(x);
+	else
+		err = esp_init_authenc(x);
+
 	if (err)
 		goto error;
 
+	aead = esp->aead;
+
+	esp->padlen = 0;
+
 	x->props.header_len = sizeof(struct ip_esp_hdr) +
 			      crypto_aead_ivsize(aead);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index d8c1619..84fe594 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -356,35 +356,53 @@ static void esp6_destroy(struct xfrm_state *x)
 	kfree(esp);
 }
 
-static int esp6_init_state(struct xfrm_state *x)
+static int esp_init_aead(struct xfrm_state *x)
+{
+	struct esp_data *esp = x->data;
+	struct crypto_aead *aead;
+	int err;
+
+	aead = crypto_alloc_aead(x->aead->alg_name, 0, 0);
+	err = PTR_ERR(aead);
+	if (IS_ERR(aead))
+		goto error;
+
+	esp->aead = aead;
+
+	err = crypto_aead_setkey(aead, x->aead->alg_key,
+				 (x->aead->alg_key_len + 7) / 8);
+	if (err)
+		goto error;
+
+	err = crypto_aead_setauthsize(aead, x->aead->alg_icv_len / 8);
+	if (err)
+		goto error;
+
+error:
+	return err;
+}
+
+static int esp_init_authenc(struct xfrm_state *x)
 {
-	struct esp_data *esp = NULL;
+	struct esp_data *esp = x->data;
 	struct crypto_aead *aead;
 	struct crypto_authenc_key_param *param;
 	struct rtattr *rta;
 	char *key;
 	char *p;
 	char authenc_name[CRYPTO_MAX_ALG_NAME];
-	u32 align;
 	unsigned int keylen;
 	int err;
 
+	err = -EINVAL;
 	if (x->ealg == NULL)
-		return -EINVAL;
-
-	if (x->encap)
-		return -EINVAL;
+		goto error;
 
+	err = -ENAMETOOLONG;
 	if (snprintf(authenc_name, CRYPTO_MAX_ALG_NAME, "authenc(%s,%s)",
                      x->aalg ? x->aalg->alg_name : "digest_null",
                      x->ealg->alg_name) >= CRYPTO_MAX_ALG_NAME)
-		return -ENAMETOOLONG;
-
-	esp = kzalloc(sizeof(*esp), GFP_KERNEL);
-	if (esp == NULL)
-		return -ENOMEM;
-
-	x->data = esp;
+		goto error;
 
 	aead = crypto_alloc_aead(authenc_name, 0, 0);
 	err = PTR_ERR(aead);
@@ -432,8 +450,6 @@ static int esp6_init_state(struct xfrm_state *x)
 			goto free_key;
 	}
 
-	esp->padlen = 0;
-
 	param->enckeylen = cpu_to_be32((x->ealg->alg_key_len + 7) / 8);
 	memcpy(p, x->ealg->alg_key, (x->ealg->alg_key_len + 7) / 8);
 
@@ -442,9 +458,38 @@ static int esp6_init_state(struct xfrm_state *x)
 free_key:
 	kfree(key);
 
+error:
+	return err;
+}
+
+static int esp6_init_state(struct xfrm_state *x)
+{
+	struct esp_data *esp;
+	struct crypto_aead *aead;
+	u32 align;
+	int err;
+
+	if (x->encap)
+		return -EINVAL;
+
+	esp = kzalloc(sizeof(*esp), GFP_KERNEL);
+	if (esp == NULL)
+		return -ENOMEM;
+
+	x->data = esp;
+
+	if (x->aead)
+		err = esp_init_aead(x);
+	else
+		err = esp_init_authenc(x);
+
 	if (err)
 		goto error;
 
+	aead = esp->aead;
+
+	esp->padlen = 0;
+
 	x->props.header_len = sizeof(struct ip_esp_hdr) +
 			      crypto_aead_ivsize(aead);
 	switch (x->props.mode) {
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index ae34a12..259e61e 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -28,6 +28,57 @@
  * that instantiated crypto transforms have correct parameters for IPsec
  * purposes.
  */
+static struct xfrm_algo_desc aead_list[] = {
+{
+	.name = "gcm(aes)",
+
+	.uinfo = {
+		.aead = {
+			.icv_truncbits = 64,
+		}
+	},
+
+	.desc = {
+		.sadb_alg_id = SADB_X_EALG_AES_GCM_ICV8,
+		.sadb_alg_ivlen = 8,
+		.sadb_alg_minbits = 128,
+		.sadb_alg_maxbits = 256
+	}
+},
+{
+	.name = "gcm(aes)",
+
+	.uinfo = {
+		.aead = {
+			.icv_truncbits = 96,
+		}
+	},
+
+	.desc = {
+		.sadb_alg_id = SADB_X_EALG_AES_GCM_ICV12,
+		.sadb_alg_ivlen = 8,
+		.sadb_alg_minbits = 128,
+		.sadb_alg_maxbits = 256
+	}
+},
+{
+	.name = "gcm(aes)",
+
+	.uinfo = {
+		.aead = {
+			.icv_truncbits = 128,
+		}
+	},
+
+	.desc = {
+		.sadb_alg_id = SADB_X_EALG_AES_GCM_ICV16,
+		.sadb_alg_ivlen = 8,
+		.sadb_alg_minbits = 128,
+		.sadb_alg_maxbits = 256
+	}
+},
+};
+
 static struct xfrm_algo_desc aalg_list[] = {
 {
 	.name = "hmac(digest_null)",
@@ -332,6 +383,11 @@ static struct xfrm_algo_desc calg_list[] = {
 },
 };
 
+static inline int aead_entries(void)
+{
+	return ARRAY_SIZE(aead_list);
+}
+
 static inline int aalg_entries(void)
 {
 	return ARRAY_SIZE(aalg_list);
@@ -354,6 +410,13 @@ struct xfrm_algo_list {
 	u32 mask;
 };
 
+static const struct xfrm_algo_list xfrm_aead_list = {
+	.algs = aead_list,
+	.entries = ARRAY_SIZE(aead_list),
+	.type = CRYPTO_ALG_TYPE_AEAD,
+	.mask = CRYPTO_ALG_TYPE_MASK,
+};
+
 static const struct xfrm_algo_list xfrm_aalg_list = {
 	.algs = aalg_list,
 	.entries = ARRAY_SIZE(aalg_list),
@@ -461,6 +524,33 @@ struct xfrm_algo_desc *xfrm_calg_get_byname(char *name, int probe)
 }
 EXPORT_SYMBOL_GPL(xfrm_calg_get_byname);
 
+struct xfrm_aead_name {
+	const char *name;
+	int icvbits;
+};
+
+static int xfrm_aead_name_match(const struct xfrm_algo_desc *entry,
+				const void *data)
+{
+	const struct xfrm_aead_name *aead = data;
+	const char *name = aead->name;
+
+	return aead->icvbits == entry->uinfo.aead.icv_truncbits && name &&
+	       !strcmp(name, entry->name);
+}
+
+struct xfrm_algo_desc *xfrm_aead_get_byname(char *name, int icv_len, int probe)
+{
+	struct xfrm_aead_name data = {
+		.name = name,
+		.icvbits = icv_len * 8,
+	};
+
+	return xfrm_find_algo(&xfrm_aead_list, xfrm_aead_name_match, &data,
+			      probe);
+}
+EXPORT_SYMBOL_GPL(xfrm_aead_get_byname);
+
 struct xfrm_algo_desc *xfrm_aalg_get_byidx(unsigned int idx)
 {
 	if (idx >= aalg_entries())
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2403788..6ad1f11 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -36,6 +36,11 @@ static inline int alg_len(struct xfrm_algo *alg)
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
 
+static inline int aead_len(struct xfrm_algo_aead *alg)
+{
+	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
+}
+
 static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 {
 	struct nlattr *rt = attrs[type];
@@ -61,6 +66,8 @@ static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 			return -EINVAL;
 		break;
 
+	case XFRMA_ALG_AEAD:
+		/* Zero length keys will be picked up by init_state. */
 	case XFRMA_ALG_COMP:
 		/* Zero length keys are legal.  */
 		break;
@@ -73,6 +80,22 @@ static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 	return 0;
 }
 
+static int verify_aead(struct nlattr **attrs)
+{
+	struct nlattr *rt = attrs[XFRMA_ALG_AEAD];
+	struct xfrm_algo_aead *algp;
+
+	if (!rt)
+		return 0;
+
+	algp = nla_data(rt);
+	if (nla_len(rt) < aead_len(algp))
+		return -EINVAL;
+
+	algp->alg_name[CRYPTO_MAX_ALG_NAME - 1] = '\0';
+	return 0;
+}
+
 static void verify_one_addr(struct nlattr **attrs, enum xfrm_attr_type_t type,
 			   xfrm_address_t **addrp)
 {
@@ -124,20 +147,28 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 	switch (p->id.proto) {
 	case IPPROTO_AH:
 		if (!attrs[XFRMA_ALG_AUTH]	||
+		    attrs[XFRMA_ALG_AEAD]	||
 		    attrs[XFRMA_ALG_CRYPT]	||
 		    attrs[XFRMA_ALG_COMP])
 			goto out;
 		break;
 
 	case IPPROTO_ESP:
+		if (attrs[XFRMA_ALG_COMP])
+			goto out;
 		if ((!attrs[XFRMA_ALG_AUTH] &&
-		     !attrs[XFRMA_ALG_CRYPT])	||
-		    attrs[XFRMA_ALG_COMP])
+		     !attrs[XFRMA_ALG_CRYPT] &&
+		     !attrs[XFRMA_ALG_AEAD]))
 			goto out;
+		if ((attrs[XFRMA_ALG_AUTH] ||
+		     attrs[XFRMA_ALG_CRYPT]) &&
+		    attrs[XFRMA_ALG_AEAD])
+		    	goto out;
 		break;
 
 	case IPPROTO_COMP:
 		if (!attrs[XFRMA_ALG_COMP]	||
+		    attrs[XFRMA_ALG_AEAD]	||
 		    attrs[XFRMA_ALG_AUTH]	||
 		    attrs[XFRMA_ALG_CRYPT])
 			goto out;
@@ -148,6 +179,7 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 	case IPPROTO_ROUTING:
 		if (attrs[XFRMA_ALG_COMP]	||
 		    attrs[XFRMA_ALG_AUTH]	||
+		    attrs[XFRMA_ALG_AEAD]	||
 		    attrs[XFRMA_ALG_CRYPT]	||
 		    attrs[XFRMA_ENCAP]		||
 		    attrs[XFRMA_SEC_CTX]	||
@@ -160,6 +192,8 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		goto out;
 	}
 
+	if ((err = verify_aead(attrs)))
+		goto out;
 	if ((err = verify_one_alg(attrs, XFRMA_ALG_AUTH)))
 		goto out;
 	if ((err = verify_one_alg(attrs, XFRMA_ALG_CRYPT)))
@@ -213,6 +247,31 @@ static int attach_one_algo(struct xfrm_algo **algpp, u8 *props,
 	return 0;
 }
 
+static int attach_aead(struct xfrm_algo_aead **algpp, u8 *props,
+		       struct nlattr *rta)
+{
+	struct xfrm_algo_aead *p, *ualg;
+	struct xfrm_algo_desc *algo;
+
+	if (!rta)
+		return 0;
+
+	ualg = nla_data(rta);
+
+	algo = xfrm_aead_get_byname(ualg->alg_name, ualg->alg_icv_len, 1);
+	if (!algo)
+		return -ENOSYS;
+	*props = algo->desc.sadb_alg_id;
+
+	p = kmemdup(ualg, aead_len(ualg), GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+
+	strcpy(p->alg_name, algo->name);
+	*algpp = p;
+	return 0;
+}
+
 static inline int xfrm_user_sec_ctx_size(struct xfrm_sec_ctx *xfrm_ctx)
 {
 	int len = 0;
@@ -291,6 +350,9 @@ static struct xfrm_state *xfrm_state_construct(struct xfrm_usersa_info *p,
 
 	copy_from_user_state(x, p);
 
+	if ((err = attach_aead(&x->aead, &x->props.ealgo,
+			       attrs[XFRMA_ALG_AEAD])))
+		goto error;
 	if ((err = attach_one_algo(&x->aalg, &x->props.aalgo,
 				   xfrm_aalg_get_byname,
 				   attrs[XFRMA_ALG_AUTH])))
@@ -515,6 +577,8 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 	if (x->lastused)
 		NLA_PUT_U64(skb, XFRMA_LASTUSED, x->lastused);
 
+	if (x->aead)
+		NLA_PUT(skb, XFRMA_ALG_AEAD, aead_len(x->aead), x->aead);
 	if (x->aalg)
 		NLA_PUT(skb, XFRMA_ALG_AUTH, alg_len(x->aalg), x->aalg);
 	if (x->ealg)
@@ -1813,6 +1877,7 @@ static const int xfrm_msg_min[XFRM_NR_MSGTYPES] = {
 #undef XMSGSIZE
 
 static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
+	[XFRMA_ALG_AEAD]	= { .len = sizeof(struct xfrm_algo_aead) },
 	[XFRMA_ALG_AUTH]	= { .len = sizeof(struct xfrm_algo) },
 	[XFRMA_ALG_CRYPT]	= { .len = sizeof(struct xfrm_algo) },
 	[XFRMA_ALG_COMP]	= { .len = sizeof(struct xfrm_algo) },
