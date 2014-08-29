From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 3/3] amd-xgbe: Enhance auto-negotiation parallel
 detection
Date: Fri, 29 Aug 2014 10:22:07 -0500
Message-ID: <20140829152207.13783.86648.stgit@tlendack-t1.amdoffice.net>
References: <20140829152148.13783.23789.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0186.outbound.protection.outlook.com ([207.46.163.186]:50831
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753732AbaH2PWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 11:22:14 -0400
In-Reply-To: <20140829152148.13783.23789.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for parallel detection during auto negotiation while in
KR speed mode.  Additionally, don't use auto negotiation registers
to determine state if parallel detection was used.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-phy.c |   19 ++++++++++++++++++-
 drivers/net/ethernet/amd/xgbe/xgbe.h     |    1 +
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-phy.c b/drivers/net/ethernet/amd/xgbe/xgbe-phy.c
index d072201..d95c2a8 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-phy.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-phy.c
@@ -108,6 +108,10 @@
 #define MDIO_AN_INT			0x8002
 #endif
 
+#ifndef MDIO_AN_KR_CTRL
+#define MDIO_AN_KR_CTRL			0x8003
+#endif
+
 #ifndef MDIO_CTRL1_SPEED1G
 #define MDIO_CTRL1_SPEED1G		(MDIO_CTRL1_SPEED10G & ~BMCR_SPEED100)
 #endif
@@ -120,6 +124,10 @@
 #define MDIO_PMA_10GBR_KR_TRAIN_ENABLE	0x02
 #endif
 
+#ifndef MDIO_KR_CTRL_PDETECT
+#define MDIO_KR_CTRL_PDETECT		1
+#endif
+
 /* SerDes integration register offsets */
 #define SIR0_KR_RT_1			0x002c
 #define SIR0_STATUS			0x0040
@@ -642,6 +650,9 @@ static enum xgbe_an xgbe_phy_an_start(struct phy_device *phydev)
 	/* Enable and start auto-negotiation */
 	XMDIO_WRITE(pdata, MDIO_MMD_AN, MDIO_AN_INT, 0);
 
+	XMDIO_WRITE_BITS(pdata, MDIO_MMD_AN, MDIO_AN_KR_CTRL,
+			 MDIO_KR_CTRL_PDETECT, MDIO_KR_CTRL_PDETECT);
+
 	val = XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_CTRL1);
 	val |= MDIO_AN_CTRL1_ENABLE;
 	val |= MDIO_AN_CTRL1_RESTART;
@@ -714,6 +725,9 @@ static void xgbe_phy_an_state_machine(struct work_struct *work)
 	unsigned int sleep;
 	unsigned int an_supported = 0;
 
+	/* Start in KX mode */
+	xgbe_phy_set_mode(phydev, XGBE_SPEED_MODE_KX);
+
 	while (1) {
 		mutex_lock(&pdata->phy.an_mutex);
 
@@ -722,6 +736,7 @@ static void xgbe_phy_an_state_machine(struct work_struct *work)
 		switch (pdata->phy.an_state) {
 		case XGBE_AN_START:
 			an_supported = 0;
+			pdata->phy.parallel_detect = 0;
 			pdata->phy.an_state = xgbe_phy_an_start(phydev);
 			break;
 
@@ -739,6 +754,7 @@ static void xgbe_phy_an_state_machine(struct work_struct *work)
 			break;
 
 		case XGBE_AN_COMPLETE:
+			pdata->phy.parallel_detect = an_supported ? 0 : 1;
 			netdev_info(phydev->attached_dev, "%s successful\n",
 				    an_supported ? "Auto negotiation"
 						 : "Parallel detection");
@@ -956,7 +972,8 @@ static int xgbe_phy_read_status(struct phy_device *phydev)
 	if (ret)
 		return ret;
 
-	if (phydev->autoneg == AUTONEG_ENABLE) {
+	if ((phydev->autoneg == AUTONEG_ENABLE) &&
+	    !pdata->phy.parallel_detect) {
 		if (!(mmd_mask & MDIO_DEVS_AN))
 			return -EINVAL;
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 2d057cf..a964266 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -464,6 +464,7 @@ struct xgbe_phy {
 	enum xgbe_an_rx kx_state;
 	struct work_struct an_work;
 	struct workqueue_struct *an_workqueue;
+	unsigned int parallel_detect;
 };
 
 struct xgbe_hw_if {
