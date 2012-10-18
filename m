From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 10/14] net: cdc_mbim: adding MBIM driver
Date: Thu, 18 Oct 2012 22:41:03 +0200
Message-ID: <1350592867-25651-11-git-send-email-bjorn@mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Suarez <gpsuarez2512-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Fangxiaozhi (Franko)" <fangxiaozhi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1350592867-25651-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>

The CDC Mobile Broadband Interface Model (MBIM) specification
extends CDC NCM by
 - removing the redundant ethernet header from the point-to-point
   USB channel
 - adding support for multiple IP (v4 and/or v6) sessions multiplexed
   on the same USB channel
 - adding a MBIM control channel encapsulated in CDC
 - adding Device Service Streams (DSS), which are non IP generic data
   streams multiplexed on the same USB channel as the IP sessions

MBIM devices are managed using the dedicated control channel, and no
data will flow on the data channel until a control session has been
established.  This driver has no knowledge of MBIM control messages.
It just exports the control channel to a /dev/cdc-wdmX character
device for userspace management applications. Such an application is
therefore required to use this driver.

This patch implements basic MBIM support, reusing the NCM and WDM drive=
r
APIs, currently limited to IP sessions with SessionID 0. DSS and
multiplexed IP sessions are not yet supported.

Signed-off-by: Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_mbim.c  |  365 +++++++++++++++++++++++++++++++++++=
++++++++
 include/linux/usb/cdc_ncm.h |   10 ++
 2 files changed, 375 insertions(+)
 create mode 100644 drivers/net/usb/cdc_mbim.c

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
new file mode 100644
index 0000000..2f21139
--- /dev/null
+++ b/drivers/net/usb/cdc_mbim.c
@@ -0,0 +1,365 @@
+/*
+ * Copyright (c) 2012  Smith Micro Software, Inc.
+ * Copyright (c) 2012  Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
+ *
+ * This driver is based on and reuse most of cdc_ncm, which is
+ * Copyright (C) ST-Ericsson 2010-2012
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/ip.h>
+#include <linux/mii.h>
+#include <linux/usb.h>
+#include <linux/usb/cdc.h>
+#include <linux/usb/usbnet.h>
+#include <linux/usb/cdc-wdm.h>
+#include <linux/usb/cdc_ncm.h>
+
+/* driver specific data - must match cdc_ncm usage */
+struct cdc_mbim_state {
+	struct cdc_ncm_ctx *ctx;
+	atomic_t pmcount;
+	struct usb_driver *subdriver;
+	struct usb_interface *control;
+	struct usb_interface *data;
+};
+
+/* using a counter to merge subdriver requests with our own into a com=
bined state */
+static int cdc_mbim_manage_power(struct usbnet *dev, int on)
+{
+	struct cdc_mbim_state *info =3D (void *)&dev->data;
+	int rv =3D 0;
+
+	dev_dbg(&dev->intf->dev, "%s() pmcount=3D%d, on=3D%d\n", __func__, at=
omic_read(&info->pmcount), on);
+
+	if ((on && atomic_add_return(1, &info->pmcount) =3D=3D 1) || (!on && =
atomic_dec_and_test(&info->pmcount))) {
+		/* need autopm_get/put here to ensure the usbcore sees the new value=
 */
+		rv =3D usb_autopm_get_interface(dev->intf);
+		if (rv < 0)
+			goto err;
+		dev->intf->needs_remote_wakeup =3D on;
+		usb_autopm_put_interface(dev->intf);
+	}
+err:
+	return rv;
+}
+
+static int cdc_mbim_wdm_manage_power(struct usb_interface *intf, int s=
tatus)
+{
+	struct usbnet *dev =3D usb_get_intfdata(intf);
+
+	/* can be called while disconnecting */
+	if (!dev)
+		return 0;
+
+	return cdc_mbim_manage_power(dev, status);
+}
+
+
+static int cdc_mbim_bind(struct usbnet *dev, struct usb_interface *int=
f)
+{
+	struct cdc_ncm_ctx *ctx;
+	struct usb_driver *subdriver =3D ERR_PTR(-ENODEV);
+	int ret =3D -ENODEV;
+	u8 data_altsetting =3D CDC_NCM_DATA_ALTSETTING_NCM;
+	struct cdc_mbim_state *info =3D (void *)&dev->data;
+
+	/* see if interface supports MBIM alternate setting */
+	if (intf->num_altsetting =3D=3D 2) {
+		if (!cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
+			usb_set_interface(dev->udev,
+					  intf->cur_altsetting->desc.bInterfaceNumber,
+					  CDC_NCM_COMM_ALTSETTING_MBIM);
+		data_altsetting =3D CDC_NCM_DATA_ALTSETTING_MBIM;
+	}
+
+	/* Probably NCM, defer for cdc_ncm_bind */
+	if (!cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
+		goto err;
+
+	ret =3D cdc_ncm_bind_common(dev, intf, data_altsetting);
+	if (ret)
+		goto err;
+
+	ctx =3D info->ctx;
+
+	/* The MBIM descriptor and the status endpoint are required */
+	if (ctx->mbim_desc && dev->status)
+		subdriver =3D usb_cdc_wdm_register(ctx->control,
+						 &dev->status->desc,
+						 le16_to_cpu(ctx->mbim_desc->wMaxControlMessage),
+						 cdc_mbim_wdm_manage_power);
+	if (IS_ERR(subdriver)) {
+		ret =3D PTR_ERR(subdriver);
+		cdc_ncm_unbind(dev, intf);
+		goto err;
+	}
+
+	/* can't let usbnet use the interrupt endpoint */
+	dev->status =3D NULL;
+	info->subdriver =3D subdriver;
+
+	/* MBIM cannot do ARP */
+	dev->net->flags |=3D IFF_NOARP;
+err:
+	return ret;
+}
+
+static void cdc_mbim_unbind(struct usbnet *dev, struct usb_interface *=
intf)
+{
+	struct cdc_mbim_state *info =3D (void *)&dev->data;
+	struct cdc_ncm_ctx *ctx =3D info->ctx;
+
+	/* disconnect subdriver from control interface */
+	if (info->subdriver && info->subdriver->disconnect)
+		info->subdriver->disconnect(ctx->control);
+	info->subdriver =3D NULL;
+
+	/* let NCM unbind clean up both control and data interface */
+	cdc_ncm_unbind(dev, intf);
+}
+
+
+static struct sk_buff *cdc_mbim_tx_fixup(struct usbnet *dev, struct sk=
_buff *skb, gfp_t flags)
+{
+	struct sk_buff *skb_out;
+	struct cdc_mbim_state *info =3D (void *)&dev->data;
+	struct cdc_ncm_ctx *ctx =3D info->ctx;
+
+	if (!ctx)
+		goto error;
+
+	if (skb) {
+		if (skb->len <=3D sizeof(ETH_HLEN))
+			goto error;
+
+		skb_reset_mac_header(skb);
+		switch (eth_hdr(skb)->h_proto) {
+		case htons(ETH_P_IP):
+		case htons(ETH_P_IPV6):
+			skb_pull(skb, ETH_HLEN);
+			break;
+		default:
+			goto error;
+		}
+	}
+
+	spin_lock_bh(&ctx->mtx);
+	skb_out =3D cdc_ncm_fill_tx_frame(ctx, skb, cpu_to_le32(USB_CDC_MBIM_=
NDP16_IPS_SIGN));
+	spin_unlock_bh(&ctx->mtx);
+	return skb_out;
+
+error:
+	if (skb)
+		dev_kfree_skb_any(skb);
+
+	return NULL;
+}
+
+static struct sk_buff *cdc_mbim_process_dgram(struct usbnet *dev, u8 *=
buf, size_t len)
+{
+	__be16 proto;
+	struct sk_buff *skb =3D NULL;
+
+	switch (*buf & 0xf0) {
+	case 0x40:
+		proto =3D htons(ETH_P_IP);
+		break;
+	case 0x60:
+		proto =3D htons(ETH_P_IPV6);
+		break;
+	default:
+		goto err;
+	}
+
+	skb =3D netdev_alloc_skb_ip_align(dev->net,  len + ETH_HLEN);
+	if (!skb)
+		goto err;
+
+	/* add an ethernet header */
+	skb_put(skb, ETH_HLEN);
+	skb_reset_mac_header(skb);
+	eth_hdr(skb)->h_proto =3D proto;
+	memset(eth_hdr(skb)->h_source, 0, ETH_ALEN);
+	memcpy(eth_hdr(skb)->h_dest, dev->net->dev_addr, ETH_ALEN);
+
+	/* add datagram */
+	memcpy(skb_put(skb, len), buf, len);
+err:
+	return skb;
+}
+
+static int cdc_mbim_rx_fixup(struct usbnet *dev, struct sk_buff *skb_i=
n)
+{
+	struct sk_buff *skb;
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	int len;
+	int nframes;
+	int x;
+	int offset;
+	struct usb_cdc_ncm_ndp16 *ndp16;
+	struct usb_cdc_ncm_dpe16 *dpe16;
+	int ndpoffset;
+	int loopcount =3D 50; /* arbitrary max preventing infinite loop */
+
+	ndpoffset =3D cdc_ncm_rx_verify_nth16(ctx, skb_in);
+	if (ndpoffset < 0)
+		goto error;
+
+next_ndp:
+	nframes =3D cdc_ncm_rx_verify_ndp16(skb_in, ndpoffset);
+	if (nframes < 0)
+		goto error;
+
+	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)(skb_in->data + ndpoffset);
+
+	/* only supporting IPS Session #0 for now */
+	switch (ndp16->dwSignature) {
+	case cpu_to_le32(USB_CDC_MBIM_NDP16_IPS_SIGN):
+		break;
+	default:
+		netif_dbg(dev, rx_err, dev->net,
+			  "unsupported NDP signature <0x%08x>\n",
+			  le32_to_cpu(ndp16->dwSignature));
+		goto err_ndp;
+
+	}
+
+	dpe16 =3D ndp16->dpe16;
+	for (x =3D 0; x < nframes; x++, dpe16++) {
+		offset =3D le16_to_cpu(dpe16->wDatagramIndex);
+		len =3D le16_to_cpu(dpe16->wDatagramLength);
+
+		/*
+		 * CDC NCM ch. 3.7
+		 * All entries after first NULL entry are to be ignored
+		 */
+		if ((offset =3D=3D 0) || (len =3D=3D 0)) {
+			if (!x)
+				goto err_ndp; /* empty NTB */
+			break;
+		}
+
+		/* sanity checking */
+		if (((offset + len) > skb_in->len) || (len > ctx->rx_max) ||
+		    (len < sizeof(struct iphdr))) {
+			netif_dbg(dev, rx_err, dev->net,
+				  "invalid frame detected (ignored) offset[%u]=3D%u, length=3D%u, =
skb=3D%p\n",
+				  x, offset, len, skb_in);
+			if (!x)
+				goto err_ndp;
+			break;
+		} else {
+			skb =3D cdc_mbim_process_dgram(dev, skb_in->data + offset, len);
+			if (!skb)
+				goto error;
+			usbnet_skb_return(dev, skb);
+		}
+	}
+err_ndp:
+	/* are there more NDPs to process? */
+	ndpoffset =3D le16_to_cpu(ndp16->wNextNdpIndex);
+	if (ndpoffset && loopcount--)
+		goto next_ndp;
+
+	return 1;
+error:
+	return 0;
+}
+
+static int cdc_mbim_suspend(struct usb_interface *intf, pm_message_t m=
essage)
+{
+	int ret =3D 0;
+	struct usbnet *dev =3D usb_get_intfdata(intf);
+	struct cdc_mbim_state *info =3D (void *)&dev->data;
+	struct cdc_ncm_ctx *ctx =3D info->ctx;
+
+	if (ctx =3D=3D NULL) {
+		ret =3D -1;
+		goto error;
+	}
+
+	ret =3D usbnet_suspend(intf, message);
+	if (ret < 0)
+		goto error;
+
+	if (intf =3D=3D ctx->control && info->subdriver && info->subdriver->s=
uspend)
+		ret =3D info->subdriver->suspend(intf, message);
+	if (ret < 0)
+		usbnet_resume(intf);
+
+error:
+	return ret;
+}
+
+static int cdc_mbim_resume(struct usb_interface *intf)
+{
+	int  ret =3D 0;
+	struct usbnet *dev =3D usb_get_intfdata(intf);
+	struct cdc_mbim_state *info =3D (void *)&dev->data;
+	struct cdc_ncm_ctx *ctx =3D info->ctx;
+	bool callsub =3D (intf =3D=3D ctx->control && info->subdriver && info=
->subdriver->resume);
+
+	if (callsub)
+		ret =3D info->subdriver->resume(intf);
+	if (ret < 0)
+		goto err;
+	ret =3D usbnet_resume(intf);
+	if (ret < 0 && callsub && info->subdriver->suspend)
+		info->subdriver->suspend(intf, PMSG_SUSPEND);
+err:
+	return ret;
+}
+
+static const struct driver_info cdc_mbim_info =3D {
+	.description =3D "CDC MBIM",
+	.flags =3D FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN,
+	.bind =3D cdc_mbim_bind,
+	.unbind =3D cdc_mbim_unbind,
+	.manage_power =3D cdc_mbim_manage_power,
+	.rx_fixup =3D cdc_mbim_rx_fixup,
+	.tx_fixup =3D cdc_mbim_tx_fixup,
+};
+
+static const struct usb_device_id mbim_devs[] =3D {
+	/* This duplicate NCM entry is intentional. MBIM devices can
+	 * be disguised as NCM by default, and this is necessary to
+	 * allow us to bind the correct driver_info to such devices.
+	 *
+	 * bind() will sort out this for us, selecting the correct
+	 * entry and reject the other
+	 */
+	{ USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_NCM, USB_CDC_PR=
OTO_NONE),
+	  .driver_info =3D (unsigned long)&cdc_mbim_info,
+	},
+	{ USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_MBIM, USB_CDC_P=
ROTO_NONE),
+	  .driver_info =3D (unsigned long)&cdc_mbim_info,
+	},
+	{
+	},
+};
+MODULE_DEVICE_TABLE(usb, mbim_devs);
+
+static struct usb_driver cdc_mbim_driver =3D {
+	.name =3D "cdc_mbim",
+	.id_table =3D mbim_devs,
+	.probe =3D usbnet_probe,
+	.disconnect =3D usbnet_disconnect,
+	.suspend =3D cdc_mbim_suspend,
+	.resume =3D cdc_mbim_resume,
+	.reset_resume =3D	cdc_mbim_resume,
+	.supports_autosuspend =3D 1,
+	.disable_hub_initiated_lpm =3D 1,
+};
+module_usb_driver(cdc_mbim_driver);
+
+MODULE_AUTHOR("Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>");
+MODULE_AUTHOR("Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>");
+MODULE_DESCRIPTION("USB CDC MBIM host driver");
+MODULE_LICENSE("GPL");
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index d1719a7..3b8f9d4 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -36,6 +36,12 @@
  * SUCH DAMAGE.
  */
