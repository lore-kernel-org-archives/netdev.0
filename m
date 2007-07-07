From: "Michael Chan" <mchan@broadcom.com>
Subject: [2.6.23 3/9][BNX2]: Add support for remote PHY.
Date: Fri, 06 Jul 2007 20:29:25 -0700
Message-ID: <1183778965.5182.20.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4190 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753695AbXGGChK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 22:37:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add support for remote PHY.

In blade servers, the Serdes PHY in 5708S can control the remote
copper PHY through autonegotiation on the backplane.  This patch adds
the logic to interface with the firmware to control the remote PHY
autonegotiation and to handle remote PHY link events.

When remote PHY is present, the 5708S Serdes device practically
becomes a copper device with full control over the 1000Base-T
link settings.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 56bc41e..3268d16 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -550,6 +550,9 @@ bnx2_report_fw_link(struct bnx2 *bp)
 {
 	u32 fw_link_status = 0;
 
+	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+		return;
+
 	if (bp->link_up) {
 		u32 bmsr;
 
@@ -1100,6 +1103,9 @@ bnx2_set_link(struct bnx2 *bp)
 		return 0;
 	}
 
+	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+		return 0;
+
 	link_up = bp->link_up;
 
 	bnx2_enable_bmsr1(bp);
@@ -1210,12 +1216,74 @@ bnx2_phy_get_pause_adv(struct bnx2 *bp)
 	return adv;
 }
 
+static int bnx2_fw_sync(struct bnx2 *, u32, int);
+
 static int
