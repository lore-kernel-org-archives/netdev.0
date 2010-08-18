From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Wed, 18 Aug 2010 15:03:46 +0200
Message-ID: <1282136626.2194.68.camel@edumazet-laptop>
References: <E1OlhmZ-0002l6-00.xeb-mail-ru@f45.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57752 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627Ab0HRNDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 09:03:51 -0400
Received: by wwi17 with SMTP id 17so807269wwi.1
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 06:03:50 -0700 (PDT)
In-Reply-To: <E1OlhmZ-0002l6-00.xeb-mail-ru@f45.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 ao=C3=BBt 2010 =C3=A0 16:30 +0400, Dmitry Kozlov a =C3=A9=
crit :
> This patch contains:
> 1. pptp driver
> 2. gre demultiplexer driver for demultiplexing gre packets with diffe=
rent gre version
>    so ip_gre and pptp may coexists
> 3. ip_gre modification
> 4. other stuff
>=20
> Changes from patch v3:
> 1. using rcu instead of read-write lock in gre module
> 2. fixed coding style issues
>=20

Hmm. You left a synchronize_rcu() call in add_chan() but this is not
necessary. Please remove it or explain why you think it is needed.

synchronize_rcu(); in del_chan() is now fine, thanks.


You use a mutex for gre_proto_lock, but you dont need a mutex, please
use a spinlock like I suggested. I would have said 'use a mutex' if if
was needed, you can trust me.

A mutex is needed if you can sleep while holding the lock, this is not
the case here. A spinlock is faster and reduces to no-op on !SMP

Also, please remove the synchronize_rcu() call from gre_add_protocol() =
:
It is not needed at all, like in add_chan().

(You dont have to wait for a RCU grace period when adding something,
only when removing from a data structure)

You sometime have too many tabulations, check :



> +	{
> +		struct flowi fl =3D { .oif =3D 0,
> +				    .nl_u =3D {

ip4_u has one excess level
> +							.ip4_u =3D {
> +								.daddr =3D opt->dst_addr.sin_addr.s_addr,
> +								.saddr =3D opt->src_addr.sin_addr.s_addr,
> +								.tos =3D RT_TOS(0) } },
> +				    .proto =3D IPPROTO_GRE };
> +		err =3D ip_route_output_key(&init_net, &rt, &fl);
> +		if (err)
> +			goto tx_error;
> +	}
> +	tdev =3D rt->u.dst.dev;
> +
> +	max_headroom =3D LL_RESERVED_SPACE(tdev) + sizeof(*iph) + sizeof(*h=
dr) + 2;
> +
> +=09

same on this if clause. why so many leading spaces ?

> +	if (
> +					/* version should be 1 */
> +					((header->ver & 0x7F) !=3D PPTP_GRE_VER) ||
> +					/* PPTP-GRE protocol for PPTP */
> +					(ntohs(header->protocol) !=3D PPTP_GRE_PROTO) ||
> +					/* flag C should be clear   */
> +					PPTP_GRE_IS_C(header->flags) ||
> +					/* flag R should be clear   */
> +					PPTP_GRE_IS_R(header->flags) ||
> +					/* flag K should be set     */
> +					(!PPTP_GRE_IS_K(header->flags)) ||
> +					/* routing and recursion ctrl =3D 0  */
> +					((header->flags&0xF) !=3D 0))
> +					/* if invalid, discard this packet */
> +		goto drop;
> +
> +
> +	po =3D lookup_chan(htons(header->call_id), iph->saddr);

=2E..

> +
> +	{
> +		struct flowi fl =3D {
> +				    .nl_u =3D {

ditto

> +							.ip4_u =3D {
> +								.daddr =3D opt->dst_addr.sin_addr.s_addr,
> +								.saddr =3D opt->src_addr.sin_addr.s_addr,
> +								.tos =3D RT_CONN_FLAGS(sk) } },
> +				    .proto =3D IPPROTO_GRE };
> +		security_sk_classify_flow(sk, &fl);
> +		if (ip_route_output_key(&init_net, &rt, &fl)) {
> +			error =3D -EHOSTUNREACH;
> +			goto end;
> +		}
> +		sk_setup_caps(sk, &rt->u.dst);
> +	}

Thanks


