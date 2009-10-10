From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/7] bnx2x: Refactor MAC address setup code.
Date: Sat, 10 Oct 2009 16:46:54 -0700
Message-ID: <1255218419-17320-2-git-send-email-mchan@broadcom.com>
References: <1255218419-17320-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michaelc@cs.wisc.edu,
	shmulikr@broadcom.com, eilong@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1958 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755547AbZJJXjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2009 19:39:07 -0400
In-Reply-To: <1255218419-17320-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For iSCSI MAC address setup in later patches.

Signed-off-by: Shmulik Ravid - Rabinovitz <shmulikr@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    4 +-
 drivers/net/bnx2x_main.c |  162 ++++++++++++++++++++++++++++++++--------------
 2 files changed, 114 insertions(+), 52 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index bbf8422..1f07063 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -863,8 +863,8 @@ struct bnx2x {
 
 	/* Flags for marking that there is a STAT_QUERY or
 	   SET_MAC ramrod pending */
-	u8			stats_pending;
-	u8			set_mac_pending;
+	int			stats_pending;
+	int			set_mac_pending;
 
 	/* End of fields used in the performance code paths */
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 713d669..02ce3b3 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1026,12 +1026,15 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_OPEN):
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_DIAG):
 		DP(NETIF_MSG_IFUP, "got set mac ramrod\n");
-		bp->set_mac_pending = 0;
+		bp->set_mac_pending--;
+		smp_wmb();
 		break;
 
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_CLOSING_WAIT4_HALT):
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_DISABLED):
 		DP(NETIF_MSG_IFDOWN, "got (un)set mac ramrod\n");
+		bp->set_mac_pending--;
+		smp_wmb();
 		break;
 
 	default:
@@ -2530,7 +2533,7 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 }
 
 static void bnx2x_set_storm_rx_mode(struct bnx2x *bp);
-static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp, int set);
+static void bnx2x_set_eth_mac_addr_e1h(struct bnx2x *bp, int set);
 static void bnx2x_set_rx_mode(struct net_device *dev);
 
 static void bnx2x_e1h_disable(struct bnx2x *bp)
@@ -2546,7 +2549,7 @@ static void bnx2x_e1h_disable(struct bnx2x *bp)
 
 	REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 0);
 
-	bnx2x_set_mac_addr_e1h(bp, 0);
+	bnx2x_set_eth_mac_addr_e1h(bp, 0);
 
 	for (i = 0; i < MC_HASH_SIZE; i++)
 		REG_WR(bp, MC_HASH_OFFSET(bp, i), 0);
@@ -2560,7 +2563,7 @@ static void bnx2x_e1h_enable(struct bnx2x *bp)
 
 	REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 1);
 
-	bnx2x_set_mac_addr_e1h(bp, 1);
+	bnx2x_set_eth_mac_addr_e1h(bp, 1);
 
 	/* Tx queue should be only reenabled */
 	netif_tx_wake_all_queues(bp->dev);
@@ -7036,7 +7039,19 @@ static void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
  * Init service functions
  */
 
