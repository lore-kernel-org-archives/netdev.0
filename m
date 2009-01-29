From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-01-29
Date: Thu, 29 Jan 2009 16:27:25 -0500
Message-ID: <20090129212725.GB6085@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52529 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbZA2Vat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 16:30:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

I present to you another round of patches intended for 2.6.29.  There is
a MAINTAINERS patch that recognizes the reality that Michael Wu is no
longer touching mac80211.  There is a power setting patch for rtl8187
that corrects a functional regression, and a NULL pointer fix for
iwlagn.  There are a couple of regulatory-related patches that are
isolated and I think merit inclusion based on their nature.  Finally,
there is an ath5k fix for an older problem that is more prevalent since
the merge of "ath5k: ignore the return value of
ath5k_hw_noise_floor_calibration" and which addresses kernel.org bugs
12068 and 12080.

Please let me know if there are problems!

Thanks,

John
---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 5376071069ec8a7e6a8112beab16fc24f5139475:
  Linus Torvalds (1):
        Merge master.kernel.org:/home/rmk/linux-2.6-arm

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bob Copeland (1):
      ath5k: fix locking in ath5k_config

Johannes Berg (1):
      mac80211: remove Michael Wu as maintainer

Larry Finger (1):
      rtl8187: Fix error in setting OFDM power settings for RTL8187L

Luis R. Rodriguez (2):
      cfg80211: Fix sanity check on 5 GHz when processing country IE
      cfg80211: print correct intersected regulatory domain

Zhu, Yi (1):
      iwlwifi: fix kernel oops when ucode DMA memory allocation failure

 MAINTAINERS                                    |    2 -
 drivers/net/wireless/ath5k/base.c              |   10 ++++++-
 drivers/net/wireless/iwlwifi/iwl-agn.c         |    4 +++
 drivers/net/wireless/rtl818x/rtl8187_rtl8225.c |   10 ++++++-
 net/wireless/reg.c                             |   32 +++++++++++++++---------
 5 files changed, 41 insertions(+), 17 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index d992d40..474ec0c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2836,8 +2836,6 @@ S:	Maintained
 MAC80211
 P:	Johannes Berg
 M:	johannes@sipsolutions.net
-P:	Michael Wu
-M:	flamingice@sourmilk.net
 L:	linux-wireless@vger.kernel.org
 W:	http://linuxwireless.org/
 T:	git kernel.org:/pub/scm/linux/kernel/git/linville/wireless-2.6.git
diff --git a/arch/arm/mach-integrator/clock.h b/arch/arm/mach-integrator/clock.h
deleted file mode 100644
index e69de29..0000000
diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index 8ef8735..a533ed6 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -1028,6 +1028,8 @@ ath5k_setup_bands(struct ieee80211_hw *hw)
  * it's done by reseting the chip.  To accomplish this we must
  * first cleanup any pending DMA, then restart stuff after a la
  * ath5k_init.
+ *
+ * Called with sc->lock.
  */
 static int
 ath5k_chan_set(struct ath5k_softc *sc, struct ieee80211_channel *chan)
@@ -2814,11 +2816,17 @@ ath5k_config(struct ieee80211_hw *hw, u32 changed)
 {
 	struct ath5k_softc *sc = hw->priv;
 	struct ieee80211_conf *conf = &hw->conf;
+	int ret;
+
+	mutex_lock(&sc->lock);
 
 	sc->bintval = conf->beacon_int;
 	sc->power_level = conf->power_level;
 
-	return ath5k_chan_set(sc, conf->channel);
+	ret = ath5k_chan_set(sc, conf->channel);
+
+	mutex_unlock(&sc->lock);
+	return ret;
 }
 
 static int
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 0dc8eed..b35c881 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -1719,6 +1719,10 @@ static int iwl_read_ucode(struct iwl_priv *priv)
 	priv->ucode_data_backup.len = data_size;
 	iwl_alloc_fw_desc(priv->pci_dev, &priv->ucode_data_backup);
 
