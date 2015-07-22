From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/6] bnx2x: new Multi-function mode - BD
Date: Wed, 22 Jul 2015 09:16:25 +0300
Message-ID: <1437545787-22097-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:25909 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755720AbbGVGRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 02:17:11 -0400
In-Reply-To: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support to a new multi-function mode, enabling driver to
initialize such devices and correctly interacting with management FW
for fully utilizing their features.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |  3 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    | 74 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    | 36 +++++++++++
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  3 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h    | 74 ++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   | 56 ++++++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h    | 17 ++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |  3 +
 8 files changed, 251 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index a59f0b9..ecf1d7f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1424,6 +1424,7 @@ enum {
 	SUB_MF_MODE_UNKNOWN = 0,
 	SUB_MF_MODE_UFP,
 	SUB_MF_MODE_NPAR1_DOT_5,
+	SUB_MF_MODE_BD,
 };
 
 struct bnx2x {
@@ -1638,6 +1639,8 @@ struct bnx2x {
 	u8			mf_sub_mode;
 #define IS_MF_UFP(bp)		(IS_MF_SD(bp) && \
 				 bp->mf_sub_mode == SUB_MF_MODE_UFP)
+#define IS_MF_BD(bp)		(IS_MF_SD(bp) && \
+				 bp->mf_sub_mode == SUB_MF_MODE_BD)
 
 	u8			wol;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index e395ae9..0e392ca 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2517,6 +2517,20 @@ static void bnx2x_bz_fp(struct bnx2x *bp, int index)
 		fp->mode = TPA_MODE_DISABLED;
 }
 
