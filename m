From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 2/3] crypto: Add inline per-cpu wrappers for compression
Date: Wed,  7 Dec 2011 12:59:09 -0600
Message-ID: <1323284350-13784-3-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1323284350-13784-1-git-send-email-sjenning@linux.vnet.ibm.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Brian King <brking@linux.vnet.ibm.com>,
	Robert Jennings <rcj@linux.vnet.ibm.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1323284350-13784-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds wrapper functions for compression users
that allocate and free per-cpu compression transforms

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 include/linux/crypto.h |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index 8a94217..5ed19c1 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -483,6 +483,10 @@ struct crypto_attr_u32 {
  
 struct crypto_tfm *crypto_alloc_base(const char *alg_name, u32 type, u32 mask);
 void crypto_destroy_tfm(void *mem, struct crypto_tfm *tfm);
+struct crypto_tfm * __percpu *crypto_alloc_percpu_tfms(const char *alg_name,
+			u32 type, u32 mask, const struct cpumask *cpumask);
+void crypto_free_percpu_tfms(struct crypto_tfm * __percpu *tfms,
+				const struct cpumask *cpumask);
 
 static inline void crypto_free_tfm(struct crypto_tfm *tfm)
 {
@@ -1213,6 +1217,12 @@ static inline struct crypto_comp *__crypto_comp_cast(struct crypto_tfm *tfm)
 	return (struct crypto_comp *)tfm;
 }
 
+static inline struct crypto_comp * __percpu *__crypto_comp_percpu_cast(
+	struct crypto_tfm * __percpu *tfms)
+{
+	return (struct crypto_comp * __percpu *)tfms;
+}
+
 static inline struct crypto_comp *crypto_comp_cast(struct crypto_tfm *tfm)
 {
 	BUG_ON((crypto_tfm_alg_type(tfm) ^ CRYPTO_ALG_TYPE_COMPRESS) &
@@ -1230,6 +1240,17 @@ static inline struct crypto_comp *crypto_alloc_comp(const char *alg_name,
 	return __crypto_comp_cast(crypto_alloc_base(alg_name, type, mask));
 }
 
+static inline struct crypto_comp * __percpu *crypto_alloc_percpu_comp(
+	const char *alg_name, u32 type, u32 mask, const struct cpumask *cpumask)
+{
+	type &= ~CRYPTO_ALG_TYPE_MASK;
+	type |= CRYPTO_ALG_TYPE_COMPRESS;
+	mask |= CRYPTO_ALG_TYPE_MASK;
+
+	return __crypto_comp_percpu_cast(crypto_alloc_percpu_tfms(alg_name,
+							type, mask, cpumask));
+}
+
 static inline struct crypto_tfm *crypto_comp_tfm(struct crypto_comp *tfm)
 {
 	return &tfm->base;
@@ -1240,6 +1261,13 @@ static inline void crypto_free_comp(struct crypto_comp *tfm)
 	crypto_free_tfm(crypto_comp_tfm(tfm));
 }
 
+static inline void crypto_free_percpu_comp(struct crypto_comp * __percpu *tfms,
+				const struct cpumask *cpumask)
+{
+	crypto_free_percpu_tfms((struct crypto_tfm * __percpu *)(tfms),
+		cpumask);
+}
+
 static inline int crypto_has_comp(const char *alg_name, u32 type, u32 mask)
 {
 	type &= ~CRYPTO_ALG_TYPE_MASK;
-- 
1.7.5.4
