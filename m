From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/3] mv643xx_eth: convert to phylib
Date: Wed,  3 Sep 2008 15:20:12 +0200
Message-ID: <1220448012-20347-4-git-send-email-buytenh@wantstofly.org>
References: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org>
Cc: Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:56366 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752093AbYICNUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 09:20:14 -0400
In-Reply-To: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch mv643xx_eth from using drivers/net/mii.c to using phylib.

Since the mv643xx_eth hardware does all the link state handling and
PHY polling, the driver will use phylib in the "Doing it all yourself"
mode described in the phylib documentation.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/Kconfig       |    2 +-
 drivers/net/mv643xx_eth.c |  218 ++++++++++++++++++++-------------------------
 2 files changed, 99 insertions(+), 121 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a5c141c..9410266 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2262,7 +2262,7 @@ config UGETH_TX_ON_DEMAND
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
 	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) || PLAT_ORION
-	select MII
+	select PHYLIB
 	help
 	  This driver supports the gigabit ethernet MACs in the
 	  Marvell Discovery PPC/MIPS chipset family (MV643XX) and
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index c0ff2ee..67451e6 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -48,7 +48,7 @@
 #include <linux/kernel.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
-#include <linux/mii.h>
+#include <linux/phy.h>
 #include <linux/mv643xx_eth.h>
 #include <asm/io.h>
 #include <asm/types.h>
