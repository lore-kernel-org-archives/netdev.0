From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/4] net: Convert ethtool {get_stats,self_test}_count() ops
	to get_sset_count()
Date: Thu, 01 Oct 2009 22:58:24 +0100
Message-ID: <1254432754.2735.27.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: nChien Tung <chien.tin.tung@intel.com>,
	Faisal Latif <faisal.latif@intel.com>,
	Subbu Seetharaman <subbus@serverengines.com>,
	Sathya Perla <sathyap@serverengines.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	etdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:4146 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbZJAV6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:58:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These string query operations were supposed to be replaced by the
generic get_sset_count() starting in 2007.  Convert the remaining
implementations.

Also remove calls to these operations to initialise drvinfo->n_stats.
The ethtool core code already does that.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/infiniband/hw/nes/nes_nic.c |   12 ++++---
 drivers/net/benet/be_ethtool.c      |   11 +++++--
 drivers/net/bnx2x_main.c            |   60 ++++++++++++++++++-----------------
 drivers/net/ibm_newemac/core.c      |   10 +++--
 drivers/net/igbvf/ethtool.c         |   25 +++++++-------
 drivers/net/niu.c                   |    7 +++-
 6 files changed, 70 insertions(+), 55 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 538e409..1388409 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1080,11 +1080,14 @@ static int nes_netdev_set_rx_csum(struct net_device *netdev, u32 enable)
 

 /**
- * nes_netdev_get_stats_count
+ * nes_netdev_get_sset_count
  */
-static int nes_netdev_get_stats_count(struct net_device *netdev)
+static int nes_netdev_get_sset_count(struct net_device *netdev, int stringset)
 {
-	return NES_ETHTOOL_STAT_COUNT;
+	if (stringset == ETH_SS_STATS)
+		return NES_ETHTOOL_STAT_COUNT;
+	else
+		return -EINVAL;
 }
 

