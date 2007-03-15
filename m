From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Tehuti Networks 10GbE Support
Date: Thu, 15 Mar 2007 11:13:07 -0400
Message-ID: <45F96283.4080208@garzik.org>
References: <20070315140246.GA24146@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nadav@tehutinetworks.net,
	baum@tehutinetworks.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50296 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422874AbXCOPNM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 11:13:12 -0400
In-Reply-To: <20070315140246.GA24146@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:
> 
> This patch adds support for 10GbE cards from Tehuti Networks.
> 
> Support for suspend/resume isn't included yet, but that work is
> underway.
> 
> It should apply cleanly against netdev-2.6#upstream.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Alexander Indenbaum <baum@tehutinetworks.net>
> Signed-off-by: Nadav Shemer <nadav@tehutinetworks.net>
> ---
> 
>  MAINTAINERS                      |    8 
>  drivers/net/Kconfig              |    6 
>  drivers/net/Makefile             |    1 
>  drivers/net/tehuti/Makefile      |    4 
>  drivers/net/tehuti/bdx.h         |  695 ++
>  drivers/net/tehuti/bdx_ethtool.c |  283 +
>  drivers/net/tehuti/bdx_fw_ta3.h  |10702 +++++++++++++++++++++++++++++++++++++++
>  drivers/net/tehuti/bdx_main.c    | 1228 ++++
>  drivers/net/tehuti/bdx_rx.c      |  578 ++
>  drivers/net/tehuti/bdx_tx.c      |  588 ++
>  drivers/net/tehuti/dbg.h         |   35 
>  drivers/net/tehuti/lxr_regs.h    |  449 +
>  include/linux/pci_ids.h          |    5 
>  13 files changed, 14582 insertions(+)


AFAICS this is small enough to be

	tehuti.c
	tehuti.h
	tehuti_fw.h



