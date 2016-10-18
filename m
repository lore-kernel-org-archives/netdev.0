From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [RFC PATCH 2/2] mac80211: aes_ccm: cache AEAD request structures per CPU
Date: Tue, 18 Oct 2016 15:08:33 +0100
Message-ID: <1476799713-16188-3-git-send-email-ard.biesheuvel@linaro.org>
References: <1476799713-16188-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: herbert@gondor.apana.org.au, j@w1.fi, luto@amacapital.net,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: linux-wireless@vger.kernel.org, johannes@sipsolutions.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:33770 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758911AbcJROIo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 10:08:44 -0400
Received: by mail-qk0-f171.google.com with SMTP id n189so294584650qke.0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 07:08:44 -0700 (PDT)
In-Reply-To: <1476799713-16188-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we can no longer invoke AEAD transforms with the aead_request
structure allocated on the stack, we perform a kmalloc/kfree for every
packet, which is expensive.

Since the CCMP routines execute in softirq context, we know there can
never be more than one request in flight on each CPU, and so we can
simply keep a cached aead_request structure per CPU, and deallocate all
of them when deallocating the AEAD transform.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 net/mac80211/aes_ccm.c | 49 ++++++++++++++------
 net/mac80211/key.h     |  1 +
 2 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index 58e0338a2c34..2cb5ee4868ea 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -28,9 +28,14 @@ int ieee80211_aes_ccm_encrypt(struct ieee80211_ccmp_aead *ccmp, u8 *b_0,
 	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(ccmp->tfm);
 	u8 *__aad;
 
-	aead_req = kzalloc(reqsize + CCM_AAD_LEN, GFP_ATOMIC);
-	if (!aead_req)
-		return -ENOMEM;
+	aead_req = *this_cpu_ptr(ccmp->reqs);
+	if (!aead_req) {
+		aead_req = kzalloc(reqsize + CCM_AAD_LEN, GFP_ATOMIC);
+		if (!aead_req)
+			return -ENOMEM;
+		*this_cpu_ptr(ccmp->reqs) = aead_req;
+		aead_request_set_tfm(aead_req, ccmp->tfm);
+	}
 
 	__aad = (u8 *)aead_req + reqsize;
 	memcpy(__aad, aad, CCM_AAD_LEN);
@@ -40,12 +45,10 @@ int ieee80211_aes_ccm_encrypt(struct ieee80211_ccmp_aead *ccmp, u8 *b_0,
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, mic_len);
 
-	aead_request_set_tfm(aead_req, ccmp->tfm);
 	aead_request_set_crypt(aead_req, sg, sg, data_len, b_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
 	crypto_aead_encrypt(aead_req);
-	kzfree(aead_req);
 
 	return 0;
 }
@@ -58,14 +61,18 @@ int ieee80211_aes_ccm_decrypt(struct ieee80211_ccmp_aead *ccmp, u8 *b_0,
 	struct aead_request *aead_req;
 	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(ccmp->tfm);
 	u8 *__aad;
-	int err;
 
 	if (data_len == 0)
 		return -EINVAL;
 
-	aead_req = kzalloc(reqsize + CCM_AAD_LEN, GFP_ATOMIC);
-	if (!aead_req)
-		return -ENOMEM;
+	aead_req = *this_cpu_ptr(ccmp->reqs);
+	if (!aead_req) {
+		aead_req = kzalloc(reqsize + CCM_AAD_LEN, GFP_ATOMIC);
+		if (!aead_req)
+			return -ENOMEM;
+		*this_cpu_ptr(ccmp->reqs) = aead_req;
+		aead_request_set_tfm(aead_req, ccmp->tfm);
+	}
 
 	__aad = (u8 *)aead_req + reqsize;
 	memcpy(__aad, aad, CCM_AAD_LEN);
@@ -75,14 +82,10 @@ int ieee80211_aes_ccm_decrypt(struct ieee80211_ccmp_aead *ccmp, u8 *b_0,
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, mic_len);
 
-	aead_request_set_tfm(aead_req, ccmp->tfm);
 	aead_request_set_crypt(aead_req, sg, sg, data_len + mic_len, b_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
-	err = crypto_aead_decrypt(aead_req);
-	kzfree(aead_req);
-
-	return err;
+	return crypto_aead_decrypt(aead_req);
 }
 
 int ieee80211_aes_key_setup_encrypt(struct ieee80211_ccmp_aead *ccmp,
@@ -91,6 +94,7 @@ int ieee80211_aes_key_setup_encrypt(struct ieee80211_ccmp_aead *ccmp,
 				    size_t mic_len)
 {
 	struct crypto_aead *tfm;
+	struct aead_request **r;
 	int err;
 
 	tfm = crypto_alloc_aead("ccm(aes)", 0, CRYPTO_ALG_ASYNC);
@@ -104,6 +108,14 @@ int ieee80211_aes_key_setup_encrypt(struct ieee80211_ccmp_aead *ccmp,
 	if (err)
 		goto free_aead;
 
+	/* allow a struct aead_request to be cached per cpu */
+	r = alloc_percpu(struct aead_request *);
+	if (!r) {
+		err = -ENOMEM;
+		goto free_aead;
+	}
+
+	ccmp->reqs = r;
 	ccmp->tfm = tfm;
 	return 0;
 
@@ -114,5 +126,14 @@ int ieee80211_aes_key_setup_encrypt(struct ieee80211_ccmp_aead *ccmp,
 
 void ieee80211_aes_key_free(struct ieee80211_ccmp_aead *ccmp)
 {
+	struct aead_request *req;
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		req = *per_cpu_ptr(ccmp->reqs, cpu);
+		if (req)
+			kzfree(req);
+	}
+	free_percpu(ccmp->reqs);
 	crypto_free_aead(ccmp->tfm);
 }
diff --git a/net/mac80211/key.h b/net/mac80211/key.h
index 1ec7a737ab79..f99ec46dc08f 100644
--- a/net/mac80211/key.h
+++ b/net/mac80211/key.h
@@ -89,6 +89,7 @@ struct ieee80211_key {
 			 */
 			u8 rx_pn[IEEE80211_NUM_TIDS + 1][IEEE80211_CCMP_PN_LEN];
 			struct crypto_aead *tfm;
+			struct aead_request * __percpu *reqs;
 			u32 replays; /* dot11RSNAStatsCCMPReplays */
 		} ccmp;
 		struct {
-- 
2.7.4
