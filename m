From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: use skb_get_rxhash()
Date: Tue, 24 Aug 2010 21:53:49 +0800
Message-ID: <AANLkTi=AkO0hUZ7o3uwX5zrxeiLi1TsLzu5QL=pUrAju@mail.gmail.com>
References: <1282643558-20866-1-git-send-email-xiaosuo@gmail.com> <1282645262.2477.64.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60631 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241Ab0HXNyK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 09:54:10 -0400
Received: by wyb35 with SMTP id 35so494076wyb.19
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 06:54:09 -0700 (PDT)
In-Reply-To: <1282645262.2477.64.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 24, 2010 at 6:21 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 24 ao=FBt 2010 =E0 17:52 +0800, Changli Gao a =E9crit :
>> Although it is rare the line contains skb->rxhash is executed:
>>
>> =A0* The forwarded skbs should have the the rx queue recoreded.
>> =A0* The local generated skbs should have non zero sk_hash in most o=
f cases.
>>
>> when it is executed, a non zero rxhash will be better.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> =A0net/core/dev.c | =A0 =A02 +-
>> =A01 file changed, 1 insertion(+), 1 deletion(-)
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 859e30f..ea041fd 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2034,7 +2034,7 @@ u16 skb_tx_hash(const struct net_device *dev, =
const struct sk_buff *skb)
>> =A0 =A0 =A0 if (skb->sk && skb->sk->sk_hash)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash =3D skb->sk->sk_hash;
>> =A0 =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 hash =3D (__force u16) skb->protocol ^ skb=
->rxhash;
>> + =A0 =A0 =A0 =A0 =A0 =A0 hash =3D (__force u16) skb->protocol ^ skb=
_get_rxhash(skb);
>> =A0 =A0 =A0 hash =3D jhash_1word(hash, hashrnd);
>>
>> =A0 =A0 =A0 return (u16) (((u64) hash * dev->real_num_tx_queues) >> =
32);
>> --
>
> Instead of adding hacks and growing kernel code (considering your
> previous patch), could we sit down and fix existing code, if really
> needed ?
>
> Spirit of existing code is that tcp/udp sockets have a sk_hash field,
> and this feeds skb->rxhash in transmit path.
>
> (check commit 87fd308c for an example of a fix)
>

Thanks. Got it. skb->rxhash should be only used when skb->sk is NULL,
and skb->rxhash should save the value copied from skb->sk->sk_hash at
that time.

       if (skb->sk && skb->sk->sk_hash)
               hash =3D skb->sk->sk_hash;

However, do we really need to check if skb->sk->sk_hash is zero? It is
a rare case, and this check may mislead someone to think a non zero
sk_hash means that sk_hash is set.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
