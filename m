From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 4223] New: sis900 kernel oop at boot
Date: Sat, 19 Feb 2005 09:18:52 +1100
Message-ID: <20050218221852.GA15250@gondor.apana.org.au>
References: <E1D26BP-0005Lg-00@gondolin.me.apana.org.au> <5ce5a5e4fed105451a3b7700bf40b04d@libero.it>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gKMricLos+KVdGMg"
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>, mangus@deprecated.it,
        jgarzik@pobox.com
To: Daniele Venzano <webvenza@libero.it>
Content-Disposition: inline
In-Reply-To: <5ce5a5e4fed105451a3b7700bf40b04d@libero.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Feb 18, 2005 at 07:17:06PM +0100, Daniele Venzano wrote:
>
> I think the patch is ok, but it will not apply with the latest changes  
> I sent to Jeff Garzik (see  
> <http://gkernel.bkbits.net:8080/netdev-2.6/related/drivers/net/ 
> sis900.c?nav=index.html|src/.|src/drivers|src/drivers/net>.
> Don't know if this is a problem, since those changes have not yet  
> reached Linus tree.

Thanks for the pointer.  I've rediffed the patch against netdev-2.6.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== drivers/net/sis900.c 1.67 vs edited =====
--- 1.67/drivers/net/sis900.c	2005-01-27 11:00:00 +11:00
+++ edited/drivers/net/sis900.c	2005-02-19 09:16:13 +11:00
@@ -373,6 +373,55 @@
 	return 0;
 }
 
+static int __devinit sis900_init_netdev(struct net_device *net_dev)
+{
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
+	struct pci_dev *pci_dev = sis_priv->pci_dev;
+	long ioaddr = net_dev->base_addr;
+	struct pci_dev *dev;
+	int ret;
+	
+	/* Get Mac address according to the chip revision */
+	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &(sis_priv->chipset_rev));
+	if (netif_msg_probe(sis_priv))
+		printk(KERN_DEBUG "%s: detected revision %2.2x, "
+				  "trying to get MAC address...\n",
+		       net_dev->name, sis_priv->chipset_rev);
+	
+	if (sis_priv->chipset_rev == SIS630E_900_REV)
+		ret = sis630e_get_mac_addr(pci_dev, net_dev);
+	else if ((sis_priv->chipset_rev > 0x81) && (sis_priv->chipset_rev <= 0x90))
+		ret = sis635_get_mac_addr(pci_dev, net_dev);
+	else if (sis_priv->chipset_rev == SIS96x_900_REV)
+		ret = sis96x_get_mac_addr(pci_dev, net_dev);
+	else
+		ret = sis900_get_mac_addr(pci_dev, net_dev);
+
+	if (ret == 0) {
+		printk(KERN_WARNING "%s: Cannot read MAC address.\n", net_dev->name);
+		return -ENODEV;
+	}
+	
+	/* 630ET : set the mii access mode as software-mode */
+	if (sis_priv->chipset_rev == SIS630ET_900_REV)
+		outl(ACCESSMODE | inl(ioaddr + cr), ioaddr + cr);
+
+	/* probe for mii transceiver */
+	if (sis900_mii_probe(net_dev) == 0) {
+		printk(KERN_WARNING "%s: Error probing MII device.\n", net_dev->name);
+		return -ENODEV;
+	}
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
@@ -389,7 +438,6 @@
 {
 	struct sis900_private *sis_priv;
 	struct net_device *net_dev;
-	struct pci_dev *dev;
 	dma_addr_t ring_dma;
 	void *ring_space;
 	long ioaddr;
@@ -463,6 +511,7 @@
 	net_dev->tx_timeout = sis900_tx_timeout;
 	net_dev->watchdog_timeo = TX_TIMEOUT;
 	net_dev->ethtool_ops = &sis900_ethtool_ops;
+	net_dev->init = &sis900_init_netdev;
 
 	if (sis900_debug > 0)
 		sis_priv->msg_enable = sis900_debug;
@@ -472,47 +521,6 @@
 	ret = register_netdev(net_dev);
 	if (ret)
 		goto err_unmap_rx;
-		
-	/* Get Mac address according to the chip revision */
-	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &(sis_priv->chipset_rev));
-	if(netif_msg_probe(sis_priv))
-		printk(KERN_DEBUG "%s: detected revision %2.2x, "
-				"trying to get MAC address...\n",
-				net_dev->name, sis_priv->chipset_rev);
-	
-	ret = 0;
-	if (sis_priv->chipset_rev == SIS630E_900_REV)
-		ret = sis630e_get_mac_addr(pci_dev, net_dev);
-	else if ((sis_priv->chipset_rev > 0x81) && (sis_priv->chipset_rev <= 0x90) )
-		ret = sis635_get_mac_addr(pci_dev, net_dev);
-	else if (sis_priv->chipset_rev == SIS96x_900_REV)
-		ret = sis96x_get_mac_addr(pci_dev, net_dev);
-	else
-		ret = sis900_get_mac_addr(pci_dev, net_dev);
-
-	if (ret == 0) {
-		printk(KERN_WARNING "%s: Cannot read MAC address.\n", net_dev->name);
-		ret = -ENODEV;
-		goto err_out_unregister;
-	}
-	
-	/* 630ET : set the mii access mode as software-mode */
-	if (sis_priv->chipset_rev == SIS630ET_900_REV)
-		outl(ACCESSMODE | inl(ioaddr + cr), ioaddr + cr);
-
-	/* probe for mii transceiver */
-	if (sis900_mii_probe(net_dev) == 0) {
-		printk(KERN_WARNING "%s: Error probing MII device.\n", net_dev->name);
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
@@ -523,8 +531,6 @@
 
 	return 0;
 
- err_out_unregister:
- 	unregister_netdev(net_dev);
  err_unmap_rx:
 	pci_free_consistent(pci_dev, RX_TOTAL_SIZE, sis_priv->rx_ring,
 		sis_priv->rx_ring_dma);

--gKMricLos+KVdGMg--
