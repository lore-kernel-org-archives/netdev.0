From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver fixes
Date: Sun, 13 Feb 2005 15:18:58 -0500
Message-ID: <420FB632.1080706@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060304050309040009090806"
Cc: Netdev <netdev@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060304050309040009090806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------060304050309040009090806
Content-Type: text/plain;
 name="changelog.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changelog.txt"

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/ibm_emac/ibm_emac_core.c |    8 +-
 drivers/net/ibm_emac/ibm_emac_core.h |    2 
 drivers/net/tulip/de2104x.c          |    4 -
 drivers/net/wan/dscc4.c              |  117 ++++++++++++++++++-----------------
 4 files changed, 67 insertions(+), 64 deletions(-)

through these ChangeSets:

<mporter@kernel.crashing.org> (05/02/13 1.2033)
   [PATCH] emac: fix mdio delay
   
   Fixes MDIO delay. Please apply.
   
   Signed-off-by: Ralph Siemsen <ralphs@netwinder.org>
   Signed-off-by: Matt Porter <mporter@kernel.crashing.org>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<mporter@kernel.crashing.org> (05/02/13 1.2032)
   [PATCH] emac: fix jumbo frame support
   
   Fixes a bug in RX buffer allocation so that jumbo size skbs are
   allocated when the MTU size is changed. Also removes the deprecated
   restore_flags() call.  Please apply.
   
   Signed-off-by: Matt Porter <mporter@kernel.crashing.org>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<bjorn-helgaas@comcast.net> (05/02/11 1.2031)
   [PATCH] de214x.c uses uninitialized pci_dev->irq
   
   Don't use pci_dev->irq until after pci_enable_device().
   Andy Esten reported that his NIC stopped working in
   2.6.10 because of this problem.
   
   Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<romieu@fr.zoreil.com> (05/01/27 1.1966.102.5)
   [PATCH] dscc4: removal of unneeded variable
   
   Removal of unneeded variable and more spaces for my eyes.
   
   Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<romieu@fr.zoreil.com> (05/01/27 1.1966.102.4)
   [PATCH] dscc4: removal of unneeded casts
   
   Removal of unneeded casts.
   
   Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<romieu@fr.zoreil.com> (05/01/27 1.1966.102.3)
   [PATCH] dscc4: error status checking and pci janitoring
   
   Error status checking and PCI janitoring
   - propagation of the error code;
   - pci_request_region use in dscc4_init_one;
   - missing pci_disable_device() added to the error path;
   
   Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<romieu@fr.zoreil.com> (05/01/27 1.1966.102.2)
   [PATCH] dscc4: code factorisation
   
   Small code factorization.
   
   Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

<romieu@fr.zoreil.com> (05/01/27 1.1966.102.1)
   [PATCH] dscc4: use of uncompletely initialized struct
   
   dscc4_set_quartz() is issued with an argument in an unitialized state and
   the kernel does not like it.
   
   Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>


--------------060304050309040009090806
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
--- a/drivers/net/ibm_emac/ibm_emac_core.c	2005-02-13 15:18:01 -05:00
+++ b/drivers/net/ibm_emac/ibm_emac_core.c	2005-02-13 15:18:01 -05:00
@@ -475,8 +475,9 @@
 
 	out_be32(&emacp->em0stacr, stacr);
 
-	while (((stacr = in_be32(&emacp->em0stacr) & EMAC_STACR_OC) == 0)
-					&& (count++ < 5000))
+	count = 0;
+	while ((((stacr = in_be32(&emacp->em0stacr)) & EMAC_STACR_OC) == 0)
+					&& (count++ < MDIO_DELAY))
 		udelay(1);
 	MDIO_DEBUG((" (count was %d)\n", count));
 
@@ -912,7 +913,6 @@
 		PKT_DEBUG(("emac_start_xmit() stopping queue\n"));
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&fep->lock, flags);
-		restore_flags(flags);
 		return -EBUSY;
 	}
 
@@ -1281,7 +1281,7 @@
 	/* Format the receive descriptor ring. */
 	ep->rx_slot = 0;
 	/* Default is MTU=1500 + Ethernet overhead */