+	if (!priv->ucode_code.v_addr || !priv->ucode_data.v_addr ||
+	    !priv->ucode_data_backup.v_addr)
+		goto err_pci_alloc;
+
 	/* Initialization instructions and data */
 	if (init_size && init_data_size) {
 		priv->ucode_init.len = init_size;
diff --git a/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c b/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c
index 4e75e8e..78df281 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c
@@ -285,7 +285,10 @@ static void rtl8225_rf_set_tx_power(struct ieee80211_hw *dev, int channel)
 	ofdm_power = priv->channels[channel - 1].hw_value >> 4;
 
 	cck_power = min(cck_power, (u8)11);
-	ofdm_power = min(ofdm_power, (u8)35);
+	if (ofdm_power > (u8)15)
+		ofdm_power = 25;
+	else
+		ofdm_power += 10;
 
 	rtl818x_iowrite8(priv, &priv->map->TX_GAIN_CCK,
 			 rtl8225_tx_gain_cck_ofdm[cck_power / 6] >> 1);
@@ -536,7 +539,10 @@ static void rtl8225z2_rf_set_tx_power(struct ieee80211_hw *dev, int channel)
 	cck_power += priv->txpwr_base & 0xF;
 	cck_power = min(cck_power, (u8)35);
 
-	ofdm_power = min(ofdm_power, (u8)15);
+	if (ofdm_power > (u8)15)
+		ofdm_power = 25;
+	else
+		ofdm_power += 10;
 	ofdm_power += priv->txpwr_base >> 4;
 	ofdm_power = min(ofdm_power, (u8)35);
 
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index bc494ce..85c9034 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -498,6 +498,7 @@ static struct ieee80211_regdomain *country_ie_2_rd(
 	 * calculate the number of reg rules we will need. We will need one
 	 * for each channel subband */
 	while (country_ie_len >= 3) {
+		int end_channel = 0;
 		struct ieee80211_country_ie_triplet *triplet =
 			(struct ieee80211_country_ie_triplet *) country_ie;
 		int cur_sub_max_channel = 0, cur_channel = 0;
@@ -509,9 +510,25 @@ static struct ieee80211_regdomain *country_ie_2_rd(
 			continue;
 		}
 
+		/* 2 GHz */
+		if (triplet->chans.first_channel <= 14)
+			end_channel = triplet->chans.first_channel +
+				triplet->chans.num_channels;
+		else
+			/*
+			 * 5 GHz -- For example in country IEs if the first
+			 * channel given is 36 and the number of channels is 4
+			 * then the individual channel numbers defined for the
+			 * 5 GHz PHY by these parameters are: 36, 40, 44, and 48
+			 * and not 36, 37, 38, 39.
+			 *
+			 * See: http://tinyurl.com/11d-clarification
+			 */
+			end_channel =  triplet->chans.first_channel +
+				(4 * (triplet->chans.num_channels - 1));
+
 		cur_channel = triplet->chans.first_channel;
-		cur_sub_max_channel = ieee80211_channel_to_frequency(
-			cur_channel + triplet->chans.num_channels);
+		cur_sub_max_channel = end_channel;
 
 		/* Basic sanity check */
 		if (cur_sub_max_channel < cur_channel)
@@ -590,15 +607,6 @@ static struct ieee80211_regdomain *country_ie_2_rd(
 			end_channel = triplet->chans.first_channel +
 				triplet->chans.num_channels;
 		else
-			/*
-			 * 5 GHz -- For example in country IEs if the first
-			 * channel given is 36 and the number of channels is 4
-			 * then the individual channel numbers defined for the
-			 * 5 GHz PHY by these parameters are: 36, 40, 44, and 48
-			 * and not 36, 37, 38, 39.
-			 *
-			 * See: http://tinyurl.com/11d-clarification
-			 */
 			end_channel =  triplet->chans.first_channel +
 				(4 * (triplet->chans.num_channels - 1));
 
@@ -1276,7 +1284,7 @@ static void reg_country_ie_process_debug(
 	if (intersected_rd) {
 		printk(KERN_DEBUG "cfg80211: We intersect both of these "
 			"and get:\n");
-		print_regdomain_info(rd);
+		print_regdomain_info(intersected_rd);
 		return;
 	}
 	printk(KERN_DEBUG "cfg80211: Intersection between both failed\n");
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
