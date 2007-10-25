From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v1.2.8] wan: new driver retina
Date: Thu, 25 Oct 2007 06:59:28 -0400
Message-ID: <47207710.7030102@garzik.org>
References: <816507.21090.qm@web52011.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, info@dcombus.com, netdev@vger.kernel.org
To: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42861 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753995AbXJYK7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 06:59:38 -0400
In-Reply-To: <816507.21090.qm@web52011.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matti Linnanvuori wrote:
> From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
> 
> Adding Retina G.703 and G.SHDSL driver.
> 
> Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

Overall comment:  very nice and clean, well done.



> diff -Napur linux-2.6.23/drivers/net/wan/Kconfig linux-2.6.24/drivers/net/wan/Kconfig
> --- linux-2.6.23/drivers/net/wan/Kconfig	2007-10-09 23:31:38.000000000 +0300
> +++ linux-2.6.24/drivers/net/wan/Kconfig	2007-10-25 09:23:19.933170522 +0300
> @@ -494,4 +494,15 @@ config SBNI_MULTILINE
>  
>  	  If unsure, say N.
>  
> +config RETINA
> +	tristate "Retina support"
> +	depends on PCI
> +	help
> +	  Driver for Retina C5400 and E2200 network PCI cards, which
> +	  support G.703, G.SHDSL with Ethernet encapsulation or
> +	  character device stream.
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
> +++ linux-2.6.24/drivers/net/wan/retina.c	2007-10-25 13:10:05.004606703 +0300
> @@ -0,0 +1,3708 @@
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
> +#define DRV_VERSION	"1.2.8"
> +
> +/* Keep this if you want to have point-to-point links.
> + * Only interfaces listed in retina_ptp_interfaces will be created in PtP mode.
> + * See retina_ptp_interfaces. */
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
> +static const char fepci_name[] = "retina";
> +static const char fepci_alarm_manager_name[] = "retina alarm manager";
> +static const char fepci_NAME[] = "RETINA";
> +static const char fepci_netdev_name[] = "dcpxx";
> +static const char fepci_proc_entry_name[] = "driver/retina";
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
> +/* Time in jiffies before concluding that the transmitter is hung */
> +#define TX_TIMEOUT  (5 * HZ)
> +
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

consider making an enum like your other constants


> +#define PCI_IOTYPE (PCI_COMMAND_MASTER | PCI_COMMAND_MEMORY)

delete, never used


