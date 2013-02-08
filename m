From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] macvlan: add a salt to mc_hash()
Date: Thu, 7 Feb 2013 21:07:11 -0800
Message-ID: <CANP3RGfFpHsQN_G6cR79M3HVMK--2Le_o2UqVcU48YJmCx8GQg@mail.gmail.com>
References: <1360291262.28557.89.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:52047 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926Ab3BHFHN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 00:07:13 -0500
Received: by mail-pa0-f43.google.com with SMTP id bh2so1871669pad.30
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 21:07:12 -0800 (PST)
In-Reply-To: <1360291262.28557.89.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>

On Thu, Feb 7, 2013 at 6:41 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> From: Eric Dumazet <edumazet@google.com>
>
> Some multicast addresses are common to all macvlans,
> so if a multicast message has a hash value collision, we
> have to deliver a copy to all macvlans, adding significant
> latency and possible packet drops if netdev_max_backlog
> limit is hit.
>
> Having a per macvlan hash function permits to reduce the
> impact of hash collisions.
>
> Suggested-by: Maciej =C5=BBenczykowski <maze@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> Should be applied after
>   "macvlan: broadcast addr should be part of mc_filter"
>
>  drivers/net/macvlan.c |   17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index ce7c926..e4b8078 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -127,10 +127,18 @@ static int macvlan_broadcast_one(struct sk_buff=
 *skb,
>         return vlan->receive(skb);
>  }
>
> -static unsigned int mc_hash(const unsigned char *addr)
> +static u32 macvlan_hash_mix(const struct macvlan_dev *vlan)
> +{
> +       return (u32)(((unsigned long)vlan) >> L1_CACHE_SHIFT);
> +}
> +
> +
> +static unsigned int mc_hash(const struct macvlan_dev *vlan,
> +                           const unsigned char *addr)
>  {
>         u32 val =3D __get_unaligned_cpu32(addr + 2);
>
> +       val ^=3D macvlan_hash_mix(vlan);
>         return hash_32(val, MACVLAN_MC_FILTER_BITS);
>  }
>
> @@ -145,7 +153,7 @@ static void macvlan_broadcast(struct sk_buff *skb=
,
>         struct sk_buff *nskb;
>         unsigned int i;
>         int err;
> -       unsigned int hash =3D mc_hash(eth->h_dest);
> +       unsigned int hash;
>
>         if (skb->protocol =3D=3D htons(ETH_P_PAUSE))
>                 return;
> @@ -155,6 +163,7 @@ static void macvlan_broadcast(struct sk_buff *skb=
,
>                         if (vlan->dev =3D=3D src || !(vlan->mode & mo=
de))
>                                 continue;
>
> +                       hash =3D mc_hash(vlan, eth->h_dest);
>                         if (!test_bit(hash, vlan->mc_filter))
>                                 continue;
>                         nskb =3D skb_clone(skb, GFP_ATOMIC);
> @@ -424,10 +433,10 @@ static void macvlan_set_mac_lists(struct net_de=
vice *dev)
>
>                 bitmap_zero(filter, MACVLAN_MC_FILTER_SZ);
>                 netdev_for_each_mc_addr(ha, dev) {
> -                       __set_bit(mc_hash(ha->addr), filter);
> +                       __set_bit(mc_hash(vlan, ha->addr), filter);
>                 }
>
> -               __set_bit(mc_hash(dev->broadcast), filter);
> +               __set_bit(mc_hash(vlan, dev->broadcast), filter);
>
>                 bitmap_copy(vlan->mc_filter, filter, MACVLAN_MC_FILTE=
R_SZ);
>         }
>
>