-	ep->rx_buffer_size = ENET_DEF_BUF_SIZE;
+	ep->rx_buffer_size = dev->mtu + ENET_HEADER_SIZE + ENET_FCS_SIZE;
 	emac_rx_fill(dev, 0);
 	if (ep->rx_slot != 0) {
 		printk(KERN_ERR
diff -Nru a/drivers/net/ibm_emac/ibm_emac_core.h b/drivers/net/ibm_emac/ibm_emac_core.h
--- a/drivers/net/ibm_emac/ibm_emac_core.h	2005-02-13 15:18:01 -05:00
+++ b/drivers/net/ibm_emac/ibm_emac_core.h	2005-02-13 15:18:01 -05:00
@@ -77,8 +77,6 @@
 
 #define ENET_HEADER_SIZE	14
 #define ENET_FCS_SIZE		4
-#define ENET_DEF_MTU_SIZE	1500
-#define ENET_DEF_BUF_SIZE	(ENET_DEF_MTU_SIZE + ENET_HEADER_SIZE + ENET_FCS_SIZE)
 #define EMAC_MIN_FRAME		64
 #define EMAC_MAX_FRAME		9018
 #define EMAC_MIN_MTU		(EMAC_MIN_FRAME - ENET_HEADER_SIZE - ENET_FCS_SIZE)
diff -Nru a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
--- a/drivers/net/tulip/de2104x.c	2005-02-13 15:18:01 -05:00
+++ b/drivers/net/tulip/de2104x.c	2005-02-13 15:18:01 -05:00
@@ -1960,8 +1960,6 @@
 	dev->tx_timeout = de_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-	dev->irq = pdev->irq;
-
 	de = dev->priv;
 	de->de21040 = ent->driver_data == 0 ? 1 : 0;
 	de->pdev = pdev;
@@ -1996,6 +1994,8 @@
 		       pdev->irq, pci_name(pdev));
 		goto err_out_res;
 	}
+
+	dev->irq = pdev->irq;
 
 	/* obtain and check validity of PCI I/O address */
 	pciaddr = pci_resource_start(pdev, 1);
diff -Nru a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
--- a/drivers/net/wan/dscc4.c	2005-02-13 15:18:01 -05:00
+++ b/drivers/net/wan/dscc4.c	2005-02-13 15:18:01 -05:00
@@ -691,7 +691,7 @@
 	root = ppriv->root;
 
 	for (i = 0; i < dev_per_card; i++)
-		unregister_hdlc_device(dscc4_to_dev(&root[i]));
+		unregister_hdlc_device(dscc4_to_dev(root + i));
 
 	pci_set_drvdata(pdev, NULL);
 
