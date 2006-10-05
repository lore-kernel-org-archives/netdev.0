From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2.6.18 4/6]: sb1250-mac: Driver model & phylib support
Date: Thu, 5 Oct 2006 17:04:11 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610051655040.22085@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:34564 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP id S932155AbWJEQEO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 12:04:14 -0400
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 This is an update including the following changes:

1. Some help text for Kconfig.

2. Removal of unused module options.

3. Phylib support and the resulting removal of generic bits for handling 
   the PHY.

4. Proper reserving of device resources and using ioremap()ped handles
   to access MAC registers rather than platform-specific macros.

5. Handling of the device using the driver model.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---

 This revision fixes the problem with drivers/net/Kconfig.

 Please consider.

  Maciej

patch-2.6.18-sb1250-mac-16
diff -up --recursive --new-file linux-2.6.18.macro/drivers/net/Kconfig linux-2.6.18/drivers/net/Kconfig
--- linux-2.6.18.macro/drivers/net/Kconfig	2006-09-20 03:42:06.000000000 +0000
+++ linux-2.6.18/drivers/net/Kconfig	2006-10-05 15:50:20.000000000 +0000
@@ -456,6 +456,15 @@ config MIPS_AU1X00_ENET
 config NET_SB1250_MAC
 	tristate "SB1250 Ethernet support"
 	depends on NET_ETHERNET && SIBYTE_SB1xxx_SOC
+	select PHYLIB
+	---help---
+	  This driver supports gigabit Ethernet interfaces based on the
+	  Broadcom SiByte family of System-On-a-Chip parts.  They include
+	  the BCM1120, BCM1125, BCM1125H, BCM1250, BCM1255, BCM1280, BCM1455
+	  and BCM1480 chips.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sb1250-mac.
 
 config SGI_IOC3_ETH
 	bool "SGI IOC3 Ethernet"
diff -up --recursive --new-file linux-2.6.18.macro/drivers/net/sb1250-mac.c linux-2.6.18/drivers/net/sb1250-mac.c
--- linux-2.6.18.macro/drivers/net/sb1250-mac.c	2006-09-20 03:42:06.000000000 +0000
+++ linux-2.6.18/drivers/net/sb1250-mac.c	2006-10-05 15:48:50.000000000 +0000
@@ -1,5 +1,6 @@
 /*
  * Copyright (C) 2001,2002,2003,2004 Broadcom Corporation
+ * Copyright (c) 2006  Maciej W. Rozycki
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -18,7 +19,11 @@
  *
  * This driver is designed for the Broadcom SiByte SOC built-in
  * Ethernet controllers. Written by Mitch Lichtenberg at Broadcom Corp.
+ *
+ * Updated to the driver model and the PHY abstraction layer
+ * by Maciej W. Rozycki.
  */
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -32,9 +37,18 @@
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/bitops.h>
-#include <asm/processor.h>		/* Processor type for cache alignment. */
-#include <asm/io.h>
+#include <linux/err.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/platform_device.h>
+#include <linux/workqueue.h>
+
+#include <asm/bug.h>
 #include <asm/cache.h>
+#include <asm/io.h>
+#include <asm/processor.h>	/* Processor type for cache alignment. */
 
 /* This is only here until the firmware is ready.  In that case,
    the firmware leaves the ethernet address in the register for us. */
@@ -48,7 +62,7 @@
 
 /* These identify the driver base version and may not be removed. */
 #if 0
-static char version1[] __devinitdata =
+static char version1[] __initdata =
 "sb1250-mac.c:1.00 1/11/2001 Written by Mitch Lichtenberg\n";
 #endif
 
@@ -57,8 +71,6 @@ static char version1[] __devinitdata =
 
 #define CONFIG_SBMAC_COALESCE
 
-#define MAX_UNITS 4		/* More are supported, limit only on options */
-
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (2*HZ)
 
@@ -74,26 +86,6 @@ static int debug = 1;
 module_param(debug, int, S_IRUGO);
 MODULE_PARM_DESC(debug, "Debug messages");
 
-/* mii status msgs */
-static int noisy_mii = 1;
-module_param(noisy_mii, int, S_IRUGO);
-MODULE_PARM_DESC(noisy_mii, "MII status messages");
-
-/* Used to pass the media type, etc.
-   Both 'options[]' and 'full_duplex[]' should exist for driver
-   interoperability.
-   The media type is usually passed in 'options[]'.
-*/
-#ifdef MODULE
-static int options[MAX_UNITS] = {-1, -1, -1, -1};
-module_param_array(options, int, NULL, S_IRUGO);
-MODULE_PARM_DESC(options, "1-" __MODULE_STRING(MAX_UNITS));
-
-static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1};
-module_param_array(full_duplex, int, NULL, S_IRUGO);
-MODULE_PARM_DESC(full_duplex, "1-" __MODULE_STRING(MAX_UNITS));
-#endif
-
 #ifdef CONFIG_SBMAC_COALESCE
 static int int_pktcnt = 0;
 module_param(int_pktcnt, int, S_IRUGO);
@@ -104,6 +96,7 @@ module_param(int_timeout, int, S_IRUGO);
 MODULE_PARM_DESC(int_timeout, "Timeout value");
 #endif
 
+#include <asm/sibyte/board.h>
 #include <asm/sibyte/sb1250.h>
 #if defined(CONFIG_SIBYTE_BCM1x55) || defined(CONFIG_SIBYTE_BCM1x80)
 #include <asm/sibyte/bcm1480_regs.h>
@@ -126,22 +119,43 @@ MODULE_PARM_DESC(int_timeout, "Timeout v
 #error invalid SiByte MAC configuation
 #endif
 
+#ifdef K_INT_PHY
+#define SBMAC_PHY_INT			K_INT_PHY
+#else
+#define SBMAC_PHY_INT			PHY_POLL
+#endif
+
 /**********************************************************************
  *  Simple types
  ********************************************************************* */
 
-
-typedef enum { sbmac_speed_auto, sbmac_speed_10,
-	       sbmac_speed_100, sbmac_speed_1000 } sbmac_speed_t;
-
-typedef enum { sbmac_duplex_auto, sbmac_duplex_half,
-	       sbmac_duplex_full } sbmac_duplex_t;
-
-typedef enum { sbmac_fc_auto, sbmac_fc_disabled, sbmac_fc_frame,
-	       sbmac_fc_collision, sbmac_fc_carrier } sbmac_fc_t;
-
-typedef enum { sbmac_state_uninit, sbmac_state_off, sbmac_state_on,
-	       sbmac_state_broken } sbmac_state_t;
+typedef enum {
+	sbmac_speed_none = 0,
+	sbmac_speed_10 = SPEED_10,
+	sbmac_speed_100 = SPEED_100,
+	sbmac_speed_1000 = SPEED_1000,
+} sbmac_speed_t;
+
+typedef enum {
+	sbmac_duplex_none = -1,
+	sbmac_duplex_half = DUPLEX_HALF,
+	sbmac_duplex_full = DUPLEX_FULL,
+} sbmac_duplex_t;
+
+typedef enum {
+	sbmac_fc_none,
+	sbmac_fc_disabled,
+	sbmac_fc_frame,
+	sbmac_fc_collision,
+	sbmac_fc_carrier,
+} sbmac_fc_t;
+
+typedef enum {
+	sbmac_state_uninit,
+	sbmac_state_off,
+	sbmac_state_on,
+	sbmac_state_broken,
+} sbmac_state_t;
 
 
 /**********************************************************************
@@ -225,46 +239,46 @@ struct sbmac_softc {
 	 * Linux-specific things
 	 */
 
-	struct net_device *sbm_dev;		/* pointer to linux device */
-	spinlock_t sbm_lock;		/* spin lock */
-	struct timer_list sbm_timer;     	/* for monitoring MII */
-	struct net_device_stats sbm_stats;
-	int sbm_devflags;			/* current device flags */
-
-	int	     sbm_phy_oldbmsr;
-	int	     sbm_phy_oldanlpar;
-	int	     sbm_phy_oldk1stsr;
-	int	     sbm_phy_oldlinkstat;
-	int sbm_buffersize;
+	struct net_device	*sbm_dev;	/* pointer to linux device */
+	struct phy_device	*phy_dev;	/* the associated PHY device */
+	struct mii_bus		mii_bus;	/* the MII bus */
+	int			phy_irq[PHY_MAX_ADDR];
+	struct work_struct	sbm_queue;	/* used for the PHY */
+	spinlock_t		sbm_lock;	/* spin lock */
+	struct net_device_stats	sbm_stats;
+	int			sbm_devflags;	/* current device flags */
 
-	unsigned char sbm_phys[2];
+	int			sbm_buffersize;
 
 	/*
 	 * Controller-specific things
 	 */
 
-	volatile void __iomem *sbm_base;          /* MAC's base address */
-	sbmac_state_t    sbm_state;         /* current state */
+	volatile void __iomem	*sbm_base;	/* MAC's base address */
+	sbmac_state_t		sbm_state;	/* current state */
 
 	volatile void __iomem	*sbm_macenable;	/* MAC Enable Register */
-	volatile void __iomem	*sbm_maccfg;	/* MAC Configuration Register */
-	volatile void __iomem	*sbm_fifocfg;	/* FIFO configuration register */
-	volatile void __iomem	*sbm_framecfg;	/* Frame configuration register */
-	volatile void __iomem	*sbm_rxfilter;	/* receive filter register */
-	volatile void __iomem	*sbm_isr;	/* Interrupt status register */
-	volatile void __iomem	*sbm_imr;	/* Interrupt mask register */
-	volatile void __iomem	*sbm_mdio;	/* MDIO register */
-
-	sbmac_speed_t    sbm_speed;		/* current speed */
-	sbmac_duplex_t   sbm_duplex;	/* current duplex */
-	sbmac_fc_t       sbm_fc;		/* current flow control setting */
-
-	unsigned char    sbm_hwaddr[ETHER_ADDR_LEN];
-
-	sbmacdma_t       sbm_txdma;		/* for now, only use channel 0 */
-	sbmacdma_t       sbm_rxdma;
-	int              rx_hw_checksum;
-	int 		 sbe_idx;
+	volatile void __iomem	*sbm_maccfg;	/* MAC Config Register */
+	volatile void __iomem	*sbm_fifocfg;	/* FIFO Config Register */
+	volatile void __iomem	*sbm_framecfg;	/* Frame Config Register */
+	volatile void __iomem	*sbm_rxfilter;	/* Receive Filter Register */
+	volatile void __iomem	*sbm_isr;	/* Interrupt Status Register */
+	volatile void __iomem	*sbm_imr;	/* Interrupt Mask Register */
+	volatile void __iomem	*sbm_mdio;	/* MDIO Register */
+
+
+	sbmac_speed_t		sbm_speed;	/* current speed */
+	sbmac_duplex_t		sbm_duplex;	/* current duplex */
+	sbmac_fc_t		sbm_fc;		/* cur. flow control setting */
+	int			sbm_pause;	/* current pause setting */
+	int			sbm_link;	/* current link state */
+
+	unsigned char		sbm_hwaddr[ETHER_ADDR_LEN];
+
+	sbmacdma_t		sbm_txdma;	/* only channel 0 for now */
+	sbmacdma_t		sbm_rxdma;
+	int			rx_hw_checksum;
+	int			sbe_idx;
 };
 
 
