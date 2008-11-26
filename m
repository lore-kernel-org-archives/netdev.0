From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [RFC] Validate ethtool autoneg before relaying
Date: Wed, 26 Nov 2008 14:17:41 -0800
Message-ID: <20081126221741.GA8800@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4797 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752168AbYKZWR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 17:17:56 -0500
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id 57ADF2B2 for
 <netdev@vger.kernel.org>; Wed, 26 Nov 2008 14:17:42 -0800 (PST)
Received: from NT-IRVA-0752.brcm.ad.broadcom.com (nt-irva-0752
 [10.8.194.67]) by mail-irva-13.broadcom.com (Postfix) with ESMTP id
 A6F9F74CFE for <netdev@vger.kernel.org>; Wed, 26 Nov 2008 14:17:41
 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think I want to get an opinion on the direction of this before I
expend too much effort.  As I was auditing the tg3 driver, I found
that ethtool commands are not validated or even range checked before
being passed to the driver.  While this maximizes the flexibility of the
ethtool interface, it can and probably will lead to a lot of duplicated
parameter validation checks within the drivers.  Rather than go off and
selfishly code an iron set of parameter checks for the tg3 driver, I
wanted to see how much of this work would be accepted as part of the
ethtool interface.

The patch below validates the autoneg parameter of
ethtool_set_settings().  As it is coded, the check makes sure the
parameter can either be AUTONEG_ENABLED or AUTONEG_DISABLED.  This makes
any other value an error where it wasn't before.  Correcting out of
range values is possible, but I stumbled when trying to decide which
enumeration of autoneg they should be corrected to.

If this type of work is desirable, I'll continue to trickle in patches.
(Patch is not compile tested at the moment.)

=======================================================================

This patch validates the ethtool autoneg parameter before relaying it on
to the driver's set_settings() function.  All implementers of
set_settings have been audited and redundant checks have been removed.

---
 drivers/net/arm/etherh.c       |   10 ++--------
 drivers/net/cassini.c          |    4 ----
 drivers/net/forcedeth.c        |    4 +---
 drivers/net/ibm_newemac/core.c |    2 --
 drivers/net/mii.c              |    2 --
 drivers/net/natsemi.c          |    4 +---
 drivers/net/phy/phy.c          |    3 ---
 drivers/net/r8169.c            |    7 +++----
 drivers/net/sc92031.c          |    2 --
 drivers/net/sungem.c           |    4 ----
 drivers/net/sunhme.c           |    3 ---
 drivers/net/tulip/de2104x.c    |    2 --
 net/core/ethtool.c             |    3 +++
 13 files changed, 10 insertions(+), 40 deletions(-)

diff --git a/drivers/net/arm/etherh.c b/drivers/net/arm/etherh.c
index 9eb9d1b..76c1ace 100644
--- a/drivers/net/arm/etherh.c
+++ b/drivers/net/arm/etherh.c
@@ -601,12 +601,9 @@ static int etherh_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int etherh_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	switch (cmd->autoneg) {
-	case AUTONEG_ENABLE:
+	if (cmd->autoneg == AUTONEG_ENABLE)
 		dev->flags |= IFF_AUTOMEDIA;
-		break;
-
-	case AUTONEG_DISABLE:
+	else {
 		switch (cmd->port) {
 		case PORT_TP:
 			dev->if_port = IF_PORT_10BASET;
@@ -621,9 +618,6 @@ static int etherh_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		}
 		dev->flags &= ~IFF_AUTOMEDIA;
 		break;
-
-	default:
-		return -EINVAL;
 	}
 
 	etherh_setif(dev);
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index bc84c4c..339b181 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4725,10 +4725,6 @@ static int cas_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	unsigned long flags;
 
 	/* Verify the settings we care about. */
-	if (cmd->autoneg != AUTONEG_ENABLE &&
-	    cmd->autoneg != AUTONEG_DISABLE)
-		return -EINVAL;
-
 	if (cmd->autoneg == AUTONEG_DISABLE &&
 	    ((cmd->speed != SPEED_1000 &&
 	      cmd->speed != SPEED_100 &&
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0d7e575..9c31e62 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4268,7 +4268,7 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if ((ecmd->advertising & mask) == 0)
 			return -EINVAL;
 
-	} else if (ecmd->autoneg == AUTONEG_DISABLE) {
+	} else {
 		/* Note: autonegotiation disable, speed 1000 intentionally
 		 * forbidden - noone should need that. */
 
@@ -4276,8 +4276,6 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			return -EINVAL;
 		if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
 			return -EINVAL;
-	} else {
-		return -EINVAL;
 	}
 
 	netif_carrier_off(dev);
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 87a7066..3660865 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1960,8 +1960,6 @@ static int emac_ethtool_set_settings(struct net_device *ndev,
 	/* Basic sanity checks */
 	if (dev->phy.address < 0)
 		return -EOPNOTSUPP;
-	if (cmd->autoneg != AUTONEG_ENABLE && cmd->autoneg != AUTONEG_DISABLE)
-		return -EINVAL;
 	if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
 		return -EINVAL;
 	if (cmd->duplex != DUPLEX_HALF && cmd->duplex != DUPLEX_FULL)
diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index 9205605..5484079 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -144,8 +144,6 @@ int mii_ethtool_sset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 		return -EINVAL;
 	if (ecmd->phy_address != mii->phy_id)
 		return -EINVAL;
-	if (ecmd->autoneg != AUTONEG_DISABLE && ecmd->autoneg != AUTONEG_ENABLE)
-		return -EINVAL;
 	if ((ecmd->speed == SPEED_1000) && (!mii->supports_gmii))
 		return -EINVAL;
 
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 9f81fcb..11cd648 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2903,13 +2903,11 @@ static int netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 					  ADVERTISED_100baseT_Full)) == 0) {
 			return -EINVAL;
 		}
-	} else if (ecmd->autoneg == AUTONEG_DISABLE) {
+	} else {
 		if (ecmd->speed != SPEED_10 && ecmd->speed != SPEED_100)
 			return -EINVAL;
 		if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
 			return -EINVAL;
-	} else {
-		return -EINVAL;
 	}
 
 	/*
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index e4ede60..b912d62 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -248,9 +248,6 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 	cmd->advertising &= phydev->supported;
 
 	/* Verify the settings we care about. */
