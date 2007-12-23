From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 4/8] [PATCH] Halt device if rndis_bind fails.
Date: Sat, 22 Dec 2007 16:54:11 -0800
Message-ID: <20071223005412.0811E22313C@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
 <1198360295683-git-send-email-bjd@jooz.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	jussi.kivilinna@mbnet.fi
To: bjd@jooz.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.sbc.mail.mud.yahoo.com ([68.142.198.202]:37457 "HELO
	smtp103.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752309AbXLWBAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 20:00:54 -0500
In-Reply-To: <1198360295683-git-send-email-bjd@jooz.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From bjd@jooz.net  Sat Dec 22 13:53:07 2007
> From: Bjorge Dijkstra <bjd@jooz.net>
> To: dbrownell@users.sourceforge.net
> Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
> 	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Subject: [PATCH 4/8] [PATCH] Halt device if rndis_bind fails.
> Date: Sat, 22 Dec 2007 22:51:30 +0100
>
> From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
>
> When bind fails after device was initialized, shutdown device properly
> by sending RNDIS_MSG_HALT.
>
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Signed-off-by: Bjorge Dijkstra <bjd@jooz.net>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>

> ---
>  drivers/net/usb/rndis_host.c |   12 +++++++++---
>  1 files changed, 9 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index 42b161c..c686025 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -467,6 +467,7 @@ static int rndis_bind(struct usbnet *dev, struct usb_interface *intf)
>  		struct rndis_query_c	*get_c;
>  		struct rndis_set	*set;
>  		struct rndis_set_c	*set_c;
> +		struct rndis_halt	*halt;
>  	} u;
>  	u32			tmp;
>  	int			reply_len;
> @@ -517,7 +518,7 @@ static int rndis_bind(struct usbnet *dev, struct usb_interface *intf)
>  				"dev can't take %u byte packets (max %u)\n",
>  				dev->hard_mtu, tmp);
>  			retval = -EINVAL;
> -			goto fail_and_release;
> +			goto halt_fail_and_release;
>  		}
>  		dev->hard_mtu = tmp;
>  		net->mtu = dev->hard_mtu - net->hard_header_len;
> @@ -539,7 +540,7 @@ static int rndis_bind(struct usbnet *dev, struct usb_interface *intf)
>  			48, (void **) &bp, &reply_len);
>  	if (unlikely(retval< 0)) {
>  		dev_err(&intf->dev, "rndis get ethaddr, %d\n", retval);
> -		goto fail_and_release;
> +		goto halt_fail_and_release;
>  	}
>  	memcpy(net->dev_addr, bp, ETH_ALEN);
>  
> @@ -555,7 +556,7 @@ static int rndis_bind(struct usbnet *dev, struct usb_interface *intf)
>  	retval = rndis_command(dev, u.header);
>  	if (unlikely(retval < 0)) {
>  		dev_err(&intf->dev, "rndis set packet filter, %d\n", retval);
> -		goto fail_and_release;
> +		goto halt_fail_and_release;
>  	}
>  
>  	retval = 0;
> @@ -563,6 +564,11 @@ static int rndis_bind(struct usbnet *dev, struct usb_interface *intf)
>  	kfree(u.buf);
>  	return retval;
>  
> +halt_fail_and_release:
> +	memset(u.halt, 0, sizeof *u.halt);
> +	u.halt->msg_type = RNDIS_MSG_HALT;
> +	u.halt->msg_len = ccpu2(sizeof *u.halt);
> +	(void) rndis_command(dev, (void *)u.halt);
>  fail_and_release:
>  	usb_set_intfdata(info->data, NULL);
>  	usb_driver_release_interface(driver_of(intf), info->data);
> -- 
> 1.5.2.5
>
