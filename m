From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [RFC PATCH] cdc_ncm: support moving the NDP part of the frame
 to the end of NCM package
Date: Wed, 17 Jun 2015 17:41:49 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1506171727200.3515@localhost.localdomain>
References: <1433760296-18543-1-git-send-email-mrkiko.rs@gmail.com> <1433760803.8770.16.camel@suse.com> <alpine.LNX.2.20.1506090933410.2290@localhost.localdomain> <1433846339.28343.9.camel@suse.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="8323328-317078025-1434555711=:3515"
Cc: Oliver Neukum <oneukum@suse.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37187 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932513AbbFQPlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:41:53 -0400
Received: by wifx6 with SMTP id x6so57937675wif.0
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 08:41:52 -0700 (PDT)
In-Reply-To: <1433846339.28343.9.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--8323328-317078025-1434555711=:3515
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT

Hello guys.
Sorry for the long delay / timing: but I arrived to the conclusion I had to shut up and inform myself and write somecode.
:D
Yes, you madeit!
So here are my findings and answers.


On Tue, 9 Jun 2015, Oliver Neukum wrote:

==Date: Tue, 9 Jun 2015 12:38:59
==From: Oliver Neukum <oneukum@suse.com>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: netdev@vger.kernel.org
==Subject: Re: [RFC PATCH] cdc_ncm: support moving the NDP part of the frame to
==    the end of NCM package
==
==On Tue, 2015-06-09 at 09:46 +0200, Enrico Mioso wrote:
==
==> ==Not another parameter please. If the alternate frames are processed as
==> ==well as the current frames, all is well and we can generally produces
==> ==such frames. If not, we want a black list.
==> 
==> I would agree on this point: and I was exploring different alternatives also, 
==> such as having this option settable when invoking cdc_ncm_bind_common from
==> huawei_cdc_ncm for example. Unfortunately, I don't feel confident we could do 
==> that.
==
==Using a module parameter is simply wrong. A system can be connected to
==multiple devices (in turn). As a minimum the feature must be per device.
==

Sure.

==> First of all: this driver supports more devices than Huawei ones, so I feel we 
==> have chances to break them modifying the frame structure.
==
==In theory we must never break or impede compliant devices for
==uncompliant devices. Yet I doubt we can break any device doing what
==Windows does.
==Does it have a standard NCM driver that works with Huawei devices?
==
==> Even more complicated is the fact that huawei NCM devices are not easily 
==> distinguishable one another from the driver perspective. Some heuristics may be 
==> put in place probably, but I don't have access to old enough NCM devices to 
==> know best.
==> The Huawei vendor driver put NDPs at end of frame - and does so for all devices 
==> in my opinion, but I can't be really sure about that.
==
==Doesn't it have a list of supported devices?

I don't have a Windows box readily at disposal to look into - partly due to 
accessiblity problems here. Still, Mobile Partner comes with it's own drivers 
for NCM devices.

==
==> Not now. Anyway I can change this as desired. Would something like a sysfs knob 
==> be preferable? User-space surely has a good chance to tell us what to do here.
==
==Not really. The answer will come from a list. The question is just
==whether easier updates are worth splitting up the fix.
==

The Linux huawei vendor driver defines various kinds of NDIS interfaces: but 
doesn't threat them differently when it comes to NCM framing: it always writes 
the NDP after the datagrams sequence, at least from what I understand reading 
the code.
Some device work with both the cdc_ncm-way and huawei_cdc-way, others don't.

