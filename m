From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 10/14] [rndis_host] Add early_init function pointer to 'struct rndis_data'.
Date: Sun, 27 Jan 2008 08:14:43 -0800
Message-ID: <200801270814.43760.david-b@pacbell.net>
References: <20080125225032.11716.77713.stgit@fate.lan> <20080125225128.11716.59998.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	bjd@jooz.net
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp114.sbc.mail.mud.yahoo.com ([68.142.198.213]:37200 "HELO
	smtp114.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752305AbYA0Q34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2008 11:29:56 -0500
In-Reply-To: <20080125225128.11716.59998.stgit@fate.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 January 2008, Jussi Kivilinna wrote:
> Function pointer is for 'subminidrivers' that need to do work on device 
> right after minidriver has initialized hardware.
> 
> For example, rndis_wlan setting device specific configuration parameters
> with OID_GEN_RNDIS_CONFIG_PARAMETER right after rndis_host has 
> initialized hardware with RNDIS_INIT.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>

... though I'm not sure I'd coin a term like "subminidriver".  ;)


> ---
> 
>  drivers/net/usb/rndis_host.c |    6 ++++++
>  drivers/net/usb/usbnet.h     |    5 +++++
>  2 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index 1d6bf0a..0813903 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -336,6 +336,12 @@ int generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf)
>  		dev->hard_mtu, tmp, dev->rx_urb_size,
>  		1 << le32_to_cpu(u.init_c->packet_alignment));
>  
> +	/* module has some device initialization code needs to be done right
> +	 * after RNDIS_INIT */
> +	if (dev->driver_info->early_init &&
> +			dev->driver_info->early_init(dev) != 0)
> +		goto halt_fail_and_release;
> +
>  	/* Get designated host ethernet address */
>  	reply_len = ETH_ALEN;
>  	retval = rndis_query(dev, intf, u.buf, OID_802_3_PERMANENT_ADDRESS,
> diff --git a/drivers/net/usb/usbnet.h b/drivers/net/usb/usbnet.h
> index 0b4bf09..25b63d3 100644
> --- a/drivers/net/usb/usbnet.h
> +++ b/drivers/net/usb/usbnet.h
> @@ -116,6 +116,11 @@ struct driver_info {
>  	struct sk_buff	*(*tx_fixup)(struct usbnet *dev,
>  				struct sk_buff *skb, gfp_t flags);
>  
> +	/* early initialization code, can sleep. This is for minidrivers
> +	 * having 'subminidrivers' that need to do extra initialization
> +	 * right after minidriver have initialized hardware. */
> +	int	(*early_init)(struct usbnet *dev);
> +
>  	/* for new devices, use the descriptor-reading code instead */
>  	int		in;		/* rx endpoint */
>  	int		out;		/* tx endpoint */
> 


