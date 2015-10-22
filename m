From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC Patch 10/12] IXGBEVF: Add lock to protect tx/rx ring
 operation
Date: Thu, 22 Oct 2015 15:40:27 +0300
Message-ID: <20151022153756-mutt-send-email-mst@redhat.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
 <1445445464-5056-11-git-send-email-tianyu.lan@intel.com>
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
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445445464-5056-11-git-send-email-tianyu.lan@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 12:37:42AM +0800, Lan Tianyu wrote:
> Ring shifting during restoring VF function maybe race with original
> ring operation(transmit/receive package). This patch is to add tx/rx
> lock to protect ring related data.
> 
> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>

That's adding a bunch of locking on data path - what's the
performance impact?

Can't you do something faster? E.g. migration things
are slow path - can't you use something like RCU
to flush outstanding work?


> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  2 ++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 28 ++++++++++++++++++++---
>  2 files changed, 27 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> index 6eab402e..3a748c8 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> @@ -448,6 +448,8 @@ struct ixgbevf_adapter {
>  
>  	spinlock_t mbx_lock;
>  	unsigned long last_reset;
> +	spinlock_t mg_rx_lock;
> +	spinlock_t mg_tx_lock;
>  };
>  
>  enum ixbgevf_state_t {
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index 15ec361..04b6ce7 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -227,8 +227,10 @@ static u64 ixgbevf_get_tx_completed(struct ixgbevf_ring *ring)
>  
>  int ixgbevf_tx_ring_shift(struct ixgbevf_ring *r, u32 head)
>  {
> +	struct ixgbevf_adapter *adapter = netdev_priv(r->netdev);
>  	struct ixgbevf_tx_buffer *tx_buffer = NULL;
>  	static union ixgbevf_desc *tx_desc = NULL;
> +	unsigned long flags;
>  
>  	tx_buffer = vmalloc(sizeof(struct ixgbevf_tx_buffer) * (r->count));
>  	if (!tx_buffer)
> @@ -238,6 +240,7 @@ int ixgbevf_tx_ring_shift(struct ixgbevf_ring *r, u32 head)
>  	if (!tx_desc)
>  		return -ENOMEM;
>  
> +	spin_lock_irqsave(&adapter->mg_tx_lock, flags);
>  	memcpy(tx_desc, r->desc, sizeof(union ixgbevf_desc) * r->count);
>  	memcpy(r->desc, &tx_desc[head], sizeof(union ixgbevf_desc) * (r->count - head));
>  	memcpy(&r->desc[r->count - head], tx_desc, sizeof(union ixgbevf_desc) * head);
> @@ -256,6 +259,8 @@ int ixgbevf_tx_ring_shift(struct ixgbevf_ring *r, u32 head)
>  	else
>  		r->next_to_use += (r->count - head);
>  
> +	spin_unlock_irqrestore(&adapter->mg_tx_lock, flags);
> +
>  	vfree(tx_buffer);
>  	vfree(tx_desc);
>  	return 0;
> @@ -263,8 +268,10 @@ int ixgbevf_tx_ring_shift(struct ixgbevf_ring *r, u32 head)
>  
>  int ixgbevf_rx_ring_shift(struct ixgbevf_ring *r, u32 head)
>  {
> +	struct ixgbevf_adapter *adapter = netdev_priv(r->netdev);
>  	struct ixgbevf_rx_buffer *rx_buffer = NULL;
>  	static union ixgbevf_desc *rx_desc = NULL;
> +	unsigned long flags;	
>  
>  	rx_buffer = vmalloc(sizeof(struct ixgbevf_rx_buffer) * (r->count));
>  	if (!rx_buffer)
> @@ -274,6 +281,7 @@ int ixgbevf_rx_ring_shift(struct ixgbevf_ring *r, u32 head)
>  	if (!rx_desc)
>  		return -ENOMEM;
>  
> +	spin_lock_irqsave(&adapter->mg_rx_lock, flags);
>  	memcpy(rx_desc, r->desc, sizeof(union ixgbevf_desc) * (r->count));
>  	memcpy(r->desc, &rx_desc[head], sizeof(union ixgbevf_desc) * (r->count - head));
>  	memcpy(&r->desc[r->count - head], rx_desc, sizeof(union ixgbevf_desc) * head);
> @@ -291,6 +299,7 @@ int ixgbevf_rx_ring_shift(struct ixgbevf_ring *r, u32 head)
>  		r->next_to_use -= head;
>  	else
>  		r->next_to_use += (r->count - head);
> +	spin_unlock_irqrestore(&adapter->mg_rx_lock, flags);
>  
>  	vfree(rx_buffer);
>  	vfree(rx_desc);
> @@ -377,6 +386,8 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
>  	if (test_bit(__IXGBEVF_DOWN, &adapter->state))
>  		return true;
>  
> +	spin_lock(&adapter->mg_tx_lock);
> +	i = tx_ring->next_to_clean;
>  	tx_buffer = &tx_ring->tx_buffer_info[i];
>  	tx_desc = IXGBEVF_TX_DESC(tx_ring, i);
>  	i -= tx_ring->count;
> @@ -471,6 +482,8 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
>  	q_vector->tx.total_bytes += total_bytes;
>  	q_vector->tx.total_packets += total_packets;
>  
> +	spin_unlock(&adapter->mg_tx_lock);
> +
>  	if (check_for_tx_hang(tx_ring) && ixgbevf_check_tx_hang(tx_ring)) {
>  		struct ixgbe_hw *hw = &adapter->hw;
>  		union ixgbe_adv_tx_desc *eop_desc;
> @@ -999,10 +1012,12 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
>  				struct ixgbevf_ring *rx_ring,
>  				int budget)
>  {
> +	struct ixgbevf_adapter *adapter = netdev_priv(rx_ring->netdev);
>  	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
>  	u16 cleaned_count = ixgbevf_desc_unused(rx_ring);
>  	struct sk_buff *skb = rx_ring->skb;
>  
> +	spin_lock(&adapter->mg_rx_lock);
>  	while (likely(total_rx_packets < budget)) {
>  		union ixgbe_adv_rx_desc *rx_desc;
>  
> @@ -1078,6 +1093,7 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
>  	q_vector->rx.total_packets += total_rx_packets;
>  	q_vector->rx.total_bytes += total_rx_bytes;
>  
> +	spin_unlock(&adapter->mg_rx_lock);
>  	return total_rx_packets;
>  }
>  
> @@ -3572,14 +3588,17 @@ static void ixgbevf_tx_map(struct ixgbevf_ring *tx_ring,
>  	struct ixgbevf_tx_buffer *tx_buffer;
>  	union ixgbe_adv_tx_desc *tx_desc;
>  	struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
> +	struct ixgbevf_adapter *adapter = netdev_priv(tx_ring->netdev);
>  	unsigned int data_len = skb->data_len;
>  	unsigned int size = skb_headlen(skb);
>  	unsigned int paylen = skb->len - hdr_len;
> +	unsigned long flags;
>  	u32 tx_flags = first->tx_flags;
>  	__le32 cmd_type;
> -	u16 i = tx_ring->next_to_use;
> -	u16 start;
> +	u16 i, start;     
>  
> +	spin_lock_irqsave(&adapter->mg_tx_lock, flags);
> +	i = tx_ring->next_to_use;
>  	tx_desc = IXGBEVF_TX_DESC(tx_ring, i);
>  
>  	ixgbevf_tx_olinfo_status(tx_desc, tx_flags, paylen);
> @@ -3673,7 +3692,7 @@ static void ixgbevf_tx_map(struct ixgbevf_ring *tx_ring,
>  
>  	/* notify HW of packet */
>  	ixgbevf_write_tail(tx_ring, i);
> -
> +	spin_unlock_irqrestore(&adapter->mg_tx_lock, flags);
>  	return;
>  dma_error:
>  	dev_err(tx_ring->dev, "TX DMA map failed\n");
> @@ -3690,6 +3709,7 @@ dma_error:
>  	}
>  
>  	tx_ring->next_to_use = i;
> +	spin_unlock_irqrestore(&adapter->mg_tx_lock, flags);
>  }
>  
>  static int __ixgbevf_maybe_stop_tx(struct ixgbevf_ring *tx_ring, int size)
> @@ -4188,6 +4208,8 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  		break;
>  	}
>  
> +	spin_lock_init(&adapter->mg_tx_lock);
> +	spin_lock_init(&adapter->mg_rx_lock);
>  	return 0;
>  
>  err_register:
> -- 
> 1.8.4.rc0.1.g8f6a3e5.dirty
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
