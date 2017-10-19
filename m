From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net 2/7] net: aquantia: Add queue restarts stats counter
Date: Thu, 19 Oct 2017 18:23:54 +0300
Message-ID: <1025f38eaa7611b283745cb9b1e2760b6e84a829.1508159232.git.igor.russkikh@aquantia.com>
References: <cover.1508159232.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0070.outbound.protection.outlook.com ([104.47.32.70]:53504
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752007AbdJSPYj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 11:24:39 -0400
In-Reply-To: <cover.1508159232.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Queue stat strings are cleaned up, duplicate stat name strings removed,
queue restarts counter added

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Signed-off-by: Igor Russkikh <igor.russkikh@aquantia.com>
---
 .../net/ethernet/aquantia/atlantic/aq_ethtool.c    | 92 ++++++++--------------
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c    |  3 +
 2 files changed, 37 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c b/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
index a761e91..3eab408 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c
@@ -56,10 +56,6 @@ aq_ethtool_set_link_ksettings(struct net_device *ndev,
 	return aq_nic_set_link_ksettings(aq_nic, cmd);
 }
 
-/* there "5U" is number of queue[#] stats lines (InPackets+...+InErrors) */
-static const unsigned int aq_ethtool_stat_queue_lines = 5U;
-static const unsigned int aq_ethtool_stat_queue_chars =
-	5U * ETH_GSTRING_LEN;
 static const char aq_ethtool_stat_names[][ETH_GSTRING_LEN] = {
 	"InPackets",
 	"InUCast",
@@ -83,56 +79,26 @@ static const char aq_ethtool_stat_names[][ETH_GSTRING_LEN] = {
 	"InOctetsDma",
 	"OutOctetsDma",
 	"InDroppedDma",
-	"Queue[0] InPackets",
-	"Queue[0] OutPackets",
-	"Queue[0] InJumboPackets",
-	"Queue[0] InLroPackets",
-	"Queue[0] InErrors",
-	"Queue[1] InPackets",
-	"Queue[1] OutPackets",
-	"Queue[1] InJumboPackets",
-	"Queue[1] InLroPackets",
-	"Queue[1] InErrors",
-	"Queue[2] InPackets",
-	"Queue[2] OutPackets",
-	"Queue[2] InJumboPackets",
-	"Queue[2] InLroPackets",
-	"Queue[2] InErrors",
-	"Queue[3] InPackets",
-	"Queue[3] OutPackets",
-	"Queue[3] InJumboPackets",
-	"Queue[3] InLroPackets",
-	"Queue[3] InErrors",
-	"Queue[4] InPackets",
-	"Queue[4] OutPackets",
-	"Queue[4] InJumboPackets",
-	"Queue[4] InLroPackets",
-	"Queue[4] InErrors",
-	"Queue[5] InPackets",
-	"Queue[5] OutPackets",
-	"Queue[5] InJumboPackets",
-	"Queue[5] InLroPackets",
-	"Queue[5] InErrors",
-	"Queue[6] InPackets",
-	"Queue[6] OutPackets",
-	"Queue[6] InJumboPackets",
-	"Queue[6] InLroPackets",
-	"Queue[6] InErrors",
-	"Queue[7] InPackets",
-	"Queue[7] OutPackets",
-	"Queue[7] InJumboPackets",
-	"Queue[7] InLroPackets",
-	"Queue[7] InErrors",
+};
+
+static const char aq_ethtool_queue_stat_names[][ETH_GSTRING_LEN] = {
+	"Queue[%d] InPackets",
+	"Queue[%d] OutPackets",
+	"Queue[%d] Restarts",
+	"Queue[%d] InJumboPackets",
+	"Queue[%d] InLroPackets",
+	"Queue[%d] InErrors",
 };
 
 static void aq_ethtool_stats(struct net_device *ndev,
 			     struct ethtool_stats *stats, u64 *data)
 {
 	struct aq_nic_s *aq_nic = netdev_priv(ndev);
+	struct aq_nic_cfg_s *cfg = aq_nic_get_cfg(aq_nic);
 
-/* ASSERT: Need add lines to aq_ethtool_stat_names if AQ_CFG_VECS_MAX > 8 */
-	BUILD_BUG_ON(AQ_CFG_VECS_MAX > 8);
-	memset(data, 0, ARRAY_SIZE(aq_ethtool_stat_names) * sizeof(u64));
+	memset(data, 0, (ARRAY_SIZE(aq_ethtool_stat_names) +
+				ARRAY_SIZE(aq_ethtool_queue_stat_names) *
+				cfg->vecs) * sizeof(u64));
 	aq_nic_get_stats(aq_nic, data);
 }
 
@@ -154,8 +120,8 @@ static void aq_ethtool_get_drvinfo(struct net_device *ndev,
 
 	strlcpy(drvinfo->bus_info, pdev ? pci_name(pdev) : "",
 		sizeof(drvinfo->bus_info));
-	drvinfo->n_stats = ARRAY_SIZE(aq_ethtool_stat_names) -
-		(AQ_CFG_VECS_MAX - cfg->vecs) * aq_ethtool_stat_queue_lines;
+	drvinfo->n_stats = ARRAY_SIZE(aq_ethtool_stat_names) +
+		cfg->vecs * ARRAY_SIZE(aq_ethtool_queue_stat_names);
 	drvinfo->testinfo_len = 0;
 	drvinfo->regdump_len = regs_count;
 	drvinfo->eedump_len = 0;
@@ -164,14 +130,25 @@ static void aq_ethtool_get_drvinfo(struct net_device *ndev,
 static void aq_ethtool_get_strings(struct net_device *ndev,
 				   u32 stringset, u8 *data)
 {
+	int i, si;
 	struct aq_nic_s *aq_nic = netdev_priv(ndev);
 	struct aq_nic_cfg_s *cfg = aq_nic_get_cfg(aq_nic);
-
-	if (stringset == ETH_SS_STATS)
-		memcpy(data, *aq_ethtool_stat_names,
-		       sizeof(aq_ethtool_stat_names) -
-		       (AQ_CFG_VECS_MAX - cfg->vecs) *
-		       aq_ethtool_stat_queue_chars);
+	u8 *p = data;
+
+	if (stringset == ETH_SS_STATS) {
+		memcpy(p, *aq_ethtool_stat_names,
+		       sizeof(aq_ethtool_stat_names));
+		p = p + sizeof(aq_ethtool_stat_names);
+		for (i = 0; i < cfg->vecs; i++) {
+			for (si = 0;
+				si < ARRAY_SIZE(aq_ethtool_queue_stat_names);
+				si++) {
+				snprintf(p, ETH_GSTRING_LEN,
+					 aq_ethtool_queue_stat_names[si], i);
+				p += ETH_GSTRING_LEN;
+			}
+		}
+	}
 }
 
 static int aq_ethtool_get_sset_count(struct net_device *ndev, int stringset)
@@ -182,9 +159,8 @@ static int aq_ethtool_get_sset_count(struct net_device *ndev, int stringset)
 
 	switch (stringset) {
 	case ETH_SS_STATS:
-		ret = ARRAY_SIZE(aq_ethtool_stat_names) -
-			(AQ_CFG_VECS_MAX - cfg->vecs) *
-			aq_ethtool_stat_queue_lines;
+		ret = ARRAY_SIZE(aq_ethtool_stat_names) +
+			cfg->vecs * ARRAY_SIZE(aq_ethtool_queue_stat_names);
 		break;
 	default:
 		ret = -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_vec.c b/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
index 305ff8f..5fecc9a 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
@@ -373,8 +373,11 @@ int aq_vec_get_sw_stats(struct aq_vec_s *self, u64 *data, unsigned int *p_count)
 	memset(&stats_tx, 0U, sizeof(struct aq_ring_stats_tx_s));
 	aq_vec_add_stats(self, &stats_rx, &stats_tx);
 
+	/* This data should mimic aq_ethtool_queue_stat_names structure
+	 */
 	data[count] += stats_rx.packets;
 	data[++count] += stats_tx.packets;
+	data[++count] += stats_tx.queue_restarts;
 	data[++count] += stats_rx.jumbo_packets;
 	data[++count] += stats_rx.lro_packets;
 	data[++count] += stats_rx.errors;
-- 
2.7.4
