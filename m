From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 5/8] [MV643XX_ETH] Remove SHARED_REGS register address bias
Date: Fri, 19 Oct 2007 04:11:17 +0200
Message-ID: <20071019021117.GG16037@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:44008 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763591AbXJSCLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 22:11:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Start counting mv643xx_eth register addresses from zero, instead of
from 0x2000 (MV643XX_ETH_SHARED_REGS.)

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Tzachi Perelstein <tzachi@marvell.com>

Index: linux-2.6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6/drivers/net/mv643xx_eth.c
@@ -78,26 +78,19 @@ static const struct ethtool_ops mv643xx_
 static char mv643xx_driver_name[] = "mv643xx_eth";
 static char mv643xx_driver_version[] = "1.0";
 
-static void __iomem *mv643xx_eth_shared_base;
+static void __iomem *mv643xx_eth_base;
 
 /* used to protect MV643XX_ETH_SMI_REG, which is shared across ports */
 static DEFINE_SPINLOCK(mv643xx_eth_phy_lock);
 
 static inline u32 mv_read(int offset)
 {
-	void __iomem *reg_base;
-
-	reg_base = mv643xx_eth_shared_base - MV643XX_ETH_SHARED_REGS;
-
-	return readl(reg_base + offset);
+	return readl(((void __iomem *)mv643xx_eth_base) + offset);
 }
 
 static inline void mv_write(int offset, u32 data)
 {
-	void __iomem *reg_base;
-
-	reg_base = mv643xx_eth_shared_base - MV643XX_ETH_SHARED_REGS;
-	writel(data, reg_base + offset);
+	writel(data, ((void __iomem *)mv643xx_eth_base) + offset);
 }
 
 /*
@@ -1470,9 +1463,8 @@ static int mv643xx_eth_shared_probe(stru
 	if (res == NULL)
 		return -ENODEV;
 
-	mv643xx_eth_shared_base = ioremap(res->start,
-						MV643XX_ETH_SHARED_REGS_SIZE);
-	if (mv643xx_eth_shared_base == NULL)
+	mv643xx_eth_base = ioremap(res->start, res->end - res->start + 1);
+	if (mv643xx_eth_base == NULL)
 		return -ENOMEM;
 
 	return 0;
@@ -1481,8 +1473,8 @@ static int mv643xx_eth_shared_probe(stru
 
 static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
-	iounmap(mv643xx_eth_shared_base);
-	mv643xx_eth_shared_base = NULL;
+	iounmap(mv643xx_eth_base);
+	mv643xx_eth_base = NULL;
 
 	return 0;
 }
Index: linux-2.6/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.6.orig/drivers/net/mv643xx_eth.h
+++ linux-2.6/drivers/net/mv643xx_eth.h
@@ -55,116 +55,116 @@
 /*        Ethernet Unit Registers  		*/
 /****************************************/
 
