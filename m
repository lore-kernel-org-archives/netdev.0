From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 64/77] zd1201: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:31 -0700
Message-ID: <20090321053717.440414565@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, pe1rxq-QXXXXQs8DbXYtjvyW6yDsg@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=zd1201-stats.patch
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

--- a/drivers/net/wireless/zd1201.c	2009-03-20 21:45:40.866964137 -0700
+++ b/drivers/net/wireless/zd1201.c	2009-03-20 22:26:00.356902321 -0700
@@ -328,8 +328,8 @@ static void zd1201_usbrx(struct urb *urb
 			memcpy(skb_put(skb, 2), &data[datalen-24], 2);
 			memcpy(skb_put(skb, len), data, len);
 			skb->protocol = eth_type_trans(skb, zd->dev);
-			zd->stats.rx_packets++;
-			zd->stats.rx_bytes += skb->len;
+			zd->dev->stats.rx_packets++;
+			zd->dev->stats.rx_bytes += skb->len;
 			netif_rx(skb);
 			goto resubmit;
 		}
@@ -384,8 +384,8 @@ static void zd1201_usbrx(struct urb *urb
 			memcpy(skb_put(skb, len), data+8, len);
 		}
 		skb->protocol = eth_type_trans(skb, zd->dev);
-		zd->stats.rx_packets++;
-		zd->stats.rx_bytes += skb->len;
+		zd->dev->stats.rx_packets++;
+		zd->dev->stats.rx_bytes += skb->len;
 		netif_rx(skb);
 	}
 resubmit:
@@ -787,7 +787,7 @@ static int zd1201_hard_start_xmit(struct
 	struct urb *urb = zd->tx_urb;
 
 	if (!zd->mac_enabled || zd->monitor) {
-		zd->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		kfree_skb(skb);
 		return 0;
 	}
@@ -817,12 +817,12 @@ static int zd1201_hard_start_xmit(struct
 
 	err = usb_submit_urb(zd->tx_urb, GFP_ATOMIC);
 	if (err) {
-		zd->stats.tx_errors++;
+		dev->stats.tx_errors++;
 		netif_start_queue(dev);
 		return err;
 	}
-	zd->stats.tx_packets++;
-	zd->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 	dev->trans_start = jiffies;
 	kfree_skb(skb);
 
@@ -838,7 +838,7 @@ static void zd1201_tx_timeout(struct net
 	dev_warn(&zd->usb->dev, "%s: TX timeout, shooting down urb\n",
 	    dev->name);
 	usb_unlink_urb(zd->tx_urb);
-	zd->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	/* Restart the timeout to quiet the watchdog: */
 	dev->trans_start = jiffies;
 }
@@ -861,13 +861,6 @@ static int zd1201_set_mac_address(struct
 	return zd1201_mac_reset(zd);
 }
 
-static struct net_device_stats *zd1201_get_stats(struct net_device *dev)
-{
-	struct zd1201 *zd = netdev_priv(dev);
-
-	return &zd->stats;
-}
-
 static struct iw_statistics *zd1201_get_wireless_stats(struct net_device *dev)
 {
 	struct zd1201 *zd = netdev_priv(dev);
@@ -1778,9 +1771,7 @@ static int zd1201_probe(struct usb_inter
 
 	dev->open = zd1201_net_open;
 	dev->stop = zd1201_net_stop;
-	dev->get_stats = zd1201_get_stats;
-	dev->wireless_handlers =
-	    (struct iw_handler_def *)&zd1201_iw_handlers;
+	dev->wireless_handlers = &zd1201_iw_handlers;
 	dev->hard_start_xmit = zd1201_hard_start_xmit;
 	dev->watchdog_timeo = ZD1201_TX_TIMEOUT;
 	dev->tx_timeout = zd1201_tx_timeout;
--- a/drivers/net/wireless/zd1201.h	2009-03-20 21:45:40.859963944 -0700
+++ b/drivers/net/wireless/zd1201.h	2009-03-20 22:26:00.356902321 -0700
@@ -26,7 +26,6 @@ struct zd1201 {
 	struct usb_device	*usb;
 	int			removed;
 	struct net_device	*dev;
-	struct net_device_stats stats;
 	struct iw_statistics	iwstats;
 
 	int			endp_in;

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
