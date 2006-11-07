From: Vitaly Wool <vwool@ru.mvista.com>
Subject: [PATCH/RFC] add netpoll support for gianfar: respin
Date: Tue, 7 Nov 2006 13:27:02 +0300
Message-ID: <20061107132702.11645b80.vwool@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:13668 "EHLO
	buildserver.ru.mvista.com") by vger.kernel.org with ESMTP
	id S1751859AbWKGK3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 05:29:45 -0500
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch inlined below adds NET_POLL_CONTROLLER support for gianfar network driver, slightly modified wrt the comments from Andy Fleming.

 drivers/net/gianfar.c |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

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
@@ -1536,6 +1542,33 @@ static int gfar_poll(struct net_device *
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
+		gfar_interrupt(priv->interruptTransmit, dev);
+		enable_irq(priv->interruptError);
+		enable_irq(priv->interruptReceive);
+		enable_irq(priv->interruptTransmit);
+	} else {
+		disable_irq(priv->interruptTransmit);
+		gfar_interrupt(priv->interruptTransmit, dev);
+		enable_irq(priv->interruptTransmit);
+	}
+}
+#endif
+
 /* The interrupt handler for devices with one interrupt */
 static irqreturn_t gfar_interrupt(int irq, void *dev_id)
 {

