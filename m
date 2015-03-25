From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH net-next v1 3/3] drivers: net: xgene: Add separate tx completion ring
Date: Wed, 25 Mar 2015 12:19:12 -0700
Message-ID: <1427311152-30333-4-git-send-email-isubramanian@apm.com>
References: <1427311152-30333-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, kchudgar-qTEPVZfXA3Y@public.gmane.org,
	patches-qTEPVZfXA3Y@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1427311152-30333-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

- Added wrapper functions around napi_add, napi_del, napi_enable and napi_disable
- Moved platform_get_irq function call after reading phy_mode
- Associating the new irq to tx completion for the supported ethernet interfaces

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 141 +++++++++++++++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |   6 +
 2 files changed, 127 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 6146a993..40d3530 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -428,13 +428,23 @@ static int xgene_enet_register_irq(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct device *dev = ndev_to_dev(ndev);
+	struct xgene_enet_desc_ring *ring;
 	int ret;
 
-	ret = devm_request_irq(dev, pdata->rx_ring->irq, xgene_enet_rx_irq,
-			       IRQF_SHARED, ndev->name, pdata->rx_ring);
-	if (ret) {
-		netdev_err(ndev, "rx%d interrupt request failed\n",
-			   pdata->rx_ring->irq);
+	ring = pdata->rx_ring;
+	ret = devm_request_irq(dev, ring->irq, xgene_enet_rx_irq,
+			       IRQF_SHARED, ring->irq_name, ring);
+	if (ret)
+		netdev_err(ndev, "Failed to request irq %s\n", ring->irq_name);
+
+	if (pdata->cq_cnt) {
+		ring = pdata->tx_ring->cp_ring;
+		ret = devm_request_irq(dev, ring->irq, xgene_enet_rx_irq,
+				       IRQF_SHARED, ring->irq_name, ring);
+		if (ret) {
+			netdev_err(ndev, "Failed to request irq %s\n",
+				   ring->irq_name);
+		}
 	}
 
 	return ret;
@@ -448,6 +458,37 @@ static void xgene_enet_free_irq(struct net_device *ndev)
 	pdata = netdev_priv(ndev);
 	dev = ndev_to_dev(ndev);
 	devm_free_irq(dev, pdata->rx_ring->irq, pdata->rx_ring);
+
+	if (pdata->cq_cnt) {
+		devm_free_irq(dev, pdata->tx_ring->cp_ring->irq,
+			      pdata->tx_ring->cp_ring);
+	}
+}
+
+static void xgene_enet_napi_enable(struct xgene_enet_pdata *pdata)
+{
+	struct napi_struct *napi;
+
+	napi = &pdata->rx_ring->napi;
+	napi_enable(napi);
+
+	if (pdata->cq_cnt) {
+		napi = &pdata->tx_ring->cp_ring->napi;
+		napi_enable(napi);
+	}
+}
+
+static void xgene_enet_napi_disable(struct xgene_enet_pdata *pdata)
+{
+	struct napi_struct *napi;
+
+	napi = &pdata->rx_ring->napi;
+	napi_disable(napi);
+
+	if (pdata->cq_cnt) {
+		napi = &pdata->tx_ring->cp_ring->napi;
+		napi_disable(napi);
+	}
 }
 
 static int xgene_enet_open(struct net_device *ndev)
@@ -462,7 +503,7 @@ static int xgene_enet_open(struct net_device *ndev)
 	ret = xgene_enet_register_irq(ndev);
 	if (ret)
 		return ret;
-	napi_enable(&pdata->rx_ring->napi);
+	xgene_enet_napi_enable(pdata);
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
 		phy_start(pdata->phy_dev);
@@ -486,7 +527,7 @@ static int xgene_enet_close(struct net_device *ndev)
 	else
 		cancel_delayed_work_sync(&pdata->link_work);
 
-	napi_disable(&pdata->rx_ring->napi);
+	xgene_enet_napi_disable(pdata);
 	xgene_enet_free_irq(ndev);
 	xgene_enet_process_ring(pdata->rx_ring, -1);
 
@@ -580,6 +621,8 @@ static void xgene_enet_free_desc_rings(struct xgene_enet_pdata *pdata)
 	if (ring) {
 		if (ring->cp_ring && ring->cp_ring->cp_skb)
 			devm_kfree(dev, ring->cp_ring->cp_skb);
+		if (ring->cp_ring && pdata->cq_cnt)
+			xgene_enet_free_desc_ring(ring->cp_ring);
 		xgene_enet_free_desc_ring(ring);
 	}
 
@@ -673,6 +716,12 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 	rx_ring->nbufpool = NUM_BUFPOOL;
 	rx_ring->buf_pool = buf_pool;
 	rx_ring->irq = pdata->rx_irq;
+	if (!pdata->cq_cnt) {
+		snprintf(rx_ring->irq_name, IRQ_ID_SIZE, "%s-rx-txc",
+			 ndev->name);
+	} else {
+		snprintf(rx_ring->irq_name, IRQ_ID_SIZE, "%s-rx", ndev->name);
+	}
 	buf_pool->rx_skb = devm_kcalloc(dev, buf_pool->slots,
 					sizeof(struct sk_buff *), GFP_KERNEL);
 	if (!buf_pool->rx_skb) {
@@ -694,7 +743,22 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 	}
 	pdata->tx_ring = tx_ring;
 
-	cp_ring = pdata->rx_ring;
+	if (!pdata->cq_cnt) {
+		cp_ring = pdata->rx_ring;
+	} else {
+		/* allocate tx completion descriptor ring */
+		ring_id = xgene_enet_get_ring_id(RING_OWNER_CPU, cpu_bufnum++);
+		cp_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
+						      RING_CFGSIZE_16KB,
+						      ring_id);
+		if (!cp_ring) {
+			ret = -ENOMEM;
+			goto err;
+		}
+		cp_ring->irq = pdata->txc_irq;
+		snprintf(cp_ring->irq_name, IRQ_ID_SIZE, "%s-txc", ndev->name);
+	}
+
 	cp_ring->cp_skb = devm_kcalloc(dev, tx_ring->slots,
 				       sizeof(struct sk_buff *), GFP_KERNEL);
 	if (!cp_ring->cp_skb) {
@@ -853,14 +917,6 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 		return -ENOMEM;
 	}
 
