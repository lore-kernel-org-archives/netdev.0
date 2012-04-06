From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 24/39] xircom_cb: fix device probe error path.
Date: Fri,  6 Apr 2012 12:06:38 +0200
Message-ID: <271dcd170006b9d55eb555b2e79e22c1fa86e0a0.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43491 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756062Ab2DFKKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:43 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unbalanced pci_disable_device
- PCI ressources were not released
- mismatching pci_alloc_.../kfree pairs are replaced by DMA alloc helpers.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Grant Grundler <grundler@parisc-linux.org>
---
 drivers/net/ethernet/dec/tulip/xircom_cb.c |   53 ++++++++++++++++++----------
 1 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index fdb329f..cbcc6d6 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -192,15 +192,18 @@ static const struct net_device_ops netdev_ops = {
  */
 static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
+	struct device *d = &pdev->dev;
 	struct net_device *dev = NULL;
 	struct xircom_private *private;
 	unsigned long flags;
 	unsigned short tmp16;
+	int rc;
 
 	/* First do the PCI initialisation */
 
-	if (pci_enable_device(pdev))
-		return -ENODEV;
+	rc = pci_enable_device(pdev);
+	if (rc < 0)
+		goto out;
 
 	/* disable all powermanagement */
 	pci_write_config_dword(pdev, PCI_POWERMGMT, 0x0000);
@@ -211,11 +214,13 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	pci_read_config_word (pdev,PCI_STATUS, &tmp16);
 	pci_write_config_word (pdev, PCI_STATUS,tmp16);
 
-	if (!request_region(pci_resource_start(pdev, 0), 128, "xircom_cb")) {
+	rc = pci_request_regions(pdev, "xircom_cb");
+	if (rc < 0) {
 		pr_err("%s: failed to allocate io-region\n", __func__);
-		return -ENODEV;
+		goto err_disable;
 	}
 
+	rc = -ENOMEM;
 	/*
 	   Before changing the hardware, allocate the memory.
 	   This way, we can fail gracefully if not enough memory
@@ -223,17 +228,21 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	 */
 	dev = alloc_etherdev(sizeof(struct xircom_private));
 	if (!dev)
-		goto device_fail;
+		goto err_release;
 
 	private = netdev_priv(dev);
 
 	/* Allocate the send/receive buffers */
-	private->rx_buffer = pci_alloc_consistent(pdev,8192,&private->rx_dma_handle);
+	private->rx_buffer = dma_alloc_coherent(d, 8192,
+						&private->rx_dma_handle,
+						GFP_KERNEL);
 	if (private->rx_buffer == NULL) {
 		pr_err("%s: no memory for rx buffer\n", __func__);
 		goto rx_buf_fail;
 	}
-	private->tx_buffer = pci_alloc_consistent(pdev,8192,&private->tx_dma_handle);
+	private->tx_buffer = dma_alloc_coherent(d, 8192,
+						&private->tx_dma_handle,
+						GFP_KERNEL);
 	if (private->tx_buffer == NULL) {
 		pr_err("%s: no memory for tx buffer\n", __func__);
 		goto tx_buf_fail;
@@ -256,7 +265,8 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	dev->netdev_ops = &netdev_ops;
 	pci_set_drvdata(pdev, dev);
 
-	if (register_netdev(dev)) {
+	rc = register_netdev(dev);
+	if (rc < 0) {
 		pr_err("%s: netdevice registration failed\n", __func__);
 		goto reg_fail;
 	}
@@ -273,17 +283,21 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	spin_unlock_irqrestore(&private->lock,flags);
 
 	trigger_receive(private);
-
-	return 0;
+out:
+	return rc;
 
 reg_fail:
-	kfree(private->tx_buffer);
+	pci_set_drvdata(pdev, NULL);
+	dma_free_coherent(d, 8192, private->tx_buffer, private->tx_dma_handle);
 tx_buf_fail:
-	kfree(private->rx_buffer);
+	dma_free_coherent(d, 8192, private->rx_buffer, private->rx_dma_handle);
 rx_buf_fail:
 	free_netdev(dev);
-device_fail:
-	return -ENODEV;
+err_release:
+	pci_release_regions(pdev);
+err_disable:
+	pci_disable_device(pdev);
+	goto out;
 }
 
 
@@ -297,14 +311,15 @@ static void __devexit xircom_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct xircom_private *card = netdev_priv(dev);
+	struct device *d = &pdev->dev;
 
-	pci_free_consistent(pdev,8192,card->rx_buffer,card->rx_dma_handle);
-	pci_free_consistent(pdev,8192,card->tx_buffer,card->tx_dma_handle);
-
-	release_region(dev->base_addr, 128);
 	unregister_netdev(dev);
-	free_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
+	dma_free_coherent(d, 8192, card->tx_buffer, card->tx_dma_handle);
+	dma_free_coherent(d, 8192, card->rx_buffer, card->rx_dma_handle);
+	free_netdev(dev);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
 }
 
 static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
-- 
1.7.7.6
