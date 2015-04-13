From: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Subject: [PATCH 1/1] stmmac: bugfix oops on rmmod after ifconfig
Date: Mon, 13 Apr 2015 12:15:13 +0100
Message-ID: <1428923713-2419-2-git-send-email-pure.logic@nexus-software.ie>
References: <1428923713-2419-1-git-send-email-pure.logic@nexus-software.ie>
Cc: andriy.shevchenko@linux.intel.com, hock.leong.kweh@intel.com,
	boon.leong.ong@intel.com, dan.odonovan@emutex.com,
	linux-kernel@vger.kernel.org,
	Bryan O'Donoghue <pure.logic@nexus-software.ie>
To: peppe.cavallaro@st.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428923713-2419-1-git-send-email-pure.logic@nexus-software.ie>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An oops exists in the flow of stmmac_release().
phy_ethtool_get_wol() depends on phydev->drv which will be null in
stmmac_dvr_remove after stmmac_mdio_unreg() completes.

Steps to reproduce on Quark X1000:

1. ifconfig eth0 192.168.0.1
2. rmmod stmmac_pci

This patch re-orders the calling of the unreg() functions so that
stmmac_unreg_mdio() happens later in the release() routine thus avoiding the
null pointer dereference.

Signed-off-by: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Reported-by: Dan O'Donovan <dan.odonovan@emutex.com>

---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a0ea84f..3ab3e4a8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2958,14 +2958,14 @@ int stmmac_dvr_remove(struct net_device *ndev)
 	priv->hw->dma->stop_tx(priv->ioaddr);
 
 	stmmac_set_mac(priv->ioaddr, false);
-	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
-	    priv->pcs != STMMAC_PCS_RTBI)
-		stmmac_mdio_unregister(ndev);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
 	if (priv->stmmac_rst)
 		reset_control_assert(priv->stmmac_rst);
 	clk_disable_unprepare(priv->stmmac_clk);
+	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
+	    priv->pcs != STMMAC_PCS_RTBI)
+		stmmac_mdio_unregister(ndev);
 	free_netdev(ndev);
 
 	return 0;
-- 
1.9.1