> diff --git a/MAINTAINERS b/MAINTAINERS
> index 97341c0..b17ee5d 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -3117,6 +3117,14 @@ P:	Mark Gross
>  M:	mark.gross@intel.com
>  S:	Supported
>  
> +TEHUTI 10GbE DRIVER 
> +P:	Alexander Indenbaum
> +M:	baum@tehutinetworks.net
> +P:	Andy Gospodarek
> +M:	andy@greyhouse.net
> +L:	netdev@vger.kernel.org
> +S:	Supported
> +
>  TENSILICA XTENSA PORT (xtensa):
>  P:	Chris Zankel
>  M:	chris@zankel.net
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 52d7239..2965644 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2493,6 +2493,12 @@ config PASEMI_MAC
>  	  This driver supports the on-chip 1/10Gbit Ethernet controller on
>  	  PA Semi's PWRficient line of chips.
>  
> +config TEHUTI
> +	tristate "Tehuti Networks 10G Ethernet"
> +	depends on PCI
> +	help
> +	  Tehuti Networks 10G Ethernet
> +
>  endmenu
>  
>  source "drivers/net/tokenring/Kconfig"
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 33af833..863fb77 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -5,6 +5,7 @@
>  obj-$(CONFIG_E1000) += e1000/
>  obj-$(CONFIG_IBM_EMAC) += ibm_emac/
>  obj-$(CONFIG_IXGB) += ixgb/
> +obj-$(CONFIG_TEHUTI) += tehuti/
>  obj-$(CONFIG_CHELSIO_T1) += chelsio/
>  obj-$(CONFIG_CHELSIO_T3) += cxgb3/
>  obj-$(CONFIG_EHEA) += ehea/
> diff --git a/drivers/net/tehuti/Makefile b/drivers/net/tehuti/Makefile
> new file mode 100644
> index 0000000..d3b010a
> --- /dev/null
> +++ b/drivers/net/tehuti/Makefile
> @@ -0,0 +1,4 @@
> +
> +obj-$(CONFIG_TEHUTI) += tehuti.o
> +
> +tehuti-objs := bdx_main.o bdx_rx.o bdx_tx.o bdx_ethtool.o
> diff --git a/drivers/net/tehuti/bdx.h b/drivers/net/tehuti/bdx.h
> new file mode 100644
> index 0000000..74304fb
> --- /dev/null
> +++ b/drivers/net/tehuti/bdx.h
> @@ -0,0 +1,695 @@
> +/* 
> + * Tehuti Networks(R) Network Driver 
> + * Copyright (C) 2007 Tehuti Networks Ltd. All rights reserved 
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#ifndef _BDX__H
> +#define _BDX__H

add a namespace to this symbol.  something like __LINUX_NET_TEHUTI_H__


> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/pci.h>
> +#include <linux/delay.h>
> +#include <linux/ethtool.h>
> +#include <linux/mii.h>
> +#include <linux/crc32.h>
> +#include <asm/uaccess.h>
> +#include <linux/in.h>
> +#include <linux/ip.h>
> +#include <linux/tcp.h>
> +#include <linux/sched.h>
> +#include <linux/tty.h>
> +#include <linux/if_vlan.h>
> +#include <linux/version.h>
> +
> +#include "lxr_regs.h"
> +
> +/* Compile Time Switches */
> +#define BDX_NAPI
> +#define BDX_VLAN
> +#define BDX_TSO
> +#define BDX_LLTX
> +/*#define BDX_MSI*/
> +/* End of Compile Time Switches */
> +
> +#if !defined HAVE_NETDEV_POLL
> +#   undef BDX_NAPI
> +#endif
> +#if !defined(NETIF_F_HW_VLAN_TX)
> +#   undef BDX_VLAN
> +#endif
> +#if !defined(NETIF_F_TSO)
> +#   undef BDX_TSO
> +#endif
> +#if !defined(NETIF_F_LLTX)
> +#   undef BDX_LLTX
> +#endif
> +#if !defined CONFIG_PCI_MSI
> +#   undef BDX_MSI
> +#endif
> +
> +#define DELAY_WPTR
> +
> +#define DRIVER_AUTHOR     "Tehuti Networks(R)"
> +#define BDX_DRV_DESC      "Tehuti Networks(R) Network Driver"
> +#define BDX_DRV_NAME      "tehuti"
> +#define BDX_NIC_NAME      "Tehuti 10 Giga TOE SmartNIC"
> +#define BDX_NIC2PORT_NAME "Tehuti 2-Port 10 Giga TOE SmartNIC"
> +#define BDX_DRV_VERSION   "7.27.1"
> +
> +#ifdef BDX_VLAN
> +#    define BDX_VLAN_STRING "hw_vlan "
> +#else
> +#    define BDX_VLAN_STRING ""
> +#endif
> +
> +#ifdef BDX_TSO
> +#    define BDX_TSO_STRING "hw_tso "
> +#else
> +#    define BDX_TSO_STRING ""
> +#endif
> +
> +#ifdef BDX_NAPI
> +#    define BDX_NAPI_STRING "napi "
> +#else
> +#    define BDX_NAPI_STRING ""
> +#endif
> +
> +#ifdef BDX_MSI
> +#    define BDX_MSI_STRING "msi "
> +#else
> +#    define BDX_MSI_STRING ""
> +#endif
> +
> +#define BDX_MIN_MTU  60		/* TODO: allow lower,  but pad */
> +#define BDX_MAX_MTU  0x6500
> +#define PKT_BUF_SZ   1536	/* Size of each temporary Rx buffer. */
> +
> +#define BDX_VENDOR_ID     0x1374
> +#define BDX_DEV_ID	  0x1d
> +#define BDX_REGS_SIZE	  0x384
> +
> +/* netdev tx queue len for Luxor. default value is, btw, 1000
> + * ifcontig eth1 txqueuelen 3000 - to change it at runtime */
> +#define BDX_NDEV_TXQ_LEN 3000
> +
> +#define bitCLKPL_RSTEND  3
> +#define FIFO_SIZE  4096
> +#define BDX_ACC_BUFFER_SIZE 0x6500
> +
> +#define BDX_REGS_VER		1	/* version 1 */
> +#define TX_DESC_NUM   (FIFO_SIZE/16)	/* about 50% more Dscr then fifo */
> +
> +#define TXF_WPTR_MASK 0x7ff0	/* last 4 bits are dropped - size is rounded to 16 */
> +
> +#define MIN(x,y)  (  (x) < (y) ? (x) : (y) )
> +
> +#if BITS_PER_LONG == 64
> +#    define H32_64(x)  (u32) ((u64)(x) >> 32)
> +#    define L32_64(x)  (u32) ((u64)(x) & 0xffffffff)
> +#elif BITS_PER_LONG == 32
> +#    define H32_64(x)  0
> +#    define L32_64(x)  ((u32) (x))
> +#else				/* BITS_PER_LONG == ?? */
> +#    error BITS_PER_LONG is undefined. Must be 64 or 32
> +#endif				/* BITS_PER_LONG */
> +
> +#define INVALID_PTR 3
> +
> +#define RX_OFFSET		2
> +#define MAX_HTB_DESC_SIZE 208
> +#define MAX_HTB_DATA_SIZE (208-16)
> +#define MAX_HTB_TBL_SIZE 512
> +
> +/* 
> + *   In case of NAPI vlan_hwaccel_receive_skb() and netif_receive_skb() 
> + *   should be used instead of vlan_hwaccel_rx() and netif_rx().
> + *   See example at e1000_main.c:2360
> + */
> +#ifdef BDX_NAPI
> +#    define BDX_VLAN_HWACCEL_RX vlan_hwaccel_receive_skb
> +#    define BDX_NETIF_RX        netif_receive_skb
> +#    define BDX_VLAN_WITH_NAPI  1
> +#else
> +#    define BDX_VLAN_HWACCEL_RX vlan_hwaccel_rx
> +#    define BDX_NETIF_RX        netif_rx
> +#    define BDX_VLAN_WITH_NAPI  0
> +#endif
> +
> +#ifndef IRQ_HANDLED
> +#   define irqreturn_t void
> +#   define IRQ_HANDLED
> +#   define IRQ_NONE
> +#endif
> +
> +#ifndef DMA_64BIT_MASK
> +#   define DMA_64BIT_MASK  0xffffffffffffffffULL
> +#endif
> +
> +#ifndef DMA_32BIT_MASK
> +#   define DMA_32BIT_MASK  0x00000000ffffffffULL
> +#endif
> +
> +#ifndef NET_IP_ALIGN
> +#   define NET_IP_ALIGN 2
> +#endif
> +
> +#ifndef NETDEV_TX_OK
> +#   define NETDEV_TX_OK 0
> +#endif


