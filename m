From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [01/22] Cyclades PC300 driver: merge in Cyclades driver version 4.1.0
Date: Sun, 29 Jan 2012 18:43:54 -0800
Message-ID: <20120130024354.GB10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Merge in version 4.1.0 of the Cyclades PC-300 driver.  This driver is licensed
under GPLv2 and may be obtained from:

ftp://ftp.cyclades.com/pub/cyclades/pc300/linux/pc300-4.1.0.tar.gz

This patch contains many style violations; they are present in driver version
4.1.0 as well as in the 3.4.5 driver already in the kernel tree.  Those which
are not fixed in another patch subsequent to this one are fixed in patch 16
(cleanup) of this series.  For convenience, two omnibus patches incorporating
all changes from this patch (01) to the cleanup path (16) and all changes
from this path to the last of this series (20) are attached as #21 and #22
respectively, and this may be verified.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/hd64572.h b/drivers/net/wan/hd64572.h
index 96567c2..727dc6b 100644
--- a/drivers/net/wan/hd64572.h
+++ b/drivers/net/wan/hd64572.h
@@ -4,7 +4,7 @@
  *
  * Author:	Ivan Passos <ivan@cyclades.com>
  *
- * Copyright:   (c) 2000-2001 Cyclades Corp.
+ * Copyright:   (c) 2000-2004 Cyclades Corp.
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
diff --git a/drivers/net/wan/pc300-falc-lh.h b/drivers/net/wan/pc300-falc-lh.h
index 01ed23c..514000a 100644
--- a/drivers/net/wan/pc300-falc-lh.h
+++ b/drivers/net/wan/pc300-falc-lh.h
@@ -3,7 +3,7 @@
  *
  * Author:	Ivan Passos <ivan@cyclades.com>
  *
- * Copyright:	(c) 2000-2001 Cyclades Corp.
+ * Copyright:	(c) 2000-2004 Cyclades Corp.
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
diff --git a/drivers/net/wan/pc300.h b/drivers/net/wan/pc300.h
index 2e4f84f..54f99a3 100644
--- a/drivers/net/wan/pc300.h
+++ b/drivers/net/wan/pc300.h
@@ -3,7 +3,7 @@
  *
  * Author:	Ivan Passos <ivan@cyclades.com>
  *
- * Copyright:	(c) 1999-2002 Cyclades Corp.
+ * Copyright:	(c) 1999-2004 Cyclades Corp.
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
@@ -103,11 +103,31 @@
 #include "hd64572.h"
 #include "pc300-falc-lh.h"
 
-#define PC300_PROTO_MLPPP 1
+#ifndef CY_TYPES
+#define CY_TYPES
+#if defined(__alpha__)
+typedef	unsigned long	ucdouble;	/* 64 bits, unsigned */
+typedef	unsigned int	uclong;		/* 32 bits, unsigned */
+#else
+typedef	unsigned long	uclong;		/* 32 bits, unsigned */
+#endif
+typedef	unsigned short	ucshort;	/* 16 bits, unsigned */
+typedef	unsigned char	ucchar;		/* 8 bits, unsigned */
+#endif /* CY_TYPES */
+
+#define PC300_PROTO_MLPPP 1		
+
+#define PC300_KERNEL	"2.4.x"	/* Kernel supported by this driver */
 
+#define	PC300_DEVNAME	"hdlc"	/* Dev. name base (for hdlc0, hdlc1, etc.) */
+#define PC300_MAXINDEX	100	/* Max dev. name index (the '0' in hdlc0) */
+
+#define	PC300_MAXCARDS	4	/* Max number of cards per system */
 #define	PC300_MAXCHAN	2	/* Number of channels per card */
 
+#define	PC300_PLX_WIN	0x80    /* PLX control window size (128b) */
 #define	PC300_RAMSIZE	0x40000 /* RAM window size (256Kb) */
+#define	PC300_SCASIZE	0x400   /* SCA window size (1Kb) */
 #define	PC300_FALCSIZE	0x400	/* FALC window size (1Kb) */
 
 #define PC300_OSC_CLOCK	24576000
@@ -143,14 +163,26 @@
  * Memory access functions/macros      *
  * (required to support Alpha systems) *
  ***************************************/
-#define cpc_writeb(port,val)	{writeb((u8)(val),(port)); mb();}
-#define cpc_writew(port,val)	{writew((ushort)(val),(port)); mb();}
-#define cpc_writel(port,val)	{writel((u32)(val),(port)); mb();}
+#ifdef __KERNEL__
+#define cpc_writeb(port,val)	{writeb((ucchar)(val),(ulong)(port)); mb();}
+#define cpc_writew(port,val)	{writew((ushort)(val),(ulong)(port)); mb();}
+#define cpc_writel(port,val)	{writel((uclong)(val),(ulong)(port)); mb();}
 
 #define cpc_readb(port)		readb(port)
 #define cpc_readw(port)		readw(port)
 #define cpc_readl(port)		readl(port)
 
+#else /* __KERNEL__ */
+#define cpc_writeb(port,val)	(*(volatile ucchar *)(port) = (ucchar)(val))
+#define cpc_writew(port,val)	(*(volatile ucshort *)(port) = (ucshort)(val))
+#define cpc_writel(port,val)	(*(volatile uclong *)(port) = (uclong)(val))
+
+#define cpc_readb(port)		(*(volatile ucchar *)(port))
+#define cpc_readw(port)		(*(volatile ucshort *)(port))
+#define cpc_readl(port)		(*(volatile uclong *)(port))
+
+#endif /* __KERNEL__ */
+
 /****** Data Structures *****************************************************/
 
 /*
@@ -159,15 +191,15 @@
  *      (memory mapped).
  */
 struct RUNTIME_9050 {
-	u32 loc_addr_range[4];	/* 00-0Ch : Local Address Ranges */
-	u32 loc_rom_range;	/* 10h : Local ROM Range */
-	u32 loc_addr_base[4];	/* 14-20h : Local Address Base Addrs */
-	u32 loc_rom_base;	/* 24h : Local ROM Base */
-	u32 loc_bus_descr[4];	/* 28-34h : Local Bus Descriptors */
-	u32 rom_bus_descr;	/* 38h : ROM Bus Descriptor */
-	u32 cs_base[4];		/* 3C-48h : Chip Select Base Addrs */
-	u32 intr_ctrl_stat;	/* 4Ch : Interrupt Control/Status */
-	u32 init_ctrl;		/* 50h : EEPROM ctrl, Init Ctrl, etc */
+	uclong	loc_addr_range[4];	/* 00-0Ch : Local Address Ranges */
+	uclong	loc_rom_range;		/* 10h : Local ROM Range */
+	uclong	loc_addr_base[4];	/* 14-20h : Local Address Base Addrs */
+	uclong	loc_rom_base;		/* 24h : Local ROM Base */
+	uclong	loc_bus_descr[4];	/* 28-34h : Local Bus Descriptors */
+	uclong	rom_bus_descr;		/* 38h : ROM Bus Descriptor */
+	uclong	cs_base[4];		/* 3C-48h : Chip Select Base Addrs */
+	uclong	intr_ctrl_stat;		/* 4Ch : Interrupt Control/Status */
+	uclong	init_ctrl;		/* 50h : EEPROM ctrl, Init Ctrl, etc */
 };
 
 #define PLX_9050_LINT1_ENABLE	0x01
