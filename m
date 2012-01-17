From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] ipv6: dst_allfrag() not taken into account by TCP
Date: Tue, 17 Jan 2012 19:15:11 +0100
Message-ID: <1326824111.2259.54.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120117.123405.2126678655326303069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tore@fud.no
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62678 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959Ab2AQSPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 13:15:15 -0500
Received: by wgbdq11 with SMTP id dq11so2239594wgb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 10:15:14 -0800 (PST)
In-Reply-To: <20120117.123405.2126678655326303069.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 janvier 2012 =C3=A0 12:34 -0500, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 17 Jan 2012 17:28:19 +0100
>=20
> > It seems that dst_allfrag() will force us to use ip6_fragment() and
> > reduce effective MSS to :
>=20
> Don't use TCP with forced fragmentation.
>=20
> Use path MTU discovery or an artificially reduced route MTU on paths
> where ICMP blocking is causing problems.

We receive a correct ICMP message and we process it correctly.

It should work without fragments, if we hadnt a bug, when we hit the
minimum IPv6 MTU (1280) ?

Problem is we build too large TCP frames (by 8 bytes) and they must be
fragmented in ip6_finish_output(), wasting cpu and network bandwidth.

We do the following in tcp_mtu_to_mss()

mss_now =3D pmtu - icsk->icsk_af_ops->net_header_len - sizeof(struct tc=
phdr);

(net_header_len being a constant value : sizeof(struct ipv6hdr) for IPv=
6)

=46or IPv6, effective network header len would be either :

1)	sizeof(struct ipv6hdr)=20
2)	sizeof(struct ipv6hdr) + sizeof(frag_hdr)

We could change net_header_len to be a method, and for ipv6 do :

static unsigned int ipv6_net_header_len(struct sock *sk)
{
	const struct dst_entry *dst =3D __sk_dst_get(sk);

	return sizeof(struct ipv6hdr) +
		(dst && dst_allfrag(dst)) ? sizeof(struct frag_hdr) : 0;=20
}

/* for ipv4 : */
static unsigned int ipv4_net_header_len(struct sock *sk)
{
	return sizeof(struct iphdr);
}
