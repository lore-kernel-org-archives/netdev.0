From: Hong Liu <hong.liu@intel.com>
Subject: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Fri, 20 Oct 2006 17:19:36 +0800
Message-ID: <1161335976.21402.11.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19464 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S932209AbWJTJ0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 05:26:13 -0400
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipw3945 TKIP hwcrypto only support RC4 encryption,
so the stack needs to pre compute the michael MIC and the RC4key
for it.

Signed-off-by: Hong Liu <hong.liu@intel.com>

---

 include/net/d80211.h |    7 +++++++
 net/d80211/tkip.c    |   25 +++++++++++++++----------
 net/d80211/tkip.h    |    2 ++
 net/d80211/wpa.c     |   10 +++++++++-
 4 files changed, 33 insertions(+), 11 deletions(-)

a759f6251a0a5c7a8529c2ebd579acd6f0183cb4
diff --git a/include/net/d80211.h b/include/net/d80211.h
index a80f48b..48e1e01 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -176,6 +176,7 @@ struct ieee80211_tx_control {
 			*/
 	int icv_len:8; /* Length of the ICV/MIC field in octets */
 	int iv_len:8; /* Length of the IV field in octets */
+	u8 rc4key[16]; /* generated RC4 key for hw TKIP */
 	unsigned int queue:4; /* hardware queue to use for this frame;
 		      * 0 = highest, hw->queues-1 = lowest */
 	unsigned int sw_retry_attempt:4; /* no. of times hw has tried to
@@ -476,6 +477,12 @@ struct ieee80211_hw {
 	/* Force software encryption for TKIP packets if WMM is enabled. */
 	unsigned int no_tkip_wmm_hwaccel:1;
 
+	/* Do TKIP key mixing in stack, send the generated RC4 key with
+	 * with each TX frame */
+	unsigned int tkip_include_rc4key:1;
+	/* calculate michael MIC in stack */
+	unsigned int tkip_include_mmic:1;
+
 	/* set if the payload needs to be padded at even boundaries after the
 	 * header */
 	unsigned int extra_hdr_room:1;
diff --git a/net/d80211/tkip.c b/net/d80211/tkip.c
index 7e3665a..c031814 100644
--- a/net/d80211/tkip.c
+++ b/net/d80211/tkip.c
@@ -190,17 +190,9 @@ u8 * ieee80211_tkip_add_iv(u8 *pos, stru
 	return pos;
 }
 
-
-/* Encrypt packet payload with TKIP using @key. @pos is a pointer to the
- * beginning of the buffer containing payload. This payload must include
- * headroom of eight octets for IV and Ext. IV and taildroom of four octets
- * for ICV. @payload_len is the length of payload (_not_ including extra
- * headroom and tailroom). @ta is the transmitter addresses. */
-void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
-				 u8 *pos, size_t payload_len, u8 *ta)
+void ieee80211_tkip_gen_rc4key(struct ieee80211_key *key,
+			       u8 *rc4key, u8* ta)
 {
-	u8 rc4key[16];
-
 	/* Calculate per-packet key */
 	if (key->u.tkip.iv16 == 0 || !key->u.tkip.tx_initialized) {
 		/* IV16 wrapped around - perform TKIP phase 1 */
@@ -212,6 +204,19 @@ void ieee80211_tkip_encrypt_data(struct 
 	tkip_mixing_phase2(key->u.tkip.p1k, &key->key[ALG_TKIP_TEMP_ENCR_KEY],
 			   key->u.tkip.iv16, rc4key);
 
+}
+
+/* Encrypt packet payload with TKIP using @key. @pos is a pointer to the
+ * beginning of the buffer containing payload. This payload must include
+ * headroom of eight octets for IV and Ext. IV and taildroom of four octets
+ * for ICV. @payload_len is the length of payload (_not_ including extra
+ * headroom and tailroom). @ta is the transmitter addresses. */
+void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+				 u8 *pos, size_t payload_len, u8 *ta)
+{
+	u8 rc4key[16];
+
+	ieee80211_tkip_gen_rc4key(key, rc4key, ta);
 	pos = ieee80211_tkip_add_iv(pos, key, rc4key[0], rc4key[1], rc4key[2]);
 	ieee80211_wep_encrypt_data(tfm, rc4key, 16, pos, payload_len);
 }
diff --git a/net/d80211/tkip.h b/net/d80211/tkip.h
index e36b85c..407556b 100644
--- a/net/d80211/tkip.h
+++ b/net/d80211/tkip.h
@@ -15,6 +15,8 @@ #include "ieee80211_key.h"
 
 u8 * ieee80211_tkip_add_iv(u8 *pos, struct ieee80211_key *key,
 			   u8 iv0, u8 iv1, u8 iv2);
+void ieee80211_tkip_gen_rc4key(struct ieee80211_key *key,
+			       u8 *rc4key, u8* ta);
 void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
 				 u8 *pos, size_t payload_len, u8 *ta);
 enum {
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index 31abf9b..5e62464 100644
--- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -104,7 +104,8 @@ #ifdef CONFIG_HOSTAPD_WPA_TESTING
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	if (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt &&
-	    !tx->fragmented && !wpa_test) {
+	    !tx->fragmented && !tx->local->hw->tkip_include_mmic &&
+	    !wpa_test) {
 		/* hwaccel - with no need for preallocated room for Michael MIC
 		 */
 		return TXRX_CONTINUE;
@@ -336,6 +337,13 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 					    0x7f),
 				      (u8) key->u.tkip.iv16);
 
+		if (tx->local->hw->tkip_include_rc4key) {
+			hdr = (struct ieee80211_hdr *)skb->data;
+			ieee80211_tkip_gen_rc4key(key,
+						  tx->u.tx.control->rc4key,
+						  hdr->addr2);
+		}
+
 		tx->u.tx.control->key_idx = tx->key->hw_key_idx;
 		return 0;
 	}
-- 
1.3.3