> +/* typedef irqreturn_t (*irq_handler)(int, void *, struct pt_regs *); */

kill all this compat crap


> +#define LUXOR_MAX_PORT    2
> +
> +typedef struct {
> +	int port_num;
> +	void *regs;
> +	struct _bdx_priv *priv[LUXOR_MAX_PORT];
> +} pci_nic;
> +
> +enum { IRQ_INTX, IRQ_MSI, IRQ_MSIX };
> +
> +#define PCK_TH_MULT   128
> +#define INT_COAL_MULT 2
> +typedef union {
> +	struct {
> +		u32 int_coal:15,	/* Interrupt Coalescing Timer */
> +		 int_coal_rc:1,	/* Interrupt Coalescing Timer Recharge */
> +		 rxf_th:4,	/* RX_FREE Interrupt Request Threshold */
> +		 pck_th:4,	/* Packet Count Threshold */
> +		 rsrv:8;	/* Reserved */
> +	} bits;
> +	u32 val;
> +} rdintcm_reg;
> +
> +typedef union {
> +	struct {
> +		u32 int_coal:15,	/* Interrupt Coalescing Timer */
> +		 int_coal_rc:1,	/* Interrupt Coalescing Timer Recharge */
> +		 rsrv0:4,	/* Reserved */
> +		 pck_th:4,	/* Packet Count Threshold */
> +		 rsrv1:8;	/* Reserved */
> +	} bits;
> +	u32 val;
> +} tdintcm_reg;
> +
> +typedef struct SMacLList {
> +	struct SMacLList *next;
> +	u64 macAddr;
> +} TMacLList;
> +
> +typedef struct {
> +	u32 bc:5,		/* Buffer Count - Descriptor length in LWORDs */
> +				/* including optional data. */
> +	 rsrv0:11,		/* Reserved - must be 0. */
> +	 type:4,		/* Type - Internal Descriptor, must be 0xF */
> +	 rsrv1:12;		/* Reserved - must be 0. */
> +
> +	u32 cmd_addr:15,	/* Command Address - must be 0. */
> +	 rsrv3:1,		/* Reserved - must be 0. */
> +	 vint:4,		/* Veneto Interrupt - must be 0 (jump). */
> +	 s_cmd:4,		/* Search machine command - must be IDLE = 7. */
> +	 rsrvd2:8;		/* Reserved - must be 0. */
> +
> +	u32 s_type:16,		/* Service Type - must be 0. */
> +	 len:16;		/* Length - Data length in bytes (starting at byte 16). */
> +
> +	u32 taddr;		/* Table Address - must be WORD aligned. */
> +
> +	/* FIXME: where is DATA_0 ??? */
> +	u32 data[MAX_HTB_TBL_SIZE];	/* sizeof (data) == 512 */
> +} htb_desc;

