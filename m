From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.10-rc1 3/5] dscc4: error status checking and pci janitoring
Date: Fri, 14 Jan 2005 01:12:12 +0100
Message-ID: <20050114001212.GC2219@electric-eye.fr.zoreil.com>
References: <20050114000732.GA28864@electric-eye.fr.zoreil.com> <20050114000941.GA2219@electric-eye.fr.zoreil.com> <20050114001054.GB2219@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20050114001054.GB2219@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Error status checking and PCI janitoring
- propagation of the error code;
- pci_request_region use in dscc4_init_one;
- missing pci_disable_device() added to the error path;

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/wan/dscc4.c~dscc4-020 drivers/net/wan/dscc4.c
--- linux-2.6.11-rc1/drivers/net/wan/dscc4.c~dscc4-020	2005-01-14 00:54:49.243016015 +0100
+++ linux-2.6.11-rc1-fr/drivers/net/wan/dscc4.c	2005-01-14 00:54:49.248015200 +0100
@@ -708,31 +708,35 @@ static int __devinit dscc4_init_one(stru
 	struct dscc4_dev_priv *dpriv;
 	static int cards_found = 0;
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
@@ -742,14 +746,16 @@ static int __devinit dscc4_init_one(stru
 	pci_write_config_byte(pdev, PCI_LATENCY_TIMER, 0xf8);
 	pci_set_master(pdev);
 
-	if (dscc4_found1(pdev, ioaddr))
-	        goto err_out_iounmap;
+	rc = dscc4_found1(pdev, ioaddr);
+	if (rc < 0)
+	        goto err_iounmap_3;
 
 	priv = (struct dscc4_pci_priv *)pci_get_drvdata(pdev);
 
-	if (request_irq(pdev->irq, &dscc4_irq, SA_SHIRQ, DRV_NAME, priv->root)){
+	rc = request_irq(pdev->irq, dscc4_irq, SA_SHIRQ, DRV_NAME, priv->root);
+	if (rc < 0) {
 		printk(KERN_WARNING "%s: IRQ %d busy\n", DRV_NAME, pdev->irq);
-		goto err_out_free1;
+		goto err_release_4;
 	}
 
 	/* power up/little endian/dma core controlled via lrda/ltda */
@@ -769,9 +775,11 @@ static int __devinit dscc4_init_one(stru
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
@@ -781,7 +789,7 @@ static int __devinit dscc4_init_one(stru
 		dpriv->iqtx = (u32 *) pci_alloc_consistent(pdev,
 			IRQ_RING_SIZE*sizeof(u32), &dpriv->iqtx_dma);
 		if (!dpriv->iqtx)
-			goto err_out_free_iqtx;
+			goto err_free_iqtx_6;
 		writel(dpriv->iqtx_dma, ioaddr + IQTX0 + i*4);
 	}
 	for (i = 0; i < dev_per_card; i++) {
@@ -789,7 +797,7 @@ static int __devinit dscc4_init_one(stru
 		dpriv->iqrx = (u32 *) pci_alloc_consistent(pdev,
 			IRQ_RING_SIZE*sizeof(u32), &dpriv->iqrx_dma);
 		if (!dpriv->iqrx)
-			goto err_out_free_iqrx;
+			goto err_free_iqrx_7;
 		writel(dpriv->iqrx_dma, ioaddr + IQRX0 + i*4);
 	}
 
@@ -805,16 +813,19 @@ static int __devinit dscc4_init_one(stru
 	writel(0xff200001, ioaddr + GCMDR);
 
 	cards_found++;
-	return 0;
 
-err_out_free_iqrx:
+	rc = 0;
+out:
+	return rc;
+
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
@@ -822,20 +833,19 @@ err_out_free_iqtx:
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
@@ -1997,10 +2007,10 @@ static void __devexit dscc4_remove_one(s
 
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

_