-static void bnx2x_set_mac_addr_e1(struct bnx2x *bp, int set)
+/**
+ * Sets a MAC in a CAM for a few L2 Clients for E1 chip
+ *
+ * @param bp driver descriptor
+ * @param set set or clear an entry (1 or 0)
+ * @param mac pointer to a buffer containing a MAC
+ * @param cl_bit_vec bit vector of clients to register a MAC for
+ * @param cam_offset offset in a CAM to use
+ * @param with_bcast set broadcast MAC as well
+ */
+static void bnx2x_set_mac_addr_e1_gen(struct bnx2x *bp, int set, u8 *mac,
+				      u32 cl_bit_vec, u8 cam_offset,
+				      u8 with_bcast)
 {
 	struct mac_configuration_cmd *config = bnx2x_sp(bp, mac_config);
 	int port = BP_PORT(bp);
@@ -7045,25 +7060,25 @@ static void bnx2x_set_mac_addr_e1(struct bnx2x *bp, int set)
 	 * unicasts 0-31:port0 32-63:port1
 	 * multicast 64-127:port0 128-191:port1
 	 */
-	config->hdr.length = 2;
-	config->hdr.offset = port ? 32 : 0;
-	config->hdr.client_id = bp->fp->cl_id;
+	config->hdr.length = 1 + (with_bcast ? 1 : 0);
+	config->hdr.offset = cam_offset;
+	config->hdr.client_id = 0xff;
 	config->hdr.reserved1 = 0;
 
 	/* primary MAC */
 	config->config_table[0].cam_entry.msb_mac_addr =
-					swab16(*(u16 *)&bp->dev->dev_addr[0]);
+					swab16(*(u16 *)&mac[0]);
 	config->config_table[0].cam_entry.middle_mac_addr =
-					swab16(*(u16 *)&bp->dev->dev_addr[2]);
+					swab16(*(u16 *)&mac[2]);
 	config->config_table[0].cam_entry.lsb_mac_addr =
-					swab16(*(u16 *)&bp->dev->dev_addr[4]);
+					swab16(*(u16 *)&mac[4]);
 	config->config_table[0].cam_entry.flags = cpu_to_le16(port);
 	if (set)
 		config->config_table[0].target_table_entry.flags = 0;
 	else
 		CAM_INVALIDATE(config->config_table[0]);
 	config->config_table[0].target_table_entry.clients_bit_vector =
-						cpu_to_le32(1 << BP_L_ID(bp));
+						cpu_to_le32(cl_bit_vec);
 	config->config_table[0].target_table_entry.vlan_id = 0;
 
 	DP(NETIF_MSG_IFUP, "%s MAC (%04x:%04x:%04x)\n",
@@ -7073,47 +7088,58 @@ static void bnx2x_set_mac_addr_e1(struct bnx2x *bp, int set)
 	   config->config_table[0].cam_entry.lsb_mac_addr);
 
 	/* broadcast */
-	config->config_table[1].cam_entry.msb_mac_addr = cpu_to_le16(0xffff);
-	config->config_table[1].cam_entry.middle_mac_addr = cpu_to_le16(0xffff);
-	config->config_table[1].cam_entry.lsb_mac_addr = cpu_to_le16(0xffff);
-	config->config_table[1].cam_entry.flags = cpu_to_le16(port);
-	if (set)
-		config->config_table[1].target_table_entry.flags =
-				TSTORM_CAM_TARGET_TABLE_ENTRY_BROADCAST;
-	else
-		CAM_INVALIDATE(config->config_table[1]);
-	config->config_table[1].target_table_entry.clients_bit_vector =
-						cpu_to_le32(1 << BP_L_ID(bp));
-	config->config_table[1].target_table_entry.vlan_id = 0;
+	if (with_bcast) {
+		config->config_table[1].cam_entry.msb_mac_addr =
+			cpu_to_le16(0xffff);
+		config->config_table[1].cam_entry.middle_mac_addr =
+			cpu_to_le16(0xffff);
+		config->config_table[1].cam_entry.lsb_mac_addr =
+			cpu_to_le16(0xffff);
+		config->config_table[1].cam_entry.flags = cpu_to_le16(port);
+		if (set)
+			config->config_table[1].target_table_entry.flags =
+					TSTORM_CAM_TARGET_TABLE_ENTRY_BROADCAST;
+		else
+			CAM_INVALIDATE(config->config_table[1]);
+		config->config_table[1].target_table_entry.clients_bit_vector =
+							cpu_to_le32(cl_bit_vec);
+		config->config_table[1].target_table_entry.vlan_id = 0;
+	}
 
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
 		      U64_HI(bnx2x_sp_mapping(bp, mac_config)),
 		      U64_LO(bnx2x_sp_mapping(bp, mac_config)), 0);
 }
 
