From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 8/10] bnx2x: change to the rss engine
Date: Wed, 4 Apr 2012 07:41:30 +0300
Message-ID: <1333514492-20425-9-git-send-email-yuvalmin@broadcom.com>
References: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4898 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752797Ab2DDEri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 00:47:38 -0400
In-Reply-To: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

This patch revises the way by which rss are configured, removing
an unnecessary module paramater and unrequired modes.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   88 ++++++--------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |   13 +++-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    7 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   10 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |    6 --
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h     |    3 -
 7 files changed, 42 insertions(+), 86 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 5eecafd..b0803ba 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1375,7 +1375,6 @@ struct bnx2x {
 #define BNX2X_STATE_DIAG		0xe000
 #define BNX2X_STATE_ERROR		0xf000
 
-	int			multi_mode;
 #define BNX2X_MAX_PRIORITY		8
 #define BNX2X_MAX_ENTRIES_PER_PRI	16
 #define BNX2X_MAX_COS			3
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 98b82eb..5caba1f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1460,20 +1460,11 @@ u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 	return __skb_tx_hash(dev, skb, BNX2X_NUM_ETH_QUEUES(bp));
 }
 
+
 void bnx2x_set_num_queues(struct bnx2x *bp)
 {
-	switch (bp->multi_mode) {
-	case ETH_RSS_MODE_DISABLED:
-		bp->num_queues = 1;
-		break;
-	case ETH_RSS_MODE_REGULAR:
-		bp->num_queues = bnx2x_calc_num_queues(bp);
-		break;
-
-	default:
-		bp->num_queues = 1;
-		break;
-	}
+	/* RSS queues */
+	bp->num_queues = bnx2x_calc_num_queues(bp);
 
 #ifdef BCM_CNIC
 	/* override in STORAGE SD mode */
@@ -1572,16 +1563,13 @@ static inline int bnx2x_init_rss_pf(struct bnx2x *bp)
 	u8 ind_table[T_ETH_INDIRECTION_TABLE_SIZE] = {0};
 	u8 num_eth_queues = BNX2X_NUM_ETH_QUEUES(bp);
 
-	/*
-	 * Prepare the inital contents fo the indirection table if RSS is
+	/* Prepare the initial contents fo the indirection table if RSS is
 	 * enabled
 	 */
-	if (bp->multi_mode != ETH_RSS_MODE_DISABLED) {
-		for (i = 0; i < sizeof(ind_table); i++)
-			ind_table[i] =
-				bp->fp->cl_id +
-				ethtool_rxfh_indir_default(i, num_eth_queues);
-	}
+	for (i = 0; i < sizeof(ind_table); i++)
+		ind_table[i] =
+			bp->fp->cl_id +
+			ethtool_rxfh_indir_default(i, num_eth_queues);
 
 	/*
 	 * For 57710 and 57711 SEARCHER configuration (rss_keys) is
@@ -1591,11 +1579,12 @@ static inline int bnx2x_init_rss_pf(struct bnx2x *bp)
 	 * For 57712 and newer on the other hand it's a per-function
 	 * configuration.
 	 */
-	return bnx2x_config_rss_pf(bp, ind_table,
-				   bp->port.pmf || !CHIP_IS_E1x(bp));
+	return bnx2x_config_rss_eth(bp, ind_table,
+				    bp->port.pmf || !CHIP_IS_E1x(bp));
 }
 
