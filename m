From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2] enic: add support for set/get rss hash key
Date: Wed, 10 Dec 2014 13:40:23 +0530
Message-ID: <1418199023-12451-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:61001 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754357AbaLJIKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 03:10:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for setting/getting rss hash key using ethtool.

v2:
respin patch to support RSS hash function changes.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h         |  2 ++
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 38 ++++++++++++++++++++++++++
 drivers/net/ethernet/cisco/enic/enic_main.c    | 13 ++++++---
 3 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 5ba5ad0..25c4d88 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -187,6 +187,7 @@ struct enic {
 	unsigned int cq_count;
 	struct enic_rfs_flw_tbl rfs_h;
 	u32 rx_copybreak;
+	u8 rss_key[ENIC_RSS_LEN];
 };
 
 static inline struct device *enic_get_dev(struct enic *enic)
@@ -246,5 +247,6 @@ int enic_sriov_enabled(struct enic *enic);
 int enic_is_valid_vf(struct enic *enic, int vf);
 int enic_is_dynamic(struct enic *enic);
 void enic_set_ethtool_ops(struct net_device *netdev);
+int __enic_set_rsskey(struct enic *enic);
 
 #endif /* _ENIC_H_ */
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 85173d6..eba1eb8 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -23,6 +23,7 @@
 #include "enic.h"
 #include "enic_dev.h"
 #include "enic_clsf.h"
+#include "vnic_rss.h"
 
 struct enic_stat {
 	char name[ETH_GSTRING_LEN];
@@ -416,6 +417,40 @@ static int enic_set_tunable(struct net_device *dev,
 	return ret;
 }
 
+static u32 enic_get_rxfh_key_size(struct net_device *netdev)
+{
+	return ENIC_RSS_LEN;
+}
+
+static int enic_get_rxfh(struct net_device *netdev, u32 *indir, u8 *hkey,
+			 u8 *hfunc)
+{
+	struct enic *enic = netdev_priv(netdev);
+
+	if (hkey)
+		memcpy(hkey, enic->rss_key, ENIC_RSS_LEN);
+
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_TOP;
+
+	return 0;
+}
+
+static int enic_set_rxfh(struct net_device *netdev, const u32 *indir,
+			 const u8 *hkey, const u8 hfunc)
+{
+	struct enic *enic = netdev_priv(netdev);
+
+	if ((hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP) ||
+	    indir)
+		return -EINVAL;
+
+	if (hkey)
+		memcpy(enic->rss_key, hkey, ENIC_RSS_LEN);
+
+	return __enic_set_rsskey(enic);
+}
+
 static const struct ethtool_ops enic_ethtool_ops = {
 	.get_settings = enic_get_settings,
 	.get_drvinfo = enic_get_drvinfo,
@@ -430,6 +465,9 @@ static const struct ethtool_ops enic_ethtool_ops = {
 	.get_rxnfc = enic_get_rxnfc,
 	.get_tunable = enic_get_tunable,
 	.set_tunable = enic_set_tunable,
+	.get_rxfh_key_size = enic_get_rxfh_key_size,
+	.get_rxfh = enic_get_rxfh,
+	.set_rxfh = enic_set_rxfh,
 };
 
 void enic_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 86ee350..868d0f6 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1888,11 +1888,10 @@ static int enic_dev_hang_reset(struct enic *enic)
 	return err;
 }
 
-static int enic_set_rsskey(struct enic *enic)
+int __enic_set_rsskey(struct enic *enic)
 {
 	union vnic_rss_key *rss_key_buf_va;
 	dma_addr_t rss_key_buf_pa;
-	u8 rss_key[ENIC_RSS_LEN];
 	int i, kidx, bidx, err;
 
 	rss_key_buf_va = pci_zalloc_consistent(enic->pdev,
@@ -1901,11 +1900,10 @@ static int enic_set_rsskey(struct enic *enic)
 	if (!rss_key_buf_va)
 		return -ENOMEM;
 
-	netdev_rss_key_fill(rss_key, ENIC_RSS_LEN);
 	for (i = 0; i < ENIC_RSS_LEN; i++) {
 		kidx = i / ENIC_RSS_BYTES_PER_KEY;
 		bidx = i % ENIC_RSS_BYTES_PER_KEY;
-		rss_key_buf_va->key[kidx].b[bidx] = rss_key[i];
+		rss_key_buf_va->key[kidx].b[bidx] = enic->rss_key[i];
 	}
 	spin_lock_bh(&enic->devcmd_lock);
 	err = enic_set_rss_key(enic,
@@ -1919,6 +1917,13 @@ static int enic_set_rsskey(struct enic *enic)
 	return err;
 }
 
+static int enic_set_rsskey(struct enic *enic)
+{
+	netdev_rss_key_fill(enic->rss_key, ENIC_RSS_LEN);
+
+	return __enic_set_rsskey(enic);
+}
+
 static int enic_set_rsscpu(struct enic *enic, u8 rss_hash_bits)
 {
 	dma_addr_t rss_cpu_buf_pa;
-- 
2.1.0
