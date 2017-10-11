From: Xiang Gao <qasdfgtyuiop@gmail.com>
Subject: [PATCH v3] mac80211: aead api to reduce redundancy
Date: Tue, 10 Oct 2017 22:31:49 -0400
Message-ID: <20171011023149.18021-1-qasdfgtyuiop@gmail.com>
Cc: qasdfgtyuiop@gmail.com
To: davem@davemloft.net, johannes@sipsolutions.net,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, the aes_ccm.c and aes_gcm.c are almost line by line copy of
each other. This patch reduce code redundancy by moving the code in these
two files to crypto/aead_api.c to make it a higher level aead api. The
file aes_ccm.c and aes_gcm.c are removed and all the functions there are
now implemented in their headers using the newly added aead api.

Signed-off-by: Xiang Gao <qasdfgtyuiop@gmail.com>
---
 net/mac80211/Makefile                  |   3 +-
 net/mac80211/{aes_ccm.c => aead_api.c} |  40 ++++++------
 net/mac80211/aead_api.h                |  27 ++++++++
 net/mac80211/aes_ccm.h                 |  42 +++++++++----
 net/mac80211/aes_gcm.c                 | 109 ---------------------------------
 net/mac80211/aes_gcm.h                 |  38 +++++++++---
 net/mac80211/wpa.c                     |   4 +-
 7 files changed, 111 insertions(+), 152 deletions(-)
 rename net/mac80211/{aes_ccm.c => aead_api.c} (67%)
 create mode 100644 net/mac80211/aead_api.h
 delete mode 100644 net/mac80211/aes_gcm.c

diff --git a/net/mac80211/Makefile b/net/mac80211/Makefile
index 282912245938..80f25ff2f24b 100644
--- a/net/mac80211/Makefile
+++ b/net/mac80211/Makefile
@@ -6,6 +6,7 @@ mac80211-y := \
 	driver-ops.o \
 	sta_info.o \
 	wep.o \
+	aead_api.o \
 	wpa.o \
 	scan.o offchannel.o \
 	ht.o agg-tx.o agg-rx.o \
@@ -15,8 +16,6 @@ mac80211-y := \
 	rate.o \
 	michael.o \
 	tkip.o \
-	aes_ccm.o \
-	aes_gcm.o \
 	aes_cmac.o \
 	aes_gmac.o \
 	fils_aead.o \
diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aead_api.c
similarity index 67%
rename from net/mac80211/aes_ccm.c
rename to net/mac80211/aead_api.c
index a4e0d59a40dd..cc48675ba742 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aead_api.c
@@ -1,4 +1,5 @@
 /*
+ * Copyright 2014-2015, Qualcomm Atheros, Inc.
  * Copyright 2003-2004, Instant802 Networks, Inc.
  * Copyright 2005-2006, Devicescape Software, Inc.
  *
@@ -12,30 +13,29 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/err.h>
+#include <linux/scatterlist.h>
 #include <crypto/aead.h>
 
-#include <net/mac80211.h>
-#include "key.h"
-#include "aes_ccm.h"
+#include "aead_api.h"
 
-int ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic,
-			      size_t mic_len)
+int aead_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad, size_t aad_len,
+		 u8 *data, size_t data_len, u8 *mic)
 {
+	size_t mic_len = tfm->authsize;
 	struct scatterlist sg[3];
 	struct aead_request *aead_req;
 	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(tfm);
 	u8 *__aad;
 
-	aead_req = kzalloc(reqsize + CCM_AAD_LEN, GFP_ATOMIC);
+	aead_req = kzalloc(reqsize + aad_len, GFP_ATOMIC);
 	if (!aead_req)
 		return -ENOMEM;
 
 	__aad = (u8 *)aead_req + reqsize;
-	memcpy(__aad, aad, CCM_AAD_LEN);
+	memcpy(__aad, aad, aad_len);
 
 	sg_init_table(sg, 3);
-	sg_set_buf(&sg[0], &__aad[2], be16_to_cpup((__be16 *)__aad));
+	sg_set_buf(&sg[0], __aad, aad_len);
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, mic_len);
 
@@ -49,10 +49,10 @@ int ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	return 0;
 }
 
-int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic,
-			      size_t mic_len)
+int aead_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad, size_t aad_len,
+		 u8 *data, size_t data_len, u8 *mic)
 {
+	size_t mic_len = tfm->authsize;
 	struct scatterlist sg[3];
 	struct aead_request *aead_req;
 	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(tfm);
@@ -62,15 +62,15 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	if (data_len == 0)
 		return -EINVAL;
 
-	aead_req = kzalloc(reqsize + CCM_AAD_LEN, GFP_ATOMIC);
+	aead_req = kzalloc(reqsize + aad_len, GFP_ATOMIC);
 	if (!aead_req)
 		return -ENOMEM;
 
 	__aad = (u8 *)aead_req + reqsize;
-	memcpy(__aad, aad, CCM_AAD_LEN);
+	memcpy(__aad, aad, aad_len);
 
 	sg_init_table(sg, 3);
-	sg_set_buf(&sg[0], &__aad[2], be16_to_cpup((__be16 *)__aad));
+	sg_set_buf(&sg[0], __aad, aad_len);
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, mic_len);
 
@@ -84,14 +84,14 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	return err;
 }
 
-struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[],
-						    size_t key_len,
-						    size_t mic_len)
+struct crypto_aead *
+aead_key_setup_encrypt(const char *alg, const u8 key[],
+		       size_t key_len, size_t mic_len)
 {
 	struct crypto_aead *tfm;
 	int err;
 
-	tfm = crypto_alloc_aead("ccm(aes)", 0, CRYPTO_ALG_ASYNC);
+	tfm = crypto_alloc_aead(alg, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm))
 		return tfm;
 
@@ -109,7 +109,7 @@ struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[],
 	return ERR_PTR(err);
 }
 
-void ieee80211_aes_key_free(struct crypto_aead *tfm)
+void aead_key_free(struct crypto_aead *tfm)
 {
 	crypto_free_aead(tfm);
 }
diff --git a/net/mac80211/aead_api.h b/net/mac80211/aead_api.h
new file mode 100644
index 000000000000..5e39ea843bbf
--- /dev/null
+++ b/net/mac80211/aead_api.h
@@ -0,0 +1,27 @@
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _AEAD_API_H
+#define _AEAD_API_H
+
+#include <crypto/aead.h>
+#include <linux/crypto.h>
+
+struct crypto_aead *
+aead_key_setup_encrypt(const char *alg, const u8 key[],
+		       size_t key_len, size_t mic_len);
+
+int aead_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
+		 size_t aad_len, u8 *data,
+		 size_t data_len, u8 *mic);
+
+int aead_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
+		 size_t aad_len, u8 *data,
+		 size_t data_len, u8 *mic);
+
+void aead_key_free(struct crypto_aead *tfm);
+
+#endif /* _AEAD_API_H */
diff --git a/net/mac80211/aes_ccm.h b/net/mac80211/aes_ccm.h
index fcd3254c5cf0..e9b7ca0bde5b 100644
--- a/net/mac80211/aes_ccm.h
+++ b/net/mac80211/aes_ccm.h
@@ -10,19 +10,39 @@
 #ifndef AES_CCM_H
 #define AES_CCM_H
 
