From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH -mm 3/5] Blackfin: on-chip ethernet MAC controller driver
Date: Thu, 01 Mar 2007 07:52:54 -0800
Message-ID: <45E6F6D6.5000804@linux-foundation.org>
References: <1172722514.5264.77.camel@roc-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: bryan.wu@analog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:57642 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965303AbXCAPw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 10:52:56 -0500
In-Reply-To: <1172722514.5264.77.camel@roc-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wu, Bryan wrote:
> Hi folks,
>
> Here is the blackfin on-chip ethernet MAC controller driver for Linux.
>
> It's name is blackfin-driver-net-stamp537.patch
>
> [PATCH] Blackfin: on-chip ethernet MAC controller driver
>
> This patch implements the driver necessary use the Analog Devices
> Blackfin processor's on-chip ethernet MAC controller.
>
> Signed-off-by: Bryan Wu <bryan.wu@analog.com> 
> ---
>
>  drivers/net/Kconfig    |   44 ++
>  drivers/net/Makefile   |    1
>  drivers/net/bfin_mac.c |  988 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/bfin_mac.h |  146 +++++++++
>  4 files changed, 1179 insertions(+)
>
> Index: linux-2.6/drivers/net/Kconfig
> ===================================================================
> --- linux-2.6.orig/drivers/net/Kconfig	2007-03-01 11:39:14.000000000 +0800
> +++ linux-2.6/drivers/net/Kconfig	2007-03-01 11:39:19.000000000 +0800
> @@ -836,6 +836,50 @@
>  	  module, say M here and read <file:Documentation/modules.txt> as well
>  	  as <file:Documentation/networking/net-modules.txt>.
>  
> +config BFIN_MAC
> +	tristate "Blackfin 536/537 on-chip mac support"
> +	depends on NET_ETHERNET && (BF537 || BF536) && (!BF537_PORT_H)
> +	select CRC32
> +	select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
> +	help
> +	  This is the driver for blackfin on-chip mac device. Say Y if you want it
> +	  compiled into the kernel. This driver is also available as a module
> +	  ( = code which can be inserted in and removed from the running kernel
> +	  whenever you want). The module will be called bfin_mac.
> +
> +config BFIN_MAC_USE_L1
> +	bool "Use L1 memory for rx/tx packets"
> +	depends on BFIN_MAC && BF537
> +	default y
> +	help
> +	  To get maximum network performace, you should use L1 memory as rx/tx buffers.
> +	  Say N here if you want to reserve L1 memory for other uses.
> +
> +config BFIN_TX_DESC_NUM
> +	int "Number of transmit buffer packets"
> +	depends on BFIN_MAC
> +	range 6 10 if BFIN_MAC_USE_L1
> +	range 10 100
> +	default "10"
> +	help
> +	  Set the number of buffer packets used in driver.
> +
> +config BFIN_RX_DESC_NUM
> +	int "Number of receive buffer packets"
> +	depends on BFIN_MAC
> +	range 20 100 if BFIN_MAC_USE_L1
> +	range 20 800
> +	default "20"
> +	help
> +	  Set the number of buffer packets used in driver
>   
The regular practice is to put these in a device include file, and not 
make them kernel configurable.
Why would you want to make it tuneable at compile time?
> +
> +config BFIN_MAC_RMII
> +	bool "RMII PHY Interface (EXPERIMENTAL)"
> +	depends on BFIN_MAC && EXPERIMENTAL
> +	default n
> +	help
> +	  Use Reduced PHY MII Interface
> +
>  config SMC9194
>  	tristate "SMC 9194 support"
>  	depends on NET_VENDOR_SMC && (ISA || MAC && BROKEN)
> Index: linux-2.6/drivers/net/Makefile
> ===================================================================
> --- linux-2.6.orig/drivers/net/Makefile	2007-03-01 11:33:24.000000000 +0800
> +++ linux-2.6/drivers/net/Makefile	2007-03-01 11:39:19.000000000 +0800
> @@ -195,6 +195,7 @@
>  obj-$(CONFIG_MYRI10GE) += myri10ge/
>  obj-$(CONFIG_SMC91X) += smc91x.o
>  obj-$(CONFIG_SMC911X) += smc911x.o
> +obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
>  obj-$(CONFIG_DM9000) += dm9000.o
>  obj-$(CONFIG_FEC_8XX) += fec_8xx/
>  obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o
> Index: linux-2.6/drivers/net/bfin_mac.c
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6/drivers/net/bfin_mac.c	2007-03-01 11:39:19.000000000 +0800
> @@ -0,0 +1,988 @@
> +/*
> + * File:         drivers/net/bfin_mac.c
> + * Based on:
> + * Author:       Luke Yang <luke.yang@analog.com>
> + *
> + * Created:
> + * Description:
> + *
> + * Rev:          $Id: bfin_mac.c,v 1.60 2006/12/16 11:23:56 hennerich Exp $
> + *
> + * Modified:
> + *               Copyright 2004-2006 Analog Devices Inc.
> + *
> + * Bugs:         Enter bugs at http://blackfin.uclinux.org/
> + *
> + * This program is free software ;  you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation ;  either version 2, or (at your option)
> + * any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY ;  without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program ;  see the file COPYING.
> + * If not, write to the Free Software Foundation,
> + * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
> + */
> +
> +#include <linux/init.h>
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/sched.h>
> +#include <linux/slab.h>
> +#include <linux/delay.h>
> +#include <linux/timer.h>
> +#include <linux/errno.h>
> +#include <linux/ioport.h>
> +#include <linux/crc32.h>
> +#include <linux/device.h>
> +#include <linux/spinlock.h>
> +#include <linux/ethtool.h>
> +#include <linux/mii.h>
> +
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/skbuff.h>
> +
> +#include <linux/platform_device.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/skbuff.h>
> +
> +#include <asm/io.h>
> +#include <asm/irq.h>
> +#include <asm/dma.h>
> +#include <linux/dma-mapping.h>
> +
> +#include <asm/irq.h>
> +#include <asm/blackfin.h>
> +#include <asm/delay.h>
> +
> +#include "bfin_mac.h"
> +
> +#define CARDNAME "bfin_mac"
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Luke Yang");
> +MODULE_DESCRIPTION("Blackfin MAC Driver");
> +
> +#if defined(CONFIG_BFIN_MAC_USE_L1)
> +# define bfin_mac_alloc(dma_handle, size)  l1_data_sram_zalloc(size)
> +# define bfin_mac_free(dma_handle, ptr)    l1_data_sram_free(ptr)
> +#else
> +# define bfin_mac_alloc(dma_handle, size)  dma_alloc_coherent(NULL, size, dma_handle, GFP_DMA)
> +# define bfin_mac_free(dma_handle, ptr)    dma_free_coherent(NULL, sizeof(*ptr), ptr, dma_handle)
> +#endif
> +
> +#define PKT_BUF_SZ 1580
> +
> +static void desc_list_free(void);
> +
> +/* pointers to maintain transmit list */
> +struct net_dma_desc_tx *tx_list_head;
> +struct net_dma_desc_tx *tx_list_tail;
> +struct net_dma_desc_rx *rx_list_head;
> +struct net_dma_desc_rx *rx_list_tail;
> +struct net_dma_desc_rx *current_rx_ptr;
> +struct net_dma_desc_tx *current_tx_ptr;
> +struct net_dma_desc_tx *tx_desc;
> +struct net_dma_desc_rx *rx_desc;
>   

