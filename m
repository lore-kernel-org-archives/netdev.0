From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1] USBNET: fix handling padding packet
Date: Mon, 23 Sep 2013 20:59:35 +0800
Message-ID: <1379941175-10500-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:58455 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967Ab3IWM7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 08:59:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 638c5115a7949(USBNET: support DMA SG) introduces DMA SG
if the usb host controller is capable of building packet from
discontinuous buffers, but missed handling padding packet when
building DMA SG.

This patch attachs the pre-allocated padding packet at the
end of the sg list, so padding packet can be sent to device
if drivers require that.

Reported-by: David Laight <David.Laight@aculab.com>
Acked-by: Oliver Neukum <oliver@neukum.org>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
v1:
	- fix bug in case of dev->can_dma_sg and !urb->num_sgs
---
 drivers/net/usb/usbnet.c   |   27 +++++++++++++++++++++------
 include/linux/usb/usbnet.h |    1 +
 2 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 7b331e6..bf94e10 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1241,7 +1241,9 @@ static int build_dma_sg(const struct sk_buff *skb, struct urb *urb)
 	if (num_sgs == 1)
 		return 0;
 
-	urb->sg = kmalloc(num_sgs * sizeof(struct scatterlist), GFP_ATOMIC);
+	/* reserve one for zero packet */
+	urb->sg = kmalloc((num_sgs + 1) * sizeof(struct scatterlist),
+			  GFP_ATOMIC);
 	if (!urb->sg)
 		return -ENOMEM;
 
@@ -1305,7 +1307,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		if (build_dma_sg(skb, urb) < 0)
 			goto drop;
 	}
-	entry->length = length = urb->transfer_buffer_length;
+	length = urb->transfer_buffer_length;
 
 	/* don't assume the hardware handles USB_ZERO_PACKET
 	 * NOTE:  strictly conforming cdc-ether devices should expect
@@ -1317,15 +1319,18 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	if (length % dev->maxpacket == 0) {
 		if (!(info->flags & FLAG_SEND_ZLP)) {
 			if (!(info->flags & FLAG_MULTI_PACKET)) {
-				urb->transfer_buffer_length++;
-				if (skb_tailroom(skb)) {
+				length++;
+				if (skb_tailroom(skb) && !urb->num_sgs) {
 					skb->data[skb->len] = 0;
 					__skb_put(skb, 1);
-				}
+				} else if (urb->num_sgs)
+					sg_set_buf(&urb->sg[urb->num_sgs++],
+							dev->padding_pkt, 1);
 			}
 		} else
 			urb->transfer_flags |= URB_ZERO_PACKET;
 	}
+	entry->length = urb->transfer_buffer_length = length;
 
 	spin_lock_irqsave(&dev->txq.lock, flags);
 	retval = usb_autopm_get_interface_async(dev->intf);
@@ -1509,6 +1514,7 @@ void usbnet_disconnect (struct usb_interface *intf)
 
 	usb_kill_urb(dev->interrupt);
 	usb_free_urb(dev->interrupt);
+	kfree(dev->padding_pkt);
 
 	free_netdev(net);
 }
@@ -1679,9 +1685,16 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	/* initialize max rx_qlen and tx_qlen */
 	usbnet_update_max_qlen(dev);
 
+	if (dev->can_dma_sg && !(info->flags & FLAG_SEND_ZLP) &&
+		!(info->flags & FLAG_MULTI_PACKET)) {
+		dev->padding_pkt = kzalloc(1, GFP_KERNEL);
+		if (!dev->padding_pkt)
+			goto out4;
+	}
+
 	status = register_netdev (net);
 	if (status)
-		goto out4;
+		goto out5;
 	netif_info(dev, probe, dev->net,
 		   "register '%s' at usb-%s-%s, %s, %pM\n",
 		   udev->dev.driver->name,
@@ -1699,6 +1712,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 
 	return 0;
 
+out5:
+	kfree(dev->padding_pkt);
 out4:
 	usb_free_urb(dev->interrupt);
 out3:
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 9cb2fe8..e303eef 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -42,6 +42,7 @@ struct usbnet {
 	struct usb_host_endpoint *status;
 	unsigned		maxpacket;
 	struct timer_list	delay;
+	const char		*padding_pkt;
 
 	/* protocol/interface state */
 	struct net_device	*net;
-- 
1.7.9.5
