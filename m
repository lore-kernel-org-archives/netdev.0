From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH RFC 3/3] huawei_cdc_ncm base skeleton
Date: Wed, 03 Jul 2013 09:38:40 +0200
Message-ID: <87ip0sw0sf.fsf@nemi.mork.no>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso>
	<87wqp9xja5.fsf@nemi.mork.no>
	<alpine.LNX.2.02.1307021855270.19053@eeeadesso>
	<alpine.LNX.2.02.1307022202570.26010@eeeadesso>
	<alpine.LNX.2.02.1307022207060.26010@eeeadesso>
	<alpine.LNX.2.02.1307022210470.26010@eeeadesso>
	<alpine.LNX.2.02.1307022213380.26010@eeeadesso>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51676 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754228Ab3GCHjA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 03:39:00 -0400
In-Reply-To: <alpine.LNX.2.02.1307022213380.26010@eeeadesso> (Enrico Mioso's
	message of "Tue, 2 Jul 2013 22:15:49 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> This is more an RFC than a patch.

It looks pretty complete to me :)

> + * This code is based on the original cdc_ncm implementation, that i=
s:
> + * Copyright (C) ST-Ericsson 2010-2012
> + * Contact: Alexey Orishko <alexey.orishko@stericsson.com>
> + * Original author: Hans Petter Selasky <hans.petter.selasky@sterics=
son.com>
> + *
> + * USB Host Driver for Network Control Model (NCM)
> + * http://www.usb.org/developers/devclass_docs/NCM10.zip
> + *
> + * The NCM encoding, decoding and initialization logic
> + * derives from FreeBSD 8.x. if_cdce.c and if_cdcereg.h
> + *
> + * This software is available to you under a choice of one of two
> + * licenses. You may choose this file to be licensed under the terms
> + * of the GNU General Public License (GPL) Version 2 or the 2-clause
> + * BSD license listed below:

This text does not match the MODULE_LICENSE you have used. You should
probably take a few minutes to think about how you want your work to be
licensed and use the appropriate combination of license comment and
MODULE_LICENSE.

You do in any case not need to copy all this from the cdc_ncm driver.
You reuse code via the exported API, but the code in this driver is
mostly your own.  A small note of cdc_ncm use is nice, but I don't thin=
k
it's any more necessary than for other kernel code you use via #include=
s.


> +/* Bind our driver to needed interfaces. Heavily inspired by cdc_mbi=
m.c one! */

Many of your comments look mostly like notes for yourself.  Which they
probably are, given that you sent this as a RFC :)

You should go over all these comments and think about whether they are
useful for others reading this code.  I don't think this one is, for
example.

> +static int huawei_cdc_ncm_bind(struct usbnet *usbnet_dev, struct usb=
_interface *intf) {
> +
> +	/* Some general use variables */
> +	struct cdc_ncm_ctx *ctx;
> +	struct usb_driver *subdriver =3D ERR_PTR(-ENODEV);
> +	int ret =3D -ENODEV;
> +	struct huawei_cdc_ncm_state *drvstate =3D (void *)&usbnet_dev->data=
;
> +=09
> +	/* Actually binds us to the device: use standard ncm function */
> +	ret =3D cdc_ncm_bind_common(usbnet_dev, intf, 1); /* altsetting sho=
uld be 1 */
> +=09
> +	/* Did the ncm bind function fail? */
> +	if (ret)
> +		goto err;
> +=09
> +	/* Let cdc data ctx pointer point to our state structure */
> +	ctx =3D drvstate->ctx;
> +=09
> +	if (usbnet_dev->status)=20
> +		subdriver =3D usb_cdc_wdm_register(ctx->control, &usbnet_dev->stat=
us->desc, 4096, huawei_cdc_ncm_wdm_manage_power); /* a smarter way to c=
alculate that constant? */

Yes, we were going to revisit that constant as soon as you discovered
the protocol.  Now you found that it is AT commands, which doesn't
really provide an absolute answer.  But AT commands is actually the
normal usecase for cdc-wdm, so I believe using the defaults from that
specification makes some sense.  As noted on the cdc-wdm driver:

  CDC-WMC r1.1 requires wMaxCommand to be "at least 256 decimal (0x100)=
"

Maybe 256 is enough here? Or are there Huawei specific AT commands with
larger responses than that?  I don't know.  Choose some number and
change the comment to explain the reasoning behind that choice.


> +	if (IS_ERR(subdriver)) {
> +	 ret =3D PTR_ERR(subdriver);
> +	 cdc_ncm_unbind(usbnet_dev, intf);
> +   goto err;
> +	}
> +=09
> +	/* Prevent usbnet from using the status descriptor */
> +	usbnet_dev->status =3D NULL;
> +=09
> +	drvstate->subdriver =3D subdriver;
> +=09
> +	/* FIXME: should we handle the vlan header in some way? */

No, that is in cdc_mbim because it maps multiplexed MBIM IP sessions to
ethernet VLAN interfaces.  The devices supported by this driver cannot
support more than one IP session per USB function, so there is
absolutely nothing you or the firmware can map a VLAN to.  Just drop th=
e
comment.=20

> +	/* FIXME2: in my opinion we also could not do ARP, hoping somebody =
can help... */

The firmware obviously does ARP as it works whether you disable it or
not.  The usefulness can be discussed, but you cannot drop it without
testing that it does in fact work.  The firmware most likely use either
DHCP or ARP requests to figure out your MAC address, so the ARP request=
s
might be required even if they look silly.


> +static const struct usb_device_id huawei_cdc_ncm_devs[] =3D {
> +	/* The correct NCM handling will be implemented. For now, only my d=
ongle
> +		will be handled.
> +		*/
> +	{ USB_DEVICE_INTERFACE_NUMBER(0x12d1, 0x1506, 1), \
> +		.driver_info =3D (unsigned long)&huawei_cdc_ncm_info,
> +	},
> +
> +	{
> +		/* Terminating entry */
> +	},
> +};


As you note, that table needs to match on class codes.  Just move the
Huawei vendor specific entries from cdc_ncm.



Bj=C3=B8rn
