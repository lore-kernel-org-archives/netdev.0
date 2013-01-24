From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net] net: usbnet: prevent buggy devices from killing us
Date: Thu, 24 Jan 2013 15:57:09 -0800
Message-ID: <1359071829.2117.6.camel@joe-AO722>
References: <2556579.vjYlY1iKn5@linux-5eaq.site>
	 <1359055016-13603-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1359055016-13603-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-01-24 at 20:16 +0100, Bj=F8rn Mork wrote:
> A device sending 0 length frames as fast as it can has been
> observed killing the host system due to the resulting memory
> pressure.
[]
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
[]
> @@ -539,6 +545,22 @@ block:
>  		break;
>  	}
> =20
> +	/* stop rx if packet error rate is high */
> +	if (++dev->pkt_cnt > 30) {
> +		dev->pkt_cnt =3D 0;
> +		dev->pkt_err =3D 0;
> +	} else {
> +		if (state =3D=3D rx_cleanup)
> +			dev->pkt_err++;
> +		if (dev->pkt_err > 20) {
> +			set_bit(EVENT_RX_KILL, &dev->flags);
> +			if (net_ratelimit())
> +				netif_dbg(dev, rx_err, dev->net,
> +					  "rx kill: high error rate\n");
> +			dev->pkt_err =3D 0;
> +		}
> +	}

Maybe use ratelimit() here?

> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
[]
> @@ -33,6 +33,7 @@ struct usbnet {
>  	wait_queue_head_t	*wait;
>  	struct mutex		phy_mutex;
>  	unsigned char		suspend_count;
> +	unsigned char		pkt_cnt, pkt_err;

and instead:

	struct ratelimit_state errors;



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
