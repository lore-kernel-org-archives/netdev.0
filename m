From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] 3c505: do not set pcb->data.raw beyond its size
Date: Thu, 12 Feb 2009 06:37:15 +0000
Message-ID: <20090212063715.GA4283@ff.dom.local>
References: <20090211133341.GB12362@ff.dom.local> <4992DF3C.7070802@gmail.com> <20090211171403.GA2539@ami.dom.local> <49932805.7050309@gmail.com> <20090211202755.GA2550@ami.dom.local> <20090211205854.GB2550@ami.dom.local> <4993576C.8080409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, philb@gnu.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:14410 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbZBLGhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 01:37:22 -0500
Received: by fg-out-1718.google.com with SMTP id 16so175131fgg.17
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 22:37:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4993576C.8080409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 11, 2009 at 11:55:40PM +0100, Roel Kluin wrote:
> Many thanks, Jarek,
> 
> Is this changelog ok?

Yes, the changelog and patch look OK to me.

Thanks,
Jarek P.

> ------------------------------>8----------------8<------------------------------
> 
> Ensure that we do not set pcb->data.raw beyond its size, print an error message
> and return false if we attempt to. A timout message was printed one too early.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
> index 6124605..a8107f9 100644
> --- a/drivers/net/3c505.c
> +++ b/drivers/net/3c505.c
> @@ -493,21 +493,27 @@ static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
>  	}
>  	/* read the data */
>  	spin_lock_irqsave(&adapter->lock, flags);
> -	i = 0;
> -	do {
> -		j = 0;
> -		while (((stat = get_status(dev->base_addr)) & ACRF) == 0 && j++ < 20000);
> -		pcb->data.raw[i++] = inb_command(dev->base_addr);
> -		if (i > MAX_PCB_DATA)
> -			INVALID_PCB_MSG(i);
> -	} while ((stat & ASF_PCB_MASK) != ASF_PCB_END && j < 20000);
> +	for (i = 0; i < MAX_PCB_DATA; i++) {
> +		for (j = 0; j < 20000; j++) {
> +			stat = get_status(dev->base_addr);
> +			if (stat & ACRF)
> +				break;
> +		}
> +		pcb->data.raw[i] = inb_command(dev->base_addr);
> +		if ((stat & ASF_PCB_MASK) == ASF_PCB_END || j >= 20000)
> +			break;
> +	}
>  	spin_unlock_irqrestore(&adapter->lock, flags);
> +	if (i >= MAX_PCB_DATA) {
> +		INVALID_PCB_MSG(i);
> +		return false;
> +	}
>  	if (j >= 20000) {
>  		TIMEOUT_MSG(__LINE__);
>  		return false;
>  	}
> -	/* woops, the last "data" byte was really the length! */
> -	total_length = pcb->data.raw[--i];
> +	/* the last "data" byte was really the length! */
> +	total_length = pcb->data.raw[i];
>  
>  	/* safety check total length vs data length */
>  	if (total_length != (pcb->length + 2)) {
