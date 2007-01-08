From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3]: Add PHY workaround for 5755M.
Date: Mon, 08 Jan 2007 15:58:00 -0800
Message-ID: <1168300680.4430.12.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2955 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161188AbXAHXLL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 18:11:11 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add PHY workaround for 5755M.

Some PHY trim values need to be fine-tuned on 5755M to be
IEEE-compliant.

Update version to 3.72.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4056ba1..d5c2241 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -68,8 +68,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.71"
-#define DRV_MODULE_RELDATE	"December 15, 2006"
+#define DRV_MODULE_VERSION	"3.72"
+#define DRV_MODULE_RELDATE	"January 8, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -1015,7 +1015,12 @@ out:
 	else if (tp->tg3_flags2 & TG3_FLG2_PHY_JITTER_BUG) {
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
 		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x000a);
-		tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x010b);
+		if (tp->tg3_flags2 & TG3_FLG2_PHY_ADJUST_TRIM) {
+			tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x110b);
+			tg3_writephy(tp, MII_TG3_TEST1,
+				     MII_TG3_TEST1_TRIM_EN | 0x4);
+		} else
+			tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x010b);
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
 	}
 	/* Set Extended packet length bit (bit 14) on all chips that */
@@ -10803,9 +10808,11 @@ static int __devinit tg3_get_invariants(
 
 	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787) {
 			tp->tg3_flags2 |= TG3_FLG2_PHY_JITTER_BUG;
-		else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)
+			if (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5755M)
+				tp->tg3_flags2 |= TG3_FLG2_PHY_ADJUST_TRIM;
+		} else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)
 			tp->tg3_flags2 |= TG3_FLG2_PHY_BER_BUG;
 	}
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index cf78a7e..80f59ac 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1658,6 +1658,9 @@
 #define MII_TG3_EPHY_TEST		0x1f /* 5906 PHY register */
 #define MII_TG3_EPHY_SHADOW_EN		0x80
 
+#define MII_TG3_TEST1			0x1e
+#define MII_TG3_TEST1_TRIM_EN		0x0010
+
 /* There are two ways to manage the TX descriptors on the tigon3.
  * Either the descriptors are in host DMA'able memory, or they
  * exist only in the cards on-chip SRAM.  All 16 send bds are under
@@ -2256,6 +2259,7 @@ struct tg3 {
 #define TG3_FLG2_1SHOT_MSI		0x10000000
 #define TG3_FLG2_PHY_JITTER_BUG		0x20000000
 #define TG3_FLG2_NO_FWARE_REPORTED	0x40000000
+#define TG3_FLG2_PHY_ADJUST_TRIM	0x80000000
 
 	u32				split_mode_max_reqs;
 #define SPLIT_MODE_5704_MAX_REQ		3


