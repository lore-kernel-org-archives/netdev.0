From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/2] ixgbe: add support for XDP_TX action
Date: Mon, 24 Apr 2017 21:29:21 +0200
Message-ID: <20170424212921.36fdfff7@redhat.com>
References: <20170424013004.8354.34893.stgit@john-Precision-Tower-5810>
        <20170424013135.8354.93583.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, jeffrey.t.kirsher@intel.com,
        netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47034 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1174031AbdDXT31 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 15:29:27 -0400
In-Reply-To: <20170424013135.8354.93583.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Apr 2017 18:31:36 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> +static int ixgbe_xmit_xdp_ring(struct ixgbe_adapter *adapter,
> +			       struct xdp_buff *xdp)
> +{
> +	struct ixgbe_ring *ring = adapter->xdp_ring[smp_processor_id()];

I was about to question whether is it always true that the array size
can match the number of CPUs in the system, but I can see later in
ixgbe_xdp_setup() that you reject XDP program if the system have more
CPUs that MAX_XDP_QUEUES.

> +	struct ixgbe_tx_buffer *tx_buffer;
> +	union ixgbe_adv_tx_desc *tx_desc;
> +	u32 len, cmd_type;
> +	dma_addr_t dma;
> +	u16 i;
> +
> +	len = xdp->data_end - xdp->data;
> +
> +	if (unlikely(!ixgbe_desc_unused(ring)))
> +		return IXGBE_XDP_CONSUMED;
> +
> +	dma = dma_map_single(ring->dev, xdp->data, len, DMA_TO_DEVICE);
> +	if (dma_mapping_error(ring->dev, dma))
> +		return IXGBE_XDP_CONSUMED;
> +
> +	/* record the location of the first descriptor for this packet */
> +	tx_buffer = &ring->tx_buffer_info[ring->next_to_use];
> +	tx_buffer->bytecount = len;
> +	tx_buffer->gso_segs = 1;
> +	tx_buffer->protocol = 0;
> +
> +	i = ring->next_to_use;
> +	tx_desc = IXGBE_TX_DESC(ring, i);
> +
> +	dma_unmap_len_set(tx_buffer, len, len);
> +	dma_unmap_addr_set(tx_buffer, dma, dma);
> +	tx_buffer->data = xdp->data;
> +	tx_desc->read.buffer_addr = cpu_to_le64(dma);
> +
> +	/* put descriptor type bits */
> +	cmd_type = IXGBE_ADVTXD_DTYP_DATA |
> +		   IXGBE_ADVTXD_DCMD_DEXT |
> +		   IXGBE_ADVTXD_DCMD_IFCS;
> +	cmd_type |= len | IXGBE_TXD_CMD;
> +	tx_desc->read.cmd_type_len = cpu_to_le32(cmd_type);
> +	tx_desc->read.olinfo_status =
> +		cpu_to_le32(len << IXGBE_ADVTXD_PAYLEN_SHIFT);
> +
> +	/* Force memory writes to complete before letting h/w know there
> +	 * are new descriptors to fetch.  (Only applicable for weak-ordered
> +	 * memory model archs, such as IA-64).
> +	 *
> +	 * We also need this memory barrier to make certain all of the
> +	 * status bits have been updated before next_to_watch is written.
> +	 */
> +	wmb();
> +
> +	/* set next_to_watch value indicating a packet is present */
> +	i++;
> +	if (i == ring->count)
> +		i = 0;
> +
> +	tx_buffer->next_to_watch = tx_desc;
> +	ring->next_to_use = i;
> +
> +	writel(i, ring->tail);

A tailptr write for every XDP_TX packet is not going be fast, but you
already mentioned that this is not optimal yet, so I guess you are aware.

> +	return IXGBE_XDP_TX;
> +}


On Sun, 23 Apr 2017 18:31:36 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> @@ -9559,9 +9740,23 @@ static int ixgbe_xdp_setup(struct net_device *dev, struct bpf_prog *prog)
>  			return -EINVAL;
>  	}
>  
> +	if (nr_cpu_ids > MAX_XDP_QUEUES)
> +		return -ENOMEM;
> +


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
