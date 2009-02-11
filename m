From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: off by one, try #2
Date: Wed, 11 Feb 2009 18:14:03 +0100
Message-ID: <20090211171403.GA2539@ami.dom.local>
References: <20090211133341.GB12362@ff.dom.local> <4992DF3C.7070802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:61349 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756707AbZBKROT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 12:14:19 -0500
Received: by fxm13 with SMTP id 13so867821fxm.13
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 09:14:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4992DF3C.7070802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 11, 2009 at 03:22:52PM +0100, Roel Kluin wrote:
> >> With while (x++ < n) { ... } x can reach n+1.
> > 
> > Yes, but it looks like here is even more...
> > i is also misused here and array can be overriden, so additional
> > break/return is needed.
> 
> Thanks, is this how it should be?

It looks (almost) OK to me. :-) Except this > 80 line.

On the other hand, I wonder if it's not a good time to make it more
readable; I mean the first while (): length, ";", and maybe ++j
similarly to i now?

BTW, I hope you remember about irda.

Jarek P.

> -------------------->8----------------8<-----------------------
> 
> With while (x++ < n) { ... } x can reach n+1. As Jarek Poplawski pointed out, array
> pcb->data.raw was not correctly used.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
> index 6124605..4cf3050 100644
> --- a/drivers/net/3c505.c
> +++ b/drivers/net/3c505.c
> @@ -497,12 +497,15 @@ static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
>  	do {
>  		j = 0;
>  		while (((stat = get_status(dev->base_addr)) & ACRF) == 0 && j++ < 20000);
> -		pcb->data.raw[i++] = inb_command(dev->base_addr);
> -		if (i > MAX_PCB_DATA)
> -			INVALID_PCB_MSG(i);
> -	} while ((stat & ASF_PCB_MASK) != ASF_PCB_END && j < 20000);
> +		pcb->data.raw[i] = inb_command(dev->base_addr);
> +	} while (++i < MAX_PCB_DATA && (stat & ASF_PCB_MASK) != ASF_PCB_END && j <= 20000);
> +
>  	spin_unlock_irqrestore(&adapter->lock, flags);
> -	if (j >= 20000) {
> +	if (i >= MAX_PCB_DATA) {
> +		INVALID_PCB_MSG(i);
> +		return false;
> +	}
> +	if (j > 20000) {
>  		TIMEOUT_MSG(__LINE__);
>  		return false;
>  	}