+void bnx2x_set_os_driver_state(struct bnx2x *bp, u32 state)
+{
+	u32 cur;
+
+	if (!IS_MF_BD(bp) || !SHMEM2_HAS(bp, os_driver_state) || IS_VF(bp))
+		return;
+
+	cur = SHMEM2_RD(bp, os_driver_state[BP_FW_MB_IDX(bp)]);
+	DP(NETIF_MSG_IFUP, "Driver state %08x-->%08x\n",
+	   cur, state);
+
+	SHMEM2_WR(bp, os_driver_state[BP_FW_MB_IDX(bp)], state);
+}
+
 int bnx2x_load_cnic(struct bnx2x *bp)
 {
 	int i, rc, port = BP_PORT(bp);
@@ -2880,6 +2894,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		/* mark driver is loaded in shmem2 */
 		u32 val;
 		val = SHMEM2_RD(bp, drv_capabilities_flag[BP_FW_MB_IDX(bp)]);
+		val &= ~DRV_FLAGS_MTU_MASK;
+		val |= (bp->dev->mtu << DRV_FLAGS_MTU_SHIFT);
 		SHMEM2_WR(bp, drv_capabilities_flag[BP_FW_MB_IDX(bp)],
 			  val | DRV_FLAGS_CAPABILITIES_LOADED_SUPPORTED |
 			  DRV_FLAGS_CAPABILITIES_LOADED_L2);
@@ -2896,6 +2912,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	if (bp->port.pmf && (bp->state != BNX2X_STATE_DIAG))
 		bnx2x_dcbx_init(bp, false);
 
+	if (!IS_MF_SD_STORAGE_PERSONALITY_ONLY(bp))
+		bnx2x_set_os_driver_state(bp, OS_DRIVER_STATE_ACTIVE);
+
 	DP(NETIF_MSG_IFUP, "Ending successfully NIC load\n");
 
 	return 0;
@@ -2963,6 +2982,9 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 
 	DP(NETIF_MSG_IFUP, "Starting NIC unload\n");
 
+	if (!IS_MF_SD_STORAGE_PERSONALITY_ONLY(bp))
+		bnx2x_set_os_driver_state(bp, OS_DRIVER_STATE_DISABLED);
+
 	/* mark driver is unloaded in shmem2 */
 	if (IS_PF(bp) && SHMEM2_HAS(bp, drv_capabilities_flag)) {
 		u32 val;
@@ -4191,6 +4213,41 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+void bnx2x_get_c2s_mapping(struct bnx2x *bp, u8 *c2s_map, u8 *c2s_default)
+{
+	int mfw_vn = BP_FW_MB_IDX(bp);
+	u32 tmp;
+
+	/* If the shmem shouldn't affect configuration, reflect */
+	if (!IS_MF_BD(bp)) {
+		int i;
+
+		for (i = 0; i < BNX2X_MAX_PRIORITY; i++)
+			c2s_map[i] = i;
+		*c2s_default = 0;
+
+		return;
+	}
+
+	tmp = SHMEM2_RD(bp, c2s_pcp_map_lower[mfw_vn]);
+	tmp = (__force u32)be32_to_cpu((__force __be32)tmp);
+	c2s_map[0] = tmp & 0xff;
+	c2s_map[1] = (tmp >> 8) & 0xff;
+	c2s_map[2] = (tmp >> 16) & 0xff;
+	c2s_map[3] = (tmp >> 24) & 0xff;
+
+	tmp = SHMEM2_RD(bp, c2s_pcp_map_upper[mfw_vn]);
+	tmp = (__force u32)be32_to_cpu((__force __be32)tmp);
+	c2s_map[4] = tmp & 0xff;
+	c2s_map[5] = (tmp >> 8) & 0xff;
+	c2s_map[6] = (tmp >> 16) & 0xff;
+	c2s_map[7] = (tmp >> 24) & 0xff;
+
+	tmp = SHMEM2_RD(bp, c2s_pcp_map_default[mfw_vn]);
+	tmp = (__force u32)be32_to_cpu((__force __be32)tmp);
+	*c2s_default = (tmp >> (8 * mfw_vn)) & 0xff;
+}
+
 /**
  * bnx2x_setup_tc - routine to configure net_device for multi tc
  *
@@ -4201,8 +4258,9 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
  */
 int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 {
-	int cos, prio, count, offset;
 	struct bnx2x *bp = netdev_priv(dev);
+	u8 c2s_map[BNX2X_MAX_PRIORITY], c2s_def;
+	int cos, prio, count, offset;
 
 	/* setup tc must be called under rtnl lock */
 	ASSERT_RTNL();
@@ -4226,12 +4284,16 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 		return -EINVAL;
 	}
 
+	bnx2x_get_c2s_mapping(bp, c2s_map, &c2s_def);
+
 	/* configure priority to traffic class mapping */
 	for (prio = 0; prio < BNX2X_MAX_PRIORITY; prio++) {
-		netdev_set_prio_tc_map(dev, prio, bp->prio_to_cos[prio]);
+		int outer_prio = c2s_map[prio];
+
+		netdev_set_prio_tc_map(dev, prio, bp->prio_to_cos[outer_prio]);
 		DP(BNX2X_MSG_SP | NETIF_MSG_IFUP,
 		   "mapping priority %d to tc %d\n",
-		   prio, bp->prio_to_cos[prio]);
+		   outer_prio, bp->prio_to_cos[outer_prio]);
 	}
 
 	/* Use this configuration to differentiate tc0 from other COSes
@@ -4285,6 +4347,9 @@ int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 	if (netif_running(dev))
 		rc = bnx2x_set_eth_mac(bp, true);
 
+	if (IS_PF(bp) && SHMEM2_HAS(bp, curr_cfg))
+		SHMEM2_WR(bp, curr_cfg, CURR_CFG_MET_OS);
+
 	return rc;
 }
 
@@ -4838,6 +4903,9 @@ int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 	 */
 	dev->mtu = new_mtu;
 
+	if (IS_PF(bp) && SHMEM2_HAS(bp, curr_cfg))
+		SHMEM2_WR(bp, curr_cfg, CURR_CFG_MET_OS);
+
 	return bnx2x_reload_if_running(dev);
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 77693d3..b1a6ff2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -622,6 +622,14 @@ int bnx2x_set_features(struct net_device *dev, netdev_features_t features);
  */
 void bnx2x_tx_timeout(struct net_device *dev);
 
+/** bnx2x_get_c2s_mapping - read inner-to-outer vlan configuration
+ * c2s_map should have BNX2X_MAX_PRIORITY entries.
+ * @bp:			driver handle
+ * @c2s_map:		should have BNX2X_MAX_PRIORITY entries for mapping
+ * @c2s_default:	entry for non-tagged configuration
+ */
+void bnx2x_get_c2s_mapping(struct bnx2x *bp, u8 *c2s_map, u8 *c2s_default);
+
 /*********************** Inlines **********************************/
 /*********************** Fast path ********************************/
 static inline void bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
@@ -933,6 +941,27 @@ static inline int bnx2x_func_start(struct bnx2x *bp)
 	start_params->mf_mode = bp->mf_mode;
 	start_params->sd_vlan_tag = bp->mf_ov;
 
+	/* Configure Ethertype for BD mode */
+	if (IS_MF_BD(bp)) {
+		DP(NETIF_MSG_IFUP, "Configuring ethertype 0x88a8 for BD\n");
+		start_params->sd_vlan_eth_type = ETH_P_8021AD;
+		REG_WR(bp, PRS_REG_VLAN_TYPE_0, ETH_P_8021AD);
+		REG_WR(bp, PBF_REG_VLAN_TYPE_0, ETH_P_8021AD);
+		REG_WR(bp, NIG_REG_LLH_E1HOV_TYPE_1, ETH_P_8021AD);
+
+		bnx2x_get_c2s_mapping(bp, start_params->c2s_pri,
+				      &start_params->c2s_pri_default);
+		start_params->c2s_pri_valid = 1;
+
+		DP(NETIF_MSG_IFUP,
+		   "Inner-to-Outer priority: %02x %02x %02x %02x %02x %02x %02x %02x [Default %02x]\n",
+		   start_params->c2s_pri[0], start_params->c2s_pri[1],
+		   start_params->c2s_pri[2], start_params->c2s_pri[3],
+		   start_params->c2s_pri[4], start_params->c2s_pri[5],
+		   start_params->c2s_pri[6], start_params->c2s_pri[7],
+		   start_params->c2s_pri_default);
+	}
+
 	if (CHIP_IS_E2(bp) || CHIP_IS_E3(bp))
 		start_params->network_cos_mode = STATIC_COS;
 	else /* CHIP_IS_E1X */
@@ -1339,4 +1368,11 @@ void bnx2x_squeeze_objects(struct bnx2x *bp);
 void bnx2x_schedule_sp_rtnl(struct bnx2x*, enum sp_rtnl_flag,
 			    u32 verbose);
 
+/**
+ * bnx2x_set_os_driver_state - write driver state for management FW usage
+ *
+ * @bp:		driver handle
+ * @state:	OS_DRIVER_STATE_* value reflecting current driver state
+ */
+void bnx2x_set_os_driver_state(struct bnx2x *bp, u32 state);
 #endif /* BNX2X_CMN_H */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 93c78a8..e764ca0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1131,6 +1131,9 @@ static int bnx2x_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	} else
 		bp->wol = 0;
 
+	if (SHMEM2_HAS(bp, curr_cfg))
+		SHMEM2_WR(bp, curr_cfg, CURR_CFG_MET_OS);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 5425de0..23960df 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -868,6 +868,7 @@ struct shared_feat_cfg {		 /* NVRAM Offset */
 		#define SHARED_FEAT_CFG_FORCE_SF_MODE_SPIO4          0x00000200
 		#define SHARED_FEAT_CFG_FORCE_SF_MODE_SWITCH_INDEPT  0x00000300
 		#define SHARED_FEAT_CFG_FORCE_SF_MODE_AFEX_MODE      0x00000400
+		#define SHARED_FEAT_CFG_FORCE_SF_MODE_BD_MODE        0x00000500
 		#define SHARED_FEAT_CFG_FORCE_SF_MODE_UFP_MODE       0x00000600
 		#define SHARED_FEAT_CFG_FORCE_SF_MODE_EXTENDED_MODE  0x00000700
 
@@ -2068,6 +2069,12 @@ struct ncsi_oem_fcoe_features {
 	#define FCOE_FEATURES4_FEATURE_SETTINGS_OFFSET          0
 };
 
+enum curr_cfg_method_e {
+	CURR_CFG_MET_NONE = 0,  /* default config */
+	CURR_CFG_MET_OS = 1,
+	CURR_CFG_MET_VENDOR_SPEC = 2,/* e.g. Option ROM, NPAR, O/S Cfg Utils */
+};
+
 struct ncsi_oem_data {
 	u32 driver_version[4];
 	struct ncsi_oem_fcoe_features ncsi_oem_fcoe_features;
@@ -2191,6 +2198,8 @@ struct shmem2_region {
 #define DRV_FLAGS_CAPABILITIES_LOADED_L2        0x00000002
 #define DRV_FLAGS_CAPABILITIES_LOADED_FCOE      0x00000004
 #define DRV_FLAGS_CAPABILITIES_LOADED_ISCSI     0x00000008
+#define DRV_FLAGS_MTU_MASK			0xffff0000
+#define DRV_FLAGS_MTU_SHIFT			16
 
 	u32 extended_dev_info_shared_cfg_size;
 
@@ -2273,6 +2282,71 @@ struct shmem2_region {
 
 	/* We use indication for each PF (0..3) */
 #define MFW_DRV_IND_READ_DONE_OFFSET(_pf_) (1 << (_pf_))
+	union { /* For various OEMs */			/* Offset 0x1a0 */
+		u8 storage_boot_prog[E2_FUNC_MAX];
+	#define STORAGE_BOOT_PROG_MASK				0x000000FF
+	#define STORAGE_BOOT_PROG_NONE				0x00000000
+	#define STORAGE_BOOT_PROG_ISCSI_IP_ACQUIRED		0x00000002
+	#define STORAGE_BOOT_PROG_FCOE_FABRIC_LOGIN_SUCCESS	0x00000002
+	#define STORAGE_BOOT_PROG_TARGET_FOUND			0x00000004
+	#define STORAGE_BOOT_PROG_ISCSI_CHAP_SUCCESS		0x00000008
+	#define STORAGE_BOOT_PROG_FCOE_LUN_FOUND		0x00000008
+	#define STORAGE_BOOT_PROG_LOGGED_INTO_TGT		0x00000010
+	#define STORAGE_BOOT_PROG_IMG_DOWNLOADED		0x00000020
+	#define STORAGE_BOOT_PROG_OS_HANDOFF			0x00000040
+	#define STORAGE_BOOT_PROG_COMPLETED			0x00000080
+
+		u32 oem_i2c_data_addr;
+	};
+
+	/* 9 entires for the C2S PCP map for each inner VLAN PCP + 1 default */
+	/* For PCP values 0-3 use the map lower */
+	/* 0xFF000000 - PCP 0, 0x00FF0000 - PCP 1,
+	 * 0x0000FF00 - PCP 2, 0x000000FF PCP 3
+	 */
+	u32 c2s_pcp_map_lower[E2_FUNC_MAX];			/* 0x1a4 */
+
+	/* For PCP values 4-7 use the map upper */
+	/* 0xFF000000 - PCP 4, 0x00FF0000 - PCP 5,
+	 * 0x0000FF00 - PCP 6, 0x000000FF PCP 7
+	 */
+	u32 c2s_pcp_map_upper[E2_FUNC_MAX];			/* 0x1b4 */
+
+	/* For PCP default value get the MSB byte of the map default */
+	u32 c2s_pcp_map_default[E2_FUNC_MAX];			/* 0x1c4 */
+
+	/* FC_NPIV table offset in NVRAM */
+	u32 fc_npiv_nvram_tbl_addr[PORT_MAX];			/* 0x1d4 */
+
+	/* Shows last method that changed configuration of this device */
+	enum curr_cfg_method_e curr_cfg;			/* 0x1dc */
+
+	/* Storm FW version, shold be kept in the format 0xMMmmbbdd:
+	 * MM - Major, mm - Minor, bb - Build ,dd - Drop
+	 */
+	u32 netproc_fw_ver;					/* 0x1e0 */
+
+	/* Option ROM SMASH CLP version */
+	u32 clp_ver;						/* 0x1e4 */
+
+	u32 pcie_bus_num;					/* 0x1e8 */
+
+	u32 sriov_switch_mode;					/* 0x1ec */
+	#define SRIOV_SWITCH_MODE_NONE		0x0
+	#define SRIOV_SWITCH_MODE_VEB		0x1
+	#define SRIOV_SWITCH_MODE_VEPA		0x2
+
+	u8  rsrv2[E2_FUNC_MAX];					/* 0x1f0 */
+
+	u32 img_inv_table_addr;	/* Address to INV_TABLE_P */	/* 0x1f4 */
+
+	u32 mtu_size[E2_FUNC_MAX];				/* 0x1f8 */
+
+	u32 os_driver_state[E2_FUNC_MAX];			/* 0x208 */
+	#define OS_DRIVER_STATE_NOT_LOADED	0 /* not installed */
+	#define OS_DRIVER_STATE_LOADING		1 /* transition state */
+	#define OS_DRIVER_STATE_DISABLED	2 /* installed but disabled */
+	#define OS_DRIVER_STATE_ACTIVE		3 /* installed and active */
 };
 
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e85e6ff..0a069fa 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2918,7 +2918,7 @@ static void bnx2x_handle_update_svid_cmd(struct bnx2x *bp)
 	func_params.f_obj = &bp->func_obj;
 	func_params.cmd = BNX2X_F_CMD_SWITCH_UPDATE;
 
-	if (IS_MF_UFP(bp)) {
+	if (IS_MF_UFP(bp) || IS_MF_BD(bp)) {
 		int func = BP_ABS_FUNC(bp);
 		u32 val;
 
@@ -2945,16 +2945,16 @@ static void bnx2x_handle_update_svid_cmd(struct bnx2x *bp)
 			BNX2X_ERR("Failed to configure FW of S-tag Change to %02x\n",
 				  bp->mf_ov);
 			goto fail;
+		} else {
+			DP(BNX2X_MSG_MCP, "Configured S-tag %02x\n",
+			   bp->mf_ov);
 		}
-
-		DP(BNX2X_MSG_MCP, "Configured S-tag %02x\n", bp->mf_ov);
-
-		bnx2x_fw_command(bp, DRV_MSG_CODE_OEM_UPDATE_SVID_OK, 0);
-
-		return;
+	} else {
+		goto fail;
 	}
 
-	/* not supported by SW yet */
+	bnx2x_fw_command(bp, DRV_MSG_CODE_OEM_UPDATE_SVID_OK, 0);
+	return;
 fail:
 	bnx2x_fw_command(bp, DRV_MSG_CODE_OEM_UPDATE_SVID_FAILURE, 0);
 }
@@ -7433,6 +7433,9 @@ static int bnx2x_init_hw_common(struct bnx2x *bp)
 	} else
 		BNX2X_ERR("Bootcode is missing - can not initialize link\n");
 
+	if (SHMEM2_HAS(bp, netproc_fw_ver))
+		SHMEM2_WR(bp, netproc_fw_ver, REG_RD(bp, XSEM_REG_PRAM));
+
 	return 0;
 }
 
@@ -11682,7 +11685,7 @@ static void validate_set_si_mode(struct bnx2x *bp)
 static int bnx2x_get_hwinfo(struct bnx2x *bp)
 {
 	int /*abs*/func = BP_ABS_FUNC(bp);
-	int vn;
+	int vn, mfw_vn;
 	u32 val = 0, val2 = 0;
 	int rc = 0;
 
@@ -11772,6 +11775,7 @@ static int bnx2x_get_hwinfo(struct bnx2x *bp)
 	bp->mf_mode = 0;
 	bp->mf_sub_mode = 0;
 	vn = BP_VN(bp);
+	mfw_vn = BP_FW_MB_IDX(bp);
 
 	if (!CHIP_IS_E1(bp) && !BP_NOMCP(bp)) {
 		BNX2X_DEV_INFO("shmem2base 0x%x, size %d, mfcfg offset %d\n",
@@ -11828,6 +11832,31 @@ static int bnx2x_get_hwinfo(struct bnx2x *bp)
 				} else
 					BNX2X_DEV_INFO("illegal OV for SD\n");
 				break;
+			case SHARED_FEAT_CFG_FORCE_SF_MODE_BD_MODE:
+				bp->mf_mode = MULTI_FUNCTION_SD;
+				bp->mf_sub_mode = SUB_MF_MODE_BD;
+				bp->mf_config[vn] =
+					MF_CFG_RD(bp,
+						  func_mf_config[func].config);
+
+				if (SHMEM2_HAS(bp, mtu_size)) {
+					int mtu_idx = BP_FW_MB_IDX(bp);
+					u16 mtu_size;
+					u32 mtu;
+
+					mtu = SHMEM2_RD(bp, mtu_size[mtu_idx]);
+					mtu_size = (u16)mtu;
+					DP(NETIF_MSG_IFUP, "Read MTU size %04x [%08x]\n",
+					   mtu_size, mtu);
+
+					/* if valid: update device mtu */
+					if (((mtu_size + ETH_HLEN) >=
+					     ETH_MIN_PACKET_SIZE) &&
+					    (mtu_size <=
+					     ETH_MAX_JUMBO_PACKET_SIZE))
+						bp->dev->mtu = mtu_size;
+				}
+				break;
 			case SHARED_FEAT_CFG_FORCE_SF_MODE_UFP_MODE:
 				bp->mf_mode = MULTI_FUNCTION_SD;
 				bp->mf_sub_mode = SUB_MF_MODE_UFP;
@@ -11875,9 +11904,10 @@ static int bnx2x_get_hwinfo(struct bnx2x *bp)
 
 				BNX2X_DEV_INFO("MF OV for func %d is %d (0x%04x)\n",
 					       func, bp->mf_ov, bp->mf_ov);
-			} else if (bp->mf_sub_mode == SUB_MF_MODE_UFP) {
+			} else if ((bp->mf_sub_mode == SUB_MF_MODE_UFP) ||
+				   (bp->mf_sub_mode == SUB_MF_MODE_BD)) {
 				dev_err(&bp->pdev->dev,
-					"Unexpected - no valid MF OV for func %d in UFP mode\n",
+					"Unexpected - no valid MF OV for func %d in UFP/BD mode\n",
 					func);
 				bp->path_has_ovlan = true;
 			} else {
@@ -13565,6 +13595,9 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 
 	bnx2x_register_phc(bp);
 
+	if (!IS_MF_SD_STORAGE_PERSONALITY_ONLY(bp))
+		bnx2x_set_os_driver_state(bp, OS_DRIVER_STATE_DISABLED);
+
 	return 0;
 
 init_one_exit:
@@ -13627,6 +13660,7 @@ static void __bnx2x_remove(struct pci_dev *pdev,
 	/* Power on: we can't let PCI layer write to us while we are in D3 */
 	if (IS_PF(bp)) {
 		bnx2x_set_power_state(bp, PCI_D0);
+		bnx2x_set_os_driver_state(bp, OS_DRIVER_STATE_NOT_LOADED);
 
 		/* Set endianity registers to reset values in case next driver
 		 * boots in different endianty environment.
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index f18bf51..4dead49 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -2139,6 +2139,10 @@
 /* [RW 1] When this bit is set; the LLH will expect all packets to be with
    e1hov */
 #define NIG_REG_LLH_E1HOV_MODE					 0x160d8
+/* [RW 16] Outer VLAN type identifier for multi-function mode. In non
+ * multi-function mode; it will hold the inner VLAN type. Typically 0x8100.
+ */
+#define NIG_REG_LLH_E1HOV_TYPE_1				 0x16028
 /* [RW 1] When this bit is set; the LLH will classify the packet before
    sending it to the BRB or calculating WoL on it. */
 #define NIG_REG_LLH_MF_MODE					 0x16024
@@ -2955,7 +2959,12 @@
 #define PBF_REG_TQ_OCCUPANCY_Q0					 0x1403ac
 /* [R 13] Number of 8 bytes lines occupied in the task queue of queue 1. */
 #define PBF_REG_TQ_OCCUPANCY_Q1					 0x1403b0
-#define PB_REG_CONTROL						 0
+/* [RW 16] One of 8 values that should be compared to type in Ethernet
+ * parsing. If there is a match; the field after Ethernet is the first VLAN.
+ * Reset value is 0x8100 which is the standard VLAN type. Note that when
+ * checking second VLAN; type is compared only to 0x8100.
+ */
+#define PBF_REG_VLAN_TYPE_0					 0x15c06c
 /* [RW 2] Interrupt mask register #0 read/write */
 #define PB_REG_PB_INT_MASK					 0x28
 /* [R 2] Interrupt register #0 read */
@@ -3374,6 +3383,12 @@
 #define PRS_REG_TCM_CURRENT_CREDIT				 0x40160
 /* [R 8] debug only: TSDM current credit. Transaction based. */
 #define PRS_REG_TSDM_CURRENT_CREDIT				 0x4015c
+/* [RW 16] One of 8 values that should be compared to type in Ethernet
+ * parsing. If there is a match; the field after Ethernet is the first VLAN.
+ * Reset value is 0x8100 which is the standard VLAN type. Note that when
+ * checking second VLAN; type is compared only to 0x8100.
+ */
+#define PRS_REG_VLAN_TYPE_0					 0x401a8
 #define PXP2_PXP2_INT_MASK_0_REG_PGL_CPL_AFT			 (0x1<<19)
 #define PXP2_PXP2_INT_MASK_0_REG_PGL_CPL_OF			 (0x1<<20)
 #define PXP2_PXP2_INT_MASK_0_REG_PGL_PCIE_ATTN			 (0x1<<22)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 4d5c7b3..5b243bc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1340,6 +1340,9 @@ int bnx2x_iov_init_one(struct bnx2x *bp, int int_mode_param,
 
 	mutex_init(&bp->vfdb->bulletin_mutex);
 
+	if (SHMEM2_HAS(bp, sriov_switch_mode))
+		SHMEM2_WR(bp, sriov_switch_mode, SRIOV_SWITCH_MODE_VEB);
+
 	return 0;
 failed:
 	DP(BNX2X_MSG_IOV, "Failed err=%d\n", err);
-- 
1.9.3
