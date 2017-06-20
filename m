From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_en: don't set CHECKSUM_COMPLETE on SCTP
 packets
Date: Tue, 20 Jun 2017 10:52:02 +0300
Message-ID: <0132c295-3134-94f1-1aea-8574cdb7d344@gmail.com>
References: <eed45546c689875c5e57a7716fc1f06089f6b7d3.1497621301.git.dcaratti@redhat.com>
 <bc64924a-a9cd-737e-b63d-27011445d230@mellanox.com>
 <1497891850.2600.9.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>
To: Davide Caratti <dcaratti@redhat.com>,
        Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35844 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750863AbdFTHwF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 03:52:05 -0400
Received: by mail-wr0-f196.google.com with SMTP id 77so16306061wrb.3
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 00:52:05 -0700 (PDT)
In-Reply-To: <1497891850.2600.9.camel@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 19/06/2017 8:04 PM, Davide Caratti wrote:
> hello Tariq,
> On Sun, 2017-06-18 at 14:10 +0300, Tariq Toukan wrote:
>>> @@ -624,12 +632,13 @@ static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, void *va,
>>>                 hdr += sizeof(struct vlan_hdr);
>>>         }
>>>     
>>> -     if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV4))
>>> -             get_fixed_ipv4_csum(hw_checksum, skb, hdr);
>>> +     if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV4)) &&
>>> +         (unlikely(get_fixed_ipv4_csum(hw_checksum, skb, hdr))))
>>
>> No! The lazy evaluation trick is wrong here.
>> This way you'll end up going almost always to the else (ipv6) for the
>> wrong reason.
> 
> you are right! thanks for spotting this.
> 
>>> +             return -1;
>>>     #if IS_ENABLED(CONFIG_IPV6)
>>> -     else if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV6))
>>> -             if (unlikely(get_fixed_ipv6_csum(hw_checksum, skb, hdr)))
>>> -                     return -1;
>>> +     else if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV6)) &&
>>> +              (unlikely(get_fixed_ipv6_csum(hw_checksum, skb, hdr))))
>>> +             return -1;
>>
>> Let's not change this, might cause future bugs, similarly to the one above.
>>>     #endif
>>>         return 0;
>>>     }
> 
> maybe we can avoid adding braces, remove that 'else' keyword and the nested 'if',
> thus saving one line, given that check_csum() returns the same set of values as
> get_fixed_ipv{4,6}_checksum(), with the same meaning (-1 => go with CHECKSUM_NONE,
> 0 => go with CHECKSUM_COMPLETE).
> 
Yeah this sounds good.

> ---- >8 ----
> @@ -625,11 +633,10 @@ static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, void *va,
>   	}
>   
>   	if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV4))
> -		get_fixed_ipv4_csum(hw_checksum, skb, hdr);
> +		return get_fixed_ipv4_csum(hw_checksum, skb, hdr);
>   #if IS_ENABLED(CONFIG_IPV6)
> -	else if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV6))
> -		if (unlikely(get_fixed_ipv6_csum(hw_checksum, skb, hdr)))
> -			return -1;
> +	if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV6))
> +		return get_fixed_ipv6_csum(hw_checksum, skb, hdr);
>   #endif
>   	return 0;
>   }
> ---- 8< ----

Looks good to me.

> 
> I will test and repost a v2 with this modification, unless you have any
> objections. Thank you in advance!
> regards
> --
> davide
> 
> 
> 
Thank you Davide.

Regards,
Tariq
