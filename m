From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] wan: new driver retina
Date: Tue, 23 Oct 2007 09:31:19 -0700
Message-ID: <20071023093119.1c094bf6@freepuppy.rosehill>
References: <956438.34005.qm@web52003.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50334 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751942AbXJWQcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 12:32:10 -0400
In-Reply-To: <956438.34005.qm@web52003.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Oct 2007 02:58:29 -0700 (PDT)
Matti Linnanvuori <mattilinnanvuori@yahoo.com> wrote:

> From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
> 
> Retina G.703 and G.SHDSL driver.
> 
> Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
> ---
> 
> Fixed bugs according to linux-netdev comments.
> 
> diff -Napur linux-2.6.23/drivers/net/wan/Kconfig linux-2.6.24/drivers/net/wan/Kconfig
> --- linux-2.6.23/drivers/net/wan/Kconfig	2007-10-09 23:31:38.000000000 +0300
> +++ linux-2.6.24/drivers/net/wan/Kconfig	2007-10-23 12:30:45.853384514 +0300
> @@ -494,4 +494,14 @@ config SBNI_MULTILINE
>  
>  	  If unsure, say N.
>  
> +config RETINA
> +	tristate "Retina support"
> +	depends on PCI
> +	help
> +	  Driver for Retina C5400 and E2200 network PCI cards, which
> +	  support G.703, G.SHDSL with Ethernet encapsulation.
> +
> +	  To compile this driver as a module, choose M here: the
> +	  module will be called retina.
> +
>  endif # WAN
> diff -Napur linux-2.6.23/drivers/net/wan/Makefile linux-2.6.24/drivers/net/wan/Makefile
> --- linux-2.6.23/drivers/net/wan/Makefile	2007-10-09 23:31:38.000000000 +0300
> +++ linux-2.6.24/drivers/net/wan/Makefile	2007-10-23 12:31:17.598640178 +0300
> @@ -42,6 +42,7 @@ obj-$(CONFIG_C101)		+= c101.o
>  obj-$(CONFIG_WANXL)		+= wanxl.o
>  obj-$(CONFIG_PCI200SYN)		+= pci200syn.o
>  obj-$(CONFIG_PC300TOO)		+= pc300too.o
> +obj-$(CONFIG_RETINA)		+= retina.o
>  
>  clean-files := wanxlfw.inc
>  $(obj)/wanxl.o:	$(obj)/wanxlfw.inc
> diff -Napur linux-2.6.23/drivers/net/wan/retina.c linux-2.6.24/drivers/net/wan/retina.c
> --- linux-2.6.23/drivers/net/wan/retina.c	1970-01-01 02:00:00.000000000 +0200
> +++ linux-2.6.24/drivers/net/wan/retina.c	2007-10-23 12:52:17.122802714 +0300
> @@ -0,0 +1,4428 @@
> +/* retina.c: */
> +
> +/*
> +	This driver is based on:
> +
> +	/drivers/net/fepci.c
> +	FEPCI (Frame Engine for PCI) driver for Linux operating system
> +
> +	Copyright (C) 2002-2003 Jouni Kujala, Flexibilis Oy.
> +
> +	This program is free software; you can redistribute it and/or
> +	modify it under the terms of the GNU General Public License
> +	as published by the Free Software Foundation; either version 2
> +	of the License, or (at your option) any later version.
> +
> +	This program is distributed in the hope that it will be useful,
> +	but WITHOUT ANY WARRANTY; without even the implied warranty of
> +	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> +	GNU General Public License for more details.
> +
> +	All the drivers derived from or based on this code fall under the
> +	GPL and must retain the copyright and license notice.
> +*/
> +
> +#define DRV_NAME	"retina"
> +#define DRV_VERSION	"1.2.6"
> +
> +#define DBG_PRINT(xyz...)	/* printk(KERN_DEBUG xyz) */

pr_debug()

> +/* uncomment this if you want to have debug files in /proc
> + * #define DEBUG_PROC_FILES */
> +
> +/* Keep this if you want to have point-to-point links
> + ! Only interfaces listed in retina_ptp_interfaces will
> +   be created in PtP mode
> +  see retina_ptp_interfaces */
> +#define FEPCI_POINT_TO_POINT
> +
> +/* need to update MODULE_PARM also */
> +#define MAX_DEVICES 32u
> +
> +#define MAX_TX_UNITS  256u
> +#define MAX_RX_UNITS  256u
> +
> +#define MAX_UNIT_SZ_ORDER  10u
> +
> +#define TX_RING_SIZE	8u
> +#define RX_RING_SIZE	8u
> +
> +/* need to update MODULE_PARM also */
> +#define CHANNELS        4u
> +
> +#define RX_FIFO_THRESHOLD_PACKET_MODE 0x4
> +#define TX_FIFO_THRESHOLD_PACKET_MODE 0x4
> +#define TX_DESC_THRESHOLD_PACKET_MODE 0x4
> +
> +#define RX_FIFO_THRESHOLD_STREAM_MODE 0x4
> +#define TX_FIFO_THRESHOLD_STREAM_MODE 0x7
> +#define TX_DESC_THRESHOLD_STREAM_MODE 0x1
> +
> +/* need to update MODULE_PARM also */
> +#define MAX_INTERFACES (CHANNELS*MAX_DEVICES)
> +
> +const char fepci_name[] = "retina";
> +const char fepci_alarm_manager_name[] = "retina alarm manager";
> +const char fepci_NAME[] = "RETINA";
> +const char fepci_netdev_name[] = "dcpxx";
> +const char fepci_proc_entry_name[] = "driver/retina";
> +
> +static unsigned int find_cnt;
> +
> +#ifdef FEPCI_POINT_TO_POINT
> +static char *retina_ptp_interfaces[MAX_INTERFACES];
> +static int retina_noarp_with_ptp = 1;
> +#endif /* FEPCI_POINT_TO_POINT */
> +
> +#define fepci_features_proc_entry_name "driver/retina/%02x:%02x.%02x/features"
> +#define fepci_settings_proc_entry_name "driver/retina/%02x:%02x.%02x/settings"
> +#define fepci_status_proc_entry_name "driver/retina/%02x:%02x.%02x/status"
> +
> +#ifdef DEBUG_PROC_FILES
> +#define fepci_counters_proc_entry_name \
> +"driver/retina/%02x:%02x.%02x/counters_ch%d"
> +#define fepci_descriptors_proc_entry_name \
> +"driver/retina/%02x:%02x.%02x/descriptors_ch%d"
> +#define fepci_stream_counters_proc_entry_name \
> +"driver/retina/%02x:%02x.%02x/stream_counters_ch%d"
> +#define fepci_registers_proc_entry_name \
> +"driver/retina/%02x:%02x.%02x/registers_ch%d"
> +#endif /* DEBUG_PROC_FILES */

You can't use /proc for this in new drivers. Either:
1. Remove the code since it doesn't do anything useful
2. Convert it to use debugfs (see skge and sky2)
3. Convert it to use sysfs attributes.

> +/* Time in jiffies before concluding that the transmitter is hung */
> +#define TX_TIMEOUT  (20*HZ)

Pretty long.

> +#include "retina.h"
> +#include <linux/mm.h>
> +#include <linux/random.h>
> +#include <linux/proc_fs.h>
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/string.h>
> +#include <linux/timer.h>
> +#include <linux/errno.h>
> +#include <linux/ioport.h>
> +#include <linux/slab.h>
> +#include <linux/interrupt.h>
> +#include <linux/pci.h>
> +#include <linux/init.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/ethtool.h>
> +#include <linux/delay.h>
> +#include <linux/bitops.h>
> +#include <linux/version.h>
> +#include <linux/pfn.h>
> +#include <linux/uaccess.h>
> +#include <linux/io.h>
> +
> +#include <asm/unaligned.h>
> +#include <asm/pgtable.h>
> +
> +MODULE_VERSION(DRV_VERSION);
> +
> +/* PCI I/O space extent */
> +#define FEPCI_SIZE 0x20000
> +#define PCI_IOTYPE (PCI_COMMAND_MASTER | PCI_COMMAND_MEMORY)
> +
> +struct pci_id_info {
> +	const char *name;
> +	struct match_info {
> +		int pci, pci_mask, subsystem, subsystem_mask;
> +		int revision, revision_mask;	/* Only 8 bits. */
> +	} id;
> +	unsigned pci_flags;
> +	int io_size;		/* Needed for I/O region check or ioremap */
> +	int drv_flags;		/* Driver use, intended as capability flags */
> +};
> +
> +static struct pci_id_info pci_id_tbl[] = {
> +	{"Frame Engine for PCI (FEPCI)",
> +	 {0x1FC00300, 0x1FC00301, 0xffffffff},
> +	 PCI_IOTYPE, FEPCI_SIZE},
> +	{0,},
> +};

You shouldn't need this if you use current pci device discovery
methods.

