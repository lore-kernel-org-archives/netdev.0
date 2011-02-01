From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next-2.6] bnx2x, cnic: Consolidate iSCSI/FCoE shared
 mem logic in bnx2x
Date: Mon, 31 Jan 2011 16:39:17 -0800
Message-ID: <1296520757-5387-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3201 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754272Ab1BABdX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 20:33:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>

Move all shared mem code to bnx2x to avoid code duplication.  bnx2x now
performs:

- Read the FCoE and iSCSI max connection information.
- Read the iSCSI and FCoE MACs from NPAR configuration in shmem.
- Block the CNIC for the current function if there is neither FCoE nor
  iSCSI valid configuration by returning NULL from bnx2x_cnic_probe().

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.h             |    2 +
 drivers/net/bnx2x/bnx2x.h      |    5 +-
 drivers/net/bnx2x/bnx2x_hsi.h  |   25 +++++---
 drivers/net/bnx2x/bnx2x_main.c |  112 ++++++++++++++++++++++++++++----
 drivers/net/cnic.c             |  143 +++++-----------------------------------
 drivers/net/cnic_if.h          |    8 ++-
 6 files changed, 146 insertions(+), 149 deletions(-)

diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 0132ea9..7a5e88f 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6207,6 +6207,8 @@ struct l2_fhdr {
 
 #define BNX2_CP_SCRATCH					0x001a0000
 
+#define BNX2_FW_MAX_ISCSI_CONN				 0x001a0080
+
 
 /*
  *  mcp_reg definition
diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 04fb72b..ff87ec3 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -976,8 +976,12 @@ struct bnx2x {
 #define MF_FUNC_DIS			0x1000
 #define FCOE_MACS_SET			0x2000
 #define NO_FCOE_FLAG			0x4000
+#define NO_ISCSI_OOO_FLAG		0x8000
+#define NO_ISCSI_FLAG			0x10000
 
 #define NO_FCOE(bp)		((bp)->flags & NO_FCOE_FLAG)
+#define NO_ISCSI(bp)		((bp)->flags & NO_ISCSI_FLAG)
+#define NO_ISCSI_OOO(bp)	((bp)->flags & NO_ISCSI_OOO_FLAG)
 
 	int			pf_num;	/* absolute PF number */
 	int			pfid;	/* per-path PF number */
@@ -1125,7 +1129,6 @@ struct bnx2x {
 	u16			cnic_kwq_pending;
 	u16			cnic_spq_pending;
 	struct mutex		cnic_mutex;
-	u8			iscsi_mac[ETH_ALEN];
 	u8			fip_mac[ETH_ALEN];
 #endif
 
diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index 51d69db..be503cc 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -11,20 +11,27 @@
 
 #include "bnx2x_fw_defs.h"
 
+#define FW_ENCODE_32BIT_PATTERN		0x1e1e1e1e
+
 struct license_key {
 	u32 reserved[6];
 
-#if defined(__BIG_ENDIAN)
-	u16 max_iscsi_init_conn;
-	u16 max_iscsi_trgt_conn;
-#elif defined(__LITTLE_ENDIAN)
-	u16 max_iscsi_trgt_conn;
-	u16 max_iscsi_init_conn;
-#endif
+	u32 max_iscsi_conn;
+#define BNX2X_MAX_ISCSI_TRGT_CONN_MASK	0xFFFF
+#define BNX2X_MAX_ISCSI_TRGT_CONN_SHIFT	0
+#define BNX2X_MAX_ISCSI_INIT_CONN_MASK	0xFFFF0000
+#define BNX2X_MAX_ISCSI_INIT_CONN_SHIFT	16
 
-	u32 reserved_a[6];
-};
+	u32 reserved_a;
+
+	u32 max_fcoe_conn;
+#define BNX2X_MAX_FCOE_TRGT_CONN_MASK	0xFFFF
+#define BNX2X_MAX_FCOE_TRGT_CONN_SHIFT	0
+#define BNX2X_MAX_FCOE_INIT_CONN_MASK	0xFFFF0000
+#define BNX2X_MAX_FCOE_INIT_CONN_SHIFT	16
 
+	u32 reserved_b[4];
+};
 
 #define PORT_0				0
 #define PORT_1				1
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 2215a39..ae8d20a 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -6456,12 +6456,13 @@ static int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
 	u32 iscsi_l2_cl_id = BNX2X_ISCSI_ETH_CL_ID +
 		BP_E1HVN(bp) * NONE_ETH_CONTEXT_USE;
 	u32 cl_bit_vec = (1 << iscsi_l2_cl_id);
+	u8 *iscsi_mac = bp->cnic_eth_dev.iscsi_mac;
 
 	/* Send a SET_MAC ramrod */
-	bnx2x_set_mac_addr_gen(bp, set, bp->iscsi_mac, cl_bit_vec,
+	bnx2x_set_mac_addr_gen(bp, set, iscsi_mac, cl_bit_vec,
 			       cam_offset, 0);
 
-	bnx2x_set_mac_in_nig(bp, set, bp->iscsi_mac, LLH_CAM_ISCSI_ETH_LINE);
+	bnx2x_set_mac_in_nig(bp, set, iscsi_mac, LLH_CAM_ISCSI_ETH_LINE);
 
 	return 0;
 }
@@ -8385,11 +8386,47 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 							bp->common.shmem2_base);
 }
 