==> ==> --- a/include/linux/usb/cdc_ncm.h
==> ==> +++ b/include/linux/usb/cdc_ncm.h
==> ==> @@ -93,6 +93,7 @@ struct cdc_ncm_ctx {
==> ==>  	const struct usb_cdc_mbim_desc *mbim_desc;
==> ==>  	const struct usb_cdc_mbim_extended_desc *mbim_extended_desc;
==> ==>  	const struct usb_cdc_ether_desc *ether_desc;
==> ==> +	struct usb_cdc_ncm_ndp16 *delayed_ndp;
==> ==
==> ==What prevents you from embedding this in the structure?
==> ==
==> ==	Regards
==> ==		Oliver
==> ==
==> ==
==> ==
==> Sorry - I think I didn't understand your ocmment here. Still, I am open to any 
==> suggestion.
==
==Why don't you put "struct usb_cdc_ncm_ndp16 delayed_ndp" as opposed to a
==pointer to it into struct cdc_ncm_ctx. You never need more than one at a
==time.
==
==	Regards
==		Oliver
==
==
==

I guess this will be clear reading the code I am posting here.

Based on the situation and constrains, I decided to re-write the NCM tx stack: 
and write a huawei specific one, in the huawei_cdc_ncm.c driver.
I can actually produce SKBs which are processed and seemigly received from the 
Linux cdc_ncm rx_fixup function, still not by the device I am testing this on, 
an E3131 3G dongle.
I don't know exactly why at the moment - still, I imagine two possibilities.
I might be aligning things wrong, or I might be doing some programming errors 
and corrupting the data somewhere. Any suggestion on how to verify this are 
welcome.

Si I post here the entire huawei_cdc_ncm.c file, since a patch would be 
probably not so smaller.
The only things I changed are still huawei_ncm_mgmt, huawei_ncm_tx_fixup and 
some defines got added.

I decided to split the NCM engine in two parts:
1 - The manager: which performs operations on frames based on what you ask.
2 - The packet processing path, which is in huawei_cdc_ncm_tx_fixup.

I expect all kinds of errors here: still hoping my work can show a serious 
intention in trying to do my best.
Obviously, printks sparkled all-over, huawei_show_ndp and probably many checks 
will go away. Some of them are redundant probably and make the code ugly.
I put them in place at least so I can avoid rebooting my virtual machine :D .

thank you,
Enrico

/* huawei_cdc_ncm.c - handles Huawei devices using the CDC NCM protocol as
 * transport layer.
 * Copyright (C) 2013	 Enrico Mioso <mrkiko.rs@gmail.com>
 *
 *
 * ABSTRACT:
 * This driver handles devices resembling the CDC NCM standard, but
 * encapsulating another protocol inside it. An example are some Huawei 3G
 * devices, exposing an embedded AT channel where you can set up the NCM
 * connection.
 * This code has been heavily inspired by the cdc_mbim.c driver, which is
 * Copyright (c) 2012  Smith Micro Software, Inc.
 * Copyright (c) 2012  Bjørn Mork <bjorn@mork.no>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 */

#include <linux/module.h>
#include <linux/netdevice.h>
#include <linux/ethtool.h>
#include <linux/if_vlan.h>
#include <linux/ip.h>
#include <linux/mii.h>
#include <linux/usb.h>
#include <linux/usb/cdc.h>
#include <linux/usb/usbnet.h>
#include <linux/usb/cdc-wdm.h>
#include <linux/usb/cdc_ncm.h>

/* NCM management operations: */

/* INIT_NCM_FRAME: prepare for a new frame.
 * NTH16 header is written to output SKB, and NDP data is reset.
 * Now, data may be added to this NCM package.
 */
#define NCM_INIT_FRAME		1

/* NCM_UPDATE_NDP: adds data to an NDP structure, hence updating it.
 * Some checks are performed to be sure data fits in, respecting device and
 * spec constrains.
 */
#define NCM_UPDATE_NDP		2

/* Write NDP: commits NDP to output SKB. */
#define NCM_COMMIT_NDP		3

/* NCM_FRAME_AVAILSPC: return to caller how much space is available in the frame.
 */
#define NCM_NDP_AVAILSPC	4

/* Driver data */
struct huawei_cdc_ncm_state {
	struct cdc_ncm_ctx *ctx;
	atomic_t pmcount;
	struct usb_driver *subdriver;
	struct usb_interface *control;
	struct usb_interface *data;

	/* Keeps track of where data starts and ends in SKBs. */
	int data_start;
	int data_len;

	/* Temporary NDP storage */
	struct usb_cdc_ncm_ndp16 *ndp;

	/* Temporary SKB for excess data. */
	struct sk_buff *skb_excess;
};

static int huawei_cdc_ncm_manage_power(struct usbnet *usbnet_dev, int on)
{
	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
	int rv;

	if ((on && atomic_add_return(1, &drvstate->pmcount) == 1) ||
			(!on && atomic_dec_and_test(&drvstate->pmcount))) {
		rv = usb_autopm_get_interface(usbnet_dev->intf);
		usbnet_dev->intf->needs_remote_wakeup = on;
		if (!rv)
			usb_autopm_put_interface(usbnet_dev->intf);
	}
	return 0;
}

static void huawei_show_ndp(struct usb_cdc_ncm_ndp16 *ndp16) {
	u16 ndplen;
	int i;
	int index;

	if (!ndp16) {
		printk("\nNo NDP to show.");
		return;
	}

	ndplen = le16_to_cpu(ndp16->wLength);
	index = (ndplen - sizeof(struct usb_cdc_ncm_ndp16)) / sizeof(struct usb_cdc_ncm_dpe16) - 1;

	printk("\nNDP INFO: \nNDP length: %d; Points to next NDP at %d.",ndp16->wLength,ndp16->wNextNdpIndex);
	printk("\nDPE data follows: ");

	for (i=0;i<=index;i++) {
		printk("\nIndex %d: ",i);
		printk("datagram index %d, wdatagramlength %d.",cpu_to_le16(ndp16->dpe16[i].wDatagramIndex),cpu_to_le16(ndp16->dpe16[i].wDatagramLength));
	}
	printk("\nEND NDP INFO");
	return;
}

int huawei_ncm_mgmt(struct huawei_cdc_ncm_state *drvstate, struct sk_buff *skb_out, int mode) {
	struct usb_cdc_ncm_nth16 *nth16 = (struct usb_cdc_ncm_nth16 *)skb_out->data;
	struct cdc_ncm_ctx *ctx = drvstate->ctx;
	struct usb_cdc_ncm_ndp16 *ndp16 = drvstate->ndp;
	int ret = -EINVAL;
	u16 ndplen, index;

	switch(mode) {
		case NCM_INIT_FRAME:

			/* Write a new NTH16 header */
			nth16 = (struct usb_cdc_ncm_nth16 *)memset(skb_put(skb_out, sizeof(struct usb_cdc_ncm_nth16)), 0, sizeof(struct usb_cdc_ncm_nth16));
			if (!nth16) {
				printk("\nNo memory for NTH.");
				ret = -EINVAL;
				goto error;
			}

			/* NTH16 signature and header length are known a-priori. */
			nth16->dwSignature = cpu_to_le32(USB_CDC_NCM_NTH16_SIGN);
			nth16->wHeaderLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_nth16));
			
			/* TX sequence numbering: not initialized. */
			nth16->wSequence = cpu_to_le16(ctx->tx_seq++);

			/* Prepare a new NDP to add data on subsequent calls. */
			ndp16 = memset(drvstate->ndp, 0, ctx->max_ndp_size);

			/* Initial NDP length */
			ndp16->wLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_ndp16) + sizeof(struct usb_cdc_ncm_dpe16));

			/* Frame signature: to be reworked. */
			ndp16->dwSignature = cpu_to_le32(USB_CDC_NCM_NDP16_NOCRC_SIGN);

			/* All went well. */
			ret = 0;
			break;

		case NCM_UPDATE_NDP:

			/* Do we have enough space for the data? */
			if (skb_out->len + ctx->max_ndp_size > ctx->tx_max) {
				printk("\nDevice constrains are not allowing this data.");
				return ret;
			}

			/* Calculate frame number withing this NDP */
			ndplen = le16_to_cpu(ndp16->wLength);
			index = (ndplen - sizeof(struct usb_cdc_ncm_ndp16)) / sizeof(struct usb_cdc_ncm_dpe16) - 1;

			if (index >= CDC_NCM_DPT_DATAGRAMS_MAX) {
				printk("\nDPT16 limit.");
				return ret;
			}

			/* tx_max shouldn't be exceeded after committing. */
			if (ndplen + sizeof(struct usb_cdc_ncm_dpe16) > ctx->tx_max) {
				printk("\nNo room for NDP.");
				return ret;
			}

			/* Adding a DPT entry. */
			ndp16->dpe16[index].wDatagramLength = cpu_to_le16(drvstate->data_len);
			ndp16->dpe16[index].wDatagramIndex = cpu_to_le16(drvstate->data_start);
			ndp16->wLength = cpu_to_le16(ndplen + sizeof(struct usb_cdc_ncm_dpe16));

			ret = 0;
			break;

		case NCM_COMMIT_NDP:

			/* Add the NULL DPE
			ndplen = le16_to_cpu(ndp16->wLength);
			index = (ndplen - sizeof(struct usb_cdc_ncm_ndp16)) / sizeof(struct usb_cdc_ncm_dpe16) - 1;
			ndp16->wLength = cpu_to_le16(ndplen + sizeof(struct usb_cdc_ncm_dpe16)); */

			/* NTH is here! */
			nth16->wNdpIndex = cpu_to_le16(skb_out->len);

			/* Write NDP */
			memcpy(skb_put(skb_out, ctx->max_ndp_size), ndp16, ctx->max_ndp_size);

			/* Finalize NTH16 header, setting it's block length */
			nth16->wBlockLength = cpu_to_le16(skb_out->len);

			huawei_show_ndp(ndp16);
			ret = 0;
			break;
		default:
			ret = -EINVAL;
			printk("\nInvalid operation requested: %d.",mode);
			break;
	}