-static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp, int set)
+/**
+ * Sets a MAC in a CAM for a few L2 Clients for E1H chip
+ *
+ * @param bp driver descriptor
+ * @param set set or clear an entry (1 or 0)
+ * @param mac pointer to a buffer containing a MAC
+ * @param cl_bit_vec bit vector of clients to register a MAC for
+ * @param cam_offset offset in a CAM to use
+ */
+static void bnx2x_set_mac_addr_e1h_gen(struct bnx2x *bp, int set, u8 *mac,
+				       u32 cl_bit_vec, u8 cam_offset)
 {
 	struct mac_configuration_cmd_e1h *config =
 		(struct mac_configuration_cmd_e1h *)bnx2x_sp(bp, mac_config);
 
-	/* CAM allocation for E1H
-	 * unicasts: by func number
-	 * multicast: 20+FUNC*20, 20 each
-	 */
 	config->hdr.length = 1;
-	config->hdr.offset = BP_FUNC(bp);
-	config->hdr.client_id = bp->fp->cl_id;
+	config->hdr.offset = cam_offset;
+	config->hdr.client_id = 0xff;
 	config->hdr.reserved1 = 0;
 
 	/* primary MAC */
 	config->config_table[0].msb_mac_addr =
-					swab16(*(u16 *)&bp->dev->dev_addr[0]);
+					swab16(*(u16 *)&mac[0]);
 	config->config_table[0].middle_mac_addr =
-					swab16(*(u16 *)&bp->dev->dev_addr[2]);
+					swab16(*(u16 *)&mac[2]);
 	config->config_table[0].lsb_mac_addr =
-					swab16(*(u16 *)&bp->dev->dev_addr[4]);
+					swab16(*(u16 *)&mac[4]);
 	config->config_table[0].clients_bit_vector =
-					cpu_to_le32(1 << BP_L_ID(bp));
+					cpu_to_le32(cl_bit_vec);
 	config->config_table[0].vlan_id = 0;
 	config->config_table[0].e1hov_id = cpu_to_le16(bp->e1hov);
 	if (set)
@@ -7122,11 +7148,11 @@ static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp, int set)
 		config->config_table[0].flags =
 				MAC_CONFIGURATION_ENTRY_E1H_ACTION_TYPE;
 
-	DP(NETIF_MSG_IFUP, "%s MAC (%04x:%04x:%04x)  E1HOV %d  CLID %d\n",
+	DP(NETIF_MSG_IFUP, "%s MAC (%04x:%04x:%04x)  E1HOV %d  CLID mask %d\n",
 	   (set ? "setting" : "clearing"),
 	   config->config_table[0].msb_mac_addr,
 	   config->config_table[0].middle_mac_addr,
-	   config->config_table[0].lsb_mac_addr, bp->e1hov, BP_L_ID(bp));
+	   config->config_table[0].lsb_mac_addr, bp->e1hov, cl_bit_vec);
 
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
 		      U64_HI(bnx2x_sp_mapping(bp, mac_config)),
@@ -7178,6 +7204,31 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 	return -EBUSY;
 }
 
+static void bnx2x_set_eth_mac_addr_e1h(struct bnx2x *bp, int set)
+{
+	bp->set_mac_pending++;
+	smp_wmb();
+
+	bnx2x_set_mac_addr_e1h_gen(bp, set, bp->dev->dev_addr,
+				   (1 << bp->fp->cl_id), BP_FUNC(bp));
+
+	/* Wait for a completion */
+	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending, set ? 0 : 1);
+}
+
+static void bnx2x_set_eth_mac_addr_e1(struct bnx2x *bp, int set)
+{
+	bp->set_mac_pending++;
+	smp_wmb();
+
+	bnx2x_set_mac_addr_e1_gen(bp, set, bp->dev->dev_addr,
+				  (1 << bp->fp->cl_id), (BP_PORT(bp) ? 32 : 0),
+				  1);
+
+	/* Wait for a completion */
+	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending, set ? 0 : 1);
+}
+
 static int bnx2x_setup_leading(struct bnx2x *bp)
 {
 	int rc;
@@ -7452,9 +7503,9 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		}
 
 		if (CHIP_IS_E1(bp))
-			bnx2x_set_mac_addr_e1(bp, 1);
+			bnx2x_set_eth_mac_addr_e1(bp, 1);
 		else
-			bnx2x_set_mac_addr_e1h(bp, 1);
+			bnx2x_set_eth_mac_addr_e1h(bp, 1);
 	}
 
 	if (bp->port.pmf)
@@ -7717,7 +7768,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		struct mac_configuration_cmd *config =
 						bnx2x_sp(bp, mcast_config);
 
