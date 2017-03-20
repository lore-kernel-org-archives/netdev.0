From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH net-next] stmmac: call stmmac_init_phy from stmmac_dvr_probe
Date: Mon, 20 Mar 2017 18:29:15 +0100
Message-ID: <20170320172915.8313-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Niklas Cassel <niklass@axis.com>
To: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

It is usually possible to do
ethtool -s autoneg on
so that you trigger an autoneg before calling
ip link set dev eth0 up

However, stmmac returns -EBUSY if !netif_running.
The only reason for this appears to be that stmmac_init_phy
is called from stmmac_open instead of from stmmac_dvr_probe.

Move stmmac_init_phy to stmmac_dvr_probe so that ethool
works as soon as register_netdev has been called.
stmmac_check_ether_addr was also moved to probe,
so that the ordering doesn't change.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   | 13 --------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 35 +++++++++-------------
 2 files changed, 14 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 16808e48ca1c..027c280f33d0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -359,11 +359,6 @@ static int stmmac_ethtool_get_link_ksettings(struct net_device *dev,
 		       __func__, dev->name);
 		return -ENODEV;
 	}
-	if (!netif_running(dev)) {
-		pr_err("%s: interface is disabled: we cannot track "
-		"link speed / duplex setting\n", dev->name);
-		return -EBUSY;
-	}
 	rc = phy_ethtool_ksettings_get(phy, cmd);
 	return rc;
 }
@@ -420,13 +415,6 @@ static void stmmac_ethtool_setmsglevel(struct net_device *dev, u32 level)
 
 }
 
-static int stmmac_check_if_running(struct net_device *dev)
-{
-	if (!netif_running(dev))
-		return -EBUSY;
-	return 0;
-}
-
 static int stmmac_ethtool_get_regs_len(struct net_device *dev)
 {
 	return REG_SPACE_SIZE;
@@ -847,7 +835,6 @@ static int stmmac_set_tunable(struct net_device *dev,
 }
 
 static const struct ethtool_ops stmmac_ethtool_ops = {
-	.begin = stmmac_check_if_running,
 	.get_drvinfo = stmmac_ethtool_getdrvinfo,
 	.get_msglevel = stmmac_ethtool_getmsglevel,
 	.set_msglevel = stmmac_ethtool_setmsglevel,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d3a21519e4c0..7335ae60dc70 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2080,20 +2080,6 @@ static int stmmac_open(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	int ret;
 
-	stmmac_check_ether_addr(priv);
-
-	if (priv->hw->pcs != STMMAC_PCS_RGMII &&
-	    priv->hw->pcs != STMMAC_PCS_TBI &&
-	    priv->hw->pcs != STMMAC_PCS_RTBI) {
-		ret = stmmac_init_phy(dev);
-		if (ret) {
-			netdev_err(priv->dev,
-				   "%s: Cannot attach to PHY (error: %d)\n",
-				   __func__, ret);
-			return ret;
-		}
-	}
-
 	/* Extra statistics */
 	memset(&priv->xstats, 0, sizeof(struct stmmac_extra_stats));
 	priv->xstats.threshold = tc;
@@ -2179,9 +2165,6 @@ static int stmmac_open(struct net_device *dev)
 init_error:
 	free_dma_desc_resources(priv);
 dma_desc_error:
-	if (dev->phydev)
-		phy_disconnect(dev->phydev);
-
 	return ret;
 }
 
@@ -2198,11 +2181,8 @@ static int stmmac_release(struct net_device *dev)
 	if (priv->eee_enabled)
 		del_timer_sync(&priv->eee_ctrl_timer);
 
-	/* Stop and disconnect the PHY */
-	if (dev->phydev) {
+	if (dev->phydev)
 		phy_stop(dev->phydev);
-		phy_disconnect(dev->phydev);
-	}
 
 	netif_stop_queue(dev);
 
@@ -3656,6 +3636,7 @@ int stmmac_dvr_probe(struct device *device,
 		priv->clk_csr = priv->plat->clk_csr;
 
 	stmmac_check_pcs_mode(priv);
+	stmmac_check_ether_addr(priv);
 
 	if (priv->hw->pcs != STMMAC_PCS_RGMII  &&
 	    priv->hw->pcs != STMMAC_PCS_TBI &&
@@ -3668,6 +3649,13 @@ int stmmac_dvr_probe(struct device *device,
 				__func__, priv->plat->bus_id);
 			goto error_mdio_register;
 		}
+		ret = stmmac_init_phy(ndev);
+		if (ret) {
+			dev_err(priv->device,
+				"%s: Cannot attach to PHY (error: %d)\n",
+				__func__, ret);
+			goto error_init_phy;
+		}
 	}
 
 	ret = register_netdev(ndev);
@@ -3683,6 +3671,11 @@ int stmmac_dvr_probe(struct device *device,
 	if (priv->hw->pcs != STMMAC_PCS_RGMII &&
 	    priv->hw->pcs != STMMAC_PCS_TBI &&
 	    priv->hw->pcs != STMMAC_PCS_RTBI)
+		phy_disconnect(ndev->phydev);
+error_init_phy:
+	if (priv->hw->pcs != STMMAC_PCS_RGMII &&
+	    priv->hw->pcs != STMMAC_PCS_TBI &&
+	    priv->hw->pcs != STMMAC_PCS_RTBI)
 		stmmac_mdio_unregister(ndev);
 error_mdio_register:
 	netif_napi_del(&priv->napi);
-- 
2.11.0
