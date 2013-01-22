From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/15] drivers/net: delete 486 Apricot support
Date: Mon, 21 Jan 2013 20:46:08 -0500
Message-ID: <1358819182-28032-2-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45315 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635Ab3AVBqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:36 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Apricot was a 486 PC with 4MB RAM, and an on-board ethernet
via an intel i82596 hard-wired to i/o 0x300.

Those who were using linux in the 1990's will recall that the
i82596 driver was not one of the more stable or widely used
drivers of its day.  Combine that with the extremely limited
resources of the platform, and it is truly time to expire the
support for this thing.

There are some old m68k targets who were also using this chip,
so rather than poll the m68k user base, we simply cut out the
x86/Apricot support here in this commit.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Space.c                  |  2 +-
 drivers/net/ethernet/i825xx/82596.c  | 96 +++---------------------------------
 drivers/net/ethernet/i825xx/Kconfig  | 11 -----
 drivers/net/ethernet/i825xx/Makefile |  1 -
 4 files changed, 9 insertions(+), 101 deletions(-)

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 5637c26..c6e5194 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -165,7 +165,7 @@ static struct devprobe2 isa_probes[] __initdata = {
 #ifdef CONFIG_EWRK3             /* DEC EtherWORKS 3 */
     	{ewrk3_probe, 0},
 #endif
-#if defined(CONFIG_APRICOT) || defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
+#if defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
 	{i82596_probe, 0},
 #endif
 #ifdef CONFIG_EL1		/* 3c501 */
diff --git a/drivers/net/ethernet/i825xx/82596.c b/drivers/net/ethernet/i825xx/82596.c
index 6aa927a..05cda84 100644
--- a/drivers/net/ethernet/i825xx/82596.c
+++ b/drivers/net/ethernet/i825xx/82596.c
@@ -95,9 +95,6 @@ static char version[] __initdata =
 #if defined(CONFIG_BVME6000_NET) || defined(CONFIG_BVME6000_NET_MODULE)
 #define ENABLE_BVME6000_NET
 #endif
-#if defined(CONFIG_APRICOT) || defined(CONFIG_APRICOT_MODULE)
-#define ENABLE_APRICOT
-#endif
 
 #ifdef ENABLE_MVME16x_NET
 #include <asm/mvme16xhw.h>
@@ -120,8 +117,15 @@ static char version[] __initdata =
 #define WSWAPtbd(x)  ((struct i596_tbd *) (((u32)(x)<<16) | ((((u32)(x)))>>16)))
 #define WSWAPchar(x) ((char *)            (((u32)(x)<<16) | ((((u32)(x)))>>16)))
 #define ISCP_BUSY	0x00010000
-#define MACH_IS_APRICOT	0
 #else
+#error 82596.c: unknown architecture
+#endif
+
+/*
+ * These were the intel versions, left here for reference. There
+ * are currently no x86 users of this legacy i82596 chip.
+ */
+#if 0
 #define WSWAPrfd(x)     ((struct i596_rfd *)((long)x))
 #define WSWAPrbd(x)     ((struct i596_rbd *)((long)x))
 #define WSWAPiscp(x)    ((struct i596_iscp *)((long)x))
@@ -130,7 +134,6 @@ static char version[] __initdata =
 #define WSWAPtbd(x)     ((struct i596_tbd *)((long)x))
 #define WSWAPchar(x)    ((char *)((long)x))
 #define ISCP_BUSY	0x0001
-#define MACH_IS_APRICOT	1
 #endif
 
 /*
@@ -383,11 +386,6 @@ static inline void CA(struct net_device *dev)
 		i = *(volatile u32 *) (dev->base_addr);
 	}
 #endif
-#ifdef ENABLE_APRICOT
-	if (MACH_IS_APRICOT) {
-		outw(0, (short) (dev->base_addr) + 4);
-	}
-#endif
 }
 
 
@@ -617,9 +615,6 @@ static void rebuild_rx_bufs(struct net_device *dev)
 static int init_i596_mem(struct net_device *dev)
 {
 	struct i596_private *lp = dev->ml_priv;
-#if !defined(ENABLE_MVME16x_NET) && !defined(ENABLE_BVME6000_NET) || defined(ENABLE_APRICOT)
-	short ioaddr = dev->base_addr;
-#endif
 	unsigned long flags;
 
 	MPU_PORT(dev, PORT_RESET, NULL);
@@ -653,20 +648,6 @@ static int init_i596_mem(struct net_device *dev)
 
 	MPU_PORT(dev, PORT_ALTSCP, (void *)virt_to_bus((void *)&lp->scp));
 
-#elif defined(ENABLE_APRICOT)
-
-	{
-		u32 scp = virt_to_bus(&lp->scp);
-
-		/* change the scp address */
-		outw(0, ioaddr);
-		outw(0, ioaddr);
-		outb(4, ioaddr + 0xf);
-		outw(scp | 2, ioaddr);
-		outw(scp >> 16, ioaddr);
-	}
-#endif
-
 	lp->last_cmd = jiffies;
 
 #ifdef ENABLE_MVME16x_NET
@@ -677,10 +658,6 @@ static int init_i596_mem(struct net_device *dev)
 	if (MACH_IS_BVME6000)
 		lp->scp.sysbus = 0x0000004c;
 #endif
