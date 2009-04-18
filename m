From: "Peter Holik" <peter-xHLhtm3VSFg@public.gmane.org>
Subject: [Resend][PATCH] usb driver for intellon int51x1 based PLC like
     devolo dlan duo
Date: Sat, 18 Apr 2009 11:31:51 +0200 (CEST)
Message-ID: <cb6d2886e87af66d945f1052e6eb8a85.squirrel@webmail.it-technology.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a usb driver for the intellon int51x1 based PLC
(Powerline Communications) like devolo dlan duo.

Signed-off-by: Peter Holik <peter-xHLhtm3VSFg@public.gmane.org>
---
 drivers/net/usb/Kconfig   |    8 ++
 drivers/net/usb/Makefile  |    1 +
 drivers/net/usb/int51x1.c |  268 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 277 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/int51x1.c

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 8ee2103..86c9e86 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -345,4 +345,12 @@ config USB_HSO
 	  To compile this driver as a module, choose M here: the
 	  module will be called hso.

+config USB_NET_INT51X1
+	tristate "Intellon PLC based usb adapter"
+	depends on USB_USBNET
+	help
+	  Choose this option if you're using a USB-based PLC
+	  (Powerline Communications) solution with an Intellon
+	  int51x1 chip, like the "devolo dLan duo".
+
 endmenu
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 88a87ee..f4402a0 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -19,4 +19,5 @@ obj-$(CONFIG_USB_NET_CDC_SUBSET)	+= cdc_subset.o
 obj-$(CONFIG_USB_NET_ZAURUS)	+= zaurus.o
 obj-$(CONFIG_USB_NET_MCS7830)	+= mcs7830.o
 obj-$(CONFIG_USB_USBNET)	+= usbnet.o
+obj-$(CONFIG_USB_NET_INT51X1)	+= int51x1.o

