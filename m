From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: [PATCH net-next v3] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Tue, 19 Jul 2016 16:54:11 +0200
Message-ID: <1468940051-24407-1-git-send-email-kristian.evensen@gmail.com>
Cc: Kristian Evensen <kristian.evensen@gmail.com>
To: oliver@neukum.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The firmware in several ZTE devices (at least the MF823/831/910
modems/mifis) use OS fingerprinting to determine which type of device to
export. In addition, these devices export a REST API which can be used to
control the type of device. So far, on Linux, the devices have been seen as
RNDIS or CDC Ether.

When CDC Ether is used, devices of the same type are, as with RNDIS,
exported with the same, bogus random MAC address. In addition, the devices
(at least on all firmware revisions I have found) use the bogus MAC when
sending traffic routed from external networks. And as a final feature, the
devices sometimes export the link state incorrectly. There are also
references online to several other ZTE devices displaying this behavior,
with several different PIDs and MAC addresses.

This patch tries to improve the handling of ZTE devices by doing the
following:

* Create a new driver_info-struct that is used by ZTE devices that do not
have an explicit entry in the product table. This struct is the same as the
default cdc_ether driver info, but a new bind- and an rx_fixup-function
have been added.

* In the new bind function, we check if we have read a random MAC from the
device. If we have, then we generate a new random MAC address. This will
ensure that all devices get a unique MAC.

* The rx_fixup-function replaces the destination MAC address in the skb
with that of the device. I have not seen a revision of these devices that
behaves correctly (i.e., sets the right destination MAC), so I chose not to
do any comparison with for example the known, bogus addresses.

* The MF823/MF832/MF910 sometimes export cdc carrier on twice on connect
(the correct behavior is off then on). Work around this by manually setting
carrier to off if an on-notification is received and the NOCARRIER-bit is
not set.

This change will affect all devices, but it should take care of similar
mistakes made by other manufacturers. I tried to think of/look/test for
problems/regressions that could be introduced by this behavior, but could
not find any. However, my familiarity with this code path is not that
great, so there could be something I have overlooked.

I have tested this patch with multiple revisions of all three devices, and
they behave as expected. In other words, they all got a valid, random MAC,
the correct operational state and I can receive/sent traffic without
problems. I also tested with some other cdc_ether devices I have and did
not find any problems/regressions caused by the two general changes.

v2->v3:
* I had forgot to remove the random MAC generation from usbnet_cdc_bind()
(thanks Olive).
* Rework logic in the ZTE bind-function a bit.

v1->v2:
* Only generate random MAC for ZTE devices (thanks Oliver Neukum).
* Set random MAC and do RX fixup for all ZTE devices that do not have a
product-entry, as the bogus MAC have been seen on devices with several
different PIDs/MAC addresses. In other words, it seems to be the default
behavior of ZTE CDC Ether devices (thanks Lars Melin).

Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
---
 drivers/net/usb/cdc_ether.c | 54 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 7cba2c3..874caad 100644
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
@@ -432,6 +438,37 @@ int usbnet_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 }
 EXPORT_SYMBOL_GPL(usbnet_cdc_bind);
 
+static int usbnet_cdc_zte_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int status = usbnet_cdc_bind(dev, intf);
+
+	if (!status && (dev->net->dev_addr[0] & 0x02))
+		eth_hw_addr_random(dev->net);
+
+	return status;
+}
+
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
@@ -442,6 +479,17 @@ static const struct driver_info	cdc_info = {
 	.manage_power =	usbnet_manage_power,
 };
 
+static const struct driver_info	zte_cdc_info = {
+	.description =	"ZTE CDC Ethernet Device",
+	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
+	.bind =		usbnet_cdc_zte_bind,
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
@@ -707,6 +755,12 @@ static const struct usb_device_id	products[] = {
 			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
 	.driver_info = (kernel_ulong_t)&wwan_info,
 }, {
+	/* ZTE modules */
+	USB_VENDOR_AND_INTERFACE_INFO(ZTE_VENDOR_ID, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET,
+				      USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long)&zte_cdc_info,
+}, {
 	USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_ETHERNET,
 			USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long) &cdc_info,
-- 
2.5.0