-#include <linux/crypto.h>
+#include "aead_api.h"
 
 #define CCM_AAD_LEN	32
 
-struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[],
-						    size_t key_len,
-						    size_t mic_len);
-int ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic,
-			      size_t mic_len);
-int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic,
-			      size_t mic_len);
-void ieee80211_aes_key_free(struct crypto_aead *tfm);
+static inline struct crypto_aead *
+ieee80211_aes_key_setup_encrypt(const u8 key[], size_t key_len, size_t mic_len)
+{
+	return aead_key_setup_encrypt("ccm(aes)", key, key_len, mic_len);
+}
+
+static inline int
+ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm,
+			  u8 *b_0, u8 *aad, u8 *data,
+			  size_t data_len, u8 *mic)
+{
+	return aead_encrypt(tfm, b_0, aad + 2,
+			    be16_to_cpup((__be16 *)aad),
+			    data, data_len, mic);
+}
+
+static inline int
+ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm,
+			  u8 *b_0, u8 *aad, u8 *data,
+			  size_t data_len, u8 *mic)
+{
+	return aead_decrypt(tfm, b_0, aad + 2,
+			    be16_to_cpup((__be16 *)aad),
+			    data, data_len, mic);
+}
+
+static inline void ieee80211_aes_key_free(struct crypto_aead *tfm)
+{
+	return aead_key_free(tfm);
+}
 
 #endif /* AES_CCM_H */
