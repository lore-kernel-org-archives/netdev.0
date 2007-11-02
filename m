From: dacker@roinet.com (David Acker)
Subject: [PATCH] Fix e100 on systems that have cache
	incoherent DMA
Date: Fri,  2 Nov 2007 09:27:03 -0400 (EDT)
Message-ID: <20071102132703.1652446C128@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Milton Miller <miltonm@bga.com>, Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
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


This is a patch for 2.6.24-rc1.

Signed-off-by: David Acker <dacker@roinet.com>

---

This version is based on the simpler patch I did in May.  The algorithm I tried
after that never worked correctly under load.  It would hang the RU and the
transmit unit sometimes and if the card was restarted it would often crash the
system with memory corruption.  This patch was tested on my embedded system
using pktgen.  I had it sending while a PC sent at it.  I also ran it as
wireless access point with a 12-hour bidirectional 20 mbps UDP going between an
ethernet host on the e100 and a wireless client.

--- linux-2.6.24-rc1/drivers/net/e100.c.orig	2007-11-01 11:42:35.000000000 -0400
+++ linux-2.6.24-rc1/drivers/net/e100.c	2007-11-02 09:09:47.000000000 -0400
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
@@ -281,14 +288,15 @@ struct csr {
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
+	ru_running	 = 1,
+	ru_uninitialized = -1,
 };
 
 enum scb_stat_ack {
@@ -952,7 +960,7 @@ static void e100_get_defaults(struct nic
 		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));
 
 	/* Template for a freshly allocated RFD */
-	nic->blank_rfd.command = cpu_to_le16(cb_el);
+	nic->blank_rfd.command = 0;
 	nic->blank_rfd.rbd = 0xFFFFFFFF;
 	nic->blank_rfd.size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
 
