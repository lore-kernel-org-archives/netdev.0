From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH][TG3]: Add PHY workaround for 5784
Date: Thu, 03 Apr 2008 20:07:29 -0800
Message-ID: <1207282049.5625.3.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4954 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499AbYDDDFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2008 23:05:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[TG3]: Add PHY workaround for 5784

The 5784 B step and newer chips require the PHY DSPs to be fine-tuned
based on one-time programmable values stored in the chip.  This is
essential to achieve optimal PHY operations especially when using
long cables.  We also need to properly handle the 10Mbit RX bit in the
CPMU_CTRL register during PHY reset.

Update version to 3.89.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f9ef8bd..d4655b2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.88"
-#define DRV_MODULE_RELDATE	"March 20, 2008"
+#define DRV_MODULE_VERSION	"3.89"
+#define DRV_MODULE_RELDATE	"April 03, 2008"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -804,6 +804,12 @@ static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
 	return ret;
 }
 
+static void tg3_phydsp_write(struct tg3 *tp, u32 reg, u32 val)
+{
+	tg3_writephy(tp, MII_TG3_DSP_ADDRESS, reg);
+	tg3_writephy(tp, MII_TG3_DSP_RW_PORT, val);
+}
+
 static void tg3_phy_toggle_automdix(struct tg3 *tp, int enable)
 {
 	u32 phy;
@@ -886,6 +892,49 @@ static int tg3_bmcr_reset(struct tg3 *tp)
 	return 0;
 }
 
+static void tg3_phy_apply_otp(struct tg3 *tp)
+{
+	u32 otp, phy;
+
+	if (!tp->phy_otp)
+		return;
+
+	otp = tp->phy_otp;
+
+	/* Enable SM_DSP clock and tx 6dB coding. */
+	phy = MII_TG3_AUXCTL_SHDWSEL_AUXCTL |
+	      MII_TG3_AUXCTL_ACTL_SMDSP_ENA |
+	      MII_TG3_AUXCTL_ACTL_TX_6DB;
+	tg3_writephy(tp, MII_TG3_AUX_CTRL, phy);
+
+	phy = ((otp & TG3_OTP_AGCTGT_MASK) >> TG3_OTP_AGCTGT_SHIFT);
+	phy |= MII_TG3_DSP_TAP1_AGCTGT_DFLT;
+	tg3_phydsp_write(tp, MII_TG3_DSP_TAP1, phy);
+
+	phy = ((otp & TG3_OTP_HPFFLTR_MASK) >> TG3_OTP_HPFFLTR_SHIFT) |
+	      ((otp & TG3_OTP_HPFOVER_MASK) >> TG3_OTP_HPFOVER_SHIFT);
+	tg3_phydsp_write(tp, MII_TG3_DSP_AADJ1CH0, phy);
+
+	phy = ((otp & TG3_OTP_LPFDIS_MASK) >> TG3_OTP_LPFDIS_SHIFT);
+	phy |= MII_TG3_DSP_AADJ1CH3_ADCCKADJ;
+	tg3_phydsp_write(tp, MII_TG3_DSP_AADJ1CH3, phy);
+
+	phy = ((otp & TG3_OTP_VDAC_MASK) >> TG3_OTP_VDAC_SHIFT);
+	tg3_phydsp_write(tp, MII_TG3_DSP_EXP75, phy);
+
+	phy = ((otp & TG3_OTP_10BTAMP_MASK) >> TG3_OTP_10BTAMP_SHIFT);
+	tg3_phydsp_write(tp, MII_TG3_DSP_EXP96, phy);
+
+	phy = ((otp & TG3_OTP_ROFF_MASK) >> TG3_OTP_ROFF_SHIFT) |
+	      ((otp & TG3_OTP_RCOFF_MASK) >> TG3_OTP_RCOFF_SHIFT);
+	tg3_phydsp_write(tp, MII_TG3_DSP_EXP97, phy);
+
+	/* Turn off SM_DSP clock. */
+	phy = MII_TG3_AUXCTL_SHDWSEL_AUXCTL |
+	      MII_TG3_AUXCTL_ACTL_TX_6DB;
+	tg3_writephy(tp, MII_TG3_AUX_CTRL, phy);
+}
+
 static int tg3_wait_macro_done(struct tg3 *tp)
 {
 	int limit = 100;
@@ -1073,6 +1122,7 @@ static void tg3_link_report(struct tg3 *);
  */
 static int tg3_phy_reset(struct tg3 *tp)
 {
+	u32 cpmuctrl;
 	u32 phy_status;
 	int err;
 
@@ -1102,10 +1152,28 @@ static int tg3_phy_reset(struct tg3 *tp)
 		goto out;
 	}
 
+	cpmuctrl = 0;
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
+	    GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) {
+		cpmuctrl = tr32(TG3_CPMU_CTRL);
+		if (cpmuctrl & CPMU_CTRL_GPHY_10MB_RXONLY)
+			tw32(TG3_CPMU_CTRL,
+			     cpmuctrl & ~CPMU_CTRL_GPHY_10MB_RXONLY);
+	}
+
 	err = tg3_bmcr_reset(tp);
 	if (err)
 		return err;
 
