From: "Matti Linnanvuori" <mattilinn@gmail.com>
Subject: [patch v0.7.67] WAN: add drivers etp and etp_stream
Date: Thu, 2 Oct 2008 09:05:55 +0300
Message-ID: <ca0148c30810012305g182336b3k538bdd8e6d73953e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:10459 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318AbYJBGF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 02:05:56 -0400
Received: by wf-out-1314.google.com with SMTP id 27so953960wfd.4
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2008 23:05:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Linnanvuori <matti.linnanvuori@ascom.com>

Adding ETP G.703 drivers.

Signed-off-by: Matti Linnanvuori <matti.linnanvuori@ascom.com>

---

This patch is on top of linux-next-20080919. The patch is also in the
following URL:
http://groups.google.com/group/pcidriver/web/etp.patch

--- linux-2.6.27-rc2/MAINTAINERS	2008-08-08 13:21:10.470637659 +0300
+++ linux/MAINTAINERS	2008-08-08 13:25:00.661113955 +0300
@@ -1678,6 +1678,13 @@ P:	Mika Kuoppala
 M:	miku@iki.fi
 S:	Maintained

+ETP WAN DRIVERS
+P:	Matti Linnanvuori
+M:	matti.linnanvuori@ascom.com
+L:	netdev@vger.kernel.org
+L:	linux-kernel@vger.kernel.org
+S:	Supported
+
 EXT2 FILE SYSTEM
 L:	linux-ext4@vger.kernel.org
 S:	Maintained
--- linux-2.6.27-rc2/drivers/net/wan/Kconfig	2008-08-08 13:21:20.448131033 +0300
+++ linux/drivers/net/wan/Kconfig	2008-08-08 12:59:30.828005756 +0300
@@ -492,4 +492,23 @@ config SBNI_MULTILINE

 	  If unsure, say N.

+config ETP
+	tristate "ETP support"
+	depends on PCI
+	help
+	  Driver for ETP PCI and PCI104 cards, which
+	  support G.703 with Cisco-HDLC or Ethernet encapsulation.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called etp.
+
+config ETP_STREAM
+	tristate "ETP raw bitstream and sensitivity support"
+	depends on ETP
+	help
+	  Driver for ETP raw bitstream and sensitivity.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called etp_stream.
+
 endif # WAN
--- linux-2.6.27-rc2/drivers/net/wan/Makefile	2008-08-08
13:21:20.452131629 +0300
+++ linux/drivers/net/wan/Makefile	2008-08-08 12:59:30.828005756 +0300
@@ -41,6 +41,10 @@ obj-$(CONFIG_C101)		+= c101.o
 obj-$(CONFIG_WANXL)		+= wanxl.o
 obj-$(CONFIG_PCI200SYN)		+= pci200syn.o
 obj-$(CONFIG_PC300TOO)		+= pc300too.o
+etp-y				:= etp_main.o etp_idt.o etp_proc.o
+obj-$(CONFIG_ETP)		+= etp.o syncppp.o
+etp-objs			:= $(etp-y)
+obj-$(CONFIG_ETP_STREAM)	+= etp_stream/

 clean-files := wanxlfw.inc
 $(obj)/wanxl.o:	$(obj)/wanxlfw.inc