=20
+#define CDC_NCM_COMM_ALTSETTING_NCM		0
+#define CDC_NCM_COMM_ALTSETTING_MBIM		1
+
+#define CDC_NCM_DATA_ALTSETTING_NCM		1
+#define CDC_NCM_DATA_ALTSETTING_MBIM		2
+
 /* CDC NCM subclass 3.2.1 */
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
=20
@@ -74,6 +80,10 @@
 	(sizeof(struct usb_cdc_ncm_ndp16) +				\
 	      (CDC_NCM_DPT_DATAGRAMS_MAX + 1) * sizeof(struct usb_cdc_ncm_dpe=
16))
=20
+#define cdc_ncm_comm_intf_is_mbim(x)  ((x)->desc.bInterfaceSubClass =3D=
=3D USB_CDC_SUBCLASS_MBIM && \
+				       (x)->desc.bInterfaceProtocol =3D=3D USB_CDC_PROTO_NONE)
+#define cdc_ncm_data_intf_is_mbim(x)  ((x)->desc.bInterfaceProtocol =3D=
=3D USB_CDC_MBIM_PROTO_NTB)
+
 struct cdc_ncm_ctx {
 	struct usb_cdc_ncm_ntb_parameters ncm_parm;
 	struct hrtimer tx_timer;
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
