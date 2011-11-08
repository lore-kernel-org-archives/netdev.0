From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCHv4 5/9] macb: initial support for Cadence GEM
Date: Tue,  8 Nov 2011 14:13:29 +0000
Message-ID: <1320761613-18641-6-git-send-email-jamie@jamieiles.com>
References: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
Cc: arnd@arndb.de, Jamie Iles <jamie@jamieiles.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49746 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932474Ab1KHONy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 09:13:54 -0500
Received: by mail-ww0-f44.google.com with SMTP id 36so805148wwi.1
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 06:13:53 -0800 (PST)
In-Reply-To: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Cadence GEM is based on the MACB Ethernet controller but has a few
small changes with regards to register and bitfield placement.  This
patch detects the presence of a GEM by reading the module ID register
and setting a flag appropriately.

This handles the new HW address, USRIO and hash register base register
locations in GEM.

v3: - convert to macb_is_gem() inline rather than storing a boolean
      flag
    - handle rx_overrun stats for gem

Acked-by: David S. Miller <davem@davemloft.net>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/ethernet/cadence/Kconfig |   16 +++++----
 drivers/net/ethernet/cadence/macb.c  |   44 +++++++++++++-----------
 drivers/net/ethernet/cadence/macb.h  |   61 ++++++++++++++++++++++++++++++++++
 3 files changed, 94 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index 98849a1..a2e1500 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -5,8 +5,8 @@
 config HAVE_NET_MACB
 	bool
 
-config NET_ATMEL
-	bool "Atmel devices"
+config NET_CADENCE
+	bool "Cadence devices"
 	depends on HAVE_NET_MACB || (ARM && ARCH_AT91RM9200)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
@@ -20,7 +20,7 @@ config NET_ATMEL
 	  the remaining Atmel network card questions. If you say Y, you will be
 	  asked for your specific card in the following questions.
 
-if NET_ATMEL
+if NET_CADENCE
 
 config ARM_AT91_ETHER
 	tristate "AT91RM9200 Ethernet support"
@@ -32,14 +32,16 @@ config ARM_AT91_ETHER
 	  ethernet support, then you should always answer Y to this.
 
 config MACB
-	tristate "Atmel MACB support"
+	tristate "Cadence MACB/GEM support"
 	depends on HAVE_NET_MACB
 	select PHYLIB
 	---help---
-	  The Atmel MACB ethernet interface is found on many AT32 and AT91
-	  parts. Say Y to include support for the MACB chip.
+	  The Cadence MACB ethernet interface is found on many Atmel AT32 and
+	  AT91 parts.  This driver also supports the Cadence GEM (Gigabit
+	  Ethernet MAC found in some ARM SoC devices).  Note: the Gigabit mode
+	  is not yet supported.  Say Y to include support for the MACB/GEM chip.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called macb.
 
-endif # NET_ATMEL
+endif # NET_CADENCE
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 26e6b04..a7c3162 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1,5 +1,5 @@
 /*
- * Atmel MACB Ethernet Controller driver
+ * Cadence MACB/GEM Ethernet Controller driver
  *
  * Copyright (C) 2004-2006 Atmel Corporation
  *
@@ -7,7 +7,6 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
 #define pr_fmt(fmt) "macb: " fmt
 #include <linux/clk.h>
 #include <linux/module.h>
@@ -59,9 +58,9 @@ static void __macb_set_hwaddr(struct macb *bp)
 	u16 top;
 
 	bottom = cpu_to_le32(*((u32 *)bp->dev->dev_addr));
-	macb_writel(bp, SA1B, bottom);
+	macb_or_gem_writel(bp, SA1B, bottom);
 	top = cpu_to_le16(*((u16 *)(bp->dev->dev_addr + 4)));
-	macb_writel(bp, SA1T, top);
+	macb_or_gem_writel(bp, SA1T, top);
 }
 
 static void __init macb_get_hwaddr(struct macb *bp)
@@ -70,8 +69,8 @@ static void __init macb_get_hwaddr(struct macb *bp)
 	u16 top;
 	u8 addr[6];
 
-	bottom = macb_readl(bp, SA1B);
-	top = macb_readl(bp, SA1T);
+	bottom = macb_or_gem_readl(bp, SA1B);
+	top = macb_or_gem_readl(bp, SA1T);
 
 	addr[0] = bottom & 0xff;
 	addr[1] = (bottom >> 8) & 0xff;
@@ -579,7 +578,10 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 
 		if (status & MACB_BIT(ISR_ROVR)) {
 			/* We missed at least one packet */
