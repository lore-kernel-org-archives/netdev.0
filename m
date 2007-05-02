From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 14/20][BNX2]: Re-structure the 2.5G Serdes code.
Date: Tue, 01 May 2007 18:16:11 -0700
Message-ID: <1178068571.4820.50.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1281 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992464AbXEBA3T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 20:29:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Re-structure the 2.5G Serdes code.

Add some common procedures to handle enabling and disabling 2.5G.

Add some missing code to resolve flow control.

Add SUPPORTED_2500baseX_Full and ADVERTISED_2500baseX_Full in
ethtool.h.
 
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index c265068..eac52a1 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -899,6 +899,86 @@ bnx2_set_mac_link(struct bnx2 *bp)
 }
 
 static int
+bnx2_test_and_enable_2g5(struct bnx2 *bp)
+{
+	u32 up1;
+	int ret = 1;
+
+	if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
+		return 0;
+
+	if (bp->autoneg & AUTONEG_SPEED)
+		bp->advertising |= ADVERTISED_2500baseX_Full;
+
+	bnx2_read_phy(bp, bp->mii_up1, &up1);
+	if (!(up1 & BCM5708S_UP1_2G5)) {
+		up1 |= BCM5708S_UP1_2G5;
+		bnx2_write_phy(bp, bp->mii_up1, up1);
+		ret = 0;
+	}
+
+	return ret;
+}
+
+static int
+bnx2_test_and_disable_2g5(struct bnx2 *bp)
+{
+	u32 up1;
+	int ret = 0;
+
+	if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
+		return 0;
+
+	bnx2_read_phy(bp, bp->mii_up1, &up1);
+	if (up1 & BCM5708S_UP1_2G5) {
+		up1 &= ~BCM5708S_UP1_2G5;
+		bnx2_write_phy(bp, bp->mii_up1, up1);
+		ret = 1;
+	}
+
+	return ret;
+}
+
+static void
+bnx2_enable_forced_2g5(struct bnx2 *bp)
+{
+	u32 bmcr;
+
+	if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
+		return;
+
+	if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
+		bmcr |= BCM5708S_BMCR_FORCE_2500;
+	}
+
+	if (bp->autoneg & AUTONEG_SPEED) {
+		bmcr &= ~BMCR_ANENABLE;
+		if (bp->req_duplex == DUPLEX_FULL)
+			bmcr |= BMCR_FULLDPLX;
+	}
+	bnx2_write_phy(bp, bp->mii_bmcr, bmcr);
+}
+
+static void
+bnx2_disable_forced_2g5(struct bnx2 *bp)
+{
+	u32 bmcr;
+
+	if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
+		return;
+
+	if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
+		bmcr &= ~BCM5708S_BMCR_FORCE_2500;
+	}
+
+	if (bp->autoneg & AUTONEG_SPEED)
+		bmcr |= BMCR_SPEED1000 | BMCR_ANENABLE | BMCR_ANRESTART;
+	bnx2_write_phy(bp, bp->mii_bmcr, bmcr);
+}
+
+static int
 bnx2_set_link(struct bnx2 *bp)
 {
 	u32 bmsr;
@@ -941,17 +1021,9 @@ bnx2_set_link(struct bnx2 *bp)
 	}
 	else {
 		if ((bp->phy_flags & PHY_SERDES_FLAG) &&
-			(bp->autoneg & AUTONEG_SPEED)) {
+		    (bp->autoneg & AUTONEG_SPEED))
+			bnx2_disable_forced_2g5(bp);
 
-			u32 bmcr;
-
-			bnx2_read_phy(bp, MII_BMCR, &bmcr);
-			bmcr &= ~BCM5708S_BMCR_FORCE_2500;
-			if (!(bmcr & BMCR_ANENABLE)) {
-				bnx2_write_phy(bp, MII_BMCR, bmcr |
-					BMCR_ANENABLE);
-			}
-		}
 		bp->phy_flags &= ~PHY_PARALLEL_DETECT_FLAG;
 		bp->link_up = 0;
 	}
