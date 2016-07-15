From: Zhao Qiang <qiang.zhao@nxp.com>
Subject: [PATCH 2/2] wan/fsl_ucc_hdlc: rewrite error handling to make it clearer
Date: Fri, 15 Jul 2016 10:38:25 +0800
Message-ID: <1468550305-38571-2-git-send-email-qiang.zhao@nxp.com>
References: <1468550305-38571-1-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xiaobo.xie@nxp.com>, Zhao Qiang <qiang.zhao@nxp.com>
To: <davem@davemloft.net>, <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468550305-38571-1-git-send-email-qiang.zhao@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It was used err_xxx for labeled statement, it is
not easy to understand, now use free_xxx for labeled
statement.

Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 55 +++++++++++++++++++++---------------------
 1 file changed, 27 insertions(+), 28 deletions(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index e2b225d..9309c72 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -143,7 +143,7 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 	if (!priv->rx_bd_base) {
 		dev_err(priv->dev, "Cannot allocate MURAM memory for RxBDs\n");
 		ret = -ENOMEM;
-		goto rxbd_alloc_error;
+		goto free_uccf;
 	}
 
 	/* Alloc Tx BD */
@@ -154,7 +154,7 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 	if (!priv->tx_bd_base) {
 		dev_err(priv->dev, "Cannot allocate MURAM memory for TxBDs\n");
 		ret = -ENOMEM;
-		goto txbd_alloc_error;
+		goto free_rx_bd;
 	}
 
 	/* Alloc parameter ram for ucc hdlc */
@@ -164,18 +164,18 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 	if (priv->ucc_pram_offset < 0) {
 		dev_err(priv->dev, "Can not allocate MURAM for hdlc prameter.\n");
 		ret = -ENOMEM;
-		goto pram_alloc_error;
+		goto free_tx_bd;
 	}
 
 	priv->rx_skbuff = kzalloc(priv->rx_ring_size * sizeof(*priv->rx_skbuff),
 				  GFP_KERNEL);
 	if (!priv->rx_skbuff)
-		goto rx_skb_alloc_error;
+		goto free_ucc_pram;
 
 	priv->tx_skbuff = kzalloc(priv->tx_ring_size * sizeof(*priv->tx_skbuff),
 				  GFP_KERNEL);
 	if (!priv->tx_skbuff)
-		goto tx_skb_alloc_error;
+		goto free_rx_skbuff;
 
 	priv->skb_curtx = 0;
 	priv->skb_dirtytx = 0;
@@ -200,14 +200,14 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 	if (riptr < 0) {
 		dev_err(priv->dev, "Cannot allocate MURAM mem for Receive internal temp data pointer\n");
 		ret = -ENOMEM;
-		goto riptr_alloc_error;
+		goto free_tx_skbuff;
 	}
 
 	tiptr = qe_muram_alloc(32, 32);
 	if (tiptr < 0) {
 		dev_err(priv->dev, "Cannot allocate MURAM mem for Transmit internal temp data pointer\n");
 		ret = -ENOMEM;
-		goto tiptr_alloc_error;
+		goto free_riptr;
 	}
 
 	/* Set RIPTR, TIPTR */
@@ -247,7 +247,7 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 	if (!bd_buffer) {
 		dev_err(priv->dev, "Could not allocate buffer descriptors\n");
 		ret = -ENOMEM;
-		goto bd_alloc_error;
+		goto free_tiptr;
 	}
 
 	memset(bd_buffer, 0, (RX_BD_RING_LEN + TX_BD_RING_LEN)
@@ -283,25 +283,25 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 
 	return 0;
 
-bd_alloc_error:
+free_tiptr:
 	qe_muram_free(tiptr);
-tiptr_alloc_error:
+free_riptr:
 	qe_muram_free(riptr);
-riptr_alloc_error:
+free_tx_skbuff:
 	kfree(priv->tx_skbuff);
-tx_skb_alloc_error:
+free_rx_skbuff:
 	kfree(priv->rx_skbuff);
-rx_skb_alloc_error:
+free_ucc_pram:
 	qe_muram_free(priv->ucc_pram_offset);
-pram_alloc_error:
+free_tx_bd:
 	dma_free_coherent(priv->dev,
 			  TX_BD_RING_LEN * sizeof(struct qe_bd),
 			  priv->tx_bd_base, priv->dma_tx_bd);
-txbd_alloc_error:
+free_rx_bd:
 	dma_free_coherent(priv->dev,
 			  RX_BD_RING_LEN * sizeof(struct qe_bd),
 			  priv->rx_bd_base, priv->dma_rx_bd);
-rxbd_alloc_error:
+free_uccf:
 	ucc_fast_free(priv->uccf);
 
 	return ret;
@@ -1068,9 +1068,7 @@ static int ucc_hdlc_probe(struct platform_device *pdev)
 
 	uhdlc_priv = kzalloc(sizeof(*uhdlc_priv), GFP_KERNEL);
 	if (!uhdlc_priv) {
-		ret = -ENOMEM;
-		dev_err(&pdev->dev, "No mem to alloc hdlc private data\n");
-		goto err_alloc_priv;
+		return -ENOMEM;
 	}
 
 	dev_set_drvdata(&pdev->dev, uhdlc_priv);
@@ -1088,25 +1086,25 @@ static int ucc_hdlc_probe(struct platform_device *pdev)
 		if (!utdm) {
 			ret = -ENOMEM;
 			dev_err(&pdev->dev, "No mem to alloc ucc tdm data\n");
-			goto err_alloc_utdm;
+			goto free_uhdlc_priv;
 		}
 		uhdlc_priv->utdm = utdm;
 		ret = ucc_of_parse_tdm(np, utdm, ut_info);
 		if (ret)
-			goto err_miss_tsa_property;
+			goto free_utdm;
 	}
 
 	ret = uhdlc_init(uhdlc_priv);
 	if (ret) {
 		dev_err(&pdev->dev, "Failed to init uhdlc\n");
-		goto err_hdlc_init;
+		goto free_utdm;
 	}
 
 	dev = alloc_hdlcdev(uhdlc_priv);
 	if (!dev) {
 		ret = -ENOMEM;
 		pr_err("ucc_hdlc: unable to allocate memory\n");
-		goto err_hdlc_init;
+		goto undo_uhdlc_init;
 	}
 
 	uhdlc_priv->ndev = dev;
@@ -1120,18 +1118,19 @@ static int ucc_hdlc_probe(struct platform_device *pdev)
 		ret = -ENOBUFS;
 		pr_err("ucc_hdlc: unable to register hdlc device\n");
 		free_netdev(dev);
-		goto err_hdlc_init;
+		goto free_dev;
 	}
 
 	return 0;
 
-err_hdlc_init:
-err_miss_tsa_property:
+free_dev:
+	free_netdev(dev);
+undo_uhdlc_init:
+free_utdm:
 	if (uhdlc_priv->tsa)
 		kfree(utdm);
-err_alloc_utdm:
+free_uhdlc_priv:
 	kfree(uhdlc_priv);
-err_alloc_priv:
 	return ret;
 }
 
-- 
2.1.0.27.g96db324
