From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100
	rx: or s and el bits)
Date: Mon, 4 Jun 2007 04:03:52 -0500
Message-ID: <fac4512e243d821a94e8ee7304240981@bga.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net>
	<46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com>
	<463BA906.30205@roinet.com>
	<85f07fc58d5ed2147d5214d0f0b4fe32@bga.com>
	<4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com>
	<464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com>
	<464DB619.3070900@roinet.com> <464DC676.90504@intel.com>
	<464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com>
	<464DDE3E.9010400@roinet.com>
	<e3819b7a866b1117fd5a69e6a85e0784@bga.com>
	<4651DAC1.7050604@intel.com>
	<53c44b6f03973eb1b28f221859d3002c@bga.com>
	<465369AF.8080508@roinet.com>
	<f83441453b1233771c5bda869912aeca@bga.com>
	<4654B2E4.9010308@roinet.com>
	<039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com>
	<a4fae96e1c8c7b594207bf77fcb6b38f@bga.com>
	<465C4DBE.6000205@roinet.com>
	<94c8ff9069a77568513a9a1d1e60012d@bga.com>
	<4660856E.80403@roinet.com>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: David Acker <dacker@roinet.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4660856E.80403@roinet.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


On Jun 1, 2007, at 3:45 PM, David Acker wrote:
> Ok, I took a stab at coding and testing these ideas.  Below is a patch 
> against 2.6.22-rc3.
> Let me know what you think.

I think you got most of the ideas.   As Auke noted, your coding style 
is showing again.   And your mailer again munged whitespace (fixed by 
s/^<space><space>/<space>/ s/^$/<space>/).

>   Testing shows that we can hit any of the following scenarios:
>
> Find a buffer not complete with rx->el and rx->s0 set.
> 	I read back the status and see if the receiver is still running.
>

This means the hardware reached what we think is end of list, good.

> Find a buffer not complete with rx->el not set and rx->s0 set.
> 	I check the next buffer and if it is complete, I free the skb and 
> return 0.	
This is the case when hardware read the descriptor between el being 
removed and size being set.


> If the next buffer is not  complete, I read the receiver's status to 
> see if he is still running.
>

The polling of still running will save us waiting for irq or next poll 
when hardware read el before we cleared it, at the cost of an ioread 
when there is simply no packet ready and we hit a fill mark.

> Find a buffer that is complete with rx->el not set and rx->s0 set.
> 	It appears that hardware can read the rfd's el-bit, then software can 
> clear the rfd el-bit and set the rfd size, and then hardware can come 
> in and read the size.

Yes, since the size is after the EL flag in the descriptor, this can 
happen since the pci read is not atomic.

> I am reading the status back, although I don't think that I have to in 
> this instance.

Actually, you are reading it when the rfd still has EL set.  Since the 
cpu will never encounter that case, the if condition is never 
satisfied.

How about creating a state unknown, for when we think we should check 
the device if its running.
If we are in this state and then encounter a received packet without s0 
set, we can set it back
to running.   We set it when we rx a packet with s0 set.

We then move both io_status reads to the caller.


> I am testing a version of this code patched against 2.6.18.4 on my PXA 
> 255 based system.  I will let you all know how it goes.

I'm assuming this is why the cleanup of the receiver start to always 
start on rx_to_clean got dropped again. :-)

Also, I would like a few sentences in the Driver Operation section IV 
Receive big comment.  Something like

In order to keep updates to the RFD link field from colliding with 
hardware writes to mark packets complete, we use the feature that 
hardware will not write to a size 0 descriptor and mark the previous 
packet as end-of-list (EL).   After updating the link, we remove EL and 
only then restore the size such that hardware may use the 
previous-to-end RFD.

at the end of the first paragraph, and insert software before "no 
locking is required" in the second.

