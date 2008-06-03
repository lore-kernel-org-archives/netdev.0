From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 24/39] mv643xx_eth: kill private unused instance of struct net_device_stats
Date: Tue,  3 Jun 2008 13:02:39 +0200
Message-ID: <1212490974-23719-25-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48748 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754861AbYFCMAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:30 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The per-port mv643xx_eth_private struct had a private instance
of struct net_device_stats that was never ever written to, only
read (via the ethtool statistics interface).  This patch gets
rid of the private instance, and tweaks the ethtool statistics
code in mv643xx_eth to use the statistics in struct net_device
instead.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  120 +++++++++++++++++++++++++--------------------
 1 files changed, 66 insertions(+), 54 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index d68780a..b3be8fe 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -316,7 +316,6 @@ struct mv643xx_eth_private {
 
 	struct net_device *dev;
 	struct napi_struct napi;
-	struct net_device_stats stats;
 	struct mib_counters mib_counters;
 	spinlock_t lock;
 	/* Size of Tx Ring per queue */
@@ -876,55 +875,59 @@ static void update_mib_counters(struct mv643xx_eth_private *mep)
 struct mv643xx_eth_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int sizeof_stat;
-	int stat_offset;
+	int netdev_off;
+	int mep_off;
 };
 
-#define MV643XX_ETH_STAT(m) FIELD_SIZEOF(struct mv643xx_eth_private, m), \
-					offsetof(struct mv643xx_eth_private, m)
-
-static const struct mv643xx_eth_stats mv643xx_eth_gstrings_stats[] = {
-	{ "rx_packets", MV643XX_ETH_STAT(stats.rx_packets) },
-	{ "tx_packets", MV643XX_ETH_STAT(stats.tx_packets) },
-	{ "rx_bytes", MV643XX_ETH_STAT(stats.rx_bytes) },
-	{ "tx_bytes", MV643XX_ETH_STAT(stats.tx_bytes) },
-	{ "rx_errors", MV643XX_ETH_STAT(stats.rx_errors) },
-	{ "tx_errors", MV643XX_ETH_STAT(stats.tx_errors) },
-	{ "rx_dropped", MV643XX_ETH_STAT(stats.rx_dropped) },
-	{ "tx_dropped", MV643XX_ETH_STAT(stats.tx_dropped) },
-	{ "good_octets_received", MV643XX_ETH_STAT(mib_counters.good_octets_received) },
-	{ "bad_octets_received", MV643XX_ETH_STAT(mib_counters.bad_octets_received) },
-	{ "internal_mac_transmit_err", MV643XX_ETH_STAT(mib_counters.internal_mac_transmit_err) },
-	{ "good_frames_received", MV643XX_ETH_STAT(mib_counters.good_frames_received) },
-	{ "bad_frames_received", MV643XX_ETH_STAT(mib_counters.bad_frames_received) },
-	{ "broadcast_frames_received", MV643XX_ETH_STAT(mib_counters.broadcast_frames_received) },
-	{ "multicast_frames_received", MV643XX_ETH_STAT(mib_counters.multicast_frames_received) },
-	{ "frames_64_octets", MV643XX_ETH_STAT(mib_counters.frames_64_octets) },
-	{ "frames_65_to_127_octets", MV643XX_ETH_STAT(mib_counters.frames_65_to_127_octets) },
-	{ "frames_128_to_255_octets", MV643XX_ETH_STAT(mib_counters.frames_128_to_255_octets) },
-	{ "frames_256_to_511_octets", MV643XX_ETH_STAT(mib_counters.frames_256_to_511_octets) },
-	{ "frames_512_to_1023_octets", MV643XX_ETH_STAT(mib_counters.frames_512_to_1023_octets) },
-	{ "frames_1024_to_max_octets", MV643XX_ETH_STAT(mib_counters.frames_1024_to_max_octets) },
-	{ "good_octets_sent", MV643XX_ETH_STAT(mib_counters.good_octets_sent) },
-	{ "good_frames_sent", MV643XX_ETH_STAT(mib_counters.good_frames_sent) },
-	{ "excessive_collision", MV643XX_ETH_STAT(mib_counters.excessive_collision) },
-	{ "multicast_frames_sent", MV643XX_ETH_STAT(mib_counters.multicast_frames_sent) },
-	{ "broadcast_frames_sent", MV643XX_ETH_STAT(mib_counters.broadcast_frames_sent) },
-	{ "unrec_mac_control_received", MV643XX_ETH_STAT(mib_counters.unrec_mac_control_received) },
-	{ "fc_sent", MV643XX_ETH_STAT(mib_counters.fc_sent) },
-	{ "good_fc_received", MV643XX_ETH_STAT(mib_counters.good_fc_received) },
-	{ "bad_fc_received", MV643XX_ETH_STAT(mib_counters.bad_fc_received) },
-	{ "undersize_received", MV643XX_ETH_STAT(mib_counters.undersize_received) },
-	{ "fragments_received", MV643XX_ETH_STAT(mib_counters.fragments_received) },
-	{ "oversize_received", MV643XX_ETH_STAT(mib_counters.oversize_received) },
-	{ "jabber_received", MV643XX_ETH_STAT(mib_counters.jabber_received) },
-	{ "mac_receive_error", MV643XX_ETH_STAT(mib_counters.mac_receive_error) },
-	{ "bad_crc_event", MV643XX_ETH_STAT(mib_counters.bad_crc_event) },
-	{ "collision", MV643XX_ETH_STAT(mib_counters.collision) },
-	{ "late_collision", MV643XX_ETH_STAT(mib_counters.late_collision) },
+#define SSTAT(m)						\
+	{ #m, FIELD_SIZEOF(struct net_device_stats, m),		\
+	  offsetof(struct net_device, stats.m), -1 }
+
+#define MIBSTAT(m)						\
+	{ #m, FIELD_SIZEOF(struct mib_counters, m),		\
+	  -1, offsetof(struct mv643xx_eth_private, mib_counters.m) }
+
+static const struct mv643xx_eth_stats mv643xx_eth_stats[] = {
+	SSTAT(rx_packets),
+	SSTAT(tx_packets),
+	SSTAT(rx_bytes),
+	SSTAT(tx_bytes),
+	SSTAT(rx_errors),
+	SSTAT(tx_errors),
+	SSTAT(rx_dropped),
+	SSTAT(tx_dropped),
+	MIBSTAT(good_octets_received),
+	MIBSTAT(bad_octets_received),
+	MIBSTAT(internal_mac_transmit_err),
+	MIBSTAT(good_frames_received),
+	MIBSTAT(bad_frames_received),
+	MIBSTAT(broadcast_frames_received),
+	MIBSTAT(multicast_frames_received),
+	MIBSTAT(frames_64_octets),
+	MIBSTAT(frames_65_to_127_octets),
+	MIBSTAT(frames_128_to_255_octets),
+	MIBSTAT(frames_256_to_511_octets),
+	MIBSTAT(frames_512_to_1023_octets),
+	MIBSTAT(frames_1024_to_max_octets),
+	MIBSTAT(good_octets_sent),
+	MIBSTAT(good_frames_sent),
+	MIBSTAT(excessive_collision),
+	MIBSTAT(multicast_frames_sent),
+	MIBSTAT(broadcast_frames_sent),
+	MIBSTAT(unrec_mac_control_received),
+	MIBSTAT(fc_sent),
+	MIBSTAT(good_fc_received),
+	MIBSTAT(bad_fc_received),
+	MIBSTAT(undersize_received),
+	MIBSTAT(fragments_received),
+	MIBSTAT(oversize_received),
+	MIBSTAT(jabber_received),
+	MIBSTAT(mac_receive_error),
+	MIBSTAT(bad_crc_event),
+	MIBSTAT(collision),
+	MIBSTAT(late_collision),
 };
 
-#define MV643XX_ETH_STATS_LEN	ARRAY_SIZE(mv643xx_eth_gstrings_stats)
-
 static int mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
@@ -960,7 +963,7 @@ static void mv643xx_eth_get_drvinfo(struct net_device *netdev,
 	strncpy(drvinfo->version, mv643xx_eth_driver_version, 32);
 	strncpy(drvinfo->fw_version, "N/A", 32);
 	strncpy(drvinfo->bus_info, "mv643xx", 32);
-	drvinfo->n_stats = MV643XX_ETH_STATS_LEN;
+	drvinfo->n_stats = ARRAY_SIZE(mv643xx_eth_stats);
 }
 
 static int mv643xx_eth_nway_restart(struct net_device *dev)
@@ -984,9 +987,9 @@ static void mv643xx_eth_get_strings(struct net_device *netdev, uint32_t stringse
 
 	switch(stringset) {
 	case ETH_SS_STATS:
-		for (i=0; i < MV643XX_ETH_STATS_LEN; i++) {
+		for (i=0; i < ARRAY_SIZE(mv643xx_eth_stats); i++) {
 			memcpy(data + i * ETH_GSTRING_LEN,
-				mv643xx_eth_gstrings_stats[i].stat_string,
+				mv643xx_eth_stats[i].stat_string,
 				ETH_GSTRING_LEN);
 		}
 		break;
@@ -1001,10 +1004,19 @@ static void mv643xx_eth_get_ethtool_stats(struct net_device *netdev,
 
 	update_mib_counters(mep);
 
-	for (i = 0; i < MV643XX_ETH_STATS_LEN; i++) {
-		char *p = (char *)mep+mv643xx_eth_gstrings_stats[i].stat_offset;
-		data[i] = (mv643xx_eth_gstrings_stats[i].sizeof_stat ==
-			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+	for (i = 0; i < ARRAY_SIZE(mv643xx_eth_stats); i++) {
+		const struct mv643xx_eth_stats *stat;
+		void *p;
+
+		stat = mv643xx_eth_stats + i;
+
+		if (stat->netdev_off >= 0)
+			p = ((void *)mep->dev) + stat->netdev_off;
+		else
+			p = ((void *)mep) + stat->mep_off;
+
+		data[i] = (stat->sizeof_stat == 8) ?
+				*(uint64_t *)p : *(uint32_t *)p;
 	}
 }
 
@@ -1012,7 +1024,7 @@ static int mv643xx_eth_get_sset_count(struct net_device *netdev, int sset)
 {
 	switch (sset) {
 	case ETH_SS_STATS:
-		return MV643XX_ETH_STATS_LEN;
+		return ARRAY_SIZE(mv643xx_eth_stats);
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
1.5.3.4

