From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next] r8169:Place dma_alloc_coherent on interrupt context
Date: Thu, 30 Jul 2015 22:33:21 +0300
Message-ID: <1438284801-4188-1-git-send-email-corcodel.marian@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38008 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbbG3Tdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 15:33:37 -0400
Received: by wibxm9 with SMTP id xm9so5051783wib.1
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 12:33:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   According to this doc
 https://www.kernel.org/doc/Documentation/DMA-API.txt   dma_alloc_coherent
 must run on interrupt context, and flush the chip before use.

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3df51fa..edce264 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7535,15 +7535,15 @@ static void rtl8169_down(struct net_device *dev)
 	rtl_pll_power_down(tp);
 }
 
-static int rtl8169_close(struct net_device *dev)
+/*static int rtl8169_close(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev = tp->pci_dev;
 
-	pm_runtime_get_sync(&pdev->dev);
+	pm_runtime_get_sync(&pdev->dev); */
 
 	/* Update counters before going down */
-	rtl8169_update_counters(dev);
+	/*rtl8169_update_counters(dev);
 
 	rtl_lock_work(tp);
 	clear_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
@@ -7565,6 +7565,39 @@ static int rtl8169_close(struct net_device *dev)
 	pm_runtime_put_sync(&pdev->dev);
 
 	return 0;
+} */
+
+static int rtl8169_close(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct pci_dev *pdev = tp->pci_dev;
+
+	pm_runtime_get_sync(&pdev->dev);
+
+	/* Update counters before going down */
+	rtl8169_update_counters(dev);
+
+	rtl_lock_work(tp);
+	clear_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
+
+	rtl8169_down(dev);
+	rtl_unlock_work(tp);
+
+	cancel_work_sync(&tp->wk.work);
+
+	
+
+	dma_free_coherent(&pdev->dev, NUM_RX_DESC, tp->RxDescArray,
+			  tp->RxPhyAddr);
+	dma_free_coherent(&pdev->dev, NUM_RX_DESC, tp->TxDescArray,
+			  tp->TxPhyAddr);
+	tp->TxDescArray = NULL;
+	tp->RxDescArray = NULL;
+
+	pm_runtime_put_sync(&pdev->dev);
+	free_irq(pdev->irq, dev);
+
+	return 0;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -7576,20 +7609,20 @@ static void rtl8169_netpoll(struct net_device *dev)
 }
 #endif
 
-static int rtl_open(struct net_device *dev)
+/*static int rtl_open(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 	int retval = -ENOMEM;
 
-	pm_runtime_get_sync(&pdev->dev);
+	pm_runtime_get_sync(&pdev->dev); */
 
 	/*
 	 * Rx and Tx descriptors needs 256 bytes alignment.
 	 * dma_alloc_coherent provides more.
 	 */
-	tp->TxDescArray = dma_alloc_coherent(&pdev->dev, R8169_TX_RING_BYTES,
+	/*tp->TxDescArray = dma_alloc_coherent(&pdev->dev, R8169_TX_RING_BYTES,
 					     &tp->TxPhyAddr, GFP_KERNEL);
 	if (!tp->TxDescArray)
 		goto err_pm_runtime_put;
@@ -7654,6 +7687,84 @@ err_free_tx_0:
 err_pm_runtime_put:
 	pm_runtime_put_noidle(&pdev->dev);
 	goto out;
+} */
+
+static int rtl_open(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
+	int retval = -ENOMEM;
+
+	retval = request_irq(pdev->irq, rtl8169_interrupt,
+			     (tp->features & RTL_FEATURE_MSI) ? 0 : IRQF_SHARED,
+			     dev->name, dev);
+	if (retval < 0)
+		return -EBUSY;
+
+	pm_runtime_get_sync(&pdev->dev);
+	rtl_hw_reset(tp);
+
+	/*
+	 * Rx and Tx descriptors needs 256 bytes alignment.
+	 * dma_alloc_coherent provides more.
+	 */
+	tp->TxDescArray = dma_alloc_coherent(&pdev->dev, NUM_RX_DESC,
+					     &tp->TxPhyAddr, GFP_KERNEL);
+
+	tp->RxDescArray = dma_alloc_coherent(&pdev->dev, NUM_RX_DESC,
+					     &tp->RxPhyAddr, GFP_KERNEL);
+
+	retval = rtl8169_init_ring(dev);
+	if (retval < 0)
+		goto err;
+
+	
+
+	INIT_WORK(&tp->wk.work, rtl_task);
+
+	smp_mb();
+
+	rtl_request_firmware(tp);
+
+
+
+	rtl_lock_work(tp);
+
+	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
+
+	napi_enable(&tp->napi);
+	rtl8169_init_phy(dev, tp);
+	
+
+	__rtl8169_set_features(dev, dev->features);
+	
+	rtl_pll_power_up(tp);
+
+	rtl_hw_start(dev);
+	//synchronize_sched();
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
+err:
+	dma_free_coherent(&pdev->dev, NUM_RX_DESC, tp->RxDescArray,
+			  tp->RxPhyAddr);
+	tp->RxDescArray = NULL;
+	dma_free_coherent(&pdev->dev, NUM_RX_DESC, tp->TxDescArray,
+			  tp->TxPhyAddr);
+	tp->TxDescArray = NULL;
+	pm_runtime_put_sync(&pdev->dev);
+	free_irq(pdev->irq, dev);
+        goto out;
 }
 
 static struct rtnl_link_stats64 *
-- 
2.1.4
