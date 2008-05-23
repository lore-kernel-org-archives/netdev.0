From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/8] tg3: Code cleanup.
Date: Thu, 22 May 2008 19:56:57 -0700
Message-ID: <1211511417.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4999 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759991AbYEWCxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 22:53:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch applies cleanups that would otherwise clutter later
patches.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7928acc..e402f16 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1002,43 +1002,38 @@ static u8 tg3_resolve_flowctrl_1000X(u16 lcladv, u16 rmtadv)
 	return cap;
 }
 
-static void tg3_setup_flow_control(struct tg3 *tp, u32 local_adv, u32 remote_adv)
+static void tg3_setup_flow_control(struct tg3 *tp, u32 lcladv, u32 rmtadv)
 {
-	u8 new_tg3_flags = 0;
+	u8 flowctrl = 0;
 	u32 old_rx_mode = tp->rx_mode;
 	u32 old_tx_mode = tp->tx_mode;
 
 	if (tp->link_config.autoneg == AUTONEG_ENABLE &&
 	    (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG)) {
 		if (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES)
-			new_tg3_flags = tg3_resolve_flowctrl_1000X(local_adv,
-								   remote_adv);
+			flowctrl = tg3_resolve_flowctrl_1000X(lcladv, rmtadv);
 		else
-			new_tg3_flags = tg3_resolve_flowctrl_1000T(local_adv,
-								   remote_adv);
-	} else {
-		new_tg3_flags = tp->link_config.flowctrl;
-	}
+			flowctrl = tg3_resolve_flowctrl_1000T(lcladv, rmtadv);
+	} else
+		flowctrl = tp->link_config.flowctrl;
 
-	tp->link_config.active_flowctrl = new_tg3_flags;
+	tp->link_config.active_flowctrl = flowctrl;
 
-	if (new_tg3_flags & TG3_FLOW_CTRL_RX)
+	if (flowctrl & TG3_FLOW_CTRL_RX)
 		tp->rx_mode |= RX_MODE_FLOW_CTRL_ENABLE;
 	else
 		tp->rx_mode &= ~RX_MODE_FLOW_CTRL_ENABLE;
 
-	if (old_rx_mode != tp->rx_mode) {
+	if (old_rx_mode != tp->rx_mode)
 		tw32_f(MAC_RX_MODE, tp->rx_mode);
-	}
 
-	if (new_tg3_flags & TG3_FLOW_CTRL_TX)
+	if (flowctrl & TG3_FLOW_CTRL_TX)
 		tp->tx_mode |= TX_MODE_FLOW_CTRL_ENABLE;
 	else
 		tp->tx_mode &= ~TX_MODE_FLOW_CTRL_ENABLE;
 
-	if (old_tx_mode != tp->tx_mode) {
+	if (old_tx_mode != tp->tx_mode)
 		tw32_f(MAC_TX_MODE, tp->tx_mode);
-	}
 }
 
 static void tg3_phydsp_write(struct tg3 *tp, u32 reg, u32 val)
@@ -7091,7 +7086,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787) ||
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784) ||
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761))
-		val |= (1 << 29);
+		val |= WDMAC_MODE_STATUS_TAG_FIX;
 
 	tw32_f(WDMAC_MODE, val);
 	udelay(40);
@@ -11542,14 +11537,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		}
 	}
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5750 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5752 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5755 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5787 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
+	     (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		tp->tg3_flags2 |= TG3_FLG2_JUMBO_CAPABLE;
 
 	pcie_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_EXP);
@@ -11833,8 +11822,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			tp->phy_otp = TG3_OTP_DEFAULT;
 	}
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+	if (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT)
 		tp->mi_mode = MAC_MI_MODE_500KHZ_CONST;
 	else
 		tp->mi_mode = MAC_MI_MODE_BASE;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 0404f93..5643be5 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1109,6 +1109,7 @@
 #define  WDMAC_MODE_FIFOOREAD_ENAB	 0x00000100
 #define  WDMAC_MODE_LNGREAD_ENAB	 0x00000200
 #define  WDMAC_MODE_RX_ACCEL	 	 0x00000400
+#define  WDMAC_MODE_STATUS_TAG_FIX	 0x20000000
 #define WDMAC_STATUS			0x00004c04
 #define  WDMAC_STATUS_TGTABORT		 0x00000004
 #define  WDMAC_STATUS_MSTABORT		 0x00000008


