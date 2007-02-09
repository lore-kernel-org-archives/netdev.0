From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull "upstream" branch of wireless-2.6
Date: Fri, 9 Feb 2007 15:13:06 -0500
Message-ID: <20070209201306.GA2580@tuxdriver.com>
References: <20070202212747.GC9382@tuxdriver.com> <45C917EF.1060307@garzik.org> <20070207211117.GC6109@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070207211117.GC6109-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 07, 2007 at 04:11:17PM -0500, John W. Linville wrote:
> On Tue, Feb 06, 2007 at 07:06:07PM -0500, Jeff Garzik wrote:
> > Would you mind rebasing & resending, kind sir?
> 
> By your command! :-)

And once more, now with feeling! :-)

---

The following changes since commit 62d0cfcb27cf755cebdc93ca95dabc83608007cd:
  Linus Torvalds (1):
        Linux 2.6.20

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Daniel Drake (1):
      zd1211rw: Remove noisy debug message

Larry Finger (5):
      bcm43xx: Fix problem with >1 GB RAM
      bcm43xx: Fix scaling error for 'iwlist rate' information
      bcm43xx: Fix scaling error for 'iwlist freq' information
      bcm43xx: Check error returns in initialization routines
      ieee80211: Fix sparse warning

Maxime Austruy (1):
      zd1211rw: fix potential leak in usb_init

Michael Buesch (1):
      bcm43xx: Enable fwpostfix in nondebug bcm43xx

Robert P. J. Day (2):
      Rename IPW2100 debugging macros to not look like config options.
      Replace incorrect macro name "WIRELESS_EXT" with "CONFIG_WIRELESS_EXT"

