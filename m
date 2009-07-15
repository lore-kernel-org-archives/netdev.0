From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] USB host CDC Phonet network interface driver
Date: Wed, 15 Jul 2009 16:59:01 +0300
Message-ID: <1247666341-7121-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:55051 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754784AbZGON4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 09:56:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Many Nokia handsets support a Phonet interface to the cellular modem
via a vendor-specific USB interface. CDC Phonet follows the
Communications Device Class model, with one control interface, and
and a pair of inactive and active data alternative interface. The later
has two bulk endpoint, one per direction.

This was tested against Nokia E61, Nokia N95, and the existing Phonet
gadget function for the Linux composite USB gadget framework.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/net/usb/Kconfig      |    8 +
 drivers/net/usb/Makefile     |    1 +
 drivers/net/usb/cdc-phonet.c |  451 ++++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 460 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/cdc-phonet.c

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index a906d39..c47237c 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -369,4 +369,12 @@ config USB_NET_INT51X1
 	  (Powerline Communications) solution with an Intellon
 	  INT51x1/INT5200 chip, like the "devolo dLan duo".
=20
+config USB_CDC_PHONET
+	tristate "CDC Phonet support"
+	depends on PHONET
+	help
+	  Choose this option to support the Phonet interface to a Nokia
+	  cellular modem, as found on most Nokia handsets with the
+	  "PC suite" USB profile.
+
 endmenu
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index b870b0b..e17afb7 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -21,4 +21,5 @@ obj-$(CONFIG_USB_NET_ZAURUS)	+=3D zaurus.o
 obj-$(CONFIG_USB_NET_MCS7830)	+=3D mcs7830.o
 obj-$(CONFIG_USB_USBNET)	+=3D usbnet.o
 obj-$(CONFIG_USB_NET_INT51X1)	+=3D int51x1.o
