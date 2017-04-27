From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] net: hso: register netdev later to avoid a race condition
Date: Thu, 27 Apr 2017 10:44:01 +0200
Message-ID: <20170427084401.GP2823@localhost>
References: <1493227600-10102-1-git-send-email-andreas@kemnade.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
        peter-WaGBZJeGNqdsbIuE7sb01tBPR1lH4CV8@public.gmane.org, hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andreas Kemnade <andreas-cLv4Z9ELZ06ZuzBka8ofvg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1493227600-10102-1-git-send-email-andreas-cLv4Z9ELZ06ZuzBka8ofvg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26, 2017 at 07:26:40PM +0200, Andreas Kemnade wrote:
> If the netdev is accessed before the urbs are initialized,
> there will be NULL pointer dereferences. That is avoided by
> registering it when it is fully initialized.

> Reported-by: H. Nikolaus Schaller <hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org>
> Signed-off-by: Andreas Kemnade <andreas-cLv4Z9ELZ06ZuzBka8ofvg@public.gmane.org>
> ---
>  drivers/net/usb/hso.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index 93411a3..00067a0 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -2534,13 +2534,6 @@ static struct hso_device *hso_create_net_device(struct usb_interface *interface,
>  	SET_NETDEV_DEV(net, &interface->dev);
>  	SET_NETDEV_DEVTYPE(net, &hso_type);
>  
> -	/* registering our net device */
> -	result = register_netdev(net);
> -	if (result) {
> -		dev_err(&interface->dev, "Failed to register device\n");
> -		goto exit;
> -	}
> -
>  	/* start allocating */
>  	for (i = 0; i < MUX_BULK_RX_BUF_COUNT; i++) {
>  		hso_net->mux_bulk_rx_urb_pool[i] = usb_alloc_urb(0, GFP_KERNEL);
> @@ -2560,6 +2553,13 @@ static struct hso_device *hso_create_net_device(struct usb_interface *interface,
>  
>  	add_net_device(hso_dev);
>  
> +	/* registering our net device */
> +	result = register_netdev(net);
> +	if (result) {
> +		dev_err(&interface->dev, "Failed to register device\n");
> +		goto exit;

This all looks good, but you should consider cleaning up the error
handling of this function as a follow-up as we should not be
deregistering netdevs that have never been registered (e.g. if a
required endpoint is missing or if registration fails for some reason).

But just to be clear, this problem existed also before this change.

> +	}
> +
>  	hso_log_port(hso_dev);
>  
>  	hso_create_rfkill(hso_dev, interface);

Reviewed-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Thanks,
Johan
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
