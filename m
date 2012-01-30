From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [21/22] Cyclades PC300 driver: omnibus patch from merge up to cleanup (patches 01 through 16 inclusive)
Date: Sun, 29 Jan 2012 19:01:15 -0800
Message-ID: <20120130030115.GV10262@cronus.persephoneslair.org>
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

This is an omnibus patch including patches 01 through 16 of this series; one
may readily verify that it passes checkpatch.pl style conformance and that it
builds cleanly.  The resulting driver will detect hardware but not operate
reliably or efficiently due to the bugs fixed in patches 17, 18 and 19.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index 423eb26..36a439a 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
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
diff --git a/drivers/net/wan/hd64572.h b/drivers/net/wan/hd64572.h
index 96567c2..2626fea 100644
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
index 2e4f84f..b0f3601 100644
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
@@ -105,9 +105,16 @@
 
 #define PC300_PROTO_MLPPP 1
 
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
@@ -143,13 +150,28 @@
  * Memory access functions/macros      *
  * (required to support Alpha systems) *
  ***************************************/
-#define cpc_writeb(port,val)	{writeb((u8)(val),(port)); mb();}
-#define cpc_writew(port,val)	{writew((ushort)(val),(port)); mb();}
-#define cpc_writel(port,val)	{writel((u32)(val),(port)); mb();}
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
 
-#define cpc_readb(port)		readb(port)
-#define cpc_readw(port)		readw(port)
-#define cpc_readl(port)		readl(port)
+#else /* __KERNEL__ */
+#define cpc_writeb(port, val)	(*((u8 *)(port)) = (u8)(val))
+#define cpc_writew(port, val)	(*((u16 *)(port)) = (u16)(val))
+#define cpc_writel(port, val)	(*((u32 *)(port)) = (u32)(val))
+
+#define cpc_readb(port)		(*((u8 *)(port)))
+#define cpc_readw(port)		(*((u16 *)(port)))
+#define cpc_readl(port)		(*((u32 *)(port)))
+
+#endif /* __KERNEL__ */
 
 /****** Data Structures *****************************************************/
 
@@ -267,11 +289,47 @@ typedef struct rsv_x21_status {
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
 
@@ -291,16 +349,31 @@ typedef struct pc300patterntst {
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
@@ -314,29 +387,60 @@ typedef struct pc300hw {
 	u16 cpld_reg2;		/* CPLD reg 2 (TE only) */
 	u16 gpioc_reg;		/* PLX GPIOC reg */
 	u16 intctl_reg;		/* PLX Int Ctrl/Status reg */
-	u32 iophys;		/* PLX registers I/O base */
+	phys_addr_t iophys;	/* PLX registers I/O base */
 	u32 iosize;		/* PLX registers I/O size */
-	u32 plxphys;		/* PLX registers MMIO base (physical) */
-	void __iomem * plxbase;	/* PLX registers MMIO base (virtual) */
+	phys_addr_t plxphys;	/* PLX registers MMIO base (physical) */
+	void __iomem *plxbase;	/* PLX registers MMIO base (virtual) */
 	u32 plxsize;		/* PLX registers MMIO size */
-	u32 scaphys;		/* SCA registers MMIO base (physical) */
-	void __iomem * scabase;	/* SCA registers MMIO base (virtual) */
+	phys_addr_t scaphys;	/* SCA registers MMIO base (physical) */
+	void __iomem *scabase;	/* SCA registers MMIO base (virtual) */
 	u32 scasize;		/* SCA registers MMIO size */
-	u32 ramphys;		/* On-board RAM MMIO base (physical) */
-	void __iomem * rambase;	/* On-board RAM MMIO base (virtual) */
+	phys_addr_t ramphys;	/* On-board RAM MMIO base (physical) */
+	void __iomem *rambase;	/* On-board RAM MMIO base (virtual) */
 	u32 alloc_ramsize;	/* RAM MMIO size allocated by the PCI bridge */
 	u32 ramsize;		/* On-board RAM MMIO size */
-	u32 falcphys;		/* FALC registers MMIO base (physical) */
-	void __iomem * falcbase;/* FALC registers MMIO base (virtual) */
+	phys_addr_t falcphys;	/* FALC registers MMIO base (physical) */
+	void __iomem *falcbase;/* FALC registers MMIO base (virtual) */
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
@@ -346,6 +450,8 @@ typedef struct pc300chconf {
 	u32 tslot_bitmap;	/* bit[i]=1  =>  timeslot _i_ is active */
 } pc300chconf_t;
 
+#ifdef __KERNEL__
+
 typedef struct pc300ch {
 	struct pc300 *card;
 	int channel;
@@ -365,8 +471,10 @@ typedef struct pc300 {
 	spinlock_t card_lock;
 } pc300_t;
 
+#endif /* __KERNEL__ */
+
 typedef struct pc300conf {
-	pc300hw_t hw;
+	struct pc300hw_user hw;
 	pc300chconf_t conf;
 } pc300conf_t;
 
@@ -430,7 +538,19 @@ enum pc300_loopback_cmds {
 #define PC300_TX_QUEUE_LEN	100
 #define	PC300_DEF_MTU		1600
 
-/* Function Prototypes */
-int cpc_open(struct net_device *dev);
+#ifdef __KERNEL__
+
+int cpc_open(struct net_device *);
+
+#ifdef CONFIG_PC300_MLPPP
+void cpc_tty_init(pc300dev_t *);
+void cpc_tty_unregister_service(pc300dev_t *);
+void cpc_tty_receive(pc300dev_t *);
+void cpc_tty_trigger_poll(pc300dev_t *);
+void cpc_tty_reset_var(void);
+#endif /* CONFIG_PC300_MLPP */
+
+#endif /* __KERNEL__ */
 
 #endif	/* _PC300_H */
+
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 1eeedd6..c44c26a 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -1,6 +1,6 @@
 #define	USE_PCI_CLOCK
 static const char rcsid[] =
-"Revision: 3.4.5 Date: 2002/03/07 ";
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
@@ -16,6 +16,10 @@ static const char rcsid[] =
  *	2 of the License, or (at your option) any later version.
  *	
  *	Using tabstop = 4.
+ *
+ * Due to changes in certain ioctls necessary for portability, this
+ * version requires a new version of pc300utils, which may be found
+ * at: http://charon.persephoneslair.org/~andrea/software/pc300utils/
  * 
  * $Log: pc300_drv.c,v $
  * Revision 3.23  2002/03/20 13:58:40  henrique
@@ -219,6 +223,7 @@ static const char rcsid[] =
 #include <linux/mm.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
+#include <linux/interrupt.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/init.h>
@@ -238,21 +243,22 @@ static const char rcsid[] =
 
 #include "pc300.h"
 
-#define	CPC_LOCK(card,flags)		\
-		do {						\
-		spin_lock_irqsave(&card->card_lock, flags);	\
-		} while (0)
+#define	CPC_LOCK(card, flags) \
+		{ \
+		    spin_lock_irqsave(&((card)->card_lock), (flags)); \
+		}
 
-#define CPC_UNLOCK(card,flags)			\
-		do {							\
-		spin_unlock_irqrestore(&card->card_lock, flags);	\
-		} while (0)
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
@@ -279,53 +285,128 @@ MODULE_DEVICE_TABLE(pci, cpc_pci_dev_id);
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
-static int cpc_attach(struct net_device *, unsigned short, unsigned short);
-static int cpc_close(struct net_device *dev);
+static int rx_config(pc300dev_t *);
+static inline void show_version(void);
+static int tx_config(pc300dev_t *);
 
-#ifdef CONFIG_PC300_MLPPP
-void cpc_tty_init(pc300dev_t * dev);
-void cpc_tty_unregister_service(pc300dev_t * pc300dev);
-void cpc_tty_receive(pc300dev_t * pc300dev);
-void cpc_tty_trigger_poll(pc300dev_t * pc300dev);
-void cpc_tty_reset_var(void);
-#endif
+static int cpc_attach(struct net_device *, unsigned short, unsigned short);
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
+
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
 
 /************************/
 /***   DMA Routines   ***/
 /************************/
-static void tx_dma_buf_pt_init(pc300_t * card, int ch)
+static void tx_dma_buf_pt_init(pc300_t *card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_TX_BUF;
-	volatile pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
-			               + DMA_TX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
+	pcsca_bd_t __iomem *ptdescr =
+		(card->hw.rambase + DMA_TX_BD_BASE +
+		 ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_TX_BUF; i++, ptdescr++) {
 		cpc_writel(&ptdescr->next, (u32)(DMA_TX_BD_BASE +
-			(ch_factor + ((i + 1) & (N_DMA_TX_BUF - 1))) * sizeof(pcsca_bd_t)));
+			(ch_factor + ((i + 1) & (N_DMA_TX_BUF - 1))) *
+			sizeof(pcsca_bd_t)));
 		cpc_writel(&ptdescr->ptbuf,
-			   (u32)(DMA_TX_BASE + (ch_factor + i) * BD_DEF_LEN));
+			(u32)(DMA_TX_BASE +
+			(ch_factor + i) * BD_DEF_LEN));
 	}
 }
 
-static void tx_dma_buf_init(pc300_t * card, int ch)
+static void tx_dma_buf_init(pc300_t *card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_TX_BUF;
-	volatile pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
-			       + DMA_TX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
+	pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
+			+ DMA_TX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_TX_BUF; i++, ptdescr++) {
 		memset_io(ptdescr, 0, sizeof(pcsca_bd_t));
@@ -335,27 +416,30 @@ static void tx_dma_buf_init(pc300_t * card, int ch)
 	tx_dma_buf_pt_init(card, ch);
 }
 
-static void rx_dma_buf_pt_init(pc300_t * card, int ch)
+static void rx_dma_buf_pt_init(pc300_t *card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_RX_BUF;
-	volatile pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
-				       + DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
+	pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
+			+ DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_RX_BUF; i++, ptdescr++) {
 		cpc_writel(&ptdescr->next, (u32)(DMA_RX_BD_BASE +
-			(ch_factor + ((i + 1) & (N_DMA_RX_BUF - 1))) * sizeof(pcsca_bd_t)));
+			(ch_factor + ((i + 1) & (N_DMA_RX_BUF - 1))) *
+			sizeof(pcsca_bd_t)));
 		cpc_writel(&ptdescr->ptbuf,
-			   (u32)(DMA_RX_BASE + (ch_factor + i) * BD_DEF_LEN));
+			(u32)(DMA_RX_BASE +
+			(ch_factor + i) * BD_DEF_LEN));
 	}
 }
 
