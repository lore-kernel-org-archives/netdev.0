From: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] USB CDC NCM: tx_fixup() race condition fix
Date: Mon, 17 Jan 2011 17:57:59 +0300
Message-ID: <4D3458F7.5070209@ru.mvista.com>
References: <1295271573-8890-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org, yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1295271573-8890-1-git-send-email-alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

Alexey Orishko wrote:

> - tx_fixup() call be called from either timer callback or from xmit()

    s/call/can/?

>   in usbnet, so spinlock is added to avoid concurrency-related problem.
> - minor correction due checkpatch warning for some line over 80 chars

    Due to?

>   after previous patch was applied.

> Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
> ---
>  drivers/net/usb/cdc_ncm.c |   13 ++++++++-----
>  1 files changed, 8 insertions(+), 5 deletions(-)

> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index d776c4a..bf13fa6 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -54,7 +54,7 @@
>  #include <linux/usb/usbnet.h>
>  #include <linux/usb/cdc.h>
>  
> -#define	DRIVER_VERSION				"30-Nov-2010"
> +#define	DRIVER_VERSION				"17-Jan-2011"
>  
>  /* CDC NCM subclass 3.2.1 */
>  #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
> @@ -873,9 +873,11 @@ static void cdc_ncm_tx_timeout(unsigned long arg)
>  
>  	spin_unlock(&ctx->mtx);
>  
> -	if (restart)
> +	if (restart) {
> +		spin_lock(&ctx->mtx);
>  		cdc_ncm_tx_timeout_start(ctx);
> -	else if (ctx->netdev != NULL)
> +		spin_unlock(&ctx->mtx);
> +	} else if (ctx->netdev != NULL)

    The 'else' branch should now also have {}, according to 
Documentation/CodingStyle.

>  		usbnet_start_xmit(NULL, ctx->netdev);
>  }
>  
> @@ -1021,7 +1024,7 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
>  		    (temp > CDC_NCM_MAX_DATAGRAM_SIZE) || (temp < ETH_HLEN)) {
>  			pr_debug("invalid frame detected (ignored)"
>  				"offset[%u]=%u, length=%u, skb=%p\n",
> -							x, offset, temp, skb_in);
> +						x, offset, temp, skb_in);

    Would be good to align uniformly with the previous line...

WBR, Sergei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