@@ -297,32 +311,36 @@ static uint64_t sbmac_addr2reg(unsigned 
 static irqreturn_t sbmac_intr(int irq,void *dev_instance,struct pt_regs *rgs);
 static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev);
 static void sbmac_setmulti(struct sbmac_softc *sc);
-static int sbmac_init(struct net_device *dev, int idx);
+static int sbmac_init(struct platform_device *pldev, long long base);
 static int sbmac_set_speed(struct sbmac_softc *s,sbmac_speed_t speed);
 static int sbmac_set_duplex(struct sbmac_softc *s,sbmac_duplex_t duplex,sbmac_fc_t fc);
 
 static int sbmac_open(struct net_device *dev);
-static void sbmac_timer(unsigned long data);
 static void sbmac_tx_timeout (struct net_device *dev);
 static struct net_device_stats *sbmac_get_stats(struct net_device *dev);
 static void sbmac_set_rx_mode(struct net_device *dev);
 static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+static void sbmac_phy_disconnect(void *data);
 static int sbmac_close(struct net_device *dev);
-static int sbmac_mii_poll(struct sbmac_softc *s,int noisy);
+static void sbmac_mii_poll(struct net_device *dev);
 static int sbmac_mii_probe(struct net_device *dev);
 
-static void sbmac_mii_sync(struct sbmac_softc *s);
-static void sbmac_mii_senddata(struct sbmac_softc *s,unsigned int data, int bitcnt);
-static unsigned int sbmac_mii_read(struct sbmac_softc *s,int phyaddr,int regidx);
-static void sbmac_mii_write(struct sbmac_softc *s,int phyaddr,int regidx,
-			    unsigned int regval);
+static void sbmac_mii_sync(volatile void __iomem *sbm_mdio);
+static void sbmac_mii_senddata(volatile void __iomem *sbm_mdio,
+			       unsigned int data, int bitcnt);
+static int sbmac_mii_read(struct mii_bus *bus, int phyaddr, int regidx);
+static int sbmac_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
+			   u16 val);
 
 
 /**********************************************************************
  *  Globals
  ********************************************************************* */
 
-static uint64_t sbmac_orig_hwaddr[MAX_UNITS];
+static char sbmac_string[] = "sb1250-mac";
+static char sbmac_pretty[] = "SB1250 MAC";
+
+static char sbmac_mdio_string[] = "sb1250-mac-mdio";
 
 
 /**********************************************************************
@@ -334,185 +352,66 @@ static uint64_t sbmac_orig_hwaddr[MAX_UN
 #define	MII_COMMAND_WRITE	0x01
 #define	MII_COMMAND_ACK		0x02
 
-#define BMCR_RESET     0x8000
-#define BMCR_LOOPBACK  0x4000
-#define BMCR_SPEED0    0x2000
-#define BMCR_ANENABLE  0x1000
-#define BMCR_POWERDOWN 0x0800
-#define BMCR_ISOLATE   0x0400
-#define BMCR_RESTARTAN 0x0200
-#define BMCR_DUPLEX    0x0100
-#define BMCR_COLTEST   0x0080
-#define BMCR_SPEED1    0x0040
-#define BMCR_SPEED1000	BMCR_SPEED1
-#define BMCR_SPEED100	BMCR_SPEED0
-#define BMCR_SPEED10 	0
-
-#define BMSR_100BT4	0x8000
-#define BMSR_100BT_FDX	0x4000
-#define BMSR_100BT_HDX  0x2000
-#define BMSR_10BT_FDX   0x1000
-#define BMSR_10BT_HDX   0x0800
-#define BMSR_100BT2_FDX 0x0400
-#define BMSR_100BT2_HDX 0x0200
-#define BMSR_1000BT_XSR	0x0100
-#define BMSR_PRESUP	0x0040
-#define BMSR_ANCOMPLT	0x0020
-#define BMSR_REMFAULT	0x0010
-#define BMSR_AUTONEG	0x0008
-#define BMSR_LINKSTAT	0x0004
-#define BMSR_JABDETECT	0x0002
-#define BMSR_EXTCAPAB	0x0001
-
-#define PHYIDR1 	0x2000
-#define PHYIDR2		0x5C60
-
-#define ANAR_NP		0x8000
-#define ANAR_RF		0x2000
-#define ANAR_ASYPAUSE	0x0800
-#define ANAR_PAUSE	0x0400
-#define ANAR_T4		0x0200
-#define ANAR_TXFD	0x0100
-#define ANAR_TXHD	0x0080
-#define ANAR_10FD	0x0040
-#define ANAR_10HD	0x0020
-#define ANAR_PSB	0x0001
-
-#define ANLPAR_NP	0x8000
-#define ANLPAR_ACK	0x4000
-#define ANLPAR_RF	0x2000
-#define ANLPAR_ASYPAUSE	0x0800
-#define ANLPAR_PAUSE	0x0400
-#define ANLPAR_T4	0x0200
-#define ANLPAR_TXFD	0x0100
-#define ANLPAR_TXHD	0x0080
-#define ANLPAR_10FD	0x0040
-#define ANLPAR_10HD	0x0020
-#define ANLPAR_PSB	0x0001	/* 802.3 */
-
-#define ANER_PDF	0x0010
-#define ANER_LPNPABLE	0x0008
-#define ANER_NPABLE	0x0004
-#define ANER_PAGERX	0x0002
-#define ANER_LPANABLE	0x0001
-
-#define ANNPTR_NP	0x8000
-#define ANNPTR_MP	0x2000
-#define ANNPTR_ACK2	0x1000
-#define ANNPTR_TOGTX	0x0800
-#define ANNPTR_CODE	0x0008
-
-#define ANNPRR_NP	0x8000
-#define ANNPRR_MP	0x2000
-#define ANNPRR_ACK3	0x1000
-#define ANNPRR_TOGTX	0x0800
-#define ANNPRR_CODE	0x0008
-
-#define K1TCR_TESTMODE	0x0000
-#define K1TCR_MSMCE	0x1000
-#define K1TCR_MSCV	0x0800
-#define K1TCR_RPTR	0x0400
-#define K1TCR_1000BT_FDX 0x200
-#define K1TCR_1000BT_HDX 0x100
-
-#define K1STSR_MSMCFLT	0x8000
-#define K1STSR_MSCFGRES	0x4000
-#define K1STSR_LRSTAT	0x2000
-#define K1STSR_RRSTAT	0x1000
-#define K1STSR_LP1KFD	0x0800
-#define K1STSR_LP1KHD   0x0400
-#define K1STSR_LPASMDIR	0x0200
-
-#define K1SCR_1KX_FDX	0x8000
-#define K1SCR_1KX_HDX	0x4000
-#define K1SCR_1KT_FDX	0x2000
-#define K1SCR_1KT_HDX	0x1000
-
-#define STRAP_PHY1	0x0800
-#define STRAP_NCMODE	0x0400
-#define STRAP_MANMSCFG	0x0200
-#define STRAP_ANENABLE	0x0100
-#define STRAP_MSVAL	0x0080
-#define STRAP_1KHDXADV	0x0010
-#define STRAP_1KFDXADV	0x0008
-#define STRAP_100ADV	0x0004
-#define STRAP_SPEEDSEL	0x0000
-#define STRAP_SPEED100	0x0001
-
-#define PHYSUP_SPEED1000 0x10
-#define PHYSUP_SPEED100  0x08
-#define PHYSUP_SPEED10   0x00
-#define PHYSUP_LINKUP	 0x04
-#define PHYSUP_FDX       0x02
-
-#define	MII_BMCR	0x00 	/* Basic mode control register (rw) */
-#define	MII_BMSR	0x01	/* Basic mode status register (ro) */
-#define	MII_PHYIDR1	0x02
-#define	MII_PHYIDR2	0x03
-
-#define MII_K1STSR	0x0A	/* 1K Status Register (ro) */
-#define	MII_ANLPAR	0x05	/* Autonegotiation lnk partner abilities (rw) */
-
-
 #define M_MAC_MDIO_DIR_OUTPUT	0		/* for clarity */
 
 #define ENABLE 		1
 #define DISABLE		0
 
 /**********************************************************************
- *  SBMAC_MII_SYNC(s)
+ *  SBMAC_MII_SYNC(sbm_mdio)
  *
  *  Synchronize with the MII - send a pattern of bits to the MII
  *  that will guarantee that it is ready to accept a command.
  *
  *  Input parameters:
- *  	   s - sbmac structure
+ *  	   sbm_mdio - address of the MAC's MDIO register
  *
  *  Return value:
  *  	   nothing
  ********************************************************************* */
 
