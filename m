From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/2] mv643xx_eth: use auto phy polling for configuring (R)(G)MII interface
Date: Sat, 19 Jul 2008 14:49:33 +0200
Message-ID: <20080719124933.GB12630@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:41885 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374AbYGSMtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 08:49:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv643xx_eth hardware has a provision for polling the PHY's
MII management registers to obtain the (R)(G)MII interface speed
(10/100/1000) and duplex (half/full) and pause (off/symmetric)
settings to use to talk to the PHY.

The driver currently does not make use of this feature.  Instead,
whenever there is a link status change event, it reads the current
link parameters from the PHY, and programs those parameters into
the mv643xx_eth MAC by hand.

This patch switches the mv643xx_eth driver to letting the MAC
auto-determine the (R)(G)MII link parameters by PHY polling, if there
is a PHY present.  For PHYless ports (when e.g. the (R)(G)MII
interface is connected to a hardware switch), we keep hardcoding the
MII interface parameters.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.26/arch/arm/mach-kirkwood/rd88f6281-setup.c
===================================================================
--- linux-2.6.26.orig/arch/arm/mach-kirkwood/rd88f6281-setup.c
+++ linux-2.6.26/arch/arm/mach-kirkwood/rd88f6281-setup.c
@@ -18,6 +18,7 @@
 #include <linux/timer.h>
 #include <linux/ata_platform.h>
 #include <linux/mv643xx_eth.h>
+#include <linux/ethtool.h>
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
 #include <asm/mach/pci.h>
