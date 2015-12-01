From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH net-next] ravb: ptp: Add CONFIG mode support
Date: Wed,  2 Dec 2015 02:04:39 +0900
Message-ID: <1448989479-11594-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

This patch makes PTP support active in CONFIG mode on R-Car Gen3.

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's next networking
tree.

 drivers/net/ethernet/renesas/ravb.h      |  1 +
 drivers/net/ethernet/renesas/ravb_main.c | 33 +++++++++++++++++++++++++++-----
 2 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
index f9dee74..9fbe92a 100644
--- a/drivers/net/ethernet/renesas/ravb.h
+++ b/drivers/net/ethernet/renesas/ravb.h
@@ -206,6 +206,7 @@ enum CCC_BIT {
 	CCC_OPC_RESET	= 0x00000000,
 	CCC_OPC_CONFIG	= 0x00000001,
 	CCC_OPC_OPERATION = 0x00000002,
+	CCC_GAC		= 0x00000080,
 	CCC_DTSR	= 0x00000100,
 	CCC_CSEL	= 0x00030000,
 	CCC_CSEL_HPB	= 0x00010000,
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 990dc55..293046d 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1231,7 +1231,8 @@ static int ravb_open(struct net_device *ndev)
 	ravb_emac_init(ndev);
 
 	/* Initialise PTP Clock driver */
-	ravb_ptp_init(ndev, priv->pdev);
+	if (priv->chip_id == RCAR_GEN2)
+		ravb_ptp_init(ndev, priv->pdev);
 
 	netif_tx_start_all_queues(ndev);
 
@@ -1244,7 +1245,8 @@ static int ravb_open(struct net_device *ndev)
 
 out_ptp_stop:
 	/* Stop PTP Clock driver */
-	ravb_ptp_stop(ndev);
+	if (priv->chip_id == RCAR_GEN2)
+		ravb_ptp_stop(ndev);
 out_free_irq:
 	free_irq(ndev->irq, ndev);
 	free_irq(priv->emac_irq, ndev);
@@ -1476,7 +1478,8 @@ static int ravb_close(struct net_device *ndev)
 	ravb_write(ndev, 0, TIC);
 
 	/* Stop PTP Clock driver */
-	ravb_ptp_stop(ndev);
+	if (priv->chip_id == RCAR_GEN2)
+		ravb_ptp_stop(ndev);
 
 	/* Set the config mode to stop the AVB-DMAC's processes */
 	if (ravb_stop_dma(ndev) < 0)
@@ -1781,8 +1784,16 @@ static int ravb_probe(struct platform_device *pdev)
 	ndev->ethtool_ops = &ravb_ethtool_ops;
 
 	/* Set AVB config mode */
-	ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_OPC) | CCC_OPC_CONFIG,
-		   CCC);
+	if (chip_id == RCAR_GEN2) {
+		ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_OPC) |
+			   CCC_OPC_CONFIG, CCC);
+		/* Set CSEL value */
+		ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_CSEL) |
+			   CCC_CSEL_HPB, CCC);
+	} else {
+		ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_OPC) |
+			   CCC_OPC_CONFIG | CCC_GAC | CCC_CSEL_HPB, CCC);
+	}
 
 	/* Set CSEL value */
 	ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_CSEL) | CCC_CSEL_HPB,
@@ -1814,6 +1825,10 @@ static int ravb_probe(struct platform_device *pdev)
 	/* Initialise HW timestamp list */
 	INIT_LIST_HEAD(&priv->ts_skb_list);
 
+	/* Initialise PTP Clock driver */
+	if (chip_id != RCAR_GEN2)
+		ravb_ptp_init(ndev, pdev);
+
 	/* Debug message level */
 	priv->msg_enable = RAVB_DEF_MSG_ENABLE;
 
@@ -1855,6 +1870,10 @@ out_napi_del:
 out_dma_free:
 	dma_free_coherent(ndev->dev.parent, priv->desc_bat_size, priv->desc_bat,
 			  priv->desc_bat_dma);
+
+	/* Stop PTP Clock driver */
+	if (chip_id != RCAR_GEN2)
+		ravb_ptp_stop(ndev);
 out_release:
 	if (ndev)
 		free_netdev(ndev);
@@ -1869,6 +1888,10 @@ static int ravb_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct ravb_private *priv = netdev_priv(ndev);
 
+	/* Stop PTP Clock driver */
+	if (priv->chip_id != RCAR_GEN2)
+		ravb_ptp_stop(ndev);
+
 	dma_free_coherent(ndev->dev.parent, priv->desc_bat_size, priv->desc_bat,
 			  priv->desc_bat_dma);
 	/* Set reset mode */
-- 
1.9.1

