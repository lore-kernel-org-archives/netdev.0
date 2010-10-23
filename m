From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [PATCH] Fix PC-300 driver for 64-bit cleanliness and recent HDLC/tty_driver
Date: Sat, 23 Oct 2010 02:10:33 -0700
Message-ID: <20101023091033.GA30519@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an updated and fixed version of the Cyclades PC-300 WAN interface
driver which is presently marked 'Broken' in 2.6.36.  The version in the kernel
is based on Cyclades' version 3.23, and has many portability bugs as well as being
incompatible with recent tty_driver and HDLC changes (for values of recent < about
three years...).  Cyclades does not seem to be maintaining this driver any longer,
as the most recent version was released in 2005.

This patch merges in Cyclades' most recent version, 4.1.0, and updates it to work
with current kernel interfaces for tty_driver and HDLC, and fixes problems with
portability and 64-bit cleanliness.  It also contains some style fixups.

Due to some ioctls using non-portable interfaces (specifically, passing kernel
pointers and unsigned longs out to userland, which fails in the case of a 32-bit
process on a 64-bit kernel), some of the structures involved have been redesigned.
Thus, a new version of the userland package, pc300utils, is required.  This me
obtained at:

http://charon.persephoneslair.org/~andrea/software/pc300utils/

This patch is tested and known to work on a sparc64 kernel with a single-port
Cyclades PC-300 TE1 board using a full T1 circuit, with both 32-bit and 64-bit
userland utilities.

I am not subscribed to this list, so please CC me on replies.

-- 
Andrea Shepard

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff -Npur -X linux-2.6.36/Documentation/dontdiff linux-2.6.36/drivers/net/wan/Kconfig linux-2.6.36-pc300/drivers/net/wan/Kconfig
--- linux-2.6.36/drivers/net/wan/Kconfig	2010-10-20 13:30:22.000000000 -0700
+++ linux-2.6.36-pc300/drivers/net/wan/Kconfig	2010-10-23 01:48:42.000000000 -0700
@@ -205,10 +205,8 @@ config WANXL_BUILD_FIRMWARE
 
 config PC300
 	tristate "Cyclades-PC300 support (RS-232/V.35, X.21, T1/E1 boards)"
-	depends on HDLC && PCI && BROKEN
+	depends on HDLC && PCI
 	---help---
-	  This driver is broken because of struct tty_driver change.
-
 	  Driver for the Cyclades-PC300 synchronous communication boards.
 
 	  These boards provide synchronous serial interfaces to your
@@ -217,6 +215,10 @@ config PC300
 	  option later and read the file README.mlppp provided by PC300
 	  package.
 
+          Due to changes in certain ioctls necessary for portability, this
+          version requires a new version of pc300utils, which may be found
+          at: http://charon.persephoneslair.org/~andrea/software/pc300utils/
+
 	  To compile this as a module, choose M here: the module
 	  will be called pc300.
 
@@ -228,11 +230,8 @@ config PC300_MLPPP
 	help
 	  Multilink PPP over the PC300 synchronous communication boards.
 
-comment "Cyclades-PC300 MLPPP support is disabled."
-	depends on HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
-
 comment "Refer to the file README.mlppp, provided by PC300 package."
-	depends on HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
+	depends on HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP) && PC300_MLPPP
 
 config PC300TOO
 	tristate "Cyclades PC300 RSV/X21 alternative support"
diff -Npur -X linux-2.6.36/Documentation/dontdiff linux-2.6.36/drivers/net/wan/hd64572.h linux-2.6.36-pc300/drivers/net/wan/hd64572.h
--- linux-2.6.36/drivers/net/wan/hd64572.h	2010-10-20 13:30:22.000000000 -0700
+++ linux-2.6.36-pc300/drivers/net/wan/hd64572.h	2010-10-22 22:43:56.000000000 -0700
@@ -4,7 +4,7 @@
  *
  * Author:	Ivan Passos <ivan@cyclades.com>
  *
- * Copyright:   (c) 2000-2001 Cyclades Corp.
+ * Copyright:   (c) 2000-2004 Cyclades Corp.
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
@@ -172,11 +172,11 @@
 
 /* Block Descriptor Structure */
 typedef struct {
-	unsigned long	next;		/* pointer to next block descriptor */
-	unsigned long	ptbuf;		/* buffer pointer */
-	unsigned short	len;		/* data length */
-	unsigned char	status;		/* status */
-	unsigned char	filler[5];	/* alignment filler (16 bytes) */ 
+	u32	next;		/* pointer to next block descriptor */
+	u32	ptbuf;		/* buffer pointer */
+	u16	len;		/* data length */
+	u8	status;		/* status */
+	u8	filler[5];	/* alignment filler (16 bytes) */
 } pcsca_bd_t;
 
 /* Block Descriptor Structure */
diff -Npur -X linux-2.6.36/Documentation/dontdiff linux-2.6.36/drivers/net/wan/pc300-falc-lh.h linux-2.6.36-pc300/drivers/net/wan/pc300-falc-lh.h
--- linux-2.6.36/drivers/net/wan/pc300-falc-lh.h	2010-10-20 13:30:22.000000000 -0700
+++ linux-2.6.36-pc300/drivers/net/wan/pc300-falc-lh.h	2010-10-20 20:34:58.000000000 -0700
@@ -3,7 +3,7 @@
  *
  * Author:	Ivan Passos <ivan@cyclades.com>
  *
- * Copyright:	(c) 2000-2001 Cyclades Corp.
+ * Copyright:	(c) 2000-2004 Cyclades Corp.
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
diff -Npur -X linux-2.6.36/Documentation/dontdiff linux-2.6.36/drivers/net/wan/pc300.h linux-2.6.36-pc300/drivers/net/wan/pc300.h
--- linux-2.6.36/drivers/net/wan/pc300.h	2010-10-20 13:30:22.000000000 -0700
+++ linux-2.6.36-pc300/drivers/net/wan/pc300.h	2010-10-22 23:04:36.000000000 -0700
@@ -3,7 +3,7 @@
  *
  * Author:	Ivan Passos <ivan@cyclades.com>
  *
- * Copyright:	(c) 1999-2002 Cyclades Corp.
+ * Copyright:	(c) 1999-2004 Cyclades Corp.
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
@@ -105,9 +105,17 @@
 
 #define PC300_PROTO_MLPPP 1
 
+#define PC300_KERNEL	"2.6.x"	/* Kernel supported by this driver */
+
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
@@ -143,13 +151,28 @@
  * Memory access functions/macros      *
  * (required to support Alpha systems) *
  ***************************************/
-#define cpc_writeb(port,val)	{writeb((u8)(val),(port)); mb();}
-#define cpc_writew(port,val)	{writew((ushort)(val),(port)); mb();}
-#define cpc_writel(port,val)	{writel((u32)(val),(port)); mb();}
-
-#define cpc_readb(port)		readb(port)
-#define cpc_readw(port)		readw(port)
-#define cpc_readl(port)		readl(port)
+#ifdef __KERNEL__
+#define cpc_writeb(port, val)	{writeb((u8)(val), \
+				(void __iomem *)(port)); mb(); }
+#define cpc_writew(port, val)	{writew((u16)(val), \
+				(void __iomem *)(port)); mb(); }
+#define cpc_writel(port, val)	{writel((u32)(val), \
+				(void __iomem *)(port)); mb(); }
+
+#define cpc_readb(port)		readb((void __iomem *)(port))
+#define cpc_readw(port)		readw((void __iomem *)(port))
+#define cpc_readl(port)		readl((void __iomem *)(port))
+
+#else /* __KERNEL__ */
+#define cpc_writeb(port, val)	(*(u8 *)(port) = (u8)(val))
+#define cpc_writew(port, val)	(*(u16 *)(port) = (u16)(val))
+#define cpc_writel(port, val)	(*(u32 *)(port) = (u32)(val))
+
+#define cpc_readb(port)		(*(u8 *)(port))
+#define cpc_readw(port)		(*(u16 *)(port))
+#define cpc_readl(port)		(*(u32 *)(port))
+
+#endif /* __KERNEL__ */
 
 /****** Data Structures *****************************************************/
 
@@ -267,11 +290,47 @@ typedef struct rsv_x21_status {
 	u8 dtr;
 } rsv_x21_status_t;
 
+struct pc300_net_stats {
+	u64 rx_packets;
+	u64 tx_packets;
+	u64 rx_bytes;
+	u64 tx_bytes;
+	u64 rx_errors;
+	u64 tx_errors;
+	u64 rx_dropped;
+	u64 tx_dropped;
+	u64 multicast;
+	u64 collisions;
+
+	/* detailed rx_errors: */
+	u64 rx_length_errors;
+	u64 rx_over_errors;
+	u64 rx_crc_errors;
+	u64 rx_frame_errors;
+	u64 rx_fifo_errors;
+	u64 rx_missed_errors;
+
+	/* detailed tx_errors */
+	u64 tx_aborted_errors;
+	u64 tx_carrier_errors;
+	u64 tx_fifo_errors;
+	u64 tx_heartbeat_errors;
+	u64 tx_window_errors;
+
+	u64 rx_compressed;
+	u64 tx_compressed;
+};
+
 typedef struct pc300stats {
 	int hw_type;
 	u32 line_on;
 	u32 line_off;
-	struct net_device_stats gen_stats;
+	/* Use this instead of net_device_stats, since passing
+	 * net_device_stats breaks 32-bit user processes on 64-bit kernels,
+	 * and rtnetlink is unreasonably complicated just to get
+	 * some statistics.
+	 */
+	struct pc300_net_stats net_stats;
 	falc_t te_stats;
 } pc300stats_t;
 
@@ -291,16 +350,31 @@ typedef struct pc300patterntst {
 	u16 num_errors;
 } pc300patterntst_t;
 
