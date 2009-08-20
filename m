From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] WAN: bit and/or confusion
Date: Thu, 20 Aug 2009 16:25:13 +0200
Message-ID: <m3eir6k1fa.fsf@intrepid.localdomain>
References: <4A855DE2.2000907@gmail.com>
	<20090814163644.0cc8974f.akpm@linux-foundation.org>
	<20090814.164123.36875657.davem@davemloft.net>
	<20090814165852.7338461e.akpm@linux-foundation.org>
	<4A86BAF3.5060609@gmail.com> <m3iqgovrsv.fsf@intrepid.localdomain>
	<4A8D57F8.1050106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:39229 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754249AbZHTOZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 10:25:14 -0400
In-Reply-To: <4A8D57F8.1050106@gmail.com> (Roel Kluin's message of "Thu\, 20 Aug 2009 16\:04\:40 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin <roel.kluin@gmail.com> writes:

>> Perhaps something like the following should be better?
>> 
>> 		u8 status = ~skb->data[pkt_len];
>> 
>> 		if (status == 0)
>> 			looks_good...;
>> 		else {
>> 			if (status & FrameRab)
>> 				...
>> 			if (status & FrameVfr)
>> 				...
>> 			etc.
>> 			rx_errors++;
>> 		}
>
> I don't understand your suggestion - why status == 0? doesn't the patch
> below do what you want instead?

Because I think (didn't read the manual) that these (inverted) bits
represent specific errors. So I suggested inverting them, then treating
as separate error bits, it should be easier to read.

That's only a suggestion of course (unless someone sends me the/a card -
non-returnable "donations" only please - and I can work on it
personally).

IOW all (inverted) bits = 1 => all bits zero after inversion => no
errors. This changes functionality a bit, and would need to be checked.
Otherwise, you could test: if ((status & FrameOk) == 0) then looks_good().

> diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
> index 8face5d..88534b6 100644
> --- a/drivers/net/wan/dscc4.c
> +++ b/drivers/net/wan/dscc4.c
> @@ -663,12 +663,12 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
>  	} else {
>  		if (skb->data[pkt_len] & FrameRdo)
>  			dev->stats.rx_fifo_errors++;
> -		else if (!(skb->data[pkt_len] | ~FrameCrc))
> +		else if (!(skb->data[pkt_len] & FrameCrc))
>  			dev->stats.rx_crc_errors++;
> -		else if (!(skb->data[pkt_len] | ~(FrameVfr | FrameRab)))
> +		else if ((skb->data[pkt_len] & (FrameVfr | FrameRab)) !=
> +				FrameVfr | FrameRab)
>  			dev->stats.rx_length_errors++;
> -		else
> -			dev->stats.rx_errors++;
> +		dev->stats.rx_errors++;
>  		dev_kfree_skb_irq(skb);
>  	}
>  refill:

Guess it would do.
-- 
Krzysztof Halasa
