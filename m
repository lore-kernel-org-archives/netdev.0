From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 13/20][BNX2]: Put MII register offsets in the bnx2
 struct.
Date: Tue, 01 May 2007 18:15:49 -0700
Message-ID: <1178068549.4820.49.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3279 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161717AbXEBA26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 20:28:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Put MII register offsets in the bnx2 struct.

The 5709 Serdes device uses non-standard MII register offsets.  This
re-structuring will make it easier to support 5709 Serdes.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 8610f7f..c265068 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -572,8 +572,8 @@ bnx2_report_fw_link(struct bnx2 *bp)
 		if (bp->autoneg) {
 			fw_link_status |= BNX2_LINK_STATUS_AN_ENABLED;
 
-			bnx2_read_phy(bp, MII_BMSR, &bmsr);
-			bnx2_read_phy(bp, MII_BMSR, &bmsr);
+			bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
+			bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
 
 			if (!(bmsr & BMSR_ANEGCOMPLETE) ||
 			    bp->phy_flags & PHY_PARALLEL_DETECT_FLAG)
@@ -654,8 +654,8 @@ bnx2_resolve_flow_ctrl(struct bnx2 *bp)
 		return;
 	}
 
-	bnx2_read_phy(bp, MII_ADVERTISE, &local_adv);
-	bnx2_read_phy(bp, MII_LPA, &remote_adv);
+	bnx2_read_phy(bp, bp->mii_adv, &local_adv);
+	bnx2_read_phy(bp, bp->mii_lpa, &remote_adv);
 
 	if (bp->phy_flags & PHY_SERDES_FLAG) {
 		u32 new_local_adv = 0;
@@ -736,7 +736,7 @@ bnx2_5706s_linkup(struct bnx2 *bp)
 	bp->link_up = 1;
 	bp->line_speed = SPEED_1000;
 
-	bnx2_read_phy(bp, MII_BMCR, &bmcr);
+	bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 	if (bmcr & BMCR_FULLDPLX) {
 		bp->duplex = DUPLEX_FULL;
 	}
@@ -748,8 +748,8 @@ bnx2_5706s_linkup(struct bnx2 *bp)
 		return 0;
 	}
 
