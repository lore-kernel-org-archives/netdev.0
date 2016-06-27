From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 1/2] net: thunderx: Fix link status reporting
Date: Mon, 27 Jun 2016 15:30:02 +0530
Message-ID: <1467021603-26226-2-git-send-email-sunil.kovvuri@gmail.com>
References: <1467021603-26226-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	robert.richter@caviumnetworks.com, Naveen.Reddy@cavium.com,
	Sunil Goutham <sgoutham@cavium.com>,
	Tao Wang <tao.wang@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467021603-26226-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Check for SMU RX local/remote faults along with SPU LINK
status. Otherwise at times link is UP at our end but DOWN
at link partner's side. Also due to an issue in BGX it's
rarely seen that initialization doesn't happen properly
and SMU RX reports faults with everything fine at SPU.
This patch tries to reinitialize LMAC to fix it.

Also fixed LMAC disable sequence to properly bring down link.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: Tao Wang <tao.wang@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 91 +++++++++++++++--------
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h |  2 +
 2 files changed, 62 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 3ed2198..289cb19 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -551,7 +551,9 @@ static int bgx_xaui_check_link(struct lmac *lmac)
 	}
 
 	/* Clear rcvflt bit (latching high) and read it back */
-	bgx_reg_modify(bgx, lmacid, BGX_SPUX_STATUS2, SPU_STATUS2_RCVFLT);
+	if (bgx_reg_read(bgx, lmacid, BGX_SPUX_STATUS2) & SPU_STATUS2_RCVFLT)
+		bgx_reg_modify(bgx, lmacid,
+			       BGX_SPUX_STATUS2, SPU_STATUS2_RCVFLT);
 	if (bgx_reg_read(bgx, lmacid, BGX_SPUX_STATUS2) & SPU_STATUS2_RCVFLT) {
 		dev_err(&bgx->pdev->dev, "Receive fault, retry training\n");
 		if (bgx->use_training) {
@@ -570,13 +572,6 @@ static int bgx_xaui_check_link(struct lmac *lmac)
 		return -1;
 	}
 
-	/* Wait for MAC RX to be ready */
-	if (bgx_poll_reg(bgx, lmacid, BGX_SMUX_RX_CTL,
-			 SMU_RX_CTL_STATUS, true)) {
-		dev_err(&bgx->pdev->dev, "SMU RX link not okay\n");
-		return -1;
-	}
-
 	/* Wait for BGX RX to be idle */
 	if (bgx_poll_reg(bgx, lmacid, BGX_SMUX_CTL, SMU_CTL_RX_IDLE, false)) {
 		dev_err(&bgx->pdev->dev, "SMU RX not idle\n");
@@ -589,29 +584,30 @@ static int bgx_xaui_check_link(struct lmac *lmac)
 		return -1;
 	}
 
-	if (bgx_reg_read(bgx, lmacid, BGX_SPUX_STATUS2) & SPU_STATUS2_RCVFLT) {
-		dev_err(&bgx->pdev->dev, "Receive fault\n");
-		return -1;
-	}
-
-	/* Receive link is latching low. Force it high and verify it */
-	bgx_reg_modify(bgx, lmacid, BGX_SPUX_STATUS1, SPU_STATUS1_RCV_LNK);
-	if (bgx_poll_reg(bgx, lmacid, BGX_SPUX_STATUS1,
-			 SPU_STATUS1_RCV_LNK, false)) {
-		dev_err(&bgx->pdev->dev, "SPU receive link down\n");
-		return -1;
-	}
-
+	/* Clear receive packet disable */
 	cfg = bgx_reg_read(bgx, lmacid, BGX_SPUX_MISC_CONTROL);
 	cfg &= ~SPU_MISC_CTL_RX_DIS;
 	bgx_reg_write(bgx, lmacid, BGX_SPUX_MISC_CONTROL, cfg);
-	return 0;
+
+	/* Check for MAC RX faults */
+	cfg = bgx_reg_read(bgx, lmacid, BGX_SMUX_RX_CTL);
+	/* 0 - Link is okay, 1 - Local fault, 2 - Remote fault */
+	cfg &= SMU_RX_CTL_STATUS;
+	if (!cfg)
+		return 0;
+
+	/* Rx local/remote fault seen.
+	 * Do lmac reinit to see if condition recovers
+	 */
+	bgx_lmac_xaui_init(bgx, lmacid, bgx->lmac_type);
+
+	return -1;
 }
 
 static void bgx_poll_for_link(struct work_struct *work)
 {
 	struct lmac *lmac;
-	u64 link;
+	u64 spu_link, smu_link;
 
 	lmac = container_of(work, struct lmac, dwork.work);
 
@@ -621,8 +617,11 @@ static void bgx_poll_for_link(struct work_struct *work)
 	bgx_poll_reg(lmac->bgx, lmac->lmacid, BGX_SPUX_STATUS1,
 		     SPU_STATUS1_RCV_LNK, false);
 
-	link = bgx_reg_read(lmac->bgx, lmac->lmacid, BGX_SPUX_STATUS1);
-	if (link & SPU_STATUS1_RCV_LNK) {
+	spu_link = bgx_reg_read(lmac->bgx, lmac->lmacid, BGX_SPUX_STATUS1);
+	smu_link = bgx_reg_read(lmac->bgx, lmac->lmacid, BGX_SMUX_RX_CTL);
+
+	if ((spu_link & SPU_STATUS1_RCV_LNK) &&
+	    !(smu_link & SMU_RX_CTL_STATUS)) {
 		lmac->link_up = 1;
 		if (lmac->bgx->lmac_type == BGX_MODE_XLAUI)
 			lmac->last_speed = 40000;
@@ -636,9 +635,15 @@ static void bgx_poll_for_link(struct work_struct *work)
 	}
 
 	if (lmac->last_link != lmac->link_up) {
+		if (lmac->link_up) {
+			if (bgx_xaui_check_link(lmac)) {
+				/* Errors, clear link_up state */
+				lmac->link_up = 0;
+				lmac->last_speed = SPEED_UNKNOWN;
+				lmac->last_duplex = DUPLEX_UNKNOWN;
+			}
+		}
 		lmac->last_link = lmac->link_up;
-		if (lmac->link_up)
-			bgx_xaui_check_link(lmac);
 	}
 
 	queue_delayed_work(lmac->check_link, &lmac->dwork, HZ * 2);
@@ -710,7 +715,7 @@ static int bgx_lmac_enable(struct bgx *bgx, u8 lmacid)
 static void bgx_lmac_disable(struct bgx *bgx, u8 lmacid)
 {
 	struct lmac *lmac;
-	u64 cmrx_cfg;
+	u64 cfg;
 
 	lmac = &bgx->lmac[lmacid];
 	if (lmac->check_link) {
@@ -719,9 +724,33 @@ static void bgx_lmac_disable(struct bgx *bgx, u8 lmacid)
 		destroy_workqueue(lmac->check_link);
 	}
 
-	cmrx_cfg = bgx_reg_read(bgx, lmacid, BGX_CMRX_CFG);
-	cmrx_cfg &= ~(1 << 15);
-	bgx_reg_write(bgx, lmacid, BGX_CMRX_CFG, cmrx_cfg);
+	/* Disable packet reception */
+	cfg = bgx_reg_read(bgx, lmacid, BGX_CMRX_CFG);
+	cfg &= ~CMR_PKT_RX_EN;
+	bgx_reg_write(bgx, lmacid, BGX_CMRX_CFG, cfg);
+
+	/* Give chance for Rx/Tx FIFO to get drained */
+	bgx_poll_reg(bgx, lmacid, BGX_CMRX_RX_FIFO_LEN, (u64)0x1FFF, true);
+	bgx_poll_reg(bgx, lmacid, BGX_CMRX_TX_FIFO_LEN, (u64)0x3FFF, true);
+
+	/* Disable packet transmission */
+	cfg = bgx_reg_read(bgx, lmacid, BGX_CMRX_CFG);
+	cfg &= ~CMR_PKT_TX_EN;
+	bgx_reg_write(bgx, lmacid, BGX_CMRX_CFG, cfg);
+
+	/* Disable serdes lanes */ 
+        if (!lmac->is_sgmii)
+                bgx_reg_modify(bgx, lmacid,
+                               BGX_SPUX_CONTROL1, SPU_CTL_LOW_POWER);
+        else
+                bgx_reg_modify(bgx, lmacid,
+                               BGX_GMP_PCS_MRX_CTL, PCS_MRX_CTL_PWR_DN);
+
+	/* Disable LMAC */
+	cfg = bgx_reg_read(bgx, lmacid, BGX_CMRX_CFG);
+	cfg &= ~CMR_EN;
+	bgx_reg_write(bgx, lmacid, BGX_CMRX_CFG, cfg);
+
 	bgx_flush_dmac_addrs(bgx, lmacid);
 
 	if ((bgx->lmac_type != BGX_MODE_XFI) &&
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
index 149e179..42010d2 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -41,6 +41,7 @@
 #define BGX_CMRX_RX_STAT10		0xC0
 #define BGX_CMRX_RX_BP_DROP		0xC8
 #define BGX_CMRX_RX_DMAC_CTL		0x0E8
+#define BGX_CMRX_RX_FIFO_LEN		0x108
 #define BGX_CMR_RX_DMACX_CAM		0x200
 #define  RX_DMACX_CAM_EN			BIT_ULL(48)
 #define  RX_DMACX_CAM_LMACID(x)			(x << 49)
@@ -50,6 +51,7 @@
 #define BGX_CMR_CHAN_MSK_AND		0x450
 #define BGX_CMR_BIST_STATUS		0x460
 #define BGX_CMR_RX_LMACS		0x468
+#define BGX_CMRX_TX_FIFO_LEN		0x518
 #define BGX_CMRX_TX_STAT0		0x600
 #define BGX_CMRX_TX_STAT1		0x608
 #define BGX_CMRX_TX_STAT2		0x610
-- 
2.7.4
