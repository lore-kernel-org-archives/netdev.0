From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] moxa: fix the error handling in moxart_mac_probe()
Date: Tue, 8 Oct 2013 11:19:19 +0800
Message-ID: <CAPgLHd95agB+cseQmD4wg50wX_ddyZ0=0VxJ8vAR80ZbcFsMTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: grant.likely@linaro.org, rob.herring@calxeda.com,
	davem@davemloft.net, jg1.han@samsung.com, b.zolnierkie@samsung.com,
	kyungmin.park@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:42077 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045Ab3JHDTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 23:19:21 -0400
Received: by mail-bk0-f53.google.com with SMTP id d7so3058932bkh.12
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 20:19:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

This patch fix the error handling in moxart_mac_probe():
 - return -ENOMEM in some memory alloc fail cases
 - add missing free_netdev() in the error handling case

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index bd1a2d2..ea54d95 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -448,7 +448,8 @@ static int moxart_mac_probe(struct platform_device *pdev)
 	irq = irq_of_parse_and_map(node, 0);
 	if (irq <= 0) {
 		netdev_err(ndev, "irq_of_parse_and_map failed\n");
-		return -EINVAL;
+		ret = -EINVAL;
+		goto irq_map_fail;
 	}
 
 	priv = netdev_priv(ndev);
@@ -472,24 +473,32 @@ static int moxart_mac_probe(struct platform_device *pdev)
 	priv->tx_desc_base = dma_alloc_coherent(NULL, TX_REG_DESC_SIZE *
 						TX_DESC_NUM, &priv->tx_base,
 						GFP_DMA | GFP_KERNEL);
-	if (priv->tx_desc_base == NULL)
+	if (priv->tx_desc_base == NULL) {
+		ret = -ENOMEM;
 		goto init_fail;
+	}
 
 	priv->rx_desc_base = dma_alloc_coherent(NULL, RX_REG_DESC_SIZE *
 						RX_DESC_NUM, &priv->rx_base,
 						GFP_DMA | GFP_KERNEL);
-	if (priv->rx_desc_base == NULL)
+	if (priv->rx_desc_base == NULL) {
+		ret = -ENOMEM;
 		goto init_fail;
+	}
 
 	priv->tx_buf_base = kmalloc(priv->tx_buf_size * TX_DESC_NUM,
 				    GFP_ATOMIC);
-	if (!priv->tx_buf_base)
+	if (!priv->tx_buf_base) {
+		ret = -ENOMEM;
 		goto init_fail;
+	}
 
 	priv->rx_buf_base = kmalloc(priv->rx_buf_size * RX_DESC_NUM,
 				    GFP_ATOMIC);
-	if (!priv->rx_buf_base)
+	if (!priv->rx_buf_base) {
+		ret = -ENOMEM;
 		goto init_fail;
+	}
 
 	platform_set_drvdata(pdev, ndev);
 
@@ -522,7 +531,8 @@ static int moxart_mac_probe(struct platform_device *pdev)
 init_fail:
 	netdev_err(ndev, "init failed\n");
 	moxart_mac_free_memory(ndev);
-
+irq_map_fail:
+	free_netdev(ndev);
 	return ret;
 }
 
