From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: Re: IPv6 multicast snooping behaviour on 2.6.39-rc2 and later
Date: Wed, 24 Aug 2011 16:38:39 +0900
Message-ID: <4E54AA7F.80107@sfc.wide.ad.jp>
References: <4E5367CA.3090005@sfc.wide.ad.jp> <1314093424.2219.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4E539DA8.1070504@sfc.wide.ad.jp> <1314105027.2219.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4E53B360.8090107@sfc.wide.ad.jp> <4E53E237.1060401@sfc.wide.ad.jp> <CAAM7YAmht5FFTTFHrDUXAXHD5h5gzn1GrtEbHkQfbaoCwccG0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Linus_L=FCssing?= <linus.luessing@web.de>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "Yan, Zheng " <yanzheng@21cn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:53602 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750835Ab1HXHim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 03:38:42 -0400
In-Reply-To: <CAAM7YAmht5FFTTFHrDUXAXHD5h5gzn1GrtEbHkQfbaoCwccG0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Zheng Yan. Your patch works as well. I trust others' code more than mine,
so please ignore the patch that I sent earlier.

On 24/08/11 16:04, Yan, Zheng wrote:
> On Wed, Aug 24, 2011 at 1:24 AM, Ang Way Chuang <wcang@sfc.wide.ad.jp> wrote:
>> This is what I found so far from debugging.
>>
>> The packet is not forwarded due to the failed checksum at
>> br_multicast.c:1533
>>
>>        case CHECKSUM_NONE:
>>                skb2->csum = 0;
>>                if (skb_checksum_complete(skb2))
>>                        goto out;
>>        }
>>
>> Contrary to description of commit ff9a57a6, when the patch of commit
>> ff9a57a6 is applied,
>> pskb_trim_rcsum is never called at all on my testbed. When commit ff9a57a6
>> is reverted,
>> pskb_trim_rcsum will be called. The difference is:
>>
>> with commit ff9a57a6,
>>   pskb_trim_rcsum is never called, br_multicast_ipv6_rcv returns -EINVAL
>> which causes
>>   br_handle_frame_finish to drop the packet
>>
>> without commit ff9a57a6,
>>   pskb_trim_rcsum is called overwriting err with 0. br_multicast_ipv6_rcv
>> still fails on the
>>   same line (skb_checksum_complete). But the difference is err is set to 0
>> this time. Thereby,
>>   allowing the packet to be forwarded.
>>
>> Anyway, I don't think the behaviour is correct with or without commit
>> ff9a57a6
>>
>>
> Looks like a checksum calculation bug. Please try below patch, Thanks.
>
> ---
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 2d85ca7..22d2d1a 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1520,16 +1520,23 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
>  		err = pskb_trim_rcsum(skb2, len);
>  		if (err)
>  			goto out;
> +		err = -EINVAL;
>  	}
>
> +	ip6h = ipv6_hdr(skb2);
> +
>  	switch (skb2->ip_summed) {
>  	case CHECKSUM_COMPLETE:
> -		if (!csum_fold(skb2->csum))
> +		if (!csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr, skb2->len,
> +					IPPROTO_ICMPV6, skb2->csum))
>  			break;
>  		/*FALLTHROUGH*/
>  	case CHECKSUM_NONE:
> -		skb2->csum = 0;
> -		if (skb_checksum_complete(skb2))
> +		skb2->csum = ~csum_unfold(csum_ipv6_magic(&ip6h->saddr,
> +							&ip6h->daddr,
> +							skb2->len,
> +							IPPROTO_ICMPV6, 0));
> +		if (__skb_checksum_complete(skb2))
>  			goto out;
>  	}
>
> ---
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