@@ -248,9 +248,9 @@ struct mv643xx_eth_shared_private {
 	struct mv643xx_eth_shared_private *smi;
 
 	/*
-	 * Protects access to SMI_REG, which is shared between ports.
+	 * Provides access to local SMI interface.
 	 */
-	struct mutex phy_lock;
+	struct mii_bus smi_bus;
 
 	/*
 	 * If we have access to the error interrupt pin (which is
@@ -349,11 +349,10 @@ struct mv643xx_eth_private {
 
 	struct net_device *dev;
 
-	int phy_addr;
+	struct phy_device *phy;
 
 	struct mib_counters mib_counters;
 	struct work_struct tx_timeout_task;
-	struct mii_if_info mii;
 
 	struct napi_struct napi;
 	u8 work_link;
@@ -1062,62 +1061,50 @@ static int smi_wait_ready(struct mv643xx_eth_shared_private *msp)
 	return 0;
 }
 
-static int smi_reg_read(struct mv643xx_eth_private *mp,
-			unsigned int addr, unsigned int reg)
+static int smi_bus_read(struct mii_bus *bus, int addr, int reg)
 {
-	struct mv643xx_eth_shared_private *msp = mp->shared->smi;
+	struct mv643xx_eth_shared_private *msp = bus->priv;
 	void __iomem *smi_reg = msp->base + SMI_REG;
 	int ret;
 
-	mutex_lock(&msp->phy_lock);
-
 	if (smi_wait_ready(msp)) {
-		printk("%s: SMI bus busy timeout\n", mp->dev->name);
-		ret = -ETIMEDOUT;
-		goto out;
+		printk("mv643xx_eth: SMI bus busy timeout\n");
+		return -ETIMEDOUT;
 	}
 
 	writel(SMI_OPCODE_READ | (reg << 21) | (addr << 16), smi_reg);
 
 	if (smi_wait_ready(msp)) {
-		printk("%s: SMI bus busy timeout\n", mp->dev->name);
-		ret = -ETIMEDOUT;
-		goto out;
+		printk("mv643xx_eth: SMI bus busy timeout\n");
+		return -ETIMEDOUT;
 	}
 
 	ret = readl(smi_reg);
 	if (!(ret & SMI_READ_VALID)) {
-		printk("%s: SMI bus read not valid\n", mp->dev->name);
-		ret = -ENODEV;
-		goto out;
+		printk("mv643xx_eth: SMI bus read not valid\n");
+		return -ENODEV;
 	}
 
-	ret &= 0xffff;
-
-out:
-	mutex_unlock(&msp->phy_lock);
-
-	return ret;
+	return ret & 0xffff;
 }
 
-static int smi_reg_write(struct mv643xx_eth_private *mp, unsigned int addr,
-			 unsigned int reg, unsigned int value)
+static int smi_bus_write(struct mii_bus *bus, int addr, int reg, u16 val)
 {
-	struct mv643xx_eth_shared_private *msp = mp->shared->smi;
+	struct mv643xx_eth_shared_private *msp = bus->priv;
 	void __iomem *smi_reg = msp->base + SMI_REG;
 
-	mutex_lock(&msp->phy_lock);
-
 	if (smi_wait_ready(msp)) {
-		printk("%s: SMI bus busy timeout\n", mp->dev->name);
-		mutex_unlock(&msp->phy_lock);
+		printk("mv643xx_eth: SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
 	writel(SMI_OPCODE_WRITE | (reg << 21) |
-		(addr << 16) | (value & 0xffff), smi_reg);
+		(addr << 16) | (val & 0xffff), smi_reg);
 
-	mutex_unlock(&msp->phy_lock);
+	if (smi_wait_ready(msp)) {
+		printk("mv643xx_eth: SMI bus busy timeout\n");
+		return -ETIMEDOUT;
+	}
 
 	return 0;
 }
@@ -1262,7 +1249,9 @@ static int mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int err;
 
-	err = mii_ethtool_gset(&mp->mii, cmd);
+	err = phy_read_status(mp->phy);
+	if (err == 0)
+		err = phy_ethtool_gset(mp->phy, cmd);
 
 	/*
 	 * The MAC does not support 1000baseT_Half.
@@ -1316,7 +1305,7 @@ static int mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *
 	 */
 	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
 
-	return mii_ethtool_sset(&mp->mii, cmd);
+	return phy_ethtool_sset(mp->phy, cmd);
 }
 
 static int mv643xx_eth_set_settings_phyless(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -1338,7 +1327,7 @@ static int mv643xx_eth_nway_reset(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	return mii_nway_restart(&mp->mii);
+	return phy_nway_restart(mp->phy);
 }
 
 static int mv643xx_eth_nway_reset_phyless(struct net_device *dev)
@@ -1350,7 +1339,7 @@ static u32 mv643xx_eth_get_link(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	return mii_link_ok(&mp->mii);
+	return phy_link_ok(mp->phy);
 }
 
 static u32 mv643xx_eth_get_link_phyless(struct net_device *dev)
@@ -1935,16 +1924,16 @@ static void phy_reset(struct mv643xx_eth_private *mp)
 {
 	int data;
 
-	data = smi_reg_read(mp, mp->phy_addr, MII_BMCR);
+	data = phy_read(mp->phy, MII_BMCR);
 	if (data < 0)
 		return;
 
 	data |= BMCR_RESET;
-	if (smi_reg_write(mp, mp->phy_addr, MII_BMCR, data) < 0)
+	if (phy_write(mp->phy, MII_BMCR, data) < 0)
 		return;
 
 	do {
-		data = smi_reg_read(mp, mp->phy_addr, MII_BMCR);
+		data = phy_read(mp->phy, MII_BMCR);
 	} while (data >= 0 && data & BMCR_RESET);
 }
 
@@ -1956,7 +1945,7 @@ static void port_start(struct mv643xx_eth_private *mp)
 	/*
 	 * Perform PHY reset, if there is a PHY.
 	 */
-	if (mp->phy_addr != -1) {
+	if (mp->phy != NULL) {
 		struct ethtool_cmd cmd;
 
 		mv643xx_eth_get_settings(mp->dev, &cmd);
@@ -1973,7 +1962,7 @@ static void port_start(struct mv643xx_eth_private *mp)
 	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
 
 	pscr |= DO_NOT_FORCE_LINK_FAIL;
-	if (mp->phy_addr == -1)
+	if (mp->phy == NULL)
 		pscr |= FORCE_LINK_PASS;
 	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
 
@@ -2179,8 +2168,8 @@ static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	if (mp->phy_addr != -1)
-		return generic_mii_ioctl(&mp->mii, if_mii(ifr), cmd, NULL);
+	if (mp->phy != NULL)
+		return phy_mii_ioctl(mp->phy, if_mii(ifr), cmd);
 
 	return -EOPNOTSUPP;
 }
@@ -2250,18 +2239,6 @@ static void mv643xx_eth_netpoll(struct net_device *dev)
 }
 #endif
 
-static int mv643xx_eth_mdio_read(struct net_device *dev, int addr, int reg)
-{
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	return smi_reg_read(mp, addr, reg);
-}
-
-static void mv643xx_eth_mdio_write(struct net_device *dev, int addr, int reg, int val)
-{
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	smi_reg_write(mp, addr, reg, val);
-}
-
 
 /* platform glue ************************************************************/
 static void
@@ -2350,11 +2327,23 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (msp->base == NULL)
 		goto out_free;
 
-	msp->smi = msp;
-	if (pd != NULL && pd->shared_smi != NULL)
+	/*
+	 * Set up and register SMI bus.
+	 */
+	if (pd == NULL || pd->shared_smi == NULL) {
+		msp->smi_bus.priv = msp;
+		msp->smi_bus.name = "mv643xx_eth smi";
+		msp->smi_bus.read = smi_bus_read;
+		msp->smi_bus.write = smi_bus_write,
+		snprintf(msp->smi_bus.id, MII_BUS_ID_SIZE, "%d", pdev->id);
+		msp->smi_bus.dev = &pdev->dev;
+		msp->smi_bus.phy_mask = 0xffffffff;
+		if (mdiobus_register(&msp->smi_bus) < 0)
+			goto out_unmap;
+		msp->smi = msp;
+	} else {
 		msp->smi = platform_get_drvdata(pd->shared_smi);
-
-	mutex_init(&msp->phy_lock);
+	}
 
 	msp->err_interrupt = NO_IRQ;
 	init_waitqueue_head(&msp->smi_busy_wait);
@@ -2390,6 +2379,8 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 
 	return 0;
 
+out_unmap:
+	iounmap(msp->base);
 out_free:
 	kfree(msp);
 out:
@@ -2399,7 +2390,10 @@ out:
 static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
 	struct mv643xx_eth_shared_private *msp = platform_get_drvdata(pdev);
+	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
 
+	if (pd == NULL || pd->shared_smi == NULL)
+		mdiobus_unregister(&msp->smi_bus);
 	if (msp->err_interrupt != NO_IRQ)
 		free_irq(msp->err_interrupt, msp);
 	iounmap(msp->base);
@@ -2447,17 +2441,6 @@ static void set_params(struct mv643xx_eth_private *mp,
 	else
 		uc_addr_get(mp, dev->dev_addr);
 
-	if (pd->phy_addr == MV643XX_ETH_PHY_NONE) {
-		mp->phy_addr = -1;
-	} else {
-		if (pd->phy_addr != MV643XX_ETH_PHY_ADDR_DEFAULT) {
-			mp->phy_addr = pd->phy_addr & 0x3f;
-			phy_addr_set(mp, mp->phy_addr);
-		} else {
-			mp->phy_addr = phy_addr_get(mp);
-		}
-	}
-
 	mp->default_rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
 	if (pd->rx_queue_size)
 		mp->default_rx_ring_size = pd->rx_queue_size;
@@ -2475,76 +2458,69 @@ static void set_params(struct mv643xx_eth_private *mp,
 	mp->txq_count = pd->tx_queue_count ? : 1;
 }
 
-static int phy_detect(struct mv643xx_eth_private *mp)
+static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
+				   int phy_addr)
 {
-	int data;
-	int data2;
-
-	data = smi_reg_read(mp, mp->phy_addr, MII_BMCR);
-	if (data < 0)
-		return -ENODEV;
+	struct mii_bus *bus = &mp->shared->smi->smi_bus;
+	struct phy_device *phydev;
+	int start;
+	int num;
+	int i;
 
-	if (smi_reg_write(mp, mp->phy_addr, MII_BMCR, data ^ BMCR_ANENABLE) < 0)
-		return -ENODEV;
+	if (phy_addr == MV643XX_ETH_PHY_ADDR_DEFAULT) {
+		start = phy_addr_get(mp) & 0x1f;
+		num = 32;
+	} else {
+		start = phy_addr & 0x1f;
+		num = 1;
+	}
 
-	data2 = smi_reg_read(mp, mp->phy_addr, MII_BMCR);
-	if (data2 < 0)
-		return -ENODEV;
+	phydev = NULL;
+	for (i = 0; i < num; i++) {
+		int addr = (start + i) & 0x1f;
 
-	if (((data ^ data2) & BMCR_ANENABLE) == 0)
-		return -ENODEV;
+		if (bus->phy_map[addr] == NULL)
+			mdiobus_scan(bus, addr);
 
-	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data);
+		if (phydev == NULL) {
+			phydev = bus->phy_map[addr];
+			if (phydev != NULL)
+				phy_addr_set(mp, addr);
+		}
+	}
 
-	return 0;
+	return phydev;
 }
 
