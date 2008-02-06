From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 'fixes' 2008-02-05
Date: Tue, 5 Feb 2008 21:59:02 -0500
Message-ID: <20080206025902.GM4252@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Some fixes intended for 2.6.25, especially some ports to b43legacy of
some b43 fixes that are already merged.  Please let me know if there are
problems.

Thanks!

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes

---

The following changes since commit 9ef9dc69d4167276c04590d67ee55de8380bc1ad:
  Linus Torvalds (1):
        Merge branch 'for-linus' of master.kernel.org:/home/rmk/linux-2.6-arm

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes

Adrian Bunk (1):
      iwl3945-base.c: fix off-by-one errors

Andrew Morton (1):
      b43: fix build with CONFIG_SSB_PCIHOST=n

Michael Buesch (2):
      mac80211: Is not EXPERIMENTAL anymore
      b43: Fix DMA for 30/32-bit DMA engines

Stefano Brivio (4):
      b43legacy: fix PIO crash
      b43legacy: fix suspend/resume
      b43legacy: drop packets we are not able to encrypt
      b43legacy: fix DMA slot resource leakage

 drivers/net/wireless/b43/dma.c              |  137 ++++++++++++++++++---------
 drivers/net/wireless/b43/dma.h              |   20 ++--
 drivers/net/wireless/b43legacy/dma.c        |   23 ++++-
 drivers/net/wireless/b43legacy/main.c       |    9 ++-
 drivers/net/wireless/b43legacy/pio.c        |   21 ++++-
 drivers/net/wireless/b43legacy/xmit.c       |   15 +++-
 drivers/net/wireless/b43legacy/xmit.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    8 +-
 include/linux/ssb/ssb.h                     |    9 ++
 net/mac80211/Kconfig                        |    1 -
 10 files changed, 171 insertions(+), 74 deletions(-)

diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 8a708b7..3dfb28a 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -337,7 +337,7 @@ static inline int txring_to_priority(struct b43_dmaring *ring)
 	return idx_to_prio[index];
 }
 