--- linux-2.6.27-rc2/drivers/net/wan/etp.h	1970-01-01 02:00:00.000000000 +0200
+++ linux/drivers/net/wan/etp.h	2008-08-08 13:07:06.884725537 +0300
@@ -0,0 +1,459 @@
+/* etp.h */
+
+/*
+	Copyright (C) 2005 Jouni Kujala, Flexibilis Oy.
+
+	This program is free software; you can redistribute it and/or
+	modify it under the terms of the GNU General Public License
+	as published by the Free Software Foundation; either version 2
+	of the License, or (at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	All the drivers derived from or based on this code must retain
+	the copyright notice.
+*/
+
+#ifndef _ETP_H_
+#define _ETP_H_
+
+#include <linux/netdevice.h>
+#include <linux/if.h>
+#include <linux/pci.h>
+#include <linux/rcupdate.h>
+#include <net/syncppp.h>
+#include "etp_ioctl.h"
+
+#define PCI_DEVICE_ID_ETP_ORIGINAL	0x2
+#define PCI_DEVICE_ID_ETP_104		0xA
+#define PCI_DEVICE_ID_DONTCARE		0x0
+
+/* Offsets to the registers. */
+#define REG_GENERAL	0x0
+#define REG_LED_CTRL	0x4
+#define REG_RST_CTRL	0x10
+#define REG_NCO_CTRL	0x20
+#define REG_CLK_STAT	0x30
+#define REG_E1_CTRL	0x40
+
+#define	REG_INT_MASK0	0x80
+#define	REG_INT_MASK1	0x84
+#define	REG_INT_MASK2	0x88
+#define	REG_INT_STAT0	0xc0
+#define	REG_INT_STAT1	0xc4
+#define	REG_INT_STAT2	0xc8
+
+#define REG_RXCTRL_IF(x)	(0x2000 + (x) * 0x80)
+#define REG_RXCTRL1_IF(x)	(0x2004 + (x) * 0x80)
+#define REG_TXCTRL_IF(x)	(0x3000 + (x) * 0x80)
+#define REG_TXCTRL1_IF(x)	(0x3004 + (x) * 0x80)
+#define REG_RXCTRL_CH(x)	(0x4000 + (x) * 0x80)
+#define REG_TXCTRL_CH(x)	(0x6000 + (x) * 0x80)
+
+#define REG_RXDESCxA_CHy(x, y) (0x10000 + (x) * 0x8 + (y) * 0x80)
+#define REG_RXDESCxB_CHy(x, y) (0x10004 + (x) * 0x8 + (y) * 0x80)
+
+#define REG_TXDESCxA_CHy(x, y) (0x18000 + (x) * 0x8 + (y) * 0x80)
+#define REG_TXDESCxB_CHy(x, y) (0x18004 + (x) * 0x8 + (y) * 0x80)
+
+struct rxdesc {
+	uint32_t desc_a;
+	uint32_t desc_b;
+};
+
+struct txdesc {
+	uint32_t desc_a;
+	uint32_t desc_b;
+};
+
+/* Bits in General register: */
+
+#define LVDS_ENABLE_MASK	(1 << 20)
+#define LVDS_ENABLE		(1 << 20)
+
+#define E1_RESET_MASK	(1 << 21)
+#define E1_RESET_ENABLE	(1 << 21)
+
+#define E1_HIGH_Z_MASK		(1 << 22)
+#define E1_HIFH_Z_ENABLE	(1 << 22)
+
+#define OUTPUT_CLK_SELECT_MASK	((1 << 27) | (1 << 28) | (1 << 29))
+#define OUTPUT_CLK_SELECT_SHIFT	27
+#define CLOCK_SELECT_LOCAL	0x0
+#define CLOCK_SELECT_DALLAS	0x1
+#define CLOCK_SELECT_RJ		0x2
+#define CLOCK_SELECT_LVDS	0x3
+#define CLOCK_SELECT_E1_GEN	0x5
+#define CLOCK_SELECT_E1_A	0x6
+#define CLOCK_SELECT_NO_CLOCK	0x7
+
+/* Bits in Reset Control register. */
+#define RESET_CH(x)	(1 << (x))
+
+/* Bits in LED ctrl register: */
+#define ALL_LED_BITS		(0x3)
+#define LED_CTRL_OFF		(0x0)
+#define LED_CTRL_ON		(0x1)
+#define LED_CTRL_BLINK		(0x2)
+#define LED_CTRL_TRAFFIC	(0x3)
+
+#define LEDx_SHIFT(x)	((x) * 2)
+
+
+/* Bits in CLOCK STATUS register: */
+#define EXT_CLOCK_RJ_STATUS_MASK	0xFF
+#define EXT_CLOCK_RJ_STATUS_SHIFT	0
+#define EXT_CLOCK_LVDS_STATUS_MASK	0xFF0000
+#define EXT_CLOCK_LVDS_STATUS_SHIFT	16
+#define EXT_CLOCK_NCO_STATUS_MASK	0xFF000000
+#define EXT_CLOCK_NCO_STATUS_SHIFT	24
+
+/* Bits in E1 control register: */
+#define E1_DATA_MASK		0xFF
+#define E1_REGISTER_MASK	0xFFF0000
+#define E1_REGISTER_MASK_NO_IF	0xFF0000
+#define E1_REGISTER_MASK_IF	0xF000000
+#define E1_REGISTER_SHIFT	16
+#define E1_REGISTER_SHIFT_IF	24
+#define E1_DIR_MASK		(1 << 30)
+#define E1_DIR_READ		(1 << 30)
+#define E1_DIR_WRITE		0x0
+#define E1_ACCESS_ON		(1 << 31)
+
+/* Bits in interrupt mask0 and status0 register: */
+#define INT_0_RECEIVED_CH(x)	(1 << (4 * (x)))
+#define INT_0_TRANSMITTED_CH(x)	(1 << (4 * (x) + 1))
+#define INT_0_RX_DROPPED_CH(x)	(1 << (4 * (x) + 2))
+#define INT_0_TX_UNDERF_CH(x)	(1 << (4 * (x) + 3))
+
+/* Bits in interrupt mask2 and status2 register: */
+#define INT_2_E1_INT		(1 << 0)
+#define INT_2_E1_ACCESS_DONE	(1 << 8)
+#define INT_2_ALLINTS		(INT_2_E1_INT | INT_2_E1_ACCESS_DONE)
+#define INT_2_RX_RESYNC_CH(x)	(1 << (16 + (x)))
+#define INT_2_TX_RESYNC_CH(x)	(1 << (24 + (x)))
+
+/* Interrupt bit generalization */
+#define INT_0_BIT_SHIFT_CH(x)	((x) * 4)
+#define INT_2_BIT_SHIFT_CH(x)	((x) + 16)
+#define CH_ALLINTS_MASK		0xF
+#define INT_RECEIVED		(1 << 0)
+#define INT_TRANSMITTED		(1 << 1)
+#define INT_RX_DROPPED		(1 << 2)
+#define INT_TX_UNDERF		(1 << 3)
+
+#define INT2_RX_RESYNC		(1 << 0)
+#define INT2_TX_RESYNC		(1 << 8)
+#define CH_ALLINTS2_MASK	(INT2_RX_RESYNC | INT2_TX_RESYNC)
+
+/* Bits in interface RX control register. */
+#define E1_MODE_HDLC		1
+#define E1_MODE_TIMESLOT	0
+#define E1_MODE_MASK		1
+#define HDLC_CRC_16		(1 << 4)
+#define HDLC_CRC_32		(0)
+#define HDLC_CRC_DELAY		(1 << 5)
+#define HDLC_CRC_MASK		((1 << 4) | (1 << 5))
+#define HDLC_RETINA_FLAG	(1 << 6)
+
+#define CLOCK_SELECT_RX_X	0x8	/* check if clock is rx clock */
+#define CLOCK_SELECT_RX(x)	(((x) | 0x8) & 0xF) /* interface clock */
+#define CLOCK_SELECT_RX_TO_CH(x) ((x) & 0x7)	/* clock select to interface */
+#define TX_CLOCK_SELECT_SHIFT	24
+#define TX_CLOCK_SELECT_MASK	(0xF << TX_CLOCK_SELECT_SHIFT)
+
+/* Bits in channel RX control register */
+#define DMA_LENGTH_LIMIT_MASK		(0xFFF)
+#define FIFO_THRESHOLD_SHIFT		24
+#define FIFO_THRESHOLD_MASK		(0x7 << FIFO_THRESHOLD_SHIFT)
+#define RX_FIFO_THRESHOLD_DEFAULT	(0x2 << FIFO_THRESHOLD_SHIFT)
+#define DMA_ENABLE_MASK			(1 << 31)
+#define DMA_ENABLE			(1 << 31)
+
+/* Bits in channel TX control register */
+#define TX_FIFO_THRESHOLD_DEFAULT (0x6 << FIFO_THRESHOLD_SHIFT)
+#define TX_START_LEVEL_SHIFT	27
+#define TX_START_LEVEL_MASK	(0x7 << TX_START_LEVEL_SHIFT)
+#define TX_START_LEVEL_DEFAULT	(0x4 << TX_START_LEVEL_SHIFT)
+
+/* Bits in descriptors */
+#define RX_DESCB_LENGT_MASK	(0xFFF)
+#define RX_DESCB_FIFO_ERR	(1 << 16)
+#define RX_DESCB_SIZE_ERR	(1 << 17)
+#define RX_DESCB_CRC_ERR	(1 << 18)
+#define RX_DESCB_OCTET_ERR	(1 << 19)
+#define RX_DESCB_TRANSFER	(1 << 31)
+
+#define TX_DESCB_LENGT_MASK	(0xFFF)
+#define TX_DESCB_FIFO_ERR	(1 << 16)
+#define TX_DESCB_TRANSFER	(1 << 31)
+
+/* interface to channel defines: */
+#define IF_TO_CH(x) (x)
+#define CH_TO_IF(x) (x)
+
+#define DESCRIPTORS_PER_CHANNEL	8
+#define TX_TIMEOUT	(1*HZ)	/* 1 sec in jiffies */
+
+struct etp_netdev_priv {
+	void *if_ptr;		/* General purpose pointer (used by SPPP) */
+	struct etp_channel_private *cp;
+};
+
+#define MAX_SLOTS  65535
+#define MIN_SLOTS  0x8
+#define SLOT_SIZE  0x100
+
+#define E1_TIMESLOTS_PER_CHANNEL  32
+struct e1_frame {
+	uint8_t e1_timeslot[E1_TIMESLOTS_PER_CHANNEL];
+};
+
+#define FRAMES_IN_SLOT 8
+struct slot_struct {
+	struct e1_frame e1_frame[FRAMES_IN_SLOT];
+};
+
+#define ETP_TIMER (HZ > 1000 / DESCRIPTORS_PER_CHANNEL)
+
+struct rx_descriptor {
+	struct rxdesc __iomem *descriptor;
+	struct sk_buff *skb;
+	DECLARE_PCI_UNMAP_ADDR(address)
+};
+
+struct tx_descriptor {
+	struct txdesc __iomem *descriptor;
+	struct sk_buff *skb;
+	DECLARE_PCI_UNMAP_ADDR(address)
+};
+
+struct etp_channel_private {
+	struct etp_device_private *this_dev_priv;
+	struct net_device *this_netdev;
+	struct napi_struct napi;
+	bool interrupt; /* A reception or transmission event to handle? */
+	unsigned char channel_number;	/* channel number inside a device */
+	unsigned char device_number;
+	uint32_t __iomem *reg_ch_rxctrl;
+	struct rx_descriptor rx_descriptor[DESCRIPTORS_PER_CHANNEL];
+	uint32_t __iomem *reg_ch_txctrl;
+	struct tx_descriptor tx_descriptor[DESCRIPTORS_PER_CHANNEL];
+/* ------------ hdlc mode specific: ------------- */
+	uint32_t hdlc_mode_g704_used_timeslots;
+	unsigned char hdlc_mode;	/* HDLC_MODE_XXXX */
+	/* last or next sent descriptor written by etp_netdev_start_xmit */
+	unsigned char last_tx_desc_transmitted;
+/* ------------ timeslot mode specific: ------------- */
+	unsigned short tx_slots; /* 8 - */
+/* ------------- syncppp specific: ----------------- */
+	struct ppp_device pppdevice;
+#if ETP_TIMER
+	struct timer_list timer;
+#endif
+	struct slot_struct *rx;
+	dma_addr_t rx_address;
+	void (*rx_callback) (unsigned device,
+			     unsigned interface,
+			     unsigned read,
+			     const struct slot_struct *rx);
+	unsigned short rx_slots; /* 8 - */
+	unsigned short last_rx_slot_received;
+	/* last or next received descriptor */
+	unsigned char last_rx_desc_received;
+	unsigned char last_tx_desc_released; /* last tx descriptor released */
+	unsigned short last_tx_slot_transmitted;
+	struct slot_struct *tx;
+	dma_addr_t tx_address;
+	void (*tx_callback) (unsigned device,
+			     unsigned interface,
+			     unsigned written,
+			     struct slot_struct *tx);
+	atomic_t owner; /* Owner (0, 1 or unowned) of callbacks. */
+};
+
+/**
+ * Locking order: 1 struct etp_device_private idt[0]
+ *		  2 struct etp_device_private idt[1]
+ *		  3 struct etp_interface_private semaphore e1_00
+ *		  ...
+ *		  66 struct etp_interface_private semaphore e1_63
+ *		  67 rtnl_lock();
+ *		  68 struct etp_device_private mutex
+ **/
+
+struct etp_interface_private {
+	struct etp_channel_private ch_priv;
+	struct rw_semaphore semaphore;
+	uint32_t tx_clock_source;
+	/* The updates of the next word are synchronized with rtnl_lock(): */
+	unsigned char if_mode;
+	bool los; /* Loss of signal? */
+
+	/* interface specific register locations: */
+	uint32_t __iomem *reg_if_rxctrl;
+	uint32_t __iomem *reg_if_txctrl;
+	uint32_t __iomem *reg_if_rxctrl1;
+	uint32_t __iomem *reg_if_txctrl1;
+};
+
+enum { ETP_CALLBACKS = 2 };
+typedef void (*etp_idt_callback_t) (unsigned device);
+
+struct etp_device_private {
+	struct work_struct status_work;
+	struct mutex idt; /* The next word is written with mutex locked. */
+	unsigned char number; /* The number of the card. */
+	unsigned char run[ETP_CALLBACKS]; /* Run callback with index? Bitmap. */
+	etp_idt_callback_t idt_int_callback[ETP_CALLBACKS];
+	struct delayed_work led;
+	struct workqueue_struct *queue;
+	struct etp_interface_private interface_privates[INTERFACES_PER_DEVICE];
+
+	struct mutex mutex; /* IDT chip access mutex */
+	atomic_t reset;	/* 1: device unusable; 0: device usable. */
+	atomic_t interrupt; /* 1: IDT interrupt; 0: no IDT interrupt. */
+	uint32_t led_register_value;
+	spinlock_t lock2;
+	uint32_t reg_int_mask2;
+
+	struct pci_dev *pci_dev;	/* this PCI device */
+	uint8_t __iomem *ioaddr;
+	spinlock_t lock0;
+	uint32_t reg_int_mask0;
+};
+
+extern unsigned get_led(const struct etp_interface_private *ip);
+
+extern struct etp_device_private **etp_devices;
+
+static inline struct etp_device_private *get_dev_priv(unsigned device)
+{
+	struct etp_device_private *card;
+	rcu_read_lock();
+	card = rcu_dereference(etp_devices[device]);
+	rcu_read_unlock();
+	return card;
+}
+
+static inline
+struct etp_interface_private *this_if_priv(const struct
etp_channel_private *cp)
+{
+	return container_of(cp, struct etp_interface_private, ch_priv);
+}
+
+static inline unsigned device_number(const struct etp_device_private *dp)
+{
+	return dp->number;
+}
+
+/* kernel interface: struct to be used when registering callback functions: */
+
+struct etp_callback_struct {
+	void (*rx_callback) (unsigned device,
+			     unsigned interface,
+			     unsigned read,
+			     const struct slot_struct *buffer);
+	void (*tx_callback) (unsigned device,
+			     unsigned interface,
+			     unsigned written,
+			     struct slot_struct *buffer);
+	void (*idt_int_callback) (unsigned device);
+	unsigned device, interface;
+	bool index;
+};
+
+/**
+ * Functions callable from inside kernel, i.e.  kernel interface functions.
+ * Unless otherwise stated, the functions return 0 on success.
+ **/
+
+static inline struct etp_device_private *
+this_device_priv(const struct etp_channel_private *cp)
+{
+	return cp->this_dev_priv;
+}
+
+static inline
+struct etp_device_private *this_dev_priv(const struct
etp_interface_private *ip)
+{
+	return this_device_priv(&ip->ch_priv);
+}
+
+static inline unsigned interface_number(const struct etp_interface_private *ip)
+{
+	return CH_TO_IF(ip->ch_priv.channel_number);
+}
+
+/* Registers callback fuctions. */
+extern int etp_register_callbacks(const struct etp_callback_struct *callback);
+
+/* Open interface (timeslot and stream mode only). */
+extern int etp_if_open(unsigned device,
+		       unsigned interface,
+		       unsigned if_mode,
+		       unsigned rx_slots,
+		       unsigned tx_slots);
+
+/**
+ * Set timeslot (true) or stream (false) mode for an interface that
is in stream
+ * or timeslot mode. Caller must hold rtnl_lock().
+ **/
+extern int etp_frame(unsigned device, unsigned interface, bool frame);
+
+/* Close interface (timeslot and stream mode only) */
+extern int etp_if_close(unsigned device, unsigned interface);
+
+/* Start transmitter (timeslotand stream mode only) */
+int etp_tx_on(unsigned device, unsigned interface);
+
+/* Stop transmitter (timeslot and stream mode only). */
+int etp_tx_off(unsigned device, unsigned interface);
+
+/* Start receiver (timeslot and stream mode only) */
+int etp_rx_on(unsigned device, unsigned interface);
+
+/* Stop receiver (timeslot and stream mode only) */
+int etp_rx_off(unsigned device, unsigned interface);
+
+/* Change settings of an interface. */
+int etp_if_settings(unsigned device,
+		    unsigned interface,
+		    uint32_t clock_source,
+		    unsigned hdlc_mode,	/* HDLC_MODE_XXX  */
+		    uint32_t hdlc_mode_g704_used_timeslots);
+
+/* Det output clock source. */
+int etp_ext_output_clock(unsigned device, uint32_t clock_source);
+
+/* Fine tune local clock frequency */
+int etp_nco_adjust(unsigned device, uint32_t nco_addend_value);
+
+extern unsigned etp_number;
+/* Ask the number of devices installed in the system. */
+static inline unsigned etp_number_devices(void)
+{
+	return etp_number;
+}
+
+/* Gets the current settings and status of a device */
+int etp_device_status_get(unsigned device,
+			  struct etp_device_status_struct *device_status);
+
+int etp_interface_status_get(unsigned device, unsigned interface,
+			     struct etp_interface_status_struct *status);
+
+extern uint32_t etp_rx_on_get(const struct etp_channel_private *cp);
+
+extern uint32_t etp_tx_on_get(const struct etp_channel_private *cp);
+
+void etp_down(struct etp_device_private *device);
+
+void etp_up(struct etp_device_private *device);
+
+/* returns IDT register address offset of a card's span or -ENXIO on error. */
+int etp_idt_offset(unsigned card_number, unsigned span);
+#endif
--- linux-2.6.27-rc2/drivers/net/wan/etp_ioctl.h	1970-01-01
02:00:00.000000000 +0200
+++ linux/drivers/net/wan/etp_ioctl.h	2008-08-08 13:07:06.928732087 +0300
@@ -0,0 +1,139 @@
+/* etp_ioctl.h */
+
+/*
+	Copyright (C) 2005 Jouni Kujala, Flexibilis Oy.
+
+	This program is free software; you can redistribute it and/or
+	modify it under the terms of the GNU General Public License
+	as published by the Free Software Foundation; either version 2
+	of the License, or (at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	All the drivers derived from or based on this code must retain
+	the copyright notice.
+*/
+
+#ifndef _ETP_IOCTL_H_
+#define _ETP_IOCTL_H_
+
+#define INTERFACES_PER_DEVICE		8
+#define E1_TIMESLOTS_PER_INTERFACE	32
+
+#define ETP_IOCTL_MAGIC 0xF2
+
+#define CLOCK_SOURCE_NCO	0x0
+#define CLOCK_SOURCE_DALLAS	0x1
+#define CLOCK_SOURCE_RJ		0x2
+#define CLOCK_SOURCE_LVDS	0x3
+#define CLOCK_SOURCE_RX(x)	(((x) | 0x8) & 0xF)
+#define CLOCK_SOURCE_RX0	CLOCK_SOURCE_RX(0)
+#define CLOCK_SOURCE_RX1	CLOCK_SOURCE_RX(1)
+#define CLOCK_SOURCE_RX2	CLOCK_SOURCE_RX(2)
+#define CLOCK_SOURCE_RX3	CLOCK_SOURCE_RX(3)
+#define CLOCK_SOURCE_RX4	CLOCK_SOURCE_RX(4)
+#define CLOCK_SOURCE_RX5	CLOCK_SOURCE_RX(5)
+#define CLOCK_SOURCE_RX6	CLOCK_SOURCE_RX(6)
+#define CLOCK_SOURCE_RX7	CLOCK_SOURCE_RX(7)
+
+#define LOCAL_CLK_kHz		32768	/* local crystal on the board */
+#define CLOCK_COUNTER_PERIOD	512
+#define COUNTER_TO_kHz(x) ((x) * (LOCAL_CLK_kHz / CLOCK_COUNTER_PERIOD))
+#define NCO_ADDEND_DEFAULT_VALUE	0x10000000	/* 2 Mbps */
+#define PCM_RATE_kHz			8
+
+struct etp_device_status_struct {
+	/* Value sets the frequency of numerically controllable oscillator. */
+	uint32_t nco_addend_value;
+	unsigned int external_input_clock_rj_status;	/* 0 idle, 1 active */
+	unsigned int external_input_clock_rj_speed;	/* in kHz */
+	unsigned int external_input_clock_lvds_status;	/* 0 idle, 1 active */
+	unsigned int external_input_clock_lvds_speed;	/* in kHz */
+	uint32_t ext_output_clock_source;	/* CLOCK_SOURCE_XXXX */
+};
+
+struct etp_interface_status_struct {
+	unsigned int interface;
+	/* settable ones: */
+#define IF_MODE_CLOSED   0
+#define IF_MODE_HDLC     1
+#define IF_MODE_TIMESLOT 2
+#define IF_MODE_STREAM   3
+	unsigned int mode;	/* IF_MODE_XXXX */
+	uint32_t tx_on;	/* 0 no, DMA_ENABLE_MASK yes */
+	uint32_t rx_on;	/* 0 no, DMA_ENABLE_MASK yes */
+	uint32_t tx_clock_source;	/* CLOCK_SOURCE_XXXX */
+#define HDLC_MODE_CISCO_OVER_G703 0
+#define HDLC_MODE_CISCO_OVER_G704 1
+#define HDLC_MODE_RETINA_OVER_G703 10
+#define HDLC_MODE_RETINA_OVER_G704 11
+#define HDLC_MODE_RETINA_OVER_G703_POINTOPOINT 12
+#define HDLC_MODE_RETINA_OVER_G704_POINTOPOINT 13
+	unsigned int hdlc_mode;	/* HDLC_MODE_XXXX */
+	uint32_t hdlc_mode_g704_used_timeslots;	/* timeslots for HDLC frame */
+	unsigned int led;	/* LED status */
+	unsigned int loss_of_signal;	/* 1 = loss of signal */
+};
+
+/* ioctl call specific structures: */
+struct etp_ioctl_open {
+	unsigned int interface;	/* 0 .. INTERFACES_PER_DEVICE-1 */
+	unsigned int if_mode;	/* IF_MODE_TIMESLOT or IF_MODE_STREAM */
+	unsigned int rx_slots;
+	unsigned int tx_slots;
+};
+
+struct etp_ioctl_interface_settings {
+	unsigned int interface;	/* 0 .. INTERFACES_PER_DEVICE-1 */
+	uint32_t tx_clock_source;	/* CLOCK_SOURCE_XXX */
+	unsigned int hdlc_mode;	/* HDLC_MODE_XXX */
+	uint32_t hdlc_mode_g704_used_timeslots;	/* timeslots for HDLC frame */
+};
+
+struct etp_ioctl_ext_output_clock {
+	uint32_t clock_source;	/* CLOCK_SOURCE_X */
+};
+
+struct etp_ioctl_nco_adjust {
+	uint32_t nco_addend_value;
+};
+
+struct etp_ioctl_e1_access {
+	unsigned int write;	/* 0 = read, 1 = write */
+	unsigned int address;	/* address on E1 chip */
+	unsigned int data;	/* data read or written */
+};
+
+struct etp_ioctl_buffer_poll {
+	unsigned int interface;	/* 0 .. INTERFACES_PER_DEVICE-1 */
+	unsigned int rx_slot;	/* latest rx slot received */
+	unsigned int tx_slot;	/* latest tx slot transmitted */
+};
+
+/* ioctl calls: */
+#define ETP_IOCTL_INTERFACE_OPEN _IOW(ETP_IOCTL_MAGIC, 1, struct
etp_ioctl_open)
+#define ETP_IOCTL_INTERFACE_CLOSE _IO(ETP_IOCTL_MAGIC, 2)
+#define ETP_IOCTL_TX_ON _IO(ETP_IOCTL_MAGIC, 10)
+#define ETP_IOCTL_TX_OFF _IO(ETP_IOCTL_MAGIC, 11)
+#define ETP_IOCTL_RX_ON _IO(ETP_IOCTL_MAGIC, 12)
+#define ETP_IOCTL_RX_OFF _IO(ETP_IOCTL_MAGIC, 13)
+
+#define ETP_IOCTL_INTERFACE_SETTINGS \
+	_IOW(ETP_IOCTL_MAGIC, 20, struct etp_ioctl_interface_settings)
+#define ETP_IOCTL_EXT_OUTPUT_CLOCK \
+	_IOW(ETP_IOCTL_MAGIC, 21, struct etp_ioctl_ext_output_clock)
+#define ETP_IOCTL_NCO _IOW(ETP_IOCTL_MAGIC, 22, struct etp_ioctl_nco_adjust)
+
+#define ETP_IOCTL_DEVICE_STATUS_GET \
+	_IOWR(ETP_IOCTL_MAGIC, 30, struct etp_device_status_struct)
+#define ETP_IOCTL_INTERFACE_STATUS_GET \
+	_IOWR(ETP_IOCTL_MAGIC, 31, struct etp_interface_status_struct)
+#define ETP_IOCTL_E1_ACCESS \
+	_IOWR(ETP_IOCTL_MAGIC, 32, struct etp_ioctl_e1_access)
+#define ETP_IOCTL_RXTX_NOSLEEP_POLL \
+	_IOWR(ETP_IOCTL_MAGIC, 35, struct etp_ioctl_buffer_poll)
+
+#endif
--- linux-2.6.27-rc2/drivers/net/wan/etp_idt.h	1970-01-01
02:00:00.000000000 +0200
+++ linux/drivers/net/wan/etp_idt.h	2008-08-08 13:07:06.916730302 +0300
@@ -0,0 +1,115 @@
+/* etp_idt.h */
+
+/*
+	Copyright (C) 2005 Jouni Kujala, Flexibilis Oy.
+
+	This program is free software; you can redistribute it and/or
+	modify it under the terms of the GNU General Public License
+	as published by the Free Software Foundation; either version 2
+	of the License, or (at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	All the drivers derived from or based on this code must retain
+	the copyright notice.
+*/
+
+#ifndef _ETP_IDT_H_
+#define _ETP_IDT_H_
+#include "etp.h"
+#include "idt82p2288.h"
+
+#define ALL_IDT_INTERFACES 0xFF
+#define IDT_INTERFACES	8
+
+static inline unsigned if_to_idt_if_etp(unsigned interface)
+{
+	static const unsigned char to_idt_if[] = { 6, 4, 0, 2, 7, 5, 1, 3 };
+	return to_idt_if[interface];
+}
+
+static inline unsigned if_to_idt_if_etp104(unsigned interface)
+{
+	return 7 - interface;
+}
+
+static inline unsigned idt_if_to_if_etp(unsigned interface)
+{
+	static const unsigned char to_if[] = { 2, 6, 3, 7, 1, 5, 0, 4 };
+	return to_if[interface];
+}
+
+static inline unsigned idt_if_to_if_etp104(unsigned interface)
+{
+	return 7 - interface;
+}
+
+extern unsigned int etp_if_to_idt_if(unsigned interface,
+				     unsigned short pci_device_id);
+
+/**
+ * Returns the IDT register offset of a span whose number is given as
the second
+ * argument.
+ **/
+static inline unsigned idt_offset_down(const struct etp_device_private *device,
+				       unsigned span)
+{
+	return etp_if_to_idt_if(span, device->pci_dev->device) << 8;
+}
+
+extern void idt_init_default(struct etp_device_private *dp);
+extern int idt_open_if_hdlc_g703(struct etp_device_private *dp,
+				 unsigned);
+extern int idt_open_if_hdlc_g704(struct etp_device_private *dp,
+				 unsigned);
+extern int idt_open_if_timeslot(struct etp_device_private *dp,
+				unsigned);
+extern int idt_open_if_stream(struct etp_device_private *dp,
+			      unsigned);
+extern int idt_close_if(struct etp_device_private *dp, unsigned);
+extern int etp_idt_reset(unsigned device);
+
+extern int etp_read_idt_register_lock(unsigned device, unsigned reg);
+extern int etp_read_idt_register_if_lock(unsigned device, unsigned reg,
+					 unsigned interface);
+
+static inline unsigned read_idt_register(uint32_t __iomem *ioaddr,
unsigned reg)
+{
+	unsigned value;
+	while (readl_relaxed(ioaddr) & E1_ACCESS_ON)
+		cpu_relax();
+	writel(((reg << E1_REGISTER_SHIFT) & E1_REGISTER_MASK)
+	       | E1_DIR_READ | E1_ACCESS_ON,
+		ioaddr);
+	while ((value = readl_relaxed(ioaddr)) & E1_ACCESS_ON)
+		cpu_relax();
+	return value & E1_DATA_MASK;
+}
+
+static inline void write_idt_register(uint32_t __iomem *ioaddr, unsigned value)
+{
+	while (readl_relaxed(ioaddr) & E1_ACCESS_ON)
+		cpu_relax();
+	writel(value, ioaddr);
+}
+
+static inline unsigned etp_value(unsigned reg, unsigned value)
+{
+	return ((reg << E1_REGISTER_SHIFT) & E1_REGISTER_MASK) |
+	       E1_DIR_WRITE | E1_ACCESS_ON | value;
+}
+
+extern int etp_write_idt_register_lock(unsigned device, unsigned reg,
+				       unsigned value);
+extern int etp_write_idt_register_if_lock(unsigned device, unsigned reg,
+					  unsigned interface,
+					  unsigned value);
+
+extern int idt_set_ref_clk(struct etp_device_private *dp,
+			   unsigned interface);
+extern int idt_get_ref_clk(struct etp_device_private *dp);
+
+#endif
--- linux-2.6.27-rc2/drivers/net/wan/etp_idt.c	1970-01-01
02:00:00.000000000 +0200
+++ linux/drivers/net/wan/etp_idt.c	2008-08-08 13:07:06.900727921 +0300
@@ -0,0 +1,346 @@
+/* etp_idt.c */
+
+/*
+	Copyright (C) 2006 Jouni Kujala, Flexibilis Oy.
+
+	This program is free software; you can redistribute it and/or
+	modify it under the terms of the GNU General Public License
+	as published by the Free Software Foundation; either version 2
+	of the License, or (at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	All the drivers derived from or based on this code must retain
+	the copyright notice.
+*/
+
+#include "etp.h"
+#include "etp_ioctl.h"
+#include "etp_idt.h"
+
+int etp_read_idt_register_if_lock(unsigned device, unsigned reg,
+				  unsigned interface)
+{
+	const int offset = etp_idt_offset(device, interface);
+	if (unlikely(offset < 0))
+		return -ENXIO;
+	return etp_read_idt_register_lock(device, reg | offset);
+}
+EXPORT_SYMBOL(etp_read_idt_register_if_lock);
+
+static int
+write_idt_register_if(unsigned device, unsigned reg,
+		      unsigned interface, unsigned value);
+
+static inline unsigned int idt_if_to_if(unsigned interface,
+					unsigned short pci_device_id)
+{
+	switch (pci_device_id) {
+	case PCI_DEVICE_ID_ETP_ORIGINAL:
+		return idt_if_to_if_etp(interface);
+	default:
+		return idt_if_to_if_etp104(interface);
+	}
+}
+
+unsigned int etp_if_to_idt_if(unsigned interface, unsigned short pci_device_id)
+{
+	switch (pci_device_id) {
+	case PCI_DEVICE_ID_ETP_ORIGINAL:
+		return if_to_idt_if_etp(interface);
+	default:
+		return if_to_idt_if_etp104(interface);
+	}
+}
+EXPORT_SYMBOL(etp_if_to_idt_if);
+
+int etp_idt_reset(unsigned device)
+{
+	struct etp_device_private *etp = get_dev_priv(device);
+	int error;
+	etp_down(etp);
+	if (likely(!atomic_read(&etp->reset))) {
+		mutex_lock(&etp->mutex);
+		/* Give SW Reset: */
+		write_idt_register((uint32_t __iomem *)
+				   (etp->ioaddr + REG_E1_CTRL),
+				   etp_value(E1_TRNCVR_SW_RESET_REG, 0x0));
+		/* Wait for PCI write to finish. */
+		readl_relaxed(etp->ioaddr + E1_ACCESS_ON);
+		/* wait for E1 chip to be ready: */
+		msleep(2);	/* should be at least 2 ms */
+		mutex_unlock(&etp->mutex);
+		error = 0;
+	} else {
+		error = -ENXIO;
+	}
+	etp_up(etp);
+	return error;
+}
+EXPORT_SYMBOL(etp_idt_reset);
+
+void idt_init_default(struct etp_device_private *dp)
+{
+	const unsigned device = device_number(dp);
+	/* Enable Tx Jitter Attenuation: */
+	write_idt_register_if(device,
+			      E1_TRNCVR_TX_JITTER_ATTEN_CONF_REG,
+			      ALL_IDT_INTERFACES, 0x08);
+	/* Enable Rx Jitter Attenuation */
+	write_idt_register_if(device,
+			      E1_TRNCVR_RX_JITTER_ATTEN_CONF_REG,
+			      ALL_IDT_INTERFACES, 0x8);
+	/* Select Auto report mode */
+	write_idt_register_if(device,
+			      E1_TRNCVR_MAINT_FUNC_CTRL2_REG,
+			      ALL_IDT_INTERFACES, 0x2);
+	/* Set internal impedance */
+	write_idt_register_if(device,
+			      E1_TRNCVR_TX_RX_TERM_CONF_REG,
+			      ALL_IDT_INTERFACES, 0x9);
+	/* Set the transmit Clock Slave mode */
+	write_idt_register_if(device,
+			      E1_TRNCVR_TBIF_OPERATING_MODE_REG,
+			      ALL_IDT_INTERFACES, 0x1);
+	/* Set Backplane config: Each link uses its own timing: */
+	write_idt_register_if(device,
+			      E1_TRNCVR_BP_GLOBAL_CONF_REG,
+			      ALL_IDT_INTERFACES, 0x14);
+	write_idt_register_if(device,
+			      E1_TRNCVR_TBIF_OPTION_REG,
+			      ALL_IDT_INTERFACES, 0x18);
+	/* Disable the RSD/RSIG tri-state buffer */
+	write_idt_register_if(device,
+			      E1_TRNCVR_RBIF_OPTION_REG,
+			      ALL_IDT_INTERFACES, 0x0C);
+	/* Set the receive Clock Master mode */
+	write_idt_register_if(device,
+			      E1_TRNCVR_RBIF_MODE_REG, ALL_IDT_INTERFACES, 0x0);
+	/* Autoyellow on: */
+	write_idt_register_if(device,
+			      E1_TRNCVR_FGEN_MAINT0_REG,
+			      ALL_IDT_INTERFACES, 0x2);
+	/* Clock select from the recovered clock in line side */
+	write_idt_register_if(device,
+			      E1_TRNCVR_TX_TIMING_OPTION_REG,
+			      ALL_IDT_INTERFACES, 0x0);
+	/* G.775 Alarm detection criteria selected */
+	write_idt_register_if(device,
+			      E1_TRNCVR_ALARM_CRITERIA_CTRL_REG,
+			      ALL_IDT_INTERFACES, 0x2);
+	/* Shall trigger an interrupt to notify about loss of signal. */
+	write_idt_register_if(device, E1_TRNCVR_INT_ENA_CTRL0_REG,
+			      ALL_IDT_INTERFACES, 1);
+/* Shall trigger an interrupt to notify about changes in loss of signal. */
+	write_idt_register_if(device, E1_TRNCVR_INT_TRIG_EDGE_SEL_REG,
+			      ALL_IDT_INTERFACES, 1);
+}
+
+int idt_open_if_hdlc_g703(struct etp_device_private *dp,
+			  unsigned interface)
+{
+	const unsigned device = device_number(dp);
+	/* IDT receive in unframed mode: */
+	int error = write_idt_register_if(device,
+					  E1_TRNCVR_FRMR_MODE0_REG,
+					  interface,
+					  0x0E);
+	if (error)
+		return error;
+	/* idt transmit unframed: (FDIS = 1) */
+	error = write_idt_register_if(device,
+				      E1_TRNCVR_E1_MODE_REG, interface, 0x01);
+	if (error)
+		return error;
+	/* Disable Tx High-Z, Set cable impedance: */
+	return write_idt_register_if(device,
+				     E1_TRNCVR_TX_CONF1_REG, interface, 0x01);
+}
+
+int idt_open_if_hdlc_g704(struct etp_device_private *dp,
+			  unsigned interface)
+{
+	const unsigned device = device_number(dp);
+	/* idt in receive framed mode: */
+	int error = write_idt_register_if(device,
+					  E1_TRNCVR_FRMR_MODE0_REG,
+					  interface,
+					  0x06);
+	if (error)
+		return error;
+	/* IDT transmit framed: (FDIS = 0), no CAS, but CRC. Works with Cisco */
+	error = write_idt_register_if(device,
+				      E1_TRNCVR_E1_MODE_REG, interface, 0x02);
+	if (error)
+		return error;
+	/* Disable Tx High-Z, Set cable impedance: */
+	return write_idt_register_if(device,
+				     E1_TRNCVR_TX_CONF1_REG, interface, 0x01);
+}
+
+int idt_open_if_timeslot(struct etp_device_private *dp, unsigned interface)
+{
+	const unsigned device = device_number(dp);
+	/* IDT in receive framed mode: */
+	int error = write_idt_register_if(device,
+					  E1_TRNCVR_FRMR_MODE0_REG,
+					  interface,
+					  0x06);
+	if (error)
+		return error;
+	/* IDT transmit framed: (FDIS = 0) */
+	error = write_idt_register_if(device,
+				      E1_TRNCVR_E1_MODE_REG, interface, 0x06);
+	if (error)
+		return error;
+	/* Disable Tx High-Z, Set cable impedance: */
+	return write_idt_register_if(device,
+				     E1_TRNCVR_TX_CONF1_REG, interface, 0x01);
+}
+
+int idt_open_if_stream(struct etp_device_private *dp, unsigned interface)
+{
+	const unsigned device = device_number(dp);
+	/* idt receive in unframed mode: */
+	int error = write_idt_register_if(device,
+					  E1_TRNCVR_FRMR_MODE0_REG,
+					  interface,
+					  0x0E);
+	if (error)
+		return error;
+	/* idt transmit unframed: (FDIS = 1) */
+	error = write_idt_register_if(device,
+				      E1_TRNCVR_E1_MODE_REG, interface, 0x01);
+	if (error)
+		return error;
+	/* Disable Tx High-Z, Set cable impedance: */
+	return write_idt_register_if(device,
+				     E1_TRNCVR_TX_CONF1_REG, interface, 0x01);
+}
+
+int idt_close_if(struct etp_device_private *dp, unsigned interface)
+{
+	/* Tx to High-Z: */
+	return write_idt_register_if(device_number(dp),
+				     E1_TRNCVR_TX_CONF1_REG, interface, 0x10);
+}
+
+int etp_read_idt_register_lock(unsigned device, unsigned reg)
+{
+	unsigned value;
+	struct etp_device_private *etp = get_dev_priv(device);
+	uint32_t __iomem *ioaddr = (uint32_t __iomem *)
+				   (etp->ioaddr + REG_E1_CTRL);
+	mutex_lock(&etp->mutex);
+	if (unlikely(atomic_read(&etp->reset))) {
+		mutex_unlock(&etp->mutex);
+		return -ENXIO;
+	}
+	value = read_idt_register(ioaddr, reg);
+	mutex_unlock(&etp->mutex);
+	return value;
+}
+EXPORT_SYMBOL(etp_read_idt_register_lock);
+
+
+/**
+ * Returns the IDT register offset of a span whose numbers are given as the
+ * arguments or -ENXIO on no card present.
+ **/
+int etp_idt_offset(unsigned card_number, unsigned span)
+{
+	struct etp_device_private *device = get_dev_priv(card_number);
+	struct mutex *mutex = &device->mutex;
+	int offset;
+	mutex_lock(mutex);
+	if (unlikely(atomic_read(&device->reset)))
+		offset = -ENXIO;
+	else
+		offset = idt_offset_down(device, span);
+	mutex_unlock(mutex);
+	return offset;
+}
+EXPORT_SYMBOL(etp_idt_offset);
+
+static int
+write_idt_register_if(unsigned device, unsigned reg,
+		      unsigned interface, unsigned value)
+{
+	if (interface == ALL_IDT_INTERFACES) {
+		int error;
+		unsigned int i = IDT_INTERFACES - 1u;
+		do {
+			error = etp_write_idt_register_lock(device,
+							    reg | (i << 8),
+							    value);
+			if (unlikely(error))
+				return error;
+		} while (i--);
+		return error;
+	} else {
+		unsigned offset = idt_offset_down(get_dev_priv(device),
+						  interface);
+		return etp_write_idt_register_lock(device, reg | offset, value);
+	}
+}
+
+int etp_write_idt_register_if_lock(unsigned device, unsigned reg,
+				   unsigned interface, unsigned value)
+{
+	if (interface == ALL_IDT_INTERFACES) {
+		int error;
+		unsigned int i = IDT_INTERFACES - 1u;
+		do {
+			error = etp_write_idt_register_lock(device,
+							    reg | (i << 8),
+							    value);
+			if (unlikely(error))
+				return error;
+		} while (i--);
+		return error;
+	} else {
+		int offset = etp_idt_offset(device, interface);
+		if (unlikely(offset == -ENXIO))
+			return offset;
+		return etp_write_idt_register_lock(device, reg | offset, value);
+	}
+}
+EXPORT_SYMBOL(etp_write_idt_register_if_lock);
+
+int etp_write_idt_register_lock(unsigned device, unsigned reg, unsigned value)
+{
+	struct etp_device_private *etp = get_dev_priv(device);
+	mutex_lock(&etp->mutex);
+	if (unlikely(atomic_read(&etp->reset))) {
+		mutex_unlock(&etp->mutex);
+		return -ENXIO;
+	}
+	write_idt_register((uint32_t __iomem *)(etp->ioaddr + REG_E1_CTRL),
+			   etp_value(reg, value));
+	mutex_unlock(&etp->mutex);
+	return 0;
+}
+EXPORT_SYMBOL(etp_write_idt_register_lock);
+
+/* Set ref clk to be from certain interface */
+int idt_set_ref_clk(struct etp_device_private *dp, unsigned interface)
+{
+	unsigned short pci_device_id = dp->pci_dev->device;
+	return etp_write_idt_register_lock(device_number(dp),
+					   E1_TRNCVR_REF_CLK_REG,
+					   etp_if_to_idt_if(interface,
+							    pci_device_id));
+}
+
+/* Get the interface where from the ref clock is. */
+int idt_get_ref_clk(struct etp_device_private *dp)
+{
+	unsigned short pci_device_id = dp->pci_dev->device;
+	return idt_if_to_if(0xf &
+			    etp_read_idt_register_lock(device_number(dp),
+						       E1_TRNCVR_REF_CLK_REG),
+			    pci_device_id);
+}
--- linux-2.6.27-rc2/drivers/net/wan/etp_proc.c	1970-01-01
02:00:00.000000000 +0200
+++ linux/drivers/net/wan/etp_proc.c	2008-08-08 13:07:06.968738040 +0300
@@ -0,0 +1,99 @@
+/* etp_proc.c */
+
+/*
+	Copyright (C) 2005 Jouni Kujala, Flexibilis Oy.
+
+	This program is free software; you can redistribute it and/or
+	modify it under the terms of the GNU General Public License
+	as published by the Free Software Foundation; either version 2
+	of the License, or (at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	All the drivers derived from or based on this code must retain
+	the copyright notice.
+*/
+
+#include "etp.h"
+#include "etp_ioctl.h"
+#include "etp_idt.h"
+
+int etp_device_status_get(unsigned device,
+			  struct etp_device_status_struct *device_status)
+{
+	struct etp_device_private *dp;
+	int error;
+	if (unlikely(device >= etp_number_devices()))
+		return -ENXIO;
+	dp = get_dev_priv(device);
+	down_read(&dp->interface_privates[0].semaphore);
+	if (likely(!atomic_read(&dp->reset))) {
+		uint8_t __iomem *ioaddr = dp->ioaddr;
+		device_status->nco_addend_value =
+		    (readl_relaxed(ioaddr + REG_NCO_CTRL));
+		device_status->external_input_clock_rj_status =
+		    (readl_relaxed(ioaddr + REG_CLK_STAT) &
+		     EXT_CLOCK_RJ_STATUS_MASK) ? 1 : 0;
+		device_status->external_input_clock_rj_speed =
+		    COUNTER_TO_kHz((readl_relaxed(ioaddr + REG_CLK_STAT) &
+				    EXT_CLOCK_RJ_STATUS_MASK) >>
+				   EXT_CLOCK_RJ_STATUS_SHIFT);
+		device_status->external_input_clock_lvds_status =
+		    (readl_relaxed(ioaddr + REG_CLK_STAT) &
+		     EXT_CLOCK_LVDS_STATUS_MASK) ? 1 : 0;
+		device_status->external_input_clock_lvds_speed =
+		    COUNTER_TO_kHz((readl_relaxed(ioaddr + REG_CLK_STAT) &
+				    EXT_CLOCK_LVDS_STATUS_MASK) >>
+				   EXT_CLOCK_LVDS_STATUS_SHIFT);
+		device_status->ext_output_clock_source =
+			(readl_relaxed(ioaddr + REG_GENERAL) &
+			 OUTPUT_CLK_SELECT_MASK) >> OUTPUT_CLK_SELECT_SHIFT;
+		if (device_status->ext_output_clock_source == CLOCK_SELECT_E1_A)
+			device_status->ext_output_clock_source =
+				CLOCK_SELECT_RX(idt_get_ref_clk(dp));
+		error = 0;
+	} else {
+		error = -ENXIO;
+	}
+	up_read(&dp->interface_privates[0].semaphore);
+	return error;
+}
+
+int etp_interface_status_get(unsigned device, unsigned interface,
+			     struct etp_interface_status_struct *status_struct)
+{
+	struct etp_device_private *dp;
+	int error;
+	struct etp_interface_private *ip;
+	if (unlikely(device >= etp_number_devices()
+		     || interface > INTERFACES_PER_DEVICE - 1))
+		return -ENXIO;
+	dp = get_dev_priv(device);
+	ip = &dp->interface_privates[interface];
+	down_read(&ip->semaphore);
+	if (likely(!atomic_read(&dp->reset))) {
+		struct etp_channel_private *cp =
+		    &dp->interface_privates[interface].ch_priv;
+
+		status_struct->interface = interface;
+		status_struct->mode = ip->if_mode;
+		status_struct->tx_on = etp_tx_on_get(cp);
+		status_struct->rx_on = etp_rx_on_get(cp);
+		status_struct->tx_clock_source = ip->tx_clock_source;
+		status_struct->hdlc_mode = cp->hdlc_mode;
+		status_struct->hdlc_mode_g704_used_timeslots =
+		    cp->hdlc_mode_g704_used_timeslots;
+		status_struct->led = get_led(ip);
+		status_struct->loss_of_signal = ip->los
+		    || ip->if_mode == IF_MODE_CLOSED;
+		error = 0;
+	} else {
+		error = -ENXIO;
+	}
+	up_read(&ip->semaphore);
+	return error;
+}
+EXPORT_SYMBOL(etp_interface_status_get);
--- linux-2.6.27-rc2/drivers/net/wan/idt82p2288.h	1970-01-01
02:00:00.000000000 +0200
+++ linux/drivers/net/wan/idt82p2288.h	2008-08-08 13:07:06.988741017 +0300
@@ -0,0 +1,270 @@
+/* Author: Flexibilis Oy / Petri Anttila */
+
+/*
+
+	ATMUX (Analog Telephone Multiplexer)
+
+	Copyright (C) 2005 Petri Anttila, Flexibilis Oy.
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
+*/
+
+#ifndef _IDT82P2281_H_
+#define _IDT82P2281_H_
+
+
+/* Registers*/
+#define E1_TRNCVR_ID_REG                     0x0
+#define E1_TRNCVR_SW_RESET_REG               0x04
+#define E1_TRNCVR_G772_MON_CTRL_REG          0x05
+#define E1_TRNCVR_GPIO_REG                   0x06
+#define E1_TRNCVR_REF_CLK_REG                0x07
+#define E1_TRNCVR_INT_REQ_LINK_ID_REG        0x09
+#define E1_TRNCVR_TIMER_INT_CTRL_REG         0x0A
+#define E1_TRNCVR_TIMER_INT_IND_REG          0x0B
+#define E1_TRNCVR_PMON_ACCESS_PORT_REG       0x0E
+#define E1_TRNCVR_PMON_ACCESS_DATA_REG       0x0F
+#define E1_TRNCVR_BP_GLOBAL_CONF_REG         0x10
+
+#define E1_TRNCVR_T1_E1_MODE_REG             0x20
+#define E1_TRNCVR_TX_JITTER_ATTEN_CONF_REG   0x21
+#define E1_TRNCVR_TX_CONF0_REG               0x22
+#define E1_TRNCVR_TX_CONF1_REG               0x23
+#define E1_TRNCVR_TX_CONF2_REG               0x24
+#define E1_TRNCVR_TX_CONF3_REG               0x25
+#define E1_TRNCVR_TX_CONF4_REG               0x26
+#define E1_TRNCVR_RX_JITTER_ATTEN_CONF_REG   0x27
+#define E1_TRNCVR_RX_CONF0_REG               0x28
+#define E1_TRNCVR_RX_CONF1_REG               0x29
+#define E1_TRNCVR_RX_CONF2_REG               0x2A
+#define E1_TRNCVR_MAINT_FUNC_CTRL0_REG       0x2B
+#define E1_TRNCVR_MAINT_FUNC_CTRL1_REG       0x2C
+#define E1_TRNCVR_MAINT_FUNC_CTRL2_REG       0x31
+#define E1_TRNCVR_TX_RX_TERM_CONF_REG        0x32
+#define E1_TRNCVR_INT_ENA_CTRL0_REG          0x33
+#define E1_TRNCVR_INT_ENA_CTRL1_REG          0x34
+#define E1_TRNCVR_INT_TRIG_EDGE_SEL_REG      0x35
+#define E1_TRNCVR_LINE_STATUS0_REG           0x36
+#define E1_TRNCVR_LINE_STATUS1_REG           0x37
+#define E1_TRNCVR_TX_JITTER_MEAS_VAL_IND_REG 0x38
+#define E1_TRNCVR_RX_JITTER_MEAS_VAL_IND_REG 0x39
+#define E1_TRNCVR_INT_STATUS0_REG            0x3A
+#define E1_TRNCVR_INT_STATUS1_REG            0x3B
+#define E1_TRNCVR_EXZ_ERROR_CNT_H_BYTE_REG   0x3C
+#define E1_TRNCVR_EXZ_ERROR_CNT_L_BYTE_REG   0x3D
+#define E1_TRNCVR_REF_CLK_CTRL_REG           0x3E
+#define E1_TRNCVR_INT_MOD_IND2_REG           0x3F
+#define E1_TRNCVR_INT_MOD_IND0_REG           0x40
+#define E1_TRNCVR_INT_MOD_IND1_REG           0x41
+#define E1_TRNCVR_TBIF_OPTION_REG            0x42
+#define E1_TRNCVR_TBIF_OPERATING_MODE_REG    0x43
+#define E1_TRNCVR_TBIF_TS_OFFSET_REG         0x44
+#define E1_TRNCVR_TBIF_BIT_OFFSET_REG        0x45
+#define E1_TRNCVR_RBIF_OPTION_REG            0x46
+#define E1_TRNCVR_RBIF_MODE_REG              0x47
+#define E1_TRNCVR_RBIF_FRAME_PULSE_REG       0x48
+#define E1_TRNCVR_RBIF_TS_OFFSET_REG         0x49
+#define E1_TRNCVR_RBIF_BIT_OFFSET_REG        0x4A
+#define E1_TRNCVR_RTSFS_CHANGE_IND_REG       0x4B
+#define E1_TRNCVR_RTSFS_INT_CTRL_REG         0x4C
+#define E1_TRNCVR_FRMR_MODE0_REG             0x4D
+#define E1_TRNCVR_FRMR_MODE1_REG             0x4E
+#define E1_TRNCVR_FRMR_STATUS_REG            0x4F
+#define E1_TRNCVR_FRMR_INT_CTRL0_REG         0x50
+#define E1_TRNCVR_FRMR_INT_CTRL1_REG         0x51
+#define E1_TRNCVR_FRMR_INT_IND0_REG          0x52
+#define E1_TRNCVR_FRMR_INT_IND1_REG          0x53
+#define E1_TRNCVR_TS0_INTERNAT_NAT_REG       0x54
+#define E1_TRNCVR_TS16_SPARE_REG             0x55
+#define E1_TRNCVR_SA4_CODEWORD_REG           0x56
+#define E1_TRNCVR_SA5_CODEWORD_REG           0x57
+#define E1_TRNCVR_SA6_CODEWORD_REG           0x58
+#define E1_TRNCVR_SA7_CODEWORD_REG           0x59
+#define E1_TRNCVR_SA8_CODEWORD_REG           0x5A
+#define E1_TRNCVR_SA6_CODEWORD_IND_REG       0x5B
+#define E1_TRNCVR_SA_CODEWORD_INT_CTRL_REG   0x5C
+#define E1_TRNCVR_SA_CODEWORD_INT_IND_REG    0x5D
+#define E1_TRNCVR_OVERH_ERROR_STATUS_REG     0x5F
+#define E1_TRNCVR_OVERH_INT_CTRL_REG         0x60
+#define E1_TRNCVR_OVERH_INT_IND_REG          0x61
+#define E1_TRNCVR_E1_MODE_REG                0x62
+#define E1_TRNCVR_FGEN_INTERN_BIT_REG        0x63
+#define E1_TRNCVR_FGEN_SA_CTRL_REG           0x64
+#define E1_TRNCVR_SA4_CODE_WORD_REG          0x65
+#define E1_TRNCVR_SA5_CODE_WORD_REG          0x66
+#define E1_TRNCVR_SA6_CODE_WORD_REG          0x67
+#define E1_TRNCVR_SA7_CODE_WORD_REG          0x68
+#define E1_TRNCVR_SA8_CODE_WORD_REG          0x69
+#define E1_TRNCVR_FGEN_EXTRA_REG             0x6A
+#define E1_TRNCVR_FGEN_MAINT0_REG            0x6B
+#define E1_TRNCVR_FGEN_MAINT1_REG            0x6C
+#define E1_TRNCVR_FGEN_INT_CTRL_REG          0x6D
+#define E1_TRNCVR_FGEN_INT_IND_REG           0x6E
+#define E1_TRNCVR_ERROR_INSERTION_REG        0x6F
+#define E1_TRNCVR_TX_TIMING_OPTION_REG       0x70
+#define E1_TRNCVR_PRGD_CTRL_REG              0x71
+#define E1_TRNCVR_PRGD_STATUS_CTRL_REG       0x72
+#define E1_TRNCVR_PRGD_INT_IND_REG           0x73
+#define E1_TRNCVR_ELST_CONF_REG              0x7C
+#define E1_TRNCVR_ELST_INT_IND_REG           0x7D
+#define E1_TRNCVR_ELST_TRUNK_CODE_REG        0x7E
+
+#define E1_TRNCVR_THDLC_ENA_CTRL_REG         0x84
+#define E1_TRNCVR_THDLC1_ASSIGNMENT_REG      0x85
+#define E1_TRNCVR_THDLC2_ASSIGNMENT_REG      0x86
+#define E1_TRNCVR_THDLC3_ASSIGNMENT_REG      0x87
+#define E1_TRNCVR_THDLC1_BIT_SEL_REG         0x88
+#define E1_TRNCVR_THDLC2_BIT_SEL_REG         0x89
+#define E1_TRNCVR_THDLC3_BIT_SEL_REG         0x8A
+#define E1_TRNCVR_RHDLC_ENA_CTRL_REG         0x8B
+#define E1_TRNCVR_RHDLC1_ASSIGNMENT_REG      0x8C
+#define E1_TRNCVR_RHDLC2_ASSIGNMENT_REG      0x8D
+#define E1_TRNCVR_RHDLC3_ASSIGNMENT_REG      0x8E
+#define E1_TRNCVR_RHDLC1_BIT_SEL_REG         0x8F
+#define E1_TRNCVR_RHDLC2_BIT_SEL_REG         0x90
+#define E1_TRNCVR_RHDLC3_BIT_SEL_REG         0x91
+#define E1_TRNCVR_RHDLC1_CTRL_REG            0x92
+#define E1_TRNCVR_RHDLC2_CTRL_REG            0x93
+#define E1_TRNCVR_RHDLC3_CTRL_REG            0x94
+#define E1_TRNCVR_RHDLC1_RFIFO_ACC_STAT_REG  0x95
+#define E1_TRNCVR_RHDLC2_RFIFO_ACC_STAT_REG  0x96
+#define E1_TRNCVR_RHDLC3_RFIFO_ACC_STAT_REG  0x97
+#define E1_TRNCVR_RHDLC1_DATA_REG            0x98
+#define E1_TRNCVR_RHDLC2_DATA_REG            0x99
+#define E1_TRNCVR_RHDLC3_DATA_REG            0x9A
+#define E1_TRNCVR_RHDLC1_INT_CTRL_REG        0x9B
+#define E1_TRNCVR_RHDLC2_INT_CTRL_REG        0x9C
+#define E1_TRNCVR_RHDLC3_INT_CTRL_REG        0x9D
+#define E1_TRNCVR_RHDLC1_INT_IND_REG         0x9E
+#define E1_TRNCVR_RHDLC2_INT_IND_REG         0x9F
+#define E1_TRNCVR_RHDLC3_INT_IND_REG         0xA0
+#define E1_TRNCVR_RHDLC1_HIGH_ADDR_REG       0xA1
+#define E1_TRNCVR_RHDLC2_HIGH_ADDR_REG       0xA2
+#define E1_TRNCVR_RHDLC3_HIGH_ADDR_REG       0xA3
+#define E1_TRNCVR_RHDLC1_LOW_ADDR_REG        0xA4
+#define E1_TRNCVR_RHDLC2_LOW_ADDR_REG        0xA5
+#define E1_TRNCVR_RHDLC3_LOW_ADDR_REG        0xA6
+#define E1_TRNCVR_THDLC1_CTRL_REG            0xA7
+#define E1_TRNCVR_THDLC2_CTRL_REG            0xA8
+#define E1_TRNCVR_THDLC3_CTRL_REG            0xA9
+#define E1_TRNCVR_TFIFO1_TRESHOLD_REG        0xAA
+#define E1_TRNCVR_TFIFO2_TRESHOLD_REG        0xAB
+#define E1_TRNCVR_TFIFO3_TRESHOLD_REG        0xAC
+#define E1_TRNCVR_THDLC1_DATA_REG            0xAD
+#define E1_TRNCVR_THDLC2_DATA_REG            0xAE
+#define E1_TRNCVR_THDLC3_DATA_REG            0xAF
+#define E1_TRNCVR_TFIFO1_STATUS_REG          0xB0
+#define E1_TRNCVR_TFIFO2_STATUS_REG          0xB1
+#define E1_TRNCVR_TFIFO3_STATUS_REG          0xB2
+#define E1_TRNCVR_THDLC1_INT_CTRL            0XB3
+#define E1_TRNCVR_THDLC2_INT_CTRL            0XB4
+#define E1_TRNCVR_THDLC3_INT_CTRL            0XB5
+#define E1_TRNCVR_THDLC1_INT_IND_REG         0XB6
+#define E1_TRNCVR_THDLC2_INT_IND_REG         0XB7
+#define E1_TRNCVR_THDLC3_INT_IND_REG         0XB8
+#define E1_TRNCVR_ALARM_STATUS_REG           0xB9
+#define E1_TRNCVR_ALARM_CTRL_REG             0xBA
+#define E1_TRNCVR_ALARM_IND_REG              0xBB
+#define E1_TRNCVR_ALARM_CRITERIA_CTRL_REG    0xBC
+#define E1_TRNCVR_PMON_CTRL_REG              0xC2
+#define E1_TRNCVR_PMON_INT_CTRL0_REG         0xC3
+#define E1_TRNCVR_PMON_INT_CTRL1_REG         0xC4
+#define E1_TRNCVR_PMON_INT_IND0_REG          0xC5
+#define E1_TRNCVR_PMON_INT_IND1_REG          0xC6
+#define E1_TRNCVR_TPLC_RPLC_PRGD_TEST_CFG_REG 0xC7
+#define E1_TRNCVR_TPLC_ACCESS_STATUS_REG     0xC8
+#define E1_TRNCVR_TPLC_ACCESS_CTRL_REG       0xC9
+#define E1_TRNCVR_TPLC_ACCESS_DATA_REG       0xCA
+#define E1_TRNCVR_TPLC_CONF_REG              0xCB
+#define E1_TRNCVR_TPLC_CTRL_ENA_REG          0xCC
+#define E1_TRNCVR_RPLC_ACCESS_STATUS_REG     0xCD
+#define E1_TRNCVR_RPLC_ACCESS_CTRL_REG       0xCE
+#define E1_TRNCVR_RPLC_ACCESS_DATA_REG       0xCF
+#define E1_TRNCVR_RPLC_CONF_REG              0xD0
+#define E1_TRNCVR_RPLC_CTRL_ENA_REG          0xD1
+#define E1_TRNCVR_RCRB_CONF_REG              0xD2
+#define E1_TRNCVR_RCRB_ACCESS_STATUS_REG     0xD3
+#define E1_TRNCVR_RCRB_ACCESS_CTRL_REG       0xD4
+#define E1_TRNCVR_RCRB_ACCESS_DATA_REG       0xD5
+#define E1_TRNCVR_RCRB_STATE_CHANGE_IND0_REG 0xD6
+#define E1_TRNCVR_RCRB_STATE_CHANGE_IND1_REG 0xD7
+#define E1_TRNCVR_RCRB_STATE_CHANGE_IND2_REG 0xD8
+#define E1_TRNCVR_RCRB_STATE_CHANGE_IND3_REG 0xD9
+
+/* RCRB INDIRECT REGISTERS*/
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS1   0x01
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS2   0x02
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS3   0x03
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS4   0x04
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS5   0x05
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS6   0x06
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS7   0x07
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS8   0x08
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS9   0x09
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS10   0x0a
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS11   0x0b
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS12   0x0c
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS13   0x0d
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS14   0x0e
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS15   0x0f
+
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS17   0x11
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS18   0x12
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS19   0x13
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS20   0x14
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS21   0x15
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS22   0x16
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS23   0x17
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS24   0x18
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS25   0x19
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS26   0x1a
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS27   0x1b
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS28   0x1c
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS29   0x1d
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS30   0x1e
+#define E1_TRNCVR_RCRB_RX_SIGN_DATA_TS31   0x1f
+
+/* RPLC INDIRECT REGISTERS*/
+
+/* TPLC INDIRECT REGISTERS*/
+#define E1_TRNCVR_TPLC_TS1_SIGNALING_TRUNK_REG  0x41
+#define E1_TRNCVR_TPLC_TS2_SIGNALING_TRUNK_REG  0x42
+#define E1_TRNCVR_TPLC_TS3_SIGNALING_TRUNK_REG  0x43
+#define E1_TRNCVR_TPLC_TS4_SIGNALING_TRUNK_REG  0x44
+#define E1_TRNCVR_TPLC_TS5_SIGNALING_TRUNK_REG  0x45
+#define E1_TRNCVR_TPLC_TS6_SIGNALING_TRUNK_REG  0x46
+#define E1_TRNCVR_TPLC_TS7_SIGNALING_TRUNK_REG  0x47
+#define E1_TRNCVR_TPLC_TS8_SIGNALING_TRUNK_REG  0x48
+#define E1_TRNCVR_TPLC_TS9_SIGNALING_TRUNK_REG  0x49
+#define E1_TRNCVR_TPLC_TS10_SIGNALING_TRUNK_REG  0x4a
+#define E1_TRNCVR_TPLC_TS11_SIGNALING_TRUNK_REG  0x4b
+#define E1_TRNCVR_TPLC_TS12_SIGNALING_TRUNK_REG  0x4c
+#define E1_TRNCVR_TPLC_TS13_SIGNALING_TRUNK_REG  0x4d
+#define E1_TRNCVR_TPLC_TS14_SIGNALING_TRUNK_REG  0x4e
+#define E1_TRNCVR_TPLC_TS15_SIGNALING_TRUNK_REG  0x4f
+
+#define E1_TRNCVR_TPLC_TS17_SIGNALING_TRUNK_REG  0x51
+#define E1_TRNCVR_TPLC_TS18_SIGNALING_TRUNK_REG  0x52
+#define E1_TRNCVR_TPLC_TS19_SIGNALING_TRUNK_REG  0x53
+#define E1_TRNCVR_TPLC_TS20_SIGNALING_TRUNK_REG  0x54
+#define E1_TRNCVR_TPLC_TS21_SIGNALING_TRUNK_REG  0x55
+#define E1_TRNCVR_TPLC_TS22_SIGNALING_TRUNK_REG  0x56
+#define E1_TRNCVR_TPLC_TS23_SIGNALING_TRUNK_REG  0x57
+#define E1_TRNCVR_TPLC_TS24_SIGNALING_TRUNK_REG  0x58
+#define E1_TRNCVR_TPLC_TS25_SIGNALING_TRUNK_REG  0x59
+#define E1_TRNCVR_TPLC_TS26_SIGNALING_TRUNK_REG  0x5a
+#define E1_TRNCVR_TPLC_TS27_SIGNALING_TRUNK_REG  0x5b
+#define E1_TRNCVR_TPLC_TS28_SIGNALING_TRUNK_REG  0x5c
+#define E1_TRNCVR_TPLC_TS29_SIGNALING_TRUNK_REG  0x5d
+#define E1_TRNCVR_TPLC_TS30_SIGNALING_TRUNK_REG  0x5e
+#define E1_TRNCVR_TPLC_TS31_SIGNALING_TRUNK_REG  0x5f
+
+#endif
--- linux-2.6.27-rc2/drivers/net/wan/etp_stream/Makefile	1970-01-01
02:00:00.000000000 +0200
+++ linux/drivers/net/wan/etp_stream/Makefile	2008-08-08
12:59:30.824005131 +0300
@@ -0,0 +1,7 @@
+#
+# Makefile for the ETP stream device driver.
+#
+# 1 Jul 2008, Matti Linnanvuori
+#
+
+obj-$(CONFIG_ETP_STREAM)	+= etp_stream.o
--- linux-2.6.27-rc2/drivers/net/wan/etp_stream/etp_stream.h	1970-01-01
02:00:00.000000000 +0200
+++ linux/drivers/net/wan/etp_stream/etp_stream.h	2008-08-08
13:07:18.042386059 +0300
@@ -0,0 +1,15 @@
+/* etp_stream.h */
+
+/* Matti Linnanvuori, Copyright (C) 2006 Ascom (Finland) Oy. */
+
+#define ETP_STREAM_SLOT _IO(0xE1, 1)
+#define ETP_STREAM_SENSITIVITY _IO(0xE1, 2)
+#define ETP_STREAM_SENSITIVITY_GET _IO(0xE1, 3)
+#define ETP_STREAM_GET_TX_BUFFER_FILL _IO(0xE1, 4)
+#define ETP_STREAM_BUFFER_SIZE_GET _IO(0xE1, 5)
+#define ETP_STREAM_CLEAR 0
+#define ETP_STREAM_OVERFLOW_BIT 0
+#define ETP_STREAM_UNDERFLOW_BIT 1
+#define ETP_STREAM_OVERFLOW (1 << ETP_STREAM_OVERFLOW_BIT)
+#define ETP_STREAM_UNDERFLOW (1 << ETP_STREAM_UNDERFLOW_BIT)
+#define ETP_STREAM_GET_CLEAR_EXCEPTIONS _IO(0xE1, 6)
--- linux-2.6.27-rc2/drivers/net/wan/etp_stream/etp_stream.c	1970-01-01
02:00:00.000000000 +0200
+++ linux/drivers/net/wan/etp_stream/etp_stream.c	2008-08-08
13:07:18.034384868 +0300
@@ -0,0 +1,844 @@
+/**
+ *
+ * etp_stream.c	Pseudowire and sensitivity for ETP Octal E1/T1 card
+ *
+ *
+ * Author	Matti Linnanvuori (matti.linnanvuori@ascom.com)
+ *
+ * This file is (c) under GNU PUBLIC LICENSE
+ *
+ **/
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/poll.h>
+#include <linux/rcupdate.h>
+#include <linux/list.h>
+#include <linux/rtnetlink.h>
+#include <linux/cdev.h>
+
+#include "../etp.h"
+#include "../etp_ioctl.h"
+#include "../etp_idt.h"
+#include "../idt82p2288.h"
+#include "etp_stream.h"
+
+MODULE_DESCRIPTION("ETP Octal E1/T1 card pseudowire and sensitivity module");
+MODULE_VERSION("1.0.33");
+MODULE_AUTHOR("Matti Linnanvuori");
+MODULE_LICENSE("GPL");
+
+enum { RED = HZ / 10ul };
+
+static dev_t from; /* The first in the range of numbers. */
+enum { DEVICES = 256u * INTERFACES_PER_DEVICE };
+static struct cdev cdev;
+
+struct etp_interface {
+	struct mutex mutex;		/* Lock mutex before etp. */
+	struct hlist_head file;		/* struct etp_file objects opened. */
+	wait_queue_head_t queue;	/* Blocking poll system calls queue. */
+	/* The next word is written by either one soft interrupt or one timer */
+	unsigned short transmitting;	/* The number of the slot transmitted */
+	unsigned short receiving;	/* The number of the slot received. */
+	unsigned char g704;	/* The number of open streaming G.704 files. */
+	unsigned char timeslot0;/* The number of open streaming G.704 files
+				   using timeslot 0. */
+	bool out;		/* 1 if out of basic frame synchronization,
+				   else 0. */
+	unsigned long red;	/* jiffies when red alarm would be declared. */
+};
+
+struct etp_card {
+	struct delayed_work work;
+	unsigned number;
+	struct etp_interface interface[INTERFACES_PER_DEVICE];
+};
+
+static struct etp_card *cards; /* Pointer to array. */
+static unsigned number; /* The number of the cards handled by this module. */
+
+struct etp_file {
+	struct hlist_node node;
+	loff_t *position;
+	unsigned char card;	/* The number of the device. */
+	unsigned char interface;/* The number of the interface. */
+	/* Starting timeslot and timeslot range length and first past timeslot
+	   range end. */
+	unsigned char slot, length;
+	unsigned char beyond;
+	atomic_t exceptions;	/* ETP_STREAM_OVERFLOW | ETP_STREAM_UNDERFLOW */
+	unsigned long flow; /* ETP_STREAM_OVERFLOW | ETP_STREAM_UNDERFLOW */
+};
+
+/* Cleans up resources when this kernel module is removed. */
+static void __exit etp_cleanup(void)
+{
+	unregister_chrdev_region(from, DEVICES);
+	cdev_del(&cdev);
+	{
+		unsigned card = number - 1;
+		do {
+			struct etp_card *my_card = cards + card;
+			cancel_delayed_work_sync(&my_card->work);
+		} while (card--);
+	}
+	kfree(cards);
+}
+
+static inline unsigned read_slot(loff_t *ppos)
+{
+	return (*ppos >> 8) & 0xffff;
+}
+
+/* Notifies about reception of data from ETP and checks overflow. */
+static void notify_reception(unsigned device,
+			     unsigned interface,
+			     unsigned can_be_read,
+			     const struct slot_struct *slot)
+{
+	struct hlist_node *node;
+	struct etp_interface *my_interface =
+	    &cards[device].interface[interface];
+	wait_queue_head_t *queue;
+	struct etp_file *file;
+
+	my_interface->receiving = can_be_read;
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(file, node, &my_interface->file, node) {
+		if (unlikely(read_slot(file->position) == can_be_read)) {
+			set_bit(ETP_STREAM_OVERFLOW_BIT, &file->flow);
+			if (!(atomic_read(&file->exceptions) &
+			      ETP_STREAM_OVERFLOW)) {
+				atomic_inc(&file->exceptions);
+				smp_mb__after_atomic_inc();
+			}
+		}
+	}
+	rcu_read_unlock();
+	queue = &my_interface->queue;
+	if (waitqueue_active(queue))
+		wake_up_interruptible(queue);
+}
+
+static inline unsigned write_slot(loff_t *ppos)
+{
+	return *ppos >> 40;
+}
+
+/* Notifies about transmission of data to ETP. */
+static void notify_transmission(unsigned device,
+				unsigned interface,
+				unsigned can_be_written,
+				struct slot_struct *slot)
+{
+	struct etp_interface *my_interface =
+		&cards[device].interface[interface];
+	wait_queue_head_t *queue;
+	struct hlist_node *node;
+	struct etp_file *file;
+
+	my_interface->transmitting = can_be_written;
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(file, node, &my_interface->file, node) {
+		if (unlikely(write_slot(file->position) == can_be_written)) {
+			set_bit(ETP_STREAM_UNDERFLOW_BIT, &file->flow);
+			if (!(atomic_read(&file->exceptions) &
+			      ETP_STREAM_UNDERFLOW))
+				atomic_add(ETP_STREAM_UNDERFLOW,
+					   &file->exceptions);
+		}
+	}
+	rcu_read_unlock();
+	queue = &my_interface->queue;
+	if (waitqueue_active(queue))
+		wake_up_interruptible(queue);
+}
+
+/* Frame alignment signal OK? */
+static inline bool frame(const struct slot_struct *slot)
+{
+	uint8_t last = slot->e1_frame[FRAMES_IN_SLOT - 1u].e1_timeslot[0];
+	if (last & 0x40)
+		last = slot->e1_frame[FRAMES_IN_SLOT - 2u].e1_timeslot[0];
+	return (last & 0x7f) == 0x1b;
+}
+
+/* Clearing all alarm indications to stop redundant IDT interrupts. */
+static void clear_alarm_indications(unsigned device, unsigned interface)
+{
+	int error = etp_write_idt_register_if_lock(device,
+						   E1_TRNCVR_ALARM_IND_REG,
+						   interface, 0x3f);
+	if (unlikely(error))
+		dev_warn(&get_dev_priv(device)->interface_privates[interface]
+			 .ch_priv.this_netdev->dev,
+			 "Failed to clear alarm indication: %d\n", error);
+}
+
+/* Checks if frame alignment signal is OK on a streaming G.703 interface. */
+static inline void
+check_frame(struct etp_card *card, struct etp_device_private *etp,
+	    unsigned device, unsigned interface,
+	    struct etp_interface *my_interface, const struct slot_struct *slot,
+	    const struct etp_channel_private *cp)
+{
+	if (frame(slot)) {
+		my_interface->out = false;
+	} else if (my_interface->out) {
+		if (time_before_eq(my_interface->red, jiffies)) {
+			int error;
+			rtnl_lock();
+			error = etp_frame(device, interface, 1);
+			rtnl_unlock();
+			if (unlikely(error)) {
+				dev_warn(&cp->this_netdev->dev,
+					 "Failed to set to timeslot mode: %d\n",
+					 error);
+			} else {
+				error = etp_write_idt_register_if_lock(device,
+							E1_TRNCVR_E1_MODE_REG,
+							interface, 0u);
+				if (unlikely(error))
+					dev_warn(&cp->this_netdev->dev,
+						 "Failed to disable multi-frame"
+						 ": %d\n", error);
+				else
+					queue_work(etp->queue,
+						   &card->work.work);
+			}
+		}
+	} else {
+		my_interface->red = jiffies + RED;
+		my_interface->out = true;
+	}
+}
+
+/* Checks the alarms and frame alignment on streaming interfaces of a card. */
+static void check_alarm(struct work_struct *work)
+{
+	struct delayed_work *delayed = container_of(work, struct delayed_work,
+						    work);
+	struct etp_card *card = container_of(delayed, struct etp_card, work);
+	const unsigned device = card->number;
+	struct etp_device_private *etp = get_dev_priv(device);
+	struct etp_interface_private *interfaces = etp->interface_privates;
+	struct etp_interface *my_interfaces = card->interface;
+	unsigned interface = 0u;
+	do {
+		struct etp_interface *my_interface = my_interfaces + interface;
+		struct etp_interface_private *ip = interfaces + interface;
+		down_write(&ip->semaphore);
+		if (my_interface->g704) {
+			clear_alarm_indications(device, interface);
+			if (ip->if_mode == IF_MODE_TIMESLOT &&
+			    my_interface->timeslot0) {
+/* Timeslot 0 used. */		unsigned alarm;
+				bool red;
+				if (unlikely(atomic_read(&etp->reset)))
+					break;
+				alarm = etp_read_idt_register_if_lock(
+					device,
+					E1_TRNCVR_ALARM_STATUS_REG,
+					interface);
+				red = alarm & 1u;
+				if (!red) {
+					int error;
+/* No red alarm. */			if (!frame(ip->ch_priv.tx +
+						   ip->ch_priv.
+						   last_tx_slot_transmitted)) {
+						queue_delayed_work(etp->queue,
+								   &card->work,
+								   RED);
+						goto UNLOCK;
+					}
+					rtnl_lock();
+					error = etp_frame(device, interface, 0);
+					rtnl_unlock();
+					my_interface->out = 0;
+					if (unlikely(error))
+						dev_warn(&ip->ch_priv.
+							 this_netdev->dev,
+							 "Failed to set to "
+							 "stream mode: %d\n",
+							 error);
+					else
+						clear_alarm_indications(device,
+								interface);
+				}
+			}
+		}
+UNLOCK:		up_write(&ip->semaphore);
+	} while (interface++ < INTERFACES_PER_DEVICE - 1);
+}
+
+/* Queue streaming alarm and frame alignment checking work. */
+static void etp_idt_int_callback(unsigned device)
+{
+	struct etp_card *card = &cards[device];
+	queue_work(get_dev_priv(device)->queue, &card->work.work);
+}
+
+static inline void save_read(loff_t *ppos, unsigned slot, unsigned frame,
+			     unsigned timeslot)
+{
+	*ppos = (*ppos & 0xffffffff00000000ull) | (slot << 8) | (frame << 5) |
+		timeslot;
+}
+
+static inline void save_write(loff_t *ppos, loff_t slot, loff_t frame,
+			      loff_t timeslot)
+{
+	*ppos = (*ppos & 0xffffffffull) | (slot << 40) | (frame << 37)
+		| (timeslot << 32);
+}
+
+/* Handles the open system call. */
+static int etp_open(struct inode *inode, struct file *filp)
+{
+	unsigned minor = MINOR(inode->i_rdev);
+	unsigned card = minor >> 3;
+	struct etp_file *file;
+	if (unlikely(card >= number))
+		return -ENXIO;
+	if (unlikely(!try_module_get(THIS_MODULE)))
+		return -EBUSY;
+	file = kmalloc(sizeof(struct etp_file), GFP_KERNEL);
+	if (likely(file)) {
+		unsigned interface_number = minor & (INTERFACES_PER_DEVICE - 1);
+		filp->private_data = file;
+		file->interface = interface_number;
+		file->card = card;
+		INIT_HLIST_NODE(&file->node);
+		file->slot = 0u;
+		save_write(&filp->f_pos, 0u, 0u, 0u);
+		save_read(&filp->f_pos, 0u, 0u, 0u);
+		file->beyond = E1_TIMESLOTS_PER_INTERFACE;
+		atomic_set(&file->exceptions, ETP_STREAM_CLEAR);
+		file->flow = ETP_STREAM_CLEAR;
+		file->length = E1_TIMESLOTS_PER_INTERFACE;
+		file->position = &filp->f_pos;
+		return 0;
+	} else {
+		return -ENOMEM;
+	}
+}
+
+/* Handles the close system call. */
+static int etp_close(struct inode *inode, struct file *filp)
+{
+	struct etp_file *file = filp->private_data;
+	if (!hlist_unhashed(&file->node)) {
+		const unsigned card_number = file->card;
+		const unsigned interface_number = file->interface;
+		struct etp_card *card = &cards[card_number];
+		struct etp_interface *interface =
+					&card->interface[interface_number];
+		struct mutex *mutex = &interface->mutex;
+		mutex_lock(mutex); /* Protect list and memory integrity. */
+		hlist_del_rcu(&file->node);
+		if (file->length < E1_TIMESLOTS_PER_INTERFACE) {
+			interface->g704--;
+			if (file->slot == 0)
+				interface->timeslot0--;
+		}
+		/* No more open files for interface? */
+		if (hlist_empty(&interface->file)) {
+			const struct etp_callback_struct callback = {
+				NULL, NULL, NULL,
+				card_number, interface_number, 1 };
+			etp_register_callbacks(&callback);
+		}
+		mutex_unlock(mutex);
+		synchronize_rcu();
+	}
+	kfree(file);
+	module_put(THIS_MODULE);
+	return 0;
+}
+
+static inline unsigned read_frame(loff_t *ppos)
+{
+	return (*ppos >> 5) & (FRAMES_IN_SLOT - 1);
+}
+
+static inline unsigned read_timeslot(loff_t *ppos)
+{
+	return *ppos & (E1_TIMESLOTS_PER_INTERFACE - 1);
+}
+
+/* Reads data from ETP DMA reception buffer to user space. */
+static ssize_t
+etp_read(struct file *file_p, char __user *buf, size_t length, loff_t *ppos)
+{
+	struct etp_file *file = file_p->private_data;
+	const unsigned device = file->card;
+	const unsigned interface_number = file->interface;
+	const struct slot_struct *rx, *slot;
+	ssize_t read = 0;
+	unsigned reading, reading_frame, reading_slot, rx_slots, beyond;
+	unsigned starting;
+	struct etp_card *card = &cards[device];
+	struct etp_interface *interface = &card->interface[interface_number];
+	struct etp_device_private *dp = get_dev_priv(device);
+	struct etp_interface_private *ip =
+		&dp->interface_privates[interface_number];
+	const struct etp_channel_private *channel = &ip->ch_priv;
+	struct rw_semaphore *semaphore = &ip->semaphore;
+	down_write(semaphore);
+	rx = channel->rx;
+	if (unlikely(rx == NULL)) {
+		up_write(semaphore);
+		return -ENXIO;
+	}
+	rx_slots = channel->rx_slots;
+	reading = read_slot(ppos);
+	reading *= reading < rx_slots;
+	slot = rx + reading;
+	if (ip->if_mode == IF_MODE_STREAM && interface->g704)
+		check_frame(card, dp, device, interface_number, interface,
+			    slot, channel);
+	reading_frame = read_frame(ppos);
+	reading_slot = read_timeslot(ppos);
+	beyond = file->beyond;
+	starting = file->slot;
+	while (length) {
+		const void *source;
+		unsigned slots;
+		if (unlikely(reading == interface->receiving &&
+			     !reading_frame)) {
+			if (file->flow & ETP_STREAM_OVERFLOW) {
+				clear_bit(ETP_STREAM_OVERFLOW_BIT, &file->flow);
+				goto NEXT;
+			}
+			if (read == 0)
+				read = -EAGAIN;
+			goto SAVE;
+		}
+		source = slot->e1_frame[reading_frame].e1_timeslot +
+			 reading_slot;
+		prefetch(source);
+		slots = beyond - reading_slot;
+		slots = min(length, slots);
+		if (unlikely(__copy_to_user(buf + read, source, slots))) {
+			read = -EFAULT;
+			goto SAVE;
+		}
+		read += slots;
+		length -= slots;
+		reading_slot += slots;
+		if (likely(reading_slot >= beyond)) {
+			reading_slot = starting;
+			reading_frame++;
+			if (reading_frame == FRAMES_IN_SLOT) {
+				reading_frame = 0;
+NEXT:				reading++;
+				reading *= reading < rx_slots;
+				slot = rx + reading;
+			}
+		}
+	}
+SAVE:	save_read(ppos, reading, reading_frame, reading_slot);
+	up_write(semaphore);
+	return read;
+}
+
+static inline unsigned write_frame(loff_t *ppos)
+{
+	return (*ppos >> 37) & (FRAMES_IN_SLOT - 1);
+}
+
+static inline unsigned write_timeslot(loff_t *ppos)
+{
+	return (*ppos >> 32) & (E1_TIMESLOTS_PER_INTERFACE - 1);
+}
+
+/* Writes data to ETP DMA transmission buffer from user space. */
+static ssize_t
+etp_write(struct file *file_p, const char __user *buf, size_t count,
+	  loff_t *ppos)
+{
+	struct etp_file *file = file_p->private_data;
+	const unsigned device = file->card;
+	const unsigned interface_number = file->interface;
+	struct slot_struct *slot, *write;
+	ssize_t written = 0;
+	struct etp_interface *interface = &cards[device].interface
+							 [interface_number];
+	const struct etp_channel_private *channel =
+		&get_dev_priv(device)->interface_privates[interface_number].
+		ch_priv;
+	unsigned writing;
+	unsigned writing_frame;
+	unsigned tx_slots;
+	unsigned writing_slot;
+	unsigned beyond;
+	unsigned starting;
+	struct rw_semaphore *semaphore = &this_if_priv(channel)->semaphore;
+	down_write(semaphore);
+	slot = channel->tx;
+	if (unlikely(slot == NULL)) {
+		up_write(semaphore);
+		return -ENXIO;
+	}
+	tx_slots = channel->tx_slots;
+	writing = write_slot(ppos);
+	writing *= writing < tx_slots;
+	write = slot + writing;
+	writing_frame = write_frame(ppos);
+	writing_slot = write_timeslot(ppos);
+	beyond = file->beyond;
+	starting = file->slot;
+	while (count) {
+		unsigned length;
+		if (unlikely(writing == interface->transmitting &&
+			     !writing_frame)) {
+			if (file->flow & ETP_STREAM_UNDERFLOW) {
+				clear_bit(ETP_STREAM_UNDERFLOW_BIT,
+					  &file->flow);
+				goto NEXT;
+			}
+			if (!written)
+				written = -EAGAIN;
+			goto SAVE;
+		}
+		length = beyond - writing_slot;
+		length = min(count, length);
+		if (unlikely(__copy_from_user
+			(write->e1_frame[writing_frame].e1_timeslot +
+			 writing_slot, buf + written, length))) {
+			written = -EFAULT;
+			goto SAVE;
+		}
+		written += length;
+		count -= length;
+		writing_slot += length;
+		if (likely(writing_slot >= beyond)) {
+			writing_slot = starting;
+			writing_frame++;
+			if (writing_frame == FRAMES_IN_SLOT) {
+				writing_frame = 0;
+NEXT:				writing++;
+				writing *= writing < tx_slots;
+				write = slot + writing;
+			}
+		}
+	}
+SAVE:	save_write(ppos, writing, writing_frame, writing_slot);
+	up_write(semaphore);
+	flush_write_buffers();
+	return written;
+}
+
+/* Handles select system call. */
+static unsigned int etp_poll(struct file *file, poll_table *wait)
+{
+	struct etp_file *etp = file->private_data;
+	struct etp_interface *interface =
+		&cards[etp->card].interface[etp->interface];
+	loff_t *position = etp->position;
+	unsigned long flow;
+	poll_wait(file, &interface->queue, wait);
+	flow = etp->flow;
+	return
+	    ((interface->receiving != read_slot(position) ||
+	      (flow & ETP_STREAM_OVERFLOW)) * (POLLIN | POLLRDNORM)) |
+	    ((interface->transmitting != write_slot(position) ||
+	      (flow & ETP_STREAM_UNDERFLOW)) * (POLLOUT | POLLWRNORM))
+	    | ((atomic_read(&etp->exceptions) != ETP_STREAM_CLEAR) * POLLPRI);
+}
+
+/* Sets the starting slot and slot range length of the opened file. */
+static inline int etp_slot(struct file *file_p, unsigned long arg)
+{
+	struct etp_file *file = file_p->private_data;
+	const unsigned char card_number = file->card;
+	struct etp_card *card = &cards[card_number];
+	struct etp_device_private *device = get_dev_priv(card_number);
+	const unsigned char interface_number = file->interface;
+	struct etp_interface *my_interface = &card->interface[interface_number];
+	const unsigned char slot = file->slot;
+	const unsigned char oldlength = file->length;
+	struct etp_interface_private *interface =
+				&device->interface_privates[interface_number];
+	int error;
+	const struct etp_callback_struct callback = {
+		notify_reception, notify_transmission,
+		etp_idt_int_callback, card_number, interface_number, 1 };
+	struct mutex *mutex = &my_interface->mutex;
+	struct rw_semaphore *semaphore = &interface->semaphore;
+	mutex_lock(mutex);
+	down_write(semaphore);
+	file->slot = arg & (E1_TIMESLOTS_PER_INTERFACE - 1);
+	file->length = arg >> 5;
+	if (unlikely(!file->length ||
+		     file->length > E1_TIMESLOTS_PER_INTERFACE))
+		file->length = E1_TIMESLOTS_PER_INTERFACE;
+	file->beyond = file->slot + file->length;
+	if (unlikely(file->beyond > E1_TIMESLOTS_PER_INTERFACE)) {
+		file->beyond = E1_TIMESLOTS_PER_INTERFACE;
+		file->length = E1_TIMESLOTS_PER_INTERFACE - file->slot;
+	}
+	save_write(&file_p->f_pos, write_slot(&file_p->f_pos),
+		   write_frame(&file_p->f_pos), file->slot);
+	save_read(&file_p->f_pos, read_slot(&file_p->f_pos),
+		  read_frame(&file_p->f_pos), file->slot);
+	switch (interface->if_mode) {
+	case IF_MODE_STREAM:
+		if (likely(file->length < E1_TIMESLOTS_PER_INTERFACE)) {
+			my_interface->g704 +=
+				oldlength == E1_TIMESLOTS_PER_INTERFACE;
+			my_interface->timeslot0 +=
+				(file->slot == 0) -
+				(slot == 0 &&
+				 oldlength < E1_TIMESLOTS_PER_INTERFACE);
+			rtnl_lock();
+			error = etp_frame(card_number, interface_number, 1);
+			rtnl_unlock();
+			if (unlikely(error))
+				dev_warn(&interface->ch_priv.this_netdev->dev,
+					 "Failed to set to timeslot mode: %d\n",
+					 error);
+			goto TIMESLOT;
+		} else if (unlikely(oldlength < E1_TIMESLOTS_PER_INTERFACE)) {
+			my_interface->g704--;
+			my_interface->timeslot0 -= slot == 0;
+		}
+		break;
+	case IF_MODE_TIMESLOT:
+		{
+			unsigned g704 =
+				file->length < E1_TIMESLOTS_PER_INTERFACE;
+			unsigned g704_old = oldlength <
+					    E1_TIMESLOTS_PER_INTERFACE;
+			error = etp_write_idt_register_if_lock(card_number,
+							E1_TRNCVR_E1_MODE_REG,
+							interface_number, 0u);
+			if (unlikely(error))
+				dev_warn(&interface->ch_priv.this_netdev->dev,
+					 "Failed to disable multi-frame: %d\n",
+					 error);
+			my_interface->g704 += g704 - g704_old;
+			if (likely(file->slot == 0u)) {
+				my_interface->timeslot0 += g704 && (!g704_old
+								    || slot !=
+								       0u);
+TIMESLOT:			queue_work(device->queue, &card->work.work);
+			} else {
+				my_interface->timeslot0 -=
+					g704_old && slot == 0u;
+			}
+		}
+	}
+	if (hlist_unhashed(&file->node))
+		hlist_add_head_rcu(&file->node, &my_interface->file);
+	up_write(semaphore);
+	error = etp_register_callbacks(&callback);
+	mutex_unlock(mutex);
+	return error;
+}
+
+static uint32_t etp_fill(const struct etp_file *file,
+			 unsigned short tx_slots, unsigned char length,
+			 unsigned char card, unsigned char interface_number)
+{
+	const struct etp_interface *interface =
+				&cards[card].interface[interface_number];
+	uint32_t slots = (uint32_t)write_slot(file->position) -
+			 (uint32_t)interface->transmitting;
+	if (slots >= MAX_SLOTS) /* uint32_t underflow */
+		slots += tx_slots;
+	return slots * FRAMES_IN_SLOT * length;
+}
+
+/* Handles ioctl system calls. */
+static int
+etp_ioctl(struct inode *inode,
+	  struct file *file_p, unsigned int cmd, unsigned long arg)
+{
+	switch (cmd) {
+	case ETP_STREAM_GET_TX_BUFFER_FILL:
+		{
+			const struct etp_file *file = file_p->private_data;
+			unsigned char card = file->card;
+			unsigned char interface = file->interface;
+			return etp_fill(file, get_dev_priv(card)->
+						interface_privates[interface].
+						ch_priv.tx_slots, file->length,
+					card, interface);
+		}
+	case ETP_STREAM_GET_CLEAR_EXCEPTIONS:
+		{
+			struct etp_file *file = file_p->private_data;
+			return atomic_xchg(&file->exceptions, ETP_STREAM_CLEAR);
+		}
+	case ETP_STREAM_SLOT:
+		return etp_slot(file_p, arg);
+	case ETP_STREAM_SENSITIVITY:
+/* Sets the sensitivity -10 dB (short haul) or -44 dB (long haul) */
+		{
+			unsigned data = arg == (unsigned long)-10 ? 0x15 : 0x54;
+			struct etp_file *file = file_p->private_data;
+			return etp_write_idt_register_if_lock(
+							file->card,
+							E1_TRNCVR_RX_CONF1_REG,
+							file->interface,
+							data);
+		}
+	case ETP_STREAM_SENSITIVITY_GET:
+/* Returns the value of the IDT register Receive Configuration 1 */
+		{
+			struct etp_file *file = file_p->private_data;
+			return etp_read_idt_register_if_lock(file->card,
+							 E1_TRNCVR_RX_CONF1_REG,
+							 file->interface);
+		}
+	case ETP_STREAM_BUFFER_SIZE_GET:
+		{
+			struct etp_file *interface = file_p->private_data;
+			return get_dev_priv(interface->card)->
+				interface_privates[interface->interface].
+				ch_priv.tx_slots;
+		}
+	default:
+		return -ENOTTY;
+	}
+}
+
+static inline loff_t write_position(loff_t offset)
+{
+	return offset >> 32;
+}
+
+static loff_t etp_seek(struct file *file_p, loff_t loffset, int whence)
+{
+	struct etp_file *file = file_p->private_data;
+	const unsigned char length = file->length;
+	int32_t offset = loffset;
+	const unsigned char card = file->card, interface = file->interface;
+	int32_t slot_offset, frame_offset, slot, frame, writing;
+	unsigned short slots;
+	struct etp_interface_private *ip =
+			&get_dev_priv(card)->interface_privates[interface];
+	struct rw_semaphore *semaphore = &ip->semaphore;
+	down_write(semaphore);
+	slots = ip->ch_priv.tx_slots;
+	if (unlikely(!slots)) {
+		up_write(semaphore);
+		return -ESPIPE;
+	}
+	switch (whence) {
+	case SEEK_CUR:
+	{
+		int32_t fill = -etp_fill(file, slots, length, card, interface);
+		if (unlikely(offset < fill)) {
+			goto INVALID;
+		} else if (unlikely(offset == fill)) {
+			if (!write_frame(file->position))
+				set_bit(ETP_STREAM_UNDERFLOW_BIT, &file->flow);
+		} else {
+			int32_t limit = (int32_t)slots * FRAMES_IN_SLOT *
+					(int32_t)length + fill;
+			if (unlikely(offset > limit)) {
+				if (file->flow & ETP_STREAM_UNDERFLOW) {
+					clear_bit(ETP_STREAM_UNDERFLOW_BIT,
+						  &file->flow);
+				} else {
+INVALID:				up_write(semaphore);
+					return -EINVAL;
+				}
+			}
+		}
+	}
+CUR:
+	slot_offset = offset % (int32_t)length;
+	frame_offset = offset / (int32_t)length;
+	slot = (int32_t)write_timeslot(&file_p->f_pos) + slot_offset;
+	frame = (int32_t)write_frame(&file_p->f_pos) + frame_offset;
+	if (slot < 0) {
+		slot += length;
+		frame--;
+	} else if (slot >= file->beyond) {
+		slot -= length;
+		frame++;
+	}
+	writing = (int32_t)write_slot(&file_p->f_pos) + frame / FRAMES_IN_SLOT;
+	frame %= FRAMES_IN_SLOT;
+	if (frame < 0) {
+		frame += FRAMES_IN_SLOT;
+		writing--;
+	}
+	writing %= slots;
+	if (writing < 0)
+		writing += slots;
+	save_write(&file_p->f_pos, writing, frame, slot);
+	loffset = write_position(file_p->f_pos);
+	break;
+	case SEEK_END:
+	writing = cards[card].interface[interface].transmitting;
+	frame = 0u;
+	slot = file->slot;
+	save_write(&file_p->f_pos, writing, frame, slot);
+	goto CUR;
+	default:
+	file_p->f_pos = (file_p->f_pos & 0xffffffffull) | (loffset << 32);
+	loffset = write_position(file_p->f_pos);
+	}
+	up_write(semaphore);
+	return loffset;
+}
+
+static struct file_operations etp_char_fops = {
+	.read		= etp_read,
+	.write		= etp_write,
+	.open		= etp_open,
+	.release	= etp_close,
+	.ioctl		= etp_ioctl,
+	.poll		= etp_poll,
+	.llseek		= etp_seek
+};
+
+/* Initializes this kernel module. */
+static int __init etp_init(void)
+{
+	unsigned index;
+	int error;
+	number = etp_number_devices();
+	if (unlikely(number == 0u))
+		return -ENXIO;
+	cards = kzalloc(sizeof(struct etp_card) * number, GFP_KERNEL);
+	if (unlikely(cards == NULL))
+		return -ENOMEM;
+	index = number - 1u;
+	do {
+		struct etp_card *card = cards + index;
+		unsigned interface;
+		card->number = index;
+		interface = INTERFACES_PER_DEVICE - 1;
+		do {
+			struct etp_interface *my_interface =
+						card->interface + interface;
+			INIT_HLIST_HEAD(&my_interface->file);
+			init_waitqueue_head(&my_interface->queue);
+			mutex_init(&my_interface->mutex);
+		} while (interface--);
+		INIT_DELAYED_WORK(&card->work, check_alarm);
+	} while (index--);
+
+	error = alloc_chrdev_region(&from, 0u, 256u * INTERFACES_PER_DEVICE,
+				    THIS_MODULE->name);
+	if (unlikely(error)) {
+FREE:		kfree(cards);
+		return error;
+	}
+	cdev_init(&cdev, &etp_char_fops);
+	error = cdev_add(&cdev, from, DEVICES);
+	if (unlikely(error)) {
+		unregister_chrdev_region(from, DEVICES);
+		goto FREE;
+	}
+	return 0;
+}
+
+module_init(etp_init);
+module_exit(etp_cleanup);
--- linux-2.6.27-rc6/drivers/net/wan/etp_main.c	1970-01-01
02:00:00.000000000 +0200
+++ linux-2.6.27-rc6-next-20080919/drivers/net/wan/etp_main.c	2008-10-02
08:39:00.606821735 +0300
@@ -0,0 +1,2418 @@
+/* etp_main.c */
+
+/*
+	Copyright (C) 2006 Jouni Kujala, Flexibilis Oy.
+
+	This program is free software; you can redistribute it and/or
+	modify it under the terms of the GNU General Public License
+	as published by the Free Software Foundation; either version 2
+	of the License, or (at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	All the drivers derived from or based on this code must retain
+	the copyright notice.
+*/
+
+#include <linux/mm.h>
+#include <linux/random.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
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
+#include <linux/fs.h>
+#include <linux/uaccess.h>
+#include <linux/rwsem.h>
+#include <linux/io.h>
+#include <linux/delay.h>
+#include <linux/version.h>
+#include <linux/timer.h>
+#include <net/checksum.h>	/* ip_fast_csum */
+#include <linux/rtnetlink.h>
+
+#include "etp.h"
+#include "etp_idt.h"
+
+MODULE_VERSION("0.7.67");
+
+/* PCI IO size */
+#define ETP_SIZE 0x20000
+
+enum { ETP_MRU = 1800u, ETP_DMA = ETP_MRU + 2u };
+
+enum { ETP_ON = 0, ETP_OFF = 1 };
+
+enum { ETP_INTERRUPT_NONE = 0, ETP_INTERRUPT = 1 };
+
+static struct pci_device_id etp_pci_tbl[] __devinitdata = {
+	{0x10EE, PCI_DEVICE_ID_ETP_ORIGINAL, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	/* etp-104 (1a2b:000a) */
+	{0x1A2B, PCI_DEVICE_ID_ETP_104, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0,}
+};
+
+MODULE_DESCRIPTION("ETP");
+MODULE_AUTHOR("Jouni Kujala");
+MODULE_LICENSE("GPL");
+MODULE_DEVICE_TABLE(pci, etp_pci_tbl);
+
+/* Global variables (common to whole driver, all the devices) */
+static int major; /* Character device major number */
+struct etp_device_private **etp_devices;
+EXPORT_SYMBOL(etp_devices);
+unsigned int etp_number; /* The number of the devices found. */
+EXPORT_SYMBOL(etp_number);
+static const char etp_netdev_name[] = "e1_xx";
+
+/* Functions */
+
+static int etp_char_open(struct inode *inode, struct file *filp);
+static int etp_char_ioctl(struct inode *inode, struct file *filp,
+			  unsigned int cmd, unsigned long arg);
+
+static void etp_enable_interrupt(struct etp_device_private *dp);
+
+static struct file_operations etp_char_fops = {
+	.owner		= THIS_MODULE,
+	.ioctl		= etp_char_ioctl,
+	.open		= etp_char_open
+};
+
+static inline void etp_unregister_char_device(void)
+{
+	unregister_chrdev(major, THIS_MODULE->name);
+}
+
+static inline int etp_register_char_device(void)
+{
+	int error = register_chrdev(0u /* dynamic */, THIS_MODULE->name,
+				    &etp_char_fops);
+	if (unlikely(error < 0)) {
+		printk(KERN_WARNING
+		       "%s: unable to register char device\n",
+		       THIS_MODULE->name);
+	}
+	return error;
+}
+
+static irqreturn_t etp_interrupt(int irq, void *device);
+static int etp_change_mtu(struct net_device *dev, int mtu);
+static void etp_netdev_tx_timeout(struct net_device *dev);
+static int etp_netdev_open(struct net_device *dev);
+static int etp_netdev_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static int etp_netdev_close(struct net_device *dev);
+static void etp_netdev_close_down(struct net_device *dev,
+				  struct etp_channel_private *cp,
+				  struct etp_interface_private *ip,
+				  struct etp_device_private *dp);
+static void status_work(struct work_struct *work);
+static void led_work(struct work_struct *work);
+static int etp_tx_on_down(struct etp_interface_private *ip);
+static int etp_rx_on_down(struct etp_interface_private *ip);
+static int etp_rx_off_down(struct etp_interface_private *ip);
+static int etp_tx_off_down(struct etp_interface_private *ip);
+static int etp_if_close_down(unsigned interface,
+			     struct etp_device_private *dp,
+			     struct etp_interface_private *ip);
+static void rx_task_stream_timeslot(unsigned long channel);
+
+static unsigned if_to_led(unsigned interface)
+{
+	if (interface < 4u)
+		return interface << 1;
+	else
+		return ((interface - 4u) << 1) + 1u;
+}
+
+static void set_led(uint32_t new_value, struct etp_interface_private *ip,
+		    unsigned interface, struct etp_device_private *dp)
+{
+	uint8_t __iomem *ioaddr = dp->ioaddr;
+	/* The idea here is that we do not need to read the old value from
+	   device because we know what we have written there. */
+	uint32_t old = dp->led_register_value;
+	uint32_t temp = old;	/* LED value temp */
+	/* reset bits */
+	temp &= ~(ALL_LED_BITS << LEDx_SHIFT(if_to_led(interface)));
+	/* write new value */
+	temp |= new_value << LEDx_SHIFT(if_to_led(interface));
+	/* write bits */
+	if (old != temp) {
+		writel(temp, ioaddr + REG_LED_CTRL);
+		if (new_value) {
+			cancel_delayed_work(&dp->led);
+			queue_delayed_work(dp->queue, &dp->led, 5ul * HZ);
+		}
+	}
+	dp->led_register_value = temp;
+}
+
+unsigned int get_led(const struct etp_interface_private *ip)
+{
+	struct etp_device_private *dp = this_dev_priv(ip);
+	unsigned int interface = interface_number(ip);
+	return (dp->led_register_value >> LEDx_SHIFT(if_to_led(interface))) &
+	       ALL_LED_BITS;
+}
+
+static int __devinit etp_init_device(struct pci_dev *pdev,
+				     const struct pci_device_id *ent);
+
+#ifdef CONFIG_PM
+static int etp_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct etp_device_private *dp = pci_get_drvdata(pdev);
+	unsigned channel;
+	struct mutex *device_mutex = &dp->mutex;
+	cancel_delayed_work(&dp->led);
+	etp_down(dp);
+	channel = 0u;
+	do {
+		struct etp_interface_private *ip = dp->interface_privates +
+						   channel;
+		const unsigned mode = ip->if_mode;
+		struct etp_channel_private *cp = &ip->ch_priv;
+		if (mode >= IF_MODE_TIMESLOT) {
+			rtnl_lock();
+			etp_if_close_down(channel, dp, ip);
+			rtnl_unlock();
+		} else if (mode != IF_MODE_CLOSED) {
+			struct net_device *dev = cp->this_netdev;
+			if (dev) {
+				netif_device_detach(dev);
+				rtnl_lock();
+				etp_netdev_close_down(dev, cp, ip, dp);
+				rtnl_unlock();
+			}
+		}
+		rtnl_lock();
+		ip->if_mode = mode;
+		rtnl_unlock();
+	} while (channel++ < INTERFACES_PER_DEVICE - 1u);
+	mutex_lock(device_mutex);
+	atomic_set(&dp->reset, ETP_OFF);
+	mutex_unlock(device_mutex);
+	etp_up(dp);
+	flush_workqueue(dp->queue);
+	/* Set E1 and access done interrupts disabled. */
+	writel(dp->reg_int_mask2 = 0u, dp->ioaddr + REG_INT_MASK2);
+	/* Disable IRQ. */
+	free_irq(pdev->irq, dp);
+	pci_save_state(pdev);
+	/* Disable IO/bus master/IRQ router. */
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	return 0;
+}
+
+static int etp_resume(struct pci_dev *pdev)
+{
+	struct etp_device_private *dp = pci_get_drvdata(pdev);
+	unsigned channel;
+	int error;
+	unsigned irq;
+	struct etp_interface_private *interfaces;
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	/* device's irq possibly is changed, driver should take care */
+	error = pci_enable_device(pdev);
+	if (unlikely(error))
+		return error;
+	pci_set_master(pdev);
+	/* driver specific operations */
+	msleep(2u); /* IDT chip reset timeout. */
+	irq = pdev->irq;
+	error = request_irq(irq, &etp_interrupt, IRQF_SHARED, THIS_MODULE->name,
+			    dp);
+	if (unlikely(error))
+		return error;
+	atomic_set(&dp->reset, ETP_ON);
+	/* Set default settings to E1 chip (IDT). */
+	idt_init_default(dp);
+	etp_enable_interrupt(dp);
+	channel = 0u;
+	interfaces = dp->interface_privates;
+	do {
+		struct etp_interface_private *ip = interfaces + channel;
+		struct etp_channel_private *cp = &ip->ch_priv;
+		struct net_device *dev = cp->this_netdev;
+		if (likely(dev)) {
+			dev->irq = irq;
+			if (netif_running(dev)) {
+				rtnl_lock();
+				etp_netdev_open(dev);
+				rtnl_unlock();
+			}
+			netif_device_attach(dev);
+		}
+	} while (channel++ < INTERFACES_PER_DEVICE - 1u);
+	return error;
+}
+#endif
+
+static void __devexit etp_remove_device(struct pci_dev *pdev);
+
+static struct pci_driver etp_driver = {
+	.name		= THIS_MODULE->name,
+	.id_table	= etp_pci_tbl,
+	.probe		= etp_init_device,
+	.remove		= etp_remove_device,
+#ifdef CONFIG_PM
+	.suspend	= etp_suspend,
+	.resume		= etp_resume
+#endif
+};
+
+static int __init etp_init(void)
+{
+	int ret = pci_register_driver(&etp_driver);
+	if (unlikely(ret))
+		return ret;
+	major = etp_register_char_device();
+	if (unlikely(major < 0)) {
+		pci_unregister_driver(&etp_driver);
+		return major;
+	}
+	return ret;
+}
+
+static void __exit etp_cleanup(void)
+{
+	unsigned device;
+	pci_unregister_driver(&etp_driver);
+	etp_unregister_char_device();
+	for (device = 0u; device < etp_number; device++) {
+		struct etp_device_private *card = etp_devices[device];
+		struct workqueue_struct *queue = card->queue;
+		if (queue)
+			destroy_workqueue(queue);
+		kfree(card);
+	}
+	kfree(etp_devices);
+}
+
+module_init(etp_init);
+module_exit(etp_cleanup);
+
+static int etp_poll(struct napi_struct *napi, int weight);
+
+/**
+ * Function that does nothing, the reason for this function exists is that
+ * we have to have something to give as parameter to alloc_netdev.
+ **/
+static void etp_null(struct net_device *dev)
+{
+}
+
+/* Callback functions that do nothing: */
+static void rx_null_callback(unsigned device, unsigned interface,
+			     unsigned can_be, const struct slot_struct *rx)
+{
+}
+
+static void tx_null_callback(unsigned device, unsigned interface,
+			     unsigned can_be, struct slot_struct *tx)
+{
+}
+
+static int etp_init_netdev(struct etp_channel_private *cp, int hdlc_mode)
+{
+	struct net_device *netdev;
+	unsigned int interface = CH_TO_IF(cp->channel_number);
+	unsigned int device = cp->device_number;
+	struct etp_device_private *dp = this_device_priv(cp);
+
+	if (hdlc_mode <= HDLC_MODE_CISCO_OVER_G704) {
+		netdev = alloc_netdev(sizeof(struct etp_netdev_priv),
+				      etp_netdev_name, etp_null);
+		if (unlikely(!netdev))
+			goto NO_MEMORY;
+		((struct etp_netdev_priv *)(netdev_priv(netdev)))->cp = cp;
+		/* General purpose pointer (used by SPPP) */
+		((struct etp_netdev_priv *)(netdev_priv(netdev)))->if_ptr =
+			&(cp->pppdevice);
+		cp->pppdevice.dev = netdev;
+	} else {
+		netdev = alloc_etherdev(sizeof(struct etp_netdev_priv));
+		if (unlikely(!netdev)) {
+NO_MEMORY:		dev_err(&dp->pci_dev->dev,
+				"cannot allocate net device\n");
+			return -ENOMEM;
+		}
+		((struct etp_netdev_priv *)(netdev_priv(netdev)))->cp = cp;
+		cp->pppdevice.dev = NULL;
+
+		/* name := xxx00..xxxnn */
+		memcpy(netdev->name, etp_netdev_name, 6);
+
+		ether_setup(netdev);
+		random_ether_addr(netdev->dev_addr);
+	}
+	netdev->name[4] = /* number -> ascii */
+		((device * INTERFACES_PER_DEVICE + interface) % 10) + 0x30;
+	netdev->name[3] = /* number -> ascii */
+		((device * INTERFACES_PER_DEVICE + interface) / 10) + 0x30;
+	netdev->base_addr = (unsigned long)dp->ioaddr;
+	netdev->irq = dp->pci_dev->irq;
+
+	/* The FEPCI specific entries in the network device structure. */
+	netdev->open = &etp_netdev_open;
+	netdev->hard_start_xmit = &etp_netdev_start_xmit;
+	netdev->stop = &etp_netdev_close;
+	netdev->change_mtu = &etp_change_mtu;
+	netdev->tx_timeout = etp_netdev_tx_timeout;
+	netdev->watchdog_timeo = TX_TIMEOUT;
+	netif_napi_add(netdev, &cp->napi, etp_poll, DESCRIPTORS_PER_CHANNEL);
+	cp->hdlc_mode = hdlc_mode;
+
+	switch (hdlc_mode) {
+	case HDLC_MODE_CISCO_OVER_G703:
+	case HDLC_MODE_CISCO_OVER_G704:
+		sppp_attach(&cp->pppdevice);
+		break;
+	case HDLC_MODE_RETINA_OVER_G703_POINTOPOINT:
+	case HDLC_MODE_RETINA_OVER_G704_POINTOPOINT:
+		netdev->flags |= (IFF_POINTOPOINT); /* Point-to-point link. */
+		netdev->flags &= ~(IFF_BROADCAST | IFF_MULTICAST);
+	}
+	SET_NETDEV_DEV(netdev, &dp->pci_dev->dev);
+	cp->this_netdev = netdev;
+	return register_netdev(netdev);
+}
+
+static void etp_free_netdev(struct etp_channel_private *cp)
+{
+	struct net_device *device = cp->this_netdev;
+	if (unlikely(device == NULL))
+		return;
+	cp->this_netdev = NULL;
+	if (device->reg_state == NETREG_REGISTERED)
+		unregister_netdev(device);
+	if (cp->hdlc_mode <= HDLC_MODE_CISCO_OVER_G704)
+		sppp_detach(device);	/* Crashes if not attached. */
+	synchronize_irq(device->irq);
+	free_netdev(device);
+	cp->pppdevice.dev = NULL;
+}
+
+static void etp_init_channel(struct etp_channel_private *cp,
+			     struct etp_interface_private *ip,
+			     uint8_t __iomem *ioaddr)
+{
+	unsigned int descriptor;
+	unsigned int interface = interface_number(ip);
+
+	cp->reg_ch_rxctrl = (uint32_t __iomem *)
+			    (ioaddr + REG_RXCTRL_CH(IF_TO_CH(interface)));
+	cp->reg_ch_txctrl = (uint32_t __iomem *)
+			    (ioaddr + REG_TXCTRL_CH(IF_TO_CH(interface)));
+	for (descriptor = 0u; descriptor < DESCRIPTORS_PER_CHANNEL;
+	     descriptor++) {
+		struct rx_descriptor *rx = &cp->rx_descriptor[descriptor];
+		struct tx_descriptor *tx = &cp->tx_descriptor[descriptor];
+		/* Initialize descriptor pointers. */
+		rx->descriptor = (struct rxdesc __iomem *)
+				 (ioaddr + REG_RXDESCxA_CHy(descriptor,
+							    IF_TO_CH
+								(interface)));
+		tx->descriptor = (struct txdesc __iomem *)
+				 (ioaddr + REG_TXDESCxA_CHy(descriptor,
+							    IF_TO_CH
+								(interface)));
+		rx->skb = NULL;
+		tx->skb = NULL;
+	}
+
+	if (unlikely(etp_init_netdev(cp,	/* HDLC mode to default */
+				     HDLC_MODE_RETINA_OVER_G703_POINTOPOINT)))
+		etp_free_netdev(cp);
+}
+
+/* Fine tune local clock frequency. */
+static void etp_nco_adjust_down(struct etp_device_private *dp,
+				uint32_t nco_addend_value)
+{
+	writel(nco_addend_value, dp->ioaddr + REG_NCO_CTRL);
+}
+
+/* Set output clock source.*/
+static int etp_ext_output_clock_down(struct etp_device_private *dp,
+				     uint32_t clock_source)
+{
+	switch (clock_source) {
+	case CLOCK_SELECT_E1_GEN:	/* for testing only */
+	case CLOCK_SOURCE_NCO:
+	case CLOCK_SOURCE_DALLAS:
+	case CLOCK_SOURCE_RJ:
+	case CLOCK_SOURCE_LVDS:
+		writel((clock_source << OUTPUT_CLK_SELECT_SHIFT) |
+		       (~OUTPUT_CLK_SELECT_MASK &
+			readl_relaxed(dp->ioaddr + REG_GENERAL)),
+		       dp->ioaddr + REG_GENERAL);
+		return 0;
+	case CLOCK_SOURCE_RX0:
+	case CLOCK_SOURCE_RX1:
+	case CLOCK_SOURCE_RX2:
+	case CLOCK_SOURCE_RX3:
+	case CLOCK_SOURCE_RX4:
+	case CLOCK_SOURCE_RX5:
+	case CLOCK_SOURCE_RX6:
+	case CLOCK_SOURCE_RX7:
+		{
+			int error = idt_set_ref_clk(dp,
+						    CLOCK_SELECT_RX_TO_CH
+						    (clock_source));
+			if (unlikely(error))
+				return error;
+			writel((CLOCK_SELECT_E1_A << OUTPUT_CLK_SELECT_SHIFT) |
+			       (~OUTPUT_CLK_SELECT_MASK &
+				readl_relaxed(dp->ioaddr + REG_GENERAL)),
+			       dp->ioaddr + REG_GENERAL);
+			return 0;
+		}
+	default:
+		dev_warn(&dp->pci_dev->dev, "Invalid clock source 0x%x\n",
+			 clock_source);
+		return -EINVAL;
+	}
+}
+
+/* Change settings of an interface. */
+static int etp_if_settings_down(struct etp_device_private *dp,
+				struct etp_interface_private *ip,
+				uint32_t clock_source,
+				unsigned hdlc_mode,
+				uint32_t hdlc_mode_g704_used_timeslots)
+{
+	struct etp_channel_private *cp = &ip->ch_priv;
+	struct net_device *netdev = cp->this_netdev;
+	if (cp->hdlc_mode != hdlc_mode) {
+		switch (ip->if_mode) {
+		case IF_MODE_CLOSED: {
+			int error;
+			etp_free_netdev(cp);
+			error = etp_init_netdev(cp, hdlc_mode);
+			if (unlikely(error)) {
+				etp_free_netdev(cp);
+				return error;
+			}
+			break;
+		}
+		default:
+			dev_warn(&netdev->dev,
+				 "Interface open: cannot change HDLC mode\n");
+			return -EBUSY;
+		}
+	}
+	switch (clock_source) {
+	case CLOCK_SOURCE_NCO:
+	case CLOCK_SOURCE_DALLAS:
+	case CLOCK_SOURCE_RJ:
+	case CLOCK_SOURCE_LVDS:
+	case CLOCK_SELECT_E1_GEN:	/* for testing only */
+	case CLOCK_SOURCE_RX0:
+	case CLOCK_SOURCE_RX1:
+	case CLOCK_SOURCE_RX2:
+	case CLOCK_SOURCE_RX3:
+	case CLOCK_SOURCE_RX4:
+	case CLOCK_SOURCE_RX5:
+	case CLOCK_SOURCE_RX6:
+	case CLOCK_SOURCE_RX7:
+		if (ip->tx_clock_source != clock_source) {
+			if (unlikely(ip->if_mode != IF_MODE_CLOSED)) {
+				dev_warn(&netdev->dev, "Interface open: "
+					 "cannot change clocking\n");
+				return -EBUSY;
+			}
+			ip->tx_clock_source = clock_source;
+		}
+		break;
+	default:
+		if (netdev)
+			dev_warn(&netdev->dev,
+				 "Invalid clock source 0x%x\n", clock_source);
+		return -EINVAL;
+	}
+	if (unlikely(hdlc_mode_g704_used_timeslots & 0x1)) { /* sync channel */
+		if (netdev)
+			dev_warn(&netdev->dev,
+				 "Cannot use channel 0 for data in G.704\n");
+		return -EINVAL;
+	}
+	cp->hdlc_mode_g704_used_timeslots = hdlc_mode_g704_used_timeslots;
+	if (ip->if_mode == IF_MODE_HDLC && (cp->hdlc_mode & 1u)) { /* G.704 */
+		int error;
+		if (likely(!atomic_read(&dp->reset))) {
+			writel(~hdlc_mode_g704_used_timeslots,
+			       ip->reg_if_rxctrl1);
+			writel(~hdlc_mode_g704_used_timeslots,
+			       ip->reg_if_txctrl1);
+			error = 0;
+		} else {
+			error = -ENXIO;
+		}
+		return error;
+	}
+	return 0;
+}
+
+void etp_down(struct etp_device_private *device)
+{
+	unsigned interface = 0u;
+	do {
+		down_write(&device->interface_privates[interface].semaphore);
+	} while (++interface <= INTERFACES_PER_DEVICE - 1);
+}
+
+void etp_up(struct etp_device_private *device)
+{
+	unsigned interface = 0u;
+	do {
+		up_write(&device->interface_privates[interface].semaphore);
+	} while (++interface <= INTERFACES_PER_DEVICE - 1);
+}
+
+static int __devinit etp_init_device(struct pci_dev *pdev,
+				     const struct pci_device_id *ent)
+{
+	int i;
+	uint8_t __iomem *ioaddr;
+	unsigned int device;
+	unsigned int interface;
+	struct etp_device_private *card, **cards, **old;
+	struct etp_interface_private *interfaces;
+
+	for (device = 0u; device < etp_number; device++) {
+		card = etp_devices[device];
+		if (card->pci_dev == NULL)
+			goto ENABLE;
+	}
+	if (unlikely(etp_number == 256u))
+		return -ENOMEM;
+	card = kzalloc(sizeof(struct etp_device_private), GFP_KERNEL);
+	if (unlikely(card == NULL))
+		return -ENOMEM;
+	cards = kmalloc((etp_number + 1u) * sizeof(struct etp_device_private *),
+			GFP_KERNEL);
+	if (unlikely(cards == NULL)) {
+		kfree(card);
+		return -ENOMEM;
+	}
+	for (i = 0u; i < device; i++)
+		cards[i] = etp_devices[i];
+	cards[i] = card;
+	interfaces = card->interface_privates;
+	interface = 0u;
+	card->number = device;
+	do {
+		struct etp_interface_private *ip = interfaces + interface;
+		struct etp_channel_private *cp = &ip->ch_priv;
+		init_rwsem(&ip->semaphore);
+		cp->channel_number = IF_TO_CH(interface);
+		cp->device_number = device;
+		cp->this_dev_priv = card;
+		atomic_set(&cp->owner, ETP_CALLBACKS);
+		cp->rx_callback = rx_null_callback;
+		cp->tx_callback = tx_null_callback;
+#if ETP_TIMER
+		init_timer(&cp->timer);
+		cp->timer.function = rx_task_stream_timeslot;
+		cp->timer.data = (unsigned long)cp;
+#endif
+	} while (interface++ < INTERFACES_PER_DEVICE - 1u);
+	mutex_init(&card->mutex);
+	mutex_init(&card->idt);
+	spin_lock_init(&card->lock0);
+	spin_lock_init(&card->lock2);
+	INIT_WORK(&card->status_work, status_work);
+	INIT_DELAYED_WORK(&card->led, led_work);
+	atomic_set(&card->reset, ETP_OFF);
+	old = etp_devices;
+	rcu_assign_pointer(etp_devices, cards);
+	synchronize_rcu();
+	kfree(old);
+	etp_number++;
+ENABLE:	i = pci_enable_device(pdev);
+	if (unlikely(i)) {
+		dev_warn(&pdev->dev, "enabling device failed\n");
+		return i;
+	}
+
+	pci_set_master(pdev);
+
+	i = pci_request_regions(pdev, THIS_MODULE->name);
+	if (unlikely(i)) {
+		dev_warn(&pdev->dev, "requesting regions failed\n");
+		pci_disable_device(pdev);
+		return i;
+	}
+
+	if (unlikely(pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
+		dev_warn(&pdev->dev, "no suitable DMA available\n");
+		i = -ENOMEM;
+		goto ERROR;
+	}
+
+	if (unlikely(!(pci_resource_flags(pdev, 0u) & IORESOURCE_MEM))) {
+		i = -ENXIO;
+		goto ERROR;
+	}
+	if (unlikely(pci_resource_len(pdev, 0u) < ETP_SIZE)) {
+		dev_warn(&pdev->dev, "resource length less than required %u\n",
+			 ETP_SIZE);
+		i = -ENXIO;
+		goto ERROR;
+	}
+	ioaddr = pci_iomap(pdev, 0u, ETP_SIZE);
+	if (unlikely(ioaddr == NULL)) {
+		dev_warn(&pdev->dev, "mapping failed\n");
+		i = -ENOMEM;
+		goto ERROR;
+	}
+	card->pci_dev = pdev;
+	card->ioaddr = ioaddr;
+
+	/* All LEDs on. */
+	writel(0x5555, ioaddr + REG_LED_CTRL);
+
+	/* E1 reset. */
+	writel(E1_RESET_ENABLE | readl_relaxed(ioaddr + REG_GENERAL),
+	       ioaddr + REG_GENERAL);
+	writel(~E1_RESET_ENABLE & readl_relaxed(ioaddr + REG_GENERAL),
+	       ioaddr + REG_GENERAL);
+	readl_relaxed(ioaddr + REG_GENERAL);	/* Wait for reset enable off. */
+	/* Wait after hardware reset: should be at least 2 milliseconds. */
+	msleep(2u);
+
+	pci_set_drvdata(pdev, card);
+
+	/* Enable LVDS. */
+	writel(LVDS_ENABLE | readl_relaxed(ioaddr + REG_GENERAL),
+	       ioaddr + REG_GENERAL);
+
+	interfaces = card->interface_privates;
+	for (interface = 0u; interface < INTERFACES_PER_DEVICE; interface++) {
+		struct etp_interface_private *ip = interfaces + interface;
+		struct etp_channel_private *cp = &ip->ch_priv;
+		/* Initialize register pointers. */
+		ip->reg_if_rxctrl = (uint32_t __iomem *)
+			(ioaddr + REG_RXCTRL_IF(interface));
+		ip->reg_if_txctrl = (uint32_t __iomem *)
+			(ioaddr + REG_TXCTRL_IF(interface));
+		ip->reg_if_rxctrl1 = (uint32_t __iomem *)
+				     (ioaddr + REG_RXCTRL1_IF(interface));
+		ip->reg_if_txctrl1 = (uint32_t __iomem *)
+				     (ioaddr + REG_TXCTRL1_IF(interface));
+
+		etp_init_channel(cp, ip, ioaddr);
+
+		/* Set interface clock setting to local (NCO) clock... */
+		etp_if_settings_down(card, ip, CLOCK_SOURCE_NCO, cp->hdlc_mode,
+				     0u /* no timeslots used in G.704 */);
+
+		/* ...but do not enable the clock output at the FPGA */
+		writel((CLOCK_SELECT_NO_CLOCK << TX_CLOCK_SELECT_SHIFT) |
+		       (~TX_CLOCK_SELECT_MASK &
+			readl_relaxed(ip->reg_if_txctrl)), ip->reg_if_txctrl);
+	}
+
+	/* all LEDs off */
+	writel(0x0, ioaddr + REG_LED_CTRL);
+
+	/* set NCO value */
+	etp_nco_adjust_down(card, NCO_ADDEND_DEFAULT_VALUE);
+
+	/* Set output clock to local. */
+	etp_ext_output_clock_down(card, CLOCK_SELECT_LOCAL);
+
+	if (likely(card->queue == NULL)) {
+		struct workqueue_struct *queue =
+			create_singlethread_workqueue(THIS_MODULE->name);
+		if (unlikely(queue == NULL)) {
+			i = -ENOMEM;
+			goto CLEANUP;
+		}
+		card->queue = queue;
+	}
+
+	etp_down(card);
+	atomic_set(&card->reset, ETP_ON);
+	/* Default settings to E1 chip (IDT). */
+	idt_init_default(card);
+
+	/* Set interface closed at IDT chip. */
+	for (interface = 0u; interface < INTERFACES_PER_DEVICE; interface++)
+		idt_close_if(card, interface);
+
+	/* Register interrupt handler. */
+	i = request_irq(pdev->irq, &etp_interrupt, IRQF_SHARED,
+			THIS_MODULE->name, card);
+	if (unlikely(i)) {
+		atomic_set(&card->reset, ETP_OFF);
+		etp_up(card);
+CLEANUP:
+		card->pci_dev = NULL;
+		iounmap(ioaddr);
+		goto ERROR;
+	}
+
+	etp_enable_interrupt(card);
+	etp_up(card);
+
+	return 0;
+
+ERROR:
+	pci_set_drvdata(pdev, NULL);
+	pci_disable_device(pdev);
+	pci_release_regions(pdev);
+	return i;
+}
+
+static void __devexit etp_remove_device(struct pci_dev *pdev)
+{
+	unsigned int i;
+	struct etp_device_private *dp = pci_get_drvdata(pdev);
+	struct etp_interface_private *interfaces;
+	uint8_t __iomem *ioaddr = dp->ioaddr;
+	const unsigned device = device_number(dp);
+
+	etp_down(dp);
+	mutex_lock(&dp->mutex);
+	atomic_set(&dp->reset, ETP_OFF);
+	mutex_unlock(&dp->mutex);
+	etp_up(dp);
+
+	interfaces = dp->interface_privates;
+	for (i = 0u; i < INTERFACES_PER_DEVICE; i++) {
+		struct etp_interface_private *ip = &(interfaces[i]);
+		switch (ip->if_mode) {
+		case IF_MODE_HDLC:
+			unregister_netdev(ip->ch_priv.this_netdev);
+			break;
+		case IF_MODE_TIMESLOT:
+		case IF_MODE_STREAM:
+			etp_if_close(device, i);
+		}
+	}
+
+	/* Switch E1 and access done interrupts off. */
+	writel(dp->reg_int_mask2 = 0u, ioaddr + REG_INT_MASK2);
+
+	free_irq(pdev->irq, dp);
+	for (i = 0u; i < INTERFACES_PER_DEVICE; i++) {
+		struct etp_interface_private *ip = &(interfaces[i]);
+		etp_free_netdev(&ip->ch_priv);
+	}
+
+	cancel_delayed_work(&dp->led);
+
+	/* Switch all LEDs off. */
+	writel(0x0, ioaddr + REG_LED_CTRL);
+
+	/* Leave E1 in reset, LVDS disable. */
+	writel(E1_RESET_ENABLE, ioaddr + REG_GENERAL);
+
+	iounmap(ioaddr);
+	dp->pci_dev = NULL;
+	pci_set_drvdata(pdev, NULL);
+
+	pci_disable_device(pdev);
+	pci_release_regions(pdev);
+}
+
+static int etp_char_open(struct inode *inode, struct file *filp)
+{
+	unsigned int minor = MINOR(inode->i_rdev);
+
+	/* If trying to access a device that has not been probed. */
+	if (unlikely(minor >= etp_number))
+		return -ENXIO;
+	filp->private_data = get_dev_priv(minor);
+	return 0;
+}
+
+static int etp_char_ioctl(struct inode *inode, struct file *filp,
+			  unsigned int cmd, unsigned long arg)
+{
+	struct etp_device_private *dp = filp->private_data;
+	unsigned char device = dp->number;
+	unsigned int interface;
+	int error = 0;
+
+	if (unlikely((_IOC_DIR(cmd) & _IOC_WRITE) &&
+		     !access_ok(VERIFY_READ, (void __user *)arg,
+				_IOC_SIZE(cmd))))
+		return -EFAULT;
+
+	switch (cmd) {
+	case ETP_IOCTL_INTERFACE_OPEN:
+		{
+			struct etp_ioctl_open open_struct;
+			if (unlikely(__copy_from_user(&open_struct,
+						      (void __user *)arg,
+						      _IOC_SIZE(cmd))))
+				return -EFAULT;
+			error = etp_if_open(device, open_struct.interface,
+				open_struct.if_mode, open_struct.rx_slots,
+				open_struct.tx_slots);
+		}
+		break;
+	case ETP_IOCTL_INTERFACE_CLOSE:
+		interface = arg;	/* here arg == interface_number */
+		error = etp_if_close(device, interface);
+		break;
+	case ETP_IOCTL_TX_ON:
+		interface = arg;	/* here arg == interface_number */
+		error = etp_tx_on(device, interface);
+		break;
+	case ETP_IOCTL_TX_OFF:
+		interface = arg;	/* here arg == interface_number */
+		error = etp_tx_off(device, interface);
+		break;
+	case ETP_IOCTL_RX_ON:
+		interface = arg;	/* here arg == interface_number */
+		error = etp_rx_on(device, interface);
+		break;
+	case ETP_IOCTL_RX_OFF:
+		interface = arg;	/* here arg == interface_number */
+		error = etp_rx_off(device, interface);
+		break;
+	case ETP_IOCTL_INTERFACE_SETTINGS:
+		{
+			struct etp_ioctl_interface_settings settings_struct;
+			if (unlikely(__copy_from_user
+				     (&settings_struct, (void __user *)arg,
+				      _IOC_SIZE(cmd))))
+				return -EFAULT;
+			error = etp_if_settings
+			    (device, settings_struct.interface,
+			     settings_struct.tx_clock_source,
+			     settings_struct.hdlc_mode,
+			     settings_struct.hdlc_mode_g704_used_timeslots);
+		}
+		break;
+	case ETP_IOCTL_EXT_OUTPUT_CLOCK:
+		{
+			struct etp_ioctl_ext_output_clock clock_struct;
+			if (unlikely(__copy_from_user(&clock_struct,
+						      (void __user *)arg,
+						      _IOC_SIZE(cmd))))
+				return -EFAULT;
+			error = etp_ext_output_clock
+			    (device, clock_struct.clock_source);
+		}
+		break;
+	case ETP_IOCTL_NCO:
+		{
+			struct etp_ioctl_nco_adjust nco_struct;
+			if (unlikely(__copy_from_user(&nco_struct,
+						      (void __user *)arg,
+						      _IOC_SIZE(cmd))))
+				return -EFAULT;
+			error = etp_nco_adjust
+			    (device, nco_struct.nco_addend_value);
+		}
+		break;
+	case ETP_IOCTL_DEVICE_STATUS_GET:
+		{
+			struct etp_device_status_struct status_struct;
+			error = etp_device_status_get(device, &status_struct);
+			if (unlikely(error))
+				break;
+			if (unlikely(__copy_to_user((void __user *)arg,
+						    &status_struct,
+						    _IOC_SIZE(cmd))))
+				return -EFAULT;
+		}
+		break;
+	case ETP_IOCTL_INTERFACE_STATUS_GET:
+		{
+			struct etp_interface_status_struct status_struct;
+			if (unlikely(__copy_from_user(&status_struct,
+						      (void __user *)arg,
+						      _IOC_SIZE(cmd))))
+				return -EFAULT;
+			error = etp_interface_status_get
+			    (device, status_struct.interface, &status_struct);
+			if (unlikely(error))
+				break;
+			if (unlikely(__copy_to_user((void __user *)arg,
+						    &status_struct,
+						    _IOC_SIZE(cmd))))
+				return -EFAULT;
+		}
+		break;
+	case ETP_IOCTL_E1_ACCESS:	/* Read / write IDT chip. */
+		if (unlikely(device >= etp_number)) {
+			return -ENXIO;
+		} else {
+			struct etp_ioctl_e1_access e1_struct;
+			if (unlikely(__copy_from_user(&e1_struct,
+						      (void __user *)arg,
+						      _IOC_SIZE(cmd))))
+				return -EFAULT;
+			if (!e1_struct.write) {
+				e1_struct.data = etp_read_idt_register_lock(
+								device,
+								e1_struct.
+								address);
+			} else {	/* write */
+				error = etp_write_idt_register_lock(device,
+								e1_struct.
+								address,
+								e1_struct.data);
+				if (unlikely(error))
+					break;
+			}
+			if (unlikely(__copy_to_user((void __user *)arg,
+						    &e1_struct,
+						    _IOC_SIZE(cmd))))
+				return -EFAULT;
+		}
+		break;
+	case ETP_IOCTL_RXTX_NOSLEEP_POLL:
+		if (unlikely(device >= etp_number)) {
+			return -ENXIO;
+		} else {
+			struct etp_ioctl_buffer_poll poll_struct;
+			struct etp_interface_private *ip;
+			struct etp_channel_private *cp;
+			if (unlikely(__copy_from_user(&poll_struct,
+						      (void __user *)arg,
+						      _IOC_SIZE(cmd))))
+				return -EFAULT;
+			ip = &dp->interface_privates[poll_struct.interface];
+			cp = &ip->ch_priv;
+			poll_struct.rx_slot = cp->last_rx_slot_received;
+			poll_struct.tx_slot = cp->last_tx_slot_transmitted;
+			if (unlikely(__copy_to_user((void __user *)arg,
+						    &poll_struct,
+						    _IOC_SIZE(cmd))))
+				return -EFAULT;
+		}
+		break;
+	default:
+		return -ENOTTY;
+	}
+	return error;
+}
+
+static inline void etp_disable_interrupt0(struct etp_device_private *dp,
+					  unsigned channel_number,
+					  uint8_t __iomem *ioaddr)
+{
+	spinlock_t *lock = &dp->lock0;
+	spin_lock(lock);
+	writel(dp->reg_int_mask0 &= ~(CH_ALLINTS_MASK <<
+				      INT_0_BIT_SHIFT_CH(channel_number)),
+	       ioaddr + REG_INT_MASK0);
+	mmiowb();
+	spin_unlock(lock);
+}
+
+static void etp_disable_interrupt0_irq(struct etp_device_private *dp,
+				       unsigned channel_number,
+				       uint8_t __iomem *ioaddr)
+{
+	local_irq_disable();
+	etp_disable_interrupt0(dp, channel_number, ioaddr);
+	local_irq_enable();
+}
+
+static inline void etp_schedule(struct etp_channel_private *cp,
+				struct etp_device_private *dp,
+				unsigned interface,
+				uint8_t __iomem *ioaddr)
+{
+	struct napi_struct *napi = &cp->napi;
+	cp->interrupt = true;
+	if (napi_schedule_prep(napi)) {
+		etp_disable_interrupt0(dp, IF_TO_CH(interface), ioaddr);
+		__napi_schedule(napi);
+	}
+}
+
+static inline bool etp_disable_interrupt2(struct etp_device_private *dp,
+					  uint8_t __iomem *ioaddr)
+{
+	spinlock_t *lock = &dp->lock2;
+	bool disable;
+	spin_lock(lock);
+	if (dp->reg_int_mask2 & INT_2_E1_INT) {
+		writel(dp->reg_int_mask2 &= ~INT_2_E1_INT,
+		       ioaddr + REG_INT_MASK2);
+		mmiowb();
+		disable = true;
+	} else {
+		disable = false;
+	}
+	spin_unlock(lock);
+	return disable;
+}
+
+
+static inline void queue_status(struct etp_device_private *dp,
+				uint8_t __iomem *ioaddr)
+{
+	atomic_set(&dp->interrupt, ETP_INTERRUPT);
+	if (etp_disable_interrupt2(dp, ioaddr))
+		queue_work(dp->queue, &dp->status_work);
+}
+
+static
+void queue_status_work(struct etp_device_private *dp, uint8_t __iomem *ioaddr)
+{
+	local_irq_disable();
+	queue_status(dp, ioaddr);
+	local_irq_enable();
+}
+
+/* Interrupt handler. */
+static irqreturn_t etp_interrupt(int irq, void *device)
+{
+	struct etp_device_private *dp = (struct etp_device_private *)device;
+	unsigned int interface;
+	uint8_t __iomem *ioaddr = dp->ioaddr;
+	irqreturn_t irqreturn;
+	/* Get interrupt status */
+	uint32_t intr_status_0 = readl(ioaddr + REG_INT_STAT0);
+	uint32_t intr_status_2 = readl_relaxed(ioaddr + REG_INT_STAT2);
+	struct etp_interface_private *interfaces;
+	/* Clear interrupts (only those visible in status,
+	   not those that happened after reading status) */
+	if (intr_status_0) {
+		writel(~intr_status_0, ioaddr + REG_INT_STAT0);
+		irqreturn = IRQ_HANDLED;
+	} else {
+		irqreturn = IRQ_NONE;
+	}
+	if (intr_status_2) {
+		writel(~intr_status_2, ioaddr + REG_INT_STAT2);
+		irqreturn = IRQ_HANDLED;
+	}
+	/* Check interrupts for each channel. */
+	interfaces = dp->interface_privates;
+	interface = INTERFACES_PER_DEVICE - 1u;
+	do {
+		uint32_t ch_intr_status =
+			(intr_status_0 >>
+			 INT_0_BIT_SHIFT_CH(IF_TO_CH(interface)))
+			& CH_ALLINTS_MASK;
+		if (ch_intr_status &
+		    (INT_RECEIVED | INT_RX_DROPPED | INT_TRANSMITTED)) {
+			struct etp_channel_private *cp =
+				&interfaces[interface].ch_priv;
+			if (cp->this_netdev)
+				etp_schedule(cp, dp, interface, ioaddr);
+		}
+	} while (interface--);
+	if (intr_status_2 & INT_2_E1_INT)
+		queue_status(dp, ioaddr);
+	return irqreturn;
+}
+
+/* Returns zero on success; non-zero on error. */
+static inline bool etp_update_rx_descriptor_statistics_netdev(struct
+							      net_device_stats
+							      *netdev_stats,
+							      uint32_t desc_b,
+							      uint32_t length)
+{
+	if (unlikely(length <= 2u || length > ETP_DMA)) {
+		netdev_stats->rx_length_errors++;
+		netdev_stats->rx_errors++;
+		return true;
+	}
+	if (unlikely(desc_b & (RX_DESCB_FIFO_ERR | RX_DESCB_SIZE_ERR |
+			       RX_DESCB_CRC_ERR | RX_DESCB_OCTET_ERR))) {
+		if (desc_b & RX_DESCB_FIFO_ERR)
+			netdev_stats->rx_fifo_errors++;
+		else if (desc_b & RX_DESCB_SIZE_ERR)
+			netdev_stats->rx_over_errors++;
+		else if (desc_b & RX_DESCB_CRC_ERR)
+			netdev_stats->rx_crc_errors++;
+		else
+			netdev_stats->rx_frame_errors++;
+		netdev_stats->rx_errors++;
+		return true;
+	} else { /* OK, no error. */
+		netdev_stats->rx_bytes += length;
+		netdev_stats->rx_packets++;
+		return false;
+	}
+}
+
+static inline void etp_update_tx_descriptor_statistics_netdev(struct
+							      net_device_stats
+							      *netdev_stats,
+							      uint32_t desc_b,
+							      uint32_t length)
+{
+	if (unlikely(desc_b & TX_DESCB_FIFO_ERR)) {
+		netdev_stats->tx_fifo_errors++;
+	} else {
+		netdev_stats->tx_packets++;
+		netdev_stats->tx_bytes += length;
+	}
+}
+
+static inline int rx_task_hdlc(struct etp_channel_private *cp, int weight,
+			       struct net_device *netdev, int poll)
+{
+	unsigned d = cp->last_rx_desc_received;
+	struct sk_buff *skb;
+	for (;;) {
+		struct rx_descriptor *rx = rx = cp->rx_descriptor + d;
+		struct rxdesc __iomem *rxdesc = rx->descriptor;
+		uint32_t descb = readl(&rxdesc->desc_b);
+		if (descb & RX_DESCB_TRANSFER)
+			break;
+		/* Transfer done. */
+		skb = rx->skb;
+		if (likely(skb)) {
+			uint32_t length = descb & RX_DESCB_LENGT_MASK;
+			bool error = etp_update_rx_descriptor_statistics_netdev(
+							&netdev->stats,
+							descb, length);
+			if (unlikely(error)) {
+				/* If error, reuse old skbuff. */
+				writel(RX_DESCB_TRANSFER, &rxdesc->desc_b);
+				goto NEXT;
+			} else {	/* If no error. */
+				if (unlikely(poll == weight))
+					break;
+				pci_unmap_single(this_device_priv(cp)->pci_dev,
+						 pci_unmap_addr(rx, address),
+						 ETP_DMA,
+						 PCI_DMA_FROMDEVICE);
+				if (cp->hdlc_mode <
+				    HDLC_MODE_RETINA_OVER_G703) {
+					/* -2 is the CRC. */
+					__skb_put(skb, length - 2u);
+					/* Select correct protocol. */
+					skb->protocol =
+						__constant_htons(ETH_P_WAN_PPP);
+					skb_reset_mac_header(skb);
+				} else { /* Retina ethernet mode. */
+					__skb_put(skb, length);
+					/* Remove CALP header. */
+					__skb_pull(skb, 2u);
+					skb->protocol =
+						eth_type_trans(skb, netdev);
+				}
+				if (likely(netdev->flags & IFF_POINTOPOINT)) {
+					/* Received is for us. */
+					if (unlikely(netdev->flags &
+						     IFF_NOARP)) {
+			/* NOARP applied -> destination MAC addresses bogus */
+						if (skb->pkt_type ==
+						    PACKET_OTHERHOST)
+							skb->pkt_type =
+								PACKET_HOST;
+					} else {
+	/* NOARP not applied -> destination MAC addresses are broadcast */
+						if (skb->pkt_type ==
+						    PACKET_BROADCAST)
+							skb->pkt_type =
+								PACKET_HOST;
+					}	/* IFF_NOARP */
+				}	/* IFF_POINTOPOINT */
+				netdev->last_rx = jiffies;
+				netif_receive_skb(skb);
+				poll++;
+			}
+		}
+		skb = netdev_alloc_skb(netdev, ETP_DMA + NET_IP_ALIGN);
+		if (likely(skb)) {
+			dma_addr_t bus_address;
+			skb_reserve(skb, NET_IP_ALIGN);
+			bus_address =
+				pci_map_single(this_device_priv(cp)->pci_dev,
+					       skb->data,
+					       ETP_DMA,
+					       PCI_DMA_FROMDEVICE);
+			if (likely(!pci_dma_mapping_error(this_device_priv(cp)->
+									pci_dev,
+							  bus_address))) {
+				pci_unmap_addr_set(rx, address, bus_address);
+				rx->skb = skb;
+				writel(bus_address, &rxdesc->desc_a);
+				writel(RX_DESCB_TRANSFER, &rxdesc->desc_b);
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+			} else {
+				dev_kfree_skb_any(skb);
+				rx->skb = NULL;
+				dev_warn(&netdev->dev,
+					 "failed to map DMA buffer\n");
+				goto CHECK;
+			}
+NEXT:
+			d++;
+			d &= DESCRIPTORS_PER_CHANNEL - 1u;
+		} else {
+			rx->skb = NULL;
+			dev_warn(&netdev->dev, "failed to allocate buffer\n");
+CHECK:
+			d++;
+			d &= DESCRIPTORS_PER_CHANNEL - 1u;
+			if (unlikely(d == cp->last_rx_desc_received))
+				break;
+		}
+	}
+	cp->last_rx_desc_received = d;
+	return poll;
+}
+
+static inline void tx_task_stream_timeslot(struct etp_channel_private *cp)
+{
+	/* Descriptor: start from the next descriptor to the last used. */
+	unsigned char d = (cp->last_tx_desc_transmitted + 1u) &
+			  (DESCRIPTORS_PER_CHANNEL - 1u);
+	const unsigned short slots = cp->tx_slots;
+	/* Go through all the descriptors consumed by the hardware. */
+	uint32_t desc_b;
+	struct txdesc __iomem *txdesc;
+	while (((desc_b =
+		 readl_relaxed(&(txdesc = cp->tx_descriptor[d].descriptor)->
+				desc_b)) & TX_DESCB_TRANSFER) == 0u) {
+		/* Has been sent. */
+		unsigned short slot = cp->last_tx_slot_transmitted + 1u;
+		dma_addr_t address;
+		etp_update_tx_descriptor_statistics_netdev(
+							&cp->this_netdev->stats,
+							desc_b, SLOT_SIZE);
+		cp->last_tx_desc_transmitted = d;
+		slot *= slot < slots;
+		cp->last_tx_slot_transmitted = slot;
+		address = slot + DESCRIPTORS_PER_CHANNEL;
+		address -= (address >= slots) * slots;
+		writel(cp->tx_address + (address << 8), &txdesc->desc_a);
+		writel((SLOT_SIZE & TX_DESCB_LENGT_MASK)
+		       | TX_DESCB_TRANSFER, &txdesc->desc_b);
+		{
+			unsigned written = slot + 1u;
+			written *= written < slots;
+			cp->tx_callback(cp->device_number,
+				 CH_TO_IF(cp->channel_number), written, cp->tx);
+		}
+		flush_write_buffers();
+		d = (d + 1u) & (DESCRIPTORS_PER_CHANNEL - 1u);
+	}
+#if ETP_TIMER
+	if (likely(this_if_priv(cp)->if_mode >= IF_MODE_TIMESLOT))
+		mod_timer(&cp->timer, jiffies + max(1ul, HZ / 1000ul));
+#endif
+}
+
+static void rx_task_stream_timeslot(unsigned long channel)
+{
+	struct etp_channel_private *cp = (struct etp_channel_private *)channel;
+	/* Start from the next descriptor to the last used. */
+	unsigned char d = (cp->last_rx_desc_received + 1u) &
+			  (DESCRIPTORS_PER_CHANNEL - 1u);
+	const unsigned short slots = cp->rx_slots;
+	uint32_t desc_b;
+	struct rxdesc __iomem *rxdesc;
+	/* Go through all the descriptors consumed by the hardware. */
+	while (((desc_b = readl(&(rxdesc = cp->rx_descriptor[d].descriptor)
+				 ->desc_b)) & RX_DESCB_TRANSFER) == 0u) {
+		/* Transfer done. */
+		unsigned short slot = cp->last_rx_slot_received + 1u;
+		dma_addr_t address;
+		/* Update statistics. */
+		etp_update_rx_descriptor_statistics_netdev(
+						&cp->this_netdev->stats,
+						desc_b, SLOT_SIZE);
+		/* update counters pointing to last received descriptors & slots
+		   and increase last received descriptor counter */
+		cp->last_rx_desc_received = d;
+		slot *= slot < slots;
+		cp->last_rx_slot_received = slot;
+		/* Move to next slot: initialize next descriptor and slot: */
+		address = slot + DESCRIPTORS_PER_CHANNEL;
+		address -= (address >= slots) * slots;
+		writel(cp->rx_address + (address << 8), &rxdesc->desc_a);
+		writel(RX_DESCB_TRANSFER, &rxdesc->desc_b);
+		{
+			unsigned read = slot + 1;
+			read *= read < slots;
+			cp->rx_callback(cp->device_number,
+				 CH_TO_IF(cp->channel_number), read, cp->rx);
+		}
+		d = (d + 1u) & (DESCRIPTORS_PER_CHANNEL - 1u);
+	}
+	tx_task_stream_timeslot(cp);
+}
+
+static inline void tx_task_hdlc(struct etp_channel_private *cp,
+				struct net_device *netdev)
+{
+	unsigned d;
+	uint32_t desc_b;
+	struct tx_descriptor *tx;
+	struct sk_buff *skb;
+	struct txdesc __iomem *txdesc;
+
+	d = cp->last_tx_desc_released + 1u;
+	d &= (DESCRIPTORS_PER_CHANNEL - 1u);
+	while (((skb = (tx = cp->tx_descriptor + d)->skb) != NULL) &&
+	       (((desc_b =
+		  readl_relaxed(&(txdesc = tx->descriptor)->
+				 desc_b)) & TX_DESCB_TRANSFER) == 0u)) {
+		/* Has been sent. */
+		uint32_t length = desc_b & TX_DESCB_LENGT_MASK;
+		pci_unmap_single(this_device_priv(cp)->pci_dev,
+				 pci_unmap_addr(tx, address),
+				 length, PCI_DMA_TODEVICE);
+		etp_update_tx_descriptor_statistics_netdev(&netdev->stats,
+							   desc_b, length);
+		dev_kfree_skb_any(skb);
+		tx->skb = NULL;
+		cp->last_tx_desc_released = d;
+		d++;
+		d &= (DESCRIPTORS_PER_CHANNEL - 1u);
+	}
+
+	netif_tx_lock(netdev);
+	/* If the next tx descriptor is free, continue taking new ones. */
+	if (netif_queue_stopped(netdev) &&
+	    cp->tx_descriptor[cp->last_tx_desc_transmitted].skb == NULL &&
+	    this_if_priv(cp)->if_mode == IF_MODE_HDLC)
+		netif_wake_queue(netdev);
+	netif_tx_unlock(netdev);
+}
+
+static inline void etp_enable_interrupt0(struct etp_device_private *dp,
+					 unsigned channel_number,
+					 uint8_t __iomem *ioaddr)
+{
+	unsigned long flags;
+	spinlock_t *lock = &dp->lock0;
+	spin_lock_irqsave(lock, flags);
+	writel(dp->reg_int_mask0 |=
+		CH_ALLINTS_MASK << INT_0_BIT_SHIFT_CH(channel_number),
+	       ioaddr + REG_INT_MASK0);
+	mmiowb();
+	spin_unlock_irqrestore(lock, flags);
+}
+
+static int etp_poll(struct napi_struct *napi, int weight)
+{
+	struct etp_channel_private *cp =
+		container_of(napi, struct etp_channel_private, napi);
+	struct etp_interface_private *ip = this_if_priv(cp);
+
+	switch (ip->if_mode) {
+#if !ETP_TIMER
+	case IF_MODE_TIMESLOT:
+	case IF_MODE_STREAM:
+	{
+		struct etp_device_private *dp;
+		do {
+			cp->interrupt = false;
+			rx_task_stream_timeslot((unsigned long)cp);
+			napi_complete(&cp->napi);
+		} while (cp->interrupt && napi_reschedule(&cp->napi));
+		dp = this_device_priv(cp);
+		etp_enable_interrupt0(dp, cp->channel_number, dp->ioaddr);
+		return 0;
+	}
+#endif
+	case IF_MODE_HDLC:
+	{
+		struct etp_device_private *dp;
+		int poll = 0;
+		do {
+			struct net_device *dev = cp->this_netdev;
+			cp->interrupt = false;
+			tx_task_hdlc(cp, dev);
+			poll = rx_task_hdlc(cp, weight, dev, poll);
+			if (poll == weight)
+				return poll;
+			napi_complete(&cp->napi);
+		} while (cp->interrupt && napi_reschedule(&cp->napi));
+		dp = this_device_priv(cp);
+		etp_enable_interrupt0(dp, cp->channel_number, dp->ioaddr);
+		return poll;
+	}
+	default:
+	napi_complete(napi);
+	return 0;
+	}
+}
+
+static int etp_change_mtu(struct net_device *dev, int mtu)
+{
+	if (unlikely(mtu > ETP_MRU))
+		return -EINVAL;
+	dev->mtu = mtu;
+	return 0;
+}
+
+static void etp_netdev_tx_timeout(struct net_device *dev)
+{
+	struct etp_channel_private *cp =
+		((struct etp_netdev_priv *)(netdev_priv(dev)))->cp;
+	struct etp_device_private *dp = cp->this_dev_priv;
+	local_irq_disable();
+	etp_schedule(cp, dp, CH_TO_IF(cp->channel_number), dp->ioaddr);
+	local_irq_enable();
+}
+
+/* Clear (initialize) descriptors. */
+static inline void clear_descriptors(struct etp_channel_private *cp)
+{
+	unsigned d;
+	for (d = 0u; d < DESCRIPTORS_PER_CHANNEL; d++) {
+		struct rxdesc __iomem *rxdesc =
+			cp->rx_descriptor[d].descriptor;
+		struct txdesc __iomem *txdesc;
+		writel(0u, &rxdesc->desc_b);
+		writel(0u, &rxdesc->desc_a);
+		txdesc = cp->tx_descriptor[d].descriptor;
+		writel(0u, &txdesc->desc_b);
+		writel(0u, &txdesc->desc_a);
+	}
+}
+
+static inline void etp_free_rx(struct etp_channel_private *cp,
+			       struct etp_device_private *dp)
+{
+	unsigned d;
+	for (d = 0u; d < DESCRIPTORS_PER_CHANNEL; d++) {
+		struct rx_descriptor *rx = cp->rx_descriptor + d;
+		struct sk_buff *skb = rx->skb;
+		if (skb != NULL) {
+			pci_unmap_single(dp->pci_dev,
+					 pci_unmap_addr(rx, address),
+					 ETP_DMA, PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(skb);
+			rx->skb = NULL;
+		}
+	}
+}
+
+static int etp_netdev_open(struct net_device *netdev)
+{
+	struct etp_channel_private *cp =
+		((struct etp_netdev_priv *)(netdev_priv(netdev)))->cp;
+	unsigned channel_number = cp->channel_number;
+	struct etp_interface_private *ip = this_if_priv(cp);
+	struct etp_device_private *dp = this_dev_priv(ip);
+	unsigned d;
+	uint8_t __iomem *ioaddr;
+	int error;
+
+	if (unlikely(ip->if_mode >= IF_MODE_TIMESLOT))	/* timeslot or stream */
+		return -EBUSY;
+
+	if (cp->hdlc_mode <= HDLC_MODE_CISCO_OVER_G704) { /* Cisco-HDLC */
+		error = sppp_do_ioctl(netdev, NULL, SPPPIOCCISCO);
+		if (unlikely(error))
+			return error;
+	}
+
+	cp->last_rx_desc_received = 0u;
+	cp->last_tx_desc_transmitted = 0u;
+	cp->last_tx_desc_released = DESCRIPTORS_PER_CHANNEL - 1u;
+
+	/* Clear CRC mode (and flag multiply) in TX and RX registers. */
+	writel(~(HDLC_CRC_MASK | HDLC_RETINA_FLAG)
+	       & readl_relaxed(ip->reg_if_rxctrl), ip->reg_if_rxctrl);
+	writel(~(HDLC_CRC_MASK | HDLC_RETINA_FLAG)
+	       & readl_relaxed(ip->reg_if_txctrl), ip->reg_if_txctrl);
+	switch (cp->hdlc_mode) {
+	case HDLC_MODE_CISCO_OVER_G703:
+		{
+			/* Set E1 mode to HDLC, configure CRC mode. */
+			writel(E1_MODE_HDLC | HDLC_CRC_16 |
+			       readl_relaxed(ip->reg_if_rxctrl),
+			       ip->reg_if_rxctrl);
+			writel(E1_MODE_HDLC | HDLC_CRC_16 |
+			       readl_relaxed(ip->reg_if_txctrl),
+			       ip->reg_if_txctrl);
+			error = idt_open_if_hdlc_g703(dp,
+						      CH_TO_IF(channel_number));
+			if (unlikely(error))
+				return error;
+			/* Select all timeslots. */
+			writel(0u, ip->reg_if_rxctrl1);
+			writel(0u, ip->reg_if_txctrl1);
+			break;
+		}
+	case HDLC_MODE_RETINA_OVER_G703:
+	case HDLC_MODE_RETINA_OVER_G703_POINTOPOINT:
+		{
+			/* Set E1 mode to HDLC, configure CRC mode. */
+			writel(E1_MODE_HDLC | HDLC_CRC_32 | HDLC_CRC_DELAY |
+			       HDLC_RETINA_FLAG |
+			       readl_relaxed(ip->reg_if_rxctrl),
+			       ip->reg_if_rxctrl);
+			writel(E1_MODE_HDLC | HDLC_CRC_32 | HDLC_CRC_DELAY |
+			       HDLC_RETINA_FLAG |
+			       readl_relaxed(ip->reg_if_txctrl),
+			       ip->reg_if_txctrl);
+			error = idt_open_if_hdlc_g703(dp,
+						      CH_TO_IF(channel_number));
+			if (unlikely(error))
+				return error;
+			/* Select all timeslots. */
+			writel(0u, ip->reg_if_rxctrl1);
+			writel(0u, ip->reg_if_txctrl1);
+			break;
+		}
+	case HDLC_MODE_CISCO_OVER_G704:
+		{
+			/* Set E1 mode to HDLC and configure CRC mode. */
+			writel(E1_MODE_HDLC | HDLC_CRC_16 |
+			       readl_relaxed(ip->reg_if_rxctrl),
+			       ip->reg_if_rxctrl);
+			writel(E1_MODE_HDLC | HDLC_CRC_16 |
+			       readl_relaxed(ip->reg_if_txctrl),
+			       ip->reg_if_txctrl);
+			error = idt_open_if_hdlc_g704(dp,
+						      CH_TO_IF(channel_number));
+			if (unlikely(error))
+				return error;
+			/* Select wanted timeslots. */
+			writel(~(cp->hdlc_mode_g704_used_timeslots),
+			       ip->reg_if_rxctrl1);
+			writel(~(cp->hdlc_mode_g704_used_timeslots),
+			       ip->reg_if_txctrl1);
+			break;
+		}
+	case HDLC_MODE_RETINA_OVER_G704:
+	case HDLC_MODE_RETINA_OVER_G704_POINTOPOINT:
+		{
+			/* Set E1 mode to HDLC and configure CRC mode. */
+			writel(E1_MODE_HDLC | HDLC_CRC_32 | HDLC_CRC_DELAY |
+			       HDLC_RETINA_FLAG |
+			       readl_relaxed(ip->reg_if_rxctrl),
+			       ip->reg_if_rxctrl);
+			writel(E1_MODE_HDLC | HDLC_CRC_32 | HDLC_CRC_DELAY |
+			       HDLC_RETINA_FLAG |
+			       readl_relaxed(ip->reg_if_txctrl),
+			       ip->reg_if_txctrl);
+			error = idt_open_if_hdlc_g704(dp,
+						      CH_TO_IF(channel_number));
+			if (unlikely(error))
+				return error;
+			/* Select wanted timeslots. */
+			writel(~(cp->hdlc_mode_g704_used_timeslots),
+			       ip->reg_if_rxctrl1);
+			writel(~(cp->hdlc_mode_g704_used_timeslots),
+			       ip->reg_if_txctrl1);
+			break;
+		}
+	}
+	/* If syncPPP (CiscoHDLC). */
+	if (cp->hdlc_mode <= HDLC_MODE_CISCO_OVER_G704) {
+		error = sppp_open(netdev);
+		if (unlikely(error))
+			return error;
+	}
+
+	clear_descriptors(cp);
+	/* Go through all the descriptors and reserve new struct sk_buffs. */
+	for (d = 0u; d < DESCRIPTORS_PER_CHANNEL; d++) {
+		dma_addr_t address;
+		struct sk_buff *skb = __netdev_alloc_skb(netdev,
+							 ETP_DMA + NET_IP_ALIGN,
+							 GFP_KERNEL);
+		if (unlikely(skb == NULL))
+			continue;
+		skb_reserve(skb, NET_IP_ALIGN);
+		address = pci_map_single(dp->pci_dev, skb->data,
+					 ETP_DMA, PCI_DMA_FROMDEVICE);
+		if (likely(!pci_dma_mapping_error(dp->pci_dev, address))) {
+			struct rx_descriptor *rx = cp->rx_descriptor + d;
+			struct rxdesc __iomem *rxdesc;
+			pci_unmap_addr_set(rx, address, address);
+			rx->skb = skb;
+			rxdesc = rx->descriptor;
+			writel(address, &rxdesc->desc_a);
+			writel(RX_DESCB_TRANSFER, &rxdesc->desc_b);
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		} else {
+			dev_kfree_skb(skb);
+		}
+	}
+
+	/* Start the reception and transmission channels. */
+	writel(DMA_ENABLE | RX_FIFO_THRESHOLD_DEFAULT | ETP_DMA,
+	       cp->reg_ch_rxctrl);
+	writel(DMA_ENABLE | TX_FIFO_THRESHOLD_DEFAULT | TX_START_LEVEL_DEFAULT,
+	       cp->reg_ch_txctrl);
+	/* Turn the transmit clock on. */
+	writel((ip->tx_clock_source << TX_CLOCK_SELECT_SHIFT) |
+	       (~TX_CLOCK_SELECT_MASK
+		& readl_relaxed(ip->reg_if_txctrl)), ip->reg_if_txctrl);
+	ip->if_mode = IF_MODE_HDLC;
+	ioaddr = dp->ioaddr;
+	queue_status_work(dp, ioaddr);
+	napi_enable(&cp->napi);
+	/* Enable interrupts by setting the interrupt mask. */
+	etp_enable_interrupt0(dp, channel_number, ioaddr);
+	netif_start_queue(netdev);
+	return 0;
+}
+
+static int etp_netdev_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct etp_channel_private *cp
+		= ((struct etp_netdev_priv *)(netdev_priv(dev)))->cp;
+	unsigned last_transmitted;
+	uint8_t *data;
+	struct tx_descriptor *tx;
+	unsigned tx_length = skb->len;
+#ifdef ETP_TESTER
+	/* change IP addresses to be able to ping myself */
+	{
+		struct iphdr *ip_header =
+			(struct iphdr *)((skb->data) + sizeof(struct ethhdr));
+		uint32_t *s_addr = &ip_header->saddr;
+		uint32_t *d_addr = &ip_header->daddr;
+		if (skb->len < sizeof(struct ethhdr) + sizeof(struct iphdr))
+			goto no_messing_with_ip;
+		((u8 *) s_addr)[3] ^= 4;
+		((u8 *) d_addr)[3] ^= 4;
+		/* calculate new checksum: */
+		ip_header->check = 0;
+		ip_header->check = ip_fast_csum((unsigned char *)
+						ip_header, ip_header->ihl);
+	}
+no_messing_with_ip:
+#endif /* ETP_TESTER */
+	if (unlikely(tx_length < ETH_ZLEN)) {
+		if (unlikely(skb_padto(skb, ETH_ZLEN))) {
+			dev->stats.tx_dropped++;
+			return NETDEV_TX_OK;
+		}
+		tx_length = ETH_ZLEN;
+	}
+	if (cp->hdlc_mode >= HDLC_MODE_RETINA_OVER_G703) {
+		/* make room for CALP header */
+		if (unlikely(skb_cow_head(skb, 2u)))
+			return NETDEV_TX_BUSY;
+		data = __skb_push(skb, 2u);
+		*data = 0x0;	/* the CALP header */
+		data[1] = 0x40;	/* the CALP header */
+		/* add CALP header length (+2), minus CRC (-4) */
+		tx_length += 2u;
+	} else {
+		data = skb->data;
+	}
+	{
+		dma_addr_t bus_address =
+			pci_map_single(this_device_priv(cp)->pci_dev, data,
+				       tx_length, PCI_DMA_TODEVICE);
+		if (likely(!pci_dma_mapping_error(this_device_priv(cp)->pci_dev,
+						  bus_address))) {
+			struct txdesc __iomem *txdesc;
+			last_transmitted = cp->last_tx_desc_transmitted;
+			tx = cp->tx_descriptor + last_transmitted;
+			pci_unmap_addr_set(tx, address, bus_address);
+			txdesc = tx->descriptor;
+			writel(bus_address, &txdesc->desc_a);
+			writel(tx_length | TX_DESCB_TRANSFER,
+			       &txdesc->desc_b);
+		} else {
+			if (cp->hdlc_mode >= HDLC_MODE_RETINA_OVER_G703)
+				__skb_pull(skb, 2u);
+			return NETDEV_TX_BUSY;
+		}
+	}
+	tx->skb = skb;
+	{
+		/* Calculate the next transmission descriptor entry */
+		unsigned next = (last_transmitted + 1u) &
+				(DESCRIPTORS_PER_CHANNEL - 1u);
+		cp->last_tx_desc_transmitted = next;
+		/* If next descriptor is busy, discontinue taking new ones. */
+		if (cp->tx_descriptor[next].skb != NULL)
+			netif_stop_queue(dev);
+	}
+	dev->trans_start = jiffies;
+	return NETDEV_TX_OK;
+}
+
+static void etp_netdev_close_down(struct net_device *dev,
+				  struct etp_channel_private *cp,
+				  struct etp_interface_private *ip,
+				  struct etp_device_private *dp)
+{
+	uint8_t __iomem *ioaddr, *reg_rst_ctrl;
+	unsigned d = cp->channel_number;
+	uint32_t __iomem *reg_if_txctrl = ip->reg_if_txctrl;
+
+	if (ip->if_mode == IF_MODE_CLOSED)
+		return;
+	ip->if_mode = IF_MODE_CLOSED;
+	netif_tx_disable(dev);
+	napi_disable(&cp->napi);
+
+	if (cp->hdlc_mode <= HDLC_MODE_CISCO_OVER_G704)
+		sppp_close(dev);
+
+	idt_close_if(dp, CH_TO_IF(d));
+	/* Transmit clock off. */
+	writel((CLOCK_SELECT_NO_CLOCK << TX_CLOCK_SELECT_SHIFT) |
+	       (~TX_CLOCK_SELECT_MASK &
+		readl_relaxed(reg_if_txctrl)), reg_if_txctrl);
+	ioaddr = dp->ioaddr;
+	/* Disable interrupts by clearing the interrupt mask. */
+	etp_disable_interrupt0_irq(dp, d, ioaddr);
+	/* Stop DMA. */
+	writel(~DMA_ENABLE & readl(cp->reg_ch_rxctrl), cp->reg_ch_rxctrl);
+	writel(~DMA_ENABLE & readl_relaxed(cp->reg_ch_txctrl),
+	       cp->reg_ch_txctrl);
+	/* Reset the channel. */
+	reg_rst_ctrl = ioaddr + REG_RST_CTRL;
+	writel(RESET_CH(d), reg_rst_ctrl);
+	readl(reg_rst_ctrl); /* Wait for DMA to end before free. */
+	/* Free all the reception skbuffs */
+	etp_free_rx(cp, dp);
+	/* and transmission. */
+	for (d = 0u; d < DESCRIPTORS_PER_CHANNEL; d++) {
+		struct tx_descriptor *tx = cp->tx_descriptor + d;
+		struct sk_buff *skb = tx->skb;
+		if (skb != NULL) {
+			pci_unmap_single(dp->pci_dev,
+					 pci_unmap_addr(tx, address),
+					 skb->len, PCI_DMA_TODEVICE);
+			dev_kfree_skb(skb);
+			tx->skb = NULL;
+		}
+	}
+	queue_status_work(dp, ioaddr);
+}
+
+static int etp_netdev_close(struct net_device *dev)
+{
+	struct etp_channel_private *cp
+		= ((struct etp_netdev_priv *)(netdev_priv(dev)))->cp;
+	struct etp_interface_private *ip = this_if_priv(cp);
+	struct etp_device_private *dp = this_dev_priv(ip);
+	if (unlikely(!netif_device_present(dev)))
+		return -ENXIO;
+	etp_netdev_close_down(dev, cp, ip, dp);
+	return 0;
+}
+
+/* For getting LOS information. */
+static inline int idt_los(unsigned device, unsigned offset)
+{
+	return etp_read_idt_register_lock(device,
+					  E1_TRNCVR_LINE_STATUS0_REG | offset);
+}
+
+/* Set E1 interrupt enabled. */
+static
+void etp_enable_interrupt(struct etp_device_private *dp)
+{
+	spinlock_t *lock = &dp->lock2;
+	spin_lock_irq(lock);
+	writel(dp->reg_int_mask2 |= INT_2_E1_INT, dp->ioaddr + REG_INT_MASK2);
+	mmiowb();
+	spin_unlock_irq(lock);
+}
+
+/* Work called to read IDT chip. */
+static void status_work(struct work_struct *work)
+{
+	struct etp_device_private *dp =
+		container_of(work, struct etp_device_private, status_work);
+	struct etp_interface_private *interfaces = dp->interface_privates;
+	unsigned interface;
+	const unsigned device = device_number(dp);
+	struct mutex *mutex = &dp->idt;
+	if (unlikely(atomic_read(&dp->reset)))
+		return;
+	mutex_lock(mutex);
+	atomic_set(&dp->interrupt, ETP_INTERRUPT_NONE);
+	if (dp->run[0])
+		dp->idt_int_callback[0](device);
+	if (dp->run[1])
+		dp->idt_int_callback[1](device);
+	mutex_unlock(mutex);
+	interface = 0u;
+	do {
+		struct etp_interface_private *ip;
+		unsigned mode;
+		int los;
+		int offset = etp_idt_offset(device, interface);
+		struct net_device *this_netdev;
+		if (unlikely(offset < 0))
+			return;
+		/* Clear E1 Interrupt Status 0. */
+		etp_write_idt_register_lock(device, E1_TRNCVR_INT_STATUS0_REG
+						    | offset, 1u);
+		los = idt_los(device, offset);
+		if (unlikely(los < 0))
+			return;
+		los &= 1;
+		ip = &interfaces[interface];
+		rtnl_lock();
+		mode = ip->if_mode;
+		ip->los = los;
+		this_netdev = ip->ch_priv.this_netdev;
+		if (likely(this_netdev)) {
+			if (los || mode == IF_MODE_CLOSED) {
+				set_led(LED_CTRL_OFF, ip, interface, dp);
+				netif_carrier_off(this_netdev);
+			} else { /* Link up and interface opened. */
+				netif_carrier_on(this_netdev);
+				set_led(mode == IF_MODE_HDLC ? LED_CTRL_TRAFFIC
+					: LED_CTRL_ON, ip, interface, dp);
+			}
+		}
+		rtnl_unlock();
+	} while (interface++ < INTERFACES_PER_DEVICE - 1u);
+	if (unlikely(atomic_read(&dp->interrupt))) {
+QUEUE:		queue_delayed_work(dp->queue, &dp->led, HZ * 4ul / 5ul);
+	} else {
+		etp_enable_interrupt(dp);
+		if (unlikely(atomic_read(&dp->interrupt) &&
+			     etp_disable_interrupt2(dp, dp->ioaddr)))
+			goto QUEUE;
+	}
+}
+
+/* Work called to read IDT chip for setting LEDs right after 4
seconds delay. */
+static void led_work(struct work_struct *work)
+{
+	struct delayed_work *led =
+		container_of(work, struct delayed_work, work);
+	struct etp_device_private *dp =
+		container_of(led, struct etp_device_private, led);
+	status_work(&dp->status_work);
+}
+
+/* ---------- Functions of etp kernel interface (defined in etp.h)
---------- */
+
+/* Registers callback functions. */
+int etp_register_callbacks(const struct etp_callback_struct *callback_p)
+{
+	struct etp_device_private *dp = get_dev_priv(callback_p->device);
+	struct etp_interface_private *interfaces = dp->interface_privates;
+	unsigned interface = callback_p->interface;
+	struct etp_interface_private *ip = interfaces + interface;
+	struct etp_channel_private *cp = &ip->ch_priv;
+	unsigned index = callback_p->index;
+	struct mutex *mutex = &dp->idt;
+	etp_idt_callback_t callback = callback_p->idt_int_callback;
+	void (*rx_callback) (unsigned device,
+			     unsigned interface,
+			     unsigned read,
+			     const struct slot_struct *) =
+			callback_p->rx_callback;
+	void (*rx_old) (unsigned device,
+			unsigned interface,
+			unsigned read,
+			const struct slot_struct *);
+	void (*tx_callback) (unsigned device,
+			     unsigned interface,
+			     unsigned written,
+			     struct slot_struct *) = callback_p->tx_callback;
+	void (*tx_old) (unsigned device,
+			unsigned interface,
+			unsigned written,
+			struct slot_struct *);
+	int error = 0;
+	mutex_lock(mutex);
+	if (callback) {
+		dp->idt_int_callback[index] = callback;
+		dp->run[index] |= 1u << interface;
+	} else {
+		dp->run[index] &= ~(1u << interface);
+	}
+	rx_old = cp->rx_callback;
+	tx_old = cp->tx_callback;
+	if (likely(atomic_read(&cp->owner) != !index)) {
+		if (rx_callback) {
+			atomic_set(&cp->owner, index);
+			cp->rx_callback = rx_callback;
+			cp->tx_callback = tx_callback;
+		} else {
+			atomic_set(&cp->owner, ETP_CALLBACKS);
+			cp->tx_callback = tx_null_callback;
+			cp->rx_callback = rx_null_callback;
+		}
+	} else if (unlikely(rx_callback)) {
+		error = -EBUSY;
+	}
+	mutex_unlock(mutex);
+	return error;
+}
+EXPORT_SYMBOL(etp_register_callbacks);
+
+uint32_t etp_rx_on_get(const struct etp_channel_private *cp)
+{
+	return readl(cp->reg_ch_rxctrl) & DMA_ENABLE_MASK;
+}
+
+uint32_t etp_tx_on_get(const struct etp_channel_private *cp)
+{
+	return readl_relaxed(cp->reg_ch_txctrl) & DMA_ENABLE_MASK;
+}
+
+int etp_frame(unsigned device, unsigned interface, bool frame)
+{
+	if (unlikely(device >= etp_number)) {
+		return -ENXIO;
+	} else {
+		struct etp_device_private *dp = get_dev_priv(device);
+		struct etp_interface_private *ip =
+			&dp->interface_privates[interface];
+		if (frame) {
+			/* Set channel E1 mode to TIMESLOT. */
+			int error = idt_open_if_timeslot(dp, interface);
+			if (unlikely(error))
+				return error;
+			ip->if_mode = IF_MODE_TIMESLOT;
+		} else {
+			/* Set channel E1 mode to STREAM. */
+			int error = idt_open_if_stream(dp, interface);
+			if (unlikely(error))
+				return error;
+			ip->if_mode = IF_MODE_STREAM;
+		}
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(etp_frame);
+
+/* Open interface (in timeslot or stream mode). */
+int etp_if_open(unsigned device,	/* The number of the device. */
+		unsigned interface,	/* The number of the interface. */
+		unsigned if_mode,
+		unsigned rx_slots,	/* The size of the rx buffer. */
+		unsigned tx_slots)	/* The size of the rx buffer. */
+{
+	struct etp_device_private *dp;
+	struct etp_interface_private *ip;
+	struct etp_channel_private *cp;
+	int error;
+	unsigned d;
+	struct rw_semaphore *ip_semaphore;
+	struct net_device *net_device;
+	struct device *dev;
+
+	if (unlikely(tx_slots < MIN_SLOTS
+		     || tx_slots > MAX_SLOTS
+		     || rx_slots < MIN_SLOTS
+		     || rx_slots > MAX_SLOTS))
+		return -EINVAL;
+	if (unlikely(interface >= INTERFACES_PER_DEVICE))
+		return -ENXIO;
+	if (unlikely(device >= etp_number))
+		return -ENXIO;
+	dp = get_dev_priv(device);
+	ip = &dp->interface_privates[interface];
+	ip_semaphore = &ip->semaphore;
+	down_write(ip_semaphore);
+	if (unlikely(atomic_read(&dp->reset))) {
+		error = -ENXIO;
+		goto UP;
+	}
+	cp = &ip->ch_priv;
+	while ((net_device = cp->this_netdev) == NULL) {
+		error = etp_init_netdev(cp,
+					HDLC_MODE_RETINA_OVER_G703_POINTOPOINT);
+		if (unlikely(error))
+			goto UP;
+	}
+	rtnl_lock();
+	if (unlikely(ip->if_mode != IF_MODE_CLOSED)) {	/* The current mode */
+		dev_warn(&net_device->dev,
+			 "Interface must be closed before it can be opened\n");
+		error = -EBUSY;
+		goto UNLOCK;
+	}
+	if (unlikely(if_mode < IF_MODE_TIMESLOT)) {	/* The wanted mode */
+		dev_warn(&net_device->dev,
+			 "Invalid mode %u for the interface\n", if_mode);
+		error = -EINVAL;
+		goto UNLOCK;
+	}
+	dev = &dp->pci_dev->dev;
+	/* Reserve the buffers. */
+	cp->tx = dma_alloc_coherent(dev, tx_slots * SLOT_SIZE, &cp->tx_address,
+				    GFP_KERNEL);
+	if (unlikely(cp->tx == NULL)) {
+		error = -ENOMEM;
+		goto UNLOCK;
+	}
+	cp->tx_slots = tx_slots;
+	cp->rx = dma_alloc_coherent(dev, rx_slots * SLOT_SIZE, &cp->rx_address,
+				    GFP_KERNEL);
+	if (unlikely(cp->rx == NULL)) {
+		error = -ENOMEM;
+		goto CLOSE;
+	}
+	cp->rx_slots = rx_slots;
+	cp->last_rx_desc_received = DESCRIPTORS_PER_CHANNEL - 1u;
+	cp->last_rx_slot_received = rx_slots - 1u;
+	cp->last_tx_desc_transmitted = DESCRIPTORS_PER_CHANNEL - 1u;
+	cp->last_tx_slot_transmitted = tx_slots - 1u;
+	/* Initialize the descriptors. */
+	for (d = 0u; d < DESCRIPTORS_PER_CHANNEL; d++) {
+		struct rxdesc __iomem *rxdesc =
+			cp->rx_descriptor[d].descriptor;
+		struct txdesc __iomem *txdesc =
+			cp->tx_descriptor[d].descriptor;
+		writel(cp->rx_address + d * SLOT_SIZE, &rxdesc->desc_a);
+		writel(RX_DESCB_TRANSFER, &rxdesc->desc_b);
+		writel(cp->tx_address + d * SLOT_SIZE, &txdesc->desc_a);
+		writel((SLOT_SIZE & TX_DESCB_LENGT_MASK) | TX_DESCB_TRANSFER,
+		       &txdesc->desc_b);
+	}
+
+	/* Enable the disabled timeslots. */
+	writel(0u, ip->reg_if_rxctrl1);
+	writel(0u, ip->reg_if_txctrl1);
+	writel(~(E1_MODE_MASK | HDLC_CRC_MASK) &
+	       readl_relaxed(ip->reg_if_rxctrl),
+	       ip->reg_if_rxctrl);
+	writel(~(E1_MODE_MASK | HDLC_CRC_MASK) &
+	       readl_relaxed(ip->reg_if_txctrl),
+	       ip->reg_if_txctrl);
+	error = etp_frame(device, interface, if_mode == IF_MODE_TIMESLOT);
+	if (likely(!error)) {
+		uint8_t __iomem *ioaddr = dp->ioaddr;
+		queue_status_work(dp, ioaddr);
+#if ETP_TIMER
+		{
+			struct timer_list *timer = &cp->timer;
+			timer->expires = jiffies + HZ / 1000ul;
+			add_timer(timer);
+		}
+		mmiowb();
+#else
+		napi_enable(&cp->napi);
+		/* Enable interrupts by setting the interrupt mask. */
+		etp_enable_interrupt0(dp, IF_TO_CH(interface), ioaddr);
+#endif
+	} else {
+		goto CLOSE;
+	}
+UNLOCK:	rtnl_unlock();
+UP:	up_write(ip_semaphore);
+	return error;
+CLOSE:
+	etp_if_close_down(interface, dp, ip);
+	goto UNLOCK;
+}
+EXPORT_SYMBOL(etp_if_open);
+
+/**
+ * Close an interface in timeslot or stream mode.
+ * The caller must be holding the interface semaphore and rtnl_lock().
+ **/
+static int etp_if_close_down(unsigned interface, struct etp_device_private *dp,
+			     struct etp_interface_private *ip)
+{
+	struct etp_channel_private *cp = &ip->ch_priv;
+	uint8_t __iomem *ioaddr;
+	struct net_device *net_device = cp->this_netdev;
+	struct device *device;
+	unsigned char mode = ip->if_mode;
+	if (unlikely(net_device == NULL))
+		return 0;
+	if (unlikely(mode == IF_MODE_HDLC)) {
+		dev_warn(&net_device->dev,
+			 "Trying to close interface that is in HDLC mode\n");
+		return -EBUSY;
+	}
+	idt_close_if(dp, interface);
+	etp_tx_off_down(ip);
+	etp_rx_off_down(ip);
+	ioaddr = dp->ioaddr;
+	/* Prevent the running of new polls and timers. */
+	ip->if_mode = IF_MODE_CLOSED;
+#if ETP_TIMER
+	smp_wmb(); /* Prevent restarting the timer by setting mode closed. */
+	/* Kill a possible running timer before freeing DMA buffers. */
+	del_timer_sync(&cp->timer);
+#else
+	etp_disable_interrupt0_irq(dp, IF_TO_CH(interface), ioaddr);
+	/* Kill a possible running poll before freeing DMA buffers. */
+	if (mode != IF_MODE_CLOSED)
+		napi_disable(&cp->napi);
+#endif
+	/* Reset the channel. */
+	writel(RESET_CH(IF_TO_CH(interface)), ioaddr + REG_RST_CTRL);
+	readl(ioaddr + REG_RST_CTRL); /* Wait for the card to respond. */
+	device = &dp->pci_dev->dev;
+	/* Free the buffers. */
+	if (likely(cp->tx)) {
+		dma_free_coherent(device, (size_t)cp->tx_slots * SLOT_SIZE,
+				  cp->tx, cp->tx_address);
+		cp->tx = NULL;
+	}
+	if (likely(cp->rx)) {
+		dma_free_coherent(device, (size_t)cp->rx_slots * SLOT_SIZE,
+				  cp->rx, cp->rx_address);
+		cp->rx = NULL;
+	}
+	queue_status_work(dp, ioaddr);
+	return 0;
+}
+
+/* Close an interface in timeslot or stream mode only. */
+int etp_if_close(unsigned device, /* The number of the device. */
+		 unsigned interface) /* The number of the interface. */
+{
+	struct etp_device_private *dp = get_dev_priv(device);
+	struct etp_interface_private *ip = &dp->interface_privates[interface];
+	struct rw_semaphore *ip_semaphore = &ip->semaphore;
+	int error;
+	down_write(ip_semaphore);
+	rtnl_lock();
+	error = etp_if_close_down(interface, dp, ip);
+	mmiowb();
+	rtnl_unlock();
+	up_write(ip_semaphore);
+	return error;
+}
+EXPORT_SYMBOL(etp_if_close);
+
+static int etp_tx_on_down(struct etp_interface_private *ip)
+{
+	struct etp_channel_private *cp = &ip->ch_priv;
+	if (unlikely(ip->if_mode < IF_MODE_TIMESLOT)) {
+		struct net_device *device = cp->this_netdev;
+		if (device)
+			dev_warn(&device->dev, "Cannot set transmitter on "
+				 "because not in timeslot or stream mode\n");
+		return -EBUSY;
+	}
+	/* Set DMA on... */
+	writel(DMA_ENABLE | TX_FIFO_THRESHOLD_DEFAULT | TX_START_LEVEL_DEFAULT,
+	       cp->reg_ch_txctrl);
+	/* ...and then the transmit clock on. */
+	writel((ip->tx_clock_source << TX_CLOCK_SELECT_SHIFT) |
+	       (~TX_CLOCK_SELECT_MASK
+		& readl_relaxed(ip->reg_if_txctrl)), ip->reg_if_txctrl);
+	return 0;
+}
+
+/* Start transmitter (timeslot or stream mode only). */
+int etp_tx_on(unsigned device, unsigned channel)
+{
+	struct etp_device_private *dp;
+	struct etp_interface_private *ip;
+	int error;
+	struct rw_semaphore *ip_semaphore;
+	if (unlikely(device >= etp_number || channel >= INTERFACES_PER_DEVICE))
+		return -ENXIO;
+	dp = get_dev_priv(device);
+	ip = &dp->interface_privates[channel];
+	ip_semaphore = &ip->semaphore;
+	down_write(ip_semaphore);
+	error = etp_tx_on_down(ip);
+	mmiowb();
+	up_write(ip_semaphore);
+	return error;
+}
+EXPORT_SYMBOL(etp_tx_on);
+
+/* Stop transmitter (timeslot or stream mode). */
+static int etp_tx_off_down(struct etp_interface_private *ip)
+{
+	unsigned mode = ip->if_mode;
+	struct etp_channel_private *cp = &ip->ch_priv;
+
+	if (unlikely(mode == IF_MODE_HDLC)) {
+		dev_warn(&cp->this_netdev->dev, "Cannot set transmitter off "
+			 "because not in timeslot or stream mode\n");
+		return -EBUSY;
+	}
+	if (mode != IF_MODE_CLOSED) {
+		/* Transmit clock off. */
+		writel((CLOCK_SELECT_NO_CLOCK << TX_CLOCK_SELECT_SHIFT) |
+		       (~TX_CLOCK_SELECT_MASK &
+			readl_relaxed(ip->reg_if_txctrl)),
+		       ip->reg_if_txctrl);
+		/* DMA off. */
+		writel(~DMA_ENABLE & readl_relaxed(cp->reg_ch_txctrl),
+		       cp->reg_ch_txctrl);
+	}
+	return 0;
+}
+
+/* Stop transmitter (timeslot or stream mode only). */
+int etp_tx_off(unsigned device, unsigned channel)
+{
+	struct etp_device_private *dp;
+	struct etp_interface_private *ip;
+	struct rw_semaphore *ip_semaphore;
+	int error;
+	if (unlikely(device >= etp_number || channel >= INTERFACES_PER_DEVICE))
+		return -ENXIO;
+	dp = get_dev_priv(device);
+	ip = &dp->interface_privates[channel];
+	ip_semaphore = &ip->semaphore;
+	down_write(ip_semaphore);
+	error = etp_tx_off_down(ip);
+	mmiowb();
+	up_write(ip_semaphore);
+	return 0;
+}
+
+static int etp_rx_on_down(struct etp_interface_private *ip)
+{
+	struct etp_channel_private *cp = &ip->ch_priv;
+	if (unlikely(ip->if_mode < IF_MODE_TIMESLOT)) {
+		struct net_device *device = cp->this_netdev;
+		if (device)
+			dev_warn(&device->dev, "Cannot set receiver on "
+				 "because not in timeslot or stream mode\n");
+		return -EBUSY;
+	}
+
+	writel(DMA_ENABLE | RX_FIFO_THRESHOLD_DEFAULT | SLOT_SIZE,
+	       cp->reg_ch_rxctrl);
+	return 0;
+}
+
+/* Start receiver (timeslot or stream mode only). */
+int etp_rx_on(unsigned device, unsigned channel)
+{
+	struct etp_device_private *dp;
+	struct etp_interface_private *ip;
+	int error;
+	struct rw_semaphore *ip_semaphore;
+	if (unlikely(device >= etp_number || channel >= INTERFACES_PER_DEVICE))
+		return -ENXIO;
+	dp = get_dev_priv(device);
+	ip = &dp->interface_privates[channel];
+	ip_semaphore = &ip->semaphore;
+	down_write(ip_semaphore);
+	error = etp_rx_on_down(ip);
+	mmiowb();
+	up_write(ip_semaphore);
+	return error;
+}
+EXPORT_SYMBOL(etp_rx_on);
+
+/* Stop receiver (timeslot or stream mode only). */
+static int etp_rx_off_down(struct etp_interface_private *ip)
+{
+	struct etp_channel_private *cp = &ip->ch_priv;
+	if (unlikely(ip->if_mode == IF_MODE_HDLC)) {
+		dev_warn(&cp->this_netdev->dev, "Cannot set receiver off "
+			 "because not in timeslot or stream mode\n");
+		return -EBUSY;
+	}
+	if (ip->if_mode != IF_MODE_CLOSED) {
+		writel(~DMA_ENABLE & readl(cp->reg_ch_rxctrl),
+		       cp->reg_ch_rxctrl);
+	}
+	return 0;
+}
+
+/* Stop receiver (timeslot or stream mode only). */
+int etp_rx_off(unsigned device,	/* The number of the device. */
+	       unsigned channel)
+{
+	struct etp_device_private *dp;
+	struct etp_interface_private *ip;
+	struct rw_semaphore *ip_semaphore;
+	int error;
+	if (unlikely(device >= etp_number || channel >= INTERFACES_PER_DEVICE))
+		return -ENXIO;
+	dp = get_dev_priv(device);
+	ip = &dp->interface_privates[channel];
+	ip_semaphore = &ip->semaphore;
+	down_write(ip_semaphore);
+	error = etp_rx_off_down(ip);
+	mmiowb();
+	up_write(ip_semaphore);
+	return 0;
+}
+
+/* Change settings of an interface. */
+int etp_if_settings(unsigned device, /* The number of the device */
+		    unsigned channel, /* The number of interface */
+		    uint32_t clock_source, /* whence the transmit clock comes */
+		    unsigned hdlc_mode,
+		    uint32_t hdlc_mode_g704_used_timeslots)
+{
+	struct etp_device_private *dp;
+	struct etp_interface_private *ip;
+	int error;
+	struct rw_semaphore *ip_semaphore;
+	if (unlikely(device >= etp_number || channel >= INTERFACES_PER_DEVICE))
+		return -ENXIO;
+	dp = get_dev_priv(device);
+	ip = &dp->interface_privates[channel];
+	ip_semaphore = &ip->semaphore;
+	down_write(ip_semaphore);
+	if (unlikely(atomic_read(&dp->reset))) {
+		error = -ENXIO;
+	} else {
+		error = etp_if_settings_down(dp, ip, clock_source, hdlc_mode,
+					     hdlc_mode_g704_used_timeslots);
+		mmiowb();
+	}
+	up_write(ip_semaphore);
+	return error;
+}
+EXPORT_SYMBOL(etp_if_settings);
+
+/* Set output clock source. */
+int etp_ext_output_clock(unsigned device, uint32_t clock_source)
+{
+	struct etp_device_private *dp;
+	int error;
+	struct rw_semaphore *ip_semaphore;
+	if (unlikely(device >= etp_number))
+		return -ENXIO;
+	dp = get_dev_priv(device);
+	ip_semaphore = &dp->interface_privates[0].semaphore;
+	down_write(ip_semaphore);
+	if (likely(!atomic_read(&dp->reset))) {
+		error = etp_ext_output_clock_down(dp, clock_source);
+		mmiowb();
+	} else {
+		error = -ENXIO;
+	}
+	up_write(ip_semaphore);
+	return error;
+}
+
+/* Fine tune local clock frequency. */
+int etp_nco_adjust(unsigned device, uint32_t nco_addend_value)
+{
+	struct etp_device_private *dp;
+	struct mutex *mutex;
+	int error;
+	if (unlikely(device >= etp_number))
+		return -ENXIO;
+	dp = get_dev_priv(device);
+	mutex = &dp->mutex;
+	mutex_lock(mutex);
+	if (unlikely(atomic_read(&dp->reset))) {
+		error = -ENXIO;
+	} else {
+		etp_nco_adjust_down(dp, nco_addend_value);
+		error = 0;
+		mmiowb();
+	}
+	mutex_unlock(mutex);
+	return error;
+}
--- linux-2.6.27-rc6/drivers/net/wan/syncppp.c	1970-01-01
02:00:00.000000000 +0200
+++ linux-2.6.27-rc6-next-20080919/drivers/net/wan/syncppp.c	2008-10-02
08:43:04.200251188 +0300
@@ -0,0 +1,1488 @@
+/*
+ *	NET3:	A (fairly minimal) implementation of synchronous PPP for Linux
+ *		as well as a CISCO HDLC implementation. See the copyright
+ *		message below for the original source.
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the license, or (at your option) any later version.
+ *
+ *	Note however. This code is also used in a different form by FreeBSD.
+ *	Therefore when making any non OS specific change please consider
+ *	contributing it back to the original author under the terms
+ *	below in addition.
+ *		-- Alan
+ *
+ *	Port for Linux-2.1 by Jan "Yenya" Kasprzak <kas@fi.muni.cz>
+ */
+
+/*
+ * Synchronous PPP/Cisco link level subroutines.
+ * Keepalive protocol implemented in both Cisco and PPP modes.
+ *
+ * Copyright (C) 1994 Cronyx Ltd.
+ * Author: Serge Vakulenko, <vak@zebub.msk.su>
+ *
+ * This software is distributed with NO WARRANTIES, not even the implied
+ * warranties for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ * Authors grant any other persons or organisations permission to use
+ * or modify this software as long as this message is kept with the software,
+ * all derivative works or modified versions.
+ *
+ * Version 1.9, Wed Oct  4 18:58:15 MSK 1995
+ *
+ * $Id: syncppp.c,v 1.18 2000/04/11 05:25:31 asj Exp $
+ */
+#undef DEBUG
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/if_arp.h>
+#include <linux/skbuff.h>
+#include <linux/route.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/random.h>
+#include <linux/pkt_sched.h>
+#include <linux/spinlock.h>
+#include <linux/rcupdate.h>
+
+#include <net/net_namespace.h>
+#include <net/syncppp.h>
+
+#include <asm/byteorder.h>
+#include <asm/uaccess.h>
+
+#define MAXALIVECNT     6               /* max. alive packets */
+
+#define PPP_ALLSTATIONS 0xff            /* All-Stations broadcast address */
+#define PPP_UI          0x03            /* Unnumbered Information */
+#define PPP_IP          0x0021          /* Internet Protocol */
+#define PPP_ISO         0x0023          /* ISO OSI Protocol */
+#define PPP_XNS         0x0025          /* Xerox NS Protocol */
+#define PPP_IPX         0x002b          /* Novell IPX Protocol */
+#define PPP_LCP         0xc021          /* Link Control Protocol */
+#define PPP_IPCP        0x8021          /* Internet Protocol Control
Protocol */
+
+#define LCP_CONF_REQ    1               /* PPP LCP configure request */
+#define LCP_CONF_ACK    2               /* PPP LCP configure acknowledge */
+#define LCP_CONF_NAK    3               /* PPP LCP configure negative ack */
+#define LCP_CONF_REJ    4               /* PPP LCP configure reject */
+#define LCP_TERM_REQ    5               /* PPP LCP terminate request */
+#define LCP_TERM_ACK    6               /* PPP LCP terminate acknowledge */
+#define LCP_CODE_REJ    7               /* PPP LCP code reject */
+#define LCP_PROTO_REJ   8               /* PPP LCP protocol reject */
+#define LCP_ECHO_REQ    9               /* PPP LCP echo request */
+#define LCP_ECHO_REPLY  10              /* PPP LCP echo reply */
+#define LCP_DISC_REQ    11              /* PPP LCP discard request */
+
+#define LCP_OPT_MRU             1       /* maximum receive unit */
+#define LCP_OPT_ASYNC_MAP       2       /* async control character map */
+#define LCP_OPT_AUTH_PROTO      3       /* authentication protocol */
+#define LCP_OPT_QUAL_PROTO      4       /* quality protocol */
+#define LCP_OPT_MAGIC           5       /* magic number */
+#define LCP_OPT_RESERVED        6       /* reserved */
+#define LCP_OPT_PROTO_COMP      7       /* protocol field compression */
+#define LCP_OPT_ADDR_COMP       8       /* address/control field compression */
+
+#define IPCP_CONF_REQ   LCP_CONF_REQ    /* PPP IPCP configure request */
+#define IPCP_CONF_ACK   LCP_CONF_ACK    /* PPP IPCP configure acknowledge */
+#define IPCP_CONF_NAK   LCP_CONF_NAK    /* PPP IPCP configure negative ack */
+#define IPCP_CONF_REJ   LCP_CONF_REJ    /* PPP IPCP configure reject */
+#define IPCP_TERM_REQ   LCP_TERM_REQ    /* PPP IPCP terminate request */
+#define IPCP_TERM_ACK   LCP_TERM_ACK    /* PPP IPCP terminate acknowledge */
+#define IPCP_CODE_REJ   LCP_CODE_REJ    /* PPP IPCP code reject */
+
+#define CISCO_MULTICAST         0x8f    /* Cisco multicast address */
+#define CISCO_UNICAST           0x0f    /* Cisco unicast address */
+#define CISCO_KEEPALIVE         0x8035  /* Cisco keepalive protocol */
+#define CISCO_ADDR_REQ          0       /* Cisco address request */
+#define CISCO_ADDR_REPLY        1       /* Cisco address reply */
+#define CISCO_KEEPALIVE_REQ     2       /* Cisco keepalive request */
+
+struct ppp_header {
+	u8 address;
+	u8 control;
+	__be16 protocol;
+};
+#define PPP_HEADER_LEN          sizeof (struct ppp_header)
+
+struct lcp_header {
+	u8 type;
+	u8 ident;
+	__be16 len;
+};
+#define LCP_HEADER_LEN          sizeof (struct lcp_header)
+
+struct cisco_packet {
+	__be32 type;
+	__be32 par1;
+	__be32 par2;
+	__be16 rel;
+	__be16 time0;
+	__be16 time1;
+};
+#define CISCO_PACKET_LEN 18
+#define CISCO_BIG_PACKET_LEN 20
+
+static struct sppp *spppq;
+static struct timer_list sppp_keepalive_timer;
+static DEFINE_SPINLOCK(spppq_lock);
+
+/* global xmit queue for sending packets while spinlock is held */
+static struct sk_buff_head tx_queue;
+
+static void sppp_keepalive (unsigned long dummy);
+static void sppp_cp_send (struct sppp *sp, u16 proto, u8 type,
+	u8 ident, u16 len, void *data);
+static void sppp_cisco_send (struct sppp *sp, int type, u32 par1, u32 par2);
+static void sppp_lcp_input (struct sppp *sp, struct sk_buff *m);
+static void sppp_cisco_input (struct sppp *sp, struct sk_buff *m);
+static void sppp_ipcp_input (struct sppp *sp, struct sk_buff *m);
+static void sppp_lcp_open (struct sppp *sp);
+static void sppp_ipcp_open (struct sppp *sp);
+static int sppp_lcp_conf_parse_options (struct sppp *sp, struct lcp_header *h,
+	int len, u32 *magic);
+static void sppp_cp_timeout (unsigned long arg);
+static char *sppp_lcp_type_name (u8 type);
+static char *sppp_ipcp_type_name (u8 type);
+static void sppp_print_bytes (u8 *p, u16 len);
+
+static int debug;
+
+/* Flush global outgoing packet queue to dev_queue_xmit().
+ *
+ * dev_queue_xmit() must be called with interrupts enabled
+ * which means it can't be called with spinlocks held.
+ * If a packet needs to be sent while a spinlock is held,
+ * then put the packet into tx_queue, and call sppp_flush_xmit()
+ * after spinlock is released.
+ */
+static void sppp_flush_xmit(void)
+{
+	struct sk_buff *skb;
+	while ((skb = skb_dequeue(&tx_queue)) != NULL)
+		dev_queue_xmit(skb);
+}
+
+/*
+ *	Interface down stub
+ */	
+
+static void if_down(struct net_device *dev)
+{
+	struct sppp *sp = (struct sppp *)sppp_of(dev);
+
+	sp->pp_link_state=SPPP_LINK_DOWN;
+}
+
+/*
+ * Timeout routine activations.
+ */
+
+static void sppp_set_timeout(struct sppp *p,int s)
+{
+	if (! (p->pp_flags & PP_TIMO))
+	{
+		init_timer(&p->pp_timer);
+		p->pp_timer.function=sppp_cp_timeout;
+		p->pp_timer.expires=jiffies+s*HZ;
+		p->pp_timer.data=(unsigned long)p;
+		p->pp_flags |= PP_TIMO;
+		add_timer(&p->pp_timer);
+	}
+}
+
+static void sppp_clear_timeout(struct sppp *p)
+{
+	if (p->pp_flags & PP_TIMO)
+	{
+		del_timer(&p->pp_timer);
+		p->pp_flags &= ~PP_TIMO;
+	}
+}
+
+/**
+ *	sppp_input -	receive and process a WAN PPP frame
+ *	@skb:	The buffer to process
+ *	@dev:	The device it arrived on
+ *
+ *	This can be called directly by cards that do not have
+ *	timing constraints but is normally called from the network layer
+ *	after interrupt servicing to process frames queued via netif_rx().
+ *
+ *	We process the options in the card. If the frame is destined for
+ *	the protocol stacks then it requeues the frame for the upper level
+ *	protocol. If it is a control from it is processed and discarded
+ *	here.
+ */
+
+static void sppp_input (struct net_device *dev, struct sk_buff *skb)
+{
+	struct ppp_header *h;
+	struct sppp *sp = (struct sppp *)sppp_of(dev);
+	unsigned long flags;
+
+	skb->dev=dev;
+	skb_reset_mac_header(skb);
+
+	if (dev->flags & IFF_RUNNING)
+	{
+		/* Count received bytes, add FCS and one flag */
+		sp->ibytes+= skb->len + 3;
+		sp->ipkts++;
+	}
+
+	if (!pskb_may_pull(skb, PPP_HEADER_LEN)) {
+		/* Too small packet, drop it. */
+		if (sp->pp_flags & PP_DEBUG)
+			printk (KERN_DEBUG "%s: input packet is too small, %d bytes\n",
+				dev->name, skb->len);
+		kfree_skb(skb);
+		return;
+	}
+
+	/* Get PPP header. */
+	h = (struct ppp_header *)skb->data;
+	skb_pull(skb,sizeof(struct ppp_header));
+
+	spin_lock_irqsave(&sp->lock, flags);
+	
+	switch (h->address) {
+	default:        /* Invalid PPP packet. */
+		goto invalid;
+	case PPP_ALLSTATIONS:
+		if (h->control != PPP_UI)
+			goto invalid;
+		if (sp->pp_flags & PP_CISCO) {
+			if (sp->pp_flags & PP_DEBUG)
+				printk (KERN_WARNING "%s: PPP packet in Cisco mode <0x%x 0x%x 0x%x>\n",
+					dev->name,
+					h->address, h->control, ntohs (h->protocol));
+			goto drop;
+		}
+		switch (ntohs (h->protocol)) {
+		default:
+			if (sp->lcp.state == LCP_STATE_OPENED)
+				sppp_cp_send (sp, PPP_LCP, LCP_PROTO_REJ,
+					++sp->pp_seq, skb->len + 2,
+					&h->protocol);
+			if (sp->pp_flags & PP_DEBUG)
+				printk (KERN_WARNING "%s: invalid input protocol <0x%x 0x%x 0x%x>\n",
+					dev->name,
+					h->address, h->control, ntohs (h->protocol));
+			goto drop;
+		case PPP_LCP:
+			sppp_lcp_input (sp, skb);
+			goto drop;
+		case PPP_IPCP:
+			if (sp->lcp.state == LCP_STATE_OPENED)
+				sppp_ipcp_input (sp, skb);
+			else
+				printk(KERN_DEBUG "IPCP when still waiting LCP finish.\n");
+			goto drop;
+		case PPP_IP:
+			if (sp->ipcp.state == IPCP_STATE_OPENED) {
+				if(sp->pp_flags&PP_DEBUG)
+					printk(KERN_DEBUG "Yow an IP frame.\n");
+				skb->protocol=htons(ETH_P_IP);
+				netif_rx(skb);
+				dev->last_rx = jiffies;
+				goto done;
+			}
+			break;
+#ifdef IPX
+		case PPP_IPX:
+			/* IPX IPXCP not implemented yet */
+			if (sp->lcp.state == LCP_STATE_OPENED) {
+				skb->protocol=htons(ETH_P_IPX);
+				netif_rx(skb);
+				dev->last_rx = jiffies;
+				goto done;
+			}
+			break;
+#endif
+		}
+		break;
+	case CISCO_MULTICAST:
+	case CISCO_UNICAST:
+		/* Don't check the control field here (RFC 1547). */
+		if (! (sp->pp_flags & PP_CISCO)) {
+			if (sp->pp_flags & PP_DEBUG)
+				printk (KERN_WARNING "%s: Cisco packet in PPP mode <0x%x 0x%x 0x%x>\n",
+					dev->name,
+					h->address, h->control, ntohs (h->protocol));
+			goto drop;
+		}
+		switch (ntohs (h->protocol)) {
+		default:
+			goto invalid;
+		case CISCO_KEEPALIVE:
+			sppp_cisco_input (sp, skb);
+			goto drop;
+#ifdef CONFIG_INET
+		case ETH_P_IP:
+			skb->protocol=htons(ETH_P_IP);
+			netif_rx(skb);
+			dev->last_rx = jiffies;
+			goto done;
+#endif
+#ifdef CONFIG_IPX
+		case ETH_P_IPX:
+			skb->protocol=htons(ETH_P_IPX);
+			netif_rx(skb);
+			dev->last_rx = jiffies;
+			goto done;
+#endif
+		}
+		break;
+	}
+	goto drop;
+
+invalid:
+	if (sp->pp_flags & PP_DEBUG)
+		printk (KERN_WARNING "%s: invalid input packet <0x%x 0x%x 0x%x>\n",
+			dev->name, h->address, h->control, ntohs (h->protocol));
+drop:
+	kfree_skb(skb);
+done:
+	spin_unlock_irqrestore(&sp->lock, flags);
+	sppp_flush_xmit();
+	return;
+}
+
+/*
+ *	Handle transmit packets.
+ */
+
+static int sppp_hard_header(struct sk_buff *skb,
+			    struct net_device *dev, __u16 type,
+			    const void *daddr, const void *saddr,
+			    unsigned int len)
+{
+	struct sppp *sp = (struct sppp *)sppp_of(dev);
+	struct ppp_header *h;
+	skb_push(skb,sizeof(struct ppp_header));
+	h=(struct ppp_header *)skb->data;
+	if(sp->pp_flags&PP_CISCO)
+	{
+		h->address = CISCO_UNICAST;
+		h->control = 0;
+	}
+	else
+	{
+		h->address = PPP_ALLSTATIONS;
+		h->control = PPP_UI;
+	}
+	if(sp->pp_flags & PP_CISCO)
+	{
+		h->protocol = htons(type);
+	}
+	else switch(type)
+	{
+		case ETH_P_IP:
+			h->protocol = htons(PPP_IP);
+			break;
+		case ETH_P_IPX:
+			h->protocol = htons(PPP_IPX);
+			break;
+	}
+	return sizeof(struct ppp_header);
+}
+
+static const struct header_ops sppp_header_ops = {
+	.create = sppp_hard_header,
+};
+
+/*
+ * Send keepalive packets, every 10 seconds.
+ */
+
+static void sppp_keepalive (unsigned long dummy)
+{
+	struct sppp *sp;
+	unsigned long flags;
+
+	spin_lock_irqsave(&spppq_lock, flags);
+
+	for (sp=spppq; sp; sp=sp->pp_next)
+	{
+		struct net_device *dev = sp->pp_if;
+
+		/* Keepalive mode disabled or channel down? */
+		if (! (sp->pp_flags & PP_KEEPALIVE) ||
+		    ! (dev->flags & IFF_UP))
+			continue;
+
+		spin_lock(&sp->lock);
+
+		/* No keepalive in PPP mode if LCP not opened yet. */
+		if (! (sp->pp_flags & PP_CISCO) &&
+		    sp->lcp.state != LCP_STATE_OPENED) {
+			spin_unlock(&sp->lock);
+			continue;
+		}
+
+		if (sp->pp_alivecnt == MAXALIVECNT) {
+			/* No keepalive packets got.  Stop the interface. */
+			printk (KERN_WARNING "%s: protocol down\n", dev->name);
+			if_down (dev);
+			if (! (sp->pp_flags & PP_CISCO)) {
+				/* Shut down the PPP link. */
+				sp->lcp.magic = jiffies;
+				sp->lcp.state = LCP_STATE_CLOSED;
+				sp->ipcp.state = IPCP_STATE_CLOSED;
+				sppp_clear_timeout (sp);
+				/* Initiate negotiation. */
+				sppp_lcp_open (sp);
+			}
+		}
+		if (sp->pp_alivecnt <= MAXALIVECNT)
+			++sp->pp_alivecnt;
+		if (sp->pp_flags & PP_CISCO)
+			sppp_cisco_send (sp, CISCO_KEEPALIVE_REQ, ++sp->pp_seq,
+				sp->pp_rseq);
+		else if (sp->lcp.state == LCP_STATE_OPENED) {
+			__be32 nmagic = htonl (sp->lcp.magic);
+			sp->lcp.echoid = ++sp->pp_seq;
+			sppp_cp_send (sp, PPP_LCP, LCP_ECHO_REQ,
+				sp->lcp.echoid, 4, &nmagic);
+		}
+
+		spin_unlock(&sp->lock);
+	}
+	spin_unlock_irqrestore(&spppq_lock, flags);
+	sppp_flush_xmit();
+	sppp_keepalive_timer.expires=jiffies+10*HZ;
+	add_timer(&sppp_keepalive_timer);
+}
+
+/*
+ * Handle incoming PPP Link Control Protocol packets.
+ */
+
+static void sppp_lcp_input (struct sppp *sp, struct sk_buff *skb)
+{
+	struct lcp_header *h;
+	struct net_device *dev = sp->pp_if;
+	int len = skb->len;
+	u8 *p, opt[6];
+	u32 rmagic = 0;
+
+	if (!pskb_may_pull(skb, sizeof(struct lcp_header))) {
+		if (sp->pp_flags & PP_DEBUG)
+			printk (KERN_WARNING "%s: invalid lcp packet length: %d bytes\n",
+				dev->name, len);
+		return;
+	}
+	h = (struct lcp_header *)skb->data;
+	skb_pull(skb,sizeof(struct lcp_header *));
+	
+	if (sp->pp_flags & PP_DEBUG)
+	{
+		char state = '?';
+		switch (sp->lcp.state) {
+		case LCP_STATE_CLOSED:   state = 'C'; break;
+		case LCP_STATE_ACK_RCVD: state = 'R'; break;
+		case LCP_STATE_ACK_SENT: state = 'S'; break;
+		case LCP_STATE_OPENED:   state = 'O'; break;
+		}
+		printk (KERN_WARNING "%s: lcp input(%c): %d bytes <%s id=%xh len=%xh",
+			dev->name, state, len,
+			sppp_lcp_type_name (h->type), h->ident, ntohs (h->len));
+		if (len > 4)
+			sppp_print_bytes ((u8*) (h+1), len-4);
+		printk (">\n");
+	}
+	if (len > ntohs (h->len))
+		len = ntohs (h->len);
+	switch (h->type) {
+	default:
+		/* Unknown packet type -- send Code-Reject packet. */
+		sppp_cp_send (sp, PPP_LCP, LCP_CODE_REJ, ++sp->pp_seq,
+			skb->len, h);
+		break;
+	case LCP_CONF_REQ:
+		if (len < 4) {
+			if (sp->pp_flags & PP_DEBUG)
+				printk (KERN_DEBUG"%s: invalid lcp configure request packet
length: %d bytes\n",
+					dev->name, len);
+			break;
+		}
+		if (len>4 && !sppp_lcp_conf_parse_options (sp, h, len, &rmagic))
+			goto badreq;
+		if (rmagic == sp->lcp.magic) {
+			/* Local and remote magics equal -- loopback? */
+			if (sp->pp_loopcnt >= MAXALIVECNT*5) {
+				printk (KERN_WARNING "%s: loopback\n",
+					dev->name);
+				sp->pp_loopcnt = 0;
+				if (dev->flags & IFF_UP) {
+					if_down (dev);
+				}
+			} else if (sp->pp_flags & PP_DEBUG)
+				printk (KERN_DEBUG "%s: conf req: magic glitch\n",
+					dev->name);
+			++sp->pp_loopcnt;
+
+			/* MUST send Conf-Nack packet. */
+			rmagic = ~sp->lcp.magic;
+			opt[0] = LCP_OPT_MAGIC;
+			opt[1] = sizeof (opt);
+			opt[2] = rmagic >> 24;
+			opt[3] = rmagic >> 16;
+			opt[4] = rmagic >> 8;
+			opt[5] = rmagic;
+			sppp_cp_send (sp, PPP_LCP, LCP_CONF_NAK,
+				h->ident, sizeof (opt), &opt);
+badreq:
+			switch (sp->lcp.state) {
+			case LCP_STATE_OPENED:
+				/* Initiate renegotiation. */
+				sppp_lcp_open (sp);
+				/* fall through... */
+			case LCP_STATE_ACK_SENT:
+				/* Go to closed state. */
+				sp->lcp.state = LCP_STATE_CLOSED;
+				sp->ipcp.state = IPCP_STATE_CLOSED;
+			}
+			break;
+		}
+		/* Send Configure-Ack packet. */
+		sp->pp_loopcnt = 0;
+		if (sp->lcp.state != LCP_STATE_OPENED) {
+			sppp_cp_send (sp, PPP_LCP, LCP_CONF_ACK,
+					h->ident, len-4, h+1);
+		}
+		/* Change the state. */
+		switch (sp->lcp.state) {
+		case LCP_STATE_CLOSED:
+			sp->lcp.state = LCP_STATE_ACK_SENT;
+			break;
+		case LCP_STATE_ACK_RCVD:
+			sp->lcp.state = LCP_STATE_OPENED;
+			sppp_ipcp_open (sp);
+			break;
+		case LCP_STATE_OPENED:
+			/* Remote magic changed -- close session. */
+			sp->lcp.state = LCP_STATE_CLOSED;
+			sp->ipcp.state = IPCP_STATE_CLOSED;
+			/* Initiate renegotiation. */
+			sppp_lcp_open (sp);
+			/* Send ACK after our REQ in attempt to break loop */
+			sppp_cp_send (sp, PPP_LCP, LCP_CONF_ACK,
+					h->ident, len-4, h+1);
+			sp->lcp.state = LCP_STATE_ACK_SENT;
+			break;
+		}
+		break;
+	case LCP_CONF_ACK:
+		if (h->ident != sp->lcp.confid)
+			break;
+		sppp_clear_timeout (sp);
+		if ((sp->pp_link_state != SPPP_LINK_UP) &&
+		    (dev->flags & IFF_UP)) {
+			/* Coming out of loopback mode. */
+			sp->pp_link_state=SPPP_LINK_UP;
+			printk (KERN_INFO "%s: protocol up\n", dev->name);
+		}
+		switch (sp->lcp.state) {
+		case LCP_STATE_CLOSED:
+			sp->lcp.state = LCP_STATE_ACK_RCVD;
+			sppp_set_timeout (sp, 5);
+			break;
+		case LCP_STATE_ACK_SENT:
+			sp->lcp.state = LCP_STATE_OPENED;
+			sppp_ipcp_open (sp);
+			break;
+		}
+		break;
+	case LCP_CONF_NAK:
+		if (h->ident != sp->lcp.confid)
+			break;
+		p = (u8*) (h+1);
+		if (len>=10 && p[0] == LCP_OPT_MAGIC && p[1] >= 4) {
+			rmagic = (u32)p[2] << 24 |
+				(u32)p[3] << 16 | p[4] << 8 | p[5];
+			if (rmagic == ~sp->lcp.magic) {
+				int newmagic;
+				if (sp->pp_flags & PP_DEBUG)
+					printk (KERN_DEBUG "%s: conf nak: magic glitch\n",
+						dev->name);
+				get_random_bytes(&newmagic, sizeof(newmagic));
+				sp->lcp.magic += newmagic;
+			} else
+				sp->lcp.magic = rmagic;
+			}
+		if (sp->lcp.state != LCP_STATE_ACK_SENT) {
+			/* Go to closed state. */
+			sp->lcp.state = LCP_STATE_CLOSED;
+			sp->ipcp.state = IPCP_STATE_CLOSED;
+		}
+		/* The link will be renegotiated after timeout,
+		 * to avoid endless req-nack loop. */
+		sppp_clear_timeout (sp);
+		sppp_set_timeout (sp, 2);
+		break;
+	case LCP_CONF_REJ:
+		if (h->ident != sp->lcp.confid)
+			break;
+		sppp_clear_timeout (sp);
+		/* Initiate renegotiation. */
+		sppp_lcp_open (sp);
+		if (sp->lcp.state != LCP_STATE_ACK_SENT) {
+			/* Go to closed state. */
+			sp->lcp.state = LCP_STATE_CLOSED;
+			sp->ipcp.state = IPCP_STATE_CLOSED;
+		}
+		break;
+	case LCP_TERM_REQ:
+		sppp_clear_timeout (sp);
+		/* Send Terminate-Ack packet. */
+		sppp_cp_send (sp, PPP_LCP, LCP_TERM_ACK, h->ident, 0, NULL);
+		/* Go to closed state. */
+		sp->lcp.state = LCP_STATE_CLOSED;
+		sp->ipcp.state = IPCP_STATE_CLOSED;
+		/* Initiate renegotiation. */
+		sppp_lcp_open (sp);
+		break;
+	case LCP_TERM_ACK:
+	case LCP_CODE_REJ:
+	case LCP_PROTO_REJ:
+		/* Ignore for now. */
+		break;
+	case LCP_DISC_REQ:
+		/* Discard the packet. */
+		break;
+	case LCP_ECHO_REQ:
+		if (sp->lcp.state != LCP_STATE_OPENED)
+			break;
+		if (len < 8) {
+			if (sp->pp_flags & PP_DEBUG)
+				printk (KERN_WARNING "%s: invalid lcp echo request packet length:
%d bytes\n",
+					dev->name, len);
+			break;
+		}
+		if (ntohl (*(__be32*)(h+1)) == sp->lcp.magic) {
+			/* Line loopback mode detected. */
+			printk (KERN_WARNING "%s: loopback\n", dev->name);
+			if_down (dev);
+
+			/* Shut down the PPP link. */
+			sp->lcp.state = LCP_STATE_CLOSED;
+			sp->ipcp.state = IPCP_STATE_CLOSED;
+			sppp_clear_timeout (sp);
+			/* Initiate negotiation. */
+			sppp_lcp_open (sp);
+			break;
+		}
+		*(__be32 *)(h+1) = htonl (sp->lcp.magic);
+		sppp_cp_send (sp, PPP_LCP, LCP_ECHO_REPLY, h->ident, len-4, h+1);
+		break;
+	case LCP_ECHO_REPLY:
+		if (h->ident != sp->lcp.echoid)
+			break;
+		if (len < 8) {
+			if (sp->pp_flags & PP_DEBUG)
+				printk (KERN_WARNING "%s: invalid lcp echo reply packet length:
%d bytes\n",
+					dev->name, len);
+			break;
+		}
+		if (ntohl(*(__be32 *)(h+1)) != sp->lcp.magic)
+		sp->pp_alivecnt = 0;
+		break;
+	}
+}
+
+/*
+ * Handle incoming Cisco keepalive protocol packets.
+ */
+
+static void sppp_cisco_input (struct sppp *sp, struct sk_buff *skb)
+{
+	struct cisco_packet *h;
+	struct net_device *dev = sp->pp_if;
+
+	if (!pskb_may_pull(skb, sizeof(struct cisco_packet))
+	    || (skb->len != CISCO_PACKET_LEN
+		&& skb->len != CISCO_BIG_PACKET_LEN)) {
+		if (sp->pp_flags & PP_DEBUG)
+			printk (KERN_WARNING "%s: invalid cisco packet length: %d bytes\n",
+				dev->name,  skb->len);
+		return;
+	}
+	h = (struct cisco_packet *)skb->data;
+	skb_pull(skb, sizeof(struct cisco_packet*));
+	if (sp->pp_flags & PP_DEBUG)
+		printk (KERN_WARNING "%s: cisco input: %d bytes <%xh %xh %xh %xh %xh-%xh>\n",
+			dev->name,  skb->len,
+			ntohl (h->type), h->par1, h->par2, h->rel,
+			h->time0, h->time1);
+	switch (ntohl (h->type)) {
+	default:
+		if (sp->pp_flags & PP_DEBUG)
+			printk (KERN_WARNING "%s: unknown cisco packet type: 0x%x\n",
+				dev->name,  ntohl (h->type));
+		break;
+	case CISCO_ADDR_REPLY:
+		/* Reply on address request, ignore */
+		break;
+	case CISCO_KEEPALIVE_REQ:
+		sp->pp_alivecnt = 0;
+		sp->pp_rseq = ntohl (h->par1);
+		if (sp->pp_seq == sp->pp_rseq) {
+			/* Local and remote sequence numbers are equal.
+			 * Probably, the line is in loopback mode. */
+			int newseq;
+			if (sp->pp_loopcnt >= MAXALIVECNT) {
+				printk (KERN_WARNING "%s: loopback\n",
+					dev->name);
+				sp->pp_loopcnt = 0;
+				if (dev->flags & IFF_UP) {
+					if_down (dev);
+				}
+			}
+			++sp->pp_loopcnt;
+
+			/* Generate new local sequence number */
+			get_random_bytes(&newseq, sizeof(newseq));
+			sp->pp_seq ^= newseq;
+			break;
+		}
+		sp->pp_loopcnt = 0;
+		if (sp->pp_link_state==SPPP_LINK_DOWN &&
+		    (dev->flags & IFF_UP)) {
+			sp->pp_link_state=SPPP_LINK_UP;
+			printk (KERN_INFO "%s: protocol up\n", dev->name);
+		}
+		break;
+	case CISCO_ADDR_REQ:
+		/* Stolen from net/ipv4/devinet.c -- SIOCGIFADDR ioctl */
+		{
+		struct in_device *in_dev;
+		struct in_ifaddr *ifa;
+		__be32 addr = 0, mask = htonl(~0U); /* FIXME: is the mask correct? */
+#ifdef CONFIG_INET
+		rcu_read_lock();
+		if ((in_dev = __in_dev_get_rcu(dev)) != NULL)
+		{
+			for (ifa=in_dev->ifa_list; ifa != NULL;
+				ifa=ifa->ifa_next) {
+				if (strcmp(dev->name, ifa->ifa_label) == 0)
+				{
+					addr = ifa->ifa_local;
+					mask = ifa->ifa_mask;
+					break;
+				}
+			}
+		}
+		rcu_read_unlock();
+#endif		
+		sppp_cisco_send (sp, CISCO_ADDR_REPLY, ntohl(addr), ntohl(mask));
+		break;
+		}
+	}
+}
+
+
+/*
+ * Send PPP LCP packet.
+ */
+
+static void sppp_cp_send (struct sppp *sp, u16 proto, u8 type,
+	u8 ident, u16 len, void *data)
+{
+	struct ppp_header *h;
+	struct lcp_header *lh;
+	struct sk_buff *skb;
+	struct net_device *dev = sp->pp_if;
+
+	skb=alloc_skb(dev->hard_header_len+PPP_HEADER_LEN+LCP_HEADER_LEN+len,
+		GFP_ATOMIC);
+	if (skb==NULL)
+		return;
+
+	skb_reserve(skb,dev->hard_header_len);
+	
+	h = (struct ppp_header *)skb_put(skb, sizeof(struct ppp_header));
+	h->address = PPP_ALLSTATIONS;        /* broadcast address */
+	h->control = PPP_UI;                 /* Unnumbered Info */
+	h->protocol = htons (proto);         /* Link Control Protocol */
+
+	lh = (struct lcp_header *)skb_put(skb, sizeof(struct lcp_header));
+	lh->type = type;
+	lh->ident = ident;
+	lh->len = htons (LCP_HEADER_LEN + len);
+
+	if (len)
+		memcpy(skb_put(skb,len),data, len);
+
+	if (sp->pp_flags & PP_DEBUG) {
+		printk (KERN_WARNING "%s: %s output <%s id=%xh len=%xh",
+			dev->name,
+			proto==PPP_LCP ? "lcp" : "ipcp",
+			proto==PPP_LCP ? sppp_lcp_type_name (lh->type) :
+			sppp_ipcp_type_name (lh->type), lh->ident,
+			ntohs (lh->len));
+		if (len)
+			sppp_print_bytes ((u8*) (lh+1), len);
+		printk (">\n");
+	}
+	sp->obytes += skb->len;
+	/* Control is high priority so it doesn't get queued behind data */
+	skb->priority=TC_PRIO_CONTROL;
+	skb->dev = dev;
+	skb_queue_tail(&tx_queue, skb);
+}
+
+/*
+ * Send Cisco keepalive packet.
+ */
+
+static void sppp_cisco_send (struct sppp *sp, int type, u32 par1, u32 par2)
+{
+	struct ppp_header *h;
+	struct cisco_packet *ch;
+	struct sk_buff *skb;
+	struct net_device *dev = sp->pp_if;
+	u32 t = jiffies * 1000/HZ;
+
+	skb=alloc_skb(dev->hard_header_len+PPP_HEADER_LEN+CISCO_PACKET_LEN,
+		GFP_ATOMIC);
+
+	if(skb==NULL)
+		return;
+		
+	skb_reserve(skb, dev->hard_header_len);
+	h = (struct ppp_header *)skb_put (skb, sizeof(struct ppp_header));
+	h->address = CISCO_MULTICAST;
+	h->control = 0;
+	h->protocol = htons (CISCO_KEEPALIVE);
+
+	ch = (struct cisco_packet*)skb_put(skb, CISCO_PACKET_LEN);
+	ch->type = htonl (type);
+	ch->par1 = htonl (par1);
+	ch->par2 = htonl (par2);
+	ch->rel = htons(0xffff);
+	ch->time0 = htons ((u16) (t >> 16));
+	ch->time1 = htons ((u16) t);
+
+	if (sp->pp_flags & PP_DEBUG)
+		printk (KERN_WARNING "%s: cisco output: <%xh %xh %xh %xh %xh-%xh>\n",
+			dev->name,  ntohl (ch->type), ch->par1,
+			ch->par2, ch->rel, ch->time0, ch->time1);
+	sp->obytes += skb->len;
+	skb->priority=TC_PRIO_CONTROL;
+	skb->dev = dev;
+	skb_queue_tail(&tx_queue, skb);
+}
+
+/**
+ *	sppp_close - close down a synchronous PPP or Cisco HDLC link
+ *	@dev: The network device to drop the link of
+ *
+ *	This drops the logical interface to the channel. It is not
+ *	done politely as we assume we will also be dropping DTR. Any
+ *	timeouts are killed.
+ */
+
+int sppp_close (struct net_device *dev)
+{
+	struct sppp *sp = (struct sppp *)sppp_of(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&sp->lock, flags);
+	sp->pp_link_state = SPPP_LINK_DOWN;
+	sp->lcp.state = LCP_STATE_CLOSED;
+	sp->ipcp.state = IPCP_STATE_CLOSED;
+	sppp_clear_timeout (sp);
+	spin_unlock_irqrestore(&sp->lock, flags);
+
+	return 0;
+}
+
+EXPORT_SYMBOL(sppp_close);
+
+/**
+ *	sppp_open - open a synchronous PPP or Cisco HDLC link
+ *	@dev:	Network device to activate
+ *	
+ *	Close down any existing synchronous session and commence
+ *	from scratch. In the PPP case this means negotiating LCP/IPCP
+ *	and friends, while for Cisco HDLC we simply need to start sending
+ *	keepalives
+ */
+
+int sppp_open (struct net_device *dev)
+{
+	struct sppp *sp = (struct sppp *)sppp_of(dev);
+	unsigned long flags;
+
+	sppp_close(dev);
+
+	spin_lock_irqsave(&sp->lock, flags);
+	if (!(sp->pp_flags & PP_CISCO)) {
+		sppp_lcp_open (sp);
+	}
+	sp->pp_link_state = SPPP_LINK_DOWN;
+	spin_unlock_irqrestore(&sp->lock, flags);
+	sppp_flush_xmit();
+
+	return 0;
+}
+
+EXPORT_SYMBOL(sppp_open);
+
+/**
+ *	sppp_reopen - notify of physical link loss
+ *	@dev: Device that lost the link
+ *
+ *	This function informs the synchronous protocol code that
+ *	the underlying link died (for example a carrier drop on X.21)
+ *
+ *	We increment the magic numbers to ensure that if the other end
+ *	failed to notice we will correctly start a new session. It happens
+ *	do to the nature of telco circuits is that you can lose carrier on
+ *	one endonly.
+ *
+ *	Having done this we go back to negotiating. This function may
+ *	be called from an interrupt context.
+ */
+
+int sppp_reopen (struct net_device *dev)
+{
+	struct sppp *sp = (struct sppp *)sppp_of(dev);
+	unsigned long flags;
+
+	sppp_close(dev);
+
+	spin_lock_irqsave(&sp->lock, flags);
+	if (!(sp->pp_flags & PP_CISCO))
+	{
+		sp->lcp.magic = jiffies;
+		++sp->pp_seq;
+		sp->lcp.state = LCP_STATE_CLOSED;
+		sp->ipcp.state = IPCP_STATE_CLOSED;
+		/* Give it a moment for the line to settle then go */
+		sppp_set_timeout (sp, 1);
+	}
+	sp->pp_link_state=SPPP_LINK_DOWN;
+	spin_unlock_irqrestore(&sp->lock, flags);
+
+	return 0;
+}
+
+EXPORT_SYMBOL(sppp_reopen);
+
+/**
+ *	sppp_change_mtu - Change the link MTU
+ *	@dev:	Device to change MTU on
+ *	@new_mtu: New MTU
+ *
+ *	Change the MTU on the link. This can only be called with
+ *	the link down. It returns an error if the link is up or
+ *	the mtu is out of range.
+ */
+
+static int sppp_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if(new_mtu<128||new_mtu>PPP_MTU||(dev->flags&IFF_UP))
+		return -EINVAL;
+	dev->mtu=new_mtu;
+	return 0;
+}
+
+/**
+ *	sppp_do_ioctl - Ioctl handler for ppp/hdlc
+ *	@dev: Device subject to ioctl
+ *	@ifr: Interface request block from the user
+ *	@cmd: Command that is being issued
+ *	
+ *	This function handles the ioctls that may be issued by the user
+ *	to control the settings of a PPP/HDLC link. It does both busy
+ *	and security checks. This function is intended to be wrapped by
+ *	callers who wish to add additional ioctl calls of their own.
+ */
+
+int sppp_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct sppp *sp = (struct sppp *)sppp_of(dev);
+
+	if(dev->flags&IFF_UP)
+		return -EBUSY;
+		
+	if(!capable(CAP_NET_ADMIN))
+		return -EPERM;
+	
+	switch(cmd)
+	{
+		case SPPPIOCCISCO:
+			sp->pp_flags|=PP_CISCO;
+			dev->type = ARPHRD_HDLC;
+			break;
+		case SPPPIOCPPP:
+			sp->pp_flags&=~PP_CISCO;
+			dev->type = ARPHRD_PPP;
+			break;
+		case SPPPIOCDEBUG:
+			sp->pp_flags&=~PP_DEBUG;
+			if(ifr->ifr_flags)
+				sp->pp_flags|=PP_DEBUG;
+			break;
+		case SPPPIOCGFLAGS:
+			if(copy_to_user(ifr->ifr_data, &sp->pp_flags, sizeof(sp->pp_flags)))
+				return -EFAULT;
+			break;
+		case SPPPIOCSFLAGS:
+			if(copy_from_user(&sp->pp_flags, ifr->ifr_data, sizeof(sp->pp_flags)))
+				return -EFAULT;
+			break;
+		default:
+			return -EINVAL;
+	}
+	return 0;
+}
+
+EXPORT_SYMBOL(sppp_do_ioctl);
+
+/**
+ *	sppp_attach - attach synchronous PPP/HDLC to a device
+ *	@pd:	PPP device to initialise
+ *
+ *	This initialises the PPP/HDLC support on an interface. At the
+ *	time of calling the dev element must point to the network device
+ *	that this interface is attached to. The interface should not yet
+ *	be registered.
+ */
+
+void sppp_attach(struct ppp_device *pd)
+{
+	struct net_device *dev = pd->dev;
+	struct sppp *sp = &pd->sppp;
+	unsigned long flags;
+
+	/* Make sure embedding is safe for sppp_of */
+	BUG_ON(sppp_of(dev) != sp);
+
+	spin_lock_irqsave(&spppq_lock, flags);
+	/* Initialize keepalive handler. */
+	if (! spppq)
+	{
+		init_timer(&sppp_keepalive_timer);
+		sppp_keepalive_timer.expires=jiffies+10*HZ;
+		sppp_keepalive_timer.function=sppp_keepalive;
+		add_timer(&sppp_keepalive_timer);
+	}
+	/* Insert new entry into the keepalive list. */
+	sp->pp_next = spppq;
+	spppq = sp;
+	spin_unlock_irqrestore(&spppq_lock, flags);
+
+	sp->pp_loopcnt = 0;
+	sp->pp_alivecnt = 0;
+	sp->pp_seq = 0;
+	sp->pp_rseq = 0;
+	sp->pp_flags = PP_KEEPALIVE|PP_CISCO|debug;/*PP_DEBUG;*/
+	sp->lcp.magic = 0;
+	sp->lcp.state = LCP_STATE_CLOSED;
+	sp->ipcp.state = IPCP_STATE_CLOSED;
+	sp->pp_if = dev;
+	spin_lock_init(&sp->lock);
+	
+	/*
+	 *	Device specific setup. All but interrupt handler and
+	 *	hard_start_xmit.
+	 */
+	
+	dev->header_ops = &sppp_header_ops;
+
+	dev->tx_queue_len = 10;
+	dev->type = ARPHRD_HDLC;
+	dev->addr_len = 0;
+	dev->hard_header_len = sizeof(struct ppp_header);
+	dev->mtu = PPP_MTU;
+	/*
+	 *	These 4 are callers but MUST also call sppp_ functions
+	 */
+	dev->do_ioctl = sppp_do_ioctl;
+#if 0
+	dev->get_stats = NULL;		/* Let the driver override these */
+	dev->open = sppp_open;
+	dev->stop = sppp_close;
+#endif	
+	dev->change_mtu = sppp_change_mtu;
+	dev->flags = IFF_MULTICAST|IFF_POINTOPOINT|IFF_NOARP;
+}
+
+EXPORT_SYMBOL(sppp_attach);
+
+/**
+ *	sppp_detach - release PPP resources from a device
+ *	@dev:	Network device to release
+ *
+ *	Stop and free up any PPP/HDLC resources used by this
+ *	interface. This must be called before the device is
+ *	freed.
+ */
+
+void sppp_detach (struct net_device *dev)
+{
+	struct sppp **q, *p, *sp = (struct sppp *)sppp_of(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&spppq_lock, flags);
+	/* Remove the entry from the keepalive list. */
+	for (q = &spppq; (p = *q); q = &p->pp_next)
+		if (p == sp) {
+			*q = p->pp_next;
+			break;
+		}
+
+	/* Stop keepalive handler. */
+	if (! spppq)
+		del_timer(&sppp_keepalive_timer);
+	sppp_clear_timeout (sp);
+	spin_unlock_irqrestore(&spppq_lock, flags);
+}
+
+EXPORT_SYMBOL(sppp_detach);
+
+/*
+ * Analyze the LCP Configure-Request options list
+ * for the presence of unknown options.
+ * If the request contains unknown options, build and
+ * send Configure-reject packet, containing only unknown options.
+ */
+static int
+sppp_lcp_conf_parse_options (struct sppp *sp, struct lcp_header *h,
+	int len, u32 *magic)
+{
+	u8 *buf, *r, *p;
+	int rlen;
+
+	len -= 4;
+	buf = r = kmalloc (len, GFP_ATOMIC);
+	if (! buf)
+		return (0);
+
+	p = (void*) (h+1);
+	for (rlen=0; len>1 && p[1]; len-=p[1], p+=p[1]) {
+		switch (*p) {
+		case LCP_OPT_MAGIC:
+			/* Magic number -- extract. */
+			if (len >= 6 && p[1] == 6) {
+				*magic = (u32)p[2] << 24 |
+					(u32)p[3] << 16 | p[4] << 8 | p[5];
+				continue;
+			}
+			break;
+		case LCP_OPT_ASYNC_MAP:
+			/* Async control character map -- check to be zero. */
+			if (len >= 6 && p[1] == 6 && ! p[2] && ! p[3] &&
+			    ! p[4] && ! p[5])
+				continue;
+			break;
+		case LCP_OPT_MRU:
+			/* Maximum receive unit -- always OK. */
+			continue;
+		default:
+			/* Others not supported. */
+			break;
+		}
+		/* Add the option to rejected list. */
+		memcpy(r, p, p[1]);
+		r += p[1];
+		rlen += p[1];
+	}
+	if (rlen)
+		sppp_cp_send (sp, PPP_LCP, LCP_CONF_REJ, h->ident, rlen, buf);
+	kfree(buf);
+	return (rlen == 0);
+}
+
+static void sppp_ipcp_input (struct sppp *sp, struct sk_buff *skb)
+{
+	struct lcp_header *h;
+	struct net_device *dev = sp->pp_if;
+	int len = skb->len;
+
+	if (!pskb_may_pull(skb, sizeof(struct lcp_header))) {
+		if (sp->pp_flags & PP_DEBUG)
+			printk (KERN_WARNING "%s: invalid ipcp packet length: %d bytes\n",
+				dev->name,  len);
+		return;
+	}
+	h = (struct lcp_header *)skb->data;
+	skb_pull(skb,sizeof(struct lcp_header));
+	if (sp->pp_flags & PP_DEBUG) {
+		printk (KERN_WARNING "%s: ipcp input: %d bytes <%s id=%xh len=%xh",
+			dev->name,  len,
+			sppp_ipcp_type_name (h->type), h->ident, ntohs (h->len));
+		if (len > 4)
+			sppp_print_bytes ((u8*) (h+1), len-4);
+		printk (">\n");
+	}
+	if (len > ntohs (h->len))
+		len = ntohs (h->len);
+	switch (h->type) {
+	default:
+		/* Unknown packet type -- send Code-Reject packet. */
+		sppp_cp_send (sp, PPP_IPCP, IPCP_CODE_REJ, ++sp->pp_seq, len, h);
+		break;
+	case IPCP_CONF_REQ:
+		if (len < 4) {
+			if (sp->pp_flags & PP_DEBUG)
+				printk (KERN_WARNING "%s: invalid ipcp configure request packet
length: %d bytes\n",
+					dev->name, len);
+			return;
+		}
+		if (len > 4) {
+			sppp_cp_send (sp, PPP_IPCP, LCP_CONF_REJ, h->ident,
+				len-4, h+1);
+
+			switch (sp->ipcp.state) {
+			case IPCP_STATE_OPENED:
+				/* Initiate renegotiation. */
+				sppp_ipcp_open (sp);
+				/* fall through... */
+			case IPCP_STATE_ACK_SENT:
+				/* Go to closed state. */
+				sp->ipcp.state = IPCP_STATE_CLOSED;
+			}
+		} else {
+			/* Send Configure-Ack packet. */
+			sppp_cp_send (sp, PPP_IPCP, IPCP_CONF_ACK, h->ident,
+				0, NULL);
+			/* Change the state. */
+			if (sp->ipcp.state == IPCP_STATE_ACK_RCVD)
+				sp->ipcp.state = IPCP_STATE_OPENED;
+			else
+				sp->ipcp.state = IPCP_STATE_ACK_SENT;
+		}
+		break;
+	case IPCP_CONF_ACK:
+		if (h->ident != sp->ipcp.confid)
+			break;
+		sppp_clear_timeout (sp);
+		switch (sp->ipcp.state) {
+		case IPCP_STATE_CLOSED:
+			sp->ipcp.state = IPCP_STATE_ACK_RCVD;
+			sppp_set_timeout (sp, 5);
+			break;
+		case IPCP_STATE_ACK_SENT:
+			sp->ipcp.state = IPCP_STATE_OPENED;
+			break;
+		}
+		break;
+	case IPCP_CONF_NAK:
+	case IPCP_CONF_REJ:
+		if (h->ident != sp->ipcp.confid)
+			break;
+		sppp_clear_timeout (sp);
+			/* Initiate renegotiation. */
+		sppp_ipcp_open (sp);
+		if (sp->ipcp.state != IPCP_STATE_ACK_SENT)
+			/* Go to closed state. */
+			sp->ipcp.state = IPCP_STATE_CLOSED;
+		break;
+	case IPCP_TERM_REQ:
+		/* Send Terminate-Ack packet. */
+		sppp_cp_send (sp, PPP_IPCP, IPCP_TERM_ACK, h->ident, 0, NULL);
+		/* Go to closed state. */
+		sp->ipcp.state = IPCP_STATE_CLOSED;
+		/* Initiate renegotiation. */
+		sppp_ipcp_open (sp);
+		break;
+	case IPCP_TERM_ACK:
+		/* Ignore for now. */
+	case IPCP_CODE_REJ:
+		/* Ignore for now. */
+		break;
+	}
+}
+
+static void sppp_lcp_open (struct sppp *sp)
+{
+	char opt[6];
+
+	if (! sp->lcp.magic)
+		sp->lcp.magic = jiffies;
+	opt[0] = LCP_OPT_MAGIC;
+	opt[1] = sizeof (opt);
+	opt[2] = sp->lcp.magic >> 24;
+	opt[3] = sp->lcp.magic >> 16;
+	opt[4] = sp->lcp.magic >> 8;
+	opt[5] = sp->lcp.magic;
+	sp->lcp.confid = ++sp->pp_seq;
+	sppp_cp_send (sp, PPP_LCP, LCP_CONF_REQ, sp->lcp.confid,
+		sizeof (opt), &opt);
+	sppp_set_timeout (sp, 2);
+}
+
+static void sppp_ipcp_open (struct sppp *sp)
+{
+	sp->ipcp.confid = ++sp->pp_seq;
+	sppp_cp_send (sp, PPP_IPCP, IPCP_CONF_REQ, sp->ipcp.confid, 0, NULL);
+	sppp_set_timeout (sp, 2);
+}
+
+/*
+ * Process PPP control protocol timeouts.
+ */
+
+static void sppp_cp_timeout (unsigned long arg)
+{
+	struct sppp *sp = (struct sppp*) arg;
+	unsigned long flags;
+
+	spin_lock_irqsave(&sp->lock, flags);
+
+	sp->pp_flags &= ~PP_TIMO;
+	if (! (sp->pp_if->flags & IFF_UP) || (sp->pp_flags & PP_CISCO)) {
+		spin_unlock_irqrestore(&sp->lock, flags);
+		return;
+	}
+	switch (sp->lcp.state) {
+	case LCP_STATE_CLOSED:
+		/* No ACK for Configure-Request, retry. */
+		sppp_lcp_open (sp);
+		break;
+	case LCP_STATE_ACK_RCVD:
+		/* ACK got, but no Configure-Request for peer, retry. */
+		sppp_lcp_open (sp);
+		sp->lcp.state = LCP_STATE_CLOSED;
+		break;
+	case LCP_STATE_ACK_SENT:
+		/* ACK sent but no ACK for Configure-Request, retry. */
+		sppp_lcp_open (sp);
+		break;
+	case LCP_STATE_OPENED:
+		/* LCP is already OK, try IPCP. */
+		switch (sp->ipcp.state) {
+		case IPCP_STATE_CLOSED:
+			/* No ACK for Configure-Request, retry. */
+			sppp_ipcp_open (sp);
+			break;
+		case IPCP_STATE_ACK_RCVD:
+			/* ACK got, but no Configure-Request for peer, retry. */
+			sppp_ipcp_open (sp);
+			sp->ipcp.state = IPCP_STATE_CLOSED;
+			break;
+		case IPCP_STATE_ACK_SENT:
+			/* ACK sent but no ACK for Configure-Request, retry. */
+			sppp_ipcp_open (sp);
+			break;
+		case IPCP_STATE_OPENED:
+			/* IPCP is OK. */
+			break;
+		}
+		break;
+	}
+	spin_unlock_irqrestore(&sp->lock, flags);
+	sppp_flush_xmit();
+}
+
+static char *sppp_lcp_type_name (u8 type)
+{
+	static char buf [8];
+	switch (type) {
+	case LCP_CONF_REQ:   return ("conf-req");
+	case LCP_CONF_ACK:   return ("conf-ack");
+	case LCP_CONF_NAK:   return ("conf-nack");
+	case LCP_CONF_REJ:   return ("conf-rej");
+	case LCP_TERM_REQ:   return ("term-req");
+	case LCP_TERM_ACK:   return ("term-ack");
+	case LCP_CODE_REJ:   return ("code-rej");
+	case LCP_PROTO_REJ:  return ("proto-rej");
+	case LCP_ECHO_REQ:   return ("echo-req");
+	case LCP_ECHO_REPLY: return ("echo-reply");
+	case LCP_DISC_REQ:   return ("discard-req");
+	}
+	sprintf (buf, "%xh", type);
+	return (buf);
+}
+
+static char *sppp_ipcp_type_name (u8 type)
+{
+	static char buf [8];
+	switch (type) {
+	case IPCP_CONF_REQ:   return ("conf-req");
+	case IPCP_CONF_ACK:   return ("conf-ack");
+	case IPCP_CONF_NAK:   return ("conf-nack");
+	case IPCP_CONF_REJ:   return ("conf-rej");
+	case IPCP_TERM_REQ:   return ("term-req");
+	case IPCP_TERM_ACK:   return ("term-ack");
+	case IPCP_CODE_REJ:   return ("code-rej");
+	}
+	sprintf (buf, "%xh", type);
+	return (buf);
+}
+
+static void sppp_print_bytes (u_char *p, u16 len)
+{
+	printk (" %x", *p++);
+	while (--len > 0)
+		printk ("-%x", *p++);
+}
+
+/**
+ *	sppp_rcv -	receive and process a WAN PPP frame
+ *	@skb:	The buffer to process
+ *	@dev:	The device it arrived on
+ *	@p: Unused
+ *	@orig_dev: Unused
+ *
+ *	Protocol glue. This drives the deferred processing mode the poorer
+ *	cards use. This can be called directly by cards that do not have
+ *	timing constraints but is normally called from the network layer
+ *	after interrupt servicing to process frames queued via netif_rx.
+ */
+
+static int sppp_rcv(struct sk_buff *skb, struct net_device *dev,
struct packet_type *p, struct net_device *orig_dev)
+{
+	if (dev_net(dev) != &init_net) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+		return NET_RX_DROP;
+	sppp_input(dev,skb);
+	return 0;
+}
+
+static struct packet_type sppp_packet_type = {
+	.type	= __constant_htons(ETH_P_WAN_PPP),
+	.func	= sppp_rcv,
+};
+
+static char banner[] __initdata =
+	KERN_INFO "Cronyx Ltd, Synchronous PPP and CISCO HDLC (c) 1994\n"
+	KERN_INFO "Linux port (c) 1998 Building Number Three Ltd & "
+		  "Jan \"Yenya\" Kasprzak.\n";
+
+static int __init sync_ppp_init(void)
+{
+	if(debug)
+		debug=PP_DEBUG;
+	printk(banner);
+	skb_queue_head_init(&tx_queue);
+	dev_add_pack(&sppp_packet_type);
+	return 0;
+}
+
+
+static void __exit sync_ppp_cleanup(void)
+{
+	dev_remove_pack(&sppp_packet_type);
+}
+
+module_init(sync_ppp_init);
+module_exit(sync_ppp_cleanup);
+module_param(debug, int, 0);
+MODULE_LICENSE("GPL");
+
--- linux-2.6.27-rc6/include/net/syncppp.h	1970-01-01 02:00:00.000000000 +0200
+++ linux-2.6.27-rc6-next-20080919/include/net/syncppp.h	2008-10-02
08:44:05.300718038 +0300
@@ -0,0 +1,104 @@
+/*
+ * Defines for synchronous PPP/Cisco link level subroutines.
+ *
+ * Copyright (C) 1994 Cronyx Ltd.
+ * Author: Serge Vakulenko, <vak@zebub.msk.su>
+ *
+ * This software is distributed with NO WARRANTIES, not even the implied
+ * warranties for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ * Authors grant any other persons or organizations permission to use
+ * or modify this software as long as this message is kept with the software,
+ * all derivative works or modified versions.
+ *
+ * Version 1.7, Wed Jun  7 22:12:02 MSD 1995
+ *
+ *
+ *
+ */
+
+#ifndef _SYNCPPP_H_
+#define _SYNCPPP_H_ 1
+
+#ifdef __KERNEL__
+struct slcp {
+	u16	state;          /* state machine */
+	u32	magic;          /* local magic number */
+	u_char	echoid;         /* id of last keepalive echo request */
+	u_char	confid;         /* id of last configuration request */
+};
+
+struct sipcp {
+	u16	state;          /* state machine */
+	u_char  confid;         /* id of last configuration request */
+};
+
+struct sppp
+{
+	struct sppp *	pp_next;	/* next interface in keepalive list */
+	u32		pp_flags;	/* use Cisco protocol instead of PPP */
+	u16		pp_alivecnt;	/* keepalive packets counter */
+	u16		pp_loopcnt;	/* loopback detection counter */
+	u32		pp_seq;		/* local sequence number */
+	u32		pp_rseq;	/* remote sequence number */
+	struct slcp	lcp;		/* LCP params */
+	struct sipcp	ipcp;		/* IPCP params */
+	u32		ibytes,obytes;	/* Bytes in/out */
+	u32		ipkts,opkts;	/* Packets in/out */
+	struct timer_list	pp_timer;
+	struct net_device	*pp_if;
+	char		pp_link_state;	/* Link status */
+	spinlock_t      lock;
+};
+
+struct ppp_device
+{	
+	struct net_device *dev;	/* Network device pointer */
+	struct sppp sppp;	/* Synchronous PPP */
+};
+
+static inline struct sppp *sppp_of(struct net_device *dev)
+{
+	struct ppp_device **ppp = dev->ml_priv;
+	BUG_ON((*ppp)->dev != dev);
+	return &(*ppp)->sppp;
+}
+
+#define PP_KEEPALIVE    0x01    /* use keepalive protocol */
+#define PP_CISCO        0x02    /* use Cisco protocol instead of PPP */
+#define PP_TIMO         0x04    /* cp_timeout routine active */
+#define PP_DEBUG	0x08
+
+#define PPP_MTU          1500    /* max. transmit unit */
+
+#define LCP_STATE_CLOSED        0       /* LCP state: closed (conf-req sent) */
+#define LCP_STATE_ACK_RCVD      1       /* LCP state: conf-ack received */
+#define LCP_STATE_ACK_SENT      2       /* LCP state: conf-ack sent */
+#define LCP_STATE_OPENED        3       /* LCP state: opened */
+
+#define IPCP_STATE_CLOSED       0       /* IPCP state: closed
(conf-req sent) */
+#define IPCP_STATE_ACK_RCVD     1       /* IPCP state: conf-ack received */
+#define IPCP_STATE_ACK_SENT     2       /* IPCP state: conf-ack sent */
+#define IPCP_STATE_OPENED       3       /* IPCP state: opened */
+
+#define SPPP_LINK_DOWN		0	/* link down - no keepalive */
+#define SPPP_LINK_UP		1	/* link is up - keepalive ok */
+
+void sppp_attach (struct ppp_device *pd);
+void sppp_detach (struct net_device *dev);
+int sppp_do_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd);
+struct sk_buff *sppp_dequeue (struct net_device *dev);
+int sppp_isempty (struct net_device *dev);
+void sppp_flush (struct net_device *dev);
+int sppp_open (struct net_device *dev);
+int sppp_reopen (struct net_device *dev);
+int sppp_close (struct net_device *dev);
+#endif
+
+#define SPPPIOCCISCO	(SIOCDEVPRIVATE)
+#define SPPPIOCPPP	(SIOCDEVPRIVATE+1)
+#define SPPPIOCDEBUG	(SIOCDEVPRIVATE+2)
+#define SPPPIOCSFLAGS	(SIOCDEVPRIVATE+3)
+#define SPPPIOCGFLAGS	(SIOCDEVPRIVATE+4)
+
+#endif /* _SYNCPPP_H_ */
