From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Problem with frame time stamping
Date: Tue, 13 Nov 2007 11:55:35 +0100
Message-ID: <473982A7.6040409@cosmosbay.com>
References: <2cbbd8de0711120742h35f27441p5f096e5e99e1d7dc@mail.gmail.com>	 <20071112174759.c2777ea2.dada1@cosmosbay.com>	 <2cbbd8de0711130207t82f2f46h9ee1b876a61bad6a@mail.gmail.com>	 <47397C0C.4060106@cosmosbay.com> <2cbbd8de0711130239j67127e1cxf312033aee1ddd5a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	netfilter-devel@vger.kernel.org, patrik.arlos@bth.se
To: Antoine Zen-Ruffinen <antoine.zen@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <2cbbd8de0711130239j67127e1cxf312033aee1ddd5a@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Antoine Zen-Ruffinen a =E9crit :
> This is exactly my problem : The driver of the network card I am usin=
g
> (see rt2x00.serialmonkey.com) do the minimum in the hardware interrup=
t
> (not filling skb->tstamp). Then netif_rx() is called later using a
> tasklet (also not filling skb->tstamp). As it seem to me (maybe I am
> wrong, if so please tell), the elapse time between the actual frame
> arrival and the time where netif_rx() do net_timestamp(skb) is not
> predicable !?
>
> Else, I would like to thank you to spend time helping me.
>
>
>  =20
A tasklet could process the skb much later than corresponding IRQ,=20
depending on various things
(other tasks/softirqs on system with higher priorities). So yes, it is=20
not predictable at all.

Usually it doesnt matter, but if your business depends on precise tstam=
ps,
then just do skb->tstamp =3D ktime_get_real(); in IRQ handler (but it w=
ill=20
slow it a bit,
depending on how fast is ktime_get_real() on the target machine)
netif_rx() wont overwrite it.

skb =3D dev_alloc_skb(desc.size + NET_IP_ALIGN);
if (!skb)
    return;
skb->tstamp =3D ktime_get_real(); /* do it before other copies */
skb_reserve(skb, NET_IP_ALIGN);
skb_put(skb, desc.size);
memcpy(skb->data, entry->data_addr, desc.size);

=2E..