These should all be static
> +
> +extern void get_bf537_ether_addr(char *addr);
> +
> +static int desc_list_init(void)
> +{
> +	struct net_dma_desc_tx *tmp_desc_tx;
> +	struct net_dma_desc_rx *tmp_desc_rx;
> +	int i;
> +	struct sk_buff *new_skb;
> +#if !defined(CONFIG_BFIN_MAC_USE_L1)
> +	dma_addr_t dma_handle;
> +#endif
> +
> +	tx_desc =
> +	    bfin_mac_alloc(&dma_handle,
> +			   sizeof(struct net_dma_desc_tx) *
> +			   CONFIG_BFIN_TX_DESC_NUM);
> +	if (tx_desc == NULL)
> +		goto init_error;
> +
> +	rx_desc =
> +	    bfin_mac_alloc(&dma_handle,
> +			   sizeof(struct net_dma_desc_rx) *
> +			   CONFIG_BFIN_RX_DESC_NUM);
> +	if (rx_desc == NULL)
> +		goto init_error;
> +
> +	/* init tx_list */
> +	for (i = 0; i < CONFIG_BFIN_TX_DESC_NUM; i++) {
> +
> +		tmp_desc_tx = tx_desc + i;
> +
> +		if (i == 0) {
> +			tx_list_head = tmp_desc_tx;
> +			tx_list_tail = tmp_desc_tx;
> +		}
> +
> +		tmp_desc_tx->desc_a.start_addr =
> +		    (unsigned long)tmp_desc_tx->packet;
> +		tmp_desc_tx->desc_a.x_count = 0;
> +		tmp_desc_tx->desc_a.config.b_DMA_EN = 0;	//disabled
>   
Coding Style for Linux kernel is to *not* use C++ style comments (ie. //)

> +		tmp_desc_tx->desc_a.config.b_WNR = 0;	//read from memory
> +		tmp_desc_tx->desc_a.config.b_WDSIZE = 2;	//wordsize is 32 bits
> +		tmp_desc_tx->desc_a.config.b_NDSIZE = 6;	//6 half words is desc size.
> +		tmp_desc_tx->desc_a.config.b_FLOW = 7;	//large desc flow
> +		tmp_desc_tx->desc_a.next_dma_desc = &(tmp_desc_tx->desc_b);
> +
> +		tmp_desc_tx->desc_b.start_addr =
> +		    (unsigned long)(&(tmp_desc_tx->status));
> +		tmp_desc_tx->desc_b.x_count = 0;
> +		tmp_desc_tx->desc_b.config.b_DMA_EN = 1;	//enabled
> +		tmp_desc_tx->desc_b.config.b_WNR = 1;	//write to memory
> +		tmp_desc_tx->desc_b.config.b_WDSIZE = 2;	//wordsize is 32 bits
> +		tmp_desc_tx->desc_b.config.b_DI_EN = 0;	//disable interrupt
> +		tmp_desc_tx->desc_b.config.b_NDSIZE = 6;
> +		tmp_desc_tx->desc_b.config.b_FLOW = 7;	//stop mode
> +		tmp_desc_tx->skb = NULL;
> +		tx_list_tail->desc_b.next_dma_desc = &(tmp_desc_tx->desc_a);
> +		tx_list_tail->next = tmp_desc_tx;
> +
> +		tx_list_tail = tmp_desc_tx;
> +	}
> +	tx_list_tail->next = tx_list_head;	/* tx_list is a circle */
> +	tx_list_tail->desc_b.next_dma_desc = &(tx_list_head->desc_a);
> +	current_tx_ptr = tx_list_head;
> +
> +	/* init rx_list */
> +	for (i = 0; i < CONFIG_BFIN_RX_DESC_NUM; i++) {
> +
> +		tmp_desc_rx = rx_desc + i;
> +
> +		if (i == 0) {
> +			rx_list_head = tmp_desc_rx;
> +			rx_list_tail = tmp_desc_rx;
> +		}
> +
> +		/* allocat a new skb for next time receive */
> +		new_skb = dev_alloc_skb(PKT_BUF_SZ + 2);
> +		if (!new_skb) {
> +			printk(KERN_NOTICE CARDNAME
> +			       ": init: low on mem - packet dropped\n");
> +			goto init_error;
> +		}
> +		skb_reserve(new_skb, 2);
> +		tmp_desc_rx->skb = new_skb;
> +		/* since RXDWA is enabled */
> +		tmp_desc_rx->desc_a.start_addr =
> +		    (unsigned long)new_skb->data - 2;
> +		tmp_desc_rx->desc_a.x_count = 0;
> +		tmp_desc_rx->desc_a.config.b_DMA_EN = 1;	//enabled
> +		tmp_desc_rx->desc_a.config.b_WNR = 1;	//Write to memory
> +		tmp_desc_rx->desc_a.config.b_WDSIZE = 2;	//wordsize is 32 bits
> +		tmp_desc_rx->desc_a.config.b_NDSIZE = 6;	//6 half words is desc size.
> +		tmp_desc_rx->desc_a.config.b_FLOW = 7;	//large desc flow
> +		tmp_desc_rx->desc_a.next_dma_desc = &(tmp_desc_rx->desc_b);
> +
> +		tmp_desc_rx->desc_b.start_addr =
> +		    (unsigned long)(&(tmp_desc_rx->status));
> +		tmp_desc_rx->desc_b.x_count = 0;
> +		tmp_desc_rx->desc_b.config.b_DMA_EN = 1;	//enabled
> +		tmp_desc_rx->desc_b.config.b_WNR = 1;	//Write to memory
> +		tmp_desc_rx->desc_b.config.b_WDSIZE = 2;	//wordsize is 32 bits
> +		tmp_desc_rx->desc_b.config.b_NDSIZE = 6;
> +		tmp_desc_rx->desc_b.config.b_DI_EN = 1;	//enable interrupt
> +		tmp_desc_rx->desc_b.config.b_FLOW = 7;	//large mode
> +		rx_list_tail->desc_b.next_dma_desc = &(tmp_desc_rx->desc_a);
> +
> +		rx_list_tail->next = tmp_desc_rx;
> +		rx_list_tail = tmp_desc_rx;
> +	}
> +	rx_list_tail->next = rx_list_head;	/* rx_list is a circle */
> +	rx_list_tail->desc_b.next_dma_desc = &(rx_list_head->desc_a);
> +	current_rx_ptr = rx_list_head;
> +
> +	return 0;
> +
> +      init_error:
> +	desc_list_free();
> +	printk(KERN_ERR CARDNAME ": kmalloc failed\n");
> +	return -ENOMEM;
> +}
> +
> +static void desc_list_free(void)
> +{
> +	struct net_dma_desc_rx *tmp_desc_rx;
> +	struct net_dma_desc_tx *tmp_desc_tx;
> +	int i;
> +#if !defined(CONFIG_BFIN_MAC_USE_L1)
> +	dma_addr_t dma_handle = 0;
> +#endif
> +
> +	if (tx_desc != NULL) {
> +		tmp_desc_tx = tx_list_head;
> +		for (i = 0; i < CONFIG_BFIN_TX_DESC_NUM; i++) {
> +			if (tmp_desc_tx != NULL) {
> +				if (tmp_desc_tx->skb) {
> +					dev_kfree_skb(tmp_desc_tx->skb);
> +					tmp_desc_tx->skb = NULL;
> +				}
> +
> +			}
> +			tmp_desc_tx = tmp_desc_tx->next;
> +		}
> +		bfin_mac_free(dma_handle, tx_desc);
> +	}
> +
> +	if (rx_desc != NULL) {
> +		tmp_desc_rx = rx_list_head;
> +		for (i = 0; i < CONFIG_BFIN_RX_DESC_NUM; i++) {
> +			if (tmp_desc_rx != NULL) {
> +				if (tmp_desc_rx->skb) {
> +					dev_kfree_skb(tmp_desc_rx->skb);
> +					tmp_desc_rx->skb = NULL;
> +				}
> +			}
> +			tmp_desc_rx = tmp_desc_rx->next;
> +		}
> +		bfin_mac_free(dma_handle, rx_desc);
> +	}
> +}
> +
> +/*---PHY CONTROL AND CONFIGURATION-----------------------------------------*/
> +
> +//
> +//Set FER regs to MUX in Ethernet pins
> +//
> +
> +static void SetupPinMux(void)
> +{
> +	
Please do not use mixed case for function or structure member names (see 
Coding Style)
