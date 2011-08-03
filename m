From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-08-03
Date: Wed, 3 Aug 2011 10:47:55 -0400
Message-ID: <20110803144754.GB30439@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38061 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579Ab1HCPC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 11:02:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This is mostly a replay of the mangled pull request I sent yesterday.
The body of that request message is here:

	Here are a few more fixes intended for 3.1.  Dan Carpenter
	gives us an off-by-one fix in the scan trigger code for
	nl80211.  Felix gives us a fix for tx power initialization
	for ath9k.  Larry fixes an oops on ARM by rewriting some init
	code to avoid checking something that doesn't get initialized
	on ARM.  This round's big hero is Stanislaw, who gives us a
	brown paper bag fix for some skb handling in rt2x00, an ath9k
	fix to avoid hangs on systems w/ ASPM disabled, and an iwlegacy
	fix to ensure that tx power settings are applied properly.

In addition to that, I have a few more fixes to squeeze in here!  A fix
from Emmanuel Grumbach for iwlagn reverts a buggy portion of an
earlier patch.  A fix from Helmut Schaa corrects a build problem w/
rt2x00 discovered by Randy Dunlap.  Stanislaw brings us yet another fix,
this one for a NULL pointer access in rt2x00.  Finally, Wey-Yi gives us
a fix to turn-off idel support for iwl5000 devices since using it makes
them unstable.

As usual, please let me know if there are problems!

John

P.S.  I apologize for the confusion I've created lately, with the previous
pull request and others.  The summer heat (and the screaming kids) must
be getting to me!  I'll work harder on tightening things up...

---

