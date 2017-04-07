From: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Subject: [PATCH net-next 13/14] usbnet: kaweth: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:38 +0200
Message-ID: <20170407081739.5243-14-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170407081739.5243-1-tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Instead of using a private copy of struct net_device_stats in struct
kaweth_device, use stats from struct net_device. Also remove the now
unnecessary .ndo_get_stats function.

Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
---
 drivers/net/usb/kaweth.c | 32 ++++++++++----------------------
 1 file changed, 10 insertions(+), 22 deletions(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 876f02f4945e..3d8ea18df696 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -245,8 +245,6 @@ struct kaweth_device
 	__u16 packet_filter_bitmap;
 
 	struct kaweth_ethernet_configuration configuration;
-
-	struct net_device_stats stats;
 };
 
 /****************************************************************
@@ -598,7 +596,7 @@ static void kaweth_usb_receive(struct urb *urb)
 	struct sk_buff *skb;
 
 	if (unlikely(status == -EPIPE)) {
-		kaweth->stats.rx_errors++;
+		net->stats.rx_errors++;
 		kaweth->end = 1;
 		wake_up(&kaweth->term_wait);
 		dev_dbg(dev, "Status was -EPIPE.\n");
@@ -613,12 +611,12 @@ static void kaweth_usb_receive(struct urb *urb)
 	}
 	if (unlikely(status == -EPROTO || status == -ETIME ||
 		     status == -EILSEQ)) {
-		kaweth->stats.rx_errors++;
+		net->stats.rx_errors++;
 		dev_dbg(dev, "Status was -EPROTO, -ETIME, or -EILSEQ.\n");
 		return;
 	}
 	if (unlikely(status == -EOVERFLOW)) {
-		kaweth->stats.rx_errors++;
+		net->stats.rx_errors++;
 		dev_dbg(dev, "Status was -EOVERFLOW.\n");
 	}
 	spin_lock(&kaweth->device_lock);
@@ -663,8 +661,8 @@ static void kaweth_usb_receive(struct urb *urb)
 
 		netif_rx(skb);
 
-		kaweth->stats.rx_packets++;
-		kaweth->stats.rx_bytes += pkt_len;
+		net->stats.rx_packets++;
+		net->stats.rx_bytes += pkt_len;
 	}
 
 	kaweth_resubmit_rx_urb(kaweth, GFP_ATOMIC);
@@ -810,7 +808,7 @@ static netdev_tx_t kaweth_start_xmit(struct sk_buff *skb,
 		dev_kfree_skb_irq(skb);
 		skb = copied_skb;
 		if (!copied_skb) {
-			kaweth->stats.tx_errors++;
+			net->stats.tx_errors++;
 			netif_start_queue(net);
 			spin_unlock_irq(&kaweth->device_lock);
 			return NETDEV_TX_OK;
@@ -834,15 +832,15 @@ static netdev_tx_t kaweth_start_xmit(struct sk_buff *skb,
 	{
 		dev_warn(&net->dev, "kaweth failed tx_urb %d\n", res);
 skip:
-		kaweth->stats.tx_errors++;
+		net->stats.tx_errors++;
 
 		netif_start_queue(net);
 		dev_kfree_skb_irq(skb);
 	}
 	else
 	{
-		kaweth->stats.tx_packets++;
-		kaweth->stats.tx_bytes += skb->len;
+		net->stats.tx_packets++;
+		net->stats.tx_bytes += skb->len;
 	}
 
 	spin_unlock_irq(&kaweth->device_lock);
@@ -912,15 +910,6 @@ static void kaweth_async_set_rx_mode(struct kaweth_device *kaweth)
 }
 
 /****************************************************************
- *     kaweth_netdev_stats
- ****************************************************************/
-static struct net_device_stats *kaweth_netdev_stats(struct net_device *dev)
-{
-	struct kaweth_device *kaweth = netdev_priv(dev);
-	return &kaweth->stats;
-}
-
-/****************************************************************
  *     kaweth_tx_timeout
  ****************************************************************/
 static void kaweth_tx_timeout(struct net_device *net)
@@ -928,7 +917,7 @@ static void kaweth_tx_timeout(struct net_device *net)
 	struct kaweth_device *kaweth = netdev_priv(net);
 
 	dev_warn(&net->dev, "%s: Tx timed out. Resetting.\n", net->name);
-	kaweth->stats.tx_errors++;
+	net->stats.tx_errors++;
 	netif_trans_update(net);
 
 	usb_unlink_urb(kaweth->tx_urb);
@@ -981,7 +970,6 @@ static const struct net_device_ops kaweth_netdev_ops = {
 	.ndo_start_xmit =		kaweth_start_xmit,
 	.ndo_tx_timeout =		kaweth_tx_timeout,
 	.ndo_set_rx_mode =		kaweth_set_rx_mode,
-	.ndo_get_stats =		kaweth_netdev_stats,
 	.ndo_set_mac_address =		eth_mac_addr,
 	.ndo_validate_addr =		eth_validate_addr,
 };
-- 
2.12.2


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
