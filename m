From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 2/2] amd-xgbe: Perform phy connect/disconnect at dev
 open/stop
Date: Tue, 5 Aug 2014 11:21:25 -0500
Message-ID: <20140805162125.28088.51072.stgit@tlendack-t1.amdoffice.net>
References: <20140805162113.28088.67523.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0235.outbound.protection.outlook.com ([207.46.163.235]:53295
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754753AbaHEQV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2014 12:21:29 -0400
In-Reply-To: <20140805162113.28088.67523.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A change added to the mdiobus/phy api added a module_get/module_put
during phy connect/disconnect processing. Currently, the driver
performs a phy connect during module probe and a phy disconnect during
module remove. With the addition of the module_get during phy connect
the amd-xgbe module use count is incremented and can no longer be
unloaded.

Move the phy connect/disconnect from the driver probe/remove functions
to the net_device_ops ndo_open/ndo_stop functions.  This allows the
module use count to be decremented when the device(s) are brought down
and allows the module to be unloaded.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c  |  122 +++++++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c |   98 -----------------------
 2 files changed, 121 insertions(+), 99 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 3bf3c01..1f5487f 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -122,6 +122,7 @@
 #include <linux/clk.h>
 #include <linux/if_ether.h>
 #include <linux/net_tstamp.h>
+#include <linux/phy.h>
 
 #include "xgbe.h"
 #include "xgbe-common.h"
@@ -521,6 +522,114 @@ static void xgbe_free_rx_skbuff(struct xgbe_prv_data *pdata)
 	DBGPR("<--xgbe_free_rx_skbuff\n");
 }
 
+static void xgbe_adjust_link(struct net_device *netdev)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct phy_device *phydev = pdata->phydev;
+	int new_state = 0;
+
+	if (phydev == NULL)
+		return;
+
+	if (phydev->link) {
+		/* Flow control support */
+		if (pdata->pause_autoneg) {
+			if (phydev->pause || phydev->asym_pause) {
+				pdata->tx_pause = 1;
+				pdata->rx_pause = 1;
+			} else {
+				pdata->tx_pause = 0;
+				pdata->rx_pause = 0;
+			}
+		}
+
+		if (pdata->tx_pause != pdata->phy_tx_pause) {
+			hw_if->config_tx_flow_control(pdata);
+			pdata->phy_tx_pause = pdata->tx_pause;
+		}
+
+		if (pdata->rx_pause != pdata->phy_rx_pause) {
+			hw_if->config_rx_flow_control(pdata);
+			pdata->phy_rx_pause = pdata->rx_pause;
+		}
+
+		/* Speed support */
+		if (phydev->speed != pdata->phy_speed) {
+			new_state = 1;
+
+			switch (phydev->speed) {
+			case SPEED_10000:
+				hw_if->set_xgmii_speed(pdata);
+				break;
+
+			case SPEED_2500:
+				hw_if->set_gmii_2500_speed(pdata);
+				break;
+
+			case SPEED_1000:
+				hw_if->set_gmii_speed(pdata);
+				break;
+			}
+			pdata->phy_speed = phydev->speed;
+		}
+
+		if (phydev->link != pdata->phy_link) {
+			new_state = 1;
+			pdata->phy_link = 1;
+		}
+	} else if (pdata->phy_link) {
+		new_state = 1;
+		pdata->phy_link = 0;
+		pdata->phy_speed = SPEED_UNKNOWN;
+	}
+
+	if (new_state)
+		phy_print_status(phydev);
+}
+
+static int xgbe_phy_init(struct xgbe_prv_data *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	struct phy_device *phydev = pdata->phydev;
+	int ret;
+
+	pdata->phy_link = -1;
+	pdata->phy_speed = SPEED_UNKNOWN;
+	pdata->phy_tx_pause = pdata->tx_pause;
+	pdata->phy_rx_pause = pdata->rx_pause;
+
+	ret = phy_connect_direct(netdev, phydev, &xgbe_adjust_link,
+				 pdata->phy_mode);
+	if (ret) {
+		netdev_err(netdev, "phy_connect_direct failed\n");
+		return ret;
+	}
+
+	if (!phydev->drv || (phydev->drv->phy_id == 0)) {
+		netdev_err(netdev, "phy_id not valid\n");
+		ret = -ENODEV;
+		goto err_phy_connect;
+	}
+	DBGPR("  phy_connect_direct succeeded for PHY %s, link=%d\n",
+	      dev_name(&phydev->dev), phydev->link);
+
+	return 0;
+
+err_phy_connect:
+	phy_disconnect(phydev);
+
+	return ret;
+}
+
+static void xgbe_phy_exit(struct xgbe_prv_data *pdata)
+{
+	if (!pdata->phydev)
+		return;
+
+	phy_disconnect(pdata->phydev);
+}
+
 int xgbe_powerdown(struct net_device *netdev, unsigned int caller)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
@@ -986,11 +1095,16 @@ static int xgbe_open(struct net_device *netdev)
 
 	DBGPR("-->xgbe_open\n");
 
+	/* Initialize the phy */
+	ret = xgbe_phy_init(pdata);
+	if (ret)
+		return ret;
+
 	/* Enable the clocks */
 	ret = clk_prepare_enable(pdata->sysclk);
 	if (ret) {
 		netdev_alert(netdev, "dma clk_prepare_enable failed\n");
-		return ret;
+		goto err_phy_init;
 	}
 
 	ret = clk_prepare_enable(pdata->ptpclk);
@@ -1047,6 +1161,9 @@ err_ptpclk:
 err_sysclk:
 	clk_disable_unprepare(pdata->sysclk);
 
+err_phy_init:
+	xgbe_phy_exit(pdata);
+
 	return ret;
 }
 
