From: =?UTF-8?q?L=2E=20Alberto=20Gim=C3=A9nez?= <agimenez@sysvalve.es>
Subject: [PATCH Resubmission] drivers/net/usb: Add new driver ipheth
Date: Thu,  8 Apr 2010 00:11:20 +0200
Message-ID: <1270678281-20750-1-git-send-email-agimenez@sysvalve.es>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dgiagio@gmail.com, dborca@yahoo.com,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Jonas=20Sj=C3=B6quist?= <jonas.sjoquist@ericsson.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Torgny Johansson <torgny.johansson@gmail.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Omar Laazimani <omar.oberthur@gmail.com>,
	=?UTF-8?q?L=2E=20Alberto=20Gim=C3=A9nez?= <agimenez@sysvalve.es>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: dborca@yahoo.com

Add new driver to use tethering with an iPhone device. After initial su=
bmission,
apply fixes to fit the new driver into the kernel standards.

There are still a couple of minor (almost cosmetic-level) issues, but t=
he driver
is fully functional right now.

Signed-off-by: L. Alberto Gim=C3=A9nez <agimenez@sysvalve.es>
---
 drivers/net/usb/Kconfig  |   12 +
 drivers/net/usb/Makefile |    1 +
 drivers/net/usb/ipheth.c |  562 ++++++++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 575 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/ipheth.c

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index ba56ce4..63be4ca 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -385,4 +385,16 @@ config USB_CDC_PHONET
 	  cellular modem, as found on most Nokia handsets with the
 	  "PC suite" USB profile.
=20
+config USB_IPHETH
+	tristate "Apple iPhone USB Ethernet driver"
+	default n
+	---help---
+	  Module used to share Internet connection (tethering) from your
+	  iPhone (Original, 3G and 3GS) to your system.
+	  Note that you need userspace libraries and programs that are needed
+	  to pair your device with your system and that understand the iPhone
+	  protocol.
+
+	  For more information: http://giagio.com/wiki/moin.cgi/iPhoneEtherne=
tDriver
+
 endmenu
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 82ea629..edb09c0 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -23,4 +23,5 @@ obj-$(CONFIG_USB_NET_MCS7830)	+=3D mcs7830.o
 obj-$(CONFIG_USB_USBNET)	+=3D usbnet.o
 obj-$(CONFIG_USB_NET_INT51X1)	+=3D int51x1.o
 obj-$(CONFIG_USB_CDC_PHONET)	+=3D cdc-phonet.o
