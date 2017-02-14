From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: nvidia: forcedeth: use new api ethtool_{get|set}_link_ksettings
Date: Tue, 14 Feb 2017 23:36:32 +0100
Message-ID: <1487111792-26192-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, amitoj1606@gmail.com, jarod@redhat.com,
        stephen@networkplumber.org, edumazet@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   91 +++++++++++++++++--------------
 1 files changed, 50 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 58ba5d3..92367a0 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -4237,14 +4237,15 @@ static int nv_set_wol(struct net_device *dev, struct ethtool_wolinfo *wolinfo)
 	return 0;
 }
 
-static int nv_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int nv_get_link_ksettings(struct net_device *dev,
+				 struct ethtool_link_ksettings *cmd)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	u32 speed;
+	u32 speed, supported, advertising;
 	int adv;
 
 	spin_lock_irq(&np->lock);
-	ecmd->port = PORT_MII;
+	cmd->base.port = PORT_MII;
 	if (!netif_running(dev)) {
 		/* We do not track link speed / duplex setting if the
 		 * interface is disabled. Force a link check */
@@ -4272,64 +4273,71 @@ static int nv_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			speed = -1;
 			break;
 		}
-		ecmd->duplex = DUPLEX_HALF;
+		cmd->base.duplex = DUPLEX_HALF;
 		if (np->duplex)
