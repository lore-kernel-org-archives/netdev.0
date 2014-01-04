From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH v2 5/5] alx: add stats to ethtool
Date: Sat,  4 Jan 2014 17:47:11 +0100
Message-ID: <1388854031-24142-6-git-send-email-sd@queasysnail.net>
References: <1388854031-24142-1-git-send-email-sd@queasysnail.net>
Cc: bhutchings@solarflare.com, johannes@sipsolutions.net,
	netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:47538 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754825AbaADQsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 11:48:51 -0500
In-Reply-To: <1388854031-24142-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ethernet/atheros/alx/ethtool.c | 101 +++++++++++++++++++++++++++++
 drivers/net/ethernet/atheros/alx/hw.h      |   6 +-
 2 files changed, 106 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/alx/ethtool.c b/drivers/net/ethernet/atheros/alx/ethtool.c
index 45b3650..62aea08 100644
--- a/drivers/net/ethernet/atheros/alx/ethtool.c
+++ b/drivers/net/ethernet/atheros/alx/ethtool.c
@@ -46,6 +46,66 @@
 #include "reg.h"
 #include "hw.h"
 
+/* The order of these strings must match the order of the fields in
+ * struct alx_hw_stats
+ * See hw.h
+ */
+static const char alx_gstrings_stats[][ETH_GSTRING_LEN] = {
+	"rx_packets",
+	"rx_bcast_packets",
+	"rx_mcast_packets",
+	"rx_pause_packets",
+	"rx_ctrl_packets",
+	"rx_fcs_errors",
+	"rx_length_errors",
+	"rx_bytes",
+	"rx_runt_packets",
+	"rx_fragments",
+	"rx_64B_or_less_packets",
+	"rx_65B_to_127B_packets",
+	"rx_128B_to_255B_packets",
+	"rx_256B_to_511B_packets",
+	"rx_512B_to_1023B_packets",
+	"rx_1024B_to_1518B_packets",
+	"rx_1519B_to_mtu_packets",
+	"rx_oversize_packets",
+	"rx_rxf_ov_drop_packets",
+	"rx_rrd_ov_drop_packets",
+	"rx_align_errors",
+	"rx_bcast_bytes",
+	"rx_mcast_bytes",
+	"rx_address_errors",
+	"tx_packets",
+	"tx_bcast_packets",
+	"tx_mcast_packets",
+	"tx_pause_packets",
+	"tx_exc_defer_packets",
+	"tx_ctrl_packets",
+	"tx_defer_packets",
+	"tx_bytes",
+	"tx_64B_or_less_packets",
+	"tx_65B_to_127B_packets",
+	"tx_128B_to_255B_packets",
+	"tx_256B_to_511B_packets",
+	"tx_512B_to_1023B_packets",
+	"tx_1024B_to_1518B_packets",
+	"tx_1519B_to_mtu_packets",
+	"tx_single_collision",
+	"tx_multiple_collisions",
+	"tx_late_collision",
+	"tx_abort_collision",
+	"tx_underrun",
+	"tx_trd_eop",
+	"tx_length_errors",
+	"tx_trunc_packets",
+	"tx_bcast_bytes",
+	"tx_mcast_bytes",
+	"tx_update",
+};
+
+#define ALX_NUM_STATS ARRAY_SIZE(alx_gstrings_stats)
+
+
 static u32 alx_get_supported_speeds(struct alx_hw *hw)
 {
 	u32 supported = SUPPORTED_10baseT_Half |
@@ -201,6 +261,44 @@ static void alx_set_msglevel(struct net_device *netdev, u32 data)
 	alx->msg_enable = data;
 }
 
+static void alx_get_ethtool_stats(struct net_device *netdev,
+				  struct ethtool_stats *estats, u64 *data)
+{
+	struct alx_priv *alx = netdev_priv(netdev);
+	struct alx_hw *hw = &alx->hw;
+
+	spin_lock(&alx->stats_lock);
+
+	__alx_update_hw_stats(hw);
+	BUILD_BUG_ON(sizeof(hw->stats) - offsetof(struct alx_hw_stats, rx_ok) <
+		     ALX_NUM_STATS * sizeof(u64));
+	memcpy(data, &hw->stats.rx_ok, ALX_NUM_STATS * sizeof(u64));
+
+	spin_unlock(&alx->stats_lock);
+}
+
+static void alx_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(buf, &alx_gstrings_stats, sizeof(alx_gstrings_stats));
+		break;
+	default:
+		WARN_ON(1);
+		break;
+	}
+}
+
+static int alx_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ALX_NUM_STATS;
+	default:
+		return -EINVAL;
+	}
+}
+
 const struct ethtool_ops alx_ethtool_ops = {
 	.get_settings	= alx_get_settings,
 	.set_settings	= alx_set_settings,
@@ -209,4 +307,7 @@ const struct ethtool_ops alx_ethtool_ops = {
 	.get_msglevel	= alx_get_msglevel,
 	.set_msglevel	= alx_set_msglevel,
 	.get_link	= ethtool_op_get_link,
+	.get_strings	= alx_get_strings,
+	.get_sset_count	= alx_get_sset_count,
+	.get_ethtool_stats	= alx_get_ethtool_stats,
 };
diff --git a/drivers/net/ethernet/atheros/alx/hw.h b/drivers/net/ethernet/atheros/alx/hw.h
index 3780773..de0bdaf 100644
--- a/drivers/net/ethernet/atheros/alx/hw.h
+++ b/drivers/net/ethernet/atheros/alx/hw.h
@@ -381,7 +381,11 @@ struct alx_rrd {
 				 ALX_ISR_RX_Q6 | \
 				 ALX_ISR_RX_Q7)
 
-/* Statistics counters collected by the MAC */
+/* Statistics counters collected by the MAC
+ *
+ * The order of the fields must match the strings in alx_gstrings_stats
+ * See ethtool.c
+ */
 struct alx_hw_stats {
 	/* rx */
 	u64 rx_ok;
-- 
1.8.5.2
