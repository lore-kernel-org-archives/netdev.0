From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH resend] softmac: suggest per-frame-type TX rate
Date: Mon,  1 May 2006 22:45:50 +0100 (BST)
Message-ID: <20060501214550.A5914887A13@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:17311 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932277AbWEAVpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 17:45:45 -0400
To: linville@tuxdriver.com
Cc: johannes@sipsolutions.net
Cc: softmac-dev@sipsolutions.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is the first step towards rate control inside softmac.

The txrates substructure has been extended to provide different fields for
different types of packets (management/data, unicast/multicast). These fields
are updated on association to values compatible with the access point we are
associating to.

Drivers can then use the new ieee80211softmac_suggest_txrate() function call
when deciding which rate to transmit each frame at. This is immensely useful
for ZD1211, and bcm can use it too.

The user can still specify a rate through iwconfig, which is matched for all
transmissions (assuming the rate they have specified is in the rate set
required by the AP).

At a later date, we can incorporate automatic rate management into the 
ieee80211softmac_recalc_txrates() function.

This patch also removes the mcast_fallback field. Sam Leffler pointed out that
this field is meaningless, because no driver will ever be retransmitting mcast
frames (they are not acked).

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Acked-by: Johannes Berg <johannes@sipsolutions.net>

--

Rediffed against my other recent patches.
Also, even though this patch modifies the softmac API
(ieee80211softmac_txrates), this should not cause any breakage because nobody
uses that yet.

Index: linux-2.6.17-rc3/include/net/ieee80211softmac.h
===================================================================
--- linux-2.6.17-rc3.orig/include/net/ieee80211softmac.h
+++ linux-2.6.17-rc3/include/net/ieee80211softmac.h
@@ -86,6 +86,9 @@ struct ieee80211softmac_assoc_info {
 	
 	/* BSSID we're trying to associate to */
 	char bssid[ETH_ALEN];
+
+	/* Rates supported by the network */
+	struct ieee80211softmac_ratesinfo supported_rates;
 	
 	/* some flags.
 	 * static_essid is valid if the essid is constant,
@@ -132,23 +135,26 @@ enum {
 struct ieee80211softmac_txrates {
 	/* The Bit-Rate to be used for multicast frames. */
 	u8 mcast_rate;
-	/* The Bit-Rate to be used for multicast fallback
-	 * (If the device supports fallback and hardware-retry)
-	 */
-	u8 mcast_fallback;
+
+	/* The Bit-Rate to be used for multicast management frames. */
+	u8 mgt_mcast_rate;
+
 	/* The Bit-Rate to be used for any other (normal) data packet. */
 	u8 default_rate;
 	/* The Bit-Rate to be used for default fallback
 	 * (If the device supports fallback and hardware-retry)
 	 */
 	u8 default_fallback;
+
+	/* This is the rate that the user asked for */
+	u8 user_rate;
 };
 
 /* Bits for txrates_change callback. */
 #define IEEE80211SOFTMAC_TXRATECHG_DEFAULT		(1 << 0) /* default_rate */
 #define IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK	(1 << 1) /* default_fallback */
 #define IEEE80211SOFTMAC_TXRATECHG_MCAST		(1 << 2) /* mcast_rate */