-			ecmd->duplex = DUPLEX_FULL;
+			cmd->base.duplex = DUPLEX_FULL;
 	} else {
 		speed = SPEED_UNKNOWN;
-		ecmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
-	ethtool_cmd_speed_set(ecmd, speed);
-	ecmd->autoneg = np->autoneg;
+	cmd->base.speed = speed;
+	cmd->base.autoneg = np->autoneg;
 
-	ecmd->advertising = ADVERTISED_MII;
+	advertising = ADVERTISED_MII;
 	if (np->autoneg) {
-		ecmd->advertising |= ADVERTISED_Autoneg;
+		advertising |= ADVERTISED_Autoneg;
 		adv = mii_rw(dev, np->phyaddr, MII_ADVERTISE, MII_READ);
 		if (adv & ADVERTISE_10HALF)
-			ecmd->advertising |= ADVERTISED_10baseT_Half;
+			advertising |= ADVERTISED_10baseT_Half;
 		if (adv & ADVERTISE_10FULL)
-			ecmd->advertising |= ADVERTISED_10baseT_Full;
+			advertising |= ADVERTISED_10baseT_Full;
 		if (adv & ADVERTISE_100HALF)
-			ecmd->advertising |= ADVERTISED_100baseT_Half;
+			advertising |= ADVERTISED_100baseT_Half;
 		if (adv & ADVERTISE_100FULL)
-			ecmd->advertising |= ADVERTISED_100baseT_Full;
+			advertising |= ADVERTISED_100baseT_Full;
 		if (np->gigabit == PHY_GIGABIT) {
 			adv = mii_rw(dev, np->phyaddr, MII_CTRL1000, MII_READ);
 			if (adv & ADVERTISE_1000FULL)
-				ecmd->advertising |= ADVERTISED_1000baseT_Full;
+				advertising |= ADVERTISED_1000baseT_Full;
 		}
 	}
-	ecmd->supported = (SUPPORTED_Autoneg |
+	supported = (SUPPORTED_Autoneg |
 		SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
 		SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 		SUPPORTED_MII);
 	if (np->gigabit == PHY_GIGABIT)
-		ecmd->supported |= SUPPORTED_1000baseT_Full;
+		supported |= SUPPORTED_1000baseT_Full;
 
-	ecmd->phy_address = np->phyaddr;
-	ecmd->transceiver = XCVR_EXTERNAL;
+	cmd->base.phy_address = np->phyaddr;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	/* ignore maxtxpkt, maxrxpkt for now */
 	spin_unlock_irq(&np->lock);
 	return 0;
 }
 
-static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int nv_set_link_ksettings(struct net_device *dev,
+				 const struct ethtool_link_ksettings *cmd)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	u32 speed = ethtool_cmd_speed(ecmd);
+	u32 speed = cmd->base.speed;
+	u32 advertising;
 
-	if (ecmd->port != PORT_MII)
-		return -EINVAL;
-	if (ecmd->transceiver != XCVR_EXTERNAL)
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
+
+	if (cmd->base.port != PORT_MII)
 		return -EINVAL;
-	if (ecmd->phy_address != np->phyaddr) {
+	if (cmd->base.phy_address != np->phyaddr) {
 		/* TODO: support switching between multiple phys. Should be
 		 * trivial, but not enabled due to lack of test hardware. */
 		return -EINVAL;
 	}
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		u32 mask;
 
 		mask = ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
@@ -4337,16 +4345,17 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if (np->gigabit == PHY_GIGABIT)
 			mask |= ADVERTISED_1000baseT_Full;
 
-		if ((ecmd->advertising & mask) == 0)
+		if ((advertising & mask) == 0)
 			return -EINVAL;
 
-	} else if (ecmd->autoneg == AUTONEG_DISABLE) {
+	} else if (cmd->base.autoneg == AUTONEG_DISABLE) {
 		/* Note: autonegotiation disable, speed 1000 intentionally
 		 * forbidden - no one should need that. */
 
 		if (speed != SPEED_10 && speed != SPEED_100)
 			return -EINVAL;
-		if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
+		if (cmd->base.duplex != DUPLEX_HALF &&
+		    cmd->base.duplex != DUPLEX_FULL)
 			return -EINVAL;
 	} else {
 		return -EINVAL;
@@ -4376,7 +4385,7 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		netif_tx_unlock_bh(dev);
 	}
 
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		int adv, bmcr;
 
 		np->autoneg = 1;
@@ -4384,13 +4393,13 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		/* advertise only what has been requested */
 		adv = mii_rw(dev, np->phyaddr, MII_ADVERTISE, MII_READ);
 		adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4 | ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
-		if (ecmd->advertising & ADVERTISED_10baseT_Half)
+		if (advertising & ADVERTISED_10baseT_Half)
 			adv |= ADVERTISE_10HALF;
-		if (ecmd->advertising & ADVERTISED_10baseT_Full)
+		if (advertising & ADVERTISED_10baseT_Full)
 			adv |= ADVERTISE_10FULL;
-		if (ecmd->advertising & ADVERTISED_100baseT_Half)
+		if (advertising & ADVERTISED_100baseT_Half)
 			adv |= ADVERTISE_100HALF;
-		if (ecmd->advertising & ADVERTISED_100baseT_Full)
+		if (advertising & ADVERTISED_100baseT_Full)
 			adv |= ADVERTISE_100FULL;
 		if (np->pause_flags & NV_PAUSEFRAME_RX_REQ)  /* for rx we set both advertisements but disable tx pause */
 			adv |=  ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
@@ -4401,7 +4410,7 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if (np->gigabit == PHY_GIGABIT) {
 			adv = mii_rw(dev, np->phyaddr, MII_CTRL1000, MII_READ);
 			adv &= ~ADVERTISE_1000FULL;
-			if (ecmd->advertising & ADVERTISED_1000baseT_Full)
+			if (advertising & ADVERTISED_1000baseT_Full)
 				adv |= ADVERTISE_1000FULL;
 			mii_rw(dev, np->phyaddr, MII_CTRL1000, adv);
 		}
@@ -4428,13 +4437,13 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 
 		adv = mii_rw(dev, np->phyaddr, MII_ADVERTISE, MII_READ);
 		adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4 | ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
-		if (speed == SPEED_10 && ecmd->duplex == DUPLEX_HALF)
+		if (speed == SPEED_10 && cmd->base.duplex == DUPLEX_HALF)
 			adv |= ADVERTISE_10HALF;
-		if (speed == SPEED_10 && ecmd->duplex == DUPLEX_FULL)
+		if (speed == SPEED_10 && cmd->base.duplex == DUPLEX_FULL)
 			adv |= ADVERTISE_10FULL;
-		if (speed == SPEED_100 && ecmd->duplex == DUPLEX_HALF)
+		if (speed == SPEED_100 && cmd->base.duplex == DUPLEX_HALF)
 			adv |= ADVERTISE_100HALF;
-		if (speed == SPEED_100 && ecmd->duplex == DUPLEX_FULL)
+		if (speed == SPEED_100 && cmd->base.duplex == DUPLEX_FULL)
 			adv |= ADVERTISE_100FULL;
 		np->pause_flags &= ~(NV_PAUSEFRAME_AUTONEG|NV_PAUSEFRAME_RX_ENABLE|NV_PAUSEFRAME_TX_ENABLE);
 		if (np->pause_flags & NV_PAUSEFRAME_RX_REQ) {/* for rx we set both advertisements but disable tx pause */
@@ -5241,8 +5250,6 @@ static void nv_get_strings(struct net_device *dev, u32 stringset, u8 *buffer)
 	.get_link = ethtool_op_get_link,
 	.get_wol = nv_get_wol,
 	.set_wol = nv_set_wol,
-	.get_settings = nv_get_settings,
-	.set_settings = nv_set_settings,
 	.get_regs_len = nv_get_regs_len,
 	.get_regs = nv_get_regs,
 	.nway_reset = nv_nway_reset,
@@ -5255,6 +5262,8 @@ static void nv_get_strings(struct net_device *dev, u32 stringset, u8 *buffer)
 	.get_sset_count = nv_get_sset_count,
 	.self_test = nv_self_test,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.get_link_ksettings = nv_get_link_ksettings,
+	.set_link_ksettings = nv_set_link_ksettings,
 };
 
 /* The mgmt unit and driver use a semaphore to access the phy during init */
-- 
1.7.4.4
