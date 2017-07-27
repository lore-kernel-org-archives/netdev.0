From: sunil.kovvuri@gmail.com
Subject: [PATCH] net: thunderx: Fix BGX transmit stall due to underflow
Date: Thu, 27 Jul 2017 12:53:04 +0530
Message-ID: <1501140184-25625-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

For SGMII/RGMII/QSGMII interfaces when physical link goes down
while traffic is high is resulting in underflow condition being set
on that specific BGX's LMAC. Which assets a backpresure and VNIC stops
transmitting packets.

This is due to BGX being disabled in link status change callback while
packet is in transit. This patch fixes this issue by not disabling BGX
but instead just disables packet Rx and Tx.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 27 ++++++++++++++++++-----
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h |  2 ++
 2 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 7911256..5e5c4d7 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -292,11 +292,30 @@ static void bgx_sgmii_change_link_state(struct lmac *lmac)
 	u64 cmr_cfg;
 	u64 port_cfg = 0;
 	u64 misc_ctl = 0;
+	bool tx_en, rx_en;
 
 	cmr_cfg = bgx_reg_read(bgx, lmac->lmacid, BGX_CMRX_CFG);
-	cmr_cfg &= ~CMR_EN;
+	tx_en = cmr_cfg & CMR_PKT_TX_EN;
+	rx_en = cmr_cfg & CMR_PKT_RX_EN;
+	cmr_cfg &= ~(CMR_PKT_RX_EN | CMR_PKT_TX_EN);
 	bgx_reg_write(bgx, lmac->lmacid, BGX_CMRX_CFG, cmr_cfg);
 
+	/* Wait for BGX RX to be idle */
+	if (bgx_poll_reg(bgx, lmac->lmacid, BGX_GMP_GMI_PRTX_CFG,
+			 GMI_PORT_CFG_RX_IDLE, false)) {
+		dev_err(&bgx->pdev->dev, "BGX%d LMAC%d GMI RX not idle\n",
+			bgx->bgx_id, lmac->lmacid);
+		return;
+	}
+
+	/* Wait for BGX TX to be idle */
+	if (bgx_poll_reg(bgx, lmac->lmacid, BGX_GMP_GMI_PRTX_CFG,
+			 GMI_PORT_CFG_TX_IDLE, false)) {
+		dev_err(&bgx->pdev->dev, "BGX%d LMAC%d GMI TX not idle\n",
+			bgx->bgx_id, lmac->lmacid);
+		return;
+	}
+
 	port_cfg = bgx_reg_read(bgx, lmac->lmacid, BGX_GMP_GMI_PRTX_CFG);
 	misc_ctl = bgx_reg_read(bgx, lmac->lmacid, BGX_GMP_PCS_MISCX_CTL);
 
@@ -347,10 +366,8 @@ static void bgx_sgmii_change_link_state(struct lmac *lmac)
 	bgx_reg_write(bgx, lmac->lmacid, BGX_GMP_PCS_MISCX_CTL, misc_ctl);
 	bgx_reg_write(bgx, lmac->lmacid, BGX_GMP_GMI_PRTX_CFG, port_cfg);
 
-	port_cfg = bgx_reg_read(bgx, lmac->lmacid, BGX_GMP_GMI_PRTX_CFG);
-
-	/* Re-enable lmac */
-	cmr_cfg |= CMR_EN;
+	/* Restore CMR config settings */
+	cmr_cfg |= (rx_en ? CMR_PKT_RX_EN : 0) | (tx_en ? CMR_PKT_TX_EN : 0);
 	bgx_reg_write(bgx, lmac->lmacid, BGX_CMRX_CFG, cmr_cfg);
 
 	if (bgx->is_rgx && (cmr_cfg & (CMR_PKT_RX_EN | CMR_PKT_TX_EN)))
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
index 6b7fe6fd..23acdc5 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -170,6 +170,8 @@
 #define  GMI_PORT_CFG_DUPLEX			BIT_ULL(2)
 #define  GMI_PORT_CFG_SLOT_TIME			BIT_ULL(3)
 #define  GMI_PORT_CFG_SPEED_MSB			BIT_ULL(8)
+#define  GMI_PORT_CFG_RX_IDLE			BIT_ULL(12)
+#define  GMI_PORT_CFG_TX_IDLE			BIT_ULL(13)
 #define BGX_GMP_GMI_RXX_JABBER		0x38038
 #define BGX_GMP_GMI_TXX_THRESH		0x38210
 #define BGX_GMP_GMI_TXX_APPEND		0x38218
-- 
2.7.4
