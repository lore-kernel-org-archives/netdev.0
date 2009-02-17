From: Constantin Baranov <baranov@mercdev.com>
Subject: [PATCH 2/2] niu: improve ethtool support for gigabit copper cards
Date: Tue, 17 Feb 2009 15:43:34 +0400
Message-ID: <20090217154334.97837477.baranov@mercdev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.dewahost.net ([205.234.111.6]:48638 "EHLO
	titan.dewahost.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbZBQLnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 06:43:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduced support for link speed and duplex setting (ethtool -s),
link advertising parameters and autonegotiation (ethtool -r):
- struct niu_link_config: split advertising and autoneg
  fields into active and target values (similar to speed
  and duplex fields)
- mii_init_common(): rewrite function to actually apply
  requested niu_link_config parameters instead of providing
  default initialization
- link_status_1g(): move parsing of MII registers into
  new link_status_mii() function (link_status_1g_rgmii()
  could possibly use this new implementation too)
- introduce simple nway_reset method
- fix incorrect XMAC_CONFIG_MODE selection for 10Mbps case

Signed-off-by: Constantin Baranov <baranov@mercdev.com>
---
 drivers/net/niu.c |  345 ++++++++++++++++++++++++++++++++++++-----------------
 drivers/net/niu.h |    5 +-
 2 files changed, 242 insertions(+), 108 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 15c9e5f..db7c34f 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -1115,6 +1115,130 @@ static int link_status_10g_serdes(struct niu *np, int *link_up_p)
 	return 0;
 }
 
+static int link_status_mii(struct niu *np, int *link_up_p)
+{
+	struct niu_link_config *lp = &np->link_config;
+	int err;
+	int bmsr, advert, ctrl1000, stat1000, lpa, bmcr, estatus;
+	int supported, advertising, active_speed, active_duplex;
+
+	err = mii_read(np, np->phy_addr, MII_BMCR);
+	if (unlikely(err < 0))
+		return err;
+	bmcr = err;
+
+	err = mii_read(np, np->phy_addr, MII_BMSR);
+	if (unlikely(err < 0))
+		return err;
+	bmsr = err;
+
+	err = mii_read(np, np->phy_addr, MII_ADVERTISE);
+	if (unlikely(err < 0))
+		return err;
+	advert = err;
+
+	err = mii_read(np, np->phy_addr, MII_LPA);
+	if (unlikely(err < 0))
+		return err;
+	lpa = err;
+
+	if (likely(bmsr & BMSR_ESTATEN)) {
+		err = mii_read(np, np->phy_addr, MII_ESTATUS);
+		if (unlikely(err < 0))
+			return err;
+		estatus = err;
+
+		err = mii_read(np, np->phy_addr, MII_CTRL1000);
+		if (unlikely(err < 0))
+			return err;
+		ctrl1000 = err;
+
+		err = mii_read(np, np->phy_addr, MII_STAT1000);
+		if (unlikely(err < 0))
+			return err;
+		stat1000 = err;
+	} else
+		estatus = ctrl1000 = stat1000 = 0;
+
+	supported = 0;
+	if (bmsr & BMSR_ANEGCAPABLE)
+		supported |= SUPPORTED_Autoneg;
+	if (bmsr & BMSR_10HALF)
+		supported |= SUPPORTED_10baseT_Half;
+	if (bmsr & BMSR_10FULL)
+		supported |= SUPPORTED_10baseT_Full;
+	if (bmsr & BMSR_100HALF)
+		supported |= SUPPORTED_100baseT_Half;
+	if (bmsr & BMSR_100FULL)
+		supported |= SUPPORTED_100baseT_Full;
+	if (estatus & ESTATUS_1000_THALF)
+		supported |= SUPPORTED_1000baseT_Half;
+	if (estatus & ESTATUS_1000_TFULL)
+		supported |= SUPPORTED_1000baseT_Full;
+	lp->supported = supported;
+
+	advertising = 0;
+	if (advert & ADVERTISE_10HALF)
+		advertising |= ADVERTISED_10baseT_Half;
+	if (advert & ADVERTISE_10FULL)
+		advertising |= ADVERTISED_10baseT_Full;
+	if (advert & ADVERTISE_100HALF)
+		advertising |= ADVERTISED_100baseT_Half;
+	if (advert & ADVERTISE_100FULL)
+		advertising |= ADVERTISED_100baseT_Full;
+	if (ctrl1000 & ADVERTISE_1000HALF)
+		advertising |= ADVERTISED_1000baseT_Half;
+	if (ctrl1000 & ADVERTISE_1000FULL)
+		advertising |= ADVERTISED_1000baseT_Full;
+
+	if (bmcr & BMCR_ANENABLE) {
+		int neg, neg1000;
+
+		lp->active_autoneg = 1;
+		advertising |= ADVERTISED_Autoneg;
+
+		neg = advert & lpa;
+		neg1000 = (ctrl1000 << 2) & stat1000;
+
+		if (neg1000 & (LPA_1000FULL | LPA_1000HALF))
+			active_speed = SPEED_1000;
+		else if (neg & LPA_100)
+			active_speed = SPEED_100;
+		else if (neg & (LPA_10HALF | LPA_10FULL))
+			active_speed = SPEED_10;
+		else
+			active_speed = SPEED_INVALID;
+
+		if ((neg1000 & LPA_1000FULL) || (neg & LPA_DUPLEX))
+			active_duplex = DUPLEX_FULL;
+		else if (active_speed != SPEED_INVALID)
+			active_duplex = DUPLEX_HALF;
+		else
+			active_duplex = DUPLEX_INVALID;
+	} else {
+		lp->active_autoneg = 0;
+
+		if ((bmcr & BMCR_SPEED1000) && !(bmcr & BMCR_SPEED100))
+			active_speed = SPEED_1000;
+		else if (bmcr & BMCR_SPEED100)
+			active_speed = SPEED_100;
+		else
+			active_speed = SPEED_10;
+
+		if (bmcr & BMCR_FULLDPLX)
+			active_duplex = DUPLEX_FULL;
+		else
+			active_duplex = DUPLEX_HALF;
+	}
+
+	lp->active_advertising = advertising;
+	lp->active_speed = active_speed;
+	lp->active_duplex = active_duplex;
+	*link_up_p = !!(bmsr & BMSR_LSTATUS);
+
+	return 0;
+}
+
 static int link_status_1g_rgmii(struct niu *np, int *link_up_p)
 {
 	struct niu_link_config *lp = &np->link_config;
@@ -1171,6 +1295,22 @@ out:
 	return err;
 }
 
