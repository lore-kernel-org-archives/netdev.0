From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH 2/4] be2net: Maintain tx and rx counters in driver
Date: Sat, 20 Feb 2010 05:27:12 +0530
Message-ID: <20100219235702.GA12931@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f197.google.com ([209.85.211.197]:57461 "EHLO
	mail-yw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353Ab0BSX5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 18:57:18 -0500
Received: by ywh35 with SMTP id 35so622250ywh.4
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 15:57:17 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For certain skews of the BE adapter, H/W Tx and Rx
counters could be common for more than one interface.
Add Tx and Rx counters in the adapter structure
(to maintain stats on a per interfae basis).

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    2 ++
 drivers/net/benet/be_main.c |   18 +++++++++---------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index e3a4665..42c7a2b 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -164,6 +164,7 @@ struct be_drvr_stats {
 	ulong be_tx_jiffies;
 	u64 be_tx_bytes;
 	u64 be_tx_bytes_prev;
+	u64 be_tx_pkts;
 	u32 be_tx_rate;
 
 	u32 cache_barrier[16];
@@ -175,6 +176,7 @@ struct be_drvr_stats {
 	ulong be_rx_jiffies;
 	u64 be_rx_bytes;
 	u64 be_rx_bytes_prev;
+	u64 be_rx_pkts;
 	u32 be_rx_rate;
 	/* number of non ether type II frames dropped where
 	 * frame len > length field of Mac Hdr */
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index f667044..de0830e 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -159,13 +159,10 @@ void netdev_stats_update(struct be_adapter *adapter)
 	struct net_device_stats *dev_stats = &adapter->netdev->stats;
 	struct be_erx_stats *erx_stats = &hw_stats->erx;
 
-	dev_stats->rx_packets = port_stats->rx_total_frames;
-	dev_stats->tx_packets = port_stats->tx_unicastframes +
-		port_stats->tx_multicastframes + port_stats->tx_broadcastframes;
-	dev_stats->rx_bytes = (u64) port_stats->rx_bytes_msd << 32 |
-				(u64) port_stats->rx_bytes_lsd;
-	dev_stats->tx_bytes = (u64) port_stats->tx_bytes_msd << 32 |
-				(u64) port_stats->tx_bytes_lsd;
+	dev_stats->rx_packets = drvr_stats(adapter)->be_rx_pkts;
+	dev_stats->tx_packets = drvr_stats(adapter)->be_tx_pkts;
+	dev_stats->rx_bytes = drvr_stats(adapter)->be_rx_bytes;
+	dev_stats->tx_bytes = drvr_stats(adapter)->be_tx_bytes;
 
 	/* bad pkts received */
 	dev_stats->rx_errors = port_stats->rx_crc_errors +
@@ -322,12 +319,13 @@ static void be_tx_rate_update(struct be_adapter *adapter)
 }
 
 static void be_tx_stats_update(struct be_adapter *adapter,
-			u32 wrb_cnt, u32 copied, bool stopped)
+			u32 wrb_cnt, u32 copied, u32 gso_segs, bool stopped)
 {
 	struct be_drvr_stats *stats = drvr_stats(adapter);
 	stats->be_tx_reqs++;
 	stats->be_tx_wrbs += wrb_cnt;
 	stats->be_tx_bytes += copied;
+	stats->be_tx_pkts += (gso_segs ? gso_segs : 1);
 	if (stopped)
 		stats->be_tx_stops++;
 }
@@ -472,7 +470,8 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 
 		be_txq_notify(adapter, txq->id, wrb_cnt);
 
-		be_tx_stats_update(adapter, wrb_cnt, copied, stopped);
+		be_tx_stats_update(adapter, wrb_cnt, copied,
+				skb_shinfo(skb)->gso_segs, stopped);
 	} else {
 		txq->head = start;
 		dev_kfree_skb_any(skb);
@@ -619,6 +618,7 @@ static void be_rx_stats_update(struct be_adapter *adapter,
 	stats->be_rx_compl++;
 	stats->be_rx_frags += numfrags;
 	stats->be_rx_bytes += pktsize;
+	stats->be_rx_pkts++;
 }
 
 static inline bool do_pkt_csum(struct be_eth_rx_compl *rxcp, bool cso)
-- 
1.6.3.3