diff --git a/drivers/net/usb/int51x1.c b/drivers/net/usb/int51x1.c
new file mode 100644
index 0000000..44a8a09
--- /dev/null
+++ b/drivers/net/usb/int51x1.c
@@ -0,0 +1,268 @@
+/*
+ * Copyright (c) 2009 Peter Holik
+ *
+ * Intellon usb PLC (Powerline Communications) usb net driver
+ *
+ * http://www.tandel.be/downloads/INT51X1_Datasheet.pdf
+ *
+ * Based on the work of Jan 'RedBully' Seiffert
+ */
+
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or.
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+#include <linux/module.h>
+#include <linux/ctype.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/usb.h>
+#include <linux/usb/usbnet.h>
+
+#define INT51X1_VENDOR_ID	0x09e1
+#define INT51X1_PRODUCT_ID	0x5121
+
+#define INT51X1_HEADER_SIZE	2	/* 2 byte header */
+
+#define PACKET_TYPE_PROMISCUOUS		(1 << 0)
+#define PACKET_TYPE_ALL_MULTICAST	(1 << 1) /* no filter */
+#define PACKET_TYPE_DIRECTED		(1 << 2)
+#define PACKET_TYPE_BROADCAST		(1 << 3)
+#define PACKET_TYPE_MULTICAST		(1 << 4) /* filtered */
+
+#define SET_ETHERNET_PACKET_FILTER	0x43
+
+static u8 nibble(unsigned char c)
+{
+	if (likely(isdigit(c)))
+		return c - '0';
+	c = toupper(c);
+	if (likely(isxdigit(c)))
+		return 10 + c - 'A';
+	return 0;
+}
+
+static inline int get_ethernet_addr(struct usbnet *dev)
+{
+	int             tmp, i;
+	unsigned char   buf [13];
+
+	tmp = usb_string(dev->udev, 3, buf, sizeof buf);
+	if (tmp != 12) {
+		devdbg(dev, "bad MAC string fetch, %d\n", tmp);
+		if (tmp >= 0)
+			tmp = -EINVAL;
+		return tmp;
+	}
+	for (i = tmp = 0; i < 6; i++, tmp += 2)
+		dev->net->dev_addr [i] =
+			(nibble(buf [tmp]) << 4) + nibble(buf [tmp + 1]);
+	return 0;
+}
+
+static int int51x1_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	int len;
+
+	if (unlikely(skb->len < INT51X1_HEADER_SIZE)) {
+		deverr(dev, "unexpected tiny rx frame");
+		return 0;
+	}
+
+	len = le16_to_cpu(*(__le16 *)&skb->data[skb->len - 2]);
+
+	skb_trim(skb, len);
+
+	return 1;
+}
+
+static struct sk_buff *int51x1_tx_fixup(struct usbnet *dev,
+		struct sk_buff *skb, gfp_t flags)
+{
+	int pack_len = skb->len;
+	int headroom = skb_headroom(skb);
+	int tailroom = skb_tailroom(skb);
+	int need_tail = 0;
+	__le16 *len;
+
+	/*
+	 * usbnet would send a ZLP if packetlength mod urbsize == 0 for us,
+	 * but we need to know ourself, because this would add to the length
+	 * we send down to the device...
+	 */
+	if (!((pack_len + INT51X1_HEADER_SIZE) % dev->maxpacket))
+		need_tail = 1;
+
+	/* if packet and our header is smaler than 64 pad to 64 (+ ZLP) */
+	if ((pack_len + INT51X1_HEADER_SIZE + need_tail) < dev->maxpacket + 1)
+		need_tail = dev->maxpacket + 1 - pack_len - INT51X1_HEADER_SIZE;
+
+	if (!skb_cloned(skb) &&
+			(headroom + tailroom >= need_tail + INT51X1_HEADER_SIZE)) {
+		if (headroom < INT51X1_HEADER_SIZE || tailroom < need_tail) {
+			skb->data = memmove(skb->head + INT51X1_HEADER_SIZE,
+					skb->data, skb->len);
+			skb_set_tail_pointer(skb, skb->len);
+		}
+	} else {
+		struct sk_buff *skb2;
+
+		skb2 = skb_copy_expand(skb,
+				INT51X1_HEADER_SIZE,
+				need_tail,
+				flags);
+		dev_kfree_skb_any(skb);
+		if (!skb2)
+			return NULL;
+		skb = skb2;
+	}
+
+	pack_len += need_tail;
+	pack_len &= 0x07ff;
+
+	len = (__le16 *) __skb_push(skb, INT51X1_HEADER_SIZE);
+	*len = cpu_to_le16(pack_len);
+
+	if(need_tail)
+		memset(__skb_put(skb, need_tail), 0, need_tail);
+
+	return skb;
+}
+
+static void int51x1_async_cmd_callback(struct urb *urb)
+{
+	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
+	int status = urb->status;
+
+	if (status < 0)
+		dev_warn(&urb->dev->dev, "async callback failed with %d\n", status);
+
+	kfree(req);
+	usb_free_urb(urb);
+}
+
+static void int51x1_set_multicast(struct net_device *netdev)
+{
+	struct usb_ctrlrequest *req;
+	int status;
+	struct urb *urb;
+	struct usbnet *dev = netdev_priv(netdev);
+	u16 filter = PACKET_TYPE_DIRECTED |
+		     PACKET_TYPE_BROADCAST;
+
+	if (netdev->flags & IFF_PROMISC) {
+		/* do not expect to see traffic of other PLCs */
+		filter |= PACKET_TYPE_PROMISCUOUS;
+		devinfo(dev, "promiscuous mode enabled");
+	} else if (netdev->mc_count ||
+		  (netdev->flags & IFF_ALLMULTI)) {
+		filter |= PACKET_TYPE_ALL_MULTICAST;
+		devdbg(dev, "receive all multicast enabled");
+	} else {
+		/* ~PROMISCUOUS, ~MULTICAST */
+		devdbg(dev, "receive own packets only");
+	}
+
+	urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (!urb) {
+		devwarn(dev, "Error allocating URB");
+		return;
+	}
+
+	req = kmalloc(sizeof *req, GFP_ATOMIC);
+	if (!req) {
+		devwarn(dev, "Error allocating control msg");
+		usb_free_urb(urb);
+		return;
+	}
+
+	req->bRequestType = USB_DIR_OUT | USB_TYPE_CLASS | USB_RECIP_INTERFACE;
+	req->bRequest = SET_ETHERNET_PACKET_FILTER;
+	req->wValue = cpu_to_le16(filter);
+	req->wIndex = 0;
+	req->wLength = 0;
+
+	usb_fill_control_urb(urb, dev->udev, usb_sndctrlpipe(dev->udev, 0),
+		(void *)req, NULL, 0,
+		int51x1_async_cmd_callback,
+		(void *)req);
+
+	status = usb_submit_urb(urb, GFP_ATOMIC);
+	if (status < 0) {
+		devwarn(dev, "Error submitting control msg, sts=%d", status);
+		kfree(req);
+		usb_free_urb(urb);
+	}
+}
+
+static int int51x1_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int status = get_ethernet_addr(dev);
+
+	if (status)
+		return status;
+
+	dev->net->hard_header_len += INT51X1_HEADER_SIZE;
+	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+	dev->net->set_multicast_list = int51x1_set_multicast;
+
+	return usbnet_get_endpoints(dev, intf);
+}
+
+static const struct driver_info int51x1_info = {
+	.description = "Intellon usb powerline adapter",
+	.bind        = int51x1_bind,
+	.rx_fixup    = int51x1_rx_fixup,
+	.tx_fixup    = int51x1_tx_fixup,
+	.in          = 1,
+	.out         = 2,
+	.flags      = FLAG_ETHER,
+};
+
+static const struct usb_device_id products[] = {
+	{
+	USB_DEVICE(INT51X1_VENDOR_ID, INT51X1_PRODUCT_ID),
+		.driver_info = (unsigned long) &int51x1_info,
+	},
+	{},
+};
+MODULE_DEVICE_TABLE(usb, products);
+
+static struct usb_driver int51x1_driver = {
+	.name       = "int51x1",
+	.id_table   = products,
+	.probe      = usbnet_probe,
+	.disconnect = usbnet_disconnect,
+	.suspend    = usbnet_suspend,
+	.resume     = usbnet_resume,
+};
+
+static int __init int51x1_init(void)
+{
+	return usb_register(&int51x1_driver);
+}
+module_init(int51x1_init);
+
+static void __exit int51x1_exit(void)
+{
+	usb_deregister(&int51x1_driver);
+}
+module_exit(int51x1_exit);
+
+MODULE_AUTHOR("Peter Holik");
+MODULE_DESCRIPTION("Intellon usb powerline adapter");
+MODULE_LICENSE("GPL");
-- 
1.6.2.1


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