-			bp->hw_stats.rx_overruns++;
+			if (macb_is_gem(bp))
+				bp->hw_stats.gem.rx_overruns++;
+			else
+				bp->hw_stats.macb.rx_overruns++;
 		}
 
 		if (status & MACB_BIT(HRESP)) {
@@ -904,8 +906,8 @@ static void macb_sethashtable(struct net_device *dev)
 		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
 	}
 
-	macb_writel(bp, HRB, mc_filter[0]);
-	macb_writel(bp, HRT, mc_filter[1]);
+	macb_or_gem_writel(bp, HRB, mc_filter[0]);
+	macb_or_gem_writel(bp, HRT, mc_filter[1]);
 }
 
 /*
@@ -927,8 +929,8 @@ static void macb_set_rx_mode(struct net_device *dev)
 
 	if (dev->flags & IFF_ALLMULTI) {
 		/* Enable all multicast mode */
-		macb_writel(bp, HRB, -1);
-		macb_writel(bp, HRT, -1);
+		macb_or_gem_writel(bp, HRB, -1);
+		macb_or_gem_writel(bp, HRT, -1);
 		cfg |= MACB_BIT(NCFGR_MTI);
 	} else if (!netdev_mc_empty(dev)) {
 		/* Enable specific multicasts */
@@ -936,8 +938,8 @@ static void macb_set_rx_mode(struct net_device *dev)
 		cfg |= MACB_BIT(NCFGR_MTI);
 	} else if (dev->flags & (~IFF_ALLMULTI)) {
 		/* Disable all multicast mode */
-		macb_writel(bp, HRB, 0);
-		macb_writel(bp, HRT, 0);
+		macb_or_gem_writel(bp, HRB, 0);
+		macb_or_gem_writel(bp, HRT, 0);
 		cfg &= ~MACB_BIT(NCFGR_MTI);
 	}
 
@@ -1198,15 +1200,16 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	if (pdata && pdata->is_rmii)
 #if defined(CONFIG_ARCH_AT91)
-		macb_writel(bp, USRIO, (MACB_BIT(RMII) | MACB_BIT(CLKEN)) );
+		macb_or_gem_writel(bp, USRIO, (MACB_BIT(RMII) |
+					       MACB_BIT(CLKEN)));
 #else
-		macb_writel(bp, USRIO, 0);
+		macb_or_gem_writel(bp, USRIO, 0);
 #endif
 	else
 #if defined(CONFIG_ARCH_AT91)
-		macb_writel(bp, USRIO, MACB_BIT(CLKEN));
+		macb_or_gem_writel(bp, USRIO, MACB_BIT(CLKEN));
 #else
-		macb_writel(bp, USRIO, MACB_BIT(MII));
+		macb_or_gem_writel(bp, USRIO, MACB_BIT(MII));
 #endif
 
 	bp->tx_pending = DEF_TX_RING_PENDING;
@@ -1223,8 +1226,9 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, dev);
 
