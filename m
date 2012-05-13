From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH] CS89x0 : Use ioread16/iowrite16 on all platforms
Date: Mon, 14 May 2012 00:14:39 +0200
Message-ID: <1336947279-10769-1-git-send-email-jaccon.bastiaansen@gmail.com>
Cc: s.hauer@pengutronix.de, gfm@funxed.com, davem@davemloft.net,
	festevam@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org,
	Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42868 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495Ab2EMWPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2012 18:15:10 -0400
Received: by eaak11 with SMTP id k11so279722eaa.19
        for <netdev@vger.kernel.org>; Sun, 13 May 2012 15:15:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of the inw/outw functions by the cs89x0 platform driver
results in NULL pointer references.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
 drivers/net/ethernet/cirrus/cs89x0.c |   91 +++++++++++++++++++++++-----------
 1 files changed, 62 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index b9406cb..5a1e5d7 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -222,6 +222,7 @@ struct net_local {
 	int send_underrun;	/* keep track of how many underruns in a row we get */
 	int force;		/* force various values; see FORCE* above. */
 	spinlock_t lock;
+	unsigned long phys_addr;/* CS89x0 I/O port or physical address. */
 #if ALLOW_DMA
 	int use_dma;		/* Flag: we're using dma */
 	int dma;		/* DMA channel */
@@ -231,8 +232,6 @@ struct net_local {
 	unsigned char *rx_dma_ptr;	/* points to the next packet  */
 #endif
 #ifdef CONFIG_CS89x0_PLATFORM
-	void __iomem *virt_addr;/* Virtual address for accessing the CS89x0. */
-	unsigned long phys_addr;/* Physical address for accessing the CS89x0. */
 	unsigned long size;	/* Length of CS89x0 memory region. */
 #endif
 };
@@ -279,6 +278,47 @@ static int __init dma_fn(char *str)
 __setup("cs89x0_dma=", dma_fn);
 #endif	/* !defined(MODULE) && (ALLOW_DMA != 0) */
 
+#ifndef CONFIG_CS89x0_PLATFORM
+/*
+ * This function converts the I/O port addres used by the cs89x0_probe() and
+ * init_module() functions to the I/O memory address used by the
+ * cs89x0_probe1() function.
+ */
+static int __init
+cs89x0_ioport_probe(struct net_device *dev, unsigned long ioport, int modular)
+{
+	struct net_local *lp = netdev_priv(dev);
+	int ret = 0;
+	void __iomem *io_mem;
+
+	if (!lp)
+		return -ENOMEM;
+
+	lp->phys_addr = ioport;
+
+	if (!request_region(ioport, NETCARD_IO_EXTENT, DRV_NAME)) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	io_mem = ioport_map(ioport, NETCARD_IO_EXTENT);
+	if (!io_mem) {
+		ret = -ENOMEM;
+		goto release;
+	}
+
+	ret = cs89x0_probe1(dev, ret, modular);
+	if (!ret)
+		goto out;
+
+	ioport_unmap(io_mem);
+release:
+	release_region(ioport, NETCARD_IO_EXTENT);
+out:
+	return ret;
+}
+#endif
+
 #ifndef MODULE
 static int g_cs89x0_media__force;
 
@@ -292,7 +332,6 @@ static int __init media_fn(char *str)
 
 __setup("cs89x0_media=", media_fn);
 
-
 #ifndef CONFIG_CS89x0_PLATFORM
 /* Check for a network adaptor of this type, and return '0' iff one exists.
    If dev->base_addr == 0, probe all likely locations.
@@ -322,12 +361,12 @@ struct net_device * __init cs89x0_probe(int unit)
 		printk("cs89x0:cs89x0_probe(0x%x)\n", io);
 
 	if (io > 0x1ff)	{	/* Check a single specified location. */
-		err = cs89x0_probe1(dev, io, 0);
+		err = cs89x0_ioport_probe(dev, io, 0);
 	} else if (io != 0) {	/* Don't probe at all. */
 		err = -ENXIO;
 	} else {
 		for (port = netcard_portlist; *port; port++) {
-			if (cs89x0_probe1(dev, *port, 0) == 0)
+			if (cs89x0_ioport_probe(dev, *port, 0) == 0)
 				break;
 			dev->irq = irq;
 		}
@@ -373,13 +412,13 @@ writeword(unsigned long base_addr, int portno, u16 value)
 static u16
 readword(unsigned long base_addr, int portno)
 {
-	return inw(base_addr + portno);
+	return ioread16((void __iomem *)base_addr + portno);
 }
 
 static void
 writeword(unsigned long base_addr, int portno, u16 value)
 {
-	outw(value, base_addr + portno);
+	iowrite16(value, (void __iomem *)(base_addr + portno));
 }
 #endif
 
@@ -532,15 +571,6 @@ cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 
         }
 