-int bnx2x_config_rss_pf(struct bnx2x *bp, u8 *ind_table, bool config_hash)
+int bnx2x_config_rss_pf(struct bnx2x *bp, struct bnx2x_rss_config_obj *rss_obj,
+			u8 *ind_table, bool config_hash)
 {
 	struct bnx2x_config_rss_params params = {NULL};
 	int i;
@@ -1607,52 +1596,29 @@ int bnx2x_config_rss_pf(struct bnx2x *bp, u8 *ind_table, bool config_hash)
 	 *      bp->multi_mode = ETH_RSS_MODE_DISABLED;
 	 */
 
-	params.rss_obj = &bp->rss_conf_obj;
+	params.rss_obj = rss_obj;
 
 	__set_bit(RAMROD_COMP_WAIT, &params.ramrod_flags);
 
-	/* RSS mode */
-	switch (bp->multi_mode) {
-	case ETH_RSS_MODE_DISABLED:
-		__set_bit(BNX2X_RSS_MODE_DISABLED, &params.rss_flags);
-		break;
-	case ETH_RSS_MODE_REGULAR:
-		__set_bit(BNX2X_RSS_MODE_REGULAR, &params.rss_flags);
-		break;
-	case ETH_RSS_MODE_VLAN_PRI:
-		__set_bit(BNX2X_RSS_MODE_VLAN_PRI, &params.rss_flags);
-		break;
-	case ETH_RSS_MODE_E1HOV_PRI:
-		__set_bit(BNX2X_RSS_MODE_E1HOV_PRI, &params.rss_flags);
-		break;
-	case ETH_RSS_MODE_IP_DSCP:
-		__set_bit(BNX2X_RSS_MODE_IP_DSCP, &params.rss_flags);
-		break;
-	default:
-		BNX2X_ERR("Unknown multi_mode: %d\n", bp->multi_mode);
-		return -EINVAL;
-	}
+	__set_bit(BNX2X_RSS_MODE_REGULAR, &params.rss_flags);
 
-	/* If RSS is enabled */
-	if (bp->multi_mode != ETH_RSS_MODE_DISABLED) {
-		/* RSS configuration */
-		__set_bit(BNX2X_RSS_IPV4, &params.rss_flags);
-		__set_bit(BNX2X_RSS_IPV4_TCP, &params.rss_flags);
-		__set_bit(BNX2X_RSS_IPV6, &params.rss_flags);
-		__set_bit(BNX2X_RSS_IPV6_TCP, &params.rss_flags);
+	/* RSS configuration */
+	__set_bit(BNX2X_RSS_IPV4, &params.rss_flags);
+	__set_bit(BNX2X_RSS_IPV4_TCP, &params.rss_flags);
+	__set_bit(BNX2X_RSS_IPV6, &params.rss_flags);
+	__set_bit(BNX2X_RSS_IPV6_TCP, &params.rss_flags);
 
-		/* Hash bits */
-		params.rss_result_mask = MULTI_MASK;
+	/* Hash bits */
+	params.rss_result_mask = MULTI_MASK;
 
-		memcpy(params.ind_table, ind_table, sizeof(params.ind_table));
+	memcpy(params.ind_table, ind_table, sizeof(params.ind_table));
 
-		if (config_hash) {
-			/* RSS keys */
-			for (i = 0; i < sizeof(params.rss_key) / 4; i++)
-				params.rss_key[i] = random32();
+	if (config_hash) {
+		/* RSS keys */
+		for (i = 0; i < sizeof(params.rss_key) / 4; i++)
+			params.rss_key[i] = random32();
 
-			__set_bit(BNX2X_RSS_SET_SRCH, &params.rss_flags);
-		}
+		__set_bit(BNX2X_RSS_SET_SRCH, &params.rss_flags);
 	}
 
 	return bnx2x_config_rss(bp, &params);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 7f3cb81..0c3b2c5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -86,13 +86,15 @@ u32 bnx2x_send_unload_req(struct bnx2x *bp, int unload_mode);
 void bnx2x_send_unload_done(struct bnx2x *bp);
 
 /**
- * bnx2x_config_rss_pf - configure RSS parameters.
+ * bnx2x_config_rss_pf - configure RSS parameters in a PF.
  *
  * @bp:			driver handle
+ * @rss_obj		RSS object to use
  * @ind_table:		indirection table to configure
  * @config_hash:	re-configure RSS hash keys configuration
  */
-int bnx2x_config_rss_pf(struct bnx2x *bp, u8 *ind_table, bool config_hash);
+int bnx2x_config_rss_pf(struct bnx2x *bp, struct bnx2x_rss_config_obj *rss_obj,
+			u8 *ind_table, bool config_hash);
 
 /**
  * bnx2x__init_func_obj - init function object
@@ -967,6 +969,13 @@ static inline int func_by_vn(struct bnx2x *bp, int vn)
 	return 2 * vn + BP_PORT(bp);
 }
 
+static inline int bnx2x_config_rss_eth(struct bnx2x *bp, u8 *ind_table,
+				       bool config_hash)
+{
+	return bnx2x_config_rss_pf(bp, &bp->rss_conf_obj, ind_table,
+				   config_hash);
+}
+
 /**
  * bnx2x_func_start - init function
  *
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 93b5fc4..3c7d0cc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2393,10 +2393,7 @@ static int bnx2x_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 
 static u32 bnx2x_get_rxfh_indir_size(struct net_device *dev)
 {
-	struct bnx2x *bp = netdev_priv(dev);
-
-	return (bp->multi_mode == ETH_RSS_MODE_DISABLED ?
-		0 : T_ETH_INDIRECTION_TABLE_SIZE);
+	return T_ETH_INDIRECTION_TABLE_SIZE;
 }
 
 static int bnx2x_get_rxfh_indir(struct net_device *dev, u32 *indir)
@@ -2442,7 +2439,7 @@ static int bnx2x_set_rxfh_indir(struct net_device *dev, const u32 *indir)
 		ind_table[i] = indir[i] + bp->fp->cl_id;
 	}
 
-	return bnx2x_config_rss_pf(bp, ind_table, false);
+	return bnx2x_config_rss_eth(bp, ind_table, false);
 }
 
 static const struct ethtool_ops bnx2x_ethtool_ops = {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9e03067..eb4fc787 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -91,15 +91,11 @@ MODULE_FIRMWARE(FW_FILE_NAME_E1);
 MODULE_FIRMWARE(FW_FILE_NAME_E1H);
 MODULE_FIRMWARE(FW_FILE_NAME_E2);
 
-static int multi_mode = 1;
-module_param(multi_mode, int, 0);
-MODULE_PARM_DESC(multi_mode, " Multi queue mode "
-			     "(0 Disable; 1 Enable (default))");
 
 int num_queues;
 module_param(num_queues, int, 0);
-MODULE_PARM_DESC(num_queues, " Number of queues for multi_mode=1"
-				" (default is as a number of CPUs)");
+MODULE_PARM_DESC(num_queues,
+		 " Set number of queues (default is as a number of CPUs)");
 
 static int disable_tpa;
 module_param(disable_tpa, int, 0);
@@ -9969,8 +9965,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	if (BP_NOMCP(bp) && (func == 0))
 		dev_err(&bp->pdev->dev, "MCP disabled, must load devices in order!\n");
 
-	bp->multi_mode = multi_mode;
-
 	bp->disable_tpa = disable_tpa;
 
 #ifdef BCM_CNIC
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 3f52fad..fc6dc30 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -4090,12 +4090,6 @@ static int bnx2x_setup_rss(struct bnx2x *bp,
 		rss_mode = ETH_RSS_MODE_DISABLED;
 	else if (test_bit(BNX2X_RSS_MODE_REGULAR, &p->rss_flags))
 		rss_mode = ETH_RSS_MODE_REGULAR;
-	else if (test_bit(BNX2X_RSS_MODE_VLAN_PRI, &p->rss_flags))
-		rss_mode = ETH_RSS_MODE_VLAN_PRI;
-	else if (test_bit(BNX2X_RSS_MODE_E1HOV_PRI, &p->rss_flags))
-		rss_mode = ETH_RSS_MODE_E1HOV_PRI;
-	else if (test_bit(BNX2X_RSS_MODE_IP_DSCP, &p->rss_flags))
-		rss_mode = ETH_RSS_MODE_IP_DSCP;
 
 	data->rss_mode = rss_mode;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 61a7670..dee2f37 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -685,9 +685,6 @@ enum {
 	/* RSS_MODE bits are mutually exclusive */
 	BNX2X_RSS_MODE_DISABLED,
 	BNX2X_RSS_MODE_REGULAR,
-	BNX2X_RSS_MODE_VLAN_PRI,
-	BNX2X_RSS_MODE_E1HOV_PRI,
-	BNX2X_RSS_MODE_IP_DSCP,
 
 	BNX2X_RSS_SET_SRCH, /* Setup searcher, E1x specific flag */
 
-- 
1.7.9.rc2
