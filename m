From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] usbnet: fix oops in usbnet_start_xmit
Date: Mon, 7 Nov 2011 14:33:51 +0100
Message-ID: <20111107133351.GA1484@cherladcori01>
References: <20111106183337.5379.4356.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, devel@openvz.org,
	Michael Riesch <michael@riesch.at>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51830 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754394Ab1KGNeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 08:34:04 -0500
Received: by eye27 with SMTP id 27so3420573eye.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 05:34:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20111106183337.5379.4356.stgit@zurg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 06, 2011 at 10:33:37PM +0300, Konstantin Khlebnikov wrote:
> This patch fixes the bug added in commit v3.1-rc7-1055-gf9b491e
> SKB can be NULL at this point, at least for cdc-ncm.

What? You mean .ndo_start_xmit is called with skb NULL?

> Let's call skb_tx_timestamp() after driver specific tx-fixup hacks.

No, that won't work.

That call is before the fixup on purpose, because some fixups add
padding in front of the Ethernet payload, and this will spoil the PTP
packet detection filter.

I don't know why the skb can be NULL here. If that is really the case,
then the correct fix is:

	if (skb)
		skb_tx_timestamp(skb);

Thanks,
Richard


> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> ---
>  drivers/net/usb/usbnet.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 7d60821..485be70 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1057,8 +1057,6 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
>  	unsigned long		flags;
>  	int retval;
>  
> -	skb_tx_timestamp(skb);
> -
>  	// some devices want funky USB-level framing, for
>  	// win32 driver (usually) and/or hardware quirks
>  	if (info->tx_fixup) {
> @@ -1075,6 +1073,8 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
>  	}
>  	length = skb->len;
>  
> +	skb_tx_timestamp(skb);
> +
>  	if (!(urb = usb_alloc_urb (0, GFP_ATOMIC))) {
>  		netif_dbg(dev, tx_err, dev->net, "no urb\n");
>  		goto drop;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
