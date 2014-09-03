From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 2/4] amd-xgbe-phy: Enhance parallel detection to
 support KR speed
Date: Wed, 3 Sep 2014 12:14:22 -0500
Message-ID: <20140903171422.9710.42049.stgit@tlendack-t1.amdoffice.net>
References: <20140903171410.9710.37086.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0148.outbound.protection.outlook.com ([157.56.111.148]:3513
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932840AbaICRa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 13:30:27 -0400
In-Reply-To: <20140903171410.9710.37086.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to allow parallel detection to work in KR speed. With
both speed modes of KX and KR supported, KX must be checked first.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |   30 ++++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index b3cef20..da351d3 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -100,9 +100,11 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #ifndef MDIO_PMA_10GBR_PMD_CTRL
 #define MDIO_PMA_10GBR_PMD_CTRL		0x0096
 #endif
+
 #ifndef MDIO_PMA_10GBR_FEC_CTRL
 #define MDIO_PMA_10GBR_FEC_CTRL		0x00ab
 #endif
+
 #ifndef MDIO_AN_XNP
 #define MDIO_AN_XNP			0x0016
 #endif
@@ -110,14 +112,23 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #ifndef MDIO_AN_INTMASK
 #define MDIO_AN_INTMASK			0x8001
 #endif
+
 #ifndef MDIO_AN_INT
 #define MDIO_AN_INT			0x8002
 #endif
 
+#ifndef MDIO_AN_KR_CTRL
+#define MDIO_AN_KR_CTRL			0x8003
+#endif
+
 #ifndef MDIO_CTRL1_SPEED1G
 #define MDIO_CTRL1_SPEED1G		(MDIO_CTRL1_SPEED10G & ~BMCR_SPEED100)
 #endif
 
+#ifndef MDIO_KR_CTRL_PDETECT
+#define MDIO_KR_CTRL_PDETECT		0x01
+#endif
+
 /* SerDes integration register offsets */
 #define SIR0_KR_RT_1			0x002c
 #define SIR0_STATUS			0x0040
@@ -341,6 +352,7 @@ struct amd_xgbe_phy_priv {
 	enum amd_xgbe_phy_rx kx_state;
 	struct work_struct an_work;
 	struct workqueue_struct *an_workqueue;
+	unsigned int parallel_detect;
 };
 
 static int amd_xgbe_an_enable_kr_training(struct phy_device *phydev)
@@ -808,6 +820,13 @@ static enum amd_xgbe_phy_an amd_xgbe_an_start(struct phy_device *phydev)
 	/* Enable and start auto-negotiation */
 	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INT, 0);
 
+	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_KR_CTRL);
+	if (ret < 0)
+		return AMD_XGBE_AN_ERROR;
+
+	ret |= MDIO_KR_CTRL_PDETECT;
+	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_KR_CTRL, ret);
+
 	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_CTRL1);
 	if (ret < 0)
 		return AMD_XGBE_AN_ERROR;
@@ -888,6 +907,10 @@ static void amd_xgbe_an_state_machine(struct work_struct *work)
 	int sleep;
 	unsigned int an_supported = 0;
 
+	/* Start in KX mode */
+	if (amd_xgbe_phy_set_mode(phydev, AMD_XGBE_MODE_KX))
+		priv->an_state = AMD_XGBE_AN_ERROR;
+
 	while (1) {
 		mutex_lock(&priv->an_mutex);
 
@@ -895,8 +918,9 @@ static void amd_xgbe_an_state_machine(struct work_struct *work)
 
 		switch (priv->an_state) {
 		case AMD_XGBE_AN_START:
-			priv->an_state = amd_xgbe_an_start(phydev);
 			an_supported = 0;
+			priv->parallel_detect = 0;
+			priv->an_state = amd_xgbe_an_start(phydev);
 			break;
 
 		case AMD_XGBE_AN_EVENT:
@@ -913,6 +937,7 @@ static void amd_xgbe_an_state_machine(struct work_struct *work)
 			break;
 
 		case AMD_XGBE_AN_COMPLETE:
+			priv->parallel_detect = an_supported ? 0 : 1;
 			netdev_info(phydev->attached_dev, "%s successful\n",
 				    an_supported ? "Auto negotiation"
 						 : "Parallel detection");
@@ -1150,7 +1175,8 @@ static int amd_xgbe_phy_read_status(struct phy_device *phydev)
 	if (ret)
 		return ret;
 
-	if (phydev->autoneg == AUTONEG_ENABLE) {
+	if ((phydev->autoneg == AUTONEG_ENABLE) &&
+	    !priv->parallel_detect) {
 		if (!(mmd_mask & MDIO_DEVS_AN))
 			return -EINVAL;
 
