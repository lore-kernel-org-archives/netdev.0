From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 04/12] drivers: net: xgene: Remove redundant local stats
Date: Wed, 10 May 2017 13:45:02 -0700
Message-ID: <1494449110-23785-5-git-send-email-isubramanian@apm.com>
References: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Quan Nguyen <qnguyen@apm.com>,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33003 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754080AbdEJUma (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 16:42:30 -0400
Received: by mail-io0-f176.google.com with SMTP id p24so9503634ioi.0
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:42:30 -0700 (PDT)
In-Reply-To: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

Commit 5944701df90d ("net: remove useless memset's in drivers get_stats64")
makes the pdata->stats redundant. This patch removes pdata->stats and
updates get_stats64() callback accordingly.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c | 7 ++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c    | 4 +---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h    | 1 -
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index 28fdedc..217cde8 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -25,7 +25,7 @@ struct xgene_gstrings_stats {
 	int offset;
 };
 
-#define XGENE_STAT(m) { #m, offsetof(struct xgene_enet_pdata, stats.m) }
+#define XGENE_STAT(m) { #m, offsetof(struct rtnl_link_stats64, m) }
 
 static const struct xgene_gstrings_stats gstrings_stats[] = {
 	XGENE_STAT(rx_packets),
@@ -156,11 +156,12 @@ static void xgene_get_ethtool_stats(struct net_device *ndev,
 				    struct ethtool_stats *dummy,
 				    u64 *data)
 {
-	void *pdata = netdev_priv(ndev);
+	struct rtnl_link_stats64 stats;
 	int i;
 
+	dev_get_stats(ndev, &stats);
 	for (i = 0; i < XGENE_STATS_LEN; i++)
-		*data++ = *(u64 *)(pdata + gstrings_stats[i].offset);
+		data[i] = *(u64 *)((char *)&stats + gstrings_stats[i].offset);
 }
 
 static void xgene_get_pauseparam(struct net_device *ndev,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 9a28ac3..e4f2ef2 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1466,10 +1466,9 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 
 static void xgene_enet_get_stats64(
 			struct net_device *ndev,
-			struct rtnl_link_stats64 *storage)
+			struct rtnl_link_stats64 *stats)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
-	struct rtnl_link_stats64 *stats = &pdata->stats;
 	struct xgene_enet_desc_ring *ring;
 	int i;
 
@@ -1493,7 +1492,6 @@ static void xgene_enet_get_stats64(
 			stats->rx_dropped += ring->rx_dropped;
 		}
 	}
-	memcpy(storage, stats, sizeof(struct rtnl_link_stats64));
 }
 
 static int xgene_enet_set_mac_address(struct net_device *ndev, void *addr)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 827b33d..5e6fd71 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -219,7 +219,6 @@ struct xgene_enet_pdata {
 	int phy_mode;
 	enum xgene_enet_rm rm;
 	struct xgene_enet_cle cle;
-	struct rtnl_link_stats64 stats;
 	const struct xgene_mac_ops *mac_ops;
 	spinlock_t mac_lock; /* mac lock */
 	const struct xgene_port_ops *port_ops;
-- 
1.9.1
