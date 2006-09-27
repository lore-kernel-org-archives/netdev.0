From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 8/14] d80211: fix WEP on big endian cpus
Date: Wed, 27 Sep 2006 17:50:53 +0200 (CEST)
Message-ID: <20060927155053.0CFD13BA251@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50572 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964977AbWI0Pts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:48 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice@sourmilk.net>

This patch fixes the endian issues with the ICV in WEP, as pointed out by
David Kimdon <david.kimdon@devicescape.com>, and uses __le32 where
appropriate to make things clear.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/wep.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

adcdddba34181486f2a1b402f39d66fe05f42595
diff --git a/net/d80211/wep.c b/net/d80211/wep.c
index c3e4728..22c2e53 100644
--- a/net/d80211/wep.c
+++ b/net/d80211/wep.c
@@ -120,10 +120,10 @@ void ieee80211_wep_encrypt_data(struct c
 				size_t klen, u8 *data, size_t data_len)
 {
 	struct scatterlist sg;
-	u32 *icv;
+	__le32 *icv;
 
-	icv = (u32 *)(data + data_len);
-	*icv = ~crc32_le(~0, data, data_len);
+	icv = (__le32 *)(data + data_len);
+	*icv = cpu_to_le32(~crc32_le(~0, data, data_len));
 
 	crypto_cipher_setkey(tfm, rc4key, klen);
 	sg.page = virt_to_page(data);
@@ -187,7 +187,7 @@ int ieee80211_wep_decrypt_data(struct cr
 			       size_t klen, u8 *data, size_t data_len)
 {
 	struct scatterlist sg;
-	u32 crc;
+	__le32 crc;
 
 	crypto_cipher_setkey(tfm, rc4key, klen);
 	sg.page = virt_to_page(data);
@@ -195,7 +195,7 @@ int ieee80211_wep_decrypt_data(struct cr
 	sg.length = data_len + WEP_ICV_LEN;
 	crypto_cipher_decrypt(tfm, &sg, &sg, sg.length);
 
-	crc = ~crc32_le(~0, data, data_len);
+	crc = cpu_to_le32(~crc32_le(~0, data, data_len));
 	if (memcmp(&crc, data + data_len, WEP_ICV_LEN) != 0)
 		/* ICV mismatch */
 		return -1;
-- 
1.3.0

