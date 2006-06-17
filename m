From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH, RFT] bcm43xx: Busting the 1G limit
Date: Sat, 17 Jun 2006 19:28:07 +0200
Message-ID: <200606171928.08155.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:15020
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750744AbWFQR36
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jun 2006 13:29:58 -0400
To: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch adds full 32-bit and 64-bit DMA support
to the bcm43xx driver. Well, it _should_ do this. I can
not test it, as I don't have a machine to trigger the 1G
limit.
The 1G limit should be exploitable on an AMD64 machine
with more than 1G RAM.

Please test and report, if it works or not. In the
case of "works not", please provide full dmesg log.

Note that I am not sure which cards actually support
full 32-bit or even 64-bit mode. Older cards might still
only support 30-bit DMA.

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-06-17 17:48:26.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-06-17 18:01:34.000000000 +0200
@@ -32,14 +32,18 @@
 #define BCM43xx_PCICFG_ICR		0x94
 
 /* MMIO offsets */
-#define BCM43xx_MMIO_DMA1_REASON	0x20
-#define BCM43xx_MMIO_DMA1_IRQ_MASK	0x24
-#define BCM43xx_MMIO_DMA2_REASON	0x28
-#define BCM43xx_MMIO_DMA2_IRQ_MASK	0x2C
-#define BCM43xx_MMIO_DMA3_REASON	0x30
-#define BCM43xx_MMIO_DMA3_IRQ_MASK	0x34
-#define BCM43xx_MMIO_DMA4_REASON	0x38
-#define BCM43xx_MMIO_DMA4_IRQ_MASK	0x3C
+#define BCM43xx_MMIO_DMA0_REASON	0x20
+#define BCM43xx_MMIO_DMA0_IRQ_MASK	0x24
+#define BCM43xx_MMIO_DMA1_REASON	0x28
+#define BCM43xx_MMIO_DMA1_IRQ_MASK	0x2C
+#define BCM43xx_MMIO_DMA2_REASON	0x30
+#define BCM43xx_MMIO_DMA2_IRQ_MASK	0x34
+#define BCM43xx_MMIO_DMA3_REASON	0x38
+#define BCM43xx_MMIO_DMA3_IRQ_MASK	0x3C
+#define BCM43xx_MMIO_DMA4_REASON	0x40
+#define BCM43xx_MMIO_DMA4_IRQ_MASK	0x44
+#define BCM43xx_MMIO_DMA5_REASON	0x48
+#define BCM43xx_MMIO_DMA5_IRQ_MASK	0x4C
 #define BCM43xx_MMIO_STATUS_BITFIELD	0x120
 #define BCM43xx_MMIO_STATUS2_BITFIELD	0x124
 #define BCM43xx_MMIO_GEN_IRQ_REASON	0x128
@@ -55,14 +59,27 @@
 #define BCM43xx_MMIO_XMITSTAT_1		0x174
 #define BCM43xx_MMIO_REV3PLUS_TSF_LOW	0x180 /* core rev >= 3 only */
 #define BCM43xx_MMIO_REV3PLUS_TSF_HIGH	0x184 /* core rev >= 3 only */
-#define BCM43xx_MMIO_DMA1_BASE		0x200
-#define BCM43xx_MMIO_DMA2_BASE		0x220
-#define BCM43xx_MMIO_DMA3_BASE		0x240
-#define BCM43xx_MMIO_DMA4_BASE		0x260
+
+/* 32-bit DMA */
+#define BCM43xx_MMIO_DMA32_BASE0	0x200
+#define BCM43xx_MMIO_DMA32_BASE1	0x220
+#define BCM43xx_MMIO_DMA32_BASE2	0x240
+#define BCM43xx_MMIO_DMA32_BASE3	0x260
+#define BCM43xx_MMIO_DMA32_BASE4	0x280
+#define BCM43xx_MMIO_DMA32_BASE5	0x2A0
+/* 64-bit DMA */
+#define BCM43xx_MMIO_DMA64_BASE0	0x200
+#define BCM43xx_MMIO_DMA64_BASE1	0x240
+#define BCM43xx_MMIO_DMA64_BASE2	0x280
+#define BCM43xx_MMIO_DMA64_BASE3	0x2C0
+#define BCM43xx_MMIO_DMA64_BASE4	0x300
+#define BCM43xx_MMIO_DMA64_BASE5	0x340
+/* PIO */
 #define BCM43xx_MMIO_PIO1_BASE		0x300
 #define BCM43xx_MMIO_PIO2_BASE		0x310
 #define BCM43xx_MMIO_PIO3_BASE		0x320
 #define BCM43xx_MMIO_PIO4_BASE		0x330
+
 #define BCM43xx_MMIO_PHY_VER		0x3E0
 #define BCM43xx_MMIO_PHY_RADIO		0x3E2
 #define BCM43xx_MMIO_ANTENNA		0x3E8
@@ -231,8 +248,14 @@
 #define BCM43xx_SBTMSTATELOW_FORCE_GATE_CLOCK	0x20000
 
 /* sbtmstatehigh state flags */
-#define BCM43xx_SBTMSTATEHIGH_SERROR		0x1
-#define BCM43xx_SBTMSTATEHIGH_BUSY		0x4
+#define BCM43xx_SBTMSTATEHIGH_SERROR		0x00000001
+#define BCM43xx_SBTMSTATEHIGH_BUSY		0x00000004
+#define BCM43xx_SBTMSTATEHIGH_TIMEOUT		0x00000020
+#define BCM43xx_SBTMSTATEHIGH_COREFLAGS		0x1FFF0000
+#define BCM43xx_SBTMSTATEHIGH_DMA64BIT		0x10000000
+#define BCM43xx_SBTMSTATEHIGH_GATEDCLK		0x20000000
+#define BCM43xx_SBTMSTATEHIGH_BISTFAILED	0x40000000
+#define BCM43xx_SBTMSTATEHIGH_BISTCOMPLETE	0x80000000
 
 /* sbimstate flags */
 #define BCM43xx_SBIMSTATE_IB_ERROR		0x20000
@@ -566,8 +589,11 @@
 	struct bcm43xx_dmaring *tx_ring1;
 	struct bcm43xx_dmaring *tx_ring2;
 	struct bcm43xx_dmaring *tx_ring3;
+	struct bcm43xx_dmaring *tx_ring4;
+	struct bcm43xx_dmaring *tx_ring5;
+
 	struct bcm43xx_dmaring *rx_ring0;
-	struct bcm43xx_dmaring *rx_ring1; /* only available on core.rev < 5 */
+	struct bcm43xx_dmaring *rx_ring3; /* only available on core.rev < 5 */
 };
 
 /* Data structures for PIO transmission, per 80211 core. */
@@ -708,7 +734,7 @@
 
 	/* Reason code of the last interrupt. */
 	u32 irq_reason;
-	u32 dma_reason[4];
+	u32 dma_reason[6];
 	/* saved irq enable/disable state bitfield. */
 	u32 irq_savedstate;
 	/* Link Quality calculation context. */
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_dma.c	2006-06-17 17:48:26.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_dma.c	2006-06-17 19:18:41.000000000 +0200
@@ -4,7 +4,7 @@
 
   DMA ringbuffer and descriptor allocation/management
 
-  Copyright (c) 2005 Michael Buesch <mbuesch@freenet.de>
+  Copyright (c) 2005, 2006 Michael Buesch <mbuesch@freenet.de>
 
   Some code in this file is derived from the b44.c driver
   Copyright (C) 2002 David S. Miller
@@ -109,6 +109,35 @@
 	}
 }
 
