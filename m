From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] via-velocity big-endian support
Date: Fri, 28 Dec 2007 18:40:08 +0000
Message-ID: <20071228184008.GN27894@ZenIV.linux.org.uk>
References: <20071224050659.GS8181@ftp.linux.org.uk> <20071225224333.GA21585@electric-eye.fr.zoreil.com> <20071225225606.GC27894@ZenIV.linux.org.uk> <20071225232135.GA22589@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59847 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbXL1SkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 13:40:11 -0500
Content-Disposition: inline
In-Reply-To: <20071225232135.GA22589@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 26, 2007 at 12:21:35AM +0100, Francois Romieu wrote:
> -> some descriptor bits are now declared with an explicit endianness
>    while others are not (whence "u16 rsr" where "__le16 rsr" whould
>    have fit). Both are fine but it would not hurt to stick with one
>    convention in a given driver.

Point taken...

* kill multibyte bitfields
* annotate
* add missing conversions
* fix a couple of brainos in zerocopy stuff (fortunately, it's ifdef'ed out)

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/net/via-velocity.c |   62 ++++++-------
 drivers/net/via-velocity.h |  220 +++++++++++++++++++-------------------------
 2 files changed, 125 insertions(+), 157 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 35cd65d..3842516 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -8,7 +8,6 @@
  * for 64bit hardware platforms.
  *
  * TODO
- *	Big-endian support
  *	rx_copybreak/alignment
  *	Scatter gather
  *	More testing
@@ -681,7 +680,7 @@ static void velocity_rx_reset(struct velocity_info *vptr)
 	 *	Init state, all RD entries belong to the NIC
 	 */
 	for (i = 0; i < vptr->options.numrx; ++i)
-		vptr->rd_ring[i].rdesc0.owner = OWNED_BY_NIC;
+		vptr->rd_ring[i].rdesc0.len |= OWNED_BY_NIC;
 
 	writew(vptr->options.numrx, &regs->RBRDU);
 	writel(vptr->rd_pool_dma, &regs->RDBaseLo);
