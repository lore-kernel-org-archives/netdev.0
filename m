From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 08/19] bnx2x: rename MF related fields
Date: Wed, 6 Oct 2010 15:26:40 +0200
Message-ID: <1286371600.30552.37.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757971Ab0JFNj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:39:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


MF (multi-function) mode supported not only by 57711E (E1H) devices, 
but also by coming 57712E, then we use more generic names.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h         |    8 ++--
 drivers/net/bnx2x/bnx2x_cmn.c     |    2 +-
 drivers/net/bnx2x/bnx2x_ethtool.c |   24 ++++++++--------
 drivers/net/bnx2x/bnx2x_main.c    |   56 ++++++++++++++++++------------------
 drivers/net/bnx2x/bnx2x_stats.c   |    4 +-
 5 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 8b053e0..d7b24f9 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -933,9 +933,9 @@ struct bnx2x {
 	u32			vn_weight_sum;
 
 	u32			mf_config;
-	u16			e1hov;
-	u8			e1hmf;
-#define IS_E1HMF(bp)			(bp->e1hmf != 0)
+	u16			mf_ov;
+	u8			mf_mode;
+#define IS_MF(bp)			(bp->mf_mode != 0)
 
 	u8			wol;
 
@@ -1127,7 +1127,7 @@ struct bnx2x {
 #define RSS_IPV6_CAP		0x0004
 #define RSS_IPV6_TCP_CAP	0x0008
 
-#define BNX2X_MAX_QUEUES(bp)	(IS_E1HMF(bp) ? (MAX_CONTEXT/E1HVN_MAX) \
+#define BNX2X_MAX_QUEUES(bp)	(IS_MF(bp) ? (MAX_CONTEXT/E1HVN_MAX) \
 					      : MAX_CONTEXT)
 #define BNX2X_NUM_QUEUES(bp)	(bp->num_queues)
 #define is_multi(bp)		(BNX2X_NUM_QUEUES(bp) > 1)
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index bcc4a8f..ae05987 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -745,7 +745,7 @@ void bnx2x_link_report(struct bnx2x *bp)
 		netdev_info(bp->dev, "NIC Link is Up, ");
 
 		line_speed = bp->link_vars.line_speed;
-		if (IS_E1HMF(bp)) {
+		if (IS_MF(bp)) {
 			u16 vn_max_rate;
 
 			vn_max_rate =
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 56a0cb5..fa8f952 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -41,7 +41,7 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	    (bp->link_vars.link_up)) {
 		cmd->speed = bp->link_vars.line_speed;
 		cmd->duplex = bp->link_vars.duplex;
-		if (IS_E1HMF(bp)) {
+		if (IS_MF(bp)) {
 			u16 vn_max_rate;
 
 			vn_max_rate =
@@ -89,7 +89,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct bnx2x *bp = netdev_priv(dev);
 	u32 advertising, cfg_idx, old_multi_phy_config, new_multi_phy_config;
 
-	if (IS_E1HMF(bp))
+	if (IS_MF(bp))
 		return 0;
 
 	DP(NETIF_MSG_LINK, "ethtool_cmd: cmd %d\n"
@@ -1027,7 +1027,7 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	u32 cfg_idx = bnx2x_get_link_cfg_idx(bp);
-	if (IS_E1HMF(bp))
+	if (IS_MF(bp))
 		return 0;
 
 	DP(NETIF_MSG_LINK, "ethtool_pauseparam: cmd %d\n"
@@ -1616,7 +1616,7 @@ static void bnx2x_self_test(struct net_device *dev,
 		return;
 
 	/* offline tests are not supported in MF mode */
-	if (IS_E1HMF(bp))
+	if (IS_MF(bp))
 		etest->flags &= ~ETH_TEST_FL_OFFLINE;
 	is_serdes = (bp->link_vars.link_status & LINK_STATUS_SERDES_LINK) > 0;
 
@@ -1808,8 +1808,8 @@ static const struct {
 #define IS_PORT_STAT(i) \
 	((bnx2x_stats_arr[i].flags & STATS_FLAGS_BOTH) == STATS_FLAGS_PORT)
 #define IS_FUNC_STAT(i)		(bnx2x_stats_arr[i].flags & STATS_FLAGS_FUNC)
-#define IS_E1HMF_MODE_STAT(bp) \
-			(IS_E1HMF(bp) && !(bp->msg_enable & BNX2X_MSG_STATS))
+#define IS_MF_MODE_STAT(bp) \
+			(IS_MF(bp) && !(bp->msg_enable & BNX2X_MSG_STATS))
 
 static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
 {
@@ -1820,10 +1820,10 @@ static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
 	case ETH_SS_STATS:
 		if (is_multi(bp)) {
 			num_stats = BNX2X_NUM_Q_STATS * bp->num_queues;
-			if (!IS_E1HMF_MODE_STAT(bp))
+			if (!IS_MF_MODE_STAT(bp))
 				num_stats += BNX2X_NUM_STATS;
 		} else {
-			if (IS_E1HMF_MODE_STAT(bp)) {
+			if (IS_MF_MODE_STAT(bp)) {
 				num_stats = 0;
 				for (i = 0; i < BNX2X_NUM_STATS; i++)
 					if (IS_FUNC_STAT(i))
@@ -1856,14 +1856,14 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 						bnx2x_q_stats_arr[j].string, i);
 				k += BNX2X_NUM_Q_STATS;
 			}
-			if (IS_E1HMF_MODE_STAT(bp))
+			if (IS_MF_MODE_STAT(bp))
 				break;
 			for (j = 0; j < BNX2X_NUM_STATS; j++)
 				strcpy(buf + (k + j)*ETH_GSTRING_LEN,
 				       bnx2x_stats_arr[j].string);
 		} else {
 			for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
-				if (IS_E1HMF_MODE_STAT(bp) && IS_PORT_STAT(i))
+				if (IS_MF_MODE_STAT(bp) && IS_PORT_STAT(i))
 					continue;
 				strcpy(buf + j*ETH_GSTRING_LEN,
 				       bnx2x_stats_arr[i].string);
@@ -1907,7 +1907,7 @@ static void bnx2x_get_ethtool_stats(struct net_device *dev,
 			}
 			k += BNX2X_NUM_Q_STATS;
 		}
-		if (IS_E1HMF_MODE_STAT(bp))
+		if (IS_MF_MODE_STAT(bp))
 			return;
 		hw_stats = (u32 *)&bp->eth_stats;
 		for (j = 0; j < BNX2X_NUM_STATS; j++) {
@@ -1928,7 +1928,7 @@ static void bnx2x_get_ethtool_stats(struct net_device *dev,
 	} else {
 		hw_stats = (u32 *)&bp->eth_stats;
 		for (i = 0, j = 0; i < BNX2X_NUM_STATS; i++) {
-			if (IS_E1HMF_MODE_STAT(bp) && IS_PORT_STAT(i))
+			if (IS_MF_MODE_STAT(bp) && IS_PORT_STAT(i))
 				continue;
 			if (bnx2x_stats_arr[i].size == 0) {
 				/* skip this counter */
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 119ca87..238e38f 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1013,7 +1013,7 @@ void bnx2x_int_enable(struct bnx2x *bp)
 
 	if (CHIP_IS_E1H(bp)) {
 		/* init leading/trailing edge */
-		if (IS_E1HMF(bp)) {
+		if (IS_MF(bp)) {
 			val = (0xee0f | (1 << (BP_E1HVN(bp) + 4)));
 			if (bp->port.pmf)
 				/* enable nig and gpio3 attention */
@@ -1792,7 +1792,7 @@ static int bnx2x_get_cmng_fns_mode(struct bnx2x *bp)
 {
 	if (CHIP_REV_IS_SLOW(bp))
 		return CMNG_FNS_NONE;
-	if (IS_E1HMF(bp))
+	if (IS_MF(bp))
 		return CMNG_FNS_MINMAX;
 
 	return CMNG_FNS_NONE;
@@ -1906,7 +1906,7 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 	if (prev_link_status != bp->link_vars.link_status)
 		bnx2x_link_report(bp);
 
-	if (IS_E1HMF(bp)) {
+	if (IS_MF(bp)) {
 		int port = BP_PORT(bp);
 		int func;
 		int vn;
@@ -2160,7 +2160,7 @@ static inline u16 bnx2x_get_cl_flags(struct bnx2x *bp,
 	/* calculate queue flags */
 	flags |= QUEUE_FLG_CACHE_ALIGN;
 	flags |= QUEUE_FLG_HC;
-	flags |= IS_E1HMF(bp) ? QUEUE_FLG_OV : 0;
+	flags |= IS_MF(bp) ? QUEUE_FLG_OV : 0;
 
 #ifdef BCM_VLAN
 	flags |= QUEUE_FLG_VLAN;
@@ -2262,7 +2262,7 @@ void bnx2x_pf_init(struct bnx2x *bp)
 
 	/* pf specific setups */
 	if (!CHIP_IS_E1(bp))
-		storm_memset_ov(bp, bp->e1hov, BP_FUNC(bp));
+		storm_memset_ov(bp, bp->mf_ov, BP_FUNC(bp));
 
 	/* function setup flags */
 	flags = (FUNC_FLG_STATS | FUNC_FLG_LEADING | FUNC_FLG_SPQ);
@@ -3855,13 +3855,13 @@ static void bnx2x_init_internal_common(struct bnx2x *bp)
 		/* xstorm needs to know whether to add  ovlan to packets or not,
 		 * in switch-independent we'll write 0 to here... */
 		REG_WR8(bp, BAR_XSTRORM_INTMEM + XSTORM_FUNCTION_MODE_OFFSET,
-			bp->e1hmf);
+			bp->mf_mode);
 		REG_WR8(bp, BAR_TSTRORM_INTMEM + TSTORM_FUNCTION_MODE_OFFSET,
-			bp->e1hmf);
+			bp->mf_mode);
 		REG_WR8(bp, BAR_CSTRORM_INTMEM + CSTORM_FUNCTION_MODE_OFFSET,
-			bp->e1hmf);
+			bp->mf_mode);
 		REG_WR8(bp, BAR_USTRORM_INTMEM + USTORM_FUNCTION_MODE_OFFSET,
-			bp->e1hmf);
+			bp->mf_mode);
 	}
 
 	/* Zero this manually as its initialization is
@@ -4418,7 +4418,7 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 
 	bnx2x_init_block(bp, MISC_BLOCK, COMMON_STAGE);
 	if (CHIP_IS_E1H(bp))
-		REG_WR(bp, MISC_REG_E1HMF_MODE, IS_E1HMF(bp));
+		REG_WR(bp, MISC_REG_E1HMF_MODE, IS_MF(bp));
 
 	REG_WR(bp, MISC_REG_LCPLL_CTRL_REG_2, 0x100);
 	msleep(30);
@@ -4518,7 +4518,7 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 	REG_WR(bp, PRS_REG_NIC_MODE, 1);
 #endif
 	if (CHIP_IS_E1H(bp))
-		REG_WR(bp, PRS_REG_E1HOV_MODE, IS_E1HMF(bp));
+		REG_WR(bp, PRS_REG_E1HOV_MODE, IS_MF(bp));
 
 	bnx2x_init_block(bp, TSDM_BLOCK, COMMON_STAGE);
 	bnx2x_init_block(bp, CSDM_BLOCK, COMMON_STAGE);
@@ -4596,8 +4596,8 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 
 	bnx2x_init_block(bp, NIG_BLOCK, COMMON_STAGE);
 	if (CHIP_IS_E1H(bp)) {
-		REG_WR(bp, NIG_REG_LLH_MF_MODE, IS_E1HMF(bp));
-		REG_WR(bp, NIG_REG_LLH_E1HOV_MODE, IS_E1HMF(bp));
+		REG_WR(bp, NIG_REG_LLH_MF_MODE, IS_MF(bp));
+		REG_WR(bp, NIG_REG_LLH_E1HOV_MODE, IS_MF(bp));
 	}
 
 	if (CHIP_REV_IS_SLOW(bp))
@@ -4692,7 +4692,7 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 		low = 0;
 		high = 513;
 	} else {
-		if (IS_E1HMF(bp))
+		if (IS_MF(bp))
 			low = ((bp->flags & ONE_PORT_FLAG) ? 160 : 246);
 		else if (bp->dev->mtu > 4096) {
 			if (bp->flags & ONE_PORT_FLAG)
@@ -4758,7 +4758,7 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 	 *  - MF mode: bit 3 is masked. bits 0-2 are in use as in SF
 	 *             bits 4-7 are used for "per vn group attention" */
 	REG_WR(bp, MISC_REG_AEU_MASK_ATTN_FUNC_0 + port*4,
-	       (IS_E1HMF(bp) ? 0xF7 : 0x7));
+	       (IS_MF(bp) ? 0xF7 : 0x7));
 
 	bnx2x_init_block(bp, PXPCS_BLOCK, init_stage);
 	bnx2x_init_block(bp, EMAC0_BLOCK, init_stage);
@@ -4771,9 +4771,9 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 	REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 1);
 
 	if (CHIP_IS_E1H(bp)) {
-		/* 0x2 disable e1hov, 0x1 enable */
+		/* 0x2 disable mf_ov, 0x1 enable */
 		REG_WR(bp, NIG_REG_LLH0_BRB1_DRV_MASK_MF + port*4,
-		       (IS_E1HMF(bp) ? 0x1 : 0x2));
+		       (IS_MF(bp) ? 0x1 : 0x2));
 
 		{
 			REG_WR(bp, NIG_REG_LLFC_ENABLE_0 + port*4, 0);
@@ -4883,9 +4883,9 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 
 	bnx2x_init_block(bp, CFC_BLOCK, FUNC0_STAGE + func);
 
-	if (IS_E1HMF(bp)) {
+	if (IS_MF(bp)) {
 		REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 1);
-		REG_WR(bp, NIG_REG_LLH0_FUNC_VLAN_ID + port*8, bp->e1hov);
+		REG_WR(bp, NIG_REG_LLH0_FUNC_VLAN_ID + port*8, bp->mf_ov);
 	}
 
 	bnx2x_init_block(bp, MISC_AEU_BLOCK, FUNC0_STAGE + func);
@@ -7189,8 +7189,8 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 	bp->igu_base_sb = 0;
 	bp->igu_sb_cnt = min_t(u8, FP_SB_MAX_E1x, bp->l2_cid_count);
 
-	bp->e1hov = 0;
-	bp->e1hmf = 0;
+	bp->mf_ov = 0;
+	bp->mf_mode = 0;
 	if (CHIP_IS_E1H(bp) && !BP_NOMCP(bp)) {
 
 		bp->common.mf_cfg_base = bp->common.shmem_base +
@@ -7202,19 +7202,19 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 		val = (MF_CFG_RD(bp, func_mf_config[FUNC_0].e1hov_tag) &
 		       FUNC_MF_CFG_E1HOV_TAG_MASK);
 		if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT)
-			bp->e1hmf = 1;
+			bp->mf_mode = 1;
 		BNX2X_DEV_INFO("%s function mode\n",
-			       IS_E1HMF(bp) ? "multi" : "single");
+			       IS_MF(bp) ? "multi" : "single");
 
-		if (IS_E1HMF(bp)) {
+		if (IS_MF(bp)) {
 			val = (MF_CFG_RD(bp, func_mf_config[func].
 								e1hov_tag) &
 			       FUNC_MF_CFG_E1HOV_TAG_MASK);
 			if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
-				bp->e1hov = val;
+				bp->mf_ov = val;
 				BNX2X_DEV_INFO("E1HOV for func %d is %d "
 					       "(0x%04x)\n",
-					       func, bp->e1hov, bp->e1hov);
+					       func, bp->mf_ov, bp->mf_ov);
 			} else {
 				BNX2X_ERROR("No valid E1HOV for func %d,"
 					    "  aborting\n", func);
@@ -7230,7 +7230,7 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 	}
 
 	/* adjust igu_sb_cnt to MF */
-	if (IS_E1HMF(bp))
+	if (IS_MF(bp))
 		bp->igu_sb_cnt /= E1HVN_MAX;
 
 	if (!BP_NOMCP(bp)) {
@@ -7241,7 +7241,7 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 		BNX2X_DEV_INFO("fw_seq 0x%08x\n", bp->fw_seq);
 	}
 
-	if (IS_E1HMF(bp)) {
+	if (IS_MF(bp)) {
 		val2 = MF_CFG_RD(bp, func_mf_config[func].mac_upper);
 		val = MF_CFG_RD(bp,  func_mf_config[func].mac_lower);
 		if ((val2 != FUNC_MF_CFG_UPPERMAC_DEFAULT) &&
diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
index 1256f62..c271fc5 100644
--- a/drivers/net/bnx2x/bnx2x_stats.c
+++ b/drivers/net/bnx2x/bnx2x_stats.c
@@ -253,7 +253,7 @@ static void bnx2x_stats_pmf_update(struct bnx2x *bp)
 	u32 *stats_comp = bnx2x_sp(bp, stats_comp);
 
 	/* sanity */
-	if (!IS_E1HMF(bp) || !bp->port.pmf || !bp->port.port_stx) {
+	if (!IS_MF(bp) || !bp->port.pmf || !bp->port.port_stx) {
 		BNX2X_ERR("BUG!\n");
 		return;
 	}
@@ -1284,7 +1284,7 @@ static void bnx2x_port_stats_base_init(struct bnx2x *bp)
 
 static void bnx2x_func_stats_base_init(struct bnx2x *bp)
 {
-	int vn, vn_max = IS_E1HMF(bp) ? E1HVN_MAX : E1VN_MAX;
+	int vn, vn_max = IS_MF(bp) ? E1HVN_MAX : E1VN_MAX;
 	int port = BP_PORT(bp);
 	int func;
 	u32 func_stx;
-- 
1.7.1