+	if (cpmuctrl & CPMU_CTRL_GPHY_10MB_RXONLY) {
+		u32 phy;
+
+		phy = MII_TG3_DSP_EXP8_AEDW | MII_TG3_DSP_EXP8_REJ2MHz;
+		tg3_phydsp_write(tp, MII_TG3_DSP_EXP8, phy);
+
+		tw32(TG3_CPMU_CTRL, cpmuctrl);
+	}
+
 	if (tp->tg3_flags3 & TG3_FLG3_5761_5784_AX_FIXES) {
 		u32 val;
 
@@ -1124,6 +1192,8 @@ static int tg3_phy_reset(struct tg3 *tp)
 			     MII_TG3_MISC_SHDW_APD_WKTM_84MS);
 	}
 
+	tg3_phy_apply_otp(tp);
+
 out:
 	if (tp->tg3_flags2 & TG3_FLG2_PHY_ADC_BUG) {
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
@@ -9464,7 +9534,8 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (err)
 		return TG3_LOOPBACK_FAILED;
 
-	if (tp->tg3_flags3 & TG3_FLG3_5761_5784_AX_FIXES) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761) {
 		int i;
 		u32 status;
 
@@ -9481,17 +9552,23 @@ static int tg3_test_loopback(struct tg3 *tp)
 		if (status != CPMU_MUTEX_GNT_DRIVER)
 			return TG3_LOOPBACK_FAILED;
 
-		/* Turn off power management based on link speed. */
+		/* Turn off link-based power management. */
 		cpmuctrl = tr32(TG3_CPMU_CTRL);
-		tw32(TG3_CPMU_CTRL,
-		     cpmuctrl & ~(CPMU_CTRL_LINK_SPEED_MODE |
-				  CPMU_CTRL_LINK_AWARE_MODE));
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+		    GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5761_AX)
+			tw32(TG3_CPMU_CTRL,
+			     cpmuctrl & ~(CPMU_CTRL_LINK_SPEED_MODE |
+					  CPMU_CTRL_LINK_AWARE_MODE));
+		else
+			tw32(TG3_CPMU_CTRL,
+			     cpmuctrl & ~CPMU_CTRL_LINK_AWARE_MODE);
 	}
 
 	if (tg3_run_loopback(tp, TG3_MAC_LOOPBACK))
 		err |= TG3_MAC_LOOPBACK_FAILED;
 
-	if (tp->tg3_flags3 & TG3_FLG3_5761_5784_AX_FIXES) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761) {
 		tw32(TG3_CPMU_CTRL, cpmuctrl);
 
 		/* Release the mutex */
@@ -10724,9 +10801,8 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		    tp->pdev->subsystem_vendor == PCI_VENDOR_ID_DELL)
 			tp->led_ctrl = LED_CTRL_MODE_PHY_2;
 
-		if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
-		    tp->pci_chip_rev_id == CHIPREV_ID_5784_A1)
-			tp->led_ctrl = LED_CTRL_MODE_MAC;
+		if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5784_AX)
+			tp->led_ctrl = LED_CTRL_MODE_PHY_1;
 
 		if (nic_cfg & NIC_SRAM_DATA_CFG_EEPROM_WP) {
 			tp->tg3_flags |= TG3_FLAG_EEPROM_WRITE_PROT;
@@ -10773,6 +10849,55 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 	}
 }
 
