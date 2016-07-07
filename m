From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v5 03/11] drivers: net: xgene: Fix module unload crash - change sw sequence
Date: Thu,  7 Jul 2016 16:02:51 -0700
Message-ID: <1467932579-14320-4-git-send-email-isubramanian@apm.com>
References: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	matthias.bgg@gmail.com, andrew@lunn.ch, linux@armlinux.org.uk,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35750 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbcGGXC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 19:02:58 -0400
Received: by mail-pf0-f172.google.com with SMTP id c2so10045783pfa.2
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 16:02:58 -0700 (PDT)
In-Reply-To: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the driver is configured as kernel module and when it gets
unloaded and reloaded, kernel crash was observed.  This patch
addresses the software cleanup by doing the following,

- Moved register_netdev call after hardware is ready
- Since ndev is not ready, added set_irq_name to set irq name
- Since ndev is not ready, changed mdio_bus->parent to pdev->dev
- Replaced netif_start(stop)_queue by netif_tx_start(stop)_queues
- Removed napi_del call since it's called by free_netdev
- Added dev_close call, within remove
- Added shutdown callback
- Changed to use dmam_ APIs

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
Tested-by: Matthias Brugger <mbrugger@suse.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |   2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 120 ++++++++++++++---------
 2 files changed, 73 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 009fb8e..4f98749 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -901,7 +901,7 @@ int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
 		 ndev->name);
 
 	mdio_bus->priv = pdata;
-	mdio_bus->parent = &ndev->dev;
+	mdio_bus->parent = &pdata->pdev->dev;
 
 	ret = xgene_mdiobus_register(pdata, mdio_bus);
 	if (ret) {
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index f79950a..87e5929 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -608,6 +608,30 @@ static void xgene_enet_timeout(struct net_device *ndev)
 	}
 }
 
+static void xgene_enet_set_irq_name(struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct xgene_enet_desc_ring *ring;
+	int i;
+
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		ring = pdata->rx_ring[i];
+		if (!pdata->cq_cnt) {
+			snprintf(ring->irq_name, IRQ_ID_SIZE, "%s-rx-txc",
+				 ndev->name);
+		} else {
+			snprintf(ring->irq_name, IRQ_ID_SIZE, "%s-rx-%d",
+				 ndev->name, i);
+		}
+	}
+
+	for (i = 0; i < pdata->cq_cnt; i++) {
+		ring = pdata->tx_ring[i]->cp_ring;
+		snprintf(ring->irq_name, IRQ_ID_SIZE, "%s-txc-%d",
+			 ndev->name, i);
+	}
+}
+
 static int xgene_enet_register_irq(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
@@ -615,6 +639,7 @@ static int xgene_enet_register_irq(struct net_device *ndev)
 	struct xgene_enet_desc_ring *ring;
 	int ret = 0, i;
 
+	xgene_enet_set_irq_name(ndev);
 	for (i = 0; i < pdata->rxq_cnt; i++) {
 		ring = pdata->rx_ring[i];
 		irq_set_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
@@ -723,7 +748,7 @@ static int xgene_enet_open(struct net_device *ndev)
 
 	mac_ops->tx_enable(pdata);
 	mac_ops->rx_enable(pdata);
-	netif_start_queue(ndev);
+	netif_tx_start_all_queues(ndev);
 
 	return ret;
 }
@@ -734,7 +759,7 @@ static int xgene_enet_close(struct net_device *ndev)
 	const struct xgene_mac_ops *mac_ops = pdata->mac_ops;
 	int i;
 
-	netif_stop_queue(ndev);
+	netif_tx_stop_all_queues(ndev);
 	mac_ops->tx_disable(pdata);
 	mac_ops->rx_disable(pdata);
 
@@ -759,7 +784,7 @@ static void xgene_enet_delete_ring(struct xgene_enet_desc_ring *ring)
 	dev = ndev_to_dev(ring->ndev);
 
 	pdata->ring_ops->clear(ring);
-	dma_free_coherent(dev, ring->size, ring->desc_addr, ring->dma);
+	dmam_free_coherent(dev, ring->size, ring->desc_addr, ring->dma);
 }
 
 static void xgene_enet_delete_desc_rings(struct xgene_enet_pdata *pdata)
