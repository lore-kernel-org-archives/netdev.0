From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v3] net: Allow no-cache copy from user on transmit
Date: Thu, 31 Mar 2011 10:52:06 +0200
Message-ID: <AANLkTimJR+SxeoiZnyP3_vyuK7Z+w_2G2gtUp7pZGZiR@mail.gmail.com>
References: <alpine.DEB.2.00.1103302156270.17065@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:47375 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932977Ab1CaIw1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 04:52:27 -0400
Received: by qyk7 with SMTP id 7so3352753qyk.19
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 01:52:26 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1103302156270.17065@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/31 Tom Herbert <therbert@google.com>:
> This patch uses __copy_from_user_nocache (from skb_copy_to_page)
> on transmit to bypass data cache for a performance improvement.
> This functionality is configurable per device using ethtool.
[...]
> diff --git a/include/net/sock.h b/include/net/sock.h
> index da0534d..74ce586 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1401,6 +1401,11 @@ static inline int skb_copy_to_page(struct sock=
 *sk, char __user *from,
>                if (err)
>                        return err;
>                skb->csum =3D csum_block_add(skb->csum, csum, skb->len=
);
> +       } else if (sk->sk_route_caps & NETIF_F_NOCACHE_COPY) {
> +               if (!access_ok(VERIFY_READ, from, copy) ||
> +                   __copy_from_user_nocache(page_address(page) + off=
,
> +                                               from, copy))
> +                       return -EFAULT;
>        } else if (copy_from_user(page_address(page) + off, from, copy=
))
>                return -EFAULT;
>

BTW, the checks should take protocol into account. If, for example,
device has NOCACHE_COPY and CSUM_IPV4, but not CSUM_IPV6, then it will
take a hit for every IPv6 packet that needs checksumming in software.
Maybe this can be taken into account when sk_route_caps are set?

[...]
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 1a6e9eb..59b6ce9 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1407,7 +1407,7 @@ static int bond_compute_features(struct bonding=
 *bond)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0features &=3D ~(NETIF_F_ALL_CSUM | BOND_VL=
AN_FEATURES);
> - =C2=A0 =C2=A0 =C2=A0 features |=3D =C2=A0NETIF_F_GSO_MASK | NETIF_F=
_NO_CSUM;
> + =C2=A0 =C2=A0 =C2=A0 features |=3D =C2=A0NETIF_F_GSO_MASK | NETIF_F=
_NO_CSUM | NETIF_F_NOCACHE_COPY;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!bond->first_slave)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto done;
[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0b88eba..454abfd 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5444,6 +5444,13 @@ int register_netdevice(struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->features =
&=3D ~NETIF_F_GSO;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> + =C2=A0 =C2=A0 =C2=A0 /* Turn no cache copy off if HW isn't doing ch=
ecksum */
> + =C2=A0 =C2=A0 =C2=A0 if (!(dev->features & NETIF_F_ALL_CSUM) ||
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (dev->features & NETIF_F_NO_CSUM=
)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->wanted_featur=
es &=3D ~NETIF_F_NOCACHE_COPY;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->features &=3D=
 ~NETIF_F_NOCACHE_COPY;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Enable GRO and NETIF_F_HIGHDMA for vlan=
s by default,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * vlan_dev_init() will do the dev->featur=
es check, so these features
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * are enabled only if supported by underl=
ying device.

Why NO_CSUM is disabling NOCACHE_COPY? You combine those features in
bonding code anyway.

You didn't add netdev_fix_features() checks, so NOCACHE_COPY might be
enabled via ethtool after device is registered even if driver doesn't
support checksum offloads.

Best Regards,
Micha=C5=82 Miros=C5=82aw
