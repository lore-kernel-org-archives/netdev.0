From: David Decotigny <decot@google.com>
Subject: [PATCHv3 3/7] ethtool: Use the full 32 bit speed range in ethtool's set_settings
Date: Wed, 27 Apr 2011 18:27:19 -0700
Message-ID: <1303954043-17440-4-git-send-email-decot__10780.1826707602$1303954147$gmane$org@google.com>
References: <1303954043-17440-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	mirq-linux@rere.qmqm.pl, Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyc
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:15528 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932353Ab1D1B2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 21:28:04 -0400
In-Reply-To: <1303954043-17440-1-git-send-email-decot@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes sure the ethtool's set_settings() callback of network
drivers don't ignore the 16 most significant bits when ethtool calls
their set_settings().

All drivers compiled with make allyesconfig on x86_64 have been
updated.

Tested: make allyesconfig compiles + e1000e and bnx2x work
Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/acenic.c                    |    2 +-
 drivers/net/atl1c/atl1c_ethtool.c       |    5 +++--
 drivers/net/atlx/atl1.c                 |    5 +++--
 drivers/net/b44.c                       |    7 ++++---
 drivers/net/bna/bnad_ethtool.c          |    3 ++-
 drivers/net/bnx2.c                      |   12 ++++++------
 drivers/net/cassini.c                   |   12 +++++++-----
 drivers/net/chelsio/cxgb2.c             |    7 ++++---
 drivers/net/cxgb3/cxgb3_main.c          |   10 ++++++----
 drivers/net/cxgb4/cxgb4_main.c          |   11 ++++++-----
 drivers/net/dl2k.c                      |   25 +++++++------------------
 drivers/net/e100.c                      |    8 +++++---
 drivers/net/e1000/e1000_ethtool.c       |    6 ++++--
 drivers/net/e1000e/ethtool.c            |    3 ++-
 drivers/net/enc28j60.c                  |    3 ++-
 drivers/net/forcedeth.c                 |   11 ++++++-----
 drivers/net/igb/igb_ethtool.c           |    3 ++-
 drivers/net/ixgb/ixgb_ethtool.c         |    3 ++-
 drivers/net/ixgbe/ixgbe_ethtool.c       |    3 ++-
 drivers/net/jme.c                       |    3 ++-
 drivers/net/ksz884x.c                   |    9 +++++----
 drivers/net/mii.c                       |   13 +++++++------
 drivers/net/mlx4/en_ethtool.c           |    3 ++-
 drivers/net/natsemi.c                   |    5 +++--
 drivers/net/netxen/netxen_nic_ethtool.c |    5 +++--
 drivers/net/niu.c                       |    2 +-
 drivers/net/pch_gbe/pch_gbe_ethtool.c   |    9 ++++++---
 drivers/net/pcmcia/smc91c92_cs.c        |    4 ++--
 drivers/net/phy/phy.c                   |   10 ++++++----
 drivers/net/qlcnic/qlcnic_ethtool.c     |    4 ++--
 drivers/net/r8169.c                     |    3 ++-
 drivers/net/s2io.c                      |    2 +-
 drivers/net/sc92031.c                   |    5 +++--
 drivers/net/sfc/ethtool.c               |    3 ++-
 drivers/net/sfc/mcdi_phy.c              |    4 ++--
 drivers/net/skge.c                      |    5 +++--
 drivers/net/sky2.c                      |    5 +++--
 drivers/net/sungem.c                    |    9 +++++----
 drivers/net/sunhme.c                    |    6 +++---
 drivers/net/tg3.c                       |    9 +++++----
 drivers/net/tulip/de2104x.c             |    5 +++--
 drivers/net/typhoon.c                   |   17 +++++++++--------
 drivers/net/via-velocity.c              |   10 ++++++----
 drivers/net/vxge/vxge-ethtool.c         |    3 ++-
 net/bridge/br_if.c                      |    4 ++--
 45 files changed, 164 insertions(+), 132 deletions(-)

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index ee648fe..0b4d8d1 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2718,7 +2718,7 @@ static int ace_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		link |= LNK_TX_FLOW_CTL_Y;
 	if (ecmd->autoneg == AUTONEG_ENABLE)
 		link |= LNK_NEGOTIATE;