@@ -834,7 +859,7 @@ static void xgene_enet_free_desc_ring(struct xgene_enet_desc_ring *ring)
 
 	if (ring->desc_addr) {
 		pdata->ring_ops->clear(ring);
-		dma_free_coherent(dev, ring->size, ring->desc_addr, ring->dma);
+		dmam_free_coherent(dev, ring->size, ring->desc_addr, ring->dma);
 	}
 	devm_kfree(dev, ring);
 }
@@ -892,9 +917,10 @@ static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
 			struct net_device *ndev, u32 ring_num,
 			enum xgene_enet_ring_cfgsize cfgsize, u32 ring_id)
 {
-	struct xgene_enet_desc_ring *ring;
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct device *dev = ndev_to_dev(ndev);
+	struct xgene_enet_desc_ring *ring;
+	void *irq_mbox_addr;
 	int size;
 
 	size = xgene_enet_get_ring_size(dev, cfgsize);
@@ -911,8 +937,8 @@ static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
 	ring->cfgsize = cfgsize;
 	ring->id = ring_id;
 
-	ring->desc_addr = dma_zalloc_coherent(dev, size, &ring->dma,
-					      GFP_KERNEL);
+	ring->desc_addr = dmam_alloc_coherent(dev, size, &ring->dma,
+					      GFP_KERNEL | __GFP_ZERO);
 	if (!ring->desc_addr) {
 		devm_kfree(dev, ring);
 		return NULL;
@@ -920,14 +946,16 @@ static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
 	ring->size = size;
 
 	if (is_irq_mbox_required(pdata, ring)) {
-		ring->irq_mbox_addr = dma_zalloc_coherent(dev, INTR_MBOX_SIZE,
-				&ring->irq_mbox_dma, GFP_KERNEL);
-		if (!ring->irq_mbox_addr) {
-			dma_free_coherent(dev, size, ring->desc_addr,
-					  ring->dma);
+		irq_mbox_addr = dmam_alloc_coherent(dev, INTR_MBOX_SIZE,
+						    &ring->irq_mbox_dma,
+						    GFP_KERNEL | __GFP_ZERO);
+		if (!irq_mbox_addr) {
+			dmam_free_coherent(dev, size, ring->desc_addr,
+					   ring->dma);
 			devm_kfree(dev, ring);
 			return NULL;
 		}
+		ring->irq_mbox_addr = irq_mbox_addr;
 	}
 
 	ring->cmd_base = xgene_enet_ring_cmd_base(pdata, ring);
@@ -988,6 +1016,7 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 	u8 eth_bufnum = pdata->eth_bufnum;
 	u8 bp_bufnum = pdata->bp_bufnum;
 	u16 ring_num = pdata->ring_num;
+	__le64 *exp_bufs;
 	u16 ring_id;
 	int i, ret, size;
 
@@ -1019,13 +1048,6 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 		rx_ring->nbufpool = NUM_BUFPOOL;
 		rx_ring->buf_pool = buf_pool;
 		rx_ring->irq = pdata->irqs[i];
-		if (!pdata->cq_cnt) {
-			snprintf(rx_ring->irq_name, IRQ_ID_SIZE, "%s-rx-txc",
-				 ndev->name);
-		} else {
-			snprintf(rx_ring->irq_name, IRQ_ID_SIZE, "%s-rx%d",
-				 ndev->name, i);
-		}
 		buf_pool->rx_skb = devm_kcalloc(dev, buf_pool->slots,
 						sizeof(struct sk_buff *),
 						GFP_KERNEL);
@@ -1052,13 +1074,13 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 		}
 
 		size = (tx_ring->slots / 2) * sizeof(__le64) * MAX_EXP_BUFFS;
-		tx_ring->exp_bufs = dma_zalloc_coherent(dev, size,
-							&dma_exp_bufs,
-							GFP_KERNEL);
-		if (!tx_ring->exp_bufs) {
+		exp_bufs = dmam_alloc_coherent(dev, size, &dma_exp_bufs,
+					       GFP_KERNEL | __GFP_ZERO);
+		if (!exp_bufs) {
 			ret = -ENOMEM;
 			goto err;
 		}
+		tx_ring->exp_bufs = exp_bufs;
 
 		pdata->tx_ring[i] = tx_ring;
 
@@ -1078,8 +1100,6 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 
 			cp_ring->irq = pdata->irqs[pdata->rxq_cnt + i];
 			cp_ring->index = i;
-			snprintf(cp_ring->irq_name, IRQ_ID_SIZE, "%s-txc%d",
-				 ndev->name, i);
 		}
 
 		cp_ring->cp_skb = devm_kcalloc(dev, tx_ring->slots,
@@ -1549,22 +1569,6 @@ static void xgene_enet_napi_add(struct xgene_enet_pdata *pdata)
 	}
 }
 
-static void xgene_enet_napi_del(struct xgene_enet_pdata *pdata)
-{
-	struct napi_struct *napi;
-	int i;
-
-	for (i = 0; i < pdata->rxq_cnt; i++) {
-		napi = &pdata->rx_ring[i]->napi;
-		netif_napi_del(napi);
-	}
-
-	for (i = 0; i < pdata->cq_cnt; i++) {
-		napi = &pdata->tx_ring[i]->cp_ring->napi;
-		netif_napi_del(napi);
-	}
-}
-
 static int xgene_enet_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
@@ -1628,12 +1632,6 @@ static int xgene_enet_probe(struct platform_device *pdev)
 		goto err;
 	}
 
