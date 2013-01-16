From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] CDC_NCM adding support IFF_NOARP for infineon modem
 platform
Date: Wed, 16 Jan 2013 15:45:43 -0600
Message-ID: <1358372743.8713.0.camel@dcbw.foobar.com>
References: <1357990479-5836-1-git-send-email-cpuwolf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org,
	bjorn-yOkvZcmFvRU@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1357990479-5836-1-git-send-email-cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-01-12 at 19:34 +0800, Wei Shuai wrote:
> Infineon(now Intel) HSPA Modem platform NCM cannot support ARP. so I introduce a flag CDC_NCM_DRIVER_DATA_NOARP which is defined in driver_info:data. so later on, if more such buggy devices are found, they could use same flag to handle. 

So given that Dave now approves of IFF_NOARP, let's change your original
patch to add a FLAG_NOARP for the .flags structure instead of inventing
another mechanism for .data.

Dan

> Signed-off-by: Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/usb/cdc_ncm.c |   29 +++++++++++++++++++++++++++++
>  1 files changed, 29 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index 71b6e92..6093e07 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -55,6 +55,9 @@
>  
>  #define	DRIVER_VERSION				"14-Mar-2012"
>  
> +/* Flags for driver_info::data */
> +#define CDC_NCM_DRIVER_DATA_NOARP  1
> +
>  static void cdc_ncm_txpath_bh(unsigned long param);
>  static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx);
>  static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_timer);
> @@ -573,6 +576,10 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
>  		return -ENODEV;
>  #endif
>  
> +	if (dev->driver_info->data & CDC_NCM_DRIVER_DATA_NOARP) {
> +		/* some buggy device cannot do ARP*/
> +		dev->net->flags |= IFF_NOARP;
> +	}
>  	/* NCM data altsetting is always 1 */
>  	ret = cdc_ncm_bind_common(dev, intf, 1);
>  
> @@ -1155,6 +1162,21 @@ static const struct driver_info wwan_info = {
>  	.tx_fixup = cdc_ncm_tx_fixup,
>  };
>  
> +/* Same as wwan_info, but with IFF_NOARP  */
> +static const struct driver_info wwan_noarp_info = {
> +	.description = "Mobile Broadband Network Device (NO ARP)",
> +	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
> +			| FLAG_WWAN,
> +	.data = CDC_NCM_DRIVER_DATA_NOARP,
> +	.bind = cdc_ncm_bind,
> +	.unbind = cdc_ncm_unbind,
> +	.check_connect = cdc_ncm_check_connect,
> +	.manage_power = usbnet_manage_power,
> +	.status = cdc_ncm_status,
> +	.rx_fixup = cdc_ncm_rx_fixup,
> +	.tx_fixup = cdc_ncm_tx_fixup,
> +};
> +
>  static const struct usb_device_id cdc_devs[] = {
>  	/* Ericsson MBM devices like F5521gw */
>  	{ .match_flags = USB_DEVICE_ID_MATCH_INT_INFO
> @@ -1194,6 +1216,13 @@ static const struct usb_device_id cdc_devs[] = {
>  	  .driver_info = (unsigned long)&wwan_info,
>  	},
>  
> +	/* Infineon(now Intel) HSPA Modem platform */
> +	{ USB_DEVICE_AND_INTERFACE_INFO(0x1519, 0x0443,
> +		USB_CLASS_COMM,
> +		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
> +	  .driver_info = (unsigned long)&wwan_noarp_info,
> +	},
> +
>  	/* Generic CDC-NCM devices */
>  	{ USB_INTERFACE_INFO(USB_CLASS_COMM,
>  		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