> +static struct pci_device_id fepci_pci_tbl[] __devinitdata = {
> +	{0x1FC0, 0x0300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> +	{0x1FC0, 0x0301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> +	{0,}
> +};

You might want to add PCI_VENDOR_ID_FEPCI to pci_ids.h

> +MODULE_DESCRIPTION("Frame Engine for PCI (FEPCI)");
> +MODULE_AUTHOR("Jouni Kujala");
> +MODULE_LICENSE("GPL");
> +MODULE_DEVICE_TABLE(pci, fepci_pci_tbl);
> +
> +/* Linux appears to drop POINTOPOINT,BROADCAST and NOARP flags in SIOCSFLAGS
> + * This workaround allows load time per interface ptp mode configuration.
> + * Runtime ptp mode changes would either require changes to Linux or
> + * use of proprietary ioctls, which ifconfig knows nothing about anyway
> + */
> +
> +static unsigned interfaces = MAX_INTERFACES;
> +#ifdef FEPCI_POINT_TO_POINT
> +module_param_array(retina_ptp_interfaces, charp, &interfaces, S_IRUGO);
> +module_param(retina_noarp_with_ptp, bool, S_IRUGO);
> +MODULE_PARM_DESC(retina_noarp_with_ptp,
> +		 "0 to disable NOARP, "
> +		 "1 to enable NOARP on pointopoint interfaces");
> +#endif
> +
> +struct fepci_ch_private {
> +	unsigned int channel_number;
> +	struct net_device *this_dev;
> +
> +	struct fepci_card_private *this_card_priv;
> +
> +	unsigned int reg_rxctrl;
> +	unsigned int reg_txctrl;
> +
> +	struct fepci_desc *rx_desc;	/* rx_ring start */
> +	struct fepci_desc *tx_desc;	/* tx_ring start */
> +	struct sk_buff *rx_skbuff[RX_RING_SIZE];
> +	struct sk_buff *tx_skbuff[TX_RING_SIZE];
> +
> +	struct timer_list timer;
> +	struct net_device_stats stats;
> +
> +	unsigned drv_flags;
> +
> +	unsigned int rx_buf_sz;	/*  MTU+slack */
> +	unsigned int cur_tx;	/* the next filled tx_descriptor */
> +	/* in stream mode the desc which is being transmitted */
> +	/* rx_descriptor where next packet transferred */
> +	unsigned int cur_rx;
> +	/* in stream mode the desc which is being received */
> +
> +/* stream mode: */
> +	bool in_eth_mode;
> +	bool in_stream_mode;
> +	bool stream_on;
> +	u32 *rx_buffer;
> +	u32 *tx_buffer;
> +	unsigned bufsize_order;	/* 10=1kB,11=2kB,12=4kB...16=64kB */
> +	unsigned bufsize;
> +	unsigned unit_sz_order;	/* 8=256B...14=16kB */
> +	unsigned unit_sz;
> +	unsigned units;		/* 2,4,8,16,...,256 */
> +	/* fake units (and pointers) are for faking larger unit sizes to
> +	 * the user than what is the maximum internal unit size in FEPCI */
> +	unsigned fake_unit_sz_order;
> +	unsigned fake_unit_sz;
> +	unsigned fake_units;
> +	u32 *tx_unit[MAX_TX_UNITS];
> +	u32 *rx_unit[MAX_RX_UNITS];
> +	unsigned cur_tx_unit;	/* last sent tx_unit */
> +	/* rx_unit where to next packet is transferred */
> +	unsigned cur_rx_unit;
> +/* char device: */
> +	unsigned minor;		/* currently the same as card_nuber */
> +/* debugging stuff for packet mode: */
> +	/* rx-errors in descriptors */
> +	unsigned int rx_desc_fifo_err;
> +	unsigned int rx_desc_size_err;
> +	unsigned int rx_desc_crc_err;
> +	unsigned int rx_desc_octet_err;
> +	unsigned rx_desc_line_err;
> +	/* tx-errors in descriptors */
> +	unsigned tx_desc_fifo_err;
> +	/* rx-errors in interrupts */
> +	unsigned rx_int_fifo_err;
> +	unsigned rx_int_frame_dropped_err;
> +	/* tx-errors in interrupts */
> +	unsigned tx_int_fifo_err;
> +	/* ints */
> +	unsigned interrupts;
> +	unsigned rx_interrupts;
> +	unsigned tx_interrupts;
> +	/* error combination tables */
> +	/* fifo,size,crc,octet,line */
> +	unsigned rx_desc_err_table[2][2][2][2][2];
> +	unsigned int_err_table[2][2];	/* fifo,frame_dropped */
> +	/* skbuff counters */
> +	unsigned rx_skbuffs_in;
> +	unsigned rx_skbuffs_out;
> +	unsigned tx_skbuffs_in;
> +	unsigned tx_skbuffs_out;
> +/* debugging stuff for stream mode: */
> +	/* rx-errors in descriptors */
> +	unsigned rx_desc_fifo_err_stream;
> +	unsigned rx_desc_size_err_stream;
> +	unsigned rx_desc_crc_err_stream;
> +	unsigned rx_desc_octet_err_stream;
> +	unsigned rx_desc_line_err_stream;
> +	/* tx-errors in descriptors */
> +	unsigned tx_desc_fifo_err_stream;
> +	/* rx-errors in interrupts */
> +	unsigned rx_int_fifo_err_stream;
> +	unsigned rx_int_frame_dropped_err_stream;
> +	/* tx-errors in interrupts */
> +	unsigned tx_int_fifo_err_stream;
> +	/* ints */
> +	unsigned interrupts_stream;
> +	unsigned rx_interrupts_stream;
> +	unsigned tx_interrupts_stream;
> +	/* error combination tables */
> +	/* fifo,size,crc,octet,line */
> +	unsigned rx_desc_err_table_stream[2][2][2][2][2];
> +	unsigned int_err_table_stream[2][2];	/* fifo,frame_dropped */
> +/* other: */
> +	/* tx interrupts since last timer interrupt */
> +	unsigned tx_interrupts_since_last_timer;
> +/* small packet counters: */
> +	unsigned rx_packets_of_size_0;
> +	unsigned rx_packets_of_size_1;
> +	unsigned rx_packets_of_size_2;
> +	unsigned rx_packets_of_size_3;
> +	unsigned rx_packets_of_size_4_7;
> +	unsigned rx_packets_of_size_8_15;
> +	unsigned rx_packets_of_size_16_31;
> +/* small packet counters for stream: */
> +	unsigned rx_packets_of_size_0_stream;
> +	unsigned rx_packets_of_size_1_stream;
> +	unsigned rx_packets_of_size_2_stream;
> +	unsigned rx_packets_of_size_3_stream;
> +	unsigned rx_packets_of_size_4_7_stream;
> +	unsigned rx_packets_of_size_8_15_stream;
> +	unsigned rx_packets_of_size_16_31_stream;
> +};
> +
> +struct fepci_card_private {
> +	unsigned int card_number;
> +	u8 *ioaddr;
> +	/* Process ID of the current mailbox user
> +	 * (for whom it is reserved for) */
> +	unsigned int ioctl_saved_pid;
> +	struct pci_dev *pci_dev;
> +	struct fepci_ch_private *ch_privates[CHANNELS];
> +
> +	wait_queue_head_t alarm_manager_wait_q;
> +	struct timer_list mailbox_timer;
> +
> +	wait_queue_head_t stream_receive_q;
> +	wait_queue_head_t stream_transmit_q;
> +	wait_queue_head_t stream_both_q;
> +
> +	struct rw_semaphore semaphore;
> +};
> +
> +/* Offsets to the FEPCI registers */
> +enum fepci_offsets {
> +	reg_custom = 0x40,
> +
> +	reg_first_int_mask = 0x80,
> +	reg_first_int_status = 0xc0,
> +
> +	reg_first_rxctrl = 0x4000,
> +	to_next_rxctrl = 0x80,
> +
> +	reg_first_txctrl = 0x6000,
> +	to_next_txctrl = 0x80,
> +
> +	first_rx_desc = 0x10000,
> +	to_next_ch_rx_desc = 0x200,
> +
> +	first_tx_desc = 0x18000,
> +	to_next_ch_tx_desc = 0x200,
> +};
> +
> +enum reg_custom_bits {
> +	AM_interrupt_mask = 0x1,
> +	AM_interrupt_status = 0x100,
> +};
> +
> +enum reg_receive_control {
> +	Rx_fifo_threshold = 0x7,
> +	Receive_enable = 0x80000000,
> +};
> +
> +enum reg_transmit_control {
> +	Tx_fifo_threshold = 0x7,
> +	Tx_desc_threshold = 0x700,
> +	Transmit_enable = 0x80000000,
> +};
> +
> +enum int_bits {
> +	MaskFrameReceived = 0x01, MaskRxFifoError =
> +	    0x02, MaskRxFrameDroppedError = 0x04,
> +	MaskFrameTransmitted = 0x40, MaskTxFifoError = 0x80,
> +	MaskAllInts = 0xc7,
> +	IntrFrameReceived = 0x01, IntrRxFifoError =
> +	    0x02, IntrRxFrameDroppedError = 0x04,
> +	IntrFrameTransmitted = 0x40, IntrTxFifoError = 0x80,
> +	IntrAllInts = 0xc7,
> +};
> +
> +/* The FEPCI Rx and Tx buffer descriptors
> + * Elements are written as 32 bit for endian portability */
> +
> +struct fepci_desc {
> +	u32 desc_a;
> +	u32 desc_b;
> +};
> +
> +enum desc_b_bits {
> +	frame_length = 0xFFF,
> +	fifo_error = 0x10000,
> +	size_error = 0x20000,
> +	crc_error = 0x40000,
> +	octet_error = 0x80000,
> +	line_error = 0x100000,
> +	enable_transfer = 0x80000000,
> +	transfer_not_done = 0x80000000,
> +};
> +
> +/* global variables (common to whole driver, all the cards): */
> +int major;			/* char device major number */

Why are you using regular major/minor for a network device?
Any local variable like this has to be declared static so
as not to pollute the namespace of the whole kernel.



> +struct fepci_card_private card_privates[MAX_DEVICES];
> +unsigned long stream_pointers;
> +struct proc_dir_entry *proc_root_entry;

More name space pollution

> +void set_int_mask(int channel, u_char value, struct fepci_card_private *cp)
> +{
> +	void *address;
> +	unsigned shift, oldvalue;
> +	DBG_PRINT("set_int_mask\n");
> +	address = (cp->ioaddr) + reg_first_int_mask + (channel / 4L) * 4L;
> +	shift = 8L * (channel % 4L);
> +	oldvalue = readl((void *)address);
> +	oldvalue &= ~(0xff << shift);	/* clear bits */
> +	oldvalue |= value << shift;	/* set bits */
> +	writel(oldvalue, (void *)address);
> +}

All these have to be declared static.

> +u_char get_int_mask(int channel, void *ioaddr)
> +{
> +	void *address;
> +	unsigned shift, oldvalue;
> +	DBG_PRINT("get_int_mask\n");
> +	address = ioaddr + reg_first_int_mask + (channel / 4L) * 4L;
> +	shift = 8L * (channel % 4L);
> +	oldvalue = readl((void *)address);
> +	oldvalue &= (0xff << shift);	/* clear other bits */
> +	return (oldvalue >> shift);
> +}
> +
> +void clear_int(int channel, u_char value, void *ioaddr)
> +{
> +	void *address;
> +	unsigned shift, longvalue;
> +	DBG_PRINT("clear_int\n");
> +	address = ioaddr + reg_first_int_status + (channel / 4L) * 4L;
> +	shift = 8L * (channel % 4L);
> +	longvalue = value << shift;
> +	writel(~longvalue, (void *)address);
> +}
> +
> +u_char get_int_status(int channel, void *ioaddr)
> +{
> +	void *address;
> +	unsigned shift, oldvalue;
> +	DBG_PRINT("get_int_status\n");
> +	address = ioaddr + reg_first_int_status + (channel / 4L) * 4L;
> +	shift = 8L * (channel % 4L);
> +	oldvalue = readl((void *)address);
> +	oldvalue &= (0xff << shift);	/* clear other bits */
> +	return (oldvalue >> shift);
> +}
> +
> +void fillregisterswith_00(void *ioaddr)
> +{
> +	DBG_PRINT("fillregisterswith_00\n");
> +	writel(0x0, (void *)(ioaddr + reg_first_rxctrl));
> +	writel(0x0, (void *)(ioaddr + reg_first_txctrl));
> +	writel(0x0, (void *)(ioaddr + reg_first_int_mask));
> +	writel(0x0, (void *)(ioaddr + reg_first_int_status));
> +	writel(0x0, (void *)(ioaddr + first_rx_desc));
> +	writel(0x0, (void *)(ioaddr + first_tx_desc));
> +}
> +
> +static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
> +static int fepci_open(struct net_device *dev);
> +static void fepci_timer(unsigned long data);
> +static void fepci_tx_timeout(struct net_device *dev);
> +static void fepci_init_ring(struct net_device *dev);
> +static int fepci_start_xmit(struct sk_buff *skb, struct net_device *dev);
> +static irqreturn_t fepci_interrupt(int irq, void *dev_instance);
> +static int fepci_rx(struct net_device *dev);
> +static int fepci_close(struct net_device *dev);
> +static struct net_device_stats *fepci_get_stats(struct net_device *dev);
> +static void set_rx_mode(struct net_device *dev);
> +static void fepci_remove_one(struct pci_dev *pdev);
> +
> +/* proc filesystem functions introduced: */
> +
> +static int fepci_proc_init_driver(void);
> +static void fepci_proc_cleanup_driver(void);
> +static void fepci_proc_init_card(int card_number, void *card_data);
> +static void fepci_proc_cleanup_card(int card_number);
> +#ifdef DEBUG_PROC_FILES
> +static void fepci_proc_init_channel(int card_number, int channel_number,
> +				    void *channel_data);
> +static void fepci_proc_cleanup_channel(int card_number, int channel_number);
> +#endif /* DEBUG_PROC_FILES */
> +
> +/* char device operations: */
> +
> +ssize_t fepci_char_read(struct file *filp, char *buf, size_t count,
> +			loff_t *f_pos);
> +int fepci_char_open(struct inode *inode, struct file *filp);
> +int fepci_char_release(struct inode *inode, struct file *filp);
> +int fepci_char_mmap(struct file *filp, struct vm_area_struct *vma);
> +int fepci_char_ioctl(struct inode *inode, struct file *filp,
> +		     unsigned int cmd, unsigned long arg);
> +
> +struct file_operations fepci_char_fops = {
> +read:		fepci_char_read,
> +ioctl:		fepci_char_ioctl,
> +open:		fepci_char_open,
> +release:	fepci_char_release,
> +mmap:		fepci_char_mmap,
> +};

Please use C99 style initializers not old Gcc style.

> +int fepci_char_open(struct inode *inode, struct file *filp)
> +{
> +	unsigned int minor = MINOR(inode->i_rdev);
> +	DBG_PRINT("fepci_char_open\n");
> +	if (unlikely(minor >= find_cnt || card_privates[minor].pci_dev == NULL))
> +		return -ENXIO;
> +	filp->f_op = &fepci_char_fops;
> +	if (unlikely(!try_module_get(THIS_MODULE)))
> +		return -EBUSY;
> +	return 0;
> +}

If you use owner properly on proc files, you won't need to be
dorking with module ref counts.

> +
> +int fepci_char_release(struct inode *inode, struct file *filp)
> +{
> +	DBG_PRINT("fepci_char_release\n");
> +	module_put(THIS_MODULE);
> +	return 0;
> +}
> +
> +void fepci_vma_open(struct vm_area_struct *vma)
> +{
> +	DBG_PRINT("fepci_vma_open\n");
> +}
> +
> +void fepci_vma_close(struct vm_area_struct *vma)
> +{
> +	DBG_PRINT("fepci_vma_close\n");
> +	module_put(THIS_MODULE);
> +}
> +
> +static struct vm_operations_struct fepci_vm_ops = {
> +open:	fepci_vma_open,
> +close:	fepci_vma_close,
> +};
> +
> +int fepci_char_mmap(struct file *filp, struct vm_area_struct *vma)
> +{
> +	unsigned long offset = vma->vm_pgoff << PAGE_SHIFT;
> +	unsigned long size = vma->vm_end - vma->vm_start;
> +
> +	unsigned long virtual_address = 0;
> +
> +	vma->vm_flags |= VM_IO | VM_RESERVED;
> +	vma->vm_ops = &fepci_vm_ops;
> +	vma->vm_file = filp;
> +
> +	if (offset == STREAM_BUFFER_POINTER_AREA) {
> +		virtual_address = stream_pointers;
> +		if (virtual_address == 0) {
> +			printk(KERN_WARNING "%s: mmap: internal error.\n",
> +			       fepci_name);
> +			return -ENOMEM;
> +		}
> +		if (size > (1 << PAGE_SHIFT)) {
> +			printk(KERN_WARNING
> +			       "%s: mmap: area size over range.\n", fepci_name);
> +			return -EINVAL;
> +		}
> +	} else {
> +		unsigned int page;
> +
> +		unsigned int card;
> +		unsigned int channel;
> +		unsigned int area;	/* 0=rx, 1=tx */
> +
> +		card = (offset >> CARD_ADDRESS_SHIFT) & 0xf;
> +		channel = (offset >> CHANNEL_ADDRESS_SHIFT) & 0xf;
> +		area = (offset >> AREA_ADDRESS_SHIFT) & 0xf;
> +		page = (offset & 0xffff);	/* >> PAGE_SHIFT; */
> +
> +		if (area == 0) {
> +			/* if there really is such card */
> +			if (card < find_cnt && card_privates[card].pci_dev)
> +				virtual_address =
> +				    (unsigned long)card_privates[card].
> +				    ch_privates[channel]->rx_buffer;
> +			else
> +				goto INVALID;
> +		} else if (area == 1) {
> +			/* if there really is such card */
> +			if (card < find_cnt && card_privates[card].pci_dev)
> +				virtual_address =
> +				    (unsigned long)card_privates[card].
> +				    ch_privates[channel]->tx_buffer;
> +			else
> +				goto INVALID;
> +		} else {
> +INVALID:
> +			DBG_PRINT("%s: mmap: invalid address 0x%lx\n",
> +				  fepci_NAME, virtual_address);
> +			return -EINVAL;
> +		}
> +		if (virtual_address == 0)
> +			goto INVALID;
> +	}
> +
> +	if (!try_module_get(THIS_MODULE))
> +		return -EBUSY;
> +
> +	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
> +	{
> +		unsigned pfn = PFN_DOWN(virt_to_phys((void *)virtual_address));
> +		int error = io_remap_pfn_range(vma, vma->vm_start, pfn,
> +					       size, vma->vm_page_prot);
> +		if (unlikely(error))
> +			return error;
> +	}
> +	fepci_vma_open(vma);
> +	return 0;
> +}
> +
> +/* mmap operations end */
> +
> +/* char operations start */
> +
> +void fepci_copy_to_user(unsigned long to, void *from, unsigned long len,
> +			int shrink)
> +{
> +	unsigned int i;
> +	DBG_PRINT("fepci_copy_to_user\n");
> +	if (shrink) {
> +		for (i = 0; i < len; i += 2) {
> +			put_user((((unsigned long *)from)[i / 2]) & 0xff,
> +				 (unsigned char *)(to + i));
> +			put_user((((unsigned long *)from)[i / 2]) >> 8,
> +				 (unsigned char *)(to + i + 1));
> +		}
> +	} else {
> +		for (i = 0; i < len; i += 4)
> +			put_user(((unsigned long *)from)[i / 4],
> +				 (unsigned long *)(to + i));
> +	}
> +}
> +
> +void fepci_copy_from_user(void *to, unsigned long from, unsigned long len,
> +			  int enlarge)
> +{
> +	unsigned int i;
> +	if (enlarge) {
> +		for (i = 0; i < len; i += 2) {
> +			unsigned char temp1;
> +			unsigned char temp2;
> +			get_user(temp1, (unsigned char *)(from + i));
> +			get_user(temp2, (unsigned char *)(from + i + 1));
> +			*((unsigned long *)(to + i * 2)) = temp1 + (temp2 << 8);
> +		}
> +	} else {
> +		for (i = 0; i < len; i += 4)
> +			get_user(((unsigned long *)to)[i / 4],
> +				 (unsigned long *)(from + i));
> +	}
> +}
> +
> +unsigned get_semafore(struct fepci_real_mailbox *mailbox)
> +{
> +	unsigned semafore = readb(&mailbox->Semafore_Mail_number);
> +	DBG_PRINT("get_semafore = %x\n", semafore);
> +	return semafore;
> +}
> +
> +int set_semafore(struct fepci_real_mailbox *mailbox, unsigned semafore)
> +{
> +	unsigned number = readl(&mailbox->Semafore_Mail_number);
> +	DBG_PRINT("got number %u at %p.\n", number,
> +		  &mailbox->Semafore_Mail_number);
> +	number = ((number & ~0xFF) | semafore) + (1 << 8);
> +	DBG_PRINT
> +	    ("increases the mail number to %u at the same time at %p.\n",
> +	     number, &mailbox->Semafore_Mail_number);
> +	writel(number, &mailbox->Semafore_Mail_number);
> +	DBG_PRINT("set_semafore %p, %u returns 0.\n", mailbox, semafore);
> +	return 0;
> +}
> +
> +static void fepci_mailbox_timer(unsigned long data)
> +{
> +	int card_number = data;
> +	unsigned int *saved_pid = &card_privates[card_number].ioctl_saved_pid;
> +	void *ioaddr = card_privates[card_number].ioaddr;
> +	struct fepci_real_mailbox *real_mailbox =
> +	    (struct fepci_real_mailbox *)(ioaddr + FEPCI_MAILBOX_OFFSETT);
> +
> +	set_semafore(real_mailbox, 0x0);
> +	*saved_pid = 0;
> +}
> +
> +int fepci_char_ioctl(struct inode *inode, struct file *filp,
> +		     unsigned int cmd, unsigned long arg)
> +{
> +	unsigned int minor = MINOR(inode->i_rdev);
> +	void *ioaddr;
> +	struct fepci_real_mailbox *real_mailbox;
> +	int retval = 0;
> +	unsigned int *saved_pid;
> +	unsigned int my_pid;
> +
> +	if (minor >= find_cnt || card_privates[minor].pci_dev == NULL) {
> +		printk(KERN_WARNING
> +		       "%s: trying to access a card that does not exist.\n",
> +		       fepci_NAME);
> +		/* if trying to access a card that does not exist */
> +		return -ENXIO;
> +	}
> +
> +	DBG_PRINT("fepci_char_ioctl minor %u.\n", minor);
> +
> +	if (_IOC_DIR(cmd) & _IOC_READ)
> +		if (!access_ok(VERIFY_WRITE, (void *)arg, _IOC_SIZE(cmd)))
> +			return -EFAULT;
> +	if (_IOC_DIR(cmd) & _IOC_WRITE)
> +		if (!access_ok(VERIFY_READ, (void *)arg, _IOC_SIZE(cmd)))
> +			return -EFAULT;
> +
> +	ioaddr = card_privates[minor].ioaddr;
> +	real_mailbox =
> +	    (struct fepci_real_mailbox *)(ioaddr + FEPCI_MAILBOX_OFFSETT);
> +	saved_pid = &card_privates[minor].ioctl_saved_pid;
> +	my_pid = current->pid;
> +
> +	switch (cmd) {
> +	case FEPCI_IOCTL_STREAM_TRANSMIT_POLL:
> +		/* here: arg == channel number */
> +		if (arg < 0 || arg >= CHANNELS
> +		    || !(card_privates[minor].ch_privates[arg]->stream_on))
> +			return 0x2;
> +		{
> +			u32 pointer = *USER_TX_S_FAKE_POINTER(minor, arg,
> +							      stream_pointers);
> +			wait_event_interruptible((card_privates[minor].
> +						  stream_transmit_q)
> +						 ,
> +						 (pointer !=
> +						  *USER_TX_S_FAKE_POINTER
> +						  (minor, arg,
> +						   stream_pointers)));
> +			return 0x1;
> +		}
> +		return retval;
> +	case FEPCI_IOCTL_STREAM_RECEIVE_POLL:
> +		/* here: arg == channel number */
> +		if (arg < 0 || arg >= CHANNELS
> +		    || !(card_privates[minor].ch_privates[arg]->stream_on))
> +			return 0x2;
> +		{
> +			u32 pointer = *USER_RX_S_FAKE_POINTER(minor, arg,
> +							      stream_pointers);
> +			wait_event_interruptible((card_privates[minor].
> +						  stream_receive_q)
> +						 ,
> +						 (pointer !=
> +						  *USER_RX_S_FAKE_POINTER
> +						  (minor, arg,
> +						   stream_pointers)));
> +			retval = 0x1;
> +		}
> +		return retval;
> +	case FEPCI_IOCTL_STREAM_BOTH_POLL:
> +		/* here: arg == channel number */
> +		if (arg < 0 || arg >= CHANNELS
> +		    || !(card_privates[minor].ch_privates[arg]->stream_on))
> +			return 0x2;
> +		{
> +			u32 temp_tx_pointer =
> +			    *USER_TX_S_FAKE_POINTER(minor, arg,
> +						    stream_pointers);
> +			u32 temp_rx_pointer =
> +			    *USER_RX_S_FAKE_POINTER(minor, arg,
> +						    stream_pointers);
> +
> +			wait_event_interruptible((card_privates[minor].
> +						  stream_both_q)
> +						 ,
> +						 (temp_tx_pointer !=
> +						  *USER_TX_S_FAKE_POINTER
> +						  (minor, arg, stream_pointers))
> +						 || (temp_rx_pointer !=
> +						     *USER_RX_S_FAKE_POINTER
> +						     (minor, arg,
> +						      stream_pointers)));
> +			retval = 0x1;
> +		}
> +		return retval;
> +	case FEPCI_IOCTL_R_SHARED_MEM:
> +		DBG_PRINT(" %s: ioctl read shared mem commanded.\n",
> +			  fepci_NAME);
> +		fepci_copy_to_user(arg, ioaddr + FEPCI_SHARED_MEM_OFFSETT,
> +				   _IOC_SIZE(cmd), 0);
> +		break;
> +	case FEPCI_IOCTL_W_SHARED_MEM:
> +		DBG_PRINT(" %s: ioctl write shared mem commanded.\n",
> +			  fepci_NAME);
> +		fepci_copy_from_user(ioaddr + FEPCI_SHARED_MEM_OFFSETT,
> +				     arg, _IOC_SIZE(cmd), 0);
> +		break;
> +	case FEPCI_IOCTL_G_IDENTIFICATION:
> +		DBG_PRINT(" %s: IOCTL_G_IDENTIFICATION commanded.\n",
> +			  fepci_NAME);
> +		fepci_copy_to_user(arg,
> +				   ioaddr + FEPCI_IDENTIFICATION_OFFSETT,
> +				   _IOC_SIZE(cmd), 1);
> +		break;
> +	case FEPCI_IOCTL_G_FEATURES:
> +		DBG_PRINT(" %s: IOCTL_G_FEATURES commanded.\n", fepci_NAME);
> +		fepci_copy_to_user(arg, ioaddr + FEPCI_FEATURES_OFFSETT,
> +				   _IOC_SIZE(cmd), 1);
> +		break;
> +	case FEPCI_IOCTL_G_SETTINGS:
> +		DBG_PRINT(" %s: IOCTL_G_SETTINGS commanded.\n", fepci_NAME);
> +		fepci_copy_to_user(arg, ioaddr + FEPCI_SETTINGS_OFFSETT,
> +				   _IOC_SIZE(cmd), 1);
> +		break;
> +	case FEPCI_IOCTL_G_STATUS:
> +		DBG_PRINT(" %s: IOCTL_G_STATUS commanded.\n", fepci_NAME);
> +		fepci_copy_to_user(arg, ioaddr + FEPCI_STATUS_OFFSETT,
> +				   _IOC_SIZE(cmd), 1);
> +		break;
> +	case FEPCI_IOCTL_B_POLL:
> +		DBG_PRINT(" %s: IOCTL_B_POLL commanded.\n", fepci_NAME);
> +		retval = get_semafore(real_mailbox);
> +		if ((retval == 0x20 || retval == 0x21 || retval == 0x40)
> +		    && *saved_pid != my_pid)
> +			retval = 0x7;
> +		del_timer_sync(&card_privates[minor].mailbox_timer);
> +		card_privates[minor].mailbox_timer.expires = jiffies + 20 * HZ;
> +		card_privates[minor].mailbox_timer.data = minor;
> +		card_privates[minor].mailbox_timer.function =
> +		    &fepci_mailbox_timer;
> +		add_timer(&card_privates[minor].mailbox_timer);
> +		break;
> +	case FEPCI_IOCTL_B_GRAB:
> +		DBG_PRINT("%s: IOCTL_B_GRAB commanded.\n", fepci_NAME);
> +		if ((my_pid != *saved_pid) && (*saved_pid != 0)) {
> +			retval = 0x2;
> +			break;
> +		}
> +		DBG_PRINT("%s: IOCTL_B_GRAB getting semaphore.\n", fepci_NAME);
> +		if (get_semafore(real_mailbox) == 0x0) {
> +			DBG_PRINT("%s: IOCTL_B_GRAB setting semaphore.\n",
> +				  fepci_NAME);
> +			set_semafore(real_mailbox, 0x40);
> +			DBG_PRINT("%s: IOCTL_B_GRAB sleeping.\n", fepci_NAME);
> +			msleep(1);	/* delay at least 1 millisecond */
> +			DBG_PRINT
> +			    ("%s: IOCTL_B_GRAB getting semaphore again.\n",
> +			     fepci_NAME);
> +			switch (get_semafore(real_mailbox)) {
> +			case 0x40:
> +				retval = 0x0;
> +				DBG_PRINT
> +				    ("%s: IOCTL_B_GRAB saving pid to %p.\n",
> +				     fepci_NAME, saved_pid);
> +				*saved_pid = my_pid;
> +				DBG_PRINT
> +				    ("%s: IOCTL_B_GRAB deleting timer at %p.\n",
> +				     fepci_NAME,
> +				     &card_privates[minor].mailbox_timer);
> +				del_timer_sync(&card_privates[minor].
> +					       mailbox_timer);
> +				card_privates[minor].mailbox_timer.
> +				    expires = jiffies + 20 * HZ;
> +				card_privates[minor].mailbox_timer.data = minor;
> +				card_privates[minor].mailbox_timer.
> +				    function = &fepci_mailbox_timer;
> +				add_timer(&card_privates[minor].mailbox_timer);
> +				break;
> +			case 0x10:
> +			case 0x11:
> +			case 0x80:
> +				retval = 0x1;
> +				break;
> +			default:
> +				retval = 0xff;
> +			}
> +		} else {
> +			switch (get_semafore(real_mailbox)) {
> +			case 0x10:
> +			case 0x11:
> +			case 0x80:
> +				retval = 0x1;
> +				break;
> +			default:
> +				retval = 0xff;
> +			}
> +		}
> +		break;
> +	case FEPCI_IOCTL_B_RELEASE:
> +		DBG_PRINT(" %s: IOCTL_B_RELEASE commanded.\n", fepci_NAME);
> +		if (my_pid != *saved_pid) {
> +			retval = 0x2;
> +			break;
> +		}
> +		switch (get_semafore(real_mailbox)) {
> +		case 0x40:
> +		case 0x20:
> +			retval = 0x0;
> +			set_semafore(real_mailbox, 0x0);
> +			*saved_pid = 0;
> +			del_timer(&card_privates[minor].mailbox_timer);
> +			break;
> +		case 0x21:
> +			retval = 0x04;
> +			break;
> +		case 0x10:
> +		case 0x11:
> +		case 0x80:
> +			retval = 0x1;
> +			break;
> +		default:
> +			retval = 0xff;
> +		}
> +		break;
> +	case FEPCI_IOCTL_B_S_CMAIL:
> +		DBG_PRINT(" %s: IOCTL_B_S_CMAIL commanded.\n", fepci_NAME);
> +		if (my_pid != *saved_pid) {
> +			retval = 0x2;
> +			break;
> +		}
> +		switch (get_semafore(real_mailbox)) {
> +		case 0x40:
> +		case 0x20:
> +		case 0x21:
> +			/* copy the mailbox */
> +			fepci_copy_from_user(ioaddr +
> +					     FEPCI_MAILBOX_OFFSETT + 4,
> +					     arg + 2, _IOC_SIZE(cmd) - 2, 1);
> +			/* semafore -> 10 */
> +			set_semafore(real_mailbox, 0x10);
> +			retval = 0x0;
> +
> +			del_timer_sync(&card_privates[minor].mailbox_timer);
> +			card_privates[minor].mailbox_timer.expires =
> +			    jiffies + 20 * HZ;
> +			card_privates[minor].mailbox_timer.data = minor;
> +			card_privates[minor].mailbox_timer.function =
> +			    &fepci_mailbox_timer;
> +			add_timer(&card_privates[minor].mailbox_timer);
> +
> +			break;
> +
> +		case 0x10:
> +		case 0x11:
> +		case 0x80:
> +			retval = 0x1;
> +			break;
> +		case 0x0:
> +			retval = 0x3;
> +			break;
> +		default:
> +			retval = 0xff;
> +		}
> +		break;
> +	case FEPCI_IOCTL_B_S_QMAIL:
> +		DBG_PRINT(" %s: IOCTL_B_S_QMAIL commanded.\n", fepci_NAME);
> +		if (my_pid != *saved_pid) {
> +			retval = 0x2;
> +			break;
> +		}
> +		switch (get_semafore(real_mailbox)) {
> +		case 0x40:
> +		case 0x20:
> +		case 0x21:
> +			/* copy the mailbox; */
> +			fepci_copy_from_user(ioaddr +
> +					     FEPCI_MAILBOX_OFFSETT + 4,
> +					     arg + 2, _IOC_SIZE(cmd) - 2, 1);
> +			/* semafore -> 11 */
> +			set_semafore(real_mailbox, 0x11);
> +			retval = 0x0;
> +
> +			del_timer_sync(&card_privates[minor].mailbox_timer);
> +			card_privates[minor].mailbox_timer.expires =
> +			    jiffies + 20 * HZ;
> +			card_privates[minor].mailbox_timer.data = minor;
> +			card_privates[minor].mailbox_timer.function =
> +			    &fepci_mailbox_timer;
> +			add_timer(&card_privates[minor].mailbox_timer);
> +
> +			break;
> +
> +		case 0x10:
> +		case 0x11:
> +		case 0x80:
> +			retval = 0x1;
> +			break;
> +		case 0x0:
> +			retval = 0x3;
> +			break;
> +		default:
> +			retval = 0xff;
> +		}
> +		break;
> +	case FEPCI_IOCTL_B_G_MAIL:
> +		DBG_PRINT(" %s: IOCTL_B_G_MAIL commanded.\n", fepci_NAME);
> +		if (my_pid != *saved_pid) {
> +			retval = 0x2;
> +		} else {
> +			switch (get_semafore(real_mailbox)) {
> +			case 0x10:
> +			case 0x11:
> +			case 0x80:
> +				retval = 0x1;
> +				break;
> +			case 0x40:
> +			case 0x20:
> +			case 0x21:
> +				retval = 0x0;
> +				fepci_copy_to_user(arg,
> +						   ioaddr +
> +						   FEPCI_MAILBOX_OFFSETT,
> +						   _IOC_SIZE(cmd), 1);
> +
> +				del_timer_sync(&card_privates[minor].
> +					       mailbox_timer);
> +				card_privates[minor].mailbox_timer.
> +				    expires = jiffies + 20 * HZ;
> +				card_privates[minor].mailbox_timer.data = minor;
> +				card_privates[minor].mailbox_timer.
> +				    function = &fepci_mailbox_timer;
> +				add_timer(&card_privates[minor].mailbox_timer);
> +
> +				break;
> +			case 0x0:
> +				retval = 0x3;
> +				break;
> +			default:
> +				retval = 0xff;
> +			}
> +		}
> +		if (retval != 0) {
> +			static unsigned char seven = 7;
> +			/* copy four lowest bytes from the mailbox */
> +			fepci_copy_to_user(arg,
> +					   ioaddr + FEPCI_MAILBOX_OFFSETT,
> +					   4, 1);
> +			/* lowest byte = 0x7 */
> +			__put_user(arg, &seven);
> +		}
> +		break;
> +	case FEPCI_IOCTL_ALARM_MANAGER:
> +		DBG_PRINT(" %s: IOCTL_ALARM_MANAGER commanded.\n", fepci_NAME);
> +		interruptible_sleep_on(&(card_privates[minor].
> +					 alarm_manager_wait_q));
> +		return retval;
> +	default:
> +		DBG_PRINT(" %s: Unknown ioctl command 0x%x.\n", fepci_NAME,
> +			  cmd);
> +		return -ENOTTY;
> +	}
> +	return retval;
> +}
> +
> +ssize_t fepci_char_read(struct file *filp, char *buf, size_t count,
> +			loff_t *f_pos)
> +{
> +	DBG_PRINT("fepci_char_read\n");
> +	if (count > 1)
> +		count = 1;
> +	if (unlikely(copy_to_user(buf, "\n", count)))
> +		return -EFAULT;
> +	return count;
> +}
> +
> +static int fepci_register_char_device(void)
> +{
> +	int error =
> +	    register_chrdev(0 /* dynamic */ , fepci_name, &fepci_char_fops);
> +	if (unlikely(error < 0))
> +		printk(KERN_WARNING
> +		       "%s: unable to register char device.\n", fepci_NAME);
> +	else
> +		DBG_PRINT("%s: registered char device, major:0x%x.\n",
> +			  fepci_NAME, error);
> +	return error;
> +}
> +
> +void fepci_unregister_char_device(void)
> +{
> +	unregister_chrdev(major, fepci_name);
> +}
> +
> +/* char operations end */
> +
> +/* stream operations start */
> +
> +static irqreturn_t fepci_stream_interrupt(int irq, void *dev_instance);
> +static int fepci_stream_close(struct net_device *dev);
> +
> +static int fepci_stream_open(struct net_device *dev)
> +{
> +	struct fepci_ch_private *fp = dev->priv;
> +	unsigned tx_pages, rx_pages, tx_order, rx_order;
> +	unsigned page_number;
> +	unsigned int i;
> +
> +	down_write(&fp->this_card_priv->semaphore);
> +	if (fp->in_eth_mode) {
> +		up_write(&fp->this_card_priv->semaphore);
> +		printk(KERN_WARNING
> +		       "%s: Interface is in Ethernet mode, "
> +		       "cannot open stream interface.\n", fepci_NAME);
> +BUSY:
> +		return -EBUSY;
> +	}
> +	if (fp->in_stream_mode) {
> +		up_write(&fp->this_card_priv->semaphore);
> +		printk(KERN_WARNING
> +		       "%s: Interface is already in stream mode, "
> +		       "cannot open stream interface.\n", fepci_NAME);
> +		goto BUSY;
> +	}
> +
> +	if (unlikely(fp->this_card_priv->pci_dev == NULL)) {
> +		up_write(&fp->this_card_priv->semaphore);
> +		return -ENXIO;
> +	}
> +
> +	fp->bufsize = 1 << fp->bufsize_order;
> +
> +	if (fp->fake_unit_sz_order < 5) {
> +		up_write(&fp->this_card_priv->semaphore);
> +		printk(KERN_WARNING
> +		       "%s: Unit size has to be at least 32 Bytes.\n",
> +		       fepci_NAME);
> +INVALID:
> +		return (-EINVAL);
> +	}
> +
> +	if (fp->fake_unit_sz_order >= fp->bufsize_order) {
> +		up_write(&fp->this_card_priv->semaphore);
> +		printk(KERN_WARNING
> +		       "%s: Bufsize has to be greater than unit size.\n",
> +		       fepci_NAME);
> +		goto INVALID;
> +	}
> +
> +	if (fp->fake_unit_sz_order >= MAX_UNIT_SZ_ORDER) {
> +		fp->unit_sz_order = MAX_UNIT_SZ_ORDER;
> +	} else {
> +		fp->unit_sz_order = fp->fake_unit_sz_order;
> +	}
> +
> +	fp->fake_unit_sz = 1 << fp->fake_unit_sz_order;
> +	fp->unit_sz = 1 << fp->unit_sz_order;
> +	fp->units = 1 << (fp->bufsize_order - fp->unit_sz_order);
> +	fp->fake_units = 1 << (fp->bufsize_order - fp->fake_unit_sz_order);
> +
> +	/* reserve memory */
> +	if (fp->bufsize_order < PAGE_SHIFT) {
> +		rx_order = 0;
> +		tx_order = 0;
> +		rx_pages = 1;
> +		tx_pages = 1;
> +	} else {
> +		tx_order = fp->bufsize_order - PAGE_SHIFT;
> +		tx_pages = 1 << tx_order;
> +		rx_order = tx_order + 1;
> +		rx_pages = 1 << rx_order;
> +	}
> +	fp->in_stream_mode = 1;
> +	fp->tx_buffer = (u32 *) __get_dma_pages(GFP_KERNEL, tx_order);
> +	if (!fp->tx_buffer)
> +		goto NO_MEMORY;
> +	fp->rx_buffer = (u32 *) __get_dma_pages(GFP_KERNEL, rx_order);
> +	if (!fp->rx_buffer) {
> +NO_MEMORY:
> +		up_write(&fp->this_card_priv->semaphore);
> +		printk(KERN_WARNING
> +		       "%s: unable to allocate memory for buffers.\n",
> +		       fepci_NAME);
> +		fepci_stream_close(dev);
> +		return (-ENOMEM);
> +	}
> +
> +	for (page_number = 0; page_number < rx_pages; page_number++)
> +		/* make pages reserved to allow remappping pages
> +		   with io_remap_pfn_range */
> +		SetPageReserved(virt_to_page
> +				((unsigned long)fp->rx_buffer +
> +				 (page_number << PAGE_SHIFT)));
> +	for (page_number = 0; page_number < tx_pages; page_number++)
> +		/* make pages reserved to allow remappping pages
> +		   with io_remap_pfn_range */
> +		SetPageReserved(virt_to_page
> +				((unsigned long)fp->tx_buffer +
> +				 (page_number << PAGE_SHIFT)));
> +
> +	for (i = 0; i < (fp->bufsize) / 4; i++)
> +		fp->tx_buffer[i] = 0xffffffff;
> +
> +	/* + fp->channel_number; */
> +	*USER_RX_S_POINTER(fp->this_card_priv->card_number, fp->channel_number,
> +			   stream_pointers) = 0;
> +	/* + fp->channel_number; */
> +	*USER_TX_S_POINTER(fp->this_card_priv->card_number, fp->channel_number,
> +			   stream_pointers) = 0;
> +	/* + fp->channel_number; */
> +	*USER_RX_S_FAKE_POINTER(fp->this_card_priv->card_number,
> +				fp->channel_number, stream_pointers) = 0;
> +	/* + fp->channel_number; */
> +	*USER_TX_S_FAKE_POINTER(fp->this_card_priv->card_number,
> +				fp->channel_number, stream_pointers) = 0;
> +
> +	DBG_PRINT("%s: Bufsize is 0x%x.\n", fepci_NAME, fp->bufsize);
> +	DBG_PRINT("%s: Unit_size is 0x%x.\n", fepci_NAME, fp->unit_sz);
> +	DBG_PRINT("%s: Number of units is 0x%x.\n", fepci_NAME, fp->units);
> +
> +	DBG_PRINT("%s: Fake_unit_size is 0x%x.\n", fepci_NAME,
> +		  fp->fake_unit_sz);
> +	DBG_PRINT("%s: Number of fake units is 0x%x.\n", fepci_NAME,
> +		  fp->fake_units);
> +
> +	/* init ring buffers */
> +	for (i = 0; i < MAX_RX_UNITS; i++)
> +		fp->rx_unit[i] =
> +		    (u32 *) ((u32) (fp->rx_buffer) + (fp->unit_sz * i));
> +	for (i = 0; i < MAX_TX_UNITS; i++)
> +		fp->tx_unit[i] =
> +		    (u32 *) ((u32) (fp->tx_buffer) + (fp->unit_sz * i));
> +
> +	for (i = 0; i < RX_RING_SIZE; i++) {
> +		writel(0, &fp->rx_desc[i].desc_a);
> +		writel(0, &fp->rx_desc[i].desc_b);
> +	}
> +	for (i = 0; i < TX_RING_SIZE; i++) {
> +		writel(0, &fp->tx_desc[i].desc_a);
> +		writel(0, &fp->tx_desc[i].desc_b);
> +	}
> +
> +	up_write(&fp->this_card_priv->semaphore);
> +	return 0;
> +}
> +
> +static int fepci_stream_start(struct net_device *dev)
> +{
> +	struct fepci_ch_private *fp = dev->priv;
> +	unsigned i;
> +	down_write(&fp->this_card_priv->semaphore);
> +
> +	if (fp->in_stream_mode == 0) {
> +		up_write(&fp->this_card_priv->semaphore);
> +		printk(KERN_WARNING
> +		       "%s: Interface is not in stream mode, "
> +		       "streaming cannot be started.\n", fepci_NAME);
> +		return (-EBUSY);
> +	}
> +	if (fp->stream_on) {
> +		up_write(&fp->this_card_priv->semaphore);
> +		printk(KERN_WARNING
> +		       "%s: Streaming is already on, "
> +		       "streaming cannot be started.\n", fepci_NAME);
> +		return (-EBUSY);
> +	}
> +
> +	{
> +		/* reserve irq */
> +		int error = request_irq(dev->irq, &fepci_stream_interrupt,
> +					IRQF_SHARED, dev->name, dev);
> +		if (error) {
> +			up_write(&fp->this_card_priv->semaphore);
> +			printk(KERN_WARNING
> +			       "%s: unable to allocate IRQ %d, error 0x%x\n",
> +			       fepci_NAME, dev->irq, error);
> +			return -ENOMEM;
> +		}
> +	}
> +
> +	fp->stream_on = 1;
> +
> +	/* sending &receiving on, start from the beginning of the buffer */
> +	fp->cur_tx_unit = 0;
> +	fp->cur_rx_unit = 0;
> +	fp->cur_tx = 0;
> +	fp->cur_rx = 0;
> +
> +	/* all the descriptors ready to go: */
> +	for (i = 0; i < min(RX_RING_SIZE, TX_RING_SIZE); i++) {
> +		dma_addr_t address = pci_map_single(fp->this_card_priv->pci_dev,
> +						    fp->
> +						    rx_unit[(fp->cur_rx_unit +
> +							     i) % fp->units],
> +						    fp->unit_sz,
> +						    PCI_DMA_FROMDEVICE);
> +		if (unlikely(pci_dma_mapping_error(address)))
> +			printk(KERN_WARNING
> +			       "%s: failed to map DMA buffer.\n", fepci_NAME);
> +		else {
> +			writel(address,
> +			       &fp->rx_desc[(fp->cur_rx + i) &
> +					    (RX_RING_SIZE - 1)].desc_a);
> +			if (!
> +			    (readl
> +			     (&fp->
> +			      rx_desc[(fp->cur_rx + i) & (RX_RING_SIZE -
> +							  1)].
> +			      desc_b) & enable_transfer))
> +				writel(enable_transfer,
> +				       &fp->rx_desc[(fp->cur_rx + i) %
> +						    RX_RING_SIZE].desc_b);
> +		}
> +		address =
> +		    pci_map_single(fp->this_card_priv->pci_dev,
> +				   fp->tx_unit[(fp->cur_tx_unit + i) %
> +					       fp->units], fp->unit_sz,
> +				   PCI_DMA_TODEVICE);
> +		writel(address,
> +		       &fp->
> +		       tx_desc[(fp->cur_tx + i) & (TX_RING_SIZE - 1)].desc_a);
> +		if (unlikely(pci_dma_mapping_error(address)))
> +			printk(KERN_WARNING
> +			       "%s: failed to map DMA buffer.\n", fepci_NAME);
> +		else {
> +			if (!
> +			    (readl
> +			     (&fp->
> +			      tx_desc[(fp->cur_tx + i) & (TX_RING_SIZE -
> +							  1)].
> +			      desc_b) & enable_transfer))
> +				writel(enable_transfer |
> +				       (fp->unit_sz & frame_length),
> +				       &fp->
> +				       tx_desc[(fp->cur_tx +
> +						i) & (TX_RING_SIZE -
> +						      1)].desc_b);
> +		}
> +	}
> +
> +	/* irq on */
> +	set_int_mask(fp->channel_number,
> +		     MaskFrameReceived | MaskFrameTransmitted |
> +		     MaskRxFifoError | MaskRxFrameDroppedError |
> +		     MaskTxFifoError, fp->this_card_priv);
> +	{
> +		void *ioaddr = (void *)dev->base_addr;
> +		/* Start Rx and Tx channels */
> +		writel(Receive_enable |
> +		       (Rx_fifo_threshold & RX_FIFO_THRESHOLD_STREAM_MODE),
> +		       (void *)(ioaddr + fp->reg_rxctrl));
> +		writel((Transmit_enable |
> +			(Tx_desc_threshold &
> +			 (TX_DESC_THRESHOLD_STREAM_MODE << 8)) |
> +			(Tx_fifo_threshold & TX_FIFO_THRESHOLD_STREAM_MODE)),
> +		       (void *)(ioaddr + fp->reg_txctrl));
> +	}
> +	up_write(&fp->this_card_priv->semaphore);
> +
> +	return 0;
> +}
> +
> +static int fepci_stream_stop(struct net_device *dev)
> +{
> +	struct fepci_ch_private *fp = dev->priv;
> +	void *ioaddr = (void *)dev->base_addr;
> +	down_write(&fp->this_card_priv->semaphore);
> +	if (fp->in_stream_mode == 0) {
> +		up_write(&fp->this_card_priv->semaphore);
> +		return (1);
> +	}
> +	fp->stream_on = 0;
> +	/* Stop Rx and Tx channels. */
> +	writel(0x0, (void *)(ioaddr + fp->reg_rxctrl));
> +	writel(0x0, (void *)(ioaddr + fp->reg_txctrl));
> +
> +	/* Disable interrupts by clearing the interrupt mask. */
> +	set_int_mask(fp->channel_number, 0x0, fp->this_card_priv);
> +
> +	/* unregister irq */
> +	free_irq(dev->irq, dev);
> +
> +	{
> +		unsigned i = min(RX_RING_SIZE, TX_RING_SIZE) - 1;
> +		do {
> +			dma_addr_t bus_address = readl(&fp->rx_desc[i].desc_a);
> +			if (likely(!pci_dma_mapping_error(bus_address)))
> +				pci_unmap_single(fp->this_card_priv->
> +						 pci_dev, bus_address,
> +						 fp->unit_sz,
> +						 PCI_DMA_FROMDEVICE);
> +			bus_address = readl(&fp->tx_desc[i].desc_a);
> +			if (likely(!pci_dma_mapping_error(bus_address)))
> +				pci_unmap_single(fp->this_card_priv->
> +						 pci_dev, bus_address,
> +						 fp->unit_sz, PCI_DMA_TODEVICE);
> +		}
> +		while (i--);
> +	}
> +
> +	up_write(&fp->this_card_priv->semaphore);
> +	return 0;
> +}
> +
> +static int fepci_stream_close(struct net_device *dev)
> +{
> +	struct fepci_ch_private *fp = dev->priv;
> +	unsigned rx_pages, tx_pages, rx_order, tx_order;
> +
> +	if (fepci_stream_stop(dev))
> +		return -ENODEV;
> +	down_write(&fp->this_card_priv->semaphore);
> +	if (!(fp->in_stream_mode)) {
> +		up_write(&fp->this_card_priv->semaphore);
> +		return -ENODEV;
> +	}
> +	/* release memory */
> +	if (fp->bufsize_order < PAGE_SHIFT) {
> +		rx_order = 0;
> +		tx_order = 0;
> +		rx_pages = 1;
> +		tx_pages = 1;
> +	} else {
> +		rx_order = (int)((fp->bufsize_order) - PAGE_SHIFT + 1);
> +		rx_pages = 1 << rx_order;
> +		tx_order = (int)((fp->bufsize_order) - PAGE_SHIFT);
> +		tx_pages = 1 << tx_order;
> +	}
> +	if (fp->rx_buffer) {
> +		unsigned page_number;
> +		for (page_number = 0; page_number < rx_pages; page_number++)
> +			/* turn pages back to non-reserved */
> +			ClearPageReserved(virt_to_page
> +					  ((unsigned long)fp->rx_buffer +
> +					   (page_number << PAGE_SHIFT)));
> +		free_pages((unsigned long)fp->rx_buffer, rx_order);
> +		fp->rx_buffer = NULL;
> +	}
> +	if (fp->tx_buffer) {
> +		unsigned page_number;
> +		for (page_number = 0; page_number < tx_pages; page_number++)
> +			/* turn pages back to non-reserved */
> +			ClearPageReserved(virt_to_page
> +					  ((unsigned long)fp->tx_buffer +
> +					   (page_number << PAGE_SHIFT)));
> +		free_pages((unsigned long)fp->tx_buffer, tx_order);
> +		fp->tx_buffer = NULL;
> +	}
> +
> +	fp->in_stream_mode = 0;
> +	up_write(&fp->this_card_priv->semaphore);
> +	return 0;
> +}
> +
> +static irqreturn_t fepci_stream_interrupt(int irq, void *dev_instance)
> +{
> +	struct net_device *dev = dev_instance;
> +	struct fepci_ch_private *fp = dev->priv;
> +	void *ioaddr = (void *)dev->base_addr;
> +	unsigned intr_status = get_int_status(fp->channel_number, ioaddr);
> +	bool fifo, dropped;
> +	unsigned int temp_rx;
> +	unsigned int temp_rx_unit;
> +	unsigned int temp_tx;
> +	unsigned int temp_tx_unit;
> +
> +	clear_int(fp->channel_number, intr_status, ioaddr);
> +
> +	/* debugging */
> +	fp->interrupts_stream++;
> +	fifo = (intr_status & IntrRxFifoError) != 0;
> +	dropped = (intr_status & IntrRxFrameDroppedError) != 0;
> +	fp->int_err_table_stream[fifo][dropped]++;
> +	if (intr_status & IntrFrameReceived)
> +		fp->rx_interrupts_stream++;
> +	if (intr_status & IntrFrameTransmitted)
> +		fp->tx_interrupts_stream++;
> +	if (fifo)
> +		fp->rx_int_fifo_err_stream++;
> +	if (dropped)
> +		fp->rx_int_frame_dropped_err_stream++;
> +	if (intr_status & IntrTxFifoError)
> +		fp->tx_int_fifo_err_stream++;
> +	/* first update cur_rx, and do stuff if it has moved
> +	   (+ packets have been received) */
> +	{
> +		temp_rx = fp->cur_rx;
> +		/* has been received */
> +		while ((readl(&fp->rx_desc[fp->cur_rx].desc_b) &
> +			transfer_not_done) == 0
> +		       /* stop if made one round */
> +		       && temp_rx != ((fp->cur_rx + 1) & (RX_RING_SIZE - 1))) {
> +			dma_addr_t bus_address = readl(&fp->rx_desc[fp->cur_rx].
> +						       desc_a);
> +			if (likely(!pci_dma_mapping_error(bus_address)))
> +				pci_unmap_single(fp->this_card_priv->
> +						 pci_dev, bus_address,
> +						 fp->unit_sz,
> +						 PCI_DMA_FROMDEVICE);
> +			fp->cur_rx = (fp->cur_rx + 1) & (RX_RING_SIZE - 1);
> +			fp->cur_rx_unit = (fp->cur_rx_unit + 1);
> +			fp->cur_rx_unit *= fp->cur_rx_unit < fp->units;
> +
> +			*USER_RX_S_POINTER(fp->this_card_priv->
> +					   card_number,
> +					   fp->channel_number,
> +					   stream_pointers) = fp->cur_rx_unit;
> +			*USER_RX_S_FAKE_POINTER(fp->this_card_priv->
> +						card_number,
> +						fp->channel_number,
> +						stream_pointers) =
> +			    fp->cur_rx_unit * fp->unit_sz / fp->fake_unit_sz;
> +			wake_up_interruptible(&(fp->this_card_priv->
> +						stream_receive_q));
> +			wake_up_interruptible(&(fp->this_card_priv->
> +						stream_both_q));
> +		}
> +	}
> +	/* from the first uninitialized descriptor to cur_rx */
> +	temp_rx = (fp->cur_rx + 1) & (RX_RING_SIZE - 1);
> +	temp_rx_unit = (fp->cur_rx_unit + 1);
> +	temp_rx_unit *= temp_rx_unit < fp->units;
> +
> +	while (temp_rx != fp->cur_rx) {
> +		unsigned desc_b = readl(&fp->rx_desc[temp_rx].desc_b);
> +		if ((desc_b & transfer_not_done) == 0) {
> +			bool fifo = (desc_b & fifo_error) != 0;
> +			bool size = (desc_b & size_error) != 0;
> +			bool crc = (desc_b & crc_error) != 0;
> +			bool octet = (desc_b & octet_error) != 0;
> +			bool line = (desc_b & line_error) != 0;
> +			unsigned length = desc_b & frame_length;
> +			dma_addr_t bus_address;
> +			/* update debug counters */
> +			fp->rx_desc_err_table_stream[fifo]
> +			    [size]
> +			    [crc]
> +			    [octet]
> +			    [line]++;
> +			if (length == 0)
> +				fp->rx_packets_of_size_0_stream++;
> +			else if (length == 1)
> +				fp->rx_packets_of_size_1_stream++;
> +			else if (length == 2)
> +				fp->rx_packets_of_size_2_stream++;
> +			else if (length == 3)
> +				fp->rx_packets_of_size_3_stream++;
> +			else if (length < 8)
> +				fp->rx_packets_of_size_4_7_stream++;
> +			else if (length < 16)
> +				fp->rx_packets_of_size_8_15_stream++;
> +			else if (length < 32)
> +				fp->rx_packets_of_size_16_31_stream++;
> +			if (fifo)
> +				fp->rx_desc_fifo_err_stream++;
> +			else if (size)
> +				fp->rx_desc_size_err_stream++;
> +			else if (crc)
> +				fp->rx_desc_crc_err_stream++;
> +			else if (octet)
> +				fp->rx_desc_octet_err_stream++;
> +			else if (line)
> +				fp->rx_desc_line_err_stream++;
> +			/* initialize the descriptor for transfer */
> +			bus_address =
> +			    pci_map_single(fp->this_card_priv->pci_dev,
> +					   fp->rx_unit[temp_rx_unit],
> +					   fp->unit_sz, PCI_DMA_FROMDEVICE);
> +			if (likely(!pci_dma_mapping_error(bus_address))) {
> +				writel(bus_address,
> +				       &fp->rx_desc[temp_rx].desc_a);
> +				writel(enable_transfer,
> +				       &fp->rx_desc[temp_rx].desc_b);
> +			} else
> +				printk(KERN_WARNING
> +				       "%s: failed to map DMA for reception.\n",
> +				       fepci_NAME);
> +		}
> +		temp_rx = (temp_rx + 1) & (RX_RING_SIZE - 1);
> +		temp_rx_unit = (temp_rx_unit + 1);
> +		temp_rx_unit *= temp_rx_unit < fp->units;
> +	}
> +
> +	/* first update cur_tx, and do stuff if it has moved
> +	   (+ packets have been transmitted) */
> +	{
> +		temp_tx = fp->cur_tx;
> +		/* has been transmitted */
> +		while ((readl(&fp->tx_desc[fp->cur_tx].desc_b) &
> +			transfer_not_done) == 0
> +		       /* stop if made one round */
> +		       && temp_tx != ((fp->cur_tx + 1) & (TX_RING_SIZE - 1))) {
> +			dma_addr_t bus_address = readl(&fp->tx_desc[fp->cur_tx].
> +						       desc_a);
> +			if (likely(!pci_dma_mapping_error(bus_address)))
> +				pci_unmap_single(fp->this_card_priv->
> +						 pci_dev, bus_address,
> +						 fp->unit_sz, PCI_DMA_TODEVICE);
> +			fp->cur_tx = (fp->cur_tx + 1) & (TX_RING_SIZE - 1);
> +			fp->cur_tx_unit = (fp->cur_tx_unit + 1);
> +			fp->cur_tx_unit *= fp->cur_tx_unit < fp->units;
> +
> +			*USER_TX_S_POINTER(fp->this_card_priv->
> +					   card_number,
> +					   fp->channel_number,
> +					   stream_pointers) = fp->cur_tx_unit;
> +			*USER_TX_S_FAKE_POINTER(fp->this_card_priv->
> +						card_number,
> +						fp->channel_number,
> +						stream_pointers) =
> +			    fp->cur_tx_unit * fp->unit_sz / fp->fake_unit_sz;
> +			wake_up_interruptible(&(fp->this_card_priv->
> +						stream_transmit_q));
> +			wake_up_interruptible(&(fp->this_card_priv->
> +						stream_both_q));
> +		}
> +	}
> +	/* from the first uninitialized descriptor to cur_tx */
> +	temp_tx = (fp->cur_tx + 1) & (TX_RING_SIZE - 1);
> +	temp_tx_unit = (fp->cur_tx_unit + 1);
> +	temp_tx_unit *= temp_tx_unit < fp->units;
> +
> +	while (temp_tx != fp->cur_tx) {
> +		unsigned desc_b = readl(&fp->tx_desc[temp_tx].desc_b);
> +		if ((desc_b & transfer_not_done) == 0) {
> +			dma_addr_t bus_address;
> +			/* update debug counters */
> +			if (desc_b & fifo_error)
> +				fp->tx_desc_fifo_err_stream++;
> +			/* initialize the desctiptor for transfer */
> +			bus_address =
> +			    pci_map_single(fp->this_card_priv->pci_dev,
> +					   fp->tx_unit[temp_tx_unit],
> +					   fp->unit_sz, PCI_DMA_TODEVICE);
> +			writel(bus_address, &fp->tx_desc[temp_tx].desc_a);
> +			if (likely(!pci_dma_mapping_error(bus_address)))
> +				writel(enable_transfer |
> +				       (fp->unit_sz & frame_length),
> +				       &fp->tx_desc[temp_tx].desc_b);
> +			else
> +				printk(KERN_WARNING
> +				       "%s: failed to map tranmission DMA.\n",
> +				       fepci_NAME);
> +		}
> +		temp_tx = (temp_tx + 1) & (TX_RING_SIZE - 1);
> +		temp_tx_unit = (temp_tx_unit + 1);
> +		temp_tx_unit *= temp_tx_unit < fp->units;
> +	}
> +
> +	return intr_status ? IRQ_HANDLED : IRQ_NONE;
> +}
> +
> +/* stream operations end */
> +
> +int fepci_rebuild_header(struct sk_buff *skb)
> +{
> +	DBG_PRINT("fepci_rebuild_header\n");
> +	return 0;
> +}
> +
> +static inline u16 get_common_reg_word(void *ioaddr, unsigned long offsett)
> +{
> +	u16 word;
> +	DBG_PRINT("get_common_reg_word ioaddr %p, offsett %lu\n", ioaddr,
> +		  offsett);
> +	__clear_bit(0, &offsett);
> +	DBG_PRINT("get_common_reg_word %p\n",
> +		  ioaddr + FEPCI_IDENTIFICATION_OFFSETT + (offsett << 1));
> +	word = le16_to_cpu(readw
> +			   (ioaddr + FEPCI_IDENTIFICATION_OFFSETT +
> +			    (offsett << 1)));
> +	DBG_PRINT("get_common_reg_word %p: %hu\n",
> +		  ioaddr + FEPCI_IDENTIFICATION_OFFSETT + (offsett << 1), word);
> +	return word;
> +}
> +
> +static irqreturn_t alarm_manager_interrupt(int irq, void *pointer)
> +{
> +	struct fepci_card_private *card_private = pointer;
> +	void *ioaddr = card_private->ioaddr;
> +	/* check int status */
> +	if (readl((void *)(ioaddr + reg_custom)) & AM_interrupt_status) {
> +		/* clear int (zero everything, but the mask bit) */
> +		writel(readl((void *)(ioaddr + reg_custom)) &
> +		       AM_interrupt_mask, (void *)(ioaddr + reg_custom));
> +		/* wake queue */
> +		wake_up(&(card_private->alarm_manager_wait_q));
> +	}
> +
> +	return IRQ_HANDLED;
> +}
> +
> +#ifdef FEPCI_POINT_TO_POINT
> +static int is_ptp_interface(struct net_device *dev)
> +{
> +	char **p_ptp_if_name = retina_ptp_interfaces;
> +	unsigned int i = interfaces;
> +	while (i > 0 && *p_ptp_if_name != NULL) {
> +		if (!strncmp(dev->name, *p_ptp_if_name, sizeof(dev->name)))
> +			return 1;
> +		p_ptp_if_name++;
> +		i--;
> +	}
> +	return 0;
> +}
> +#endif /* FEPCI_POINT_TO_POINT */
> +
> +static int __devinit fepci_init_one(struct pci_dev *pdev,
> +				    const struct pci_device_id *ent)
> +{
> +	struct net_device *dev = NULL;
> +	struct fepci_ch_private *fp = NULL;
> +	int chip_idx = ent->driver_data;
> +	int drv_flags = pci_id_tbl[chip_idx].drv_flags;
> +	int i;
> +	unsigned j;
> +	resource_size_t real_ioaddr;
> +	void *ioaddr;
> +	unsigned position;
> +
> +	i = pci_enable_device(pdev);
> +	if (i) {
> +		printk(KERN_WARNING "%s: pci_enable_device returned %x.\n",
> +		       fepci_NAME, i);
> +		return i;
> +	}
> +
> +	pci_set_master(pdev);
> +
> +	i = pci_request_regions(pdev, (char *)fepci_name);
> +	if (i) {
> +		printk(KERN_WARNING
> +		       "%s: pci_request_regions returned %x.\n", fepci_NAME, i);
> +		pci_disable_device(pdev);
> +		return i;
> +	}
> +
> +	/* make sure above region is MMIO */
> +	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
> +		printk(KERN_WARNING "%s: region not MMIO region\n", fepci_NAME);
> +		goto ERR_1;
> +	}
> +
> +	j = pci_resource_len(pdev, 0);
> +	if (j < FEPCI_SIZE) {
> +		printk(KERN_WARNING
> +		       "%s: resource length %u less than required %u.\n",
> +		       fepci_NAME, j, FEPCI_SIZE);
> +		goto ERR_1;
> +	}
> +
> +	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
> +		printk(KERN_WARNING "%s: no suitable DMA available.\n",
> +		       fepci_NAME);
> +		goto ERR_1;
> +	}
> +
> +	real_ioaddr = pci_resource_start(pdev, 0);
> +	DBG_PRINT("pci_resource_start %lu.\n", real_ioaddr);
> +	ioaddr = ioremap_nocache(real_ioaddr, FEPCI_SIZE);
> +	DBG_PRINT("ioremap_nocache = %p.\n", ioaddr);
> +	if (!ioaddr) {
> +		printk(KERN_WARNING "%s: remapping failed.\n", fepci_NAME);
> +		goto ERR_1_5;
> +	}
> +	position = 0;
> +	for (; position < MAX_DEVICES; position++) {
> +		down_write(&card_privates[position].semaphore);
> +		if (card_privates[position].pci_dev == NULL) {
> +			card_privates[position].pci_dev = pdev;
> +			if (position == find_cnt)
> +				find_cnt++;
> +			goto FOUND;
> +		}
> +		up_write(&card_privates[position].semaphore);
> +	}
> +	printk(KERN_WARNING
> +	       "%s: no space to inialize device #%u.\n",
> +	       fepci_NAME, MAX_DEVICES + 1);
> +	goto ERR_2;
> +FOUND:
> +	card_privates[position].card_number = position;
> +	card_privates[position].ioaddr = ioaddr;
> +	card_privates[position].pci_dev = pdev;
> +	DBG_PRINT("fillregisterswith_00 %p.\n", ioaddr);
> +	fillregisterswith_00(ioaddr);
> +
> +	fepci_proc_init_card(position, (void *)&(card_privates[position]));
> +
> +	init_waitqueue_head(&(card_privates[position].alarm_manager_wait_q));
> +	init_waitqueue_head(&(card_privates[position].stream_transmit_q));
> +	init_waitqueue_head(&(card_privates[position].stream_receive_q));
> +	init_waitqueue_head(&(card_privates[position].stream_both_q));
> +
> +	init_timer(&card_privates[position].mailbox_timer);
> +
> +	DBG_PRINT("request_irq %d, %s.\n", pdev->irq, fepci_alarm_manager_name);
> +	i = request_irq(pdev->irq, &alarm_manager_interrupt,
> +			IRQF_SHARED,
> +			fepci_alarm_manager_name, &card_privates[position]);
> +	if (i) {
> +		up_write(&card_privates[position].semaphore);
> +		printk(KERN_WARNING
> +		       "%s: unable to allocate IRQ %d alarm manager: 0x%x\n",
> +		       fepci_NAME, pdev->irq, i);
> +		goto ERR_2;
> +	}
> +	DBG_PRINT("alarm manager int on %p.\n", (void *)(ioaddr + reg_custom));
> +	writel(AM_interrupt_mask, (void *)(ioaddr + reg_custom));
> +	/* alarm manager int on */
> +
> +	for (j = 0; j < CHANNELS; j++) {
> +		DBG_PRINT("alloc_etherdev %u.\n", j);
> +		dev = alloc_etherdev(sizeof(struct fepci_ch_private));
> +		if (!dev) {
> +			printk(KERN_WARNING
> +			       "%s: cannot allocate ethernet device\n",
> +			       fepci_NAME);
> +			continue;
> +		}
> +
> +		fp = dev->priv;
> +		fp->minor = position;	/* * CHANNELS + j; */
> +		/* name := xxx01..xxxnn */
> +		memcpy(dev->name, fepci_netdev_name, 6);
> +		/* dev->name[3]= j+'0';    channel number -> ascii */
> +		/* minor number -> ascii */
> +		dev->name[4] = ((fp->minor * CHANNELS + j) % 10) + '0';
> +		/* minor number -> ascii */
> +		dev->name[3] = ((fp->minor * CHANNELS + j) / 10) + '0';
> +
> +		SET_MODULE_OWNER(dev);
> +		DBG_PRINT("clear_int %u, %x, %p.\n", j, IntrAllInts, ioaddr);
> +		clear_int(j, IntrAllInts, ioaddr);
> +		DBG_PRINT("ether_setup %p.\n", dev);
> +		ether_setup(dev);
> +
> +		random_ether_addr(dev->dev_addr);
> +		/* HW_ADDR is got using the mailbox: */
> +		{
> +			struct fepci_real_mailbox *real_mailbox =
> +			    (struct fepci_real_mailbox *)
> +			    (ioaddr + FEPCI_MAILBOX_OFFSETT);
> +			unsigned long waituntil;
> +
> +			set_semafore(real_mailbox, 0x40);
> +			writel(0x1 /*size */  +
> +			       (0x8 << 8) /* get mac command */ ,
> +			       &real_mailbox->Size_Command);
> +			set_semafore(real_mailbox, 0x11);
> +
> +			waituntil = jiffies + HZ;
> +			while (time_before(jiffies, waituntil) &&
> +			       get_semafore(real_mailbox) != 0x20) {
> +				DBG_PRINT("jiffies %lu < waituntil %lu.\n",
> +					  jiffies, waituntil);
> +				msleep(0);
> +			}
> +
> +			/* 14.5.2004 JT: Made this safer. */
> +			if (get_semafore(real_mailbox) == 0x20) {
> +				dev->dev_addr[5] =
> +				    readb(&real_mailbox->Data[0 + 3 * j]);
> +				dev->dev_addr[4] =
> +				    readb(((u8 *) & real_mailbox->
> +					   Data[0 + 3 * j]) + 1);
> +				dev->dev_addr[3] =
> +				    readb(&real_mailbox->Data[1 + 3 * j]);
> +				dev->dev_addr[2] =
> +				    readb(((u8 *) & real_mailbox->
> +					   Data[1 + 3 * j]) + 1);
> +				dev->dev_addr[1] =
> +				    readb(&real_mailbox->Data[2 + 3 * j]);
> +				dev->dev_addr[0] =
> +				    readb(((u8 *) & real_mailbox->
> +					   Data[2 + 3 * j]) + 1);
> +			}
> +
> +			set_semafore(real_mailbox, 0x0);
> +		}
> +		dev->addr_len = 6;
> +
> +		dev->base_addr = (unsigned long)ioaddr;
> +		dev->irq = pdev->irq;
> +		DBG_PRINT("alarm pci_set_drvdata %p, %p.\n", pdev, dev);
> +		if (j == 0)
> +			pci_set_drvdata(pdev, dev);
> +
> +		fp->drv_flags = drv_flags;
> +
> +		fp->rx_desc =
> +		    (struct fepci_desc *)(dev->base_addr + first_rx_desc +
> +					  j * to_next_ch_rx_desc);
> +		fp->tx_desc =
> +		    (struct fepci_desc *)(dev->base_addr + first_tx_desc +
> +					  j * to_next_ch_tx_desc);
> +
> +		fp->channel_number = j;	/*channel in this device */
> +		fp->this_dev = dev;
> +
> +		fp->this_card_priv = &card_privates[position];
> +		fp->this_card_priv->ch_privates[j] = fp;
> +
> +		fp->cur_tx = 0;
> +
> +		fp->in_stream_mode = 0;
> +		fp->in_eth_mode = 0;
> +
> +		fp->reg_rxctrl = reg_first_rxctrl + j * to_next_rxctrl;
> +		fp->reg_txctrl = reg_first_txctrl + j * to_next_txctrl;
> +
> +		/* The FEPCI specific entries in the device structure */
> +		dev->open = &fepci_open;
> +		dev->hard_start_xmit = &fepci_start_xmit;
> +		dev->stop = &fepci_close;
> +		dev->get_stats = &fepci_get_stats;
> +		dev->set_multicast_list = &set_rx_mode;
> +		dev->do_ioctl = &netdev_ioctl;
> +		dev->tx_timeout = fepci_tx_timeout;
> +		dev->watchdog_timeo = TX_TIMEOUT;
> +
> +#ifdef FEPCI_POINT_TO_POINT
> +		if (is_ptp_interface(dev)) {
> +			dev->flags |= (IFF_POINTOPOINT);
> +			dev->flags &= ~(IFF_BROADCAST | IFF_MULTICAST);
> +			if (retina_noarp_with_ptp) {
> +				dev->rebuild_header = fepci_rebuild_header;
> +				dev->flags |= (IFF_NOARP);
> +			}
> +		}
> +#endif
> +		DBG_PRINT("register_netdev %p.\n", dev);
> +		i = register_netdev(dev);
> +		if (i) {
> +			printk(KERN_WARNING
> +			       "%s: register_netdev failed 0x%x.\n",
> +			       fepci_NAME, i);
> +			continue;
> +		}
> +
> +		printk("%s: %s type %x at %p, ",
> +		       dev->name, pci_id_tbl[chip_idx].name, 0x0, ioaddr);
> +		for (i = 0; i < 5; i++)
> +			printk("%2.2x:", dev->dev_addr[i]);
> +		printk("%2.2x, IRQ %d.\n", dev->dev_addr[i], pdev->irq);
> +#ifdef DEBUG_PROC_FILES
> +		fepci_proc_init_channel(position, j, fp);
> +#endif /* DEBUG_PROC_FILES */
> +	}
> +	up_write(&card_privates[position].semaphore);
> +	DBG_PRINT("fepci_init_one %u.\n", position);
> +	return 0;
> +
> +ERR_2:
> +	iounmap(ioaddr);
> +ERR_1_5:
> +	pci_set_drvdata(pdev, NULL);
> +ERR_1:
> +	pci_disable_device(pdev);
> +	pci_release_regions(pdev);
> +	return -ENODEV;
> +}
> +
> +static int fepci_open(struct net_device *dev)
> +{
> +	struct fepci_ch_private *fp = dev->priv;
> +
> +	down_write(&fp->this_card_priv->semaphore);
> +
> +	if (fp->this_card_priv->pci_dev == NULL) {
> +		up_write(&fp->this_card_priv->semaphore);
> +		fepci_close(dev);
> +		return -ENXIO;
> +	}
> +
> +	while (fp->in_stream_mode) {
> +		up_write(&fp->this_card_priv->semaphore);
> +		fepci_stream_close(dev);
> +		down_write(&fp->this_card_priv->semaphore);
> +	}
> +
> +	{
> +		int i = request_irq(dev->irq, &fepci_interrupt,
> +				    IRQF_SHARED, dev->name, dev);
> +		if (i) {
> +			up_write(&fp->this_card_priv->semaphore);
> +			printk(KERN_WARNING
> +			       "%s: unable to allocate IRQ %d, error 0x%x",
> +			       fepci_NAME, dev->irq, i);
> +			return i;
> +		}
> +	}
> +
> +	fp->in_eth_mode = 1;
> +
> +	fepci_init_ring(dev);
> +	set_rx_mode(dev);
> +
> +	fp->cur_rx = 0;
> +	fp->cur_tx = 0;
> +
> +	netif_carrier_off(dev);
> +
> +	/* Enable interrupts by setting the interrupt mask. */
> +
> +	set_int_mask(fp->channel_number,
> +		     MaskFrameReceived | MaskFrameTransmitted |
> +		     MaskRxFifoError | MaskRxFrameDroppedError |
> +		     MaskTxFifoError, fp->this_card_priv);
> +
> +	{
> +		void *ioaddr = (void *)dev->base_addr;
> +
> +		/* Start Rx and Tx channels. */
> +		writel(Receive_enable |
> +		       (Rx_fifo_threshold & RX_FIFO_THRESHOLD_PACKET_MODE),
> +		       (void *)(ioaddr + fp->reg_rxctrl));
> +
> +		writel((Transmit_enable |
> +			(Tx_desc_threshold &
> +			 (TX_DESC_THRESHOLD_PACKET_MODE << 8)) |
> +			(Tx_fifo_threshold & TX_FIFO_THRESHOLD_PACKET_MODE)),
> +		       (void *)(ioaddr + fp->reg_txctrl));
> +	}
> +
> +	netif_start_queue(dev);
> +
> +	/* Set timer */
> +	init_timer(&fp->timer);
> +	fp->timer.expires = jiffies + HZ;
> +	fp->timer.data = (unsigned long)dev;
> +	fp->timer.function = &fepci_timer;	/* timer handler */
> +	add_timer(&fp->timer);
> +
> +	up_write(&fp->this_card_priv->semaphore);
> +
> +	return 0;
> +}
> +
> +static void fepci_timer(unsigned long data)
> +{
> +	struct net_device *dev = (struct net_device *)data;
> +	struct fepci_ch_private *fp = dev->priv;
> +
> +	/* just to make it absolutely sure the sending starts again
> +	 * if the system jams: free already sent skbuffs */
> +
> +	if (netif_tx_trylock(dev)) {
> +		if (!(fp->tx_interrupts_since_last_timer)) {
> +			unsigned i = TX_RING_SIZE - 1;
> +			do {
> +				unsigned desc_b;
> +				if ((fp->tx_skbuff[i] != NULL)
> +				    &&
> +				    (((desc_b =
> +				       readl(&fp->tx_desc[i].
> +					     desc_b)) & transfer_not_done) ==
> +				     0)) {
> +					/* has been sent */
> +					pci_unmap_single(fp->
> +							 this_card_priv->
> +							 pci_dev,
> +							 readl(&fp->
> +							       tx_desc[i].
> +							       desc_a),
> +							 desc_b &
> +							 frame_length,
> +							 PCI_DMA_TODEVICE);
> +					dev_kfree_skb(fp->tx_skbuff[i]);
> +					fp->tx_skbuffs_out++;
> +
> +					fp->tx_skbuff[i] = NULL;
> +
> +					if (desc_b & fifo_error) {
> +						fp->stats.tx_fifo_errors++;
> +						fp->tx_desc_fifo_err++;
> +					} else
> +						fp->stats.tx_packets++;
> +				}
> +			}
> +			while (i--);
> +		}
> +		/* if the next descriptor is free, continue taking new ones */
> +		if (!
> +		    (readl(&fp->tx_desc[fp->cur_tx].desc_b) &
> +		     transfer_not_done))
> +			netif_wake_queue(dev);
> +		netif_tx_unlock(dev);
> +	}
> +
> +	fp->tx_interrupts_since_last_timer = 0;
> +
> +	if ((get_common_reg_word(fp->this_card_priv->ioaddr, 0x72) >> fp->
> +	     channel_number) & 1) {
> +		netif_carrier_off(dev);
> +	} else {
> +		netif_carrier_on(dev);
> +	}
> +
> +	if (fp->in_eth_mode)
> +		mod_timer(&fp->timer, jiffies + 5 * HZ);
> +}
> +
> +static void fepci_tx_timeout(struct net_device *dev)
> +{
> +	DBG_PRINT("%s: transmit timed out!\n", dev->name);
> +}
> +
> +/* Initialize the rx and tx rings */
> +static void fepci_init_ring(struct net_device *dev)
> +{
> +	struct fepci_ch_private *fp = dev->priv;
> +	unsigned i;
> +
> +	fp->rx_buf_sz = 2000;
> +
> +	for (i = 0; i < RX_RING_SIZE; i++) {
> +		struct sk_buff *skb =
> +		    __dev_alloc_skb(fp->rx_buf_sz, GFP_KERNEL);
> +
> +		if (unlikely(skb == NULL)) {
> +ZERO:
> +			writel(0, &fp->rx_desc[i].desc_a);
> +			writel(0, &fp->rx_desc[i].desc_b);
> +			continue;
> +		} else {
> +			dma_addr_t bus_address =
> +			    pci_map_single(fp->this_card_priv->pci_dev,
> +					   skb->data, fp->rx_buf_sz,
> +					   PCI_DMA_FROMDEVICE);
> +			if (likely(!pci_dma_mapping_error(bus_address))) {
> +				fp->rx_skbuffs_in++;
> +				/* Mark as being used by this device */
> +				skb->dev = dev;
> +				skb->ip_summed = CHECKSUM_UNNECESSARY;
> +				fp->rx_skbuff[i] = skb;
> +				writel(bus_address, &fp->rx_desc[i].desc_a);
> +				writel(enable_transfer, &fp->rx_desc[i].desc_b);
> +			} else {
> +				dev_kfree_skb(skb);
> +				goto ZERO;
> +			}
> +		}
> +	}
> +
> +	for (i = 0; i < TX_RING_SIZE; i++) {
> +		fp->tx_skbuff[i] = NULL;
> +		writel(0, &fp->tx_desc[i].desc_a);	/* no skbuff */
> +		/* no transfer enable, no int enable */
> +		writel(0, &fp->tx_desc[i].desc_b);
> +	}
> +
> +	return;
> +}
> +
> +static int fepci_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct fepci_ch_private *fp = dev->priv;
> +	const unsigned cur_tx = fp->cur_tx;
> +	unsigned next;
> +	unsigned tx_length = skb->len;
> +	dma_addr_t bus_address;
> +	struct sk_buff *old;
> +
> +	fp->tx_skbuffs_in++;
> +
> +	if (unlikely(tx_length < ETH_ZLEN)) {
> +		struct sk_buff *bigger =
> +		    skb_copy_expand(skb, 0, ETH_ZLEN - tx_length,
> +				    GFP_ATOMIC);
> +		if (unlikely(!bigger))
> +			return NET_XMIT_CN;
> +		tx_length = ETH_ZLEN;
> +		old = skb;
> +		skb = bigger;
> +	} else
> +		old = NULL;
> +	bus_address =
> +	    pci_map_single(fp->this_card_priv->pci_dev, skb->data,
> +			   tx_length, PCI_DMA_TODEVICE);
> +	if (likely(!pci_dma_mapping_error(bus_address))) {
> +		struct fepci_desc *descriptor;
> +		if (old)
> +			dev_kfree_skb(old);
> +		descriptor = &fp->tx_desc[cur_tx];
> +		writel(bus_address, &descriptor->desc_a);
> +		writel((tx_length & frame_length) | enable_transfer,
> +		       &descriptor->desc_b);
> +	} else {
> +		if (old)
> +			dev_kfree_skb(skb);
> +		return NET_XMIT_CN;
> +	}
> +	fp->stats.tx_bytes += tx_length;
> +
> +	fp->tx_skbuff[cur_tx] = skb;
> +
> +	/* Calculate the next Tx descriptor entry */
> +	next = (cur_tx + 1) & (TX_RING_SIZE - 1);
> +	fp->cur_tx = next;
> +	/* if the next descriptor is busy, discontinue taking new ones */
> +	if (fp->tx_skbuff[next] != NULL)
> +		netif_stop_queue(dev);
> +	dev->trans_start = jiffies;
> +
> +	return NET_XMIT_SUCCESS;
> +}
> +
> +static irqreturn_t fepci_interrupt(int irq, void *dev_instance)
> +{
> +	struct net_device *dev = dev_instance;
> +	void *ioaddr = (void *)dev->base_addr;
> +	struct fepci_ch_private *fp = dev->priv;
> +	unsigned intr_status = get_int_status(fp->channel_number, ioaddr);
> +	bool RxFifoError;
> +	bool RxFrameDroppedError;
> +
> +	clear_int(fp->channel_number, intr_status, ioaddr);
> +
> +	RxFifoError = (intr_status & IntrRxFifoError) != 0;
> +	RxFrameDroppedError = (intr_status & IntrRxFrameDroppedError) != 0;
> +	/* first update interrupt error table */
> +	fp->int_err_table[RxFifoError][RxFrameDroppedError]++;
> +
> +	fp->interrupts++;
> +
> +	if (intr_status & IntrFrameReceived) {
> +		fepci_rx(dev);
> +		fp->rx_interrupts++;
> +	}
> +	if (intr_status & IntrFrameTransmitted) {
> +		fp->tx_interrupts_since_last_timer++;
> +		if (netif_tx_trylock(dev)) {
> +			unsigned i = TX_RING_SIZE - 1;
> +			unsigned next;
> +			do {
> +				unsigned desc_b;
> +				if ((fp->tx_skbuff[i] != NULL)
> +				    &&
> +				    (((desc_b =
> +				       readl(&fp->tx_desc[i].
> +					     desc_b)) & transfer_not_done) ==
> +				     0)) {
> +					/* has been sent */
> +					pci_unmap_single(fp->
> +							 this_card_priv->
> +							 pci_dev,
> +							 readl(&fp->
> +							       tx_desc[i].
> +							       desc_a),
> +							 desc_b &
> +							 frame_length,
> +							 PCI_DMA_TODEVICE);
> +					dev_kfree_skb_irq(fp->tx_skbuff[i]);
> +					fp->tx_skbuffs_out++;
> +					fp->tx_skbuff[i] = NULL;
> +					if (desc_b & fifo_error) {
> +						fp->stats.tx_fifo_errors++;
> +						fp->tx_desc_fifo_err++;
> +					} else
> +						fp->stats.tx_packets++;
> +				}
> +			}
> +			while (i--);
> +			next = fp->cur_tx;
> +			/* if next tx descriptor is free,
> +			 * continue taking new ones */
> +			if (!(readl(&fp->tx_desc[next].desc_b) &
> +			      transfer_not_done))
> +				netif_wake_queue(dev);
> +			netif_tx_unlock(dev);
> +		}
> +		fp->tx_interrupts++;
> +	}
> +	if (RxFifoError) {
> +		fp->rx_int_fifo_err++;
> +		fepci_rx(dev);
> +	}
> +	if (RxFrameDroppedError) {
> +		fp->rx_int_frame_dropped_err++;
> +		fepci_rx(dev);
> +	}
> +	if (intr_status & IntrTxFifoError)
> +		fp->tx_int_fifo_err++;
> +	return intr_status ? IRQ_HANDLED : IRQ_NONE;
> +}
> +
> +static int fepci_rx(struct net_device *dev)
> +{
> +	struct fepci_ch_private *fp = dev->priv;
> +
> +	unsigned int i, old_cur_rx = fp->cur_rx;
> +	for (i = old_cur_rx;
> +	     i != ((old_cur_rx + RX_RING_SIZE - 1) & (RX_RING_SIZE - 1));
> +	     i = (i + 1) & (RX_RING_SIZE - 1)) {
> +		unsigned desc_b;
> +		struct sk_buff *skb;
> +		/* transfer done */
> +		bool condition = (skb = fp->rx_skbuff[i]) &&
> +		    ((desc_b =
> +		      readl(&fp->rx_desc[i].desc_b)) & transfer_not_done) == 0;
> +		if (condition) {
> +			bool fifo = (desc_b & fifo_error) != 0;
> +			bool size = (desc_b & size_error) != 0;
> +			bool crc = (desc_b & crc_error) != 0;
> +			bool octet = (desc_b & octet_error) != 0;
> +			bool line = (desc_b & line_error) != 0;
> +			unsigned length = desc_b & frame_length;
> +			pci_unmap_single(fp->this_card_priv->pci_dev,
> +					 readl(&fp->rx_desc[i].desc_a),
> +					 fp->rx_buf_sz, PCI_DMA_FROMDEVICE);
> +			fp->cur_rx = (i + 1) & (RX_RING_SIZE - 1);
> +			/* first update error table */
> +			fp->rx_desc_err_table[fifo]
> +			    [size]
> +			    [crc]
> +			    [octet]
> +			    [line]++;
> +			/* small packet counters */
> +			if (length == 0)
> +				fp->rx_packets_of_size_0++;
> +			else if (length == 1)
> +				fp->rx_packets_of_size_1++;
> +			else if (length == 2)
> +				fp->rx_packets_of_size_2++;
> +			else if (length == 3)
> +				fp->rx_packets_of_size_3++;
> +			else if (length < 8)
> +				fp->rx_packets_of_size_4_7++;
> +			else if (length < 16)
> +				fp->rx_packets_of_size_8_15++;
> +			else if (length < 32)
> +				fp->rx_packets_of_size_16_31++;
> +
> +			if (fifo) {
> +				fp->stats.rx_errors++;
> +				fp->stats.rx_frame_errors++;
> +				fp->rx_desc_fifo_err++;
> +				writel(enable_transfer, &fp->rx_desc[i].desc_b);
> +			} else if (size) {
> +				fp->stats.rx_errors++;
> +				fp->stats.rx_over_errors++;
> +				fp->rx_desc_size_err++;
> +				writel(enable_transfer, &fp->rx_desc[i].desc_b);
> +			} else if (crc) {
> +				fp->stats.rx_errors++;
> +				fp->stats.rx_crc_errors++;
> +				fp->rx_desc_crc_err++;
> +				writel(enable_transfer, &fp->rx_desc[i].desc_b);
> +			} else if (octet) {
> +				fp->rx_desc_octet_err++;
> +				writel(enable_transfer, &fp->rx_desc[i].desc_b);
> +			} else if (line) {
> +				fp->rx_desc_line_err++;
> +				writel(enable_transfer, &fp->rx_desc[i].desc_b);
> +			} else {
> +				skb_put(skb, length - 4);
> +
> +				skb->protocol = eth_type_trans(skb, dev);
> +#ifdef FEPCI_POINT_TO_POINT
> +				if (dev->flags & IFF_POINTOPOINT) {
> +					/* everything received is for us. */
> +
> +					if (dev->flags & IFF_NOARP) {
> +						/* NOARP applied ->
> +						 * destination MAC addresses
> +						 * are bogus */
> +						if (skb->
> +						    pkt_type ==
> +						    PACKET_OTHERHOST)
> +							skb->
> +							    pkt_type =
> +							    PACKET_HOST;
> +					} else {
> +						/* NOARP not applied ->
> +						 * destination MAC addresses are
> +						 * broadcast */
> +						if (skb->
> +						    pkt_type ==
> +						    PACKET_BROADCAST)
> +							skb->
> +							    pkt_type =
> +							    PACKET_HOST;
> +
> +					}	/* IFF_NOARP */
> +				}	/* IFF_POINTOPOINT */
> +#endif
> +				skb_reset_mac_header(skb);
> +				netif_rx(skb);
> +				fp->rx_skbuffs_out++;
> +				/* statistics -4==crc */
> +				fp->stats.rx_bytes += length - 4;
> +				fp->stats.rx_packets++;
> +
> +				fp->rx_skbuff[i] = NULL;
> +				dev->last_rx = jiffies;
> +			}
> +		}
> +		/* reserve a new one */
> +		if (fp->rx_skbuff[i] == NULL) {
> +			struct sk_buff *skb = dev_alloc_skb(fp->rx_buf_sz);
> +
> +			if (skb == NULL)
> +				continue;	/* Better luck next round. */
> +			else {
> +				dma_addr_t address =
> +				    pci_map_single(fp->this_card_priv->pci_dev,
> +						   skb->data,
> +						   fp->rx_buf_sz,
> +						   PCI_DMA_FROMDEVICE);
> +				if (likely(!pci_dma_mapping_error(address))) {
> +					struct fepci_desc *descriptor;
> +					fp->rx_skbuffs_in++;
> +					fp->rx_skbuff[i] = skb;
> +					/* Mark as being used by this device. */
> +					skb->dev = dev;
> +					skb->ip_summed = CHECKSUM_UNNECESSARY;
> +					descriptor = &fp->rx_desc[i];
> +					writel(address, &descriptor->desc_a);
> +					writel(enable_transfer,
> +					       &descriptor->desc_b);
> +				} else {
> +					dev_kfree_skb(skb);
> +					printk(KERN_WARNING
> +					       "%s: failed to map DMA.\n",
> +					       dev->name);
> +				}
> +			}
> +		}
> +	}
> +	return 0;
> +}
> +
> +static int fepci_close(struct net_device *dev)
> +{
> +	struct fepci_ch_private *fp = dev->priv;
> +	unsigned i;
> +	void *ioaddr = (void *)dev->base_addr;
> +
> +	down_write(&fp->this_card_priv->semaphore);
> +
> +	netif_stop_queue(dev);
> +
> +	/* Disable interrupts by clearing the interrupt mask */
> +	set_int_mask(fp->channel_number, 0x0, fp->this_card_priv);
> +
> +	/* Stop the Tx and Rx processes */
> +	writel(0x0, ioaddr + fp->reg_rxctrl);
> +	writel(0x0, ioaddr + fp->reg_txctrl);
> +	fp->in_eth_mode = 0;
> +
> +	del_timer_sync(&fp->timer);
> +
> +	free_irq(dev->irq, dev);
> +
> +	/* Free all the rx skbuffs */
> +	for (i = 0; i < RX_RING_SIZE; i++) {
> +		if (fp->rx_skbuff[i] != NULL) {
> +			pci_unmap_single(fp->this_card_priv->
> +					 pci_dev,
> +					 readl(&fp->rx_desc[i].
> +					       desc_a),
> +					 fp->rx_buf_sz, PCI_DMA_FROMDEVICE);
> +			dev_kfree_skb(fp->rx_skbuff[i]);
> +			fp->rx_skbuffs_out++;
> +			fp->rx_skbuff[i] = NULL;
> +		}
> +	}
> +	/* and tx */
> +	for (i = 0; i < TX_RING_SIZE; i++) {
> +		if (fp->tx_skbuff[i] != NULL) {
> +			pci_unmap_single(fp->this_card_priv->
> +					 pci_dev,
> +					 readl(&fp->tx_desc[i].
> +					       desc_a),
> +					 readl(&fp->tx_desc[i].
> +					       desc_b) & frame_length,
> +					 PCI_DMA_TODEVICE);
> +			dev_kfree_skb(fp->tx_skbuff[i]);
> +			fp->tx_skbuffs_out++;
> +			fp->tx_skbuff[i] = NULL;
> +		}
> +	}
> +	up_write(&fp->this_card_priv->semaphore);
> +	return 0;
> +}
> +
> +static struct net_device_stats *fepci_get_stats(struct net_device *dev)
> +{
> +	struct fepci_ch_private *fp = dev->priv;
> +	return &fp->stats;
> +}
> +
> +static void set_rx_mode(struct net_device *dev)
> +{
> +	DBG_PRINT("set_rx_mode\n");
> +}
> +
> +static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> +{
> +	struct fepci_ch_private *fp = dev->priv;
> +	char data = ((unsigned)rq->ifr_data) & 0xff;
> +	int ret = 0;
> +
> +	DBG_PRINT("%s: netdev_ioctl called (command_nmbr:0x%x).\n",
> +		  dev->name, cmd);
> +
> +	switch (cmd) {
> +	case FEPCI_NETDEV_IOCTL_STREAM_BUFSIZE:
> +		DBG_PRINT
> +		    (" ioctl stream bufsize commanded. (bufsize:0x%x)\n", data);
> +		down_write(&fp->this_card_priv->semaphore);
> +		if (fp->in_stream_mode) {
> +			up_write(&fp->this_card_priv->semaphore);
> +			return -EBUSY;
> +		}
> +		fp->bufsize_order = data;
> +		up_write(&fp->this_card_priv->semaphore);
> +		break;
> +	case FEPCI_NETDEV_IOCTL_STREAM_UNITSIZE:
> +		DBG_PRINT
> +		    (" ioctl stream unitsize commanded. (unitsize:0x%x)\n",
> +		     data);
> +		down_write(&fp->this_card_priv->semaphore);
> +		if (fp->in_stream_mode) {
> +			up_write(&fp->this_card_priv->semaphore);
> +			return -EBUSY;
> +		}
> +		fp->fake_unit_sz_order = data;
> +		up_write(&fp->this_card_priv->semaphore);
> +		break;
> +	case FEPCI_NETDEV_IOCTL_STREAM_OPEN:
> +		DBG_PRINT(" ioctl stream open commanded.\n");
> +		ret = fepci_stream_open(dev);
> +		break;
> +	case FEPCI_NETDEV_IOCTL_STREAM_START:
> +		DBG_PRINT(" ioctl stream start commanded.\n");
> +		ret = fepci_stream_start(dev);
> +		break;
> +	case FEPCI_NETDEV_IOCTL_STREAM_CLOSE:
> +		DBG_PRINT(" ioctl stream close commanded.\n");
> +		ret = fepci_stream_close(dev);
> +		break;
> +	default:
> +		DBG_PRINT(" unknown ioctl command 0x%x.\n", cmd);
> +		return -ENOTTY;
> +	}
> +	return ret;
> +}
> +
> +static void fepci_remove_one(struct pci_dev *pdev)
> +{
> +	/* from first dev, same in all */
> +	struct net_device *dev = pci_get_drvdata(pdev);
> +	struct fepci_ch_private *fp = dev->priv;
> +	struct fepci_card_private *cardp = fp->this_card_priv;
> +	unsigned int i;
> +
> +	writel(0, (void *)(cardp->ioaddr + reg_custom));
> +	/* alarm manager int off */
> +
> +	for (i = 0; i < CHANNELS; i++) {
> +		dev = cardp->ch_privates[i]->this_dev;
> +		fp = dev->priv;
> +#ifdef DEBUG_PROC_FILES
> +		fepci_proc_cleanup_channel(cardp->card_number,
> +					   fp->channel_number);
> +#endif /* DEBUG_PROC_FILES */
> +		unregister_netdev(dev);
> +		fepci_stream_close(dev);
> +		free_netdev(dev);
> +	}
> +
> +	pdev = cardp->pci_dev;
> +	free_irq(pdev->irq, (void *)cardp);
> +
> +	down_write(&cardp->semaphore);
> +
> +	fepci_proc_cleanup_card(cardp->card_number);
> +
> +	pci_set_drvdata(pdev, NULL);
> +
> +	if (cardp->card_number + 1 == find_cnt)
> +		find_cnt--;
> +	cardp->pci_dev = NULL;
> +
> +	iounmap(cardp->ioaddr);
> +
> +	up_write(&cardp->semaphore);
> +
> +	pci_disable_device(pdev);
> +	pci_release_regions(pdev);
> +}
> +
> +static struct pci_driver fepci_driver = {
> +name:		DRV_NAME,
> +id_table:	fepci_pci_tbl,
> +probe:		fepci_init_one,
> +remove:		fepci_remove_one,
> +};
> +
> +static int __init fepci_init(void)
> +{
> +	unsigned card = MAX_DEVICES - 1;
> +	do
> +		init_rwsem(&card_privates[card].semaphore);
> +	while (card--);
> +	major = fepci_register_char_device();
> +	if (major < 0)
> +		return major;
> +	stream_pointers =
> +	    (unsigned long)get_zeroed_page(GFP_KERNEL | __GFP_DMA);
> +	DBG_PRINT(" %x.\n", stream_pointers);
> +	if (stream_pointers == 0) {
> +		fepci_unregister_char_device();
> +		return -ENOMEM;
> +	}
> +	DBG_PRINT("SetPageReserved %u.\n", stream_pointers);
> +	SetPageReserved(virt_to_page(stream_pointers));
> +	DBG_PRINT("fepci_proc_init_driver.\n");
> +	fepci_proc_init_driver();
> +	DBG_PRINT("pci_register_driver %p.\n", &fepci_driver);
> +	{
> +		int ret = pci_register_driver(&fepci_driver);
> +		if (ret) {
> +			fepci_unregister_char_device();
> +			ClearPageReserved(virt_to_page(stream_pointers));
> +			free_page(stream_pointers);
> +			DBG_PRINT
> +			    ("pci_register_driver %p failed with %d.\n",
> +			     &fepci_driver, ret);
> +			fepci_proc_cleanup_driver();
> +			return ret;
> +		}
> +		DBG_PRINT("fepci_init %d.\n", ret);
> +		return ret;
> +	}
> +}
> +
> +static void __exit fepci_cleanup(void)
> +{
> +	DBG_PRINT("fepci_cleanup\n");
> +	pci_unregister_driver(&fepci_driver);
> +	fepci_proc_cleanup_driver();
> +	fepci_unregister_char_device();
> +	ClearPageReserved(virt_to_page(stream_pointers));
> +	free_page(stream_pointers);
> +}
> +
> +module_init(fepci_init);
> +module_exit(fepci_cleanup);
> +
>

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