> +static struct pci_device_id fepci_pci_tbl[] __devinitdata = {
> +	{0x1FC0, 0x0300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> +	{0x1FC0, 0x0301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},

some prefer

	{ PCI_VDEVICE(VENDOR_NAME, 0x0300) },
	{ PCI_VDEVICE(VENDOR_NAME, 0x0301) },
	{ }	/* terminate list */

but it's up to you.


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
> +/* debugging stuff for stream mode: */
> +	/* rx-errors in descriptors */
> +	unsigned rx_desc_fifo_err_stream;
> +	unsigned rx_desc_size_err_stream;
> +	unsigned rx_desc_octet_err_stream;
> +	unsigned rx_desc_line_err_stream;
> +	/* tx-errors in descriptors */
> +	unsigned tx_desc_fifo_err_stream;
> +	/* rx-errors in interrupts */
> +	unsigned rx_int_fifo_err_stream;
> +	unsigned rx_int_frame_dropped_err_stream;
> +	/* tx-errors in interrupts */
> +	unsigned tx_int_fifo_err_stream;
> +/* other: */
> +	/* tx interrupts since last timer interrupt */
> +	unsigned tx_interrupts_since_last_timer;

if these are purely informational statistics, recommend a separate 
structure that is in turn embedded within struct fepci_ch_private


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

I recommend making these enums more readable by tabbing the values into 
alignment:

	fifo_error		= 0x10000,
	transfer_not_done	= 0x80000000,
	etc.


> +/* global variables (common to whole driver, all the cards): */
> +static int major;			/* char device major number */
> +static struct fepci_card_private card_privates[MAX_DEVICES];
> +static unsigned long stream_pointers;
> +static struct proc_dir_entry *proc_root_entry;

generally new procfs nodes are discouraged, in favor of sysfs attributes


> +static void set_int_mask(int channel, u_char value,
> +			 struct fepci_card_private *cp)
> +{
> +	void *address;
> +	unsigned shift, oldvalue;
> +	pr_debug("set_int_mask\n");
> +	address = (cp->ioaddr) + reg_first_int_mask + (channel / 4L) * 4L;
> +	shift = 8L * (channel % 4L);
> +	oldvalue = readl((void *)address);
> +	oldvalue &= ~(0xff << shift);	/* clear bits */
> +	oldvalue |= value << shift;	/* set bits */
> +	writel(oldvalue, (void *)address);

all addresses passed to writel() and readl() should be marked with 'void 
__iomem *'

then run sparse to validate (Documentation/sparse.txt)


> +static void clear_int(unsigned channel, unsigned value, void *ioaddr)
> +{
> +	void *address;
> +	unsigned shift, longvalue;
> +	pr_debug("clear_int\n");
> +	address = ioaddr + reg_first_int_status + (channel / 4) * 4;
> +	shift = 8 * (channel % 4);
> +	longvalue = value << shift;
> +	writel(~longvalue, (void *)address);

1) delete cast

2) void __iomem *address

> +static u_char get_int_status(int channel, void *ioaddr)
> +{
> +	void *address;
> +	unsigned shift, oldvalue;
> +	pr_debug("get_int_status\n");
> +	address = ioaddr + reg_first_int_status + (channel / 4L) * 4L;
> +	shift = 8L * (channel % 4L);
> +	oldvalue = readl((void *)address);
> +	oldvalue &= (0xff << shift);	/* clear other bits */
> +	return (oldvalue >> shift);
> +}
> +
> +static void fillregisterswith_00(void *ioaddr)
> +{
> +	pr_debug("fillregisterswith_00\n");
> +	writel(0x0, (void *)(ioaddr + reg_first_rxctrl));
> +	writel(0x0, (void *)(ioaddr + reg_first_txctrl));
> +	writel(0x0, (void *)(ioaddr + reg_first_int_mask));
> +	writel(0x0, (void *)(ioaddr + reg_first_int_status));
> +	writel(0x0, (void *)(ioaddr + first_rx_desc));
> +	writel(0x0, (void *)(ioaddr + first_tx_desc));

ditto

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
> +
> +/* char device operations: */
> +
> +static ssize_t fepci_char_read(struct file *filp, char *buf, size_t count,
> +			loff_t *f_pos);
> +static int fepci_char_open(struct inode *inode, struct file *filp);
> +static int fepci_char_release(struct inode *inode, struct file *filp);
> +static int fepci_char_mmap(struct file *filp, struct vm_area_struct *vma);
> +static int fepci_char_ioctl(struct inode *inode, struct file *filp,
> +		     unsigned int cmd, unsigned long arg);
> +
> +struct file_operations fepci_char_fops = {
> +       .read	= fepci_char_read,
> +       .ioctl	= fepci_char_ioctl,
> +       .open	= fepci_char_open,
> +       .release	= fepci_char_release,
> +       .mmap	= fepci_char_mmap
> +};
> +
> +static int fepci_char_open(struct inode *inode, struct file *filp)
> +{
> +	unsigned int minor = MINOR(inode->i_rdev);
> +	pr_debug("fepci_char_open\n");
> +	if (unlikely(minor >= find_cnt || card_privates[minor].pci_dev == NULL))
> +		return -ENXIO;
> +	filp->f_op = &fepci_char_fops;
> +	if (unlikely(!try_module_get(THIS_MODULE)))
> +		return -EBUSY;
> +	return 0;
> +}
> +
> +static int fepci_char_release(struct inode *inode, struct file *filp)
> +{
> +	pr_debug("fepci_char_release\n");
> +	module_put(THIS_MODULE);
> +	return 0;
> +}
> +
> +static void fepci_vma_open(struct vm_area_struct *vma)
> +{
> +	pr_debug("fepci_vma_open\n");
> +}
> +
> +static void fepci_vma_close(struct vm_area_struct *vma)
> +{
> +	pr_debug("fepci_vma_close\n");
> +	module_put(THIS_MODULE);
> +}
> +
> +static struct vm_operations_struct fepci_vm_ops = {
> +       .open	= fepci_vma_open,
> +       .close	= fepci_vma_close
> +};
> +
> +static int fepci_char_mmap(struct file *filp, struct vm_area_struct *vma)
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
> +			pr_debug("%s: mmap: invalid address 0x%lx\n",
> +				  fepci_NAME, virtual_address);
> +			return -EINVAL;
> +		}
> +		if (unlikely(virtual_address == 0))
> +			goto INVALID;
> +	}
> +
> +	if (unlikely(!try_module_get(THIS_MODULE)))
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
> +static void fepci_copy_to_user(unsigned long to, void *from, unsigned long len,
> +			int shrink)
> +{
> +	unsigned int i;
> +	pr_debug("fepci_copy_to_user\n");
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
> +static void fepci_copy_from_user(void *to, unsigned long from,
> +				 unsigned long len, int enlarge)
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

please kindly explain this char device in detail (URL to documentation?)...

a WAN driver providing mmap(2) is quite unusual.  what is the interface 
description?  what security restrictions exist?

Stopped reviewing here.  That should give you a bit to do :)

	Jeff


