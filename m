From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: 2.6.0test8 Goramo PCI200SYN sync serial driver
Date: 19 Oct 2003 01:24:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3r81adt9r.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-=-=

Hi,

This is a 2.6.0test driver for Goramo PCI200SYN sync serial card,
a dual V.35 port PCI card.

This patch adds some defines to drivers/net/wan/hd64572.h header file,
which is then shared between Cyclades PC300 and this driver (both
cards use the same Hitachi SCA chip).

This change:
-#ifndef _HD64572_H
-#define _HD64572_H
+#ifndef __HD64572_H
+#define __HD64572_H

is required for proper detection of SCA chip version handled by
.../wan/hd6457x.c file (SCA HD64570 used by n2.c and c101.c vs
SCA-II HD64572 used by, for example, PCI200SYN).

Compiles, works. Please apply. Thanks.
-- 
Krzysztof Halasa, B*FH

--=-=-=
Content-Type: text/x-patch
Content-Disposition: attachment; filename=pci200-2.6.0test8.patch

--- linux-2.6.orig/drivers/net/wan/Makefile	2003-10-03 15:38:12.000000000 +0200
+++ linux-2.6/drivers/net/wan/Makefile	2003-10-03 16:28:07.000000000 +0200
@@ -67,6 +67,7 @@
 obj-$(CONFIG_N2)		+= n2.o
 obj-$(CONFIG_C101)		+= c101.o
 obj-$(CONFIG_WANXL)		+= wanxl.o
+obj-$(CONFIG_PCI200SYN)		+= pci200syn.o
 
 ifeq ($(CONFIG_WANXL_BUILD_FIRMWARE),y)
 ifeq ($(ARCH),m68k)
--- linux-2.6.orig/drivers/net/wan/hd64572.h	2003-08-09 06:38:50.000000000 +0200
+++ linux-2.6/drivers/net/wan/hd64572.h	2003-10-03 16:22:06.000000000 +0200
@@ -23,8 +25,8 @@
  *
  */
 
-#ifndef _HD64572_H
-#define _HD64572_H
+#ifndef __HD64572_H
+#define __HD64572_H
 
 /* Illegal Access Register */
 #define	ILAR	0x00
@@ -59,6 +61,9 @@
 #define IR0_M(val, chan)	((val)<<(8*(chan)))		/* Int MSCI */
 
 /* MSCI Channel Registers */
+#define MSCI0_OFFSET 0x00
+#define MSCI1_OFFSET 0x80
+
 #define MD0	0x138	/* Mode reg 0 */
 #define MD1	0x139	/* Mode reg 1 */
 #define MD2	0x13a	/* Mode reg 2 */
@@ -107,6 +113,11 @@
 #define RCR	0x156	/* Rx DMA Critical Request Reg */
 
 /* Timer Registers */
+#define TIMER0RX_OFFSET 0x00
+#define TIMER0TX_OFFSET 0x10
+#define TIMER1RX_OFFSET 0x20
+#define TIMER1TX_OFFSET 0x30
+
 #define TCNTL	0x200	/* Timer Upcounter L */
 #define TCNTH	0x201	/* Timer Upcounter H */
 #define TCONRL	0x204	/* Timer Constant Register L */
@@ -132,6 +144,11 @@
 #define DCR_TX(chan)	(0x59 + 2*chan)	/* DMA Command Reg (Tx) */
 
 /* DMA Channel Registers */
+#define DMAC0RX_OFFSET 0x00
+#define DMAC0TX_OFFSET 0x20
+#define DMAC1RX_OFFSET 0x40
+#define DMAC1TX_OFFSET 0x60
+
 #define DARL	0x80	/* Dest Addr Register L (single-block, RX only) */
 #define DARH	0x81	/* Dest Addr Register H (single-block, RX only) */
 #define DARB	0x82	/* Dest Addr Register B (single-block, RX only) */
@@ -166,7 +184,17 @@
 	unsigned char	filler[5];	/* alignment filler (16 bytes) */ 
 } pcsca_bd_t;
 
