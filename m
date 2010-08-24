From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] typhoon: fix a race in typhoon_do_get_stats
Date: Tue, 24 Aug 2010 16:18:13 +0200
Message-ID: <1282659493.2477.241.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45930 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755109Ab0HXOSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 10:18:18 -0400
Received: by wwe15 with SMTP id 15so1952217wwe.1
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 07:18:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its important to store 'final' values in counters,
not using them as temporary variables,
or this might break some SNMP applications.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/typhoon.c |   46 +++++++++++++++++++---------------------
 1 file changed, 22 insertions(+), 24 deletions(-)

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 2e50077..3f4681f 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -962,36 +962,34 @@ typhoon_do_get_stats(struct typhoon *tp)
 	 * The extra status reported would be a good candidate for
 	 * ethtool_ops->get_{strings,stats}()
 	 */
-	stats->tx_packets = le32_to_cpu(s->txPackets);
-	stats->tx_bytes = le64_to_cpu(s->txBytes);
-	stats->tx_errors = le32_to_cpu(s->txCarrierLost);
-	stats->tx_carrier_errors = le32_to_cpu(s->txCarrierLost);
-	stats->collisions = le32_to_cpu(s->txMultipleCollisions);
-	stats->rx_packets = le32_to_cpu(s->rxPacketsGood);
-	stats->rx_bytes = le64_to_cpu(s->rxBytesGood);
-	stats->rx_fifo_errors = le32_to_cpu(s->rxFifoOverruns);
+	stats->tx_packets = le32_to_cpu(s->txPackets) +
+			saved->tx_packets;
+	stats->tx_bytes = le64_to_cpu(s->txBytes) +
+			saved->tx_bytes;
+	stats->tx_errors = le32_to_cpu(s->txCarrierLost) +
+			saved->tx_errors;
+	stats->tx_carrier_errors = le32_to_cpu(s->txCarrierLost) +
+			saved->tx_carrier_errors;
+	stats->collisions = le32_to_cpu(s->txMultipleCollisions) +
+			saved->collisions;
+	stats->rx_packets = le32_to_cpu(s->rxPacketsGood) +
+			saved->rx_packets;
+	stats->rx_bytes = le64_to_cpu(s->rxBytesGood) +
+			saved->rx_bytes;
+	stats->rx_fifo_errors = le32_to_cpu(s->rxFifoOverruns) +
+			saved->rx_fifo_errors;
 	stats->rx_errors = le32_to_cpu(s->rxFifoOverruns) +
-			le32_to_cpu(s->BadSSD) + le32_to_cpu(s->rxCrcErrors);
-	stats->rx_crc_errors = le32_to_cpu(s->rxCrcErrors);
-	stats->rx_length_errors = le32_to_cpu(s->rxOversized);
+			le32_to_cpu(s->BadSSD) + le32_to_cpu(s->rxCrcErrors) +
+			saved->rx_errors;
+	stats->rx_crc_errors = le32_to_cpu(s->rxCrcErrors) +
+			saved->rx_crc_errors;
+	stats->rx_length_errors = le32_to_cpu(s->rxOversized) +
+			saved->rx_length_errors;
 	tp->speed = (s->linkStatus & TYPHOON_LINK_100MBPS) ?
 			SPEED_100 : SPEED_10;
 	tp->duplex = (s->linkStatus & TYPHOON_LINK_FULL_DUPLEX) ?
 			DUPLEX_FULL : DUPLEX_HALF;
 
-	/* add in the saved statistics
-	 */
-	stats->tx_packets += saved->tx_packets;
-	stats->tx_bytes += saved->tx_bytes;
-	stats->tx_errors += saved->tx_errors;
-	stats->collisions += saved->collisions;
-	stats->rx_packets += saved->rx_packets;
-	stats->rx_bytes += saved->rx_bytes;
-	stats->rx_fifo_errors += saved->rx_fifo_errors;
-	stats->rx_errors += saved->rx_errors;
-	stats->rx_crc_errors += saved->rx_crc_errors;
-	stats->rx_length_errors += saved->rx_length_errors;
-
 	return 0;
 }
 


