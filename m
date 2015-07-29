From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Subject: [PATCH net-next] be2net: Support vxlan offload stats in the driver
Date: Wed, 29 Jul 2015 19:35:32 +0530
Message-ID: <1438178732-29026-1-git-send-email-sriharsha.basavapatna@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:50466 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752430AbbG2OHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 10:07:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds vxlan offload specific counters to ethtool stats. We
provide tx/rx queue counters to show the number of vxlan offload pkts
sent/received.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         | 2 ++
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 2 ++
 drivers/net/ethernet/emulex/benet/be_main.c    | 7 ++++++-
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 8cd384d..0a27805 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -230,6 +230,7 @@ struct be_mcc_obj {
 struct be_tx_stats {
 	u64 tx_bytes;
 	u64 tx_pkts;
+	u64 tx_vxlan_offload_pkts;
 	u64 tx_reqs;
 	u64 tx_compl;
 	ulong tx_jiffies;
@@ -277,6 +278,7 @@ struct be_rx_page_info {
 struct be_rx_stats {
 	u64 rx_bytes;
 	u64 rx_pkts;
+	u64 rx_vxlan_offload_pkts;
 	u32 rx_drops_no_skbs;	/* skb allocation errors */
 	u32 rx_drops_no_frags;	/* HW has no fetched frags */
 	u32 rx_post_fail;	/* page post alloc failures */
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index d20ff05..2c9ed17 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -138,6 +138,7 @@ static const struct be_ethtool_stat et_stats[] = {
 static const struct be_ethtool_stat et_rx_stats[] = {
 	{DRVSTAT_RX_INFO(rx_bytes)},/* If moving this member see above note */
 	{DRVSTAT_RX_INFO(rx_pkts)}, /* If moving this member see above note */
+	{DRVSTAT_RX_INFO(rx_vxlan_offload_pkts)},
 	{DRVSTAT_RX_INFO(rx_compl)},
 	{DRVSTAT_RX_INFO(rx_compl_err)},
 	{DRVSTAT_RX_INFO(rx_mcast_pkts)},
@@ -190,6 +191,7 @@ static const struct be_ethtool_stat et_tx_stats[] = {
 	{DRVSTAT_TX_INFO(tx_internal_parity_err)},
 	{DRVSTAT_TX_INFO(tx_bytes)},
 	{DRVSTAT_TX_INFO(tx_pkts)},
+	{DRVSTAT_TX_INFO(tx_vxlan_offload_pkts)},
 	/* Number of skbs queued for trasmission by the driver */
 	{DRVSTAT_TX_INFO(tx_reqs)},
 	/* Number of times the TX queue was stopped due to lack
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5e92db8..d86bc5d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -677,11 +677,14 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
 static void be_tx_stats_update(struct be_tx_obj *txo, struct sk_buff *skb)
 {
 	struct be_tx_stats *stats = tx_stats(txo);
+	u64 tx_pkts = skb_shinfo(skb)->gso_segs ? : 1;
 
 	u64_stats_update_begin(&stats->sync);
 	stats->tx_reqs++;
 	stats->tx_bytes += skb->len;
-	stats->tx_pkts += (skb_shinfo(skb)->gso_segs ? : 1);
+	stats->tx_pkts += tx_pkts;
+	if (skb->encapsulation && skb->ip_summed == CHECKSUM_PARTIAL)
+		stats->tx_vxlan_offload_pkts += tx_pkts;
 	u64_stats_update_end(&stats->sync);
 }
 
@@ -1957,6 +1960,8 @@ static void be_rx_stats_update(struct be_rx_obj *rxo,
 	stats->rx_compl++;
 	stats->rx_bytes += rxcp->pkt_size;
 	stats->rx_pkts++;
+	if (rxcp->tunneled)
+		stats->rx_vxlan_offload_pkts++;
 	if (rxcp->pkt_type == BE_MULTICAST_PACKET)
 		stats->rx_mcast_pkts++;
 	if (rxcp->err)
-- 
2.3.0.rc2
