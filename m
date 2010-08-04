From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Wed, 4 Aug 2010 10:09:14 -0700
Message-ID: <20100804100914.18d8c39c@nehalam>
References: <201008040515.o745FaRu028739@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <ddutt@brocade.com>, <huangj@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60948 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757565Ab0HDRJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 13:09:19 -0400
In-Reply-To: <201008040515.o745FaRu028739@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Aug 2010 22:15:36 -0700
Rasesh Mody <rmody@brocade.com> wrote:

> From: Rasesh Mody <rmody@brocade.com>
> 
> This is patch 1/6 which contains linux driver source for
> Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
> Source is based against net-next-2.6.
> 
> We wish this patch to be considered for inclusion in net-next-2.6
> 
> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> ---
>  bnad.c         | 3326 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  bnad.h         |  474 ++++++++
>  bnad_ethtool.c | 1269 +++++++++++++++++++++
>  3 files changed, 5069 insertions(+)
> 
> diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bnad.c net-next-2.6.35-rc1-mod/drivers/net/bna/bnad.c
> --- net-next-2.6.35-rc1-orig/drivers/net/bna/bnad.c	1969-12-31 16:00:00.000000000 -0800
> +++ net-next-2.6.35-rc1-mod/drivers/net/bna/bnad.c	2010-08-02 17:19:19.447239000 -0700
> @@ -0,0 +1,3326 @@
> +/*
> + * Linux network driver for Brocade Converged Network Adapter.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License (GPL) Version 2 as
> + * published by the Free Software Foundation
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + */
> +/*
> + * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
> + * All rights reserved
> + * www.brocade.com
> + */
> +#include <linux/netdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/etherdevice.h>
> +#include <linux/in.h>
> +#include <linux/ethtool.h>
> +#include <linux/if_vlan.h>
> +#include <linux/if_ether.h>
> +#include <linux/ip.h>
> +
> +#include "bnad.h"
> +#include "bna.h"
> +#include "cna.h"
> +
> +DEFINE_MUTEX(bnad_fwimg_mutex);
> +
> +/*
> + * Module params
> + */
> +static uint bnad_msix_disable;
> +module_param(bnad_msix_disable, uint, 0444);
> +MODULE_PARM_DESC(bnad_msix_disable, "Disable MSIX mode");
> +
> +static uint bnad_ioc_auto_recover = 1;
> +module_param(bnad_ioc_auto_recover, uint, 0444);
> +MODULE_PARM_DESC(bnad_ioc_auto_recover, "Enable / Disable auto recovery");
> +
> +/*
> + * Global variables
> + */
> +u32 bna_id;
> +u32 bnad_rxqs_per_cq = 2;
> +
> +DECLARE_MUTEX(bnad_list_sem);
> +LIST_HEAD(bnad_list);
> +
> +const u8 bnad_bcast_addr[] =  {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};

Surprised this isn't defined somewhere else.

> +
> +/*
> + * Local MACROS
> + */
> +#define BNAD_TX_UNMAPQ_DEPTH (bnad->txq_depth * 2)
> +
> +#define BNAD_RX_UNMAPQ_DEPTH (bnad->rxq_depth)
> +
> +#define BNAD_GET_MBOX_IRQ(_bnad)				\
> +	(((_bnad)->cfg_flags & BNAD_CF_MSIX) ?			\
> +	 ((_bnad)->msix_table[(_bnad)->msix_num - 1].vector) : 	\
> +	 ((_bnad)->pcidev->irq))
> +
> +#define BNAD_FILL_UNMAPQ_MEM_REQ(_res_info, _num, _depth)	\
> +do {								\
> +	(_res_info)->res_type = BNA_RES_T_MEM;			\
> +	(_res_info)->res_u.mem_info.mem_type = BNA_MEM_T_KVA;	\
> +	(_res_info)->res_u.mem_info.num = (_num);		\
> +	(_res_info)->res_u.mem_info.len =			\
> +	sizeof(struct bnad_unmap_q) +				\
> +	(sizeof(struct bnad_skb_unmap) * ((_depth) - 1));	\
> +} while (0)
> +
> +void
> +bnad_add_to_list(struct bnad *bnad)
> +{
> +	down(&bnad_list_sem);
> +	list_add_tail(&bnad->list_entry, &bnad_list);
> +	bna_id++;
> +	up(&bnad_list_sem);
> +}