-	if (ecmd->speed != speed) {
+	if (ethtool_cmd_speed(ecmd) != speed) {
 		link &= ~(LNK_1000MB | LNK_100MB | LNK_10MB);
 		switch (speed) {
 		case SPEED_1000:
diff --git a/drivers/net/atl1c/atl1c_ethtool.c b/drivers/net/atl1c/atl1c_ethtool.c
index 3af5a33..b1eceee 100644
--- a/drivers/net/atl1c/atl1c_ethtool.c
+++ b/drivers/net/atl1c/atl1c_ethtool.c
@@ -77,7 +77,8 @@ static int atl1c_set_settings(struct net_device *netdev,
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
 		autoneg_advertised = ADVERTISED_Autoneg;
 	} else {
-		if (ecmd->speed == SPEED_1000) {
+		u32 speed = ethtool_cmd_speed(ecmd);
+		if (speed == SPEED_1000) {
 			if (ecmd->duplex != DUPLEX_FULL) {
 				if (netif_msg_link(adapter))
 					dev_warn(&adapter->pdev->dev,
@@ -86,7 +87,7 @@ static int atl1c_set_settings(struct net_device *netdev,
 				return -EINVAL;
 			}
 			autoneg_advertised = ADVERTISED_1000baseT_Full;
-		} else if (ecmd->speed == SPEED_100) {
+		} else if (speed == SPEED_100) {
 			if (ecmd->duplex == DUPLEX_FULL)
 				autoneg_advertised = ADVERTISED_100baseT_Full;
 			else
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index dffa691..37a092f 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -3268,7 +3268,8 @@ static int atl1_set_settings(struct net_device *netdev,
 	if (ecmd->autoneg == AUTONEG_ENABLE)
 		hw->media_type = MEDIA_TYPE_AUTO_SENSOR;
 	else {
-		if (ecmd->speed == SPEED_1000) {
+		u32 speed = ethtool_cmd_speed(ecmd);
+		if (speed == SPEED_1000) {
 			if (ecmd->duplex != DUPLEX_FULL) {
 				if (netif_msg_link(adapter))
 					dev_warn(&adapter->pdev->dev,
@@ -3277,7 +3278,7 @@ static int atl1_set_settings(struct net_device *netdev,
 				goto exit_sset;
 			}
 			hw->media_type = MEDIA_TYPE_1000M_FULL;
-		} else if (ecmd->speed == SPEED_100) {
+		} else if (speed == SPEED_100) {
 			if (ecmd->duplex == DUPLEX_FULL)
 				hw->media_type = MEDIA_TYPE_100M_FULL;
 			else
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 2e2b762..909cc4b 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1831,6 +1831,7 @@ static int b44_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static int b44_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct b44 *bp = netdev_priv(dev);
+	u32 speed = ethtool_cmd_speed(cmd);
 
 	/* We do not support gigabit. */
 	if (cmd->autoneg == AUTONEG_ENABLE) {
@@ -1838,8 +1839,8 @@ static int b44_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		    (ADVERTISED_1000baseT_Half |
 		     ADVERTISED_1000baseT_Full))
 			return -EINVAL;
-	} else if ((cmd->speed != SPEED_100 &&
-		    cmd->speed != SPEED_10) ||
+	} else if ((speed != SPEED_100 &&
+		    speed != SPEED_10) ||
 		   (cmd->duplex != DUPLEX_HALF &&
 		    cmd->duplex != DUPLEX_FULL)) {
 			return -EINVAL;
@@ -1873,7 +1874,7 @@ static int b44_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	} else {
 		bp->flags |= B44_FLAG_FORCE_LINK;
 		bp->flags &= ~(B44_FLAG_100_BASE_T | B44_FLAG_FULL_DUPLEX);
-		if (cmd->speed == SPEED_100)
+		if (speed == SPEED_100)
 			bp->flags |= B44_FLAG_100_BASE_T;
 		if (cmd->duplex == DUPLEX_FULL)
 			bp->flags |= B44_FLAG_FULL_DUPLEX;
diff --git a/drivers/net/bna/bnad_ethtool.c b/drivers/net/bna/bnad_ethtool.c
index c51e078e..ae1e118 100644
--- a/drivers/net/bna/bnad_ethtool.c
+++ b/drivers/net/bna/bnad_ethtool.c
@@ -256,7 +256,8 @@ bnad_set_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 	/* 10G full duplex setting supported only */
 	if (cmd->autoneg == AUTONEG_ENABLE)
 		return -EOPNOTSUPP; else {
-		if ((cmd->speed == SPEED_10000) && (cmd->duplex == DUPLEX_FULL))
+		if ((ethtool_cmd_speed(cmd) == SPEED_10000)
+		    && (cmd->duplex == DUPLEX_FULL))
 			return 0;
 	}
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index bf729ee..e43efd8 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6758,21 +6758,21 @@ bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		advertising |= ADVERTISED_Autoneg;
 	}
 	else {
+		u32 speed = ethtool_cmd_speed(cmd);
 		if (cmd->port == PORT_FIBRE) {
-			if ((cmd->speed != SPEED_1000 &&
-			     cmd->speed != SPEED_2500) ||
+			if ((speed != SPEED_1000 &&
+			     speed != SPEED_2500) ||
 			    (cmd->duplex != DUPLEX_FULL))
 				goto err_out_unlock;
 
-			if (cmd->speed == SPEED_2500 &&
+			if (speed == SPEED_2500 &&
 			    !(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE))
 				goto err_out_unlock;
-		}
-		else if (cmd->speed == SPEED_1000 || cmd->speed == SPEED_2500)
+		} else if (speed == SPEED_1000 || speed == SPEED_2500)
 			goto err_out_unlock;
 
 		autoneg &= ~AUTONEG_SPEED;
-		req_line_speed = cmd->speed;
+		req_line_speed = speed;
 		req_duplex = cmd->duplex;
 		advertising = 0;
 	}
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 143a28c..a6c3f8c 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -709,10 +709,11 @@ static void cas_begin_auto_negotiation(struct cas *cp, struct ethtool_cmd *ep)
 	if (ep->autoneg == AUTONEG_ENABLE)
 		cp->link_cntl = BMCR_ANENABLE;
 	else {
+		u32 speed = ethtool_cmd_speed(ep);
 		cp->link_cntl = 0;
-		if (ep->speed == SPEED_100)
+		if (speed == SPEED_100)
 			cp->link_cntl |= BMCR_SPEED100;
-		else if (ep->speed == SPEED_1000)
+		else if (speed == SPEED_1000)
 			cp->link_cntl |= CAS_BMCR_SPEED1000;
 		if (ep->duplex == DUPLEX_FULL)
 			cp->link_cntl |= BMCR_FULLDPLX;
@@ -4653,6 +4654,7 @@ static int cas_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct cas *cp = netdev_priv(dev);
 	unsigned long flags;
+	u32 speed = ethtool_cmd_speed(cmd);
 
 	/* Verify the settings we care about. */
 	if (cmd->autoneg != AUTONEG_ENABLE &&
@@ -4660,9 +4662,9 @@ static int cas_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return -EINVAL;
 
 	if (cmd->autoneg == AUTONEG_DISABLE &&
-	    ((cmd->speed != SPEED_1000 &&
-	      cmd->speed != SPEED_100 &&
-	      cmd->speed != SPEED_10) ||
+	    ((speed != SPEED_1000 &&
+	      speed != SPEED_100 &&
+	      speed != SPEED_10) ||
 	     (cmd->duplex != DUPLEX_HALF &&
 	      cmd->duplex != DUPLEX_FULL)))
 		return -EINVAL;
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 5f82c9c..8e14d65 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -638,11 +638,12 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return -EOPNOTSUPP;             /* can't change speed/duplex */
 
 	if (cmd->autoneg == AUTONEG_DISABLE) {
-		int cap = speed_duplex_to_caps(cmd->speed, cmd->duplex);
+		u32 speed = ethtool_cmd_speed(cmd);
+		int cap = speed_duplex_to_caps(speed, cmd->duplex);
 
-		if (!(lc->supported & cap) || cmd->speed == SPEED_1000)
+		if (!(lc->supported & cap) || (speed == SPEED_1000))
 			return -EINVAL;
-		lc->requested_speed = cmd->speed;
+		lc->requested_speed = speed;
 		lc->requested_duplex = cmd->duplex;
 		lc->advertising = 0;
 	} else {
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 0404918..0526715 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1821,7 +1821,8 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		 * being requested.
 		 */
 		if (cmd->autoneg == AUTONEG_DISABLE) {
-			int cap = speed_duplex_to_caps(cmd->speed, cmd->duplex);
+			u32 speed = ethtool_cmd_speed(cmd);
+			int cap = speed_duplex_to_caps(speed, cmd->duplex);
 			if (lc->supported & cap)
 				return 0;
 		}
@@ -1829,11 +1830,12 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	}
 
 	if (cmd->autoneg == AUTONEG_DISABLE) {
-		int cap = speed_duplex_to_caps(cmd->speed, cmd->duplex);
+		u32 speed = ethtool_cmd_speed(cmd);
+		int cap = speed_duplex_to_caps(speed, cmd->duplex);
 
-		if (!(lc->supported & cap) || cmd->speed == SPEED_1000)
+		if (!(lc->supported & cap) || (speed == SPEED_1000))
 			return -EINVAL;
-		lc->requested_speed = cmd->speed;
+		lc->requested_speed = speed;
 		lc->requested_duplex = cmd->duplex;
 		lc->advertising = 0;
 	} else {
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index bdc868c..c02b4d3 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1460,6 +1460,7 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	unsigned int cap;
 	struct port_info *p = netdev_priv(dev);
 	struct link_config *lc = &p->link_cfg;
+	u32 speed = ethtool_cmd_speed(cmd);
 
 	if (cmd->duplex != DUPLEX_FULL)     /* only full-duplex supported */
 		return -EINVAL;
@@ -1470,16 +1471,16 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		 * being requested.
 		 */
 		if (cmd->autoneg == AUTONEG_DISABLE &&
-		    (lc->supported & speed_to_caps(cmd->speed)))
-				return 0;
+		    (lc->supported & speed_to_caps(speed)))
+			return 0;
 		return -EINVAL;
 	}
 
 	if (cmd->autoneg == AUTONEG_DISABLE) {
-		cap = speed_to_caps(cmd->speed);
+		cap = speed_to_caps(speed);
 
-		if (!(lc->supported & cap) || cmd->speed == SPEED_1000 ||
-		    cmd->speed == SPEED_10000)
+		if (!(lc->supported & cap) || (speed == SPEED_1000) ||
+		    (speed == SPEED_10000))
 			return -EINVAL;
 		lc->requested_speed = cap;
 		lc->advertising = 0;
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index c05db60..ab63989 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -1219,31 +1219,20 @@ static int rio_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	} else {
 		np->an_enable = 0;
 		if (np->speed == 1000) {
-			cmd->speed = SPEED_100;
+			ethtool_cmd_speed_set(cmd, SPEED_100);
 			cmd->duplex = DUPLEX_FULL;
 			printk("Warning!! Can't disable Auto negotiation in 1000Mbps, change to Manual 100Mbps, Full duplex.\n");
 		}
-		switch(cmd->speed + cmd->duplex) {
-
-		case SPEED_10 + DUPLEX_HALF:
-			np->speed = 10;
-			np->full_duplex = 0;
-			break;
-
-		case SPEED_10 + DUPLEX_FULL:
+		switch (ethtool_cmd_speed(cmd)) {
+		case SPEED_10:
 			np->speed = 10;
-			np->full_duplex = 1;
+			np->full_duplex = (cmd->duplex == DUPLEX_FULL);
 			break;
-		case SPEED_100 + DUPLEX_HALF:
+		case SPEED_100:
 			np->speed = 100;
-			np->full_duplex = 0;
-			break;
-		case SPEED_100 + DUPLEX_FULL:
-			np->speed = 100;
-			np->full_duplex = 1;
+			np->full_duplex = (cmd->duplex == DUPLEX_FULL);
 			break;
-		case SPEED_1000 + DUPLEX_HALF:/* not supported */
-		case SPEED_1000 + DUPLEX_FULL:/* not supported */
+		case SPEED_1000: /* not supported */
 		default:
 			return -EINVAL;
 		}
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 66ba596..c810cda 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1669,6 +1669,7 @@ static void e100_watchdog(unsigned long data)
 {
 	struct nic *nic = (struct nic *)data;
 	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
+	u32 speed;
 
 	netif_printk(nic, timer, KERN_DEBUG, nic->netdev,
 		     "right now = %ld\n", jiffies);
@@ -1676,10 +1677,11 @@ static void e100_watchdog(unsigned long data)
 	/* mii library handles link maintenance tasks */
 
 	mii_ethtool_gset(&nic->mii, &cmd);
+	speed = ethtool_cmd_speed(&cmd);
 
 	if (mii_link_ok(&nic->mii) && !netif_carrier_ok(nic->netdev)) {
 		netdev_info(nic->netdev, "NIC Link is Up %u Mbps %s Duplex\n",
-			    cmd.speed == SPEED_100 ? 100 : 10,
+			    speed == SPEED_100 ? 100 : 10,
 			    cmd.duplex == DUPLEX_FULL ? "Full" : "Half");
 	} else if (!mii_link_ok(&nic->mii) && netif_carrier_ok(nic->netdev)) {
 		netdev_info(nic->netdev, "NIC Link is Down\n");
@@ -1698,13 +1700,13 @@ static void e100_watchdog(unsigned long data)
 	spin_unlock_irq(&nic->cmd_lock);
 
 	e100_update_stats(nic);
-	e100_adjust_adaptive_ifs(nic, cmd.speed, cmd.duplex);
+	e100_adjust_adaptive_ifs(nic, speed, cmd.duplex);
 
 	if (nic->mac <= mac_82557_D100_C)
 		/* Issue a multicast command to workaround a 557 lock up */
 		e100_set_multicast_list(nic->netdev);
 
-	if (nic->flags & ich && cmd.speed==SPEED_10 && cmd.duplex==DUPLEX_HALF)
+	if (nic->flags & ich && speed == SPEED_10 && cmd.duplex == DUPLEX_HALF)
 		/* Need SW workaround for ICH[x] 10Mbps/half duplex Tx hang. */
 		nic->flags |= ich_10h_workaround;
 	else
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index dd70738..a53629d 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -197,11 +197,13 @@ static int e1000_set_settings(struct net_device *netdev,
 			                         ADVERTISED_TP |
 			                         ADVERTISED_Autoneg;
 		ecmd->advertising = hw->autoneg_advertised;
-	} else
-		if (e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex)) {
+	} else {
+		u32 speed = ethtool_cmd_speed(ecmd);
+		if (e1000_set_spd_dplx(adapter, speed + ecmd->duplex)) {
 			clear_bit(__E1000_RESETTING, &adapter->flags);
 			return -EINVAL;
 		}
+	}
 
 	/* reset the link */
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 1d7bf40..bc02c6b 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -269,7 +269,8 @@ static int e1000_set_settings(struct net_device *netdev,
 		if (adapter->fc_autoneg)
 			hw->fc.requested_mode = e1000_fc_default;
 	} else {
-		if (e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex)) {
+		u32 speed = ethtool_cmd_speed(ecmd);
+		if (e1000_set_spd_dplx(adapter, speed + ecmd->duplex)) {
 			clear_bit(__E1000_RESETTING, &adapter->state);
 			return -EINVAL;
 		}
diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index 907b05a..81a7937 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -1499,7 +1499,8 @@ enc28j60_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static int
 enc28j60_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	return enc28j60_setlink(dev, cmd->autoneg, cmd->speed, cmd->duplex);
+	return enc28j60_setlink(dev, cmd->autoneg,
+				ethtool_cmd_speed(cmd), cmd->duplex);
 }
 
 static u32 enc28j60_get_msglevel(struct net_device *dev)
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0e1c76a..d24b3f3 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4029,6 +4029,7 @@ static int nv_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct fe_priv *np = netdev_priv(dev);
+	u32 speed = ethtool_cmd_speed(ecmd);
 
 	if (ecmd->port != PORT_MII)
 		return -EINVAL;
@@ -4054,7 +4055,7 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		/* Note: autonegotiation disable, speed 1000 intentionally
 		 * forbidden - no one should need that. */
 
-		if (ecmd->speed != SPEED_10 && ecmd->speed != SPEED_100)
+		if (speed != SPEED_10 && speed != SPEED_100)
 			return -EINVAL;
 		if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
 			return -EINVAL;
@@ -4138,13 +4139,13 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 
 		adv = mii_rw(dev, np->phyaddr, MII_ADVERTISE, MII_READ);
 		adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4 | ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
-		if (ecmd->speed == SPEED_10 && ecmd->duplex == DUPLEX_HALF)
+		if (speed == SPEED_10 && ecmd->duplex == DUPLEX_HALF)
 			adv |= ADVERTISE_10HALF;
-		if (ecmd->speed == SPEED_10 && ecmd->duplex == DUPLEX_FULL)
+		if (speed == SPEED_10 && ecmd->duplex == DUPLEX_FULL)
 			adv |= ADVERTISE_10FULL;
-		if (ecmd->speed == SPEED_100 && ecmd->duplex == DUPLEX_HALF)
+		if (speed == SPEED_100 && ecmd->duplex == DUPLEX_HALF)
 			adv |= ADVERTISE_100HALF;
-		if (ecmd->speed == SPEED_100 && ecmd->duplex == DUPLEX_FULL)
+		if (speed == SPEED_100 && ecmd->duplex == DUPLEX_FULL)
 			adv |= ADVERTISE_100FULL;
 		np->pause_flags &= ~(NV_PAUSEFRAME_AUTONEG|NV_PAUSEFRAME_RX_ENABLE|NV_PAUSEFRAME_TX_ENABLE);
 		if (np->pause_flags & NV_PAUSEFRAME_RX_REQ) {/* for rx we set both advertisements but disable tx pause */
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index d976733..2cc221b 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -223,7 +223,8 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		if (adapter->fc_autoneg)
 			hw->fc.requested_mode = e1000_fc_default;
 	} else {
-		if (igb_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex)) {
+		u32 speed = ethtool_cmd_speed(ecmd);
+		if (igb_set_spd_dplx(adapter, speed + ecmd->duplex)) {
 			clear_bit(__IGB_RESETTING, &adapter->state);
 			return -EINVAL;
 		}
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index cc53aa1..edb3d7e 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -129,9 +129,10 @@ static int
 ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
+	u32 speed = ethtool_cmd_speed(ecmd);
 
 	if (ecmd->autoneg == AUTONEG_ENABLE ||
-	   ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
+	    (speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL))
 		return -EINVAL;
 
 	if (netif_running(adapter->netdev)) {
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 7279345..c52243d 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -346,9 +346,10 @@ static int ixgbe_set_settings(struct net_device *netdev,
 		}
 	} else {
 		/* in this case we currently only support 10Gb/FULL */
+		u32 speed = ethtool_cmd_speed(ecmd);
 		if ((ecmd->autoneg == AUTONEG_ENABLE) ||
 		    (ecmd->advertising != ADVERTISED_10000baseT_Full) ||
-		    (ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL))
+		    (speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL))
 			return -EINVAL;
 	}
 
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index be4773f..b5b174a 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2555,7 +2555,8 @@ jme_set_settings(struct net_device *netdev,
 	struct jme_adapter *jme = netdev_priv(netdev);
 	int rc, fdc = 0;
 
-	if (ecmd->speed == SPEED_1000 && ecmd->autoneg != AUTONEG_ENABLE)
+	if (ethtool_cmd_speed(ecmd) == SPEED_1000
+	    && ecmd->autoneg != AUTONEG_ENABLE)
 		return -EINVAL;
 
 	/*
diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 2c37a38..41ea592 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -5998,6 +5998,7 @@ static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct dev_priv *priv = netdev_priv(dev);
 	struct dev_info *hw_priv = priv->adapter;
 	struct ksz_port *port = &priv->port;
+	u32 speed = ethtool_cmd_speed(cmd);
 	int rc;
 
 	/*
@@ -6006,11 +6007,11 @@ static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	 */
 	if (cmd->autoneg && priv->advertising == cmd->advertising) {
 		cmd->advertising |= ADVERTISED_ALL;
-		if (10 == cmd->speed)
+		if (10 == speed)
 			cmd->advertising &=
 				~(ADVERTISED_100baseT_Full |
 				ADVERTISED_100baseT_Half);
-		else if (100 == cmd->speed)
+		else if (100 == speed)
 			cmd->advertising &=
 				~(ADVERTISED_10baseT_Full |
 				ADVERTISED_10baseT_Half);
@@ -6032,8 +6033,8 @@ static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		port->force_link = 0;
 	} else {
 		port->duplex = cmd->duplex + 1;
-		if (cmd->speed != 1000)
-			port->speed = cmd->speed;
+		if (1000 != speed)
+			port->speed = speed;
 		if (cmd->autoneg)
 			port->force_link = 0;
 		else
diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index 05acca7..e8198ed 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -157,10 +157,11 @@ int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 int mii_ethtool_sset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 {
 	struct net_device *dev = mii->dev;
+	u32 speed = ethtool_cmd_speed(ecmd);
 
-	if (ecmd->speed != SPEED_10 &&
-	    ecmd->speed != SPEED_100 &&
-	    ecmd->speed != SPEED_1000)
+	if (speed != SPEED_10 &&
+	    speed != SPEED_100 &&
+	    speed != SPEED_1000)
 		return -EINVAL;
 	if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
 		return -EINVAL;
@@ -172,7 +173,7 @@ int mii_ethtool_sset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 		return -EINVAL;
 	if (ecmd->autoneg != AUTONEG_DISABLE && ecmd->autoneg != AUTONEG_ENABLE)
 		return -EINVAL;
-	if ((ecmd->speed == SPEED_1000) && (!mii->supports_gmii))
+	if ((speed == SPEED_1000) && (!mii->supports_gmii))
 		return -EINVAL;
 
 	/* ignore supported, maxtxpkt, maxrxpkt */
@@ -230,9 +231,9 @@ int mii_ethtool_sset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 		bmcr = mii->mdio_read(dev, mii->phy_id, MII_BMCR);
 		tmp = bmcr & ~(BMCR_ANENABLE | BMCR_SPEED100 |
 			       BMCR_SPEED1000 | BMCR_FULLDPLX);
-		if (ecmd->speed == SPEED_1000)
+		if (speed == SPEED_1000)
 			tmp |= BMCR_SPEED1000;
-		else if (ecmd->speed == SPEED_100)
+		else if (speed == SPEED_100)
 			tmp |= BMCR_SPEED100;
 		if (ecmd->duplex == DUPLEX_FULL) {
 			tmp |= BMCR_FULLDPLX;
diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index da1b64d..be4a9e0 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -292,7 +292,8 @@ static int mlx4_en_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static int mlx4_en_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	if ((cmd->autoneg == AUTONEG_ENABLE) ||
-	    (cmd->speed != SPEED_10000) || (cmd->duplex != DUPLEX_FULL))
+	    (ethtool_cmd_speed(cmd) != SPEED_10000) ||
+	    (cmd->duplex != DUPLEX_FULL))
 		return -EINVAL;
 
 	/* Nothing to change */
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 1074231..7633c67 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2908,7 +2908,8 @@ static int netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 			return -EINVAL;
 		}
 	} else if (ecmd->autoneg == AUTONEG_DISABLE) {
-		if (ecmd->speed != SPEED_10 && ecmd->speed != SPEED_100)
+		u32 speed = ethtool_cmd_speed(ecmd);
+		if (speed != SPEED_10 && speed != SPEED_100)
 			return -EINVAL;
 		if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
 			return -EINVAL;
@@ -2956,7 +2957,7 @@ static int netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if (ecmd->advertising & ADVERTISED_100baseT_Full)
 			np->advertising |= ADVERTISE_100FULL;
 	} else {
-		np->speed  = ecmd->speed;
+		np->speed  = ethtool_cmd_speed(ecmd);
 		np->duplex = ecmd->duplex;
 		/* user overriding the initial full duplex parm? */
 		if (np->duplex == DUPLEX_HALF)
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 29f90ba..e8d16f6 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -251,6 +251,7 @@ static int
 netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
+	u32 speed = ethtool_cmd_speed(ecmd);
 	int ret;
 
 	if (adapter->ahw.port_type != NETXEN_NIC_GBE)
@@ -259,14 +260,14 @@ netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	if (!(adapter->capabilities & NX_FW_CAPABILITY_GBE_LINK_CFG))
 		return -EOPNOTSUPP;
 
-	ret = nx_fw_cmd_set_gbe_port(adapter, ecmd->speed, ecmd->duplex,
+	ret = nx_fw_cmd_set_gbe_port(adapter, speed, ecmd->duplex,
 				     ecmd->autoneg);
 	if (ret == NX_RCODE_NOT_SUPPORTED)
 		return -EOPNOTSUPP;
 	else if (ret)
 		return -EIO;
 
-	adapter->link_speed = ecmd->speed;
+	adapter->link_speed = speed;
 	adapter->link_duplex = ecmd->duplex;
 	adapter->link_autoneg = ecmd->autoneg;
 
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index a707217..524e800 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6859,7 +6859,7 @@ static int niu_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct niu_link_config *lp = &np->link_config;
 
 	lp->advertising = cmd->advertising;
-	lp->speed = cmd->speed;
+	lp->speed = ethtool_cmd_speed(cmd);
 	lp->duplex = cmd->duplex;
 	lp->autoneg = cmd->autoneg;
 	return niu_init_link(np);
diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/pch_gbe/pch_gbe_ethtool.c
index c35d105..21a2a04 100644
--- a/drivers/net/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
@@ -109,12 +109,15 @@ static int pch_gbe_set_settings(struct net_device *netdev,
 {
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
 	struct pch_gbe_hw *hw = &adapter->hw;
+	u32 speed = ethtool_cmd_speed(ecmd);
 	int ret;
 
 	pch_gbe_hal_write_phy_reg(hw, MII_BMCR, BMCR_RESET);
 
-	if (ecmd->speed == USHRT_MAX) {
-		ecmd->speed = SPEED_1000;
+	/* when set_settings() is called with a ethtool_cmd previously
+	 * filled by get_settings() on a down link, speed is -1: */
+	if (speed == UINT_MAX) {
+		speed = SPEED_1000;
 		ecmd->duplex = DUPLEX_FULL;
 	}
 	ret = mii_ethtool_sset(&adapter->mii, ecmd);
@@ -122,7 +125,7 @@ static int pch_gbe_set_settings(struct net_device *netdev,
 		pr_err("Error: mii_ethtool_sset\n");
 		return ret;
 	}
-	hw->mac.link_speed = ecmd->speed;
+	hw->mac.link_speed = speed;
 	hw->mac.link_duplex = ecmd->duplex;
 	hw->phy.autoneg_advertised = ecmd->advertising;
 	hw->mac.autoneg = ecmd->autoneg;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 1085917..bc71cb2 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -1875,8 +1875,8 @@ static int smc_netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
     u16 tmp;
     unsigned int ioaddr = dev->base_addr;
 
-    if (ecmd->speed != SPEED_10)
-    	return -EINVAL;
+    if (ethtool_cmd_speed(ecmd) != SPEED_10)
+	return -EINVAL;
     if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
     	return -EINVAL;
     if (ecmd->port != PORT_TP && ecmd->port != PORT_AUI)
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index f767033..e3f3501 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -238,6 +238,8 @@ static void phy_sanitize_settings(struct phy_device *phydev)
  */
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 {
+	u32 speed = ethtool_cmd_speed(cmd);
+
 	if (cmd->phy_address != phydev->addr)
 		return -EINVAL;
 
@@ -253,16 +255,16 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 		return -EINVAL;
 
 	if (cmd->autoneg == AUTONEG_DISABLE &&
-	    ((cmd->speed != SPEED_1000 &&
-	      cmd->speed != SPEED_100 &&
-	      cmd->speed != SPEED_10) ||
+	    ((speed != SPEED_1000 &&
+	      speed != SPEED_100 &&
+	      speed != SPEED_10) ||
 	     (cmd->duplex != DUPLEX_HALF &&
 	      cmd->duplex != DUPLEX_FULL)))
 		return -EINVAL;
 
 	phydev->autoneg = cmd->autoneg;
 
-	phydev->speed = cmd->speed;
+	phydev->speed = speed;
 
 	phydev->advertising = cmd->advertising;
 
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 615a5ab..61a4a7a 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -302,7 +302,7 @@ qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			      &status) != 0)
 			return -EIO;
 
-		switch (ecmd->speed) {
+		switch (ethtool_cmd_speed(ecmd)) {
 		case SPEED_10:
 			qlcnic_set_phy_speed(status, 0);
 			break;
@@ -323,7 +323,7 @@ qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			       *((int *)&status)) != 0)
 			return -EIO;
 		else {
-			adapter->link_speed = ecmd->speed;
+			adapter->link_speed = ethtool_cmd_speed(ecmd);
 			adapter->link_duplex = ecmd->duplex;
 		}
 	} else
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 6364e0b..b52ee17 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1349,7 +1349,8 @@ static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	spin_lock_irqsave(&tp->lock, flags);
 	ret = rtl8169_set_speed(dev,
-		cmd->autoneg, cmd->speed, cmd->duplex, cmd->advertising);
+				cmd->autoneg, ethtool_cmd_speed(cmd),
+				cmd->duplex, cmd->advertising);
 	spin_unlock_irqrestore(&tp->lock, flags);
 
 	return ret;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 58b78f4..5443985 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -5380,7 +5380,7 @@ static int s2io_ethtool_sset(struct net_device *dev,
 {
 	struct s2io_nic *sp = netdev_priv(dev);
 	if ((info->autoneg == AUTONEG_ENABLE) ||
-	    (info->speed != SPEED_10000) ||
+	    (ethtool_cmd_speed(info) != SPEED_10000) ||
 	    (info->duplex != DUPLEX_FULL))
 		return -EINVAL;
 	else {
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 76290a8..f3ffc1d 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1188,10 +1188,11 @@ static int sc92031_ethtool_set_settings(struct net_device *dev,
 {
 	struct sc92031_priv *priv = netdev_priv(dev);
 	void __iomem *port_base = priv->port_base;
+	u32 speed = ethtool_cmd_speed(cmd);
 	u32 phy_ctrl;
 	u32 old_phy_ctrl;
 
-	if (!(cmd->speed == SPEED_10 || cmd->speed == SPEED_100))
+	if (!(speed == SPEED_10 || speed == SPEED_100))
 		return -EINVAL;
 	if (!(cmd->duplex == DUPLEX_HALF || cmd->duplex == DUPLEX_FULL))
 		return -EINVAL;
@@ -1229,7 +1230,7 @@ static int sc92031_ethtool_set_settings(struct net_device *dev,
 		// FIXME: Whole branch guessed
 		phy_ctrl = 0;
 
-		if (cmd->speed == SPEED_10)
+		if (speed == SPEED_10)
 			phy_ctrl |= PhyCtrlSpd10;
 		else /* cmd->speed == SPEED_100 */
 			phy_ctrl |= PhyCtrlSpd100;
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 5d8468f..10b160a 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -234,7 +234,8 @@ static int efx_ethtool_set_settings(struct net_device *net_dev,
 	int rc;
 
 	/* GMAC does not support 1000Mbps HD */
-	if (ecmd->speed == SPEED_1000 && ecmd->duplex != DUPLEX_FULL) {
+	if ((ethtool_cmd_speed(ecmd) == SPEED_1000) &&
+	    (ecmd->duplex != DUPLEX_FULL)) {
 		netif_dbg(efx, drv, efx->net_dev,
 			  "rejecting unsupported 1000Mbps HD setting\n");
 		return -EINVAL;
diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/sfc/mcdi_phy.c
index 1fcda2d..6c5fccb 100644
--- a/drivers/net/sfc/mcdi_phy.c
+++ b/drivers/net/sfc/mcdi_phy.c
@@ -545,7 +545,7 @@ static int efx_mcdi_phy_set_settings(struct efx_nic *efx, struct ethtool_cmd *ec
 		caps = (ethtool_to_mcdi_cap(ecmd->advertising) |
 			 1 << MC_CMD_PHY_CAP_AN_LBN);
 	} else if (ecmd->duplex) {
-		switch (ecmd->speed) {
+		switch (ethtool_cmd_speed(ecmd)) {
 		case 10:    caps = 1 << MC_CMD_PHY_CAP_10FDX_LBN;    break;
 		case 100:   caps = 1 << MC_CMD_PHY_CAP_100FDX_LBN;   break;
 		case 1000:  caps = 1 << MC_CMD_PHY_CAP_1000FDX_LBN;  break;
@@ -553,7 +553,7 @@ static int efx_mcdi_phy_set_settings(struct efx_nic *efx, struct ethtool_cmd *ec
 		default:    return -EINVAL;
 		}
 	} else {
-		switch (ecmd->speed) {
+		switch (ethtool_cmd_speed(ecmd)) {
 		case 10:    caps = 1 << MC_CMD_PHY_CAP_10HDX_LBN;    break;
 		case 100:   caps = 1 << MC_CMD_PHY_CAP_100HDX_LBN;   break;
 		case 1000:  caps = 1 << MC_CMD_PHY_CAP_1000HDX_LBN;  break;
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 176d784..a05e864 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -321,8 +321,9 @@ static int skge_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		skge->speed = -1;
 	} else {
 		u32 setting;
+		u32 speed = ethtool_cmd_speed(ecmd);
 
-		switch (ecmd->speed) {
+		switch (speed) {
 		case SPEED_1000:
 			if (ecmd->duplex == DUPLEX_FULL)
 				setting = SUPPORTED_1000baseT_Full;
@@ -355,7 +356,7 @@ static int skge_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if ((setting & supported) == 0)
 			return -EINVAL;
 
-		skge->speed = ecmd->speed;
+		skge->speed = speed;
 		skge->duplex = ecmd->duplex;
 	}
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index c8d0451..5c7e2d6 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3452,8 +3452,9 @@ static int sky2_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		sky2->speed = -1;
 	} else {
 		u32 setting;
+		u32 speed = ethtool_cmd_speed(ecmd);
 
-		switch (ecmd->speed) {
+		switch (speed) {
 		case SPEED_1000:
 			if (ecmd->duplex == DUPLEX_FULL)
 				setting = SUPPORTED_1000baseT_Full;
@@ -3486,7 +3487,7 @@ static int sky2_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if ((setting & supported) == 0)
 			return -EINVAL;
 
-		sky2->speed = ecmd->speed;
+		sky2->speed = speed;
 		sky2->duplex = ecmd->duplex;
 		sky2->flags &= ~SKY2_FLAG_AUTO_SPEED;
 	}
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 81b6eb8..40a755d 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1294,7 +1294,7 @@ static void gem_begin_auto_negotiation(struct gem *gp, struct ethtool_cmd *ep)
 		autoneg = 1;
 	} else {
 		autoneg = 0;
-		speed = ep->speed;
+		speed = ethtool_cmd_speed(ep);
 		duplex = ep->duplex;
 	}
 
@@ -2686,6 +2686,7 @@ static int gem_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static int gem_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct gem *gp = netdev_priv(dev);
+	u32 speed = ethtool_cmd_speed(cmd);
 
 	/* Verify the settings we care about. */
 	if (cmd->autoneg != AUTONEG_ENABLE &&
@@ -2697,9 +2698,9 @@ static int gem_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return -EINVAL;
 
 	if (cmd->autoneg == AUTONEG_DISABLE &&
-	    ((cmd->speed != SPEED_1000 &&
-	      cmd->speed != SPEED_100 &&
-	      cmd->speed != SPEED_10) ||
+	    ((speed != SPEED_1000 &&
+	      speed != SPEED_100 &&
+	      speed != SPEED_10) ||
 	     (cmd->duplex != DUPLEX_HALF &&
 	      cmd->duplex != DUPLEX_FULL)))
 		return -EINVAL;
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 80e907d..8f3f028 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -1383,7 +1383,7 @@ force_link:
 		if (ep == NULL || ep->autoneg == AUTONEG_ENABLE) {
 			hp->sw_bmcr = BMCR_SPEED100;
 		} else {
-			if (ep->speed == SPEED_100)
+			if (ethtool_cmd_speed(ep) == SPEED_100)
 				hp->sw_bmcr = BMCR_SPEED100;
 			else
 				hp->sw_bmcr = 0;
@@ -2452,8 +2452,8 @@ static int hme_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	    cmd->autoneg != AUTONEG_DISABLE)
 		return -EINVAL;
 	if (cmd->autoneg == AUTONEG_DISABLE &&
-	    ((cmd->speed != SPEED_100 &&
-	      cmd->speed != SPEED_10) ||
+	    ((ethtool_cmd_speed(cmd) != SPEED_100 &&
+	      ethtool_cmd_speed(cmd) != SPEED_10) ||
 	     (cmd->duplex != DUPLEX_HALF &&
 	      cmd->duplex != DUPLEX_FULL)))
 		return -EINVAL;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b20538a..84f62af 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10044,6 +10044,7 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct tg3 *tp = netdev_priv(dev);
+	u32 speed = ethtool_cmd_speed(cmd);
 
 	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
 		struct phy_device *phydev;
@@ -10093,14 +10094,14 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->advertising &= mask;
 	} else {
 		if (tp->phy_flags & TG3_PHYFLG_ANY_SERDES) {
-			if (cmd->speed != SPEED_1000)
+			if (speed != SPEED_1000)
 				return -EINVAL;
 
 			if (cmd->duplex != DUPLEX_FULL)
 				return -EINVAL;
 		} else {
-			if (cmd->speed != SPEED_100 &&
-			    cmd->speed != SPEED_10)
+			if (speed != SPEED_100 &&
+			    speed != SPEED_10)
 				return -EINVAL;
 		}
 	}
@@ -10115,7 +10116,7 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		tp->link_config.duplex = DUPLEX_INVALID;
 	} else {
 		tp->link_config.advertising = 0;
-		tp->link_config.speed = cmd->speed;
+		tp->link_config.speed = speed;
 		tp->link_config.duplex = cmd->duplex;
 	}
 
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index b13c6b0..f8d26bf 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1549,10 +1549,11 @@ static int __de_set_settings(struct de_private *de, struct ethtool_cmd *ecmd)
 {
 	u32 new_media;
 	unsigned int media_lock;
+	u32 speed = ethtool_cmd_speed(ecmd);
 
-	if (ecmd->speed != SPEED_10 && ecmd->speed != 5 && ecmd->speed != 2)
+	if (speed != SPEED_10 && speed != 5 && speed != 2)
 		return -EINVAL;
-	if (de->de21040 && ecmd->speed == 2)
+	if (de->de21040 && speed == 2)
 		return -EINVAL;
 	if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
 		return -EINVAL;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 119c394..9f11c11 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1068,25 +1068,26 @@ static int
 typhoon_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct typhoon *tp = netdev_priv(dev);
+	u32 speed = ethtool_cmd_speed(cmd);
 	struct cmd_desc xp_cmd;
 	__le16 xcvr;
 	int err;
 
 	err = -EINVAL;
-	if(cmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->autoneg == AUTONEG_ENABLE) {
 		xcvr = TYPHOON_XCVR_AUTONEG;
 	} else {
-		if(cmd->duplex == DUPLEX_HALF) {
-			if(cmd->speed == SPEED_10)
+		if (cmd->duplex == DUPLEX_HALF) {
+			if (speed == SPEED_10)
 				xcvr = TYPHOON_XCVR_10HALF;
-			else if(cmd->speed == SPEED_100)
+			else if (speed == SPEED_100)
 				xcvr = TYPHOON_XCVR_100HALF;
 			else
 				goto out;
-		} else if(cmd->duplex == DUPLEX_FULL) {
-			if(cmd->speed == SPEED_10)
+		} else if (cmd->duplex == DUPLEX_FULL) {
+			if (speed == SPEED_10)
 				xcvr = TYPHOON_XCVR_10FULL;
-			else if(cmd->speed == SPEED_100)
+			else if (speed == SPEED_100)
 				xcvr = TYPHOON_XCVR_100FULL;
 			else
 				goto out;
@@ -1105,7 +1106,7 @@ typhoon_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		tp->speed = 0xff;	/* invalid */
 		tp->duplex = 0xff;	/* invalid */
 	} else {
-		tp->speed = cmd->speed;
+		tp->speed = speed;
 		tp->duplex = cmd->duplex;
 	}
 
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index baf04b0..9a8f116 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -3247,9 +3247,11 @@ static int velocity_get_settings(struct net_device *dev, struct ethtool_cmd *cmd
 	return 0;
 }
 
-static int velocity_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int velocity_set_settings(struct net_device *dev,
+				 struct ethtool_cmd *cmd)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
+	u32 speed = ethtool_cmd_speed(cmd);
 	u32 curr_status;
 	u32 new_status = 0;
 	int ret = 0;
@@ -3258,9 +3260,9 @@ static int velocity_set_settings(struct net_device *dev, struct ethtool_cmd *cmd
 	curr_status &= (~VELOCITY_LINK_FAIL);
 
 	new_status |= ((cmd->autoneg) ? VELOCITY_AUTONEG_ENABLE : 0);
-	new_status |= ((cmd->speed == SPEED_1000) ? VELOCITY_SPEED_1000 : 0);
-	new_status |= ((cmd->speed == SPEED_100) ? VELOCITY_SPEED_100 : 0);
-	new_status |= ((cmd->speed == SPEED_10) ? VELOCITY_SPEED_10 : 0);
+	new_status |= ((speed == SPEED_1000) ? VELOCITY_SPEED_1000 : 0);
+	new_status |= ((speed == SPEED_100) ? VELOCITY_SPEED_100 : 0);
+	new_status |= ((speed == SPEED_10) ? VELOCITY_SPEED_10 : 0);
 	new_status |= ((cmd->duplex == DUPLEX_FULL) ? VELOCITY_DUPLEX_FULL : 0);
 
 	if ((new_status & VELOCITY_AUTONEG_ENABLE) &&
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-ethtool.c
index 5aef6c8..a70874e 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -33,7 +33,8 @@ static int vxge_ethtool_sset(struct net_device *dev, struct ethtool_cmd *info)
 {
 	/* We currently only support 10Gb/FULL */
 	if ((info->autoneg == AUTONEG_ENABLE) ||
-	    (info->speed != SPEED_10000) || (info->duplex != DUPLEX_FULL))
+	    (ethtool_cmd_speed(info) != SPEED_10000) ||
+	    (info->duplex != DUPLEX_FULL))
 		return -EINVAL;
 
 	return 0;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 7f5379c..c57d187 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -36,8 +36,8 @@ static int port_cost(struct net_device *dev)
 	if (dev->ethtool_ops && dev->ethtool_ops->get_settings) {
 		struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET, };
 
-		if (!dev->ethtool_ops->get_settings(dev, &ecmd)) {
-			switch(ecmd.speed) {
+		if (!dev_ethtool_get_settings(dev, &ecmd)) {
+			switch (ethtool_cmd_speed(&ecmd)) {
 			case SPEED_10000:
 				return 2;
 			case SPEED_1000:
-- 
1.7.3.1

