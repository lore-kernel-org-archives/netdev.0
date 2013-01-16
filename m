From: Lucas Stach <dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
Subject: [PATCH v3 1/2] net: asix: init ASIX AX88772B MAC from EEPROM
Date: Wed, 16 Jan 2013 15:24:06 +0100
Message-ID: <1358346247-10579-1-git-send-email-dev@lynxeye.de>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The device comes up with a MAC address of all zeros. We need to read the
initial device MAC from EEPROM so it can be set properly later.

Signed-off-by: Lucas Stach <dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
---
A similar fix was added into U-Boot:
http://patchwork.ozlabs.org/patch/179409/

v2: pass flag in the data field instead of clobbering the global flags
    space
v3: no change
---
 drivers/net/usb/asix.h         |  3 +++
 drivers/net/usb/asix_devices.c | 30 +++++++++++++++++++++++++++---
 2 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
index e889631..7afe8ac 100644
--- a/drivers/net/usb/asix.h
+++ b/drivers/net/usb/asix.h
@@ -167,6 +167,9 @@ struct asix_data {
 	u8 res;
 };
 
+/* ASIX specific flags */
+#define FLAG_EEPROM_MAC		(1UL << 0)  /* init device MAC from eeprom */
+
 int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 		  u16 size, void *data);
 
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 7a6e758..0ecc3bc 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -422,14 +422,25 @@ static const struct net_device_ops ax88772_netdev_ops = {
 
 static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 {
-	int ret, embd_phy;
+	int ret, embd_phy, i;
 	u8 buf[ETH_ALEN];
 	u32 phyid;
 
 	usbnet_get_endpoints(dev,intf);
 
 	/* Get the MAC address */
-	ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
+	if (dev->driver_info->data & FLAG_EEPROM_MAC) {
+		for (i = 0; i < (ETH_ALEN >> 1); i++) {
+			ret = asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x04 + i,
+					0, 2, buf + i * 2);
+			if (ret < 0)
+				break;
+		}
+	} else {
+		ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
+				0, 0, ETH_ALEN, buf);
+	}
+
 	if (ret < 0) {
 		netdev_dbg(dev->net, "Failed to read MAC address: %d\n", ret);
 		return ret;
@@ -872,6 +883,19 @@ static const struct driver_info ax88772_info = {
 	.tx_fixup = asix_tx_fixup,
 };
 
+static const struct driver_info ax88772b_info = {
+	.description = "ASIX AX88772B USB 2.0 Ethernet",
+	.bind = ax88772_bind,
+	.status = asix_status,
+	.link_reset = ax88772_link_reset,
+	.reset = ax88772_reset,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
+	         FLAG_MULTI_PACKET,
+	.rx_fixup = asix_rx_fixup,
+	.tx_fixup = asix_tx_fixup,
+	.data = FLAG_EEPROM_MAC,
+};
+
 static const struct driver_info ax88178_info = {
 	.description = "ASIX AX88178 USB 2.0 Ethernet",
 	.bind = ax88178_bind,
@@ -953,7 +977,7 @@ static const struct usb_device_id	products [] = {
 }, {
 	// ASIX AX88772B 10/100
 	USB_DEVICE (0x0b95, 0x772b),
-	.driver_info = (unsigned long) &ax88772_info,
+	.driver_info = (unsigned long) &ax88772b_info,
 }, {
 	// ASIX AX88772 10/100
 	USB_DEVICE (0x0b95, 0x7720),
-- 
1.8.0.2

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
