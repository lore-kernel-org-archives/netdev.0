From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 04/17] mv643xx_eth: switch ->phy_lock from a spinlock to a mutex
Date: Wed,  3 Sep 2008 14:29:31 +0200
Message-ID: <1220444984-20150-5-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52894 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751317AbYICM3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:46 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 81600eea98789da09a32de69ca9d3be8b9503c54 ("mv643xx_eth:
use auto phy polling for configuring (R)(G)MII interface"),
mv643xx_eth no longer does SMI accesses from interrupt context.  The
only other callers that do SMI accesses all do them from process
context, which means we can switch the PHY lock from a spinlock to a
mutex, and get rid of the extra locking in some ethtool methods.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   23 +++++++----------------
 1 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 2f6cec4..2d43401 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -251,7 +251,7 @@ struct mv643xx_eth_shared_private {
 	/*
 	 * Protects access to SMI_REG, which is shared between ports.
 	 */
-	spinlock_t phy_lock;
+	struct mutex phy_lock;
 
 	/*
 	 * Per-port MBUS window access register value.
@@ -988,11 +988,10 @@ static void smi_reg_read(struct mv643xx_eth_private *mp, unsigned int addr,
 			 unsigned int reg, unsigned int *value)
 {
 	void __iomem *smi_reg = mp->shared_smi->base + SMI_REG;
-	unsigned long flags;
 	int i;
 
 	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
+	mutex_lock(&mp->shared_smi->phy_lock);
 
 	/* wait for the SMI register to become available */
 	for (i = 0; readl(smi_reg) & SMI_BUSY; i++) {
@@ -1016,7 +1015,7 @@ static void smi_reg_read(struct mv643xx_eth_private *mp, unsigned int addr,
 
 	*value = readl(smi_reg) & 0xffff;
 out:
-	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
+	mutex_unlock(&mp->shared_smi->phy_lock);
 }
 
 static void smi_reg_write(struct mv643xx_eth_private *mp,
@@ -1024,11 +1023,10 @@ static void smi_reg_write(struct mv643xx_eth_private *mp,
 			  unsigned int reg, unsigned int value)
 {
 	void __iomem *smi_reg = mp->shared_smi->base + SMI_REG;
-	unsigned long flags;
 	int i;
 
 	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
+	mutex_lock(&mp->shared_smi->phy_lock);
 
 	/* wait for the SMI register to become available */
 	for (i = 0; readl(smi_reg) & SMI_BUSY; i++) {
@@ -1042,7 +1040,7 @@ static void smi_reg_write(struct mv643xx_eth_private *mp,
 	writel(SMI_OPCODE_WRITE | (reg << 21) |
 		(addr << 16) | (value & 0xffff), smi_reg);
 out:
-	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
+	mutex_unlock(&mp->shared_smi->phy_lock);
 }
 
 
@@ -1161,9 +1159,7 @@ static int mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int err;
 
-	spin_lock_irq(&mp->lock);
 	err = mii_ethtool_gset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
 
 	/*
 	 * The MAC does not support 1000baseT_Half.
@@ -1211,18 +1207,13 @@ static int mv643xx_eth_get_settings_phyless(struct net_device *dev, struct ethto
 static int mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	int err;
 
 	/*
 	 * The MAC does not support 1000baseT_Half.
 	 */
 	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
 
-	spin_lock_irq(&mp->lock);
-	err = mii_ethtool_sset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
-
-	return err;
+	return mii_ethtool_sset(&mp->mii, cmd);
 }
 
 static int mv643xx_eth_set_settings_phyless(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -2324,7 +2315,7 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (msp->base == NULL)
 		goto out_free;
 
-	spin_lock_init(&msp->phy_lock);
+	mutex_init(&msp->phy_lock);
 
 	/*
 	 * (Re-)program MBUS remapping windows if we are asked to.
-- 
1.5.6.4