-bnx2_setup_serdes_phy(struct bnx2 *bp)
+bnx2_setup_remote_phy(struct bnx2 *bp, u8 port)
+{
+	u32 speed_arg = 0, pause_adv;
+
+	pause_adv = bnx2_phy_get_pause_adv(bp);
+
+	if (bp->autoneg & AUTONEG_SPEED) {
+		speed_arg |= BNX2_NETLINK_SET_LINK_ENABLE_AUTONEG;
+		if (bp->advertising & ADVERTISED_10baseT_Half)
+			speed_arg |= BNX2_NETLINK_SET_LINK_SPEED_10HALF;
+		if (bp->advertising & ADVERTISED_10baseT_Full)
+			speed_arg |= BNX2_NETLINK_SET_LINK_SPEED_10FULL;
+		if (bp->advertising & ADVERTISED_100baseT_Half)
+			speed_arg |= BNX2_NETLINK_SET_LINK_SPEED_100HALF;
+		if (bp->advertising & ADVERTISED_100baseT_Full)
+			speed_arg |= BNX2_NETLINK_SET_LINK_SPEED_100FULL;
+		if (bp->advertising & ADVERTISED_1000baseT_Full)
+			speed_arg |= BNX2_NETLINK_SET_LINK_SPEED_1GFULL;
+		if (bp->advertising & ADVERTISED_2500baseX_Full)
+			speed_arg |= BNX2_NETLINK_SET_LINK_SPEED_2G5FULL;
+	} else {
+		if (bp->req_line_speed == SPEED_2500)
+			speed_arg = BNX2_NETLINK_SET_LINK_SPEED_2G5FULL;
+		else if (bp->req_line_speed == SPEED_1000)
+			speed_arg = BNX2_NETLINK_SET_LINK_SPEED_1GFULL;
+		else if (bp->req_line_speed == SPEED_100) {
+			if (bp->req_duplex == DUPLEX_FULL)
+				speed_arg = BNX2_NETLINK_SET_LINK_SPEED_100FULL;
+			else
+				speed_arg = BNX2_NETLINK_SET_LINK_SPEED_100HALF;
+		} else if (bp->req_line_speed == SPEED_10) {
+			if (bp->req_duplex == DUPLEX_FULL)
+				speed_arg = BNX2_NETLINK_SET_LINK_SPEED_10FULL;
+			else
+				speed_arg = BNX2_NETLINK_SET_LINK_SPEED_10HALF;
+		}
+	}
+
+	if (pause_adv & (ADVERTISE_1000XPAUSE | ADVERTISE_PAUSE_CAP))
+		speed_arg |= BNX2_NETLINK_SET_LINK_FC_SYM_PAUSE;
+	if (pause_adv & (ADVERTISE_1000XPSE_ASYM | ADVERTISE_1000XPSE_ASYM))
+		speed_arg |= BNX2_NETLINK_SET_LINK_FC_ASYM_PAUSE;
+
+	if (port == PORT_TP)
+		speed_arg |= BNX2_NETLINK_SET_LINK_PHY_APP_REMOTE |
+			     BNX2_NETLINK_SET_LINK_ETH_AT_WIRESPEED;
+
+	REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_MB_ARG0, speed_arg);
+
+	spin_unlock_bh(&bp->phy_lock);
+	bnx2_fw_sync(bp, BNX2_DRV_MSG_CODE_CMD_SET_LINK, 0);
+	spin_lock_bh(&bp->phy_lock);
+
+	return 0;
+}
+
+static int
+bnx2_setup_serdes_phy(struct bnx2 *bp, u8 port)
 {
 	u32 adv, bmcr;
 	u32 new_adv = 0;
 
+	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+		return (bnx2_setup_remote_phy(bp, port));
+
 	if (!(bp->autoneg & AUTONEG_SPEED)) {
 		u32 new_bmcr;
 		int force_link_down = 0;
@@ -1338,8 +1406,58 @@ bnx2_setup_serdes_phy(struct bnx2 *bp)
 #define PHY_ALL_1000_SPEED (ADVERTISE_1000HALF | ADVERTISE_1000FULL)
 
 static void
+bnx2_set_default_remote_link(struct bnx2 *bp)
+{
+	u32 link;
+
+	if (bp->phy_port == PORT_TP)
+		link = REG_RD_IND(bp, bp->shmem_base + BNX2_RPHY_COPPER_LINK);
+	else
+		link = REG_RD_IND(bp, bp->shmem_base + BNX2_RPHY_SERDES_LINK);
+
+	if (link & BNX2_NETLINK_SET_LINK_ENABLE_AUTONEG) {
+		bp->req_line_speed = 0;
+		bp->autoneg |= AUTONEG_SPEED;
+		bp->advertising = ADVERTISED_Autoneg;
+		if (link & BNX2_NETLINK_SET_LINK_SPEED_10HALF)
+			bp->advertising |= ADVERTISED_10baseT_Half;
+		if (link & BNX2_NETLINK_SET_LINK_SPEED_10FULL)
+			bp->advertising |= ADVERTISED_10baseT_Full;
+		if (link & BNX2_NETLINK_SET_LINK_SPEED_100HALF)
+			bp->advertising |= ADVERTISED_100baseT_Half;
+		if (link & BNX2_NETLINK_SET_LINK_SPEED_100FULL)
+			bp->advertising |= ADVERTISED_100baseT_Full;
+		if (link & BNX2_NETLINK_SET_LINK_SPEED_1GFULL)
+			bp->advertising |= ADVERTISED_1000baseT_Full;
+		if (link & BNX2_NETLINK_SET_LINK_SPEED_2G5FULL)
+			bp->advertising |= ADVERTISED_2500baseX_Full;
+	} else {
+		bp->autoneg = 0;
+		bp->advertising = 0;
+		bp->req_duplex = DUPLEX_FULL;
+		if (link & BNX2_NETLINK_SET_LINK_SPEED_10) {
+			bp->req_line_speed = SPEED_10;
+			if (link & BNX2_NETLINK_SET_LINK_SPEED_10HALF)
+				bp->req_duplex = DUPLEX_HALF;
+		}
+		if (link & BNX2_NETLINK_SET_LINK_SPEED_100) {
+			bp->req_line_speed = SPEED_100;
+			if (link & BNX2_NETLINK_SET_LINK_SPEED_100HALF)
+				bp->req_duplex = DUPLEX_HALF;
+		}
+		if (link & BNX2_NETLINK_SET_LINK_SPEED_1GFULL)
+			bp->req_line_speed = SPEED_1000;
+		if (link & BNX2_NETLINK_SET_LINK_SPEED_2G5FULL)
+			bp->req_line_speed = SPEED_2500;
+	}
+}
+
+static void
 bnx2_set_default_link(struct bnx2 *bp)
 {
+	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+		return bnx2_set_default_remote_link(bp);
+
 	bp->autoneg = AUTONEG_SPEED | AUTONEG_FLOW_CTRL;
 	bp->req_line_speed = 0;
 	if (bp->phy_flags & PHY_SERDES_FLAG) {
@@ -1358,6 +1476,97 @@ bnx2_set_default_link(struct bnx2 *bp)
 		bp->advertising = ETHTOOL_ALL_COPPER_SPEED | ADVERTISED_Autoneg;
 }
 
+static void
+bnx2_remote_phy_event(struct bnx2 *bp)
+{
+	u32 msg;
+	u8 link_up = bp->link_up;
+	u8 old_port;
+
+	msg = REG_RD_IND(bp, bp->shmem_base + BNX2_LINK_STATUS);
+
+	if ((msg & BNX2_LINK_STATUS_LINK_UP) == BNX2_LINK_STATUS_LINK_DOWN)
+		bp->link_up = 0;
+	else {
+		u32 speed;
+
+		bp->link_up = 1;
+		speed = msg & BNX2_LINK_STATUS_SPEED_MASK;
+		bp->duplex = DUPLEX_FULL;
+		switch (speed) {
+			case BNX2_LINK_STATUS_10HALF:
+				bp->duplex = DUPLEX_HALF;
+			case BNX2_LINK_STATUS_10FULL:
+				bp->line_speed = SPEED_10;
+				break;
+			case BNX2_LINK_STATUS_100HALF:
+				bp->duplex = DUPLEX_HALF;
+			case BNX2_LINK_STATUS_100BASE_T4:
+			case BNX2_LINK_STATUS_100FULL:
+				bp->line_speed = SPEED_100;
+				break;
+			case BNX2_LINK_STATUS_1000HALF:
+				bp->duplex = DUPLEX_HALF;
+			case BNX2_LINK_STATUS_1000FULL:
+				bp->line_speed = SPEED_1000;
+				break;
+			case BNX2_LINK_STATUS_2500HALF:
+				bp->duplex = DUPLEX_HALF;
+			case BNX2_LINK_STATUS_2500FULL:
+				bp->line_speed = SPEED_2500;
+				break;
+			default:
+				bp->line_speed = 0;
+				break;
+		}
+
+		spin_lock(&bp->phy_lock);
+		bp->flow_ctrl = 0;
+		if ((bp->autoneg & (AUTONEG_SPEED | AUTONEG_FLOW_CTRL)) !=
+		    (AUTONEG_SPEED | AUTONEG_FLOW_CTRL)) {
+			if (bp->duplex == DUPLEX_FULL)
+				bp->flow_ctrl = bp->req_flow_ctrl;
+		} else {
+			if (msg & BNX2_LINK_STATUS_TX_FC_ENABLED)
+				bp->flow_ctrl |= FLOW_CTRL_TX;
+			if (msg & BNX2_LINK_STATUS_RX_FC_ENABLED)
+				bp->flow_ctrl |= FLOW_CTRL_RX;
+		}
+
+		old_port = bp->phy_port;
+		if (msg & BNX2_LINK_STATUS_SERDES_LINK)
+			bp->phy_port = PORT_FIBRE;
+		else
+			bp->phy_port = PORT_TP;
+
+		if (old_port != bp->phy_port)
+			bnx2_set_default_link(bp);
+
+		spin_unlock(&bp->phy_lock);
+	}
+	if (bp->link_up != link_up)
+		bnx2_report_link(bp);
+
+	bnx2_set_mac_link(bp);
+}
+
+static int
+bnx2_set_remote_link(struct bnx2 *bp)
+{
+	u32 evt_code;
+
+	evt_code = REG_RD_IND(bp, bp->shmem_base + BNX2_FW_EVT_CODE_MB);
+	switch (evt_code) {
+		case BNX2_FW_EVT_CODE_LINK_EVENT:
+			bnx2_remote_phy_event(bp);
+			break;
+		case BNX2_FW_EVT_CODE_SW_TIMER_EXPIRATION_EVENT:
+		default:
+			break;
+	}
+	return 0;
+}
+
 static int
 bnx2_setup_copper_phy(struct bnx2 *bp)
 {
@@ -1456,13 +1665,13 @@ bnx2_setup_copper_phy(struct bnx2 *bp)
 }
 
 static int
-bnx2_setup_phy(struct bnx2 *bp)
+bnx2_setup_phy(struct bnx2 *bp, u8 port)
 {
 	if (bp->loopback == MAC_LOOPBACK)
 		return 0;
 
 	if (bp->phy_flags & PHY_SERDES_FLAG) {
-		return (bnx2_setup_serdes_phy(bp));
+		return (bnx2_setup_serdes_phy(bp, port));
 	}
 	else {
 		return (bnx2_setup_copper_phy(bp));
@@ -1682,6 +1891,9 @@ bnx2_init_phy(struct bnx2 *bp)
 
         REG_WR(bp, BNX2_EMAC_ATTENTION_ENA, BNX2_EMAC_ATTENTION_ENA_LINK);
 
+	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+		goto setup_phy;
+
 	bnx2_read_phy(bp, MII_PHYSID1, &val);
 	bp->phy_id = val << 16;
 	bnx2_read_phy(bp, MII_PHYSID2, &val);
@@ -1699,7 +1911,9 @@ bnx2_init_phy(struct bnx2 *bp)
 		rc = bnx2_init_copper_phy(bp);
 	}
 
-	bnx2_setup_phy(bp);
+setup_phy:
+	if (!rc)
+		rc = bnx2_setup_phy(bp, bp->phy_port);
 
 	return rc;
 }
@@ -2007,6 +2221,9 @@ bnx2_phy_int(struct bnx2 *bp)
 		bnx2_set_link(bp);
 		spin_unlock(&bp->phy_lock);
 	}
+	if (bnx2_phy_event_is_set(bp, STATUS_ATTN_BITS_TIMER_ABORT))
+		bnx2_set_remote_link(bp);
+
 }
 
 static void
@@ -2345,7 +2562,8 @@ bnx2_interrupt(int irq, void *dev_instance)
 	return IRQ_HANDLED;
 }
 
