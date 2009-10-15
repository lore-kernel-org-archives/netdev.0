From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 4/8] bnx2x: Changing the Disabled state to a flag
Date: Thu, 15 Oct 2009 08:48:37 +0200
Message-ID: <1255589317.25030.74.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3319 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933013AbZJOGtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 02:49:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When working with DCC, a function can be disabled or enabled (virtual link down
or up). Using the function state introduced some race conditions with the
load/unload flow.
Using a separate flag to indicate that the function is disabled.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    2 +-
 drivers/net/bnx2x_main.c |   34 +++++++++++++++++++---------------
 2 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 60fa14f..185a6ba 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -900,6 +900,7 @@ struct bnx2x {
 #define BP_NOMCP(bp)			(bp->flags & NO_MCP_FLAG)
 #define HW_VLAN_TX_FLAG			0x400
 #define HW_VLAN_RX_FLAG			0x800
+#define MF_FUNC_DIS			0x1000
 
 	int			func;
 #define BP_PORT(bp)			(bp->func % PORT_MAX)
@@ -965,7 +966,6 @@ struct bnx2x {
 #define BNX2X_STATE_CLOSING_WAIT4_HALT	0x4000
 #define BNX2X_STATE_CLOSING_WAIT4_DELETE 0x5000
 #define BNX2X_STATE_CLOSING_WAIT4_UNLOAD 0x6000
-#define BNX2X_STATE_DISABLED		0xd000
 #define BNX2X_STATE_DIAG		0xe000
 #define BNX2X_STATE_ERROR		0xf000
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 691cf15..e7b3b27 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1043,7 +1043,6 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 		break;
 
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_CLOSING_WAIT4_HALT):
-	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_DISABLED):
 		DP(NETIF_MSG_IFDOWN, "got (un)set mac ramrod\n");
 		bp->set_mac_pending--;
 		smp_wmb();
@@ -2157,7 +2156,7 @@ static void bnx2x_calc_fc_adv(struct bnx2x *bp)
 
 static void bnx2x_link_report(struct bnx2x *bp)
 {
-	if (bp->state == BNX2X_STATE_DISABLED) {
+	if (bp->flags & MF_FUNC_DIS) {
 		netif_carrier_off(bp->dev);
 		printk(KERN_ERR PFX "%s NIC Link is Down\n", bp->dev->name);
 		return;
@@ -2437,8 +2436,7 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 			memset(&(pstats->mac_stx[0]), 0,
 			       sizeof(struct mac_stx));
 		}
-		if ((bp->state == BNX2X_STATE_OPEN) ||
-		    (bp->state == BNX2X_STATE_DISABLED))
+		if (bp->state == BNX2X_STATE_OPEN)
 			bnx2x_stats_handle(bp, STATS_EVENT_LINK_UP);
 	}
 
@@ -2481,9 +2479,7 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 
 static void bnx2x__link_status_update(struct bnx2x *bp)
 {
-	int func = BP_FUNC(bp);
-
-	if (bp->state != BNX2X_STATE_OPEN)
+	if ((bp->state != BNX2X_STATE_OPEN) || (bp->flags & MF_FUNC_DIS))
 		return;
 
 	bnx2x_link_status_update(&bp->link_params, &bp->link_vars);
@@ -2640,14 +2636,19 @@ static void bnx2x_dcc_event(struct bnx2x *bp, u32 dcc_event)
 
 	if (dcc_event & DRV_STATUS_DCC_DISABLE_ENABLE_PF) {
 
+		/*
+		 * This is the only place besides the function initialization
+		 * where the bp->flags can change so it is done without any
+		 * locks
+		 */
 		if (bp->mf_config & FUNC_MF_CFG_FUNC_DISABLED) {
 			DP(NETIF_MSG_IFDOWN, "mf_cfg function disabled\n");
-			bp->state = BNX2X_STATE_DISABLED;
+			bp->flags |= MF_FUNC_DIS;
 
 			bnx2x_e1h_disable(bp);
 		} else {
 			DP(NETIF_MSG_IFUP, "mf_cfg function enabled\n");
-			bp->state = BNX2X_STATE_OPEN;
+			bp->flags &= ~MF_FUNC_DIS;
 
 			bnx2x_e1h_enable(bp);
 		}
@@ -4695,8 +4696,7 @@ static void bnx2x_timer(unsigned long data)
 		}
 	}
 
-	if ((bp->state == BNX2X_STATE_OPEN) ||
-	    (bp->state == BNX2X_STATE_DISABLED))
+	if (bp->state == BNX2X_STATE_OPEN)
 		bnx2x_stats_handle(bp, STATS_EVENT_UPDATE);
 
 timer_restart:
@@ -7629,7 +7629,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	if (CHIP_IS_E1H(bp))
 		if (bp->mf_config & FUNC_MF_CFG_FUNC_DISABLED) {
 			DP(NETIF_MSG_IFUP, "mf_cfg function disabled\n");
-			bp->state = BNX2X_STATE_DISABLED;
+			bp->flags |= MF_FUNC_DIS;
 		}
 
 	if (bp->state == BNX2X_STATE_OPEN) {
@@ -9034,7 +9034,9 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	cmd->supported = bp->port.supported;
 	cmd->advertising = bp->port.advertising;
 
-	if (netif_carrier_ok(dev)) {
+	if ((bp->state == BNX2X_STATE_OPEN) &&
+	    !(bp->flags & MF_FUNC_DIS) &&
+	    (bp->link_vars.link_up)) {
 		cmd->speed = bp->link_vars.line_speed;
 		cmd->duplex = bp->link_vars.duplex;
 		if (IS_E1HMF(bp)) {
@@ -9433,6 +9435,9 @@ static u32 bnx2x_get_link(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
+	if (bp->flags & MF_FUNC_DIS)
+		return 0;
+
 	return bp->link_vars.link_up;
 }
 
@@ -9837,8 +9842,7 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 
 	} else if (eeprom->magic == 0x50485952) {
 		/* 'PHYR' (0x50485952): re-init link after FW upgrade */
-		if ((bp->state == BNX2X_STATE_OPEN) ||
-		    (bp->state == BNX2X_STATE_DISABLED)) {
+		if (bp->state == BNX2X_STATE_OPEN) {
 			bnx2x_acquire_phy_lock(bp);
 			rc |= bnx2x_link_reset(&bp->link_params,
 					       &bp->link_vars, 1);
-- 
1.5.4.3




