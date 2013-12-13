From: freddy@asix.com.tw
Subject: [PATCH 1/1] AX88179_178A: Add FLAG_HW_IPALIGN to determine whether reserving NET_IP_ALIGN bytes for an SKB.
Date: Fri, 13 Dec 2013 17:25:08 +0800
Message-ID: <1386926708-2343-1-git-send-email-freddy@asix.com.tw>
Cc: Freddy Xin <freddy@asix.com.tw>
To: netdev@vger.kernel.org, davem@davemloft.net,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	louis@asix.com.tw, allan@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Freddy Xin <freddy@asix.com.tw>

The AX88179_178A has a hardware feature that it can insert a
2-bytes pseudo header in front of each received frame by setting
the AX_RX_CTL_IPE bit. This feature is used to let the IP header
be aligned on a doubleword-aligned address, so the rx_submit() of
usbnet.c needn't reserve NET_IP_ALIGN bytes for an SKB in the case.

This patch adds a flag of driver_info "FLAG_HW_IPALIGN" which is
used in rx_submit() of usbnet.c to determine whether reserving
NET_IP_ALIGN bytes for an SKB.

Signed-off-by: Freddy Xin <freddy@asix.com.tw>
---
 drivers/net/usb/ax88179_178a.c | 8 ++++----
 drivers/net/usb/usbnet.c       | 5 ++++-
 include/linux/usb/usbnet.h     | 3 +++
 3 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 8e8d0fc..04a2cc9 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1374,7 +1374,7 @@ static const struct driver_info ax88179_info = {
 	.link_reset = ax88179_link_reset,
 	.reset = ax88179_reset,
 	.stop = ax88179_stop,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_HW_IPALIGN,
 	.rx_fixup = ax88179_rx_fixup,
 	.tx_fixup = ax88179_tx_fixup,
 };
@@ -1387,7 +1387,7 @@ static const struct driver_info ax88178a_info = {
 	.link_reset = ax88179_link_reset,
 	.reset = ax88179_reset,
 	.stop = ax88179_stop,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_HW_IPALIGN,
 	.rx_fixup = ax88179_rx_fixup,
 	.tx_fixup = ax88179_tx_fixup,
 };
@@ -1400,7 +1400,7 @@ static const struct driver_info sitecom_info = {
 	.link_reset = ax88179_link_reset,
 	.reset = ax88179_reset,
 	.stop = ax88179_stop,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_HW_IPALIGN,
 	.rx_fixup = ax88179_rx_fixup,
 	.tx_fixup = ax88179_tx_fixup,
 };
@@ -1413,7 +1413,7 @@ static const struct driver_info samsung_info = {
 	.link_reset = ax88179_link_reset,
 	.reset = ax88179_reset,
 	.stop = ax88179_stop,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_HW_IPALIGN,
 	.rx_fixup = ax88179_rx_fixup,
 	.tx_fixup = ax88179_tx_fixup,
 };
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8494bb5..8a618b8 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -473,7 +473,10 @@ static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 		return -ENOLINK;
 	}
 
-	skb = __netdev_alloc_skb_ip_align(dev->net, size, flags);
+	if (dev->driver_info->flags & FLAG_HW_IPALIGN)
+		skb = __netdev_alloc_skb(dev->net, size, flags);
+	else
+		skb = __netdev_alloc_skb_ip_align(dev->net, size, flags);
 	if (!skb) {
 		netif_dbg(dev, rx_err, dev->net, "no rx skb\n");
 		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index e303eef..e4855cf 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -116,6 +116,9 @@ struct driver_info {
 #define FLAG_MULTI_PACKET	0x2000
 #define FLAG_RX_ASSEMBLE	0x4000	/* rx packets may span >1 frames */
 #define FLAG_NOARP		0x8000	/* device can't do ARP */
+#define FLAG_HW_IPALIGN		0x10000 /* hardware adds headers to let the
+					 * IP header align on a dword-aligned
+					 * address */
 
 	/* init device ... can sleep, or cause probe() failure */
 	int	(*bind)(struct usbnet *, struct usb_interface *);
-- 
1.8.3.2
