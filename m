From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH v2 1/3] atl1c: update statistics code
Date: Sun, 12 Jan 2014 18:50:38 +0100
Message-ID: <1389549040-8785-2-git-send-email-sd@queasysnail.net>
References: <1389549040-8785-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	jcliburn@gmail.com, chris.snook@gmail.com,
	Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:45229 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbaALRvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 12:51:14 -0500
In-Reply-To: <1389549040-8785-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Ben Hutchings pointed out for the stats in alx, some
hardware-specific stats aren't matched to the right net_device_stats
field. Also fix the collision field and include errors in the total
number of RX/TX packets.

Minor whitespace fixes to match the style in alx.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 31 ++++++++++++++++---------
 1 file changed, 20 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 2980175..4d3258d 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1500,31 +1500,40 @@ static struct net_device_stats *atl1c_get_stats(struct net_device *netdev)
 	struct net_device_stats *net_stats = &netdev->stats;
 
 	atl1c_update_hw_stats(adapter);
-	net_stats->rx_packets = hw_stats->rx_ok;
-	net_stats->tx_packets = hw_stats->tx_ok;
 	net_stats->rx_bytes   = hw_stats->rx_byte_cnt;
 	net_stats->tx_bytes   = hw_stats->tx_byte_cnt;
 	net_stats->multicast  = hw_stats->rx_mcast;
 	net_stats->collisions = hw_stats->tx_1_col +
-				hw_stats->tx_2_col * 2 +
-				hw_stats->tx_late_col + hw_stats->tx_abort_col;
-	net_stats->rx_errors  = hw_stats->rx_frag + hw_stats->rx_fcs_err +
-				hw_stats->rx_len_err + hw_stats->rx_sz_ov +
-				hw_stats->rx_rrd_ov + hw_stats->rx_align_err;
+				hw_stats->tx_2_col +
+				hw_stats->tx_late_col +
+				hw_stats->tx_abort_col;
+
+	net_stats->rx_errors  = hw_stats->rx_frag +
+				hw_stats->rx_fcs_err +
+				hw_stats->rx_len_err +
+				hw_stats->rx_sz_ov +
+				hw_stats->rx_rrd_ov +
+				hw_stats->rx_align_err +
+				hw_stats->rx_rxf_ov;
+
 	net_stats->rx_fifo_errors   = hw_stats->rx_rxf_ov;
 	net_stats->rx_length_errors = hw_stats->rx_len_err;
 	net_stats->rx_crc_errors    = hw_stats->rx_fcs_err;
 	net_stats->rx_frame_errors  = hw_stats->rx_align_err;
-	net_stats->rx_over_errors   = hw_stats->rx_rrd_ov + hw_stats->rx_rxf_ov;
+	net_stats->rx_dropped       = hw_stats->rx_rrd_ov;
 
-	net_stats->rx_missed_errors = hw_stats->rx_rrd_ov + hw_stats->rx_rxf_ov;
+	net_stats->tx_errors = hw_stats->tx_late_col +
+			       hw_stats->tx_abort_col +
+			       hw_stats->tx_underrun +
+			       hw_stats->tx_trunc;
 
-	net_stats->tx_errors = hw_stats->tx_late_col + hw_stats->tx_abort_col +
-				hw_stats->tx_underrun + hw_stats->tx_trunc;
 	net_stats->tx_fifo_errors    = hw_stats->tx_underrun;
 	net_stats->tx_aborted_errors = hw_stats->tx_abort_col;
 	net_stats->tx_window_errors  = hw_stats->tx_late_col;
 
+	net_stats->rx_packets = hw_stats->rx_ok + net_stats->rx_errors;
+	net_stats->tx_packets = hw_stats->tx_ok + net_stats->tx_errors;
+
 	return net_stats;
 }
 
-- 
1.8.5.2
