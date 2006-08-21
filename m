From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 3/7] ieee80211: TKIP and CCMP replay check rework
Date: Mon, 21 Aug 2006 11:33:09 +0800
Message-ID: <20060821033309.GA4784@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24860 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932548AbWHUDfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:35:04 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use time_after() to handle jiffies wrapping.

Signed-off-by: Hong Liu <hong.liu@intel.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/ieee80211/ieee80211_crypt_ccmp.c |   23 ++++++++++++++++++++++-
 net/ieee80211/ieee80211_crypt_tkip.c |   16 ++++++++++++++--
 2 files changed, 36 insertions(+), 3 deletions(-)

c262e06687a20f13608e376be64c4806611fc46c
diff --git a/net/ieee80211/ieee80211_crypt_ccmp.c b/net/ieee80211/ieee80211_crypt_ccmp.c
index ed90a8a..6c98408 100644
--- a/net/ieee80211/ieee80211_crypt_ccmp.c
+++ b/net/ieee80211/ieee80211_crypt_ccmp.c
@@ -271,6 +271,27 @@ static int ieee80211_ccmp_encrypt(struct
 	return 0;
 }
 
+/*
+ * deal with seq counter wrapping correctly.
+ * refer to timer_after() for jiffies wrapping handling
+ */
+static inline int ccmp_replay_check(u8 *pn_n, u8 *pn_o)
+{
+	u32 iv32_n, iv16_n;
+	u32 iv32_o, iv16_o;
+	
+	iv32_n = (pn_n[0] << 24) | (pn_n[1] << 16) | (pn_n[2] << 8) | pn_n[3];
+	iv16_n = (pn_n[4] << 8) | pn_n[5];
+
+	iv32_o = (pn_o[0] << 24) | (pn_o[1] << 16) | (pn_o[2] << 8) | pn_o[3];
+	iv16_o = (pn_o[4] << 8) | pn_o[5]; 
+
+	if ((s32)iv32_n - (s32)iv32_o < 0 ||
+	    (iv32_n == iv32_o && iv16_n <= iv16_o))
+		return 1;
+	return 0;
+}
+
 static int ieee80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 {
 	struct ieee80211_ccmp_data *key = priv;
@@ -323,7 +344,7 @@ static int ieee80211_ccmp_decrypt(struct
 	pn[5] = pos[0];
 	pos += 8;
 
-	if (memcmp(pn, key->rx_pn, CCMP_PN_LEN) <= 0) {
+	if (ccmp_replay_check(pn, key->rx_pn)) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "CCMP: replay detected: STA=" MAC_FMT
 			       " previous PN %02x%02x%02x%02x%02x%02x "
diff --git a/net/ieee80211/ieee80211_crypt_tkip.c b/net/ieee80211/ieee80211_crypt_tkip.c
index a61b09e..02abf29 100644
--- a/net/ieee80211/ieee80211_crypt_tkip.c
+++ b/net/ieee80211/ieee80211_crypt_tkip.c
@@ -360,6 +360,19 @@ static int ieee80211_tkip_encrypt(struct
 	return 0;
 }
 
+/*
+ * deal with seq counter wrapping correctly.
+ * refer to timer_after() for jiffies wrapping handling
+ */
+static inline int tkip_replay_check(u32 iv32_n, u16 iv16_n,
+				    u32 iv32_o, u16 iv16_o)
+{
+	if ((s32)iv32_n - (s32)iv32_o < 0 ||
+	    (iv32_n == iv32_o && iv16_n <= iv16_o))
+		return 1;
+	return 0;
+}
+
 static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 {
 	struct ieee80211_tkip_data *tkey = priv;
@@ -414,8 +427,7 @@ static int ieee80211_tkip_decrypt(struct
 	iv32 = pos[4] | (pos[5] << 8) | (pos[6] << 16) | (pos[7] << 24);
 	pos += 8;
 
-	if (iv32 < tkey->rx_iv32 ||
-	    (iv32 == tkey->rx_iv32 && iv16 <= tkey->rx_iv16)) {
+	if (tkip_replay_check(iv32, iv16, tkey->rx_iv32, tkey->rx_iv16)) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "TKIP: replay detected: STA=" MAC_FMT
 			       " previous TSC %08x%04x received TSC "
-- 
1.2.6
