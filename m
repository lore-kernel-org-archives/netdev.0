From: behanw@converseincode.com
Subject: [PATCH v2] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Fri,  7 Mar 2014 17:26:00 -0800
Message-ID: <1394241960-1764-1-git-send-email-behanw@converseincode.com>
References: <1394177091.4653.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dwmw2@infradead.org,
	pageexec@freemail.hu,
	=?UTF-8?q?Jan-Simon=20M=C3=B6ller?= <dl9pf@gmx.de>,
	Behan Webster <behanw@converseincode.com>,
	=?UTF-8?q?Vin=C3=ADcius=20Tinti?= <viniciustinti@gmail.com>,
	Mark Charlebois <charlebm@gmail.com>
To: linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394177091.4653.1.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Jan-Simon M=C3=B6ller <dl9pf@gmx.de>

Replaced the use of a Variable Length Array In Struct (VLAIS) with a C9=
9
compliant equivalent. This is the original VLAIS struct.

struct {
	struct aead_request     req;
	u8                      priv[crypto_aead_reqsize(tfm)];
} aead_req;

This patch instead allocates the appropriate amount of memory using an =
char
array.

The new code can be compiled with both gcc and clang.

Signed-off-by: Jan-Simon M=C3=B6ller <dl9pf@gmx.de>
Signed-off-by: Behan Webster <behanw@converseincode.com>
Signed-off-by: Vin=C3=ADcius Tinti <viniciustinti@gmail.com>
Signed-off-by: Mark Charlebois <charlebm@gmail.com>
---
 net/mac80211/aes_ccm.c | 40 ++++++++++++++++++++++------------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index 7c7df47..3317578 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -23,12 +23,14 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *=
tfm, u8 *b_0, u8 *aad,
 			       u8 *data, size_t data_len, u8 *mic)
 {
 	struct scatterlist assoc, pt, ct[2];
-	struct {
-		struct aead_request	req;
-		u8			priv[crypto_aead_reqsize(tfm)];
-	} aead_req;
=20
-	memset(&aead_req, 0, sizeof(aead_req));
+	char aead_req_data[sizeof(struct aead_request) +
+				crypto_aead_reqsize(tfm) +
+				CRYPTO_MINALIGN] CRYPTO_MINALIGN_ATTR;
+
+	struct aead_request *aead_req =3D (void *) aead_req_data;
+
+	memset(aead_req, 0, sizeof(aead_req_data));
=20
 	sg_init_one(&pt, data, data_len);
 	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
@@ -36,23 +38,25 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *=
tfm, u8 *b_0, u8 *aad,
 	sg_set_buf(&ct[0], data, data_len);
 	sg_set_buf(&ct[1], mic, IEEE80211_CCMP_MIC_LEN);
=20
-	aead_request_set_tfm(&aead_req.req, tfm);
-	aead_request_set_assoc(&aead_req.req, &assoc, assoc.length);
-	aead_request_set_crypt(&aead_req.req, &pt, ct, data_len, b_0);
+	aead_request_set_tfm(aead_req, tfm);
+	aead_request_set_assoc(aead_req, &assoc, assoc.length);
+	aead_request_set_crypt(aead_req, &pt, ct, data_len, b_0);
=20
-	crypto_aead_encrypt(&aead_req.req);
+	crypto_aead_encrypt(aead_req);
 }
=20
 int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aa=
d,
 			      u8 *data, size_t data_len, u8 *mic)
 {
 	struct scatterlist assoc, pt, ct[2];
-	struct {
-		struct aead_request	req;
-		u8			priv[crypto_aead_reqsize(tfm)];
-	} aead_req;
=20
-	memset(&aead_req, 0, sizeof(aead_req));
+	char aead_req_data[sizeof(struct aead_request) +
+				crypto_aead_reqsize(tfm) +
+				CRYPTO_MINALIGN] CRYPTO_MINALIGN_ATTR;
+
+	struct aead_request *aead_req =3D (void *) aead_req_data;
+
+	memset(aead_req, 0, sizeof(aead_req_data));
=20
 	sg_init_one(&pt, data, data_len);
 	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
@@ -60,12 +64,12 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *t=
fm, u8 *b_0, u8 *aad,
 	sg_set_buf(&ct[0], data, data_len);
 	sg_set_buf(&ct[1], mic, IEEE80211_CCMP_MIC_LEN);
=20
-	aead_request_set_tfm(&aead_req.req, tfm);
-	aead_request_set_assoc(&aead_req.req, &assoc, assoc.length);
-	aead_request_set_crypt(&aead_req.req, ct, &pt,
+	aead_request_set_tfm(aead_req, tfm);
+	aead_request_set_assoc(aead_req, &assoc, assoc.length);
+	aead_request_set_crypt(aead_req, ct, &pt,
 			       data_len + IEEE80211_CCMP_MIC_LEN, b_0);
=20
-	return crypto_aead_decrypt(&aead_req.req);
+	return crypto_aead_decrypt(aead_req);
 }
=20
 struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[])
--=20
1.8.3.2
