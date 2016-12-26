From: maowenan <maowenan@huawei.com>
Subject: RE: [RFC PATCH] i40e: enable PCIe relax ordering for SPARC
Date: Mon, 26 Dec 2016 11:39:23 +0000
Message-ID: <F95AC9340317A84688A5F0DF0246F3F2015209E7@szxeml504-mbs.china.huawei.com>
References: <1480957627-16825-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Dingtianhong <dingtianhong@huawei.com>
To: Tushar Dave <tushar.n.dave@oracle.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:27150 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751252AbcLZLkZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 06:40:25 -0500
In-Reply-To: <1480957627-16825-1-git-send-email-tushar.n.dave@oracle.com>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Tushar Dave
> Sent: Tuesday, December 06, 2016 1:07 AM
> To: jeffrey.t.kirsher@intel.com; intel-wired-lan@lists.osuosl.org
> Cc: netdev@vger.kernel.org
> Subject: [RFC PATCH] i40e: enable PCIe relax ordering for SPARC
> 
> Unlike previous generation NIC (e.g. ixgbe) i40e doesn't seem to have standard
> CSR where PCIe relaxed ordering can be set. Without PCIe relax ordering
> enabled, i40e performance is significantly low on SPARC.
> 
[Mao Wenan]Hi Tushar, you have referred to i40e doesn't seem to have standard CSR
to set PCIe relaxed ordering, this CSR like TX&Rx DCA Control Register in 82599, right?
Is DMA_ATTR_WEAK_ORDERING the same as TX&RX control register in 82599?  

And to enable relax ordering mode in 82599 for SPARC using below codes:
s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
{
	u32 i;

	/* Clear the rate limiters */
	for (i = 0; i < hw->mac.max_tx_queues; i++) {
		IXGBE_WRITE_REG(hw, IXGBE_RTTDQSEL, i);
		IXGBE_WRITE_REG(hw, IXGBE_RTTBCNRC, 0);
	}
	IXGBE_WRITE_FLUSH(hw);

#ifndef CONFIG_SPARC
	/* Disable relaxed ordering */
	for (i = 0; i < hw->mac.max_tx_queues; i++) {
		u32 regval;

		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(i));
		regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(i), regval);
	}

	for (i = 0; i < hw->mac.max_rx_queues; i++) {
		u32 regval;

		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
		regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
			    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
	}
#endif
	return 0;
}



