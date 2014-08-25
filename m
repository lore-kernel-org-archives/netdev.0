From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] cdc-ether: clean packet filter upon probe
Date: Mon, 25 Aug 2014 10:39:53 +0200
Message-ID: <87a96tc692.fsf@nemi.mork.no>
References: <1406537796-20156-1-git-send-email-oneukum@suse.de>
	<87a977z5pn.fsf@nemi.mork.no>
	<1408083121.17565.4.camel@linux-fkkt.site>
	<87d2c2xm2k.fsf@nemi.mork.no>
	<1408954063.10300.1.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:45626 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753344AbaHYLBg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 07:01:36 -0400
In-Reply-To: <1408954063.10300.1.camel@linux-fkkt.site> (Oliver Neukum's
	message of "Mon, 25 Aug 2014 10:07:43 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.de> writes:
> On Fri, 2014-08-15 at 09:13 +0200, Bj=C3=B8rn Mork wrote:
>> Oliver Neukum <oneukum@suse.de> writes:
>>=20
>> > On Thu, 2014-08-14 at 13:11 +0200, Bj=C3=B8rn Mork wrote:
>
>> > Support for this request is mandatory.
>>=20
>> Yes, there is no problem for standard conforming ECM devices.  I ful=
ly
>> agree there.=20
>>=20
>> But standard conformance is unfortunately not something we can expec=
t.
>> My question was regarding the non-conforming devices, like the ones
>> supported by th zaurus and rndis_host drivers.  These drivers are ma=
de
>
> You have a point. Yet another flag? Do you see an alternative?

Note that I don't know whether this is a real problem or not. I don't
believe I have any zaurus or rndis_host devices.

But how about just splitting the .bind functions for true ECM devices
and the others, letting the zaurus and rndis_host driver continue to us=
e
usbnet_cdc_bind with no filter setting?  Maybe define a new unexported
=2Ebind in cdc_ether for this purpose, moving the ECM specific
initialization there?

Maybe something along this (instead of the change to
usbnet_generic_cdc_bind)?:

static int usbnet_cdc_ecm_bind(struct usbnet *dev, struct usb_interface=
 *intf)
{
        int rv =3D usbnet_cdc_bind(dev, intf);

	if (rv < 0)
		return rv;

	/* Some devices don't initialise properly. In particular
	 * the packet filter is not reset. There are devices that
	 * don't do reset all the way. So the packet filter should
	 * be set to a sane initial value.
	 */
	rv =3D usb_control_msg(dev->udev,
			     usb_sndctrlpipe(dev->udev, 0),
			     USB_CDC_SET_ETHERNET_PACKET_FILTER,
			     USB_TYPE_CLASS | USB_RECIP_INTERFACE,
			     USB_CDC_PACKET_TYPE_ALL_MULTICAST | USB_CDC_PACKET_TYPE_DIRECTE=
D | USB_CDC_PACKET_TYPE_BROADCAST,
			     intf->cur_altsetting->desc.bInterfaceNumber,
			     NULL,
			     0,
			     USB_CTRL_SET_TIMEOUT);
  	if (rv < 0)
		return rv;
        return 0;
}

=2E.

static const struct driver_info	cdc_info =3D {
	.description =3D	"CDC Ethernet Device",
	.flags =3D	FLAG_ETHER | FLAG_POINTTOPOINT,
	.bind =3D		usbnet_cdc_ecm_bind,
	.unbind =3D	usbnet_cdc_unbind,
	.status =3D	usbnet_cdc_status,
	.manage_power =3D	usbnet_manage_power,
};


Bj=C3=B8rn