-static void sbmac_mii_sync(struct sbmac_softc *s)
+static void sbmac_mii_sync(volatile void __iomem *sbm_mdio)
 {
 	int cnt;
 	uint64_t bits;
 	int mac_mdio_genc;
 
-	mac_mdio_genc = __raw_readq(s->sbm_mdio) & M_MAC_GENC;
+	mac_mdio_genc = __raw_readq(sbm_mdio) & M_MAC_GENC;
 
 	bits = M_MAC_MDIO_DIR_OUTPUT | M_MAC_MDIO_OUT;
 
-	__raw_writeq(bits | mac_mdio_genc, s->sbm_mdio);
+	__raw_writeq(bits | mac_mdio_genc, sbm_mdio);
 
 	for (cnt = 0; cnt < 32; cnt++) {
-		__raw_writeq(bits | M_MAC_MDC | mac_mdio_genc, s->sbm_mdio);
-		__raw_writeq(bits | mac_mdio_genc, s->sbm_mdio);
+		__raw_writeq(bits | M_MAC_MDC | mac_mdio_genc, sbm_mdio);
+		__raw_writeq(bits | mac_mdio_genc, sbm_mdio);
 	}
 }
 
 /**********************************************************************
- *  SBMAC_MII_SENDDATA(s,data,bitcnt)
+ *  SBMAC_MII_SENDDATA(sbm_mdio, data, bitcnt)
  *
  *  Send some bits to the MII.  The bits to be sent are right-
  *  justified in the 'data' parameter.
  *
  *  Input parameters:
- *  	   s - sbmac structure
- *  	   data - data to send
- *  	   bitcnt - number of bits to send
+ *  	   sbm_mdio - address of the MAC's MDIO register
+ *  	   data     - data to send
+ *  	   bitcnt   - number of bits to send
  ********************************************************************* */
 
-static void sbmac_mii_senddata(struct sbmac_softc *s,unsigned int data, int bitcnt)
+static void sbmac_mii_senddata(volatile void __iomem *sbm_mdio,
+			       unsigned int data, int bitcnt)
 {
 	int i;
 	uint64_t bits;
 	unsigned int curmask;
 	int mac_mdio_genc;
 
-	mac_mdio_genc = __raw_readq(s->sbm_mdio) & M_MAC_GENC;
+	mac_mdio_genc = __raw_readq(sbm_mdio) & M_MAC_GENC;
 
 	bits = M_MAC_MDIO_DIR_OUTPUT;
-	__raw_writeq(bits | mac_mdio_genc, s->sbm_mdio);
+	__raw_writeq(bits | mac_mdio_genc, sbm_mdio);
 
 	curmask = 1 << (bitcnt - 1);
 
@@ -520,9 +419,9 @@ static void sbmac_mii_senddata(struct sb
 		if (data & curmask)
 			bits |= M_MAC_MDIO_OUT;
 		else bits &= ~M_MAC_MDIO_OUT;
-		__raw_writeq(bits | mac_mdio_genc, s->sbm_mdio);
-		__raw_writeq(bits | M_MAC_MDC | mac_mdio_genc, s->sbm_mdio);
-		__raw_writeq(bits | mac_mdio_genc, s->sbm_mdio);
+		__raw_writeq(bits | mac_mdio_genc, sbm_mdio);
+		__raw_writeq(bits | M_MAC_MDC | mac_mdio_genc, sbm_mdio);
+		__raw_writeq(bits | mac_mdio_genc, sbm_mdio);
 		curmask >>= 1;
 	}
 }
@@ -530,21 +429,22 @@ static void sbmac_mii_senddata(struct sb
 
 
 /**********************************************************************
- *  SBMAC_MII_READ(s,phyaddr,regidx)
- *
+ *  SBMAC_MII_READ(bus, phyaddr, regidx)
  *  Read a PHY register.
  *
  *  Input parameters:
- *  	   s - sbmac structure
+ *  	   bus     - MDIO bus handle
  *  	   phyaddr - PHY's address
- *  	   regidx = index of register to read
+ *  	   regnum  - index of register to read
  *
  *  Return value:
- *  	   value read, or 0 if an error occurred.
+ *  	   value read, or 0xffff if an error occurred.
  ********************************************************************* */
 
-static unsigned int sbmac_mii_read(struct sbmac_softc *s,int phyaddr,int regidx)
+static int sbmac_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
 {
+	struct sbmac_softc *sc = (struct sbmac_softc *)bus->priv;
+	volatile void __iomem *sbm_mdio = sc->sbm_mdio;
 	int idx;
 	int error;
 	int regval;
@@ -554,8 +454,7 @@ static unsigned int sbmac_mii_read(struc
 	 * Synchronize ourselves so that the PHY knows the next
 	 * thing coming down is a command
 	 */
-
-	sbmac_mii_sync(s);
+	sbmac_mii_sync(sbm_mdio);
 
 	/*
 	 * Send the data to the PHY.  The sequence is
@@ -564,37 +463,37 @@ static unsigned int sbmac_mii_read(struc
 	 * the PHY addr (5 bits)
 	 * the register index (5 bits)
 	 */
+	sbmac_mii_senddata(sbm_mdio, MII_COMMAND_START, 2);
+	sbmac_mii_senddata(sbm_mdio, MII_COMMAND_READ, 2);
+	sbmac_mii_senddata(sbm_mdio, phyaddr, 5);
+	sbmac_mii_senddata(sbm_mdio, regidx, 5);
 
-	sbmac_mii_senddata(s,MII_COMMAND_START, 2);
-	sbmac_mii_senddata(s,MII_COMMAND_READ, 2);
-	sbmac_mii_senddata(s,phyaddr, 5);
-	sbmac_mii_senddata(s,regidx, 5);
-
-	mac_mdio_genc = __raw_readq(s->sbm_mdio) & M_MAC_GENC;
+	mac_mdio_genc = __raw_readq(sbm_mdio) & M_MAC_GENC;
 
 	/*
 	 * Switch the port around without a clock transition.
 	 */
-	__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, s->sbm_mdio);
+	__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, sbm_mdio);
 
 	/*
 	 * Send out a clock pulse to signal we want the status
 	 */
-
-	__raw_writeq(M_MAC_MDIO_DIR_INPUT | M_MAC_MDC | mac_mdio_genc, s->sbm_mdio);
-	__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, s->sbm_mdio);
+	__raw_writeq(M_MAC_MDIO_DIR_INPUT | M_MAC_MDC | mac_mdio_genc,
+		     sbm_mdio);
+	__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, sbm_mdio);
 
 	/*
 	 * If an error occurred, the PHY will signal '1' back
 	 */