@@ -1026,34 +1098,32 @@ bnx2_phy_get_pause_adv(struct bnx2 *bp)
 static int
 bnx2_setup_serdes_phy(struct bnx2 *bp)
 {
-	u32 adv, bmcr, up1;
+	u32 adv, bmcr;
 	u32 new_adv = 0;
 
 	if (!(bp->autoneg & AUTONEG_SPEED)) {
 		u32 new_bmcr;
 		int force_link_down = 0;
 
+		if (bp->req_line_speed == SPEED_2500) {
+			if (!bnx2_test_and_enable_2g5(bp))
+				force_link_down = 1;
+		} else if (bp->req_line_speed == SPEED_1000) {
+			if (bnx2_test_and_disable_2g5(bp))
+				force_link_down = 1;
+		}
 		bnx2_read_phy(bp, bp->mii_adv, &adv);
 		adv &= ~(ADVERTISE_1000XFULL | ADVERTISE_1000XHALF);
 
 		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
-		new_bmcr = bmcr & ~(BMCR_ANENABLE | BCM5708S_BMCR_FORCE_2500);
+		new_bmcr = bmcr & ~BMCR_ANENABLE;
 		new_bmcr |= BMCR_SPEED1000;
-		if (bp->req_line_speed == SPEED_2500) {
-			new_bmcr |= BCM5708S_BMCR_FORCE_2500;
-			bnx2_read_phy(bp, BCM5708S_UP1, &up1);
-			if (!(up1 & BCM5708S_UP1_2G5)) {
-				up1 |= BCM5708S_UP1_2G5;
-				bnx2_write_phy(bp, BCM5708S_UP1, up1);
-				force_link_down = 1;
-			}
-		} else if (CHIP_NUM(bp) == CHIP_NUM_5708) {
-			bnx2_read_phy(bp, BCM5708S_UP1, &up1);
-			if (up1 & BCM5708S_UP1_2G5) {
-				up1 &= ~BCM5708S_UP1_2G5;
-				bnx2_write_phy(bp, BCM5708S_UP1, up1);
-				force_link_down = 1;
-			}
+
+		if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+			if (bp->req_line_speed == SPEED_2500)
+				new_bmcr |= BCM5708S_BMCR_FORCE_2500;
+			else
+				new_bmcr = bmcr & ~BCM5708S_BMCR_FORCE_2500;
 		}
 
 		if (bp->req_duplex == DUPLEX_FULL) {
@@ -1080,15 +1150,14 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 			}
 			bnx2_write_phy(bp, bp->mii_adv, adv);
 			bnx2_write_phy(bp, bp->mii_bmcr, new_bmcr);
+		} else {
+			bnx2_resolve_flow_ctrl(bp);
+			bnx2_set_mac_link(bp);
 		}
 		return 0;
 	}
 
-	if (bp->phy_flags & PHY_2_5G_CAPABLE_FLAG) {
-		bnx2_read_phy(bp, BCM5708S_UP1, &up1);
-		up1 |= BCM5708S_UP1_2G5;
-		bnx2_write_phy(bp, BCM5708S_UP1, up1);
-	}
+	bnx2_test_and_enable_2g5(bp);
 
 	if (bp->advertising & ADVERTISED_1000baseT_Full)
 		new_adv |= ADVERTISE_1000XFULL;
@@ -1122,6 +1191,9 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 		bp->current_interval = SERDES_AN_TIMEOUT;
 		bp->serdes_an_pending = 1;
 		mod_timer(&bp->timer, jiffies + bp->current_interval);
+	} else {
+		bnx2_resolve_flow_ctrl(bp);
+		bnx2_set_mac_link(bp);
 	}
 
 	return 0;
@@ -4300,16 +4372,11 @@ bnx2_5708_serdes_timer(struct bnx2 *bp)
 		u32 bmcr;
 
 		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
-
 		if (bmcr & BMCR_ANENABLE) {
-			bmcr &= ~BMCR_ANENABLE;
-			bmcr |= BMCR_FULLDPLX | BCM5708S_BMCR_FORCE_2500;
-			bnx2_write_phy(bp, MII_BMCR, bmcr);
+			bnx2_enable_forced_2g5(bp);
 			bp->current_interval = SERDES_FORCED_TIMEOUT;
 		} else {
-			bmcr &= ~(BMCR_FULLDPLX | BCM5708S_BMCR_FORCE_2500);
-			bmcr |= BMCR_ANENABLE;
-			bnx2_write_phy(bp, MII_BMCR, bmcr);
+			bnx2_disable_forced_2g5(bp);
 			bp->serdes_an_pending = 2;
 			bp->current_interval = bp->timer_interval;
 		}
@@ -4880,6 +4947,8 @@ bnx2_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (bp->phy_flags & PHY_SERDES_FLAG) {
 		cmd->supported |= SUPPORTED_1000baseT_Full |
 			SUPPORTED_FIBRE;
+		if (bp->phy_flags & PHY_2_5G_CAPABLE_FLAG)
+			cmd->supported |= SUPPORTED_2500baseX_Full;
 
 		cmd->port = PORT_FIBRE;
 	}
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c6310ae..f2d248f 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -434,6 +434,7 @@ struct ethtool_ops {
 #define SUPPORTED_10000baseT_Full	(1 << 12)
 #define SUPPORTED_Pause			(1 << 13)
 #define SUPPORTED_Asym_Pause		(1 << 14)
+#define SUPPORTED_2500baseX_Full	(1 << 15)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -451,6 +452,7 @@ struct ethtool_ops {
 #define ADVERTISED_10000baseT_Full	(1 << 12)
 #define ADVERTISED_Pause		(1 << 13)
 #define ADVERTISED_Asym_Pause		(1 << 14)
+#define ADVERTISED_2500baseX_Full	(1 << 15)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the


