From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] 2.6.0-test4-bk5 - Was: Re: The recent free_netdev() conversion...
Date: Thu, 4 Sep 2003 00:33:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030904003306.A14624@electric-eye.fr.zoreil.com>
References: <3F535EBD.6090401@pobox.com> <20030901075345.4c35e3e6.davem@redhat.com> <3F536CB7.6060404@pobox.com> <20030901085814.5a333518.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030901085814.5a333518.davem@redhat.com>; from davem@redhat.com on Mon, Sep 01, 2003 at 08:58:14AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@redhat.com> :
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > True, but for long term, it's best to use free_netdev().  Besides 
> > naturally pairing with alloc_foodev(), if we ever decide to have 
> > alloc_netdev() perform more than one allocation, free_netdev() will 
> > already be in place to handle the multiple de-allocations.
> 
> Okie dokie, I'll take patches that fix any of these
> cases.

Please review.

The following drivers haven't been submitted to compilation
- ioc3-eth
- lasi_82596
- lp486e
- smc-mca
- sunXYZ drivers
All others compile fine.


Balance alloc_etherdev() with free_netdev() instead of kfree().

Extra bugs/remarks:
- drivers/net/pcnet32.c
  dev wasn't freed at all in error paths following a failure after
  pci_alloc_consistent() in pcnet32_probe1() -> goto, goto, yummmm...
- drivers/net/sb1000.c
  dev wasn't freed after failure of register_netdev().
- drivers/net/sis190.c
  Calling pci_disable_device() if pci_enable_device() doesn't look nice.
  example for the incoming generations.
  It is probably better to remove the hunks related to drivers/net/sis190.c
  until Jeff feeds its own stuff as my local version contains some extra
  changes.
- drivers/net/smc-mca.c
  dev wasn't freed after failure of register_netdev().
- drivers/net/sungem.c
  let's keep pci_{enable/disable}_device balanced in gem_init_one().


 drivers/net/3c509.c      |    2 +-
 drivers/net/3c59x.c      |    2 +-
 drivers/net/8139cp.c     |    2 +-
 drivers/net/acenic.c     |   10 +++++-----
 drivers/net/amd8111e.c   |    2 +-
 drivers/net/b44.c        |    2 +-
 drivers/net/bmac.c       |    2 +-
 drivers/net/dgrs.c       |    4 ++--
 drivers/net/dl2k.c       |    2 +-
 drivers/net/eepro100.c   |    2 +-
 drivers/net/epic100.c    |    2 +-
 drivers/net/fealnx.c     |    2 +-
 drivers/net/hamachi.c    |    2 +-
 drivers/net/ioc3-eth.c   |    2 +-
 drivers/net/lasi_82596.c |    2 +-
 drivers/net/lp486e.c     |    2 +-
 drivers/net/natsemi.c    |    6 +++---
 drivers/net/pcnet32.c    |   47 ++++++++++++++++++++++++-----------------------
 drivers/net/r8169.c      |    4 ++--
 drivers/net/rcpci45.c    |    2 +-
 drivers/net/sb1000.c     |    4 +++-
 drivers/net/sis190.c     |   15 ++++++++-------
 drivers/net/sis900.c     |    2 +-
 drivers/net/smc-mca.c    |   33 +++++++++++++++++++++++----------
 drivers/net/starfire.c   |    2 +-
 drivers/net/sundance.c   |    2 +-
 drivers/net/sungem.c     |   25 +++++++++++++++++--------
 drivers/net/sunhme.c     |    4 ++--
 drivers/net/sunqe.c      |    2 +-
 drivers/net/tg3.c        |    2 +-
 drivers/net/tlan.c       |    4 ++--
 drivers/net/typhoon.c    |    2 +-
 drivers/net/via-rhine.c  |    2 +-
 drivers/net/yellowfin.c  |    2 +-
 34 files changed, 114 insertions(+), 88 deletions(-)

diff -puN drivers/net/epic100.c~alloc_netdev-balance drivers/net/epic100.c
--- linux-2.6.0-test4-bk5/drivers/net/epic100.c~alloc_netdev-balance	Wed Sep  3 22:59:31 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/epic100.c	Wed Sep  3 23:00:02 2003
@@ -565,7 +565,7 @@ err_out_free_res:
 #endif
 	pci_release_regions(pdev);
 err_out_free_netdev:
-	kfree(dev);
+	free_netdev(dev);
 	return -ENODEV;
 }
 
diff -puN drivers/net/3c509.c~alloc_netdev-balance drivers/net/3c509.c
--- linux-2.6.0-test4-bk5/drivers/net/3c509.c~alloc_netdev-balance	Wed Sep  3 23:02:08 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/3c509.c	Wed Sep  3 23:03:03 2003
@@ -604,7 +604,7 @@ out1:
 		pnp_device_detach(idev);
 #endif
 out:
