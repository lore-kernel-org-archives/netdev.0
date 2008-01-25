From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 10/14] [rndis_host] Add rndis_early_init function pointer to 'struct rndis_data'.
Date: Thu, 24 Jan 2008 17:10:35 -0800
Message-ID: <200801241710.35528.david-b@pacbell.net>
References: <20080120001438.25718.96722.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjd-a1rhEgazXTw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080120001438.25718.96722.stgit-q/85JClnwdg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 19 January 2008, Jussi Kivilinna wrote:
> Function pointer is for rndis minidrivers that need to do work on device right
> after RNDIS_INIT. For example setting device specific configuration parameters
> with OID_GEN_RNDIS_CONFIG_PARAMETER.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>

Could this -- and #11/14 -- instead be generalized a bit,
so they're not RNDIS-specific?  At least in name; the
only user for now would be the rndis_host code.

The generalization would presumably be "early_init" and
"link_change", paired with doc comments reflecting that
they're usable by any driver stack built over the usbnet
framework core.

There's no point IMO to having generalizable hooks be
restricted this way.

- Dave


> ---
> 
>  drivers/net/usb/rndis_host.c |    6 ++++++
>  drivers/net/usb/usbnet.h     |    3 +++
>  2 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index 1d6bf0a..22e5ca1 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -336,6 +336,12 @@ int generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf)
>  		dev->hard_mtu, tmp, dev->rx_urb_size,
>  		1 << le32_to_cpu(u.init_c->packet_alignment));
>  
> +	/* module has some device initialization code needs to be done right
> +	 * after RNDIS_INIT */
> +	if (dev->driver_info->rndis_early_init &&
> +			dev->driver_info->rndis_early_init(dev) != 0)
> +		goto halt_fail_and_release;
> +
>  	/* Get designated host ethernet address */
>  	reply_len = ETH_ALEN;
>  	retval = rndis_query(dev, intf, u.buf, OID_802_3_PERMANENT_ADDRESS,
> diff --git a/drivers/net/usb/usbnet.h b/drivers/net/usb/usbnet.h
> index 0b4bf09..2bc5f76 100644
> --- a/drivers/net/usb/usbnet.h
> +++ b/drivers/net/usb/usbnet.h
> @@ -116,6 +116,9 @@ struct driver_info {
>  	struct sk_buff	*(*tx_fixup)(struct usbnet *dev,
>  				struct sk_buff *skb, gfp_t flags);
>  
> +	/* rndis minidriver early initialization code, can sleep */
> +	int	(*rndis_early_init)(struct usbnet *dev);
> +
>  	/* for new devices, use the descriptor-reading code instead */
>  	int		in;		/* rx endpoint */
>  	int		out;		/* tx endpoint */
> 