-static void rx_dma_buf_init(pc300_t * card, int ch)
+static void rx_dma_buf_init(pc300_t *card, int ch)
 {
 	int i;
 	int ch_factor = ch * N_DMA_RX_BUF;
-	volatile pcsca_bd_t __iomem *ptdescr = (card->hw.rambase
-				       + DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
+	pcsca_bd_t __iomem *ptdescr =
+		(card->hw.rambase + DMA_RX_BD_BASE +
+		 ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_RX_BUF; i++, ptdescr++) {
 		memset_io(ptdescr, 0, sizeof(pcsca_bd_t));
@@ -365,88 +449,129 @@ static void rx_dma_buf_init(pc300_t * card, int ch)
 	rx_dma_buf_pt_init(card, ch);
 }
 
-static void tx_dma_buf_check(pc300_t * card, int ch)
+static void tx_dma_buf_check(pc300_t *card, int ch)
 {
-	volatile pcsca_bd_t __iomem *ptdescr;
+	pcsca_bd_t __iomem *ptdescr;
 	int i;
 	u16 first_bd = card->chan[ch].tx_first_bd;
 	u16 next_bd = card->chan[ch].tx_next_bd;
 
-	printk("#CH%d: f_bd = %d(0x%08zx), n_bd = %d(0x%08zx)\n", ch,
-	       first_bd, TX_BD_ADDR(ch, first_bd),
-	       next_bd, TX_BD_ADDR(ch, next_bd));
-	for (i = first_bd,
-	     ptdescr = (card->hw.rambase + TX_BD_ADDR(ch, first_bd));
-	     i != ((next_bd + 1) & (N_DMA_TX_BUF - 1));
-	     i = (i + 1) & (N_DMA_TX_BUF - 1), 
-		 ptdescr = (card->hw.rambase + TX_BD_ADDR(ch, i))) {
-		printk("\n CH%d TX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
-		       ch, i, cpc_readl(&ptdescr->next),
-		       cpc_readl(&ptdescr->ptbuf),
-		       cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
+	printk(KERN_DEBUG "#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
+		first_bd, (u32)TX_BD_ADDR(ch, first_bd),
+		next_bd, (u32)TX_BD_ADDR(ch, next_bd));
+	for (
+		i = first_bd,
+		ptdescr = (pcsca_bd_t *)
+			(card->hw.rambase + TX_BD_ADDR(ch, first_bd));
+
+		i != ((next_bd + 1) & (N_DMA_TX_BUF - 1));
+
+		i = (i + 1) & (N_DMA_TX_BUF - 1),
+		ptdescr = (pcsca_bd_t *)
+			(card->hw.rambase + TX_BD_ADDR(ch, i))
+		) {
+		printk(KERN_DEBUG
+			"\n CH%d TX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
+			ch, i, (u32) cpc_readl(&ptdescr->next),
+			(u32) cpc_readl(&ptdescr->ptbuf),
+			cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
 	}
-	printk("\n");
+	printk(KERN_DEBUG "\n");
 }
 
 #ifdef	PC300_DEBUG_OTHER
 /* Show all TX buffer descriptors */
-static void tx1_dma_buf_check(pc300_t * card, int ch)
+static void tx1_dma_buf_check(pc300_t *card, int ch)
 {
-	volatile pcsca_bd_t __iomem *ptdescr;
+	pcsca_bd_t __iomem *ptdescr;
 	int i;
 	u16 first_bd = card->chan[ch].tx_first_bd;
 	u16 next_bd = card->chan[ch].tx_next_bd;
-	u32 scabase = card->hw.scabase;
-
-	printk ("\nnfree_tx_bd = %d\n", card->chan[ch].nfree_tx_bd);
-	printk("#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
-	       first_bd, TX_BD_ADDR(ch, first_bd),
-	       next_bd, TX_BD_ADDR(ch, next_bd));
-	printk("TX_CDA=0x%08x, TX_EDA=0x%08x\n",
-	       cpc_readl(scabase + DTX_REG(CDAL, ch)),
-	       cpc_readl(scabase + DTX_REG(EDAL, ch)));
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
+
+	printk(KERN_DEBUG
+		"\nnfree_tx_bd = %d\n", card->chan[ch].nfree_tx_bd);
+	printk(KERN_DEBUG
+		"#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
+		first_bd, (u32)TX_BD_ADDR(ch, first_bd),
+		next_bd, (u32)TX_BD_ADDR(ch, next_bd));
+	printk(KERN_DEBUG
+		"TX_CDA=0x%08x, TX_EDA=0x%08x\n",
+		(u32)(cpc_readl(scabase + DTX_REG(CDAL, ch))),
+		(u32)(cpc_readl(scabase + DTX_REG(EDAL, ch))));
+	printk(KERN_DEBUG
+		"TX_CDA(BH/B/H/L) = %02x %02x %02x %02x\n",
+		(u8) cpc_readb(scabase + DTX_REG(CDABH, ch)),
+		(u8) cpc_readb(scabase + DTX_REG(CDAB, ch)),
+		(u8) cpc_readb(scabase + DTX_REG(CDAH, ch)),
+		(u8) cpc_readb(scabase + DTX_REG(CDAL, ch)));
+	printk(KERN_DEBUG
+		"TX_EDA(BH/B/H/L) = %02x %02x %02x %02x\n",
+		(u8) cpc_readb(scabase + DTX_REG(EDABH, ch)),
+		(u8) cpc_readb(scabase + DTX_REG(EDAB, ch)),
+		(u8) cpc_readb(scabase + DTX_REG(EDAH, ch)),
+		(u8) cpc_readb(scabase + DTX_REG(EDAL, ch)));
 	for (i = 0; i < N_DMA_TX_BUF; i++) {
 		ptdescr = (card->hw.rambase + TX_BD_ADDR(ch, i));
-		printk("\n CH%d TX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
-		       ch, i, cpc_readl(&ptdescr->next),
-		       cpc_readl(&ptdescr->ptbuf),
-		       cpc_readb(&ptdescr->status), cpc_readw(&ptdescr->len));
+		printk(KERN_DEBUG
+			"\n CH%d TX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
+			ch, i, (u32) cpc_readl(&ptdescr->next),
+			(u32) cpc_readl(&ptdescr->ptbuf),
+			cpc_readb(&ptdescr->status),
+			cpc_readw(&ptdescr->len));
+		printk(KERN_DEBUG
+			"\n CH%d TX%d: next=0x%02x%02x%02x%02x (endianess-correct)",
+			ch, i,
+			cpc_readb((unsigned char *)(&(ptdescr->next))+0x3),
+			cpc_readb((unsigned char *)(&(ptdescr->next))+0x2),
+			cpc_readb((unsigned char *)(&(ptdescr->next))+0x1),
+			cpc_readb((unsigned char *)(&(ptdescr->next))+0x0));
 	}
-	printk("\n");
+	printk(KERN_DEBUG "\n");
 }
 #endif
 
-static void rx_dma_buf_check(pc300_t * card, int ch)
+static void rx_dma_buf_check(pc300_t *card, int ch)
 {
-	volatile pcsca_bd_t __iomem *ptdescr;
+	pcsca_bd_t __iomem *ptdescr;
 	int i;
 	u16 first_bd = card->chan[ch].rx_first_bd;
 	u16 last_bd = card->chan[ch].rx_last_bd;
 	int ch_factor;
 
 	ch_factor = ch * N_DMA_RX_BUF;
-	printk("#CH%d: f_bd = %d, l_bd = %d\n", ch, first_bd, last_bd);
-	for (i = 0, ptdescr = (card->hw.rambase +
-					      DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
-	     i < N_DMA_RX_BUF; i++, ptdescr++) {
+	printk(KERN_DEBUG
+		"#CH%d: f_bd = %d, l_bd = %d\n", ch, first_bd, last_bd);
+	for (
+		i = 0,
+		ptdescr = (pcsca_bd_t *)
+			(card->hw.rambase + DMA_RX_BD_BASE +
+			 ch_factor * sizeof(pcsca_bd_t));
+
+		i < N_DMA_RX_BUF;
+
+		i++,
+		ptdescr++
+		) {
 		if (cpc_readb(&ptdescr->status) & DST_OSB)
-			printk ("\n CH%d RX%d: next=0x%x, ptbuf=0x%x, ST=0x%x, len=%d",
-				 ch, i, cpc_readl(&ptdescr->next),
-				 cpc_readl(&ptdescr->ptbuf),
-				 cpc_readb(&ptdescr->status),
-				 cpc_readw(&ptdescr->len));
+			printk(KERN_DEBUG
+				"\n CH%d RX%d: next=0x%08x, ptbuf=0x%08x, ST=0x%2x, len=%d",
+				ch, i, (u32) cpc_readl(&ptdescr->next),
+				(u32) cpc_readl(&ptdescr->ptbuf),
+				cpc_readb(&ptdescr->status),
+				cpc_readw(&ptdescr->len));
 	}
-	printk("\n");
+	printk(KERN_DEBUG "\n");
 }
 
-static int dma_get_rx_frame_size(pc300_t * card, int ch)
+static int dma_get_rx_frame_size(pc300_t *card, int ch)
 {
-	volatile pcsca_bd_t __iomem *ptdescr;
+	pcsca_bd_t __iomem *ptdescr;
 	u16 first_bd = card->chan[ch].rx_first_bd;
 	int rcvd = 0;
-	volatile u8 status;
+	u8 status;
 
-	ptdescr = (card->hw.rambase + RX_BD_ADDR(ch, first_bd));
+	ptdescr = (pcsca_bd_t *)(card->hw.rambase + RX_BD_ADDR(ch, first_bd));
 	while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 		rcvd += cpc_readw(&ptdescr->len);
 		first_bd = (first_bd + 1) & (N_DMA_RX_BUF - 1);
@@ -455,8 +580,11 @@ static int dma_get_rx_frame_size(pc300_t * card, int ch)
 			* (dma_buf_read will clean the buffer descriptors in this case). */
 			return rcvd;
 		}
-		ptdescr = (card->hw.rambase + cpc_readl(&ptdescr->next));
+		ptdescr = (pcsca_bd_t *)
+			(card->hw.rambase +
+			 cpc_readl(&ptdescr->next));
 	}
+
 	return -1;
 }
 
@@ -467,7 +595,7 @@ static int dma_get_rx_frame_size(pc300_t * card, int ch)
 static int dma_buf_write(pc300_t *card, int ch, u8 *ptdata, int len)
 {
 	int i, nchar;
-	volatile pcsca_bd_t __iomem *ptdescr;
+	pcsca_bd_t __iomem *ptdescr;
 	int tosend = len;
 	u8 nbuf = ((len - 1) / BD_DEF_LEN) + 1;
 
@@ -476,11 +604,12 @@ static int dma_buf_write(pc300_t *card, int ch, u8 *ptdata, int len)
 	}
 
 	for (i = 0; i < nbuf; i++) {
-		ptdescr = (card->hw.rambase +
+		ptdescr = (pcsca_bd_t *) (card->hw.rambase +
 					  TX_BD_ADDR(ch, card->chan[ch].tx_next_bd));
 		nchar = cpc_min(BD_DEF_LEN, tosend);
 		if (cpc_readb(&ptdescr->status) & DST_OSB) {
-			memcpy_toio((card->hw.rambase + cpc_readl(&ptdescr->ptbuf)),
+			memcpy_toio((card->hw.rambase +
+				cpc_readl(&ptdescr->ptbuf)),
 				    &ptdata[len - tosend], nchar);
 			cpc_writew(&ptdescr->len, nchar);
 			card->chan[ch].nfree_tx_bd--;
@@ -495,7 +624,8 @@ static int dma_buf_write(pc300_t *card, int ch, u8 *ptdata, int len)
 		}
 		tosend -= nchar;
 		card->chan[ch].tx_next_bd =
-			(card->chan[ch].tx_next_bd + 1) & (N_DMA_TX_BUF - 1);
+			(card->chan[ch].tx_next_bd + 1) &
+			(N_DMA_TX_BUF - 1);
 	}
 	/* If it gets to here, it means we have sent the whole frame */
 	return 0;
@@ -505,20 +635,22 @@ static int dma_buf_write(pc300_t *card, int ch, u8 *ptdata, int len)
  * dma_buf_read: reads a frame from the Rx DMA buffers
  * NOTE: this function reads one frame at a time.
  */
-static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
+static int dma_buf_read(pc300_t *card, int ch, struct sk_buff *skb)
 {
 	int nchar;
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
-	volatile pcsca_bd_t __iomem *ptdescr;
+	pcsca_bd_t __iomem *ptdescr;
 	int rcvd = 0;
-	volatile u8 status;
+	u8 status;
 
-	ptdescr = (card->hw.rambase +
+	ptdescr = (pcsca_bd_t *)(card->hw.rambase +
 				  RX_BD_ADDR(ch, chan->rx_first_bd));
 	while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 		nchar = cpc_readw(&ptdescr->len);
-		if ((status & (DST_OVR | DST_CRC | DST_RBIT | DST_SHRT | DST_ABT)) ||
-		    (nchar > BD_DEF_LEN)) {
+		if ((status &
+					(DST_OVR | DST_CRC | DST_RBIT |
+					 DST_SHRT | DST_ABT))
+		    || (nchar > BD_DEF_LEN)) {
 
 			if (nchar > BD_DEF_LEN)
 				status |= DST_RBIT;
@@ -529,7 +661,7 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 				chan->rx_first_bd = (chan->rx_first_bd+1) & (N_DMA_RX_BUF-1);
 				if (status & DST_EOM)
 					break;
-				ptdescr = (card->hw.rambase +
+				ptdescr = (pcsca_bd_t *) (card->hw.rambase +
 							  cpc_readl(&ptdescr->next));
 				status = cpc_readb(&ptdescr->status);
 			}
@@ -538,23 +670,29 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 		if (nchar != 0) {
 			if (skb) {
 				memcpy_fromio(skb_put(skb, nchar),
-				 (card->hw.rambase+cpc_readl(&ptdescr->ptbuf)),nchar);
+				 (void *)(card->hw.rambase +
+					 cpc_readl(&ptdescr->ptbuf)), nchar);
 			}
 			rcvd += nchar;
 		}
 		cpc_writeb(&ptdescr->status, 0);
 		cpc_writeb(&ptdescr->len, 0);
-		chan->rx_first_bd = (chan->rx_first_bd + 1) & (N_DMA_RX_BUF - 1);
+		chan->rx_first_bd =
+			(chan->rx_first_bd + 1) &
+			(N_DMA_RX_BUF - 1);
 
 		if (status & DST_EOM)
 			break;
 
-		ptdescr = (card->hw.rambase + cpc_readl(&ptdescr->next));
+		ptdescr = (pcsca_bd_t *)
+			(card->hw.rambase + cpc_readl(&ptdescr->next));
 	}
 
 	if (rcvd != 0) {
 		/* Update pointer */
-		chan->rx_last_bd = (chan->rx_first_bd - 1) & (N_DMA_RX_BUF - 1);
+		chan->rx_last_bd =
+			(chan->rx_first_bd - 1) &
+			(N_DMA_RX_BUF - 1);
 		/* Update EDA */
 		cpc_writel(card->hw.scabase + DRX_REG(EDAL, ch),
 			   RX_BD_ADDR(ch, chan->rx_last_bd));
@@ -562,9 +700,9 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 	return rcvd;
 }
 
-static void tx_dma_stop(pc300_t * card, int ch)
+static void tx_dma_stop(pc300_t *card, int ch)
 {
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	u8 drr_ena_bit = 1 << (5 + 2 * ch);
 	u8 drr_rst_bit = 1 << (1 + 2 * ch);
 
@@ -573,9 +711,9 @@ static void tx_dma_stop(pc300_t * card, int ch)
 	cpc_writeb(scabase + DRR, drr_rst_bit & ~drr_ena_bit);
 }
 
-static void rx_dma_stop(pc300_t * card, int ch)
+static void rx_dma_stop(pc300_t *card, int ch)
 {
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	u8 drr_ena_bit = 1 << (4 + 2 * ch);
 	u8 drr_rst_bit = 1 << (2 * ch);
 
@@ -584,9 +722,9 @@ static void rx_dma_stop(pc300_t * card, int ch)
 	cpc_writeb(scabase + DRR, drr_rst_bit & ~drr_ena_bit);
 }
 
-static void rx_dma_start(pc300_t * card, int ch)
+static void rx_dma_start(pc300_t *card, int ch)
 {
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	
 	/* Start DMA */
@@ -602,7 +740,7 @@ static void rx_dma_start(pc300_t * card, int ch)
 	cpc_writew(scabase + DRX_REG(BFLL, ch), BD_DEF_LEN);
 	cpc_writeb(scabase + DSR_RX(ch), DSR_DE);
 	if (!(cpc_readb(scabase + DSR_RX(ch)) & DSR_DE)) {
-	cpc_writeb(scabase + DSR_RX(ch), DSR_DE);
+		cpc_writeb(scabase + DSR_RX(ch), DSR_DE);
 	}
 }
 
@@ -611,25 +749,26 @@ static void rx_dma_start(pc300_t * card, int ch)
 /*************************/
 static void falc_issue_cmd(pc300_t *card, int ch, u8 cmd)
 {
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	unsigned long i = 0;
 
 	while (cpc_readb(falcbase + F_REG(SIS, ch)) & SIS_CEC) {
 		if (i++ >= PC300_FALC_MAXLOOP) {
-			printk("%s: FALC command locked(cmd=0x%x).\n",
-			       card->chan[ch].d.name, cmd);
+			printk(KERN_ERR
+					"%s: FALC command locked(cmd=0x%x).\n",
+					card->chan[ch].d.name, cmd);
 			break;
 		}
 	}
 	cpc_writeb(falcbase + F_REG(CMDR, ch), cmd);
 }
 
-static void falc_intr_enable(pc300_t * card, int ch)
+static void falc_intr_enable(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	/* Interrupt pins are open-drain */
 	cpc_writeb(falcbase + F_REG(IPC, ch),
@@ -674,9 +813,9 @@ static void falc_intr_enable(pc300_t * card, int ch)
 	}
 }
 
-static void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
+static void falc_open_timeslot(pc300_t *card, int ch, int timeslot)
 {
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 tshf = card->chan[ch].falc.offset;
 
 	cpc_writeb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch),
@@ -690,9 +829,9 @@ static void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
 			(0x80 >> (timeslot & 0x07)));
 }
 
-static void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
+static void falc_close_timeslot(pc300_t *card, int ch, int timeslot)
 {
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 tshf = card->chan[ch].falc.offset;
 
 	cpc_writeb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch),
@@ -706,11 +845,11 @@ static void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
 		   ~(0x80 >> (timeslot & 0x07)));
 }
 
-static void falc_close_all_timeslots(pc300_t * card, int ch)
+static void falc_close_all_timeslots(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	cpc_writeb(falcbase + F_REG(ICB1, ch), 0xff);
 	cpc_writeb(falcbase + F_REG(TTR1, ch), 0);
@@ -728,11 +867,11 @@ static void falc_close_all_timeslots(pc300_t * card, int ch)
 	}
 }
 
-static void falc_open_all_timeslots(pc300_t * card, int ch)
+static void falc_open_all_timeslots(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	cpc_writeb(falcbase + F_REG(ICB1, ch), 0);
 	if (conf->fr_mode == PC300_FR_UNFRAMED) {
@@ -760,7 +899,7 @@ static void falc_open_all_timeslots(pc300_t * card, int ch)
 	}
 }
 
-static void falc_init_timeslot(pc300_t * card, int ch)
+static void falc_init_timeslot(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -778,7 +917,7 @@ static void falc_init_timeslot(pc300_t * card, int ch)
 	}
 }
 
-static void falc_enable_comm(pc300_t * card, int ch)
+static void falc_enable_comm(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -794,7 +933,7 @@ static void falc_enable_comm(pc300_t * card, int ch)
 		   ~((CPLD_REG1_FALC_DCD | CPLD_REG1_FALC_CTS) << (2 * ch)));
 }
 
-static void falc_disable_comm(pc300_t * card, int ch)
+static void falc_disable_comm(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -808,12 +947,12 @@ static void falc_disable_comm(pc300_t * card, int ch)
 		   ((CPLD_REG1_FALC_DCD | CPLD_REG1_FALC_CTS) << (2 * ch)));
 }
 
-static void falc_init_t1(pc300_t * card, int ch)
+static void falc_init_t1(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
 
 	/* Switch to T1 mode (PCM 24) */
@@ -977,12 +1116,12 @@ static void falc_init_t1(pc300_t * card, int ch)
 	falc_close_all_timeslots(card, ch);
 }
 
-static void falc_init_e1(pc300_t * card, int ch)
+static void falc_init_e1(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
 
 	/* Switch to E1 mode (PCM 30) */
@@ -1157,9 +1296,9 @@ static void falc_init_e1(pc300_t * card, int ch)
 	falc_close_all_timeslots(card, ch);
 }
 
-static void falc_init_hdlc(pc300_t * card, int ch)
+static void falc_init_hdlc(pc300_t *card, int ch)
 {
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 
@@ -1183,12 +1322,12 @@ static void falc_init_hdlc(pc300_t * card, int ch)
 	falc_intr_enable(card, ch);
 }
 
-static void te_config(pc300_t * card, int ch)
+static void te_config(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 dummy;
 	unsigned long flags;
 
@@ -1243,12 +1382,12 @@ static void te_config(pc300_t * card, int ch)
 	CPC_UNLOCK(card, flags);
 }
 
-static void falc_check_status(pc300_t * card, int ch, unsigned char frs0)
+static void falc_check_status(pc300_t *card, int ch, unsigned char frs0)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	/* Verify LOS */
 	if (frs0 & FRS0_LOS) {
@@ -1399,12 +1538,12 @@ static void falc_check_status(pc300_t * card, int ch, unsigned char frs0)
 	}
 }
 