+obj-$(CONFIG_USB_IPHETH)	+=3D ipheth.o
=20
diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
new file mode 100644
index 0000000..677ae4a
--- /dev/null
+++ b/drivers/net/usb/ipheth.c
@@ -0,0 +1,562 @@
+/*
+ * ipheth.c - Apple iPhone USB Ethernet driver
+ *
+ * Copyright (c) 2009 Diego Giagio <diego@giagio.com>
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyrigh=
t
+ *    notice, this list of conditions and the following disclaimer in =
the
+ *    documentation and/or other materials provided with the distribut=
ion.
+ * 3. Neither the name of GIAGIO.COM nor the names of its contributors
+ *    may be used to endorse or promote products derived from this sof=
tware
+ *    without specific prior written permission.
+ *
+ * Alternatively, provided that this notice is retained in full, this
+ * software may be distributed under the terms of the GNU General
+ * Public License ("GPL") version 2, in which case the provisions of t=
he
+ * GPL apply INSTEAD OF those given above.
+ *
+ * The provided data structures and external interfaces from this code
+ * are not restricted to be used by modules with a GPL compatible lice=
nse.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS F=
OR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGH=
T
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTA=
L,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF US=
E,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON A=
NY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE U=
SE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
+ * DAMAGE.
+ *
+ *
+ * Attention: iPhone device must be paired, otherwise it won't respond=
 to our
+ * driver. For more info: http://giagio.com/wiki/moin.cgi/iPhoneEthern=
etDriver
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/usb.h>
+#include <linux/workqueue.h>
+
+#define USB_VENDOR_APPLE        0x05ac
+#define USB_PRODUCT_IPHONE      0x1290
+#define USB_PRODUCT_IPHONE_3G   0x1292
+#define USB_PRODUCT_IPHONE_3GS  0x1294
+
+#define IPHETH_USBINTF_CLASS    255
+#define IPHETH_USBINTF_SUBCLASS 253
+#define IPHETH_USBINTF_PROTO    1
+
+#define IPHETH_BUF_SIZE         1516
+#define IPHETH_TX_TIMEOUT       (5 * HZ)
+
+#define IPHETH_INTFNUM          2
+#define IPHETH_ALT_INTFNUM      1
+
+#define IPHETH_CTRL_ENDP        0x00
+#define IPHETH_CTRL_BUF_SIZE    0x40
+#define IPHETH_CTRL_TIMEOUT     (5 * HZ)
+
+#define IPHETH_CMD_GET_MACADDR   0x00
+#define IPHETH_CMD_CARRIER_CHECK 0x45
+
+#define IPHETH_CARRIER_CHECK_TIMEOUT (1 * HZ)
+#define IPHETH_CARRIER_ON       0x04
+
+static struct usb_device_id ipheth_table[] =3D {
+	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_3G,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_3GS,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
+	{ }
+};
+MODULE_DEVICE_TABLE(usb, ipheth_table);
+
+struct ipheth_device {
+	struct usb_device *udev;
+	struct usb_interface *intf;
+	struct net_device *net;
+	struct sk_buff *tx_skb;
+	struct urb *tx_urb;
+	struct urb *rx_urb;
+	unsigned char *tx_buf;
+	unsigned char *rx_buf;
+	unsigned char *ctrl_buf;
+	u8 bulk_in;
+	u8 bulk_out;
+	struct delayed_work carrier_work;
+};
+
+static int ipheth_rx_submit(struct ipheth_device *dev, gfp_t mem_flags=
);
+
+static int ipheth_alloc_urbs(struct ipheth_device *iphone)
+{
+	struct urb *tx_urb =3D NULL;
+	struct urb *rx_urb =3D NULL;
+	u8 *tx_buf =3D NULL;
+	u8 *rx_buf =3D NULL;
+
+	tx_urb =3D usb_alloc_urb(0, GFP_KERNEL);
+	if (tx_urb =3D=3D NULL)
+		goto error;
+
+	rx_urb =3D usb_alloc_urb(0, GFP_KERNEL);
+	if (rx_urb =3D=3D NULL)
+		goto error;
+
+	tx_buf =3D usb_buffer_alloc(iphone->udev,
+				  IPHETH_BUF_SIZE,
+				  GFP_KERNEL,
+				  &tx_urb->transfer_dma);
+	if (tx_buf =3D=3D NULL)
+		goto error;
+
+	rx_buf =3D usb_buffer_alloc(iphone->udev,
+				  IPHETH_BUF_SIZE,
+				  GFP_KERNEL,
+				  &rx_urb->transfer_dma);
+	if (rx_buf =3D=3D NULL)
+		goto error;
+
+
+	iphone->tx_urb =3D tx_urb;
+	iphone->rx_urb =3D rx_urb;
+	iphone->tx_buf =3D tx_buf;
+	iphone->rx_buf =3D rx_buf;
+	return 0;
+
+error:
+	usb_buffer_free(iphone->udev, IPHETH_BUF_SIZE, rx_buf,
+			rx_urb->transfer_dma);
+	usb_buffer_free(iphone->udev, IPHETH_BUF_SIZE, tx_buf,
+			tx_urb->transfer_dma);
+	usb_free_urb(rx_urb);
+	usb_free_urb(tx_urb);
+	return -ENOMEM;
+}
+
+static void ipheth_free_urbs(struct ipheth_device *iphone)
+{
+	usb_buffer_free(iphone->udev, IPHETH_BUF_SIZE, iphone->rx_buf,
+			iphone->rx_urb->transfer_dma);
+	usb_buffer_free(iphone->udev, IPHETH_BUF_SIZE, iphone->tx_buf,
+			iphone->tx_urb->transfer_dma);
+	usb_free_urb(iphone->rx_urb);
+	usb_free_urb(iphone->tx_urb);
+}
+
+static void ipheth_kill_urbs(struct ipheth_device *dev)
+{
+	usb_kill_urb(dev->tx_urb);
+	usb_kill_urb(dev->rx_urb);
+}
+
+static void ipheth_rcvbulk_callback(struct urb *urb)
+{
+	struct ipheth_device *dev;
+	struct sk_buff *skb;
+	int status;
+	char *buf;
+	int len;
+
+	dev =3D urb->context;
+	if (dev =3D=3D NULL)
+		return;
+
+	status =3D urb->status;
+	switch (status) {
+	case -ENOENT:
+	case -ECONNRESET:
+	case -ESHUTDOWN:
+		return;
+	case 0:
+		break;
+	default:
+		err("%s: urb status: %d", __func__, urb->status);
+		return;
+	}
+
+	len =3D urb->actual_length;
+	buf =3D urb->transfer_buffer;
+
+	skb =3D dev_alloc_skb(NET_IP_ALIGN + len);
+	if (!skb) {
+		err("%s: dev_alloc_skb: -ENOMEM", __func__);
+		dev->net->stats.rx_dropped++;
+		return;
+	}
+
+	skb_reserve(skb, NET_IP_ALIGN);
+	memcpy(skb_put(skb, len), buf + NET_IP_ALIGN, len - NET_IP_ALIGN);
+	skb->dev =3D dev->net;
+	skb->protocol =3D eth_type_trans(skb, dev->net);
+
+	dev->net->stats.rx_packets++;
+	dev->net->stats.rx_bytes +=3D len;
+
+	netif_rx(skb);
+	ipheth_rx_submit(dev, GFP_ATOMIC);
+}
+
+static void ipheth_sndbulk_callback(struct urb *urb)
+{
+	struct ipheth_device *dev;
+
+	dev =3D urb->context;
+	if (dev =3D=3D NULL)
+		return;
+
+	if (urb->status !=3D 0 &&
+	    urb->status !=3D -ENOENT &&
+	    urb->status !=3D -ECONNRESET &&
+	    urb->status !=3D -ESHUTDOWN)
+		err("%s: urb status: %d", __func__, urb->status);
+
+	dev_kfree_skb_irq(dev->tx_skb);
+	netif_wake_queue(dev->net);
+}
+
+static int ipheth_carrier_set(struct ipheth_device *dev)
+{
+	struct usb_device *udev =3D dev->udev;
+	int retval;
+
+	retval =3D usb_control_msg(udev,
+			usb_rcvctrlpipe(udev, IPHETH_CTRL_ENDP),
+			IPHETH_CMD_CARRIER_CHECK, /* request */
+			0xc0, /* request type */
+			0x00, /* value */
+			0x02, /* index */
+			dev->ctrl_buf, IPHETH_CTRL_BUF_SIZE,
+			IPHETH_CTRL_TIMEOUT);
+	if (retval < 0) {
+		err("%s: usb_control_msg: %d", __func__, retval);
+		return retval;
+	}
+
+	if (dev->ctrl_buf[0] =3D=3D IPHETH_CARRIER_ON)
+		netif_carrier_on(dev->net);
+	else
+		netif_carrier_off(dev->net);
+
+	return 0;
+}
+
+static void ipheth_carrier_check_work(struct work_struct *work)
+{
+	struct ipheth_device *dev =3D container_of(work, struct ipheth_device=
,
+						 carrier_work.work);
+
+	ipheth_carrier_set(dev);
+	schedule_delayed_work(&dev->carrier_work, IPHETH_CARRIER_CHECK_TIMEOU=
T);
+}
+
+static int ipheth_get_macaddr(struct ipheth_device *dev)
+{
+	struct usb_device *udev =3D dev->udev;
+	struct net_device *net =3D dev->net;
+	int retval;
+
+	retval =3D usb_control_msg(udev,
+				 usb_rcvctrlpipe(udev, IPHETH_CTRL_ENDP),
+				 IPHETH_CMD_GET_MACADDR, /* request */
+				 0xc0, /* request type */
+				 0x00, /* value */
+				 0x02, /* index */
+				 dev->ctrl_buf,
+				 IPHETH_CTRL_BUF_SIZE,
+				 IPHETH_CTRL_TIMEOUT);
+	if (retval < 0) {
+		err("%s: usb_control_msg: %d", __func__, retval);
+	} else if (retval < ETH_ALEN) {
+		err("%s: usb_control_msg: short packet: %d bytes",
+			__func__, retval);
+		retval =3D -EINVAL;
+	} else {
+		memcpy(net->dev_addr, dev->ctrl_buf, ETH_ALEN);
+		retval =3D 0;
+	}
+
+	return retval;
+}
+
+static int ipheth_rx_submit(struct ipheth_device *dev, gfp_t mem_flags=
)
+{
+	struct usb_device *udev =3D dev->udev;
+	int retval;
+
+	usb_fill_bulk_urb(dev->rx_urb, udev,
+			  usb_rcvbulkpipe(udev, dev->bulk_in),
+			  dev->rx_buf, IPHETH_BUF_SIZE,
+			  ipheth_rcvbulk_callback,
+			  dev);
+	dev->rx_urb->transfer_flags |=3D URB_NO_TRANSFER_DMA_MAP;
+
+	retval =3D usb_submit_urb(dev->rx_urb, mem_flags);
+	if (retval)
+		err("%s: usb_submit_urb: %d", __func__, retval);
+	return retval;
+}
+
+static int ipheth_open(struct net_device *net)
+{
+	struct ipheth_device *dev =3D netdev_priv(net);
+	struct usb_device *udev =3D dev->udev;
+	int retval =3D 0;
+
+	usb_set_interface(udev, IPHETH_INTFNUM, IPHETH_ALT_INTFNUM);
+
+	retval =3D ipheth_carrier_set(dev);
+	if (retval)
+		return retval;
+
+	retval =3D ipheth_rx_submit(dev, GFP_KERNEL);
+	if (retval)
+		return retval;
+
+	schedule_delayed_work(&dev->carrier_work, IPHETH_CARRIER_CHECK_TIMEOU=
T);
+	netif_start_queue(net);
+	return retval;
+}
+
+static int ipheth_close(struct net_device *net)
+{
+	struct ipheth_device *dev =3D netdev_priv(net);
+
+	cancel_delayed_work_sync(&dev->carrier_work);
+	netif_stop_queue(net);
+	return 0;
+}
+
+static int ipheth_tx(struct sk_buff *skb, struct net_device *net)
+{
+	struct ipheth_device *dev =3D netdev_priv(net);
+	struct usb_device *udev =3D dev->udev;
+	int retval;
+
+	/* Paranoid */
+	if (skb->len > IPHETH_BUF_SIZE) {
+		WARN(1, "%s: skb too large: %d bytes", __func__, skb->len);
+		dev->net->stats.tx_dropped++;
+		dev_kfree_skb_irq(skb);
+		return NETDEV_TX_OK;
+	}
+
+	memcpy(dev->tx_buf, skb->data, skb->len);
+	if (skb->len < IPHETH_BUF_SIZE)
+		memset(dev->tx_buf + skb->len, 0, IPHETH_BUF_SIZE - skb->len);
+
+	usb_fill_bulk_urb(dev->tx_urb, udev,
+			  usb_sndbulkpipe(udev, dev->bulk_out),
+			  dev->tx_buf, IPHETH_BUF_SIZE,
+			  ipheth_sndbulk_callback,
+			  dev);
+	dev->tx_urb->transfer_flags |=3D URB_NO_TRANSFER_DMA_MAP;
+
+	retval =3D usb_submit_urb(dev->tx_urb, GFP_ATOMIC);
+	if (retval) {
+		err("%s: usb_submit_urb: %d", __func__, retval);
+		dev->net->stats.tx_errors++;
+		dev_kfree_skb_irq(skb);
+	} else {
+		dev->tx_skb =3D skb;
+
+		dev->net->stats.tx_packets++;
+		dev->net->stats.tx_bytes +=3D skb->len;
+		netif_stop_queue(net);
+	}
+
+	return NETDEV_TX_OK;
+}
+
+static void ipheth_tx_timeout(struct net_device *net)
+{
+	struct ipheth_device *dev =3D netdev_priv(net);
+
+	err("%s: TX timeout", __func__);
+	dev->net->stats.tx_errors++;
+	usb_unlink_urb(dev->tx_urb);
+}
+
+static struct net_device_stats *ipheth_stats(struct net_device *net)
+{
+	struct ipheth_device *dev =3D netdev_priv(net);
+	return &dev->net->stats;
+}
+
+static u32 ipheth_ethtool_op_get_link(struct net_device *net)
+{
+	struct ipheth_device *dev =3D netdev_priv(net);
+	return netif_carrier_ok(dev->net);
+}
+
+static struct ethtool_ops ops =3D {
+	.get_link =3D ipheth_ethtool_op_get_link
+};
+
+static const struct net_device_ops ipheth_netdev_ops =3D {
+	.ndo_open =3D &ipheth_open,
+	.ndo_stop =3D &ipheth_close,
+	.ndo_start_xmit =3D &ipheth_tx,
+	.ndo_tx_timeout =3D &ipheth_tx_timeout,
+	.ndo_get_stats =3D &ipheth_stats,
+};
+
+static int ipheth_probe(struct usb_interface *intf,
+			const struct usb_device_id *id)
+{
+	struct usb_device *udev =3D interface_to_usbdev(intf);
+	struct usb_host_interface *hintf;
+	struct usb_endpoint_descriptor *endp;
+	struct ipheth_device *dev;
+	struct net_device *netdev;
+	int i;
+	int retval;
+
+	netdev =3D alloc_etherdev(sizeof(struct ipheth_device));
+	if (!netdev)
+		return -ENOMEM;
+
+	netdev->netdev_ops =3D &ipheth_netdev_ops;
+	netdev->watchdog_timeo =3D IPHETH_TX_TIMEOUT;
+
+	dev =3D netdev_priv(netdev);
+	dev->udev =3D udev;
+	dev->net =3D netdev;
+	dev->intf =3D intf;
+
+	/* Set up endpoints */
+	hintf =3D usb_altnum_to_altsetting(intf, IPHETH_ALT_INTFNUM);
+	if (hintf =3D=3D NULL) {
+		retval =3D -ENODEV;
+		err("Unable to find alternate settings interface");
+		goto err_endpoints;
+	}
+
+	for (i =3D 0; i < hintf->desc.bNumEndpoints; i++) {
+		endp =3D &hintf->endpoint[i].desc;
+		if (usb_endpoint_is_bulk_in(endp))
+			dev->bulk_in =3D endp->bEndpointAddress;
+		else if (usb_endpoint_is_bulk_out(endp))
+			dev->bulk_out =3D endp->bEndpointAddress;
+	}
+	if (!(dev->bulk_in && dev->bulk_out)) {
+		retval =3D -ENODEV;
+		err("Unable to find endpoints");
+		goto err_endpoints;
+	}
+
+	dev->ctrl_buf =3D kmalloc(IPHETH_CTRL_BUF_SIZE, GFP_KERNEL);
+	if (dev->ctrl_buf =3D=3D NULL) {
+		retval =3D -ENOMEM;
+		goto err_alloc_ctrl_buf;
+	}
+
+	retval =3D ipheth_get_macaddr(dev);
+	if (retval)
+		goto err_get_macaddr;
+
+	INIT_DELAYED_WORK(&dev->carrier_work, ipheth_carrier_check_work);
+
+	retval =3D ipheth_alloc_urbs(dev);
+	if (retval) {
+		err("error allocating urbs: %d", retval);
+		goto err_alloc_urbs;
+	}
+
+	usb_set_intfdata(intf, dev);
+
+	SET_NETDEV_DEV(netdev, &intf->dev);
+	SET_ETHTOOL_OPS(netdev, &ops);
+
+	retval =3D register_netdev(netdev);
+	if (retval) {
+		err("error registering netdev: %d", retval);
+		retval =3D -EIO;
+		goto err_register_netdev;
+	}
+
+	dev_info(&intf->dev, "Apple iPhone USB Ethernet device attached\n");
+	return 0;
+
+err_register_netdev:
+	ipheth_free_urbs(dev);
+err_alloc_urbs:
+err_get_macaddr:
+err_alloc_ctrl_buf:
+	kfree(dev->ctrl_buf);
+err_endpoints:
+	free_netdev(netdev);
+	return retval;
+}
+
+static void ipheth_disconnect(struct usb_interface *intf)
+{
+	struct ipheth_device *dev;
+
+	dev =3D usb_get_intfdata(intf);
+	if (dev !=3D NULL) {
+		unregister_netdev(dev->net);
+		ipheth_kill_urbs(dev);
+		ipheth_free_urbs(dev);
+		kfree(dev->ctrl_buf);
+		free_netdev(dev->net);
+	}
+	usb_set_intfdata(intf, NULL);
+	dev_info(&intf->dev, "Apple iPhone USB Ethernet now disconnected\n");
+}
+
+static struct usb_driver ipheth_driver =3D {
+	.name =3D		"ipheth",
+	.probe =3D	ipheth_probe,
+	.disconnect =3D	ipheth_disconnect,
+	.id_table =3D	ipheth_table,
+};
+
+static int __init ipheth_init(void)
+{
+	int retval;
+
+	retval =3D usb_register(&ipheth_driver);
+	if (retval) {
+		err("usb_register failed: %d", retval);
+		return retval;
+	}
+	return 0;
+}
+
+static void __exit ipheth_exit(void)
+{
+	usb_deregister(&ipheth_driver);
+}
+
+module_init(ipheth_init);
+module_exit(ipheth_exit);
+
+MODULE_AUTHOR("Diego Giagio <diego@giagio.com>");
+MODULE_DESCRIPTION("Apple iPhone USB Ethernet driver");
+MODULE_LICENSE("Dual BSD/GPL");
--=20
1.7.0