+static int link_status_1g(struct niu *np, int *link_up_p)
+{
+	struct niu_link_config *lp = &np->link_config;
+	unsigned long flags;
+	int err;
+
+	spin_lock_irqsave(&np->lock, flags);
+
+	err = link_status_mii(np, link_up_p);
+	lp->supported |= SUPPORTED_TP;
+	lp->active_advertising |= ADVERTISED_TP;
+
+	spin_unlock_irqrestore(&np->lock, flags);
+	return err;
+}
+
 static int bcm8704_reset(struct niu *np)
 {
 	int err, limit;
@@ -1676,39 +1816,88 @@ static int mii_init_common(struct niu *np)
 			return err;
 	}
 
-	/* XXX configurable XXX */
-	/* XXX for now don't advertise half-duplex or asym pause... XXX */
-	adv = ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP;
-	if (bmsr & BMSR_10FULL)
-		adv |= ADVERTISE_10FULL;
-	if (bmsr & BMSR_100FULL)
-		adv |= ADVERTISE_100FULL;
-	err = mii_write(np, np->phy_addr, MII_ADVERTISE, adv);
-	if (err)
-		return err;
-
-	if (bmsr & BMSR_ESTATEN) {
-		u16 ctrl1000 = 0;
-
-		if (estat & ESTATUS_1000_TFULL)
-			ctrl1000 |= ADVERTISE_1000FULL;
-		err = mii_write(np, np->phy_addr, MII_CTRL1000, ctrl1000);
+	if (lp->autoneg) {
+		u16 ctrl1000;
+
+		adv = ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP;
+		if ((bmsr & BMSR_10HALF) &&
+			(lp->advertising & ADVERTISED_10baseT_Half))
+			adv |= ADVERTISE_10HALF;
+		if ((bmsr & BMSR_10FULL) &&
+			(lp->advertising & ADVERTISED_10baseT_Full))
+			adv |= ADVERTISE_10FULL;
+		if ((bmsr & BMSR_100HALF) &&
+			(lp->advertising & ADVERTISED_100baseT_Half))
+			adv |= ADVERTISE_100HALF;
+		if ((bmsr & BMSR_100FULL) &&
+			(lp->advertising & ADVERTISED_100baseT_Full))
+			adv |= ADVERTISE_100FULL;
+		err = mii_write(np, np->phy_addr, MII_ADVERTISE, adv);
 		if (err)
 			return err;
+
+		if (likely(bmsr & BMSR_ESTATEN)) {
+			ctrl1000 = 0;
+			if ((estat & ESTATUS_1000_THALF) &&
+				(lp->advertising & ADVERTISED_1000baseT_Half))
+				ctrl1000 |= ADVERTISE_1000HALF;
+			if ((estat & ESTATUS_1000_TFULL) &&
+				(lp->advertising & ADVERTISED_1000baseT_Full))
+				ctrl1000 |= ADVERTISE_1000FULL;
+			err = mii_write(np, np->phy_addr,
+					MII_CTRL1000, ctrl1000);
+			if (err)
+				return err;
+		}
+
+		bmcr |= (BMCR_ANENABLE | BMCR_ANRESTART);
+	} else {
+		/* !lp->autoneg */
+		int fulldpx;
+
+		if (lp->duplex == DUPLEX_FULL) {
+			bmcr |= BMCR_FULLDPLX;
+			fulldpx = 1;
+		} else if (lp->duplex == DUPLEX_HALF)
+			fulldpx = 0;
+		else
+			return -EINVAL;
+
+		if (lp->speed == SPEED_1000) {
+			/* if X-full requested while not supported, or
+			   X-half requested while not supported... */
+			if ((fulldpx && !(estat & ESTATUS_1000_TFULL)) ||
+				(!fulldpx && !(estat & ESTATUS_1000_THALF)))
+				return -EINVAL;
+			bmcr |= BMCR_SPEED1000;
+		} else if (lp->speed == SPEED_100) {
+			if ((fulldpx && !(bmsr & BMSR_100FULL)) ||
+				(!fulldpx && !(bmsr & BMSR_100HALF)))
+				return -EINVAL;
+			bmcr |= BMCR_SPEED100;
+		} else if (lp->speed == SPEED_10) {
+			if ((fulldpx && !(bmsr & BMSR_10FULL)) ||
+				(!fulldpx && !(bmsr & BMSR_10HALF)))
+				return -EINVAL;
+		} else
+			return -EINVAL;
 	}
-	bmcr |= (BMCR_ANENABLE | BMCR_ANRESTART);
 
 	err = mii_write(np, np->phy_addr, MII_BMCR, bmcr);
 	if (err)
 		return err;
 
+#if 0
 	err = mii_read(np, np->phy_addr, MII_BMCR);
 	if (err < 0)
 		return err;
+	bmcr = err;
+
 	err = mii_read(np, np->phy_addr, MII_BMSR);
 	if (err < 0)
 		return err;
-#if 0
+	bmsr = err;
+
 	pr_info(PFX "Port %u after MII init bmcr[%04x] bmsr[%04x]\n",
 		np->port, bmcr, bmsr);
 #endif
@@ -2054,87 +2243,6 @@ static int link_status_10g_hotplug(struct niu *np, int *link_up_p)
 	return err;
 }
 
