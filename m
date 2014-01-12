From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH v2 3/3] atl1: update statistics code
Date: Sun, 12 Jan 2014 18:50:40 +0100
Message-ID: <1389549040-8785-4-git-send-email-sd@queasysnail.net>
References: <1389549040-8785-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	jcliburn@gmail.com, chris.snook@gmail.com,
	Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:46416 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbaALRve (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 12:51:34 -0500
In-Reply-To: <1389549040-8785-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Ben Hutchings pointed out for the stats in alx, some
hardware-specific stats aren't matched to the right net_device_stats
field. Also fix the collision field and include errors in the total
number of RX/TX packets. Add a rx_dropped field and use it where
netdev->stats was modified directly out of the stats update function.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ethernet/atheros/atlx/atl1.c | 43 +++++++++++++++++++-------------
 drivers/net/ethernet/atheros/atlx/atl1.h |  1 +
 2 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 538211d..9162a28 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -1678,33 +1678,42 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct stats_msg_block *smb = adapter->smb.smb;
 
+	u64 new_rx_errors = smb->rx_frag +
+			    smb->rx_fcs_err +
+			    smb->rx_len_err +
+			    smb->rx_sz_ov +
+			    smb->rx_rxf_ov +
+			    smb->rx_rrd_ov +
+			    smb->rx_align_err;
+	u64 new_tx_errors = smb->tx_late_col +
+			    smb->tx_abort_col +
+			    smb->tx_underrun +
+			    smb->tx_trunc;
+
 	/* Fill out the OS statistics structure */
-	adapter->soft_stats.rx_packets += smb->rx_ok;
-	adapter->soft_stats.tx_packets += smb->tx_ok;
+	adapter->soft_stats.rx_packets += smb->rx_ok + new_rx_errors;
+	adapter->soft_stats.tx_packets += smb->tx_ok + new_tx_errors;
 	adapter->soft_stats.rx_bytes += smb->rx_byte_cnt;
 	adapter->soft_stats.tx_bytes += smb->tx_byte_cnt;
 	adapter->soft_stats.multicast += smb->rx_mcast;
-	adapter->soft_stats.collisions += (smb->tx_1_col + smb->tx_2_col * 2 +
-		smb->tx_late_col + smb->tx_abort_col * adapter->hw.max_retry);
+	adapter->soft_stats.collisions += smb->tx_1_col +
+					  smb->tx_2_col +
+					  smb->tx_late_col +
+					  smb->tx_abort_col;
 
 	/* Rx Errors */
-	adapter->soft_stats.rx_errors += (smb->rx_frag + smb->rx_fcs_err +
-		smb->rx_len_err + smb->rx_sz_ov + smb->rx_rxf_ov +
-		smb->rx_rrd_ov + smb->rx_align_err);
+	adapter->soft_stats.rx_errors += new_rx_errors;
 	adapter->soft_stats.rx_fifo_errors += smb->rx_rxf_ov;
 	adapter->soft_stats.rx_length_errors += smb->rx_len_err;
 	adapter->soft_stats.rx_crc_errors += smb->rx_fcs_err;
 	adapter->soft_stats.rx_frame_errors += smb->rx_align_err;
-	adapter->soft_stats.rx_missed_errors += (smb->rx_rrd_ov +
-		smb->rx_rxf_ov);
 
 	adapter->soft_stats.rx_pause += smb->rx_pause;
 	adapter->soft_stats.rx_rrd_ov += smb->rx_rrd_ov;
 	adapter->soft_stats.rx_trunc += smb->rx_sz_ov;
 
 	/* Tx Errors */
-	adapter->soft_stats.tx_errors += (smb->tx_late_col +
-		smb->tx_abort_col + smb->tx_underrun + smb->tx_trunc);
+	adapter->soft_stats.tx_errors += new_tx_errors;
 	adapter->soft_stats.tx_fifo_errors += smb->tx_underrun;
 	adapter->soft_stats.tx_aborted_errors += smb->tx_abort_col;
 	adapter->soft_stats.tx_window_errors += smb->tx_late_col;
@@ -1718,23 +1727,18 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
 	adapter->soft_stats.tx_trunc += smb->tx_trunc;
 	adapter->soft_stats.tx_pause += smb->tx_pause;
 
-	netdev->stats.rx_packets = adapter->soft_stats.rx_packets;
-	netdev->stats.tx_packets = adapter->soft_stats.tx_packets;
 	netdev->stats.rx_bytes = adapter->soft_stats.rx_bytes;
 	netdev->stats.tx_bytes = adapter->soft_stats.tx_bytes;
 	netdev->stats.multicast = adapter->soft_stats.multicast;
 	netdev->stats.collisions = adapter->soft_stats.collisions;
 	netdev->stats.rx_errors = adapter->soft_stats.rx_errors;
-	netdev->stats.rx_over_errors =
-		adapter->soft_stats.rx_missed_errors;
 	netdev->stats.rx_length_errors =
 		adapter->soft_stats.rx_length_errors;
 	netdev->stats.rx_crc_errors = adapter->soft_stats.rx_crc_errors;
 	netdev->stats.rx_frame_errors =
 		adapter->soft_stats.rx_frame_errors;
 	netdev->stats.rx_fifo_errors = adapter->soft_stats.rx_fifo_errors;
-	netdev->stats.rx_missed_errors =
-		adapter->soft_stats.rx_missed_errors;
+	netdev->stats.rx_dropped = adapter->soft_stats.rx_rrd_ov;
 	netdev->stats.tx_errors = adapter->soft_stats.tx_errors;
 	netdev->stats.tx_fifo_errors = adapter->soft_stats.tx_fifo_errors;
 	netdev->stats.tx_aborted_errors =
@@ -1743,6 +1747,9 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
 		adapter->soft_stats.tx_window_errors;
 	netdev->stats.tx_carrier_errors =
 		adapter->soft_stats.tx_carrier_errors;
+
+	netdev->stats.rx_packets = adapter->soft_stats.rx_packets;
+	netdev->stats.tx_packets = adapter->soft_stats.tx_packets;
 }
 
 static void atl1_update_mailbox(struct atl1_adapter *adapter)
@@ -1872,7 +1879,7 @@ static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
 						adapter->rx_buffer_len);
 		if (unlikely(!skb)) {
 			/* Better luck next round */
-			adapter->netdev->stats.rx_dropped++;
+			adapter->soft_stats.rx_dropped++;
 			break;
 		}
 
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.h b/drivers/net/ethernet/atheros/atlx/atl1.h
index 3bf79a5..34a58cd 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.h
+++ b/drivers/net/ethernet/atheros/atlx/atl1.h
@@ -666,6 +666,7 @@ struct atl1_sft_stats {
 	u64 rx_errors;
 	u64 rx_length_errors;
 	u64 rx_crc_errors;
+	u64 rx_dropped;
 	u64 rx_frame_errors;
 	u64 rx_fifo_errors;
 	u64 rx_missed_errors;
-- 
1.8.5.2
