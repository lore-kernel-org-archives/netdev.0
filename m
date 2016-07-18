From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Mon, 18 Jul 2016 14:24:51 +0200
Message-ID: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
Cc: Kristian Evensen <kristian.evensen@gmail.com>
To: oliver@neukum.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The firmware in the ZTE MF823/831/910 modems/mifis use OS fingerprinting to
determine which type of device to export. In addition, these devices export
a REST API which can also be used to control the type of device. So far, on
Linux, the devices have been seen as RNDIS or CDC Ether.

When CDC Ether is used, devices of the same type are, as with RNDIS,
exported with the same, bogus random MAC address. In addition, the devices
(at least on all firmware revisions I have found) use this MAC when sending
traffic routed from external networks. And as a final feature, the devices
sometimes export the link state incorrectly.

This patch tries to improve the handling of these devices by doing the
following:

* If a random MAC is read from device, then generate a new random MAC
address. This fix will apply to all devices using cdc_ether, but that
should be ok as we will also fix similar mistakes from other
manufacturers.

* The MF823/MF832/MF910 sometimes export cdc carrier on twice on connect
(the correct behavior is off then on). Work around this by manually setting
carrier to off if an on-notification is received and the NOCARRIER-bit is
not set.

This change will also affect all devices, but as with the MAC-fix it should
take care of similar mistakes. I tried to think of/look/test for
problems/regressions that could be introduced by this behavior, but could
not find any. However, my familiarity with this code path is not that
great, so there could be something I have overlooked.

* Add an rx_fixup-function (and a new driver info-struct) which is used by
these three devices (identified either as PID 0x1405 or 0x1408). The
rx_fixup-function replaces the destination MAC address in the skb with that
of the device. I have not seen a revision of these three device that
behaves correctly (i.e., sets the right destination MAC), so I chose not to
do any comparison with for example the known, bogus addresses.

I have tested this patch with multiple revisions of all three devices, and
they behave as expected. In other words, they all got a valid, random MAC,
the correct operational state and I can receive/sent traffic without
problems. I also tested with some other cdc_ether devices I have and did
not find any problems/regressions caused by the two general changes.

Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
---
 drivers/net/usb/cdc_ether.c | 53 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 7cba2c3..2325097 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -388,6 +388,12 @@ void usbnet_cdc_status(struct usbnet *dev, struct urb *urb)
 	case USB_CDC_NOTIFY_NETWORK_CONNECTION:
 		netif_dbg(dev, timer, dev->net, "CDC: carrier %s\n",
 			  event->wValue ? "on" : "off");
+
+		/* Work-around for devices with broken off-notifications */
+		if (event->wValue &&
+		    !test_bit(__LINK_STATE_NOCARRIER, &dev->net->state))
+			usbnet_link_change(dev, 0, 0);
+
 		usbnet_link_change(dev, !!event->wValue, 0);
 		break;
 	case USB_CDC_NOTIFY_SPEED_CHANGE:	/* tx/rx rates */
@@ -428,10 +434,34 @@ int usbnet_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 		return status;
 	}
 
+	if (dev->net->dev_addr[0] & 0x02)
+		eth_hw_addr_random(dev->net);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_cdc_bind);
 
+/* Make sure packets have correct destination MAC address
+ *
+ * A firmware bug observed on some devices (ZTE MF823/831/910) is that the
+ * device sends packets with a static, bogus, random MAC address (event if
+ * device MAC address has been updated). Always set MAC address to that of the
+ * device.
+ */
+static int usbnet_cdc_zte_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	u8 num_buggy_hwaddrs;
+	u8 buggy_hwaddrs_idx = 0;
+
+	if (skb->len < ETH_HLEN || !(skb->data[0] & 0x02))
+		return 1;
+
+	skb_reset_mac_header(skb);
+	ether_addr_copy(eth_hdr(skb)->h_dest, dev->net->dev_addr);
+
+	return 1;
+}
+
 static const struct driver_info	cdc_info = {
 	.description =	"CDC Ethernet Device",
 	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
@@ -442,6 +472,17 @@ static const struct driver_info	cdc_info = {
 	.manage_power =	usbnet_manage_power,
 };
 
+static const struct driver_info	zte_cdc_info = {
+	.description =	"ZTE MF823/831/910 CDC Ethernet Device",
+	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
+	.bind =		usbnet_cdc_bind,
+	.unbind =	usbnet_cdc_unbind,
+	.status =	usbnet_cdc_status,
+	.set_rx_mode =	usbnet_cdc_update_filter,
+	.manage_power =	usbnet_manage_power,
+	.rx_fixup = usbnet_cdc_zte_rx_fixup,
+};
+
 static const struct driver_info wwan_info = {
 	.description =	"Mobile Broadband Network Device",
 	.flags =	FLAG_WWAN,
@@ -697,6 +738,18 @@ static const struct usb_device_id	products[] = {
 				      USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long)&wwan_info,
 }, {
+	/* ZTE MF823/831/910 */
+	USB_DEVICE_AND_INTERFACE_INFO(ZTE_VENDOR_ID, 0x1405, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET,
+				      USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long)&zte_cdc_info,
+}, {
+	/* ZTE MF823/831/910 */
+	USB_DEVICE_AND_INTERFACE_INFO(ZTE_VENDOR_ID, 0x1408, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET,
+				      USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long)&zte_cdc_info,
+}, {
 	/* Telit modules */
 	USB_VENDOR_AND_INTERFACE_INFO(0x1bc7, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
-- 
2.5.0