@@ -777,7 +776,7 @@ static void velocity_init_registers(struct velocity_info *vptr,
 
 		vptr->int_mask = INT_MASK_DEF;
 
-		writel(cpu_to_le32(vptr->rd_pool_dma), &regs->RDBaseLo);
+		writel(vptr->rd_pool_dma, &regs->RDBaseLo);
 		writew(vptr->options.numrx - 1, &regs->RDCSize);
 		mac_rx_queue_run(regs);
 		mac_rx_queue_wake(regs);
@@ -785,7 +784,7 @@ static void velocity_init_registers(struct velocity_info *vptr,
 		writew(vptr->options.numtx - 1, &regs->TDCSize);
 
 		for (i = 0; i < vptr->num_txq; i++) {
-			writel(cpu_to_le32(vptr->td_pool_dma[i]), &(regs->TDBaseLo[i]));
+			writel(vptr->td_pool_dma[i], &regs->TDBaseLo[i]);
 			mac_tx_queue_run(regs, i);
 		}
 
@@ -1195,7 +1194,7 @@ static inline void velocity_give_many_rx_descs(struct velocity_info *vptr)
 	dirty = vptr->rd_dirty - unusable;
 	for (avail = vptr->rd_filled & 0xfffc; avail; avail--) {
 		dirty = (dirty > 0) ? dirty - 1 : vptr->options.numrx - 1;
-		vptr->rd_ring[dirty].rdesc0.owner = OWNED_BY_NIC;
+		vptr->rd_ring[dirty].rdesc0.len |= OWNED_BY_NIC;
 	}
 
 	writew(vptr->rd_filled & 0xfffc, &regs->RBRDU);
@@ -1210,7 +1209,7 @@ static int velocity_rx_refill(struct velocity_info *vptr)
 		struct rx_desc *rd = vptr->rd_ring + dirty;
 
 		/* Fine for an all zero Rx desc at init time as well */
-		if (rd->rdesc0.owner == OWNED_BY_NIC)
+		if (rd->rdesc0.len & OWNED_BY_NIC)
 			break;
 
 		if (!vptr->rd_info[dirty].skb) {
@@ -1413,7 +1412,7 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
 		if (!vptr->rd_info[rd_curr].skb)
 			break;
 
-		if (rd->rdesc0.owner == OWNED_BY_NIC)
+		if (rd->rdesc0.len & OWNED_BY_NIC)
 			break;
 
 		rmb();
@@ -1421,7 +1420,7 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
 		/*
 		 *	Don't drop CE or RL error frame although RXOK is off
 		 */
-		if ((rd->rdesc0.RSR & RSR_RXOK) || (!(rd->rdesc0.RSR & RSR_RXOK) && (rd->rdesc0.RSR & (RSR_CE | RSR_RL)))) {
+		if (rd->rdesc0.RSR & (RSR_RXOK | RSR_CE | RSR_RL)) {
 			if (velocity_receive_frame(vptr, rd_curr) < 0)
 				stats->rx_dropped++;
 		} else {
@@ -1433,7 +1432,7 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
 			stats->rx_dropped++;
 		}
 
-		rd->inten = 1;
+		rd->size |= RX_INTEN;
 
 		vptr->dev->last_rx = jiffies;
 
@@ -1554,7 +1553,7 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 	struct net_device_stats *stats = &vptr->stats;
 	struct velocity_rd_info *rd_info = &(vptr->rd_info[idx]);
 	struct rx_desc *rd = &(vptr->rd_ring[idx]);
-	int pkt_len = rd->rdesc0.len;
+	int pkt_len = le16_to_cpu(rd->rdesc0.len) & 0x3fff;
 	struct sk_buff *skb;
 
 	if (rd->rdesc0.RSR & (RSR_STP | RSR_EDP)) {
@@ -1637,8 +1636,7 @@ static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
  	 */
 
 	*((u32 *) & (rd->rdesc0)) = 0;
-	rd->len = cpu_to_le32(vptr->rx_buf_sz);
-	rd->inten = 1;
+	rd->size = cpu_to_le16(vptr->rx_buf_sz) | RX_INTEN;
 	rd->pa_low = cpu_to_le32(rd_info->skb_dma);
 	rd->pa_high = 0;
 	return 0;
@@ -1674,7 +1672,7 @@ static int velocity_tx_srv(struct velocity_info *vptr, u32 status)
 			td = &(vptr->td_rings[qnum][idx]);
 			tdinfo = &(vptr->td_infos[qnum][idx]);
 
-			if (td->tdesc0.owner == OWNED_BY_NIC)
+			if (td->tdesc0.len & OWNED_BY_NIC)
 				break;
 
 			if ((works++ > 15))
@@ -1874,7 +1872,7 @@ static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_
 
 		for (i = 0; i < tdinfo->nskb_dma; i++) {
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
-			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], td->tdesc1.len, PCI_DMA_TODEVICE);
+			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], le16_to_cpu(td->tdesc1.len), PCI_DMA_TODEVICE);
 #else
 			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i], skb->len, PCI_DMA_TODEVICE);
 #endif
@@ -2067,8 +2065,8 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct velocity_td_info *tdinfo;
 	unsigned long flags;
 	int index;
-
 	int pktlen = skb->len;
+	__le16 len = cpu_to_le16(pktlen);
 
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
 	if (skb_shinfo(skb)->nr_frags > 6 && __skb_linearize(skb)) {
@@ -2085,7 +2083,7 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	td_ptr->tdesc1.TCPLS = TCPLS_NORMAL;
 	td_ptr->tdesc1.TCR = TCR0_TIC;
-	td_ptr->td_buf[0].queue = 0;
+	td_ptr->td_buf[0].size &= ~TD_QUEUE;
 
 	/*
 	 *	Pad short frames.
@@ -2093,14 +2091,15 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (pktlen < ETH_ZLEN) {
 		/* Cannot occur until ZC support */
 		pktlen = ETH_ZLEN;
+		len = cpu_to_le16(ETH_ZLEN);
 		skb_copy_from_linear_data(skb, tdinfo->buf, skb->len);
 		memset(tdinfo->buf + skb->len, 0, ETH_ZLEN - skb->len);
 		tdinfo->skb = skb;
 		tdinfo->skb_dma[0] = tdinfo->buf_dma;
-		td_ptr->tdesc0.pktsize = pktlen;
+		td_ptr->tdesc0.len = len;
 		td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
 		td_ptr->td_buf[0].pa_high = 0;
-		td_ptr->td_buf[0].bufsize = td_ptr->tdesc0.pktsize;
+		td_ptr->td_buf[0].size = len;	/* queue is 0 anyway */
 		tdinfo->nskb_dma = 1;
 		td_ptr->tdesc1.CMDZ = 2;
 	} else