-/* 
+/* Block Descriptor Structure */
+typedef struct {
+	u32 cp;			/* pointer to next block descriptor */
+	u32 bp;			/* buffer pointer */
+	u16 len;		/* data length */
+	u8 stat;		/* status */
+	u8 unused;		/* pads to 4-byte boundary */
+}pkt_desc;
+
+
+/*
 	Descriptor Status definitions:
 
 	Bit	Transmission	Reception
@@ -190,6 +218,23 @@
 #define DST_SHRT	0x40	/* Short Frame  */
 #define DST_EOM		0x80	/* End of Message  */
 
+/* Packet Descriptor Status bits */
+
+#define ST_TX_EOM     0x80	/* End of frame */
+#define ST_TX_UNDRRUN 0x08
+#define ST_TX_OWNRSHP 0x02
+#define ST_TX_EOT     0x01	/* End of transmition */
+
+#define ST_RX_EOM     0x80	/* End of frame */
+#define ST_RX_SHORT   0x40	/* Short frame */
+#define ST_RX_ABORT   0x20	/* Abort */
+#define ST_RX_RESBIT  0x10	/* Residual bit */
+#define ST_RX_OVERRUN 0x08	/* Overrun */
+#define ST_RX_CRC     0x04	/* CRC */
+#define ST_RX_OWNRSHP 0x02
+
+#define ST_ERROR_MASK 0x7C
+
 /* Status Counter Registers */
 #define CMCR	0x158	/* Counter Master Ctl Reg */
 #define TECNTL	0x160	/* Tx EOM Counter L */
@@ -246,11 +291,25 @@
 #define MD0_BIT_SYNC	0x80
 #define MD0_TRANSP	0xc0
 
+#define MD0_HDLC        0x80	/* Bit-sync HDLC mode */
+
+#define MD0_CRC_NONE	0x00
+#define MD0_CRC_16_0	0x04
+#define MD0_CRC_16	0x05
+#define MD0_CRC_ITU32	0x06
+#define MD0_CRC_ITU	0x07
+
 #define MD1_NOADDR	0x00
 #define MD1_SADDR1	0x40
 #define MD1_SADDR2	0x80
 #define MD1_DADDR	0xc0
 
+#define MD2_NRZI_IEEE	0x40
+#define MD2_MANCHESTER	0x80
+#define MD2_FM_MARK	0xA0
+#define MD2_FM_SPACE	0xC0
+#define MD2_LOOPBACK	0x03	/* Local data Loopback */
+
 #define MD2_F_DUPLEX	0x00
 #define MD2_AUTO_ECHO	0x01
 #define MD2_LOOP_HI_Z	0x02
@@ -274,6 +333,10 @@
 #define CTL_URSKP	0x40
 #define CTL_URCT	0x80
 
+#define CTL_NORTS	0x01
+#define CTL_NODTR	0x02
+#define CTL_IDLE	0x10
+
 #define	RXS_BR0		0x01
 #define	RXS_BR1		0x02
 #define	RXS_BR2		0x04
@@ -302,6 +365,12 @@
 #define	EXS_TES1	0x20
 #define	EXS_TES2	0x40
 
+#define CLK_BRG_MASK	0x0F
+#define CLK_PIN_OUT	0x80
+#define CLK_LINE    	0x00	/* clock line input */
+#define CLK_BRG     	0x40	/* internal baud rate generator */
+#define CLK_TX_RXCLK	0x60	/* TX clock from RX clock */
+
 #define CMD_RX_RST	0x11
 #define CMD_RX_ENA	0x12
 #define CMD_RX_DIS	0x13
@@ -324,6 +393,10 @@
 #define CMD_SRCH_MODE	0x31
 #define CMD_NOP		0x00
 
+#define CMD_RESET	0x21
+#define CMD_TX_ENABLE	0x02
+#define CMD_RX_ENABLE	0x12
+
 #define ST0_RXRDY	0x01
 #define ST0_TXRDY	0x02
 #define ST0_RXINTB	0x20