@@ -211,66 +243,66 @@ struct RUNTIME_9050 {
 #define PC300_FALC_MAXLOOP	0x0000ffff	/* for falc_issue_cmd() */
 
 typedef struct falc {
-	u8 sync;	/* If true FALC is synchronized */
-	u8 active;	/* if TRUE then already active */
-	u8 loop_active;	/* if TRUE a line loopback UP was received */
-	u8 loop_gen;	/* if TRUE a line loopback UP was issued */
+	ucchar sync;		/* If true FALC is synchronized */
+	ucchar active;		/* if TRUE then already active */
+	ucchar loop_active;	/* if TRUE a line loopback UP was received */
+	ucchar loop_gen;	/* if TRUE a line loopback UP was issued */
 
-	u8 num_channels;
-	u8 offset;	/* 1 for T1, 0 for E1 */
-	u8 full_bandwidth;
+	ucchar num_channels;
+	ucchar offset;		/* 1 for T1, 0 for E1 */
+	ucchar full_bandwidth;
 
-	u8 xmb_cause;
-	u8 multiframe_mode;
+	ucchar xmb_cause;
+	ucchar multiframe_mode;
 
 	/* Statistics */
-	u16 pden;	/* Pulse Density violation count */
-	u16 los;	/* Loss of Signal count */
-	u16 losr;	/* Loss of Signal recovery count */
-	u16 lfa;	/* Loss of frame alignment count */
-	u16 farec;	/* Frame Alignment Recovery count */
-	u16 lmfa;	/* Loss of multiframe alignment count */
-	u16 ais;	/* Remote Alarm indication Signal count */
-	u16 sec;	/* One-second timer */
-	u16 es;		/* Errored second */
-	u16 rai;	/* remote alarm received */
-	u16 bec;
-	u16 fec;
-	u16 cvc;
-	u16 cec;
-	u16 ebc;
+	ucshort pden;	/* Pulse Density violation count */
+	ucshort los;	/* Loss of Signal count */
+	ucshort losr;	/* Loss of Signal recovery count */
+	ucshort lfa;	/* Loss of frame alignment count */
+	ucshort farec;	/* Frame Alignment Recovery count */
+	ucshort lmfa;	/* Loss of multiframe alignment count */
+	ucshort ais;	/* Remote Alarm indication Signal count */
+	ucshort sec;	/* One-second timer */
+	ucshort es;	/* Errored second */
+	ucshort rai;	/* remote alarm received */
+	ucshort bec;
+	ucshort fec;
+	ucshort cvc;
+	ucshort cec;
+	ucshort ebc;
 
 	/* Status */
-	u8 red_alarm;
-	u8 blue_alarm;
-	u8 loss_fa;
-	u8 yellow_alarm;
-	u8 loss_mfa;
-	u8 prbs;
+	ucchar red_alarm;
+	ucchar blue_alarm;
+	ucchar loss_fa;
+	ucchar yellow_alarm;
+	ucchar loss_mfa;
+	ucchar prbs;
 } falc_t;
 
 typedef struct falc_status {
-	u8 sync;	/* If true FALC is synchronized */
-	u8 red_alarm;
-	u8 blue_alarm;
-	u8 loss_fa;
-	u8 yellow_alarm;
-	u8 loss_mfa;
-	u8 prbs;
+	ucchar sync;  /* If true FALC is synchronized */
+	ucchar red_alarm;
+	ucchar blue_alarm;
+	ucchar loss_fa;
+	ucchar yellow_alarm;
+	ucchar loss_mfa;
+	ucchar prbs;
 } falc_status_t;
 
 typedef struct rsv_x21_status {
-	u8 dcd;
-	u8 dsr;
-	u8 cts;
-	u8 rts;
-	u8 dtr;
+	ucchar dcd;
+	ucchar dsr;
+	ucchar cts;
+	ucchar rts;
+	ucchar dtr;
 } rsv_x21_status_t;
 
 typedef struct pc300stats {
 	int hw_type;
-	u32 line_on;
-	u32 line_off;
+	uclong line_on;
+	uclong line_off;
 	struct net_device_stats gen_stats;
 	falc_t te_stats;
 } pc300stats_t;
@@ -288,19 +320,28 @@ typedef struct pc300loopback {
 
 typedef struct pc300patterntst {
 	char patrntst_on;       /* 0 - off; 1 - on; 2 - read num_errors */
-	u16 num_errors;
+	ucshort num_errors;
 } pc300patterntst_t;
 
 typedef struct pc300dev {
+	void *if_ptr;		/* General purpose pointer */
 	struct pc300ch *chan;
-	u8 trace_on;
-	u32 line_on;		/* DCD(X.21, RSV) / sync(TE) change counters */
-	u32 line_off;
+	ucchar trace_on;
+	uclong line_on;		/* DCD(X.21, RSV) / sync(TE) change counters */
+	uclong line_off;
+#ifdef __KERNEL__
 	char name[16];
-	struct net_device *dev;
+	hdlc_device *hdlc;
+
+	void *private;
+	struct sk_buff *tx_skb;
+	union {	/* This union has all the protocol-specific structures */
+		struct ppp_device pppdev;
+	}ifu;
 #ifdef CONFIG_PC300_MLPPP
 	void *cpc_tty;	/* information to PC300 TTY driver */
 #endif
+#endif /* __KERNEL__ */
 }pc300dev_t;
 
 typedef struct pc300hw {
@@ -308,42 +349,43 @@ typedef struct pc300hw {
 	int bus;		/* Bus (PCI, PMC, etc.) */
 	int nchan;		/* number of channels */
 	int irq;		/* interrupt request level */
-	u32 clock;		/* Board clock */
-	u8 cpld_id;		/* CPLD ID (TE only) */
-	u16 cpld_reg1;		/* CPLD reg 1 (TE only) */
-	u16 cpld_reg2;		/* CPLD reg 2 (TE only) */
-	u16 gpioc_reg;		/* PLX GPIOC reg */
-	u16 intctl_reg;		/* PLX Int Ctrl/Status reg */
-	u32 iophys;		/* PLX registers I/O base */
-	u32 iosize;		/* PLX registers I/O size */
-	u32 plxphys;		/* PLX registers MMIO base (physical) */
-	void __iomem * plxbase;	/* PLX registers MMIO base (virtual) */
-	u32 plxsize;		/* PLX registers MMIO size */
-	u32 scaphys;		/* SCA registers MMIO base (physical) */
-	void __iomem * scabase;	/* SCA registers MMIO base (virtual) */
-	u32 scasize;		/* SCA registers MMIO size */
-	u32 ramphys;		/* On-board RAM MMIO base (physical) */
-	void __iomem * rambase;	/* On-board RAM MMIO base (virtual) */
-	u32 alloc_ramsize;	/* RAM MMIO size allocated by the PCI bridge */
-	u32 ramsize;		/* On-board RAM MMIO size */
-	u32 falcphys;		/* FALC registers MMIO base (physical) */
-	void __iomem * falcbase;/* FALC registers MMIO base (virtual) */
-	u32 falcsize;		/* FALC registers MMIO size */
+	uclong clock;		/* Board clock */
+	ucchar cpld_id;		/* CPLD ID (TE only) */
+	ucshort cpld_reg1;	/* CPLD reg 1 (TE only) */
+	ucshort cpld_reg2;	/* CPLD reg 2 (TE only) */
+	ucshort gpioc_reg;	/* PLX GPIOC reg */
+	ucshort intctl_reg;	/* PLX Int Ctrl/Status reg */
+	uclong iophys;		/* PLX registers I/O base */
+	uclong iosize;		/* PLX registers I/O size */
+	uclong plxphys;		/* PLX registers MMIO base (physical) */
+	uclong plxbase;		/* PLX registers MMIO base (virtual) */
+	uclong plxsize;		/* PLX registers MMIO size */
+	uclong scaphys;		/* SCA registers MMIO base (physical) */
+	uclong scabase;		/* SCA registers MMIO base (virtual) */
+	uclong scasize;		/* SCA registers MMIO size */
+	uclong ramphys;		/* On-board RAM MMIO base (physical) */
+	uclong rambase;		/* On-board RAM MMIO base (virtual) */
+	uclong alloc_ramsize;	/* RAM MMIO size allocated by the PCI bridge */
+	uclong ramsize;		/* On-board RAM MMIO size */
+	uclong falcphys;	/* FALC registers MMIO base (physical) */
+	uclong falcbase;	/* FALC registers MMIO base (virtual) */
+	uclong falcsize;	/* FALC registers MMIO size */
 } pc300hw_t;
 
 typedef struct pc300chconf {
-	sync_serial_settings	phys_settings;	/* Clock type/rate (in bps),
+	sync_serial_settings	phys_settings;	/* Clock type/rate (in bps), 
 						   loopback mode */
 	raw_hdlc_proto		proto_settings;	/* Encoding, parity (CRC) */
-	u32 media;		/* HW media (RS232, V.35, etc.) */
-	u32 proto;		/* Protocol (PPP, X.25, etc.) */
+	uclong media;		/* HW media (RS232, V.35, etc.) */
+	uclong proto;		/* Protocol (PPP, X.25, etc.) */
+	ucchar monitor;		/* Monitor mode (0 = off, !0 = on) */
 
 	/* TE-specific parameters */
-	u8 lcode;		/* Line Code (AMI, B8ZS, etc.) */
-	u8 fr_mode;		/* Frame Mode (ESF, D4, etc.) */
-	u8 lbo;			/* Line Build Out */
-	u8 rx_sens;		/* Rx Sensitivity (long- or short-haul) */
-	u32 tslot_bitmap;	/* bit[i]=1  =>  timeslot _i_ is active */
+	ucchar lcode;		/* Line Code (AMI, B8ZS, etc.) */
+	ucchar fr_mode;		/* Frame Mode (ESF, D4, etc.) */
+	ucchar lbo;		/* Line Build Out */
+	ucchar rx_sens;		/* Rx Sensitivity (long- or short-haul) */
+	uclong tslot_bitmap;	/* bit[i]=1  =>  timeslot _i_ is active */
 } pc300chconf_t;
 
 typedef struct pc300ch {
@@ -351,18 +393,20 @@ typedef struct pc300ch {
 	int channel;
 	pc300dev_t d;
 	pc300chconf_t conf;
-	u8 tx_first_bd;	/* First TX DMA block descr. w/ data */
-	u8 tx_next_bd;	/* Next free TX DMA block descriptor */
-	u8 rx_first_bd;	/* First free RX DMA block descriptor */
-	u8 rx_last_bd;	/* Last free RX DMA block descriptor */
-	u8 nfree_tx_bd;	/* Number of free TX DMA block descriptors */
-	falc_t falc;	/* FALC structure (TE only) */
+	ucchar tx_first_bd;	/* First TX DMA block descr. w/ data */
+	ucchar tx_next_bd;	/* Next free TX DMA block descriptor */
+	ucchar rx_first_bd;	/* First free RX DMA block descriptor */
+	ucchar rx_last_bd;	/* Last free RX DMA block descriptor */
+	ucchar nfree_tx_bd;	/* Number of free TX DMA block descriptors */
+	falc_t falc;		/* FALC structure (TE only) */
 } pc300ch_t;
 
 typedef struct pc300 {
 	pc300hw_t hw;			/* hardware config. */
 	pc300ch_t chan[PC300_MAXCHAN];
+#ifdef __KERNEL__
 	spinlock_t card_lock;
+#endif /* __KERNEL__ */
 } pc300_t;
 
 typedef struct pc300conf {
@@ -430,7 +474,28 @@ enum pc300_loopback_cmds {
 #define PC300_TX_QUEUE_LEN	100
 #define	PC300_DEF_MTU		1600
 
+#ifdef __KERNEL__
 /* Function Prototypes */
+int dma_buf_write(pc300_t *, int, ucchar *, int);
+int dma_buf_read(pc300_t *, int, struct sk_buff *);
+void tx_dma_start(pc300_t *, int);
+void rx_dma_start(pc300_t *, int);
+void tx_dma_stop(pc300_t *, int);
+void rx_dma_stop(pc300_t *, int);
+int cpc_queue_xmit(struct sk_buff *, struct net_device *);
+void cpc_net_rx(hdlc_device *);
+void cpc_sca_status(pc300_t *, int);
+int cpc_change_mtu(struct net_device *, int);
+int cpc_ioctl(struct net_device *, struct ifreq *, int);
+int ch_config(pc300dev_t *);
+int rx_config(pc300dev_t *);
+int tx_config(pc300dev_t *);
+void cpc_opench(pc300dev_t *);
+void cpc_closech(pc300dev_t *);
 int cpc_open(struct net_device *dev);
+int cpc_close(struct net_device *dev);
+int cpc_set_media(hdlc_device *, int);
+#endif /* __KERNEL__ */
 
 #endif	/* _PC300_H */
+
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 1eeedd6..1d2bd69 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -1,6 +1,6 @@
 #define	USE_PCI_CLOCK
-static const char rcsid[] =
-"Revision: 3.4.5 Date: 2002/03/07 ";
+static char rcsid[] = 
+"Revision: 4.1.0 Date: 2004/02/20 ";
 
 /*
  * pc300.c	Cyclades-PC300(tm) Driver.
@@ -8,7 +8,7 @@ static const char rcsid[] =
  * Author:	Ivan Passos <ivan@cyclades.com>
  * Maintainer:	PC300 Maintainer <pc300@cyclades.com>
  *
- * Copyright:	(c) 1999-2003 Cyclades Corp.
+ * Copyright:	(c) 1999-2004 Cyclades Corp.
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
@@ -227,10 +227,10 @@ static const char rcsid[] =
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
 #include <linux/netdevice.h>
-#include <linux/etherdevice.h>
 #include <linux/spinlock.h>
 #include <linux/if.h>
-#include <linux/slab.h>
+
+#include <net/syncppp.h>
 #include <net/arp.h>
 
 #include <asm/io.h>
@@ -254,7 +254,7 @@ static const char rcsid[] =
 #undef	PC300_DEBUG_RX
 #undef	PC300_DEBUG_OTHER
 
-static DEFINE_PCI_DEVICE_TABLE(cpc_pci_dev_id) = {
+static struct pci_device_id cpc_pci_dev_id[] __devinitdata = {
 	/* PC300/RSV or PC300/X21, 2 chan */
 	{0x120e, 0x300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0x300},
 	/* PC300/RSV or PC300/X21, 1 chan */
@@ -286,13 +286,13 @@ static void rx_dma_buf_pt_init(pc300_t *, int);
 static void rx_dma_buf_init(pc300_t *, int);
 static void tx_dma_buf_check(pc300_t *, int);
 static void rx_dma_buf_check(pc300_t *, int);
-static irqreturn_t cpc_intr(int, void *);
-static int clock_rate_calc(u32, u32, int *);
-static u32 detect_ram(pc300_t *);
+static irqreturn_t cpc_intr(int, void *, struct pt_regs *);
+static struct net_device_stats *cpc_get_stats(struct net_device *);
+static int clock_rate_calc(uclong, uclong, int *);
+static uclong detect_ram(pc300_t *);
 static void plx_init(pc300_t *);
 static void cpc_trace(struct net_device *, struct sk_buff *, char);
-static int cpc_attach(struct net_device *, unsigned short, unsigned short);
-static int cpc_close(struct net_device *dev);
+static int cpc_attach(hdlc_device *, unsigned short, unsigned short);
 
 #ifdef CONFIG_PC300_MLPPP
 void cpc_tty_init(pc300dev_t * dev);
@@ -309,14 +309,14 @@ static void tx_dma_buf_pt_init(pc300_t * card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_TX_BUF;
-	volatile pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
+	volatile pcsca_bd_t *ptdescr = (pcsca_bd_t *) (card->hw.rambase
 			               + DMA_TX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_TX_BUF; i++, ptdescr++) {
-		cpc_writel(&ptdescr->next, (u32)(DMA_TX_BD_BASE +
+		cpc_writel(&ptdescr->next, (uclong) (DMA_TX_BD_BASE +
 			(ch_factor + ((i + 1) & (N_DMA_TX_BUF - 1))) * sizeof(pcsca_bd_t)));
-		cpc_writel(&ptdescr->ptbuf,
-			   (u32)(DMA_TX_BASE + (ch_factor + i) * BD_DEF_LEN));
+		cpc_writel(&ptdescr->ptbuf, 
+						(uclong) (DMA_TX_BASE + (ch_factor + i) * BD_DEF_LEN));
 	}
 }
 
@@ -324,7 +324,7 @@ static void tx_dma_buf_init(pc300_t * card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_TX_BUF;
-	volatile pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
+	volatile pcsca_bd_t *ptdescr = (pcsca_bd_t *) (card->hw.rambase
 			       + DMA_TX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_TX_BUF; i++, ptdescr++) {
@@ -339,14 +339,14 @@ static void rx_dma_buf_pt_init(pc300_t * card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_RX_BUF;
-	volatile pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
+	volatile pcsca_bd_t *ptdescr = (pcsca_bd_t *) (card->hw.rambase
 				       + DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_RX_BUF; i++, ptdescr++) {
-		cpc_writel(&ptdescr->next, (u32)(DMA_RX_BD_BASE +
-			(ch_factor + ((i + 1) & (N_DMA_RX_BUF - 1))) * sizeof(pcsca_bd_t)));
+		cpc_writel(&ptdescr->next, (uclong) (DMA_RX_BD_BASE +
+	     	(ch_factor + ((i + 1) & (N_DMA_RX_BUF - 1))) * sizeof(pcsca_bd_t)));
 		cpc_writel(&ptdescr->ptbuf,
-			   (u32)(DMA_RX_BASE + (ch_factor + i) * BD_DEF_LEN));
+			   (uclong) (DMA_RX_BASE + (ch_factor + i) * BD_DEF_LEN));
 	}
 }
 
@@ -354,7 +354,7 @@ static void rx_dma_buf_init(pc300_t * card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_RX_BUF;
-	volatile pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
+	volatile pcsca_bd_t *ptdescr = (pcsca_bd_t *) (card->hw.rambase
 				       + DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_RX_BUF; i++, ptdescr++) {
@@ -367,22 +367,22 @@ static void rx_dma_buf_init(pc300_t * card, int ch)
 
 static void tx_dma_buf_check(pc300_t * card, int ch)
 {
-	volatile pcsca_bd_t __iomem *ptdescr;
+	volatile pcsca_bd_t *ptdescr;
 	int i;
-	u16 first_bd = card->chan[ch].tx_first_bd;
-	u16 next_bd = card->chan[ch].tx_next_bd;
+	ucshort first_bd = card->chan[ch].tx_first_bd;
+	ucshort next_bd = card->chan[ch].tx_next_bd;
 
-	printk("#CH%d: f_bd = %d(0x%08zx), n_bd = %d(0x%08zx)\n", ch,
+	printk("#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
 	       first_bd, TX_BD_ADDR(ch, first_bd),
 	       next_bd, TX_BD_ADDR(ch, next_bd));
 	for (i = first_bd,
-	     ptdescr = (card->hw.rambase + TX_BD_ADDR(ch, first_bd));
+	     ptdescr = (pcsca_bd_t *) (card->hw.rambase + TX_BD_ADDR(ch, first_bd));
 	     i != ((next_bd + 1) & (N_DMA_TX_BUF - 1));
 	     i = (i + 1) & (N_DMA_TX_BUF - 1), 
-		 ptdescr = (card->hw.rambase + TX_BD_ADDR(ch, i))) {
-		printk("\n CH%d TX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
-		       ch, i, cpc_readl(&ptdescr->next),
-		       cpc_readl(&ptdescr->ptbuf),
+		 ptdescr = (pcsca_bd_t *) (card->hw.rambase + TX_BD_ADDR(ch, i))) {
+		printk("\n CH%d TX%d: next=0x%lx, ptbuf=0x%lx, ST=0x%x, len=%d",
+		       ch, i, (uclong) cpc_readl(&ptdescr->next),
+		       (uclong) cpc_readl(&ptdescr->ptbuf),
 		       cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
 	}
 	printk("\n");
@@ -392,95 +392,95 @@ static void tx_dma_buf_check(pc300_t * card, int ch)
 /* Show all TX buffer descriptors */
 static void tx1_dma_buf_check(pc300_t * card, int ch)
 {
-	volatile pcsca_bd_t __iomem *ptdescr;
+	volatile pcsca_bd_t *ptdescr;
 	int i;
-	u16 first_bd = card->chan[ch].tx_first_bd;
-	u16 next_bd = card->chan[ch].tx_next_bd;
-	u32 scabase = card->hw.scabase;
+	ucshort first_bd = card->chan[ch].tx_first_bd;
+	ucshort next_bd = card->chan[ch].tx_next_bd;
+	uclong scabase = card->hw.scabase;
 
-	printk ("\nnfree_tx_bd = %d\n", card->chan[ch].nfree_tx_bd);
+	printk ("\nnfree_tx_bd = %d \n", card->chan[ch].nfree_tx_bd);
 	printk("#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
 	       first_bd, TX_BD_ADDR(ch, first_bd),
 	       next_bd, TX_BD_ADDR(ch, next_bd));
-	printk("TX_CDA=0x%08x, TX_EDA=0x%08x\n",
-	       cpc_readl(scabase + DTX_REG(CDAL, ch)),
-	       cpc_readl(scabase + DTX_REG(EDAL, ch)));
+	printk("TX_CDA=0x%08lx, TX_EDA=0x%08lx\n",
+	       (uclong) cpc_readl(scabase + DTX_REG(CDAL, ch)),
+	       (uclong) cpc_readl(scabase + DTX_REG(EDAL, ch)));
 	for (i = 0; i < N_DMA_TX_BUF; i++) {
-		ptdescr = (card->hw.rambase + TX_BD_ADDR(ch, i));
-		printk("\n CH%d TX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
-		       ch, i, cpc_readl(&ptdescr->next),
-		       cpc_readl(&ptdescr->ptbuf),
+		ptdescr = (pcsca_bd_t *) (card->hw.rambase + TX_BD_ADDR(ch, i));
+		printk("\n CH%d TX%d: next=0x%lx, ptbuf=0x%lx, ST=0x%x, len=%d",
+		       ch, i, (uclong) cpc_readl(&ptdescr->next),
+		       (uclong) cpc_readl(&ptdescr->ptbuf),
 		       cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
 	}
 	printk("\n");
 }
 #endif
-
+			 
 static void rx_dma_buf_check(pc300_t * card, int ch)
 {
-	volatile pcsca_bd_t __iomem *ptdescr;
+	volatile pcsca_bd_t *ptdescr;
 	int i;
-	u16 first_bd = card->chan[ch].rx_first_bd;
-	u16 last_bd = card->chan[ch].rx_last_bd;
+	ucshort first_bd = card->chan[ch].rx_first_bd;
+	ucshort last_bd = card->chan[ch].rx_last_bd;
 	int ch_factor;
 
 	ch_factor = ch * N_DMA_RX_BUF;
 	printk("#CH%d: f_bd = %d, l_bd = %d\n", ch, first_bd, last_bd);
-	for (i = 0, ptdescr = (card->hw.rambase +
+	for (i = 0, ptdescr = (pcsca_bd_t *) (card->hw.rambase +
 					      DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 	     i < N_DMA_RX_BUF; i++, ptdescr++) {
 		if (cpc_readb(&ptdescr->status) & DST_OSB)
-			printk ("\n CH%d RX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
-				 ch, i, cpc_readl(&ptdescr->next),
-				 cpc_readl(&ptdescr->ptbuf),
+			printk ("\n CH%d RX%d: next=0x%lx, ptbuf=0x%lx, ST=0x%x, len=%d",
+				 ch, i, (uclong) cpc_readl(&ptdescr->next),
+				 (uclong) cpc_readl(&ptdescr->ptbuf),
 				 cpc_readb(&ptdescr->status),
 				 cpc_readw(&ptdescr->len));
 	}
 	printk("\n");
 }
 
-static int dma_get_rx_frame_size(pc300_t * card, int ch)
+int dma_get_rx_frame_size(pc300_t * card, int ch)
 {
-	volatile pcsca_bd_t __iomem *ptdescr;
-	u16 first_bd = card->chan[ch].rx_first_bd;
+	volatile pcsca_bd_t *ptdescr;
+	ucshort first_bd = card->chan[ch].rx_first_bd;
 	int rcvd = 0;
-	volatile u8 status;
+	volatile ucchar status;
 
-	ptdescr = (card->hw.rambase + RX_BD_ADDR(ch, first_bd));
+	ptdescr = (pcsca_bd_t *)(card->hw.rambase + RX_BD_ADDR(ch, first_bd));
 	while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 		rcvd += cpc_readw(&ptdescr->len);
 		first_bd = (first_bd + 1) & (N_DMA_RX_BUF - 1);
 		if ((status & DST_EOM) || (first_bd == card->chan[ch].rx_last_bd)) {
 			/* Return the size of a good frame or incomplete bad frame 
 			* (dma_buf_read will clean the buffer descriptors in this case). */
-			return rcvd;
+			return (rcvd);
 		}
-		ptdescr = (card->hw.rambase + cpc_readl(&ptdescr->next));
+		ptdescr = (pcsca_bd_t *)(card->hw.rambase + cpc_readl(&ptdescr->next));
 	}
-	return -1;
+	return (-1);
 }
 
 /*
  * dma_buf_write: writes a frame to the Tx DMA buffers
  * NOTE: this function writes one frame at a time.
  */
-static int dma_buf_write(pc300_t *card, int ch, u8 *ptdata, int len)
+int dma_buf_write(pc300_t * card, int ch, ucchar * ptdata, int len)
 {
 	int i, nchar;
-	volatile pcsca_bd_t __iomem *ptdescr;
+	volatile pcsca_bd_t *ptdescr;
 	int tosend = len;
-	u8 nbuf = ((len - 1) / BD_DEF_LEN) + 1;
+	ucchar nbuf = ((len - 1) / BD_DEF_LEN) + 1;
 
 	if (nbuf >= card->chan[ch].nfree_tx_bd) {
 		return -ENOMEM;
 	}
 
 	for (i = 0; i < nbuf; i++) {
-		ptdescr = (card->hw.rambase +
+		ptdescr = (pcsca_bd_t *) (card->hw.rambase +
 					  TX_BD_ADDR(ch, card->chan[ch].tx_next_bd));
 		nchar = cpc_min(BD_DEF_LEN, tosend);
 		if (cpc_readb(&ptdescr->status) & DST_OSB) {
-			memcpy_toio((card->hw.rambase + cpc_readl(&ptdescr->ptbuf)),
+			memcpy_toio((void *)(card->hw.rambase + cpc_readl(&ptdescr->ptbuf)),
 				    &ptdata[len - tosend], nchar);
 			cpc_writew(&ptdescr->len, nchar);
 			card->chan[ch].nfree_tx_bd--;
@@ -505,20 +505,20 @@ static int dma_buf_write(pc300_t *card, int ch, u8 *ptdata, int len)
  * dma_buf_read: reads a frame from the Rx DMA buffers
  * NOTE: this function reads one frame at a time.
  */
-static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
+int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 {
 	int nchar;
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
-	volatile pcsca_bd_t __iomem *ptdescr;
+	volatile pcsca_bd_t *ptdescr;
 	int rcvd = 0;
-	volatile u8 status;
+	volatile ucchar status;
 
-	ptdescr = (card->hw.rambase +
+	ptdescr = (pcsca_bd_t *) (card->hw.rambase +
 				  RX_BD_ADDR(ch, chan->rx_first_bd));
 	while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 		nchar = cpc_readw(&ptdescr->len);
-		if ((status & (DST_OVR | DST_CRC | DST_RBIT | DST_SHRT | DST_ABT)) ||
-		    (nchar > BD_DEF_LEN)) {
+		if ((status & (DST_OVR | DST_CRC | DST_RBIT | DST_SHRT | DST_ABT))
+		    || (nchar > BD_DEF_LEN)) {
 
 			if (nchar > BD_DEF_LEN)
 				status |= DST_RBIT;
@@ -529,7 +529,7 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 				chan->rx_first_bd = (chan->rx_first_bd+1) & (N_DMA_RX_BUF-1);
 				if (status & DST_EOM)
 					break;
-				ptdescr = (card->hw.rambase +
+				ptdescr = (pcsca_bd_t *) (card->hw.rambase +
 							  cpc_readl(&ptdescr->next));
 				status = cpc_readb(&ptdescr->status);
 			}
@@ -538,7 +538,7 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 		if (nchar != 0) {
 			if (skb) {
 				memcpy_fromio(skb_put(skb, nchar),
-				 (card->hw.rambase+cpc_readl(&ptdescr->ptbuf)),nchar);
+				 (void *)(card->hw.rambase+cpc_readl(&ptdescr->ptbuf)),nchar);
 			}
 			rcvd += nchar;
 		}
@@ -549,7 +549,7 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 		if (status & DST_EOM)
 			break;
 
-		ptdescr = (card->hw.rambase + cpc_readl(&ptdescr->next));
+		ptdescr = (pcsca_bd_t *) (card->hw.rambase + cpc_readl(&ptdescr->next));
 	}
 
 	if (rcvd != 0) {
@@ -559,34 +559,34 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 		cpc_writel(card->hw.scabase + DRX_REG(EDAL, ch),
 			   RX_BD_ADDR(ch, chan->rx_last_bd));
 	}
-	return rcvd;
+	return (rcvd);
 }
 
-static void tx_dma_stop(pc300_t * card, int ch)
+void tx_dma_stop(pc300_t * card, int ch)
 {
-	void __iomem *scabase = card->hw.scabase;
-	u8 drr_ena_bit = 1 << (5 + 2 * ch);
-	u8 drr_rst_bit = 1 << (1 + 2 * ch);
+	uclong scabase = card->hw.scabase;
+	ucchar drr_ena_bit = 1 << (5 + 2 * ch);
+	ucchar drr_rst_bit = 1 << (1 + 2 * ch);
 
 	/* Disable DMA */
 	cpc_writeb(scabase + DRR, drr_ena_bit);
 	cpc_writeb(scabase + DRR, drr_rst_bit & ~drr_ena_bit);
 }
 
-static void rx_dma_stop(pc300_t * card, int ch)
+void rx_dma_stop(pc300_t * card, int ch)
 {
-	void __iomem *scabase = card->hw.scabase;
-	u8 drr_ena_bit = 1 << (4 + 2 * ch);
-	u8 drr_rst_bit = 1 << (2 * ch);
+	uclong scabase = card->hw.scabase;
+	ucchar drr_ena_bit = 1 << (4 + 2 * ch);
+	ucchar drr_rst_bit = 1 << (2 * ch);
 
 	/* Disable DMA */
 	cpc_writeb(scabase + DRR, drr_ena_bit);
 	cpc_writeb(scabase + DRR, drr_rst_bit & ~drr_ena_bit);
 }
 
-static void rx_dma_start(pc300_t * card, int ch)
+void rx_dma_start(pc300_t * card, int ch)
 {
-	void __iomem *scabase = card->hw.scabase;
+	uclong scabase = card->hw.scabase;
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	
 	/* Start DMA */
@@ -609,9 +609,9 @@ static void rx_dma_start(pc300_t * card, int ch)
 /*************************/
 /***   FALC Routines   ***/
 /*************************/
-static void falc_issue_cmd(pc300_t *card, int ch, u8 cmd)
+void falc_issue_cmd(pc300_t * card, int ch, ucchar cmd)
 {
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 	unsigned long i = 0;
 
 	while (cpc_readb(falcbase + F_REG(SIS, ch)) & SIS_CEC) {
@@ -624,12 +624,12 @@ static void falc_issue_cmd(pc300_t *card, int ch, u8 cmd)
 	cpc_writeb(falcbase + F_REG(CMDR, ch), cmd);
 }
 
-static void falc_intr_enable(pc300_t * card, int ch)
+void falc_intr_enable(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	/* Interrupt pins are open-drain */
 	cpc_writeb(falcbase + F_REG(IPC, ch),
@@ -674,10 +674,10 @@ static void falc_intr_enable(pc300_t * card, int ch)
 	}
 }
 
-static void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
+void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
 {
-	void __iomem *falcbase = card->hw.falcbase;
-	u8 tshf = card->chan[ch].falc.offset;
+	uclong falcbase = card->hw.falcbase;
+	ucchar tshf = card->chan[ch].falc.offset;
 
 	cpc_writeb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch),
 		   cpc_readb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch)) & 
@@ -690,10 +690,10 @@ static void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
 			(0x80 >> (timeslot & 0x07)));
 }
 
-static void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
+void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
 {
-	void __iomem *falcbase = card->hw.falcbase;
-	u8 tshf = card->chan[ch].falc.offset;
+	uclong falcbase = card->hw.falcbase;
+	ucchar tshf = card->chan[ch].falc.offset;
 
 	cpc_writeb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch),
 		   cpc_readb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch)) | 
@@ -706,11 +706,11 @@ static void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
 		   ~(0x80 >> (timeslot & 0x07)));
 }
 
-static void falc_close_all_timeslots(pc300_t * card, int ch)
+void falc_close_all_timeslots(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	cpc_writeb(falcbase + F_REG(ICB1, ch), 0xff);
 	cpc_writeb(falcbase + F_REG(TTR1, ch), 0);
@@ -728,11 +728,11 @@ static void falc_close_all_timeslots(pc300_t * card, int ch)
 	}
 }
 
-static void falc_open_all_timeslots(pc300_t * card, int ch)
+void falc_open_all_timeslots(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	cpc_writeb(falcbase + F_REG(ICB1, ch), 0);
 	if (conf->fr_mode == PC300_FR_UNFRAMED) {
@@ -760,7 +760,7 @@ static void falc_open_all_timeslots(pc300_t * card, int ch)
 	}
 }
 
-static void falc_init_timeslot(pc300_t * card, int ch)
+void falc_init_timeslot(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -778,7 +778,7 @@ static void falc_init_timeslot(pc300_t * card, int ch)
 	}
 }
 
-static void falc_enable_comm(pc300_t * card, int ch)
+void falc_enable_comm(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -794,7 +794,7 @@ static void falc_enable_comm(pc300_t * card, int ch)
 		   ~((CPLD_REG1_FALC_DCD | CPLD_REG1_FALC_CTS) << (2 * ch)));
 }
 
-static void falc_disable_comm(pc300_t * card, int ch)
+void falc_disable_comm(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -808,13 +808,13 @@ static void falc_disable_comm(pc300_t * card, int ch)
 		   ((CPLD_REG1_FALC_DCD | CPLD_REG1_FALC_CTS) << (2 * ch)));
 }
 
-static void falc_init_t1(pc300_t * card, int ch)
+void falc_init_t1(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
-	u8 dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
+	uclong falcbase = card->hw.falcbase;
+	ucchar dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
 
 	/* Switch to T1 mode (PCM 24) */
 	cpc_writeb(falcbase + F_REG(FMR1, ch), FMR1_PMOD);
@@ -977,13 +977,13 @@ static void falc_init_t1(pc300_t * card, int ch)
 	falc_close_all_timeslots(card, ch);
 }
 
-static void falc_init_e1(pc300_t * card, int ch)
+void falc_init_e1(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
-	u8 dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
+	uclong falcbase = card->hw.falcbase;
+	ucchar dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
 
 	/* Switch to E1 mode (PCM 30) */
 	cpc_writeb(falcbase + F_REG(FMR1, ch),
@@ -1157,9 +1157,9 @@ static void falc_init_e1(pc300_t * card, int ch)
 	falc_close_all_timeslots(card, ch);
 }
 
-static void falc_init_hdlc(pc300_t * card, int ch)
+void falc_init_hdlc(pc300_t * card, int ch)
 {
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 
@@ -1183,13 +1183,13 @@ static void falc_init_hdlc(pc300_t * card, int ch)
 	falc_intr_enable(card, ch);
 }
 
-static void te_config(pc300_t * card, int ch)
+void te_config(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
-	u8 dummy;
+	uclong falcbase = card->hw.falcbase;
+	ucchar dummy;
 	unsigned long flags;
 
 	memset(pfalc, 0, sizeof(falc_t));
@@ -1243,12 +1243,12 @@ static void te_config(pc300_t * card, int ch)
 	CPC_UNLOCK(card, flags);
 }
 
-static void falc_check_status(pc300_t * card, int ch, unsigned char frs0)
+void falc_check_status(pc300_t * card, int ch, unsigned char frs0)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	/* Verify LOS */
 	if (frs0 & FRS0_LOS) {
@@ -1399,13 +1399,13 @@ static void falc_check_status(pc300_t * card, int ch, unsigned char frs0)
 	}
 }
 
-static void falc_update_stats(pc300_t * card, int ch)
+void falc_update_stats(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
-	u16 counter;
+	uclong falcbase = card->hw.falcbase;
+	ucshort counter;
 
 	counter = cpc_readb(falcbase + F_REG(FECL, ch));
 	counter |= cpc_readb(falcbase + F_REG(FECH, ch)) << 8;
@@ -1431,7 +1431,8 @@ static void falc_update_stats(pc300_t * card, int ch)
 
 		if (((conf->media == IF_IFACE_T1) &&
 		     (cpc_readb(falcbase + F_REG(FRS1, ch)) & FRS1_LLBAD) &&
-		     (!(cpc_readb(falcbase + F_REG(FRS1, ch)) & FRS1_PDEN))) ||
+		     (!(cpc_readb(falcbase + F_REG(FRS1, ch)) & FRS1_PDEN)))
+		    ||
 		    ((conf->media == IF_IFACE_E1) &&
 		     (cpc_readb(falcbase + F_REG(RSP, ch)) & RSP_LLBAD))) {
 			pfalc->prbs = 2;
@@ -1447,16 +1448,16 @@ static void falc_update_stats(pc300_t * card, int ch)
  * Description:	In the remote loopback mode the clock and data recovered
  *		from the line inputs RL1/2 or RDIP/RDIN are routed back
  *		to the line outputs XL1/2 or XDOP/XDON via the analog
- *		transmitter. As in normal mode they are processed by
+ *		transmitter. As in normal mode they are processsed by
  *		the synchronizer and then sent to the system interface.
  *----------------------------------------------------------------------------
  */
-static void falc_remote_loop(pc300_t * card, int ch, int loop_on)
+void falc_remote_loop(pc300_t * card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	if (loop_on) {
 		// EVENT_FALC_ABNORMAL
@@ -1496,11 +1497,11 @@ static void falc_remote_loop(pc300_t * card, int ch, int loop_on)
  *		coding must be identical.
  *----------------------------------------------------------------------------
  */
-static void falc_local_loop(pc300_t * card, int ch, int loop_on)
+void falc_local_loop(pc300_t * card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	if (loop_on) {
 		cpc_writeb(falcbase + F_REG(LIM0, ch),
@@ -1523,12 +1524,12 @@ static void falc_local_loop(pc300_t * card, int ch, int loop_on)
  *		looped. They are originated by the FALC-LH transmitter.
  *----------------------------------------------------------------------------
  */
-static void falc_payload_loop(pc300_t * card, int ch, int loop_on)
+void falc_payload_loop(pc300_t * card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	if (loop_on) {
 		// EVENT_FALC_ABNORMAL
@@ -1577,11 +1578,11 @@ static void falc_payload_loop(pc300_t * card, int ch, int loop_on)
  * Description:	Turns XLU bit off in the proper register
  *----------------------------------------------------------------------------
  */
-static void turn_off_xlu(pc300_t * card, int ch)
+void turn_off_xlu(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1598,11 +1599,11 @@ static void turn_off_xlu(pc300_t * card, int ch)
  * Description: Turns XLD bit off in the proper register
  *----------------------------------------------------------------------------
  */
-static void turn_off_xld(pc300_t * card, int ch)
+void turn_off_xld(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1620,12 +1621,12 @@ static void turn_off_xld(pc300_t * card, int ch)
  *		to generate a LOOP activation code over a T1/E1 line.
  *----------------------------------------------------------------------------
  */
-static void falc_generate_loop_up_code(pc300_t * card, int ch)
+void falc_generate_loop_up_code(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1653,12 +1654,12 @@ static void falc_generate_loop_up_code(pc300_t * card, int ch)
  *		to generate a LOOP deactivation code over a T1/E1 line.
  *----------------------------------------------------------------------------
  */
-static void falc_generate_loop_down_code(pc300_t * card, int ch)
+void falc_generate_loop_down_code(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1683,12 +1684,12 @@ static void falc_generate_loop_down_code(pc300_t * card, int ch)
  *		it on the reception side.
  *----------------------------------------------------------------------------
  */
-static void falc_pattern_test(pc300_t * card, int ch, unsigned int activate)
+void falc_pattern_test(pc300_t * card, int ch, unsigned int activate)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	if (activate) {
 		pfalc->prbs = 1;
@@ -1730,12 +1731,12 @@ static void falc_pattern_test(pc300_t * card, int ch, unsigned int activate)
  * Description:	This routine returns the bit error counter value
  *----------------------------------------------------------------------------
  */
-static u16 falc_pattern_test_error(pc300_t * card, int ch)
+ucshort falc_pattern_test_error(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
 
-	return pfalc->bec;
+	return (pfalc->bec);
 }
 
 /**********************************/
@@ -1755,32 +1756,33 @@ cpc_trace(struct net_device *dev, struct sk_buff *skb_main, char rx_tx)
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_CUST);
-	skb_reset_mac_header(skb);
+	skb->mac.raw = skb->data;
 	skb->pkt_type = PACKET_HOST;
 	skb->len = 10 + skb_main->len;
 
-	skb_copy_to_linear_data(skb, dev->name, 5);
+	memcpy(skb->data, dev->name, 5);
 	skb->data[5] = '[';
 	skb->data[6] = rx_tx;
 	skb->data[7] = ']';
 	skb->data[8] = ':';
 	skb->data[9] = ' ';
-	skb_copy_from_linear_data(skb_main, &skb->data[10], skb_main->len);
+	memcpy(&skb->data[10], skb_main->data, skb_main->len);
 
 	netif_rx(skb);
 }
 
-static void cpc_tx_timeout(struct net_device *dev)
+void cpc_tx_timeout(struct net_device *dev)
 {
-	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
+	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
+	struct net_device_stats *stats = &d->hdlc->stats;
 	int ch = chan->channel;
-	unsigned long flags;
-	u8 ilar;
+	uclong flags;
+	ucchar ilar;
 
-	dev->stats.tx_errors++;
-	dev->stats.tx_aborted_errors++;
+	stats->tx_errors++;
+	stats->tx_aborted_errors++;
 	CPC_LOCK(card, flags);
 	if ((ilar = cpc_readb(card->hw.scabase + ILAR)) != 0) {
 		printk("%s: ILAR=0x%x\n", dev->name, ilar);
@@ -1792,32 +1794,37 @@ static void cpc_tx_timeout(struct net_device *dev)
 			   cpc_readb(card->hw.falcbase + card->hw.cpld_reg2) &
 			   ~(CPLD_REG2_FALC_LED1 << (2 * ch)));
 	}
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	dev->trans_start = jiffies;
 	CPC_UNLOCK(card, flags);
 	netif_wake_queue(dev);
 }
 
-static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
+int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
+	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
+	struct net_device_stats *stats = &d->hdlc->stats;
 	int ch = chan->channel;
-	unsigned long flags;
+	uclong flags;
 #ifdef PC300_DEBUG_TX
 	int i;
 #endif
 
-	if (!netif_carrier_ok(dev)) {
+	if (chan->conf.monitor) {
+		/* In monitor mode no Tx is done: ignore packet */
+		dev_kfree_skb(skb);
+		return 0;
+	} else if (!netif_carrier_ok(dev)) {
 		/* DCD must be OFF: drop packet */
 		dev_kfree_skb(skb);
-		dev->stats.tx_errors++;
-		dev->stats.tx_carrier_errors++;
+		stats->tx_errors++;
+		stats->tx_carrier_errors++;
 		return 0;
 	} else if (cpc_readb(card->hw.scabase + M_REG(ST3, ch)) & ST3_DCD) {
 		printk("%s: DCD is OFF. Going administrative down.\n", dev->name);
-		dev->stats.tx_errors++;
-		dev->stats.tx_carrier_errors++;
+		stats->tx_errors++;
+		stats->tx_carrier_errors++;
 		dev_kfree_skb(skb);
 		netif_carrier_off(dev);
 		CPC_LOCK(card, flags);
@@ -1833,12 +1840,12 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Write buffer to DMA buffers */
-	if (dma_buf_write(card, ch, (u8 *)skb->data, skb->len) != 0) {
+	if (dma_buf_write(card, ch, (ucchar *) skb->data, skb->len) != 0) {
 //		printk("%s: write error. Dropping TX packet.\n", dev->name);
 		netif_stop_queue(dev);
 		dev_kfree_skb(skb);
-		dev->stats.tx_errors++;
-		dev->stats.tx_dropped++;
+		stats->tx_errors++;
+		stats->tx_dropped++;
 		return 0;
 	}
 #ifdef PC300_DEBUG_TX
@@ -1851,6 +1858,7 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (d->trace_on) {
 		cpc_trace(dev, skb, 'T');
 	}
+	dev->trans_start = jiffies;
 
 	/* Start transmission */
 	CPC_LOCK(card, flags);
@@ -1874,11 +1882,13 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static void cpc_net_rx(struct net_device *dev)
+void cpc_net_rx(hdlc_device * hdlc)
 {
-	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
+	struct net_device *dev = hdlc_to_dev(hdlc);
+	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
+	struct net_device_stats *stats = &d->hdlc->stats;
 	int ch = chan->channel;
 #ifdef PC300_DEBUG_RX
 	int i;
@@ -1914,24 +1924,24 @@ static void cpc_net_rx(struct net_device *dev)
 #endif
 			if ((skb == NULL) && (rxb > 0)) {
 				/* rxb > dev->mtu */
-				dev->stats.rx_errors++;
-				dev->stats.rx_length_errors++;
+				stats->rx_errors++;
+				stats->rx_length_errors++;
 				continue;
 			}
 
 			if (rxb < 0) {	/* Invalid frame */
 				rxb = -rxb;
 				if (rxb & DST_OVR) {
-					dev->stats.rx_errors++;
-					dev->stats.rx_fifo_errors++;
+					stats->rx_errors++;
+					stats->rx_fifo_errors++;
 				}
 				if (rxb & DST_CRC) {
-					dev->stats.rx_errors++;
-					dev->stats.rx_crc_errors++;
+					stats->rx_errors++;
+					stats->rx_crc_errors++;
 				}
 				if (rxb & (DST_RBIT | DST_SHRT | DST_ABT)) {
-					dev->stats.rx_errors++;
-					dev->stats.rx_frame_errors++;
+					stats->rx_errors++;
+					stats->rx_frame_errors++;
 				}
 			}
 			if (skb) {
@@ -1940,7 +1950,7 @@ static void cpc_net_rx(struct net_device *dev)
 			continue;
 		}
 
-		dev->stats.rx_bytes += rxb;
+		stats->rx_bytes += rxb;
 
 #ifdef PC300_DEBUG_RX
 		printk("%s R:", dev->name);
@@ -1951,7 +1961,8 @@ static void cpc_net_rx(struct net_device *dev)
 		if (d->trace_on) {
 			cpc_trace(dev, skb, 'R');
 		}
-		dev->stats.rx_packets++;
+		stats->rx_packets++;
+		skb->mac.raw = skb->data;
 		skb->protocol = hdlc_type_trans(skb, dev);
 		netif_rx(skb);
 	}
@@ -1965,21 +1976,23 @@ static void sca_tx_intr(pc300dev_t *dev)
 	pc300ch_t *chan = (pc300ch_t *)dev->chan; 
 	pc300_t *card = (pc300_t *)chan->card; 
 	int ch = chan->channel; 
-	volatile pcsca_bd_t __iomem * ptdescr; 
+	volatile pcsca_bd_t * ptdescr; 
+	struct net_device_stats *stats = &dev->hdlc->stats; 
 
     /* Clean up descriptors from previous transmission */
-	ptdescr = (card->hw.rambase +
+	ptdescr = (pcsca_bd_t *)(card->hw.rambase +
 						TX_BD_ADDR(ch,chan->tx_first_bd));
-	while ((cpc_readl(card->hw.scabase + DTX_REG(CDAL,ch)) !=
-		TX_BD_ADDR(ch,chan->tx_first_bd)) &&
-	       (cpc_readb(&ptdescr->status) & DST_OSB)) {
-		dev->dev->stats.tx_packets++;
-		dev->dev->stats.tx_bytes += cpc_readw(&ptdescr->len);
+	while ((cpc_readl(card->hw.scabase + DTX_REG(CDAL,ch)) != 
+							TX_BD_ADDR(ch,chan->tx_first_bd)) && 
+			(cpc_readb(&ptdescr->status) & DST_OSB)) {
+		stats->tx_packets++;
+		stats->tx_bytes += cpc_readw(&ptdescr->len);
 		cpc_writeb(&ptdescr->status, DST_OSB);
 		cpc_writew(&ptdescr->len, 0);
 		chan->nfree_tx_bd++;
 		chan->tx_first_bd = (chan->tx_first_bd + 1) & (N_DMA_TX_BUF - 1);
-		ptdescr = (card->hw.rambase + TX_BD_ADDR(ch,chan->tx_first_bd));
+		ptdescr = (pcsca_bd_t *)(card->hw.rambase +
+						TX_BD_ADDR(ch,chan->tx_first_bd));
     }
 
 #ifdef CONFIG_PC300_MLPPP
@@ -1988,7 +2001,7 @@ static void sca_tx_intr(pc300dev_t *dev)
 	} else {
 #endif
 	/* Tell the upper layer we are ready to transmit more packets */
-		netif_wake_queue(dev->dev);
+		netif_wake_queue((struct net_device*)dev->hdlc);
 #ifdef CONFIG_PC300_MLPPP
 	}
 #endif
@@ -1996,8 +2009,8 @@ static void sca_tx_intr(pc300dev_t *dev)
 
 static void sca_intr(pc300_t * card)
 {
-	void __iomem *scabase = card->hw.scabase;
-	volatile u32 status;
+	uclong scabase = card->hw.scabase;
+	volatile uclong status;
 	int ch;
 	int intr_count = 0;
 	unsigned char dsr_rx;
@@ -2006,13 +2019,14 @@ static void sca_intr(pc300_t * card)
 		for (ch = 0; ch < card->hw.nchan; ch++) {
 			pc300ch_t *chan = &card->chan[ch];
 			pc300dev_t *d = &chan->d;
-			struct net_device *dev = d->dev;
+			hdlc_device *hdlc = d->hdlc;
+			struct net_device *dev = hdlc_to_dev(hdlc);
 
 			spin_lock(&card->card_lock);
 
 	    /**** Reception ****/
 			if (status & IR0_DRX((IR0_DMIA | IR0_DMIB), ch)) {
-				u8 drx_stat = cpc_readb(scabase + DSR_RX(ch));
+				ucchar drx_stat = cpc_readb(scabase + DSR_RX(ch));
 
 				/* Clear RX interrupts */
 				cpc_writeb(scabase + DSR_RX(ch), drx_stat | DSR_DWE);
@@ -2037,10 +2051,10 @@ static void sca_intr(pc300_t * card)
 							if ((cpc_readb(scabase + DSR_RX(ch)) & DSR_DE)) {
 								rx_dma_stop(card, ch);
 							}
-							cpc_net_rx(dev);
+							cpc_net_rx(hdlc);
 							/* Discard invalid frames */
-							dev->stats.rx_errors++;
-							dev->stats.rx_over_errors++;
+							hdlc->stats.rx_errors++;
+							hdlc->stats.rx_over_errors++;
 							chan->rx_first_bd = 0;
 							chan->rx_last_bd = N_DMA_RX_BUF - 1;
 							rx_dma_start(card, ch);
@@ -2061,10 +2075,10 @@ static void sca_intr(pc300_t * card)
 							/* verify if driver is TTY */
 							cpc_tty_receive(d);
 						} else {
-							cpc_net_rx(dev);
+							cpc_net_rx(hdlc);
 						}
 #else
-						cpc_net_rx(dev);
+						cpc_net_rx(hdlc);
 #endif
 						if (card->hw.type == PC300_TE) {
 							cpc_writeb(card->hw.falcbase +
@@ -2086,7 +2100,7 @@ static void sca_intr(pc300_t * card)
 
 	    /**** Transmission ****/
 			if (status & IR0_DTX((IR0_EFT | IR0_DMIA | IR0_DMIB), ch)) {
-				u8 dtx_stat = cpc_readb(scabase + DSR_TX(ch));
+				ucchar dtx_stat = cpc_readb(scabase + DSR_TX(ch));
 
 				/* Clear TX interrupts */
 				cpc_writeb(scabase + DSR_TX(ch), dtx_stat | DSR_DWE);
@@ -2106,8 +2120,8 @@ static void sca_intr(pc300_t * card)
 										   card->hw.cpld_reg2) &
 								   ~ (CPLD_REG2_FALC_LED1 << (2 * ch)));
 						}
-						dev->stats.tx_errors++;
-						dev->stats.tx_fifo_errors++;
+						hdlc->stats.tx_errors++;
+						hdlc->stats.tx_fifo_errors++;
 						sca_tx_intr(d);
 					}
 				}
@@ -2130,7 +2144,7 @@ static void sca_intr(pc300_t * card)
 
 	    /**** MSCI ****/
 			if (status & IR0_M(IR0_RXINTA, ch)) {
-				u8 st1 = cpc_readb(scabase + M_REG(ST1, ch));
+				ucchar st1 = cpc_readb(scabase + M_REG(ST1, ch));
 
 				/* Clear MSCI interrupts */
 				cpc_writeb(scabase + M_REG(ST1, ch), st1);
@@ -2172,11 +2186,11 @@ static void sca_intr(pc300_t * card)
 	}
 }
 
-static void falc_t1_loop_detection(pc300_t *card, int ch, u8 frs1)
+static void falc_t1_loop_detection(pc300_t * card, int ch, ucchar frs1)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	if (((cpc_readb(falcbase + F_REG(LCR1, ch)) & LCR1_XPRBS) == 0) &&
 	    !pfalc->loop_gen) {
@@ -2197,11 +2211,11 @@ static void falc_t1_loop_detection(pc300_t *card, int ch, u8 frs1)
 	}
 }
 
-static void falc_e1_loop_detection(pc300_t *card, int ch, u8 rsp)
+static void falc_e1_loop_detection(pc300_t * card, int ch, ucchar rsp)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uclong falcbase = card->hw.falcbase;
 
 	if (((cpc_readb(falcbase + F_REG(LCR1, ch)) & LCR1_XPRBS) == 0) &&
 	    !pfalc->loop_gen) {
@@ -2226,9 +2240,9 @@ static void falc_t1_intr(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
-	u8 isr0, isr3, gis;
-	u8 dummy;
+	uclong falcbase = card->hw.falcbase;
+	ucchar isr0, isr3, gis;
+	ucchar dummy;
 
 	while ((gis = cpc_readb(falcbase + F_REG(GIS, ch))) != 0) {
 		if (gis & GIS_ISR0) {
@@ -2273,9 +2287,9 @@ static void falc_e1_intr(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
-	u8 isr1, isr2, isr3, gis, rsp;
-	u8 dummy;
+	uclong falcbase = card->hw.falcbase;
+	ucchar isr1, isr2, isr3, gis, rsp;
+	ucchar dummy;
 
 	while ((gis = cpc_readb(falcbase + F_REG(GIS, ch))) != 0) {
 		rsp = cpc_readb(falcbase + F_REG(RSP, ch));
@@ -2286,8 +2300,8 @@ static void falc_e1_intr(pc300_t * card, int ch)
 		if (gis & GIS_ISR1) {
 			isr1 = cpc_readb(falcbase + F_REG(FISR1, ch));
 			if (isr1 & FISR1_XMB) {
-				if ((pfalc->xmb_cause & 2) &&
-				    pfalc->multiframe_mode) {
+				if ((pfalc->xmb_cause & 2)
+				    && pfalc->multiframe_mode) {
 					if (cpc_readb (falcbase + F_REG(FRS0, ch)) & 
 									(FRS0_LOS | FRS0_AIS | FRS0_LFA)) {
 						cpc_writeb(falcbase + F_REG(XSP, ch),
@@ -2354,19 +2368,19 @@ static void falc_intr(pc300_t * card)
 	}
 }
 
-static irqreturn_t cpc_intr(int irq, void *dev_id)
+static irqreturn_t cpc_intr(int irq, void *dev_id, struct pt_regs *regs)
 {
-	pc300_t *card = dev_id;
-	volatile u8 plx_status;
+	pc300_t *card;
+	volatile ucchar plx_status;
 
-	if (!card) {
+	if ((card = (pc300_t *) dev_id) == 0) {
 #ifdef PC300_DEBUG_INTR
 		printk("cpc_intr: spurious intr %d\n", irq);
 #endif
 		return IRQ_NONE;		/* spurious intr */
 	}
 
-	if (!card->hw.rambase) {
+	if (card->hw.rambase == 0) {
 #ifdef PC300_DEBUG_INTR
 		printk("cpc_intr: spurious intr2 %d\n", irq);
 #endif
@@ -2394,11 +2408,11 @@ static irqreturn_t cpc_intr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static void cpc_sca_status(pc300_t * card, int ch)
+void cpc_sca_status(pc300_t * card, int ch)
 {
-	u8 ilar;
-	void __iomem *scabase = card->hw.scabase;
-	unsigned long flags;
+	ucchar ilar;
+	uclong scabase = card->hw.scabase;
+	uclong flags;
 
 	tx_dma_buf_check(card, ch);
 	rx_dma_buf_check(card, ch);
@@ -2406,12 +2420,12 @@ static void cpc_sca_status(pc300_t * card, int ch)
 	printk ("ILAR=0x%02x, WCRL=0x%02x, PCR=0x%02x, BTCR=0x%02x, BOLR=0x%02x\n",
 		 ilar, cpc_readb(scabase + WCRL), cpc_readb(scabase + PCR),
 		 cpc_readb(scabase + BTCR), cpc_readb(scabase + BOLR));
-	printk("TX_CDA=0x%08x, TX_EDA=0x%08x\n",
-	       cpc_readl(scabase + DTX_REG(CDAL, ch)),
-	       cpc_readl(scabase + DTX_REG(EDAL, ch)));
-	printk("RX_CDA=0x%08x, RX_EDA=0x%08x, BFL=0x%04x\n",
-	       cpc_readl(scabase + DRX_REG(CDAL, ch)),
-	       cpc_readl(scabase + DRX_REG(EDAL, ch)),
+	printk("TX_CDA=0x%08lx, TX_EDA=0x%08lx\n",
+	       (uclong) cpc_readl(scabase + DTX_REG(CDAL, ch)),
+	       (uclong) cpc_readl(scabase + DTX_REG(EDAL, ch)));
+	printk("RX_CDA=0x%08lx, RX_EDA=0x%08lx, BFL=0x%04x\n",
+	       (uclong) cpc_readl(scabase + DRX_REG(CDAL, ch)),
+	       (uclong) cpc_readl(scabase + DRX_REG(EDAL, ch)),
 	       cpc_readw(scabase + DRX_REG(BFLL, ch)));
 	printk("DMER=0x%02x, DSR_TX=0x%02x, DSR_RX=0x%02x\n",
 	       cpc_readb(scabase + DMER), cpc_readb(scabase + DSR_TX(ch)),
@@ -2476,7 +2490,7 @@ static void cpc_sca_status(pc300_t * card, int ch)
 	       cpc_readb(scabase + M_REG(IE2, ch)),
 	       cpc_readb(scabase + M_REG(IE4, ch)),
 	       cpc_readb(scabase + M_REG(FIE, ch)));
-	printk("IER0=0x%08x\n", cpc_readl(scabase + IER0));
+	printk("IER0=0x%08lx\n", (uclong) cpc_readl(scabase + IER0));
 
 	if (ilar != 0) {
 		CPC_LOCK(card, flags);
@@ -2486,11 +2500,11 @@ static void cpc_sca_status(pc300_t * card, int ch)
 	}
 }
 
-static void cpc_falc_status(pc300_t * card, int ch)
+void cpc_falc_status(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = &card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	unsigned long flags;
+	uclong flags;
 
 	CPC_LOCK(card, flags);
 	printk("CH%d:   %s %s  %d channels\n",
@@ -2514,7 +2528,7 @@ static void cpc_falc_status(pc300_t * card, int ch)
 	CPC_UNLOCK(card, flags);
 }
 
-static int cpc_change_mtu(struct net_device *dev, int new_mtu)
+int cpc_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if ((new_mtu < 128) || (new_mtu > PC300_DEF_MTU))
 		return -EINVAL;
@@ -2522,17 +2536,18 @@ static int cpc_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
+	hdlc_device *hdlc = dev_to_hdlc(dev);
+	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	pc300conf_t conf_aux;
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	int ch = chan->channel;
-	void __user *arg = ifr->ifr_data;
+	void *arg = (void *) ifr->ifr_data;
 	struct if_settings *settings = &ifr->ifr_settings;
-	void __iomem *scabase = card->hw.scabase;
+	uclong scabase = card->hw.scabase;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -2541,10 +2556,10 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		case SIOCGPC300CONF:
 #ifdef CONFIG_PC300_MLPPP
 			if (conf->proto != PC300_PROTO_MLPPP) {
-				conf->proto = /* FIXME hdlc->proto.id */ 0;
+				conf->proto = hdlc->proto.id;
 			}
 #else
-			conf->proto = /* FIXME hdlc->proto.id */ 0;
+			conf->proto = hdlc->proto.id;
 #endif
 			memcpy(&conf_aux.conf, conf, sizeof(pc300chconf_t));
 			memcpy(&conf_aux.hw, &card->hw, sizeof(pc300hw_t));
@@ -2577,12 +2592,12 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 					}
 				} else {
 					memcpy(conf, &conf_aux.conf, sizeof(pc300chconf_t));
-					/* FIXME hdlc->proto.id = conf->proto; */
+					hdlc->proto.id = conf->proto;
 				}
 			}
 #else
 			memcpy(conf, &conf_aux.conf, sizeof(pc300chconf_t));
-			/* FIXME hdlc->proto.id = conf->proto; */
+			hdlc->proto.id = conf->proto;
 #endif
 			return 0;
 		case SIOCGPC300STATUS:
@@ -2595,7 +2610,7 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		case SIOCGPC300UTILSTATS:
 			{
 				if (!arg) {	/* clear statistics */
-					memset(&dev->stats, 0, sizeof(dev->stats));
+					memset(&hdlc->stats, 0, sizeof(struct net_device_stats));
 					if (card->hw.type == PC300_TE) {
 						memset(&chan->falc, 0, sizeof(falc_t));
 					}
@@ -2606,8 +2621,8 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 					pc300stats.hw_type = card->hw.type;
 					pc300stats.line_on = card->chan[ch].d.line_on;
 					pc300stats.line_off = card->chan[ch].d.line_off;
-					memcpy(&pc300stats.gen_stats, &dev->stats,
-					       sizeof(dev->stats));
+					memcpy(&pc300stats.gen_stats, &hdlc->stats,
+					       sizeof(struct net_device_stats));
 					if (card->hw.type == PC300_TE)
 						memcpy(&pc300stats.te_stats,&chan->falc,sizeof(falc_t));
 				    	if (copy_to_user(arg, &pc300stats, sizeof(pc300stats_t)))
@@ -2640,9 +2655,9 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 						!(cpc_readb (scabase + M_REG(CTL, ch)) & CTL_DTR);
 					/* There is no DSR in HD64572 */
 				}
-				if (!arg ||
-				    copy_to_user(arg, &pc300status, sizeof(pc300status_t)))
-					return -EINVAL;
+				if (!arg
+				    || copy_to_user(arg, &pc300status, sizeof(pc300status_t)))
+						return -EINVAL;
 				return 0;
 			}
 
@@ -2720,8 +2735,9 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 					}
 					pc300patrntst.num_errors =
 						falc_pattern_test_error(card, ch);
-					if (copy_to_user(arg, &pc300patrntst,
-							 sizeof(pc300patterntst_t)))
+					if (!arg
+					    || copy_to_user(arg, &pc300patrntst,
+							    sizeof (pc300patterntst_t)))
 							return -EINVAL;
 				} else {
 					falc_pattern_test(card, ch, pc300patrntst.patrntst_on);
@@ -2813,15 +2829,23 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	}
 }
 
-static int clock_rate_calc(u32 rate, u32 clock, int *br_io)
+static struct net_device_stats *cpc_get_stats(struct net_device *dev)
+{
+	pc300dev_t *d = (pc300dev_t *) dev->priv;
+
+	if (d)
+		return &d->hdlc->stats;
+	else
+		return NULL;
+}
+
+static int clock_rate_calc(uclong rate, uclong clock, int *br_io)
 {
 	int br, tc;
 	int br_pwr, error;
 
-	*br_io = 0;
-
 	if (rate == 0)
-		return 0;
+		return (0);
 
 	for (br = 0, br_pwr = 1; br <= 9; br++, br_pwr <<= 1) {
 		if ((tc = clock / br_pwr / rate) <= 0xff) {
@@ -2834,28 +2858,29 @@ static int clock_rate_calc(u32 rate, u32 clock, int *br_io)
 		error = ((rate - (clock / br_pwr / rate)) / rate) * 1000;
 		/* Errors bigger than +/- 1% won't be tolerated */
 		if (error < -10 || error > 10)
-			return -1;
+			return (-1);
 		else
-			return tc;
+			return (tc);
 	} else {
-		return -1;
+		return (-1);
 	}
 }
 
-static int ch_config(pc300dev_t * d)
+int ch_config(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	pc300_t *card = (pc300_t *) chan->card;
-	void __iomem *scabase = card->hw.scabase;
-	void __iomem *plxbase = card->hw.plxbase;
+	uclong scabase = card->hw.scabase;
+	uclong plxbase = card->hw.plxbase;
 	int ch = chan->channel;
-	u32 clkrate = chan->conf.phys_settings.clock_rate;
-	u32 clktype = chan->conf.phys_settings.clock_type;
-	u16 encoding = chan->conf.proto_settings.encoding;
-	u16 parity = chan->conf.proto_settings.parity;
-	u8 md0, md2;
-
+	uclong clkrate = chan->conf.phys_settings.clock_rate;
+	uclong clktype = chan->conf.phys_settings.clock_type;
+	ucshort encoding = chan->conf.proto_settings.encoding;
+	ucshort parity = chan->conf.proto_settings.parity;   
+	int tmc, br;
+	ucchar md0, md2;
+    
 	/* Reset the channel */
 	cpc_writeb(scabase + M_REG(CMD, ch), CMD_CH_RST);
 
@@ -2926,12 +2951,8 @@ static int ch_config(pc300dev_t * d)
 		case PC300_RSV:
 		case PC300_X21:
 			if (clktype == CLOCK_INT || clktype == CLOCK_TXINT) {
-				int tmc, br;
-
 				/* Calculate the clkrate parameters */
 				tmc = clock_rate_calc(clkrate, card->hw.clock, &br);
-				if (tmc < 0)
-					return -EIO;
 				cpc_writeb(scabase + M_REG(TMCT, ch), tmc);
 				cpc_writeb(scabase + M_REG(TXS, ch),
 					   (TXS_DTRXC | TXS_IBRG | br));
@@ -2993,11 +3014,11 @@ static int ch_config(pc300dev_t * d)
 	return 0;
 }
 
-static int rx_config(pc300dev_t * d)
+int rx_config(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	void __iomem *scabase = card->hw.scabase;
+	uclong scabase = card->hw.scabase;
 	int ch = chan->channel;
 
 	cpc_writeb(scabase + DSR_RX(ch), 0);
@@ -3024,11 +3045,11 @@ static int rx_config(pc300dev_t * d)
 	return 0;
 }
 
-static int tx_config(pc300dev_t * d)
+int tx_config(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	void __iomem *scabase = card->hw.scabase;
+	uclong scabase = card->hw.scabase;
 	int ch = chan->channel;
 
 	cpc_writeb(scabase + DSR_TX(ch), 0);
@@ -3056,10 +3077,11 @@ static int tx_config(pc300dev_t * d)
 	return 0;
 }
 
-static int cpc_attach(struct net_device *dev, unsigned short encoding,
+static int cpc_attach(hdlc_device * hdlc, unsigned short encoding,
 		      unsigned short parity)
 {
-	pc300dev_t *d = (pc300dev_t *)dev_to_hdlc(dev)->priv;
+	struct net_device * dev = hdlc_to_dev(hdlc);
+	pc300dev_t *d = (pc300dev_t *)dev->priv;
 	pc300ch_t *chan = (pc300ch_t *)d->chan;
 	pc300_t *card = (pc300_t *)chan->card;
 	pc300chconf_t *conf = (pc300chconf_t *)&chan->conf;
@@ -3087,16 +3109,14 @@ static int cpc_attach(struct net_device *dev, unsigned short encoding,
 	return 0;
 }
 
-static int cpc_opench(pc300dev_t * d)
+void cpc_opench(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	int ch = chan->channel, rc;
-	void __iomem *scabase = card->hw.scabase;
+	int ch = chan->channel;
+	uclong scabase = card->hw.scabase;
 
-	rc = ch_config(d);
-	if (rc)
-		return rc;
+	ch_config(d);
 
 	rx_config(d);
 
@@ -3105,11 +3125,9 @@ static int cpc_opench(pc300dev_t * d)
 	/* Assert RTS and DTR */
 	cpc_writeb(scabase + M_REG(CTL, ch),
 		   cpc_readb(scabase + M_REG(CTL, ch)) & ~(CTL_RTS | CTL_DTR));
-
-	return 0;
 }
 
-static void cpc_closech(pc300dev_t * d)
+void cpc_closech(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
@@ -3139,7 +3157,8 @@ static void cpc_closech(pc300dev_t * d)
 
 int cpc_open(struct net_device *dev)
 {
-	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
+	hdlc_device *hdlc = dev_to_hdlc(dev);
+	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	struct ifreq ifr;
 	int result;
 
@@ -3147,30 +3166,31 @@ int cpc_open(struct net_device *dev)
 	printk("pc300: cpc_open");
 #endif
 
-	result = hdlc_open(dev);
+	if (hdlc->proto.id == IF_PROTO_PPP) {
+		d->if_ptr = &hdlc->state.ppp.pppdev;
+	}
 
-	if (result)
+	result = hdlc_open(hdlc);
+	if (hdlc->proto.id == IF_PROTO_PPP) {
+		dev->priv = d;
+	}
+	if (result) {
 		return result;
+	}
 
 	sprintf(ifr.ifr_name, "%s", dev->name);
-	result = cpc_opench(d);
-	if (result)
-		goto err_out;
-
+	cpc_opench(d);
 	netif_start_queue(dev);
 	return 0;
-
-err_out:
-	hdlc_close(dev);
-	return result;
 }
 
-static int cpc_close(struct net_device *dev)
+int cpc_close(struct net_device *dev)
 {
-	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
+	hdlc_device *hdlc = dev_to_hdlc(dev);
+	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	unsigned long flags;
+	uclong flags;
 
 #ifdef	PC300_DEBUG_OTHER
 	printk("pc300: cpc_close");
@@ -3182,8 +3202,10 @@ static int cpc_close(struct net_device *dev)
 	cpc_closech(d);
 	CPC_UNLOCK(card, flags);
 
-	hdlc_close(dev);
-
+	hdlc_close(hdlc);
+	if (hdlc->proto.id == IF_PROTO_PPP) {
+		d->if_ptr = NULL;
+	}
 #ifdef CONFIG_PC300_MLPPP
 	if (chan->conf.proto == PC300_PROTO_MLPPP) {
 		cpc_tty_unregister_service(d);
@@ -3194,27 +3216,27 @@ static int cpc_close(struct net_device *dev)
 	return 0;
 }
 
-static u32 detect_ram(pc300_t * card)
+static uclong detect_ram(pc300_t * card)
 {
-	u32 i;
-	u8 data;
-	void __iomem *rambase = card->hw.rambase;
+	uclong i;
+	ucchar data;
+	uclong rambase = card->hw.rambase;
 
 	card->hw.ramsize = PC300_RAMSIZE;
 	/* Let's find out how much RAM is present on this board */
 	for (i = 0; i < card->hw.ramsize; i++) {
-		data = (u8)(i & 0xff);
+		data = (ucchar) (i & 0xff);
 		cpc_writeb(rambase + i, data);
 		if (cpc_readb(rambase + i) != data) {
 			break;
 		}
 	}
-	return i;
+	return (i);
 }
 
 static void plx_init(pc300_t * card)
 {
-	struct RUNTIME_9050 __iomem *plx_ctl = card->hw.plxbase;
+	struct RUNTIME_9050 *plx_ctl = (struct RUNTIME_9050 *) card->hw.plxbase;
 
 	/* Reset PLX */
 	cpc_writel(&plx_ctl->init_ctrl,
@@ -3244,19 +3266,10 @@ static inline void show_version(void)
 	rcsdate++;
 	tmp = strrchr(rcsdate, ' ');
 	*tmp = '\0';
-	pr_info("Cyclades-PC300 driver %s %s\n", rcsvers, rcsdate);
+	printk(KERN_INFO "Cyclades-PC300 driver %s %s (built %s %s)\n", 
+		rcsvers, rcsdate, __DATE__, __TIME__);
 }				/* show_version */
 
-static const struct net_device_ops cpc_netdev_ops = {
-	.ndo_open		= cpc_open,
-	.ndo_stop		= cpc_close,
-	.ndo_tx_timeout		= cpc_tx_timeout,
-	.ndo_set_mac_address	= NULL,
-	.ndo_change_mtu		= cpc_change_mtu,
-	.ndo_do_ioctl		= cpc_ioctl,
-	.ndo_validate_addr	= eth_validate_addr,
-};
-
 static void cpc_init_card(pc300_t * card)
 {
 	int i, devcount = 0;
@@ -3289,7 +3302,7 @@ static void cpc_init_card(pc300_t * card)
 	cpc_writeb(card->hw.scabase + DMER, 0x80);
 
 	if (card->hw.type == PC300_TE) {
-		u8 reg1;
+		ucchar reg1;
 
 		/* Check CPLD version */
 		reg1 = cpc_readb(card->hw.falcbase + CPLD_REG1);
@@ -3353,28 +3366,41 @@ static void cpc_init_card(pc300_t * card)
 		chan->nfree_tx_bd = N_DMA_TX_BUF;
 
 		d->chan = chan;
+		d->tx_skb = NULL;
 		d->trace_on = 0;
 		d->line_on = 0;
 		d->line_off = 0;
 
-		dev = alloc_hdlcdev(d);
-		if (dev == NULL)
+		d->hdlc = (hdlc_device *) kmalloc(sizeof(hdlc_device), GFP_KERNEL);
+		if (d->hdlc == NULL)
 			continue;
+		memset(d->hdlc, 0, sizeof(hdlc_device));
 
-		hdlc = dev_to_hdlc(dev);
+		hdlc = d->hdlc;
 		hdlc->xmit = cpc_queue_xmit;
 		hdlc->attach = cpc_attach;
-		d->dev = dev;
+
+		dev = hdlc_to_dev(hdlc);
+
 		dev->mem_start = card->hw.ramphys;
 		dev->mem_end = card->hw.ramphys + card->hw.ramsize - 1;
 		dev->irq = card->hw.irq;
+		dev->init = NULL;
 		dev->tx_queue_len = PC300_TX_QUEUE_LEN;
 		dev->mtu = PC300_DEF_MTU;
 
-		dev->netdev_ops = &cpc_netdev_ops;
+		dev->open = cpc_open;
+		dev->stop = cpc_close;
+		dev->tx_timeout = cpc_tx_timeout;
 		dev->watchdog_timeo = PC300_TX_TIMEOUT;
-
-		if (register_hdlc_device(dev) == 0) {
+		dev->get_stats = cpc_get_stats;
+		dev->set_multicast_list = NULL;
+		dev->set_mac_address = NULL;
+		dev->change_mtu = cpc_change_mtu;
+		dev->do_ioctl = cpc_ioctl;
+
+		if (register_hdlc_device(hdlc) == 0) {
+			dev->priv = d;	/* We need 'priv', hdlc doesn't */
 			printk("%s: Cyclades-PC300/", dev->name);
 			switch (card->hw.type) {
 				case PC300_TE:
@@ -3394,14 +3420,15 @@ static void cpc_init_card(pc300_t * card)
 					printk("RSV ");
 					break;
 			}
-			printk (" #%d, %dKB of RAM at 0x%08x, IRQ%d, channel %d.\n",
+			printk (" #%d, %ldKB of RAM at 0x%08lx, IRQ%d, channel %d.\n",
 				 board_nbr, card->hw.ramsize / 1024,
 				 card->hw.ramphys, card->hw.irq, i + 1);
 			devcount++;
 		} else {
-			printk ("Dev%d on card(0x%08x): unable to allocate i/f name.\n",
+			printk ("Dev%d on card(0x%08lx): unable to allocate i/f name.\n",
 				 i + 1, card->hw.ramphys);
-			free_netdev(dev);
+			*(dev->name) = 0;
+			kfree(d->hdlc);
 			continue;
 		}
 	}
@@ -3414,8 +3441,9 @@ static int __devinit
 cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int first_time = 1;
-	int err, eeprom_outdated = 0;
-	u16 device_id;
+	ucchar cpc_rev_id;
+	int err = 0, eeprom_outdated = 0;
+	ucshort device_id;
 	pc300_t *card;
 
 	if (first_time) {
@@ -3426,19 +3454,14 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #endif
 	}
 
-	if ((err = pci_enable_device(pdev)) < 0)
-		return err;
-
-	card = kzalloc(sizeof(pc300_t), GFP_KERNEL);
+	card = (pc300_t *) kmalloc(sizeof(pc300_t), GFP_KERNEL);
 	if (card == NULL) {
-		printk("PC300 found at RAM 0x%016llx, "
+		printk("PC300 found at RAM 0x%08lx, "
 		       "but could not allocate card structure.\n",
-		       (unsigned long long)pci_resource_start(pdev, 3));
-		err = -ENOMEM;
-		goto err_disable_dev;
+		       pci_resource_start(pdev, 3));
+		return -ENOMEM;
 	}
-
-	err = -ENODEV;
+	memset(card, 0, sizeof(pc300_t));
 
 	/* read PCI configuration area */
 	device_id = ent->device;
@@ -3453,6 +3476,7 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	card->hw.falcsize = pci_resource_len(pdev, 4);
 	card->hw.plxphys = pci_resource_start(pdev, 5);
 	card->hw.plxsize = pci_resource_len(pdev, 5);
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &cpc_rev_id);
 
 	switch (device_id) {
 		case PCI_DEVICE_ID_PC300_RX_1:
@@ -3470,7 +3494,7 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 #ifdef PC300_DEBUG_PCI
 	printk("cpc (bus=0x0%x,pci_id=0x%x,", pdev->bus->number, pdev->devfn);
-	printk("rev_id=%d) IRQ%d\n", pdev->revision, card->hw.irq);
+	printk("rev_id=%d) IRQ%d\n", cpc_rev_id, card->hw.irq);
 	printk("cpc:found  ramaddr=0x%08lx plxaddr=0x%08lx "
 	       "ctladdr=0x%08lx falcaddr=0x%08lx\n",
 	       card->hw.ramphys, card->hw.plxphys, card->hw.scaphys,
@@ -3482,7 +3506,7 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!request_region(card->hw.iophys, card->hw.iosize, "PLX Registers")) {
 		/* In case we can't allocate it, warn user */
 		printk("WARNING: couldn't allocate I/O region for PC300 board "
-		       "at 0x%08x!\n", card->hw.ramphys);
+		       "at 0x%08lx!\n", card->hw.ramphys);
 	}
 
 	if (card->hw.plxphys) {
@@ -3495,29 +3519,36 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	if (!request_mem_region(card->hw.plxphys, card->hw.plxsize,
 				"PLX Registers")) {
-		printk("PC300 found at RAM 0x%08x, "
+		printk("PC300 found at RAM 0x%08lx, "
 		       "but could not allocate PLX mem region.\n",
 		       card->hw.ramphys);
+		err = -ENODEV;
 		goto err_release_io;
 	}
 	if (!request_mem_region(card->hw.ramphys, card->hw.alloc_ramsize,
 				"On-board RAM")) {
-		printk("PC300 found at RAM 0x%08x, "
+		printk("PC300 found at RAM 0x%08lx, "
 		       "but could not allocate RAM mem region.\n",
 		       card->hw.ramphys);
+		err = -ENODEV;
 		goto err_release_plx;
 	}
 	if (!request_mem_region(card->hw.scaphys, card->hw.scasize,
 				"SCA-II Registers")) {
-		printk("PC300 found at RAM 0x%08x, "
+		printk("PC300 found at RAM 0x%08lx, "
 		       "but could not allocate SCA mem region.\n",
 		       card->hw.ramphys);
+		err = -ENODEV;
 		goto err_release_ram;
 	}
 
-	card->hw.plxbase = ioremap(card->hw.plxphys, card->hw.plxsize);
-	card->hw.rambase = ioremap(card->hw.ramphys, card->hw.alloc_ramsize);
-	card->hw.scabase = ioremap(card->hw.scaphys, card->hw.scasize);
+	if ((err = pci_enable_device(pdev)) != 0)
+		goto err_release_sca;
+
+	card->hw.plxbase = (uclong) ioremap(card->hw.plxphys, card->hw.plxsize);
+	card->hw.rambase = (uclong) ioremap(card->hw.ramphys,
+					    card->hw.alloc_ramsize);
+	card->hw.scabase = (uclong) ioremap(card->hw.scaphys, card->hw.scasize);
 	switch (device_id) {
 		case PCI_DEVICE_ID_PC300_TE_1:
 		case PCI_DEVICE_ID_PC300_TE_2:
@@ -3525,13 +3556,14 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		case PCI_DEVICE_ID_PC300_TE_M_2:
 			request_mem_region(card->hw.falcphys, card->hw.falcsize,
 					   "FALC Registers");
-			card->hw.falcbase = ioremap(card->hw.falcphys, card->hw.falcsize);
+			card->hw.falcbase = (uclong) ioremap(card->hw.falcphys,
+							     card->hw.falcsize);
 			break;
 
 		case PCI_DEVICE_ID_PC300_RX_1:
 		case PCI_DEVICE_ID_PC300_RX_2:
 		default:
-			card->hw.falcbase = NULL;
+			card->hw.falcbase = 0;
 			break;
 	}
 
@@ -3584,8 +3616,8 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	/* Allocate IRQ */
-	if (request_irq(card->hw.irq, cpc_intr, IRQF_SHARED, "Cyclades-PC300", card)) {
-		printk ("PC300 found at RAM 0x%08x, but could not allocate IRQ%d.\n",
+	if (request_irq(card->hw.irq, cpc_intr, SA_SHIRQ, "Cyclades-PC300", card)) {
+		printk ("PC300 found at RAM 0x%08lx, but could not allocate IRQ%d.\n",
 			 card->hw.ramphys, card->hw.irq);
 		goto err_io_unmap;
 	}
@@ -3597,13 +3629,14 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
 err_io_unmap:
-	iounmap(card->hw.plxbase);
-	iounmap(card->hw.scabase);
-	iounmap(card->hw.rambase);
+	iounmap((void *) card->hw.plxbase);
+	iounmap((void *) card->hw.scabase);
+	iounmap((void *) card->hw.rambase);
 	if (card->hw.type == PC300_TE) {
-		iounmap(card->hw.falcbase);
+		iounmap((void *) card->hw.falcbase);
 		release_mem_region(card->hw.falcphys, card->hw.falcsize);
 	}
+err_release_sca:
 	release_mem_region(card->hw.scaphys, card->hw.scasize);
 err_release_ram:
 	release_mem_region(card->hw.ramphys, card->hw.alloc_ramsize);
@@ -3612,16 +3645,14 @@ err_release_plx:
 err_release_io:
 	release_region(card->hw.iophys, card->hw.iosize);
 	kfree(card);
-err_disable_dev:
-	pci_disable_device(pdev);
-	return err;
+	return -ENODEV;
 }
 
 static void __devexit cpc_remove_one(struct pci_dev *pdev)
 {
 	pc300_t *card = pci_get_drvdata(pdev);
 
-	if (card->hw.rambase) {
+	if (card->hw.rambase != 0) {
 		int i;
 
 		/* Disable interrupts on the PCI bridge */
@@ -3629,26 +3660,22 @@ static void __devexit cpc_remove_one(struct pci_dev *pdev)
 			   cpc_readw(card->hw.plxbase + card->hw.intctl_reg) & ~(0x0040));
 
 		for (i = 0; i < card->hw.nchan; i++) {
-			unregister_hdlc_device(card->chan[i].d.dev);
+			unregister_hdlc_device(card->chan[i].d.hdlc);
 		}
-		iounmap(card->hw.plxbase);
-		iounmap(card->hw.scabase);
-		iounmap(card->hw.rambase);
+		iounmap((void *) card->hw.plxbase);
+		iounmap((void *) card->hw.scabase);
+		iounmap((void *) card->hw.rambase);
 		release_mem_region(card->hw.plxphys, card->hw.plxsize);
 		release_mem_region(card->hw.ramphys, card->hw.alloc_ramsize);
 		release_mem_region(card->hw.scaphys, card->hw.scasize);
 		release_region(card->hw.iophys, card->hw.iosize);
 		if (card->hw.type == PC300_TE) {
-			iounmap(card->hw.falcbase);
+			iounmap((void *) card->hw.falcbase);
 			release_mem_region(card->hw.falcphys, card->hw.falcsize);
 		}
-		for (i = 0; i < card->hw.nchan; i++)
-			if (card->chan[i].d.dev)
-				free_netdev(card->chan[i].d.dev);
 		if (card->hw.irq)
 			free_irq(card->hw.irq, card);
 		kfree(card);
-		pci_disable_device(pdev);
 	}
 }
 
@@ -3661,7 +3688,7 @@ static struct pci_driver cpc_driver = {
 
 static int __init cpc_init(void)
 {
-	return pci_register_driver(&cpc_driver);
+	return pci_module_init(&cpc_driver);
 }
 
 static void __exit cpc_cleanup_module(void)
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index d47d2cd..db1a21a 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -3,7 +3,7 @@
  *
  * Author:	Regina Kodato <reginak@cyclades.com>
  *
- * Copyright:	(c) 1999-2002 Cyclades Corp.
+ * Copyright:	(c) 1999-2004 Cyclades Corp.
  *
  *	This program is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU General Public License
@@ -38,6 +38,7 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
+#include <linux/pci.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/init.h>
@@ -111,28 +112,30 @@ typedef	struct _st_cpc_tty_area {
 static struct tty_driver serial_drv;
 
 /* local variables */
-static st_cpc_tty_area	cpc_tty_area[CPC_TTY_NPORTS];
+st_cpc_tty_area	cpc_tty_area[CPC_TTY_NPORTS];
 
-static int cpc_tty_cnt = 0;	/* number of intrfaces configured with MLPPP */
-static int cpc_tty_unreg_flag = 0;
+int cpc_tty_cnt=0;	/* number of intrfaces configured with MLPPP */
+int cpc_tty_unreg_flag = 0;
 
 /* TTY functions prototype */
 static int cpc_tty_open(struct tty_struct *tty, struct file *flip);
 static void cpc_tty_close(struct tty_struct *tty, struct file *flip);
-static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf, int count);
+static int cpc_tty_write(struct tty_struct *tty, int from_user,
+				const unsigned char *buf, int count);
 static int cpc_tty_write_room(struct tty_struct *tty);
 static int cpc_tty_chars_in_buffer(struct tty_struct *tty);
 static void cpc_tty_flush_buffer(struct tty_struct *tty);
 static void cpc_tty_hangup(struct tty_struct *tty);
-static void cpc_tty_rx_work(struct work_struct *work);
-static void cpc_tty_tx_work(struct work_struct *work);
+static void cpc_tty_rx_work(void *data);
+static void cpc_tty_tx_work(void *data);
 static int cpc_tty_send_to_card(pc300dev_t *dev,void *buf, int len);
 static void cpc_tty_trace(pc300dev_t *dev, char* buf, int len, char rxtx);
 static void cpc_tty_signal_off(pc300dev_t *pc300dev, unsigned char);
 static void cpc_tty_signal_on(pc300dev_t *pc300dev, unsigned char);
 
-static int pc300_tiocmset(struct tty_struct *, unsigned int, unsigned int);
-static int pc300_tiocmget(struct tty_struct *);
+int pc300_tiocmset(struct tty_struct *, struct file *,
+			unsigned int, unsigned int);
+int pc300_tiocmget(struct tty_struct *, struct file *);
 
 /* functions called by PC300 driver */
 void cpc_tty_init(pc300dev_t *dev);
@@ -152,7 +155,7 @@ static void cpc_tty_signal_off(pc300dev_t *pc300dev, unsigned char signal)
 	unsigned long flags; 
 
 	CPC_TTY_DBG("%s-tty: Clear signal %x\n",
-		pc300dev->dev->name, signal);
+		((struct net_device*)(pc300dev->hdlc))->name, signal);
 	CPC_TTY_LOCK(card, flags); 
 	cpc_writeb(card->hw.scabase + M_REG(CTL,ch), 
 		cpc_readb(card->hw.scabase+M_REG(CTL,ch))& signal);
@@ -170,27 +173,13 @@ static void cpc_tty_signal_on(pc300dev_t *pc300dev, unsigned char signal)
 	unsigned long flags; 
 
 	CPC_TTY_DBG("%s-tty: Set signal %x\n",
-		pc300dev->dev->name, signal);
+		((struct net_device*)(pc300dev->hdlc))->name, signal);
 	CPC_TTY_LOCK(card, flags); 
 	cpc_writeb(card->hw.scabase + M_REG(CTL,ch), 
 		cpc_readb(card->hw.scabase+M_REG(CTL,ch))& ~signal);
 	CPC_TTY_UNLOCK(card,flags); 
 }
 
-
-static const struct tty_operations pc300_ops = {
-	.open = cpc_tty_open,
-	.close = cpc_tty_close,
-	.write = cpc_tty_write,
-	.write_room = cpc_tty_write_room,
-	.chars_in_buffer = cpc_tty_chars_in_buffer,
-	.tiocmset = pc300_tiocmset,
-	.tiocmget = pc300_tiocmget,
-	.flush_buffer = cpc_tty_flush_buffer,
-	.hangup = cpc_tty_hangup,
-};
-
-
 /*
  * PC300 TTY initialization routine
  *
@@ -203,22 +192,21 @@ static const struct tty_operations pc300_ops = {
  */
 void cpc_tty_init(pc300dev_t *pc300dev)
 {
-	unsigned long port;
-	int aux;
+	int port, aux;
 	st_cpc_tty_area * cpc_tty;
 
 	/* hdlcX - X=interface number */
-	port = pc300dev->dev->name[4] - '0';
+	port = ((struct net_device*)(pc300dev->hdlc))->name[4] - '0';
 	if (port >= CPC_TTY_NPORTS) {
-		printk("%s-tty: invalid interface selected (0-%i): %li",
-			pc300dev->dev->name,
+		printk("%s-tty: invalid interface selected (0-%i): %i", 
+			((struct net_device*)(pc300dev->hdlc))->name,
 			CPC_TTY_NPORTS-1,port);
 		return;
 	}
 
 	if (cpc_tty_cnt == 0) { /* first TTY connection -> register driver */
 		CPC_TTY_DBG("%s-tty: driver init, major:%i, minor range:%i=%i\n",
-			pc300dev->dev->name,
+			((struct net_device*)(pc300dev->hdlc))->name,
 			CPC_TTY_MAJOR, CPC_TTY_MINOR_START,
 			CPC_TTY_MINOR_START+CPC_TTY_NPORTS);
 		/* initialize tty driver struct */
@@ -238,12 +226,20 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 		serial_drv.flags = TTY_DRIVER_REAL_RAW;
 
 		/* interface routines from the upper tty layer to the tty driver */
-		tty_set_operations(&serial_drv, &pc300_ops);
+		serial_drv.open = cpc_tty_open;
+		serial_drv.close = cpc_tty_close;
+		serial_drv.write = cpc_tty_write; 
+		serial_drv.write_room = cpc_tty_write_room; 
+		serial_drv.chars_in_buffer = cpc_tty_chars_in_buffer; 
+		serial_drv.tiocmset = pc300_tiocmset;
+		serial_drv.tiocmget = pc300_tiocmget;
+		serial_drv.flush_buffer = cpc_tty_flush_buffer; 
+		serial_drv.hangup = cpc_tty_hangup;
 
 		/* register the TTY driver */
 		if (tty_register_driver(&serial_drv)) { 
 			printk("%s-tty: Failed to register serial driver! ",
-				pc300dev->dev->name);
+				((struct net_device*)(pc300dev->hdlc))->name);
 		   	return;
 		} 
 
@@ -255,7 +251,7 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 	
 	if (cpc_tty->state != CPC_TTY_ST_IDLE) {
 		CPC_TTY_DBG("%s-tty: TTY port %i, already in use.\n",
-				pc300dev->dev->name, port);
+					((struct net_device*)(pc300dev->hdlc))->name,port);
 		return;
 	}
 
@@ -265,18 +261,18 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 	cpc_tty->tty_minor = port + CPC_TTY_MINOR_START;
 	cpc_tty->pc300dev = pc300dev; 
 
-	INIT_WORK(&cpc_tty->tty_tx_work, cpc_tty_tx_work);
-	INIT_WORK(&cpc_tty->tty_rx_work, cpc_tty_rx_work);
+	INIT_WORK(&cpc_tty->tty_tx_work, cpc_tty_tx_work, (void *)cpc_tty);
+	INIT_WORK(&cpc_tty->tty_rx_work, cpc_tty_rx_work, (void *)port);
 	
-	cpc_tty->buf_rx.first = cpc_tty->buf_rx.last = NULL;
+	cpc_tty->buf_rx.first = cpc_tty->buf_rx.last = 0;
 
 	pc300dev->cpc_tty = (void *)cpc_tty; 
 	
-	aux = strlen(pc300dev->dev->name);
-	memcpy(cpc_tty->name, pc300dev->dev->name, aux);
+	aux = strlen(((struct net_device*)(pc300dev->hdlc))->name);
+	memcpy(cpc_tty->name,((struct net_device*)(pc300dev->hdlc))->name,aux);
 	memcpy(&cpc_tty->name[aux], "-tty", 5);
 	
-	cpc_open(pc300dev->dev);
+	cpc_open((struct net_device *)pc300dev->hdlc);
 	cpc_tty_signal_off(pc300dev, CTL_DTR);
 
 	CPC_TTY_DBG("%s: Initializing TTY Sync Driver, tty major#%d minor#%i\n",
@@ -318,7 +314,7 @@ static int cpc_tty_open(struct tty_struct *tty, struct file *flip)
 	if (cpc_tty->num_open == 0) { /* first open of this tty */
 		if (!cpc_tty_area[port].buf_tx){
 			cpc_tty_area[port].buf_tx = kmalloc(CPC_TTY_MAX_MTU,GFP_KERNEL);
-			if (!cpc_tty_area[port].buf_tx) {
+			if (cpc_tty_area[port].buf_tx == 0){
 				CPC_TTY_DBG("%s: error in memory allocation\n",cpc_tty->name);
 				return -ENOMEM;
 			}
@@ -365,7 +361,7 @@ static void cpc_tty_close(struct tty_struct *tty, struct file *flip)
 	int res;
 
 	if (!tty || !tty->driver_data ) {
-		CPC_TTY_DBG("hdlx-tty: no TTY in close\n");
+		CPC_TTY_DBG("hdlx-tty: no TTY in close \n");
 		return;
 	}
 
@@ -404,8 +400,10 @@ static void cpc_tty_close(struct tty_struct *tty, struct file *flip)
 		cpc_tty->buf_rx.last = NULL;
 	}
 	
-	kfree(cpc_tty->buf_tx);
-	cpc_tty->buf_tx = NULL;
+	if (cpc_tty->buf_tx) {
+		kfree(cpc_tty->buf_tx);
+		cpc_tty->buf_tx = NULL;
+	}
 
 	CPC_TTY_DBG("%s: TTY closed\n",cpc_tty->name);
 	
@@ -428,7 +426,8 @@ static void cpc_tty_close(struct tty_struct *tty, struct file *flip)
  * o verify the DCD signal
  * o send characters to board and start the transmission
  */
-static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf, int count)
+static int cpc_tty_write(struct tty_struct *tty, int from_user,
+			const unsigned char *buf, int count)
 {
 	st_cpc_tty_area    *cpc_tty; 
 	pc300ch_t *pc300chan; 
@@ -454,10 +453,11 @@ static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf, int c
 		return -EINVAL;        /* frame too big */ 
 	}
 
-	CPC_TTY_DBG("%s: cpc_tty_write data len=%i\n",cpc_tty->name,count);
+	CPC_TTY_DBG("%s: cpc_tty_write %s data len=%i\n",cpc_tty->name,
+		(from_user)?"from user" : "from kernel",count);
 	
 	pc300chan = (pc300ch_t *)((pc300dev_t*)cpc_tty->pc300dev)->chan; 
-	stats = &cpc_tty->pc300dev->dev->stats;
+	stats = &((pc300dev_t*)cpc_tty->pc300dev)->hdlc->stats;
 	card = (pc300_t *) pc300chan->card;
 	ch = pc300chan->channel; 
 
@@ -481,10 +481,27 @@ static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf, int c
 		return -EINVAL; 
 	}
 
-	if (cpc_tty_send_to_card(cpc_tty->pc300dev, (void*)buf, count)) { 
-	   /* failed to send */
-	   CPC_TTY_DBG("%s: trasmition error\n", cpc_tty->name);
-	   return 0;
+	if (from_user) { 
+		unsigned char *buf_tmp; 
+
+		buf_tmp = cpc_tty->buf_tx;
+		if (copy_from_user(buf_tmp, buf, count)) { 
+			/* failed to copy from user */
+			CPC_TTY_DBG("%s: error in copy from user\n",cpc_tty->name);
+			return -EINVAL; 
+		}
+
+		if (cpc_tty_send_to_card(cpc_tty->pc300dev, (void*) buf_tmp,count)) { 
+			/* failed to send */ 
+			CPC_TTY_DBG("%s: transmission error\n",cpc_tty->name);
+			return 0; 
+		}
+	} else {
+		if (cpc_tty_send_to_card(cpc_tty->pc300dev, (void*)buf, count)) { 
+		   /* failed to send */
+		   CPC_TTY_DBG("%s: trasmition error\n", cpc_tty->name);
+		   return 0;
+		}
 	}
 	return count; 
 } 
@@ -539,15 +556,15 @@ static int cpc_tty_chars_in_buffer(struct tty_struct *tty)
 		return -ENODEV; 
 	}
    
-	return 0;
+	return(0); 
 } 
 
-static int pc300_tiocmset(struct tty_struct *tty,
-			  unsigned int set, unsigned int clear)
+int pc300_tiocmset(struct tty_struct *tty, struct file *file,
+			unsigned int set, unsigned int clear)
 {
 	st_cpc_tty_area    *cpc_tty; 
 
-	CPC_TTY_DBG("%s: set:%x clear:%x\n", __func__, set, clear);
+	CPC_TTY_DBG("%s: set:%x clear:%x\n", __FUNCTION__, set, clear);
 
 	if (!tty || !tty->driver_data ) {
 	   	CPC_TTY_DBG("hdlcX-tty: no TTY to chars in buffer\n");	
@@ -569,7 +586,7 @@ static int pc300_tiocmset(struct tty_struct *tty,
 	return 0;
 }
 
-static int pc300_tiocmget(struct tty_struct *tty)
+int pc300_tiocmget(struct tty_struct *tty, struct file *file)
 {
 	unsigned int result;
 	unsigned char status;
@@ -617,8 +634,14 @@ static void cpc_tty_flush_buffer(struct tty_struct *tty)
 	}
 
 	CPC_TTY_DBG("%s: call wake_up_interruptible\n",cpc_tty->name);
+	
+	wake_up_interruptible(&tty->write_wait); 
+
+	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) && tty->ldisc.write_wakeup){
+		CPC_TTY_DBG("%s: call line disc. wake up\n",cpc_tty->name);
+		tty->ldisc.write_wakeup(tty); 
+	} 
 
-	tty_wakeup(tty);	
 	return; 
 } 
 
@@ -663,39 +686,30 @@ static void cpc_tty_hangup(struct tty_struct *tty)
  * o call the line disc. read
  * o free memory
  */
-static void cpc_tty_rx_work(struct work_struct *work)
+static void cpc_tty_rx_work(void * data)
 {
-	st_cpc_tty_area *cpc_tty;
-	unsigned long port;
-	int i, j;
-	volatile st_cpc_rx_buf *buf;
+	int port, i, j;
+	st_cpc_tty_area *cpc_tty; 
+	st_cpc_rx_buf * buf;
 	char flags=0,flg_rx=1; 
-	struct tty_ldisc *ld;
 
 	if (cpc_tty_cnt == 0) return;
-	
+
 	for (i=0; (i < 4) && flg_rx ; i++) {
 		flg_rx = 0;
-
-		cpc_tty = container_of(work, st_cpc_tty_area, tty_rx_work);
-		port = cpc_tty - cpc_tty_area;
-
+		port = (int) data;
 		for (j=0; j < CPC_TTY_NPORTS; j++) {
 			cpc_tty = &cpc_tty_area[port];
 		
-			if ((buf=cpc_tty->buf_rx.first) != NULL) {
-				if (cpc_tty->tty) {
-					ld = tty_ldisc_ref(cpc_tty->tty);
-					if (ld) {
-						if (ld->ops->receive_buf) {
-							CPC_TTY_DBG("%s: call line disc. receive_buf\n",cpc_tty->name);
-							ld->ops->receive_buf(cpc_tty->tty, (char *)(buf->data), &flags, buf->size);
-						}
-						tty_ldisc_deref(ld);
-					}
+			if ((buf=cpc_tty->buf_rx.first) != 0) {
+															
+				if (cpc_tty->tty && (cpc_tty->tty->ldisc.receive_buf)) { 
+					CPC_TTY_DBG("%s: call line disc. receive_buf\n",cpc_tty->name);
+					cpc_tty->tty->ldisc.receive_buf(cpc_tty->tty, (char *)(buf->data), 
+					&flags, buf->size);
 				}	
 				cpc_tty->buf_rx.first = cpc_tty->buf_rx.first->next;
-				kfree((void *)buf);
+				kfree((unsigned char *)buf);
 				buf = cpc_tty->buf_rx.first;
 				flg_rx = 1;
 			}
@@ -714,13 +728,13 @@ static void cpc_tty_rx_work(struct work_struct *work)
  */
 static void cpc_tty_rx_disc_frame(pc300ch_t *pc300chan)
 {
-	volatile pcsca_bd_t __iomem * ptdescr; 
+	volatile pcsca_bd_t * ptdescr; 
 	volatile unsigned char status; 
 	pc300_t *card = (pc300_t *)pc300chan->card; 
 	int ch = pc300chan->channel; 
 
 	/* dma buf read */ 
-	ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase + 
+	ptdescr = (pcsca_bd_t *)(card->hw.rambase + 
 				RX_BD_ADDR(ch, pc300chan->rx_first_bd)); 
 	while (pc300chan->rx_first_bd != pc300chan->rx_last_bd) { 
 		status = cpc_readb(&ptdescr->status); 
@@ -731,22 +745,22 @@ static void cpc_tty_rx_disc_frame(pc300ch_t *pc300chan)
 		if (status & DST_EOM) { 
 			break; /* end of message */
 		}
-		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase + cpc_readl(&ptdescr->next)); 
+		ptdescr = (pcsca_bd_t *)(card->hw.rambase + cpc_readl(&ptdescr->next)); 
 	}
 }
 
 void cpc_tty_receive(pc300dev_t *pc300dev)
 {
-	st_cpc_tty_area *cpc_tty; 
+	st_cpc_tty_area    *cpc_tty; 
 	pc300ch_t *pc300chan = (pc300ch_t *)pc300dev->chan; 
 	pc300_t *card = (pc300_t *)pc300chan->card; 
 	int ch = pc300chan->channel; 
-	volatile pcsca_bd_t  __iomem * ptdescr; 
-	struct net_device_stats *stats = &pc300dev->dev->stats;
+	volatile pcsca_bd_t * ptdescr; 
+	struct net_device_stats *stats = &pc300dev->hdlc->stats; 
 	int rx_len, rx_aux; 
 	volatile unsigned char status; 
 	unsigned short first_bd = pc300chan->rx_first_bd;
-	st_cpc_rx_buf *new = NULL;
+	st_cpc_rx_buf	*new;
 	unsigned char dsr_rx;
 
 	if (pc300dev->cpc_tty == NULL) { 
@@ -759,14 +773,14 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 
 	while (1) { 
 		rx_len = 0;
-		ptdescr = (pcsca_bd_t  __iomem *)(card->hw.rambase + RX_BD_ADDR(ch, first_bd));
+		ptdescr = (pcsca_bd_t *)(card->hw.rambase + RX_BD_ADDR(ch, first_bd));
 		while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 			rx_len += cpc_readw(&ptdescr->len);
 			first_bd = (first_bd + 1) & (N_DMA_RX_BUF - 1);
 			if (status & DST_EOM) {
 				break;
 			}
-			ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase+cpc_readl(&ptdescr->next));
+			ptdescr=(pcsca_bd_t*)(card->hw.rambase+cpc_readl(&ptdescr->next));
 		}
 			
 		if (!rx_len) { 
@@ -775,7 +789,6 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 				cpc_writel(card->hw.scabase + DRX_REG(EDAL, ch), 
 						RX_BD_ADDR(ch, pc300chan->rx_last_bd)); 
 			}
-			kfree(new);
 			return; 
 		}
 		
@@ -788,14 +801,14 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 			continue;
 		} 
 		
-		new = kmalloc(rx_len + sizeof(st_cpc_rx_buf), GFP_ATOMIC);
-		if (!new) {
+		new = (st_cpc_rx_buf *) kmalloc(rx_len + sizeof(st_cpc_rx_buf), GFP_ATOMIC);
+		if (new == 0) {
 			cpc_tty_rx_disc_frame(pc300chan);
 			continue;
 		}
 		
 		/* dma buf read */ 
-		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase + 
+		ptdescr = (pcsca_bd_t *)(card->hw.rambase + 
 				RX_BD_ADDR(ch, pc300chan->rx_first_bd)); 
 
 		rx_len = 0;	/* counter frame size */
@@ -821,8 +834,7 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 						cpc_tty->name);
 				cpc_tty_rx_disc_frame(pc300chan);
 				rx_len = 0;
-				kfree(new);
-				new = NULL;
+				kfree((unsigned char *)new);
 				break; /* read next frame - while(1) */
 			}
 
@@ -831,15 +843,14 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 				cpc_tty_rx_disc_frame(pc300chan);
 				stats->rx_dropped++; 
 				rx_len = 0; 
-				kfree(new);
-				new = NULL;
+				kfree((unsigned char *)new);
 				break; /* read next frame - while(1) */
 			}
 
 			/* read the segment of the frame */
 			if (rx_aux != 0) {
 				memcpy_fromio((new->data + rx_len), 
-					(void __iomem *)(card->hw.rambase + 
+					(void *)(card->hw.rambase + 
 					 cpc_readl(&ptdescr->ptbuf)), rx_aux);
 				rx_len += rx_aux; 
 			}
@@ -849,7 +860,7 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 					(N_DMA_RX_BUF -1); 
 			if (status & DST_EOM)break;
 			
-			ptdescr = (pcsca_bd_t __iomem *) (card->hw.rambase + 
+			ptdescr = (pcsca_bd_t *) (card->hw.rambase + 
 					cpc_readl(&ptdescr->next)); 
 		}
 		/* update pointer */ 
@@ -867,8 +878,8 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 				cpc_tty_trace(pc300dev, new->data,rx_len, 'R'); 
 			} 
 			new->size = rx_len;
-			new->next = NULL;
-			if (cpc_tty->buf_rx.first == NULL) {
+			new->next = 0;
+			if (cpc_tty->buf_rx.first == 0) {
 				cpc_tty->buf_rx.first = new;
 				cpc_tty->buf_rx.last = new;
 			} else {
@@ -888,19 +899,24 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
  * o if need call line discipline wakeup
  * o call wake_up_interruptible
  */
-static void cpc_tty_tx_work(struct work_struct *work)
+static void cpc_tty_tx_work(void *data)
 {
-	st_cpc_tty_area *cpc_tty =
-		container_of(work, st_cpc_tty_area, tty_tx_work);
+	st_cpc_tty_area *cpc_tty = (st_cpc_tty_area *) data; 
 	struct tty_struct *tty; 
 
 	CPC_TTY_DBG("%s: cpc_tty_tx_work init\n",cpc_tty->name);
 	
-	if ((tty = cpc_tty->tty) == NULL) { 
+	if ((tty = cpc_tty->tty) == 0) { 
 		CPC_TTY_DBG("%s: the interface is not opened\n",cpc_tty->name);
 		return; 
 	}
-	tty_wakeup(tty);
+
+	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) && tty->ldisc.write_wakeup){
+		CPC_TTY_DBG("%s:call line disc. wakeup\n",cpc_tty->name);
+		tty->ldisc.write_wakeup (tty); 
+	}
+
+	wake_up_interruptible(&tty->write_wait); 
 }
 
 /*
@@ -916,9 +932,9 @@ static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
 	pc300ch_t *chan = (pc300ch_t *)dev->chan; 
 	pc300_t *card = (pc300_t *)chan->card; 
 	int ch = chan->channel; 
-	struct net_device_stats *stats = &dev->dev->stats;
+	struct net_device_stats *stats = &dev->hdlc->stats; 
 	unsigned long flags; 
-	volatile pcsca_bd_t __iomem *ptdescr; 
+	volatile pcsca_bd_t * ptdescr; 
 	int i, nchar;
 	int tosend = len;
 	int nbuf = ((len - 1)/BD_DEF_LEN) + 1;
@@ -935,11 +951,11 @@ static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
 	CPC_TTY_DBG("%s: call dma_buf_write\n",
 			(st_cpc_tty_area *)dev->cpc_tty->name);	
 	for (i = 0 ; i < nbuf ; i++) {
-		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase + 
+		ptdescr = (pcsca_bd_t *)(card->hw.rambase + 
 			TX_BD_ADDR(ch, card->chan[ch].tx_next_bd));
 		nchar = (BD_DEF_LEN > tosend) ? tosend : BD_DEF_LEN;
 		if (cpc_readb(&ptdescr->status) & DST_OSB) {
-			memcpy_toio((void __iomem *)(card->hw.rambase + 
+			memcpy_toio((void *)(card->hw.rambase + 
 				cpc_readl(&ptdescr->ptbuf)), 
 				&pdata[len - tosend], 
 				nchar);
@@ -1000,24 +1016,25 @@ static void cpc_tty_trace(pc300dev_t *dev, char* buf, int len, char rxtx)
 
 	if ((skb = dev_alloc_skb(10 + len)) == NULL) { 
 		/* out of memory */ 
-		CPC_TTY_DBG("%s: tty_trace - out of memory\n", dev->dev->name);
+		CPC_TTY_DBG("%s: tty_trace - out of memory\n",
+			((struct net_device *)(dev->hdlc))->name);
 		return; 
 	}
 
 	skb_put (skb, 10 + len); 
-	skb->dev = dev->dev; 
+	skb->dev = (struct net_device *) dev->hdlc; 
 	skb->protocol = htons(ETH_P_CUST); 
-	skb_reset_mac_header(skb);
+	skb->mac.raw = skb->data; 
 	skb->pkt_type = PACKET_HOST; 
 	skb->len = 10 + len; 
 
-	skb_copy_to_linear_data(skb, dev->dev->name, 5);
+	memcpy(skb->data,((struct net_device *)(dev->hdlc))->name,5);
 	skb->data[5] = '['; 
 	skb->data[6] = rxtx; 
 	skb->data[7] = ']'; 
 	skb->data[8] = ':'; 
 	skb->data[9] = ' '; 
-	skb_copy_to_linear_data_offset(skb, 10, buf, len);
+	memcpy(&skb->data[10], buf, len); 
 	netif_rx(skb); 
 } 	
 
@@ -1032,15 +1049,16 @@ void cpc_tty_unregister_service(pc300dev_t *pc300dev)
 	ulong flags;
 	int res;
 
-	if ((cpc_tty= (st_cpc_tty_area *) pc300dev->cpc_tty) == NULL) {
-		CPC_TTY_DBG("%s: interface is not TTY\n", pc300dev->dev->name);
+	if ((cpc_tty= (st_cpc_tty_area *) pc300dev->cpc_tty) == 0) { 
+		CPC_TTY_DBG("%s: interface is not TTY\n",
+			((struct net_device *)(pc300dev->hdlc))->name);
 		return; 
 	}
 	CPC_TTY_DBG("%s: cpc_tty_unregister_service", cpc_tty->name);
 
 	if (cpc_tty->pc300dev != pc300dev) { 
 		CPC_TTY_DBG("%s: invalid tty ptr=%s\n", 
-		pc300dev->dev->name, cpc_tty->name);
+		((struct net_device *)(pc300dev->hdlc))->name, cpc_tty->name);
 		return; 
 	}
 