@@ -69,6 +70,8 @@ static struct platform_device rd88f6281_
 
 static struct mv643xx_eth_platform_data rd88f6281_ge00_data = {
 	.phy_addr	= -1,
+	.speed		= SPEED_1000,
+	.duplex		= DUPLEX_FULL,
 };
 
 static struct mv_sata_platform_data rd88f6281_sata_data = {
Index: linux-2.6.26/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
===================================================================
--- linux-2.6.26.orig/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
+++ linux-2.6.26/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
@@ -15,6 +15,7 @@
 #include <linux/irq.h>
 #include <linux/mtd/physmap.h>
 #include <linux/mv643xx_eth.h>
+#include <linux/ethtool.h>
 #include <asm/mach-types.h>
 #include <asm/gpio.h>
 #include <asm/leds.h>
@@ -88,6 +89,8 @@ static struct orion5x_mpp_mode rd88f5181
 
 static struct mv643xx_eth_platform_data rd88f5181l_fxo_eth_data = {
 	.phy_addr	= -1,
+	.speed		= SPEED_1000,
+	.duplex		= DUPLEX_FULL,
 };
 
 static void __init rd88f5181l_fxo_init(void)
Index: linux-2.6.26/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
===================================================================
--- linux-2.6.26.orig/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
+++ linux-2.6.26/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
@@ -15,6 +15,7 @@
 #include <linux/irq.h>
 #include <linux/mtd/physmap.h>
 #include <linux/mv643xx_eth.h>
+#include <linux/ethtool.h>
 #include <linux/i2c.h>
 #include <asm/mach-types.h>
 #include <asm/gpio.h>
@@ -89,6 +90,8 @@ static struct orion5x_mpp_mode rd88f5181
 
 static struct mv643xx_eth_platform_data rd88f5181l_ge_eth_data = {
 	.phy_addr	= -1,
+	.speed		= SPEED_1000,
+	.duplex		= DUPLEX_FULL,
 };
 
 static struct i2c_board_info __initdata rd88f5181l_ge_i2c_rtc = {
Index: linux-2.6.26/arch/arm/mach-orion5x/wnr854t-setup.c
===================================================================
--- linux-2.6.26.orig/arch/arm/mach-orion5x/wnr854t-setup.c
+++ linux-2.6.26/arch/arm/mach-orion5x/wnr854t-setup.c
@@ -14,6 +14,7 @@
 #include <linux/delay.h>
 #include <linux/mtd/physmap.h>
 #include <linux/mv643xx_eth.h>
+#include <linux/ethtool.h>
 #include <asm/mach-types.h>
 #include <asm/gpio.h>
 #include <asm/mach/arch.h>
@@ -92,6 +93,8 @@ static struct platform_device wnr854t_no
 
 static struct mv643xx_eth_platform_data wnr854t_eth_data = {
 	.phy_addr	= -1,
+	.speed		= SPEED_1000,
+	.duplex		= DUPLEX_FULL,
 };
 
 static void __init wnr854t_init(void)
Index: linux-2.6.26/arch/arm/mach-orion5x/wrt350n-v2-setup.c
===================================================================
--- linux-2.6.26.orig/arch/arm/mach-orion5x/wrt350n-v2-setup.c
+++ linux-2.6.26/arch/arm/mach-orion5x/wrt350n-v2-setup.c
@@ -14,6 +14,7 @@
 #include <linux/delay.h>
 #include <linux/mtd/physmap.h>
 #include <linux/mv643xx_eth.h>
+#include <linux/ethtool.h>
 #include <asm/mach-types.h>
 #include <asm/gpio.h>
 #include <asm/mach/arch.h>
@@ -100,6 +101,8 @@ static struct platform_device wrt350n_v2
 
 static struct mv643xx_eth_platform_data wrt350n_v2_eth_data = {
 	.phy_addr	= -1,
+	.speed		= SPEED_1000,
+	.duplex		= DUPLEX_FULL,
 };
 
 static void __init wrt350n_v2_init(void)
Index: linux-2.6.26/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.26.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.26/drivers/net/mv643xx_eth.c
@@ -91,6 +91,7 @@ static char mv643xx_eth_driver_version[]
 #define PORT_STATUS(p)			(0x0444 + ((p) << 10))
 #define  TX_FIFO_EMPTY			0x00000400
 #define  TX_IN_PROGRESS			0x00000080
+#define  LINK_UP			0x00000002
 #define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
 #define TXQ_FIX_PRIO_CONF(p)		(0x044c + ((p) << 10))
 #define TX_BW_RATE(p)			(0x0450 + ((p) << 10))
@@ -156,7 +157,6 @@ static char mv643xx_eth_driver_version[]
 #define SET_GMII_SPEED_TO_1000			(1 << 23)
 #define SET_FULL_DUPLEX_MODE			(1 << 21)
 #define MAX_RX_PACKET_9700BYTE			(5 << 17)
-#define MAX_RX_PACKET_MASK			(7 << 17)
 #define DISABLE_AUTO_NEG_SPEED_GMII		(1 << 13)
 #define DO_NOT_FORCE_LINK_FAIL			(1 << 10)
 #define SERIAL_PORT_CONTROL_RESERVED		(1 << 9)
@@ -1120,9 +1120,9 @@ static int mv643xx_eth_get_settings(stru
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int err;
 
-	spin_lock_irq(&mp->lock);
+	spin_lock(&mp->lock);
 	err = mii_ethtool_gset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
+	spin_unlock(&mp->lock);
 
 	/*
 	 * The MAC does not support 1000baseT_Half.
@@ -1135,10 +1135,28 @@ static int mv643xx_eth_get_settings(stru
 
 static int mv643xx_eth_get_settings_phyless(struct net_device *dev, struct ethtool_cmd *cmd)
 {
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	u32 port_status;
+
+	port_status = rdl(mp, PORT_STATUS(mp->port_num));
+
 	cmd->supported = SUPPORTED_MII;
 	cmd->advertising = ADVERTISED_MII;
-	cmd->speed = SPEED_1000;
-	cmd->duplex = DUPLEX_FULL;
+	switch (port_status & PORT_SPEED_MASK) {
+	case PORT_SPEED_10:
+		cmd->speed = SPEED_10;
+		break;
+	case PORT_SPEED_100:
+		cmd->speed = SPEED_100;
+		break;
+	case PORT_SPEED_1000:
+		cmd->speed = SPEED_1000;
+		break;
+	default:
+		cmd->speed = -1;
+		break;
+	}
+	cmd->duplex = (port_status & FULL_DUPLEX) ? DUPLEX_FULL : DUPLEX_HALF;
 	cmd->port = PORT_MII;
 	cmd->phy_address = 0;
 	cmd->transceiver = XCVR_INTERNAL;
@@ -1159,9 +1177,9 @@ static int mv643xx_eth_set_settings(stru
 	 */
 	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
 
-	spin_lock_irq(&mp->lock);
+	spin_lock(&mp->lock);
 	err = mii_ethtool_sset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
+	spin_unlock(&mp->lock);
 
 	return err;
 }
@@ -1661,51 +1679,6 @@ static void txq_deinit(struct tx_queue *
 
 
 /* netdev ops and related ***************************************************/
-static void update_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
-{
-	u32 pscr_o;
-	u32 pscr_n;
-
-	pscr_o = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
-
-	/* clear speed, duplex and rx buffer size fields */
-	pscr_n = pscr_o & ~(SET_MII_SPEED_TO_100   |
-			    SET_GMII_SPEED_TO_1000 |
-			    SET_FULL_DUPLEX_MODE   |
-			    MAX_RX_PACKET_MASK);
-
-	pscr_n |= MAX_RX_PACKET_9700BYTE;
-
-	if (speed == SPEED_1000)
-		pscr_n |= SET_GMII_SPEED_TO_1000;
-	else if (speed == SPEED_100)
-		pscr_n |= SET_MII_SPEED_TO_100;
-
-	if (duplex == DUPLEX_FULL)
-		pscr_n |= SET_FULL_DUPLEX_MODE;
-
-	if (pscr_n != pscr_o) {
-		if ((pscr_o & SERIAL_PORT_ENABLE) == 0)
-			wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr_n);
-		else {
-			int i;
-
-			for (i = 0; i < 8; i++)
-				if (mp->txq_mask & (1 << i))
-					txq_disable(mp->txq + i);
-
-			pscr_o &= ~SERIAL_PORT_ENABLE;
-			wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr_o);
-			wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr_n);
-			wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr_n);
-
-			for (i = 0; i < 8; i++)
-				if (mp->txq_mask & (1 << i))
-					txq_enable(mp->txq + i);
-		}
-	}
-}
-
 static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