-	kfree(dev);
+	free_netdev(dev);
 	return err;
 }
 
diff -puN drivers/net/3c59x.c~alloc_netdev-balance drivers/net/3c59x.c
--- linux-2.6.0-test4-bk5/drivers/net/3c59x.c~alloc_netdev-balance	Wed Sep  3 23:03:27 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/3c59x.c	Wed Sep  3 23:04:49 2003
@@ -1468,7 +1468,7 @@ free_ring:
 free_region:
 	if (vp->must_free_region)
 		release_region(ioaddr, vci->io_size);
-	kfree (dev);
+	free_netdev(dev);
 	printk(KERN_ERR PFX "vortex_probe1 fails.  Returns %d\n", retval);
 out:
 	return retval;
diff -puN drivers/net/8139cp.c~alloc_netdev-balance drivers/net/8139cp.c
--- linux-2.6.0-test4-bk5/drivers/net/8139cp.c~alloc_netdev-balance	Wed Sep  3 23:05:27 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/8139cp.c	Wed Sep  3 23:06:04 2003
@@ -1768,7 +1768,7 @@ err_out_mwi:
 err_out_disable:
 	pci_disable_device(pdev);
 err_out_free:
-	kfree(dev);
+	free_netdev(dev);
 	return rc;
 }
 
diff -puN drivers/net/acenic.c~alloc_netdev-balance drivers/net/acenic.c
--- linux-2.6.0-test4-bk5/drivers/net/acenic.c~alloc_netdev-balance	Wed Sep  3 23:07:40 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/acenic.c	Wed Sep  3 23:08:53 2003
@@ -685,7 +685,7 @@ int __devinit acenic_probe (ACE_PROBE_AR
 		}
 
 		if (pci_enable_device(pdev)) {
-			kfree(dev);
+			free_netdev(dev);
 			continue;
 		}
 