-static void falc_update_stats(pc300_t * card, int ch)
+static void falc_update_stats(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u16 counter;
 
 	counter = cpc_readb(falcbase + F_REG(FECL, ch));
@@ -1451,12 +1590,12 @@ static void falc_update_stats(pc300_t * card, int ch)
  *		the synchronizer and then sent to the system interface.
  *----------------------------------------------------------------------------
  */
-static void falc_remote_loop(pc300_t * card, int ch, int loop_on)
+static void falc_remote_loop(pc300_t *card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (loop_on) {
 		// EVENT_FALC_ABNORMAL
@@ -1496,11 +1635,11 @@ static void falc_remote_loop(pc300_t * card, int ch, int loop_on)
  *		coding must be identical.
  *----------------------------------------------------------------------------
  */
-static void falc_local_loop(pc300_t * card, int ch, int loop_on)
+static void falc_local_loop(pc300_t *card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (loop_on) {
 		cpc_writeb(falcbase + F_REG(LIM0, ch),
@@ -1523,12 +1662,12 @@ static void falc_local_loop(pc300_t * card, int ch, int loop_on)
  *		looped. They are originated by the FALC-LH transmitter.
  *----------------------------------------------------------------------------
  */
-static void falc_payload_loop(pc300_t * card, int ch, int loop_on)
+static void falc_payload_loop(pc300_t *card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (loop_on) {
 		// EVENT_FALC_ABNORMAL
@@ -1577,11 +1716,11 @@ static void falc_payload_loop(pc300_t * card, int ch, int loop_on)
  * Description:	Turns XLU bit off in the proper register
  *----------------------------------------------------------------------------
  */
-static void turn_off_xlu(pc300_t * card, int ch)
+static void turn_off_xlu(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1598,11 +1737,11 @@ static void turn_off_xlu(pc300_t * card, int ch)
  * Description: Turns XLD bit off in the proper register
  *----------------------------------------------------------------------------
  */
-static void turn_off_xld(pc300_t * card, int ch)
+static void turn_off_xld(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1620,12 +1759,12 @@ static void turn_off_xld(pc300_t * card, int ch)
  *		to generate a LOOP activation code over a T1/E1 line.
  *----------------------------------------------------------------------------
  */
-static void falc_generate_loop_up_code(pc300_t * card, int ch)
+static void falc_generate_loop_up_code(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1653,12 +1792,12 @@ static void falc_generate_loop_up_code(pc300_t * card, int ch)
  *		to generate a LOOP deactivation code over a T1/E1 line.
  *----------------------------------------------------------------------------
  */
-static void falc_generate_loop_down_code(pc300_t * card, int ch)
+static void falc_generate_loop_down_code(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (conf->media == IF_IFACE_T1) {
 		cpc_writeb(falcbase + F_REG(FMR5, ch),
@@ -1683,12 +1822,12 @@ static void falc_generate_loop_down_code(pc300_t * card, int ch)
  *		it on the reception side.
  *----------------------------------------------------------------------------
  */
-static void falc_pattern_test(pc300_t * card, int ch, unsigned int activate)
+static void falc_pattern_test(pc300_t *card, int ch, unsigned int activate)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (activate) {
 		pfalc->prbs = 1;
@@ -1730,7 +1869,7 @@ static void falc_pattern_test(pc300_t * card, int ch, unsigned int activate)
  * Description:	This routine returns the bit error counter value
  *----------------------------------------------------------------------------
  */
-static u16 falc_pattern_test_error(pc300_t * card, int ch)
+static u16 falc_pattern_test_error(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -1748,7 +1887,9 @@ cpc_trace(struct net_device *dev, struct sk_buff *skb_main, char rx_tx)
 	struct sk_buff *skb;
 
 	if ((skb = dev_alloc_skb(10 + skb_main->len)) == NULL) {
-		printk("%s: out of memory\n", dev->name);
+		printk(KERN_ERR
+				"%s: out of memory\n",
+				dev->name);
 		return;
 	}
 	skb_put(skb, 10 + skb_main->len);
@@ -1775,15 +1916,24 @@ static void cpc_tx_timeout(struct net_device *dev)
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
-		printk("%s: ILAR=0x%x\n", dev->name, ilar);
+#ifdef PC300_DEBUG_OTHER
+		printk(KERN_DEBUG
+				"%s: ILAR=0x%x\n",
+				dev->name, ilar);
+#endif
 		cpc_writeb(card->hw.scabase + ILAR, ilar);
 		cpc_writeb(card->hw.scabase + DMER, 0x80);
 	}
@@ -1792,8 +1942,13 @@ static void cpc_tx_timeout(struct net_device *dev)
 			   cpc_readb(card->hw.falcbase + card->hw.cpld_reg2) &
 			   ~(CPLD_REG2_FALC_LED1 << (2 * ch)));
 	}
-	dev->trans_start = jiffies; /* prevent tx timeout */
+	dev->trans_start = jiffies;
 	CPC_UNLOCK(card, flags);
+#ifdef PC300_DEBUG_QUEUE
+	printk(KERN_DEBUG
+			"%s: waking queue, finished cpc_tx_timeout()\n",
+			dev->name);
+#endif
 	netif_wake_queue(dev);
 }
 
@@ -1802,22 +1957,52 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
+	struct net_device_stats *stats = &(dev->stats);
 	int ch = chan->channel;
 	unsigned long flags;
 #ifdef PC300_DEBUG_TX
 	int i;
 #endif
 
-	if (!netif_carrier_ok(dev)) {
+#ifdef PC300_DEBUG_TX
+	printk(KERN_DEBUG
+			"%s: cpc_queue_xmit called wih %d bytes\n",
+			dev->name, skb->len);
+#endif
+	if (chan->conf.monitor) {
+		/* In monitor mode no Tx is done: ignore packet */
+		dev_kfree_skb(skb);
+#ifdef PC300_DEBUG_OTHER
+		printk(KERN_DEBUG
+				"%s: dropping TX packet because in monitor mode\n",
+				dev->name);
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
+		printk(KERN_DEBUG
+				"%s: TX carrier error; dropping silently\n",
+				dev->name);
+#endif
 		return 0;
-	} else if (cpc_readb(card->hw.scabase + M_REG(ST3, ch)) & ST3_DCD) {
-		printk("%s: DCD is OFF. Going administrative down.\n", dev->name);
-		dev->stats.tx_errors++;
-		dev->stats.tx_carrier_errors++;
+	} else if (
+			cpc_readb(card->hw.scabase +
+				M_REG(ST3, ch)) &
+			ST3_DCD) {
+		printk(KERN_INFO
+				"%s: DCD is OFF. Going administrative down.\n",
+				dev->name);
+		stats->tx_errors++;
+		stats->tx_carrier_errors++;
+#ifdef PC300_DEBUG_OTHER
+		printk(KERN_DEBUG
+				"%s: TX carrier error; dropping silently\n",
+				dev->name);
+#endif
 		dev_kfree_skb(skb);
 		netif_carrier_off(dev);
 		CPC_LOCK(card, flags);
@@ -1828,34 +2013,59 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 				   			~(CPLD_REG2_FALC_LED1 << (2 * ch)));
 		}
 		CPC_UNLOCK(card, flags);
+#ifdef PC300_DEBUG_QUEUE
+		printk(KERN_DEBUG
+				"%s: waking queue after TX carrier error\n",
+				dev->name);
+#endif
 		netif_wake_queue(dev);
 		return 0;
 	}
 
+	CPC_LOCK(card, flags);
 	/* Write buffer to DMA buffers */
-	if (dma_buf_write(card, ch, (u8 *)skb->data, skb->len) != 0) {
-//		printk("%s: write error. Dropping TX packet.\n", dev->name);
+	if (dma_buf_write(
+				card, ch,
+				(u8 *) skb->data,
+				skb->len) != 0) {
+		CPC_UNLOCK(card, flags);
+		printk(KERN_ERR
+				"%s: write error. Dropping TX packet.\n",
+				dev->name);
+#ifdef PC300_DEBUG_QUEUE
+		printk(KERN_DEBUG
+			"%s: stopping queue due to DMA error\n",
+			dev->name);
+#endif
+		d->reason_stopped = CPC_DMA_ERROR;
 		netif_stop_queue(dev);
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
-	printk("%s T:", dev->name);
+	printk(KERN_DEBUG "%s T:", dev->name);
 	for (i = 0; i < skb->len; i++)
-		printk(" %02x", *(skb->data + i));
-	printk("\n");
+		printk(KERN_DEBUG " %02x", *(skb->data + i));
+	printk(KERN_DEBUG "\n");
 #endif
 
 	if (d->trace_on) {
 		cpc_trace(dev, skb, 'T');
 	}
+	dev->trans_start = jiffies;
 
 	/* Start transmission */
 	CPC_LOCK(card, flags);
 	/* verify if it has more than one free descriptor */
 	if (card->chan[ch].nfree_tx_bd <= 1) {
+#ifdef PC300_DEBUG_QUEUE
+		printk(KERN_DEBUG
+			"%s: stopping queue for transmission\n",
+			dev->name);
+#endif
 		/* don't have so stop the queue */
 		netif_stop_queue(dev);
 	}
@@ -1871,6 +2081,11 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	CPC_UNLOCK(card, flags);
 	dev_kfree_skb(skb);
 
+#ifdef PC300_DEBUG_TX
+	printk(KERN_DEBUG "%s: cpc_queue_xmit returning normally\n",
+	       dev->name);
+#endif
+
 	return 0;
 }
 
@@ -1879,6 +2094,7 @@ static void cpc_net_rx(struct net_device *dev)
 	pc300dev_t *d = (pc300dev_t *) dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
+	struct net_device_stats *stats = &(dev->stats);
 	int ch = chan->channel;
 #ifdef PC300_DEBUG_RX
 	int i;
@@ -1892,16 +2108,22 @@ static void cpc_net_rx(struct net_device *dev)
 
 		if (!netif_carrier_ok(dev)) {
 			/* DCD must be OFF: drop packet */
-		    printk("%s : DCD is OFF - drop %d rx bytes\n", dev->name, rxb); 
+			printk(KERN_INFO
+				"%s : DCD is OFF - drop %d rx bytes\n",
+				dev->name, rxb);
 			skb = NULL;
 		} else {
 			if (rxb > (dev->mtu + 40)) { /* add headers */
-				printk("%s : MTU exceeded %d\n", dev->name, rxb); 
+				printk(KERN_ERR
+					"%s : MTU exceeded %d\n",
+					dev->name, rxb);
 				skb = NULL;
 			} else {
 				skb = dev_alloc_skb(rxb);
 				if (skb == NULL) {
-					printk("%s: Memory squeeze!!\n", dev->name);
+					printk(KERN_ERR
+						"%s: Memory squeeze!!\n",
+						dev->name);
 					return;
 				}
 				skb->dev = dev;
@@ -1910,28 +2132,30 @@ static void cpc_net_rx(struct net_device *dev)
 
 		if (((rxb = dma_buf_read(card, ch, skb)) <= 0) || (skb == NULL)) {
 #ifdef PC300_DEBUG_RX
-			printk("%s: rxb = %x\n", dev->name, rxb);
+			printk(KERN_DEBUG
+				"%s: rxb = %x\n",
+				dev->name, rxb);
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
@@ -1940,18 +2164,19 @@ static void cpc_net_rx(struct net_device *dev)
 			continue;
 		}
 
-		dev->stats.rx_bytes += rxb;
+		stats->rx_bytes += rxb;
 
 #ifdef PC300_DEBUG_RX
-		printk("%s R:", dev->name);
+		printk(KERN_DEBUG "%s R:", dev->name);
 		for (i = 0; i < skb->len; i++)
-			printk(" %02x", *(skb->data + i));
-		printk("\n");
+			printk(KERN_DEBUG " %02x", *(skb->data + i));
+		printk(KERN_DEBUG "\n");
 #endif
 		if (d->trace_on) {
 			cpc_trace(dev, skb, 'R');
 		}
-		dev->stats.rx_packets++;
+		stats->rx_packets++;
+		skb_reset_mac_header(skb);
 		skb->protocol = hdlc_type_trans(skb, dev);
 		netif_rx(skb);
 	}
@@ -1964,23 +2189,28 @@ static void sca_tx_intr(pc300dev_t *dev)
 {
 	pc300ch_t *chan = (pc300ch_t *)dev->chan; 
 	pc300_t *card = (pc300_t *)chan->card; 
-	int ch = chan->channel; 
-	volatile pcsca_bd_t __iomem * ptdescr; 
+	int ch = chan->channel;
+	pcsca_bd_t *ptdescr;
+	struct net_device_stats *stats = &(dev->netdev->stats);
 
     /* Clean up descriptors from previous transmission */
-	ptdescr = (card->hw.rambase +
-						TX_BD_ADDR(ch,chan->tx_first_bd));
-	while ((cpc_readl(card->hw.scabase + DTX_REG(CDAL,ch)) !=
-		TX_BD_ADDR(ch,chan->tx_first_bd)) &&
-	       (cpc_readb(&ptdescr->status) & DST_OSB)) {
-		dev->dev->stats.tx_packets++;
-		dev->dev->stats.tx_bytes += cpc_readw(&ptdescr->len);
+	ptdescr = (pcsca_bd_t *)
+		(card->hw.rambase +
+		 TX_BD_ADDR(ch, chan->tx_first_bd));
+	while (
+			(cpc_readl(card->hw.scabase + DTX_REG(CDAL, ch)) !=
+			TX_BD_ADDR(ch, chan->tx_first_bd)) &&
+			(cpc_readb(&ptdescr->status) & DST_OSB)
+			) {
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
@@ -1988,38 +2218,46 @@ static void sca_tx_intr(pc300dev_t *dev)
 	} else {
 #endif
 	/* Tell the upper layer we are ready to transmit more packets */
-		netif_wake_queue(dev->dev);
+#ifdef PC300_DEBUG_QUEUE
+		printk(KERN_DEBUG "Waking queue on TX interrupt\n");
+#endif
+		netif_wake_queue(dev->netdev);
 #ifdef CONFIG_PC300_MLPPP
 	}
 #endif
 }
 
-static void sca_intr(pc300_t * card)
+static void sca_intr(pc300_t *card)
 {
-	void __iomem *scabase = card->hw.scabase;
-	volatile u32 status;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
+	u32 status;
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
 
 	    /**** Reception ****/
 			if (status & IR0_DRX((IR0_DMIA | IR0_DMIB), ch)) {
-				u8 drx_stat = cpc_readb(scabase + DSR_RX(ch));
+				u8 drx_stat =
+					cpc_readb(scabase + DSR_RX(ch));
 
 				/* Clear RX interrupts */
 				cpc_writeb(scabase + DSR_RX(ch), drx_stat | DSR_DWE);
 
 #ifdef PC300_DEBUG_INTR
-				printk ("sca_intr: RX intr chan[%d] (st=0x%08lx, dsr=0x%02x)\n",
-					 ch, status, drx_stat);
+				printk(KERN_DEBUG "sca_intr: RX intr chan[%d] (st=0x%08x, dsr=0x%02x)\n",
+				       ch, status, drx_stat);
 #endif
 				if (status & IR0_DRX(IR0_DMIA, ch)) {
 					if (drx_stat & DSR_BOF) {
@@ -2039,10 +2277,15 @@ static void sca_intr(pc300_t * card)
 							}
 							cpc_net_rx(dev);
 							/* Discard invalid frames */
-							dev->stats.rx_errors++;
-							dev->stats.rx_over_errors++;
-							chan->rx_first_bd = 0;
-							chan->rx_last_bd = N_DMA_RX_BUF - 1;
+							++dev->stats.
+								rx_errors;
+							++dev->stats.
+								rx_over_errors;
+							chan->rx_first_bd
+								= 0;
+							chan->rx_last_bd
+								= N_DMA_RX_BUF
+								- 1;
 							rx_dma_start(card, ch);
 						}
 					}
@@ -2077,8 +2320,10 @@ static void sca_intr(pc300_t * card)
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
@@ -2086,14 +2331,15 @@ static void sca_intr(pc300_t * card)
 
 	    /**** Transmission ****/
 			if (status & IR0_DTX((IR0_EFT | IR0_DMIA | IR0_DMIB), ch)) {
-				u8 dtx_stat = cpc_readb(scabase + DSR_TX(ch));
+				u8 dtx_stat =
+					cpc_readb(scabase + DSR_TX(ch));
 
 				/* Clear TX interrupts */
 				cpc_writeb(scabase + DSR_TX(ch), dtx_stat | DSR_DWE);
 
 #ifdef PC300_DEBUG_INTR
-				printk ("sca_intr: TX intr chan[%d] (st=0x%08lx, dsr=0x%02x)\n",
-					 ch, status, dtx_stat);
+				printk(KERN_DEBUG "sca_intr: TX intr chan[%d] (st=0x%08x, dsr=0x%02x)\n",
+				       ch, status, dtx_stat);
 #endif
 				if (status & IR0_DTX(IR0_EFT, ch)) {
 					if (dtx_stat & DSR_UDRF) {
@@ -2108,8 +2354,17 @@ static void sca_intr(pc300_t * card)
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
@@ -2123,26 +2378,28 @@ static void sca_intr(pc300_t * card)
 								    			card->hw.cpld_reg2) &
 								   ~ (CPLD_REG2_FALC_LED1 << (2 * ch)));
 						}
-						sca_tx_intr(d);
 					}
+					sca_tx_intr(d);
 				}
 			}
 
 	    /**** MSCI ****/
 			if (status & IR0_M(IR0_RXINTA, ch)) {
-				u8 st1 = cpc_readb(scabase + M_REG(ST1, ch));
+				u8 st1 =
+					cpc_readb(scabase + M_REG(ST1, ch));
 
 				/* Clear MSCI interrupts */
 				cpc_writeb(scabase + M_REG(ST1, ch), st1);
 
 #ifdef PC300_DEBUG_INTR
-				printk("sca_intr: MSCI intr chan[%d] (st=0x%08lx, st1=0x%02x)\n",
-					 ch, status, st1);
+				printk(KERN_DEBUG "sca_intr: MSCI intr chan[%d] (st=0x%08x, st1=0x%02x)\n",
+				       ch, status, st1);
 #endif
 				if (st1 & ST1_CDCD) {	/* DCD changed */
 					if (cpc_readb(scabase + M_REG(ST3, ch)) & ST3_DCD) {
-						printk ("%s: DCD is OFF. Going administrative down.\n",
-							 dev->name);
+						printk(KERN_INFO
+								"%s: DCD is OFF. Going administrative down.\n",
+								dev->name);
 #ifdef CONFIG_PC300_MLPPP
 						if (chan->conf.proto != PC300_PROTO_MLPPP) {
 							netif_carrier_off(dev);
@@ -2153,8 +2410,9 @@ static void sca_intr(pc300_t * card)
 #endif
 						card->chan[ch].d.line_off++;
 					} else {	/* DCD = 1 */
-						printk ("%s: DCD is ON. Going administrative up.\n",
-							 dev->name);
+						printk(KERN_INFO
+								"%s: DCD is ON. Going administrative up.\n",
+								dev->name);
 #ifdef CONFIG_PC300_MLPPP
 						if (chan->conf.proto != PC300_PROTO_MLPPP)
 							/* verify if driver is not TTY */
@@ -2176,7 +2434,7 @@ static void falc_t1_loop_detection(pc300_t *card, int ch, u8 frs1)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (((cpc_readb(falcbase + F_REG(LCR1, ch)) & LCR1_XPRBS) == 0) &&
 	    !pfalc->loop_gen) {
@@ -2201,7 +2459,7 @@ static void falc_e1_loop_detection(pc300_t *card, int ch, u8 rsp)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 
 	if (((cpc_readb(falcbase + F_REG(LCR1, ch)) & LCR1_XPRBS) == 0) &&
 	    !pfalc->loop_gen) {
@@ -2222,11 +2480,11 @@ static void falc_e1_loop_detection(pc300_t *card, int ch, u8 rsp)
 	}
 }
 
-static void falc_t1_intr(pc300_t * card, int ch)
+static void falc_t1_intr(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 isr0, isr3, gis;
 	u8 dummy;
 
@@ -2269,11 +2527,11 @@ static void falc_t1_intr(pc300_t * card, int ch)
 	}
 }
 
-static void falc_e1_intr(pc300_t * card, int ch)
+static void falc_e1_intr(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
-	void __iomem *falcbase = card->hw.falcbase;
+	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 isr1, isr2, isr3, gis, rsp;
 	u8 dummy;
 
@@ -2286,8 +2544,8 @@ static void falc_e1_intr(pc300_t * card, int ch)
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
@@ -2338,7 +2596,7 @@ static void falc_e1_intr(pc300_t * card, int ch)
 	}
 }
 
-static void falc_intr(pc300_t * card)
+static void falc_intr(pc300_t *card)
 {
 	int ch;
 
@@ -2356,19 +2614,24 @@ static void falc_intr(pc300_t * card)
 
 static irqreturn_t cpc_intr(int irq, void *dev_id)
 {
-	pc300_t *card = dev_id;
-	volatile u8 plx_status;
+	pc300_t *card;
+	u8 plx_status;
 
-	if (!card) {
+	card = (pc300_t *)dev_id;
+	if (card == 0) {
 #ifdef PC300_DEBUG_INTR
-		printk("cpc_intr: spurious intr %d\n", irq);
+		printk(KERN_DEBUG
+				"cpc_intr: spurious intr %d\n",
+				irq);
 #endif
 		return IRQ_NONE;		/* spurious intr */
 	}
 
-	if (!card->hw.rambase) {
+	if (card->hw.rambase == 0) {
 #ifdef PC300_DEBUG_INTR
-		printk("cpc_intr: spurious intr2 %d\n", irq);
+		printk(KERN_DEBUG
+				"cpc_intr: spurious intr2 %d\n",
+				irq);
 #endif
 		return IRQ_NONE;		/* spurious intr */
 	}
@@ -2394,89 +2657,137 @@ static irqreturn_t cpc_intr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static void cpc_sca_status(pc300_t * card, int ch)
+static void cpc_sca_status(pc300_t *card, int ch)
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
-	printk ("ILAR=0x%02x, WCRL=0x%02x, PCR=0x%02x, BTCR=0x%02x, BOLR=0x%02x\n",
-		 ilar, cpc_readb(scabase + WCRL), cpc_readb(scabase + PCR),
-		 cpc_readb(scabase + BTCR), cpc_readb(scabase + BOLR));
-	printk("TX_CDA=0x%08x, TX_EDA=0x%08x\n",
-	       cpc_readl(scabase + DTX_REG(CDAL, ch)),
-	       cpc_readl(scabase + DTX_REG(EDAL, ch)));
-	printk("RX_CDA=0x%08x, RX_EDA=0x%08x, BFL=0x%04x\n",
-	       cpc_readl(scabase + DRX_REG(CDAL, ch)),
-	       cpc_readl(scabase + DRX_REG(EDAL, ch)),
-	       cpc_readw(scabase + DRX_REG(BFLL, ch)));
-	printk("DMER=0x%02x, DSR_TX=0x%02x, DSR_RX=0x%02x\n",
-	       cpc_readb(scabase + DMER), cpc_readb(scabase + DSR_TX(ch)),
-	       cpc_readb(scabase + DSR_RX(ch)));
-	printk("DMR_TX=0x%02x, DMR_RX=0x%02x, DIR_TX=0x%02x, DIR_RX=0x%02x\n",
-	       cpc_readb(scabase + DMR_TX(ch)), cpc_readb(scabase + DMR_RX(ch)),
-	       cpc_readb(scabase + DIR_TX(ch)),
-	       cpc_readb(scabase + DIR_RX(ch)));
-	printk("DCR_TX=0x%02x, DCR_RX=0x%02x, FCT_TX=0x%02x, FCT_RX=0x%02x\n",
-	       cpc_readb(scabase + DCR_TX(ch)), cpc_readb(scabase + DCR_RX(ch)),
-	       cpc_readb(scabase + FCT_TX(ch)),
-	       cpc_readb(scabase + FCT_RX(ch)));
-	printk("MD0=0x%02x, MD1=0x%02x, MD2=0x%02x, MD3=0x%02x, IDL=0x%02x\n",
-	       cpc_readb(scabase + M_REG(MD0, ch)),
-	       cpc_readb(scabase + M_REG(MD1, ch)),
-	       cpc_readb(scabase + M_REG(MD2, ch)),
-	       cpc_readb(scabase + M_REG(MD3, ch)),
-	       cpc_readb(scabase + M_REG(IDL, ch)));
-	printk("CMD=0x%02x, SA0=0x%02x, SA1=0x%02x, TFN=0x%02x, CTL=0x%02x\n",
-	       cpc_readb(scabase + M_REG(CMD, ch)),
-	       cpc_readb(scabase + M_REG(SA0, ch)),
-	       cpc_readb(scabase + M_REG(SA1, ch)),
-	       cpc_readb(scabase + M_REG(TFN, ch)),
-	       cpc_readb(scabase + M_REG(CTL, ch)));
-	printk("ST0=0x%02x, ST1=0x%02x, ST2=0x%02x, ST3=0x%02x, ST4=0x%02x\n",
-	       cpc_readb(scabase + M_REG(ST0, ch)),
-	       cpc_readb(scabase + M_REG(ST1, ch)),
-	       cpc_readb(scabase + M_REG(ST2, ch)),
-	       cpc_readb(scabase + M_REG(ST3, ch)),
-	       cpc_readb(scabase + M_REG(ST4, ch)));
-	printk ("CST0=0x%02x, CST1=0x%02x, CST2=0x%02x, CST3=0x%02x, FST=0x%02x\n",
-		 cpc_readb(scabase + M_REG(CST0, ch)),
-		 cpc_readb(scabase + M_REG(CST1, ch)),
-		 cpc_readb(scabase + M_REG(CST2, ch)),
-		 cpc_readb(scabase + M_REG(CST3, ch)),
-		 cpc_readb(scabase + M_REG(FST, ch)));
-	printk("TRC0=0x%02x, TRC1=0x%02x, RRC=0x%02x, TBN=0x%02x, RBN=0x%02x\n",
-	       cpc_readb(scabase + M_REG(TRC0, ch)),
-	       cpc_readb(scabase + M_REG(TRC1, ch)),
-	       cpc_readb(scabase + M_REG(RRC, ch)),
-	       cpc_readb(scabase + M_REG(TBN, ch)),
-	       cpc_readb(scabase + M_REG(RBN, ch)));
-	printk("TFS=0x%02x, TNR0=0x%02x, TNR1=0x%02x, RNR=0x%02x\n",
-	       cpc_readb(scabase + M_REG(TFS, ch)),
-	       cpc_readb(scabase + M_REG(TNR0, ch)),
-	       cpc_readb(scabase + M_REG(TNR1, ch)),
-	       cpc_readb(scabase + M_REG(RNR, ch)));
-	printk("TCR=0x%02x, RCR=0x%02x, TNR1=0x%02x, RNR=0x%02x\n",
-	       cpc_readb(scabase + M_REG(TCR, ch)),
-	       cpc_readb(scabase + M_REG(RCR, ch)),
-	       cpc_readb(scabase + M_REG(TNR1, ch)),
-	       cpc_readb(scabase + M_REG(RNR, ch)));
-	printk("TXS=0x%02x, RXS=0x%02x, EXS=0x%02x, TMCT=0x%02x, TMCR=0x%02x\n",
-	       cpc_readb(scabase + M_REG(TXS, ch)),
-	       cpc_readb(scabase + M_REG(RXS, ch)),
-	       cpc_readb(scabase + M_REG(EXS, ch)),
-	       cpc_readb(scabase + M_REG(TMCT, ch)),
-	       cpc_readb(scabase + M_REG(TMCR, ch)));
-	printk("IE0=0x%02x, IE1=0x%02x, IE2=0x%02x, IE4=0x%02x, FIE=0x%02x\n",
-	       cpc_readb(scabase + M_REG(IE0, ch)),
-	       cpc_readb(scabase + M_REG(IE1, ch)),
-	       cpc_readb(scabase + M_REG(IE2, ch)),
-	       cpc_readb(scabase + M_REG(IE4, ch)),
-	       cpc_readb(scabase + M_REG(FIE, ch)));
-	printk("IER0=0x%08x\n", cpc_readl(scabase + IER0));
+	printk(KERN_DEBUG
+			"ILAR=0x%02x, WCRL=0x%02x, PCR=0x%02x, "
+			"BTCR=0x%02x, BOLR=0x%02x\n",
+			ilar, cpc_readb(scabase + WCRL),
+			cpc_readb(scabase + PCR),
+			cpc_readb(scabase + BTCR),
+			cpc_readb(scabase + BOLR));
+	printk(KERN_DEBUG
+			"TX_CDA=0x%08x, TX_EDA=0x%08x\n",
+			(u32) cpc_readl(scabase + DTX_REG(CDAL, ch)),
+			(u32) cpc_readl(scabase + DTX_REG(EDAL, ch)));
+	printk(KERN_DEBUG
+			"RX_CDA=0x%08x, RX_EDA=0x%08x, BFL=0x%04x\n",
+			(u32) cpc_readl(scabase + DRX_REG(CDAL, ch)),
+			(u32) cpc_readl(scabase + DRX_REG(EDAL, ch)),
+			cpc_readw(scabase + DRX_REG(BFLL, ch)));
+	printk(KERN_DEBUG
+			"DMER=0x%02x, DSR_TX=0x%02x, DSR_RX=0x%02x\n",
+			cpc_readb(scabase + DMER),
+			cpc_readb(scabase + DSR_TX(ch)),
+			cpc_readb(scabase + DSR_RX(ch)));
+	printk(KERN_DEBUG
+			"DMR_TX=0x%02x, DMR_RX=0x%02x, DIR_TX=0x%02x, DIR_RX=0x%02x\n",
+			cpc_readb(scabase + DMR_TX(ch)),
+			cpc_readb(scabase + DMR_RX(ch)),
+			cpc_readb(scabase + DIR_TX(ch)),
+			cpc_readb(scabase + DIR_RX(ch)));
+	printk(KERN_DEBUG
+			"DCR_TX=0x%02x, DCR_RX=0x%02x, FCT_TX=0x%02x, FCT_RX=0x%02x\n",
+			cpc_readb(scabase + DCR_TX(ch)),
+			cpc_readb(scabase + DCR_RX(ch)),
+			cpc_readb(scabase + FCT_TX(ch)),
+			cpc_readb(scabase + FCT_RX(ch)));
+	printk(KERN_DEBUG
+			"MD0=0x%02x, MD1=0x%02x, MD2=0x%02x, MD3=0x%02x, IDL=0x%02x\n",
+			cpc_readb(scabase + M_REG(MD0, ch)),
+			cpc_readb(scabase + M_REG(MD1, ch)),
+			cpc_readb(scabase + M_REG(MD2, ch)),
+			cpc_readb(scabase + M_REG(MD3, ch)),
+			cpc_readb(scabase + M_REG(IDL, ch)));
+	printk(KERN_DEBUG
+			"CMD=0x%02x, SA0=0x%02x, SA1=0x%02x, TFN=0x%02x, CTL=0x%02x\n",
+			cpc_readb(scabase + M_REG(CMD, ch)),
+			cpc_readb(scabase + M_REG(SA0, ch)),
+			cpc_readb(scabase + M_REG(SA1, ch)),
+			cpc_readb(scabase + M_REG(TFN, ch)),
+			cpc_readb(scabase + M_REG(CTL, ch)));
+	printk(KERN_DEBUG
+			"ST0=0x%02x, ST1=0x%02x, ST2=0x%02x, ST3=0x%02x, ST4=0x%02x\n",
+			cpc_readb(scabase + M_REG(ST0, ch)),
+			cpc_readb(scabase + M_REG(ST1, ch)),
+			cpc_readb(scabase + M_REG(ST2, ch)),
+			cpc_readb(scabase + M_REG(ST3, ch)),
+			cpc_readb(scabase + M_REG(ST4, ch)));
+	printk(KERN_DEBUG
+			"CST0=0x%02x, CST1=0x%02x, CST2=0x%02x, CST3=0x%02x, FST=0x%02x\n",
+			cpc_readb(scabase + M_REG(CST0, ch)),
+			cpc_readb(scabase + M_REG(CST1, ch)),
+			cpc_readb(scabase + M_REG(CST2, ch)),
+			cpc_readb(scabase + M_REG(CST3, ch)),
+			cpc_readb(scabase + M_REG(FST, ch)));
+	printk(KERN_DEBUG
+			"TRC0=0x%02x, TRC1=0x%02x, RRC=0x%02x, TBN=0x%02x, RBN=0x%02x\n",
+			cpc_readb(scabase + M_REG(TRC0, ch)),
+			cpc_readb(scabase + M_REG(TRC1, ch)),
+			cpc_readb(scabase + M_REG(RRC, ch)),
+			cpc_readb(scabase + M_REG(TBN, ch)),
+			cpc_readb(scabase + M_REG(RBN, ch)));
+	printk(KERN_DEBUG
+			"TFS=0x%02x, TNR0=0x%02x, TNR1=0x%02x, RNR=0x%02x\n",
+			cpc_readb(scabase + M_REG(TFS, ch)),
+			cpc_readb(scabase + M_REG(TNR0, ch)),
+			cpc_readb(scabase + M_REG(TNR1, ch)),
+			cpc_readb(scabase + M_REG(RNR, ch)));
+	printk(KERN_DEBUG
+			"TCR=0x%02x, RCR=0x%02x, TNR1=0x%02x, RNR=0x%02x\n",
+			cpc_readb(scabase + M_REG(TCR, ch)),
+			cpc_readb(scabase + M_REG(RCR, ch)),
+			cpc_readb(scabase + M_REG(TNR1, ch)),
+			cpc_readb(scabase + M_REG(RNR, ch)));
+	printk(KERN_DEBUG
+			"TXS=0x%02x, RXS=0x%02x, EXS=0x%02x, TMCT=0x%02x, TMCR=0x%02x\n",
+			cpc_readb(scabase + M_REG(TXS, ch)),
+			cpc_readb(scabase + M_REG(RXS, ch)),
+			cpc_readb(scabase + M_REG(EXS, ch)),
+			cpc_readb(scabase + M_REG(TMCT, ch)),
+			cpc_readb(scabase + M_REG(TMCR, ch)));
+	printk(KERN_DEBUG
+			"IE0=0x%02x, IE1=0x%02x, IE2=0x%02x, IE4=0x%02x, FIE=0x%02x\n",
+			cpc_readb(scabase + M_REG(IE0, ch)),
+			cpc_readb(scabase + M_REG(IE1, ch)),
+			cpc_readb(scabase + M_REG(IE2, ch)),
+			cpc_readb(scabase + M_REG(IE4, ch)),
+			cpc_readb(scabase + M_REG(FIE, ch)));
+	printk(KERN_DEBUG
+			"IER0=0x%08x\n",
+			(u32) cpc_readl(scabase + IER0));
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
@@ -2486,73 +2797,157 @@ static void cpc_sca_status(pc300_t * card, int ch)
 	}
 }
 
-static void cpc_falc_status(pc300_t * card, int ch)
+static void cpc_falc_status(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = &card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
 	unsigned long flags;
 
 	CPC_LOCK(card, flags);
-	printk("CH%d:   %s %s  %d channels\n",
-	       ch, (pfalc->sync ? "SYNC" : ""), (pfalc->active ? "ACTIVE" : ""),
-	       pfalc->num_channels);
-
-	printk("        pden=%d,  los=%d,  losr=%d,  lfa=%d,  farec=%d\n",
-	       pfalc->pden, pfalc->los, pfalc->losr, pfalc->lfa, pfalc->farec);
-	printk("        lmfa=%d,  ais=%d,  sec=%d,  es=%d,  rai=%d\n",
-	       pfalc->lmfa, pfalc->ais, pfalc->sec, pfalc->es, pfalc->rai);
-	printk("        bec=%d,  fec=%d,  cvc=%d,  cec=%d,  ebc=%d\n",
-	       pfalc->bec, pfalc->fec, pfalc->cvc, pfalc->cec, pfalc->ebc);
-
-	printk("\n");
-	printk("        STATUS: %s  %s  %s  %s  %s  %s\n",
-	       (pfalc->red_alarm ? "RED" : ""),
-	       (pfalc->blue_alarm ? "BLU" : ""),
-	       (pfalc->yellow_alarm ? "YEL" : ""),
-	       (pfalc->loss_fa ? "LFA" : ""),
-	       (pfalc->loss_mfa ? "LMF" : ""), (pfalc->prbs ? "PRB" : ""));
+	printk(KERN_DEBUG
+			"CH%d:   %s %s  %d channels\n",
+			ch,
+			(pfalc->sync ? "SYNC" : ""),
+			(pfalc->active ? "ACTIVE" : ""),
+			pfalc->num_channels);
+
+	printk(KERN_DEBUG
+			"        pden=%d,  los=%d,  losr=%d,  lfa=%d,  farec=%d\n",
+			pfalc->pden, pfalc->los,
+			pfalc->losr, pfalc->lfa,
+			pfalc->farec);
+	printk(KERN_DEBUG
+			"        lmfa=%d,  ais=%d,  sec=%d,  es=%d,  rai=%d\n",
+			pfalc->lmfa, pfalc->ais,
+			pfalc->sec, pfalc->es,
+			pfalc->rai);
+	printk(KERN_DEBUG
+			"        bec=%d,  fec=%d,  cvc=%d,  cec=%d,  ebc=%d\n",
+			pfalc->bec, pfalc->fec,
+			pfalc->cvc, pfalc->cec,
+			pfalc->ebc);
+
+	printk(KERN_DEBUG "\n");
+	printk(KERN_DEBUG
+			"        STATUS: %s  %s  %s  %s  %s  %s\n",
+			(pfalc->red_alarm ? "RED" : ""),
+			(pfalc->blue_alarm ? "BLU" : ""),
+			(pfalc->yellow_alarm ? "YEL" : ""),
+			(pfalc->loss_fa ? "LFA" : ""),
+			(pfalc->loss_mfa ? "LMF" : ""),
+			(pfalc->prbs ? "PRB" : ""));
 	CPC_UNLOCK(card, flags);
 }
 
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
-				conf->proto = /* FIXME hdlc->proto.id */ 0;
+				conf->proto = 0;
 			}
 #else
-			conf->proto = /* FIXME hdlc->proto.id */ 0;
+			conf->proto = 0;
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
@@ -2577,12 +2972,15 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 					}
 				} else {
 					memcpy(conf, &conf_aux.conf, sizeof(pc300chconf_t));
-					/* FIXME hdlc->proto.id = conf->proto; */
 				}
 			}
 #else
 			memcpy(conf, &conf_aux.conf, sizeof(pc300chconf_t));
-			/* FIXME hdlc->proto.id = conf->proto; */
+#endif
+#ifdef PC300_DEBUG_OTHER
+			printk(KERN_DEBUG
+			       "%s: SIOCSPC300CONF returning, with conf->monitor = %d\n",
+			       dev->name, conf->monitor);
 #endif
 			return 0;
 		case SIOCGPC300STATUS:
@@ -2593,28 +2991,45 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return 0;
 
 		case SIOCGPC300UTILSTATS:
-			{
-				if (!arg) {	/* clear statistics */
-					memset(&dev->stats, 0, sizeof(dev->stats));
-					if (card->hw.type == PC300_TE) {
-						memset(&chan->falc, 0, sizeof(falc_t));
-					}
-				} else {
-					pc300stats_t pc300stats;
-
-					memset(&pc300stats, 0, sizeof(pc300stats_t));
-					pc300stats.hw_type = card->hw.type;
-					pc300stats.line_on = card->chan[ch].d.line_on;
-					pc300stats.line_off = card->chan[ch].d.line_off;
-					memcpy(&pc300stats.gen_stats, &dev->stats,
-					       sizeof(dev->stats));
-					if (card->hw.type == PC300_TE)
-						memcpy(&pc300stats.te_stats,&chan->falc,sizeof(falc_t));
-				    	if (copy_to_user(arg, &pc300stats, sizeof(pc300stats_t)))
-						return -EFAULT;
+			if (!arg) {	/* clear statistics */
+				memset(&dev->stats, 0,
+						sizeof(dev->stats));
+				if (card->hw.type == PC300_TE) {
+					memset(&chan->falc, 0,
+							sizeof(falc_t));
+				}
+			} else {
+				pc300stats_t pc300stats;
+
+				memset(&pc300stats, 0,
+						sizeof(pc300stats_t));
+				pc300stats.hw_type = card->hw.type;
+				pc300stats.line_on = card->chan[ch].d.line_on;
+				pc300stats.line_off = card->chan[ch].d.line_off;
+				/*
+				 * Do this instead of passing dev->stats
+				 * out so 32-bit userland on 64-bit
+				 * kernel works.
+				 */
+				cpc_net_stats_to_user(
+						&(dev->stats),
+						&(pc300stats.net_stats));
+				if (card->hw.type == PC300_TE) {
+					memcpy(&pc300stats.te_stats,
+							&chan->falc,
+							sizeof(falc_t));
+				}
+				if (
+						copy_to_user(
+							arg,
+							&pc300stats,
+							sizeof(pc300stats_t)
+							)
+						) {
+					return -EFAULT;
 				}
-				return 0;
 			}
+			return 0;
 
 		case SIOCGPC300UTILSTATUS:
 			{
@@ -2622,27 +3037,52 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 				pc300status.hw_type = card->hw.type;
 				if (card->hw.type == PC300_TE) {
-					pc300status.te_status.sync = chan->falc.sync;
-					pc300status.te_status.red_alarm = chan->falc.red_alarm;
-					pc300status.te_status.blue_alarm = chan->falc.blue_alarm;
-					pc300status.te_status.loss_fa = chan->falc.loss_fa;
-					pc300status.te_status.yellow_alarm =chan->falc.yellow_alarm;
-					pc300status.te_status.loss_mfa = chan->falc.loss_mfa;
-					pc300status.te_status.prbs = chan->falc.prbs;
+					pc300status.te_status.sync =
+						chan->falc.sync;
+					pc300status.te_status.red_alarm =
+						chan->falc.red_alarm;
+					pc300status.te_status.blue_alarm =
+						chan->falc.blue_alarm;
+					pc300status.te_status.loss_fa =
+						chan->falc.loss_fa;
+					pc300status.te_status.yellow_alarm =
+						chan->falc.yellow_alarm;
+					pc300status.te_status.loss_mfa =
+						chan->falc.loss_mfa;
+					pc300status.te_status.prbs =
+						chan->falc.prbs;
 				} else {
 					pc300status.gen_status.dcd =
-						!(cpc_readb (scabase + M_REG(ST3, ch)) & ST3_DCD);
+						!(cpc_readb(
+							scabase +
+							M_REG(ST3, ch)) &
+						ST3_DCD);
 					pc300status.gen_status.cts =
-						!(cpc_readb (scabase + M_REG(ST3, ch)) & ST3_CTS);
+						!(cpc_readb(
+							scabase +
+							M_REG(ST3, ch)) &
+						ST3_CTS);
 					pc300status.gen_status.rts =
-						!(cpc_readb (scabase + M_REG(CTL, ch)) & CTL_RTS);
+						!(cpc_readb(
+							scabase +
+							M_REG(CTL, ch)) &
+						CTL_RTS);
 					pc300status.gen_status.dtr =
-						!(cpc_readb (scabase + M_REG(CTL, ch)) & CTL_DTR);
+						!(cpc_readb(
+							scabase +
+							M_REG(CTL, ch)) &
+						CTL_DTR);
 					/* There is no DSR in HD64572 */
 				}
 				if (!arg ||
-				    copy_to_user(arg, &pc300status, sizeof(pc300status_t)))
+						copy_to_user(
+							arg,
+							&pc300status,
+							sizeof(pc300status_t)
+							)
+						) {
 					return -EINVAL;
+				}
 				return 0;
 			}
 
@@ -2661,8 +3101,11 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 					return -EINVAL;
 
 				if (!arg || 
-					copy_from_user(&pc300loop, arg, sizeof(pc300loopback_t)))
+					copy_from_user(&pc300loop,
+						arg,
+						sizeof(pc300loopback_t))) {
 						return -EINVAL;
+				}
 				switch (pc300loop.loop_type) {
 					case PC300LOCLOOP:	/* Turn the local loop on/off */
 						falc_local_loop(card, ch, pc300loop.loop_on);
@@ -2712,19 +3155,39 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 				}
 
 				if (!arg || 
-					copy_from_user(&pc300patrntst,arg,sizeof(pc300patterntst_t)))
+						copy_from_user(
+							&pc300patrntst,
+							arg,
+							sizeof(
+								pc300patrntst
+								)
+							)
+						) {
 						return -EINVAL;
+				}
 				if (pc300patrntst.patrntst_on == 2) {
 					if (chan->falc.prbs == 0) {
 						falc_pattern_test(card, ch, 1);
 					}
 					pc300patrntst.num_errors =
 						falc_pattern_test_error(card, ch);
-					if (copy_to_user(arg, &pc300patrntst,
-							 sizeof(pc300patterntst_t)))
-							return -EINVAL;
+					if (!arg ||
+						copy_to_user(
+							arg,
+							&pc300patrntst,
+							sizeof(
+								pc300patrntst
+								)
+							)) {
+						return -EINVAL;
+					}
 				} else {
-					falc_pattern_test(card, ch, pc300patrntst.patrntst_on);
+					falc_pattern_test(
+						card,
+						ch,
+						pc300patrntst.
+							patrntst_on
+						);
 				}
 				return 0;
 			}
@@ -2813,6 +3276,16 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
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
@@ -2842,13 +3315,13 @@ static int clock_rate_calc(u32 rate, u32 clock, int *br_io)
 	}
 }
 
-static int ch_config(pc300dev_t * d)
+static int ch_config(pc300dev_t *d)
 {
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
@@ -2987,17 +3460,19 @@ static int ch_config(pc300dev_t * d)
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
 
-static int rx_config(pc300dev_t * d)
+static int rx_config(pc300dev_t *d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	int ch = chan->channel;
 
 	cpc_writeb(scabase + DSR_RX(ch), 0);
@@ -3024,11 +3499,11 @@ static int rx_config(pc300dev_t * d)
 	return 0;
 }
 
-static int tx_config(pc300dev_t * d)
+static int tx_config(pc300dev_t *d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	int ch = chan->channel;
 
 	cpc_writeb(scabase + DSR_TX(ch), 0);
@@ -3056,9 +3531,11 @@ static int tx_config(pc300dev_t * d)
 	return 0;
 }
 
-static int cpc_attach(struct net_device *dev, unsigned short encoding,
-		      unsigned short parity)
-{
+static int cpc_attach(
+		struct net_device *dev,
+		unsigned short encoding,
+		unsigned short parity
+		) {
 	pc300dev_t *d = (pc300dev_t *)dev_to_hdlc(dev)->priv;
 	pc300ch_t *chan = (pc300ch_t *)d->chan;
 	pc300_t *card = (pc300_t *)chan->card;
@@ -3087,12 +3564,12 @@ static int cpc_attach(struct net_device *dev, unsigned short encoding,
 	return 0;
 }
 
-static int cpc_opench(pc300dev_t * d)
+static int cpc_opench(pc300dev_t *d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
 	int ch = chan->channel, rc;
-	void __iomem *scabase = card->hw.scabase;
+	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 
 	rc = ch_config(d);
 	if (rc)
@@ -3109,7 +3586,7 @@ static int cpc_opench(pc300dev_t * d)
 	return 0;
 }
 
-static void cpc_closech(pc300dev_t * d)
+static void cpc_closech(pc300dev_t *d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
@@ -3144,11 +3621,10 @@ int cpc_open(struct net_device *dev)
 	int result;
 
 #ifdef	PC300_DEBUG_OTHER
-	printk("pc300: cpc_open");
+	printk(KERN_DEBUG "pc300: cpc_open\n");
 #endif
 
 	result = hdlc_open(dev);
-
 	if (result)
 		return result;
 
@@ -3157,6 +3633,9 @@ int cpc_open(struct net_device *dev)
 	if (result)
 		goto err_out;
 
+#ifdef PC300_DEBUG_QUEUE
+	printk(KERN_DEBUG "%s: starting queue for open\n", dev->name);
+#endif
 	netif_start_queue(dev);
 	return 0;
 
@@ -3173,9 +3652,13 @@ static int cpc_close(struct net_device *dev)
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
@@ -3183,7 +3666,6 @@ static int cpc_close(struct net_device *dev)
 	CPC_UNLOCK(card, flags);
 
 	hdlc_close(dev);
-
 #ifdef CONFIG_PC300_MLPPP
 	if (chan->conf.proto == PC300_PROTO_MLPPP) {
 		cpc_tty_unregister_service(d);
@@ -3194,11 +3676,11 @@ static int cpc_close(struct net_device *dev)
 	return 0;
 }
 
-static u32 detect_ram(pc300_t * card)
+static u32 detect_ram(pc300_t *card)
 {
 	u32 i;
 	u8 data;
-	void __iomem *rambase = card->hw.rambase;
+	uintptr_t rambase = (uintptr_t)(card->hw.rambase);
 
 	card->hw.ramsize = PC300_RAMSIZE;
 	/* Let's find out how much RAM is present on this board */
@@ -3212,9 +3694,10 @@ static u32 detect_ram(pc300_t * card)
 	return i;
 }
 
-static void plx_init(pc300_t * card)
+static void plx_init(pc300_t *card)
 {
-	struct RUNTIME_9050 __iomem *plx_ctl = card->hw.plxbase;
+	struct RUNTIME_9050 __iomem *plx_ctl =
+		(struct RUNTIME_9050 __iomem *) card->hw.plxbase;
 
 	/* Reset PLX */
 	cpc_writel(&plx_ctl->init_ctrl,
@@ -3244,20 +3727,11 @@ static inline void show_version(void)
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
-static void cpc_init_card(pc300_t * card)
+static void cpc_init_card(pc300_t *card)
 {
 	int i, devcount = 0;
 	static int board_nbr = 1;
@@ -3346,6 +3820,7 @@ static void cpc_init_card(pc300_t * card)
 				break;
 		}
 		chan->conf.proto = IF_PROTO_PPP;
+		chan->conf.monitor = 0;
 		chan->tx_first_bd = 0;
 		chan->tx_next_bd = 0;
 		chan->rx_first_bd = 0;
@@ -3353,6 +3828,7 @@ static void cpc_init_card(pc300_t * card)
 		chan->nfree_tx_bd = N_DMA_TX_BUF;
 
 		d->chan = chan;
+		d->tx_skb = NULL;
 		d->trace_on = 0;
 		d->line_on = 0;
 		d->line_off = 0;
@@ -3361,47 +3837,67 @@ static void cpc_init_card(pc300_t * card)
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
-			printk("%s: Cyclades-PC300/", dev->name);
+			printk(KERN_INFO
+					"%s: Cyclades-PC300/",
+					dev->name);
 			switch (card->hw.type) {
 				case PC300_TE:
 					if (card->hw.bus == PC300_PMC) {
-						printk("TE-M");
+						printk(KERN_INFO "TE-M");
 					} else {
-						printk("TE  ");
+						printk(KERN_INFO "TE  ");
 					}
 					break;
 
 				case PC300_X21:
-					printk("X21 ");
+					printk(KERN_INFO "X21 ");
 					break;
 
 				case PC300_RSV:
 				default:
-					printk("RSV ");
+					printk(KERN_INFO "RSV ");
 					break;
 			}
-			printk (" #%d, %dKB of RAM at 0x%08x, IRQ%d, channel %d.\n",
-				 board_nbr, card->hw.ramsize / 1024,
-				 card->hw.ramphys, card->hw.irq, i + 1);
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+			printk(KERN_INFO " #%d, %dKB of RAM at 0x%016lx, IRQ %d, channel %d.\n",
+			       board_nbr, card->hw.ramsize / 1024,
+			       (unsigned long)(card->hw.ramphys),
+			       card->hw.irq, i + 1);
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+			printk(KERN_INFO " #%d, %dKB of RAM at 0x%08x, IRQ %d, channel %d.\n",
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
+			printk(KERN_ERR "Dev %d on card(0x%016lx): unable to allocate i/f name.\n",
+			       i + 1, (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+			printk(KERN_ERR "Dev %d on card(0x%08x): unable to allocate i/f name.\n",
+			       i + 1, (unsigned int)(card->hw.ramphys));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
+			*(dev->name) = 0;
+			kfree(d->hdlc);
 			continue;
 		}
 	}
@@ -3414,7 +3910,10 @@ static int __devinit
 cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int first_time = 1;
-	int err, eeprom_outdated = 0;
+#ifdef PC300_DEBUG_PCI
+	u8 cpc_rev_id;
+#endif
+	int err = 0, eeprom_outdated = 0;
 	u16 device_id;
 	pc300_t *card;
 
@@ -3426,20 +3925,18 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
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
+		printk(KERN_ERR "PC300 found at RAM 0x%016lx, but could not allocate card structure.\n",
+		       (unsigned long)(pci_resource_start(pdev, 3)));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR "PC300 found at RAM 0x%08x, but could not allocate card structure.\n",
+		       (unsigned int)(pci_resource_start(pdev, 3)));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
+		return -ENOMEM;
 	}
 
-	err = -ENODEV;
-
 	/* read PCI configuration area */
 	device_id = ent->device;
 	card->hw.irq = pdev->irq;
@@ -3453,6 +3950,9 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	card->hw.falcsize = pci_resource_len(pdev, 4);
 	card->hw.plxphys = pci_resource_start(pdev, 5);
 	card->hw.plxsize = pci_resource_len(pdev, 5);
+#ifdef PC300_DEBUG_PCI
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &cpc_rev_id);
+#endif
 
 	switch (device_id) {
 		case PCI_DEVICE_ID_PC300_RX_1:
@@ -3469,20 +3969,46 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			break;
 	}
 #ifdef PC300_DEBUG_PCI
-	printk("cpc (bus=0x0%x,pci_id=0x%x,", pdev->bus->number, pdev->devfn);
-	printk("rev_id=%d) IRQ%d\n", pdev->revision, card->hw.irq);
-	printk("cpc:found  ramaddr=0x%08lx plxaddr=0x%08lx "
-	       "ctladdr=0x%08lx falcaddr=0x%08lx\n",
-	       card->hw.ramphys, card->hw.plxphys, card->hw.scaphys,
-	       card->hw.falcphys);
+	printk(KERN_DEBUG
+			"cpc (bus=0x0%x,pci_id=0x%x,",
+			pdev->bus->number, pdev->devfn);
+	printk(KERN_DEBUG
+			"rev_id=%d) IRQ%d\n",
+			pdev->revision, card->hw.irq);
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
-		printk("WARNING: couldn't allocate I/O region for PC300 board "
-		       "at 0x%08x!\n", card->hw.ramphys);
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk(KERN_ERR
+				"WARNING: couldn't allocate I/O region for PC300 board "
+				"at 0x%016lx!\n",
+				(unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR
+				"WARNING: couldn't allocate I/O region for PC300 board "
+				"at 0x%08x!\n",
+				(unsigned int)(card->hw.ramphys));
+#endif
 	}
 
 	if (card->hw.plxphys) {
@@ -3495,29 +4021,63 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	if (!request_mem_region(card->hw.plxphys, card->hw.plxsize,
 				"PLX Registers")) {
-		printk("PC300 found at RAM 0x%08x, "
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%016lx, "
+		       "but could not allocate PLX mem region.\n",
+		       (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%08x, "
 		       "but could not allocate PLX mem region.\n",
-		       card->hw.ramphys);
+		       (unsigned int)(card->hw.ramphys));
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
+		err = -ENODEV;
 		goto err_release_io;
 	}
 	if (!request_mem_region(card->hw.ramphys, card->hw.alloc_ramsize,
 				"On-board RAM")) {
-		printk("PC300 found at RAM 0x%08x, "
-		       "but could not allocate RAM mem region.\n",
-		       card->hw.ramphys);
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk(KERN_ERR
+				"PC300 found at RAM 0x%016lx, "
+				"but could not allocate SCA mem region.\n",
+				(unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR
+				"PC300 found at RAM 0x%08x, "
+				"but could not allocate RAM mem region.\n",
+				(unsigned int)(card->hw.ramphys));
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
 		       "but could not allocate SCA mem region.\n",
-		       card->hw.ramphys);
+		       (unsigned long)(card->hw.ramphys));
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR
+		       "PC300 found at RAM 0x%08x, "
+		       "but could not allocate SCA mem region.\n",
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
+		(void __iomem *) ioremap(card->hw.plxphys, card->hw.plxsize);
+	card->hw.rambase = (void __iomem *) ioremap(card->hw.ramphys,
+					    card->hw.alloc_ramsize);
+	card->hw.scabase =
+		(void __iomem *) ioremap(card->hw.scaphys, card->hw.scasize);
 	switch (device_id) {
 		case PCI_DEVICE_ID_PC300_TE_1:
 		case PCI_DEVICE_ID_PC300_TE_2:
@@ -3525,7 +4085,9 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		case PCI_DEVICE_ID_PC300_TE_M_2:
 			request_mem_region(card->hw.falcphys, card->hw.falcsize,
 					   "FALC Registers");
-			card->hw.falcbase = ioremap(card->hw.falcphys, card->hw.falcsize);
+			card->hw.falcbase =
+				(void __iomem *) ioremap(card->hw.falcphys,
+							     card->hw.falcsize);
 			break;
 
 		case PCI_DEVICE_ID_PC300_RX_1:
@@ -3536,10 +4098,23 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -3584,16 +4159,36 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	/* Allocate IRQ */
-	if (request_irq(card->hw.irq, cpc_intr, IRQF_SHARED, "Cyclades-PC300", card)) {
-		printk ("PC300 found at RAM 0x%08x, but could not allocate IRQ%d.\n",
-			 card->hw.ramphys, card->hw.irq);
+	if (
+		request_irq(
+			card->hw.irq,
+			cpc_intr,
+			IRQF_SHARED,
+			"Cyclades-PC300",
+			card)
+		) {
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+		printk(KERN_ERR
+			"PC300 found at RAM 0x%016lx, but could not allocate "
+			"IRQ%d.\n", (unsigned long)(card->hw.ramphys),
+			card->hw.irq);
+#else /* !CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR
+			"PC300 found at RAM 0x%08x, but could not allocate "
+			"IRQ%d.\n", (unsigned int)(card->hw.ramphys),
+			card->hw.irq);
+#endif /* CONFIG_PHYS_ADDR_T_64BIT */
+		printk(KERN_ERR
+			"PC300 found at RAM 0x%08lx, but could not allocate IRQ%d.\n",
+			card->hw.ramphys, card->hw.irq);
 		goto err_io_unmap;
 	}
 
 	cpc_init_card(card);
 
 	if (eeprom_outdated)
-		printk("WARNING: PC300 with outdated EEPROM.\n");
+		printk(KERN_WARNING "WARNING: PC300 with outdated EEPROM.\n");
+
 	return 0;
 
 err_io_unmap:
@@ -3604,6 +4199,7 @@ err_io_unmap:
 		iounmap(card->hw.falcbase);
 		release_mem_region(card->hw.falcphys, card->hw.falcsize);
 	}
+err_release_sca:
 	release_mem_region(card->hw.scaphys, card->hw.scasize);
 err_release_ram:
 	release_mem_region(card->hw.ramphys, card->hw.alloc_ramsize);
@@ -3612,16 +4208,14 @@ err_release_plx:
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
@@ -3629,7 +4223,8 @@ static void __devexit cpc_remove_one(struct pci_dev *pdev)
 			   cpc_readw(card->hw.plxbase + card->hw.intctl_reg) & ~(0x0040));
 
 		for (i = 0; i < card->hw.nchan; i++) {
-			unregister_hdlc_device(card->chan[i].d.dev);
+			unregister_hdlc_device(card->chan[i].d.netdev);
+			free_netdev(card->chan[i].d.netdev);
 		}
 		iounmap(card->hw.plxbase);
 		iounmap(card->hw.scabase);
@@ -3642,13 +4237,9 @@ static void __devexit cpc_remove_one(struct pci_dev *pdev)
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
 
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index d47d2cd..56a7161 100644
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
@@ -50,6 +50,7 @@
 #include <linux/tty.h>
 #include <linux/tty_flip.h>
 #include <linux/serial.h>
+#include <linux/workqueue.h>
 
 #include <asm/io.h>
 #include <asm/uaccess.h>
@@ -79,7 +80,7 @@
 		spin_unlock_irqrestore(&card->card_lock, flags);	\
 	} while (0)
 
-//#define	CPC_TTY_DBG(format,a...)	printk(format,##a)
+/* #define	CPC_TTY_DBG(format,a...) printk(KERN_DEBUG format,##a) */
 #define	CPC_TTY_DBG(format,a...)
 
 /* data structures */
@@ -113,13 +114,16 @@ static struct tty_driver serial_drv;
 /* local variables */
 static st_cpc_tty_area	cpc_tty_area[CPC_TTY_NPORTS];
 
-static int cpc_tty_cnt = 0;	/* number of intrfaces configured with MLPPP */
-static int cpc_tty_unreg_flag = 0;
+static int cpc_tty_cnt;	/* number of intrfaces configured with MLPPP */
+static int cpc_tty_unreg_flag;
 
 /* TTY functions prototype */
 static int cpc_tty_open(struct tty_struct *tty, struct file *flip);
 static void cpc_tty_close(struct tty_struct *tty, struct file *flip);
-static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf, int count);
+static int cpc_tty_write(
+	struct tty_struct *tty,
+	const unsigned char *buf,
+	int count);
 static int cpc_tty_write_room(struct tty_struct *tty);
 static int cpc_tty_chars_in_buffer(struct tty_struct *tty);
 static void cpc_tty_flush_buffer(struct tty_struct *tty);
@@ -152,11 +156,16 @@ static void cpc_tty_signal_off(pc300dev_t *pc300dev, unsigned char signal)
 	unsigned long flags; 
 
 	CPC_TTY_DBG("%s-tty: Clear signal %x\n",
-		pc300dev->dev->name, signal);
-	CPC_TTY_LOCK(card, flags); 
-	cpc_writeb(card->hw.scabase + M_REG(CTL,ch), 
-		cpc_readb(card->hw.scabase+M_REG(CTL,ch))& signal);
-	CPC_TTY_UNLOCK(card,flags); 
+			pc300dev->netdev->name,
+			signal);
+	CPC_TTY_LOCK(card, flags);
+	cpc_writeb(
+			card->hw.scabase + M_REG(CTL, ch),
+			cpc_readb(
+				card->hw.scabase +
+				M_REG(CTL, ch)) &
+			signal);
+	CPC_TTY_UNLOCK(card, flags);
 }
 
 /*
@@ -170,7 +179,8 @@ static void cpc_tty_signal_on(pc300dev_t *pc300dev, unsigned char signal)
 	unsigned long flags; 
 
 	CPC_TTY_DBG("%s-tty: Set signal %x\n",
-		pc300dev->dev->name, signal);
+			pc300dev->netdev->name,
+			signal);
 	CPC_TTY_LOCK(card, flags); 
 	cpc_writeb(card->hw.scabase + M_REG(CTL,ch), 
 		cpc_readb(card->hw.scabase+M_REG(CTL,ch))& ~signal);
@@ -203,22 +213,24 @@ static const struct tty_operations pc300_ops = {
  */
 void cpc_tty_init(pc300dev_t *pc300dev)
 {
-	unsigned long port;
 	int aux;
-	st_cpc_tty_area * cpc_tty;
+	long port;
+	st_cpc_tty_area *cpc_tty;
 
 	/* hdlcX - X=interface number */
-	port = pc300dev->dev->name[4] - '0';
+	port = pc300dev->netdev->name[4] - '0';
 	if (port >= CPC_TTY_NPORTS) {
-		printk("%s-tty: invalid interface selected (0-%i): %li",
-			pc300dev->dev->name,
-			CPC_TTY_NPORTS-1,port);
+		printk(KERN_ERR
+				"%s-tty: invalid interface selected (0-%i): %li",
+				pc300dev->netdev->name,
+				CPC_TTY_NPORTS - 1,
+				port);
 		return;
 	}
 
 	if (cpc_tty_cnt == 0) { /* first TTY connection -> register driver */
 		CPC_TTY_DBG("%s-tty: driver init, major:%i, minor range:%i=%i\n",
-			pc300dev->dev->name,
+			pc300dev->netdev->name,
 			CPC_TTY_MAJOR, CPC_TTY_MINOR_START,
 			CPC_TTY_MINOR_START+CPC_TTY_NPORTS);
 		/* initialize tty driver struct */
@@ -241,11 +253,12 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 		tty_set_operations(&serial_drv, &pc300_ops);
 
 		/* register the TTY driver */
-		if (tty_register_driver(&serial_drv)) { 
-			printk("%s-tty: Failed to register serial driver! ",
-				pc300dev->dev->name);
+		if (tty_register_driver(&serial_drv)) {
+			printk(KERN_ERR
+					"%s-tty: Failed to register serial driver! ",
+					pc300dev->netdev->name);
 		   	return;
-		} 
+		}
 
 		memset((void *)cpc_tty_area, 0,
 								sizeof(st_cpc_tty_area) * CPC_TTY_NPORTS);
@@ -254,8 +267,10 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 	cpc_tty = &cpc_tty_area[port];
 	
 	if (cpc_tty->state != CPC_TTY_ST_IDLE) {
-		CPC_TTY_DBG("%s-tty: TTY port %i, already in use.\n",
-				pc300dev->dev->name, port);
+		CPC_TTY_DBG(
+				"%s-tty: TTY port %i, already in use.\n",
+				pc300dev->netdev->name,
+				port);
 		return;
 	}
 
@@ -268,15 +283,15 @@ void cpc_tty_init(pc300dev_t *pc300dev)
 	INIT_WORK(&cpc_tty->tty_tx_work, cpc_tty_tx_work);
 	INIT_WORK(&cpc_tty->tty_rx_work, cpc_tty_rx_work);
 	
-	cpc_tty->buf_rx.first = cpc_tty->buf_rx.last = NULL;
+	cpc_tty->buf_rx.first = cpc_tty->buf_rx.last = 0;
 
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
@@ -316,9 +331,9 @@ static int cpc_tty_open(struct tty_struct *tty, struct file *flip)
 	}
 
 	if (cpc_tty->num_open == 0) { /* first open of this tty */
-		if (!cpc_tty_area[port].buf_tx){
+		if (cpc_tty_area[port].buf_tx == 0) {
 			cpc_tty_area[port].buf_tx = kmalloc(CPC_TTY_MAX_MTU,GFP_KERNEL);
-			if (!cpc_tty_area[port].buf_tx) {
+			if (cpc_tty_area[port].buf_tx == 0) {
 				CPC_TTY_DBG("%s: error in memory allocation\n",cpc_tty->name);
 				return -ENOMEM;
 			}
@@ -360,7 +375,7 @@ static int cpc_tty_open(struct tty_struct *tty, struct file *flip)
 
 static void cpc_tty_close(struct tty_struct *tty, struct file *flip)
 {
-	st_cpc_tty_area    *cpc_tty;
+	st_cpc_tty_area *cpc_tty;
 	unsigned long flags;
 	int res;
 
@@ -407,9 +422,9 @@ static void cpc_tty_close(struct tty_struct *tty, struct file *flip)
 	kfree(cpc_tty->buf_tx);
 	cpc_tty->buf_tx = NULL;
 
-	CPC_TTY_DBG("%s: TTY closed\n",cpc_tty->name);
+	CPC_TTY_DBG("%s: TTY closed\n", cpc_tty->name);
 	
-	if (!serial_drv.refcount && cpc_tty_unreg_flag) {
+	if (!cpc_tty_cnt && cpc_tty_unreg_flag) {
 		cpc_tty_unreg_flag = 0;
 		CPC_TTY_DBG("%s: unregister the tty driver\n", cpc_tty->name);
 		if ((res=tty_unregister_driver(&serial_drv))) { 
@@ -428,14 +443,16 @@ static void cpc_tty_close(struct tty_struct *tty, struct file *flip)
  * o verify the DCD signal
  * o send characters to board and start the transmission
  */
-static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf, int count)
+static int cpc_tty_write(struct tty_struct *tty,
+			const unsigned char *buf, int count)
 {
-	st_cpc_tty_area    *cpc_tty; 
+	st_cpc_tty_area *cpc_tty;
 	pc300ch_t *pc300chan; 
 	pc300_t *card; 
 	int ch; 
 	unsigned long flags; 
 	struct net_device_stats *stats; 
+	int from_user = 1;
 
 	if (!tty || !tty->driver_data ) { 
 		CPC_TTY_DBG("hdlcX-tty: no TTY in write\n");
@@ -454,10 +471,14 @@ static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf, int c
 		return -EINVAL;        /* frame too big */ 
 	}
 
-	CPC_TTY_DBG("%s: cpc_tty_write data len=%i\n",cpc_tty->name,count);
+	CPC_TTY_DBG(
+			"%s: cpc_tty_write %s data len=%i\n",
+			cpc_tty->name,
+			(from_user) ? "from user" : "from kernel",
+			count);
 	
 	pc300chan = (pc300ch_t *)((pc300dev_t*)cpc_tty->pc300dev)->chan; 
-	stats = &cpc_tty->pc300dev->dev->stats;
+	stats = &(cpc_tty->pc300dev->netdev->stats);
 	card = (pc300_t *) pc300chan->card;
 	ch = pc300chan->channel; 
 
@@ -481,11 +502,35 @@ static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf, int c
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
+			CPC_TTY_DBG("%s: error in copy from user\n",
+					cpc_tty->name);
+			return -EINVAL;
+		}
+
+		if (cpc_tty_send_to_card(cpc_tty->pc300dev,
+					(void *)buf_tmp, count)) {
+			/* failed to send */
+			CPC_TTY_DBG("%s: transmission error\n", cpc_tty->name);
+			return 0;
+		}
+	} else {
+		if (
+				cpc_tty_send_to_card(cpc_tty->pc300dev,
+					(void *)buf,
+					count)
+				) {
+			/* failed to send */
+			CPC_TTY_DBG("%s: transmission error\n", cpc_tty->name);
+			return 0;
+		}
 	}
+
 	return count; 
 } 
 
@@ -498,7 +543,7 @@ static int cpc_tty_write(struct tty_struct *tty, const unsigned char *buf, int c
  */
 static int cpc_tty_write_room(struct tty_struct *tty)
 {
-	st_cpc_tty_area    *cpc_tty; 
+	st_cpc_tty_area *cpc_tty;
 
 	if (!tty || !tty->driver_data ) { 
 		CPC_TTY_DBG("hdlcX-tty: no TTY to write room\n");
@@ -525,7 +570,7 @@ static int cpc_tty_write_room(struct tty_struct *tty)
  */
 static int cpc_tty_chars_in_buffer(struct tty_struct *tty)
 {
-	st_cpc_tty_area    *cpc_tty; 
+	st_cpc_tty_area *cpc_tty;
 
 	if (!tty || !tty->driver_data ) {
 		CPC_TTY_DBG("hdlcX-tty: no TTY to chars in buffer\n");
@@ -542,10 +587,12 @@ static int cpc_tty_chars_in_buffer(struct tty_struct *tty)
 	return 0;
 } 
 
-static int pc300_tiocmset(struct tty_struct *tty,
-			  unsigned int set, unsigned int clear)
+static int pc300_tiocmset(
+		struct tty_struct *tty,
+		unsigned int set,
+		unsigned int clear)
 {
-	st_cpc_tty_area    *cpc_tty; 
+	st_cpc_tty_area *cpc_tty;
 
 	CPC_TTY_DBG("%s: set:%x clear:%x\n", __func__, set, clear);
 
@@ -582,8 +629,9 @@ static int pc300_tiocmget(struct tty_struct *tty)
 
 	cpc_tty = (st_cpc_tty_area *) tty->driver_data;
 
-	CPC_TTY_DBG("%s-tty: tiocmget\n",
-		((struct net_device*)(pc300dev->hdlc))->name);
+	CPC_TTY_DBG(
+			"%s-tty: tiocmget\n",
+			pc300dev->netdev->name);
 
 	CPC_TTY_LOCK(card, flags);
 	status = cpc_readb(card->hw.scabase+M_REG(CTL,ch));
@@ -602,7 +650,7 @@ static int pc300_tiocmget(struct tty_struct *tty)
  */
 static void cpc_tty_flush_buffer(struct tty_struct *tty)
 { 
-	st_cpc_tty_area    *cpc_tty; 
+	st_cpc_tty_area *cpc_tty;
 	
 	if (!tty || !tty->driver_data ) {
 	   	CPC_TTY_DBG("hdlcX-tty: no TTY to flush buffer\n");	
@@ -618,9 +666,18 @@ static void cpc_tty_flush_buffer(struct tty_struct *tty)
 
 	CPC_TTY_DBG("%s: call wake_up_interruptible\n",cpc_tty->name);
 
-	tty_wakeup(tty);	
-	return; 
-} 
+	wake_up_interruptible(&tty->write_wait);
+
+	if (
+			(tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) &&
+			tty->ldisc &&
+			tty->ldisc->ops && tty->ldisc->ops->write_wakeup
+			) {
+		CPC_TTY_DBG("%s: call line disc. wake up\n",
+				cpc_tty->name);
+		tty->ldisc->ops->write_wakeup(tty);
+	}
+}
 
 /*
  * PC300 TTY Hangup routine
@@ -631,7 +688,7 @@ static void cpc_tty_flush_buffer(struct tty_struct *tty)
 
 static void cpc_tty_hangup(struct tty_struct *tty)
 { 
-	st_cpc_tty_area    *cpc_tty; 
+	st_cpc_tty_area *cpc_tty;
 	int res;
 
 	if (!tty || !tty->driver_data ) {
@@ -645,7 +702,7 @@ static void cpc_tty_hangup(struct tty_struct *tty)
 		CPC_TTY_DBG("%s: TTY is not opened\n",cpc_tty->name);
 		return ;
 	}
-	if (!serial_drv.refcount && cpc_tty_unreg_flag) {
+	if (!cpc_tty_cnt && cpc_tty_unreg_flag) {
 		cpc_tty_unreg_flag = 0;
 		CPC_TTY_DBG("%s: unregister the tty driver\n", cpc_tty->name);
 		if ((res=tty_unregister_driver(&serial_drv))) { 
@@ -665,35 +722,35 @@ static void cpc_tty_hangup(struct tty_struct *tty)
  */
 static void cpc_tty_rx_work(struct work_struct *work)
 {
-	st_cpc_tty_area *cpc_tty;
-	unsigned long port;
 	int i, j;
-	volatile st_cpc_rx_buf *buf;
-	char flags=0,flg_rx=1; 
-	struct tty_ldisc *ld;
+	unsigned long port;
+	st_cpc_tty_area *cpc_tty;
+	st_cpc_rx_buf *buf;
+	char flags = 0, flg_rx = 1;
 
 	if (cpc_tty_cnt == 0) return;
-	
-	for (i=0; (i < 4) && flg_rx ; i++) {
-		flg_rx = 0;
 
+	for (i = 0; (i < 4) && flg_rx; i++) {
+		flg_rx = 0;
 		cpc_tty = container_of(work, st_cpc_tty_area, tty_rx_work);
 		port = cpc_tty - cpc_tty_area;
 
-		for (j=0; j < CPC_TTY_NPORTS; j++) {
+		for (j = 0; j < CPC_TTY_NPORTS; j++) {
 			cpc_tty = &cpc_tty_area[port];
-		
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
-				}	
+			buf = cpc_tty->buf_rx.first;
+			if (buf != NULL) {
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
@@ -714,13 +771,13 @@ static void cpc_tty_rx_work(struct work_struct *work)
  */
 static void cpc_tty_rx_disc_frame(pc300ch_t *pc300chan)
 {
-	volatile pcsca_bd_t __iomem * ptdescr; 
-	volatile unsigned char status; 
-	pc300_t *card = (pc300_t *)pc300chan->card; 
-	int ch = pc300chan->channel; 
+	pcsca_bd_t *ptdescr;
+	unsigned char status;
+	pc300_t *card = (pc300_t *)pc300chan->card;
+	int ch = pc300chan->channel;
 
 	/* dma buf read */ 
-	ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase + 
+	ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
 				RX_BD_ADDR(ch, pc300chan->rx_first_bd)); 
 	while (pc300chan->rx_first_bd != pc300chan->rx_last_bd) { 
 		status = cpc_readb(&ptdescr->status); 
@@ -731,22 +788,23 @@ static void cpc_tty_rx_disc_frame(pc300ch_t *pc300chan)
 		if (status & DST_EOM) { 
 			break; /* end of message */
 		}
-		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase + cpc_readl(&ptdescr->next)); 
+		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
+			cpc_readl(&ptdescr->next));
 	}
 }
 
 void cpc_tty_receive(pc300dev_t *pc300dev)
 {
-	st_cpc_tty_area *cpc_tty; 
-	pc300ch_t *pc300chan = (pc300ch_t *)pc300dev->chan; 
-	pc300_t *card = (pc300_t *)pc300chan->card; 
-	int ch = pc300chan->channel; 
-	volatile pcsca_bd_t  __iomem * ptdescr; 
-	struct net_device_stats *stats = &pc300dev->dev->stats;
-	int rx_len, rx_aux; 
-	volatile unsigned char status; 
+	st_cpc_tty_area *cpc_tty;
+	pc300ch_t *pc300chan = (pc300ch_t *)pc300dev->chan;
+	pc300_t *card = (pc300_t *)pc300chan->card;
+	int ch = pc300chan->channel;
+	pcsca_bd_t __iomem *ptdescr;
+	struct net_device_stats *stats = &pc300dev->netdev->stats;
+	int rx_len, rx_aux;
+	unsigned char status;
 	unsigned short first_bd = pc300chan->rx_first_bd;
-	st_cpc_rx_buf *new = NULL;
+	st_cpc_rx_buf	*new;
 	unsigned char dsr_rx;
 
 	if (pc300dev->cpc_tty == NULL) { 
@@ -759,14 +817,16 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 
 	while (1) { 
 		rx_len = 0;
-		ptdescr = (pcsca_bd_t  __iomem *)(card->hw.rambase + RX_BD_ADDR(ch, first_bd));
+		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
+			RX_BD_ADDR(ch, first_bd));
 		while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
 			rx_len += cpc_readw(&ptdescr->len);
 			first_bd = (first_bd + 1) & (N_DMA_RX_BUF - 1);
 			if (status & DST_EOM) {
 				break;
 			}
-			ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase+cpc_readl(&ptdescr->next));
+			ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
+				cpc_readl(&ptdescr->next));
 		}
 			
 		if (!rx_len) { 
@@ -775,7 +835,6 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 				cpc_writel(card->hw.scabase + DRX_REG(EDAL, ch), 
 						RX_BD_ADDR(ch, pc300chan->rx_last_bd)); 
 			}
-			kfree(new);
 			return; 
 		}
 		
@@ -789,13 +848,13 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 		} 
 		
 		new = kmalloc(rx_len + sizeof(st_cpc_rx_buf), GFP_ATOMIC);
-		if (!new) {
+		if (new == 0) {
 			cpc_tty_rx_disc_frame(pc300chan);
 			continue;
 		}
 		
 		/* dma buf read */ 
-		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase + 
+		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
 				RX_BD_ADDR(ch, pc300chan->rx_first_bd)); 
 
 		rx_len = 0;	/* counter frame size */
@@ -821,8 +880,7 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 						cpc_tty->name);
 				cpc_tty_rx_disc_frame(pc300chan);
 				rx_len = 0;
-				kfree(new);
-				new = NULL;
+				kfree((unsigned char *)new);
 				break; /* read next frame - while(1) */
 			}
 
@@ -831,15 +889,14 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
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
+					(void __iomem *)(card->hw.rambase +
 					 cpc_readl(&ptdescr->ptbuf)), rx_aux);
 				rx_len += rx_aux; 
 			}
@@ -847,9 +904,10 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
 			cpc_writeb(&ptdescr->len, 0); 
 			pc300chan->rx_first_bd = (pc300chan->rx_first_bd + 1) & 
 					(N_DMA_RX_BUF -1); 
-			if (status & DST_EOM)break;
+			if (status & DST_EOM)
+				break;
 			
-			ptdescr = (pcsca_bd_t __iomem *) (card->hw.rambase + 
+			ptdescr = (pcsca_bd_t __iomem *) (card->hw.rambase +
 					cpc_readl(&ptdescr->next)); 
 		}
 		/* update pointer */ 
@@ -867,8 +925,8 @@ void cpc_tty_receive(pc300dev_t *pc300dev)
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
@@ -892,15 +950,29 @@ static void cpc_tty_tx_work(struct work_struct *work)
 {
 	st_cpc_tty_area *cpc_tty =
 		container_of(work, st_cpc_tty_area, tty_tx_work);
-	struct tty_struct *tty; 
+	struct tty_struct *tty;
 
 	CPC_TTY_DBG("%s: cpc_tty_tx_work init\n",cpc_tty->name);
 	
-	if ((tty = cpc_tty->tty) == NULL) { 
-		CPC_TTY_DBG("%s: the interface is not opened\n",cpc_tty->name);
+	tty = cpc_tty->tty;
+	if (tty == 0) {
+		CPC_TTY_DBG("%s: the interface is not opened\n",
+				cpc_tty->name);
 		return; 
 	}
-	tty_wakeup(tty);
+
+	if (
+			(tty->flags & (1 << TTY_DO_WRITE_WAKEUP)) &&
+			tty->ldisc &&
+			tty->ldisc->ops &&
+			tty->ldisc->ops->write_wakeup
+			) {
+		CPC_TTY_DBG("%s:call line disc. wakeup\n",
+				cpc_tty->name);
+		tty->ldisc->ops->write_wakeup(tty);
+	}
+
+	wake_up_interruptible(&tty->write_wait);
 }
 
 /*
@@ -911,21 +983,23 @@ static void cpc_tty_tx_work(struct work_struct *work)
  * o write data to DMA buffers
  * o start the transmission
  */
-static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
+static int cpc_tty_send_to_card(pc300dev_t *dev, void *buf, int len)
 {
 	pc300ch_t *chan = (pc300ch_t *)dev->chan; 
 	pc300_t *card = (pc300_t *)chan->card; 
 	int ch = chan->channel; 
-	struct net_device_stats *stats = &dev->dev->stats;
+	struct net_device_stats *stats = &dev->netdev->stats;
 	unsigned long flags; 
-	volatile pcsca_bd_t __iomem *ptdescr; 
+	pcsca_bd_t __iomem *ptdescr;
 	int i, nchar;
 	int tosend = len;
 	int nbuf = ((len - 1)/BD_DEF_LEN) + 1;
 	unsigned char *pdata=buf;
 
-	CPC_TTY_DBG("%s:cpc_tty_send_to_cars len=%i", 
-			(st_cpc_tty_area *)dev->cpc_tty->name,len);	
+	CPC_TTY_DBG(
+			"%s:cpc_tty_send_to_card len=%i",
+			(st_cpc_tty_area *)dev->cpc_tty->name,
+			len);
 
 	if (nbuf >= card->chan[ch].nfree_tx_bd) {
 		return 1;
@@ -935,11 +1009,11 @@ static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
 	CPC_TTY_DBG("%s: call dma_buf_write\n",
 			(st_cpc_tty_area *)dev->cpc_tty->name);	
 	for (i = 0 ; i < nbuf ; i++) {
-		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase + 
+		ptdescr = (pcsca_bd_t __iomem *)(card->hw.rambase +
 			TX_BD_ADDR(ch, card->chan[ch].tx_next_bd));
 		nchar = (BD_DEF_LEN > tosend) ? tosend : BD_DEF_LEN;
 		if (cpc_readb(&ptdescr->status) & DST_OSB) {
-			memcpy_toio((void __iomem *)(card->hw.rambase + 
+			memcpy_toio((void __iomem *)(card->hw.rambase +
 				cpc_readl(&ptdescr->ptbuf)), 
 				&pdata[len - tosend], 
 				nchar);
@@ -955,7 +1029,7 @@ static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
 			CPC_TTY_DBG("%s: error in dma_buf_write\n",
 					(st_cpc_tty_area *)dev->cpc_tty->name);	
 			stats->tx_dropped++;
-			return 1; 
+			return 1;
 		}
 		tosend -= nchar;
 		card->chan[ch].tx_next_bd = 
@@ -982,7 +1056,7 @@ static int cpc_tty_send_to_card(pc300dev_t *dev,void* buf, int len)
 			(CPLD_REG2_FALC_LED1 << (2 * ch))); 
 	}
 	CPC_TTY_UNLOCK(card, flags); 
-	return 0; 
+	return 0;
 } 
 
 /*
@@ -1000,26 +1074,28 @@ static void cpc_tty_trace(pc300dev_t *dev, char* buf, int len, char rxtx)
 
 	if ((skb = dev_alloc_skb(10 + len)) == NULL) { 
 		/* out of memory */ 
-		CPC_TTY_DBG("%s: tty_trace - out of memory\n", dev->dev->name);
+		CPC_TTY_DBG(
+				"%s: tty_trace - out of memory\n",
+				dev->netdev->name);
 		return; 
 	}
 
 	skb_put (skb, 10 + len); 
-	skb->dev = dev->dev; 
-	skb->protocol = htons(ETH_P_CUST); 
+	skb->dev = dev->netdev;
+	skb->protocol = htons(ETH_P_CUST);
 	skb_reset_mac_header(skb);
-	skb->pkt_type = PACKET_HOST; 
-	skb->len = 10 + len; 
-
-	skb_copy_to_linear_data(skb, dev->dev->name, 5);
-	skb->data[5] = '['; 
-	skb->data[6] = rxtx; 
-	skb->data[7] = ']'; 
-	skb->data[8] = ':'; 
-	skb->data[9] = ' '; 
+	skb->pkt_type = PACKET_HOST;
+	skb->len = 10 + len;
+
+	skb_copy_to_linear_data(skb, dev->netdev->name, 5);
+	skb->data[5] = '[';
+	skb->data[6] = rxtx;
+	skb->data[7] = ']';
+	skb->data[8] = ':';
+	skb->data[9] = ' ';
 	skb_copy_to_linear_data_offset(skb, 10, buf, len);
-	netif_rx(skb); 
-} 	
+	netif_rx(skb);
+}
 
 /*
  *	PC300 TTY unregister service routine
@@ -1032,38 +1108,40 @@ void cpc_tty_unregister_service(pc300dev_t *pc300dev)
 	ulong flags;
 	int res;
 
-	if ((cpc_tty= (st_cpc_tty_area *) pc300dev->cpc_tty) == NULL) {
-		CPC_TTY_DBG("%s: interface is not TTY\n", pc300dev->dev->name);
+	cpc_tty = (st_cpc_tty_area *) pc300dev->cpc_tty;
+	if (cpc_tty == 0) {
+		CPC_TTY_DBG(
+				"%s: interface is not TTY\n",
+				pc300dev->netdev->name);
 		return; 
 	}
-	CPC_TTY_DBG("%s: cpc_tty_unregister_service", cpc_tty->name);
+	CPC_TTY_DBG(
+			"%s: cpc_tty_unregister_service",
+			cpc_tty->name);
 
 	if (cpc_tty->pc300dev != pc300dev) { 
-		CPC_TTY_DBG("%s: invalid tty ptr=%s\n", 
-		pc300dev->dev->name, cpc_tty->name);
+		CPC_TTY_DBG(
+				"%s: invalid tty ptr=%s\n",
+				pc300dev->netdev->name,
+				cpc_tty->name);
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
+		CPC_TTY_DBG("%s: unregister the tty driver\n",
+				cpc_tty->name);
+		res = tty_unregister_driver(&serial_drv);
+		if (res) {
+			CPC_TTY_DBG(
+				"%s: ERROR ->unregister the tty driver error=%d\n",
+				cpc_tty->name, res);
 		}
 	}
 	CPC_TTY_LOCK(pc300dev->chan->card,flags);
-	cpc_tty->tty = NULL; 
+	cpc_tty->tty = NULL;
 	CPC_TTY_UNLOCK(pc300dev->chan->card, flags);
-	cpc_tty->tty_minor = 0; 
-	cpc_tty->state = CPC_TTY_ST_IDLE; 
+	cpc_tty->tty_minor = 0;
+	cpc_tty->state = CPC_TTY_ST_IDLE;
 } 
 
 /*
@@ -1092,6 +1170,7 @@ void cpc_tty_reset_var(void)
 	/* reset  the tty_driver structure - serial_drv */ 
 	memset(&serial_drv, 0, sizeof(struct tty_driver));
 	for (i=0; i < CPC_TTY_NPORTS; i++){
-		memset(&cpc_tty_area[i],0, sizeof(st_cpc_tty_area)); 
+		memset(&cpc_tty_area[i], 0,
+				sizeof(st_cpc_tty_area));
 	}
 }
