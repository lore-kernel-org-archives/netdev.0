From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] cdc-ether: clean packet filter upon probe
Date: Fri, 15 Aug 2014 09:13:07 +0200
Message-ID: <87d2c2xm2k.fsf@nemi.mork.no>
References: <1406537796-20156-1-git-send-email-oneukum@suse.de>
	<87a977z5pn.fsf@nemi.mork.no>
	<1408083121.17565.4.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36727 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbaHOHNU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 03:13:20 -0400
In-Reply-To: <1408083121.17565.4.camel@linux-fkkt.site> (Oliver Neukum's
	message of "Fri, 15 Aug 2014 08:12:01 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.de> writes:

> On Thu, 2014-08-14 at 13:11 +0200, Bj=C3=B8rn Mork wrote:
>> Oliver Neukum <oneukum@suse.de> writes:
>>=20
>> > There are devices that don't do reset all the way. So the packet f=
ilter should
>> > be set to a sane initial value. Failure to do so leads to intermit=
tent failures
>> > of DHCP on some systems under some conditions.
>> >
>> > Signed-off-by: Oliver Neukum <oneukum@suse.de>
>> > ---
>> >  drivers/net/usb/cdc_ether.c | 16 ++++++++++++++++
>> >  1 file changed, 16 insertions(+)
>> >
>> > diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_eth=
er.c
>> > index 9ea4bfe..2a32d91 100644
>> > --- a/drivers/net/usb/cdc_ether.c
>> > +++ b/drivers/net/usb/cdc_ether.c
>> > @@ -341,6 +341,22 @@ next_desc:
>> >  		usb_driver_release_interface(driver, info->data);
>> >  		return -ENODEV;
>> >  	}
>> > +
>> > +	/* Some devices don't initialise properly. In particular
>> > +	 * the packet filter is not reset. There are devices that
>> > +	 * don't do reset all the way. So the packet filter should
>> > +	 * be set to a sane initial value.
>> > +	 */
>> > +	usb_control_msg(dev->udev,
>> > +			usb_sndctrlpipe(dev->udev, 0),
>> > +			USB_CDC_SET_ETHERNET_PACKET_FILTER,
>> > +			USB_TYPE_CLASS | USB_RECIP_INTERFACE,
>> > +			USB_CDC_PACKET_TYPE_ALL_MULTICAST | USB_CDC_PACKET_TYPE_DIRECT=
ED | USB_CDC_PACKET_TYPE_BROADCAST,
>> > +			intf->cur_altsetting->desc.bInterfaceNumber,
>> > +			NULL,
>> > +			0,
>> > +			USB_CTRL_SET_TIMEOUT
>> > +		);
>> >  	return 0;
>> > =20
>> >  bad_desc:
>>=20
>> Hmm, the usbnet_generic_cdc_bind() function is used by the vendor
>> specific zaurus and rndis_host drivers as well.  Are we sure the
>> USB_CDC_SET_ETHERNET_PACKET_FILTER message is supported by all devic=
es
>> supported by these drivers?
>
> Support for this request is mandatory.

Yes, there is no problem for standard conforming ECM devices.  I fully
agree there.=20

But standard conformance is unfortunately not something we can expect.
My question was regarding the non-conforming devices, like the ones
supported by th zaurus and rndis_host drivers.  These drivers are made
solely because the supported devices do *not* conform to the ECM spec.
If you know they support the request, then fine.  But I do not think we
can assume that they do without testing it, despite what the ECM spec
says.


Bj=C3=B8rn
