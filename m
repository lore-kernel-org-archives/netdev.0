From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 25/34] xircom_cb: stop using net_device.{base_addr, irq} and convert to __iomem.
Date: Thu, 15 Mar 2012 14:57:22 +0100
Message-ID: <d01b498a140cc8f7245d2c05443706807f62e62a.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51890 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755016Ab2CON7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:55 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Grant Grundler <grundler@parisc-linux.org>
---
 drivers/net/ethernet/dec/tulip/xircom_cb.c |   37 ++++++++++++++++++----------
 1 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index cbcc6d6..4aed477 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -41,7 +41,9 @@ MODULE_DESCRIPTION("Xircom Cardbus ethernet driver");
 MODULE_AUTHOR("Arjan van de Ven <arjanv@redhat.com>");
 MODULE_LICENSE("GPL");
 
-
+#define outl	iowrite32
+#define inl	ioread32
+#define inb	ioread8
 
 /* IO registers on the card, offsets */
 #define CSR0	0x00
@@ -83,7 +85,7 @@ struct xircom_private {
 
 	struct sk_buff *tx_skb[4];
 
-	unsigned long io_port;
+	void __iomem *io_port;
 	int open;
 
 	/* transmit_used is the rotating counter that indicates which transmit
@@ -253,10 +255,13 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 
 	private->dev = dev;
 	private->pdev = pdev;
-	private->io_port = pci_resource_start(pdev, 0);
+
+	/* IO range. */
+	private->io_port = pci_iomap(pdev, 0, 0);
+	if (!private->io_port)
+		goto reg_fail;
+
 	spin_lock_init(&private->lock);
-	dev->irq = pdev->irq;
-	dev->base_addr = private->io_port;
 
 	initialize_card(private);
 	read_mac_address(private);
@@ -268,7 +273,7 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	rc = register_netdev(dev);
 	if (rc < 0) {
 		pr_err("%s: netdevice registration failed\n", __func__);
-		goto reg_fail;
+		goto err_unmap;
 	}
 
 	netdev_info(dev, "Xircom cardbus revision %i at irq %i\n",
@@ -286,6 +291,8 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 out:
 	return rc;
 
+err_unmap:
+	pci_iounmap(pdev, private->io_port);
 reg_fail:
 	pci_set_drvdata(pdev, NULL);
 	dma_free_coherent(d, 8192, private->tx_buffer, private->tx_dma_handle);
@@ -314,6 +321,7 @@ static void __devexit xircom_remove(struct pci_dev *pdev)
 	struct device *d = &pdev->dev;
 
 	unregister_netdev(dev);
+	pci_iounmap(pdev, card->io_port);
 	pci_set_drvdata(pdev, NULL);
 	dma_free_coherent(d, 8192, card->tx_buffer, card->tx_dma_handle);
 	dma_free_coherent(d, 8192, card->rx_buffer, card->rx_dma_handle);
@@ -438,11 +446,11 @@ static netdev_tx_t xircom_start_xmit(struct sk_buff *skb,
 static int xircom_open(struct net_device *dev)
 {
 	struct xircom_private *xp = netdev_priv(dev);
+	const int irq = xp->pdev->irq;
 	int retval;
 
-	netdev_info(dev, "xircom cardbus adaptor found, using irq %i\n",
-		    dev->irq);
-	retval = request_irq(dev->irq, xircom_interrupt, IRQF_SHARED, dev->name, dev);
+	netdev_info(dev, "xircom cardbus adaptor found, using irq %i\n", irq);
+	retval = request_irq(irq, xircom_interrupt, IRQF_SHARED, dev->name, dev);
 	if (retval)
 		return retval;
 
@@ -474,7 +482,7 @@ static int xircom_close(struct net_device *dev)
 	spin_unlock_irqrestore(&card->lock,flags);
 
 	card->open = 0;
-	free_irq(dev->irq,dev);
+	free_irq(card->pdev->irq, dev);
 
 	return 0;
 
@@ -484,9 +492,12 @@ static int xircom_close(struct net_device *dev)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void xircom_poll_controller(struct net_device *dev)
 {
-	disable_irq(dev->irq);
-	xircom_interrupt(dev->irq, dev);
-	enable_irq(dev->irq);
+	struct xircom_private *xp = netdev_priv(dev);
+	const int irq = xp->pdev->irq;
+
+	disable_irq(irq);
+	xircom_interrupt(irq, dev);
+	enable_irq(irq);
 }
 #endif
 
-- 
1.7.7.6