+obj-$(CONFIG_USB_CDC_PHONET)	+=3D cdc-phonet.o
=20
diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.=
c
new file mode 100644
index 0000000..d335b72
--- /dev/null
+++ b/drivers/net/usb/cdc-phonet.c
@@ -0,0 +1,451 @@
+/*
+ * phonet.c -- USB CDC Phonet host driver
+ *
+ * Copyright (C) 2008-2009 Nokia Corporation. All rights reserved.
+ *
+ * Author: R=C3=A9mi Denis-Courmont
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =C2=A0See the =
GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/usb.h>
+#include <linux/usb/cdc.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/if_phonet.h>
+
+#define PN_MEDIA_USB	0x1B
+
+static const unsigned rxq_size =3D 17;
+
+struct usbpn_dev {
+	struct net_device	*dev;
+	atomic_t		tx_queue;
+
+	struct usb_interface	*intf, *data_intf;
+	struct usb_device	*usb;
+	unsigned int		tx_pipe, rx_pipe;
+	u8 active_setting;
+
+	spinlock_t		rx_lock;
+	struct sk_buff		*rx_skb;
+	struct urb		*urbs[0];
+};
+
+static void tx_complete(struct urb *req);
+static void rx_complete(struct urb *req);
+
+/*
+ * Network device callbacks
+ */
+static int usbpn_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct usbpn_dev *pnd =3D netdev_priv(dev);
+	struct urb *req =3D NULL;
+	int err;
+
+	if (skb->protocol !=3D htons(ETH_P_PHONET))
+		goto drop;
+
+	req =3D usb_alloc_urb(0, GFP_ATOMIC);
+	if (!req)
+		goto drop;
+	usb_fill_bulk_urb(req, pnd->usb, pnd->tx_pipe, skb->data, skb->len,
+				tx_complete, skb);
+	req->transfer_flags =3D URB_ZERO_PACKET;
+	err =3D usb_submit_urb(req, GFP_ATOMIC);
+	if (err) {
+		usb_free_urb(req);
+		goto drop;
+	}
+
+	netif_stop_queue(dev);
+	if (atomic_inc_return(&pnd->tx_queue) < dev->tx_queue_len)
+		netif_wake_queue(dev);
+	return 0;
+
+drop:
+	dev_kfree_skb(skb);
+	dev->stats.tx_dropped++;
+	return 0;
+}
+
+static void tx_complete(struct urb *req)
+{
+	struct sk_buff *skb =3D req->context;
+	struct net_device *dev =3D skb->dev;
+	struct usbpn_dev *pnd =3D netdev_priv(dev);
+
+	switch (req->status) {
+	case 0:
+		dev->stats.tx_bytes +=3D skb->len;
+		break;
+
+	case -ENOENT:
+	case -ECONNRESET:
+	case -ESHUTDOWN:
+		dev->stats.tx_aborted_errors++;
+	default:
+		dev->stats.tx_errors++;
+		dev_dbg(&dev->dev, "TX error (%d)\n", req->status);
+	}
+	dev->stats.tx_packets++;
+
+	atomic_dec(&pnd->tx_queue);
+	netif_wake_queue(dev);
+
+	dev_kfree_skb_any(skb);
+	usb_free_urb(req);
+}
+
+static int rx_submit(struct usbpn_dev *pnd, struct urb *req, gfp_t gfp=
_flags)
+{
+	struct net_device *dev =3D pnd->dev;
+	struct page *page;
+	int err;
+
+	page =3D __netdev_alloc_page(dev, gfp_flags);
+	if (!page)
+		return -ENOMEM;
+
+	usb_fill_bulk_urb(req, pnd->usb, pnd->rx_pipe, page_address(page),
+				PAGE_SIZE, rx_complete, dev);
+	req->transfer_flags =3D 0;
+	err =3D usb_submit_urb(req, gfp_flags);
+	if (unlikely(err)) {
+		dev_dbg(&dev->dev, "RX submit error (%d)\n", err);
+		netdev_free_page(dev, page);
+	}
+	return err;
+}
+
+static void rx_complete(struct urb *req)
+{
+	struct net_device *dev =3D req->context;
+	struct usbpn_dev *pnd =3D netdev_priv(dev);
+	struct page *page =3D virt_to_page(req->transfer_buffer);
+	struct sk_buff *skb;
+	unsigned long flags;
+
+	switch (req->status) {
+	case 0:
+		spin_lock_irqsave(&pnd->rx_lock, flags);
+		skb =3D pnd->rx_skb;
+		if (!skb) {
+			skb =3D pnd->rx_skb =3D netdev_alloc_skb(dev, 12);
+			if (likely(skb)) {
+				/* Can't use pskb_pull() on page in IRQ */
+				memcpy(skb_put(skb, 1), page_address(page), 1);
+				skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+						page, 1, req->actual_length);
+				page =3D NULL;
+			}
+		} else {
+			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+					page, 0, req->actual_length);
+			page =3D NULL;
+		}
+		if (req->actual_length < PAGE_SIZE)
+			pnd->rx_skb =3D NULL; /* Last fragment */
+		else
+			skb =3D NULL;
+		spin_unlock_irqrestore(&pnd->rx_lock, flags);
+		if (skb) {
+			skb->protocol =3D htons(ETH_P_PHONET);
+			skb_reset_mac_header(skb);
+			__skb_pull(skb, 1);
+			skb->dev =3D dev;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes +=3D skb->len;
+
+			netif_rx(skb);
+		}
+		goto resubmit;
+
+	case -ENOENT:
+	case -ECONNRESET:
+	case -ESHUTDOWN:
+		req =3D NULL;
+		break;
+
+	case -EOVERFLOW:
+		dev->stats.rx_over_errors++;
+		dev_dbg(&dev->dev, "RX overflow\n");
+		break;
+
+	case -EILSEQ:
+		dev->stats.rx_crc_errors++;
+		break;
+	}
+
+	dev->stats.rx_errors++;
+resubmit:
+	if (page)
+		netdev_free_page(dev, page);
+	if (req)
+		rx_submit(pnd, req, GFP_ATOMIC);
+}
+
+static int usbpn_open(struct net_device *dev)
+{
+	struct usbpn_dev *pnd =3D netdev_priv(dev);
+	int err;
+	unsigned i;
+	unsigned num =3D pnd->data_intf->cur_altsetting->desc.bInterfaceNumbe=
r;
+
+	err =3D usb_set_interface(pnd->usb, num, pnd->active_setting);
+	if (err)
+		return err;
+
+	for (i =3D 0; i < rxq_size; i++) {
+		struct urb *req =3D usb_alloc_urb(0, GFP_KERNEL);
+
+		if (req && rx_submit(pnd, req, GFP_KERNEL)) {
+			usb_free_urb(req);
+			req =3D NULL;
+		}
+		pnd->urbs[i] =3D req;
+	}
+
+	netif_wake_queue(dev);
+	return 0;
+}
+
+static int usbpn_close(struct net_device *dev)
+{
+	struct usbpn_dev *pnd =3D netdev_priv(dev);
+	unsigned i;
+	unsigned num =3D pnd->data_intf->cur_altsetting->desc.bInterfaceNumbe=
r;
+
+	netif_stop_queue(dev);
+
+	for (i =3D 0; i < rxq_size; i++) {
+		struct urb *req =3D pnd->urbs[i];
+
+		if (!req)
+			continue;
+		usb_kill_urb(req);
+		usb_free_urb(req);
+		pnd->urbs[i] =3D NULL;
+	}
+
+	return usb_set_interface(pnd->usb, num, !pnd->active_setting);
+}
+
+static int usbpn_set_mtu(struct net_device *dev, int new_mtu)
+{
+	if ((new_mtu < PHONET_MIN_MTU) || (new_mtu > PHONET_MAX_MTU))
+		return -EINVAL;
+
+	dev->mtu =3D new_mtu;
+	return 0;
+}
+
+static const struct net_device_ops usbpn_ops =3D {
+	.ndo_open	=3D usbpn_open,
+	.ndo_stop	=3D usbpn_close,
+	.ndo_start_xmit =3D usbpn_xmit,
+	.ndo_change_mtu =3D usbpn_set_mtu,
+};
+
+static void usbpn_setup(struct net_device *dev)
+{
+	dev->features		=3D 0;
+	dev->netdev_ops		=3D &usbpn_ops,
+	dev->header_ops		=3D &phonet_header_ops;
+	dev->type		=3D ARPHRD_PHONET;
+	dev->flags		=3D IFF_POINTOPOINT | IFF_NOARP;
+	dev->mtu		=3D PHONET_MAX_MTU;
+	dev->hard_header_len	=3D 1;
+	dev->dev_addr[0]	=3D PN_MEDIA_USB;
+	dev->addr_len		=3D 1;
+	dev->tx_queue_len	=3D 3;
+
+	dev->destructor		=3D free_netdev;
+}
+
+/*
+ * USB driver callbacks
+ */
+static struct usb_device_id usbpn_ids[] =3D {
+	{
+		.match_flags =3D USB_DEVICE_ID_MATCH_VENDOR
+			| USB_DEVICE_ID_MATCH_INT_CLASS
+			| USB_DEVICE_ID_MATCH_INT_SUBCLASS,
+		.idVendor =3D 0x0421, /* Nokia */
+		.bInterfaceClass =3D USB_CLASS_COMM,
+		.bInterfaceSubClass =3D 0xFE,
+	},
+	{ },
+};
+
+MODULE_DEVICE_TABLE(usb, usbpn_ids);
+
+static struct usb_driver usbpn_driver;
+
+int usbpn_probe(struct usb_interface *intf, const struct usb_device_id=
 *id)
