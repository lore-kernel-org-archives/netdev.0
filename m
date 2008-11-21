From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 04/10] tg3: Enable GPHY APD on select devices
Date: Fri, 21 Nov 2008 11:01:12 -0800
Message-ID: <1227295575.5618@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1315 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755161AbYKUT0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 14:26:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GPHY Autopowerdown (APD) is a way to save power when energy is not
detected on the wire.  At the moment, only the 5784 and 5761 are
apable of enabling this mode.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++------
 drivers/net/tg3.h |    2 ++
 2 files changed, 48 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 659fb99..6972fe5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1474,6 +1474,34 @@ static void tg3_phydsp_write(struct tg3 *tp, u32 reg, u32 val)
 	tg3_writephy(tp, MII_TG3_DSP_RW_PORT, val);
 }
 
+static void tg3_phy_toggle_apd(struct tg3 *tp, bool enable)
+{
+	u32 reg;
+
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+		return;
+
+	reg = MII_TG3_MISC_SHDW_WREN |
+	      MII_TG3_MISC_SHDW_SCR5_SEL |
+	      MII_TG3_MISC_SHDW_SCR5_LPED |
+	      MII_TG3_MISC_SHDW_SCR5_DLPTLM |
+	      MII_TG3_MISC_SHDW_SCR5_SDTL |
+	      MII_TG3_MISC_SHDW_SCR5_C125OE;
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 || !enable)
+		reg |= MII_TG3_MISC_SHDW_SCR5_DLLAPD;
+
+	tg3_writephy(tp, MII_TG3_MISC_SHDW, reg);
+
+
+	reg = MII_TG3_MISC_SHDW_WREN |
+	      MII_TG3_MISC_SHDW_APD_SEL |
+	      MII_TG3_MISC_SHDW_APD_WKTM_84MS;
+	if (enable)
+		reg |= MII_TG3_MISC_SHDW_APD_ENABLE;
+
+	tg3_writephy(tp, MII_TG3_MISC_SHDW, reg);
+}
+
 static void tg3_phy_toggle_automdix(struct tg3 *tp, int enable)
 {
 	u32 phy;
@@ -1816,16 +1844,15 @@ static int tg3_phy_reset(struct tg3 *tp)
 			udelay(40);
 			tw32_f(TG3_CPMU_LSPD_1000MB_CLK, val);
 		}
-
-		/* Disable GPHY autopowerdown. */
-		tg3_writephy(tp, MII_TG3_MISC_SHDW,
-			     MII_TG3_MISC_SHDW_WREN |
-			     MII_TG3_MISC_SHDW_APD_SEL |
-			     MII_TG3_MISC_SHDW_APD_WKTM_84MS);
 	}
 
 	tg3_phy_apply_otp(tp);
 
+	if (tp->tg3_flags3 & TG3_FLG3_PHY_ENABLE_APD)
+		tg3_phy_toggle_apd(tp, true);
+	else
+		tg3_phy_toggle_apd(tp, false);
+
 out:
 	if (tp->tg3_flags2 & TG3_FLG2_PHY_ADC_BUG) {
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
@@ -10264,6 +10291,10 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (err)
 		return TG3_LOOPBACK_FAILED;
 
+	/* Turn off gphy autopowerdown. */
+	if (tp->tg3_flags3 & TG3_FLG3_PHY_ENABLE_APD)
+		tg3_phy_toggle_apd(tp, false);
+
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
@@ -10308,6 +10339,10 @@ static int tg3_test_loopback(struct tg3 *tp)
 			err |= TG3_PHY_LOOPBACK_FAILED;
 	}
 
+	/* Re-enable gphy autopowerdown. */
+	if (tp->tg3_flags3 & TG3_FLG3_PHY_ENABLE_APD)
+		tg3_phy_toggle_apd(tp, true);
+
 	return err;
 }
 
@@ -11596,6 +11631,11 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		if (cfg2 & (1 << 18))
 			tp->tg3_flags2 |= TG3_FLG2_SERDES_PREEMPHASIS;
 
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
+		    GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX &&
+		    (cfg2 & NIC_SRAM_DATA_CFG_2_APD_EN))
+			tp->tg3_flags3 |= TG3_FLG3_PHY_ENABLE_APD;
+
 		if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
 			u32 cfg3;
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 53684b9..eba62e2 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1822,6 +1822,7 @@
 
 #define NIC_SRAM_DATA_CFG_2		0x00000d38
 
+#define  NIC_SRAM_DATA_CFG_2_APD_EN	 0x00000400
 #define  SHASTA_EXT_LED_MODE_MASK	 0x00018000
 #define  SHASTA_EXT_LED_LEGACY		 0x00000000
 #define  SHASTA_EXT_LED_SHARED		 0x00008000
@@ -2619,6 +2620,7 @@ struct tg3 {
 #define TG3_FLG3_RGMII_EXT_IBND_RX_EN	0x00000200
 #define TG3_FLG3_RGMII_EXT_IBND_TX_EN	0x00000400
 #define TG3_FLG3_CLKREQ_BUG		0x00000800
+#define TG3_FLG3_PHY_ENABLE_APD		0x00001000
 
 	struct timer_list		timer;
 	u16				timer_counter;
-- 
1.5.6.4



