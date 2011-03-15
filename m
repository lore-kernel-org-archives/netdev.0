From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCHv2 5/9] macb: initial support for Cadence GEM
Date: Tue, 15 Mar 2011 10:14:52 +0000
Message-ID: <1300184096-13937-6-git-send-email-jamie@jamieiles.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, plagnioj@jcrosoft.com,
	Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54894 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756557Ab1COKP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 06:15:27 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so389803bwz.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 03:15:26 -0700 (PDT)
In-Reply-To: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Cadence GEM is based on the MACB Ethernet controller but has a few
small changes with regards to register and bitfield placement.  This
patch detects the presence of a GEM by reading the module ID register
and setting a flag appropriately.

This handles the new HW address, USRIO and hash register base register
locations in GEM.

Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/Kconfig |    8 ++++--
 drivers/net/macb.c  |   43 +++++++++++++++++++++-----------------
 drivers/net/macb.h  |   57 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 86 insertions(+), 22 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3cdf485..30d43c2 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -223,12 +223,14 @@ menuconfig NET_ETHERNET
 if NET_ETHERNET
 
 config MACB
-	tristate "Atmel MACB support"
+	tristate "Cadence MACB/GEM support"
 	depends on HAVE_NET_MACB
 	select PHYLIB
 	help
-	  The Atmel MACB ethernet interface is found on many AT32 and AT91
-	  parts. Say Y to include support for the MACB chip.
+	  The Cadence MACB ethernet interface is found on many Atmel AT32 and
+	  AT91 parts.  This driver also supports the Cadence GEM (Gigabit
+	  Ethernet MAC found in some ARM SoC devices).  Note: the Gigabit mode
+	  is not yet supported.  Say Y to include support for the MACB/GEM chip.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called macb.
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 41cecfb..9cd1d7e 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
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
@@ -58,9 +57,9 @@ static void __macb_set_hwaddr(struct macb *bp)
 	u16 top;
 
 	bottom = cpu_to_le32(*((u32 *)bp->dev->dev_addr));
-	macb_writel(bp, SA1B, bottom);
+	macb_or_gem_writel(bp, SA1B, bottom);
 	top = cpu_to_le16(*((u16 *)(bp->dev->dev_addr + 4)));
-	macb_writel(bp, SA1T, top);
+	macb_or_gem_writel(bp, SA1T, top);
 }
 
 static void __init macb_get_hwaddr(struct macb *bp)
@@ -69,8 +68,8 @@ static void __init macb_get_hwaddr(struct macb *bp)
 	u16 top;
 	u8 addr[6];
 
-	bottom = macb_readl(bp, SA1B);
-	top = macb_readl(bp, SA1T);
+	bottom = macb_or_gem_readl(bp, SA1B);
+	top = macb_or_gem_readl(bp, SA1T);
 
 	addr[0] = bottom & 0xff;
 	addr[1] = (bottom >> 8) & 0xff;
@@ -893,8 +892,8 @@ static void macb_sethashtable(struct net_device *dev)
 		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
 	}
 
-	macb_writel(bp, HRB, mc_filter[0]);
-	macb_writel(bp, HRT, mc_filter[1]);
+	macb_or_gem_writel(bp, HRB, mc_filter[0]);
+	macb_or_gem_writel(bp, HRT, mc_filter[1]);
 }
 
 /*
@@ -916,8 +915,8 @@ static void macb_set_rx_mode(struct net_device *dev)
 
 	if (dev->flags & IFF_ALLMULTI) {
 		/* Enable all multicast mode */
-		macb_writel(bp, HRB, -1);
-		macb_writel(bp, HRT, -1);
+		macb_or_gem_writel(bp, HRB, -1);
+		macb_or_gem_writel(bp, HRT, -1);
 		cfg |= MACB_BIT(NCFGR_MTI);
 	} else if (!netdev_mc_empty(dev)) {
 		/* Enable specific multicasts */
@@ -925,8 +924,8 @@ static void macb_set_rx_mode(struct net_device *dev)
 		cfg |= MACB_BIT(NCFGR_MTI);
 	} else if (dev->flags & (~IFF_ALLMULTI)) {
 		/* Disable all multicast mode */
-		macb_writel(bp, HRB, 0);
-		macb_writel(bp, HRT, 0);
+		macb_or_gem_writel(bp, HRB, 0);
+		macb_or_gem_writel(bp, HRT, 0);
 		cfg &= ~MACB_BIT(NCFGR_MTI);
 	}
 
@@ -1164,6 +1163,10 @@ static int __init macb_probe(struct platform_device *pdev)
 		goto err_out_iounmap;
 	}
 
+	/* Cadence GEM has a module ID of 2. */
+	if (MACB_BFEXT(IDNUM, macb_readl(bp, MID)) == 0x2)
+		bp->is_gem = 1;
+
 	dev->netdev_ops = &macb_netdev_ops;
 	netif_napi_add(dev, &bp->napi, macb_poll, 64);
 	dev->ethtool_ops = &macb_ethtool_ops;
@@ -1187,15 +1190,16 @@ static int __init macb_probe(struct platform_device *pdev)
 
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
@@ -1212,8 +1216,9 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, dev);
 
-	netdev_info(dev, "Atmel MACB at 0x%08lx irq %d (%pM)\n",
-		dev->base_addr, dev->irq, dev->dev_addr);
+	netdev_info(dev, "Cadence %s at 0x%08lx irq %d (%pM)\n",
+		    bp->is_gem ? "GEM" : "MACB", dev->base_addr,
+		    dev->irq, dev->dev_addr);
 
 	phydev = bp->phy_dev;
 	netdev_info(dev, "attached PHY driver [%s] "
@@ -1324,6 +1329,6 @@ module_init(macb_init);
 module_exit(macb_exit);
 
 MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("Atmel MACB Ethernet driver");
+MODULE_DESCRIPTION("Cadence MACB/GEM Ethernet driver");
 MODULE_AUTHOR("Haavard Skinnemoen <hskinnemoen@atmel.com>");
 MODULE_ALIAS("platform:macb");
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index d3212f6..3a07352 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
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
+		if ((__bp)->is_gem) \
+			gem_writel((__bp), __reg, __value); \
+		else \
+			macb_writel((__bp), __reg, __value); \
+	})
+
+#define macb_or_gem_readl(__bp, __reg) \
+	({ \
+		u32 __v; \
+		if ((__bp)->is_gem) \
+			__v = gem_readl((__bp), __reg); \
+		else \
+			__v = macb_readl((__bp), __reg); \
+		__v; \
+	})
 
 struct dma_desc {
 	u32	addr;
@@ -360,6 +416,7 @@ struct macb_stats {
 
 struct macb {
 	void __iomem		*regs;
+	int			is_gem;
 
 	unsigned int		rx_tail;
 	struct dma_desc		*rx_ring;
-- 
1.7.4