+{
+	static const char ifname[] =3D "usbpn%d";
+	const struct usb_cdc_union_desc *union_header =3D NULL;
+	const struct usb_cdc_header_desc *phonet_header =3D NULL;
+	const struct usb_host_interface *data_desc;
+	struct usb_interface *data_intf;
+	struct usb_device *usbdev =3D interface_to_usbdev(intf);
+	struct net_device *dev;
+	struct usbpn_dev *pnd;
+	u8 *data;
+	int len, err;
+
+	data =3D intf->altsetting->extra;
+	len =3D intf->altsetting->extralen;
+	while (len >=3D 3) {
+		u8 dlen =3D data[0];
+		if (dlen < 3)
+			return -EINVAL;
+
+		/* bDescriptorType */
+		if (data[1] =3D=3D USB_DT_CS_INTERFACE) {
+			/* bDescriptorSubType */
+			switch (data[2]) {
+			case USB_CDC_UNION_TYPE:
+				if (union_header || dlen < 5)
+					break;
+				union_header =3D
+					(struct usb_cdc_union_desc *)data;
+				break;
+			case 0xAB:
+				if (phonet_header || dlen < 5)
+					break;
+				phonet_header =3D
+					(struct usb_cdc_header_desc *)data;
+				break;
+			}
+		}
+		data +=3D dlen;
+		len -=3D dlen;
+	}
+
+	if (!union_header || !phonet_header)
+		return -EINVAL;
+
+	data_intf =3D usb_ifnum_to_if(usbdev, union_header->bSlaveInterface0)=
;
+	if (data_intf =3D=3D NULL)
+		return -ENODEV;
+	/* Data interface has one inactive and one active setting */
+	if (data_intf->num_altsetting !=3D 2)
+		return -EINVAL;
+	if (data_intf->altsetting[0].desc.bNumEndpoints =3D=3D 0
+	 && data_intf->altsetting[1].desc.bNumEndpoints =3D=3D 2)
+		data_desc =3D data_intf->altsetting + 1;
+	else
+	if (data_intf->altsetting[0].desc.bNumEndpoints =3D=3D 2
+	 && data_intf->altsetting[1].desc.bNumEndpoints =3D=3D 0)
+		data_desc =3D data_intf->altsetting;
+	else
+		return -EINVAL;
+
+	dev =3D alloc_netdev(sizeof(*pnd) + sizeof(pnd->urbs[0]) * rxq_size,
+				ifname, usbpn_setup);
+	if (!dev)
+		return -ENOMEM;
+
+	pnd =3D netdev_priv(dev);
+	SET_NETDEV_DEV(dev, &intf->dev);
+	netif_stop_queue(dev);
+
+	pnd->dev =3D dev;
+	atomic_set(&pnd->tx_queue, 0);
+	pnd->usb =3D usb_get_dev(usbdev);
+	pnd->intf =3D intf;
+	pnd->data_intf =3D data_intf;
+	spin_lock_init(&pnd->rx_lock);
+	/* Endpoints */
+	if ((data_desc->endpoint[0].desc.bEndpointAddress & USB_DIR_IN) =3D=3D
+			USB_DIR_IN) {
+		pnd->rx_pipe =3D usb_rcvbulkpipe(usbdev,
+			data_desc->endpoint[0].desc.bEndpointAddress);
+		pnd->tx_pipe =3D usb_sndbulkpipe(usbdev,
+			data_desc->endpoint[1].desc.bEndpointAddress);
+	} else {
+		pnd->rx_pipe =3D usb_rcvbulkpipe(usbdev,
+			data_desc->endpoint[1].desc.bEndpointAddress);
+		pnd->tx_pipe =3D usb_sndbulkpipe(usbdev,
+			data_desc->endpoint[0].desc.bEndpointAddress);
+	}
+	pnd->active_setting =3D data_desc - data_intf->altsetting;
+
+	err =3D usb_driver_claim_interface(&usbpn_driver, data_intf, pnd);
+	if (err)
+		goto out;
+
+	/* Force inactive mode until the network device is brought UP */
+	usb_set_interface(usbdev, union_header->bSlaveInterface0,
+				!pnd->active_setting);
+	usb_set_intfdata(intf, pnd);
+	BUG_ON(!usb_get_intfdata(intf));
+
+	err =3D register_netdev(dev);
+	if (err) {
+		usb_driver_release_interface(&usbpn_driver, data_intf);
+		goto out;
+	}
+
+	dev_dbg(&dev->dev, "USB CDC Phonet device found\n");
+	return 0;
+
+out:
+	usb_set_intfdata(intf, NULL);
+	free_netdev(dev);
+	return err;
+}
+
+static void usbpn_disconnect(struct usb_interface *intf)
+{
+	struct usbpn_dev *pnd =3D usb_get_intfdata(intf);
+
+	if (intf !=3D pnd->data_intf) {
+		usb_driver_release_interface(&usbpn_driver, pnd->data_intf);
+		return;
+	}
+
+	unregister_netdev(pnd->dev);
+	usb_put_dev(pnd->usb);
+}
+
+static struct usb_driver usbpn_driver =3D {
+	.name =3D		"cdc_phonet",
+	.probe =3D	usbpn_probe,
+	.disconnect =3D	usbpn_disconnect,
+	.id_table =3D	usbpn_ids,
+};
+
+static int __init usbpn_init(void)
+{
+	return usb_register(&usbpn_driver);
+}
+
+static void __exit usbpn_exit(void)
+{
+	usb_deregister(&usbpn_driver);
+}
+
+module_init(usbpn_init);
+module_exit(usbpn_exit);
+
+MODULE_AUTHOR("Remi Denis-Courmont");
+MODULE_DESCRIPTION("USB CDC Phonet host interface");
+MODULE_LICENSE("GPL");
--=20
1.6.0.4