-	if (cmd->autoneg != AUTONEG_ENABLE && cmd->autoneg != AUTONEG_DISABLE)
-		return -EINVAL;
-
 	if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
 		return -EINVAL;
 
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index dddf6ae..b8a9a20 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -805,11 +805,10 @@ static int rtl8169_set_speed_tbi(struct net_device *dev,
 	u32 reg;
 
 	reg = RTL_R32(TBICSR);
-	if ((autoneg == AUTONEG_DISABLE) && (speed == SPEED_1000) &&
-	    (duplex == DUPLEX_FULL)) {
-		RTL_W32(TBICSR, reg & ~(TBINwEnable | TBINwRestart));
-	} else if (autoneg == AUTONEG_ENABLE)
+	if (autoneg == AUTONEG_ENABLE)
 		RTL_W32(TBICSR, reg | TBINwEnable | TBINwRestart);
+	else if (speed == SPEED_1000 && duplex == DUPLEX_FULL)
+		RTL_W32(TBICSR, reg & ~(TBINwEnable | TBINwRestart));
 	else {
 		if (netif_msg_link(tp)) {
 			printk(KERN_WARNING "%s: "
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 590f217..0747d07 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1207,8 +1207,6 @@ static int sc92031_ethtool_set_settings(struct net_device *dev,
 		return -EINVAL;
 	if (!(cmd->transceiver == XCVR_INTERNAL))
 		return -EINVAL;
-	if (!(cmd->autoneg == AUTONEG_DISABLE || cmd->autoneg == AUTONEG_ENABLE))
-		return -EINVAL;
 
 	if (cmd->autoneg == AUTONEG_ENABLE) {
 		if (!(cmd->advertising & (ADVERTISED_Autoneg
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 44be8df..280122d 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -2690,10 +2690,6 @@ static int gem_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct gem *gp = netdev_priv(dev);
 
 	/* Verify the settings we care about. */
-	if (cmd->autoneg != AUTONEG_ENABLE &&
-	    cmd->autoneg != AUTONEG_DISABLE)
-		return -EINVAL;
-
 	if (cmd->autoneg == AUTONEG_ENABLE &&
 	    cmd->advertising == 0)
 		return -EINVAL;
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index b22d335..9098984 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2448,9 +2448,6 @@ static int hme_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct happy_meal *hp = netdev_priv(dev);
 
 	/* Verify the settings we care about. */
-	if (cmd->autoneg != AUTONEG_ENABLE &&
-	    cmd->autoneg != AUTONEG_DISABLE)
-		return -EINVAL;
 	if (cmd->autoneg == AUTONEG_DISABLE &&
 	    ((cmd->speed != SPEED_100 &&
 	      cmd->speed != SPEED_10) ||
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 3aa60fa..dea3f99 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1520,8 +1520,6 @@ static int __de_set_settings(struct de_private *de, struct ethtool_cmd *ecmd)
 		return -EINVAL;
 	if (ecmd->transceiver != XCVR_INTERNAL)
 		return -EINVAL;
-	if (ecmd->autoneg != AUTONEG_DISABLE && ecmd->autoneg != AUTONEG_ENABLE)
-		return -EINVAL;
 	if (ecmd->advertising & ~de->media_supported)
 		return -EINVAL;
 	if (ecmd->autoneg == AUTONEG_ENABLE &&
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 14ada53..6362f56 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -164,6 +164,9 @@ static int ethtool_set_settings(struct net_device *dev, void __user *useraddr)
 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
 		return -EFAULT;
 
+	if (cmd.autoneg != AUTONEG_ENABLE && cmd.autoneg != AUTONEG_DISABLE)
+		return -EFAULT;
+
 	return dev->ethtool_ops->set_settings(dev, &cmd);
 }
 
-- 
1.5.6.4