-#ifdef ENABLE_APRICOT
-	if (MACH_IS_APRICOT)
-		lp->scp.sysbus = 0x00440000;
-#endif
 
 	lp->scp.iscp = WSWAPiscp(virt_to_bus((void *)&lp->iscp));
 	lp->iscp.scb = WSWAPscb(virt_to_bus((void *)&lp->scb));
@@ -698,10 +675,6 @@ static int init_i596_mem(struct net_device *dev)
 
 	DEB(DEB_INIT,printk(KERN_DEBUG "%s: starting i82596.\n", dev->name));
 
-#if defined(ENABLE_APRICOT)
-	(void) inb(ioaddr + 0x10);
-	outb(4, ioaddr + 0xf);
-#endif
 	CA(dev);
 
 	if (wait_istat(dev,lp,1000,"initialization timed out"))
@@ -1203,43 +1176,6 @@ struct net_device * __init i82596_probe(int unit)
 		goto found;
 	}
 #endif
-#ifdef ENABLE_APRICOT
-	{
-		int checksum = 0;
-		int ioaddr = 0x300;
-
-		/* this is easy the ethernet interface can only be at 0x300 */
-		/* first check nothing is already registered here */
-
-		if (!request_region(ioaddr, I596_TOTAL_SIZE, DRV_NAME)) {
-			printk(KERN_ERR "82596: IO address 0x%04x in use\n", ioaddr);
-			err = -EBUSY;
-			goto out;
-		}
-
-		dev->base_addr = ioaddr;
-
-		for (i = 0; i < 8; i++) {
-			eth_addr[i] = inb(ioaddr + 8 + i);
-			checksum += eth_addr[i];
-		}
-
-		/* checksum is a multiple of 0x100, got this wrong first time
-		   some machines have 0x100, some 0x200. The DOS driver doesn't
-		   even bother with the checksum.
-		   Some other boards trip the checksum.. but then appear as
-		   ether address 0. Trap these - AC */
-
-		if ((checksum % 0x100) ||
-		    (memcmp(eth_addr, "\x00\x00\x49", 3) != 0)) {
-			err = -ENODEV;
-			goto out1;
-		}
-
-		dev->irq = 10;
-		goto found;
-	}
-#endif
 	err = -ENODEV;
 	goto out;
 
@@ -1296,9 +1232,6 @@ out2:
 #endif
 	free_page ((u32)(dev->mem_start));
 out1:
-#ifdef ENABLE_APRICOT
-	release_region(dev->base_addr, I596_TOTAL_SIZE);
-#endif
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -1455,10 +1388,6 @@ static irqreturn_t i596_interrupt(int irq, void *dev_id)
 		*ethirq = 3;
 	}
 #endif
-#ifdef ENABLE_APRICOT
-	(void) inb(ioaddr + 0x10);
-	outb(4, ioaddr + 0xf);
-#endif
 	CA(dev);
 
 	DEB(DEB_INTS,printk(KERN_DEBUG "%s: exiting interrupt.\n", dev->name));
@@ -1589,11 +1518,6 @@ static void set_multicast_list(struct net_device *dev)
 #ifdef MODULE
 static struct net_device *dev_82596;
 
-#ifdef ENABLE_APRICOT
-module_param(irq, int, 0);
-MODULE_PARM_DESC(irq, "Apricot IRQ number");
-#endif
-
 static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "i82596 debug mask");
@@ -1620,10 +1544,6 @@ void __exit cleanup_module(void)
 			IOMAP_FULL_CACHING);
 #endif
 	free_page ((u32)(dev_82596->mem_start));
-#ifdef ENABLE_APRICOT
-	/* If we don't do this, we can't re-insmod it later. */
-	release_region(dev_82596->base_addr, I596_TOTAL_SIZE);
-#endif
 	free_netdev(dev_82596);
 }
 
diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i825xx/Kconfig
index 70f8c2d..c39698a 100644
--- a/drivers/net/ethernet/i825xx/Kconfig
+++ b/drivers/net/ethernet/i825xx/Kconfig
@@ -50,17 +50,6 @@ config ARM_ETHER1
 	  If you have an Acorn system with one of these (AKA25) network cards,
 	  you should say Y to this option if you wish to use it with Linux.
 
-config APRICOT
-	tristate "Apricot Xen-II on board Ethernet"
-	depends on ISA
-	---help---
-	  If you have a network (Ethernet) controller of this type, say Y and
-	  read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called apricot.
-
 config BVME6000_NET
 	tristate "BVME6000 Ethernet support"
 	depends on BVME6000
diff --git a/drivers/net/ethernet/i825xx/Makefile b/drivers/net/ethernet/i825xx/Makefile
index 6adff85..e5ab9d0 100644
--- a/drivers/net/ethernet/i825xx/Makefile
+++ b/drivers/net/ethernet/i825xx/Makefile
@@ -11,7 +11,6 @@ obj-$(CONFIG_LP486E) += lp486e.o
 obj-$(CONFIG_NI52) += ni52.o
 obj-$(CONFIG_SUN3_82586) += sun3_82586.o
 obj-$(CONFIG_ZNET) += znet.o
-obj-$(CONFIG_APRICOT) += 82596.o
 obj-$(CONFIG_LASI_82596) += lasi_82596.o
 obj-$(CONFIG_SNI_82596) += sni_82596.o
 obj-$(CONFIG_MVME16x_NET) += 82596.o
-- 
1.8.1
