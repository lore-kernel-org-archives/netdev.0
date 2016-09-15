From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net 2/2] bna: fix crash in bnad_get_strings()
Date: Thu, 15 Sep 2016 22:47:52 +0200
Message-ID: <1473972472-29681-2-git-send-email-ivecera@redhat.com>
References: <1473972472-29681-1-git-send-email-ivecera@redhat.com>
Cc: jarod@redhat.com, rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52982 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751502AbcIOUr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 16:47:57 -0400
In-Reply-To: <1473972472-29681-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6e7333d "net: add rx_nohandler stat counter" added the new entry
rx_nohandler into struct rtnl_link_stats64. Unfortunately the bna
driver foolishly depends on the structure. It uses part of it for
ethtool statistics and it's not bad but the driver assumes its size
is constant as it defines string for each existing entry. The problem
occurs when the structure is extended because you need to modify bna
driver as well. If not any attempt to retrieve ethtool statistics results
in crash in bnad_get_strings().
The patch changes BNAD_ETHTOOL_STATS_NUM so it counts real number of
strings in the array and also removes rtnl_link_stats64 entries that
are not used in output and are always zero.

Fixes: 6e7333d "net: add rx_nohandler stat counter"
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c | 50 ++++++++++++-------------
 1 file changed, 23 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 5671353..31f61a7 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -34,12 +34,7 @@
 #define BNAD_NUM_RXQ_COUNTERS 7
 #define BNAD_NUM_TXQ_COUNTERS 5
 
-#define BNAD_ETHTOOL_STATS_NUM						\
-	(sizeof(struct rtnl_link_stats64) / sizeof(u64) +	\
-	sizeof(struct bnad_drv_stats) / sizeof(u64) +		\
-	offsetof(struct bfi_enet_stats, rxf_stats[0]) / sizeof(u64))
-
-static const char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
+static const char *bnad_net_stats_strings[] = {
 	"rx_packets",
 	"tx_packets",
 	"rx_bytes",
@@ -50,22 +45,10 @@ static const char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
 	"tx_dropped",
 	"multicast",
 	"collisions",
-
 	"rx_length_errors",
-	"rx_over_errors",
 	"rx_crc_errors",
 	"rx_frame_errors",
-	"rx_fifo_errors",
-	"rx_missed_errors",
-
-	"tx_aborted_errors",
-	"tx_carrier_errors",
 	"tx_fifo_errors",
-	"tx_heartbeat_errors",
-	"tx_window_errors",
-
-	"rx_compressed",
-	"tx_compressed",
 
 	"netif_queue_stop",
 	"netif_queue_wakeup",
@@ -254,6 +237,8 @@ static const char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
 	"fc_tx_fid_parity_errors",
 };
 
+#define BNAD_ETHTOOL_STATS_NUM	ARRAY_SIZE(bnad_net_stats_strings)
+
 static int
 bnad_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 {
@@ -859,9 +844,9 @@ bnad_get_ethtool_stats(struct net_device *netdev, struct ethtool_stats *stats,
 		       u64 *buf)
 {
 	struct bnad *bnad = netdev_priv(netdev);
-	int i, j, bi;
+	int i, j, bi = 0;
 	unsigned long flags;
-	struct rtnl_link_stats64 *net_stats64;
+	struct rtnl_link_stats64 net_stats64;
 	u64 *stats64;
 	u32 bmap;
 
@@ -876,14 +861,25 @@ bnad_get_ethtool_stats(struct net_device *netdev, struct ethtool_stats *stats,
 	 * under the same lock
 	 */
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bi = 0;
-	memset(buf, 0, stats->n_stats * sizeof(u64));
-
-	net_stats64 = (struct rtnl_link_stats64 *)buf;
-	bnad_netdev_qstats_fill(bnad, net_stats64);
-	bnad_netdev_hwstats_fill(bnad, net_stats64);
 
-	bi = sizeof(*net_stats64) / sizeof(u64);
+	memset(&net_stats64, 0, sizeof(net_stats64));
+	bnad_netdev_qstats_fill(bnad, &net_stats64);
+	bnad_netdev_hwstats_fill(bnad, &net_stats64);
+
+	buf[bi++] = net_stats64.rx_packets;
+	buf[bi++] = net_stats64.tx_packets;
+	buf[bi++] = net_stats64.rx_bytes;
+	buf[bi++] = net_stats64.tx_bytes;
+	buf[bi++] = net_stats64.rx_errors;
+	buf[bi++] = net_stats64.tx_errors;
+	buf[bi++] = net_stats64.rx_dropped;
+	buf[bi++] = net_stats64.tx_dropped;
+	buf[bi++] = net_stats64.multicast;
+	buf[bi++] = net_stats64.collisions;
+	buf[bi++] = net_stats64.rx_length_errors;
+	buf[bi++] = net_stats64.rx_crc_errors;
+	buf[bi++] = net_stats64.rx_frame_errors;
+	buf[bi++] = net_stats64.tx_fifo_errors;
 
 	/* Get netif_queue_stopped from stack */
 	bnad->stats.drv_stats.netif_queue_stopped = netif_queue_stopped(netdev);
-- 
2.7.3
