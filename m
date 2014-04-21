From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance problem with bond interface
Date: Mon, 21 Apr 2014 08:47:18 -0700
Message-ID: <1398095238.19600.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5e9e32bb-b60e-44d1-82be-28c4d6ec82d5@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org,
	Rama Nichanamatlu <rama.nichanamatlu@oracle.com>,
	Sergey Linetskiy <sergey.linetskiy@oracle.com>,
	Vadim Makhervaks <vadim.makhervaks@oracle.com>,
	Guangyu Sun <guangyu.sun@oracle.com>
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5e9e32bb-b60e-44d1-82be-28c4d6ec82d5@default>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-04-21 at 07:23 -0700, Venkat Venkatsubra wrote:
> We see a performance problem when the slaves of the bond=20
> don't support checksum offload features. What we see is
> tcp_sendmsg's skb_add_data_nocache ending up not using the
> csum_and_copy_from_user which would have computed the
> checksum while copying from user buffer to kernel buffer.
> Instead it computes later in dev_hard_start_xmit when it
> figures out the slave doesn't support checksum offload and
> ends up expensive .=20
>=20
> The bonding interface's "features" has  NETIF_F_HW_CSUM=20
> (or NETIF_F_NO_CSUM in 2.6.39) set which makes the=20
> stack think checksum need not be computed in software.
> /*
> * Check whether we can use HW checksum.
> */
> if (sk->sk_route_caps & NETIF_F_ALL_CSUM)
>      skb->ip_summed =3D CHECKSUM_PARTIAL;
>=20
> But later in dev_hard_start_xmit it finds out the slave does not
> support checksumming and decides to compute in software.
>=20
> /* If packet is not checksummed and device does not
> * support checksumming for this protocol, complete
> * checksumming here.
> */
> if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
>          skb_set_transport_header(skb,
>               skb_checksum_start_offset(skb));
>         if (!(features & NETIF_F_ALL_CSUM) &&
>              skb_checksum_help(skb))
>                goto out_kfree_skb;
> }
>=20
> We see this problem after this commit:
> commit 1742f183fc218798dab6fcf0ded25b6608fc0a48
> Author: Micha=C3=85<82> Miros=C3=85<82>aw <mirq-linux@rere.qmqm.pl>
> Date:   Fri Apr 22 06:31:16 2011 +0000
>=20
>     net: fix netdev_increment_features()
>=20
>     Simplify and fix netdev_increment_features() to conform to what i=
s
>     stated in netdevice.h comments about NETIF_F_ONE_FOR_ALL.
>     Include FCoE segmentation and VLAN-challedged flags in computatio=
n.
>=20
>     Signed-off-by: Micha=C3=85<82> Miros=C3=85<82>aw <mirq-linux@rere=
=2Eqmqm.pl>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> Prior to that the below code in netdev_increment_features was helping=
 in
> turning off NETIF_F_NO_CSUM on bond when the slaves don't support it:=
=20
> /* If device needs checksumming, downgrade to it. */
> if (all & NETIF_F_NO_CSUM && !(one & NETIF_F_NO_CSUM))
>         all ^=3D NETIF_F_NO_CSUM | (one & NETIF_F_ALL_CSUM);
>=20
> The slaves are Mellanox IB adapters. This is on x86_64 platform.
>=20
> Please let us know if you need any additional information.

Please CC patch author (I did), instead of sending this to hundred of
people (linux-kernel ??? netdev is more appropriate...)

Do these NIC really not support TX checksum ?

You did not provide kernel version you use.

Please also provide : (using a recent ethtool to get extended offload
info)

ethtool -k bond0 # or the bonding device name

ethtool -k eth1  # or the slave name

ethtool -i eth1

Thanks !