-	/* Grab the region so we can find another board if autoIRQ fails. */
-	/* WTF is going on here? */
-	if (!request_region(ioaddr & ~3, NETCARD_IO_EXTENT, DRV_NAME)) {
-		printk(KERN_ERR "%s: request_region(0x%lx, 0x%x) failed\n",
-				DRV_NAME, ioaddr, NETCARD_IO_EXTENT);
-		retval = -EBUSY;
-		goto out1;
-	}
-
 	/* if they give us an odd I/O address, then do ONE write to
            the address port, to get it back to address zero, where we
            expect to find the EISA signature word. An IO with a base of 0x3
@@ -553,7 +583,7 @@ cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 				printk(KERN_ERR "%s: bad signature 0x%x\n",
 					dev->name, readword(ioaddr & ~3, ADD_PORT));
 		        	retval = -ENODEV;
-				goto out2;
+				goto out1;
 			}
 	}
 
@@ -568,7 +598,7 @@ cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 			CHIP_EISA_ID_SIG_STR "\n",
 			dev->name, ioaddr, DATA_PORT, tmp);
   		retval = -ENODEV;
-  		goto out2;
+		goto out1;
 	}
 
 	/* Fill in the 'dev' fields. */
@@ -787,13 +817,12 @@ cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 
 	retval = register_netdev(dev);
 	if (retval)
-		goto out3;
+		goto out2;
 	return 0;
-out3:
-	writeword(dev->base_addr, ADD_PORT, PP_ChipID);
 out2:
-	release_region(ioaddr & ~3, NETCARD_IO_EXTENT);
+	writeword(dev->base_addr, ADD_PORT, PP_ChipID);
 out1:
+	release_region(ioaddr & ~3, NETCARD_IO_EXTENT);
 	return retval;
 }
 
@@ -1886,7 +1915,7 @@ int __init init_module(void)
 		goto out;
 	}
 #endif
-	ret = cs89x0_probe1(dev, io, 1);
+	ret = cs89x0_ioport_probe(dev, io, 1);
 	if (ret)
 		goto out;
 
@@ -1900,9 +1929,12 @@ out:
 void __exit
 cleanup_module(void)
 {
+	struct net_local *lp = netdev_priv(dev_cs89x0);
+
 	unregister_netdev(dev_cs89x0);
 	writeword(dev_cs89x0->base_addr, ADD_PORT, PP_ChipID);
-	release_region(dev_cs89x0->base_addr, NETCARD_IO_EXTENT);
+	ioport_unmap((void __iomem *)dev_cs89x0->base_addr);
+	release_region(lp->phys_addr, NETCARD_IO_EXTENT);
 	free_netdev(dev_cs89x0);
 }
 #endif /* MODULE && !CONFIG_CS89x0_PLATFORM */
@@ -1913,6 +1945,7 @@ static int __init cs89x0_platform_probe(struct platform_device *pdev)
 	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
 	struct net_local *lp;
 	struct resource *mem_res;
+	void __iomem *virt_addr;
 	int err;
 
 	if (!dev)
@@ -1936,14 +1969,14 @@ static int __init cs89x0_platform_probe(struct platform_device *pdev)
 		goto free;
 	}
 
-	lp->virt_addr = ioremap(lp->phys_addr, lp->size);
-	if (!lp->virt_addr) {
+	virt_addr = ioremap(lp->phys_addr, lp->size);
+	if (!virt_addr) {
 		dev_warn(&dev->dev, "ioremap() failed.\n");
 		err = -ENOMEM;
 		goto release;
 	}
 
-	err = cs89x0_probe1(dev, (unsigned long)lp->virt_addr, 0);
+	err = cs89x0_probe1(dev, (unsigned long)virt_addr, 0);
 	if (err) {
 		dev_warn(&dev->dev, "no cs8900 or cs8920 detected.\n");
 		goto unmap;
@@ -1953,7 +1986,7 @@ static int __init cs89x0_platform_probe(struct platform_device *pdev)
 	return 0;
 
 unmap:
-	iounmap(lp->virt_addr);
+	iounmap(virt_addr);
 release:
 	release_mem_region(lp->phys_addr, lp->size);
 free:
@@ -1967,7 +2000,7 @@ static int cs89x0_platform_remove(struct platform_device *pdev)
 	struct net_local *lp = netdev_priv(dev);
 
 	unregister_netdev(dev);
-	iounmap(lp->virt_addr);
+	iounmap((void __iomem *)dev->base_addr);
 	release_mem_region(lp->phys_addr, lp->size);
 	free_netdev(dev);
 	return 0;
-- 
1.7.1
