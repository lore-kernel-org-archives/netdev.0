From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] bonding: allow TSO being set on bonding master
Date: Wed, 15 May 2013 21:31:10 -0700
Message-ID: <CAHo-Oozt9tmfhhFHj0o+bGfRevcZw+YD6PpHAr-U_S76AbC+2A@mail.gmail.com>
References: <1368654065.4519.53.camel@edumazet-glaptop>
	<CAHXqBF+r3wnWY+hveYjVBNwbVYdiDF4mOj1UmbKeH3OYo6kz6Q@mail.gmail.com>
	<1368659900.4519.57.camel@edumazet-glaptop>
	<1368660613.4519.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:43685 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab3EPEbL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 00:31:11 -0400
Received: by mail-vc0-f182.google.com with SMTP id ia10so2456236vcb.13
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 21:31:10 -0700 (PDT)
In-Reply-To: <1368660613.4519.60.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think it should always be possible to enable both TSO and GSO on the
bond master - regardless of what the slaves support and/or currently
have enabled.
At the last moment as we're passing a packet to a slave, we should
check whether the slave will like it and if not GSO it.
This means TSO or GSO enabled on the master can effectively almost
force (or force emulation of) GSO on slaves.
Even if the slaves themselves don't support GSO.

There's a lot more room for argument with regards to the default state
of TSO/GSO on the master.
I would argue for default to on for both.
One could argue that if none of the slaves support GSO or TSO then
maybe it should default to off, but I don't buy that.

I don't really understand the point of passing GSO/TSO up from the
slaves to the master.
Although the maximum size and/or number of segs for a packet probably
needs to be propagated from TSO capable devices,
unless one were to add a "split big GSO packet into smaller (but still
larger than mtu) TSO packets" step as well.

On Wed, May 15, 2013 at 4:30 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Wed, 2013-05-15 at 16:18 -0700, Eric Dumazet wrote:
>> On Thu, 2013-05-16 at 00:55 +0200, Micha=C5=82 Miros=C5=82aw wrote:
>>
>> > Have you tried adding it to NETIF_F_ONE_FOR_ALL set? 'Team' and br=
idge
>> > could then also use it.
>>
>> Good point, I am testing this, thanks !
>>
>
> Hmm, this doesnt work.
>
>
> # ethtool -k bond0 | grep tcp-segmentation-offload
> tcp-segmentation-offload: off
> # ethtool -K bond0 tso on
> # ethtool -k bond0 | grep tcp-segmentation-offload
> tcp-segmentation-offload: off
>
> Do you have something different in mind ?
>
> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_f=
eatures.h
> index 77f5202..c8d9db0 100644
> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h
> @@ -132,7 +132,7 @@ enum {
>   * for all in netdev_increment_features.
>   */
>  #define NETIF_F_ONE_FOR_ALL    (NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_R=
OBUST | \
> -                                NETIF_F_SG | NETIF_F_HIGHDMA |      =
   \
> +                                NETIF_F_SG | NETIF_F_HIGHDMA | NETIF=
_F_ALL_TSO |       \
>                                  NETIF_F_FRAGLIST | NETIF_F_VLAN_CHAL=
LENGED)
>  /*
>   * If one device doesn't support one of these features, then disable=
 it
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