+static int __devinit tg3_issue_otp_command(struct tg3 *tp, u32 cmd)
+{
+	int i;
+	u32 val;
+
+	tw32(OTP_CTRL, cmd | OTP_CTRL_OTP_CMD_START);
+	tw32(OTP_CTRL, cmd);
+
+	/* Wait for up to 1 ms for command to execute. */
+	for (i = 0; i < 100; i++) {
+		val = tr32(OTP_STATUS);
+		if (val & OTP_STATUS_CMD_DONE)
+			break;
+		udelay(10);
+	}
+
+	return (val & OTP_STATUS_CMD_DONE) ? 0 : -EBUSY;
+}
+
+/* Read the gphy configuration from the OTP region of the chip.  The gphy
+ * configuration is a 32-bit value that straddles the alignment boundary.
+ * We do two 32-bit reads and then shift and merge the results.
+ */
+static u32 __devinit tg3_read_otp_phycfg(struct tg3 *tp)
+{
+	u32 bhalf_otp, thalf_otp;
+
+	tw32(OTP_MODE, OTP_MODE_OTP_THRU_GRC);
+
+	if (tg3_issue_otp_command(tp, OTP_CTRL_OTP_CMD_INIT))
+		return 0;
+
+	tw32(OTP_ADDRESS, OTP_ADDRESS_MAGIC1);
+
+	if (tg3_issue_otp_command(tp, OTP_CTRL_OTP_CMD_READ))
+		return 0;
+
+	thalf_otp = tr32(OTP_READ_DATA);
+
+	tw32(OTP_ADDRESS, OTP_ADDRESS_MAGIC2);
+
+	if (tg3_issue_otp_command(tp, OTP_CTRL_OTP_CMD_READ))
+		return 0;
+
+	bhalf_otp = tr32(OTP_READ_DATA);
+
+	return ((thalf_otp & 0x0000ffff) << 16) | (bhalf_otp >> 16);
+}
+
 static int __devinit tg3_phy_probe(struct tg3 *tp)
 {
 	u32 hw_phy_id_1, hw_phy_id_2;
@@ -11586,6 +11711,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			tp->tg3_flags2 |= TG3_FLG2_PHY_BER_BUG;
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
+	    GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) {
+		tp->phy_otp = tg3_read_otp_phycfg(tp);
+		if (tp->phy_otp == 0)
+			tp->phy_otp = TG3_OTP_DEFAULT;
+	}
+
 	tp->coalesce_mode = 0;
 	if (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5700_AX &&
 	    GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5700_BX)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 3938eb3..c1075a7 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -138,6 +138,8 @@
 #define   CHIPREV_5704_BX		 0x21
 #define   CHIPREV_5750_AX		 0x40
 #define   CHIPREV_5750_BX		 0x41
+#define   CHIPREV_5784_AX		 0x57840
+#define   CHIPREV_5761_AX		 0x57610
 #define  GET_METAL_REV(CHIP_REV_ID)	((CHIP_REV_ID) & 0xff)
 #define   METAL_REV_A0			 0x00
 #define   METAL_REV_A1			 0x01
@@ -866,6 +868,7 @@
 #define  CPMU_CTRL_LINK_IDLE_MODE	 0x00000200
 #define  CPMU_CTRL_LINK_AWARE_MODE	 0x00000400
 #define  CPMU_CTRL_LINK_SPEED_MODE	 0x00004000
+#define  CPMU_CTRL_GPHY_10MB_RXONLY	 0x00010000
 #define TG3_CPMU_LSPD_10MB_CLK		0x00003604
 #define  CPMU_LSPD_10MB_MACCLK_MASK	 0x001f0000
 #define  CPMU_LSPD_10MB_MACCLK_6_25	 0x00130000
@@ -1559,7 +1562,24 @@
 /* 0x702c unused */
 
 #define NVRAM_ADDR_LOCKOUT		0x00007030
-/* 0x7034 --> 0x7c00 unused */
+/* 0x7034 --> 0x7500 unused */
+
+#define OTP_MODE			0x00007500
+#define OTP_MODE_OTP_THRU_GRC		 0x00000001
+#define OTP_CTRL			0x00007504
+#define OTP_CTRL_OTP_PROG_ENABLE	 0x00200000
+#define OTP_CTRL_OTP_CMD_READ		 0x00000000
+#define OTP_CTRL_OTP_CMD_INIT		 0x00000008
+#define OTP_CTRL_OTP_CMD_START		 0x00000001
+#define OTP_STATUS			0x00007508
+#define OTP_STATUS_CMD_DONE		 0x00000001
+#define OTP_ADDRESS			0x0000750c
+#define OTP_ADDRESS_MAGIC1		 0x000000a0
+#define OTP_ADDRESS_MAGIC2		 0x00000080
+/* 0x7510 unused */
+
+#define OTP_READ_DATA			0x00007514
+/* 0x7518 --> 0x7c04 unused */
 
 #define PCIE_TRANSACTION_CFG		0x00007c04
 #define PCIE_TRANS_CFG_1SHOT_MSI	 0x20000000
@@ -1568,6 +1588,28 @@
 #define PCIE_PWR_MGMT_THRESH		0x00007d28
 #define PCIE_PWR_MGMT_L1_THRESH_MSK	 0x0000ff00
 
