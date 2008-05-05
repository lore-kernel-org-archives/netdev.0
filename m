From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] ali-ircc: use netstats in net_device structure
Date: Mon, 05 May 2008 23:04:58 +0300
Message-ID: <481F686A.7070106@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050605000508010106010701"
Cc: irda-users@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:55496 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756576AbYEEUKJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 16:10:09 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1Jt70c-0000g6-Gc
	for netdev@vger.kernel.org; Mon, 05 May 2008 20:10:02 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 20:10:02 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 20:10:02 +0000
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050605000508010106010701
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.
Kill ali_ircc_net_get_stats function, because by default it is used
identical internal_stats function from net/core/dev.c

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------050605000508010106010701
Content-Type: text/x-patch;
 name="ali-ircc_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ali-ircc_netstats.patch"

diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 083b0dd..0858539 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -109,7 +109,6 @@ static int  ali_ircc_net_open(struct net_device *dev);
 static int  ali_ircc_net_close(struct net_device *dev);
 static int  ali_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static void ali_ircc_change_speed(struct ali_ircc_cb *self, __u32 baud);
-static struct net_device_stats *ali_ircc_net_get_stats(struct net_device *dev);
 
 /* SIR function */
 static int  ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev);
@@ -366,7 +365,6 @@ static int ali_ircc_open(int i, chipio_t *info)
 	dev->open            = ali_ircc_net_open;
 	dev->stop            = ali_ircc_net_close;
 	dev->do_ioctl        = ali_ircc_net_ioctl;
-	dev->get_stats	     = ali_ircc_net_get_stats;
 
 	err = register_netdev(dev);
 	if (err) {
@@ -876,8 +874,8 @@ static void ali_ircc_sir_receive(struct ali_ircc_cb *self)
          * async_unwrap_char will deliver all found frames  
 	 */
 	do {
-		async_unwrap_char(self->netdev, &self->stats, &self->rx_buff, 
-				  inb(iobase+UART_RX));
+		async_unwrap_char(self->netdev, &self->netdev->stats,
+				  &self->rx_buff, inb(iobase+UART_RX));
 
 		/* Make sure we don't stay here too long */
 		if (boguscount++ > 32) {
@@ -943,7 +941,7 @@ static void ali_ircc_sir_write_wakeup(struct ali_ircc_cb *self)
 			netif_wake_queue(self->netdev);	
 		}
 			
-		self->stats.tx_packets++;
+		self->netdev->stats.tx_packets++;
 		
 		/* Turn on receive interrupts */
 		outb(UART_IER_RDI, iobase+UART_IER);
@@ -1467,7 +1465,7 @@ static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	self->tx_fifo.queue[self->tx_fifo.free].len = skb->len;
 	self->tx_fifo.tail += skb->len;
 
-	self->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 
 	skb_copy_from_linear_data(skb, self->tx_fifo.queue[self->tx_fifo.free].start,
 		      skb->len);
@@ -1661,12 +1659,12 @@ static int  ali_ircc_dma_xmit_complete(struct ali_ircc_cb *self)
 	
 	{
 		IRDA_ERROR("%s(), ********* LSR_FRAME_ABORT *********\n", __FUNCTION__);	
-		self->stats.tx_errors++;
-		self->stats.tx_fifo_errors++;		
+		self->netdev->stats.tx_errors++;
+		self->netdev->stats.tx_fifo_errors++;		
 	}
 	else 
 	{
-		self->stats.tx_packets++;
+		self->netdev->stats.tx_packets++;
 	}
 
 	/* Check if we need to change the speed */
@@ -1831,35 +1829,35 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 			IRDA_DEBUG(0,"%s(), ************* RX Errors ************ \n", __FUNCTION__ );	
 			
 			/* Skip frame */
-			self->stats.rx_errors++;
+			self->netdev->stats.rx_errors++;
 			
 			self->rx_buff.data += len;
 			
 			if (status & LSR_FIFO_UR) 
 			{
-				self->stats.rx_frame_errors++;
+				self->netdev->stats.rx_frame_errors++;
 				IRDA_DEBUG(0,"%s(), ************* FIFO Errors ************ \n", __FUNCTION__ );
 			}	
 			if (status & LSR_FRAME_ERROR)
 			{
-				self->stats.rx_frame_errors++;
+				self->netdev->stats.rx_frame_errors++;
 				IRDA_DEBUG(0,"%s(), ************* FRAME Errors ************ \n", __FUNCTION__ );
 			}
 							
 			if (status & LSR_CRC_ERROR) 
 			{
-				self->stats.rx_crc_errors++;
+				self->netdev->stats.rx_crc_errors++;
 				IRDA_DEBUG(0,"%s(), ************* CRC Errors ************ \n", __FUNCTION__ );
 			}
 			
 			if(self->rcvFramesOverflow)
 			{
-				self->stats.rx_frame_errors++;
+				self->netdev->stats.rx_frame_errors++;
 				IRDA_DEBUG(0,"%s(), ************* Overran DMA buffer ************ \n", __FUNCTION__ );								
 			}
 			if(len == 0)
 			{
-				self->stats.rx_frame_errors++;
+				self->netdev->stats.rx_frame_errors++;
 				IRDA_DEBUG(0,"%s(), ********** Receive Frame Size = 0 ********* \n", __FUNCTION__ );
 			}
 		}	 
@@ -1910,7 +1908,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 				IRDA_WARNING("%s(), memory squeeze, "
 					     "dropping frame.\n",
 					     __FUNCTION__);
-				self->stats.rx_dropped++;
+				self->netdev->stats.rx_dropped++;
 
 				return FALSE;
 			}
