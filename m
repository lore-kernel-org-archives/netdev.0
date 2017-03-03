From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: smsc: smc91c92_cs: use new api ethtool_{get|set}_link_ksettings
Date: Fri,  3 Mar 2017 23:39:35 +0100
Message-ID: <1488580775-27415-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, jarod@redhat.com,
        felipe.balbi@linux.intel.com, edumazet@google.com, fw@strlen.de,
        tklauser@distanz.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/smsc/smc91c92_cs.c |   98 ++++++++++++++++--------------
 1 files changed, 52 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index 97280da..976aa87 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -1843,56 +1843,60 @@ static int smc_link_ok(struct net_device *dev)
     }
 }
 
-static int smc_netdev_get_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int smc_netdev_get_ecmd(struct net_device *dev,
+			       struct ethtool_link_ksettings *ecmd)
 {
-    u16 tmp;
-    unsigned int ioaddr = dev->base_addr;
+	u16 tmp;
+	unsigned int ioaddr = dev->base_addr;
+	u32 supported;
 
-    ecmd->supported = (SUPPORTED_TP | SUPPORTED_AUI |
-	SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full);
-		
-    SMC_SELECT_BANK(1);
-    tmp = inw(ioaddr + CONFIG);
-    ecmd->port = (tmp & CFG_AUI_SELECT) ? PORT_AUI : PORT_TP;
-    ecmd->transceiver = XCVR_INTERNAL;
-    ethtool_cmd_speed_set(ecmd, SPEED_10);
-    ecmd->phy_address = ioaddr + MGMT;
+	supported = (SUPPORTED_TP | SUPPORTED_AUI |
+		     SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full);
 
-    SMC_SELECT_BANK(0);
-    tmp = inw(ioaddr + TCR);
-    ecmd->duplex = (tmp & TCR_FDUPLX) ? DUPLEX_FULL : DUPLEX_HALF;
+	SMC_SELECT_BANK(1);
+	tmp = inw(ioaddr + CONFIG);
+	ecmd->base.port = (tmp & CFG_AUI_SELECT) ? PORT_AUI : PORT_TP;
+	ecmd->base.speed = SPEED_10;
+	ecmd->base.phy_address = ioaddr + MGMT;
 
-    return 0;
+	SMC_SELECT_BANK(0);
+	tmp = inw(ioaddr + TCR);
+	ecmd->base.duplex = (tmp & TCR_FDUPLX) ? DUPLEX_FULL : DUPLEX_HALF;
+
+	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.supported,
+						supported);
+
+	return 0;
 }
 
-static int smc_netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int smc_netdev_set_ecmd(struct net_device *dev,
+			       const struct ethtool_link_ksettings *ecmd)
 {
-    u16 tmp;
-    unsigned int ioaddr = dev->base_addr;
+	u16 tmp;
+	unsigned int ioaddr = dev->base_addr;
 
-    if (ethtool_cmd_speed(ecmd) != SPEED_10)
-	return -EINVAL;
-    if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
-    	return -EINVAL;
-    if (ecmd->port != PORT_TP && ecmd->port != PORT_AUI)
-	return -EINVAL;
-    if (ecmd->transceiver != XCVR_INTERNAL)
-    	return -EINVAL;
+	if (ecmd->base.speed != SPEED_10)
+		return -EINVAL;
+	if (ecmd->base.duplex != DUPLEX_HALF &&
+	    ecmd->base.duplex != DUPLEX_FULL)
+		return -EINVAL;
+	if (ecmd->base.port != PORT_TP && ecmd->base.port != PORT_AUI)
+		return -EINVAL;
 
-    if (ecmd->port == PORT_AUI)
-	smc_set_xcvr(dev, 1);
-    else
-	smc_set_xcvr(dev, 0);
+	if (ecmd->base.port == PORT_AUI)
+		smc_set_xcvr(dev, 1);
+	else
+		smc_set_xcvr(dev, 0);
 
-    SMC_SELECT_BANK(0);
-    tmp = inw(ioaddr + TCR);
-    if (ecmd->duplex == DUPLEX_FULL)
-	tmp |= TCR_FDUPLX;
-    else
-	tmp &= ~TCR_FDUPLX;
-    outw(tmp, ioaddr + TCR);
-	
-    return 0;
+	SMC_SELECT_BANK(0);
+	tmp = inw(ioaddr + TCR);
+	if (ecmd->base.duplex == DUPLEX_FULL)
+		tmp |= TCR_FDUPLX;
+	else
+		tmp &= ~TCR_FDUPLX;
+	outw(tmp, ioaddr + TCR);
+
+	return 0;
 }
 
 static int check_if_running(struct net_device *dev)
@@ -1908,7 +1912,8 @@ static void smc_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 }
 
-static int smc_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int smc_get_link_ksettings(struct net_device *dev,
+				  struct ethtool_link_ksettings *ecmd)
 {
 	struct smc_private *smc = netdev_priv(dev);
 	unsigned int ioaddr = dev->base_addr;
@@ -1919,7 +1924,7 @@ static int smc_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	spin_lock_irqsave(&smc->lock, flags);
 	SMC_SELECT_BANK(3);
 	if (smc->cfg & CFG_MII_SELECT)
-		ret = mii_ethtool_gset(&smc->mii_if, ecmd);
+		ret = mii_ethtool_get_link_ksettings(&smc->mii_if, ecmd);
 	else
 		ret = smc_netdev_get_ecmd(dev, ecmd);
 	SMC_SELECT_BANK(saved_bank);
@@ -1927,7 +1932,8 @@ static int smc_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	return ret;
 }
 
-static int smc_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int smc_set_link_ksettings(struct net_device *dev,
+				  const struct ethtool_link_ksettings *ecmd)
 {
 	struct smc_private *smc = netdev_priv(dev);
 	unsigned int ioaddr = dev->base_addr;
@@ -1938,7 +1944,7 @@ static int smc_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	spin_lock_irqsave(&smc->lock, flags);
 	SMC_SELECT_BANK(3);
 	if (smc->cfg & CFG_MII_SELECT)
-		ret = mii_ethtool_sset(&smc->mii_if, ecmd);
+		ret = mii_ethtool_set_link_ksettings(&smc->mii_if, ecmd);
 	else
 		ret = smc_netdev_set_ecmd(dev, ecmd);
 	SMC_SELECT_BANK(saved_bank);
@@ -1982,10 +1988,10 @@ static int smc_nway_reset(struct net_device *dev)
 static const struct ethtool_ops ethtool_ops = {
 	.begin = check_if_running,
 	.get_drvinfo = smc_get_drvinfo,
-	.get_settings = smc_get_settings,
-	.set_settings = smc_set_settings,
 	.get_link = smc_get_link,
 	.nway_reset = smc_nway_reset,
+	.get_link_ksettings = smc_get_link_ksettings,
+	.set_link_ksettings = smc_set_link_ksettings,
 };
 
 static int smc_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
-- 
1.7.4.4
