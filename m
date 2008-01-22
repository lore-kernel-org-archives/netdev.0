From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.25 3/4][BNX2]: Add link-down workaround on 5706
 serdes.
Date: Mon, 21 Jan 2008 17:08:24 -0800
Message-ID: <1200964104.10010.48.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4634 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754241AbYAVAXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 19:23:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Add link-down workaround on 5706 serdes.

In some blade systems using the 5706 serdes, the hardware sometimes
does not properly generate link down interrupts.  We add a workaround
in the driver's timer to force a link-down when some PHY registers
report loss of SYNC.

The parallel detect logic is cleaned up slightly to better integrate
the workaround.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7ee7746..834675f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1186,6 +1186,19 @@ bnx2_disable_forced_2g5(struct bnx2 *bp)
 	bnx2_write_phy(bp, bp->mii_bmcr, bmcr);
 }
 
+static void
+bnx2_5706s_force_link_dn(struct bnx2 *bp, int start)
+{
+	u32 val;
+
+	bnx2_write_phy(bp, MII_BNX2_DSP_ADDRESS, MII_EXPAND_SERDES_CTL);
+	bnx2_read_phy(bp, MII_BNX2_DSP_RW_PORT, &val);
+	if (start)
+		bnx2_write_phy(bp, MII_BNX2_DSP_RW_PORT, val & 0xff0f);
+	else
+		bnx2_write_phy(bp, MII_BNX2_DSP_RW_PORT, val | 0xc0);
+}
+
 static int
 bnx2_set_link(struct bnx2 *bp)
 {
@@ -1211,6 +1224,10 @@ bnx2_set_link(struct bnx2 *bp)
 	    (CHIP_NUM(bp) == CHIP_NUM_5706)) {
 		u32 val;
 
+		if (bp->phy_flags & PHY_FORCED_DOWN_FLAG) {
+			bnx2_5706s_force_link_dn(bp, 0);
+			bp->phy_flags &= ~PHY_FORCED_DOWN_FLAG;
+		}
 		val = REG_RD(bp, BNX2_EMAC_STATUS);
 		if (val & BNX2_EMAC_STATUS_LINK)
 			bmsr |= BMSR_LSTATUS;
@@ -1239,7 +1256,15 @@ bnx2_set_link(struct bnx2 *bp)
 		    (bp->autoneg & AUTONEG_SPEED))
 			bnx2_disable_forced_2g5(bp);
 
-		bp->phy_flags &= ~PHY_PARALLEL_DETECT_FLAG;
+		if (bp->phy_flags & PHY_PARALLEL_DETECT_FLAG) {
+			u32 bmcr;
+
+			bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
+			bmcr |= BMCR_ANENABLE;
+			bnx2_write_phy(bp, bp->mii_bmcr, bmcr);
+
+			bp->phy_flags &= ~PHY_PARALLEL_DETECT_FLAG;
+		}
 		bp->link_up = 0;
 	}
 
@@ -5276,13 +5301,51 @@ bnx2_test_intr(struct bnx2 *bp)
 	return -ENODEV;
 }
 
