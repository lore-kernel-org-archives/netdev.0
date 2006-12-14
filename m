From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 2/2] bcm43xx-d80211: Fix for PHYmode API change.
Date: Thu, 14 Dec 2006 19:20:25 +0100
Message-ID: <200612141920.26107.mb@bu3sch.de>
References: <200612141917.20816.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: jbenc-AlSwsSmVLrQ@public.gmane.org
In-Reply-To: <200612141917.20816.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This fixes the PHYmode list API breakage for the bcm43xx-d80211 driver.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: bu3sch-wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
===================================================================
--- bu3sch-wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	
2006-12-13 19:24:25.000000000 +0100
+++ bu3sch-wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	
2006-12-14 17:42:42.000000000 +0100
@@ -561,6 +561,8 @@ struct bcm43xx_phy {
 	enum bcm43xx_firmware_compat fw;
 	/* The TX header length. This depends on the firmware. */
 	size_t txhdr_size;
+
+	struct ieee80211_hw_mode hwmode;
 };
 
 /* Data structures for DMA transmission, per 80211 core. */
Index: bu3sch-wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- 
bu3sch-wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	
2006-12-13 19:24:25.000000000 +0100
+++ bu3sch-wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	
2006-12-14 17:57:46.000000000 +0100
@@ -2892,19 +2892,25 @@ static void bcm43xx_chipset_detach(struc
 
 static void bcm43xx_free_modes(struct bcm43xx_private *bcm)
 {
-	struct ieee80211_hw *hw = bcm->ieee;
+	struct ssb_core *core;
+	struct bcm43xx_corepriv_80211 *wlpriv;
+	struct bcm43xx_phy *phy;
 	int i;
 
-	for (i = 0; i < hw->num_modes; i++) {
-		kfree(hw->modes[i].channels);
-		kfree(hw->modes[i].rates);
+	for (i = 0; i < bcm->nr_80211_available; i++) {
+		core = bcm->wlcores[i];
+		wlpriv = core->priv;
+		phy = &wlpriv->phy;
+
+		kfree(phy->hwmode.channels);
+		phy->hwmode.channels = NULL;
+		kfree(phy->hwmode.rates);
+		phy->hwmode.rates = NULL;
 	}
-	kfree(hw->modes);
-	hw->modes = NULL;
-	hw->num_modes = 0;
 }
 
-static int bcm43xx_append_mode(struct ieee80211_hw *hw,
+static int bcm43xx_append_mode(struct bcm43xx_private *bcm,
+			       struct bcm43xx_phy *phy,
 			       int mode_id,
 			       int nr_channels,
 			       const struct ieee80211_channel *channels,
@@ -2913,10 +2919,10 @@ static int bcm43xx_append_mode(struct ie
 			       int nr_rates2,
 			       const struct ieee80211_rate *rates2)
 {
-	struct ieee80211_hw_modes *mode;
+	struct ieee80211_hw_mode *mode;
 	int err = -ENOMEM;
 
-	mode = &(hw->modes[hw->num_modes]);
+	mode = &phy->hwmode;
 
 	mode->mode = mode_id;
 	mode->num_channels = nr_channels;
@@ -2937,11 +2943,14 @@ static int bcm43xx_append_mode(struct ie
 		       sizeof(*rates2) * nr_rates2);
 	}
 
-	hw->num_modes++;
-	err = 0;
+	err = ieee80211_register_hwmode(bcm->ieee, mode);
+	if (err)
+		goto err_free_rates;
 out:
 	return err;
 
+err_free_rates:
+	kfree(mode->rates);
 err_free_channels:
 	kfree(mode->channels);
 	goto out;
@@ -2950,17 +2959,9 @@ err_free_channels:
 static int bcm43xx_setup_modes(struct bcm43xx_private *bcm)
 {
 	int err = -ENOMEM;
-	struct ieee80211_hw *hw = bcm->ieee;
 	struct ssb_core *core;
 	struct bcm43xx_corepriv_80211 *wlpriv;
-	int i, nr_modes;
-
-	nr_modes = bcm->nr_80211_available;
-	hw->modes = kzalloc(sizeof(*(hw->modes)) * nr_modes,
-			      GFP_KERNEL);
-	if (!hw->modes)
-		goto out;
-	hw->num_modes = 0;
+	int i;
 
 	for (i = 0; i < bcm->nr_80211_available; i++) {
 		core = bcm->wlcores[i];
@@ -2968,7 +2969,7 @@ static int bcm43xx_setup_modes(struct bc
 
 		switch (wlpriv->phy.type) {
 		case BCM43xx_PHYTYPE_A:
-			err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211A,
+			err = bcm43xx_append_mode(bcm, &wlpriv->phy, MODE_IEEE80211A,
 						  ARRAY_SIZE(bcm43xx_a_chantable),
 						  bcm43xx_a_chantable,
 						  ARRAY_SIZE(bcm43xx_ofdm_ratetable),
@@ -2976,7 +2977,7 @@ static int bcm43xx_setup_modes(struct bc
 						  0, NULL);
 			break;
 		case BCM43xx_PHYTYPE_B:
-			err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211B,
+			err = bcm43xx_append_mode(bcm, &wlpriv->phy, MODE_IEEE80211B,
 						  ARRAY_SIZE(bcm43xx_bg_chantable),
 						  bcm43xx_bg_chantable,
 						  ARRAY_SIZE(bcm43xx_cck_ratetable),
@@ -2984,7 +2985,7 @@ static int bcm43xx_setup_modes(struct bc
 						  0, NULL);
 			break;
 		case BCM43xx_PHYTYPE_G:
-			err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211G,
+			err = bcm43xx_append_mode(bcm, &wlpriv->phy, MODE_IEEE80211G,
 						  ARRAY_SIZE(bcm43xx_bg_chantable),
 						  bcm43xx_bg_chantable,
 						  ARRAY_SIZE(bcm43xx_ofdm_ratetable),
@@ -3222,7 +3223,6 @@ bcm->wlcore = active_core;
 	bcm43xx_security_init(bcm);
 	bcm43xx_measure_channel_change_time(bcm);
 	drain_txstatus_queue(bcm);
-	ieee80211_update_hw(bcm->ieee);
 	ieee80211_start_queues(bcm->ieee);
 
 	/* Let's go! Be careful after enabling the IRQs.