error:
	return ret;
}

struct sk_buff *
huawei_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb_in, gfp_t flags) {
	struct huawei_cdc_ncm_state *drvstate = (void *)&dev->data;
	struct cdc_ncm_ctx *ctx = drvstate->ctx;
	struct sk_buff *skb_out;
	int status;

	/* Allocate a fresh OUT skb. */
	skb_out = alloc_skb(ctx->tx_max, GFP_NOIO);
	printk("\nSKB allocated.");

	/* Create base NCM structure */
	status = huawei_ncm_mgmt(drvstate, skb_out, NCM_INIT_FRAME);
	printk("\nStarting new NCM frame.");

	/* Do we have excess data? */
	if (drvstate->skb_excess) {
		drvstate->data_start = skb_out->len;

		/* Align beginning of next frame. */
		cdc_ncm_align_tail(skb_out,  ctx->tx_modulus, ctx->tx_remainder, ctx->tx_max);

		memcpy(skb_put(skb_out, drvstate->skb_excess->len), drvstate->skb_excess->data, drvstate->skb_excess->len);
		drvstate->data_len = skb_out->len-drvstate->data_start;

		printk("\nCopying excess data: from %d to %d, asking mgr to update NDP.",drvstate->data_start,skb_out->len);
		status = huawei_ncm_mgmt(drvstate, skb_out, NCM_UPDATE_NDP);
		if (status) {
			printk("\nExcess data can't fit in NDP. MTU problem? ");
			goto error_dealloc;
		}

		dev_kfree_skb_any(drvstate->skb_excess);
	}

	/* Timer context may be placed here. */

	if (skb_in->len + skb_out->len > ctx->tx_max) {
		printk("\nTotal data can not fit, still excess can be sent.");
		/* Still we might try to send out excess data we already added. */
		if (skb_out->len != 0) {
			goto send_out;
		}

		goto error_dealloc;
	}

	/* Align beginning of next frame. */
	cdc_ncm_align_tail(skb_out,  ctx->tx_modulus, ctx->tx_remainder, ctx->tx_max);

	drvstate->data_start = skb_out->len;
	memcpy(skb_put(skb_out, skb_in->len), skb_in->data, skb_in->len);
	drvstate->data_len = skb_out->len-drvstate->data_start;
	printk("\nIN data copied from %d to %d, asking MGR to update NDP.",drvstate->data_start,skb_out->len);

	/* Add data to NDP */
	status = huawei_ncm_mgmt(drvstate, skb_out, NCM_UPDATE_NDP);
	if (status) {
		printk("\nNew data can not fit in NDP.");

		drvstate->skb_excess = alloc_skb(skb_in->len, GFP_NOIO);
		if (!drvstate->skb_excess) {
			printk("\nCan not allocate excess data buffer.");
			goto error_dealloc;
		}
		memcpy(skb_put(drvstate->skb_excess, skb_in->len), skb_in->data, skb_in->len);
		goto send_out;
	}

send_out:
	/* Write final NDP frame */
	printk("\nCommitting NDP.");

	/* Align new NDP */
	cdc_ncm_align_tail(skb_out, ctx->tx_ndp_modulus, 0, ctx->tx_max);

	status = huawei_ncm_mgmt(drvstate, skb_out, NCM_COMMIT_NDP);
	if (status) {
		printk("\nError writing final NDP.");
		goto error_dealloc;
	}

	if (skb_in) {
		dev_kfree_skb_any(skb_in);
		printk("\nIN skb deallocated.");
	}

	//cdc_ncm_rx_test(dev, skb_out);
	return skb_out;
error_dealloc:
	if (drvstate->skb_excess)
		dev_kfree_skb_any(drvstate->skb_excess);
//not_enough_data:
	if (skb_in)
		dev_kfree_skb_any(skb_in);
	return NULL;
}

