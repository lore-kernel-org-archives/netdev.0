From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] CDC_NCM adding support IFF_NOARP for buggy device
Date: Thu, 10 Jan 2013 15:10:49 +0100
Message-ID: <11735941.VRAKVV1na0@linux-5eaq.site>
References: <1357826368-30543-1-git-send-email-cpuwolf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: gregkh@linuxfoundation.org, alexey.orishko@stericsson.com,
	hans.petter.selasky@stericsson.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Wei Shuai <cpuwolf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43372 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023Ab3AJOKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 09:10:52 -0500
In-Reply-To: <1357826368-30543-1-git-send-email-cpuwolf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 10 January 2013 21:59:28 Wei Shuai wrote:

Hi,

I am afraid this is done in an unclean manner.

> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index 71b6e92..9903f79 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -545,6 +545,7 @@ EXPORT_SYMBOL_GPL(cdc_ncm_unbind);
>  static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
>  {
>  	int ret;
> +	struct usb_device *udev = interface_to_usbdev(intf);
>  
>  	/* The MBIM spec defines a NCM compatible default altsetting,
>  	 * which we may have matched:
> @@ -572,6 +573,10 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
>  	    cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
>  		return -ENODEV;
>  #endif
> +	/*  this buggy device cannot do ARP */
> +	if( (le16_to_cpu(udev->descriptor.idVendor) == 0xAAAA) ) {
> +		dev->net->flags |= IFF_NOARP;

So either you do a check here ...

> +	}
>  
>  	/* NCM data altsetting is always 1 */
>  	ret = cdc_ncm_bind_common(dev, intf, 1);
> @@ -1186,6 +1191,16 @@ static const struct usb_device_id cdc_devs[] = {
>  	  .driver_info = (unsigned long) &wwan_info,
>  	},
>  
> +	/* buggy device cannot send ARP */
> +	{ .match_flags = USB_DEVICE_ID_MATCH_INT_INFO
> +		| USB_DEVICE_ID_MATCH_VENDOR,
> +	  .idVendor = 0xAAAA,
> +	  .bInterfaceClass = USB_CLASS_COMM,
> +	  .bInterfaceSubClass = USB_CDC_SUBCLASS_NCM,
> +	  .bInterfaceProtocol = USB_CDC_PROTO_NONE,
> +	  .driver_info = (unsigned long) &wwan_info,

... or you define a matching id here and give it a flag in driver_info

But not both.

	Regards
		Oliver
