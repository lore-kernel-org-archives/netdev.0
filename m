From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 03/20] tg3: Fix disappearing 57780 devices
Date: Mon, 2 Nov 2009 16:24:02 -0800
Message-ID: <1257211992.21989@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3429 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755669AbZKCBdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under certain power saving conditions, 57780 asic rev devices might
disappear from the system.  The fix is to disallow the PCIe PLL from
powering down.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   24 ++----------------------
 drivers/net/tg3.h |    1 -
 2 files changed, 2 insertions(+), 23 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a7a582e..b3c5d74 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3243,15 +3243,6 @@ relink:
 			pci_write_config_word(tp->pdev,
 					      tp->pcie_cap + PCI_EXP_LNKCTL,
 					      newlnkctl);
-	} else if (tp->tg3_flags3 & TG3_FLG3_TOGGLE_10_100_L1PLLPD) {
-		u32 newreg, oldreg = tr32(TG3_PCIE_LNKCTL);
-		if (tp->link_config.active_speed == SPEED_100 ||
-		    tp->link_config.active_speed == SPEED_10)
-			newreg = oldreg & ~TG3_PCIE_LNKCTL_L1_PLL_PD_EN;
-		else
-			newreg = oldreg | TG3_PCIE_LNKCTL_L1_PLL_PD_EN;
-		if (newreg != oldreg)
-			tw32(TG3_PCIE_LNKCTL, newreg);
 	}
 
 	if (current_link_up != netif_carrier_ok(tp->dev)) {
@@ -7180,15 +7171,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tw32(TG3_PCIE_EIDLE_DELAY, val | TG3_PCIE_EIDLE_DELAY_13_CLKS);
 
 		tw32(TG3_CORR_ERR_STAT, TG3_CORR_ERR_STAT_CLEAR);
-	}
 
-	if (tp->tg3_flags3 & TG3_FLG3_TOGGLE_10_100_L1PLLPD) {
-		val = tr32(TG3_PCIE_LNKCTL);
-		if (tp->tg3_flags3 & TG3_FLG3_CLKREQ_BUG)
-			val |= TG3_PCIE_LNKCTL_L1_PLL_PD_DIS;
-		else
-			val &= ~TG3_PCIE_LNKCTL_L1_PLL_PD_DIS;
-		tw32(TG3_PCIE_LNKCTL, val);
+		val = tr32(TG3_PCIE_LNKCTL) & ~TG3_PCIE_LNKCTL_L1_PLL_PD_EN;
+		tw32(TG3_PCIE_LNKCTL, val | TG3_PCIE_LNKCTL_L1_PLL_PD_DIS);
 	}
 
 	/* This works around an issue with Athlon chipsets on
@@ -12951,11 +12936,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 		tp->tg3_flags3 |= TG3_FLG3_USE_PHYLIB;
 
-	if ((tp->pci_chip_rev_id == CHIPREV_ID_57780_A1 &&
-	     tr32(RCVLPC_STATS_ENABLE) & RCVLPC_STATSENAB_ASF_FIX) ||
-	    tp->pci_chip_rev_id == CHIPREV_ID_57780_A0)
-		tp->tg3_flags3 |= TG3_FLG3_TOGGLE_10_100_L1PLLPD;
-
 	err = tg3_mdio_init(tp);
 	if (err)
 		return err;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index a5568a1..eb4ed82 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2756,7 +2756,6 @@ struct tg3 {
 #define TG3_FLG3_PHY_ENABLE_APD		0x00001000
 #define TG3_FLG3_5755_PLUS		0x00002000
 #define TG3_FLG3_NO_NVRAM		0x00004000
-#define TG3_FLG3_TOGGLE_10_100_L1PLLPD	0x00008000
 #define TG3_FLG3_PHY_IS_FET		0x00010000
 #define TG3_FLG3_ENABLE_RSS		0x00020000
 #define TG3_FLG3_4G_DMA_BNDRY_BUG	0x00080000
-- 
1.6.4.4


