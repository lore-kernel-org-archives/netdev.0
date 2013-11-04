From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next v6 2/3] net: huawei_cdc_ncm: Introduce the huawei_cdc_ncm driver
Date: Mon,  4 Nov 2013 09:50:48 +0100
Message-ID: <1383555049-24834-3-git-send-email-bjorn@mork.no>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48275 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752785Ab3KDIvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 03:51:08 -0500
In-Reply-To: <1383555049-24834-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Enrico Mioso <mrkiko.rs@gmail.com>

This driver supports devices using the NCM protocol as an encapsulation=
 layer
for other protocols, like the E3131 Huawei 3G modem. This drivers appro=
ach was
heavily inspired by the qmi_wwan/cdc_mbim approach & code model.

Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/Kconfig          |   15 +++
 drivers/net/usb/Makefile         |    1 +
 drivers/net/usb/huawei_cdc_ncm.c |  230 ++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 246 insertions(+)
 create mode 100644 drivers/net/usb/huawei_cdc_ncm.c

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 40db312..85e4a01 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -242,6 +242,21 @@ config USB_NET_CDC_NCM
 	    * ST-Ericsson M343 HSPA Mobile Broadband Modem (reference design)
 	    * Ericsson F5521gw Mobile Broadband Module
=20
+config USB_NET_HUAWEI_CDC_NCM
+	tristate "Huawei NCM embedded AT channel support"
+	depends on USB_USBNET
+	select USB_WDM
+	select USB_NET_CDC_NCM
+	help
+		This driver supports huawei-style NCM devices, that use NCM as a
+		transport for other protocols, usually an embedded AT channel.
+		Good examples are:
+		* Huawei E3131
+		* Huawei E3251
+
+		To compile this driver as a module, choose M here: the module will b=
e
+		called huawei_cdc_ncm.ko.
+
 config USB_NET_CDC_MBIM
 	tristate "CDC MBIM support"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 8b342cf..b17b5e8 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -32,6 +32,7 @@ obj-$(CONFIG_USB_IPHETH)	+=3D ipheth.o
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
index 0000000..312178d
--- /dev/null
+++ b/drivers/net/usb/huawei_cdc_ncm.c
@@ -0,0 +1,230 @@
+/* huawei_cdc_ncm.c - handles Huawei devices using the CDC NCM protoco=
l as
+ * transport layer.
+ * Copyright (C) 2013	 Enrico Mioso <mrkiko.rs@gmail.com>
+ *
+ *
+ * ABSTRACT:
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
+	int rv;
+
+	if ((on && atomic_add_return(1, &drvstate->pmcount) =3D=3D 1) ||
+			(!on && atomic_dec_and_test(&drvstate->pmcount))) {
+		rv =3D usb_autopm_get_interface(usbnet_dev->intf);
+		usbnet_dev->intf->needs_remote_wakeup =3D on;
+		if (!rv)
+			usb_autopm_put_interface(usbnet_dev->intf);
+	}
+	return 0;
+}
+
+static int huawei_cdc_ncm_wdm_manage_power(struct usb_interface *intf,
+					   int status)
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
+static int huawei_cdc_ncm_bind(struct usbnet *usbnet_dev,
+			       struct usb_interface *intf)
+{
+	struct cdc_ncm_ctx *ctx;
+	struct usb_driver *subdriver =3D ERR_PTR(-ENODEV);
+	int ret =3D -ENODEV;
+	struct huawei_cdc_ncm_state *drvstate =3D (void *)&usbnet_dev->data;
+
+	/* altsetting should always be 1 for NCM devices - so we hard-coded
+	 * it here
+	 */
+	ret =3D cdc_ncm_bind_common(usbnet_dev, intf, 1);
+	if (ret)
+		goto err;
+
+	ctx =3D drvstate->ctx;
+
+	if (usbnet_dev->status)
+		/* CDC-WMC r1.1 requires wMaxCommand to be "at least 256
+		 * decimal (0x100)"
+		 */
+		subdriver =3D usb_cdc_wdm_register(ctx->control,
+						 &usbnet_dev->status->desc,
+						 256, /* wMaxCommand */
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
+static void huawei_cdc_ncm_unbind(struct usbnet *usbnet_dev,
+				  struct usb_interface *intf)
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
+static int huawei_cdc_ncm_suspend(struct usb_interface *intf,
+				  pm_message_t message)
+{
+	int ret =3D 0;
+	struct usbnet *usbnet_dev =3D usb_get_intfdata(intf);
+	struct huawei_cdc_ncm_state *drvstate =3D (void *)&usbnet_dev->data;
+	struct cdc_ncm_ctx *ctx =3D drvstate->ctx;
+
+	if (ctx =3D=3D NULL) {
+		ret =3D -ENODEV;
+		goto error;
+	}
+
+	ret =3D usbnet_suspend(intf, message);
+	if (ret < 0)
+		goto error;
+
+	if (intf =3D=3D ctx->control &&
+		drvstate->subdriver &&
+		drvstate->subdriver->suspend)
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
+	bool callsub;
+	struct cdc_ncm_ctx *ctx =3D drvstate->ctx;
+
+	/* should we call subdriver's resume function? */
+	callsub =3D
+		(intf =3D=3D ctx->control &&
+		drvstate->subdriver &&
+		drvstate->subdriver->resume);
+
+	if (callsub)
+		ret =3D drvstate->subdriver->resume(intf);
+	if (ret < 0)
+		goto err;
+	ret =3D usbnet_resume(intf);
+	if (ret < 0 && callsub)
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
