From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH v2 2/2] e1000: bundle xdp xmit routines
Date: Mon, 12 Sep 2016 14:17:55 +0200
Message-ID: <20160912141755.365c169e@redhat.com>
References: <20160909212915.4001.25504.stgit@john-Precision-Tower-5810>
        <20160909212938.4001.40540.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bblanco@plumgrid.com, alexei.starovoitov@gmail.com,
        jeffrey.t.kirsher@intel.com, davem@davemloft.net,
        xiyou.wangcong@gmail.com, intel-wired-lan@lists.osuosl.org,
        u9012063@gmail.com, netdev@vger.kernel.org, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59854 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757403AbcILMS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 08:18:26 -0400
In-Reply-To: <20160909212938.4001.40540.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 09 Sep 2016 14:29:38 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> e1000 supports a single TX queue so it is being shared with the stack
> when XDP runs XDP_TX action. This requires taking the xmit lock to
> ensure we don't corrupt the tx ring. To avoid taking and dropping the
> lock per packet this patch adds a bundling implementation to submit
> a bundle of packets to the xmit routine.
> 
> I tested this patch running e1000 in a VM using KVM over a tap
> device using pktgen to generate traffic along with 'ping -f -l 100'.
> 
> Suggested-by: Jesper Dangaard Brouer <brouer@redhat.com>

Thank you for actually implementing this! :-)

> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
[...]
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 91d5c87..b985271 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
>  
[...]
> @@ -3369,33 +3381,52 @@ static void e1000_tx_map_rxpage(struct e1000_tx_ring *tx_ring,
>  }
>  
>  static void e1000_xmit_raw_frame(struct e1000_rx_buffer *rx_buffer_info,
> -				 unsigned int len,
> -				 struct net_device *netdev,
> -				 struct e1000_adapter *adapter)
> +				 __u32 len,
> +				 struct e1000_adapter *adapter,
> +				 struct e1000_tx_ring *tx_ring)
>  {
> -	struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
> -	struct e1000_hw *hw = &adapter->hw;
> -	struct e1000_tx_ring *tx_ring;
> -
>  	if (len > E1000_MAX_DATA_PER_TXD)
>  		return;
>  
> +	if (E1000_DESC_UNUSED(tx_ring) < 2)
> +		return;
> +
> +	e1000_tx_map_rxpage(tx_ring, rx_buffer_info, len);
> +	e1000_tx_queue(adapter, tx_ring, 0/*tx_flags*/, 1);
> +}
> +
> +static void e1000_xdp_xmit_bundle(struct e1000_rx_buffer_bundle *buffer_info,
> +				  struct net_device *netdev,
> +				  struct e1000_adapter *adapter)
> +{
> +	struct netdev_queue *txq = netdev_get_tx_queue(netdev, 0);
> +	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
> +	struct e1000_hw *hw = &adapter->hw;
> +	int i = 0;
> +
>  	/* e1000 only support a single txq at the moment so the queue is being
>  	 * shared with stack. To support this requires locking to ensure the
>  	 * stack and XDP are not running at the same time. Devices with
>  	 * multiple queues should allocate a separate queue space.
> +	 *
> +	 * To amortize the locking cost e1000 bundles the xmits and sends as
> +	 * many as possible until either running out of descriptors or failing.
>  	 */
>  	HARD_TX_LOCK(netdev, txq, smp_processor_id());
>  
> -	tx_ring = adapter->tx_ring;
> -
> -	if (E1000_DESC_UNUSED(tx_ring) < 2) {
> -		HARD_TX_UNLOCK(netdev, txq);
> -		return;
> +	for (; i < E1000_XDP_XMIT_BUNDLE_MAX && buffer_info[i].buffer; i++) {
                                                                       ^^^
> +		e1000_xmit_raw_frame(buffer_info[i].buffer,
> +				     buffer_info[i].length,
> +				     adapter, tx_ring);
> +		buffer_info[i].buffer->rxbuf.page = NULL;
> +		buffer_info[i].buffer = NULL;
> +		buffer_info[i].length = 0;
> +		i++;
                ^^^
Looks like "i" is incremented twice, is that correct?

>  	}
>  
> -	e1000_tx_map_rxpage(tx_ring, rx_buffer_info, len);
> -	e1000_tx_queue(adapter, tx_ring, 0/*tx_flags*/, 1);
> +	/* kick hardware to send bundle and return control back to the stack */
> +	writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
> +	mmiowb();
>  
>  	writel(tx_ring->next_to_use, hw->hw_addr + tx_ring->tdt);
>  	mmiowb();
> @@ -4281,9 +4312,10 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
>  	struct bpf_prog *prog;
>  	u32 length;
>  	unsigned int i;
> -	int cleaned_count = 0;
> +	int cleaned_count = 0, xdp_xmit = 0;
>  	bool cleaned = false;
>  	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
> +	struct e1000_rx_buffer_bundle *xdp_bundle = rx_ring->xdp_buffer;
>  
>  	rcu_read_lock(); /* rcu lock needed here to protect xdp programs */
>  	prog = READ_ONCE(adapter->prog);
> @@ -4338,13 +4370,13 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
>  			case XDP_PASS:
>  				break;
>  			case XDP_TX:
> +				xdp_bundle[xdp_xmit].buffer = buffer_info;
> +				xdp_bundle[xdp_xmit].length = length;
>  				dma_sync_single_for_device(&pdev->dev,
>  							   dma,
>  							   length,
>  							   DMA_TO_DEVICE);
> -				e1000_xmit_raw_frame(buffer_info, length,
> -						     netdev, adapter);
> -				buffer_info->rxbuf.page = NULL;
> +				xdp_xmit++;
>  			case XDP_DROP:
>  			default:
>  				/* re-use mapped page. keep buffer_info->dma

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
