From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/2] mv643xx_eth: print message on link status change
Date: Sat, 19 Jul 2008 14:49:52 +0200
Message-ID: <20080719124952.GC12630@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:41888 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753670AbYGSMty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 08:49:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is a link status change (link or phy status interrupt),
print a message notifying the user of the new link status.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.26/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.26.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.26/drivers/net/mv643xx_eth.c
@@ -91,6 +91,12 @@ static char mv643xx_eth_driver_version[]
 #define PORT_STATUS(p)			(0x0444 + ((p) << 10))
 #define  TX_FIFO_EMPTY			0x00000400
 #define  TX_IN_PROGRESS			0x00000080
+#define  PORT_SPEED_MASK		0x00000030
+#define  PORT_SPEED_1000		0x00000010
+#define  PORT_SPEED_100			0x00000020
+#define  PORT_SPEED_10			0x00000000
+#define  FLOW_CONTROL_ENABLED		0x00000008
+#define  FULL_DUPLEX			0x00000004
 #define  LINK_UP			0x00000002
 #define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
 #define TXQ_FIX_PRIO_CONF(p)		(0x044c + ((p) << 10))
@@ -1679,6 +1685,64 @@ static void txq_deinit(struct tx_queue *
 
 
 /* netdev ops and related ***************************************************/
+static void handle_link_event(struct mv643xx_eth_private *mp)
+{
+	struct net_device *dev = mp->dev;
+	u32 port_status;
+	int speed;
+	int duplex;
+	int fc;
+
+	port_status = rdl(mp, PORT_STATUS(mp->port_num));
+	if (!(port_status & LINK_UP)) {
+		if (netif_carrier_ok(dev)) {
+			int i;
+
+			printk(KERN_INFO "%s: link down\n", dev->name);
+
+			netif_carrier_off(dev);
+			netif_stop_queue(dev);
+
+			for (i = 0; i < 8; i++) {
+				struct tx_queue *txq = mp->txq + i;
+
+				if (mp->txq_mask & (1 << i)) {
+					txq_reclaim(txq, 1);
+					txq_reset_hw_ptr(txq);
+				}
+			}
+		}
+		return;
+	}
+
+	switch (port_status & PORT_SPEED_MASK) {
+	case PORT_SPEED_10:
+		speed = 10;
+		break;
+	case PORT_SPEED_100:
+		speed = 100;
+		break;
+	case PORT_SPEED_1000:
+		speed = 1000;
+		break;
+	default:
+		speed = -1;
+		break;
+	}
+	duplex = (port_status & FULL_DUPLEX) ? 1 : 0;
+	fc = (port_status & FLOW_CONTROL_ENABLED) ? 1 : 0;
+
+	printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex, "
+			 "flow control %sabled\n", dev->name,
+			 speed, duplex ? "full" : "half",
+			 fc ? "en" : "dis");
+
+	if (!netif_carrier_ok(dev)) {
+		netif_carrier_on(dev);
+		netif_wake_queue(dev);
+	}
+}
+
 static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
@@ -1698,28 +1762,8 @@ static irqreturn_t mv643xx_eth_irq(int i
 		wrl(mp, INT_CAUSE_EXT(mp->port_num), ~int_cause_ext);
 	}
 
-	if (int_cause_ext & (INT_EXT_PHY | INT_EXT_LINK)) {
-		if (rdl(mp, PORT_STATUS(mp->port_num)) & LINK_UP) {
-			if (!netif_carrier_ok(dev)) {
-				netif_carrier_on(dev);
-				netif_wake_queue(dev);
-			}
-		} else if (netif_carrier_ok(dev)) {
-			int i;
-
-			netif_stop_queue(dev);
-			netif_carrier_off(dev);
-
-			for (i = 0; i < 8; i++) {
-				struct tx_queue *txq = mp->txq + i;
-
-				if (mp->txq_mask & (1 << i)) {
-					txq_reclaim(txq, 1);
-					txq_reset_hw_ptr(txq);
-				}
-			}
-		}
-	}
+	if (int_cause_ext & (INT_EXT_PHY | INT_EXT_LINK))
+		handle_link_event(mp);
 
 	/*
 	 * RxBuffer or RxError set for any of the 8 queues?
@@ -1970,6 +2014,9 @@ static int mv643xx_eth_open(struct net_d
 	napi_enable(&mp->napi);
 #endif
 
+	netif_carrier_off(dev);
+	netif_stop_queue(dev);
+
 	port_start(mp);
 
 	set_rx_coal(mp, 0);