+static int
+bnx2_5706_serdes_has_link(struct bnx2 *bp)
+{
+	u32 mode_ctl, an_dbg, exp;
+
+	bnx2_write_phy(bp, MII_BNX2_MISC_SHADOW, MISC_SHDW_MODE_CTL);
+	bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &mode_ctl);
+
+	if (!(mode_ctl & MISC_SHDW_MODE_CTL_SIG_DET))
+		return 0;
+
+	bnx2_write_phy(bp, MII_BNX2_MISC_SHADOW, MISC_SHDW_AN_DBG);
+	bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &an_dbg);
+	bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &an_dbg);
+
+	if (an_dbg & MISC_SHDW_AN_DBG_NOSYNC)
+		return 0;
+
+	bnx2_write_phy(bp, MII_BNX2_DSP_ADDRESS, MII_EXPAND_REG1);
+	bnx2_read_phy(bp, MII_BNX2_DSP_RW_PORT, &exp);
+	bnx2_read_phy(bp, MII_BNX2_DSP_RW_PORT, &exp);
+
+	if (exp & MII_EXPAND_REG1_RUDI_C)	/* receiving CONFIG */
+		return 0;
+
+	return 1;
+}
+
 static void
 bnx2_5706_serdes_timer(struct bnx2 *bp)
 {
+	int check_link = 1;
+
 	spin_lock(&bp->phy_lock);
-	if (bp->serdes_an_pending)
+	if (bp->phy_flags & PHY_FORCED_DOWN_FLAG) {
+		bnx2_5706s_force_link_dn(bp, 0);
+		bp->phy_flags &= ~PHY_FORCED_DOWN_FLAG;
+		spin_unlock(&bp->phy_lock);
+		return;
+	}
+
+	if (bp->serdes_an_pending) {
 		bp->serdes_an_pending--;
-	else if ((bp->link_up == 0) && (bp->autoneg & AUTONEG_SPEED)) {
+		check_link = 0;
+	} else if ((bp->link_up == 0) && (bp->autoneg & AUTONEG_SPEED)) {
 		u32 bmcr;
 
 		bp->current_interval = bp->timer_interval;
@@ -5290,19 +5353,7 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 
 		if (bmcr & BMCR_ANENABLE) {
-			u32 phy1, phy2;
-
-			bnx2_write_phy(bp, 0x1c, 0x7c00);
-			bnx2_read_phy(bp, 0x1c, &phy1);
-
-			bnx2_write_phy(bp, 0x17, 0x0f01);
-			bnx2_read_phy(bp, 0x15, &phy2);
-			bnx2_write_phy(bp, 0x17, 0x0f01);
-			bnx2_read_phy(bp, 0x15, &phy2);
-
-			if ((phy1 & 0x10) &&	/* SIGNAL DETECT */
-				!(phy2 & 0x20)) {	/* no CONFIG */
-
+			if (bnx2_5706_serdes_has_link(bp)) {
 				bmcr &= ~BMCR_ANENABLE;
 				bmcr |= BMCR_SPEED1000 | BMCR_FULLDPLX;
 				bnx2_write_phy(bp, bp->mii_bmcr, bmcr);
@@ -5314,6 +5365,7 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 		 (bp->phy_flags & PHY_PARALLEL_DETECT_FLAG)) {
 		u32 phy2;
 
+		check_link = 0;
 		bnx2_write_phy(bp, 0x17, 0x0f01);
 		bnx2_read_phy(bp, 0x15, &phy2);
 		if (phy2 & 0x20) {
@@ -5328,6 +5380,18 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 	} else
 		bp->current_interval = bp->timer_interval;
 
+	if (bp->link_up && (bp->autoneg & AUTONEG_SPEED) && check_link) {
+		u32 val;
+
+		bnx2_write_phy(bp, MII_BNX2_MISC_SHADOW, MISC_SHDW_AN_DBG);
+		bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &val);
+		bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &val);
+
+		if (val & MISC_SHDW_AN_DBG_NOSYNC) {
+			bnx2_5706s_force_link_dn(bp, 1);
+			bp->phy_flags |= PHY_FORCED_DOWN_FLAG;
+		}
+	}
 	spin_unlock(&bp->phy_lock);
 }
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index c1ab30b..31a030a 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6344,6 +6344,15 @@ struct l2_fhdr {
 #define MII_BNX2_DSP_RW_PORT			0x15
 #define MII_BNX2_DSP_ADDRESS			0x17
 #define MII_BNX2_DSP_EXPAND_REG			 0x0f00
+#define MII_EXPAND_REG1				  (MII_BNX2_DSP_EXPAND_REG | 1)
+#define MII_EXPAND_REG1_RUDI_C			   0x20
+#define MII_EXPAND_SERDES_CTL			  (MII_BNX2_DSP_EXPAND_REG | 2)
+
+#define MII_BNX2_MISC_SHADOW			0x1c
+#define MISC_SHDW_AN_DBG			 0x6800
+#define MISC_SHDW_AN_DBG_NOSYNC			  0x0002
+#define MISC_SHDW_MODE_CTL			 0x7c00
+#define MISC_SHDW_MODE_CTL_SIG_DET		  0x0010
 
 #define MII_BNX2_BLK_ADDR			0x1f
 #define MII_BNX2_BLK_ADDR_IEEE0			 0x0000
@@ -6643,6 +6652,7 @@ struct bnx2 {
 #define PHY_INT_MODE_LINK_READY_FLAG	0x200
 #define PHY_DIS_EARLY_DAC_FLAG		0x400
 #define REMOTE_PHY_CAP_FLAG		0x800
+#define PHY_FORCED_DOWN_FLAG		0x1000
 
 	u32			mii_bmcr;
 	u32			mii_bmsr;


