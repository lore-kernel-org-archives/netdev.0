From: dacker@roinet.com (David Acker)
Subject: [PATCH] Fix e100 on systems that have cache incoherent DMA
Date: Fri, 31 Aug 2007 16:54:30 -0400 (EDT)
Message-ID: <20070831205430.7209E46C20E@localhost>
Cc: John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Milton Miller <miltonm@bga.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Scott Feldman <sfeldma@pobox.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:45746
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966117AbXHaUyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 16:54:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the systems that have cache incoherent DMA, including ARM, there is a
race condition between software allocating a new receive buffer and hardware
writing into a buffer.  The two race on touching the last Receive Frame
Descriptor (RFD).  It has its el-bit set and its next link equal to 0.
When hardware encounters this buffer it attempts to write data to it and
then update Status Word bits and Actual Count in the RFD.  At the same time
software may try to clear the el-bit and set the link address to a new buffer.

Since the entire RFD is once cache-line, the two write operations can collide.
This can lead to the receive unit stalling or interpreting random memory as
its receive area.

The fix is to set the el-bit on and the size to 0 on the next to last buffer
in the chain.  When the hardware encounters this buffer it stops and does not
write to it at all.  The hardware issues an RNR interrupt with the receive
unit in the No Resources state.  Software can write to the tail of the list
because it knows hardware will stop on the previous descriptor that was
marked as the end of list.

Once it has a new next to last buffer prepared, it can clear the el-bit and
set the size on the previous one.  The race on this buffer is safe since
the link already points to a valid next buffer and the software can handle
the race setting the size (assuming aligned 16 bit writes are atomic with
respect to the DMA read). If the hardware sees the el-bit cleared without
the size set, it will move on to the next buffer and skip this one.  If it
sees the size set but the el-bit still set, it will complete that buffer
and then RNR interrupt and wait.

Flags are kept in the software descriptor to note if the el bit is set and if
the size was 0.  When software clears the RFD's el bit and set its size, it
also clears the el flag but leaves the size was 0 bit set.  This way software
can identify them when the race may have occurred when cleaning the ring.
On these descriptors, it looks ahead and if the next one is complete then
hardware must have skipped the current one.  Logic is added to prevent two
packets in a row being marked while the receiver is running to avoid running
in lockstep with the hardware and thereby limiting the required lookahead.

This is a patch for 2.6.23-rc4.

Signed-off-by: David Acker <dacker@roinet.com>

---

--- linux-2.6.23-rc4/drivers/net/e100.c.orig	2007-08-30 13:32:10.000000000 -0400
+++ linux-2.6.23-rc4/drivers/net/e100.c	2007-08-30 15:42:07.000000000 -0400
@@ -106,6 +106,13 @@
  *	the RFD, the RFD must be dma_sync'ed to maintain a consistent
  *	view from software and hardware.
  *
+ *	In order to keep updates to the RFD link field from colliding with
+ *	hardware writes to mark packets complete, we use the feature that
+ *	hardware will not write to a size 0 descriptor and mark the previous
+ *	packet as end-of-list (EL).   After updating the link, we remove EL
+ *	and only then restore the size such that hardware may use the
+ *	previous-to-end RFD. 
+ *
  *	Under typical operation, the  receive unit (RU) is start once,
  *	and the controller happily fills RFDs as frames arrive.  If
  *	replacement RFDs cannot be allocated, or the RU goes non-active,
@@ -281,14 +288,14 @@ struct csr {
 };
 
 enum scb_status {
+	rus_no_res       = 0x08,
 	rus_ready        = 0x10,
 	rus_mask         = 0x3C,
 };
 
 enum ru_state  {
-	RU_SUSPENDED = 0,
-	RU_RUNNING	 = 1,
-	RU_UNINITIALIZED = -1,
+	ru_stopped = 0,
+	ru_running = 1,
 };
 
 enum scb_stat_ack {
@@ -401,10 +408,16 @@ struct rfd {
 	u16 size;
 };
 
+enum rx_flags {
+	rx_el = 0x01,
+	rx_s0 = 0x02,
+};
+
 struct rx {
 	struct rx *next, *prev;
 	struct sk_buff *skb;
 	dma_addr_t dma_addr;
+	u8 flags;
 };
 
 #if defined(__BIG_ENDIAN_BITFIELD)
@@ -952,7 +965,7 @@ static void e100_get_defaults(struct nic
 		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));
 
 	/* Template for a freshly allocated RFD */
