From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] softmac: ERP handling and driver-level notifications
Date: Tue, 18 Jul 2006 21:33:27 +0100 (BST)
Message-ID: <20060718203327.EEDAB8DEF41@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:25334 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932387AbWGRUdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 16:33:25 -0400
To: linville@tuxdriver.com
Cc: johannes@sipsolutions.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements ERP handling in softmac so that the drivers can support
protection and preambles properly.

I added a new struct, ieee80211softmac_bss_info, which is used for
BSS-dependent variables like these.

A new hook has been added (bssinfo_change), which allows the drivers to be
notified when anything in bssinfo changes.

I modified the txrates_change API to match the bssinfo_change API. The
existing one is a little messy and the usefulness of providing the old rates
is questionable (and can be implemented at driver level if really necessary).
No drivers are using this API (yet), so this should be safe.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Acked-by: Johannes Berg <johannes@sipsolutions.net>

Index: linux/include/net/ieee80211softmac.h
===================================================================
--- linux.orig/include/net/ieee80211softmac.h
+++ linux/include/net/ieee80211softmac.h
@@ -86,9 +86,6 @@ struct ieee80211softmac_assoc_info {
 	
 	/* BSSID we're trying to associate to */
 	char bssid[ETH_ALEN];
-
-	/* Rates supported by the network */
-	struct ieee80211softmac_ratesinfo supported_rates;
 	
 	/* some flags.
 	 * static_essid is valid if the essid is constant,
@@ -103,6 +100,7 @@ struct ieee80211softmac_assoc_info {
 	 * bssfixed is used for SIOCSIWAP.
 	 */
 	u8 static_essid:1,
+	   short_preamble_available:1,
 	   associating:1,
 	   assoc_wait:1,
 	   bssvalid:1,
@@ -115,6 +113,19 @@ struct ieee80211softmac_assoc_info {
 	struct work_struct timeout;
 };
 
+struct ieee80211softmac_bss_info {
+	/* Rates supported by the network */
+	struct ieee80211softmac_ratesinfo supported_rates;
+
+	/* This indicates whether frames can currently be transmitted with
+	 * short preamble (only use this variable during TX at CCK rates) */
+	u8 short_preamble:1;
+
+	/* This indicates whether protection (e.g. self-CTS) should be used
+	 * when transmitting with OFDM modulation */
+	u8 use_protection:1;
+};
+
 enum {
 	IEEE80211SOFTMAC_AUTH_OPEN_REQUEST	= 1,
 	IEEE80211SOFTMAC_AUTH_OPEN_RESPONSE	= 2,
@@ -157,6 +168,10 @@ struct ieee80211softmac_txrates {
 #define IEEE80211SOFTMAC_TXRATECHG_MCAST		(1 << 2) /* mcast_rate */
 #define IEEE80211SOFTMAC_TXRATECHG_MGT_MCAST		(1 << 3) /* mgt_mcast_rate */
 
+#define IEEE80211SOFTMAC_BSSINFOCHG_RATES		(1 << 0) /* supported_rates */
+#define IEEE80211SOFTMAC_BSSINFOCHG_SHORT_PREAMBLE	(1 << 1) /* short_preamble */
+#define IEEE80211SOFTMAC_BSSINFOCHG_PROTECTION		(1 << 2) /* use_protection */
+
 struct ieee80211softmac_device {
 	/* 802.11 structure for data stuff */
 	struct ieee80211_device *ieee;
@@ -200,10 +215,16 @@ struct ieee80211softmac_device {
 	 * The driver just needs to read them.
 	 */
 	struct ieee80211softmac_txrates txrates;
-	/* If the driver needs to do stuff on TX rate changes, assign this callback. */
+
+	/* If the driver needs to do stuff on TX rate changes, assign this
+	 * callback. See IEEE80211SOFTMAC_TXRATECHG for change flags. */
 	void (*txrates_change)(struct net_device *dev,
-			       u32 changes, /* see IEEE80211SOFTMAC_TXRATECHG flags */
-			       const struct ieee80211softmac_txrates *rates_before_change);
+			       u32 changes);
+
+	/* If the driver needs to do stuff when BSS properties change, assign
+	 * this callback. see IEEE80211SOFTMAC_BSSINFOCHG for change flags. */
+	void (*bssinfo_change)(struct net_device *dev,
+			       u32 changes);
 
 	/* private stuff follows */
 	/* this lock protects this structure */
@@ -216,6 +237,7 @@ struct ieee80211softmac_device {
 	
 	struct ieee80211softmac_scaninfo *scaninfo;
 	struct ieee80211softmac_assoc_info associnfo;
+	struct ieee80211softmac_bss_info bssinfo;
 
 	struct list_head auth_queue;
 	struct list_head events;
@@ -279,6 +301,24 @@ static inline u8 ieee80211softmac_sugges
 		return txrates->mcast_rate;
 }
 
+/* Helper function which advises you when it is safe to transmit with short
+ * preamble.
+ * You should only call this function when transmitting at CCK rates. */
+static inline int ieee80211softmac_short_preamble_ok(struct ieee80211softmac_device *mac,
+						    int is_multicast,
+						    int is_mgt)
+{
+	return (is_multicast && is_mgt) ? 0 : mac->bssinfo.short_preamble;
+}
+
+/* Helper function which advises you whether protection (e.g. self-CTS) is
+ * needed. 1 = protection needed, 0 = no protection needed
+ * Only use this function when transmitting with OFDM modulation. */
+static inline int ieee80211softmac_protection_needed(struct ieee80211softmac_device *mac)
+{
+	return mac->bssinfo.use_protection;
+}
+
 /* Start the SoftMAC. Call this after you initialized the device
  * and it is ready to run.
  */
Index: linux/net/ieee80211/softmac/ieee80211softmac_assoc.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -96,7 +96,7 @@ ieee80211softmac_disassoc(struct ieee802
 	mac->associated = 0;
 	mac->associnfo.bssvalid = 0;
 	mac->associnfo.associating = 0;
-	ieee80211softmac_init_txrates(mac);
+	ieee80211softmac_init_bss(mac);
 	ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
 	spin_unlock_irqrestore(&mac->lock, flags);
 }
@@ -334,11 +334,19 @@ ieee80211softmac_associated(struct ieee8
 	struct ieee80211_assoc_response * resp,
 	struct ieee80211softmac_network *net)
 {
+	u16 cap = le16_to_cpu(resp->capability);
+	u8 erp_value = net->erp_value;
+
 	mac->associnfo.associating = 0;
-	mac->associnfo.supported_rates = net->supported_rates;
+	mac->bssinfo.supported_rates = net->supported_rates;
 	ieee80211softmac_recalc_txrates(mac);
 
 	mac->associated = 1;
+
+	mac->associnfo.short_preamble_available =
+		(cap & WLAN_CAPABILITY_SHORT_PREAMBLE) != 0;
+	ieee80211softmac_process_erp(mac, erp_value);
+
 	if (mac->set_bssid_filter)
 		mac->set_bssid_filter(mac->dev, net->bssid);
 	memcpy(mac->ieee->bssid, net->bssid, ETH_ALEN);
@@ -351,9 +359,9 @@ ieee80211softmac_associated(struct ieee8
 int
 ieee80211softmac_handle_assoc_response(struct net_device * dev,
 				       struct ieee80211_assoc_response * resp,
-				       struct ieee80211_network * _ieee80211_network_do_not_use)
+				       struct ieee80211_network * _ieee80211_network)
 {
-	/* NOTE: the network parameter has to be ignored by
+	/* NOTE: the network parameter has to be mostly ignored by
 	 *       this code because it is the ieee80211's pointer
 	 *       to the struct, not ours (we made a copy)
 	 */
@@ -385,6 +393,11 @@ ieee80211softmac_handle_assoc_response(s
 	/* now that we know it was for us, we can cancel the timeout */
 	cancel_delayed_work(&mac->associnfo.timeout);
 
+	/* if the association response included an ERP IE, update our saved
+	 * copy */
+	if (_ieee80211_network->flags & NETWORK_HAS_ERP_VALUE)
+		network->erp_value = _ieee80211_network->erp_value;
+
 	switch (status) {
 		case 0:
 			dprintk(KERN_INFO PFX "associated!\n");
Index: linux/net/ieee80211/softmac/ieee80211softmac_io.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_io.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_io.c
@@ -468,3 +468,17 @@ ieee80211softmac_send_mgt_frame(struct i
 	kfree(pkt);
 	return 0;
 }
+
+/* Beacon handling */
+int ieee80211softmac_handle_beacon(struct net_device *dev,
+	struct ieee80211_beacon *beacon,
+	struct ieee80211_network *network)
+{
+	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
+
+	if (mac->associated && memcmp(network->bssid, mac->associnfo.bssid, ETH_ALEN) == 0)
+		ieee80211softmac_process_erp(mac, network->erp_value);
+
+	return 0;
+}
+
Index: linux/net/ieee80211/softmac/ieee80211softmac_module.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_module.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_module.c
@@ -44,6 +44,7 @@ struct net_device *alloc_ieee80211softma
 	softmac->ieee->handle_assoc_response = ieee80211softmac_handle_assoc_response;
 	softmac->ieee->handle_reassoc_request = ieee80211softmac_handle_reassoc_req;
 	softmac->ieee->handle_disassoc = ieee80211softmac_handle_disassoc;
+ 	softmac->ieee->handle_beacon = ieee80211softmac_handle_beacon;
 	softmac->scaninfo = NULL;
 
 	softmac->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;
@@ -209,35 +210,59 @@ static u8 highest_supported_rate(struct 
 	return user_rate;
 }
 
+void ieee80211softmac_process_erp(struct ieee80211softmac_device *mac,
+	u8 erp_value)
+{
+ 	int use_protection;
+	int short_preamble;
+ 	u32 changes = 0;
+
+	/* Barker preamble mode */
+	short_preamble = ((erp_value & WLAN_ERP_BARKER_PREAMBLE) == 0
+			  && mac->associnfo.short_preamble_available) ? 1 : 0;
+
+	/* Protection needed? */
+	use_protection = (erp_value & WLAN_ERP_USE_PROTECTION) != 0;
+
+	if (mac->bssinfo.short_preamble != short_preamble) {
+		changes |= IEEE80211SOFTMAC_BSSINFOCHG_SHORT_PREAMBLE;
+		mac->bssinfo.short_preamble = short_preamble;
+	}
+
+	if (mac->bssinfo.use_protection != use_protection) {
+		changes |= IEEE80211SOFTMAC_BSSINFOCHG_PROTECTION;
+		mac->bssinfo.use_protection = use_protection;
+	}
+
+	if (mac->bssinfo_change && changes)
+		mac->bssinfo_change(mac->dev, changes);
+}
+
 void ieee80211softmac_recalc_txrates(struct ieee80211softmac_device *mac)
 {
 	struct ieee80211softmac_txrates *txrates = &mac->txrates;
-	struct ieee80211softmac_txrates oldrates;
 	u32 change = 0;
 
-	if (mac->txrates_change)
-		oldrates = mac->txrates;
-
 	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
-	txrates->default_rate = highest_supported_rate(mac, &mac->associnfo.supported_rates, 0);
+	txrates->default_rate = highest_supported_rate(mac, &mac->bssinfo.supported_rates, 0);
 
 	change |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT_FBACK;
 	txrates->default_fallback = lower_rate(mac, txrates->default_rate);
 
 	change |= IEEE80211SOFTMAC_TXRATECHG_MCAST;
-	txrates->mcast_rate = highest_supported_rate(mac, &mac->associnfo.supported_rates, 1);
+	txrates->mcast_rate = highest_supported_rate(mac, &mac->bssinfo.supported_rates, 1);
 
 	if (mac->txrates_change)
-		mac->txrates_change(mac->dev, change, &oldrates);
+		mac->txrates_change(mac->dev, change);
 
 }
 
-void ieee80211softmac_init_txrates(struct ieee80211softmac_device *mac)
+void ieee80211softmac_init_bss(struct ieee80211softmac_device *mac)
 {
 	struct ieee80211_device *ieee = mac->ieee;
 	u32 change = 0;
 	struct ieee80211softmac_txrates *txrates = &mac->txrates;
-	struct ieee80211softmac_txrates oldrates;
+	struct ieee80211softmac_bss_info *bssinfo = &mac->bssinfo;
 
 	/* TODO: We need some kind of state machine to lower the default rates
 	 *       if we loose too many packets.
@@ -245,8 +270,6 @@ void ieee80211softmac_init_txrates(struc
 	/* Change the default txrate to the highest possible value.
 	 * The txrate machine will lower it, if it is too high.
 	 */
-	if (mac->txrates_change)
-		oldrates = mac->txrates;
 	/* FIXME: We don't correctly handle backing down to lower
 	   rates, so 801.11g devices start off at 11M for now. People
 	   can manually change it if they really need to, but 11M is
@@ -272,7 +295,23 @@ void ieee80211softmac_init_txrates(struc
 	change |= IEEE80211SOFTMAC_TXRATECHG_MGT_MCAST;
 
 	if (mac->txrates_change)
-		mac->txrates_change(mac->dev, change, &oldrates);
+		mac->txrates_change(mac->dev, change);
+
+	change = 0;
+
+	bssinfo->supported_rates.count = 0;
+	memset(bssinfo->supported_rates.rates, 0,
+		sizeof(bssinfo->supported_rates.rates));
+	change |= IEEE80211SOFTMAC_BSSINFOCHG_RATES;
+
+	bssinfo->short_preamble = 0;
+	change |= IEEE80211SOFTMAC_BSSINFOCHG_SHORT_PREAMBLE;
+
+	bssinfo->use_protection = 0;
+	change |= IEEE80211SOFTMAC_BSSINFOCHG_PROTECTION;
+
+	if (mac->bssinfo_change)
+		mac->bssinfo_change(mac->dev, change);
 
 	mac->running = 1;
 }
@@ -282,7 +321,7 @@ void ieee80211softmac_start(struct net_d
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 
 	ieee80211softmac_start_check_rates(mac);
-	ieee80211softmac_init_txrates(mac);
+	ieee80211softmac_init_bss(mac);
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_start);
 
@@ -335,7 +374,6 @@ u8 ieee80211softmac_lower_rate_delta(str
 static void ieee80211softmac_add_txrates_badness(struct ieee80211softmac_device *mac,
 						 int amount)
 {
-	struct ieee80211softmac_txrates oldrates;
 	u8 default_rate = mac->txrates.default_rate;
 	u8 default_fallback = mac->txrates.default_fallback;
 	u32 changes = 0;
@@ -348,8 +386,6 @@ printk("badness %d\n", mac->txrate_badne
 	mac->txrate_badness += amount;
 	if (mac->txrate_badness <= -1000) {
 		/* Very small badness. Try a faster bitrate. */
-		if (mac->txrates_change)
-			memcpy(&oldrates, &mac->txrates, sizeof(oldrates));
 		default_rate = raise_rate(mac, default_rate);
 		changes |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
 		default_fallback = get_fallback_rate(mac, default_rate);
@@ -358,8 +394,6 @@ printk("badness %d\n", mac->txrate_badne
 printk("Bitrate raised to %u\n", default_rate);
 	} else if (mac->txrate_badness >= 10000) {
 		/* Very high badness. Try a slower bitrate. */
-		if (mac->txrates_change)
-			memcpy(&oldrates, &mac->txrates, sizeof(oldrates));
 		default_rate = lower_rate(mac, default_rate);
 		changes |= IEEE80211SOFTMAC_TXRATECHG_DEFAULT;
 		default_fallback = get_fallback_rate(mac, default_rate);
@@ -372,7 +406,7 @@ printk("Bitrate lowered to %u\n", defaul
 	mac->txrates.default_fallback = default_fallback;
 
 	if (changes && mac->txrates_change)
-		mac->txrates_change(mac->dev, changes, &oldrates);
+		mac->txrates_change(mac->dev, changes);
 }
 
 void ieee80211softmac_fragment_lost(struct net_device *dev,
@@ -416,7 +450,11 @@ ieee80211softmac_create_network(struct i
 	memcpy(&softnet->supported_rates.rates[softnet->supported_rates.count], net->rates_ex, net->rates_ex_len);
 	softnet->supported_rates.count += net->rates_ex_len;
 	sort(softnet->supported_rates.rates, softnet->supported_rates.count, sizeof(softnet->supported_rates.rates[0]), rate_cmp, NULL);
-	
+
+	/* we save the ERP value because it is needed at association time, and
+	 * many AP's do not include an ERP IE in the association response. */
+	softnet->erp_value = net->erp_value;
+
 	softnet->capabilities = net->capability;
 	return softnet;
 }
Index: linux/net/ieee80211/softmac/ieee80211softmac_priv.h
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_priv.h
+++ linux/net/ieee80211/softmac/ieee80211softmac_priv.h
@@ -116,9 +116,11 @@ ieee80211softmac_get_network_by_essid(st
 	struct ieee80211softmac_essid *essid);
 
 /* Rates related */
+void ieee80211softmac_process_erp(struct ieee80211softmac_device *mac,
+	u8 erp_value);
 int ieee80211softmac_ratesinfo_rate_supported(struct ieee80211softmac_ratesinfo *ri, u8 rate);
 u8 ieee80211softmac_lower_rate_delta(struct ieee80211softmac_device *mac, u8 rate, int delta);
-void ieee80211softmac_init_txrates(struct ieee80211softmac_device *mac);
+void ieee80211softmac_init_bss(struct ieee80211softmac_device *mac);
 void ieee80211softmac_recalc_txrates(struct ieee80211softmac_device *mac);
 static inline u8 lower_rate(struct ieee80211softmac_device *mac, u8 rate) {
 	return ieee80211softmac_lower_rate_delta(mac, rate, 1);
@@ -133,6 +135,9 @@ static inline u8 get_fallback_rate(struc
 /*** prototypes from _io.c */
 int ieee80211softmac_send_mgt_frame(struct ieee80211softmac_device *mac,
 	void* ptrarg, u32 type, u32 arg);
+int ieee80211softmac_handle_beacon(struct net_device *dev,
+	struct ieee80211_beacon *beacon,
+	struct ieee80211_network *network);
 
 /*** prototypes from _auth.c */
 /* do these have to go into the public header? */
@@ -189,6 +194,7 @@ struct ieee80211softmac_network {
 	    authenticated:1,
 	    auth_desynced_once:1;
 
+	u8 erp_value;				/* Saved ERP value */
 	u16 capabilities;			/* Capabilities bitfield */
 	u8 challenge_len;			/* Auth Challenge length */
 	char *challenge;			/* Challenge Text */
