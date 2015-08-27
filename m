From: Corinna Vinschen <vinschen@redhat.com>
Subject: [PATCH net-next] r8169: Add software counter for multicast packages
Date: Thu, 27 Aug 2015 17:11:48 +0200
Message-ID: <1440688308-24649-1-git-send-email-vinschen@redhat.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>, nic_swsd@realtek.com,
	ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:54961 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbbH0PLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 11:11:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The multicast hardware counter on 8168/8111 chips is only 32 bit while the
statistics in struct rtnl_link_stats64 are 64 bit.  Given that statistics
are requested on an irregular basis, an overflow of the hardware counter
can go unnoticed.  To count even very large numbers of multicast packets
reliably, add a software counter and remove previously applied code to
fill the multicast field requested by @rtl8169_get_stats64 with the values
read from the rx_multicast hardware counter.

Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
---
 drivers/net/ethernet/realtek/r8169.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index d6d39df..24dcbe6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -754,7 +754,6 @@ struct rtl8169_tc_offsets {
 	bool	inited;
 	__le64	tx_errors;
 	__le32	tx_multi_collision;
-	__le32	rx_multicast;
 	__le16	tx_aborted;
 };
 
@@ -2326,7 +2325,6 @@ static bool rtl8169_init_counter_offsets(struct net_device *dev)
 
 	tp->tc_offset.tx_errors = tp->counters.tx_errors;
 	tp->tc_offset.tx_multi_collision = tp->counters.tx_multi_collision;
-	tp->tc_offset.rx_multicast = tp->counters.rx_multicast;
 	tp->tc_offset.tx_aborted = tp->counters.tx_aborted;
 	tp->tc_offset.inited = true;
 
@@ -7480,6 +7478,9 @@ process_pkt:
 			tp->rx_stats.packets++;
 			tp->rx_stats.bytes += pkt_size;
 			u64_stats_update_end(&tp->rx_stats.syncp);
+
+			if (skb->pkt_type == PACKET_MULTICAST)
+				dev->stats.multicast++;
 		}
 release_descriptor:
 		desc->opts2 = 0;
@@ -7790,7 +7791,6 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		stats->rx_bytes	= tp->rx_stats.bytes;
 	} while (u64_stats_fetch_retry_irq(&tp->rx_stats.syncp, start));
 
-
 	do {
 		start = u64_stats_fetch_begin_irq(&tp->tx_stats.syncp);
 		stats->tx_packets = tp->tx_stats.packets;
@@ -7804,6 +7804,7 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	stats->rx_crc_errors	= dev->stats.rx_crc_errors;
 	stats->rx_fifo_errors	= dev->stats.rx_fifo_errors;
 	stats->rx_missed_errors = dev->stats.rx_missed_errors;
+	stats->multicast	= dev->stats.multicast;
 
 	/*
 	 * Fetch additonal counter values missing in stats collected by driver
@@ -7819,8 +7820,6 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		le64_to_cpu(tp->tc_offset.tx_errors);
 	stats->collisions = le32_to_cpu(tp->counters.tx_multi_collision) -
 		le32_to_cpu(tp->tc_offset.tx_multi_collision);
-	stats->multicast = le32_to_cpu(tp->counters.rx_multicast) -
-		le32_to_cpu(tp->tc_offset.rx_multicast);
 	stats->tx_aborted_errors = le16_to_cpu(tp->counters.tx_aborted) -
 		le16_to_cpu(tp->tc_offset.tx_aborted);
 
-- 
2.1.0
