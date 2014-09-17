From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/3] bnx2x: Changes with storage & MAC macros
Date: Wed, 17 Sep 2014 16:24:36 +0300
Message-ID: <1410960278-32064-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1410960278-32064-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:39505 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755287AbaIQNYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 09:24:55 -0400
In-Reply-To: <1410960278-32064-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>

Rearrange macros to query for storage-only modes in different MF environment.
Improves the readibility and maintainability of the code. E.g.:
	-	if (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))
	+	if (IS_MF_STORAGE_ONLY(bp))

In addition, this removes the need for bnx2x_is_valid_ether_addr().

Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        | 44 ++++++++++++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    | 12 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |  8 ----
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   | 30 ++++++---------
 5 files changed, 54 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 86e9451..7ecb61f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2361,7 +2361,7 @@ void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func, u8 idu_sb_id,
 #define ATTN_HARD_WIRED_MASK		0xff00
 #define ATTENTION_ID			4
 
-#define IS_MF_STORAGE_ONLY(bp) (IS_MF_STORAGE_SD(bp) || \
+#define IS_MF_STORAGE_ONLY(bp) (IS_MF_STORAGE_PERSONALITY_ONLY(bp) || \
 				 IS_MF_FCOE_AFEX(bp))
 
 /* stuff added to make the code fit 80Col */
@@ -2537,14 +2537,44 @@ void bnx2x_notify_link_changed(struct bnx2x *bp);
 
 #define IS_MF_ISCSI_SD(bp) (IS_MF_SD(bp) && BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp))
 #define IS_MF_FCOE_SD(bp) (IS_MF_SD(bp) && BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp))
+#define IS_MF_ISCSI_SI(bp) (IS_MF_SI(bp) && BNX2X_IS_MF_EXT_PROTOCOL_ISCSI(bp))
 
-#define BNX2X_MF_EXT_PROTOCOL_FCOE(bp)  ((bp)->mf_ext_config & \
-					 MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD)
+#define IS_MF_ISCSI_ONLY(bp)    (IS_MF_ISCSI_SD(bp) ||  IS_MF_ISCSI_SI(bp))
+
+#define BNX2X_MF_EXT_PROTOCOL_MASK					\
+				(MACP_FUNC_CFG_FLAGS_ETHERNET |		\
+				 MACP_FUNC_CFG_FLAGS_ISCSI_OFFLOAD |	\
+				 MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD)
+
+#define BNX2X_MF_EXT_PROT(bp)	((bp)->mf_ext_config &			\
+				 BNX2X_MF_EXT_PROTOCOL_MASK)
+
+#define BNX2X_HAS_MF_EXT_PROTOCOL_FCOE(bp)				\
+		(BNX2X_MF_EXT_PROT(bp) & MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD)
+
+#define BNX2X_IS_MF_EXT_PROTOCOL_FCOE(bp)				\
+		(BNX2X_MF_EXT_PROT(bp) == MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD)
+
+#define BNX2X_IS_MF_EXT_PROTOCOL_ISCSI(bp)				\
+		(BNX2X_MF_EXT_PROT(bp) == MACP_FUNC_CFG_FLAGS_ISCSI_OFFLOAD)
+
+#define IS_MF_FCOE_AFEX(bp)						\
+		(IS_MF_AFEX(bp) && BNX2X_IS_MF_EXT_PROTOCOL_FCOE(bp))
+
+#define IS_MF_SD_STORAGE_PERSONALITY_ONLY(bp)				\
+				(IS_MF_SD(bp) &&			\
+				 (BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp) ||	\
+				  BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp)))
+
+#define IS_MF_SI_STORAGE_PERSONALITY_ONLY(bp)				\
+				(IS_MF_SI(bp) &&			\
+				 (BNX2X_IS_MF_EXT_PROTOCOL_ISCSI(bp) ||	\
+				  BNX2X_IS_MF_EXT_PROTOCOL_FCOE(bp)))
+
+#define IS_MF_STORAGE_PERSONALITY_ONLY(bp)				\
+			(IS_MF_SD_STORAGE_PERSONALITY_ONLY(bp) ||	\
+			 IS_MF_SI_STORAGE_PERSONALITY_ONLY(bp))
 