static int huawei_cdc_ncm_wdm_manage_power(struct usb_interface *intf,
					   int status)
{
	struct usbnet *usbnet_dev = usb_get_intfdata(intf);

	/* can be called while disconnecting */
	if (!usbnet_dev)
		return 0;

	return huawei_cdc_ncm_manage_power(usbnet_dev, status);
}


static int huawei_cdc_ncm_bind(struct usbnet *usbnet_dev,
			       struct usb_interface *intf)
{
	struct cdc_ncm_ctx *ctx;
	struct usb_driver *subdriver = ERR_PTR(-ENODEV);
	int ret = -ENODEV;
	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;

	/* altsetting should always be 1 for NCM devices - so we hard-coded
	 * it here
	 */
	ret = cdc_ncm_bind_common(usbnet_dev, intf, 1);
	if (ret)
		goto err;

	ctx = drvstate->ctx;

	if (usbnet_dev->status)
		/* The wMaxCommand buffer must be big enough to hold
		 * any message from the modem. Experience has shown
		 * that some replies are more than 256 bytes long
		 */
		subdriver = usb_cdc_wdm_register(ctx->control,
						 &usbnet_dev->status->desc,
						 1024, /* wMaxCommand */
						 huawei_cdc_ncm_wdm_manage_power);
	if (IS_ERR(subdriver)) {
		ret = PTR_ERR(subdriver);
		cdc_ncm_unbind(usbnet_dev, intf);
		goto err;
	}

