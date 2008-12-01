From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC PATCH 4/5] crypto: allow allocation of percpu crypto
	transforms
Date: Mon, 1 Dec 2008 08:19:43 +0100
Message-ID: <20081201071943.GT476@secunet.com>
References: <20081201071614.GP476@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	klassert@mathematik.tu-chemnitz.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:46522 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750811AbYLAHsU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 02:48:20 -0500
Content-Disposition: inline
In-Reply-To: <20081201071614.GP476@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>

This patch adds functions to alloc/free crypto transforms
as percpu data.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 crypto/api.c           |   86 ++++++++++++++++++++++++++++++++++++++++++-----
 crypto/internal.h      |    3 ++
 include/linux/crypto.h |    1 +
 3 files changed, 80 insertions(+), 10 deletions(-)

diff --git a/crypto/api.c b/crypto/api.c
index 0444d24..6c8fcfb 100644
--- a/crypto/api.c
+++ b/crypto/api.c
@@ -361,6 +361,55 @@ void crypto_shoot_alg(struct crypto_alg *alg)
 }
 EXPORT_SYMBOL_GPL(crypto_shoot_alg);
 
+struct crypto_tfm *__crypto_alloc_tfm_percpu(struct crypto_alg *alg, u32 type,
+				      u32 mask)
+{
+	struct crypto_tfm *tfm = NULL;
+	struct crypto_tfm *tfm_percpu = NULL;
+	unsigned int tfm_size, cpu, cpu_err;
+	int err = -ENOMEM;
+
+	tfm_size = sizeof(*tfm) + crypto_ctxsize(alg, type, mask);
+
+	tfm_percpu =  __alloc_percpu(tfm_size);
+	if (tfm_percpu == NULL)
+		goto out_err;
+
+	for_each_possible_cpu(cpu) {
+
+		tfm = per_cpu_ptr(tfm_percpu, cpu);
+
+		tfm->__crt_alg = alg;
+
+		err = crypto_init_ops(tfm, type, mask);
+		if (err)
+			goto out_free_tfm;
+
+		if (alg->cra_init && (err = alg->cra_init(tfm))) {
+			if (err == -EAGAIN)
+				crypto_shoot_alg(alg);
+			goto cra_init_failed;
+		}
+	}
+
+	goto out;
+
+cra_init_failed:
+	for_each_possible_cpu(cpu_err) {
+		tfm = per_cpu_ptr(tfm_percpu, cpu);
+		crypto_exit_ops(tfm);
+		if (cpu_err == cpu)
+			break;
+	}
+out_free_tfm:
+	free_percpu(tfm_percpu);
+out_err:
+	tfm_percpu = ERR_PTR(err);
+out:
+	return tfm_percpu;
+}
+EXPORT_SYMBOL_GPL(__crypto_alloc_tfm_percpu);
+
 struct crypto_tfm *__crypto_alloc_tfm(struct crypto_alg *alg, u32 type,
 				      u32 mask)
 {
@@ -450,15 +499,8 @@ err:
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(crypto_alloc_base);
- 
-/*
- *	crypto_free_tfm - Free crypto transform
- *	@tfm: Transform to free
- *
- *	crypto_free_tfm() frees up the transform and any associated resources,
- *	then drops the refcount on the associated algorithm.
- */
-void crypto_free_tfm(struct crypto_tfm *tfm)
+
+void __crypto_free_tfm(struct crypto_tfm *tfm)
 {
 	struct crypto_alg *alg;
 	int size;
@@ -474,11 +516,35 @@ void crypto_free_tfm(struct crypto_tfm *tfm)
 	crypto_exit_ops(tfm);
 	crypto_mod_put(alg);
 	memset(tfm, 0, size);
-	kfree(tfm);
 }
 
+/*
+ *	crypto_free_tfm - Free crypto transform
+ *	@tfm: Transform to free
+ *
+ *	crypto_free_tfm() frees up the transform and any associated resources,
+ *	then drops the refcount on the associated algorithm.
+ */
+void crypto_free_tfm(struct crypto_tfm *tfm)
+{
+	__crypto_free_tfm(tfm);
+	kfree(tfm);
+}
 EXPORT_SYMBOL_GPL(crypto_free_tfm);
 
+void crypto_free_tfm_percpu(struct crypto_tfm *tfm_percpu)
+{
+	unsigned int cpu;
+	struct crypto_tfm *tfm;
+
+	for_each_possible_cpu(cpu) {
+		tfm = per_cpu_ptr(tfm_percpu, cpu);
+		__crypto_free_tfm(tfm);
+	}
+	free_percpu(tfm_percpu);
+}
+EXPORT_SYMBOL_GPL(crypto_free_tfm_percpu);
+
 int crypto_has_alg(const char *name, u32 type, u32 mask)
 {
 	int ret = 0;
diff --git a/crypto/internal.h b/crypto/internal.h
index 8ef72d7..8f0fa9e 100644
--- a/crypto/internal.h
+++ b/crypto/internal.h
@@ -109,6 +109,9 @@ void crypto_alg_tested(const char *name, int err);
 void crypto_shoot_alg(struct crypto_alg *alg);
 struct crypto_tfm *__crypto_alloc_tfm(struct crypto_alg *alg, u32 type,
 				      u32 mask);
+struct crypto_tfm *__crypto_alloc_tfm_percpu(struct crypto_alg *alg, u32 type,
+				      u32 mask);
+void __crypto_free_tfm(struct crypto_tfm *tfm);
 
 int crypto_register_instance(struct crypto_template *tmpl,
 			     struct crypto_instance *inst);
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index d5dd094..da07852 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -548,6 +548,7 @@ struct crypto_attr_u32 {
 struct crypto_tfm *crypto_alloc_tfm(const char *alg_name, u32 tfm_flags);
 struct crypto_tfm *crypto_alloc_base(const char *alg_name, u32 type, u32 mask);
 void crypto_free_tfm(struct crypto_tfm *tfm);
+void crypto_free_tfm_percpu(struct crypto_tfm *tfm);
 
 int alg_test(const char *driver, const char *alg, u32 type, u32 mask);
 
-- 
1.5.4.2

