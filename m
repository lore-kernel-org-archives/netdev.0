From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/3][BNX2]: Fix remote PHY media detection problems.
Date: Wed, 10 Oct 2007 17:01:32 -0700
Message-ID: <1192060892.6534.4.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3187 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756692AbXJJXCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 19:02:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix remote PHY media detection problems.

The remote PHY media type and link status can change between
->probe() and ->open().  For correct operation, we need to get the
new status again during ->open().

The ethtool link test and loopback test are also fixed to work with
remote PHY.  PHY loopback is simply skipped when remote PHY is
present.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 0e4928c..21493e0 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3776,12 +3776,6 @@ bnx2_init_remote_phy(struct bnx2 *bp)
 		return;
 
 	if (val & BNX2_FW_CAP_REMOTE_PHY_CAPABLE) {
-		if (netif_running(bp->dev)) {
-			val = BNX2_DRV_ACK_CAP_SIGNATURE |
-			      BNX2_FW_CAP_REMOTE_PHY_CAPABLE;
-			REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_ACK_CAP_MB,
-				   val);
-		}
 		bp->phy_flags |= REMOTE_PHY_CAP_FLAG;
 
 		val = REG_RD_IND(bp, bp->shmem_base + BNX2_LINK_STATUS);
@@ -3789,6 +3783,22 @@ bnx2_init_remote_phy(struct bnx2 *bp)
 			bp->phy_port = PORT_FIBRE;
 		else
 			bp->phy_port = PORT_TP;
+
+		if (netif_running(bp->dev)) {
+			u32 sig;
+
+			if (val & BNX2_LINK_STATUS_LINK_UP) {
+				bp->link_up = 1;
+				netif_carrier_on(bp->dev);
+			} else {
+				bp->link_up = 0;
+				netif_carrier_off(bp->dev);
+			}
+			sig = BNX2_DRV_ACK_CAP_SIGNATURE |
+			      BNX2_FW_CAP_REMOTE_PHY_CAPABLE;
+			REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_ACK_CAP_MB,
+				   sig);
+		}
 	}
 }
 
@@ -3797,6 +3807,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 {
 	u32 val;
 	int i, rc = 0;
+	u8 old_port;
 
 	/* Wait for the current PCI transaction to complete before
 	 * issuing a reset. */
@@ -3875,8 +3886,9 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 		return rc;
 
 	spin_lock_bh(&bp->phy_lock);
+	old_port = bp->phy_port;
 	bnx2_init_remote_phy(bp);
-	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+	if ((bp->phy_flags & REMOTE_PHY_CAP_FLAG) && old_port != bp->phy_port)
 		bnx2_set_default_remote_link(bp);
 	spin_unlock_bh(&bp->phy_lock);
 
@@ -4565,6 +4577,9 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 		bnx2_set_mac_loopback(bp);
 	}
 	else if (loopback_mode == BNX2_PHY_LOOPBACK) {
+		if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+			return 0;
+
 		bp->loopback = PHY_LOOPBACK;
 		bnx2_set_phy_loopback(bp);
 	}
@@ -4733,6 +4748,11 @@ bnx2_test_link(struct bnx2 *bp)
 {
 	u32 bmsr;
 
+	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG) {
+		if (bp->link_up)
+			return 0;
+		return -ENODEV;
+	}
 	spin_lock_bh(&bp->phy_lock);
 	bnx2_enable_bmsr1(bp);
 	bnx2_read_phy(bp, bp->mii_bmsr1, &bmsr);