-		bnx2x_set_mac_addr_e1(bp, 0);
+		bnx2x_set_eth_mac_addr_e1(bp, 0);
 
 		for (i = 0; i < config->hdr.length; i++)
 			CAM_INVALIDATE(config->config_table[i]);
@@ -7730,6 +7781,9 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		config->hdr.client_id = bp->fp->cl_id;
 		config->hdr.reserved1 = 0;
 
+		bp->set_mac_pending++;
+		smp_wmb();
+
 		bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
 			      U64_HI(bnx2x_sp_mapping(bp, mcast_config)),
 			      U64_LO(bnx2x_sp_mapping(bp, mcast_config)), 0);
@@ -7737,7 +7791,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	} else { /* E1H */
 		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 0);
 
-		bnx2x_set_mac_addr_e1h(bp, 0);
+		bnx2x_set_eth_mac_addr_e1h(bp, 0);
 
 		for (i = 0; i < MC_HASH_SIZE; i++)
 			REG_WR(bp, MC_HASH_OFFSET(bp, i), 0);
@@ -8520,6 +8574,14 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 		       bp->link_params.req_flow_ctrl, bp->port.advertising);
 }
 
+static void __devinit bnx2x_set_mac_buf(u8 *mac_buf, u32 mac_lo, u16 mac_hi)
+{
+	mac_hi = cpu_to_be16(mac_hi);
+	mac_lo = cpu_to_be32(mac_lo);
+	memcpy(mac_buf, &mac_hi, sizeof(mac_hi));
+	memcpy(mac_buf + sizeof(mac_hi), &mac_lo, sizeof(mac_lo));
+}
+
 static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
@@ -8601,12 +8663,7 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 
 	val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_upper);
 	val = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_lower);
-	bp->dev->dev_addr[0] = (u8)(val2 >> 8 & 0xff);
-	bp->dev->dev_addr[1] = (u8)(val2 & 0xff);
-	bp->dev->dev_addr[2] = (u8)(val >> 24 & 0xff);
-	bp->dev->dev_addr[3] = (u8)(val >> 16 & 0xff);
-	bp->dev->dev_addr[4] = (u8)(val >> 8  & 0xff);
-	bp->dev->dev_addr[5] = (u8)(val & 0xff);
+	bnx2x_set_mac_buf(bp->dev->dev_addr, val, val2);
 	memcpy(bp->link_params.mac_addr, bp->dev->dev_addr, ETH_ALEN);
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
 }
@@ -10232,14 +10289,16 @@ static int bnx2x_test_intr(struct bnx2x *bp)
 	config->hdr.client_id = bp->fp->cl_id;
 	config->hdr.reserved1 = 0;
 
+	bp->set_mac_pending++;
+	smp_wmb();
 	rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
 			   U64_HI(bnx2x_sp_mapping(bp, mac_config)),
 			   U64_LO(bnx2x_sp_mapping(bp, mac_config)), 0);
 	if (rc == 0) {
-		bp->set_mac_pending++;
 		for (i = 0; i < 10; i++) {
 			if (!bp->set_mac_pending)
 				break;
+			smp_rmb();
 			msleep_interruptible(10);
 		}
 		if (i == 10)
@@ -11337,6 +11396,9 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 			config->hdr.client_id = bp->fp->cl_id;
 			config->hdr.reserved1 = 0;
 
+			bp->set_mac_pending++;
+			smp_wmb();
+
 			bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
 				   U64_HI(bnx2x_sp_mapping(bp, mcast_config)),
 				   U64_LO(bnx2x_sp_mapping(bp, mcast_config)),
@@ -11386,9 +11448,9 @@ static int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	if (netif_running(dev)) {
 		if (CHIP_IS_E1(bp))
-			bnx2x_set_mac_addr_e1(bp, 1);
+			bnx2x_set_eth_mac_addr_e1(bp, 1);
 		else
-			bnx2x_set_mac_addr_e1h(bp, 1);
+			bnx2x_set_eth_mac_addr_e1h(bp, 1);
 	}
 
 	return 0;
-- 
1.6.4.GIT


