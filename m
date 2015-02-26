From: Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Subject: [PATCH net-next] usbnet: Fix tx_packets stat for FLAG_MULTI_FRAME
 drivers
Date: Thu, 26 Feb 2015 19:34:37 +0000
Message-ID: <1424979277.4444.39.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ct-linux-kernel <linux-kernel-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently the usbnet core does not update the tx_packets statistic for
drivers with FLAG_MULTI_PACKET and there is no hook in the TX
completion path where they could do this.

cdc_ncm and dependent drivers are bumping tx_packets stat on the
transmit path while asix and sr9800 aren't updating it at all.

Add a packet count in struct skb_data so these drivers can fill it
in, initialise it to 1 for other drivers, and add the packet count
to the tx_packets statistic on completion.

Signed-off-by: Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
---
I have only tested the asix driver after this change; I think cdc_ncm
and one of the non-multi-packet drivers should also be tested before
it's applied.

Ben.

 drivers/net/usb/asix_common.c |    2 ++
 drivers/net/usb/cdc_ncm.c     |    3 ++-
 drivers/net/usb/sr9800.c      |    1 +
 drivers/net/usb/usbnet.c      |    5 +++--
 include/linux/usb/usbnet.h    |   12 ++++++++++++
 5 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 5c55f11572ba..724a9b50df7a 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -188,6 +188,8 @@ struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 		memcpy(skb_tail_pointer(skb), &padbytes, sizeof(padbytes));
 		skb_put(skb, sizeof(padbytes));
 	}
+
+	usbnet_set_skb_tx_stats(skb, 1);
 	return skb;
 }
 
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 80a844e0ae03..70cbea551139 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1172,7 +1172,6 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 
 	/* return skb */
 	ctx->tx_curr_skb = NULL;
-	dev->net->stats.tx_packets += ctx->tx_curr_frame_num;
 
 	/* keep private stats: framing overhead and number of NTBs */
 	ctx->tx_overhead += skb_out->len - ctx->tx_curr_frame_payload;
@@ -1184,6 +1183,8 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 	 */
 	dev->net->stats.tx_bytes -= skb_out->len - ctx->tx_curr_frame_payload;
 
+	usbnet_set_skb_tx_stats(skb_out, n);
+
 	return skb_out;
 
 exit_no_skb:
diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
index b94a0fbb8b3b..7650cdc8fe6b 100644
--- a/drivers/net/usb/sr9800.c
+++ b/drivers/net/usb/sr9800.c
@@ -144,6 +144,7 @@ static struct sk_buff *sr_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 		skb_put(skb, sizeof(padbytes));
 	}
 
+	usbnet_set_skb_tx_stats(skb, 1);
 	return skb;
 }
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 449835f4331e..0f3ff285f6a1 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1188,8 +1188,7 @@ static void tx_complete (struct urb *urb)
 	struct usbnet		*dev = entry->dev;
 
 	if (urb->status == 0) {
-		if (!(dev->driver_info->flags & FLAG_MULTI_PACKET))
-			dev->net->stats.tx_packets++;
+		dev->net->stats.tx_packets += entry->packets;
 		dev->net->stats.tx_bytes += entry->length;
 	} else {
 		dev->net->stats.tx_errors++;
@@ -1348,6 +1347,8 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 			urb->transfer_flags |= URB_ZERO_PACKET;
 	}
 	entry->length = urb->transfer_buffer_length = length;
+	if (!(info->flags & FLAG_MULTI_PACKET))
+		usbnet_set_skb_tx_stats(skb, 1);
 
 	spin_lock_irqsave(&dev->txq.lock, flags);
 	retval = usb_autopm_get_interface_async(dev->intf);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index d9a4905e01d0..ff3fb2bd0e90 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -228,8 +228,20 @@ struct skb_data {	/* skb->cb is one of these */
 	struct usbnet		*dev;
 	enum skb_state		state;
 	size_t			length;
+	unsigned long		packets;
 };
 
+/* Drivers that set FLAG_MULTI_PACKET must call this in their
+ * tx_fixup method before returning an skb.
+ */
+static inline void
+usbnet_set_skb_tx_stats(struct sk_buff *skb, unsigned long packets)
+{
+	struct skb_data *entry = (struct skb_data *) skb->cb;
+
+	entry->packets = packets;
+}
+
 extern int usbnet_open(struct net_device *net);
 extern int usbnet_stop(struct net_device *net);
 extern netdev_tx_t usbnet_start_xmit(struct sk_buff *skb,
-- 
1.7.10.4



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