@@ -706,33 +706,36 @@
 {
 	struct dscc4_pci_priv *priv;
 	struct dscc4_dev_priv *dpriv;
-	static int cards_found = 0;
 	void __iomem *ioaddr;
-	int i;
+	int i, rc;
 
 	printk(KERN_DEBUG "%s", version);
 
-	if (pci_enable_device(pdev))
-		goto err_out;
-	if (!request_mem_region(pci_resource_start(pdev, 0),
-	                	pci_resource_len(pdev, 0), "registers")) {
+	rc = pci_enable_device(pdev);
+	if (rc < 0)
+		goto out;
+
+	rc = pci_request_region(pdev, 0, "registers");
+	if (rc < 0) {
 	        printk(KERN_ERR "%s: can't reserve MMIO region (regs)\n",
 			DRV_NAME);
-	        goto err_out;
+	        goto err_disable_0;
 	}
-	if (!request_mem_region(pci_resource_start(pdev, 1),
-	                        pci_resource_len(pdev, 1), "LBI interface")) {
+	rc = pci_request_region(pdev, 1, "LBI interface");
+	if (rc < 0) {
 	        printk(KERN_ERR "%s: can't reserve MMIO region (lbi)\n",
 			DRV_NAME);
-	        goto err_out_free_mmio_region0;
+	        goto err_free_mmio_region_1;
 	}
+
 	ioaddr = ioremap(pci_resource_start(pdev, 0),
 					pci_resource_len(pdev, 0));
 	if (!ioaddr) {
 		printk(KERN_ERR "%s: cannot remap MMIO region %lx @ %lx\n",
 			DRV_NAME, pci_resource_len(pdev, 0),
 			pci_resource_start(pdev, 0));
-		goto err_out_free_mmio_region;
+		rc = -EIO;
+		goto err_free_mmio_regions_2;
 	}
 	printk(KERN_DEBUG "Siemens DSCC4, MMIO at %#lx (regs), %#lx (lbi), IRQ %d\n",
 	        pci_resource_start(pdev, 0),
@@ -742,14 +745,16 @@
 	pci_write_config_byte(pdev, PCI_LATENCY_TIMER, 0xf8);
 	pci_set_master(pdev);
 
-	if (dscc4_found1(pdev, ioaddr))
-	        goto err_out_iounmap;
+	rc = dscc4_found1(pdev, ioaddr);
+	if (rc < 0)
+	        goto err_iounmap_3;
 
-	priv = (struct dscc4_pci_priv *)pci_get_drvdata(pdev);
+	priv = pci_get_drvdata(pdev);
 
-	if (request_irq(pdev->irq, &dscc4_irq, SA_SHIRQ, DRV_NAME, priv->root)){
+	rc = request_irq(pdev->irq, dscc4_irq, SA_SHIRQ, DRV_NAME, priv->root);
+	if (rc < 0) {
 		printk(KERN_WARNING "%s: IRQ %d busy\n", DRV_NAME, pdev->irq);
-		goto err_out_free1;
+		goto err_release_4;
 	}
 
 	/* power up/little endian/dma core controlled via lrda/ltda */
@@ -769,9 +774,11 @@
 	priv->iqcfg = (u32 *) pci_alloc_consistent(pdev,
 		IRQ_RING_SIZE*sizeof(u32), &priv->iqcfg_dma);
 	if (!priv->iqcfg)
-		goto err_out_free_irq;
+		goto err_free_irq_5;
 	writel(priv->iqcfg_dma, ioaddr + IQCFG);
 
+	rc = -ENOMEM;
+
 	/*
 	 * SCC 0-3 private rx/tx irq structures
 	 * IQRX/TXi needs to be set soon. Learned it the hard way...
@@ -781,7 +788,7 @@
 		dpriv->iqtx = (u32 *) pci_alloc_consistent(pdev,
 			IRQ_RING_SIZE*sizeof(u32), &dpriv->iqtx_dma);
 		if (!dpriv->iqtx)
-			goto err_out_free_iqtx;
+			goto err_free_iqtx_6;
 		writel(dpriv->iqtx_dma, ioaddr + IQTX0 + i*4);
 	}
 	for (i = 0; i < dev_per_card; i++) {
@@ -789,7 +796,7 @@
 		dpriv->iqrx = (u32 *) pci_alloc_consistent(pdev,
 			IRQ_RING_SIZE*sizeof(u32), &dpriv->iqrx_dma);
 		if (!dpriv->iqrx)
-			goto err_out_free_iqrx;
+			goto err_free_iqrx_7;
 		writel(dpriv->iqrx_dma, ioaddr + IQRX0 + i*4);
 	}
 
@@ -804,17 +811,18 @@
 
 	writel(0xff200001, ioaddr + GCMDR);
 
-	cards_found++;
-	return 0;
+	rc = 0;
+out:
+	return rc;
 
-err_out_free_iqrx:
+err_free_iqrx_7:
 	while (--i >= 0) {
 		dpriv = priv->root + i;
 		pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32),
 				    dpriv->iqrx, dpriv->iqrx_dma);
 	}
 	i = dev_per_card;
-err_out_free_iqtx:
+err_free_iqtx_6:
 	while (--i >= 0) {
 		dpriv = priv->root + i;
 		pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32),
@@ -822,20 +830,19 @@
 	}
 	pci_free_consistent(pdev, IRQ_RING_SIZE*sizeof(u32), priv->iqcfg,
 			    priv->iqcfg_dma);
-err_out_free_irq:
+err_free_irq_5:
 	free_irq(pdev->irq, priv->root);
-err_out_free1:
+err_release_4:
 	dscc4_free1(pdev);
-err_out_iounmap:
+err_iounmap_3:
 	iounmap (ioaddr);
-err_out_free_mmio_region:
-	release_mem_region(pci_resource_start(pdev, 1),
-			   pci_resource_len(pdev, 1));
-err_out_free_mmio_region0:
-	release_mem_region(pci_resource_start(pdev, 0),
-			   pci_resource_len(pdev, 0));
-err_out:
-	return -ENODEV;
+err_free_mmio_regions_2:
+	pci_release_region(pdev, 1);
+err_free_mmio_region_1:
+	pci_release_region(pdev, 0);
+err_disable_0:
+	pci_disable_device(pdev);
+	goto out;
 };
 
 /*
@@ -882,8 +889,7 @@
 	struct dscc4_dev_priv *root;
 	int i, ret = -ENOMEM;
 
-	root = (struct dscc4_dev_priv *)
-		kmalloc(dev_per_card*sizeof(*root), GFP_KERNEL);
+	root = kmalloc(dev_per_card*sizeof(*root), GFP_KERNEL);
 	if (!root) {
 		printk(KERN_ERR "%s: can't allocate data\n", DRV_NAME);
 		goto err_out;
@@ -892,22 +898,17 @@
 
 	for (i = 0; i < dev_per_card; i++) {
 		root[i].dev = alloc_hdlcdev(root + i);
-		if (!root[i].dev) {
-			while (i--)
-				free_netdev(root[i].dev);
+		if (!root[i].dev)
 			goto err_free_dev;
-		}
 	}
 
-	ppriv = (struct dscc4_pci_priv *) kmalloc(sizeof(*ppriv), GFP_KERNEL);
+	ppriv = kmalloc(sizeof(*ppriv), GFP_KERNEL);
 	if (!ppriv) {
 		printk(KERN_ERR "%s: can't allocate private data\n", DRV_NAME);
-		goto err_free_dev2;
+		goto err_free_dev;
 	}
 	memset(ppriv, 0, sizeof(struct dscc4_pci_priv));
-	ret = dscc4_set_quartz(root, quartz);
-	if (ret < 0)
-		goto err_free_priv;
+
 	ppriv->root = root;
 	spin_lock_init(&ppriv->lock);
 
@@ -951,20 +952,24 @@
 			goto err_unregister;
 	        }
 	}
+
+	ret = dscc4_set_quartz(root, quartz);
+	if (ret < 0)
+		goto err_unregister;
+
 	pci_set_drvdata(pdev, ppriv);
 	return ret;
 
 err_unregister:
-	while (--i >= 0) {
+	while (i-- > 0) {
 		dscc4_release_ring(root + i);
-		unregister_hdlc_device(dscc4_to_dev(&root[i]));
+		unregister_hdlc_device(dscc4_to_dev(root + i));
 	}
-err_free_priv:
 	kfree(ppriv);
-err_free_dev2:
-	for (i = 0; i < dev_per_card; i++)
-		free_netdev(root[i].dev);
+	i = dev_per_card;
 err_free_dev:
+	while (i-- > 0)
+		free_netdev(root[i].dev);
 	kfree(root);
 err_out:
 	return ret;
@@ -1998,10 +2003,10 @@
 
 	iounmap(ioaddr);
 
-	release_mem_region(pci_resource_start(pdev, 1),
-			   pci_resource_len(pdev, 1));
-	release_mem_region(pci_resource_start(pdev, 0),
-			   pci_resource_len(pdev, 0));
+	pci_release_region(pdev, 1);
+	pci_release_region(pdev, 0);
+
+	pci_disable_device(pdev);
 }
 
 static int dscc4_hdlc_attach(struct net_device *dev, unsigned short encoding,

--------------060304050309040009090806--
