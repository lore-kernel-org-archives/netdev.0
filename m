From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH net-next 1/2] net: stmmac: fix netdev release
Date: Fri, 24 Mar 2017 17:16:44 +0000
Message-ID: <c4e0980b1d5eb5ba48e1cdebe565d3d6bd3a4dc0.1490375512.git.jpinto@synopsys.com>
References: <cover.1490375512.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        clabbe.montjoie@gmail.com, thierry.reding@gmail.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:48762 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965669AbdCXRQy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 13:16:54 -0400
In-Reply-To: <cover.1490375512.git.jpinto@synopsys.com>
In-Reply-To: <cover.1490375512.git.jpinto@synopsys.com>
References: <cover.1490375512.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the kernel crash problem that happens when the driver
exits. The dma resouces must be freed after netdev resouces get freed and
in driver removed, multiple napi's should be deleted before removing
netdev resouces or it will hang.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4b418d2..3827952 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2659,9 +2659,6 @@ static int stmmac_release(struct net_device *dev)
 	/* Stop TX/RX DMA and clear the descriptors */
 	stmmac_stop_all_dma(priv);
 
-	/* Release and free the Rx/Tx resources */
-	free_dma_desc_resources(priv);
-
 	/* Disable the MAC Rx/Tx */
 	stmmac_set_mac(priv->ioaddr, false);
 
@@ -4080,7 +4077,7 @@ int stmmac_dvr_probe(struct device *device,
 	/* Init MAC and get the capabilities */
 	ret = stmmac_hw_init(priv);
 	if (ret)
-		goto error_hw_init;
+		return ret;
 
 	/* Configure real RX and TX queues */
 	ndev->real_num_rx_queues = priv->plat->rx_queues_to_use;
@@ -4207,9 +4204,8 @@ int stmmac_dvr_probe(struct device *device,
 		netif_napi_del(&rx_q->napi);
 	}
 init_dma_error:
-	free_dma_desc_resources(priv);
-error_hw_init:
 	free_netdev(ndev);
+	free_dma_desc_resources(priv);
 
 	return ret;
 }
@@ -4225,6 +4221,7 @@ int stmmac_dvr_remove(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
+	u32 queue = 0;
 
 	netdev_info(priv->dev, "%s: removing driver", __func__);
 
@@ -4241,7 +4238,15 @@ int stmmac_dvr_remove(struct device *dev)
 	    priv->hw->pcs != STMMAC_PCS_TBI &&
 	    priv->hw->pcs != STMMAC_PCS_RTBI)
 		stmmac_mdio_unregister(ndev);
+
+	for (queue = 0; queue < priv->plat->rx_queues_to_use; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		netif_napi_del(&rx_q->napi);
+	}
+
 	free_netdev(ndev);
+	free_dma_desc_resources(priv);
 
 	return 0;
 }
-- 
2.9.3
