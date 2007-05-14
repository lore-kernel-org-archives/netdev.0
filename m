From: David Acker <dacker@roinet.com>
Subject: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and el
 bits)
Date: Mon, 14 May 2007 14:26:39 -0400
Message-ID: <4648A9DF.6030001@roinet.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>, netdev@vger.kernel.org
To: Milton Miller <miltonm@bga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:39180
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757122AbXENS0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 14:26:14 -0400
In-Reply-To: <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Milton Miller wrote:
> In fact 6.4.3.4 says 82557 will start dropping frames immediately.
> 
> Looking at the descriptions around page 101:
> (1) The link pointer, S, and EL is read when hw starts recieving the frame.
> (2) Its pretty clear EL overrides S from the order of the descriptions 
> in the text.
> (3) 6.4.3.3.1 #4 looks intresting -- That is a RFD with size 0 skips 
> frame fill and goes to the next packet.
> 
> How about putting a zero length descriptor in consistent memory to 
> suspend the rx unit before the last real frame?   In other words  fr0 -> 
> fr1 ... frN-2 -> frN-1 -> WaitHere0 -> FrN.   We could then have 2 such 
> frames, and when we refill modify FrN to the new chain, with the 
> WaitHere1 as its next-to-last, do the syncs, then clear the S bit on 
> WaitHere0.   When the rx passes WaitHere0 we can reclaim it for the next 
> use (might want a slightly larger pool, basically need RxRingSize / 
> RxRingFillBatch such frames.
> 

I managed to code up something similar to what Milton described here.  Below
is a patch against 2.6.21.1, before the S-bit patch.  I ran it through two
12 hour UDP tests with 20 megabits per second in each direction for data
going from an ethernet client to an 802.11g client.  I had the receive pool
sized at 16 buffers.

---

On the ARM, their is a race condition between software allocating a new receive
buffer and hardware writing into a buffer.  The two race on touching the last
Receive Frame Descriptor (RFD).  It has its el-bit set and its next link equal
to 0.  When hardware encounters this buffer it attempts to write data to it
and then update Status Word bits and Actual Count in the RFD.  At the same time
software may try to clear the el-bit and set the link address to a new buffer.
Since the entire RFD is once cache-line, the two write operations can
collide.  This can lead to the receive unit stalling or freed receive buffers
getting written to.

The fix is to set the el-bit on and the size to 0 on the next to last buffer
in the chain.  When the hardware encounters this buffer it stops and does
not write to it at all.  The hardware issues an RNR interrupt with the
receive unit in the No Resources state.  When software allocates buffers,
it can update the tail of the list because it knows the hardware will stop
at the buffer before it.  Once it has a new next to last buffer prepared,
it can clear the el-bit and set the size on the previous one.  The race on
this buffer is safe since the link already points to a valid next buffer.
If the hardware sees the el-bit cleared without the size set, it will
move on to the next buffer and complete that one in error.  If it sees
the size set but the el-bit still set, it will complete that buffer
and then RNR interrupt and wait.


Signed-off-by: David Acker <dacker@roinet.com>

---

--- linux-2.6.21.1/drivers/net/e100.c.orig	2007-05-11 11:27:11.000000000 -0400
+++ linux-2.6.21.1/drivers/net/e100.c	2007-05-11 11:39:06.000000000 -0400
@@ -1781,13 +1781,12 @@ static int e100_rx_alloc_skb(struct nic
  	}

  	/* Link the RFD to end of RFA by linking previous RFD to
-	 * this one, and clearing EL bit of previous.  */
+	 * this one.  We are safe to touch the previous RFD because
+	 * it is protected the before last buffer's el bit being set  */
  	if(rx->prev->skb) {
  		struct rfd *prev_rfd = (struct rfd *)rx->prev->skb->data;
  		put_unaligned(cpu_to_le32(rx->dma_addr),
  			(u32 *)&prev_rfd->link);
-		wmb();
-		prev_rfd->command &= ~cpu_to_le16(cb_el);
  		pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
  			sizeof(struct rfd), PCI_DMA_TODEVICE);
  	}