+#ifdef __KERNEL__
+
 typedef struct pc300dev {
 	struct pc300ch *chan;
 	u8 trace_on;
 	u32 line_on;		/* DCD(X.21, RSV) / sync(TE) change counters */
 	u32 line_off;
+#ifdef __KERNEL__
 	char name[16];
-	struct net_device *dev;
+	hdlc_device *hdlc;
+	struct net_device *netdev;
+
+	void *private;
+	struct sk_buff *tx_skb;
+
+	enum {
+	  CPC_DMA_FULL,
+	  CPC_DMA_ERROR,
+	  TRANSMISSION_ACTIVE,
+	  CHANNEL_CLOSED
+	} reason_stopped;
 #ifdef CONFIG_PC300_MLPPP
 	void *cpc_tty;	/* information to PC300 TTY driver */
 #endif
+#endif /* __KERNEL__ */
 }pc300dev_t;
 
 typedef struct pc300hw {
@@ -314,29 +388,60 @@ typedef struct pc300hw {
 	u16 cpld_reg2;		/* CPLD reg 2 (TE only) */
 	u16 gpioc_reg;		/* PLX GPIOC reg */
 	u16 intctl_reg;		/* PLX Int Ctrl/Status reg */
-	u32 iophys;		/* PLX registers I/O base */
+	phys_addr_t iophys;	/* PLX registers I/O base */
 	u32 iosize;		/* PLX registers I/O size */
-	u32 plxphys;		/* PLX registers MMIO base (physical) */
+	phys_addr_t plxphys;	/* PLX registers MMIO base (physical) */
 	void __iomem * plxbase;	/* PLX registers MMIO base (virtual) */
 	u32 plxsize;		/* PLX registers MMIO size */
-	u32 scaphys;		/* SCA registers MMIO base (physical) */
+	phys_addr_t scaphys;	/* SCA registers MMIO base (physical) */
 	void __iomem * scabase;	/* SCA registers MMIO base (virtual) */
 	u32 scasize;		/* SCA registers MMIO size */
-	u32 ramphys;		/* On-board RAM MMIO base (physical) */
+	phys_addr_t ramphys;	/* On-board RAM MMIO base (physical) */
 	void __iomem * rambase;	/* On-board RAM MMIO base (virtual) */
 	u32 alloc_ramsize;	/* RAM MMIO size allocated by the PCI bridge */
 	u32 ramsize;		/* On-board RAM MMIO size */
-	u32 falcphys;		/* FALC registers MMIO base (physical) */
+	phys_addr_t falcphys;	/* FALC registers MMIO base (physical) */
 	void __iomem * falcbase;/* FALC registers MMIO base (virtual) */
 	u32 falcsize;		/* FALC registers MMIO size */
 } pc300hw_t;
 
+#endif /* __KERNEL__ */
+
+/*
+ * It's problematic to pass the addresses out to userland, since their sizes
+ * are so platform-dependent.  The userland pc300cfg program might be 32-bit
+ * even on a 64-bit kernel, and in any case it can't see phys_addr_t.  Since
+ * this information isn't even very interesting and in any case is visible in
+ * from the printk() calls when we init, just leave it out when responding to
+ * SIOCGPC300CONF.
+ */
+
+struct pc300hw_user {
+	int type;               /* RSV, X21, etc. */
+	int bus;                /* Bus (PCI, PMC, etc.) */
+	int nchan;              /* number of channels */
+	int irq;                /* interrupt request level */
+	u32 clock;              /* Board clock */
+	u8 cpld_id;             /* CPLD ID (TE only) */
+	u16 cpld_reg1;          /* CPLD reg 1 (TE only) */
+	u16 cpld_reg2;          /* CPLD reg 2 (TE only) */
+	u16 gpioc_reg;          /* PLX GPIOC reg */
+	u16 intctl_reg;         /* PLX Int Ctrl/Status reg */
+	u32 iosize;             /* PLX registers I/O size */
+	u32 plxsize;            /* PLX registers MMIO size */
+	u32 scasize;            /* SCA registers MMIO size */
+	u32 alloc_ramsize;      /* RAM MMIO size allocated by the PCI bridge */
+	u32 ramsize;            /* On-board RAM MMIO size */
+	u32 falcsize;           /* FALC registers MMIO size */
+};
+
 typedef struct pc300chconf {
 	sync_serial_settings	phys_settings;	/* Clock type/rate (in bps),
 						   loopback mode */
 	raw_hdlc_proto		proto_settings;	/* Encoding, parity (CRC) */
 	u32 media;		/* HW media (RS232, V.35, etc.) */
 	u32 proto;		/* Protocol (PPP, X.25, etc.) */
+	u8 monitor;		/* Monitor mode (0 = off, !0 = on) */
 
 	/* TE-specific parameters */
 	u8 lcode;		/* Line Code (AMI, B8ZS, etc.) */
@@ -346,6 +451,8 @@ typedef struct pc300chconf {
 	u32 tslot_bitmap;	/* bit[i]=1  =>  timeslot _i_ is active */
 } pc300chconf_t;
 
+#ifdef __KERNEL__
+
 typedef struct pc300ch {
 	struct pc300 *card;
 	int channel;
@@ -365,8 +472,10 @@ typedef struct pc300 {
 	spinlock_t card_lock;
 } pc300_t;
 
+#endif /* __KERNEL__ */
+
 typedef struct pc300conf {
-	pc300hw_t hw;
+	struct pc300hw_user hw;
 	pc300chconf_t conf;
 } pc300conf_t;
 
@@ -430,7 +539,8 @@ enum pc300_loopback_cmds {
 #define PC300_TX_QUEUE_LEN	100
 #define	PC300_DEF_MTU		1600
 
-/* Function Prototypes */
-int cpc_open(struct net_device *dev);
+#ifdef __KERNEL__
+int cpc_open(struct net_device *);
+#endif /* __KERNEL__ */
 
 #endif	/* _PC300_H */
diff -Npur -X linux-2.6.36/Documentation/dontdiff linux-2.6.36/drivers/net/wan/pc300_drv.c linux-2.6.36-pc300/drivers/net/wan/pc300_drv.c
--- linux-2.6.36/drivers/net/wan/pc300_drv.c	2010-10-20 13:30:22.000000000 -0700
+++ linux-2.6.36-pc300/drivers/net/wan/pc300_drv.c	2010-10-23 01:46:19.000000000 -0700
@@ -1,6 +1,6 @@
 #define	USE_PCI_CLOCK
 static char rcsid[] = 
-"Revision: 3.4.5 Date: 2002/03/07 ";
+"Revision: 4.1.0 Date: 2004/02/20 ";
 
 /*
  * pc300.c	Cyclades-PC300(tm) Driver.
@@ -8,7 +8,7 @@ static char rcsid[] = 
  * Author:	Ivan Passos <ivan@cyclades.com>
  * Maintainer:	PC300 Maintainer <pc300@cyclades.com>
  *
- * Copyright:	(c) 1999-2003 Cyclades Corp.
+ * Copyright:	(c) 1999-2004 Cyclades Corp.
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
@@ -16,6 +16,13 @@ static char rcsid[] = 
  *	2 of the License, or (at your option) any later version.
  *	
  *	Using tabstop = 4.
+ *
+ * Cyclades version 4.1.0 merged in, with new portability fixes,
+ * and ported to recent kernels by Andrea Shepard <andrea@persephoneslair.org>
+ *
+ * Due to changes in certain ioctls necessary for portability, this
+ * version requires a new version of pc300utils, which may be found
+ * at: http://charon.persephoneslair.org/~andrea/software/pc300utils/
  * 
  * $Log: pc300_drv.c,v $
  * Revision 3.23  2002/03/20 13:58:40  henrique
@@ -236,21 +243,22 @@ static char rcsid[] = 
 
 #include "pc300.h"
 
-#define	CPC_LOCK(card,flags)		\
-		do {						\
-		spin_lock_irqsave(&card->card_lock, flags);	\
-		} while (0)
-
-#define CPC_UNLOCK(card,flags)			\
-		do {							\
-		spin_unlock_irqrestore(&card->card_lock, flags);	\
-		} while (0)
+#define	CPC_LOCK(card, flags) \
+		{ \
+		    spin_lock_irqsave(&((card)->card_lock), (flags)); \
+		}
+
+#define CPC_UNLOCK(card, flags) \
+		{ \
+		    spin_unlock_irqrestore(&((card)->card_lock), (flags)); \
+		}
 
 #undef	PC300_DEBUG_PCI
 #undef	PC300_DEBUG_INTR
 #undef	PC300_DEBUG_TX
 #undef	PC300_DEBUG_RX
 #undef	PC300_DEBUG_OTHER
+#undef  PC300_DEBUG_QUEUE
 
 static DEFINE_PCI_DEVICE_TABLE(cpc_pci_dev_id) = {
 	/* PC300/RSV or PC300/X21, 2 chan */
@@ -277,20 +285,88 @@ MODULE_DEVICE_TABLE(pci, cpc_pci_dev_id)
 #define	cpc_max(a,b)	(((a)>(b))?(a):(b))
 #endif
 
-/* prototypes */
-static void tx_dma_buf_pt_init(pc300_t *, int);
-static void tx_dma_buf_init(pc300_t *, int);
-static void rx_dma_buf_pt_init(pc300_t *, int);
+/* DMA routines */
+static int dma_buf_read(pc300_t *, int, struct sk_buff *);
+static int dma_buf_write(pc300_t *, int, u8 *, int);
+static int dma_get_rx_frame_size(pc300_t *, int);
+static void rx_dma_buf_check(pc300_t *, int);
 static void rx_dma_buf_init(pc300_t *, int);
+static void rx_dma_buf_pt_init(pc300_t *, int);
+static void rx_dma_start(pc300_t *, int);
+static void rx_dma_stop(pc300_t *, int);
+#ifdef PC300_DEBUG_OTHER
+static void tx1_dma_buf_check(pc300_t *, int);
+#endif
 static void tx_dma_buf_check(pc300_t *, int);
-static void rx_dma_buf_check(pc300_t *, int);
-static irqreturn_t cpc_intr(int, void *);
+static void tx_dma_buf_init(pc300_t *, int);
+static void tx_dma_buf_pt_init(pc300_t *, int);
+static void tx_dma_stop(pc300_t *, int);
+
+/* FALC routines */
+static void falc_check_status(pc300_t *, int, unsigned char);
+static void falc_close_all_timeslots(pc300_t *, int);
+static void falc_close_timeslot(pc300_t *, int, int);
+static void falc_disable_comm(pc300_t *, int);
+static void falc_e1_intr(pc300_t *, int);
+static void falc_e1_loop_detection(pc300_t *, int, u8);
+static void falc_enable_comm(pc300_t *, int);
+static void falc_generate_loop_down_code(pc300_t *, int);
+static void falc_generate_loop_up_code(pc300_t *, int);
+static void falc_init_e1(pc300_t *, int);
+static void falc_init_hdlc(pc300_t *, int);
+static void falc_init_t1(pc300_t *, int);
+static void falc_init_timeslot(pc300_t *, int);
+static void falc_intr_enable(pc300_t *, int);
+static void falc_intr(pc300_t *);
+static void falc_issue_cmd(pc300_t *, int, u8);
+static void falc_local_loop(pc300_t *, int, int);
+static void falc_open_all_timeslots(pc300_t *, int);
+static void falc_open_timeslot(pc300_t *, int, int);
+static u16 falc_pattern_test_error(pc300_t *, int);
+static void falc_pattern_test(pc300_t *, int, unsigned int);
+static void falc_payload_loop(pc300_t *, int, int);
+static void falc_remote_loop(pc300_t *, int, int);
+static void falc_t1_intr(pc300_t *, int);
+static void falc_t1_loop_detection(pc300_t *, int, u8);
+static void falc_update_stats(pc300_t *, int);
+static void te_config(pc300_t *, int);
+static void turn_off_xld(pc300_t *, int);
+static void turn_off_xlu(pc300_t *, int);
+
+static void sca_intr(pc300_t *);
+static void sca_tx_intr(pc300dev_t *);
+
+static int ch_config(pc300dev_t *);
 static int clock_rate_calc(u32, u32, int *);
 static u32 detect_ram(pc300_t *);
 static void plx_init(pc300_t *);
-static void cpc_trace(struct net_device *, struct sk_buff *, char);
+static int rx_config(pc300dev_t *);
+static inline void show_version(void);
+static int tx_config(pc300dev_t *);
+
 static int cpc_attach(struct net_device *, unsigned short, unsigned short);
-static int cpc_close(struct net_device *dev);
+static int cpc_change_mtu(struct net_device *, int);
+static void __exit cpc_cleanup_module(void);
+static void cpc_closech(pc300dev_t *);
+static int cpc_close(struct net_device *);
+static void cpc_falc_status(pc300_t *, int);
+static struct net_device_stats *cpc_get_stats(struct net_device *);
+static void cpc_hw_info_to_user(const pc300hw_t *, struct pc300hw_user *);
+static void cpc_init_card(pc300_t *);
+static int __devinit cpc_init_one(struct pci_dev *,
+				  const struct pci_device_id *);
+static int __init cpc_init(void);
+static irqreturn_t cpc_intr(int, void *);
+static int cpc_ioctl(struct net_device *, struct ifreq *, int);
+static void cpc_net_rx(struct net_device *);
+static void cpc_net_stats_to_user(const struct net_device_stats *,
+				  struct pc300_net_stats *);
+static int cpc_opench(pc300dev_t *);
+static int cpc_queue_xmit(struct sk_buff *, struct net_device *);
+static void __devexit cpc_remove_one(struct pci_dev *);
+static void cpc_sca_status(pc300_t *, int);
+static void cpc_trace(struct net_device *, struct sk_buff *, char);
+static void cpc_tx_timeout(struct net_device *);
 
 #ifdef CONFIG_PC300_MLPPP
 void cpc_tty_init(pc300dev_t * dev);
@@ -300,6 +376,18 @@ void cpc_tty_trigger_poll(pc300dev_t * p
 void cpc_tty_reset_var(void);
 #endif
 
+static const struct net_device_ops pc300_netdev_ops = {
+	.ndo_change_mtu = cpc_change_mtu,
+	.ndo_do_ioctl = cpc_ioctl,
+	.ndo_get_stats = cpc_get_stats,
+	.ndo_open = cpc_open,
+	.ndo_set_mac_address = NULL,
+	.ndo_start_xmit = cpc_queue_xmit,
+	.ndo_stop = cpc_close,
+	.ndo_tx_timeout = cpc_tx_timeout,
+	.ndo_validate_addr = NULL
+};
+
 /************************/
 /***   DMA Routines   ***/
 /************************/
@@ -370,23 +458,25 @@ static void tx_dma_buf_check(pc300_t * c
 	u16 first_bd = card->chan[ch].tx_first_bd;
 	u16 next_bd = card->chan[ch].tx_next_bd;
 
-	printk("#CH%d: f_bd = %d(0x%08zx), n_bd = %d(0x%08zx)\n", ch,
-	       first_bd, TX_BD_ADDR(ch, first_bd),
-	       next_bd, TX_BD_ADDR(ch, next_bd));
+	printk(KERN_DEBUG "#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
+	       first_bd, (u32)TX_BD_ADDR(ch, first_bd),
+	       next_bd, (u32)TX_BD_ADDR(ch, next_bd));
 	for (i = first_bd,
-	     ptdescr = (card->hw.rambase + TX_BD_ADDR(ch, first_bd));
+	     ptdescr = (pcsca_bd_t *)(card->hw.rambase +
+			TX_BD_ADDR(ch, first_bd));
 	     i != ((next_bd + 1) & (N_DMA_TX_BUF - 1));
 	     i = (i + 1) & (N_DMA_TX_BUF - 1), 
-		 ptdescr = (card->hw.rambase + TX_BD_ADDR(ch, i))) {
-		printk("\n CH%d TX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
-		       ch, i, cpc_readl(&ptdescr->next),
-		       cpc_readl(&ptdescr->ptbuf),
+		ptdescr = (pcsca_bd_t *)
+		(card->hw.rambase + TX_BD_ADDR(ch, i))) {
+		printk("\n CH%d TX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
+		       ch, i, (u32) cpc_readl(&ptdescr->next),
+		       (u32) cpc_readl(&ptdescr->ptbuf),
 		       cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
 	}
 	printk("\n");
 }
 
-#ifdef	PC300_DEBUG_OTHER
+#ifdef PC300_DEBUG_OTHER
 /* Show all TX buffer descriptors */
 static void tx1_dma_buf_check(pc300_t * card, int ch)
 {
@@ -394,21 +484,37 @@ static void tx1_dma_buf_check(pc300_t * 
 	int i;
 	u16 first_bd = card->chan[ch].tx_first_bd;
 	u16 next_bd = card->chan[ch].tx_next_bd;
-	u32 scabase = card->hw.scabase;
+	uintptr_t scabase = card->hw.scabase;
 
 	printk ("\nnfree_tx_bd = %d\n", card->chan[ch].nfree_tx_bd);
 	printk("#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
-	       first_bd, TX_BD_ADDR(ch, first_bd),
-	       next_bd, TX_BD_ADDR(ch, next_bd));
+	       first_bd, (u32)TX_BD_ADDR(ch, first_bd),
+	       next_bd, (u32)TX_BD_ADDR(ch, next_bd));
 	printk("TX_CDA=0x%08x, TX_EDA=0x%08x\n",
-	       cpc_readl(scabase + DTX_REG(CDAL, ch)),
-	       cpc_readl(scabase + DTX_REG(EDAL, ch)));
+	       (u32)(cpc_readl(scabase + DTX_REG(CDAL, ch))),
+	       (u32)(cpc_readl(scabase + DTX_REG(EDAL, ch))));
+	printk(KERN_DEBUG "TX_CDA(BH/B/H/L) = %02x %02x %02x %02x\n",
+	       (u8) cpc_readb(scabase + DTX_REG(CDABH, ch)),
+	       (u8) cpc_readb(scabase + DTX_REG(CDAB, ch)),
+	       (u8) cpc_readb(scabase + DTX_REG(CDAH, ch)),
+	       (u8) cpc_readb(scabase + DTX_REG(CDAL, ch)));
+	printk(KERN_DEBUG "TX_EDA(BH/B/H/L) = %02x %02x %02x %02x\n",
+	       (u8) cpc_readb(scabase + DTX_REG(EDABH, ch)),
+	       (u8) cpc_readb(scabase + DTX_REG(EDAB, ch)),
+	       (u8) cpc_readb(scabase + DTX_REG(EDAH, ch)),
+	       (u8) cpc_readb(scabase + DTX_REG(EDAL, ch)));
 	for (i = 0; i < N_DMA_TX_BUF; i++) {
 		ptdescr = (card->hw.rambase + TX_BD_ADDR(ch, i));
 		printk("\n CH%d TX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
-		       ch, i, cpc_readl(&ptdescr->next),
-		       cpc_readl(&ptdescr->ptbuf),
+		       ch, i, (u32) cpc_readl(&ptdescr->next),
+		       (u32) cpc_readl(&ptdescr->ptbuf),
 		       cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
+		printk("\n CH%d TX%d: next=0x%02x%02x%02x%02x (endianess-correct)",
+		       ch, i,
+		       cpc_readb((unsigned char *)(&(ptdescr->next))+0x3),
+		       cpc_readb((unsigned char *)(&(ptdescr->next))+0x2),
+		       cpc_readb((unsigned char *)(&(ptdescr->next))+0x1),
+		       cpc_readb((unsigned char *)(&(ptdescr->next))+0x0));
 	}
 	printk("\n");
 }
@@ -424,15 +530,16 @@ static void rx_dma_buf_check(pc300_t * c
 
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
-				 cpc_readb(&ptdescr->status),
-				 cpc_readw(&ptdescr->len));
+			printk(KERN_DEBUG
+			       "\n CH%d RX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
+				ch, i, (u32) cpc_readl(&ptdescr->next),
+				(u32) cpc_readl(&ptdescr->ptbuf),
+				cpc_readb(&ptdescr->status),
+				cpc_readw(&ptdescr->len));
 	}
 	printk("\n");
 }
@@ -444,7 +551,7 @@ static int dma_get_rx_frame_size(pc300_t
 	int rcvd = 0;
 	volatile u8 status;
 
-	ptdescr = (card->hw.rambase + RX_BD_ADDR(ch, first_bd));
+	ptdescr = (pcsca_bd_t *)(card->hw.rambase + RX_BD_ADDR(ch, first_bd));
 	while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 		rcvd += cpc_readw(&ptdescr->len);
 		first_bd = (first_bd + 1) & (N_DMA_RX_BUF - 1);
@@ -453,7 +560,8 @@ static int dma_get_rx_frame_size(pc300_t
 			* (dma_buf_read will clean the buffer descriptors in this case). */
 			return (rcvd);
 		}
-		ptdescr = (card->hw.rambase + cpc_readl(&ptdescr->next));
+		ptdescr = (pcsca_bd_t *)(card->hw.rambase +
+					 cpc_readl(&ptdescr->next));
 	}
 	return (-1);
 }
@@ -474,7 +582,7 @@ static int dma_buf_write(pc300_t *card, 
 	}
 
 	for (i = 0; i < nbuf; i++) {
-		ptdescr = (card->hw.rambase +
+		ptdescr = (pcsca_bd_t *) (card->hw.rambase +
 					  TX_BD_ADDR(ch, card->chan[ch].tx_next_bd));
 		nchar = cpc_min(BD_DEF_LEN, tosend);
 		if (cpc_readb(&ptdescr->status) & DST_OSB) {
@@ -511,7 +619,7 @@ static int dma_buf_read(pc300_t * card, 
 	int rcvd = 0;
 	volatile u8 status;
 
-	ptdescr = (card->hw.rambase +
+	ptdescr = (pcsca_bd_t *)(card->hw.rambase +
 				  RX_BD_ADDR(ch, chan->rx_first_bd));
 	while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 		nchar = cpc_readw(&ptdescr->len);
@@ -527,7 +635,7 @@ static int dma_buf_read(pc300_t * card, 
 				chan->rx_first_bd = (chan->rx_first_bd+1) & (N_DMA_RX_BUF-1);
 				if (status & DST_EOM)
 					break;
-				ptdescr = (card->hw.rambase +
+				ptdescr = (pcsca_bd_t *) (card->hw.rambase +
 							  cpc_readl(&ptdescr->next));
 				status = cpc_readb(&ptdescr->status);
 			}
@@ -536,7 +644,8 @@ static int dma_buf_read(pc300_t * card, 
 		if (nchar != 0) {
 			if (skb) {
 				memcpy_fromio(skb_put(skb, nchar),
-				 (card->hw.rambase+cpc_readl(&ptdescr->ptbuf)),nchar);
+					(void *)(card->hw.rambase +
+					cpc_readl(&ptdescr->ptbuf)), nchar);
 			}
 			rcvd += nchar;
 		}
@@ -547,7 +656,8 @@ static int dma_buf_read(pc300_t * card, 
 		if (status & DST_EOM)
 			break;
 
-		ptdescr = (card->hw.rambase + cpc_readl(&ptdescr->next));
+		ptdescr = (pcsca_bd_t *)(card->hw.rambase +
+					 cpc_readl(&ptdescr->next));
 	}
 
 	if (rcvd != 0) {
@@ -562,7 +672,7 @@ static int dma_buf_read(pc300_t * card, 
 
 static void tx_dma_stop(pc300_t * card, int ch)
 {
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	u8 drr_ena_bit = 1 << (5 + 2 * ch);
 	u8 drr_rst_bit = 1 << (1 + 2 * ch);
 
@@ -573,7 +683,7 @@ static void tx_dma_stop(pc300_t * card, 
 
 static void rx_dma_stop(pc300_t * card, int ch)
 {
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	u8 drr_ena_bit = 1 << (4 + 2 * ch);
 	u8 drr_rst_bit = 1 << (2 * ch);
 
@@ -584,7 +694,7 @@ static void rx_dma_stop(pc300_t * card, 
 
 static void rx_dma_start(pc300_t * card, int ch)
 {
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	
 	/* Start DMA */
@@ -600,7 +710,7 @@ static void rx_dma_start(pc300_t * card,
 	cpc_writew(scabase + DRX_REG(BFLL, ch), BD_DEF_LEN);
 	cpc_writeb(scabase + DSR_RX(ch), DSR_DE);
 	if (!(cpc_readb(scabase + DSR_RX(ch)) & DSR_DE)) {
-	cpc_writeb(scabase + DSR_RX(ch), DSR_DE);
+		cpc_writeb(scabase + DSR_RX(ch), DSR_DE);
 	}
 }
 
@@ -609,7 +719,7 @@ static void rx_dma_start(pc300_t * card,
 /*************************/
 static void falc_issue_cmd(pc300_t *card, int ch, u8 cmd)
 {
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	unsigned long i = 0;
 
 	while (cpc_readb(falcbase + F_REG(SIS, ch)) & SIS_CEC) {
@@ -627,7 +737,7 @@ static void falc_intr_enable(pc300_t * c
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	/* Interrupt pins are open-drain */
 	cpc_writeb(falcbase + F_REG(IPC, ch),
@@ -674,7 +784,7 @@ static void falc_intr_enable(pc300_t * c
 
 static void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
 {
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 tshf = card->chan[ch].falc.offset;
 
 	cpc_writeb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch),
@@ -690,7 +800,7 @@ static void falc_open_timeslot(pc300_t *
 
 static void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
 {
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 tshf = card->chan[ch].falc.offset;
 
 	cpc_writeb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch),
@@ -708,7 +818,7 @@ static void falc_close_all_timeslots(pc3
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	cpc_writeb(falcbase + F_REG(ICB1, ch), 0xff);
 	cpc_writeb(falcbase + F_REG(TTR1, ch), 0);
@@ -730,7 +840,7 @@ static void falc_open_all_timeslots(pc30
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	cpc_writeb(falcbase + F_REG(ICB1, ch), 0);
 	if (conf->fr_mode == PC300_FR_UNFRAMED) {
@@ -811,7 +921,7 @@ static void falc_init_t1(pc300_t * card,
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
 
 	/* Switch to T1 mode (PCM 24) */
@@ -980,7 +1090,7 @@ static void falc_init_e1(pc300_t * card,
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
 
 	/* Switch to E1 mode (PCM 30) */
@@ -1157,7 +1267,7 @@ static void falc_init_e1(pc300_t * card,
 
 static void falc_init_hdlc(pc300_t * card, int ch)
 {
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 
@@ -1186,7 +1296,7 @@ static void te_config(pc300_t * card, in
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 dummy;
 	unsigned long flags;
 
@@ -1246,7 +1356,7 @@ static void falc_check_status(pc300_t * 
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	/* Verify LOS */
 	if (frs0 & FRS0_LOS) {
@@ -1402,7 +1512,7 @@ static void falc_update_stats(pc300_t * 
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u16 counter;
 
 	counter = cpc_readb(falcbase + F_REG(FECL, ch));
@@ -1454,7 +1564,7 @@ static void falc_remote_loop(pc300_t * c
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (loop_on) {
 		// EVENT_FALC_ABNORMAL
@@ -1498,7 +1608,7 @@ static void falc_local_loop(pc300_t * ca
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (loop_on) {
 		cpc_writeb(falcbase + F_REG(LIM0, ch),
@@ -1526,7 +1636,7 @@ static void falc_payload_loop(pc300_t * 
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (loop_on) {
 		// EVENT_FALC_ABNORMAL
@@ -1579,7 +1689,7 @@ static void turn_off_xlu(pc300_t * card,
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1600,7 +1710,7 @@ static void turn_off_xld(pc300_t * card,
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1623,7 +1733,7 @@ static void falc_generate_loop_up_code(p
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1656,7 +1766,7 @@ static void falc_generate_loop_down_code
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1686,7 +1796,7 @@ static void falc_pattern_test(pc300_t * 
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (activate) {
 		pfalc->prbs = 1;
@@ -1773,12 +1883,17 @@ static void cpc_tx_timeout(struct net_de
 	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
+	struct net_device_stats *stats = &(dev->stats);
 	int ch = chan->channel;
 	unsigned long flags;
 	u8 ilar;
 
-	dev->stats.tx_errors++;
-	dev->stats.tx_aborted_errors++;
+#ifdef PC300_DEBUG_OTHER
+	printk(KERN_DEBUG "cpc_tx_timeout()\n");
+	cpc_sca_status(card, ch);
+#endif
+	stats->tx_errors++;
+	stats->tx_aborted_errors++;
 	CPC_LOCK(card, flags);
 	if ((ilar = cpc_readb(card->hw.scabase + ILAR)) != 0) {
 		printk("%s: ILAR=0x%x\n", dev->name, ilar);
@@ -1792,6 +1907,10 @@ static void cpc_tx_timeout(struct net_de
 	}
 	dev->trans_start = jiffies; /* prevent tx timeout */
 	CPC_UNLOCK(card, flags);
+#ifdef PC300_DEBUG_QUEUE
+	printk(KERN_DEBUG "%s: waking queue, finished cpc_tx_timeout()\n",
+	       dev->name);
+#endif
 	netif_wake_queue(dev);
 }
 
@@ -1800,22 +1919,72 @@ static int cpc_queue_xmit(struct sk_buff
 	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
+	struct net_device_stats *stats = &(dev->stats);
 	int ch = chan->channel;
 	unsigned long flags;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 #ifdef PC300_DEBUG_TX
 	int i;
 #endif
 
-	if (!netif_carrier_ok(dev)) {
+#ifdef PC300_DEBUG_TX
+	printk(KERN_DEBUG "%s: cpc_queue_xmit called wih %d bytes\n",
+	       dev->name, skb->len);
+#endif
+	if (cpc_readb(scabase + M_REG(ST3, ch)) & ST3_DCD) {
+		if (netif_carrier_ok(dev)) {
+			printk(KERN_INFO "%s: DCD is OFF. Going administrative down.\n",
+			       dev->name);
+#ifdef CONFIG_PC300_MLPPP
+		if (chan->conf.proto != PC300_PROTO_MLPPP)
+			netif_carrier_off(dev);
+#else
+		netif_carrier_off(dev);
+#endif
+		card->chan[ch].d.line_off++;
+		}
+	} else {	/* DCD = 1 */
+		if (!netif_carrier_ok(dev)) {
+			printk(KERN_INFO "%s: DCD is ON. Going administrative up.\n",
+			       dev->name);
+#ifdef CONFIG_PC300_MLPPP
+			if (chan->conf.proto != PC300_PROTO_MLPPP) {
+				/* verify if driver is not TTY */
+				netif_carrier_on(dev);
+			}
+#else
+			netif_carrier_on(dev);
+#endif
+			card->chan[ch].d.line_on++;
+		}
+	}
+
+	if (chan->conf.monitor) {
+		/* In monitor mode no Tx is done: ignore packet */
+		dev_kfree_skb(skb);
+#ifdef PC300_DEBUG_OTHER
+		printk(KERN_DEBUG "%s: dropping TX packet because in monitor mode\n",
+		       dev->name);
+#endif
+		return 0;
+	} else if (!netif_carrier_ok(dev)) {
 		/* DCD must be OFF: drop packet */
 		dev_kfree_skb(skb);
-		dev->stats.tx_errors++;
-		dev->stats.tx_carrier_errors++;
+		stats->tx_errors++;
+		stats->tx_carrier_errors++;
+#ifdef PC300_DEBUG_OTHER
+		printk(KERN_DEBUG "%s: TX carrier error; dropping silently\n",
+		       dev->name);
+#endif
 		return 0;
 	} else if (cpc_readb(card->hw.scabase + M_REG(ST3, ch)) & ST3_DCD) {
 		printk("%s: DCD is OFF. Going administrative down.\n", dev->name);
-		dev->stats.tx_errors++;
-		dev->stats.tx_carrier_errors++;
+		stats->tx_errors++;
+		stats->tx_carrier_errors++;
+#ifdef PC300_DEBUG_OTHER
+		printk(KERN_DEBUG "%s: TX carrier error; dropping silently\n",
+		       dev->name);
+#endif
 		dev_kfree_skb(skb);
 		netif_carrier_off(dev);
 		CPC_LOCK(card, flags);
@@ -1826,19 +1995,33 @@ static int cpc_queue_xmit(struct sk_buff
 				   			~(CPLD_REG2_FALC_LED1 << (2 * ch)));
 		}
 		CPC_UNLOCK(card, flags);
+#ifdef PC300_DEBUG_QUEUE
+		printk(KERN_DEBUG "%s: waking queue after TX carrier error\n",
+		       dev->name);
+#endif
 		netif_wake_queue(dev);
 		return 0;
 	}
 
+	CPC_LOCK(card, flags);
 	/* Write buffer to DMA buffers */
-	if (dma_buf_write(card, ch, (u8 *)skb->data, skb->len) != 0) {
-//		printk("%s: write error. Dropping TX packet.\n", dev->name);
+	if (dma_buf_write(card, ch, (u8 *) skb->data, skb->len) != 0) {
+		CPC_UNLOCK(card, flags);
+		printk(KERN_ERR "%s: write error. Dropping TX packet.\n",
+		       dev->name);
+#ifdef PC300_DEBUG_QUEUE
+		printk(KERN_DEBUG "%s: stopping queue due to DMA error\n",
+		       dev->name);
+#endif
+		d->reason_stopped = CPC_DMA_ERROR;
 		netif_stop_queue(dev);
+
 		dev_kfree_skb(skb);
-		dev->stats.tx_errors++;
-		dev->stats.tx_dropped++;
+		stats->tx_errors++;
+		stats->tx_dropped++;
 		return 0;
-	}
+	} else
+		CPC_UNLOCK(card, flags);
 #ifdef PC300_DEBUG_TX
 	printk("%s T:", dev->name);
 	for (i = 0; i < skb->len; i++)
@@ -1852,11 +2035,12 @@ static int cpc_queue_xmit(struct sk_buff
 
 	/* Start transmission */
 	CPC_LOCK(card, flags);
-	/* verify if it has more than one free descriptor */
-	if (card->chan[ch].nfree_tx_bd <= 1) {
-		/* don't have so stop the queue */
-		netif_stop_queue(dev);
-	}
+#ifdef PC300_DEBUG_QUEUE
+	printk(KERN_DEBUG "%s: stopping queue for transmission\n",
+	       dev->name);
+#endif
+	d->reason_stopped = TRANSMISSION_ACTIVE;
+	netif_stop_queue(dev);
 	cpc_writel(card->hw.scabase + DTX_REG(EDAL, ch),
 		   TX_BD_ADDR(ch, chan->tx_next_bd));
 	cpc_writeb(card->hw.scabase + M_REG(CMD, ch), CMD_TX_ENA);
@@ -1866,9 +2050,28 @@ static int cpc_queue_xmit(struct sk_buff
 			   cpc_readb(card->hw.falcbase + card->hw.cpld_reg2) |
 			   (CPLD_REG2_FALC_LED1 << (2 * ch)));
 	}
+	/* verify if it has more than one free descriptor */
+	if (card->chan[ch].nfree_tx_bd > 1) {
+#ifdef PC300_DEBUG_QUEUE
+		printk(KERN_DEBUG "%s: waking queue after transmission\n",
+		       dev->name);
+#endif
+		netif_wake_queue(dev);
+	}
+#ifdef PC300_DEBUG_QUEUE
+	else {
+		printk(KERN_DEBUG "%s: queue full\n",
+		       dev->name);
+	}
+#endif
 	CPC_UNLOCK(card, flags);
 	dev_kfree_skb(skb);
 
+#ifdef PC300_DEBUG_TX
+	printk(KERN_DEBUG "%s: cpc_queue_xmit returning normally\n",
+	       dev->name);
+#endif
+
 	return 0;
 }
 
@@ -1877,20 +2080,30 @@ static void cpc_net_rx(struct net_device
 	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
+	struct net_device_stats *stats = &(dev->stats);
 	int ch = chan->channel;
 #ifdef PC300_DEBUG_RX
 	int i;
 #endif
 	int rxb;
 	struct sk_buff *skb;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 
 	while (1) {
 		if ((rxb = dma_get_rx_frame_size(card, ch)) == -1)
 			return;
 
 		if (!netif_carrier_ok(dev)) {
+			if (!(cpc_readb(scabase + M_REG(ST3, ch)) & ST3_DCD)) {
+				printk(KERN_INFO "%s: DCD ON - going up\n",
+				       dev->name);
+				netif_carrier_on(dev);
+			}
+		}
+		if (!netif_carrier_ok(dev)) {
 			/* DCD must be OFF: drop packet */
-		    printk("%s : DCD is OFF - drop %d rx bytes\n", dev->name, rxb); 
+			printk(KERN_INFO "%s : DCD is OFF - drop %d rx bytes\n",
+			       dev->name, rxb);
 			skb = NULL;
 		} else {
 			if (rxb > (dev->mtu + 40)) { /* add headers */
@@ -1912,24 +2125,24 @@ static void cpc_net_rx(struct net_device
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
@@ -1938,7 +2151,7 @@ static void cpc_net_rx(struct net_device
 			continue;
 		}
 
-		dev->stats.rx_bytes += rxb;
+		stats->rx_bytes += rxb;
 
 #ifdef PC300_DEBUG_RX
 		printk("%s R:", dev->name);
@@ -1949,7 +2162,8 @@ static void cpc_net_rx(struct net_device
 		if (d->trace_on) {
 			cpc_trace(dev, skb, 'R');
 		}
-		dev->stats.rx_packets++;
+		stats->rx_packets++;
+		skb_reset_mac_header(skb);
 		skb->protocol = hdlc_type_trans(skb, dev);
 		netif_rx(skb);
 	}
@@ -1963,22 +2177,24 @@ static void sca_tx_intr(pc300dev_t *dev)
 	pc300ch_t *chan = (pc300ch_t *)dev->chan; 
 	pc300_t *card = (pc300_t *)chan->card; 
 	int ch = chan->channel; 
-	volatile pcsca_bd_t __iomem * ptdescr; 
+	pcsca_bd_t *ptdescr;
+	struct net_device_stats *stats = &(dev->netdev->stats);
 
     /* Clean up descriptors from previous transmission */
-	ptdescr = (card->hw.rambase +
+	ptdescr = (pcsca_bd_t *)(card->hw.rambase +
 						TX_BD_ADDR(ch,chan->tx_first_bd));
 	while ((cpc_readl(card->hw.scabase + DTX_REG(CDAL,ch)) !=
-		TX_BD_ADDR(ch,chan->tx_first_bd)) &&
-	       (cpc_readb(&ptdescr->status) & DST_OSB)) {
-		dev->dev->stats.tx_packets++;
-		dev->dev->stats.tx_bytes += cpc_readw(&ptdescr->len);
+		TX_BD_ADDR(ch, chan->tx_first_bd)) &&
+		(cpc_readb(&ptdescr->status) & DST_OSB)) {
+		stats->tx_packets++;
+		stats->tx_bytes += cpc_readw(&ptdescr->len);
 		cpc_writeb(&ptdescr->status, DST_OSB);
 		cpc_writew(&ptdescr->len, 0);
 		chan->nfree_tx_bd++;
 		chan->tx_first_bd = (chan->tx_first_bd + 1) & (N_DMA_TX_BUF - 1);
-		ptdescr = (card->hw.rambase + TX_BD_ADDR(ch,chan->tx_first_bd));
-    }
+		ptdescr = (pcsca_bd_t *)(card->hw.rambase +
+			TX_BD_ADDR(ch, chan->tx_first_bd));
+	}
 
 #ifdef CONFIG_PC300_MLPPP
 	if (chan->conf.proto == PC300_PROTO_MLPPP) {
@@ -1986,7 +2202,13 @@ static void sca_tx_intr(pc300dev_t *dev)
 	} else {
 #endif
 	/* Tell the upper layer we are ready to transmit more packets */
-		netif_wake_queue(dev->dev);
+
+		if (chan->nfree_tx_bd > 1 && netif_queue_stopped(dev->netdev)) {
+#ifdef PC300_DEBUG_QUEUE
+			printk(KERN_DEBUG "Waking queue on TX interrupt\n");
+#endif
+			netif_wake_queue(dev->netdev);
+		}
 #ifdef CONFIG_PC300_MLPPP
 	}
 #endif
@@ -1994,17 +2216,21 @@ static void sca_tx_intr(pc300dev_t *dev)
 
 static void sca_intr(pc300_t * card)
 {
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	volatile u32 status;
 	int ch;
 	int intr_count = 0;
 	unsigned char dsr_rx;
 
 	while ((status = cpc_readl(scabase + ISR0)) != 0) {
+#ifdef PC300_DEBUG_INTR
+		printk(KERN_DEBUG "sca_intr(): status = %08x\n",
+		       status);
+#endif
 		for (ch = 0; ch < card->hw.nchan; ch++) {
 			pc300ch_t *chan = &card->chan[ch];
 			pc300dev_t *d = &chan->d;
-			struct net_device *dev = d->dev;
+			struct net_device *dev = d->netdev;
 
 			spin_lock(&card->card_lock);
 
@@ -2016,8 +2242,9 @@ static void sca_intr(pc300_t * card)
 				cpc_writeb(scabase + DSR_RX(ch), drx_stat | DSR_DWE);
 
 #ifdef PC300_DEBUG_INTR
-				printk ("sca_intr: RX intr chan[%d] (st=0x%08lx, dsr=0x%02x)\n",
-					 ch, status, drx_stat);
+				printk(KERN_DEBUG
+				       "sca_intr: RX intr chan[%d] (st=0x%08x, dsr=0x%02x)\n",
+				       ch, status, drx_stat);
 #endif
 				if (status & IR0_DRX(IR0_DMIA, ch)) {
 					if (drx_stat & DSR_BOF) {
@@ -2075,8 +2302,10 @@ static void sca_intr(pc300_t * card)
 				}
 				if (!(dsr_rx = cpc_readb(scabase + DSR_RX(ch)) & DSR_DE)) {
 #ifdef PC300_DEBUG_INTR
-		printk("%s: RX intr chan[%d] (st=0x%08lx, dsr=0x%02x, dsr2=0x%02x)\n",
-			dev->name, ch, status, drx_stat, dsr_rx);
+					printk(KERN_DEBUG
+					       "%s: RX intr chan[%d] (st=0x%08x, dsr=0x%02x, dsr2=0x%02x)\n",
+					       dev->name, ch, status,
+					       drx_stat, dsr_rx);
 #endif
 					cpc_writeb(scabase + DSR_RX(ch), (dsr_rx | DSR_DE) & 0xfe);
 				}
@@ -2090,8 +2319,9 @@ static void sca_intr(pc300_t * card)
 				cpc_writeb(scabase + DSR_TX(ch), dtx_stat | DSR_DWE);
 
 #ifdef PC300_DEBUG_INTR
-				printk ("sca_intr: TX intr chan[%d] (st=0x%08lx, dsr=0x%02x)\n",
-					 ch, status, dtx_stat);
+				printk(KERN_DEBUG
+				       "sca_intr: TX intr chan[%d] (st=0x%08x, dsr=0x%02x)\n",
+				       ch, status, dtx_stat);
 #endif
 				if (status & IR0_DTX(IR0_EFT, ch)) {
 					if (dtx_stat & DSR_UDRF) {
@@ -2106,8 +2336,17 @@ static void sca_intr(pc300_t * card)
 						}
 						dev->stats.tx_errors++;
 						dev->stats.tx_fifo_errors++;
-						sca_tx_intr(d);
+#ifdef PC300_DEBUG_OTHER
+						printk(KERN_DEBUG
+						       "sca_intr(): TX underflow!  Dump follows:\n");
+						printk(KERN_DEBUG
+						       "DSR_TX was 0x%02x\n",
+						       dtx_stat);
+						cpc_sca_status(card, ch);
+#endif
+
 					}
+					sca_tx_intr(d);
 				}
 				if (status & IR0_DTX(IR0_DMIA, ch)) {
 					if (dtx_stat & DSR_BOF) {
@@ -2121,11 +2360,12 @@ static void sca_intr(pc300_t * card)
 								    			card->hw.cpld_reg2) &
 								   ~ (CPLD_REG2_FALC_LED1 << (2 * ch)));
 						}
-						sca_tx_intr(d);
 					}
+					sca_tx_intr(d);
 				}
 			}
 
+
 	    /**** MSCI ****/
 			if (status & IR0_M(IR0_RXINTA, ch)) {
 				u8 st1 = cpc_readb(scabase + M_REG(ST1, ch));
@@ -2134,8 +2374,9 @@ static void sca_intr(pc300_t * card)
 				cpc_writeb(scabase + M_REG(ST1, ch), st1);
 
 #ifdef PC300_DEBUG_INTR
-				printk("sca_intr: MSCI intr chan[%d] (st=0x%08lx, st1=0x%02x)\n",
-					 ch, status, st1);
+				printk(KERN_DEBUG
+				       "sca_intr: MSCI intr chan[%d] (st=0x%08x, st1=0x%02x)\n",
+				       ch, status, st1);
 #endif
 				if (st1 & ST1_CDCD) {	/* DCD changed */
 					if (cpc_readb(scabase + M_REG(ST3, ch)) & ST3_DCD) {
@@ -2174,7 +2415,7 @@ static void falc_t1_loop_detection(pc300
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (((cpc_readb(falcbase + F_REG(LCR1, ch)) & LCR1_XPRBS) == 0) &&
 	    !pfalc->loop_gen) {
@@ -2199,7 +2440,7 @@ static void falc_e1_loop_detection(pc300
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (((cpc_readb(falcbase + F_REG(LCR1, ch)) & LCR1_XPRBS) == 0) &&
 	    !pfalc->loop_gen) {
@@ -2224,7 +2465,7 @@ static void falc_t1_intr(pc300_t * card,
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 isr0, isr3, gis;
 	u8 dummy;
 
@@ -2271,7 +2512,7 @@ static void falc_e1_intr(pc300_t * card,
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 isr1, isr2, isr3, gis, rsp;
 	u8 dummy;
 
@@ -2364,7 +2605,7 @@ static irqreturn_t cpc_intr(int irq, voi
 		return IRQ_NONE;		/* spurious intr */
 	}
 
-	if (!card->hw.rambase) {
+	if (!(card->hw.rambase)) {
 #ifdef PC300_DEBUG_INTR
 		printk("cpc_intr: spurious intr2 %d\n", irq);
 #endif
@@ -2395,21 +2636,28 @@ static irqreturn_t cpc_intr(int irq, voi
 static void cpc_sca_status(pc300_t * card, int ch)
 {
 	u8 ilar;
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	unsigned long flags;
+	char *reason;
 
+	printk(KERN_DEBUG "tx_dma_buf_check():\n");
 	tx_dma_buf_check(card, ch);
+#ifdef PC300_DEBUG_OTHER
+	printk(KERN_DEBUG "tx1_dma_buf_check():\n");
+	tx1_dma_buf_check(card, ch);
+#endif
+	printk(KERN_DEBUG "rx_dma_buf_check():\n");
 	rx_dma_buf_check(card, ch);
 	ilar = cpc_readb(scabase + ILAR);
 	printk ("ILAR=0x%02x, WCRL=0x%02x, PCR=0x%02x, BTCR=0x%02x, BOLR=0x%02x\n",
 		 ilar, cpc_readb(scabase + WCRL), cpc_readb(scabase + PCR),
 		 cpc_readb(scabase + BTCR), cpc_readb(scabase + BOLR));
 	printk("TX_CDA=0x%08x, TX_EDA=0x%08x\n",
-	       cpc_readl(scabase + DTX_REG(CDAL, ch)),
-	       cpc_readl(scabase + DTX_REG(EDAL, ch)));
+	       (u32) cpc_readl(scabase + DTX_REG(CDAL, ch)),
+	       (u32) cpc_readl(scabase + DTX_REG(EDAL, ch)));
 	printk("RX_CDA=0x%08x, RX_EDA=0x%08x, BFL=0x%04x\n",
-	       cpc_readl(scabase + DRX_REG(CDAL, ch)),
-	       cpc_readl(scabase + DRX_REG(EDAL, ch)),
+	       (u32) cpc_readl(scabase + DRX_REG(CDAL, ch)),
+	       (u32) cpc_readl(scabase + DRX_REG(EDAL, ch)),
 	       cpc_readw(scabase + DRX_REG(BFLL, ch)));
 	printk("DMER=0x%02x, DSR_TX=0x%02x, DSR_RX=0x%02x\n",
 	       cpc_readb(scabase + DMER), cpc_readb(scabase + DSR_TX(ch)),
@@ -2474,7 +2722,25 @@ static void cpc_sca_status(pc300_t * car
 	       cpc_readb(scabase + M_REG(IE2, ch)),
 	       cpc_readb(scabase + M_REG(IE4, ch)),
 	       cpc_readb(scabase + M_REG(FIE, ch)));
-	printk("IER0=0x%08x\n", cpc_readl(scabase + IER0));
+	printk(KERN_DEBUG "IER0=0x%08x\n", (u32) cpc_readl(scabase + IER0));
+	switch (card->chan[ch].d.reason_stopped) {
+	case CPC_DMA_FULL:
+	  reason = "CPC_DMA_FULL";
+	  break;
+	case CPC_DMA_ERROR:
+	  reason = "CPC_DMA_ERROR";
+	  break;
+	case TRANSMISSION_ACTIVE:
+	  reason = "TRANSMISSION_ACTIVE";
+	  break;
+	case CHANNEL_CLOSED:
+	  reason = "CHANNEL_CLOSED";
+	  break;
+	default:
+	  reason = "unknown";
+	  break;
+	}
+	printk(KERN_DEBUG "reason_stopped = %s\n", reason);
 
 	if (ilar != 0) {
 		CPC_LOCK(card, flags);
@@ -2514,29 +2780,89 @@ static void cpc_falc_status(pc300_t * ca
 
 static int cpc_change_mtu(struct net_device *dev, int new_mtu)
 {
+#ifdef PC300_DEBUG_OTHER
+	printk(KERN_DEBUG "%s: change MTU to %d\n", dev->name, new_mtu);
+#endif
 	if ((new_mtu < 128) || (new_mtu > PC300_DEF_MTU))
 		return -EINVAL;
 	dev->mtu = new_mtu;
 	return 0;
 }
 
+/* Helper function to produce userland version of network stats */
+static void cpc_net_stats_to_user(const struct net_device_stats *stats,
+				  struct pc300_net_stats *user_stats)
+{
+	user_stats->rx_packets = stats->rx_packets;
+	user_stats->tx_packets = stats->tx_packets;
+	user_stats->rx_bytes = stats->rx_bytes;
+	user_stats->tx_bytes = stats->tx_bytes;
+	user_stats->rx_errors = stats->rx_errors;
+	user_stats->tx_errors = stats->tx_errors;
+	user_stats->rx_dropped = stats->rx_dropped;
+	user_stats->tx_dropped = stats->tx_dropped;
+	user_stats->multicast = stats->multicast;
+	user_stats->collisions = stats->collisions;
+	user_stats->rx_length_errors = stats->rx_length_errors;
+	user_stats->rx_over_errors = stats->rx_over_errors;
+	user_stats->rx_crc_errors = stats->rx_crc_errors;
+	user_stats->rx_frame_errors = stats->rx_frame_errors;
+	user_stats->rx_fifo_errors = stats->rx_fifo_errors;
+	user_stats->rx_missed_errors = stats->rx_missed_errors;
+	user_stats->tx_aborted_errors = stats->tx_aborted_errors;
+	user_stats->tx_carrier_errors = stats->tx_carrier_errors;
+	user_stats->tx_fifo_errors = stats->tx_fifo_errors;
+	user_stats->tx_heartbeat_errors = stats->tx_heartbeat_errors;
+	user_stats->tx_window_errors = stats->tx_window_errors;
+	user_stats->rx_compressed = stats->rx_compressed;
+	user_stats->tx_compressed = stats->tx_compressed;
+}
+
+/* Helper function to produce userland version of pc300hw struct */
+static void cpc_hw_info_to_user(const pc300hw_t *hw,
+				struct pc300hw_user *user_hw)
+{
+	memset(user_hw, 0, sizeof(*user_hw));
+	user_hw->type = hw->type;
+	user_hw->bus = hw->bus;
+	user_hw->nchan = hw->nchan;
+	user_hw->irq = hw->irq;
+	user_hw->clock = hw->clock;
+	user_hw->cpld_id = hw->cpld_id;
+	user_hw->cpld_reg1 = hw->cpld_reg1;
+	user_hw->cpld_reg2 = hw->cpld_reg2;
+	user_hw->gpioc_reg = hw->gpioc_reg;
+	user_hw->intctl_reg = hw->intctl_reg;
+	user_hw->iosize = hw->iosize;
+	user_hw->plxsize = hw->plxsize;
+	user_hw->scasize = hw->scasize;
+	user_hw->alloc_ramsize = hw->alloc_ramsize;
+	user_hw->ramsize = hw->ramsize;
+	user_hw->falcsize = hw->falcsize;
+}
+
 static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
+	pc300dev_t *d = (pc300dev_t *) (dev_to_hdlc(dev))->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	pc300conf_t conf_aux;
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	int ch = chan->channel;
-	void __user *arg = ifr->ifr_data;
+	void *arg = (void *) ifr->ifr_data;
 	struct if_settings *settings = &ifr->ifr_settings;
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
 	switch (cmd) {
 		case SIOCGPC300CONF:
+#ifdef PC300_DEBUG_OTHER
+			printk(KERN_DEBUG
+			       "%s: SIOCGPC300CONF called, with conf->monitor = %d\n",
+			       dev->name, conf->monitor);
+#endif
 #ifdef CONFIG_PC300_MLPPP
 			if (conf->proto != PC300_PROTO_MLPPP) {
 				conf->proto = /* FIXME hdlc->proto.id */ 0;
@@ -2545,12 +2871,22 @@ static int cpc_ioctl(struct net_device *
 			conf->proto = /* FIXME hdlc->proto.id */ 0;
 #endif
 			memcpy(&conf_aux.conf, conf, sizeof(pc300chconf_t));
-			memcpy(&conf_aux.hw, &card->hw, sizeof(pc300hw_t));
+			cpc_hw_info_to_user(&card->hw, &conf_aux.hw);
 			if (!arg || 
 				copy_to_user(arg, &conf_aux, sizeof(pc300conf_t))) 
 				return -EINVAL;
+#ifdef PC300_DEBUG_OTHER
+			printk(KERN_DEBUG
+			       "%s: SIOCGPC300CONF returning, with conf->monitor = %d\n",
+			       dev->name, conf->monitor);
+#endif
 			return 0;
 		case SIOCSPC300CONF:
+#ifdef PC300_DEBUG_OTHER
+			printk(KERN_DEBUG
+			       "%s: SIOCSPC300CONF called, with conf->monitor = %d\n",
+			       dev->name, conf->monitor);
+#endif
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
 			if (!arg || 
@@ -2582,6 +2918,11 @@ static int cpc_ioctl(struct net_device *
 			memcpy(conf, &conf_aux.conf, sizeof(pc300chconf_t));
 			/* FIXME hdlc->proto.id = conf->proto; */
 #endif
+#ifdef PC300_DEBUG_OTHER
+			printk(KERN_DEBUG
+			       "%s: SIOCSPC300CONF returning, with conf->monitor = %d\n",
+			       dev->name, conf->monitor);
+#endif
 			return 0;
 		case SIOCGPC300STATUS:
 			cpc_sca_status(card, ch);
@@ -2604,8 +2945,13 @@ static int cpc_ioctl(struct net_device *
 					pc300stats.hw_type = card->hw.type;
 					pc300stats.line_on = card->chan[ch].d.line_on;
 					pc300stats.line_off = card->chan[ch].d.line_off;
-					memcpy(&pc300stats.gen_stats, &dev->stats,
-					       sizeof(dev->stats));
+					/*
+					 * Do this instead of passing dev->stats
+					 * out so 32-bit userland on 64-bit
+					 * kernel works.
+					 */
+					cpc_net_stats_to_user(&(dev->stats),
+						&(pc300stats.net_stats));
 					if (card->hw.type == PC300_TE)
 						memcpy(&pc300stats.te_stats,&chan->falc,sizeof(falc_t));
 				    	if (copy_to_user(arg, &pc300stats, sizeof(pc300stats_t)))
@@ -2811,6 +3157,16 @@ static int cpc_ioctl(struct net_device *
 	}
 }
 
+static struct net_device_stats *cpc_get_stats(struct net_device *dev)
+{
+	pc300dev_t *d = (pc300dev_t *) (dev_to_hdlc(dev))->priv;
+
+	if (d)
+		return &(dev->stats);
+	else
+		return NULL;
+}
+
 static int clock_rate_calc(u32 rate, u32 clock, int *br_io)
 {
 	int br, tc;
@@ -2845,8 +3201,8 @@ static int ch_config(pc300dev_t * d)
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	pc300_t *card = (pc300_t *) chan->card;
-	void __iomem *scabase = card->hw.scabase;
-	void __iomem *plxbase = card->hw.plxbase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
+	uintptr_t plxbase = (uintptr_t)(card->hw.plxbase);
 	int ch = chan->channel;
 	u32 clkrate = chan->conf.phys_settings.clock_rate;
 	u32 clktype = chan->conf.phys_settings.clock_type;
@@ -2985,8 +3341,10 @@ static int ch_config(pc300dev_t * d)
 		   IR0_DTX(IR0_EFT | IR0_DMIA | IR0_DMIB, ch));
 	cpc_writeb(scabase + M_REG(IE0, ch),
 		   cpc_readl(scabase + M_REG(IE0, ch)) | IE0_RXINTA);
+
+	/* Was cpc_readl(), changed for unaligned access */
 	cpc_writeb(scabase + M_REG(IE1, ch),
-		   cpc_readl(scabase + M_REG(IE1, ch)) | IE1_CDCD);
+		   cpc_readb(scabase + M_REG(IE1, ch)) | IE1_CDCD);
 
 	return 0;
 }
@@ -2995,14 +3353,15 @@ static int rx_config(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	int ch = chan->channel;
 
 	cpc_writeb(scabase + DSR_RX(ch), 0);
 
 	/* General RX settings */
 	cpc_writeb(scabase + M_REG(RRC, ch), 0);
-	cpc_writeb(scabase + M_REG(RNR, ch), 16);
+	cpc_writeb(scabase + M_REG(RNR, ch), 8);
+	cpc_writeb(scabase + M_REG(RCR, ch), 16);
 
 	/* Enable reception */
 	cpc_writeb(scabase + M_REG(CMD, ch), CMD_RX_CRC_INIT);
@@ -3026,17 +3385,17 @@ static int tx_config(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	int ch = chan->channel;
 
 	cpc_writeb(scabase + DSR_TX(ch), 0);
 
 	/* General TX settings */
 	cpc_writeb(scabase + M_REG(TRC0, ch), 0);
-	cpc_writeb(scabase + M_REG(TFS, ch), 32);
-	cpc_writeb(scabase + M_REG(TNR0, ch), 20);
-	cpc_writeb(scabase + M_REG(TNR1, ch), 48);
-	cpc_writeb(scabase + M_REG(TCR, ch), 8);
+	cpc_writeb(scabase + M_REG(TFS, ch), 0x3c);
+	cpc_writeb(scabase + M_REG(TNR0, ch), 0x38);
+	cpc_writeb(scabase + M_REG(TNR1, ch), 0x3f);
+	cpc_writeb(scabase + M_REG(TCR, ch), 0x38);
 
 	/* Enable transmission */
 	cpc_writeb(scabase + M_REG(CMD, ch), CMD_TX_CRC_INIT);
@@ -3090,7 +3449,7 @@ static int cpc_opench(pc300dev_t * d)
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	int ch = chan->channel, rc;
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 
 	rc = ch_config(d);
 	if (rc)
@@ -3140,13 +3499,17 @@ int cpc_open(struct net_device *dev)
 	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	struct ifreq ifr;
 	int result;
+	pc300ch_t *chan = (pc300ch_t *) d->chan;
+	pc300_t *card = (pc300_t *) chan->card;
+	int ch = chan->channel;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
+
 
 #ifdef	PC300_DEBUG_OTHER
-	printk("pc300: cpc_open");
+	printk("pc300: cpc_open\n");
 #endif
 
 	result = hdlc_open(dev);
-
 	if (result)
 		return result;
 
@@ -3155,7 +3518,16 @@ int cpc_open(struct net_device *dev)
 	if (result)
 		goto err_out;
 
+#ifdef PC300_DEBUG_QUEUE
+	printk(KERN_DEBUG "%s: starting queue for open\n",
+	       dev->name);
+#endif
 	netif_start_queue(dev);
+	if (cpc_readb(scabase + M_REG(ST3, ch)) & ST3_DCD)
+		netif_carrier_off(dev);
+	else
+		netif_carrier_on(dev);
+
 	return 0;
 
 err_out:
@@ -3171,9 +3543,13 @@ static int cpc_close(struct net_device *
 	unsigned long flags;
 
 #ifdef	PC300_DEBUG_OTHER
-	printk("pc300: cpc_close");
+	printk(KERN_DEBUG "pc300: cpc_close\n");
+#endif
+#ifdef PC300_DEBUG_QUEUE
+	printk(KERN_DEBUG "%s: stopping queue\n", dev->name);
 #endif
 
+	d->reason_stopped = CHANNEL_CLOSED;
 	netif_stop_queue(dev);
 
 	CPC_LOCK(card, flags);
@@ -3181,7 +3557,6 @@ static int cpc_close(struct net_device *
 	CPC_UNLOCK(card, flags);
 
 	hdlc_close(dev);
-
 #ifdef CONFIG_PC300_MLPPP
 	if (chan->conf.proto == PC300_PROTO_MLPPP) {
 		cpc_tty_unregister_service(d);
@@ -3196,7 +3571,7 @@ static u32 detect_ram(pc300_t * card)
 {
 	u32 i;
 	u8 data;
-	void __iomem *rambase = card->hw.rambase;
+	uintptr_t rambase = (uintptr_t)(card->hw.rambase);
 
 	card->hw.ramsize = PC300_RAMSIZE;
 	/* Let's find out how much RAM is present on this board */
@@ -3212,7 +3587,8 @@ static u32 detect_ram(pc300_t * card)
 
 static void plx_init(pc300_t * card)
 {
-	struct RUNTIME_9050 __iomem *plx_ctl = card->hw.plxbase;
+	struct RUNTIME_9050 __iomem *plx_ctl =
+		(struct RUNTIME_9050 *) card->hw.plxbase;
 
 	/* Reset PLX */
 	cpc_writel(&plx_ctl->init_ctrl,
@@ -3246,16 +3622,6 @@ static inline void show_version(void)
 		rcsvers, rcsdate, __DATE__, __TIME__);
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
@@ -3345,6 +3711,7 @@ static void cpc_init_card(pc300_t * card
 				break;
 		}
 		chan->conf.proto = IF_PROTO_PPP;
+		chan->conf.monitor = 0;
 		chan->tx_first_bd = 0;
 		chan->tx_next_bd = 0;
 		chan->rx_first_bd = 0;
@@ -3352,6 +3719,7 @@ static void cpc_init_card(pc300_t * card
 		chan->nfree_tx_bd = N_DMA_TX_BUF;
 
 		d->chan = chan;
+		d->tx_skb = NULL;
 		d->trace_on = 0;
 		d->line_on = 0;
 		d->line_off = 0;
@@ -3360,19 +3728,22 @@ static void cpc_init_card(pc300_t * card
 		if (dev == NULL)
 			continue;
 
-		hdlc = dev_to_hdlc(dev);
-		hdlc->xmit = cpc_queue_xmit;
-		hdlc->attach = cpc_attach;
-		d->dev = dev;
 		dev->mem_start = card->hw.ramphys;
 		dev->mem_end = card->hw.ramphys + card->hw.ramsize - 1;
 		dev->irq = card->hw.irq;
 		dev->tx_queue_len = PC300_TX_QUEUE_LEN;
 		dev->mtu = PC300_DEF_MTU;
-
-		dev->netdev_ops = &cpc_netdev_ops;
+		dev->netdev_ops = &pc300_netdev_ops;
 		dev->watchdog_timeo = PC300_TX_TIMEOUT;
 
+		hdlc = dev_to_hdlc(dev);
+		hdlc->xmit = cpc_queue_xmit;
+		hdlc->attach = cpc_attach;
+		d->hdlc = hdlc;
+
+		d->netdev = dev;
+		d->reason_stopped = CHANNEL_CLOSED;
+
 		if (register_hdlc_device(dev) == 0) {
 			printk("%s: Cyclades-PC300/", dev->name);
 			switch (card->hw.type) {
@@ -3393,14 +3764,33 @@ static void cpc_init_card(pc300_t * card
 					printk("RSV ");
 					break;
 			}
-			printk (" #%d, %dKB of RAM at 0x%08x, IRQ%d, channel %d.\n",
-				 board_nbr, card->hw.ramsize / 1024,
-				 card->hw.ramphys, card->hw.irq, i + 1);
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+			printk(KERN_INFO
+			       " #%d, %dKB of RAM at 0x%016lx, IRQ%d, channel %d.\n",
+			       board_nbr, card->hw.ramsize / 1024,
+			       (unsigned long)(card->hw.ramphys),
+			       card->hw.irq, i + 1);
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+			printk(KERN_INFO
+			       " #%d, %dKB of RAM at 0x%08x, IRQ%d, channel %d.\n",
+			       board_nbr, card->hw.ramsize / 1024,
+			       (unsigned int)(card->hw.ramphys),
+			       card->hw.irq, i + 1);
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
+
 			devcount++;
 		} else {
-			printk ("Dev%d on card(0x%08x): unable to allocate i/f name.\n",
-				 i + 1, card->hw.ramphys);
-			free_netdev(dev);
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+			printk(KERN_ERR
+			       "Dev%d on card(0x%016lx): unable to allocate i/f name.\n",
+			       i + 1, (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+			printk(KERN_ERR
+			       "Dev%d on card(0x%08x): unable to allocate i/f name.\n",
+			       i + 1, (unsigned int)(card->hw.ramphys));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
+			*(dev->name) = 0;
+			kfree(d->hdlc);
 			continue;
 		}
 	}
@@ -3413,7 +3803,7 @@ static int __devinit
 cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int first_time = 1;
-	int err, eeprom_outdated = 0;
+	int err = 0, eeprom_outdated = 0;
 	u16 device_id;
 	pc300_t *card;
 
@@ -3425,20 +3815,20 @@ cpc_init_one(struct pci_dev *pdev, const
 #endif
 	}
 
-	if ((err = pci_enable_device(pdev)) < 0)
-		return err;
-
 	card = kzalloc(sizeof(pc300_t), GFP_KERNEL);
 	if (card == NULL) {
-		printk("PC300 found at RAM 0x%016llx, "
-		       "but could not allocate card structure.\n",
-		       (unsigned long long)pci_resource_start(pdev, 3));
-		err = -ENOMEM;
-		goto err_disable_dev;
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%016lx, but could not allocate card structure.\n",
+		       (unsigned long)(pci_resource_start(pdev, 3)));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%08x, but could not allocate card structure.\n",
+		       (unsigned int)(pci_resource_start(pdev, 3)));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
+		return -ENOMEM;
 	}
 
-	err = -ENODEV;
-
 	/* read PCI configuration area */
 	device_id = ent->device;
 	card->hw.irq = pdev->irq;
@@ -3470,18 +3860,36 @@ cpc_init_one(struct pci_dev *pdev, const
 #ifdef PC300_DEBUG_PCI
 	printk("cpc (bus=0x0%x,pci_id=0x%x,", pdev->bus->number, pdev->devfn);
 	printk("rev_id=%d) IRQ%d\n", pdev->revision, card->hw.irq);
-	printk("cpc:found  ramaddr=0x%08lx plxaddr=0x%08lx "
-	       "ctladdr=0x%08lx falcaddr=0x%08lx\n",
-	       card->hw.ramphys, card->hw.plxphys, card->hw.scaphys,
-	       card->hw.falcphys);
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+	printk(KERN_INFO
+	       "cpc:found  ramaddr=0x%016lx plxaddr=0x%016lx "
+	       "ctladdr=0x%016lx falcaddr=0x%016lx\n",
+	       (unsigned long)(card->hw.ramphys),
+	       (unsigned long)(card->hw.plxphys),
+	       (unsigned long)(card->hw.scaphys),
+	       (unsigned long)(card->hw.falcphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+	printk(KERN_INFO
+	       "cpc:found  ramaddr=0x%08x plxaddr=0x%08x "
+	       "ctladdr=0x%08x falcaddr=0x%08x\n",
+	       (unsigned int)(card->hw.ramphys),
+	       (unsigned int)(card->hw.plxphys),
+	       (unsigned int)(card->hw.scaphys),
+	       (unsigned int)(card->hw.falcphys));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
 #endif
 	/* Although we don't use this I/O region, we should
 	 * request it from the kernel anyway, to avoid problems
 	 * with other drivers accessing it. */
 	if (!request_region(card->hw.iophys, card->hw.iosize, "PLX Registers")) {
 		/* In case we can't allocate it, warn user */
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk("WARNING: couldn't allocate I/O region for PC300 board "
+		       "at 0x%016lx!\n", (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
 		printk("WARNING: couldn't allocate I/O region for PC300 board "
-		       "at 0x%08x!\n", card->hw.ramphys);
+		       "at 0x%08x!\n", (unsigned int)(card->hw.ramphys));
+#endif
 	}
 
 	if (card->hw.plxphys) {
@@ -3494,29 +3902,64 @@ cpc_init_one(struct pci_dev *pdev, const
 
 	if (!request_mem_region(card->hw.plxphys, card->hw.plxsize,
 				"PLX Registers")) {
-		printk("PC300 found at RAM 0x%08x, "
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%016lx, "
 		       "but could not allocate PLX mem region.\n",
-		       card->hw.ramphys);
+		       (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%08x, "
+		       "but could not allocate PLX mem region.\n",
+		       (unsigned int)(card->hw.ramphys));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
+		err = -ENODEV;
 		goto err_release_io;
 	}
 	if (!request_mem_region(card->hw.ramphys, card->hw.alloc_ramsize,
 				"On-board RAM")) {
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk("PC300 found at RAM 0x%016lx, "
+		       "but could not allocate SCA mem region.\n",
+		       (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
 		printk("PC300 found at RAM 0x%08x, "
 		       "but could not allocate RAM mem region.\n",
-		       card->hw.ramphys);
+		       (unsigned int)(card->hw.ramphys));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
+		err = -ENODEV;
 		goto err_release_plx;
 	}
 	if (!request_mem_region(card->hw.scaphys, card->hw.scasize,
 				"SCA-II Registers")) {
-		printk("PC300 found at RAM 0x%08x, "
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%016lx, "
+		       "but could not allocate SCA mem region.\n",
+		       (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%08x, "
 		       "but could not allocate SCA mem region.\n",
-		       card->hw.ramphys);
+		       (unsigned int)(card->hw.ramphys));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
+		err = -ENODEV;
 		goto err_release_ram;
 	}
 
-	card->hw.plxbase = ioremap(card->hw.plxphys, card->hw.plxsize);
-	card->hw.rambase = ioremap(card->hw.ramphys, card->hw.alloc_ramsize);
-	card->hw.scabase = ioremap(card->hw.scaphys, card->hw.scasize);
+	err = pci_enable_device(pdev);
+	if (err != 0)
+		goto err_release_sca;
+
+	card->hw.plxbase =
+		(void __iomem *) ioremap(card->hw.plxphys,
+					 card->hw.plxsize);
+	card->hw.rambase =
+		(void __iomem *) ioremap(card->hw.ramphys,
+					 card->hw.alloc_ramsize);
+	card->hw.scabase =
+		(void __iomem *) ioremap(card->hw.scaphys,
+					 card->hw.scasize);
 	switch (device_id) {
 		case PCI_DEVICE_ID_PC300_TE_1:
 		case PCI_DEVICE_ID_PC300_TE_2:
@@ -3524,7 +3967,9 @@ cpc_init_one(struct pci_dev *pdev, const
 		case PCI_DEVICE_ID_PC300_TE_M_2:
 			request_mem_region(card->hw.falcphys, card->hw.falcsize,
 					   "FALC Registers");
-			card->hw.falcbase = ioremap(card->hw.falcphys, card->hw.falcsize);
+			card->hw.falcbase =
+				(void __iomem *) ioremap(card->hw.falcphys,
+							 card->hw.falcsize);
 			break;
 
 		case PCI_DEVICE_ID_PC300_RX_1:
@@ -3535,10 +3980,23 @@ cpc_init_one(struct pci_dev *pdev, const
 	}
 
 #ifdef PC300_DEBUG_PCI
-	printk("cpc: relocate ramaddr=0x%08lx plxaddr=0x%08lx "
-	       "ctladdr=0x%08lx falcaddr=0x%08lx\n",
-	       card->hw.rambase, card->hw.plxbase, card->hw.scabase,
-	       card->hw.falcbase);
+#ifdef CONFIG_64BIT
+	printk(KERN_DEBUG
+	       "cpc: relocate ramaddr=0x%016lx plxaddr=0x%016lx "
+	       "ctladdr=0x%016lx falcaddr=0x%016lx\n",
+	       (unsigned long)(card->hw.rambase),
+	       (unsigned long)(card->hw.plxbase),
+	       (unsigned long)(card->hw.scabase),
+	       (unsigned long)(card->hw.falcbase));
+#else /* !CONFIG_64BIT */
+	printk(KERN_DEBUG
+	       "cpc: relocate ramaddr=0x%08x plxaddr=0x%08x "
+	       "ctladdr=0x%08x falcaddr=0x%08x\n",
+	       (unsigned int)(card->hw.rambase),
+	       (unsigned int)(card->hw.plxbase),
+	       (unsigned int)(card->hw.scabase),
+	       (unsigned int)(card->hw.falcbase));
+#endif /* CONFIG_64BIT */
 #endif
 
 	/* Set PCI drv pointer to the card structure */
@@ -3584,8 +4042,15 @@ cpc_init_one(struct pci_dev *pdev, const
 
 	/* Allocate IRQ */
 	if (request_irq(card->hw.irq, cpc_intr, IRQF_SHARED, "Cyclades-PC300", card)) {
-		printk ("PC300 found at RAM 0x%08x, but could not allocate IRQ%d.\n",
-			 card->hw.ramphys, card->hw.irq);
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%016lx, but could not allocate IRQ%d.\n",
+		       (unsigned long)(card->hw.ramphys), card->hw.irq);
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%08x, but could not allocate IRQ%d.\n",
+		       (unsigned int)(card->hw.ramphys), card->hw.irq);
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
 		goto err_io_unmap;
 	}
 
@@ -3603,6 +4068,7 @@ err_io_unmap:
 		iounmap(card->hw.falcbase);
 		release_mem_region(card->hw.falcphys, card->hw.falcsize);
 	}
+err_release_sca:
 	release_mem_region(card->hw.scaphys, card->hw.scasize);
 err_release_ram:
 	release_mem_region(card->hw.ramphys, card->hw.alloc_ramsize);
@@ -3611,9 +4077,7 @@ err_release_plx:
 err_release_io:
 	release_region(card->hw.iophys, card->hw.iosize);
 	kfree(card);
-err_disable_dev:
-	pci_disable_device(pdev);
-	return err;
+	return -ENODEV;
 }
 
 static void __devexit cpc_remove_one(struct pci_dev *pdev)
@@ -3628,7 +4092,8 @@ static void __devexit cpc_remove_one(str
 			   cpc_readw(card->hw.plxbase + card->hw.intctl_reg) & ~(0x0040));
 
 		for (i = 0; i < card->hw.nchan; i++) {
-			unregister_hdlc_device(card->chan[i].d.dev);
+			unregister_hdlc_device(card->chan[i].d.netdev);
+			free_netdev(card->chan[i].d.netdev);
 		}
 		iounmap(card->hw.plxbase);
 		iounmap(card->hw.scabase);
@@ -3641,13 +4106,9 @@ static void __devexit cpc_remove_one(str
 			iounmap(card->hw.falcbase);
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
 
diff -Npur -X linux-2.6.36/Documentation/dontdiff linux-2.6.36/drivers/net/wan/pc300_tty.c linux-2.6.36-pc300/drivers/net/wan/pc300_tty.c
--- linux-2.6.36/drivers/net/wan/pc300_tty.c	2010-10-20 13:30:22.000000000 -0700
+++ linux-2.6.36-pc300/drivers/net/wan/pc300_tty.c	2010-10-23 01:31:35.000000000 -0700
@@ -3,7 +3,7 @@
  *
  * Author:	Regina Kodato <reginak@cyclades.com>
  *
- * Copyright:	(c) 1999-2002 Cyclades Corp.
+ * Copyright:	(c) 1999-2004 Cyclades Corp.
  *
  *	This program is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU General Public License
@@ -50,6 +50,7 @@
 #include <linux/tty.h>
 #include <linux/tty_flip.h>
 #include <linux/serial.h>
+#include <linux/workqueue.h>
 
 #include <asm/io.h>
 #include <asm/uaccess.h>
@@ -153,7 +154,7 @@ static void cpc_tty_signal_off(pc300dev_
 	unsigned long flags; 
 
 	CPC_TTY_DBG("%s-tty: Clear signal %x\n",
-		pc300dev->dev->name, signal);
+		((struct net_device *)(pc300dev->hdlc))->name, signal);
 	CPC_TTY_LOCK(card, flags); 
 	cpc_writeb(card->hw.scabase + M_REG(CTL,ch), 
 		cpc_readb(card->hw.scabase+M_REG(CTL,ch))& signal);
@@ -171,7 +172,7 @@ static void cpc_tty_signal_on(pc300dev_t
 	unsigned long flags; 
 
 	CPC_TTY_DBG("%s-tty: Set signal %x\n",
-		pc300dev->dev->name, signal);
+		((struct net_device *)(pc300dev->hdlc))->name, signal);
 	CPC_TTY_LOCK(card, flags); 
 	cpc_writeb(card->hw.scabase + M_REG(CTL,ch), 
 		cpc_readb(card->hw.scabase+M_REG(CTL,ch))& ~signal);
@@ -204,22 +205,22 @@ static const struct tty_operations pc300
  */
 void cpc_tty_init(pc300dev_t *pc300dev)
 {
-	unsigned long port;
 	int aux;
+	long port;
 	st_cpc_tty_area * cpc_tty;
 
 	/* hdlcX - X=interface number */
-	port = pc300dev->dev->name[4] - '0';
+	port = ((struct net_device *)(pc300dev->hdlc))->name[4] - '0';
 	if (port >= CPC_TTY_NPORTS) {
 		printk("%s-tty: invalid interface selected (0-%i): %li",
-			pc300dev->dev->name,
+			((struct net_device *)(pc300dev->hdlc))->name,
 			CPC_TTY_NPORTS-1,port);
 		return;
 	}
 
 	if (cpc_tty_cnt == 0) { /* first TTY connection -> register driver */
 		CPC_TTY_DBG("%s-tty: driver init, major:%i, minor range:%i=%i\n",
-			pc300dev->dev->name,
+			((struct net_device *)(pc300dev->hdlc))->name,
 			CPC_TTY_MAJOR, CPC_TTY_MINOR_START,
 			CPC_TTY_MINOR_START+CPC_TTY_NPORTS);
 		/* initialize tty driver struct */
@@ -244,7 +245,7 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 		/* register the TTY driver */
 		if (tty_register_driver(&serial_drv)) { 
 			printk("%s-tty: Failed to register serial driver! ",
-				pc300dev->dev->name);
+				((struct net_device *)(pc300dev->hdlc))->name);
 		   	return;
 		} 
 
@@ -256,7 +257,8 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 	
 	if (cpc_tty->state != CPC_TTY_ST_IDLE) {
 		CPC_TTY_DBG("%s-tty: TTY port %i, already in use.\n",
-				pc300dev->dev->name, port);
+			    ((struct net_device *)(pc300dev->hdlc))->name,
+			    port);
 		return;
 	}
 
@@ -273,11 +275,11 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 
 	pc300dev->cpc_tty = (void *)cpc_tty; 
 	
-	aux = strlen(pc300dev->dev->name);
-	memcpy(cpc_tty->name, pc300dev->dev->name, aux);
+	aux = strlen(pc300dev->netdev->name);
+	memcpy(cpc_tty->name, pc300dev->netdev->name, aux);
 	memcpy(&cpc_tty->name[aux], "-tty", 5);
 	
-	cpc_open(pc300dev->dev);
+	cpc_open(pc300dev->netdev);
 	cpc_tty_signal_off(pc300dev, CTL_DTR);
 
 	CPC_TTY_DBG("%s: Initializing TTY Sync Driver, tty major#%d minor#%i\n",
@@ -410,7 +412,7 @@ static void cpc_tty_close(struct tty_str
 
 	CPC_TTY_DBG("%s: TTY closed\n",cpc_tty->name);
 	
-	if (!serial_drv.refcount && cpc_tty_unreg_flag) {
+	if (!cpc_tty_cnt && cpc_tty_unreg_flag) {
 		cpc_tty_unreg_flag = 0;
 		CPC_TTY_DBG("%s: unregister the tty driver\n", cpc_tty->name);
 		if ((res=tty_unregister_driver(&serial_drv))) { 
@@ -429,14 +431,16 @@ static void cpc_tty_close(struct tty_str
  * o verify the DCD signal
  * o send characters to board and start the transmission
  */
-static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf, int count)
+static int cpc_tty_write(struct tty_struct *tty,
+			const unsigned char *buf, int count)
 {
 	st_cpc_tty_area    *cpc_tty; 
 	pc300ch_t *pc300chan; 
 	pc300_t *card; 
 	int ch; 
 	unsigned long flags; 
-	struct net_device_stats *stats; 
+	struct net_device_stats *stats;
+	int from_user = 1;
 
 	if (!tty || !tty->driver_data ) { 
 		CPC_TTY_DBG("hdlcX-tty: no TTY in write\n");
@@ -455,10 +459,11 @@ static int cpc_tty_write(struct tty_stru
 		return -EINVAL;        /* frame too big */ 
 	}
 
-	CPC_TTY_DBG("%s: cpc_tty_write data len=%i\n",cpc_tty->name,count);
+	CPC_TTY_DBG("%s: cpc_tty_write %s data len=%i\n", cpc_tty->name,
+		(from_user) ? "from user" : "from kernel", count);
 	
 	pc300chan = (pc300ch_t *)((pc300dev_t*)cpc_tty->pc300dev)->chan; 
-	stats = &cpc_tty->pc300dev->dev->stats;
+	stats = &(cpc_tty->pc300dev->netdev->stats);
 	card = (pc300_t *) pc300chan->card;
 	ch = pc300chan->channel; 
 
@@ -482,10 +487,30 @@ static int cpc_tty_write(struct tty_stru
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
+			CPC_TTY_DBG("%s: error in copy from user\n"
+				    cpc_tty->name);
+			return -EINVAL;
+		}
+
+		if (cpc_tty_send_to_card(cpc_tty->pc300dev,
+					 (void *) buf_tmp, count)) {
+			/* failed to send */
+			CPC_TTY_DBG("%s: transmission error\n", cpc_tty->name);
+			return 0;
+		}
+	} else {
+		if (cpc_tty_send_to_card(cpc_tty->pc300dev,
+					 (void *)buf, count)) {
+			/* failed to send */
+			CPC_TTY_DBG("%s: trasmition error\n", cpc_tty->name);
+			return 0;
+		}
 	}
 	return count; 
 } 
@@ -619,7 +644,14 @@ static void cpc_tty_flush_buffer(struct 
 
 	CPC_TTY_DBG("%s: call wake_up_interruptible\n",cpc_tty->name);
 
-	tty_wakeup(tty);	
+	wake_up_interruptible(&tty->write_wait);
+
+	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) && tty->ldisc &&
+		tty->ldisc->ops && tty->ldisc->ops->write_wakeup){
+		CPC_TTY_DBG("%s: call line disc. wake up\n", cpc_tty->name);
+		tty->ldisc->ops->write_wakeup(tty);
+	}
+
 	return; 
 } 
 
@@ -646,7 +678,7 @@ static void cpc_tty_hangup(struct tty_st
 		CPC_TTY_DBG("%s: TTY is not opened\n",cpc_tty->name);
 		return ;
 	}
-	if (!serial_drv.refcount && cpc_tty_unreg_flag) {
+	if (!cpc_tty_cnt && cpc_tty_unreg_flag) {
 		cpc_tty_unreg_flag = 0;
 		CPC_TTY_DBG("%s: unregister the tty driver\n", cpc_tty->name);
 		if ((res=tty_unregister_driver(&serial_drv))) { 
@@ -667,11 +699,10 @@ static void cpc_tty_hangup(struct tty_st
 static void cpc_tty_rx_work(struct work_struct *work)
 {
 	st_cpc_tty_area *cpc_tty;
-	unsigned long port;
 	int i, j;
-	volatile st_cpc_rx_buf *buf;
+	unsigned long port;
+	st_cpc_rx_buf *buf;
 	char flags=0,flg_rx=1; 
-	struct tty_ldisc *ld;
 
 	if (cpc_tty_cnt == 0) return;
 	
@@ -685,16 +716,18 @@ static void cpc_tty_rx_work(struct work_
 			cpc_tty = &cpc_tty_area[port];
 		
 			if ((buf=cpc_tty->buf_rx.first) != NULL) {
-				if (cpc_tty->tty) {
-					ld = tty_ldisc_ref(cpc_tty->tty);
-					if (ld) {
-						if (ld->ops->receive_buf) {
-							CPC_TTY_DBG("%s: call line disc. receive_buf\n",cpc_tty->name);
-							ld->ops->receive_buf(cpc_tty->tty, (char *)(buf->data), &flags, buf->size);
-						}
-						tty_ldisc_deref(ld);
-					}
-				}	
+				if (cpc_tty->tty && cpc_tty->tty->ldisc &&
+				    cpc_tty->tty->ldisc->ops &&
+				    cpc_tty->tty->ldisc->ops->receive_buf) {
+					CPC_TTY_DBG(
+					  "%s: call line disc. receive_buf\n",
+					  cpc_tty->name);
+					cpc_tty->tty->
+					  ldisc->ops->
+					  receive_buf(cpc_tty->tty,
+						(char *)(buf->data),
+						&flags, buf->size);
+				}
 				cpc_tty->buf_rx.first = cpc_tty->buf_rx.first->next;
 				kfree((void *)buf);
 				buf = cpc_tty->buf_rx.first;
@@ -743,11 +776,11 @@ void cpc_tty_receive(pc300dev_t *pc300de
 	pc300_t *card = (pc300_t *)pc300chan->card; 
 	int ch = pc300chan->channel; 
 	volatile pcsca_bd_t  __iomem * ptdescr; 
-	struct net_device_stats *stats = &pc300dev->dev->stats;
+	struct net_device_stats *stats = &pc300dev->netdev->stats;
 	int rx_len, rx_aux; 
 	volatile unsigned char status; 
 	unsigned short first_bd = pc300chan->rx_first_bd;
-	st_cpc_rx_buf *new = NULL;
+	st_cpc_rx_buf *new;
 	unsigned char dsr_rx;
 
 	if (pc300dev->cpc_tty == NULL) { 
@@ -776,7 +809,6 @@ void cpc_tty_receive(pc300dev_t *pc300de
 				cpc_writel(card->hw.scabase + DRX_REG(EDAL, ch), 
 						RX_BD_ADDR(ch, pc300chan->rx_last_bd)); 
 			}
-			kfree(new);
 			return; 
 		}
 		
@@ -822,8 +854,7 @@ void cpc_tty_receive(pc300dev_t *pc300de
 						cpc_tty->name);
 				cpc_tty_rx_disc_frame(pc300chan);
 				rx_len = 0;
-				kfree(new);
-				new = NULL;
+				kfree((unsigned char *)new);
 				break; /* read next frame - while(1) */
 			}
 
@@ -832,8 +863,7 @@ void cpc_tty_receive(pc300dev_t *pc300de
 				cpc_tty_rx_disc_frame(pc300chan);
 				stats->rx_dropped++; 
 				rx_len = 0; 
-				kfree(new);
-				new = NULL;
+				kfree((unsigned char *)new);
 				break; /* read next frame - while(1) */
 			}
 
@@ -901,7 +931,14 @@ static void cpc_tty_tx_work(struct work_
 		CPC_TTY_DBG("%s: the interface is not opened\n",cpc_tty->name);
 		return; 
 	}
-	tty_wakeup(tty);
+
+	if ((tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) && tty->ldisc &&
+	     tty->ldisc->ops && tty->ldisc->ops->write_wakeup) {
+		CPC_TTY_DBG("%s:call line disc. wakeup\n", cpc_tty->name);
+		tty->ldisc->ops->write_wakeup(tty);
+	}
+
+	wake_up_interruptible(&tty->write_wait);
 }
 
 /*
@@ -917,7 +954,7 @@ static int cpc_tty_send_to_card(pc300dev
 	pc300ch_t *chan = (pc300ch_t *)dev->chan; 
 	pc300_t *card = (pc300_t *)chan->card; 
 	int ch = chan->channel; 
-	struct net_device_stats *stats = &dev->dev->stats;
+	struct net_device_stats *stats = &dev->netdev->stats;
 	unsigned long flags; 
 	volatile pcsca_bd_t __iomem *ptdescr; 
 	int i, nchar;
@@ -1001,18 +1038,19 @@ static void cpc_tty_trace(pc300dev_t *de
 
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
 	skb_reset_mac_header(skb);
 	skb->pkt_type = PACKET_HOST; 
 	skb->len = 10 + len; 
 
-	skb_copy_to_linear_data(skb, dev->dev->name, 5);
+	skb_copy_to_linear_data(skb, dev->netdev->name, 5);
 	skb->data[5] = '['; 
 	skb->data[6] = rxtx; 
 	skb->data[7] = ']'; 
@@ -1033,31 +1071,27 @@ void cpc_tty_unregister_service(pc300dev
 	ulong flags;
 	int res;
 
-	if ((cpc_tty= (st_cpc_tty_area *) pc300dev->cpc_tty) == NULL) {
-		CPC_TTY_DBG("%s: interface is not TTY\n", pc300dev->dev->name);
+	cpc_tty = (st_cpc_tty_area *) pc300dev->cpc_tty;
+	if (cpc_tty == NULL) {
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
 
 	if (--cpc_tty_cnt == 0) { 
-		if (serial_drv.refcount) {
-			CPC_TTY_DBG("%s: unregister is not possible, refcount=%d",
-							cpc_tty->name, serial_drv.refcount);
-			cpc_tty_cnt++;
-			cpc_tty_unreg_flag = 1;
-			return;
-		} else { 
-			CPC_TTY_DBG("%s: unregister the tty driver\n", cpc_tty->name);
-			if ((res=tty_unregister_driver(&serial_drv))) { 
-				CPC_TTY_DBG("%s: ERROR ->unregister the tty driver error=%d\n",
-								cpc_tty->name,res);
-			}
+		CPC_TTY_DBG("%s: unregister the tty driver\n", cpc_tty->name);
+		res = tty_unregister_driver(&serial_drv);
+		if (res) {
+			CPC_TTY_DBG(
+				"%s: ERROR ->unregister the tty driver error=%d\n",
+				cpc_tty->name, res);
 		}
 	}
 	CPC_TTY_LOCK(pc300dev->chan->card,flags);