kill all bitfields.  All compilers generate awful code for bitfields, 
there are inherent endianness problems, and bit mask/shift operations on 
16/32/64-bit values are very efficient.

Additionally, all hardware data structures directly references (like 
htb_desc) should be verified with the 'sparse' tool (read 
Documentation/sparse.txt), after using endian-sensitive data types like 
__le32.


> +/* 
> + * Host Table Buffer format ( 2Kbyte )
> + * Source: BORDEAUX Data Sheet, 10.2
> + *
> + * 0x000 - 0x1FF   512 bytes   MAC Table
> + * 0x200 - 0x3FF   512 bytes   VLAN Table (Device Info after reset)
> + * 0x400 - 0x4FF   256 bytes   L2 Statistics Table
> + * 0x500 - 0x5FF   256 bytes   L3 and L4 Statistics Table
> + * 0x600 - 0x6FF   256 bytes   Routing Table
> + * 0x700 - 0x707   8   bytes   HTB Address
> + * 0x708 - 0x70F   8   bytes   Reserved
> + * 0x710 - 0x72F   32  bytes   SDRAM Read Data
> + * 0x730 - 0x7FF   208 bytes   Reserved
> + */
> +enum {
> +	BDX_HTB_MAC_TABLE_SIZE = 512,
> +	BDX_HTB_VLAN_TABLE_SIZE = 512,
> +	BDX_HTB_L2_TABLE_SIZE = 256,
> +	BDX_HTB_L3_TABLE_SIZE = 256,
> +	BDX_HTB_ROUTING_TABLE_SIZE = 256,
> +	BDX_HTB_ADDR_SIZE = 8,
> +	BDX_HTB_RESERVED_1_SIZE = 8,
> +	BDX_HTB_SDRAM_READ_DATA_SIZE = 32,
> +	BDX_HTB_RESERVED_2_SIZE = 208
> +};
> +
> +/*
> + * L2 table size
> + * has to be BDX_HTB_L2_TABLE_SIZE bytes long
> + */
> +typedef struct {
> +	u64 aFramesTransmittedOK,
> +	    aFramesReceivedOK,
> +	    aFrameCheckSequenceErrors,
> +	    aAlignmentErrors,
> +	    aTxPAUSEMACCtrlFrames,
> +	    aRxPAUSEMACCtrlFrames,
> +	    aFrameTooLongErrors,
> +	    aInRangeLengthErrors,
> +	    VLANTransmittedOK,
> +	    VLANReceivedOK,
> +	    ifOutOctets,
> +	    ifInOctets,
> +	    ifInUcastPkts,
> +	    ifInMulticastPkts,
> +	    ifInBroadcastPkts,
> +	    ifOutErrors,
> +	    ifOutDiscards,
> +	    ifOutUcastPkts,
> +	    ifOutMulticastPkts,
> +	    ifOutBroadcastPkts,
> +	    etherStatsDropEvents,
> +	    etherStatsOctets,
> +	    etherStatsPkts,
> +	    etherStatsUndersizePkts,
> +	    etherStatsPkts64Octets,
> +	    etherStatsPkts65to127Octets,
> +	    etherStatsPkts128to255Octets,
> +	    etherStatsPkts256to511Octets,
> +	    etherStatsPkts512to1023Octets,
> +	    etherStatsPkts1024to1518Octets,
> +	    etherStatsPkts1519toX, etherStatsOversizePkts;
> +	/* etherStatsJabbers; */
> +} l2_stat_block;
> +
> +typedef struct htb_table {
> +	u8 mac_table[BDX_HTB_MAC_TABLE_SIZE];
> +	u8 vlan_table[BDX_HTB_VLAN_TABLE_SIZE];
> +	l2_stat_block l2_stats;	/* [sizeof = BDX_HTB_L2_TABLE_SIZE]; */
> +	u8 l3l4_stats[BDX_HTB_L3_TABLE_SIZE];
> +	u8 routing_table[BDX_HTB_ROUTING_TABLE_SIZE];
> +	u8 htb_addr[BDX_HTB_ADDR_SIZE];
> +	u8 reserved_1[BDX_HTB_RESERVED_1_SIZE];
> +	u8 sdram_read_data[BDX_HTB_SDRAM_READ_DATA_SIZE];
> +	u8 reserved_2[BDX_HTB_RESERVED_2_SIZE];
> +} htb_table_t;
> +
> +enum {
> +	FIFO_EXTRA_SPACE = 1024
> +};
> +
> +typedef struct {
> +	dma_addr_t da;		/* physical address of fifo (used by HW) */
> +	char *va;		/* virtual address of fifo (used by SW) */
> +	u32 rptr, wptr;		/* cached values of RPTR and WPTR registers, */
> +				/* they're 32 bits on both 32 and 64 archs */
> +	u16 reg_CFG0, reg_CFG1;
> +	u16 reg_RPTR, reg_WPTR;
> +	u16 memsz;		/* memory size allocated for fifo (used in pci_free_consistent) */
> +	u16 size_mask;
> +	u16 pktsz;		/* skb packet size to allocate */
> +	u16 rcvno;		/* number of RXD buffers that come from this RXF */
> +} fifo;
> +
> +typedef struct {
> +	fifo m;			/* minimal set of variables that used by all fifos */
> +} txf_fifo;
> +
> +typedef struct {
> +	fifo m;			/* minimal set of variables that used by all fifos */
> +} txd_fifo;
> +
> +typedef struct {
> +	fifo m;			/* minimal set of variables that used by all fifos */
> +} rxf_fifo;
> +
> +typedef struct {
> +	fifo m;			/* minimal set of variables that used by all fifos */
> +} rxd_fifo;
> +
> +typedef struct {
> +	u64 dma;
> +	struct sk_buff *skb;
> +} rx_map;
> +
> +typedef struct {
> +	int *stack;
> +	rx_map *elems;
> +	int nelem;
> +	int top;
> +} rxdb_t;
> +
> +typedef union {
> +	dma_addr_t dma;
> +	struct sk_buff *skb;
> +} bdx_dma_addr_t;
> +
> +/* Entry in the db. */
> +/* if len == 0 addr is dma */
> +/* if len != 0 addr is skb */
> +typedef struct {
> +	bdx_dma_addr_t addr;
> +	int len;
> +} tx_map;
> +
> +/* tx database - implemented as circular fifo buffer */
> +typedef struct {
> +	tx_map *start;		/* points to the first element */
> +	tx_map *end;		/* points just AFTER the last element */
> +	tx_map *rptr;		/* points to the next element to read */
> +	tx_map *wptr;		/* points to the next element to write */
> +	int size;		/* number of elements in the db */
> +} txdb_t;
> +
> +typedef struct _bdx_priv {
> +	void *pBdxRegs;
> +	struct net_device *ndev;
> +
> +	/* RX FIFOs: 1 for data (full) descs, and 2 for free descs */
> +	rxd_fifo rxd_fifo0;
> +	rxf_fifo rxf_fifo0, rxf_fifo2;
> +	rxdb_t *rx0db, *rx2db;	/* rx dbs to store skb pointers */
> +	int napi_stop;
> +#ifdef BDX_VLAN
> +	struct vlan_group *vlgrp;
> +#endif
> +
> +	/* Tx FIFOs: 1 for data desc, 1 for empty (acks) desc */
> +	txd_fifo txd_fifo0;
> +	txf_fifo txf_fifo0;
> +
> +	txdb_t txdb;
> +	int tx_level;
> +#ifdef DELAY_WPTR
> +	int tx_update_mark;
> +	int tx_noupd;
> +#endif
> +	spinlock_t tx_lock;	/* NETIF_F_LLTX mode */
> +
> +	/* rarely used */
> +	u8 port;
> +	u32 msg_enable;
> +	struct net_device_stats net_stats;
> +	struct pci_dev *pdev;
> +
> +	htb_table_t *htb;
> +	dma_addr_t htb_dma;
> +	pci_nic *nic;
> +	int irq_type;
> +} bdx_priv;