-static int phy_init(struct mv643xx_eth_private *mp,
-		    struct mv643xx_eth_platform_data *pd)
+static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
 {
 	struct ethtool_cmd cmd;
-	int err;
 
-	err = phy_detect(mp);
-	if (err) {
-		dev_printk(KERN_INFO, &mp->dev->dev,
-			   "no PHY detected at addr %d\n", mp->phy_addr);
-		return err;
-	}
 	phy_reset(mp);
 
-	mp->mii.phy_id = mp->phy_addr;
-	mp->mii.phy_id_mask = 0x3f;
-	mp->mii.reg_num_mask = 0x1f;
-	mp->mii.dev = mp->dev;
-	mp->mii.mdio_read = mv643xx_eth_mdio_read;
-	mp->mii.mdio_write = mv643xx_eth_mdio_write;
-
-	mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
+	phy_attach(mp->dev, mp->phy->dev.bus_id, 0, 0);
 
 	memset(&cmd, 0, sizeof(cmd));
 
 	cmd.port = PORT_MII;
 	cmd.transceiver = XCVR_INTERNAL;
-	cmd.phy_address = mp->phy_addr;
-	if (pd->speed == 0) {
+	cmd.phy_address = mp->phy->addr;
+	if (speed == 0) {
 		cmd.autoneg = AUTONEG_ENABLE;
 		cmd.speed = SPEED_100;
 		cmd.advertising = ADVERTISED_10baseT_Half  |
 				  ADVERTISED_10baseT_Full  |
 				  ADVERTISED_100baseT_Half |
 				  ADVERTISED_100baseT_Full;
-		if (mp->mii.supports_gmii)
+		if (phy_check_gmii_support(mp->phy))
 			cmd.advertising |= ADVERTISED_1000baseT_Full;
 	} else {
 		cmd.autoneg = AUTONEG_DISABLE;
-		cmd.speed = pd->speed;
-		cmd.duplex = pd->duplex;
+		cmd.speed = speed;
+		cmd.duplex = duplex;
 	}
 
 	mv643xx_eth_set_settings(mp->dev, &cmd);
-
-	return 0;
 }
 
 static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
@@ -2558,7 +2534,7 @@ static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
 	}
 
 	pscr = MAX_RX_PACKET_9700BYTE | SERIAL_PORT_CONTROL_RESERVED;