-	ret = platform_get_irq(pdev, 0);
-	if (ret <= 0) {
-		dev_err(dev, "Unable to get ENET Rx IRQ\n");
-		ret = ret ? : -ENXIO;
-		return ret;
-	}
-	pdata->rx_irq = ret;
-
 	ret = xgene_get_port_id(dev, pdata);
 	if (ret)
 		return ret;
@@ -882,6 +938,24 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 		return -ENODEV;
 	}
 
+	ret = platform_get_irq(pdev, 0);
+	if (ret <= 0) {
+		dev_err(dev, "Unable to get ENET Rx IRQ\n");
+		ret = ret ? : -ENXIO;
+		return ret;
+	}
+	pdata->rx_irq = ret;
+
+	if (pdata->phy_mode != PHY_INTERFACE_MODE_RGMII) {
+		ret = platform_get_irq(pdev, 1);
+		if (ret <= 0) {
+			dev_err(dev, "Unable to get ENET Tx completion IRQ\n");
+			ret = ret ? : -ENXIO;
+			return ret;
+		}
+		pdata->txc_irq = ret;
+	}
+
 	pdata->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pdata->clk)) {
 		/* Firmware may have set up the clock already. */
@@ -950,11 +1024,13 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 		pdata->mac_ops = &xgene_sgmac_ops;
 		pdata->port_ops = &xgene_sgport_ops;
 		pdata->rm = RM1;
+		pdata->cq_cnt = XGENE_MAX_TXC_RINGS;
 		break;
 	default:
 		pdata->mac_ops = &xgene_xgmac_ops;
 		pdata->port_ops = &xgene_xgport_ops;
 		pdata->rm = RM0;
+		pdata->cq_cnt = XGENE_MAX_TXC_RINGS;
 		break;
 	}
 
@@ -977,12 +1053,38 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 
 }
 
+static void xgene_enet_napi_add(struct xgene_enet_pdata *pdata)
+{
+	struct napi_struct *napi;
+
+	napi = &pdata->rx_ring->napi;
+	netif_napi_add(pdata->ndev, napi, xgene_enet_napi, NAPI_POLL_WEIGHT);
+
+	if (pdata->cq_cnt) {
+		napi = &pdata->tx_ring->cp_ring->napi;
+		netif_napi_add(pdata->ndev, napi, xgene_enet_napi,
+			       NAPI_POLL_WEIGHT);
+	}
+}
+
+static void xgene_enet_napi_del(struct xgene_enet_pdata *pdata)
+{
+	struct napi_struct *napi;
+
+	napi = &pdata->rx_ring->napi;
+	netif_napi_del(napi);
+
+	if (pdata->cq_cnt) {
+		napi = &pdata->tx_ring->cp_ring->napi;
+		netif_napi_del(napi);
+	}
+}
+
 static int xgene_enet_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
 	struct xgene_enet_pdata *pdata;
 	struct device *dev = &pdev->dev;
-	struct napi_struct *napi;
 	struct xgene_mac_ops *mac_ops;
 	int ret;
 
@@ -1024,8 +1126,7 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	if (ret)
 		goto err;
 
-	napi = &pdata->rx_ring->napi;
-	netif_napi_add(ndev, napi, xgene_enet_napi, NAPI_POLL_WEIGHT);
+	xgene_enet_napi_add(pdata);
 	mac_ops = pdata->mac_ops;
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
 		ret = xgene_enet_mdio_config(pdata);
@@ -1052,7 +1153,7 @@ static int xgene_enet_remove(struct platform_device *pdev)
 	mac_ops->rx_disable(pdata);
 	mac_ops->tx_disable(pdata);
 
-	netif_napi_del(&pdata->rx_ring->napi);
+	xgene_enet_napi_del(pdata);
 	xgene_enet_mdio_remove(pdata);
 	xgene_enet_delete_desc_rings(pdata);
 	unregister_netdev(ndev);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index b93ed21..8f3d232 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -51,6 +51,9 @@
 #define START_BP_BUFNUM_1	0x2A
 #define START_RING_NUM_1	264
 
+#define IRQ_ID_SIZE		16
+#define XGENE_MAX_TXC_RINGS	1
+
 #define PHY_POLL_LINK_ON	(10 * HZ)
 #define PHY_POLL_LINK_OFF	(PHY_POLL_LINK_ON / 5)
 
@@ -63,6 +66,7 @@ struct xgene_enet_desc_ring {
 	u16 tail;
 	u16 slots;
 	u16 irq;
+	char irq_name[IRQ_ID_SIZE];
 	u32 size;
 	u32 state[NUM_RING_CONFIG];
 	void __iomem *cmd_base;
@@ -117,6 +121,8 @@ struct xgene_enet_pdata {
 	u32 cp_qcnt_hi;
 	u32 cp_qcnt_low;
 	u32 rx_irq;
+	u32 txc_irq;
+	u8 cq_cnt;
 	void __iomem *eth_csr_addr;
 	void __iomem *eth_ring_if_addr;
 	void __iomem *eth_diag_csr_addr;
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
