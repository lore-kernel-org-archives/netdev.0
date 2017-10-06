From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC 1/3] tun: ethtool stats
Date: Fri,  6 Oct 2017 18:25:14 -0400
Message-ID: <20171006222516.90654-2-willemdebruijn.kernel@gmail.com>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, jasowang@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:46931 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752156AbdJFWZU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 18:25:20 -0400
Received: by mail-qt0-f195.google.com with SMTP id 6so24995375qtw.3
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 15:25:20 -0700 (PDT)
In-Reply-To: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Support ethtool -S on tun devices. This interface allows exporting
device-specific stats not present in rtnl stats.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/tun.c | 38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 57e4c31fa84a..df6ef9670d05 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -194,6 +194,15 @@ struct tun_flow_entry {
 
 #define TUN_NUM_FLOW_ENTRIES 1024
 
+static const struct {
+	const char string[ETH_GSTRING_LEN];
+} tun_ethtool_stats_keys[] = {
+	{ "rx_packets" },
+	{ "tx_packets" },
+	{ "rx_bytes" },
+	{ "tx_bytes" },
+};
+
 /* Since the socket were moved to tun_file, to preserve the behavior of persist
  * device, socket filter, sndbuf and vnet header size were restore when the
  * file were attached to a persist device.
@@ -2954,6 +2963,32 @@ static int tun_set_coalesce(struct net_device *dev,
 	return 0;
 }
 
+static int tun_get_sset_count(struct net_device *dev, int string_set)
+{
+	if (string_set == ETH_SS_STATS)
+		return ARRAY_SIZE(tun_ethtool_stats_keys);
+
+	return -EINVAL;
+}
+
+static void tun_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+{
+	if (stringset == ETH_SS_STATS)
+		memcpy(data, &tun_ethtool_stats_keys,
+		       sizeof(tun_ethtool_stats_keys));
+}
+
+static void tun_get_ethtool_stats(struct net_device *dev,
+				  struct ethtool_stats *stats, u64 *data)
+{
+	const int ethtool_stats_bytelen =
+		ARRAY_SIZE(tun_ethtool_stats_keys) * sizeof(u64);
+	struct rtnl_link_stats64 link_stats64 = {0};
+
+	tun_net_get_stats64(dev, &link_stats64);
+	memcpy(data, &link_stats64, ethtool_stats_bytelen);
+}
+
 static const struct ethtool_ops tun_ethtool_ops = {
 	.get_drvinfo	= tun_get_drvinfo,
 	.get_msglevel	= tun_get_msglevel,
@@ -2963,6 +2998,9 @@ static const struct ethtool_ops tun_ethtool_ops = {
 	.get_coalesce   = tun_get_coalesce,
 	.set_coalesce   = tun_set_coalesce,
 	.get_link_ksettings = tun_get_link_ksettings,
+	.get_sset_count	= tun_get_sset_count,
+	.get_strings	= tun_get_strings,
+	.get_ethtool_stats = tun_get_ethtool_stats,
 };
 
 static int tun_queue_resize(struct tun_struct *tun)
-- 
2.14.2.920.gcf0c67979c-goog
