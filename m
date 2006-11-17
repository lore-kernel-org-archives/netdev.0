From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/17][BNX2]: Improve SerDes handling.
Date: Thu, 16 Nov 2006 18:59:29 -0800
Message-ID: <1163732369.6658.24.camel@rh4>
References: <1163731443.6658.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:16906 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1424903AbWKQCHG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 21:07:06 -0500
To: davem@davemloft.net
In-Reply-To: <1163731443.6658.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Improve SerDes handling.

1. Add support for 2.5Gbps forced speed setting.
2. Remove a long udelay() loop and change to msleep().
3. Other misc. SerDes fixes.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index b60e45d..9b391cf 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -860,7 +860,7 @@ bnx2_set_link(struct bnx2 *bp)
 	u32 bmsr;
 	u8 link_up;
 
-	if (bp->loopback == MAC_LOOPBACK) {
+	if (bp->loopback == MAC_LOOPBACK || bp->loopback == PHY_LOOPBACK) {
 		bp->link_up = 1;
 		return 0;
 	}
@@ -902,6 +902,7 @@ bnx2_set_link(struct bnx2 *bp)
 			u32 bmcr;
 
 			bnx2_read_phy(bp, MII_BMCR, &bmcr);
+			bmcr &= ~BCM5708S_BMCR_FORCE_2500;
 			if (!(bmcr & BMCR_ANENABLE)) {
 				bnx2_write_phy(bp, MII_BMCR, bmcr |
 					BMCR_ANENABLE);
@@ -988,7 +989,21 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 		u32 new_bmcr;
 		int force_link_down = 0;
 
-		if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+		bnx2_read_phy(bp, MII_ADVERTISE, &adv);
+		adv &= ~(ADVERTISE_1000XFULL | ADVERTISE_1000XHALF);
+
+		bnx2_read_phy(bp, MII_BMCR, &bmcr);
+		new_bmcr = bmcr & ~(BMCR_ANENABLE | BCM5708S_BMCR_FORCE_2500);
+		new_bmcr |= BMCR_SPEED1000;
+		if (bp->req_line_speed == SPEED_2500) {
+			new_bmcr |= BCM5708S_BMCR_FORCE_2500;
+			bnx2_read_phy(bp, BCM5708S_UP1, &up1);
+			if (!(up1 & BCM5708S_UP1_2G5)) {
+				up1 |= BCM5708S_UP1_2G5;
+				bnx2_write_phy(bp, BCM5708S_UP1, up1);
+				force_link_down = 1;
+			}
+		} else if (CHIP_NUM(bp) == CHIP_NUM_5708) {
 			bnx2_read_phy(bp, BCM5708S_UP1, &up1);
 			if (up1 & BCM5708S_UP1_2G5) {
 				up1 &= ~BCM5708S_UP1_2G5;
@@ -997,12 +1012,6 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 			}
 		}
 
-		bnx2_read_phy(bp, MII_ADVERTISE, &adv);
-		adv &= ~(ADVERTISE_1000XFULL | ADVERTISE_1000XHALF);
-
-		bnx2_read_phy(bp, MII_BMCR, &bmcr);
-		new_bmcr = bmcr & ~BMCR_ANENABLE;
-		new_bmcr |= BMCR_SPEED1000;
 		if (bp->req_duplex == DUPLEX_FULL) {
 			adv |= ADVERTISE_1000XFULL;
 			new_bmcr |= BMCR_FULLDPLX;
@@ -1023,6 +1032,7 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 				bp->link_up = 0;
 				netif_carrier_off(bp->dev);
 				bnx2_write_phy(bp, MII_BMCR, new_bmcr);
+				bnx2_report_link(bp);
 			}
 			bnx2_write_phy(bp, MII_ADVERTISE, adv);
 			bnx2_write_phy(bp, MII_BMCR, new_bmcr);
@@ -1048,12 +1058,10 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 	if ((adv != new_adv) || ((bmcr & BMCR_ANENABLE) == 0)) {
 		/* Force a link down visible on the other side */
 		if (bp->link_up) {
-			int i;
-
 			bnx2_write_phy(bp, MII_BMCR, BMCR_LOOPBACK);
-			for (i = 0; i < 110; i++) {
-				udelay(100);
-			}
+			spin_unlock_bh(&bp->phy_lock);
+			msleep(20);
+			spin_lock_bh(&bp->phy_lock);
 		}
 
 		bnx2_write_phy(bp, MII_ADVERTISE, new_adv);
@@ -1397,7 +1405,7 @@ bnx2_set_phy_loopback(struct bnx2 *bp)
 	for (i = 0; i < 10; i++) {
 		if (bnx2_test_link(bp) == 0)
 			break;
-		udelay(10);
+		msleep(100);
 	}
 
 	mac_mode = REG_RD(bp, BNX2_EMAC_MODE);
@@ -3713,7 +3721,9 @@ bnx2_init_nic(struct bnx2 *bp)
 	if ((rc = bnx2_reset_nic(bp, BNX2_DRV_MSG_CODE_RESET)) != 0)
 		return rc;
 
+	spin_lock_bh(&bp->phy_lock);
 	bnx2_init_phy(bp);
+	spin_unlock_bh(&bp->phy_lock);
 	bnx2_set_link(bp);
 	return 0;
 }
@@ -3953,7 +3963,7 @@ bnx2_run_loopback(struct bnx2 *bp, int l
 		bnx2_set_mac_loopback(bp);
 	}
 	else if (loopback_mode == BNX2_PHY_LOOPBACK) {
-		bp->loopback = 0;
+		bp->loopback = PHY_LOOPBACK;
 		bnx2_set_phy_loopback(bp);
 	}
 	else
@@ -4744,10 +4754,14 @@ bnx2_set_settings(struct net_device *dev
 	}
 	else {
 		if (bp->phy_flags & PHY_SERDES_FLAG) {
-			if ((cmd->speed != SPEED_1000) ||
-				(cmd->duplex != DUPLEX_FULL)) {
+			if ((cmd->speed != SPEED_1000 &&
+			     cmd->speed != SPEED_2500) ||
+			    (cmd->duplex != DUPLEX_FULL))
+				return -EINVAL;
+
+			if (cmd->speed == SPEED_2500 &&
+			    !(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
 				return -EINVAL;
-			}
 		}
 		else if (cmd->speed == SPEED_1000) {
 			return -EINVAL;
@@ -5289,6 +5303,8 @@ bnx2_self_test(struct net_device *dev, s
 
 	memset(buf, 0, sizeof(u64) * BNX2_NUM_TESTS);
 	if (etest->flags & ETH_TEST_FL_OFFLINE) {
+		int i;
+
 		bnx2_netif_stop(bp);
 		bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_DIAG);
 		bnx2_free_skbs(bp);
@@ -5313,9 +5329,11 @@ bnx2_self_test(struct net_device *dev, s
 		}
 
 		/* wait for link up */
-		msleep_interruptible(3000);
-		if ((!bp->link_up) && !(bp->phy_flags & PHY_SERDES_FLAG))
-			msleep_interruptible(4000);
+		for (i = 0; i < 7; i++) {
+			if (bp->link_up)
+				break;
+			msleep_interruptible(1000);
+		}
 	}
 
 	if (bnx2_test_nvram(bp) != 0) {
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index ca31904..78ff09d 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -3696,6 +3696,8 @@ #define PHY_REV_ID(id)                  
 
 /* 5708 Serdes PHY registers */
 
+#define BCM5708S_BMCR_FORCE_2500		0x20
+
 #define BCM5708S_UP1				0xb
 
 #define BCM5708S_UP1_2G5			0x1


