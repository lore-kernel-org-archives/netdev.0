From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-04-15
Date: Tue, 15 Apr 2008 15:38:57 -0400
Message-ID: <20080415193857.GA16625@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764427AbYDOT7h@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

This set looks bigger than it really is...three of the patches deal
with a subtle API change for the SSB bus to do DMA correctly on
architectures with complex DMA requirements.  The changes in those
patches amount to applying the same one-line change in dozens of
places across three drivers (b44, b43, and b43legacy).

Also included are a number of MAINTAINERS updates.  I guess everyone
forgets about these until the release nears.

Finally there are a few minor fixes, like the rfkill fix to only toggle
state for the correct device type rather than all devices on a system,
the rtl8187 priv->vif fix, the gelic IE overrun fix, and the mac80211
fix to limit log SPAM.

Please let me know if there are problems!  Hopefully this will be the
last round before 2.6.25...(famous last words...)

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 56690c2151d33534f0537fd03c533eda81d96f0f:
  Oliver Hartkopp (1):
        [CAN]: Update documentation of struct sockaddr_can

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git

Carlos Corbacho (1):
      rfkill: Fix device type check when toggling states

Herton Ronaldo Krzesinski (1):
      rtl8187: Add missing priv->vif assignments

Ivo van Doorn (2):
      Add rfkill to MAINTAINERS file
      Update rt2x00 MAINTAINERS entry

Johannes Berg (1):
      mac80211: remove message on receiving unexpected unencrypted frames

Masakazu Mokuno (1):
      PS3: gelic: fix the oops on the broken IE returned from the hypervisor

Michael Buesch (2):
      ssb: Fix usage of struct device used for DMAing
      b43legacy: Fix usage of struct device used for DMAing

Reinette Chatre (1):
      MAINTAINERS: move to generic repository for iwlwifi

Stefano Brivio (2):
      b43legacy: fix initvals loading on bcm4303
      b43legacy: fix DMA mapping leakage

 MAINTAINERS                           |   10 +++++-
 drivers/net/b44.c                     |   52 +++++++++++++++---------------
 drivers/net/ps3_gelic_wireless.c      |   11 +++++--
 drivers/net/wireless/b43/dma.c        |   27 ++++++++--------
 drivers/net/wireless/b43legacy/dma.c  |   55 ++++++++++++++++++--------------
 drivers/net/wireless/b43legacy/main.c |    2 +
 drivers/net/wireless/rtl8187_dev.c    |    3 ++
 drivers/ssb/main.c                    |   14 +++++---
 include/linux/ssb/ssb.h               |    4 ++
 net/mac80211/rx.c                     |    7 +---
 net/rfkill/rfkill.c                   |    2 +-
 11 files changed, 108 insertions(+), 79 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 23e1799..e467758 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2116,7 +2116,7 @@ M:	reinette.chatre@intel.com
 L:	linux-wireless@vger.kernel.org
 L:	ipw3945-devel@lists.sourceforge.net
 W:	http://intellinuxwireless.org
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/rchatre/iwlwifi-2.6.git
+T:	git kernel.org:/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-2.6.git
 S:	Supported
 
 IOC3 ETHERNET DRIVER
@@ -3280,6 +3280,7 @@ L:	linux-wireless@vger.kernel.org
 L:	rt2400-devel@lists.sourceforge.net
 W:	http://rt2x00.serialmonkey.com/
 S:	Maintained
+T:	git kernel.org:/pub/scm/linux/kernel/git/ivd/rt2x00.git
 F:	drivers/net/wireless/rt2x00/
 
 RAMDISK RAM BLOCK DEVICE DRIVER
@@ -3342,6 +3343,13 @@ L:	reiserfs-devel@vger.kernel.org
 W:	http://www.namesys.com
 S:	Supported
 
