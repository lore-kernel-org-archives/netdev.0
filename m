From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: stmmac: Fix error path after register_netdev move
Date: Wed, 28 Dec 2016 15:44:41 -0800
Message-ID: <20161228234441.5026-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, pavel@ucw.cz,
        Joao.Pinto@synopsys.com, seraphin.bonnaffe@st.com,
        alexandre.torgue@gmail.com, manabian@gmail.com,
        niklas.cassel@axis.com, johan@kernel.org, boon.leong.ong@intel.com,
        weifeng.voon@intel.com, lars.persson@axis.com,
        linux-kernel@vger.kernel.org,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 5701659004d6 ("net: stmmac: Fix race between stmmac_drv_probe and
stmmac_open") re-ordered how the MDIO bus registration and the network
device are registered, but missed to unwind the MDIO bus registration in
case we fail to register the network device.

Fixes: 5701659004d6 ("net: stmmac: Fix race between stmmac_drv_probe and stmmac_open")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 5910ea51f8f6..39eb7a65bb9f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3366,12 +3366,19 @@ int stmmac_dvr_probe(struct device *device,
 	}
 
 	ret = register_netdev(ndev);
-	if (ret)
+	if (ret) {
 		netdev_err(priv->dev, "%s: ERROR %i registering the device\n",
 			   __func__, ret);
+		goto error_netdev_register;
+	}
 
 	return ret;
 
+error_netdev_register:
+	if (priv->hw->pcs != STMMAC_PCS_RGMII &&
+	    priv->hw->pcs != STMMAC_PCS_TBI &&
+	    priv->hw->pcs != STMMAC_PCS_RTBI)
+		stmmac_mdio_unregister(ndev);
 error_mdio_register:
 	netif_napi_del(&priv->napi);
 error_hw_init:
-- 
2.9.3