+
+/* OTP bit definitions */
+#define TG3_OTP_AGCTGT_MASK		0x000000e0
+#define TG3_OTP_AGCTGT_SHIFT		1
+#define TG3_OTP_HPFFLTR_MASK		0x00000300
+#define TG3_OTP_HPFFLTR_SHIFT		1
+#define TG3_OTP_HPFOVER_MASK		0x00000400
+#define TG3_OTP_HPFOVER_SHIFT		1
+#define TG3_OTP_LPFDIS_MASK		0x00000800
+#define TG3_OTP_LPFDIS_SHIFT		11
+#define TG3_OTP_VDAC_MASK		0xff000000
+#define TG3_OTP_VDAC_SHIFT		24
+#define TG3_OTP_10BTAMP_MASK		0x0000f000
+#define TG3_OTP_10BTAMP_SHIFT		8
+#define TG3_OTP_ROFF_MASK		0x00e00000
+#define TG3_OTP_ROFF_SHIFT		11
+#define TG3_OTP_RCOFF_MASK		0x001c0000
+#define TG3_OTP_RCOFF_SHIFT		16
+
+#define TG3_OTP_DEFAULT			0x286c1640
+
+
 #define TG3_EEPROM_MAGIC		0x669955aa
 #define TG3_EEPROM_MAGIC_FW		0xa5000000
 #define TG3_EEPROM_MAGIC_FW_MSK		0xff000000
@@ -1705,15 +1747,31 @@
 
 #define MII_TG3_DSP_RW_PORT		0x15 /* DSP coefficient read/write port */
 
-#define MII_TG3_DSP_ADDRESS		0x17 /* DSP address register */
 #define MII_TG3_EPHY_PTEST		0x17 /* 5906 PHY register */
+#define MII_TG3_DSP_ADDRESS		0x17 /* DSP address register */
+
+#define MII_TG3_DSP_TAP1		0x0001
+#define  MII_TG3_DSP_TAP1_AGCTGT_DFLT	0x0007
+#define MII_TG3_DSP_AADJ1CH0		0x001f
+#define MII_TG3_DSP_AADJ1CH3		0x601f
+#define  MII_TG3_DSP_AADJ1CH3_ADCCKADJ	0x0002
+#define MII_TG3_DSP_EXP8		0x0708
+#define  MII_TG3_DSP_EXP8_REJ2MHz	0x0001
+#define  MII_TG3_DSP_EXP8_AEDW		0x0200
+#define MII_TG3_DSP_EXP75		0x0f75
+#define MII_TG3_DSP_EXP96		0x0f96
+#define MII_TG3_DSP_EXP97		0x0f97
 
 #define MII_TG3_AUX_CTRL		0x18 /* auxilliary control register */
 
 #define MII_TG3_AUXCTL_MISC_WREN	0x8000
 #define MII_TG3_AUXCTL_MISC_FORCE_AMDIX	0x0200
 #define MII_TG3_AUXCTL_MISC_RDSEL_MISC	0x7000
-#define MII_TG3_AUXCTL_SHDWSEL_MISC		0x0007
+#define MII_TG3_AUXCTL_SHDWSEL_MISC	0x0007
+
+#define MII_TG3_AUXCTL_ACTL_SMDSP_ENA	0x0800
+#define MII_TG3_AUXCTL_ACTL_TX_6DB	0x0400
+#define MII_TG3_AUXCTL_SHDWSEL_AUXCTL	0x0000
 
 #define MII_TG3_AUX_STAT		0x19 /* auxilliary status register */
 #define MII_TG3_AUX_STAT_LPASS		0x0004
@@ -1743,6 +1801,20 @@
 #define MII_TG3_INT_DUPLEXCHG		0x0008
 #define MII_TG3_INT_ANEG_PAGE_RX	0x0400
 
+#define MII_TG3_MISC_SHDW		0x1c
+#define MII_TG3_MISC_SHDW_WREN		0x8000
+#define MII_TG3_MISC_SHDW_SCR5_SEL	0x1400
+#define MII_TG3_MISC_SHDW_APD_SEL	0x2800
+
+#define MII_TG3_MISC_SHDW_SCR5_C125OE	0x0001
+#define MII_TG3_MISC_SHDW_SCR5_DLLAPD	0x0002
+#define MII_TG3_MISC_SHDW_SCR5_SDTL	0x0004
+#define MII_TG3_MISC_SHDW_SCR5_DLPTLM	0x0008
+#define MII_TG3_MISC_SHDW_SCR5_LPED	0x0010
+
+#define MII_TG3_MISC_SHDW_APD_WKTM_84MS	0x0001
+#define MII_TG3_MISC_SHDW_APD_ENABLE	0x0020
+
 #define MII_TG3_EPHY_TEST		0x1f /* 5906 PHY register */
 #define MII_TG3_EPHY_SHADOW_EN		0x80
 
@@ -2473,6 +2545,7 @@ struct tg3 {
 #define PHY_REV_BCM5411_X0		0x1 /* Found on Netgear GA302T */
 
 	u32				led_ctrl;
+	u32				phy_otp;
 	u16				pci_cmd;
 
 	char				board_part_number[24];


