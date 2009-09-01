From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH net-next] can: sja1000: fix network statistics update
Date: Tue, 01 Sep 2009 17:29:41 +0200
Message-ID: <4A9D3DE5.40309@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:38660 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860AbZIAP3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 11:29:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The member "tx_bytes" of "struct net_device_stats" should be
incremented when the interrupt is done and an "arbitration
lost error" is a TX error and the statistics should be updated
accordingly.

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/sja1000/sja1000.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: net-next-2.6/drivers/net/can/sja1000/sja1000.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000.c
+++ net-next-2.6/drivers/net/can/sja1000/sja1000.c
@@ -242,7 +242,6 @@ static netdev_tx_t sja1000_start_xmit(st
 					    struct net_device *dev)
 {
 	struct sja1000_priv *priv = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	uint8_t fi;
 	uint8_t dlc;
@@ -276,7 +275,6 @@ static netdev_tx_t sja1000_start_xmit(st
 	for (i = 0; i < dlc; i++)
 		priv->write_reg(priv, dreg++, cf->data[i]);
 
-	stats->tx_bytes += dlc;
 	dev->trans_start = jiffies;
 
 	can_put_echo_skb(skb, dev, 0);
@@ -428,7 +426,7 @@ static int sja1000_err(struct net_device
 		dev_dbg(dev->dev.parent, "arbitration lost interrupt\n");
 		alc = priv->read_reg(priv, REG_ALC);
 		priv->can.can_stats.arbitration_lost++;
-		stats->rx_errors++;
+		stats->tx_errors++;
 		cf->can_id |= CAN_ERR_LOSTARB;
 		cf->data[0] = alc & 0x1f;
 	}
@@ -486,6 +484,7 @@ irqreturn_t sja1000_interrupt(int irq, v
 
 		if (isrc & IRQ_TI) {
 			/* transmission complete interrupt */
+		  	stats->tx_bytes += priv->read_reg(priv, REG_FI) & 0xf;
 			stats->tx_packets++;
 			can_get_echo_skb(dev, 0);
 			netif_wake_queue(dev);