+u16 bcm43xx_dmacontroller_base(int dma64bit, int controller_idx)
+{
+	static const u16 map64[] = {
+		BCM43xx_MMIO_DMA64_BASE0,
+		BCM43xx_MMIO_DMA64_BASE1,
+		BCM43xx_MMIO_DMA64_BASE2,
+		BCM43xx_MMIO_DMA64_BASE3,
+		BCM43xx_MMIO_DMA64_BASE4,
+		BCM43xx_MMIO_DMA64_BASE5,
+	};
+	static const u16 map32[] = {
+		BCM43xx_MMIO_DMA32_BASE0,
+		BCM43xx_MMIO_DMA32_BASE1,
+		BCM43xx_MMIO_DMA32_BASE2,
+		BCM43xx_MMIO_DMA32_BASE3,
+		BCM43xx_MMIO_DMA32_BASE4,
+		BCM43xx_MMIO_DMA32_BASE5,
+	};
+
+	if (dma64bit) {
+		assert(controller_idx >= 0 ||
+		       controller_idx < ARRAY_SIZE(map64));
+		return map64[controller_idx];
+	}
+	assert(controller_idx >= 0 ||
+	       controller_idx < ARRAY_SIZE(map32));
+	return map32[controller_idx];
+}
+
 static inline
 dma_addr_t map_descbuffer(struct bcm43xx_dmaring *ring,
 			  unsigned char *buf,
@@ -172,7 +201,6 @@
 /* Unmap and free a descriptor buffer. */
 static inline
 void free_descriptor_buffer(struct bcm43xx_dmaring *ring,
-			    struct bcm43xx_dmadesc *desc,
 			    struct bcm43xx_dmadesc_meta *meta,
 			    int irq_context)
 {
@@ -188,23 +216,13 @@
 {
 	struct device *dev = &(ring->bcm->pci_dev->dev);
 
-	ring->vbase = dma_alloc_coherent(dev, BCM43xx_DMA_RINGMEMSIZE,
-					 &(ring->dmabase), GFP_KERNEL);
-	if (!ring->vbase) {
+	ring->descbase = dma_alloc_coherent(dev, BCM43xx_DMA_RINGMEMSIZE,
+					    &(ring->dmabase), GFP_KERNEL);
+	if (!ring->descbase) {
 		printk(KERN_ERR PFX "DMA ringmemory allocation failed\n");
 		return -ENOMEM;
 	}
-	if (ring->dmabase + BCM43xx_DMA_RINGMEMSIZE > BCM43xx_DMA_BUSADDRMAX) {
-		printk(KERN_ERR PFX ">>>FATAL ERROR<<<  DMA RINGMEMORY >1G "
-				    "(0x%llx, len: %lu)\n",
-				(unsigned long long)ring->dmabase,
-				BCM43xx_DMA_RINGMEMSIZE);
-		dma_free_coherent(dev, BCM43xx_DMA_RINGMEMSIZE,
-				  ring->vbase, ring->dmabase);
-		return -ENOMEM;
-	}
-	assert(!(ring->dmabase & 0x000003FF));
-	memset(ring->vbase, 0, BCM43xx_DMA_RINGMEMSIZE);
+	memset(ring->descbase, 0, BCM43xx_DMA_RINGMEMSIZE);
 
 	return 0;
 }
@@ -214,26 +232,34 @@
 	struct device *dev = &(ring->bcm->pci_dev->dev);
 
 	dma_free_coherent(dev, BCM43xx_DMA_RINGMEMSIZE,
-			  ring->vbase, ring->dmabase);
+			  ring->descbase, ring->dmabase);
 }
 
 /* Reset the RX DMA channel */
 int bcm43xx_dmacontroller_rx_reset(struct bcm43xx_private *bcm,
-				   u16 mmio_base)
+				   u16 mmio_base, int dma64)
 {
 	int i;
 	u32 value;
+	u16 offset;
 
-	bcm43xx_write32(bcm,
-			mmio_base + BCM43xx_DMA_RX_CONTROL,
-			0x00000000);
+	offset = dma64 ? BCM43xx_DMA64_RXCTL : BCM43xx_DMA32_RXCTL;
+	bcm43xx_write32(bcm, mmio_base + offset, 0);
 	for (i = 0; i < 1000; i++) {
-		value = bcm43xx_read32(bcm,
-				       mmio_base + BCM43xx_DMA_RX_STATUS);
-		value &= BCM43xx_DMA_RXSTAT_STAT_MASK;
-		if (value == BCM43xx_DMA_RXSTAT_STAT_DISABLED) {
-			i = -1;
-			break;
+		offset = dma64 ? BCM43xx_DMA64_RXSTATUS : BCM43xx_DMA32_RXSTATUS;
+		value = bcm43xx_read32(bcm, mmio_base + offset);
+		if (dma64) {
+			value &= BCM43xx_DMA64_RXSTAT;
+			if (value == BCM43xx_DMA64_RXSTAT_DISABLED) {
+				i = -1;
+				break;
+			}
+		} else {
+			value &= BCM43xx_DMA32_RXSTATE;
+			if (value == BCM43xx_DMA32_RXSTAT_DISABLED) {
+				i = -1;
+				break;
+			}
 		}
 		udelay(10);
 	}
@@ -247,31 +273,47 @@
 
 /* Reset the RX DMA channel */
 int bcm43xx_dmacontroller_tx_reset(struct bcm43xx_private *bcm,
-				   u16 mmio_base)
+				   u16 mmio_base, int dma64)
 {
 	int i;
 	u32 value;
+	u16 offset;
 
 	for (i = 0; i < 1000; i++) {
-		value = bcm43xx_read32(bcm,
-				       mmio_base + BCM43xx_DMA_TX_STATUS);
-		value &= BCM43xx_DMA_TXSTAT_STAT_MASK;
-		if (value == BCM43xx_DMA_TXSTAT_STAT_DISABLED ||
-		    value == BCM43xx_DMA_TXSTAT_STAT_IDLEWAIT ||
-		    value == BCM43xx_DMA_TXSTAT_STAT_STOPPED)
-			break;
+		offset = dma64 ? BCM43xx_DMA64_TXSTATUS : BCM43xx_DMA32_TXSTATUS;
+		value = bcm43xx_read32(bcm, mmio_base + offset);
+		if (dma64) {
+			value &= BCM43xx_DMA64_TXSTAT;
+			if (value == BCM43xx_DMA64_TXSTAT_DISABLED ||
+			    value == BCM43xx_DMA64_TXSTAT_IDLEWAIT ||
+			    value == BCM43xx_DMA64_TXSTAT_STOPPED)
+				break;
+		} else {
+			value &= BCM43xx_DMA32_TXSTATE;
+			if (value == BCM43xx_DMA32_TXSTAT_DISABLED ||
+			    value == BCM43xx_DMA32_TXSTAT_IDLEWAIT ||
+			    value == BCM43xx_DMA32_TXSTAT_STOPPED)
+				break;
+		}
 		udelay(10);
 	}
-	bcm43xx_write32(bcm,
-			mmio_base + BCM43xx_DMA_TX_CONTROL,
-			0x00000000);
+	offset = dma64 ? BCM43xx_DMA64_TXCTL : BCM43xx_DMA32_TXCTL;
+	bcm43xx_write32(bcm, mmio_base + offset, 0);
 	for (i = 0; i < 1000; i++) {
-		value = bcm43xx_read32(bcm,
-				       mmio_base + BCM43xx_DMA_TX_STATUS);
-		value &= BCM43xx_DMA_TXSTAT_STAT_MASK;
-		if (value == BCM43xx_DMA_TXSTAT_STAT_DISABLED) {
-			i = -1;
-			break;
+		offset = dma64 ? BCM43xx_DMA64_TXSTATUS : BCM43xx_DMA32_TXSTATUS;
+		value = bcm43xx_read32(bcm, mmio_base + offset);
+		if (dma64) {
+			value &= BCM43xx_DMA64_TXSTAT;
+			if (value == BCM43xx_DMA64_TXSTAT_DISABLED) {
+				i = -1;
+				break;
+			}
+		} else {
+			value &= BCM43xx_DMA32_TXSTATE;
+			if (value == BCM43xx_DMA32_TXSTAT_DISABLED) {
+				i = -1;
+				break;
+			}
 		}
 		udelay(10);
 	}
@@ -285,47 +327,98 @@
 	return 0;
 }
 
+static void fill_descriptor(struct bcm43xx_dmaring *ring,
+			    struct bcm43xx_dmadesc_generic *desc,
+			    dma_addr_t dmaaddr,
+			    u16 bufsize,
+			    int start, int end, int irq)
+{
+	int slot;
+
+	slot = bcm43xx_dma_desc2idx(ring, desc);
+	assert(slot >= 0 && slot < ring->nr_slots);
+
+	if (ring->dma64) {
+		u32 ctl0 = 0, ctl1 = 0;
+		u32 addrlo, addrhi;
+		u32 addrext;
+
+		addrlo = (u32)(dmaaddr & 0xFFFFFFFF);
+		addrhi = (((u64)dmaaddr >> 32) & ~BCM43xx_DMA64_ROUTING);
+		addrext = (((u64)dmaaddr >> 32) >> BCM43xx_DMA64_ROUTING_SHIFT);
+		addrhi |= ring->routing;
+		if (slot == ring->nr_slots - 1)
+			ctl0 |= BCM43xx_DMA64_DCTL0_DTABLEEND;
+		if (start)
+			ctl0 |= BCM43xx_DMA64_DCTL0_FRAMESTART;
+		if (end)
+			ctl0 |= BCM43xx_DMA64_DCTL0_FRAMEEND;
+		if (irq)
+			ctl0 |= BCM43xx_DMA64_DCTL0_IRQ;
+		ctl1 |= (bufsize - ring->frameoffset)
+			& BCM43xx_DMA64_DCTL1_BYTECNT;
+		ctl1 |= (addrext << BCM43xx_DMA64_DCTL1_ADDREXT_SHIFT)
+			& BCM43xx_DMA64_DCTL1_ADDREXT_MASK;
+
+		desc->dma64.control0 = cpu_to_le32(ctl0);
+		desc->dma64.control1 = cpu_to_le32(ctl1);
+		desc->dma64.address_low = cpu_to_le32(addrlo);
+		desc->dma64.address_high = cpu_to_le32(addrhi);
+	} else {
+		u32 ctl;
+		u32 addr;
+		u32 addrext;
+
+		addr = (u32)(dmaaddr & ~BCM43xx_DMA32_ROUTING);
+		addrext = (u32)(dmaaddr & BCM43xx_DMA32_ROUTING)
+			   >> BCM43xx_DMA32_ROUTING_SHIFT;
+		addr |= ring->routing;
+		ctl = (bufsize - ring->frameoffset)
+		      & BCM43xx_DMA32_DCTL_BYTECNT;
+		if (slot == ring->nr_slots - 1)
+			ctl |= BCM43xx_DMA32_DCTL_DTABLEEND;
+		if (start)
+			ctl |= BCM43xx_DMA32_DCTL_FRAMESTART;
+		if (end)
+			ctl |= BCM43xx_DMA32_DCTL_FRAMEEND;
+		if (irq)
+			ctl |= BCM43xx_DMA32_DCTL_IRQ;
+		ctl |= (addrext << BCM43xx_DMA32_DCTL_ADDREXT_SHIFT)
+		       & BCM43xx_DMA32_DCTL_ADDREXT_MASK;
+
+		desc->dma32.control = cpu_to_le32(ctl);
+		desc->dma32.address = cpu_to_le32(addr);
+	}
+}
+
 static int setup_rx_descbuffer(struct bcm43xx_dmaring *ring,
-			       struct bcm43xx_dmadesc *desc,
+			       struct bcm43xx_dmadesc_generic *desc,
 			       struct bcm43xx_dmadesc_meta *meta,
 			       gfp_t gfp_flags)
 {
 	struct bcm43xx_rxhdr *rxhdr;
+	struct bcm43xx_hwxmitstatus *xmitstat;
 	dma_addr_t dmaaddr;
-	u32 desc_addr;
-	u32 desc_ctl;
-	const int slot = (int)(desc - ring->vbase);
 	struct sk_buff *skb;
 
-	assert(slot >= 0 && slot < ring->nr_slots);
 	assert(!ring->tx);
 
 	skb = __dev_alloc_skb(ring->rx_buffersize, gfp_flags);
 	if (unlikely(!skb))
 		return -ENOMEM;
 	dmaaddr = map_descbuffer(ring, skb->data, ring->rx_buffersize, 0);
-	if (unlikely(dmaaddr + ring->rx_buffersize > BCM43xx_DMA_BUSADDRMAX)) {
-		unmap_descbuffer(ring, dmaaddr, ring->rx_buffersize, 0);
-		dev_kfree_skb_any(skb);
-		printk(KERN_ERR PFX ">>>FATAL ERROR<<<  DMA RX SKB >1G "
-				    "(0x%llx, len: %u)\n",
-			(unsigned long long)dmaaddr, ring->rx_buffersize);
-		return -ENOMEM;
-	}
 	meta->skb = skb;
 	meta->dmaaddr = dmaaddr;
 	skb->dev = ring->bcm->net_dev;
-	desc_addr = (u32)(dmaaddr + ring->memoffset);
-	desc_ctl = (BCM43xx_DMADTOR_BYTECNT_MASK &
-		    (u32)(ring->rx_buffersize - ring->frameoffset));
-	if (slot == ring->nr_slots - 1)
-		desc_ctl |= BCM43xx_DMADTOR_DTABLEEND;
-	set_desc_addr(desc, desc_addr);
-	set_desc_ctl(desc, desc_ctl);
+
+	fill_descriptor(ring, desc, dmaaddr,
+			ring->rx_buffersize, 0, 0, 0);
 
 	rxhdr = (struct bcm43xx_rxhdr *)(skb->data);
 	rxhdr->frame_length = 0;
 	rxhdr->flags1 = 0;
+	xmitstat = (struct bcm43xx_hwxmitstatus *)(skb->data);
+	xmitstat->cookie = 0;
 
 	return 0;
 }
@@ -336,17 +429,17 @@
 static int alloc_initial_descbuffers(struct bcm43xx_dmaring *ring)
 {
 	int i, err = -ENOMEM;
-	struct bcm43xx_dmadesc *desc;
+	struct bcm43xx_dmadesc_generic *desc;
 	struct bcm43xx_dmadesc_meta *meta;
 
 	for (i = 0; i < ring->nr_slots; i++) {
-		desc = ring->vbase + i;
-		meta = ring->meta + i;
+		desc = bcm43xx_dma_idx2desc(ring, i, &meta);
 
 		err = setup_rx_descbuffer(ring, desc, meta, GFP_KERNEL);
 		if (err)
 			goto err_unwind;
 	}
+	mb();
 	ring->used_slots = ring->nr_slots;
 	err = 0;
 out:
@@ -354,8 +447,7 @@
 
 err_unwind:
 	for (i--; i >= 0; i--) {
-		desc = ring->vbase + i;
-		meta = ring->meta + i;
+		desc = bcm43xx_dma_idx2desc(ring, i, &meta);
 
 		unmap_descbuffer(ring, meta->dmaaddr, ring->rx_buffersize, 0);
 		dev_kfree_skb(meta->skb);
@@ -371,27 +463,67 @@
 {
 	int err = 0;
 	u32 value;
+	u32 addrext;
 
 	if (ring->tx) {
-		/* Set Transmit Control register to "transmit enable" */
-		bcm43xx_dma_write(ring, BCM43xx_DMA_TX_CONTROL,
-				  BCM43xx_DMA_TXCTRL_ENABLE);
-		/* Set Transmit Descriptor ring address. */
-		bcm43xx_dma_write(ring, BCM43xx_DMA_TX_DESC_RING,
-				  ring->dmabase + ring->memoffset);
+		if (ring->dma64) {
+			u64 ringbase = (u64)(ring->dmabase);
+
+			addrext = ((ringbase >> 32) >> BCM43xx_DMA64_ROUTING_SHIFT);
+			value = BCM43xx_DMA64_TXENABLE;
+			value |= (addrext << BCM43xx_DMA64_TXADDREXT_SHIFT)
+				& BCM43xx_DMA64_TXADDREXT_MASK;
+			bcm43xx_dma_write(ring, BCM43xx_DMA64_TXCTL, value);
+			bcm43xx_dma_write(ring, BCM43xx_DMA64_TXRINGLO,
+					(ringbase & 0xFFFFFFFF));
+			bcm43xx_dma_write(ring, BCM43xx_DMA64_TXRINGHI,
+					((ringbase >> 32) & ~BCM43xx_DMA64_ROUTING)
+					| ring->routing);
+		} else {
+			u32 ringbase = (u32)(ring->dmabase);
+
+			addrext = (ringbase >> BCM43xx_DMA32_ROUTING_SHIFT);
+			value = BCM43xx_DMA32_TXENABLE;
+			value |= (addrext << BCM43xx_DMA32_TXADDREXT_SHIFT)
+				& BCM43xx_DMA32_TXADDREXT_MASK;
+			bcm43xx_dma_write(ring, BCM43xx_DMA32_TXCTL, value);
+			bcm43xx_dma_write(ring, BCM43xx_DMA32_TXRING,
+					(ringbase & ~BCM43xx_DMA32_ROUTING)
+					| ring->routing);
+		}
 	} else {
 		err = alloc_initial_descbuffers(ring);
 		if (err)
 			goto out;
-		/* Set Receive Control "receive enable" and frame offset */
-		value = (ring->frameoffset << BCM43xx_DMA_RXCTRL_FRAMEOFF_SHIFT);
-		value |= BCM43xx_DMA_RXCTRL_ENABLE;
-		bcm43xx_dma_write(ring, BCM43xx_DMA_RX_CONTROL, value);
-		/* Set Receive Descriptor ring address. */
-		bcm43xx_dma_write(ring, BCM43xx_DMA_RX_DESC_RING,
-				  ring->dmabase + ring->memoffset);
-		/* Init the descriptor pointer. */
-		bcm43xx_dma_write(ring, BCM43xx_DMA_RX_DESC_INDEX, 200);
+		if (ring->dma64) {
+			u64 ringbase = (u64)(ring->dmabase);
+
+			addrext = ((ringbase >> 32) >> BCM43xx_DMA64_ROUTING_SHIFT);
+			value = (ring->frameoffset << BCM43xx_DMA64_RXFROFF_SHIFT);
+			value |= BCM43xx_DMA64_RXENABLE;
+			value |= (addrext << BCM43xx_DMA64_RXADDREXT_SHIFT)
+				& BCM43xx_DMA64_RXADDREXT_MASK;
+			bcm43xx_dma_write(ring, BCM43xx_DMA64_RXCTL, value);
+			bcm43xx_dma_write(ring, BCM43xx_DMA64_RXRINGLO,
+					(ringbase & 0xFFFFFFFF));
+			bcm43xx_dma_write(ring, BCM43xx_DMA64_RXRINGHI,
+					((ringbase >> 32) & ~BCM43xx_DMA64_ROUTING)
+					| ring->routing);
+			bcm43xx_dma_write(ring, BCM43xx_DMA64_RXINDEX, 200);
+		} else {
+			u32 ringbase = (u32)(ring->dmabase);
+
+			addrext = (ringbase >> BCM43xx_DMA32_ROUTING_SHIFT);
+			value = (ring->frameoffset << BCM43xx_DMA32_RXFROFF_SHIFT);
+			value |= BCM43xx_DMA32_RXENABLE;
+			value |= (addrext << BCM43xx_DMA32_RXADDREXT_SHIFT)
+				& BCM43xx_DMA32_RXADDREXT_MASK;
+			bcm43xx_dma_write(ring, BCM43xx_DMA32_RXCTL, value);
+			bcm43xx_dma_write(ring, BCM43xx_DMA32_RXRING,
+					(ringbase & ~BCM43xx_DMA32_ROUTING)
+					| ring->routing);
+			bcm43xx_dma_write(ring, BCM43xx_DMA32_RXINDEX, 200);
+		}
 	}
 
 out:
@@ -402,27 +534,32 @@
 static void dmacontroller_cleanup(struct bcm43xx_dmaring *ring)
 {
 	if (ring->tx) {
-		bcm43xx_dmacontroller_tx_reset(ring->bcm, ring->mmio_base);
-		/* Zero out Transmit Descriptor ring address. */
-		bcm43xx_dma_write(ring, BCM43xx_DMA_TX_DESC_RING, 0);
+		bcm43xx_dmacontroller_tx_reset(ring->bcm, ring->mmio_base, ring->dma64);
+		if (ring->dma64) {
+			bcm43xx_dma_write(ring, BCM43xx_DMA64_TXRINGLO, 0);
+			bcm43xx_dma_write(ring, BCM43xx_DMA64_TXRINGHI, 0);
+		} else
+			bcm43xx_dma_write(ring, BCM43xx_DMA32_TXRING, 0);
 	} else {
-		bcm43xx_dmacontroller_rx_reset(ring->bcm, ring->mmio_base);
-		/* Zero out Receive Descriptor ring address. */
-		bcm43xx_dma_write(ring, BCM43xx_DMA_RX_DESC_RING, 0);
+		bcm43xx_dmacontroller_rx_reset(ring->bcm, ring->mmio_base, ring->dma64);
+		if (ring->dma64) {
+			bcm43xx_dma_write(ring, BCM43xx_DMA64_RXRINGLO, 0);
+			bcm43xx_dma_write(ring, BCM43xx_DMA64_RXRINGHI, 0);
+		} else
+			bcm43xx_dma_write(ring, BCM43xx_DMA32_RXRING, 0);
 	}
 }
 
 static void free_all_descbuffers(struct bcm43xx_dmaring *ring)
 {
-	struct bcm43xx_dmadesc *desc;
+	struct bcm43xx_dmadesc_generic *desc;
 	struct bcm43xx_dmadesc_meta *meta;
 	int i;
 
 	if (!ring->used_slots)
 		return;
 	for (i = 0; i < ring->nr_slots; i++) {
-		desc = ring->vbase + i;
-		meta = ring->meta + i;
+		desc = bcm43xx_dma_idx2desc(ring, i, &meta);
 
 		if (!meta->skb) {
 			assert(ring->tx);
@@ -430,62 +567,67 @@
 		}
 		if (ring->tx) {
 			unmap_descbuffer(ring, meta->dmaaddr,
-					 meta->skb->len, 1);
+					meta->skb->len, 1);
 		} else {
 			unmap_descbuffer(ring, meta->dmaaddr,
-					 ring->rx_buffersize, 0);
+					ring->rx_buffersize, 0);
 		}
-		free_descriptor_buffer(ring, desc, meta, 0);
+		free_descriptor_buffer(ring, meta, 0);
 	}
 }
 
 /* Main initialization function. */
 static
 struct bcm43xx_dmaring * bcm43xx_setup_dmaring(struct bcm43xx_private *bcm,
-					       u16 dma_controller_base,
-					       int nr_descriptor_slots,
-					       int tx)
+					       int controller_index,
+					       int for_tx,
+					       int dma64)
 {
 	struct bcm43xx_dmaring *ring;
 	int err;
+	int nr_slots;
 
 	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 	if (!ring)
 		goto out;
 
-	ring->meta = kzalloc(sizeof(*ring->meta) * nr_descriptor_slots,
-			     GFP_KERNEL);
+	nr_slots = BCM43xx_RXRING_SLOTS;
+	if (for_tx)
+		nr_slots = BCM43xx_TXRING_SLOTS;
+
+	ring->meta = kzalloc(sizeof(*ring->meta) * nr_slots,
+			GFP_KERNEL);
 	if (!ring->meta)
 		goto err_kfree_ring;
 
-	ring->memoffset = BCM43xx_DMA_DMABUSADDROFFSET;
+	ring->routing = BCM43xx_DMA32_CLIENTTRANS;
+	if (dma64)
+		ring->routing = BCM43xx_DMA64_CLIENTTRANS;
 #ifdef CONFIG_BCM947XX
 	if (bcm->pci_dev->bus->number == 0)
-		ring->memoffset = 0;
+		ring->routing = dma64 ? BCM43xx_DMA64_NOTRANS : BCM43xx_DMA32_NOTRANS;
 #endif
 
 	ring->bcm = bcm;
-	ring->nr_slots = nr_descriptor_slots;
+	ring->nr_slots = nr_slots;
 	ring->suspend_mark = ring->nr_slots * BCM43xx_TXSUSPEND_PERCENT / 100;
 	ring->resume_mark = ring->nr_slots * BCM43xx_TXRESUME_PERCENT / 100;
 	assert(ring->suspend_mark < ring->resume_mark);
-	ring->mmio_base = dma_controller_base;
-	if (tx) {
+	ring->mmio_base = bcm43xx_dmacontroller_base(dma64, controller_index);
+	ring->index = controller_index;
+	ring->dma64 = !!dma64;
+	if (for_tx) {
 		ring->tx = 1;
 		ring->current_slot = -1;
 	} else {
-		switch (dma_controller_base) {
-		case BCM43xx_MMIO_DMA1_BASE:
-			ring->rx_buffersize = BCM43xx_DMA1_RXBUFFERSIZE;
-			ring->frameoffset = BCM43xx_DMA1_RX_FRAMEOFFSET;
-			break;
-		case BCM43xx_MMIO_DMA4_BASE:
-			ring->rx_buffersize = BCM43xx_DMA4_RXBUFFERSIZE;
-			ring->frameoffset = BCM43xx_DMA4_RX_FRAMEOFFSET;
-			break;
-		default:
+		if (ring->index == 0) {
+			ring->rx_buffersize = BCM43xx_DMA0_RX_BUFFERSIZE;
+			ring->frameoffset = BCM43xx_DMA0_RX_FRAMEOFFSET;
+		} else if (ring->index == 3) {
+			ring->rx_buffersize = BCM43xx_DMA3_RX_BUFFERSIZE;
+			ring->frameoffset = BCM43xx_DMA3_RX_FRAMEOFFSET;
+		} else
 			assert(0);
-		}
 	}
 
 	err = alloc_ringmemory(ring);
@@ -514,7 +656,8 @@
 	if (!ring)
 		return;
 
-	dprintk(KERN_INFO PFX "DMA 0x%04x (%s) max used slots: %d/%d\n",
+	dprintk(KERN_INFO PFX "DMA-%s 0x%04X (%s) max used slots: %d/%d\n",
+		(ring->dma64) ? "64" : "32",
 		ring->mmio_base,
 		(ring->tx) ? "TX" : "RX",
 		ring->max_used_slots, ring->nr_slots);
@@ -537,10 +680,15 @@
 		return;
 	dma = bcm43xx_current_dma(bcm);
 
-	bcm43xx_destroy_dmaring(dma->rx_ring1);
-	dma->rx_ring1 = NULL;
+	bcm43xx_destroy_dmaring(dma->rx_ring3);
+	dma->rx_ring3 = NULL;
 	bcm43xx_destroy_dmaring(dma->rx_ring0);
 	dma->rx_ring0 = NULL;
+
+	bcm43xx_destroy_dmaring(dma->tx_ring5);
+	dma->tx_ring5 = NULL;
+	bcm43xx_destroy_dmaring(dma->tx_ring4);
+	dma->tx_ring4 = NULL;
 	bcm43xx_destroy_dmaring(dma->tx_ring3);
 	dma->tx_ring3 = NULL;
 	bcm43xx_destroy_dmaring(dma->tx_ring2);
@@ -556,48 +704,59 @@
 	struct bcm43xx_dma *dma = bcm43xx_current_dma(bcm);
 	struct bcm43xx_dmaring *ring;
 	int err = -ENOMEM;
+	int dma64 = 0;
+	u32 sbtmstatehi;
+
+	sbtmstatehi = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATEHIGH);
+	if (sbtmstatehi & BCM43xx_SBTMSTATEHIGH_DMA64BIT)
+		dma64 = 1;
 
 	/* setup TX DMA channels. */
-	ring = bcm43xx_setup_dmaring(bcm, BCM43xx_MMIO_DMA1_BASE,
-				     BCM43xx_TXRING_SLOTS, 1);
+	ring = bcm43xx_setup_dmaring(bcm, 0, 1, dma64);
 	if (!ring)
 		goto out;
 	dma->tx_ring0 = ring;
 
-	ring = bcm43xx_setup_dmaring(bcm, BCM43xx_MMIO_DMA2_BASE,
-				     BCM43xx_TXRING_SLOTS, 1);
+	ring = bcm43xx_setup_dmaring(bcm, 1, 1, dma64);
 	if (!ring)
 		goto err_destroy_tx0;
 	dma->tx_ring1 = ring;
 
-	ring = bcm43xx_setup_dmaring(bcm, BCM43xx_MMIO_DMA3_BASE,
-				     BCM43xx_TXRING_SLOTS, 1);
+	ring = bcm43xx_setup_dmaring(bcm, 2, 1, dma64);
 	if (!ring)
 		goto err_destroy_tx1;
 	dma->tx_ring2 = ring;
 
-	ring = bcm43xx_setup_dmaring(bcm, BCM43xx_MMIO_DMA4_BASE,
-				     BCM43xx_TXRING_SLOTS, 1);
+	ring = bcm43xx_setup_dmaring(bcm, 3, 1, dma64);
 	if (!ring)
 		goto err_destroy_tx2;
 	dma->tx_ring3 = ring;
 
-	/* setup RX DMA channels. */
-	ring = bcm43xx_setup_dmaring(bcm, BCM43xx_MMIO_DMA1_BASE,
-				     BCM43xx_RXRING_SLOTS, 0);
+	ring = bcm43xx_setup_dmaring(bcm, 4, 1, dma64);
 	if (!ring)
 		goto err_destroy_tx3;
+	dma->tx_ring4 = ring;
+
+	ring = bcm43xx_setup_dmaring(bcm, 5, 1, dma64);
+	if (!ring)
+		goto err_destroy_tx4;
+	dma->tx_ring5 = ring;
+
+	/* setup RX DMA channels. */
+	ring = bcm43xx_setup_dmaring(bcm, 0, 0, dma64);
+	if (!ring)
+		goto err_destroy_tx5;
 	dma->rx_ring0 = ring;
 
 	if (bcm->current_core->rev < 5) {
-		ring = bcm43xx_setup_dmaring(bcm, BCM43xx_MMIO_DMA4_BASE,
-					     BCM43xx_RXRING_SLOTS, 0);
+		ring = bcm43xx_setup_dmaring(bcm, 3, 0, dma64);
 		if (!ring)
 			goto err_destroy_rx0;
-		dma->rx_ring1 = ring;
+		dma->rx_ring3 = ring;
 	}
 
-	dprintk(KERN_INFO PFX "DMA initialized\n");
+	dprintk(KERN_INFO PFX "%s DMA initialized\n",
+			dma64 ? "64-bit" : "32-bit");
 	err = 0;
 out:
 	return err;
@@ -605,6 +764,12 @@
 err_destroy_rx0:
 	bcm43xx_destroy_dmaring(dma->rx_ring0);
 	dma->rx_ring0 = NULL;
+err_destroy_tx5:
+	bcm43xx_destroy_dmaring(dma->tx_ring5);
+	dma->tx_ring5 = NULL;
+err_destroy_tx4:
+	bcm43xx_destroy_dmaring(dma->tx_ring4);
+	dma->tx_ring4 = NULL;
 err_destroy_tx3:
 	bcm43xx_destroy_dmaring(dma->tx_ring3);
 	dma->tx_ring3 = NULL;
@@ -624,7 +789,7 @@
 static u16 generate_cookie(struct bcm43xx_dmaring *ring,
 			   int slot)
 {
-	u16 cookie = 0xF000;
+	u16 cookie = 0x1000;
 
 	/* Use the upper 4 bits of the cookie as
 	 * DMA controller ID and store the slot number
@@ -632,21 +797,25 @@
 	 * Note that the cookie must never be 0, as this
 	 * is a special value used in RX path.
 	 */
-	switch (ring->mmio_base) {
-	default:
-		assert(0);
-	case BCM43xx_MMIO_DMA1_BASE:
+	switch (ring->index) {
+	case 0:
 		cookie = 0xA000;
 		break;
-	case BCM43xx_MMIO_DMA2_BASE:
+	case 1:
 		cookie = 0xB000;
 		break;
-	case BCM43xx_MMIO_DMA3_BASE:
+	case 2:
 		cookie = 0xC000;
 		break;
-	case BCM43xx_MMIO_DMA4_BASE:
+	case 3:
 		cookie = 0xD000;
 		break;
+	case 4:
+		cookie = 0xE000;
+		break;
+	case 5:
+		cookie = 0xF000;
+		break;
 	}
 	assert(((u16)slot & 0xF000) == 0x0000);
 	cookie |= (u16)slot;
@@ -675,6 +844,12 @@
 	case 0xD000:
 		ring = dma->tx_ring3;
 		break;
+	case 0xE000:
+		ring = dma->tx_ring4;
+		break;
+	case 0xF000:
+		ring = dma->tx_ring5;
+		break;
 	default:
 		assert(0);
 	}
@@ -687,6 +862,9 @@
 static void dmacontroller_poke_tx(struct bcm43xx_dmaring *ring,
 				  int slot)
 {
+	u16 offset;
+	int descsize;
+
 	/* Everything is ready to start. Buffers are DMA mapped and
 	 * associated with slots.
 	 * "slot" is the last slot of the new frame we want to transmit.
@@ -694,25 +872,26 @@
 	 */
 	wmb();
 	slot = next_slot(ring, slot);
-	bcm43xx_dma_write(ring, BCM43xx_DMA_TX_DESC_INDEX,
-			  (u32)(slot * sizeof(struct bcm43xx_dmadesc)));
+	offset = (ring->dma64) ? BCM43xx_DMA64_TXINDEX : BCM43xx_DMA32_TXINDEX;
+	descsize = (ring->dma64) ? sizeof(struct bcm43xx_dmadesc64)
+		: sizeof(struct bcm43xx_dmadesc32);
+	bcm43xx_dma_write(ring, offset,
+			(u32)(slot * descsize));
 }
 
-static int dma_tx_fragment(struct bcm43xx_dmaring *ring,
-			   struct sk_buff *skb,
-			   u8 cur_frag)
+static void dma_tx_fragment(struct bcm43xx_dmaring *ring,
+			    struct sk_buff *skb,
+			    u8 cur_frag)
 {
 	int slot;
-	struct bcm43xx_dmadesc *desc;
+	struct bcm43xx_dmadesc_generic *desc;
 	struct bcm43xx_dmadesc_meta *meta;
-	u32 desc_ctl;
-	u32 desc_addr;
+	dma_addr_t dmaaddr;
 
 	assert(skb_shinfo(skb)->nr_frags == 0);
 
 	slot = request_slot(ring);
-	desc = ring->vbase + slot;
-	meta = ring->meta + slot;
+	desc = bcm43xx_dma_idx2desc(ring, slot, &meta);
 
 	/* Add a device specific TX header. */
 	assert(skb_headroom(skb) >= sizeof(struct bcm43xx_txhdr));
@@ -729,29 +908,14 @@
 			       generate_cookie(ring, slot));
 
 	meta->skb = skb;
-	meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
-	if (unlikely(meta->dmaaddr + skb->len > BCM43xx_DMA_BUSADDRMAX)) {
-		return_slot(ring, slot);
-		printk(KERN_ERR PFX ">>>FATAL ERROR<<<  DMA TX SKB >1G "
-				    "(0x%llx, len: %u)\n",
-			(unsigned long long)meta->dmaaddr, skb->len);
-		return -ENOMEM;
-	}
+	dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
+	meta->dmaaddr = dmaaddr;
 
-	desc_addr = (u32)(meta->dmaaddr + ring->memoffset);
-	desc_ctl = BCM43xx_DMADTOR_FRAMESTART | BCM43xx_DMADTOR_FRAMEEND;
-	desc_ctl |= BCM43xx_DMADTOR_COMPIRQ;
-	desc_ctl |= (BCM43xx_DMADTOR_BYTECNT_MASK &
-		     (u32)(meta->skb->len - ring->frameoffset));
-	if (slot == ring->nr_slots - 1)
-		desc_ctl |= BCM43xx_DMADTOR_DTABLEEND;
+	fill_descriptor(ring, desc, dmaaddr,
+			skb->len, 1, 1, 1);
 
-	set_desc_ctl(desc, desc_ctl);
-	set_desc_addr(desc, desc_addr);
 	/* Now transfer the whole frame. */
 	dmacontroller_poke_tx(ring, slot);
-
-	return 0;
 }
 
 int bcm43xx_dma_tx(struct bcm43xx_private *bcm,
@@ -781,7 +945,6 @@
 		/* Take skb from ieee80211_txb_free */
 		txb->fragments[i] = NULL;
 		dma_tx_fragment(ring, skb, i);
-		//TODO: handle failure of dma_tx_fragment
 	}
 	ieee80211_txb_free(txb);
 
@@ -792,23 +955,28 @@
 				   struct bcm43xx_xmitstatus *status)
 {
 	struct bcm43xx_dmaring *ring;
-	struct bcm43xx_dmadesc *desc;
+	struct bcm43xx_dmadesc_generic *desc;
 	struct bcm43xx_dmadesc_meta *meta;
 	int is_last_fragment;
 	int slot;
+	u32 tmp;
 
 	ring = parse_cookie(bcm, status->cookie, &slot);
 	assert(ring);
 	assert(ring->tx);
-	assert(get_desc_ctl(ring->vbase + slot) & BCM43xx_DMADTOR_FRAMESTART);
 	while (1) {
 		assert(slot >= 0 && slot < ring->nr_slots);
-		desc = ring->vbase + slot;
-		meta = ring->meta + slot;
+		desc = bcm43xx_dma_idx2desc(ring, slot, &meta);
 
-		is_last_fragment = !!(get_desc_ctl(desc) & BCM43xx_DMADTOR_FRAMEEND);
+		if (ring->dma64) {
+			tmp = le32_to_cpu(desc->dma64.control0);
+			is_last_fragment = !!(tmp & BCM43xx_DMA64_DCTL0_FRAMEEND);
+		} else {
+			tmp = le32_to_cpu(desc->dma32.control);
+			is_last_fragment = !!(tmp & BCM43xx_DMA32_DCTL_FRAMEEND);
+		}
 		unmap_descbuffer(ring, meta->dmaaddr, meta->skb->len, 1);
-		free_descriptor_buffer(ring, desc, meta, 1);
+		free_descriptor_buffer(ring, meta, 1);
 		/* Everything belonging to the slot is unmapped
 		 * and freed, so we can return it.
 		 */
@@ -824,7 +992,7 @@
 static void dma_rx(struct bcm43xx_dmaring *ring,
 		   int *slot)
 {
-	struct bcm43xx_dmadesc *desc;
+	struct bcm43xx_dmadesc_generic *desc;
 	struct bcm43xx_dmadesc_meta *meta;
 	struct bcm43xx_rxhdr *rxhdr;
 	struct sk_buff *skb;
@@ -832,13 +1000,12 @@
 	int err;
 	dma_addr_t dmaaddr;
 
-	desc = ring->vbase + *slot;
-	meta = ring->meta + *slot;
+	desc = bcm43xx_dma_idx2desc(ring, *slot, &meta);
 
 	sync_descbuffer_for_cpu(ring, meta->dmaaddr, ring->rx_buffersize);
 	skb = meta->skb;
 
-	if (ring->mmio_base == BCM43xx_MMIO_DMA4_BASE) {
+	if (ring->index == 3) {
 		/* We received an xmit status. */
 		struct bcm43xx_hwxmitstatus *hw = (struct bcm43xx_hwxmitstatus *)skb->data;
 		struct bcm43xx_xmitstatus stat;
@@ -894,8 +1061,7 @@
 		s32 tmp = len;
 
 		while (1) {
-			desc = ring->vbase + *slot;
-			meta = ring->meta + *slot;
+			desc = bcm43xx_dma_idx2desc(ring, *slot, &meta);
 			/* recycle the descriptor buffer. */
 			sync_descbuffer_for_device(ring, meta->dmaaddr,
 						   ring->rx_buffersize);
@@ -906,8 +1072,8 @@
 				break;
 		}
 		printkl(KERN_ERR PFX "DMA RX buffer too small "
-				     "(len: %u, buffer: %u, nr-dropped: %d)\n",
-		        len, ring->rx_buffersize, cnt);
+			"(len: %u, buffer: %u, nr-dropped: %d)\n",
+			len, ring->rx_buffersize, cnt);
 		goto drop;
 	}
 	len -= IEEE80211_FCS_LEN;
@@ -945,9 +1111,15 @@
 #endif
 
 	assert(!ring->tx);
-	status = bcm43xx_dma_read(ring, BCM43xx_DMA_RX_STATUS);
-	descptr = (status & BCM43xx_DMA_RXSTAT_DPTR_MASK);
-	current_slot = descptr / sizeof(struct bcm43xx_dmadesc);
+	if (ring->dma64) {
+		status = bcm43xx_dma_read(ring, BCM43xx_DMA64_RXSTATUS);
+		descptr = (status & BCM43xx_DMA64_RXSTATDPTR);
+		current_slot = descptr / sizeof(struct bcm43xx_dmadesc64);
+	} else {
+		status = bcm43xx_dma_read(ring, BCM43xx_DMA32_RXSTATUS);
+		descptr = (status & BCM43xx_DMA32_RXDPTR);
+		current_slot = descptr / sizeof(struct bcm43xx_dmadesc32);
+	}
 	assert(current_slot >= 0 && current_slot < ring->nr_slots);
 
 	slot = ring->current_slot;
@@ -958,8 +1130,13 @@
 			ring->max_used_slots = used_slots;
 #endif
 	}
-	bcm43xx_dma_write(ring, BCM43xx_DMA_RX_DESC_INDEX,
-			  (u32)(slot * sizeof(struct bcm43xx_dmadesc)));
+	if (ring->dma64) {
+		bcm43xx_dma_write(ring, BCM43xx_DMA64_RXINDEX,
+				(u32)(slot * sizeof(struct bcm43xx_dmadesc64)));
+	} else {
+		bcm43xx_dma_write(ring, BCM43xx_DMA32_RXINDEX,
+				(u32)(slot * sizeof(struct bcm43xx_dmadesc32)));
+	}
 	ring->current_slot = slot;
 }
 
@@ -967,16 +1144,28 @@
 {
 	assert(ring->tx);
 	bcm43xx_power_saving_ctl_bits(ring->bcm, -1, 1);
-	bcm43xx_dma_write(ring, BCM43xx_DMA_TX_CONTROL,
-			  bcm43xx_dma_read(ring, BCM43xx_DMA_TX_CONTROL)
-			  | BCM43xx_DMA_TXCTRL_SUSPEND);
+	if (ring->dma64) {
+		bcm43xx_dma_write(ring, BCM43xx_DMA64_TXCTL,
+				bcm43xx_dma_read(ring, BCM43xx_DMA64_TXCTL)
+				| BCM43xx_DMA64_TXSUSPEND);
+	} else {
+		bcm43xx_dma_write(ring, BCM43xx_DMA32_TXCTL,
+				bcm43xx_dma_read(ring, BCM43xx_DMA32_TXCTL)
+				| BCM43xx_DMA32_TXSUSPEND);
+	}
 }
 
 void bcm43xx_dma_tx_resume(struct bcm43xx_dmaring *ring)
 {
 	assert(ring->tx);
-	bcm43xx_dma_write(ring, BCM43xx_DMA_TX_CONTROL,
-			  bcm43xx_dma_read(ring, BCM43xx_DMA_TX_CONTROL)
-			  & ~BCM43xx_DMA_TXCTRL_SUSPEND);
+	if (ring->dma64) {
+		bcm43xx_dma_write(ring, BCM43xx_DMA64_TXCTL,
+				bcm43xx_dma_read(ring, BCM43xx_DMA64_TXCTL)
+				& ~BCM43xx_DMA64_TXSUSPEND);
+	} else {
+		bcm43xx_dma_write(ring, BCM43xx_DMA32_TXCTL,
+				bcm43xx_dma_read(ring, BCM43xx_DMA32_TXCTL)
+				& ~BCM43xx_DMA32_TXSUSPEND);
+	}
 	bcm43xx_power_saving_ctl_bits(ring->bcm, -1, -1);
 }
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_dma.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_dma.h	2006-06-17 17:48:26.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_dma.h	2006-06-17 19:09:40.000000000 +0200
@@ -14,63 +14,179 @@
 #define BCM43xx_DMAIRQ_NONFATALMASK	(1 << 13)
 #define BCM43xx_DMAIRQ_RX_DONE		(1 << 16)
 
-/* DMA controller register offsets. (relative to BCM43xx_DMA#_BASE) */
-#define BCM43xx_DMA_TX_CONTROL		0x00
-#define BCM43xx_DMA_TX_DESC_RING	0x04
-#define BCM43xx_DMA_TX_DESC_INDEX	0x08
-#define BCM43xx_DMA_TX_STATUS		0x0c
-#define BCM43xx_DMA_RX_CONTROL		0x10
-#define BCM43xx_DMA_RX_DESC_RING	0x14
-#define BCM43xx_DMA_RX_DESC_INDEX	0x18
-#define BCM43xx_DMA_RX_STATUS		0x1c
-
-/* DMA controller channel control word values. */
-#define BCM43xx_DMA_TXCTRL_ENABLE		(1 << 0)
-#define BCM43xx_DMA_TXCTRL_SUSPEND		(1 << 1)
-#define BCM43xx_DMA_TXCTRL_LOOPBACK		(1 << 2)
-#define BCM43xx_DMA_TXCTRL_FLUSH		(1 << 4)
-#define BCM43xx_DMA_RXCTRL_ENABLE		(1 << 0)
-#define BCM43xx_DMA_RXCTRL_FRAMEOFF_MASK	0x000000fe
-#define BCM43xx_DMA_RXCTRL_FRAMEOFF_SHIFT	1
-#define BCM43xx_DMA_RXCTRL_PIO			(1 << 8)
-/* DMA controller channel status word values. */
-#define BCM43xx_DMA_TXSTAT_DPTR_MASK		0x00000fff
-#define BCM43xx_DMA_TXSTAT_STAT_MASK		0x0000f000
-#define BCM43xx_DMA_TXSTAT_STAT_DISABLED	0x00000000
-#define BCM43xx_DMA_TXSTAT_STAT_ACTIVE		0x00001000
-#define BCM43xx_DMA_TXSTAT_STAT_IDLEWAIT	0x00002000
-#define BCM43xx_DMA_TXSTAT_STAT_STOPPED		0x00003000
-#define BCM43xx_DMA_TXSTAT_STAT_SUSP		0x00004000
-#define BCM43xx_DMA_TXSTAT_ERROR_MASK		0x000f0000
-#define BCM43xx_DMA_TXSTAT_FLUSHED		(1 << 20)
-#define BCM43xx_DMA_RXSTAT_DPTR_MASK		0x00000fff
-#define BCM43xx_DMA_RXSTAT_STAT_MASK		0x0000f000
-#define BCM43xx_DMA_RXSTAT_STAT_DISABLED	0x00000000
-#define BCM43xx_DMA_RXSTAT_STAT_ACTIVE		0x00001000
-#define BCM43xx_DMA_RXSTAT_STAT_IDLEWAIT	0x00002000
-#define BCM43xx_DMA_RXSTAT_STAT_RESERVED	0x00003000
-#define BCM43xx_DMA_RXSTAT_STAT_ERRORS		0x00004000
-#define BCM43xx_DMA_RXSTAT_ERROR_MASK		0x000f0000
-
-/* DMA descriptor control field values. */
-#define BCM43xx_DMADTOR_BYTECNT_MASK		0x00001fff
-#define BCM43xx_DMADTOR_DTABLEEND		(1 << 28) /* End of descriptor table */
-#define BCM43xx_DMADTOR_COMPIRQ			(1 << 29) /* IRQ on completion request */
-#define BCM43xx_DMADTOR_FRAMEEND		(1 << 30)
-#define BCM43xx_DMADTOR_FRAMESTART		(1 << 31)
+
+/*** 32-bit DMA Engine. ***/
+
+/* 32-bit DMA controller registers. */
+#define BCM43xx_DMA32_TXCTL				0x00
+#define		BCM43xx_DMA32_TXENABLE			0x00000001
+#define		BCM43xx_DMA32_TXSUSPEND			0x00000002
+#define		BCM43xx_DMA32_TXLOOPBACK		0x00000004
+#define		BCM43xx_DMA32_TXFLUSH			0x00000010
+#define		BCM43xx_DMA32_TXADDREXT_MASK		0x00030000
+#define		BCM43xx_DMA32_TXADDREXT_SHIFT		16
+#define BCM43xx_DMA32_TXRING				0x04
+#define BCM43xx_DMA32_TXINDEX				0x08
+#define BCM43xx_DMA32_TXSTATUS				0x0C
+#define		BCM43xx_DMA32_TXDPTR			0x00000FFF
+#define		BCM43xx_DMA32_TXSTATE			0x0000F000
+#define			BCM43xx_DMA32_TXSTAT_DISABLED	0x00000000
+#define			BCM43xx_DMA32_TXSTAT_ACTIVE	0x00001000
+#define			BCM43xx_DMA32_TXSTAT_IDLEWAIT	0x00002000
+#define			BCM43xx_DMA32_TXSTAT_STOPPED	0x00003000
+#define			BCM43xx_DMA32_TXSTAT_SUSP	0x00004000
+#define		BCM43xx_DMA32_TXERROR			0x000F0000
+#define			BCM43xx_DMA32_TXERR_NOERR	0x00000000
+#define			BCM43xx_DMA32_TXERR_PROT	0x00010000
+#define			BCM43xx_DMA32_TXERR_UNDERRUN	0x00020000
+#define			BCM43xx_DMA32_TXERR_BUFREAD	0x00030000
+#define			BCM43xx_DMA32_TXERR_DESCREAD	0x00040000
+#define		BCM43xx_DMA32_TXACTIVE			0xFFF00000
+#define BCM43xx_DMA32_RXCTL				0x10
+#define		BCM43xx_DMA32_RXENABLE			0x00000001
+#define		BCM43xx_DMA32_RXFROFF_MASK		0x000000FE
+#define		BCM43xx_DMA32_RXFROFF_SHIFT		1
+#define		BCM43xx_DMA32_RXDIRECTFIFO		0x00000100
+#define		BCM43xx_DMA32_RXADDREXT_MASK		0x00030000
+#define		BCM43xx_DMA32_RXADDREXT_SHIFT		16
+#define BCM43xx_DMA32_RXRING				0x14
+#define BCM43xx_DMA32_RXINDEX				0x18
+#define BCM43xx_DMA32_RXSTATUS				0x1C
+#define		BCM43xx_DMA32_RXDPTR			0x00000FFF
+#define		BCM43xx_DMA32_RXSTATE			0x0000F000
+#define			BCM43xx_DMA32_RXSTAT_DISABLED	0x00000000
+#define			BCM43xx_DMA32_RXSTAT_ACTIVE	0x00001000
+#define			BCM43xx_DMA32_RXSTAT_IDLEWAIT	0x00002000
+#define			BCM43xx_DMA32_RXSTAT_STOPPED	0x00003000
+#define		BCM43xx_DMA32_RXERROR			0x000F0000
+#define			BCM43xx_DMA32_RXERR_NOERR	0x00000000
+#define			BCM43xx_DMA32_RXERR_PROT	0x00010000
+#define			BCM43xx_DMA32_RXERR_OVERFLOW	0x00020000
+#define			BCM43xx_DMA32_RXERR_BUFWRITE	0x00030000
+#define			BCM43xx_DMA32_RXERR_DESCREAD	0x00040000
+#define		BCM43xx_DMA32_RXACTIVE			0xFFF00000
+
+/* 32-bit DMA descriptor. */
+struct bcm43xx_dmadesc32 {
+	__le32 control;
+	__le32 address;
+} __attribute__((__packed__));
+#define BCM43xx_DMA32_DCTL_BYTECNT		0x00001FFF
+#define BCM43xx_DMA32_DCTL_ADDREXT_MASK		0x00030000
+#define BCM43xx_DMA32_DCTL_ADDREXT_SHIFT	16
+#define BCM43xx_DMA32_DCTL_DTABLEEND		0x10000000
+#define BCM43xx_DMA32_DCTL_IRQ			0x20000000
+#define BCM43xx_DMA32_DCTL_FRAMEEND		0x40000000
+#define BCM43xx_DMA32_DCTL_FRAMESTART		0x80000000
+
+/* Address field Routing value. */
+#define BCM43xx_DMA32_ROUTING			0xC0000000
+#define BCM43xx_DMA32_ROUTING_SHIFT		30
+#define		BCM43xx_DMA32_NOTRANS		0x00000000
+#define		BCM43xx_DMA32_CLIENTTRANS	0x40000000
+
+
+
+/*** 64-bit DMA Engine. ***/
+
+/* 64-bit DMA controller registers. */
+#define BCM43xx_DMA64_TXCTL				0x00
+#define		BCM43xx_DMA64_TXENABLE			0x00000001
+#define		BCM43xx_DMA64_TXSUSPEND			0x00000002
+#define		BCM43xx_DMA64_TXLOOPBACK		0x00000004
+#define		BCM43xx_DMA64_TXFLUSH			0x00000010
+#define		BCM43xx_DMA64_TXADDREXT_MASK		0x00030000
+#define		BCM43xx_DMA64_TXADDREXT_SHIFT		16
+#define BCM43xx_DMA64_TXINDEX				0x04
+#define BCM43xx_DMA64_TXRINGLO				0x08
+#define BCM43xx_DMA64_TXRINGHI				0x0C
+#define BCM43xx_DMA64_TXSTATUS				0x10
+#define		BCM43xx_DMA64_TXSTATDPTR		0x00001FFF
+#define		BCM43xx_DMA64_TXSTAT			0xF0000000
+#define			BCM43xx_DMA64_TXSTAT_DISABLED	0x00000000
+#define			BCM43xx_DMA64_TXSTAT_ACTIVE	0x10000000
+#define			BCM43xx_DMA64_TXSTAT_IDLEWAIT	0x20000000
+#define			BCM43xx_DMA64_TXSTAT_STOPPED	0x30000000
+#define			BCM43xx_DMA64_TXSTAT_SUSP	0x40000000
+#define BCM43xx_DMA64_TXERROR				0x14
+#define		BCM43xx_DMA64_TXERRDPTR			0x0001FFFF
+#define		BCM43xx_DMA64_TXERR			0xF0000000
+#define			BCM43xx_DMA64_TXERR_NOERR	0x00000000
+#define			BCM43xx_DMA64_TXERR_PROT	0x10000000
+#define			BCM43xx_DMA64_TXERR_UNDERRUN	0x20000000
+#define			BCM43xx_DMA64_TXERR_TRANSFER	0x30000000
+#define			BCM43xx_DMA64_TXERR_DESCREAD	0x40000000
+#define			BCM43xx_DMA64_TXERR_CORE	0x50000000
+#define BCM43xx_DMA64_RXCTL				0x20
+#define		BCM43xx_DMA64_RXENABLE			0x00000001
+#define		BCM43xx_DMA64_RXFROFF_MASK		0x000000FE
+#define		BCM43xx_DMA64_RXFROFF_SHIFT		1
+#define		BCM43xx_DMA64_RXDIRECTFIFO		0x00000100
+#define		BCM43xx_DMA64_RXADDREXT_MASK		0x00030000
+#define		BCM43xx_DMA64_RXADDREXT_SHIFT		16
+#define BCM43xx_DMA64_RXINDEX				0x24
+#define BCM43xx_DMA64_RXRINGLO				0x28
+#define BCM43xx_DMA64_RXRINGHI				0x2C
+#define BCM43xx_DMA64_RXSTATUS				0x30
+#define		BCM43xx_DMA64_RXSTATDPTR		0x00001FFF
+#define		BCM43xx_DMA64_RXSTAT			0xF0000000
+#define			BCM43xx_DMA64_RXSTAT_DISABLED	0x00000000
+#define			BCM43xx_DMA64_RXSTAT_ACTIVE	0x10000000
+#define			BCM43xx_DMA64_RXSTAT_IDLEWAIT	0x20000000
+#define			BCM43xx_DMA64_RXSTAT_STOPPED	0x30000000
+#define			BCM43xx_DMA64_RXSTAT_SUSP	0x40000000
+#define BCM43xx_DMA64_RXERROR				0x34
+#define		BCM43xx_DMA64_RXERRDPTR			0x0001FFFF
+#define		BCM43xx_DMA64_RXERR			0xF0000000
+#define			BCM43xx_DMA64_RXERR_NOERR	0x00000000
+#define			BCM43xx_DMA64_RXERR_PROT	0x10000000
+#define			BCM43xx_DMA64_RXERR_UNDERRUN	0x20000000
+#define			BCM43xx_DMA64_RXERR_TRANSFER	0x30000000
+#define			BCM43xx_DMA64_RXERR_DESCREAD	0x40000000
+#define			BCM43xx_DMA64_RXERR_CORE	0x50000000
+
+/* 64-bit DMA descriptor. */
+struct bcm43xx_dmadesc64 {
+	__le32 control0;
+	__le32 control1;
+	__le32 address_low;
+	__le32 address_high;
+} __attribute__((__packed__));
+#define BCM43xx_DMA64_DCTL0_DTABLEEND		0x10000000
+#define BCM43xx_DMA64_DCTL0_IRQ			0x20000000
+#define BCM43xx_DMA64_DCTL0_FRAMEEND		0x40000000
+#define BCM43xx_DMA64_DCTL0_FRAMESTART		0x80000000
+#define BCM43xx_DMA64_DCTL1_BYTECNT		0x00001FFF
+#define BCM43xx_DMA64_DCTL1_ADDREXT_MASK	0x00030000
+#define BCM43xx_DMA64_DCTL1_ADDREXT_SHIFT	16
+
+/* Address field Routing value. */
+#define BCM43xx_DMA64_ROUTING			0xC0000000
+#define BCM43xx_DMA64_ROUTING_SHIFT		30
+#define		BCM43xx_DMA64_NOTRANS		0x00000000
+#define		BCM43xx_DMA64_CLIENTTRANS	0x80000000
+
+
+
+struct bcm43xx_dmadesc_generic {
+	union {
+		struct bcm43xx_dmadesc32 dma32;
+		struct bcm43xx_dmadesc64 dma64;
+	} __attribute__((__packed__));
+} __attribute__((__packed__));
+
 
 /* Misc DMA constants */
 #define BCM43xx_DMA_RINGMEMSIZE		PAGE_SIZE
-#define BCM43xx_DMA_BUSADDRMAX		0x3FFFFFFF
-#define BCM43xx_DMA_DMABUSADDROFFSET	(1 << 30)
-#define BCM43xx_DMA1_RX_FRAMEOFFSET	30
-#define BCM43xx_DMA4_RX_FRAMEOFFSET	0
+#define BCM43xx_DMA0_RX_FRAMEOFFSET	30
+#define BCM43xx_DMA3_RX_FRAMEOFFSET	0
+
 
 /* DMA engine tuning knobs */
 #define BCM43xx_TXRING_SLOTS		512
 #define BCM43xx_RXRING_SLOTS		64
-#define BCM43xx_DMA1_RXBUFFERSIZE	(2304 + 100)
-#define BCM43xx_DMA4_RXBUFFERSIZE	16
+#define BCM43xx_DMA0_RX_BUFFERSIZE	(2304 + 100)
+#define BCM43xx_DMA3_RX_BUFFERSIZE	16
 /* Suspend the tx queue, if less than this percent slots are free. */
 #define BCM43xx_TXSUSPEND_PERCENT	20
 /* Resume the tx queue, if more than this percent slots are free. */
@@ -86,17 +202,6 @@
 struct bcm43xx_xmitstatus;
 
 
-struct bcm43xx_dmadesc {
-	__le32 _control;
-	__le32 _address;
-} __attribute__((__packed__));
-
-/* Macros to access the bcm43xx_dmadesc struct */
-#define get_desc_ctl(desc)		le32_to_cpu((desc)->_control)
-#define set_desc_ctl(desc, ctl)		do { (desc)->_control = cpu_to_le32(ctl); } while (0)
-#define get_desc_addr(desc)		le32_to_cpu((desc)->_address)
-#define set_desc_addr(desc, addr)	do { (desc)->_address = cpu_to_le32(addr); } while (0)
-
 struct bcm43xx_dmadesc_meta {
 	/* The kernel DMA-able buffer. */
 	struct sk_buff *skb;
@@ -105,15 +210,14 @@
 };
 
 struct bcm43xx_dmaring {
-	struct bcm43xx_private *bcm;
 	/* Kernel virtual base address of the ring memory. */
-	struct bcm43xx_dmadesc *vbase;
-	/* DMA memory offset */
-	dma_addr_t memoffset;
-	/* (Unadjusted) DMA base bus-address of the ring memory. */
-	dma_addr_t dmabase;
+	void *descbase;
 	/* Meta data about all descriptors. */
 	struct bcm43xx_dmadesc_meta *meta;
+	/* DMA Routing value. */
+	u32 routing;
+	/* (Unadjusted) DMA base bus-address of the ring memory. */
+	dma_addr_t dmabase;
 	/* Number of descriptor slots in the ring. */
 	int nr_slots;
 	/* Number of used descriptor slots. */
@@ -127,12 +231,14 @@
 	u32 frameoffset;
 	/* Descriptor buffer size. */
 	u16 rx_buffersize;
-	/* The MMIO base register of the DMA controller, this
-	 * ring is posted to.
-	 */
+	/* The MMIO base register of the DMA controller. */
 	u16 mmio_base;
+	/* DMA controller index number (0-5). */
+	int index;
 	u8 tx:1,	/* TRUE, if this is a TX ring. */
+	   dma64:1,	/* TRUE, if 64-bit DMA is enabled (FALSE if 32bit). */
 	   suspended:1;	/* TRUE, if transfers are suspended on this ring. */
+	struct bcm43xx_private *bcm;
 #ifdef CONFIG_BCM43XX_DEBUG
 	/* Maximum number of used slots. */
 	int max_used_slots;
@@ -141,6 +247,34 @@
 
 
 static inline
+int bcm43xx_dma_desc2idx(struct bcm43xx_dmaring *ring,
+			 struct bcm43xx_dmadesc_generic *desc)
+{
+	if (ring->dma64) {
+		struct bcm43xx_dmadesc64 *dd64 = ring->descbase;
+		return (int)(&(desc->dma64) - dd64);
+	} else {
+		struct bcm43xx_dmadesc32 *dd32 = ring->descbase;
+		return (int)(&(desc->dma32) - dd32);
+	}
+}
+
+static inline
+struct bcm43xx_dmadesc_generic * bcm43xx_dma_idx2desc(struct bcm43xx_dmaring *ring,
+						      int slot,
+						      struct bcm43xx_dmadesc_meta **meta)
+{
+	*meta = &(ring->meta[slot]);
+	if (ring->dma64) {
+		struct bcm43xx_dmadesc64 *dd64 = ring->descbase;
+		return (struct bcm43xx_dmadesc_generic *)(&(dd64[slot]));
+	} else {
+		struct bcm43xx_dmadesc32 *dd32 = ring->descbase;
+		return (struct bcm43xx_dmadesc_generic *)(&(dd32[slot]));
+	}
+}
+
+static inline
 u32 bcm43xx_dma_read(struct bcm43xx_dmaring *ring,
 		     u16 offset)
 {
@@ -159,9 +293,13 @@
 void bcm43xx_dma_free(struct bcm43xx_private *bcm);
 
 int bcm43xx_dmacontroller_rx_reset(struct bcm43xx_private *bcm,
-				   u16 dmacontroller_mmio_base);
+				   u16 dmacontroller_mmio_base,
+				   int dma64);
 int bcm43xx_dmacontroller_tx_reset(struct bcm43xx_private *bcm,
-				   u16 dmacontroller_mmio_base);
+				   u16 dmacontroller_mmio_base,
+				   int dma64);
+
+u16 bcm43xx_dmacontroller_base(int dma64bit, int dmacontroller_idx);
 
 void bcm43xx_dma_tx_suspend(struct bcm43xx_dmaring *ring);
 void bcm43xx_dma_tx_resume(struct bcm43xx_dmaring *ring);
@@ -173,7 +311,6 @@
 		   struct ieee80211_txb *txb);
 void bcm43xx_dma_rx(struct bcm43xx_dmaring *ring);
 
-
 #else /* CONFIG_BCM43XX_DMA */
 
 
@@ -188,13 +325,15 @@
 }
 static inline
 int bcm43xx_dmacontroller_rx_reset(struct bcm43xx_private *bcm,
-				   u16 dmacontroller_mmio_base)
+				   u16 dmacontroller_mmio_base,
+				   int dma64)
 {
 	return 0;
 }
 static inline
 int bcm43xx_dmacontroller_tx_reset(struct bcm43xx_private *bcm,
-				   u16 dmacontroller_mmio_base)
+				   u16 dmacontroller_mmio_base,
+				   int dma64)
 {
 	return 0;
 }
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-17 17:48:26.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-17 18:15:31.000000000 +0200
@@ -1376,6 +1376,7 @@
 	if ((bcm43xx_core_enabled(bcm)) &&
 	    !bcm43xx_using_pio(bcm)) {
 //FIXME: Do we _really_ want #ifndef CONFIG_BCM947XX here?
+#if 0
 #ifndef CONFIG_BCM947XX
 		/* reset all used DMA controllers. */
 		bcm43xx_dmacontroller_tx_reset(bcm, BCM43xx_MMIO_DMA1_BASE);
@@ -1386,6 +1387,7 @@
 		if (bcm->current_core->rev < 5)
 			bcm43xx_dmacontroller_rx_reset(bcm, BCM43xx_MMIO_DMA4_BASE);
 #endif
+#endif
 	}
 	if (bcm->shutting_down) {
 		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
@@ -1696,8 +1698,9 @@
 static void bcm43xx_interrupt_tasklet(struct bcm43xx_private *bcm)
 {
 	u32 reason;
-	u32 dma_reason[4];
-	int activity = 0;
+	u32 dma_reason[6];
+	u32 merged_dma_reason = 0;
+	int i, activity = 0;
 	unsigned long flags;
 
 #ifdef CONFIG_BCM43XX_DEBUG
@@ -1709,10 +1712,10 @@
 
 	bcm43xx_lock_mmio(bcm, flags);
 	reason = bcm->irq_reason;
-	dma_reason[0] = bcm->dma_reason[0];
-	dma_reason[1] = bcm->dma_reason[1];
-	dma_reason[2] = bcm->dma_reason[2];
-	dma_reason[3] = bcm->dma_reason[3];
+	for (i = 5; i >= 0; i--) {
+		dma_reason[i] = bcm->dma_reason[i];
+		merged_dma_reason |= dma_reason[i];
+	}
 
 	if (unlikely(reason & BCM43xx_IRQ_XMIT_ERROR)) {
 		/* TX error. We get this when Template Ram is written in wrong endianess
@@ -1723,26 +1726,24 @@
 		printkl(KERN_ERR PFX "FATAL ERROR: BCM43xx_IRQ_XMIT_ERROR\n");
 		bcmirq_handled(BCM43xx_IRQ_XMIT_ERROR);
 	}
-	if (unlikely((dma_reason[0] & BCM43xx_DMAIRQ_FATALMASK) |
-		     (dma_reason[1] & BCM43xx_DMAIRQ_FATALMASK) |
-		     (dma_reason[2] & BCM43xx_DMAIRQ_FATALMASK) |
-		     (dma_reason[3] & BCM43xx_DMAIRQ_FATALMASK))) {
+	if (unlikely(merged_dma_reason & BCM43xx_DMAIRQ_FATALMASK)) {
 		printkl(KERN_ERR PFX "FATAL ERROR: Fatal DMA error: "
-				     "0x%08X, 0x%08X, 0x%08X, 0x%08X\n",
+				     "0x%08X, 0x%08X, 0x%08X, "
+				     "0x%08X, 0x%08X, 0x%08X\n",
 		        dma_reason[0], dma_reason[1],
-			dma_reason[2], dma_reason[3]);
+			dma_reason[2], dma_reason[3],
+			dma_reason[4], dma_reason[5]);
 		bcm43xx_controller_restart(bcm, "DMA error");
 		bcm43xx_unlock_mmio(bcm, flags);
 		return;
 	}
-	if (unlikely((dma_reason[0] & BCM43xx_DMAIRQ_NONFATALMASK) |
-		     (dma_reason[1] & BCM43xx_DMAIRQ_NONFATALMASK) |
-		     (dma_reason[2] & BCM43xx_DMAIRQ_NONFATALMASK) |
-		     (dma_reason[3] & BCM43xx_DMAIRQ_NONFATALMASK))) {
+	if (unlikely(merged_dma_reason & BCM43xx_DMAIRQ_NONFATALMASK)) {
 		printkl(KERN_ERR PFX "DMA error: "
-				     "0x%08X, 0x%08X, 0x%08X, 0x%08X\n",
+				     "0x%08X, 0x%08X, 0x%08X, "
+				     "0x%08X, 0x%08X, 0x%08X\n",
 		        dma_reason[0], dma_reason[1],
-			dma_reason[2], dma_reason[3]);
+			dma_reason[2], dma_reason[3],
+			dma_reason[4], dma_reason[5]);
 	}
 
 	if (reason & BCM43xx_IRQ_PS) {
@@ -1777,8 +1778,6 @@
 	}
 
 	/* Check the DMA reason registers for received data. */
-	assert(!(dma_reason[1] & BCM43xx_DMAIRQ_RX_DONE));
-	assert(!(dma_reason[2] & BCM43xx_DMAIRQ_RX_DONE));
 	if (dma_reason[0] & BCM43xx_DMAIRQ_RX_DONE) {
 		if (bcm43xx_using_pio(bcm))
 			bcm43xx_pio_rx(bcm43xx_current_pio(bcm)->queue0);
@@ -1786,13 +1785,17 @@
 			bcm43xx_dma_rx(bcm43xx_current_dma(bcm)->rx_ring0);
 		/* We intentionally don't set "activity" to 1, here. */
 	}
+	assert(!(dma_reason[1] & BCM43xx_DMAIRQ_RX_DONE));
+	assert(!(dma_reason[2] & BCM43xx_DMAIRQ_RX_DONE));
 	if (dma_reason[3] & BCM43xx_DMAIRQ_RX_DONE) {
 		if (bcm43xx_using_pio(bcm))
 			bcm43xx_pio_rx(bcm43xx_current_pio(bcm)->queue3);
 		else
-			bcm43xx_dma_rx(bcm43xx_current_dma(bcm)->rx_ring1);
+			bcm43xx_dma_rx(bcm43xx_current_dma(bcm)->rx_ring3);
 		activity = 1;
 	}
+	assert(!(dma_reason[4] & BCM43xx_DMAIRQ_RX_DONE));
+	assert(!(dma_reason[5] & BCM43xx_DMAIRQ_RX_DONE));
 	bcmirq_handled(BCM43xx_IRQ_RX);
 
 	if (reason & BCM43xx_IRQ_XMIT_STATUS) {
@@ -1848,14 +1851,18 @@
 
 	bcm43xx_write32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON, reason);
 
-	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA1_REASON,
+	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA0_REASON,
 			bcm->dma_reason[0]);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA2_REASON,
+	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA1_REASON,
 			bcm->dma_reason[1]);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA3_REASON,
+	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA2_REASON,
 			bcm->dma_reason[2]);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA4_REASON,
