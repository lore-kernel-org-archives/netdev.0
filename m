From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/12) skge: use chip MIB stats for packet and byte counts
Date: Thu, 3 Mar 2005 11:37:40 -0800
Message-ID: <20050303113740.692bf69e@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use the chip MIB statistics to implement the packet and byte counts.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.11/drivers/net/skge.c.orig	2005-03-02 17:25:25.000000000 -0800
+++ skge-2.6.11/drivers/net/skge.c	2005-03-02 17:29:30.000000000 -0800
@@ -361,6 +361,31 @@
 		yukon_get_stats(skge, data);
 }
 
+/* Use hardware MIB variables for critical path statistics and
+ * transmit feedback not reported at interrupt.
+ * Other errors are accounted for in interrupt handler.
+ */
+static struct net_device_stats *skge_get_stats(struct net_device *dev)
+{
+	struct skge_port *skge = netdev_priv(dev);
+	u64 data[ARRAY_SIZE(skge_stats)];
+
+	if (skge->hw->chip_id == CHIP_ID_GENESIS)
+		genesis_get_stats(skge, data);
+	else
+		yukon_get_stats(skge, data);
+
+	skge->net_stats.tx_bytes = data[0];
+	skge->net_stats.rx_bytes = data[1];
+	skge->net_stats.tx_packets = data[2] + data[4] + data[6];
+	skge->net_stats.rx_packets = data[3] + data[5] + data[7];
+	skge->net_stats.multicast = data[5] + data[7];
+	skge->net_stats.collisions = data[10];
+	skge->net_stats.tx_aborted_errors = data[12];
+
+	return &skge->net_stats;
+}
+
 static void skge_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
 	int i;
@@ -2336,9 +2361,6 @@
 		netif_stop_queue(dev);
 	}
 
-	skge->net_stats.tx_packets++;
-	skge->net_stats.tx_bytes += skb->len;
-
 	dev->trans_start = jiffies;
 	spin_unlock_irqrestore(&skge->tx_lock, flags);
 
@@ -2572,8 +2594,6 @@
 		}
 
 		dev->last_rx = jiffies;
-		skge->net_stats.rx_packets++;
-		skge->net_stats.rx_bytes += skb->len;
 		netif_receive_skb(skb);
 
 		++work_done;
@@ -2825,15 +2845,6 @@
 }
 #endif
 
-/* TODO: use MIB counters instead?? */
-static struct net_device_stats *skge_get_stats(struct net_device *dev)
-{
-	struct skge_port *skge = netdev_priv(dev);
-
-	return &skge->net_stats;
-}
-
-
 static int skge_set_mac_address(struct net_device *dev, void *p)
 {
 	struct skge_port *skge = netdev_priv(dev);