diff --git a/net/mac80211/aes_gcm.c b/net/mac80211/aes_gcm.c
deleted file mode 100644
index 8a4397cc1b08..000000000000
--- a/net/mac80211/aes_gcm.c
+++ /dev/null
@@ -1,109 +0,0 @@
-/*
- * Copyright 2014-2015, Qualcomm Atheros, Inc.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/kernel.h>
-#include <linux/types.h>
-#include <linux/err.h>
-#include <crypto/aead.h>
-
-#include <net/mac80211.h>
-#include "key.h"
-#include "aes_gcm.h"
-
-int ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic)
-{
-	struct scatterlist sg[3];
-	struct aead_request *aead_req;
-	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(tfm);
-	u8 *__aad;
-
-	aead_req = kzalloc(reqsize + GCM_AAD_LEN, GFP_ATOMIC);
-	if (!aead_req)
-		return -ENOMEM;
-
-	__aad = (u8 *)aead_req + reqsize;
-	memcpy(__aad, aad, GCM_AAD_LEN);
-
-	sg_init_table(sg, 3);
-	sg_set_buf(&sg[0], &__aad[2], be16_to_cpup((__be16 *)__aad));
-	sg_set_buf(&sg[1], data, data_len);
-	sg_set_buf(&sg[2], mic, IEEE80211_GCMP_MIC_LEN);
-
-	aead_request_set_tfm(aead_req, tfm);
-	aead_request_set_crypt(aead_req, sg, sg, data_len, j_0);
-	aead_request_set_ad(aead_req, sg[0].length);
-
-	crypto_aead_encrypt(aead_req);
-	kzfree(aead_req);
-	return 0;
-}
-
-int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic)
-{
-	struct scatterlist sg[3];
-	struct aead_request *aead_req;
-	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(tfm);
-	u8 *__aad;
-	int err;
-
-	if (data_len == 0)
-		return -EINVAL;
-
-	aead_req = kzalloc(reqsize + GCM_AAD_LEN, GFP_ATOMIC);
-	if (!aead_req)
-		return -ENOMEM;
-
-	__aad = (u8 *)aead_req + reqsize;
-	memcpy(__aad, aad, GCM_AAD_LEN);
-
-	sg_init_table(sg, 3);
-	sg_set_buf(&sg[0], &__aad[2], be16_to_cpup((__be16 *)__aad));
-	sg_set_buf(&sg[1], data, data_len);
-	sg_set_buf(&sg[2], mic, IEEE80211_GCMP_MIC_LEN);
-
-	aead_request_set_tfm(aead_req, tfm);
-	aead_request_set_crypt(aead_req, sg, sg,
-			       data_len + IEEE80211_GCMP_MIC_LEN, j_0);
-	aead_request_set_ad(aead_req, sg[0].length);
-
-	err = crypto_aead_decrypt(aead_req);
-	kzfree(aead_req);
-
-	return err;
-}
-
-struct crypto_aead *ieee80211_aes_gcm_key_setup_encrypt(const u8 key[],
-							size_t key_len)
-{
-	struct crypto_aead *tfm;
-	int err;
-
-	tfm = crypto_alloc_aead("gcm(aes)", 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(tfm))
-		return tfm;
-
-	err = crypto_aead_setkey(tfm, key, key_len);
-	if (err)
-		goto free_aead;
-	err = crypto_aead_setauthsize(tfm, IEEE80211_GCMP_MIC_LEN);
-	if (err)
-		goto free_aead;
-
-	return tfm;
-
-free_aead:
-	crypto_free_aead(tfm);
-	return ERR_PTR(err);
-}
-
-void ieee80211_aes_gcm_key_free(struct crypto_aead *tfm)
-{
-	crypto_free_aead(tfm);
-}
diff --git a/net/mac80211/aes_gcm.h b/net/mac80211/aes_gcm.h
index 55aed5352494..d2b096033009 100644
--- a/net/mac80211/aes_gcm.h
+++ b/net/mac80211/aes_gcm.h
@@ -9,16 +9,38 @@
 #ifndef AES_GCM_H
 #define AES_GCM_H
 
-#include <linux/crypto.h>
+#include "aead_api.h"
 
 #define GCM_AAD_LEN	32
 
-int ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic);
-int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic);
-struct crypto_aead *ieee80211_aes_gcm_key_setup_encrypt(const u8 key[],
-							size_t key_len);
-void ieee80211_aes_gcm_key_free(struct crypto_aead *tfm);
+static inline int ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm,
+					    u8 *j_0, u8 *aad,  u8 *data,
+					    size_t data_len, u8 *mic)
+{
+	return aead_encrypt(tfm, j_0, aad + 2,
+			    be16_to_cpup((__be16 *)aad),
+			    data, data_len, mic);
+}
+
+static inline int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm,
+					    u8 *j_0, u8 *aad, u8 *data,
+					    size_t data_len, u8 *mic)
+{
+	return aead_decrypt(tfm, j_0, aad + 2,
+			    be16_to_cpup((__be16 *)aad),
+			    data, data_len, mic);
+}
+
+static inline struct crypto_aead *
+ieee80211_aes_gcm_key_setup_encrypt(const u8 key[], size_t key_len)
+{
+	return aead_key_setup_encrypt("gcm(aes)", key,
+				      key_len, IEEE80211_GCMP_MIC_LEN);
+}
+
+static inline void ieee80211_aes_gcm_key_free(struct crypto_aead *tfm)
+{
+	return aead_key_free(tfm);
+}
 
 #endif /* AES_GCM_H */
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 0d722ea98a1b..b58722d9de37 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -464,7 +464,7 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb,
 	pos += IEEE80211_CCMP_HDR_LEN;
 	ccmp_special_blocks(skb, pn, b_0, aad);
 	return ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad, pos, len,
-					 skb_put(skb, mic_len), mic_len);
+					 skb_put(skb, mic_len));
 }
 
 
@@ -543,7 +543,7 @@ ieee80211_crypto_ccmp_decrypt(struct ieee80211_rx_data *rx,
 				    key->u.ccmp.tfm, b_0, aad,
 				    skb->data + hdrlen + IEEE80211_CCMP_HDR_LEN,
 				    data_len,
-				    skb->data + skb->len - mic_len, mic_len))
+				    skb->data + skb->len - mic_len))
 				return RX_DROP_UNUSABLE;
 		}
 
-- 
2.14.2