@@ -1264,7 +1267,6 @@ static void nes_netdev_get_drvinfo(struct net_device *netdev,
 	sprintf(drvinfo->fw_version, "%u.%u", nesadapter->firmware_version>>16,
 				nesadapter->firmware_version & 0x000000ff);
 	strcpy(drvinfo->version, DRV_VERSION);
-	drvinfo->n_stats = nes_netdev_get_stats_count(netdev);
 	drvinfo->testinfo_len = 0;
 	drvinfo->eedump_len = 0;
 	drvinfo->regdump_len = 0;
@@ -1516,7 +1518,7 @@ static const struct ethtool_ops nes_ethtool_ops = {
 	.get_rx_csum = nes_netdev_get_rx_csum,
 	.get_sg = ethtool_op_get_sg,
 	.get_strings = nes_netdev_get_strings,
-	.get_stats_count = nes_netdev_get_stats_count,
+	.get_sset_count = nes_netdev_get_sset_count,
 	.get_ethtool_stats = nes_netdev_get_ethtool_stats,
 	.get_drvinfo = nes_netdev_get_drvinfo,
 	.get_coalesce = nes_netdev_get_coalesce,
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 11445df..851543a 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -281,9 +281,14 @@ be_get_stat_strings(struct net_device *netdev, uint32_t stringset,
 	}
 }
 
-static int be_get_stats_count(struct net_device *netdev)
+static int be_get_sset_count(struct net_device *netdev, int stringset)
 {
-	return ETHTOOL_STATS_NUM;
+	switch (stringset) {
+	case ETH_SS_STATS:
+		return ETHTOOL_STATS_NUM;
+	default:
+		return -EINVAL;
+	}
 }
 
 static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
@@ -364,7 +369,7 @@ const struct ethtool_ops be_ethtool_ops = {
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = ethtool_op_set_tso,
 	.get_strings = be_get_stat_strings,
-	.get_stats_count = be_get_stats_count,
+	.get_sset_count = be_get_sset_count,
 	.get_ethtool_stats = be_get_ethtool_stats,
 	.flash_device = be_do_flash,
 };
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 20f0ed9..c0abfc4 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9818,11 +9818,6 @@ static const struct {
 	{ "idle check (online)" }
 };
 
-static int bnx2x_self_test_count(struct net_device *dev)
-{
-	return BNX2X_NUM_TESTS;
-}
-
 static int bnx2x_test_registers(struct bnx2x *bp)
 {
 	int idx, i, rc = -ENODEV;
@@ -10436,6 +10431,36 @@ static const struct {
 #define IS_E1HMF_MODE_STAT(bp) \
 			(IS_E1HMF(bp) && !(bp->msglevel & BNX2X_MSG_STATS))
 
+static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	int i, num_stats;
+
+	switch(stringset) {
+	case ETH_SS_STATS:
+		if (is_multi(bp)) {
+			num_stats = BNX2X_NUM_Q_STATS * bp->num_rx_queues;
+			if (!IS_E1HMF_MODE_STAT(bp))
+				num_stats += BNX2X_NUM_STATS;
+		} else {
+			if (IS_E1HMF_MODE_STAT(bp)) {
+				num_stats = 0;
+				for (i = 0; i < BNX2X_NUM_STATS; i++)
+					if (IS_FUNC_STAT(i))
+						num_stats++;
+			} else
+				num_stats = BNX2X_NUM_STATS;
+		}
+		return num_stats;
+
+	case ETH_SS_TEST:
+		return BNX2X_NUM_TESTS;
+
+	default:
+		return -EINVAL;
+	}
+}
+
 static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 {
 	struct bnx2x *bp = netdev_priv(dev);
@@ -10473,28 +10498,6 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 	}
 }
 
-static int bnx2x_get_stats_count(struct net_device *dev)
-{
-	struct bnx2x *bp = netdev_priv(dev);
-	int i, num_stats;
-
-	if (is_multi(bp)) {
-		num_stats = BNX2X_NUM_Q_STATS * bp->num_rx_queues;
-		if (!IS_E1HMF_MODE_STAT(bp))
-			num_stats += BNX2X_NUM_STATS;
-	} else {
-		if (IS_E1HMF_MODE_STAT(bp)) {
-			num_stats = 0;
-			for (i = 0; i < BNX2X_NUM_STATS; i++)
-				if (IS_FUNC_STAT(i))
-					num_stats++;
-		} else
-			num_stats = BNX2X_NUM_STATS;
-	}
-
-	return num_stats;
-}
-
 static void bnx2x_get_ethtool_stats(struct net_device *dev,
 				    struct ethtool_stats *stats, u64 *buf)
 {
@@ -10637,11 +10640,10 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.set_sg			= ethtool_op_set_sg,
 	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= bnx2x_set_tso,
-	.self_test_count	= bnx2x_self_test_count,
 	.self_test		= bnx2x_self_test,
+	.get_sset_count		= bnx2x_get_sset_count,
 	.get_strings		= bnx2x_get_strings,
 	.phys_id		= bnx2x_phys_id,
-	.get_stats_count	= bnx2x_get_stats_count,
 	.get_ethtool_stats	= bnx2x_get_ethtool_stats,
 };
 
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 1d7d7fe..638a893 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2145,9 +2145,12 @@ static int emac_ethtool_nway_reset(struct net_device *ndev)
 	return res;
 }
 