-	error = __raw_readq(s->sbm_mdio) & M_MAC_MDIO_IN;
+	error = __raw_readq(sbm_mdio) & M_MAC_MDIO_IN;
 
 	/*
 	 * Issue an 'idle' clock pulse, but keep the direction
 	 * the same.
 	 */
-	__raw_writeq(M_MAC_MDIO_DIR_INPUT | M_MAC_MDC | mac_mdio_genc, s->sbm_mdio);
-	__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, s->sbm_mdio);
+	__raw_writeq(M_MAC_MDIO_DIR_INPUT | M_MAC_MDC | mac_mdio_genc,
+		     sbm_mdio);
+	__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, sbm_mdio);
 
 	regval = 0;
 
@@ -602,55 +501,60 @@ static unsigned int sbmac_mii_read(struc
 		regval <<= 1;
 
 		if (error == 0) {
-			if (__raw_readq(s->sbm_mdio) & M_MAC_MDIO_IN)
+			if (__raw_readq(sbm_mdio) & M_MAC_MDIO_IN)
 				regval |= 1;
 		}
 
-		__raw_writeq(M_MAC_MDIO_DIR_INPUT|M_MAC_MDC | mac_mdio_genc, s->sbm_mdio);
-		__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, s->sbm_mdio);
+		__raw_writeq(M_MAC_MDIO_DIR_INPUT | M_MAC_MDC | mac_mdio_genc,
+			     sbm_mdio);
+		__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, sbm_mdio);
 	}
 
 	/* Switch back to output */
-	__raw_writeq(M_MAC_MDIO_DIR_OUTPUT | mac_mdio_genc, s->sbm_mdio);
+	__raw_writeq(M_MAC_MDIO_DIR_OUTPUT | mac_mdio_genc, sbm_mdio);
 
 	if (error == 0)
 		return regval;
-	return 0;
+	return 0xffff;
 }
 
 
 /**********************************************************************
- *  SBMAC_MII_WRITE(s,phyaddr,regidx,regval)
+ *  SBMAC_MII_WRITE(bus, phyaddr, regidx, regval)
  *
  *  Write a value to a PHY register.
  *
  *  Input parameters:
- *  	   s - sbmac structure
+ *  	   bus     - MDIO bus handle
  *  	   phyaddr - PHY to use
- *  	   regidx - register within the PHY
- *  	   regval - data to write to register
+ *  	   regidx  - register within the PHY
+ *  	   regval  - data to write to register
  *
  *  Return value:
- *  	   nothing
+ *  	   0 for success
  ********************************************************************* */
 
-static void sbmac_mii_write(struct sbmac_softc *s,int phyaddr,int regidx,
-			    unsigned int regval)
+static int sbmac_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
+			   u16 regval)
 {
+	struct sbmac_softc *sc = (struct sbmac_softc *)bus->priv;
+	volatile void __iomem *sbm_mdio = sc->sbm_mdio;
 	int mac_mdio_genc;
 
-	sbmac_mii_sync(s);
+	sbmac_mii_sync(sbm_mdio);
+
+	sbmac_mii_senddata(sbm_mdio, MII_COMMAND_START, 2);
+	sbmac_mii_senddata(sbm_mdio, MII_COMMAND_WRITE, 2);
+	sbmac_mii_senddata(sbm_mdio, phyaddr, 5);
+	sbmac_mii_senddata(sbm_mdio, regidx, 5);
+	sbmac_mii_senddata(sbm_mdio, MII_COMMAND_ACK, 2);
+	sbmac_mii_senddata(sbm_mdio, regval, 16);
 
-	sbmac_mii_senddata(s,MII_COMMAND_START,2);
-	sbmac_mii_senddata(s,MII_COMMAND_WRITE,2);
-	sbmac_mii_senddata(s,phyaddr, 5);
-	sbmac_mii_senddata(s,regidx, 5);
-	sbmac_mii_senddata(s,MII_COMMAND_ACK,2);
-	sbmac_mii_senddata(s,regval,16);
+	mac_mdio_genc = __raw_readq(sbm_mdio) & M_MAC_GENC;
 
-	mac_mdio_genc = __raw_readq(s->sbm_mdio) & M_MAC_GENC;
+	__raw_writeq(M_MAC_MDIO_DIR_OUTPUT | mac_mdio_genc, sbm_mdio);
 
-	__raw_writeq(M_MAC_MDIO_DIR_OUTPUT | mac_mdio_genc, s->sbm_mdio);
+	return 0;
 }
 
 
@@ -692,27 +596,27 @@ static void sbdma_initctx(sbmacdma_t *d,
 	s->sbe_idx =(s->sbm_base - A_MAC_BASE_0)/MAC_SPACING;
 #endif
 
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_TX_BYTES)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_COLLISIONS)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_LATE_COL)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_EX_COL)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_FCS_ERROR)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_TX_ABORT)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_TX_BAD)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_TX_GOOD)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_TX_RUNT)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_TX_OVERSIZE)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_BYTES)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_MCAST)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_BCAST)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_BAD)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_GOOD)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_RUNT)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_OVERSIZE)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_FCS_ERROR)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_LENGTH_ERROR)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_CODE_ERROR)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_ALIGN_ERROR)));
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_TX_BYTES);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_COLLISIONS);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_LATE_COL);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_EX_COL);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_FCS_ERROR);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_TX_ABORT);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_TX_BAD);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_TX_GOOD);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_TX_RUNT);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_TX_OVERSIZE);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_BYTES);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_MCAST);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_BCAST);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_BAD);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_GOOD);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_RUNT);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_OVERSIZE);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_FCS_ERROR);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_LENGTH_ERROR);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_CODE_ERROR);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_ALIGN_ERROR);
 
 	/*
 	 * initialize register pointers
@@ -927,7 +831,7 @@ static int sbdma_add_rcvbuffer(sbmacdma_
 	if (sb == NULL) {
 		sb_new = dev_alloc_skb(ENET_PACKET_SIZE + SMP_CACHE_BYTES * 2 + ETHER_ALIGN);
 		if (sb_new == NULL) {
-			printk(KERN_INFO "%s: sk_buff allocation failed\n",
+			pr_info("%s: sk_buff allocation failed\n",
 			       d->sbdma_eth->sbm_dev->name);
 			return -ENOBUFS;
 		}
@@ -1379,14 +1283,6 @@ static int sbmac_initctx(struct sbmac_so
 	s->sbm_imr       = s->sbm_base + R_MAC_INT_MASK;
 	s->sbm_mdio      = s->sbm_base + R_MAC_MDIO;
 
-	s->sbm_phys[0]   = 1;
-	s->sbm_phys[1]   = 0;
-
-	s->sbm_phy_oldbmsr = 0;
-	s->sbm_phy_oldanlpar = 0;
-	s->sbm_phy_oldk1stsr = 0;
-	s->sbm_phy_oldlinkstat = 0;
-
 	/*
 	 * Initialize the DMA channels.  Right now, only one per MAC is used
 	 * Note: Only do this _once_, as it allocates memory from the kernel!
@@ -1401,14 +1297,6 @@ static int sbmac_initctx(struct sbmac_so
 
 	s->sbm_state = sbmac_state_off;
 
-	/*
-	 * Initial speed is (XXX TEMP) 10MBit/s HDX no FC
-	 */
-
-	s->sbm_speed = sbmac_speed_10;
-	s->sbm_duplex = sbmac_duplex_half;
-	s->sbm_fc = sbmac_fc_disabled;
-
 	return 0;
 }
 
@@ -1921,8 +1809,6 @@ static int sbmac_set_speed(struct sbmac_
 		cfg |= V_MAC_SPEED_SEL_1000MBPS | M_MAC_BURST_EN;
 		break;
 
-	case sbmac_speed_auto:		/* XXX not implemented */
-		/* fall through */
 	default:
 		return 0;
 	}