The following changes since commit 28f4881cbf9ce285edfc245a8990af36d21c062f:

  bnx2x: Clear MDIO access warning during first driver load (2011-08-03 03:22:18 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

Dan Carpenter (1):
      cfg80211: off by one in nl80211_trigger_scan()

Emmanuel Grumbach (1):
      iwlagn: sysfs couldn't find the priv pointer

Felix Fietkau (1):
      ath9k: initialize tx chainmask before testing channel tx power values

Helmut Schaa (1):
      rt2x00: Fix compilation without CONFIG_RT2X00_LIB_CRYPTO

John W. Linville (1):
      Merge git://git.kernel.org/.../linville/wireless-next into for-davem

Larry Finger (1):
      rtlwifi: Fix kernel oops on ARM SOC

Stanislaw Gruszka (4):
      iwlegacy: set tx power after rxon_assoc
      ath9k: skip ->config_pci_powersave() if PCIe port has ASPM disabled
      rt2x00: rt2800: fix zeroing skb structure
      rt2x00: fix usage of NULL queue

Wey-Yi Guy (1):
      iwlagn: 5000 do not support idle mode

 drivers/net/wireless/ath/ath9k/ar9002_hw.c |    6 +-----
 drivers/net/wireless/ath/ath9k/ar9003_hw.c |    6 +-----
 drivers/net/wireless/ath/ath9k/hw.c        |   11 +++++++++--
 drivers/net/wireless/ath/ath9k/hw.h        |    3 ++-
 drivers/net/wireless/ath/ath9k/init.c      |    2 ++
 drivers/net/wireless/ath/ath9k/pci.c       |   27 +++++++++++++++++++++++++++
 drivers/net/wireless/iwlegacy/iwl-3945.c   |    6 +++++-
 drivers/net/wireless/iwlegacy/iwl-4965.c   |    8 ++++++--
 drivers/net/wireless/iwlwifi/iwl-5000.c    |    1 +
 drivers/net/wireless/iwlwifi/iwl-core.h    |    2 ++
 drivers/net/wireless/iwlwifi/iwl-pci.c     |   18 +++++++++---------
 drivers/net/wireless/iwlwifi/iwl-power.c   |    3 ++-
 drivers/net/wireless/rt2x00/rt2800lib.c    |    3 +--
 drivers/net/wireless/rt2x00/rt2x00lib.h    |    3 ++-
 drivers/net/wireless/rt2x00/rt2x00mac.c    |    5 +++--
 drivers/net/wireless/rtlwifi/pci.c         |   20 +++++++++++---------
 net/wireless/nl80211.c                     |    2 +-
 17 files changed, 85 insertions(+), 41 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9002_hw.c b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
index 9ff7c30..44d9d8d 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_hw.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
@@ -309,11 +309,7 @@ static void ar9002_hw_configpcipowersave(struct ath_hw *ah,
 	u8 i;
 	u32 val;
 
-	if (ah->is_pciexpress != true)
-		return;
-
-	/* Do not touch SerDes registers */
-	if (ah->config.pcie_powersave_enable == 2)
+	if (ah->is_pciexpress != true || ah->aspm_enabled != true)
 		return;
 
 	/* Nothing to do on restore for 11N */
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_hw.c b/drivers/net/wireless/ath/ath9k/ar9003_hw.c
index 8efdec2..ad2bb2b 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_hw.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_hw.c
@@ -519,11 +519,7 @@ static void ar9003_hw_configpcipowersave(struct ath_hw *ah,
 					 int restore,
 					 int power_off)
 {
-	if (ah->is_pciexpress != true)
-		return;
-
-	/* Do not touch SerDes registers */
-	if (ah->config.pcie_powersave_enable == 2)
+	if (ah->is_pciexpress != true || ah->aspm_enabled != true)
 		return;
 
 	/* Nothing to do on restore for 11N */
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 8006ce0..8dcefe7 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -318,6 +318,14 @@ static void ath9k_hw_disablepcie(struct ath_hw *ah)
 	REG_WRITE(ah, AR_PCIE_SERDES2, 0x00000000);
 }
 
+static void ath9k_hw_aspm_init(struct ath_hw *ah)
+{
+	struct ath_common *common = ath9k_hw_common(ah);
+
+	if (common->bus_ops->aspm_init)
+		common->bus_ops->aspm_init(common);
+}
+
 /* This should work for all families including legacy */
 static bool ath9k_hw_chip_test(struct ath_hw *ah)
 {
@@ -378,7 +386,6 @@ static void ath9k_hw_init_config(struct ath_hw *ah)
 	ah->config.additional_swba_backoff = 0;
 	ah->config.ack_6mb = 0x0;
 	ah->config.cwm_ignore_extcca = 0;
-	ah->config.pcie_powersave_enable = 0;
 	ah->config.pcie_clock_req = 0;
 	ah->config.pcie_waen = 0;
 	ah->config.analog_shiftreg = 1;
@@ -598,7 +605,7 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 
 
 	if (ah->is_pciexpress)
-		ath9k_hw_configpcipowersave(ah, 0, 0);
+		ath9k_hw_aspm_init(ah);
 	else
 		ath9k_hw_disablepcie(ah);
 
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index 6acd0f9..c798890 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -219,7 +219,6 @@ struct ath9k_ops_config {
 	int additional_swba_backoff;
 	int ack_6mb;
 	u32 cwm_ignore_extcca;
-	u8 pcie_powersave_enable;
 	bool pcieSerDesWrite;
 	u8 pcie_clock_req;
 	u32 pcie_waen;
@@ -673,6 +672,7 @@ struct ath_hw {
 
 	bool sw_mgmt_crypto;
 	bool is_pciexpress;
+	bool aspm_enabled;
 	bool is_monitoring;
 	bool need_an_top2_fixup;
 	u16 tx_trig_level;
@@ -874,6 +874,7 @@ struct ath_bus_ops {
 	bool (*eeprom_read)(struct ath_common *common, u32 off, u16 *data);
 	void (*bt_coex_prep)(struct ath_common *common);
 	void (*extn_synch_en)(struct ath_common *common);
+	void (*aspm_init)(struct ath_common *common);
 };
 
 static inline struct ath_common *ath9k_hw_common(struct ath_hw *ah)
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index ac51071..aa0ff7e 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -670,8 +670,10 @@ static void ath9k_init_band_txpower(struct ath_softc *sc, int band)
 static void ath9k_init_txpower_limits(struct ath_softc *sc)
 {
 	struct ath_hw *ah = sc->sc_ah;
+	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	struct ath9k_channel *curchan = ah->curchan;
 
+	ah->txchainmask = common->tx_chainmask;
 	if (ah->caps.hw_caps & ATH9K_HW_CAP_2GHZ)
 		ath9k_init_band_txpower(sc, IEEE80211_BAND_2GHZ);
 	if (ah->caps.hw_caps & ATH9K_HW_CAP_5GHZ)
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index 3bad0b2..be4ea13 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -16,6 +16,7 @@
 
 #include <linux/nl80211.h>
 #include <linux/pci.h>
+#include <linux/pci-aspm.h>
 #include <linux/ath9k_platform.h>
 #include "ath9k.h"
 
@@ -115,12 +116,38 @@ static void ath_pci_extn_synch_enable(struct ath_common *common)
 	pci_write_config_byte(pdev, sc->sc_ah->caps.pcie_lcr_offset, lnkctl);
 }
 
+static void ath_pci_aspm_init(struct ath_common *common)
+{
+	struct ath_softc *sc = (struct ath_softc *) common->priv;
+	struct ath_hw *ah = sc->sc_ah;
+	struct pci_dev *pdev = to_pci_dev(sc->dev);
+	struct pci_dev *parent;
+	int pos;
+	u8 aspm;
+
+	if (!pci_is_pcie(pdev))
+		return;
+
+	parent = pdev->bus->self;
+	if (WARN_ON(!parent))
+		return;
+
+	pos = pci_pcie_cap(parent);
+	pci_read_config_byte(parent, pos +  PCI_EXP_LNKCTL, &aspm);
+	if (aspm & (PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1)) {
+		ah->aspm_enabled = true;
+		/* Initialize PCIe PM and SERDES registers. */
+		ath9k_hw_configpcipowersave(ah, 0, 0);
+	}
+}
+
 static const struct ath_bus_ops ath_pci_bus_ops = {
 	.ath_bus_type = ATH_PCI,
 	.read_cachesize = ath_pci_read_cachesize,
 	.eeprom_read = ath_pci_eeprom_read,
 	.bt_coex_prep = ath_pci_bt_coex_prep,
 	.extn_synch_en = ath_pci_extn_synch_enable,
+	.aspm_init = ath_pci_aspm_init,
 };
 
 static int ath_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
diff --git a/drivers/net/wireless/iwlegacy/iwl-3945.c b/drivers/net/wireless/iwlegacy/iwl-3945.c
index dab67a1..73fe3cd 100644
--- a/drivers/net/wireless/iwlegacy/iwl-3945.c
+++ b/drivers/net/wireless/iwlegacy/iwl-3945.c
@@ -1746,7 +1746,11 @@ int iwl3945_commit_rxon(struct iwl_priv *priv, struct iwl_rxon_context *ctx)
 		}
 
 		memcpy(active_rxon, staging_rxon, sizeof(*active_rxon));
-
+		/*
+		 * We do not commit tx power settings while channel changing,
+		 * do it now if tx power changed.
+		 */
+		iwl_legacy_set_tx_power(priv, priv->tx_power_next, false);
 		return 0;
 	}
 
diff --git a/drivers/net/wireless/iwlegacy/iwl-4965.c b/drivers/net/wireless/iwlegacy/iwl-4965.c
index bd4b000..ecdc6e5 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965.c
+++ b/drivers/net/wireless/iwlegacy/iwl-4965.c
@@ -1235,7 +1235,12 @@ static int iwl4965_commit_rxon(struct iwl_priv *priv, struct iwl_rxon_context *c
 
 		memcpy(active_rxon, &ctx->staging, sizeof(*active_rxon));
 		iwl_legacy_print_rx_config_cmd(priv, ctx);
-		goto set_tx_power;
+		/*
+		 * We do not commit tx power settings while channel changing,
+		 * do it now if tx power changed.
+		 */
+		iwl_legacy_set_tx_power(priv, priv->tx_power_next, false);
+		return 0;
 	}
 
 	/* If we are currently associated and the new config requires
@@ -1315,7 +1320,6 @@ static int iwl4965_commit_rxon(struct iwl_priv *priv, struct iwl_rxon_context *c
 
 	iwl4965_init_sensitivity(priv);
 
-set_tx_power:
 	/* If we issue a new RXON command which required a tune then we must
 	 * send a new TXPOWER command or we won't be able to Tx any frames */
 	ret = iwl_legacy_set_tx_power(priv, priv->tx_power_next, true);
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index 3eeb12e..c95cefd 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -365,6 +365,7 @@ static struct iwl_base_params iwl5000_base_params = {
 	.chain_noise_scale = 1000,
 	.wd_timeout = IWL_LONG_WD_TIMEOUT,
 	.max_event_log_size = 512,
+	.no_idle_support = true,
 };
 static struct iwl_ht_params iwl5000_ht_params = {
 	.ht_greenfield_support = true,
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 3e6bb73..02817a4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -135,6 +135,7 @@ struct iwl_mod_params {
  * @temperature_kelvin: temperature report by uCode in kelvin
  * @max_event_log_size: size of event log buffer size for ucode event logging
  * @shadow_reg_enable: HW shadhow register bit
+ * @no_idle_support: do not support idle mode
  */
 struct iwl_base_params {
 	int eeprom_size;
@@ -156,6 +157,7 @@ struct iwl_base_params {
 	bool temperature_kelvin;
 	u32 max_event_log_size;
 	const bool shadow_reg_enable;
+	const bool no_idle_support;
 };
 /*
  * @advanced_bt_coexist: support advanced bt coexist
diff --git a/drivers/net/wireless/iwlwifi/iwl-pci.c b/drivers/net/wireless/iwlwifi/iwl-pci.c
index fb7e436..69d4ec4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-pci.c
+++ b/drivers/net/wireless/iwlwifi/iwl-pci.c
@@ -134,6 +134,7 @@ static void iwl_pci_apm_config(struct iwl_bus *bus)
 static void iwl_pci_set_drv_data(struct iwl_bus *bus, void *drv_data)
 {
 	bus->drv_data = drv_data;
+	pci_set_drvdata(IWL_BUS_GET_PCI_DEV(bus), drv_data);
 }
 
 static void iwl_pci_get_hw_id(struct iwl_bus *bus, char buf[],
@@ -454,8 +455,6 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		pci_write_config_word(pdev, PCI_COMMAND, pci_cmd);
 	}
 
-	pci_set_drvdata(pdev, bus);
-
 	bus->dev = &pdev->dev;
 	bus->irq = pdev->irq;
 	bus->ops = &pci_ops;
@@ -494,11 +493,12 @@ static void iwl_pci_down(struct iwl_bus *bus)
 
 static void __devexit iwl_pci_remove(struct pci_dev *pdev)
 {
-	struct iwl_bus *bus = pci_get_drvdata(pdev);
+	struct iwl_priv *priv = pci_get_drvdata(pdev);
+	void *bus_specific = priv->bus->bus_specific;
 
-	iwl_remove(bus->drv_data);
+	iwl_remove(priv);
 
-	iwl_pci_down(bus);
+	iwl_pci_down(bus_specific);
 }
 
 #ifdef CONFIG_PM
@@ -506,20 +506,20 @@ static void __devexit iwl_pci_remove(struct pci_dev *pdev)
 static int iwl_pci_suspend(struct device *device)
 {
 	struct pci_dev *pdev = to_pci_dev(device);
-	struct iwl_bus *bus = pci_get_drvdata(pdev);
+	struct iwl_priv *priv = pci_get_drvdata(pdev);
 
 	/* Before you put code here, think about WoWLAN. You cannot check here
 	 * whether WoWLAN is enabled or not, and your code will run even if
 	 * WoWLAN is enabled - don't kill the NIC, someone may need it in Sx.
 	 */
 
-	return iwl_suspend(bus->drv_data);
+	return iwl_suspend(priv);
 }
 
 static int iwl_pci_resume(struct device *device)
 {
 	struct pci_dev *pdev = to_pci_dev(device);
-	struct iwl_bus *bus = pci_get_drvdata(pdev);
+	struct iwl_priv *priv = pci_get_drvdata(pdev);
 
 	/* Before you put code here, think about WoWLAN. You cannot check here
 	 * whether WoWLAN is enabled or not, and your code will run even if
@@ -532,7 +532,7 @@ static int iwl_pci_resume(struct device *device)
 	 */
 	pci_write_config_byte(pdev, PCI_CFG_RETRY_TIMEOUT, 0x00);
 
-	return iwl_resume(bus->drv_data);
+	return iwl_resume(priv);
 }
 
 static SIMPLE_DEV_PM_OPS(iwl_dev_pm_ops, iwl_pci_suspend, iwl_pci_resume);
diff --git a/drivers/net/wireless/iwlwifi/iwl-power.c b/drivers/net/wireless/iwlwifi/iwl-power.c
index 3ec619c..cd64df0 100644
--- a/drivers/net/wireless/iwlwifi/iwl-power.c
+++ b/drivers/net/wireless/iwlwifi/iwl-power.c
@@ -349,7 +349,8 @@ static void iwl_power_build_cmd(struct iwl_priv *priv,
 
 	if (priv->wowlan)
 		iwl_static_sleep_cmd(priv, cmd, IWL_POWER_INDEX_5, dtimper);
-	else if (priv->hw->conf.flags & IEEE80211_CONF_IDLE)
+	else if (!priv->cfg->base_params->no_idle_support &&
+		 priv->hw->conf.flags & IEEE80211_CONF_IDLE)
 		iwl_static_sleep_cmd(priv, cmd, IWL_POWER_INDEX_5, 20);
 	else if (iwl_tt_is_low_power_state(priv)) {
 		/* in thermal throttling low power state */
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index 84ab7d1..ef67f67 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -703,8 +703,7 @@ void rt2800_write_beacon(struct queue_entry *entry, struct txentry_desc *txdesc)
 	/*
 	 * Add space for the TXWI in front of the skb.
 	 */
-	skb_push(entry->skb, TXWI_DESC_SIZE);
-	memset(entry->skb, 0, TXWI_DESC_SIZE);
+	memset(skb_push(entry->skb, TXWI_DESC_SIZE), 0, TXWI_DESC_SIZE);
 
 	/*
 	 * Register descriptor details in skb frame descriptor.
diff --git a/drivers/net/wireless/rt2x00/rt2x00lib.h b/drivers/net/wireless/rt2x00/rt2x00lib.h
index 15cdc7e..4cdf247 100644
--- a/drivers/net/wireless/rt2x00/rt2x00lib.h
+++ b/drivers/net/wireless/rt2x00/rt2x00lib.h
@@ -355,7 +355,8 @@ static inline enum cipher rt2x00crypto_key_to_cipher(struct ieee80211_key_conf *
 	return CIPHER_NONE;
 }
 
-static inline void rt2x00crypto_create_tx_descriptor(struct queue_entry *entry,
+static inline void rt2x00crypto_create_tx_descriptor(struct rt2x00_dev *rt2x00dev,
+						     struct sk_buff *skb,
 						     struct txentry_desc *txdesc)
 {
 }
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/rt2x00/rt2x00mac.c
index 8efab39..4ccf238 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -113,7 +113,7 @@ void rt2x00mac_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 	 * due to possible race conditions in mac80211.
 	 */
 	if (!test_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags))
-		goto exit_fail;
+		goto exit_free_skb;
 
 	/*
 	 * Use the ATIM queue if appropriate and present.
@@ -127,7 +127,7 @@ void rt2x00mac_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 		ERROR(rt2x00dev,
 		      "Attempt to send packet over invalid queue %d.\n"
 		      "Please file bug report to %s.\n", qid, DRV_PROJECT);
-		goto exit_fail;
+		goto exit_free_skb;
 	}
 
 	/*
@@ -159,6 +159,7 @@ void rt2x00mac_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 
  exit_fail:
 	rt2x00queue_pause_queue(queue);
+ exit_free_skb:
 	dev_kfree_skb_any(skb);
 }
 EXPORT_SYMBOL_GPL(rt2x00mac_tx);
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 5efd578..56f1235 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1696,15 +1696,17 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 	pcipriv->ndis_adapter.devnumber = PCI_SLOT(pdev->devfn);
 	pcipriv->ndis_adapter.funcnumber = PCI_FUNC(pdev->devfn);
 
-	/*find bridge info */
-	pcipriv->ndis_adapter.pcibridge_vendorid = bridge_pdev->vendor;
-	for (tmp = 0; tmp < PCI_BRIDGE_VENDOR_MAX; tmp++) {
-		if (bridge_pdev->vendor == pcibridge_vendors[tmp]) {
-			pcipriv->ndis_adapter.pcibridge_vendor = tmp;
-			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-				 ("Pci Bridge Vendor is found index: %d\n",
-				  tmp));
-			break;
+	if (bridge_pdev) {
+		/*find bridge info if available */
+		pcipriv->ndis_adapter.pcibridge_vendorid = bridge_pdev->vendor;
+		for (tmp = 0; tmp < PCI_BRIDGE_VENDOR_MAX; tmp++) {
+			if (bridge_pdev->vendor == pcibridge_vendors[tmp]) {
+				pcipriv->ndis_adapter.pcibridge_vendor = tmp;
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
+					 ("Pci Bridge Vendor is found index:"
+					 " %d\n", tmp));
+				break;
+			}
 		}
 	}
 
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 28d2aa1..e83e7fe 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -3464,7 +3464,7 @@ static int nl80211_trigger_scan(struct sk_buff *skb, struct genl_info *info)
 				    tmp) {
 			enum ieee80211_band band = nla_type(attr);
 
-			if (band < 0 || band > IEEE80211_NUM_BANDS) {
+			if (band < 0 || band >= IEEE80211_NUM_BANDS) {
 				err = -EINVAL;
 				goto out_free;
 			}
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
