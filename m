From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: [PATCH 2.6.34-rc6] net: Improve ks8851 snl transmit performance
Date: Thu, 6 May 2010 15:50:27 -0700
Message-ID: <14385191E87B904DBD836449AA30269D021A64@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, "Abraham Arce" <x0066660@ti.com>,
	"Sebastien Jan" <s-jan@ti.com>
To: "Ben Dooks" <ben@simtec.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@micrel.com>

Under heavy transmission the driver will put 4 1514-byte packets in queue and stop the device transmit queue.  Only the last packet triggers the transmit done interrupt and wakes up the device transmit queue.  That means a bit of time is wasted when the CPU cannot send any more packet.

The new implementation triggers the transmit interrupt when the transmit buffer left is less than 3 packets.  The maximum transmit buffer size is 6144 bytes.  This allows the device transmit queue to be restarted sooner so that CPU can send more packets.

For TCP receiving it also has the benefit of not triggering any transmit interrupt at all.

There is a driver option no_tx_opt so that the driver can revert to original implementation.  This allows user to verify if the transmit performance actually improves.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
---
This replaces the [patch 01/13] patch I submitted and was objected by David.

Other users with Micrel KSZ8851 SNL chip please verify the transmit performance does improve or not.

--- a/drivers/net/ks8851.c	2010-04-29 20:02:05.000000000 -0700
+++ b/drivers/net/ks8851.c	2010-05-06 15:30:40.000000000 -0700
@@ -74,6 +74,9 @@ union ks8851_tx_hdr {
  * @rxd: Space for receiving SPI data, in DMA-able space.
  * @txd: Space for transmitting SPI data, in DMA-able space.
  * @msg_enable: The message flags controlling driver output (see ethtool).
+ * @tx_space: The current available transmit buffer size.
+ * @tx_avail: The maximum available transmit buffer size.
+ * @tx_chk_cnt: Used to indicate how often to check the transmit buffer.
  * @fid: Incrementing frame id tag.
  * @rc_ier: Cached copy of KS_IER.
  * @rc_rxqcr: Cached copy of KS_RXQCR.
@@ -103,6 +106,8 @@ struct ks8851_net {
 
 	u32			msg_enable ____cacheline_aligned;
 	u16			tx_space;
+	u16			tx_avail;
+	u8			tx_chk_cnt;
 	u8			fid;
 
 	u16			rc_ier;
@@ -124,6 +129,7 @@ struct ks8851_net {
 };
 
 static int msg_enable;
+static int no_tx_opt;
 
 #define ks_info(_ks, _msg...) dev_info(&(_ks)->spidev->dev, _msg)
 #define ks_warn(_ks, _msg...) dev_warn(&(_ks)->spidev->dev, _msg)
@@ -580,10 +586,21 @@ static void ks8851_irq_work(struct work_
 
 		/* update our idea of how much tx space is available to the
 		 * system */
+		ks->tx_chk_cnt = 0;
 		ks->tx_space = ks8851_rdreg16(ks, KS_TXMIR);
 
 		if (netif_msg_intr(ks))
 			ks_dbg(ks, "%s: txspace %d\n", __func__, ks->tx_space);
+
+	/* Update tx space when packets are being transmitted. */
+	} else if (ks->tx_space < ks->tx_avail) {
+		ks->tx_chk_cnt++;
+
+		/* Read the transmit buffer register every 4th rx interrupt. */
+		if (4 == ks->tx_chk_cnt) {
+			ks->tx_chk_cnt = 0;
+			ks->tx_space = ks8851_rdreg16(ks, KS_TXMIR);
+		}
 	}
 
 	if (status & IRQ_RXI)
@@ -715,6 +732,7 @@ static void ks8851_tx_work(struct work_s
 	struct ks8851_net *ks = container_of(work, struct ks8851_net, tx_work);
 	struct sk_buff *txb;
 	bool last = skb_queue_empty(&ks->txq);
+	bool tx_irq;
 
 	mutex_lock(&ks->lock);
 
@@ -724,7 +742,11 @@ static void ks8851_tx_work(struct work_s
 
 		if (txb != NULL) {
 			ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_SDA);
-			ks8851_wrpkt(ks, txb, last);
+			if (ks->tx_avail)
+				tx_irq = (CHECKSUM_UNNECESSARY == txb->ip_summed);
+			else
+				tx_irq = last;
+			ks8851_wrpkt(ks, txb, tx_irq);
 			ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr);
 			ks8851_wrreg16(ks, KS_TXQCR, TXQCR_METFE);
 
@@ -917,11 +939,17 @@ static netdev_tx_t ks8851_start_xmit(str
 		ret = NETDEV_TX_BUSY;
 	} else {
 		ks->tx_space -= needed;
+		/*
+		 * Indicate to enable transmit done interrupt when transmit
+		 * buffer is less than a certain size.
+		 */
+		if (ks->tx_avail && ks->tx_space < 1514 * 3)
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		skb_queue_tail(&ks->txq, skb);
+		schedule_work(&ks->tx_work);
 	}
 
 	spin_unlock(&ks->statelock);
-	schedule_work(&ks->tx_work);
 
 	return ret;
 }
@@ -1224,7 +1252,6 @@ static int __devinit ks8851_probe(struct
 
 	ks->netdev = ndev;
 	ks->spidev = spi;
-	ks->tx_space = 6144;
 
 	mutex_init(&ks->lock);
 	spin_lock_init(&ks->statelock);
@@ -1279,6 +1306,10 @@ static int __devinit ks8851_probe(struct
 		goto err_id;
 	}
 
+	ks->tx_space = ks8851_rdreg16(ks, KS_TXMIR);
+	if (!no_tx_opt)
+		ks->tx_avail = ks->tx_space;
+
 	ks8851_read_selftest(ks);
 	ks8851_init_mac(ks);
 
@@ -1351,6 +1382,8 @@ MODULE_DESCRIPTION("KS8851 Network drive
 MODULE_AUTHOR("Ben Dooks <ben@simtec.co.uk>");
 MODULE_LICENSE("GPL");
 
+module_param(no_tx_opt, int, 0);
+MODULE_PARM_DESC(message, "No TX optimization");
 module_param_named(message, msg_enable, int, 0);
 MODULE_PARM_DESC(message, "Message verbosity level (0=none, 31=all)");
 MODULE_ALIAS("spi:ks8851");