@@ -733,7 +733,7 @@ int __devinit acenic_probe (ACE_PROBE_AR
 
 		if (register_netdev(dev)) {
 			printk(KERN_ERR "acenic: device registration failed\n");
-			kfree(dev);
+			free_netdev(dev);
 			continue;
 		}
 
@@ -793,7 +793,7 @@ int __devinit acenic_probe (ACE_PROBE_AR
 			printk(KERN_ERR "%s: Driver compiled without Tigon I"
 			       " support - NIC disabled\n", dev->name);
 			ace_init_cleanup(dev);
-			kfree(dev);
+			free_netdev(dev);
 			continue;
 		}
 #endif
@@ -803,7 +803,7 @@ int __devinit acenic_probe (ACE_PROBE_AR
 			 * ace_allocate_descriptors() calls
 			 * ace_init_cleanup() on error.
 			 */
-			kfree(dev);
+			free_netdev(dev);
 			continue;
 		}
 
@@ -820,7 +820,7 @@ int __devinit acenic_probe (ACE_PROBE_AR
 			/*
 			 * ace_init() calls ace_init_cleanup() on error.
 			 */
-			kfree(dev);
+			free_netdev(dev);
 			continue;
 		}
 
diff -puN drivers/net/amd8111e.c~alloc_netdev-balance drivers/net/amd8111e.c
--- linux-2.6.0-test4-bk5/drivers/net/amd8111e.c~alloc_netdev-balance	Wed Sep  3 23:09:49 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/amd8111e.c	Wed Sep  3 23:10:03 2003
@@ -1927,7 +1927,7 @@ err_iounmap:
 	iounmap((void *) lp->mmio);
 
 err_free_dev:
-	kfree(dev);
+	free_netdev(dev);
 
 err_free_reg:
 	pci_release_regions(pdev);
diff -puN drivers/net/b44.c~alloc_netdev-balance drivers/net/b44.c
--- linux-2.6.0-test4-bk5/drivers/net/b44.c~alloc_netdev-balance	Wed Sep  3 23:10:29 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/b44.c	Wed Sep  3 23:11:01 2003
@@ -1834,7 +1834,7 @@ err_out_iounmap:
 	iounmap((void *) bp->regs);
 
 err_out_free_dev:
-	kfree(dev);
+	free_netdev(dev);
 
 err_out_free_res:
 	pci_release_regions(pdev);
diff -puN drivers/net/bmac.c~alloc_netdev-balance drivers/net/bmac.c
--- linux-2.6.0-test4-bk5/drivers/net/bmac.c~alloc_netdev-balance	Wed Sep  3 23:11:23 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/bmac.c	Wed Sep  3 23:11:40 2003
@@ -1462,7 +1462,7 @@ out2:
 	release_OF_resource(bp->node, 0);
 out1:
 	pmac_call_feature(PMAC_FTR_BMAC_ENABLE, bp->node, 0, 0);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 static int bmac_open(struct net_device *dev)
diff -puN drivers/net/dgrs.c~alloc_netdev-balance drivers/net/dgrs.c
--- linux-2.6.0-test4-bk5/drivers/net/dgrs.c~alloc_netdev-balance	Wed Sep  3 23:12:00 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/dgrs.c	Wed Sep  3 23:13:10 2003
@@ -1275,7 +1275,7 @@ dgrs_found_device(
 	SET_MODULE_OWNER(dev);
 
 	if (register_netdev(dev) != 0) {
-		kfree(dev);
+		free_netdev(dev);
 		return -EIO;
 	}
 
@@ -1322,7 +1322,7 @@ dgrs_found_device(
 
 		ret = -EIO;
 		if (register_netdev(devN)) {
-			kfree(devN);
+			free_netdev(devN);
 			goto fail;
 		}
 		privN->chan = i+1;
diff -puN drivers/net/dl2k.c~alloc_netdev-balance drivers/net/dl2k.c
--- linux-2.6.0-test4-bk5/drivers/net/dl2k.c~alloc_netdev-balance	Wed Sep  3 23:13:35 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/dl2k.c	Wed Sep  3 23:14:07 2003
@@ -319,7 +319,7 @@ rio_probe1 (struct pci_dev *pdev, const 
 
       err_out_dev:
 #endif
-	kfree (dev);
+	free_netdev (dev);
 
       err_out_res:
 	pci_release_regions (pdev);
diff -puN drivers/net/eepro100.c~alloc_netdev-balance drivers/net/eepro100.c
--- linux-2.6.0-test4-bk5/drivers/net/eepro100.c~alloc_netdev-balance	Wed Sep  3 23:14:33 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/eepro100.c	Wed Sep  3 23:14:59 2003
@@ -894,7 +894,7 @@ static int __devinit speedo_found1(struc
 
  err_free_unlock:
 	rtnl_unlock();
-	kfree(dev);
+	free_netdev(dev);
 	return -1;
 }
 
diff -puN drivers/net/fealnx.c~alloc_netdev-balance drivers/net/fealnx.c
--- linux-2.6.0-test4-bk5/drivers/net/fealnx.c~alloc_netdev-balance	Wed Sep  3 23:15:20 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/fealnx.c	Wed Sep  3 23:15:59 2003
@@ -689,7 +689,7 @@ err_out_free_tx:
 err_out_free_rx:
 	pci_free_consistent(pdev, RX_TOTAL_SIZE, np->rx_ring, np->rx_ring_dma);
 err_out_free_dev:
-	kfree(dev);
+	free_netdev(dev);
 err_out_unmap:
 #ifndef USE_IO_OPS
 	iounmap((void *)ioaddr);
diff -puN drivers/net/hamachi.c~alloc_netdev-balance drivers/net/hamachi.c
--- linux-2.6.0-test4-bk5/drivers/net/hamachi.c~alloc_netdev-balance	Wed Sep  3 23:16:14 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/hamachi.c	Wed Sep  3 23:16:39 2003
@@ -785,7 +785,7 @@ err_out_unmap_tx:
 	pci_free_consistent(pdev, TX_TOTAL_SIZE, hmp->tx_ring, 
 		hmp->tx_ring_dma);
 err_out_cleardev:
-	kfree (dev);
+	free_netdev (dev);
 err_out_iounmap:
 	iounmap((char *)ioaddr);
 err_out_release:
diff -puN drivers/net/ioc3-eth.c~alloc_netdev-balance drivers/net/ioc3-eth.c
--- linux-2.6.0-test4-bk5/drivers/net/ioc3-eth.c~alloc_netdev-balance	Wed Sep  3 23:16:58 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/ioc3-eth.c	Wed Sep  3 23:17:19 2003
@@ -1512,7 +1512,7 @@ out_stop:
 out_res:
 	pci_release_regions(pdev);
 out_free:
-	kfree(dev);
+	free_netdev(dev);
 	return err;
 }
 
diff -puN drivers/net/lasi_82596.c~alloc_netdev-balance drivers/net/lasi_82596.c
--- linux-2.6.0-test4-bk5/drivers/net/lasi_82596.c~alloc_netdev-balance	Wed Sep  3 23:17:35 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/lasi_82596.c	Wed Sep  3 23:18:19 2003
@@ -1543,7 +1543,7 @@ lan_init_chip(struct parisc_device *dev)
 	retval = register_netdev(netdevice);
 	if (retval) {
 		printk(KERN_WARNING __FILE__ ": register_netdevice ret'd %d\n", retval);
-		kfree(netdevice);
+		free_netdev(netdevice);
 		return -ENODEV;
 	};
 	if (dev->id.sversion == 0x72) {
diff -puN drivers/net/lp486e.c~alloc_netdev-balance drivers/net/lp486e.c
--- linux-2.6.0-test4-bk5/drivers/net/lp486e.c~alloc_netdev-balance	Wed Sep  3 23:18:27 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/lp486e.c	Wed Sep  3 23:19:22 2003
@@ -1324,7 +1324,7 @@ static int __init lp486e_init_module(voi
 	dev->base_addr = io;
 	dev->init = lp486e_probe;
 	if (register_netdev(dev) != 0) {
-		kfree(dev);
+		free_netdev(dev);
 		return -EIO;
 	}
 	dev_lp486e = dev;
diff -puN drivers/net/natsemi.c~alloc_netdev-balance drivers/net/natsemi.c
--- linux-2.6.0-test4-bk5/drivers/net/natsemi.c~alloc_netdev-balance	Wed Sep  3 23:19:32 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/natsemi.c	Wed Sep  3 23:20:20 2003
@@ -766,7 +766,7 @@ static int __devinit natsemi_probe1 (str
 
 	i = pci_request_regions(pdev, dev->name);
 	if (i) {
-		kfree(dev);
+		free_netdev(dev);
 		return i;
 	}
 
@@ -774,7 +774,7 @@ static int __devinit natsemi_probe1 (str
 		void *mmio = ioremap (ioaddr, iosize);
 		if (!mmio) {
 			pci_release_regions(pdev);
-			kfree(dev);
+			free_netdev(dev);
 			return -ENOMEM;
 		}
 		ioaddr = (unsigned long) mmio;
@@ -838,7 +838,7 @@ static int __devinit natsemi_probe1 (str
 	if (i) {
 		pci_release_regions(pdev);
 		unregister_netdev(dev);
-		kfree(dev);
+		free_netdev(dev);
 		pci_set_drvdata(pdev, NULL);
 		return i;
 	}
diff -puN drivers/net/pcnet32.c~alloc_netdev-balance drivers/net/pcnet32.c
--- linux-2.6.0-test4-bk5/drivers/net/pcnet32.c~alloc_netdev-balance	Wed Sep  3 23:20:44 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/pcnet32.c	Thu Sep  4 00:04:56 2003
@@ -529,6 +529,7 @@ pcnet32_probe1(unsigned long ioaddr, uns
     struct net_device *dev;
     struct pcnet32_access *a = NULL;
     u8 promaddr[6];
+    int ret = -ENODEV;
 
     /* reset the chip */
     pcnet32_wio_reset(ioaddr);
@@ -540,19 +541,15 @@ pcnet32_probe1(unsigned long ioaddr, uns
 	pcnet32_dwio_reset(ioaddr);
 	if (pcnet32_dwio_read_csr(ioaddr, 0) == 4 && pcnet32_dwio_check(ioaddr)) {
 	    a = &pcnet32_dwio;
-	} else {
-		release_region(ioaddr, PCNET32_TOTAL_SIZE);
-		return -ENODEV;
-	}
+	} else
+		goto err_release_region;
     }
 
     chip_version = a->read_csr(ioaddr, 88) | (a->read_csr(ioaddr,89) << 16);
     if (pcnet32_debug > 2)
 	printk(KERN_INFO "  PCnet chip version is %#x.\n", chip_version);
-    if ((chip_version & 0xfff) != 0x003) {
-	    release_region(ioaddr, PCNET32_TOTAL_SIZE);
-	    return -ENODEV;
-    }
+    if ((chip_version & 0xfff) != 0x003)
+	    goto err_release_region;
     
     /* initialize variables */
     fdx = mii = fset = dxsuflo = ltint = 0;
@@ -614,8 +611,7 @@ pcnet32_probe1(unsigned long ioaddr, uns
     default:
 	printk(KERN_INFO PFX "PCnet version %#x, no PCnet32 chip.\n",
 			chip_version);
-	release_region(ioaddr, PCNET32_TOTAL_SIZE);
-	return -ENODEV;
+	goto err_release_region;
     }
 
     /*
@@ -635,8 +631,8 @@ pcnet32_probe1(unsigned long ioaddr, uns
     
     dev = alloc_etherdev(0);
     if(!dev) {
-	    release_region(ioaddr, PCNET32_TOTAL_SIZE);
-	    return -ENOMEM;
+	    ret = -ENOMEM;
+	    goto err_release_region;
     }
     SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -708,8 +704,8 @@ pcnet32_probe1(unsigned long ioaddr, uns
     dev->base_addr = ioaddr;
     /* pci_alloc_consistent returns page-aligned memory, so we do not have to check the alignment */
     if ((lp = pci_alloc_consistent(pdev, sizeof(*lp), &lp_dma_addr)) == NULL) {
-	release_region(ioaddr, PCNET32_TOTAL_SIZE);
-	return -ENOMEM;
+	ret = -ENOMEM;
+	goto err_free_netdev;
     }
 
     memset(lp, 0, sizeof(*lp));
@@ -741,9 +737,8 @@ pcnet32_probe1(unsigned long ioaddr, uns
     
     if (!a) {
       printk(KERN_ERR PFX "No access methods\n");
-      pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
-      release_region(ioaddr, PCNET32_TOTAL_SIZE);
-      return -ENODEV;
+      ret = -ENODEV;
+      goto err_free_consistent;
     }
     lp->a = *a;
     
@@ -785,14 +780,12 @@ pcnet32_probe1(unsigned long ioaddr, uns
 	mdelay (1);
 	
 	dev->irq = probe_irq_off (irq_mask);
-	if (dev->irq)
-	    printk(", probed IRQ %d.\n", dev->irq);
-	else {
+	if (!dev->irq) {
 	    printk(", failed to detect IRQ line.\n");
-	    pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
-	    release_region(ioaddr, PCNET32_TOTAL_SIZE);
-	    return -ENODEV;
+	    ret = -ENODEV;
+	    goto err_free_consistent;
 	}
+	printk(", probed IRQ %d.\n", dev->irq);
     }
 
     /* Set the mii phy_id so that we can query the link state */
@@ -821,6 +814,14 @@ pcnet32_probe1(unsigned long ioaddr, uns
     printk(KERN_INFO "%s: registered as %s\n",dev->name, lp->name);
     cards_found++;
     return 0;
+
+err_free_consistent:
+    pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
+err_free_netdev:
+    free_netdev(dev);
+err_release_region:
+    release_region(ioaddr, PCNET32_TOTAL_SIZE);
+    return ret;
 }
 
 
diff -puN drivers/net/r8169.c~alloc_netdev-balance drivers/net/r8169.c
--- linux-2.6.0-test4-bk5/drivers/net/r8169.c~alloc_netdev-balance	Wed Sep  3 23:29:22 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/r8169.c	Wed Sep  3 23:30:35 2003
@@ -454,7 +454,7 @@ err_out_disable:
 	pci_disable_device(pdev);
 
 err_out:
-	kfree(dev);
+	free_netdev(dev);
 	return rc;
 }
 
@@ -514,7 +514,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 		iounmap(ioaddr);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-		kfree(dev);
+		free_netdev(dev);
 		return rc;
 	}
 
diff -puN drivers/net/rcpci45.c~alloc_netdev-balance drivers/net/rcpci45.c
--- linux-2.6.0-test4-bk5/drivers/net/rcpci45.c~alloc_netdev-balance	Wed Sep  3 23:30:45 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/rcpci45.c	Wed Sep  3 23:32:07 2003
@@ -269,7 +269,7 @@ err_out_free_msgbuf:
 	pci_free_consistent (pdev, MSG_BUF_SIZE, pDpa->msgbuf,
 			     pDpa->msgbuf_dma);
 err_out_free_dev:
-	kfree (dev);
+	free_netdev (dev);
 err_out:
 	card_idx--;
 	return error;
diff -puN drivers/net/sb1000.c~alloc_netdev-balance drivers/net/sb1000.c
--- linux-2.6.0-test4-bk5/drivers/net/sb1000.c~alloc_netdev-balance	Wed Sep  3 23:32:16 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/sb1000.c	Wed Sep  3 23:34:12 2003
@@ -213,9 +213,11 @@ sb1000_probe_one(struct pnp_dev *pdev, c
 
 	error = register_netdev(dev);
 	if (error)
-		goto out_release_regions;
+		goto out_free_netdev;
 	return 0;
 
+ out_free_netdev:
+	free_netdev(dev);
  out_release_regions:
 	release_region(ioaddr[1], 16);
  out_release_region0:
diff -puN drivers/net/sis190.c~alloc_netdev-balance drivers/net/sis190.c
--- linux-2.6.0-test4-bk5/drivers/net/sis190.c~alloc_netdev-balance	Wed Sep  3 23:35:01 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/sis190.c	Wed Sep  3 23:37:23 2003
@@ -473,7 +473,7 @@ SiS190_init_board(struct pci_dev *pdev, 
 
 	rc = pci_set_dma_mask(pdev, 0xffffffffULL);
 	if (rc)
-		goto err_out;
+		goto err_out_disable;
 
 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_end = pci_resource_end(pdev, 0);
@@ -485,18 +485,18 @@ SiS190_init_board(struct pci_dev *pdev, 
 		printk(KERN_ERR PFX
 		       "region #0 not an MMIO resource, aborting\n");
 		rc = -ENODEV;
-		goto err_out;
+		goto err_out_disable;
 	}
 	// check for weird/broken PCI region reporting
 	if (mmio_len < SiS190_MIN_IO_SIZE) {
 		printk(KERN_ERR PFX "Invalid PCI region size(s), aborting\n");
 		rc = -ENODEV;
-		goto err_out;
+		goto err_out_disable;
 	}
 
 	rc = pci_request_regions(pdev, dev->name);
 	if (rc)
-		goto err_out;
+		goto err_out_disable;
 
 	// enable PCI bus-mastering
 	pci_set_master(pdev);
@@ -524,9 +524,10 @@ SiS190_init_board(struct pci_dev *pdev, 
 err_out_free_res:
 	pci_release_regions(pdev);
 
-err_out:
+err_out_disable:
 	pci_disable_device(pdev);
-	kfree(dev);
+err_out:
+	free_netdev(dev);
 	return rc;
 }
 
@@ -606,7 +607,7 @@ SiS190_init_one(struct pci_dev *pdev, co
 		iounmap(ioaddr);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-		kfree(dev);
+		free_netdev(dev);
 		return rc;
 	}
 
diff -puN drivers/net/sis900.c~alloc_netdev-balance drivers/net/sis900.c
--- linux-2.6.0-test4-bk5/drivers/net/sis900.c~alloc_netdev-balance	Wed Sep  3 23:39:12 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/sis900.c	Wed Sep  3 23:40:08 2003
@@ -503,7 +503,7 @@ static int __devinit sis900_probe (struc
  	pci_set_drvdata(pci_dev, NULL);
 	pci_release_regions(pci_dev);
  err_out:
-	kfree(net_dev);
+	free_netdev(net_dev);
 	return ret;
 }
 
diff -puN drivers/net/smc-mca.c~alloc_netdev-balance drivers/net/smc-mca.c
--- linux-2.6.0-test4-bk5/drivers/net/smc-mca.c~alloc_netdev-balance	Wed Sep  3 23:40:19 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/smc-mca.c	Wed Sep  3 23:46:25 2003
@@ -132,7 +132,7 @@ int __init ultramca_probe(struct device 
 	struct mca_device *mca_dev = to_mca_device(gen_dev);
 	char slot = mca_dev->slot;
 	unsigned char pos2 = 0xff, pos3 = 0xff, pos4 = 0xff, pos5 = 0xff;
-	int i;
+	int i, rc;
 	int adapter = mca_dev->index;
 	int tbase = 0;
 	int tirq = 0;
@@ -209,8 +209,9 @@ int __init ultramca_probe(struct device 
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, gen_dev);
 
-	if((i = register_netdev(dev)) != 0)
-		return i;
+	rc = register_netdev(dev);
+	if (rc)
+		goto err_free_netdev;
 
 	printk(KERN_INFO "%s: %s found in slot %d\n",
 	       dev->name, smc_mca_adapter_names[adapter], slot + 1);
@@ -262,11 +263,15 @@ int __init ultramca_probe(struct device 
 		}
 	}
 
-	if (dev->mem_start == 0) /* sanity check, shouldn't happen */
-		return -ENODEV;
+	/* sanity check, shouldn't happen */
+	if (dev->mem_start == 0) {
+		rc = -ENODEV;
+		goto err_unregister_netdev;
+	}
 
-	if (!request_region(ioaddr, ULTRA_IO_EXTENT, dev->name))
-		return -EBUSY;
+	rc = request_region(ioaddr, ULTRA_IO_EXTENT, dev->name);
+	if (rc)
+		goto err_unregister_netdev;
 
 	reg4 = inb(ioaddr + 4) & 0x7f;
 	outb(reg4, ioaddr + 4);
@@ -296,10 +301,10 @@ int __init ultramca_probe(struct device 
 	/* Allocate dev->priv and fill in 8390 specific dev fields.
 	 */
 
-	if (ethdev_init(dev)) {
+	rc = ethdev_init(dev);
+	if (rc) {
 		printk (", no memory for dev->priv.\n");
-		release_region(ioaddr, ULTRA_IO_EXTENT);
-		return -ENOMEM;
+		goto err_release_region;
 	}
 	gen_dev->driver_data = dev;
 
@@ -334,6 +339,14 @@ int __init ultramca_probe(struct device 
 	NS8390_init(dev, 0);
 
 	return 0;
+
+err_release_region:
+	release_region(ioaddr, ULTRA_IO_EXTENT);
+err_unregister_netdev:
+	unregister_netdev(dev);
+err_free_netdev:
+	free_netdev(dev);
+	return rc;
 }
 
 static int ultramca_open(struct net_device *dev)
diff -puN drivers/net/starfire.c~alloc_netdev-balance drivers/net/starfire.c
--- linux-2.6.0-test4-bk5/drivers/net/starfire.c~alloc_netdev-balance	Wed Sep  3 23:46:46 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/starfire.c	Wed Sep  3 23:47:41 2003
@@ -1070,7 +1070,7 @@ err_out_cleardev:
 err_out_free_res:
 	pci_release_regions (pdev);
 err_out_free_netdev:
-	kfree(dev);
+	free_netdev(dev);
 	return -ENODEV;
 }
 
diff -puN drivers/net/sundance.c~alloc_netdev-balance drivers/net/sundance.c
--- linux-2.6.0-test4-bk5/drivers/net/sundance.c~alloc_netdev-balance	Wed Sep  3 23:47:55 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/sundance.c	Wed Sep  3 23:48:39 2003
@@ -734,7 +734,7 @@ err_out_res:
 #endif
 	pci_release_regions(pdev);
 err_out_netdev:
-	kfree (dev);
+	free_netdev (dev);
 	return -ENODEV;
 }
 
diff -puN drivers/net/sungem.c~alloc_netdev-balance drivers/net/sungem.c
--- linux-2.6.0-test4-bk5/drivers/net/sungem.c~alloc_netdev-balance	Wed Sep  3 23:48:47 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/sungem.c	Wed Sep  3 23:54:32 2003
@@ -2630,7 +2630,7 @@ static int __devinit gem_init_one(struct
 		if (err) {
 			printk(KERN_ERR PFX "No usable DMA configuration, "
 			       "aborting.\n");
-			return err;
+			goto err_disable_device;
 		}
 		pci_using_dac = 0;
 	}
@@ -2641,20 +2641,23 @@ static int __devinit gem_init_one(struct
 	if ((pci_resource_flags(pdev, 0) & IORESOURCE_IO) != 0) {
 		printk(KERN_ERR PFX "Cannot find proper PCI device "
 		       "base address, aborting.\n");
-		return -ENODEV;
+		err = -ENODEV;
+		goto err_disable_device;
 	}
 
 	dev = alloc_etherdev(sizeof(*gp));
 	if (!dev) {
 		printk(KERN_ERR PFX "Etherdev alloc failed, aborting.\n");
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto err_disable_device;
 	}
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	gp = dev->priv;
 
-	if (pci_request_regions(pdev, dev->name)) {
+	err = pci_request_regions(pdev, dev->name);
+	if (err) {
 		printk(KERN_ERR PFX "Cannot obtain PCI resources, "
 		       "aborting.\n");
 		goto err_out_free_netdev;
@@ -2688,6 +2691,7 @@ static int __devinit gem_init_one(struct
 	if (gp->regs == 0UL) {
 		printk(KERN_ERR PFX "Cannot map device registers, "
 		       "aborting.\n");
+		err = -EIO;
 		goto err_out_free_res;
 	}
 
@@ -2711,8 +2715,10 @@ static int __devinit gem_init_one(struct
 	/* By default, we start with autoneg */
 	gp->want_autoneg = 1;
 	
-	if (gem_check_invariants(gp))
+	if (gem_check_invariants(gp)) {
+		err = -ENODEV;
 		goto err_out_iounmap;
+	}
 
 	/* It is guaranteed that the returned buffer will be at least
 	 * PAGE_SIZE aligned.
@@ -2723,6 +2729,7 @@ static int __devinit gem_init_one(struct
 	if (!gp->init_block) {
 		printk(KERN_ERR PFX "Cannot allocate init block, "
 		       "aborting.\n");
+		err = -ENOMEM;
 		goto err_out_iounmap;
 	}
 
@@ -2735,6 +2742,7 @@ static int __devinit gem_init_one(struct
 	if (register_netdev(dev)) {
 		printk(KERN_ERR PFX "Cannot register net device, "
 		       "aborting.\n");
+		err = -ENOMEM;
 		goto err_out_free_consistent;
 	}
 
@@ -2804,9 +2812,10 @@ err_out_free_res:
 	pci_release_regions(pdev);
 
 err_out_free_netdev:
-	kfree(dev);
-
-	return -ENODEV;
+	free_netdev(dev);
+err_disable_device:
+	pci_disable_device(pdev);
+	return err;
 
 }
 
diff -puN drivers/net/sunhme.c~alloc_netdev-balance drivers/net/sunhme.c
--- linux-2.6.0-test4-bk5/drivers/net/sunhme.c~alloc_netdev-balance	Wed Sep  3 23:54:40 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/sunhme.c	Wed Sep  3 23:56:19 2003
@@ -2895,7 +2895,7 @@ err_out_iounmap:
 		sbus_iounmap(hp->tcvregs, TCVR_REG_SIZE);
 
 err_out_free_netdev:
-	kfree(dev);
+	free_netdev(dev);
 
 err_out:
 	return err;
@@ -3247,7 +3247,7 @@ err_out_clear_quattro:
 	if (qp != NULL)
 		qp->happy_meals[qfe_slot] = NULL;
 
-	kfree(dev);
+	free_netdev(dev);
 
 err_out:
 	return err;
diff -puN drivers/net/sunqe.c~alloc_netdev-balance drivers/net/sunqe.c
--- linux-2.6.0-test4-bk5/drivers/net/sunqe.c~alloc_netdev-balance	Wed Sep  3 23:56:30 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/sunqe.c	Wed Sep  3 23:58:42 2003
@@ -949,7 +949,7 @@ out1:
 	i = 4;
 out:
 	while (i--)
-		kfree(qe_devs[i]);
+		free_netdev(qe_devs[i]);
 	return res;
 }
 
diff -puN drivers/net/tg3.c~alloc_netdev-balance drivers/net/tg3.c
--- linux-2.6.0-test4-bk5/drivers/net/tg3.c~alloc_netdev-balance	Wed Sep  3 23:58:51 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/tg3.c	Thu Sep  4 00:00:31 2003
@@ -7740,7 +7740,7 @@ err_out_iounmap:
 	iounmap((void *) tp->regs);
 
 err_out_free_dev:
-	kfree(dev);
+	free_netdev(dev);
 
 err_out_free_res:
 	pci_release_regions(pdev);
diff -puN drivers/net/tlan.c~alloc_netdev-balance drivers/net/tlan.c
--- linux-2.6.0-test4-bk5/drivers/net/tlan.c~alloc_netdev-balance	Thu Sep  4 00:00:40 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/tlan.c	Thu Sep  4 00:01:29 2003
@@ -670,7 +670,7 @@ err_out_uninit:
 	pci_free_consistent(priv->pciDev, priv->dmaSize, priv->dmaStorage,
 			    priv->dmaStorageDMA );
 err_out_free_dev:
-	kfree(dev);
+	free_netdev(dev);
 err_out_regions:
 	if (pdev)
 		pci_release_regions(pdev);
@@ -695,7 +695,7 @@ static void TLan_Eisa_Cleanup(void)
 		release_region( dev->base_addr, 0x10);
 		unregister_netdev( dev );
 		TLan_Eisa_Devices = priv->nextDevice;
-		kfree( dev );
+		free_netdev( dev );
 		tlan_have_eisa--;
 	}
 }
diff -puN drivers/net/typhoon.c~alloc_netdev-balance drivers/net/typhoon.c
--- linux-2.6.0-test4-bk5/drivers/net/typhoon.c~alloc_netdev-balance	Thu Sep  4 00:01:35 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/typhoon.c	Thu Sep  4 00:02:11 2003
@@ -2455,7 +2455,7 @@ error_out_remap:
 error_out_regions:
 	pci_release_regions(pdev);
 error_out_dev:
-	kfree(dev);
+	free_netdev(dev);
 error_out:
 	return err;
 }
diff -puN drivers/net/via-rhine.c~alloc_netdev-balance drivers/net/via-rhine.c
--- linux-2.6.0-test4-bk5/drivers/net/via-rhine.c~alloc_netdev-balance	Thu Sep  4 00:02:18 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/via-rhine.c	Thu Sep  4 00:03:08 2003
@@ -868,7 +868,7 @@ err_out_free_res:
 #endif
 	pci_release_regions(pdev);
 err_out_free_netdev:
-	kfree (dev);
+	free_netdev (dev);
 err_out:
 	return -ENODEV;
 }
diff -puN drivers/net/yellowfin.c~alloc_netdev-balance drivers/net/yellowfin.c
--- linux-2.6.0-test4-bk5/drivers/net/yellowfin.c~alloc_netdev-balance	Thu Sep  4 00:03:15 2003
+++ linux-2.6.0-test4-bk5-fr/drivers/net/yellowfin.c	Thu Sep  4 00:03:34 2003
@@ -577,7 +577,7 @@ err_out_free_res:
 #endif
 	pci_release_regions(pdev);
 err_out_free_netdev:
-	kfree (dev);
+	free_netdev (dev);
 	return -ENODEV;
 }
 

_
