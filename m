From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [RFC] huawei_cdc_ncm driver - status
Date: Tue, 2 Jul 2013 21:06:48 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307022105370.24276@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:53981 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453Ab3GBTGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 15:06:31 -0400
Received: by mail-we0-f170.google.com with SMTP id w57so4669799wes.29
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 12:06:30 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.02.1307021855270.19053@eeeadesso>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, I fixed my code - I forgot one of the most important things eve :) the 
registration.
Ok - now: the cdc-wdm character device is ok and working, the wwan interface 
has been created and for sure it will not work... :)
But the thing seems stable.



On Tue, 2 Jul 2013, Enrico Mioso wrote:

==Date: Tue, 2 Jul 2013 19:04:05 +0200 (CEST)
==From: Enrico Mioso <mrkiko.rs@gmail.com>
==To: Bj?rn Mork <bjorn@mork.no>
==Cc: netdev@vger.kernel.org
==Subject: [RFC] huawei_cdc_ncm driver - status
==
==Hi all guys!
==I'm writing this mail to inform you about the progresso f the "new" driver - 
==huawei_cdc_ncm.c, which should handle generally devices wich resembles the 
==cdc_ncm standard, but embed another protocol on it (AT or something).
==This driver has been developed starting from a Bjorn idea, and is based on the 
==cdc_mbim.c driver.
==
==Now - i need some help and corrections, review.
==the driver currently loads and doesn't cause panics, and that's already a very 
==good result for a first-time kernel programmer! :)
==Even the driver name may be inappropriate, any ideas and suggestions are 
==welcome!
==
==Here is the driver .c file: in addition:
==- I managed to export cdc_ncm {rx,tx}_fixup functions, modfying the needed .h 
==file and adding symbol exporting.
==- I removed from the cdc_ncm driver entries that made it bind t my dongle
==- I added product and vendor id for my dongle, but probably doing something 
==wrong...
==- updated the build infrastructure in accordance (Kconfig, Makefile ...) and 
==that works.
==
==
==And here it is - please help me if you can.
==
==/* copyrights and other things are importand but will be added later */
==#include <linux/module.h>
==#include <linux/netdevice.h>
==#include <linux/ethtool.h>
==#include <linux/if_vlan.h>
==#include <linux/ip.h>
==#include <linux/mii.h>
==#include <linux/usb.h>
==#include <linux/usb/cdc.h>
==#include <linux/usb/usbnet.h>
==#include <linux/usb/cdc-wdm.h>
==#include <linux/usb/cdc_ncm.h>
==
==/* Specific driver data */
==struct huawei_cdc_ncm_state {
==	struct cdc_ncm_ctx *ctx;
==	atomic_t pmcount;
==	struct usb_driver *subdriver;
==	struct usb_interface *control;
==	struct usb_interface *data;
==};
==
==static int huawei_cdc_ncm_manage_power(struct usbnet *usbnet_dev, int on)
=={
==	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
==	int rv = 0;
==
==	if ((on && atomic_add_return(1, &drvstate->pmcount) == 1) || (!on && atomic_dec_and_test(&drvstate->pmcount))) {
==		rv = usb_autopm_get_interface(usbnet_dev->intf);
==		if (rv < 0)
==			goto err;
==		usbnet_dev->intf->needs_remote_wakeup = on;
==		usb_autopm_put_interface(usbnet_dev->intf);
==	}
==err:
==	return rv;
==}
==
==static int huawei_cdc_ncm_wdm_manage_power(struct usb_interface *intf, int status)
=={
==	struct usbnet *usbnet_dev = usb_get_intfdata(intf);
==
==	/* can be called while disconnecting */
==	if (!usbnet_dev)
==		return 0;
==
==	return huawei_cdc_ncm_manage_power(usbnet_dev, status);
==}
==
==
==/* Bind our driver to needed interfaces. Heavily inspired by cdc_mbim.c one! */
==static int huawei_cdc_ncm_bind(struct usbnet *usbnet_dev, struct usb_interface *intf) {
==
==	/* Some general use variables */
==	struct cdc_ncm_ctx *ctx;
==	struct usb_driver *subdriver = ERR_PTR(-ENODEV);
==	int ret = -ENODEV;
==	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
==	
==	/* Actually binds us to the device: use standard ncm function */
==	ret = cdc_ncm_bind_common(usbnet_dev, intf, 1); /* altsetting should be 1 */
==	
==	/* Did the ncm bind function fail? */
==	if (ret)
==		goto err;
==	
==	/* Let cdc data ctx pointer point to our state structure */
==	ctx = drvstate->ctx;
==	
==	if (usbnet_dev->status) 
==		subdriver = usb_cdc_wdm_register(ctx->control, &usbnet_dev->status->desc, 4096, huawei_cdc_ncm_wdm_manage_power); /* a smarter way to calculate that constant? */
==	if (IS_ERR(subdriver)) {
==	 ret = PTR_ERR(subdriver);
==	 cdc_ncm_unbind(usbnet_dev, intf);
==   goto err;
==	}
==	
==	/* Prevent usbnet from using the status descriptor */
==	usbnet_dev->status = NULL;
==	
==	drvstate->subdriver = subdriver;
==	
==	/* FIXME: should we handle the vlan header in some way? */
==	/* FIXME2: in my opinion we also could not do ARP, hoping somebody can help... */
==err:
==	return ret; /* ret = -ENODEV if not changed in the meanwhile */
==}
==
==static void huawei_cdc_ncm_unbind(struct usbnet *usbnet_dev, struct usb_interface *intf) {
==	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
==	struct cdc_ncm_ctx *ctx = drvstate->ctx;
==	
==	/* Bye cdc-wdm! And see you soon! :) */
==	if (drvstate->subdriver && drvstate->subdriver->disconnect)
==		drvstate->subdriver->disconnect(ctx->control);
==	drvstate->subdriver = NULL;
==	
==	/* Unbind from both control and data interface */
==	cdc_ncm_unbind(usbnet_dev, intf);
==}
==
==/* Suspend function - the logic has been taken from cdc_mbim.c directly. */
==static int huawei_cdc_ncm_suspend(struct usb_interface *intf, pm_message_t message)
=={
==	int ret = 0;
==	struct usbnet *usbnet_dev = usb_get_intfdata(intf);
==	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
==	struct cdc_ncm_ctx *ctx = drvstate->ctx;
==
==	if (ctx == NULL) {
==		ret = -1;
==		goto error;
==	}
==
==	/*
==	 * Both usbnet_suspend() and subdriver->suspend() MUST return 0
==	 * in system sleep context, otherwise, the resume callback has
==	 * to recover device from previous suspend failure.
==	 */
==	ret = usbnet_suspend(intf, message);
==	if (ret < 0)
==		goto error;
==
==	if (intf == ctx->control && drvstate->subdriver && drvstate->subdriver->suspend)
==		ret = drvstate->subdriver->suspend(intf, message);
==	if (ret < 0)
==		usbnet_resume(intf);
==
==error:
==	return ret;
==}
==
==/* Resume function - logic took completely from huawei_cdc.c */
==static int huawei_cdc_ncm_resume(struct usb_interface *intf)
=={
==	int ret = 0;
==	struct usbnet *usbnet_dev = usb_get_intfdata(intf);
==	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
==	struct cdc_ncm_ctx *ctx = drvstate->ctx;
==	bool callsub = (intf == ctx->control && drvstate->subdriver && drvstate->subdriver->resume); /* should we call subdriver's resume? ? */
==
==	if (callsub)
==		ret = drvstate->subdriver->resume(intf);
==	if (ret < 0)
==		goto err;
==	ret = usbnet_resume(intf);
==	if (ret < 0 && callsub && drvstate->subdriver->suspend)
==		drvstate->subdriver->suspend(intf, PMSG_SUSPEND);
==err:
==	return ret;
==}
==
==
==/* General driver informations, exposed partly to modutils */
==static const struct driver_info huawei_cdc_info = {
==	.description = "Huawei-style CDC NCM",
==	.flags = FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN,
==	.bind = huawei_cdc_ncm_bind,
==	.unbind = huawei_cdc_ncm_unbind,
==	.manage_power = huawei_cdc_ncm_manage_power,
==	/* NCM RX and TX fixup functions work properly on these devices */
==	.rx_fixup = cdc_ncm_rx_fixup,
==	.tx_fixup = cdc_ncm_tx_fixup,
==};
==
==static const struct usb_device_id huawei_cdc_ncm_devs[] = {
==	/* The correct NCM handling will be implemented. For now, only my dongle
==		will be handled.
==		*/
==	{ USB_DEVICE(0x12d1, 0x1506) },
==	{
==		/* Terminating entry */
==	},
==};
==/* Expose table in module info */
==MODULE_DEVICE_TABLE(usb, huawei_cdc_ncm_devs);
==
==
==/* USB driver struct - used by USB stack */
==static struct usb_driver huawei_cdc_ncm_driver = {
==	.name = "huawei_cdc_ncm",
==	.id_table = huawei_cdc_ncm_devs,
==	.probe = usbnet_probe,
==	.disconnect = usbnet_disconnect,
==	.suspend = huawei_cdc_ncm_suspend,
==	.resume = huawei_cdc_ncm_resume,
==	.reset_resume = huawei_cdc_ncm_resume,
==	.supports_autosuspend = 1,
==	.disable_hub_initiated_lpm = 1,
==};
==module_usb_driver(huawei_cdc_ncm_driver);
==MODULE_AUTHOR("Enrico Mioso <mrkiko.rs@gmail.com>");
==MODULE_DESCRIPTION("USB CDC NCM host driver with encapsulated protocol support");
==MODULE_LICENSE("GPL");
==