	/* Prevent usbnet from using the status descriptor */
	usbnet_dev->status = NULL;

	drvstate->subdriver = subdriver;

	/* Allocate temporary NDP storage for NDP building */
	drvstate->ndp = kzalloc(ctx->max_ndp_size, GFP_KERNEL);

err:
	return ret;
}

static void huawei_cdc_ncm_unbind(struct usbnet *usbnet_dev,
				  struct usb_interface *intf)
{
	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
	struct cdc_ncm_ctx *ctx = drvstate->ctx;

	if (drvstate->subdriver && drvstate->subdriver->disconnect)
		drvstate->subdriver->disconnect(ctx->control);
	drvstate->subdriver = NULL;

	cdc_ncm_unbind(usbnet_dev, intf);

	/* Deallocate temporary NDP storage */
	kfree(drvstate->ndp);
}

static int huawei_cdc_ncm_suspend(struct usb_interface *intf,
				  pm_message_t message)
{
	int ret = 0;
	struct usbnet *usbnet_dev = usb_get_intfdata(intf);
	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
	struct cdc_ncm_ctx *ctx = drvstate->ctx;

	if (ctx == NULL) {
		ret = -ENODEV;
		goto error;
	}

	ret = usbnet_suspend(intf, message);
	if (ret < 0)
		goto error;

	if (intf == ctx->control &&
		drvstate->subdriver &&
		drvstate->subdriver->suspend)
		ret = drvstate->subdriver->suspend(intf, message);
	if (ret < 0)
		usbnet_resume(intf);

error:
	return ret;
}

