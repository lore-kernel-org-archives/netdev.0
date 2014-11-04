From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 08/12] amd-xgbe: Add receive side scaling
 ethtool support
Date: Tue, 4 Nov 2014 16:07:23 -0600
Message-ID: <20141104220723.24738.68077.stgit@tlendack-t1.amdoffice.net>
References: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0106.outbound.protection.outlook.com ([157.56.110.106]:26336
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751971AbaKDWH2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:07:28 -0500
In-Reply-To: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for ethtool receive side scaling (RSS) commands.
Support is added to get/set the RSS hash key and the RSS lookup table.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |   20 +++++++
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   74 ++++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    2 +
 3 files changed, 96 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 551794c..7daa2cd 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -419,6 +419,24 @@ static int xgbe_write_rss_lookup_table(struct xgbe_prv_data *pdata)
 	return 0;
 }
 
+static int xgbe_set_rss_hash_key(struct xgbe_prv_data *pdata, const u8 *key)
+{
+	memcpy(pdata->rss_key, key, sizeof(pdata->rss_key));
+
+	return xgbe_write_rss_hash_key(pdata);
+}
+
+static int xgbe_set_rss_lookup_table(struct xgbe_prv_data *pdata,
+				     const u32 *table)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(pdata->rss_table); i++)
+		XGMAC_SET_BITS(pdata->rss_table[i], MAC_RSSDR, DMCH, table[i]);
+
+	return xgbe_write_rss_lookup_table(pdata);
+}
+
 static int xgbe_enable_rss(struct xgbe_prv_data *pdata)
 {
 	int ret;
@@ -2759,6 +2777,8 @@ void xgbe_init_function_ptrs_dev(struct xgbe_hw_if *hw_if)
 	/* For Receive Side Scaling */
 	hw_if->enable_rss = xgbe_enable_rss;
 	hw_if->disable_rss = xgbe_disable_rss;
+	hw_if->set_rss_hash_key = xgbe_set_rss_hash_key;
+	hw_if->set_rss_lookup_table = xgbe_set_rss_lookup_table;
 
 	DBGPR("<--xgbe_init_function_ptrs\n");
 }
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 47022fb..95d4453 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -481,6 +481,75 @@ static int xgbe_set_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+static int xgbe_get_rxnfc(struct net_device *netdev,
+			  struct ethtool_rxnfc *rxnfc, u32 *rule_locs)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	switch (rxnfc->cmd) {
+	case ETHTOOL_GRXRINGS:
+		rxnfc->data = pdata->rx_ring_count;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static u32 xgbe_get_rxfh_key_size(struct net_device *netdev)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	return sizeof(pdata->rss_key);
+}
+
+static u32 xgbe_get_rxfh_indir_size(struct net_device *netdev)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	return ARRAY_SIZE(pdata->rss_table);
+}
+
+static int xgbe_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	unsigned int i;
+
+	if (indir) {
+		for (i = 0; i < ARRAY_SIZE(pdata->rss_table); i++)
+			indir[i] = XGMAC_GET_BITS(pdata->rss_table[i],
+						  MAC_RSSDR, DMCH);
+	}
+
+	if (key)
+		memcpy(key, pdata->rss_key, sizeof(pdata->rss_key));
+
+	return 0;
+}
+
+static int xgbe_set_rxfh(struct net_device *netdev, const u32 *indir,
+			 const u8 *key)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	unsigned int ret;
+
+	if (indir) {
+		ret = hw_if->set_rss_lookup_table(pdata, indir);
+		if (ret)
+			return ret;
+	}
+
+	if (key) {
+		ret = hw_if->set_rss_hash_key(pdata, key);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
 static int xgbe_get_ts_info(struct net_device *netdev,
 			    struct ethtool_ts_info *ts_info)
 {
@@ -526,6 +595,11 @@ static const struct ethtool_ops xgbe_ethtool_ops = {
 	.get_strings = xgbe_get_strings,
 	.get_ethtool_stats = xgbe_get_ethtool_stats,
 	.get_sset_count = xgbe_get_sset_count,
+	.get_rxnfc = xgbe_get_rxnfc,
+	.get_rxfh_key_size = xgbe_get_rxfh_key_size,
+	.get_rxfh_indir_size = xgbe_get_rxfh_indir_size,
+	.get_rxfh = xgbe_get_rxfh,
+	.set_rxfh = xgbe_set_rxfh,
 	.get_ts_info = xgbe_get_ts_info,
 };
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 2ac4f17..aa8da9f 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -557,6 +557,8 @@ struct xgbe_hw_if {
 	/* For Receive Side Scaling */
 	int (*enable_rss)(struct xgbe_prv_data *);
 	int (*disable_rss)(struct xgbe_prv_data *);
+	int (*set_rss_hash_key)(struct xgbe_prv_data *, const u8 *);
+	int (*set_rss_lookup_table)(struct xgbe_prv_data *, const u32 *);
 };
 
 struct xgbe_desc_if {