@@ -1861,6 +1860,8 @@ static void e100_rx_clean(struct nic *ni
  	struct rx *rx;
  	int restart_required = 0;
  	struct rx *rx_to_start = NULL;
+	struct rx *old_before_last_rx, *new_before_last_rx;
+	struct rfd *old_before_last_rfd, *new_before_last_rfd;

  	/* are we already rnr? then pay attention!!! this ensures that
  	 * the state machine progression never allows a start with a
@@ -1885,12 +1886,43 @@ static void e100_rx_clean(struct nic *ni
  	if(restart_required)
  		rx_to_start = nic->rx_to_clean;

+	old_before_last_rx = nic->rx_to_use->prev->prev;
+	old_before_last_rfd = (struct rfd *)old_before_last_rx->skb->data;
+
  	/* Alloc new skbs to refill list */
  	for(rx = nic->rx_to_use; !rx->skb; rx = nic->rx_to_use = rx->next) {
  		if(unlikely(e100_rx_alloc_skb(nic, rx)))
  			break; /* Better luck next time (see watchdog) */
  	}

+	new_before_last_rx = nic->rx_to_use->prev->prev;
+	if (new_before_last_rx != old_before_last_rx) {
+		/* Set the el-bit on the buffer that is before the last buffer.
+		 * This lets us update the next pointer on the last buffer without
+		 * worrying about hardware touching it.
+		 * We set the size to 0 to prevent hardware from touching this buffer.
+		 * When the hardware hits the before last buffer with el-bit and size
+		 * of 0, it will RNR interrupt, the RUS will go into the No Resources
+		 * state.  It will not complete nor write to this buffer. */
+		new_before_last_rfd = (struct rfd *)new_before_last_rx->skb->data;
+		new_before_last_rfd->size = 0;
+		new_before_last_rfd->command |= cpu_to_le16(cb_el);
+		pci_dma_sync_single_for_device(nic->pdev, new_before_last_rx->dma_addr,
+			sizeof(struct rfd), PCI_DMA_TODEVICE);
+
+		/* Now that we have a new stopping point, we can clear the old
+		 * stopping point.
+		 * Note: There appears to be a race here where the hardware
+		 * can complete this buffer with the el-bit set but with the
+		 * size also set.  The hardware RNR interrupts, the RUS
+		 * goes into the No Resources state. */
+		old_before_last_rfd->command &= ~cpu_to_le16(cb_el);
+		wmb();
+		old_before_last_rfd->size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
+		pci_dma_sync_single_for_device(nic->pdev, old_before_last_rx->dma_addr,
+			sizeof(struct rfd), PCI_DMA_TODEVICE);
+	}
+
  	if(restart_required) {
  		// ack the rnr?
  		writeb(stat_ack_rnr, &nic->csr->scb.stat_ack);
@@ -1926,6 +1958,7 @@ static int e100_rx_alloc_list(struct nic
  {
  	struct rx *rx;
  	unsigned int i, count = nic->params.rfds.count;
+	struct rfd *before_last;

  	nic->rx_to_use = nic->rx_to_clean = NULL;
  	nic->ru_running = RU_UNINITIALIZED;
@@ -1942,6 +1975,20 @@ static int e100_rx_alloc_list(struct nic
  		}
  	}

+	/* Set the el-bit on the buffer that is before the last buffer.
+	 * This lets us update the next pointer on the last buffer without
+	 * worrying about hardware touching it.
+	 * We set the size to 0 to prevent hardware from touching this buffer.
+	 * When the hardware hits the before last buffer with el-bit and size
+	 * of 0, it will RNR interrupt, the RUS will go into the No Resources
+	 * state.  It will not complete nor write to this buffer. */
+	rx = nic->rxs->prev->prev;
+	before_last = (struct rfd *)rx->skb->data;
+	before_last->command |= cpu_to_le16(cb_el);
+	before_last->size = 0;
+	pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
+		sizeof(struct rfd), PCI_DMA_TODEVICE);
+
  	nic->rx_to_use = nic->rx_to_clean = nic->rxs;
  	nic->ru_running = RU_SUSPENDED;


