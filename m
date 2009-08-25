From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 02/12] tg3: Prevent tx BD corruption
Date: Tue, 25 Aug 2009 13:07:27 -0700
Message-ID: <1251232429.25401@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1676 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756047AbZHYUgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 16:36:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prevents a tx BD corruption bug by preventing the device from
powering down the PLL from L1 if the link speed is 10Mbps or 100Mbps.

The same bits are also used to prevent a system hang during chip reset
resulting from a complicated set of events that ultimately leads to
PCIe block register corruption.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   28 ++++++++++++++++++++++++++++
 drivers/net/tg3.h |    9 ++++++++-
 2 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e8def28..595ddf2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3167,6 +3167,15 @@ relink:
 			pci_write_config_word(tp->pdev,
 					      tp->pcie_cap + PCI_EXP_LNKCTL,
 					      newlnkctl);
+	} else if (tp->tg3_flags3 & TG3_FLG3_TOGGLE_10_100_L1PLLPD) {
+		u32 newreg, oldreg = tr32(TG3_PCIE_LNKCTL);
+		if (tp->link_config.active_speed == SPEED_100 ||
+		    tp->link_config.active_speed == SPEED_10)
+			newreg = oldreg & ~TG3_PCIE_LNKCTL_L1_PLL_PD_EN;
+		else
+			newreg = oldreg | TG3_PCIE_LNKCTL_L1_PLL_PD_EN;
+		if (newreg != oldreg)
+			tw32(TG3_PCIE_LNKCTL, newreg);
 	}
 
 	if (current_link_up != netif_carrier_ok(tp->dev)) {
@@ -6160,6 +6169,11 @@ static int tg3_chip_reset(struct tg3 *tp)
 	smp_mb();
 	synchronize_irq(tp->pdev->irq);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780) {
+		val = tr32(TG3_PCIE_LNKCTL) & ~TG3_PCIE_LNKCTL_L1_PLL_PD_EN;
+		tw32(TG3_PCIE_LNKCTL, val | TG3_PCIE_LNKCTL_L1_PLL_PD_DIS);
+	}
+
 	/* do the reset */
 	val = GRC_MISC_CFG_CORECLK_RESET;
 
@@ -6726,6 +6740,15 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tw32(TG3_CORR_ERR_STAT, TG3_CORR_ERR_STAT_CLEAR);
 	}
 
+	if (tp->tg3_flags3 & TG3_FLG3_TOGGLE_10_100_L1PLLPD) {
+		val = tr32(TG3_PCIE_LNKCTL);
+		if (tp->tg3_flags3 & TG3_FLG3_CLKREQ_BUG)
+			val |= TG3_PCIE_LNKCTL_L1_PLL_PD_DIS;
+		else
+			val &= ~TG3_PCIE_LNKCTL_L1_PLL_PD_DIS;
+		tw32(TG3_PCIE_LNKCTL, val);
+	}
+
 	/* This works around an issue with Athlon chipsets on
 	 * B3 tigon3 silicon.  This bit has no effect on any
 	 * other revision.  But do not set this on PCI Express
@@ -12274,6 +12297,11 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 		tp->tg3_flags3 |= TG3_FLG3_USE_PHYLIB;
 
+	if ((tp->pci_chip_rev_id == CHIPREV_ID_57780_A1 &&
+	     tr32(RCVLPC_STATS_ENABLE) & RCVLPC_STATSENAB_ASF_FIX) ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_57780_A0)
+		tp->tg3_flags3 |= TG3_FLG3_TOGGLE_10_100_L1PLLPD;
+
 	err = tg3_mdio_init(tp);
 	if (err)
 		return err;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index c613cbb..bb8591e 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -866,6 +866,7 @@
 #define  RCVLPC_STATSCTRL_ENABLE	 0x00000001
 #define  RCVLPC_STATSCTRL_FASTUPD	 0x00000002
 #define RCVLPC_STATS_ENABLE		0x00002018
+#define  RCVLPC_STATSENAB_ASF_FIX	 0x00000002
 #define  RCVLPC_STATSENAB_DACK_FIX	 0x00040000
 #define  RCVLPC_STATSENAB_LNGBRST_RFIX	 0x00400000
 #define RCVLPC_STATS_INCMASK		0x0000201c
@@ -1704,7 +1705,12 @@
 #define PCIE_PWR_MGMT_L1_THRESH_MSK	 0x0000ff00
 #define PCIE_PWR_MGMT_L1_THRESH_4MS	 0x0000ff00
 #define PCIE_PWR_MGMT_EXT_ASPM_TMR_EN	 0x01000000
-/* 0x7d2c --> 0x7e70 unused */
+/* 0x7d2c --> 0x7d54 unused */
+
+#define TG3_PCIE_LNKCTL			0x00007d54
+#define  TG3_PCIE_LNKCTL_L1_PLL_PD_EN	 0x00000008
+#define  TG3_PCIE_LNKCTL_L1_PLL_PD_DIS	 0x00000080
+/* 0x7d58 --> 0x7e70 unused */
 
 #define TG3_PCIE_EIDLE_DELAY		0x00007e70
 #define  TG3_PCIE_EIDLE_DELAY_MASK	 0x0000001f
@@ -2650,6 +2656,7 @@ struct tg3 {
 #define TG3_FLG3_PHY_ENABLE_APD		0x00001000
 #define TG3_FLG3_5755_PLUS		0x00002000
 #define TG3_FLG3_NO_NVRAM		0x00004000
+#define TG3_FLG3_TOGGLE_10_100_L1PLLPD	0x00008000
 
 	struct timer_list		timer;
 	u16				timer_counter;
-- 
1.6.3.3


