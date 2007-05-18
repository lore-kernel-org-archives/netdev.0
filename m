From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and
 el bits)
Date: Fri, 18 May 2007 13:11:26 -0400
Message-ID: <464DDE3E.9010400@roinet.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Milton Miller <miltonm@bga.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:59774
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665AbXERRKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 13:10:45 -0400
In-Reply-To: <464DCD5E.50003@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> First impression just came in: It seems RX performance is dropped to 
> 10mbit. TX is unaffected and runs at 94mbit/tcp, but RX the new code 
> seems to misbehave and  fluctuate, dropping below 10mbit after a few 
> netperf runs and staying there...
> 
> ideas?

I found the problem.  Another casualty of working with two different kernels at once...arg.
The blank rfd needs to have its el-bit clear now.  Here is the new and improved patch.

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

--- linux-2.6.22-rc1/drivers/net/e100.c.orig	2007-05-18 13:08:01.000000000 -0400
+++ linux-2.6.22-rc1/drivers/net/e100.c	2007-05-18 13:08:24.000000000 -0400
@@ -285,6 +285,12 @@ enum scb_status {
  	rus_mask         = 0x3C,
  };

+enum ru_state  {
+	RU_SUSPENDED = 0,
+	RU_RUNNING	 = 1,
+	RU_UNINITIALIZED = -1,
+};
+
  enum scb_stat_ack {
  	stat_ack_not_ours    = 0x00,
  	stat_ack_sw_gen      = 0x04,
@@ -526,6 +532,7 @@ struct nic {
  	struct rx *rx_to_use;
  	struct rx *rx_to_clean;
  	struct rfd blank_rfd;
+	enum ru_state ru_running;

  	spinlock_t cb_lock			____cacheline_aligned;
  	spinlock_t cmd_lock;
@@ -947,7 +954,7 @@ static void e100_get_defaults(struct nic
  		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));

  	/* Template for a freshly allocated RFD */
-	nic->blank_rfd.command = cpu_to_le16(cb_el & cb_s);
+	nic->blank_rfd.command = 0;
  	nic->blank_rfd.rbd = 0xFFFFFFFF;
  	nic->blank_rfd.size = cpu_to_le16(VLAN_ETH_FRAME_LEN);

@@ -1742,11 +1749,19 @@ static int e100_alloc_cbs(struct nic *ni
  	return 0;
  }

-static inline void e100_start_receiver(struct nic *nic)
+static inline void e100_start_receiver(struct nic *nic, struct rx *rx)
  {
-	/* Start if RFA is non-NULL */
-	if(nic->rx_to_clean->skb)
-		e100_exec_cmd(nic, ruc_start, nic->rx_to_clean->dma_addr);
+	if(!nic->rxs) return;
+	if(RU_SUSPENDED != nic->ru_running) return;
+
+	/* handle init time starts */
+	if(!rx) rx = nic->rxs;
+
+	/* (Re)start RU if suspended or idle and RFA is non-NULL */
+	if(rx->skb) {
+		e100_exec_cmd(nic, ruc_start, rx->dma_addr);
+		nic->ru_running = RU_RUNNING;
+	}
  }

  #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
@@ -1769,13 +1784,12 @@ static int e100_rx_alloc_skb(struct nic
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
-		prev_rfd->command &= ~cpu_to_le16(cb_el & cb_s);
  		pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
  			sizeof(struct rfd), PCI_DMA_TODEVICE);
  	}