-u16 b43_dmacontroller_base(int dma64bit, int controller_idx)
+static u16 b43_dmacontroller_base(enum b43_dmatype type, int controller_idx)
 {
 	static const u16 map64[] = {
 		B43_MMIO_DMA64_BASE0,
@@ -356,7 +356,7 @@ u16 b43_dmacontroller_base(int dma64bit, int controller_idx)
 		B43_MMIO_DMA32_BASE5,
 	};
 
-	if (dma64bit) {
+	if (type == B43_DMA_64BIT) {
 		B43_WARN_ON(!(controller_idx >= 0 &&
 			      controller_idx < ARRAY_SIZE(map64)));
 		return map64[controller_idx];
@@ -437,7 +437,7 @@ static int alloc_ringmemory(struct b43_dmaring *ring)
 	 * 02, which uses 64-bit DMA, needs the ring buffer in very low memory,
 	 * which accounts for the GFP_DMA flag below.
 	 */
-	if (ring->dma64)
+	if (ring->type == B43_DMA_64BIT)
 		flags |= GFP_DMA;
 	ring->descbase = dma_alloc_coherent(dev, B43_DMA_RINGMEMSIZE,
 					    &(ring->dmabase), flags);
@@ -459,7 +459,8 @@ static void free_ringmemory(struct b43_dmaring *ring)
 }
 
 /* Reset the RX DMA channel */
-int b43_dmacontroller_rx_reset(struct b43_wldev *dev, u16 mmio_base, int dma64)
+static int b43_dmacontroller_rx_reset(struct b43_wldev *dev, u16 mmio_base,
+				      enum b43_dmatype type)
 {
 	int i;
 	u32 value;
@@ -467,12 +468,13 @@ int b43_dmacontroller_rx_reset(struct b43_wldev *dev, u16 mmio_base, int dma64)
 
 	might_sleep();
 
-	offset = dma64 ? B43_DMA64_RXCTL : B43_DMA32_RXCTL;
+	offset = (type == B43_DMA_64BIT) ? B43_DMA64_RXCTL : B43_DMA32_RXCTL;
 	b43_write32(dev, mmio_base + offset, 0);
 	for (i = 0; i < 10; i++) {
-		offset = dma64 ? B43_DMA64_RXSTATUS : B43_DMA32_RXSTATUS;
+		offset = (type == B43_DMA_64BIT) ? B43_DMA64_RXSTATUS :
+						   B43_DMA32_RXSTATUS;
 		value = b43_read32(dev, mmio_base + offset);
-		if (dma64) {
+		if (type == B43_DMA_64BIT) {
 			value &= B43_DMA64_RXSTAT;
 			if (value == B43_DMA64_RXSTAT_DISABLED) {
 				i = -1;
@@ -496,7 +498,8 @@ int b43_dmacontroller_rx_reset(struct b43_wldev *dev, u16 mmio_base, int dma64)
 }
 
 /* Reset the TX DMA channel */
-int b43_dmacontroller_tx_reset(struct b43_wldev *dev, u16 mmio_base, int dma64)
+static int b43_dmacontroller_tx_reset(struct b43_wldev *dev, u16 mmio_base,
+				      enum b43_dmatype type)
 {
 	int i;
 	u32 value;
@@ -505,9 +508,10 @@ int b43_dmacontroller_tx_reset(struct b43_wldev *dev, u16 mmio_base, int dma64)
 	might_sleep();
 
 	for (i = 0; i < 10; i++) {
-		offset = dma64 ? B43_DMA64_TXSTATUS : B43_DMA32_TXSTATUS;
+		offset = (type == B43_DMA_64BIT) ? B43_DMA64_TXSTATUS :
+						   B43_DMA32_TXSTATUS;
 		value = b43_read32(dev, mmio_base + offset);
-		if (dma64) {
+		if (type == B43_DMA_64BIT) {
 			value &= B43_DMA64_TXSTAT;
 			if (value == B43_DMA64_TXSTAT_DISABLED ||
 			    value == B43_DMA64_TXSTAT_IDLEWAIT ||
@@ -522,12 +526,13 @@ int b43_dmacontroller_tx_reset(struct b43_wldev *dev, u16 mmio_base, int dma64)
 		}
 		msleep(1);
 	}
-	offset = dma64 ? B43_DMA64_TXCTL : B43_DMA32_TXCTL;
+	offset = (type == B43_DMA_64BIT) ? B43_DMA64_TXCTL : B43_DMA32_TXCTL;
 	b43_write32(dev, mmio_base + offset, 0);
 	for (i = 0; i < 10; i++) {
-		offset = dma64 ? B43_DMA64_TXSTATUS : B43_DMA32_TXSTATUS;
+		offset = (type == B43_DMA_64BIT) ? B43_DMA64_TXSTATUS :
+						   B43_DMA32_TXSTATUS;
 		value = b43_read32(dev, mmio_base + offset);
-		if (dma64) {
+		if (type == B43_DMA_64BIT) {
 			value &= B43_DMA64_TXSTAT;
 			if (value == B43_DMA64_TXSTAT_DISABLED) {
 				i = -1;
@@ -552,6 +557,33 @@ int b43_dmacontroller_tx_reset(struct b43_wldev *dev, u16 mmio_base, int dma64)
 	return 0;
 }
 
+/* Check if a DMA mapping address is invalid. */
+static bool b43_dma_mapping_error(struct b43_dmaring *ring,
+				  dma_addr_t addr,
+				  size_t buffersize)
+{
+	if (unlikely(dma_mapping_error(addr)))
+		return 1;
+
+	switch (ring->type) {
+	case B43_DMA_30BIT:
+		if ((u64)addr + buffersize > (1ULL << 30))
+			return 1;
+		break;
+	case B43_DMA_32BIT:
+		if ((u64)addr + buffersize > (1ULL << 32))
+			return 1;
+		break;
+	case B43_DMA_64BIT:
+		/* Currently we can't have addresses beyond
+		 * 64bit in the kernel. */
+		break;
+	}
+
+	/* The address is OK. */
+	return 0;
+}
+
 static int setup_rx_descbuffer(struct b43_dmaring *ring,
 			       struct b43_dmadesc_generic *desc,
 			       struct b43_dmadesc_meta *meta, gfp_t gfp_flags)
@@ -567,7 +599,7 @@ static int setup_rx_descbuffer(struct b43_dmaring *ring,
 	if (unlikely(!skb))
 		return -ENOMEM;
 	dmaaddr = map_descbuffer(ring, skb->data, ring->rx_buffersize, 0);
-	if (dma_mapping_error(dmaaddr)) {
+	if (b43_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize)) {
 		/* ugh. try to realloc in zone_dma */
 		gfp_flags |= GFP_DMA;
 
@@ -580,7 +612,7 @@ static int setup_rx_descbuffer(struct b43_dmaring *ring,
 					 ring->rx_buffersize, 0);
 	}
 
-	if (dma_mapping_error(dmaaddr)) {
+	if (b43_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize)) {
 		dev_kfree_skb_any(skb);
 		return -EIO;
 	}
@@ -645,7 +677,7 @@ static int dmacontroller_setup(struct b43_dmaring *ring)
 	u32 trans = ssb_dma_translation(ring->dev->dev);
 
 	if (ring->tx) {
-		if (ring->dma64) {
+		if (ring->type == B43_DMA_64BIT) {
 			u64 ringbase = (u64) (ring->dmabase);
 
 			addrext = ((ringbase >> 32) & SSB_DMA_TRANSLATION_MASK)
@@ -677,7 +709,7 @@ static int dmacontroller_setup(struct b43_dmaring *ring)
 		err = alloc_initial_descbuffers(ring);
 		if (err)
 			goto out;
-		if (ring->dma64) {
+		if (ring->type == B43_DMA_64BIT) {
 			u64 ringbase = (u64) (ring->dmabase);
 
 			addrext = ((ringbase >> 32) & SSB_DMA_TRANSLATION_MASK)
@@ -722,16 +754,16 @@ static void dmacontroller_cleanup(struct b43_dmaring *ring)
 {
 	if (ring->tx) {
 		b43_dmacontroller_tx_reset(ring->dev, ring->mmio_base,
-					   ring->dma64);
-		if (ring->dma64) {
+					   ring->type);
+		if (ring->type == B43_DMA_64BIT) {
 			b43_dma_write(ring, B43_DMA64_TXRINGLO, 0);
 			b43_dma_write(ring, B43_DMA64_TXRINGHI, 0);
 		} else
 			b43_dma_write(ring, B43_DMA32_TXRING, 0);
 	} else {
 		b43_dmacontroller_rx_reset(ring->dev, ring->mmio_base,
-					   ring->dma64);
-		if (ring->dma64) {
+					   ring->type);
+		if (ring->type == B43_DMA_64BIT) {
 			b43_dma_write(ring, B43_DMA64_RXRINGLO, 0);
 			b43_dma_write(ring, B43_DMA64_RXRINGHI, 0);
 		} else
@@ -786,7 +818,8 @@ static u64 supported_dma_mask(struct b43_wldev *dev)
 static
 struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 				      int controller_index,
-				      int for_tx, int dma64)
+				      int for_tx,
+				      enum b43_dmatype type)
 {
 	struct b43_dmaring *ring;
 	int err;
@@ -796,6 +829,7 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 	if (!ring)
 		goto out;
+	ring->type = type;
 
 	nr_slots = B43_RXRING_SLOTS;
 	if (for_tx)
@@ -818,7 +852,7 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 					  b43_txhdr_size(dev),
 					  DMA_TO_DEVICE);
 
-		if (dma_mapping_error(dma_test)) {
+		if (b43_dma_mapping_error(ring, dma_test, b43_txhdr_size(dev))) {
 			/* ugh realloc */
 			kfree(ring->txhdr_cache);
 			ring->txhdr_cache = kcalloc(nr_slots,
@@ -832,7 +866,8 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 						  b43_txhdr_size(dev),
 						  DMA_TO_DEVICE);
 
-			if (dma_mapping_error(dma_test))
+			if (b43_dma_mapping_error(ring, dma_test,
+						  b43_txhdr_size(dev)))
 				goto err_kfree_txhdr_cache;
 		}
 
@@ -843,10 +878,9 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 
 	ring->dev = dev;
 	ring->nr_slots = nr_slots;
-	ring->mmio_base = b43_dmacontroller_base(dma64, controller_index);
+	ring->mmio_base = b43_dmacontroller_base(type, controller_index);
 	ring->index = controller_index;
-	ring->dma64 = !!dma64;
-	if (dma64)
+	if (type == B43_DMA_64BIT)
 		ring->ops = &dma64_ops;
 	else
 		ring->ops = &dma32_ops;
@@ -896,8 +930,8 @@ static void b43_destroy_dmaring(struct b43_dmaring *ring)
 	if (!ring)
 		return;
 
-	b43dbg(ring->dev->wl, "DMA-%s 0x%04X (%s) max used slots: %d/%d\n",
-	       (ring->dma64) ? "64" : "32",
+	b43dbg(ring->dev->wl, "DMA-%u 0x%04X (%s) max used slots: %d/%d\n",
+	       (unsigned int)(ring->type),
 	       ring->mmio_base,
 	       (ring->tx) ? "TX" : "RX", ring->max_used_slots, ring->nr_slots);
 	/* Device IRQs are disabled prior entering this function,
@@ -941,12 +975,22 @@ int b43_dma_init(struct b43_wldev *dev)
 	struct b43_dmaring *ring;
 	int err;
 	u64 dmamask;
-	int dma64 = 0;
+	enum b43_dmatype type;
 
 	dmamask = supported_dma_mask(dev);
-	if (dmamask == DMA_64BIT_MASK)
-		dma64 = 1;
-
+	switch (dmamask) {
+	default:
+		B43_WARN_ON(1);
+	case DMA_30BIT_MASK:
+		type = B43_DMA_30BIT;
+		break;
+	case DMA_32BIT_MASK:
+		type = B43_DMA_32BIT;
+		break;
+	case DMA_64BIT_MASK:
+		type = B43_DMA_64BIT;
+		break;
+	}
 	err = ssb_dma_set_mask(dev->dev, dmamask);
 	if (err) {
 		b43err(dev->wl, "The machine/kernel does not support "
@@ -958,52 +1002,51 @@ int b43_dma_init(struct b43_wldev *dev)
 
 	err = -ENOMEM;
 	/* setup TX DMA channels. */
-	ring = b43_setup_dmaring(dev, 0, 1, dma64);
+	ring = b43_setup_dmaring(dev, 0, 1, type);
 	if (!ring)
 		goto out;
 	dma->tx_ring0 = ring;
 
-	ring = b43_setup_dmaring(dev, 1, 1, dma64);
+	ring = b43_setup_dmaring(dev, 1, 1, type);
 	if (!ring)
 		goto err_destroy_tx0;
 	dma->tx_ring1 = ring;
 
-	ring = b43_setup_dmaring(dev, 2, 1, dma64);
+	ring = b43_setup_dmaring(dev, 2, 1, type);
 	if (!ring)
 		goto err_destroy_tx1;
 	dma->tx_ring2 = ring;
 
-	ring = b43_setup_dmaring(dev, 3, 1, dma64);
+	ring = b43_setup_dmaring(dev, 3, 1, type);
 	if (!ring)
 		goto err_destroy_tx2;
 	dma->tx_ring3 = ring;
 
-	ring = b43_setup_dmaring(dev, 4, 1, dma64);
+	ring = b43_setup_dmaring(dev, 4, 1, type);
 	if (!ring)
 		goto err_destroy_tx3;
 	dma->tx_ring4 = ring;
 
-	ring = b43_setup_dmaring(dev, 5, 1, dma64);
+	ring = b43_setup_dmaring(dev, 5, 1, type);
 	if (!ring)
 		goto err_destroy_tx4;
 	dma->tx_ring5 = ring;
 
 	/* setup RX DMA channels. */
-	ring = b43_setup_dmaring(dev, 0, 0, dma64);
+	ring = b43_setup_dmaring(dev, 0, 0, type);
 	if (!ring)
 		goto err_destroy_tx5;
 	dma->rx_ring0 = ring;
 
 	if (dev->dev->id.revision < 5) {
-		ring = b43_setup_dmaring(dev, 3, 0, dma64);
+		ring = b43_setup_dmaring(dev, 3, 0, type);
 		if (!ring)
 			goto err_destroy_rx0;
 		dma->rx_ring3 = ring;
 	}
 
-	b43dbg(dev->wl, "%d-bit DMA initialized\n",
-	       (dmamask == DMA_64BIT_MASK) ? 64 :
-	       (dmamask == DMA_32BIT_MASK) ? 32 : 30);
+	b43dbg(dev->wl, "%u-bit DMA initialized\n",
+	       (unsigned int)type);
 	err = 0;
       out:
 	return err;
@@ -1146,7 +1189,7 @@ static int dma_tx_fragment(struct b43_dmaring *ring,
 
 	meta_hdr->dmaaddr = map_descbuffer(ring, (unsigned char *)header,
 					   hdrsize, 1);
-	if (dma_mapping_error(meta_hdr->dmaaddr)) {
+	if (b43_dma_mapping_error(ring, meta_hdr->dmaaddr, hdrsize)) {
 		ring->current_slot = old_top_slot;
 		ring->used_slots = old_used_slots;
 		return -EIO;
@@ -1165,7 +1208,7 @@ static int dma_tx_fragment(struct b43_dmaring *ring,
 
 	meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
 	/* create a bounce buffer in zone_dma on mapping failure. */
-	if (dma_mapping_error(meta->dmaaddr)) {
+	if (b43_dma_mapping_error(ring, meta->dmaaddr, skb->len)) {
 		bounce_skb = __dev_alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb) {
 			ring->current_slot = old_top_slot;
@@ -1179,7 +1222,7 @@ static int dma_tx_fragment(struct b43_dmaring *ring,
 		skb = bounce_skb;
 		meta->skb = skb;
 		meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
-		if (dma_mapping_error(meta->dmaaddr)) {
+		if (b43_dma_mapping_error(ring, meta->dmaaddr, skb->len)) {
 			ring->current_slot = old_top_slot;
 			ring->used_slots = old_used_slots;
 			err = -EIO;
diff --git a/drivers/net/wireless/b43/dma.h b/drivers/net/wireless/b43/dma.h
index 58db03a..c0d6b69 100644
--- a/drivers/net/wireless/b43/dma.h
+++ b/drivers/net/wireless/b43/dma.h
@@ -203,6 +203,12 @@ struct b43_dma_ops {
 	void (*set_current_rxslot) (struct b43_dmaring * ring, int slot);
 };
 
+enum b43_dmatype {
+	B43_DMA_30BIT	= 30,
+	B43_DMA_32BIT	= 32,
+	B43_DMA_64BIT	= 64,
+};
+
 struct b43_dmaring {
 	/* Lowlevel DMA ops. */
 	const struct b43_dma_ops *ops;
@@ -235,8 +241,8 @@ struct b43_dmaring {
 	int index;
 	/* Boolean. Is this a TX ring? */
 	bool tx;
-	/* Boolean. 64bit DMA if true, 32bit DMA otherwise. */
-	bool dma64;
+	/* The type of DMA engine used. */
+	enum b43_dmatype type;
 	/* Boolean. Is this ring stopped at ieee80211 level? */
 	bool stopped;
 	/* Lock, only used for TX. */
@@ -255,8 +261,7 @@ static inline u32 b43_dma_read(struct b43_dmaring *ring, u16 offset)
 	return b43_read32(ring->dev, ring->mmio_base + offset);
 }
 
-static inline
-    void b43_dma_write(struct b43_dmaring *ring, u16 offset, u32 value)
+static inline void b43_dma_write(struct b43_dmaring *ring, u16 offset, u32 value)
 {
 	b43_write32(ring->dev, ring->mmio_base + offset, value);
 }
@@ -264,13 +269,6 @@ static inline
 int b43_dma_init(struct b43_wldev *dev);
 void b43_dma_free(struct b43_wldev *dev);
 
-int b43_dmacontroller_rx_reset(struct b43_wldev *dev,
-			       u16 dmacontroller_mmio_base, int dma64);
-int b43_dmacontroller_tx_reset(struct b43_wldev *dev,
-			       u16 dmacontroller_mmio_base, int dma64);
-
-u16 b43_dmacontroller_base(int dma64bit, int dmacontroller_idx);
-
 void b43_dma_tx_suspend(struct b43_wldev *dev);
 void b43_dma_tx_resume(struct b43_wldev *dev);
 
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 83161d9..6e08405 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -1164,7 +1164,7 @@ static int dma_tx_fragment(struct b43legacy_dmaring *ring,
 {
 	const struct b43legacy_dma_ops *ops = ring->ops;
 	u8 *header;
-	int slot;
+	int slot, old_top_slot, old_used_slots;
 	int err;
 	struct b43legacy_dmadesc_generic *desc;
 	struct b43legacy_dmadesc_meta *meta;
@@ -1174,6 +1174,9 @@ static int dma_tx_fragment(struct b43legacy_dmaring *ring,
 #define SLOTS_PER_PACKET  2
 	B43legacy_WARN_ON(skb_shinfo(skb)->nr_frags != 0);
 
+	old_top_slot = ring->current_slot;
+	old_used_slots = ring->used_slots;
+
 	/* Get a slot for the header. */
 	slot = request_slot(ring);
 	desc = ops->idx2desc(ring, slot, &meta_hdr);
@@ -1181,9 +1184,14 @@ static int dma_tx_fragment(struct b43legacy_dmaring *ring,
 
 	header = &(ring->txhdr_cache[slot * sizeof(
 			       struct b43legacy_txhdr_fw3)]);
-	b43legacy_generate_txhdr(ring->dev, header,
+	err = b43legacy_generate_txhdr(ring->dev, header,
 				 skb->data, skb->len, ctl,
 				 generate_cookie(ring, slot));
+	if (unlikely(err)) {
+		ring->current_slot = old_top_slot;
+		ring->used_slots = old_used_slots;
+		return err;
+	}
 
 	meta_hdr->dmaaddr = map_descbuffer(ring, (unsigned char *)header,
 				       sizeof(struct b43legacy_txhdr_fw3), 1);
@@ -1206,6 +1214,8 @@ static int dma_tx_fragment(struct b43legacy_dmaring *ring,
 	if (dma_mapping_error(meta->dmaaddr)) {
 		bounce_skb = __dev_alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb) {
+			ring->current_slot = old_top_slot;
+			ring->used_slots = old_used_slots;
 			err = -ENOMEM;
 			goto out_unmap_hdr;
 		}
@@ -1216,6 +1226,8 @@ static int dma_tx_fragment(struct b43legacy_dmaring *ring,
 		meta->skb = skb;
 		meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
 		if (dma_mapping_error(meta->dmaaddr)) {
+			ring->current_slot = old_top_slot;
+			ring->used_slots = old_used_slots;
 			err = -EIO;
 			goto out_free_bounce;
 		}
@@ -1282,6 +1294,13 @@ int b43legacy_dma_tx(struct b43legacy_wldev *dev,
 	B43legacy_BUG_ON(ring->stopped);
 
 	err = dma_tx_fragment(ring, skb, ctl);
+	if (unlikely(err == -ENOKEY)) {
+		/* Drop this packet, as we don't have the encryption key
+		 * anymore and must not transmit it unencrypted. */
+		dev_kfree_skb_any(skb);
+		err = 0;
+		goto out_unlock;
+	}
 	if (unlikely(err)) {
 		b43legacyerr(dev->wl, "DMA tx mapping failure\n");
 		goto out_unlock;
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index aa20d5d..53f7f2e 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -3160,8 +3160,6 @@ static int b43legacy_wireless_core_init(struct b43legacy_wldev *dev)
 	b43legacy_shm_write16(dev, B43legacy_SHM_SHARED, 0x0414, 0x01F4);
 
 	ssb_bus_powerup(bus, 1); /* Enable dynamic PCTL */
-	memset(wl->bssid, 0, ETH_ALEN);
-	memset(wl->mac_addr, 0, ETH_ALEN);
 	b43legacy_upload_card_macaddress(dev);
 	b43legacy_security_init(dev);
 	b43legacy_rng_init(wl);
@@ -3263,6 +3261,13 @@ static int b43legacy_op_start(struct ieee80211_hw *hw)
 	 * LEDs that are registered later depend on it. */
 	b43legacy_rfkill_init(dev);
 
+	/* Kill all old instance specific information to make sure
+	 * the card won't use it in the short timeframe between start
+	 * and mac80211 reconfiguring it. */
+	memset(wl->bssid, 0, ETH_ALEN);
+	memset(wl->mac_addr, 0, ETH_ALEN);
+	wl->filter_flags = 0;
+
 	mutex_lock(&wl->mutex);
 
 	if (b43legacy_status(dev) < B43legacy_STAT_INITIALIZED) {
diff --git a/drivers/net/wireless/b43legacy/pio.c b/drivers/net/wireless/b43legacy/pio.c
index e4f4c5c..bcdd54e 100644
--- a/drivers/net/wireless/b43legacy/pio.c
+++ b/drivers/net/wireless/b43legacy/pio.c
@@ -181,7 +181,7 @@ union txhdr_union {
 	struct b43legacy_txhdr_fw3 txhdr_fw3;
 };
 
-static void pio_tx_write_fragment(struct b43legacy_pioqueue *queue,
+static int pio_tx_write_fragment(struct b43legacy_pioqueue *queue,
 				  struct sk_buff *skb,
 				  struct b43legacy_pio_txpacket *packet,
 				  size_t txhdr_size)
@@ -189,14 +189,17 @@ static void pio_tx_write_fragment(struct b43legacy_pioqueue *queue,
 	union txhdr_union txhdr_data;
 	u8 *txhdr = NULL;
 	unsigned int octets;
+	int err;
 
 	txhdr = (u8 *)(&txhdr_data.txhdr_fw3);
 
 	B43legacy_WARN_ON(skb_shinfo(skb)->nr_frags != 0);
-	b43legacy_generate_txhdr(queue->dev,
+	err = b43legacy_generate_txhdr(queue->dev,
 				 txhdr, skb->data, skb->len,
 				 &packet->txstat.control,
 				 generate_cookie(queue, packet));
+	if (err)
+		return err;
 
 	tx_start(queue);
 	octets = skb->len + txhdr_size;
@@ -204,6 +207,8 @@ static void pio_tx_write_fragment(struct b43legacy_pioqueue *queue,
 		octets--;
 	tx_data(queue, txhdr, (u8 *)skb->data, octets);
 	tx_complete(queue, skb);
+
+	return 0;
 }
 
 static void free_txpacket(struct b43legacy_pio_txpacket *packet,
@@ -226,6 +231,7 @@ static int pio_tx_packet(struct b43legacy_pio_txpacket *packet)
 	struct b43legacy_pioqueue *queue = packet->queue;
 	struct sk_buff *skb = packet->skb;
 	u16 octets;
+	int err;
 
 	octets = (u16)skb->len + sizeof(struct b43legacy_txhdr_fw3);
 	if (queue->tx_devq_size < octets) {
@@ -247,8 +253,14 @@ static int pio_tx_packet(struct b43legacy_pio_txpacket *packet)
 	if (queue->tx_devq_used + octets > queue->tx_devq_size)
 		return -EBUSY;
 	/* Now poke the device. */
-	pio_tx_write_fragment(queue, skb, packet,
+	err = pio_tx_write_fragment(queue, skb, packet,
 			      sizeof(struct b43legacy_txhdr_fw3));
+	if (unlikely(err == -ENOKEY)) {
+		/* Drop this packet, as we don't have the encryption key
+		 * anymore and must not transmit it unencrypted. */
+		free_txpacket(packet, 1);
+		return 0;
+	}
 
 	/* Account for the packet size.
 	 * (We must not overflow the device TX queue)
@@ -486,6 +498,9 @@ void b43legacy_pio_handle_txstatus(struct b43legacy_wldev *dev,
 	queue = parse_cookie(dev, status->cookie, &packet);
 	B43legacy_WARN_ON(!queue);
 
+	if (!packet->skb)
+		return;
+
 	queue->tx_devq_packets--;
 	queue->tx_devq_used -= (packet->skb->len +
 				sizeof(struct b43legacy_txhdr_fw3));
diff --git a/drivers/net/wireless/b43legacy/xmit.c b/drivers/net/wireless/b43legacy/xmit.c
index e20c552..d84408a 100644
--- a/drivers/net/wireless/b43legacy/xmit.c
+++ b/drivers/net/wireless/b43legacy/xmit.c
@@ -181,7 +181,7 @@ static u8 b43legacy_calc_fallback_rate(u8 bitrate)
 	return 0;
 }
 
-static void generate_txhdr_fw3(struct b43legacy_wldev *dev,
+static int generate_txhdr_fw3(struct b43legacy_wldev *dev,
 			       struct b43legacy_txhdr_fw3 *txhdr,
 			       const unsigned char *fragment_data,
 			       unsigned int fragment_len,
@@ -252,6 +252,13 @@ static void generate_txhdr_fw3(struct b43legacy_wldev *dev,
 			iv_len = min((size_t)txctl->iv_len,
 				     ARRAY_SIZE(txhdr->iv));
 			memcpy(txhdr->iv, ((u8 *)wlhdr) + wlhdr_len, iv_len);
+		} else {
+			/* This key is invalid. This might only happen
+			 * in a short timeframe after machine resume before
+			 * we were able to reconfigure keys.
+			 * Drop this packet completely. Do not transmit it
+			 * unencrypted to avoid leaking information. */
+			return -ENOKEY;
 		}
 	}
 	b43legacy_generate_plcp_hdr((struct b43legacy_plcp_hdr4 *)
@@ -345,16 +352,18 @@ static void generate_txhdr_fw3(struct b43legacy_wldev *dev,
 	/* Apply the bitfields */
 	txhdr->mac_ctl = cpu_to_le32(mac_ctl);
 	txhdr->phy_ctl = cpu_to_le16(phy_ctl);
+
+	return 0;
 }
 
-void b43legacy_generate_txhdr(struct b43legacy_wldev *dev,
+int b43legacy_generate_txhdr(struct b43legacy_wldev *dev,
 			      u8 *txhdr,
 			      const unsigned char *fragment_data,
 			      unsigned int fragment_len,
 			      const struct ieee80211_tx_control *txctl,
 			      u16 cookie)
 {
-	generate_txhdr_fw3(dev, (struct b43legacy_txhdr_fw3 *)txhdr,
+	return generate_txhdr_fw3(dev, (struct b43legacy_txhdr_fw3 *)txhdr,
 			   fragment_data, fragment_len,
 			   txctl, cookie);
 }
diff --git a/drivers/net/wireless/b43legacy/xmit.h b/drivers/net/wireless/b43legacy/xmit.h
index 8a155d0..bab4792 100644
--- a/drivers/net/wireless/b43legacy/xmit.h
+++ b/drivers/net/wireless/b43legacy/xmit.h
@@ -76,7 +76,7 @@ struct b43legacy_txhdr_fw3 {
 
 
 
-void b43legacy_generate_txhdr(struct b43legacy_wldev *dev,
+int b43legacy_generate_txhdr(struct b43legacy_wldev *dev,
 			      u8 *txhdr,
 			      const unsigned char *fragment_data,
 			      unsigned int fragment_len,
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index f55c757..5ee1ad6 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -4207,13 +4207,13 @@ static u8 ratio2dB[100] = {
  * Conversion assumes that levels are voltages (20*log), not powers (10*log). */
 int iwl3945_calc_db_from_ratio(int sig_ratio)
 {
-	/* Anything above 1000:1 just report as 60 dB */
-	if (sig_ratio > 1000)
+	/* 1000:1 or higher just report as 60 dB */
+	if (sig_ratio >= 1000)
 		return 60;
 
-	/* Above 100:1, divide by 10 and use table,
+	/* 100:1 or higher, divide by 10 and use table,
 	 *   add 20 dB to make up for divide by 10 */
-	if (sig_ratio > 100)
+	if (sig_ratio >= 100)
 		return (20 + (int)ratio2dB[sig_ratio/10]);
 
 	/* We shouldn't see this */
diff --git a/include/linux/ssb/ssb.h b/include/linux/ssb/ssb.h
index e18f5c2..9d5da8b 100644
--- a/include/linux/ssb/ssb.h
+++ b/include/linux/ssb/ssb.h
@@ -373,6 +373,15 @@ void ssb_pcihost_set_power_state(struct ssb_device *sdev, pci_power_t state)
 	if (sdev->bus->bustype == SSB_BUSTYPE_PCI)
 		pci_set_power_state(sdev->bus->host_pci, state);
 }
+#else
+static inline void ssb_pcihost_unregister(struct pci_driver *driver)
+{
+}
+
+static inline
+void ssb_pcihost_set_power_state(struct ssb_device *sdev, pci_power_t state)
+{
+}
 #endif /* CONFIG_SSB_PCIHOST */
 
 
diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index e77592d..45c7c0c 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -1,6 +1,5 @@
 config MAC80211
 	tristate "Generic IEEE 802.11 Networking Stack (mac80211)"
-	depends on EXPERIMENTAL
 	select CRYPTO
 	select CRYPTO_ECB
 	select CRYPTO_ARC4
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