+RFKILL
+P:	Ivo van Doorn
+M:	IvDoorn@gmail.com
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	net/rfkill
+
 ROCKETPORT DRIVER
 P:	Comtrol Corp.
 W:	http://www.comtrol.com
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 25f1337..59dce6a 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -148,7 +148,7 @@ static inline void b44_sync_dma_desc_for_device(struct ssb_device *sdev,
 						unsigned long offset,
 						enum dma_data_direction dir)
 {
-	dma_sync_single_range_for_device(sdev->dev, dma_base,
+	dma_sync_single_range_for_device(sdev->dma_dev, dma_base,
 					 offset & dma_desc_align_mask,
 					 dma_desc_sync_size, dir);
 }
@@ -158,7 +158,7 @@ static inline void b44_sync_dma_desc_for_cpu(struct ssb_device *sdev,
 					     unsigned long offset,
 					     enum dma_data_direction dir)
 {
-	dma_sync_single_range_for_cpu(sdev->dev, dma_base,
+	dma_sync_single_range_for_cpu(sdev->dma_dev, dma_base,
 				      offset & dma_desc_align_mask,
 				      dma_desc_sync_size, dir);
 }
@@ -613,7 +613,7 @@ static void b44_tx(struct b44 *bp)
 
 		BUG_ON(skb == NULL);
 
-		dma_unmap_single(bp->sdev->dev,
+		dma_unmap_single(bp->sdev->dma_dev,
 				 rp->mapping,
 				 skb->len,
 				 DMA_TO_DEVICE);
@@ -653,7 +653,7 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 	if (skb == NULL)
 		return -ENOMEM;
 
-	mapping = dma_map_single(bp->sdev->dev, skb->data,
+	mapping = dma_map_single(bp->sdev->dma_dev, skb->data,
 				 RX_PKT_BUF_SZ,
 				 DMA_FROM_DEVICE);
 
@@ -663,19 +663,19 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 		mapping + RX_PKT_BUF_SZ > DMA_30BIT_MASK) {
 		/* Sigh... */
 		if (!dma_mapping_error(mapping))
-			dma_unmap_single(bp->sdev->dev, mapping,
+			dma_unmap_single(bp->sdev->dma_dev, mapping,
 					RX_PKT_BUF_SZ, DMA_FROM_DEVICE);
 		dev_kfree_skb_any(skb);
 		skb = __netdev_alloc_skb(bp->dev, RX_PKT_BUF_SZ, GFP_ATOMIC|GFP_DMA);
 		if (skb == NULL)
 			return -ENOMEM;
-		mapping = dma_map_single(bp->sdev->dev, skb->data,
+		mapping = dma_map_single(bp->sdev->dma_dev, skb->data,
 					 RX_PKT_BUF_SZ,
 					 DMA_FROM_DEVICE);
 		if (dma_mapping_error(mapping) ||
 			mapping + RX_PKT_BUF_SZ > DMA_30BIT_MASK) {
 			if (!dma_mapping_error(mapping))
-				dma_unmap_single(bp->sdev->dev, mapping, RX_PKT_BUF_SZ,DMA_FROM_DEVICE);
+				dma_unmap_single(bp->sdev->dma_dev, mapping, RX_PKT_BUF_SZ,DMA_FROM_DEVICE);
 			dev_kfree_skb_any(skb);
 			return -ENOMEM;
 		}
@@ -750,7 +750,7 @@ static void b44_recycle_rx(struct b44 *bp, int src_idx, u32 dest_idx_unmasked)
 					     dest_idx * sizeof(dest_desc),
 					     DMA_BIDIRECTIONAL);
 
-	dma_sync_single_for_device(bp->sdev->dev, le32_to_cpu(src_desc->addr),
+	dma_sync_single_for_device(bp->sdev->dma_dev, le32_to_cpu(src_desc->addr),
 				   RX_PKT_BUF_SZ,
 				   DMA_FROM_DEVICE);
 }
@@ -772,7 +772,7 @@ static int b44_rx(struct b44 *bp, int budget)
 		struct rx_header *rh;
 		u16 len;
 
-		dma_sync_single_for_cpu(bp->sdev->dev, map,
+		dma_sync_single_for_cpu(bp->sdev->dma_dev, map,
 					    RX_PKT_BUF_SZ,
 					    DMA_FROM_DEVICE);
 		rh = (struct rx_header *) skb->data;
@@ -806,7 +806,7 @@ static int b44_rx(struct b44 *bp, int budget)
 			skb_size = b44_alloc_rx_skb(bp, cons, bp->rx_prod);
 			if (skb_size < 0)
 				goto drop_it;
-			dma_unmap_single(bp->sdev->dev, map,
+			dma_unmap_single(bp->sdev->dma_dev, map,
 					 skb_size, DMA_FROM_DEVICE);
 			/* Leave out rx_header */
                 	skb_put(skb, len + RX_PKT_OFFSET);
@@ -966,24 +966,24 @@ static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto err_out;
 	}
 
-	mapping = dma_map_single(bp->sdev->dev, skb->data, len, DMA_TO_DEVICE);
+	mapping = dma_map_single(bp->sdev->dma_dev, skb->data, len, DMA_TO_DEVICE);
 	if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
 		struct sk_buff *bounce_skb;
 
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
 		if (!dma_mapping_error(mapping))
-			dma_unmap_single(bp->sdev->dev, mapping, len,
+			dma_unmap_single(bp->sdev->dma_dev, mapping, len,
 					DMA_TO_DEVICE);
 
 		bounce_skb = __dev_alloc_skb(len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb)
 			goto err_out;
 
-		mapping = dma_map_single(bp->sdev->dev, bounce_skb->data,
+		mapping = dma_map_single(bp->sdev->dma_dev, bounce_skb->data,
 					 len, DMA_TO_DEVICE);
 		if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
 			if (!dma_mapping_error(mapping))
-				dma_unmap_single(bp->sdev->dev, mapping,
+				dma_unmap_single(bp->sdev->dma_dev, mapping,
 					 len, DMA_TO_DEVICE);
 			dev_kfree_skb_any(bounce_skb);
 			goto err_out;
@@ -1082,7 +1082,7 @@ static void b44_free_rings(struct b44 *bp)
 
 		if (rp->skb == NULL)
 			continue;
-		dma_unmap_single(bp->sdev->dev, rp->mapping, RX_PKT_BUF_SZ,
+		dma_unmap_single(bp->sdev->dma_dev, rp->mapping, RX_PKT_BUF_SZ,
 					DMA_FROM_DEVICE);
 		dev_kfree_skb_any(rp->skb);
 		rp->skb = NULL;
@@ -1094,7 +1094,7 @@ static void b44_free_rings(struct b44 *bp)
 
 		if (rp->skb == NULL)
 			continue;
-		dma_unmap_single(bp->sdev->dev, rp->mapping, rp->skb->len,
+		dma_unmap_single(bp->sdev->dma_dev, rp->mapping, rp->skb->len,
 					DMA_TO_DEVICE);
 		dev_kfree_skb_any(rp->skb);
 		rp->skb = NULL;
@@ -1117,12 +1117,12 @@ static void b44_init_rings(struct b44 *bp)
 	memset(bp->tx_ring, 0, B44_TX_RING_BYTES);
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
-		dma_sync_single_for_device(bp->sdev->dev, bp->rx_ring_dma,
+		dma_sync_single_for_device(bp->sdev->dma_dev, bp->rx_ring_dma,
 			                  DMA_TABLE_BYTES,
 			                  DMA_BIDIRECTIONAL);
 
 	if (bp->flags & B44_FLAG_TX_RING_HACK)
-		dma_sync_single_for_device(bp->sdev->dev, bp->tx_ring_dma,
+		dma_sync_single_for_device(bp->sdev->dma_dev, bp->tx_ring_dma,
 			                  DMA_TABLE_BYTES,
 			                  DMA_TO_DEVICE);
 
@@ -1144,24 +1144,24 @@ static void b44_free_consistent(struct b44 *bp)
 	bp->tx_buffers = NULL;
 	if (bp->rx_ring) {
 		if (bp->flags & B44_FLAG_RX_RING_HACK) {
-			dma_unmap_single(bp->sdev->dev, bp->rx_ring_dma,
+			dma_unmap_single(bp->sdev->dma_dev, bp->rx_ring_dma,
 					DMA_TABLE_BYTES,
 					DMA_BIDIRECTIONAL);
 			kfree(bp->rx_ring);
 		} else
-			dma_free_coherent(bp->sdev->dev, DMA_TABLE_BYTES,
+			dma_free_coherent(bp->sdev->dma_dev, DMA_TABLE_BYTES,
 					    bp->rx_ring, bp->rx_ring_dma);
 		bp->rx_ring = NULL;
 		bp->flags &= ~B44_FLAG_RX_RING_HACK;
 	}
 	if (bp->tx_ring) {
 		if (bp->flags & B44_FLAG_TX_RING_HACK) {
-			dma_unmap_single(bp->sdev->dev, bp->tx_ring_dma,
+			dma_unmap_single(bp->sdev->dma_dev, bp->tx_ring_dma,
 					DMA_TABLE_BYTES,
 					DMA_TO_DEVICE);
 			kfree(bp->tx_ring);
 		} else
-			dma_free_coherent(bp->sdev->dev, DMA_TABLE_BYTES,
+			dma_free_coherent(bp->sdev->dma_dev, DMA_TABLE_BYTES,
 					    bp->tx_ring, bp->tx_ring_dma);
 		bp->tx_ring = NULL;
 		bp->flags &= ~B44_FLAG_TX_RING_HACK;
@@ -1187,7 +1187,7 @@ static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 		goto out_err;
 
 	size = DMA_TABLE_BYTES;
-	bp->rx_ring = dma_alloc_coherent(bp->sdev->dev, size, &bp->rx_ring_dma, gfp);
+	bp->rx_ring = dma_alloc_coherent(bp->sdev->dma_dev, size, &bp->rx_ring_dma, gfp);
 	if (!bp->rx_ring) {
 		/* Allocation may have failed due to pci_alloc_consistent
 		   insisting on use of GFP_DMA, which is more restrictive
@@ -1199,7 +1199,7 @@ static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 		if (!rx_ring)
 			goto out_err;
 
-		rx_ring_dma = dma_map_single(bp->sdev->dev, rx_ring,
+		rx_ring_dma = dma_map_single(bp->sdev->dma_dev, rx_ring,
 			                    DMA_TABLE_BYTES,
 			                    DMA_BIDIRECTIONAL);
 
@@ -1214,7 +1214,7 @@ static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 		bp->flags |= B44_FLAG_RX_RING_HACK;
 	}
 
-	bp->tx_ring = dma_alloc_coherent(bp->sdev->dev, size, &bp->tx_ring_dma, gfp);
+	bp->tx_ring = dma_alloc_coherent(bp->sdev->dma_dev, size, &bp->tx_ring_dma, gfp);
 	if (!bp->tx_ring) {
 		/* Allocation may have failed due to dma_alloc_coherent
 		   insisting on use of GFP_DMA, which is more restrictive
@@ -1226,7 +1226,7 @@ static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 		if (!tx_ring)
 			goto out_err;
 
-		tx_ring_dma = dma_map_single(bp->sdev->dev, tx_ring,
+		tx_ring_dma = dma_map_single(bp->sdev->dma_dev, tx_ring,
 			                    DMA_TABLE_BYTES,
 			                    DMA_TO_DEVICE);
 
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index ddbc6e4..c16de51 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -512,13 +512,18 @@ static void gelic_wl_parse_ie(u8 *data, size_t len,
 		 data, len);
 	memset(ie_info, 0, sizeof(struct ie_info));
 
-	while (0 < data_left) {
+	while (2 <= data_left) {
 		item_id = *pos++;
 		item_len = *pos++;
+		data_left -= 2;
+
+		if (data_left < item_len)
+			break;
 
 		switch (item_id) {
 		case MFIE_TYPE_GENERIC:
-			if (!memcmp(pos, wpa_oui, OUI_LEN) &&
+			if ((OUI_LEN + 1 <= item_len) &&
+			    !memcmp(pos, wpa_oui, OUI_LEN) &&
 			    pos[OUI_LEN] == 0x01) {
 				ie_info->wpa.data = pos - 2;
 				ie_info->wpa.len = item_len + 2;
@@ -535,7 +540,7 @@ static void gelic_wl_parse_ie(u8 *data, size_t len,
 			break;
 		}
 		pos += item_len;
-		data_left -= item_len + 2;
+		data_left -= item_len;
 	}
 	pr_debug("%s: wpa=%p,%d wpa2=%p,%d\n", __func__,
 		 ie_info->wpa.data, ie_info->wpa.len,
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 948eb1f..48e9124 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -373,10 +373,10 @@ static inline
 	dma_addr_t dmaaddr;
 
 	if (tx) {
-		dmaaddr = dma_map_single(ring->dev->dev->dev,
+		dmaaddr = dma_map_single(ring->dev->dev->dma_dev,
 					 buf, len, DMA_TO_DEVICE);
 	} else {
-		dmaaddr = dma_map_single(ring->dev->dev->dev,
+		dmaaddr = dma_map_single(ring->dev->dev->dma_dev,
 					 buf, len, DMA_FROM_DEVICE);
 	}
 
@@ -388,9 +388,10 @@ static inline
 			  dma_addr_t addr, size_t len, int tx)
 {
 	if (tx) {
-		dma_unmap_single(ring->dev->dev->dev, addr, len, DMA_TO_DEVICE);
+		dma_unmap_single(ring->dev->dev->dma_dev,
+				 addr, len, DMA_TO_DEVICE);
 	} else {
-		dma_unmap_single(ring->dev->dev->dev,
+		dma_unmap_single(ring->dev->dev->dma_dev,
 				 addr, len, DMA_FROM_DEVICE);
 	}
 }
@@ -400,7 +401,7 @@ static inline
 				 dma_addr_t addr, size_t len)
 {
 	B43_WARN_ON(ring->tx);
-	dma_sync_single_for_cpu(ring->dev->dev->dev,
+	dma_sync_single_for_cpu(ring->dev->dev->dma_dev,
 				addr, len, DMA_FROM_DEVICE);
 }
 
@@ -409,7 +410,7 @@ static inline
 				    dma_addr_t addr, size_t len)
 {
 	B43_WARN_ON(ring->tx);
-	dma_sync_single_for_device(ring->dev->dev->dev,
+	dma_sync_single_for_device(ring->dev->dev->dma_dev,
 				   addr, len, DMA_FROM_DEVICE);
 }
 
@@ -425,7 +426,7 @@ static inline
 
 static int alloc_ringmemory(struct b43_dmaring *ring)
 {
-	struct device *dev = ring->dev->dev->dev;
+	struct device *dma_dev = ring->dev->dev->dma_dev;
 	gfp_t flags = GFP_KERNEL;
 
 	/* The specs call for 4K buffers for 30- and 32-bit DMA with 4K
@@ -439,7 +440,7 @@ static int alloc_ringmemory(struct b43_dmaring *ring)
 	 */
 	if (ring->type == B43_DMA_64BIT)
 		flags |= GFP_DMA;
-	ring->descbase = dma_alloc_coherent(dev, B43_DMA_RINGMEMSIZE,
+	ring->descbase = dma_alloc_coherent(dma_dev, B43_DMA_RINGMEMSIZE,
 					    &(ring->dmabase), flags);
 	if (!ring->descbase) {
 		b43err(ring->dev->wl, "DMA ringmemory allocation failed\n");
@@ -452,9 +453,9 @@ static int alloc_ringmemory(struct b43_dmaring *ring)
 
 static void free_ringmemory(struct b43_dmaring *ring)
 {
-	struct device *dev = ring->dev->dev->dev;
+	struct device *dma_dev = ring->dev->dev->dma_dev;
 
-	dma_free_coherent(dev, B43_DMA_RINGMEMSIZE,
+	dma_free_coherent(dma_dev, B43_DMA_RINGMEMSIZE,
 			  ring->descbase, ring->dmabase);
 }
 
@@ -854,7 +855,7 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 			goto err_kfree_meta;
 
 		/* test for ability to dma to txhdr_cache */
-		dma_test = dma_map_single(dev->dev->dev,
+		dma_test = dma_map_single(dev->dev->dma_dev,
 					  ring->txhdr_cache,
 					  b43_txhdr_size(dev),
 					  DMA_TO_DEVICE);
@@ -869,7 +870,7 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 			if (!ring->txhdr_cache)
 				goto err_kfree_meta;
 
-			dma_test = dma_map_single(dev->dev->dev,
+			dma_test = dma_map_single(dev->dev->dma_dev,
 						  ring->txhdr_cache,
 						  b43_txhdr_size(dev),
 						  DMA_TO_DEVICE);
@@ -883,7 +884,7 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 			}
 		}
 
-		dma_unmap_single(dev->dev->dev,
+		dma_unmap_single(dev->dev->dma_dev,
 				 dma_test, b43_txhdr_size(dev),
 				 DMA_TO_DEVICE);
 	}
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index e87b427..c990f87 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -393,11 +393,11 @@ dma_addr_t map_descbuffer(struct b43legacy_dmaring *ring,
 	dma_addr_t dmaaddr;
 
 	if (tx)
-		dmaaddr = dma_map_single(ring->dev->dev->dev,
+		dmaaddr = dma_map_single(ring->dev->dev->dma_dev,
 					 buf, len,
 					 DMA_TO_DEVICE);
 	else
-		dmaaddr = dma_map_single(ring->dev->dev->dev,
+		dmaaddr = dma_map_single(ring->dev->dev->dma_dev,
 					 buf, len,
 					 DMA_FROM_DEVICE);
 
@@ -411,11 +411,11 @@ void unmap_descbuffer(struct b43legacy_dmaring *ring,
 		      int tx)
 {
 	if (tx)
-		dma_unmap_single(ring->dev->dev->dev,
+		dma_unmap_single(ring->dev->dev->dma_dev,
 				 addr, len,
 				 DMA_TO_DEVICE);
 	else
-		dma_unmap_single(ring->dev->dev->dev,
+		dma_unmap_single(ring->dev->dev->dma_dev,
 				 addr, len,
 				 DMA_FROM_DEVICE);
 }
@@ -427,7 +427,7 @@ void sync_descbuffer_for_cpu(struct b43legacy_dmaring *ring,
 {
 	B43legacy_WARN_ON(ring->tx);
 
-	dma_sync_single_for_cpu(ring->dev->dev->dev,
+	dma_sync_single_for_cpu(ring->dev->dev->dma_dev,
 				addr, len, DMA_FROM_DEVICE);
 }
 
@@ -438,7 +438,7 @@ void sync_descbuffer_for_device(struct b43legacy_dmaring *ring,
 {
 	B43legacy_WARN_ON(ring->tx);
 
-	dma_sync_single_for_device(ring->dev->dev->dev,
+	dma_sync_single_for_device(ring->dev->dev->dma_dev,
 				   addr, len, DMA_FROM_DEVICE);
 }
 
@@ -458,9 +458,9 @@ void free_descriptor_buffer(struct b43legacy_dmaring *ring,
 
 static int alloc_ringmemory(struct b43legacy_dmaring *ring)
 {
-	struct device *dev = ring->dev->dev->dev;
+	struct device *dma_dev = ring->dev->dev->dma_dev;
 
-	ring->descbase = dma_alloc_coherent(dev, B43legacy_DMA_RINGMEMSIZE,
+	ring->descbase = dma_alloc_coherent(dma_dev, B43legacy_DMA_RINGMEMSIZE,
 					    &(ring->dmabase), GFP_KERNEL);
 	if (!ring->descbase) {
 		b43legacyerr(ring->dev->wl, "DMA ringmemory allocation"
@@ -474,9 +474,9 @@ static int alloc_ringmemory(struct b43legacy_dmaring *ring)
 
 static void free_ringmemory(struct b43legacy_dmaring *ring)
 {
-	struct device *dev = ring->dev->dev->dev;
+	struct device *dma_dev = ring->dev->dev->dma_dev;
 
-	dma_free_coherent(dev, B43legacy_DMA_RINGMEMSIZE,
+	dma_free_coherent(dma_dev, B43legacy_DMA_RINGMEMSIZE,
 			  ring->descbase, ring->dmabase);
 }
 
@@ -585,8 +585,9 @@ static int b43legacy_dmacontroller_tx_reset(struct b43legacy_wldev *dev,
 
 /* Check if a DMA mapping address is invalid. */
 static bool b43legacy_dma_mapping_error(struct b43legacy_dmaring *ring,
-					dma_addr_t addr,
-					size_t buffersize)
+					 dma_addr_t addr,
+					 size_t buffersize,
+					 bool dma_to_device)
 {
 	if (unlikely(dma_mapping_error(addr)))
 		return 1;
@@ -594,11 +595,11 @@ static bool b43legacy_dma_mapping_error(struct b43legacy_dmaring *ring,
 	switch (ring->type) {
 	case B43legacy_DMA_30BIT:
 		if ((u64)addr + buffersize > (1ULL << 30))
-			return 1;
+			goto address_error;
 		break;
 	case B43legacy_DMA_32BIT:
 		if ((u64)addr + buffersize > (1ULL << 32))
-			return 1;
+			goto address_error;
 		break;
 	case B43legacy_DMA_64BIT:
 		/* Currently we can't have addresses beyond 64 bits in the kernel. */
@@ -607,6 +608,12 @@ static bool b43legacy_dma_mapping_error(struct b43legacy_dmaring *ring,
 
 	/* The address is OK. */
 	return 0;
+
+address_error:
+	/* We can't support this address. Unmap it again. */
+	unmap_descbuffer(ring, addr, buffersize, dma_to_device);
+
+	return 1;
 }
 
 static int setup_rx_descbuffer(struct b43legacy_dmaring *ring,
@@ -626,7 +633,7 @@ static int setup_rx_descbuffer(struct b43legacy_dmaring *ring,
 		return -ENOMEM;
 	dmaaddr = map_descbuffer(ring, skb->data,
 				 ring->rx_buffersize, 0);
-	if (b43legacy_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize)) {
+	if (b43legacy_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize, 0)) {
 		/* ugh. try to realloc in zone_dma */
 		gfp_flags |= GFP_DMA;
 
@@ -639,7 +646,7 @@ static int setup_rx_descbuffer(struct b43legacy_dmaring *ring,
 					 ring->rx_buffersize, 0);
 	}
 
-	if (b43legacy_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize)) {
+	if (b43legacy_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize, 0)) {
 		dev_kfree_skb_any(skb);
 		return -EIO;
 	}
@@ -886,12 +893,12 @@ struct b43legacy_dmaring *b43legacy_setup_dmaring(struct b43legacy_wldev *dev,
 			goto err_kfree_meta;
 
 		/* test for ability to dma to txhdr_cache */
-		dma_test = dma_map_single(dev->dev->dev, ring->txhdr_cache,
+		dma_test = dma_map_single(dev->dev->dma_dev, ring->txhdr_cache,
 					  sizeof(struct b43legacy_txhdr_fw3),
 					  DMA_TO_DEVICE);
 
 		if (b43legacy_dma_mapping_error(ring, dma_test,
-					sizeof(struct b43legacy_txhdr_fw3))) {
+					sizeof(struct b43legacy_txhdr_fw3), 1)) {
 			/* ugh realloc */
 			kfree(ring->txhdr_cache);
 			ring->txhdr_cache = kcalloc(nr_slots,
@@ -900,17 +907,17 @@ struct b43legacy_dmaring *b43legacy_setup_dmaring(struct b43legacy_wldev *dev,
 			if (!ring->txhdr_cache)
 				goto err_kfree_meta;
 
-			dma_test = dma_map_single(dev->dev->dev,
+			dma_test = dma_map_single(dev->dev->dma_dev,
 					ring->txhdr_cache,
 					sizeof(struct b43legacy_txhdr_fw3),
 					DMA_TO_DEVICE);
 
 			if (b43legacy_dma_mapping_error(ring, dma_test,
-					sizeof(struct b43legacy_txhdr_fw3)))
+					sizeof(struct b43legacy_txhdr_fw3), 1))
 				goto err_kfree_txhdr_cache;
 		}
 
-		dma_unmap_single(dev->dev->dev,
+		dma_unmap_single(dev->dev->dma_dev,
 				 dma_test, sizeof(struct b43legacy_txhdr_fw3),
 				 DMA_TO_DEVICE);
 	}
@@ -1235,7 +1242,7 @@ static int dma_tx_fragment(struct b43legacy_dmaring *ring,
 	meta_hdr->dmaaddr = map_descbuffer(ring, (unsigned char *)header,
 					   sizeof(struct b43legacy_txhdr_fw3), 1);
 	if (b43legacy_dma_mapping_error(ring, meta_hdr->dmaaddr,
-					sizeof(struct b43legacy_txhdr_fw3))) {
+					sizeof(struct b43legacy_txhdr_fw3), 1)) {
 		ring->current_slot = old_top_slot;
 		ring->used_slots = old_used_slots;
 		return -EIO;
@@ -1254,7 +1261,7 @@ static int dma_tx_fragment(struct b43legacy_dmaring *ring,
 
 	meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
 	/* create a bounce buffer in zone_dma on mapping failure. */
-	if (b43legacy_dma_mapping_error(ring, meta->dmaaddr, skb->len)) {
+	if (b43legacy_dma_mapping_error(ring, meta->dmaaddr, skb->len, 1)) {
 		bounce_skb = __dev_alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb) {
 			ring->current_slot = old_top_slot;
@@ -1268,7 +1275,7 @@ static int dma_tx_fragment(struct b43legacy_dmaring *ring,
 		skb = bounce_skb;
 		meta->skb = skb;
 		meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
-		if (b43legacy_dma_mapping_error(ring, meta->dmaaddr, skb->len)) {
+		if (b43legacy_dma_mapping_error(ring, meta->dmaaddr, skb->len, 1)) {
 			ring->current_slot = old_top_slot;
 			ring->used_slots = old_used_slots;
 			err = -EIO;
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 5f3f34e..0f7a6e7 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -1488,6 +1488,7 @@ static int b43legacy_request_firmware(struct b43legacy_wldev *dev)
 	}
 	if (!fw->initvals) {
 		switch (dev->phy.type) {
+		case B43legacy_PHYTYPE_B:
 		case B43legacy_PHYTYPE_G:
 			if ((rev >= 5) && (rev <= 10))
 				filename = "b0g0initvals5";
@@ -1505,6 +1506,7 @@ static int b43legacy_request_firmware(struct b43legacy_wldev *dev)
 	}
 	if (!fw->initvals_band) {
 		switch (dev->phy.type) {
+		case B43legacy_PHYTYPE_B:
 		case B43legacy_PHYTYPE_G:
 			if ((rev >= 5) && (rev <= 10))
 				filename = "b0g0bsinitvals5";
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index f445059..133b3f3 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -509,6 +509,8 @@ static int rtl8187_add_interface(struct ieee80211_hw *dev,
 		return -EOPNOTSUPP;
 	}
 
+	priv->vif = conf->vif;
+
 	rtl818x_iowrite8(priv, &priv->map->EEPROM_CMD, RTL818X_EEPROM_CMD_CONFIG);
 	for (i = 0; i < ETH_ALEN; i++)
 		rtl818x_iowrite8(priv, &priv->map->MAC[i],
@@ -523,6 +525,7 @@ static void rtl8187_remove_interface(struct ieee80211_hw *dev,
 {
 	struct rtl8187_priv *priv = dev->priv;
 	priv->mode = IEEE80211_IF_TYPE_MNTR;
+	priv->vif = NULL;
 }
 
 static int rtl8187_config(struct ieee80211_hw *dev, struct ieee80211_conf *conf)
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 72017bf..8003a9e 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -436,15 +436,18 @@ static int ssb_devices_register(struct ssb_bus *bus)
 #ifdef CONFIG_SSB_PCIHOST
 			sdev->irq = bus->host_pci->irq;
 			dev->parent = &bus->host_pci->dev;
+			sdev->dma_dev = &bus->host_pci->dev;
 #endif
 			break;
 		case SSB_BUSTYPE_PCMCIA:
 #ifdef CONFIG_SSB_PCMCIAHOST
 			sdev->irq = bus->host_pcmcia->irq.AssignedIRQ;
 			dev->parent = &bus->host_pcmcia->dev;
+			sdev->dma_dev = &bus->host_pcmcia->dev;
 #endif
 			break;
 		case SSB_BUSTYPE_SSB:
+			sdev->dma_dev = dev;
 			break;
 		}
 
@@ -1018,15 +1021,14 @@ EXPORT_SYMBOL(ssb_dma_translation);
 
 int ssb_dma_set_mask(struct ssb_device *ssb_dev, u64 mask)
 {
-	struct device *dev = ssb_dev->dev;
+	struct device *dma_dev = ssb_dev->dma_dev;
 
 #ifdef CONFIG_SSB_PCIHOST
-	if (ssb_dev->bus->bustype == SSB_BUSTYPE_PCI &&
-	    !dma_supported(dev, mask))
-		return -EIO;
+	if (ssb_dev->bus->bustype == SSB_BUSTYPE_PCI)
+		return dma_set_mask(dma_dev, mask);
 #endif
-	dev->coherent_dma_mask = mask;
-	dev->dma_mask = &dev->coherent_dma_mask;
+	dma_dev->coherent_dma_mask = mask;
+	dma_dev->dma_mask = &dma_dev->coherent_dma_mask;
 
 	return 0;
 }
diff --git a/include/linux/ssb/ssb.h b/include/linux/ssb/ssb.h
index 20add65..db53def 100644
--- a/include/linux/ssb/ssb.h
+++ b/include/linux/ssb/ssb.h
@@ -129,6 +129,10 @@ struct ssb_device {
 	const struct ssb_bus_ops *ops;
 
 	struct device *dev;
+	/* Pointer to the device that has to be used for
+	 * any DMA related operation. */
+	struct device *dma_dev;
+
 	struct ssb_bus *bus;
 	struct ssb_device_id id;
 
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 535407d..a8a40ab 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1050,12 +1050,9 @@ ieee80211_drop_unencrypted(struct ieee80211_txrx_data *rx)
 	if (unlikely(!(rx->fc & IEEE80211_FCTL_PROTECTED) &&
 		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
 		     (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_NULLFUNC &&
-		     (rx->key || rx->sdata->drop_unencrypted))) {
-		if (net_ratelimit())
-			printk(KERN_DEBUG "%s: RX non-WEP frame, but expected "
-			       "encryption\n", rx->dev->name);
+		     (rx->key || rx->sdata->drop_unencrypted)))
 		return -EACCES;
-	}
+
 	return 0;
 }
 
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index 140a0a8..4e10a95 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -92,7 +92,7 @@ void rfkill_switch_all(enum rfkill_type type, enum rfkill_state state)
 	rfkill_states[type] = state;
 
 	list_for_each_entry(rfkill, &rfkill_list, node) {
-		if (!rfkill->user_claim)
+		if ((!rfkill->user_claim) && (rfkill->type == type))
 			rfkill_toggle_radio(rfkill, state);
 	}
 
-- 
John W. Linville
linville@tuxdriver.com
