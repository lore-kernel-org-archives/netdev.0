From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 5/8] r8169: move rtl8169_open after rtl_task it depends on.
Date: Sat, 10 Mar 2012 23:20:06 +0100
Message-ID: <20120310222006.GF9692@electric-eye.fr.zoreil.com>
References: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41097 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752673Ab2CJWVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 17:21:18 -0500
Content-Disposition: inline
In-Reply-To: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |  168 ++++++++++++++++-----------------
 1 files changed, 81 insertions(+), 87 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index abb6dea..8d4515e 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -775,10 +775,6 @@ MODULE_FIRMWARE(FIRMWARE_8168F_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_2);
 
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance);
-static int rtl8169_init_ring(struct net_device *dev);
-static void rtl_hw_start(struct net_device *dev);
-static void rtl8169_rx_clear(struct rtl8169_private *tp);
-static int rtl8169_poll(struct napi_struct *napi, int budget);
 
 static void rtl_lock_work(struct rtl8169_private *tp)
 {
@@ -4033,88 +4029,6 @@ static void rtl_request_firmware(struct rtl8169_private *tp)
 		rtl_request_uncached_firmware(tp);
 }
 
-static void rtl_task(struct work_struct *);
-
-static int rtl8169_open(struct net_device *dev)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
-	int retval = -ENOMEM;
-
-	pm_runtime_get_sync(&pdev->dev);
-
-	/*
-	 * Rx and Tx desscriptors needs 256 bytes alignment.
-	 * dma_alloc_coherent provides more.
-	 */
-	tp->TxDescArray = dma_alloc_coherent(&pdev->dev, R8169_TX_RING_BYTES,
-					     &tp->TxPhyAddr, GFP_KERNEL);
-	if (!tp->TxDescArray)
-		goto err_pm_runtime_put;
-
-	tp->RxDescArray = dma_alloc_coherent(&pdev->dev, R8169_RX_RING_BYTES,
-					     &tp->RxPhyAddr, GFP_KERNEL);
-	if (!tp->RxDescArray)
-		goto err_free_tx_0;
-
-	retval = rtl8169_init_ring(dev);
-	if (retval < 0)
-		goto err_free_rx_1;
-
-	INIT_WORK(&tp->wk.work, rtl_task);
-
-	smp_mb();
-
-	rtl_request_firmware(tp);
-
-	retval = request_irq(dev->irq, rtl8169_interrupt,
-			     (tp->features & RTL_FEATURE_MSI) ? 0 : IRQF_SHARED,
-			     dev->name, dev);
-	if (retval < 0)
-		goto err_release_fw_2;
-
-	rtl_lock_work(tp);
-
-	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
-
-	napi_enable(&tp->napi);
-
-	rtl8169_init_phy(dev, tp);
-
-	__rtl8169_set_features(dev, dev->features);
-
-	rtl_pll_power_up(tp);
-
-	rtl_hw_start(dev);
-
-	netif_start_queue(dev);
-
-	rtl_unlock_work(tp);
-
-	tp->saved_wolopts = 0;
-	pm_runtime_put_noidle(&pdev->dev);
-
-	rtl8169_check_link_status(dev, tp, ioaddr);
-out:
-	return retval;
-
-err_release_fw_2:
-	rtl_release_firmware(tp);
-	rtl8169_rx_clear(tp);
-err_free_rx_1:
-	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
-			  tp->RxPhyAddr);
-	tp->RxDescArray = NULL;
-err_free_tx_0:
-	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
-			  tp->TxPhyAddr);
-	tp->TxDescArray = NULL;
-err_pm_runtime_put:
-	pm_runtime_put_noidle(&pdev->dev);
-	goto out;
-}
-
 static void rtl_rx_close(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -5806,6 +5720,86 @@ static int rtl8169_close(struct net_device *dev)
 	return 0;
 }
 
+static int rtl_open(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+	int retval = -ENOMEM;
+
+	pm_runtime_get_sync(&pdev->dev);
+
+	/*
+	 * Rx and Tx desscriptors needs 256 bytes alignment.
+	 * dma_alloc_coherent provides more.
+	 */
+	tp->TxDescArray = dma_alloc_coherent(&pdev->dev, R8169_TX_RING_BYTES,
+					     &tp->TxPhyAddr, GFP_KERNEL);
+	if (!tp->TxDescArray)
+		goto err_pm_runtime_put;
+
+	tp->RxDescArray = dma_alloc_coherent(&pdev->dev, R8169_RX_RING_BYTES,
+					     &tp->RxPhyAddr, GFP_KERNEL);
+	if (!tp->RxDescArray)
+		goto err_free_tx_0;
+
+	retval = rtl8169_init_ring(dev);
+	if (retval < 0)
+		goto err_free_rx_1;
+
+	INIT_WORK(&tp->wk.work, rtl_task);
+
+	smp_mb();
+
+	rtl_request_firmware(tp);
+
+	retval = request_irq(dev->irq, rtl8169_interrupt,
+			     (tp->features & RTL_FEATURE_MSI) ? 0 : IRQF_SHARED,
+			     dev->name, dev);
+	if (retval < 0)
+		goto err_release_fw_2;
+
+	rtl_lock_work(tp);
+
+	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
+
+	napi_enable(&tp->napi);
+
+	rtl8169_init_phy(dev, tp);
+
+	__rtl8169_set_features(dev, dev->features);
+
+	rtl_pll_power_up(tp);
+
+	rtl_hw_start(dev);
+
+	netif_start_queue(dev);
+
+	rtl_unlock_work(tp);
+
+	tp->saved_wolopts = 0;
+	pm_runtime_put_noidle(&pdev->dev);
+
+	rtl8169_check_link_status(dev, tp, ioaddr);
+out:
+	return retval;
+
+err_release_fw_2:
+	rtl_release_firmware(tp);
+	rtl8169_rx_clear(tp);
+err_free_rx_1:
+	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
+			  tp->RxPhyAddr);
+	tp->RxDescArray = NULL;
+err_free_tx_0:
+	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
+			  tp->TxPhyAddr);
+	tp->TxDescArray = NULL;
+err_pm_runtime_put:
+	pm_runtime_put_noidle(&pdev->dev);
+	goto out;
+}
+
 static struct rtnl_link_stats64 *
 rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
@@ -6043,7 +6037,7 @@ static void __devexit rtl_remove_one(struct pci_dev *pdev)
 }
 
 static const struct net_device_ops rtl_netdev_ops = {
-	.ndo_open		= rtl8169_open,
+	.ndo_open		= rtl_open,
 	.ndo_stop		= rtl8169_close,
 	.ndo_get_stats64	= rtl8169_get_stats64,
 	.ndo_start_xmit		= rtl8169_start_xmit,
-- 
1.7.7.6