> This patch sets PCIe relax ordering for SPARC arch by setting dma attr
> DMA_ATTR_WEAK_ORDERING for every tx and rx DMA map/unmap.
> This has shown 10x increase in performance numbers.
> 
> e.g.
> iperf TCP test with 10 threads on SPARC S7
> 
> Test 1: Without this patch
> 
> [root@brm-snt1-03 net]# iperf -s
> ------------------------------------------------------------
> Server listening on TCP port 5001
> TCP window size: 85.3 KByte (default)
> ------------------------------------------------------------
> [  4] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40926 [  5] local
> 16.0.0.7 port 5001 connected with 16.0.0.1 port 40934 [  6] local 16.0.0.7 port
> 5001 connected with 16.0.0.1 port 40930 [  7] local 16.0.0.7 port 5001
> connected with 16.0.0.1 port 40928 [  8] local 16.0.0.7 port 5001 connected
> with 16.0.0.1 port 40922 [  9] local 16.0.0.7 port 5001 connected with 16.0.0.1
> port 40932 [ 10] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40920
> [ 11] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 40924 [ 14] local
> 16.0.0.7 port 5001 connected with 16.0.0.1 port 40982 [ 12] local 16.0.0.7 port
> 5001 connected with 16.0.0.1 port 40980
> [ ID] Interval       Transfer     Bandwidth
> [  4]  0.0-20.0 sec   566 MBytes   237 Mbits/sec
> [  5]  0.0-20.0 sec   532 MBytes   223 Mbits/sec
> [  6]  0.0-20.0 sec   537 MBytes   225 Mbits/sec
> [  8]  0.0-20.0 sec   546 MBytes   229 Mbits/sec
> [ 11]  0.0-20.0 sec   592 MBytes   248 Mbits/sec
> [  7]  0.0-20.0 sec   539 MBytes   226 Mbits/sec
> [  9]  0.0-20.0 sec   572 MBytes   240 Mbits/sec
> [ 10]  0.0-20.0 sec   604 MBytes   253 Mbits/sec
> [ 14]  0.0-20.0 sec   567 MBytes   238 Mbits/sec
> [ 12]  0.0-20.0 sec   511 MBytes   214 Mbits/sec
> [SUM]  0.0-20.0 sec  5.44 GBytes  2.33 Gbits/sec
> 
> Test 2: with this patch:
> 
> [root@brm-snt1-03 net]# iperf -s
> ------------------------------------------------------------
> Server listening on TCP port 5001
> TCP window size: 85.3 KByte (default)
> ------------------------------------------------------------
> TCP: request_sock_TCP: Possible SYN flooding on port 5001. Sending cookies.
> Check SNMP counters.
> [  4] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46876 [  5] local
> 16.0.0.7 port 5001 connected with 16.0.0.1 port 46874 [  6] local 16.0.0.7 port
> 5001 connected with 16.0.0.1 port 46872 [  7] local 16.0.0.7 port 5001
> connected with 16.0.0.1 port 46880 [  8] local 16.0.0.7 port 5001 connected
> with 16.0.0.1 port 46878 [  9] local 16.0.0.7 port 5001 connected with 16.0.0.1
> port 46884 [ 10] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46886
> [ 11] local 16.0.0.7 port 5001 connected with 16.0.0.1 port 46890 [ 12] local
> 16.0.0.7 port 5001 connected with 16.0.0.1 port 46888 [ 13] local 16.0.0.7 port
> 5001 connected with 16.0.0.1 port 46882
> [ ID] Interval       Transfer     Bandwidth
> [  4]  0.0-20.0 sec  7.45 GBytes  3.19 Gbits/sec [  5]  0.0-20.0 sec  7.48
> GBytes  3.21 Gbits/sec [  7]  0.0-20.0 sec  7.34 GBytes  3.15 Gbits/sec
> [  8]  0.0-20.0 sec  7.42 GBytes  3.18 Gbits/sec [  9]  0.0-20.0 sec  7.24
> GBytes  3.11 Gbits/sec [ 10]  0.0-20.0 sec  7.40 GBytes  3.17 Gbits/sec
> [ 12]  0.0-20.0 sec  7.49 GBytes  3.21 Gbits/sec [  6]  0.0-20.0 sec  7.30
> GBytes  3.13 Gbits/sec [ 11]  0.0-20.0 sec  7.44 GBytes  3.19 Gbits/sec
> [ 13]  0.0-20.0 sec  7.22 GBytes  3.10 Gbits/sec [SUM]  0.0-20.0 sec  73.8
> GBytes  31.6 Gbits/sec
> 
> NOTE: In my testing, this patch does _not_ show any harm to i40e performance
> numbers on x86.
> 
> Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 69
> ++++++++++++++++++++---------  drivers/net/ethernet/intel/i40e/i40e_txrx.h |
> 1 +
>  2 files changed, 49 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index 6287bf6..800dca7 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -551,15 +551,17 @@ static void
> i40e_unmap_and_free_tx_resource(struct i40e_ring *ring,
>  		else
>  			dev_kfree_skb_any(tx_buffer->skb);
>  		if (dma_unmap_len(tx_buffer, len))
> -			dma_unmap_single(ring->dev,
> -					 dma_unmap_addr(tx_buffer, dma),
> -					 dma_unmap_len(tx_buffer, len),
> -					 DMA_TO_DEVICE);
> +			dma_unmap_single_attrs(ring->dev,
> +					       dma_unmap_addr(tx_buffer, dma),
> +					       dma_unmap_len(tx_buffer, len),
> +					       DMA_TO_DEVICE,
> +					       ring->dma_attrs);
>  	} else if (dma_unmap_len(tx_buffer, len)) {
> -		dma_unmap_page(ring->dev,
> -			       dma_unmap_addr(tx_buffer, dma),
> -			       dma_unmap_len(tx_buffer, len),
> -			       DMA_TO_DEVICE);
> +		dma_unmap_single_attrs(ring->dev,
> +				       dma_unmap_addr(tx_buffer, dma),
> +				       dma_unmap_len(tx_buffer, len),
> +				       DMA_TO_DEVICE,
> +				       ring->dma_attrs);
>  	}
> 
>  	tx_buffer->next_to_watch = NULL;
> @@ -662,6 +664,8 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
>  	struct i40e_tx_buffer *tx_buf;
>  	struct i40e_tx_desc *tx_head;
>  	struct i40e_tx_desc *tx_desc;
> +	dma_addr_t addr;
> +	size_t size;
>  	unsigned int total_bytes = 0, total_packets = 0;
>  	unsigned int budget = vsi->work_limit;
> 
> @@ -696,10 +700,11 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
>  		napi_consume_skb(tx_buf->skb, napi_budget);
> 
>  		/* unmap skb header data */
> -		dma_unmap_single(tx_ring->dev,
> -				 dma_unmap_addr(tx_buf, dma),
> -				 dma_unmap_len(tx_buf, len),
> -				 DMA_TO_DEVICE);
> +		dma_unmap_single_attrs(tx_ring->dev,
> +				       dma_unmap_addr(tx_buf, dma),
> +				       dma_unmap_len(tx_buf, len),
> +				       DMA_TO_DEVICE,
> +				       tx_ring->dma_attrs);
> 
>  		/* clear tx_buffer data */
>  		tx_buf->skb = NULL;
> @@ -717,12 +722,15 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
>  				tx_desc = I40E_TX_DESC(tx_ring, 0);
>  			}
> 
> +			addr = dma_unmap_addr(tx_buf, dma);
> +			size = dma_unmap_len(tx_buf, len);
>  			/* unmap any remaining paged data */
>  			if (dma_unmap_len(tx_buf, len)) {
> -				dma_unmap_page(tx_ring->dev,
> -					       dma_unmap_addr(tx_buf, dma),
> -					       dma_unmap_len(tx_buf, len),
> -					       DMA_TO_DEVICE);
> +				dma_unmap_single_attrs(tx_ring->dev,
> +						       addr,
> +						       size,
> +						       DMA_TO_DEVICE,
> +						       tx_ring->dma_attrs);
>  				dma_unmap_len_set(tx_buf, len, 0);
>  			}
>  		}
> @@ -1010,6 +1018,11 @@ int i40e_setup_tx_descriptors(struct i40e_ring
> *tx_ring)
>  	 */
>  	tx_ring->size += sizeof(u32);
>  	tx_ring->size = ALIGN(tx_ring->size, 4096);
> +#ifdef CONFIG_SPARC
> +	tx_ring->dma_attrs = DMA_ATTR_WEAK_ORDERING; #else
> +	tx_ring->dma_attrs = 0;
> +#endif
>  	tx_ring->desc = dma_alloc_coherent(dev, tx_ring->size,
>  					   &tx_ring->dma, GFP_KERNEL);
>  	if (!tx_ring->desc) {
> @@ -1053,7 +1066,11 @@ void i40e_clean_rx_ring(struct i40e_ring *rx_ring)
>  		if (!rx_bi->page)
>  			continue;
> 
> -		dma_unmap_page(dev, rx_bi->dma, PAGE_SIZE,
> DMA_FROM_DEVICE);
> +		dma_unmap_single_attrs(dev,
> +				       rx_bi->dma,
> +				       PAGE_SIZE,
> +				       DMA_FROM_DEVICE,
> +				       rx_ring->dma_attrs);
>  		__free_pages(rx_bi->page, 0);
> 
>  		rx_bi->page = NULL;
> @@ -1113,6 +1130,11 @@ int i40e_setup_rx_descriptors(struct i40e_ring
> *rx_ring)
>  	/* Round up to nearest 4K */
>  	rx_ring->size = rx_ring->count * sizeof(union i40e_32byte_rx_desc);
>  	rx_ring->size = ALIGN(rx_ring->size, 4096);
> +#ifdef CONFIG_SPARC
> +	rx_ring->dma_attrs = DMA_ATTR_WEAK_ORDERING; #else
> +	rx_ring->dma_attrs = 0;
> +#endif
>  	rx_ring->desc = dma_alloc_coherent(dev, rx_ring->size,
>  					   &rx_ring->dma, GFP_KERNEL);
> 
> @@ -1182,7 +1204,8 @@ static bool i40e_alloc_mapped_page(struct
> i40e_ring *rx_ring,
>  	}
> 
>  	/* map page for use */
> -	dma = dma_map_page(rx_ring->dev, page, 0, PAGE_SIZE,
> DMA_FROM_DEVICE);
> +	dma = dma_map_single_attrs(rx_ring->dev, page_address(page),
> PAGE_SIZE,
> +				   DMA_FROM_DEVICE, rx_ring->dma_attrs);
> 
>  	/* if mapping failed free memory back to system since
>  	 * there isn't much point in holding memory we can't use @@ -1695,8
> +1718,11 @@ struct sk_buff *i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
>  		rx_ring->rx_stats.page_reuse_count++;
>  	} else {
>  		/* we are not reusing the buffer so unmap it */
> -		dma_unmap_page(rx_ring->dev, rx_buffer->dma, PAGE_SIZE,
> -			       DMA_FROM_DEVICE);
> +		dma_unmap_single_attrs(rx_ring->dev,
> +				       rx_buffer->dma,
> +				       PAGE_SIZE,
> +				       DMA_FROM_DEVICE,
> +				       rx_ring->dma_attrs);
>  	}
> 
>  	/* clear contents of buffer_info */
> @@ -2737,7 +2763,8 @@ static inline void i40e_tx_map(struct i40e_ring
> *tx_ring, struct sk_buff *skb,
>  	first->skb = skb;
>  	first->tx_flags = tx_flags;
> 
> -	dma = dma_map_single(tx_ring->dev, skb->data, size, DMA_TO_DEVICE);
> +	dma = dma_map_single_attrs(tx_ring->dev, skb->data, size,
> +				   DMA_TO_DEVICE, tx_ring->dma_attrs);
> 
>  	tx_desc = I40E_TX_DESC(tx_ring, i);
>  	tx_bi = first;
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
> b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
> index 5088405..9a86212 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
> @@ -327,6 +327,7 @@ struct i40e_ring {
> 
>  	unsigned int size;		/* length of descriptor ring in bytes */
>  	dma_addr_t dma;			/* physical address of ring */
> +	unsigned long dma_attrs;	/* DMA attributes */
> 
>  	struct i40e_vsi *vsi;		/* Backreference to associated VSI */
>  	struct i40e_q_vector *q_vector;	/* Backreference to associated vector
> */
> --
> 1.9.1