>
> On the ARM, their is a race condition between software allocating a 
> new receive
> buffer and hardware writing into a buffer.  The two race on touching 
> the last
> Receive Frame Descriptor (RFD).  It has its el-bit set and its next 
> link equal
> to 0.  When hardware encounters this buffer it attempts to write data 
> to it
> and then update Status Word bits and Actual Count in the RFD.  At the 
> same time
> software may try to clear the el-bit and set the link address to a new 
> buffer.
> Since the entire RFD is once cache-line, the two write operations can
> collide.  This can lead to the receive unit stalling or freed receive 
> buffers
> getting written to.
>
> The fix is to set the el-bit on and the size to 0 on the next to last 
> buffer
> in the chain.  When the hardware encounters this buffer it stops and 
> does
> not write to it at all.  The hardware issues an RNR interrupt with the
> receive unit in the No Resources state.  When software allocates 
> buffers,
> it can update the tail of the list when either it knows the hardware
> has stopped or the previous to the new one to mark marked.
> Once it has a new next to last buffer prepared, it can clear the el-bit
> and set the size on the previous one.  The race on this buffer is safe
> since the link already points to a valid next buffer.  We keep flags
> in our software descriptor to note if the el bit is set and if the size
> was 0.  When we clear the RFD's el bit and set its size, we also clear
> the el flag but we leave the size was 0 bit set.  This was we can find
> this buffer again later.
>
> If the hardware sees the el-bit cleared without the size set, it will
> move on to the next buffer and skip this one.  If it sees
> the size set but the el-bit still set, it will complete that buffer
> and then RNR interrupt and wait.
>
>
> Signed-off-by: David Acker <dacker@roinet.com>
>
> ---
>
> --- linux-2.6.22-rc3/drivers/net/e100.c.orig	2007-06-01 
> 16:13:16.000000000 -0400
> +++ linux-2.6.22-rc3/drivers/net/e100.c	2007-06-01 16:20:36.000000000 
> -0400
> @@ -281,10 +281,17 @@ struct csr {
>  };
>
>  enum scb_status {
> +	rus_no_res       = 0x08,
>  	rus_ready        = 0x10,
>  	rus_mask         = 0x3C,
>  };
>
> +enum ru_state  {
> +	ru_suspended = 0,
> +	ru_running	 = 1,
> +	ru_uninitialized = -1,
> +};
> +

If we are going to have uninitialized, it should be 0.  But its only 
set (1) during teardown, and (2) during rx list allocation.  In the 
same function its set to suspended.

Also, lets call this stopped, not suspended.  Suspended is a specific 
hardware state we are not using.

See above for my comments about adding unknown or maybe_running.

