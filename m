From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] softmac: export highest_supported_rate function
Date: Tue, 18 Jul 2006 21:34:56 +0100 (BST)
Message-ID: <20060718203456.C48348DEF41@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:33340 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932388AbWGRUew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 16:34:52 -0400
To: linville@tuxdriver.com
Cc: johannes@sipsolutions.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

zd1211 needs this functionality, no point duplicating it.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Acked-by: Johannes Berg <johannes@sipsolutions.net>

Index: linux/include/net/ieee80211softmac.h
===================================================================
--- linux.orig/include/net/ieee80211softmac.h
+++ linux/include/net/ieee80211softmac.h
@@ -279,6 +279,14 @@ extern void ieee80211softmac_fragment_lo
  * Note that the rates need to be sorted. */
 extern void ieee80211softmac_set_rates(struct net_device *dev, u8 count, u8 *rates);
 
+/* Finds the highest rate which is:
+ *  1. Present in ri (optionally a basic rate)
+ *  2. Supported by the device
+ *  3. Less than or equal to the user-defined rate
+ */
+extern u8 ieee80211softmac_highest_supported_rate(struct ieee80211softmac_device *mac,
+	struct ieee80211softmac_ratesinfo *ri, int basic_only);
+
 /* Helper function which advises you the rate at which a frame should be
  * transmitted at. */
 static inline u8 ieee80211softmac_suggest_txrate(struct ieee80211softmac_device *mac,
Index: linux/net/ieee80211/softmac/ieee80211softmac_module.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_module.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_module.c
@@ -179,21 +179,14 @@ int ieee80211softmac_ratesinfo_rate_supp
 	return 0;
 }
 
-/* Finds the highest rate which is:
- *  1. Present in ri (optionally a basic rate)
- *  2. Supported by the device
- *  3. Less than or equal to the user-defined rate
- */
-static u8 highest_supported_rate(struct ieee80211softmac_device *mac,
+u8 ieee80211softmac_highest_supported_rate(struct ieee80211softmac_device *mac,
 	struct ieee80211softmac_ratesinfo *ri, int basic_only)
 {
 	u8 user_rate = mac->txrates.user_rate;
 	int i;
 
-	if (ri->count == 0) {
-		dprintk(KERN_ERR PFX "empty ratesinfo?\n");
+	if (ri->count == 0)
 		return IEEE80211_CCK_RATE_1MB;
-	}
 
 	for (i = ri->count - 1; i >= 0; i--) {
 		u8 rate = ri->rates[i];
@@ -209,6 +202,7 @@ static u8 highest_supported_rate(struct 
 	/* If we haven't found a suitable rate by now, just trust the user */
 	return user_rate;
 }
+EXPORT_SYMBOL_GPL(ieee80211softmac_highest_supported_rate);
 
 void ieee80211softmac_process_erp(struct ieee80211softmac_device *mac,
 	u8 erp_value)
@@ -244,13 +238,13 @@ void ieee80211softmac_recalc_txrates(str
 	u32 change = 0;
 
 	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
-	txrates->default_rate = highest_supported_rate(mac, &mac->bssinfo.supported_rates, 0);
+	txrates->default_rate = ieee80211softmac_highest_supported_rate(mac, &mac->bssinfo.supported_rates, 0);
 
 	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK;
 	txrates->default_fallback = lower_rate(mac, txrates->default_rate);
 
 	change |= IEEE80211SOFTMAC_TXRATECHG_MCAST;
-	txrates->mcast_rate = highest_supported_rate(mac, &mac->bssinfo.supported_rates, 1);
+	txrates->mcast_rate = ieee80211softmac_highest_supported_rate(mac, &mac->bssinfo.supported_rates, 1);
 
 	if (mac->txrates_change)
 		mac->txrates_change(mac->dev, change);