-	if (mp->phy_addr == -1) {
+	if (mp->phy == NULL) {
 		pscr |= DISABLE_AUTO_NEG_SPEED_GMII;
 		if (speed == SPEED_1000)
 			pscr |= SET_GMII_SPEED_TO_1000;
@@ -2612,20 +2588,20 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	set_params(mp, pd);
 	dev->real_num_tx_queues = mp->txq_count;
 
-	mib_counters_clear(mp);
-	INIT_WORK(&mp->tx_timeout_task, tx_timeout_task);
-
-	if (mp->phy_addr != -1) {
-		err = phy_init(mp, pd);
-		if (err)
-			goto out;
+	if (pd->phy_addr != MV643XX_ETH_PHY_NONE)
+		mp->phy = phy_scan(mp, pd->phy_addr);
 
+	if (mp->phy != NULL) {
+		phy_init(mp, pd->speed, pd->duplex);
 		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
 	} else {
 		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops_phyless);
 	}
+
 	init_pscr(mp, pd->speed, pd->duplex);
 
+	mib_counters_clear(mp);
+	INIT_WORK(&mp->tx_timeout_task, tx_timeout_task);
 	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, 128);
 
 	init_timer(&mp->rx_oom);
@@ -2683,6 +2659,8 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 	struct mv643xx_eth_private *mp = platform_get_drvdata(pdev);
 
 	unregister_netdev(mp->dev);
+	if (mp->phy != NULL)
+		phy_detach(mp->phy);
 	flush_scheduled_work();
 	free_netdev(mp->dev);
 
-- 
1.5.6.4

