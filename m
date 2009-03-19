From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/3] smsc911x: define status word positions as constants
Date: Thu, 19 Mar 2009 10:24:44 +0000
Message-ID: <1237458286-23421-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:56036 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752246AbZCSKYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 06:24:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vast majority of bit constants in this driver are defined in the
header file, but TX and RX status word bits are not.  This patch (which
should make no functional change) defines these, to make the driver
slightly more readable.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |   18 ++++++++----------
 drivers/net/smsc911x.h |    7 +++++++
 2 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index fd59a8d..f52bb8a 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -895,22 +895,22 @@ static void smsc911x_tx_update_txcounters(struct net_device *dev)
 			SMSC_WARNING(HW,
 				"Packet tag reserved bit is high");
 		} else {
-			if (unlikely(tx_stat & 0x00008000)) {
+			if (unlikely(tx_stat & TX_STS_ES_)) {
 				dev->stats.tx_errors++;
 			} else {
 				dev->stats.tx_packets++;
 				dev->stats.tx_bytes += (tx_stat >> 16);
 			}
-			if (unlikely(tx_stat & 0x00000100)) {
+			if (unlikely(tx_stat & TX_STS_EXCESS_COL_)) {
 				dev->stats.collisions += 16;
 				dev->stats.tx_aborted_errors += 1;
 			} else {
 				dev->stats.collisions +=
 				    ((tx_stat >> 3) & 0xF);
 			}
-			if (unlikely(tx_stat & 0x00000800))
+			if (unlikely(tx_stat & TX_STS_LOST_CARRIER_))
 				dev->stats.tx_carrier_errors += 1;
-			if (unlikely(tx_stat & 0x00000200)) {
+			if (unlikely(tx_stat & TX_STS_LATE_COL_)) {
 				dev->stats.collisions++;
 				dev->stats.tx_aborted_errors++;
 			}
@@ -924,19 +924,17 @@ smsc911x_rx_counterrors(struct net_device *dev, unsigned int rxstat)
 {
 	int crc_err = 0;
 
-	if (unlikely(rxstat & 0x00008000)) {
+	if (unlikely(rxstat & RX_STS_ES_)) {
 		dev->stats.rx_errors++;
-		if (unlikely(rxstat & 0x00000002)) {
+		if (unlikely(rxstat & RX_STS_CRC_ERR_)) {
 			dev->stats.rx_crc_errors++;
 			crc_err = 1;
 		}
 	}
 	if (likely(!crc_err)) {
-		if (unlikely((rxstat & 0x00001020) == 0x00001020)) {
-			/* Frame type indicates length,
-			 * and length error is set */
+		if (unlikely((rxstat & RX_STS_FRAME_TYPE_) &&
+			     (rxstat & RX_STS_LENGTH_ERR_)))
 			dev->stats.rx_length_errors++;
-		}
 		if (rxstat & RX_STS_MCAST_)
 			dev->stats.multicast++;
 	}
diff --git a/drivers/net/smsc911x.h b/drivers/net/smsc911x.h
index 2b76654..b5716bd 100644
--- a/drivers/net/smsc911x.h
+++ b/drivers/net/smsc911x.h
@@ -81,12 +81,19 @@
 
 #define RX_STATUS_FIFO			0x40
 #define RX_STS_ES_			0x00008000
+#define RX_STS_LENGTH_ERR_		0x00001000
 #define RX_STS_MCAST_			0x00000400
+#define RX_STS_FRAME_TYPE_		0x00000020
+#define RX_STS_CRC_ERR_			0x00000002
 
 #define RX_STATUS_FIFO_PEEK		0x44
 
 #define TX_STATUS_FIFO			0x48
 #define TX_STS_ES_			0x00008000
+#define TX_STS_LOST_CARRIER_		0x00000800
+#define TX_STS_NO_CARRIER_		0x00000400
+#define TX_STS_LATE_COL_		0x00000200
+#define TX_STS_EXCESS_COL_		0x00000100
 
 #define TX_STATUS_FIFO_PEEK		0x4C
 
-- 
1.6.0.6

