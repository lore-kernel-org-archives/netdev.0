From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] [RFC] introduce cx82310_eth: Conexant CX82310-based ADSL router USB ethernet driver
Date: Fri, 3 Sep 2010 23:17:12 +0200
Message-ID: <201009032317.14954.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Brownell <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: cxacru@fire.lp0.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-out1.atlantis.sk ([80.94.52.55]:41280 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753595Ab0ICVRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 17:17:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
this patch introduces cx82310_eth driver - driver for USB ethernet port of 
ADSL routers based on Conexant CX82310 chips. Such routers usually have 
ethernet port(s) too which are bridged together with the USB ethernet port, 
allowing the USB-connected machine to communicate to the network (and also 
internet through the ADSL, of course).

This is my first driver, so please check thoroughly. As there's no protocol 
documentation, it was done with usbsnoop dumps from Windows driver, some 
parts (the commands) inspired by cxacru driver and also other usbnet drivers. 
The driver passed my testing - some real work and also pings sized from 0 to 
65507 B.

The only problem I found is the ifconfig error counter. When I return 0 (or 1 
but empty skb) from rx_fixup(), usbnet increases the error counter although 
it's not an error condition (because packets can cross URB boundaries). Maybe 
the usbnet should be fixed to allow rx_fixup() to return empty skbs (or some 
other value, e.g. 2)?

The USB ID of my device is 0x0572:0xcb01 which conflicts with some ADSL modems 
using cxacru driver (they probably use the same chipset but simpler 
firmware). The modems seem to use bDeviceClass 0 and iProduct "ADSL USB 
MODEM", my router uses bDeviceClass 255 and iProduct "USB NET CARD". The 
driver matches only devices with class 255 and checks for the iProduct string 
during init. The cxacru driver should be modified to ignore these devices.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

--- /dev/null	2010-09-03 21:17:56.916000000 +0200
+++ linux-2.6.35-rc3/drivers/net/usb/cx82310_eth.c	2010-09-03 23:09:16.000000000 +0200
@@ -0,0 +1,350 @@
+/*
+ * Driver for USB ethernet port of Conexant CX82310-based ADSL routers
+ * Copyright (C) 2010 by Ondrej Zary
+ * some parts inspired by the cxacru driver
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/workqueue.h>
+#include <linux/mii.h>
+#include <linux/usb.h>
+#include <linux/usb/usbnet.h>
+
+enum cx82310_cmd {
+	CMD_START		= 0x84,	/* no effect? */
+	CMD_STOP		= 0x85,	/* no effect? */
+	CMD_GET_STATUS		= 0x90,	/* returns nothing? */
+	CMD_GET_MAC_ADDR	= 0x91,	/* read MAC address */
+	CMD_GET_LINK_STATUS	= 0x92,	/* not useful, link is always up */
+	CMD_ETHERNET_MODE	= 0x99,	/* unknown, needed during init */
+};
+
+enum cx82310_status {
+	STATUS_UNDEFINED,
+	STATUS_SUCCESS,
+	STATUS_ERROR,
+	STATUS_UNSUPPORTED,
+	STATUS_UNIMPLEMENTED,
+	STATUS_PARAMETER_ERROR,
+	STATUS_DBG_LOOPBACK,
+};
+
+#define CMD_PACKET_SIZE	64
+/* first command after power on can take around 8 seconds */
+#define CMD_TIMEOUT	15000
+#define CMD_REPLY_RETRY 5
+
+#define CX82310_MTU	1514
+#define CMD_EP		0x01
+
+/*
+ * execute control command
+ *  - optionally send some data (command parameters)
+ *  - optionally wait for the reply
+ *  - optionally read some data from the reply
+ */
+static int cx82310_cmd(struct usbnet *dev, enum cx82310_cmd cmd, bool reply,
+		       u8 *wdata, int wlen, u8 *rdata, int rlen)
+{
+	int actual_len, retries, ret;
+	struct usb_device *udev = dev->udev;
+	u8 *buf = kzalloc(CMD_PACKET_SIZE, GFP_KERNEL);
+
+	if (!buf)
+		return -ENOMEM;
+
+	/* create command packet */
+	buf[0] = cmd;
+	if (wdata)
+		memcpy(buf + 4, wdata, min_t(int, wlen, CMD_PACKET_SIZE - 4));
+
+	/* send command packet */
+	ret = usb_bulk_msg(udev, usb_sndbulkpipe(udev, CMD_EP), buf,
+			   CMD_PACKET_SIZE, &actual_len, CMD_TIMEOUT);
+	if (ret < 0) {
+		dev_err(&dev->udev->dev, "send command %#x: error %d\n",
+			cmd, ret);
+		goto end;
+	}
+
+	if (reply) {
+		/* wait for reply, retry if it's empty */
+		for (retries = 0; retries < CMD_REPLY_RETRY; retries++) {
+			ret = usb_bulk_msg(udev, usb_rcvbulkpipe(udev, CMD_EP),
+					   buf, CMD_PACKET_SIZE, &actual_len,
+					   CMD_TIMEOUT);
+			if (ret < 0) {
+				dev_err(&dev->udev->dev,
+					"reply receive error %d\n", ret);
+				goto end;
+			}
+			if (actual_len > 0)
+				break;
+		}
+		if (actual_len == 0) {
+			dev_err(&dev->udev->dev, "no reply to command %#x\n",
+				cmd);
+			ret = -EIO;
+			goto end;
+		}
+		if (buf[0] != cmd) {
+			dev_err(&dev->udev->dev,
+				"got reply to command %#x, expected: %#x\n",
+				buf[0], cmd);
+			ret = -EIO;
+			goto end;
+		}
+		if (buf[1] != STATUS_SUCCESS) {
+			dev_err(&dev->udev->dev, "command %#x failed: %#x\n",
+				cmd, buf[1]);
+			ret = -EIO;
+			goto end;
+		}
+		if (rdata)
+			memcpy(rdata, buf + 4,
+			       min_t(int, rlen, CMD_PACKET_SIZE - 4));
+	}
+end:
+	kfree(buf);
+	return ret;
+}
+
+#define rx_incomplete	(dev->data[0])
+#define rx_remainder	(dev->data[1])
+#define incomplete_data	(dev->data[2])
+
+static int cx82310_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int ret;
+	char buf[15];
+	struct usb_device *udev = dev->udev;
+
+	/* avoid ADSL modems - continue only if iProduct is "USB NET CARD" */
+	if (udev->descriptor.iProduct &&
+	    usb_string(udev, udev->descriptor.iProduct, buf, sizeof(buf)) &&
+	    strcmp(buf, "USB NET CARD")) {
+		dev_err(&udev->dev,
+			"probably an ADSL modem, use cxacru driver instead\n");
+		return -ENODEV;
+	}
+
+	ret = usbnet_get_endpoints(dev, intf);
+	if (ret)
+		return ret;
+
+	/*
+	 * this must not include ethernet header as the device can send partial
+	 * packets with no header (URB is at least 2 bytes long, so 2 is OK)
+	 */
+	dev->net->hard_header_len = 2;
+	/* we can send at most 1514 bytes of data (+ 2-byte header) per URB */
+	dev->hard_mtu = CX82310_MTU + dev->net->hard_header_len;
+	/* we can receive URBs up to 4KB from the device */
+	dev->rx_urb_size = 4096;
+
+	incomplete_data = (unsigned long) kmalloc(dev->hard_mtu, GFP_KERNEL);
+	if (!incomplete_data)
+		return -ENOMEM;
+
+	/* enable ethernet mode (?) */
+	ret = cx82310_cmd(dev, CMD_ETHERNET_MODE, true, "\x01", 1, NULL, 0);
+	if (ret) {
+		dev_err(&udev->dev, "unable to enable ethernet mode\n");
+		goto err;
+	}
+
+	/* get the MAC address */
+	ret = cx82310_cmd(dev, CMD_GET_MAC_ADDR, true, NULL, 0,
+			  dev->net->dev_addr, ETH_ALEN);
+	if (ret) {
+		dev_err(&udev->dev, "unable to read MAC address\n");
+		goto err;
+	}
+
+	/* start (does not seem to have any effect?) */
+	ret = cx82310_cmd(dev, CMD_START, false, NULL, 0, NULL, 0);
+	if (ret)
+		goto err;
+
+	return 0;
+err:
+	kfree((void *)incomplete_data);
+	return ret;
+}
+
+static void cx82310_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	kfree((void *)incomplete_data);
+}
+
+/*
+ * RX is NOT easy - we can receive multiple packets per skb, each having 2-byte
+ * packet length at the beginning.
+ * The last packet might be incomplete (when it crosses the 4KB URB size),
+ * continuing in the next skb (without any headers).
+ * If a packet has odd length, there is one extra byte at the end (before next
+ * packet or at the end of the URB).
+ */
+static int cx82310_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	int len;
+	struct sk_buff *skb2;
+
+	/*
+	 * If the last skb ended with an incomplete packet, this skb contains
+	 * end of that packet at the beginning.
+	 */
+	if (rx_remainder) {
+		skb2 = alloc_skb(rx_incomplete + rx_remainder, GFP_ATOMIC);
+		if (!skb2)
+			return 0;
+		skb_put(skb2, rx_incomplete + rx_remainder);
+		memcpy(skb2->data, (void *)incomplete_data, rx_incomplete);
+		memcpy(skb2->data + rx_incomplete, skb->data, rx_remainder);
+		usbnet_skb_return(dev, skb2);
+		skb_pull(skb, (rx_remainder + 1) & ~1);
+		rx_remainder = 0;
+		if (skb->len < 2)
+			return 1;
+	}
+
+	if (skb->len < 2) {
+		dev_err(&dev->udev->dev, "RX frame too short: %d B\n",
+			skb->len);
+		return 0;
+	}
+
+	/* a skb can contain multiple packets */
+	while (skb->len > 1) {
+		/* first two bytes are packet length */
+		len = skb->data[0] | (skb->data[1] << 8);
+		skb_pull(skb, 2);
+
+		/* if last packet in the skb, let usbnet to process it */
+		if (len == skb->len || len + 1 == skb->len) {
+			skb_trim(skb, len);
+			break;
+		}
+
+		if (len > CX82310_MTU) {
+			dev_err(&dev->udev->dev, "RX packet too long: %d B\n",
+				len);
+			return 0;
+		}
+
+		/* incomplete packet, save it for the next skb */
+		if (len > skb->len) {
+			rx_incomplete = skb->len;
+			rx_remainder = len - skb->len;
+			memcpy((void *)incomplete_data, skb->data,
+			       rx_incomplete);
+			skb_pull(skb, skb->len);
+			break;
+		}
+
+		skb2 = alloc_skb(len, GFP_ATOMIC);
+		if (!skb2)
+			return 0;
+		skb_put(skb2, len);
+		memcpy(skb2->data, skb->data, len);
+		/* process the packet */
+		usbnet_skb_return(dev, skb2);
+
+		skb_pull(skb, (len + 1) & ~1);
+	}
+
+	/* let usbnet process the last packet */
+	return 1;
+}
+
+/* TX is easy, just add 2 bytes of length at the beginning */
+static struct sk_buff *cx82310_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
+				       gfp_t flags)
+{
+	int len = skb->len;
+
+	if (skb_headroom(skb) < 2) {
+		struct sk_buff *skb2 = skb_copy_expand(skb, 2, 0, flags);
+		dev_kfree_skb_any(skb);
+		skb = skb2;
+		if (!skb)
+			return NULL;
+	}
+	skb_push(skb, 2);
+
+	skb->data[0] = len;
+	skb->data[1] = len >> 8;
+
+	return skb;
+}
+
+
+static const struct driver_info	cx82310_info = {
+	.description	= "Conexant CX82310 USB ethernet",
+	.flags		= FLAG_ETHER,
+	.bind		= cx82310_bind,
+	.unbind		= cx82310_unbind,
+	.rx_fixup	= cx82310_rx_fixup,
+	.tx_fixup	= cx82310_tx_fixup,
+};
+
+#define USB_DEVICE_CLASS(vend, prod, cl, sc, pr) \
+	.match_flags = USB_DEVICE_ID_MATCH_DEVICE | \
+		       USB_DEVICE_ID_MATCH_DEV_INFO, \
+	.idVendor = (vend), \
+	.idProduct = (prod), \
+	.bDeviceClass = (cl), \
+	.bDeviceSubClass = (sc), \
+	.bDeviceProtocol = (pr)
+
+static const struct usb_device_id products[] = {
+	{
+		USB_DEVICE_CLASS(0x0572, 0xcb01, 0xff, 0, 0),
+		.driver_info = (unsigned long) &cx82310_info
+	},
+	{ },
+};
+MODULE_DEVICE_TABLE(usb, products);
+
+static struct usb_driver cx82310_driver = {
+	.name		= "cx82310_eth",
+	.id_table	= products,
+	.probe		= usbnet_probe,
+	.disconnect	= usbnet_disconnect,
+	.suspend	= usbnet_suspend,
+	.resume		= usbnet_resume,
+};
+
+static int __init cx82310_init(void)
+{
+	return usb_register(&cx82310_driver);
+}
+module_init(cx82310_init);
+
+static void __exit cx82310_exit(void)
+{
+	usb_deregister(&cx82310_driver);
+}
+module_exit(cx82310_exit);
+
+MODULE_AUTHOR("Ondrej Zary");
+MODULE_DESCRIPTION("Conexant CX82310-based ADSL router USB ethernet driver");
+MODULE_LICENSE("GPL");
--- linux-2.6.35-rc2/drivers/net/usb/Kconfig	2010-06-06 05:43:24.000000000 +0200
+++ linux-2.6.35-rc3/drivers/net/usb/Kconfig	2010-09-01 19:20:36.000000000 +0200
@@ -358,6 +358,14 @@ config USB_NET_ZAURUS
 	  really need this non-conformant variant of CDC Ethernet (or in
 	  some cases CDC MDLM) protocol, not "g_ether".
 
+config USB_NET_CX82310_ETH
+	tristate "Conexant CX82310 USB ethernet port"
+	depends on USB_USBNET
+	help
+	  Choose this option if you're using a Conexant CX82310-based ADSL
+	  router with USB ethernet port. This driver is for routers only,
+	  it will not work with ADSL modems (use cxacru driver instead).
+
 config USB_HSO
 	tristate "Option USB High Speed Mobile Devices"
 	depends on USB && RFKILL
--- linux-2.6.35-rc2/drivers/net/usb/Makefile	2010-06-06 05:43:24.000000000 +0200
+++ linux-2.6.35-rc3/drivers/net/usb/Makefile	2010-09-03 23:14:46.000000000 +0200
@@ -25,4 +25,5 @@ obj-$(CONFIG_USB_NET_INT51X1)	+= int51x1
 obj-$(CONFIG_USB_CDC_PHONET)	+= cdc-phonet.o
 obj-$(CONFIG_USB_IPHETH)	+= ipheth.o
 obj-$(CONFIG_USB_SIERRA_NET)	+= sierra_net.o
+obj-$(CONFIG_USB_NET_CX82310_ETH)	+= cx82310_eth.o
 


-- 
Ondrej Zary
