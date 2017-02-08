From: sunil.kovvuri@gmail.com
Subject: [PATCH net] net: thunderx: Fix PHY autoneg for SGMII QLM mode
Date: Wed,  8 Feb 2017 18:09:00 +0530
Message-ID: <1486557540-818-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>,
 Thanneeru Srinivasulu <tsrinivasulu@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Thanneeru Srinivasulu <tsrinivasulu@cavium.com>

This patch fixes the case where there is no phydev attached
to a LMAC in DT due to non-existance of a PHY driver or due
to usage of non-stanadard PHY which doesn't support autoneg.
Changes dependeds on firmware to send correct info w.r.t
PHY and autoneg capability.

This patch also covers a case where a 10G/40G interface is used
as a 1G with convertors with Cortina PHY in between.

Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@cavium.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 108 +++++++++++++++++++---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h |   5 +
 2 files changed, 101 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 2f85b64..1e46952 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -31,6 +31,7 @@ struct lmac {
 	u8                      lmac_type;
 	u8                      lane_to_sds;
 	bool                    use_training;
+	bool                    autoneg;
 	bool			link_up;
 	int			lmacid; /* ID within BGX */
 	int			lmacid_bd; /* ID on board */
@@ -461,7 +462,17 @@ static int bgx_lmac_sgmii_init(struct bgx *bgx, struct lmac *lmac)
 	/* power down, reset autoneg, autoneg enable */
 	cfg = bgx_reg_read(bgx, lmacid, BGX_GMP_PCS_MRX_CTL);
 	cfg &= ~PCS_MRX_CTL_PWR_DN;
-	cfg |= (PCS_MRX_CTL_RST_AN | PCS_MRX_CTL_AN_EN);
+	cfg |= PCS_MRX_CTL_RST_AN;
+	if (lmac->phydev) {
+		cfg |= PCS_MRX_CTL_AN_EN;
+	} else {
+		/* In scenarios where PHY driver is not present or it's a
+		 * non-standard PHY, FW sets AN_EN to inform Linux driver
+		 * to do auto-neg and link polling or not.
+		 */
+		if (cfg & PCS_MRX_CTL_AN_EN)
+			lmac->autoneg = true;
+	}
 	bgx_reg_write(bgx, lmacid, BGX_GMP_PCS_MRX_CTL, cfg);
 
 	if (lmac->lmac_type == BGX_MODE_QSGMII) {
@@ -472,7 +483,7 @@ static int bgx_lmac_sgmii_init(struct bgx *bgx, struct lmac *lmac)
 		return 0;
 	}
 
-	if (lmac->lmac_type == BGX_MODE_SGMII) {
+	if ((lmac->lmac_type == BGX_MODE_SGMII) && lmac->phydev) {
 		if (bgx_poll_reg(bgx, lmacid, BGX_GMP_PCS_MRX_STATUS,
 				 PCS_MRX_STATUS_AN_CPT, false)) {
 			dev_err(&bgx->pdev->dev, "BGX AN_CPT not completed\n");
@@ -678,12 +689,71 @@ static int bgx_xaui_check_link(struct lmac *lmac)
 	return -1;
 }
 
+static void bgx_poll_for_sgmii_link(struct lmac *lmac)
+{
+	u64 pcs_link, an_result;
+	u8 speed;
+
+	pcs_link = bgx_reg_read(lmac->bgx, lmac->lmacid,
+				BGX_GMP_PCS_MRX_STATUS);
+
+	/*Link state bit is sticky, read it again*/
+	if (!(pcs_link & PCS_MRX_STATUS_LINK))
+		pcs_link = bgx_reg_read(lmac->bgx, lmac->lmacid,
+					BGX_GMP_PCS_MRX_STATUS);
+
+	if (bgx_poll_reg(lmac->bgx, lmac->lmacid, BGX_GMP_PCS_MRX_STATUS,
+			 PCS_MRX_STATUS_AN_CPT, false)) {
+		lmac->link_up = false;
+		lmac->last_speed = SPEED_UNKNOWN;
+		lmac->last_duplex = DUPLEX_UNKNOWN;
+		goto next_poll;
+	}
+
+	lmac->link_up = ((pcs_link & PCS_MRX_STATUS_LINK) != 0) ? true : false;
+	an_result = bgx_reg_read(lmac->bgx, lmac->lmacid,
+				 BGX_GMP_PCS_ANX_AN_RESULTS);
+
+	speed = (an_result >> 3) & 0x3;
+	lmac->last_duplex = (an_result >> 1) & 0x1;
+	switch (speed) {
+	case 0:
+		lmac->last_speed = 10;
+		break;
+	case 1:
+		lmac->last_speed = 100;
+		break;
+	case 2:
+		lmac->last_speed = 1000;
+		break;
+	default:
+		lmac->link_up = false;
+		lmac->last_speed = SPEED_UNKNOWN;
+		lmac->last_duplex = DUPLEX_UNKNOWN;
+		break;
+	}
+
+next_poll:
+
+	if (lmac->last_link != lmac->link_up) {
+		if (lmac->link_up)
+			bgx_sgmii_change_link_state(lmac);
+		lmac->last_link = lmac->link_up;
+	}
+
+	queue_delayed_work(lmac->check_link, &lmac->dwork, HZ * 3);
+}
+
 static void bgx_poll_for_link(struct work_struct *work)
 {
 	struct lmac *lmac;
 	u64 spu_link, smu_link;
 
 	lmac = container_of(work, struct lmac, dwork.work);
+	if (lmac->is_sgmii) {
+		bgx_poll_for_sgmii_link(lmac);
+		return;
+	}
 
 	/* Receive link is latching low. Force it high and verify it */
 	bgx_reg_modify(lmac->bgx, lmac->lmacid,
@@ -775,9 +845,21 @@ static int bgx_lmac_enable(struct bgx *bgx, u8 lmacid)
 	    (lmac->lmac_type != BGX_MODE_XLAUI) &&
 	    (lmac->lmac_type != BGX_MODE_40G_KR) &&
 	    (lmac->lmac_type != BGX_MODE_10G_KR)) {
-		if (!lmac->phydev)
-			return -ENODEV;
-
+		if (!lmac->phydev) {
+			if (lmac->autoneg) {
+				bgx_reg_write(bgx, lmacid,
+					      BGX_GMP_PCS_LINKX_TIMER,
+					      PCS_LINKX_TIMER_COUNT);
+				goto poll;
+			} else {
+				/* Default to below link speed and duplex */
+				lmac->link_up = true;
+				lmac->last_speed = 1000;
+				lmac->last_duplex = 1;
+				bgx_sgmii_change_link_state(lmac);
+				return 0;
+			}
+		}
 		lmac->phydev->dev_flags = 0;
 
 		if (phy_connect_direct(&lmac->netdev, lmac->phydev,
@@ -786,15 +868,17 @@ static int bgx_lmac_enable(struct bgx *bgx, u8 lmacid)
 			return -ENODEV;
 
 		phy_start_aneg(lmac->phydev);
-	} else {
-		lmac->check_link = alloc_workqueue("check_link", WQ_UNBOUND |
-						   WQ_MEM_RECLAIM, 1);
-		if (!lmac->check_link)
-			return -ENOMEM;
-		INIT_DELAYED_WORK(&lmac->dwork, bgx_poll_for_link);
-		queue_delayed_work(lmac->check_link, &lmac->dwork, 0);
+		return 0;
 	}
 
+poll:
+	lmac->check_link = alloc_workqueue("check_link", WQ_UNBOUND |
+					   WQ_MEM_RECLAIM, 1);
+	if (!lmac->check_link)
+		return -ENOMEM;
+	INIT_DELAYED_WORK(&lmac->dwork, bgx_poll_for_link);
+	queue_delayed_work(lmac->check_link, &lmac->dwork, 0);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
index c18ebfe..a60f189 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -153,10 +153,15 @@
 #define	 PCS_MRX_CTL_LOOPBACK1			BIT_ULL(14)
 #define	 PCS_MRX_CTL_RESET			BIT_ULL(15)
 #define BGX_GMP_PCS_MRX_STATUS		0x30008
+#define	 PCS_MRX_STATUS_LINK			BIT_ULL(2)
 #define	 PCS_MRX_STATUS_AN_CPT			BIT_ULL(5)
+#define BGX_GMP_PCS_ANX_ADV		0x30010
 #define BGX_GMP_PCS_ANX_AN_RESULTS	0x30020
+#define BGX_GMP_PCS_LINKX_TIMER		0x30040
+#define PCS_LINKX_TIMER_COUNT			0x1E84
 #define BGX_GMP_PCS_SGM_AN_ADV		0x30068
 #define BGX_GMP_PCS_MISCX_CTL		0x30078
+#define  PCS_MISC_CTL_MODE			BIT_ULL(8)
 #define  PCS_MISC_CTL_DISP_EN			BIT_ULL(13)
 #define  PCS_MISC_CTL_GMX_ENO			BIT_ULL(11)
 #define  PCS_MISC_CTL_SAMP_PT_MASK	0x7Full
-- 
2.7.4
