From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 3/3] enic: add stats for dma mapping error
Date: Wed, 24 Dec 2014 15:59:38 +0530
Message-ID: <1419416978-1008-4-git-send-email-_govind@gmx.com>
References: <1419416978-1008-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, sassmann@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:49164 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650AbaLXKaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Dec 2014 05:30:46 -0500
In-Reply-To: <1419416978-1008-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds generic statistics for enic. As of now dma_map_error is the only
member. dma_map_erro is incremented every time dma maping error happens.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h         |  2 ++
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 19 ++++++++++++++++++-
 drivers/net/ethernet/cisco/enic/vnic_stats.h   |  5 +++++
 3 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index b2ea35a..d2a1035 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -188,6 +188,7 @@ struct enic {
 	struct enic_rfs_flw_tbl rfs_h;
 	u32 rx_copybreak;
 	u8 rss_key[ENIC_RSS_LEN];
+	struct vnic_gen_stats gen_stats;
 };
 
 static inline struct device *enic_get_dev(struct enic *enic)
@@ -247,6 +248,7 @@ static inline int enic_dma_map_check(struct enic *enic, dma_addr_t dma_addr)
 	if (unlikely(pci_dma_mapping_error(enic->pdev, dma_addr))) {
 		net_warn_ratelimited("%s: PCI dma mapping failed!\n",
 				     enic->netdev->name);
+		enic->gen_stats.dma_map_error++;
 
 		return -ENOMEM;
 	}
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index eba1eb8..0c396c1 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -24,6 +24,7 @@
 #include "enic_dev.h"
 #include "enic_clsf.h"
 #include "vnic_rss.h"
+#include "vnic_stats.h"
 
 struct enic_stat {
 	char name[ETH_GSTRING_LEN];
@@ -40,6 +41,11 @@ struct enic_stat {
 	.index = offsetof(struct vnic_rx_stats, stat) / sizeof(u64) \
 }
 
+#define ENIC_GEN_STAT(stat) { \
+	.name = #stat, \
+	.index = offsetof(struct vnic_gen_stats, stat) / sizeof(u64)\
+}
+
 static const struct enic_stat enic_tx_stats[] = {
 	ENIC_TX_STAT(tx_frames_ok),
 	ENIC_TX_STAT(tx_unicast_frames_ok),
@@ -78,8 +84,13 @@ static const struct enic_stat enic_rx_stats[] = {
 	ENIC_RX_STAT(rx_frames_to_max),
 };
 
+static const struct enic_stat enic_gen_stats[] = {
+	ENIC_GEN_STAT(dma_map_error),
+};
+
 static const unsigned int enic_n_tx_stats = ARRAY_SIZE(enic_tx_stats);
 static const unsigned int enic_n_rx_stats = ARRAY_SIZE(enic_rx_stats);
+static const unsigned int enic_n_gen_stats = ARRAY_SIZE(enic_gen_stats);
 
 void enic_intr_coal_set_rx(struct enic *enic, u32 timer)
 {
@@ -146,6 +157,10 @@ static void enic_get_strings(struct net_device *netdev, u32 stringset,
 			memcpy(data, enic_rx_stats[i].name, ETH_GSTRING_LEN);
 			data += ETH_GSTRING_LEN;
 		}
+		for (i = 0; i < enic_n_gen_stats; i++) {
+			memcpy(data, enic_gen_stats[i].name, ETH_GSTRING_LEN);
+			data += ETH_GSTRING_LEN;
+		}
 		break;
 	}
 }
@@ -154,7 +169,7 @@ static int enic_get_sset_count(struct net_device *netdev, int sset)
 {
 	switch (sset) {
 	case ETH_SS_STATS:
-		return enic_n_tx_stats + enic_n_rx_stats;
+		return enic_n_tx_stats + enic_n_rx_stats + enic_n_gen_stats;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -173,6 +188,8 @@ static void enic_get_ethtool_stats(struct net_device *netdev,
 		*(data++) = ((u64 *)&vstats->tx)[enic_tx_stats[i].index];
 	for (i = 0; i < enic_n_rx_stats; i++)
 		*(data++) = ((u64 *)&vstats->rx)[enic_rx_stats[i].index];
+	for (i = 0; i < enic_n_gen_stats; i++)
+		*(data++) = ((u64 *)&enic->gen_stats)[enic_gen_stats[i].index];
 }
 
 static u32 enic_get_msglevel(struct net_device *netdev)
diff --git a/drivers/net/ethernet/cisco/enic/vnic_stats.h b/drivers/net/ethernet/cisco/enic/vnic_stats.h
index 77750ec..74c81ed 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_stats.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_stats.h
@@ -62,6 +62,11 @@ struct vnic_rx_stats {
 	u64 rsvd[16];
 };
 
+/* Generic statistics */
+struct vnic_gen_stats {
+	u64 dma_map_error;
+};
+
 struct vnic_stats {
 	struct vnic_tx_stats tx;
 	struct vnic_rx_stats rx;
-- 
2.2.1
