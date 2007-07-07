From: "Michael Chan" <mchan@broadcom.com>
Subject: [2.6.23 1/9][BNX2]: Add bnx2_set_default_link().
Date: Fri, 06 Jul 2007 20:28:45 -0700
Message-ID: <1183778925.5182.18.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4153 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667AbXGGCga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 22:36:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add bnx2_set_default_link().

Put existing code to setup the default link settings in this new
function.  This makes it easier to support the remote PHY feature in
the next few patches.

Also change ETHTOOL_ALL_FIBRE_SPEED to include 2500Mbps if supported.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 0f4f76f..56bc41e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1323,7 +1323,9 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 }
 
 #define ETHTOOL_ALL_FIBRE_SPEED						\
-	(ADVERTISED_1000baseT_Full)
+	(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG) ?			\
+		(ADVERTISED_2500baseX_Full | ADVERTISED_1000baseT_Full) :\
+		(ADVERTISED_1000baseT_Full)
 
 #define ETHTOOL_ALL_COPPER_SPEED					\
 	(ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |		\
@@ -1335,6 +1337,27 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 
 #define PHY_ALL_1000_SPEED (ADVERTISE_1000HALF | ADVERTISE_1000FULL)
 
+static void
+bnx2_set_default_link(struct bnx2 *bp)
+{
+	bp->autoneg = AUTONEG_SPEED | AUTONEG_FLOW_CTRL;
+	bp->req_line_speed = 0;
+	if (bp->phy_flags & PHY_SERDES_FLAG) {
+		u32 reg;
+
+		bp->advertising = ETHTOOL_ALL_FIBRE_SPEED | ADVERTISED_Autoneg;
+
+		reg = REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_HW_CFG_CONFIG);
+		reg &= BNX2_PORT_HW_CFG_CFG_DFLT_LINK_MASK;
+		if (reg == BNX2_PORT_HW_CFG_CFG_DFLT_LINK_1G) {
+			bp->autoneg = 0;
+			bp->req_line_speed = bp->line_speed = SPEED_1000;
+			bp->req_duplex = DUPLEX_FULL;
+		}
+	} else
+		bp->advertising = ETHTOOL_ALL_COPPER_SPEED | ADVERTISED_Autoneg;
+}
+
 static int
 bnx2_setup_copper_phy(struct bnx2 *bp)
 {
@@ -6374,23 +6397,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		}
 	}
 
-	bp->autoneg = AUTONEG_SPEED | AUTONEG_FLOW_CTRL;
-	bp->req_line_speed = 0;
-	if (bp->phy_flags & PHY_SERDES_FLAG) {
-		bp->advertising = ETHTOOL_ALL_FIBRE_SPEED | ADVERTISED_Autoneg;
-
-		reg = REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_HW_CFG_CONFIG);
-		reg &= BNX2_PORT_HW_CFG_CFG_DFLT_LINK_MASK;
-		if (reg == BNX2_PORT_HW_CFG_CFG_DFLT_LINK_1G) {
-			bp->autoneg = 0;
-			bp->req_line_speed = bp->line_speed = SPEED_1000;
-			bp->req_duplex = DUPLEX_FULL;
-		}
-	}
-	else {
-		bp->advertising = ETHTOOL_ALL_COPPER_SPEED | ADVERTISED_Autoneg;
-	}
-
+	bnx2_set_default_link(bp);
 	bp->req_flow_ctrl = FLOW_CTRL_RX | FLOW_CTRL_TX;
 
 	init_timer(&bp->timer);