+#ifdef BCM_CNIC
+static void __devinit bnx2x_get_cnic_info(struct bnx2x *bp)
+{
+	u32 max_iscsi_conn = FW_ENCODE_32BIT_PATTERN ^ SHMEM_RD(bp,
+				drv_lic_key[BP_PORT(bp)].max_iscsi_conn);
+	u32 max_fcoe_conn = FW_ENCODE_32BIT_PATTERN ^ SHMEM_RD(bp,
+				drv_lic_key[BP_PORT(bp)].max_fcoe_conn);
+
+	/* Get the number of maximum allowed iSCSI and FCoE connections */
+	bp->cnic_eth_dev.max_iscsi_conn =
+		(max_iscsi_conn & BNX2X_MAX_ISCSI_INIT_CONN_MASK) >>
+		BNX2X_MAX_ISCSI_INIT_CONN_SHIFT;
+
+	bp->cnic_eth_dev.max_fcoe_conn =
+		(max_fcoe_conn & BNX2X_MAX_FCOE_INIT_CONN_MASK) >>
+		BNX2X_MAX_FCOE_INIT_CONN_SHIFT;
+
+	BNX2X_DEV_INFO("max_iscsi_conn 0x%x max_fcoe_conn 0x%x\n",
+		       bp->cnic_eth_dev.max_iscsi_conn,
+		       bp->cnic_eth_dev.max_fcoe_conn);
+
+	/* If mamimum allowed number of connections is zero -
+	 * disable the feature.
+	 */
+	if (!bp->cnic_eth_dev.max_iscsi_conn)
+		bp->flags |= NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG;
+
+	if (!bp->cnic_eth_dev.max_fcoe_conn)
+		bp->flags |= NO_FCOE_FLAG;
+}
+#endif
+
 static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 {
 	u32 val, val2;
 	int func = BP_ABS_FUNC(bp);
 	int port = BP_PORT(bp);
+#ifdef BCM_CNIC
+	u8 *iscsi_mac = bp->cnic_eth_dev.iscsi_mac;
+	u8 *fip_mac = bp->fip_mac;
+#endif
 
 	if (BP_NOMCP(bp)) {
 		BNX2X_ERROR("warning: random MAC workaround active\n");
@@ -8402,7 +8439,9 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 			bnx2x_set_mac_buf(bp->dev->dev_addr, val, val2);
 
 #ifdef BCM_CNIC
-		/* iSCSI NPAR MAC */
+		/* iSCSI and FCoE NPAR MACs: if there is no either iSCSI or
+		 * FCoE MAC then the appropriate feature should be disabled.
+		 */
 		if (IS_MF_SI(bp)) {
 			u32 cfg = MF_CFG_RD(bp, func_ext_config[func].func_cfg);
 			if (cfg & MACP_FUNC_CFG_FLAGS_ISCSI_OFFLOAD) {
@@ -8410,8 +8449,39 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 						     iscsi_mac_addr_upper);
 				val = MF_CFG_RD(bp, func_ext_config[func].
 						    iscsi_mac_addr_lower);
-				bnx2x_set_mac_buf(bp->iscsi_mac, val, val2);
-			}
+				BNX2X_DEV_INFO("Read iSCSI MAC: "
+					       "0x%x:0x%04x\n", val2, val);
+				bnx2x_set_mac_buf(iscsi_mac, val, val2);
+
+				/* Disable iSCSI OOO if MAC configuration is
+				 * invalid.
+				 */
+				if (!is_valid_ether_addr(iscsi_mac)) {
+					bp->flags |= NO_ISCSI_OOO_FLAG |
+						     NO_ISCSI_FLAG;
+					memset(iscsi_mac, 0, ETH_ALEN);
+				}
+			} else
+				bp->flags |= NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG;
+
+			if (cfg & MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD) {
+				val2 = MF_CFG_RD(bp, func_ext_config[func].
+						     fcoe_mac_addr_upper);
+				val = MF_CFG_RD(bp, func_ext_config[func].
+						    fcoe_mac_addr_lower);
+				BNX2X_DEV_INFO("Read FCoE MAC to "
+					       "0x%x:0x%04x\n", val2, val);
+				bnx2x_set_mac_buf(fip_mac, val, val2);
+
+				/* Disable FCoE if MAC configuration is
+				 * invalid.
+				 */
+				if (!is_valid_ether_addr(fip_mac)) {
+					bp->flags |= NO_FCOE_FLAG;
+					memset(bp->fip_mac, 0, ETH_ALEN);
+				}
+			} else
+				bp->flags |= NO_FCOE_FLAG;
 		}
 #endif
 	} else {
@@ -8425,7 +8495,7 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 				    iscsi_mac_upper);
 		val = SHMEM_RD(bp, dev_info.port_hw_config[port].
 				   iscsi_mac_lower);