@@ -1995,8 +1881,6 @@ static int sbmac_set_duplex(struct sbmac
 			cfg |= M_MAC_HDX_EN | V_MAC_FC_CMD_ENAB_FALSECARR;
 			break;
 
-		case sbmac_fc_auto:		/* XXX not implemented */
-			/* fall through */
 		case sbmac_fc_frame:		/* not valid in half duplex */
 		default:			/* invalid selection */
 			return 0;
@@ -2015,15 +1899,12 @@ static int sbmac_set_duplex(struct sbmac
 
 		case sbmac_fc_collision:	/* not valid in full duplex */
 		case sbmac_fc_carrier:		/* not valid in full duplex */
-		case sbmac_fc_auto:		/* XXX not implemented */
-			/* fall through */
 		default:
 			return 0;
 		}
 		break;
-	case sbmac_duplex_auto:
-		/* XXX not implemented */
-		break;
+	default:
+		return 0;
 	}
 
 	/*
@@ -2322,7 +2203,7 @@ static int sb1250_change_mtu(struct net_
 	if (new_mtu >  ENET_PACKET_SIZE)
 		return -EINVAL;
 	_dev->mtu = new_mtu;
-	printk(KERN_INFO "changing the mtu to %d\n", new_mtu);
+	pr_info("changing the mtu to %d\n", new_mtu);
 	return 0;
 }
 
@@ -2338,19 +2219,16 @@ static int sb1250_change_mtu(struct net_
  *  	   status
  ********************************************************************* */
 
