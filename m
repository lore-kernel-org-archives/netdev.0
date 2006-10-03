From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx-softmac: Fix system hang for x86-64 with >1GB RAM
Date: Mon, 02 Oct 2006 23:48:54 -0500
Message-ID: <4521EBB6.mailBJL11AF99@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

The bcm43xx-softmac software currently fails when running on x86_64 systems
with more than 1GB RAM and one of the card variants with 30-bit DMA addressing.
This patch uses the address extension bits in the hardware to set the correct
DMA mask for the specific card in use.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

Please apply this to wireless-2.6. It is a fix for a current bug,
and should be sent upstream for inclusion in 2.6.19. The patch has been
circulated on the bcm43xx mailing list for a couple of weeks, and has
fixed every case where there was a problem with more than 1 GB RAM.

Larry


Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_dma.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_dma.h
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_dma.h
@@ -314,6 +314,23 @@ int bcm43xx_dma_tx(struct bcm43xx_privat
 		   struct ieee80211_txb *txb);
 void bcm43xx_dma_rx(struct bcm43xx_dmaring *ring);
 
+/* Helper function that returns the dma mask for this device. */
+static inline
+u64 bcm43xx_get_supported_dma_mask(struct bcm43xx_private *bcm)
+{
+	int dma64 = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATEHIGH) &
+				   BCM43xx_SBTMSTATEHIGH_DMA64BIT;
+	u16 mmio_base = bcm43xx_dmacontroller_base(dma64, 0);
+	u32 mask = BCM43xx_DMA32_TXADDREXT_MASK;
+
+	if (dma64)
+		return DMA_64BIT_MASK;
+	bcm43xx_write32(bcm, mmio_base + BCM43xx_DMA32_TXCTL, mask);
+	if (bcm43xx_read32(bcm, mmio_base + BCM43xx_DMA32_TXCTL) & mask)
+		return DMA_32BIT_MASK;
+	return DMA_30BIT_MASK;
+}
+
 #else /* CONFIG_BCM43XX_DMA */
 
 
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2925,10 +2925,13 @@ static int bcm43xx_wireless_core_init(st
 		bcm43xx_write16(bcm, 0x043C, 0x000C);
 
 	if (active_wlcore) {
-		if (bcm43xx_using_pio(bcm))
+		if (bcm43xx_using_pio(bcm)) {
 			err = bcm43xx_pio_init(bcm);
-		else
+		} else {
 			err = bcm43xx_dma_init(bcm);
+			if (err == -ENOSYS)
+				err = bcm43xx_pio_init(bcm);
+		}
 		if (err)
 			goto err_chip_cleanup;
 	}
@@ -3994,8 +3997,6 @@ static int bcm43xx_init_private(struct b
 				struct net_device *net_dev,
 				struct pci_dev *pci_dev)
 {
-	int err;
-
 	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
 	bcm->ieee = netdev_priv(net_dev);
 	bcm->softmac = ieee80211_priv(net_dev);
@@ -4013,22 +4014,8 @@ static int bcm43xx_init_private(struct b
 		     (void (*)(unsigned long))bcm43xx_interrupt_tasklet,
 		     (unsigned long)bcm);
 	tasklet_disable_nosync(&bcm->isr_tasklet);
-	if (modparam_pio) {
+	if (modparam_pio)
 		bcm->__using_pio = 1;
-	} else {
-		err = pci_set_dma_mask(pci_dev, DMA_30BIT_MASK);
-		err |= pci_set_consistent_dma_mask(pci_dev, DMA_30BIT_MASK);
-		if (err) {
-#ifdef CONFIG_BCM43XX_PIO
-			printk(KERN_WARNING PFX "DMA not supported. Falling back to PIO.\n");
-			bcm->__using_pio = 1;
-#else
-			printk(KERN_ERR PFX "FATAL: DMA not supported and PIO not configured. "
-					    "Recompile the driver with PIO support, please.\n");
-			return -ENODEV;
-#endif /* CONFIG_BCM43XX_PIO */
-		}
-	}
 	bcm->rts_threshold = BCM43xx_DEFAULT_RTS_THRESHOLD;
 
 	/* default to sw encryption for now */
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
@@ -705,11 +705,30 @@ int bcm43xx_dma_init(struct bcm43xx_priv
 	struct bcm43xx_dmaring *ring;
 	int err = -ENOMEM;
 	int dma64 = 0;
-	u32 sbtmstatehi;
+	u64 mask = bcm43xx_get_supported_dma_mask(bcm);
+	int nobits;
 
-	sbtmstatehi = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATEHIGH);
-	if (sbtmstatehi & BCM43xx_SBTMSTATEHIGH_DMA64BIT)
+	if (mask == DMA_64BIT_MASK) {
 		dma64 = 1;
+		nobits = 64;
+	} else if (mask == DMA_32BIT_MASK)
+		nobits = 32;
+	else
+		nobits = 30;
+	err = pci_set_dma_mask(bcm->pci_dev, mask);
+	err |= pci_set_consistent_dma_mask(bcm->pci_dev, mask);
+	if (err) {
+#ifdef CONFIG_BCM43XX_PIO
+		printk(KERN_WARNING PFX "DMA not supported on this device."
+					" Falling back to PIO.\n");
+		bcm->__using_pio = 1;
+		return -ENOSYS;
+#else
+		printk(KERN_ERR PFX "FATAL: DMA not supported and PIO not configured. "
+				    "Please recompile the driver with PIO support.\n");
+		return -ENODEV;
+#endif /* CONFIG_BCM43XX_PIO */
+	}
 
 	/* setup TX DMA channels. */
 	ring = bcm43xx_setup_dmaring(bcm, 0, 1, dma64);
@@ -755,8 +774,7 @@ int bcm43xx_dma_init(struct bcm43xx_priv
 		dma->rx_ring3 = ring;
 	}
 
-	dprintk(KERN_INFO PFX "%s DMA initialized\n",
-			dma64 ? "64-bit" : "32-bit");
+	dprintk(KERN_INFO PFX "%d-bit DMA initialized\n", nobits);
 	err = 0;
 out:
 	return err;

====
