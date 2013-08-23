From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH RESEND V3 net-next 2/3] net: huawei_cdc_ncm: Introduce the huawei_cdc_ncm driver
Date: Fri, 23 Aug 2013 09:56:29 +0200
Message-ID: <1377244590-8558-3-git-send-email-mrkiko.rs@gmail.com>
References: <mrkiko.rs@gmail.com>
 <1377244590-8558-1-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: gregkh@linuxfoundation.org, oliver@neukum.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:42300 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922Ab3HWH4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 03:56:36 -0400
In-Reply-To: <1377244590-8558-1-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver supports devices using the NCM protocol as an encapsulation=
 layer
for other protocols, like the E3131 Huawei 3G modem. This drivers appro=
ach was=20
heavily inspired by the qmi_wwan approach & code model.

Suggested-by: Bjorn Mork <bjorn@mork.no>
Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
---
 drivers/net/usb/Kconfig          |   11 ++
 drivers/net/usb/Makefile         |    1 +
 drivers/net/usb/huawei_cdc_ncm.c |  210 ++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 222 insertions(+)
 create mode 100644 drivers/net/usb/huawei_cdc_ncm.c

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index d84bfd4..6e56751 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -242,6 +242,17 @@ config USB_NET_CDC_NCM
 	    * ST-Ericsson M343 HSPA Mobile Broadband Modem (reference design)
 	    * Ericsson F5521gw Mobile Broadband Module
=20
+config USB_NET_HUAWEI_CDC_NCM
+	tristate "Huawei-style CDC NCM support"
+	depends on USB_USBNET
+	select USB_WDM
+	select USB_NET_CDC_NCM
+	help
+		This driver aims to support huawei-style NCM devices, that use ncm a=
s a
+		transport for other protocols.
+		To compile this driver as a module, choose M here: the module will b=
e
+		called huawei_cdc_ncm.
+
 config USB_NET_CDC_MBIM
 	tristate "CDC MBIM support"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index e817178..fd0e6a7 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -31,6 +31,7 @@ obj-$(CONFIG_USB_IPHETH)	+=3D ipheth.o
 obj-$(CONFIG_USB_SIERRA_NET)	+=3D sierra_net.o
 obj-$(CONFIG_USB_NET_CX82310_ETH)	+=3D cx82310_eth.o
 obj-$(CONFIG_USB_NET_CDC_NCM)	+=3D cdc_ncm.o
+obj-$(CONFIG_USB_NET_HUAWEI_CDC_NCM)	+=3D huawei_cdc_ncm.o
 obj-$(CONFIG_USB_VL600)		+=3D lg-vl600.o
 obj-$(CONFIG_USB_NET_QMI_WWAN)	+=3D qmi_wwan.o
 obj-$(CONFIG_USB_NET_CDC_MBIM)	+=3D cdc_mbim.o
