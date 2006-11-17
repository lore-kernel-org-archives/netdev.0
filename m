From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/17][BNX2]: Add 5708S parallel detection.
Date: Thu, 16 Nov 2006 18:59:48 -0800
Message-ID: <1163732388.6658.26.camel@rh4>
References: <1163731443.6658.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:50439 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1424915AbWKQCHY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 21:07:24 -0500
To: davem@davemloft.net
In-Reply-To: <1163731443.6658.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add 5708S parallel detection.

Add code to parallel detect 1Gbps and 2.5Gbps link speeds.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7897481..ea5daf6 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1067,19 +1067,17 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 		bnx2_write_phy(bp, MII_ADVERTISE, new_adv);
 		bnx2_write_phy(bp, MII_BMCR, bmcr | BMCR_ANRESTART |
 			BMCR_ANENABLE);
-		if (CHIP_NUM(bp) == CHIP_NUM_5706) {
-			/* Speed up link-up time when the link partner
-			 * does not autonegotiate which is very common
-			 * in blade servers. Some blade servers use
-			 * IPMI for kerboard input and it's important
-			 * to minimize link disruptions. Autoneg. involves
-			 * exchanging base pages plus 3 next pages and
-			 * normally completes in about 120 msec.
-			 */
-			bp->current_interval = SERDES_AN_TIMEOUT;
-			bp->serdes_an_pending = 1;
-			mod_timer(&bp->timer, jiffies + bp->current_interval);
-		}
+		/* Speed up link-up time when the link partner
+		 * does not autonegotiate which is very common
+		 * in blade servers. Some blade servers use
+		 * IPMI for kerboard input and it's important
+		 * to minimize link disruptions. Autoneg. involves
+		 * exchanging base pages plus 3 next pages and
+		 * normally completes in about 120 msec.
+		 */
+		bp->current_interval = SERDES_AN_TIMEOUT;
+		bp->serdes_an_pending = 1;
+		mod_timer(&bp->timer, jiffies + bp->current_interval);
 	}
 
 	return 0;
@@ -4228,6 +4226,41 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 }
 
 static void
+bnx2_5708_serdes_timer(struct bnx2 *bp)
+{
+	if ((bp->phy_flags & PHY_2_5G_CAPABLE_FLAG) == 0) {
+		bp->serdes_an_pending = 0;
+		return;
+	}
+
+	spin_lock(&bp->phy_lock);
+	if (bp->serdes_an_pending)
+		bp->serdes_an_pending--;
+	else if ((bp->link_up == 0) && (bp->autoneg & AUTONEG_SPEED)) {
+		u32 bmcr;
+
+		bnx2_read_phy(bp, MII_BMCR, &bmcr);
+
+		if (bmcr & BMCR_ANENABLE) {
+			bmcr &= ~BMCR_ANENABLE;
+			bmcr |= BMCR_FULLDPLX | BCM5708S_BMCR_FORCE_2500;
+			bnx2_write_phy(bp, MII_BMCR, bmcr);
+			bp->current_interval = SERDES_FORCED_TIMEOUT;
+		} else {
+			bmcr &= ~(BMCR_FULLDPLX | BCM5708S_BMCR_FORCE_2500);
+			bmcr |= BMCR_ANENABLE;
+			bnx2_write_phy(bp, MII_BMCR, bmcr);
+			bp->serdes_an_pending = 2;
+			bp->current_interval = bp->timer_interval;
+		}
+
+	} else
+		bp->current_interval = bp->timer_interval;
+
+	spin_unlock(&bp->phy_lock);
+}
+
+static void
 bnx2_timer(unsigned long data)
 {
 	struct bnx2 *bp = (struct bnx2 *) data;
@@ -4244,9 +4277,12 @@ bnx2_timer(unsigned long data)
 
 	bp->stats_blk->stat_FwRxDrop = REG_RD_IND(bp, BNX2_FW_RX_DROP_COUNT);
 
-	if ((bp->phy_flags & PHY_SERDES_FLAG) &&
-	    (CHIP_NUM(bp) == CHIP_NUM_5706))
-		bnx2_5706_serdes_timer(bp);
+	if (bp->phy_flags & PHY_SERDES_FLAG) {
+		if (CHIP_NUM(bp) == CHIP_NUM_5706)
+			bnx2_5706_serdes_timer(bp);
+		else if (CHIP_NUM(bp) == CHIP_NUM_5708)
+			bnx2_5708_serdes_timer(bp);
+	}
 
 bnx2_restart_timer:
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
@@ -4917,11 +4953,10 @@ bnx2_nway_reset(struct net_device *dev)
 		msleep(20);
 
 		spin_lock_bh(&bp->phy_lock);
-		if (CHIP_NUM(bp) == CHIP_NUM_5706) {
-			bp->current_interval = SERDES_AN_TIMEOUT;
-			bp->serdes_an_pending = 1;
-			mod_timer(&bp->timer, jiffies + bp->current_interval);
-		}
+
+		bp->current_interval = SERDES_AN_TIMEOUT;
+		bp->serdes_an_pending = 1;
+		mod_timer(&bp->timer, jiffies + bp->current_interval);
 	}
 
 	bnx2_read_phy(bp, MII_BMCR, &bmcr);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 78ff09d..7fa7008 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -4040,6 +4040,7 @@ #define PHY_LOOPBACK		2
 
 	u8			serdes_an_pending;
 #define SERDES_AN_TIMEOUT	(HZ / 3)
+#define SERDES_FORCED_TIMEOUT	(HZ / 10)
 
 	u8			mac_addr[8];
 


