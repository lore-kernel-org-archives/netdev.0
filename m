From: Brian Haley <Brian.Haley@hp.com>
Subject: Re: [GIT PULL net-2.6] IPv6 fixes.
Date: Tue, 03 Jun 2008 21:19:44 -0400
Message-ID: <4845EDB0.7030809@hp.com>
References: <20080604.094917.75827853.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:42255 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbYFDBWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 21:22:35 -0400
In-Reply-To: <20080604.094917.75827853.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> Please consider pulling following fixes on top of net-2.6 tree
> available at
> 	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git net-2.6-=
misc-20080604b
>=20
=2E..
> commit c878bc2da63acd3b80ba4cf428702f6e98c55b3c
> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date:   Mon Jun 2 18:45:23 2008 +0900
>=20
>     [IPv6]: Check outgoing interface even if source address is unspec=
ified.
>    =20
>     The outgoing interface index (ipi6_ifindex) in IPV6_PKTINFO
>     ancillary data, is not checked if the source address (ipi6_addr)
>     is unspecified.  If the ipi6_ifindex is the not-exist interface,
>     it should be fail and the errno should be set ENODEV.
>    =20
>     Based on patch from Shan Wei <shanwei@cn.fujitsu.com>.
>    =20
>     Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>=20
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index 94fa6ae..76d4ab4 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -535,27 +535,29 @@ int datagram_send_ctl(struct msghdr *msg, struc=
t flowi *fl,
>  				fl->oif =3D src_info->ipi6_ifindex;
>  			}
> =20
> -			addr_type =3D ipv6_addr_type(&src_info->ipi6_addr);
> +			if (fl->oif) {
> +				dev =3D dev_get_by_index(&init_net, fl->oif);
> +				if (!dev)
> +					return -ENODEV;
> +			}
> =20
> -			if (addr_type =3D=3D IPV6_ADDR_ANY)
> +			addr_type =3D ipv6_addr_type(&src_info->ipi6_addr);
> +			if (addr_type =3D=3D IPV6_ADDR_ANY) {
> +				if (dev)
> +					dev_put(dev);
>  				break;
> -
> -			if (addr_type & IPV6_ADDR_LINKLOCAL) {
> -				if (!src_info->ipi6_ifindex)
> -					return -EINVAL;
> -				else {
> -					dev =3D dev_get_by_index(&init_net, src_info->ipi6_ifindex);
> -					if (!dev)
> -						return -ENODEV;
> -				}
>  			}
> -			if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
> +
> +			if (((addr_type & IPV6_ADDR_LINKLOCAL) &&
> +			     !src_info->ipi6_ifindex) ||
> +			    !ipv6_chk_addr(&init_net, &src_info->ipi6_addr,

I think this !src_info->ipi6_ifindex here should be !fl->oif - that wil=
l=20
have been assigned correctly if it was zero and src_info->ipi6_ifindex=20
was passed-in, and is what we used to do the device lookup.

-Brian
