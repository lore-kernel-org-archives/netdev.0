From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] WAN: bit and/or confusion
Date: Sat, 15 Aug 2009 20:46:24 +0200
Message-ID: <m3iqgovrsv.fsf@intrepid.localdomain>
References: <4A855DE2.2000907@gmail.com>
	<20090814163644.0cc8974f.akpm@linux-foundation.org>
	<20090814.164123.36875657.davem@davemloft.net>
	<20090814165852.7338461e.akpm@linux-foundation.org>
	<4A86BAF3.5060609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:42025 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800AbZHOSqZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Aug 2009 14:46:25 -0400
In-Reply-To: <4A86BAF3.5060609@gmail.com> (Roel Kluin's message of "Sat\, 15 Aug 2009 15\:41\:07 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin <roel.kluin@gmail.com> writes:

> +++ b/drivers/net/wan/dscc4.c
> @@ -663,9 +663,9 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
>  	} else {
>  		if (skb->data[pkt_len] & FrameRdo)
>  			dev->stats.rx_fifo_errors++;
> -		else if (!(skb->data[pkt_len] | ~FrameCrc))
> +		else if (!(skb->data[pkt_len] & FrameCrc))
>  			dev->stats.rx_crc_errors++;

This looks like a correct fix.

> -		else if (!(skb->data[pkt_len] | ~(FrameVfr | FrameRab)))
> +		else if (!(skb->data[pkt_len] & (FrameVfr | FrameRab)))
>  			dev->stats.rx_length_errors++;

This test requires both FrameVfr and FrameRab to be true (zero). Perhaps
it should be:

> +		else if ((skb->data[pkt_len] & (FrameVfr | FrameRab)) != FrameVfr | FrameRab)

>  		else
>  			dev->stats.rx_errors++;

rx_errors is incremented only on remaining errors. I think most drivers
increment rx_errors on all RX errors, and simultaneously rx_*_errors
when needed.


Perhaps something like the following should be better?

		u8 status = ~skb->data[pkt_len];

		if (status == 0)
			looks_good...;
		else {
			if (status & FrameRab)
				...
			if (status & FrameVfr)
				...
			etc.
			rx_errors++;
		}

I don't have the hardware and can't test (donations of such hw welcome).
-- 
Krzysztof Halasa