-	ret = register_netdev(ndev);
-	if (ret) {
-		netdev_err(ndev, "Failed to register netdev\n");
-		goto err;
-	}
-
 	ret = xgene_enet_init_hw(pdata);
 	if (ret)
 		goto err_netdev;
@@ -1648,7 +1646,14 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	}
 
 	xgene_enet_napi_add(pdata);
+	ret = register_netdev(ndev);
+	if (ret) {
+		netdev_err(ndev, "Failed to register netdev\n");
+		goto err;
+	}
+
 	return 0;
+
 err_netdev:
 	unregister_netdev(ndev);
 err:
@@ -1666,10 +1671,14 @@ static int xgene_enet_remove(struct platform_device *pdev)
 	mac_ops = pdata->mac_ops;
 	ndev = pdata->ndev;
 
+	rtnl_lock();
+	if (netif_running(ndev))
+		dev_close(ndev);
+	rtnl_unlock();
+
 	mac_ops->rx_disable(pdata);
 	mac_ops->tx_disable(pdata);
 
-	xgene_enet_napi_del(pdata);
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
 		xgene_enet_mdio_remove(pdata);
 	unregister_netdev(ndev);
@@ -1680,6 +1689,20 @@ static int xgene_enet_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static void xgene_enet_shutdown(struct platform_device *pdev)
+{
+	struct xgene_enet_pdata *pdata;
+
+	pdata = platform_get_drvdata(pdev);
+	if (!pdata)
+		return;
+
+	if (!pdata->ndev)
+		return;
+
+	xgene_enet_remove(pdev);
+}
+
 #ifdef CONFIG_ACPI
 static const struct acpi_device_id xgene_enet_acpi_match[] = {
 	{ "APMC0D05", XGENE_ENET1},
@@ -1714,6 +1737,7 @@ static struct platform_driver xgene_enet_driver = {
 	},
 	.probe = xgene_enet_probe,
 	.remove = xgene_enet_remove,
+	.shutdown = xgene_enet_shutdown,
 };
 
 module_platform_driver(xgene_enet_driver);
-- 
1.9.1
