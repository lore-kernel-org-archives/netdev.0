From: olof@lixom.net (Olof Johansson)
Subject: [PATCH] [2/4] pasemi_mac: irq mapping changes
Date: Mon, 16 Apr 2007 01:18:18 -0500
Message-ID: <20070416061818.GD19783@lixom.net>
References: <20070416061654.GB19783@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20070416061654.GB19783@lixom.net>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Fixes for ethernet IRQ mapping, to move it to the driver instead of in
the platform setup code.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: powerpc/arch/powerpc/platforms/pasemi/pci.c
===================================================================
--- powerpc.orig/arch/powerpc/platforms/pasemi/pci.c
+++ powerpc/arch/powerpc/platforms/pasemi/pci.c
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
Index: powerpc/arch/powerpc/platforms/pasemi/setup.c
===================================================================
--- powerpc.orig/arch/powerpc/platforms/pasemi/setup.c
+++ powerpc/arch/powerpc/platforms/pasemi/setup.c
@@ -240,5 +240,4 @@ define_machine(pas) {
 	.check_legacy_ioport    = pas_check_legacy_ioport,
 	.progress		= pas_progress,
 	.machine_check_exception = pas_machine_check_handler,
-	.pci_irq_fixup		= pas_pci_irq_fixup,
 };
Index: powerpc/drivers/net/pasemi_mac.c
===================================================================
--- powerpc.orig/drivers/net/pasemi_mac.c
+++ powerpc/drivers/net/pasemi_mac.c
@@ -537,6 +537,9 @@ static irqreturn_t pasemi_mac_tx_intr(in
 static int pasemi_mac_open(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
+	struct device_node *dma_dn = pci_device_to_OF_node(mac->dma_pdev);
+	const unsigned int *prop;
+	int base_irq;
 	unsigned int flags;
 	int ret;
 
@@ -600,8 +603,24 @@ static int pasemi_mac_open(struct net_de
 	netif_start_queue(dev);
 	netif_poll_enable(dev);
 
-	ret = request_irq(mac->dma_pdev->irq + mac->dma_txch,
-			  &pasemi_mac_tx_intr, IRQF_DISABLED,
+	/* Interrupts are a bit different for our DMA controller: While
+	 * it's got one a regular PCI device header, the interrupt there
+	 * is really the base of the range it's using. Each tx and rx
+	 * channel has it's own interrupt source.
+	 *
+	 * The only way to get to the actual hardware interrupt is by
+	 * getting it from the device tree, since the kernel has done
+	 * virtual remapping of the sources by the time we can get them
+	 * from the PCI device.
+	 */
+
+	prop = of_get_property(dma_dn, "interrupts", NULL);
+	base_irq = *prop;
+
+	mac->tx_irq = irq_create_mapping(NULL, base_irq + mac->dma_txch);
+	mac->rx_irq = irq_create_mapping(NULL, base_irq + 20 + mac->dma_txch);
+
+	ret = request_irq(mac->tx_irq, &pasemi_mac_tx_intr, IRQF_DISABLED,
 			  mac->tx->irq_name, dev);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
@@ -609,8 +628,7 @@ static int pasemi_mac_open(struct net_de
 		goto out_tx_int;
 	}
 
-	ret = request_irq(mac->dma_pdev->irq + 20 + mac->dma_rxch,
-			  &pasemi_mac_rx_intr, IRQF_DISABLED,
+	ret = request_irq(mac->rx_irq, &pasemi_mac_rx_intr, IRQF_DISABLED,
 			  mac->rx->irq_name, dev);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
@@ -621,7 +639,7 @@ static int pasemi_mac_open(struct net_de
 	return 0;
 
 out_rx_int:
-	free_irq(mac->dma_pdev->irq + mac->dma_txch, dev);
+	free_irq(mac->tx_irq, dev);
 out_tx_int:
 	netif_poll_disable(dev);
 	netif_stop_queue(dev);
@@ -705,8 +723,8 @@ static int pasemi_mac_close(struct net_d
 	pci_write_config_dword(mac->dma_pdev,
 			       PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
 
-	free_irq(mac->dma_pdev->irq + mac->dma_txch, dev);
-	free_irq(mac->dma_pdev->irq + 20 + mac->dma_rxch, dev);
+	free_irq(mac->tx_irq, dev);
+	free_irq(mac->rx_irq, dev);
 
 	/* Free resources */
 	pasemi_mac_free_rx_resources(dev);
Index: powerpc/drivers/net/pasemi_mac.h
===================================================================
--- powerpc.orig/drivers/net/pasemi_mac.h
+++ powerpc/drivers/net/pasemi_mac.h
@@ -73,6 +73,8 @@ struct pasemi_mac {
 
 	struct pasemi_mac_txring *tx;
 	struct pasemi_mac_rxring *rx;
+	unsigned long	tx_irq;
+	unsigned long	rx_irq;
 };
 
 /* Software status descriptor (desc_info) */
