From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 04/12] amd-xgbe-phy: On suspend,
 save CTRL1 reg for use on resume
Date: Fri, 16 Jan 2015 12:46:39 -0600
Message-ID: <20150116184639.18809.48101.stgit@tlendack-t1.amdoffice.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44033 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756807AbbAPSyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:31 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reads to registers are undefined when the PCS is powered down. To be
safe, save the CTRL1 register used for power down during suspend and
restore that value during resume.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |   20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index b65a0a8..5ce42e3 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -350,6 +350,8 @@ struct amd_xgbe_phy_priv {
 	struct work_struct an_work;
 	struct workqueue_struct *an_workqueue;
 	unsigned int parallel_detect;
+
+	unsigned int lpm_ctrl;		/* CTRL1 for resume */
 };
 
 static int amd_xgbe_an_enable_kr_training(struct phy_device *phydev)
@@ -1250,6 +1252,7 @@ static int amd_xgbe_phy_read_status(struct phy_device *phydev)
 
 static int amd_xgbe_phy_suspend(struct phy_device *phydev)
 {
+	struct amd_xgbe_phy_priv *priv = phydev->priv;
 	int ret;
 
 	mutex_lock(&phydev->lock);
@@ -1258,6 +1261,8 @@ static int amd_xgbe_phy_suspend(struct phy_device *phydev)
 	if (ret < 0)
 		goto unlock;
 
+	priv->lpm_ctrl = ret;
+
 	ret |= MDIO_CTRL1_LPOWER;
 	phy_write_mmd(phydev, MDIO_MMD_PCS, MDIO_CTRL1, ret);
 
@@ -1271,23 +1276,16 @@ unlock:
 
 static int amd_xgbe_phy_resume(struct phy_device *phydev)
 {
-	int ret;
+	struct amd_xgbe_phy_priv *priv = phydev->priv;
 
 	mutex_lock(&phydev->lock);
 
-	ret = phy_read_mmd(phydev, MDIO_MMD_PCS, MDIO_CTRL1);
-	if (ret < 0)
-		goto unlock;
-
-	ret &= ~MDIO_CTRL1_LPOWER;
-	phy_write_mmd(phydev, MDIO_MMD_PCS, MDIO_CTRL1, ret);
-
-	ret = 0;
+	priv->lpm_ctrl &= ~MDIO_CTRL1_LPOWER;
+	phy_write_mmd(phydev, MDIO_MMD_PCS, MDIO_CTRL1, priv->lpm_ctrl);
 
-unlock:
 	mutex_unlock(&phydev->lock);
 
-	return ret;
+	return 0;
 }
 
 static int amd_xgbe_phy_probe(struct phy_device *phydev)
