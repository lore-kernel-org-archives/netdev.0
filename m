From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Do I need to skb_put() Ethernet frames to a minimum of 60
 bytes?
Date: Tue, 21 Aug 2012 19:42:47 +0200
Message-ID: <1345570967.5158.541.camel@edumazet-glaptop>
References: <502A9EC4.4040208@xdin.com>
	 <1344976557.2690.43.camel@bwh-desktop.uk.solarflarecom.com>
	 <5033C6B0.4060508@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38327 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139Ab2HURmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 13:42:52 -0400
Received: by eeil10 with SMTP id l10so24166eei.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 10:42:51 -0700 (PDT)
In-Reply-To: <5033C6B0.4060508@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 17:34 +0000, Arvid Brodin wrote:

> Nicolas, can you take a look at this? At the moment I'm using the following change
> in macb.c to avoid TX underruns on short packages:
> 
> --- a/drivers/net/ethernet/cadence/macb.c	2012-05-04 19:14:41.927719667 +0200
> +++ b/drivers/net/ethernet/cadence/macb.c	2012-08-21 19:22:40.063739049 +0200
> @@ -618,6 +618,7 @@ static void macb_poll_controller(struct
>  }
>  #endif
> 
> +#define MIN_ETHFRAME_LEN	60
>  static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct macb *bp = netdev_priv(dev);
> @@ -635,6 +636,12 @@ static int macb_start_xmit(struct sk_buf
>  	printk("\n");
>  #endif
> 
> +	if (skb->len < MIN_ETHFRAME_LEN) {
> +		/* Pad skb to minium Ethernet frame size */
> +		if (skb_tailroom(skb) >= MIN_ETHFRAME_LEN - skb->len)
> +			memset(skb_put(skb, MIN_ETHFRAME_LEN - skb->len), 0,
> +						MIN_ETHFRAME_LEN - skb->len);
> +	}
>  	len = skb->len;
>  	spin_lock_irqsave(&bp->lock, flags);
> 
> 
> ... but as you can see this is limited to linear skbs which has been allocated with
> enough tailroom. Perhaps there are better ways to fix the problem? (Maybe the hardware
> is actually doing the padding already and the problem has to do with the way the DMA
> transfer is set up?)
> 

other net drivers use skb_padto() for this ...
