From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4223] New: sis900 kernel oop at boot
Date: Fri, 18 Feb 2005 22:20:27 +1100
Message-ID: <E1D26BP-0005Lg-00@gondolin.me.apana.org.au>
References: <20050217134440.44f591e2.akpm@osdl.org>
Cc: netdev@oss.sgi.com, mangus@deprecated.it, jgarzik@pobox.com,
        webvenza@libero.it
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20050217134440.44f591e2.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Feb 15 18:26:20 saturno kernel: Unable to handle kernel NULL pointer 
> dereference at virtual address 0000000e 
> Feb 15 18:26:20 saturno kernel:  printing eip: 
> Feb 15 18:26:20 saturno kernel: e1113417 
> Feb 15 18:26:20 saturno kernel: *pde = 00000000 
> Feb 15 18:26:20 saturno kernel: Oops: 0000 [#1] 
> Feb 15 18:26:20 saturno kernel: PREEMPT 
> Feb 15 18:26:20 saturno kernel: Modules linked in: sis900 nvidia 8250_pci 8250 
> serial_core psmouse 
> Feb 15 18:26:20 saturno kernel: CPU:    0 
> Feb 15 18:26:20 saturno kernel: EIP:    0060:[<e1113417>]    Tainted: P 
> VLI 
> Feb 15 18:26:20 saturno kernel: EFLAGS: 00010296   (2.6.10-M7) 
> Feb 15 18:26:20 saturno kernel: EIP is at sis900_check_mode+0x17/0xa0 [sis900] 

OK, this happened because we got preempted before sis900_mii_probe
finished setting the sis_priv->mii.  Theoretically this can happen
with SMP as well but I suppose the number of SMP machines with sis900
is fairly small.

Anyway, the fix is to make sure that sis900_mii_probe is done before
the device can be opened.  This patch does it by moving the setup
after register_netdevice into the netdev init function.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== drivers/net/sis900.c 1.62 vs edited =====
--- 1.62/drivers/net/sis900.c	2005-01-11 03:52:27 +11:00
+++ edited/drivers/net/sis900.c	2005-02-18 22:15:13 +11:00
@@ -365,6 +365,48 @@
 	return 0;
 }
 
+static int __devinit sis900_init_netdev(struct net_device *net_dev)
+{
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
+	struct pci_dev *pci_dev = sis_priv->pci_dev;
+	long ioaddr = net_dev->base_addr;
+	struct pci_dev *dev;
+	int ret;
+	u8 revision;
+
+	/* Get Mac address according to the chip revision */
+	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &revision);
+
+	if (revision == SIS630E_900_REV)
+		ret = sis630e_get_mac_addr(pci_dev, net_dev);
+	else if ((revision > 0x81) && (revision <= 0x90) )
+		ret = sis635_get_mac_addr(pci_dev, net_dev);
+	else if (revision == SIS96x_900_REV)
+		ret = sis96x_get_mac_addr(pci_dev, net_dev);
+	else
+		ret = sis900_get_mac_addr(pci_dev, net_dev);
+
+	if (ret == 0)
+		return -ENODEV;
+	
+	/* 630ET : set the mii access mode as software-mode */
+	if (revision == SIS630ET_900_REV)
+		outl(ACCESSMODE | inl(ioaddr + cr), ioaddr + cr);
+
+	/* probe for mii transceiver */
+	if (sis900_mii_probe(net_dev) == 0)
+		return -ENODEV;
+
+	/* save our host bridge revision */
+	dev = pci_get_device(PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_630, NULL);
+	if (dev) {
+		pci_read_config_byte(dev, PCI_CLASS_REVISION, &sis_priv->host_bridge_rev);
+		pci_dev_put(dev);
+	}
+
+	return 0;
+}
+
 /**
  *	sis900_probe - Probe for sis900 device
  *	@pci_dev: the sis900 pci device
@@ -381,12 +423,10 @@
 {
 	struct sis900_private *sis_priv;
 	struct net_device *net_dev;
-	struct pci_dev *dev;
 	dma_addr_t ring_dma;
 	void *ring_space;
 	long ioaddr;
 	int i, ret;
-	u8 revision;
 	char *card_name = card_names[pci_id->driver_data];
 
 /* when built into the kernel, we only print version if device is found */
@@ -456,45 +496,11 @@
 	net_dev->tx_timeout = sis900_tx_timeout;
 	net_dev->watchdog_timeo = TX_TIMEOUT;
 	net_dev->ethtool_ops = &sis900_ethtool_ops;
+	net_dev->init = &sis900_init_netdev;
 	
 	ret = register_netdev(net_dev);
 	if (ret)
 		goto err_unmap_rx;
-		
-	/* Get Mac address according to the chip revision */
-	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &revision);
-	ret = 0;
-
-	if (revision == SIS630E_900_REV)
-		ret = sis630e_get_mac_addr(pci_dev, net_dev);
-	else if ((revision > 0x81) && (revision <= 0x90) )
-		ret = sis635_get_mac_addr(pci_dev, net_dev);
-	else if (revision == SIS96x_900_REV)
-		ret = sis96x_get_mac_addr(pci_dev, net_dev);
-	else
-		ret = sis900_get_mac_addr(pci_dev, net_dev);
-
-	if (ret == 0) {
-		ret = -ENODEV;
-		goto err_out_unregister;
-	}
-	
-	/* 630ET : set the mii access mode as software-mode */
-	if (revision == SIS630ET_900_REV)
-		outl(ACCESSMODE | inl(ioaddr + cr), ioaddr + cr);
-
-	/* probe for mii transceiver */
-	if (sis900_mii_probe(net_dev) == 0) {
-		ret = -ENODEV;
-		goto err_out_unregister;
-	}
-
-	/* save our host bridge revision */
-	dev = pci_get_device(PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_630, NULL);
-	if (dev) {
-		pci_read_config_byte(dev, PCI_CLASS_REVISION, &sis_priv->host_bridge_rev);
-		pci_dev_put(dev);
-	}
 
 	/* print some information about our NIC */
 	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, ", net_dev->name,
@@ -505,8 +511,6 @@
 
 	return 0;
 
- err_out_unregister:
- 	unregister_netdev(net_dev);
  err_unmap_rx:
 	pci_free_consistent(pci_dev, RX_TOTAL_SIZE, sis_priv->rx_ring,
 		sis_priv->rx_ring_dma);
