From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 7/9][TG3]: Add 5709 PHY support.
Date: Wed, 27 Sep 2006 13:35:06 -0700
Message-ID: <1159389306.3411.24.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:23314 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030793AbWI0Ui3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 16:38:29 -0400
To: davem@davemloft.net, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add 5709 PHY support.

Add support for the 5709 10/100 PHY.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2b062d7..23f5744 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1035,6 +1035,24 @@ out:
 				 phy_reg | MII_TG3_EXT_CTRL_FIFO_ELASTIC);
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		u32 phy_reg;
+
+		/* adjust output voltage */
+		tg3_writephy(tp, MII_TG3_EPHY_PTEST, 0x12);
+
+		if (!tg3_readphy(tp, MII_TG3_EPHY_TEST, &phy_reg)) {
+			u32 phy_reg2;
+
+			tg3_writephy(tp, MII_TG3_EPHY_TEST,
+				     phy_reg | MII_TG3_EPHY_SHADOW_EN);
+			/* Enable auto-MDIX */
+			if (!tg3_readphy(tp, 0x10, &phy_reg2))
+				tg3_writephy(tp, 0x10, phy_reg2 | 0x4000);
+			tg3_writephy(tp, MII_TG3_EPHY_TEST, phy_reg);
+		}
+	}
+
 	tg3_phy_set_wirespeed(tp);
 	return 0;
 }
@@ -1151,8 +1169,11 @@ static void tg3_power_down_phy(struct tg
 	if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)
 		return;
 
-	tg3_writephy(tp, MII_TG3_EXT_CTRL, MII_TG3_EXT_CTRL_FORCE_LED_OFF);
-	tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x01b2);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906) {
+		tg3_writephy(tp, MII_TG3_EXT_CTRL,
+			     MII_TG3_EXT_CTRL_FORCE_LED_OFF);
+		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x01b2);
+	}
 
 	/* The PHY should not be powered down on some chips because
 	 * of bugs.
@@ -1505,6 +1526,13 @@ static void tg3_aux_stat_to_speed_duplex
 		break;
 
 	default:
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+			*speed = (val & MII_TG3_AUX_STAT_100) ? SPEED_100 :
+				 SPEED_10;
+			*duplex = (val & MII_TG3_AUX_STAT_FULL) ? DUPLEX_FULL :
+				  DUPLEX_HALF;
+			break;
+		}
 		*speed = SPEED_INVALID;
 		*duplex = DUPLEX_INVALID;
 		break;
@@ -1787,7 +1815,7 @@ static int tg3_setup_copper_phy(struct t
 
 	if (tp->tg3_flags & TG3_FLAG_USE_MI_INTERRUPT)
 		tg3_writephy(tp, MII_TG3_IMASK, ~MII_TG3_INT_LINKCHG);
-	else
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)
 		tg3_writephy(tp, MII_TG3_IMASK, ~0);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
@@ -6552,7 +6580,8 @@ static int tg3_reset_hw(struct tg3 *tp, 
 	if (err)
 		return err;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)) {
+	if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES) &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906) {
 		u32 tmp;
 
 		/* Clear CRC stats. */
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 2f5e00c..9259d12 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1624,6 +1624,7 @@
 #define MII_TG3_DSP_RW_PORT		0x15 /* DSP coefficient read/write port */
 
 #define MII_TG3_DSP_ADDRESS		0x17 /* DSP address register */
+#define MII_TG3_EPHY_PTEST		0x17 /* 5906 PHY register */
 
 #define MII_TG3_AUX_CTRL		0x18 /* auxilliary control register */
 
@@ -1637,6 +1638,8 @@
 #define MII_TG3_AUX_STAT_100FULL	0x0500
 #define MII_TG3_AUX_STAT_1000HALF	0x0600
 #define MII_TG3_AUX_STAT_1000FULL	0x0700
+#define MII_TG3_AUX_STAT_100		0x0008
+#define MII_TG3_AUX_STAT_FULL		0x0001
 
 #define MII_TG3_ISTAT			0x1a /* IRQ status register */
 #define MII_TG3_IMASK			0x1b /* IRQ mask register */
@@ -1647,6 +1650,9 @@
 #define MII_TG3_INT_DUPLEXCHG		0x0008
 #define MII_TG3_INT_ANEG_PAGE_RX	0x0400
 
+#define MII_TG3_EPHY_TEST		0x1f /* 5906 PHY register */
+#define MII_TG3_EPHY_SHADOW_EN		0x80
+
 /* There are two ways to manage the TX descriptors on the tigon3.
  * Either the descriptors are in host DMA'able memory, or they
  * exist only in the cards on-chip SRAM.  All 16 send bds are under


