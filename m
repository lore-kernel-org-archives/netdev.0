From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next PATCH 2/5] be2net: fix netdev stats rx_errors and
	rx_dropped
Date: Wed, 10 Jun 2009 17:51:16 +0530
Message-ID: <20090610122116.GA16429@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:52525 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755470AbZFJMV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 08:21:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix netdev stat rx_errors to cover length related errors and checksum errors and rx_dropped to the pkts dropped due to lack of buffers

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   43 +++++++++++++++++++++++++++++--------------
 1 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 69046a1..6487eb4 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -168,6 +168,7 @@ static void netdev_stats_update(struct be_adapter *adapter)
 	struct be_port_rxf_stats *port_stats =
 			&rxf_stats->port[adapter->port_num];
 	struct net_device_stats *dev_stats = &adapter->stats.net_stats;
+	struct be_erx_stats *erx_stats = &hw_stats->erx;
 
 	dev_stats->rx_packets = port_stats->rx_total_frames;
 	dev_stats->tx_packets = port_stats->tx_unicastframes +
@@ -181,29 +182,33 @@ static void netdev_stats_update(struct be_adapter *adapter)
 	dev_stats->rx_errors = port_stats->rx_crc_errors +
 		port_stats->rx_alignment_symbol_errors +
 		port_stats->rx_in_range_errors +
-		port_stats->rx_out_range_errors + port_stats->rx_frame_too_long;
-
-	/*  packet transmit problems */
-	dev_stats->tx_errors = 0;
-
-	/*  no space in linux buffers */
-	dev_stats->rx_dropped = 0;
-
-	/* no space available in linux */
-	dev_stats->tx_dropped = 0;
-
-	dev_stats->multicast = port_stats->tx_multicastframes;
-	dev_stats->collisions = 0;
+		port_stats->rx_out_range_errors +
+		port_stats->rx_frame_too_long +
+		port_stats->rx_dropped_too_small +
+		port_stats->rx_dropped_too_short +
+		port_stats->rx_dropped_header_too_small +
+		port_stats->rx_dropped_tcp_length +
+		port_stats->rx_dropped_runt +
+		port_stats->rx_tcp_checksum_errs +
+		port_stats->rx_ip_checksum_errs +
+		port_stats->rx_udp_checksum_errs;
+
+	/*  no space in linux buffers: best possible approximation */
+	dev_stats->rx_dropped = erx_stats->rx_drops_no_fragments[0];
 
 	/* detailed rx errors */
 	dev_stats->rx_length_errors = port_stats->rx_in_range_errors +
-		port_stats->rx_out_range_errors + port_stats->rx_frame_too_long;
+		port_stats->rx_out_range_errors +
+		port_stats->rx_frame_too_long;
+
 	/* receive ring buffer overflow */
 	dev_stats->rx_over_errors = 0;
+
 	dev_stats->rx_crc_errors = port_stats->rx_crc_errors;
 
 	/* frame alignment errors */
 	dev_stats->rx_frame_errors = port_stats->rx_alignment_symbol_errors;
+
 	/* receiver fifo overrun */
 	/* drops_no_pbuf is no per i/f, it's per BE card */
 	dev_stats->rx_fifo_errors = port_stats->rx_fifo_overflow +
@@ -211,6 +216,16 @@ static void netdev_stats_update(struct be_adapter *adapter)
 					rxf_stats->rx_drops_no_pbuf;
 	/* receiver missed packetd */
 	dev_stats->rx_missed_errors = 0;
+
+	/*  packet transmit problems */
+	dev_stats->tx_errors = 0;
+
+	/* no space available in linux */
+	dev_stats->tx_dropped = 0;
+
+	dev_stats->multicast = port_stats->tx_multicastframes;
+	dev_stats->collisions = 0;
+
 	/* detailed tx_errors */
 	dev_stats->tx_aborted_errors = 0;
 	dev_stats->tx_carrier_errors = 0;
-- 
1.6.0.4

