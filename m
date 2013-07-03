From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH V2 3/3] usbnet: introduce huawei_cdc_ncm driver
Date: Wed, 3 Jul 2013 15:05:25 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307031500360.24525@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso> <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
 <alpine.LNX.2.02.1307022210470.26010@eeeadesso> <alpine.LNX.2.02.1307022213380.26010@eeeadesso> <alpine.LNX.2.02.1307030836270.12831@eeeadesso> <alpine.LNX.2.02.1307030908090.13789@eeeadesso> <871u7gvz2z.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:43603 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754019Ab3GCNFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 09:05:06 -0400
Received: by mail-wg0-f47.google.com with SMTP id l18so98885wgh.2
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 06:05:04 -0700 (PDT)
In-Reply-To: <871u7gvz2z.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new driver, handles devices that mimic the NCM standard, but using NCM as 
a transport layer to encapsulate other protocol (i.e. AT protocol).


Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
v2:
  - added check_connect handler
  - cleaned up some comments
  - proper device binding entries added

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 287cc62..33cb175 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -246,6 +246,18 @@ config USB_NET_CDC_NCM
 	    * ST-Ericsson M343 HSPA Mobile Broadband Modem (reference design)
 	    * Ericsson F5521gw Mobile Broadband Module
 
+config USB_NET_HUAWEI_CDC_NCM
+	tristate "Huawei-style CDC NCM support"
+	depends on USB_USBNET
+	default y
+	select USB_WDM
+	select USB_NET_CDC_NCM
+	help
+		This driver aims to support huawei-style NCM devices, that use ncm as a 
+		transport for other protols.
+		To compile this driver as a module, choose M here: the module will be 
+		called huawei_cdc_ncm.
+
 config USB_NET_CDC_MBIM
 	tristate "CDC MBIM support"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 9ab5c9d..12a0279 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -31,6 +31,7 @@ obj-$(CONFIG_USB_IPHETH)	+= ipheth.o
 obj-$(CONFIG_USB_SIERRA_NET)	+= sierra_net.o
 obj-$(CONFIG_USB_NET_CX82310_ETH)	+= cx82310_eth.o
 obj-$(CONFIG_USB_NET_CDC_NCM)	+= cdc_ncm.o
+obj-$(CONFIG_USB_NET_HUAWEI_CDC_NCM)	+= huawei_cdc_ncm.o
 obj-$(CONFIG_USB_VL600)		+= lg-vl600.o
 obj-$(CONFIG_USB_NET_QMI_WWAN)	+= qmi_wwan.o
 obj-$(CONFIG_USB_NET_CDC_MBIM)	+= cdc_mbim.o
