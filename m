From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC Patch 12/12] IXGBEVF: Track dma dirty pages
Date: Thu, 22 Oct 2015 15:30:46 +0300
Message-ID: <20151022150137-mutt-send-email-mst@redhat.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
 <1445445464-5056-13-git-send-email-tianyu.lan@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhelgaas@google.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, eddie.dong@intel.com,
	nrupal.jani@intel.com, yang.z.zhang@intel.com, agraf@suse.de,
	kvm@vger.kernel.org, pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
To: Lan Tianyu <tianyu.lan@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445445464-5056-13-git-send-email-tianyu.lan@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 12:37:44AM +0800, Lan Tianyu wrote:
> Migration relies on tracking dirty page to migrate memory.
> Hardware can't automatically mark a page as dirty after DMA
> memory access. VF descriptor rings and data buffers are modified
> by hardware when receive and transmit data. To track such dirty memory
> manually, do dummy writes(read a byte and write it back) during receive
> and transmit data.
> 
> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 14 +++++++++++---
>  1 file changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index d22160f..ce7bd7a 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -414,6 +414,9 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
>  		if (!(eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)))
>  			break;
>  
> +		/* write back status to mark page dirty */

Which page? the descriptor ring?  What does marking it dirty accomplish
though, given that we might migrate right before this happens?

It might be a good idea to just specify addresses of rings
to hypervisor, and have it send the ring pages after VM
and the VF are stopped.


> +		eop_desc->wb.status = eop_desc->wb.status;
> +
Compiler is likely to optimize this out.
You also probably need a wmb here ...

>  		/* clear next_to_watch to prevent false hangs */
>  		tx_buffer->next_to_watch = NULL;
>  		tx_buffer->desc_num = 0;
> @@ -946,15 +949,17 @@ static struct sk_buff *ixgbevf_fetch_rx_buffer(struct ixgbevf_ring *rx_ring,
>  {
>  	struct ixgbevf_rx_buffer *rx_buffer;
>  	struct page *page;
> +	u8 *page_addr;
>  
>  	rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
>  	page = rx_buffer->page;
>  	prefetchw(page);
>  
> -	if (likely(!skb)) {
> -		void *page_addr = page_address(page) +
> -				  rx_buffer->page_offset;
> +	/* Mark page dirty */

Looks like there's a race condition here: VM could
migrate at this point. RX ring will indicate
packet has been received, but page data would be stale.


One solution I see is explicitly testing for this
condition and discarding the packet.
For example, hypervisor could increment some counter
in RAM during migration.

Then:

	x = read counter

	get packet from rx ring
	mark page dirty

	y = read counter

	if (x != y)
		discard packet


> +	page_addr = page_address(page) + rx_buffer->page_offset;
> +	*page_addr = *page_addr;

Compiler is likely to optimize this out.
You also probably need a wmb here ...


>  
> +	if (likely(!skb)) {
>  		/* prefetch first cache line of first page */
>  		prefetch(page_addr);

prefetch makes no sense if you read it right here.

>  #if L1_CACHE_BYTES < 128
> @@ -1032,6 +1037,9 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
>  		if (!ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_DD))
>  			break;
>  
> +		/* Write back status to mark page dirty */
> +		rx_desc->wb.upper.status_error = rx_desc->wb.upper.status_error;
> +

same question as for tx.

>  		/* This memory barrier is needed to keep us from reading
>  		 * any other fields out of the rx_desc until we know the
>  		 * RXD_STAT_DD bit is set
> -- 
> 1.8.4.rc0.1.g8f6a3e5.dirty
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
