From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 5/5] mv643xx_eth: inter-mv643xx SMI port sharing
Date: Thu, 24 Apr 2008 01:29:59 +0200
Message-ID: <20080423232959.GG17159@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@cam.org>
To: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:60305 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbYDWXaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 19:30:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There exist chips with up to four mv643xx_eth silicon blocks but
only one external SMI (MII management) interface -- the SMI logic
of the first block is shared by all the blocks.

Handle this by allowing a per-port override of which
mv643xx_eth_shared's SMI registers (and spinlock) to use.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Nicolas Pitre <nico@marvell.com>

Index: linux-2.6.25-git4/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.25-git4.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.25-git4/drivers/net/mv643xx_eth.c
@@ -527,6 +527,8 @@ struct mv643xx_private {
 	struct mv643xx_shared_private *shared;
 	int port_num;			/* User Ethernet port number	*/
 
+	struct mv643xx_shared_private *shared_smi;
+
 	u32 rx_sram_addr;		/* Base address of rx sram area */
 	u32 rx_sram_size;		/* Size of rx sram area		*/
 	u32 tx_sram_addr;		/* Base address of tx sram area */
@@ -1898,6 +1900,10 @@ static int mv643xx_eth_probe(struct plat
 	if (mp->shared->win_protect)
 		wrl(mp, WINDOW_PROTECT(port_num), mp->shared->win_protect);
 
+	mp->shared_smi = mp->shared;
+	if (pd->shared_smi != NULL)
+		mp->shared_smi = platform_get_drvdata(pd->shared_smi);
+
 	/* set default config values */
 	eth_port_uc_addr_get(mp, dev->dev_addr);
 	mp->rx_ring_size = PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
@@ -2983,15 +2989,16 @@ static void eth_port_reset(struct mv643x
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
@@ -2999,11 +3006,11 @@ static void eth_port_read_smi_reg(struct
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
@@ -3011,9 +3018,9 @@ static void eth_port_read_smi_reg(struct
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	*value = rdl(mp, SMI_REG) & 0xffff;
+	*value = readl(smi_reg) & 0xffff;
 out:
-	spin_unlock_irqrestore(&mp->shared->phy_lock, flags);
+	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
 }
 
 /*
@@ -3039,17 +3046,16 @@ out:
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
@@ -3057,10 +3063,10 @@ static void eth_port_write_smi_reg(struc
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
Index: linux-2.6.25-git4/include/linux/mv643xx_eth.h
===================================================================
--- linux-2.6.25-git4.orig/include/linux/mv643xx_eth.h
+++ linux-2.6.25-git4/include/linux/mv643xx_eth.h
@@ -24,6 +24,8 @@ struct mv643xx_eth_platform_data {
 	struct platform_device	*shared;
 	int		port_number;
 
+	struct platform_device	*shared_smi;
+
 	u16		force_phy_addr;	/* force override if phy_addr == 0 */
 	u16		phy_addr;
 

--