>  enum scb_stat_ack {
>  	stat_ack_not_ours    = 0x00,
>  	stat_ack_sw_gen      = 0x04,
> @@ -395,10 +402,16 @@ struct rfd {
>  	u16 size;
>  };
>
> +enum rx_flags {
> +	rx_el = 0x01,
> +	rx_s0 = 0x02,
> +};
> +
>  struct rx {
>  	struct rx *next, *prev;
>  	struct sk_buff *skb;
>  	dma_addr_t dma_addr;
> +	u8 flags;
>  };
>
>  #if defined(__BIG_ENDIAN_BITFIELD)
> @@ -526,6 +539,7 @@ struct nic {
>  	struct rx *rx_to_use;
>  	struct rx *rx_to_clean;
>  	struct rfd blank_rfd;
> +	enum ru_state ru_running;
>
>  	spinlock_t cb_lock			____cacheline_aligned;
>  	spinlock_t cmd_lock;
> @@ -947,7 +961,7 @@ static void e100_get_defaults(struct nic
>  		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));
>
>  	/* Template for a freshly allocated RFD */
> -	nic->blank_rfd.command = cpu_to_le16(cb_el & cb_s);
> +	nic->blank_rfd.command = 0;
>  	nic->blank_rfd.rbd = 0xFFFFFFFF;
>  	nic->blank_rfd.size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
>
> @@ -1742,11 +1756,55 @@ static int e100_alloc_cbs(struct nic *ni
>  	return 0;
>  }
>
> -static inline void e100_start_receiver(struct nic *nic)
> +static void e100_find_mark_el(struct nic *nic, struct rx *marked_rx, 
> int is_running)
>  {
> -	/* Start if RFA is non-NULL */
> -	if(nic->rx_to_clean->skb)
> -		e100_exec_cmd(nic, ruc_start, nic->rx_to_clean->dma_addr);
> +	struct rx *rx_to_mark = nic->rx_to_use->prev->prev;
> +	struct rfd *rfd_to_mark;

Let's just call this rfd or mark_rfd (since its used for both mark 
setting and clearing).

> +
> +	if(is_running && rx_to_mark->prev->flags & rx_el)
> +		return;

or just rx_to_mark == marked_rx (saves the load of flags).

> +
> +	if(marked_rx == rx_to_mark)
> +		return;
> +
> +	rfd_to_mark = (struct rfd *) rx_to_mark->skb->data;
> +	rfd_to_mark->command |= cpu_to_le16(cb_el);
> +	rfd_to_mark->size = 0;
> +	pci_dma_sync_single_for_cpu(nic->pdev, rx_to_mark->dma_addr,
> +		sizeof(struct rfd), PCI_DMA_TODEVICE);

for_device, BIDIRECTIONAL

> +	rx_to_mark->flags |= (rx_el | rx_s0);
> +
> +	if(!marked_rx)
> +		return;
> +
> +	rfd_to_mark = (struct rfd *) marked_rx->skb->data;
> +	rfd_to_mark->command &= ~cpu_to_le16(cb_el);
> +	pci_dma_sync_single_for_cpu(nic->pdev, marked_rx->dma_addr,
> +		sizeof(struct rfd), PCI_DMA_TODEVICE);

for_device BIDIRECTIONAL

> +
> +	rfd_to_mark->size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
> +	pci_dma_sync_single_for_cpu(nic->pdev, marked_rx->dma_addr,
> +		sizeof(struct rfd), PCI_DMA_TODEVICE);
>
for_device BIDIRECTIONAL

> +
> +	if(is_running)
> +		marked_rx->flags &= ~rx_el;
> +	else
> +		marked_rx->flags &= ~(rx_el | rx_s0);
> +}
> +
> +static inline void e100_start_receiver(struct nic *nic, struct rx *rx)
> +{
> +	if(!nic->rxs) return;
> +	if(ru_suspended != nic->ru_running) return;
>
Are these checks just paranoia?  Can we call poll leading to rx_clean 
without setting up the receive list?

> +
> +	/* handle init time starts */
> +	if(!rx) rx = nic->rxs;

Again, as the previous patch noted, we can drop rx as a parameter and 
always (re)start on rx_to_clean.

> +
> +	/* (Re)start RU if suspended or idle and RFA is non-NULL */
> +	if(rx->skb) {
> +		e100_exec_cmd(nic, ruc_start, rx->dma_addr);
> +		nic->ru_running = ru_running;
> +	}
>  }
>
>  #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
> @@ -1774,8 +1832,6 @@ static int e100_rx_alloc_skb(struct nic
>  		struct rfd *prev_rfd = (struct rfd *)rx->prev->skb->data;
>  		put_unaligned(cpu_to_le32(rx->dma_addr),
>  			(u32 *)&prev_rfd->link);
> -		wmb();
> -		prev_rfd->command &= ~cpu_to_le16(cb_el & cb_s);
>  		pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
>  			sizeof(struct rfd), PCI_DMA_TODEVICE);
>  	}
> @@ -1789,6 +1845,7 @@ static int e100_rx_indicate(struct nic *
>  	struct sk_buff *skb = rx->skb;
>  	struct rfd *rfd = (struct rfd *)skb->data;
>  	u16 rfd_status, actual_size;
> +	u8 status;
>
>  	if(unlikely(work_done && *work_done >= work_to_do))
>  		return -EAGAIN;
> @@ -1800,9 +1857,46 @@ static int e100_rx_indicate(struct nic *
>
>  	DPRINTK(RX_STATUS, DEBUG, "status=0x%04X\n", rfd_status);
>
> -	/* If data isn't ready, nothing to indicate */
> -	if(unlikely(!(rfd_status & cb_complete)))
> +	/* If data isn't ready, nothing to indicate
> +	 * If both the el and s0 rx flags are set, we have hit the marked
> +	 * buffer but we don't know if hardware has seen it so we check
> +	 * the status.
> +	 * If only the s0 flag is set, we check the next buffer.
> +	 * If it is complete, we know that hardware saw the rfd el bit
> +	 * get cleared but did not see the rfd size get set so it
> +	 * skipped this buffer.  We just return 0 and look at the
> +	 * next buffer.
> +	 * If only the s0 flag is set but the next buffer is
> +	 * not complete, we cleared the el flag as hardware
> +	 * hit this buffer. */
> +	if(unlikely(!(rfd_status & cb_complete))) {
> +		u8 maskedFlags = rx->flags & (rx_el | rx_s0);
> +		if(maskedFlags == (rx_el | rx_s0)) {
> +			status = ioread8(&nic->csr->scb.status);
> +			if(status & rus_no_res) {
> +				nic->ru_running = ru_suspended;
> +			}
> +		} else if(maskedFlags == rx_s0) {
> +			struct rx *next_rx = rx->next;
> +			struct rfd *next_rfd = (struct rfd *)next_rx->skb->data;
> +			pci_dma_sync_single_for_cpu(nic->pdev, next_rx->dma_addr,
> +				sizeof(struct rfd), PCI_DMA_FROMDEVICE);
> +			if(next_rfd->status & cpu_to_le16(cb_complete)) {
> +				pci_unmap_single(nic->pdev, rx->dma_addr,
> +					RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
> +				dev_kfree_skb_any(skb);
> +				rx->skb = NULL;
> +				rx->flags &= ~rx_s0;
> +				return 0;
> +			} else {
> +				status = ioread8(&nic->csr->scb.status);
> +				if(status & rus_no_res) {
> +					nic->ru_running = ru_suspended;
> +				}
> +			}
> +		}
>  		return -ENODATA;
> +	}
>
>  	/* Get actual data size */
>  	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
> @@ -1813,6 +1907,15 @@ static int e100_rx_indicate(struct nic *
>  	pci_unmap_single(nic->pdev, rx->dma_addr,
>  		RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
>
> +	/* This happens when hardward sees the rfd el flag set
> +	 * but then sees the rfd size set as well */
> +	if(le16_to_cpu(rfd->command) & cb_el) {

The racing read of the dma device might see it, but our cpu will never 
see this since it wrote them in the other order.

how about if rx-flags & s0 ?
Also see my comments about ru_unknown.

Where do you clear s0 when we encounter a packet with rfd status 
complete?

Maybe we should just set flags to 0 when allocating the skb?

> +		status = ioread8(&nic->csr->scb.status);
> +		if(status & rus_no_res) {
> +			nic->ru_running = ru_suspended;
> +		}
> +	}
> +
>  	/* Pull off the RFD and put the actual data (minus eth hdr) */
>  	skb_reserve(skb, sizeof(struct rfd));
>  	skb_put(skb, actual_size);
> @@ -1842,19 +1945,46 @@ static int e100_rx_indicate(struct nic *
>  static void e100_rx_clean(struct nic *nic, unsigned int *work_done,
>  	unsigned int work_to_do)
>  {
> -	struct rx *rx;
> +	struct rx *rx, *marked_rx;
> +	int restart_required = 0;
> +	int err = 0;
>
>  	/* Indicate newly arrived packets */
>  	for(rx = nic->rx_to_clean; rx->skb; rx = nic->rx_to_clean = 
> rx->next) {
> -		if(e100_rx_indicate(nic, rx, work_done, work_to_do))
> -			break; /* No more to clean */
> +		err = e100_rx_indicate(nic, rx, work_done, work_to_do);
> +		/* Hit quota or no more to clean */
> +		if(-EAGAIN == err || -ENODATA == err)
> +			break;
>  	}

My ru_state of maybe_running would cause us to read the status and 
resolve it to either running or suspended here (after the clean loop).
>
> +	/* On EAGAIN, hit quota so have more work to do, restart once
> +	 * cleanup is complete.
> +	 * Else, are we already rnr? then pay attention!!! this ensures that
> +	 * the state machine progression never allows a start with a
> +	 * partially cleaned list, avoiding a race between hardware
> +	 * and rx_to_clean when in NAPI mode */

It took me a long while to figure out what race you are referring to 
here.   At first I thought you were just moving a comment.  I am 
totally lost by "are we already rnr? then pay attention!!!".

This isn't a race, its more like "We don't restart the receiver when we 
stop processing due to NAPI quota because we don't yet know which rfd 
is the first that already contains data.  That is, rx_to_clean points 
to something that might be a used rfd instead of a known clean one."



> +	if(-EAGAIN != err && ru_suspended == nic->ru_running)
> +		restart_required = 1;
> +
> +	marked_rx = nic->rx_to_use->prev->prev;
> +	while(!(marked_rx->flags & rx_el))
> +		marked_rx = marked_rx->prev;
> +

Not while.  This should be if, followed by BUG_ON(!marked_rx->flags & 
rx_el).   We can remove the BUG_ON later, but it points to an error in 
our logic if its not one of the two places.

>  	/* Alloc new skbs to refill list */
>  	for(rx = nic->rx_to_use; !rx->skb; rx = nic->rx_to_use = rx->next) {
>  		if(unlikely(e100_rx_alloc_skb(nic, rx)))
>  			break; /* Better luck next time (see watchdog) */
>  	}
> +
> +	e100_find_mark_el(nic, marked_rx, !restart_required);
>

We could pass the true ru_status based value here, but since we won't 
be restoring the receiver it doesn't matter.

> +
> +	if(restart_required) {
> +		// ack the rnr?
> +		iowrite8(stat_ack_rnr, &nic->csr->scb.stat_ack);
> +		e100_start_receiver(nic, nic->rx_to_clean);
> +		if(work_done)
> +			(*work_done)++;
>

Why is restarting the receiver work?   Actually receiving the packet is 
work.

> +	}
>  }
>
>  static void e100_rx_clean_list(struct nic *nic)
> @@ -1862,6 +1992,8 @@ static void e100_rx_clean_list(struct ni
>  	struct rx *rx;
>  	unsigned int i, count = nic->params.rfds.count;
>
> +	nic->ru_running = ru_uninitialized;
> +
>  	if(nic->rxs) {
>  		for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
>  			if(rx->skb) {
> @@ -1883,6 +2015,7 @@ static int e100_rx_alloc_list(struct nic
>  	unsigned int i, count = nic->params.rfds.count;
>
>  	nic->rx_to_use = nic->rx_to_clean = NULL;
> +	nic->ru_running = ru_uninitialized;

Here is the short duration of uninitialized, and its not the 0 case.
>
>  	if(!(nic->rxs = kcalloc(count, sizeof(struct rx), GFP_ATOMIC)))
>  		return -ENOMEM;
> @@ -1897,6 +2030,9 @@ static int e100_rx_alloc_list(struct nic
>  	}
>
>  	nic->rx_to_use = nic->rx_to_clean = nic->rxs;
> +	nic->ru_running = ru_suspended;
> +
> +	e100_find_mark_el(nic, NULL, 0);
>
>  	return 0;
>  }
> @@ -1916,6 +2052,10 @@ static irqreturn_t e100_intr(int irq, vo
>  	/* Ack interrupt(s) */
>  	iowrite8(stat_ack, &nic->csr->scb.stat_ack);
>
> +	/* We hit Receive No Resource (RNR); restart RU after cleaning */
> +	if(stat_ack & stat_ack_rnr)
> +		nic->ru_running = ru_suspended;
> +
>  	if(likely(netif_rx_schedule_prep(netdev))) {
>  		e100_disable_irq(nic);
>  		__netif_rx_schedule(netdev);
> @@ -2007,7 +2147,7 @@ static int e100_up(struct nic *nic)
>  	if((err = e100_hw_init(nic)))
>  		goto err_clean_cbs;
>  	e100_set_multicast_list(nic->netdev);
> -	e100_start_receiver(nic);
> +	e100_start_receiver(nic, NULL);

(remove second arg to start_receiver, this diff will go away).

>  	mod_timer(&nic->watchdog, jiffies);
>  	if((err = request_irq(nic->pdev->irq, e100_intr, IRQF_SHARED,
>  		nic->netdev->name, nic->netdev)))
> @@ -2088,7 +2228,7 @@ static int e100_loopback_test(struct nic
>  		mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR,
>  			BMCR_LOOPBACK);
>
> -	e100_start_receiver(nic);
> +	e100_start_receiver(nic, NULL);
>
(and this one).

>  	if(!(skb = netdev_alloc_skb(nic->netdev, ETH_DATA_LEN))) {
>  		err = -ENOMEM;
>
>

Thanks for doing the work David.

milton


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
