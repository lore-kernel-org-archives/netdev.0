From: olof@lixom.net (Olof Johansson)
Subject: [PATCH v3] [2/10] pasemi_mac: Move the IRQ mapping from the PCI layer to the driver
Date: Sat, 28 Apr 2007 15:36:50 -0500
Message-ID: <20070428203650.GC4331@lixom.net>
References: <20070428203624.GA4331@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:38611 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751922AbXD1UgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 16:36:14 -0400
Content-Disposition: inline
In-Reply-To: <20070428203624.GA4331@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes for ethernet IRQ mapping, to be done in the driver instead of in
the platform setup code.

Signed-off-by: Olof Johansson <olof@lixom.net>


Index: netdev-2.6/arch/powerpc/platforms/pasemi/pci.c
===================================================================
--- netdev-2.6.orig/arch/powerpc/platforms/pasemi/pci.c
+++ netdev-2.6/arch/powerpc/platforms/pasemi/pci.c
@@ -163,19 +163,6 @@ static void __init pas_fixup_phb_resourc
 }
 
 
-void __devinit pas_pci_irq_fixup(struct pci_dev *dev)
-{
-	/* DMA is special, 84 interrupts (128 -> 211), all but 128
-	 * need to be mapped by hand here.
-	 */
-	if (dev->vendor == 0x1959 && dev->device == 0xa007) {
-		int i;
-		for (i = 129; i < 212; i++)
-			irq_create_mapping(NULL, i);
-	}
-}
-
-
 void __init pas_pci_init(void)
 {
 	struct device_node *np, *root;
Index: netdev-2.6/arch/powerpc/platforms/pasemi/setup.c
===================================================================
--- netdev-2.6.orig/arch/powerpc/platforms/pasemi/setup.c
+++ netdev-2.6/arch/powerpc/platforms/pasemi/setup.c
@@ -240,5 +240,4 @@ define_machine(pas) {
 	.check_legacy_ioport    = pas_check_legacy_ioport,
 	.progress		= pas_progress,
 	.machine_check_exception = pas_machine_check_handler,
-	.pci_irq_fixup		= pas_pci_irq_fixup,
 };
Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -33,6 +33,8 @@
 #include <linux/tcp.h>
 #include <net/checksum.h>
 
+#include <asm/irq.h>
+
 #include "pasemi_mac.h"
 
 
@@ -531,6 +533,7 @@ static irqreturn_t pasemi_mac_tx_intr(in
 static int pasemi_mac_open(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
+	int base_irq;
 	unsigned int flags;
 	int ret;
 
@@ -594,28 +597,37 @@ static int pasemi_mac_open(struct net_de
 	netif_start_queue(dev);
 	netif_poll_enable(dev);
 
-	ret = request_irq(mac->dma_pdev->irq + mac->dma_txch,
-			  &pasemi_mac_tx_intr, IRQF_DISABLED,
+	/* Interrupts are a bit different for our DMA controller: While
+	 * it's got one a regular PCI device header, the interrupt there
+	 * is really the base of the range it's using. Each tx and rx
+	 * channel has it's own interrupt source.
+	 */
+
+	base_irq = virq_to_hw(mac->dma_pdev->irq);
+
+	mac->tx_irq = irq_create_mapping(NULL, base_irq + mac->dma_txch);
+	mac->rx_irq = irq_create_mapping(NULL, base_irq + 20 + mac->dma_txch);
+
+	ret = request_irq(mac->tx_irq, &pasemi_mac_tx_intr, IRQF_DISABLED,
 			  mac->tx->irq_name, dev);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
-		       mac->dma_pdev->irq + mac->dma_txch, ret);
+			base_irq + mac->dma_txch, ret);
 		goto out_tx_int;
 	}
 
-	ret = request_irq(mac->dma_pdev->irq + 20 + mac->dma_rxch,
-			  &pasemi_mac_rx_intr, IRQF_DISABLED,
+	ret = request_irq(mac->rx_irq, &pasemi_mac_rx_intr, IRQF_DISABLED,
 			  mac->rx->irq_name, dev);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
-		       mac->dma_pdev->irq + 20 + mac->dma_rxch, ret);
+			base_irq + 20 + mac->dma_rxch, ret);
 		goto out_rx_int;
 	}
 
 	return 0;
 
 out_rx_int:
-	free_irq(mac->dma_pdev->irq + mac->dma_txch, dev);
+	free_irq(mac->tx_irq, dev);
 out_tx_int:
 	netif_poll_disable(dev);
 	netif_stop_queue(dev);
@@ -699,8 +711,8 @@ static int pasemi_mac_close(struct net_d
 	pci_write_config_dword(mac->dma_pdev,
 			       PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
 
-	free_irq(mac->dma_pdev->irq + mac->dma_txch, dev);
-	free_irq(mac->dma_pdev->irq + 20 + mac->dma_rxch, dev);
+	free_irq(mac->tx_irq, dev);
+	free_irq(mac->rx_irq, dev);
 
 	/* Free resources */
 	pasemi_mac_free_rx_resources(dev);
Index: netdev-2.6/drivers/net/pasemi_mac.h
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.h
+++ netdev-2.6/drivers/net/pasemi_mac.h
@@ -73,6 +73,8 @@ struct pasemi_mac {
 
 	struct pasemi_mac_txring *tx;
 	struct pasemi_mac_rxring *rx;
+	unsigned long	tx_irq;
+	unsigned long	rx_irq;
 };
 
 /* Software status descriptor (desc_info) */
