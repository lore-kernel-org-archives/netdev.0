From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [**RFC**] [IPV6]: Support RFC3542 IPV6_PKTINFO socket option.
Date: Mon, 16 Jul 2007 11:31:28 -0400
Message-ID: <469B8F50.7000906@hp.com>
References: <20070716.234413.103263857.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:45131 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759424AbXGPPrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 11:47:00 -0400
In-Reply-To: <20070716.234413.103263857.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> Hello.
>=20
> This patch is just a tentative implementation of RFC3542 IPV6_PKTINFO
> sticky option, and is NOT intended to be applied so far.
>=20
> We need to check if this is okay in RFC POV, anyway.

ok.  comments from just the RFC pov.

> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index fe0f490..cc6e480 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -496,7 +496,55 @@ int datagram_recv_ctl(struct sock *sk, struct ms=
ghdr *msg, struct sk_buff *skb)
>  	return 0;
>  }
> =20
> -int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
> +int ip6_datagram_set_pktinfo(struct in6_pktinfo *src_info,
> +			     struct in6_addr *saddr,
> +			     struct flowi *fl)
> +{
> +	struct net_device *dev =3D NULL;
> +	int addr_type;
> +
> +	if (src_info->ipi6_ifindex) {
> +		if (fl->oif && src_info->ipi6_ifindex !=3D fl->oif)
> +			return -EINVAL;
> +		fl->oif =3D src_info->ipi6_ifindex;
> +	}
> +
> +	addr_type =3D ipv6_addr_type(&src_info->ipi6_addr);
> +
> +	if (addr_type =3D=3D IPV6_ADDR_ANY)
> +		return 0;

The above code will not fully clear the previously set option since
we are not guaranteed that fl->oif is 0.

   An   application can clear any sticky IPV6_PKTINFO option by doing a
   "regular" setsockopt with ipi6_addr being in6addr_any and
   ipi6_ifindex being zero.



> +
> +	if (saddr) {
> +		if (!ipv6_addr_any(saddr))
> +			return -EINVAL;
> +		if (!ipv6_addr_equal(&src_info->ipi6_addr, saddr))
> +			return -EINVAL;
> +	}
  =20
Not following the following text:
   If the ipi6_addr member is not the
   unspecified address, but the socket has already bound a source
   address, then the ipi6_addr value overrides the already-bound source
   address for this output operation only.


> +
> +	if (addr_type & IPV6_ADDR_LINKLOCAL) {
> +		if (!src_info->ipi6_ifindex)
> +			return -EINVAL;
> +		else {
> +			dev =3D dev_get_by_index(src_info->ipi6_ifindex);
> +			if (!dev)
> +				return -ENODEV;
> +		}
> +	}
> +	if (!ipv6_chk_addr(&src_info->ipi6_addr, dev, 0)) {
> +		if (dev)
> +			dev_put(dev);
> +		return -EINVAL;
> +	}
> +	if (dev)
> +		dev_put(dev);
> +
> +	ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);

Additional checks needed for:

   IPV6_PKTINFO can also be used as a sticky option for specifying the
   socket's default source address.  However, the ipi6_addr member must
   be the unspecified address for TCP sockets, because it is not
   possible to dynamically change the source address of a TCP
   connection.  When the IPV6_PKTINFO option is specified for a TCP
   socket with a non-unspecified address, the call will fail.  This
   restriction should be applied even before the socket binds a specifi=
c
   address.


Also, see Section 6.7 for the correct interface selection rules that sh=
ould
be applied as well.  Not sure if these are implemented anywhere.

Thanks
-vlad
