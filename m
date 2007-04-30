From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: many sockets, slow sendto
Date: Mon, 30 Apr 2007 14:47:15 +0200
Message-ID: <20070430144715.b0c03c83.dada1@cosmosbay.com>
References: <460064C6.5030302@cosmosbay.com>
	<4601ADD8.8040500@cosmosbay.com>
	<20070430.002643.68156452.davem@davemloft.net>
	<20070430.195604.26499662.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, zacco@fw.hu, baruch@ev-en.org,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:48696 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423212AbXD3MrU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 08:47:20 -0400
In-Reply-To: <20070430.195604.26499662.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Apr 2007 19:56:04 +0900 (JST)
YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <yoshfuji@linu=
x-ipv6.org> wrote:

> In article <20070430.002643.68156452.davem@davemloft.net> (at Mon, 30=
 Apr 2007 00:26:43 -0700 (PDT)), David Miller <davem@davemloft.net> say=
s:
>=20
> > > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> >=20
> > Eric, I've applied this, thanks again.
> >=20
> > Could I trouble you to cook up an ipv6 version of this patch?
>=20
> Here's my tentative version.  Not tested.
> Dave, Eric, could you double-check this, please?

Hi Yoshifuji

Your patch seems good, thank you.

I have two minor comments about udp6_hash_port_and_addr()

Compiler knows that const 'struct in6_addr *addr' is NULL when we call =
udp6_hash_port_and_addr(..., NULL)

But not when we pass saddr :  udp6_hash_port_and_addr(port, saddr)

So to avoid one conditional branch, you could use udp6_hash_port_and_ad=
dr() only once, with addr not NULL :

Also, I am not sure we need to use all 128 bits of IPV6 address, maybe =
the 64 low order bits are enough ?

static inline unsigned int udp6_hash_port_and_addr(__u16 port,
						  const struct in6_addr *addr)
{
	u32 hash =3D (__force u32) addr->s6_addr32[2] ^
		   (__force u32) addr->s6_addr32[3];
	hash ^=3D hash >> 16;
	hash ^=3D hash >> 8;

	return port ^ hash;
}

static inline unsigned int udp6_hash_wildcard(__u16 port,
					      const struct in6_addr *addr)
{
	return port;
}

=2E..


	hash =3D udp6_hash_port_and_addr(ntohs(dport), saddr);
	hashwild =3D udp6_hash_wildcard(ntohs(dport), saddr);

Eric