-#define IEEE80211SOFTMAC_TXRATECHG_MCAST_FBACK		(1 << 3) /* mcast_fallback */
+#define IEEE80211SOFTMAC_TXRATECHG_MGT_MCAST		(1 << 3) /* mgt_mcast_rate */
 
 struct ieee80211softmac_device {
 	/* 802.11 structure for data stuff */
@@ -250,6 +256,28 @@ extern void ieee80211softmac_fragment_lo
  * Note that the rates need to be sorted. */
 extern void ieee80211softmac_set_rates(struct net_device *dev, u8 count, u8 *rates);
 
+/* Helper function which advises you the rate at which a frame should be
+ * transmitted at. */
+static inline u8 ieee80211softmac_suggest_txrate(struct ieee80211softmac_device *mac,
+						 int is_multicast,
+						 int is_mgt)
+{
+	struct ieee80211softmac_txrates *txrates = &mac->txrates;
+
+	if (!mac->associated)
+		return txrates->mgt_mcast_rate;
+
+	/* We are associated, sending unicast frame */
+	if (!is_multicast)
+		return txrates->default_rate;
+
+	/* We are associated, sending multicast frame */
+	if (is_mgt)
+		return txrates->mgt_mcast_rate;
+	else
+		return txrates->mcast_rate;
+}
+
 /* Start the SoftMAC. Call this after you initialized the device
  * and it is ready to run.
  */
Index: linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_assoc.c
===================================================================
--- linux-2.6.17-rc3.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -96,6 +96,7 @@ ieee80211softmac_disassoc(struct ieee802
 	mac->associated = 0;
 	mac->associnfo.bssvalid = 0;
 	mac->associnfo.associating = 0;
+	ieee80211softmac_init_txrates(mac);
 	ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
 	spin_unlock_irqrestore(&mac->lock, flags);
 }
@@ -118,24 +119,15 @@ ieee80211softmac_send_disassoc_req(struc
 static inline int
 we_support_all_basic_rates(struct ieee80211softmac_device *mac, u8 *from, u8 from_len)
 {
-	int idx, search, found;
-	u8 rate, search_rate;
+	int idx;
+	u8 rate;
 
 	for (idx = 0; idx < (from_len); idx++) {
 		rate = (from)[idx];
 		if (!(rate & IEEE80211_BASIC_RATE_MASK))
 			continue;
-		found = 0;
 		rate &= ~IEEE80211_BASIC_RATE_MASK;
-		for (search = 0; search < mac->ratesinfo.count; search++) {
-			search_rate = mac->ratesinfo.rates[search];
-			search_rate &= ~IEEE80211_BASIC_RATE_MASK;
-			if (rate == search_rate) {
-				found = 1;
-				break;
-			}
-		}
-		if (!found)
+		if (!ieee80211softmac_ratesinfo_rate_supported(&mac->ratesinfo, rate))
 			return 0;
 	}
 	return 1;
@@ -310,6 +302,9 @@ ieee80211softmac_associated(struct ieee8
 	struct ieee80211softmac_network *net)
 {
 	mac->associnfo.associating = 0;
+	mac->associnfo.supported_rates = net->supported_rates;
+	ieee80211softmac_recalc_txrates(mac);
+
 	mac->associated = 1;
 	if (mac->set_bssid_filter)
 		mac->set_bssid_filter(mac->dev, net->bssid);
Index: linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_module.c
===================================================================
--- linux-2.6.17-rc3.orig/net/ieee80211/softmac/ieee80211softmac_module.c
+++ linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_module.c
@@ -26,6 +26,7 @@
 
 #include "ieee80211softmac_priv.h"
 #include <linux/sort.h>
+#include <linux/etherdevice.h>
 
 struct net_device *alloc_ieee80211softmac(int sizeof_priv)
 {
@@ -61,14 +62,6 @@ struct net_device *alloc_ieee80211softma
 	softmac->wait_for_scan = ieee80211softmac_wait_for_scan_implementation;
 	softmac->stop_scan = ieee80211softmac_stop_scan_implementation;
 
-	//TODO: The mcast rate has to be assigned dynamically somewhere (in scanning, association. Not sure...)
-	//      It has to be set to the highest rate all stations in the current network can handle.
-	softmac->txrates.mcast_rate = IEEE80211_CCK_RATE_1MB;
-	softmac->txrates.mcast_fallback = IEEE80211_CCK_RATE_1MB;
-	/* This is reassigned in ieee80211softmac_start to sane values. */
-	softmac->txrates.default_rate = IEEE80211_CCK_RATE_1MB;
-	softmac->txrates.default_fallback = IEEE80211_CCK_RATE_1MB;
-
 	/* to start with, we can't send anything ... */
 	netif_carrier_off(dev);
 	
@@ -170,15 +163,82 @@ static void ieee80211softmac_start_check
 	}
 }
 
-void ieee80211softmac_start(struct net_device *dev)
+int ieee80211softmac_ratesinfo_rate_supported(struct ieee80211softmac_ratesinfo *ri, u8 rate)
+{
+	int search;
+	u8 search_rate;
+
+	for (search = 0; search < ri->count; search++) {
+		search_rate = ri->rates[search];
+		search_rate &= ~IEEE80211_BASIC_RATE_MASK;
+		if (rate == search_rate)
+			return 1;
+	}
+
+	return 0;
+}
+
+/* Finds the highest rate which is:
+ *  1. Present in ri (optionally a basic rate)
+ *  2. Supported by the device
+ *  3. Less than or equal to the user-defined rate
+ */
+static u8 highest_supported_rate(struct ieee80211softmac_device *mac,
+	struct ieee80211softmac_ratesinfo *ri, int basic_only)
+{
+	u8 user_rate = mac->txrates.user_rate;
+	int i;
+
+	if (ri->count == 0) {
+		dprintk(KERN_ERR PFX "empty ratesinfo?\n");
+		return IEEE80211_CCK_RATE_1MB;
+	}
+
+	for (i = ri->count - 1; i >= 0; i--) {
+		u8 rate = ri->rates[i];
+		if (basic_only && !(rate & IEEE80211_BASIC_RATE_MASK))
+			continue;
+		rate &= ~IEEE80211_BASIC_RATE_MASK;
+		if (rate > user_rate)
+			continue;
+		if (ieee80211softmac_ratesinfo_rate_supported(&mac->ratesinfo, rate))
+			return rate;
+	}
+
+	/* If we haven't found a suitable rate by now, just trust the user */
+	return user_rate;
+}
+
+void ieee80211softmac_recalc_txrates(struct ieee80211softmac_device *mac)
+{
+	struct ieee80211softmac_txrates *txrates = &mac->txrates;
+	struct ieee80211softmac_txrates oldrates;
+	u32 change = 0;
+
+	if (mac->txrates_change)
+		oldrates = mac->txrates;
+
+	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
+	txrates->default_rate = highest_supported_rate(mac, &mac->associnfo.supported_rates, 0);
+
+	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK;
+	txrates->default_fallback = lower_rate(mac, txrates->default_rate);
+
+	change |= IEEE80211SOFTMAC_TXRATECHG_MCAST;
+	txrates->mcast_rate = highest_supported_rate(mac, &mac->associnfo.supported_rates, 1);
+
+	if (mac->txrates_change)
+		mac->txrates_change(mac->dev, change, &oldrates);
+
+}
+
+void ieee80211softmac_init_txrates(struct ieee80211softmac_device *mac)
 {
-	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 	struct ieee80211_device *ieee = mac->ieee;
 	u32 change = 0;
+	struct ieee80211softmac_txrates *txrates = &mac->txrates;
 	struct ieee80211softmac_txrates oldrates;
 
-	ieee80211softmac_start_check_rates(mac);
-
 	/* TODO: We need some kind of state machine to lower the default rates
 	 *       if we loose too many packets.
 	 */
@@ -193,22 +253,37 @@ void ieee80211softmac_start(struct net_d
 	   more reliable. Note similar logic in
 	   ieee80211softmac_wx_set_rate() */	 
 	if (ieee->modulation & IEEE80211_CCK_MODULATION) {
-		mac->txrates.default_rate = IEEE80211_CCK_RATE_11MB;
-		change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
-		mac->txrates.default_fallback = IEEE80211_CCK_RATE_5MB;
-		change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK;
+		txrates->user_rate = IEEE80211_CCK_RATE_11MB;
 	} else if (ieee->modulation & IEEE80211_OFDM_MODULATION) {
-		mac->txrates.default_rate = IEEE80211_OFDM_RATE_54MB;
-		change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
-		mac->txrates.default_fallback = IEEE80211_OFDM_RATE_24MB;
-		change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK;
+		txrates->user_rate = IEEE80211_OFDM_RATE_54MB;
 	} else
 		assert(0);
+
+	txrates->default_rate = IEEE80211_CCK_RATE_1MB;
+	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
+
+	txrates->default_fallback = IEEE80211_CCK_RATE_1MB;
+	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK;
+
+	txrates->mcast_rate = IEEE80211_CCK_RATE_1MB;
+	change |= IEEE80211SOFTMAC_TXRATECHG_MCAST;
+
+	txrates->mgt_mcast_rate = IEEE80211_CCK_RATE_1MB;
+	change |= IEEE80211SOFTMAC_TXRATECHG_MGT_MCAST;
+
 	if (mac->txrates_change)
-		mac->txrates_change(dev, change, &oldrates);
+		mac->txrates_change(mac->dev, change, &oldrates);
 
 	mac->running = 1;
 }
+
+void ieee80211softmac_start(struct net_device *dev)
+{
+	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
+
+	ieee80211softmac_start_check_rates(mac);
+	ieee80211softmac_init_txrates(mac);
+}
 EXPORT_SYMBOL_GPL(ieee80211softmac_start);
 
 void ieee80211softmac_stop(struct net_device *dev)
Index: linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_wx.c
===================================================================
--- linux-2.6.17-rc3.orig/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -211,8 +211,8 @@ ieee80211softmac_wx_set_rate(struct net_
 	if (is_ofdm && !(ieee->modulation & IEEE80211_OFDM_MODULATION))
 		goto out_unlock;
 
-	mac->txrates.default_rate = rate;
-	mac->txrates.default_fallback = lower_rate(mac, rate);
+	mac->txrates.user_rate = rate;
+	ieee80211softmac_recalc_txrates(mac);
 	err = 0;
 
 out_unlock:	
Index: linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_priv.h
===================================================================
--- linux-2.6.17-rc3.orig/net/ieee80211/softmac/ieee80211softmac_priv.h
+++ linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_priv.h
@@ -116,7 +116,10 @@ ieee80211softmac_get_network_by_essid(st
 	struct ieee80211softmac_essid *essid);
 
 /* Rates related */
+int ieee80211softmac_ratesinfo_rate_supported(struct ieee80211softmac_ratesinfo *ri, u8 rate);
 u8 ieee80211softmac_lower_rate_delta(struct ieee80211softmac_device *mac, u8 rate, int delta);
+void ieee80211softmac_init_txrates(struct ieee80211softmac_device *mac);
+void ieee80211softmac_recalc_txrates(struct ieee80211softmac_device *mac);
 static inline u8 lower_rate(struct ieee80211softmac_device *mac, u8 rate) {
 	return ieee80211softmac_lower_rate_delta(mac, rate, 1);
 }
