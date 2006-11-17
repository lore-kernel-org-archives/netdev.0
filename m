From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/17][BNX2]: Add bnx2_5706_serdes_timer().
Date: Thu, 16 Nov 2006 19:20:28 -0800
Message-ID: <1163733628.6658.52.camel@rh4>
References: <1163731443.6658.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:24580 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1424938AbWKQC2G
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 21:28:06 -0500
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.10.64.221]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id B8E4A2AE for
 <netdev@vger.kernel.org>; Thu, 16 Nov 2006 18:27:56 -0800 (PST)
Received: from NT-IRVA-0751.brcm.ad.broadcom.com (nt-irva-0751
 [10.8.194.65]) by mail-irva-12.broadcom.com (Postfix) with ESMTP id
 1E23769CA4 for <netdev@vger.kernel.org>; Thu, 16 Nov 2006 18:27:56
 -0800 (PST)
To: netdev@vger.kernel.org
In-Reply-To: <1163731443.6658.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add bnx2_5706_serdes_timer().

Separate the 5706S SerDes handling code in bnx2_timer() and put it
in a new function.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 9b391cf..7897481 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4173,81 +4173,80 @@ bnx2_test_intr(struct bnx2 *bp)
 }
 
 static void
-bnx2_timer(unsigned long data)
+bnx2_5706_serdes_timer(struct bnx2 *bp)
 {
-	struct bnx2 *bp = (struct bnx2 *) data;
-	u32 msg;
+	spin_lock(&bp->phy_lock);
+	if (bp->serdes_an_pending)
+		bp->serdes_an_pending--;
+	else if ((bp->link_up == 0) && (bp->autoneg & AUTONEG_SPEED)) {
+		u32 bmcr;
 
-	if (!netif_running(bp->dev))
-		return;
+		bp->current_interval = bp->timer_interval;
 
-	if (atomic_read(&bp->intr_sem) != 0)
-		goto bnx2_restart_timer;
+		bnx2_read_phy(bp, MII_BMCR, &bmcr);
 
-	msg = (u32) ++bp->fw_drv_pulse_wr_seq;
-	REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_PULSE_MB, msg);
+		if (bmcr & BMCR_ANENABLE) {
+			u32 phy1, phy2;
 
-	bp->stats_blk->stat_FwRxDrop = REG_RD_IND(bp, BNX2_FW_RX_DROP_COUNT);
+			bnx2_write_phy(bp, 0x1c, 0x7c00);
+			bnx2_read_phy(bp, 0x1c, &phy1);
 
-	if ((bp->phy_flags & PHY_SERDES_FLAG) &&
-	    (CHIP_NUM(bp) == CHIP_NUM_5706)) {
+			bnx2_write_phy(bp, 0x17, 0x0f01);
+			bnx2_read_phy(bp, 0x15, &phy2);
+			bnx2_write_phy(bp, 0x17, 0x0f01);
+			bnx2_read_phy(bp, 0x15, &phy2);
 
-		spin_lock(&bp->phy_lock);
-		if (bp->serdes_an_pending) {
-			bp->serdes_an_pending--;
+			if ((phy1 & 0x10) &&	/* SIGNAL DETECT */
+				!(phy2 & 0x20)) {	/* no CONFIG */
+
+				bmcr &= ~BMCR_ANENABLE;
+				bmcr |= BMCR_SPEED1000 | BMCR_FULLDPLX;
+				bnx2_write_phy(bp, MII_BMCR, bmcr);
+				bp->phy_flags |= PHY_PARALLEL_DETECT_FLAG;
+			}
 		}
-		else if ((bp->link_up == 0) && (bp->autoneg & AUTONEG_SPEED)) {
-			u32 bmcr;
+	}
+	else if ((bp->link_up) && (bp->autoneg & AUTONEG_SPEED) &&
+		 (bp->phy_flags & PHY_PARALLEL_DETECT_FLAG)) {
+		u32 phy2;
 
-			bp->current_interval = bp->timer_interval;
+		bnx2_write_phy(bp, 0x17, 0x0f01);
+		bnx2_read_phy(bp, 0x15, &phy2);
+		if (phy2 & 0x20) {
+			u32 bmcr;
 
 			bnx2_read_phy(bp, MII_BMCR, &bmcr);
+			bmcr |= BMCR_ANENABLE;
+			bnx2_write_phy(bp, MII_BMCR, bmcr);
 
-			if (bmcr & BMCR_ANENABLE) {
-				u32 phy1, phy2;
-
-				bnx2_write_phy(bp, 0x1c, 0x7c00);
-				bnx2_read_phy(bp, 0x1c, &phy1);
-
-				bnx2_write_phy(bp, 0x17, 0x0f01);
-				bnx2_read_phy(bp, 0x15, &phy2);
-				bnx2_write_phy(bp, 0x17, 0x0f01);
-				bnx2_read_phy(bp, 0x15, &phy2);
+			bp->phy_flags &= ~PHY_PARALLEL_DETECT_FLAG;
+		}
+	} else
+		bp->current_interval = bp->timer_interval;
 
-				if ((phy1 & 0x10) &&	/* SIGNAL DETECT */
-					!(phy2 & 0x20)) {	/* no CONFIG */
+	spin_unlock(&bp->phy_lock);
+}
 
-					bmcr &= ~BMCR_ANENABLE;
-					bmcr |= BMCR_SPEED1000 |
-						BMCR_FULLDPLX;
-					bnx2_write_phy(bp, MII_BMCR, bmcr);
-					bp->phy_flags |=
-						PHY_PARALLEL_DETECT_FLAG;
-				}
-			}
-		}
-		else if ((bp->link_up) && (bp->autoneg & AUTONEG_SPEED) &&
-			(bp->phy_flags & PHY_PARALLEL_DETECT_FLAG)) {
-			u32 phy2;
+static void
+bnx2_timer(unsigned long data)
+{
+	struct bnx2 *bp = (struct bnx2 *) data;
+	u32 msg;
 
-			bnx2_write_phy(bp, 0x17, 0x0f01);
-			bnx2_read_phy(bp, 0x15, &phy2);
-			if (phy2 & 0x20) {
-				u32 bmcr;
+	if (!netif_running(bp->dev))
+		return;
 
-				bnx2_read_phy(bp, MII_BMCR, &bmcr);
-				bmcr |= BMCR_ANENABLE;
-				bnx2_write_phy(bp, MII_BMCR, bmcr);
+	if (atomic_read(&bp->intr_sem) != 0)
+		goto bnx2_restart_timer;
 
-				bp->phy_flags &= ~PHY_PARALLEL_DETECT_FLAG;
+	msg = (u32) ++bp->fw_drv_pulse_wr_seq;
+	REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_PULSE_MB, msg);
 
-			}
-		}
-		else
-			bp->current_interval = bp->timer_interval;
+	bp->stats_blk->stat_FwRxDrop = REG_RD_IND(bp, BNX2_FW_RX_DROP_COUNT);
 
-		spin_unlock(&bp->phy_lock);
-	}
+	if ((bp->phy_flags & PHY_SERDES_FLAG) &&
+	    (CHIP_NUM(bp) == CHIP_NUM_5706))
+		bnx2_5706_serdes_timer(bp);
 
 bnx2_restart_timer:
 	mod_timer(&bp->timer, jiffies + bp->current_interval);


