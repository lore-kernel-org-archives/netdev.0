From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 7/9] bnx2x: changed iscsi/fcoe mac init and macros
Date: Sun, 18 Mar 2012 16:33:43 -0400
Message-ID: <1332102825-7838-8-git-send-email-yuvalmin@broadcom.com>
References: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1278 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753822Ab2CRNsa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 09:48:30 -0400
In-Reply-To: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

This includes changes in macros to better distinguish between the two
protocols, and slightly changed the way their macs are set.
Notice this file contains string print lines with more than 80 characters,
as to not break prints.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |   16 +++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    8 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   82 ++++++++++++---------
 4 files changed, 64 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index f534bf1..562cec3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2117,14 +2117,22 @@ void bnx2x_set_ethtool_ops(struct net_device *netdev);
 void bnx2x_notify_link_changed(struct bnx2x *bp);
 
 
-#define BNX2X_MF_PROTOCOL(bp) \
+#define BNX2X_MF_SD_PROTOCOL(bp) \
 	((bp)->mf_config[BP_VN(bp)] & FUNC_MF_CFG_PROTOCOL_MASK)
 
 #ifdef BCM_CNIC
-#define BNX2X_IS_MF_PROTOCOL_ISCSI(bp) \
-	(BNX2X_MF_PROTOCOL(bp) == FUNC_MF_CFG_PROTOCOL_ISCSI)
+#define BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp) \
+	(BNX2X_MF_SD_PROTOCOL(bp) == FUNC_MF_CFG_PROTOCOL_ISCSI)
 
-#define IS_MF_ISCSI_SD(bp) (IS_MF_SD(bp) && BNX2X_IS_MF_PROTOCOL_ISCSI(bp))
+#define BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp) \
+	(BNX2X_MF_SD_PROTOCOL(bp) == FUNC_MF_CFG_PROTOCOL_FCOE)
+
+#define IS_MF_ISCSI_SD(bp) (IS_MF_SD(bp) && BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp))
+#define IS_MF_FCOE_SD(bp) (IS_MF_SD(bp) && BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp))
+
+#define IS_MF_STORAGE_SD(bp) (IS_MF_SD(bp) && \
+				(BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp) || \
+				 BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp)))
 #endif
 
 #endif /* bnx2x.h */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 8865b92..b457a5c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1453,8 +1453,8 @@ void bnx2x_set_num_queues(struct bnx2x *bp)
 	}
 
 #ifdef BCM_CNIC
-	/* override in ISCSI SD mod */
-	if (IS_MF_ISCSI_SD(bp))
+	/* override in STORAGE SD mode */
+	if (IS_MF_STORAGE_SD(bp))
 		bp->num_queues = 1;
 #endif
 	/* Add special queues */
@@ -3077,7 +3077,7 @@ int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 	}
 
 #ifdef BCM_CNIC
