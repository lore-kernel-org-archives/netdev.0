From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and
 el bits)
Date: Fri, 01 Jun 2007 16:45:34 -0400
Message-ID: <4660856E.80403@roinet.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com> <464DDE3E.9010400@roinet.com> <e3819b7a866b1117fd5a69e6a85e0784@bga.com> <4651DAC1.7050604@intel.com> <53c44b6f03973eb1b28f221859d3002c@bga.com> <465369AF.8080508@roinet.com> <f83441453b1233771c5bda869912aeca@bga.com> <4654B2E4.9010308@roinet.com> <039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com> <a4fae96e1c8c7b594207bf77fcb6b38f@bga.com> <465C4DBE.6000205@roinet.com> <94c8ff9069a77568513a9a1d1e60012d@bga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>, netdev@vger.kernel.org
To: Milton Miller <miltonm@bga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:41592
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932135AbXFAUpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 16:45:04 -0400
In-Reply-To: <94c8ff9069a77568513a9a1d1e60012d@bga.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Milton Miller wrote:
> Your logic works, this adds some conditional branching but saves a 
> pointer, not sure which is better.  Mine can be used for initializing 
> without special casing since it will just calculate rx_to_unmark as 
> rx[n-2] and rx_to_mark as rx[n-2] != rx[n-2]->prev; unmarking a never 
> marked still works, where as for yours the "was marked" must be 
> explicitly set to something (hmm, rxs = rx[0] might work for that 
> initial value until we mark -2??)
> 
> again, the compare of rx->el instead of rx->rfd->el is to save cache 
> traffic to the rfd under io.  The rx->was_0 is required, so the el flag 
> is free.
> 

Ok, I took a stab at coding and testing these ideas.  Below is a patch against 2.6.22-rc3.
Let me know what you think.  Testing shows that we can hit any of the following scenarios:

Find a buffer not complete with rx->el and rx->s0 set. I read back the status and see if
the receiver is still running.
Find a buffer not complete with rx->el not set and rx->s0 set.  I check the next buffer
and if it is complete, I free the skb and return 0.  If the next buffer is not
complete, I read the receiver's status to see if he is still running.
Find a buffer that is complete with rx->el not set and rx->s0 set.  It appears that hardware
can read the rfd's el-bit, then software can clear the rfd el-bit and set the rfd size, and
then hardware can come in and read the size.  I am reading the status back, although
I don't think that I have to in this instance.

I am testing a version of this code patched against 2.6.18.4 on my PXA 255 based system.  I will let 
you all know how it goes.

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
it can update the tail of the list when either it knows the hardware
has stopped or the previous to the new one to mark marked.
Once it has a new next to last buffer prepared, it can clear the el-bit
and set the size on the previous one.  The race on this buffer is safe
since the link already points to a valid next buffer.  We keep flags
in our software descriptor to note if the el bit is set and if the size
was 0.  When we clear the RFD's el bit and set its size, we also clear
the el flag but we leave the size was 0 bit set.  This was we can find
this buffer again later.

If the hardware sees the el-bit cleared without the size set, it will
move on to the next buffer and skip this one.  If it sees
the size set but the el-bit still set, it will complete that buffer
and then RNR interrupt and wait.


Signed-off-by: David Acker <dacker@roinet.com>

---

--- linux-2.6.22-rc3/drivers/net/e100.c.orig	2007-06-01 16:13:16.000000000 -0400
+++ linux-2.6.22-rc3/drivers/net/e100.c	2007-06-01 16:20:36.000000000 -0400
@@ -281,10 +281,17 @@ struct csr {
  };

  enum scb_status {
+	rus_no_res       = 0x08,
  	rus_ready        = 0x10,
  	rus_mask         = 0x3C,
  };