@@ -2111,10 +2110,10 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (nfrags > 6) {
 			skb_copy_from_linear_data(skb, tdinfo->buf, skb->len);
 			tdinfo->skb_dma[0] = tdinfo->buf_dma;
-			td_ptr->tdesc0.pktsize =
+			td_ptr->tdesc0.len = len;
 			td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
 			td_ptr->td_buf[0].pa_high = 0;
-			td_ptr->td_buf[0].bufsize = td_ptr->tdesc0.pktsize;
+			td_ptr->td_buf[0].size = len;	/* queue is 0 anyway */
 			tdinfo->nskb_dma = 1;
 			td_ptr->tdesc1.CMDZ = 2;
 		} else {
@@ -2122,22 +2121,23 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 			tdinfo->nskb_dma = 0;
 			tdinfo->skb_dma[i] = pci_map_single(vptr->pdev, skb->data, skb->len - skb->data_len, PCI_DMA_TODEVICE);
 
-			td_ptr->tdesc0.pktsize = pktlen;
+			td_ptr->tdesc0.len = len;
 
 			/* FIXME: support 48bit DMA later */
 			td_ptr->td_buf[i].pa_low = cpu_to_le32(tdinfo->skb_dma);
 			td_ptr->td_buf[i].pa_high = 0;
-			td_ptr->td_buf[i].bufsize = skb->len->skb->data_len;
+			td_ptr->td_buf[i].size =
+				cpu_to_le16(skb->len->skb->data_len);
 
 			for (i = 0; i < nfrags; i++) {
 				skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-				void *addr = ((void *) page_address(frag->page + frag->page_offset));
+				void *addr = (void *)page_address(frag->page) + frag->page_offset;
 
 				tdinfo->skb_dma[i + 1] = pci_map_single(vptr->pdev, addr, frag->size, PCI_DMA_TODEVICE);
 
 				td_ptr->td_buf[i + 1].pa_low = cpu_to_le32(tdinfo->skb_dma[i + 1]);
 				td_ptr->td_buf[i + 1].pa_high = 0;
-				td_ptr->td_buf[i + 1].bufsize = frag->size;
+				td_ptr->td_buf[i + 1].size = cpu_to_le16(frag->size);
 			}
 			tdinfo->nskb_dma = i - 1;
 			td_ptr->tdesc1.CMDZ = i;
@@ -2152,18 +2152,16 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		tdinfo->skb = skb;
 		tdinfo->skb_dma[0] = pci_map_single(vptr->pdev, skb->data, pktlen, PCI_DMA_TODEVICE);
-		td_ptr->tdesc0.pktsize = pktlen;
+		td_ptr->tdesc0.len = len;
 		td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
 		td_ptr->td_buf[0].pa_high = 0;
-		td_ptr->td_buf[0].bufsize = td_ptr->tdesc0.pktsize;
+		td_ptr->td_buf[0].size = len;
 		tdinfo->nskb_dma = 1;
 		td_ptr->tdesc1.CMDZ = 2;
 	}
 
 	if (vptr->vlgrp && vlan_tx_tag_present(skb)) {
-		td_ptr->tdesc1.pqinf.VID = vlan_tx_tag_get(skb);
-		td_ptr->tdesc1.pqinf.priority = 0;
-		td_ptr->tdesc1.pqinf.CFI = 0;
+		td_ptr->tdesc1.vlan = cpu_to_le16(vlan_tx_tag_get(skb));
 		td_ptr->tdesc1.TCR |= TCR0_VETAG;
 	}
 
@@ -2185,7 +2183,7 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		if (prev < 0)
 			prev = vptr->options.numtx - 1;
-		td_ptr->tdesc0.owner = OWNED_BY_NIC;
+		td_ptr->tdesc0.len |= OWNED_BY_NIC;
 		vptr->td_used[qnum]++;
 		vptr->td_curr[qnum] = (index + 1) % vptr->options.numtx;
 
@@ -2193,7 +2191,7 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_stop_queue(dev);
 
 		td_ptr = &(vptr->td_rings[qnum][prev]);