Why do you need to list semaphore? Isn't RTNL mutex held
when this is done. If you have to have own exclusion use
a mutex for this.

> +void
> +bnad_remove_from_list(struct bnad *bnad)
> +{
> +	down(&bnad_list_sem);
> +	list_del(&bnad->list_entry);
> +	up(&bnad_list_sem);
> +}
> +
> +const struct pci_device_id bnad_pci_id_table[] = {
> +	{
> +		PCI_DEVICE(PCI_VENDOR_ID_BROCADE,
> +			PCI_DEVICE_ID_BROCADE_CT),
> +		.class = PCI_CLASS_NETWORK_ETHERNET << 8,
> +		.class_mask =  0xffff00
> +	}, {0,  }
> +};

Why is this not static?


> +/* TX */
> +/* bnad_start_xmit : Netdev entry point for Transmit */
> +/*		     Called under lock held by net_device */
> +
> +netdev_tx_t
> +bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)

Should also be static...

> +{
> +	struct bnad *bnad = netdev_priv(netdev);
> +
> +	u16 		txq_prod, vlan_tag = 0;
> +	u32 		unmap_prod, wis, wis_used, wi_range;
> +	u32 		vectors, vect_id, i, acked;
> +	u32		tx_id;
> +	int 			err;
> +
> +	struct bnad_tx_info *tx_info;
> +	struct bna_tcb *tcb;
> +	struct bnad_unmap_q *unmap_q;
> +	dma_addr_t 		dma_addr;
> +	struct bna_txq_entry *txqent;
> +	bna_txq_wi_ctrl_flag_t 	flags;
> +
> +	if (unlikely
> +	    (skb->len <= ETH_HLEN || skb->len > BFI_TX_MAX_DATA_PER_PKT)) {
> +		dev_kfree_skb(skb);
> +		return NETDEV_TX_OK;
> +	}
> +
> +	/*
> +	 * Takes care of the Tx that is scheduled between clearing the flag
> +	 * and the netif_stop_queue() call.
> +	 */
> +	if (unlikely(!test_bit(BNAD_RF_TX_STARTED, &bnad->run_flags))) {
> +		dev_kfree_skb(skb);
> +		return NETDEV_TX_OK;
> +	}
> +
> +	tx_id = BNAD_GET_TX_ID(skb);
> +
> +	tx_info = &bnad->tx_info[tx_id];
> +	tcb = tx_info->tcb[tx_id];
> +	unmap_q = tcb->unmap_q;
> +
> +	vectors = 1 + skb_shinfo(skb)->nr_frags;
> +	if (vectors > BFI_TX_MAX_VECTORS_PER_PKT) {
> +		dev_kfree_skb(skb);
> +		return NETDEV_TX_OK;
> +	}
> +	wis = BNA_TXQ_WI_NEEDED(vectors);	/* 4 vectors per work item */
> +	acked = 0;
> +	if (unlikely
> +	    (wis > BNA_QE_FREE_CNT(tcb, tcb->q_depth) ||
> +	     vectors > BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth))) {
> +		if ((u16) (*tcb->hw_consumer_index) !=
> +		    tcb->consumer_index &&
> +		    !test_and_set_bit(BNAD_TXQ_FREE_SENT, &tcb->flags)) {
> +			acked = bnad_free_txbufs(bnad, tcb);
> +			bna_ib_ack(tcb->i_dbell, acked);
> +			smp_mb__before_clear_bit();
> +			clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
> +		} else {
> +			netif_stop_queue(netdev);
> +			BNAD_UPDATE_CTR(bnad, netif_queue_stop);
> +		}
> +
> +		smp_mb();
> +		/*
> +		 * Check again to deal with race condition between
> +		 * netif_stop_queue here, and netif_wake_queue in
> +		 * interrupt handler which is not inside netif tx lock.
> +		 */
> +		if (likely
> +		    (wis > BNA_QE_FREE_CNT(tcb, tcb->q_depth) ||
> +		     vectors > BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth))) {
> +			BNAD_UPDATE_CTR(bnad, netif_queue_stop);
> +			return NETDEV_TX_BUSY;

The transmit routine should check for available space after
queueing to device, so you can avoid having to return
TX_BUSY.
