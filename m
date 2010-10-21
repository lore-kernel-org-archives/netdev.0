From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 09/10] can: at91_can: convert dev_<level> printing to netdev_<level>
Date: Thu, 21 Oct 2010 13:01:21 +0200
Message-ID: <1287658882-26914-10-git-send-email-mkl@pengutronix.de>
References: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34932 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757249Ab0JULB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:01:28 -0400
In-Reply-To: <1287658882-26914-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While there, remove "printk()" on driver loading.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c |   35 ++++++++++++++++-------------------
 1 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 12bd615..7149a86 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -268,7 +268,7 @@ static int at91_set_bittiming(struct net_device *dev)
 		((bt->prop_seg - 1) << 8) | ((bt->phase_seg1 - 1) << 4) |
 		((bt->phase_seg2 - 1) << 0);
 
-	dev_info(dev->dev.parent, "writing AT91_BR: 0x%08x\n", reg_br);
+	netdev_info(dev, "writing AT91_BR: 0x%08x\n", reg_br);
 
 	at91_write(priv, AT91_BR, reg_br);
 
@@ -369,8 +369,7 @@ static netdev_tx_t at91_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(!(at91_read(priv, AT91_MSR(mb)) & AT91_MSR_MRDY))) {
 		netif_stop_queue(dev);
 
-		dev_err(dev->dev.parent,
-			"BUG! TX buffer full when queue awake!\n");
+		netdev_err(dev, "BUG! TX buffer full when queue awake!\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -454,7 +453,7 @@ static void at91_rx_overflow_err(struct net_device *dev)
 	struct sk_buff *skb;
 	struct can_frame *cf;
 
-	dev_dbg(dev->dev.parent, "RX buffer overflow\n");
+	netdev_dbg(dev, "RX buffer overflow\n");
 	stats->rx_over_errors++;
 	stats->rx_errors++;
 
@@ -587,8 +586,8 @@ static int at91_poll_rx(struct net_device *dev, int quota)
 
 	if (priv->rx_next > AT91_MB_RX_LOW_LAST &&
 	    reg_sr & AT91_MB_RX_LOW_MASK)
-		dev_info(dev->dev.parent,
-			 "order of incoming frames cannot be guaranteed\n");
+		netdev_info(dev,
+			"order of incoming frames cannot be guaranteed\n");
 
  again:
 	for (mb = find_next_bit(addr, AT91_MB_RX_NUM, priv->rx_next);
@@ -626,7 +625,7 @@ static void at91_poll_err_frame(struct net_device *dev,
 
 	/* CRC error */
 	if (reg_sr & AT91_IRQ_CERR) {
-		dev_dbg(dev->dev.parent, "CERR irq\n");
+		netdev_dbg(dev, "CERR irq\n");
 		dev->stats.rx_errors++;
 		priv->can.can_stats.bus_error++;
 		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
@@ -634,7 +633,7 @@ static void at91_poll_err_frame(struct net_device *dev,
 
 	/* Stuffing Error */
 	if (reg_sr & AT91_IRQ_SERR) {
-		dev_dbg(dev->dev.parent, "SERR irq\n");
+		netdev_dbg(dev, "SERR irq\n");
 		dev->stats.rx_errors++;
 		priv->can.can_stats.bus_error++;
 		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
@@ -643,14 +642,14 @@ static void at91_poll_err_frame(struct net_device *dev,
 
 	/* Acknowledgement Error */
 	if (reg_sr & AT91_IRQ_AERR) {
-		dev_dbg(dev->dev.parent, "AERR irq\n");
+		netdev_dbg(dev, "AERR irq\n");
 		dev->stats.tx_errors++;
 		cf->can_id |= CAN_ERR_ACK;
 	}
 
 	/* Form error */
 	if (reg_sr & AT91_IRQ_FERR) {
-		dev_dbg(dev->dev.parent, "FERR irq\n");
+		netdev_dbg(dev, "FERR irq\n");
 		dev->stats.rx_errors++;
 		priv->can.can_stats.bus_error++;
 		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
@@ -659,7 +658,7 @@ static void at91_poll_err_frame(struct net_device *dev,
 
 	/* Bit Error */
 	if (reg_sr & AT91_IRQ_BERR) {
-		dev_dbg(dev->dev.parent, "BERR irq\n");
+		netdev_dbg(dev, "BERR irq\n");
 		dev->stats.tx_errors++;
 		priv->can.can_stats.bus_error++;
 		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
@@ -791,7 +790,7 @@ static void at91_irq_err_state(struct net_device *dev,
 		 */
 		if (new_state >= CAN_STATE_ERROR_WARNING &&
 		    new_state <= CAN_STATE_BUS_OFF) {
-			dev_dbg(dev->dev.parent, "Error Warning IRQ\n");
+			netdev_dbg(dev, "Error Warning IRQ\n");
 			priv->can.can_stats.error_warning++;
 
 			cf->can_id |= CAN_ERR_CRTL;
@@ -807,7 +806,7 @@ static void at91_irq_err_state(struct net_device *dev,
 		 */
 		if (new_state >= CAN_STATE_ERROR_PASSIVE &&
 		    new_state <= CAN_STATE_BUS_OFF) {
-			dev_dbg(dev->dev.parent, "Error Passive IRQ\n");
+			netdev_dbg(dev, "Error Passive IRQ\n");
 			priv->can.can_stats.error_passive++;
 
 			cf->can_id |= CAN_ERR_CRTL;
@@ -824,7 +823,7 @@ static void at91_irq_err_state(struct net_device *dev,
 		if (new_state <= CAN_STATE_ERROR_PASSIVE) {
 			cf->can_id |= CAN_ERR_RESTARTED;
 
-			dev_dbg(dev->dev.parent, "restarted\n");
+			netdev_dbg(dev, "restarted\n");
 			priv->can.can_stats.restarts++;
 
 			netif_carrier_on(dev);
@@ -845,7 +844,7 @@ static void at91_irq_err_state(struct net_device *dev,
 		 * circumstances. so just enable AT91_IRQ_ERRP, thus
 		 * the "fallthrough"
 		 */
-		dev_dbg(dev->dev.parent, "Error Active\n");
+		netdev_dbg(dev, "Error Active\n");
 		cf->can_id |= CAN_ERR_PROT;
 		cf->data[2] = CAN_ERR_PROT_ACTIVE;
 	case CAN_STATE_ERROR_WARNING:	/* fallthrough */
@@ -863,7 +862,7 @@ static void at91_irq_err_state(struct net_device *dev,
 
 		cf->can_id |= CAN_ERR_BUSOFF;
 
-		dev_dbg(dev->dev.parent, "bus-off\n");
+		netdev_dbg(dev, "bus-off\n");
 		netif_carrier_off(dev);
 		priv->can.can_stats.bus_off++;
 
@@ -901,7 +900,7 @@ static void at91_irq_err(struct net_device *dev)
 	else if (likely(reg_sr & AT91_IRQ_ERRA))
 		new_state = CAN_STATE_ERROR_ACTIVE;
 	else {
-		dev_err(dev->dev.parent, "BUG! hardware in undefined state\n");
+		netdev_err(dev, "BUG! hardware in undefined state\n");
 		return;
 	}
 
@@ -1156,14 +1155,12 @@ static struct platform_driver at91_can_driver = {
 
 static int __init at91_can_module_init(void)
 {
-	printk(KERN_INFO "%s netdevice driver\n", DRV_NAME);
 	return platform_driver_register(&at91_can_driver);
 }
 
 static void __exit at91_can_module_exit(void)
 {
 	platform_driver_unregister(&at91_can_driver);
-	printk(KERN_INFO "%s: driver removed\n", DRV_NAME);
 }
 
 module_init(at91_can_module_init);
-- 
1.7.0.4

