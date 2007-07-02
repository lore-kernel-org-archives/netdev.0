From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI	Express adapters...
Date: Mon, 02 Jul 2007 08:52:34 -0400
Message-ID: <4688F512.3030801@garzik.org>
References: <20070612234417.5102.29147.stgit@localhost.localdomain> <20070612234431.5102.33880.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	arjan@linux.intel.com, akpm@linux-foundation.org
To: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51218 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689AbXGBMwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:52:38 -0400
In-Reply-To: <20070612234431.5102.33880.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayyappan Veeraiyan wrote:
> +#define IXGBE_TX_FLAGS_CSUM		0x00000001
> +#define IXGBE_TX_FLAGS_VLAN		0x00000002
> +#define IXGBE_TX_FLAGS_TSO		0x00000004
> +#define IXGBE_TX_FLAGS_IPV4		0x00000008
> +#define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
> +#define IXGBE_TX_FLAGS_VLAN_SHIFT	16

defining bits using the form "(1 << n)" is preferred.  Makes it easier 
to read, by eliminating the requirement of the human brain to decode hex 
into bit numbers.


> +	union {
> +		/* To protect race between sender and clean_tx_irq */
> +		spinlock_t tx_lock;
> +		struct net_device netdev;
> +	};

Embedded a struct net_device into your ring?  How can I put this?

Wrong, wrong.  Wrong, wrong, wrong.  Wrong.



> +	struct ixgbe_queue_stats stats;
> +
> +	u32 eims_value;
> +	u32 itr_val;
> +	u16 itr_range;
> +	u16 itr_register;
> +
> +	char name[IFNAMSIZ + 5];

The interface name should not be stored by your ring structure



> +#define IXGBE_DESC_UNUSED(R) \
> +	((((R)->next_to_clean > (R)->next_to_use) ? 0 : (R)->count) + \
> +	(R)->next_to_clean - (R)->next_to_use - 1)
> +
> +#define IXGBE_RX_DESC_ADV(R, i)	    \
> +	(&(((union ixgbe_adv_rx_desc *)((R).desc))[i]))
> +#define IXGBE_TX_DESC_ADV(R, i)	    \
> +	(&(((union ixgbe_adv_tx_desc *)((R).desc))[i]))
> +#define IXGBE_TX_CTXTDESC_ADV(R, i)	    \
> +	(&(((struct ixgbe_adv_tx_context_desc *)((R).desc))[i]))
> +
> +#define IXGBE_MAX_JUMBO_FRAME_SIZE	16128
> +
> +/* board specific private data structure */
> +struct ixgbe_adapter {
> +	struct timer_list watchdog_timer;
> +	struct vlan_group *vlgrp;
> +	u16 bd_number;
> +	u16 rx_buf_len;
> +	u32 part_num;
> +	u32 link_speed;
> +	unsigned long io_base;

Kill io_base and stop setting netdev->base_addr


> +	atomic_t irq_sem;
> +	struct work_struct reset_task;
> +
> +	/* TX */
> +	struct ixgbe_ring *tx_ring;	/* One per active queue */
> +	u64 restart_queue;
> +	u64 lsc_int;
> +	u32 txd_cmd;
> +	u64 hw_tso_ctxt;
> +	u64 hw_tso6_ctxt;
> +	u32 tx_timeout_count;
> +	boolean_t detect_tx_hung;
> +
> +	/* RX */
> +	struct ixgbe_ring *rx_ring;	/* One per active queue */
> +	u64 hw_csum_tx_good;
> +	u64 hw_csum_rx_error;
> +	u64 hw_csum_rx_good;
> +	u64 non_eop_descs;
> +	int num_tx_queues;
> +	int num_rx_queues;
> +	struct msix_entry *msix_entries;
> +
> +	u64 rx_hdr_split;
> +	u32 alloc_rx_page_failed;
> +	u32 alloc_rx_buff_failed;
> +	struct {
> +		unsigned int rx_csum_enabled	:1;
> +		unsigned int msi_capable	:1;
> +		unsigned int msi_enabled	:1;
> +		unsigned int msix_capable	:1;
> +		unsigned int msix_enabled	:1;
> +		unsigned int imir_enabled	:1;
> +		unsigned int in_netpoll		:1;
> +	} flags;

always avoid bitfields.  They generate horrible code, and endian 
problems abound (though no endian problems are apparent here).


> +	u32 max_frame_size;	/* Maximum frame size supported */
> +	u32 eitr;		/* Interrupt Throttle Rate */
> +
> +	/* OS defined structs */
> +	struct net_device *netdev;
> +	struct pci_dev *pdev;
> +	struct net_device_stats net_stats;
> +
> +	/* structs defined in ixgbe_hw.h */
> +	struct ixgbe_hw hw;
> +	u16 msg_enable;
> +	struct ixgbe_hw_stats stats;
> +	char lsc_name[IFNAMSIZ + 5];

delete lsc_name and use netdev name directly in request_irq()



Will review more after you fix these problems.

