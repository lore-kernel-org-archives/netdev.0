From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH] pf_key/xfrm_algo: prepare pf_key and xfrm_algo for new
 algorithms without pfkey support
Date: Thu, 31 Jan 2013 12:40:38 +0200
Message-ID: <20130131104038.6852.57446.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-02.sanoma.fi ([158.127.18.162]:50239 "EHLO
	sd-mail-sa-02.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282Ab3AaKkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 05:40:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark existing algorithms as pfkey supported and make pfkey only use algorithms
that have pfkey_supported set.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---
 include/net/xfrm.h   |    5 ++--
 net/key/af_key.c     |   39 ++++++++++++++++++++++++------
 net/xfrm/xfrm_algo.c |   65 +++++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 93 insertions(+), 16 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 421f764..814a1ba 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1320,6 +1320,7 @@ struct xfrm_algo_desc {
 	char *name;
 	char *compat;
 	u8 available:1;
+	u8 pfkey_supported:1;
 	union {
 		struct xfrm_algo_aead_info aead;
 		struct xfrm_algo_auth_info auth;
@@ -1561,8 +1562,8 @@ extern void xfrm_input_init(void);
 extern int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq);
 
 extern void xfrm_probe_algs(void);
-extern int xfrm_count_auth_supported(void);
-extern int xfrm_count_enc_supported(void);
+extern int xfrm_count_pfkey_auth_supported(void);
+extern int xfrm_count_pfkey_enc_supported(void);
 extern struct xfrm_algo_desc *xfrm_aalg_get_byidx(unsigned int idx);
 extern struct xfrm_algo_desc *xfrm_ealg_get_byidx(unsigned int idx);
 extern struct xfrm_algo_desc *xfrm_aalg_get_byid(int alg_id);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 5b426a6..88a6e4d 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -816,18 +816,21 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 	sa->sadb_sa_auth = 0;
 	if (x->aalg) {
 		struct xfrm_algo_desc *a = xfrm_aalg_get_byname(x->aalg->alg_name, 0);
-		sa->sadb_sa_auth = a ? a->desc.sadb_alg_id : 0;
+		sa->sadb_sa_auth = (a && a->pfkey_supported) ?
+					a->desc.sadb_alg_id : 0;
 	}
 	sa->sadb_sa_encrypt = 0;
 	BUG_ON(x->ealg && x->calg);
 	if (x->ealg) {
 		struct xfrm_algo_desc *a = xfrm_ealg_get_byname(x->ealg->alg_name, 0);
-		sa->sadb_sa_encrypt = a ? a->desc.sadb_alg_id : 0;
+		sa->sadb_sa_encrypt = (a && a->pfkey_supported) ?
+					a->desc.sadb_alg_id : 0;
 	}
 	/* KAME compatible: sadb_sa_encrypt is overloaded with calg id */
 	if (x->calg) {
 		struct xfrm_algo_desc *a = xfrm_calg_get_byname(x->calg->alg_name, 0);
-		sa->sadb_sa_encrypt = a ? a->desc.sadb_alg_id : 0;
+		sa->sadb_sa_encrypt = (a && a->pfkey_supported) ?
+					a->desc.sadb_alg_id : 0;
 	}
 
 	sa->sadb_sa_flags = 0;
@@ -1138,7 +1141,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 	if (sa->sadb_sa_auth) {
 		int keysize = 0;
 		struct xfrm_algo_desc *a = xfrm_aalg_get_byid(sa->sadb_sa_auth);
-		if (!a) {
+		if (!a || !a->pfkey_supported) {
 			err = -ENOSYS;
 			goto out;
 		}
@@ -1160,7 +1163,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 	if (sa->sadb_sa_encrypt) {
 		if (hdr->sadb_msg_satype == SADB_X_SATYPE_IPCOMP) {
 			struct xfrm_algo_desc *a = xfrm_calg_get_byid(sa->sadb_sa_encrypt);
-			if (!a) {
+			if (!a || !a->pfkey_supported) {
 				err = -ENOSYS;
 				goto out;
 			}
@@ -1172,7 +1175,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 		} else {
 			int keysize = 0;
 			struct xfrm_algo_desc *a = xfrm_ealg_get_byid(sa->sadb_sa_encrypt);
-			if (!a) {
+			if (!a || !a->pfkey_supported) {
 				err = -ENOSYS;
 				goto out;
 			}
@@ -1578,13 +1581,13 @@ static struct sk_buff *compose_sadb_supported(const struct sadb_msg *orig,
 	struct sadb_msg *hdr;
 	int len, auth_len, enc_len, i;
 
-	auth_len = xfrm_count_auth_supported();
+	auth_len = xfrm_count_pfkey_auth_supported();
 	if (auth_len) {
 		auth_len *= sizeof(struct sadb_alg);
 		auth_len += sizeof(struct sadb_supported);
 	}
 
-	enc_len = xfrm_count_enc_supported();
+	enc_len = xfrm_count_pfkey_enc_supported();
 	if (enc_len) {
 		enc_len *= sizeof(struct sadb_alg);
 		enc_len += sizeof(struct sadb_supported);
@@ -1615,6 +1618,8 @@ static struct sk_buff *compose_sadb_supported(const struct sadb_msg *orig,
 			struct xfrm_algo_desc *aalg = xfrm_aalg_get_byidx(i);
 			if (!aalg)
 				break;
+			if (!aalg->pfkey_supported)
+				continue;
 			if (aalg->available)
 				*ap++ = aalg->desc;
 		}
@@ -1634,6 +1639,8 @@ static struct sk_buff *compose_sadb_supported(const struct sadb_msg *orig,
 			struct xfrm_algo_desc *ealg = xfrm_ealg_get_byidx(i);
 			if (!ealg)
 				break;
+			if (!ealg->pfkey_supported)
+				continue;
 			if (ealg->available)
 				*ap++ = ealg->desc;
 		}
@@ -2825,6 +2832,8 @@ static int count_ah_combs(const struct xfrm_tmpl *t)
 		const struct xfrm_algo_desc *aalg = xfrm_aalg_get_byidx(i);
 		if (!aalg)
 			break;
+		if (!aalg->pfkey_supported)
+			continue;
 		if (aalg_tmpl_set(t, aalg) && aalg->available)
 			sz += sizeof(struct sadb_comb);
 	}
@@ -2840,6 +2849,9 @@ static int count_esp_combs(const struct xfrm_tmpl *t)
 		if (!ealg)
 			break;
 
+		if (!ealg->pfkey_supported)
+			continue;
+
 		if (!(ealg_tmpl_set(t, ealg) && ealg->available))
 			continue;
 
@@ -2848,6 +2860,9 @@ static int count_esp_combs(const struct xfrm_tmpl *t)
 			if (!aalg)
 				break;
 
+			if (!aalg->pfkey_supported)
+				continue;
+
 			if (aalg_tmpl_set(t, aalg) && aalg->available)
 				sz += sizeof(struct sadb_comb);
 		}
@@ -2871,6 +2886,9 @@ static void dump_ah_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 		if (!aalg)
 			break;
 
+		if (!aalg->pfkey_supported)
+			continue;
+
 		if (aalg_tmpl_set(t, aalg) && aalg->available) {
 			struct sadb_comb *c;
 			c = (struct sadb_comb*)skb_put(skb, sizeof(struct sadb_comb));
@@ -2903,6 +2921,9 @@ static void dump_esp_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 		if (!ealg)
 			break;
 
+		if (!ealg->pfkey_supported)
+			continue;
+
 		if (!(ealg_tmpl_set(t, ealg) && ealg->available))
 			continue;
 
@@ -2911,6 +2932,8 @@ static void dump_esp_combs(struct sk_buff *skb, const struct xfrm_tmpl *t)
 			const struct xfrm_algo_desc *aalg = xfrm_aalg_get_byidx(k);
 			if (!aalg)
 				break;
+			if (!aalg->pfkey_supported)
+				continue;
 			if (!(aalg_tmpl_set(t, aalg) && aalg->available))
 				continue;
 			c = (struct sadb_comb*)skb_put(skb, sizeof(struct sadb_comb));
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 4694cca..7198326 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -35,6 +35,8 @@ static struct xfrm_algo_desc aead_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_AES_GCM_ICV8,
 		.sadb_alg_ivlen = 8,
@@ -51,6 +53,8 @@ static struct xfrm_algo_desc aead_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_AES_GCM_ICV12,
 		.sadb_alg_ivlen = 8,
@@ -67,6 +71,8 @@ static struct xfrm_algo_desc aead_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_AES_GCM_ICV16,
 		.sadb_alg_ivlen = 8,
@@ -83,6 +89,8 @@ static struct xfrm_algo_desc aead_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_AES_CCM_ICV8,
 		.sadb_alg_ivlen = 8,
@@ -99,6 +107,8 @@ static struct xfrm_algo_desc aead_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_AES_CCM_ICV12,
 		.sadb_alg_ivlen = 8,
@@ -115,6 +125,8 @@ static struct xfrm_algo_desc aead_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_AES_CCM_ICV16,
 		.sadb_alg_ivlen = 8,
@@ -131,6 +143,8 @@ static struct xfrm_algo_desc aead_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_NULL_AES_GMAC,
 		.sadb_alg_ivlen = 8,
@@ -151,6 +165,8 @@ static struct xfrm_algo_desc aalg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_AALG_NULL,
 		.sadb_alg_ivlen = 0,
@@ -169,6 +185,8 @@ static struct xfrm_algo_desc aalg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_AALG_MD5HMAC,
 		.sadb_alg_ivlen = 0,
@@ -187,6 +205,8 @@ static struct xfrm_algo_desc aalg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_AALG_SHA1HMAC,
 		.sadb_alg_ivlen = 0,
@@ -205,6 +225,8 @@ static struct xfrm_algo_desc aalg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_AALG_SHA2_256HMAC,
 		.sadb_alg_ivlen = 0,
@@ -222,6 +244,8 @@ static struct xfrm_algo_desc aalg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_AALG_SHA2_384HMAC,
 		.sadb_alg_ivlen = 0,
@@ -239,6 +263,8 @@ static struct xfrm_algo_desc aalg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_AALG_SHA2_512HMAC,
 		.sadb_alg_ivlen = 0,
@@ -257,6 +283,8 @@ static struct xfrm_algo_desc aalg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_AALG_RIPEMD160HMAC,
 		.sadb_alg_ivlen = 0,
@@ -274,6 +302,8 @@ static struct xfrm_algo_desc aalg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_AALG_AES_XCBC_MAC,
 		.sadb_alg_ivlen = 0,
@@ -295,6 +325,8 @@ static struct xfrm_algo_desc ealg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id =	SADB_EALG_NULL,
 		.sadb_alg_ivlen = 0,
@@ -313,6 +345,8 @@ static struct xfrm_algo_desc ealg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_EALG_DESCBC,
 		.sadb_alg_ivlen = 8,
@@ -331,6 +365,8 @@ static struct xfrm_algo_desc ealg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_EALG_3DESCBC,
 		.sadb_alg_ivlen = 8,
@@ -349,6 +385,8 @@ static struct xfrm_algo_desc ealg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_CASTCBC,
 		.sadb_alg_ivlen = 8,
@@ -367,6 +405,8 @@ static struct xfrm_algo_desc ealg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_BLOWFISHCBC,
 		.sadb_alg_ivlen = 8,
@@ -385,6 +425,8 @@ static struct xfrm_algo_desc ealg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_AESCBC,
 		.sadb_alg_ivlen = 8,
@@ -403,6 +445,8 @@ static struct xfrm_algo_desc ealg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_SERPENTCBC,
 		.sadb_alg_ivlen = 8,
@@ -421,6 +465,8 @@ static struct xfrm_algo_desc ealg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_CAMELLIACBC,
 		.sadb_alg_ivlen = 8,
@@ -439,6 +485,8 @@ static struct xfrm_algo_desc ealg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_TWOFISHCBC,
 		.sadb_alg_ivlen = 8,
@@ -456,6 +504,8 @@ static struct xfrm_algo_desc ealg_list[] = {
 		}
 	},
 
+	.pfkey_supported = 1,
+
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_AESCTR,
 		.sadb_alg_ivlen	= 8,
@@ -473,6 +523,7 @@ static struct xfrm_algo_desc calg_list[] = {
 			.threshold = 90,
 		}
 	},
+	.pfkey_supported = 1,
 	.desc = { .sadb_alg_id = SADB_X_CALG_DEFLATE }
 },
 {
@@ -482,6 +533,7 @@ static struct xfrm_algo_desc calg_list[] = {
 			.threshold = 90,
 		}
 	},
+	.pfkey_supported = 1,
 	.desc = { .sadb_alg_id = SADB_X_CALG_LZS }
 },
 {
@@ -491,6 +543,7 @@ static struct xfrm_algo_desc calg_list[] = {
 			.threshold = 50,
 		}
 	},
+	.pfkey_supported = 1,
 	.desc = { .sadb_alg_id = SADB_X_CALG_LZJH }
 },
 };
@@ -713,27 +766,27 @@ void xfrm_probe_algs(void)
 }
 EXPORT_SYMBOL_GPL(xfrm_probe_algs);
 
-int xfrm_count_auth_supported(void)
+int xfrm_count_pfkey_auth_supported(void)
 {
 	int i, n;
 
 	for (i = 0, n = 0; i < aalg_entries(); i++)
-		if (aalg_list[i].available)
+		if (aalg_list[i].available && aalg_list[i].pfkey_supported)
 			n++;
 	return n;
 }
-EXPORT_SYMBOL_GPL(xfrm_count_auth_supported);
+EXPORT_SYMBOL_GPL(xfrm_count_pfkey_auth_supported);
 
-int xfrm_count_enc_supported(void)
+int xfrm_count_pfkey_enc_supported(void)
 {
 	int i, n;
 
 	for (i = 0, n = 0; i < ealg_entries(); i++)
-		if (ealg_list[i].available)
+		if (ealg_list[i].available && ealg_list[i].pfkey_supported)
 			n++;
 	return n;
 }
-EXPORT_SYMBOL_GPL(xfrm_count_enc_supported);
+EXPORT_SYMBOL_GPL(xfrm_count_pfkey_enc_supported);
 
 #if defined(CONFIG_INET_ESP) || defined(CONFIG_INET_ESP_MODULE) || defined(CONFIG_INET6_ESP) || defined(CONFIG_INET6_ESP_MODULE)
 
