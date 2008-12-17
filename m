From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 5/5] Phonet: USB CDC Phonet function for gadget framework
Date: Wed, 17 Dec 2008 16:07:54 +0200
Message-ID: <1229522874-20636-5-git-send-email-remi.denis-courmont@nokia.com>
References: <200812171607.14184.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:40569 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbYLQOJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 09:09:24 -0500
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mBHE9CBE019763
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 16:09:21 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int02.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id mBHE7sdf016910
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 16:08:00 +0200
In-Reply-To: <200812171607.14184.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements the Nokia vendor-specific communication device class
function to exchange Phonet messages over USB. This function is already
found in the "PC suite" USB profile of (non-Linux) Nokia handsets.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/usb/gadget/f_phonet.c |  621 +++++++++++++++++++++++++++++++++=
++++++++
 drivers/usb/gadget/u_phonet.h |   21 ++
 2 files changed, 642 insertions(+), 0 deletions(-)
 create mode 100644 drivers/usb/gadget/f_phonet.c
 create mode 100644 drivers/usb/gadget/u_phonet.h

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phone=
t.c
new file mode 100644
index 0000000..d8fc9b3
--- /dev/null
+++ b/drivers/usb/gadget/f_phonet.c
@@ -0,0 +1,621 @@
+/*
+ * f_phonet.c -- USB CDC Phonet function
+ *
+ * Copyright (C) 2007-2008 Nokia Corporation. All rights reserved.
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
+#include <linux/device.h>
+
+#include <linux/netdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_phonet.h>
+#include <linux/if_arp.h>
+
+#include <linux/usb/ch9.h>
+#include <linux/usb/cdc.h>
+#include <linux/usb/composite.h>
+
+#include "u_phonet.h"
+
+#define PN_MEDIA_USB	0x1B
+
+/*--------------------------------------------------------------------=
-----*/
+
+struct phonet_port {
+	struct f_phonet			*usb;
+	spinlock_t			lock;
+};
+
+struct f_phonet {
+	struct usb_function		function;
+	struct net_device		*dev;
+	struct usb_ep			*in_ep, *out_ep;
+
+	struct usb_request		*in_req;
+	struct usb_request		*out_reqv[0];
+};
+
+static int phonet_rxq_size =3D 2;
+
+static inline struct f_phonet *func_to_pn(struct usb_function *f)
+{
+	return container_of(f, struct f_phonet, function);
+}
+
+/*--------------------------------------------------------------------=
-----*/
+
+#define USB_CDC_SUBCLASS_PHONET	0xfe
+#define USB_CDC_PHONET_TYPE	0xab
+
+static struct usb_interface_descriptor
+pn_control_intf_desc =3D {
+	.bLength =3D		sizeof pn_control_intf_desc,
+	.bDescriptorType =3D	USB_DT_INTERFACE,
+
+	/* .bInterfaceNumber =3D	DYNAMIC, */
+	.bInterfaceClass =3D	USB_CLASS_COMM,
+	.bInterfaceSubClass =3D	USB_CDC_SUBCLASS_PHONET,
+};
+
+static const struct usb_cdc_header_desc
+pn_header_desc =3D {
+	.bLength =3D		sizeof pn_header_desc,
+	.bDescriptorType =3D	USB_DT_CS_INTERFACE,
+	.bDescriptorSubType =3D	USB_CDC_HEADER_TYPE,
+	.bcdCDC =3D		__constant_cpu_to_le16(0x0110),
+};
+
+static const struct usb_cdc_header_desc
+pn_phonet_desc =3D {
+	.bLength =3D		sizeof pn_phonet_desc,
+	.bDescriptorType =3D	USB_DT_CS_INTERFACE,
+	.bDescriptorSubType =3D	USB_CDC_PHONET_TYPE,
+	.bcdCDC =3D		__constant_cpu_to_le16(0x1505), /* ??? */
+};
+
+static struct usb_cdc_union_desc
+pn_union_desc =3D {
+	.bLength =3D		sizeof pn_union_desc,
+	.bDescriptorType =3D	USB_DT_CS_INTERFACE,
+	.bDescriptorSubType =3D	USB_CDC_UNION_TYPE,
+
+	/* .bMasterInterface0 =3D	DYNAMIC, */
+	/* .bSlaveInterface0 =3D	DYNAMIC, */
+};
+
+static struct usb_interface_descriptor
+pn_data_nop_intf_desc =3D {
+	.bLength =3D		sizeof pn_data_nop_intf_desc,
+	.bDescriptorType =3D	USB_DT_INTERFACE,
+
+	/* .bInterfaceNumber =3D	DYNAMIC, */
+	.bAlternateSetting =3D	0,
+	.bNumEndpoints =3D	0,
+	.bInterfaceClass =3D	USB_CLASS_CDC_DATA,
+};
+
+static struct usb_interface_descriptor
+pn_data_intf_desc =3D {
+	.bLength =3D		sizeof pn_data_intf_desc,
+	.bDescriptorType =3D	USB_DT_INTERFACE,
+
+	/* .bInterfaceNumber =3D	DYNAMIC, */
+	.bAlternateSetting =3D	1,
+	.bNumEndpoints =3D	2,
+	.bInterfaceClass =3D	USB_CLASS_CDC_DATA,
+};
+
+static struct usb_endpoint_descriptor
+pn_fs_sink_desc =3D {
+	.bLength =3D		USB_DT_ENDPOINT_SIZE,
+	.bDescriptorType =3D	USB_DT_ENDPOINT,
+
+	.bEndpointAddress =3D	USB_DIR_OUT,
+	.bmAttributes =3D		USB_ENDPOINT_XFER_BULK,
+};
+
+static struct usb_endpoint_descriptor
+pn_hs_sink_desc =3D {
+	.bLength =3D		USB_DT_ENDPOINT_SIZE,
+	.bDescriptorType =3D	USB_DT_ENDPOINT,
+
+	.bEndpointAddress =3D	USB_DIR_OUT,
+	.bmAttributes =3D		USB_ENDPOINT_XFER_BULK,
+	.wMaxPacketSize =3D	__constant_cpu_to_le16(512),
+};
+
+static struct usb_endpoint_descriptor
+pn_fs_source_desc =3D {
+	.bLength =3D		USB_DT_ENDPOINT_SIZE,
+	.bDescriptorType =3D	USB_DT_ENDPOINT,
+
+	.bEndpointAddress =3D	USB_DIR_IN,
+	.bmAttributes =3D		USB_ENDPOINT_XFER_BULK,
+};
+
+static struct usb_endpoint_descriptor
+pn_hs_source_desc =3D {
+	.bLength =3D		USB_DT_ENDPOINT_SIZE,
+	.bDescriptorType =3D	USB_DT_ENDPOINT,
+
+	.bEndpointAddress =3D	USB_DIR_IN,
+	.bmAttributes =3D		USB_ENDPOINT_XFER_BULK,
+	.wMaxPacketSize =3D	__constant_cpu_to_le16(512),
+};
+
+static struct usb_descriptor_header *fs_pn_function[] =3D {
+	(struct usb_descriptor_header *) &pn_control_intf_desc,
+	(struct usb_descriptor_header *) &pn_header_desc,
+	(struct usb_descriptor_header *) &pn_phonet_desc,
+	(struct usb_descriptor_header *) &pn_union_desc,
+	(struct usb_descriptor_header *) &pn_data_nop_intf_desc,
+	(struct usb_descriptor_header *) &pn_data_intf_desc,
+	(struct usb_descriptor_header *) &pn_fs_sink_desc,
+	(struct usb_descriptor_header *) &pn_fs_source_desc,
+	NULL,
+};
+
+static struct usb_descriptor_header *hs_pn_function[] =3D {
+	(struct usb_descriptor_header *) &pn_control_intf_desc,
+	(struct usb_descriptor_header *) &pn_header_desc,
+	(struct usb_descriptor_header *) &pn_phonet_desc,
+	(struct usb_descriptor_header *) &pn_union_desc,
+	(struct usb_descriptor_header *) &pn_data_nop_intf_desc,
+	(struct usb_descriptor_header *) &pn_data_intf_desc,
+	(struct usb_descriptor_header *) &pn_hs_sink_desc,
+	(struct usb_descriptor_header *) &pn_hs_source_desc,
+	NULL,
+};
+
+/*--------------------------------------------------------------------=
-----*/
+
+static int pn_net_open(struct net_device *dev)
+{
+	if (netif_carrier_ok(dev))
+		netif_wake_queue(dev);
+	return 0;
+}
+
+static int pn_net_close(struct net_device *dev)
+{
+	netif_stop_queue(dev);
+	return 0;
+}
+
+static void pn_tx_complete(struct usb_ep *ep, struct usb_request *req)
+{
+	struct f_phonet *fp =3D ep->driver_data;
+	struct net_device *dev =3D fp->dev;
+	struct sk_buff *skb =3D req->context;
+
+	switch (req->status) {
+	case 0:
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes +=3D skb->len;
+		break;
+
+	case -ESHUTDOWN: /* disconnected */
+	case -ECONNRESET: /* disabled */
+		dev->stats.tx_aborted_errors++;
+	default:
+		dev->stats.tx_errors++;
+	}
+
+	dev_kfree_skb_any(skb);
+	if (netif_carrier_ok(dev))
+		netif_wake_queue(dev);
+}
+
+static int pn_net_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct phonet_port *port =3D netdev_priv(dev);
+	struct f_phonet *fp;
+	struct usb_request *req;
+	unsigned long flags;
+
+	if (skb->protocol !=3D htons(ETH_P_PHONET))
+		goto out;
+
+	spin_lock_irqsave(&port->lock, flags);
+	fp =3D port->usb;
+	if (unlikely(!fp)) /* race with carrier loss */
+		goto out_unlock;
+
+	req =3D fp->in_req;
+	req->buf =3D skb->data;
+	req->length =3D skb->len;
+	req->complete =3D pn_tx_complete;
+	req->zero =3D 1;
+	req->context =3D skb;
+
+	if (unlikely(usb_ep_queue(fp->in_ep, req, GFP_ATOMIC)))
+		goto out_unlock;
+
+	netif_stop_queue(dev);
+	skb =3D NULL;
+
+out_unlock:
+	spin_unlock_irqrestore(&port->lock, flags);
+out:
+	if (unlikely(skb)) {
+		dev_kfree_skb_any(skb);
+		dev->stats.tx_dropped++;
+	}
+	return 0;
+}
+
+static int pn_net_mtu(struct net_device *dev, int new_mtu)
+{
+	struct phonet_port *port =3D netdev_priv(dev);
+	unsigned long flags;
+	int err =3D -EBUSY;
+
+	if ((new_mtu < PHONET_MIN_MTU) || (new_mtu > PHONET_MAX_MTU))
+		return -EINVAL;
+
+	spin_lock_irqsave(&port->lock, flags);
+	if (!netif_carrier_ok(dev)) {
+		dev->mtu =3D new_mtu;
+		err =3D 0;
+	}
+	spin_unlock_irqrestore(&port->lock, flags);
+	return err;
+}
+
+static void pn_net_setup(struct net_device *dev)
+{
+	dev->features		=3D 0;
+	dev->type		=3D ARPHRD_PHONET;
+	dev->flags		=3D IFF_POINTOPOINT | IFF_NOARP;
+	dev->mtu		=3D PHONET_DEV_MTU;
+	dev->hard_header_len	=3D 1;
+	dev->dev_addr[0]	=3D PN_MEDIA_USB;
+	dev->addr_len		=3D 1;
+	dev->tx_queue_len	=3D 1;
+
+	dev->destructor		=3D free_netdev;
+	dev->header_ops		=3D &phonet_header_ops;
+	dev->open		=3D pn_net_open;
+	dev->stop		=3D pn_net_close;
+	dev->hard_start_xmit	=3D pn_net_xmit; /* mandatory */
+	dev->change_mtu		=3D pn_net_mtu;
+}
+
+/*--------------------------------------------------------------------=
-----*/
+
+/*
+ * Queue buffer for data from the host
+ */
+static int
+pn_rx_submit(struct f_phonet *fp, struct usb_request *req, gfp_t gfp_f=
lags)
+{
+	struct sk_buff *skb;
+	const size_t size =3D fp->dev->mtu;
+	int err;
+
+	skb =3D alloc_skb(size, gfp_flags);
+	if (!skb)
+		return -ENOMEM;
+
+	req->buf =3D skb->data;
+	req->length =3D size;
+	req->context =3D skb;
+
+	err =3D usb_ep_queue(fp->out_ep, req, gfp_flags);
+	if (unlikely(err))
+		dev_kfree_skb_any(skb);
+	return err;
+}
+
+static void pn_rx_complete(struct usb_ep *ep, struct usb_request *req)
+{
+	struct f_phonet *fp =3D ep->driver_data;
+	struct net_device *dev =3D fp->dev;
+	struct sk_buff *skb =3D req->context;
+	int status =3D req->status;
+
+	switch (status) {
+	case 0:
+		if (unlikely(!netif_running(dev)))
+			break;
+		if (unlikely(req->actual < 1))
+			break;
+		skb_put(skb, req->actual);
+		skb->protocol =3D htons(ETH_P_PHONET);
+		skb_reset_mac_header(skb);
+		__skb_pull(skb, 1);
+		skb->dev =3D dev;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes +=3D skb->len;
+
+		netif_rx(skb);
+		skb =3D NULL;
+		break;
+
+	/* Do not resubmit in these cases: */
+	case -ESHUTDOWN: /* disconnect */
+	case -ECONNABORTED: /* hw reset */
+	case -ECONNRESET: /* dequeued (unlink or netif down) */
+		req =3D NULL;
+		break;
+
+	/* Do resubmit in these cases: */
+	case -EOVERFLOW: /* request buffer overflow */
+		dev->stats.rx_over_errors++;
+	default:
+		dev->stats.rx_errors++;
+		break;
+	}
+
+	if (skb)
+		dev_kfree_skb_any(skb);
+	if (req)
+		pn_rx_submit(fp, req, GFP_ATOMIC);
+}
+
+/*--------------------------------------------------------------------=
-----*/
+
+static void __pn_reset(struct usb_function *f)
+{
+	struct f_phonet *fp =3D func_to_pn(f);
+	struct net_device *dev =3D fp->dev;
+	struct phonet_port *port =3D netdev_priv(dev);
+
+	netif_carrier_off(dev);
+	netif_stop_queue(dev);
+	port->usb =3D NULL;
+
+	usb_ep_disable(fp->out_ep);
+	usb_ep_disable(fp->in_ep);
+}
+
+static int pn_set_alt(struct usb_function *f, unsigned intf, unsigned =
alt)
+{
+	struct f_phonet *fp =3D func_to_pn(f);
+	struct usb_gadget *gadget =3D fp->function.config->cdev->gadget;
+
+	if (intf =3D=3D pn_control_intf_desc.bInterfaceNumber)
+		/* control interface, no altsetting */
+		return (alt > 0) ? -EINVAL : 0;
+
+	if (intf =3D=3D pn_data_intf_desc.bInterfaceNumber) {
+		struct net_device *dev =3D fp->dev;
+		struct phonet_port *port =3D netdev_priv(dev);
+
+		/* data intf (0: inactive, 1: active) */
+		if (alt > 1)
+			return -EINVAL;
+
+		spin_lock(&port->lock);
+		__pn_reset(f);
+		if (alt =3D=3D 1) {
+			struct usb_endpoint_descriptor *out, *in;
+			int i;
+
+			out =3D ep_choose(gadget,
+					&pn_hs_sink_desc,
+					&pn_fs_sink_desc);
+			in =3D ep_choose(gadget,
+					&pn_hs_source_desc,
+					&pn_fs_source_desc);
+			usb_ep_enable(fp->out_ep, out);
+			usb_ep_enable(fp->in_ep, in);
+
+			port->usb =3D fp;
+			fp->out_ep->driver_data =3D fp;
+			fp->in_ep->driver_data =3D fp;
+
+			netif_carrier_on(dev);
+			if (netif_running(dev))
+				netif_wake_queue(dev);
+			for (i =3D 0; i < phonet_rxq_size; i++)
+				pn_rx_submit(fp, fp->out_reqv[i], GFP_ATOMIC);
+		}
+		spin_unlock(&port->lock);
+		return 0;
+	}
+
+	return -EINVAL;
+}
+
+static int pn_get_alt(struct usb_function *f, unsigned intf)
+{
+	struct f_phonet *fp =3D func_to_pn(f);
+
+	if (intf =3D=3D pn_control_intf_desc.bInterfaceNumber)
+		return 0;
+
+	if (intf =3D=3D pn_data_intf_desc.bInterfaceNumber) {
+		struct phonet_port *port =3D netdev_priv(fp->dev);
+		u8 alt;
+
+		spin_lock(&port->lock);
+		alt =3D port->usb !=3D NULL;
+		spin_unlock(&port->lock);
+		return alt;
+	}
+
+	return -EINVAL;
+}
+
+static void pn_disconnect(struct usb_function *f)
+{
+	struct f_phonet *fp =3D func_to_pn(f);
+	struct phonet_port *port =3D netdev_priv(fp->dev);
+	unsigned long flags;
+
+	/* remain disabled until set_alt */
+	spin_lock_irqsave(&port->lock, flags);
+	__pn_reset(f);
+	spin_unlock_irqrestore(&port->lock, flags);
+}
+
+/*--------------------------------------------------------------------=
-----*/
+
+static __init
+int pn_bind(struct usb_configuration *c, struct usb_function *f)
+{
+	struct usb_composite_dev *cdev =3D c->cdev;
+	struct usb_gadget *gadget =3D cdev->gadget;
+	struct f_phonet *fp =3D func_to_pn(f);
+	struct usb_ep *ep;
+	int status, i;
+
+	/* Reserve interface IDs */
+	status =3D usb_interface_id(c, f);
+	if (status < 0)
+		goto err;
+	pn_control_intf_desc.bInterfaceNumber =3D status;
+	pn_union_desc.bMasterInterface0 =3D status;
+
+	status =3D usb_interface_id(c, f);
+	if (status < 0)
+		goto err;
+	pn_data_nop_intf_desc.bInterfaceNumber =3D status;
+	pn_data_intf_desc.bInterfaceNumber =3D status;
+	pn_union_desc.bSlaveInterface0 =3D status;
+
+	/* Reserve endpoints */
+	status =3D -ENODEV;
+	ep =3D usb_ep_autoconfig(gadget, &pn_fs_sink_desc);
+	if (!ep)
+		goto err;
+	fp->out_ep =3D ep;
+	ep->driver_data =3D fp; /* Claim */
+
+	ep =3D usb_ep_autoconfig(gadget, &pn_fs_source_desc);
+	if (!ep)
+		goto err;
+	fp->in_ep =3D ep;
+	ep->driver_data =3D fp; /* Claim */
+
+	pn_hs_sink_desc.bEndpointAddress =3D
+		pn_fs_sink_desc.bEndpointAddress;
+	pn_hs_source_desc.bEndpointAddress =3D
+		pn_fs_source_desc.bEndpointAddress;
+
+	/* Do not try to bind Phonet twice... */
+	fp->function.descriptors =3D fs_pn_function;
+	fp->function.hs_descriptors =3D hs_pn_function;
+
+	/* Incoming USB requests */
+	status =3D -ENOMEM;
+	for (i =3D 0; i < phonet_rxq_size; i++) {
+		struct usb_request *req;
+
+		req =3D usb_ep_alloc_request(fp->out_ep, GFP_KERNEL);
+		if (!req)
+			goto err;
+
+		req->complete =3D pn_rx_complete;
+		fp->out_reqv[i] =3D req;
+	}
+
+	/* Outgoing USB requests */
+	fp->in_req =3D usb_ep_alloc_request(fp->in_ep, GFP_KERNEL);
+	if (!fp->in_req)
+		goto err;
+
+	INFO(cdev, "USB CDC Phonet function\n");
+	INFO(cdev, "using %s, OUT %s, IN %s\n", cdev->gadget->name,
+		fp->out_ep->name, fp->in_ep->name);
+	return 0;
+
+err:
+	if (fp->out_ep)
+		fp->out_ep->driver_data =3D NULL;
+	if (fp->in_ep)
+		fp->in_ep->driver_data =3D NULL;
+	ERROR(cdev, "USB CDC Phonet: cannot autoconfigure\n");
+	return status;
+}
+
+static void
+pn_unbind(struct usb_configuration *c, struct usb_function *f)
+{
+	struct f_phonet *fp =3D func_to_pn(f);
+	int i;
+
+	/* We are already disconnected */
+	if (fp->in_req)
+		usb_ep_free_request(fp->in_ep, fp->in_req);
+	for (i =3D 0; i < phonet_rxq_size; i++)
+		if (fp->out_reqv[i])
+			usb_ep_free_request(fp->out_ep, fp->out_reqv[i]);
+
+	kfree(fp);
+}
+
+/*--------------------------------------------------------------------=
-----*/
+
+static struct net_device *dev;
+
+int __init phonet_bind_config(struct usb_configuration *c)
+{
+	struct f_phonet *fp;
+	int err;
+
+	fp =3D kzalloc(sizeof(*fp), GFP_KERNEL);
+	if (!fp)
+		return -ENOMEM;
+
+	fp->dev =3D dev;
+	fp->function.name =3D "phonet";
+	fp->function.bind =3D pn_bind;
+	fp->function.unbind =3D pn_unbind;
+	fp->function.set_alt =3D pn_set_alt;
+	fp->function.get_alt =3D pn_get_alt;
+	fp->function.disable =3D pn_disconnect;
+
+	err =3D usb_add_function(c, &fp->function);
+	if (err)
+		kfree(fp);
+	return err;
+}
+
+int __init gphonet_setup(struct usb_gadget *gadget)
+{
+	struct phonet_port *port;
+	int err;
+
+	/* Create net device */
+	BUG_ON(dev);
+	dev =3D alloc_netdev(sizeof(*port)
+		+ (phonet_rxq_size * sizeof(struct usb_request *)),
+				"upnlink%d", pn_net_setup);
+	if (!dev)
+		return -ENOMEM;
+
+	port =3D netdev_priv(dev);
+	spin_lock_init(&port->lock);
+	netif_carrier_off(dev);
+	netif_stop_queue(dev);
+	SET_NETDEV_DEV(dev, &gadget->dev);
+
+	err =3D register_netdev(dev);
+	if (err)
+		free_netdev(dev);
+	return err;
+}
+
+void gphonet_cleanup(void)
+{
+	unregister_netdev(dev);
+}
diff --git a/drivers/usb/gadget/u_phonet.h b/drivers/usb/gadget/u_phone=
t.h
new file mode 100644
index 0000000..09a7525
--- /dev/null
+++ b/drivers/usb/gadget/u_phonet.h
@@ -0,0 +1,21 @@
+/*
+ * u_phonet.h - interface to Phonet
+ *
+ * Copyright (C) 2007-2008 by Nokia Corporation
+ *
+ * This software is distributed under the terms of the GNU General
+ * Public License ("GPL") as published by the Free Software Foundation=
,
+ * either version 2 of that License or (at your option) any later vers=
ion.
+ */
+
+#ifndef __U_PHONET_H
+#define __U_PHONET_H
+
+#include <linux/usb/composite.h>
+#include <linux/usb/cdc.h>
+
+int gphonet_setup(struct usb_gadget *gadget);
+int phonet_bind_config(struct usb_configuration *c);
+void gphonet_cleanup(void);
+
+#endif /* __U_PHONET_H */
--=20
1.5.4.3

