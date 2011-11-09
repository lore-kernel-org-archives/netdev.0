From: Mark Kamichoff <prox@prolixium.com>
Subject: [PATCH][RESEND] net/usb: Misc. fixes for the LG-VL600 LTE USB modem
Date: Wed,  9 Nov 2011 16:48:10 -0500
Message-ID: <1320875290-29407-1-git-send-email-prox@prolixium.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Mark Kamichoff <prox@prolixium.com>
To: oliver@neukum.name, gregkh@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add checking for valid magic values (needed for stability in the event
corrupted packets are received) and remove some other unneeded checks.
Also, fix flagging device as WWAN (Bugzilla bug #39952).

Signed-off-by: Mark Kamichoff <prox@prolixium.com>
---
 drivers/net/usb/cdc_ether.c |    2 +-
 drivers/net/usb/lg-vl600.c  |   25 +++++++++++--------------
 2 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index c924ea2..99ed6eb 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -567,7 +567,7 @@ static const struct usb_device_id	products [] = {
 {
 	USB_DEVICE_AND_INTERFACE_INFO(0x1004, 0x61aa, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
-	.driver_info = (unsigned long)&wwan_info,
+	.driver_info = 0,
 },
 
 /*
diff --git a/drivers/net/usb/lg-vl600.c b/drivers/net/usb/lg-vl600.c
index d43db32..9c26c63 100644
--- a/drivers/net/usb/lg-vl600.c
+++ b/drivers/net/usb/lg-vl600.c
@@ -144,10 +144,11 @@ static int vl600_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	}
 
 	frame = (struct vl600_frame_hdr *) buf->data;
-	/* NOTE: Should check that frame->magic == 0x53544448?
-	 * Otherwise if we receive garbage at the beginning of the frame
-	 * we may end up allocating a huge buffer and saving all the
-	 * future incoming data into it.  */
+	/* Yes, check that frame->magic == 0x53544448 (or 0x44544d48),
+	 * otherwise we may run out of memory w/a bad packet */
+	if (ntohl(frame->magic) != 0x53544448 &&
+			ntohl(frame->magic) != 0x44544d48)
+		goto error;
 
 	if (buf->len < sizeof(*frame) ||
 			buf->len != le32_to_cpup(&frame->len)) {
@@ -296,6 +297,11 @@ encapsulate:
 	 * overwrite the remaining fields.
 	 */
 	packet = (struct vl600_pkt_hdr *) skb->data;
+	/* The VL600 wants IPv6 packets to have an IPv4 ethertype
+	 * Since this modem only supports IPv4 and IPv6, just set all
+	 * frames to 0x0800 (ETH_P_IP)
+	 */
+	packet->h_proto = htons(ETH_P_IP);
 	memset(&packet->dummy, 0, sizeof(packet->dummy));
 	packet->len = cpu_to_le32(orig_len);
 
@@ -308,21 +314,12 @@ encapsulate:
 	if (skb->len < full_len) /* Pad */
 		skb_put(skb, full_len - skb->len);
 
-	/* The VL600 wants IPv6 packets to have an IPv4 ethertype
-	 * Check if this is an IPv6 packet, and set the ethertype
-	 * to 0x800
-	 */
-	if ((skb->data[sizeof(struct vl600_pkt_hdr *) + 0x22] & 0xf0) == 0x60) {
-		skb->data[sizeof(struct vl600_pkt_hdr *) + 0x20] = 0x08;
-		skb->data[sizeof(struct vl600_pkt_hdr *) + 0x21] = 0;
-	}
-
 	return skb;
 }
 
 static const struct driver_info	vl600_info = {
 	.description	= "LG VL600 modem",
-	.flags		= FLAG_ETHER | FLAG_RX_ASSEMBLE,
+	.flags		= FLAG_RX_ASSEMBLE | FLAG_WWAN,
 	.bind		= vl600_bind,
 	.unbind		= vl600_unbind,
 	.status		= usbnet_cdc_status,
-- 
1.7.5.4