@@ -1726,14 +1699,7 @@ static irqreturn_t mv643xx_eth_irq(int i
 	}
 
 	if (int_cause_ext & (INT_EXT_PHY | INT_EXT_LINK)) {
-		if (mp->phy_addr == -1 || mii_link_ok(&mp->mii)) {
-			if (mp->phy_addr != -1) {
-				struct ethtool_cmd cmd;
-
-				mii_ethtool_gset(&mp->mii, &cmd);
-				update_pscr(mp, cmd.speed, cmd.duplex);
-			}
-
+		if (rdl(mp, PORT_STATUS(mp->port_num)) & LINK_UP) {
 			if (!netif_carrier_ok(dev)) {
 				netif_carrier_on(dev);
 				netif_wake_queue(dev);
@@ -1847,23 +1813,6 @@ static void port_start(struct mv643xx_et
 	int i;
 
 	/*
-	 * Configure basic link parameters.
-	 */
-	pscr = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
-	pscr &= ~(SERIAL_PORT_ENABLE | FORCE_LINK_PASS);
-	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
-	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
-		DISABLE_AUTO_NEG_SPEED_GMII    |
-		DISABLE_AUTO_NEG_FOR_DUPLEX    |
-		DO_NOT_FORCE_LINK_FAIL	       |
-		SERIAL_PORT_CONTROL_RESERVED;
-	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
-	pscr |= SERIAL_PORT_ENABLE;
-	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
-
-	wrl(mp, SDMA_CONFIG(mp->port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
-
-	/*
 	 * Perform PHY reset, if there is a PHY.
 	 */
 	if (mp->phy_addr != -1) {
@@ -1875,6 +1824,21 @@ static void port_start(struct mv643xx_et
 	}
 
 	/*
+	 * Configure basic link parameters.
+	 */
+	pscr = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
+
+	pscr |= SERIAL_PORT_ENABLE;
+	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+
+	pscr |= DO_NOT_FORCE_LINK_FAIL;
+	if (mp->phy_addr == -1)
+		pscr |= FORCE_LINK_PASS;
+	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+
+	wrl(mp, SDMA_CONFIG(mp->port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
+
+	/*
 	 * Configure TX path and queues.
 	 */
 	tx_set_rate(mp, 1000000000, 16777216);
@@ -2441,12 +2405,39 @@ static int phy_init(struct mv643xx_eth_p
 		cmd.duplex = pd->duplex;
 	}
 
-	update_pscr(mp, cmd.speed, cmd.duplex);
 	mv643xx_eth_set_settings(mp->dev, &cmd);
 
 	return 0;
 }
 
+static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
+{
+	u32 pscr;
+
+	pscr = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
+	if (pscr & SERIAL_PORT_ENABLE) {
+		pscr &= ~SERIAL_PORT_ENABLE;
+		wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+	}
+
+	pscr = MAX_RX_PACKET_9700BYTE | SERIAL_PORT_CONTROL_RESERVED;
+	if (mp->phy_addr == -1) {
+		pscr |= DISABLE_AUTO_NEG_SPEED_GMII;
+		if (speed == SPEED_1000)
+			pscr |= SET_GMII_SPEED_TO_1000;
+		else if (speed == SPEED_100)
+			pscr |= SET_MII_SPEED_TO_100;
+
+		pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL;
+
+		pscr |= DISABLE_AUTO_NEG_FOR_DUPLEX;
+		if (duplex == DUPLEX_FULL)
+			pscr |= SET_FULL_DUPLEX_MODE;
+	}
+
+	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+}
+
 static int mv643xx_eth_probe(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *pd;
@@ -2500,6 +2491,7 @@ static int mv643xx_eth_probe(struct plat
 	} else {
 		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops_phyless);
 	}
+	init_pscr(mp, pd->speed, pd->duplex);
 
 
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