-		td_ptr->td_buf[0].queue = 1;
+		td_ptr->td_buf[0].size |= TD_QUEUE;
 		mac_tx_queue_wake(vptr->mac_regs, qnum);
 	}
 	dev->trans_start = jiffies;
@@ -3410,7 +3408,7 @@ static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
 		velocity_save_context(vptr, &vptr->context);
 		velocity_shutdown(vptr);
 		velocity_set_wol(vptr);
-		pci_enable_wake(pdev, 3, 1);
+		pci_enable_wake(pdev, PCI_D3hot, 1);
 		pci_set_power_state(pdev, PCI_D3hot);
 	} else {
 		velocity_save_context(vptr, &vptr->context);
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index aa91796..ffb7ced 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -70,40 +70,27 @@
  * Bits in the RSR0 register
  */
 
-#define RSR_DETAG          0x0080
-#define RSR_SNTAG          0x0040
-#define RSR_RXER           0x0020
-#define RSR_RL             0x0010
-#define RSR_CE             0x0008
-#define RSR_FAE            0x0004
-#define RSR_CRC            0x0002
-#define RSR_VIDM           0x0001
+#define RSR_DETAG	cpu_to_le16(0x0080)
+#define RSR_SNTAG	cpu_to_le16(0x0040)
+#define RSR_RXER	cpu_to_le16(0x0020)
+#define RSR_RL		cpu_to_le16(0x0010)
+#define RSR_CE		cpu_to_le16(0x0008)
+#define RSR_FAE		cpu_to_le16(0x0004)
+#define RSR_CRC		cpu_to_le16(0x0002)
+#define RSR_VIDM	cpu_to_le16(0x0001)
 
 /*
  * Bits in the RSR1 register
  */
 
-#define RSR_RXOK           0x8000	// rx OK
-#define RSR_PFT            0x4000	// Perfect filtering address match
-#define RSR_MAR            0x2000	// MAC accept multicast address packet
-#define RSR_BAR            0x1000	// MAC accept broadcast address packet
-#define RSR_PHY            0x0800	// MAC accept physical address packet
-#define RSR_VTAG           0x0400	// 802.1p/1q tagging packet indicator
-#define RSR_STP            0x0200	// start of packet
-#define RSR_EDP            0x0100	// end of packet
-
-/*
- * Bits in the RSR1 register
- */
-
-#define RSR1_RXOK           0x80	// rx OK
-#define RSR1_PFT            0x40	// Perfect filtering address match
-#define RSR1_MAR            0x20	// MAC accept multicast address packet
-#define RSR1_BAR            0x10	// MAC accept broadcast address packet
-#define RSR1_PHY            0x08	// MAC accept physical address packet
-#define RSR1_VTAG           0x04	// 802.1p/1q tagging packet indicator
-#define RSR1_STP            0x02	// start of packet
-#define RSR1_EDP            0x01	// end of packet
+#define RSR_RXOK	cpu_to_le16(0x8000) // rx OK
+#define RSR_PFT		cpu_to_le16(0x4000) // Perfect filtering address match
+#define RSR_MAR		cpu_to_le16(0x2000) // MAC accept multicast address packet
+#define RSR_BAR		cpu_to_le16(0x1000) // MAC accept broadcast address packet
+#define RSR_PHY		cpu_to_le16(0x0800) // MAC accept physical address packet
+#define RSR_VTAG	cpu_to_le16(0x0400) // 802.1p/1q tagging packet indicator
+#define RSR_STP		cpu_to_le16(0x0200) // start of packet
+#define RSR_EDP		cpu_to_le16(0x0100) // end of packet
 
 /*
  * Bits in the CSM register
@@ -120,33 +107,21 @@
  * Bits in the TSR0 register
  */
 
-#define TSR0_ABT            0x0080	// Tx abort because of excessive collision
-#define TSR0_OWT            0x0040	// Jumbo frame Tx abort
-#define TSR0_OWC            0x0020	// Out of window collision
-#define TSR0_COLS           0x0010	// experience collision in this transmit event
-#define TSR0_NCR3           0x0008	// collision retry counter[3]
-#define TSR0_NCR2           0x0004	// collision retry counter[2]
-#define TSR0_NCR1           0x0002	// collision retry counter[1]
-#define TSR0_NCR0           0x0001	// collision retry counter[0]
-#define TSR0_TERR           0x8000	//
-#define TSR0_FDX            0x4000	// current transaction is serviced by full duplex mode
-#define TSR0_GMII           0x2000	// current transaction is serviced by GMII mode
-#define TSR0_LNKFL          0x1000	// packet serviced during link down
-#define TSR0_SHDN           0x0400	// shutdown case
-#define TSR0_CRS            0x0200	// carrier sense lost
-#define TSR0_CDH            0x0100	// AQE test fail (CD heartbeat)
-
-/*
- * Bits in the TSR1 register
- */
-
-#define TSR1_TERR           0x80	//
-#define TSR1_FDX            0x40	// current transaction is serviced by full duplex mode
-#define TSR1_GMII           0x20	// current transaction is serviced by GMII mode
-#define TSR1_LNKFL          0x10	// packet serviced during link down
-#define TSR1_SHDN           0x04	// shutdown case
-#define TSR1_CRS            0x02	// carrier sense lost
-#define TSR1_CDH            0x01	// AQE test fail (CD heartbeat)
+#define TSR0_ABT	cpu_to_le16(0x0080) // Tx abort because of excessive collision
+#define TSR0_OWT	cpu_to_le16(0x0040) // Jumbo frame Tx abort
+#define TSR0_OWC	cpu_to_le16(0x0020) // Out of window collision
+#define TSR0_COLS	cpu_to_le16(0x0010) // experience collision in this transmit event
+#define TSR0_NCR3	cpu_to_le16(0x0008) // collision retry counter[3]
+#define TSR0_NCR2	cpu_to_le16(0x0004) // collision retry counter[2]
+#define TSR0_NCR1	cpu_to_le16(0x0002) // collision retry counter[1]
+#define TSR0_NCR0	cpu_to_le16(0x0001) // collision retry counter[0]
+#define TSR0_TERR	cpu_to_le16(0x8000) //
+#define TSR0_FDX	cpu_to_le16(0x4000) // current transaction is serviced by full duplex mode
+#define TSR0_GMII	cpu_to_le16(0x2000) // current transaction is serviced by GMII mode
+#define TSR0_LNKFL	cpu_to_le16(0x1000) // packet serviced during link down
+#define TSR0_SHDN	cpu_to_le16(0x0400) // shutdown case
+#define TSR0_CRS	cpu_to_le16(0x0200) // carrier sense lost
+#define TSR0_CDH	cpu_to_le16(0x0100) // AQE test fail (CD heartbeat)
 
 //
 // Bits in the TCR0 register
@@ -197,25 +172,26 @@
  */
 
 struct rdesc0 {
-	u16 RSR;		/* Receive status */
-	u16 len:14;		/* Received packet length */
-	u16 reserved:1;
-	u16 owner:1;		/* Who owns this buffer ? */
+	__le16 RSR;		/* Receive status */
+	__le16 len;		/* bits 0--13; bit 15 - owner */
 };
 
 struct rdesc1 {
-	u16 PQTAG;
+	__le16 PQTAG;
 	u8 CSM;
 	u8 IPKT;
 };
 
+enum {
+	RX_INTEN = __constant_cpu_to_le16(0x8000)
+};
+
 struct rx_desc {
 	struct rdesc0 rdesc0;
 	struct rdesc1 rdesc1;
-	u32 pa_low;		/* Low 32 bit PCI address */
-	u16 pa_high;		/* Next 16 bit PCI address (48 total) */
-	u16 len:15;		/* Frame size */
-	u16 inten:1;		/* Enable interrupt */
+	__le32 pa_low;		/* Low 32 bit PCI address */
+	__le16 pa_high;		/* Next 16 bit PCI address (48 total) */
+	__le16 size;		/* bits 0--14 - frame size, bit 15 - enable int. */
 } __attribute__ ((__packed__));
 
 /*
@@ -223,32 +199,26 @@ struct rx_desc {
  */
 
 struct tdesc0 {
-	u16 TSR;		/* Transmit status register */
-	u16 pktsize:14;		/* Size of frame */
-	u16 reserved:1;
-	u16 owner:1;		/* Who owns the buffer */
+	__le16 TSR;		/* Transmit status register */
+	__le16 len;		/* bits 0--13 - size of frame, bit 15 - owner */
 };
 
-struct pqinf {			/* Priority queue info */
-	u16 VID:12;
-	u16 CFI:1;
-	u16 priority:3;
-} __attribute__ ((__packed__));
-
 struct tdesc1 {
-	struct pqinf pqinf;
+	__le16 vlan;
 	u8 TCR;
 	u8 TCPLS:2;
 	u8 reserved:2;
 	u8 CMDZ:4;
 } __attribute__ ((__packed__));
 
+enum {
+	TD_QUEUE = __constant_cpu_to_le16(0x8000)
+};
+
 struct td_buf {
-	u32 pa_low;
-	u16 pa_high;
-	u16 bufsize:14;
-	u16 reserved:1;
-	u16 queue:1;
+	__le32 pa_low;
+	__le16 pa_high;
+	__le16 size;		/* bits 0--13 - size, bit 15 - queue */
 } __attribute__ ((__packed__));
 
 struct tx_desc {
@@ -276,7 +246,7 @@ struct velocity_td_info {
 
 enum  velocity_owner {
 	OWNED_BY_HOST = 0,
-	OWNED_BY_NIC = 1
+	OWNED_BY_NIC = __constant_cpu_to_le16(0x8000)
 };
 
 
@@ -1012,45 +982,45 @@ struct mac_regs {
 	volatile u8 RCR;
 	volatile u8 TCR;
 
-	volatile u32 CR0Set;		/* 0x08 */
-	volatile u32 CR0Clr;		/* 0x0C */
+	volatile __le32 CR0Set;		/* 0x08 */
+	volatile __le32 CR0Clr;		/* 0x0C */
 
 	volatile u8 MARCAM[8];		/* 0x10 */
 
-	volatile u32 DecBaseHi;		/* 0x18 */
-	volatile u16 DbfBaseHi;		/* 0x1C */
-	volatile u16 reserved_1E;
+	volatile __le32 DecBaseHi;	/* 0x18 */
+	volatile __le16 DbfBaseHi;	/* 0x1C */
+	volatile __le16 reserved_1E;
 
-	volatile u16 ISRCTL;		/* 0x20 */
+	volatile __le16 ISRCTL;		/* 0x20 */
 	volatile u8 TXESR;
 	volatile u8 RXESR;
 
-	volatile u32 ISR;		/* 0x24 */
-	volatile u32 IMR;
+	volatile __le32 ISR;		/* 0x24 */
+	volatile __le32 IMR;
 
-	volatile u32 TDStatusPort;	/* 0x2C */
+	volatile __le32 TDStatusPort;	/* 0x2C */
 
-	volatile u16 TDCSRSet;		/* 0x30 */
+	volatile __le16 TDCSRSet;	/* 0x30 */
 	volatile u8 RDCSRSet;
 	volatile u8 reserved_33;
-	volatile u16 TDCSRClr;
+	volatile __le16 TDCSRClr;
 	volatile u8 RDCSRClr;
 	volatile u8 reserved_37;
 
-	volatile u32 RDBaseLo;		/* 0x38 */
-	volatile u16 RDIdx;		/* 0x3C */
-	volatile u16 reserved_3E;
+	volatile __le32 RDBaseLo;	/* 0x38 */
+	volatile __le16 RDIdx;		/* 0x3C */
+	volatile __le16 reserved_3E;
 
-	volatile u32 TDBaseLo[4];	/* 0x40 */
+	volatile __le32 TDBaseLo[4];	/* 0x40 */
 
-	volatile u16 RDCSize;		/* 0x50 */
-	volatile u16 TDCSize;		/* 0x52 */
-	volatile u16 TDIdx[4];		/* 0x54 */
-	volatile u16 tx_pause_timer;	/* 0x5C */
-	volatile u16 RBRDU;		/* 0x5E */
+	volatile __le16 RDCSize;	/* 0x50 */
+	volatile __le16 TDCSize;	/* 0x52 */
+	volatile __le16 TDIdx[4];	/* 0x54 */
+	volatile __le16 tx_pause_timer;	/* 0x5C */
+	volatile __le16 RBRDU;		/* 0x5E */
 
-	volatile u32 FIFOTest0;		/* 0x60 */
-	volatile u32 FIFOTest1;		/* 0x64 */
+	volatile __le32 FIFOTest0;	/* 0x60 */
+	volatile __le32 FIFOTest1;	/* 0x64 */
 
 	volatile u8 CAMADDR;		/* 0x68 */
 	volatile u8 CAMCR;		/* 0x69 */
@@ -1063,18 +1033,18 @@ struct mac_regs {
 	volatile u8 PHYSR1;
 	volatile u8 MIICR;
 	volatile u8 MIIADR;
-	volatile u16 MIIDATA;
+	volatile __le16 MIIDATA;
 
-	volatile u16 SoftTimer0;	/* 0x74 */
-	volatile u16 SoftTimer1;
+	volatile __le16 SoftTimer0;	/* 0x74 */
+	volatile __le16 SoftTimer1;
 
 	volatile u8 CFGA;		/* 0x78 */
 	volatile u8 CFGB;
 	volatile u8 CFGC;
 	volatile u8 CFGD;
 
-	volatile u16 DCFG;		/* 0x7C */
-	volatile u16 MCFG;
+	volatile __le16 DCFG;		/* 0x7C */
+	volatile __le16 MCFG;
 
 	volatile u8 TBIST;		/* 0x80 */
 	volatile u8 RBIST;
@@ -1086,9 +1056,9 @@ struct mac_regs {
 	volatile u8 rev_id;
 	volatile u8 PORSTS;
 
-	volatile u32 MIBData;		/* 0x88 */
+	volatile __le32 MIBData;	/* 0x88 */
 
-	volatile u16 EEWrData;
+	volatile __le16 EEWrData;
 
 	volatile u8 reserved_8E;
 	volatile u8 BPMDWr;
@@ -1098,7 +1068,7 @@ struct mac_regs {
 	volatile u8 EECHKSUM;		/* 0x92 */
 	volatile u8 EECSR;
 
-	volatile u16 EERdData;		/* 0x94 */
+	volatile __le16 EERdData;	/* 0x94 */
 	volatile u8 EADDR;
 	volatile u8 EMBCMD;
 
@@ -1112,22 +1082,22 @@ struct mac_regs {
 	volatile u8 DEBUG;
 	volatile u8 CHIPGCR;
 
-	volatile u16 WOLCRSet;		/* 0xA0 */
+	volatile __le16 WOLCRSet;	/* 0xA0 */
 	volatile u8 PWCFGSet;
 	volatile u8 WOLCFGSet;
 
-	volatile u16 WOLCRClr;		/* 0xA4 */
+	volatile __le16 WOLCRClr;	/* 0xA4 */
 	volatile u8 PWCFGCLR;
 	volatile u8 WOLCFGClr;
 
-	volatile u16 WOLSRSet;		/* 0xA8 */
-	volatile u16 reserved_AA;
+	volatile __le16 WOLSRSet;	/* 0xA8 */
+	volatile __le16 reserved_AA;
 
-	volatile u16 WOLSRClr;		/* 0xAC */
-	volatile u16 reserved_AE;
+	volatile __le16 WOLSRClr;	/* 0xAC */
+	volatile __le16 reserved_AE;
 
-	volatile u16 PatternCRC[8];	/* 0xB0 */
-	volatile u32 ByteMask[4][4];	/* 0xC0 */
+	volatile __le16 PatternCRC[8];	/* 0xB0 */
+	volatile __le32 ByteMask[4][4];	/* 0xC0 */
 } __attribute__ ((__packed__));
 
 
@@ -1238,12 +1208,12 @@ typedef u8 MCAM_ADDR[ETH_ALEN];
 struct arp_packet {
 	u8 dest_mac[ETH_ALEN];
 	u8 src_mac[ETH_ALEN];
-	u16 type;
-	u16 ar_hrd;
-	u16 ar_pro;
+	__be16 type;
+	__be16 ar_hrd;
+	__be16 ar_pro;
 	u8 ar_hln;
 	u8 ar_pln;
-	u16 ar_op;
+	__be16 ar_op;
 	u8 ar_sha[ETH_ALEN];
 	u8 ar_sip[4];
 	u8 ar_tha[ETH_ALEN];
@@ -1253,7 +1223,7 @@ struct arp_packet {
 struct _magic_packet {
 	u8 dest_mac[6];
 	u8 src_mac[6];
-	u16 type;
+	__be16 type;
 	u8 MAC[16][6];
 	u8 password[6];
 } __attribute__ ((__packed__));
-- 
1.5.3.GIT

