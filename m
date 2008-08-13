From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 12/25] bnx2x: Clearing MAC addresses filters
Date: Wed, 13 Aug 2008 17:14:26 +0300
Message-ID: <1218636866.547.88.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yitchak Gertner" <gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4376 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756333AbYHMOOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:14:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clearing MAC addresses filters
When the driver unloads, it should clear the MAC addresses filters in
the HW - this prevents packets from entering the chip when the driver is
re-loaded before initializing the right filters

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   68 ++++++++++++++++++++++++++++++++++++---------
 1 files changed, 54 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ea6fcf3..db6a3b9 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6048,7 +6048,7 @@ static int bnx2x_req_irq(struct bnx2x *bp)
  * Init service functions
  */
 
-static void bnx2x_set_mac_addr_e1(struct bnx2x *bp)
+static void bnx2x_set_mac_addr_e1(struct bnx2x *bp, int set)
 {
 	struct mac_configuration_cmd *config = bnx2x_sp(bp, mac_config);
 	int port = BP_PORT(bp);
@@ -6070,11 +6070,15 @@ static void bnx2x_set_mac_addr_e1(struct bnx2x *bp)
 	config->config_table[0].cam_entry.lsb_mac_addr =
 					swab16(*(u16 *)&bp->dev->dev_addr[4]);
 	config->config_table[0].cam_entry.flags = cpu_to_le16(port);
-	config->config_table[0].target_table_entry.flags = 0;
+	if (set)
+		config->config_table[0].target_table_entry.flags = 0;
+	else
+		CAM_INVALIDATE(config->config_table[0]);
 	config->config_table[0].target_table_entry.client_id = 0;
 	config->config_table[0].target_table_entry.vlan_id = 0;
 
-	DP(NETIF_MSG_IFUP, "setting MAC (%04x:%04x:%04x)\n",
+	DP(NETIF_MSG_IFUP, "%s MAC (%04x:%04x:%04x)\n",
+	   (set ? "setting" : "clearing"),
 	   config->config_table[0].cam_entry.msb_mac_addr,
 	   config->config_table[0].cam_entry.middle_mac_addr,
 	   config->config_table[0].cam_entry.lsb_mac_addr);
@@ -6084,8 +6088,11 @@ static void bnx2x_set_mac_addr_e1(struct bnx2x *bp)
 	config->config_table[1].cam_entry.middle_mac_addr = 0xffff;
 	config->config_table[1].cam_entry.lsb_mac_addr = 0xffff;
 	config->config_table[1].cam_entry.flags = cpu_to_le16(port);
-	config->config_table[1].target_table_entry.flags =
+	if (set)
+		config->config_table[1].target_table_entry.flags =
 				TSTORM_CAM_TARGET_TABLE_ENTRY_BROADCAST;
+	else
+		CAM_INVALIDATE(config->config_table[1]);
 	config->config_table[1].target_table_entry.client_id = 0;
 	config->config_table[1].target_table_entry.vlan_id = 0;
 
@@ -6094,12 +6101,12 @@ static void bnx2x_set_mac_addr_e1(struct bnx2x *bp)
 		      U64_LO(bnx2x_sp_mapping(bp, mac_config)), 0);
 }
 
-static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp)
+static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp, int set)
 {
 	struct mac_configuration_cmd_e1h *config =
 		(struct mac_configuration_cmd_e1h *)bnx2x_sp(bp, mac_config);
 
-	if (bp->state != BNX2X_STATE_OPEN) {
+	if (set && (bp->state != BNX2X_STATE_OPEN)) {
 		DP(NETIF_MSG_IFUP, "state is %x, returning\n", bp->state);
 		return;
 	}
@@ -6123,9 +6130,14 @@ static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp)
 	config->config_table[0].client_id = BP_L_ID(bp);
 	config->config_table[0].vlan_id = 0;
 	config->config_table[0].e1hov_id = cpu_to_le16(bp->e1hov);
-	config->config_table[0].flags = BP_PORT(bp);
+	if (set)
+		config->config_table[0].flags = BP_PORT(bp);
+	else
+		config->config_table[0].flags =
+				MAC_CONFIGURATION_ENTRY_E1H_ACTION_TYPE;
 
-	DP(NETIF_MSG_IFUP, "setting MAC (%04x:%04x:%04x)  E1HOV %d  CLID %d\n",
+	DP(NETIF_MSG_IFUP, "%s MAC (%04x:%04x:%04x)  E1HOV %d  CLID %d\n",
+	   (set ? "setting" : "clearing"),
 	   config->config_table[0].msb_mac_addr,
 	   config->config_table[0].middle_mac_addr,
 	   config->config_table[0].lsb_mac_addr, bp->e1hov, BP_L_ID(bp));
@@ -6150,13 +6162,13 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 			bnx2x_rx_int(bp->fp, 10);
 			/* if index is different from 0
 			 * the reply for some commands will
-			 * be on the none default queue
+			 * be on the non default queue
 			 */
 			if (idx)
 				bnx2x_rx_int(&bp->fp[idx], 10);
 		}
-		mb(); /* state is changed by bnx2x_sp_event() */
 
+		mb(); /* state is changed by bnx2x_sp_event() */
 		if (*state_p == state)
 			return 0;
 
@@ -6364,9 +6376,9 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		}
 
 	if (CHIP_IS_E1(bp))
-		bnx2x_set_mac_addr_e1(bp);
+		bnx2x_set_mac_addr_e1(bp, 1);
 	else
-		bnx2x_set_mac_addr_e1h(bp);
+		bnx2x_set_mac_addr_e1h(bp, 1);
 
 	if (bp->port.pmf)
 		bnx2x_initial_phy_init(bp);
@@ -6668,6 +6680,34 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	} else
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
 
+	if (CHIP_IS_E1(bp)) {
+		struct mac_configuration_cmd *config =
+						bnx2x_sp(bp, mcast_config);
+
+		bnx2x_set_mac_addr_e1(bp, 0);
+
+		for (i = 0; i < config->hdr.length_6b; i++)
+			CAM_INVALIDATE(config->config_table[i]);
+
+		config->hdr.length_6b = i;
+		if (CHIP_REV_IS_SLOW(bp))
+			config->hdr.offset = BNX2X_MAX_EMUL_MULTI*(1 + port);
+		else
+			config->hdr.offset = BNX2X_MAX_MULTICAST*(1 + port);
+		config->hdr.client_id = BP_CL_ID(bp);
+		config->hdr.reserved1 = 0;
+
+		bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
+			      U64_HI(bnx2x_sp_mapping(bp, mcast_config)),
+			      U64_LO(bnx2x_sp_mapping(bp, mcast_config)), 0);
+
+	} else { /* E1H */
+		bnx2x_set_mac_addr_e1h(bp, 0);
+
+		for (i = 0; i < MC_HASH_SIZE; i++)
+			REG_WR(bp, MC_HASH_OFFSET(bp, i), 0);
+	}
+
 	if (CHIP_IS_E1H(bp))
 		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 0);
 
@@ -9811,9 +9851,9 @@ static int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	if (netif_running(dev)) {
 		if (CHIP_IS_E1(bp))
-			bnx2x_set_mac_addr_e1(bp);
+			bnx2x_set_mac_addr_e1(bp, 1);
 		else
-			bnx2x_set_mac_addr_e1h(bp);
+			bnx2x_set_mac_addr_e1h(bp, 1);
 	}
 
 	return 0;
-- 
1.5.3.2