+enum ru_state  {
+	ru_suspended = 0,
+	ru_running	 = 1,
+	ru_uninitialized = -1,
+};
+
  enum scb_stat_ack {
  	stat_ack_not_ours    = 0x00,
  	stat_ack_sw_gen      = 0x04,
@@ -395,10 +402,16 @@ struct rfd {
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
@@ -526,6 +539,7 @@ struct nic {
  	struct rx *rx_to_use;
  	struct rx *rx_to_clean;
  	struct rfd blank_rfd;
+	enum ru_state ru_running;

  	spinlock_t cb_lock			____cacheline_aligned;
  	spinlock_t cmd_lock;
@@ -947,7 +961,7 @@ static void e100_get_defaults(struct nic
  		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));

  	/* Template for a freshly allocated RFD */
-	nic->blank_rfd.command = cpu_to_le16(cb_el & cb_s);
+	nic->blank_rfd.command = 0;
  	nic->blank_rfd.rbd = 0xFFFFFFFF;
  	nic->blank_rfd.size = cpu_to_le16(VLAN_ETH_FRAME_LEN);

@@ -1742,11 +1756,55 @@ static int e100_alloc_cbs(struct nic *ni
  	return 0;
  }

-static inline void e100_start_receiver(struct nic *nic)
+static void e100_find_mark_el(struct nic *nic, struct rx *marked_rx, int is_running)
  {
-	/* Start if RFA is non-NULL */
-	if(nic->rx_to_clean->skb)
-		e100_exec_cmd(nic, ruc_start, nic->rx_to_clean->dma_addr);
+	struct rx *rx_to_mark = nic->rx_to_use->prev->prev;
+	struct rfd *rfd_to_mark;
+
+	if(is_running && rx_to_mark->prev->flags & rx_el)
+		return;
+
+	if(marked_rx == rx_to_mark)
+		return;
+
+	rfd_to_mark = (struct rfd *) rx_to_mark->skb->data;
+	rfd_to_mark->command |= cpu_to_le16(cb_el);
+	rfd_to_mark->size = 0;
+	pci_dma_sync_single_for_cpu(nic->pdev, rx_to_mark->dma_addr,
+		sizeof(struct rfd), PCI_DMA_TODEVICE);
+	rx_to_mark->flags |= (rx_el | rx_s0);
+
+	if(!marked_rx)
+		return;
+
+	rfd_to_mark = (struct rfd *) marked_rx->skb->data;
+	rfd_to_mark->command &= ~cpu_to_le16(cb_el);
+	pci_dma_sync_single_for_cpu(nic->pdev, marked_rx->dma_addr,
+		sizeof(struct rfd), PCI_DMA_TODEVICE);
+
+	rfd_to_mark->size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
+	pci_dma_sync_single_for_cpu(nic->pdev, marked_rx->dma_addr,
+		sizeof(struct rfd), PCI_DMA_TODEVICE);
+
+	if(is_running)
+		marked_rx->flags &= ~rx_el;
+	else
+		marked_rx->flags &= ~(rx_el | rx_s0);
+}
+
+static inline void e100_start_receiver(struct nic *nic, struct rx *rx)
+{
+	if(!nic->rxs) return;
+	if(ru_suspended != nic->ru_running) return;
+
+	/* handle init time starts */
+	if(!rx) rx = nic->rxs;
+
+	/* (Re)start RU if suspended or idle and RFA is non-NULL */
+	if(rx->skb) {
+		e100_exec_cmd(nic, ruc_start, rx->dma_addr);
+		nic->ru_running = ru_running;
+	}
  }

  #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
@@ -1774,8 +1832,6 @@ static int e100_rx_alloc_skb(struct nic
  		struct rfd *prev_rfd = (struct rfd *)rx->prev->skb->data;
  		put_unaligned(cpu_to_le32(rx->dma_addr),
  			(u32 *)&prev_rfd->link);
-		wmb();
-		prev_rfd->command &= ~cpu_to_le16(cb_el & cb_s);
  		pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
  			sizeof(struct rfd), PCI_DMA_TODEVICE);
  	}
@@ -1789,6 +1845,7 @@ static int e100_rx_indicate(struct nic *
  	struct sk_buff *skb = rx->skb;
  	struct rfd *rfd = (struct rfd *)skb->data;
  	u16 rfd_status, actual_size;
+	u8 status;

  	if(unlikely(work_done && *work_done >= work_to_do))
  		return -EAGAIN;
@@ -1800,9 +1857,46 @@ static int e100_rx_indicate(struct nic *

  	DPRINTK(RX_STATUS, DEBUG, "status=0x%04X\n", rfd_status);

-	/* If data isn't ready, nothing to indicate */
-	if(unlikely(!(rfd_status & cb_complete)))
+	/* If data isn't ready, nothing to indicate
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
+	 * hit this buffer. */
+	if(unlikely(!(rfd_status & cb_complete))) {
+		u8 maskedFlags = rx->flags & (rx_el | rx_s0);
+		if(maskedFlags == (rx_el | rx_s0)) {
+			status = ioread8(&nic->csr->scb.status);
+			if(status & rus_no_res) {
+				nic->ru_running = ru_suspended;
+			}
+		} else if(maskedFlags == rx_s0) {
+			struct rx *next_rx = rx->next;
+			struct rfd *next_rfd = (struct rfd *)next_rx->skb->data;
+			pci_dma_sync_single_for_cpu(nic->pdev, next_rx->dma_addr,
+				sizeof(struct rfd), PCI_DMA_FROMDEVICE);
+			if(next_rfd->status & cpu_to_le16(cb_complete)) {
+				pci_unmap_single(nic->pdev, rx->dma_addr,
+					RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
+				dev_kfree_skb_any(skb);
+				rx->skb = NULL;
+				rx->flags &= ~rx_s0;
+				return 0;
+			} else {
+				status = ioread8(&nic->csr->scb.status);
+				if(status & rus_no_res) {
+					nic->ru_running = ru_suspended;
+				}
+			}
+		}
  		return -ENODATA;
+	}

  	/* Get actual data size */
  	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
@@ -1813,6 +1907,15 @@ static int e100_rx_indicate(struct nic *
  	pci_unmap_single(nic->pdev, rx->dma_addr,
  		RFD_BUF_LEN, PCI_DMA_FROMDEVICE);

+	/* This happens when hardward sees the rfd el flag set
+	 * but then sees the rfd size set as well */
+	if(le16_to_cpu(rfd->command) & cb_el) {
+		status = ioread8(&nic->csr->scb.status);
+		if(status & rus_no_res) {
+			nic->ru_running = ru_suspended;
+		}
+	}
+
  	/* Pull off the RFD and put the actual data (minus eth hdr) */
  	skb_reserve(skb, sizeof(struct rfd));
  	skb_put(skb, actual_size);
@@ -1842,19 +1945,46 @@ static int e100_rx_indicate(struct nic *
  static void e100_rx_clean(struct nic *nic, unsigned int *work_done,
  	unsigned int work_to_do)
  {
-	struct rx *rx;
+	struct rx *rx, *marked_rx;
+	int restart_required = 0;
+	int err = 0;

  	/* Indicate newly arrived packets */
  	for(rx = nic->rx_to_clean; rx->skb; rx = nic->rx_to_clean = rx->next) {
-		if(e100_rx_indicate(nic, rx, work_done, work_to_do))
-			break; /* No more to clean */
+		err = e100_rx_indicate(nic, rx, work_done, work_to_do);
+		/* Hit quota or no more to clean */
+		if(-EAGAIN == err || -ENODATA == err)
+			break;
  	}

+	/* On EAGAIN, hit quota so have more work to do, restart once
+	 * cleanup is complete.
+	 * Else, are we already rnr? then pay attention!!! this ensures that
+	 * the state machine progression never allows a start with a
+	 * partially cleaned list, avoiding a race between hardware
+	 * and rx_to_clean when in NAPI mode */
+	if(-EAGAIN != err && ru_suspended == nic->ru_running)
+		restart_required = 1;
+
+	marked_rx = nic->rx_to_use->prev->prev;
+	while(!(marked_rx->flags & rx_el))
+		marked_rx = marked_rx->prev;
+
  	/* Alloc new skbs to refill list */
  	for(rx = nic->rx_to_use; !rx->skb; rx = nic->rx_to_use = rx->next) {
  		if(unlikely(e100_rx_alloc_skb(nic, rx)))
  			break; /* Better luck next time (see watchdog) */
  	}
+
+	e100_find_mark_el(nic, marked_rx, !restart_required);
+
+	if(restart_required) {
+		// ack the rnr?
+		iowrite8(stat_ack_rnr, &nic->csr->scb.stat_ack);
+		e100_start_receiver(nic, nic->rx_to_clean);
+		if(work_done)
+			(*work_done)++;
+	}
  }

  static void e100_rx_clean_list(struct nic *nic)
@@ -1862,6 +1992,8 @@ static void e100_rx_clean_list(struct ni
  	struct rx *rx;
  	unsigned int i, count = nic->params.rfds.count;

+	nic->ru_running = ru_uninitialized;
+
  	if(nic->rxs) {
  		for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
  			if(rx->skb) {
@@ -1883,6 +2015,7 @@ static int e100_rx_alloc_list(struct nic
  	unsigned int i, count = nic->params.rfds.count;

  	nic->rx_to_use = nic->rx_to_clean = NULL;
+	nic->ru_running = ru_uninitialized;

  	if(!(nic->rxs = kcalloc(count, sizeof(struct rx), GFP_ATOMIC)))
  		return -ENOMEM;
@@ -1897,6 +2030,9 @@ static int e100_rx_alloc_list(struct nic
  	}

  	nic->rx_to_use = nic->rx_to_clean = nic->rxs;
+	nic->ru_running = ru_suspended;
+
+	e100_find_mark_el(nic, NULL, 0);

  	return 0;
  }
@@ -1916,6 +2052,10 @@ static irqreturn_t e100_intr(int irq, vo
  	/* Ack interrupt(s) */
  	iowrite8(stat_ack, &nic->csr->scb.stat_ack);

+	/* We hit Receive No Resource (RNR); restart RU after cleaning */
+	if(stat_ack & stat_ack_rnr)
+		nic->ru_running = ru_suspended;
+
  	if(likely(netif_rx_schedule_prep(netdev))) {
  		e100_disable_irq(nic);
  		__netif_rx_schedule(netdev);
@@ -2007,7 +2147,7 @@ static int e100_up(struct nic *nic)
  	if((err = e100_hw_init(nic)))
  		goto err_clean_cbs;
  	e100_set_multicast_list(nic->netdev);
-	e100_start_receiver(nic);
+	e100_start_receiver(nic, NULL);
  	mod_timer(&nic->watchdog, jiffies);
  	if((err = request_irq(nic->pdev->irq, e100_intr, IRQF_SHARED,
  		nic->netdev->name, nic->netdev)))
@@ -2088,7 +2228,7 @@ static int e100_loopback_test(struct nic
  		mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR,
  			BMCR_LOOPBACK);

-	e100_start_receiver(nic);
+	e100_start_receiver(nic, NULL);

  	if(!(skb = netdev_alloc_skb(nic->netdev, ETH_DATA_LEN))) {
  		err = -ENOMEM;