diff --git a/drivers/net/usb/huawei_cdc_ncm.c b/drivers/net/usb/huawei_=
cdc_ncm.c
new file mode 100644
index 0000000..d3426b9
--- /dev/null
+++ b/drivers/net/usb/huawei_cdc_ncm.c
@@ -0,0 +1,210 @@
+/*
+ * huawei_cdc_ncm.c - handles huawei-style NCM devices.
+ * Copyright (C) 2013	 Enrico Mioso <mrkiko.rs@gmail.com>
+ * This driver handles devices resembling the CDC NCM standard, but
+ * encapsulating another protocol inside it. An example are some Huawe=
i 3G
+ * devices, exposing an embedded AT channel where you can set up the N=
CM
+ * connection.
+ * This code has been heavily inspired by the cdc_mbim.c driver, which=
 is
+ * Copyright (c) 2012  Smith Micro Software, Inc.
+ * Copyright (c) 2012  Bj=C3=B8rn Mork <bjorn@mork.no>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+#include <linux/ip.h>
+#include <linux/mii.h>
+#include <linux/usb.h>
+#include <linux/usb/cdc.h>
+#include <linux/usb/usbnet.h>
+#include <linux/usb/cdc-wdm.h>
+#include <linux/usb/cdc_ncm.h>
+
+/* Driver data */
+struct huawei_cdc_ncm_state {
+	struct cdc_ncm_ctx *ctx;
+	atomic_t pmcount;
+	struct usb_driver *subdriver;
+	struct usb_interface *control;
+	struct usb_interface *data;
+};
+
+static int huawei_cdc_ncm_manage_power(struct usbnet *usbnet_dev, int =
on)
+{
+	struct huawei_cdc_ncm_state *drvstate =3D (void *)&usbnet_dev->data;
+	int rv =3D 0;
+
+	if ((on && atomic_add_return(1, &drvstate->pmcount) =3D=3D 1) || (!on=
 && atomic_dec_and_test(&drvstate->pmcount))) {
+		rv =3D usb_autopm_get_interface(usbnet_dev->intf);
+		if (rv < 0)
+			goto err;
+		usbnet_dev->intf->needs_remote_wakeup =3D on;
+		usb_autopm_put_interface(usbnet_dev->intf);
+	}
+err:
+	return rv;
+}
+
+static int huawei_cdc_ncm_wdm_manage_power(struct usb_interface *intf,=
 int status)