-#define IS_MF_FCOE_AFEX(bp) (IS_MF_AFEX(bp) && BNX2X_MF_EXT_PROTOCOL_FCOE(bp))
-#define IS_MF_STORAGE_SD(bp) (IS_MF_SD(bp) && \
-				(BNX2X_IS_MF_SD_PROTOCOL_ISCSI(bp) || \
-				 BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp)))
 
 #define SET_FLAG(value, mask, flag) \
 	do {\
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 6dc32ae..40beef5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1938,7 +1938,7 @@ void bnx2x_set_num_queues(struct bnx2x *bp)
 	bp->num_ethernet_queues = bnx2x_calc_num_queues(bp);
 
 	/* override in STORAGE SD modes */
-	if (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))
+	if (IS_MF_STORAGE_ONLY(bp))
 		bp->num_ethernet_queues = 1;
 
 	/* Add special queues */
@@ -4231,14 +4231,13 @@ int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 	struct bnx2x *bp = netdev_priv(dev);
 	int rc = 0;
 
-	if (!bnx2x_is_valid_ether_addr(bp, addr->sa_data)) {
+	if (!is_valid_ether_addr(addr->sa_data)) {
 		BNX2X_ERR("Requested MAC address is not valid\n");
 		return -EINVAL;
 	}
 
-	if ((IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp)) &&
-	    !is_zero_ether_addr(addr->sa_data)) {
-		BNX2X_ERR("Can't configure non-zero address on iSCSI or FCoE functions in MF-SD mode\n");
+	if (IS_MF_STORAGE_ONLY(bp)) {
+		BNX2X_ERR("Can't change address on STORAGE ONLY function\n");
 		return -EINVAL;
 	}
 
@@ -4417,8 +4416,7 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 	u8 cos;
 	int rx_ring_size = 0;
 
-	if (!bp->rx_ring_size &&
-	    (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))) {
+	if (!bp->rx_ring_size && IS_MF_STORAGE_ONLY(bp)) {
 		rx_ring_size = MIN_RX_SIZE_NONTPA;
 		bp->rx_ring_size = rx_ring_size;
 	} else if (!bp->rx_ring_size) {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index ac63e16..0102775 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1298,15 +1298,7 @@ static inline void bnx2x_update_drv_flags(struct bnx2x *bp, u32 flags, u32 set)
 	}
 }
 
-static inline bool bnx2x_is_valid_ether_addr(struct bnx2x *bp, u8 *addr)
-{
-	if (is_valid_ether_addr(addr) ||
-	    (is_zero_ether_addr(addr) &&
-	     (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))))
-		return true;
 
-	return false;
-}
 
 /**
  * bnx2x_fill_fw_str - Fill buffer with FW version string
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 0b173ed..1edc931 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1852,7 +1852,7 @@ static int bnx2x_set_ringparam(struct net_device *dev,
 	if ((ering->rx_pending > MAX_RX_AVAIL) ||
 	    (ering->rx_pending < (bp->disable_tpa ? MIN_RX_SIZE_NONTPA :
 						    MIN_RX_SIZE_TPA)) ||
-	    (ering->tx_pending > (IS_MF_FCOE_AFEX(bp) ? 0 : MAX_TX_AVAIL)) ||
+	    (ering->tx_pending > (IS_MF_STORAGE_ONLY(bp) ? 0 : MAX_TX_AVAIL)) ||
 	    (ering->tx_pending <= MAX_SKB_FRAGS + 4)) {
 		DP(BNX2X_MSG_ETHTOOL, "Command parameters not supported\n");
 		return -EINVAL;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 32e2444..82ea6b6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -8323,13 +8323,6 @@ int bnx2x_del_all_macs(struct bnx2x *bp,
 
 int bnx2x_set_eth_mac(struct bnx2x *bp, bool set)
 {
-	if (is_zero_ether_addr(bp->dev->dev_addr) &&
-	    (IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp))) {
-		DP(NETIF_MSG_IFUP | NETIF_MSG_IFDOWN,
-		   "Ignoring Zero MAC for STORAGE SD mode\n");
-		return 0;
-	}
-
 	if (IS_PF(bp)) {
 		unsigned long ramrod_flags = 0;
 
@@ -11355,15 +11348,14 @@ static void bnx2x_get_fcoe_info(struct bnx2x *bp)
 				 dev_info.port_hw_config[port].
 				 fcoe_wwn_node_name_lower);
 	} else if (!IS_MF_SD(bp)) {
-		/*
-		 * Read the WWN info only if the FCoE feature is enabled for
+		/* Read the WWN info only if the FCoE feature is enabled for
 		 * this function.
 		 */
