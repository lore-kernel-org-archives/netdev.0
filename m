From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 12/14 v2] [rndis_host] Add RNDIS physical medium checking into generic_rndis_bind()
Date: Sun, 27 Jan 2008 22:49:42 -0800
Message-ID: <200801272249.43094.david-b@pacbell.net>
References: <20080127213358.7278.32005.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bjd-a1rhEgazXTw@public.gmane.org
To: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080127213358.7278.32005.stgit-q/85JClnwdg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 27 January 2008, Jussi Kivilinna wrote:
> Add RNDIS physical medium checking into generic_rndis_bind() and also make
> rndis_host to be only bind on every medium except wireless.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>

Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

I think that means the whole series is fair to merge into
the network drivers queue, assuming nobody has any issues
with the last patch (adding the actual rndis_wlan support).

Thanks for doing this ... it's nice to see folk successfully
building on top of this rndis_host code, since it started
without any "real" RNDIS devices to test against!  (Just the
Linux-USB "g_ether" peripheral code.)

- Dave


> ---
> 
>  drivers/net/usb/rndis_host.c |   36 +++++++++++++++++++++++++++++++++---
>  drivers/net/usb/rndis_host.h |   19 ++++++++++++++++++-
>  2 files changed, 51 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index 800c9d0..0606e11 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -271,7 +271,8 @@ response_error:
>  	return -EDOM;
>  }
>  
> -int generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf)
> +int
> +generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
>  {
>  	int			retval;
>  	struct net_device	*net = dev->net;
> @@ -287,7 +288,7 @@ int generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf)
>  		struct rndis_set_c	*set_c;
>  		struct rndis_halt	*halt;
>  	} u;
> -	u32			tmp;
> +	u32			tmp, *phym;
>  	int			reply_len;
>  	unsigned char		*bp;
>  
> @@ -358,6 +359,30 @@ int generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf)
>  			dev->driver_info->early_init(dev) != 0)
>  		goto halt_fail_and_release;
>  
> +	/* Check physical medium */
> +	reply_len = sizeof *phym;
> +	retval = rndis_query(dev, intf, u.buf, OID_GEN_PHYSICAL_MEDIUM,
> +			0, (void **) &phym, &reply_len);
> +	if (retval != 0)
> +		/* OID is optional so don't fail here. */
> +		*phym = RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED;
> +	if ((flags & FLAG_RNDIS_PHYM_WIRELESS) &&
> +			*phym != RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
> +		if (netif_msg_probe(dev))
> +			dev_dbg(&intf->dev, "driver requires wireless "
> +				"physical medium, but device is not.\n");
> +		retval = -ENODEV;
> +		goto halt_fail_and_release;
> +	}
> +	if ((flags & FLAG_RNDIS_PHYM_NOT_WIRELESS) &&
> +			*phym == RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
> +		if (netif_msg_probe(dev))
> +			dev_dbg(&intf->dev, "driver requires non-wireless "
> +				"physical medium, but device is wireless.\n");
> +		retval = -ENODEV;
> +		goto halt_fail_and_release;
> +	}
> +
>  	/* Get designated host ethernet address */
>  	reply_len = ETH_ALEN;
>  	retval = rndis_query(dev, intf, u.buf, OID_802_3_PERMANENT_ADDRESS,
> @@ -403,6 +428,11 @@ fail:
>  }
>  EXPORT_SYMBOL_GPL(generic_rndis_bind);
>  
> +static int rndis_bind(struct usbnet *dev, struct usb_interface *intf)
> +{
> +	return generic_rndis_bind(dev, intf, FLAG_RNDIS_PHYM_NOT_WIRELESS);
> +}
> +
>  void rndis_unbind(struct usbnet *dev, struct usb_interface *intf)
>  {
>  	struct rndis_halt	*halt;
> @@ -518,7 +548,7 @@ EXPORT_SYMBOL_GPL(rndis_tx_fixup);
>  static const struct driver_info	rndis_info = {
>  	.description =	"RNDIS device",
>  	.flags =	FLAG_ETHER | FLAG_FRAMING_RN | FLAG_NO_SETINT,
> -	.bind =		generic_rndis_bind,
> +	.bind =		rndis_bind,
>  	.unbind =	rndis_unbind,
>  	.status =	rndis_status,
>  	.rx_fixup =	rndis_rx_fixup,
> diff --git a/drivers/net/usb/rndis_host.h b/drivers/net/usb/rndis_host.h
> index 61f1fd8..edc1d4a 100644
> --- a/drivers/net/usb/rndis_host.h
> +++ b/drivers/net/usb/rndis_host.h
> @@ -82,6 +82,17 @@ struct rndis_msg_hdr {
>  #define	RNDIS_STATUS_MEDIA_CONNECT	ccpu2(0x4001000b)
>  #define	RNDIS_STATUS_MEDIA_DISCONNECT	ccpu2(0x4001000c)
>  
> +/* codes for OID_GEN_PHYSICAL_MEDIUM */
> +#define	RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED	ccpu2(0x00000000)
> +#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN	ccpu2(0x00000001)
> +#define	RNDIS_PHYSICAL_MEDIUM_CABLE_MODEM	ccpu2(0x00000002)
> +#define	RNDIS_PHYSICAL_MEDIUM_PHONE_LINE	ccpu2(0x00000003)
> +#define	RNDIS_PHYSICAL_MEDIUM_POWER_LINE	ccpu2(0x00000004)
> +#define	RNDIS_PHYSICAL_MEDIUM_DSL		ccpu2(0x00000005)
> +#define	RNDIS_PHYSICAL_MEDIUM_FIBRE_CHANNEL	ccpu2(0x00000006)
> +#define	RNDIS_PHYSICAL_MEDIUM_1394		ccpu2(0x00000007)
> +#define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_WAN	ccpu2(0x00000008)
> +#define	RNDIS_PHYSICAL_MEDIUM_MAX		ccpu2(0x00000009)
>  
>  struct rndis_data_hdr {
>  	__le32	msg_type;		/* RNDIS_MSG_PACKET */
> @@ -222,6 +233,7 @@ struct rndis_keepalive_c {	/* IN (optionally OUT) */
>  #define OID_802_3_PERMANENT_ADDRESS	ccpu2(0x01010101)
>  #define OID_GEN_MAXIMUM_FRAME_SIZE	ccpu2(0x00010106)
>  #define OID_GEN_CURRENT_PACKET_FILTER	ccpu2(0x0001010e)
> +#define OID_GEN_PHYSICAL_MEDIUM		ccpu2(0x00010202)
>  
>  /* packet filter bits used by OID_GEN_CURRENT_PACKET_FILTER */
>  #define RNDIS_PACKET_TYPE_DIRECTED		ccpu2(0x00000001)
> @@ -244,10 +256,15 @@ struct rndis_keepalive_c {	/* IN (optionally OUT) */
>  	RNDIS_PACKET_TYPE_ALL_MULTICAST | \
>  	RNDIS_PACKET_TYPE_PROMISCUOUS)
>  
> +/* Flags to require specific physical medium type for generic_rndis_bind() */
> +#define FLAG_RNDIS_PHYM_NOT_WIRELESS	0x0001
> +#define FLAG_RNDIS_PHYM_WIRELESS	0x0002
> +
>  
>  extern void rndis_status(struct usbnet *dev, struct urb *urb);
>  extern int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf);
> -extern int generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf);
> +extern int
> +generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags);
>  extern void rndis_unbind(struct usbnet *dev, struct usb_interface *intf);
>  extern int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb);
>  extern struct sk_buff *
> 