-static int emac_ethtool_get_stats_count(struct net_device *ndev)
+static int emac_ethtool_get_sset_count(struct net_device *ndev, int stringset)
 {
-	return EMAC_ETHTOOL_STATS_COUNT;
+	if (stringset == ETH_SS_STATS)
+		return EMAC_ETHTOOL_STATS_COUNT;
+	else
+		return -EINVAL;
 }
 
 static void emac_ethtool_get_strings(struct net_device *ndev, u32 stringset,
@@ -2178,7 +2181,6 @@ static void emac_ethtool_get_drvinfo(struct net_device *ndev,
 	info->fw_version[0] = '\0';
 	sprintf(info->bus_info, "PPC 4xx EMAC-%d %s",
 		dev->cell_index, dev->ofdev->node->full_name);
-	info->n_stats = emac_ethtool_get_stats_count(ndev);
 	info->regdump_len = emac_ethtool_get_regs_len(ndev);
 }
 
@@ -2198,7 +2200,7 @@ static const struct ethtool_ops emac_ethtool_ops = {
 	.get_rx_csum = emac_ethtool_get_rx_csum,
 
 	.get_strings = emac_ethtool_get_strings,
-	.get_stats_count = emac_ethtool_get_stats_count,
+	.get_sset_count = emac_ethtool_get_sset_count,
 	.get_ethtool_stats = emac_ethtool_get_ethtool_stats,
 
 	.get_link = ethtool_op_get_link,
diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index ee17a09..bc606f8 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -363,16 +363,6 @@ static int igbvf_link_test(struct igbvf_adapter *adapter, u64 *data)
 	return *data;
 }
 
-static int igbvf_get_self_test_count(struct net_device *netdev)
-{
-	return IGBVF_TEST_LEN;
-}
-
-static int igbvf_get_stats_count(struct net_device *netdev)
-{
-	return IGBVF_GLOBAL_STATS_LEN;
-}
-
 static void igbvf_diag_test(struct net_device *netdev,
                             struct ethtool_test *eth_test, u64 *data)
 {
@@ -480,6 +470,18 @@ static void igbvf_get_ethtool_stats(struct net_device *netdev,
 
 }
 
+static int igbvf_get_sset_count(struct net_device *dev, int stringset)
+{
+	switch(stringset) {
+	case ETH_SS_TEST:
+		return IGBVF_TEST_LEN;
+	case ETH_SS_STATS:
+		return IGBVF_GLOBAL_STATS_LEN;
+	default:
+		return -EINVAL;
+	}
+}
+
 static void igbvf_get_strings(struct net_device *netdev, u32 stringset,
                               u8 *data)
 {
@@ -528,11 +530,10 @@ static const struct ethtool_ops igbvf_ethtool_ops = {
 	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= igbvf_set_tso,
 	.self_test		= igbvf_diag_test,
+	.get_sset_count		= igbvf_get_sset_count,
 	.get_strings		= igbvf_get_strings,
 	.phys_id		= igbvf_phys_id,
 	.get_ethtool_stats	= igbvf_get_ethtool_stats,
-	.self_test_count	= igbvf_get_self_test_count,
-	.get_stats_count	= igbvf_get_stats_count,
 	.get_coalesce		= igbvf_get_coalesce,
 	.set_coalesce		= igbvf_set_coalesce,
 };
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 76cc261..98d9b75 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -7855,10 +7855,13 @@ static void niu_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	}
 }
 
-static int niu_get_stats_count(struct net_device *dev)
+static int niu_get_sset_count(struct net_device *dev, int stringset)
 {
 	struct niu *np = netdev_priv(dev);
 
+	if (stringset != ETH_SS_STATS)
+		return -EINVAL;
+
 	return ((np->flags & NIU_FLAGS_XMAC ?
 		 NUM_XMAC_STAT_KEYS :
 		 NUM_BMAC_STAT_KEYS) +
@@ -7978,7 +7981,7 @@ static const struct ethtool_ops niu_ethtool_ops = {
 	.get_settings		= niu_get_settings,
 	.set_settings		= niu_set_settings,
 	.get_strings		= niu_get_strings,
-	.get_stats_count	= niu_get_stats_count,
+	.get_sset_count		= niu_get_sset_count,
 	.get_ethtool_stats	= niu_get_ethtool_stats,
 	.phys_id		= niu_phys_id,
 	.get_rxnfc		= niu_get_nfc,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