@@ -1924,8 +1922,8 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 
 			/* Move to next frame */
 			self->rx_buff.data += len;
-			self->stats.rx_bytes += len;
-			self->stats.rx_packets++;
+			self->netdev->stats.rx_bytes += len;
+			self->netdev->stats.rx_packets++;
 
 			skb->dev = self->netdev;
 			skb_reset_mac_header(skb);
@@ -1995,7 +1993,7 @@ static int ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	self->tx_buff.len = async_wrap_skb(skb, self->tx_buff.data, 
 					   self->tx_buff.truesize);
 	
-	self->stats.tx_bytes += self->tx_buff.len;
+	dev->stats.tx_bytes += self->tx_buff.len;
 
 	/* Turn on transmit finished interrupt. Will fire immediately!  */
 	outb(UART_IER_THRI, iobase+UART_IER); 
@@ -2112,17 +2110,6 @@ static int ali_ircc_is_receiving(struct ali_ircc_cb *self)
 	return status;
 }
 
-static struct net_device_stats *ali_ircc_net_get_stats(struct net_device *dev)
-{
-	struct ali_ircc_cb *self = (struct ali_ircc_cb *) dev->priv;
-	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
-		
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
-	
-	return &self->stats;
-}
-
 static int ali_ircc_suspend(struct platform_device *dev, pm_message_t state)
 {
 	struct ali_ircc_cb *self = platform_get_drvdata(dev);
diff --git a/drivers/net/irda/ali-ircc.h b/drivers/net/irda/ali-ircc.h
index 0787657..3ab6791 100644
--- a/drivers/net/irda/ali-ircc.h
+++ b/drivers/net/irda/ali-ircc.h
@@ -191,7 +191,6 @@ struct ali_ircc_cb {
 	struct tx_fifo tx_fifo;    /* Info about frames to be transmitted */
 
 	struct net_device *netdev;     /* Yes! we are some kind of netdevice */
-	struct net_device_stats stats;
 	
 	struct irlap_cb *irlap;    /* The link layer we are binded to */
 	struct qos_info qos;       /* QoS capabilities for this device */

--------------050605000508010106010701--