@@ -1801,8 +1815,12 @@ static int e100_rx_indicate(struct nic *
  	DPRINTK(RX_STATUS, DEBUG, "status=0x%04X\n", rfd_status);

  	/* If data isn't ready, nothing to indicate */
-	if(unlikely(!(rfd_status & cb_complete)))
+	if(unlikely(!(rfd_status & cb_complete))) {
+		/* this allows for a fast restart without re-enabling interrupts */
+		if(le16_to_cpu(rfd->command) & cb_el)
+			nic->ru_running = RU_SUSPENDED;
  		return -ENODATA;
+	}

  	/* Get actual data size */
  	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
@@ -1813,6 +1831,10 @@ static int e100_rx_indicate(struct nic *
  	pci_unmap_single(nic->pdev, rx->dma_addr,
  		RFD_BUF_LEN, PCI_DMA_FROMDEVICE);

+	/* this allows for a fast restart without re-enabling interrupts */
+	if(le16_to_cpu(rfd->command) & cb_el)
+		nic->ru_running = RU_SUSPENDED;
+
  	/* Pull off the RFD and put the actual data (minus eth hdr) */
  	skb_reserve(skb, sizeof(struct rfd));
  	skb_put(skb, actual_size);
@@ -1843,18 +1865,78 @@ static void e100_rx_clean(struct nic *ni
  	unsigned int work_to_do)
  {
  	struct rx *rx;
+	int restart_required = 0;
+	struct rx *rx_to_start = NULL;
+	struct rx *old_before_last_rx, *new_before_last_rx;
+	struct rfd *old_before_last_rfd, *new_before_last_rfd;
+
+	/* are we already rnr? then pay attention!!! this ensures that
+	 * the state machine progression never allows a start with a
+	 * partially cleaned list, avoiding a race between hardware
+	 * and rx_to_clean when in NAPI mode */
+	if(RU_SUSPENDED == nic->ru_running)
+		restart_required = 1;

  	/* Indicate newly arrived packets */
  	for(rx = nic->rx_to_clean; rx->skb; rx = nic->rx_to_clean = rx->next) {
-		if(e100_rx_indicate(nic, rx, work_done, work_to_do))
+		int err = e100_rx_indicate(nic, rx, work_done, work_to_do);
+		if(-EAGAIN == err) {
+			/* hit quota so have more work to do, restart once
+			 * cleanup is complete */
+			restart_required = 0;
+			break;
+		} else if(-ENODATA == err)
  			break; /* No more to clean */
  	}

+	/* save our starting point as the place we'll restart the receiver */
+	if(restart_required)
+		rx_to_start = nic->rx_to_clean;
+
+	old_before_last_rx = nic->rx_to_use->prev->prev;
+	old_before_last_rfd = (struct rfd *)old_before_last_rx->skb->data;
+
  	/* Alloc new skbs to refill list */
  	for(rx = nic->rx_to_use; !rx->skb; rx = nic->rx_to_use = rx->next) {
  		if(unlikely(e100_rx_alloc_skb(nic, rx)))
  			break; /* Better luck next time (see watchdog) */
  	}
+
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
+	if(restart_required) {
+		// ack the rnr?
+		writeb(stat_ack_rnr, &nic->csr->scb.stat_ack);
+		e100_start_receiver(nic, rx_to_start);
+		if(work_done)
+			(*work_done)++;
+	}
  }

  static void e100_rx_clean_list(struct nic *nic)
@@ -1862,6 +1944,8 @@ static void e100_rx_clean_list(struct ni
  	struct rx *rx;
  	unsigned int i, count = nic->params.rfds.count;

+	nic->ru_running = RU_UNINITIALIZED;
+
  	if(nic->rxs) {
  		for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
  			if(rx->skb) {
@@ -1881,8 +1965,10 @@ static int e100_rx_alloc_list(struct nic
  {
  	struct rx *rx;
  	unsigned int i, count = nic->params.rfds.count;
+	struct rfd *before_last;

  	nic->rx_to_use = nic->rx_to_clean = NULL;
+	nic->ru_running = RU_UNINITIALIZED;

  	if(!(nic->rxs = kcalloc(count, sizeof(struct rx), GFP_ATOMIC)))
  		return -ENOMEM;
@@ -1896,7 +1982,22 @@ static int e100_rx_alloc_list(struct nic
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
+	nic->ru_running = RU_SUSPENDED;

  	return 0;
  }
@@ -1916,6 +2017,10 @@ static irqreturn_t e100_intr(int irq, vo
  	/* Ack interrupt(s) */
  	iowrite8(stat_ack, &nic->csr->scb.stat_ack);

+	/* We hit Receive No Resource (RNR); restart RU after cleaning */
+	if(stat_ack & stat_ack_rnr)
+		nic->ru_running = RU_SUSPENDED;
+
  	if(likely(netif_rx_schedule_prep(netdev))) {
  		e100_disable_irq(nic);
  		__netif_rx_schedule(netdev);
@@ -2007,7 +2112,7 @@ static int e100_up(struct nic *nic)
  	if((err = e100_hw_init(nic)))
  		goto err_clean_cbs;
  	e100_set_multicast_list(nic->netdev);
-	e100_start_receiver(nic);
+	e100_start_receiver(nic, NULL);
  	mod_timer(&nic->watchdog, jiffies);
  	if((err = request_irq(nic->pdev->irq, e100_intr, IRQF_SHARED,
  		nic->netdev->name, nic->netdev)))
@@ -2088,7 +2193,7 @@ static int e100_loopback_test(struct nic
  		mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR,
  			BMCR_LOOPBACK);

-	e100_start_receiver(nic);
+	e100_start_receiver(nic, NULL);

  	if(!(skb = netdev_alloc_skb(nic->netdev, ETH_DATA_LEN))) {
  		err = -ENOMEM;