-	if (IS_MF_ISCSI_SD(bp) && !is_zero_ether_addr(addr->sa_data)) {
+	if (IS_MF_STORAGE_SD(bp) && !is_zero_ether_addr(addr->sa_data)) {
 		BNX2X_ERR("Can't configure non-zero address on iSCSI or FCoE functions in MF-SD mode\n");
 		return -EINVAL;
 	}
@@ -3199,7 +3199,7 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 	int rx_ring_size = 0;
 
 #ifdef BCM_CNIC
-	if (!bp->rx_ring_size && IS_MF_ISCSI_SD(bp)) {
+	if (!bp->rx_ring_size && IS_MF_STORAGE_SD(bp)) {
 		rx_ring_size = MIN_RX_SIZE_NONTPA;
 		bp->rx_ring_size = rx_ring_size;
 	} else
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index e15fdc9..145bfc7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1658,7 +1658,7 @@ static inline bool bnx2x_is_valid_ether_addr(struct bnx2x *bp, u8 *addr)
 	if (is_valid_ether_addr(addr))
 		return true;
 #ifdef BCM_CNIC
-	if (is_zero_ether_addr(addr) && IS_MF_ISCSI_SD(bp))
+	if (is_zero_ether_addr(addr) && IS_MF_STORAGE_SD(bp))
 		return true;
 #endif
 	return false;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d969738..a3d5246 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7177,7 +7177,7 @@ int bnx2x_set_eth_mac(struct bnx2x *bp, bool set)
 	unsigned long ramrod_flags = 0;
 
 #ifdef BCM_CNIC
-	if (is_zero_ether_addr(bp->dev->dev_addr) && IS_MF_ISCSI_SD(bp)) {
+	if (is_zero_ether_addr(bp->dev->dev_addr) && IS_MF_STORAGE_SD(bp)) {
 		DP(NETIF_MSG_IFUP | NETIF_MSG_IFDOWN,
 		   "Ignoring Zero MAC for STORAGE SD mode\n");
 		return 0;
@@ -9479,6 +9479,7 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 
 void bnx2x_get_iscsi_info(struct bnx2x *bp)
 {
+	u32 no_flags = NO_ISCSI_FLAG;
 #ifdef BCM_CNIC
 	int port = BP_PORT(bp);
 
@@ -9498,12 +9499,28 @@ void bnx2x_get_iscsi_info(struct bnx2x *bp)
 	 * disable the feature.
 	 */
 	if (!bp->cnic_eth_dev.max_iscsi_conn)
-		bp->flags |= NO_ISCSI_FLAG;
+		bp->flags |= no_flags;
 #else
-	bp->flags |= NO_ISCSI_FLAG;
+	bp->flags |= no_flags;
 #endif
 }
 
+#ifdef BCM_CNIC
+static void __devinit bnx2x_get_ext_wwn_info(struct bnx2x *bp, int func)
+{
+	/* Port info */
+	bp->cnic_eth_dev.fcoe_wwn_port_name_hi =
+		MF_CFG_RD(bp, func_ext_config[func].fcoe_wwn_port_name_upper);
+	bp->cnic_eth_dev.fcoe_wwn_port_name_lo =
+		MF_CFG_RD(bp, func_ext_config[func].fcoe_wwn_port_name_lower);
+
+	/* Node info */
+	bp->cnic_eth_dev.fcoe_wwn_node_name_hi =
+		MF_CFG_RD(bp, func_ext_config[func].fcoe_wwn_node_name_upper);
+	bp->cnic_eth_dev.fcoe_wwn_node_name_lo =
+		MF_CFG_RD(bp, func_ext_config[func].fcoe_wwn_node_name_lower);
+}
+#endif
 static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
 {
 #ifdef BCM_CNIC
@@ -9546,24 +9563,11 @@ static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
 		 * Read the WWN info only if the FCoE feature is enabled for
 		 * this function.
 		 */
-		if (cfg & MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD) {
-			/* Port info */
-			bp->cnic_eth_dev.fcoe_wwn_port_name_hi =
-				MF_CFG_RD(bp, func_ext_config[func].
-						fcoe_wwn_port_name_upper);
-			bp->cnic_eth_dev.fcoe_wwn_port_name_lo =
-				MF_CFG_RD(bp, func_ext_config[func].
-						fcoe_wwn_port_name_lower);
-
-			/* Node info */
-			bp->cnic_eth_dev.fcoe_wwn_node_name_hi =
-				MF_CFG_RD(bp, func_ext_config[func].
-						fcoe_wwn_node_name_upper);
-			bp->cnic_eth_dev.fcoe_wwn_node_name_lo =
-				MF_CFG_RD(bp, func_ext_config[func].
-						fcoe_wwn_node_name_lower);
-		}
-	}
+		if (cfg & MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD)
+			bnx2x_get_ext_wwn_info(bp, func);
+
+	} else if (IS_MF_FCOE_SD(bp))
+		bnx2x_get_ext_wwn_info(bp, func);
 
 	BNX2X_DEV_INFO("max_fcoe_conn 0x%x\n", bp->cnic_eth_dev.max_fcoe_conn);
 
@@ -9616,8 +9620,11 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 		/*
 		 * iSCSI and FCoE NPAR MACs: if there is no either iSCSI or
 		 * FCoE MAC then the appropriate feature should be disabled.
+		 *
+		 * In non SD mode features configuration comes from
+		 * struct func_ext_config.
 		 */
-		if (IS_MF_SI(bp)) {
+		if (!IS_MF_SD(bp)) {
 			u32 cfg = MF_CFG_RD(bp, func_ext_config[func].func_cfg);
 			if (cfg & MACP_FUNC_CFG_FLAGS_ISCSI_OFFLOAD) {
 				val2 = MF_CFG_RD(bp, func_ext_config[func].
@@ -9641,16 +9648,25 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 
 			} else
 				bp->flags |= NO_FCOE_FLAG;
-		} else { /* SD mode */
-			if (BNX2X_IS_MF_PROTOCOL_ISCSI(bp)) {
-				/* use primary mac as iscsi mac */
-				memcpy(iscsi_mac, bp->dev->dev_addr, ETH_ALEN);
+		} else { /* SD MODE */
+			if (IS_MF_STORAGE_SD(bp)) {
+				if (BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp)) {
+					/* use primary mac as iscsi mac */
+					memcpy(iscsi_mac, bp->dev->dev_addr,
+					       ETH_ALEN);
+
+					BNX2X_DEV_INFO("SD ISCSI MODE\n");
+					BNX2X_DEV_INFO("Read iSCSI MAC: %pM\n",
+						       iscsi_mac);
+				} else { /* FCoE */
+					memcpy(fip_mac, bp->dev->dev_addr,
+					       ETH_ALEN);
+					BNX2X_DEV_INFO("SD FCoE MODE\n");
+					BNX2X_DEV_INFO("Read FIP MAC: %pM\n",
+						       fip_mac);
+				}
 				/* Zero primary MAC configuration */
 				memset(bp->dev->dev_addr, 0, ETH_ALEN);
-
-				BNX2X_DEV_INFO("SD ISCSI MODE\n");
-				BNX2X_DEV_INFO("Read iSCSI MAC: %pM\n",
-					       iscsi_mac);
 			}
 		}
 #endif
@@ -9679,10 +9695,6 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
 
 #ifdef BCM_CNIC
-	/* Set the FCoE MAC in MF_SD mode */
-	if (!CHIP_IS_E1x(bp) && IS_MF_SD(bp))
-		memcpy(fip_mac, bp->dev->dev_addr, ETH_ALEN);
-
 	/* Disable iSCSI if MAC configuration is
 	 * invalid.
 	 */
@@ -10092,7 +10104,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	bp->disable_tpa = disable_tpa;
 
 #ifdef BCM_CNIC
-	bp->disable_tpa |= IS_MF_ISCSI_SD(bp);
+	bp->disable_tpa |= IS_MF_STORAGE_SD(bp);
 #endif
 
 	/* Set TPA flags */
-- 
1.7.9.rc2