Ulrich Kunitz (3):
      zd1211rw: Reset device in the probe call
      zd1211rw: Fixed array size issue in reset_mode
      zd1211rw: Added error stats update

 drivers/net/wireless/bcm43xx/bcm43xx.h      |    1 +
 drivers/net/wireless/bcm43xx/bcm43xx_dma.c  |  171 +++++++++++++++++++--------
 drivers/net/wireless/bcm43xx/bcm43xx_main.c |   25 +++--
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c   |   28 ++--
 drivers/net/wireless/ipw2100.c              |   16 ++--
 drivers/net/wireless/zd1211rw/zd_mac.c      |   44 ++++++--
 drivers/net/wireless/zd1211rw/zd_usb.c      |   12 ++
 net/core/net-sysfs.c                        |    4 +-
 net/ieee80211/ieee80211_tx.c                |    3 -
 9 files changed, 210 insertions(+), 94 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index 8286678..4168b1a 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -766,6 +766,7 @@ struct bcm43xx_private {
 	 * This is currently always BCM43xx_BUSTYPE_PCI
 	 */
 	u8 bustype;
+	u64 dma_mask;
 
 	u16 board_vendor;
 	u16 board_type;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_dma.c b/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
index 978ed09..6e0dc76 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
@@ -145,16 +145,14 @@ dma_addr_t map_descbuffer(struct bcm43xx_dmaring *ring,
 			  int tx)
 {
 	dma_addr_t dmaaddr;
+	int direction = PCI_DMA_FROMDEVICE;
 
-	if (tx) {
-		dmaaddr = dma_map_single(&ring->bcm->pci_dev->dev,
-					 buf, len,
-					 DMA_TO_DEVICE);
-	} else {
-		dmaaddr = dma_map_single(&ring->bcm->pci_dev->dev,
+	if (tx)
+		direction = PCI_DMA_TODEVICE;
+
+	dmaaddr = pci_map_single(ring->bcm->pci_dev,
 					 buf, len,
-					 DMA_FROM_DEVICE);
-	}
+					 direction);
 
 	return dmaaddr;
 }
@@ -166,13 +164,13 @@ void unmap_descbuffer(struct bcm43xx_dmaring *ring,
 		      int tx)
 {
 	if (tx) {
-		dma_unmap_single(&ring->bcm->pci_dev->dev,
+		pci_unmap_single(ring->bcm->pci_dev,
 				 addr, len,
-				 DMA_TO_DEVICE);
+				 PCI_DMA_TODEVICE);
 	} else {
-		dma_unmap_single(&ring->bcm->pci_dev->dev,
+		pci_unmap_single(ring->bcm->pci_dev,
 				 addr, len,
-				 DMA_FROM_DEVICE);
+				 PCI_DMA_FROMDEVICE);
 	}
 }
 
@@ -183,8 +181,8 @@ void sync_descbuffer_for_cpu(struct bcm43xx_dmaring *ring,
 {
 	assert(!ring->tx);
 
-	dma_sync_single_for_cpu(&ring->bcm->pci_dev->dev,
-				addr, len, DMA_FROM_DEVICE);
+	pci_dma_sync_single_for_cpu(ring->bcm->pci_dev,
+				    addr, len, PCI_DMA_FROMDEVICE);
 }
 
 static inline
@@ -194,8 +192,8 @@ void sync_descbuffer_for_device(struct bcm43xx_dmaring *ring,
 {
 	assert(!ring->tx);
 
-	dma_sync_single_for_device(&ring->bcm->pci_dev->dev,
-				   addr, len, DMA_FROM_DEVICE);
+	pci_dma_sync_single_for_cpu(ring->bcm->pci_dev,
+				    addr, len, PCI_DMA_TODEVICE);
 }
 
 /* Unmap and free a descriptor buffer. */
@@ -214,17 +212,53 @@ void free_descriptor_buffer(struct bcm43xx_dmaring *ring,
 
 static int alloc_ringmemory(struct bcm43xx_dmaring *ring)
 {
-	struct device *dev = &(ring->bcm->pci_dev->dev);
-
-	ring->descbase = dma_alloc_coherent(dev, BCM43xx_DMA_RINGMEMSIZE,
-					    &(ring->dmabase), GFP_KERNEL);
+	ring->descbase = pci_alloc_consistent(ring->bcm->pci_dev, BCM43xx_DMA_RINGMEMSIZE,
+					    &(ring->dmabase));
 	if (!ring->descbase) {
-		printk(KERN_ERR PFX "DMA ringmemory allocation failed\n");
-		return -ENOMEM;
+		/* Allocation may have failed due to pci_alloc_consistent
+		   insisting on use of GFP_DMA, which is more restrictive
+		   than necessary...  */
+		struct dma_desc *rx_ring;
+		dma_addr_t rx_ring_dma;
+
+		rx_ring = kzalloc(BCM43xx_DMA_RINGMEMSIZE, GFP_KERNEL);
+		if (!rx_ring)
+			goto out_err;
+
+		rx_ring_dma = pci_map_single(ring->bcm->pci_dev, rx_ring,
+					     BCM43xx_DMA_RINGMEMSIZE,
+					     PCI_DMA_BIDIRECTIONAL);
+
+		if (pci_dma_mapping_error(rx_ring_dma) ||
+		    rx_ring_dma + BCM43xx_DMA_RINGMEMSIZE > ring->bcm->dma_mask) {
+			/* Sigh... */
+			if (!pci_dma_mapping_error(rx_ring_dma))
+				pci_unmap_single(ring->bcm->pci_dev,
+						 rx_ring_dma, BCM43xx_DMA_RINGMEMSIZE,
+						 PCI_DMA_BIDIRECTIONAL);
+			rx_ring_dma = pci_map_single(ring->bcm->pci_dev,
+						 rx_ring, BCM43xx_DMA_RINGMEMSIZE,
+						 PCI_DMA_BIDIRECTIONAL);
+			if (pci_dma_mapping_error(rx_ring_dma) ||
+			    rx_ring_dma + BCM43xx_DMA_RINGMEMSIZE > ring->bcm->dma_mask) {
+				assert(0);
+				if (!pci_dma_mapping_error(rx_ring_dma))
+					pci_unmap_single(ring->bcm->pci_dev,
+							 rx_ring_dma, BCM43xx_DMA_RINGMEMSIZE,
+							 PCI_DMA_BIDIRECTIONAL);
+				goto out_err;
+			}
+                }
+
+                ring->descbase = rx_ring;
+                ring->dmabase = rx_ring_dma;
 	}
 	memset(ring->descbase, 0, BCM43xx_DMA_RINGMEMSIZE);
 
 	return 0;
+out_err:
+	printk(KERN_ERR PFX "DMA ringmemory allocation failed\n");
+	return -ENOMEM;
 }
 
 static void free_ringmemory(struct bcm43xx_dmaring *ring)
@@ -407,6 +441,29 @@ static int setup_rx_descbuffer(struct bcm43xx_dmaring *ring,
 	if (unlikely(!skb))
 		return -ENOMEM;
 	dmaaddr = map_descbuffer(ring, skb->data, ring->rx_buffersize, 0);
+	/* This hardware bug work-around adapted from the b44 driver.
+	   The chip may be unable to do PCI DMA to/from anything above 1GB */
+	if (pci_dma_mapping_error(dmaaddr) ||
+	    dmaaddr + ring->rx_buffersize > ring->bcm->dma_mask) {
+		/* This one has 30-bit addressing... */
+		if (!pci_dma_mapping_error(dmaaddr))
+			pci_unmap_single(ring->bcm->pci_dev,
+					 dmaaddr, ring->rx_buffersize,
+					 PCI_DMA_FROMDEVICE);
+		dev_kfree_skb_any(skb);
+		skb = __dev_alloc_skb(ring->rx_buffersize,GFP_DMA);
+		if (skb == NULL)
+			return -ENOMEM;
+		dmaaddr = pci_map_single(ring->bcm->pci_dev,
+					 skb->data, ring->rx_buffersize,
+					 PCI_DMA_FROMDEVICE);
+		if (pci_dma_mapping_error(dmaaddr) ||
+		    dmaaddr + ring->rx_buffersize > ring->bcm->dma_mask) {
+			assert(0);
+			dev_kfree_skb_any(skb);
+			return -ENOMEM;
+		}
+	}
 	meta->skb = skb;
 	meta->dmaaddr = dmaaddr;
 	skb->dev = ring->bcm->net_dev;
@@ -636,8 +693,10 @@ struct bcm43xx_dmaring * bcm43xx_setup_dmaring(struct bcm43xx_private *bcm,
 	err = dmacontroller_setup(ring);
 	if (err)
 		goto err_free_ringmemory;
+	return ring;
 
 out:
+	printk(KERN_ERR PFX "Error in bcm43xx_setup_dmaring\n");
 	return ring;
 
 err_free_ringmemory:
@@ -705,30 +764,16 @@ int bcm43xx_dma_init(struct bcm43xx_private *bcm)
 	struct bcm43xx_dmaring *ring;
 	int err = -ENOMEM;
 	int dma64 = 0;
-	u64 mask = bcm43xx_get_supported_dma_mask(bcm);
-	int nobits;
 
-	if (mask == DMA_64BIT_MASK) {
+	bcm->dma_mask = bcm43xx_get_supported_dma_mask(bcm);
+	if (bcm->dma_mask == DMA_64BIT_MASK)
 		dma64 = 1;
-		nobits = 64;
-	} else if (mask == DMA_32BIT_MASK)
-		nobits = 32;
-	else
-		nobits = 30;
-	err = pci_set_dma_mask(bcm->pci_dev, mask);
-	err |= pci_set_consistent_dma_mask(bcm->pci_dev, mask);
-	if (err) {
-#ifdef CONFIG_BCM43XX_PIO
-		printk(KERN_WARNING PFX "DMA not supported on this device."
-					" Falling back to PIO.\n");
-		bcm->__using_pio = 1;
-		return -ENOSYS;
-#else
-		printk(KERN_ERR PFX "FATAL: DMA not supported and PIO not configured. "
-				    "Please recompile the driver with PIO support.\n");
-		return -ENODEV;
-#endif /* CONFIG_BCM43XX_PIO */
-	}
+	err = pci_set_dma_mask(bcm->pci_dev, bcm->dma_mask);
+	if (err)
+		goto no_dma;
+	err = pci_set_consistent_dma_mask(bcm->pci_dev, bcm->dma_mask);
+	if (err)
+		goto no_dma;
 
 	/* setup TX DMA channels. */
 	ring = bcm43xx_setup_dmaring(bcm, 0, 1, dma64);
@@ -774,7 +819,9 @@ int bcm43xx_dma_init(struct bcm43xx_private *bcm)
 		dma->rx_ring3 = ring;
 	}
 
-	dprintk(KERN_INFO PFX "%d-bit DMA initialized\n", nobits);
+	dprintk(KERN_INFO PFX "%d-bit DMA initialized\n",
+		(bcm->dma_mask == DMA_64BIT_MASK) ? 64 :
+		(bcm->dma_mask == DMA_32BIT_MASK) ? 32 : 30);
 	err = 0;
 out:
 	return err;
@@ -800,7 +847,17 @@ err_destroy_tx1:
 err_destroy_tx0:
 	bcm43xx_destroy_dmaring(dma->tx_ring0);
 	dma->tx_ring0 = NULL;
-	goto out;
+no_dma:
+#ifdef CONFIG_BCM43XX_PIO
+	printk(KERN_WARNING PFX "DMA not supported on this device."
+				" Falling back to PIO.\n");
+	bcm->__using_pio = 1;
+	return -ENOSYS;
+#else
+	printk(KERN_ERR PFX "FATAL: DMA not supported and PIO not configured. "
+			    "Please recompile the driver with PIO support.\n");
+	return -ENODEV;
+#endif /* CONFIG_BCM43XX_PIO */
 }
 
 /* Generate a cookie for the TX header. */
@@ -905,6 +962,7 @@ static void dma_tx_fragment(struct bcm43xx_dmaring *ring,
 	struct bcm43xx_dmadesc_generic *desc;
 	struct bcm43xx_dmadesc_meta *meta;
 	dma_addr_t dmaaddr;
+	struct sk_buff *bounce_skb;
 
 	assert(skb_shinfo(skb)->nr_frags == 0);
 
@@ -924,9 +982,28 @@ static void dma_tx_fragment(struct bcm43xx_dmaring *ring,
 			       skb->len - sizeof(struct bcm43xx_txhdr),
 			       (cur_frag == 0),
 			       generate_cookie(ring, slot));
+	dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
+	if (dma_mapping_error(dmaaddr) || dmaaddr + skb->len > ring->bcm->dma_mask) {
+		/* chip cannot handle DMA to/from > 1GB, use bounce buffer (copied from b44 driver) */
+		if (!dma_mapping_error(dmaaddr))
+			unmap_descbuffer(ring, dmaaddr, skb->len, 1);
+		bounce_skb = __dev_alloc_skb(skb->len, GFP_ATOMIC|GFP_DMA);
+		if (!bounce_skb)
+			return;
+		dmaaddr = map_descbuffer(ring, bounce_skb->data, bounce_skb->len, 1);
+		if (dma_mapping_error(dmaaddr) || dmaaddr + skb->len > ring->bcm->dma_mask) {
+			if (!dma_mapping_error(dmaaddr))
+				unmap_descbuffer(ring, dmaaddr, skb->len, 1);
+			dev_kfree_skb_any(bounce_skb);
+			assert(0);
+			return;
+		}
+		memcpy(skb_put(bounce_skb, skb->len), skb->data, skb->len);
+		dev_kfree_skb_any(skb);
+		skb = bounce_skb;
+	}
 
 	meta->skb = skb;
-	dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
 	meta->dmaaddr = dmaaddr;
 
 	fill_descriptor(ring, desc, dmaaddr,
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 91b752e..63fc16f 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -95,13 +95,9 @@ static int modparam_noleds;
 module_param_named(noleds, modparam_noleds, int, 0444);
 MODULE_PARM_DESC(noleds, "Turn off all LED activity");
 
-#ifdef CONFIG_BCM43XX_DEBUG
 static char modparam_fwpostfix[64];
 module_param_string(fwpostfix, modparam_fwpostfix, 64, 0444);
-MODULE_PARM_DESC(fwpostfix, "Postfix for .fw files. Useful for debugging.");
-#else
-# define modparam_fwpostfix  ""
-#endif /* CONFIG_BCM43XX_DEBUG*/
+MODULE_PARM_DESC(fwpostfix, "Postfix for .fw files. Useful for using multiple firmware image versions.");
 
 
 /* If you want to debug with just a single device, enable this,
@@ -2980,8 +2976,10 @@ static int bcm43xx_chipset_attach(struct bcm43xx_private *bcm)
 	err = bcm43xx_pctl_set_crystal(bcm, 1);
 	if (err)
 		goto out;
-	bcm43xx_pci_read_config16(bcm, PCI_STATUS, &pci_status);
-	bcm43xx_pci_write_config16(bcm, PCI_STATUS, pci_status & ~PCI_STATUS_SIG_TARGET_ABORT);
+	err = bcm43xx_pci_read_config16(bcm, PCI_STATUS, &pci_status);
+	if (err)
+		goto out;
+	err = bcm43xx_pci_write_config16(bcm, PCI_STATUS, pci_status & ~PCI_STATUS_SIG_TARGET_ABORT);
 
 out:
 	return err;
@@ -3778,12 +3776,18 @@ static int bcm43xx_attach_board(struct bcm43xx_private *bcm)
 	}
 	net_dev->base_addr = (unsigned long)bcm->mmio_addr;
 
-	bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_VENDOR_ID,
+	err = bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_VENDOR_ID,
 	                          &bcm->board_vendor);
-	bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_ID,
+	if (err)
+		goto err_iounmap;
+	err = bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_ID,
 	                          &bcm->board_type);
-	bcm43xx_pci_read_config16(bcm, PCI_REVISION_ID,
+	if (err)
+		goto err_iounmap;
+	err = bcm43xx_pci_read_config16(bcm, PCI_REVISION_ID,
 	                          &bcm->board_revision);
+	if (err)
+		goto err_iounmap;
 
 	err = bcm43xx_chipset_attach(bcm);
 	if (err)
@@ -3874,6 +3878,7 @@ err_pci_release:
 	pci_release_regions(pci_dev);
 err_pci_disable:
 	pci_disable_device(pci_dev);
+	printk(KERN_ERR PFX "Unable to attach board\n");
 	goto out;
 }
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index a659442..6961be6 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -261,22 +261,22 @@ static int bcm43xx_wx_get_rangeparams(struct net_device *net_dev,
 	if (phy->type == BCM43xx_PHYTYPE_A ||
 	    phy->type == BCM43xx_PHYTYPE_G) {
 		range->num_bitrates = 8;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_6MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_9MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_12MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_18MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_24MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_36MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_48MB;
-		range->bitrate[i++] = IEEE80211_OFDM_RATE_54MB;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_6MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_9MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_12MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_18MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_24MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_36MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_48MB * 500000;
+		range->bitrate[i++] = IEEE80211_OFDM_RATE_54MB * 500000;
 	}
 	if (phy->type == BCM43xx_PHYTYPE_B ||
 	    phy->type == BCM43xx_PHYTYPE_G) {
 		range->num_bitrates += 4;
-		range->bitrate[i++] = IEEE80211_CCK_RATE_1MB;
-		range->bitrate[i++] = IEEE80211_CCK_RATE_2MB;
-		range->bitrate[i++] = IEEE80211_CCK_RATE_5MB;
-		range->bitrate[i++] = IEEE80211_CCK_RATE_11MB;
+		range->bitrate[i++] = IEEE80211_CCK_RATE_1MB * 500000;
+		range->bitrate[i++] = IEEE80211_CCK_RATE_2MB * 500000;
+		range->bitrate[i++] = IEEE80211_CCK_RATE_5MB * 500000;
+		range->bitrate[i++] = IEEE80211_CCK_RATE_11MB * 500000;
 	}
 
 	geo = ieee80211_get_geo(bcm->ieee);
@@ -286,7 +286,7 @@ static int bcm43xx_wx_get_rangeparams(struct net_device *net_dev,
 		if (j == IW_MAX_FREQUENCIES)
 			break;
 		range->freq[j].i = j + 1;
-		range->freq[j].m = geo->a[i].freq;//FIXME?
+		range->freq[j].m = geo->a[i].freq * 100000;
 		range->freq[j].e = 1;
 		j++;
 	}
@@ -294,7 +294,7 @@ static int bcm43xx_wx_get_rangeparams(struct net_device *net_dev,
 		if (j == IW_MAX_FREQUENCIES)
 			break;
 		range->freq[j].i = j + 1;
-		range->freq[j].m = geo->bg[i].freq;//FIXME?
+		range->freq[j].m = geo->bg[i].freq * 100000;
 		range->freq[j].e = 1;
 		j++;
 	}
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index b85857a..d0639a4 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -175,7 +175,7 @@ that only one external action is invoked at a time.
 
 /* Debugging stuff */
 #ifdef CONFIG_IPW2100_DEBUG
-#define CONFIG_IPW2100_RX_DEBUG	/* Reception debugging */
+#define IPW2100_RX_DEBUG	/* Reception debugging */
 #endif
 
 MODULE_DESCRIPTION(DRV_DESCRIPTION);
@@ -2239,7 +2239,7 @@ static void ipw2100_snapshot_free(struct ipw2100_priv *priv)
 	priv->snapshot[0] = NULL;
 }
 
-#ifdef CONFIG_IPW2100_DEBUG_C3
+#ifdef IPW2100_DEBUG_C3
 static int ipw2100_snapshot_alloc(struct ipw2100_priv *priv)
 {
 	int i;
@@ -2314,13 +2314,13 @@ static u32 ipw2100_match_buf(struct ipw2100_priv *priv, u8 * in_buf,
  * The size of the constructed ethernet
  *
  */
-#ifdef CONFIG_IPW2100_RX_DEBUG
+#ifdef IPW2100_RX_DEBUG
 static u8 packet_data[IPW_RX_NIC_BUFFER_LENGTH];
 #endif
 
 static void ipw2100_corruption_detected(struct ipw2100_priv *priv, int i)
 {
-#ifdef CONFIG_IPW2100_DEBUG_C3
+#ifdef IPW2100_DEBUG_C3
 	struct ipw2100_status *status = &priv->status_queue.drv[i];
 	u32 match, reg;
 	int j;
@@ -2342,7 +2342,7 @@ static void ipw2100_corruption_detected(struct ipw2100_priv *priv, int i)
 	}
 #endif
 
-#ifdef CONFIG_IPW2100_DEBUG_C3
+#ifdef IPW2100_DEBUG_C3
 	/* Halt the fimrware so we can get a good image */
 	write_register(priv->net_dev, IPW_REG_RESET_REG,
 		       IPW_AUX_HOST_RESET_REG_STOP_MASTER);
@@ -2413,7 +2413,7 @@ static void isr_rx(struct ipw2100_priv *priv, int i,
 
 	skb_put(packet->skb, status->frame_size);
 
-#ifdef CONFIG_IPW2100_RX_DEBUG
+#ifdef IPW2100_RX_DEBUG
 	/* Make a copy of the frame so we can dump it to the logs if
 	 * ieee80211_rx fails */
 	memcpy(packet_data, packet->skb->data,
@@ -2421,7 +2421,7 @@ static void isr_rx(struct ipw2100_priv *priv, int i,
 #endif
 
 	if (!ieee80211_rx(priv->ieee, packet->skb, stats)) {
-#ifdef CONFIG_IPW2100_RX_DEBUG
+#ifdef IPW2100_RX_DEBUG
 		IPW_DEBUG_DROP("%s: Non consumed packet:\n",
 			       priv->net_dev->name);
 		printk_buf(IPW_DL_DROP, packet_data, status->frame_size);
@@ -4912,7 +4912,7 @@ static int ipw2100_set_power_mode(struct ipw2100_priv *priv, int power_level)
 	else
 		priv->power_mode = IPW_POWER_ENABLED | power_level;
 
-#ifdef CONFIG_IPW2100_TX_POWER
+#ifdef IPW2100_TX_POWER
 	if (priv->port_type == IBSS && priv->adhoc_power != DFTL_IBSS_TX_POWER) {
 		/* Set beacon interval */
 		cmd.host_command = TX_POWER_INDEX;
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index a085241..4c5f78e 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -156,7 +156,7 @@ void zd_mac_clear(struct zd_mac *mac)
 static int reset_mode(struct zd_mac *mac)
 {
 	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
-	struct zd_ioreq32 ioreqs[3] = {
+	struct zd_ioreq32 ioreqs[] = {
 		{ CR_RX_FILTER, STA_RX_FILTER },
 		{ CR_SNIFFER_ON, 0U },
 	};
@@ -164,10 +164,9 @@ static int reset_mode(struct zd_mac *mac)
 	if (ieee->iw_mode == IW_MODE_MONITOR) {
 		ioreqs[0].value = 0xffffffff;
 		ioreqs[1].value = 0x1;
-		ioreqs[2].value = ENC_SNIFFER;
 	}
 
-	return zd_iowrite32a(&mac->chip, ioreqs, 3);
+	return zd_iowrite32a(&mac->chip, ioreqs, ARRAY_SIZE(ioreqs));
 }
 
 int zd_mac_open(struct net_device *netdev)
@@ -904,16 +903,21 @@ static int fill_ctrlset(struct zd_mac *mac,
 static int zd_mac_tx(struct zd_mac *mac, struct ieee80211_txb *txb, int pri)
 {
 	int i, r;
+	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 
 	for (i = 0; i < txb->nr_frags; i++) {
 		struct sk_buff *skb = txb->fragments[i];
 
 		r = fill_ctrlset(mac, txb, i);
-		if (r)
+		if (r) {
+			ieee->stats.tx_dropped++;
 			return r;
+		}
 		r = zd_usb_tx(&mac->chip.usb, skb->data, skb->len);
-		if (r)
+		if (r) {
+			ieee->stats.tx_dropped++;
 			return r;
+		}
 	}
 
 	/* FIXME: shouldn't this be handled by the upper layers? */
@@ -1063,9 +1067,23 @@ static int fill_rx_stats(struct ieee80211_rx_stats *stats,
 
 	*pstatus = status = zd_tail(buffer, length, sizeof(struct rx_status));
 	if (status->frame_status & ZD_RX_ERROR) {
-		/* FIXME: update? */
+		struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
+		ieee->stats.rx_errors++;
+		if (status->frame_status & ZD_RX_TIMEOUT_ERROR)
+			ieee->stats.rx_missed_errors++;
+		else if (status->frame_status & ZD_RX_FIFO_OVERRUN_ERROR)
+			ieee->stats.rx_fifo_errors++;
+		else if (status->frame_status & ZD_RX_DECRYPTION_ERROR)
+			ieee->ieee_stats.rx_discards_undecryptable++;
+		else if (status->frame_status & ZD_RX_CRC32_ERROR) {
+			ieee->stats.rx_crc_errors++;
+			ieee->ieee_stats.rx_fcs_errors++;
+		}
+		else if (status->frame_status & ZD_RX_CRC16_ERROR)
+			ieee->stats.rx_crc_errors++;
 		return -EINVAL;
 	}
+
 	memset(stats, 0, sizeof(struct ieee80211_rx_stats));
 	stats->len = length - (ZD_PLCP_HEADER_SIZE + IEEE80211_FCS_LEN +
 		               + sizeof(struct rx_status));
@@ -1094,14 +1112,16 @@ static void zd_mac_rx(struct zd_mac *mac, struct sk_buff *skb)
 	if (skb->len < ZD_PLCP_HEADER_SIZE + IEEE80211_1ADDR_LEN +
 	               IEEE80211_FCS_LEN + sizeof(struct rx_status))
 	{
-		dev_dbg_f(zd_mac_dev(mac), "Packet with length %u to small.\n",
-			 skb->len);
+		ieee->stats.rx_errors++;
+		ieee->stats.rx_length_errors++;
 		goto free_skb;
 	}
 
 	r = fill_rx_stats(&stats, &status, mac, skb->data, skb->len);
 	if (r) {
-		/* Only packets with rx errors are included here. */
+		/* Only packets with rx errors are included here.
+		 * The error stats have already been set in fill_rx_stats.
+		 */
 		goto free_skb;
 	}
 
@@ -1114,8 +1134,10 @@ static void zd_mac_rx(struct zd_mac *mac, struct sk_buff *skb)
 
 	r = filter_rx(ieee, skb->data, skb->len, &stats);
 	if (r <= 0) {
-		if (r < 0)
+		if (r < 0) {
+			ieee->stats.rx_errors++;
 			dev_dbg_f(zd_mac_dev(mac), "Error in packet.\n");
+		}
 		goto free_skb;
 	}
 
@@ -1146,7 +1168,9 @@ int zd_mac_rx_irq(struct zd_mac *mac, const u8 *buffer, unsigned int length)
 
 	skb = dev_alloc_skb(sizeof(struct zd_rt_hdr) + length);
 	if (!skb) {
+		struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 		dev_warn(zd_mac_dev(mac), "Could not allocate skb.\n");
+		ieee->stats.rx_dropped++;
 		return -ENOMEM;
 	}
 	skb_reserve(skb, sizeof(struct zd_rt_hdr));
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 605e96e..a3217a8 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -401,6 +401,12 @@ out:
 
 static inline void handle_retry_failed_int(struct urb *urb)
 {
+	struct zd_usb *usb = urb->context;
+	struct zd_mac *mac = zd_usb_to_mac(usb);
+	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
+
+	ieee->stats.tx_errors++;
+	ieee->ieee_stats.tx_retry_limit_exceeded++;
 	dev_dbg_f(urb_dev(urb), "retry failed interrupt\n");
 }
 
@@ -575,6 +581,9 @@ static void handle_rx_packet(struct zd_usb *usb, const u8 *buffer,
 
 	if (length < sizeof(struct rx_length_info)) {
 		/* It's not a complete packet anyhow. */
+		struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
+		ieee->stats.rx_errors++;
+		ieee->stats.rx_length_errors++;
 		return;
 	}
 	length_info = (struct rx_length_info *)
@@ -1027,6 +1036,8 @@ static int probe(struct usb_interface *intf, const struct usb_device_id *id)
 		goto error;
 	}
 
+	usb_reset_device(interface_to_usbdev(intf));
+
 	netdev = zd_netdev_alloc(intf);
 	if (netdev == NULL) {
 		r = -ENOMEM;
@@ -1128,6 +1139,7 @@ static int __init usb_init(void)
 
 	r = usb_register(&driver);
 	if (r) {
+		destroy_workqueue(zd_workqueue);
 		printk(KERN_ERR "%s usb_register() failed. Error number %d\n",
 		       driver.name, r);
 		return r;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index f47f319..44e69a2 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -329,7 +329,7 @@ static struct attribute_group netstat_group = {
 	.attrs  = netstat_attrs,
 };
 
-#ifdef WIRELESS_EXT
+#ifdef CONFIG_WIRELESS_EXT
 /* helper function that does all the locking etc for wireless stats */
 static ssize_t wireless_show(struct class_device *cd, char *buf,
 			     ssize_t (*format)(const struct iw_statistics *,
@@ -462,7 +462,7 @@ int netdev_register_sysfs(struct net_device *net)
 	if (net->get_stats)
 		*groups++ = &netstat_group;
 
-#ifdef WIRELESS_EXT
+#ifdef CONFIG_WIRELESS_EXT
 	if (net->wireless_handlers && net->wireless_handlers->get_wireless_stats)
 		*groups++ = &wireless_group;
 #endif
diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index 854fc13..54e0116 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -502,9 +502,6 @@ int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (host_encrypt)
 			ieee80211_encrypt_fragment(ieee, skb_frag, hdr_len);
 		else if (host_build_iv) {
-			struct ieee80211_crypt_data *crypt;
-
-			crypt = ieee->crypt[ieee->tx_keyidx];
 			atomic_inc(&crypt->refcnt);
 			if (crypt->ops->build_iv)
 				crypt->ops->build_iv(skb_frag, hdr_len,
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
