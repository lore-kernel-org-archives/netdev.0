From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH] gianfar: fix potential sk_wmem_alloc imbalance
Date: Wed, 11 Jul 2012 11:06:36 +0300
Message-ID: <4FFD340C.3090405@freescale.com>
References: <1341524713.3265.41.camel@edumazet-glaptop>  <20120706180947.GI1817@windriver.com> <1341738542.3265.1406.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Manfred Rudigier <manfred.rudigier@omicron.at>,
	Jiajun Wu <b06378@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe001.messaging.microsoft.com ([213.199.154.204]:20519
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754223Ab2GKIHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 04:07:07 -0400
In-Reply-To: <1341738542.3265.1406.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 7/8/2012 12:09 PM, Eric Dumazet wrote:
> On Fri, 2012-07-06 at 14:09 -0400, Paul Gortmaker wrote:
>
>> Aside from the one line change at driver init, is there more to it than
>> that?  More specifically, it currently does:
>>
>> fcb_length = GMAC_FCB_LEN;
>>
>> if (...timestamps...)
>> 	fcb_length = GMAC_FCB_LEN + GMAC_TXPAL_LEN;
>>
>> if (... && (skb_headroom(skb) < fcb_length))
>> 	...
>> 	skb_new = skb_realloc_headroom(skb, fcb_length);
>>
>> and I don't know the code well enough to know if setting the
>> needed_headroom value _guarantees_ the above fcb_length comparison
>> will always be false, and hence can be deleted.  It kind of looks
>> like it via LL_RESERVED_SPACE, but I'm not 100% sure...
>
> This is not a guarantee but should take care of most cases.
>
> So we should keep the test anyway.
>
> And init needed_headroom to the largest room. Existing tests seems to
> ignore vlan case and timestamping.

VLAN tagging (offloaded by eTSEC) is accommodated by the FCB block (8 
bytes), which seemingly has already been reserved in the headroom 
(GMAC_FCB_LEN). So it shouldn't require extra headroom.

And, according to the hw manual, time stamp insertion for transmit 
packets requires an additional 16 bytes, next to the FCB, as the 
timestamp (8 bytes) is written at an offset of 16. And looks like this 
is taken care of by GMAC_TXPAL_LEN.

However I don't fully understand the "needed_headroom" setting and its 
implications, maybe you could help with the following questions.
Is "needed_headroom" setting relevant for IP forwarding scenarios too?
Or is it used only in the case when the networking stack generates 
packets for Tx?

Thanks!

Claudiu

>
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index af16f9f..b4517b7 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -1084,9 +1084,7 @@ static int gfar_probe(struct platform_device *ofdev)
>   	else
>   		priv->padding = 0;
>
> -	if (dev->features & NETIF_F_IP_CSUM ||
> -	    priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)
> -		dev->needed_headroom = GMAC_FCB_LEN;
> +	dev->needed_headroom = GMAC_FCB_LEN + GMAC_TXPAL_LEN;
>
>   	/* Program the isrg regs only if number of grps > 1 */
>   	if (priv->num_grps > 1) {
>
>
>
>
> .
>