-	netdev_info(dev, "Atmel MACB at 0x%08lx irq %d (%pM)\n",
-		dev->base_addr, dev->irq, dev->dev_addr);
+	netdev_info(dev, "Cadence %s at 0x%08lx irq %d (%pM)\n",
+		    macb_is_gem(bp) ? "GEM" : "MACB", dev->base_addr,
+		    dev->irq, dev->dev_addr);
 
 	phydev = bp->phy_dev;
 	netdev_info(dev, "attached PHY driver [%s] "
@@ -1335,6 +1339,6 @@ module_init(macb_init);
 module_exit(macb_exit);
 
 MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("Atmel MACB Ethernet driver");
+MODULE_DESCRIPTION("Cadence MACB/GEM Ethernet driver");
 MODULE_AUTHOR("Haavard Skinnemoen (Atmel)");
 MODULE_ALIAS("platform:macb");
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index d3212f6..d50057c 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -59,6 +59,15 @@
 #define MACB_TPQ				0x00bc
 #define MACB_USRIO				0x00c0
 #define MACB_WOL				0x00c4
+#define MACB_MID				0x00fc
+
+/* GEM register offsets. */
+#define GEM_NCFGR				0x0004
+#define GEM_USRIO				0x000c
+#define GEM_HRB					0x0080
+#define GEM_HRT					0x0084
+#define GEM_SA1B				0x0088
+#define GEM_SA1T				0x008C
 
 /* Bitfields in NCR */
 #define MACB_LB_OFFSET				0
@@ -228,6 +237,12 @@
 #define MACB_WOL_MTI_OFFSET			19
 #define MACB_WOL_MTI_SIZE			1
 
+/* Bitfields in MID */
+#define MACB_IDNUM_OFFSET			16
+#define MACB_IDNUM_SIZE				16
+#define MACB_REV_OFFSET				0
+#define MACB_REV_SIZE				16
+
 /* Constants for CLK */
 #define MACB_CLK_DIV8				0
 #define MACB_CLK_DIV16				1
@@ -254,11 +269,52 @@
 		    << MACB_##name##_OFFSET))		\
 	 | MACB_BF(name,value))
 
+#define GEM_BIT(name)					\
+	(1 << GEM_##name##_OFFSET)
+#define GEM_BF(name, value)				\
+	(((value) & ((1 << GEM_##name##_SIZE) - 1))	\
+	 << GEM_##name##_OFFSET)
+#define GEM_BFEXT(name, value)\
+	(((value) >> GEM_##name##_OFFSET)		\
+	 & ((1 << GEM_##name##_SIZE) - 1))
+#define GEM_BFINS(name, value, old)			\
+	(((old) & ~(((1 << GEM_##name##_SIZE) - 1)	\
+		    << GEM_##name##_OFFSET))		\
+	 | GEM_BF(name, value))
+
 /* Register access macros */
 #define macb_readl(port,reg)				\
 	__raw_readl((port)->regs + MACB_##reg)
 #define macb_writel(port,reg,value)			\
 	__raw_writel((value), (port)->regs + MACB_##reg)
+#define gem_readl(port, reg)				\
+	__raw_readl((port)->regs + GEM_##reg)
+#define gem_writel(port, reg, value)			\
+	__raw_writel((value), (port)->regs + GEM_##reg)
+
+/*
+ * Conditional GEM/MACB macros.  These perform the operation to the correct
+ * register dependent on whether the device is a GEM or a MACB.  For registers
+ * and bitfields that are common across both devices, use macb_{read,write}l
+ * to avoid the cost of the conditional.
+ */
+#define macb_or_gem_writel(__bp, __reg, __value) \
+	({ \
+		if (macb_is_gem((__bp))) \
+			gem_writel((__bp), __reg, __value); \
+		else \
+			macb_writel((__bp), __reg, __value); \
+	})
+
+#define macb_or_gem_readl(__bp, __reg) \
+	({ \
+		u32 __v; \
+		if (macb_is_gem((__bp))) \
+			__v = gem_readl((__bp), __reg); \
+		else \
+			__v = macb_readl((__bp), __reg); \
+		__v; \
+	})
 
 struct dma_desc {
 	u32	addr;
@@ -391,4 +447,9 @@ struct macb {
 	unsigned int 		duplex;
 };
 
+static inline bool macb_is_gem(struct macb *bp)
+{
+	return MACB_BFEXT(IDNUM, macb_readl(bp, MID)) == 0x2;
+}
+
 #endif /* _MACB_H */
-- 
1.7.4.1
