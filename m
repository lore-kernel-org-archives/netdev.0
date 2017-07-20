From: Keerthy <j-keerthy@ti.com>
Subject: [PATCH] net: ethernet: ti: cpsw: Push the request_irq function to the end of probe
Date: Thu, 20 Jul 2017 16:59:52 +0530
Message-ID: <1500550192-6550-1-git-send-email-j-keerthy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <johan@kernel.org>,
        <ivan.khoronzhuk@linaro.org>, <t-kristo@ti.com>,
        <grygorii.strashko@ti.com>, <nsekhar@ti.com>, <j-keerthy@ti.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Push the request_irq function to the end of probe so as
to ensure all the required fields are populated in the event
of an ISR getting executed right after requesting the irq.

Currently while loading the crash kernel a crash was seen as
soon as devm_request_threaded_irq was called. This was due to
n->poll being NULL which is called as part of net_rx_action
function.

Suggested-by: Sekhar Nori <nsekhar@ti.com>
Signed-off-by: Keerthy <j-keerthy@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 49 +++++++++++++++++++++---------------------
 1 file changed, 25 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 37fc165..94892d5 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -3085,6 +3085,31 @@ static int cpsw_probe(struct platform_device *pdev)
 			cpsw->quirk_irq = true;
 	}
 
+	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+
+	ndev->netdev_ops = &cpsw_netdev_ops;
+	ndev->ethtool_ops = &cpsw_ethtool_ops;
+	netif_napi_add(ndev, &cpsw->napi_rx, cpsw_rx_poll, CPSW_POLL_WEIGHT);
+	netif_tx_napi_add(ndev, &cpsw->napi_tx, cpsw_tx_poll, CPSW_POLL_WEIGHT);
+	cpsw_split_res(ndev);
+
+	/* register the network device */
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+	ret = register_netdev(ndev);
+	if (ret) {
+		dev_err(priv->dev, "error registering net device\n");
+		ret = -ENODEV;
+		goto clean_ale_ret;
+	}
+
+	if (cpsw->data.dual_emac) {
+		ret = cpsw_probe_dual_emac(priv);
+		if (ret) {
+			cpsw_err(priv, probe, "error probe slave 2 emac interface\n");
+			goto clean_unregister_netdev_ret;
+		}
+	}
+
 	/* Grab RX and TX IRQs. Note that we also have RX_THRESHOLD and
 	 * MISC IRQs which are always kept disabled with this driver so
 	 * we will not request them.
@@ -3123,33 +3148,9 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
-	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
-
-	ndev->netdev_ops = &cpsw_netdev_ops;
-	ndev->ethtool_ops = &cpsw_ethtool_ops;
-	netif_napi_add(ndev, &cpsw->napi_rx, cpsw_rx_poll, CPSW_POLL_WEIGHT);
-	netif_tx_napi_add(ndev, &cpsw->napi_tx, cpsw_tx_poll, CPSW_POLL_WEIGHT);
-	cpsw_split_res(ndev);
-
-	/* register the network device */
-	SET_NETDEV_DEV(ndev, &pdev->dev);
-	ret = register_netdev(ndev);
-	if (ret) {
-		dev_err(priv->dev, "error registering net device\n");
-		ret = -ENODEV;
-		goto clean_ale_ret;
-	}
-
 	cpsw_notice(priv, probe,
 		    "initialized device (regs %pa, irq %d, pool size %d)\n",
 		    &ss_res->start, ndev->irq, dma_params.descs_pool_size);
-	if (cpsw->data.dual_emac) {
-		ret = cpsw_probe_dual_emac(priv);
-		if (ret) {
-			cpsw_err(priv, probe, "error probe slave 2 emac interface\n");
-			goto clean_unregister_netdev_ret;
-		}
-	}
 
 	pm_runtime_put(&pdev->dev);
 
-- 
1.9.1