-		if (BNX2X_MF_EXT_PROTOCOL_FCOE(bp) && !CHIP_IS_E1x(bp))
+		if (BNX2X_HAS_MF_EXT_PROTOCOL_FCOE(bp))
+			bnx2x_get_ext_wwn_info(bp, func);
+	} else {
+		if (BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp) && !CHIP_IS_E1x(bp))
 			bnx2x_get_ext_wwn_info(bp, func);
-
-	} else if (IS_MF_FCOE_SD(bp) && !CHIP_IS_E1x(bp)) {
-		bnx2x_get_ext_wwn_info(bp, func);
 	}
 
 	BNX2X_DEV_INFO("max_fcoe_conn 0x%x\n", bp->cnic_eth_dev.max_fcoe_conn);
@@ -11401,7 +11393,7 @@ static void bnx2x_get_cnic_mac_hwinfo(struct bnx2x *bp)
 		 * In non SD mode features configuration comes from struct
 		 * func_ext_config.
 		 */
-		if (!IS_MF_SD(bp) && !CHIP_IS_E1x(bp)) {
+		if (!IS_MF_SD(bp)) {
 			u32 cfg = MF_CFG_RD(bp, func_ext_config[func].func_cfg);
 			if (cfg & MACP_FUNC_CFG_FLAGS_ISCSI_OFFLOAD) {
 				val2 = MF_CFG_RD(bp, func_ext_config[func].
@@ -11520,7 +11512,7 @@ static void bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 
 	memcpy(bp->link_params.mac_addr, bp->dev->dev_addr, ETH_ALEN);
 
-	if (!bnx2x_is_valid_ether_addr(bp, bp->dev->dev_addr))
+	if (!is_valid_ether_addr(bp->dev->dev_addr))
 		dev_err(&bp->pdev->dev,
 			"bad Ethernet MAC address configuration: %pM\n"
 			"change it manually before bringing up the appropriate network interface\n",
@@ -11970,7 +11962,7 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 		dev_err(&bp->pdev->dev, "MCP disabled, must load devices in order!\n");
 
 	bp->disable_tpa = disable_tpa;
-	bp->disable_tpa |= IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp);
+	bp->disable_tpa |= !!IS_MF_STORAGE_ONLY(bp);
 	/* Reduce memory usage in kdump environment by disabling TPA */
 	bp->disable_tpa |= is_kdump_kernel();
 
@@ -11990,7 +11982,7 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 
 	bp->mrrs = mrrs;
 
-	bp->tx_ring_size = IS_MF_FCOE_AFEX(bp) ? 0 : MAX_TX_AVAIL;
+	bp->tx_ring_size = IS_MF_STORAGE_ONLY(bp) ? 0 : MAX_TX_AVAIL;
 	if (IS_VF(bp))
 		bp->rx_ring_size = MAX_RX_AVAIL;
 
@@ -12310,7 +12302,7 @@ void bnx2x_set_rx_mode_inner(struct bnx2x *bp)
 
 	bp->rx_mode = rx_mode;
 	/* handle ISCSI SD mode */
-	if (IS_MF_ISCSI_SD(bp))
+	if (IS_MF_ISCSI_ONLY(bp))
 		bp->rx_mode = BNX2X_RX_MODE_NONE;
 
 	/* Schedule the rx_mode command */
@@ -12417,7 +12409,7 @@ static int bnx2x_validate_addr(struct net_device *dev)
 	if (IS_VF(bp))
 		bnx2x_sample_bulletin(bp);
 
-	if (!bnx2x_is_valid_ether_addr(bp, dev->dev_addr)) {
+	if (!is_valid_ether_addr(dev->dev_addr)) {
 		BNX2X_ERR("Non-valid Ethernet address\n");
 		return -EADDRNOTAVAIL;
 	}
-- 
1.8.3.1