-#define MV643XX_ETH_PHY_ADDR_REG                                    0x2000
-#define MV643XX_ETH_SMI_REG                                         0x2004
-#define MV643XX_ETH_UNIT_DEFAULT_ADDR_REG                           0x2008
-#define MV643XX_ETH_UNIT_DEFAULTID_REG                              0x200c
-#define MV643XX_ETH_UNIT_INTERRUPT_CAUSE_REG                        0x2080
-#define MV643XX_ETH_UNIT_INTERRUPT_MASK_REG                         0x2084
-#define MV643XX_ETH_UNIT_INTERNAL_USE_REG                           0x24fc
-#define MV643XX_ETH_UNIT_ERROR_ADDR_REG                             0x2094
-#define MV643XX_ETH_BAR_0                                           0x2200
-#define MV643XX_ETH_BAR_1                                           0x2208
-#define MV643XX_ETH_BAR_2                                           0x2210
-#define MV643XX_ETH_BAR_3                                           0x2218
-#define MV643XX_ETH_BAR_4                                           0x2220
-#define MV643XX_ETH_BAR_5                                           0x2228
-#define MV643XX_ETH_SIZE_REG_0                                      0x2204
-#define MV643XX_ETH_SIZE_REG_1                                      0x220c
-#define MV643XX_ETH_SIZE_REG_2                                      0x2214
-#define MV643XX_ETH_SIZE_REG_3                                      0x221c
-#define MV643XX_ETH_SIZE_REG_4                                      0x2224
-#define MV643XX_ETH_SIZE_REG_5                                      0x222c
-#define MV643XX_ETH_HEADERS_RETARGET_BASE_REG                       0x2230
-#define MV643XX_ETH_HEADERS_RETARGET_CONTROL_REG                    0x2234
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_0                           0x2280
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_1                           0x2284
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_2                           0x2288
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_3                           0x228c
-#define MV643XX_ETH_BASE_ADDR_ENABLE_REG                            0x2290
-#define MV643XX_ETH_ACCESS_PROTECTION_REG(port)                    (0x2294 + (port<<2))
-#define MV643XX_ETH_MIB_COUNTERS_BASE(port)                        (0x3000 + (port<<7))
-#define MV643XX_ETH_PORT_CONFIG_REG(port)                          (0x2400 + (port<<10))
-#define MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port)                   (0x2404 + (port<<10))
-#define MV643XX_ETH_MII_SERIAL_PARAMETRS_REG(port)                 (0x2408 + (port<<10))
-#define MV643XX_ETH_GMII_SERIAL_PARAMETRS_REG(port)                (0x240c + (port<<10))
-#define MV643XX_ETH_VLAN_ETHERTYPE_REG(port)                       (0x2410 + (port<<10))
-#define MV643XX_ETH_MAC_ADDR_LOW(port)                             (0x2414 + (port<<10))
-#define MV643XX_ETH_MAC_ADDR_HIGH(port)                            (0x2418 + (port<<10))
-#define MV643XX_ETH_SDMA_CONFIG_REG(port)                          (0x241c + (port<<10))
-#define MV643XX_ETH_DSCP_0(port)                                   (0x2420 + (port<<10))
-#define MV643XX_ETH_DSCP_1(port)                                   (0x2424 + (port<<10))
-#define MV643XX_ETH_DSCP_2(port)                                   (0x2428 + (port<<10))
-#define MV643XX_ETH_DSCP_3(port)                                   (0x242c + (port<<10))
-#define MV643XX_ETH_DSCP_4(port)                                   (0x2430 + (port<<10))
-#define MV643XX_ETH_DSCP_5(port)                                   (0x2434 + (port<<10))
-#define MV643XX_ETH_DSCP_6(port)                                   (0x2438 + (port<<10))
-#define MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port)                  (0x243c + (port<<10))
-#define MV643XX_ETH_VLAN_PRIORITY_TAG_TO_PRIORITY(port)            (0x2440 + (port<<10))
-#define MV643XX_ETH_PORT_STATUS_REG(port)                          (0x2444 + (port<<10))
-#define MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port)               (0x2448 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_FIXED_PRIORITY(port)                  (0x244c + (port<<10))
-#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_RATE_CONFIG(port)         (0x2450 + (port<<10))
-#define MV643XX_ETH_MAXIMUM_TRANSMIT_UNIT(port)                    (0x2458 + (port<<10))
-#define MV643XX_ETH_PORT_MAXIMUM_TOKEN_BUCKET_SIZE(port)           (0x245c + (port<<10))
-#define MV643XX_ETH_INTERRUPT_CAUSE_REG(port)                      (0x2460 + (port<<10))
-#define MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port)               (0x2464 + (port<<10))
-#define MV643XX_ETH_INTERRUPT_MASK_REG(port)                       (0x2468 + (port<<10))
-#define MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port)                (0x246c + (port<<10))
-#define MV643XX_ETH_RX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2470 + (port<<10))
-#define MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2474 + (port<<10))
-#define MV643XX_ETH_RX_MINIMAL_FRAME_SIZE_REG(port)                (0x247c + (port<<10))
-#define MV643XX_ETH_RX_DISCARDED_FRAMES_COUNTER(port)              (0x2484 + (port<<10))
-#define MV643XX_ETH_PORT_DEBUG_0_REG(port)                         (0x248c + (port<<10))
-#define MV643XX_ETH_PORT_DEBUG_1_REG(port)                         (0x2490 + (port<<10))
-#define MV643XX_ETH_PORT_INTERNAL_ADDR_ERROR_REG(port)             (0x2494 + (port<<10))
-#define MV643XX_ETH_INTERNAL_USE_REG(port)                         (0x24fc + (port<<10))
-#define MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port)                (0x2680 + (port<<10))
-#define MV643XX_ETH_CURRENT_SERVED_TX_DESC_PTR(port)               (0x2684 + (port<<10))
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x260c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x261c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x262c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x263c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x264c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x265c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x266c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x267c + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x26c0 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x26c4 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x26c8 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x26cc + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x26d0 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x26d4 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x26d8 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x26dc + (port<<10))     
-#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_COUNT(port)            (0x2700 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_COUNT(port)            (0x2710 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_COUNT(port)            (0x2720 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_COUNT(port)            (0x2730 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_COUNT(port)            (0x2740 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_COUNT(port)            (0x2750 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_COUNT(port)            (0x2760 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_COUNT(port)            (0x2770 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_CONFIG(port)           (0x2704 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_CONFIG(port)           (0x2714 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_CONFIG(port)           (0x2724 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_CONFIG(port)           (0x2734 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_CONFIG(port)           (0x2744 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_CONFIG(port)           (0x2754 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_CONFIG(port)           (0x2764 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_CONFIG(port)           (0x2774 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_0_ARBITER_CONFIG(port)                (0x2708 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_1_ARBITER_CONFIG(port)                (0x2718 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_2_ARBITER_CONFIG(port)                (0x2728 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_3_ARBITER_CONFIG(port)                (0x2738 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_4_ARBITER_CONFIG(port)                (0x2748 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_5_ARBITER_CONFIG(port)                (0x2758 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_6_ARBITER_CONFIG(port)                (0x2768 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_7_ARBITER_CONFIG(port)                (0x2778 + (port<<10))
-#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_COUNT(port)               (0x2780 + (port<<10))
-#define MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port)   (0x3400 + (port<<10))
-#define MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port)     (0x3500 + (port<<10))
-#define MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(port)             (0x3600 + (port<<10))
+#define MV643XX_ETH_PHY_ADDR_REG                                    0x0000
+#define MV643XX_ETH_SMI_REG                                         0x0004
+#define MV643XX_ETH_UNIT_DEFAULT_ADDR_REG                           0x0008
+#define MV643XX_ETH_UNIT_DEFAULTID_REG                              0x000c
+#define MV643XX_ETH_UNIT_INTERRUPT_CAUSE_REG                        0x0080
+#define MV643XX_ETH_UNIT_INTERRUPT_MASK_REG                         0x0084
+#define MV643XX_ETH_UNIT_INTERNAL_USE_REG                           0x04fc
+#define MV643XX_ETH_UNIT_ERROR_ADDR_REG                             0x0094
+#define MV643XX_ETH_BAR_0                                           0x0200
+#define MV643XX_ETH_BAR_1                                           0x0208
+#define MV643XX_ETH_BAR_2                                           0x0210
+#define MV643XX_ETH_BAR_3                                           0x0218
+#define MV643XX_ETH_BAR_4                                           0x0220
+#define MV643XX_ETH_BAR_5                                           0x0228
+#define MV643XX_ETH_SIZE_REG_0                                      0x0204
+#define MV643XX_ETH_SIZE_REG_1                                      0x020c
+#define MV643XX_ETH_SIZE_REG_2                                      0x0214
+#define MV643XX_ETH_SIZE_REG_3                                      0x021c
+#define MV643XX_ETH_SIZE_REG_4                                      0x0224
+#define MV643XX_ETH_SIZE_REG_5                                      0x022c
+#define MV643XX_ETH_HEADERS_RETARGET_BASE_REG                       0x0230
+#define MV643XX_ETH_HEADERS_RETARGET_CONTROL_REG                    0x0234
+#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_0                           0x0280
+#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_1                           0x0284
+#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_2                           0x0288
+#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_3                           0x028c
+#define MV643XX_ETH_BASE_ADDR_ENABLE_REG                            0x0290
+#define MV643XX_ETH_ACCESS_PROTECTION_REG(port)                    (0x0294 + (port<<2))
+#define MV643XX_ETH_MIB_COUNTERS_BASE(port)                        (0x1000 + (port<<7))
+#define MV643XX_ETH_PORT_CONFIG_REG(port)                          (0x0400 + (port<<10))
+#define MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port)                   (0x0404 + (port<<10))
+#define MV643XX_ETH_MII_SERIAL_PARAMETRS_REG(port)                 (0x0408 + (port<<10))
+#define MV643XX_ETH_GMII_SERIAL_PARAMETRS_REG(port)                (0x040c + (port<<10))
+#define MV643XX_ETH_VLAN_ETHERTYPE_REG(port)                       (0x0410 + (port<<10))
+#define MV643XX_ETH_MAC_ADDR_LOW(port)                             (0x0414 + (port<<10))
+#define MV643XX_ETH_MAC_ADDR_HIGH(port)                            (0x0418 + (port<<10))
+#define MV643XX_ETH_SDMA_CONFIG_REG(port)                          (0x041c + (port<<10))
+#define MV643XX_ETH_DSCP_0(port)                                   (0x0420 + (port<<10))
+#define MV643XX_ETH_DSCP_1(port)                                   (0x0424 + (port<<10))
+#define MV643XX_ETH_DSCP_2(port)                                   (0x0428 + (port<<10))
+#define MV643XX_ETH_DSCP_3(port)                                   (0x042c + (port<<10))
+#define MV643XX_ETH_DSCP_4(port)                                   (0x0430 + (port<<10))
+#define MV643XX_ETH_DSCP_5(port)                                   (0x0434 + (port<<10))
+#define MV643XX_ETH_DSCP_6(port)                                   (0x0438 + (port<<10))
+#define MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port)                  (0x043c + (port<<10))
+#define MV643XX_ETH_VLAN_PRIORITY_TAG_TO_PRIORITY(port)            (0x0440 + (port<<10))
+#define MV643XX_ETH_PORT_STATUS_REG(port)                          (0x0444 + (port<<10))
+#define MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port)               (0x0448 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_FIXED_PRIORITY(port)                  (0x044c + (port<<10))
+#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_RATE_CONFIG(port)         (0x0450 + (port<<10))
+#define MV643XX_ETH_MAXIMUM_TRANSMIT_UNIT(port)                    (0x0458 + (port<<10))
+#define MV643XX_ETH_PORT_MAXIMUM_TOKEN_BUCKET_SIZE(port)           (0x045c + (port<<10))
+#define MV643XX_ETH_INTERRUPT_CAUSE_REG(port)                      (0x0460 + (port<<10))
+#define MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port)               (0x0464 + (port<<10))
+#define MV643XX_ETH_INTERRUPT_MASK_REG(port)                       (0x0468 + (port<<10))
+#define MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port)                (0x046c + (port<<10))
+#define MV643XX_ETH_RX_FIFO_URGENT_THRESHOLD_REG(port)             (0x0470 + (port<<10))
+#define MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(port)             (0x0474 + (port<<10))
+#define MV643XX_ETH_RX_MINIMAL_FRAME_SIZE_REG(port)                (0x047c + (port<<10))
+#define MV643XX_ETH_RX_DISCARDED_FRAMES_COUNTER(port)              (0x0484 + (port<<10))
+#define MV643XX_ETH_PORT_DEBUG_0_REG(port)                         (0x048c + (port<<10))
+#define MV643XX_ETH_PORT_DEBUG_1_REG(port)                         (0x0490 + (port<<10))
+#define MV643XX_ETH_PORT_INTERNAL_ADDR_ERROR_REG(port)             (0x0494 + (port<<10))
+#define MV643XX_ETH_INTERNAL_USE_REG(port)                         (0x04fc + (port<<10))
+#define MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port)                (0x0680 + (port<<10))
+#define MV643XX_ETH_CURRENT_SERVED_TX_DESC_PTR(port)               (0x0684 + (port<<10))
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x060c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x061c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x062c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x063c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x064c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x065c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x066c + (port<<10))     
+#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x067c + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x06c0 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x06c4 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x06c8 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x06cc + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x06d0 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x06d4 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x06d8 + (port<<10))     
+#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x06dc + (port<<10))     
+#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_COUNT(port)            (0x0700 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_COUNT(port)            (0x0710 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_COUNT(port)            (0x0720 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_COUNT(port)            (0x0730 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_COUNT(port)            (0x0740 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_COUNT(port)            (0x0750 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_COUNT(port)            (0x0760 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_COUNT(port)            (0x0770 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_CONFIG(port)           (0x0704 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_CONFIG(port)           (0x0714 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_CONFIG(port)           (0x0724 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_CONFIG(port)           (0x0734 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_CONFIG(port)           (0x0744 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_CONFIG(port)           (0x0754 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_CONFIG(port)           (0x0764 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_CONFIG(port)           (0x0774 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_0_ARBITER_CONFIG(port)                (0x0708 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_1_ARBITER_CONFIG(port)                (0x0718 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_2_ARBITER_CONFIG(port)                (0x0728 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_3_ARBITER_CONFIG(port)                (0x0738 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_4_ARBITER_CONFIG(port)                (0x0748 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_5_ARBITER_CONFIG(port)                (0x0758 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_6_ARBITER_CONFIG(port)                (0x0768 + (port<<10))
+#define MV643XX_ETH_TX_QUEUE_7_ARBITER_CONFIG(port)                (0x0778 + (port<<10))
+#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_COUNT(port)               (0x0780 + (port<<10))
+#define MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port)   (0x1400 + (port<<10))
+#define MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port)     (0x1500 + (port<<10))
+#define MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(port)             (0x1600 + (port<<10))
 
 /* These macros describe Ethernet Port configuration reg (Px_cR) bits */
 #define MV643XX_ETH_UNICAST_NORMAL_MODE		0