-	nic->blank_rfd.command = cpu_to_le16(cb_el);
+	nic->blank_rfd.command = 0;
 	nic->blank_rfd.rbd = 0xFFFFFFFF;
 	nic->blank_rfd.size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
 
@@ -1753,18 +1766,48 @@ static int e100_alloc_cbs(struct nic *ni
 	return 0;
 }
 
-static inline void e100_start_receiver(struct nic *nic, struct rx *rx)
+static void e100_find_mark_el(struct nic *nic, struct rx *marked_rx, int is_running)
 {
-	if(!nic->rxs) return;
-	if(RU_SUSPENDED != nic->ru_running) return;
+	struct rx *rx = nic->rx_to_use->prev->prev;
+	struct rfd *rfd;
+
+	if (marked_rx == rx)
+		return;
+
+	rfd = (struct rfd *) rx->skb->data;
+	rfd->command |= cpu_to_le16(cb_el);
+	rfd->size = 0;
+	pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
+		sizeof(struct rfd), PCI_DMA_BIDIRECTIONAL);
+	rx->flags |= (rx_el | rx_s0);
+
+	if (!marked_rx)
+		return;
+
+	rfd = (struct rfd *) marked_rx->skb->data;
+	rfd->command &= ~cpu_to_le16(cb_el);
+	pci_dma_sync_single_for_device(nic->pdev, marked_rx->dma_addr,
+		sizeof(struct rfd), PCI_DMA_BIDIRECTIONAL);
+
+	rfd->size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
+	pci_dma_sync_single_for_device(nic->pdev, marked_rx->dma_addr,
+		sizeof(struct rfd), PCI_DMA_BIDIRECTIONAL);
 
-	/* handle init time starts */
-	if(!rx) rx = nic->rxs;
+	if (is_running)
+		marked_rx->flags &= ~rx_el;
+	else
+		marked_rx->flags &= ~(rx_el | rx_s0);
+}
+
+static inline void e100_start_receiver(struct nic *nic)
+{
+	if(!nic->rxs) return;
+	if (ru_stopped != nic->ru_running) return;
 
 	/* (Re)start RU if suspended or idle and RFA is non-NULL */
-	if(rx->skb) {
-		e100_exec_cmd(nic, ruc_start, rx->dma_addr);
-		nic->ru_running = RU_RUNNING;
+	if (nic->rx_to_clean->skb) {
+		e100_exec_cmd(nic, ruc_start, nic->rx_to_clean->dma_addr);
+		nic->ru_running = ru_running;
 	}
 }
 
@@ -1793,8 +1836,6 @@ static int e100_rx_alloc_skb(struct nic 
 		struct rfd *prev_rfd = (struct rfd *)rx->prev->skb->data;
 		put_unaligned(cpu_to_le32(rx->dma_addr),
 			(u32 *)&prev_rfd->link);
-		wmb();
-		prev_rfd->command &= ~cpu_to_le16(cb_el);
 		pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
 			sizeof(struct rfd), PCI_DMA_TODEVICE);
 	}
