From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] usbnet: changes for upcoming cdc_ncm driver
Date: Tue, 23 Nov 2010 17:51:27 +0100
Message-ID: <1290531088-2393-1-git-send-email-alexey.orishko@stericsson.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org,
	yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, felipe.balbi-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org,
	sjur.brandeland-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: gregkh-l3A5Bk7waGM@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
---
Changes:
drivers/net/usb/usbnet.c:
- the procedure of counting packets in usbnet was updated due to the
 accumulating of IP packets in the CDC NCM driver
- no short packets sent for cdc_ncm driver
include/linux/usb/usbnet.h:
- a new flag to indicate driver's capability to accumulate IP packets in one
 skb before sending them (Tx direction)

 drivers/net/usb/usbnet.c   |   45 ++++++++++++++++++++++++++++++-------------
 include/linux/usb/usbnet.h |    6 +++++
 2 files changed, 37 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index c04d49e..ac1a66e 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -391,14 +391,19 @@ static inline void rx_process (struct usbnet *dev, struct sk_buff *skb)
 		goto error;
 	// else network stack removes extra byte if we forced a short packet
 
-	if (skb->len)
-		usbnet_skb_return (dev, skb);
-	else {
-		netif_dbg(dev, rx_err, dev->net, "drop\n");
-error:
-		dev->net->stats.rx_errors++;
-		skb_queue_tail (&dev->done, skb);
+	if (skb->len) {
+		/* all data was already cloned inside NCM driver */
+		if (dev->driver_info->flags & FLAG_MULTI_PACKET)
+			dev_kfree_skb_any(skb);
+		else
+			usbnet_skb_return(dev, skb);
+		return;
 	}
+
+	netif_dbg(dev, rx_err, dev->net, "drop\n");
+error:
+	dev->net->stats.rx_errors++;
+	skb_queue_tail(&dev->done, skb);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -971,7 +976,8 @@ static void tx_complete (struct urb *urb)
 	struct usbnet		*dev = entry->dev;
 
 	if (urb->status == 0) {
-		dev->net->stats.tx_packets++;
+		if (!(dev->driver_info->flags & FLAG_MULTI_PACKET))
+			dev->net->stats.tx_packets++;
 		dev->net->stats.tx_bytes += entry->length;
 	} else {
 		dev->net->stats.tx_errors++;
@@ -1044,8 +1050,13 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	if (info->tx_fixup) {
 		skb = info->tx_fixup (dev, skb, GFP_ATOMIC);
 		if (!skb) {
-			netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
-			goto drop;
+			if (netif_msg_tx_err(dev)) {
+				netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
+				goto drop;
+			} else {
+				/* cdc_ncm collected packet; waits for more */
+				goto not_drop;
+			}
 		}
 	}
 	length = skb->len;
@@ -1067,13 +1078,18 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	/* don't assume the hardware handles USB_ZERO_PACKET
 	 * NOTE:  strictly conforming cdc-ether devices should expect
 	 * the ZLP here, but ignore the one-byte packet.
+	 * NOTE2: CDC NCM specification is different from CDC ECM when
+	 * handling ZLP/short packets, so cdc_ncm driver will make short
+	 * packet itself if needed.
 	 */
 	if (length % dev->maxpacket == 0) {
 		if (!(info->flags & FLAG_SEND_ZLP)) {
-			urb->transfer_buffer_length++;
-			if (skb_tailroom(skb)) {
-				skb->data[skb->len] = 0;
-				__skb_put(skb, 1);
+			if (!(info->flags & FLAG_MULTI_PACKET)) {
+				urb->transfer_buffer_length++;
+				if (skb_tailroom(skb)) {
+					skb->data[skb->len] = 0;
+					__skb_put(skb, 1);
+				}
 			}
 		} else
 			urb->transfer_flags |= URB_ZERO_PACKET;
@@ -1122,6 +1138,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		netif_dbg(dev, tx_err, dev->net, "drop, code %d\n", retval);
 drop:
 		dev->net->stats.tx_dropped++;
+not_drop:
 		if (skb)
 			dev_kfree_skb_any (skb);
 		usb_free_urb (urb);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 7ae27a4..f2842cb 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -97,6 +97,12 @@ struct driver_info {
 
 #define FLAG_LINK_INTR	0x0800		/* updates link (carrier) status */
 
+/*
+ * Indicates to usbnet, that USB driver accumulates multiple IP packets before
+ * sending them. Affects statistic (counters) and short packet handling.
+ */
+#define FLAG_MULTI_PACKET	0x1000
+
 	/* init device ... can sleep, or cause probe() failure */
 	int	(*bind)(struct usbnet *, struct usb_interface *);
 
-- 
1.7.0.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