@@ -1077,6 +1194,9 @@ static int xgbe_close(struct net_device *netdev)
 	clk_disable_unprepare(pdata->ptpclk);
 	clk_disable_unprepare(pdata->sysclk);
 
+	/* Release the phy */
+	xgbe_phy_exit(pdata);
+
 	DBGPR("<--xgbe_close\n");
 
 	return 0;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index eecd360..6d2221e 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -116,7 +116,6 @@
 
 #include <linux/module.h>
 #include <linux/kmod.h>
-#include <linux/spinlock.h>
 #include <linux/mdio.h>
 #include <linux/phy.h>
 #include <linux/of.h>
@@ -158,77 +157,6 @@ static int xgbe_mdio_write(struct mii_bus *mii, int prtad, int mmd_reg,
 	return 0;
 }
 
-static void xgbe_adjust_link(struct net_device *netdev)
-{
-	struct xgbe_prv_data *pdata = netdev_priv(netdev);
-	struct xgbe_hw_if *hw_if = &pdata->hw_if;
-	struct phy_device *phydev = pdata->phydev;
-	int new_state = 0;
-
-	if (phydev == NULL)
-		return;
-
-	DBGPR_MDIO("-->xgbe_adjust_link: address=%d, newlink=%d, curlink=%d\n",
-		   phydev->addr, phydev->link, pdata->phy_link);
-
-	if (phydev->link) {
-		/* Flow control support */
-		if (pdata->pause_autoneg) {
-			if (phydev->pause || phydev->asym_pause) {
-				pdata->tx_pause = 1;
-				pdata->rx_pause = 1;
-			} else {
-				pdata->tx_pause = 0;
-				pdata->rx_pause = 0;
-			}
-		}
-
-		if (pdata->tx_pause != pdata->phy_tx_pause) {
-			hw_if->config_tx_flow_control(pdata);
-			pdata->phy_tx_pause = pdata->tx_pause;
-		}
-
-		if (pdata->rx_pause != pdata->phy_rx_pause) {
-			hw_if->config_rx_flow_control(pdata);
-			pdata->phy_rx_pause = pdata->rx_pause;
-		}
-
-		/* Speed support */
-		if (phydev->speed != pdata->phy_speed) {
-			new_state = 1;
-
-			switch (phydev->speed) {
-			case SPEED_10000:
-				hw_if->set_xgmii_speed(pdata);
-				break;
-
-			case SPEED_2500:
-				hw_if->set_gmii_2500_speed(pdata);
-				break;
-
-			case SPEED_1000:
-				hw_if->set_gmii_speed(pdata);
-				break;
-			}
-			pdata->phy_speed = phydev->speed;
-		}
-
-		if (phydev->link != pdata->phy_link) {
-			new_state = 1;
-			pdata->phy_link = 1;
-		}
-	} else if (pdata->phy_link) {
-		new_state = 1;
-		pdata->phy_link = 0;
-		pdata->phy_speed = SPEED_UNKNOWN;
-	}
-
-	if (new_state)
-		phy_print_status(phydev);
-
-	DBGPR_MDIO("<--xgbe_adjust_link\n");
-}
-
 void xgbe_dump_phy_registers(struct xgbe_prv_data *pdata)
 {
 	struct device *dev = pdata->dev;
@@ -278,7 +206,6 @@ void xgbe_dump_phy_registers(struct xgbe_prv_data *pdata)
 
 int xgbe_mdio_register(struct xgbe_prv_data *pdata)
 {
-	struct net_device *netdev = pdata->netdev;
 	struct device_node *phy_node;
 	struct mii_bus *mii;
 	struct phy_device *phydev;
@@ -293,7 +220,6 @@ int xgbe_mdio_register(struct xgbe_prv_data *pdata)
 		return -EINVAL;
 	}
 
-	/* Register with the MDIO bus */
 	mii = mdiobus_alloc();
 	if (mii == NULL) {
 		dev_err(pdata->dev, "mdiobus_alloc failed\n");
@@ -348,26 +274,6 @@ int xgbe_mdio_register(struct xgbe_prv_data *pdata)
 	pdata->mii = mii;
 	pdata->mdio_mmd = MDIO_MMD_PCS;
 
-	pdata->phy_link = -1;
-	pdata->phy_speed = SPEED_UNKNOWN;
-	pdata->phy_tx_pause = pdata->tx_pause;
-	pdata->phy_rx_pause = pdata->rx_pause;
-
-	ret = phy_connect_direct(netdev, phydev, &xgbe_adjust_link,
-				 pdata->phy_mode);
-	if (ret) {
-		netdev_err(netdev, "phy_connect_direct failed\n");
-		goto err_phy_device;
-	}
-
-	if (!phydev->drv || (phydev->drv->phy_id == 0)) {
-		netdev_err(netdev, "phy_id not valid\n");
-		ret = -ENODEV;
-		goto err_phy_connect;
-	}
-	DBGPR("  phy_connect_direct succeeded for PHY %s, link=%d\n",
-	      dev_name(&phydev->dev), phydev->link);
-
 	phydev->autoneg = pdata->default_autoneg;
 	if (phydev->autoneg == AUTONEG_DISABLE) {
 		phydev->speed = pdata->default_speed;
@@ -386,9 +292,6 @@ int xgbe_mdio_register(struct xgbe_prv_data *pdata)
 
 	return 0;
 
-err_phy_connect:
-	phy_disconnect(phydev);
-
 err_phy_device:
 	phy_device_free(phydev);
 
@@ -408,7 +311,6 @@ void xgbe_mdio_unregister(struct xgbe_prv_data *pdata)
 {
 	DBGPR("-->xgbe_mdio_unregister\n");
 
-	phy_disconnect(pdata->phydev);
 	pdata->phydev = NULL;
 
 	module_put(pdata->phy_module);
