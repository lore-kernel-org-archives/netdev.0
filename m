From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 15/22] NET: DM9000: Use netif_msg to enable debugging options
Date: Mon, 19 Nov 2007 20:39:25 +0000
Message-ID: <20071119204015.342133927@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61676 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752025AbXKSVRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:17:49 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-debug-msglevel.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the netif_msg_*() macros to enable the debugging based
on the board's msg_enable field. The output still goes via
the dev_dbg() macros, so will be tagged and output as 
appropriate.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt4/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt4.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt4/drivers/net/dm9000.c
@@ -745,7 +745,8 @@ dm9000_open(struct net_device *dev)
 	board_info_t *db = (board_info_t *) dev->priv;
 	unsigned long irqflags = IRQF_SHARED;
 
-	dev_dbg(db->dev, "entering %s\n", __func__);
+	if (netif_msg_ifup(db))
+		dev_dbg(db->dev, "enabling %s\n", dev->name);
 
 	if (db->platdata)
 		irqflags |= db->platdata->irqflags;
@@ -881,7 +882,8 @@ dm9000_stop(struct net_device *ndev)
 {
 	board_info_t *db = (board_info_t *) ndev->priv;
 
-	dm9000_dbg(db, 1, "entering %s\n", __func__);
+	if (netif_msg_ifdown(db))
+		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
 
 	/* deleted timer */
 	kthread_stop(db->thread);
@@ -912,6 +914,9 @@ dm9000_tx_done(struct net_device *dev, b
 		db->tx_pkt_cnt--;
 		db->stats.tx_packets++;
 
+		if (netif_msg_tx_done(db))
+			dev_dbg(db->dev, "tx done, NSR %02x\n", tx_status);
+
 		/* Queue packet check & send */
 		if (db->tx_pkt_cnt > 0) {
 			iow(db, DM9000_TXPLL, db->queue_pkt_len & 0xff);
@@ -947,6 +952,9 @@ dm9000_interrupt(int irq, void *dev_id)
 	int_status = ior(db, DM9000_ISR);	/* Got ISR */
 	iow(db, DM9000_ISR, int_status);	/* Clear ISR status */
 
+	if (netif_msg_intr(db))
+		dev_dbg(db->dev, "interrupt status %02x\n", int_status);
+
 	/* Received the coming packet */
 	if (int_status & ISR_PRS)
 		dm9000_rx(dev);
@@ -1048,10 +1056,15 @@ dm9000_rx(struct net_device *dev)
 
 		RxLen = le16_to_cpu(rxhdr.RxLen);
 
+		if (netif_msg_rx_status(db))
+			dev_dbg(db->dev, "RX: status %02x, length %04x\n",
+				rxhdr.RxStatus, RxLen);
+
 		/* Packet Status check */
 		if (RxLen < 0x40) {
 			GoodPacket = false;
-			dev_dbg(db->dev, "Bad Packet received (runt)\n");
+			if (netif_msg_rx_err(db))
+				dev_dbg(db->dev, "RX: Bad Packet (runt)\n");
 		}
 
 		if (RxLen > DM9000_PKT_MAX) {
@@ -1061,15 +1074,18 @@ dm9000_rx(struct net_device *dev)
 		if (rxhdr.RxStatus & 0xbf) {
 			GoodPacket = false;
 			if (rxhdr.RxStatus & 0x01) {
-				dev_dbg(db->dev, "fifo error\n");
+				if (netif_msg_rx_err(db))
+					dev_dbg(db->dev, "fifo error\n");
 				db->stats.rx_fifo_errors++;
 			}
 			if (rxhdr.RxStatus & 0x02) {
-				dev_dbg(db->dev, "crc error\n");
+				if (netif_msg_rx_err(db))
+					dev_dbg(db->dev, "crc error\n");
 				db->stats.rx_crc_errors++;
 			}
 			if (rxhdr.RxStatus & 0x80) {
-				dev_dbg(db->dev, "length error\n");
+				if (netif_msg_rx_err(db))
+					dev_dbg(db->dev, "length error\n");
 				db->stats.rx_length_errors++;
 			}
 		}

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
