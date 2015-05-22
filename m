From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 1/13] crypto: aead - Add crypto_aead_alg_ivsize/maxauthsize
Date: Fri, 22 May 2015 16:30:48 +0800
Message-ID: <E1YviLw-0000wm-U7@gondolin.me.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

AEAD algorithm implementors need to figure out a given algorithm's
IV size and maximum authentication size.  During the transition
this is difficult to do as an algorithm could be new style or old
style.

This patch creates two helpers to make this easier.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/aead.c                  |   15 +++------------
 include/crypto/aead.h          |   21 ++++++++++++++++++---
 include/crypto/internal/aead.h |   19 +++++++------------
 3 files changed, 28 insertions(+), 27 deletions(-)

diff --git a/crypto/aead.c b/crypto/aead.c
index 5fa992a..c1f73a9 100644
--- a/crypto/aead.c
+++ b/crypto/aead.c
@@ -69,7 +69,7 @@ int crypto_aead_setauthsize(struct crypto_aead *tfm, unsigned int authsize)
 {
 	int err;
 
-	if (authsize > tfm->maxauthsize)
+	if (authsize > crypto_aead_maxauthsize(tfm))
 		return -EINVAL;
 
 	if (tfm->setauthsize) {
@@ -162,8 +162,6 @@ static int crypto_old_aead_init_tfm(struct crypto_tfm *tfm)
 		crt->givdecrypt = aead_null_givdecrypt;
 	}
 	crt->child = __crypto_aead_cast(tfm);
-	crt->ivsize = alg->ivsize;
-	crt->maxauthsize = alg->maxauthsize;
 	crt->authsize = alg->maxauthsize;
 
 	return 0;
@@ -182,8 +180,6 @@ static int crypto_aead_init_tfm(struct crypto_tfm *tfm)
 	aead->encrypt = alg->encrypt;
 	aead->decrypt = alg->decrypt;
 	aead->child = __crypto_aead_cast(tfm);
-	aead->ivsize = alg->ivsize;
-	aead->maxauthsize = alg->maxauthsize;
 	aead->authsize = alg->maxauthsize;
 
 	return 0;
@@ -418,13 +414,8 @@ struct aead_instance *aead_geniv_alloc(struct crypto_template *tmpl,
 
 	alg = crypto_spawn_aead_alg(spawn);
 
-	if (alg->base.cra_aead.encrypt) {
-		ivsize = alg->base.cra_aead.ivsize;
-		maxauthsize = alg->base.cra_aead.maxauthsize;
-	} else {
-		ivsize = alg->ivsize;
-		maxauthsize = alg->maxauthsize;
-	}
+	ivsize = crypto_aead_alg_ivsize(alg);
+	maxauthsize = crypto_aead_alg_maxauthsize(alg);
 
 	err = -EINVAL;
 	if (!ivsize)
diff --git a/include/crypto/aead.h b/include/crypto/aead.h
index 177e6f4..ba28c61 100644
--- a/include/crypto/aead.h
+++ b/include/crypto/aead.h
@@ -139,9 +139,7 @@ struct crypto_aead {
 
 	struct crypto_aead *child;
 
-	unsigned int ivsize;
 	unsigned int authsize;
-	unsigned int maxauthsize;
 	unsigned int reqsize;
 
 	struct crypto_tfm base;
@@ -187,6 +185,23 @@ static inline struct crypto_aead *crypto_aead_crt(struct crypto_aead *tfm)
 	return tfm;
 }
 
+static inline struct old_aead_alg *crypto_old_aead_alg(struct crypto_aead *tfm)
+{
+	return &crypto_aead_tfm(tfm)->__crt_alg->cra_aead;
+}
+
+static inline struct aead_alg *crypto_aead_alg(struct crypto_aead *tfm)
+{
+	return container_of(crypto_aead_tfm(tfm)->__crt_alg,
+			    struct aead_alg, base);
+}
+
+static inline unsigned int crypto_aead_alg_ivsize(struct aead_alg *alg)
+{
+	return alg->base.cra_aead.encrypt ? alg->base.cra_aead.ivsize :
+					    alg->ivsize;
+}
+
 /**
  * crypto_aead_ivsize() - obtain IV size
  * @tfm: cipher handle
@@ -198,7 +213,7 @@ static inline struct crypto_aead *crypto_aead_crt(struct crypto_aead *tfm)
  */
 static inline unsigned int crypto_aead_ivsize(struct crypto_aead *tfm)
 {
-	return tfm->ivsize;
+	return crypto_aead_alg_ivsize(crypto_aead_alg(tfm));
 }
 
 /**
diff --git a/include/crypto/internal/aead.h b/include/crypto/internal/aead.h
index 08f2ca6..4137330 100644
--- a/include/crypto/internal/aead.h
+++ b/include/crypto/internal/aead.h
@@ -30,17 +30,6 @@ struct crypto_aead_spawn {
 extern const struct crypto_type crypto_aead_type;
 extern const struct crypto_type crypto_nivaead_type;
 
-static inline struct old_aead_alg *crypto_old_aead_alg(struct crypto_aead *tfm)
-{
-	return &crypto_aead_tfm(tfm)->__crt_alg->cra_aead;
-}
-
-static inline struct aead_alg *crypto_aead_alg(struct crypto_aead *tfm)
-{
-	return container_of(crypto_aead_tfm(tfm)->__crt_alg,
-			    struct aead_alg, base);
-}
-
 static inline void *crypto_aead_ctx(struct crypto_aead *tfm)
 {
 	return crypto_tfm_ctx(&tfm->base);
@@ -145,9 +134,15 @@ static inline void crypto_aead_set_reqsize(struct crypto_aead *aead,
 	crypto_aead_crt(aead)->reqsize = reqsize;
 }
 
+static inline unsigned int crypto_aead_alg_maxauthsize(struct aead_alg *alg)
+{
+	return alg->base.cra_aead.encrypt ? alg->base.cra_aead.maxauthsize :
+					    alg->maxauthsize;
+}
+
 static inline unsigned int crypto_aead_maxauthsize(struct crypto_aead *aead)
 {
-	return aead->maxauthsize;
+	return crypto_aead_alg_maxauthsize(crypto_aead_alg(aead));
 }
 
 int crypto_register_aead(struct aead_alg *alg);
