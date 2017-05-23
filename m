From: "Ridgway, Keith" <kridgway@harris.com>
Subject: re: [PATCH v2] cdc-ether: divorce initialisation with a filter reset
 and a generic method
Date: Tue, 23 May 2017 11:08:28 +0000
Message-ID: <f5bf63ad488043f8af6e2f2778d5c32e@ROCXCH13.cs.myharris.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rocxsmtpout1.harris.com ([192.158.6.51]:56010 "EHLO
        rocxsmtp1.harris.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S935672AbdEWLXc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 07:23:32 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Some devices need their multicast filter reset but others are crashed by that.
> So the methods need to be separated.
>
> Signed-off-by: Oliver Neukum <oneukum@suse.com>
> Reported-by: "Ridgway, Keith" <kridgway@harris.com>

I have tested this patch with three different Harris radios and it fixes the problem we experienced with RNDIS.
I don't have any CDC Ethernet devices to try.
Tested-by: Keith Ridgway <kridgway@harris.com>

> ---
>  drivers/net/usb/cdc_ether.c | 31 ++++++++++++++++++++++++-------
>  include/linux/usb/usbnet.h  |  1 +
>  2 files changed, 25 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
> index f3ae88fdf332..8ab281b478f2 100644
> --- a/drivers/net/usb/cdc_ether.c
> +++ b/drivers/net/usb/cdc_ether.c
> @@ -310,6 +310,26 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
>  		return -ENODEV;
>  	}
>  
> +	return 0;
> +
> +bad_desc:
> +	dev_info(&dev->udev->dev, "bad CDC descriptors\n");
> +	return -ENODEV;
> +}
> +EXPORT_SYMBOL_GPL(usbnet_generic_cdc_bind);
> +
> +
> +/* like usbnet_generic_cdc_bind() but handles filter initialization
> + * correctly
> + */
> +int usbnet_ether_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
> +{
> +	int rv;
> +
> +	rv = usbnet_generic_cdc_bind(dev, intf);
> +	if (rv < 0)
> +		goto bail_out;
> +
>  	/* Some devices don't initialise properly. In particular
>  	 * the packet filter is not reset. There are devices that
>  	 * don't do reset all the way. So the packet filter should
> @@ -317,13 +337,10 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
>  	 */
>  	usbnet_cdc_update_filter(dev);
>  
> -	return 0;
> -
> -bad_desc:
> -	dev_info(&dev->udev->dev, "bad CDC descriptors\n");
> -	return -ENODEV;
> +bail_out:
> +	return rv;
>  }
> -EXPORT_SYMBOL_GPL(usbnet_generic_cdc_bind);
> +EXPORT_SYMBOL_GPL(usbnet_ether_cdc_bind);
>  
>  void usbnet_cdc_unbind(struct usbnet *dev, struct usb_interface *intf)
>  {
> @@ -417,7 +434,7 @@ int usbnet_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
>  	BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data)
>  			< sizeof(struct cdc_state)));
>  
> -	status = usbnet_generic_cdc_bind(dev, intf);
> +	status = usbnet_ether_cdc_bind(dev, intf);
>  	if (status < 0)
>  		return status;
>  
> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> index 7dffa5624ea6..97116379db5f 100644
> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -206,6 +206,7 @@ struct cdc_state {
>  };
>  
>  extern int usbnet_generic_cdc_bind(struct usbnet *, struct usb_interface *);
> +extern int usbnet_ether_cdc_bind(struct usbnet *dev, struct usb_interface *intf);
>  extern int usbnet_cdc_bind(struct usbnet *, struct usb_interface *);
>  extern void usbnet_cdc_unbind(struct usbnet *, struct usb_interface *);
>  extern void usbnet_cdc_status(struct usbnet *, struct urb *);
> -- 
> 2.12.0
>
