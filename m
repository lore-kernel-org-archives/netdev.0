From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/2] d80211: Turn PHYmode list from an array into a linked list
Date: Fri, 15 Dec 2006 16:37:06 +0100
Message-ID: <200612151637.06319.mb@bu3sch.de>
References: <200612141920.11439.mb@bu3sch.de> <200612151454.55508.mb@bu3sch.de> <20061215150655.50a728c4@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:42398
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752746AbWLOPhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 10:37:31 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061215150655.50a728c4@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 15 December 2006 15:06, Jiri Benc wrote:
> On Fri, 15 Dec 2006 14:54:55 +0100, Michael Buesch wrote:
> > Can you also apply the bcm43xx fix for this to your tree?
> > I think that should be easiest and prevent long-living breakage.
> 
> It doesn't apply :-( It's probably easy to fix but I'd rather leave it
> to you to not make any damage.

Here's the fixed patch diffed against your tree.

Still Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: jbenc-dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-12-15 16:17:30.000000000 +0100
@@ -503,6 +503,8 @@ struct bcm43xx_phyinfo {
 	enum bcm43xx_firmware_compat fw;
 	/* The TX header length. This depends on the firmware. */
 	size_t txhdr_size;
+
+	struct ieee80211_hw_mode hwmode;
 };
 
 
Index: jbenc-dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-12-15 16:30:55.000000000 +0100
@@ -2845,19 +2845,25 @@ static void bcm43xx_chipset_detach(struc
 
 static void bcm43xx_free_modes(struct bcm43xx_private *bcm)
 {
-	struct ieee80211_hw *hw = bcm->ieee;
+	struct ssb_core *core;
+	struct bcm43xx_corepriv_80211 *wlpriv;
+	struct bcm43xx_phyinfo *phy;
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
+			       struct bcm43xx_phyinfo *phy,
 			       int mode_id,
 			       int nr_channels,
 			       const struct ieee80211_channel *channels,
@@ -2866,10 +2872,10 @@ static int bcm43xx_append_mode(struct ie
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
@@ -2890,11 +2896,14 @@ static int bcm43xx_append_mode(struct ie
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
@@ -2903,17 +2912,9 @@ err_free_channels:
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
@@ -2921,7 +2922,7 @@ static int bcm43xx_setup_modes(struct bc
 
 		switch (wlpriv->phy.type) {
 		case BCM43xx_PHYTYPE_A:
-			err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211A,
+			err = bcm43xx_append_mode(bcm, &wlpriv->phy, MODE_IEEE80211A,
 						  ARRAY_SIZE(bcm43xx_a_chantable),
 						  bcm43xx_a_chantable,
 						  ARRAY_SIZE(bcm43xx_ofdm_ratetable),
@@ -2929,7 +2930,7 @@ static int bcm43xx_setup_modes(struct bc
 						  0, NULL);
 			break;
 		case BCM43xx_PHYTYPE_B:
-			err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211B,
+			err = bcm43xx_append_mode(bcm, &wlpriv->phy, MODE_IEEE80211B,
 						  ARRAY_SIZE(bcm43xx_bg_chantable),
 						  bcm43xx_bg_chantable,
 						  ARRAY_SIZE(bcm43xx_cck_ratetable),
@@ -2937,7 +2938,7 @@ static int bcm43xx_setup_modes(struct bc
 						  0, NULL);
 			break;
 		case BCM43xx_PHYTYPE_G:
-			err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211G,
+			err = bcm43xx_append_mode(bcm, &wlpriv->phy, MODE_IEEE80211G,
 						  ARRAY_SIZE(bcm43xx_bg_chantable),
 						  bcm43xx_bg_chantable,
 						  ARRAY_SIZE(bcm43xx_ofdm_ratetable),
@@ -3180,7 +3181,6 @@ bcm->wlcore = active_core;
 	bcm43xx_macfilter_set(bcm, BCM43xx_MACFILTER_SELF, (u8 *)(bcm->ieee->perm_addr));
 	bcm43xx_security_init(bcm);
 	bcm43xx_measure_channel_change_time(bcm);
-	ieee80211_update_hw(bcm->ieee);
 	ieee80211_start_queues(bcm->ieee);
 
 	/* Let's go! Be careful after enabling the IRQs.


-- 
Greetings Michael.
