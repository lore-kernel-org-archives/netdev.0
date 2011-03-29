From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Handle gso packets in dev_forward_skb
Date: Tue, 29 Mar 2011 14:02:58 -0700
Message-ID: <m1aagdhc71.fsf@fess.ebiederm.org>
References: <m1wrjsi2tf.fsf@fess.ebiederm.org>
	<1300743744.2837.7.camel@edumazet-laptop>
	<m1hbawi15z.fsf@fess.ebiederm.org>
	<20110327.180922.59673799.davem@davemloft.net>
	<1301340048.2506.13.camel@edumazet-laptop> <4D91D693.1070202@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	greearb@candelatech.com, arnd@arndb.de, kaber@trash.net
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39217 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754431Ab1C2VDH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 17:03:07 -0400
In-Reply-To: <4D91D693.1070202@free.fr> (Daniel Lezcano's message of "Tue, 29
	Mar 2011 14:54:43 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano <daniel.lezcano@free.fr> writes:

> On 03/28/2011 09:20 PM, Eric Dumazet wrote:
>> Le dimanche 27 mars 2011 =C3=A0 18:09 -0700, David Miller a =C3=A9cr=
it :
>>> From: ebiederm@xmission.com (Eric W. Biederman)
>>> Date: Mon, 21 Mar 2011 15:00:56 -0700
>>>
>>>> Eric Dumazet<eric.dumazet@gmail.com>  writes:
>>>>
>>>>> Hmm, did you follow http://patchwork.ozlabs.org/patch/86815/
>>>>> discussion ?
>>>> No.  It seems I missed it, but I do have the same problem, and
>>>> essentially the same fix.
>>> Can someone work on getting this straightened out and resubmit the
>>> final patch so I can apply something?
>>>
>> Apparently Daniel is busy.
>
> Yes, sorry for the delay.
> I would like to fix it but I am not sure to understand the different =
solutions
> proposed.
>
> On 03/28/2011 09:20 PM, Eric Dumazet wrote:
>> Le dimanche 27 mars 2011 =C3=A0 18:09 -0700, David Miller a =C3=A9cr=
it :
>>> From: ebiederm@xmission.com (Eric W. Biederman)
>>> Date: Mon, 21 Mar 2011 15:00:56 -0700
>>>
>>>> Eric Dumazet<eric.dumazet@gmail.com>  writes:
>>>>
>>>>> Hmm, did you follow http://patchwork.ozlabs.org/patch/86815/
>>>>> discussion ?
>>>> No.  It seems I missed it, but I do have the same problem, and
>>>> essentially the same fix.
>>> Can someone work on getting this straightened out and resubmit the
>>> final patch so I can apply something?
>>>
>> Apparently Daniel is busy.
>
> Yes, sorry for the delay.
> I would like to fix it, but my knowledge in limited on offloading.
>
> I did the following patch, it fixes the problem. If it looks good I c=
an resend
> it in patch format:

It looks fine to me.  I would resubmit it so that if anyone else has
complaints they will be jolted into looking at the patch again.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>


Eric



>
> Index: net-2.6/net/core/dev.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-2.6.orig/net/core/dev.c 2011-03-29 14:50:00.047646000 +0200
> +++ net-2.6/net/core/dev.c      2011-03-29 14:50:35.587646000 +0200
> @@ -1454,6 +1454,27 @@ static inline void net_timestamp_check(s
>                 __net_timestamp(skb);
>  }
>
> +static inline bool is_skb_forwardable(struct net_device *dev,
> +                                     struct sk_buff *skb)
> +{
> +       unsigned int len;
> +
> +       if (!(dev->flags & IFF_UP))
> +               return false;
> +
> +       len =3D dev->mtu + dev->hard_header_len + VLAN_HLEN;
> +       if (skb->len <=3D len)
> +               return true;
> +
> +       /* if TSO is enabled, we don't care about the length as the p=
acket
> +        * could be forwarded without being segmented before
> +        */
> +       if (skb_is_gso(skb))
> +               return true;
> +
> +       return false;
> +}
> +
>  /**
>   * dev_forward_skb - loopback an skb to another netif
>   *
> @@ -1477,8 +1498,7 @@ int dev_forward_skb(struct net_device *d
>         skb_orphan(skb);
>         nf_reset(skb);
>
> -       if (unlikely(!(dev->flags & IFF_UP) ||
> -                    (skb->len > (dev->mtu + dev->hard_header_len +
> VLAN_HLEN)))) {
> +       if (unlikely(!is_skb_forwardable(dev, skb))) {
>                 atomic_long_inc(&dev->rx_dropped);
>                 kfree_skb(skb);
>                 return NET_RX_DROP;
