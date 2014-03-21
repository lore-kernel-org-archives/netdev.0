From: behanw-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org
Subject: [PATCH v4] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Thu, 20 Mar 2014 23:39:32 -0700
Message-ID: <1395383972-20372-1-git-send-email-behanw@converseincode.com>
References: <1395237113.4142.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	pageexec-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org,
	=?UTF-8?q?Jan-Simon=20M=C3=B6ller?= <dl9pf-Mmb7MZpHnFY@public.gmane.org>,
	Behan Webster <behanw-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org>,
	=?UTF-8?q?Vin=C3=ADcius=20Tinti?= <viniciustinti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Mark Charlebois <charlebm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1395237113.4142.5.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Jan-Simon M=C3=B6ller <dl9pf-Mmb7MZpHnFY@public.gmane.org>

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

Signed-off-by: Jan-Simon M=C3=B6ller <dl9pf-Mmb7MZpHnFY@public.gmane.org>
Signed-off-by: Behan Webster <behanw-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org>
Signed-off-by: Vin=C3=ADcius Tinti <viniciustinti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Mark Charlebois <charlebm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/mac80211/aes_ccm.c | 37 ++++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 19 deletions(-)

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index 7c7df47..71e2abd 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -23,12 +23,12 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *=
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
+				crypto_aead_reqsize(tfm)]
+				__aligned(__alignof__(struct aead_request));
+	struct aead_request *aead_req =3D (void *) aead_req_data;
+	memset(aead_req, 0, sizeof(aead_req_data));
=20
 	sg_init_one(&pt, data, data_len);
 	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
@@ -36,23 +36,22 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *=
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
-
-	memset(&aead_req, 0, sizeof(aead_req));
+	char aead_req_data[sizeof(struct aead_request) +
+				crypto_aead_reqsize(tfm)]
+				__aligned(__alignof__(struct aead_request));
+	struct aead_request *aead_req =3D (void *) aead_req_data;
+	memset(aead_req, 0, sizeof(aead_req_data));
=20
 	sg_init_one(&pt, data, data_len);
 	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
@@ -60,12 +59,12 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *t=
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
