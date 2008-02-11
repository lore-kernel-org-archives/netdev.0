From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Mon, 11 Feb 2008 12:05:16 -0500
Message-ID: <20080211170516.GA13872@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:44812 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbYBKRFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 12:05:18 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mostly fixes, a few cleanups (generally assisting fixes), and an
exception for PS3 wireless because it had been posted, reviewed and
acked for a while, just not committed.

Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 drivers/net/8139too.c            |    2 +-
 drivers/net/Kconfig              |   18 +
 drivers/net/Makefile             |    3 +-
 drivers/net/cxgb3/l2t.c          |    2 +-
 drivers/net/cxgb3/sge.c          |   35 +-
 drivers/net/dm9000.c             |  654 ++++++----
 drivers/net/e1000/e1000_main.c   |   18 +-
 drivers/net/forcedeth.c          |  132 ++-
 drivers/net/ni52.c               | 1142 ++++++++--------
 drivers/net/ni52.h               |  158 ++--
 drivers/net/pcnet32.c            |   48 +-
 drivers/net/phy/fixed.c          |    4 +-
 drivers/net/ps3_gelic_net.c      | 1215 ++++++++++-------
 drivers/net/ps3_gelic_net.h      |  415 ++++--
 drivers/net/ps3_gelic_wireless.c | 2753 ++++++++++++++++++++++++++++++++++++++
 drivers/net/ps3_gelic_wireless.h |  329 +++++
 drivers/net/r6040.c              |  233 ++--
 drivers/net/sis190.c             |    3 +-
 drivers/s390/net/claw.h          |   19 +-
 drivers/s390/net/lcs.c           |    2 +-
 drivers/s390/net/lcs.h           |   16 +-
 drivers/s390/net/netiucv.c       |   29 +-
 include/linux/dm9000.h           |    2 +
 23 files changed, 5440 insertions(+), 1792 deletions(-)
 create mode 100644 drivers/net/ps3_gelic_wireless.c
 create mode 100644 drivers/net/ps3_gelic_wireless.h

Adrian Bunk (1):
      net/phy/fixed.c: fix a use-after-free

Adrian McMenamin (1):
      8139too fix for Dreamcast

Alan Cox (1):
      ni52: Remove 278 scripts/checkpatch errors

Ayaz Abdulla (2):
      forcedeth: tx collision fix
      forcedeth: tx pause watermarks

Ben Dooks (24):
      DM9000: Fix endian-ness of data accesses.
      DM9000: Add platform data to specify external phy
      DM9000 use dev_xxx() instead of printk for output.
      DM9000 update debugging macros to use debug level
      DM9000: Pass IRQ flags via platform resources
      DM9000: Remove old timer based poll routines
      DM9000: Add initial ethtool support
      DM9000: Do not sleep with spinlock and IRQs held
      DM9000: Use msleep() instead of udelay()
      DM9000: Remove barely used SROM array read.
      DM9000: Add mutex to protect access
      DM9000: Add ethtool support for reading and writing EEPROM
      DM9000: Add ethtool control of msg_enable value
      DM9000: Remove EEPROM initialisation code.
      DM9000: Ensure spinlock held whilst accessing EEPROM registers
      DM9000: Remove unnecessary changelog in header comment
      DM9000: Use netif_msg to enable debugging options
      DM9000: Fix delays used by EEPROM read and write
      DM9000: Remove cal_CRC() and use ether_crc_le instead
      DM9000: Remove redudant use of "& 0xff"
      DM9000: Add platform flag for no attached EEPROM
      DM9000: Add support for MII ioctl() calls
      DM9000: Update retry count whilst identifying chip
      DM9000: Show the MAC address source after printing MAC

Benjamin Herrenschmidt (1):
      e1000: Fix for 32 bits platforms with 64 bits resources

Cornelia Huck (1):
      netiucv: Remember to set driver->owner.

Don Fry (2):
      pcnet32: use NET_IP_ALIGN instead of 2
      pcnet32: Use print_mac

Florian Fainelli (4):
      r6040: do not use a private stats structure to store statistics
      r6040: add helpers to allocate and free the Tx/Rx buffers
      r6040: recover from transmit timeout
      r6040: cleanups

Krishna Kumar (1):
      Optimize cxgb3 xmit path (a bit)

Masakazu Mokuno (7):
      PS3: gelic: Fix the wrong dev_id passed
      PS3: gelic: Add endianness macros
      PS3: gelic: code cleanup
      PS3: gelic: remove duplicated ethtool handlers
      PS3: gelic: add support for port link status
      PS3: gelic: Add support for dual network interface
      PS3: gelic: Add wireless support for PS3

Peter Tiedemann (2):
      lcs: avoid/reduce unused s390dbf debug areas.
      claw/lcs/netiucv: check s390dbf level before sprints

Sergio Luis (1):
      drivers/net/sis190: fix section mismatch warning in sis190_get_mac_addr

Steve Wise (1):
      cxgb3: Handle ARP completions that mark neighbors stale.

Ursula Braun (2):
      claw: removal of volatile variables
      netiucv: change name of nop function

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index eef6fec..be6e918 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -168,7 +168,7 @@ static int debug = -1;
  * Warning: 64K ring has hardware issues and may lock up.
  */
 #if defined(CONFIG_SH_DREAMCAST)
-#define RX_BUF_IDX	1	/* 16K ring */
+#define RX_BUF_IDX 0	/* 8K ring */
 #else
 #define RX_BUF_IDX	2	/* 32K ring */
 #endif
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 50c2b60..f337800 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -931,6 +931,14 @@ config ENC28J60_WRITEVERIFY
 	  Enable the verify after the buffer write useful for debugging purpose.
 	  If unsure, say N.
 
+config DM9000_DEBUGLEVEL
+	int "DM9000 maximum debug level"
+	depends on DM9000
+	default 4
+	help
+	  The maximum level of debugging code compiled into the DM9000
+	  driver.
+
 config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
@@ -2352,6 +2360,16 @@ config GELIC_NET
 	  To compile this driver as a module, choose M here: the
 	  module will be called ps3_gelic.
 
+config GELIC_WIRELESS
+       bool "PS3 Wireless support"
+       depends on GELIC_NET
+       help
+        This option adds the support for the wireless feature of PS3.
+        If you have the wireless-less model of PS3 or have no plan to
+        use wireless feature, disabling this option saves memory.  As
+        the driver automatically distinguishes the models, you can
+        safely enable this option even if you have a wireless-less model.
+
 config GIANFAR
 	tristate "Gianfar Ethernet"
 	depends on FSL_SOC
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 9fc7794..3b1ea32 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -70,7 +70,8 @@ obj-$(CONFIG_BNX2X) += bnx2x.o
 spidernet-y += spider_net.o spider_net_ethtool.o
 obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
 obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
-ps3_gelic-objs += ps3_gelic_net.o
+gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
+ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
 obj-$(CONFIG_TC35815) += tc35815.o
 obj-$(CONFIG_SKGE) += skge.o
 obj-$(CONFIG_SKY2) += sky2.o
diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index 17ed4c3..865faee 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -404,7 +404,7 @@ found:
 			if (neigh->nud_state & NUD_FAILED) {
 				arpq = e->arpq_head;
 				e->arpq_head = e->arpq_tail = NULL;
-			} else if (neigh_is_connected(neigh))
+			} else if (neigh->nud_state & (NUD_CONNECTED|NUD_STALE))
 				setup_l2e_send_pending(dev, NULL, e);
 		} else {
 			e->state = neigh_is_connected(neigh) ?
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 9ca8c66..979f3fc 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1059,6 +1059,14 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
 			 htonl(V_WR_TID(q->token)));
 }
 
+static inline void t3_stop_queue(struct net_device *dev, struct sge_qset *qs,
+				 struct sge_txq *q)
+{
+	netif_stop_queue(dev);
+	set_bit(TXQ_ETH, &qs->txq_stopped);
+	q->stops++;
+}
+
 /**
  *	eth_xmit - add a packet to the Ethernet Tx queue
  *	@skb: the packet
@@ -1090,31 +1098,18 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	ndesc = calc_tx_descs(skb);
 
 	if (unlikely(credits < ndesc)) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
-			set_bit(TXQ_ETH, &qs->txq_stopped);
-			q->stops++;
-			dev_err(&adap->pdev->dev,
-				"%s: Tx ring %u full while queue awake!\n",
-				dev->name, q->cntxt_id & 7);
-		}
+		t3_stop_queue(dev, qs, q);
+		dev_err(&adap->pdev->dev,
+			"%s: Tx ring %u full while queue awake!\n",
+			dev->name, q->cntxt_id & 7);
 		spin_unlock(&q->lock);
 		return NETDEV_TX_BUSY;
 	}
 
 	q->in_use += ndesc;
-	if (unlikely(credits - ndesc < q->stop_thres)) {
-		q->stops++;
-		netif_stop_queue(dev);
-		set_bit(TXQ_ETH, &qs->txq_stopped);
-#if !USE_GTS
-		if (should_restart_tx(q) &&
-		    test_and_clear_bit(TXQ_ETH, &qs->txq_stopped)) {
-			q->restarts++;
-			netif_wake_queue(dev);
-		}
-#endif
-	}
+	if (unlikely(credits - ndesc < q->stop_thres))
+		if (USE_GTS || !should_restart_tx(q))
+			t3_stop_queue(dev, qs, q);
 
 	gen = q->gen;
 	q->unacked += ndesc;
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 6a20a54..1fe305c 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1,7 +1,5 @@
 /*
- *   dm9000.c: Version 1.2 03/18/2003
- *
- *         A Davicom DM9000 ISA NIC fast Ethernet driver for Linux.
+ *      Davicom DM9000 Fast Ethernet driver for Linux.
  * 	Copyright (C) 1997  Sten Wang
  *
  * 	This program is free software; you can redistribute it and/or
@@ -14,44 +12,11 @@
  * 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * 	GNU General Public License for more details.
  *
- *   (C)Copyright 1997-1998 DAVICOM Semiconductor,Inc. All Rights Reserved.
- *
- * V0.11	06/20/2001	REG_0A bit3=1, default enable BP with DA match
- * 	06/22/2001 	Support DM9801 progrmming
- * 	 	 	E3: R25 = ((R24 + NF) & 0x00ff) | 0xf000
- * 		 	E4: R25 = ((R24 + NF) & 0x00ff) | 0xc200
- * 		     		R17 = (R17 & 0xfff0) | NF + 3
- * 		 	E5: R25 = ((R24 + NF - 3) & 0x00ff) | 0xc200
- * 		     		R17 = (R17 & 0xfff0) | NF
- *
- * v1.00               	modify by simon 2001.9.5
- *                         change for kernel 2.4.x
- *
- * v1.1   11/09/2001      	fix force mode bug
- *
- * v1.2   03/18/2003       Weilun Huang <weilun_huang@davicom.com.tw>:
- * 			Fixed phy reset.
- * 			Added tx/rx 32 bit mode.
- * 			Cleaned up for kernel merge.
- *
- *        03/03/2004    Sascha Hauer <s.hauer@pengutronix.de>
- *                      Port to 2.6 kernel
- *
- *	  24-Sep-2004   Ben Dooks <ben@simtec.co.uk>
- *			Cleanup of code to remove ifdefs
- *			Allowed platform device data to influence access width
- *			Reformatting areas of code
- *
- *        17-Mar-2005   Sascha Hauer <s.hauer@pengutronix.de>
- *                      * removed 2.4 style module parameters
- *                      * removed removed unused stat counter and fixed
- *                        net_device_stats
- *                      * introduced tx_timeout function
- *                      * reworked locking
+ * (C) Copyright 1997-1998 DAVICOM Semiconductor,Inc. All Rights Reserved.
  *
- *	  01-Jul-2005   Ben Dooks <ben@simtec.co.uk>
- *			* fixed spinlock call without pointer
- *			* ensure spinlock is initialised
+ * Additional updates, Copyright:
+ *	Ben Dooks <ben@simtec.co.uk>
+ *	Sascha Hauer <s.hauer@pengutronix.de>
  */
 
 #include <linux/module.h>
@@ -63,6 +28,7 @@
 #include <linux/spinlock.h>
 #include <linux/crc32.h>
 #include <linux/mii.h>
+#include <linux/ethtool.h>
 #include <linux/dm9000.h>
 #include <linux/delay.h>
 #include <linux/platform_device.h>
@@ -80,30 +46,7 @@
 
 #define CARDNAME "dm9000"
 #define PFX CARDNAME ": "
-
-#define DM9000_TIMER_WUT  jiffies+(HZ*2)	/* timer wakeup time : 2 second */
-
-#define DM9000_DEBUG 0
-
-#if DM9000_DEBUG > 2
-#define PRINTK3(args...)  printk(CARDNAME ": " args)
-#else
-#define PRINTK3(args...)  do { } while(0)
-#endif
-
-#if DM9000_DEBUG > 1
-#define PRINTK2(args...)  printk(CARDNAME ": " args)
-#else
-#define PRINTK2(args...)  do { } while(0)
-#endif
-
-#if DM9000_DEBUG > 0
-#define PRINTK1(args...)  printk(CARDNAME ": " args)
-#define PRINTK(args...)   printk(CARDNAME ": " args)
-#else
-#define PRINTK1(args...)  do { } while(0)
-#define PRINTK(args...)   printk(KERN_DEBUG args)
-#endif
+#define DRV_VERSION	"1.30"
 
 #ifdef CONFIG_BLACKFIN
 #define readsb	insb
@@ -112,9 +55,9 @@
 #define writesb	outsb
 #define writesw	outsw
 #define writesl	outsl
-#define DM9000_IRQ_FLAGS	(IRQF_SHARED | IRQF_TRIGGER_HIGH)
+#define DEFAULT_TRIGGER IRQF_TRIGGER_HIGH
 #else
-#define DM9000_IRQ_FLAGS	(IRQF_SHARED | IRQT_RISING)
+#define DEFAULT_TRIGGER (0)
 #endif
 
 /*
@@ -124,6 +67,24 @@ static int watchdog = 5000;
 module_param(watchdog, int, 0400);
 MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
 
+/* DM9000 register address locking.
+ *
+ * The DM9000 uses an address register to control where data written
+ * to the data register goes. This means that the address register
+ * must be preserved over interrupts or similar calls.
+ *
+ * During interrupt and other critical calls, a spinlock is used to
+ * protect the system, but the calls themselves save the address
+ * in the address register in case they are interrupting another
+ * access to the device.
+ *
+ * For general accesses a lock is provided so that calls which are
+ * allowed to sleep are serialised so that the address register does
+ * not need to be saved. This lock also serves to serialise access
+ * to the EEPROM and PHY access registers which are shared between
+ * these two devices.
+ */
+
 /* Structure/enum declaration ------------------------------- */
 typedef struct board_info {
 
@@ -137,33 +98,52 @@ typedef struct board_info {
 	u16 dbug_cnt;
 	u8 io_mode;		/* 0:word, 2:byte */
 	u8 phy_addr;
+	unsigned int flags;
+	unsigned int in_suspend :1;
+
+	int debug_level;
 
 	void (*inblk)(void __iomem *port, void *data, int length);
 	void (*outblk)(void __iomem *port, void *data, int length);
 	void (*dumpblk)(void __iomem *port, int length);
 
+	struct device	*dev;	     /* parent device */
+
 	struct resource	*addr_res;   /* resources found */
 	struct resource *data_res;
 	struct resource	*addr_req;   /* resources requested */
 	struct resource *data_req;
 	struct resource *irq_res;
 
-	struct timer_list timer;
-	unsigned char srom[128];
+	struct mutex	 addr_lock;	/* phy and eeprom access lock */
+
 	spinlock_t lock;
 
 	struct mii_if_info mii;
 	u32 msg_enable;
 } board_info_t;
 
+/* debug code */
+
+#define dm9000_dbg(db, lev, msg...) do {		\
+	if ((lev) < CONFIG_DM9000_DEBUGLEVEL &&		\
+	    (lev) < db->debug_level) {			\
+		dev_dbg(db->dev, msg);			\
+	}						\
+} while (0)
+
+static inline board_info_t *to_dm9000_board(struct net_device *dev)
+{
+	return dev->priv;
+}
+
 /* function declaration ------------------------------------- */
 static int dm9000_probe(struct platform_device *);
 static int dm9000_open(struct net_device *);
 static int dm9000_start_xmit(struct sk_buff *, struct net_device *);
 static int dm9000_stop(struct net_device *);
+static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int cmd);
 
-
-static void dm9000_timer(unsigned long);
 static void dm9000_init_dm9000(struct net_device *);
 
 static irqreturn_t dm9000_interrupt(int, void *);
@@ -171,20 +151,19 @@ static irqreturn_t dm9000_interrupt(int, void *);
 static int dm9000_phy_read(struct net_device *dev, int phyaddr_unsused, int reg);
 static void dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg,
 			   int value);
-static u16 read_srom_word(board_info_t *, int);
+
+static void dm9000_read_eeprom(board_info_t *, int addr, u8 *to);
+static void dm9000_write_eeprom(board_info_t *, int addr, u8 *dp);
 static void dm9000_rx(struct net_device *);
 static void dm9000_hash_table(struct net_device *);
 
-//#define DM9000_PROGRAM_EEPROM
-#ifdef DM9000_PROGRAM_EEPROM
-static void program_eeprom(board_info_t * db);
-#endif
 /* DM9000 network board routine ---------------------------- */
 
 static void
 dm9000_reset(board_info_t * db)
 {
-	PRINTK1("dm9000x: resetting\n");
+	dev_dbg(db->dev, "resetting device\n");
+
 	/* RESET device */
 	writeb(DM9000_NCR, db->io_addr);
 	udelay(200);
@@ -300,14 +279,10 @@ static void dm9000_set_io(struct board_info *db, int byte_width)
 		db->inblk   = dm9000_inblk_8bit;
 		break;
 
-	case 2:
-		db->dumpblk = dm9000_dumpblk_16bit;
-		db->outblk  = dm9000_outblk_16bit;
-		db->inblk   = dm9000_inblk_16bit;
-		break;
 
 	case 3:
-		printk(KERN_ERR PFX ": 3 byte IO, falling back to 16bit\n");
+		dev_dbg(db->dev, ": 3 byte IO, falling back to 16bit\n");
+	case 2:
 		db->dumpblk = dm9000_dumpblk_16bit;
 		db->outblk  = dm9000_outblk_16bit;
 		db->inblk   = dm9000_inblk_16bit;
@@ -358,6 +333,139 @@ static void dm9000_poll_controller(struct net_device *dev)
 }
 #endif
 
+static int dm9000_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	return generic_mii_ioctl(&dm->mii, if_mii(req), cmd, NULL);
+}
+
+/* ethtool ops */
+
+static void dm9000_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	strcpy(info->driver, CARDNAME);
+	strcpy(info->version, DRV_VERSION);
+	strcpy(info->bus_info, to_platform_device(dm->dev)->name);
+}
+
+static u32 dm9000_get_msglevel(struct net_device *dev)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	return dm->msg_enable;
+}
+
+static void dm9000_set_msglevel(struct net_device *dev, u32 value)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	dm->msg_enable = value;
+}
+
+static int dm9000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	mii_ethtool_gset(&dm->mii, cmd);
+	return 0;
+}
+
+static int dm9000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	return mii_ethtool_sset(&dm->mii, cmd);
+}
+
+static int dm9000_nway_reset(struct net_device *dev)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	return mii_nway_restart(&dm->mii);
+}
+
+static u32 dm9000_get_link(struct net_device *dev)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	return mii_link_ok(&dm->mii);
+}
+
+#define DM_EEPROM_MAGIC		(0x444D394B)
+
+static int dm9000_get_eeprom_len(struct net_device *dev)
+{
+	return 128;
+}
+
+static int dm9000_get_eeprom(struct net_device *dev,
+			     struct ethtool_eeprom *ee, u8 *data)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	int offset = ee->offset;
+	int len = ee->len;
+	int i;
+
+	/* EEPROM access is aligned to two bytes */
+
+	if ((len & 1) != 0 || (offset & 1) != 0)
+		return -EINVAL;
+
+	if (dm->flags & DM9000_PLATF_NO_EEPROM)
+		return -ENOENT;
+
+	ee->magic = DM_EEPROM_MAGIC;
+
+	for (i = 0; i < len; i += 2)
+		dm9000_read_eeprom(dm, (offset + i) / 2, data + i);
+
+	return 0;
+}
+
+static int dm9000_set_eeprom(struct net_device *dev,
+			     struct ethtool_eeprom *ee, u8 *data)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	int offset = ee->offset;
+	int len = ee->len;
+	int i;
+
+	/* EEPROM access is aligned to two bytes */
+
+	if ((len & 1) != 0 || (offset & 1) != 0)
+		return -EINVAL;
+
+	if (dm->flags & DM9000_PLATF_NO_EEPROM)
+		return -ENOENT;
+
+	if (ee->magic != DM_EEPROM_MAGIC)
+		return -EINVAL;
+
+	for (i = 0; i < len; i += 2)
+		dm9000_write_eeprom(dm, (offset + i) / 2, data + i);
+
+	return 0;
+}
+
+static const struct ethtool_ops dm9000_ethtool_ops = {
+	.get_drvinfo		= dm9000_get_drvinfo,
+	.get_settings		= dm9000_get_settings,
+	.set_settings		= dm9000_set_settings,
+	.get_msglevel		= dm9000_get_msglevel,
+	.set_msglevel		= dm9000_set_msglevel,
+	.nway_reset		= dm9000_nway_reset,
+	.get_link		= dm9000_get_link,
+ 	.get_eeprom_len		= dm9000_get_eeprom_len,
+ 	.get_eeprom		= dm9000_get_eeprom,
+ 	.set_eeprom		= dm9000_set_eeprom,
+};
+
+
 /* dm9000_release_board
  *
  * release a board, and any mapped resources
@@ -401,6 +509,7 @@ dm9000_probe(struct platform_device *pdev)
 	struct dm9000_plat_data *pdata = pdev->dev.platform_data;
 	struct board_info *db;	/* Point a board information structure */
 	struct net_device *ndev;
+	const unsigned char *mac_src;
 	unsigned long base;
 	int ret = 0;
 	int iosize;
@@ -410,19 +519,22 @@ dm9000_probe(struct platform_device *pdev)
 	/* Init network device */
 	ndev = alloc_etherdev(sizeof (struct board_info));
 	if (!ndev) {
-		printk("%s: could not allocate device.\n", CARDNAME);
+		dev_err(&pdev->dev, "could not allocate device.\n");
 		return -ENOMEM;
 	}
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	PRINTK2("dm9000_probe()");
+	dev_dbg(&pdev->dev, "dm9000_probe()");
 
 	/* setup board info structure */
 	db = (struct board_info *) ndev->priv;
 	memset(db, 0, sizeof (*db));
 
+	db->dev = &pdev->dev;
+
 	spin_lock_init(&db->lock);
+	mutex_init(&db->addr_lock);
 
 	if (pdev->num_resources < 2) {
 		ret = -ENODEV;
@@ -450,7 +562,7 @@ dm9000_probe(struct platform_device *pdev)
 
 		if (db->addr_res == NULL || db->data_res == NULL ||
 		    db->irq_res == NULL) {
-			printk(KERN_ERR PFX "insufficient resources\n");
+			dev_err(db->dev, "insufficient resources\n");
 			ret = -ENOENT;
 			goto out;
 		}
@@ -460,7 +572,7 @@ dm9000_probe(struct platform_device *pdev)
 						  pdev->name);
 
 		if (db->addr_req == NULL) {
-			printk(KERN_ERR PFX "cannot claim address reg area\n");
+			dev_err(db->dev, "cannot claim address reg area\n");
 			ret = -EIO;
 			goto out;
 		}
@@ -468,7 +580,7 @@ dm9000_probe(struct platform_device *pdev)
 		db->io_addr = ioremap(db->addr_res->start, i);
 
 		if (db->io_addr == NULL) {
-			printk(KERN_ERR "failed to ioremap address reg\n");
+			dev_err(db->dev, "failed to ioremap address reg\n");
 			ret = -EINVAL;
 			goto out;
 		}
@@ -478,7 +590,7 @@ dm9000_probe(struct platform_device *pdev)
 						  pdev->name);
 
 		if (db->data_req == NULL) {
-			printk(KERN_ERR PFX "cannot claim data reg area\n");
+			dev_err(db->dev, "cannot claim data reg area\n");
 			ret = -EIO;
 			goto out;
 		}
@@ -486,7 +598,7 @@ dm9000_probe(struct platform_device *pdev)
 		db->io_data = ioremap(db->data_res->start, iosize);
 
 		if (db->io_data == NULL) {
-			printk(KERN_ERR "failed to ioremap data reg\n");
+			dev_err(db->dev,"failed to ioremap data reg\n");
 			ret = -EINVAL;
 			goto out;
 		}
@@ -525,12 +637,14 @@ dm9000_probe(struct platform_device *pdev)
 
 		if (pdata->dumpblk != NULL)
 			db->dumpblk = pdata->dumpblk;
+
+		db->flags = pdata->flags;
 	}
 
 	dm9000_reset(db);
 
 	/* try two times, DM9000 sometimes gets the first read wrong */
-	for (i = 0; i < 2; i++) {
+	for (i = 0; i < 8; i++) {
 		id_val  = ior(db, DM9000_VIDL);
 		id_val |= (u32)ior(db, DM9000_VIDH) << 8;
 		id_val |= (u32)ior(db, DM9000_PIDL) << 16;
@@ -538,11 +652,11 @@ dm9000_probe(struct platform_device *pdev)
 
 		if (id_val == DM9000_ID)
 			break;
-		printk("%s: read wrong id 0x%08x\n", CARDNAME, id_val);
+		dev_err(db->dev, "read wrong id 0x%08x\n", id_val);
 	}
 
 	if (id_val != DM9000_ID) {
-		printk("%s: wrong id: 0x%08x\n", CARDNAME, id_val);
+		dev_err(db->dev, "wrong id: 0x%08x\n", id_val);
 		ret = -ENODEV;
 		goto out;
 	}
@@ -558,13 +672,13 @@ dm9000_probe(struct platform_device *pdev)
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 	ndev->stop		 = &dm9000_stop;
 	ndev->set_multicast_list = &dm9000_hash_table;
+	ndev->ethtool_ops	 = &dm9000_ethtool_ops;
+	ndev->do_ioctl		 = &dm9000_ioctl;
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	ndev->poll_controller	 = &dm9000_poll_controller;
 #endif
 
-#ifdef DM9000_PROGRAM_EEPROM
-	program_eeprom(db);
-#endif
 	db->msg_enable       = NETIF_MSG_LINK;
 	db->mii.phy_id_mask  = 0x1f;
 	db->mii.reg_num_mask = 0x1f;
@@ -574,38 +688,37 @@ dm9000_probe(struct platform_device *pdev)
 	db->mii.mdio_read    = dm9000_phy_read;
 	db->mii.mdio_write   = dm9000_phy_write;
 
-	/* Read SROM content */
-	for (i = 0; i < 64; i++)
-		((u16 *) db->srom)[i] = read_srom_word(db, i);
+	mac_src = "eeprom";
 
-	/* Set Node Address */
-	for (i = 0; i < 6; i++)
-		ndev->dev_addr[i] = db->srom[i];
+	/* try reading the node address from the attached EEPROM */
+	for (i = 0; i < 6; i += 2)
+		dm9000_read_eeprom(db, i / 2, ndev->dev_addr+i);
 
 	if (!is_valid_ether_addr(ndev->dev_addr)) {
 		/* try reading from mac */
-
+		
+		mac_src = "chip";
 		for (i = 0; i < 6; i++)
 			ndev->dev_addr[i] = ior(db, i+DM9000_PAR);
 	}
 
 	if (!is_valid_ether_addr(ndev->dev_addr))
-		printk("%s: Invalid ethernet MAC address.  Please "
-		       "set using ifconfig\n", ndev->name);
+		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
+			 "set using ifconfig\n", ndev->name);
 
 	platform_set_drvdata(pdev, ndev);
 	ret = register_netdev(ndev);
 
 	if (ret == 0) {
 		DECLARE_MAC_BUF(mac);
-		printk("%s: dm9000 at %p,%p IRQ %d MAC: %s\n",
+		printk("%s: dm9000 at %p,%p IRQ %d MAC: %s (%s)\n",
 		       ndev->name,  db->io_addr, db->io_data, ndev->irq,
-		       print_mac(mac, ndev->dev_addr));
+		       print_mac(mac, ndev->dev_addr), mac_src);
 	}
 	return 0;
 
 out:
-	printk("%s: not found (%d).\n", CARDNAME, ret);
+	dev_err(db->dev, "not found (%d).\n", ret);
 
 	dm9000_release_board(pdev, db);
 	free_netdev(ndev);
@@ -621,10 +734,22 @@ static int
 dm9000_open(struct net_device *dev)
 {
 	board_info_t *db = (board_info_t *) dev->priv;
+	unsigned long irqflags = db->irq_res->flags & IRQF_TRIGGER_MASK;
 
-	PRINTK2("entering dm9000_open\n");
+	if (netif_msg_ifup(db))
+		dev_dbg(db->dev, "enabling %s\n", dev->name);
 
-	if (request_irq(dev->irq, &dm9000_interrupt, DM9000_IRQ_FLAGS, dev->name, dev))
+	/* If there is no IRQ type specified, default to something that
+	 * may work, and tell the user that this is a problem */
+
+	if (irqflags == IRQF_TRIGGER_NONE) {
+		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
+		irqflags = DEFAULT_TRIGGER;
+	}
+	
+	irqflags |= IRQF_SHARED;
+
+	if (request_irq(dev->irq, &dm9000_interrupt, irqflags, dev->name, dev))
 		return -EAGAIN;
 
 	/* Initialize DM9000 board */
@@ -634,13 +759,6 @@ dm9000_open(struct net_device *dev)
 	/* Init driver variable */
 	db->dbug_cnt = 0;
 
-	/* set and active a timer process */
-	init_timer(&db->timer);
-	db->timer.expires  = DM9000_TIMER_WUT;
-	db->timer.data     = (unsigned long) dev;
-	db->timer.function = &dm9000_timer;
-	add_timer(&db->timer);
-
 	mii_check_media(&db->mii, netif_msg_link(db), 1);
 	netif_start_queue(dev);
 
@@ -655,7 +773,7 @@ dm9000_init_dm9000(struct net_device *dev)
 {
 	board_info_t *db = (board_info_t *) dev->priv;
 
-	PRINTK1("entering %s\n",__FUNCTION__);
+	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
 	/* I/O mode */
 	db->io_mode = ior(db, DM9000_ISR) >> 6;	/* ISR bit7:6 keeps I/O mode */
@@ -665,6 +783,9 @@ dm9000_init_dm9000(struct net_device *dev)
 	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
 	iow(db, DM9000_GPR, 0);	/* Enable PHY */
 
+	if (db->flags & DM9000_PLATF_EXT_PHY)
+		iow(db, DM9000_NCR, NCR_EXT_PHY);
+
 	/* Program operating register */
 	iow(db, DM9000_TCR, 0);	        /* TX Polling clear */
 	iow(db, DM9000_BPTR, 0x3f);	/* Less 3Kb, 200us */
@@ -698,7 +819,7 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 	board_info_t *db = (board_info_t *) dev->priv;
 
-	PRINTK3("dm9000_start_xmit\n");
+	dm9000_dbg(db, 3, "%s:\n", __func__);
 
 	if (db->tx_pkt_cnt > 1)
 		return 1;
@@ -715,8 +836,8 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* TX control: First packet immediately send, second packet queue */
 	if (db->tx_pkt_cnt == 1) {
 		/* Set TX length to DM9000 */
-		iow(db, DM9000_TXPLL, skb->len & 0xff);
-		iow(db, DM9000_TXPLH, (skb->len >> 8) & 0xff);
+		iow(db, DM9000_TXPLL, skb->len);
+		iow(db, DM9000_TXPLH, skb->len >> 8);
 
 		/* Issue TX polling command */
 		iow(db, DM9000_TCR, TCR_TXREQ);	/* Cleared after TX complete */
@@ -757,10 +878,8 @@ dm9000_stop(struct net_device *ndev)
 {
 	board_info_t *db = (board_info_t *) ndev->priv;
 
-	PRINTK1("entering %s\n",__FUNCTION__);
-
-	/* deleted timer */
-	del_timer(&db->timer);
+	if (netif_msg_ifdown(db))
+		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
 
 	netif_stop_queue(ndev);
 	netif_carrier_off(ndev);
@@ -788,10 +907,13 @@ dm9000_tx_done(struct net_device *dev, board_info_t * db)
 		db->tx_pkt_cnt--;
 		dev->stats.tx_packets++;
 
+		if (netif_msg_tx_done(db))
+			dev_dbg(db->dev, "tx done, NSR %02x\n", tx_status);
+
 		/* Queue packet check & send */
 		if (db->tx_pkt_cnt > 0) {
-			iow(db, DM9000_TXPLL, db->queue_pkt_len & 0xff);
-			iow(db, DM9000_TXPLH, (db->queue_pkt_len >> 8) & 0xff);
+			iow(db, DM9000_TXPLL, db->queue_pkt_len);
+			iow(db, DM9000_TXPLH, db->queue_pkt_len >> 8);
 			iow(db, DM9000_TCR, TCR_TXREQ);
 			dev->trans_start = jiffies;
 		}
@@ -803,19 +925,14 @@ static irqreturn_t
 dm9000_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	board_info_t *db;
+	board_info_t *db = (board_info_t *) dev->priv;
 	int int_status;
 	u8 reg_save;
 
-	PRINTK3("entering %s\n",__FUNCTION__);
-
-	if (!dev) {
-		PRINTK1("dm9000_interrupt() without DEVICE arg\n");
-		return IRQ_HANDLED;
-	}
+	dm9000_dbg(db, 3, "entering %s\n", __func__);
 
 	/* A real interrupt coming */
-	db = (board_info_t *) dev->priv;
+
 	spin_lock(&db->lock);
 
 	/* Save previous register address */
@@ -828,6 +945,9 @@ dm9000_interrupt(int irq, void *dev_id)
 	int_status = ior(db, DM9000_ISR);	/* Got ISR */
 	iow(db, DM9000_ISR, int_status);	/* Clear ISR status */
 
+	if (netif_msg_intr(db))
+		dev_dbg(db->dev, "interrupt status %02x\n", int_status);
+
 	/* Received the coming packet */
 	if (int_status & ISR_PRS)
 		dm9000_rx(dev);
@@ -847,27 +967,9 @@ dm9000_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-/*
- *  A periodic timer routine
- *  Dynamic media sense, allocated Rx buffer...
- */
-static void
-dm9000_timer(unsigned long data)
-{
-	struct net_device *dev = (struct net_device *) data;
-	board_info_t *db = (board_info_t *) dev->priv;
-
-	PRINTK3("dm9000_timer()\n");
-
-	mii_check_media(&db->mii, netif_msg_link(db), 0);
-
-	/* Set timer again */
-	db->timer.expires = DM9000_TIMER_WUT;
-	add_timer(&db->timer);
-}
-
 struct dm9000_rxhdr {
-	u16	RxStatus;
+	u8	RxPktReady;
+	u8	RxStatus;
 	u16	RxLen;
 } __attribute__((__packed__));
 
@@ -893,7 +995,7 @@ dm9000_rx(struct net_device *dev)
 
 		/* Status check: this byte must be 0 or 1 */
 		if (rxbyte > DM9000_PKT_RDY) {
-			printk("status check failed: %d\n", rxbyte);
+			dev_warn(db->dev, "status check fail: %d\n", rxbyte);
 			iow(db, DM9000_RCR, 0x00);	/* Stop Device */
 			iow(db, DM9000_ISR, IMR_PAR);	/* Stop INT request */
 			return;
@@ -908,30 +1010,38 @@ dm9000_rx(struct net_device *dev)
 
 		(db->inblk)(db->io_data, &rxhdr, sizeof(rxhdr));
 
-		RxLen = rxhdr.RxLen;
+		RxLen = le16_to_cpu(rxhdr.RxLen);
+
+		if (netif_msg_rx_status(db))
+			dev_dbg(db->dev, "RX: status %02x, length %04x\n",
+				rxhdr.RxStatus, RxLen);
 
 		/* Packet Status check */
 		if (RxLen < 0x40) {
 			GoodPacket = false;
-			PRINTK1("Bad Packet received (runt)\n");
+			if (netif_msg_rx_err(db))
+				dev_dbg(db->dev, "RX: Bad Packet (runt)\n");
 		}
 
 		if (RxLen > DM9000_PKT_MAX) {
-			PRINTK1("RST: RX Len:%x\n", RxLen);
+			dev_dbg(db->dev, "RST: RX Len:%x\n", RxLen);
 		}
 
-		if (rxhdr.RxStatus & 0xbf00) {
+		if (rxhdr.RxStatus & 0xbf) {
 			GoodPacket = false;
-			if (rxhdr.RxStatus & 0x100) {
-				PRINTK1("fifo error\n");
+			if (rxhdr.RxStatus & 0x01) {
+				if (netif_msg_rx_err(db))
+					dev_dbg(db->dev, "fifo error\n");
 				dev->stats.rx_fifo_errors++;
 			}
-			if (rxhdr.RxStatus & 0x200) {
-				PRINTK1("crc error\n");
+			if (rxhdr.RxStatus & 0x02) {
+				if (netif_msg_rx_err(db))
+					dev_dbg(db->dev, "crc error\n");
 				dev->stats.rx_crc_errors++;
 			}
-			if (rxhdr.RxStatus & 0x8000) {
-				PRINTK1("length error\n");
+			if (rxhdr.RxStatus & 0x80) {
+				if (netif_msg_rx_err(db))
+					dev_dbg(db->dev, "length error\n");
 				dev->stats.rx_length_errors++;
 			}
 		}
@@ -960,72 +1070,119 @@ dm9000_rx(struct net_device *dev)
 	} while (rxbyte == DM9000_PKT_RDY);
 }
 
-/*
- *  Read a word data from SROM
- */
-static u16
-read_srom_word(board_info_t * db, int offset)
+static unsigned int
+dm9000_read_locked(board_info_t *db, int reg)
 {
-	iow(db, DM9000_EPAR, offset);
-	iow(db, DM9000_EPCR, EPCR_ERPRR);
-	mdelay(8);		/* according to the datasheet 200us should be enough,
-				   but it doesn't work */
-	iow(db, DM9000_EPCR, 0x0);
-	return (ior(db, DM9000_EPDRL) + (ior(db, DM9000_EPDRH) << 8));
+	unsigned long flags;
+	unsigned int ret;
+
+	spin_lock_irqsave(&db->lock, flags);
+	ret = ior(db, reg);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	return ret;
+}
+
+static int dm9000_wait_eeprom(board_info_t *db)
+{
+	unsigned int status;
+	int timeout = 8;	/* wait max 8msec */
+
+	/* The DM9000 data sheets say we should be able to
+	 * poll the ERRE bit in EPCR to wait for the EEPROM
+	 * operation. From testing several chips, this bit
+	 * does not seem to work. 
+	 *
+	 * We attempt to use the bit, but fall back to the
+	 * timeout (which is why we do not return an error
+	 * on expiry) to say that the EEPROM operation has
+	 * completed.
+	 */
+
+	while (1) {
+		status = dm9000_read_locked(db, DM9000_EPCR);
+
+		if ((status & EPCR_ERRE) == 0)
+			break;
+
+		if (timeout-- < 0) {
+			dev_dbg(db->dev, "timeout waiting EEPROM\n");
+			break;
+		}
+	}
+
+	return 0;
 }
 
-#ifdef DM9000_PROGRAM_EEPROM
 /*
- * Write a word data to SROM
+ *  Read a word data from EEPROM
  */
 static void
-write_srom_word(board_info_t * db, int offset, u16 val)
+dm9000_read_eeprom(board_info_t *db, int offset, u8 *to)
 {
+	unsigned long flags;
+
+	if (db->flags & DM9000_PLATF_NO_EEPROM) {
+		to[0] = 0xff;
+		to[1] = 0xff;
+		return;
+	}
+
+	mutex_lock(&db->addr_lock);
+
+	spin_lock_irqsave(&db->lock, flags);
+
 	iow(db, DM9000_EPAR, offset);
-	iow(db, DM9000_EPDRH, ((val >> 8) & 0xff));
-	iow(db, DM9000_EPDRL, (val & 0xff));
-	iow(db, DM9000_EPCR, EPCR_WEP | EPCR_ERPRW);
-	mdelay(8);		/* same shit */
-	iow(db, DM9000_EPCR, 0);
+	iow(db, DM9000_EPCR, EPCR_ERPRR);
+
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	dm9000_wait_eeprom(db);
+
+	/* delay for at-least 150uS */
+	msleep(1);
+
+	spin_lock_irqsave(&db->lock, flags);
+
+	iow(db, DM9000_EPCR, 0x0);
+
+	to[0] = ior(db, DM9000_EPDRL);
+	to[1] = ior(db, DM9000_EPDRH);
+
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	mutex_unlock(&db->addr_lock);
 }
 
 /*
- * Only for development:
- * Here we write static data to the eeprom in case
- * we don't have valid content on a new board
+ * Write a word data to SROM
  */
 static void
-program_eeprom(board_info_t * db)
+dm9000_write_eeprom(board_info_t *db, int offset, u8 *data)
 {
-	u16 eeprom[] = { 0x0c00, 0x007f, 0x1300,	/* MAC Address */
-		0x0000,		/* Autoload: accept nothing */
-		0x0a46, 0x9000,	/* Vendor / Product ID */
-		0x0000,		/* pin control */
-		0x0000,
-	};			/* Wake-up mode control */
-	int i;
-	for (i = 0; i < 8; i++)
-		write_srom_word(db, i, eeprom[i]);
-}
-#endif
+	unsigned long flags;
 
+	if (db->flags & DM9000_PLATF_NO_EEPROM)
+		return;
 
-/*
- *  Calculate the CRC valude of the Rx packet
- *  flag = 1 : return the reverse CRC (for the received packet CRC)
- *         0 : return the normal CRC (for Hash Table index)
- */
+	mutex_lock(&db->addr_lock);
 
-static unsigned long
-cal_CRC(unsigned char *Data, unsigned int Len, u8 flag)
-{
+	spin_lock_irqsave(&db->lock, flags);
+	iow(db, DM9000_EPAR, offset);
+	iow(db, DM9000_EPDRH, data[1]);
+	iow(db, DM9000_EPDRL, data[0]);
+	iow(db, DM9000_EPCR, EPCR_WEP | EPCR_ERPRW);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	dm9000_wait_eeprom(db);
 
-       u32 crc = ether_crc_le(Len, Data);
+	mdelay(1);	/* wait at least 150uS to clear */
 
-       if (flag)
-               return ~crc;
+	spin_lock_irqsave(&db->lock, flags);
+	iow(db, DM9000_EPCR, 0);
+	spin_unlock_irqrestore(&db->lock, flags);
 
-       return crc;
+	mutex_unlock(&db->addr_lock);
 }
 
 /*
@@ -1037,15 +1194,16 @@ dm9000_hash_table(struct net_device *dev)
 	board_info_t *db = (board_info_t *) dev->priv;
 	struct dev_mc_list *mcptr = dev->mc_list;
 	int mc_cnt = dev->mc_count;
+	int i, oft;
 	u32 hash_val;
-	u16 i, oft, hash_table[4];
+	u16 hash_table[4];
 	unsigned long flags;
 
-	PRINTK2("dm9000_hash_table()\n");
+	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
-	spin_lock_irqsave(&db->lock,flags);
+	spin_lock_irqsave(&db->lock, flags);
 
-	for (i = 0, oft = 0x10; i < 6; i++, oft++)
+	for (i = 0, oft = DM9000_PAR; i < 6; i++, oft++)
 		iow(db, oft, dev->dev_addr[i]);
 
 	/* Clear Hash Table */
@@ -1057,21 +1215,33 @@ dm9000_hash_table(struct net_device *dev)
 
 	/* the multicast address in Hash Table : 64 bits */
 	for (i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
-		hash_val = cal_CRC((char *) mcptr->dmi_addr, 6, 0) & 0x3f;
+		hash_val = ether_crc_le(6, mcptr->dmi_addr) & 0x3f;
 		hash_table[hash_val / 16] |= (u16) 1 << (hash_val % 16);
 	}
 
 	/* Write the hash table to MAC MD table */
-	for (i = 0, oft = 0x16; i < 4; i++) {
-		iow(db, oft++, hash_table[i] & 0xff);
-		iow(db, oft++, (hash_table[i] >> 8) & 0xff);
+	for (i = 0, oft = DM9000_MAR; i < 4; i++) {
+		iow(db, oft++, hash_table[i]);
+		iow(db, oft++, hash_table[i] >> 8);
 	}
 
-	spin_unlock_irqrestore(&db->lock,flags);
+	spin_unlock_irqrestore(&db->lock, flags);
 }
 
 
 /*
+ * Sleep, either by using msleep() or if we are suspending, then
+ * use mdelay() to sleep.
+ */
+static void dm9000_msleep(board_info_t *db, unsigned int ms)
+{
+	if (db->in_suspend)
+		mdelay(ms);
+	else
+		msleep(ms);
+}
+
+/*
  *   Read a word from phyxcer
  */
 static int
@@ -1082,6 +1252,8 @@ dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 	unsigned int reg_save;
 	int ret;
 
+	mutex_lock(&db->addr_lock);
+
 	spin_lock_irqsave(&db->lock,flags);
 
 	/* Save previous register address */
@@ -1091,7 +1263,15 @@ dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 	iow(db, DM9000_EPAR, DM9000_PHY | reg);
 
 	iow(db, DM9000_EPCR, 0xc);	/* Issue phyxcer read command */
-	udelay(100);		/* Wait read complete */
+
+	writeb(reg_save, db->io_addr);
+	spin_unlock_irqrestore(&db->lock,flags);
+
+	dm9000_msleep(db, 1);		/* Wait read complete */
+
+	spin_lock_irqsave(&db->lock,flags);
+	reg_save = readb(db->io_addr);
+
 	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer read command */
 
 	/* The read data keeps on REG_0D & REG_0E */
@@ -1099,9 +1279,9 @@ dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 
 	/* restore the previous address */
 	writeb(reg_save, db->io_addr);
-
 	spin_unlock_irqrestore(&db->lock,flags);
 
+	mutex_unlock(&db->addr_lock);
 	return ret;
 }
 
@@ -1115,6 +1295,8 @@ dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg, int value)
 	unsigned long flags;
 	unsigned long reg_save;
 
+	mutex_lock(&db->addr_lock);
+
 	spin_lock_irqsave(&db->lock,flags);
 
 	/* Save previous register address */
@@ -1124,25 +1306,38 @@ dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg, int value)
 	iow(db, DM9000_EPAR, DM9000_PHY | reg);
 
 	/* Fill the written data into REG_0D & REG_0E */
-	iow(db, DM9000_EPDRL, (value & 0xff));
-	iow(db, DM9000_EPDRH, ((value >> 8) & 0xff));
+	iow(db, DM9000_EPDRL, value);
+	iow(db, DM9000_EPDRH, value >> 8);
 
 	iow(db, DM9000_EPCR, 0xa);	/* Issue phyxcer write command */
-	udelay(500);		/* Wait write complete */
+
+	writeb(reg_save, db->io_addr);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	dm9000_msleep(db, 1);		/* Wait write complete */
+
+	spin_lock_irqsave(&db->lock,flags);
+	reg_save = readb(db->io_addr);
+
 	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer write command */
 
 	/* restore the previous address */
 	writeb(reg_save, db->io_addr);
 
-	spin_unlock_irqrestore(&db->lock,flags);
+	spin_unlock_irqrestore(&db->lock, flags);
+	mutex_unlock(&db->addr_lock);
 }
 
 static int
 dm9000_drv_suspend(struct platform_device *dev, pm_message_t state)
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
+	board_info_t *db;
 
 	if (ndev) {
+		db = (board_info_t *) ndev->priv;
+		db->in_suspend = 1;
+
 		if (netif_running(ndev)) {
 			netif_device_detach(ndev);
 			dm9000_shutdown(ndev);
@@ -1165,6 +1360,8 @@ dm9000_drv_resume(struct platform_device *dev)
 
 			netif_device_attach(ndev);
 		}
+
+		db->in_suspend = 0;
 	}
 	return 0;
 }
@@ -1180,8 +1377,7 @@ dm9000_drv_remove(struct platform_device *pdev)
 	dm9000_release_board(pdev, (board_info_t *) ndev->priv);
 	free_netdev(ndev);		/* free device structure */
 
-	PRINTK1("clean_module() exit\n");
-
+	dev_dbg(&pdev->dev, "released and freed device\n");
 	return 0;
 }
 
@@ -1199,7 +1395,7 @@ static struct platform_driver dm9000_driver = {
 static int __init
 dm9000_init(void)
 {
-	printk(KERN_INFO "%s Ethernet Driver\n", CARDNAME);
+	printk(KERN_INFO "%s Ethernet Driver, V%s\n", CARDNAME, DRV_VERSION);
 
 	return platform_driver_register(&dm9000_driver);	/* search board and register */
 }
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7c5b05a..d4ee8ec 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -926,8 +926,6 @@ e1000_probe(struct pci_dev *pdev,
 {
 	struct net_device *netdev;
 	struct e1000_adapter *adapter;
-	unsigned long mmio_start, mmio_len;
-	unsigned long flash_start, flash_len;
 
 	static int cards_found = 0;
 	static int global_quad_port_a = 0; /* global ksp3 port a indication */
@@ -970,11 +968,9 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->hw.back = adapter;
 	adapter->msg_enable = (1 << debug) - 1;
 
-	mmio_start = pci_resource_start(pdev, BAR_0);
-	mmio_len = pci_resource_len(pdev, BAR_0);
-
 	err = -EIO;
-	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
+	adapter->hw.hw_addr = ioremap(pci_resource_start(pdev, BAR_0),
+				      pci_resource_len(pdev, BAR_0));
 	if (!adapter->hw.hw_addr)
 		goto err_ioremap;
 
@@ -1009,10 +1005,6 @@ e1000_probe(struct pci_dev *pdev,
 #endif
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
-	netdev->mem_start = mmio_start;
-	netdev->mem_end = mmio_start + mmio_len;
-	netdev->base_addr = adapter->hw.io_base;
-
 	adapter->bd_number = cards_found;
 
 	/* setup the private structure */
@@ -1025,9 +1017,9 @@ e1000_probe(struct pci_dev *pdev,
 	 * because it depends on mac_type */
 	if ((adapter->hw.mac_type == e1000_ich8lan) &&
 	   (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
-		flash_start = pci_resource_start(pdev, 1);
-		flash_len = pci_resource_len(pdev, 1);
-		adapter->hw.flash_address = ioremap(flash_start, flash_len);
+		adapter->hw.flash_address =
+			ioremap(pci_resource_start(pdev, 1),
+				pci_resource_len(pdev, 1));
 		if (!adapter->hw.flash_address)
 			goto err_flashmap;
 	}
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index d4843d0..801b4d9 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -166,21 +166,24 @@
  * Hardware access:
  */
 
-#define DEV_NEED_TIMERIRQ	0x0001  /* set the timer irq flag in the irq mask */
-#define DEV_NEED_LINKTIMER	0x0002	/* poll link settings. Relies on the timer irq */
-#define DEV_HAS_LARGEDESC	0x0004	/* device supports jumbo frames and needs packet format 2 */
-#define DEV_HAS_HIGH_DMA        0x0008  /* device supports 64bit dma */
-#define DEV_HAS_CHECKSUM        0x0010  /* device supports tx and rx checksum offloads */
-#define DEV_HAS_VLAN            0x0020  /* device supports vlan tagging and striping */
-#define DEV_HAS_MSI             0x0040  /* device supports MSI */
-#define DEV_HAS_MSI_X           0x0080  /* device supports MSI-X */
-#define DEV_HAS_POWER_CNTRL     0x0100  /* device supports power savings */
-#define DEV_HAS_PAUSEFRAME_TX   0x0200  /* device supports tx pause frames */
-#define DEV_HAS_STATISTICS_V1   0x0400  /* device supports hw statistics version 1 */
-#define DEV_HAS_STATISTICS_V2   0x0800  /* device supports hw statistics version 2 */
-#define DEV_HAS_TEST_EXTENDED   0x1000  /* device supports extended diagnostic test */
-#define DEV_HAS_MGMT_UNIT       0x2000  /* device supports management unit */
-#define DEV_HAS_CORRECT_MACADDR 0x4000  /* device supports correct mac address order */
+#define DEV_NEED_TIMERIRQ          0x00001  /* set the timer irq flag in the irq mask */
+#define DEV_NEED_LINKTIMER         0x00002  /* poll link settings. Relies on the timer irq */
+#define DEV_HAS_LARGEDESC          0x00004  /* device supports jumbo frames and needs packet format 2 */
+#define DEV_HAS_HIGH_DMA           0x00008  /* device supports 64bit dma */
+#define DEV_HAS_CHECKSUM           0x00010  /* device supports tx and rx checksum offloads */
+#define DEV_HAS_VLAN               0x00020  /* device supports vlan tagging and striping */
+#define DEV_HAS_MSI                0x00040  /* device supports MSI */
+#define DEV_HAS_MSI_X              0x00080  /* device supports MSI-X */
+#define DEV_HAS_POWER_CNTRL        0x00100  /* device supports power savings */
+#define DEV_HAS_STATISTICS_V1      0x00200  /* device supports hw statistics version 1 */
+#define DEV_HAS_STATISTICS_V2      0x00400  /* device supports hw statistics version 2 */
+#define DEV_HAS_TEST_EXTENDED      0x00800  /* device supports extended diagnostic test */
+#define DEV_HAS_MGMT_UNIT          0x01000  /* device supports management unit */
+#define DEV_HAS_CORRECT_MACADDR    0x02000  /* device supports correct mac address order */
+#define DEV_HAS_COLLISION_FIX      0x04000  /* device supports tx collision fix */
+#define DEV_HAS_PAUSEFRAME_TX_V1   0x08000  /* device supports tx pause frames version 1 */
+#define DEV_HAS_PAUSEFRAME_TX_V2   0x10000  /* device supports tx pause frames version 2 */
+#define DEV_HAS_PAUSEFRAME_TX_V3   0x20000  /* device supports tx pause frames version 3 */
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -266,9 +269,12 @@ enum {
 #define NVREG_RNDSEED_FORCE3	0x7400
 
 	NvRegTxDeferral = 0xA0,
-#define NVREG_TX_DEFERRAL_DEFAULT	0x15050f
-#define NVREG_TX_DEFERRAL_RGMII_10_100	0x16070f
-#define NVREG_TX_DEFERRAL_RGMII_1000	0x14050f
+#define NVREG_TX_DEFERRAL_DEFAULT		0x15050f
+#define NVREG_TX_DEFERRAL_RGMII_10_100		0x16070f
+#define NVREG_TX_DEFERRAL_RGMII_1000		0x14050f
+#define NVREG_TX_DEFERRAL_RGMII_STRETCH_10	0x16190f
+#define NVREG_TX_DEFERRAL_RGMII_STRETCH_100	0x16300f
+#define NVREG_TX_DEFERRAL_MII_STRETCH		0x152000
 	NvRegRxDeferral = 0xA4,
 #define NVREG_RX_DEFERRAL_DEFAULT	0x16
 	NvRegMacAddrA = 0xA8,
@@ -318,8 +324,10 @@ enum {
 	NvRegTxRingPhysAddrHigh = 0x148,
 	NvRegRxRingPhysAddrHigh = 0x14C,
 	NvRegTxPauseFrame = 0x170,
-#define NVREG_TX_PAUSEFRAME_DISABLE	0x01ff0080
-#define NVREG_TX_PAUSEFRAME_ENABLE	0x01800010
+#define NVREG_TX_PAUSEFRAME_DISABLE	0x0fff0080
+#define NVREG_TX_PAUSEFRAME_ENABLE_V1	0x01800010
+#define NVREG_TX_PAUSEFRAME_ENABLE_V2	0x056003f0
+#define NVREG_TX_PAUSEFRAME_ENABLE_V3	0x09f00880
 	NvRegMIIStatus = 0x180,
 #define NVREG_MIISTAT_ERROR		0x0001
 #define NVREG_MIISTAT_LINKCHANGE	0x0008
@@ -2751,7 +2759,12 @@ static void nv_update_pause(struct net_device *dev, u32 pause_flags)
 	if (np->pause_flags & NV_PAUSEFRAME_TX_CAPABLE) {
 		u32 regmisc = readl(base + NvRegMisc1) & ~NVREG_MISC1_PAUSE_TX;
 		if (pause_flags & NV_PAUSEFRAME_TX_ENABLE) {
-			writel(NVREG_TX_PAUSEFRAME_ENABLE,  base + NvRegTxPauseFrame);
+			u32 pause_enable = NVREG_TX_PAUSEFRAME_ENABLE_V1;
+			if (np->driver_data & DEV_HAS_PAUSEFRAME_TX_V2)
+				pause_enable = NVREG_TX_PAUSEFRAME_ENABLE_V2;
+			if (np->driver_data & DEV_HAS_PAUSEFRAME_TX_V3)
+				pause_enable = NVREG_TX_PAUSEFRAME_ENABLE_V3;
+			writel(pause_enable,  base + NvRegTxPauseFrame);
 			writel(regmisc|NVREG_MISC1_PAUSE_TX, base + NvRegMisc1);
 			np->pause_flags |= NV_PAUSEFRAME_TX_ENABLE;
 		} else {
@@ -2785,6 +2798,7 @@ static int nv_update_linkspeed(struct net_device *dev)
 	int retval = 0;
 	u32 control_1000, status_1000, phyreg, pause_flags, txreg;
 	u32 txrxFlags = 0;
+	u32 phy_exp;
 
 	/* BMSR_LSTATUS is latched, read it twice:
 	 * we want the current value.
@@ -2912,13 +2926,25 @@ set_speed:
 		phyreg |= PHY_1000;
 	writel(phyreg, base + NvRegPhyInterface);
 
+	phy_exp = mii_rw(dev, np->phyaddr, MII_EXPANSION, MII_READ) & EXPANSION_NWAY; /* autoneg capable */
 	if (phyreg & PHY_RGMII) {
-		if ((np->linkspeed & NVREG_LINKSPEED_MASK) == NVREG_LINKSPEED_1000)
+		if ((np->linkspeed & NVREG_LINKSPEED_MASK) == NVREG_LINKSPEED_1000) {
 			txreg = NVREG_TX_DEFERRAL_RGMII_1000;
-		else
-			txreg = NVREG_TX_DEFERRAL_RGMII_10_100;
+		} else {
+			if (!phy_exp && !np->duplex && (np->driver_data & DEV_HAS_COLLISION_FIX)) {
+				if ((np->linkspeed & NVREG_LINKSPEED_MASK) == NVREG_LINKSPEED_10)
+					txreg = NVREG_TX_DEFERRAL_RGMII_STRETCH_10;
+				else
+					txreg = NVREG_TX_DEFERRAL_RGMII_STRETCH_100;
+			} else {
+				txreg = NVREG_TX_DEFERRAL_RGMII_10_100;
+			}
+		}
 	} else {
-		txreg = NVREG_TX_DEFERRAL_DEFAULT;
+		if (!phy_exp && !np->duplex && (np->driver_data & DEV_HAS_COLLISION_FIX))
+			txreg = NVREG_TX_DEFERRAL_MII_STRETCH;
+		else
+			txreg = NVREG_TX_DEFERRAL_DEFAULT;
 	}
 	writel(txreg, base + NvRegTxDeferral);
 
@@ -5155,7 +5181,9 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	}
 
 	np->pause_flags = NV_PAUSEFRAME_RX_CAPABLE | NV_PAUSEFRAME_RX_REQ | NV_PAUSEFRAME_AUTONEG;
-	if (id->driver_data & DEV_HAS_PAUSEFRAME_TX) {
+	if ((id->driver_data & DEV_HAS_PAUSEFRAME_TX_V1) ||
+	    (id->driver_data & DEV_HAS_PAUSEFRAME_TX_V2) ||
+	    (id->driver_data & DEV_HAS_PAUSEFRAME_TX_V3)) {
 		np->pause_flags |= NV_PAUSEFRAME_TX_CAPABLE | NV_PAUSEFRAME_TX_REQ;
 	}
 
@@ -5559,107 +5587,107 @@ static struct pci_device_id pci_tbl[] = {
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_14),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_15),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_16),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_17),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_18),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_19),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_20),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_21),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_22),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_23),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_24),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_25),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_26),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_27),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP73 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_28),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
 	},
 	{	/* MCP73 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_29),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
 	},
 	{	/* MCP73 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_30),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
 	},
 	{	/* MCP73 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_31),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_32),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_33),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_34),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_35),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_36),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_37),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_38),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_39),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX,
 	},
 	{0,},
 };
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index 6b3384a..26aa8fe 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -33,20 +33,20 @@
  * I have also done a look in the following sources: (mail me if you need them)
  *   crynwr-packet-driver by Russ Nelson
  *   Garret A. Wollman's (fourth) i82586-driver for BSD
- *   (before getting an i82596 (yes 596 not 586) manual, the existing drivers helped
- *    me a lot to understand this tricky chip.)
+ *   (before getting an i82596 (yes 596 not 586) manual, the existing drivers
+ *    helped me a lot to understand this tricky chip.)
  *
  * Known Problems:
  *   The internal sysbus seems to be slow. So we often lose packets because of
  *   overruns while receiving from a fast remote host.
- *   This can slow down TCP connections. Maybe the newer ni5210 cards are better.
- *   my experience is, that if a machine sends with more than about 500-600K/s
- *   the fifo/sysbus overflows.
+ *   This can slow down TCP connections. Maybe the newer ni5210 cards are
+ *   better. My experience is, that if a machine sends with more than about
+ *   500-600K/s the fifo/sysbus overflows.
  *
  * IMPORTANT NOTE:
  *   On fast networks, it's a (very) good idea to have 16K shared memory. With
- *   8K, we can store only 4 receive frames, so it can (easily) happen that a remote
- *   machine 'overruns' our system.
+ *   8K, we can store only 4 receive frames, so it can (easily) happen that a
+ *   remote machine 'overruns' our system.
  *
  * Known i82586/card problems (I'm sure, there are many more!):
  *   Running the NOP-mode, the i82586 sometimes seems to forget to report
@@ -60,7 +60,8 @@
  *
  * results from ftp performance tests with Linux 1.2.5
  *   send and receive about 350-400 KByte/s (peak up to 460 kbytes/s)
- *   sending in NOP-mode: peak performance up to 530K/s (but better don't run this mode)
+ *   sending in NOP-mode: peak performance up to 530K/s (but better don't
+ *   run this mode)
  */
 
 /*
@@ -94,7 +95,8 @@
  *
  * 26.March.94: patches for Linux 1.0 and iomem-auto-probe (MH)
  *
- * 30.Sep.93: Added nop-chain .. driver now runs with only one Xmit-Buff, too (MH)
+ * 30.Sep.93: Added nop-chain .. driver now runs with only one Xmit-Buff,
+ *				too (MH)
  *
  * < 30.Sep.93: first versions
  */
@@ -102,7 +104,7 @@
 static int debuglevel;	/* debug-printk 0: off 1: a few 2: more */
 static int automatic_resume; /* experimental .. better should be zero */
 static int rfdadd;	/* rfdadd=1 may be better for 8K MEM cards */
-static int fifo=0x8;	/* don't change */
+static int fifo = 0x8;	/* don't change */
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -127,14 +129,15 @@ static int fifo=0x8;	/* don't change */
 #define DEBUG       /* debug on */
 #define SYSBUSVAL 1 /* 8 Bit */
 
-#define ni_attn586()  {outb(0,dev->base_addr+NI52_ATTENTION);}
-#define ni_reset586() {outb(0,dev->base_addr+NI52_RESET);}
-#define ni_disint()   {outb(0,dev->base_addr+NI52_INTDIS);}
-#define ni_enaint()   {outb(0,dev->base_addr+NI52_INTENA);}
+#define ni_attn586()  { outb(0, dev->base_addr + NI52_ATTENTION); }
+#define ni_reset586() { outb(0, dev->base_addr + NI52_RESET); }
+#define ni_disint()   { outb(0, dev->base_addr + NI52_INTDIS); }
+#define ni_enaint()   { outb(0, dev->base_addr + NI52_INTENA); }
 
-#define make32(ptr16) (p->memtop + (short) (ptr16) )
-#define make24(ptr32) ( ((char *) (ptr32)) - p->base)
-#define make16(ptr32) ((unsigned short) ((unsigned long)(ptr32) - (unsigned long) p->memtop ))
+#define make32(ptr16) (p->memtop + (short) (ptr16))
+#define make24(ptr32) ((unsigned long)(ptr32)) - p->base
+#define make16(ptr32) ((unsigned short) ((unsigned long)(ptr32)\
+					- (unsigned long) p->memtop))
 
 /******************* how to calculate the buffers *****************************
 
@@ -159,96 +162,112 @@ sizeof(nop_cmd) = 8;
 
 /**************************************************************************/
 
-/* different DELAYs */
-#define DELAY(x) mdelay(32 * x);
-#define DELAY_16(); { udelay(16); }
-#define DELAY_18(); { udelay(4); }
-
-/* wait for command with timeout: */
-#define WAIT_4_SCB_CMD() \
-{ int i; \
-  for(i=0;i<16384;i++) { \
-    if(!p->scb->cmd_cuc) break; \
-    DELAY_18(); \
-    if(i == 16383) { \
-      printk("%s: scb_cmd timed out: %04x,%04x .. disabling i82586!!\n",dev->name,p->scb->cmd_cuc,p->scb->cus); \
-       if(!p->reseted) { p->reseted = 1; ni_reset586(); } } } }
-
-#define WAIT_4_SCB_CMD_RUC() { int i; \
-  for(i=0;i<16384;i++) { \
-    if(!p->scb->cmd_ruc) break; \
-    DELAY_18(); \
-    if(i == 16383) { \
-      printk("%s: scb_cmd (ruc) timed out: %04x,%04x .. disabling i82586!!\n",dev->name,p->scb->cmd_ruc,p->scb->rus); \
-       if(!p->reseted) { p->reseted = 1; ni_reset586(); } } } }
-
-#define WAIT_4_STAT_COMPL(addr) { int i; \
-   for(i=0;i<32767;i++) { \
-     if((addr)->cmd_status & STAT_COMPL) break; \
-     DELAY_16(); DELAY_16(); } }
 
 #define NI52_TOTAL_SIZE 16
 #define NI52_ADDR0 0x02
 #define NI52_ADDR1 0x07
 #define NI52_ADDR2 0x01
 
-static int     ni52_probe1(struct net_device *dev,int ioaddr);
-static irqreturn_t ni52_interrupt(int irq,void *dev_id);
+static int     ni52_probe1(struct net_device *dev, int ioaddr);
+static irqreturn_t ni52_interrupt(int irq, void *dev_id);
 static int     ni52_open(struct net_device *dev);
 static int     ni52_close(struct net_device *dev);
-static int     ni52_send_packet(struct sk_buff *,struct net_device *);
+static int     ni52_send_packet(struct sk_buff *, struct net_device *);
 static struct  net_device_stats *ni52_get_stats(struct net_device *dev);
 static void    set_multicast_list(struct net_device *dev);
 static void    ni52_timeout(struct net_device *dev);
-#if 0
-static void    ni52_dump(struct net_device *,void *);
-#endif
 
 /* helper-functions */
 static int     init586(struct net_device *dev);
-static int     check586(struct net_device *dev,char *where,unsigned size);
+static int     check586(struct net_device *dev, char *where, unsigned size);
 static void    alloc586(struct net_device *dev);
 static void    startrecv586(struct net_device *dev);
-static void   *alloc_rfa(struct net_device *dev,void *ptr);
+static void   *alloc_rfa(struct net_device *dev, void *ptr);
 static void    ni52_rcv_int(struct net_device *dev);
 static void    ni52_xmt_int(struct net_device *dev);
 static void    ni52_rnr_int(struct net_device *dev);
 
-struct priv
-{
+struct priv {
 	struct net_device_stats stats;
 	unsigned long base;
 	char *memtop;
-	long int lock;
-	int reseted;
-	volatile struct rfd_struct	*rfd_last,*rfd_top,*rfd_first;
-	volatile struct scp_struct	*scp;	/* volatile is important */
-	volatile struct iscp_struct	*iscp;	/* volatile is important */
-	volatile struct scb_struct	*scb;	/* volatile is important */
-	volatile struct tbd_struct	*xmit_buffs[NUM_XMIT_BUFFS];
+	spinlock_t spinlock;
+	int reset;
+	struct rfd_struct *rfd_last, *rfd_top, *rfd_first;
+	struct scp_struct *scp;
+	struct iscp_struct *iscp;
+	struct scb_struct *scb;
+	struct tbd_struct *xmit_buffs[NUM_XMIT_BUFFS];
 #if (NUM_XMIT_BUFFS == 1)
-	volatile struct transmit_cmd_struct *xmit_cmds[2];
-	volatile struct nop_cmd_struct *nop_cmds[2];
+	struct transmit_cmd_struct *xmit_cmds[2];
+	struct nop_cmd_struct *nop_cmds[2];
 #else
-	volatile struct transmit_cmd_struct *xmit_cmds[NUM_XMIT_BUFFS];
-	volatile struct nop_cmd_struct *nop_cmds[NUM_XMIT_BUFFS];
+	struct transmit_cmd_struct *xmit_cmds[NUM_XMIT_BUFFS];
+	struct nop_cmd_struct *nop_cmds[NUM_XMIT_BUFFS];
 #endif
-	volatile int		nop_point,num_recv_buffs;
-	volatile char		*xmit_cbuffs[NUM_XMIT_BUFFS];
-	volatile int		xmit_count,xmit_last;
+	int nop_point, num_recv_buffs;
+	char *xmit_cbuffs[NUM_XMIT_BUFFS];
+	int xmit_count, xmit_last;
 };
 
+/* wait for command with timeout: */
+static void wait_for_scb_cmd(struct net_device *dev)
+{
+	struct priv *p = dev->priv;
+	int i;
+	for (i = 0; i < 16384; i++) {
+		if (readb(&p->scb->cmd_cuc) == 0)
+		      break;
+		udelay(4);
+		if (i == 16383) {
+			printk(KERN_ERR "%s: scb_cmd timed out: %04x,%04x .. disabling i82586!!\n",
+				dev->name, readb(&p->scb->cmd_cuc), readb(&p->scb->cus));
+			if (!p->reset) {
+				p->reset = 1;
+				ni_reset586();
+			}
+		}
+	}
+}
+
+static void wait_for_scb_cmd_ruc(struct net_device *dev)
+{
+	struct priv *p = dev->priv;
+	int i;
+	for (i = 0; i < 16384; i++) {
+		if (readb(&p->scb->cmd_ruc) == 0)
+			break;
+		udelay(4);
+		if (i == 16383) {
+			printk(KERN_ERR "%s: scb_cmd (ruc) timed out: %04x,%04x .. disabling i82586!!\n",
+				dev->name, p->scb->cmd_ruc, p->scb->rus);
+			if (!p->reset) {
+				p->reset = 1;
+				ni_reset586();
+			}
+		}
+	}
+}
+
+static void wait_for_stat_compl(void *p)
+{
+	struct nop_cmd_struct *addr = p;
+	int i;
+	for (i = 0; i < 32767; i++) {
+		if (readw(&((addr)->cmd_status)) & STAT_COMPL)
+			break;
+		udelay(32);
+	}
+}
+
 /**********************************************
  * close device
  */
 static int ni52_close(struct net_device *dev)
 {
 	free_irq(dev->irq, dev);
-
 	ni_reset586(); /* the hard way to stop the receiver */
-
 	netif_stop_queue(dev);
-
 	return 0;
 }
 
@@ -265,55 +284,53 @@ static int ni52_open(struct net_device *dev)
 	startrecv586(dev);
 	ni_enaint();
 
-	ret = request_irq(dev->irq, &ni52_interrupt,0,dev->name,dev);
-	if (ret)
-	{
+	ret = request_irq(dev->irq, &ni52_interrupt, 0, dev->name, dev);
+	if (ret) {
 		ni_reset586();
 		return ret;
 	}
-
 	netif_start_queue(dev);
-
 	return 0; /* most done by init */
 }
 
 /**********************************************
  * Check to see if there's an 82586 out there.
  */
-static int check586(struct net_device *dev,char *where,unsigned size)
+static int check586(struct net_device *dev, char *where, unsigned size)
 {
 	struct priv pb;
 	struct priv *p = /* (struct priv *) dev->priv*/ &pb;
 	char *iscp_addrs[2];
 	int i;
 
-	p->base = (unsigned long) isa_bus_to_virt((unsigned long)where) + size - 0x01000000;
+	p->base = (unsigned long) isa_bus_to_virt((unsigned long)where)
+							+ size - 0x01000000;
 	p->memtop = isa_bus_to_virt((unsigned long)where) + size;
 	p->scp = (struct scp_struct *)(p->base + SCP_DEFAULT_ADDRESS);
-	memset((char *)p->scp,0, sizeof(struct scp_struct));
-	for(i=0;i<sizeof(struct scp_struct);i++) /* memory was writeable? */
-		if(((char *)p->scp)[i])
+	memset_io((char *)p->scp, 0, sizeof(struct scp_struct));
+	for (i = 0; i < sizeof(struct scp_struct); i++)
+		/* memory was writeable? */
+		if (readb((char *)p->scp + i))
 			return 0;
-	p->scp->sysbus = SYSBUSVAL;				/* 1 = 8Bit-Bus, 0 = 16 Bit */
-	if(p->scp->sysbus != SYSBUSVAL)
+	writeb(SYSBUSVAL, &p->scp->sysbus);	/* 1 = 8Bit-Bus, 0 = 16 Bit */
+	if (readb(&p->scp->sysbus) != SYSBUSVAL)
 		return 0;
 
 	iscp_addrs[0] = isa_bus_to_virt((unsigned long)where);
-	iscp_addrs[1]= (char *) p->scp - sizeof(struct iscp_struct);
+	iscp_addrs[1] = (char *) p->scp - sizeof(struct iscp_struct);
 
-	for(i=0;i<2;i++)
-	{
+	for (i = 0; i < 2; i++) {
 		p->iscp = (struct iscp_struct *) iscp_addrs[i];
-		memset((char *)p->iscp,0, sizeof(struct iscp_struct));
+		memset_io((char *)p->iscp, 0, sizeof(struct iscp_struct));
 
-		p->scp->iscp = make24(p->iscp);
-		p->iscp->busy = 1;
+		writel(make24(p->iscp), &p->scp->iscp);
+		writeb(1, &p->iscp->busy);
 
 		ni_reset586();
 		ni_attn586();
-		DELAY(1);	/* wait a while... */
-
-		if(p->iscp->busy) /* i82586 clears 'busy' after successful init */
+		mdelay(32);	/* wait a while... */
+		/* i82586 clears 'busy' after successful init */
+		if (readb(&p->iscp->busy))
 			return 0;
 	}
 	return 1;
@@ -327,36 +344,39 @@ static void alloc586(struct net_device *dev)
 	struct priv *p =	(struct priv *) dev->priv;
 
 	ni_reset586();
-	DELAY(1);
+	mdelay(32);
+
+	spin_lock_init(&p->spinlock);
 
 	p->scp	= (struct scp_struct *)	(p->base + SCP_DEFAULT_ADDRESS);
 	p->scb	= (struct scb_struct *)	isa_bus_to_virt(dev->mem_start);
-	p->iscp = (struct iscp_struct *) ((char *)p->scp - sizeof(struct iscp_struct));
+	p->iscp = (struct iscp_struct *)
+			((char *)p->scp - sizeof(struct iscp_struct));
 
-	memset((char *) p->iscp,0,sizeof(struct iscp_struct));
-	memset((char *) p->scp ,0,sizeof(struct scp_struct));
+	memset_io(p->iscp, 0, sizeof(struct iscp_struct));
+	memset_io(p->scp , 0, sizeof(struct scp_struct));
 
-	p->scp->iscp = make24(p->iscp);
-	p->scp->sysbus = SYSBUSVAL;
-	p->iscp->scb_offset = make16(p->scb);
+	writel(make24(p->iscp), &p->scp->iscp);
+	writeb(SYSBUSVAL, &p->scp->sysbus);
+	writew(make16(p->scb), &p->iscp->scb_offset);
 
-	p->iscp->busy = 1;
+	writeb(1, &p->iscp->busy);
 	ni_reset586();
 	ni_attn586();
 
-	DELAY(1);
+	mdelay(32);
 
-	if(p->iscp->busy)
-		printk("%s: Init-Problems (alloc).\n",dev->name);
+	if (readb(&p->iscp->busy))
+		printk(KERN_ERR "%s: Init-Problems (alloc).\n", dev->name);
 
-	p->reseted = 0;
+	p->reset = 0;
 
-	memset((char *)p->scb,0,sizeof(struct scb_struct));
+	memset_io((char *)p->scb, 0, sizeof(struct scb_struct));
 }
 
 /* set: io,irq,memstart,memend or set it when calling insmod */
-static int irq=9;
-static int io=0x300;
+static int irq = 9;
+static int io = 0x300;
 static long memstart;	/* e.g 0xd0000 */
 static long memend;	/* e.g 0xd4000 */
 
@@ -413,7 +433,7 @@ out:
 	return ERR_PTR(err);
 }
 
-static int __init ni52_probe1(struct net_device *dev,int ioaddr)
+static int __init ni52_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, size, retval;
 
@@ -425,90 +445,96 @@ static int __init ni52_probe1(struct net_device *dev,int ioaddr)
 	if (!request_region(ioaddr, NI52_TOTAL_SIZE, DRV_NAME))
 		return -EBUSY;
 
-	if( !(inb(ioaddr+NI52_MAGIC1) == NI52_MAGICVAL1) ||
+	if (!(inb(ioaddr+NI52_MAGIC1) == NI52_MAGICVAL1) ||
 	    !(inb(ioaddr+NI52_MAGIC2) == NI52_MAGICVAL2)) {
 		retval = -ENODEV;
 		goto out;
 	}
 
-	for(i=0;i<ETH_ALEN;i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = inb(dev->base_addr+i);
 
-	if(dev->dev_addr[0] != NI52_ADDR0 || dev->dev_addr[1] != NI52_ADDR1
+	if (dev->dev_addr[0] != NI52_ADDR0 || dev->dev_addr[1] != NI52_ADDR1
 		 || dev->dev_addr[2] != NI52_ADDR2) {
 		retval = -ENODEV;
 		goto out;
 	}
 
-	printk(KERN_INFO "%s: NI5210 found at %#3lx, ",dev->name,dev->base_addr);
+	printk(KERN_INFO "%s: NI5210 found at %#3lx, ",
+				dev->name, dev->base_addr);
 
 	/*
 	 * check (or search) IO-Memory, 8K and 16K
 	 */
 #ifdef MODULE
 	size = dev->mem_end - dev->mem_start;
-	if(size != 0x2000 && size != 0x4000) {
-		printk("\n%s: Illegal memory size %d. Allowed is 0x2000 or 0x4000 bytes.\n",dev->name,size);
+	if (size != 0x2000 && size != 0x4000) {
+		printk("\n");
+		printk(KERN_ERR "%s: Invalid memory size %d. Allowed is 0x2000 or 0x4000 bytes.\n", dev->name, size);
 		retval = -ENODEV;
 		goto out;
 	}
-	if(!check586(dev,(char *) dev->mem_start,size)) {
-		printk("?memcheck, Can't find memory at 0x%lx with size %d!\n",dev->mem_start,size);
+	if (!check586(dev, (char *)dev->mem_start, size)) {
+		printk(KERN_ERR "?memcheck, Can't find memory at 0x%lx with size %d!\n", dev->mem_start, size);
 		retval = -ENODEV;
 		goto out;
 	}
 #else
-	if(dev->mem_start != 0) /* no auto-mem-probe */
-	{
+	if (dev->mem_start != 0) {
+		/* no auto-mem-probe */
 		size = 0x4000; /* check for 16K mem */
-		if(!check586(dev,(char *) dev->mem_start,size)) {
+		if (!check586(dev, (char *) dev->mem_start, size)) {
 			size = 0x2000; /* check for 8K mem */
-			if(!check586(dev,(char *) dev->mem_start,size)) {
-				printk("?memprobe, Can't find memory at 0x%lx!\n",dev->mem_start);
+			if (!check586(dev, (char *)dev->mem_start, size)) {
+				printk(KERN_ERR "?memprobe, Can't find memory at 0x%lx!\n", dev->mem_start);
 				retval = -ENODEV;
 				goto out;
 			}
 		}
-	}
-	else
-	{
-		static long memaddrs[] = { 0xc8000,0xca000,0xcc000,0xce000,0xd0000,0xd2000,
-					0xd4000,0xd6000,0xd8000,0xda000,0xdc000, 0 };
-		for(i=0;;i++)
-		{
-			if(!memaddrs[i]) {
-				printk("?memprobe, Can't find io-memory!\n");
+	} else {
+		static const unsigned long memaddrs[] = {
+			0xc8000, 0xca000, 0xcc000, 0xce000, 0xd0000, 0xd2000,
+			0xd4000, 0xd6000, 0xd8000, 0xda000, 0xdc000, 0
+		};
+		for (i = 0;; i++) {
+			if (!memaddrs[i]) {
+				printk(KERN_ERR "?memprobe, Can't find io-memory!\n");
 				retval = -ENODEV;
 				goto out;
 			}
 			dev->mem_start = memaddrs[i];
 			size = 0x2000; /* check for 8K mem */
-			if(check586(dev,(char *)dev->mem_start,size)) /* 8K-check */
+			if (check586(dev, (char *)dev->mem_start, size))
+				/* 8K-check */
 				break;
 			size = 0x4000; /* check for 16K mem */
-			if(check586(dev,(char *)dev->mem_start,size)) /* 16K-check */
+			if (check586(dev, (char *)dev->mem_start, size))
+				/* 16K-check */
 				break;
 		}
 	}
-	dev->mem_end = dev->mem_start + size; /* set mem_end showed by 'ifconfig' */
+	/* set mem_end showed by 'ifconfig' */
+	dev->mem_end = dev->mem_start + size;
 #endif
 
-	memset((char *) dev->priv,0,sizeof(struct priv));
+	memset((char *)dev->priv, 0, sizeof(struct priv));
 
-	((struct priv *) (dev->priv))->memtop = isa_bus_to_virt(dev->mem_start) + size;
-	((struct priv *) (dev->priv))->base =	(unsigned long) isa_bus_to_virt(dev->mem_start) + size - 0x01000000;
+	((struct priv *)(dev->priv))->memtop =
+				isa_bus_to_virt(dev->mem_start) + size;
+	((struct priv *)(dev->priv))->base =  (unsigned long)
+			isa_bus_to_virt(dev->mem_start) + size - 0x01000000;
 	alloc586(dev);
 
 	/* set number of receive-buffs according to memsize */
-	if(size == 0x2000)
+	if (size == 0x2000)
 		((struct priv *) dev->priv)->num_recv_buffs = NUM_RECV_BUFFS_8;
 	else
 		((struct priv *) dev->priv)->num_recv_buffs = NUM_RECV_BUFFS_16;
 
-	printk("Memaddr: 0x%lx, Memsize: %d, ",dev->mem_start,size);
+	printk(KERN_DEBUG "Memaddr: 0x%lx, Memsize: %d, ",
+				dev->mem_start, size);
 
-	if(dev->irq < 2)
-	{
+	if (dev->irq < 2) {
 		unsigned long irq_mask;
 
 		irq_mask = probe_irq_on();
@@ -517,18 +543,16 @@ static int __init ni52_probe1(struct net_device *dev,int ioaddr)
 
 		mdelay(20);
 		dev->irq = probe_irq_off(irq_mask);
-		if(!dev->irq)
-		{
+		if (!dev->irq) {
 			printk("?autoirq, Failed to detect IRQ line!\n");
 			retval = -EAGAIN;
 			goto out;
 		}
-		printk("IRQ %d (autodetected).\n",dev->irq);
-	}
-	else	{
-		if(dev->irq == 2)
+		printk("IRQ %d (autodetected).\n", dev->irq);
+	} else {
+		if (dev->irq == 2)
 			dev->irq = 9;
-		printk("IRQ %d (assigned and not checked!).\n",dev->irq);
+		printk("IRQ %d (assigned and not checked!).\n", dev->irq);
 	}
 
 	dev->open		= ni52_open;
@@ -555,56 +579,58 @@ out:
 static int init586(struct net_device *dev)
 {
 	void *ptr;
-	int i,result=0;
-	struct priv *p = (struct priv *) dev->priv;
-	volatile struct configure_cmd_struct	*cfg_cmd;
-	volatile struct iasetup_cmd_struct *ias_cmd;
-	volatile struct tdr_cmd_struct *tdr_cmd;
-	volatile struct mcsetup_cmd_struct *mc_cmd;
-	struct dev_mc_list *dmi=dev->mc_list;
-	int num_addrs=dev->mc_count;
+	int i, result = 0;
+	struct priv *p = (struct priv *)dev->priv;
+	struct configure_cmd_struct *cfg_cmd;
+	struct iasetup_cmd_struct *ias_cmd;
+	struct tdr_cmd_struct *tdr_cmd;
+	struct mcsetup_cmd_struct *mc_cmd;
+	struct dev_mc_list *dmi = dev->mc_list;
+	int num_addrs = dev->mc_count;
 
 	ptr = (void *) ((char *)p->scb + sizeof(struct scb_struct));
 
 	cfg_cmd = (struct configure_cmd_struct *)ptr; /* configure-command */
-	cfg_cmd->cmd_status	= 0;
-	cfg_cmd->cmd_cmd	= CMD_CONFIGURE | CMD_LAST;
-	cfg_cmd->cmd_link	= 0xffff;
-
-	cfg_cmd->byte_cnt	= 0x0a; /* number of cfg bytes */
-	cfg_cmd->fifo		= fifo; /* fifo-limit (8=tx:32/rx:64) */
-	cfg_cmd->sav_bf		= 0x40; /* hold or discard bad recv frames (bit 7) */
-	cfg_cmd->adr_len	= 0x2e; /* addr_len |!src_insert |pre-len |loopback */
-	cfg_cmd->priority	= 0x00;
-	cfg_cmd->ifs		= 0x60;
-	cfg_cmd->time_low	= 0x00;
-	cfg_cmd->time_high	= 0xf2;
-	cfg_cmd->promisc	= 0;
-	if(dev->flags & IFF_ALLMULTI) {
+	writew(0, &cfg_cmd->cmd_status);
+	writew(CMD_CONFIGURE | CMD_LAST, &cfg_cmd->cmd_cmd);
+	writew(0xFFFF, &cfg_cmd->cmd_link);
+
+	/* number of cfg bytes */
+	writeb(0x0a, &cfg_cmd->byte_cnt);
+	/* fifo-limit (8=tx:32/rx:64) */
+	writeb(fifo, &cfg_cmd->fifo);
+	/* hold or discard bad recv frames (bit 7) */
+	writeb(0x40, &cfg_cmd->sav_bf);
+	/* addr_len |!src_insert |pre-len |loopback */
+	writeb(0x2e, &cfg_cmd->adr_len);
+	writeb(0x00, &cfg_cmd->priority);
+	writeb(0x60, &cfg_cmd->ifs);;
+	writeb(0x00, &cfg_cmd->time_low);
+	writeb(0xf2, &cfg_cmd->time_high);
+	writeb(0x00, &cfg_cmd->promisc);;
+	if (dev->flags & IFF_ALLMULTI) {
 		int len = ((char *) p->iscp - (char *) ptr - 8) / 6;
-		if(num_addrs > len)	{
-			printk("%s: switching to promisc. mode\n",dev->name);
-			dev->flags|=IFF_PROMISC;
+		if (num_addrs > len) {
+			printk(KERN_ERR "%s: switching to promisc. mode\n",
+				dev->name);
+			dev->flags |= IFF_PROMISC;
 		}
 	}
-	if(dev->flags&IFF_PROMISC)
-	{
-			 cfg_cmd->promisc=1;
-			 dev->flags|=IFF_PROMISC;
-	}
-	cfg_cmd->carr_coll	= 0x00;
+	if (dev->flags & IFF_PROMISC)
+		writeb(0x01, &cfg_cmd->promisc);
+	writeb(0x00, &cfg_cmd->carr_coll);
+	writew(make16(cfg_cmd), &p->scb->cbl_offset);
+	writew(0, &p->scb->cmd_ruc);
 
-	p->scb->cbl_offset	= make16(cfg_cmd);
-	p->scb->cmd_ruc		= 0;
-
-	p->scb->cmd_cuc		= CUC_START; /* cmd.-unit start */
+	writeb(CUC_START, &p->scb->cmd_cuc); /* cmd.-unit start */
 	ni_attn586();
 
-	WAIT_4_STAT_COMPL(cfg_cmd);
+	wait_for_stat_compl(cfg_cmd);
 
-	if((cfg_cmd->cmd_status & (STAT_OK|STAT_COMPL)) != (STAT_COMPL|STAT_OK))
-	{
-		printk("%s: configure command failed: %x\n",dev->name,cfg_cmd->cmd_status);
+	if ((readw(&cfg_cmd->cmd_status) & (STAT_OK|STAT_COMPL)) !=
+							(STAT_COMPL|STAT_OK)) {
+		printk(KERN_ERR "%s: configure command failed: %x\n",
+				dev->name, readw(&cfg_cmd->cmd_status));
 		return 1;
 	}
 
@@ -614,21 +640,22 @@ static int init586(struct net_device *dev)
 
 	ias_cmd = (struct iasetup_cmd_struct *)ptr;
 
-	ias_cmd->cmd_status	= 0;
-	ias_cmd->cmd_cmd	= CMD_IASETUP | CMD_LAST;
-	ias_cmd->cmd_link	= 0xffff;
+	writew(0, &ias_cmd->cmd_status);
+	writew(CMD_IASETUP | CMD_LAST, &ias_cmd->cmd_cmd);
+	writew(0xffff, &ias_cmd->cmd_link);
 
-	memcpy((char *)&ias_cmd->iaddr,(char *) dev->dev_addr,ETH_ALEN);
+	memcpy_toio((char *)&ias_cmd->iaddr, (char *)dev->dev_addr, ETH_ALEN);
 
-	p->scb->cbl_offset = make16(ias_cmd);
+	writew(make16(ias_cmd), &p->scb->cbl_offset);
 
-	p->scb->cmd_cuc = CUC_START; /* cmd.-unit start */
+	writeb(CUC_START, &p->scb->cmd_cuc); /* cmd.-unit start */
 	ni_attn586();
 
-	WAIT_4_STAT_COMPL(ias_cmd);
+	wait_for_stat_compl(ias_cmd);
 
-	if((ias_cmd->cmd_status & (STAT_OK|STAT_COMPL)) != (STAT_OK|STAT_COMPL)) {
-		printk("%s (ni52): individual address setup command failed: %04x\n",dev->name,ias_cmd->cmd_status);
+	if ((readw(&ias_cmd->cmd_status) & (STAT_OK|STAT_COMPL)) !=
+							(STAT_OK|STAT_COMPL)) {
+		printk(KERN_ERR "%s (ni52): individual address setup command failed: %04x\n", dev->name, readw(&ias_cmd->cmd_status));
 		return 1;
 	}
 
@@ -638,117 +665,119 @@ static int init586(struct net_device *dev)
 
 	tdr_cmd = (struct tdr_cmd_struct *)ptr;
 
-	tdr_cmd->cmd_status	= 0;
-	tdr_cmd->cmd_cmd	= CMD_TDR | CMD_LAST;
-	tdr_cmd->cmd_link	= 0xffff;
-	tdr_cmd->status		= 0;
+	writew(0, &tdr_cmd->cmd_status);
+	writew(CMD_TDR | CMD_LAST, &tdr_cmd->cmd_cmd);
+	writew(0xffff, &tdr_cmd->cmd_link);
+	writew(0, &tdr_cmd->status);
 
-	p->scb->cbl_offset = make16(tdr_cmd);
-	p->scb->cmd_cuc = CUC_START; /* cmd.-unit start */
+	writew(make16(tdr_cmd), &p->scb->cbl_offset);
+	writeb(CUC_START, &p->scb->cmd_cuc); /* cmd.-unit start */
 	ni_attn586();
 
-	WAIT_4_STAT_COMPL(tdr_cmd);
-
-	if(!(tdr_cmd->cmd_status & STAT_COMPL))
-	{
-		printk("%s: Problems while running the TDR.\n",dev->name);
-	}
-	else
-	{
-		DELAY_16(); /* wait for result */
-		result = tdr_cmd->status;
+	wait_for_stat_compl(tdr_cmd);
 
-		p->scb->cmd_cuc = p->scb->cus & STAT_MASK;
+	if (!(readw(&tdr_cmd->cmd_status) & STAT_COMPL))
+		printk(KERN_ERR "%s: Problems while running the TDR.\n",
+				dev->name);
+	else {
+		udelay(16);
+		result = readw(&tdr_cmd->status);
+		writeb(readb(&p->scb->cus) & STAT_MASK, &p->scb->cmd_cuc);
 		ni_attn586(); /* ack the interrupts */
 
-		if(result & TDR_LNK_OK)
+		if (result & TDR_LNK_OK)
 			;
-		else if(result & TDR_XCVR_PRB)
-			printk("%s: TDR: Transceiver problem. Check the cable(s)!\n",dev->name);
-		else if(result & TDR_ET_OPN)
-			printk("%s: TDR: No correct termination %d clocks away.\n",dev->name,result & TDR_TIMEMASK);
-		else if(result & TDR_ET_SRT)
-		{
-			if (result & TDR_TIMEMASK) /* time == 0 -> strange :-) */
-				printk("%s: TDR: Detected a short circuit %d clocks away.\n",dev->name,result & TDR_TIMEMASK);
-		}
-		else
-			printk("%s: TDR: Unknown status %04x\n",dev->name,result);
+		else if (result & TDR_XCVR_PRB)
+			printk(KERN_ERR "%s: TDR: Transceiver problem. Check the cable(s)!\n",
+				dev->name);
+		else if (result & TDR_ET_OPN)
+			printk(KERN_ERR "%s: TDR: No correct termination %d clocks away.\n",
+				dev->name, result & TDR_TIMEMASK);
+		else if (result & TDR_ET_SRT) {
+			/* time == 0 -> strange :-) */
+			if (result & TDR_TIMEMASK)
+				printk(KERN_ERR "%s: TDR: Detected a short circuit %d clocks away.\n",
+					dev->name, result & TDR_TIMEMASK);
+		} else
+			printk(KERN_ERR "%s: TDR: Unknown status %04x\n",
+						dev->name, result);
 	}
 
 	/*
 	 * Multicast setup
 	 */
-	if(num_addrs && !(dev->flags & IFF_PROMISC) )
-	{
+	if (num_addrs && !(dev->flags & IFF_PROMISC)) {
 		mc_cmd = (struct mcsetup_cmd_struct *) ptr;
-		mc_cmd->cmd_status = 0;
-		mc_cmd->cmd_cmd = CMD_MCSETUP | CMD_LAST;
-		mc_cmd->cmd_link = 0xffff;
-		mc_cmd->mc_cnt = num_addrs * 6;
+		writew(0, &mc_cmd->cmd_status);
+		writew(CMD_MCSETUP | CMD_LAST, &mc_cmd->cmd_cmd);
+		writew(0xffff, &mc_cmd->cmd_link);
+		writew(num_addrs * 6, &mc_cmd->mc_cnt);
 
-		for(i=0;i<num_addrs;i++,dmi=dmi->next)
-			memcpy((char *) mc_cmd->mc_list[i], dmi->dmi_addr,6);
+		for (i = 0; i < num_addrs; i++, dmi = dmi->next)
+			memcpy_toio((char *) mc_cmd->mc_list[i],
+							dmi->dmi_addr, 6);
 
-		p->scb->cbl_offset = make16(mc_cmd);
-		p->scb->cmd_cuc = CUC_START;
+		writew(make16(mc_cmd), &p->scb->cbl_offset);
+		writeb(CUC_START, &p->scb->cmd_cuc);
 		ni_attn586();
 
-		WAIT_4_STAT_COMPL(mc_cmd);
+		wait_for_stat_compl(mc_cmd);
 
-		if( (mc_cmd->cmd_status & (STAT_COMPL|STAT_OK)) != (STAT_COMPL|STAT_OK) )
-			printk("%s: Can't apply multicast-address-list.\n",dev->name);
+		if ((readw(&mc_cmd->cmd_status) & (STAT_COMPL|STAT_OK))
+						 != (STAT_COMPL|STAT_OK))
+			printk(KERN_ERR "%s: Can't apply multicast-address-list.\n", dev->name);
 	}
 
 	/*
 	 * alloc nop/xmit-cmds
 	 */
 #if (NUM_XMIT_BUFFS == 1)
-	for(i=0;i<2;i++)
-	{
-		p->nop_cmds[i] 			= (struct nop_cmd_struct *)ptr;
-		p->nop_cmds[i]->cmd_cmd		= CMD_NOP;
-		p->nop_cmds[i]->cmd_status 	= 0;
-		p->nop_cmds[i]->cmd_link	= make16((p->nop_cmds[i]));
+	for (i = 0; i < 2; i++) {
+		p->nop_cmds[i] = (struct nop_cmd_struct *)ptr;
+		writew(CMD_NOP, &p->nop_cmds[i]->cmd_cmd);
+		writew(0, &p->nop_cmds[i]->cmd_status);
+		writew(make16(p->nop_cmds[i]), &p->nop_cmds[i]->cmd_link);
 		ptr = (char *) ptr + sizeof(struct nop_cmd_struct);
 	}
 #else
-	for(i=0;i<NUM_XMIT_BUFFS;i++)
-	{
-		p->nop_cmds[i]			= (struct nop_cmd_struct *)ptr;
-		p->nop_cmds[i]->cmd_cmd		= CMD_NOP;
-		p->nop_cmds[i]->cmd_status	= 0;
-		p->nop_cmds[i]->cmd_link	= make16((p->nop_cmds[i]));
+	for (i = 0; i < NUM_XMIT_BUFFS; i++) {
+		p->nop_cmds[i] = (struct nop_cmd_struct *)ptr;
+		writew(CMD_NOP, &p->nop_cmds[i]->cmd_cmd);
+		writew(0, &p->nop_cmds[i]->cmd_status);
+		writew(make16(p->nop_cmds[i]), &p->nop_cmds[i]->cmd_link);
 		ptr = (char *) ptr + sizeof(struct nop_cmd_struct);
 	}
 #endif
 
-	ptr = alloc_rfa(dev,(void *)ptr); /* init receive-frame-area */
+	ptr = alloc_rfa(dev, (void *)ptr); /* init receive-frame-area */
 
 	/*
 	 * alloc xmit-buffs / init xmit_cmds
 	 */
-	for(i=0;i<NUM_XMIT_BUFFS;i++)
-	{
-		p->xmit_cmds[i] = (struct transmit_cmd_struct *)ptr; /*transmit cmd/buff 0*/
+	for (i = 0; i < NUM_XMIT_BUFFS; i++) {
+		/* Transmit cmd/buff 0 */
+		p->xmit_cmds[i] = (struct transmit_cmd_struct *)ptr;
 		ptr = (char *) ptr + sizeof(struct transmit_cmd_struct);
 		p->xmit_cbuffs[i] = (char *)ptr; /* char-buffs */
 		ptr = (char *) ptr + XMIT_BUFF_SIZE;
 		p->xmit_buffs[i] = (struct tbd_struct *)ptr; /* TBD */
 		ptr = (char *) ptr + sizeof(struct tbd_struct);
-		if((void *)ptr > (void *)p->iscp)
-		{
-			printk("%s: not enough shared-mem for your configuration!\n",dev->name);
+		if ((void *)ptr > (void *)p->iscp) {
+			printk(KERN_ERR "%s: not enough shared-mem for your configuration!\n",
+				dev->name);
 			return 1;
 		}
-		memset((char *)(p->xmit_cmds[i]) ,0, sizeof(struct transmit_cmd_struct));
-		memset((char *)(p->xmit_buffs[i]),0, sizeof(struct tbd_struct));
-		p->xmit_cmds[i]->cmd_link = make16(p->nop_cmds[(i+1)%NUM_XMIT_BUFFS]);
-		p->xmit_cmds[i]->cmd_status = STAT_COMPL;
-		p->xmit_cmds[i]->cmd_cmd = CMD_XMIT | CMD_INT;
-		p->xmit_cmds[i]->tbd_offset = make16((p->xmit_buffs[i]));
-		p->xmit_buffs[i]->next = 0xffff;
-		p->xmit_buffs[i]->buffer = make24((p->xmit_cbuffs[i]));
+		memset_io((char *)(p->xmit_cmds[i]), 0,
+					sizeof(struct transmit_cmd_struct));
+		memset_io((char *)(p->xmit_buffs[i]), 0,
+					sizeof(struct tbd_struct));
+		writew(make16(p->nop_cmds[(i+1)%NUM_XMIT_BUFFS]),
+					&p->xmit_cmds[i]->cmd_link);
+		writew(STAT_COMPL, &p->xmit_cmds[i]->cmd_status);
+		writew(CMD_XMIT|CMD_INT, &p->xmit_cmds[i]->cmd_cmd);
+		writew(make16(p->xmit_buffs[i]), &p->xmit_cmds[i]->tbd_offset);
+		writew(0xffff, &p->xmit_buffs[i]->next);
+		writel(make24(p->xmit_cbuffs[i]), &p->xmit_buffs[i]->buffer);
 	}
 
 	p->xmit_count = 0;
@@ -761,21 +790,21 @@ static int init586(struct net_device *dev)
 		* 'start transmitter'
 		*/
 #ifndef NO_NOPCOMMANDS
-	p->scb->cbl_offset = make16(p->nop_cmds[0]);
-	p->scb->cmd_cuc = CUC_START;
+	writew(make16(p->nop_cmds[0]), &p->scb->cbl_offset);
+	writeb(CUC_START, &p->scb->cmd_cuc);
 	ni_attn586();
-	WAIT_4_SCB_CMD();
+	wait_for_scb_cmd(dev);
 #else
-	p->xmit_cmds[0]->cmd_link = make16(p->xmit_cmds[0]);
-	p->xmit_cmds[0]->cmd_cmd	= CMD_XMIT | CMD_SUSPEND | CMD_INT;
+	writew(make16(p->xmit_cmds[0]), &p->xmit_cmds[0]->cmd_link);
+	writew(CMD_XMIT | CMD_SUSPEND | CMD_INT, &p->xmit_cmds[0]->cmd_cmd);
 #endif
 
 	/*
 	 * ack. interrupts
 	 */
-	p->scb->cmd_cuc = p->scb->cus & STAT_MASK;
+	writeb(readb(&p->scb->cus) & STAT_MASK, &p->scb->cmd_cuc);
 	ni_attn586();
-	DELAY_16();
+	udelay(16);
 
 	ni_enaint();
 
@@ -787,43 +816,45 @@ static int init586(struct net_device *dev)
  * It sets up the Receive Frame Area (RFA).
  */
 
-static void *alloc_rfa(struct net_device *dev,void *ptr)
+static void *alloc_rfa(struct net_device *dev, void *ptr)
 {
-	volatile struct rfd_struct *rfd = (struct rfd_struct *)ptr;
-	volatile struct rbd_struct *rbd;
+	struct rfd_struct *rfd = (struct rfd_struct *)ptr;
+	struct rbd_struct *rbd;
 	int i;
 	struct priv *p = (struct priv *) dev->priv;
 
-	memset((char *) rfd,0,sizeof(struct rfd_struct)*(p->num_recv_buffs+rfdadd));
+	memset_io((char *) rfd, 0,
+		sizeof(struct rfd_struct) * (p->num_recv_buffs + rfdadd));
 	p->rfd_first = rfd;
 
-	for(i = 0; i < (p->num_recv_buffs+rfdadd); i++) {
-		rfd[i].next = make16(rfd + (i+1) % (p->num_recv_buffs+rfdadd) );
-		rfd[i].rbd_offset = 0xffff;
+	for (i = 0; i < (p->num_recv_buffs + rfdadd); i++) {
+		writew(make16(rfd + (i+1) % (p->num_recv_buffs+rfdadd)),
+			&rfd[i].next);
+		writew(0xffff, &rfd[i].rbd_offset);
 	}
-	rfd[p->num_recv_buffs-1+rfdadd].last = RFD_SUSP;	 /* RU suspend */
+	/* RU suspend */
+	writeb(RFD_SUSP, &rfd[p->num_recv_buffs-1+rfdadd].last);
 
-	ptr = (void *) (rfd + (p->num_recv_buffs + rfdadd) );
+	ptr = (void *) (rfd + (p->num_recv_buffs + rfdadd));
 
 	rbd = (struct rbd_struct *) ptr;
 	ptr = (void *) (rbd + p->num_recv_buffs);
 
 	 /* clr descriptors */
-	memset((char *) rbd,0,sizeof(struct rbd_struct)*(p->num_recv_buffs));
+	memset_io((char *)rbd, 0,
+			sizeof(struct rbd_struct) * (p->num_recv_buffs));
 
-	for(i=0;i<p->num_recv_buffs;i++)
-	{
-		rbd[i].next = make16((rbd + (i+1) % p->num_recv_buffs));
-		rbd[i].size = RECV_BUFF_SIZE;
-		rbd[i].buffer = make24(ptr);
+	for (i = 0; i < p->num_recv_buffs; i++) {
+		writew(make16(rbd + (i+1) % p->num_recv_buffs), &rbd[i].next);
+		writew(RECV_BUFF_SIZE, &rbd[i].size);
+		writel(make24(ptr), &rbd[i].buffer);
 		ptr = (char *) ptr + RECV_BUFF_SIZE;
 	}
-
 	p->rfd_top	= p->rfd_first;
 	p->rfd_last = p->rfd_first + (p->num_recv_buffs - 1 + rfdadd);
 
-	p->scb->rfa_offset		= make16(p->rfd_first);
-	p->rfd_first->rbd_offset	= make16(rbd);
+	writew(make16(p->rfd_first), &p->scb->rfa_offset);
+	writew(make16(rbd), &p->rfd_first->rbd_offset);
 
 	return ptr;
 }
@@ -833,73 +864,71 @@ static void *alloc_rfa(struct net_device *dev,void *ptr)
  * Interrupt Handler ...
  */
 
-static irqreturn_t ni52_interrupt(int irq,void *dev_id)
+static irqreturn_t ni52_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	unsigned short stat;
-	int cnt=0;
+	unsigned int stat;
+	int cnt = 0;
 	struct priv *p;
 
-	if (!dev) {
-		printk ("ni5210-interrupt: irq %d for unknown device.\n",irq);
-		return IRQ_NONE;
-	}
 	p = (struct priv *) dev->priv;
 
-	if(debuglevel > 1)
+	if (debuglevel > 1)
 		printk("I");
 
-	WAIT_4_SCB_CMD(); /* wait for last command	*/
+	spin_lock(&p->spinlock);
 
-	while((stat=p->scb->cus & STAT_MASK))
-	{
-		p->scb->cmd_cuc = stat;
+	wait_for_scb_cmd(dev); /* wait for last command	*/
+
+	while ((stat = readb(&p->scb->cus) & STAT_MASK)) {
+		writeb(stat, &p->scb->cmd_cuc);
 		ni_attn586();
 
-		if(stat & STAT_FR)	 /* received a frame */
+		if (stat & STAT_FR)	 /* received a frame */
 			ni52_rcv_int(dev);
 
-		if(stat & STAT_RNR) /* RU went 'not ready' */
-		{
+		if (stat & STAT_RNR) { /* RU went 'not ready' */
 			printk("(R)");
-			if(p->scb->rus & RU_SUSPEND) /* special case: RU_SUSPEND */
-			{
-				WAIT_4_SCB_CMD();
+			if (readb(&p->scb->rus) & RU_SUSPEND) {
+				/* special case: RU_SUSPEND */
+				wait_for_scb_cmd(dev);
 				p->scb->cmd_ruc = RUC_RESUME;
 				ni_attn586();
-				WAIT_4_SCB_CMD_RUC();
-			}
-			else
-			{
-				printk("%s: Receiver-Unit went 'NOT READY': %04x/%02x.\n",dev->name,(int) stat,(int) p->scb->rus);
+				wait_for_scb_cmd_ruc(dev);
+			} else {
+				printk(KERN_ERR "%s: Receiver-Unit went 'NOT READY': %04x/%02x.\n",
+					dev->name, stat, readb(&p->scb->rus));
 				ni52_rnr_int(dev);
 			}
 		}
 
-		if(stat & STAT_CX)		/* command with I-bit set complete */
+		/* Command with I-bit set complete */
+		if (stat & STAT_CX)
 			 ni52_xmt_int(dev);
 
 #ifndef NO_NOPCOMMANDS
-		if(stat & STAT_CNA)	/* CU went 'not ready' */
-		{
-			if(netif_running(dev))
-				printk("%s: oops! CU has left active state. stat: %04x/%02x.\n",dev->name,(int) stat,(int) p->scb->cus);
+		if (stat & STAT_CNA) {	/* CU went 'not ready' */
+			if (netif_running(dev))
+				printk(KERN_ERR "%s: oops! CU has left active state. stat: %04x/%02x.\n",
+					dev->name, stat, readb(&p->scb->cus));
 		}
 #endif
 
-		if(debuglevel > 1)
-			printk("%d",cnt++);
+		if (debuglevel > 1)
+			printk("%d", cnt++);
 
-		WAIT_4_SCB_CMD(); /* wait for ack. (ni52_xmt_int can be faster than ack!!) */
-		if(p->scb->cmd_cuc)	 /* timed out? */
-		{
-			printk("%s: Acknowledge timed out.\n",dev->name);
+		/* Wait for ack. (ni52_xmt_int can be faster than ack!!) */
+		wait_for_scb_cmd(dev);
+		if (p->scb->cmd_cuc) {	 /* timed out? */
+			printk(KERN_ERR "%s: Acknowledge timed out.\n",
+				dev->name);
 			ni_disint();
 			break;
 		}
 	}
+	spin_unlock(&p->spinlock);
 
-	if(debuglevel > 1)
+	if (debuglevel > 1)
 		printk("i");
 	return IRQ_HANDLED;
 }
@@ -910,121 +939,91 @@ static irqreturn_t ni52_interrupt(int irq,void *dev_id)
 
 static void ni52_rcv_int(struct net_device *dev)
 {
-	int status,cnt=0;
+	int status, cnt = 0;
 	unsigned short totlen;
 	struct sk_buff *skb;
 	struct rbd_struct *rbd;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = (struct priv *)dev->priv;
 
-	if(debuglevel > 0)
+	if (debuglevel > 0)
 		printk("R");
 
-	for(;(status = p->rfd_top->stat_high) & RFD_COMPL;)
-	{
-			rbd = (struct rbd_struct *) make32(p->rfd_top->rbd_offset);
-
-			if(status & RFD_OK) /* frame received without error? */
-			{
-				if( (totlen = rbd->status) & RBD_LAST) /* the first and the last buffer? */
-				{
-					totlen &= RBD_MASK; /* length of this frame */
-					rbd->status = 0;
-					skb = (struct sk_buff *) dev_alloc_skb(totlen+2);
-					if(skb != NULL)
-					{
-						skb_reserve(skb,2);
-						skb_put(skb,totlen);
-						skb_copy_to_linear_data(skb,(char *) p->base+(unsigned long) rbd->buffer,totlen);
-						skb->protocol=eth_type_trans(skb,dev);
-						netif_rx(skb);
-						dev->last_rx = jiffies;
-						p->stats.rx_packets++;
-						p->stats.rx_bytes += totlen;
+	for (; (status = readb(&p->rfd_top->stat_high)) & RFD_COMPL;) {
+		rbd = (struct rbd_struct *) make32(p->rfd_top->rbd_offset);
+		if (status & RFD_OK) { /* frame received without error? */
+			totlen = readw(&rbd->status);
+			if (totlen & RBD_LAST) {
+				/* the first and the last buffer? */
+				totlen &= RBD_MASK; /* length of this frame */
+				writew(0x00, &rbd->status);
+				skb = (struct sk_buff *)dev_alloc_skb(totlen+2);
+				if (skb != NULL) {
+					skb_reserve(skb, 2);
+					skb_put(skb, totlen);
+					skb_copy_to_linear_data(skb, (char *)p->base + (unsigned long) rbd->buffer, totlen);
+					skb->protocol = eth_type_trans(skb, dev);
+					netif_rx(skb);
+					dev->last_rx = jiffies;
+					p->stats.rx_packets++;
+					p->stats.rx_bytes += totlen;
+				} else
+					p->stats.rx_dropped++;
+			} else {
+				int rstat;
+				 /* free all RBD's until RBD_LAST is set */
+				totlen = 0;
+				while (!((rstat = readw(&rbd->status)) & RBD_LAST)) {
+					totlen += rstat & RBD_MASK;
+					if (!rstat) {
+						printk(KERN_ERR "%s: Whoops .. no end mark in RBD list\n", dev->name);
+						break;
 					}
-					else
-						p->stats.rx_dropped++;
+					writew(0, &rbd->status);
+					rbd = (struct rbd_struct *) make32(readl(&rbd->next));
 				}
-				else
-				{
-					int rstat;
-						 /* free all RBD's until RBD_LAST is set */
-					totlen = 0;
-					while(!((rstat=rbd->status) & RBD_LAST))
-					{
-						totlen += rstat & RBD_MASK;
-						if(!rstat)
-						{
-							printk("%s: Whoops .. no end mark in RBD list\n",dev->name);
-							break;
-						}
-						rbd->status = 0;
-						rbd = (struct rbd_struct *) make32(rbd->next);
-					}
-					totlen += rstat & RBD_MASK;
-					rbd->status = 0;
-					printk("%s: received oversized frame! length: %d\n",dev->name,totlen);
-					p->stats.rx_dropped++;
+				totlen += rstat & RBD_MASK;
+				writew(0, &rbd->status);
+				printk(KERN_ERR "%s: received oversized frame! length: %d\n",
+					dev->name, totlen);
+				p->stats.rx_dropped++;
 			 }
-		}
-		else /* frame !(ok), only with 'save-bad-frames' */
-		{
-			printk("%s: oops! rfd-error-status: %04x\n",dev->name,status);
+		} else {/* frame !(ok), only with 'save-bad-frames' */
+			printk(KERN_ERR "%s: oops! rfd-error-status: %04x\n",
+				dev->name, status);
 			p->stats.rx_errors++;
 		}
-		p->rfd_top->stat_high = 0;
-		p->rfd_top->last = RFD_SUSP; /* maybe exchange by RFD_LAST */
-		p->rfd_top->rbd_offset = 0xffff;
-		p->rfd_last->last = 0;				/* delete RFD_SUSP	*/
+		writeb(0, &p->rfd_top->stat_high);
+		writeb(RFD_SUSP, &p->rfd_top->last); /* maybe exchange by RFD_LAST */
+		writew(0xffff, &p->rfd_top->rbd_offset);
+		writeb(0, &p->rfd_last->last);	/* delete RFD_SUSP	*/
 		p->rfd_last = p->rfd_top;
 		p->rfd_top = (struct rfd_struct *) make32(p->rfd_top->next); /* step to next RFD */
-		p->scb->rfa_offset = make16(p->rfd_top);
+		writew(make16(p->rfd_top), &p->scb->rfa_offset);
 
-		if(debuglevel > 0)
-			printk("%d",cnt++);
+		if (debuglevel > 0)
+			printk("%d", cnt++);
 	}
 
-	if(automatic_resume)
-	{
-		WAIT_4_SCB_CMD();
-		p->scb->cmd_ruc = RUC_RESUME;
+	if (automatic_resume) {
+		wait_for_scb_cmd(dev);
+		writeb(RUC_RESUME, &p->scb->cmd_ruc);
 		ni_attn586();
-		WAIT_4_SCB_CMD_RUC();
+		wait_for_scb_cmd_ruc(dev);
 	}
 
 #ifdef WAIT_4_BUSY
 	{
 		int i;
-		for(i=0;i<1024;i++)
-		{
-			if(p->rfd_top->status)
+		for (i = 0; i < 1024; i++) {
+			if (p->rfd_top->status)
 				break;
-			DELAY_16();
-			if(i == 1023)
-				printk("%s: RU hasn't fetched next RFD (not busy/complete)\n",dev->name);
+			udelay(16);
+			if (i == 1023)
+				printk(KERN_ERR "%s: RU hasn't fetched next RFD (not busy/complete)\n", dev->name);
 		}
 	}
 #endif
-
-#if 0
-	if(!at_least_one)
-	{
-		int i;
-		volatile struct rfd_struct *rfds=p->rfd_top;
-		volatile struct rbd_struct *rbds;
-		printk("%s: received a FC intr. without having a frame: %04x %d\n",dev->name,status,old_at_least);
-		for(i=0;i< (p->num_recv_buffs+4);i++)
-		{
-			rbds = (struct rbd_struct *) make32(rfds->rbd_offset);
-			printk("%04x:%04x ",rfds->status,rbds->status);
-			rfds = (struct rfd_struct *) make32(rfds->next);
-		}
-		printk("\nerrs: %04x %04x stat: %04x\n",(int)p->scb->rsc_errs,(int)p->scb->ovrn_errs,(int)p->scb->status);
-		printk("\nerrs: %04x %04x rus: %02x, cus: %02x\n",(int)p->scb->rsc_errs,(int)p->scb->ovrn_errs,(int)p->scb->rus,(int)p->scb->cus);
-	}
-	old_at_least = at_least_one;
-#endif
-
-	if(debuglevel > 0)
+	if (debuglevel > 0)
 		printk("r");
 }
 
@@ -1038,16 +1037,16 @@ static void ni52_rnr_int(struct net_device *dev)
 
 	p->stats.rx_errors++;
 
-	WAIT_4_SCB_CMD();		/* wait for the last cmd, WAIT_4_FULLSTAT?? */
-	p->scb->cmd_ruc = RUC_ABORT; /* usually the RU is in the 'no resource'-state .. abort it now. */
+	wait_for_scb_cmd(dev);		/* wait for the last cmd, WAIT_4_FULLSTAT?? */
+	writeb(RUC_ABORT, &p->scb->cmd_ruc); /* usually the RU is in the 'no resource'-state .. abort it now. */
 	ni_attn586();
-	WAIT_4_SCB_CMD_RUC();		/* wait for accept cmd. */
+	wait_for_scb_cmd_ruc(dev);		/* wait for accept cmd. */
 
-	alloc_rfa(dev,(char *)p->rfd_first);
-/* maybe add a check here, before restarting the RU */
+	alloc_rfa(dev, (char *)p->rfd_first);
+	/* maybe add a check here, before restarting the RU */
 	startrecv586(dev); /* restart RU */
 
-	printk("%s: Receive-Unit restarted. Status: %04x\n",dev->name,p->scb->rus);
+	printk(KERN_ERR "%s: Receive-Unit restarted. Status: %04x\n", dev->name, p->scb->rus);
 
 }
 
@@ -1060,43 +1059,41 @@ static void ni52_xmt_int(struct net_device *dev)
 	int status;
 	struct priv *p = (struct priv *) dev->priv;
 
-	if(debuglevel > 0)
+	if (debuglevel > 0)
 		printk("X");
 
-	status = p->xmit_cmds[p->xmit_last]->cmd_status;
-	if(!(status & STAT_COMPL))
-		printk("%s: strange .. xmit-int without a 'COMPLETE'\n",dev->name);
+	status = readw(&p->xmit_cmds[p->xmit_last]->cmd_status);
+	if (!(status & STAT_COMPL))
+		printk(KERN_ERR "%s: strange .. xmit-int without a 'COMPLETE'\n", dev->name);
 
-	if(status & STAT_OK)
-	{
+	if (status & STAT_OK) {
 		p->stats.tx_packets++;
 		p->stats.collisions += (status & TCMD_MAXCOLLMASK);
-	}
-	else
-	{
+	} else {
 		p->stats.tx_errors++;
-		if(status & TCMD_LATECOLL) {
-			printk("%s: late collision detected.\n",dev->name);
+		if (status & TCMD_LATECOLL) {
+			printk(KERN_ERR "%s: late collision detected.\n",
+				dev->name);
 			p->stats.collisions++;
-		}
-		else if(status & TCMD_NOCARRIER) {
+		} else if (status & TCMD_NOCARRIER) {
 			p->stats.tx_carrier_errors++;
-			printk("%s: no carrier detected.\n",dev->name);
-		}
-		else if(status & TCMD_LOSTCTS)
-			printk("%s: loss of CTS detected.\n",dev->name);
-		else if(status & TCMD_UNDERRUN) {
+			printk(KERN_ERR "%s: no carrier detected.\n",
+				dev->name);
+		} else if (status & TCMD_LOSTCTS)
+			printk(KERN_ERR "%s: loss of CTS detected.\n",
+				dev->name);
+		else if (status & TCMD_UNDERRUN) {
 			p->stats.tx_fifo_errors++;
-			printk("%s: DMA underrun detected.\n",dev->name);
-		}
-		else if(status & TCMD_MAXCOLL) {
-			printk("%s: Max. collisions exceeded.\n",dev->name);
+			printk(KERN_ERR "%s: DMA underrun detected.\n",
+				dev->name);
+		} else if (status & TCMD_MAXCOLL) {
+			printk(KERN_ERR "%s: Max. collisions exceeded.\n",
+				dev->name);
 			p->stats.collisions += 16;
 		}
 	}
-
 #if (NUM_XMIT_BUFFS > 1)
-	if( (++p->xmit_last) == NUM_XMIT_BUFFS)
+	if ((++p->xmit_last) == NUM_XMIT_BUFFS)
 		p->xmit_last = 0;
 #endif
 	netif_wake_queue(dev);
@@ -1110,41 +1107,51 @@ static void startrecv586(struct net_device *dev)
 {
 	struct priv *p = (struct priv *) dev->priv;
 
-	WAIT_4_SCB_CMD();
-	WAIT_4_SCB_CMD_RUC();
-	p->scb->rfa_offset = make16(p->rfd_first);
-	p->scb->cmd_ruc = RUC_START;
+	wait_for_scb_cmd(dev);
+	wait_for_scb_cmd_ruc(dev);
+	writew(make16(p->rfd_first), &p->scb->rfa_offset);
+	writeb(RUC_START, &p->scb->cmd_ruc);
 	ni_attn586();		/* start cmd. */
-	WAIT_4_SCB_CMD_RUC();	/* wait for accept cmd. (no timeout!!) */
+	wait_for_scb_cmd_ruc(dev);
+	/* wait for accept cmd. (no timeout!!) */
 }
 
 static void ni52_timeout(struct net_device *dev)
 {
 	struct priv *p = (struct priv *) dev->priv;
 #ifndef NO_NOPCOMMANDS
-	if(p->scb->cus & CU_ACTIVE) /* COMMAND-UNIT active? */
-	{
+	if (readb(&p->scb->cus) & CU_ACTIVE) { /* COMMAND-UNIT active? */
 		netif_wake_queue(dev);
 #ifdef DEBUG
-		printk("%s: strange ... timeout with CU active?!?\n",dev->name);
-		printk("%s: X0: %04x N0: %04x N1: %04x %d\n",dev->name,(int)p->xmit_cmds[0]->cmd_status,(int)p->nop_cmds[0]->cmd_status,(int)p->nop_cmds[1]->cmd_status,(int)p->nop_point);
+		printk(KERN_ERR "%s: strange ... timeout with CU active?!?\n",
+			dev->name);
+		printk(KERN_ERR "%s: X0: %04x N0: %04x N1: %04x %d\n",
+			dev->name, (int)p->xmit_cmds[0]->cmd_status,
+			readw(&p->nop_cmds[0]->cmd_status),
+			readw(&p->nop_cmds[1]->cmd_status),
+			p->nop_point);
 #endif
-		p->scb->cmd_cuc = CUC_ABORT;
+		writeb(CUC_ABORT, &p->scb->cmd_cuc);
 		ni_attn586();
-		WAIT_4_SCB_CMD();
-		p->scb->cbl_offset = make16(p->nop_cmds[p->nop_point]);
-		p->scb->cmd_cuc = CUC_START;
+		wait_for_scb_cmd(dev);
+		writew(make16(p->nop_cmds[p->nop_point]), &p->scb->cbl_offset);
+		writeb(CUC_START, &p->scb->cmd_cuc);
 		ni_attn586();
-		WAIT_4_SCB_CMD();
+		wait_for_scb_cmd(dev);
 		dev->trans_start = jiffies;
 		return 0;
 	}
 #endif
 	{
 #ifdef DEBUG
-		printk("%s: xmitter timed out, try to restart! stat: %02x\n",dev->name,p->scb->cus);
-		printk("%s: command-stats: %04x %04x\n",dev->name,p->xmit_cmds[0]->cmd_status,p->xmit_cmds[1]->cmd_status);
-		printk("%s: check, whether you set the right interrupt number!\n",dev->name);
+		printk(KERN_ERR "%s: xmitter timed out, try to restart! stat: %02x\n",
+				dev->name, readb(&p->scb->cus));
+		printk(KERN_ERR "%s: command-stats: %04x %04x\n",
+				dev->name,
+				readw(&p->xmit_cmds[0]->cmd_status),
+				readw(&p->xmit_cmds[1]->cmd_status));
+		printk(KERN_ERR "%s: check, whether you set the right interrupt number!\n",
+				dev->name);
 #endif
 		ni52_close(dev);
 		ni52_open(dev);
@@ -1158,110 +1165,99 @@ static void ni52_timeout(struct net_device *dev)
 
 static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	int len,i;
+	int len, i;
 #ifndef NO_NOPCOMMANDS
 	int next_nop;
 #endif
 	struct priv *p = (struct priv *) dev->priv;
 
-	if(skb->len > XMIT_BUFF_SIZE)
-	{
-		printk("%s: Sorry, max. framelength is %d bytes. The length of your frame is %d bytes.\n",dev->name,XMIT_BUFF_SIZE,skb->len);
+	if (skb->len > XMIT_BUFF_SIZE) {
+		printk(KERN_ERR "%s: Sorry, max. framelength is %d bytes. The length of your frame is %d bytes.\n", dev->name, XMIT_BUFF_SIZE, skb->len);
 		return 0;
 	}
 
 	netif_stop_queue(dev);
 
-#if(NUM_XMIT_BUFFS > 1)
-	if(test_and_set_bit(0,(void *) &p->lock)) {
-		printk("%s: Queue was locked\n",dev->name);
-		return 1;
+	skb_copy_from_linear_data(skb, (char *)p->xmit_cbuffs[p->xmit_count],
+							skb->len);
+	len = skb->len;
+	if (len < ETH_ZLEN) {
+		len = ETH_ZLEN;
+		memset((char *)p->xmit_cbuffs[p->xmit_count]+skb->len, 0,
+							len - skb->len);
 	}
-	else
-#endif
-	{
-		skb_copy_from_linear_data(skb, (char *) p->xmit_cbuffs[p->xmit_count], skb->len);
-		len = skb->len;
-		if (len < ETH_ZLEN) {
-			len = ETH_ZLEN;
-			memset((char *)p->xmit_cbuffs[p->xmit_count]+skb->len, 0, len - skb->len);
-		}
 
 #if (NUM_XMIT_BUFFS == 1)
 #	ifdef NO_NOPCOMMANDS
 
 #ifdef DEBUG
-		if(p->scb->cus & CU_ACTIVE)
-		{
-			printk("%s: Hmmm .. CU is still running and we wanna send a new packet.\n",dev->name);
-			printk("%s: stat: %04x %04x\n",dev->name,p->scb->cus,p->xmit_cmds[0]->cmd_status);
-		}
+	if (p->scb->cus & CU_ACTIVE) {
+		printk(KERN_ERR "%s: Hmmm .. CU is still running and we wanna send a new packet.\n", dev->name);
+		printk(KERN_ERR "%s: stat: %04x %04x\n",
+				dev->name, readb(&p->scb->cus),
+				readw(&p->xmit_cmds[0]->cmd_status));
+	}
 #endif
-
-		p->xmit_buffs[0]->size = TBD_LAST | len;
-		for(i=0;i<16;i++)
-		{
-			p->xmit_cmds[0]->cmd_status = 0;
-			WAIT_4_SCB_CMD();
-			if( (p->scb->cus & CU_STATUS) == CU_SUSPEND)
-				p->scb->cmd_cuc = CUC_RESUME;
-			else
-			{
-				p->scb->cbl_offset = make16(p->xmit_cmds[0]);
-				p->scb->cmd_cuc = CUC_START;
-			}
-
-			ni_attn586();
-			dev->trans_start = jiffies;
-			if(!i)
-				dev_kfree_skb(skb);
-			WAIT_4_SCB_CMD();
-			if( (p->scb->cus & CU_ACTIVE)) /* test it, because CU sometimes doesn't start immediately */
-				break;
-			if(p->xmit_cmds[0]->cmd_status)
-				break;
-			if(i==15)
-				printk("%s: Can't start transmit-command.\n",dev->name);
+	writew(TBD_LAST | len, &p->xmit_buffs[0]->size);;
+	for (i = 0; i < 16; i++) {
+		writew(0, &p->xmit_cmds[0]->cmd_status);
+		wait_for_scb_cmd(dev);
+		if ((readb(&p->scb->cus) & CU_STATUS) == CU_SUSPEND)
+			writeb(CUC_RESUME, &p->scb->cmd_cuc);
+		else {
+			writew(make16(p->xmit_cmds[0]), &p->scb->cbl_offset);
+			writeb(CUC_START, &p->scb->cmd_cuc);
 		}
-#	else
-		next_nop = (p->nop_point + 1) & 0x1;
-		p->xmit_buffs[0]->size = TBD_LAST | len;
-
-		p->xmit_cmds[0]->cmd_link	 = p->nop_cmds[next_nop]->cmd_link
-																= make16((p->nop_cmds[next_nop]));
-		p->xmit_cmds[0]->cmd_status = p->nop_cmds[next_nop]->cmd_status = 0;
-
-		p->nop_cmds[p->nop_point]->cmd_link = make16((p->xmit_cmds[0]));
+		ni_attn586();
 		dev->trans_start = jiffies;
-		p->nop_point = next_nop;
-		dev_kfree_skb(skb);
+		if (!i)
+			dev_kfree_skb(skb);
+		wait_for_scb_cmd(dev);
+		/* test it, because CU sometimes doesn't start immediately */
+		if (readb(&p->scb->cus) & CU_ACTIVE)
+			break;
+		if (readw(&p->xmit_cmds[0]->cmd_status))
+			break;
+		if (i == 15)
+			printk(KERN_WARNING "%s: Can't start transmit-command.\n", dev->name);
+	}
+#	else
+	next_nop = (p->nop_point + 1) & 0x1;
+	writew(TBD_LAST | len, &p->xmit_buffs[0]->size);
+	writew(make16(p->nop_cmds[next_nop]), &p->xmit_cmds[0]->cmd_link);
+	writew(make16(p->nop_cmds[next_nop]),
+				&p->nop_cmds[next_nop]->cmd_link);
+	writew(0, &p->xmit_cmds[0]->cmd_status);
+	writew(0, &p->nop_cmds[next_nop]->cmd_status);
+
+	writew(make16(p->xmit_cmds[0]), &p->nop_cmds[p->nop_point]->cmd_link);
+	dev->trans_start = jiffies;
+	p->nop_point = next_nop;
+	dev_kfree_skb(skb);
 #	endif
 #else
-		p->xmit_buffs[p->xmit_count]->size = TBD_LAST | len;
-		if( (next_nop = p->xmit_count + 1) == NUM_XMIT_BUFFS )
-			next_nop = 0;
-
-		p->xmit_cmds[p->xmit_count]->cmd_status	= 0;
-		/* linkpointer of xmit-command already points to next nop cmd */
-		p->nop_cmds[next_nop]->cmd_link = make16((p->nop_cmds[next_nop]));
-		p->nop_cmds[next_nop]->cmd_status = 0;
-
-		p->nop_cmds[p->xmit_count]->cmd_link = make16((p->xmit_cmds[p->xmit_count]));
-		dev->trans_start = jiffies;
-		p->xmit_count = next_nop;
-
-		{
-			unsigned long flags;
-			save_flags(flags);
-			cli();
-			if(p->xmit_count != p->xmit_last)
-				netif_wake_queue(dev);
-			p->lock = 0;
-			restore_flags(flags);
-		}
-		dev_kfree_skb(skb);
-#endif
+	writew(TBD_LAST | len, &p->xmit_buffs[p->xmit_count]->size);
+	next_nop = p->xmit_count + 1
+	if (next_nop == NUM_XMIT_BUFFS)
+		next_nop = 0;
+	writew(0, &p->xmit_cmds[p->xmit_count]->cmd_status);
+	/* linkpointer of xmit-command already points to next nop cmd */
+	writew(make16(p->nop_cmds[next_nop]),
+				&p->nop_cmds[next_nop]->cmd_link);
+	writew(0, &p->nop_cmds[next_nop]->cmd_status);
+	writew(make16(p->xmit_cmds[p->xmit_count]),
+				&p->nop_cmds[p->xmit_count]->cmd_link);
+	dev->trans_start = jiffies;
+	p->xmit_count = next_nop;
+	{
+		unsigned long flags;
+		spin_lock_irqsave(&p->spinlock);
+		if (p->xmit_count != p->xmit_last)
+			netif_wake_queue(dev);
+		spin_unlock_irqrestore(&p->spinlock);
 	}
+	dev_kfree_skb(skb);
+#endif
 	return 0;
 }
 
@@ -1272,16 +1268,17 @@ static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 static struct net_device_stats *ni52_get_stats(struct net_device *dev)
 {
 	struct priv *p = (struct priv *) dev->priv;
-	unsigned short crc,aln,rsc,ovrn;
-
-	crc = p->scb->crc_errs; /* get error-statistic from the ni82586 */
-	p->scb->crc_errs = 0;
-	aln = p->scb->aln_errs;
-	p->scb->aln_errs = 0;
-	rsc = p->scb->rsc_errs;
-	p->scb->rsc_errs = 0;
-	ovrn = p->scb->ovrn_errs;
-	p->scb->ovrn_errs = 0;
+	unsigned short crc, aln, rsc, ovrn;
+
+	/* Get error-statistics from the ni82586 */
+	crc = readw(&p->scb->crc_errs);
+	writew(0, &p->scb->crc_errs);
+	aln = readw(&p->scb->aln_errs);
+	writew(0, &p->scb->aln_errs);
+	rsc = readw(&p->scb->rsc_errs);
+	writew(0, &p->scb->rsc_errs);
+	ovrn = readw(&p->scb->ovrn_errs);
+	writew(0, &p->scb->ovrn_errs);
 
 	p->stats.rx_crc_errors += crc;
 	p->stats.rx_fifo_errors += ovrn;
@@ -1320,8 +1317,9 @@ MODULE_PARM_DESC(memend, "NI5210 memory end address,required");
 
 int __init init_module(void)
 {
-	if(io <= 0x0 || !memend || !memstart || irq < 2) {
-		printk("ni52: Autoprobing not allowed for modules.\nni52: Set symbols 'io' 'irq' 'memstart' and 'memend'\n");
+	if (io <= 0x0 || !memend || !memstart || irq < 2) {
+		printk(KERN_ERR "ni52: Autoprobing not allowed for modules.\n");
+		printk(KERN_ERR "ni52: Set symbols 'io' 'irq' 'memstart' and 'memend'\n");
 		return -ENODEV;
 	}
 	dev_ni52 = ni52_probe(-1);
@@ -1338,42 +1336,6 @@ void __exit cleanup_module(void)
 }
 #endif /* MODULE */
 
-#if 0
-/*
- * DUMP .. we expect a not running CMD unit and enough space
- */
-void ni52_dump(struct net_device *dev,void *ptr)
-{
-	struct priv *p = (struct priv *) dev->priv;
-	struct dump_cmd_struct *dump_cmd = (struct dump_cmd_struct *) ptr;
-	int i;
-
-	p->scb->cmd_cuc = CUC_ABORT;
-	ni_attn586();
-	WAIT_4_SCB_CMD();
-	WAIT_4_SCB_CMD_RUC();
-
-	dump_cmd->cmd_status = 0;
-	dump_cmd->cmd_cmd = CMD_DUMP | CMD_LAST;
-	dump_cmd->dump_offset = make16((dump_cmd + 1));
-	dump_cmd->cmd_link = 0xffff;
-
-	p->scb->cbl_offset = make16(dump_cmd);
-	p->scb->cmd_cuc = CUC_START;
-	ni_attn586();
-	WAIT_4_STAT_COMPL(dump_cmd);
-
-	if( (dump_cmd->cmd_status & (STAT_COMPL|STAT_OK)) != (STAT_COMPL|STAT_OK) )
-				printk("%s: Can't get dump information.\n",dev->name);
-
-	for(i=0;i<170;i++) {
-		printk("%02x ",(int) ((unsigned char *) (dump_cmd + 1))[i]);
-		if(i % 24 == 23)
-			printk("\n");
-	}
-	printk("\n");
-}
-#endif
 MODULE_LICENSE("GPL");
 
 /*
diff --git a/drivers/net/ni52.h b/drivers/net/ni52.h
index a33ea08..1f28a4d 100644
--- a/drivers/net/ni52.h
+++ b/drivers/net/ni52.h
@@ -36,12 +36,12 @@
 
 struct scp_struct
 {
-  unsigned short zero_dum0;	/* has to be zero */
-  unsigned char  sysbus;	/* 0=16Bit,1=8Bit */
-  unsigned char  zero_dum1;	/* has to be zero for 586 */
-  unsigned short zero_dum2;
-  unsigned short zero_dum3;
-  char          *iscp;		/* pointer to the iscp-block */
+	u16 zero_dum0;	/* has to be zero */
+	u8 sysbus;	/* 0=16Bit,1=8Bit */
+	u8 zero_dum1;	/* has to be zero for 586 */
+	u8 zero_dum2;
+	u8 zero_dum3;
+	u32 iscp;		/* pointer to the iscp-block */
 };
 
 
@@ -50,10 +50,10 @@ struct scp_struct
  */
 struct iscp_struct
 {
-  unsigned char  busy;          /* 586 clears after successful init */
-  unsigned char  zero_dummy;    /* has to be zero */
-  unsigned short scb_offset;    /* pointeroffset to the scb_base */
-  char          *scb_base;      /* base-address of all 16-bit offsets */
+	u8 busy;          /* 586 clears after successful init */
+	u8 zero_dummy;    /* has to be zero */
+	u16 scb_offset;    /* pointeroffset to the scb_base */
+	u32 scb_base;      /* base-address of all 16-bit offsets */
 };
 
 /*
@@ -61,16 +61,16 @@ struct iscp_struct
  */
 struct scb_struct
 {
-  unsigned char rus;
-  unsigned char cus;
-  unsigned char cmd_ruc;           /* command word: RU part */
-  unsigned char cmd_cuc;           /* command word: CU part & ACK */
-  unsigned short cbl_offset;    /* pointeroffset, command block list */
-  unsigned short rfa_offset;    /* pointeroffset, receive frame area */
-  unsigned short crc_errs;      /* CRC-Error counter */
-  unsigned short aln_errs;      /* alignmenterror counter */
-  unsigned short rsc_errs;      /* Resourceerror counter */
-  unsigned short ovrn_errs;     /* OVerrunerror counter */
+	u8 rus;
+	u8 cus;
+	u8 cmd_ruc;        /* command word: RU part */
+	u8 cmd_cuc;        /* command word: CU part & ACK */
+	u16 cbl_offset;    /* pointeroffset, command block list */
+	u16 rfa_offset;    /* pointeroffset, receive frame area */
+	u16 crc_errs;      /* CRC-Error counter */
+	u16 aln_errs;      /* alignmenterror counter */
+	u16 rsc_errs;      /* Resourceerror counter */
+	u16 ovrn_errs;     /* OVerrunerror counter */
 };
 
 /*
@@ -119,16 +119,16 @@ struct scb_struct
  */
 struct rfd_struct
 {
-  unsigned char  stat_low;	/* status word */
-  unsigned char  stat_high;	/* status word */
-  unsigned char  rfd_sf;	/* 82596 mode only */
-  unsigned char  last;		/* Bit15,Last Frame on List / Bit14,suspend */
-  unsigned short next;		/* linkoffset to next RFD */
-  unsigned short rbd_offset;	/* pointeroffset to RBD-buffer */
-  unsigned char  dest[6];	/* ethernet-address, destination */
-  unsigned char  source[6];	/* ethernet-address, source */
-  unsigned short length;	/* 802.3 frame-length */
-  unsigned short zero_dummy;	/* dummy */
+	u8  stat_low;	/* status word */
+	u8  stat_high;	/* status word */
+	u8  rfd_sf;	/* 82596 mode only */
+	u8  last;		/* Bit15,Last Frame on List / Bit14,suspend */
+	u16 next;		/* linkoffset to next RFD */
+	u16 rbd_offset;	/* pointeroffset to RBD-buffer */
+	u8  dest[6];	/* ethernet-address, destination */
+	u8  source[6];	/* ethernet-address, source */
+	u16 length;	/* 802.3 frame-length */
+	u16 zero_dummy;	/* dummy */
 };
 
 #define RFD_LAST     0x80	/* last: last rfd in the list */
@@ -153,11 +153,11 @@ struct rfd_struct
  */
 struct rbd_struct
 {
-  unsigned short status;	/* status word,number of used bytes in buff */
-  unsigned short next;		/* pointeroffset to next RBD */
-  char          *buffer;	/* receive buffer address pointer */
-  unsigned short size;		/* size of this buffer */
-  unsigned short zero_dummy;    /* dummy */
+	u16 status;	/* status word,number of used bytes in buff */
+	u16 next;		/* pointeroffset to next RBD */
+	u32 buffer;	/* receive buffer address pointer */
+	u16 size;		/* size of this buffer */
+	u16 zero_dummy;    /* dummy */
 };
 
 #define RBD_LAST	0x8000	/* last buffer */
@@ -195,9 +195,9 @@ struct rbd_struct
  */
 struct nop_cmd_struct
 {
-  unsigned short cmd_status;	/* status of this command */
-  unsigned short cmd_cmd;       /* the command itself (+bits) */
-  unsigned short cmd_link;      /* offsetpointer to next command */
+	u16 cmd_status;	/* status of this command */
+	u16 cmd_cmd;       /* the command itself (+bits) */
+	u16 cmd_link;      /* offsetpointer to next command */
 };
 
 /*
@@ -205,10 +205,10 @@ struct nop_cmd_struct
  */
 struct iasetup_cmd_struct
 {
-  unsigned short cmd_status;
-  unsigned short cmd_cmd;
-  unsigned short cmd_link;
-  unsigned char  iaddr[6];
+	u16 cmd_status;
+	u16 cmd_cmd;
+	u16 cmd_link;
+	u8  iaddr[6];
 };
 
 /*
@@ -216,21 +216,21 @@ struct iasetup_cmd_struct
  */
 struct configure_cmd_struct
 {
-  unsigned short cmd_status;
-  unsigned short cmd_cmd;
-  unsigned short cmd_link;
-  unsigned char  byte_cnt;   /* size of the config-cmd */
-  unsigned char  fifo;       /* fifo/recv monitor */
-  unsigned char  sav_bf;     /* save bad frames (bit7=1)*/
-  unsigned char  adr_len;    /* adr_len(0-2),al_loc(3),pream(4-5),loopbak(6-7)*/
-  unsigned char  priority;   /* lin_prio(0-2),exp_prio(4-6),bof_metd(7) */
-  unsigned char  ifs;        /* inter frame spacing */
-  unsigned char  time_low;   /* slot time low */
-  unsigned char  time_high;  /* slot time high(0-2) and max. retries(4-7) */
-  unsigned char  promisc;    /* promisc-mode(0) , et al (1-7) */
-  unsigned char  carr_coll;  /* carrier(0-3)/collision(4-7) stuff */
-  unsigned char  fram_len;   /* minimal frame len */
-  unsigned char  dummy;	     /* dummy */
+	u16 cmd_status;
+	u16 cmd_cmd;
+	u16 cmd_link;
+	u8  byte_cnt;   /* size of the config-cmd */
+	u8  fifo;       /* fifo/recv monitor */
+	u8  sav_bf;     /* save bad frames (bit7=1)*/
+	u8  adr_len;    /* adr_len(0-2),al_loc(3),pream(4-5),loopbak(6-7)*/
+	u8  priority;   /* lin_prio(0-2),exp_prio(4-6),bof_metd(7) */
+	u8  ifs;        /* inter frame spacing */
+	u8  time_low;   /* slot time low */
+	u8  time_high;  /* slot time high(0-2) and max. retries(4-7) */
+	u8  promisc;    /* promisc-mode(0) , et al (1-7) */
+	u8  carr_coll;  /* carrier(0-3)/collision(4-7) stuff */
+	u8  fram_len;   /* minimal frame len */
+	u8  dummy;	     /* dummy */
 };
 
 /*
@@ -238,11 +238,11 @@ struct configure_cmd_struct
  */
 struct mcsetup_cmd_struct
 {
-  unsigned short cmd_status;
-  unsigned short cmd_cmd;
-  unsigned short cmd_link;
-  unsigned short mc_cnt;		/* number of bytes in the MC-List */
-  unsigned char  mc_list[0][6];  	/* pointer to 6 bytes entries */
+	u16 cmd_status;
+	u16 cmd_cmd;
+	u16 cmd_link;
+	u16 mc_cnt;		/* number of bytes in the MC-List */
+	u8  mc_list[0][6];  	/* pointer to 6 bytes entries */
 };
 
 /*
@@ -250,10 +250,10 @@ struct mcsetup_cmd_struct
  */
 struct dump_cmd_struct
 {
-  unsigned short cmd_status;
-  unsigned short cmd_cmd;
-  unsigned short cmd_link;
-  unsigned short dump_offset;    /* pointeroffset to DUMP space */
+	u16 cmd_status;
+	u16 cmd_cmd;
+	u16 cmd_link;
+	u16 dump_offset;    /* pointeroffset to DUMP space */
 };
 
 /*
@@ -261,12 +261,12 @@ struct dump_cmd_struct
  */
 struct transmit_cmd_struct
 {
-  unsigned short cmd_status;
-  unsigned short cmd_cmd;
-  unsigned short cmd_link;
-  unsigned short tbd_offset;	/* pointeroffset to TBD */
-  unsigned char  dest[6];       /* destination address of the frame */
-  unsigned short length;	/* user defined: 802.3 length / Ether type */
+	u16 cmd_status;
+	u16 cmd_cmd;
+	u16 cmd_link;
+	u16 tbd_offset;	/* pointeroffset to TBD */
+	u8  dest[6];       /* destination address of the frame */
+	u16 length;	/* user defined: 802.3 length / Ether type */
 };
 
 #define TCMD_ERRMASK     0x0fa0
@@ -281,10 +281,10 @@ struct transmit_cmd_struct
 
 struct tdr_cmd_struct
 {
-  unsigned short cmd_status;
-  unsigned short cmd_cmd;
-  unsigned short cmd_link;
-  unsigned short status;
+	u16 cmd_status;
+	u16 cmd_cmd;
+	u16 cmd_link;
+	u16 status;
 };
 
 #define TDR_LNK_OK	0x8000	/* No link problem identified */
@@ -298,9 +298,9 @@ struct tdr_cmd_struct
  */
 struct tbd_struct
 {
-  unsigned short size;		/* size + EOF-Flag(15) */
-  unsigned short next;          /* pointeroffset to next TBD */
-  char          *buffer;        /* pointer to buffer */
+	u16 size;		/* size + EOF-Flag(15) */
+	u16 next;          /* pointeroffset to next TBD */
+	u32 buffer;        /* pointer to buffer */
 };
 
 #define TBD_LAST 0x8000         /* EOF-Flag, indicates last buffer in list */
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index c4b74e9..4eb322e 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -174,7 +174,11 @@ static int homepna[MAX_UNITS];
 #define RX_RING_SIZE		(1 << (PCNET32_LOG_RX_BUFFERS))
 #define RX_MAX_RING_SIZE	(1 << (PCNET32_LOG_MAX_RX_BUFFERS))
 
-#define PKT_BUF_SZ		1544
+#define PKT_BUF_SKB		1544
+/* actual buffer length after being aligned */
+#define PKT_BUF_SIZE		(PKT_BUF_SKB - NET_IP_ALIGN)
+/* chip wants twos complement of the (aligned) buffer length */
+#define NEG_BUF_SIZE		(NET_IP_ALIGN - PKT_BUF_SKB)
 
 /* Offsets from base I/O address. */
 #define PCNET32_WIO_RDP		0x10
@@ -604,7 +608,7 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 	/* now allocate any new buffers needed */
 	for (; new < size; new++ ) {
 		struct sk_buff *rx_skbuff;
-		new_skb_list[new] = dev_alloc_skb(PKT_BUF_SZ);
+		new_skb_list[new] = dev_alloc_skb(PKT_BUF_SKB);
 		if (!(rx_skbuff = new_skb_list[new])) {
 			/* keep the original lists and buffers */
 			if (netif_msg_drv(lp))
@@ -613,20 +617,20 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 				       dev->name);
 			goto free_all_new;
 		}
-		skb_reserve(rx_skbuff, 2);
+		skb_reserve(rx_skbuff, NET_IP_ALIGN);
 
 		new_dma_addr_list[new] =
 			    pci_map_single(lp->pci_dev, rx_skbuff->data,
-					   PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+					   PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
 		new_rx_ring[new].base = cpu_to_le32(new_dma_addr_list[new]);
-		new_rx_ring[new].buf_length = cpu_to_le16(2 - PKT_BUF_SZ);
+		new_rx_ring[new].buf_length = cpu_to_le16(NEG_BUF_SIZE);
 		new_rx_ring[new].status = cpu_to_le16(0x8000);
 	}
 	/* and free any unneeded buffers */
 	for (; new < lp->rx_ring_size; new++) {
 		if (lp->rx_skbuff[new]) {
 			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[new],
-					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+					 PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(lp->rx_skbuff[new]);
 		}
 	}
@@ -651,7 +655,7 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 	for (; --new >= lp->rx_ring_size; ) {
 		if (new_skb_list[new]) {
 			pci_unmap_single(lp->pci_dev, new_dma_addr_list[new],
-					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+					 PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(new_skb_list[new]);
 		}
 	}
@@ -678,7 +682,7 @@ static void pcnet32_purge_rx_ring(struct net_device *dev)
 		wmb();		/* Make sure adapter sees owner change */
 		if (lp->rx_skbuff[i]) {
 			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i],
-					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+					 PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb_any(lp->rx_skbuff[i]);
 		}
 		lp->rx_skbuff[i] = NULL;
@@ -1201,7 +1205,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	pkt_len = (le32_to_cpu(rxp->msg_length) & 0xfff) - 4;
 
 	/* Discard oversize frames. */
-	if (unlikely(pkt_len > PKT_BUF_SZ - 2)) {
+	if (unlikely(pkt_len > PKT_BUF_SIZE)) {
 		if (netif_msg_drv(lp))
 			printk(KERN_ERR "%s: Impossible packet size %d!\n",
 			       dev->name, pkt_len);
@@ -1218,26 +1222,26 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	if (pkt_len > rx_copybreak) {
 		struct sk_buff *newskb;
 
-		if ((newskb = dev_alloc_skb(PKT_BUF_SZ))) {
-			skb_reserve(newskb, 2);
+		if ((newskb = dev_alloc_skb(PKT_BUF_SKB))) {
+			skb_reserve(newskb, NET_IP_ALIGN);
 			skb = lp->rx_skbuff[entry];
 			pci_unmap_single(lp->pci_dev,
 					 lp->rx_dma_addr[entry],
-					 PKT_BUF_SZ - 2,
+					 PKT_BUF_SIZE,
 					 PCI_DMA_FROMDEVICE);
 			skb_put(skb, pkt_len);
 			lp->rx_skbuff[entry] = newskb;
 			lp->rx_dma_addr[entry] =
 					    pci_map_single(lp->pci_dev,
 							   newskb->data,
-							   PKT_BUF_SZ - 2,
+							   PKT_BUF_SIZE,
 							   PCI_DMA_FROMDEVICE);
 			rxp->base = cpu_to_le32(lp->rx_dma_addr[entry]);
 			rx_in_place = 1;
 		} else
 			skb = NULL;
 	} else {
-		skb = dev_alloc_skb(pkt_len + 2);
+		skb = dev_alloc_skb(pkt_len + NET_IP_ALIGN);
 	}
 
 	if (skb == NULL) {
@@ -1250,7 +1254,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	}
 	skb->dev = dev;
 	if (!rx_in_place) {
-		skb_reserve(skb, 2);	/* 16 byte align */
+		skb_reserve(skb, NET_IP_ALIGN);
 		skb_put(skb, pkt_len);	/* Make room */
 		pci_dma_sync_single_for_cpu(lp->pci_dev,
 					    lp->rx_dma_addr[entry],
@@ -1291,7 +1295,7 @@ static int pcnet32_rx(struct net_device *dev, int budget)
 		 * The docs say that the buffer length isn't touched, but Andrew
 		 * Boyd of QNX reports that some revs of the 79C965 clear it.
 		 */
-		rxp->buf_length = cpu_to_le16(2 - PKT_BUF_SZ);
+		rxp->buf_length = cpu_to_le16(NEG_BUF_SIZE);
 		wmb();	/* Make sure owner changes after others are visible */
 		rxp->status = cpu_to_le16(0x8000);
 		entry = (++lp->cur_rx) & lp->rx_mod_mask;
@@ -1774,8 +1778,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 		memset(dev->dev_addr, 0, sizeof(dev->dev_addr));
 
 	if (pcnet32_debug & NETIF_MSG_PROBE) {
-		for (i = 0; i < 6; i++)
-			printk(" %2.2x", dev->dev_addr[i]);
+		DECLARE_MAC_BUF(mac);
+		printk(" %s", print_mac(mac, dev->dev_addr));
 
 		/* Version 0x2623 and 0x2624 */
 		if (((chip_version + 1) & 0xfffe) == 0x2624) {
@@ -2396,7 +2400,7 @@ static int pcnet32_init_ring(struct net_device *dev)
 		if (rx_skbuff == NULL) {
 			if (!
 			    (rx_skbuff = lp->rx_skbuff[i] =
-			     dev_alloc_skb(PKT_BUF_SZ))) {
+			     dev_alloc_skb(PKT_BUF_SKB))) {
 				/* there is not much, we can do at this point */
 				if (netif_msg_drv(lp))
 					printk(KERN_ERR
@@ -2404,16 +2408,16 @@ static int pcnet32_init_ring(struct net_device *dev)
 					       dev->name);
 				return -1;
 			}
-			skb_reserve(rx_skbuff, 2);
+			skb_reserve(rx_skbuff, NET_IP_ALIGN);
 		}
 
 		rmb();
 		if (lp->rx_dma_addr[i] == 0)
 			lp->rx_dma_addr[i] =
 			    pci_map_single(lp->pci_dev, rx_skbuff->data,
-					   PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
+					   PKT_BUF_SIZE, PCI_DMA_FROMDEVICE);
 		lp->rx_ring[i].base = cpu_to_le32(lp->rx_dma_addr[i]);
-		lp->rx_ring[i].buf_length = cpu_to_le16(2 - PKT_BUF_SZ);
+		lp->rx_ring[i].buf_length = cpu_to_le16(NEG_BUF_SIZE);
 		wmb();		/* Make sure owner changes after all others are visible */
 		lp->rx_ring[i].status = cpu_to_le16(0x8000);
 	}
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 73b6d39..ca9b040 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -236,12 +236,12 @@ module_init(fixed_mdio_bus_init);
 static void __exit fixed_mdio_bus_exit(void)
 {
 	struct fixed_mdio_bus *fmb = &platform_fmb;
-	struct fixed_phy *fp;
+	struct fixed_phy *fp, *tmp;
 
 	mdiobus_unregister(&fmb->mii_bus);
 	platform_device_unregister(pdev);
 
-	list_for_each_entry(fp, &fmb->phys, node) {
+	list_for_each_entry_safe(fp, tmp, &fmb->phys, node) {
 		list_del(&fp->node);
 		kfree(fp);
 	}
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 055af08..7eb6e7e 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -46,29 +46,25 @@
 #include <asm/lv1call.h>
 
 #include "ps3_gelic_net.h"
+#include "ps3_gelic_wireless.h"
 
 #define DRV_NAME "Gelic Network Driver"
-#define DRV_VERSION "1.0"
+#define DRV_VERSION "2.0"
 
 MODULE_AUTHOR("SCE Inc.");
 MODULE_DESCRIPTION("Gelic Network driver");
 MODULE_LICENSE("GPL");
 
-static inline struct device *ctodev(struct gelic_net_card *card)
-{
-	return &card->dev->core;
-}
-static inline u64 bus_id(struct gelic_net_card *card)
-{
-	return card->dev->bus_id;
-}
-static inline u64 dev_id(struct gelic_net_card *card)
-{
-	return card->dev->dev_id;
-}
+
+static inline void gelic_card_enable_rxdmac(struct gelic_card *card);
+static inline void gelic_card_disable_rxdmac(struct gelic_card *card);
+static inline void gelic_card_disable_txdmac(struct gelic_card *card);
+static inline void gelic_card_reset_chain(struct gelic_card *card,
+					  struct gelic_descr_chain *chain,
+					  struct gelic_descr *start_descr);
 
 /* set irq_mask */
-static int gelic_net_set_irq_mask(struct gelic_net_card *card, u64 mask)
+int gelic_card_set_irq_mask(struct gelic_card *card, u64 mask)
 {
 	int status;
 
@@ -76,54 +72,110 @@ static int gelic_net_set_irq_mask(struct gelic_net_card *card, u64 mask)
 					    mask, 0);
 	if (status)
 		dev_info(ctodev(card),
-			 "lv1_net_set_interrupt_mask failed %d\n", status);
+			 "%s failed %d\n", __func__, status);
 	return status;
 }
-static inline void gelic_net_rx_irq_on(struct gelic_net_card *card)
+
+static inline void gelic_card_rx_irq_on(struct gelic_card *card)
 {
-	gelic_net_set_irq_mask(card, card->ghiintmask | GELIC_NET_RXINT);
+	card->irq_mask |= GELIC_CARD_RXINT;
+	gelic_card_set_irq_mask(card, card->irq_mask);
 }
-static inline void gelic_net_rx_irq_off(struct gelic_net_card *card)
+static inline void gelic_card_rx_irq_off(struct gelic_card *card)
 {
-	gelic_net_set_irq_mask(card, card->ghiintmask & ~GELIC_NET_RXINT);
+	card->irq_mask &= ~GELIC_CARD_RXINT;
+	gelic_card_set_irq_mask(card, card->irq_mask);
+}
+
+static void gelic_card_get_ether_port_status(struct gelic_card *card,
+					     int inform)
+{
+	u64 v2;
+	struct net_device *ether_netdev;
+
+	lv1_net_control(bus_id(card), dev_id(card),
+			GELIC_LV1_GET_ETH_PORT_STATUS,
+			GELIC_LV1_VLAN_TX_ETHERNET, 0, 0,
+			&card->ether_port_status, &v2);
+
+	if (inform) {
+		ether_netdev = card->netdev[GELIC_PORT_ETHERNET];
+		if (card->ether_port_status & GELIC_LV1_ETHER_LINK_UP)
+			netif_carrier_on(ether_netdev);
+		else
+			netif_carrier_off(ether_netdev);
+	}
+}
+
+void gelic_card_up(struct gelic_card *card)
+{
+	pr_debug("%s: called\n", __func__);
+	down(&card->updown_lock);
+	if (atomic_inc_return(&card->users) == 1) {
+		pr_debug("%s: real do\n", __func__);
+		/* enable irq */
+		gelic_card_set_irq_mask(card, card->irq_mask);
+		/* start rx */
+		gelic_card_enable_rxdmac(card);
+
+		napi_enable(&card->napi);
+	}
+	up(&card->updown_lock);
+	pr_debug("%s: done\n", __func__);
 }
+
+void gelic_card_down(struct gelic_card *card)
+{
+	u64 mask;
+	pr_debug("%s: called\n", __func__);
+	down(&card->updown_lock);
+	if (atomic_dec_if_positive(&card->users) == 0) {
+		pr_debug("%s: real do\n", __func__);
+		napi_disable(&card->napi);
+		/*
+		 * Disable irq. Wireless interrupts will
+		 * be disabled later if any
+		 */
+		mask = card->irq_mask & (GELIC_CARD_WLAN_EVENT_RECEIVED |
+					 GELIC_CARD_WLAN_COMMAND_COMPLETED);
+		gelic_card_set_irq_mask(card, mask);
+		/* stop rx */
+		gelic_card_disable_rxdmac(card);
+		gelic_card_reset_chain(card, &card->rx_chain,
+				       card->descr + GELIC_NET_TX_DESCRIPTORS);
+		/* stop tx */
+		gelic_card_disable_txdmac(card);
+	}
+	up(&card->updown_lock);
+	pr_debug("%s: done\n", __func__);
+}
+
 /**
- * gelic_net_get_descr_status -- returns the status of a descriptor
+ * gelic_descr_get_status -- returns the status of a descriptor
  * @descr: descriptor to look at
  *
  * returns the status as in the dmac_cmd_status field of the descriptor
  */
-static enum gelic_net_descr_status
-gelic_net_get_descr_status(struct gelic_net_descr *descr)
+static enum gelic_descr_dma_status
+gelic_descr_get_status(struct gelic_descr *descr)
 {
-	u32 cmd_status;
-
-	cmd_status = descr->dmac_cmd_status;
-	cmd_status >>= GELIC_NET_DESCR_IND_PROC_SHIFT;
-	return cmd_status;
+	return be32_to_cpu(descr->dmac_cmd_status) & GELIC_DESCR_DMA_STAT_MASK;
 }
 
 /**
- * gelic_net_set_descr_status -- sets the status of a descriptor
+ * gelic_descr_set_status -- sets the status of a descriptor
  * @descr: descriptor to change
  * @status: status to set in the descriptor
  *
  * changes the status to the specified value. Doesn't change other bits
  * in the status
  */
-static void gelic_net_set_descr_status(struct gelic_net_descr *descr,
-				       enum gelic_net_descr_status status)
+static void gelic_descr_set_status(struct gelic_descr *descr,
+				   enum gelic_descr_dma_status status)
 {
-	u32 cmd_status;
-
-	/* read the status */
-	cmd_status = descr->dmac_cmd_status;
-	/* clean the upper 4 bits */
-	cmd_status &= GELIC_NET_DESCR_IND_PROC_MASKO;
-	/* add the status to it */
-	cmd_status |= ((u32)status) << GELIC_NET_DESCR_IND_PROC_SHIFT;
-	/* and write it back */
-	descr->dmac_cmd_status = cmd_status;
+	descr->dmac_cmd_status = cpu_to_be32(status |
+			(be32_to_cpu(descr->dmac_cmd_status) &
+			 ~GELIC_DESCR_DMA_STAT_MASK));
 	/*
 	 * dma_cmd_status field is used to indicate whether the descriptor
 	 * is valid or not.
@@ -134,24 +186,24 @@ static void gelic_net_set_descr_status(struct gelic_net_descr *descr,
 }
 
 /**
- * gelic_net_free_chain - free descriptor chain
+ * gelic_card_free_chain - free descriptor chain
  * @card: card structure
  * @descr_in: address of desc
  */
-static void gelic_net_free_chain(struct gelic_net_card *card,
-				 struct gelic_net_descr *descr_in)
+static void gelic_card_free_chain(struct gelic_card *card,
+				  struct gelic_descr *descr_in)
 {
-	struct gelic_net_descr *descr;
+	struct gelic_descr *descr;
 
 	for (descr = descr_in; descr && descr->bus_addr; descr = descr->next) {
 		dma_unmap_single(ctodev(card), descr->bus_addr,
-				 GELIC_NET_DESCR_SIZE, DMA_BIDIRECTIONAL);
+				 GELIC_DESCR_SIZE, DMA_BIDIRECTIONAL);
 		descr->bus_addr = 0;
 	}
 }
 
 /**
- * gelic_net_init_chain - links descriptor chain
+ * gelic_card_init_chain - links descriptor chain
  * @card: card structure
  * @chain: address of chain
  * @start_descr: address of descriptor array
@@ -162,22 +214,22 @@ static void gelic_net_free_chain(struct gelic_net_card *card,
  *
  * returns 0 on success, <0 on failure
  */
-static int gelic_net_init_chain(struct gelic_net_card *card,
-				struct gelic_net_descr_chain *chain,
-				struct gelic_net_descr *start_descr, int no)
+static int gelic_card_init_chain(struct gelic_card *card,
+				 struct gelic_descr_chain *chain,
+				 struct gelic_descr *start_descr, int no)
 {
 	int i;
-	struct gelic_net_descr *descr;
+	struct gelic_descr *descr;
 
 	descr = start_descr;
 	memset(descr, 0, sizeof(*descr) * no);
 
 	/* set up the hardware pointers in each descriptor */
 	for (i = 0; i < no; i++, descr++) {
-		gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
+		gelic_descr_set_status(descr, GELIC_DESCR_DMA_NOT_IN_USE);
 		descr->bus_addr =
 			dma_map_single(ctodev(card), descr,
-				       GELIC_NET_DESCR_SIZE,
+				       GELIC_DESCR_SIZE,
 				       DMA_BIDIRECTIONAL);
 
 		if (!descr->bus_addr)
@@ -193,7 +245,7 @@ static int gelic_net_init_chain(struct gelic_net_card *card,
 	/* chain bus addr of hw descriptor */
 	descr = start_descr;
 	for (i = 0; i < no; i++, descr++) {
-		descr->next_descr_addr = descr->next->bus_addr;
+		descr->next_descr_addr = cpu_to_be32(descr->next->bus_addr);
 	}
 
 	chain->head = start_descr;
@@ -208,13 +260,38 @@ iommu_error:
 	for (i--, descr--; 0 <= i; i--, descr--)
 		if (descr->bus_addr)
 			dma_unmap_single(ctodev(card), descr->bus_addr,
-					 GELIC_NET_DESCR_SIZE,
+					 GELIC_DESCR_SIZE,
 					 DMA_BIDIRECTIONAL);
 	return -ENOMEM;
 }
 
 /**
- * gelic_net_prepare_rx_descr - reinitializes a rx descriptor
+ * gelic_card_reset_chain - reset status of a descriptor chain
+ * @card: card structure
+ * @chain: address of chain
+ * @start_descr: address of descriptor array
+ *
+ * Reset the status of dma descriptors to ready state
+ * and re-initialize the hardware chain for later use
+ */
+static void gelic_card_reset_chain(struct gelic_card *card,
+				   struct gelic_descr_chain *chain,
+				   struct gelic_descr *start_descr)
+{
+	struct gelic_descr *descr;
+
+	for (descr = start_descr; start_descr != descr->next; descr++) {
+		gelic_descr_set_status(descr, GELIC_DESCR_DMA_CARDOWNED);
+		descr->next_descr_addr = cpu_to_be32(descr->next->bus_addr);
+	}
+
+	chain->head = start_descr;
+	chain->tail = (descr - 1);
+
+	(descr - 1)->next_descr_addr = 0;
+}
+/**
+ * gelic_descr_prepare_rx - reinitializes a rx descriptor
  * @card: card structure
  * @descr: descriptor to re-init
  *
@@ -223,29 +300,27 @@ iommu_error:
  * allocates a new rx skb, iommu-maps it and attaches it to the descriptor.
  * Activate the descriptor state-wise
  */
-static int gelic_net_prepare_rx_descr(struct gelic_net_card *card,
-				      struct gelic_net_descr *descr)
+static int gelic_descr_prepare_rx(struct gelic_card *card,
+				  struct gelic_descr *descr)
 {
 	int offset;
 	unsigned int bufsize;
 
-	if (gelic_net_get_descr_status(descr) !=  GELIC_NET_DESCR_NOT_IN_USE) {
+	if (gelic_descr_get_status(descr) !=  GELIC_DESCR_DMA_NOT_IN_USE)
 		dev_info(ctodev(card), "%s: ERROR status \n", __func__);
-	}
 	/* we need to round up the buffer size to a multiple of 128 */
 	bufsize = ALIGN(GELIC_NET_MAX_MTU, GELIC_NET_RXBUF_ALIGN);
 
 	/* and we need to have it 128 byte aligned, therefore we allocate a
 	 * bit more */
-	descr->skb = netdev_alloc_skb(card->netdev,
-		bufsize + GELIC_NET_RXBUF_ALIGN - 1);
+	descr->skb = dev_alloc_skb(bufsize + GELIC_NET_RXBUF_ALIGN - 1);
 	if (!descr->skb) {
 		descr->buf_addr = 0; /* tell DMAC don't touch memory */
 		dev_info(ctodev(card),
 			 "%s:allocate skb failed !!\n", __func__);
 		return -ENOMEM;
 	}
-	descr->buf_size = bufsize;
+	descr->buf_size = cpu_to_be32(bufsize);
 	descr->dmac_cmd_status = 0;
 	descr->result_size = 0;
 	descr->valid_size = 0;
@@ -256,63 +331,64 @@ static int gelic_net_prepare_rx_descr(struct gelic_net_card *card,
 	if (offset)
 		skb_reserve(descr->skb, GELIC_NET_RXBUF_ALIGN - offset);
 	/* io-mmu-map the skb */
-	descr->buf_addr = dma_map_single(ctodev(card), descr->skb->data,
-					 GELIC_NET_MAX_MTU,
-					 DMA_FROM_DEVICE);
+	descr->buf_addr = cpu_to_be32(dma_map_single(ctodev(card),
+						     descr->skb->data,
+						     GELIC_NET_MAX_MTU,
+						     DMA_FROM_DEVICE));
 	if (!descr->buf_addr) {
 		dev_kfree_skb_any(descr->skb);
 		descr->skb = NULL;
 		dev_info(ctodev(card),
 			 "%s:Could not iommu-map rx buffer\n", __func__);
-		gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
+		gelic_descr_set_status(descr, GELIC_DESCR_DMA_NOT_IN_USE);
 		return -ENOMEM;
 	} else {
-		gelic_net_set_descr_status(descr, GELIC_NET_DESCR_CARDOWNED);
+		gelic_descr_set_status(descr, GELIC_DESCR_DMA_CARDOWNED);
 		return 0;
 	}
 }
 
 /**
- * gelic_net_release_rx_chain - free all skb of rx descr
+ * gelic_card_release_rx_chain - free all skb of rx descr
  * @card: card structure
  *
  */
-static void gelic_net_release_rx_chain(struct gelic_net_card *card)
+static void gelic_card_release_rx_chain(struct gelic_card *card)
 {
-	struct gelic_net_descr *descr = card->rx_chain.head;
+	struct gelic_descr *descr = card->rx_chain.head;
 
 	do {
 		if (descr->skb) {
 			dma_unmap_single(ctodev(card),
-					 descr->buf_addr,
+					 be32_to_cpu(descr->buf_addr),
 					 descr->skb->len,
 					 DMA_FROM_DEVICE);
 			descr->buf_addr = 0;
 			dev_kfree_skb_any(descr->skb);
 			descr->skb = NULL;
-			gelic_net_set_descr_status(descr,
-						   GELIC_NET_DESCR_NOT_IN_USE);
+			gelic_descr_set_status(descr,
+					       GELIC_DESCR_DMA_NOT_IN_USE);
 		}
 		descr = descr->next;
 	} while (descr != card->rx_chain.head);
 }
 
 /**
- * gelic_net_fill_rx_chain - fills descriptors/skbs in the rx chains
+ * gelic_card_fill_rx_chain - fills descriptors/skbs in the rx chains
  * @card: card structure
  *
  * fills all descriptors in the rx chain: allocates skbs
  * and iommu-maps them.
- * returns 0 on success, <0 on failure
+ * returns 0 on success, < 0 on failure
  */
-static int gelic_net_fill_rx_chain(struct gelic_net_card *card)
+static int gelic_card_fill_rx_chain(struct gelic_card *card)
 {
-	struct gelic_net_descr *descr = card->rx_chain.head;
+	struct gelic_descr *descr = card->rx_chain.head;
 	int ret;
 
 	do {
 		if (!descr->skb) {
-			ret = gelic_net_prepare_rx_descr(card, descr);
+			ret = gelic_descr_prepare_rx(card, descr);
 			if (ret)
 				goto rewind;
 		}
@@ -321,41 +397,41 @@ static int gelic_net_fill_rx_chain(struct gelic_net_card *card)
 
 	return 0;
 rewind:
-	gelic_net_release_rx_chain(card);
+	gelic_card_release_rx_chain(card);
 	return ret;
 }
 
 /**
- * gelic_net_alloc_rx_skbs - allocates rx skbs in rx descriptor chains
+ * gelic_card_alloc_rx_skbs - allocates rx skbs in rx descriptor chains
  * @card: card structure
  *
- * returns 0 on success, <0 on failure
+ * returns 0 on success, < 0 on failure
  */
-static int gelic_net_alloc_rx_skbs(struct gelic_net_card *card)
+static int gelic_card_alloc_rx_skbs(struct gelic_card *card)
 {
-	struct gelic_net_descr_chain *chain;
+	struct gelic_descr_chain *chain;
 	int ret;
 	chain = &card->rx_chain;
-	ret = gelic_net_fill_rx_chain(card);
-	chain->head = card->rx_top->prev; /* point to the last */
+	ret = gelic_card_fill_rx_chain(card);
+	chain->tail = card->rx_top->prev; /* point to the last */
 	return ret;
 }
 
 /**
- * gelic_net_release_tx_descr - processes a used tx descriptor
+ * gelic_descr_release_tx - processes a used tx descriptor
  * @card: card structure
  * @descr: descriptor to release
  *
  * releases a used tx descriptor (unmapping, freeing of skb)
  */
-static void gelic_net_release_tx_descr(struct gelic_net_card *card,
-			    struct gelic_net_descr *descr)
+static void gelic_descr_release_tx(struct gelic_card *card,
+				       struct gelic_descr *descr)
 {
 	struct sk_buff *skb = descr->skb;
 
-	BUG_ON(!(descr->data_status & (1 << GELIC_NET_TXDESC_TAIL)));
+	BUG_ON(!(be32_to_cpu(descr->data_status) & GELIC_DESCR_TX_TAIL));
 
-	dma_unmap_single(ctodev(card), descr->buf_addr, skb->len,
+	dma_unmap_single(ctodev(card), be32_to_cpu(descr->buf_addr), skb->len,
 			 DMA_TO_DEVICE);
 	dev_kfree_skb_any(skb);
 
@@ -369,59 +445,75 @@ static void gelic_net_release_tx_descr(struct gelic_net_card *card,
 	descr->skb = NULL;
 
 	/* set descr status */
-	gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
+	gelic_descr_set_status(descr, GELIC_DESCR_DMA_NOT_IN_USE);
+}
+
+static void gelic_card_stop_queues(struct gelic_card *card)
+{
+	netif_stop_queue(card->netdev[GELIC_PORT_ETHERNET]);
+
+	if (card->netdev[GELIC_PORT_WIRELESS])
+		netif_stop_queue(card->netdev[GELIC_PORT_WIRELESS]);
 }
+static void gelic_card_wake_queues(struct gelic_card *card)
+{
+	netif_wake_queue(card->netdev[GELIC_PORT_ETHERNET]);
 
+	if (card->netdev[GELIC_PORT_WIRELESS])
+		netif_wake_queue(card->netdev[GELIC_PORT_WIRELESS]);
+}
 /**
- * gelic_net_release_tx_chain - processes sent tx descriptors
+ * gelic_card_release_tx_chain - processes sent tx descriptors
  * @card: adapter structure
  * @stop: net_stop sequence
  *
  * releases the tx descriptors that gelic has finished with
  */
-static void gelic_net_release_tx_chain(struct gelic_net_card *card, int stop)
+static void gelic_card_release_tx_chain(struct gelic_card *card, int stop)
 {
-	struct gelic_net_descr_chain *tx_chain;
-	enum gelic_net_descr_status status;
+	struct gelic_descr_chain *tx_chain;
+	enum gelic_descr_dma_status status;
+	struct net_device *netdev;
 	int release = 0;
 
 	for (tx_chain = &card->tx_chain;
 	     tx_chain->head != tx_chain->tail && tx_chain->tail;
 	     tx_chain->tail = tx_chain->tail->next) {
-		status = gelic_net_get_descr_status(tx_chain->tail);
+		status = gelic_descr_get_status(tx_chain->tail);
+		netdev = tx_chain->tail->skb->dev;
 		switch (status) {
-		case GELIC_NET_DESCR_RESPONSE_ERROR:
-		case GELIC_NET_DESCR_PROTECTION_ERROR:
-		case GELIC_NET_DESCR_FORCE_END:
+		case GELIC_DESCR_DMA_RESPONSE_ERROR:
+		case GELIC_DESCR_DMA_PROTECTION_ERROR:
+		case GELIC_DESCR_DMA_FORCE_END:
 			if (printk_ratelimit())
 				dev_info(ctodev(card),
 					 "%s: forcing end of tx descriptor " \
 					 "with status %x\n",
 					 __func__, status);
-			card->netdev->stats.tx_dropped++;
+			netdev->stats.tx_dropped++;
 			break;
 
-		case GELIC_NET_DESCR_COMPLETE:
+		case GELIC_DESCR_DMA_COMPLETE:
 			if (tx_chain->tail->skb) {
-				card->netdev->stats.tx_packets++;
-				card->netdev->stats.tx_bytes +=
+				netdev->stats.tx_packets++;
+				netdev->stats.tx_bytes +=
 					tx_chain->tail->skb->len;
 			}
 			break;
 
-		case GELIC_NET_DESCR_CARDOWNED:
+		case GELIC_DESCR_DMA_CARDOWNED:
 			/* pending tx request */
 		default:
-			/* any other value (== GELIC_NET_DESCR_NOT_IN_USE) */
+			/* any other value (== GELIC_DESCR_DMA_NOT_IN_USE) */
 			if (!stop)
 				goto out;
 		}
-		gelic_net_release_tx_descr(card, tx_chain->tail);
+		gelic_descr_release_tx(card, tx_chain->tail);
 		release ++;
 	}
 out:
 	if (!stop && release)
-		netif_wake_queue(card->netdev);
+		gelic_card_wake_queues(card);
 }
 
 /**
@@ -432,9 +524,9 @@ out:
  * netdev interface. It also sets up multicast, allmulti and promisc
  * flags appropriately
  */
-static void gelic_net_set_multi(struct net_device *netdev)
+void gelic_net_set_multi(struct net_device *netdev)
 {
-	struct gelic_net_card *card = netdev_priv(netdev);
+	struct gelic_card *card = netdev_card(netdev);
 	struct dev_mc_list *mc;
 	unsigned int i;
 	uint8_t *p;
@@ -456,8 +548,8 @@ static void gelic_net_set_multi(struct net_device *netdev)
 			"lv1_net_add_multicast_address failed, %d\n",
 			status);
 
-	if (netdev->flags & IFF_ALLMULTI
-		|| netdev->mc_count > GELIC_NET_MC_COUNT_MAX) { /* list max */
+	if ((netdev->flags & IFF_ALLMULTI) ||
+	    (netdev->mc_count > GELIC_NET_MC_COUNT_MAX)) {
 		status = lv1_net_add_multicast_address(bus_id(card),
 						       dev_id(card),
 						       0, 1);
@@ -468,7 +560,7 @@ static void gelic_net_set_multi(struct net_device *netdev)
 		return;
 	}
 
-	/* set multicast address */
+	/* set multicast addresses */
 	for (mc = netdev->mc_list; mc; mc = mc->next) {
 		addr = 0;
 		p = mc->dmi_addr;
@@ -487,31 +579,42 @@ static void gelic_net_set_multi(struct net_device *netdev)
 }
 
 /**
- * gelic_net_enable_rxdmac - enables the receive DMA controller
+ * gelic_card_enable_rxdmac - enables the receive DMA controller
  * @card: card structure
  *
- * gelic_net_enable_rxdmac enables the DMA controller by setting RX_DMA_EN
+ * gelic_card_enable_rxdmac enables the DMA controller by setting RX_DMA_EN
  * in the GDADMACCNTR register
  */
-static inline void gelic_net_enable_rxdmac(struct gelic_net_card *card)
+static inline void gelic_card_enable_rxdmac(struct gelic_card *card)
 {
 	int status;
 
+#ifdef DEBUG
+	if (gelic_descr_get_status(card->rx_chain.head) !=
+	    GELIC_DESCR_DMA_CARDOWNED) {
+		printk(KERN_ERR "%s: status=%x\n", __func__,
+		       be32_to_cpu(card->rx_chain.head->dmac_cmd_status));
+		printk(KERN_ERR "%s: nextphy=%x\n", __func__,
+		       be32_to_cpu(card->rx_chain.head->next_descr_addr));
+		printk(KERN_ERR "%s: head=%p\n", __func__,
+		       card->rx_chain.head);
+	}
+#endif
 	status = lv1_net_start_rx_dma(bus_id(card), dev_id(card),
-				card->rx_chain.tail->bus_addr, 0);
+				card->rx_chain.head->bus_addr, 0);
 	if (status)
 		dev_info(ctodev(card),
 			 "lv1_net_start_rx_dma failed, status=%d\n", status);
 }
 
 /**
- * gelic_net_disable_rxdmac - disables the receive DMA controller
+ * gelic_card_disable_rxdmac - disables the receive DMA controller
  * @card: card structure
  *
- * gelic_net_disable_rxdmac terminates processing on the DMA controller by
+ * gelic_card_disable_rxdmac terminates processing on the DMA controller by
  * turing off DMA and issueing a force end
  */
-static inline void gelic_net_disable_rxdmac(struct gelic_net_card *card)
+static inline void gelic_card_disable_rxdmac(struct gelic_card *card)
 {
 	int status;
 
@@ -523,13 +626,13 @@ static inline void gelic_net_disable_rxdmac(struct gelic_net_card *card)
 }
 
 /**
- * gelic_net_disable_txdmac - disables the transmit DMA controller
+ * gelic_card_disable_txdmac - disables the transmit DMA controller
  * @card: card structure
  *
- * gelic_net_disable_txdmac terminates processing on the DMA controller by
+ * gelic_card_disable_txdmac terminates processing on the DMA controller by
  * turing off DMA and issueing a force end
  */
-static inline void gelic_net_disable_txdmac(struct gelic_net_card *card)
+static inline void gelic_card_disable_txdmac(struct gelic_card *card)
 {
 	int status;
 
@@ -546,51 +649,37 @@ static inline void gelic_net_disable_txdmac(struct gelic_net_card *card)
  *
  * always returns 0
  */
-static int gelic_net_stop(struct net_device *netdev)
+int gelic_net_stop(struct net_device *netdev)
 {
-	struct gelic_net_card *card = netdev_priv(netdev);
-
-	napi_disable(&card->napi);
-	netif_stop_queue(netdev);
+	struct gelic_card *card;
 
-	/* turn off DMA, force end */
-	gelic_net_disable_rxdmac(card);
-	gelic_net_disable_txdmac(card);
-
-	gelic_net_set_irq_mask(card, 0);
-
-	/* disconnect event port */
-	free_irq(card->netdev->irq, card->netdev);
-	ps3_sb_event_receive_port_destroy(card->dev, card->netdev->irq);
-	card->netdev->irq = NO_IRQ;
+	pr_debug("%s: start\n", __func__);
 
+	netif_stop_queue(netdev);
 	netif_carrier_off(netdev);
 
-	/* release chains */
-	gelic_net_release_tx_chain(card, 1);
-	gelic_net_release_rx_chain(card);
-
-	gelic_net_free_chain(card, card->tx_top);
-	gelic_net_free_chain(card, card->rx_top);
+	card = netdev_card(netdev);
+	gelic_card_down(card);
 
+	pr_debug("%s: done\n", __func__);
 	return 0;
 }
 
 /**
- * gelic_net_get_next_tx_descr - returns the next available tx descriptor
+ * gelic_card_get_next_tx_descr - returns the next available tx descriptor
  * @card: device structure to get descriptor from
  *
  * returns the address of the next descriptor, or NULL if not available.
  */
-static struct gelic_net_descr *
-gelic_net_get_next_tx_descr(struct gelic_net_card *card)
+static struct gelic_descr *
+gelic_card_get_next_tx_descr(struct gelic_card *card)
 {
 	if (!card->tx_chain.head)
 		return NULL;
 	/*  see if the next descriptor is free */
 	if (card->tx_chain.tail != card->tx_chain.head->next &&
-	    gelic_net_get_descr_status(card->tx_chain.head) ==
-	    GELIC_NET_DESCR_NOT_IN_USE)
+	    gelic_descr_get_status(card->tx_chain.head) ==
+	    GELIC_DESCR_DMA_NOT_IN_USE)
 		return card->tx_chain.head;
 	else
 		return NULL;
@@ -606,32 +695,33 @@ gelic_net_get_next_tx_descr(struct gelic_net_card *card)
  * depending on hardware checksum settings. This function assumes a wmb()
  * has executed before.
  */
-static void gelic_net_set_txdescr_cmdstat(struct gelic_net_descr *descr,
-					  struct sk_buff *skb)
+static void gelic_descr_set_tx_cmdstat(struct gelic_descr *descr,
+				       struct sk_buff *skb)
 {
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
-		descr->dmac_cmd_status = GELIC_NET_DMAC_CMDSTAT_NOCS |
-			GELIC_NET_DMAC_CMDSTAT_END_FRAME;
+		descr->dmac_cmd_status =
+			cpu_to_be32(GELIC_DESCR_DMA_CMD_NO_CHKSUM |
+				    GELIC_DESCR_TX_DMA_FRAME_TAIL);
 	else {
 		/* is packet ip?
 		 * if yes: tcp? udp? */
 		if (skb->protocol == htons(ETH_P_IP)) {
 			if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 				descr->dmac_cmd_status =
-					GELIC_NET_DMAC_CMDSTAT_TCPCS |
-					GELIC_NET_DMAC_CMDSTAT_END_FRAME;
+				cpu_to_be32(GELIC_DESCR_DMA_CMD_TCP_CHKSUM |
+					    GELIC_DESCR_TX_DMA_FRAME_TAIL);
 
 			else if (ip_hdr(skb)->protocol == IPPROTO_UDP)
 				descr->dmac_cmd_status =
-					GELIC_NET_DMAC_CMDSTAT_UDPCS |
-					GELIC_NET_DMAC_CMDSTAT_END_FRAME;
+				cpu_to_be32(GELIC_DESCR_DMA_CMD_UDP_CHKSUM |
+					    GELIC_DESCR_TX_DMA_FRAME_TAIL);
 			else	/*
 				 * the stack should checksum non-tcp and non-udp
 				 * packets on his own: NETIF_F_IP_CSUM
 				 */
 				descr->dmac_cmd_status =
-					GELIC_NET_DMAC_CMDSTAT_NOCS |
-					GELIC_NET_DMAC_CMDSTAT_END_FRAME;
+				cpu_to_be32(GELIC_DESCR_DMA_CMD_NO_CHKSUM |
+					    GELIC_DESCR_TX_DMA_FRAME_TAIL);
 		}
 	}
 }
@@ -662,7 +752,7 @@ static inline struct sk_buff *gelic_put_vlan_tag(struct sk_buff *skb,
 }
 
 /**
- * gelic_net_prepare_tx_descr_v - get dma address of skb_data
+ * gelic_descr_prepare_tx - setup a descriptor for sending packets
  * @card: card structure
  * @descr: descriptor structure
  * @skb: packet to use
@@ -670,16 +760,19 @@ static inline struct sk_buff *gelic_put_vlan_tag(struct sk_buff *skb,
  * returns 0 on success, <0 on failure.
  *
  */
-static int gelic_net_prepare_tx_descr_v(struct gelic_net_card *card,
-					struct gelic_net_descr *descr,
-					struct sk_buff *skb)
+static int gelic_descr_prepare_tx(struct gelic_card *card,
+				  struct gelic_descr *descr,
+				  struct sk_buff *skb)
 {
 	dma_addr_t buf;
 
-	if (card->vlan_index != -1) {
+	if (card->vlan_required) {
 		struct sk_buff *skb_tmp;
+		enum gelic_port_type type;
+
+		type = netdev_port(skb->dev)->type;
 		skb_tmp = gelic_put_vlan_tag(skb,
-					     card->vlan_id[card->vlan_index]);
+					     card->vlan[type].tx);
 		if (!skb_tmp)
 			return -ENOMEM;
 		skb = skb_tmp;
@@ -694,12 +787,12 @@ static int gelic_net_prepare_tx_descr_v(struct gelic_net_card *card,
 		return -ENOMEM;
 	}
 
-	descr->buf_addr = buf;
-	descr->buf_size = skb->len;
+	descr->buf_addr = cpu_to_be32(buf);
+	descr->buf_size = cpu_to_be32(skb->len);
 	descr->skb = skb;
 	descr->data_status = 0;
 	descr->next_descr_addr = 0; /* terminate hw descr */
-	gelic_net_set_txdescr_cmdstat(descr, skb);
+	gelic_descr_set_tx_cmdstat(descr, skb);
 
 	/* bump free descriptor pointer */
 	card->tx_chain.head = descr->next;
@@ -707,20 +800,20 @@ static int gelic_net_prepare_tx_descr_v(struct gelic_net_card *card,
 }
 
 /**
- * gelic_net_kick_txdma - enables TX DMA processing
+ * gelic_card_kick_txdma - enables TX DMA processing
  * @card: card structure
  * @descr: descriptor address to enable TX processing at
  *
  */
-static int gelic_net_kick_txdma(struct gelic_net_card *card,
-				struct gelic_net_descr *descr)
+static int gelic_card_kick_txdma(struct gelic_card *card,
+				 struct gelic_descr *descr)
 {
 	int status = 0;
 
 	if (card->tx_dma_progress)
 		return 0;
 
-	if (gelic_net_get_descr_status(descr) == GELIC_NET_DESCR_CARDOWNED) {
+	if (gelic_descr_get_status(descr) == GELIC_DESCR_DMA_CARDOWNED) {
 		card->tx_dma_progress = 1;
 		status = lv1_net_start_tx_dma(bus_id(card), dev_id(card),
 					      descr->bus_addr, 0);
@@ -738,56 +831,56 @@ static int gelic_net_kick_txdma(struct gelic_net_card *card,
  *
  * returns 0 on success, <0 on failure
  */
-static int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev)
+int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
-	struct gelic_net_card *card = netdev_priv(netdev);
-	struct gelic_net_descr *descr;
+	struct gelic_card *card = netdev_card(netdev);
+	struct gelic_descr *descr;
 	int result;
 	unsigned long flags;
 
-	spin_lock_irqsave(&card->tx_dma_lock, flags);
+	spin_lock_irqsave(&card->tx_lock, flags);
 
-	gelic_net_release_tx_chain(card, 0);
+	gelic_card_release_tx_chain(card, 0);
 
-	descr = gelic_net_get_next_tx_descr(card);
+	descr = gelic_card_get_next_tx_descr(card);
 	if (!descr) {
 		/*
 		 * no more descriptors free
 		 */
-		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&card->tx_dma_lock, flags);
+		gelic_card_stop_queues(card);
+		spin_unlock_irqrestore(&card->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
-	result = gelic_net_prepare_tx_descr_v(card, descr, skb);
+	result = gelic_descr_prepare_tx(card, descr, skb);
 	if (result) {
 		/*
 		 * DMA map failed.  As chanses are that failure
 		 * would continue, just release skb and return
 		 */
-		card->netdev->stats.tx_dropped++;
+		netdev->stats.tx_dropped++;
 		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&card->tx_dma_lock, flags);
+		spin_unlock_irqrestore(&card->tx_lock, flags);
 		return NETDEV_TX_OK;
 	}
 	/*
 	 * link this prepared descriptor to previous one
 	 * to achieve high performance
 	 */
-	descr->prev->next_descr_addr = descr->bus_addr;
+	descr->prev->next_descr_addr = cpu_to_be32(descr->bus_addr);
 	/*
 	 * as hardware descriptor is modified in the above lines,
 	 * ensure that the hardware sees it
 	 */
 	wmb();
-	if (gelic_net_kick_txdma(card, descr)) {
+	if (gelic_card_kick_txdma(card, descr)) {
 		/*
 		 * kick failed.
 		 * release descriptors which were just prepared
 		 */
-		card->netdev->stats.tx_dropped++;
-		gelic_net_release_tx_descr(card, descr);
-		gelic_net_release_tx_descr(card, descr->next);
+		netdev->stats.tx_dropped++;
+		gelic_descr_release_tx(card, descr);
+		gelic_descr_release_tx(card, descr->next);
 		card->tx_chain.tail = descr->next->next;
 		dev_info(ctodev(card), "%s: kick failure\n", __func__);
 	} else {
@@ -795,7 +888,7 @@ static int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev)
 		netdev->trans_start = jiffies;
 	}
 
-	spin_unlock_irqrestore(&card->tx_dma_lock, flags);
+	spin_unlock_irqrestore(&card->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
 
@@ -803,30 +896,34 @@ static int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev)
  * gelic_net_pass_skb_up - takes an skb from a descriptor and passes it on
  * @descr: descriptor to process
  * @card: card structure
+ * @netdev: net_device structure to be passed packet
  *
  * iommu-unmaps the skb, fills out skb structure and passes the data to the
  * stack. The descriptor state is not changed.
  */
-static void gelic_net_pass_skb_up(struct gelic_net_descr *descr,
-				 struct gelic_net_card *card)
+static void gelic_net_pass_skb_up(struct gelic_descr *descr,
+				  struct gelic_card *card,
+				  struct net_device *netdev)
+
 {
-	struct sk_buff *skb;
-	struct net_device *netdev;
+	struct sk_buff *skb = descr->skb;
 	u32 data_status, data_error;
 
-	data_status = descr->data_status;
-	data_error = descr->data_error;
-	netdev = card->netdev;
+	data_status = be32_to_cpu(descr->data_status);
+	data_error = be32_to_cpu(descr->data_error);
 	/* unmap skb buffer */
-	skb = descr->skb;
-	dma_unmap_single(ctodev(card), descr->buf_addr, GELIC_NET_MAX_MTU,
+	dma_unmap_single(ctodev(card), be32_to_cpu(descr->buf_addr),
+			 GELIC_NET_MAX_MTU,
 			 DMA_FROM_DEVICE);
 
-	skb_put(skb, descr->valid_size? descr->valid_size : descr->result_size);
+	skb_put(skb, be32_to_cpu(descr->valid_size)?
+		be32_to_cpu(descr->valid_size) :
+		be32_to_cpu(descr->result_size));
 	if (!descr->valid_size)
 		dev_info(ctodev(card), "buffer full %x %x %x\n",
-			 descr->result_size, descr->buf_size,
-			 descr->dmac_cmd_status);
+			 be32_to_cpu(descr->result_size),
+			 be32_to_cpu(descr->buf_size),
+			 be32_to_cpu(descr->dmac_cmd_status));
 
 	descr->skb = NULL;
 	/*
@@ -838,8 +935,8 @@ static void gelic_net_pass_skb_up(struct gelic_net_descr *descr,
 
 	/* checksum offload */
 	if (card->rx_csum) {
-		if ((data_status & GELIC_NET_DATA_STATUS_CHK_MASK) &&
-		    (!(data_error & GELIC_NET_DATA_ERROR_CHK_MASK)))
+		if ((data_status & GELIC_DESCR_DATA_STATUS_CHK_MASK) &&
+		    (!(data_error & GELIC_DESCR_DATA_ERROR_CHK_MASK)))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		else
 			skb->ip_summed = CHECKSUM_NONE;
@@ -847,15 +944,15 @@ static void gelic_net_pass_skb_up(struct gelic_net_descr *descr,
 		skb->ip_summed = CHECKSUM_NONE;
 
 	/* update netdevice statistics */
-	card->netdev->stats.rx_packets++;
-	card->netdev->stats.rx_bytes += skb->len;
+	netdev->stats.rx_packets++;
+	netdev->stats.rx_bytes += skb->len;
 
 	/* pass skb up to stack */
 	netif_receive_skb(skb);
 }
 
 /**
- * gelic_net_decode_one_descr - processes an rx descriptor
+ * gelic_card_decode_one_descr - processes an rx descriptor
  * @card: card structure
  *
  * returns 1 if a packet has been sent to the stack, otherwise 0
@@ -863,36 +960,56 @@ static void gelic_net_pass_skb_up(struct gelic_net_descr *descr,
  * processes an rx descriptor by iommu-unmapping the data buffer and passing
  * the packet up to the stack
  */
-static int gelic_net_decode_one_descr(struct gelic_net_card *card)
+static int gelic_card_decode_one_descr(struct gelic_card *card)
 {
-	enum gelic_net_descr_status status;
-	struct gelic_net_descr_chain *chain = &card->rx_chain;
-	struct gelic_net_descr *descr = chain->tail;
+	enum gelic_descr_dma_status status;
+	struct gelic_descr_chain *chain = &card->rx_chain;
+	struct gelic_descr *descr = chain->head;
+	struct net_device *netdev = NULL;
 	int dmac_chain_ended;
 
-	status = gelic_net_get_descr_status(descr);
+	status = gelic_descr_get_status(descr);
 	/* is this descriptor terminated with next_descr == NULL? */
 	dmac_chain_ended =
-		descr->dmac_cmd_status & GELIC_NET_DMAC_CMDSTAT_RXDCEIS;
+		be32_to_cpu(descr->dmac_cmd_status) &
+		GELIC_DESCR_RX_DMA_CHAIN_END;
 
-	if (status == GELIC_NET_DESCR_CARDOWNED)
+	if (status == GELIC_DESCR_DMA_CARDOWNED)
 		return 0;
 
-	if (status == GELIC_NET_DESCR_NOT_IN_USE) {
+	if (status == GELIC_DESCR_DMA_NOT_IN_USE) {
 		dev_dbg(ctodev(card), "dormant descr? %p\n", descr);
 		return 0;
 	}
 
-	if ((status == GELIC_NET_DESCR_RESPONSE_ERROR) ||
-	    (status == GELIC_NET_DESCR_PROTECTION_ERROR) ||
-	    (status == GELIC_NET_DESCR_FORCE_END)) {
+	/* netdevice select */
+	if (card->vlan_required) {
+		unsigned int i;
+		u16 vid;
+		vid = *(u16 *)(descr->skb->data) & VLAN_VID_MASK;
+		for (i = 0; i < GELIC_PORT_MAX; i++) {
+			if (card->vlan[i].rx == vid) {
+				netdev = card->netdev[i];
+				break;
+			}
+		};
+		if (GELIC_PORT_MAX <= i) {
+			pr_info("%s: unknown packet vid=%x\n", __func__, vid);
+			goto refill;
+		}
+	} else
+		netdev = card->netdev[GELIC_PORT_ETHERNET];
+
+	if ((status == GELIC_DESCR_DMA_RESPONSE_ERROR) ||
+	    (status == GELIC_DESCR_DMA_PROTECTION_ERROR) ||
+	    (status == GELIC_DESCR_DMA_FORCE_END)) {
 		dev_info(ctodev(card), "dropping RX descriptor with state %x\n",
 			 status);
-		card->netdev->stats.rx_dropped++;
+		netdev->stats.rx_dropped++;
 		goto refill;
 	}
 
-	if (status == GELIC_NET_DESCR_BUFFER_FULL) {
+	if (status == GELIC_DESCR_DMA_BUFFER_FULL) {
 		/*
 		 * Buffer full would occur if and only if
 		 * the frame length was longer than the size of this
@@ -909,14 +1026,14 @@ static int gelic_net_decode_one_descr(struct gelic_net_card *card)
 	 * descriptoers any other than FRAME_END here should
 	 * be treated as error.
 	 */
-	if (status != GELIC_NET_DESCR_FRAME_END) {
+	if (status != GELIC_DESCR_DMA_FRAME_END) {
 		dev_dbg(ctodev(card), "RX descriptor with state %x\n",
 			status);
 		goto refill;
 	}
 
 	/* ok, we've got a packet in descr */
-	gelic_net_pass_skb_up(descr, card);
+	gelic_net_pass_skb_up(descr, card, netdev);
 refill:
 	/*
 	 * So that always DMAC can see the end
@@ -926,21 +1043,21 @@ refill:
 	descr->next_descr_addr = 0;
 
 	/* change the descriptor state: */
-	gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
+	gelic_descr_set_status(descr, GELIC_DESCR_DMA_NOT_IN_USE);
 
 	/*
 	 * this call can fail, but for now, just leave this
 	 * decriptor without skb
 	 */
-	gelic_net_prepare_rx_descr(card, descr);
+	gelic_descr_prepare_rx(card, descr);
 
-	chain->head = descr;
-	chain->tail = descr->next;
+	chain->tail = descr;
+	chain->head = descr->next;
 
 	/*
 	 * Set this descriptor the end of the chain.
 	 */
-	descr->prev->next_descr_addr = descr->bus_addr;
+	descr->prev->next_descr_addr = cpu_to_be32(descr->bus_addr);
 
 	/*
 	 * If dmac chain was met, DMAC stopped.
@@ -956,29 +1073,27 @@ refill:
 
 /**
  * gelic_net_poll - NAPI poll function called by the stack to return packets
- * @netdev: interface device structure
+ * @napi: napi structure
  * @budget: number of packets we can pass to the stack at most
  *
- * returns 0 if no more packets available to the driver/stack. Returns 1,
- * if the quota is exceeded, but the driver has still packets.
+ * returns the number of the processed packets
  *
  */
 static int gelic_net_poll(struct napi_struct *napi, int budget)
 {
-	struct gelic_net_card *card = container_of(napi, struct gelic_net_card, napi);
-	struct net_device *netdev = card->netdev;
+	struct gelic_card *card = container_of(napi, struct gelic_card, napi);
 	int packets_done = 0;
 
 	while (packets_done < budget) {
-		if (!gelic_net_decode_one_descr(card))
+		if (!gelic_card_decode_one_descr(card))
 			break;
 
 		packets_done++;
 	}
 
 	if (packets_done < budget) {
-		netif_rx_complete(netdev, napi);
-		gelic_net_rx_irq_on(card);
+		napi_complete(napi);
+		gelic_card_rx_irq_on(card);
 	}
 	return packets_done;
 }
@@ -989,7 +1104,7 @@ static int gelic_net_poll(struct napi_struct *napi, int budget)
  *
  * returns 0 on success, <0 on failure
  */
-static int gelic_net_change_mtu(struct net_device *netdev, int new_mtu)
+int gelic_net_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	/* no need to re-alloc skbs or so -- the max mtu is about 2.3k
 	 * and mtu is outbound only anyway */
@@ -1002,13 +1117,12 @@ static int gelic_net_change_mtu(struct net_device *netdev, int new_mtu)
 }
 
 /**
- * gelic_net_interrupt - event handler for gelic_net
+ * gelic_card_interrupt - event handler for gelic_net
  */
-static irqreturn_t gelic_net_interrupt(int irq, void *ptr)
+static irqreturn_t gelic_card_interrupt(int irq, void *ptr)
 {
 	unsigned long flags;
-	struct net_device *netdev = ptr;
-	struct gelic_net_card *card = netdev_priv(netdev);
+	struct gelic_card *card = ptr;
 	u64 status;
 
 	status = card->irq_status;
@@ -1016,24 +1130,37 @@ static irqreturn_t gelic_net_interrupt(int irq, void *ptr)
 	if (!status)
 		return IRQ_NONE;
 
+	status &= card->irq_mask;
+
 	if (card->rx_dma_restart_required) {
 		card->rx_dma_restart_required = 0;
-		gelic_net_enable_rxdmac(card);
+		gelic_card_enable_rxdmac(card);
 	}
 
-	if (status & GELIC_NET_RXINT) {
-		gelic_net_rx_irq_off(card);
-		netif_rx_schedule(netdev, &card->napi);
+	if (status & GELIC_CARD_RXINT) {
+		gelic_card_rx_irq_off(card);
+		napi_schedule(&card->napi);
 	}
 
-	if (status & GELIC_NET_TXINT) {
-		spin_lock_irqsave(&card->tx_dma_lock, flags);
+	if (status & GELIC_CARD_TXINT) {
+		spin_lock_irqsave(&card->tx_lock, flags);
 		card->tx_dma_progress = 0;
-		gelic_net_release_tx_chain(card, 0);
+		gelic_card_release_tx_chain(card, 0);
 		/* kick outstanding tx descriptor if any */
-		gelic_net_kick_txdma(card, card->tx_chain.tail);
-		spin_unlock_irqrestore(&card->tx_dma_lock, flags);
+		gelic_card_kick_txdma(card, card->tx_chain.tail);
+		spin_unlock_irqrestore(&card->tx_lock, flags);
 	}
+
+	/* ether port status changed */
+	if (status & GELIC_CARD_PORT_STATUS_CHANGED)
+		gelic_card_get_ether_port_status(card, 1);
+
+#ifdef CONFIG_GELIC_WIRELESS
+	if (status & (GELIC_CARD_WLAN_EVENT_RECEIVED |
+		      GELIC_CARD_WLAN_COMMAND_COMPLETED))
+		gelic_wl_interrupt(card->netdev[GELIC_PORT_WIRELESS], status);
+#endif
+
 	return IRQ_HANDLED;
 }
 
@@ -1044,55 +1171,17 @@ static irqreturn_t gelic_net_interrupt(int irq, void *ptr)
  *
  * see Documentation/networking/netconsole.txt
  */
-static void gelic_net_poll_controller(struct net_device *netdev)
+void gelic_net_poll_controller(struct net_device *netdev)
 {
-	struct gelic_net_card *card = netdev_priv(netdev);
+	struct gelic_card *card = netdev_card(netdev);
 
-	gelic_net_set_irq_mask(card, 0);
-	gelic_net_interrupt(netdev->irq, netdev);
-	gelic_net_set_irq_mask(card, card->ghiintmask);
+	gelic_card_set_irq_mask(card, 0);
+	gelic_card_interrupt(netdev->irq, netdev);
+	gelic_card_set_irq_mask(card, card->irq_mask);
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 
 /**
- * gelic_net_open_device - open device and map dma region
- * @card: card structure
- */
-static int gelic_net_open_device(struct gelic_net_card *card)
-{
-	int result;
-
-	result = ps3_sb_event_receive_port_setup(card->dev, PS3_BINDING_CPU_ANY,
-		&card->netdev->irq);
-
-	if (result) {
-		dev_info(ctodev(card),
-			 "%s:%d: gelic_net_open_device failed (%d)\n",
-			 __func__, __LINE__, result);
-		result = -EPERM;
-		goto fail_alloc_irq;
-	}
-
-	result = request_irq(card->netdev->irq, gelic_net_interrupt,
-			     IRQF_DISABLED, card->netdev->name, card->netdev);
-
-	if (result) {
-		dev_info(ctodev(card), "%s:%d: request_irq failed (%d)\n",
-			__func__, __LINE__, result);
-		goto fail_request_irq;
-	}
-
-	return 0;
-
-fail_request_irq:
-	ps3_sb_event_receive_port_destroy(card->dev, card->netdev->irq);
-	card->netdev->irq = NO_IRQ;
-fail_alloc_irq:
-	return result;
-}
-
-
-/**
  * gelic_net_open - called upon ifonfig up
  * @netdev: interface device structure
  *
@@ -1101,169 +1190,88 @@ fail_alloc_irq:
  * gelic_net_open allocates all the descriptors and memory needed for
  * operation, sets up multicast list and enables interrupts
  */
-static int gelic_net_open(struct net_device *netdev)
+int gelic_net_open(struct net_device *netdev)
 {
-	struct gelic_net_card *card = netdev_priv(netdev);
-
-	dev_dbg(ctodev(card), " -> %s:%d\n", __func__, __LINE__);
-
-	gelic_net_open_device(card);
-
-	if (gelic_net_init_chain(card, &card->tx_chain,
-			card->descr, GELIC_NET_TX_DESCRIPTORS))
-		goto alloc_tx_failed;
-	if (gelic_net_init_chain(card, &card->rx_chain,
-				 card->descr + GELIC_NET_TX_DESCRIPTORS,
-				 GELIC_NET_RX_DESCRIPTORS))
-		goto alloc_rx_failed;
-
-	/* head of chain */
-	card->tx_top = card->tx_chain.head;
-	card->rx_top = card->rx_chain.head;
-	dev_dbg(ctodev(card), "descr rx %p, tx %p, size %#lx, num %#x\n",
-		card->rx_top, card->tx_top, sizeof(struct gelic_net_descr),
-		GELIC_NET_RX_DESCRIPTORS);
-	/* allocate rx skbs */
-	if (gelic_net_alloc_rx_skbs(card))
-		goto alloc_skbs_failed;
+	struct gelic_card *card = netdev_card(netdev);
 
-	napi_enable(&card->napi);
-
-	card->tx_dma_progress = 0;
-	card->ghiintmask = GELIC_NET_RXINT | GELIC_NET_TXINT;
+	dev_dbg(ctodev(card), " -> %s %p\n", __func__, netdev);
 
-	gelic_net_set_irq_mask(card, card->ghiintmask);
-	gelic_net_enable_rxdmac(card);
+	gelic_card_up(card);
 
 	netif_start_queue(netdev);
-	netif_carrier_on(netdev);
+	gelic_card_get_ether_port_status(card, 1);
 
+	dev_dbg(ctodev(card), " <- %s\n", __func__);
 	return 0;
-
-alloc_skbs_failed:
-	gelic_net_free_chain(card, card->rx_top);
-alloc_rx_failed:
-	gelic_net_free_chain(card, card->tx_top);
-alloc_tx_failed:
-	return -ENOMEM;
 }
 
-static void gelic_net_get_drvinfo (struct net_device *netdev,
-				   struct ethtool_drvinfo *info)
+void gelic_net_get_drvinfo(struct net_device *netdev,
+			   struct ethtool_drvinfo *info)
 {
 	strncpy(info->driver, DRV_NAME, sizeof(info->driver) - 1);
 	strncpy(info->version, DRV_VERSION, sizeof(info->version) - 1);
 }
 
-static int gelic_net_get_settings(struct net_device *netdev,
-				  struct ethtool_cmd *cmd)
+static int gelic_ether_get_settings(struct net_device *netdev,
+				    struct ethtool_cmd *cmd)
 {
-	struct gelic_net_card *card = netdev_priv(netdev);
-	int status;
-	u64 v1, v2;
-	int speed, duplex;
+	struct gelic_card *card = netdev_card(netdev);
 
-	speed = duplex = -1;
-	status = lv1_net_control(bus_id(card), dev_id(card),
-			GELIC_NET_GET_ETH_PORT_STATUS, GELIC_NET_PORT, 0, 0,
-			&v1, &v2);
-	if (status) {
-		/* link down */
-	} else {
-		if (v1 & GELIC_NET_FULL_DUPLEX) {
-			duplex = DUPLEX_FULL;
-		} else {
-			duplex = DUPLEX_HALF;
-		}
+	gelic_card_get_ether_port_status(card, 0);
 
-		if (v1 & GELIC_NET_SPEED_10 ) {
-			speed = SPEED_10;
-		} else if (v1 & GELIC_NET_SPEED_100) {
-			speed = SPEED_100;
-		} else if (v1 & GELIC_NET_SPEED_1000) {
-			speed = SPEED_1000;
-		}
+	if (card->ether_port_status & GELIC_LV1_ETHER_FULL_DUPLEX)
+		cmd->duplex = DUPLEX_FULL;
+	else
+		cmd->duplex = DUPLEX_HALF;
+
+	switch (card->ether_port_status & GELIC_LV1_ETHER_SPEED_MASK) {
+	case GELIC_LV1_ETHER_SPEED_10:
+		cmd->speed = SPEED_10;
+		break;
+	case GELIC_LV1_ETHER_SPEED_100:
+		cmd->speed = SPEED_100;
+		break;
+	case GELIC_LV1_ETHER_SPEED_1000:
+		cmd->speed = SPEED_1000;
+		break;
+	default:
+		pr_info("%s: speed unknown\n", __func__);
+		cmd->speed = SPEED_10;
+		break;
 	}
+
 	cmd->supported = SUPPORTED_TP | SUPPORTED_Autoneg |
 			SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
 			SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 			SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full;
 	cmd->advertising = cmd->supported;
-	cmd->speed = speed;
-	cmd->duplex = duplex;
 	cmd->autoneg = AUTONEG_ENABLE; /* always enabled */
 	cmd->port = PORT_TP;
 
 	return 0;
 }
 
-static u32 gelic_net_get_link(struct net_device *netdev)
+u32 gelic_net_get_rx_csum(struct net_device *netdev)
 {
-	struct gelic_net_card *card = netdev_priv(netdev);
-	int status;
-	u64 v1, v2;
-	int link;
-
-	status = lv1_net_control(bus_id(card), dev_id(card),
-			GELIC_NET_GET_ETH_PORT_STATUS, GELIC_NET_PORT, 0, 0,
-			&v1, &v2);
-	if (status)
-		return 0; /* link down */
-
-	if (v1 & GELIC_NET_LINK_UP)
-		link = 1;
-	else
-		link = 0;
-
-	return link;
-}
-
-static int gelic_net_nway_reset(struct net_device *netdev)
-{
-	if (netif_running(netdev)) {
-		gelic_net_stop(netdev);
-		gelic_net_open(netdev);
-	}
-	return 0;
-}
-
-static u32 gelic_net_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_IP_CSUM) != 0;
-}
-
-static int gelic_net_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	if (data)
-		netdev->features |= NETIF_F_IP_CSUM;
-	else
-		netdev->features &= ~NETIF_F_IP_CSUM;
-
-	return 0;
-}
-
-static u32 gelic_net_get_rx_csum(struct net_device *netdev)
-{
-	struct gelic_net_card *card = netdev_priv(netdev);
+	struct gelic_card *card = netdev_card(netdev);
 
 	return card->rx_csum;
 }
 
-static int gelic_net_set_rx_csum(struct net_device *netdev, u32 data)
+int gelic_net_set_rx_csum(struct net_device *netdev, u32 data)
 {
-	struct gelic_net_card *card = netdev_priv(netdev);
+	struct gelic_card *card = netdev_card(netdev);
 
 	card->rx_csum = data;
 	return 0;
 }
 
-static struct ethtool_ops gelic_net_ethtool_ops = {
+static struct ethtool_ops gelic_ether_ethtool_ops = {
 	.get_drvinfo	= gelic_net_get_drvinfo,
-	.get_settings	= gelic_net_get_settings,
-	.get_link	= gelic_net_get_link,
-	.nway_reset	= gelic_net_nway_reset,
-	.get_tx_csum	= gelic_net_get_tx_csum,
-	.set_tx_csum	= gelic_net_set_tx_csum,
+	.get_settings	= gelic_ether_get_settings,
+	.get_link	= ethtool_op_get_link,
+	.get_tx_csum	= ethtool_op_get_tx_csum,
+	.set_tx_csum	= ethtool_op_set_tx_csum,
 	.get_rx_csum	= gelic_net_get_rx_csum,
 	.set_rx_csum	= gelic_net_set_rx_csum,
 };
@@ -1277,9 +1285,9 @@ static struct ethtool_ops gelic_net_ethtool_ops = {
  */
 static void gelic_net_tx_timeout_task(struct work_struct *work)
 {
-	struct gelic_net_card *card =
-		container_of(work, struct gelic_net_card, tx_timeout_task);
-	struct net_device *netdev = card->netdev;
+	struct gelic_card *card =
+		container_of(work, struct gelic_card, tx_timeout_task);
+	struct net_device *netdev = card->netdev[GELIC_PORT_ETHERNET];
 
 	dev_info(ctodev(card), "%s:Timed out. Restarting... \n", __func__);
 
@@ -1302,11 +1310,11 @@ out:
  *
  * called, if tx hangs. Schedules a task that resets the interface
  */
-static void gelic_net_tx_timeout(struct net_device *netdev)
+void gelic_net_tx_timeout(struct net_device *netdev)
 {
-	struct gelic_net_card *card;
+	struct gelic_card *card;
 
-	card = netdev_priv(netdev);
+	card = netdev_card(netdev);
 	atomic_inc(&card->tx_timeout_task_counter);
 	if (netdev->flags & IFF_UP)
 		schedule_work(&card->tx_timeout_task);
@@ -1315,12 +1323,13 @@ static void gelic_net_tx_timeout(struct net_device *netdev)
 }
 
 /**
- * gelic_net_setup_netdev_ops - initialization of net_device operations
+ * gelic_ether_setup_netdev_ops - initialization of net_device operations
  * @netdev: net_device structure
  *
  * fills out function pointers in the net_device structure
  */
-static void gelic_net_setup_netdev_ops(struct net_device *netdev)
+static void gelic_ether_setup_netdev_ops(struct net_device *netdev,
+					 struct napi_struct *napi)
 {
 	netdev->open = &gelic_net_open;
 	netdev->stop = &gelic_net_stop;
@@ -1330,163 +1339,239 @@ static void gelic_net_setup_netdev_ops(struct net_device *netdev)
 	/* tx watchdog */
 	netdev->tx_timeout = &gelic_net_tx_timeout;
 	netdev->watchdog_timeo = GELIC_NET_WATCHDOG_TIMEOUT;
-	netdev->ethtool_ops = &gelic_net_ethtool_ops;
+	/* NAPI */
+	netif_napi_add(netdev, napi,
+		       gelic_net_poll, GELIC_NET_NAPI_WEIGHT);
+	netdev->ethtool_ops = &gelic_ether_ethtool_ops;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller = gelic_net_poll_controller;
+#endif
 }
 
 /**
- * gelic_net_setup_netdev - initialization of net_device
+ * gelic_ether_setup_netdev - initialization of net_device
+ * @netdev: net_device structure
  * @card: card structure
  *
  * Returns 0 on success or <0 on failure
  *
- * gelic_net_setup_netdev initializes the net_device structure
+ * gelic_ether_setup_netdev initializes the net_device structure
+ * and register it.
  **/
-static int gelic_net_setup_netdev(struct gelic_net_card *card)
+int gelic_net_setup_netdev(struct net_device *netdev, struct gelic_card *card)
 {
-	struct net_device *netdev = card->netdev;
-	struct sockaddr addr;
-	unsigned int i;
 	int status;
 	u64 v1, v2;
 	DECLARE_MAC_BUF(mac);
 
-	SET_NETDEV_DEV(netdev, &card->dev->core);
-	spin_lock_init(&card->tx_dma_lock);
-
-	card->rx_csum = GELIC_NET_RX_CSUM_DEFAULT;
-
-	gelic_net_setup_netdev_ops(netdev);
-
-	netif_napi_add(netdev, &card->napi,
-		       gelic_net_poll, GELIC_NET_NAPI_WEIGHT);
-
 	netdev->features = NETIF_F_IP_CSUM;
 
 	status = lv1_net_control(bus_id(card), dev_id(card),
-				 GELIC_NET_GET_MAC_ADDRESS,
+				 GELIC_LV1_GET_MAC_ADDRESS,
 				 0, 0, 0, &v1, &v2);
+	v1 <<= 16;
 	if (status || !is_valid_ether_addr((u8 *)&v1)) {
 		dev_info(ctodev(card),
 			 "%s:lv1_net_control GET_MAC_ADDR failed %d\n",
 			 __func__, status);
 		return -EINVAL;
 	}
-	v1 <<= 16;
-	memcpy(addr.sa_data, &v1, ETH_ALEN);
-	memcpy(netdev->dev_addr, addr.sa_data, ETH_ALEN);
-	dev_info(ctodev(card), "MAC addr %s\n",
-		 print_mac(mac, netdev->dev_addr));
+	memcpy(netdev->dev_addr, &v1, ETH_ALEN);
 
-	card->vlan_index = -1;	/* no vlan */
-	for (i = 0; i < GELIC_NET_VLAN_MAX; i++) {
-		status = lv1_net_control(bus_id(card), dev_id(card),
-					GELIC_NET_GET_VLAN_ID,
-					i + 1, /* index; one based */
-					0, 0, &v1, &v2);
-		if (status == GELIC_NET_VLAN_NO_ENTRY) {
-			dev_dbg(ctodev(card),
-				"GELIC_VLAN_ID no entry:%d, VLAN disabled\n",
-				status);
-			card->vlan_id[i] = 0;
-		} else if (status) {
-			dev_dbg(ctodev(card),
-				"%s:GELIC_NET_VLAN_ID faild, status=%d\n",
-				__func__, status);
-			card->vlan_id[i] = 0;
-		} else {
-			card->vlan_id[i] = (u32)v1;
-			dev_dbg(ctodev(card), "vlan_id:%d, %lx\n", i, v1);
-		}
-	}
-
-	if (card->vlan_id[GELIC_NET_VLAN_WIRED - 1]) {
-		card->vlan_index = GELIC_NET_VLAN_WIRED - 1;
+	if (card->vlan_required) {
 		netdev->hard_header_len += VLAN_HLEN;
+		/*
+		 * As vlan is internally used,
+		 * we can not receive vlan packets
+		 */
+		netdev->features |= NETIF_F_VLAN_CHALLENGED;
 	}
 
 	status = register_netdev(netdev);
 	if (status) {
-		dev_err(ctodev(card), "%s:Couldn't register net_device: %d\n",
-			__func__, status);
+		dev_err(ctodev(card), "%s:Couldn't register %s %d\n",
+			__func__, netdev->name, status);
 		return status;
 	}
+	dev_info(ctodev(card), "%s: MAC addr %s\n",
+		 netdev->name,
+		 print_mac(mac, netdev->dev_addr));
 
 	return 0;
 }
 
 /**
- * gelic_net_alloc_card - allocates net_device and card structure
+ * gelic_alloc_card_net - allocates net_device and card structure
  *
  * returns the card structure or NULL in case of errors
  *
  * the card and net_device structures are linked to each other
  */
-static struct gelic_net_card *gelic_net_alloc_card(void)
+#define GELIC_ALIGN (32)
+static struct gelic_card *gelic_alloc_card_net(struct net_device **netdev)
 {
-	struct net_device *netdev;
-	struct gelic_net_card *card;
+	struct gelic_card *card;
+	struct gelic_port *port;
+	void *p;
 	size_t alloc_size;
-
-	alloc_size = sizeof (*card) +
-		sizeof (struct gelic_net_descr) * GELIC_NET_RX_DESCRIPTORS +
-		sizeof (struct gelic_net_descr) * GELIC_NET_TX_DESCRIPTORS;
 	/*
-	 * we assume private data is allocated 32 bytes (or more) aligned
-	 * so that gelic_net_descr should be 32 bytes aligned.
-	 * Current alloc_etherdev() does do it because NETDEV_ALIGN
-	 * is 32.
-	 * check this assumption here.
+	 * gelic requires dma descriptor is 32 bytes aligned and
+	 * the hypervisor requires irq_status is 8 bytes aligned.
 	 */
-	BUILD_BUG_ON(NETDEV_ALIGN < 32);
-	BUILD_BUG_ON(offsetof(struct gelic_net_card, irq_status) % 8);
-	BUILD_BUG_ON(offsetof(struct gelic_net_card, descr) % 32);
+	BUILD_BUG_ON(offsetof(struct gelic_card, irq_status) % 8);
+	BUILD_BUG_ON(offsetof(struct gelic_card, descr) % 32);
+	alloc_size =
+		sizeof(struct gelic_card) +
+		sizeof(struct gelic_descr) * GELIC_NET_RX_DESCRIPTORS +
+		sizeof(struct gelic_descr) * GELIC_NET_TX_DESCRIPTORS +
+		GELIC_ALIGN - 1;
+
+	p  = kzalloc(alloc_size, GFP_KERNEL);
+	if (!p)
+		return NULL;
+	card = PTR_ALIGN(p, GELIC_ALIGN);
+	card->unalign = p;
 
-	netdev = alloc_etherdev(alloc_size);
-	if (!netdev)
+	/*
+	 * alloc netdev
+	 */
+	*netdev = alloc_etherdev(sizeof(struct gelic_port));
+	if (!netdev) {
+		kfree(card->unalign);
 		return NULL;
+	}
+	port = netdev_priv(*netdev);
+
+	/* gelic_port */
+	port->netdev = *netdev;
+	port->card = card;
+	port->type = GELIC_PORT_ETHERNET;
+
+	/* gelic_card */
+	card->netdev[GELIC_PORT_ETHERNET] = *netdev;
 
-	card = netdev_priv(netdev);
-	card->netdev = netdev;
 	INIT_WORK(&card->tx_timeout_task, gelic_net_tx_timeout_task);
 	init_waitqueue_head(&card->waitq);
 	atomic_set(&card->tx_timeout_task_counter, 0);
+	init_MUTEX(&card->updown_lock);
+	atomic_set(&card->users, 0);
 
 	return card;
 }
 
+static void gelic_card_get_vlan_info(struct gelic_card *card)
+{
+	u64 v1, v2;
+	int status;
+	unsigned int i;
+	struct {
+		int tx;
+		int rx;
+	} vlan_id_ix[2] = {
+		[GELIC_PORT_ETHERNET] = {
+			.tx = GELIC_LV1_VLAN_TX_ETHERNET,
+			.rx = GELIC_LV1_VLAN_RX_ETHERNET
+		},
+		[GELIC_PORT_WIRELESS] = {
+			.tx = GELIC_LV1_VLAN_TX_WIRELESS,
+			.rx = GELIC_LV1_VLAN_RX_WIRELESS
+		}
+	};
+
+	for (i = 0; i < ARRAY_SIZE(vlan_id_ix); i++) {
+		/* tx tag */
+		status = lv1_net_control(bus_id(card), dev_id(card),
+					 GELIC_LV1_GET_VLAN_ID,
+					 vlan_id_ix[i].tx,
+					 0, 0, &v1, &v2);
+		if (status || !v1) {
+			if (status != LV1_NO_ENTRY)
+				dev_dbg(ctodev(card),
+					"get vlan id for tx(%d) failed(%d)\n",
+					vlan_id_ix[i].tx, status);
+			card->vlan[i].tx = 0;
+			card->vlan[i].rx = 0;
+			continue;
+		}
+		card->vlan[i].tx = (u16)v1;
+
+		/* rx tag */
+		status = lv1_net_control(bus_id(card), dev_id(card),
+					 GELIC_LV1_GET_VLAN_ID,
+					 vlan_id_ix[i].rx,
+					 0, 0, &v1, &v2);
+		if (status || !v1) {
+			if (status != LV1_NO_ENTRY)
+				dev_info(ctodev(card),
+					 "get vlan id for rx(%d) failed(%d)\n",
+					 vlan_id_ix[i].rx, status);
+			card->vlan[i].tx = 0;
+			card->vlan[i].rx = 0;
+			continue;
+		}
+		card->vlan[i].rx = (u16)v1;
+
+		dev_dbg(ctodev(card), "vlan_id[%d] tx=%02x rx=%02x\n",
+			i, card->vlan[i].tx, card->vlan[i].rx);
+	}
+
+	if (card->vlan[GELIC_PORT_ETHERNET].tx) {
+		BUG_ON(!card->vlan[GELIC_PORT_WIRELESS].tx);
+		card->vlan_required = 1;
+	} else
+		card->vlan_required = 0;
+
+	/* check wirelss capable firmware */
+	if (ps3_compare_firmware_version(1, 6, 0) < 0) {
+		card->vlan[GELIC_PORT_WIRELESS].tx = 0;
+		card->vlan[GELIC_PORT_WIRELESS].rx = 0;
+	}
+
+	dev_info(ctodev(card), "internal vlan %s\n",
+		 card->vlan_required? "enabled" : "disabled");
+}
 /**
  * ps3_gelic_driver_probe - add a device to the control of this driver
  */
-static int ps3_gelic_driver_probe (struct ps3_system_bus_device *dev)
+static int ps3_gelic_driver_probe(struct ps3_system_bus_device *dev)
 {
-	struct gelic_net_card *card = gelic_net_alloc_card();
+	struct gelic_card *card;
+	struct net_device *netdev;
 	int result;
 
-	if (!card) {
-		dev_info(&dev->core, "gelic_net_alloc_card failed\n");
-		result = -ENOMEM;
-		goto fail_alloc_card;
-	}
-
-	ps3_system_bus_set_driver_data(dev, card);
-	card->dev = dev;
-
+	pr_debug("%s: called\n", __func__);
 	result = ps3_open_hv_device(dev);
 
 	if (result) {
-		dev_dbg(&dev->core, "ps3_open_hv_device failed\n");
+		dev_dbg(&dev->core, "%s:ps3_open_hv_device failed\n",
+			__func__);
 		goto fail_open;
 	}
 
 	result = ps3_dma_region_create(dev->d_region);
 
 	if (result) {
-		dev_dbg(&dev->core, "ps3_dma_region_create failed(%d)\n",
-			result);
+		dev_dbg(&dev->core, "%s:ps3_dma_region_create failed(%d)\n",
+			__func__, result);
 		BUG_ON("check region type");
 		goto fail_dma_region;
 	}
 
+	/* alloc card/netdevice */
+	card = gelic_alloc_card_net(&netdev);
+	if (!card) {
+		dev_info(&dev->core, "%s:gelic_net_alloc_card failed\n",
+			 __func__);
+		result = -ENOMEM;
+		goto fail_alloc_card;
+	}
+	ps3_system_bus_set_driver_data(dev, card);
+	card->dev = dev;
+
+	/* get internal vlan info */
+	gelic_card_get_vlan_info(card);
+
+	/* setup interrupt */
 	result = lv1_net_set_interrupt_status_indicator(bus_id(card),
 							dev_id(card),
 		ps3_mm_phys_to_lpar(__pa(&card->irq_status)),
@@ -1494,34 +1579,101 @@ static int ps3_gelic_driver_probe (struct ps3_system_bus_device *dev)
 
 	if (result) {
 		dev_dbg(&dev->core,
-			"lv1_net_set_interrupt_status_indicator failed: %s\n",
-			ps3_result(result));
+			"%s:set_interrupt_status_indicator failed: %s\n",
+			__func__, ps3_result(result));
 		result = -EIO;
 		goto fail_status_indicator;
 	}
 
-	result = gelic_net_setup_netdev(card);
+	result = ps3_sb_event_receive_port_setup(dev, PS3_BINDING_CPU_ANY,
+		&card->irq);
+
+	if (result) {
+		dev_info(ctodev(card),
+			 "%s:gelic_net_open_device failed (%d)\n",
+			 __func__, result);
+		result = -EPERM;
+		goto fail_alloc_irq;
+	}
+	result = request_irq(card->irq, gelic_card_interrupt,
+			     IRQF_DISABLED, netdev->name, card);
+
+	if (result) {
+		dev_info(ctodev(card), "%s:request_irq failed (%d)\n",
+			__func__, result);
+		goto fail_request_irq;
+	}
+
+	/* setup card structure */
+	card->irq_mask = GELIC_CARD_RXINT | GELIC_CARD_TXINT |
+		GELIC_CARD_PORT_STATUS_CHANGED;
+	card->rx_csum = GELIC_CARD_RX_CSUM_DEFAULT;
 
+
+	if (gelic_card_init_chain(card, &card->tx_chain,
+			card->descr, GELIC_NET_TX_DESCRIPTORS))
+		goto fail_alloc_tx;
+	if (gelic_card_init_chain(card, &card->rx_chain,
+				 card->descr + GELIC_NET_TX_DESCRIPTORS,
+				 GELIC_NET_RX_DESCRIPTORS))
+		goto fail_alloc_rx;
+
+	/* head of chain */
+	card->tx_top = card->tx_chain.head;
+	card->rx_top = card->rx_chain.head;
+	dev_dbg(ctodev(card), "descr rx %p, tx %p, size %#lx, num %#x\n",
+		card->rx_top, card->tx_top, sizeof(struct gelic_descr),
+		GELIC_NET_RX_DESCRIPTORS);
+	/* allocate rx skbs */
+	if (gelic_card_alloc_rx_skbs(card))
+		goto fail_alloc_skbs;
+
+	spin_lock_init(&card->tx_lock);
+	card->tx_dma_progress = 0;
+
+	/* setup net_device structure */
+	netdev->irq = card->irq;
+	SET_NETDEV_DEV(netdev, &card->dev->core);
+	gelic_ether_setup_netdev_ops(netdev, &card->napi);
+	result = gelic_net_setup_netdev(netdev, card);
 	if (result) {
-		dev_dbg(&dev->core, "%s:%d: ps3_dma_region_create failed: "
-			"(%d)\n", __func__, __LINE__, result);
+		dev_dbg(&dev->core, "%s: setup_netdev failed %d",
+			__func__, result);
 		goto fail_setup_netdev;
 	}
 
+#ifdef CONFIG_GELIC_WIRELESS
+	if (gelic_wl_driver_probe(card)) {
+		dev_dbg(&dev->core, "%s: WL init failed\n", __func__);
+		goto fail_setup_netdev;
+	}
+#endif
+	pr_debug("%s: done\n", __func__);
 	return 0;
 
 fail_setup_netdev:
+fail_alloc_skbs:
+	gelic_card_free_chain(card, card->rx_chain.head);
+fail_alloc_rx:
+	gelic_card_free_chain(card, card->tx_chain.head);
+fail_alloc_tx:
+	free_irq(card->irq, card);
+	netdev->irq = NO_IRQ;
+fail_request_irq:
+	ps3_sb_event_receive_port_destroy(dev, card->irq);
+fail_alloc_irq:
 	lv1_net_set_interrupt_status_indicator(bus_id(card),
 					       bus_id(card),
-					       0 , 0);
+					       0, 0);
 fail_status_indicator:
+	ps3_system_bus_set_driver_data(dev, NULL);
+	kfree(netdev_card(netdev)->unalign);
+	free_netdev(netdev);
+fail_alloc_card:
 	ps3_dma_region_free(dev->d_region);
 fail_dma_region:
 	ps3_close_hv_device(dev);
 fail_open:
-	ps3_system_bus_set_driver_data(dev, NULL);
-	free_netdev(card->netdev);
-fail_alloc_card:
 	return result;
 }
 
@@ -1529,9 +1681,34 @@ fail_alloc_card:
  * ps3_gelic_driver_remove - remove a device from the control of this driver
  */
 
-static int ps3_gelic_driver_remove (struct ps3_system_bus_device *dev)
+static int ps3_gelic_driver_remove(struct ps3_system_bus_device *dev)
 {
-	struct gelic_net_card *card = ps3_system_bus_get_driver_data(dev);
+	struct gelic_card *card = ps3_system_bus_get_driver_data(dev);
+	struct net_device *netdev0;
+	pr_debug("%s: called\n", __func__);
+
+#ifdef CONFIG_GELIC_WIRELESS
+	gelic_wl_driver_remove(card);
+#endif
+	/* stop interrupt */
+	gelic_card_set_irq_mask(card, 0);
+
+	/* turn off DMA, force end */
+	gelic_card_disable_rxdmac(card);
+	gelic_card_disable_txdmac(card);
+
+	/* release chains */
+	gelic_card_release_tx_chain(card, 1);
+	gelic_card_release_rx_chain(card);
+
+	gelic_card_free_chain(card, card->tx_top);
+	gelic_card_free_chain(card, card->rx_top);
+
+	netdev0 = card->netdev[GELIC_PORT_ETHERNET];
+	/* disconnect event port */
+	free_irq(card->irq, card);
+	netdev0->irq = NO_IRQ;
+	ps3_sb_event_receive_port_destroy(card->dev, card->irq);
 
 	wait_event(card->waitq,
 		   atomic_read(&card->tx_timeout_task_counter) == 0);
@@ -1539,8 +1716,9 @@ static int ps3_gelic_driver_remove (struct ps3_system_bus_device *dev)
 	lv1_net_set_interrupt_status_indicator(bus_id(card), dev_id(card),
 					       0 , 0);
 
-	unregister_netdev(card->netdev);
-	free_netdev(card->netdev);
+	unregister_netdev(netdev0);
+	kfree(netdev_card(netdev0)->unalign);
+	free_netdev(netdev0);
 
 	ps3_system_bus_set_driver_data(dev, NULL);
 
@@ -1548,6 +1726,7 @@ static int ps3_gelic_driver_remove (struct ps3_system_bus_device *dev)
 
 	ps3_close_hv_device(dev);
 
+	pr_debug("%s: done\n", __func__);
 	return 0;
 }
 
@@ -1572,8 +1751,8 @@ static void __exit ps3_gelic_driver_exit (void)
 	ps3_system_bus_driver_unregister(&ps3_gelic_driver);
 }
 
-module_init (ps3_gelic_driver_init);
-module_exit (ps3_gelic_driver_exit);
+module_init(ps3_gelic_driver_init);
+module_exit(ps3_gelic_driver_exit);
 
 MODULE_ALIAS(PS3_MODULE_ALIAS_GELIC);
 
diff --git a/drivers/net/ps3_gelic_net.h b/drivers/net/ps3_gelic_net.h
index 9685602..1d39d06 100644
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -35,198 +35,323 @@
 #define GELIC_NET_MAX_MTU               VLAN_ETH_FRAME_LEN
 #define GELIC_NET_MIN_MTU               VLAN_ETH_ZLEN
 #define GELIC_NET_RXBUF_ALIGN           128
-#define GELIC_NET_RX_CSUM_DEFAULT       1 /* hw chksum */
+#define GELIC_CARD_RX_CSUM_DEFAULT      1 /* hw chksum */
 #define GELIC_NET_WATCHDOG_TIMEOUT      5*HZ
 #define GELIC_NET_NAPI_WEIGHT           (GELIC_NET_RX_DESCRIPTORS)
 #define GELIC_NET_BROADCAST_ADDR        0xffffffffffffL
-#define GELIC_NET_VLAN_POS              (VLAN_ETH_ALEN * 2)
-#define GELIC_NET_VLAN_MAX              4
+
 #define GELIC_NET_MC_COUNT_MAX          32 /* multicast address list */
 
-enum gelic_net_int0_status {
-	GELIC_NET_GDTDCEINT  = 24,
-	GELIC_NET_GRFANMINT  = 28,
-};
+/* virtual interrupt status register bits */
+	/* INT1 */
+#define GELIC_CARD_TX_RAM_FULL_ERR           0x0000000000000001L
+#define GELIC_CARD_RX_RAM_FULL_ERR           0x0000000000000002L
+#define GELIC_CARD_TX_SHORT_FRAME_ERR        0x0000000000000004L
+#define GELIC_CARD_TX_INVALID_DESCR_ERR      0x0000000000000008L
+#define GELIC_CARD_RX_FIFO_FULL_ERR          0x0000000000002000L
+#define GELIC_CARD_RX_DESCR_CHAIN_END        0x0000000000004000L
+#define GELIC_CARD_RX_INVALID_DESCR_ERR      0x0000000000008000L
+#define GELIC_CARD_TX_RESPONCE_ERR           0x0000000000010000L
+#define GELIC_CARD_RX_RESPONCE_ERR           0x0000000000100000L
+#define GELIC_CARD_TX_PROTECTION_ERR         0x0000000000400000L
+#define GELIC_CARD_RX_PROTECTION_ERR         0x0000000004000000L
+#define GELIC_CARD_TX_TCP_UDP_CHECKSUM_ERR   0x0000000008000000L
+#define GELIC_CARD_PORT_STATUS_CHANGED       0x0000000020000000L
+#define GELIC_CARD_WLAN_EVENT_RECEIVED       0x0000000040000000L
+#define GELIC_CARD_WLAN_COMMAND_COMPLETED    0x0000000080000000L
+	/* INT 0 */
+#define GELIC_CARD_TX_FLAGGED_DESCR          0x0004000000000000L
+#define GELIC_CARD_RX_FLAGGED_DESCR          0x0040000000000000L
+#define GELIC_CARD_TX_TRANSFER_END           0x0080000000000000L
+#define GELIC_CARD_TX_DESCR_CHAIN_END        0x0100000000000000L
+#define GELIC_CARD_NUMBER_OF_RX_FRAME        0x1000000000000000L
+#define GELIC_CARD_ONE_TIME_COUNT_TIMER      0x4000000000000000L
+#define GELIC_CARD_FREE_RUN_COUNT_TIMER      0x8000000000000000L
+
+/* initial interrupt mask */
+#define GELIC_CARD_TXINT	GELIC_CARD_TX_DESCR_CHAIN_END
 
-/* GHIINT1STS bits */
-enum gelic_net_int1_status {
-	GELIC_NET_GDADCEINT = 14,
+#define GELIC_CARD_RXINT	(GELIC_CARD_RX_DESCR_CHAIN_END | \
+				 GELIC_CARD_NUMBER_OF_RX_FRAME)
+
+ /* RX descriptor data_status bits */
+enum gelic_descr_rx_status {
+	GELIC_DESCR_RXDMADU	= 0x80000000, /* destination MAC addr unknown */
+	GELIC_DESCR_RXLSTFBF	= 0x40000000, /* last frame buffer            */
+	GELIC_DESCR_RXIPCHK	= 0x20000000, /* IP checksum performed        */
+	GELIC_DESCR_RXTCPCHK	= 0x10000000, /* TCP/UDP checksup performed   */
+	GELIC_DESCR_RXWTPKT	= 0x00C00000, /*
+					       * wakeup trigger packet
+					       * 01: Magic Packet (TM)
+					       * 10: ARP packet
+					       * 11: Multicast MAC addr
+					       */
+	GELIC_DESCR_RXVLNPKT	= 0x00200000, /* VLAN packet */
+	/* bit 20..16 reserved */
+	GELIC_DESCR_RXRRECNUM	= 0x0000ff00, /* reception receipt number */
+	/* bit 7..0 reserved */
 };
 
-/* interrupt mask */
-#define GELIC_NET_TXINT                   (1L << (GELIC_NET_GDTDCEINT + 32))
+#define GELIC_DESCR_DATA_STATUS_CHK_MASK	\
+	(GELIC_DESCR_RXIPCHK | GELIC_DESCR_RXTCPCHK)
 
-#define GELIC_NET_RXINT0                  (1L << (GELIC_NET_GRFANMINT + 32))
-#define GELIC_NET_RXINT1                  (1L << GELIC_NET_GDADCEINT)
-#define GELIC_NET_RXINT                   (GELIC_NET_RXINT0 | GELIC_NET_RXINT1)
+ /* TX descriptor data_status bits */
+enum gelic_descr_tx_status {
+	GELIC_DESCR_TX_TAIL	= 0x00000001, /* gelic treated this
+					       * descriptor was end of
+					       * a tx frame
+					       */
+};
 
- /* RX descriptor data_status bits */
-#define GELIC_NET_RXDMADU	0x80000000 /* destination MAC addr unknown */
-#define GELIC_NET_RXLSTFBF	0x40000000 /* last frame buffer            */
-#define GELIC_NET_RXIPCHK	0x20000000 /* IP checksum performed        */
-#define GELIC_NET_RXTCPCHK	0x10000000 /* TCP/UDP checksup performed   */
-#define GELIC_NET_RXIPSPKT	0x08000000 /* IPsec packet   */
-#define GELIC_NET_RXIPSAHPRT	0x04000000 /* IPsec AH protocol performed */
-#define GELIC_NET_RXIPSESPPRT	0x02000000 /* IPsec ESP protocol performed */
-#define GELIC_NET_RXSESPAH	0x01000000 /*
-					    * IPsec ESP protocol auth
-					    * performed
-					    */
-
-#define GELIC_NET_RXWTPKT	0x00C00000 /*
-					    * wakeup trigger packet
-					    * 01: Magic Packet (TM)
-					    * 10: ARP packet
-					    * 11: Multicast MAC addr
-					    */
-#define GELIC_NET_RXVLNPKT	0x00200000 /* VLAN packet */
-/* bit 20..16 reserved */
-#define GELIC_NET_RXRRECNUM	0x0000ff00 /* reception receipt number */
-#define GELIC_NET_RXRRECNUM_SHIFT	8
-/* bit 7..0 reserved */
-
-#define GELIC_NET_TXDESC_TAIL		0
-#define GELIC_NET_DATA_STATUS_CHK_MASK	(GELIC_NET_RXIPCHK | GELIC_NET_RXTCPCHK)
-
-/* RX descriptor data_error bits */
-/* bit 31 reserved */
-#define GELIC_NET_RXALNERR	0x40000000 /* alignement error 10/100M */
-#define GELIC_NET_RXOVERERR	0x20000000 /* oversize error */
-#define GELIC_NET_RXRNTERR	0x10000000 /* Runt error */
-#define GELIC_NET_RXIPCHKERR	0x08000000 /* IP checksum  error */
-#define GELIC_NET_RXTCPCHKERR	0x04000000 /* TCP/UDP checksum  error */
-#define GELIC_NET_RXUMCHSP	0x02000000 /* unmatched sp on sp */
-#define GELIC_NET_RXUMCHSPI	0x01000000 /* unmatched SPI on SAD */
-#define GELIC_NET_RXUMCHSAD	0x00800000 /* unmatched SAD */
-#define GELIC_NET_RXIPSAHERR	0x00400000 /* auth error on AH protocol
-					    * processing */
-#define GELIC_NET_RXIPSESPAHERR	0x00200000 /* auth error on ESP protocol
-					    * processing */
-#define GELIC_NET_RXDRPPKT	0x00100000 /* drop packet */
-#define GELIC_NET_RXIPFMTERR	0x00080000 /* IP packet format error */
-/* bit 18 reserved */
-#define GELIC_NET_RXDATAERR	0x00020000 /* IP packet format error */
-#define GELIC_NET_RXCALERR	0x00010000 /* cariier extension length
-					    * error */
-#define GELIC_NET_RXCREXERR	0x00008000 /* carrier extention error */
-#define GELIC_NET_RXMLTCST	0x00004000 /* multicast address frame */
-/* bit 13..0 reserved */
-#define GELIC_NET_DATA_ERROR_CHK_MASK		\
-	(GELIC_NET_RXIPCHKERR | GELIC_NET_RXTCPCHKERR)
+/* RX descriptor data error bits */
+enum gelic_descr_rx_error {
+	/* bit 31 reserved */
+	GELIC_DESCR_RXALNERR	= 0x40000000, /* alignement error 10/100M */
+	GELIC_DESCR_RXOVERERR	= 0x20000000, /* oversize error */
+	GELIC_DESCR_RXRNTERR	= 0x10000000, /* Runt error */
+	GELIC_DESCR_RXIPCHKERR	= 0x08000000, /* IP checksum  error */
+	GELIC_DESCR_RXTCPCHKERR	= 0x04000000, /* TCP/UDP checksum  error */
+	GELIC_DESCR_RXDRPPKT	= 0x00100000, /* drop packet */
+	GELIC_DESCR_RXIPFMTERR	= 0x00080000, /* IP packet format error */
+	/* bit 18 reserved */
+	GELIC_DESCR_RXDATAERR	= 0x00020000, /* IP packet format error */
+	GELIC_DESCR_RXCALERR	= 0x00010000, /* cariier extension length
+					      * error */
+	GELIC_DESCR_RXCREXERR	= 0x00008000, /* carrier extention error */
+	GELIC_DESCR_RXMLTCST	= 0x00004000, /* multicast address frame */
+	/* bit 13..0 reserved */
+};
+#define GELIC_DESCR_DATA_ERROR_CHK_MASK		\
+	(GELIC_DESCR_RXIPCHKERR | GELIC_DESCR_RXTCPCHKERR)
 
+/* DMA command and status (RX and TX)*/
+enum gelic_descr_dma_status {
+	GELIC_DESCR_DMA_COMPLETE            = 0x00000000, /* used in tx */
+	GELIC_DESCR_DMA_BUFFER_FULL         = 0x00000000, /* used in rx */
+	GELIC_DESCR_DMA_RESPONSE_ERROR      = 0x10000000, /* used in rx, tx */
+	GELIC_DESCR_DMA_PROTECTION_ERROR    = 0x20000000, /* used in rx, tx */
+	GELIC_DESCR_DMA_FRAME_END           = 0x40000000, /* used in rx */
+	GELIC_DESCR_DMA_FORCE_END           = 0x50000000, /* used in rx, tx */
+	GELIC_DESCR_DMA_CARDOWNED           = 0xa0000000, /* used in rx, tx */
+	GELIC_DESCR_DMA_NOT_IN_USE          = 0xb0000000, /* any other value */
+};
+
+#define GELIC_DESCR_DMA_STAT_MASK	(0xf0000000)
 
 /* tx descriptor command and status */
-#define GELIC_NET_DMAC_CMDSTAT_NOCS       0xa0080000 /* middle of frame */
-#define GELIC_NET_DMAC_CMDSTAT_TCPCS      0xa00a0000
-#define GELIC_NET_DMAC_CMDSTAT_UDPCS      0xa00b0000
-#define GELIC_NET_DMAC_CMDSTAT_END_FRAME  0x00040000 /* end of frame */
-
-#define GELIC_NET_DMAC_CMDSTAT_RXDCEIS	  0x00000002 /* descriptor chain end
-						      * interrupt status */
-
-#define GELIC_NET_DMAC_CMDSTAT_CHAIN_END  0x00000002 /* RXDCEIS:DMA stopped */
-#define GELIC_NET_DESCR_IND_PROC_SHIFT    28
-#define GELIC_NET_DESCR_IND_PROC_MASKO    0x0fffffff
-
-
-enum gelic_net_descr_status {
-	GELIC_NET_DESCR_COMPLETE            = 0x00, /* used in tx */
-	GELIC_NET_DESCR_BUFFER_FULL         = 0x00, /* used in rx */
-	GELIC_NET_DESCR_RESPONSE_ERROR      = 0x01, /* used in rx and tx */
-	GELIC_NET_DESCR_PROTECTION_ERROR    = 0x02, /* used in rx and tx */
-	GELIC_NET_DESCR_FRAME_END           = 0x04, /* used in rx */
-	GELIC_NET_DESCR_FORCE_END           = 0x05, /* used in rx and tx */
-	GELIC_NET_DESCR_CARDOWNED           = 0x0a, /* used in rx and tx */
-	GELIC_NET_DESCR_NOT_IN_USE          = 0x0b  /* any other value */
+enum gelic_descr_tx_dma_status {
+	/* [19] */
+	GELIC_DESCR_TX_DMA_IKE		= 0x00080000, /* IPSEC off */
+	/* [18] */
+	GELIC_DESCR_TX_DMA_FRAME_TAIL	= 0x00040000, /* last descriptor of
+						       * the packet
+						       */
+	/* [17..16] */
+	GELIC_DESCR_TX_DMA_TCP_CHKSUM	= 0x00020000, /* TCP packet */
+	GELIC_DESCR_TX_DMA_UDP_CHKSUM	= 0x00030000, /* UDP packet */
+	GELIC_DESCR_TX_DMA_NO_CHKSUM	= 0x00000000, /* no checksum */
+
+	/* [1] */
+	GELIC_DESCR_TX_DMA_CHAIN_END	= 0x00000002, /* DMA terminated
+						       * due to chain end
+						       */
 };
+
+#define GELIC_DESCR_DMA_CMD_NO_CHKSUM	\
+	(GELIC_DESCR_DMA_CARDOWNED | GELIC_DESCR_TX_DMA_IKE | \
+	GELIC_DESCR_TX_DMA_NO_CHKSUM)
+
+#define GELIC_DESCR_DMA_CMD_TCP_CHKSUM	\
+	(GELIC_DESCR_DMA_CARDOWNED | GELIC_DESCR_TX_DMA_IKE | \
+	GELIC_DESCR_TX_DMA_TCP_CHKSUM)
+
+#define GELIC_DESCR_DMA_CMD_UDP_CHKSUM	\
+	(GELIC_DESCR_DMA_CARDOWNED | GELIC_DESCR_TX_DMA_IKE | \
+	GELIC_DESCR_TX_DMA_UDP_CHKSUM)
+
+enum gelic_descr_rx_dma_status {
+	/* [ 1 ] */
+	GELIC_DESCR_RX_DMA_CHAIN_END	= 0x00000002, /* DMA terminated
+						       * due to chain end
+						       */
+};
+
 /* for lv1_net_control */
-#define GELIC_NET_GET_MAC_ADDRESS               0x0000000000000001
-#define GELIC_NET_GET_ETH_PORT_STATUS           0x0000000000000002
-#define GELIC_NET_SET_NEGOTIATION_MODE          0x0000000000000003
-#define GELIC_NET_GET_VLAN_ID                   0x0000000000000004
-
-#define GELIC_NET_LINK_UP                       0x0000000000000001
-#define GELIC_NET_FULL_DUPLEX                   0x0000000000000002
-#define GELIC_NET_AUTO_NEG                      0x0000000000000004
-#define GELIC_NET_SPEED_10                      0x0000000000000010
-#define GELIC_NET_SPEED_100                     0x0000000000000020
-#define GELIC_NET_SPEED_1000                    0x0000000000000040
-
-#define GELIC_NET_VLAN_ALL                      0x0000000000000001
-#define GELIC_NET_VLAN_WIRED                    0x0000000000000002
-#define GELIC_NET_VLAN_WIRELESS                 0x0000000000000003
-#define GELIC_NET_VLAN_PSP                      0x0000000000000004
-#define GELIC_NET_VLAN_PORT0                    0x0000000000000010
-#define GELIC_NET_VLAN_PORT1                    0x0000000000000011
-#define GELIC_NET_VLAN_PORT2                    0x0000000000000012
-#define GELIC_NET_VLAN_DAEMON_CLIENT_BSS        0x0000000000000013
-#define GELIC_NET_VLAN_LIBERO_CLIENT_BSS        0x0000000000000014
-#define GELIC_NET_VLAN_NO_ENTRY                 -6
-
-#define GELIC_NET_PORT                          2 /* for port status */
+enum gelic_lv1_net_control_code {
+	GELIC_LV1_GET_MAC_ADDRESS	= 1,
+	GELIC_LV1_GET_ETH_PORT_STATUS	= 2,
+	GELIC_LV1_SET_NEGOTIATION_MODE	= 3,
+	GELIC_LV1_GET_VLAN_ID		= 4,
+	GELIC_LV1_GET_CHANNEL           = 6,
+	GELIC_LV1_POST_WLAN_CMD		= 9,
+	GELIC_LV1_GET_WLAN_CMD_RESULT	= 10,
+	GELIC_LV1_GET_WLAN_EVENT	= 11
+};
+
+/* status returened from GET_ETH_PORT_STATUS */
+enum gelic_lv1_ether_port_status {
+	GELIC_LV1_ETHER_LINK_UP		= 0x0000000000000001L,
+	GELIC_LV1_ETHER_FULL_DUPLEX	= 0x0000000000000002L,
+	GELIC_LV1_ETHER_AUTO_NEG	= 0x0000000000000004L,
+
+	GELIC_LV1_ETHER_SPEED_10	= 0x0000000000000010L,
+	GELIC_LV1_ETHER_SPEED_100	= 0x0000000000000020L,
+	GELIC_LV1_ETHER_SPEED_1000	= 0x0000000000000040L,
+	GELIC_LV1_ETHER_SPEED_MASK	= 0x0000000000000070L
+};
+
+enum gelic_lv1_vlan_index {
+	/* for outgoing packets */
+	GELIC_LV1_VLAN_TX_ETHERNET	= 0x0000000000000002L,
+	GELIC_LV1_VLAN_TX_WIRELESS	= 0x0000000000000003L,
+	/* for incoming packets */
+	GELIC_LV1_VLAN_RX_ETHERNET	= 0x0000000000000012L,
+	GELIC_LV1_VLAN_RX_WIRELESS	= 0x0000000000000013L
+};
 
 /* size of hardware part of gelic descriptor */
-#define GELIC_NET_DESCR_SIZE	(32)
-struct gelic_net_descr {
+#define GELIC_DESCR_SIZE	(32)
+
+enum gelic_port_type {
+	GELIC_PORT_ETHERNET = 0,
+	GELIC_PORT_WIRELESS = 1,
+	GELIC_PORT_MAX
+};
+
+struct gelic_descr {
 	/* as defined by the hardware */
-	u32 buf_addr;
-	u32 buf_size;
-	u32 next_descr_addr;
-	u32 dmac_cmd_status;
-	u32 result_size;
-	u32 valid_size;	/* all zeroes for tx */
-	u32 data_status;
-	u32 data_error;	/* all zeroes for tx */
+	__be32 buf_addr;
+	__be32 buf_size;
+	__be32 next_descr_addr;
+	__be32 dmac_cmd_status;
+	__be32 result_size;
+	__be32 valid_size;	/* all zeroes for tx */
+	__be32 data_status;
+	__be32 data_error;	/* all zeroes for tx */
 
 	/* used in the driver */
 	struct sk_buff *skb;
 	dma_addr_t bus_addr;
-	struct gelic_net_descr *next;
-	struct gelic_net_descr *prev;
-	struct vlan_ethhdr vlan;
+	struct gelic_descr *next;
+	struct gelic_descr *prev;
 } __attribute__((aligned(32)));
 
-struct gelic_net_descr_chain {
+struct gelic_descr_chain {
 	/* we walk from tail to head */
-	struct gelic_net_descr *head;
-	struct gelic_net_descr *tail;
+	struct gelic_descr *head;
+	struct gelic_descr *tail;
 };
 
-struct gelic_net_card {
-	struct net_device *netdev;
+struct gelic_vlan_id {
+	u16 tx;
+	u16 rx;
+};
+
+struct gelic_card {
 	struct napi_struct napi;
+	struct net_device *netdev[GELIC_PORT_MAX];
 	/*
 	 * hypervisor requires irq_status should be
 	 * 8 bytes aligned, but u64 member is
 	 * always disposed in that manner
 	 */
 	u64 irq_status;
-	u64 ghiintmask;
+	u64 irq_mask;
 
 	struct ps3_system_bus_device *dev;
-	u32 vlan_id[GELIC_NET_VLAN_MAX];
-	int vlan_index;
+	struct gelic_vlan_id vlan[GELIC_PORT_MAX];
+	int vlan_required;
 
-	struct gelic_net_descr_chain tx_chain;
-	struct gelic_net_descr_chain rx_chain;
+	struct gelic_descr_chain tx_chain;
+	struct gelic_descr_chain rx_chain;
 	int rx_dma_restart_required;
-	/* gurad dmac descriptor chain*/
-	spinlock_t chain_lock;
-
 	int rx_csum;
-	/* guard tx_dma_progress */
-	spinlock_t tx_dma_lock;
+	/*
+	 * tx_lock guards tx descriptor list and
+	 * tx_dma_progress.
+	 */
+	spinlock_t tx_lock;
 	int tx_dma_progress;
 
 	struct work_struct tx_timeout_task;
 	atomic_t tx_timeout_task_counter;
 	wait_queue_head_t waitq;
 
-	struct gelic_net_descr *tx_top, *rx_top;
-	struct gelic_net_descr descr[0];
+	/* only first user should up the card */
+	struct semaphore updown_lock;
+	atomic_t users;
+
+	u64 ether_port_status;
+	/* original address returned by kzalloc */
+	void *unalign;
+
+	/*
+	 * each netdevice has copy of irq
+	 */
+	unsigned int irq;
+	struct gelic_descr *tx_top, *rx_top;
+	struct gelic_descr descr[0]; /* must be the last */
+};
+
+struct gelic_port {
+	struct gelic_card *card;
+	struct net_device *netdev;
+	enum gelic_port_type type;
+	long priv[0]; /* long for alignment */
 };
 
+static inline struct gelic_card *port_to_card(struct gelic_port *p)
+{
+	return p->card;
+}
+static inline struct net_device *port_to_netdev(struct gelic_port *p)
+{
+	return p->netdev;
+}
+static inline struct gelic_card *netdev_card(struct net_device *d)
+{
+	return ((struct gelic_port *)netdev_priv(d))->card;
+}
+static inline struct gelic_port *netdev_port(struct net_device *d)
+{
+	return (struct gelic_port *)netdev_priv(d);
+}
+static inline struct device *ctodev(struct gelic_card *card)
+{
+	return &card->dev->core;
+}
+static inline u64 bus_id(struct gelic_card *card)
+{
+	return card->dev->bus_id;
+}
+static inline u64 dev_id(struct gelic_card *card)
+{
+	return card->dev->dev_id;
+}
+
+static inline void *port_priv(struct gelic_port *port)
+{
+	return port->priv;
+}
+
+extern int gelic_card_set_irq_mask(struct gelic_card *card, u64 mask);
+/* shared netdev ops */
+extern void gelic_card_up(struct gelic_card *card);
+extern void gelic_card_down(struct gelic_card *card);
+extern int gelic_net_open(struct net_device *netdev);
+extern int gelic_net_stop(struct net_device *netdev);
+extern int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev);
+extern void gelic_net_set_multi(struct net_device *netdev);
+extern void gelic_net_tx_timeout(struct net_device *netdev);
+extern int gelic_net_change_mtu(struct net_device *netdev, int new_mtu);
+extern int gelic_net_setup_netdev(struct net_device *netdev,
+				  struct gelic_card *card);
 
-extern unsigned long p_to_lp(long pa);
+/* shared ethtool ops */
+extern void gelic_net_get_drvinfo(struct net_device *netdev,
+				  struct ethtool_drvinfo *info);
+extern u32 gelic_net_get_rx_csum(struct net_device *netdev);
+extern int gelic_net_set_rx_csum(struct net_device *netdev, u32 data);
+extern void gelic_net_poll_controller(struct net_device *netdev);
 
 #endif /* _GELIC_NET_H */
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
new file mode 100644
index 0000000..750d2a9
--- /dev/null
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -0,0 +1,2753 @@
+/*
+ *  PS3 gelic network driver.
+ *
+ * Copyright (C) 2007 Sony Computer Entertainment Inc.
+ * Copyright 2007 Sony Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#undef DEBUG
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/wireless.h>
+#include <linux/ctype.h>
+#include <linux/string.h>
+#include <net/iw_handler.h>
+#include <net/ieee80211.h>
+
+#include <linux/dma-mapping.h>
+#include <net/checksum.h>
+#include <asm/firmware.h>
+#include <asm/ps3.h>
+#include <asm/lv1call.h>
+
+#include "ps3_gelic_net.h"
+#include "ps3_gelic_wireless.h"
+
+
+static int gelic_wl_start_scan(struct gelic_wl_info *wl, int always_scan);
+static int gelic_wl_try_associate(struct net_device *netdev);
+
+/*
+ * tables
+ */
+
+/* 802.11b/g channel to freq in MHz */
+static const int channel_freq[] = {
+	2412, 2417, 2422, 2427, 2432,
+	2437, 2442, 2447, 2452, 2457,
+	2462, 2467, 2472, 2484
+};
+#define NUM_CHANNELS ARRAY_SIZE(channel_freq)
+
+/* in bps */
+static const int bitrate_list[] = {
+	  1000000,
+	  2000000,
+	  5500000,
+	 11000000,
+	  6000000,
+	  9000000,
+	 12000000,
+	 18000000,
+	 24000000,
+	 36000000,
+	 48000000,
+	 54000000
+};
+#define NUM_BITRATES ARRAY_SIZE(bitrate_list)
+
+/*
+ * wpa2 support requires the hypervisor version 2.0 or later
+ */
+static inline int wpa2_capable(void)
+{
+	return (0 <= ps3_compare_firmware_version(2, 0, 0));
+}
+
+static inline int precise_ie(void)
+{
+	return 0; /* FIXME */
+}
+/*
+ * post_eurus_cmd helpers
+ */
+struct eurus_cmd_arg_info {
+	int pre_arg; /* command requres arg1, arg2 at POST COMMAND */
+	int post_arg; /* command requires arg1, arg2 at GET_RESULT */
+};
+
+static const struct eurus_cmd_arg_info cmd_info[GELIC_EURUS_CMD_MAX_INDEX] = {
+	[GELIC_EURUS_CMD_SET_COMMON_CFG] = { .pre_arg = 1},
+	[GELIC_EURUS_CMD_SET_WEP_CFG]    = { .pre_arg = 1},
+	[GELIC_EURUS_CMD_SET_WPA_CFG]    = { .pre_arg = 1},
+	[GELIC_EURUS_CMD_GET_COMMON_CFG] = { .post_arg = 1},
+	[GELIC_EURUS_CMD_GET_WEP_CFG]    = { .post_arg = 1},
+	[GELIC_EURUS_CMD_GET_WPA_CFG]    = { .post_arg = 1},
+	[GELIC_EURUS_CMD_GET_RSSI_CFG]   = { .post_arg = 1},
+	[GELIC_EURUS_CMD_GET_SCAN]       = { .post_arg = 1},
+};
+
+#ifdef DEBUG
+static const char *cmdstr(enum gelic_eurus_command ix)
+{
+	switch (ix) {
+	case GELIC_EURUS_CMD_ASSOC:
+		return "ASSOC";
+	case GELIC_EURUS_CMD_DISASSOC:
+		return "DISASSOC";
+	case GELIC_EURUS_CMD_START_SCAN:
+		return "SCAN";
+	case GELIC_EURUS_CMD_GET_SCAN:
+		return "GET SCAN";
+	case GELIC_EURUS_CMD_SET_COMMON_CFG:
+		return "SET_COMMON_CFG";
+	case GELIC_EURUS_CMD_GET_COMMON_CFG:
+		return "GET_COMMON_CFG";
+	case GELIC_EURUS_CMD_SET_WEP_CFG:
+		return "SET_WEP_CFG";
+	case GELIC_EURUS_CMD_GET_WEP_CFG:
+		return "GET_WEP_CFG";
+	case GELIC_EURUS_CMD_SET_WPA_CFG:
+		return "SET_WPA_CFG";
+	case GELIC_EURUS_CMD_GET_WPA_CFG:
+		return "GET_WPA_CFG";
+	case GELIC_EURUS_CMD_GET_RSSI_CFG:
+		return "GET_RSSI";
+	default:
+		break;
+	}
+	return "";
+};
+#else
+static inline const char *cmdstr(enum gelic_eurus_command ix)
+{
+	return "";
+}
+#endif
+
+/* synchronously do eurus commands */
+static void gelic_eurus_sync_cmd_worker(struct work_struct *work)
+{
+	struct gelic_eurus_cmd *cmd;
+	struct gelic_card *card;
+	struct gelic_wl_info *wl;
+
+	u64 arg1, arg2;
+
+	pr_debug("%s: <-\n", __func__);
+	cmd = container_of(work, struct gelic_eurus_cmd, work);
+	BUG_ON(cmd_info[cmd->cmd].pre_arg &&
+	       cmd_info[cmd->cmd].post_arg);
+	wl = cmd->wl;
+	card = port_to_card(wl_port(wl));
+
+	if (cmd_info[cmd->cmd].pre_arg) {
+		arg1 = ps3_mm_phys_to_lpar(__pa(cmd->buffer));
+		arg2 = cmd->buf_size;
+	} else {
+		arg1 = 0;
+		arg2 = 0;
+	}
+	init_completion(&wl->cmd_done_intr);
+	pr_debug("%s: cmd='%s' start\n", __func__, cmdstr(cmd->cmd));
+	cmd->status = lv1_net_control(bus_id(card), dev_id(card),
+				      GELIC_LV1_POST_WLAN_CMD,
+				      cmd->cmd, arg1, arg2,
+				      &cmd->tag, &cmd->size);
+	if (cmd->status) {
+		complete(&cmd->done);
+		pr_info("%s: cmd issue failed\n", __func__);
+		return;
+	}
+
+	wait_for_completion(&wl->cmd_done_intr);
+
+	if (cmd_info[cmd->cmd].post_arg) {
+		arg1 = ps3_mm_phys_to_lpar(__pa(cmd->buffer));
+		arg2 = cmd->buf_size;
+	} else {
+		arg1 = 0;
+		arg2 = 0;
+	}
+
+	cmd->status = lv1_net_control(bus_id(card), dev_id(card),
+				      GELIC_LV1_GET_WLAN_CMD_RESULT,
+				      cmd->tag, arg1, arg2,
+				      &cmd->cmd_status, &cmd->size);
+#ifdef DEBUG
+	if (cmd->status || cmd->cmd_status) {
+	pr_debug("%s: cmd done tag=%#lx arg1=%#lx, arg2=%#lx\n", __func__,
+		 cmd->tag, arg1, arg2);
+	pr_debug("%s: cmd done status=%#x cmd_status=%#lx size=%#lx\n",
+		 __func__, cmd->status, cmd->cmd_status, cmd->size);
+	}
+#endif
+	complete(&cmd->done);
+	pr_debug("%s: cmd='%s' done\n", __func__, cmdstr(cmd->cmd));
+}
+
+static struct gelic_eurus_cmd *gelic_eurus_sync_cmd(struct gelic_wl_info *wl,
+						    unsigned int eurus_cmd,
+						    void *buffer,
+						    unsigned int buf_size)
+{
+	struct gelic_eurus_cmd *cmd;
+
+	/* allocate cmd */
+	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
+	if (!cmd)
+		return NULL;
+
+	/* initialize members */
+	cmd->cmd = eurus_cmd;
+	cmd->buffer = buffer;
+	cmd->buf_size = buf_size;
+	cmd->wl = wl;
+	INIT_WORK(&cmd->work, gelic_eurus_sync_cmd_worker);
+	init_completion(&cmd->done);
+	queue_work(wl->eurus_cmd_queue, &cmd->work);
+
+	/* wait for command completion */
+	wait_for_completion(&cmd->done);
+
+	return cmd;
+}
+
+static u32 gelic_wl_get_link(struct net_device *netdev)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_port(netdev));
+	u32 ret;
+
+	pr_debug("%s: <-\n", __func__);
+	down(&wl->assoc_stat_lock);
+	if (wl->assoc_stat == GELIC_WL_ASSOC_STAT_ASSOCIATED)
+		ret = 1;
+	else
+		ret = 0;
+	up(&wl->assoc_stat_lock);
+	pr_debug("%s: ->\n", __func__);
+	return ret;
+}
+
+static void gelic_wl_send_iwap_event(struct gelic_wl_info *wl, u8 *bssid)
+{
+	union iwreq_data data;
+
+	memset(&data, 0, sizeof(data));
+	if (bssid)
+		memcpy(data.ap_addr.sa_data, bssid, ETH_ALEN);
+	data.ap_addr.sa_family = ARPHRD_ETHER;
+	wireless_send_event(port_to_netdev(wl_port(wl)), SIOCGIWAP,
+			    &data, NULL);
+}
+
+/*
+ * wireless extension handlers and helpers
+ */
+
+/* SIOGIWNAME */
+static int gelic_wl_get_name(struct net_device *dev,
+			     struct iw_request_info *info,
+			     union iwreq_data *iwreq, char *extra)
+{
+	strcpy(iwreq->name, "IEEE 802.11bg");
+	return 0;
+}
+
+static void gelic_wl_get_ch_info(struct gelic_wl_info *wl)
+{
+	struct gelic_card *card = port_to_card(wl_port(wl));
+	u64 ch_info_raw, tmp;
+	int status;
+
+	if (!test_and_set_bit(GELIC_WL_STAT_CH_INFO, &wl->stat)) {
+		status = lv1_net_control(bus_id(card), dev_id(card),
+					 GELIC_LV1_GET_CHANNEL, 0, 0, 0,
+					 &ch_info_raw,
+					 &tmp);
+		/* some fw versions may return error */
+		if (status) {
+			if (status != LV1_NO_ENTRY)
+				pr_info("%s: available ch unknown\n", __func__);
+			wl->ch_info = 0x07ff;/* 11 ch */
+		} else
+			/* 16 bits of MSB has available channels */
+			wl->ch_info = ch_info_raw >> 48;
+	}
+	return;
+}
+
+/* SIOGIWRANGE */
+static int gelic_wl_get_range(struct net_device *netdev,
+			      struct iw_request_info *info,
+			      union iwreq_data *iwreq, char *extra)
+{
+	struct iw_point *point = &iwreq->data;
+	struct iw_range *range = (struct iw_range *)extra;
+	struct gelic_wl_info *wl = port_wl(netdev_port(netdev));
+	unsigned int i, chs;
+
+	pr_debug("%s: <-\n", __func__);
+	point->length = sizeof(struct iw_range);
+	memset(range, 0, sizeof(struct iw_range));
+
+	range->we_version_compiled = WIRELESS_EXT;
+	range->we_version_source = 22;
+
+	/* available channels and frequencies */
+	gelic_wl_get_ch_info(wl);
+
+	for (i = 0, chs = 0;
+	     i < NUM_CHANNELS && chs < IW_MAX_FREQUENCIES; i++)
+		if (wl->ch_info & (1 << i)) {
+			range->freq[chs].i = i + 1;
+			range->freq[chs].m = channel_freq[i];
+			range->freq[chs].e = 6;
+			chs++;
+		}
+	range->num_frequency = chs;
+	range->old_num_frequency = chs;
+	range->num_channels = chs;
+	range->old_num_channels = chs;
+
+	/* bitrates */
+	for (i = 0; i < NUM_BITRATES; i++)
+		range->bitrate[i] = bitrate_list[i];
+	range->num_bitrates = i;
+
+	/* signal levels */
+	range->max_qual.qual = 100; /* relative value */
+	range->max_qual.level = 100;
+	range->avg_qual.qual = 50;
+	range->avg_qual.level = 50;
+	range->sensitivity = 0;
+
+	/* Event capability */
+	IW_EVENT_CAPA_SET_KERNEL(range->event_capa);
+	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWAP);
+	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWSCAN);
+
+	/* encryption capability */
+	range->enc_capa = IW_ENC_CAPA_WPA |
+		IW_ENC_CAPA_CIPHER_TKIP | IW_ENC_CAPA_CIPHER_CCMP;
+	if (wpa2_capable())
+		range->enc_capa |= IW_ENC_CAPA_WPA2;
+	range->encoding_size[0] = 5;	/* 40bit WEP */
+	range->encoding_size[1] = 13;	/* 104bit WEP */
+	range->encoding_size[2] = 32;	/* WPA-PSK */
+	range->num_encoding_sizes = 3;
+	range->max_encoding_tokens = GELIC_WEP_KEYS;
+
+	pr_debug("%s: ->\n", __func__);
+	return 0;
+
+}
+
+/* SIOC{G,S}IWSCAN */
+static int gelic_wl_set_scan(struct net_device *netdev,
+			   struct iw_request_info *info,
+			   union iwreq_data *wrqu, char *extra)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+
+	return gelic_wl_start_scan(wl, 1);
+}
+
+#define OUI_LEN 3
+static const u8 rsn_oui[OUI_LEN] = { 0x00, 0x0f, 0xac };
+static const u8 wpa_oui[OUI_LEN] = { 0x00, 0x50, 0xf2 };
+
+/*
+ * synthesize WPA/RSN IE data
+ * See WiFi WPA specification and IEEE 802.11-2007 7.3.2.25
+ * for the format
+ */
+static size_t gelic_wl_synthesize_ie(u8 *buf,
+				     struct gelic_eurus_scan_info *scan)
+{
+
+	const u8 *oui_header;
+	u8 *start = buf;
+	int rsn;
+	int ccmp;
+
+	pr_debug("%s: <- sec=%16x\n", __func__, scan->security);
+	switch (be16_to_cpu(scan->security) & GELIC_EURUS_SCAN_SEC_MASK) {
+	case GELIC_EURUS_SCAN_SEC_WPA:
+		rsn = 0;
+		break;
+	case GELIC_EURUS_SCAN_SEC_WPA2:
+		rsn = 1;
+		break;
+	default:
+		/* WEP or none.  No IE returned */
+		return 0;
+	}
+
+	switch (be16_to_cpu(scan->security) & GELIC_EURUS_SCAN_SEC_WPA_MASK) {
+	case GELIC_EURUS_SCAN_SEC_WPA_TKIP:
+		ccmp = 0;
+		break;
+	case GELIC_EURUS_SCAN_SEC_WPA_AES:
+		ccmp = 1;
+		break;
+	default:
+		if (rsn) {
+			ccmp = 1;
+			pr_info("%s: no cipher info. defaulted to CCMP\n",
+				__func__);
+		} else {
+			ccmp = 0;
+			pr_info("%s: no cipher info. defaulted to TKIP\n",
+				__func__);
+		}
+	}
+
+	if (rsn)
+		oui_header = rsn_oui;
+	else
+		oui_header = wpa_oui;
+
+	/* element id */
+	if (rsn)
+		*buf++ = MFIE_TYPE_RSN;
+	else
+		*buf++ = MFIE_TYPE_GENERIC;
+
+	/* length filed; set later */
+	buf++;
+
+	/* wpa special header */
+	if (!rsn) {
+		memcpy(buf, wpa_oui, OUI_LEN);
+		buf += OUI_LEN;
+		*buf++ = 0x01;
+	}
+
+	/* version */
+	*buf++ = 0x01; /* version 1.0 */
+	*buf++ = 0x00;
+
+	/* group cipher */
+	memcpy(buf, oui_header, OUI_LEN);
+	buf += OUI_LEN;
+
+	if (ccmp)
+		*buf++ = 0x04; /* CCMP */
+	else
+		*buf++ = 0x02; /* TKIP */
+
+	/* pairwise key count always 1 */
+	*buf++ = 0x01;
+	*buf++ = 0x00;
+
+	/* pairwise key suit */
+	memcpy(buf, oui_header, OUI_LEN);
+	buf += OUI_LEN;
+	if (ccmp)
+		*buf++ = 0x04; /* CCMP */
+	else
+		*buf++ = 0x02; /* TKIP */
+
+	/* AKM count is 1 */
+	*buf++ = 0x01;
+	*buf++ = 0x00;
+
+	/* AKM suite is assumed as PSK*/
+	memcpy(buf, oui_header, OUI_LEN);
+	buf += OUI_LEN;
+	*buf++ = 0x02; /* PSK */
+
+	/* RSN capabilities is 0 */
+	*buf++ = 0x00;
+	*buf++ = 0x00;
+
+	/* set length field */
+	start[1] = (buf - start - 2);
+
+	pr_debug("%s: ->\n", __func__);
+	return (buf - start);
+}
+
+struct ie_item {
+	u8 *data;
+	u8 len;
+};
+
+struct ie_info {
+	struct ie_item wpa;
+	struct ie_item rsn;
+};
+
+static void gelic_wl_parse_ie(u8 *data, size_t len,
+			      struct ie_info *ie_info)
+{
+	size_t data_left = len;
+	u8 *pos = data;
+	u8 item_len;
+	u8 item_id;
+
+	pr_debug("%s: data=%p len=%ld \n", __func__,
+		 data, len);
+	memset(ie_info, 0, sizeof(struct ie_info));
+
+	while (0 < data_left) {
+		item_id = *pos++;
+		item_len = *pos++;
+
+		switch (item_id) {
+		case MFIE_TYPE_GENERIC:
+			if (!memcmp(pos, wpa_oui, OUI_LEN) &&
+			    pos[OUI_LEN] == 0x01) {
+				ie_info->wpa.data = pos - 2;
+				ie_info->wpa.len = item_len + 2;
+			}
+			break;
+		case MFIE_TYPE_RSN:
+			ie_info->rsn.data = pos - 2;
+			/* length includes the header */
+			ie_info->rsn.len = item_len + 2;
+			break;
+		default:
+			pr_debug("%s: ignore %#x,%d\n", __func__,
+				 item_id, item_len);
+			break;
+		}
+		pos += item_len;
+		data_left -= item_len + 2;
+	}
+	pr_debug("%s: wpa=%p,%d wpa2=%p,%d\n", __func__,
+		 ie_info->wpa.data, ie_info->wpa.len,
+		 ie_info->rsn.data, ie_info->rsn.len);
+}
+
+
+/*
+ * translate the scan informations from hypervisor to a
+ * independent format
+ */
+static char *gelic_wl_translate_scan(struct net_device *netdev,
+				     char *ev,
+				     char *stop,
+				     struct gelic_wl_scan_info *network)
+{
+	struct iw_event iwe;
+	struct gelic_eurus_scan_info *scan = network->hwinfo;
+	char *tmp;
+	u8 rate;
+	unsigned int i, j, len;
+	u8 buf[MAX_WPA_IE_LEN];
+
+	pr_debug("%s: <-\n", __func__);
+
+	/* first entry should be AP's mac address */
+	iwe.cmd = SIOCGIWAP;
+	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
+	memcpy(iwe.u.ap_addr.sa_data, &scan->bssid[2], ETH_ALEN);
+	ev = iwe_stream_add_event(ev, stop, &iwe, IW_EV_ADDR_LEN);
+
+	/* ESSID */
+	iwe.cmd = SIOCGIWESSID;
+	iwe.u.data.flags = 1;
+	iwe.u.data.length = strnlen(scan->essid, 32);
+	ev = iwe_stream_add_point(ev, stop, &iwe, scan->essid);
+
+	/* FREQUENCY */
+	iwe.cmd = SIOCGIWFREQ;
+	iwe.u.freq.m = be16_to_cpu(scan->channel);
+	iwe.u.freq.e = 0; /* table value in MHz */
+	iwe.u.freq.i = 0;
+	ev = iwe_stream_add_event(ev, stop, &iwe, IW_EV_FREQ_LEN);
+
+	/* RATES */
+	iwe.cmd = SIOCGIWRATE;
+	iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
+	/* to stuff multiple values in one event */
+	tmp = ev + IW_EV_LCP_LEN;
+	/* put them in ascendant order (older is first) */
+	i = 0;
+	j = 0;
+	pr_debug("%s: rates=%d rate=%d\n", __func__,
+		 network->rate_len, network->rate_ext_len);
+	while (i < network->rate_len) {
+		if (j < network->rate_ext_len &&
+		    ((scan->ext_rate[j] & 0x7f) < (scan->rate[i] & 0x7f)))
+		    rate = scan->ext_rate[j++] & 0x7f;
+		else
+		    rate = scan->rate[i++] & 0x7f;
+		iwe.u.bitrate.value = rate * 500000; /* 500kbps unit */
+		tmp = iwe_stream_add_value(ev, tmp, stop, &iwe,
+					   IW_EV_PARAM_LEN);
+	}
+	while (j < network->rate_ext_len) {
+		iwe.u.bitrate.value = (scan->ext_rate[j++] & 0x7f) * 500000;
+		tmp = iwe_stream_add_value(ev, tmp, stop, &iwe,
+					   IW_EV_PARAM_LEN);
+	}
+	/* Check if we added any rate */
+	if (IW_EV_LCP_LEN < (tmp - ev))
+		ev = tmp;
+
+	/* ENCODE */
+	iwe.cmd = SIOCGIWENCODE;
+	if (be16_to_cpu(scan->capability) & WLAN_CAPABILITY_PRIVACY)
+		iwe.u.data.flags = IW_ENCODE_ENABLED | IW_ENCODE_NOKEY;
+	else
+		iwe.u.data.flags = IW_ENCODE_DISABLED;
+	iwe.u.data.length = 0;
+	ev = iwe_stream_add_point(ev, stop, &iwe, scan->essid);
+
+	/* MODE */
+	iwe.cmd = SIOCGIWMODE;
+	if (be16_to_cpu(scan->capability) &
+	    (WLAN_CAPABILITY_ESS | WLAN_CAPABILITY_IBSS)) {
+		if (be16_to_cpu(scan->capability) & WLAN_CAPABILITY_ESS)
+			iwe.u.mode = IW_MODE_MASTER;
+		else
+			iwe.u.mode = IW_MODE_ADHOC;
+		ev = iwe_stream_add_event(ev, stop, &iwe, IW_EV_UINT_LEN);
+	}
+
+	/* QUAL */
+	iwe.cmd = IWEVQUAL;
+	iwe.u.qual.updated  = IW_QUAL_ALL_UPDATED |
+			IW_QUAL_QUAL_INVALID | IW_QUAL_NOISE_INVALID;
+	iwe.u.qual.level = be16_to_cpu(scan->rssi);
+	iwe.u.qual.qual = be16_to_cpu(scan->rssi);
+	iwe.u.qual.noise = 0;
+	ev  = iwe_stream_add_event(ev, stop, &iwe, IW_EV_QUAL_LEN);
+
+	/* RSN */
+	memset(&iwe, 0, sizeof(iwe));
+	if (be16_to_cpu(scan->size) <= sizeof(*scan)) {
+		/* If wpa[2] capable station, synthesize IE and put it */
+		len = gelic_wl_synthesize_ie(buf, scan);
+		if (len) {
+			iwe.cmd = IWEVGENIE;
+			iwe.u.data.length = len;
+			ev = iwe_stream_add_point(ev, stop, &iwe, buf);
+		}
+	} else {
+		/* this scan info has IE data */
+		struct ie_info ie_info;
+		size_t data_len;
+
+		data_len = be16_to_cpu(scan->size) - sizeof(*scan);
+
+		gelic_wl_parse_ie(scan->elements, data_len, &ie_info);
+
+		if (ie_info.wpa.len && (ie_info.wpa.len <= sizeof(buf))) {
+			memcpy(buf, ie_info.wpa.data, ie_info.wpa.len);
+			iwe.cmd = IWEVGENIE;
+			iwe.u.data.length = ie_info.wpa.len;
+			ev = iwe_stream_add_point(ev, stop, &iwe, buf);
+		}
+
+		if (ie_info.rsn.len && (ie_info.rsn.len <= sizeof(buf))) {
+			memset(&iwe, 0, sizeof(iwe));
+			memcpy(buf, ie_info.rsn.data, ie_info.rsn.len);
+			iwe.cmd = IWEVGENIE;
+			iwe.u.data.length = ie_info.rsn.len;
+			ev = iwe_stream_add_point(ev, stop, &iwe, buf);
+		}
+	}
+
+	pr_debug("%s: ->\n", __func__);
+	return ev;
+}
+
+
+static int gelic_wl_get_scan(struct net_device *netdev,
+			     struct iw_request_info *info,
+			     union iwreq_data *wrqu, char *extra)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+	struct gelic_wl_scan_info *scan_info;
+	char *ev = extra;
+	char *stop = ev + wrqu->data.length;
+	int ret = 0;
+	unsigned long this_time = jiffies;
+
+	pr_debug("%s: <-\n", __func__);
+	if (down_interruptible(&wl->scan_lock))
+		return -EAGAIN;
+
+	switch (wl->scan_stat) {
+	case GELIC_WL_SCAN_STAT_SCANNING:
+		/* If a scan in progress, caller should call me again */
+		ret = -EAGAIN;
+		goto out;
+		break;
+
+	case GELIC_WL_SCAN_STAT_INIT:
+		/* last scan request failed or never issued */
+		ret = -ENODEV;
+		goto out;
+		break;
+	case GELIC_WL_SCAN_STAT_GOT_LIST:
+		/* ok, use current list */
+		break;
+	}
+
+	list_for_each_entry(scan_info, &wl->network_list, list) {
+		if (wl->scan_age == 0 ||
+		    time_after(scan_info->last_scanned + wl->scan_age,
+			       this_time))
+			ev = gelic_wl_translate_scan(netdev, ev, stop,
+						     scan_info);
+		else
+			pr_debug("%s:entry too old\n", __func__);
+
+		if (stop - ev <= IW_EV_ADDR_LEN) {
+			ret = -E2BIG;
+			goto out;
+		}
+	}
+
+	wrqu->data.length = ev - extra;
+	wrqu->data.flags = 0;
+out:
+	up(&wl->scan_lock);
+	pr_debug("%s: -> %d %d\n", __func__, ret, wrqu->data.length);
+	return ret;
+}
+
+#ifdef DEBUG
+static void scan_list_dump(struct gelic_wl_info *wl)
+{
+	struct gelic_wl_scan_info *scan_info;
+	int i;
+	DECLARE_MAC_BUF(mac);
+
+	i = 0;
+	list_for_each_entry(scan_info, &wl->network_list, list) {
+		pr_debug("%s: item %d\n", __func__, i++);
+		pr_debug("valid=%d eurusindex=%d last=%lx\n",
+			 scan_info->valid, scan_info->eurus_index,
+			 scan_info->last_scanned);
+		pr_debug("r_len=%d r_ext_len=%d essid_len=%d\n",
+			 scan_info->rate_len, scan_info->rate_ext_len,
+			 scan_info->essid_len);
+		/* -- */
+		pr_debug("bssid=%s\n",
+			 print_mac(mac, &scan_info->hwinfo->bssid[2]));
+		pr_debug("essid=%s\n", scan_info->hwinfo->essid);
+	}
+}
+#endif
+
+static int gelic_wl_set_auth(struct net_device *netdev,
+			     struct iw_request_info *info,
+			     union iwreq_data *data, char *extra)
+{
+	struct iw_param *param = &data->param;
+	struct gelic_wl_info *wl = port_wl(netdev_port(netdev));
+	unsigned long irqflag;
+	int ret = 0;
+
+	pr_debug("%s: <- %d\n", __func__, param->flags & IW_AUTH_INDEX);
+	spin_lock_irqsave(&wl->lock, irqflag);
+	switch (param->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_WPA_VERSION:
+		if (param->value & IW_AUTH_WPA_VERSION_DISABLED) {
+			pr_debug("%s: NO WPA selected\n", __func__);
+			wl->wpa_level = GELIC_WL_WPA_LEVEL_NONE;
+			wl->group_cipher_method = GELIC_WL_CIPHER_WEP;
+			wl->pairwise_cipher_method = GELIC_WL_CIPHER_WEP;
+		}
+		if (param->value & IW_AUTH_WPA_VERSION_WPA) {
+			pr_debug("%s: WPA version 1 selected\n", __func__);
+			wl->wpa_level = GELIC_WL_WPA_LEVEL_WPA;
+			wl->group_cipher_method = GELIC_WL_CIPHER_TKIP;
+			wl->pairwise_cipher_method = GELIC_WL_CIPHER_TKIP;
+			wl->auth_method = GELIC_EURUS_AUTH_OPEN;
+		}
+		if (param->value & IW_AUTH_WPA_VERSION_WPA2) {
+			/*
+			 * As the hypervisor may not tell the cipher
+			 * information of the AP if it is WPA2,
+			 * you will not decide suitable cipher from
+			 * its beacon.
+			 * You should have knowledge about the AP's
+			 * cipher infomation in other method prior to
+			 * the association.
+			 */
+			if (!precise_ie())
+				pr_info("%s: WPA2 may not work\n", __func__);
+			if (wpa2_capable()) {
+				wl->wpa_level = GELIC_WL_WPA_LEVEL_WPA2;
+				wl->group_cipher_method = GELIC_WL_CIPHER_AES;
+				wl->pairwise_cipher_method =
+					GELIC_WL_CIPHER_AES;
+				wl->auth_method = GELIC_EURUS_AUTH_OPEN;
+			} else
+				ret = -EINVAL;
+		}
+		break;
+
+	case IW_AUTH_CIPHER_PAIRWISE:
+		if (param->value &
+		    (IW_AUTH_CIPHER_WEP104 | IW_AUTH_CIPHER_WEP40)) {
+			pr_debug("%s: WEP selected\n", __func__);
+			wl->pairwise_cipher_method = GELIC_WL_CIPHER_WEP;
+		}
+		if (param->value & IW_AUTH_CIPHER_TKIP) {
+			pr_debug("%s: TKIP selected\n", __func__);
+			wl->pairwise_cipher_method = GELIC_WL_CIPHER_TKIP;
+		}
+		if (param->value & IW_AUTH_CIPHER_CCMP) {
+			pr_debug("%s: CCMP selected\n", __func__);
+			wl->pairwise_cipher_method = GELIC_WL_CIPHER_AES;
+		}
+		if (param->value & IW_AUTH_CIPHER_NONE) {
+			pr_debug("%s: no auth selected\n", __func__);
+			wl->pairwise_cipher_method = GELIC_WL_CIPHER_NONE;
+		}
+		break;
+	case IW_AUTH_CIPHER_GROUP:
+		if (param->value &
+		    (IW_AUTH_CIPHER_WEP104 | IW_AUTH_CIPHER_WEP40)) {
+			pr_debug("%s: WEP selected\n", __func__);
+			wl->group_cipher_method = GELIC_WL_CIPHER_WEP;
+		}
+		if (param->value & IW_AUTH_CIPHER_TKIP) {
+			pr_debug("%s: TKIP selected\n", __func__);
+			wl->group_cipher_method = GELIC_WL_CIPHER_TKIP;
+		}
+		if (param->value & IW_AUTH_CIPHER_CCMP) {
+			pr_debug("%s: CCMP selected\n", __func__);
+			wl->group_cipher_method = GELIC_WL_CIPHER_AES;
+		}
+		if (param->value & IW_AUTH_CIPHER_NONE) {
+			pr_debug("%s: no auth selected\n", __func__);
+			wl->group_cipher_method = GELIC_WL_CIPHER_NONE;
+		}
+		break;
+	case IW_AUTH_80211_AUTH_ALG:
+		if (param->value & IW_AUTH_ALG_SHARED_KEY) {
+			pr_debug("%s: shared key specified\n", __func__);
+			wl->auth_method = GELIC_EURUS_AUTH_SHARED;
+		} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
+			pr_debug("%s: open system specified\n", __func__);
+			wl->auth_method = GELIC_EURUS_AUTH_OPEN;
+		} else
+			ret = -EINVAL;
+		break;
+
+	case IW_AUTH_WPA_ENABLED:
+		if (param->value) {
+			pr_debug("%s: WPA enabled\n", __func__);
+			wl->wpa_level = GELIC_WL_WPA_LEVEL_WPA;
+		} else {
+			pr_debug("%s: WPA disabled\n", __func__);
+			wl->wpa_level = GELIC_WL_WPA_LEVEL_NONE;
+		}
+		break;
+
+	case IW_AUTH_KEY_MGMT:
+		if (param->value & IW_AUTH_KEY_MGMT_PSK)
+			break;
+		/* intentionally fall through */
+	default:
+		ret = -EOPNOTSUPP;
+		break;
+	};
+
+	if (!ret)
+		set_bit(GELIC_WL_STAT_CONFIGURED, &wl->stat);
+
+	spin_unlock_irqrestore(&wl->lock, irqflag);
+	pr_debug("%s: -> %d\n", __func__, ret);
+	return ret;
+}
+
+static int gelic_wl_get_auth(struct net_device *netdev,
+			     struct iw_request_info *info,
+			     union iwreq_data *iwreq, char *extra)
+{
+	struct iw_param *param = &iwreq->param;
+	struct gelic_wl_info *wl = port_wl(netdev_port(netdev));
+	unsigned long irqflag;
+	int ret = 0;
+
+	pr_debug("%s: <- %d\n", __func__, param->flags & IW_AUTH_INDEX);
+	spin_lock_irqsave(&wl->lock, irqflag);
+	switch (param->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_WPA_VERSION:
+		switch (wl->wpa_level) {
+		case GELIC_WL_WPA_LEVEL_WPA:
+			param->value |= IW_AUTH_WPA_VERSION_WPA;
+			break;
+		case GELIC_WL_WPA_LEVEL_WPA2:
+			param->value |= IW_AUTH_WPA_VERSION_WPA2;
+			break;
+		default:
+			param->value |= IW_AUTH_WPA_VERSION_DISABLED;
+		}
+		break;
+
+	case IW_AUTH_80211_AUTH_ALG:
+		if (wl->auth_method == GELIC_EURUS_AUTH_SHARED)
+			param->value = IW_AUTH_ALG_SHARED_KEY;
+		else if (wl->auth_method == GELIC_EURUS_AUTH_OPEN)
+			param->value = IW_AUTH_ALG_OPEN_SYSTEM;
+		break;
+
+	case IW_AUTH_WPA_ENABLED:
+		switch (wl->wpa_level) {
+		case GELIC_WL_WPA_LEVEL_WPA:
+		case GELIC_WL_WPA_LEVEL_WPA2:
+			param->value = 1;
+			break;
+		default:
+			param->value = 0;
+			break;
+		}
+		break;
+	default:
+		ret = -EOPNOTSUPP;
+	}
+
+	spin_unlock_irqrestore(&wl->lock, irqflag);
+	pr_debug("%s: -> %d\n", __func__, ret);
+	return ret;
+}
+
+/* SIOC{S,G}IWESSID */
+static int gelic_wl_set_essid(struct net_device *netdev,
+			      struct iw_request_info *info,
+			      union iwreq_data *data, char *extra)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+	unsigned long irqflag;
+
+	pr_debug("%s: <- l=%d f=%d\n", __func__,
+		 data->essid.length, data->essid.flags);
+	if (IW_ESSID_MAX_SIZE < data->essid.length)
+		return -EINVAL;
+
+	spin_lock_irqsave(&wl->lock, irqflag);
+	if (data->essid.flags) {
+		wl->essid_len = data->essid.length;
+		memcpy(wl->essid, extra, wl->essid_len);
+		pr_debug("%s: essid = '%s'\n", __func__, extra);
+		set_bit(GELIC_WL_STAT_ESSID_SET, &wl->stat);
+	} else {
+		pr_debug("%s: ESSID any \n", __func__);
+		clear_bit(GELIC_WL_STAT_ESSID_SET, &wl->stat);
+	}
+	set_bit(GELIC_WL_STAT_CONFIGURED, &wl->stat);
+	spin_unlock_irqrestore(&wl->lock, irqflag);
+
+
+	gelic_wl_try_associate(netdev); /* FIXME */
+	pr_debug("%s: -> \n", __func__);
+	return 0;
+}
+
+static int gelic_wl_get_essid(struct net_device *netdev,
+			      struct iw_request_info *info,
+			      union iwreq_data *data, char *extra)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+	unsigned long irqflag;
+
+	pr_debug("%s: <- \n", __func__);
+	down(&wl->assoc_stat_lock);
+	spin_lock_irqsave(&wl->lock, irqflag);
+	if (test_bit(GELIC_WL_STAT_ESSID_SET, &wl->stat) ||
+	    wl->assoc_stat == GELIC_WL_ASSOC_STAT_ASSOCIATED) {
+		memcpy(extra, wl->essid, wl->essid_len);
+		data->essid.length = wl->essid_len;
+		data->essid.flags = 1;
+	} else
+		data->essid.flags = 0;
+
+	up(&wl->assoc_stat_lock);
+	spin_unlock_irqrestore(&wl->lock, irqflag);
+	pr_debug("%s: -> len=%d \n", __func__, data->essid.length);
+
+	return 0;
+}
+
+/* SIO{S,G}IWENCODE */
+static int gelic_wl_set_encode(struct net_device *netdev,
+			       struct iw_request_info *info,
+			       union iwreq_data *data, char *extra)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+	struct iw_point *enc = &data->encoding;
+	__u16 flags;
+	unsigned int irqflag;
+	int key_index, index_specified;
+	int ret = 0;
+
+	pr_debug("%s: <- \n", __func__);
+	flags = enc->flags & IW_ENCODE_FLAGS;
+	key_index = enc->flags & IW_ENCODE_INDEX;
+
+	pr_debug("%s: key_index = %d\n", __func__, key_index);
+	pr_debug("%s: key_len = %d\n", __func__, enc->length);
+	pr_debug("%s: flag=%x\n", __func__, enc->flags & IW_ENCODE_FLAGS);
+
+	if (GELIC_WEP_KEYS < key_index)
+		return -EINVAL;
+
+	spin_lock_irqsave(&wl->lock, irqflag);
+	if (key_index) {
+		index_specified = 1;
+		key_index--;
+	} else {
+		index_specified = 0;
+		key_index = wl->current_key;
+	}
+
+	if (flags & IW_ENCODE_NOKEY) {
+		/* if just IW_ENCODE_NOKEY, change current key index */
+		if (!flags && index_specified) {
+			wl->current_key = key_index;
+			goto done;
+		}
+
+		if (flags & IW_ENCODE_DISABLED) {
+			if (!index_specified) {
+				/* disable encryption */
+				wl->group_cipher_method = GELIC_WL_CIPHER_NONE;
+				wl->pairwise_cipher_method =
+					GELIC_WL_CIPHER_NONE;
+				/* invalidate all key */
+				wl->key_enabled = 0;
+			} else
+				clear_bit(key_index, &wl->key_enabled);
+		}
+
+		if (flags & IW_ENCODE_OPEN)
+			wl->auth_method = GELIC_EURUS_AUTH_OPEN;
+		if (flags & IW_ENCODE_RESTRICTED) {
+			pr_info("%s: shared key mode enabled\n", __func__);
+			wl->auth_method = GELIC_EURUS_AUTH_SHARED;
+		}
+	} else {
+		if (IW_ENCODING_TOKEN_MAX < enc->length) {
+			ret = -EINVAL;
+			goto done;
+		}
+		wl->key_len[key_index] = enc->length;
+		memcpy(wl->key[key_index], extra, enc->length);
+		set_bit(key_index, &wl->key_enabled);
+		wl->pairwise_cipher_method = GELIC_WL_CIPHER_WEP;
+		wl->group_cipher_method = GELIC_WL_CIPHER_WEP;
+	}
+	set_bit(GELIC_WL_STAT_CONFIGURED, &wl->stat);
+done:
+	spin_unlock_irqrestore(&wl->lock, irqflag);
+	pr_debug("%s: -> \n", __func__);
+	return ret;
+}
+
+static int gelic_wl_get_encode(struct net_device *netdev,
+			       struct iw_request_info *info,
+			       union iwreq_data *data, char *extra)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+	struct iw_point *enc = &data->encoding;
+	unsigned int irqflag;
+	unsigned int key_index, index_specified;
+	int ret = 0;
+
+	pr_debug("%s: <- \n", __func__);
+	key_index = enc->flags & IW_ENCODE_INDEX;
+	pr_debug("%s: flag=%#x point=%p len=%d extra=%p\n", __func__,
+		 enc->flags, enc->pointer, enc->length, extra);
+	if (GELIC_WEP_KEYS < key_index)
+		return -EINVAL;
+
+	spin_lock_irqsave(&wl->lock, irqflag);
+	if (key_index) {
+		index_specified = 1;
+		key_index--;
+	} else {
+		index_specified = 0;
+		key_index = wl->current_key;
+	}
+
+	if (wl->group_cipher_method == GELIC_WL_CIPHER_WEP) {
+		switch (wl->auth_method) {
+		case GELIC_EURUS_AUTH_OPEN:
+			enc->flags = IW_ENCODE_OPEN;
+			break;
+		case GELIC_EURUS_AUTH_SHARED:
+			enc->flags = IW_ENCODE_RESTRICTED;
+			break;
+		}
+	} else
+		enc->flags = IW_ENCODE_DISABLED;
+
+	if (test_bit(key_index, &wl->key_enabled)) {
+		if (enc->length < wl->key_len[key_index]) {
+			ret = -EINVAL;
+			goto done;
+		}
+		enc->length = wl->key_len[key_index];
+		memcpy(extra, wl->key[key_index], wl->key_len[key_index]);
+	} else {
+		enc->length = 0;
+		enc->flags |= IW_ENCODE_NOKEY;
+	}
+	enc->flags |= key_index + 1;
+	pr_debug("%s: -> flag=%x len=%d\n", __func__,
+		 enc->flags, enc->length);
+
+done:
+	spin_unlock_irqrestore(&wl->lock, irqflag);
+	return ret;
+}
+
+/* SIOC{S,G}IWAP */
+static int gelic_wl_set_ap(struct net_device *netdev,
+			   struct iw_request_info *info,
+			   union iwreq_data *data, char *extra)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+	unsigned long irqflag;
+
+	pr_debug("%s: <-\n", __func__);
+	if (data->ap_addr.sa_family != ARPHRD_ETHER)
+		return -EINVAL;
+
+	spin_lock_irqsave(&wl->lock, irqflag);
+	if (is_valid_ether_addr(data->ap_addr.sa_data)) {
+		memcpy(wl->bssid, data->ap_addr.sa_data,
+		       ETH_ALEN);
+		set_bit(GELIC_WL_STAT_BSSID_SET, &wl->stat);
+		set_bit(GELIC_WL_STAT_CONFIGURED, &wl->stat);
+		pr_debug("%s: bss=%02x:%02x:%02x:%02x:%02x:%02x\n",
+			 __func__,
+			 wl->bssid[0], wl->bssid[1],
+			 wl->bssid[2], wl->bssid[3],
+			 wl->bssid[4], wl->bssid[5]);
+	} else {
+		pr_debug("%s: clear bssid\n", __func__);
+		clear_bit(GELIC_WL_STAT_BSSID_SET, &wl->stat);
+		memset(wl->bssid, 0, ETH_ALEN);
+	}
+	spin_unlock_irqrestore(&wl->lock, irqflag);
+	pr_debug("%s: ->\n", __func__);
+	return 0;
+}
+
+static int gelic_wl_get_ap(struct net_device *netdev,
+			   struct iw_request_info *info,
+			   union iwreq_data *data, char *extra)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+	unsigned long irqflag;
+
+	pr_debug("%s: <-\n", __func__);
+	down(&wl->assoc_stat_lock);
+	spin_lock_irqsave(&wl->lock, irqflag);
+	if (wl->assoc_stat == GELIC_WL_ASSOC_STAT_ASSOCIATED) {
+		data->ap_addr.sa_family = ARPHRD_ETHER;
+		memcpy(data->ap_addr.sa_data, wl->active_bssid,
+		       ETH_ALEN);
+	} else
+		memset(data->ap_addr.sa_data, 0, ETH_ALEN);
+
+	spin_unlock_irqrestore(&wl->lock, irqflag);
+	up(&wl->assoc_stat_lock);
+	pr_debug("%s: ->\n", __func__);
+	return 0;
+}
+
+/* SIOC{S,G}IWENCODEEXT */
+static int gelic_wl_set_encodeext(struct net_device *netdev,
+				  struct iw_request_info *info,
+				  union iwreq_data *data, char *extra)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+	struct iw_point *enc = &data->encoding;
+	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
+	__u16 alg;
+	__u16 flags;
+	unsigned int irqflag;
+	int key_index;
+	int ret = 0;
+
+	pr_debug("%s: <- \n", __func__);
+	flags = enc->flags & IW_ENCODE_FLAGS;
+	alg = ext->alg;
+	key_index = enc->flags & IW_ENCODE_INDEX;
+
+	pr_debug("%s: key_index = %d\n", __func__, key_index);
+	pr_debug("%s: key_len = %d\n", __func__, enc->length);
+	pr_debug("%s: flag=%x\n", __func__, enc->flags & IW_ENCODE_FLAGS);
+	pr_debug("%s: ext_flag=%x\n", __func__, ext->ext_flags);
+	pr_debug("%s: ext_key_len=%x\n", __func__, ext->key_len);
+
+	if (GELIC_WEP_KEYS < key_index)
+		return -EINVAL;
+
+	spin_lock_irqsave(&wl->lock, irqflag);
+	if (key_index)
+		key_index--;
+	else
+		key_index = wl->current_key;
+
+	if (!enc->length && (ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY)) {
+		/* reques to change default key index */
+		pr_debug("%s: request to change default key to %d\n",
+			 __func__, key_index);
+		wl->current_key = key_index;
+		goto done;
+	}
+
+	if (alg == IW_ENCODE_ALG_NONE || (flags & IW_ENCODE_DISABLED)) {
+		pr_debug("%s: alg disabled\n", __func__);
+		wl->wpa_level = GELIC_WL_WPA_LEVEL_NONE;
+		wl->group_cipher_method = GELIC_WL_CIPHER_NONE;
+		wl->pairwise_cipher_method = GELIC_WL_CIPHER_NONE;
+		wl->auth_method = GELIC_EURUS_AUTH_OPEN; /* should be open */
+	} else if (alg == IW_ENCODE_ALG_WEP) {
+		pr_debug("%s: WEP requested\n", __func__);
+		if (flags & IW_ENCODE_OPEN) {
+			pr_debug("%s: open key mode\n", __func__);
+			wl->auth_method = GELIC_EURUS_AUTH_OPEN;
+		}
+		if (flags & IW_ENCODE_RESTRICTED) {
+			pr_debug("%s: shared key mode\n", __func__);
+			wl->auth_method = GELIC_EURUS_AUTH_SHARED;
+		}
+		if (IW_ENCODING_TOKEN_MAX < ext->key_len) {
+			pr_info("%s: key is too long %d\n", __func__,
+				ext->key_len);
+			ret = -EINVAL;
+			goto done;
+		}
+		/* OK, update the key */
+		wl->key_len[key_index] = ext->key_len;
+		memset(wl->key[key_index], 0, IW_ENCODING_TOKEN_MAX);
+		memcpy(wl->key[key_index], ext->key, ext->key_len);
+		set_bit(key_index, &wl->key_enabled);
+		/* remember wep info changed */
+		set_bit(GELIC_WL_STAT_CONFIGURED, &wl->stat);
+	} else if ((alg == IW_ENCODE_ALG_TKIP) || (alg == IW_ENCODE_ALG_CCMP)) {
+		pr_debug("%s: TKIP/CCMP requested alg=%d\n", __func__, alg);
+		/* check key length */
+		if (IW_ENCODING_TOKEN_MAX < ext->key_len) {
+			pr_info("%s: key is too long %d\n", __func__,
+				ext->key_len);
+			ret = -EINVAL;
+			goto done;
+		}
+		if (alg == IW_ENCODE_ALG_CCMP) {
+			pr_debug("%s: AES selected\n", __func__);
+			wl->group_cipher_method = GELIC_WL_CIPHER_AES;
+			wl->pairwise_cipher_method = GELIC_WL_CIPHER_AES;
+			wl->wpa_level = GELIC_WL_WPA_LEVEL_WPA2;
+		} else {
+			pr_debug("%s: TKIP selected, WPA forced\n", __func__);
+			wl->group_cipher_method = GELIC_WL_CIPHER_TKIP;
+			wl->pairwise_cipher_method = GELIC_WL_CIPHER_TKIP;
+			/* FIXME: how do we do if WPA2 + TKIP? */
+			wl->wpa_level = GELIC_WL_WPA_LEVEL_WPA;
+		}
+		if (flags & IW_ENCODE_RESTRICTED)
+			BUG();
+		wl->auth_method = GELIC_EURUS_AUTH_OPEN;
+		/* We should use same key for both and unicast */
+		if (ext->ext_flags & IW_ENCODE_EXT_GROUP_KEY)
+			pr_debug("%s: group key \n", __func__);
+		else
+			pr_debug("%s: unicast key \n", __func__);
+		/* OK, update the key */
+		wl->key_len[key_index] = ext->key_len;
+		memset(wl->key[key_index], 0, IW_ENCODING_TOKEN_MAX);
+		memcpy(wl->key[key_index], ext->key, ext->key_len);
+		set_bit(key_index, &wl->key_enabled);
+		/* remember info changed */
+		set_bit(GELIC_WL_STAT_CONFIGURED, &wl->stat);
+	}
+done:
+	spin_unlock_irqrestore(&wl->lock, irqflag);
+	pr_debug("%s: -> \n", __func__);
+	return ret;
+}
+
+static int gelic_wl_get_encodeext(struct net_device *netdev,
+				  struct iw_request_info *info,
+				  union iwreq_data *data, char *extra)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+	struct iw_point *enc = &data->encoding;
+	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
+	unsigned int irqflag;
+	int key_index;
+	int ret = 0;
+	int max_key_len;
+
+	pr_debug("%s: <- \n", __func__);
+
+	max_key_len = enc->length - sizeof(struct iw_encode_ext);
+	if (max_key_len < 0)
+		return -EINVAL;
+	key_index = enc->flags & IW_ENCODE_INDEX;
+
+	pr_debug("%s: key_index = %d\n", __func__, key_index);
+	pr_debug("%s: key_len = %d\n", __func__, enc->length);
+	pr_debug("%s: flag=%x\n", __func__, enc->flags & IW_ENCODE_FLAGS);
+
+	if (GELIC_WEP_KEYS < key_index)
+		return -EINVAL;
+
+	spin_lock_irqsave(&wl->lock, irqflag);
+	if (key_index)
+		key_index--;
+	else
+		key_index = wl->current_key;
+
+	memset(ext, 0, sizeof(struct iw_encode_ext));
+	switch (wl->group_cipher_method) {
+	case GELIC_WL_CIPHER_WEP:
+		ext->alg = IW_ENCODE_ALG_WEP;
+		enc->flags |= IW_ENCODE_ENABLED;
+		break;
+	case GELIC_WL_CIPHER_TKIP:
+		ext->alg = IW_ENCODE_ALG_TKIP;
+		enc->flags |= IW_ENCODE_ENABLED;
+		break;
+	case GELIC_WL_CIPHER_AES:
+		ext->alg = IW_ENCODE_ALG_CCMP;
+		enc->flags |= IW_ENCODE_ENABLED;
+		break;
+	case GELIC_WL_CIPHER_NONE:
+	default:
+		ext->alg = IW_ENCODE_ALG_NONE;
+		enc->flags |= IW_ENCODE_NOKEY;
+		break;
+	}
+
+	if (!(enc->flags & IW_ENCODE_NOKEY)) {
+		if (max_key_len < wl->key_len[key_index]) {
+			ret = -E2BIG;
+			goto out;
+		}
+		if (test_bit(key_index, &wl->key_enabled))
+			memcpy(ext->key, wl->key[key_index],
+			       wl->key_len[key_index]);
+		else
+			pr_debug("%s: disabled key requested ix=%d\n",
+				 __func__, key_index);
+	}
+out:
+	spin_unlock_irqrestore(&wl->lock, irqflag);
+	pr_debug("%s: -> \n", __func__);
+	return ret;
+}
+/* SIOC{S,G}IWMODE */
+static int gelic_wl_set_mode(struct net_device *netdev,
+			     struct iw_request_info *info,
+			     union iwreq_data *data, char *extra)
+{
+	__u32 mode = data->mode;
+	int ret;
+
+	pr_debug("%s: <- \n", __func__);
+	if (mode == IW_MODE_INFRA)
+		ret = 0;
+	else
+		ret = -EOPNOTSUPP;
+	pr_debug("%s: -> %d\n", __func__, ret);
+	return ret;
+}
+
+static int gelic_wl_get_mode(struct net_device *netdev,
+			     struct iw_request_info *info,
+			     union iwreq_data *data, char *extra)
+{
+	__u32 *mode = &data->mode;
+	pr_debug("%s: <- \n", __func__);
+	*mode = IW_MODE_INFRA;
+	pr_debug("%s: ->\n", __func__);
+	return 0;
+}
+
+/* SIOCIWFIRSTPRIV */
+static int hex2bin(u8 *str, u8 *bin, unsigned int len)
+{
+	unsigned int i;
+	static unsigned char *hex = "0123456789ABCDEF";
+	unsigned char *p, *q;
+	u8 tmp;
+
+	if (len != WPA_PSK_LEN * 2)
+		return -EINVAL;
+
+	for (i = 0; i < WPA_PSK_LEN * 2; i += 2) {
+		p = strchr(hex, toupper(str[i]));
+		q = strchr(hex, toupper(str[i + 1]));
+		if (!p || !q) {
+			pr_info("%s: unconvertible PSK digit=%d\n",
+				__func__, i);
+			return -EINVAL;
+		}
+		tmp = ((p - hex) << 4) + (q - hex);
+		*bin++ = tmp;
+	}
+	return 0;
+};
+
+static int gelic_wl_priv_set_psk(struct net_device *net_dev,
+				 struct iw_request_info *info,
+				 union iwreq_data *data, char *extra)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(net_dev));
+	unsigned int len;
+	unsigned int irqflag;
+	int ret = 0;
+
+	pr_debug("%s:<- len=%d\n", __func__, data->data.length);
+	len = data->data.length - 1;
+	if (len <= 2)
+		return -EINVAL;
+
+	spin_lock_irqsave(&wl->lock, irqflag);
+	if (extra[0] == '"' && extra[len - 1] == '"') {
+		pr_debug("%s: passphrase mode\n", __func__);
+		/* pass phrase */
+		if (GELIC_WL_EURUS_PSK_MAX_LEN < (len - 2)) {
+			pr_info("%s: passphrase too long\n", __func__);
+			ret = -E2BIG;
+			goto out;
+		}
+		memset(wl->psk, 0, sizeof(wl->psk));
+		wl->psk_len = len - 2;
+		memcpy(wl->psk, &(extra[1]), wl->psk_len);
+		wl->psk_type = GELIC_EURUS_WPA_PSK_PASSPHRASE;
+	} else {
+		ret = hex2bin(extra, wl->psk, len);
+		if (ret)
+			goto out;
+		wl->psk_len = WPA_PSK_LEN;
+		wl->psk_type = GELIC_EURUS_WPA_PSK_BIN;
+	}
+	set_bit(GELIC_WL_STAT_WPA_PSK_SET, &wl->stat);
+out:
+	spin_unlock_irqrestore(&wl->lock, irqflag);
+	pr_debug("%s:->\n", __func__);
+	return ret;
+}
+
+static int gelic_wl_priv_get_psk(struct net_device *net_dev,
+				 struct iw_request_info *info,
+				 union iwreq_data *data, char *extra)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(net_dev));
+	char *p;
+	unsigned int irqflag;
+	unsigned int i;
+
+	pr_debug("%s:<-\n", __func__);
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	spin_lock_irqsave(&wl->lock, irqflag);
+	p = extra;
+	if (test_bit(GELIC_WL_STAT_WPA_PSK_SET, &wl->stat)) {
+		if (wl->psk_type == GELIC_EURUS_WPA_PSK_BIN) {
+			for (i = 0; i < wl->psk_len; i++) {
+				sprintf(p, "%02xu", wl->psk[i]);
+				p += 2;
+			}
+			*p = '\0';
+			data->data.length = wl->psk_len * 2;
+		} else {
+			*p++ = '"';
+			memcpy(p, wl->psk, wl->psk_len);
+			p += wl->psk_len;
+			*p++ = '"';
+			*p = '\0';
+			data->data.length = wl->psk_len + 2;
+		}
+	} else
+		/* no psk set */
+		data->data.length = 0;
+	spin_unlock_irqrestore(&wl->lock, irqflag);
+	pr_debug("%s:-> %d\n", __func__, data->data.length);
+	return 0;
+}
+
+/* SIOCGIWNICKN */
+static int gelic_wl_get_nick(struct net_device *net_dev,
+				  struct iw_request_info *info,
+				  union iwreq_data *data, char *extra)
+{
+	strcpy(extra, "gelic_wl");
+	data->data.length = strlen(extra);
+	data->data.flags = 1;
+	return 0;
+}
+
+
+/* --- */
+
+static struct iw_statistics *gelic_wl_get_wireless_stats(
+	struct net_device *netdev)
+{
+
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+	struct gelic_eurus_cmd *cmd;
+	struct iw_statistics *is;
+	struct gelic_eurus_rssi_info *rssi;
+
+	pr_debug("%s: <-\n", __func__);
+
+	is = &wl->iwstat;
+	memset(is, 0, sizeof(*is));
+	cmd = gelic_eurus_sync_cmd(wl, GELIC_EURUS_CMD_GET_RSSI_CFG,
+				   wl->buf, sizeof(*rssi));
+	if (cmd && !cmd->status && !cmd->cmd_status) {
+		rssi = wl->buf;
+		is->qual.level = be16_to_cpu(rssi->rssi);
+		is->qual.updated = IW_QUAL_LEVEL_UPDATED |
+			IW_QUAL_QUAL_INVALID | IW_QUAL_NOISE_INVALID;
+	} else
+		/* not associated */
+		is->qual.updated = IW_QUAL_ALL_INVALID;
+
+	kfree(cmd);
+	pr_debug("%s: ->\n", __func__);
+	return is;
+}
+
+/*
+ *  scanning helpers
+ */
+static int gelic_wl_start_scan(struct gelic_wl_info *wl, int always_scan)
+{
+	struct gelic_eurus_cmd *cmd;
+	int ret = 0;
+
+	pr_debug("%s: <- always=%d\n", __func__, always_scan);
+	if (down_interruptible(&wl->scan_lock))
+		return -ERESTARTSYS;
+
+	/*
+	 * If already a scan in progress, do not trigger more
+	 */
+	if (wl->scan_stat == GELIC_WL_SCAN_STAT_SCANNING) {
+		pr_debug("%s: scanning now\n", __func__);
+		goto out;
+	}
+
+	init_completion(&wl->scan_done);
+	/*
+	 * If we have already a bss list, don't try to get new
+	 */
+	if (!always_scan && wl->scan_stat == GELIC_WL_SCAN_STAT_GOT_LIST) {
+		pr_debug("%s: already has the list\n", __func__);
+		complete(&wl->scan_done);
+		goto out;
+	}
+	/*
+	 * issue start scan request
+	 */
+	wl->scan_stat = GELIC_WL_SCAN_STAT_SCANNING;
+	cmd = gelic_eurus_sync_cmd(wl, GELIC_EURUS_CMD_START_SCAN,
+				   NULL, 0);
+	if (!cmd || cmd->status || cmd->cmd_status) {
+		wl->scan_stat = GELIC_WL_SCAN_STAT_INIT;
+		complete(&wl->scan_done);
+		ret = -ENOMEM;
+		goto out;
+	}
+	kfree(cmd);
+out:
+	up(&wl->scan_lock);
+	pr_debug("%s: ->\n", __func__);
+	return ret;
+}
+
+/*
+ * retrieve scan result from the chip (hypervisor)
+ * this function is invoked by schedule work.
+ */
+static void gelic_wl_scan_complete_event(struct gelic_wl_info *wl)
+{
+	struct gelic_eurus_cmd *cmd = NULL;
+	struct gelic_wl_scan_info *target, *tmp;
+	struct gelic_wl_scan_info *oldest = NULL;
+	struct gelic_eurus_scan_info *scan_info;
+	unsigned int scan_info_size;
+	union iwreq_data data;
+	unsigned long this_time = jiffies;
+	unsigned int data_len, i, found, r;
+	DECLARE_MAC_BUF(mac);
+
+	pr_debug("%s:start\n", __func__);
+	down(&wl->scan_lock);
+
+	if (wl->scan_stat != GELIC_WL_SCAN_STAT_SCANNING) {
+		/*
+		 * stop() may be called while scanning, ignore result
+		 */
+		pr_debug("%s: scan complete when stat != scanning(%d)\n",
+			 __func__, wl->scan_stat);
+		goto out;
+	}
+
+	cmd = gelic_eurus_sync_cmd(wl, GELIC_EURUS_CMD_GET_SCAN,
+				   wl->buf, PAGE_SIZE);
+	if (!cmd || cmd->status || cmd->cmd_status) {
+		wl->scan_stat = GELIC_WL_SCAN_STAT_INIT;
+		pr_info("%s:cmd failed\n", __func__);
+		kfree(cmd);
+		goto out;
+	}
+	data_len = cmd->size;
+	pr_debug("%s: data_len = %d\n", __func__, data_len);
+	kfree(cmd);
+
+	/* OK, bss list retrieved */
+	wl->scan_stat = GELIC_WL_SCAN_STAT_GOT_LIST;
+
+	/* mark all entries are old */
+	list_for_each_entry_safe(target, tmp, &wl->network_list, list) {
+		target->valid = 0;
+		/* expire too old entries */
+		if (time_before(target->last_scanned + wl->scan_age,
+				this_time)) {
+			kfree(target->hwinfo);
+			target->hwinfo = NULL;
+			list_move_tail(&target->list, &wl->network_free_list);
+		}
+	}
+
+	/* put them in the newtork_list */
+	scan_info = wl->buf;
+	scan_info_size = 0;
+	i = 0;
+	while (scan_info_size < data_len) {
+		pr_debug("%s:size=%d bssid=%s scan_info=%p\n", __func__,
+			 be16_to_cpu(scan_info->size),
+			 print_mac(mac, &scan_info->bssid[2]), scan_info);
+		found = 0;
+		oldest = NULL;
+		list_for_each_entry(target, &wl->network_list, list) {
+			if (!compare_ether_addr(&target->hwinfo->bssid[2],
+						&scan_info->bssid[2])) {
+				found = 1;
+				pr_debug("%s: same BBS found scanned list\n",
+					 __func__);
+				break;
+			}
+			if (!oldest ||
+			    (target->last_scanned < oldest->last_scanned))
+				oldest = target;
+		}
+
+		if (!found) {
+			/* not found in the list */
+			if (list_empty(&wl->network_free_list)) {
+				/* expire oldest */
+				target = oldest;
+			} else {
+				target = list_entry(wl->network_free_list.next,
+						    struct gelic_wl_scan_info,
+						    list);
+			}
+		}
+
+		/* update the item */
+		target->last_scanned = this_time;
+		target->valid = 1;
+		target->eurus_index = i;
+		kfree(target->hwinfo);
+		target->hwinfo = kzalloc(be16_to_cpu(scan_info->size),
+					 GFP_KERNEL);
+		if (!target->hwinfo) {
+			pr_info("%s: kzalloc failed\n", __func__);
+			i++;
+			scan_info_size += be16_to_cpu(scan_info->size);
+			scan_info = (void *)scan_info +
+				be16_to_cpu(scan_info->size);
+			continue;
+		}
+		/* copy hw scan info */
+		memcpy(target->hwinfo, scan_info, scan_info->size);
+		target->essid_len = strnlen(scan_info->essid,
+					    sizeof(scan_info->essid));
+		target->rate_len = 0;
+		for (r = 0; r < MAX_RATES_LENGTH; r++)
+			if (scan_info->rate[r])
+				target->rate_len++;
+		if (8 < target->rate_len)
+			pr_info("%s: AP returns %d rates\n", __func__,
+				target->rate_len);
+		target->rate_ext_len = 0;
+		for (r = 0; r < MAX_RATES_EX_LENGTH; r++)
+			if (scan_info->ext_rate[r])
+				target->rate_ext_len++;
+		list_move_tail(&target->list, &wl->network_list);
+		/* bump pointer */
+		i++;
+		scan_info_size += be16_to_cpu(scan_info->size);
+		scan_info = (void *)scan_info + be16_to_cpu(scan_info->size);
+	}
+	memset(&data, 0, sizeof(data));
+	wireless_send_event(port_to_netdev(wl_port(wl)), SIOCGIWSCAN, &data,
+			    NULL);
+out:
+	complete(&wl->scan_done);
+	up(&wl->scan_lock);
+	pr_debug("%s:end\n", __func__);
+}
+
+/*
+ * Select an appropriate bss from current scan list regarding
+ * current settings from userspace.
+ * The caller must hold wl->scan_lock,
+ * and on the state of wl->scan_state == GELIC_WL_SCAN_GOT_LIST
+ */
+static void update_best(struct gelic_wl_scan_info **best,
+			struct gelic_wl_scan_info *candid,
+			int *best_weight,
+			int *weight)
+{
+	if (*best_weight < ++(*weight)) {
+		*best_weight = *weight;
+		*best = candid;
+	}
+}
+
+static
+struct gelic_wl_scan_info *gelic_wl_find_best_bss(struct gelic_wl_info *wl)
+{
+	struct gelic_wl_scan_info *scan_info;
+	struct gelic_wl_scan_info *best_bss;
+	int weight, best_weight;
+	u16 security;
+	DECLARE_MAC_BUF(mac);
+
+	pr_debug("%s: <-\n", __func__);
+
+	best_bss = NULL;
+	best_weight = 0;
+
+	list_for_each_entry(scan_info, &wl->network_list, list) {
+		pr_debug("%s: station %p\n", __func__, scan_info);
+
+		if (!scan_info->valid) {
+			pr_debug("%s: station invalid\n", __func__);
+			continue;
+		}
+
+		/* If bss specified, check it only */
+		if (test_bit(GELIC_WL_STAT_BSSID_SET, &wl->stat)) {
+			if (!compare_ether_addr(&scan_info->hwinfo->bssid[2],
+						wl->bssid)) {
+				best_bss = scan_info;
+				pr_debug("%s: bssid matched\n", __func__);
+				break;
+			} else {
+				pr_debug("%s: bssid unmached\n", __func__);
+				continue;
+			}
+		}
+
+		weight = 0;
+
+		/* security */
+		security = be16_to_cpu(scan_info->hwinfo->security) &
+			GELIC_EURUS_SCAN_SEC_MASK;
+		if (wl->wpa_level == GELIC_WL_WPA_LEVEL_WPA2) {
+			if (security == GELIC_EURUS_SCAN_SEC_WPA2)
+				update_best(&best_bss, scan_info,
+					    &best_weight, &weight);
+			else
+				continue;
+		} else if (wl->wpa_level == GELIC_WL_WPA_LEVEL_WPA) {
+			if (security == GELIC_EURUS_SCAN_SEC_WPA)
+				update_best(&best_bss, scan_info,
+					    &best_weight, &weight);
+			else
+				continue;
+		} else if (wl->wpa_level == GELIC_WL_WPA_LEVEL_NONE &&
+			   wl->group_cipher_method == GELIC_WL_CIPHER_WEP) {
+			if (security == GELIC_EURUS_SCAN_SEC_WEP)
+				update_best(&best_bss, scan_info,
+					    &best_weight, &weight);
+			else
+				continue;
+		}
+
+		/* If ESSID is set, check it */
+		if (test_bit(GELIC_WL_STAT_ESSID_SET, &wl->stat)) {
+			if ((scan_info->essid_len == wl->essid_len) &&
+			    !strncmp(wl->essid,
+				     scan_info->hwinfo->essid,
+				     scan_info->essid_len))
+				update_best(&best_bss, scan_info,
+					    &best_weight, &weight);
+			else
+				continue;
+		}
+	}
+
+#ifdef DEBUG
+	pr_debug("%s: -> bss=%p\n", __func__, best_bss);
+	if (best_bss) {
+		pr_debug("%s:addr=%s\n", __func__,
+			 print_mac(mac, &best_bss->hwinfo->bssid[2]));
+	}
+#endif
+	return best_bss;
+}
+
+/*
+ * Setup WEP configuration to the chip
+ * The caller must hold wl->scan_lock,
+ * and on the state of wl->scan_state == GELIC_WL_SCAN_GOT_LIST
+ */
+static int gelic_wl_do_wep_setup(struct gelic_wl_info *wl)
+{
+	unsigned int i;
+	struct gelic_eurus_wep_cfg *wep;
+	struct gelic_eurus_cmd *cmd;
+	int wep104 = 0;
+	int have_key = 0;
+	int ret = 0;
+
+	pr_debug("%s: <-\n", __func__);
+	/* we can assume no one should uses the buffer */
+	wep = wl->buf;
+	memset(wep, 0, sizeof(*wep));
+
+	if (wl->group_cipher_method == GELIC_WL_CIPHER_WEP) {
+		pr_debug("%s: WEP mode\n", __func__);
+		for (i = 0; i < GELIC_WEP_KEYS; i++) {
+			if (!test_bit(i, &wl->key_enabled))
+				continue;
+
+			pr_debug("%s: key#%d enabled\n", __func__, i);
+			have_key = 1;
+			if (wl->key_len[i] == 13)
+				wep104 = 1;
+			else if (wl->key_len[i] != 5) {
+				pr_info("%s: wrong wep key[%d]=%d\n",
+					__func__, i, wl->key_len[i]);
+				ret = -EINVAL;
+				goto out;
+			}
+			memcpy(wep->key[i], wl->key[i], wl->key_len[i]);
+		}
+
+		if (!have_key) {
+			pr_info("%s: all wep key disabled\n", __func__);
+			ret = -EINVAL;
+			goto out;
+		}
+
+		if (wep104) {
+			pr_debug("%s: 104bit key\n", __func__);
+			wep->security = cpu_to_be16(GELIC_EURUS_WEP_SEC_104BIT);
+		} else {
+			pr_debug("%s: 40bit key\n", __func__);
+			wep->security = cpu_to_be16(GELIC_EURUS_WEP_SEC_40BIT);
+		}
+	} else {
+		pr_debug("%s: NO encryption\n", __func__);
+		wep->security = cpu_to_be16(GELIC_EURUS_WEP_SEC_NONE);
+	}
+
+	/* issue wep setup */
+	cmd = gelic_eurus_sync_cmd(wl, GELIC_EURUS_CMD_SET_WEP_CFG,
+				   wep, sizeof(*wep));
+	if (!cmd)
+		ret = -ENOMEM;
+	else if (cmd->status || cmd->cmd_status)
+		ret = -ENXIO;
+
+	kfree(cmd);
+out:
+	pr_debug("%s: ->\n", __func__);
+	return ret;
+}
+
+#ifdef DEBUG
+static const char *wpasecstr(enum gelic_eurus_wpa_security sec)
+{
+	switch (sec) {
+	case GELIC_EURUS_WPA_SEC_NONE:
+		return "NONE";
+		break;
+	case GELIC_EURUS_WPA_SEC_WPA_TKIP_TKIP:
+		return "WPA_TKIP_TKIP";
+		break;
+	case GELIC_EURUS_WPA_SEC_WPA_TKIP_AES:
+		return "WPA_TKIP_AES";
+		break;
+	case GELIC_EURUS_WPA_SEC_WPA_AES_AES:
+		return "WPA_AES_AES";
+		break;
+	case GELIC_EURUS_WPA_SEC_WPA2_TKIP_TKIP:
+		return "WPA2_TKIP_TKIP";
+		break;
+	case GELIC_EURUS_WPA_SEC_WPA2_TKIP_AES:
+		return "WPA2_TKIP_AES";
+		break;
+	case GELIC_EURUS_WPA_SEC_WPA2_AES_AES:
+		return "WPA2_AES_AES";
+		break;
+	}
+	return "";
+};
+#endif
+
+static int gelic_wl_do_wpa_setup(struct gelic_wl_info *wl)
+{
+	struct gelic_eurus_wpa_cfg *wpa;
+	struct gelic_eurus_cmd *cmd;
+	u16 security;
+	int ret = 0;
+
+	pr_debug("%s: <-\n", __func__);
+	/* we can assume no one should uses the buffer */
+	wpa = wl->buf;
+	memset(wpa, 0, sizeof(*wpa));
+
+	if (!test_bit(GELIC_WL_STAT_WPA_PSK_SET, &wl->stat))
+		pr_info("%s: PSK not configured yet\n", __func__);
+
+	/* copy key */
+	memcpy(wpa->psk, wl->psk, wl->psk_len);
+
+	/* set security level */
+	if (wl->wpa_level == GELIC_WL_WPA_LEVEL_WPA2) {
+		if (wl->group_cipher_method == GELIC_WL_CIPHER_AES) {
+			security = GELIC_EURUS_WPA_SEC_WPA2_AES_AES;
+		} else {
+			if (wl->pairwise_cipher_method == GELIC_WL_CIPHER_AES &&
+			    precise_ie())
+				security = GELIC_EURUS_WPA_SEC_WPA2_TKIP_AES;
+			else
+				security = GELIC_EURUS_WPA_SEC_WPA2_TKIP_TKIP;
+		}
+	} else {
+		if (wl->group_cipher_method == GELIC_WL_CIPHER_AES) {
+			security = GELIC_EURUS_WPA_SEC_WPA_AES_AES;
+		} else {
+			if (wl->pairwise_cipher_method == GELIC_WL_CIPHER_AES &&
+			    precise_ie())
+				security = GELIC_EURUS_WPA_SEC_WPA_TKIP_AES;
+			else
+				security = GELIC_EURUS_WPA_SEC_WPA_TKIP_TKIP;
+		}
+	}
+	wpa->security = cpu_to_be16(security);
+
+	/* PSK type */
+	wpa->psk_type = cpu_to_be16(wl->psk_type);
+#ifdef DEBUG
+	pr_debug("%s: sec=%s psktype=%s\nn", __func__,
+		 wpasecstr(wpa->security),
+		 (wpa->psk_type == GELIC_EURUS_WPA_PSK_BIN) ?
+		 "BIN" : "passphrase");
+#if 0
+	/*
+	 * don't enable here if you plan to submit
+	 * the debug log because this dumps your precious
+	 * passphrase/key.
+	 */
+	pr_debug("%s: psk=%s\n",
+		 (wpa->psk_type == GELIC_EURUS_WPA_PSK_BIN) ?
+		 (char *)"N/A" : (char *)wpa->psk);
+#endif
+#endif
+	/* issue wpa setup */
+	cmd = gelic_eurus_sync_cmd(wl, GELIC_EURUS_CMD_SET_WPA_CFG,
+				   wpa, sizeof(*wpa));
+	if (!cmd)
+		ret = -ENOMEM;
+	else if (cmd->status || cmd->cmd_status)
+		ret = -ENXIO;
+	kfree(cmd);
+	pr_debug("%s: --> %d\n", __func__, ret);
+	return ret;
+}
+
+/*
+ * Start association. caller must hold assoc_stat_lock
+ */
+static int gelic_wl_associate_bss(struct gelic_wl_info *wl,
+				  struct gelic_wl_scan_info *bss)
+{
+	struct gelic_eurus_cmd *cmd;
+	struct gelic_eurus_common_cfg *common;
+	int ret = 0;
+	unsigned long rc;
+
+	pr_debug("%s: <-\n", __func__);
+
+	/* do common config */
+	common = wl->buf;
+	memset(common, 0, sizeof(*common));
+	common->bss_type = cpu_to_be16(GELIC_EURUS_BSS_INFRA);
+	common->op_mode = cpu_to_be16(GELIC_EURUS_OPMODE_11BG);
+
+	common->scan_index = cpu_to_be16(bss->eurus_index);
+	switch (wl->auth_method) {
+	case GELIC_EURUS_AUTH_OPEN:
+		common->auth_method = cpu_to_be16(GELIC_EURUS_AUTH_OPEN);
+		break;
+	case GELIC_EURUS_AUTH_SHARED:
+		common->auth_method = cpu_to_be16(GELIC_EURUS_AUTH_SHARED);
+		break;
+	}
+
+#ifdef DEBUG
+	scan_list_dump(wl);
+#endif
+	pr_debug("%s: common cfg index=%d bsstype=%d auth=%d\n", __func__,
+		 be16_to_cpu(common->scan_index),
+		 be16_to_cpu(common->bss_type),
+		 be16_to_cpu(common->auth_method));
+
+	cmd = gelic_eurus_sync_cmd(wl, GELIC_EURUS_CMD_SET_COMMON_CFG,
+				   common, sizeof(*common));
+	if (!cmd || cmd->status || cmd->cmd_status) {
+		ret = -ENOMEM;
+		kfree(cmd);
+		goto out;
+	}
+	kfree(cmd);
+
+	/* WEP/WPA */
+	switch (wl->wpa_level) {
+	case GELIC_WL_WPA_LEVEL_NONE:
+		/* If WEP or no security, setup WEP config */
+		ret = gelic_wl_do_wep_setup(wl);
+		break;
+	case GELIC_WL_WPA_LEVEL_WPA:
+	case GELIC_WL_WPA_LEVEL_WPA2:
+		ret = gelic_wl_do_wpa_setup(wl);
+		break;
+	};
+
+	if (ret) {
+		pr_debug("%s: WEP/WPA setup failed %d\n", __func__,
+			 ret);
+	}
+
+	/* start association */
+	init_completion(&wl->assoc_done);
+	wl->assoc_stat = GELIC_WL_ASSOC_STAT_ASSOCIATING;
+	cmd = gelic_eurus_sync_cmd(wl, GELIC_EURUS_CMD_ASSOC,
+				   NULL, 0);
+	if (!cmd || cmd->status || cmd->cmd_status) {
+		pr_debug("%s: assoc request failed\n", __func__);
+		wl->assoc_stat = GELIC_WL_ASSOC_STAT_DISCONN;
+		kfree(cmd);
+		ret = -ENOMEM;
+		gelic_wl_send_iwap_event(wl, NULL);
+		goto out;
+	}
+	kfree(cmd);
+
+	/* wait for connected event */
+	rc = wait_for_completion_timeout(&wl->assoc_done, HZ * 4);/*FIXME*/
+
+	if (!rc) {
+		/* timeouted.  Maybe key or cyrpt mode is wrong */
+		pr_info("%s: connect timeout \n", __func__);
+		cmd = gelic_eurus_sync_cmd(wl, GELIC_EURUS_CMD_DISASSOC,
+					   NULL, 0);
+		kfree(cmd);
+		wl->assoc_stat = GELIC_WL_ASSOC_STAT_DISCONN;
+		gelic_wl_send_iwap_event(wl, NULL);
+		ret = -ENXIO;
+	} else {
+		wl->assoc_stat = GELIC_WL_ASSOC_STAT_ASSOCIATED;
+		/* copy bssid */
+		memcpy(wl->active_bssid, &bss->hwinfo->bssid[2], ETH_ALEN);
+
+		/* send connect event */
+		gelic_wl_send_iwap_event(wl, wl->active_bssid);
+		pr_info("%s: connected\n", __func__);
+	}
+out:
+	pr_debug("%s: ->\n", __func__);
+	return ret;
+}
+
+/*
+ * connected event
+ */
+static void gelic_wl_connected_event(struct gelic_wl_info *wl,
+				     u64 event)
+{
+	u64 desired_event = 0;
+
+	switch (wl->wpa_level) {
+	case GELIC_WL_WPA_LEVEL_NONE:
+		desired_event = GELIC_LV1_WL_EVENT_CONNECTED;
+		break;
+	case GELIC_WL_WPA_LEVEL_WPA:
+	case GELIC_WL_WPA_LEVEL_WPA2:
+		desired_event = GELIC_LV1_WL_EVENT_WPA_CONNECTED;
+		break;
+	}
+
+	if (desired_event == event) {
+		pr_debug("%s: completed \n", __func__);
+		complete(&wl->assoc_done);
+		netif_carrier_on(port_to_netdev(wl_port(wl)));
+	} else
+		pr_debug("%s: event %#lx under wpa\n",
+				 __func__, event);
+}
+
+/*
+ * disconnect event
+ */
+static void gelic_wl_disconnect_event(struct gelic_wl_info *wl,
+				      u64 event)
+{
+	struct gelic_eurus_cmd *cmd;
+	int lock;
+
+	/*
+	 * If we fall here in the middle of association,
+	 * associate_bss() should be waiting for complation of
+	 * wl->assoc_done.
+	 * As it waits with timeout, just leave assoc_done
+	 * uncompleted, then it terminates with timeout
+	 */
+	if (down_trylock(&wl->assoc_stat_lock)) {
+		pr_debug("%s: already locked\n", __func__);
+		lock = 0;
+	} else {
+		pr_debug("%s: obtain lock\n", __func__);
+		lock = 1;
+	}
+
+	cmd = gelic_eurus_sync_cmd(wl, GELIC_EURUS_CMD_DISASSOC, NULL, 0);
+	kfree(cmd);
+
+	/* send disconnected event to the supplicant */
+	if (wl->assoc_stat == GELIC_WL_ASSOC_STAT_ASSOCIATED)
+		gelic_wl_send_iwap_event(wl, NULL);
+
+	wl->assoc_stat = GELIC_WL_ASSOC_STAT_DISCONN;
+	netif_carrier_off(port_to_netdev(wl_port(wl)));
+
+	if (lock)
+		up(&wl->assoc_stat_lock);
+}
+/*
+ * event worker
+ */
+#ifdef DEBUG
+static const char *eventstr(enum gelic_lv1_wl_event event)
+{
+	static char buf[32];
+	char *ret;
+	if (event & GELIC_LV1_WL_EVENT_DEVICE_READY)
+		ret = "EURUS_READY";
+	else if (event & GELIC_LV1_WL_EVENT_SCAN_COMPLETED)
+		ret = "SCAN_COMPLETED";
+	else if (event & GELIC_LV1_WL_EVENT_DEAUTH)
+		ret = "DEAUTH";
+	else if (event & GELIC_LV1_WL_EVENT_BEACON_LOST)
+		ret = "BEACON_LOST";
+	else if (event & GELIC_LV1_WL_EVENT_CONNECTED)
+		ret = "CONNECTED";
+	else if (event & GELIC_LV1_WL_EVENT_WPA_CONNECTED)
+		ret = "WPA_CONNECTED";
+	else if (event & GELIC_LV1_WL_EVENT_WPA_ERROR)
+		ret = "WPA_ERROR";
+	else {
+		sprintf(buf, "Unknown(%#x)", event);
+		ret = buf;
+	}
+	return ret;
+}
+#else
+static const char *eventstr(enum gelic_lv1_wl_event event)
+{
+	return NULL;
+}
+#endif
+static void gelic_wl_event_worker(struct work_struct *work)
+{
+	struct gelic_wl_info *wl;
+	struct gelic_port *port;
+	u64 event, tmp;
+	int status;
+
+	pr_debug("%s:start\n", __func__);
+	wl = container_of(work, struct gelic_wl_info, event_work.work);
+	port = wl_port(wl);
+	while (1) {
+		status = lv1_net_control(bus_id(port->card), dev_id(port->card),
+					 GELIC_LV1_GET_WLAN_EVENT, 0, 0, 0,
+					 &event, &tmp);
+		if (status) {
+			if (status != LV1_NO_ENTRY)
+				pr_debug("%s:wlan event failed %d\n",
+					 __func__, status);
+			/* got all events */
+			pr_debug("%s:end\n", __func__);
+			return;
+		}
+		pr_debug("%s: event=%s\n", __func__, eventstr(event));
+		switch (event) {
+		case GELIC_LV1_WL_EVENT_SCAN_COMPLETED:
+			gelic_wl_scan_complete_event(wl);
+			break;
+		case GELIC_LV1_WL_EVENT_BEACON_LOST:
+		case GELIC_LV1_WL_EVENT_DEAUTH:
+			gelic_wl_disconnect_event(wl, event);
+			break;
+		case GELIC_LV1_WL_EVENT_CONNECTED:
+		case GELIC_LV1_WL_EVENT_WPA_CONNECTED:
+			gelic_wl_connected_event(wl, event);
+			break;
+		default:
+			break;
+		}
+	} /* while */
+}
+/*
+ * association worker
+ */
+static void gelic_wl_assoc_worker(struct work_struct *work)
+{
+	struct gelic_wl_info *wl;
+
+	struct gelic_wl_scan_info *best_bss;
+	int ret;
+
+	wl = container_of(work, struct gelic_wl_info, assoc_work.work);
+
+	down(&wl->assoc_stat_lock);
+
+	if (wl->assoc_stat != GELIC_WL_ASSOC_STAT_DISCONN)
+		goto out;
+
+	ret = gelic_wl_start_scan(wl, 0);
+	if (ret == -ERESTARTSYS) {
+		pr_debug("%s: scan start failed association\n", __func__);
+		schedule_delayed_work(&wl->assoc_work, HZ/10); /*FIXME*/
+		goto out;
+	} else if (ret) {
+		pr_info("%s: scan prerequisite failed\n", __func__);
+		goto out;
+	}
+
+	/*
+	 * Wait for bss scan completion
+	 * If we have scan list already, gelic_wl_start_scan()
+	 * returns OK and raises the complete.  Thus,
+	 * it's ok to wait unconditionally here
+	 */
+	wait_for_completion(&wl->scan_done);
+
+	pr_debug("%s: scan done\n", __func__);
+	down(&wl->scan_lock);
+	if (wl->scan_stat != GELIC_WL_SCAN_STAT_GOT_LIST) {
+		gelic_wl_send_iwap_event(wl, NULL);
+		pr_info("%s: no scan list. association failed\n", __func__);
+		goto scan_lock_out;
+	}
+
+	/* find best matching bss */
+	best_bss = gelic_wl_find_best_bss(wl);
+	if (!best_bss) {
+		gelic_wl_send_iwap_event(wl, NULL);
+		pr_info("%s: no bss matched. association failed\n", __func__);
+		goto scan_lock_out;
+	}
+
+	/* ok, do association */
+	ret = gelic_wl_associate_bss(wl, best_bss);
+	if (ret)
+		pr_info("%s: association failed %d\n", __func__, ret);
+scan_lock_out:
+	up(&wl->scan_lock);
+out:
+	up(&wl->assoc_stat_lock);
+}
+/*
+ * Interrupt handler
+ * Called from the ethernet interrupt handler
+ * Processes wireless specific virtual interrupts only
+ */
+void gelic_wl_interrupt(struct net_device *netdev, u64 status)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+
+	if (status & GELIC_CARD_WLAN_COMMAND_COMPLETED) {
+		pr_debug("%s:cmd complete\n", __func__);
+		complete(&wl->cmd_done_intr);
+	}
+
+	if (status & GELIC_CARD_WLAN_EVENT_RECEIVED) {
+		pr_debug("%s:event received\n", __func__);
+		queue_delayed_work(wl->event_queue, &wl->event_work, 0);
+	}
+}
+
+/*
+ * driver helpers
+ */
+#define IW_IOCTL(n) [(n) - SIOCSIWCOMMIT]
+static const iw_handler gelic_wl_wext_handler[] =
+{
+	IW_IOCTL(SIOCGIWNAME)		= gelic_wl_get_name,
+	IW_IOCTL(SIOCGIWRANGE)		= gelic_wl_get_range,
+	IW_IOCTL(SIOCSIWSCAN)		= gelic_wl_set_scan,
+	IW_IOCTL(SIOCGIWSCAN)		= gelic_wl_get_scan,
+	IW_IOCTL(SIOCSIWAUTH)		= gelic_wl_set_auth,
+	IW_IOCTL(SIOCGIWAUTH)		= gelic_wl_get_auth,
+	IW_IOCTL(SIOCSIWESSID)		= gelic_wl_set_essid,
+	IW_IOCTL(SIOCGIWESSID)		= gelic_wl_get_essid,
+	IW_IOCTL(SIOCSIWENCODE)		= gelic_wl_set_encode,
+	IW_IOCTL(SIOCGIWENCODE)		= gelic_wl_get_encode,
+	IW_IOCTL(SIOCSIWAP)		= gelic_wl_set_ap,
+	IW_IOCTL(SIOCGIWAP)		= gelic_wl_get_ap,
+	IW_IOCTL(SIOCSIWENCODEEXT)	= gelic_wl_set_encodeext,
+	IW_IOCTL(SIOCGIWENCODEEXT)	= gelic_wl_get_encodeext,
+	IW_IOCTL(SIOCSIWMODE)		= gelic_wl_set_mode,
+	IW_IOCTL(SIOCGIWMODE)		= gelic_wl_get_mode,
+	IW_IOCTL(SIOCGIWNICKN)		= gelic_wl_get_nick,
+};
+
+static struct iw_priv_args gelic_wl_private_args[] =
+{
+	{
+		.cmd = GELIC_WL_PRIV_SET_PSK,
+		.set_args = IW_PRIV_TYPE_CHAR |
+		(GELIC_WL_EURUS_PSK_MAX_LEN + 2),
+		.name = "set_psk"
+	},
+	{
+		.cmd = GELIC_WL_PRIV_GET_PSK,
+		.get_args = IW_PRIV_TYPE_CHAR |
+		(GELIC_WL_EURUS_PSK_MAX_LEN + 2),
+		.name = "get_psk"
+	}
+};
+
+static const iw_handler gelic_wl_private_handler[] =
+{
+	gelic_wl_priv_set_psk,
+	gelic_wl_priv_get_psk,
+};
+
+static const struct iw_handler_def gelic_wl_wext_handler_def = {
+	.num_standard		= ARRAY_SIZE(gelic_wl_wext_handler),
+	.standard		= gelic_wl_wext_handler,
+	.get_wireless_stats	= gelic_wl_get_wireless_stats,
+	.num_private		= ARRAY_SIZE(gelic_wl_private_handler),
+	.num_private_args	= ARRAY_SIZE(gelic_wl_private_args),
+	.private		= gelic_wl_private_handler,
+	.private_args		= gelic_wl_private_args,
+};
+
+static struct net_device *gelic_wl_alloc(struct gelic_card *card)
+{
+	struct net_device *netdev;
+	struct gelic_port *port;
+	struct gelic_wl_info *wl;
+	unsigned int i;
+
+	pr_debug("%s:start\n", __func__);
+	netdev = alloc_etherdev(sizeof(struct gelic_port) +
+				sizeof(struct gelic_wl_info));
+	pr_debug("%s: netdev =%p card=%p \np", __func__, netdev, card);
+	if (!netdev)
+		return NULL;
+
+	port = netdev_priv(netdev);
+	port->netdev = netdev;
+	port->card = card;
+	port->type = GELIC_PORT_WIRELESS;
+
+	wl = port_wl(port);
+	pr_debug("%s: wl=%p port=%p\n", __func__, wl, port);
+
+	/* allocate scan list */
+	wl->networks = kzalloc(sizeof(struct gelic_wl_scan_info) *
+			       GELIC_WL_BSS_MAX_ENT, GFP_KERNEL);
+
+	if (!wl->networks)
+		goto fail_bss;
+
+	wl->eurus_cmd_queue = create_singlethread_workqueue("gelic_cmd");
+	if (!wl->eurus_cmd_queue)
+		goto fail_cmd_workqueue;
+
+	wl->event_queue = create_singlethread_workqueue("gelic_event");
+	if (!wl->event_queue)
+		goto fail_event_workqueue;
+
+	INIT_LIST_HEAD(&wl->network_free_list);
+	INIT_LIST_HEAD(&wl->network_list);
+	for (i = 0; i < GELIC_WL_BSS_MAX_ENT; i++)
+		list_add_tail(&wl->networks[i].list,
+			      &wl->network_free_list);
+	init_completion(&wl->cmd_done_intr);
+
+	INIT_DELAYED_WORK(&wl->event_work, gelic_wl_event_worker);
+	INIT_DELAYED_WORK(&wl->assoc_work, gelic_wl_assoc_worker);
+	init_MUTEX(&wl->scan_lock);
+	init_MUTEX(&wl->assoc_stat_lock);
+
+	init_completion(&wl->scan_done);
+	/* for the case that no scan request is issued and stop() is called */
+	complete(&wl->scan_done);
+
+	spin_lock_init(&wl->lock);
+
+	wl->scan_age = 5*HZ; /* FIXME */
+
+	/* buffer for receiving scanned list etc */
+	BUILD_BUG_ON(PAGE_SIZE <
+		     sizeof(struct gelic_eurus_scan_info) *
+		     GELIC_EURUS_MAX_SCAN);
+	wl->buf = (void *)get_zeroed_page(GFP_KERNEL);
+	if (!wl->buf) {
+		pr_info("%s:buffer allocation failed\n", __func__);
+		goto fail_getpage;
+	}
+	pr_debug("%s:end\n", __func__);
+	return netdev;
+
+fail_getpage:
+	destroy_workqueue(wl->event_queue);
+fail_event_workqueue:
+	destroy_workqueue(wl->eurus_cmd_queue);
+fail_cmd_workqueue:
+	kfree(wl->networks);
+fail_bss:
+	free_netdev(netdev);
+	pr_debug("%s:end error\n", __func__);
+	return NULL;
+
+}
+
+static void gelic_wl_free(struct gelic_wl_info *wl)
+{
+	struct gelic_wl_scan_info *scan_info;
+	unsigned int i;
+
+	pr_debug("%s: <-\n", __func__);
+
+	pr_debug("%s: destroy queues\n", __func__);
+	destroy_workqueue(wl->eurus_cmd_queue);
+	destroy_workqueue(wl->event_queue);
+
+	scan_info = wl->networks;
+	for (i = 0; i < GELIC_WL_BSS_MAX_ENT; i++, scan_info++)
+		kfree(scan_info->hwinfo);
+	kfree(wl->networks);
+
+	free_netdev(port_to_netdev(wl_port(wl)));
+
+	pr_debug("%s: ->\n", __func__);
+}
+
+static int gelic_wl_try_associate(struct net_device *netdev)
+{
+	struct gelic_wl_info *wl = port_wl(netdev_priv(netdev));
+	int ret = -1;
+	unsigned int i;
+
+	pr_debug("%s: <-\n", __func__);
+
+	/* check constraits for start association */
+	/* for no access restriction AP */
+	if (wl->group_cipher_method == GELIC_WL_CIPHER_NONE) {
+		if (test_bit(GELIC_WL_STAT_CONFIGURED,
+			     &wl->stat))
+			goto do_associate;
+		else {
+			pr_debug("%s: no wep, not configured\n", __func__);
+			return ret;
+		}
+	}
+
+	/* for WEP, one of four keys should be set */
+	if (wl->group_cipher_method == GELIC_WL_CIPHER_WEP) {
+		/* one of keys set */
+		for (i = 0; i < GELIC_WEP_KEYS; i++) {
+			if (test_bit(i, &wl->key_enabled))
+			    goto do_associate;
+		}
+		pr_debug("%s: WEP, but no key specified\n", __func__);
+		return ret;
+	}
+
+	/* for WPA[2], psk should be set */
+	if ((wl->group_cipher_method == GELIC_WL_CIPHER_TKIP) ||
+	    (wl->group_cipher_method == GELIC_WL_CIPHER_AES)) {
+		if (test_bit(GELIC_WL_STAT_WPA_PSK_SET,
+			     &wl->stat))
+			goto do_associate;
+		else {
+			pr_debug("%s: AES/TKIP, but PSK not configured\n",
+				 __func__);
+			return ret;
+		}
+	}
+
+do_associate:
+	ret = schedule_delayed_work(&wl->assoc_work, 0);
+	pr_debug("%s: start association work %d\n", __func__, ret);
+	return ret;
+}
+
+/*
+ * netdev handlers
+ */
+static int gelic_wl_open(struct net_device *netdev)
+{
+	struct gelic_card *card = netdev_card(netdev);
+
+	pr_debug("%s:->%p\n", __func__, netdev);
+
+	gelic_card_up(card);
+
+	/* try to associate */
+	gelic_wl_try_associate(netdev);
+
+	netif_start_queue(netdev);
+
+	pr_debug("%s:<-\n", __func__);
+	return 0;
+}
+
+/*
+ * reset state machine
+ */
+static int gelic_wl_reset_state(struct gelic_wl_info *wl)
+{
+	struct gelic_wl_scan_info *target;
+	struct gelic_wl_scan_info *tmp;
+
+	/* empty scan list */
+	list_for_each_entry_safe(target, tmp, &wl->network_list, list) {
+		list_move_tail(&target->list, &wl->network_free_list);
+	}
+	wl->scan_stat = GELIC_WL_SCAN_STAT_INIT;
+
+	/* clear configuration */
+	wl->auth_method = GELIC_EURUS_AUTH_OPEN;
+	wl->group_cipher_method = GELIC_WL_CIPHER_NONE;
+	wl->pairwise_cipher_method = GELIC_WL_CIPHER_NONE;
+	wl->wpa_level = GELIC_WL_WPA_LEVEL_NONE;
+
+	wl->key_enabled = 0;
+	wl->current_key = 0;
+
+	wl->psk_type = GELIC_EURUS_WPA_PSK_PASSPHRASE;
+	wl->psk_len = 0;
+
+	wl->essid_len = 0;
+	memset(wl->essid, 0, sizeof(wl->essid));
+	memset(wl->bssid, 0, sizeof(wl->bssid));
+	memset(wl->active_bssid, 0, sizeof(wl->active_bssid));
+
+	wl->assoc_stat = GELIC_WL_ASSOC_STAT_DISCONN;
+
+	memset(&wl->iwstat, 0, sizeof(wl->iwstat));
+	/* all status bit clear */
+	wl->stat = 0;
+	return 0;
+}
+
+/*
+ * Tell eurus to terminate association
+ */
+static void gelic_wl_disconnect(struct net_device *netdev)
+{
+	struct gelic_port *port = netdev_priv(netdev);
+	struct gelic_wl_info *wl = port_wl(port);
+	struct gelic_eurus_cmd *cmd;
+
+	/*
+	 * If scann process is running on chip,
+	 * further requests will be rejected
+	 */
+	if (wl->scan_stat == GELIC_WL_SCAN_STAT_SCANNING)
+		wait_for_completion_timeout(&wl->scan_done, HZ);
+
+	cmd = gelic_eurus_sync_cmd(wl, GELIC_EURUS_CMD_DISASSOC, NULL, 0);
+	kfree(cmd);
+	gelic_wl_send_iwap_event(wl, NULL);
+};
+
+static int gelic_wl_stop(struct net_device *netdev)
+{
+	struct gelic_port *port = netdev_priv(netdev);
+	struct gelic_wl_info *wl = port_wl(port);
+	struct gelic_card *card = netdev_card(netdev);
+
+	pr_debug("%s:<-\n", __func__);
+
+	/*
+	 * Cancel pending association work.
+	 * event work can run after netdev down
+	 */
+	cancel_delayed_work(&wl->assoc_work);
+
+	if (wl->assoc_stat == GELIC_WL_ASSOC_STAT_ASSOCIATED)
+		gelic_wl_disconnect(netdev);
+
+	/* reset our state machine */
+	gelic_wl_reset_state(wl);
+
+	netif_stop_queue(netdev);
+
+	gelic_card_down(card);
+
+	pr_debug("%s:->\n", __func__);
+	return 0;
+}
+
+/* -- */
+
+static struct ethtool_ops gelic_wl_ethtool_ops = {
+	.get_drvinfo	= gelic_net_get_drvinfo,
+	.get_link	= gelic_wl_get_link,
+	.get_tx_csum	= ethtool_op_get_tx_csum,
+	.set_tx_csum	= ethtool_op_set_tx_csum,
+	.get_rx_csum	= gelic_net_get_rx_csum,
+	.set_rx_csum	= gelic_net_set_rx_csum,
+};
+
+static void gelic_wl_setup_netdev_ops(struct net_device *netdev)
+{
+	struct gelic_wl_info *wl;
+	wl = port_wl(netdev_priv(netdev));
+	BUG_ON(!wl);
+	netdev->open = &gelic_wl_open;
+	netdev->stop = &gelic_wl_stop;
+	netdev->hard_start_xmit = &gelic_net_xmit;
+	netdev->set_multicast_list = &gelic_net_set_multi;
+	netdev->change_mtu = &gelic_net_change_mtu;
+	netdev->wireless_data = &wl->wireless_data;
+	netdev->wireless_handlers = &gelic_wl_wext_handler_def;
+	/* tx watchdog */
+	netdev->tx_timeout = &gelic_net_tx_timeout;
+	netdev->watchdog_timeo = GELIC_NET_WATCHDOG_TIMEOUT;
+
+	netdev->ethtool_ops = &gelic_wl_ethtool_ops;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller = gelic_net_poll_controller;
+#endif
+}
+
+/*
+ * driver probe/remove
+ */
+int gelic_wl_driver_probe(struct gelic_card *card)
+{
+	int ret;
+	struct net_device *netdev;
+
+	pr_debug("%s:start\n", __func__);
+
+	if (ps3_compare_firmware_version(1, 6, 0) < 0)
+		return 0;
+	if (!card->vlan[GELIC_PORT_WIRELESS].tx)
+		return 0;
+
+	/* alloc netdevice for wireless */
+	netdev = gelic_wl_alloc(card);
+	if (!netdev)
+		return -ENOMEM;
+
+	/* setup net_device structure */
+	gelic_wl_setup_netdev_ops(netdev);
+
+	/* setup some of net_device and register it */
+	ret = gelic_net_setup_netdev(netdev, card);
+	if (ret)
+		goto fail_setup;
+	card->netdev[GELIC_PORT_WIRELESS] = netdev;
+
+	/* add enable wireless interrupt */
+	card->irq_mask |= GELIC_CARD_WLAN_EVENT_RECEIVED |
+		GELIC_CARD_WLAN_COMMAND_COMPLETED;
+	/* to allow wireless commands while both interfaces are down */
+	gelic_card_set_irq_mask(card, GELIC_CARD_WLAN_EVENT_RECEIVED |
+				GELIC_CARD_WLAN_COMMAND_COMPLETED);
+	pr_debug("%s:end\n", __func__);
+	return 0;
+
+fail_setup:
+	gelic_wl_free(port_wl(netdev_port(netdev)));
+
+	return ret;
+}
+
+int gelic_wl_driver_remove(struct gelic_card *card)
+{
+	struct gelic_wl_info *wl;
+	struct net_device *netdev;
+
+	pr_debug("%s:start\n", __func__);
+
+	if (ps3_compare_firmware_version(1, 6, 0) < 0)
+		return 0;
+	if (!card->vlan[GELIC_PORT_WIRELESS].tx)
+		return 0;
+
+	netdev = card->netdev[GELIC_PORT_WIRELESS];
+	wl = port_wl(netdev_priv(netdev));
+
+	/* if the interface was not up, but associated */
+	if (wl->assoc_stat == GELIC_WL_ASSOC_STAT_ASSOCIATED)
+		gelic_wl_disconnect(netdev);
+
+	complete(&wl->cmd_done_intr);
+
+	/* cancel all work queue */
+	cancel_delayed_work(&wl->assoc_work);
+	cancel_delayed_work(&wl->event_work);
+	flush_workqueue(wl->eurus_cmd_queue);
+	flush_workqueue(wl->event_queue);
+
+	unregister_netdev(netdev);
+
+	/* disable wireless interrupt */
+	pr_debug("%s: disable intr\n", __func__);
+	card->irq_mask &= ~(GELIC_CARD_WLAN_EVENT_RECEIVED |
+			    GELIC_CARD_WLAN_COMMAND_COMPLETED);
+	/* free bss list, netdev*/
+	gelic_wl_free(wl);
+	pr_debug("%s:end\n", __func__);
+	return 0;
+}
diff --git a/drivers/net/ps3_gelic_wireless.h b/drivers/net/ps3_gelic_wireless.h
new file mode 100644
index 0000000..1036971
--- /dev/null
+++ b/drivers/net/ps3_gelic_wireless.h
@@ -0,0 +1,329 @@
+/*
+ *  PS3 gelic network driver.
+ *
+ * Copyright (C) 2007 Sony Computer Entertainment Inc.
+ * Copyright 2007 Sony Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation version 2.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#ifndef _GELIC_WIRELESS_H
+#define _GELIC_WIRELESS_H
+
+#include <linux/wireless.h>
+#include <net/iw_handler.h>
+
+
+/* return value from  GELIC_LV1_GET_WLAN_EVENT netcontrol */
+enum gelic_lv1_wl_event {
+	GELIC_LV1_WL_EVENT_DEVICE_READY   = 0x01, /* Eurus ready */
+	GELIC_LV1_WL_EVENT_SCAN_COMPLETED = 0x02, /* Scan has completed */
+	GELIC_LV1_WL_EVENT_DEAUTH         = 0x04, /* Deauthed by the AP */
+	GELIC_LV1_WL_EVENT_BEACON_LOST    = 0x08, /* Beacon lost detected */
+	GELIC_LV1_WL_EVENT_CONNECTED      = 0x10, /* Connected to AP */
+	GELIC_LV1_WL_EVENT_WPA_CONNECTED  = 0x20, /* WPA connection */
+	GELIC_LV1_WL_EVENT_WPA_ERROR      = 0x40, /* MIC error */
+};
+
+/* arguments for GELIC_LV1_POST_WLAN_COMMAND netcontrol */
+enum gelic_eurus_command {
+	GELIC_EURUS_CMD_ASSOC		=  1, /* association start */
+	GELIC_EURUS_CMD_DISASSOC	=  2, /* disassociate      */
+	GELIC_EURUS_CMD_START_SCAN	=  3, /* scan start        */
+	GELIC_EURUS_CMD_GET_SCAN	=  4, /* get scan result   */
+	GELIC_EURUS_CMD_SET_COMMON_CFG	=  5, /* set common config */
+	GELIC_EURUS_CMD_GET_COMMON_CFG	=  6, /* set common config */
+	GELIC_EURUS_CMD_SET_WEP_CFG	=  7, /* set WEP config    */
+	GELIC_EURUS_CMD_GET_WEP_CFG	=  8, /* get WEP config    */
+	GELIC_EURUS_CMD_SET_WPA_CFG	=  9, /* set WPA config    */
+	GELIC_EURUS_CMD_GET_WPA_CFG	= 10, /* get WPA config    */
+	GELIC_EURUS_CMD_GET_RSSI_CFG	= 11, /* get RSSI info.    */
+	GELIC_EURUS_CMD_MAX_INDEX
+};
+
+/* for GELIC_EURUS_CMD_COMMON_CFG */
+enum gelic_eurus_bss_type {
+	GELIC_EURUS_BSS_INFRA = 0,
+	GELIC_EURUS_BSS_ADHOC = 1, /* not supported */
+};
+
+enum gelic_eurus_auth_method {
+	GELIC_EURUS_AUTH_OPEN = 0, /* FIXME: WLAN_AUTH_OPEN */
+	GELIC_EURUS_AUTH_SHARED = 1, /* not supported */
+};
+
+enum gelic_eurus_opmode {
+	GELIC_EURUS_OPMODE_11BG = 0, /* 802.11b/g */
+	GELIC_EURUS_OPMODE_11B = 1, /* 802.11b only */
+	GELIC_EURUS_OPMODE_11G = 2, /* 802.11g only */
+};
+
+struct gelic_eurus_common_cfg {
+	/* all fields are big endian */
+	u16 scan_index;
+	u16 bss_type;    /* infra or adhoc */
+	u16 auth_method; /* shared key or open */
+	u16 op_mode; /* B/G */
+} __attribute__((packed));
+
+
+/* for GELIC_EURUS_CMD_WEP_CFG */
+enum gelic_eurus_wep_security {
+	GELIC_EURUS_WEP_SEC_NONE	= 0,
+	GELIC_EURUS_WEP_SEC_40BIT	= 1,
+	GELIC_EURUS_WEP_SEC_104BIT	= 2,
+};
+
+struct gelic_eurus_wep_cfg {
+	/* all fields are big endian */
+	u16 security;
+	u8 key[4][16];
+} __attribute__((packed));
+
+/* for GELIC_EURUS_CMD_WPA_CFG */
+enum gelic_eurus_wpa_security {
+	GELIC_EURUS_WPA_SEC_NONE		= 0x0000,
+	/* group=TKIP, pairwise=TKIP */
+	GELIC_EURUS_WPA_SEC_WPA_TKIP_TKIP	= 0x0001,
+	/* group=AES, pairwise=AES */
+	GELIC_EURUS_WPA_SEC_WPA_AES_AES		= 0x0002,
+	/* group=TKIP, pairwise=TKIP */
+	GELIC_EURUS_WPA_SEC_WPA2_TKIP_TKIP	= 0x0004,
+	/* group=AES, pairwise=AES */
+	GELIC_EURUS_WPA_SEC_WPA2_AES_AES	= 0x0008,
+	/* group=TKIP, pairwise=AES */
+	GELIC_EURUS_WPA_SEC_WPA_TKIP_AES	= 0x0010,
+	/* group=TKIP, pairwise=AES */
+	GELIC_EURUS_WPA_SEC_WPA2_TKIP_AES	= 0x0020,
+};
+
+enum gelic_eurus_wpa_psk_type {
+	GELIC_EURUS_WPA_PSK_PASSPHRASE	= 0, /* passphrase string   */
+	GELIC_EURUS_WPA_PSK_BIN		= 1, /* 32 bytes binary key */
+};
+
+#define GELIC_WL_EURUS_PSK_MAX_LEN	64
+#define WPA_PSK_LEN			32 /* WPA spec says 256bit */
+
+struct gelic_eurus_wpa_cfg {
+	/* all fields are big endian */
+	u16 security;
+	u16 psk_type; /* psk key encoding type */
+	u8 psk[GELIC_WL_EURUS_PSK_MAX_LEN]; /* psk key; hex or passphrase */
+} __attribute__((packed));
+
+/* for GELIC_EURUS_CMD_{START,GET}_SCAN */
+enum gelic_eurus_scan_capability {
+	GELIC_EURUS_SCAN_CAP_ADHOC	= 0x0000,
+	GELIC_EURUS_SCAN_CAP_INFRA	= 0x0001,
+	GELIC_EURUS_SCAN_CAP_MASK	= 0x0001,
+};
+
+enum gelic_eurus_scan_sec_type {
+	GELIC_EURUS_SCAN_SEC_NONE	= 0x0000,
+	GELIC_EURUS_SCAN_SEC_WEP	= 0x0100,
+	GELIC_EURUS_SCAN_SEC_WPA	= 0x0200,
+	GELIC_EURUS_SCAN_SEC_WPA2	= 0x0400,
+	GELIC_EURUS_SCAN_SEC_MASK	= 0x0f00,
+};
+
+enum gelic_eurus_scan_sec_wep_type {
+	GELIC_EURUS_SCAN_SEC_WEP_UNKNOWN	= 0x0000,
+	GELIC_EURUS_SCAN_SEC_WEP_40		= 0x0001,
+	GELIC_EURUS_SCAN_SEC_WEP_104		= 0x0002,
+	GELIC_EURUS_SCAN_SEC_WEP_MASK		= 0x0003,
+};
+
+enum gelic_eurus_scan_sec_wpa_type {
+	GELIC_EURUS_SCAN_SEC_WPA_UNKNOWN	= 0x0000,
+	GELIC_EURUS_SCAN_SEC_WPA_TKIP		= 0x0001,
+	GELIC_EURUS_SCAN_SEC_WPA_AES		= 0x0002,
+	GELIC_EURUS_SCAN_SEC_WPA_MASK		= 0x0003,
+};
+
+/*
+ * hw BSS information structure returned from GELIC_EURUS_CMD_GET_SCAN
+ */
+struct gelic_eurus_scan_info {
+	/* all fields are big endian */
+	__be16 size;
+	__be16 rssi; /* percentage */
+	__be16 channel; /* channel number */
+	__be16 beacon_period; /* FIXME: in msec unit */
+	__be16 capability;
+	__be16 security;
+	u8  bssid[8]; /* last ETH_ALEN are valid. bssid[0],[1] are unused */
+	u8  essid[32]; /* IW_ESSID_MAX_SIZE */
+	u8  rate[16]; /* first MAX_RATES_LENGTH(12) are valid */
+	u8  ext_rate[16]; /* first MAX_RATES_EX_LENGTH(16) are valid */
+	__be32 reserved1;
+	__be32 reserved2;
+	__be32 reserved3;
+	__be32 reserved4;
+	u8 elements[0]; /* ie */
+} __attribute__ ((packed));
+
+/* the hypervisor returns bbs up to 16 */
+#define GELIC_EURUS_MAX_SCAN  (16)
+struct gelic_wl_scan_info {
+	struct list_head list;
+	struct gelic_eurus_scan_info *hwinfo;
+
+	int valid; /* set 1 if this entry was in latest scanned list
+		     * from Eurus */
+	unsigned int eurus_index; /* index in the Eurus list */
+	unsigned long last_scanned; /* acquired time */
+
+	unsigned int rate_len;
+	unsigned int rate_ext_len;
+	unsigned int essid_len;
+};
+
+/* for GELIC_EURUS_CMD_GET_RSSI */
+struct gelic_eurus_rssi_info {
+	/* big endian */
+	__be16 rssi;
+} __attribute__ ((packed));
+
+
+/* for 'stat' member of gelic_wl_info */
+enum gelic_wl_info_status_bit {
+	GELIC_WL_STAT_CONFIGURED,
+	GELIC_WL_STAT_CH_INFO,   /* ch info aquired */
+	GELIC_WL_STAT_ESSID_SET, /* ESSID specified by userspace */
+	GELIC_WL_STAT_BSSID_SET, /* BSSID specified by userspace */
+	GELIC_WL_STAT_WPA_PSK_SET, /* PMK specified by userspace */
+	GELIC_WL_STAT_WPA_LEVEL_SET, /* WEP or WPA[2] selected */
+};
+
+/* for 'scan_stat' member of gelic_wl_info */
+enum gelic_wl_scan_state {
+	/* just initialized or get last scan result failed */
+	GELIC_WL_SCAN_STAT_INIT,
+	/* scan request issued, accepted or chip is scanning */
+	GELIC_WL_SCAN_STAT_SCANNING,
+	/* scan results retrieved */
+	GELIC_WL_SCAN_STAT_GOT_LIST,
+};
+
+/* for 'cipher_method' */
+enum gelic_wl_cipher_method {
+	GELIC_WL_CIPHER_NONE,
+	GELIC_WL_CIPHER_WEP,
+	GELIC_WL_CIPHER_TKIP,
+	GELIC_WL_CIPHER_AES,
+};
+
+/* for 'wpa_level' */
+enum gelic_wl_wpa_level {
+	GELIC_WL_WPA_LEVEL_NONE,
+	GELIC_WL_WPA_LEVEL_WPA,
+	GELIC_WL_WPA_LEVEL_WPA2,
+};
+
+/* for 'assoc_stat' */
+enum gelic_wl_assoc_state {
+	GELIC_WL_ASSOC_STAT_DISCONN,
+	GELIC_WL_ASSOC_STAT_ASSOCIATING,
+	GELIC_WL_ASSOC_STAT_ASSOCIATED,
+};
+/* part of private data alloc_etherdev() allocated */
+#define GELIC_WEP_KEYS 4
+struct gelic_wl_info {
+	/* bss list */
+	struct semaphore scan_lock;
+	struct list_head network_list;
+	struct list_head network_free_list;
+	struct gelic_wl_scan_info *networks;
+
+	unsigned long scan_age; /* last scanned time */
+	enum gelic_wl_scan_state scan_stat;
+	struct completion scan_done;
+
+	/* eurus command queue */
+	struct workqueue_struct *eurus_cmd_queue;
+	struct completion cmd_done_intr;
+
+	/* eurus event handling */
+	struct workqueue_struct *event_queue;
+	struct delayed_work event_work;
+
+	/* wl status bits */
+	unsigned long stat;
+	enum gelic_eurus_auth_method auth_method; /* open/shared */
+	enum gelic_wl_cipher_method group_cipher_method;
+	enum gelic_wl_cipher_method pairwise_cipher_method;
+	enum gelic_wl_wpa_level wpa_level; /* wpa/wpa2 */
+
+	/* association handling */
+	struct semaphore assoc_stat_lock;
+	struct delayed_work assoc_work;
+	enum gelic_wl_assoc_state assoc_stat;
+	struct completion assoc_done;
+
+	spinlock_t lock;
+	u16 ch_info; /* available channels. bit0 = ch1 */
+	/* WEP keys */
+	u8 key[GELIC_WEP_KEYS][IW_ENCODING_TOKEN_MAX];
+	unsigned long key_enabled;
+	unsigned int key_len[GELIC_WEP_KEYS];
+	unsigned int current_key;
+	/* WWPA PSK */
+	u8 psk[GELIC_WL_EURUS_PSK_MAX_LEN];
+	enum gelic_eurus_wpa_psk_type psk_type;
+	unsigned int psk_len;
+
+	u8 essid[IW_ESSID_MAX_SIZE];
+	u8 bssid[ETH_ALEN]; /* userland requested */
+	u8 active_bssid[ETH_ALEN]; /* associated bssid */
+	unsigned int essid_len;
+
+	/* buffer for hypervisor IO */
+	void *buf;
+
+	struct iw_public_data wireless_data;
+	struct iw_statistics iwstat;
+};
+
+#define GELIC_WL_BSS_MAX_ENT 32
+#define GELIC_WL_ASSOC_RETRY 50
+static inline struct gelic_port *wl_port(struct gelic_wl_info *wl)
+{
+	return container_of((void *)wl, struct gelic_port, priv);
+}
+static inline struct gelic_wl_info *port_wl(struct gelic_port *port)
+{
+	return port_priv(port);
+}
+
+struct gelic_eurus_cmd {
+	struct work_struct work;
+	struct gelic_wl_info *wl;
+	unsigned int cmd; /* command code */
+	u64 tag;
+	u64 size;
+	void *buffer;
+	unsigned int buf_size;
+	struct completion done;
+	int status;
+	u64 cmd_status;
+};
+
+/* private ioctls to pass PSK */
+#define GELIC_WL_PRIV_SET_PSK		(SIOCIWFIRSTPRIV + 0)
+#define GELIC_WL_PRIV_GET_PSK		(SIOCIWFIRSTPRIV + 1)
+
+extern int gelic_wl_driver_probe(struct gelic_card *card);
+extern int gelic_wl_driver_remove(struct gelic_card *card);
+extern void gelic_wl_interrupt(struct net_device *netdev, u64 status);
+#endif /* _GELIC_WIRELESS_H */
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 2334f4e..19184e4 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -61,7 +61,6 @@
 
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT	(6000 * HZ / 1000)
-#define TIMER_WUT	(jiffies + HZ * 1)/* timer wakeup time : 1 second */
 
 /* RDC MAC I/O Size */
 #define R6040_IO_SIZE	256
@@ -174,8 +173,6 @@ struct r6040_private {
 	struct net_device *dev;
 	struct mii_if_info mii_if;
 	struct napi_struct napi;
-	struct net_device_stats stats;
-	u16	napi_rx_running;
 	void __iomem *base;
 };
 
@@ -235,17 +232,53 @@ static void mdio_write(struct net_device *dev, int mii_id, int reg, int val)
 	phy_write(ioaddr, lp->phy_addr, reg, val);
 }
 
-static void r6040_tx_timeout(struct net_device *dev)
+static void r6040_free_txbufs(struct net_device *dev)
 {
-	struct r6040_private *priv = netdev_priv(dev);
+	struct r6040_private *lp = netdev_priv(dev);
+	int i;
 
-	disable_irq(dev->irq);
-	napi_disable(&priv->napi);
-	spin_lock(&priv->lock);
-	dev->stats.tx_errors++;
-	spin_unlock(&priv->lock);
+	for (i = 0; i < TX_DCNT; i++) {
+		if (lp->tx_insert_ptr->skb_ptr) {
+			pci_unmap_single(lp->pdev, lp->tx_insert_ptr->buf,
+				MAX_BUF_SIZE, PCI_DMA_TODEVICE);
+			dev_kfree_skb(lp->tx_insert_ptr->skb_ptr);
+			lp->rx_insert_ptr->skb_ptr = NULL;
+		}
+		lp->tx_insert_ptr = lp->tx_insert_ptr->vndescp;
+	}
+}
 
-	netif_stop_queue(dev);
+static void r6040_free_rxbufs(struct net_device *dev)
+{
+	struct r6040_private *lp = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < RX_DCNT; i++) {
+		if (lp->rx_insert_ptr->skb_ptr) {
+			pci_unmap_single(lp->pdev, lp->rx_insert_ptr->buf,
+				MAX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(lp->rx_insert_ptr->skb_ptr);
+			lp->rx_insert_ptr->skb_ptr = NULL;
+		}
+		lp->rx_insert_ptr = lp->rx_insert_ptr->vndescp;
+	}
+}
+
+static void r6040_init_ring_desc(struct r6040_descriptor *desc_ring,
+				 dma_addr_t desc_dma, int size)
+{
+	struct r6040_descriptor *desc = desc_ring;
+	dma_addr_t mapping = desc_dma;
+
+	while (size-- > 0) {
+		mapping += sizeof(sizeof(*desc));
+		desc->ndesc = cpu_to_le32(mapping);
+		desc->vndescp = desc + 1;
+		desc++;
+	}
+	desc--;
+	desc->ndesc = cpu_to_le32(desc_dma);
+	desc->vndescp = desc_ring;
 }
 
 /* Allocate skb buffer for rx descriptor */
@@ -256,7 +289,7 @@ static void rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 
 	descptr = lp->rx_insert_ptr;
 	while (lp->rx_free_desc < RX_DCNT) {
-		descptr->skb_ptr = dev_alloc_skb(MAX_BUF_SIZE);
+		descptr->skb_ptr = netdev_alloc_skb(dev, MAX_BUF_SIZE);
 
 		if (!descptr->skb_ptr)
 			break;
@@ -272,6 +305,63 @@ static void rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
 	lp->rx_insert_ptr = descptr;
 }
 
+static void r6040_alloc_txbufs(struct net_device *dev)
+{
+	struct r6040_private *lp = netdev_priv(dev);
+	void __iomem *ioaddr = lp->base;
+
+	lp->tx_free_desc = TX_DCNT;
+
+	lp->tx_remove_ptr = lp->tx_insert_ptr = lp->tx_ring;
+	r6040_init_ring_desc(lp->tx_ring, lp->tx_ring_dma, TX_DCNT);
+
+	iowrite16(lp->tx_ring_dma, ioaddr + MTD_SA0);
+	iowrite16(lp->tx_ring_dma >> 16, ioaddr + MTD_SA1);
+}
+
+static void r6040_alloc_rxbufs(struct net_device *dev)
+{
+	struct r6040_private *lp = netdev_priv(dev);
+	void __iomem *ioaddr = lp->base;
+
+	lp->rx_free_desc = 0;
+
+	lp->rx_remove_ptr = lp->rx_insert_ptr = lp->rx_ring;
+	r6040_init_ring_desc(lp->rx_ring, lp->rx_ring_dma, RX_DCNT);
+
+	rx_buf_alloc(lp, dev);
+
+	iowrite16(lp->rx_ring_dma, ioaddr + MRD_SA0);
+	iowrite16(lp->rx_ring_dma >> 16, ioaddr + MRD_SA1);
+}
+
+static void r6040_tx_timeout(struct net_device *dev)
+{
+	struct r6040_private *priv = netdev_priv(dev);
+	void __iomem *ioaddr = priv->base;
+
+	printk(KERN_WARNING "%s: transmit timed out, status %4.4x, PHY status "
+		"%4.4x\n",
+		dev->name, ioread16(ioaddr + MIER),
+		mdio_read(dev, priv->mii_if.phy_id, MII_BMSR));
+
+	disable_irq(dev->irq);
+	napi_disable(&priv->napi);
+	spin_lock(&priv->lock);
+	/* Clear all descriptors */
+	r6040_free_txbufs(dev);
+	r6040_free_rxbufs(dev);
+	r6040_alloc_txbufs(dev);
+	r6040_alloc_rxbufs(dev);
+
+	/* Reset MAC */
+	iowrite16(MAC_RST, ioaddr + MCR1);
+	spin_unlock(&priv->lock);
+	enable_irq(dev->irq);
+
+	dev->stats.tx_errors++;
+	netif_wake_queue(dev);
+}
 
 static struct net_device_stats *r6040_get_stats(struct net_device *dev)
 {
@@ -280,11 +370,11 @@ static struct net_device_stats *r6040_get_stats(struct net_device *dev)
 	unsigned long flags;
 
 	spin_lock_irqsave(&priv->lock, flags);
-	priv->stats.rx_crc_errors += ioread8(ioaddr + ME_CNT1);
-	priv->stats.multicast += ioread8(ioaddr + ME_CNT0);
+	dev->stats.rx_crc_errors += ioread8(ioaddr + ME_CNT1);
+	dev->stats.multicast += ioread8(ioaddr + ME_CNT0);
 	spin_unlock_irqrestore(&priv->lock, flags);
 
-	return &priv->stats;
+	return &dev->stats;
 }
 
 /* Stop RDC MAC and Free the allocated resource */
@@ -293,7 +383,6 @@ static void r6040_down(struct net_device *dev)
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	struct pci_dev *pdev = lp->pdev;
-	int i;
 	int limit = 2048;
 	u16 *adrp;
 	u16 cmd;
@@ -313,27 +402,12 @@ static void r6040_down(struct net_device *dev)
 	iowrite16(adrp[1], ioaddr + MID_0M);
 	iowrite16(adrp[2], ioaddr + MID_0H);
 	free_irq(dev->irq, dev);
+
 	/* Free RX buffer */
-	for (i = 0; i < RX_DCNT; i++) {
-		if (lp->rx_insert_ptr->skb_ptr) {
-			pci_unmap_single(lp->pdev, lp->rx_insert_ptr->buf,
-				MAX_BUF_SIZE, PCI_DMA_FROMDEVICE);
-			dev_kfree_skb(lp->rx_insert_ptr->skb_ptr);
-			lp->rx_insert_ptr->skb_ptr = NULL;
-		}
-		lp->rx_insert_ptr = lp->rx_insert_ptr->vndescp;
-	}
+	r6040_free_rxbufs(dev);
 
 	/* Free TX buffer */
-	for (i = 0; i < TX_DCNT; i++) {
-		if (lp->tx_insert_ptr->skb_ptr) {
-			pci_unmap_single(lp->pdev, lp->tx_insert_ptr->buf,
-				MAX_BUF_SIZE, PCI_DMA_TODEVICE);
-			dev_kfree_skb(lp->tx_insert_ptr->skb_ptr);
-			lp->rx_insert_ptr->skb_ptr = NULL;
-		}
-		lp->tx_insert_ptr = lp->tx_insert_ptr->vndescp;
-	}
+	r6040_free_txbufs(dev);
 
 	/* Free Descriptor memory */
 	pci_free_consistent(pdev, RX_DESC_SIZE, lp->rx_ring, lp->rx_ring_dma);
@@ -432,19 +506,24 @@ static int r6040_rx(struct net_device *dev, int limit)
 
 		/* Check for errors */
 		err = ioread16(ioaddr + MLSR);
-		if (err & 0x0400) priv->stats.rx_errors++;
+		if (err & 0x0400)
+			dev->stats.rx_errors++;
 		/* RX FIFO over-run */
-		if (err & 0x8000) priv->stats.rx_fifo_errors++;
+		if (err & 0x8000)
+			dev->stats.rx_fifo_errors++;
 		/* RX descriptor unavailable */
-		if (err & 0x0080) priv->stats.rx_frame_errors++;
+		if (err & 0x0080)
+			dev->stats.rx_frame_errors++;
 		/* Received packet with length over buffer lenght */
-		if (err & 0x0020) priv->stats.rx_over_errors++;
+		if (err & 0x0020)
+			dev->stats.rx_over_errors++;
 		/* Received packet with too long or short */
-		if (err & (0x0010|0x0008)) priv->stats.rx_length_errors++;
+		if (err & (0x0010 | 0x0008))
+			dev->stats.rx_length_errors++;
 		/* Received packet with CRC errors */
 		if (err & 0x0004) {
 			spin_lock(&priv->lock);
-			priv->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 			spin_unlock(&priv->lock);
 		}
 
@@ -469,8 +548,8 @@ static int r6040_rx(struct net_device *dev, int limit)
 			/* Send to upper layer */
 			netif_receive_skb(skb_ptr);
 			dev->last_rx = jiffies;
-			priv->dev->stats.rx_packets++;
-			priv->dev->stats.rx_bytes += descptr->len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += descptr->len;
 			/* To next descriptor */
 			descptr = descptr->vndescp;
 			priv->rx_free_desc--;
@@ -498,11 +577,13 @@ static void r6040_tx(struct net_device *dev)
 		/* Check for errors */
 		err = ioread16(ioaddr + MLSR);
 
-		if (err & 0x0200) priv->stats.rx_fifo_errors++;
-		if (err & (0x2000 | 0x4000)) priv->stats.tx_carrier_errors++;
+		if (err & 0x0200)
+			dev->stats.rx_fifo_errors++;
+		if (err & (0x2000 | 0x4000))
+			dev->stats.tx_carrier_errors++;
 
 		if (descptr->status & 0x8000)
-			break; /* Not complte */
+			break; /* Not complete */
 		skb_ptr = descptr->skb_ptr;
 		pci_unmap_single(priv->pdev, descptr->buf,
 			skb_ptr->len, PCI_DMA_TODEVICE);
@@ -545,7 +626,6 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	u16 status;
-	int handled = 1;
 
 	/* Mask off RDC MAC interrupt */
 	iowrite16(MSK_INT, ioaddr + MIER);
@@ -565,7 +645,7 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 	if (status & 0x10)
 		r6040_tx(dev);
 
-	return IRQ_RETVAL(handled);
+	return IRQ_HANDLED;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -577,53 +657,15 @@ static void r6040_poll_controller(struct net_device *dev)
 }
 #endif
 
-static void r6040_init_ring_desc(struct r6040_descriptor *desc_ring,
-				 dma_addr_t desc_dma, int size)
-{
-	struct r6040_descriptor *desc = desc_ring;
-	dma_addr_t mapping = desc_dma;
-
-	while (size-- > 0) {
-		mapping += sizeof(sizeof(*desc));
-		desc->ndesc = cpu_to_le32(mapping);
-		desc->vndescp = desc + 1;
-		desc++;
-	}
-	desc--;
-	desc->ndesc = cpu_to_le32(desc_dma);
-	desc->vndescp = desc_ring;
-}
-
 /* Init RDC MAC */
 static void r6040_up(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 
-	/* Initialize */
-	lp->tx_free_desc = TX_DCNT;
-	lp->rx_free_desc = 0;
-	/* Init descriptor */
-	lp->tx_remove_ptr = lp->tx_insert_ptr = lp->tx_ring;
-	lp->rx_remove_ptr = lp->rx_insert_ptr = lp->rx_ring;
-	/* Init TX descriptor */
-	r6040_init_ring_desc(lp->tx_ring, lp->tx_ring_dma, TX_DCNT);
-
-	/* Init RX descriptor */
-	r6040_init_ring_desc(lp->rx_ring, lp->rx_ring_dma, RX_DCNT);
-
-	/* Allocate buffer for RX descriptor */
-	rx_buf_alloc(lp, dev);
-
-	/*
-	 * TX and RX descriptor start registers.
-	 * Lower 16-bits to MxD_SA0. Higher 16-bits to MxD_SA1.
-	 */
-	iowrite16(lp->tx_ring_dma, ioaddr + MTD_SA0);
-	iowrite16(lp->tx_ring_dma >> 16, ioaddr + MTD_SA1);
-
-	iowrite16(lp->rx_ring_dma, ioaddr + MRD_SA0);
-	iowrite16(lp->rx_ring_dma >> 16, ioaddr + MRD_SA1);
+	/* Initialise and alloc RX/TX buffers */
+	r6040_alloc_txbufs(dev);
+	r6040_alloc_rxbufs(dev);
 
 	/* Buffer Size Register */
 	iowrite16(MAX_BUF_SIZE, ioaddr + MR_BSR);
@@ -689,8 +731,7 @@ static void r6040_timer(unsigned long data)
 	}
 
 	/* Timer active again */
-	lp->timer.expires = TIMER_WUT;
-	add_timer(&lp->timer);
+	mod_timer(&lp->timer, jiffies + round_jiffies(HZ));
 }
 
 /* Read/set MAC address routines */
@@ -746,14 +787,10 @@ static int r6040_open(struct net_device *dev)
 	napi_enable(&lp->napi);
 	netif_start_queue(dev);
 
-	if (lp->switch_sig != ICPLUS_PHY_ID) {
-		/* set and active a timer process */
-		init_timer(&lp->timer);
-		lp->timer.expires = TIMER_WUT;
-		lp->timer.data = (unsigned long)dev;
-		lp->timer.function = &r6040_timer;
-		add_timer(&lp->timer);
-	}
+	/* set and active a timer process */
+	setup_timer(&lp->timer, r6040_timer, (unsigned long) dev);
+	if (lp->switch_sig != ICPLUS_PHY_ID)
+		mod_timer(&lp->timer, jiffies + HZ);
 	return 0;
 }
 
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 2e9e88b..202fdf3 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1630,7 +1630,8 @@ static inline void sis190_init_rxfilter(struct net_device *dev)
 	SIS_PCI_COMMIT();
 }
 
-static int sis190_get_mac_addr(struct pci_dev *pdev, struct net_device *dev)
+static int __devinit sis190_get_mac_addr(struct pci_dev *pdev, 
+					 struct net_device *dev)
 {
 	u8 from;
 
diff --git a/drivers/s390/net/claw.h b/drivers/s390/net/claw.h
index 1ee9a6f..1a89d98 100644
--- a/drivers/s390/net/claw.h
+++ b/drivers/s390/net/claw.h
@@ -114,11 +114,20 @@ do { \
 	debug_event(claw_dbf_##name,level,(void*)(addr),len); \
 } while (0)
 
+/* Allow to sort out low debug levels early to avoid wasted sprints */
+static inline int claw_dbf_passes(debug_info_t *dbf_grp, int level)
+{
+	return (level <= dbf_grp->level);
+}
+
 #define CLAW_DBF_TEXT_(level,name,text...) \
-do {                                       \
-	sprintf(debug_buffer, text);  \
-		debug_text_event(claw_dbf_##name,level, debug_buffer);\
-} while (0)
+	do { \
+		if (claw_dbf_passes(claw_dbf_##name, level)) { \
+			sprintf(debug_buffer, text); \
+			debug_text_event(claw_dbf_##name, level, \
+						debug_buffer); \
+		} \
+	} while (0)
 
 /*******************************************************
 *  Define Control Blocks                               *
@@ -278,8 +287,6 @@ struct claw_env {
         __u16                   write_size;     /* write buffer size */
         __u16                   dev_id;         /* device ident */
 	__u8			packing;	/* are we packing? */
-	volatile __u8		queme_switch;   /* gate for imed packing  */
-	volatile unsigned long	pk_delay;	/* Delay for adaptive packing */
         __u8                    in_use;         /* device active flag */
         struct net_device       *ndev;    	/* backward ptr to the net dev*/
 };
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index 7bfe8d7..f51ed99 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -94,7 +94,7 @@ static int
 lcs_register_debug_facility(void)
 {
 	lcs_dbf_setup = debug_register("lcs_setup", 2, 1, 8);
-	lcs_dbf_trace = debug_register("lcs_trace", 2, 2, 8);
+	lcs_dbf_trace = debug_register("lcs_trace", 4, 1, 8);
 	if (lcs_dbf_setup == NULL || lcs_dbf_trace == NULL) {
 		PRINT_ERR("Not enough memory for debug facility.\n");
 		lcs_unregister_debug_facility();
diff --git a/drivers/s390/net/lcs.h b/drivers/s390/net/lcs.h
index 8976fb0..d58fea5 100644
--- a/drivers/s390/net/lcs.h
+++ b/drivers/s390/net/lcs.h
@@ -16,11 +16,19 @@ do { \
 	debug_event(lcs_dbf_##name,level,(void*)(addr),len); \
 } while (0)
 
+/* Allow to sort out low debug levels early to avoid wasted sprints */
+static inline int lcs_dbf_passes(debug_info_t *dbf_grp, int level)
+{
+	return (level <= dbf_grp->level);
+}
+
 #define LCS_DBF_TEXT_(level,name,text...) \
-do {                                       \
-	sprintf(debug_buffer, text);  \
-		debug_text_event(lcs_dbf_##name,level, debug_buffer);\
-} while (0)
+	do { \
+		if (lcs_dbf_passes(lcs_dbf_##name, level)) { \
+			sprintf(debug_buffer, text); \
+			debug_text_event(lcs_dbf_##name, level, debug_buffer); \
+		} \
+	} while (0)
 
 /**
  *	sysfs related stuff
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index f3d893c..874a199 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -97,12 +97,22 @@ MODULE_DESCRIPTION ("Linux for S/390 IUCV network driver");
 
 DECLARE_PER_CPU(char[256], iucv_dbf_txt_buf);
 
-#define IUCV_DBF_TEXT_(name,level,text...)				\
-	do {								\
-		char* iucv_dbf_txt_buf = get_cpu_var(iucv_dbf_txt_buf);	\
-		sprintf(iucv_dbf_txt_buf, text);			\
-		debug_text_event(iucv_dbf_##name,level,iucv_dbf_txt_buf); \
-		put_cpu_var(iucv_dbf_txt_buf);				\
+/* Allow to sort out low debug levels early to avoid wasted sprints */
+static inline int iucv_dbf_passes(debug_info_t *dbf_grp, int level)
+{
+	return (level <= dbf_grp->level);
+}
+
+#define IUCV_DBF_TEXT_(name, level, text...) \
+	do { \
+		if (iucv_dbf_passes(iucv_dbf_##name, level)) { \
+			char* iucv_dbf_txt_buf = \
+					get_cpu_var(iucv_dbf_txt_buf); \
+			sprintf(iucv_dbf_txt_buf, text); \
+			debug_text_event(iucv_dbf_##name, level, \
+						iucv_dbf_txt_buf); \
+			put_cpu_var(iucv_dbf_txt_buf); \
+		} \
 	} while (0)
 
 #define IUCV_DBF_SPRINTF(name,level,text...) \
@@ -137,6 +147,7 @@ PRINT_##importance(header "%02x %02x %02x %02x  %02x %02x %02x %02x  " \
 #define PRINTK_HEADER " iucv: "       /* for debugging */
 
 static struct device_driver netiucv_driver = {
+	.owner = THIS_MODULE,
 	.name = "netiucv",
 	.bus  = &iucv_bus,
 };
@@ -572,9 +583,9 @@ static void netiucv_callback_connres(struct iucv_path *path, u8 ipuser[16])
 }
 
 /**
- * Dummy NOP action for all statemachines
+ * NOP action for statemachines
  */
-static void fsm_action_nop(fsm_instance *fi, int event, void *arg)
+static void netiucv_action_nop(fsm_instance *fi, int event, void *arg)
 {
 }
 
@@ -1110,7 +1121,7 @@ static const fsm_node dev_fsm[] = {
 
 	{ DEV_STATE_RUNNING,    DEV_EVENT_STOP,    dev_action_stop     },
 	{ DEV_STATE_RUNNING,    DEV_EVENT_CONDOWN, dev_action_conndown },
-	{ DEV_STATE_RUNNING,    DEV_EVENT_CONUP,   fsm_action_nop      },
+	{ DEV_STATE_RUNNING,    DEV_EVENT_CONUP,   netiucv_action_nop  },
 };
 
 static const int DEV_FSM_LEN = sizeof(dev_fsm) / sizeof(fsm_node);
diff --git a/include/linux/dm9000.h b/include/linux/dm9000.h
index 0008e2a..a375046 100644
--- a/include/linux/dm9000.h
+++ b/include/linux/dm9000.h
@@ -19,6 +19,8 @@
 #define DM9000_PLATF_8BITONLY	(0x0001)
 #define DM9000_PLATF_16BITONLY	(0x0002)
 #define DM9000_PLATF_32BITONLY	(0x0004)
+#define DM9000_PLATF_EXT_PHY	(0x0008)
+#define DM9000_PLATF_NO_EEPROM	(0x0010)
 
 /* platfrom data for platfrom device structure's platfrom_data field */
 
