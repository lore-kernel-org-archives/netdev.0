From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 4/5][MV643XX_ETH] inter-mv643xx SMI port sharing
Date: Mon, 17 Mar 2008 21:06:01 +0100
Message-ID: <20080317200601.GE18726@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:47081 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758815AbYCQUGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 16:06:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There exist chips with up to four mv643xx_eth silicon blocks but
only one external SMI (MII management) interface -- the SMI logic
of the first block is shared by all the blocks.

Handle this by allowing a per-port override of which
mv643xx_eth_shared's SMI registers (and spinlock) to use.

Also handle PHY-less ports.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.25-rc6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
@@ -527,6 +527,8 @@ struct mv643xx_private {
 	struct mv643xx_shared_private *shared;
 	int port_num;			/* User Ethernet port number	*/
 
+	struct mv643xx_shared_private *shared_smi;
+
 	u32 rx_sram_addr;		/* Base address of rx sram area */
 	u32 rx_sram_size;		/* Size of rx sram area		*/
 	u32 tx_sram_addr;		/* Base address of tx sram area */
@@ -1073,9 +1075,11 @@ static irqreturn_t mv643xx_eth_int_handl
 	if (eth_int_cause_ext & (ETH_INT_CAUSE_PHY | ETH_INT_CAUSE_STATE)) {
 		struct ethtool_cmd cmd;
 
-		if (mii_link_ok(&mp->mii)) {
-			mii_ethtool_gset(&mp->mii, &cmd);
-			mv643xx_eth_update_pscr(dev, &cmd);
+		if (mp->shared_smi == NULL || mii_link_ok(&mp->mii)) {
+			if (mp->shared_smi != NULL) {
+				mii_ethtool_gset(&mp->mii, &cmd);
+				mv643xx_eth_update_pscr(dev, &cmd);
+			}
 			mv643xx_eth_port_enable_tx(mp, ETH_TX_QUEUES_ENABLED);
 			if (!netif_carrier_ok(dev)) {
 				netif_carrier_on(dev);
@@ -1898,6 +1902,14 @@ static int mv643xx_eth_probe(struct plat
 	if (mp->shared->win_protect)
 		wrl(mp, WINDOW_PROTECT(port_num), mp->shared->win_protect);
 
+	mp->shared_smi = mp->shared;
+	if (pd->override_smi) {
+		if (pd->shared_smi != NULL)
+			mp->shared_smi = platform_get_drvdata(pd->shared_smi);
+		else
+			mp->shared_smi = NULL;
+	}
+
 	/* set default config values */
 	eth_port_uc_addr_get(mp, dev->dev_addr);
 	mp->rx_ring_size = PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
@@ -1928,27 +1940,29 @@ static int mv643xx_eth_probe(struct plat
 	duplex = pd->duplex;
 	speed = pd->speed;
 
-	/* Hook up MII support for ethtool */
-	mp->mii.dev = dev;
-	mp->mii.mdio_read = mv643xx_mdio_read;
-	mp->mii.mdio_write = mv643xx_mdio_write;
-	mp->mii.phy_id = ethernet_phy_get(mp);
-	mp->mii.phy_id_mask = 0x3f;
-	mp->mii.reg_num_mask = 0x1f;
+	if (mp->shared_smi != NULL) {
+		/* Hook up MII support for ethtool */
+		mp->mii.dev = dev;
+		mp->mii.mdio_read = mv643xx_mdio_read;
+		mp->mii.mdio_write = mv643xx_mdio_write;
+		mp->mii.phy_id = ethernet_phy_get(mp);
+		mp->mii.phy_id_mask = 0x3f;
+		mp->mii.reg_num_mask = 0x1f;
+
+		err = ethernet_phy_detect(mp);
+		if (err) {
+			pr_debug("%s: No PHY detected at addr %d\n",
+					dev->name, ethernet_phy_get(mp));
+			goto out;
+		}
 
-	err = ethernet_phy_detect(mp);
-	if (err) {
-		pr_debug("%s: No PHY detected at addr %d\n",
-				dev->name, ethernet_phy_get(mp));
-		goto out;
+		ethernet_phy_reset(mp);
+		mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
+		mv643xx_init_ethtool_cmd(dev, mp->mii.phy_id, speed, duplex, &cmd);
+		mv643xx_eth_update_pscr(dev, &cmd);
+		mv643xx_set_settings(dev, &cmd);
 	}
 
-	ethernet_phy_reset(mp);
-	mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
-	mv643xx_init_ethtool_cmd(dev, mp->mii.phy_id, speed, duplex, &cmd);
-	mv643xx_eth_update_pscr(dev, &cmd);
-	mv643xx_set_settings(dev, &cmd);
-
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	err = register_netdev(dev);
 	if (err)
@@ -2408,10 +2422,12 @@ static void eth_port_start(struct net_de
 	/* Disable port bandwidth limits by clearing MTU register */
 	wrl(mp, MAXIMUM_TRANSMIT_UNIT(port_num), 0);
 
-	/* save phy settings across reset */
-	mv643xx_get_settings(dev, &ethtool_cmd);
-	ethernet_phy_reset(mp);
-	mv643xx_set_settings(dev, &ethtool_cmd);
+	if (mp->shared_smi != NULL) {
+		/* save phy settings across reset */
+		mv643xx_get_settings(dev, &ethtool_cmd);
+		ethernet_phy_reset(mp);
+		mv643xx_set_settings(dev, &ethtool_cmd);
+	}
 }
 
 /*
@@ -2983,15 +2999,16 @@ static void eth_port_reset(struct mv643x
 static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 				unsigned int phy_reg, unsigned int *value)
 {
+	void __iomem *smi_reg = mp->shared_smi->eth_base + SMI_REG;
 	int phy_addr = ethernet_phy_get(mp);
 	unsigned long flags;
 	int i;
 
 	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mp->shared->phy_lock, flags);
+	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; rdl(mp, SMI_REG) & ETH_SMI_BUSY; i++) {
+	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("%s: PHY busy timeout\n", mp->dev->name);
 			goto out;
@@ -2999,11 +3016,11 @@ static void eth_port_read_smi_reg(struct
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	wrl(mp, SMI_REG,
-		(phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ);
+	writel((phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ,
+		smi_reg);
 
 	/* now wait for the data to be valid */
-	for (i = 0; !(rdl(mp, SMI_REG) & ETH_SMI_READ_VALID); i++) {
+	for (i = 0; !(readl(smi_reg) & ETH_SMI_READ_VALID); i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("%s: PHY read timeout\n", mp->dev->name);
 			goto out;
@@ -3011,9 +3028,9 @@ static void eth_port_read_smi_reg(struct
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	*value = rdl(mp, SMI_REG) & 0xffff;
+	*value = readl(smi_reg) & 0xffff;
 out:
-	spin_unlock_irqrestore(&mp->shared->phy_lock, flags);
+	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
 }
 
 /*
@@ -3039,17 +3056,16 @@ out:
 static void eth_port_write_smi_reg(struct mv643xx_private *mp,
 				   unsigned int phy_reg, unsigned int value)
 {
-	int phy_addr;
-	int i;
+	void __iomem *smi_reg = mp->shared_smi->eth_base + SMI_REG;
+	int phy_addr = ethernet_phy_get(mp);
 	unsigned long flags;
-
-	phy_addr = ethernet_phy_get(mp);
+	int i;
 
 	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mp->shared->phy_lock, flags);
+	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; rdl(mp, SMI_REG) & ETH_SMI_BUSY; i++) {
+	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("%s: PHY busy timeout\n", mp->dev->name);
 			goto out;
@@ -3057,10 +3073,10 @@ static void eth_port_write_smi_reg(struc
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	wrl(mp, SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
-				ETH_SMI_OPCODE_WRITE | (value & 0xffff));
+	writel((phy_addr << 16) | (phy_reg << 21) |
+		ETH_SMI_OPCODE_WRITE | (value & 0xffff), smi_reg);
 out:
-	spin_unlock_irqrestore(&mp->shared->phy_lock, flags);
+	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
 }
 
 /*
Index: linux-2.6.25-rc6/include/linux/mv643xx_eth.h
===================================================================
--- linux-2.6.25-rc6.orig/include/linux/mv643xx_eth.h
+++ linux-2.6.25-rc6/include/linux/mv643xx_eth.h
@@ -24,6 +24,9 @@ struct mv643xx_eth_platform_data {
 	struct platform_device	*shared;
 	int		port_number;
 
+	int		override_smi;
+	struct platform_device	*shared_smi;
+
 	u16		force_phy_addr;	/* force override if phy_addr == 0 */
 	u16		phy_addr;
