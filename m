From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 03/14] net: dl2k: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:28 +0200
Message-ID: <20170407081739.5243-4-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34518 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755256AbdDGIRq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:46 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in struct
netdev_private, use stats from struct net_device. Also remove the now
unnecessary .ndo_get_stats function and the #ifdef'ed increment of the
collisions16 counter which doesn't exist in struct net_device_stats.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/dlink/dl2k.c | 45 +++++++++++++++++----------------------
 drivers/net/ethernet/dlink/dl2k.h |  1 -
 2 files changed, 20 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index 1e350135f11d..778f974e2928 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -878,10 +878,10 @@ tx_error (struct net_device *dev, int tx_status)
 	frame_id = (tx_status & 0xffff0000);
 	printk (KERN_ERR "%s: Transmit error, TxStatus %4.4x, FrameId %d.\n",
 		dev->name, tx_status, frame_id);
-	np->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	/* Ttransmit Underrun */
 	if (tx_status & 0x10) {
-		np->stats.tx_fifo_errors++;
+		dev->stats.tx_fifo_errors++;
 		dw16(TxStartThresh, dr16(TxStartThresh) + 0x10);
 		/* Transmit Underrun need to set TxReset, DMARest, FIFOReset */
 		dw16(ASICCtrl + 2,
@@ -903,7 +903,7 @@ tx_error (struct net_device *dev, int tx_status)
 	}
 	/* Late Collision */
 	if (tx_status & 0x04) {
-		np->stats.tx_fifo_errors++;
+		dev->stats.tx_fifo_errors++;
 		/* TxReset and clear FIFO */
 		dw16(ASICCtrl + 2, TxReset | FIFOReset);
 		/* Wait reset done */
@@ -916,13 +916,8 @@ tx_error (struct net_device *dev, int tx_status)
 		/* Let TxStartThresh stay default value */
 	}
 	/* Maximum Collisions */
-#ifdef ETHER_STATS
 	if (tx_status & 0x08)
-		np->stats.collisions16++;
-#else
-	if (tx_status & 0x08)
-		np->stats.collisions++;
-#endif
+		dev->stats.collisions++;
 	/* Restart the Tx */
 	dw32(MACCtrl, dr16(MACCtrl) | TxEnable);
 }
@@ -952,15 +947,15 @@ receive_packet (struct net_device *dev)
 			break;
 		/* Update rx error statistics, drop packet. */
 		if (frame_status & RFS_Errors) {
-			np->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (frame_status & (RxRuntFrame | RxLengthError))
-				np->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if (frame_status & RxFCSError)
-				np->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			if (frame_status & RxAlignmentError && np->speed != 1000)
-				np->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			if (frame_status & RxFIFOOverrun)
-	 			np->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 		} else {
 			struct sk_buff *skb;
 
@@ -1096,23 +1091,23 @@ get_stats (struct net_device *dev)
 	/* All statistics registers need to be acknowledged,
 	   else statistic overflow could cause problems */
 
-	np->stats.rx_packets += dr32(FramesRcvOk);
-	np->stats.tx_packets += dr32(FramesXmtOk);
-	np->stats.rx_bytes += dr32(OctetRcvOk);
-	np->stats.tx_bytes += dr32(OctetXmtOk);
+	dev->stats.rx_packets += dr32(FramesRcvOk);
+	dev->stats.tx_packets += dr32(FramesXmtOk);
+	dev->stats.rx_bytes += dr32(OctetRcvOk);
+	dev->stats.tx_bytes += dr32(OctetXmtOk);
 
-	np->stats.multicast = dr32(McstFramesRcvdOk);
-	np->stats.collisions += dr32(SingleColFrames)
+	dev->stats.multicast = dr32(McstFramesRcvdOk);
+	dev->stats.collisions += dr32(SingleColFrames)
 			     +  dr32(MultiColFrames);
 
 	/* detailed tx errors */
 	stat_reg = dr16(FramesAbortXSColls);
-	np->stats.tx_aborted_errors += stat_reg;
-	np->stats.tx_errors += stat_reg;
+	dev->stats.tx_aborted_errors += stat_reg;
+	dev->stats.tx_errors += stat_reg;
 
 	stat_reg = dr16(CarrierSenseErrors);
-	np->stats.tx_carrier_errors += stat_reg;
-	np->stats.tx_errors += stat_reg;
+	dev->stats.tx_carrier_errors += stat_reg;
+	dev->stats.tx_errors += stat_reg;
 
 	/* Clear all other statistic register. */
 	dr32(McstOctetXmtOk);
@@ -1142,7 +1137,7 @@ get_stats (struct net_device *dev)
 	dr16(TCPCheckSumErrors);
 	dr16(UDPCheckSumErrors);
 	dr16(IPCheckSumErrors);
-	return &np->stats;
+	return &dev->stats;
 }
 
 static int
diff --git a/drivers/net/ethernet/dlink/dl2k.h b/drivers/net/ethernet/dlink/dl2k.h
index 5d8ae5320242..10e98ba33ebf 100644
--- a/drivers/net/ethernet/dlink/dl2k.h
+++ b/drivers/net/ethernet/dlink/dl2k.h
@@ -377,7 +377,6 @@ struct netdev_private {
 	void __iomem *eeprom_addr;
 	spinlock_t tx_lock;
 	spinlock_t rx_lock;
-	struct net_device_stats stats;
 	unsigned int rx_buf_sz;		/* Based on MTU+slack. */
 	unsigned int speed;		/* Operating speed */
 	unsigned int vlan;		/* VLAN Id */
-- 
2.12.2
