From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] cdc-ether: clean packet filter upon probe
Date: Thu, 14 Aug 2014 13:11:16 +0200
Message-ID: <87a977z5pn.fsf@nemi.mork.no>
References: <1406537796-20156-1-git-send-email-oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49389 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473AbaHNLLr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 07:11:47 -0400
In-Reply-To: <1406537796-20156-1-git-send-email-oneukum@suse.de> (Oliver
	Neukum's message of "Mon, 28 Jul 2014 10:56:36 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.de> writes:

> There are devices that don't do reset all the way. So the packet filt=
er should
> be set to a sane initial value. Failure to do so leads to intermitten=
t failures
> of DHCP on some systems under some conditions.
>
> Signed-off-by: Oliver Neukum <oneukum@suse.de>
> ---
>  drivers/net/usb/cdc_ether.c | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
>
> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.=
c
> index 9ea4bfe..2a32d91 100644
> --- a/drivers/net/usb/cdc_ether.c
> +++ b/drivers/net/usb/cdc_ether.c
> @@ -341,6 +341,22 @@ next_desc:
>  		usb_driver_release_interface(driver, info->data);
>  		return -ENODEV;
>  	}
> +
> +	/* Some devices don't initialise properly. In particular
> +	 * the packet filter is not reset. There are devices that
> +	 * don't do reset all the way. So the packet filter should
> +	 * be set to a sane initial value.
> +	 */
> +	usb_control_msg(dev->udev,
> +			usb_sndctrlpipe(dev->udev, 0),
> +			USB_CDC_SET_ETHERNET_PACKET_FILTER,
> +			USB_TYPE_CLASS | USB_RECIP_INTERFACE,
> +			USB_CDC_PACKET_TYPE_ALL_MULTICAST | USB_CDC_PACKET_TYPE_DIRECTED =
| USB_CDC_PACKET_TYPE_BROADCAST,
> +			intf->cur_altsetting->desc.bInterfaceNumber,
> +			NULL,
> +			0,
> +			USB_CTRL_SET_TIMEOUT
> +		);
>  	return 0;
> =20
>  bad_desc:

Hmm, the usbnet_generic_cdc_bind() function is used by the vendor
specific zaurus and rndis_host drivers as well.  Are we sure the
USB_CDC_SET_ETHERNET_PACKET_FILTER message is supported by all devices
supported by these drivers?


Bj=C3=B8rn
