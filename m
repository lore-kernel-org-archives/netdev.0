From: Mark Hindley <mark@hindley.org.uk>
Subject: Re: [patch 08/18] 3c59x: check return of pci_enable_device()
Date: Tue, 14 Aug 2007 10:54:32 +0100
Message-ID: <20070814095432.GA13825@hindley.org.uk>
References: <200708102105.l7AL5Jje008968@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 83-216-141-215.markhi700.adsl.metronet.co.uk ([83.216.141.215]:3482
	"EHLO mx.hindley.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956AbXHNJyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 05:54:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2007 at 01:33:26AM -0400, Jeff Garzik wrote:
> I would strongly prefer that vortex_up return a value, since all the 
> important callers of this function can themselves return an error back 
> to the system.
> 
> we can definitely return a meaningful return value here, if 
> pci_enable_device() fails, and I would rather not apply a patch that 
> fails to propagate a serious condition (pci_enable_device failure is 
> indeed serious) when it is possible to do so
> 

OK. Any comments on this revised version? I have only ignored the return of
vortex_up in vortex_error. It is not immediately clear what to do if
vortex_up still fails there after a pci reset.

Mark


diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 001c66d..a1dfd6b 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -705,7 +705,7 @@ static struct {
 
 static int vortex_probe1(struct device *gendev, void __iomem *ioaddr, int irq,
 				   int chip_idx, int card_idx);
-static void vortex_up(struct net_device *dev);
+static int vortex_up(struct net_device *dev);
 static void vortex_down(struct net_device *dev, int final);
 static int vortex_open(struct net_device *dev);
 static void mdio_sync(void __iomem *ioaddr, int bits);
@@ -841,8 +841,11 @@ static int vortex_resume(struct pci_dev *pdev)
 			return -EBUSY;
 		}
 		if (netif_running(dev)) {
-			vortex_up(dev);
-			netif_device_attach(dev);
+			err = vortex_up(dev);
+			if (err)
+				return err;
+			else  
+				netif_device_attach(dev);
 		}
 	}
 	return 0;
@@ -1484,19 +1487,24 @@ static void vortex_check_media(struct net_device *dev, unsigned int init)
 	}
 }
 
-static void
+static int
 vortex_up(struct net_device *dev)
 {
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
 	unsigned int config;
-	int i, mii_reg1, mii_reg5;
+	int i, mii_reg1, mii_reg5, err;
 
 	if (VORTEX_PCI(vp)) {
 		pci_set_power_state(VORTEX_PCI(vp), PCI_D0);	/* Go active */
 		if (vp->pm_state_valid)
 			pci_restore_state(VORTEX_PCI(vp));
-		pci_enable_device(VORTEX_PCI(vp));
+		err = pci_enable_device(VORTEX_PCI(vp));
+		if (err) {
+			printk(KERN_WARNING "%s: Could not enable device \n",
+				dev->name);
+			goto err_out;
+		}
 	}
 
 	/* Before initializing select the active media port. */
@@ -1660,6 +1668,8 @@ vortex_up(struct net_device *dev)
 	if (vp->cb_fn_base)			/* The PCMCIA people are idiots.  */
 		iowrite32(0x8000, vp->cb_fn_base + 4);
 	netif_start_queue (dev);
+err_out:
+	return err;
 }
 
 static int
@@ -1673,7 +1683,7 @@ vortex_open(struct net_device *dev)
 	if ((retval = request_irq(dev->irq, vp->full_bus_master_rx ?
 				&boomerang_interrupt : &vortex_interrupt, IRQF_SHARED, dev->name, dev))) {
 		printk(KERN_ERR "%s: Could not reserve IRQ %d\n", dev->name, dev->irq);
-		goto out;
+		goto err;
 	}
 
 	if (vp->full_bus_master_rx) { /* Boomerang bus master. */
@@ -1702,20 +1712,22 @@ vortex_open(struct net_device *dev)
 				}
 			}
 			retval = -ENOMEM;
-			goto out_free_irq;
+			goto err_free_irq;
 		}
 		/* Wrap the ring. */
 		vp->rx_ring[i-1].next = cpu_to_le32(vp->rx_ring_dma);
 	}
 
-	vortex_up(dev);
-	return 0;
+	retval = vortex_up(dev);
+	if (!retval)
+		goto out;
 
-out_free_irq:
+err_free_irq:
 	free_irq(dev->irq, dev);
-out:
+err:
 	if (vortex_debug > 1)
 		printk(KERN_ERR "%s: vortex_open() fails: returning %d\n", dev->name, retval);
+out:
 	return retval;
 }
 