@@ -1759,7 +1767,7 @@ static int e100_alloc_cbs(struct nic *ni
 static inline void e100_start_receiver(struct nic *nic, struct rx *rx)
 {
 	if(!nic->rxs) return;
-	if(RU_SUSPENDED != nic->ru_running) return;
+	if (ru_stopped != nic->ru_running) return;
 
 	/* handle init time starts */
 	if(!rx) rx = nic->rxs;
@@ -1767,7 +1775,7 @@ static inline void e100_start_receiver(s
 	/* (Re)start RU if suspended or idle and RFA is non-NULL */
 	if(rx->skb) {
 		e100_exec_cmd(nic, ruc_start, rx->dma_addr);
-		nic->ru_running = RU_RUNNING;
+		nic->ru_running = ru_running;
 	}
 }
 
@@ -1791,15 +1799,12 @@ static int e100_rx_alloc_skb(struct nic 
 	}
 
 	/* Link the RFD to end of RFA by linking previous RFD to
-	 * this one, and clearing EL bit of previous.  */
+	 * this one.  We are safe to touch the previous RFD because
+	 * it is protected by the before last buffer's el bit being set */
 	if(rx->prev->skb) {
 		struct rfd *prev_rfd = (struct rfd *)rx->prev->skb->data;
 		put_unaligned(cpu_to_le32(rx->dma_addr),
 			(u32 *)&prev_rfd->link);
-		wmb();
-		prev_rfd->command &= ~cpu_to_le16(cb_el);
-		pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
-			sizeof(struct rfd), PCI_DMA_TODEVICE);
 	}
 
 	return 0;
@@ -1824,8 +1829,20 @@ static int e100_rx_indicate(struct nic *
 	DPRINTK(RX_STATUS, DEBUG, "status=0x%04X\n", rfd_status);
 
 	/* If data isn't ready, nothing to indicate */
-	if(unlikely(!(rfd_status & cb_complete)))
+	if (unlikely(!(rfd_status & cb_complete))) {
+		/* If the next buffer has the el bit, but we think the receiver
+		 * is still running, check to see if it really stopped while
+		 * we had interrupts off.
+		 * This allows for a fast restart without re-enabling
+		 * interrupts */
+		if ((le16_to_cpu(rfd->command) & cb_el) &&
+		    (ru_running == nic->ru_running)) {
+
+		    if (readb(&nic->csr->scb.status) & rus_no_res)
+			nic->ru_running = ru_stopped;
+		}
 		return -ENODATA;
+	}
 
 	/* Get actual data size */
 	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
@@ -1836,9 +1853,18 @@ static int e100_rx_indicate(struct nic *
 	pci_unmap_single(nic->pdev, rx->dma_addr,
 		RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
 
-	/* this allows for a fast restart without re-enabling interrupts */
-	if(le16_to_cpu(rfd->command) & cb_el)
-		nic->ru_running = RU_SUSPENDED;
+	/* If this buffer has the el bit, but we think the receiver
+	 * is still running, check to see if it really stopped while
+	 * we had interrupts off.
+	 * This allows for a fast restart without re-enabling interrupts.
+	 * This can happen when the RU sees the size change but also sees
+	 * the el bit set. */
+	if ((le16_to_cpu(rfd->command) & cb_el) &&
+	    (ru_running == nic->ru_running)) {
+
+	    if (readb(&nic->csr->scb.status) & rus_no_res)
+		nic->ru_running = ru_stopped;
+	}
 
 	/* Pull off the RFD and put the actual data (minus eth hdr) */
 	skb_reserve(skb, sizeof(struct rfd));
@@ -1870,31 +1896,30 @@ static void e100_rx_clean(struct nic *ni
 	unsigned int work_to_do)
 {
 	struct rx *rx;
-	int restart_required = 0;
-	struct rx *rx_to_start = NULL;
-
-	/* are we already rnr? then pay attention!!! this ensures that
-	 * the state machine progression never allows a start with a
-	 * partially cleaned list, avoiding a race between hardware
-	 * and rx_to_clean when in NAPI mode */
-	if(RU_SUSPENDED == nic->ru_running)
-		restart_required = 1;
+	int restart_required = 0, err = 0;
+	struct rx *old_before_last_rx, *new_before_last_rx;
+	struct rfd *old_before_last_rfd, *new_before_last_rfd;
 
 	/* Indicate newly arrived packets */
 	for(rx = nic->rx_to_clean; rx->skb; rx = nic->rx_to_clean = rx->next) {
-		int err = e100_rx_indicate(nic, rx, work_done, work_to_do);
-		if(-EAGAIN == err) {
-			/* hit quota so have more work to do, restart once
-			 * cleanup is complete */
-			restart_required = 0;
+		err = e100_rx_indicate(nic, rx, work_done, work_to_do);
+		/* Hit quota or no more to clean */
+		if (-EAGAIN == err || -ENODATA == err)
 			break;
-		} else if(-ENODATA == err)
-			break; /* No more to clean */
 	}
 
-	/* save our starting point as the place we'll restart the receiver */
-	if(restart_required)
-		rx_to_start = nic->rx_to_clean;
+
+	/* On EAGAIN, hit quota so have more work to do, restart once
+	 * cleanup is complete.
+	 * Else, are we already rnr? then pay attention!!! this ensures that
+	 * the state machine progression never allows a start with a
+	 * partially cleaned list, avoiding a race between hardware
+	 * and rx_to_clean when in NAPI mode */
+	if (-EAGAIN != err && ru_stopped == nic->ru_running)
+		restart_required = 1;
+
+	old_before_last_rx = nic->rx_to_use->prev->prev;
+	old_before_last_rfd = (struct rfd *)old_before_last_rx->skb->data;
 
 	/* Alloc new skbs to refill list */
 	for(rx = nic->rx_to_use; !rx->skb; rx = nic->rx_to_use = rx->next) {
@@ -1902,10 +1927,42 @@ static void e100_rx_clean(struct nic *ni
 			break; /* Better luck next time (see watchdog) */
 	}
 
+	new_before_last_rx = nic->rx_to_use->prev->prev;
+	if (new_before_last_rx != old_before_last_rx) {
+		/* Set the el-bit on the buffer that is before the last buffer.
+		 * This lets us update the next pointer on the last buffer
+		 * without worrying about hardware touching it.
+		 * We set the size to 0 to prevent hardware from touching this
+		 * buffer.
+		 * When the hardware hits the before last buffer with el-bit
+		 * and size of 0, it will RNR interrupt, the RUS will go into
+		 * the No Resources state.  It will not complete nor write to
+		 * this buffer. */
+		new_before_last_rfd =
+			(struct rfd *)new_before_last_rx->skb->data;
+		new_before_last_rfd->size = 0;
+		new_before_last_rfd->command |= cpu_to_le16(cb_el);
+		pci_dma_sync_single_for_device(nic->pdev,
+			new_before_last_rx->dma_addr, sizeof(struct rfd),
+			PCI_DMA_TODEVICE);
+
+		/* Now that we have a new stopping point, we can clear the old
+		 * stopping point.  We must sync twice to get the proper
+		 * ordering on the hardware side of things. */
+		old_before_last_rfd->command &= ~cpu_to_le16(cb_el);
+		pci_dma_sync_single_for_device(nic->pdev,
+			old_before_last_rx->dma_addr, sizeof(struct rfd),
+			PCI_DMA_TODEVICE);
+		old_before_last_rfd->size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
+		pci_dma_sync_single_for_device(nic->pdev,
+			old_before_last_rx->dma_addr, sizeof(struct rfd),
+			PCI_DMA_TODEVICE);
+	}
+
 	if(restart_required) {
 		// ack the rnr?
 		writeb(stat_ack_rnr, &nic->csr->scb.stat_ack);
-		e100_start_receiver(nic, rx_to_start);
+		e100_start_receiver(nic, nic->rx_to_clean);
 		if(work_done)
 			(*work_done)++;
 	}
@@ -1916,7 +1973,7 @@ static void e100_rx_clean_list(struct ni
 	struct rx *rx;
 	unsigned int i, count = nic->params.rfds.count;
 
-	nic->ru_running = RU_UNINITIALIZED;
+	nic->ru_running = ru_uninitialized;
 
 	if(nic->rxs) {
 		for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
@@ -1937,9 +1994,10 @@ static int e100_rx_alloc_list(struct nic
 {
 	struct rx *rx;
 	unsigned int i, count = nic->params.rfds.count;
+	struct rfd *before_last;
 
 	nic->rx_to_use = nic->rx_to_clean = NULL;
-	nic->ru_running = RU_UNINITIALIZED;
+	nic->ru_running = ru_uninitialized;
 
 	if(!(nic->rxs = kcalloc(count, sizeof(struct rx), GFP_ATOMIC)))
 		return -ENOMEM;
@@ -1952,9 +2010,22 @@ static int e100_rx_alloc_list(struct nic
 			return -ENOMEM;
 		}
 	}
+	/* Set the el-bit on the buffer that is before the last buffer.
+	 * This lets us update the next pointer on the last buffer without
+	 * worrying about hardware touching it.
+	 * We set the size to 0 to prevent hardware from touching this buffer.
+	 * When the hardware hits the before last buffer with el-bit and size
+	 * of 0, it will RNR interrupt, the RU will go into the No Resources
+	 * state.  It will not complete nor write to this buffer. */
+	rx = nic->rxs->prev->prev;
+	before_last = (struct rfd *)rx->skb->data;
+	before_last->command |= cpu_to_le16(cb_el);
+	before_last->size = 0;
+	pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
+		sizeof(struct rfd), PCI_DMA_TODEVICE);
 
 	nic->rx_to_use = nic->rx_to_clean = nic->rxs;
-	nic->ru_running = RU_SUSPENDED;
+	nic->ru_running = ru_stopped;
 
 	return 0;
 }
@@ -1976,7 +2047,7 @@ static irqreturn_t e100_intr(int irq, vo
 
 	/* We hit Receive No Resource (RNR); restart RU after cleaning */
 	if(stat_ack & stat_ack_rnr)
-		nic->ru_running = RU_SUSPENDED;
+		nic->ru_running = ru_stopped;
 
 	if(likely(netif_rx_schedule_prep(netdev, &nic->napi))) {
 		e100_disable_irq(nic);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