-		bnx2x_set_mac_buf(bp->iscsi_mac, val, val2);
+		bnx2x_set_mac_buf(iscsi_mac, val, val2);
 #endif
 	}
 
@@ -8433,14 +8503,12 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
 
 #ifdef BCM_CNIC
-	/* Inform the upper layers about FCoE MAC */
+	/* Set the FCoE MAC in modes other then MF_SI */
 	if (!CHIP_IS_E1x(bp)) {
 		if (IS_MF_SD(bp))
-			memcpy(bp->fip_mac, bp->dev->dev_addr,
-			       sizeof(bp->fip_mac));
-		else
-			memcpy(bp->fip_mac, bp->iscsi_mac,
-			       sizeof(bp->fip_mac));
+			memcpy(fip_mac, bp->dev->dev_addr, ETH_ALEN);
+		else if (!IS_MF(bp))
+			memcpy(fip_mac, iscsi_mac, ETH_ALEN);
 	}
 #endif
 }
@@ -8603,6 +8671,10 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 	/* Get MAC addresses */
 	bnx2x_get_mac_hwinfo(bp);
 
+#ifdef BCM_CNIC
+	bnx2x_get_cnic_info(bp);
+#endif
+
 	return rc;
 }
 
@@ -10077,6 +10149,13 @@ struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
 	struct bnx2x *bp = netdev_priv(dev);
 	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
 
+	/* If both iSCSI and FCoE are disabled - return NULL in
+	 * order to indicate CNIC that it should not try to work
+	 * with this device.
+	 */
+	if (NO_ISCSI(bp) && NO_FCOE(bp))
+		return NULL;
+
 	cp->drv_owner = THIS_MODULE;
 	cp->chip_id = CHIP_ID(bp);
 	cp->pdev = bp->pdev;
@@ -10097,6 +10176,15 @@ struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
 		BP_E1HVN(bp) * NONE_ETH_CONTEXT_USE;
 	cp->iscsi_l2_cid = BNX2X_ISCSI_ETH_CID;
 
+	if (NO_ISCSI_OOO(bp))
+		cp->drv_state |= CNIC_DRV_STATE_NO_ISCSI_OOO;
+
+	if (NO_ISCSI(bp))
+		cp->drv_state |= CNIC_DRV_STATE_NO_ISCSI;
+
+	if (NO_FCOE(bp))
+		cp->drv_state |= CNIC_DRV_STATE_NO_FCOE;
+
 	DP(BNX2X_MSG_SP, "page_size %d, tbl_offset %d, tbl_lines %d, "
 			 "starting cid %d\n",
 	   cp->ctx_blk_size,
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index c820496..2d2d28f 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -4179,6 +4179,14 @@ static void cnic_enable_bnx2_int(struct cnic_dev *dev)
 		BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID | cp->last_status_idx);
 }
 
