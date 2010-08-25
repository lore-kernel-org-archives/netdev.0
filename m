From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-2.6 1/3] be2net: fix net-snmp error because of wrong
 packet stats
Date: Wed, 25 Aug 2010 15:55:47 +0530
Message-ID: <20100825102534.GA14714@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:35715 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753209Ab0HYKZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 06:25:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrong packet statistics for multicast Rx was causing net-snmp error messages
every 15 seconds. Instead of picking the multicast stats from hardware,
now maintain it in the driver itself.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h         |    1 +
 drivers/net/benet/be_ethtool.c |    1 +
 drivers/net/benet/be_hw.h      |    7 +++++--
 drivers/net/benet/be_main.c    |   15 +++++++++++----
 4 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 99197bd..53306bf 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -181,6 +181,7 @@ struct be_drvr_stats {
 	u64 be_rx_bytes_prev;
 	u64 be_rx_pkts;
 	u32 be_rx_rate;
+	u32 be_rx_mcast_pkt;
 	/* number of non ether type II frames dropped where
 	 * frame len > length field of Mac Hdr */
 	u32 be_802_3_dropped_frames;
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index cd16243..13f0abb 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -60,6 +60,7 @@ static const struct be_ethtool_stat et_stats[] = {
 	{DRVSTAT_INFO(be_rx_events)},
 	{DRVSTAT_INFO(be_tx_compl)},
 	{DRVSTAT_INFO(be_rx_compl)},
+	{DRVSTAT_INFO(be_rx_mcast_pkt)},
 	{DRVSTAT_INFO(be_ethrx_post_fail)},
 	{DRVSTAT_INFO(be_802_3_dropped_frames)},
 	{DRVSTAT_INFO(be_802_3_malformed_frames)},
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index 5d38046..a2ec5df 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -167,8 +167,11 @@
 #define FLASH_FCoE_BIOS_START_g3           (13631488)
 #define FLASH_REDBOOT_START_g3             (262144)
 
-
-
+/************* Rx Packet Type Encoding **************/
+#define BE_UNICAST_PACKET		0
+#define BE_MULTICAST_PACKET		1
+#define BE_BROADCAST_PACKET		2
+#define BE_RSVD_PACKET			3
 
 /*
  * BE descriptors: host memory data structures whose formats
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 74e146f..a5a24e6 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -247,6 +247,7 @@ void netdev_stats_update(struct be_adapter *adapter)
 	dev_stats->tx_packets = drvr_stats(adapter)->be_tx_pkts;
 	dev_stats->rx_bytes = drvr_stats(adapter)->be_rx_bytes;
 	dev_stats->tx_bytes = drvr_stats(adapter)->be_tx_bytes;
+	dev_stats->multicast = drvr_stats(adapter)->be_rx_mcast_pkt;
 
 	/* bad pkts received */
 	dev_stats->rx_errors = port_stats->rx_crc_errors +
@@ -294,7 +295,6 @@ void netdev_stats_update(struct be_adapter *adapter)
 	/* no space available in linux */
 	dev_stats->tx_dropped = 0;
 
-	dev_stats->multicast = port_stats->rx_multicast_frames;
 	dev_stats->collisions = 0;
 
 	/* detailed tx_errors */
@@ -848,7 +848,7 @@ static void be_rx_rate_update(struct be_adapter *adapter)
 }
 
 static void be_rx_stats_update(struct be_adapter *adapter,
-		u32 pktsize, u16 numfrags)
+		u32 pktsize, u16 numfrags, u8 pkt_type)
 {
 	struct be_drvr_stats *stats = drvr_stats(adapter);
 
@@ -856,6 +856,9 @@ static void be_rx_stats_update(struct be_adapter *adapter,
 	stats->be_rx_frags += numfrags;
 	stats->be_rx_bytes += pktsize;
 	stats->be_rx_pkts++;
+
+	if (pkt_type == BE_MULTICAST_PACKET)
+		stats->be_rx_mcast_pkt++;
 }
 
 static inline bool do_pkt_csum(struct be_eth_rx_compl *rxcp, bool cso)
@@ -925,9 +928,11 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 	u16 rxq_idx, i, j;
 	u32 pktsize, hdr_len, curr_frag_len, size;
 	u8 *start;
+	u8 pkt_type;
 
 	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
 	pktsize = AMAP_GET_BITS(struct amap_eth_rx_compl, pktsize, rxcp);
+	pkt_type = AMAP_GET_BITS(struct amap_eth_rx_compl, cast_enc, rxcp);
 
 	page_info = get_rx_page_info(adapter, rxq_idx);
 
@@ -993,7 +998,7 @@ static void skb_fill_rx_data(struct be_adapter *adapter,
 	BUG_ON(j > MAX_SKB_FRAGS);
 
 done:
-	be_rx_stats_update(adapter, pktsize, num_rcvd);
+	be_rx_stats_update(adapter, pktsize, num_rcvd, pkt_type);
 }
 
 /* Process the RX completion indicated by rxcp when GRO is disabled */
@@ -1060,6 +1065,7 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	u32 num_rcvd, pkt_size, remaining, vlanf, curr_frag_len;
 	u16 i, rxq_idx = 0, vid, j;
 	u8 vtm;
+	u8 pkt_type;
 
 	num_rcvd = AMAP_GET_BITS(struct amap_eth_rx_compl, numfrags, rxcp);
 	/* Is it a flush compl that has no data */
@@ -1070,6 +1076,7 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	vlanf = AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
 	rxq_idx = AMAP_GET_BITS(struct amap_eth_rx_compl, fragndx, rxcp);
 	vtm = AMAP_GET_BITS(struct amap_eth_rx_compl, vtm, rxcp);
+	pkt_type = AMAP_GET_BITS(struct amap_eth_rx_compl, cast_enc, rxcp);
 
 	/* vlanf could be wrongly set in some cards.
 	 * ignore if vtm is not set */
@@ -1125,7 +1132,7 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 		vlan_gro_frags(&eq_obj->napi, adapter->vlan_grp, vid);
 	}
 
-	be_rx_stats_update(adapter, pkt_size, num_rcvd);
+	be_rx_stats_update(adapter, pkt_size, num_rcvd, pkt_type);
 }
 
 static struct be_eth_rx_compl *be_rx_compl_get(struct be_adapter *adapter)
-- 
1.7.0.4

