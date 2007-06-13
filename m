From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH]: ps3: gigabit ethernet driver for PS3
Date: Wed, 13 Jun 2007 16:27:32 -0400
Message-ID: <46705334.5060001@garzik.org>
References: <20070613154156.71DB.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Geoff Levand <geoffrey.levand@am.sony.com>,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: MOKUNO Masakazu <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39460 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753647AbXFMU1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 16:27:41 -0400
In-Reply-To: <20070613154156.71DB.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MOKUNO Masakazu wrote:
> Hi Jeff,
> 
> The following patch adds support for the gigabit ethernet device of PS3. 
> It was sent out before as RFC, now I submit it for 2.6.23.
> 
> Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
> Signed-off-by: Geoff Levand <geoffrey.levand@am.sony.com>
> ---
>  drivers/net/Kconfig     |   10 
>  drivers/net/Makefile    |    2 
>  drivers/net/gelic_net.c | 1564 ++++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/gelic_net.h |  233 +++++++
>  4 files changed, 1809 insertions(+)

a MAINTAINERS entry would be nice


> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2264,6 +2264,16 @@ config TSI108_ETH
>  	     To compile this driver as a module, choose M here: the module
>  	     will be called tsi108_eth.
>  
> +config GELIC_NET
> +	tristate "PS3 Gigabit Ethernet driver"
> +	depends on PPC_PS3
> +	help
> +	  This driver supports the Gigabit Ethernet device on the
> +	  PS3 game console.
> +
> +	  To compile this driver as a module, choose M here: the
> +	  module will be called ps3_gelic.
> +
>  config GIANFAR
>  	tristate "Gianfar Ethernet"
>  	depends on 85xx || 83xx || PPC_86xx
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -60,6 +60,8 @@ obj-$(CONFIG_TIGON3) += tg3.o
>  obj-$(CONFIG_BNX2) += bnx2.o
>  spidernet-y += spider_net.o spider_net_ethtool.o
>  obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
> +obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
> +ps3_gelic-objs += gelic_net.o
>  obj-$(CONFIG_TC35815) += tc35815.o
>  obj-$(CONFIG_SKGE) += skge.o
>  obj-$(CONFIG_SKY2) += sky2.o

How about ps3_gige for the driver name.  Ditto DaveM's comments about 
cleanups here.