diff --git a/drivers/net/usb/huawei_cdc_ncm.c b/drivers/net/usb/huawei_cdc_ncm.c
index e69de29..46591e7 100644
--- a/drivers/net/usb/huawei_cdc_ncm.c
+++ b/drivers/net/usb/huawei_cdc_ncm.c
@@ -0,0 +1,206 @@
+/*
+ * huawei_cdc_ncm.c - handles hawei-style NCM devices.
+ * Copyright (C) 1012	 Enrico Mioso <mrkiko.rs@gmail.com>
+ * This driver handles devices resembling the CDC NCM standard, but 
+ * encapsulating another protocol inside it. An example are some Huawei 3G devices.
+ * This code has been heavily inspired by the cdc_mbim.c driver, which is
+ * Copyright (c) 2012  Smith Micro Software, Inc. 
+ * Copyright (c) 2012  Bj??rn Mork <bjorn@mork.no>
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
+/* Specific driver data */
+struct huawei_cdc_ncm_state {
+	struct cdc_ncm_ctx *ctx;
+	atomic_t pmcount;
+	struct usb_driver *subdriver;
+	struct usb_interface *control;
+	struct usb_interface *data;
+};
+
+static int huawei_cdc_ncm_manage_power(struct usbnet *usbnet_dev, int on)
+{
+	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
+	int rv = 0;
+
+	if ((on && atomic_add_return(1, &drvstate->pmcount) == 1) || (!on && atomic_dec_and_test(&drvstate->pmcount))) {
+		rv = usb_autopm_get_interface(usbnet_dev->intf);
+		if (rv < 0)
+			goto err;
+		usbnet_dev->intf->needs_remote_wakeup = on;
+		usb_autopm_put_interface(usbnet_dev->intf);
+	}
+err:
+	return rv;
+}
+
+static int huawei_cdc_ncm_wdm_manage_power(struct usb_interface *intf, int status)
+{
+	struct usbnet *usbnet_dev = usb_get_intfdata(intf);
+
+	/* can be called while disconnecting */
+	if (!usbnet_dev)
+		return 0;
+
+	return huawei_cdc_ncm_manage_power(usbnet_dev, status);
+}
+
+
+static int huawei_cdc_ncm_bind(struct usbnet *usbnet_dev, struct usb_interface *intf) {
+	struct cdc_ncm_ctx *ctx;
+	struct usb_driver *subdriver = ERR_PTR(-ENODEV);
+	int ret = -ENODEV;
+	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
+	
+	/* Actually binds us to the device: use standard ncm function */
+	ret = cdc_ncm_bind_common(usbnet_dev, intf, 1); /* altsetting should be 1 */
+	if (ret)
+		goto err;
+	
+	ctx = drvstate->ctx;
+	
+	if (usbnet_dev->status) 
+	/* The wdm buffer size is choosen to match the one specified in AT R1.1 Standard. */	
+	subdriver = usb_cdc_wdm_register(ctx->control, &usbnet_dev->status->desc, 256, huawei_cdc_ncm_wdm_manage_power); /* CDC-WMC r1.1 requires wMaxCommand to be "at least 256" */
+	if (IS_ERR(subdriver)) {
+	 ret = PTR_ERR(subdriver);
+	 cdc_ncm_unbind(usbnet_dev, intf);
+   goto err;
+	}
+	
+	/* Prevent usbnet from using the status descriptor */
+	usbnet_dev->status = NULL;
+	
+	drvstate->subdriver = subdriver;
+	
+err:
+	return ret;
+}
+
+static void huawei_cdc_ncm_unbind(struct usbnet *usbnet_dev, struct usb_interface *intf) {
+	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
+	struct cdc_ncm_ctx *ctx = drvstate->ctx;
+	
+	if (drvstate->subdriver && drvstate->subdriver->disconnect)
+		drvstate->subdriver->disconnect(ctx->control);
+	drvstate->subdriver = NULL;
+
+	cdc_ncm_unbind(usbnet_dev, intf);
+}
+
+static int huawei_cdc_ncm_suspend(struct usb_interface *intf, pm_message_t message)
+{
+	int ret = 0;
+	struct usbnet *usbnet_dev = usb_get_intfdata(intf);
+	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
+	struct cdc_ncm_ctx *ctx = drvstate->ctx;
+
+	if (ctx == NULL) {
+		ret = -1;
+		goto error;
+	}
+
+	ret = usbnet_suspend(intf, message);
+	if (ret < 0)
+		goto error;
+
+	if (intf == ctx->control && drvstate->subdriver && drvstate->subdriver->suspend)
+		ret = drvstate->subdriver->suspend(intf, message);
+	if (ret < 0)
+		usbnet_resume(intf);
+
+error:
+	return ret;
+}
+
+static int huawei_cdc_ncm_resume(struct usb_interface *intf)
+{
+	int ret = 0;
+	struct usbnet *usbnet_dev = usb_get_intfdata(intf);
+	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
+	struct cdc_ncm_ctx *ctx = drvstate->ctx;
+	bool callsub = (intf == ctx->control && drvstate->subdriver && drvstate->subdriver->resume); /* should we call subdriver's resume? ? */
+
+	if (callsub)
+		ret = drvstate->subdriver->resume(intf);
+	if (ret < 0)
+		goto err;
+	ret = usbnet_resume(intf);
+	if (ret < 0 && callsub && drvstate->subdriver->suspend)
+		drvstate->subdriver->suspend(intf, PMSG_SUSPEND);
+err:
+	return ret;
+}
+
+static int huawei_cdc_ncm_check_connect(struct usbnet *usbnet_dev) {
+	struct cdc_ncm_ctx *ctx;
+	
+	ctx = (struct cdc_ncm_ctx *)usbnet_dev->data[0];
+	
+	if (ctx == NULL)
+		return 1; /* disconnected */
+	
+	return !ctx->connected;
+}
+
+static const struct driver_info huawei_cdc_ncm_info = {
+	.description = "Huawei CDC NCM",
+	.flags = FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN,
+	.bind = huawei_cdc_ncm_bind,
+	.unbind = huawei_cdc_ncm_unbind,
+	.check_connect = huawei_cdc_ncm_check_connect,
+	.manage_power = huawei_cdc_ncm_manage_power,
+	.rx_fixup = cdc_ncm_rx_fixup,
+	.tx_fixup = cdc_ncm_tx_fixup,
+};
+
+static const struct usb_device_id huawei_cdc_ncm_devs[] = {
+	/* Huawei NCM devices disguised as vendor specific */
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x16),
+	  .driver_info = (unsigned long)&huawei_cdc_ncm_info,
+	},
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x46),
+	  .driver_info = (unsigned long)&huawei_cdc_ncm_info,
+	},
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x76),
+	  .driver_info = (unsigned long)&huawei_cdc_ncm_info,
+	},
+
+	/* Terminating entry */
+	{
+	},
+};
+MODULE_DEVICE_TABLE(usb, huawei_cdc_ncm_devs);
+
+
+/* USB driver struct - used by USB stack */
+static struct usb_driver huawei_cdc_ncm_driver = {
+	.name = "huawei_cdc_ncm",
+	.id_table = huawei_cdc_ncm_devs,
+	.probe = usbnet_probe,
+	.disconnect = usbnet_disconnect,
+	.suspend = huawei_cdc_ncm_suspend,
+	.resume = huawei_cdc_ncm_resume,
+	.reset_resume = huawei_cdc_ncm_resume,
+	.supports_autosuspend = 1,
+	.disable_hub_initiated_lpm = 1,
+};
+module_usb_driver(huawei_cdc_ncm_driver);
+MODULE_AUTHOR("Enrico Mioso <mrkiko.rs@gmail.com>");
+MODULE_DESCRIPTION("USB CDC NCM host driver with encapsulated protocol support");
+MODULE_LICENSE("GPL");

  