@@ -1808,6 +1849,7 @@ static int e100_rx_indicate(struct nic *
 	struct sk_buff *skb = rx->skb;
 	struct rfd *rfd = (struct rfd *)skb->data;
 	u16 rfd_status, actual_size;
+	u8 status;
 
 	if(unlikely(work_done && *work_done >= work_to_do))
 		return -EAGAIN;
@@ -1819,9 +1861,47 @@ static int e100_rx_indicate(struct nic *
 
 	DPRINTK(RX_STATUS, DEBUG, "status=0x%04X\n", rfd_status);
 
-	/* If data isn't ready, nothing to indicate */
-	if(unlikely(!(rfd_status & cb_complete)))
+	/* 
+	 * If data isn't ready, nothing to indicate
+	 * If both the el and s0 rx flags are set, we have hit the marked
+	 * buffer but we don't know if hardware has seen it so we check
+	 * the status.
+	 * If only the s0 flag is set, we check the next buffer.
+	 * If it is complete, we know that hardware saw the rfd el bit
+	 * get cleared but did not see the rfd size get set so it
+	 * skipped this buffer.  We just return 0 and look at the
+	 * next buffer.
+	 * If only the s0 flag is set but the next buffer is
+	 * not complete, we cleared the el flag as hardware
+	 * hit this buffer.
+	 */
+	if (unlikely(!(rfd_status & cb_complete))) {
+		u8 maskedFlags = rx->flags & (rx_el | rx_s0);
+		if (maskedFlags == (rx_el | rx_s0)) {
+			status = readb(&nic->csr->scb.status);
+			if (status & rus_no_res)
+				nic->ru_running = ru_stopped;
+		} else if (maskedFlags == rx_s0) {
+			struct rx *next_rx = rx->next;
+			struct rfd *next_rfd = (struct rfd *)next_rx->skb->data;
+			pci_dma_sync_single_for_cpu(nic->pdev,
+				next_rx->dma_addr, sizeof(struct rfd),
+				PCI_DMA_FROMDEVICE);
+			if (next_rfd->status & cpu_to_le16(cb_complete)) {
+				pci_unmap_single(nic->pdev, rx->dma_addr,
+					RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
+				dev_kfree_skb_any(skb);
+				rx->skb = NULL;
+				rx->flags &= ~rx_s0;
+				return 0;
+			} else {
+				status = readb(&nic->csr->scb.status);
+				if (status & rus_no_res)
+					nic->ru_running = ru_stopped;
+			}
+		}
 		return -ENODATA;
+	}
 
 	/* Get actual data size */
 	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
@@ -1832,9 +1912,15 @@ static int e100_rx_indicate(struct nic *
 	pci_unmap_single(nic->pdev, rx->dma_addr,
 		RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
 
-	/* this allows for a fast restart without re-enabling interrupts */
-	if(le16_to_cpu(rfd->command) & cb_el)
-		nic->ru_running = RU_SUSPENDED;
+	/*
+	 * This happens when hardward sees the rfd el flag set
+	 * but then sees the rfd size set as well
+	 */
+	if (le16_to_cpu(rfd->command) & cb_el) {
+		status = readb(&nic->csr->scb.status);
+		if (status & rus_no_res)
+			nic->ru_running = ru_stopped;
+	}
 
 	/* Pull off the RFD and put the actual data (minus eth hdr) */
 	skb_reserve(skb, sizeof(struct rfd));
@@ -1865,32 +1951,34 @@ static int e100_rx_indicate(struct nic *
 static void e100_rx_clean(struct nic *nic, unsigned int *work_done,
 	unsigned int work_to_do)
 {
-	struct rx *rx;
+	struct rx *rx, *marked_rx;
 	int restart_required = 0;
-	struct rx *rx_to_start = NULL;
-
-	/* are we already rnr? then pay attention!!! this ensures that
-	 * the state machine progression never allows a start with a
-	 * partially cleaned list, avoiding a race between hardware
-	 * and rx_to_clean when in NAPI mode */
-	if(RU_SUSPENDED == nic->ru_running)
-		restart_required = 1;
+	int err = 0;
 
 	/* Indicate newly arrived packets */
 	for(rx = nic->rx_to_clean; rx->skb; rx = nic->rx_to_clean = rx->next) {
-		int err = e100_rx_indicate(nic, rx, work_done, work_to_do);
-		if(-EAGAIN == err) {
-			/* hit quota so have more work to do, restart once
-			 * cleanup is complete */
-			restart_required = 0;
+		err = e100_rx_indicate(nic, rx, work_done, work_to_do);
+		/* Hit quota or no more to clean */
+		if(-EAGAIN == err || -ENODATA == err)
 			break;
-		} else if(-ENODATA == err)
-			break; /* No more to clean */
 	}
 
-	/* save our starting point as the place we'll restart the receiver */
-	if(restart_required)
-		rx_to_start = nic->rx_to_clean;
+	/*
+	 * On EAGAIN, hit quota so have more work to do, restart once
+	 * cleanup is complete.
+	 * Else, are we already rnr? then pay attention!!! this ensures that
+	 * the state machine progression never allows a start with a
+	 * partially cleaned list, avoiding a race between hardware
+	 * and rx_to_clean when in NAPI mode
+	 */
+	if(-EAGAIN != err && ru_stopped == nic->ru_running)
+		restart_required = 1;
+
+	marked_rx = nic->rx_to_use->prev->prev;
+	if (!(marked_rx->flags & rx_el)) {
+		marked_rx = marked_rx->prev;
+		BUG_ON(!marked_rx->flags & rx_el);
+	}
 
 	/* Alloc new skbs to refill list */
 	for(rx = nic->rx_to_use; !rx->skb; rx = nic->rx_to_use = rx->next) {
@@ -1898,10 +1986,12 @@ static void e100_rx_clean(struct nic *ni
 			break; /* Better luck next time (see watchdog) */
 	}
 
+	e100_find_mark_el(nic, marked_rx, !restart_required);
+
 	if(restart_required) {
 		// ack the rnr?
 		writeb(stat_ack_rnr, &nic->csr->scb.stat_ack);
-		e100_start_receiver(nic, rx_to_start);
+		e100_start_receiver(nic);
 		if(work_done)
 			(*work_done)++;
 	}
@@ -1912,8 +2002,6 @@ static void e100_rx_clean_list(struct ni
 	struct rx *rx;
 	unsigned int i, count = nic->params.rfds.count;
 
-	nic->ru_running = RU_UNINITIALIZED;
-
 	if(nic->rxs) {
 		for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
 			if(rx->skb) {
@@ -1935,7 +2023,6 @@ static int e100_rx_alloc_list(struct nic
 	unsigned int i, count = nic->params.rfds.count;
 
 	nic->rx_to_use = nic->rx_to_clean = NULL;
-	nic->ru_running = RU_UNINITIALIZED;
 
 	if(!(nic->rxs = kcalloc(count, sizeof(struct rx), GFP_ATOMIC)))
 		return -ENOMEM;
@@ -1950,7 +2037,9 @@ static int e100_rx_alloc_list(struct nic
 	}
 
 	nic->rx_to_use = nic->rx_to_clean = nic->rxs;
-	nic->ru_running = RU_SUSPENDED;
+	nic->ru_running = ru_stopped;
+
+	e100_find_mark_el(nic, NULL, 0);
 
 	return 0;
 }
@@ -1971,8 +2060,8 @@ static irqreturn_t e100_intr(int irq, vo
 	iowrite8(stat_ack, &nic->csr->scb.stat_ack);
 
 	/* We hit Receive No Resource (RNR); restart RU after cleaning */
-	if(stat_ack & stat_ack_rnr)
-		nic->ru_running = RU_SUSPENDED;
+	if (stat_ack & stat_ack_rnr)
+		nic->ru_running = ru_stopped;
 
 	if(likely(netif_rx_schedule_prep(netdev))) {
 		e100_disable_irq(nic);
@@ -2065,7 +2154,7 @@ static int e100_up(struct nic *nic)
 	if((err = e100_hw_init(nic)))
 		goto err_clean_cbs;
 	e100_set_multicast_list(nic->netdev);
-	e100_start_receiver(nic, NULL);
+	e100_start_receiver(nic);
 	mod_timer(&nic->watchdog, jiffies);
 	if((err = request_irq(nic->pdev->irq, e100_intr, IRQF_SHARED,
 		nic->netdev->name, nic->netdev)))
@@ -2146,7 +2235,7 @@ static int e100_loopback_test(struct nic
 		mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR,
 			BMCR_LOOPBACK);
 
-	e100_start_receiver(nic, NULL);
+	e100_start_receiver(nic);
 
 	if(!(skb = netdev_alloc_skb(nic->netdev, ETH_DATA_LEN))) {
 		err = -ENOMEM;
