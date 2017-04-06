From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 18/19] batman-adv: Group ethtool related code together
Date: Thu,  6 Apr 2017 16:07:40 +0200
Message-ID: <20170406140741.30745-19-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:33014 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935065AbdDFOHz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:55 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The ethtool code was spread in soft-interface.c. This makes reading the
code and working on it unnecessary complicated. Having everything in a
common place next to the other code which references it, makes it slightly
easier.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Acked-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/soft-interface.c | 191 +++++++++++++++++++---------------------
 1 file changed, 92 insertions(+), 99 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 6f22b1283c92..f33bee08bd99 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -64,21 +64,6 @@
 #include "sysfs.h"
 #include "translation-table.h"
 
-static void batadv_get_drvinfo(struct net_device *dev,
-			       struct ethtool_drvinfo *info);
-static void batadv_get_strings(struct net_device *dev, u32 stringset, u8 *data);
-static void batadv_get_ethtool_stats(struct net_device *dev,
-				     struct ethtool_stats *stats, u64 *data);
-static int batadv_get_sset_count(struct net_device *dev, int stringset);
-
-static const struct ethtool_ops batadv_ethtool_ops = {
-	.get_drvinfo = batadv_get_drvinfo,
-	.get_link = ethtool_op_get_link,
-	.get_strings = batadv_get_strings,
-	.get_ethtool_stats = batadv_get_ethtool_stats,
-	.get_sset_count = batadv_get_sset_count,
-};
-
 int batadv_skb_head_push(struct sk_buff *skb, unsigned int len)
 {
 	int result;
@@ -944,6 +929,98 @@ static const struct net_device_ops batadv_netdev_ops = {
 	.ndo_del_slave = batadv_softif_slave_del,
 };
 
+static void batadv_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, "B.A.T.M.A.N. advanced", sizeof(info->driver));
+	strlcpy(info->version, BATADV_SOURCE_VERSION, sizeof(info->version));
+	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
+	strlcpy(info->bus_info, "batman", sizeof(info->bus_info));
+}
+
+/* Inspired by drivers/net/ethernet/dlink/sundance.c:1702
+ * Declare each description string in struct.name[] to get fixed sized buffer
+ * and compile time checking for strings longer than ETH_GSTRING_LEN.
+ */
+static const struct {
+	const char name[ETH_GSTRING_LEN];
+} batadv_counters_strings[] = {
+	{ "tx" },
+	{ "tx_bytes" },
+	{ "tx_dropped" },
+	{ "rx" },
+	{ "rx_bytes" },
+	{ "forward" },
+	{ "forward_bytes" },
+	{ "mgmt_tx" },
+	{ "mgmt_tx_bytes" },
+	{ "mgmt_rx" },
+	{ "mgmt_rx_bytes" },
+	{ "frag_tx" },
+	{ "frag_tx_bytes" },
+	{ "frag_rx" },
+	{ "frag_rx_bytes" },
+	{ "frag_fwd" },
+	{ "frag_fwd_bytes" },
+	{ "tt_request_tx" },
+	{ "tt_request_rx" },
+	{ "tt_response_tx" },
+	{ "tt_response_rx" },
+	{ "tt_roam_adv_tx" },
+	{ "tt_roam_adv_rx" },
+#ifdef CONFIG_BATMAN_ADV_DAT
+	{ "dat_get_tx" },
+	{ "dat_get_rx" },
+	{ "dat_put_tx" },
+	{ "dat_put_rx" },
+	{ "dat_cached_reply_tx" },
+#endif
+#ifdef CONFIG_BATMAN_ADV_NC
+	{ "nc_code" },
+	{ "nc_code_bytes" },
+	{ "nc_recode" },
+	{ "nc_recode_bytes" },
+	{ "nc_buffer" },
+	{ "nc_decode" },
+	{ "nc_decode_bytes" },
+	{ "nc_decode_failed" },
+	{ "nc_sniffed" },
+#endif
+};
+
+static void batadv_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+{
+	if (stringset == ETH_SS_STATS)
+		memcpy(data, batadv_counters_strings,
+		       sizeof(batadv_counters_strings));
+}
+
+static void batadv_get_ethtool_stats(struct net_device *dev,
+				     struct ethtool_stats *stats, u64 *data)
+{
+	struct batadv_priv *bat_priv = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < BATADV_CNT_NUM; i++)
+		data[i] = batadv_sum_counter(bat_priv, i);
+}
+
+static int batadv_get_sset_count(struct net_device *dev, int stringset)
+{
+	if (stringset == ETH_SS_STATS)
+		return BATADV_CNT_NUM;
+
+	return -EOPNOTSUPP;
+}
+
+static const struct ethtool_ops batadv_ethtool_ops = {
+	.get_drvinfo = batadv_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+	.get_strings = batadv_get_strings,
+	.get_ethtool_stats = batadv_get_ethtool_stats,
+	.get_sset_count = batadv_get_sset_count,
+};
+
 /**
  * batadv_softif_free - Deconstructor of batadv_soft_interface
  * @dev: Device to cleanup and remove
@@ -1076,87 +1153,3 @@ struct rtnl_link_ops batadv_link_ops __read_mostly = {
 	.setup		= batadv_softif_init_early,
 	.dellink	= batadv_softif_destroy_netlink,
 };
-
-static void batadv_get_drvinfo(struct net_device *dev,
-			       struct ethtool_drvinfo *info)
-{
-	strlcpy(info->driver, "B.A.T.M.A.N. advanced", sizeof(info->driver));
-	strlcpy(info->version, BATADV_SOURCE_VERSION, sizeof(info->version));
-	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
-	strlcpy(info->bus_info, "batman", sizeof(info->bus_info));
-}
-
-/* Inspired by drivers/net/ethernet/dlink/sundance.c:1702
- * Declare each description string in struct.name[] to get fixed sized buffer
- * and compile time checking for strings longer than ETH_GSTRING_LEN.
- */
-static const struct {
-	const char name[ETH_GSTRING_LEN];
-} batadv_counters_strings[] = {
-	{ "tx" },
-	{ "tx_bytes" },
-	{ "tx_dropped" },
-	{ "rx" },
-	{ "rx_bytes" },
-	{ "forward" },
-	{ "forward_bytes" },
-	{ "mgmt_tx" },
-	{ "mgmt_tx_bytes" },
-	{ "mgmt_rx" },
-	{ "mgmt_rx_bytes" },
-	{ "frag_tx" },
-	{ "frag_tx_bytes" },
-	{ "frag_rx" },
-	{ "frag_rx_bytes" },
-	{ "frag_fwd" },
-	{ "frag_fwd_bytes" },
-	{ "tt_request_tx" },
-	{ "tt_request_rx" },
-	{ "tt_response_tx" },
-	{ "tt_response_rx" },
-	{ "tt_roam_adv_tx" },
-	{ "tt_roam_adv_rx" },
-#ifdef CONFIG_BATMAN_ADV_DAT
-	{ "dat_get_tx" },
-	{ "dat_get_rx" },
-	{ "dat_put_tx" },
-	{ "dat_put_rx" },
-	{ "dat_cached_reply_tx" },
-#endif
-#ifdef CONFIG_BATMAN_ADV_NC
-	{ "nc_code" },
-	{ "nc_code_bytes" },
-	{ "nc_recode" },
-	{ "nc_recode_bytes" },
-	{ "nc_buffer" },
-	{ "nc_decode" },
-	{ "nc_decode_bytes" },
-	{ "nc_decode_failed" },
-	{ "nc_sniffed" },
-#endif
-};
-
-static void batadv_get_strings(struct net_device *dev, u32 stringset, u8 *data)
-{
-	if (stringset == ETH_SS_STATS)
-		memcpy(data, batadv_counters_strings,
-		       sizeof(batadv_counters_strings));
-}
-
-static void batadv_get_ethtool_stats(struct net_device *dev,
-				     struct ethtool_stats *stats, u64 *data)
-{
-	struct batadv_priv *bat_priv = netdev_priv(dev);
-	int i;
-
-	for (i = 0; i < BATADV_CNT_NUM; i++)
-		data[i] = batadv_sum_counter(bat_priv, i);
-}
-
-static int batadv_get_sset_count(struct net_device *dev, int stringset)
-{
-	if (stringset == ETH_SS_STATS)
-		return BATADV_CNT_NUM;
-
-	return -EOPNOTSUPP;
-}
-- 
2.11.0
