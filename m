From: AceLan Kao <acelan.kao@canonical.com>
Subject: [PATCH 1/6] ath9k: add MSI support and use_msi parameter
Date: Tue, 26 Sep 2017 14:41:34 +0800
Message-ID: <1506408099-18488-1-git-send-email-acelan.kao@canonical.com>
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding MSI support for ath9k devices.
This patch is originally from Qualcomm, but they have no intention of
submitting and maintaining ath9k driver now.
The credit should go to Qualcomm.

Signed-off-by: AceLan Kao <acelan.kao@canonical.com>
---
 drivers/net/wireless/ath/ath9k/hw.c   | 33 ++++++++++++++++++------
 drivers/net/wireless/ath/ath9k/hw.h   |  3 +++
 drivers/net/wireless/ath/ath9k/init.c |  4 +++
 drivers/net/wireless/ath/ath9k/mac.c  | 47 +++++++++++++++++++++++++++++++++++
 drivers/net/wireless/ath/ath9k/pci.c  | 21 +++++++++++++++-
 drivers/net/wireless/ath/ath9k/reg.h  | 15 +++++++++++
 6 files changed, 115 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 8c5c2dd..cd0f023 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -922,6 +922,7 @@ static void ath9k_hw_init_interrupt_masks(struct ath_hw *ah,
 		AR_IMR_RXERR |
 		AR_IMR_RXORN |
 		AR_IMR_BCNMISC;
+	u32 msi_cfg = 0;
 
 	if (AR_SREV_9340(ah) || AR_SREV_9550(ah) || AR_SREV_9531(ah) ||
 	    AR_SREV_9561(ah))
@@ -929,22 +930,30 @@ static void ath9k_hw_init_interrupt_masks(struct ath_hw *ah,
 
 	if (AR_SREV_9300_20_OR_LATER(ah)) {
 		imr_reg |= AR_IMR_RXOK_HP;
-		if (ah->config.rx_intr_mitigation)
+		if (ah->config.rx_intr_mitigation) {
 			imr_reg |= AR_IMR_RXINTM | AR_IMR_RXMINTR;
-		else
+			msi_cfg |= AR_INTCFG_MSI_RXINTM | AR_INTCFG_MSI_RXMINTR;
+		} else {
 			imr_reg |= AR_IMR_RXOK_LP;
-
+			msi_cfg |= AR_INTCFG_MSI_RXOK;
+		}
 	} else {
-		if (ah->config.rx_intr_mitigation)
+		if (ah->config.rx_intr_mitigation) {
 			imr_reg |= AR_IMR_RXINTM | AR_IMR_RXMINTR;
-		else
+			msi_cfg |= AR_INTCFG_MSI_RXINTM | AR_INTCFG_MSI_RXMINTR;
+		} else {
 			imr_reg |= AR_IMR_RXOK;
+			msi_cfg |= AR_INTCFG_MSI_RXOK;
+		}
 	}
 
-	if (ah->config.tx_intr_mitigation)
+	if (ah->config.tx_intr_mitigation) {
 		imr_reg |= AR_IMR_TXINTM | AR_IMR_TXMINTR;
-	else
+		msi_cfg |= AR_INTCFG_MSI_TXINTM | AR_INTCFG_MSI_TXMINTR;
+	} else {
 		imr_reg |= AR_IMR_TXOK;
+		msi_cfg |= AR_INTCFG_MSI_TXOK;
+	}
 
 	ENABLE_REGWRITE_BUFFER(ah);
 
@@ -952,6 +961,16 @@ static void ath9k_hw_init_interrupt_masks(struct ath_hw *ah,
 	ah->imrs2_reg |= AR_IMR_S2_GTT;
 	REG_WRITE(ah, AR_IMR_S2, ah->imrs2_reg);
 
+	if (ah->msi_enabled) {
+		ah->msi_reg = REG_READ(ah, AR_PCIE_MSI);
+		ah->msi_reg |= AR_PCIE_MSI_HW_DBI_WR_EN;
+		ah->msi_reg &= AR_PCIE_MSI_HW_INT_PENDING_ADDR_MSI_64;
+		REG_WRITE(ah, AR_INTCFG, msi_cfg);
+		ath_dbg(ath9k_hw_common(ah), ANY,
+			"value of AR_INTCFG=0x%X, msi_cfg=0x%X\n",
+			REG_READ(ah, AR_INTCFG), msi_cfg);
+	}
+
 	if (!AR_SREV_9100(ah)) {
 		REG_WRITE(ah, AR_INTR_SYNC_CAUSE, 0xFFFFFFFF);
 		REG_WRITE(ah, AR_INTR_SYNC_ENABLE, sync_default);
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index 4ac7082..0d6c07c7 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -977,6 +977,9 @@ struct ath_hw {
 	bool tpc_enabled;
 	u8 tx_power[Ar5416RateSize];
 	u8 tx_power_stbc[Ar5416RateSize];
+	bool msi_enabled;
+	u32 msi_mask;
+	u32 msi_reg;
 };
 
 struct ath_bus_ops {
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index bb79360..b6b7a35 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -75,6 +75,10 @@ MODULE_PARM_DESC(use_chanctx, "Enable channel context for concurrency");
 
 #endif /* CONFIG_ATH9K_CHANNEL_CONTEXT */
 
+int ath9k_use_msi;
+module_param_named(use_msi, ath9k_use_msi, int, 0444);
+MODULE_PARM_DESC(use_msi, "Use MSI instead of INTx if possible");
+
 bool is_ath9k_unloaded;
 
 #ifdef CONFIG_MAC80211_LEDS
diff --git a/drivers/net/wireless/ath/ath9k/mac.c b/drivers/net/wireless/ath/ath9k/mac.c
index 77c94f9..58d02c1 100644
--- a/drivers/net/wireless/ath/ath9k/mac.c
+++ b/drivers/net/wireless/ath/ath9k/mac.c
@@ -832,6 +832,43 @@ static void __ath9k_hw_enable_interrupts(struct ath_hw *ah)
 	}
 	ath_dbg(common, INTERRUPT, "AR_IMR 0x%x IER 0x%x\n",
 		REG_READ(ah, AR_IMR), REG_READ(ah, AR_IER));
+
+	if (ah->msi_enabled) {
+		u32 _msi_reg = 0;
+		u32 i = 0;
+		u32 msi_pend_addr_mask = AR_PCIE_MSI_HW_INT_PENDING_ADDR_MSI_64;
+
+		ath_dbg(ath9k_hw_common(ah), INTERRUPT,
+			"Enabling MSI, msi_mask=0x%X\n", ah->msi_mask);
+
+		REG_WRITE(ah, AR_INTR_PRIO_ASYNC_ENABLE, ah->msi_mask);
+		REG_WRITE(ah, AR_INTR_PRIO_ASYNC_MASK, ah->msi_mask);
+		ath_dbg(ath9k_hw_common(ah), INTERRUPT,
+			"AR_INTR_PRIO_ASYNC_ENABLE=0x%X, AR_INTR_PRIO_ASYNC_MASK=0x%X\n",
+			REG_READ(ah, AR_INTR_PRIO_ASYNC_ENABLE),
+			REG_READ(ah, AR_INTR_PRIO_ASYNC_MASK));
+
+		if (ah->msi_reg == 0)
+			ah->msi_reg = REG_READ(ah, AR_PCIE_MSI);
+
+		ath_dbg(ath9k_hw_common(ah), INTERRUPT,
+			"AR_PCIE_MSI=0x%X, ah->msi_reg = 0x%X\n",
+			AR_PCIE_MSI, ah->msi_reg);
+
+		i = 0;
+		do {
+			REG_WRITE(ah, AR_PCIE_MSI,
+				  (ah->msi_reg | AR_PCIE_MSI_ENABLE)
+				  & msi_pend_addr_mask);
+			_msi_reg = REG_READ(ah, AR_PCIE_MSI);
+			i++;
+		} while ((_msi_reg & AR_PCIE_MSI_ENABLE) == 0 && i < 200);
+
+		if (i >= 200)
+			ath_err(ath9k_hw_common(ah),
+				"%s: _msi_reg = 0x%X\n",
+				__func__, _msi_reg);
+	}
 }
 
 void ath9k_hw_resume_interrupts(struct ath_hw *ah)
@@ -878,12 +915,21 @@ void ath9k_hw_set_interrupts(struct ath_hw *ah)
 	if (!(ints & ATH9K_INT_GLOBAL))
 		ath9k_hw_disable_interrupts(ah);
 
+	if (ah->msi_enabled) {
+		ath_dbg(common, INTERRUPT, "Clearing AR_INTR_PRIO_ASYNC_ENABLE\n");
+
+		REG_WRITE(ah, AR_INTR_PRIO_ASYNC_ENABLE, 0);
+		REG_READ(ah, AR_INTR_PRIO_ASYNC_ENABLE);
+	}
+
 	ath_dbg(common, INTERRUPT, "New interrupt mask 0x%x\n", ints);
 
 	mask = ints & ATH9K_INT_COMMON;
 	mask2 = 0;
 
+	ah->msi_mask = 0;
 	if (ints & ATH9K_INT_TX) {
+		ah->msi_mask |= AR_INTR_PRIO_TX;
 		if (ah->config.tx_intr_mitigation)
 			mask |= AR_IMR_TXMINTR | AR_IMR_TXINTM;
 		else {
@@ -898,6 +944,7 @@ void ath9k_hw_set_interrupts(struct ath_hw *ah)
 			mask |= AR_IMR_TXEOL;
 	}
 	if (ints & ATH9K_INT_RX) {
+		ah->msi_mask |= AR_INTR_PRIO_RXLP | AR_INTR_PRIO_RXHP;
 		if (AR_SREV_9300_20_OR_LATER(ah)) {
 			mask |= AR_IMR_RXERR | AR_IMR_RXOK_HP;
 			if (ah->config.rx_intr_mitigation) {
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index 2236063..645f0fb 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -22,6 +22,8 @@
 #include <linux/module.h>
 #include "ath9k.h"
 
+extern int ath9k_use_msi;
+
 static const struct pci_device_id ath_pci_id_table[] = {
 	{ PCI_VDEVICE(ATHEROS, 0x0023) }, /* PCI   */
 	{ PCI_VDEVICE(ATHEROS, 0x0024) }, /* PCI-E */
@@ -889,6 +891,7 @@ static int ath_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	u32 val;
 	int ret = 0;
 	char hw_name[64];
+	int msi_enabled = 0;
 
 	if (pcim_enable_device(pdev))
 		return -EIO;
@@ -960,7 +963,20 @@ static int ath_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	sc->mem = pcim_iomap_table(pdev)[0];
 	sc->driver_data = id->driver_data;
 
-	ret = request_irq(pdev->irq, ath_isr, IRQF_SHARED, "ath9k", sc);
+	if (ath9k_use_msi) {
+		if (pci_enable_msi(pdev) == 0) {
+			msi_enabled = 1;
+			dev_err(&pdev->dev, "Using MSI\n");
+		} else {
+			dev_err(&pdev->dev, "Using INTx\n");
+		}
+	}
+
+	if (!msi_enabled)
+		ret = request_irq(pdev->irq, ath_isr, IRQF_SHARED, "ath9k", sc);
+	else
+		ret = request_irq(pdev->irq, ath_isr, 0, "ath9k", sc);
+
 	if (ret) {
 		dev_err(&pdev->dev, "request_irq failed\n");
 		goto err_irq;
@@ -974,6 +990,9 @@ static int ath_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_init;
 	}
 
+	sc->sc_ah->msi_enabled = msi_enabled;
+	sc->sc_ah->msi_reg = 0;
+
 	ath9k_hw_name(sc->sc_ah, hw_name, sizeof(hw_name));
 	wiphy_info(hw->wiphy, "%s mem=0x%lx, irq=%d\n",
 		   hw_name, (unsigned long)sc->mem, pdev->irq);
diff --git a/drivers/net/wireless/ath/ath9k/reg.h b/drivers/net/wireless/ath/ath9k/reg.h
index 80ff69f..653e796 100644
--- a/drivers/net/wireless/ath/ath9k/reg.h
+++ b/drivers/net/wireless/ath/ath9k/reg.h
@@ -146,6 +146,14 @@
 #define AR_MACMISC_MISC_OBS_BUS_MSB_S   15
 #define AR_MACMISC_MISC_OBS_BUS_1       1
 
+#define AR_INTCFG               0x005C
+#define AR_INTCFG_MSI_RXOK      0x00000000
+#define AR_INTCFG_MSI_RXINTM    0x00000004
+#define AR_INTCFG_MSI_RXMINTR   0x00000006
+#define AR_INTCFG_MSI_TXOK      0x00000000
+#define AR_INTCFG_MSI_TXINTM    0x00000010
+#define AR_INTCFG_MSI_TXMINTR   0x00000018
+
 #define AR_DATABUF_SIZE		0x0060
 #define AR_DATABUF_SIZE_MASK	0x00000FFF
 
@@ -1256,6 +1264,13 @@ enum {
 #define AR_PCIE_MSI                             (AR_SREV_9340(ah) ? 0x40d8 : \
 						 (AR_SREV_9300_20_OR_LATER(ah) ? 0x40a4 : 0x4094))
 #define AR_PCIE_MSI_ENABLE                       0x00000001
+#define AR_PCIE_MSI_HW_DBI_WR_EN                 0x02000000
+#define AR_PCIE_MSI_HW_INT_PENDING_ADDR          0xFFA0C1FF /* bits 8..11: value must be 0x5060 */
+#define AR_PCIE_MSI_HW_INT_PENDING_ADDR_MSI_64   0xFFA0C9FF /* bits 8..11: value must be 0x5064 */
+
+#define AR_INTR_PRIO_TX               0x00000001
+#define AR_INTR_PRIO_RXLP             0x00000002
+#define AR_INTR_PRIO_RXHP             0x00000004
 
 #define AR_INTR_PRIO_SYNC_ENABLE  (AR_SREV_9340(ah) ? 0x4088 : 0x40c4)
 #define AR_INTR_PRIO_ASYNC_MASK   (AR_SREV_9340(ah) ? 0x408c : 0x40c8)
-- 
2.7.4
