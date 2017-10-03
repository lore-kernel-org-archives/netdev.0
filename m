From: Vignesh R <vigneshr@ti.com>
Subject: Re: [v2] cdc-ether: divorce initialisation with a filter reset and a
 generic method
Date: Tue, 3 Oct 2017 13:39:18 +0530
Message-ID: <fbe82c0f-c3d5-4dd6-62a7-b8fd2ea83302@ti.com>
References: <20170522125030.21266-1-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oneukum@suse.com>, <netdev@vger.kernel.org>,
        <bjorn@mork.no>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:17042 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751102AbdJCILY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 04:11:24 -0400
In-Reply-To: <20170522125030.21266-1-oneukum@suse.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Monday 22 May 2017 06:20 PM, Oliver Neukum wrote:
> Some devices need their multicast filter reset but others are crashed by that.
> So the methods need to be separated.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.com>
> Reported-by: "Ridgway, Keith" <kridgway@harris.com>
> ---

I see this patch was merged and said to be queued for -stable, but I
don't see this fix in any of the stable kernels. Would you please ask
for this patch to be backported to -stable kernels?

Regards
Vignesh

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
> 

-- 
Regards
Vignesh
