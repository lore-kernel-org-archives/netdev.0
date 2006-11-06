From: Vitaly Wool <vwool@ru.mvista.com>
Subject: [PATCH/RFC] add netpoll support for gianfar
Date: Mon, 6 Nov 2006 14:19:58 +0300
Message-ID: <20061106141958.00002c6c.vwool@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:57003 "HELO
	mail.dev.rtsoft.ru") by vger.kernel.org with SMTP id S1752274AbWKFLUB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 06:20:01 -0500
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch inlined below adds NET_POLL_CONTROLLER support for gianfar network driver.

 drivers/net/gianfar.c |   34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

Signed-off-by: Vitaly Wool <vwool@ru.mvista.com>
  
Index: powerpc/drivers/net/gianfar.c
===================================================================
--- powerpc.orig/drivers/net/gianfar.c
+++ powerpc/drivers/net/gianfar.c
@@ -133,6 +133,9 @@ static void gfar_set_hash_for_addr(struc
 #ifdef CONFIG_GFAR_NAPI
 static int gfar_poll(struct net_device *dev, int *budget);
 #endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void gfar_netpoll(struct net_device *dev);
+#endif
 int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit);
 static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb, int length);
 static void gfar_vlan_rx_register(struct net_device *netdev,
@@ -260,6 +263,9 @@ static int gfar_probe(struct platform_de
 	dev->poll = gfar_poll;
 	dev->weight = GFAR_DEV_WEIGHT;
 #endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = gfar_netpoll;
+#endif
 	dev->stop = gfar_close;
 	dev->get_stats = gfar_get_stats;
 	dev->change_mtu = gfar_change_mtu;
@@ -1536,6 +1542,34 @@ static int gfar_poll(struct net_device *
 }
 #endif
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+static void gfar_netpoll(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+
+	/* If the device has multiple interrupts, run tx/rx */
+	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
+		disable_irq(priv->interruptTransmit);
+		disable_irq(priv->interruptReceive);
+		disable_irq(priv->interruptError);
+		gfar_transmit(priv->interruptTransmit, dev, NULL);
+		gfar_receive(priv->interruptReceive, dev, NULL);
+		enable_irq(priv->interruptError);
+		enable_irq(priv->interruptReceive);
+		enable_irq(priv->interruptTransmit);
+	} else {
+		disable_irq(priv->interruptTransmit);
+		gfar_interrupt(priv->interruptTransmit, dev, NULL);
+		enable_irq(priv->interruptTransmit);
+	}
+}
+#endif
+
 /* The interrupt handler for devices with one interrupt */
 static irqreturn_t gfar_interrupt(int irq, void *dev_id)
 {
