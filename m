From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 2/9] net: bcmgenet: prevent duplicate calls of bcmgenet_dma_teardown
Date: Wed, 25 Oct 2017 15:04:12 -0700
Message-ID: <20171025220419.24951-3-opendmb@gmail.com>
References: <20171025220419.24951-1-opendmb@gmail.com>
Cc: Doug Berger <opendmb@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025220419.24951-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When bcmgenet_dma_teardown is called from bcmgenet_fini_dma it ends
up getting called twice from the bcmgenet_close and bcmgenet_suspend
functions (once directly and once inside the bcmgenet_fini_dma call).

This commit removes the call from bcmgenet_fini_dma and ensures that
bcmgenet_dma_teardown is called before bcmgenet_fini_dma in all paths
of execution.

Fixes: 4a0c081eff43 ("net: bcmgenet: call bcmgenet_dma_teardown in bcmgenet_fini_dma")
Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f6e8e01be1c8..78368466eb70 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2505,9 +2505,6 @@ static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 	bcmgenet_fini_rx_napi(priv);
 	bcmgenet_fini_tx_napi(priv);
 
-	/* disable DMA */
-	bcmgenet_dma_teardown(priv);
-
 	for (i = 0; i < priv->num_tx_bds; i++) {
 		cb = priv->tx_cbs + i;
 		skb = bcmgenet_free_tx_cb(&priv->pdev->dev, cb);
@@ -2930,6 +2927,7 @@ static int bcmgenet_open(struct net_device *dev)
 err_irq0:
 	free_irq(priv->irq0, priv);
 err_fini_dma:
+	bcmgenet_dma_teardown(priv);
 	bcmgenet_fini_dma(priv);
 err_clk_disable:
 	if (priv->internal_phy)
-- 
2.14.1