static int huawei_cdc_ncm_resume(struct usb_interface *intf)
{
	int ret = 0;
	struct usbnet *usbnet_dev = usb_get_intfdata(intf);
	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
	bool callsub;
	struct cdc_ncm_ctx *ctx = drvstate->ctx;

	/* should we call subdriver's resume function? */
	callsub =
		(intf == ctx->control &&
		drvstate->subdriver &&
		drvstate->subdriver->resume);

	if (callsub)
		ret = drvstate->subdriver->resume(intf);
	if (ret < 0)
		goto err;
	ret = usbnet_resume(intf);
	if (ret < 0 && callsub)
		drvstate->subdriver->suspend(intf, PMSG_SUSPEND);
err:
	return ret;
}

static const struct driver_info huawei_cdc_ncm_info = {
	.description = "Huawei CDC NCM device",
	.flags = FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN,
	.bind = huawei_cdc_ncm_bind,
	.unbind = huawei_cdc_ncm_unbind,
	.manage_power = huawei_cdc_ncm_manage_power,
	.rx_fixup = cdc_ncm_rx_fixup,
	.tx_fixup = huawei_ncm_tx_fixup,
};

static const struct usb_device_id huawei_cdc_ncm_devs[] = {
	/* Huawei NCM devices disguised as vendor specific */
	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x16),
	  .driver_info = (unsigned long)&huawei_cdc_ncm_info,
	},
	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x46),
	  .driver_info = (unsigned long)&huawei_cdc_ncm_info,
	},
	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x76),
	  .driver_info = (unsigned long)&huawei_cdc_ncm_info,
	},
	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x03, 0x16),
	  .driver_info = (unsigned long)&huawei_cdc_ncm_info,
	},

	/* Terminating entry */
	{
	},
};
MODULE_DEVICE_TABLE(usb, huawei_cdc_ncm_devs);

static struct usb_driver huawei_cdc_ncm_driver = {
	.name = "huawei_cdc_ncm",
	.id_table = huawei_cdc_ncm_devs,
	.probe = usbnet_probe,
	.disconnect = usbnet_disconnect,
	.suspend = huawei_cdc_ncm_suspend,
	.resume = huawei_cdc_ncm_resume,
	.reset_resume = huawei_cdc_ncm_resume,
	.supports_autosuspend = 1,
	.disable_hub_initiated_lpm = 1,
};
module_usb_driver(huawei_cdc_ncm_driver);
MODULE_AUTHOR("Enrico Mioso <mrkiko.rs@gmail.com>");
MODULE_DESCRIPTION("USB CDC NCM host driver with encapsulated protocol support");
MODULE_LICENSE("GPL");
--8323328-317078025-1434555711=:3515--