Kill all typedefs.  Standard POSIX and Linux style is "struct foo" not 
"foo_t".


> +/* RX FREE descriptor - 64bit */
> +typedef struct {
> +	u32 info;		/* Buffer Count + Info - described below */
> +	u32 va_lo;		/* VAdr[31:0] */
> +	u32 va_hi;		/* VAdr[63:32] */
> +	u32 pa_lo;		/* PAdr[31:0] */
> +	u32 pa_hi;		/* PAdr[63:32] */
> +	u32 len;		/* Buffer Length */
> +} rxf_desc;
> +
> +typedef struct {
> +	u32 bc:5,		/* Buffer Count */
> +	    /*  The descriptor length in LWORDs including padding if added */
> +	 rsvd0:3,		/* Reserved */
> +	 rxfq:2,		/* RX Free Queue */
> +	    /*   Indicates the origin RX_FREE fifo for this descriptor. */
> +	    /*   This is used only in configuration where multiple RX_FREE */
> +	    /*   fifos feed a single RX_DESCRIPTOR fifo */
> +	 rsvd1:5,		/* Reserved, must be 0 */
> +	 to:1,			/* The aggregation of this packet has ended due to */
> +	    /* aggregation timeout */
> +	 type:4,		/* Descriptor Type */
> +	    /*   2 - RX Descriptor */
> +	    /*   3 - RX Descriptor with data change */
> +	 rsvd2:1,		/* Reserved, must be 0 */
> +	 err:6,			/* Error bitmap: */
> +	    /*   21 bit - Overflow error: received frame bigger than */
> +	    /*            maximal frame size */
> +	    /*   22 bit - Runt error: received frame smaller than 64 bytes */
> +	    /*   23 bit - CRC error */
> +	    /*   24 bit - UDP checksum error */
> +	    /*   25 bit - TCP checksum error */
> +	    /*   26 bit - IP checksum error */
> +	 rxp:1,			/* Recieve port */
> +	 pkt_id:3,		/* Packet ID: */
> +	    /*   0 - non IP */
> +	    /*   1 - TCP */
> +	    /*   2 - UDP */
> +	    /*   3 - IP non TCP or UDP */
> +	    /*   4 - 7 - reserved */
> +	 vtag:1;		/* VLAN tag */
> +	    /*   1 - received packet contains VLAN tag according to */
> +	    /*       IEEE 802.1q VLAN packet */
> +
> +	u32 len:16,		/* Packet Length in bytes */
> +	 vlan_id:12,		/* VLAN ID received in the packet header */
> +	 cfi:1,			/* Canonical Format Indicator */
> +	 prio:3;		/* VLAN Priority */
> +
> +	u32 va_lo;
> +	u32 va_hi;
> +} rxd_desc;
> +
> +/* TYPE 3 Descriptor has the addition of a data change instruction to the driver. */
> +typedef struct {
> +	u32 offset:16,		/* Change Data Offset: The offset of the data to be */
> +	    /*   changed in the virtual Buffer starting from the */
> +	    /*   buffer beginning */
> +	 dataSize:2,		/* Length - The length of the data to be changed */
> +	    /*   0 - Byte; only Data[7:0] */
> +	    /*   1 - Word; only Data [15:0] */
> +	    /*   2 - DWord; Data [31:0] */
> +	 unused:14;
> +	u32 data;
> +} rxd_data_change;
> +
> +/* PBL describes each virtual buffer to be */
> +/* transmitted from the host. */
> +typedef struct {
> +	u32 pa_lo;
> +	u32 pa_hi;
> +	u32 len;
> +} pbl_t;
> +
> +typedef struct {
> +	union {
> +		struct {
> +			u32 bc:5,	/* Buffer Count: Descriptor length in LWORDs */
> +			 ipUdpTcpCs:3,	/* UDP/TCP/IP checksum */
> +			    /*   5 bit - insert UDP checksum */
> +			    /*   6 bit - insert TCP checksum */
> +			    /*   7 bit - insert IP checksum */
> +			 vtag:1,	/* VLAN tag - insert VLAN tag according to IEEE 802.1q VLAN packet */
> +			 lgsnd:1,	/* TCP Large Send operation enabled -segment the packets to MSS segments */
> +			 frag:1,	/* IP Fragmentation enabled */
> +			 unused:1,	/* Reserved */
> +			 cfi:1,	/* Canonical Format Indicator */
> +			 prio:3,	/* VLAN Priority */
> +			 type:4,	/* Descriptor Type = 3 (Smart NIC Packet) */
> +			 vlan_id:12;	/* VLAN ID to be inserted in the packet header */
> +		} bits;
> +		u32 val;
> +	} w1;
> +	u32 mss:16,		/* MSS if LGSND=1 or MTU if FRAG=1 */
> +	 length:16;		/* Packet Length in Bytes */
> +	u32 va_lo;
> +	u32 va_hi;
> +	pbl_t pbl[0];		/* Fragments */
> +} txd_desc;
> +
> +typedef struct {
> +	u32 bc:5,		/* Buffer Count: Descriptor length in LWORDs */
> +	 rsvd1:11,		/* Reserved */
> +	 type:4,		/* Header Length: valid for Large Send only - */
> +	    /*   the length of the Ethernet, IP and TCP */
> +	    /*   header added to the generated packets */
> +	 rsrvd2:11,		/* Reserved */
> +	 txError:1;		/* Transmit Error: the packet failed to be transmitted */
> +	u32 va_lo;
> +	u32 va_hi;
> +} txf_desc;

more bitfields, more endianness bugs.

I stopped reviewing there.  Repost when these issues have been fixed, as 
it will be far easier to review the driver then.

Also, do not bother to post the firmware include in email.  Post a URL 
to the full patch, or excluded file.  Including the firmware needlessly 
eliminates reviewers by causing mailing list software to drop your patch 
rather than redistributing it to list members.

	Jeff


