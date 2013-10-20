From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH net-next v3 07/07] natsemi: Support for byte queue limits
Date: Sun, 20 Oct 2013 21:23:11 +0200
Message-ID: <1382296991-20289-8-git-send-email-milky-kernel@mcmilk.de>
References: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Bill Pemberton <wfp5p@virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:49869 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751516Ab3JTTXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 15:23:30 -0400
In-Reply-To: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to natsemi driver to use byte queue limits.


Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/natsemi/natsemi.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 7a5e295..1f6efbc 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -71,6 +71,8 @@
 				 NETIF_MSG_TX_ERR)
 static int debug = -1;
 
+static bool bql_disable;
+
 static int mtu;
 
 /* Maximum number of multicast addresses to filter (vs. rx-all-multicast).
@@ -139,12 +141,15 @@ MODULE_LICENSE("GPL");
 
 module_param(mtu, int, 0);
 module_param(debug, int, 0);
+module_param(bql_disable, bool, 0);
 module_param(rx_copybreak, int, 0);
 module_param(dspcfg_workaround, int, 0);
 module_param_array(options, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
 MODULE_PARM_DESC(mtu, "DP8381x MTU (all boards)");
 MODULE_PARM_DESC(debug, "DP8381x default debug level");
+MODULE_PARM_DESC(bql_disable,
+	"Disable Byte Queue Limits functionality (default: false)");
 MODULE_PARM_DESC(rx_copybreak,
 	"DP8381x copy breakpoint for copy-only-tiny-frames");
 MODULE_PARM_DESC(dspcfg_workaround, "DP8381x: control DspCfg workaround");
@@ -1974,6 +1979,9 @@ static void init_ring(struct net_device *dev)
 		np->tx_ring[i].cmd_status = 0;
 	}
 
+	if (unlikely(bql_disable))
+		netdev_reset_queue(dev);
+
 	/* 2) RX ring */
 	np->dirty_rx = 0;
 	np->cur_rx = RX_RING_SIZE;
@@ -2012,6 +2020,9 @@ static void drain_tx(struct net_device *dev)
 		}
 		np->tx_skbuff[i] = NULL;
 	}
+
+	if (unlikely(bql_disable))
+		netdev_reset_queue(dev);
 }
 
 static void drain_rx(struct net_device *dev)
@@ -2116,6 +2127,9 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb_irq(skb);
 		dev->stats.tx_dropped++;
 	}
+
+	if (unlikely(bql_disable))
+		netdev_sent_queue(dev, skb->len);
 	spin_unlock_irqrestore(&np->lock, flags);
 
 	if (netif_msg_tx_queued(np)) {
@@ -2128,6 +2142,7 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
 static void netdev_tx_done(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
+	unsigned bytes_compl = 0, pkts_compl = 0;
 
 	for (; np->cur_tx - np->dirty_tx > 0; np->dirty_tx++) {
 		int entry = np->dirty_tx % TX_RING_SIZE;
@@ -2158,9 +2173,15 @@ static void netdev_tx_done(struct net_device *dev)
 					np->tx_skbuff[entry]->len,
 					PCI_DMA_TODEVICE);
 		/* Free the original skb. */
+		bytes_compl += np->tx_skbuff[entry]->len;
+		pkts_compl++;
 		dev_kfree_skb_irq(np->tx_skbuff[entry]);
 		np->tx_skbuff[entry] = NULL;
 	}
+
+	if (unlikely(bql_disable))
+		netdev_completed_queue(dev, pkts_compl, bytes_compl);
+
 	if (netif_queue_stopped(dev) &&
 	    np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
 		/* The ring is no longer full, wake queue. */
-- 
1.8.4.1
