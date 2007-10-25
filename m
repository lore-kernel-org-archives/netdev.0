From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: [PATCH v1.2.8] wan: new driver retina
Date: Thu, 25 Oct 2007 03:36:39 -0700 (PDT)
Message-ID: <816507.21090.qm@web52011.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: jgarzik@pobox.com, akpm@linux-foundation.org, info@dcombus.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52011.mail.re2.yahoo.com ([206.190.48.27]:33800 "HELO
	web52011.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756768AbXJYKgo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 06:36:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

Adding Retina G.703 and G.SHDSL driver.

Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
---

=46ixing a schedule_timeout bug. Formatting a comment.

diff -Napur linux-2.6.23/drivers/net/wan/Kconfig linux-2.6.24/drivers/n=
et/wan/Kconfig
--- linux-2.6.23/drivers/net/wan/Kconfig	2007-10-09 23:31:38.000000000 =
+0300
+++ linux-2.6.24/drivers/net/wan/Kconfig	2007-10-25 09:23:19.933170522 =
+0300
@@ -494,4 +494,15 @@ config SBNI_MULTILINE
=20
 	  If unsure, say N.
=20
+config RETINA
+	tristate "Retina support"
+	depends on PCI
+	help
+	  Driver for Retina C5400 and E2200 network PCI cards, which
+	  support G.703, G.SHDSL with Ethernet encapsulation or
+	  character device stream.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called retina.
+
 endif # WAN
diff -Napur linux-2.6.23/drivers/net/wan/Makefile linux-2.6.24/drivers/=
net/wan/Makefile
--- linux-2.6.23/drivers/net/wan/Makefile	2007-10-09 23:31:38.000000000=
 +0300
+++ linux-2.6.24/drivers/net/wan/Makefile	2007-10-23 12:31:17.598640178=
 +0300
@@ -42,6 +42,7 @@ obj-$(CONFIG_C101)		+=3D c101.o
 obj-$(CONFIG_WANXL)		+=3D wanxl.o
 obj-$(CONFIG_PCI200SYN)		+=3D pci200syn.o
 obj-$(CONFIG_PC300TOO)		+=3D pc300too.o
+obj-$(CONFIG_RETINA)		+=3D retina.o
=20
 clean-files :=3D wanxlfw.inc
 $(obj)/wanxl.o:	$(obj)/wanxlfw.inc
diff -Napur linux-2.6.23/drivers/net/wan/retina.c linux-2.6.24/drivers/=
net/wan/retina.c
--- linux-2.6.23/drivers/net/wan/retina.c	1970-01-01 02:00:00.000000000=
 +0200
+++ linux-2.6.24/drivers/net/wan/retina.c	2007-10-25 13:10:05.004606703=
 +0300
@@ -0,0 +1,3708 @@
+/* retina.c: */
+
+/*
+	This driver is based on:
+
+	/drivers/net/fepci.c
+	FEPCI (Frame Engine for PCI) driver for Linux operating system
+
+	Copyright (C) 2002-2003 Jouni Kujala, Flexibilis Oy.
+
+	This program is free software; you can redistribute it and/or
+	modify it under the terms of the GNU General Public License
+	as published by the Free Software Foundation; either version 2
+	of the License, or (at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+	GNU General Public License for more details.
+
+	All the drivers derived from or based on this code fall under the
+	GPL and must retain the copyright and license notice.
+*/
+
+#define DRV_NAME	"retina"
+#define DRV_VERSION	"1.2.8"
+
+/* Keep this if you want to have point-to-point links.
+ * Only interfaces listed in retina_ptp_interfaces will be created in =
PtP mode.
+ * See retina_ptp_interfaces. */
+#define FEPCI_POINT_TO_POINT
+
+/* need to update MODULE_PARM also */
+#define MAX_DEVICES 32u
+
+#define MAX_TX_UNITS  256u
+#define MAX_RX_UNITS  256u
+
+#define MAX_UNIT_SZ_ORDER  10u
+
+#define TX_RING_SIZE	8u
+#define RX_RING_SIZE	8u
+
+/* need to update MODULE_PARM also */
+#define CHANNELS        4u
+
+#define RX_FIFO_THRESHOLD_PACKET_MODE 0x4
+#define TX_FIFO_THRESHOLD_PACKET_MODE 0x4
+#define TX_DESC_THRESHOLD_PACKET_MODE 0x4
+
+#define RX_FIFO_THRESHOLD_STREAM_MODE 0x4
+#define TX_FIFO_THRESHOLD_STREAM_MODE 0x7
+#define TX_DESC_THRESHOLD_STREAM_MODE 0x1
+
+/* need to update MODULE_PARM also */
+#define MAX_INTERFACES (CHANNELS*MAX_DEVICES)
+
+static const char fepci_name[] =3D "retina";
+static const char fepci_alarm_manager_name[] =3D "retina alarm manager=
";
+static const char fepci_NAME[] =3D "RETINA";
+static const char fepci_netdev_name[] =3D "dcpxx";
+static const char fepci_proc_entry_name[] =3D "driver/retina";
+
+static unsigned int find_cnt;
+
+#ifdef FEPCI_POINT_TO_POINT
+static char *retina_ptp_interfaces[MAX_INTERFACES];
+static int retina_noarp_with_ptp =3D 1;
+#endif /* FEPCI_POINT_TO_POINT */
+
+#define fepci_features_proc_entry_name "driver/retina/%02x:%02x.%02x/f=
eatures"
+#define fepci_settings_proc_entry_name "driver/retina/%02x:%02x.%02x/s=
ettings"
+#define fepci_status_proc_entry_name "driver/retina/%02x:%02x.%02x/sta=
tus"
+
+/* Time in jiffies before concluding that the transmitter is hung */
+#define TX_TIMEOUT  (5 * HZ)
+
+#include "retina.h"
+#include <linux/mm.h>
+#include <linux/random.h>
+#include <linux/proc_fs.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/timer.h>
+#include <linux/errno.h>
+#include <linux/ioport.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/ethtool.h>
+#include <linux/delay.h>
+#include <linux/bitops.h>
+#include <linux/version.h>
+#include <linux/pfn.h>
+#include <linux/uaccess.h>
+#include <linux/io.h>
+
+#include <asm/unaligned.h>
+#include <asm/pgtable.h>
+
+MODULE_VERSION(DRV_VERSION);
+
+/* PCI I/O space extent */
+#define FEPCI_SIZE 0x20000
+#define PCI_IOTYPE (PCI_COMMAND_MASTER | PCI_COMMAND_MEMORY)
+
+static struct pci_device_id fepci_pci_tbl[] __devinitdata =3D {
+	{0x1FC0, 0x0300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x1FC0, 0x0301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0,}
+};
+
+MODULE_DESCRIPTION("Frame Engine for PCI (FEPCI)");
+MODULE_AUTHOR("Jouni Kujala");
+MODULE_LICENSE("GPL");
+MODULE_DEVICE_TABLE(pci, fepci_pci_tbl);
+
+/* Linux appears to drop POINTOPOINT,BROADCAST and NOARP flags in SIOC=
SFLAGS
+ * This workaround allows load time per interface ptp mode configurati=
on.
+ * Runtime ptp mode changes would either require changes to Linux or
+ * use of proprietary ioctls, which ifconfig knows nothing about anywa=
y
+ */
+
+static unsigned interfaces =3D MAX_INTERFACES;
+#ifdef FEPCI_POINT_TO_POINT
+module_param_array(retina_ptp_interfaces, charp, &interfaces, S_IRUGO)=
;
+module_param(retina_noarp_with_ptp, bool, S_IRUGO);
+MODULE_PARM_DESC(retina_noarp_with_ptp,
+		 "0 to disable NOARP, "
+		 "1 to enable NOARP on pointopoint interfaces");
+#endif
+
+struct fepci_ch_private {
+	unsigned int channel_number;
+	struct net_device *this_dev;
+
+	struct fepci_card_private *this_card_priv;
+
+	unsigned int reg_rxctrl;
+	unsigned int reg_txctrl;
+
+	struct fepci_desc *rx_desc;	/* rx_ring start */
+	struct fepci_desc *tx_desc;	/* tx_ring start */
+	struct sk_buff *rx_skbuff[RX_RING_SIZE];
+	struct sk_buff *tx_skbuff[TX_RING_SIZE];
+
+	struct timer_list timer;
+	struct net_device_stats stats;
+
+	unsigned int rx_buf_sz;	/*  MTU+slack */
+	unsigned int cur_tx;	/* the next filled tx_descriptor */
+	/* in stream mode the desc which is being transmitted */
+	/* rx_descriptor where next packet transferred */
+	unsigned int cur_rx;
+	/* in stream mode the desc which is being received */
+
+/* stream mode: */
+	bool in_eth_mode;
+	bool in_stream_mode;
+	bool stream_on;
+	u32 *rx_buffer;
+	u32 *tx_buffer;
+	unsigned bufsize_order;	/* 10=3D1kB,11=3D2kB,12=3D4kB...16=3D64kB */
+	unsigned bufsize;
+	unsigned unit_sz_order;	/* 8=3D256B...14=3D16kB */
+	unsigned unit_sz;
+	unsigned units;		/* 2,4,8,16,...,256 */
+	/* fake units (and pointers) are for faking larger unit sizes to
+	 * the user than what is the maximum internal unit size in FEPCI */
+	unsigned fake_unit_sz_order;
+	unsigned fake_unit_sz;
+	unsigned fake_units;
+	u32 *tx_unit[MAX_TX_UNITS];
+	u32 *rx_unit[MAX_RX_UNITS];
+	unsigned cur_tx_unit;	/* last sent tx_unit */
+	/* rx_unit where to next packet is transferred */
+	unsigned cur_rx_unit;
+/* char device: */
+	unsigned minor;		/* currently the same as card_nuber */
+/* debugging stuff for stream mode: */
+	/* rx-errors in descriptors */
+	unsigned rx_desc_fifo_err_stream;
+	unsigned rx_desc_size_err_stream;
+	unsigned rx_desc_octet_err_stream;
+	unsigned rx_desc_line_err_stream;
+	/* tx-errors in descriptors */
+	unsigned tx_desc_fifo_err_stream;
+	/* rx-errors in interrupts */
+	unsigned rx_int_fifo_err_stream;
+	unsigned rx_int_frame_dropped_err_stream;
+	/* tx-errors in interrupts */
+	unsigned tx_int_fifo_err_stream;
+/* other: */
+	/* tx interrupts since last timer interrupt */
+	unsigned tx_interrupts_since_last_timer;
+};
+
+struct fepci_card_private {
+	unsigned int card_number;
+	u8 *ioaddr;
+	/* Process ID of the current mailbox user
+	 * (for whom it is reserved for) */
+	unsigned int ioctl_saved_pid;
+	struct pci_dev *pci_dev;
+	struct fepci_ch_private *ch_privates[CHANNELS];
+
+	wait_queue_head_t alarm_manager_wait_q;
+	struct timer_list mailbox_timer;
+
+	wait_queue_head_t stream_receive_q;
+	wait_queue_head_t stream_transmit_q;
+	wait_queue_head_t stream_both_q;
+
+	struct rw_semaphore semaphore;
+};
+
+/* Offsets to the FEPCI registers */
+enum fepci_offsets {
+	reg_custom =3D 0x40,
+
+	reg_first_int_mask =3D 0x80,
+	reg_first_int_status =3D 0xc0,
+
+	reg_first_rxctrl =3D 0x4000,
+	to_next_rxctrl =3D 0x80,
+
+	reg_first_txctrl =3D 0x6000,
+	to_next_txctrl =3D 0x80,
+
+	first_rx_desc =3D 0x10000,
+	to_next_ch_rx_desc =3D 0x200,
+
+	first_tx_desc =3D 0x18000,
+	to_next_ch_tx_desc =3D 0x200,
+};
+
+enum reg_custom_bits {
+	AM_interrupt_mask =3D 0x1,
+	AM_interrupt_status =3D 0x100,
+};
+
+enum reg_receive_control {
+	Rx_fifo_threshold =3D 0x7,
+	Receive_enable =3D 0x80000000,
+};
+
+enum reg_transmit_control {
+	Tx_fifo_threshold =3D 0x7,
+	Tx_desc_threshold =3D 0x700,
+	Transmit_enable =3D 0x80000000,
+};
+
+enum int_bits {
+	MaskFrameReceived =3D 0x01, MaskRxFifoError =3D
+	    0x02, MaskRxFrameDroppedError =3D 0x04,
+	MaskFrameTransmitted =3D 0x40, MaskTxFifoError =3D 0x80,
+	MaskAllInts =3D 0xc7,
+	IntrFrameReceived =3D 0x01, IntrRxFifoError =3D
+	    0x02, IntrRxFrameDroppedError =3D 0x04,
+	IntrFrameTransmitted =3D 0x40, IntrTxFifoError =3D 0x80,
+	IntrAllInts =3D 0xc7,
+};
+
+/* The FEPCI Rx and Tx buffer descriptors
+ * Elements are written as 32 bit for endian portability */
+
+struct fepci_desc {
+	u32 desc_a;
+	u32 desc_b;
+};
+
+enum desc_b_bits {
+	frame_length =3D 0xFFF,
+	fifo_error =3D 0x10000,
+	size_error =3D 0x20000,
+	crc_error =3D 0x40000,
+	octet_error =3D 0x80000,
+	line_error =3D 0x100000,
+	enable_transfer =3D 0x80000000,
+	transfer_not_done =3D 0x80000000,
+};
+
+/* global variables (common to whole driver, all the cards): */
+static int major;			/* char device major number */
+static struct fepci_card_private card_privates[MAX_DEVICES];
+static unsigned long stream_pointers;
+static struct proc_dir_entry *proc_root_entry;
+
+static void set_int_mask(int channel, u_char value,
+			 struct fepci_card_private *cp)
+{
+	void *address;
+	unsigned shift, oldvalue;
+	pr_debug("set_int_mask\n");
+	address =3D (cp->ioaddr) + reg_first_int_mask + (channel / 4L) * 4L;
+	shift =3D 8L * (channel % 4L);
+	oldvalue =3D readl((void *)address);
+	oldvalue &=3D ~(0xff << shift);	/* clear bits */
+	oldvalue |=3D value << shift;	/* set bits */
+	writel(oldvalue, (void *)address);
+}
+
+static void clear_int(unsigned channel, unsigned value, void *ioaddr)
+{
+	void *address;
+	unsigned shift, longvalue;
+	pr_debug("clear_int\n");
+	address =3D ioaddr + reg_first_int_status + (channel / 4) * 4;
+	shift =3D 8 * (channel % 4);
+	longvalue =3D value << shift;
+	writel(~longvalue, (void *)address);
+}
+
+static u_char get_int_status(int channel, void *ioaddr)
+{
+	void *address;
+	unsigned shift, oldvalue;
+	pr_debug("get_int_status\n");
+	address =3D ioaddr + reg_first_int_status + (channel / 4L) * 4L;
+	shift =3D 8L * (channel % 4L);
+	oldvalue =3D readl((void *)address);
+	oldvalue &=3D (0xff << shift);	/* clear other bits */
+	return (oldvalue >> shift);
+}
+
+static void fillregisterswith_00(void *ioaddr)
+{
+	pr_debug("fillregisterswith_00\n");
+	writel(0x0, (void *)(ioaddr + reg_first_rxctrl));
+	writel(0x0, (void *)(ioaddr + reg_first_txctrl));
+	writel(0x0, (void *)(ioaddr + reg_first_int_mask));
+	writel(0x0, (void *)(ioaddr + reg_first_int_status));
+	writel(0x0, (void *)(ioaddr + first_rx_desc));
+	writel(0x0, (void *)(ioaddr + first_tx_desc));
+}
+
+static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int =
cmd);
+static int fepci_open(struct net_device *dev);
+static void fepci_timer(unsigned long data);
+static void fepci_tx_timeout(struct net_device *dev);
+static void fepci_init_ring(struct net_device *dev);
+static int fepci_start_xmit(struct sk_buff *skb, struct net_device *de=
v);
+static irqreturn_t fepci_interrupt(int irq, void *dev_instance);
+static int fepci_rx(struct net_device *dev);
+static int fepci_close(struct net_device *dev);
+static struct net_device_stats *fepci_get_stats(struct net_device *dev=
);
+static void set_rx_mode(struct net_device *dev);
+static void fepci_remove_one(struct pci_dev *pdev);
+
+/* proc filesystem functions introduced: */
+
+static int fepci_proc_init_driver(void);
+static void fepci_proc_cleanup_driver(void);
+static void fepci_proc_init_card(int card_number, void *card_data);
+static void fepci_proc_cleanup_card(int card_number);
+
+/* char device operations: */
+
+static ssize_t fepci_char_read(struct file *filp, char *buf, size_t co=
unt,
+			loff_t *f_pos);
+static int fepci_char_open(struct inode *inode, struct file *filp);
+static int fepci_char_release(struct inode *inode, struct file *filp);
+static int fepci_char_mmap(struct file *filp, struct vm_area_struct *v=
ma);
+static int fepci_char_ioctl(struct inode *inode, struct file *filp,
+		     unsigned int cmd, unsigned long arg);
+
+struct file_operations fepci_char_fops =3D {
+       .read	=3D fepci_char_read,
+       .ioctl	=3D fepci_char_ioctl,
+       .open	=3D fepci_char_open,
+       .release	=3D fepci_char_release,
+       .mmap	=3D fepci_char_mmap
+};
+
+static int fepci_char_open(struct inode *inode, struct file *filp)
+{
+	unsigned int minor =3D MINOR(inode->i_rdev);
+	pr_debug("fepci_char_open\n");
+	if (unlikely(minor >=3D find_cnt || card_privates[minor].pci_dev =3D=3D=
 NULL))
+		return -ENXIO;
+	filp->f_op =3D &fepci_char_fops;
+	if (unlikely(!try_module_get(THIS_MODULE)))
+		return -EBUSY;
+	return 0;
+}
+
+static int fepci_char_release(struct inode *inode, struct file *filp)
+{
+	pr_debug("fepci_char_release\n");
+	module_put(THIS_MODULE);
+	return 0;
+}
+
+static void fepci_vma_open(struct vm_area_struct *vma)
+{
+	pr_debug("fepci_vma_open\n");
+}
+
+static void fepci_vma_close(struct vm_area_struct *vma)
+{
+	pr_debug("fepci_vma_close\n");
+	module_put(THIS_MODULE);
+}
+
+static struct vm_operations_struct fepci_vm_ops =3D {
+       .open	=3D fepci_vma_open,
+       .close	=3D fepci_vma_close
+};
+
+static int fepci_char_mmap(struct file *filp, struct vm_area_struct *v=
ma)
+{
+	unsigned long offset =3D vma->vm_pgoff << PAGE_SHIFT;
+	unsigned long size =3D vma->vm_end - vma->vm_start;
+
+	unsigned long virtual_address =3D 0;
+
+	vma->vm_flags |=3D VM_IO | VM_RESERVED;
+	vma->vm_ops =3D &fepci_vm_ops;
+	vma->vm_file =3D filp;
+
+	if (offset =3D=3D STREAM_BUFFER_POINTER_AREA) {
+		virtual_address =3D stream_pointers;
+		if (virtual_address =3D=3D 0) {
+			printk(KERN_WARNING "%s: mmap: internal error.\n",
+			       fepci_name);
+			return -ENOMEM;
+		}
+		if (size > (1 << PAGE_SHIFT)) {
+			printk(KERN_WARNING
+			       "%s: mmap: area size over range.\n", fepci_name);
+			return -EINVAL;
+		}
+	} else {
+		unsigned int page;
+
+		unsigned int card;
+		unsigned int channel;
+		unsigned int area;	/* 0=3Drx, 1=3Dtx */
+
+		card =3D (offset >> CARD_ADDRESS_SHIFT) & 0xf;
+		channel =3D (offset >> CHANNEL_ADDRESS_SHIFT) & 0xf;
+		area =3D (offset >> AREA_ADDRESS_SHIFT) & 0xf;
+		page =3D (offset & 0xffff);	/* >> PAGE_SHIFT; */
+
+		if (area =3D=3D 0) {
+			/* if there really is such card */
+			if (card < find_cnt && card_privates[card].pci_dev)
+				virtual_address =3D
+				    (unsigned long)card_privates[card].
+				    ch_privates[channel]->rx_buffer;
+			else
+				goto INVALID;
+		} else if (area =3D=3D 1) {
+			/* if there really is such card */
+			if (card < find_cnt && card_privates[card].pci_dev)
+				virtual_address =3D
+				    (unsigned long)card_privates[card].
+				    ch_privates[channel]->tx_buffer;
+			else
+				goto INVALID;
+		} else {
+INVALID:
+			pr_debug("%s: mmap: invalid address 0x%lx\n",
+				  fepci_NAME, virtual_address);
+			return -EINVAL;
+		}
+		if (unlikely(virtual_address =3D=3D 0))
+			goto INVALID;
+	}
+
+	if (unlikely(!try_module_get(THIS_MODULE)))
+		return -EBUSY;
+
+	vma->vm_page_prot =3D pgprot_noncached(vma->vm_page_prot);
+	{
+		unsigned pfn =3D PFN_DOWN(virt_to_phys((void *)virtual_address));
+		int error =3D io_remap_pfn_range(vma, vma->vm_start, pfn,
+					       size, vma->vm_page_prot);
+		if (unlikely(error))
+			return error;
+	}
+	fepci_vma_open(vma);
+	return 0;
+}
+
+/* mmap operations end */
+
+/* char operations start */
+
+static void fepci_copy_to_user(unsigned long to, void *from, unsigned =
long len,
+			int shrink)
+{
+	unsigned int i;
+	pr_debug("fepci_copy_to_user\n");
+	if (shrink) {
+		for (i =3D 0; i < len; i +=3D 2) {
+			put_user((((unsigned long *)from)[i / 2]) & 0xff,
+				 (unsigned char *)(to + i));
+			put_user((((unsigned long *)from)[i / 2]) >> 8,
+				 (unsigned char *)(to + i + 1));
+		}
+	} else {
+		for (i =3D 0; i < len; i +=3D 4)
+			put_user(((unsigned long *)from)[i / 4],
+				 (unsigned long *)(to + i));
+	}
+}
+
+static void fepci_copy_from_user(void *to, unsigned long from,
+				 unsigned long len, int enlarge)
+{
+	unsigned int i;
+	if (enlarge) {
+		for (i =3D 0; i < len; i +=3D 2) {
+			unsigned char temp1;
+			unsigned char temp2;
+			get_user(temp1, (unsigned char *)(from + i));
+			get_user(temp2, (unsigned char *)(from + i + 1));
+			*((unsigned long *)(to + i * 2)) =3D temp1 + (temp2 << 8);
+		}
+	} else {
+		for (i =3D 0; i < len; i +=3D 4)
+			get_user(((unsigned long *)to)[i / 4],
+				 (unsigned long *)(from + i));
+	}
+}
+
+static unsigned get_semafore(struct fepci_real_mailbox *mailbox)
+{
+	unsigned semafore =3D readb(&mailbox->Semafore_Mail_number);
+	pr_debug("get_semafore =3D %x\n", semafore);
+	return semafore;
+}
+
+static void set_semafore(struct fepci_real_mailbox *mailbox, unsigned =
semafore)
+{
+	unsigned number =3D readl(&mailbox->Semafore_Mail_number);
+	pr_debug("got number %u at %p.\n", number,
+		  &mailbox->Semafore_Mail_number);
+	number =3D ((number & ~0xFF) | semafore) + (1 << 8);
+	pr_debug
+	    ("increases the mail number to %u at the same time at %p.\n",
+	     number, &mailbox->Semafore_Mail_number);
+	writel(number, &mailbox->Semafore_Mail_number);
+	pr_debug("set_semafore %p, %u returns 0.\n", mailbox, semafore);
+}
+
+static void fepci_mailbox_timer(unsigned long data)
+{
+	int card_number =3D data;
+	unsigned int *saved_pid =3D &card_privates[card_number].ioctl_saved_p=
id;
+	void *ioaddr =3D card_privates[card_number].ioaddr;
+	struct fepci_real_mailbox *real_mailbox =3D
+	    (struct fepci_real_mailbox *)(ioaddr + FEPCI_MAILBOX_OFFSETT);
+
+	set_semafore(real_mailbox, 0x0);
+	*saved_pid =3D 0;
+}
+
+static int fepci_char_ioctl(struct inode *inode, struct file *filp,
+		     unsigned int cmd, unsigned long arg)
+{
+	unsigned int minor =3D MINOR(inode->i_rdev);
+	void *ioaddr;
+	struct fepci_real_mailbox *real_mailbox;
+	int retval =3D 0;
+	unsigned int *saved_pid;
+	unsigned int my_pid;
+
+	if (minor >=3D find_cnt || card_privates[minor].pci_dev =3D=3D NULL) =
{
+		printk(KERN_WARNING
+		       "%s: trying to access a card that does not exist.\n",
+		       fepci_NAME);
+		/* if trying to access a card that does not exist */
+		return -ENXIO;
+	}
+
+	pr_debug("fepci_char_ioctl minor %u.\n", minor);
+
+	if (_IOC_DIR(cmd) & _IOC_READ)
+		if (!access_ok(VERIFY_WRITE, (void *)arg, _IOC_SIZE(cmd)))
+			return -EFAULT;
+	if (_IOC_DIR(cmd) & _IOC_WRITE)
+		if (!access_ok(VERIFY_READ, (void *)arg, _IOC_SIZE(cmd)))
+			return -EFAULT;
+
+	ioaddr =3D card_privates[minor].ioaddr;
+	real_mailbox =3D
+	    (struct fepci_real_mailbox *)(ioaddr + FEPCI_MAILBOX_OFFSETT);
+	saved_pid =3D &card_privates[minor].ioctl_saved_pid;
+	my_pid =3D current->pid;
+
+	switch (cmd) {
+	case FEPCI_IOCTL_STREAM_TRANSMIT_POLL:
+		/* here: arg =3D=3D channel number */
+		if (arg < 0 || arg >=3D CHANNELS
+		    || !(card_privates[minor].ch_privates[arg]->stream_on))
+			return 0x2;
+		{
+			u32 pointer =3D *USER_TX_S_FAKE_POINTER(minor, arg,
+							      stream_pointers);
+			wait_event_interruptible((card_privates[minor].
+						  stream_transmit_q)
+						 ,
+						 (pointer !=3D
+						  *USER_TX_S_FAKE_POINTER
+						  (minor, arg,
+						   stream_pointers)));
+			return 0x1;
+		}
+		return retval;
+	case FEPCI_IOCTL_STREAM_RECEIVE_POLL:
+		/* here: arg =3D=3D channel number */
+		if (arg < 0 || arg >=3D CHANNELS
+		    || !(card_privates[minor].ch_privates[arg]->stream_on))
+			return 0x2;
+		{
+			u32 pointer =3D *USER_RX_S_FAKE_POINTER(minor, arg,
+							      stream_pointers);
+			wait_event_interruptible((card_privates[minor].
+						  stream_receive_q)
+						 ,
+						 (pointer !=3D
+						  *USER_RX_S_FAKE_POINTER
+						  (minor, arg,
+						   stream_pointers)));
+			retval =3D 0x1;
+		}
+		return retval;
+	case FEPCI_IOCTL_STREAM_BOTH_POLL:
+		/* here: arg =3D=3D channel number */
+		if (arg < 0 || arg >=3D CHANNELS
+		    || !(card_privates[minor].ch_privates[arg]->stream_on))
+			return 0x2;
+		{
+			u32 temp_tx_pointer =3D
+			    *USER_TX_S_FAKE_POINTER(minor, arg,
+						    stream_pointers);
+			u32 temp_rx_pointer =3D
+			    *USER_RX_S_FAKE_POINTER(minor, arg,
+						    stream_pointers);
+
+			wait_event_interruptible((card_privates[minor].
+						  stream_both_q)
+						 ,
+						 (temp_tx_pointer !=3D
+						  *USER_TX_S_FAKE_POINTER
+						  (minor, arg, stream_pointers))
+						 || (temp_rx_pointer !=3D
+						     *USER_RX_S_FAKE_POINTER
+						     (minor, arg,
+						      stream_pointers)));
+			retval =3D 0x1;
+		}
+		return retval;
+	case FEPCI_IOCTL_R_SHARED_MEM:
+		pr_debug(" %s: ioctl read shared mem commanded.\n",
+			  fepci_NAME);
+		fepci_copy_to_user(arg, ioaddr + FEPCI_SHARED_MEM_OFFSETT,
+				   _IOC_SIZE(cmd), 0);
+		break;
+	case FEPCI_IOCTL_W_SHARED_MEM:
+		pr_debug(" %s: ioctl write shared mem commanded.\n",
+			  fepci_NAME);
+		fepci_copy_from_user(ioaddr + FEPCI_SHARED_MEM_OFFSETT,
+				     arg, _IOC_SIZE(cmd), 0);
+		break;
+	case FEPCI_IOCTL_G_IDENTIFICATION:
+		pr_debug(" %s: IOCTL_G_IDENTIFICATION commanded.\n",
+			  fepci_NAME);
+		fepci_copy_to_user(arg,
+				   ioaddr + FEPCI_IDENTIFICATION_OFFSETT,
+				   _IOC_SIZE(cmd), 1);
+		break;
+	case FEPCI_IOCTL_G_FEATURES:
+		pr_debug(" %s: IOCTL_G_FEATURES commanded.\n", fepci_NAME);
+		fepci_copy_to_user(arg, ioaddr + FEPCI_FEATURES_OFFSETT,
+				   _IOC_SIZE(cmd), 1);
+		break;
+	case FEPCI_IOCTL_G_SETTINGS:
+		pr_debug(" %s: IOCTL_G_SETTINGS commanded.\n", fepci_NAME);
+		fepci_copy_to_user(arg, ioaddr + FEPCI_SETTINGS_OFFSETT,
+				   _IOC_SIZE(cmd), 1);
+		break;
+	case FEPCI_IOCTL_G_STATUS:
+		pr_debug(" %s: IOCTL_G_STATUS commanded.\n", fepci_NAME);
+		fepci_copy_to_user(arg, ioaddr + FEPCI_STATUS_OFFSETT,
+				   _IOC_SIZE(cmd), 1);
+		break;
+	case FEPCI_IOCTL_B_POLL:
+		pr_debug(" %s: IOCTL_B_POLL commanded.\n", fepci_NAME);
+		retval =3D get_semafore(real_mailbox);
+		if ((retval =3D=3D 0x20 || retval =3D=3D 0x21 || retval =3D=3D 0x40)
+		    && *saved_pid !=3D my_pid)
+			retval =3D 0x7;
+		del_timer_sync(&card_privates[minor].mailbox_timer);
+		card_privates[minor].mailbox_timer.expires =3D jiffies + 20 * HZ;
+		card_privates[minor].mailbox_timer.data =3D minor;
+		card_privates[minor].mailbox_timer.function =3D
+		    &fepci_mailbox_timer;
+		add_timer(&card_privates[minor].mailbox_timer);
+		break;
+	case FEPCI_IOCTL_B_GRAB:
+		pr_debug("%s: IOCTL_B_GRAB commanded.\n", fepci_NAME);
+		if ((my_pid !=3D *saved_pid) && (*saved_pid !=3D 0)) {
+			retval =3D 0x2;
+			break;
+		}
+		pr_debug("%s: IOCTL_B_GRAB getting semaphore.\n", fepci_NAME);
+		if (get_semafore(real_mailbox) =3D=3D 0x0) {
+			pr_debug("%s: IOCTL_B_GRAB setting semaphore.\n",
+				  fepci_NAME);
+			set_semafore(real_mailbox, 0x40);
+			pr_debug("%s: IOCTL_B_GRAB sleeping.\n", fepci_NAME);
+			msleep(1);	/* delay at least 1 millisecond */
+			pr_debug
+			    ("%s: IOCTL_B_GRAB getting semaphore again.\n",
+			     fepci_NAME);
+			switch (get_semafore(real_mailbox)) {
+			case 0x40:
+				retval =3D 0x0;
+				pr_debug
+				    ("%s: IOCTL_B_GRAB saving pid to %p.\n",
+				     fepci_NAME, saved_pid);
+				*saved_pid =3D my_pid;
+				pr_debug
+				    ("%s: IOCTL_B_GRAB deleting timer at %p.\n",
+				     fepci_NAME,
+				     &card_privates[minor].mailbox_timer);
+				del_timer_sync(&card_privates[minor].
+					       mailbox_timer);
+				card_privates[minor].mailbox_timer.
+				    expires =3D jiffies + 20 * HZ;
+				card_privates[minor].mailbox_timer.data =3D minor;
+				card_privates[minor].mailbox_timer.
+				    function =3D &fepci_mailbox_timer;
+				add_timer(&card_privates[minor].mailbox_timer);
+				break;
+			case 0x10:
+			case 0x11:
+			case 0x80:
+				retval =3D 0x1;
+				break;
+			default:
+				retval =3D 0xff;
+			}
+		} else {
+			switch (get_semafore(real_mailbox)) {
+			case 0x10:
+			case 0x11:
+			case 0x80:
+				retval =3D 0x1;
+				break;
+			default:
+				retval =3D 0xff;
+			}
+		}
+		break;
+	case FEPCI_IOCTL_B_RELEASE:
+		pr_debug(" %s: IOCTL_B_RELEASE commanded.\n", fepci_NAME);
+		if (my_pid !=3D *saved_pid) {
+			retval =3D 0x2;
+			break;
+		}
+		switch (get_semafore(real_mailbox)) {
+		case 0x40:
+		case 0x20:
+			retval =3D 0x0;
+			set_semafore(real_mailbox, 0x0);
+			*saved_pid =3D 0;
+			del_timer(&card_privates[minor].mailbox_timer);
+			break;
+		case 0x21:
+			retval =3D 0x04;
+			break;
+		case 0x10:
+		case 0x11:
+		case 0x80:
+			retval =3D 0x1;
+			break;
+		default:
+			retval =3D 0xff;
+		}
+		break;
+	case FEPCI_IOCTL_B_S_CMAIL:
+		pr_debug(" %s: IOCTL_B_S_CMAIL commanded.\n", fepci_NAME);
+		if (my_pid !=3D *saved_pid) {
+			retval =3D 0x2;
+			break;
+		}
+		switch (get_semafore(real_mailbox)) {
+		case 0x40:
+		case 0x20:
+		case 0x21:
+			/* copy the mailbox */
+			fepci_copy_from_user(ioaddr +
+					     FEPCI_MAILBOX_OFFSETT + 4,
+					     arg + 2, _IOC_SIZE(cmd) - 2, 1);
+			/* semafore -> 10 */
+			set_semafore(real_mailbox, 0x10);
+			retval =3D 0x0;
+
+			del_timer_sync(&card_privates[minor].mailbox_timer);
+			card_privates[minor].mailbox_timer.expires =3D
+			    jiffies + 20 * HZ;
+			card_privates[minor].mailbox_timer.data =3D minor;
+			card_privates[minor].mailbox_timer.function =3D
+			    &fepci_mailbox_timer;
+			add_timer(&card_privates[minor].mailbox_timer);
+
+			break;
+
+		case 0x10:
+		case 0x11:
+		case 0x80:
+			retval =3D 0x1;
+			break;
+		case 0x0:
+			retval =3D 0x3;
+			break;
+		default:
+			retval =3D 0xff;
+		}
+		break;
+	case FEPCI_IOCTL_B_S_QMAIL:
+		pr_debug(" %s: IOCTL_B_S_QMAIL commanded.\n", fepci_NAME);
+		if (my_pid !=3D *saved_pid) {
+			retval =3D 0x2;
+			break;
+		}
+		switch (get_semafore(real_mailbox)) {
+		case 0x40:
+		case 0x20:
+		case 0x21:
+			/* copy the mailbox; */
+			fepci_copy_from_user(ioaddr +
+					     FEPCI_MAILBOX_OFFSETT + 4,
+					     arg + 2, _IOC_SIZE(cmd) - 2, 1);
+			/* semafore -> 11 */
+			set_semafore(real_mailbox, 0x11);
+			retval =3D 0x0;
+
+			del_timer_sync(&card_privates[minor].mailbox_timer);
+			card_privates[minor].mailbox_timer.expires =3D
+			    jiffies + 20 * HZ;
+			card_privates[minor].mailbox_timer.data =3D minor;
+			card_privates[minor].mailbox_timer.function =3D
+			    &fepci_mailbox_timer;
+			add_timer(&card_privates[minor].mailbox_timer);
+
+			break;
+
+		case 0x10:
+		case 0x11:
+		case 0x80:
+			retval =3D 0x1;
+			break;
+		case 0x0:
+			retval =3D 0x3;
+			break;
+		default:
+			retval =3D 0xff;
+		}
+		break;
+	case FEPCI_IOCTL_B_G_MAIL:
+		pr_debug(" %s: IOCTL_B_G_MAIL commanded.\n", fepci_NAME);
+		if (my_pid !=3D *saved_pid) {
+			retval =3D 0x2;
+		} else {
+			switch (get_semafore(real_mailbox)) {
+			case 0x10:
+			case 0x11:
+			case 0x80:
+				retval =3D 0x1;
+				break;
+			case 0x40:
+			case 0x20:
+			case 0x21:
+				retval =3D 0x0;
+				fepci_copy_to_user(arg,
+						   ioaddr +
+						   FEPCI_MAILBOX_OFFSETT,
+						   _IOC_SIZE(cmd), 1);
+
+				del_timer_sync(&card_privates[minor].
+					       mailbox_timer);
+				card_privates[minor].mailbox_timer.
+				    expires =3D jiffies + 20 * HZ;
+				card_privates[minor].mailbox_timer.data =3D minor;
+				card_privates[minor].mailbox_timer.
+				    function =3D &fepci_mailbox_timer;
+				add_timer(&card_privates[minor].mailbox_timer);
+
+				break;
+			case 0x0:
+				retval =3D 0x3;
+				break;
+			default:
+				retval =3D 0xff;
+			}
+		}
+		if (retval !=3D 0) {
+			static unsigned char seven =3D 7;
+			/* copy four lowest bytes from the mailbox */
+			fepci_copy_to_user(arg,
+					   ioaddr + FEPCI_MAILBOX_OFFSETT,
+					   4, 1);
+			/* lowest byte =3D 0x7 */
+			__put_user(arg, &seven);
+		}
+		break;
+	case FEPCI_IOCTL_ALARM_MANAGER:
+		pr_debug(" %s: IOCTL_ALARM_MANAGER commanded.\n", fepci_NAME);
+		interruptible_sleep_on(&(card_privates[minor].
+					 alarm_manager_wait_q));
+		return retval;
+	default:
+		pr_debug(" %s: Unknown ioctl command 0x%x.\n", fepci_NAME,
+			  cmd);
+		return -ENOTTY;
+	}
+	return retval;
+}
+
+static ssize_t fepci_char_read(struct file *filp, char *buf, size_t co=
unt,
+			loff_t *f_pos)
+{
+	pr_debug("fepci_char_read\n");
+	if (count > 1)
+		count =3D 1;
+	if (unlikely(copy_to_user(buf, "\n", count)))
+		return -EFAULT;
+	return count;
+}
+
+static int fepci_register_char_device(void)
+{
+	int error =3D
+	    register_chrdev(0 /* dynamic */ , fepci_name, &fepci_char_fops);
+	if (unlikely(error < 0))
+		printk(KERN_WARNING
+		       "%s: unable to register char device.\n", fepci_NAME);
+	else
+		pr_debug("%s: registered char device, major:0x%x.\n",
+			  fepci_NAME, error);
+	return error;
+}
+
+static void fepci_unregister_char_device(void)
+{
+	unregister_chrdev(major, fepci_name);
+}
+
+/* char operations end */
+
+/* stream operations start */
+
+static irqreturn_t fepci_stream_interrupt(int irq, void *dev_instance)=
;
+static int fepci_stream_close(struct net_device *dev);
+
+static int fepci_stream_open(struct net_device *dev)
+{
+	struct fepci_ch_private *fp =3D dev->priv;
+	unsigned tx_pages, rx_pages, tx_order, rx_order;
+	unsigned page_number;
+	unsigned int i;
+
+	down_write(&fp->this_card_priv->semaphore);
+	if (fp->in_eth_mode) {
+		up_write(&fp->this_card_priv->semaphore);
+		printk(KERN_WARNING
+		       "%s: Interface is in Ethernet mode, "
+		       "cannot open stream interface.\n", fepci_NAME);
+BUSY:
+		return -EBUSY;
+	}
+	if (fp->in_stream_mode) {
+		up_write(&fp->this_card_priv->semaphore);
+		printk(KERN_WARNING
+		       "%s: Interface is already in stream mode, "
+		       "cannot open stream interface.\n", fepci_NAME);
+		goto BUSY;
+	}
+
+	if (unlikely(fp->this_card_priv->pci_dev =3D=3D NULL)) {
+		up_write(&fp->this_card_priv->semaphore);
+		return -ENXIO;
+	}
+
+	fp->bufsize =3D 1 << fp->bufsize_order;
+
+	if (fp->fake_unit_sz_order < 5) {
+		up_write(&fp->this_card_priv->semaphore);
+		printk(KERN_WARNING
+		       "%s: Unit size has to be at least 32 Bytes.\n",
+		       fepci_NAME);
+INVALID:
+		return (-EINVAL);
+	}
+
+	if (fp->fake_unit_sz_order >=3D fp->bufsize_order) {
+		up_write(&fp->this_card_priv->semaphore);
+		printk(KERN_WARNING
+		       "%s: Bufsize has to be greater than unit size.\n",
+		       fepci_NAME);
+		goto INVALID;
+	}
+
+	if (fp->fake_unit_sz_order >=3D MAX_UNIT_SZ_ORDER) {
+		fp->unit_sz_order =3D MAX_UNIT_SZ_ORDER;
+	} else {
+		fp->unit_sz_order =3D fp->fake_unit_sz_order;
+	}
+
+	fp->fake_unit_sz =3D 1 << fp->fake_unit_sz_order;
+	fp->unit_sz =3D 1 << fp->unit_sz_order;
+	fp->units =3D 1 << (fp->bufsize_order - fp->unit_sz_order);
+	fp->fake_units =3D 1 << (fp->bufsize_order - fp->fake_unit_sz_order);
+
+	/* reserve memory */
+	if (fp->bufsize_order < PAGE_SHIFT) {
+		rx_order =3D 0;
+		tx_order =3D 0;
+		rx_pages =3D 1;
+		tx_pages =3D 1;
+	} else {
+		tx_order =3D fp->bufsize_order - PAGE_SHIFT;
+		tx_pages =3D 1 << tx_order;
+		rx_order =3D tx_order + 1;
+		rx_pages =3D 1 << rx_order;
+	}
+	fp->in_stream_mode =3D 1;
+	fp->tx_buffer =3D (u32 *) __get_dma_pages(GFP_KERNEL, tx_order);
+	if (!fp->tx_buffer)
+		goto NO_MEMORY;
+	fp->rx_buffer =3D (u32 *) __get_dma_pages(GFP_KERNEL, rx_order);
+	if (!fp->rx_buffer) {
+NO_MEMORY:
+		up_write(&fp->this_card_priv->semaphore);
+		printk(KERN_WARNING
+		       "%s: unable to allocate memory for buffers.\n",
+		       fepci_NAME);
+		fepci_stream_close(dev);
+		return (-ENOMEM);
+	}
+
+	for (page_number =3D 0; page_number < rx_pages; page_number++)
+		/* make pages reserved to allow remappping pages
+		   with io_remap_pfn_range */
+		SetPageReserved(virt_to_page
+				((unsigned long)fp->rx_buffer +
+				 (page_number << PAGE_SHIFT)));
+	for (page_number =3D 0; page_number < tx_pages; page_number++)
+		/* make pages reserved to allow remappping pages
+		   with io_remap_pfn_range */
+		SetPageReserved(virt_to_page
+				((unsigned long)fp->tx_buffer +
+				 (page_number << PAGE_SHIFT)));
+
+	for (i =3D 0; i < (fp->bufsize) / 4; i++)
+		fp->tx_buffer[i] =3D 0xffffffff;
+
+	/* + fp->channel_number; */
+	*USER_RX_S_POINTER(fp->this_card_priv->card_number, fp->channel_numbe=
r,
+			   stream_pointers) =3D 0;
+	/* + fp->channel_number; */
+	*USER_TX_S_POINTER(fp->this_card_priv->card_number, fp->channel_numbe=
r,
+			   stream_pointers) =3D 0;
+	/* + fp->channel_number; */
+	*USER_RX_S_FAKE_POINTER(fp->this_card_priv->card_number,
+				fp->channel_number, stream_pointers) =3D 0;
+	/* + fp->channel_number; */
+	*USER_TX_S_FAKE_POINTER(fp->this_card_priv->card_number,
+				fp->channel_number, stream_pointers) =3D 0;
+
+	pr_debug("%s: Bufsize is 0x%x.\n", fepci_NAME, fp->bufsize);
+	pr_debug("%s: Unit_size is 0x%x.\n", fepci_NAME, fp->unit_sz);
+	pr_debug("%s: Number of units is 0x%x.\n", fepci_NAME, fp->units);
+
+	pr_debug("%s: Fake_unit_size is 0x%x.\n", fepci_NAME,
+		  fp->fake_unit_sz);
+	pr_debug("%s: Number of fake units is 0x%x.\n", fepci_NAME,
+		  fp->fake_units);
+
+	/* init ring buffers */
+	for (i =3D 0; i < MAX_RX_UNITS; i++)
+		fp->rx_unit[i] =3D
+		    (u32 *) ((u32) (fp->rx_buffer) + (fp->unit_sz * i));
+	for (i =3D 0; i < MAX_TX_UNITS; i++)
+		fp->tx_unit[i] =3D
+		    (u32 *) ((u32) (fp->tx_buffer) + (fp->unit_sz * i));
+
+	for (i =3D 0; i < RX_RING_SIZE; i++) {
+		writel(0, &fp->rx_desc[i].desc_a);
+		writel(0, &fp->rx_desc[i].desc_b);
+	}
+	for (i =3D 0; i < TX_RING_SIZE; i++) {
+		writel(0, &fp->tx_desc[i].desc_a);
+		writel(0, &fp->tx_desc[i].desc_b);
+	}
+
+	up_write(&fp->this_card_priv->semaphore);
+	return 0;
+}
+
+static int fepci_stream_start(struct net_device *dev)
+{
+	struct fepci_ch_private *fp =3D dev->priv;
+	unsigned i;
+	down_write(&fp->this_card_priv->semaphore);
+
+	if (fp->in_stream_mode =3D=3D 0) {
+		up_write(&fp->this_card_priv->semaphore);
+		printk(KERN_WARNING
+		       "%s: Interface is not in stream mode, "
+		       "streaming cannot be started.\n", fepci_NAME);
+		return (-EBUSY);
+	}
+	if (fp->stream_on) {
+		up_write(&fp->this_card_priv->semaphore);
+		printk(KERN_WARNING
+		       "%s: Streaming is already on, "
+		       "streaming cannot be started.\n", fepci_NAME);
+		return (-EBUSY);
+	}
+
+	{
+		/* reserve irq */
+		int error =3D request_irq(dev->irq, &fepci_stream_interrupt,
+					IRQF_SHARED, dev->name, dev);
+		if (error) {
+			up_write(&fp->this_card_priv->semaphore);
+			printk(KERN_WARNING
+			       "%s: unable to allocate IRQ %d, error 0x%x\n",
+			       fepci_NAME, dev->irq, error);
+			return -ENOMEM;
+		}
+	}
+
+	fp->stream_on =3D 1;
+
+	/* sending &receiving on, start from the beginning of the buffer */
+	fp->cur_tx_unit =3D 0;
+	fp->cur_rx_unit =3D 0;
+	fp->cur_tx =3D 0;
+	fp->cur_rx =3D 0;
+
+	/* all the descriptors ready to go: */
+	for (i =3D 0; i < min(RX_RING_SIZE, TX_RING_SIZE); i++) {
+		dma_addr_t address =3D pci_map_single(fp->this_card_priv->pci_dev,
+						    fp->
+						    rx_unit[(fp->cur_rx_unit +
+							     i) % fp->units],
+						    fp->unit_sz,
+						    PCI_DMA_FROMDEVICE);
+		if (unlikely(pci_dma_mapping_error(address)))
+			printk(KERN_WARNING
+			       "%s: failed to map DMA buffer.\n", fepci_NAME);
+		else {
+			writel(address,
+			       &fp->rx_desc[(fp->cur_rx + i) &
+					    (RX_RING_SIZE - 1)].desc_a);
+			if (!
+			    (readl
+			     (&fp->
+			      rx_desc[(fp->cur_rx + i) & (RX_RING_SIZE -
+							  1)].
+			      desc_b) & enable_transfer))
+				writel(enable_transfer,
+				       &fp->rx_desc[(fp->cur_rx + i) %
+						    RX_RING_SIZE].desc_b);
+		}
+		address =3D
+		    pci_map_single(fp->this_card_priv->pci_dev,
+				   fp->tx_unit[(fp->cur_tx_unit + i) %
+					       fp->units], fp->unit_sz,
+				   PCI_DMA_TODEVICE);
+		writel(address,
+		       &fp->
+		       tx_desc[(fp->cur_tx + i) & (TX_RING_SIZE - 1)].desc_a);
+		if (unlikely(pci_dma_mapping_error(address)))
+			printk(KERN_WARNING
+			       "%s: failed to map DMA buffer.\n", fepci_NAME);
+		else {
+			if (!
+			    (readl
+			     (&fp->
+			      tx_desc[(fp->cur_tx + i) & (TX_RING_SIZE -
+							  1)].
+			      desc_b) & enable_transfer))
+				writel(enable_transfer |
+				       (fp->unit_sz & frame_length),
+				       &fp->
+				       tx_desc[(fp->cur_tx +
+						i) & (TX_RING_SIZE -
+						      1)].desc_b);
+		}
+	}
+
+	/* irq on */
+	set_int_mask(fp->channel_number,
+		     MaskFrameReceived | MaskFrameTransmitted |
+		     MaskRxFifoError | MaskRxFrameDroppedError |
+		     MaskTxFifoError, fp->this_card_priv);
+	{
+		void *ioaddr =3D (void *)dev->base_addr;
+		/* Start Rx and Tx channels */
+		writel(Receive_enable |
+		       (Rx_fifo_threshold & RX_FIFO_THRESHOLD_STREAM_MODE),
+		       (void *)(ioaddr + fp->reg_rxctrl));
+		writel((Transmit_enable |
+			(Tx_desc_threshold &
+			 (TX_DESC_THRESHOLD_STREAM_MODE << 8)) |
+			(Tx_fifo_threshold & TX_FIFO_THRESHOLD_STREAM_MODE)),
+		       (void *)(ioaddr + fp->reg_txctrl));
+	}
+	up_write(&fp->this_card_priv->semaphore);
+
+	return 0;
+}
+
+static int fepci_stream_stop(struct net_device *dev)
+{
+	struct fepci_ch_private *fp =3D dev->priv;
+	void *ioaddr =3D (void *)dev->base_addr;
+	down_write(&fp->this_card_priv->semaphore);
+	if (fp->in_stream_mode =3D=3D 0) {
+		up_write(&fp->this_card_priv->semaphore);
+		return (1);
+	}
+	fp->stream_on =3D 0;
+	/* Stop Rx and Tx channels. */
+	writel(0x0, (void *)(ioaddr + fp->reg_rxctrl));
+	writel(0x0, (void *)(ioaddr + fp->reg_txctrl));
+
+	/* Disable interrupts by clearing the interrupt mask. */
+	set_int_mask(fp->channel_number, 0x0, fp->this_card_priv);
+
+	/* unregister irq */
+	free_irq(dev->irq, dev);
+
+	{
+		unsigned i =3D min(RX_RING_SIZE, TX_RING_SIZE) - 1;
+		do {
+			dma_addr_t bus_address =3D readl(&fp->rx_desc[i].desc_a);
+			if (likely(!pci_dma_mapping_error(bus_address)))
+				pci_unmap_single(fp->this_card_priv->
+						 pci_dev, bus_address,
+						 fp->unit_sz,
+						 PCI_DMA_FROMDEVICE);
+			bus_address =3D readl(&fp->tx_desc[i].desc_a);
+			if (likely(!pci_dma_mapping_error(bus_address)))
+				pci_unmap_single(fp->this_card_priv->
+						 pci_dev, bus_address,
+						 fp->unit_sz, PCI_DMA_TODEVICE);
+		}
+		while (i--);
+	}
+
+	up_write(&fp->this_card_priv->semaphore);
+	return 0;
+}
+
+static int fepci_stream_close(struct net_device *dev)
+{
+	struct fepci_ch_private *fp =3D dev->priv;
+	unsigned rx_pages, tx_pages, rx_order, tx_order;
+
+	if (fepci_stream_stop(dev))
+		return -ENODEV;
+	down_write(&fp->this_card_priv->semaphore);
+	if (!(fp->in_stream_mode)) {
+		up_write(&fp->this_card_priv->semaphore);
+		return -ENODEV;
+	}
+	/* release memory */
+	if (fp->bufsize_order < PAGE_SHIFT) {
+		rx_order =3D 0;
+		tx_order =3D 0;
+		rx_pages =3D 1;
+		tx_pages =3D 1;
+	} else {
+		rx_order =3D (int)((fp->bufsize_order) - PAGE_SHIFT + 1);
+		rx_pages =3D 1 << rx_order;
+		tx_order =3D (int)((fp->bufsize_order) - PAGE_SHIFT);
+		tx_pages =3D 1 << tx_order;
+	}
+	if (fp->rx_buffer) {
+		unsigned page_number;
+		for (page_number =3D 0; page_number < rx_pages; page_number++)
+			/* turn pages back to non-reserved */
+			ClearPageReserved(virt_to_page
+					  ((unsigned long)fp->rx_buffer +
+					   (page_number << PAGE_SHIFT)));
+		free_pages((unsigned long)fp->rx_buffer, rx_order);
+		fp->rx_buffer =3D NULL;
+	}
+	if (fp->tx_buffer) {
+		unsigned page_number;
+		for (page_number =3D 0; page_number < tx_pages; page_number++)
+			/* turn pages back to non-reserved */
+			ClearPageReserved(virt_to_page
+					  ((unsigned long)fp->tx_buffer +
+					   (page_number << PAGE_SHIFT)));
+		free_pages((unsigned long)fp->tx_buffer, tx_order);
+		fp->tx_buffer =3D NULL;
+	}
+
+	fp->in_stream_mode =3D 0;
+	up_write(&fp->this_card_priv->semaphore);
+	return 0;
+}
+
+static irqreturn_t fepci_stream_interrupt(int irq, void *dev_instance)
+{
+	struct net_device *dev =3D dev_instance;
+	struct fepci_ch_private *fp =3D dev->priv;
+	void *ioaddr =3D (void *)dev->base_addr;
+	unsigned intr_status =3D get_int_status(fp->channel_number, ioaddr);
+	unsigned fifo, dropped;
+	unsigned int temp_rx;
+	unsigned int temp_rx_unit;
+	unsigned int temp_tx;
+	unsigned int temp_tx_unit;
+
+	if (unlikely(!intr_status))
+		return IRQ_NONE;
+	clear_int(fp->channel_number, intr_status, ioaddr);
+
+	/* debugging */
+	fifo =3D intr_status & IntrRxFifoError;
+	if (fifo)
+		fp->rx_int_fifo_err_stream++;
+	dropped =3D intr_status & IntrRxFrameDroppedError;
+	if (dropped)
+		fp->rx_int_frame_dropped_err_stream++;
+	if (intr_status & IntrTxFifoError)
+		fp->tx_int_fifo_err_stream++;
+	/* first update cur_rx, and do stuff if it has moved
+	   (+ packets have been received) */
+	{
+		temp_rx =3D fp->cur_rx;
+		/* has been received */
+		while ((readl(&fp->rx_desc[fp->cur_rx].desc_b) &
+			transfer_not_done) =3D=3D 0
+		       /* stop if made one round */
+		       && temp_rx !=3D ((fp->cur_rx + 1) & (RX_RING_SIZE - 1))) {
+			dma_addr_t bus_address =3D readl(&fp->rx_desc[fp->cur_rx].
+						       desc_a);
+			if (likely(!pci_dma_mapping_error(bus_address)))
+				pci_unmap_single(fp->this_card_priv->
+						 pci_dev, bus_address,
+						 fp->unit_sz,
+						 PCI_DMA_FROMDEVICE);
+			fp->cur_rx =3D (fp->cur_rx + 1) & (RX_RING_SIZE - 1);
+			fp->cur_rx_unit =3D (fp->cur_rx_unit + 1);
+			fp->cur_rx_unit *=3D fp->cur_rx_unit < fp->units;
+
+			*USER_RX_S_POINTER(fp->this_card_priv->
+					   card_number,
+					   fp->channel_number,
+					   stream_pointers) =3D fp->cur_rx_unit;
+			*USER_RX_S_FAKE_POINTER(fp->this_card_priv->
+						card_number,
+						fp->channel_number,
+						stream_pointers) =3D
+			    fp->cur_rx_unit * fp->unit_sz / fp->fake_unit_sz;
+			wake_up_interruptible(&(fp->this_card_priv->
+						stream_receive_q));
+			wake_up_interruptible(&(fp->this_card_priv->
+						stream_both_q));
+		}
+	}
+	/* from the first uninitialized descriptor to cur_rx */
+	temp_rx =3D (fp->cur_rx + 1) & (RX_RING_SIZE - 1);
+	temp_rx_unit =3D (fp->cur_rx_unit + 1);
+	temp_rx_unit *=3D temp_rx_unit < fp->units;
+
+	while (temp_rx !=3D fp->cur_rx) {
+		unsigned desc_b =3D readl(&fp->rx_desc[temp_rx].desc_b);
+		if ((desc_b & transfer_not_done) =3D=3D 0) {
+			bool fifo =3D (desc_b & fifo_error) !=3D 0;
+			bool size =3D (desc_b & size_error) !=3D 0;
+			bool octet =3D (desc_b & octet_error) !=3D 0;
+			bool line =3D (desc_b & line_error) !=3D 0;
+			dma_addr_t bus_address;
+			/* update debug counters */
+			if (fifo)
+				fp->rx_desc_fifo_err_stream++;
+			else if (size)
+				fp->rx_desc_size_err_stream++;
+			else if (octet)
+				fp->rx_desc_octet_err_stream++;
+			else if (line)
+				fp->rx_desc_line_err_stream++;
+			/* initialize the descriptor for transfer */
+			bus_address =3D
+			    pci_map_single(fp->this_card_priv->pci_dev,
+					   fp->rx_unit[temp_rx_unit],
+					   fp->unit_sz, PCI_DMA_FROMDEVICE);
+			if (likely(!pci_dma_mapping_error(bus_address))) {
+				writel(bus_address,
+				       &fp->rx_desc[temp_rx].desc_a);
+				writel(enable_transfer,
+				       &fp->rx_desc[temp_rx].desc_b);
+			} else
+				printk(KERN_WARNING
+				       "%s: failed to map DMA for reception.\n",
+				       fepci_NAME);
+		}
+		temp_rx =3D (temp_rx + 1) & (RX_RING_SIZE - 1);
+		temp_rx_unit =3D (temp_rx_unit + 1);
+		temp_rx_unit *=3D temp_rx_unit < fp->units;
+	}
+
+	/* first update cur_tx, and do stuff if it has moved
+	   (+ packets have been transmitted) */
+	temp_tx =3D fp->cur_tx;
+	/* has been transmitted? */
+	while ((readl(&fp->tx_desc[fp->cur_tx].desc_b) &
+		transfer_not_done) =3D=3D 0
+	       /* stop if made one round */
+	       && temp_tx !=3D ((fp->cur_tx + 1) & (TX_RING_SIZE - 1))) {
+		dma_addr_t bus_address =3D readl(&fp->tx_desc[fp->cur_tx].
+					       desc_a);
+		if (likely(!pci_dma_mapping_error(bus_address)))
+			pci_unmap_single(fp->this_card_priv->
+					 pci_dev, bus_address,
+					 fp->unit_sz, PCI_DMA_TODEVICE);
+		fp->cur_tx =3D (fp->cur_tx + 1) & (TX_RING_SIZE - 1);
+		fp->cur_tx_unit =3D (fp->cur_tx_unit + 1);
+		fp->cur_tx_unit *=3D fp->cur_tx_unit < fp->units;
+			*USER_TX_S_POINTER(fp->this_card_priv->
+				   card_number,
+				   fp->channel_number,
+				   stream_pointers) =3D fp->cur_tx_unit;
+		*USER_TX_S_FAKE_POINTER(fp->this_card_priv->
+					card_number,
+					fp->channel_number,
+					stream_pointers) =3D
+		    fp->cur_tx_unit * fp->unit_sz / fp->fake_unit_sz;
+		wake_up_interruptible(&(fp->this_card_priv->
+					stream_transmit_q));
+		wake_up_interruptible(&(fp->this_card_priv->
+					stream_both_q));
+	}
+
+	/* from the first uninitialized descriptor to cur_tx */
+	temp_tx =3D (fp->cur_tx + 1) & (TX_RING_SIZE - 1);
+	temp_tx_unit =3D (fp->cur_tx_unit + 1);
+	temp_tx_unit *=3D temp_tx_unit < fp->units;
+
+	while (temp_tx !=3D fp->cur_tx) {
+		unsigned desc_b =3D readl(&fp->tx_desc[temp_tx].desc_b);
+		if ((desc_b & transfer_not_done) =3D=3D 0) {
+			dma_addr_t bus_address;
+			/* update debug counters */
+			if (desc_b & fifo_error)
+				fp->tx_desc_fifo_err_stream++;
+			/* initialize the desctiptor for transfer */
+			bus_address =3D
+			    pci_map_single(fp->this_card_priv->pci_dev,
+					   fp->tx_unit[temp_tx_unit],
+					   fp->unit_sz, PCI_DMA_TODEVICE);
+			writel(bus_address, &fp->tx_desc[temp_tx].desc_a);
+			if (likely(!pci_dma_mapping_error(bus_address)))
+				writel(enable_transfer |
+				       (fp->unit_sz & frame_length),
+				       &fp->tx_desc[temp_tx].desc_b);
+			else
+				printk(KERN_WARNING
+				       "%s: failed to map tranmission DMA.\n",
+				       fepci_NAME);
+		}
+		temp_tx =3D (temp_tx + 1) & (TX_RING_SIZE - 1);
+		temp_tx_unit =3D (temp_tx_unit + 1);
+		temp_tx_unit *=3D temp_tx_unit < fp->units;
+	}
+
+	return IRQ_HANDLED;
+}
+
+/* stream operations end */
+
+static int fepci_rebuild_header(struct sk_buff *skb)
+{
+	pr_debug("fepci_rebuild_header\n");
+	return 0;
+}
+
+static inline u16 get_common_reg_word(void *ioaddr, unsigned long offs=
ett)
+{
+	u16 word;
+	pr_debug("get_common_reg_word ioaddr %p, offsett %lu\n", ioaddr,
+		  offsett);
+	__clear_bit(0, &offsett);
+	pr_debug("get_common_reg_word %p\n",
+		  ioaddr + FEPCI_IDENTIFICATION_OFFSETT + (offsett << 1));
+	word =3D le16_to_cpu(readw
+			   (ioaddr + FEPCI_IDENTIFICATION_OFFSETT +
+			    (offsett << 1)));
+	pr_debug("get_common_reg_word %p: %hu\n",
+		  ioaddr + FEPCI_IDENTIFICATION_OFFSETT + (offsett << 1), word);
+	return word;
+}
+
+static irqreturn_t alarm_manager_interrupt(int irq, void *pointer)
+{
+	struct fepci_card_private *card_private =3D pointer;
+	void *ioaddr =3D card_private->ioaddr;
+	/* check int status */
+	if (readl((void *)(ioaddr + reg_custom)) & AM_interrupt_status) {
+		/* clear int (zero everything, but the mask bit) */
+		writel(readl((void *)(ioaddr + reg_custom)) &
+		       AM_interrupt_mask, (void *)(ioaddr + reg_custom));
+		/* wake queue */
+		wake_up(&(card_private->alarm_manager_wait_q));
+	}
+
+	return IRQ_HANDLED;
+}
+
+#ifdef FEPCI_POINT_TO_POINT
+static int is_ptp_interface(struct net_device *dev)
+{
+	char **p_ptp_if_name =3D retina_ptp_interfaces;
+	unsigned int i =3D interfaces;
+	while (i > 0 && *p_ptp_if_name !=3D NULL) {
+		if (!strncmp(dev->name, *p_ptp_if_name, sizeof(dev->name)))
+			return 1;
+		p_ptp_if_name++;
+		i--;
+	}
+	return 0;
+}
+#endif /* FEPCI_POINT_TO_POINT */
+
+static int __devinit fepci_init_one(struct pci_dev *pdev,
+				    const struct pci_device_id *ent)
+{
+	struct net_device *dev =3D NULL;
+	struct fepci_ch_private *fp =3D NULL;
+	int i;
+	unsigned j;
+	resource_size_t real_ioaddr;
+	void *ioaddr;
+	unsigned position;
+
+	i =3D pci_enable_device(pdev);
+	if (i) {
+		printk(KERN_WARNING "%s: pci_enable_device returned %x.\n",
+		       fepci_NAME, i);
+		return i;
+	}
+
+	pci_set_master(pdev);
+
+	i =3D pci_request_regions(pdev, (char *)fepci_name);
+	if (i) {
+		printk(KERN_WARNING
+		       "%s: pci_request_regions returned %x.\n", fepci_NAME, i);
+		pci_disable_device(pdev);
+		return i;
+	}
+
+	/* make sure above region is MMIO */
+	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
+		printk(KERN_WARNING "%s: region not MMIO region\n", fepci_NAME);
+		goto ERR_1;
+	}
+
+	j =3D pci_resource_len(pdev, 0);
+	if (j < FEPCI_SIZE) {
+		printk(KERN_WARNING
+		       "%s: resource length %u less than required %u.\n",
+		       fepci_NAME, j, FEPCI_SIZE);
+		goto ERR_1;
+	}
+
+	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+		printk(KERN_WARNING "%s: no suitable DMA available.\n",
+		       fepci_NAME);
+		goto ERR_1;
+	}
+
+	real_ioaddr =3D pci_resource_start(pdev, 0);
+	ioaddr =3D ioremap_nocache(real_ioaddr, FEPCI_SIZE);
+	pr_debug("ioremap_nocache =3D %p.\n", ioaddr);
+	if (!ioaddr) {
+		printk(KERN_WARNING "%s: remapping failed.\n", fepci_NAME);
+		goto ERR_1_5;
+	}
+	position =3D 0;
+	for (; position < MAX_DEVICES; position++) {
+		down_write(&card_privates[position].semaphore);
+		if (card_privates[position].pci_dev =3D=3D NULL) {
+			card_privates[position].pci_dev =3D pdev;
+			if (position =3D=3D find_cnt)
+				find_cnt++;
+			goto FOUND;
+		}
+		up_write(&card_privates[position].semaphore);
+	}
+	printk(KERN_WARNING
+	       "%s: no space to inialize device #%u.\n",
+	       fepci_NAME, MAX_DEVICES + 1);
+	goto ERR_2;
+FOUND:
+	card_privates[position].card_number =3D position;
+	card_privates[position].ioaddr =3D ioaddr;
+	card_privates[position].pci_dev =3D pdev;
+	pr_debug("fillregisterswith_00 %p.\n", ioaddr);
+	fillregisterswith_00(ioaddr);
+
+	fepci_proc_init_card(position, (void *)&(card_privates[position]));
+
+	init_waitqueue_head(&(card_privates[position].alarm_manager_wait_q));
+	init_waitqueue_head(&(card_privates[position].stream_transmit_q));
+	init_waitqueue_head(&(card_privates[position].stream_receive_q));
+	init_waitqueue_head(&(card_privates[position].stream_both_q));
+
+	init_timer(&card_privates[position].mailbox_timer);
+
+	pr_debug("request_irq %d, %s.\n", pdev->irq, fepci_alarm_manager_name=
);
+	i =3D request_irq(pdev->irq, &alarm_manager_interrupt,
+			IRQF_SHARED,
+			fepci_alarm_manager_name, &card_privates[position]);
+	if (i) {
+		up_write(&card_privates[position].semaphore);
+		printk(KERN_WARNING
+		       "%s: unable to allocate IRQ %d alarm manager: 0x%x\n",
+		       fepci_NAME, pdev->irq, i);
+		goto ERR_2;
+	}
+	pr_debug("alarm manager int on %p.\n", (void *)(ioaddr + reg_custom))=
;
+	writel(AM_interrupt_mask, (void *)(ioaddr + reg_custom));
+	/* alarm manager int on */
+
+	for (j =3D 0; j < CHANNELS; j++) {
+		pr_debug("alloc_etherdev %u.\n", j);
+		dev =3D alloc_etherdev(sizeof(struct fepci_ch_private));
+		if (!dev) {
+			printk(KERN_WARNING
+			       "%s: cannot allocate ethernet device\n",
+			       fepci_NAME);
+			continue;
+		}
+
+		fp =3D dev->priv;
+		fp->minor =3D position;	/* * CHANNELS + j; */
+		/* name :=3D xxx01..xxxnn */
+		memcpy(dev->name, fepci_netdev_name, 6);
+		/* dev->name[3]=3D j+'0';    channel number -> ascii */
+		/* minor number -> ascii */
+		dev->name[4] =3D ((fp->minor * CHANNELS + j) % 10) + '0';
+		/* minor number -> ascii */
+		dev->name[3] =3D ((fp->minor * CHANNELS + j) / 10) + '0';
+
+		SET_MODULE_OWNER(dev);
+		dev_dbg(&dev->dev, "clear_int %u, %x, %p.\n", j,
+			IntrAllInts, ioaddr);
+		clear_int(j, IntrAllInts, ioaddr);
+		dev_dbg(&dev->dev, "ether_setup.\n");
+		ether_setup(dev);
+
+		random_ether_addr(dev->dev_addr);
+		/* HW_ADDR is got using the mailbox: */
+		{
+			struct fepci_real_mailbox *real_mailbox =3D
+			    (struct fepci_real_mailbox *)
+			    (ioaddr + FEPCI_MAILBOX_OFFSETT);
+			unsigned long waituntil;
+
+			set_semafore(real_mailbox, 0x40);
+			writel(0x1 /*size */  +
+			       (0x8 << 8) /* get mac command */ ,
+			       &real_mailbox->Size_Command);
+			set_semafore(real_mailbox, 0x11);
+
+			waituntil =3D jiffies + HZ;
+			while (time_before(jiffies, waituntil) &&
+			       get_semafore(real_mailbox) !=3D 0x20) {
+				dev_dbg(&dev->dev,
+					"jiffies %lu < waituntil %lu.\n",
+					jiffies, waituntil);
+				schedule_timeout_uninterruptible(0);
+			}
+
+			/* 14.5.2004 JT: Made this safer. */
+			if (get_semafore(real_mailbox) =3D=3D 0x20) {
+				dev->dev_addr[5] =3D
+				    readb(&real_mailbox->Data[0 + 3 * j]);
+				dev->dev_addr[4] =3D
+				    readb(((u8 *) & real_mailbox->
+					   Data[0 + 3 * j]) + 1);
+				dev->dev_addr[3] =3D
+				    readb(&real_mailbox->Data[1 + 3 * j]);
+				dev->dev_addr[2] =3D
+				    readb(((u8 *) & real_mailbox->
+					   Data[1 + 3 * j]) + 1);
+				dev->dev_addr[1] =3D
+				    readb(&real_mailbox->Data[2 + 3 * j]);
+				dev->dev_addr[0] =3D
+				    readb(((u8 *) & real_mailbox->
+					   Data[2 + 3 * j]) + 1);
+			}
+
+			set_semafore(real_mailbox, 0x0);
+		}
+		dev->addr_len =3D 6;
+
+		dev->base_addr =3D (unsigned long)ioaddr;
+		dev->irq =3D pdev->irq;
+		dev_dbg(&dev->dev, "alarm pci_set_drvdata %p.\n", pdev);
+		if (j =3D=3D 0)
+			pci_set_drvdata(pdev, dev);
+
+		fp->rx_desc =3D
+		    (struct fepci_desc *)(dev->base_addr + first_rx_desc +
+					  j * to_next_ch_rx_desc);
+		fp->tx_desc =3D
+		    (struct fepci_desc *)(dev->base_addr + first_tx_desc +
+					  j * to_next_ch_tx_desc);
+
+		fp->channel_number =3D j;	/*channel in this device */
+		fp->this_dev =3D dev;
+
+		fp->this_card_priv =3D &card_privates[position];
+		fp->this_card_priv->ch_privates[j] =3D fp;
+
+		fp->cur_tx =3D 0;
+
+		fp->in_stream_mode =3D 0;
+		fp->in_eth_mode =3D 0;
+
+		fp->reg_rxctrl =3D reg_first_rxctrl + j * to_next_rxctrl;
+		fp->reg_txctrl =3D reg_first_txctrl + j * to_next_txctrl;
+
+		/* The FEPCI specific entries in the device structure */
+		dev->open =3D &fepci_open;
+		dev->hard_start_xmit =3D &fepci_start_xmit;
+		dev->stop =3D &fepci_close;
+		dev->get_stats =3D &fepci_get_stats;
+		dev->set_multicast_list =3D &set_rx_mode;
+		dev->do_ioctl =3D &netdev_ioctl;
+		dev->tx_timeout =3D fepci_tx_timeout;
+		dev->watchdog_timeo =3D TX_TIMEOUT;
+
+#ifdef FEPCI_POINT_TO_POINT
+		if (is_ptp_interface(dev)) {
+			dev->flags |=3D (IFF_POINTOPOINT);
+			dev->flags &=3D ~(IFF_BROADCAST | IFF_MULTICAST);
+			if (retina_noarp_with_ptp) {
+				dev->rebuild_header =3D fepci_rebuild_header;
+				dev->flags |=3D (IFF_NOARP);
+			}
+		}
+#endif
+		dev_dbg(&dev->dev, "register_netdev.\n");
+		i =3D register_netdev(dev);
+		if (i) {
+			printk(KERN_WARNING
+			       "%s: register_netdev failed 0x%x.\n",
+			       fepci_NAME, i);
+			continue;
+		}
+
+		for (i =3D 0; i < 5; i++)
+			dev_dbg(&dev->dev, "%2.2x:", dev->dev_addr[i]);
+		dev_dbg(&dev->dev, "%2.2x, IRQ %d.\n", dev->dev_addr[i],
+			pdev->irq);
+	}
+	up_write(&card_privates[position].semaphore);
+	pr_debug("fepci_init_one %u.\n", position);
+	return 0;
+
+ERR_2:
+	iounmap(ioaddr);
+ERR_1_5:
+	pci_set_drvdata(pdev, NULL);
+ERR_1:
+	pci_disable_device(pdev);
+	pci_release_regions(pdev);
+	return -ENODEV;
+}
+
+static int fepci_open(struct net_device *dev)
+{
+	struct fepci_ch_private *fp =3D dev->priv;
+
+	down_write(&fp->this_card_priv->semaphore);
+
+	if (fp->this_card_priv->pci_dev =3D=3D NULL) {
+		up_write(&fp->this_card_priv->semaphore);
+		fepci_close(dev);
+		return -ENXIO;
+	}
+
+	while (fp->in_stream_mode) {
+		up_write(&fp->this_card_priv->semaphore);
+		fepci_stream_close(dev);
+		down_write(&fp->this_card_priv->semaphore);
+	}
+
+	{
+		int i =3D request_irq(dev->irq, &fepci_interrupt,
+				    IRQF_SHARED, dev->name, dev);
+		if (i) {
+			up_write(&fp->this_card_priv->semaphore);
+			printk(KERN_WARNING
+			       "%s: unable to allocate IRQ %d, error 0x%x",
+			       fepci_NAME, dev->irq, i);
+			return i;
+		}
+	}
+
+	fp->in_eth_mode =3D 1;
+
+	fepci_init_ring(dev);
+	set_rx_mode(dev);
+
+	fp->cur_rx =3D 0;
+	fp->cur_tx =3D 0;
+
+	netif_carrier_off(dev);
+
+	/* Enable interrupts by setting the interrupt mask. */
+
+	set_int_mask(fp->channel_number,
+		     MaskFrameReceived | MaskFrameTransmitted |
+		     MaskRxFifoError | MaskRxFrameDroppedError |
+		     MaskTxFifoError, fp->this_card_priv);
+
+	{
+		void *ioaddr =3D (void *)dev->base_addr;
+
+		/* Start Rx and Tx channels. */
+		writel(Receive_enable |
+		       (Rx_fifo_threshold & RX_FIFO_THRESHOLD_PACKET_MODE),
+		       (void *)(ioaddr + fp->reg_rxctrl));
+
+		writel((Transmit_enable |
+			(Tx_desc_threshold &
+			 (TX_DESC_THRESHOLD_PACKET_MODE << 8)) |
+			(Tx_fifo_threshold & TX_FIFO_THRESHOLD_PACKET_MODE)),
+		       (void *)(ioaddr + fp->reg_txctrl));
+	}
+
+	netif_start_queue(dev);
+
+	/* Set timer */
+	init_timer(&fp->timer);
+	fp->timer.expires =3D jiffies + HZ;
+	fp->timer.data =3D (unsigned long)dev;
+	fp->timer.function =3D &fepci_timer;	/* timer handler */
+	add_timer(&fp->timer);
+
+	up_write(&fp->this_card_priv->semaphore);
+
+	return 0;
+}
+
+static void fepci_timer(unsigned long data)
+{
+	struct net_device *dev =3D (struct net_device *)data;
+	struct fepci_ch_private *fp =3D dev->priv;
+
+	if ((get_common_reg_word(fp->this_card_priv->ioaddr, 0x72) >> fp->
+	     channel_number) & 1)
+		netif_carrier_off(dev);
+	else
+		netif_carrier_on(dev);
+
+	if (fp->in_eth_mode)
+		mod_timer(&fp->timer, jiffies + 5 * HZ);
+}
+
+/* Just to make it absolutely sure the sending starts again
+ * if the system jams: free already sent skbuffs. */
+
+static void fepci_tx_timeout(struct net_device *dev)
+{
+	struct fepci_ch_private *fp =3D dev->priv;
+
+	if (netif_tx_trylock(dev)) {
+		if (!(fp->tx_interrupts_since_last_timer)) {
+			unsigned i =3D TX_RING_SIZE - 1;
+			do {
+				unsigned desc_b;
+				if (fp->tx_skbuff[i] =3D=3D NULL)
+					continue;
+				desc_b =3D readl(&fp->tx_desc[i].desc_b);
+				if ((desc_b & transfer_not_done) =3D=3D 0) {
+					/* has been sent */
+					pci_unmap_single(fp->
+							 this_card_priv->
+							 pci_dev,
+							 readl(&fp->
+							       tx_desc[i].
+							       desc_a),
+							 desc_b &
+							 frame_length,
+							 PCI_DMA_TODEVICE);
+					dev_kfree_skb(fp->tx_skbuff[i]);
+
+					fp->tx_skbuff[i] =3D NULL;
+
+					if (desc_b & fifo_error)
+						fp->stats.tx_fifo_errors++;
+					else
+						fp->stats.tx_packets++;
+				}
+			}
+			while (i--);
+		}
+		/* if the next descriptor is free, continue taking new ones */
+		if (!
+		    (readl(&fp->tx_desc[fp->cur_tx].desc_b) &
+		     transfer_not_done))
+			netif_wake_queue(dev);
+		netif_tx_unlock(dev);
+	}
+
+	fp->tx_interrupts_since_last_timer =3D 0;
+}
+
+/* Initialize the rx and tx rings */
+static void fepci_init_ring(struct net_device *dev)
+{
+	struct fepci_ch_private *fp =3D dev->priv;
+	unsigned i;
+
+	fp->rx_buf_sz =3D 2000;
+
+	for (i =3D 0; i < RX_RING_SIZE; i++) {
+		struct sk_buff *skb =3D
+		    __dev_alloc_skb(fp->rx_buf_sz, GFP_KERNEL);
+
+		if (unlikely(skb =3D=3D NULL)) {
+ZERO:
+			writel(0, &fp->rx_desc[i].desc_a);
+			writel(0, &fp->rx_desc[i].desc_b);
+			continue;
+		} else {
+			dma_addr_t bus_address =3D
+			    pci_map_single(fp->this_card_priv->pci_dev,
+					   skb->data, fp->rx_buf_sz,
+					   PCI_DMA_FROMDEVICE);
+			if (likely(!pci_dma_mapping_error(bus_address))) {
+				/* Mark as being used by this device */
+				skb->dev =3D dev;
+				skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+				fp->rx_skbuff[i] =3D skb;
+				writel(bus_address, &fp->rx_desc[i].desc_a);
+				writel(enable_transfer, &fp->rx_desc[i].desc_b);
+			} else {
+				dev_kfree_skb(skb);
+				goto ZERO;
+			}
+		}
+	}
+
+	for (i =3D 0; i < TX_RING_SIZE; i++) {
+		fp->tx_skbuff[i] =3D NULL;
+		writel(0, &fp->tx_desc[i].desc_a);	/* no skbuff */
+		/* no transfer enable, no int enable */
+		writel(0, &fp->tx_desc[i].desc_b);
+	}
+
+	return;
+}
+
+static int fepci_start_xmit(struct sk_buff *skb, struct net_device *de=
v)
+{
+	struct fepci_ch_private *fp =3D dev->priv;
+	const unsigned cur_tx =3D fp->cur_tx;
+	unsigned next;
+	unsigned tx_length =3D skb->len;
+	dma_addr_t bus_address;
+	struct sk_buff *old;
+
+	if (unlikely(tx_length < ETH_ZLEN)) {
+		struct sk_buff *bigger =3D
+		    skb_copy_expand(skb, 0, ETH_ZLEN - tx_length,
+				    GFP_ATOMIC);
+		if (unlikely(!bigger))
+			return NET_XMIT_CN;
+		tx_length =3D ETH_ZLEN;
+		old =3D skb;
+		skb =3D bigger;
+	} else
+		old =3D NULL;
+	bus_address =3D
+	    pci_map_single(fp->this_card_priv->pci_dev, skb->data,
+			   tx_length, PCI_DMA_TODEVICE);
+	if (likely(!pci_dma_mapping_error(bus_address))) {
+		struct fepci_desc *descriptor;
+		if (old)
+			dev_kfree_skb(old);
+		descriptor =3D &fp->tx_desc[cur_tx];
+		writel(bus_address, &descriptor->desc_a);
+		writel((tx_length & frame_length) | enable_transfer,
+		       &descriptor->desc_b);
+	} else {
+		if (old)
+			dev_kfree_skb(skb);
+		return NET_XMIT_CN;
+	}
+	fp->stats.tx_bytes +=3D tx_length;
+
+	fp->tx_skbuff[cur_tx] =3D skb;
+
+	/* Calculate the next Tx descriptor entry */
+	next =3D (cur_tx + 1) & (TX_RING_SIZE - 1);
+	fp->cur_tx =3D next;
+	/* if the next descriptor is busy, discontinue taking new ones */
+	if (fp->tx_skbuff[next] !=3D NULL)
+		netif_stop_queue(dev);
+	dev->trans_start =3D jiffies;
+
+	return NET_XMIT_SUCCESS;
+}
+
+static irqreturn_t fepci_interrupt(int irq, void *dev_instance)
+{
+	struct net_device *dev =3D dev_instance;
+	void *ioaddr =3D (void *)dev->base_addr;
+	struct fepci_ch_private *fp =3D dev->priv;
+	unsigned intr_status =3D get_int_status(fp->channel_number, ioaddr);
+
+	if (unlikely(!intr_status))
+		return IRQ_NONE;
+	clear_int(fp->channel_number, intr_status, ioaddr);
+
+	if (intr_status &
+		(IntrFrameReceived | IntrRxFifoError | IntrRxFrameDroppedError))
+		fepci_rx(dev);
+	if (intr_status & IntrFrameTransmitted) {
+		fp->tx_interrupts_since_last_timer++;
+		if (netif_tx_trylock(dev)) {
+			unsigned i =3D TX_RING_SIZE - 1;
+			unsigned next;
+			do {
+				unsigned desc_b;
+				if (fp->tx_skbuff[i] =3D=3D NULL)
+					continue;
+				desc_b =3D readl(&fp->tx_desc[i].desc_b);
+				if ((desc_b & transfer_not_done) =3D=3D 0) {
+					/* has been sent */
+					pci_unmap_single(fp->
+							 this_card_priv->
+							 pci_dev,
+							 readl(&fp->
+							       tx_desc[i].
+							       desc_a),
+							 desc_b &
+							 frame_length,
+							 PCI_DMA_TODEVICE);
+					dev_kfree_skb_irq(fp->tx_skbuff[i]);
+					fp->tx_skbuff[i] =3D NULL;
+					if (desc_b & fifo_error)
+						fp->stats.tx_fifo_errors++;
+					else
+						fp->stats.tx_packets++;
+				}
+			}
+			while (i--);
+			next =3D fp->cur_tx;
+			/* if next tx descriptor is free,
+			 * continue taking new ones */
+			if (!(readl(&fp->tx_desc[next].desc_b) &
+			      transfer_not_done))
+				netif_wake_queue(dev);
+			netif_tx_unlock(dev);
+		}
+	}
+	return IRQ_HANDLED;
+}
+
+static int fepci_rx(struct net_device *dev)
+{
+	struct fepci_ch_private *fp =3D dev->priv;
+
+	unsigned int i, old_cur_rx =3D fp->cur_rx;
+	for (i =3D old_cur_rx;
+	     i !=3D ((old_cur_rx + RX_RING_SIZE - 1) & (RX_RING_SIZE - 1));
+	     i =3D (i + 1) & (RX_RING_SIZE - 1)) {
+		unsigned desc_b;
+		struct sk_buff *skb;
+		/* transfer done */
+		bool condition =3D (skb =3D fp->rx_skbuff[i]) &&
+		    ((desc_b =3D
+		      readl(&fp->rx_desc[i].desc_b)) & transfer_not_done) =3D=3D 0;
+		if (condition) {
+			bool fifo =3D (desc_b & fifo_error) !=3D 0;
+			bool size =3D (desc_b & size_error) !=3D 0;
+			bool crc =3D (desc_b & crc_error) !=3D 0;
+			bool octet =3D (desc_b & octet_error) !=3D 0;
+			bool line =3D (desc_b & line_error) !=3D 0;
+			unsigned length =3D desc_b & frame_length;
+			pci_unmap_single(fp->this_card_priv->pci_dev,
+					 readl(&fp->rx_desc[i].desc_a),
+					 fp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+			fp->cur_rx =3D (i + 1) & (RX_RING_SIZE - 1);
+			if (fifo) {
+				fp->stats.rx_errors++;
+				fp->stats.rx_frame_errors++;
+				writel(enable_transfer, &fp->rx_desc[i].desc_b);
+			} else if (size) {
+				fp->stats.rx_errors++;
+				fp->stats.rx_over_errors++;
+				writel(enable_transfer, &fp->rx_desc[i].desc_b);
+			} else if (crc) {
+				fp->stats.rx_errors++;
+				fp->stats.rx_crc_errors++;
+				writel(enable_transfer, &fp->rx_desc[i].desc_b);
+			} else if (octet)
+				writel(enable_transfer, &fp->rx_desc[i].desc_b);
+			else if (line)
+				writel(enable_transfer, &fp->rx_desc[i].desc_b);
+			else {
+				skb_put(skb, length - 4);
+
+				skb->protocol =3D eth_type_trans(skb, dev);
+#ifdef FEPCI_POINT_TO_POINT
+				if (dev->flags & IFF_POINTOPOINT) {
+					/* everything received is for us. */
+
+					if (dev->flags & IFF_NOARP) {
+						/* NOARP applied ->
+						 * destination MAC addresses
+						 * are bogus */
+						if (skb->
+						    pkt_type =3D=3D
+						    PACKET_OTHERHOST)
+							skb->
+							    pkt_type =3D
+							    PACKET_HOST;
+					} else {
+						/* NOARP not applied ->
+						 * destination MAC addresses are
+						 * broadcast */
+						if (skb->
+						    pkt_type =3D=3D
+						    PACKET_BROADCAST)
+							skb->
+							    pkt_type =3D
+							    PACKET_HOST;
+
+					}	/* IFF_NOARP */
+				}	/* IFF_POINTOPOINT */
+#endif
+				skb_reset_mac_header(skb);
+				netif_rx(skb);
+				/* statistics -4=3D=3Dcrc */
+				fp->stats.rx_bytes +=3D length - 4;
+				fp->stats.rx_packets++;
+
+				fp->rx_skbuff[i] =3D NULL;
+				dev->last_rx =3D jiffies;
+			}
+		}
+		/* reserve a new one */
+		if (fp->rx_skbuff[i] =3D=3D NULL) {
+			struct sk_buff *skb =3D dev_alloc_skb(fp->rx_buf_sz);
+
+			if (skb =3D=3D NULL)
+				continue;	/* Better luck next round. */
+			else {
+				dma_addr_t address =3D
+				    pci_map_single(fp->this_card_priv->pci_dev,
+						   skb->data,
+						   fp->rx_buf_sz,
+						   PCI_DMA_FROMDEVICE);
+				if (likely(!pci_dma_mapping_error(address))) {
+					struct fepci_desc *descriptor;
+					fp->rx_skbuff[i] =3D skb;
+					/* Mark as being used by this device. */
+					skb->dev =3D dev;
+					skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+					descriptor =3D &fp->rx_desc[i];
+					writel(address, &descriptor->desc_a);
+					writel(enable_transfer,
+					       &descriptor->desc_b);
+				} else {
+					dev_kfree_skb(skb);
+					printk(KERN_WARNING
+					       "%s: failed to map DMA.\n",
+					       dev->name);
+				}
+			}
+		}
+	}
+	return 0;
+}
+
+static int fepci_close(struct net_device *dev)
+{
+	struct fepci_ch_private *fp =3D dev->priv;
+	unsigned i;
+	void *ioaddr =3D (void *)dev->base_addr;
+
+	down_write(&fp->this_card_priv->semaphore);
+
+	netif_stop_queue(dev);
+
+	/* Disable interrupts by clearing the interrupt mask */
+	set_int_mask(fp->channel_number, 0x0, fp->this_card_priv);
+
+	/* Stop the Tx and Rx processes */
+	writel(0x0, ioaddr + fp->reg_rxctrl);
+	writel(0x0, ioaddr + fp->reg_txctrl);
+	fp->in_eth_mode =3D 0;
+
+	del_timer_sync(&fp->timer);
+
+	free_irq(dev->irq, dev);
+
+	/* Free all the rx skbuffs */
+	for (i =3D 0; i < RX_RING_SIZE; i++) {
+		if (fp->rx_skbuff[i] !=3D NULL) {
+			pci_unmap_single(fp->this_card_priv->
+					 pci_dev,
+					 readl(&fp->rx_desc[i].
+					       desc_a),
+					 fp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(fp->rx_skbuff[i]);
+			fp->rx_skbuff[i] =3D NULL;
+		}
+	}
+	/* and tx */
+	for (i =3D 0; i < TX_RING_SIZE; i++) {
+		if (fp->tx_skbuff[i] !=3D NULL) {
+			pci_unmap_single(fp->this_card_priv->
+					 pci_dev,
+					 readl(&fp->tx_desc[i].
+					       desc_a),
+					 readl(&fp->tx_desc[i].
+					       desc_b) & frame_length,
+					 PCI_DMA_TODEVICE);
+			dev_kfree_skb(fp->tx_skbuff[i]);
+			fp->tx_skbuff[i] =3D NULL;
+		}
+	}
+	up_write(&fp->this_card_priv->semaphore);
+	return 0;
+}
+
+static struct net_device_stats *fepci_get_stats(struct net_device *dev=
)
+{
+	struct fepci_ch_private *fp =3D dev->priv;
+	return &fp->stats;
+}
+
+static void set_rx_mode(struct net_device *dev)
+{
+	dev_dbg(&dev->dev, "set_rx_mode\n");
+}
+
+static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int =
cmd)
+{
+	struct fepci_ch_private *fp =3D dev->priv;
+	char data =3D ((unsigned)rq->ifr_data) & 0xff;
+	int ret =3D 0;
+
+	dev_dbg(&dev->dev, "netdev_ioctl called (command_nmbr:0x%x).\n",
+		cmd);
+
+	switch (cmd) {
+	case FEPCI_NETDEV_IOCTL_STREAM_BUFSIZE:
+		dev_dbg
+		    (&dev->dev,
+		     " ioctl stream bufsize commanded. (bufsize:0x%x)\n",
+		     data);
+		down_write(&fp->this_card_priv->semaphore);
+		if (fp->in_stream_mode) {
+			up_write(&fp->this_card_priv->semaphore);
+			return -EBUSY;
+		}
+		fp->bufsize_order =3D data;
+		up_write(&fp->this_card_priv->semaphore);
+		break;
+	case FEPCI_NETDEV_IOCTL_STREAM_UNITSIZE:
+		dev_dbg
+		    (&dev->dev,
+		     " ioctl stream unitsize commanded. (unitsize:0x%x)\n",
+		     data);
+		down_write(&fp->this_card_priv->semaphore);
+		if (fp->in_stream_mode) {
+			up_write(&fp->this_card_priv->semaphore);
+			return -EBUSY;
+		}
+		fp->fake_unit_sz_order =3D data;
+		up_write(&fp->this_card_priv->semaphore);
+		break;
+	case FEPCI_NETDEV_IOCTL_STREAM_OPEN:
+		dev_dbg(&dev->dev, " ioctl stream open commanded.\n");
+		ret =3D fepci_stream_open(dev);
+		break;
+	case FEPCI_NETDEV_IOCTL_STREAM_START:
+		dev_dbg(&dev->dev, " ioctl stream start commanded.\n");
+		ret =3D fepci_stream_start(dev);
+		break;
+	case FEPCI_NETDEV_IOCTL_STREAM_CLOSE:
+		dev_dbg(&dev->dev, " ioctl stream close commanded.\n");
+		ret =3D fepci_stream_close(dev);
+		break;
+	default:
+		dev_dbg(&dev->dev, " unknown ioctl command 0x%x.\n", cmd);
+		return -ENOTTY;
+	}
+	return ret;
+}
+
+static void fepci_remove_one(struct pci_dev *pdev)
+{
+	/* from first dev, same in all */
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct fepci_ch_private *fp =3D dev->priv;
+	struct fepci_card_private *cardp =3D fp->this_card_priv;
+	unsigned int i;
+
+	writel(0, (void *)(cardp->ioaddr + reg_custom));
+	/* alarm manager int off */
+
+	for (i =3D 0; i < CHANNELS; i++) {
+		dev =3D cardp->ch_privates[i]->this_dev;
+		fp =3D dev->priv;
+		unregister_netdev(dev);
+		fepci_stream_close(dev);
+		free_netdev(dev);
+	}
+
+	pdev =3D cardp->pci_dev;
+	free_irq(pdev->irq, (void *)cardp);
+
+	down_write(&cardp->semaphore);
+
+	fepci_proc_cleanup_card(cardp->card_number);
+
+	pci_set_drvdata(pdev, NULL);
+
+	if (cardp->card_number + 1 =3D=3D find_cnt)
+		find_cnt--;
+	cardp->pci_dev =3D NULL;
+
+	iounmap(cardp->ioaddr);
+
+	up_write(&cardp->semaphore);
+
+	pci_disable_device(pdev);
+	pci_release_regions(pdev);
+}
+
+static struct pci_driver fepci_driver =3D {
+name:		DRV_NAME,
+id_table:	fepci_pci_tbl,
+probe:		fepci_init_one,
+remove:		fepci_remove_one,
+};
+
+static int __init fepci_init(void)
+{
+	unsigned card =3D MAX_DEVICES - 1;
+	do
+		init_rwsem(&card_privates[card].semaphore);
+	while (card--);
+	major =3D fepci_register_char_device();
+	if (major < 0)
+		return major;
+	stream_pointers =3D
+	    (unsigned long)get_zeroed_page(GFP_KERNEL | __GFP_DMA);
+	pr_debug(" %lx.\n", stream_pointers);
+	if (stream_pointers =3D=3D 0) {
+		fepci_unregister_char_device();
+		return -ENOMEM;
+	}
+	pr_debug("SetPageReserved %lu.\n", stream_pointers);
+	SetPageReserved(virt_to_page(stream_pointers));
+	pr_debug("fepci_proc_init_driver.\n");
+	fepci_proc_init_driver();
+	pr_debug("pci_register_driver %p.\n", &fepci_driver);
+	{
+		int ret =3D pci_register_driver(&fepci_driver);
+		if (ret) {
+			fepci_unregister_char_device();
+			ClearPageReserved(virt_to_page(stream_pointers));
+			free_page(stream_pointers);
+			pr_debug
+			    ("pci_register_driver %p failed with %d.\n",
+			     &fepci_driver, ret);
+			fepci_proc_cleanup_driver();
+			return ret;
+		}
+		pr_debug("fepci_init %d.\n", ret);
+		return ret;
+	}
+}
+
+static void __exit fepci_cleanup(void)
+{
+	pr_debug("fepci_cleanup\n");
+	pci_unregister_driver(&fepci_driver);
+	fepci_proc_cleanup_driver();
+	fepci_unregister_char_device();
+	ClearPageReserved(virt_to_page(stream_pointers));
+	free_page(stream_pointers);
+}
+
+module_init(fepci_init);
+module_exit(fepci_cleanup);
+
+static int get_line_data_rate_value(unsigned char line_rate)
+{
+	switch (line_rate) {
+	case 0x00:
+		return 0;
+	case 0x05:
+	case 0x28:
+		return 8;
+	case 0x14:
+		return 256;
+	case 0x15:
+		return 300;
+	case 0x29:
+	case 0x06:
+		return 10;
+	case 0x30:
+		return 32;
+	case 0x34:
+		return 56;
+	case 0x36:
+		return 64;
+	case 0x01:
+	case 0x60:
+	case 0xa0:
+	case 0x20:
+		return 1;
+	default:
+		return -1;
+	}
+}
+
+static char get_line_data_rate_unit(unsigned char line_rate)
+{
+	switch (line_rate) {
+	case 0x00:
+	case 0x01:
+	case 0x05:
+	case 0x06:
+	case 0x14:
+	case 0x15:
+		return 0;
+	case 0x20:
+	case 0x28:
+	case 0x29:
+	case 0x30:
+	case 0x34:
+	case 0x36:
+		return 'k';
+	case 0x60:
+		return 'M';
+	case 0xa0:
+		return 'G';
+	default:
+		return 0;
+	}
+}
+
+static int print_line_type(unsigned char type, char *buf, int pos)
+{
+	pr_debug("print_line_type %c\n", type);
+	switch (type) {
+	case 0:
+		pos +=3D sprintf(buf + pos, "NONE");
+		break;
+	case 1:
+		pos +=3D sprintf(buf + pos, "DCombus management bus");
+		break;
+	case 2:
+		pos +=3D sprintf(buf + pos, "V.24");
+		break;
+	case 3:
+		pos +=3D sprintf(buf + pos, "X.21");
+		break;
+	case 4:
+		pos +=3D sprintf(buf + pos, "V.35");
+		break;
+	case 5:
+		pos +=3D sprintf(buf + pos, "V.11");
+		break;
+	case 6:
+		pos +=3D sprintf(buf + pos, "IDSL (ISDN Basic Rate");
+		break;
+	case 7:
+		pos +=3D sprintf(buf + pos, "E1 nonframed/framed");
+		break;
+	case 8:
+		pos +=3D sprintf(buf + pos, "E2 nonframed/framed");
+		break;
+	case 9:
+		pos +=3D sprintf(buf + pos, "E3 nonframed/framed");
+		break;
+	case 10:
+		pos +=3D sprintf(buf + pos, "T1 nonframed/framed");
+		break;
+	case 11:
+		pos +=3D sprintf(buf + pos, "T2 nonframed/framed");
+		break;
+	case 12:
+		pos +=3D sprintf(buf + pos, "T3 nonframed/framed");
+		break;
+	case 13:
+		pos +=3D sprintf(buf + pos, "HDSL");
+		break;
+	case 14:
+		pos +=3D sprintf(buf + pos, "ADSL");
+		break;
+	case 15:
+		pos +=3D sprintf(buf + pos, "SDSL");
+		break;
+	case 16:
+		pos +=3D sprintf(buf + pos, "HDSL2");
+		break;
+	case 17:
+		pos +=3D sprintf(buf + pos, "VDSL");
+		break;
+	case 18:
+		pos +=3D sprintf(buf + pos, "G.shdsl");
+		break;
+	case 19:
+		pos +=3D sprintf(buf + pos, "SDH");
+		break;
+	case 255:
+		pos +=3D
+		    sprintf(buf + pos, "COMBINATION, get list using mailbox");
+		break;
+	default:
+		pos +=3D sprintf(buf + pos, "reserved");
+	}
+	return pos;
+}
+
+static int print_card_type(unsigned char type, char *buf, int pos)
+{
+	pr_debug("print_card_type\n");
+	switch (type) {
+	case 0x00:
+		pos +=3D sprintf(buf + pos, "illegal  ");
+		break;
+	case 0x01:
+	case 0x02:
+		pos +=3D sprintf(buf + pos, "Retina   ");
+		break;
+	default:
+		pos +=3D sprintf(buf + pos, "reserved ");
+	}
+
+	return pos;
+}
+
+static int print_card_model(unsigned char model, char *buf, int pos)
+{
+	pr_debug("print_card_model\n");
+	switch (model) {
+	case 0x00:
+		pos +=3D sprintf(buf + pos, "illegal  ");
+		break;
+	case 0x01:
+		pos +=3D sprintf(buf + pos, "E2200    ");
+		break;
+	case 0x02:
+		pos +=3D sprintf(buf + pos, "C5400    ");
+		break;
+	default:
+		pos +=3D sprintf(buf + pos, "reserved ");
+	}
+
+	return pos;
+}
+
+static inline u8 get_common_reg(void *ioaddr, unsigned long offsett)
+{
+	unsigned long byte =3D __test_and_clear_bit(0, &offsett);
+	u8 reg;
+	pr_debug("get_common_reg %p, old %p\n",
+		  ioaddr + FEPCI_IDENTIFICATION_OFFSETT + (offsett << 1) +
+		  byte,
+		  &((u32 *) (ioaddr +
+			     FEPCI_IDENTIFICATION_OFFSETT))[offsett / 2]);
+	reg =3D
+	    readb(ioaddr + FEPCI_IDENTIFICATION_OFFSETT + (offsett << 1) +
+		  byte);
+	pr_debug("get_common_reg %p: %u\n",
+		  ioaddr + FEPCI_IDENTIFICATION_OFFSETT + (offsett << 1) +
+		  byte, reg);
+	return reg;
+}
+
+static int fepci_proc_read_features(char *buf, char **start, off_t off=
set,
+				    int len, int *eof, void *data)
+{
+	int pos =3D 0;
+	int tab =3D 0;
+	struct fepci_card_private *cardp;
+	void *ioaddr;
+
+	cardp =3D (struct fepci_card_private *)data;
+
+	down_read(&cardp->semaphore);
+
+	if (unlikely(cardp->pci_dev =3D=3D NULL))
+		goto EOF;
+
+	ioaddr =3D cardp->ioaddr;
+
+	switch (offset) {
+	case 0:
+		pos +=3D sprintf(buf + pos, "\n");
+
+		pos +=3D sprintf(buf + pos, "card type:          ");
+		pos =3D print_card_type(get_common_reg(ioaddr, 0x00), buf, pos);
+		pos +=3D sprintf(buf + pos, "\n");
+
+		pos +=3D sprintf(buf + pos, "model:              ");
+		pos =3D print_card_model(get_common_reg(ioaddr, 0x00), buf, pos);
+		pos +=3D sprintf(buf + pos, "\n");
+
+		pos +=3D sprintf(buf + pos, "serial number:      ");
+		pos +=3D
+		    sprintf(buf + pos, "%2.2x", get_common_reg(ioaddr, 0x07));
+		pos +=3D
+		    sprintf(buf + pos, "%2.2x", get_common_reg(ioaddr, 0x06));
+		pos +=3D
+		    sprintf(buf + pos, "%2.2x", get_common_reg(ioaddr, 0x05));
+		pos +=3D
+		    sprintf(buf + pos, "%2.2x\n", get_common_reg(ioaddr, 0x04));
+
+		pos +=3D sprintf(buf + pos, "version:            ");
+		pos +=3D
+		    sprintf(buf + pos, "%2.2x.", get_common_reg(ioaddr, 0x08));
+		pos +=3D
+		    sprintf(buf + pos, "%2.2x.", get_common_reg(ioaddr, 0x09));
+		pos +=3D
+		    sprintf(buf + pos, "%2.2x.", get_common_reg(ioaddr, 0x0a));
+		pos +=3D
+		    sprintf(buf + pos, "%2.2x\n", get_common_reg(ioaddr, 0x0b));
+
+		pos +=3D sprintf(buf + pos, "\n");
+
+		pos +=3D sprintf(buf + pos, "max. pipe count:    ");
+		pos +=3D sprintf(buf + pos, "%d\n", get_common_reg(ioaddr, 0x03));
+
+		up_read(&cardp->semaphore);
+		*start =3D (char *)1;
+		*eof =3D 1;
+		return min(pos, len);
+	case 1:
+		pos +=3D sprintf(buf + pos, "line count:         ");
+		pos +=3D sprintf(buf + pos, "%d\n", get_common_reg(ioaddr, 0x02));
+
+		pos +=3D sprintf(buf + pos, "line type:          ");
+		pos =3D print_line_type(get_common_reg(ioaddr, 0x0c), buf, pos);
+
+		/* JT: Secondary interface is also printed also,
+		 * if there is one. */
+		if (get_common_reg(ioaddr, 0x10) > 0) {
+			pos +=3D sprintf(buf + pos, " / ");
+			pos =3D
+			    print_line_type(get_common_reg(ioaddr, 0x10),
+					    buf, pos);
+		}
+
+		pos +=3D sprintf(buf + pos, "\n");
+
+		/* JT: Line modes are printed only if
+		 * the card has NO secondary interface. */
+		if (get_common_reg(ioaddr, 0x10) =3D=3D 0) {
+			pos +=3D sprintf(buf + pos, "line modes:         ");
+			tab =3D 0;
+			if (get_common_reg(ioaddr, 0x21) & 0x80) {
+				tab =3D 1;
+				pos +=3D
+				    sprintf(buf + pos,
+					    "framed mode supported\n");
+			}
+			if (get_common_reg(ioaddr, 0x21) & 0x40) {
+				if (tab)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "                    ");
+				else
+					tab =3D 1;
+				pos +=3D
+				    sprintf(buf + pos,
+					    "unframed mode supported\n");
+			}
+			if (get_common_reg(ioaddr, 0x21) & 0x20) {
+				if (tab)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "                    ");
+				else
+					tab =3D 1;
+				pos +=3D
+				    sprintf(buf + pos,
+					    "line code setting available\n");
+			}
+			if (get_common_reg(ioaddr, 0x21) & 0x10) {
+				if (tab)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "                    ");
+				else
+					tab =3D 1;
+				pos +=3D
+				    sprintf(buf + pos,
+					    "line attenuation available\n");
+			}
+			if (get_common_reg(ioaddr, 0x21) & 0x08) {
+				if (tab)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "                    ");
+				else
+					tab =3D 1;
+				pos +=3D
+				    sprintf(buf + pos,
+					    "line quality available\n");
+			}
+			if (get_common_reg(ioaddr, 0x21) & 0x04) {
+				if (tab)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "                    ");
+				else
+					tab =3D 1;
+				pos +=3D
+				    sprintf(buf + pos,
+					    "timing setting available\n");
+			}
+			if (get_common_reg(ioaddr, 0x21) & 0x02) {
+				if (tab)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "                    ");
+				else
+					tab =3D 1;
+				pos +=3D sprintf(buf + pos, "reserved\n");
+			}
+			if (get_common_reg(ioaddr, 0x21) & 0x01) {
+				if (tab)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "                    ");
+				else
+					tab =3D 1;
+				pos +=3D
+				    sprintf(buf + pos,
+					    "line shutdown setting "
+					    "available\n");
+			}
+			if (get_common_reg(ioaddr, 0x21) =3D=3D 0) {
+				if (tab)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "                    ");
+				else
+					tab =3D 1;
+				pos +=3D sprintf(buf + pos, "n/a\n");
+			}
+		}
+		up_read(&cardp->semaphore);
+		*start =3D (char *)1;
+		*eof =3D 1;
+		return min(pos, len);
+	case 2:
+		pos +=3D sprintf(buf + pos, "line rate:          ");
+		if (get_common_reg(ioaddr, 0x28) =3D=3D
+		    get_common_reg(ioaddr, 0x2a)) {
+			if (get_line_data_rate_value
+			    (get_common_reg(ioaddr, 0x26)) < 0)
+				pos +=3D sprintf(buf + pos, "Invalid value");
+			else if (get_line_data_rate_value
+				 (get_common_reg(ioaddr, 0x26))) {
+				pos +=3D sprintf(buf + pos, "fixed ");
+				pos +=3D
+				    sprintf(buf + pos, "%d ",
+					    get_line_data_rate_value
+					    (get_common_reg(ioaddr, 0x26))
+					    * get_common_reg_word(ioaddr,
+								  0x28));
+				if (get_line_data_rate_unit
+				    (get_common_reg(ioaddr, 0x26)))
+					pos +=3D
+					    sprintf(buf + pos, "%c",
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x26)));
+				pos +=3D sprintf(buf + pos, "bps");
+			} else
+				pos +=3D
+				    sprintf(buf + pos,
+					    "No multiplier, "
+					    "get value or list using mailbox");
+		} else {
+			if (get_line_data_rate_value
+			    (get_common_reg(ioaddr, 0x26)) < 0)
+				pos +=3D sprintf(buf + pos, "Invalid value");
+			else if (get_line_data_rate_value
+				 (get_common_reg(ioaddr, 0x26))) {
+				pos +=3D
+				    sprintf(buf + pos, "%d ",
+					    get_line_data_rate_value
+					    (get_common_reg(ioaddr, 0x26))
+					    * get_common_reg_word(ioaddr,
+								  0x28));
+				if (get_line_data_rate_unit
+				    (get_common_reg(ioaddr, 0x26)))
+					pos +=3D
+					    sprintf(buf + pos, "%c",
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x26)));
+				pos +=3D sprintf(buf + pos, "bps - ");
+				pos +=3D
+				    sprintf(buf + pos, "%d ",
+					    get_line_data_rate_value
+					    (get_common_reg(ioaddr, 0x26))
+					    * get_common_reg_word(ioaddr,
+								  0x2a));
+				if (get_line_data_rate_unit
+				    (get_common_reg(ioaddr, 0x26)))
+					pos +=3D
+					    sprintf(buf + pos, "%c",
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x26)));
+				pos +=3D sprintf(buf + pos, "bps");
+			} else
+				pos +=3D
+				    sprintf(buf + pos,
+					    "No multiplier, "
+					    "get value or list using mailbox");
+		}
+
+		/* JT: Line rate of a secondary interface is printed,
+		 * if there is one. */
+		if (get_common_reg(ioaddr, 0x10) > 0) {
+			pos +=3D sprintf(buf + pos, " / ");
+
+			if (get_common_reg(ioaddr, 0x34) =3D=3D
+			    get_common_reg(ioaddr, 0x36)) {
+				if (get_line_data_rate_value
+				    (get_common_reg(ioaddr, 0x26)) < 0)
+					pos +=3D
+					    sprintf(buf + pos, "Invalid value");
+				else if (get_line_data_rate_value
+					 (get_common_reg(ioaddr, 0x26))) {
+					pos +=3D sprintf(buf + pos, "fixed ");
+					pos +=3D
+					    sprintf(buf + pos, "%d ",
+						    get_line_data_rate_value
+						    (get_common_reg
+						     (ioaddr,
+						      0x26)) *
+						    get_common_reg_word
+						    (ioaddr, 0x34));
+					if (get_line_data_rate_unit
+					    (get_common_reg(ioaddr, 0x26))) {
+						char unit =3D
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x26));
+						pos +=3D
+						    sprintf(buf + pos,
+							    "%c", unit);
+					}
+					pos +=3D sprintf(buf + pos, "bps");
+				} else
+					pos +=3D
+					    sprintf(buf + pos,
+						    "No multiplier, "
+						    "get value or "
+						    "list using mailbox");
+			} else {
+				if (get_line_data_rate_value
+				    (get_common_reg(ioaddr, 0x26)) < 0)
+					pos +=3D
+					    sprintf(buf + pos, "Invalid value");
+				else if (get_line_data_rate_value
+					 (get_common_reg(ioaddr, 0x26))) {
+					pos +=3D
+					    sprintf(buf + pos, "%d ",
+						    get_line_data_rate_value
+						    (get_common_reg
+						     (ioaddr,
+						      0x26)) *
+						    get_common_reg_word
+						    (ioaddr, 0x34));
+					if (get_line_data_rate_unit
+					    (get_common_reg(ioaddr, 0x26))) {
+						char unit =3D
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x26));
+						pos +=3D
+						    sprintf(buf + pos,
+							    "%c", unit);
+					}
+					pos +=3D sprintf(buf + pos, "bps - ");
+					pos +=3D
+					    sprintf(buf + pos, "%d ",
+						    get_line_data_rate_value
+						    (get_common_reg
+						     (ioaddr,
+						      0x26)) *
+						    get_common_reg_word
+						    (ioaddr, 0x36));
+					if (get_line_data_rate_unit
+					    (get_common_reg(ioaddr, 0x26))) {
+						char unit =3D
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x26));
+						pos +=3D
+						    sprintf(buf + pos,
+							    "%c", unit);
+					}
+					pos +=3D sprintf(buf + pos, "bps");
+				} else
+					pos +=3D
+					    sprintf(buf + pos,
+						    "No multiplier, "
+						    "get value or list "
+						    "using mailbox");
+			}
+		}
+
+		pos +=3D sprintf(buf + pos, "\n");
+
+		/* JT: Primary line special info is printed only
+		 * if the card has NO secondary interface. */
+		if (get_common_reg(ioaddr, 0x10) =3D=3D 0) {
+			pos +=3D sprintf(buf + pos, "rate sel. methods:  ");
+			if (get_common_reg(ioaddr, 0x28) =3D=3D
+			    get_common_reg(ioaddr, 0x2a))
+				pos +=3D sprintf(buf + pos, "n/a\n");
+			else if ((get_common_reg(ioaddr, 0x22) & 4)
+				 && (get_common_reg(ioaddr, 0x23) & 4))
+				pos +=3D sprintf(buf + pos, "adjust\n");
+			else if (((!get_common_reg(ioaddr, 0x22)) & 4)
+				 && (get_common_reg(ioaddr, 0x23) & 4))
+				pos +=3D sprintf(buf + pos, "adjust(framed)\n");
+			else if ((get_common_reg(ioaddr, 0x22) & 4)
+				 && ((!get_common_reg(ioaddr, 0x23)) & 4))
+				pos +=3D sprintf(buf + pos, "adjust(unframed)\n");
+			else
+				pos +=3D sprintf(buf + pos, "\n");
+
+			pos +=3D sprintf(buf + pos, "\n");
+
+			pos +=3D sprintf(buf + pos, "unframed data rate: ");
+			if (get_common_reg(ioaddr, 0x30) =3D=3D
+			    get_common_reg(ioaddr, 0x32)) {
+				if (get_line_data_rate_value
+				    (get_common_reg(ioaddr, 0x27)) < 0)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "Invalid value\n");
+				else if (get_line_data_rate_value
+					 (get_common_reg(ioaddr, 0x27))) {
+					pos +=3D sprintf(buf + pos, "fixed ");
+					pos +=3D
+					    sprintf(buf + pos, "%d ",
+						    get_line_data_rate_value
+						    (get_common_reg
+						     (ioaddr,
+						      0x27)) *
+						    get_common_reg_word
+						    (ioaddr, 0x30));
+					if (get_line_data_rate_unit
+					    (get_common_reg(ioaddr, 0x27))) {
+						char unit =3D
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x27));
+						pos +=3D
+						    sprintf(buf + pos,
+							    "%c", unit);
+					}
+					pos +=3D sprintf(buf + pos, "bps\n");
+				} else
+					pos +=3D
+					    sprintf(buf + pos,
+						    "No multiplier, "
+						    "get value or list using "
+						    "mailbox\n");
+			} else {
+				if (get_line_data_rate_value
+				    (get_common_reg(ioaddr, 0x27)) < 0)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "Invalid value\n");
+				else if (get_line_data_rate_value
+					 (get_common_reg(ioaddr, 0x27))) {
+					pos +=3D
+					    sprintf(buf + pos, "%d ",
+						    get_line_data_rate_value
+						    (get_common_reg
+						     (ioaddr,
+						      0x27)) *
+						    get_common_reg_word
+						    (ioaddr, 0x30));
+					if (get_line_data_rate_unit
+					    (get_common_reg(ioaddr, 0x27))) {
+						char unit =3D
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x27));
+						pos +=3D
+						    sprintf(buf + pos,
+							    "%c", unit);
+					}
+					pos +=3D sprintf(buf + pos, "bps - ");
+					pos +=3D
+					    sprintf(buf + pos, "%d ",
+						    get_line_data_rate_value
+						    (get_common_reg
+						     (ioaddr,
+						      0x27)) *
+						    get_common_reg_word
+						    (ioaddr, 0x32));
+					if (get_line_data_rate_unit
+					    (get_common_reg(ioaddr, 0x27))) {
+						char unit =3D
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x27));
+						pos +=3D
+						    sprintf(buf + pos,
+							    "%c", unit);
+					}
+					pos +=3D sprintf(buf + pos, "bps\n");
+				} else
+					pos +=3D
+					    sprintf(buf + pos,
+						    "No multiplier, get value "
+						    "or list using mailbox\n");
+			}
+		}
+		up_read(&cardp->semaphore);
+		*start =3D (char *)1;
+		*eof =3D 1;
+		return min(pos, len);
+
+	case 3:
+		/* JT: Line modes are printed only
+		 * if the card has NO secondary interface. */
+		if (get_common_reg(ioaddr, 0x10) =3D=3D 0) {
+			pos +=3D sprintf(buf + pos, "rate sel. methods:  ");
+			if (get_common_reg(ioaddr, 0x30) =3D=3D
+			    get_common_reg(ioaddr, 0x32))
+				pos +=3D sprintf(buf + pos, "n/a\n");
+			else {
+				if (get_common_reg(ioaddr, 0x23) & 1)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "timeslot map\n");
+				if (get_common_reg(ioaddr, 0x23) & 2)
+					pos +=3D sprintf(buf + pos, "adjust\n");
+			}
+
+			pos +=3D sprintf(buf + pos, "framed data rate:   ");
+			if (get_common_reg(ioaddr, 0x2c) =3D=3D
+			    get_common_reg(ioaddr, 0x2e)) {
+				if (get_line_data_rate_value
+				    (get_common_reg(ioaddr, 0x27)) < 0)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "Invalid value\n");
+				else if (get_line_data_rate_value
+					 (get_common_reg(ioaddr, 0x27))) {
+					pos +=3D sprintf(buf + pos, "fixed ");
+					pos +=3D
+					    sprintf(buf + pos, "%d ",
+						    get_line_data_rate_value
+						    (get_common_reg
+						     (ioaddr,
+						      0x27)) *
+						    get_common_reg_word
+						    (ioaddr, 0x2c));
+					if (get_line_data_rate_unit
+					    (get_common_reg(ioaddr, 0x27))) {
+						char unit =3D
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x27));
+						pos +=3D
+						    sprintf(buf + pos,
+							    "%c", unit);
+					}
+					pos +=3D sprintf(buf + pos, "bps\n");
+				} else
+					pos +=3D
+					    sprintf(buf + pos,
+						    "No multiplier, get value "
+						    "or list using mailbox\n");
+			} else {
+				if (get_line_data_rate_value
+				    (get_common_reg(ioaddr, 0x27)) < 0)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "Invalid value\n");
+				else if (get_line_data_rate_value
+					 (get_common_reg(ioaddr, 0x27))) {
+					pos +=3D
+					    sprintf(buf + pos, "%d ",
+						    get_line_data_rate_value
+						    (get_common_reg
+						     (ioaddr,
+						      0x27)) *
+						    get_common_reg_word
+						    (ioaddr, 0x2c));
+					if (get_line_data_rate_unit
+					    (get_common_reg(ioaddr, 0x27))) {
+						char unit =3D
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x27));
+						pos +=3D
+						    sprintf(buf + pos,
+							    "%c", unit);
+					}
+					pos +=3D sprintf(buf + pos, "bps - ");
+					pos +=3D
+					    sprintf(buf + pos, "%d ",
+						    get_line_data_rate_value
+						    (get_common_reg
+						     (ioaddr,
+						      0x27)) *
+						    get_common_reg_word
+						    (ioaddr, 0x2e));
+					if (get_line_data_rate_unit
+					    (get_common_reg(ioaddr, 0x27))) {
+						char unit =3D
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x27));
+						pos +=3D
+						    sprintf(buf + pos,
+							    "%c", unit);
+					}
+					pos +=3D sprintf(buf + pos, "bps\n");
+				} else
+					pos +=3D
+					    sprintf(buf + pos,
+						    "No multiplier, get value "
+						    "or list using mailbox\n");
+			}
+
+			pos +=3D sprintf(buf + pos, "rate sel. methods:  ");
+			if (get_common_reg_word(ioaddr, 0x2c) =3D=3D
+			    get_common_reg_word(ioaddr, 0x2e))
+				pos +=3D sprintf(buf + pos, "n/a\n");
+			else {
+				if (get_common_reg(ioaddr, 0x22) & 1)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "timeslot map\n");
+				if (get_common_reg(ioaddr, 0x22) & 2)
+					pos +=3D sprintf(buf + pos, "adjust\n");
+			}
+		}
+		up_read(&cardp->semaphore);
+		*start =3D (char *)1;
+		*eof =3D 1;
+		return min(pos, len);
+	default:
+EOF:
+		up_read(&cardp->semaphore);
+		*start =3D (char *)0;
+		*eof =3D 1;
+		return 0;
+	}
+}
+
+static int fepci_proc_read_settings(char *buf, char **start, off_t off=
set,
+				    int len, int *eof, void *data)
+{
+	int pos =3D 0;
+	int i, j;
+
+	struct fepci_card_private *cardp;
+	void *ioaddr;
+
+	cardp =3D (struct fepci_card_private *)data;
+
+	down_read(&cardp->semaphore);
+
+	if (unlikely(cardp->pci_dev =3D=3D NULL))
+		goto EOF;
+
+	ioaddr =3D cardp->ioaddr;
+
+	switch (offset) {
+	case 0:
+		j =3D get_common_reg(ioaddr, 0x02);
+
+		for (i =3D 0; i < j; i++) {
+			if ((get_common_reg_word(ioaddr, 0x44) >> i) & 1) {
+				pos +=3D sprintf(buf + pos, "\nline %2d\n", i);
+				pos +=3D sprintf(buf + pos, "-------\n");
+				pos +=3D
+				    sprintf(buf + pos, "mode:               ");
+				if ((get_common_reg_word(ioaddr, 0x46) >>
+				     i) & 1)
+					pos +=3D sprintf(buf + pos, "framed\n");
+				else
+					pos +=3D sprintf(buf + pos, "unframed\n");
+
+				pos +=3D
+				    sprintf(buf + pos, "scrambler:          ");
+				if ((get_common_reg_word(ioaddr, 0x48) >>
+				     i) & 1)
+					pos +=3D sprintf(buf + pos, "enabled\n");
+				else if ((get_common_reg_word(ioaddr, 0x46)
+					  >> i) & 1)
+					pos +=3D sprintf(buf + pos, "n/a\n");
+				else
+					pos +=3D sprintf(buf + pos, "disabled\n");
+
+				pos +=3D
+				    sprintf(buf + pos, "line crc:           ");
+				if ((get_common_reg_word(ioaddr, 0x46) >>
+				     i) & 1) {
+					if ((get_common_reg_word
+					     (ioaddr, 0x4a) >> i) & 1)
+						pos +=3D
+						    sprintf(buf + pos,
+							    "enabled\n");
+					else if (get_common_reg
+						 (ioaddr, 0x22) & 0x20)
+						pos +=3D
+						    sprintf(buf + pos,
+							    "disabled\n");
+					else
+						pos +=3D
+						    sprintf(buf + pos, "n/a\n");
+				} else {
+					if ((get_common_reg_word
+					     (ioaddr, 0x4a) >> i) & 1)
+						pos +=3D
+						    sprintf(buf + pos,
+							    "enabled\n");
+					else if (get_common_reg
+						 (ioaddr, 0x23) & 0x20)
+						pos +=3D
+						    sprintf(buf + pos,
+							    "disabled\n");
+					else
+						pos +=3D
+						    sprintf(buf + pos, "n/a\n");
+				}
+			}
+		}
+
+		/* If there are no enabled lines, "No enabled lines!" printed.
+		 * The settings file would remain empty otherwise. */
+		if ((get_common_reg_word(ioaddr, 0x44)) =3D=3D 0)
+			pos +=3D sprintf(buf + pos, "No enabled lines!\n");
+		up_read(&cardp->semaphore);
+		*start =3D (char *)1;
+		*eof =3D 1;
+		return min(pos, len);
+	case 1:
+		j =3D get_common_reg(ioaddr, 0x03);
+
+		if ((get_common_reg_word(ioaddr, 0x44)) !=3D 0) {
+			for (i =3D 0; i < j; i++) {
+				pos +=3D sprintf(buf + pos, "\npipe %2d\n", i);
+				pos +=3D sprintf(buf + pos, "-------\n");
+
+				pos +=3D
+				    sprintf(buf + pos, "access mode:        ");
+				if ((get_common_reg_word(ioaddr, 0x4e) >>
+				     i) & 1)
+					pos +=3D sprintf(buf + pos, "packet\n");
+				else
+					pos +=3D sprintf(buf + pos, "stream\n");
+
+				pos +=3D
+				    sprintf(buf + pos, "data rate:          ");
+				if (get_line_data_rate_value
+				    (get_common_reg(ioaddr, 0x42)) < 0)
+					pos +=3D
+					    sprintf(buf + pos,
+						    "Invalid value\n");
+				else if (get_line_data_rate_value
+					 (get_common_reg(ioaddr, 0x42))) {
+					pos +=3D
+					    sprintf(buf + pos, "%d ",
+						    get_line_data_rate_value
+						    (get_common_reg
+						     (ioaddr,
+						      0x42)) *
+						    get_common_reg_word
+						    (ioaddr, 0x50 + 2 * i));
+					if (get_line_data_rate_unit
+					    (get_common_reg(ioaddr, 0x42))) {
+						char unit =3D
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x42));
+						pos +=3D
+						    sprintf(buf + pos,
+							    "%c", unit);
+					}
+					pos +=3D sprintf(buf + pos, "bps\n");
+				} else
+					pos +=3D
+					    sprintf(buf + pos,
+						    "No multiplier, get value "
+						    "or list using mailbox\n");
+			}
+		}
+		up_read(&cardp->semaphore);
+		*start =3D (char *)1;
+		*eof =3D 1;
+		return min(pos, len);
+	default:
+EOF:
+		up_read(&cardp->semaphore);
+		*start =3D (char *)0;
+		*eof =3D 1;
+		return 0;
+	}
+}
+
+static void proc_cpy(char *buf_from, char *buf_to, int len)
+{
+	int i;
+	for (i =3D 0; i < len; i++)
+		*(buf_to + i) =3D *(buf_from + i);
+}
+
+static int fepci_proc_read_status(char *buf, char **start, off_t offse=
t,
+				  int len, int *eof, void *data)
+{
+	unsigned int pos =3D 0;
+	unsigned int i, j;
+
+	struct fepci_card_private *cardp;
+
+	void *ioaddr;
+
+	struct fepci_ch_private *fp;
+
+	cardp =3D (struct fepci_card_private *)data;
+
+	down_read(&cardp->semaphore);
+
+	if (unlikely(cardp->pci_dev =3D=3D NULL))
+		goto EOF;
+
+	ioaddr =3D cardp->ioaddr;
+
+	if ((offset & 0xff000) =3D=3D 0) {
+		j =3D get_common_reg(ioaddr, 0x02);
+		for (i =3D 0; i < j; i++) {
+			pos +=3D sprintf(buf + pos, "\nline %2d\n", i);
+			pos +=3D sprintf(buf + pos, "-------\n");
+			pos +=3D sprintf(buf + pos, "status:             ");
+			if ((get_common_reg_word(ioaddr, 0x72) >> i) & 1) {
+				pos +=3D sprintf(buf + pos, "DOWN\n");
+				netif_carrier_off(cardp->ch_privates[i]->
+						  this_dev);
+			} else {
+				netif_carrier_on(cardp->ch_privates[i]->
+						 this_dev);
+				if ((get_common_reg_word(ioaddr, 0x74) >>
+				     i) & 1)
+					pos +=3D sprintf(buf + pos, "UP/Alarm\n");
+				else
+					pos +=3D sprintf(buf + pos, "UP\n");
+			}
+			pos +=3D sprintf(buf + pos, "primary clock:      ");
+			if ((get_common_reg_word(ioaddr, 0x76) >> i) & 1)
+				pos +=3D sprintf(buf + pos, "OK\n");
+			else
+				pos +=3D sprintf(buf + pos, "FAIL\n");
+		}
+		up_read(&cardp->semaphore);
+		if (pos - (0xfff & offset) > (unsigned)len)
+			*start =3D (char *)len;
+		else
+			*start =3D (char *)(0x1000 - (offset & 0xfff));
+		proc_cpy(buf + (offset & 0xfff), buf, len);
+		return min((int)(pos - (0xfff & offset)), len);
+	}
+
+	j =3D get_common_reg(ioaddr, 0x03);
+	if ((j <=3D 0) || (j > 16))
+		j =3D 16;
+	if ((((((unsigned)offset) & 0xff000) >> 12) > 0) &&
+	    (((((unsigned)offset) & 0xff000) >> 12) <=3D j)) {
+		i =3D ((int)((offset & 0xff000) >> 12)) - 1;
+		if (i < CHANNELS) {
+			pos +=3D sprintf(buf + pos, "\npipe %2d\n", i);
+			pos +=3D sprintf(buf + pos, "-------\n");
+			pos +=3D sprintf(buf + pos, "status:             ");
+
+			if (!((get_common_reg_word(ioaddr, 0x78) >> i) & 1))
+				pos +=3D sprintf(buf + pos, "DOWN\n");
+			else if ((get_common_reg_word(ioaddr, 0x7a) >> i) & 1)
+				pos +=3D sprintf(buf + pos, "UP/Degraded\n");
+			else
+				pos +=3D sprintf(buf + pos, "UP\n");
+			if ((get_common_reg_word(ioaddr, 0x4e) >> i) & 1) {
+				pos +=3D
+				    sprintf(buf + pos, "packet counters:\n\n");
+				pos +=3D
+				    sprintf(buf + pos, "rx count: %lu \n",
+					    cardp->ch_privates[i]->stats.
+					    rx_packets);
+				pos +=3D
+				    sprintf(buf + pos, "rx data:  %lu \n",
+					    cardp->ch_privates[i]->stats.
+					    rx_bytes);
+				pos +=3D
+				    sprintf(buf + pos, "rx errors:%lu \n",
+					    cardp->ch_privates[i]->stats.
+					    rx_errors);
+				pos +=3D
+				    sprintf(buf + pos, "tx count: %lu \n",
+					    cardp->ch_privates[i]->stats.
+					    tx_packets);
+				pos +=3D
+				    sprintf(buf + pos, "tx data:  %lu \n",
+					    cardp->ch_privates[i]->stats.
+					    tx_bytes);
+				pos +=3D
+				    sprintf(buf + pos, "tx errors:%lu \n",
+					    cardp->ch_privates[i]->stats.
+					    tx_errors);
+			} else {
+				pos +=3D
+				    sprintf(buf + pos, "stream counters:\n\n");
+				fp =3D cardp->ch_privates[i];
+				pos +=3D sprintf(buf + pos,
+					       "rx_desc_fifo_err_stream : %10u"
+					       "  \n",
+					       fp->rx_desc_fifo_err_stream);
+				pos +=3D
+				    sprintf(buf + pos,
+					    "rx_desc_size_err_stream : %10u"
+					    "  \n",
+					    fp->rx_desc_size_err_stream);
+				pos +=3D
+				    sprintf(buf + pos,
+					    "rx_desc_octet_err_stream : %9u"
+					    "  \n",
+					    fp->rx_desc_octet_err_stream);
+				pos +=3D
+				    sprintf(buf + pos,
+					    "rx_desc_line_err_stream : %10u"
+					    "  \n",
+					    fp->rx_desc_line_err_stream);
+				pos +=3D
+				    sprintf(buf + pos,
+					    "tx_desc_fifo_err_stream : %10u"
+					    "  \n",
+					    fp->tx_desc_fifo_err_stream);
+				pos +=3D
+				    sprintf(buf + pos,
+					    "rx_int_fifo_err_stream : %11u  \n",
+					    fp->rx_int_fifo_err_stream);
+				pos +=3D
+				    sprintf(buf + pos,
+					    "rx_int_frame_dropped_err_stream :"
+					    " %2u  \n",
+					    fp->
+					    rx_int_frame_dropped_err_stream);
+				pos +=3D
+				    sprintf(buf + pos,
+					    "tx_int_fifo_err_stream : %11u  \n",
+					    fp->tx_int_fifo_err_stream);
+			}
+			if (pos - (0xfff & offset) > (unsigned)len)
+				*start =3D (char *)len;
+			else
+				*start =3D (char *)(0x1000 - (offset & 0xfff));
+			proc_cpy(buf + (offset & 0xfff), buf, len);
+		}
+		up_read(&cardp->semaphore);
+		return min((int)(pos - (0xfff & offset)), len);
+	} else {
+EOF:
+		up_read(&cardp->semaphore);
+		*start =3D (char *)0;
+		*eof =3D 1;
+		return 0;
+	}
+}
+
+static int fepci_proc_read_devices(char *buf, char **start, off_t offs=
et,
+				   int len, int *eof, void *data)
+{
+	void *ioaddr;
+	unsigned int pos =3D 0;
+	unsigned int i;
+
+	pos +=3D
+	    sprintf(buf + pos,
+		    "bus:card.function  cardtype model    lines, max rate\n");
+	for (i =3D 0; i < find_cnt; i++) {
+		down_read(&card_privates[i].semaphore);
+		if (likely(card_privates[i].pci_dev)) {	/* the card exists */
+			pos +=3D
+			    sprintf(buf + pos,
+				    "%02x:%s            ",
+				    card_privates[i].pci_dev->bus->
+				    number,
+				    card_privates[i].pci_dev->procent->name);
+			ioaddr =3D card_privates[i].ioaddr;
+			pos =3D
+			    print_card_type(get_common_reg
+					    (ioaddr, 0x00), buf, pos);
+			pos =3D
+			    print_card_model(get_common_reg
+					     (ioaddr, 0x00), buf, pos);
+			pos +=3D
+			    sprintf(buf + pos, "%d",
+				    get_common_reg(ioaddr, 0x02));
+			pos +=3D sprintf(buf + pos, " x ");
+			pos =3D
+			    print_line_type(get_common_reg
+					    (ioaddr, 0x0c), buf, pos);
+			if (get_line_data_rate_value
+			    (get_common_reg(ioaddr, 0x26)) < 0)
+				pos +=3D sprintf(buf + pos, "Invalid value\n");
+			else if (get_line_data_rate_value
+				 (get_common_reg(ioaddr, 0x26))) {
+				pos +=3D sprintf(buf + pos, ", total ");
+				pos +=3D
+				    sprintf(buf + pos, "%d ",
+					    get_line_data_rate_value
+					    (get_common_reg
+					     (ioaddr,
+					      0x26)) *
+					    get_common_reg_word
+					    (ioaddr,
+					     0x2a) *
+					    get_common_reg(ioaddr, 0x02));
+				if (get_line_data_rate_unit
+				    (get_common_reg(ioaddr, 0x26)))
+					pos +=3D
+					    sprintf(buf + pos,
+						    "%c",
+						    get_line_data_rate_unit
+						    (get_common_reg
+						     (ioaddr, 0x26)));
+				pos +=3D sprintf(buf + pos, "bps\n");
+			} else
+				pos +=3D
+				    sprintf(buf + pos,
+					    "No multiplier, get value or list "
+					    "using mailbox\n");
+
+		}
+		up_read(&card_privates[i].semaphore);
+	}
+	pr_debug("fepci_proc_read_devices pos %u < %lu?\n", pos, PAGE_SIZE);
+	*eof =3D 1;
+	return pos;
+}
+
+static int fepci_proc_read_id_list(char *buf, char **start, off_t offs=
et,
+				   int len, int *eof, void *data)
+{
+	unsigned int pos =3D 0;
+	unsigned int i;
+
+	pos +=3D sprintf(buf + pos, "bus:card.function major minor interfaces=
\n");
+	for (i =3D 0; i < find_cnt; i++) {
+		down_read(&card_privates[i].semaphore);
+		if (likely(card_privates[i].pci_dev))	/* the card exists */
+			pos +=3D
+			    sprintf(buf + pos,
+				    "%02x:%s           %03i   %03i   %s..%s\n",
+				    card_privates[i].pci_dev->bus->
+				    number,
+				    card_privates[i].pci_dev->
+				    procent->name, major,
+				    card_privates[i].
+				    ch_privates[0]->minor,
+				    card_privates[i].
+				    ch_privates[0]->this_dev->name,
+				    card_privates[i].
+				    ch_privates[CHANNELS - 1]->this_dev->name);
+		up_read(&card_privates[i].semaphore);
+	}
+
+	pos +=3D sprintf(buf + pos, "\n");
+	pr_debug("fepci_proc_read_id_list pos %u < %lu?\n", pos, PAGE_SIZE);
+	*eof =3D 1;
+	return pos;
+}
+
+const static char DEVICES[] =3D "devices";
+const static char ID_LIST[] =3D "id_list";
+
+static int fepci_proc_init_driver(void)
+{
+	pr_debug("fepci_proc_init_driver\n");
+	proc_root_entry =3D create_proc_entry(fepci_proc_entry_name, S_IFDIR,=
 0);
+	if (!proc_root_entry)
+		printk(KERN_WARNING
+		       "%s: creating proc root dir entry failed.\n",
+		       fepci_NAME);
+
+	create_proc_read_entry(DEVICES, 0, proc_root_entry,
+			       fepci_proc_read_devices, NULL);
+	create_proc_read_entry(ID_LIST, 0, proc_root_entry,
+			       fepci_proc_read_id_list, NULL);
+
+	return 0;
+}
+
+static void fepci_proc_cleanup_driver(void)
+{
+	char name[sizeof(fepci_proc_entry_name) + sizeof(DEVICES)];
+	strcpy(name, fepci_proc_entry_name);
+	name[sizeof(fepci_proc_entry_name) - 1] =3D '/';
+	strcpy(name + sizeof(fepci_proc_entry_name), DEVICES);
+	remove_proc_entry(name, 0);
+	strcpy(name + sizeof(fepci_proc_entry_name), ID_LIST);
+	remove_proc_entry(name, 0);
+	remove_proc_entry(fepci_proc_entry_name, 0);
+}
+
+static void fepci_proc_init_card(int card_number, void *card_data)
+{
+	char buf[50];
+	struct proc_dir_entry *ent;
+	sprintf(buf, "%02x:%02x.%02x",
+		card_privates[card_number].pci_dev->bus->number,
+		PCI_SLOT(card_privates[card_number].pci_dev->devfn),
+		PCI_FUNC(card_privates[card_number].pci_dev->devfn));
+
+	ent =3D create_proc_entry(buf, S_IFDIR, proc_root_entry);
+	if (!ent)
+		printk("%s: creating proc dir entry failed.\n", fepci_NAME);
+
+	sprintf(buf, fepci_features_proc_entry_name,
+		card_privates[card_number].pci_dev->bus->number,
+		PCI_SLOT(card_privates[card_number].pci_dev->devfn),
+		PCI_FUNC(card_privates[card_number].pci_dev->devfn));
+
+	create_proc_read_entry(buf, 0, NULL, fepci_proc_read_features,
+			       card_data);
+
+	sprintf(buf, fepci_settings_proc_entry_name,
+		card_privates[card_number].pci_dev->bus->number,
+		PCI_SLOT(card_privates[card_number].pci_dev->devfn),
+		PCI_FUNC(card_privates[card_number].pci_dev->devfn));
+	create_proc_read_entry(buf, 0, NULL, fepci_proc_read_settings,
+			       card_data);
+
+	sprintf(buf, fepci_status_proc_entry_name,
+		card_privates[card_number].pci_dev->bus->number,
+		PCI_SLOT(card_privates[card_number].pci_dev->devfn),
+		PCI_FUNC(card_privates[card_number].pci_dev->devfn));
+	create_proc_read_entry(buf, 0, NULL, fepci_proc_read_status, card_dat=
a);
+}
+
+static void fepci_proc_cleanup_card(int card_number)
+{
+	char buf[50];
+
+	sprintf(buf, fepci_features_proc_entry_name,
+		card_privates[card_number].pci_dev->bus->number,
+		PCI_SLOT(card_privates[card_number].pci_dev->devfn),
+		PCI_FUNC(card_privates[card_number].pci_dev->devfn));
+	remove_proc_entry(buf, 0);
+	sprintf(buf, fepci_settings_proc_entry_name,
+		card_privates[card_number].pci_dev->bus->number,
+		PCI_SLOT(card_privates[card_number].pci_dev->devfn),
+		PCI_FUNC(card_privates[card_number].pci_dev->devfn));
+	remove_proc_entry(buf, 0);
+	sprintf(buf, fepci_status_proc_entry_name,
+		card_privates[card_number].pci_dev->bus->number,
+		PCI_SLOT(card_privates[card_number].pci_dev->devfn),
+		PCI_FUNC(card_privates[card_number].pci_dev->devfn));
+	remove_proc_entry(buf, 0);
+
+	sprintf(buf, "%02x:%02x.%02x",
+		card_privates[card_number].pci_dev->bus->number,
+		PCI_SLOT(card_privates[card_number].pci_dev->devfn),
+		PCI_FUNC(card_privates[card_number].pci_dev->devfn));
+
+	remove_proc_entry(buf, proc_root_entry);
+}
diff -Napur linux-2.6.23/drivers/net/wan/retina.h linux-2.6.24/drivers/=
net/wan/retina.h
--- linux-2.6.23/drivers/net/wan/retina.h	1970-01-01 02:00:00.000000000=
 +0200
+++ linux-2.6.24/drivers/net/wan/retina.h	2007-10-25 13:10:05.004606703=
 +0300
@@ -0,0 +1,164 @@
+/* V1.0.0 */
+
+/*
+	Copyright (C) 2002-2003 Jouni Kujala, Flexibilis Oy.
+
+	This program is free software; you can redistribute it and/or
+	modify it under the terms of the GNU General Public License
+	as published by the Free Software Foundation; either version 2
+	of the License, or (at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+	GNU General Public License for more details.
+
+	All the drivers derived from or based on this code fall under the
+	GPL and must retain the copyright and license notice.
+*/
+
+#ifndef RETINA_H
+#define RETINA_H
+
+#include <linux/ioctl.h>
+#include <linux/types.h>
+
+/* net device related stuff: */
+#define FEPCI_NETDEV_IOCTL_STREAM_BUFSIZE 0x89F1
+#define FEPCI_NETDEV_IOCTL_STREAM_UNITSIZE 0x89F2
+#define FEPCI_NETDEV_IOCTL_STREAM_OPEN 0x89F3
+#define FEPCI_NETDEV_IOCTL_STREAM_START 0x89F4
+#define FEPCI_NETDEV_IOCTL_STREAM_CLOSE 0x89F6
+
+/* char device related stuff: */
+
+#define FEPCI_SHARED_MEM_OFFSETT 0x8000
+#define FEPCI_IDENTIFICATION_OFFSETT (FEPCI_SHARED_MEM_OFFSETT+0x0)
+#define FEPCI_FEATURES_OFFSETT (FEPCI_SHARED_MEM_OFFSETT+0x40)
+#define FEPCI_SETTINGS_OFFSETT (FEPCI_SHARED_MEM_OFFSETT+0x80)
+#define FEPCI_STATUS_OFFSETT (FEPCI_SHARED_MEM_OFFSETT+0xE0)
+#define FEPCI_MAILBOX_OFFSETT (FEPCI_SHARED_MEM_OFFSETT+0x100)
+
+/* structures for ioctl calls: */
+struct fepci_ioctl_identification {
+	unsigned char data[0x20];
+};
+struct fepci_real_identification {
+	unsigned long int data[0x10];
+};
+
+struct fepci_ioctl_features {
+	unsigned char data[0x20];
+};
+struct fepci_real_features {
+	unsigned long int data[0x10];
+};
+
+struct fepci_ioctl_settings {
+	unsigned char data[0x30];
+};
+struct fepci_real_settings {
+	unsigned long int data[0x15];
+};
+
+struct fepci_ioctl_status {
+	unsigned char data[0x10];
+};
+struct fepci_real_status {
+	unsigned long int data[0x5];
+};
+
+struct fepci_ioctl_shared_mem {
+	unsigned long int data[0x80];
+};
+
+#define FEPCI_IOCTL_MAGIC 0xAA
+
+#define FEPCI_IOCTL_R_SHARED_MEM _IOR(FEPCI_IOCTL_MAGIC, 1, \
+struct fepci_ioctl_shared_mem)
+#define FEPCI_IOCTL_W_SHARED_MEM _IOW(FEPCI_IOCTL_MAGIC, 2, \
+struct fepci_ioctl_shared_mem)
+
+#define FEPCI_IOCTL_G_IDENTIFICATION _IOR(FEPCI_IOCTL_MAGIC, 0x81, \
+struct fepci_ioctl_identification)
+#define FEPCI_IOCTL_G_FEATURES _IOR(FEPCI_IOCTL_MAGIC, 0x82, \
+struct fepci_ioctl_features)
+#define FEPCI_IOCTL_G_SETTINGS _IOR(FEPCI_IOCTL_MAGIC, 0x83, \
+struct fepci_ioctl_settings)
+#define FEPCI_IOCTL_G_STATUS _IOR(FEPCI_IOCTL_MAGIC, 0x84, \
+struct fepci_ioctl_status)
+
+/* mailbox: */
+
+struct fepci_ioctl_mailbox {
+	unsigned char Semafore;
+	unsigned char Mail_number;
+	unsigned char Size;
+	unsigned char Command;
+	unsigned char Data[112];
+};
+
+struct fepci_real_mailbox {
+	__u32 Semafore_Mail_number;
+	__u32 Size_Command;
+	__u32 Data[112 / 2];
+};
+
+#define FEPCI_IOCTL_B_POLL _IO(FEPCI_IOCTL_MAGIC, 0x85)
+#define FEPCI_IOCTL_B_GRAB _IO(FEPCI_IOCTL_MAGIC, 0x86)
+#define FEPCI_IOCTL_B_RELEASE _IO(FEPCI_IOCTL_MAGIC, 0x87)
+#define FEPCI_IOCTL_B_S_CMAIL _IOW(FEPCI_IOCTL_MAGIC, 0x88, \
+struct fepci_ioctl_mailbox)
+#define FEPCI_IOCTL_B_S_QMAIL _IOW(FEPCI_IOCTL_MAGIC, 0x89, \
+struct fepci_ioctl_mailbox)
+#define FEPCI_IOCTL_B_G_MAIL _IOR(FEPCI_IOCTL_MAGIC, 0x90, \
+struct fepci_ioctl_mailbox)
+
+#define FEPCI_IOCTL_ALARM_MANAGER _IO(FEPCI_IOCTL_MAGIC, 0x91)
+#define FEPCI_IOCTL_STREAM_TRANSMIT_POLL _IO(FEPCI_IOCTL_MAGIC, 0x92)
+#define FEPCI_IOCTL_STREAM_RECEIVE_POLL _IO(FEPCI_IOCTL_MAGIC, 0x93)
+#define FEPCI_IOCTL_STREAM_BOTH_POLL _IO(FEPCI_IOCTL_MAGIC, 0x94)
+
+/* stream related stuff: */
+
+/* stream buffer address space:
+ * address: 0x 7 6 5 4   3 2 1 0
+ *              ^ ^ ^
+ *              | | |
+ *           card | area(rx/tx,0=3D=3Drx,1=3D=3Dtx)
+ *             channel     */
+
+#define CARD_ADDRESS_SHIFT 24u
+#define CHANNEL_ADDRESS_SHIFT 20u
+#define AREA_ADDRESS_SHIFT 16u
+
+#define STREAM_BUFFER_POINTER_AREA 0x7fff0000	/* one page reserved */
+
+/* stream buffer pointers (at pointer area):
+ * address: 0x 7 6 5 4   3 2 1 0
+ *                        ^ ^ ^
+ *                        | | |
+ *                     card | area(rx/tx,0=3D=3Drx,4=3D=3Dtx)
+ *                       channel     */
+
+#define CARD_POINTER_SHIFT 8u
+#define CHANNEL_POINTER_SHIFT 4u
+#define AREA_POINTER_SHIFT 2u
+
+/* fake pointers are for faking larger unit sizes to the user than
+ * what is the maximum internal unit size in FEPCI */
+#define USER_RX_S_FAKE_POINTER(__card, __channel, __offset) \
+((u32 *)(((__card << CARD_POINTER_SHIFT) | \
+(__channel << CHANNEL_POINTER_SHIFT) | 0x0) + __offset))
+#define USER_TX_S_FAKE_POINTER(__card, __channel, __offset) \
+((u32 *)(((__card << CARD_POINTER_SHIFT) | \
+(__channel << CHANNEL_POINTER_SHIFT) | 0x4) + __offset))
+
+#define USER_RX_S_POINTER(__card, __channel, __offset) \
+((u32 *)(((__card << CARD_POINTER_SHIFT) | \
+(__channel << CHANNEL_POINTER_SHIFT) | 0x8) + __offset))
+#define USER_TX_S_POINTER(__card, __channel, __offset) \
+((u32 *)(((__card << CARD_POINTER_SHIFT) | \
+(__channel << CHANNEL_POINTER_SHIFT) | 0xC) + __offset))
+
+#endif
diff -Napur linux-2.6.23/MAINTAINERS linux-2.6.24/MAINTAINERS
--- linux-2.6.23/MAINTAINERS	2007-10-09 23:31:38.000000000 +0300
+++ linux-2.6.24/MAINTAINERS	2007-10-23 12:27:47.056221363 +0300
@@ -3149,6 +3149,12 @@ L:	reiserfs-devel@vger.kernel.org
 W:	http://www.namesys.com
 S:	Supported
=20
+RETINA DRIVER
+P:	Matti Linnanvuori
+M:	mattilinnanvuori@yahoo.com
+L:	netdev@vger.kernel.org
+S:	Supported
+
 ROCKETPORT DRIVER
 P:	Comtrol Corp.
 W:	http://www.comtrol.com




      Heute schon einen Blick in die Zukunft von E-Mails wagen? Versuch=
en Sie=B4s mit dem neuen Yahoo! Mail. www.yahoo.de/mail
