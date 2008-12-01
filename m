From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC PATCH 5/5] crypto: make struct aead percpu data
Date: Mon, 1 Dec 2008 08:20:43 +0100
Message-ID: <20081201072043.GU476@secunet.com>
References: <20081201071614.GP476@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	klassert@mathematik.tu-chemnitz.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:46524 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750850AbYLAHsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 02:48:21 -0500
Content-Disposition: inline
In-Reply-To: <20081201071614.GP476@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>

The struct aead is now allocated as percpu data to get
rid of a very high contended lock in crypto_authenc_hash()
if IPsec runs in parallel.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 crypto/aead.c          |    2 +-
 crypto/chainiv.c       |    3 +-
 crypto/testmgr.c       |   14 +++++---
 include/linux/crypto.h |    2 +-
 net/ipv4/esp4.c        |   79 +++++++++++++++++++++++++++-----------------
 net/ipv6/esp6.c        |   84 +++++++++++++++++++++++++++++------------------
 6 files changed, 113 insertions(+), 71 deletions(-)

diff --git a/crypto/aead.c b/crypto/aead.c
index 3a6f3f5..8f9a2a0 100644
--- a/crypto/aead.c
+++ b/crypto/aead.c
@@ -465,7 +465,7 @@ struct crypto_aead *crypto_alloc_aead(const char *alg_name, u32 type, u32 mask)
 			goto err;
 		}
 
-		tfm = __crypto_alloc_tfm(alg, type, mask);
+		tfm = __crypto_alloc_tfm_percpu(alg, type, mask);
 		if (!IS_ERR(tfm))
 			return __crypto_aead_cast(tfm);
 
diff --git a/crypto/chainiv.c b/crypto/chainiv.c
index 2079fdd..b3e2b28 100644
--- a/crypto/chainiv.c
+++ b/crypto/chainiv.c
@@ -133,7 +133,8 @@ static int async_chainiv_schedule_work(struct async_chainiv_ctx *ctx)
 			goto out;
 	}
 
-	queued = schedule_work(&ctx->postponed);
+	queued = schedule_work_on(get_cpu(), &ctx->postponed);
+	put_cpu();
 	BUG_ON(!queued);
 
 out:
diff --git a/crypto/testmgr.c b/crypto/testmgr.c
index b828c6c..96418cd 100644
--- a/crypto/testmgr.c
+++ b/crypto/testmgr.c
@@ -885,16 +885,20 @@ out:
 static int alg_test_aead(const struct alg_test_desc *desc, const char *driver,
 			 u32 type, u32 mask)
 {
-	struct crypto_aead *tfm;
+	struct crypto_aead *tfm, *tfm_percpu;
 	int err = 0;
 
-	tfm = crypto_alloc_aead(driver, type, mask);
-	if (IS_ERR(tfm)) {
+	tfm_percpu = crypto_alloc_aead(driver, type, mask);
+
+	if (IS_ERR(tfm_percpu)) {
 		printk(KERN_ERR "alg: aead: Failed to load transform for %s: "
-		       "%ld\n", driver, PTR_ERR(tfm));
-		return PTR_ERR(tfm);
+		       "%ld\n", driver, PTR_ERR(tfm_percpu));
+		return PTR_ERR(tfm_percpu);
 	}
 
+	tfm = per_cpu_ptr(tfm_percpu, get_cpu());
+	put_cpu();
+
 	if (desc->suite.aead.enc.vecs) {
 		err = test_aead(tfm, ENCRYPT, desc->suite.aead.enc.vecs,
 				desc->suite.aead.enc.count);
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index da07852..f9c4bf2 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -800,7 +800,7 @@ static inline struct crypto_tfm *crypto_aead_tfm(struct crypto_aead *tfm)
 
 static inline void crypto_free_aead(struct crypto_aead *tfm)
 {
-	crypto_free_tfm(crypto_aead_tfm(tfm));
+	crypto_free_tfm_percpu(crypto_aead_tfm(tfm));
 }
 
 static inline struct aead_tfm *crypto_aead_crt(struct crypto_aead *tfm)
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 3ea3fb2..daa7e7d 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -130,7 +130,8 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	clen = skb->len;
 
 	esp = x->data;
-	aead = esp->aead;
+	aead = per_cpu_ptr(esp->aead, get_cpu());
+	put_cpu();
 	alen = crypto_aead_authsize(aead);
 
 	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
@@ -237,7 +238,7 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 	struct iphdr *iph;
 	struct xfrm_state *x = xfrm_input_state(skb);
 	struct esp_data *esp = x->data;
-	struct crypto_aead *aead = esp->aead;
+	struct crypto_aead *aead = per_cpu_ptr(esp->aead, smp_processor_id());
 	int alen = crypto_aead_authsize(aead);
 	int hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
 	int elen = skb->len - hlen;
@@ -330,7 +331,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ip_esp_hdr *esph;
 	struct esp_data *esp = x->data;
-	struct crypto_aead *aead = esp->aead;
+	struct crypto_aead *aead = per_cpu_ptr(esp->aead, smp_processor_id());
 	struct aead_request *req;
 	struct sk_buff *trailer;
 	int elen = skb->len - sizeof(*esph) - crypto_aead_ivsize(aead);
@@ -393,11 +394,13 @@ out:
 static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 {
 	struct esp_data *esp = x->data;
-	u32 blksize = ALIGN(crypto_aead_blocksize(esp->aead), 4);
+	struct crypto_aead *aead = per_cpu_ptr(esp->aead, get_cpu());
+	u32 blksize = ALIGN(crypto_aead_blocksize(aead), 4);
 	u32 align = max_t(u32, blksize, esp->padlen);
 	u32 rem;
 
-	mtu -= x->props.header_len + crypto_aead_authsize(esp->aead);
+	put_cpu();
+	mtu -= x->props.header_len + crypto_aead_authsize(aead);
 	rem = mtu & (align - 1);
 	mtu &= ~(align - 1);
 
@@ -451,24 +454,27 @@ static void esp_destroy(struct xfrm_state *x)
 static int esp_init_aead(struct xfrm_state *x)
 {
 	struct esp_data *esp = x->data;
-	struct crypto_aead *aead;
-	int err;
+	struct crypto_aead *aead, *aead_percpu;
+	int err, cpu;
 
-	aead = crypto_alloc_aead(x->aead->alg_name, 0, 0);
-	err = PTR_ERR(aead);
-	if (IS_ERR(aead))
+	aead_percpu = crypto_alloc_aead(x->aead->alg_name, 0, 0);
+	err = PTR_ERR(aead_percpu);
+	if (IS_ERR(aead_percpu))
 		goto error;
 
-	esp->aead = aead;
+	esp->aead = aead_percpu;
 
-	err = crypto_aead_setkey(aead, x->aead->alg_key,
-				 (x->aead->alg_key_len + 7) / 8);
-	if (err)
-		goto error;
+	for_each_possible_cpu(cpu) {
+		aead = per_cpu_ptr(aead_percpu, cpu);
+		err = crypto_aead_setkey(aead, x->aead->alg_key,
+					 (x->aead->alg_key_len + 7) / 8);
+		if (err)
+			goto error;
 
-	err = crypto_aead_setauthsize(aead, x->aead->alg_icv_len / 8);
-	if (err)
-		goto error;
+		err = crypto_aead_setauthsize(aead, x->aead->alg_icv_len / 8);
+		if (err)
+			goto error;
+	}
 
 error:
 	return err;
@@ -477,14 +483,14 @@ error:
 static int esp_init_authenc(struct xfrm_state *x)
 {
 	struct esp_data *esp = x->data;
-	struct crypto_aead *aead;
+	struct crypto_aead *aead, *aead_percpu;
 	struct crypto_authenc_key_param *param;
 	struct rtattr *rta;
 	char *key;
 	char *p;
 	char authenc_name[CRYPTO_MAX_ALG_NAME];
 	unsigned int keylen;
-	int err;
+	int err, cpu;
 
 	err = -EINVAL;
 	if (x->ealg == NULL)
@@ -496,12 +502,12 @@ static int esp_init_authenc(struct xfrm_state *x)
 		     x->ealg->alg_name) >= CRYPTO_MAX_ALG_NAME)
 		goto error;
 
-	aead = crypto_alloc_aead(authenc_name, 0, 0);
-	err = PTR_ERR(aead);
-	if (IS_ERR(aead))
+	aead_percpu = crypto_alloc_aead(authenc_name, 0, 0);
+	err = PTR_ERR(aead_percpu);
+	if (IS_ERR(aead_percpu))
 		goto error;
 
-	esp->aead = aead;
+	esp->aead = aead_percpu;
 
 	keylen = (x->aalg ? (x->aalg->alg_key_len + 7) / 8 : 0) +
 		 (x->ealg->alg_key_len + 7) / 8 + RTA_SPACE(sizeof(*param));
@@ -527,6 +533,10 @@ static int esp_init_authenc(struct xfrm_state *x)
 		BUG_ON(!aalg_desc);
 
 		err = -EINVAL;
+		/* The aead authsize is the same for all cpus,
+		 * so just read from the the local cpu. */
+		aead = per_cpu_ptr(aead_percpu, get_cpu());
+		put_cpu();
 		if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
 		    crypto_aead_authsize(aead)) {
 			NETDEBUG(KERN_INFO "ESP: %s digestsize %u != %hu\n",
@@ -536,16 +546,22 @@ static int esp_init_authenc(struct xfrm_state *x)
 			goto free_key;
 		}
 
-		err = crypto_aead_setauthsize(
-			aead, aalg_desc->uinfo.auth.icv_truncbits / 8);
-		if (err)
-			goto free_key;
+		for_each_possible_cpu(cpu) {
+			aead = per_cpu_ptr(aead_percpu, cpu);
+			err = crypto_aead_setauthsize(
+				aead, aalg_desc->uinfo.auth.icv_truncbits / 8);
+			if (err)
+				goto free_key;
+		}
 	}
 
 	param->enckeylen = cpu_to_be32((x->ealg->alg_key_len + 7) / 8);
 	memcpy(p, x->ealg->alg_key, (x->ealg->alg_key_len + 7) / 8);
 
-	err = crypto_aead_setkey(aead, key, keylen);
+	for_each_possible_cpu(cpu) {
+		aead = per_cpu_ptr(aead_percpu, cpu);
+		err = crypto_aead_setkey(aead, key, keylen);
+	}
 
 free_key:
 	kfree(key);
@@ -575,7 +591,8 @@ static int esp_init_state(struct xfrm_state *x)
 	if (err)
 		goto error;
 
-	aead = esp->aead;
+	aead = per_cpu_ptr(esp->aead, get_cpu());
+	put_cpu();
 
 	esp->padlen = 0;
 
@@ -603,7 +620,7 @@ static int esp_init_state(struct xfrm_state *x)
 	align = ALIGN(crypto_aead_blocksize(aead), 4);
 	if (esp->padlen)
 		align = max_t(u32, align, esp->padlen);
-	x->props.trailer_len = align + 1 + crypto_aead_authsize(esp->aead);
+	x->props.trailer_len = align + 1 + crypto_aead_authsize(aead);
 
 error:
 	return err;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 9874adf..15bb91e 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -154,7 +154,8 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	/* Round to block size */
 	clen = skb->len;
 
-	aead = esp->aead;
+	aead = per_cpu_ptr(esp->aead, get_cpu());
+
 	alen = crypto_aead_authsize(aead);
 
 	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
@@ -218,6 +219,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	kfree(tmp);
 
 error:
+	put_cpu();
 	return err;
 }
 
@@ -225,7 +227,7 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 {
 	struct xfrm_state *x = xfrm_input_state(skb);
 	struct esp_data *esp = x->data;
-	struct crypto_aead *aead = esp->aead;
+	struct crypto_aead *aead = per_cpu_ptr(esp->aead, smp_processor_id());
 	int alen = crypto_aead_authsize(aead);
 	int hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
 	int elen = skb->len - hlen;
@@ -276,7 +278,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ip_esp_hdr *esph;
 	struct esp_data *esp = x->data;
-	struct crypto_aead *aead = esp->aead;
+	struct crypto_aead *aead = per_cpu_ptr(esp->aead, smp_processor_id());
 	struct aead_request *req;
 	struct sk_buff *trailer;
 	int elen = skb->len - sizeof(*esph) - crypto_aead_ivsize(aead);
@@ -344,11 +346,12 @@ out:
 static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 {
 	struct esp_data *esp = x->data;
-	u32 blksize = ALIGN(crypto_aead_blocksize(esp->aead), 4);
+	struct crypto_aead *aead = per_cpu_ptr(esp->aead, get_cpu());
+	u32 blksize = ALIGN(crypto_aead_blocksize(aead), 4);
 	u32 align = max_t(u32, blksize, esp->padlen);
 	u32 rem;
 
-	mtu -= x->props.header_len + crypto_aead_authsize(esp->aead);
+	mtu -= x->props.header_len + crypto_aead_authsize(aead);
 	rem = mtu & (align - 1);
 	mtu &= ~(align - 1);
 
@@ -358,6 +361,7 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 		mtu += min_t(u32, blksize - padsize, rem);
 	}
 
+	put_cpu();
 	return mtu - 2;
 }
 
@@ -394,24 +398,27 @@ static void esp6_destroy(struct xfrm_state *x)
 static int esp_init_aead(struct xfrm_state *x)
 {
 	struct esp_data *esp = x->data;
-	struct crypto_aead *aead;
-	int err;
+	struct crypto_aead *aead, *aead_percpu;
+	int err, cpu;
 
-	aead = crypto_alloc_aead(x->aead->alg_name, 0, 0);
-	err = PTR_ERR(aead);
-	if (IS_ERR(aead))
+	aead_percpu = crypto_alloc_aead(x->aead->alg_name, 0, 0);
+	err = PTR_ERR(aead_percpu);
+	if (IS_ERR(aead_percpu))
 		goto error;
 
-	esp->aead = aead;
+	esp->aead = aead_percpu;
 
-	err = crypto_aead_setkey(aead, x->aead->alg_key,
-				 (x->aead->alg_key_len + 7) / 8);
-	if (err)
-		goto error;
+	for_each_possible_cpu(cpu) {
+		aead = per_cpu_ptr(aead_percpu, cpu);
+		err = crypto_aead_setkey(aead, x->aead->alg_key,
+					 (x->aead->alg_key_len + 7) / 8);
+		if (err)
+			goto error;
 
-	err = crypto_aead_setauthsize(aead, x->aead->alg_icv_len / 8);
-	if (err)
-		goto error;
+		err = crypto_aead_setauthsize(aead, x->aead->alg_icv_len / 8);
+		if (err)
+			goto error;
+	}
 
 error:
 	return err;
@@ -420,14 +427,14 @@ error:
 static int esp_init_authenc(struct xfrm_state *x)
 {
 	struct esp_data *esp = x->data;
-	struct crypto_aead *aead;
+	struct crypto_aead *aead, *aead_percpu;
 	struct crypto_authenc_key_param *param;
 	struct rtattr *rta;
 	char *key;
 	char *p;
 	char authenc_name[CRYPTO_MAX_ALG_NAME];
 	unsigned int keylen;
-	int err;
+	int err, cpu;
 
 	err = -EINVAL;
 	if (x->ealg == NULL)
@@ -439,12 +446,12 @@ static int esp_init_authenc(struct xfrm_state *x)
 		     x->ealg->alg_name) >= CRYPTO_MAX_ALG_NAME)
 		goto error;
 
-	aead = crypto_alloc_aead(authenc_name, 0, 0);
-	err = PTR_ERR(aead);
-	if (IS_ERR(aead))
+	aead_percpu = crypto_alloc_aead(authenc_name, 0, 0);
+	err = PTR_ERR(aead_percpu);
+	if (IS_ERR(aead_percpu))
 		goto error;
 
-	esp->aead = aead;
+	esp->aead = aead_percpu;
 
 	keylen = (x->aalg ? (x->aalg->alg_key_len + 7) / 8 : 0) +
 		 (x->ealg->alg_key_len + 7) / 8 + RTA_SPACE(sizeof(*param));
@@ -470,6 +477,10 @@ static int esp_init_authenc(struct xfrm_state *x)
 		BUG_ON(!aalg_desc);
 
 		err = -EINVAL;
+		/* The aead authsize is the same for all cpus,
+		 * so just read from the the local cpu. */
+		aead = per_cpu_ptr(aead_percpu, get_cpu());
+
 		if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
 		    crypto_aead_authsize(aead)) {
 			NETDEBUG(KERN_INFO "ESP: %s digestsize %u != %hu\n",
@@ -479,18 +490,26 @@ static int esp_init_authenc(struct xfrm_state *x)
 			goto free_key;
 		}
 
-		err = crypto_aead_setauthsize(
-			aead, aalg_desc->uinfo.auth.icv_truncbits / 8);
-		if (err)
-			goto free_key;
+		for_each_possible_cpu(cpu) {
+			aead = per_cpu_ptr(aead_percpu, cpu);
+			err = crypto_aead_setauthsize(
+				aead, aalg_desc->uinfo.auth.icv_truncbits / 8);
+			if (err)
+				goto free_key;
+		}
 	}
 
 	param->enckeylen = cpu_to_be32((x->ealg->alg_key_len + 7) / 8);
 	memcpy(p, x->ealg->alg_key, (x->ealg->alg_key_len + 7) / 8);
 
-	err = crypto_aead_setkey(aead, key, keylen);
+	for_each_possible_cpu(cpu) {
+		aead = per_cpu_ptr(aead_percpu, cpu);
+		err = crypto_aead_setkey(aead, key, keylen);
+	}
 
 free_key:
+
+	put_cpu();
 	kfree(key);
 
 error:
@@ -519,9 +538,9 @@ static int esp6_init_state(struct xfrm_state *x)
 		err = esp_init_authenc(x);
 
 	if (err)
-		goto error;
+		return err;
 
-	aead = esp->aead;
+	aead = per_cpu_ptr(esp->aead, get_cpu());
 
 	esp->padlen = 0;
 
@@ -545,9 +564,10 @@ static int esp6_init_state(struct xfrm_state *x)
 	align = ALIGN(crypto_aead_blocksize(aead), 4);
 	if (esp->padlen)
 		align = max_t(u32, align, esp->padlen);
-	x->props.trailer_len = align + 1 + crypto_aead_authsize(esp->aead);
+	x->props.trailer_len = align + 1 + crypto_aead_authsize(aead);
 
 error:
+	put_cpu();
 	return err;
 }
 
-- 
1.5.4.2