-	bnx2_read_phy(bp, MII_ADVERTISE, &local_adv);
-	bnx2_read_phy(bp, MII_LPA, &remote_adv);
+	bnx2_read_phy(bp, bp->mii_adv, &local_adv);
+	bnx2_read_phy(bp, bp->mii_lpa, &remote_adv);
 
 	common = local_adv & remote_adv;
 	if (common & (ADVERTISE_1000XHALF | ADVERTISE_1000XFULL)) {
@@ -770,7 +770,7 @@ bnx2_copper_linkup(struct bnx2 *bp)
 {
 	u32 bmcr;
 
-	bnx2_read_phy(bp, MII_BMCR, &bmcr);
+	bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 	if (bmcr & BMCR_ANENABLE) {
 		u32 local_adv, remote_adv, common;
 
@@ -787,8 +787,8 @@ bnx2_copper_linkup(struct bnx2 *bp)
 			bp->duplex = DUPLEX_HALF;
 		}
 		else {
-			bnx2_read_phy(bp, MII_ADVERTISE, &local_adv);
-			bnx2_read_phy(bp, MII_LPA, &remote_adv);
+			bnx2_read_phy(bp, bp->mii_adv, &local_adv);
+			bnx2_read_phy(bp, bp->mii_lpa, &remote_adv);
 
 			common = local_adv & remote_adv;
 			if (common & ADVERTISE_100FULL) {
@@ -911,8 +911,8 @@ bnx2_set_link(struct bnx2 *bp)
 
 	link_up = bp->link_up;
 
-	bnx2_read_phy(bp, MII_BMSR, &bmsr);
-	bnx2_read_phy(bp, MII_BMSR, &bmsr);
+	bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
+	bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
 
 	if ((bp->phy_flags & PHY_SERDES_FLAG) &&
 	    (CHIP_NUM(bp) == CHIP_NUM_5706)) {
@@ -971,13 +971,13 @@ bnx2_reset_phy(struct bnx2 *bp)
 	int i;
 	u32 reg;
 
-        bnx2_write_phy(bp, MII_BMCR, BMCR_RESET);
+        bnx2_write_phy(bp, bp->mii_bmcr, BMCR_RESET);
 
 #define PHY_RESET_MAX_WAIT 100
 	for (i = 0; i < PHY_RESET_MAX_WAIT; i++) {
 		udelay(10);
 
-		bnx2_read_phy(bp, MII_BMCR, &reg);
+		bnx2_read_phy(bp, bp->mii_bmcr, &reg);
 		if (!(reg & BMCR_RESET)) {
 			udelay(20);
 			break;
@@ -1033,10 +1033,10 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 		u32 new_bmcr;
 		int force_link_down = 0;
 
-		bnx2_read_phy(bp, MII_ADVERTISE, &adv);
+		bnx2_read_phy(bp, bp->mii_adv, &adv);
 		adv &= ~(ADVERTISE_1000XFULL | ADVERTISE_1000XHALF);
 
-		bnx2_read_phy(bp, MII_BMCR, &bmcr);
+		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 		new_bmcr = bmcr & ~(BMCR_ANENABLE | BCM5708S_BMCR_FORCE_2500);
 		new_bmcr |= BMCR_SPEED1000;
 		if (bp->req_line_speed == SPEED_2500) {
@@ -1067,19 +1067,19 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 		if ((new_bmcr != bmcr) || (force_link_down)) {
 			/* Force a link down visible on the other side */
 			if (bp->link_up) {
-				bnx2_write_phy(bp, MII_ADVERTISE, adv &
+				bnx2_write_phy(bp, bp->mii_adv, adv &
 					       ~(ADVERTISE_1000XFULL |
 						 ADVERTISE_1000XHALF));
-				bnx2_write_phy(bp, MII_BMCR, bmcr |
+				bnx2_write_phy(bp, bp->mii_bmcr, bmcr |
 					BMCR_ANRESTART | BMCR_ANENABLE);
 
 				bp->link_up = 0;
 				netif_carrier_off(bp->dev);
-				bnx2_write_phy(bp, MII_BMCR, new_bmcr);
+				bnx2_write_phy(bp, bp->mii_bmcr, new_bmcr);
 				bnx2_report_link(bp);
 			}
-			bnx2_write_phy(bp, MII_ADVERTISE, adv);
-			bnx2_write_phy(bp, MII_BMCR, new_bmcr);
+			bnx2_write_phy(bp, bp->mii_adv, adv);
+			bnx2_write_phy(bp, bp->mii_bmcr, new_bmcr);
 		}
 		return 0;
 	}
@@ -1095,21 +1095,21 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 
 	new_adv |= bnx2_phy_get_pause_adv(bp);
 
-	bnx2_read_phy(bp, MII_ADVERTISE, &adv);
-	bnx2_read_phy(bp, MII_BMCR, &bmcr);
+	bnx2_read_phy(bp, bp->mii_adv, &adv);
+	bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 
 	bp->serdes_an_pending = 0;
 	if ((adv != new_adv) || ((bmcr & BMCR_ANENABLE) == 0)) {
 		/* Force a link down visible on the other side */
 		if (bp->link_up) {
-			bnx2_write_phy(bp, MII_BMCR, BMCR_LOOPBACK);
+			bnx2_write_phy(bp, bp->mii_bmcr, BMCR_LOOPBACK);
 			spin_unlock_bh(&bp->phy_lock);
 			msleep(20);
 			spin_lock_bh(&bp->phy_lock);
 		}
 
-		bnx2_write_phy(bp, MII_ADVERTISE, new_adv);
-		bnx2_write_phy(bp, MII_BMCR, bmcr | BMCR_ANRESTART |
+		bnx2_write_phy(bp, bp->mii_adv, new_adv);
+		bnx2_write_phy(bp, bp->mii_bmcr, bmcr | BMCR_ANRESTART |
 			BMCR_ANENABLE);
 		/* Speed up link-up time when the link partner
 		 * does not autonegotiate which is very common
@@ -1146,14 +1146,14 @@ bnx2_setup_copper_phy(struct bnx2 *bp)
 	u32 bmcr;
 	u32 new_bmcr;
 
-	bnx2_read_phy(bp, MII_BMCR, &bmcr);
+	bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 
 	if (bp->autoneg & AUTONEG_SPEED) {
 		u32 adv_reg, adv1000_reg;
 		u32 new_adv_reg = 0;
 		u32 new_adv1000_reg = 0;
 
-		bnx2_read_phy(bp, MII_ADVERTISE, &adv_reg);
+		bnx2_read_phy(bp, bp->mii_adv, &adv_reg);
 		adv_reg &= (PHY_ALL_10_100_SPEED | ADVERTISE_PAUSE_CAP |
 			ADVERTISE_PAUSE_ASYM);
 
@@ -1179,9 +1179,9 @@ bnx2_setup_copper_phy(struct bnx2 *bp)
 			(adv_reg != new_adv_reg) ||
 			((bmcr & BMCR_ANENABLE) == 0)) {
 
-			bnx2_write_phy(bp, MII_ADVERTISE, new_adv_reg);
+			bnx2_write_phy(bp, bp->mii_adv, new_adv_reg);
 			bnx2_write_phy(bp, MII_CTRL1000, new_adv1000_reg);
-			bnx2_write_phy(bp, MII_BMCR, BMCR_ANRESTART |
+			bnx2_write_phy(bp, bp->mii_bmcr, BMCR_ANRESTART |
 				BMCR_ANENABLE);
 		}
 		else if (bp->link_up) {
@@ -1204,21 +1204,21 @@ bnx2_setup_copper_phy(struct bnx2 *bp)
 	if (new_bmcr != bmcr) {
 		u32 bmsr;
 
-		bnx2_read_phy(bp, MII_BMSR, &bmsr);
-		bnx2_read_phy(bp, MII_BMSR, &bmsr);
+		bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
+		bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
 
 		if (bmsr & BMSR_LSTATUS) {
 			/* Force link down */
-			bnx2_write_phy(bp, MII_BMCR, BMCR_LOOPBACK);
+			bnx2_write_phy(bp, bp->mii_bmcr, BMCR_LOOPBACK);
 			spin_unlock_bh(&bp->phy_lock);
 			msleep(50);
 			spin_lock_bh(&bp->phy_lock);
 
-			bnx2_read_phy(bp, MII_BMSR, &bmsr);
-			bnx2_read_phy(bp, MII_BMSR, &bmsr);
+			bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
+			bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
 		}
 
-		bnx2_write_phy(bp, MII_BMCR, new_bmcr);
+		bnx2_write_phy(bp, bp->mii_bmcr, new_bmcr);
 
 		/* Normally, the new speed is setup after the link has
 		 * gone down and up again. In some cases, link will not go
@@ -1396,6 +1396,11 @@ bnx2_init_phy(struct bnx2 *bp)
 	bp->phy_flags &= ~PHY_INT_MODE_MASK_FLAG;
 	bp->phy_flags |= PHY_INT_MODE_LINK_READY_FLAG;
 
+	bp->mii_bmcr = MII_BMCR;
+	bp->mii_bmsr = MII_BMSR;
+	bp->mii_adv = MII_ADVERTISE;
+	bp->mii_lpa = MII_LPA;
+
         REG_WR(bp, BNX2_EMAC_ATTENTION_ENA, BNX2_EMAC_ATTENTION_ENA_LINK);
 
 	bnx2_reset_phy(bp);
@@ -1442,7 +1447,7 @@ bnx2_set_phy_loopback(struct bnx2 *bp)
 	int rc, i;
 
 	spin_lock_bh(&bp->phy_lock);
-	rc = bnx2_write_phy(bp, MII_BMCR, BMCR_LOOPBACK | BMCR_FULLDPLX |
+	rc = bnx2_write_phy(bp, bp->mii_bmcr, BMCR_LOOPBACK | BMCR_FULLDPLX |
 			    BMCR_SPEED1000);
 	spin_unlock_bh(&bp->phy_lock);
 	if (rc)
@@ -4185,8 +4190,8 @@ bnx2_test_link(struct bnx2 *bp)
 	u32 bmsr;
 
 	spin_lock_bh(&bp->phy_lock);
-	bnx2_read_phy(bp, MII_BMSR, &bmsr);
-	bnx2_read_phy(bp, MII_BMSR, &bmsr);
+	bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
+	bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
 	spin_unlock_bh(&bp->phy_lock);
 
 	if (bmsr & BMSR_LSTATUS) {
@@ -4236,7 +4241,7 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 
 		bp->current_interval = bp->timer_interval;
 
-		bnx2_read_phy(bp, MII_BMCR, &bmcr);
+		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 
 		if (bmcr & BMCR_ANENABLE) {
 			u32 phy1, phy2;
@@ -4254,7 +4259,7 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 
 				bmcr &= ~BMCR_ANENABLE;
 				bmcr |= BMCR_SPEED1000 | BMCR_FULLDPLX;
-				bnx2_write_phy(bp, MII_BMCR, bmcr);
+				bnx2_write_phy(bp, bp->mii_bmcr, bmcr);
 				bp->phy_flags |= PHY_PARALLEL_DETECT_FLAG;
 			}
 		}
@@ -4268,9 +4273,9 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 		if (phy2 & 0x20) {
 			u32 bmcr;
 
-			bnx2_read_phy(bp, MII_BMCR, &bmcr);
+			bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 			bmcr |= BMCR_ANENABLE;
-			bnx2_write_phy(bp, MII_BMCR, bmcr);
+			bnx2_write_phy(bp, bp->mii_bmcr, bmcr);
 
 			bp->phy_flags &= ~PHY_PARALLEL_DETECT_FLAG;
 		}
@@ -4294,7 +4299,7 @@ bnx2_5708_serdes_timer(struct bnx2 *bp)
 	else if ((bp->link_up == 0) && (bp->autoneg & AUTONEG_SPEED)) {
 		u32 bmcr;
 
-		bnx2_read_phy(bp, MII_BMCR, &bmcr);
+		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 
 		if (bmcr & BMCR_ANENABLE) {
 			bmcr &= ~BMCR_ANENABLE;
@@ -5115,7 +5120,7 @@ bnx2_nway_reset(struct net_device *dev)
 
 	/* Force a link down visible on the other side */
 	if (bp->phy_flags & PHY_SERDES_FLAG) {
-		bnx2_write_phy(bp, MII_BMCR, BMCR_LOOPBACK);
+		bnx2_write_phy(bp, bp->mii_bmcr, BMCR_LOOPBACK);
 		spin_unlock_bh(&bp->phy_lock);
 
 		msleep(20);
@@ -5127,9 +5132,9 @@ bnx2_nway_reset(struct net_device *dev)
 		mod_timer(&bp->timer, jiffies + bp->current_interval);
 	}
 
-	bnx2_read_phy(bp, MII_BMCR, &bmcr);
+	bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 	bmcr &= ~BMCR_LOOPBACK;
-	bnx2_write_phy(bp, MII_BMCR, bmcr | BMCR_ANRESTART | BMCR_ANENABLE);
+	bnx2_write_phy(bp, bp->mii_bmcr, bmcr | BMCR_ANRESTART | BMCR_ANENABLE);
 
 	spin_unlock_bh(&bp->phy_lock);
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 70fb639..d4a85d7 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6498,6 +6498,12 @@ struct bnx2 {
 #define PHY_INT_MODE_LINK_READY_FLAG	0x200
 #define PHY_DIS_EARLY_DAC_FLAG		0x400
 
+	u32			mii_bmcr;
+	u32			mii_bmsr;
+	u32			mii_adv;
+	u32			mii_lpa;
+	u32			mii_up1;
+
 	u32			chip_id;
 	/* chip num:16-31, rev:12-15, metal:4-11, bond_id:0-3 */
 #define CHIP_NUM(bp)			(((bp)->chip_id) & 0xffff0000)