> --- /dev/null
> +++ b/drivers/net/gelic_net.c
> @@ -0,0 +1,1564 @@
> +/*
> + *  PS3 Platfom gelic network driver.
> + *
> + * Copyright (C) 2007 Sony Computer Entertainment Inc.
> + * Copyright 2007 Sony Corporation
> + *
> + *  this file is based on: spider_net.c
> + *
> + * Network device driver for Cell Processor-Based Blade
> + *
> + * (C) Copyright IBM Corp. 2005
> + *
> + * Authors : Utz Bacher <utz.bacher@de.ibm.com>
> + *           Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2, or (at your option)
> + * any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +
> +#undef DEBUG
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +
> +#include <linux/etherdevice.h>
> +#include <linux/ethtool.h>
> +#include <linux/if_vlan.h>
> +
> +#include <linux/in.h>
> +#include <linux/ip.h>
> +#include <linux/tcp.h>
> +
> +#include <linux/dma-mapping.h>
> +#include <net/checksum.h>
> +#include <asm/firmware.h>
> +#include <asm/ps3.h>
> +#include <asm/lv1call.h>
> +
> +#include "gelic_net.h"

Please run this patch through scripts/checkpatch.pl (newly added in 
latest 2.6.22-rcX-gitY)


> +#define GELIC_NET_DRV_NAME "Gelic Network Driver"
> +#define GELIC_NET_DRV_VERSION "1.0"

please follow other net drivers and use the more simple DRV_NAME and 
DRV_VERSION


> +MODULE_AUTHOR("SCE Inc.");
> +MODULE_DESCRIPTION("Gelic Network driver");
> +MODULE_LICENSE("GPL");
> +
> +static inline struct device * ctodev(struct gelic_net_card * card)
> +{
> +	return &card->dev->core;
> +}
> +static inline unsigned int bus_id(struct gelic_net_card *card)
> +{
> +	return card->dev->bus_id;
> +}
> +static inline unsigned int dev_id(struct gelic_net_card *card)
> +{
> +	return card->dev->dev_id;
> +}
> +
> +/* set irq_mask */
> +static int gelic_net_set_irq_mask(struct gelic_net_card *card, u64 mask)
> +{
> +	int status;
> +
> +	status = lv1_net_set_interrupt_mask(bus_id(card), dev_id(card),
> +					    mask, 0);
> +	if (status)
> +		dev_info(ctodev(card),
> +			 "lv1_net_set_interrupt_mask failed %d\n", status);
> +	return status;
> +}
> +static inline void gelic_net_rx_irq_on(struct gelic_net_card *card)
> +{
> +	gelic_net_set_irq_mask(card, card->ghiintmask | GELIC_NET_RXINT);
> +}
> +static inline void gelic_net_rx_irq_off(struct gelic_net_card *card)
> +{
> +	gelic_net_set_irq_mask(card, card->ghiintmask & ~GELIC_NET_RXINT);
> +}
> +/**
> + * gelic_net_get_descr_status -- returns the status of a descriptor
> + * @descr: descriptor to look at
> + *
> + * returns the status as in the dmac_cmd_status field of the descriptor
> + */
> +static enum gelic_net_descr_status
> +gelic_net_get_descr_status(struct gelic_net_descr *descr)
> +{
> +	u32 cmd_status;
> +
> +	cmd_status = descr->dmac_cmd_status;
> +	cmd_status >>= GELIC_NET_DESCR_IND_PROC_SHIFT;
> +	return cmd_status;
> +}
> +
> +/**
> + * gelic_net_set_descr_status -- sets the status of a descriptor
> + * @descr: descriptor to change
> + * @status: status to set in the descriptor
> + *
> + * changes the status to the specified value. Doesn't change other bits
> + * in the status
> + */
> +static void gelic_net_set_descr_status(struct gelic_net_descr *descr,
> +				       enum gelic_net_descr_status status)
> +{
> +	u32 cmd_status;
> +
> +	/* read the status */
> +	cmd_status = descr->dmac_cmd_status;
> +	/* clean the upper 4 bits */
> +	cmd_status &= GELIC_NET_DESCR_IND_PROC_MASKO;
> +	/* add the status to it */
> +	cmd_status |= ((u32)status) << GELIC_NET_DESCR_IND_PROC_SHIFT;
> +	/* and write it back */
> +	descr->dmac_cmd_status = cmd_status;
> +	wmb();

does the wmb() actually do anything useful here?


> + * gelic_net_free_chain - free descriptor chain
> + * @card: card structure
> + * @descr_in: address of desc
> + */
> +static void gelic_net_free_chain(struct gelic_net_card *card,
> +				 struct gelic_net_descr *descr_in)
> +{
> +	struct gelic_net_descr *descr;
> +
> +	for (descr = descr_in; descr && descr->bus_addr; descr = descr->next) {
> +		dma_unmap_single(ctodev(card), descr->bus_addr,
> +				 GELIC_NET_DESCR_SIZE, DMA_BIDIRECTIONAL);
> +		descr->bus_addr = 0;
> +	}
> +}
> +
> +/**
> + * gelic_net_init_chain - links descriptor chain
> + * @card: card structure
> + * @chain: address of chain
> + * @start_descr: address of descriptor array
> + * @no: number of descriptors
> + *
> + * we manage a circular list that mirrors the hardware structure,
> + * except that the hardware uses bus addresses.
> + *
> + * returns 0 on success, <0 on failure
> + */
> +static int gelic_net_init_chain(struct gelic_net_card *card,
> +				struct gelic_net_descr_chain *chain,
> +				struct gelic_net_descr *start_descr, int no)
> +{
> +	int i;
> +	struct gelic_net_descr *descr;
> +
> +	descr = start_descr;
> +	memset(descr, 0, sizeof(*descr) * no);
> +
> +	/* set up the hardware pointers in each descriptor */
> +	for (i = 0; i < no; i++, descr++) {
> +		gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
> +		descr->bus_addr =
> +			dma_map_single(ctodev(card), descr,
> +				       GELIC_NET_DESCR_SIZE,
> +				       DMA_BIDIRECTIONAL);
> +
> +		if (!descr->bus_addr)
> +			goto iommu_error;
> +
> +		descr->next = descr + 1;
> +		descr->prev = descr - 1;
> +	}
> +	/* make them as ring */
> +	(descr - 1)->next = start_descr;
> +	start_descr->prev = (descr - 1);
> +
> +	/* chain bus addr of hw descriptor */
> +	descr = start_descr;
> +	for (i = 0; i < no; i++, descr++) {
> +		descr->next_descr_addr = descr->next->bus_addr;
> +	}
> +
> +	chain->head = start_descr;
> +	chain->tail = start_descr;
> +
> +	/* do not chain last hw descriptor */
> +	(descr - 1)->next_descr_addr = 0;
> +
> +	return 0;
> +
> +iommu_error:
> +	for (i--, descr--; 0 <= i; i--, descr--)
> +		if (descr->bus_addr)
> +			dma_unmap_single(ctodev(card), descr->bus_addr,
> +					 GELIC_NET_DESCR_SIZE,
> +					 DMA_BIDIRECTIONAL);
> +	return -ENOMEM;
> +}
> +
> +/**
> + * gelic_net_prepare_rx_descr - reinitializes a rx descriptor
> + * @card: card structure
> + * @descr: descriptor to re-init
> + *
> + * return 0 on succes, <0 on failure
> + *
> + * allocates a new rx skb, iommu-maps it and attaches it to the descriptor.
> + * Activate the descriptor state-wise
> + */
> +static int gelic_net_prepare_rx_descr(struct gelic_net_card *card,
> +				      struct gelic_net_descr *descr)
> +{
> +	int offset;
> +	unsigned int bufsize;
> +
> +	if (gelic_net_get_descr_status(descr) !=  GELIC_NET_DESCR_NOT_IN_USE) {
> +		dev_info(ctodev(card), "%s: ERROR status \n", __func__);
> +	}
> +	/* we need to round up the buffer size to a multiple of 128 */
> +	bufsize = (GELIC_NET_MAX_MTU + GELIC_NET_RXBUF_ALIGN - 1) &
> +		(~(GELIC_NET_RXBUF_ALIGN - 1));

use ALIGN()?


> +	/* and we need to have it 128 byte aligned, therefore we allocate a
> +	 * bit more */
> +	descr->skb = netdev_alloc_skb(card->netdev,
> +		bufsize + GELIC_NET_RXBUF_ALIGN - 1);

net_device allocation is already rounded.  and combined with the above 
code snippet, it appears you're aligning twice


> +	if (!descr->skb) {
> +		descr->buf_addr = 0; /* tell DMAC don't touch memory */
> +		dev_info(ctodev(card),
> +			 "%s:allocate skb failed !!\n", __func__);
> +		return -ENOMEM;
> +	}
> +	descr->buf_size = bufsize;
> +	descr->dmac_cmd_status = 0;
> +	descr->result_size = 0;
> +	descr->valid_size = 0;
> +	descr->data_error = 0;
> +
> +	offset = ((unsigned long)descr->skb->data) &
> +		(GELIC_NET_RXBUF_ALIGN - 1);
> +	if (offset)
> +		skb_reserve(descr->skb, GELIC_NET_RXBUF_ALIGN - offset);
> +	/* io-mmu-map the skb */
> +	descr->buf_addr = dma_map_single(ctodev(card), descr->skb->data,
> +					 GELIC_NET_MAX_MTU,
> +					 DMA_BIDIRECTIONAL);
> +	wmb();
> +	if (!descr->buf_addr) {
> +		dev_kfree_skb_any(descr->skb);
> +		descr->skb = NULL;
> +		dev_info(ctodev(card),
> +			 "%s:Could not iommu-map rx buffer\n", __func__);
> +		gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
> +		return -ENOMEM;
> +	} else {
> +		gelic_net_set_descr_status(descr, GELIC_NET_DESCR_CARDOWNED);
> +		return 0;
> +	}
> +}
> +
> +/**
> + * gelic_net_release_rx_chain - free all skb of rx descr
> + * @card: card structure
> + *
> + */
> +static void gelic_net_release_rx_chain(struct gelic_net_card *card)
> +{
> +	struct gelic_net_descr * descr = card->rx_chain.head;
> +
> +	do {
> +		if (descr->skb) {
> +			dma_unmap_single(ctodev(card),
> +					 descr->buf_addr,
> +					 descr->skb->len,
> +					 DMA_BIDIRECTIONAL);
> +			descr->buf_addr = 0;
> +			dev_kfree_skb_any(descr->skb);
> +			descr->skb = NULL;
> +			descr->dmac_cmd_status = GELIC_NET_DESCR_NOT_IN_USE;
> +		}
> +		descr = descr->next;
> +	} while (descr != card->rx_chain.head);
> +}
> +
> +/**
> + * gelic_net_fill_rx_chain - fills descriptors/skbs in the rx chains
> + * @card: card structure
> + *
> + * fills all descriptors in the rx chain: allocates skbs
> + * and iommu-maps them.
> + * returns 0 on success, <0 on failure
> + */
> +static int gelic_net_fill_rx_chain(struct gelic_net_card *card)
> +{
> +	struct gelic_net_descr *descr = card->rx_chain.head;
> +	int ret;
> +
> +	do {
> +		if (!descr->skb)
> +			if ((ret = gelic_net_prepare_rx_descr(card, descr)))
> +				goto rewind;

please avoid combining two C statements into a single line.

	ret = gelic_net_...()
	if (ret)
		goto rewind

is more readable


> +		descr = descr->next;
> +	} while (descr != card->rx_chain.head);
> +
> +	return 0;
> +rewind:
> +	gelic_net_release_rx_chain(card);
> +	return ret;
> +}
> +
> +/**
> + * gelic_net_alloc_rx_skbs - allocates rx skbs in rx descriptor chains
> + * @card: card structure
> + *
> + * returns 0 on success, <0 on failure
> + */
> +static int gelic_net_alloc_rx_skbs(struct gelic_net_card *card)
> +{
> +	struct gelic_net_descr_chain *chain;
> +	int ret;
> +	chain = &card->rx_chain;
> +	ret = gelic_net_fill_rx_chain(card);
> +	chain->head = card->rx_top->prev; /* point to the last */
> +	return ret;
> +}
> +
> +/**
> + * gelic_net_release_tx_descr - processes a used tx descriptor
> + * @card: card structure
> + * @descr: descriptor to release
> + *
> + * releases a used tx descriptor (unmapping, freeing of skb)
> + */
> +static void gelic_net_release_tx_descr(struct gelic_net_card *card,
> +			    struct gelic_net_descr *descr)
> +{
> +	struct sk_buff *skb;
> +
> +
> +	if (descr->data_status & (1 << GELIC_NET_TXDESC_TAIL)) {
> +		/* 2nd descriptor */
> +		skb = descr->skb;
> +		dma_unmap_single(ctodev(card), descr->buf_addr, skb->len,
> +				 DMA_BIDIRECTIONAL);
> +		dev_kfree_skb_any(skb);
> +	} else {
> +		dma_unmap_single(ctodev(card), descr->buf_addr,
> +				 descr->buf_size, DMA_BIDIRECTIONAL);
> +	}
> +
> +	descr->buf_addr = 0;
> +	descr->buf_size = 0;
> +	descr->next_descr_addr = 0;
> +	descr->result_size = 0;
> +	descr->valid_size = 0;
> +	descr->data_status = 0;
> +	descr->data_error = 0;
> +	descr->skb = NULL;
> +
> +	/* set descr status */
> +	descr->dmac_cmd_status = GELIC_NET_DMAC_CMDSTAT_NOT_IN_USE;
> +}
> +
> +/**
> + * gelic_net_release_tx_chain - processes sent tx descriptors
> + * @card: adapter structure
> + * @stop: net_stop sequence
> + *
> + * releases the tx descriptors that gelic has finished with
> + */
> +static void gelic_net_release_tx_chain(struct gelic_net_card *card, int stop)
> +{
> +	struct gelic_net_descr_chain *tx_chain;
> +	enum gelic_net_descr_status status;
> +	int release = 0;
> +
> +	for (tx_chain = &card->tx_chain;
> +	     tx_chain->head != tx_chain->tail && tx_chain->tail;
> +	     tx_chain->tail = tx_chain->tail->next) {
> +		status = gelic_net_get_descr_status(tx_chain->tail);
> +		switch (status) {
> +		case GELIC_NET_DESCR_RESPONSE_ERROR:
> +		case GELIC_NET_DESCR_PROTECTION_ERROR:
> +		case GELIC_NET_DESCR_FORCE_END:
> +			if (printk_ratelimit())
> +				dev_info(ctodev(card),
> +					 "%s: forcing end of tx descriptor " \
> +					 "with status %x\n",
> +					 __func__, status);
> +			card->netdev_stats.tx_dropped++;
> +			break;
> +
> +		case GELIC_NET_DESCR_COMPLETE:
> +			card->netdev_stats.tx_packets++;
> +			card->netdev_stats.tx_bytes +=
> +				tx_chain->tail->skb->len;
> +			break;
> +
> +		case GELIC_NET_DESCR_CARDOWNED:
> +			/* pending tx request */
> +		default:
> +			/* any other value (== GELIC_NET_DESCR_NOT_IN_USE) */
> +			goto out;
> +		}
> +		gelic_net_release_tx_descr(card, tx_chain->tail);
> +		release = 1;
> +	}
> +out:
> +	if (!stop && release && netif_queue_stopped(card->netdev))
> +		netif_wake_queue(card->netdev);

shouldn't need to test netif_queued_stopped() before calling 
netif_wake_queue(), as netif_wake_queue() essentially already does this



> + * gelic_net_set_multi - sets multicast addresses and promisc flags
> + * @netdev: interface device structure
> + *
> + * gelic_net_set_multi configures multicast addresses as needed for the
> + * netdev interface. It also sets up multicast, allmulti and promisc
> + * flags appropriately
> + */
> +static void gelic_net_set_multi(struct net_device *netdev)
> +{
> +	struct gelic_net_card *card = netdev_priv(netdev);
> +	struct dev_mc_list *mc;
> +	unsigned int i;
> +	uint8_t *p;
> +	u64 addr;
> +	int status;
> +
> +	/* clear all multicast address */
> +	status = lv1_net_remove_multicast_address(bus_id(card), dev_id(card),
> +						  0, 1);
> +	if (status)
> +		dev_err(ctodev(card),
> +			"lv1_net_remove_multicast_address failed %d\n",
> +			status);
> +	/* set broadcast address */
> +	status = lv1_net_add_multicast_address(bus_id(card), dev_id(card),
> +					       GELIC_NET_BROADCAST_ADDR, 0);
> +	if (status)
> +		dev_err(ctodev(card),
> +			"lv1_net_add_multicast_address failed, %d\n",
> +			status);
> +
> +	if (netdev->flags & IFF_ALLMULTI
> +		|| netdev->mc_count > GELIC_NET_MC_COUNT_MAX) { /* list max */
> +		status = lv1_net_add_multicast_address(bus_id(card), dev_id(card),
> +						       0, 1);
> +		if (status)
> +			dev_err(ctodev(card),
> +				"lv1_net_add_multicast_address failed, %d\n",
> +				status);
> +		return;
> +	}
> +
> +	/* set multicast address */
> +	for (mc = netdev->mc_list; mc; mc = mc->next) {
> +		addr = 0;
> +		p = mc->dmi_addr;
> +		for (i = 0; i < ETH_ALEN; i++) {
> +			addr <<= 8;
> +			addr |= *p++;
> +		}
> +		status = lv1_net_add_multicast_address(bus_id(card), dev_id(card),
> +				addr, 0);
> +		if (status)
> +			dev_err(ctodev(card),
> +				"lv1_net_add_multicast_address failed, %d\n",
> +				status);
> +	}

this seems not to handle the promisc case



> +/**
> + * gelic_net_enable_rxdmac - enables the receive DMA controller
> + * @card: card structure
> + *
> + * gelic_net_enable_rxdmac enables the DMA controller by setting RX_DMA_EN
> + * in the GDADMACCNTR register
> + */
> +static void gelic_net_enable_rxdmac(struct gelic_net_card *card)
> +{
> +	int status;
> +
> +	status = lv1_net_start_rx_dma(bus_id(card), dev_id(card),
> +				card->rx_chain.tail->bus_addr, 0);
> +	if (status)
> +		printk("lv1_net_start_rx_dma failed, status=%d\n", status);
> +}
> +
> +/**
> + * gelic_net_disable_rxdmac - disables the receive DMA controller
> + * @card: card structure
> + *
> + * gelic_net_disable_rxdmac terminates processing on the DMA controller by
> + * turing off DMA and issueing a force end
> + */
> +static void gelic_net_disable_rxdmac(struct gelic_net_card *card)
> +{
> +	int status;
> +
> +	/* this hvc blocks until the DMA in progress really stopped */
> +	status = lv1_net_stop_rx_dma(bus_id(card), dev_id(card), 0);
> +	if (status)
> +		dev_err(ctodev(card),
> +			"lv1_net_stop_rx_dma faild, %d\n", status);
> +}
> +
> +/**
> + * gelic_net_disable_txdmac - disables the transmit DMA controller
> + * @card: card structure
> + *
> + * gelic_net_disable_txdmac terminates processing on the DMA controller by
> + * turing off DMA and issueing a force end
> + */
> +static void gelic_net_disable_txdmac(struct gelic_net_card *card)
> +{
> +	int status;
> +
> +	/* this hvc blocks until the DMA in progress really stopped */
> +	status = lv1_net_stop_tx_dma(bus_id(card), dev_id(card), 0);
> +	if (status)
> +		dev_err(ctodev(card),
> +			"lv1_net_stop_tx_dma faild, status=%d\n", status);
> +}

do we really need all these three-C-statement functions?


> +/**
> + * gelic_net_stop - called upon ifconfig down
> + * @netdev: interface device structure
> + *
> + * always returns 0
> + */
> +static int gelic_net_stop(struct net_device *netdev)
> +{
> +	struct gelic_net_card *card = netdev_priv(netdev);
> +
> +	netif_poll_disable(netdev);
> +	netif_stop_queue(netdev);
> +
> +	/* turn off DMA, force end */
> +	gelic_net_disable_rxdmac(card);
> +	gelic_net_disable_txdmac(card);
> +
> +	gelic_net_set_irq_mask(card, 0);
> +
> +	/* disconnect event port */
> +	free_irq(card->netdev->irq, card->netdev);
> +	ps3_sb_event_receive_port_destroy(card->dev, card->netdev->irq);
> +	card->netdev->irq = NO_IRQ;
> +
> +	netif_carrier_off(netdev);
> +
> +	/* release chains */
> +	gelic_net_release_tx_chain(card, 1);
> +	gelic_net_release_rx_chain(card);
> +
> +	gelic_net_free_chain(card, card->tx_top);
> +	gelic_net_free_chain(card, card->rx_top);
> +
> +	return 0;
> +}
> +
> +/**
> + * gelic_net_get_next_tx_descr - returns the next available tx descriptor
> + * @card: device structure to get descriptor from
> + *
> + * returns the address of the next descriptor, or NULL if not available.
> + */
> +static struct gelic_net_descr *
> +gelic_net_get_next_tx_descr(struct gelic_net_card *card)
> +{
> +	if (!card->tx_chain.head)
> +		return NULL;
> +	/*  see if we can two consecutive free descrs */
> +	if (card->tx_chain.tail != card->tx_chain.head->next &&
> +	    gelic_net_get_descr_status(card->tx_chain.head) ==
> +	    GELIC_NET_DESCR_NOT_IN_USE &&
> +	    card->tx_chain.tail != card->tx_chain.head->next->next &&
> +	    gelic_net_get_descr_status(card->tx_chain.head->next) ==
> +	     GELIC_NET_DESCR_NOT_IN_USE )
> +		return card->tx_chain.head;
> +	else
> +		return NULL;
> +
> +}
> +
> +/**
> + * gelic_net_set_txdescr_cmdstat - sets the tx descriptor command field
> + * @descr: descriptor structure to fill out
> + * @skb: packet to consider
> + * @middle: middle of frame
> + *
> + * fills out the command and status field of the descriptor structure,
> + * depending on hardware checksum settings. This function assumes a wmb()
> + * has executed before.
> + */
> +static void gelic_net_set_txdescr_cmdstat(struct gelic_net_descr *descr,
> +					  struct sk_buff *skb, int middle)
> +{
> +	u32 eofr;
> +
> +	if (middle)
> +		eofr = 0;
> +	else
> +		eofr = GELIC_NET_DMAC_CMDSTAT_END_FRAME;
> +
> +	if (skb->ip_summed != CHECKSUM_PARTIAL)
> +		descr->dmac_cmd_status = GELIC_NET_DMAC_CMDSTAT_NOCS | eofr;
> +	else {
> +		/* is packet ip?
> +		 * if yes: tcp? udp? */
> +		if (skb->protocol == htons(ETH_P_IP)) {
> +			if (ip_hdr(skb)->protocol == IPPROTO_TCP)
> +				descr->dmac_cmd_status = GELIC_NET_DMAC_CMDSTAT_TCPCS | eofr;
> +			else if (ip_hdr(skb)->protocol == IPPROTO_UDP)
> +				descr->dmac_cmd_status = GELIC_NET_DMAC_CMDSTAT_UDPCS | eofr;
> +			else	/*
> +				 * the stack should checksum non-tcp and non-udp
> +				 * packets on his own: NETIF_F_IP_CSUM
> +				 */
> +				descr->dmac_cmd_status = GELIC_NET_DMAC_CMDSTAT_NOCS | eofr;
> +		}
> +	}
> +}
> +
> +/**
> + * gelic_net_prepare_tx_descr_v - get dma address of skb_data
> + * @card: card structure
> + * @descr: descriptor structure
> + * @skb: packet to use
> + *
> + * returns 0 on success, <0 on failure.
> + *
> + */
> +static int gelic_net_prepare_tx_descr_v(struct gelic_net_card *card,
> +					struct gelic_net_descr *descr,
> +					struct sk_buff *skb)
> +{
> +	dma_addr_t buf[2];
> +	unsigned int vlan_len;
> +
> +	if (skb->len < GELIC_NET_VLAN_POS)
> +		return -EINVAL;
> +
> +	memcpy(&descr->vlan, skb->data, GELIC_NET_VLAN_POS);
> +	if (card->vlan_index != -1) {
> +		descr->vlan.h_vlan_proto = htons(ETH_P_8021Q); /* vlan 0x8100*/
> +		descr->vlan.h_vlan_TCI = htons(card->vlan_id[card->vlan_index]);
> +		vlan_len = GELIC_NET_VLAN_POS + VLAN_HLEN; /* VLAN_HLEN=4 */
> +	} else
> +		vlan_len = GELIC_NET_VLAN_POS; /* no vlan tag */
> +
> +	/* first descr */
> +	buf[0] = dma_map_single(ctodev(card), &descr->vlan,
> +			     vlan_len, DMA_BIDIRECTIONAL);
> +
> +	if (!buf[0]) {
> +		dev_err(ctodev(card),
> +			"dma map 1 failed (%p, %i). Dropping packet\n",
> +			skb->data, vlan_len);
> +		return -ENOMEM;
> +	}
> +
> +	descr->buf_addr = buf[0];
> +	descr->buf_size = vlan_len;
> +	descr->skb = skb; /* not used */
> +	descr->data_status = 0;
> +	gelic_net_set_txdescr_cmdstat(descr, skb, 1); /* not the frame end */
> +
> +	/* second descr */
> +	card->tx_chain.head = card->tx_chain.head->next;
> +	descr->next_descr_addr = descr->next->bus_addr;
> +	descr = descr->next;
> +	if (gelic_net_get_descr_status(descr) != GELIC_NET_DESCR_NOT_IN_USE)
> +		dev_err(ctodev(card),"descr is not free!\n"); /* XXX will be removed */
> +
> +	buf[1] = dma_map_single(ctodev(card), skb->data + GELIC_NET_VLAN_POS,
> +			     skb->len - GELIC_NET_VLAN_POS,
> +			     DMA_BIDIRECTIONAL);
> +
> +	if (!buf[1]) {
> +		dev_err(ctodev(card),
> +			"dma map 2 failed (%p, %i). Dropping packet\n",
> +			skb->data + GELIC_NET_VLAN_POS,
> +			skb->len - GELIC_NET_VLAN_POS);
> +		dma_unmap_single(ctodev(card), buf[0], vlan_len,
> +				 DMA_BIDIRECTIONAL);
> +		return -ENOMEM;
> +	}
> +
> +	descr->buf_addr = buf[1];
> +	descr->buf_size = skb->len - GELIC_NET_VLAN_POS;
> +	descr->skb = skb;
> +	descr->data_status = 0;
> +	descr->next_descr_addr= 0; /* terminate hw descr */
> +	gelic_net_set_txdescr_cmdstat(descr,skb, 0);
> +
> +	return 0;
> +}
> +
> +/**
> + * gelic_net_kick_txdma - enables TX DMA processing
> + * @card: card structure
> + * @descr: descriptor address to enable TX processing at
> + *
> + */
> +static int gelic_net_kick_txdma(struct gelic_net_card *card,
> +				struct gelic_net_descr *descr)
> +{
> +	int status = -ENXIO;
> +	int count = 10;
> +
> +	if (card->tx_dma_progress)
> +		return 0;
> +
> +	if (gelic_net_get_descr_status(descr) == GELIC_NET_DESCR_CARDOWNED) {
> +		card->tx_dma_progress = 1;
> +		/* sometimes we need retry here */
> +		while (count--) {
> +			status = lv1_net_start_tx_dma(bus_id(card),
> +						      dev_id(card),
> +						      descr->bus_addr, 0);
> +			if (!status)
> +				break;
> +		}
> +		if (!count)
> +			dev_info(ctodev(card), "lv1_net_start_txdma failed," \
> +				"status=%d %#lx\n",
> +				 status, card->irq_status);
> +	}
> +	return status;
> +}
> +
> +/**
> + * gelic_net_xmit - transmits a frame over the device
> + * @skb: packet to send out
> + * @netdev: interface device structure
> + *
> + * returns 0 on success, <0 on failure
> + */
> +static int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev)
> +{
> +	struct gelic_net_card *card = netdev_priv(netdev);
> +	struct gelic_net_descr *descr = NULL;
> +	int result;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&card->tx_dma_lock, flags);
> +
> +	gelic_net_release_tx_chain(card, 0);
> +	if (!skb)
> +		goto kick;

skb will never be NULL here


> +	descr = gelic_net_get_next_tx_descr(card);
> +	if (!descr) {
> +		netif_stop_queue(netdev);
> +		spin_unlock_irqrestore(&card->tx_dma_lock, flags);
> +		return NETDEV_TX_BUSY;
> +	}
> +	result = gelic_net_prepare_tx_descr_v(card, descr, skb);
> +
> +	if (result)
> +		goto error;
> +
> +	card->tx_chain.head = card->tx_chain.head->next;
> +
> +	if (descr->prev)
> +		descr->prev->next_descr_addr = descr->bus_addr;
> +kick:
> +	wmb();
> +	if (gelic_net_kick_txdma(card, card->tx_chain.tail))
> +		goto error;
> +
> +	netdev->trans_start = jiffies;
> +	spin_unlock_irqrestore(&card->tx_dma_lock, flags);
> +	return NETDEV_TX_OK;
> +
> +error:
> +	card->netdev_stats.tx_dropped++;
> +	spin_unlock_irqrestore(&card->tx_dma_lock, flags);
> +	return NETDEV_TX_LOCKED;
> +}
> +
> +/**
> + * gelic_net_pass_skb_up - takes an skb from a descriptor and passes it on
> + * @descr: descriptor to process
> + * @card: card structure
> + *
> + * iommu-unmaps the skb, fills out skb structure and passes the data to the
> + * stack. The descriptor state is not changed.
> + */
> +static void gelic_net_pass_skb_up(struct gelic_net_descr *descr,
> +				 struct gelic_net_card *card)
> +{
> +	struct sk_buff *skb;
> +	struct net_device *netdev;
> +	u32 data_status, data_error;
> +
> +	data_status = descr->data_status;
> +	data_error = descr->data_error;
> +	netdev = card->netdev;
> +	/* unmap skb buffer */
> +	skb = descr->skb;
> +	dma_unmap_single(ctodev(card), descr->buf_addr, GELIC_NET_MAX_MTU,
> +			 DMA_BIDIRECTIONAL);

why BIDIRECTIONAL?


> +	skb->dev = netdev;

shouldn't be needed anymore with netdev_alloc_skb()


> +	skb_put(skb, descr->valid_size? descr->valid_size : descr->result_size);
> +	if (!descr->valid_size)
> +		dev_info(ctodev(card), "buffer full %x %x %x\n",
> +			 descr->result_size, descr->buf_size, descr->dmac_cmd_status);
> +
> +	descr->skb = NULL;
> +	/*
> +	 * the card put 2 bytes vlan tag in front
> +	 * of the ethernet frame
> +	 */
> +	skb_pull(skb, 2);
> +	skb->protocol = eth_type_trans(skb, netdev);
> +
> +	/* checksum offload */
> +	if (card->rx_csum) {
> +		if ((data_status & GELIC_NET_DATA_STATUS_CHK_MASK) &&
> +		    (!(data_error & GELIC_NET_DATA_ERROR_CHK_MASK)))
> +			skb->ip_summed = CHECKSUM_UNNECESSARY;
> +		else
> +			skb->ip_summed = CHECKSUM_NONE;
> +	} else
> +		skb->ip_summed = CHECKSUM_NONE;
> +
> +	/* update netdevice statistics */
> +	card->netdev_stats.rx_packets++;
> +	card->netdev_stats.rx_bytes += skb->len;
> +
> +	/* pass skb up to stack */
> +	netif_receive_skb(skb);
> +}
> +
> +/**
> + * gelic_net_decode_one_descr - processes an rx descriptor
> + * @card: card structure
> + *
> + * returns 1 if a packet has been sent to the stack, otherwise 0
> + *
> + * processes an rx descriptor by iommu-unmapping the data buffer and passing
> + * the packet up to the stack
> + */
> +static int gelic_net_decode_one_descr(struct gelic_net_card *card)
> +{
> +	enum gelic_net_descr_status status;
> +	struct gelic_net_descr_chain *chain = &card->rx_chain;
> +	struct gelic_net_descr *descr = chain->tail;
> +	int dmac_chain_ended;
> +
> +	status = gelic_net_get_descr_status(descr);
> +	/* is this descriptor terminated with next_descr == NULL? */
> +	dmac_chain_ended = descr->dmac_cmd_status & GELIC_NET_DMAC_CMDSTAT_RXDCEIS;
> +
> +	if (status == GELIC_NET_DESCR_CARDOWNED) {
> +		return 0;
> +	}

remove all braces around single-line C statements


> +	if (status == GELIC_NET_DESCR_NOT_IN_USE) {
> +		dev_dbg(ctodev(card), "dormant descr? %p\n", descr);
> +		return 0;
> +	}
> +
> +	if ((status == GELIC_NET_DESCR_RESPONSE_ERROR) ||
> +	    (status == GELIC_NET_DESCR_PROTECTION_ERROR) ||
> +	    (status == GELIC_NET_DESCR_FORCE_END)) {
> +		dev_info(ctodev(card), "dropping RX descriptor with state %x\n",
> +			 status);
> +		card->netdev_stats.rx_dropped++;
> +		goto refill;
> +	}
> +
> +	if ((status != GELIC_NET_DESCR_COMPLETE) &&
> +	    (status != GELIC_NET_DESCR_FRAME_END)) {
> +		dev_dbg(ctodev(card), "RX descriptor with state %x\n",
> +			status);
> +		goto refill;
> +	}
> +
> +	/* ok, we've got a packet in descr */
> +	gelic_net_pass_skb_up(descr, card); /* 1: skb_up sccess */
> +
> +refill:
> +	descr->next_descr_addr = 0; /* unlink the descr */
> +
> +	/* change the descriptor state: */
> +	gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
> +
> +	/* refill one desc
> +	 * FIXME: this can fail, but for now, just leave this
> +	 * descriptor without skb
> +	 */
> +	gelic_net_prepare_rx_descr(card, descr);
> +	chain->head = descr;
> +	chain->tail = descr->next;
> +	descr->prev->next_descr_addr = descr->bus_addr;
> +
> +	if (dmac_chain_ended) {
> +		gelic_net_enable_rxdmac(card);
> +		dev_dbg(ctodev(card), "reenable rx dma\n");
> +	}
> +
> +	return 1;
> +}
> +
> +/**
> + * gelic_net_poll - NAPI poll function called by the stack to return packets
> + * @netdev: interface device structure
> + * @budget: number of packets we can pass to the stack at most
> + *
> + * returns 0 if no more packets available to the driver/stack. Returns 1,
> + * if the quota is exceeded, but the driver has still packets.
> + *
> + */
> +static int gelic_net_poll(struct net_device *netdev, int *budget)
> +{
> +	struct gelic_net_card *card = netdev_priv(netdev);
> +	int packets_to_do, packets_done = 0;
> +	int no_more_packets = 0;
> +
> +	packets_to_do = min(*budget, netdev->quota);
> +
> +	while (packets_to_do) {
> +		if (gelic_net_decode_one_descr(card)) {
> +			packets_done++;
> +			packets_to_do--;
> +		} else {
> +			/* no more packets for the stack */
> +			no_more_packets = 1;
> +			break;
> +		}
> +	}
> +	netdev->quota -= packets_done;
> +	*budget -= packets_done;
> +	if (no_more_packets) {
> +		netif_rx_complete(netdev);
> +		gelic_net_rx_irq_on(card);
> +		return 0;
> +	} else
> +		return 1;
> +}
> +
> +/**
> + * gelic_net_get_stats - get interface statistics
> + * @netdev: interface device structure
> + *
> + * returns the interface statistics residing in the gelic_net_card struct
> + */
> +static struct net_device_stats * gelic_net_get_stats(struct net_device *netdev)
> +{
> +	struct gelic_net_card *card = netdev_priv(netdev);
> +
> +	return &card->netdev_stats;
> +}
> +
> +/**
> + * gelic_net_change_mtu - changes the MTU of an interface
> + * @netdev: interface device structure
> + * @new_mtu: new MTU value
> + *
> + * returns 0 on success, <0 on failure
> + */
> +static int gelic_net_change_mtu(struct net_device *netdev, int new_mtu)
> +{
> +	/* no need to re-alloc skbs or so -- the max mtu is about 2.3k
> +	 * and mtu is outbound only anyway */
> +	if ((new_mtu < GELIC_NET_MIN_MTU) ||
> +	    (new_mtu > GELIC_NET_MAX_MTU)) {
> +		return -EINVAL;
> +	}
> +	netdev->mtu = new_mtu;

no RX filter to change?


> +/**
> + * gelic_net_interrupt - event handler for gelic_net
> + */
> +static irqreturn_t gelic_net_interrupt(int irq, void *ptr)
> +{
> +	unsigned long flags;
> +	struct net_device *netdev = ptr;
> +	struct gelic_net_card *card = netdev_priv(netdev);
> +	u64 status;
> +
> +	status = card->irq_status;
> +
> +	if (!status)
> +		return IRQ_NONE;
> +
> +	if (status & GELIC_NET_RXINT) {
> +		gelic_net_rx_irq_off(card);
> +		netif_rx_schedule(netdev);
> +	}
> +
> +	if (status & GELIC_NET_TXINT) {
> +		spin_lock_irqsave(&card->tx_dma_lock, flags);
> +		card->tx_dma_progress = 0;
> +		spin_unlock_irqrestore(&card->tx_dma_lock, flags);
> +		/* start pending DMA */
> +		gelic_net_xmit(NULL, netdev);
> +	}
> +	return IRQ_HANDLED;
> +}
> +
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +/**
> + * gelic_net_poll_controller - artificial interrupt for netconsole etc.
> + * @netdev: interface device structure
> + *
> + * see Documentation/networking/netconsole.txt
> + */
> +static void gelic_net_poll_controller(struct net_device *netdev)
> +{
> +	struct gelic_net_card *card = netdev_priv(netdev);
> +
> +	gelic_net_set_irq_mask(card, 0);
> +	gelic_net_interrupt(netdev->irq, netdev);
> +	gelic_net_set_irq_mask(card, card->ghiintmask);
> +}
> +#endif /* CONFIG_NET_POLL_CONTROLLER */
> +
> +/**
> + * gelic_net_open_device - open device and map dma region
> + * @card: card structure
> + */
> +static int gelic_net_open_device(struct gelic_net_card *card)
> +{
> +	int result;
> +
> +	result = ps3_sb_event_receive_port_setup(card->dev, PS3_BINDING_CPU_ANY,
> +		&card->netdev->irq);
> +
> +	if (result) {
> +		dev_info(ctodev(card),
> +			 "%s:%d: gelic_net_open_device failed (%d)\n",
> +			 __func__, __LINE__, result);
> +		result = -EPERM;
> +		goto fail_alloc_irq;
> +	}
> +
> +	result = request_irq(card->netdev->irq, gelic_net_interrupt, IRQF_DISABLED,
> +		"gelic network", card->netdev);
> +
> +	if (result) {
> +		dev_info(ctodev(card), "%s:%d: request_irq failed (%d)\n",
> +			__func__, __LINE__, result);
> +		goto fail_request_irq;
> +	}
> +
> +	return 0;
