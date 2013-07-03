From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH RFC 3/3] huawei_cdc_ncm base skeleton
Date: Wed, 3 Jul 2013 12:16:19 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307031209310.19087@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso> <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
 <alpine.LNX.2.02.1307022210470.26010@eeeadesso> <alpine.LNX.2.02.1307022213380.26010@eeeadesso> <87ip0sw0sf.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:47275 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932436Ab3GCKQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 06:16:00 -0400
Received: by mail-we0-f176.google.com with SMTP id t56so5101977wes.35
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 03:15:58 -0700 (PDT)
In-Reply-To: <87ip0sw0sf.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First of all - thank you for all your comments and suggestions!




On Wed, 3 Jul 2013, Bj?rn Mork wrote:

==Date: Wed, 03 Jul 2013 09:38:40 +0200
==From: Bj?rn Mork <bjorn@mork.no>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: netdev@vger.kernel.org
==Subject: Re: [PATCH RFC 3/3] huawei_cdc_ncm base skeleton
==
==Enrico Mioso <mrkiko.rs@gmail.com> writes:
==
==> This is more an RFC than a patch.
==
==It looks pretty complete to me :)
==
==> + * This code is based on the original cdc_ncm implementation, that is:
==> + * Copyright (C) ST-Ericsson 2010-2012
==> + * Contact: Alexey Orishko <alexey.orishko@stericsson.com>
==> + * Original author: Hans Petter Selasky <hans.petter.selasky@stericsson.com>
==> + *
==> + * USB Host Driver for Network Control Model (NCM)
==> + * http://www.usb.org/developers/devclass_docs/NCM10.zip
==> + *
==> + * The NCM encoding, decoding and initialization logic
==> + * derives from FreeBSD 8.x. if_cdce.c and if_cdcereg.h
==> + *
==> + * This software is available to you under a choice of one of two
==> + * licenses. You may choose this file to be licensed under the terms
==> + * of the GNU General Public License (GPL) Version 2 or the 2-clause
==> + * BSD license listed below:
==
==This text does not match the MODULE_LICENSE you have used. You should
==probably take a few minutes to think about how you want your work to be
==licensed and use the appropriate combination of license comment and
==MODULE_LICENSE.
==
==You do in any case not need to copy all this from the cdc_ncm driver.
==You reuse code via the exported API, but the code in this driver is
==mostly your own.  A small note of cdc_ncm use is nice, but I don't think
==it's any more necessary than for other kernel code you use via #includes.
==
==

Thank you - right. I want my code to be GPL, no bsd license. Yes, I understand 
it're purely a personal choice, but wanted to be sincere.

==> +/* Bind our driver to needed interfaces. Heavily inspired by cdc_mbim.c one! */
==
==Many of your comments look mostly like notes for yourself.  Which they
==probably are, given that you sent this as a RFC :)
==
==You should go over all these comments and think about whether they are
==useful for others reading this code.  I don't think this one is, for
==example.
==
Yeah !! :) I'll remove them - they where here to help me understand the logic 
structure.

==> +static int huawei_cdc_ncm_bind(struct usbnet *usbnet_dev, struct usb_interface *intf) {
==> +
==> +	/* Some general use variables */
==> +	struct cdc_ncm_ctx *ctx;
==> +	struct usb_driver *subdriver = ERR_PTR(-ENODEV);
==> +	int ret = -ENODEV;
==> +	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
==> +	
==> +	/* Actually binds us to the device: use standard ncm function */
==> +	ret = cdc_ncm_bind_common(usbnet_dev, intf, 1); /* altsetting should be 1 */
==> +	
==> +	/* Did the ncm bind function fail? */
==> +	if (ret)
==> +		goto err;
==> +	
==> +	/* Let cdc data ctx pointer point to our state structure */
==> +	ctx = drvstate->ctx;
==> +	
==> +	if (usbnet_dev->status) 
==> +		subdriver = usb_cdc_wdm_register(ctx->control, &usbnet_dev->status->desc, 4096, huawei_cdc_ncm_wdm_manage_power); /* a smarter way to calculate that constant? */
==
==Yes, we were going to revisit that constant as soon as you discovered
==the protocol.  Now you found that it is AT commands, which doesn't
==really provide an absolute answer.  But AT commands is actually the
==normal usecase for cdc-wdm, so I believe using the defaults from that
==specification makes some sense.  As noted on the cdc-wdm driver:
==
==  CDC-WMC r1.1 requires wMaxCommand to be "at least 256 decimal (0x100)"
==
==Maybe 256 is enough here? Or are there Huawei specific AT commands with
==larger responses than that?  I don't know.  Choose some number and
==change the comment to explain the reasoning behind that choice.
==
==
I don't know - a word from Huawei would be very helpful in this context. 
Aniway, I would think there are commands with very large payloads and messages.
What you think if we set this to 512?

==> +	if (IS_ERR(subdriver)) {
==> +	 ret = PTR_ERR(subdriver);
==> +	 cdc_ncm_unbind(usbnet_dev, intf);
==> +   goto err;
==> +	}
==> +	
==> +	/* Prevent usbnet from using the status descriptor */
==> +	usbnet_dev->status = NULL;
==> +	
==> +	drvstate->subdriver = subdriver;
==> +	
==> +	/* FIXME: should we handle the vlan header in some way? */
==
==No, that is in cdc_mbim because it maps multiplexed MBIM IP sessions to
==ethernet VLAN interfaces.  The devices supported by this driver cannot
==support more than one IP session per USB function, so there is
==absolutely nothing you or the firmware can map a VLAN to.  Just drop the
==comment. 
==
Fine!
==> +	/* FIXME2: in my opinion we also could not do ARP, hoping somebody can help... */
==
==The firmware obviously does ARP as it works whether you disable it or
==not.  The usefulness can be discussed, but you cannot drop it without
==testing that it does in fact work.  The firmware most likely use either
==DHCP or ARP requests to figure out your MAC address, so the ARP requests
==might be required even if they look silly.
==
==
I will proceed with the test in some minutes!

==> +static const struct usb_device_id huawei_cdc_ncm_devs[] = {
==> +	/* The correct NCM handling will be implemented. For now, only my dongle
==> +		will be handled.
==> +		*/
==> +	{ USB_DEVICE_INTERFACE_NUMBER(0x12d1, 0x1506, 1), \
==> +		.driver_info = (unsigned long)&huawei_cdc_ncm_info,
==> +	},
==> +
==> +	{
==> +		/* Terminating entry */
==> +	},
==> +};
==
==
==As you note, that table needs to match on class codes.  Just move the
==Huawei vendor specific entries from cdc_ncm.
==
Here I'm a little bit confused - it seems there are device exporting QMI inside 
ncm, devices exporting AT and even devices exporting other unspecified 
protocol... or at least this was what I understood from google and various 
reports.
I will move all the entries - hoping not to cause regressions for cdc_ncm 
users!!

==
==
==Bj?rn
==
Thank you again for your help.
