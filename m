From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (8/12) skge: only allow tx/rx csum on Yukon chipset
Date: Thu, 3 Mar 2005 11:39:19 -0800
Message-ID: <20050303113919.4b365d90@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Only allow transmit and receive checksum to be set on Yukon chipsets
because the Genesis chipset support probably is broken based on the
comments in the sk98lin driver.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.11/drivers/net/skge.c.orig	2005-03-03 09:42:33.000000000 -0800
+++ skge-2.6.11/drivers/net/skge.c	2005-03-03 09:51:52.000000000 -0800
@@ -480,6 +480,17 @@
 	return ethtool_op_set_sg(dev, data);
 }
 
+static int skge_set_tx_csum(struct net_device *dev, u32 data)
+{
+	struct skge_port *skge = netdev_priv(dev);
+	struct skge_hw *hw = skge->hw;
+
+	if (hw->chip_id == CHIP_ID_GENESIS && data)
+		return -EOPNOTSUPP;
+
+	return ethtool_op_set_tx_csum(dev, data);
+}
+
 static u32 skge_get_rx_csum(struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
@@ -487,6 +498,7 @@
 	return skge->rx_csum;
 }
 
+/* Only Yukon supports checksum offload. */
 static int skge_set_rx_csum(struct net_device *dev, u32 data)
 {
 	struct skge_port *skge = netdev_priv(dev);
@@ -498,6 +510,7 @@
 	return 0;
 }
 
+/* Only Yukon II supports TSO (not implemented yet) */
 static int skge_set_tso(struct net_device *dev, u32 data)
 {
 	if (data)
@@ -750,7 +763,7 @@
 	.get_sg		= ethtool_op_get_sg,
 	.set_sg		= skge_set_sg,
 	.get_tx_csum	= ethtool_op_get_tx_csum,
-	.set_tx_csum	= ethtool_op_set_tx_csum,
+	.set_tx_csum	= skge_set_tx_csum,
 	.get_rx_csum	= skge_get_rx_csum,
 	.set_rx_csum	= skge_set_rx_csum,
 	.get_strings	= skge_get_strings,
@@ -3065,14 +3078,11 @@
 	dev->poll_controller = skge_netpoll;
 #endif
 	dev->irq = hw->pdev->irq;
-	if (hw->chip_id != CHIP_ID_GENESIS)
-		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 
 	skge = netdev_priv(dev);
 	skge->netdev = dev;
 	skge->hw = hw;
 	skge->msg_enable = netif_msg_init(debug, default_msg);
-	skge->rx_csum = 1;
 	skge->tx_ring.count = DEFAULT_TX_RING_SIZE;
 	skge->rx_ring.count = DEFAULT_RX_RING_SIZE;
 
@@ -3097,6 +3107,11 @@
 	skge->led_blink.function = skge_blink_timer;
 	skge->led_blink.data = (unsigned long) skge;
 
+	if (hw->chip_id != CHIP_ID_GENESIS) {
+		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
+		skge->rx_csum = 1;
+	}
+
 	/* read the mac address */
 	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port*8, ETH_ALEN);
 