@@ -373,7 +446,9 @@
 #define IE0_TXRDY	0x02
 #define IE0_RXINTB	0x20
 #define IE0_RXINTA	0x40
 #define IE0_TXINT	0x80
+#define IE0_UDRN	0x00008000 /* TX underrun MSCI interrupt enable */
+#define IE0_CDCD	0x00000400 /* CD level change interrupt enable */
 
 #define IE1_IDLD	0x01
 #define IE1_ABTD	0x02
@@ -424,14 +499,28 @@
 #define DIR_EOM		0x40
 #define DIR_EOT		0x80
 
+#define DIR_REFE	0x04
+#define DIR_UDRFE	0x04
+#define DIR_COAE	0x08
+#define DIR_COFE	0x10
+#define DIR_BOFE	0x20
+#define DIR_EOME	0x40
+#define DIR_EOTE	0x80
+
 #define DMR_CNTE	0x02
 #define DMR_NF		0x04
 #define DMR_SEOME	0x08
 #define DMR_TMOD	0x10
 
+#define DMER_DME        0x80	/* DMA Master Enable */
+
 #define DCR_SW_ABT	0x01
 #define DCR_FCT_CLR	0x02
 
+#define DCR_ABORT	0x01
+#define DCR_CLEAR_EOF	0x02
+
+#define PCR_COTE	0x80
 #define PCR_PR0		0x01
 #define PCR_PR1		0x02
 #define PCR_PR2		0x04
@@ -440,4 +529,4 @@
 #define PCR_OSB		0x40
 #define PCR_BURST	0x80
 