-static int sbmac_init(struct net_device *dev, int idx)
+static int sbmac_init(struct platform_device *pldev, long long base)
 {
-	struct sbmac_softc *sc;
+	struct net_device *dev = pldev->dev.driver_data;
+	int idx = pldev->id;
+	struct sbmac_softc *sc = netdev_priv(dev);
 	unsigned char *eaddr;
 	uint64_t ea_reg;
 	int i;
 	int err;
 
-	sc = netdev_priv(dev);
-
-	/* Determine controller base address */
-
-	sc->sbm_base = IOADDR(dev->base_addr);
 	sc->sbm_dev = dev;
 	sc->sbe_idx = idx;
 
@@ -2403,45 +2281,57 @@ static int sbmac_init(struct net_device 
 
 	dev->change_mtu         = sb1250_change_mtu;
 
+	dev->irq		= UNIT_INT(idx);
+
 	/* This is needed for PASS2 for Rx H/W checksum feature */
 	sbmac_set_iphdr_offset(sc);
 
 	err = register_netdev(dev);
-	if (err)
-		goto out_uninit;
-
-	if (sc->rx_hw_checksum == ENABLE) {
-		printk(KERN_INFO "%s: enabling TCP rcv checksum\n",
-			sc->sbm_dev->name);
+	if (err) {
+		printk(KERN_ERR "%s.%d: unable to register netdev\n",
+		       sbmac_string, idx);
+		sbmac_uninitctx(sc);
+		return err;
 	}
 
+	pr_info("%s.%d: registered as %s\n", sbmac_string, idx, dev->name);
+
+	if (sc->rx_hw_checksum == ENABLE)
+		pr_info("%s: enabling TCP rcv checksum\n", dev->name);
+
 	/*
 	 * Display Ethernet address (this is called during the config
 	 * process so we need to finish off the config message that
 	 * was being displayed)
 	 */
-	printk(KERN_INFO
-	       "%s: SiByte Ethernet at 0x%08lX, address: %02X:%02X:%02X:%02X:%02X:%02X\n",
-	       dev->name, dev->base_addr,
-	       eaddr[0],eaddr[1],eaddr[2],eaddr[3],eaddr[4],eaddr[5]);
+	pr_info("%s: SiByte Ethernet at 0x%08Lx, "
+		"address: %02X:%02X:%02X:%02X:%02X:%02X\n",
+		dev->name, base,
+		eaddr[0], eaddr[1], eaddr[2], eaddr[3], eaddr[4], eaddr[5]);
+
+	sc->mii_bus.name = sbmac_mdio_string;
+	sc->mii_bus.id = idx;
+	sc->mii_bus.priv = sc;
+	sc->mii_bus.read = sbmac_mii_read;
+	sc->mii_bus.write = sbmac_mii_write;
+	sc->mii_bus.irq = sc->phy_irq;
+	for (i = 0; i < PHY_MAX_ADDR; ++i)
+		sc->mii_bus.irq[i] = SBMAC_PHY_INT;
 
+	sc->mii_bus.dev = &pldev->dev;
+	dev_set_drvdata(&pldev->dev, &sc->mii_bus);
 
 	return 0;
-
-out_uninit:
-	sbmac_uninitctx(sc);
-
-	return err;
 }
 
 
 static int sbmac_open(struct net_device *dev)
 {
 	struct sbmac_softc *sc = netdev_priv(dev);
+	int err;
 
-	if (debug > 1) {
-		printk(KERN_DEBUG "%s: sbmac_open() irq %d.\n", dev->name, dev->irq);
-	}
+	if (debug > 1)
+		pr_debug("%s: sbmac_open() irq %d.\n", dev->name, dev->irq);
 
 	/*
 	 * map/route interrupt (clear status first, in case something
@@ -2450,224 +2340,177 @@ static int sbmac_open(struct net_device 
 	 */
 
 	__raw_readq(sc->sbm_isr);
-	if (request_irq(dev->irq, &sbmac_intr, IRQF_SHARED, dev->name, dev))
-		return -EBUSY;
+	err = request_irq(dev->irq, &sbmac_intr, IRQF_SHARED, dev->name, dev);
+	if (err) {
+		printk(KERN_ERR "%s: unable to get IRQ %d\n", dev->name,
+		       dev->irq);
+		goto out_err;
+	}
 
 	/*
-	 * Probe phy address
+	 * Sanity check whether a possible previous call
+	 * to sbmac_close() has fully concluded.
 	 */
-
-	if(sbmac_mii_probe(dev) == -1) {
-		printk("%s: failed to probe PHY.\n", dev->name);
-		return -EINVAL;
+	if (sc->phy_dev) {
+		printk(KERN_ERR "%s: PHY still in use\n", dev->name);
+		return -EBUSY;
 	}
 
 	/*
-	 * Configure default speed
+	 * Probe PHY address
 	 */
+	err = mdiobus_register(&sc->mii_bus);
+	if (err) {
+		printk(KERN_ERR "%s: unable to register MDIO bus\n",
+		       dev->name);
+		goto out_unirq;
+	}
 
-	sbmac_mii_poll(sc,noisy_mii);
+	sc->sbm_speed = sbmac_speed_none;
+	sc->sbm_duplex = sbmac_duplex_none;
+	sc->sbm_fc = sbmac_fc_none;
+	sc->sbm_pause = -1;
+	sc->sbm_link = 0;
 
 	/*
-	 * Turn on the channel
+	 * Attach to the PHY
 	 */
-
-	sbmac_set_channel_state(sc,sbmac_state_on);
+	err = sbmac_mii_probe(dev);
+	if (err)
+		goto out_unregister;
 
 	/*
-	 * XXX Station address is in dev->dev_addr
+	 * Turn on the channel
 	 */
 
-	if (dev->if_port == 0)
-		dev->if_port = 0;
+	sbmac_set_channel_state(sc,sbmac_state_on);
 
 	netif_start_queue(dev);
 
 	sbmac_set_rx_mode(dev);
 
-	/* Set the timer to check for link beat. */
-	init_timer(&sc->sbm_timer);
-	sc->sbm_timer.expires = jiffies + 2 * HZ/100;
-	sc->sbm_timer.data = (unsigned long)dev;
-	sc->sbm_timer.function = &sbmac_timer;
-	add_timer(&sc->sbm_timer);
+	phy_start(sc->phy_dev);
 
 	return 0;
+
+out_unregister:
+	mdiobus_unregister(&sc->mii_bus);
+
+out_unirq:
+	free_irq(dev->irq, dev);
+
+out_err:
+	return err;
 }
 
 static int sbmac_mii_probe(struct net_device *dev)
 {
+	struct sbmac_softc *sc = netdev_priv(dev);
+	struct phy_device *phy_dev;
 	int i;
-	struct sbmac_softc *s = netdev_priv(dev);
-	u16 bmsr, id1, id2;
-	u32 vendor, device;
-
-	for (i=1; i<31; i++) {
-	bmsr = sbmac_mii_read(s, i, MII_BMSR);
-		if (bmsr != 0) {
-			s->sbm_phys[0] = i;
-			id1 = sbmac_mii_read(s, i, MII_PHYIDR1);
-			id2 = sbmac_mii_read(s, i, MII_PHYIDR2);
-			vendor = ((u32)id1 << 6) | ((id2 >> 10) & 0x3f);
-			device = (id2 >> 4) & 0x3f;
-
-			printk(KERN_INFO "%s: found phy %d, vendor %06x part %02x\n",
-				dev->name, i, vendor, device);
-			return i;
-		}
-	}
-	return -1;
-}
 
+	INIT_WORK(&sc->sbm_queue, sbmac_phy_disconnect, sc);
 
-static int sbmac_mii_poll(struct sbmac_softc *s,int noisy)
-{
-    int bmsr,bmcr,k1stsr,anlpar;
-    int chg;
-    char buffer[100];
-    char *p = buffer;
-
-    /* Read the mode status and mode control registers. */
-    bmsr = sbmac_mii_read(s,s->sbm_phys[0],MII_BMSR);
-    bmcr = sbmac_mii_read(s,s->sbm_phys[0],MII_BMCR);
-
-    /* get the link partner status */
-    anlpar = sbmac_mii_read(s,s->sbm_phys[0],MII_ANLPAR);
-
-    /* if supported, read the 1000baseT register */
-    if (bmsr & BMSR_1000BT_XSR) {
-	k1stsr = sbmac_mii_read(s,s->sbm_phys[0],MII_K1STSR);
-	}
-    else {
-	k1stsr = 0;
+	for (i = 0; i < PHY_MAX_ADDR; i++) {
+		phy_dev = sc->mii_bus.phy_map[i];
+		if (phy_dev)
+			break;
 	}
+	if (!phy_dev) {
+		printk(KERN_ERR "%s: no PHY found\n", dev->name);
+		return -ENXIO;
+	}
+
+	phy_dev = phy_connect(dev, phy_dev->dev.bus_id, &sbmac_mii_poll, 0);
+	if (IS_ERR(phy_dev)) {
+		printk(KERN_ERR "%s: could not attach to PHY\n", dev->name);
+		return PTR_ERR(phy_dev);
+	}
+
+	/* Remove any features not supported by the controller */
+	phy_dev->supported &= SUPPORTED_10baseT_Half |
+			      SUPPORTED_10baseT_Full |
+			      SUPPORTED_100baseT_Half |
+			      SUPPORTED_100baseT_Full |
+			      SUPPORTED_1000baseT_Half |
+			      SUPPORTED_1000baseT_Full |
+			      SUPPORTED_Autoneg |
+			      SUPPORTED_MII |
+			      SUPPORTED_Pause |
+			      SUPPORTED_Asym_Pause;
+	phy_dev->advertising = phy_dev->supported;
+
+	pr_info("%s: attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
+		dev->name, phy_dev->drv->name,
+		phy_dev->dev.bus_id, phy_dev->irq);
 
-    chg = 0;
+	sc->phy_dev = phy_dev;
 
-    if ((bmsr & BMSR_LINKSTAT) == 0) {
-	/*
-	 * If link status is down, clear out old info so that when
-	 * it comes back up it will force us to reconfigure speed
-	 */
-	s->sbm_phy_oldbmsr = 0;
-	s->sbm_phy_oldanlpar = 0;
-	s->sbm_phy_oldk1stsr = 0;
 	return 0;
-	}
-
-    if ((s->sbm_phy_oldbmsr != bmsr) ||
-	(s->sbm_phy_oldanlpar != anlpar) ||
-	(s->sbm_phy_oldk1stsr != k1stsr)) {
-	if (debug > 1) {
-	    printk(KERN_DEBUG "%s: bmsr:%x/%x anlpar:%x/%x  k1stsr:%x/%x\n",
-	       s->sbm_dev->name,
-	       s->sbm_phy_oldbmsr,bmsr,
-	       s->sbm_phy_oldanlpar,anlpar,
-	       s->sbm_phy_oldk1stsr,k1stsr);
-	    }
-	s->sbm_phy_oldbmsr = bmsr;
-	s->sbm_phy_oldanlpar = anlpar;
-	s->sbm_phy_oldk1stsr = k1stsr;
-	chg = 1;
-	}
-
-    if (chg == 0)
-	    return 0;
-
-    p += sprintf(p,"Link speed: ");
-
-    if (k1stsr & K1STSR_LP1KFD) {
-	s->sbm_speed = sbmac_speed_1000;
-	s->sbm_duplex = sbmac_duplex_full;
-	s->sbm_fc = sbmac_fc_frame;
-	p += sprintf(p,"1000BaseT FDX");
-	}
-    else if (k1stsr & K1STSR_LP1KHD) {
-	s->sbm_speed = sbmac_speed_1000;
-	s->sbm_duplex = sbmac_duplex_half;
-	s->sbm_fc = sbmac_fc_disabled;
-	p += sprintf(p,"1000BaseT HDX");
-	}
-    else if (anlpar & ANLPAR_TXFD) {
-	s->sbm_speed = sbmac_speed_100;
-	s->sbm_duplex = sbmac_duplex_full;
-	s->sbm_fc = (anlpar & ANLPAR_PAUSE) ? sbmac_fc_frame : sbmac_fc_disabled;
-	p += sprintf(p,"100BaseT FDX");
-	}
-    else if (anlpar & ANLPAR_TXHD) {
-	s->sbm_speed = sbmac_speed_100;
-	s->sbm_duplex = sbmac_duplex_half;
-	s->sbm_fc = sbmac_fc_disabled;
-	p += sprintf(p,"100BaseT HDX");
-	}
-    else if (anlpar & ANLPAR_10FD) {
-	s->sbm_speed = sbmac_speed_10;
-	s->sbm_duplex = sbmac_duplex_full;
-	s->sbm_fc = sbmac_fc_frame;
-	p += sprintf(p,"10BaseT FDX");
-	}
-    else if (anlpar & ANLPAR_10HD) {
-	s->sbm_speed = sbmac_speed_10;
-	s->sbm_duplex = sbmac_duplex_half;
-	s->sbm_fc = sbmac_fc_collision;
-	p += sprintf(p,"10BaseT HDX");
-	}
-    else {
-	p += sprintf(p,"Unknown");
-	}
-
-    if (noisy) {
-	    printk(KERN_INFO "%s: %s\n",s->sbm_dev->name,buffer);
-	    }
-
-    return 1;
 }
 
 
-static void sbmac_timer(unsigned long data)
+static void sbmac_mii_poll(struct net_device *dev)
 {
-	struct net_device *dev = (struct net_device *)data;
 	struct sbmac_softc *sc = netdev_priv(dev);
-	int next_tick = HZ;
-	int mii_status;
-
-	spin_lock_irq (&sc->sbm_lock);
-
-	/* make IFF_RUNNING follow the MII status bit "Link established" */
-	mii_status = sbmac_mii_read(sc, sc->sbm_phys[0], MII_BMSR);
+	struct phy_device *phy_dev = sc->phy_dev;
+	unsigned long flags;
+	sbmac_fc_t fc;
+	int link_chg, speed_chg, duplex_chg, pause_chg, fc_chg;
 
-	if ( (mii_status & BMSR_LINKSTAT) != (sc->sbm_phy_oldlinkstat) ) {
-    	        sc->sbm_phy_oldlinkstat = mii_status & BMSR_LINKSTAT;
-		if (mii_status & BMSR_LINKSTAT) {
-			netif_carrier_on(dev);
-		}
-		else {
-			netif_carrier_off(dev);
+	link_chg = (sc->sbm_link != phy_dev->link);
+	speed_chg = (sc->sbm_speed != phy_dev->speed);
+	duplex_chg = (sc->sbm_duplex != phy_dev->duplex);
+	pause_chg = (sc->sbm_pause != phy_dev->pause);
+
+	if (!link_chg && !speed_chg && !duplex_chg && !pause_chg)
+		return;					/* Hmmm... */
+
+	if (!phy_dev->link) {
+		if (link_chg) {
+			sc->sbm_link = phy_dev->link;
+			sc->sbm_speed = sbmac_speed_none;
+			sc->sbm_duplex = sbmac_duplex_none;
+			sc->sbm_fc = sbmac_fc_disabled;
+			sc->sbm_pause = -1;
+			pr_info("%s: link unavailable\n", dev->name);
 		}
+		return;
 	}
 
-	/*
-	 * Poll the PHY to see what speed we should be running at
-	 */
+	if (phy_dev->duplex == DUPLEX_FULL) {
+		if (phy_dev->pause)
+			fc = sbmac_fc_frame;
+		else
+			fc = sbmac_fc_disabled;
+	} else
+		fc = sbmac_fc_collision;
+	fc_chg = (sc->sbm_fc != fc);
 
-	if (sbmac_mii_poll(sc,noisy_mii)) {
-		if (sc->sbm_state != sbmac_state_off) {
-			/*
-			 * something changed, restart the channel
-			 */
-			if (debug > 1) {
-				printk("%s: restarting channel because speed changed\n",
-				       sc->sbm_dev->name);
-			}
-			sbmac_channel_stop(sc);
-			sbmac_channel_start(sc);
-		}
-	}
+	pr_info("%s: link available: %dbase-%cD\n", dev->name, phy_dev->speed,
+		phy_dev->duplex == DUPLEX_FULL ? 'F' : 'H');
 
-	spin_unlock_irq (&sc->sbm_lock);
+	spin_lock_irqsave(&sc->sbm_lock, flags);
+
+	sc->sbm_speed = phy_dev->speed;
+	sc->sbm_duplex = phy_dev->duplex;
+	sc->sbm_fc = fc;
+	sc->sbm_pause = phy_dev->pause;
+	sc->sbm_link = phy_dev->link;
 
-	sc->sbm_timer.expires = jiffies + next_tick;
-	add_timer(&sc->sbm_timer);
+	if ((speed_chg || duplex_chg || fc_chg) &&
+	    sc->sbm_state != sbmac_state_off) {
+		/*
+		 * something changed, restart the channel
+		 */
+		if (debug > 1)
+			pr_debug("%s: restarting channel "
+				 "because PHY state changed\n", dev->name);
+		sbmac_channel_stop(sc);
+		sbmac_channel_start(sc);
+	}
+
+	spin_unlock_irqrestore(&sc->sbm_lock, flags);
 }
 
 
@@ -2745,62 +2588,39 @@ static void sbmac_set_rx_mode(struct net
 static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct sbmac_softc *sc = netdev_priv(dev);
-	u16 *data = (u16 *)&rq->ifr_ifru;
-	unsigned long flags;
-	int retval;
 
-	spin_lock_irqsave(&sc->sbm_lock, flags);
-	retval = 0;
+	if (!netif_running(dev) || !sc->phy_dev)
+		return -EINVAL;
 
-	switch(cmd) {
-	case SIOCDEVPRIVATE:		/* Get the address of the PHY in use. */
-		data[0] = sc->sbm_phys[0] & 0x1f;
-		/* Fall Through */
-	case SIOCDEVPRIVATE+1:		/* Read the specified MII register. */
-		data[3] = sbmac_mii_read(sc, data[0] & 0x1f, data[1] & 0x1f);
-		break;
-	case SIOCDEVPRIVATE+2:		/* Write the specified MII register */
-		if (!capable(CAP_NET_ADMIN)) {
-			retval = -EPERM;
-			break;
-		}
-		if (debug > 1) {
-		    printk(KERN_DEBUG "%s: sbmac_mii_ioctl: write %02X %02X %02X\n",dev->name,
-		       data[0],data[1],data[2]);
-		    }
-		sbmac_mii_write(sc, data[0] & 0x1f, data[1] & 0x1f, data[2]);
-		break;
-	default:
-		retval = -EOPNOTSUPP;
-	}
+	return phy_mii_ioctl(sc->phy_dev, if_mii(rq), cmd);
+}
 
-	spin_unlock_irqrestore(&sc->sbm_lock, flags);
-	return retval;
+static void sbmac_phy_disconnect(void *data)
+{
+	struct sbmac_softc *sc = data;
+
+	phy_disconnect(sc->phy_dev);
+	mdiobus_unregister(&sc->mii_bus);
+	sc->phy_dev = NULL;
 }
 
 static int sbmac_close(struct net_device *dev)
 {
 	struct sbmac_softc *sc = netdev_priv(dev);
-	unsigned long flags;
-	int irq;
 
-	sbmac_set_channel_state(sc,sbmac_state_off);
+	phy_stop(sc->phy_dev);
 
-	del_timer_sync(&sc->sbm_timer);
-
-	spin_lock_irqsave(&sc->sbm_lock, flags);
+	sbmac_set_channel_state(sc, sbmac_state_off);
 
 	netif_stop_queue(dev);
 
-	if (debug > 1) {
-		printk(KERN_DEBUG "%s: Shutting down ethercard\n",dev->name);
-	}
+	if (debug > 1)
+		pr_debug("%s: Shutting down ethercard\n",dev->name);
 
-	spin_unlock_irqrestore(&sc->sbm_lock, flags);
+	/* Cannot call phy_disconnect() here because of rtnl_lock().  */
+	schedule_work(&sc->sbm_queue);
 
-	irq = dev->irq;
-	synchronize_irq(irq);
-	free_irq(irq, dev);
+	free_irq(dev->irq, dev);
 
 	sbdma_emptyring(&(sc->sbm_txdma));
 	sbdma_emptyring(&(sc->sbm_rxdma));
@@ -2809,55 +2629,195 @@ static int sbmac_close(struct net_device
 }
 
 
+static int __init sbmac_probe(struct platform_device *pldev)
+{
+	struct net_device *dev;
+	struct sbmac_softc *sc;
+	volatile void __iomem *sbm_base;
+	struct resource *res;
+	u64 sbmac_orig_hwaddr;
+	int err;
+
+	res = platform_get_resource(pldev, IORESOURCE_MEM, 0);
+	BUG_ON(!res);
+	sbm_base = ioremap_nocache(res->start, res->end - res->start + 1);
+	if (!sbm_base) {
+		printk(KERN_ERR "%s: unable to map device registers\n",
+		       pldev->dev.bus_id);
+		err = -ENOMEM;
+		goto out_out;
+	}
+
+	/*
+	 * The R_MAC_ETHERNET_ADDR register will be set to some nonzero
+	 * value for us by the firmware if we're going to use this MAC.
+	 * If we find a zero, skip this MAC.
+	 */
+	sbmac_orig_hwaddr = __raw_readq(sbm_base + R_MAC_ETHERNET_ADDR);
+	pr_debug("%s: %sconfiguring MAC at 0x%08Lx\n", pldev->dev.bus_id,
+		 sbmac_orig_hwaddr ? "" : "not ", (long long)res->start);
+	if (sbmac_orig_hwaddr == 0) {
+		err = 0;
+		goto out_unmap;
+	}
+
+	/*
+	 * Okay, cool.  Initialize this MAC.
+	 */
+	dev = alloc_etherdev(sizeof(struct sbmac_softc));
+	if (!dev) {
+		printk(KERN_ERR "%s: unable to allocate etherdev\n",
+		       pldev->dev.bus_id);
+		err = -ENOMEM;
+		goto out_unmap;
+	}
+
+	pldev->dev.driver_data = dev;
+	SET_NETDEV_DEV(dev, &pldev->dev);
+
+	sc = netdev_priv(dev);
+	sc->sbm_base = sbm_base;
+
+	err = sbmac_init(pldev, res->start);
+	if (err)
+		goto out_kfree;
+
+	return 0;
+
+out_kfree:
+	free_netdev(dev);
+	__raw_writeq(sbmac_orig_hwaddr, sbm_base + R_MAC_ETHERNET_ADDR);
+
+out_unmap:
+	iounmap(sbm_base);
+
+out_out:
+	return err;
+}
+
+static int __exit sbmac_remove(struct platform_device *pldev)
+{
+	struct net_device *dev = pldev->dev.driver_data;
+	struct sbmac_softc *sc = netdev_priv(dev);
+
+	unregister_netdev(dev);
+	flush_scheduled_work();			/* Finish any pending work.  */
+	sbmac_uninitctx(sc);
+	iounmap(sc->sbm_base);
+	free_netdev(dev);
+
+	return 0;
+}
+
+
+static struct platform_device **sbmac_pldev;
+static int sbmac_max_units __initdata;
 
 #if defined(SBMAC_ETH0_HWADDR) || defined(SBMAC_ETH1_HWADDR) || defined(SBMAC_ETH2_HWADDR) || defined(SBMAC_ETH3_HWADDR)
-static void
-sbmac_setup_hwaddr(int chan,char *addr)
+static void sbmac_setup_hwaddr(int idx, char *addr)
 {
+	volatile void __iomem *sbm_base;
+	unsigned long start, end;
 	uint8_t eaddr[6];
 	uint64_t val;
-	unsigned long port;
 
-	port = A_MAC_CHANNEL_BASE(chan);
-	sbmac_parse_hwaddr(addr,eaddr);
+	if (idx >= sbmac_max_units)
+		return;
+
+	start = A_MAC_CHANNEL_BASE(idx);
+	end = A_MAC_CHANNEL_BASE(idx + 1) - 1;
+
+	sbm_base = ioremap_nocache(start, end - start + 1);
+	if (!sbm_base) {
+		printk(KERN_ERR "%s: unable to map device registers\n",
+		       sbmac_string);
+		return
+	}
+
+	sbmac_parse_hwaddr(addr, eaddr);
 	val = sbmac_addr2reg(eaddr);
-	__raw_writeq(val, IOADDR(port+R_MAC_ETHERNET_ADDR));
-	val = __raw_readq(IOADDR(port+R_MAC_ETHERNET_ADDR));
+	__raw_writeq(val, sbm_base + R_MAC_ETHERNET_ADDR);
+	val = __raw_readq(sbm_base + R_MAC_ETHERNET_ADDR);
+
+	iounmap(sbm_base);
 }
 #endif
 
-static struct net_device *dev_sbmac[MAX_UNITS];
+static int __init sbmac_platform_probe_one(int idx)
+{
+	struct platform_device *pldev;
+	struct {
+		struct resource r;
+		char name[strlen(sbmac_pretty) + 4];
+	} *res;
+	int err;
+
+	res = kzalloc(sizeof(*res), GFP_KERNEL);
+	if (!res) {
+		printk(KERN_ERR "%s.%d: unable to allocate memory\n",
+		       sbmac_string, idx);
+		err = -ENOMEM;
+		goto out_err;
+	}
+
+	/*
+	 * This is the base address of the MAC.
+	 */
+	snprintf(res->name, sizeof(res->name), "%s %d", sbmac_pretty, idx);
+	res->r.name = res->name;
+	res->r.flags = IORESOURCE_MEM;
+	res->r.start = A_MAC_CHANNEL_BASE(idx);
+	res->r.end = A_MAC_CHANNEL_BASE(idx + 1) - 1;
+
+	pldev = platform_device_register_simple(sbmac_string, idx, &res->r, 1);
+	if (IS_ERR(pldev)) {
+		printk(KERN_ERR "%s.%d: unable to register platform device\n",
+		       sbmac_string, idx);
+		err = PTR_ERR(pldev);
+		goto out_kfree;
+	}
+
+	if (!pldev->dev.driver) {
+		err = 0;		/* No hardware at this address. */
+		goto out_unregister;
+	}
+
+	sbmac_pldev[idx] = pldev;
+	return 0;
+
+out_unregister:
+	platform_device_unregister(pldev);
+
+out_kfree:
+	kfree(res);
+
+out_err:
+	return err;
+}
 
-static int __init
-sbmac_init_module(void)
+static void __init sbmac_platform_probe(void)
 {
-	int idx;
-	struct net_device *dev;
-	unsigned long port;
-	int chip_max_units;
+	int i;
 
 	/* Set the number of available units based on the SOC type.  */
 	switch (soc_type) {
 	case K_SYS_SOC_TYPE_BCM1250:
 	case K_SYS_SOC_TYPE_BCM1250_ALT:
-		chip_max_units = 3;
+		sbmac_max_units = 3;
 		break;
 	case K_SYS_SOC_TYPE_BCM1120:
 	case K_SYS_SOC_TYPE_BCM1125:
 	case K_SYS_SOC_TYPE_BCM1125H:
-	case K_SYS_SOC_TYPE_BCM1250_ALT2: /* Hybrid */
-		chip_max_units = 2;
+	case K_SYS_SOC_TYPE_BCM1250_ALT2:	/* Hybrid */
+		sbmac_max_units = 2;
 		break;
 	case K_SYS_SOC_TYPE_BCM1x55:
 	case K_SYS_SOC_TYPE_BCM1x80:
-		chip_max_units = 4;
+		sbmac_max_units = 4;
 		break;
 	default:
-		chip_max_units = 0;
-		break;
+		return;				/* none */
 	}
-	if (chip_max_units > MAX_UNITS)
-		chip_max_units = MAX_UNITS;
 
 	/*
 	 * For bringup when not using the firmware, we can pre-fill
@@ -2865,89 +2825,70 @@ sbmac_init_module(void)
 	 * specified in this file (or maybe from the config file?)
 	 */
 #ifdef SBMAC_ETH0_HWADDR
-	if (chip_max_units > 0)
-	  sbmac_setup_hwaddr(0,SBMAC_ETH0_HWADDR);
+	sbmac_setup_hwaddr(0, SBMAC_ETH0_HWADDR);
 #endif
 #ifdef SBMAC_ETH1_HWADDR
-	if (chip_max_units > 1)
-	  sbmac_setup_hwaddr(1,SBMAC_ETH1_HWADDR);
+	sbmac_setup_hwaddr(1, SBMAC_ETH1_HWADDR);
 #endif
 #ifdef SBMAC_ETH2_HWADDR
-	if (chip_max_units > 2)
-	  sbmac_setup_hwaddr(2,SBMAC_ETH2_HWADDR);
+	sbmac_setup_hwaddr(2, SBMAC_ETH2_HWADDR);
 #endif
 #ifdef SBMAC_ETH3_HWADDR
-	if (chip_max_units > 3)
-	  sbmac_setup_hwaddr(3,SBMAC_ETH3_HWADDR);
+	sbmac_setup_hwaddr(3, SBMAC_ETH3_HWADDR);
 #endif
 
+	sbmac_pldev = kzalloc(sbmac_max_units * sizeof(*sbmac_pldev),
+			      GFP_KERNEL);
+	if (!sbmac_pldev) {
+		printk(KERN_ERR "%s: unable to allocate memory\n",
+		       sbmac_string);
+		return;
+	}
+
 	/*
 	 * Walk through the Ethernet controllers and find
 	 * those who have their MAC addresses set.
 	 */
-	for (idx = 0; idx < chip_max_units; idx++) {
+	for (i = 0; i < sbmac_max_units; i++)
+		if (sbmac_platform_probe_one(i))
+			break;
+}
 
-	        /*
-	         * This is the base address of the MAC.
-		 */
 
-	        port = A_MAC_CHANNEL_BASE(idx);
+static void __exit sbmac_platform_cleanup(void)
+{
+	int i;
 
-		/*
-		 * The R_MAC_ETHERNET_ADDR register will be set to some nonzero
-		 * value for us by the firmware if we're going to use this MAC.
-		 * If we find a zero, skip this MAC.
-		 */
+	for (i = 0; i < sbmac_max_units; i++)
+		platform_device_unregister(sbmac_pldev[i]);
+}
 
-		sbmac_orig_hwaddr[idx] = __raw_readq(IOADDR(port+R_MAC_ETHERNET_ADDR));
-		if (sbmac_orig_hwaddr[idx] == 0) {
-			printk(KERN_DEBUG "sbmac: not configuring MAC at "
-			       "%lx\n", port);
-		    continue;
-		}
 
-		/*
-		 * Okay, cool.  Initialize this MAC.
-		 */
+static struct platform_driver sbmac_driver = {
+	.probe = sbmac_probe,
+	.remove = __exit_p(sbmac_remove),
+	.driver = {
+		.name = sbmac_string,
+	},
+};
 
-		dev = alloc_etherdev(sizeof(struct sbmac_softc));
-		if (!dev)
-			return -ENOMEM;	/* return ENOMEM */
-
-		printk(KERN_DEBUG "sbmac: configuring MAC at %lx\n", port);
-
-		dev->irq = UNIT_INT(idx);
-		dev->base_addr = port;
-		dev->mem_end = 0;
-		if (sbmac_init(dev, idx)) {
-			port = A_MAC_CHANNEL_BASE(idx);
-			__raw_writeq(sbmac_orig_hwaddr[idx], IOADDR(port+R_MAC_ETHERNET_ADDR));
-			free_netdev(dev);
-			continue;
-		}
-		dev_sbmac[idx] = dev;
-	}
-	return 0;
-}
+static int __init sbmac_init_module(void)
+{
+	int err;
 
+	err = platform_driver_register(&sbmac_driver);
+	if (err)
+		return err;
 
-static void __exit
-sbmac_cleanup_module(void)
-{
-	struct net_device *dev;
-	int idx;
+	sbmac_platform_probe();
 
-	for (idx = 0; idx < MAX_UNITS; idx++) {
-		struct sbmac_softc *sc;
-		dev = dev_sbmac[idx];
-		if (!dev)
-			continue;
+	return err;
+}
 
-		sc = netdev_priv(dev);
-		unregister_netdev(dev);
-		sbmac_uninitctx(sc);
-		free_netdev(dev);
-	}
+static void __exit sbmac_cleanup_module(void)
+{
+	sbmac_platform_cleanup();
+	platform_driver_unregister(&sbmac_driver);
 }
 
 module_init(sbmac_init_module);
