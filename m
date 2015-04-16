From: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Subject: [PATCH v3 1/1] stmmac: fix oops on rmmod after assigning ip addr
Date: Thu, 16 Apr 2015 17:56:03 +0100
Message-ID: <1429203363-10919-2-git-send-email-pure.logic@nexus-software.ie>
References: <1429203363-10919-1-git-send-email-pure.logic@nexus-software.ie>
Cc: andriy.shevchenko@linux.intel.com, hock.leong.kweh@intel.com,
	boon.leong.ong@intel.com, dan.odonovan@emutex.com,
	linux-kernel@vger.kernel.org,
	Bryan O'Donoghue <pure.logic@nexus-software.ie>
To: peppe.cavallaro@st.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429203363-10919-1-git-send-email-pure.logic@nexus-software.ie>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An oops exists in the flow of stmmac_release().
phy_ethtool_get_wol() depends on phydev->drv.
phydev->drv will be null after stmmac_mdio_unreg() completes.

Steps to reproduce on Quark X1000:

1. ifconfig eth0 192.168.0.1
2. rmmod stmmac_pci

To fix this stmmac_mdio_unreg() should be run after unregister_netdev().

Signed-off-by: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Reported-by: Dan O'Donovan <dan.odonovan@emutex.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 06103ca..6065173 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2970,15 +2970,15 @@ int stmmac_dvr_remove(struct net_device *ndev)
 	priv->hw->dma->stop_tx(priv->ioaddr);
 
 	stmmac_set_mac(priv->ioaddr, false);
-	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
-	    priv->pcs != STMMAC_PCS_RTBI)
-		stmmac_mdio_unregister(ndev);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
 	if (priv->stmmac_rst)
 		reset_control_assert(priv->stmmac_rst);
 	clk_disable_unprepare(priv->pclk);
 	clk_disable_unprepare(priv->stmmac_clk);
+	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
+	    priv->pcs != STMMAC_PCS_RTBI)
+		stmmac_mdio_unregister(ndev);
 	free_netdev(ndev);
 
 	return 0;
-- 
1.9.1
