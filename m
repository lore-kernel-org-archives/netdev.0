From: Ari Savolainen <ari.m.savolainen@gmail.com>
Subject: Re: [PATCH] tg3: fix tigon3_dma_hwbug_workaround()
Date: Sat, 22 Oct 2011 16:30:47 +0300
Message-ID: <CAEbykaWnLaWHBLhE0gGgLK45t0Y6ykdSjTgrfHMJWFojsWVteA@mail.gmail.com>
References: <CAEbykaX4UPDBxOHmNr=dodaquSPjhPr-pLCcUn5hSu4-xLZy-g@mail.gmail.com>
	<20111020.155659.486754557434415381.davem@davemloft.net>
	<1319141125.2854.14.camel@edumazet-laptop>
	<20111020.161147.33259825921677777.davem@davemloft.net>
	<1319141867.2854.19.camel@edumazet-laptop>
	<CAEbykaWhh12pM2jRSzfGig=jeKhVWSdxfwuXHFvLTt14=BYTbA@mail.gmail.com>
	<CAJFZqHzWUsP7szrjVwmW5+HWRND3R4qxWcnK=bqbsgL6F7XGeA@mail.gmail.com>
	<CAEbykaVJneQ0ozUvYh2PRn-p_BowL4z4_4Y8EFCdO9mOsNX7OQ@mail.gmail.com>
	<1319265470.6180.13.camel@edumazet-laptop>
	<1319268338.6180.20.camel@edumazet-laptop>
	<CAEbykaVif3Mi50aDzY5p09iHC3DgtbYFQBGPAWiLa8hhyk5w8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: RongQing Li <roy.qing.li@gmail.com>,
	David Miller <davem@davemloft.net>, richardcochran@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEbykaVif3Mi50aDzY5p09iHC3DgtbYFQBGPAWiLa8hhyk5w8A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I tested the patch. It works. The panics are gone.

Thanks,
Ari

2011/10/22 Ari Savolainen <ari.m.savolainen@gmail.com>:
> I tried a similar patch earlier and got another panic with that. I wa=
s
> quite tired at that time and may have made a mistake. I'll test Eric'=
s
> patch either later today or tomorrow.
>
> Ari
>
> 2011/10/22 Eric Dumazet <eric.dumazet@gmail.com>:
>> Ari got kernel panics using tg3 NIC, and bisected to 2669069aacc9 "t=
g3:
>> enable transmit time stamping."
>>
>> This is because tigon3_dma_hwbug_workaround() might alloc a new skb =
and
>> free the original. We panic when skb_tx_timestamp() is called on fre=
ed
>> skb.
>>
>> Reported-by: Ari Savolainen <ari.m.savolainen@gmail.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>> =A0drivers/net/tg3.c | =A0 =A08 ++++----
>> =A01 file changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
>> index 4a1374d..6149dc5 100644
>> --- a/drivers/net/tg3.c
>> +++ b/drivers/net/tg3.c
>> @@ -6029,12 +6029,12 @@ static void tg3_tx_skb_unmap(struct tg3_napi=
 *tnapi, u32 entry, int last)
>>
>> =A0/* Workaround 4GB and 40-bit hardware DMA bugs. */
>> =A0static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct sk_buff *skb,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct sk_buff **pskb,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 u32 *entry, u32 *budget,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 u32 base_flags, u32 mss, u32 vlan)
>> =A0{
>> =A0 =A0 =A0 =A0struct tg3 *tp =3D tnapi->tp;
>> - =A0 =A0 =A0 struct sk_buff *new_skb;
>> + =A0 =A0 =A0 struct sk_buff *new_skb, *skb =3D *pskb;
>> =A0 =A0 =A0 =A0dma_addr_t new_addr =3D 0;
>> =A0 =A0 =A0 =A0int ret =3D 0;
>>
>> @@ -6076,7 +6076,7 @@ static int tigon3_dma_hwbug_workaround(struct =
tg3_napi *tnapi,
>> =A0 =A0 =A0 =A0}
>>
>> =A0 =A0 =A0 =A0dev_kfree_skb(skb);
>> -
>> + =A0 =A0 =A0 *pskb =3D new_skb;
>> =A0 =A0 =A0 =A0return ret;
>> =A0}
>>
>> @@ -6305,7 +6305,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_bu=
ff *skb, struct net_device *dev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0entry =3D tnapi->tx_prod;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0budget =3D tg3_tx_avail(tnapi);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tigon3_dma_hwbug_workaround(tnapi,=
 skb, &entry, &budget,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tigon3_dma_hwbug_workaround(tnapi,=
 &skb, &entry, &budget,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0base_flags, mss, vlan))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_unlock;
>> =A0 =A0 =A0 =A0}
>>
>>
>>
>