-static int link_status_1g(struct niu *np, int *link_up_p)
-{
-	struct niu_link_config *lp = &np->link_config;
-	u16 current_speed, bmsr;
-	unsigned long flags;
-	u8 current_duplex;
-	int err, link_up;
-
-	link_up = 0;
-	current_speed = SPEED_INVALID;
-	current_duplex = DUPLEX_INVALID;
-
-	spin_lock_irqsave(&np->lock, flags);
-
-	err = -EINVAL;
-	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
-		goto out;
-
-	err = mii_read(np, np->phy_addr, MII_BMSR);
-	if (err < 0)
-		goto out;
-
-	bmsr = err;
-	if (bmsr & BMSR_LSTATUS) {
-		u16 adv, lpa, common, estat;
-
-		err = mii_read(np, np->phy_addr, MII_ADVERTISE);
-		if (err < 0)
-			goto out;
-		adv = err;
-
-		err = mii_read(np, np->phy_addr, MII_LPA);
-		if (err < 0)
-			goto out;
-		lpa = err;
-
-		common = adv & lpa;
-
-		err = mii_read(np, np->phy_addr, MII_ESTATUS);
-		if (err < 0)
-			goto out;
-		estat = err;
-
-		link_up = 1;
-		if (estat & (ESTATUS_1000_TFULL | ESTATUS_1000_THALF)) {
-			current_speed = SPEED_1000;
-			if (estat & ESTATUS_1000_TFULL)
-				current_duplex = DUPLEX_FULL;
-			else
-				current_duplex = DUPLEX_HALF;
-		} else {
-			if (common & ADVERTISE_100BASE4) {
-				current_speed = SPEED_100;
-				current_duplex = DUPLEX_HALF;
-			} else if (common & ADVERTISE_100FULL) {
-				current_speed = SPEED_100;
-				current_duplex = DUPLEX_FULL;
-			} else if (common & ADVERTISE_100HALF) {
-				current_speed = SPEED_100;
-				current_duplex = DUPLEX_HALF;
-			} else if (common & ADVERTISE_10FULL) {
-				current_speed = SPEED_10;
-				current_duplex = DUPLEX_FULL;
-			} else if (common & ADVERTISE_10HALF) {
-				current_speed = SPEED_10;
-				current_duplex = DUPLEX_HALF;
-			} else
-				link_up = 0;
-		}
-	}
-	lp->active_speed = current_speed;
-	lp->active_duplex = current_duplex;
-	err = 0;
-
-out:
-	spin_unlock_irqrestore(&np->lock, flags);
-
-	*link_up_p = link_up;
-	return err;
-}
-
 static int niu_link_status(struct niu *np, int *link_up_p)
 {
 	const struct niu_phy_ops *ops = np->phy_ops;
@@ -5211,10 +5319,10 @@ static void niu_init_xif_xmac(struct niu *np)
 	if (np->flags & NIU_FLAGS_10G) {
 		val |= XMAC_CONFIG_MODE_XGMII;
 	} else {
-		if (lp->active_speed == SPEED_100)
-			val |= XMAC_CONFIG_MODE_MII;
-		else
+		if (lp->active_speed == SPEED_1000)
 			val |= XMAC_CONFIG_MODE_GMII;
+		else
+			val |= XMAC_CONFIG_MODE_MII;
 	}
 
 	nw64_mac(XMAC_CONFIG, val);
@@ -6702,17 +6810,27 @@ static int niu_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	memset(cmd, 0, sizeof(*cmd));
 	cmd->phy_address = np->phy_addr;
 	cmd->supported = lp->supported;
-	cmd->advertising = lp->advertising;
-	cmd->autoneg = lp->autoneg;
+	cmd->advertising = lp->active_advertising;
+	cmd->autoneg = lp->active_autoneg;
 	cmd->speed = lp->active_speed;
 	cmd->duplex = lp->active_duplex;
+	cmd->port = (np->flags & NIU_FLAGS_FIBER) ? PORT_FIBRE : PORT_TP;
+	cmd->transceiver = (np->flags & NIU_FLAGS_XCVR_SERDES) ?
+		XCVR_EXTERNAL : XCVR_INTERNAL;
 
 	return 0;
 }
 
 static int niu_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	return -EINVAL;
