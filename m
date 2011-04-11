From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-04-11
Date: Mon, 11 Apr 2011 15:34:43 -0400
Message-ID: <20110411193443.GD2511@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another batch intended for 2.6.39.  Included is an mwl8k fix
to avoid freeing an irq that we never requested, an ath common code
fix to add a regulatory domain mapping code, an ath9k fix to avoid some
crashes on MIPS boards and fix some radio stability issues on AR9285, a
p54 fix to avoid a device lock-up caused by an uninitialized variable,
an iwlagn fix to correct for an incorrect antenna configuration value
in EEPROM on iwl5300 hardware, and an Kconfig fix for iwlegacy to
keep old kernel build configurations still building iwl3945 and/or
iwl4965 after the iwlagn/iwlegacy split.

Please let me know if there are problems!

John

---

The following changes since commit 88edaa415966af965bb7eb7056d8b58145462c8e:

  net: Add support for SMSC LAN9530, LAN9730 and LAN89530 (2011-04-10 18:59:27 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Brian Cavagnolo (1):
      mwl8k: do not free unrequested irq

Christian Lamparter (1):
      ath: add missing regdomain pair 0x5c mapping

Felix Fietkau (1):
      ath9k: fix missing ath9k_ps_wakeup/ath9k_ps_restore calls

Jason Conti (1):
      p54: Initialize extra_len in p54_tx_80211

Johannes Berg (1):
      iwlagn: override 5300 EEPROM # of chains

John W. Linville (1):
      iwlegacy: make iwl3945 and iwl4965 select IWLWIFI_LEGACY

 drivers/net/wireless/ath/ath9k/main.c   |   12 ++++++++++--
 drivers/net/wireless/ath/regd_common.h  |    1 +
 drivers/net/wireless/iwlegacy/Kconfig   |    9 +++++----
 drivers/net/wireless/iwlwifi/iwl-5000.c |    3 +++
 drivers/net/wireless/mwl8k.c            |    9 ++++++++-
 drivers/net/wireless/p54/txrx.c         |    2 +-
 6 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index dddb85d..17d04ff 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1376,7 +1376,6 @@ static void ath9k_calculate_summary_state(struct ieee80211_hw *hw,
 
 	ath9k_calculate_iter_data(hw, vif, &iter_data);
 
-	ath9k_ps_wakeup(sc);
 	/* Set BSSID mask. */
 	memcpy(common->bssidmask, iter_data.mask, ETH_ALEN);
 	ath_hw_setbssidmask(common);
@@ -1411,7 +1410,6 @@ static void ath9k_calculate_summary_state(struct ieee80211_hw *hw,
 	}
 
 	ath9k_hw_set_interrupts(ah, ah->imask);
-	ath9k_ps_restore(sc);
 
 	/* Set up ANI */
 	if ((iter_data.naps + iter_data.nadhocs) > 0) {
@@ -1457,6 +1455,7 @@ static int ath9k_add_interface(struct ieee80211_hw *hw,
 	struct ath_vif *avp = (void *)vif->drv_priv;
 	int ret = 0;
 
+	ath9k_ps_wakeup(sc);
 	mutex_lock(&sc->mutex);
 
 	switch (vif->type) {
@@ -1503,6 +1502,7 @@ static int ath9k_add_interface(struct ieee80211_hw *hw,
 	ath9k_do_vif_add_setup(hw, vif);
 out:
 	mutex_unlock(&sc->mutex);
+	ath9k_ps_restore(sc);
 	return ret;
 }
 
@@ -1517,6 +1517,7 @@ static int ath9k_change_interface(struct ieee80211_hw *hw,
 
 	ath_dbg(common, ATH_DBG_CONFIG, "Change Interface\n");
 	mutex_lock(&sc->mutex);
+	ath9k_ps_wakeup(sc);
 
 	/* See if new interface type is valid. */
 	if ((new_type == NL80211_IFTYPE_ADHOC) &&
@@ -1546,6 +1547,7 @@ static int ath9k_change_interface(struct ieee80211_hw *hw,
 
 	ath9k_do_vif_add_setup(hw, vif);
 out:
+	ath9k_ps_restore(sc);
 	mutex_unlock(&sc->mutex);
 	return ret;
 }
@@ -1558,6 +1560,7 @@ static void ath9k_remove_interface(struct ieee80211_hw *hw,
 
 	ath_dbg(common, ATH_DBG_CONFIG, "Detach Interface\n");
 
+	ath9k_ps_wakeup(sc);
 	mutex_lock(&sc->mutex);
 
 	sc->nvifs--;
@@ -1569,6 +1572,7 @@ static void ath9k_remove_interface(struct ieee80211_hw *hw,
 	ath9k_calculate_summary_state(hw, NULL);
 
 	mutex_unlock(&sc->mutex);
+	ath9k_ps_restore(sc);
 }
 
 static void ath9k_enable_ps(struct ath_softc *sc)
@@ -1809,6 +1813,7 @@ static int ath9k_conf_tx(struct ieee80211_hw *hw, u16 queue,
 
 	txq = sc->tx.txq_map[queue];
 
+	ath9k_ps_wakeup(sc);
 	mutex_lock(&sc->mutex);
 
 	memset(&qi, 0, sizeof(struct ath9k_tx_queue_info));
@@ -1832,6 +1837,7 @@ static int ath9k_conf_tx(struct ieee80211_hw *hw, u16 queue,
 			ath_beaconq_config(sc);
 
 	mutex_unlock(&sc->mutex);
+	ath9k_ps_restore(sc);
 
 	return ret;
 }
@@ -1894,6 +1900,7 @@ static void ath9k_bss_info_changed(struct ieee80211_hw *hw,
 	int slottime;
 	int error;
 
+	ath9k_ps_wakeup(sc);
 	mutex_lock(&sc->mutex);
 
 	if (changed & BSS_CHANGED_BSSID) {
@@ -1994,6 +2001,7 @@ static void ath9k_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	mutex_unlock(&sc->mutex);
+	ath9k_ps_restore(sc);
 }
 
 static u64 ath9k_get_tsf(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/ath/regd_common.h b/drivers/net/wireless/ath/regd_common.h
index 248c670..5c2cfe6 100644
--- a/drivers/net/wireless/ath/regd_common.h
+++ b/drivers/net/wireless/ath/regd_common.h
@@ -195,6 +195,7 @@ static struct reg_dmn_pair_mapping regDomainPairs[] = {
 	{APL9_WORLD, CTL_ETSI, CTL_ETSI},
 
 	{APL3_FCCA, CTL_FCC, CTL_FCC},
+	{APL7_FCCA, CTL_FCC, CTL_FCC},
 	{APL1_ETSIC, CTL_FCC, CTL_ETSI},
 	{APL2_ETSIC, CTL_FCC, CTL_ETSI},
 	{APL2_APLD, CTL_FCC, NO_CTL},
diff --git a/drivers/net/wireless/iwlegacy/Kconfig b/drivers/net/wireless/iwlegacy/Kconfig
index 2a45dd4..aef65cd 100644
--- a/drivers/net/wireless/iwlegacy/Kconfig
+++ b/drivers/net/wireless/iwlegacy/Kconfig
@@ -1,6 +1,5 @@
 config IWLWIFI_LEGACY
-	tristate "Intel Wireless Wifi legacy devices"
-	depends on PCI && MAC80211
+	tristate
 	select FW_LOADER
 	select NEW_LEDS
 	select LEDS_CLASS
@@ -65,7 +64,8 @@ endmenu
 
 config IWL4965
 	tristate "Intel Wireless WiFi 4965AGN (iwl4965)"
-	depends on IWLWIFI_LEGACY
+	depends on PCI && MAC80211
+	select IWLWIFI_LEGACY
 	---help---
 	  This option enables support for
 
@@ -92,7 +92,8 @@ config IWL4965
 
 config IWL3945
 	tristate "Intel PRO/Wireless 3945ABG/BG Network Connection (iwl3945)"
-	depends on IWLWIFI_LEGACY
+	depends on PCI && MAC80211
+	select IWLWIFI_LEGACY
 	---help---
 	  Select to build the driver supporting the:
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index 3ea31b6..22e045b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -530,6 +530,9 @@ static struct iwl_ht_params iwl5000_ht_params = {
 struct iwl_cfg iwl5300_agn_cfg = {
 	.name = "Intel(R) Ultimate N WiFi Link 5300 AGN",
 	IWL_DEVICE_5000,
+	/* at least EEPROM 0x11A has wrong info */
+	.valid_tx_ant = ANT_ABC,	/* .cfg overwrite */
+	.valid_rx_ant = ANT_ABC,	/* .cfg overwrite */
 	.ht_params = &iwl5000_ht_params,
 };
 
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 3695227..c1ceb4b 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -137,6 +137,7 @@ struct mwl8k_tx_queue {
 struct mwl8k_priv {
 	struct ieee80211_hw *hw;
 	struct pci_dev *pdev;
+	int irq;
 
 	struct mwl8k_device_info *device_info;
 
@@ -3761,9 +3762,11 @@ static int mwl8k_start(struct ieee80211_hw *hw)
 	rc = request_irq(priv->pdev->irq, mwl8k_interrupt,
 			 IRQF_SHARED, MWL8K_NAME, hw);
 	if (rc) {
+		priv->irq = -1;
 		wiphy_err(hw->wiphy, "failed to register IRQ handler\n");
 		return -EIO;
 	}
+	priv->irq = priv->pdev->irq;
 
 	/* Enable TX reclaim and RX tasklets.  */
 	tasklet_enable(&priv->poll_tx_task);
@@ -3800,6 +3803,7 @@ static int mwl8k_start(struct ieee80211_hw *hw)
 	if (rc) {
 		iowrite32(0, priv->regs + MWL8K_HIU_A2H_INTERRUPT_MASK);
 		free_irq(priv->pdev->irq, hw);
+		priv->irq = -1;
 		tasklet_disable(&priv->poll_tx_task);
 		tasklet_disable(&priv->poll_rx_task);
 	}
@@ -3818,7 +3822,10 @@ static void mwl8k_stop(struct ieee80211_hw *hw)
 
 	/* Disable interrupts */
 	iowrite32(0, priv->regs + MWL8K_HIU_A2H_INTERRUPT_MASK);
-	free_irq(priv->pdev->irq, hw);
+	if (priv->irq != -1) {
+		free_irq(priv->pdev->irq, hw);
+		priv->irq = -1;
+	}
 
 	/* Stop finalize join worker */
 	cancel_work_sync(&priv->finalize_join_worker);
diff --git a/drivers/net/wireless/p54/txrx.c b/drivers/net/wireless/p54/txrx.c
index 7834c26..042842e 100644
--- a/drivers/net/wireless/p54/txrx.c
+++ b/drivers/net/wireless/p54/txrx.c
@@ -703,7 +703,7 @@ void p54_tx_80211(struct ieee80211_hw *dev, struct sk_buff *skb)
 	struct p54_tx_info *p54info;
 	struct p54_hdr *hdr;
 	struct p54_tx_data *txhdr;
-	unsigned int padding, len, extra_len;
+	unsigned int padding, len, extra_len = 0;
 	int i, j, ridx;
 	u16 hdr_flags = 0, aid = 0;
 	u8 rate, queue = 0, crypt_offset = 0;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
