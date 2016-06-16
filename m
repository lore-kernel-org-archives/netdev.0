From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Thu, 16 Jun 2016 22:46:23 +0200
Message-ID: <20160616204623.GA7546@electric-eye.fr.zoreil.com>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davm@davemeloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aligouri@amazon.com, antoine.tenart@free-electrons.com
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Netanel Belgazal <netanel@annapurnalabs.com> :
[...]

Very limited review below.

> diff --git a/Documentation/networking/ena.txt b/Documentation/networking/ena.txt
> new file mode 100644
> index 0000000..528544f
> --- /dev/null
> +++ b/Documentation/networking/ena.txt
> @@ -0,0 +1,330 @@
> +Linux kernel driver for Elastic Network Adapter (ENA) family:
> +=============================================================
> +
> +Overview:
> +=========
> +The ENA driver provides a modern Ethernet device interface optimized
> +for high performance and low CPU overhead.

Marketing boilerplate. How much of it will still be true in 6 months ?
6 years ?

Hint: stay technical. If in doubt, make it boring. :o)

[...]
> +ENA devices allow high speed and low overhead Ethernet traffic
> +processing by providing a dedicated Tx/Rx queue pair per host CPU, a
> +dedicated MSI-X interrupt vector per Tx/Rx queue pair, adaptive
> +interrupt moderation, and CPU cacheline optimized data placement.

How many queues exactly ?

[...]
> +Memory Allocations:
> +===================
> +DMA Coherent buffers are allocated for the following DMA rings:
> +- Tx submission ring (For regular mode; for LLQ mode it is allocated
> +  using kzalloc)
> +- Tx completion ring
> +- Rx submission ring
> +- Rx completion ring
> +- Admin submission ring
> +- Admin completion ring
> +- AENQ ring

Useless documentation (implementation detail).

Nobody will maintain it when the driver changes. Please remove.

[...]
> +MTU:
> +====
> +The driver supports an arbitrarily large MTU with a maximum that is
> +negotiated with the device. The driver configures MTU using the
> +SetFeature command (ENA_ADMIN_MTU property). The user can change MTU
> +via ifconfig(8) and ip(8).

Please avoid advertising legacy ifconfig.

[...]
> diff --git a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
> new file mode 100644
> index 0000000..8516e5e
> --- /dev/null
> +++ b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
[...]
> +/* admin commands opcodes */
> +enum ena_admin_aq_opcode {
> +	/* create submission queue */
> +	ENA_ADMIN_CREATE_SQ = 1,
> +
> +	/* destroy submission queue */
> +	ENA_ADMIN_DESTROY_SQ = 2,
> +
> +	/* create completion queue */
> +	ENA_ADMIN_CREATE_CQ = 3,
> +
> +	/* destroy completion queue */
> +	ENA_ADMIN_DESTROY_CQ = 4,
> +
> +	/* get capabilities of particular feature */
> +	ENA_ADMIN_GET_FEATURE = 8,
> +
> +	/* get capabilities of particular feature */
> +	ENA_ADMIN_SET_FEATURE = 9,
> +
> +	/* get statistics */
> +	ENA_ADMIN_GET_STATS = 11,
> +};

The documentation above simply duplicates the member names -> useless
visual payload.

Please replace space with tab before "=" to line things up.

[...]
> +/* Basic Statistics Command. */
> +struct ena_admin_basic_stats {
> +	/* word 0 :  */
> +	u32 tx_bytes_low;
> +
> +	/* word 1 :  */
> +	u32 tx_bytes_high;
> +
> +	/* word 2 :  */
> +	u32 tx_pkts_low;
> +
> +	/* word 3 :  */
> +	u32 tx_pkts_high;
> +
> +	/* word 4 :  */
> +	u32 rx_bytes_low;
> +
> +	/* word 5 :  */
> +	u32 rx_bytes_high;
> +
> +	/* word 6 :  */
> +	u32 rx_pkts_low;
> +
> +	/* word 7 :  */
> +	u32 rx_pkts_high;
> +
> +	/* word 8 :  */
> +	u32 rx_drops_low;
> +
> +	/* word 9 :  */
> +	u32 rx_drops_high;
> +};

struct zorg {
	u32 ...;
	u32 ...;
	u32 ...;
	u32 ...;

	u32 ...;
	u32 ...;
	u32 ...;
	u32 ...;

	u32 ...;
	u32 ...;
	u32 ...;
};

-> No comment needed to figure the offset.
   Comment removed => no need to check if offset starts at word 0 or word 1.

[...]
> diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
> new file mode 100644
> index 0000000..357e10f
> --- /dev/null
> +++ b/drivers/net/ethernet/amazon/ena/ena_com.c
[...]
> +static inline int ena_com_mem_addr_set(struct ena_com_dev *ena_dev,
> +				       struct ena_common_mem_addr *ena_addr,
> +				       dma_addr_t addr)
> +{
> +	if ((addr & GENMASK_ULL(ena_dev->dma_addr_bits - 1, 0)) != addr) {
> +		ena_trc_err("dma address has more bits that the device supports\n");
> +		return -EINVAL;
> +	}
> +
> +	ena_addr->mem_addr_low = (u32)addr;
> +	ena_addr->mem_addr_high =
> +		((addr & GENMASK_ULL(ena_dev->dma_addr_bits - 1, 32)) >> 32);

No need to "... & GENMASK" given the test above.

> +
> +	return 0;
> +}
> +
> +static int ena_com_admin_init_sq(struct ena_com_admin_queue *queue)
> +{
> +	queue->sq.entries =
> +		dma_alloc_coherent(queue->q_dmadev,
> +				   ADMIN_SQ_SIZE(queue->q_depth),
> +				   &queue->sq.dma_addr,
> +				   GFP_KERNEL | __GFP_ZERO);

1. Use dma_zalloc_coherent().

2. Style
	xyzab = dma_alloc_coherent(..., ..., ...                  ...,
				   ...);

3. Add local variable for &queue->sq.


In a different part of the code: s/uint32_t/u32/

-- 
Ueimor
