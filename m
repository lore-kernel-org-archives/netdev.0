From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH] b44: fix ethool link settings support
Date: Fri, 21 Apr 2006 06:04:08 -0700
Message-ID: <1145624648.18928.8.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:53514 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932378AbWDUUF3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 16:05:29 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the driver support for ethtool settings for speed/duplex/autoneg.


Signed-off-by: Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 3d30668..be266a9 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -433,10 +433,10 @@ static int b44_setup_phy(struct b44 *bp)
 	u32 val;
 	int err;
 
-	if ((err = b44_readphy(bp, B44_MII_ALEDCTRL, &val)) != 0)
+	if ((err = b44_readphy(bp, B44_MII_INTERRUPTS, &val)) != 0)
 		goto out;
-	if ((err = b44_writephy(bp, B44_MII_ALEDCTRL,
-				val & MII_ALEDCTRL_ALLMSK)) != 0)
+	if ((err = b44_writephy(bp, B44_MII_INTERRUPTS,
+				val & MII_INTS_ALLMSK)) != 0)
 		goto out;
 	if ((err = b44_readphy(bp, B44_MII_TLEDCTRL, &val)) != 0)
 		goto out;
@@ -465,11 +465,7 @@ static int b44_setup_phy(struct b44 *bp)
 						       BMCR_ANRESTART))) != 0)
 			goto out;
 	} else {
-		u32 bmcr;
-
-		if ((err = b44_readphy(bp, MII_BMCR, &bmcr)) != 0)
-			goto out;
-		bmcr &= ~(BMCR_FULLDPLX | BMCR_ANENABLE | BMCR_SPEED100);
+		u32 bmcr = 0;
 		if (bp->flags & B44_FLAG_100_BASE_T)
 			bmcr |= BMCR_SPEED100;
 		if (bp->flags & B44_FLAG_FULL_DUPLEX)
@@ -1612,8 +1608,6 @@ static int b44_get_settings(struct net_d
 {
 	struct b44 *bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
-		return -EAGAIN;
 	cmd->supported = (SUPPORTED_Autoneg);
 	cmd->supported |= (SUPPORTED_100baseT_Half |
 			  SUPPORTED_100baseT_Full |
@@ -1621,7 +1615,6 @@ static int b44_get_settings(struct net_d
 			  SUPPORTED_10baseT_Full |
 			  SUPPORTED_MII);
 
-	cmd->advertising = 0;
 	if (bp->flags & B44_FLAG_ADV_10HALF)
 		cmd->advertising |= ADVERTISED_10baseT_Half;
 	if (bp->flags & B44_FLAG_ADV_10FULL)
@@ -1631,18 +1624,22 @@ static int b44_get_settings(struct net_d
 	if (bp->flags & B44_FLAG_ADV_100FULL)
 		cmd->advertising |= ADVERTISED_100baseT_Full;
 	cmd->advertising |= ADVERTISED_Pause | ADVERTISED_Asym_Pause;
-	cmd->speed = (bp->flags & B44_FLAG_100_BASE_T) ?
-		SPEED_100 : SPEED_10;
-	cmd->duplex = (bp->flags & B44_FLAG_FULL_DUPLEX) ?
-		DUPLEX_FULL : DUPLEX_HALF;
-	cmd->port = 0;
-	cmd->phy_address = bp->phy_addr;
 	cmd->transceiver = (bp->flags & B44_FLAG_INTERNAL_PHY) ?
 		XCVR_INTERNAL : XCVR_EXTERNAL;
-	cmd->autoneg = (bp->flags & B44_FLAG_FORCE_LINK) ?
-		AUTONEG_DISABLE : AUTONEG_ENABLE;
+	if (netif_running(dev)){
+		cmd->autoneg = (bp->flags & B44_FLAG_FORCE_LINK) ?
+			AUTONEG_DISABLE : AUTONEG_ENABLE;
+		cmd->speed = (bp->flags & B44_FLAG_100_BASE_T) ?
+			SPEED_100 : SPEED_10;
+		cmd->duplex = (bp->flags & B44_FLAG_FULL_DUPLEX) ?
+			DUPLEX_FULL : DUPLEX_HALF;
+	}
+	if (cmd->autoneg == AUTONEG_ENABLE)	
+		cmd->advertising |= ADVERTISED_Autoneg;
+	cmd->port = 0;
 	cmd->maxtxpkt = 0;
 	cmd->maxrxpkt = 0;
+	cmd->phy_address = bp->phy_addr;
 	return 0;
 }
 
@@ -1650,30 +1647,16 @@ static int b44_set_settings(struct net_d
 {
 	struct b44 *bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
-		return -EAGAIN;
-
-	/* We do not support gigabit. */
-	if (cmd->autoneg == AUTONEG_ENABLE) {
-		if (cmd->advertising &
-		    (ADVERTISED_1000baseT_Half |
-		     ADVERTISED_1000baseT_Full))
-			return -EINVAL;
-	} else if ((cmd->speed != SPEED_100 &&
-		    cmd->speed != SPEED_10) ||
-		   (cmd->duplex != DUPLEX_HALF &&
-		    cmd->duplex != DUPLEX_FULL)) {
-			return -EINVAL;
-	}
-
 	spin_lock_irq(&bp->lock);
-
 	if (cmd->autoneg == AUTONEG_ENABLE) {
-		bp->flags &= ~B44_FLAG_FORCE_LINK;
+		bp->flags &= ~(B44_FLAG_FORCE_LINK |
+				B44_FLAG_100_BASE_T |
+				B44_FLAG_FULL_DUPLEX); 
 		bp->flags &= ~(B44_FLAG_ADV_10HALF |
 			       B44_FLAG_ADV_10FULL |
 			       B44_FLAG_ADV_100HALF |
 			       B44_FLAG_ADV_100FULL);
+	
 		if (cmd->advertising & ADVERTISE_10HALF)
 			bp->flags |= B44_FLAG_ADV_10HALF;
 		if (cmd->advertising & ADVERTISE_10FULL)
@@ -1682,15 +1665,22 @@ static int b44_set_settings(struct net_d
 			bp->flags |= B44_FLAG_ADV_100HALF;
 		if (cmd->advertising & ADVERTISE_100FULL)
 			bp->flags |= B44_FLAG_ADV_100FULL;
+		if ((cmd->advertising & ADVERTISE_ALL) == 0)
+			bp->flags |= (B44_FLAG_ADV_10HALF |
+				      B44_FLAG_ADV_10FULL |
+				      B44_FLAG_ADV_100HALF |
+				      B44_FLAG_ADV_100FULL);
 	} else {
 		bp->flags |= B44_FLAG_FORCE_LINK;
+		bp->flags &= ~(B44_FLAG_100_BASE_T | B44_FLAG_FULL_DUPLEX); 
 		if (cmd->speed == SPEED_100)
 			bp->flags |= B44_FLAG_100_BASE_T;
 		if (cmd->duplex == DUPLEX_FULL)
 			bp->flags |= B44_FLAG_FULL_DUPLEX;
 	}
 
-	b44_setup_phy(bp);
+	if (netif_running(dev))
+		b44_setup_phy(bp);
 
 	spin_unlock_irq(&bp->lock);
 
diff --git a/drivers/net/b44.h b/drivers/net/b44.h
index b178662..c882391 100644
--- a/drivers/net/b44.h
+++ b/drivers/net/b44.h
@@ -293,13 +293,14 @@
 #define SSB_PCI_MASK2		0xc0000000
 
 /* 4400 PHY registers */
-#define B44_MII_AUXCTRL		24	/* Auxiliary Control */
+#define B44_MII_AUXCTRL		0x18	/* Auxiliary Control */
 #define  MII_AUXCTRL_DUPLEX	0x0001  /* Full Duplex */
 #define  MII_AUXCTRL_SPEED	0x0002  /* 1=100Mbps, 0=10Mbps */
 #define  MII_AUXCTRL_FORCED	0x0004	/* Forced 10/100 */
-#define B44_MII_ALEDCTRL	26	/* Activity LED */
-#define  MII_ALEDCTRL_ALLMSK	0x7fff
-#define B44_MII_TLEDCTRL	27	/* Traffic Meter LED */
+#define  MII_AUXCTRL_ANEGEN	0x0008	/* Autoneg enabled */
+#define B44_MII_INTERRUPTS	0x1a	/* Interrupt Reg */
+#define  MII_INTS_ALLMSK	0x7fff
+#define B44_MII_TLEDCTRL	0x1b	/* Traffic Meter LED */
 #define  MII_TLEDCTRL_ENABLE	0x0040
 
 struct dma_desc {


