From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2011-08-02
Date: Tue, 2 Aug 2011 14:11:31 -0400
Message-ID: <20110802181131.GH14167@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a few more fixes intended for 3.1.  Dan Carpenter gives us an
off-by-one fix in the scan trigger code for nl80211.  Felix gives us a
fix for tx power initialization for ath9k.  Larry fixes an oops on ARM
by rewriting some init code to avoid checking something that doesn't get
initialized on ARM.  This round's big hero is Stanislaw, who gives us a
brown paper bag fix for some skb handling in rt2x00, an ath9k fix to
avoid hangs on systems w/ ASPM disabled, and an iwlegacy fix to ensure
that tx power settings are applied properly.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3da3f872aa175f59e20766ed30aaea67fd4fa7d1:

  Merge branch 'for-next' of git://git.kernel.org/pub/scm/linux/kernel/git/sameo/mfd-2.6 (2011-07-31 14:31:44 -1000)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git for-davem

Dan Carpenter (1):
      cfg80211: off by one in nl80211_trigger_scan()

Felix Fietkau (1):
      ath9k: initialize tx chainmask before testing channel tx power values

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next into for-davem

Larry Finger (1):
      rtlwifi: Fix kernel oops on ARM SOC

Stanislaw Gruszka (3):
      iwlegacy: set tx power after rxon_assoc
      ath9k: skip ->config_pci_powersave() if PCIe port has ASPM disabled
      rt2x00: rt2800: fix zeroing skb structure

 drivers/net/wireless/ath/ath9k/ar9002_hw.c |    6 +-----
 drivers/net/wireless/ath/ath9k/ar9003_hw.c |    6 +-----
 drivers/net/wireless/ath/ath9k/hw.c        |   11 +++++++++--
 drivers/net/wireless/ath/ath9k/hw.h        |    3 ++-
 drivers/net/wireless/ath/ath9k/init.c      |    2 ++
 drivers/net/wireless/ath/ath9k/pci.c       |   27 +++++++++++++++++++++++++++
 drivers/net/wireless/iwlegacy/iwl-3945.c   |    6 +++++-
 drivers/net/wireless/iwlegacy/iwl-4965.c   |    8 ++++++--
 drivers/net/wireless/rt2x00/rt2800lib.c    |    3 +--
 drivers/net/wireless/rtlwifi/pci.c         |   20 +++++++++++---------
 net/wireless/nl80211.c                     |    2 +-
 11 files changed, 66 insertions(+), 28 deletions(-)

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
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
