From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC Patch 08/12] IXGBEVF: Rework code of finding the end
 transmit desc of package
Date: Wed, 21 Oct 2015 14:14:56 -0700
Message-ID: <56280050.9020301@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
 <1445445464-5056-9-git-send-email-tianyu.lan@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lan Tianyu <tianyu.lan@intel.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1445445464-5056-9-git-send-email-tianyu.lan@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2015 09:37 AM, Lan Tianyu wrote:
> When transmit a package, the end transmit desc of package
> indicates whether package is sent already. Current code records
> the end desc's pointer in the next_to_watch of struct tx buffer.
> This code will be broken if shifting desc ring after migration.
> The pointer will be invalid. This patch is to replace recording
> pointer with recording the desc number of the package and find
> the end decs via the first desc and desc number.
>
> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
> ---
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  1 +
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 19 ++++++++++++++++---
>   2 files changed, 17 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> index 775d089..c823616 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> @@ -54,6 +54,7 @@
>    */
>   struct ixgbevf_tx_buffer {
>   	union ixgbe_adv_tx_desc *next_to_watch;
> +	u16 desc_num;
>   	unsigned long time_stamp;
>   	struct sk_buff *skb;
>   	unsigned int bytecount;

So if you can't use next_to_watch why is it left in here?  Also you 
might want to take a look at moving desc_num to a different spot in the 
buffer as you are leaving a 6 byte hole in the descriptor.

> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index 4446916..056841c 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -210,6 +210,7 @@ static void ixgbevf_unmap_and_free_tx_resource(struct ixgbevf_ring *tx_ring,
>   			       DMA_TO_DEVICE);
>   	}
>   	tx_buffer->next_to_watch = NULL;
> +	tx_buffer->desc_num = 0;
>   	tx_buffer->skb = NULL;
>   	dma_unmap_len_set(tx_buffer, len, 0);

This opens up a race condition.  If you have a descriptor ready to be 
cleaned at offset 0 what is to prevent you from just running through the 
ring?  You likely need to find a descriptor number that cannot be valid 
to use here.

>   	/* tx_buffer must be completely set up in the transmit path */
> @@ -295,7 +296,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
>   	union ixgbe_adv_tx_desc *tx_desc;
>   	unsigned int total_bytes = 0, total_packets = 0;
>   	unsigned int budget = tx_ring->count / 2;
> -	unsigned int i = tx_ring->next_to_clean;
> +	int i, watch_index;
>   

Where is i being initialized?  It was here but you removed it.  Are you 
using i without initializing it?

>   	if (test_bit(__IXGBEVF_DOWN, &adapter->state))
>   		return true;
> @@ -305,9 +306,17 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
>   	i -= tx_ring->count;
>   
>   	do {
> -		union ixgbe_adv_tx_desc *eop_desc = tx_buffer->next_to_watch;
> +		union ixgbe_adv_tx_desc *eop_desc;
> +
> +		if (!tx_buffer->desc_num)
> +			break;
> +
> +		if (i + tx_buffer->desc_num >= 0)
> +			watch_index = i + tx_buffer->desc_num;
> +		else
> +			watch_index = i + tx_ring->count + tx_buffer->desc_num;
>   
> -		/* if next_to_watch is not set then there is no work pending */
> +		eop_desc = IXGBEVF_TX_DESC(tx_ring, watch_index);
>   		if (!eop_desc)
>   			break;
>   

So I don't see how this isn't triggering Tx hangs.  I suspect for the 
simple ping case desc_num will often be 0.  The fact is there are many 
cases where first and tx_buffer_info are the same descriptor.

> @@ -320,6 +329,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
>   
>   		/* clear next_to_watch to prevent false hangs */
>   		tx_buffer->next_to_watch = NULL;
> +		tx_buffer->desc_num = 0;
>   
>   		/* update the statistics for this packet */
>   		total_bytes += tx_buffer->bytecount;

You cannot use 0 because 0 is a valid number.  You are using it as a 
look-ahead currently and there are cases where i is the eop_desc index.

> @@ -3457,6 +3467,7 @@ static void ixgbevf_tx_map(struct ixgbevf_ring *tx_ring,
>   	u32 tx_flags = first->tx_flags;
>   	__le32 cmd_type;
>   	u16 i = tx_ring->next_to_use;
> +	u16 start;
>   
>   	tx_desc = IXGBEVF_TX_DESC(tx_ring, i);
>   
> @@ -3540,6 +3551,8 @@ static void ixgbevf_tx_map(struct ixgbevf_ring *tx_ring,
>   
>   	/* set next_to_watch value indicating a packet is present */
>   	first->next_to_watch = tx_desc;
> +	start = first - tx_ring->tx_buffer_info;
> +	first->desc_num = (i - start >= 0) ? i - start: i + tx_ring->count - start;
>   
>   	i++;
>   	if (i == tx_ring->count)

start and i could be the same value.  If you look at ixgbevf_tx_map you 
should find that if the packet is contained in a single buffer then the 
first and last descriptor in your send will be the same one.
