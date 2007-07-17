From: Bryan Wu <bryan.wu@analog.com>
Subject: Re: [PATCH try#6] Blackfin ethernet driver: on chip ethernet MAC
	controller driver
Date: Tue, 17 Jul 2007 14:46:46 +0800
Message-ID: <1184654806.6503.23.camel@roc-desktop>
References: <1184654625.6503.21.camel@roc-desktop>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: michael.hennerich@analog.com, mb@bu3sch.de, vapier.adi@gmail.com,
	jeff@garzik.org, hch@infradead.org, dcbw@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, joe@perches.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:31983 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014AbXGQGkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 02:40:25 -0400
In-Reply-To: <1184654625.6503.21.camel@roc-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff:

Can this driver be merged for 2.6.23-rcN?

Thanks
- Bryan Wu

On Tue, 2007-07-17 at 14:43 +0800, Bryan Wu wrote:
> This patch implements the driver necessary use the Analog Devices
> Blackfin processor's on-chip ethernet MAC controller.
> 
> [try#2]
>  - add timeout control
>  - kill dma_config_reg bitfields
>  - some trivial cleanup
> 
> [try#3]
>  - add endianess check
>  - add DRV_NAME, DRV_VERSION... driver information string
>  - add some comments for silicon anomaly and dma API confusion
>  - some code trivial cleanup
> 
> [try#4]
>  - add Blackfin latest GPIO pin mux opertion with Michael Hennerich's
>   help and Dan's review
>  - rewrite the DMA descriptor list operation in a more readable way
>   by Joe's review
> 
> [try#5]
>  - cleanup some coding style by Joe's review.
> 
> [try#6]
>  - 1.1 version fix a bug when set up multicast list pointed by Mr. yoshfuji
>  - rearrange the desc_list_free function.
> 
> Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
> Signed-off-by: Bryan Wu <bryan.wu@analog.com>
> Cc: Michael Buesch <mb@bu3sch.de>
> Cc: Mike Frysinger <vapier.adi@gmail.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Dan Williams <dcbw@redhat.com>
> Cc: Joe Perches <joe@perches.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> ---
>  MAINTAINERS            |    7 +
>  drivers/net/Kconfig    |   44 +++
>  drivers/net/Makefile   |    1 +
>  drivers/net/bfin_mac.c | 1009 ++++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/bfin_mac.h |  132 +++++++
>  5 files changed, 1193 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/bfin_mac.c
>  create mode 100644 drivers/net/bfin_mac.h
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 3914269..65d5805 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -754,6 +754,13 @@ L:	uclinux-dist-devel@blackfin.uclinux.org (subscribers-only)
>  W:	http://blackfin.uclinux.org
>  S:	Supported
>  
> +BLACKFIN EMAC DRIVER
> +P:	Bryan Wu
> +M:	bryan.wu@analog.com
> +L:	uclinux-dist-devel@blackfin.uclinux.org (subscribers-only)
> +W:	http://blackfin.uclinux.org
> +S:	Supported
> +
>  BLACKFIN RTC DRIVER
>  P:	Mike Frysinger
>  M:	michael.frysinger@analog.com
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index d17d64e..7a3edaf 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -848,6 +848,50 @@ config ULTRA32
>  	  <file:Documentation/networking/net-modules.txt>. The module
>  	  will be called smc-ultra32.
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
> +	  Set the number of buffer packets used in driver.
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
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index c26b867..9e71eb0 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -199,6 +199,7 @@ obj-$(CONFIG_S2IO) += s2io.o
>  obj-$(CONFIG_MYRI10GE) += myri10ge/
>  obj-$(CONFIG_SMC91X) += smc91x.o
>  obj-$(CONFIG_SMC911X) += smc911x.o
> +obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
>  obj-$(CONFIG_DM9000) += dm9000.o
>  obj-$(CONFIG_FEC_8XX) += fec_8xx/
>  obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o
> diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
> new file mode 100644
> index 0000000..9a08d65
> --- /dev/null
> +++ b/drivers/net/bfin_mac.c
> @@ -0,0 +1,1009 @@
> +/*
> + * File:	drivers/net/bfin_mac.c
> + * Based on:
> + * Maintainer:
> + * 		Bryan Wu <bryan.wu@analog.com>
> + *
> + * Original author:
> + * 		Luke Yang <luke.yang@analog.com>
> + *
> + * Created:
> + * Description:
> + *
> + * Modified:
> + *		Copyright 2004-2006 Analog Devices Inc.
> + *
> + * Bugs:	Enter bugs at http://blackfin.uclinux.org/
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
> +#include <linux/irq.h>
> +#include <linux/io.h>
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
> +#include <asm/dma.h>
> +#include <linux/dma-mapping.h>
> +
> +#include <asm/blackfin.h>
> +#include <asm/cacheflush.h>
> +#include <asm/portmux.h>
> +
> +#include "bfin_mac.h"
> +
> +#define DRV_NAME	"bfin_mac"
> +#define DRV_VERSION	"1.1"
> +#define DRV_AUTHOR	"Bryan Wu, Luke Yang"
> +#define DRV_DESC	"Blackfin BF53[67] on-chip Ethernet MAC driver"
> +
> +MODULE_AUTHOR(DRV_AUTHOR);
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION(DRV_DESC);
> +
> +#if defined(CONFIG_BFIN_MAC_USE_L1)
> +# define bfin_mac_alloc(dma_handle, size)  l1_data_sram_zalloc(size)
> +# define bfin_mac_free(dma_handle, ptr)    l1_data_sram_free(ptr)
> +#else
> +# define bfin_mac_alloc(dma_handle, size) \
> +	dma_alloc_coherent(NULL, size, dma_handle, GFP_KERNEL)
> +# define bfin_mac_free(dma_handle, ptr) \
> +	dma_free_coherent(NULL, sizeof(*ptr), ptr, dma_handle)
> +#endif
> +
> +#define PKT_BUF_SZ 1580
> +
> +#define MAX_TIMEOUT_CNT	500
> +
> +/* pointers to maintain transmit list */
> +static struct net_dma_desc_tx *tx_list_head;
> +static struct net_dma_desc_tx *tx_list_tail;
> +static struct net_dma_desc_rx *rx_list_head;
> +static struct net_dma_desc_rx *rx_list_tail;
> +static struct net_dma_desc_rx *current_rx_ptr;
> +static struct net_dma_desc_tx *current_tx_ptr;
> +static struct net_dma_desc_tx *tx_desc;
> +static struct net_dma_desc_rx *rx_desc;
> +
> +static void desc_list_free(void)
> +{
> +	struct net_dma_desc_rx *r;
> +	struct net_dma_desc_tx *t;
> +	int i;
> +#if !defined(CONFIG_BFIN_MAC_USE_L1)
> +	dma_addr_t dma_handle = 0;
> +#endif
> +
> +	if (tx_desc) {
> +		t = tx_list_head;
> +		for (i = 0; i < CONFIG_BFIN_TX_DESC_NUM; i++) {
> +			if (t) {
> +				if (t->skb) {
> +					dev_kfree_skb(t->skb);
> +					t->skb = NULL;
> +				}
> +				t = t->next;
> +			}
> +		}
> +		bfin_mac_free(dma_handle, tx_desc);
> +	}
> +
> +	if (rx_desc) {
> +		r = rx_list_head;
> +		for (i = 0; i < CONFIG_BFIN_RX_DESC_NUM; i++) {
> +			if (r) {
> +				if (r->skb) {
> +					dev_kfree_skb(r->skb);
> +					r->skb = NULL;
> +				}
> +				r = r->next;
> +			}
> +		}
> +		bfin_mac_free(dma_handle, rx_desc);
> +	}
> +}
> +
> +static int desc_list_init(void)
> +{
> +	int i;
> +	struct sk_buff *new_skb;
> +#if !defined(CONFIG_BFIN_MAC_USE_L1)
> +	/*
> +	 * This dma_handle is useless in Blackfin dma_alloc_coherent().
> +	 * The real dma handler is the return value of dma_alloc_coherent().
> +	 */
> +	dma_addr_t dma_handle;
> +#endif
> +
> +	tx_desc = bfin_mac_alloc(&dma_handle,
> +				sizeof(struct net_dma_desc_tx) *
> +				CONFIG_BFIN_TX_DESC_NUM);
> +	if (tx_desc == NULL)
> +		goto init_error;
> +
> +	rx_desc = bfin_mac_alloc(&dma_handle,
> +				sizeof(struct net_dma_desc_rx) *
> +				CONFIG_BFIN_RX_DESC_NUM);
> +	if (rx_desc == NULL)
> +		goto init_error;
> +
> +	/* init tx_list */
> +	tx_list_head = tx_list_tail = tx_desc;
> +
> +	for (i = 0; i < CONFIG_BFIN_TX_DESC_NUM; i++) {
> +		struct net_dma_desc_tx *t = tx_desc + i;
> +		struct dma_descriptor *a = &(t->desc_a);
> +		struct dma_descriptor *b = &(t->desc_b);
> +
> +		/*
> +		 * disable DMA
> +		 * read from memory WNR = 0
> +		 * wordsize is 32 bits
> +		 * 6 half words is desc size
> +		 * large desc flow
> +		 */
> +		a->config = WDSIZE_32 | NDSIZE_6 | DMAFLOW_LARGE;
> +		a->start_addr = (unsigned long)t->packet;
> +		a->x_count = 0;
> +		a->next_dma_desc = b;
> +
> +		/*
> +		 * enabled DMA
> +		 * write to memory WNR = 1
> +		 * wordsize is 32 bits
> +		 * disable interrupt
> +		 * 6 half words is desc size
> +		 * large desc flow
> +		 */
> +		b->config = DMAEN | WNR | WDSIZE_32 | NDSIZE_6 | DMAFLOW_LARGE;
> +		b->start_addr = (unsigned long)(&(t->status));
> +		b->x_count = 0;
> +
> +		t->skb = NULL;
> +		tx_list_tail->desc_b.next_dma_desc = a;
> +		tx_list_tail->next = t;
> +		tx_list_tail = t;
> +	}
> +	tx_list_tail->next = tx_list_head;	/* tx_list is a circle */
> +	tx_list_tail->desc_b.next_dma_desc = &(tx_list_head->desc_a);
> +	current_tx_ptr = tx_list_head;
> +
> +	/* init rx_list */
> +	rx_list_head = rx_list_tail = rx_desc;
> +
> +	for (i = 0; i < CONFIG_BFIN_RX_DESC_NUM; i++) {
> +		struct net_dma_desc_rx *r = rx_desc + i;
> +		struct dma_descriptor *a = &(r->desc_a);
> +		struct dma_descriptor *b = &(r->desc_b);
> +
> +		/* allocate a new skb for next time receive */
> +		new_skb = dev_alloc_skb(PKT_BUF_SZ + 2);
> +		if (!new_skb) {
> +			printk(KERN_NOTICE DRV_NAME
> +			       ": init: low on mem - packet dropped\n");
> +			goto init_error;
> +		}
> +		skb_reserve(new_skb, 2);
> +		r->skb = new_skb;
> +
> +		/*
> +		 * enabled DMA
> +		 * write to memory WNR = 1
> +		 * wordsize is 32 bits
> +		 * disable interrupt
> +		 * 6 half words is desc size
> +		 * large desc flow
> +		 */
> +		a->config = DMAEN | WNR | WDSIZE_32 | NDSIZE_6 | DMAFLOW_LARGE;
> +		/* since RXDWA is enabled */
> +		a->start_addr = (unsigned long)new_skb->data - 2;
> +		a->x_count = 0;
> +		a->next_dma_desc = b;
> +
> +		/*
> +		 * enabled DMA
> +		 * write to memory WNR = 1
> +		 * wordsize is 32 bits
> +		 * enable interrupt
> +		 * 6 half words is desc size
> +		 * large desc flow
> +		 */
> +		b->config = DMAEN | WNR | WDSIZE_32 | DI_EN |
> +				NDSIZE_6 | DMAFLOW_LARGE;
> +		b->start_addr = (unsigned long)(&(r->status));
> +		b->x_count = 0;
> +
> +		rx_list_tail->desc_b.next_dma_desc = a;
> +		rx_list_tail->next = r;
> +		rx_list_tail = r;
> +	}
> +	rx_list_tail->next = rx_list_head;	/* rx_list is a circle */
> +	rx_list_tail->desc_b.next_dma_desc = &(rx_list_head->desc_a);
> +	current_rx_ptr = rx_list_head;
> +
> +	return 0;
> +
> +init_error:
> +	desc_list_free();
> +	printk(KERN_ERR DRV_NAME ": kmalloc failed\n");
> +	return -ENOMEM;
> +}
> +
> +
> +/*---PHY CONTROL AND CONFIGURATION-----------------------------------------*/
> +
> +/* Set FER regs to MUX in Ethernet pins */
> +static int setup_pin_mux(int action)
> +{
> +#if defined(CONFIG_BFIN_MAC_RMII)
> +	u16 pin_req[] = P_RMII0;
> +#else
> +	u16 pin_req[] = P_MII0;
> +#endif
> +
> +	if (action) {
> +		if (peripheral_request_list(pin_req, DRV_NAME)) {
> +			printk(KERN_ERR DRV_NAME
> +			": Requesting Peripherals failed\n");
> +			return -EFAULT;
> +		}
> +	} else
> +		peripheral_free_list(pin_req);
> +
> +	return 0;
> +}
> +
> +/* Wait until the previous MDC/MDIO transaction has completed */
> +static void poll_mdc_done(void)
> +{
> +	int timeout_cnt = MAX_TIMEOUT_CNT;
> +
> +	/* poll the STABUSY bit */
> +	while ((bfin_read_EMAC_STAADD()) & STABUSY) {
> +		mdelay(10);
> +		if (timeout_cnt-- < 0) {
> +			printk(KERN_ERR DRV_NAME
> +			": wait MDC/MDIO transaction to complete timeout\n");
> +			break;
> +		}
> +	}
> +}
> +
> +/* Read an off-chip register in a PHY through the MDC/MDIO port */
> +static u16 read_phy_reg(u16 PHYAddr, u16 RegAddr)
> +{
> +	poll_mdc_done();
> +	/* read mode */
> +	bfin_write_EMAC_STAADD(SET_PHYAD(PHYAddr) |
> +				SET_REGAD(RegAddr) |
> +				STABUSY);
> +	poll_mdc_done();
> +
> +	return (u16) bfin_read_EMAC_STADAT();
> +}
> +
> +/* Write an off-chip register in a PHY through the MDC/MDIO port */
> +static void raw_write_phy_reg(u16 PHYAddr, u16 RegAddr, u32 Data)
> +{
> +	bfin_write_EMAC_STADAT(Data);
> +
> +	/* write mode */
> +	bfin_write_EMAC_STAADD(SET_PHYAD(PHYAddr) |
> +				SET_REGAD(RegAddr) |
> +				STAOP |
> +				STABUSY);
> +
> +	poll_mdc_done();
> +}
> +
> +static void write_phy_reg(u16 PHYAddr, u16 RegAddr, u32 Data)
> +{
> +	poll_mdc_done();
> +	raw_write_phy_reg(PHYAddr, RegAddr, Data);
> +}
> +
> +/* set up the phy */
> +static void bf537mac_setphy(struct net_device *dev)
> +{
> +	u16 phydat;
> +	struct bf537mac_local *lp = netdev_priv(dev);
> +
> +	/* Program PHY registers */
> +	pr_debug("start setting up phy\n");
> +
> +	/* issue a reset */
> +	raw_write_phy_reg(lp->PhyAddr, PHYREG_MODECTL, 0x8000);
> +
> +	/* wait half a second */
> +	msleep(500);
> +
> +	phydat = read_phy_reg(lp->PhyAddr, PHYREG_MODECTL);
> +
> +	/* advertise flow control supported */
> +	phydat = read_phy_reg(lp->PhyAddr, PHYREG_ANAR);
> +	phydat |= (1 << 10);
> +	write_phy_reg(lp->PhyAddr, PHYREG_ANAR, phydat);
> +
> +	phydat = 0;
> +	if (lp->Negotiate)
> +		phydat |= 0x1000;	/* enable auto negotiation */
> +	else {
> +		if (lp->FullDuplex)
> +			phydat |= (1 << 8);	/* full duplex */
> +		else
> +			phydat &= (~(1 << 8));	/* half duplex */
> +
> +		if (!lp->Port10)
> +			phydat |= (1 << 13);	/* 100 Mbps */
> +		else
> +			phydat &= (~(1 << 13));	/* 10 Mbps */
> +	}
> +
> +	if (lp->Loopback)
> +		phydat |= (1 << 14);	/* enable TX->RX loopback */
> +
> +	write_phy_reg(lp->PhyAddr, PHYREG_MODECTL, phydat);
> +	msleep(500);
> +
> +	phydat = read_phy_reg(lp->PhyAddr, PHYREG_MODECTL);
> +	/* check for SMSC PHY */
> +	if ((read_phy_reg(lp->PhyAddr, PHYREG_PHYID1) == 0x7) &&
> +	((read_phy_reg(lp->PhyAddr, PHYREG_PHYID2) & 0xfff0) == 0xC0A0)) {
> +		/*
> +		 * we have SMSC PHY so reqest interrupt
> +		 * on link down condition
> +		 */
> +
> +		/* enable interrupts */
> +		write_phy_reg(lp->PhyAddr, 30, 0x0ff);
> +	}
> +}
> +
> +/**************************************************************************/
> +void setup_system_regs(struct net_device *dev)
> +{
> +	int phyaddr;
> +	unsigned short sysctl, phydat;
> +	u32 opmode;
> +	struct bf537mac_local *lp = netdev_priv(dev);
> +	int count = 0;
> +
> +	phyaddr = lp->PhyAddr;
> +
> +	/* Enable PHY output */
> +	if (!(bfin_read_VR_CTL() & PHYCLKOE))
> +		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
> +
> +	/* MDC  = 2.5 MHz */
> +	sysctl = SET_MDCDIV(24);
> +	/* Odd word alignment for Receive Frame DMA word */
> +	/* Configure checksum support and rcve frame word alignment */
> +#if defined(BFIN_MAC_CSUM_OFFLOAD)
> +	sysctl |= RXDWA | RXCKS;
> +#else
> +	sysctl |= RXDWA;
> +#endif
> +	bfin_write_EMAC_SYSCTL(sysctl);
> +	/* auto negotiation on  */
> +	/* full duplex          */
> +	/* 100 Mbps             */
> +	phydat = PHY_ANEG_EN | PHY_DUPLEX | PHY_SPD_SET;
> +	write_phy_reg(phyaddr, PHYREG_MODECTL, phydat);
> +
> +	/* test if full duplex supported */
> +	do {
> +		msleep(100);
> +		phydat = read_phy_reg(phyaddr, PHYREG_MODESTAT);
> +		if (count > 30) {
> +			printk(KERN_NOTICE DRV_NAME ": Link is down\n");
> +			printk(KERN_NOTICE DRV_NAME
> +				 "please check your network connection\n");
> +			break;
> +		}
> +		count++;
> +	} while (!(phydat & 0x0004));
> +
> +	phydat = read_phy_reg(phyaddr, PHYREG_ANLPAR);
> +
> +	if ((phydat & 0x0100) || (phydat & 0x0040)) {
> +		opmode = FDMODE;
> +	} else {
> +		opmode = 0;
> +		printk(KERN_INFO DRV_NAME
> +			": Network is set to half duplex\n");
> +	}
> +
> +#if defined(CONFIG_BFIN_MAC_RMII)
> +	opmode |= RMII; /* For Now only 100MBit are supported */
> +#endif
> +
> +	bfin_write_EMAC_OPMODE(opmode);
> +
> +	bfin_write_EMAC_MMC_CTL(RSTC | CROLL);
> +
> +	/* Initialize the TX DMA channel registers */
> +	bfin_write_DMA2_X_COUNT(0);
> +	bfin_write_DMA2_X_MODIFY(4);
> +	bfin_write_DMA2_Y_COUNT(0);
> +	bfin_write_DMA2_Y_MODIFY(0);
> +
> +	/* Initialize the RX DMA channel registers */
> +	bfin_write_DMA1_X_COUNT(0);
> +	bfin_write_DMA1_X_MODIFY(4);
> +	bfin_write_DMA1_Y_COUNT(0);
> +	bfin_write_DMA1_Y_MODIFY(0);
> +}
> +
> +void setup_mac_addr(u8 * mac_addr)
> +{
> +	u32 addr_low = le32_to_cpu(*(__le32 *) & mac_addr[0]);
> +	u16 addr_hi = le16_to_cpu(*(__le16 *) & mac_addr[4]);
> +
> +	/* this depends on a little-endian machine */
> +	bfin_write_EMAC_ADDRLO(addr_low);
> +	bfin_write_EMAC_ADDRHI(addr_hi);
> +}
> +
> +static void adjust_tx_list(void)
> +{
> +	int timeout_cnt = MAX_TIMEOUT_CNT;
> +
> +	if (tx_list_head->status.status_word != 0
> +	    && current_tx_ptr != tx_list_head) {
> +		goto adjust_head;	/* released something, just return; */
> +	}
> +
> +	/*
> +	 * if nothing released, check wait condition
> +	 * current's next can not be the head,
> +	 * otherwise the dma will not stop as we want
> +	 */
> +	if (current_tx_ptr->next->next == tx_list_head) {
> +		while (tx_list_head->status.status_word == 0) {
> +			mdelay(10);
> +			if (tx_list_head->status.status_word != 0
> +			    || !(bfin_read_DMA2_IRQ_STATUS() & 0x08)) {
> +				goto adjust_head;
> +			}
> +			if (timeout_cnt-- < 0) {
> +				printk(KERN_ERR DRV_NAME
> +				": wait for adjust tx list head timeout\n");
> +				break;
> +			}
> +		}
> +		if (tx_list_head->status.status_word != 0) {
> +			goto adjust_head;
> +		}
> +	}
> +
> +	return;
> +
> +adjust_head:
> +	do {
> +		tx_list_head->desc_a.config &= ~DMAEN;
> +		tx_list_head->status.status_word = 0;
> +		if (tx_list_head->skb) {
> +			dev_kfree_skb(tx_list_head->skb);
> +			tx_list_head->skb = NULL;
> +		} else {
> +			printk(KERN_ERR DRV_NAME
> +			       ": no sk_buff in a transmitted frame!\n");
> +		}
> +		tx_list_head = tx_list_head->next;
> +	} while (tx_list_head->status.status_word != 0
> +		 && current_tx_ptr != tx_list_head);
> +	return;
> +
> +}
> +
> +static int bf537mac_hard_start_xmit(struct sk_buff *skb,
> +				struct net_device *dev)
> +{
> +	struct bf537mac_local *lp = netdev_priv(dev);
> +	unsigned int data;
> +
> +	current_tx_ptr->skb = skb;
> +
> +	/*
> +	 * Is skb->data always 16-bit aligned?
> +	 * Do we need to memcpy((char *)(tail->packet + 2), skb->data, len)?
> +	 */
> +	if ((((unsigned int)(skb->data)) & 0x02) == 2) {
> +		/* move skb->data to current_tx_ptr payload */
> +		data = (unsigned int)(skb->data) - 2;
> +		*((unsigned short *)data) = (unsigned short)(skb->len);
> +		current_tx_ptr->desc_a.start_addr = (unsigned long)data;
> +		/* this is important! */
> +		blackfin_dcache_flush_range(data, (data + (skb->len)) + 2);
> +
> +	} else {
> +		*((unsigned short *)(current_tx_ptr->packet)) =
> +		    (unsigned short)(skb->len);
> +		memcpy((char *)(current_tx_ptr->packet + 2), skb->data,
> +		       (skb->len));
> +		current_tx_ptr->desc_a.start_addr =
> +		    (unsigned long)current_tx_ptr->packet;
> +		if (current_tx_ptr->status.status_word != 0)
> +			current_tx_ptr->status.status_word = 0;
> +		blackfin_dcache_flush_range((unsigned int)current_tx_ptr->
> +					    packet,
> +					    (unsigned int)(current_tx_ptr->
> +							   packet + skb->len) +
> +					    2);
> +	}
> +
> +	/* enable this packet's dma */
> +	current_tx_ptr->desc_a.config |= DMAEN;
> +
> +	/* tx dma is running, just return */
> +	if (bfin_read_DMA2_IRQ_STATUS() & 0x08)
> +		goto out;
> +
> +	/* tx dma is not running */
> +	bfin_write_DMA2_NEXT_DESC_PTR(&(current_tx_ptr->desc_a));
> +	/* dma enabled, read from memory, size is 6 */
> +	bfin_write_DMA2_CONFIG(current_tx_ptr->desc_a.config);
> +	/* Turn on the EMAC tx */
> +	bfin_write_EMAC_OPMODE(bfin_read_EMAC_OPMODE() | TE);
> +
> +out:
> +	adjust_tx_list();
> +	current_tx_ptr = current_tx_ptr->next;
> +	dev->trans_start = jiffies;
> +	lp->stats.tx_packets++;
> +	lp->stats.tx_bytes += (skb->len);
> +	return 0;
> +}
> +
> +static void bf537mac_rx(struct net_device *dev)
> +{
> +	struct sk_buff *skb, *new_skb;
> +	struct bf537mac_local *lp = netdev_priv(dev);
> +	unsigned short len;
> +
> +	/* allocate a new skb for next time receive */
> +	skb = current_rx_ptr->skb;
> +	new_skb = dev_alloc_skb(PKT_BUF_SZ + 2);
> +	if (!new_skb) {
> +		printk(KERN_NOTICE DRV_NAME
> +		       ": rx: low on mem - packet dropped\n");
> +		lp->stats.rx_dropped++;
> +		goto out;
> +	}
> +	/* reserve 2 bytes for RXDWA padding */
> +	skb_reserve(new_skb, 2);
> +	current_rx_ptr->skb = new_skb;
> +	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
> +
> +	len = (unsigned short)((current_rx_ptr->status.status_word) & RX_FRLEN);
> +	skb_put(skb, len);
> +	blackfin_dcache_invalidate_range((unsigned long)skb->head,
> +					 (unsigned long)skb->tail);
> +
> +	dev->last_rx = jiffies;
> +	skb->dev = dev;
> +	skb->protocol = eth_type_trans(skb, dev);
> +#if defined(BFIN_MAC_CSUM_OFFLOAD)
> +	skb->csum = current_rx_ptr->status.ip_payload_csum;
> +	skb->ip_summed = CHECKSUM_PARTIAL;
> +#endif
> +
> +	netif_rx(skb);
> +	lp->stats.rx_packets++;
> +	lp->stats.rx_bytes += len;
> +	current_rx_ptr->status.status_word = 0x00000000;
> +	current_rx_ptr = current_rx_ptr->next;
> +
> +out:
> +	return;
> +}
> +
> +/* interrupt routine to handle rx and error signal */
> +static irqreturn_t bf537mac_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *dev = dev_id;
> +	int number = 0;
> +
> +get_one_packet:
> +	if (current_rx_ptr->status.status_word == 0) {
> +		/* no more new packet received */
> +		if (number == 0) {
> +			if (current_rx_ptr->next->status.status_word != 0) {
> +				current_rx_ptr = current_rx_ptr->next;
> +				goto real_rx;
> +			}
> +		}
> +		bfin_write_DMA1_IRQ_STATUS(bfin_read_DMA1_IRQ_STATUS() |
> +					   DMA_DONE | DMA_ERR);
> +		return IRQ_HANDLED;
> +	}
> +
> +real_rx:
> +	bf537mac_rx(dev);
> +	number++;
> +	goto get_one_packet;
> +}
> +
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void bf537mac_poll(struct net_device *dev)
> +{
> +	disable_irq(IRQ_MAC_RX);
> +	bf537mac_interrupt(IRQ_MAC_RX, dev);
> +	enable_irq(IRQ_MAC_RX);
> +}
> +#endif				/* CONFIG_NET_POLL_CONTROLLER */
> +
> +static void bf537mac_reset(void)
> +{
> +	unsigned int opmode;
> +
> +	opmode = bfin_read_EMAC_OPMODE();
> +	opmode &= (~RE);
> +	opmode &= (~TE);
> +	/* Turn off the EMAC */
> +	bfin_write_EMAC_OPMODE(opmode);
> +}
> +
> +/*
> + * Enable Interrupts, Receive, and Transmit
> + */
> +static int bf537mac_enable(struct net_device *dev)
> +{
> +	u32 opmode;
> +
> +	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
> +
> +	/* Set RX DMA */
> +	bfin_write_DMA1_NEXT_DESC_PTR(&(rx_list_head->desc_a));
> +	bfin_write_DMA1_CONFIG(rx_list_head->desc_a.config);
> +
> +	/* Wait MII done */
> +	poll_mdc_done();
> +
> +	/* We enable only RX here */
> +	/* ASTP   : Enable Automatic Pad Stripping
> +	   PR     : Promiscuous Mode for test
> +	   PSF    : Receive frames with total length less than 64 bytes.
> +	   FDMODE : Full Duplex Mode
> +	   LB     : Internal Loopback for test
> +	   RE     : Receiver Enable */
> +	opmode = bfin_read_EMAC_OPMODE();
> +	if (opmode & FDMODE)
> +		opmode |= PSF;
> +	else
> +		opmode |= DRO | DC | PSF;
> +	opmode |= RE;
> +
> +#if defined(CONFIG_BFIN_MAC_RMII)
> +	opmode |= RMII; /* For Now only 100MBit are supported */
> +#ifdef CONFIG_BF_REV_0_2
> +	opmode |= TE;
> +#endif
> +#endif
> +	/* Turn on the EMAC rx */
> +	bfin_write_EMAC_OPMODE(opmode);
> +
> +	return 0;
> +}
> +
> +/* Our watchdog timed out. Called by the networking layer */
> +static void bf537mac_timeout(struct net_device *dev)
> +{
> +	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
> +
> +	bf537mac_reset();
> +
> +	/* reset tx queue */
> +	tx_list_tail = tx_list_head->next;
> +
> +	bf537mac_enable(dev);
> +
> +	/* We can accept TX packets again */
> +	dev->trans_start = jiffies;
> +	netif_wake_queue(dev);
> +}
> +
> +/*
> + * Get the current statistics.
> + * This may be called with the card open or closed.
> + */
> +static struct net_device_stats *bf537mac_query_statistics(struct net_device
> +							  *dev)
> +{
> +	struct bf537mac_local *lp = netdev_priv(dev);
> +
> +	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
> +
> +	return &lp->stats;
> +}
> +
> +/*
> + * This routine will, depending on the values passed to it,
> + * either make it accept multicast packets, go into
> + * promiscuous mode (for TCPDUMP and cousins) or accept
> + * a select set of multicast packets
> + */
> +static void bf537mac_set_multicast_list(struct net_device *dev)
> +{
> +	u32 sysctl;
> +
> +	if (dev->flags & IFF_PROMISC) {
> +		printk(KERN_INFO "%s: set to promisc mode\n", dev->name);
> +		sysctl = bfin_read_EMAC_OPMODE();
> +		sysctl |= RAF;
> +		bfin_write_EMAC_OPMODE(sysctl);
> +	} else if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
> +		/* accept all multicast */
> +		sysctl = bfin_read_EMAC_OPMODE();
> +		sysctl |= PAM;
> +		bfin_write_EMAC_OPMODE(sysctl);
> +	} else {
> +		/* clear promisc or multicast mode */
> +		sysctl = bfin_read_EMAC_OPMODE();
> +		sysctl &= ~(RAF | PAM);
> +		bfin_write_EMAC_OPMODE(sysctl);
> +	}
> +}
> +
> +/*
> + * this puts the device in an inactive state
> + */
> +static void bf537mac_shutdown(struct net_device *dev)
> +{
> +	/* Turn off the EMAC */
> +	bfin_write_EMAC_OPMODE(0x00000000);
> +	/* Turn off the EMAC RX DMA */
> +	bfin_write_DMA1_CONFIG(0x0000);
> +	bfin_write_DMA2_CONFIG(0x0000);
> +}
> +
> +/*
> + * Open and Initialize the interface
> + *
> + * Set up everything, reset the card, etc..
> + */
> +static int bf537mac_open(struct net_device *dev)
> +{
> +	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
> +
> +	/*
> +	 * Check that the address is valid.  If its not, refuse
> +	 * to bring the device up.  The user must specify an
> +	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
> +	 */
> +	if (!is_valid_ether_addr(dev->dev_addr)) {
> +		printk(KERN_WARNING DRV_NAME ": no valid ethernet hw addr\n");
> +		return -EINVAL;
> +	}
> +
> +	/* initial rx and tx list */
> +	desc_list_init();
> +
> +	bf537mac_setphy(dev);
> +	setup_system_regs(dev);
> +	bf537mac_reset();
> +	bf537mac_enable(dev);
> +
> +	pr_debug("hardware init finished\n");
> +	netif_start_queue(dev);
> +	netif_carrier_on(dev);
> +
> +	return 0;
> +}
> +
> +/*
> + *
> + * this makes the board clean up everything that it can
> + * and not talk to the outside world.   Caused by
> + * an 'ifconfig ethX down'
> + */
> +static int bf537mac_close(struct net_device *dev)
> +{
> +	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
> +
> +	netif_stop_queue(dev);
> +	netif_carrier_off(dev);
> +
> +	/* clear everything */
> +	bf537mac_shutdown(dev);
> +
> +	/* free the rx/tx buffers */
> +	desc_list_free();
> +
> +	return 0;
> +}
> +
> +static int __init bf537mac_probe(struct net_device *dev)
> +{
> +	struct bf537mac_local *lp = netdev_priv(dev);
> +	int retval;
> +
> +	/* Grab the MAC address in the MAC */
> +	*(__le32 *) (&(dev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
> +	*(__le16 *) (&(dev->dev_addr[4])) = cpu_to_le16((u16) bfin_read_EMAC_ADDRHI());
> +
> +	/* probe mac */
> +	/*todo: how to proble? which is revision_register */
> +	bfin_write_EMAC_ADDRLO(0x12345678);
> +	if (bfin_read_EMAC_ADDRLO() != 0x12345678) {
> +		pr_debug("can't detect bf537 mac!\n");
> +		retval = -ENODEV;
> +		goto err_out;
> +	}
> +
> +	/* set the GPIO pins to Ethernet mode */
> +	retval = setup_pin_mux(1);
> +
> +	if (retval)
> +		return retval;
> +
> +	/*Is it valid? (Did bootloader initialize it?) */
> +	if (!is_valid_ether_addr(dev->dev_addr)) {
> +		/* Grab the MAC from the board somehow - this is done in the
> +		   arch/blackfin/mach-bf537/boards/eth_mac.c */
> +		get_bf537_ether_addr(dev->dev_addr);
> +	}
> +
> +	/* If still not valid, get a random one */
> +	if (!is_valid_ether_addr(dev->dev_addr)) {
> +		random_ether_addr(dev->dev_addr);
> +	}
> +
> +	setup_mac_addr(dev->dev_addr);
> +
> +	/* Fill in the fields of the device structure with ethernet values. */
> +	ether_setup(dev);
> +
> +	dev->open = bf537mac_open;
> +	dev->stop = bf537mac_close;
> +	dev->hard_start_xmit = bf537mac_hard_start_xmit;
> +	dev->tx_timeout = bf537mac_timeout;
> +	dev->get_stats = bf537mac_query_statistics;
> +	dev->set_multicast_list = bf537mac_set_multicast_list;
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	dev->poll_controller = bf537mac_poll;
> +#endif
> +
> +	/* fill in some of the fields */
> +	lp->version = 1;
> +	lp->PhyAddr = 0x01;
> +	lp->CLKIN = 25;
> +	lp->FullDuplex = 0;
> +	lp->Negotiate = 1;
> +	lp->FlowControl = 0;
> +	spin_lock_init(&lp->lock);
> +
> +	/* now, enable interrupts */
> +	/* register irq handler */
> +	if (request_irq
> +	    (IRQ_MAC_RX, bf537mac_interrupt, IRQF_DISABLED | IRQF_SHARED,
> +	     "BFIN537_MAC_RX", dev)) {
> +		printk(KERN_WARNING DRV_NAME
> +		       ": Unable to attach BlackFin MAC RX interrupt\n");
> +		return -EBUSY;
> +	}
> +
> +	/* Enable PHY output early */
> +	if (!(bfin_read_VR_CTL() & PHYCLKOE))
> +		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
> +
> +	retval = register_netdev(dev);
> +	if (retval == 0) {
> +		/* now, print out the card info, in a short format.. */
> +		printk(KERN_INFO "%s: Version %s, %s\n",
> +			 DRV_NAME, DRV_VERSION, DRV_DESC);
> +	}
> +
> +err_out:
> +	return retval;
> +}
> +
> +static int bfin_mac_probe(struct platform_device *pdev)
> +{
> +	struct net_device *ndev;
> +
> +	ndev = alloc_etherdev(sizeof(struct bf537mac_local));
> +	if (!ndev) {
> +		printk(KERN_WARNING DRV_NAME ": could not allocate device\n");
> +		return -ENOMEM;
> +	}
> +
> +	SET_MODULE_OWNER(ndev);
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +
> +	platform_set_drvdata(pdev, ndev);
> +
> +	if (bf537mac_probe(ndev) != 0) {
> +		platform_set_drvdata(pdev, NULL);
> +		free_netdev(ndev);
> +		printk(KERN_WARNING DRV_NAME ": not found\n");
> +		return -ENODEV;
> +	}
> +
> +	return 0;
> +}
> +
> +static int bfin_mac_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +
> +	platform_set_drvdata(pdev, NULL);
> +
> +	unregister_netdev(ndev);
> +
> +	free_irq(IRQ_MAC_RX, ndev);
> +
> +	free_netdev(ndev);
> +
> +	setup_pin_mux(0);
> +
> +	return 0;
> +}
> +
> +static int bfin_mac_suspend(struct platform_device *pdev, pm_message_t state)
> +{
> +	return 0;
> +}
> +
> +static int bfin_mac_resume(struct platform_device *pdev)
> +{
> +	return 0;
> +}
> +
> +static struct platform_driver bfin_mac_driver = {
> +	.probe = bfin_mac_probe,
> +	.remove = bfin_mac_remove,
> +	.resume = bfin_mac_resume,
> +	.suspend = bfin_mac_suspend,
> +	.driver = {
> +		   .name = DRV_NAME,
> +		   },
> +};
> +
> +static int __init bfin_mac_init(void)
> +{
> +	return platform_driver_register(&bfin_mac_driver);
> +}
> +
> +module_init(bfin_mac_init);
> +
> +static void __exit bfin_mac_cleanup(void)
> +{
> +	platform_driver_unregister(&bfin_mac_driver);
> +}
> +
> +module_exit(bfin_mac_cleanup);
> diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
> new file mode 100644
> index 0000000..af87189
> --- /dev/null
> +++ b/drivers/net/bfin_mac.h
> @@ -0,0 +1,132 @@
> +/*
> + * File:	drivers/net/bfin_mac.c
> + * Based on:
> + * Maintainer:
> + * 		Bryan Wu <bryan.wu@analog.com>
> + *
> + * Original author:
> + * 		Luke Yang <luke.yang@analog.com>
> + *
> + * Created:
> + * Description:
> + *
> + * Modified:
> + *		Copyright 2004-2006 Analog Devices Inc.
> + *
> + * Bugs:	Enter bugs at http://blackfin.uclinux.org/
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
> +/*
> + * PHY REGISTER NAMES
> + */
> +#define PHYREG_MODECTL		0x0000
> +#define PHYREG_MODESTAT		0x0001
> +#define PHYREG_PHYID1		0x0002
> +#define PHYREG_PHYID2		0x0003
> +#define PHYREG_ANAR		0x0004
> +#define PHYREG_ANLPAR		0x0005
> +#define PHYREG_ANER		0x0006
> +#define PHYREG_NSR		0x0010
> +#define PHYREG_LBREMR		0x0011
> +#define PHYREG_REC		0x0012
> +#define PHYREG_10CFG		0x0013
> +#define PHYREG_PHY1_1		0x0014
> +#define PHYREG_PHY1_2		0x0015
> +#define PHYREG_PHY2		0x0016
> +#define PHYREG_TW_1		0x0017
> +#define PHYREG_TW_2		0x0018
> +#define PHYREG_TEST		0x0019
> +
> +#define PHY_RESET		0x8000
> +#define PHY_ANEG_EN		0x1000
> +#define PHY_DUPLEX		0x0100
> +#define PHY_SPD_SET		0x2000
> +
> +#define BFIN_MAC_CSUM_OFFLOAD
> +
> +struct dma_descriptor {
> +	struct dma_descriptor *next_dma_desc;
> +	unsigned long start_addr;
> +	unsigned short config;
> +	unsigned short x_count;
> +};
> +
> +struct status_area_rx {
> +#if defined(BFIN_MAC_CSUM_OFFLOAD)
> +	unsigned short ip_hdr_csum;	/* ip header checksum */
> +	/* ip payload(udp or tcp or others) checksum */
> +	unsigned short ip_payload_csum;
> +#endif
> +	unsigned long status_word;	/* the frame status word */
> +};
> +
> +struct status_area_tx {
> +	unsigned long status_word;	/* the frame status word */
> +};
> +
> +/* use two descriptors for a packet */
> +struct net_dma_desc_rx {
> +	struct net_dma_desc_rx *next;
> +	struct sk_buff *skb;
> +	struct dma_descriptor desc_a;
> +	struct dma_descriptor desc_b;
> +	struct status_area_rx status;
> +};
> +
> +/* use two descriptors for a packet */
> +struct net_dma_desc_tx {
> +	struct net_dma_desc_tx *next;
> +	struct sk_buff *skb;
> +	struct dma_descriptor desc_a;
> +	struct dma_descriptor desc_b;
> +	unsigned char packet[1560];
> +	struct status_area_tx status;
> +};
> +
> +struct bf537mac_local {
> +	/*
> +	 * these are things that the kernel wants me to keep, so users
> +	 * can find out semi-useless statistics of how well the card is
> +	 * performing
> +	 */
> +	struct net_device_stats stats;
> +
> +	int version;
> +
> +	int FlowEnabled;	/* record if data flow is active */
> +	int EtherIntIVG;	/* IVG for the ethernet interrupt */
> +	int RXIVG;		/* IVG for the RX completion */
> +	int TXIVG;		/* IVG for the TX completion */
> +	int PhyAddr;		/* PHY address */
> +	int OpMode;		/* set these bits n the OPMODE regs */
> +	int Port10;		/* set port speed to 10 Mbit/s */
> +	int GenChksums;		/* IP checksums to be calculated */
> +	int NoRcveLnth;		/* dont insert recv length at start of buffer */
> +	int StripPads;		/* remove trailing pad bytes */
> +	int FullDuplex;		/* set full duplex mode */
> +	int Negotiate;		/* enable auto negotiation */
> +	int Loopback;		/* loopback at the PHY */
> +	int Cache;		/* Buffers may be cached */
> +	int FlowControl;	/* flow control active */
> +	int CLKIN;		/* clock in value in MHZ */
> +	unsigned short IntMask;	/* interrupt mask */
> +	unsigned char Mac[6];	/* MAC address of the board */
> +	spinlock_t lock;
> +};
> +
> +extern void get_bf537_ether_addr(char *addr);
