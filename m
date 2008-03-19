From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/4] mv643xx_eth: mbus decode window support
Date: Wed, 19 Mar 2008 08:49:37 +0100
Message-ID: <20080319074937.GC5010@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:47618 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765830AbYCSUR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:17:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it possible to pass mbus_dram_target_info to the mv643xx_eth
driver via the platform data, and make the mv643xx_eth driver
program the window registers based on this data if it is passed in.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Reviewed-by: Tzachi Perelstein <tzachi@marvell.com>
Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

Index: linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.25-rc6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
@@ -91,6 +91,11 @@
  */
 #define PHY_ADDR_REG				0x0000
 #define SMI_REG					0x0004
+#define WINDOW_BASE(i)				(0x0200 + ((i) << 3))
+#define WINDOW_SIZE(i)				(0x0204 + ((i) << 3))
+#define WINDOW_REMAP_HIGH(i)			(0x0280 + ((i) << 2))
+#define WINDOW_BAR_ENABLE			0x0290
+#define WINDOW_PROTECT(i)			(0x0294 + ((i) << 4))
 
 /*
  * Per-port registers.
@@ -512,6 +517,8 @@ struct mv643xx_shared_private {
 
 	/* used to protect SMI_REG, which is shared across ports */
 	spinlock_t phy_lock;
+
+	u32 win_protect;
 };
 
 struct mv643xx_private {
@@ -1888,6 +1895,9 @@ static int mv643xx_eth_probe(struct plat
 	mp->shared = platform_get_drvdata(pd->shared);
 	port_num = mp->port_num = pd->port_number;
 
+	if (mp->shared->win_protect)
+		wrl(mp, WINDOW_PROTECT(port_num), mp->shared->win_protect);
+
 	/* set default config values */
 	eth_port_uc_addr_get(mp, dev->dev_addr);
 	mp->rx_ring_size = PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
@@ -1992,9 +2002,44 @@ static int mv643xx_eth_remove(struct pla
 	return 0;
 }
 
+static void mv643xx_eth_conf_mbus_windows(struct mv643xx_shared_private *msp,
+					  struct mbus_dram_target_info *dram)
+{
+	void __iomem *base = msp->eth_base;
+	u32 win_enable;
+	u32 win_protect;
+	int i;
+
+	for (i = 0; i < 6; i++) {
+		writel(0, base + WINDOW_BASE(i));
+		writel(0, base + WINDOW_SIZE(i));
+		if (i < 4)
+			writel(0, base + WINDOW_REMAP_HIGH(i));
+	}
+
+	win_enable = 0x3f;
+	win_protect = 0;
+
+	for (i = 0; i < dram->num_cs; i++) {
+		struct mbus_dram_window *cs = dram->cs + i;
+
+		writel((cs->base & 0xffff0000) |
+			(cs->mbus_attr << 8) |
+			dram->mbus_dram_target_id, base + WINDOW_BASE(i));
+		writel((cs->size - 1) & 0xffff0000, base + WINDOW_SIZE(i));
+
+		win_enable &= ~(1 << i);
+		win_protect |= 3 << (2 * i);
+	}
+
+	writel(win_enable, base + WINDOW_BAR_ENABLE);
+	msp->win_protect = win_protect;
+}
+
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
 	static int mv643xx_version_printed = 0;
+	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
 	struct mv643xx_shared_private *msp;
 	struct resource *res;
 	int ret;
@@ -2021,6 +2066,12 @@ static int mv643xx_eth_shared_probe(stru
 
 	platform_set_drvdata(pdev, msp);
 
+	/*
+	 * (Re-)program MBUS remapping windows if we are asked to.
+	 */
+	if (pd != NULL && pd->dram != NULL)
+		mv643xx_eth_conf_mbus_windows(msp, pd->dram);
+
 	return 0;
 
 out_free:
Index: linux-2.6.25-rc6/include/linux/mv643xx_eth.h
===================================================================
--- linux-2.6.25-rc6.orig/include/linux/mv643xx_eth.h
+++ linux-2.6.25-rc6/include/linux/mv643xx_eth.h
@@ -5,6 +5,8 @@
 #ifndef __LINUX_MV643XX_ETH_H
 #define __LINUX_MV643XX_ETH_H
 
+#include <linux/mbus.h>
+
 #define MV643XX_ETH_SHARED_NAME		"mv643xx_eth_shared"
 #define MV643XX_ETH_NAME		"mv643xx_eth"
 #define MV643XX_ETH_SHARED_REGS		0x2000
@@ -13,6 +15,10 @@
 #define MV643XX_ETH_SIZE_REG_4		0x2224
 #define MV643XX_ETH_BASE_ADDR_ENABLE_REG	0x2290
 
+struct mv643xx_eth_shared_platform_data {
+	struct mbus_dram_target_info	*dram;
+};
+
 struct mv643xx_eth_platform_data {
 	struct platform_device	*shared;
 	int		port_number;


----
