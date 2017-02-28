From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 2/3] amd-xgbe: Be sure to set MDIO modes on device
 (re)start
Date: Tue, 28 Feb 2017 15:03:01 -0600
Message-ID: <20170228210301.32166.46205.stgit@tlendack-t1.amdoffice.net>
References: <20170228210242.32166.30038.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0066.outbound.protection.outlook.com ([104.47.40.66]:20106
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751648AbdB1VVE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 16:21:04 -0500
In-Reply-To: <20170228210242.32166.30038.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MDIO register mode is set when the device is probed. But when the
device is brought down and then back up, the MDIO register mode has been
reset.  Be sure to reset the mode during device startup and only change
the mode of the address specified.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c |   22 ++++++++++++++++++++++
 2 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index a7d16db..937f37a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1323,7 +1323,7 @@ static int xgbe_read_ext_mii_regs(struct xgbe_prv_data *pdata, int addr,
 static int xgbe_set_ext_mii_mode(struct xgbe_prv_data *pdata, unsigned int port,
 				 enum xgbe_mdio_mode mode)
 {
-	unsigned int reg_val = 0;
+	unsigned int reg_val = XGMAC_IOREAD(pdata, MAC_MDIOCL22R);
 
 	switch (mode) {
 	case XGBE_MDIO_MODE_CL22:
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
index 9d8c9530..04804cb 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
@@ -875,6 +875,16 @@ static int xgbe_phy_find_phy_device(struct xgbe_prv_data *pdata)
 	    !phy_data->sfp_phy_avail)
 		return 0;
 
+	/* Set the proper MDIO mode for the PHY */
+	ret = pdata->hw_if.set_ext_mii_mode(pdata, phy_data->mdio_addr,
+					    phy_data->phydev_mode);
+	if (ret) {
+		netdev_err(pdata->netdev,
+			   "mdio port/clause not compatible (%u/%u)\n",
+			   phy_data->mdio_addr, phy_data->phydev_mode);
+		return ret;
+	}
+
 	/* Create and connect to the PHY device */
 	phydev = get_phy_device(phy_data->mii, phy_data->mdio_addr,
 				(phy_data->phydev_mode == XGBE_MDIO_MODE_CL45));
@@ -2722,6 +2732,18 @@ static int xgbe_phy_start(struct xgbe_prv_data *pdata)
 	if (ret)
 		return ret;
 
+	/* Set the proper MDIO mode for the re-driver */
+	if (phy_data->redrv && !phy_data->redrv_if) {
+		ret = pdata->hw_if.set_ext_mii_mode(pdata, phy_data->redrv_addr,
+						    XGBE_MDIO_MODE_CL22);
+		if (ret) {
+			netdev_err(pdata->netdev,
+				   "redriver mdio port not compatible (%u)\n",
+				   phy_data->redrv_addr);
+			return ret;
+		}
+	}
+
 	/* Start in highest supported mode */
 	xgbe_phy_set_mode(pdata, phy_data->start_mode);
 