-#define STATUS_ATTN_EVENTS	STATUS_ATTN_BITS_LINK_STATE
+#define STATUS_ATTN_EVENTS	(STATUS_ATTN_BITS_LINK_STATE | \
+				 STATUS_ATTN_BITS_TIMER_ABORT)
 
 static inline int
 bnx2_has_work(struct bnx2 *bp)
@@ -3585,6 +3803,36 @@ nvram_write_end:
 	return rc;
 }
 
+static void
+bnx2_init_remote_phy(struct bnx2 *bp)
+{
+	u32 val;
+
+	bp->phy_flags &= ~REMOTE_PHY_CAP_FLAG;
+	if (!(bp->phy_flags & PHY_SERDES_FLAG))
+		return;
+
+	val = REG_RD_IND(bp, bp->shmem_base + BNX2_FW_CAP_MB);
+	if ((val & BNX2_FW_CAP_SIGNATURE_MASK) != BNX2_FW_CAP_SIGNATURE)
+		return;
+
+	if (val & BNX2_FW_CAP_REMOTE_PHY_CAPABLE) {
+		if (netif_running(bp->dev)) {
+			val = BNX2_DRV_ACK_CAP_SIGNATURE |
+			      BNX2_FW_CAP_REMOTE_PHY_CAPABLE;
+			REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_ACK_CAP_MB,
+				   val);
+		}
+		bp->phy_flags |= REMOTE_PHY_CAP_FLAG;
+
+		val = REG_RD_IND(bp, bp->shmem_base + BNX2_LINK_STATUS);
+		if (val & BNX2_LINK_STATUS_SERDES_LINK)
+			bp->phy_port = PORT_FIBRE;
+		else
+			bp->phy_port = PORT_TP;
+	}
+}
+
 static int
 bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 {
@@ -3665,6 +3913,12 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 	if (rc)
 		return rc;
 
+	spin_lock_bh(&bp->phy_lock);
+	bnx2_init_remote_phy(bp);
+	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+		bnx2_set_default_remote_link(bp);
+	spin_unlock_bh(&bp->phy_lock);
+
 	if (CHIP_ID(bp) == CHIP_ID_5706_A0) {
 		/* Adjust the voltage regular to two steps lower.  The default
 		 * of this register is 0x0000000e. */
@@ -4092,8 +4346,8 @@ bnx2_init_nic(struct bnx2 *bp)
 
 	spin_lock_bh(&bp->phy_lock);
 	bnx2_init_phy(bp);
-	spin_unlock_bh(&bp->phy_lock);
 	bnx2_set_link(bp);
+	spin_unlock_bh(&bp->phy_lock);
 	return 0;
 }
 
@@ -4623,6 +4877,9 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 static void
 bnx2_5708_serdes_timer(struct bnx2 *bp)
 {
+	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+		return;
+
 	if ((bp->phy_flags & PHY_2_5G_CAPABLE_FLAG) == 0) {
 		bp->serdes_an_pending = 0;
 		return;
@@ -5222,7 +5479,7 @@ bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	spin_lock_bh(&bp->phy_lock);
 
-	bnx2_setup_phy(bp);
+	bnx2_setup_phy(bp, bp->phy_port);
 
 	spin_unlock_bh(&bp->phy_lock);
 
@@ -5566,7 +5823,7 @@ bnx2_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam *epause)
 
 	spin_lock_bh(&bp->phy_lock);
 
-	bnx2_setup_phy(bp);
+	bnx2_setup_phy(bp, bp->phy_port);
 
 	spin_unlock_bh(&bp->phy_lock);
 
@@ -6338,7 +6595,9 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	else if (CHIP_BOND_ID(bp) & CHIP_BOND_ID_SERDES_BIT)
 		bp->phy_flags |= PHY_SERDES_FLAG;
 
+	bp->phy_port = PORT_TP;
 	if (bp->phy_flags & PHY_SERDES_FLAG) {
+		bp->phy_port = PORT_FIBRE;
 		bp->flags |= NO_WOL_FLAG;
 		if (CHIP_NUM(bp) != CHIP_NUM_5706) {
 			bp->phy_addr = 2;
@@ -6347,6 +6606,8 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 			if (reg & BNX2_SHARED_HW_CFG_PHY_2_5G)
 				bp->phy_flags |= PHY_2_5G_CAPABLE_FLAG;
 		}
+		bnx2_init_remote_phy(bp);
+
 	} else if (CHIP_NUM(bp) == CHIP_NUM_5706 ||
 		   CHIP_NUM(bp) == CHIP_NUM_5708)
 		bp->phy_flags |= PHY_CRC_FIX_FLAG;


