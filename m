From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 3/3] atl1: update statistics code
Date: Fri, 10 Jan 2014 17:08:23 +0100
Message-ID: <1389370103-3009-4-git-send-email-sd@queasysnail.net>
References: <1389370103-3009-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	jcliburn@gmail.com, chris.snook@gmail.com,
	Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:37096 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757202AbaAJQJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 11:09:38 -0500
In-Reply-To: <1389370103-3009-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Ben Hutchings pointed out for the stats in alx, some
hardware-specific stats aren't matched to the right net_device_stats
field. Also fix the collision field and include errors in the total
number of RX/TX packets.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ethernet/atheros/atlx/atl1.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 538211d..31d460a 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -1684,8 +1684,8 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
 	adapter->soft_stats.rx_bytes += smb->rx_byte_cnt;
 	adapter->soft_stats.tx_bytes += smb->tx_byte_cnt;
 	adapter->soft_stats.multicast += smb->rx_mcast;
-	adapter->soft_stats.collisions += (smb->tx_1_col + smb->tx_2_col * 2 +
-		smb->tx_late_col + smb->tx_abort_col * adapter->hw.max_retry);
+	adapter->soft_stats.collisions += (smb->tx_1_col + smb->tx_2_col +
+		smb->tx_late_col + smb->tx_abort_col);
 
 	/* Rx Errors */
 	adapter->soft_stats.rx_errors += (smb->rx_frag + smb->rx_fcs_err +
@@ -1718,23 +1718,18 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
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
@@ -1743,6 +1738,11 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
 		adapter->soft_stats.tx_window_errors;
 	netdev->stats.tx_carrier_errors =
 		adapter->soft_stats.tx_carrier_errors;
+
+	netdev->stats.rx_packets = adapter->soft_stats.rx_packets +
+				   netdev->stats.rx_errors;
+	netdev->stats.tx_packets = adapter->soft_stats.tx_packets +
+				   netdev->stats.tx_errors;
 }
 
 static void atl1_update_mailbox(struct atl1_adapter *adapter)
-- 
1.8.5.2