-#endif /* (_HD64572_H) */
+#endif /* (__HD64572_H) */
--- linux-2.6.orig/drivers/net/wan/pci200syn.c	2003-10-03 16:29:06.000000000 +0200
+++ linux-2.6/drivers/net/wan/pci200syn.c	2003-10-03 16:22:06.000000000 +0200
@@ -0,0 +1,458 @@
+/*
+ * Goramo PCI200SYN synchronous serial card driver for Linux
+ *
+ * Copyright (C) 2002-2003 Krzysztof Halasa <khc@pm.waw.pl>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * For information see http://hq.pm.waw.pl/hdlc/
+ *
+ * Sources of information:
+ *    Hitachi HD64572 SCA-II User's Manual
+ *    PLX Technology Inc. PCI9052 Data Book
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/sched.h>
+#include <linux/types.h>
+#include <linux/fcntl.h>
+#include <linux/in.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/ioport.h>
+#include <linux/moduleparam.h>
+#include <linux/netdevice.h>
+#include <linux/hdlc.h>
+#include <linux/pci.h>
+#include <asm/delay.h>
+#include <asm/io.h>
+
+#include "hd64572.h"
+
+static const char* version = "Goramo PCI200SYN driver version: 1.15";
+static const char* devname = "PCI200SYN";
+
+#undef DEBUG_PKT
+#define DEBUG_RINGS
+
+#define	PCI200SYN_PLX_SIZE	0x80	/* PLX control window size (128b) */
+#define	PCI200SYN_SCA_SIZE	0x400	/* SCA window size (1Kb) */
+#define ALL_PAGES_ALWAYS_MAPPED
+#define NEED_DETECT_RAM
+#define NEED_SCA_MSCI_INTR
+#define MAX_TX_BUFFERS		10
+
+static int pci_clock_freq = 33000000;
+#define CLOCK_BASE pci_clock_freq
+
+#define PCI_VENDOR_ID_GORAMO	0x10B5	/* uses PLX:9050 ID - this card	*/
+#define PCI_DEVICE_ID_PCI200SYN	0x9050	/* doesn't have its own ID	*/
+
+
+/*
+ *      PLX PCI9052 local configuration and shared runtime registers.
+ *	This structure can be used to access 9052 registers (memory mapped).
+ */
+typedef struct {
+	u32 loc_addr_range[4];	/* 00-0Ch : Local Address Ranges */
+	u32 loc_rom_range;	/* 10h : Local ROM Range */
+	u32 loc_addr_base[4];	/* 14-20h : Local Address Base Addrs */
+	u32 loc_rom_base;	/* 24h : Local ROM Base */
+	u32 loc_bus_descr[4];	/* 28-34h : Local Bus Descriptors */
+	u32 rom_bus_descr;	/* 38h : ROM Bus Descriptor */
+	u32 cs_base[4];		/* 3C-48h : Chip Select Base Addrs */
+	u32 intr_ctrl_stat;	/* 4Ch : Interrupt Control/Status */
+	u32 init_ctrl;		/* 50h : EEPROM ctrl, Init Ctrl, etc */
+}plx9052;
+
+
+
+typedef struct port_s {
+	hdlc_device hdlc;	/* HDLC device struct - must be first */
+	struct card_s *card;
+	spinlock_t lock;	/* TX lock */
+	sync_serial_settings settings;
+	int rxpart;		/* partial frame received, next frame invalid*/
+	unsigned short encoding;
+	unsigned short parity;
+	u16 rxin;		/* rx ring buffer 'in' pointer */
+	u16 txin;		/* tx ring buffer 'in' and 'last' pointers */
+	u16 txlast;
+	u8 rxs, txs, tmc;	/* SCA registers */
+	u8 phy_node;		/* physical port # - 0 or 1 */
+}port_t;
+
+
+
+typedef struct card_s {
+	u32 ramphys;		/* buffer memory base (physical) */
+	u8* rambase;		/* buffer memory base (virtual) */
+	u32 ramsize;		/* buffer memory size */
+	u32 scaphys;		/* SCA memory base (physical) */
+	u8* scabase;		/* SCA memory base (virtual) */
+	u32 plxphys;		/* PLX registers memory base (physical) */
+	plx9052* plxbase;	/* PLX registers memory base (virtual) */
+	u16 rx_ring_buffers;	/* number of buffers in a ring */
+	u16 tx_ring_buffers;
+	u16 buff_offset;	/* offset of first buffer of first channel */
+	u8 irq;			/* interrupt request level */
+
+	port_t ports[2];
+}card_t;
+
+
+#define sca_in(reg, card)	     readb(card->scabase + (reg))
+#define sca_out(value, reg, card)    writeb(value, card->scabase + (reg))
+#define sca_inw(reg, card)	     readw(card->scabase + (reg))
+#define sca_outw(value, reg, card)   writew(value, card->scabase + (reg))
+#define sca_inl(reg, card)	     readl(card->scabase + (reg))
+#define sca_outl(value, reg, card)   writel(value, card->scabase + (reg))
+
+#define port_to_card(port)	     (port->card)
+#define log_node(port)		     (port->phy_node)
+#define phy_node(port)		     (port->phy_node)
+#define winbase(card)      	     (card->rambase)
+#define get_port(card, port)	     (&card->ports[port])
+#define sca_flush(card)		     (sca_in(IER0, card));
+
+static inline void new_memcpy_toio(char *dest, char *src, int length)
+{
+	int len;
+	do {
+		len = length > 256 ? 256 : length;
+		memcpy_toio(dest, src, len);
+		dest += len;
+		src += len;
+		length -= len;
+		readb(dest);
+	} while (len);
+}
+
+#undef memcpy_toio
+#define memcpy_toio new_memcpy_toio
+
+#include "hd6457x.c"
+
+
+static void pci200_set_iface(port_t *port)
+{
+	card_t *card = port->card;
+	u16 msci = get_msci(port);
+	u8 rxs = port->rxs & CLK_BRG_MASK;
+	u8 txs = port->txs & CLK_BRG_MASK;
+
+	sca_out(EXS_TES1, (phy_node(port) ? MSCI1_OFFSET : MSCI0_OFFSET) + EXS,
+		port_to_card(port));
+	switch(port->settings.clock_type) {
+	case CLOCK_INT:
+		rxs |= CLK_BRG; /* BRG output */
+		txs |= CLK_PIN_OUT | CLK_TX_RXCLK; /* RX clock */
+		break;
+
+	case CLOCK_TXINT:
+		rxs |= CLK_LINE; /* RXC input */
+		txs |= CLK_PIN_OUT | CLK_BRG; /* BRG output */
+		break;
+
+	case CLOCK_TXFROMRX:
+		rxs |= CLK_LINE; /* RXC input */
+		txs |= CLK_PIN_OUT | CLK_TX_RXCLK; /* RX clock */
+		break;
+
+	default:		/* EXTernal clock */
+		rxs |= CLK_LINE; /* RXC input */
+		txs |= CLK_PIN_OUT | CLK_LINE; /* TXC input */
+		break;
+	}
+
+	port->rxs = rxs;
+	port->txs = txs;
+	sca_out(rxs, msci + RXS, card);
+	sca_out(txs, msci + TXS, card);
+	sca_set_port(port);
+}
+
+
+
+static int pci200_open(struct net_device *dev)
+{
+	hdlc_device *hdlc = dev_to_hdlc(dev);
+	port_t *port = hdlc_to_port(hdlc);
+
+	int result = hdlc_open(hdlc);
+	if (result)
+		return result;
+
+	sca_open(hdlc);
+	pci200_set_iface(port);
+	sca_flush(port_to_card(port));
+	return 0;
+}
+
+
+
+static int pci200_close(struct net_device *dev)
+{
+	hdlc_device *hdlc = dev_to_hdlc(dev);
+	sca_close(hdlc);
+	sca_flush(port_to_card(dev_to_port(dev)));
+	hdlc_close(hdlc);
+	return 0;
+}
+
+
+
+static int pci200_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	const size_t size = sizeof(sync_serial_settings);
+	sync_serial_settings new_line, *line = ifr->ifr_settings.ifs_ifsu.sync;
+	hdlc_device *hdlc = dev_to_hdlc(dev);
+	port_t *port = hdlc_to_port(hdlc);
+
+#ifdef DEBUG_RINGS
+	if (cmd == SIOCDEVPRIVATE) {
+		sca_dump_rings(hdlc);
+		return 0;
+	}
+#endif
+	if (cmd != SIOCWANDEV)
+		return hdlc_ioctl(dev, ifr, cmd);
+
+	switch(ifr->ifr_settings.type) {
+	case IF_GET_IFACE:
+		ifr->ifr_settings.type = IF_IFACE_V35;
+		if (ifr->ifr_settings.size < size) {
+			ifr->ifr_settings.size = size; /* data size wanted */
+			return -ENOBUFS;
+		}
+		if (copy_to_user(line, &port->settings, size))
+			return -EFAULT;
+		return 0;
+
+	case IF_IFACE_V35:
+	case IF_IFACE_SYNC_SERIAL:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		if (copy_from_user(&new_line, line, size))
+			return -EFAULT;
+
+		if (new_line.clock_type != CLOCK_EXT &&
+		    new_line.clock_type != CLOCK_TXFROMRX &&
+		    new_line.clock_type != CLOCK_INT &&
+		    new_line.clock_type != CLOCK_TXINT)
+		return -EINVAL;	/* No such clock setting */
+
+		if (new_line.loopback != 0 && new_line.loopback != 1)
+			return -EINVAL;
+
+		memcpy(&port->settings, &new_line, size); /* Update settings */
+		pci200_set_iface(port);
+		sca_flush(port_to_card(port));
+		return 0;
+
+	default:
+		return hdlc_ioctl(dev, ifr, cmd);
+	}
+}
+
+
+
+static void pci200_pci_remove_one(struct pci_dev *pdev)
+{
+	int i;
+        card_t *card = pci_get_drvdata(pdev);
+
+	for(i = 0; i < 2; i++)
+		if (card->ports[i].card)
+			unregister_hdlc_device(&card->ports[i].hdlc);
+
+	if (card->irq)
+		free_irq(card->irq, card);
+	iounmap(card->rambase);
+	iounmap(card->scabase);
+	iounmap(card->plxbase);
+        pci_release_regions(pdev);
+	kfree(card);
+}
+
+
+
+static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
+					 const struct pci_device_id *ent)
+{
+	card_t *card;
+	u8 rev_id;
+	u32 *p;
+	int i;
+
+#ifndef MODULE
+        static int printed_version;
+        if (!printed_version++)
+                printk(KERN_INFO "%s\n", version);
+#endif
+
+	i = pci_enable_device(pdev);
+	if (i)
+		return i;
+
+        i = pci_request_regions(pdev, "PCI200SYN");
+	if (i)
+                return i;
+
+	card = kmalloc(sizeof(card_t), GFP_KERNEL);
+	if (card == NULL) {
+		printk(KERN_ERR "pci200syn: unable to allocate memory\n");
+		return -ENOBUFS;
+	}
+	memset(card, 0, sizeof(card_t));
+	pci_set_drvdata(pdev, card);
+
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &rev_id);
+	if (pci_resource_len(pdev, 0) != PCI200SYN_PLX_SIZE ||
+	    pci_resource_len(pdev, 2) != PCI200SYN_SCA_SIZE ||
+	    pci_resource_len(pdev, 3) < 16384) {
+		printk(KERN_ERR "pci200syn: invalid card EEPROM parameters\n");
+		kfree(card);
+		return -EFAULT;
+	}
+
+	card->plxphys = pci_resource_start(pdev,0) & PCI_BASE_ADDRESS_MEM_MASK;
+	card->plxbase = ioremap(card->plxphys, PCI200SYN_PLX_SIZE);
+
+	card->scaphys = pci_resource_start(pdev,2) & PCI_BASE_ADDRESS_MEM_MASK;
+	card->scabase = ioremap(card->scaphys, PCI200SYN_SCA_SIZE);
+
+	card->ramphys = pci_resource_start(pdev,3) & PCI_BASE_ADDRESS_MEM_MASK;
+	card->rambase = ioremap(card->ramphys, pci_resource_len(pdev,3));
+
+	/* Reset PLX */
+	p = &card->plxbase->init_ctrl;
+	writel(readl(p) | 0x40000000, p);
+	readl(p);		/* Flush the write - do not use sca_flush */
+	udelay(1);
+
+	writel(readl(p) & ~0x40000000, p);
+	readl(p);		/* Flush the write - do not use sca_flush */
+	udelay(1);
+
+	card->ramsize = sca_detect_ram(card, card->rambase,
+				       pci_resource_len(pdev,3));
+
+	/* number of TX + RX buffers for one port - this is dual port card */
+	i = card->ramsize / (2 * (sizeof(pkt_desc) + HDLC_MAX_MRU));
+	card->tx_ring_buffers = min(i / 2, MAX_TX_BUFFERS);
+	card->rx_ring_buffers = i - card->tx_ring_buffers;
+
+	card->buff_offset = 2 * sizeof(pkt_desc) * (card->tx_ring_buffers +
+						    card->rx_ring_buffers);
+
+	printk(KERN_INFO "pci200syn: %u KB RAM at 0x%x, IRQ%u, using %u TX +"
+	       " %u RX packets rings\n", card->ramsize / 1024,
+	       card->ramphys, pdev->irq,
+	       card->tx_ring_buffers, card->rx_ring_buffers);
+
+	if (card->tx_ring_buffers < 1) {
+		printk(KERN_ERR "pci200syn: RAM test failed\n");
+		pci200_pci_remove_one(pdev);
+		return -EFAULT;
+	}
+
+	/* Enable interrupts on the PCI bridge */
+	p = &card->plxbase->intr_ctrl_stat;
+	writew(readw(p) | 0x0040, p);
+
+	/* Allocate IRQ */
+	if(request_irq(pdev->irq, sca_intr, SA_SHIRQ, devname, card)) {
+		printk(KERN_WARNING "pci200syn: could not allocate IRQ%d.\n",
+		       pdev->irq);
+		pci200_pci_remove_one(pdev);
+		return -EBUSY;
+	}
+	card->irq = pdev->irq;
+
+	sca_init(card, 0);
+
+	for(i = 0; i < 2; i++) {
+		port_t *port = &card->ports[i];
+		struct net_device *dev = hdlc_to_dev(&port->hdlc);
+		port->phy_node = i;
+
+		spin_lock_init(&port->lock);
+		SET_MODULE_OWNER(dev);
+		dev->irq = card->irq;
+		dev->mem_start = card->ramphys;
+		dev->mem_end = card->ramphys + card->ramsize - 1;
+		dev->tx_queue_len = 50;
+		dev->do_ioctl = pci200_ioctl;
+		dev->open = pci200_open;
+		dev->stop = pci200_close;
+		port->hdlc.attach = sca_attach;
+		port->hdlc.xmit = sca_xmit;
+		port->settings.clock_type = CLOCK_EXT;
+		if(register_hdlc_device(&port->hdlc)) {
+			printk(KERN_ERR "pci200syn: unable to register hdlc "
+			       "device\n");
+			pci200_pci_remove_one(pdev);
+			return -ENOBUFS;
+		}
+		port->card = card;
+		sca_init_sync_port(port);	/* Set up SCA memory */
+
+		printk(KERN_INFO "%s: PCI200SYN node %d\n",
+		       hdlc_to_name(&port->hdlc), port->phy_node);
+	}
+
+	sca_flush(card);
+	return 0;
+}
+
+
+
+static struct pci_device_id pci200_pci_tbl[] __devinitdata = {
+        { PCI_VENDOR_ID_GORAMO, PCI_DEVICE_ID_PCI200SYN, PCI_ANY_ID,
+	  PCI_ANY_ID, 0, 0, 0 },
+        { 0, }
+};
+
+
+static struct pci_driver pci200_pci_driver = {
+        name:           "PCI200SYN",
+        id_table:       pci200_pci_tbl,
+        probe:          pci200_pci_init_one,
+        remove:         pci200_pci_remove_one,
+};
+
+
+static int __init pci200_init_module(void)
+{
+#ifdef MODULE
+        printk(KERN_INFO "%s\n", version);
+#endif
+	if (pci_clock_freq < 1000000 || pci_clock_freq > 80000000) {
+		printk(KERN_ERR "pci200syn: Invalid PCI clock frequency\n");
+		return -EINVAL;
+	}
+	return pci_module_init(&pci200_pci_driver);
+}
+
+
+
+static void __exit pci200_cleanup_module(void)
+{
+	pci_unregister_driver(&pci200_pci_driver);
+}
+
+MODULE_AUTHOR("Krzysztof Halasa <khc@pm.waw.pl>");
+MODULE_DESCRIPTION("Goramo PCI200SYN serial port driver");
+MODULE_LICENSE("GPL v2");
+MODULE_DEVICE_TABLE(pci, pci200_pci_tbl);
+module_param(pci_clock_freq, int, 0444);
+MODULE_PARM_DESC(pci_clock_freq, "System PCI clock frequency in Hz");
+module_init(pci200_init_module);
+module_exit(pci200_cleanup_module);
--- linux-2.6.orig/drivers/net/wan/Kconfig	2003-10-03 15:38:12.000000000 +0200
+++ linux-2.6/drivers/net/wan/Kconfig	2003-10-03 16:27:08.000000000 +0200
@@ -325,6 +325,21 @@
 comment "X.25/LAPB support is disabled"
 	depends on WAN && HDLC && (LAPB!=m || HDLC!=m) && LAPB!=y
 
+config PCI200SYN
+	tristate "Goramo PCI200SYN support"
+	depends on HDLC && PCI
+	help
+	  This driver is for PCI200SYN cards made by Goramo sp. j.
+	  If you have such a card, say Y here and see
+	  <http://hq.pm.waw.pl/pub/hdlc/>
+
+	  If you want to compile the driver as a module ( = code which can be
+	  inserted in and removed from the running kernel whenever you want),
+	  say M here and read <file:Documentation/modules.txt>.  The module
+	  will be called pci200syn.
+
+	  If unsure, say N here.
+
 config WANXL
 	tristate "SBE Inc. wanXL support"
 	depends on HDLC && PCI

--=-=-=--
