From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 17/24 for-2.6.25] DM9000: Use netif_msg to enable debugging options
Date: Tue, 05 Feb 2008 00:02:16 +0000
Message-ID: <20080205000817.948372112@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58738 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758840AbYBEAIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:25 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-debug-msglevel.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the netif_msg_*() macros to enable the debugging based
on the board's msg_enable field. The output still goes via
the dev_dbg() macros, so will be tagged and output as 
appropriate.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt3/drivers/net/dm9000.c
@@ -714,7 +714,8 @@ dm9000_open(struct net_device *dev)
 	board_info_t *db = (board_info_t *) dev->priv;
 	unsigned long irqflags = db->irq_res->flags & IRQF_TRIGGER_MASK;
 
-	dev_dbg(db->dev, "entering %s\n", __func__);
+	if (netif_msg_ifup(db))
+		dev_dbg(db->dev, "enabling %s\n", dev->name);
 
 	/* If there is no IRQ type specified, default to something that
 	 * may work, and tell the user that this is a problem */
@@ -858,7 +859,8 @@ dm9000_stop(struct net_device *ndev)
 {
 	board_info_t *db = (board_info_t *) ndev->priv;
 
-	dm9000_dbg(db, 1, "entering %s\n", __func__);
+	if (netif_msg_ifdown(db))
+		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
 
 	netif_stop_queue(ndev);
 	netif_carrier_off(ndev);
@@ -886,6 +888,9 @@ dm9000_tx_done(struct net_device *dev, b
 		db->tx_pkt_cnt--;
 		dev->stats.tx_packets++;
 
+		if (netif_msg_tx_done(db))
+			dev_dbg(db->dev, "tx done, NSR %02x\n", tx_status);
+
 		/* Queue packet check & send */
 		if (db->tx_pkt_cnt > 0) {
 			iow(db, DM9000_TXPLL, db->queue_pkt_len & 0xff);
@@ -921,6 +926,9 @@ dm9000_interrupt(int irq, void *dev_id)
 	int_status = ior(db, DM9000_ISR);	/* Got ISR */
 	iow(db, DM9000_ISR, int_status);	/* Clear ISR status */
 
+	if (netif_msg_intr(db))
+		dev_dbg(db->dev, "interrupt status %02x\n", int_status);
+
 	/* Received the coming packet */
 	if (int_status & ISR_PRS)
 		dm9000_rx(dev);
@@ -985,10 +993,15 @@ dm9000_rx(struct net_device *dev)
 
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
@@ -998,15 +1011,18 @@ dm9000_rx(struct net_device *dev)
 		if (rxhdr.RxStatus & 0xbf) {
 			GoodPacket = false;
 			if (rxhdr.RxStatus & 0x01) {
-				dev_dbg(db->dev, "fifo error\n");
+				if (netif_msg_rx_err(db))
+					dev_dbg(db->dev, "fifo error\n");
 				dev->stats.rx_fifo_errors++;
 			}
 			if (rxhdr.RxStatus & 0x02) {
-				dev_dbg(db->dev, "crc error\n");
+				if (netif_msg_rx_err(db))
+					dev_dbg(db->dev, "crc error\n");
 				dev->stats.rx_crc_errors++;
 			}
 			if (rxhdr.RxStatus & 0x80) {
-				dev_dbg(db->dev, "length error\n");
+				if (netif_msg_rx_err(db))
+					dev_dbg(db->dev, "length error\n");
 				dev->stats.rx_length_errors++;
 			}
 		}

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