+{
+	struct usbnet *usbnet_dev =3D usb_get_intfdata(intf);
+
+	/* can be called while disconnecting */
+	if (!usbnet_dev)
+		return 0;
+
+	return huawei_cdc_ncm_manage_power(usbnet_dev, status);
+}
+
+
+static int huawei_cdc_ncm_bind(struct usbnet *usbnet_dev, struct usb_i=
nterface *intf)
+{
+	struct cdc_ncm_ctx *ctx;
+	struct usb_driver *subdriver =3D ERR_PTR(-ENODEV);
+	int ret =3D -ENODEV;
+	struct huawei_cdc_ncm_state *drvstate =3D (void *)&usbnet_dev->data;
+
+	ret =3D cdc_ncm_bind_common(usbnet_dev, intf, 1); /* altsetting shoul=
d be 1 for NCM devices */
+	if (ret)
+		goto err;
+
+	ctx =3D drvstate->ctx;
+
+	if (usbnet_dev->status)
+		subdriver =3D usb_cdc_wdm_register(ctx->control,
+						 &usbnet_dev->status->desc,
+						 256, /* CDC-WMC r1.1 requires wMaxCommand to be "at least 256 d=
ecimal (0x100)" */
+						 huawei_cdc_ncm_wdm_manage_power);
+	if (IS_ERR(subdriver)) {
+		ret =3D PTR_ERR(subdriver);
+		cdc_ncm_unbind(usbnet_dev, intf);
+		goto err;
+	}
+
+	/* Prevent usbnet from using the status descriptor */
+	usbnet_dev->status =3D NULL;
+
+	drvstate->subdriver =3D subdriver;
+
+err:
+	return ret;
+}
+
+static void huawei_cdc_ncm_unbind(struct usbnet *usbnet_dev, struct us=
b_interface *intf)
+{
+	struct huawei_cdc_ncm_state *drvstate =3D (void *)&usbnet_dev->data;
+	struct cdc_ncm_ctx *ctx =3D drvstate->ctx;
+
+	if (drvstate->subdriver && drvstate->subdriver->disconnect)
+		drvstate->subdriver->disconnect(ctx->control);
+	drvstate->subdriver =3D NULL;
+
+	cdc_ncm_unbind(usbnet_dev, intf);
+}
+
+static int huawei_cdc_ncm_suspend(struct usb_interface *intf, pm_messa=
ge_t message)
+{
+	int ret =3D 0;
+	struct usbnet *usbnet_dev =3D usb_get_intfdata(intf);
+	struct huawei_cdc_ncm_state *drvstate =3D (void *)&usbnet_dev->data;
+	struct cdc_ncm_ctx *ctx =3D drvstate->ctx;
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
+	if (intf =3D=3D ctx->control && drvstate->subdriver && drvstate->subd=
river->suspend)
+		ret =3D drvstate->subdriver->suspend(intf, message);
+	if (ret < 0)
+		usbnet_resume(intf);
+
+error:
+	return ret;
+}
+
+static int huawei_cdc_ncm_resume(struct usb_interface *intf)
+{
+	int ret =3D 0;
+	struct usbnet *usbnet_dev =3D usb_get_intfdata(intf);
+	struct huawei_cdc_ncm_state *drvstate =3D (void *)&usbnet_dev->data;
+	struct cdc_ncm_ctx *ctx =3D drvstate->ctx;
+	bool callsub =3D (intf =3D=3D ctx->control && drvstate->subdriver && =
drvstate->subdriver->resume); /* should we call subdriver's resume? ? *=
/
+
+	if (callsub)
+		ret =3D drvstate->subdriver->resume(intf);
+	if (ret < 0)
+		goto err;
+	ret =3D usbnet_resume(intf);
+	if (ret < 0 && callsub && drvstate->subdriver->suspend)
+		drvstate->subdriver->suspend(intf, PMSG_SUSPEND);
+err:
+	return ret;
+}
+
+static int huawei_cdc_ncm_check_connect(struct usbnet *usbnet_dev)
+{
+	struct cdc_ncm_ctx *ctx;
+
+	ctx =3D (struct cdc_ncm_ctx *)usbnet_dev->data[0];
+
+	if (ctx =3D=3D NULL)
+		return 1; /* disconnected */
+
+	return !ctx->connected;
+}
+
+static const struct driver_info huawei_cdc_ncm_info =3D {
+	.description =3D "Huawei CDC NCM device",
+	.flags =3D FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN,
+	.bind =3D huawei_cdc_ncm_bind,
+	.unbind =3D huawei_cdc_ncm_unbind,
+	.check_connect =3D huawei_cdc_ncm_check_connect,
+	.manage_power =3D huawei_cdc_ncm_manage_power,
+	.rx_fixup =3D cdc_ncm_rx_fixup,
+	.tx_fixup =3D cdc_ncm_tx_fixup,
+};
+
+static const struct usb_device_id huawei_cdc_ncm_devs[] =3D {
+	/* Huawei NCM devices disguised as vendor specific */
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x16),
+	  .driver_info =3D (unsigned long)&huawei_cdc_ncm_info,
+	},
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x46),
+	  .driver_info =3D (unsigned long)&huawei_cdc_ncm_info,
+	},
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x76),
+	  .driver_info =3D (unsigned long)&huawei_cdc_ncm_info,
+	},
+
+	/* Terminating entry */
+	{
+	},
+};
+MODULE_DEVICE_TABLE(usb, huawei_cdc_ncm_devs);
+
+static struct usb_driver huawei_cdc_ncm_driver =3D {
+	.name =3D "huawei_cdc_ncm",
+	.id_table =3D huawei_cdc_ncm_devs,
+	.probe =3D usbnet_probe,
+	.disconnect =3D usbnet_disconnect,
+	.suspend =3D huawei_cdc_ncm_suspend,
+	.resume =3D huawei_cdc_ncm_resume,
+	.reset_resume =3D huawei_cdc_ncm_resume,
+	.supports_autosuspend =3D 1,
+	.disable_hub_initiated_lpm =3D 1,
+};
+module_usb_driver(huawei_cdc_ncm_driver);
+MODULE_AUTHOR("Enrico Mioso <mrkiko.rs@gmail.com>");
+MODULE_DESCRIPTION("USB CDC NCM host driver with encapsulated protocol=
 support");
+MODULE_LICENSE("GPL");
--=20
1.7.10.4