+	struct niu *np = netdev_priv(dev);
+	struct niu_link_config *lp = &np->link_config;
+
+	lp->advertising = cmd->advertising;
+	lp->speed = cmd->speed;
+	lp->duplex = cmd->duplex;
+	lp->autoneg = cmd->autoneg;
+	return niu_init_link(np);
 }
 
 static u32 niu_get_msglevel(struct net_device *dev)
@@ -6727,6 +6845,16 @@ static void niu_set_msglevel(struct net_device *dev, u32 value)
 	np->msg_enable = value;
 }
 
+static int niu_nway_reset(struct net_device *dev)
+{
+	struct niu *np = netdev_priv(dev);
+
+	if (np->link_config.autoneg)
+		return niu_init_link(np);
+
+	return 0;
+}
+
 static int niu_get_eeprom_len(struct net_device *dev)
 {
 	struct niu *np = netdev_priv(dev);
@@ -7158,6 +7286,7 @@ static const struct ethtool_ops niu_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_msglevel		= niu_get_msglevel,
 	.set_msglevel		= niu_set_msglevel,
+	.nway_reset		= niu_nway_reset,
 	.get_eeprom_len		= niu_get_eeprom_len,
 	.get_eeprom		= niu_get_eeprom,
 	.get_settings		= niu_get_settings,
@@ -8257,7 +8386,9 @@ static void __devinit niu_link_config_init(struct niu *np)
 			   ADVERTISED_10000baseT_Full |
 			   ADVERTISED_Autoneg);
 	lp->speed = lp->active_speed = SPEED_INVALID;
-	lp->duplex = lp->active_duplex = DUPLEX_INVALID;
+	lp->duplex = DUPLEX_FULL;
+	lp->active_duplex = DUPLEX_INVALID;
+	lp->autoneg = 1;
 #if 0
 	lp->loopback_mode = LOOPBACK_MAC;
 	lp->active_speed = SPEED_10000;
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index e1a7392..5a00237 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -3131,16 +3131,19 @@ struct niu_ops {
 };
 
 struct niu_link_config {
+	u32				supported;
+
 	/* Describes what we're trying to get. */
 	u32				advertising;
-	u32				supported;
 	u16				speed;
 	u8				duplex;
 	u8				autoneg;
 
 	/* Describes what we actually have. */
+	u32				active_advertising;
 	u16				active_speed;
 	u8				active_duplex;
+	u8				active_autoneg;
 #define SPEED_INVALID		0xffff
 #define DUPLEX_INVALID		0xff
 #define AUTONEG_INVALID		0xff
-- 
1.6.0.6