+static void cnic_get_bnx2_iscsi_info(struct cnic_dev *dev)
+{
+	u32 max_conn;
+
+	max_conn = cnic_reg_rd_ind(dev, BNX2_FW_MAX_ISCSI_CONN);
+	dev->max_iscsi_conn = max_conn;
+}
+
 static void cnic_disable_bnx2_int_sync(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -4503,6 +4511,8 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 		return err;
 	}
 
+	cnic_get_bnx2_iscsi_info(dev);
+
 	return 0;
 }
 
@@ -4714,129 +4724,6 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 	cp->rx_cons = *cp->rx_cons_ptr;
 }
 
-static int cnic_read_bnx2x_iscsi_mac(struct cnic_dev *dev, u32 upper_addr,
-				     u32 lower_addr)
-{
-	u32 val;
-	u8 mac[6];
-
-	val = CNIC_RD(dev, upper_addr);
-
-	mac[0] = (u8) (val >> 8);
-	mac[1] = (u8) val;
-
-	val = CNIC_RD(dev, lower_addr);
-
-	mac[2] = (u8) (val >> 24);
-	mac[3] = (u8) (val >> 16);
-	mac[4] = (u8) (val >> 8);
-	mac[5] = (u8) val;
-
-	if (is_valid_ether_addr(mac)) {
-		memcpy(dev->mac_addr, mac, 6);
-		return 0;
-	} else {
-		return -EINVAL;
-	}
-}
-
-static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
-{
-	struct cnic_local *cp = dev->cnic_priv;
-	u32 base, base2, addr, addr1, val;
-	int port = CNIC_PORT(cp);
-
-	dev->max_iscsi_conn = 0;
-	base = CNIC_RD(dev, MISC_REG_SHARED_MEM_ADDR);
-	if (base == 0)
-		return;
-
-	base2 = CNIC_RD(dev, (CNIC_PATH(cp) ? MISC_REG_GENERIC_CR_1 :
-					      MISC_REG_GENERIC_CR_0));
-	addr = BNX2X_SHMEM_ADDR(base,
-		dev_info.port_hw_config[port].iscsi_mac_upper);
-
-	addr1 = BNX2X_SHMEM_ADDR(base,
-		dev_info.port_hw_config[port].iscsi_mac_lower);
-
-	cnic_read_bnx2x_iscsi_mac(dev, addr, addr1);
-
-	addr = BNX2X_SHMEM_ADDR(base, validity_map[port]);
-	val = CNIC_RD(dev, addr);
-
-	if (!(val & SHR_MEM_VALIDITY_LIC_NO_KEY_IN_EFFECT)) {
-		u16 val16;
-
-		addr = BNX2X_SHMEM_ADDR(base,
-				drv_lic_key[port].max_iscsi_init_conn);
-		val16 = CNIC_RD16(dev, addr);
-
-		if (val16)
-			val16 ^= 0x1e1e;
-		dev->max_iscsi_conn = val16;
-	}
-
-	if (BNX2X_CHIP_IS_E2(cp->chip_id))
-		dev->max_fcoe_conn = BNX2X_FCOE_NUM_CONNECTIONS;
-
-	if (BNX2X_CHIP_IS_E1H(cp->chip_id) || BNX2X_CHIP_IS_E2(cp->chip_id)) {
-		int func = CNIC_FUNC(cp);
-		u32 mf_cfg_addr;
-
-		if (BNX2X_SHMEM2_HAS(base2, mf_cfg_addr))
-			mf_cfg_addr = CNIC_RD(dev, BNX2X_SHMEM2_ADDR(base2,
-					      mf_cfg_addr));
-		else
-			mf_cfg_addr = base + BNX2X_SHMEM_MF_BLK_OFFSET;
-
-		if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
-			/* Must determine if the MF is SD vs SI mode */
-			addr = BNX2X_SHMEM_ADDR(base,
-					dev_info.shared_feature_config.config);
-			val = CNIC_RD(dev, addr);
-			if ((val & SHARED_FEAT_CFG_FORCE_SF_MODE_MASK) ==
-			    SHARED_FEAT_CFG_FORCE_SF_MODE_SWITCH_INDEPT) {
-				int rc;
-
-				/* MULTI_FUNCTION_SI mode */
-				addr = BNX2X_MF_CFG_ADDR(mf_cfg_addr,
-					func_ext_config[func].func_cfg);
-				val = CNIC_RD(dev, addr);
-				if (!(val & MACP_FUNC_CFG_FLAGS_ISCSI_OFFLOAD))
-					dev->max_iscsi_conn = 0;
-
-				if (!(val & MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD))
-					dev->max_fcoe_conn = 0;
-
-				addr = BNX2X_MF_CFG_ADDR(mf_cfg_addr,
-					func_ext_config[func].
-					iscsi_mac_addr_upper);
-				addr1 = BNX2X_MF_CFG_ADDR(mf_cfg_addr,
-					func_ext_config[func].
-					iscsi_mac_addr_lower);
-				rc = cnic_read_bnx2x_iscsi_mac(dev, addr,
-								addr1);
-				if (rc && func > 1)
-					dev->max_iscsi_conn = 0;
-
-				return;
-			}
-		}
-
-		addr = BNX2X_MF_CFG_ADDR(mf_cfg_addr,
-			func_mf_config[func].e1hov_tag);
-
-		val = CNIC_RD(dev, addr);
-		val &= FUNC_MF_CFG_E1HOV_TAG_MASK;
-		if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
-			dev->max_fcoe_conn = 0;
-			dev->max_iscsi_conn = 0;
-		}
-	}
-	if (!is_valid_ether_addr(dev->mac_addr))
-		dev->max_iscsi_conn = 0;
-}
-
 static void cnic_init_bnx2x_kcq(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -4918,8 +4805,6 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 
 	cnic_init_bnx2x_kcq(dev);
 
-	cnic_get_bnx2x_iscsi_info(dev);
-
 	/* Only 1 EQ */
 	CNIC_WR16(dev, cp->kcq1.io_addr, MAX_KCQ_IDX);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
@@ -5352,6 +5237,14 @@ static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
 	cdev->pcidev = pdev;
 	cp->chip_id = ethdev->chip_id;
 
+	if (!(ethdev->drv_state & CNIC_DRV_STATE_NO_ISCSI))
+		cdev->max_iscsi_conn = ethdev->max_iscsi_conn;
+	if (BNX2X_CHIP_IS_E2(cp->chip_id) &&
+	    !(ethdev->drv_state & CNIC_DRV_STATE_NO_FCOE))
+		cdev->max_fcoe_conn = ethdev->max_fcoe_conn;
+
+	memcpy(cdev->mac_addr, ethdev->iscsi_mac, 6);
+
 	cp->cnic_ops = &cnic_bnx2x_ops;
 	cp->start_hw = cnic_start_bnx2x_hw;
 	cp->stop_hw = cnic_stop_bnx2x_hw;
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index 9f44e0f..e01b49e 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.2.12"
-#define CNIC_MODULE_RELDATE	"Jan 03, 2011"
+#define CNIC_MODULE_VERSION	"2.2.13"
+#define CNIC_MODULE_RELDATE	"Jan 31, 2011"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
@@ -159,6 +159,9 @@ struct cnic_eth_dev {
 	u32		drv_state;
 #define CNIC_DRV_STATE_REGD		0x00000001
 #define CNIC_DRV_STATE_USING_MSIX	0x00000002
+#define CNIC_DRV_STATE_NO_ISCSI_OOO	0x00000004
+#define CNIC_DRV_STATE_NO_ISCSI		0x00000008
+#define CNIC_DRV_STATE_NO_FCOE		0x00000010
 	u32		chip_id;
 	u32		max_kwqe_pending;
 	struct pci_dev	*pdev;
@@ -176,6 +179,7 @@ struct cnic_eth_dev {
 	u32		fcoe_init_cid;
 	u16		iscsi_l2_client_id;
 	u16		iscsi_l2_cid;
+	u8		iscsi_mac[ETH_ALEN];
 
 	int		num_irq;
 	struct cnic_irq	irq_arr[MAX_CNIC_VEC];
-- 
1.6.4.GIT


