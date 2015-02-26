From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [RFC][PATCH] usbnet: Fix tx_bytes statistic running backward in
 cdc_ncm
Date: Thu, 26 Feb 2015 19:43:43 +0000
Message-ID: <1424979823.4444.46.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ct-linux-kernel <linux-kernel@codethink.co.uk>,
	linux-usb@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:45627 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbbBZTnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 14:43:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cdc_ncm disagrees with usbnet about how much framing overhead should
be counted in the tx_bytes statistics, and tries 'fix' this by
decrementing tx_bytes on the transmit path.  But statistics must never
be decremented except due to roll-over; this will thoroughly confuse
user-space.  Also, tx_bytes is only incremented by usbnet in the
completion path.

Fix this by requiring drivers that set FLAG_MULTI_FRAME to set a
tx_bytes delta along with the tx_packets count.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
I noticed this bug while trying to fix the tx_packets statistic in asix.
It depends on the patch I just sent for that.  I don't have any hardware
to test this with, or any need to make it work.  If you want this fix,
please test and re-submit it yoursef.

Ben.

 drivers/net/usb/asix_common.c |    2 +-
 drivers/net/usb/cdc_ncm.c     |    7 +++----
 drivers/net/usb/sr9800.c      |    2 +-
 drivers/net/usb/usbnet.c      |   16 +++++++++++++---
 include/linux/usb/usbnet.h    |    6 ++++--
 5 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 724a9b50df7a..75d6f26729a3 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -189,7 +189,7 @@ struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 		skb_put(skb, sizeof(padbytes));
 	}
 
-	usbnet_set_skb_tx_stats(skb, 1);
+	usbnet_set_skb_tx_stats(skb, 1, 0);
 	return skb;
 }
 
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 70cbea551139..c3e4da9e79ca 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1177,13 +1177,12 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 	ctx->tx_overhead += skb_out->len - ctx->tx_curr_frame_payload;
 	ctx->tx_ntbs++;
 
-	/* usbnet has already counted all the framing overhead.
+	/* usbnet will count all the framing overhead by default.
 	 * Adjust the stats so that the tx_bytes counter show real
 	 * payload data instead.
 	 */
-	dev->net->stats.tx_bytes -= skb_out->len - ctx->tx_curr_frame_payload;
-
-	usbnet_set_skb_tx_stats(skb_out, n);
+	usbnet_set_skb_tx_stats(skb_out, n,
+				ctx->tx_curr_frame_payload - skb_out->len);
 
 	return skb_out;
 
diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
index 7650cdc8fe6b..953de13267df 100644
--- a/drivers/net/usb/sr9800.c
+++ b/drivers/net/usb/sr9800.c
@@ -144,7 +144,7 @@ static struct sk_buff *sr_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 		skb_put(skb, sizeof(padbytes));
 	}
 
-	usbnet_set_skb_tx_stats(skb, 1);
+	usbnet_set_skb_tx_stats(skb, 1, 0);
 	return skb;
 }
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 0f3ff285f6a1..777757ae1973 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1346,9 +1346,19 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		} else
 			urb->transfer_flags |= URB_ZERO_PACKET;
 	}
-	entry->length = urb->transfer_buffer_length = length;
-	if (!(info->flags & FLAG_MULTI_PACKET))
-		usbnet_set_skb_tx_stats(skb, 1);
+	urb->transfer_buffer_length = length;
+
+	if (info->flags & FLAG_MULTI_PACKET) {
+		/* Driver has set number of packets and a length delta.
+		 * Calculate the complete length and ensure that it's
+		 * positive.
+		 */
+		entry->length += length;
+		if (WARN_ON_ONCE(entry->length <= 0))
+			entry->length = length;
+	} else {
+		usbnet_set_skb_tx_stats(skb, 1, length);
+	}
 
 	spin_lock_irqsave(&dev->txq.lock, flags);
 	retval = usb_autopm_get_interface_async(dev->intf);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index ff3fb2bd0e90..6e0ce8c7b8cb 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -227,7 +227,7 @@ struct skb_data {	/* skb->cb is one of these */
 	struct urb		*urb;
 	struct usbnet		*dev;
 	enum skb_state		state;
-	size_t			length;
+	long			length;
 	unsigned long		packets;
 };
 
@@ -235,11 +235,13 @@ struct skb_data {	/* skb->cb is one of these */
  * tx_fixup method before returning an skb.
  */
 static inline void
-usbnet_set_skb_tx_stats(struct sk_buff *skb, unsigned long packets)
+usbnet_set_skb_tx_stats(struct sk_buff *skb,
+			unsigned long packets, long bytes_delta)
 {
 	struct skb_data *entry = (struct skb_data *) skb->cb;
 
 	entry->packets = packets;
+	entry->length = bytes_delta;
 }
 
 extern int usbnet_open(struct net_device *net);
-- 
1.7.10.4