+	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA3_REASON,
 			bcm->dma_reason[3]);
+	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA4_REASON,
+			bcm->dma_reason[4]);
+	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA5_REASON,
+			bcm->dma_reason[5]);
 }
 
 /* Interrupt handler top-half */
@@ -1880,14 +1887,18 @@
 	if (!reason)
 		goto out;
 
-	bcm->dma_reason[0] = bcm43xx_read32(bcm, BCM43xx_MMIO_DMA1_REASON)
-			     & 0x0001dc00;
-	bcm->dma_reason[1] = bcm43xx_read32(bcm, BCM43xx_MMIO_DMA2_REASON)
-			     & 0x0000dc00;
-	bcm->dma_reason[2] = bcm43xx_read32(bcm, BCM43xx_MMIO_DMA3_REASON)
-			     & 0x0000dc00;
-	bcm->dma_reason[3] = bcm43xx_read32(bcm, BCM43xx_MMIO_DMA4_REASON)
-			     & 0x0001dc00;
+	bcm->dma_reason[0] = bcm43xx_read32(bcm, BCM43xx_MMIO_DMA0_REASON)
+			     & 0x0001DC00;
+	bcm->dma_reason[1] = bcm43xx_read32(bcm, BCM43xx_MMIO_DMA1_REASON)
+			     & 0x0000DC00;
+	bcm->dma_reason[2] = bcm43xx_read32(bcm, BCM43xx_MMIO_DMA2_REASON)
+			     & 0x0000DC00;
+	bcm->dma_reason[3] = bcm43xx_read32(bcm, BCM43xx_MMIO_DMA3_REASON)
+			     & 0x0001DC00;
+	bcm->dma_reason[4] = bcm43xx_read32(bcm, BCM43xx_MMIO_DMA4_REASON)
+			     & 0x0000DC00;
+	bcm->dma_reason[5] = bcm43xx_read32(bcm, BCM43xx_MMIO_DMA5_REASON)
+			     & 0x0000DC00;
 
 	bcm43xx_interrupt_ack(bcm, reason);
 
@@ -2462,10 +2473,12 @@
 		bcm43xx_write32(bcm, 0x018C, 0x02000000);
 	}
 	bcm43xx_write32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON, 0x00004000);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA1_IRQ_MASK, 0x0001DC00);
+	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA0_IRQ_MASK, 0x0001DC00);
+	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA1_IRQ_MASK, 0x0000DC00);
 	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA2_IRQ_MASK, 0x0000DC00);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA3_IRQ_MASK, 0x0000DC00);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA4_IRQ_MASK, 0x0001DC00);
+	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA3_IRQ_MASK, 0x0001DC00);
+	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA4_IRQ_MASK, 0x0000DC00);
+	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA5_IRQ_MASK, 0x0000DC00);
 
 	value32 = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
 	value32 |= 0x00100000;


-- 
Greetings Michael.
