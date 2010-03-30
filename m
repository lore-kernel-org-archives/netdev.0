From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP path MTU discovery
Date: Tue, 30 Mar 2010 08:06:08 +0200
Message-ID: <1269929168.1958.94.camel@edumazet-laptop>
References: <1269561751.2891.8.camel@ilion>
	 <877how25kx.fsf@basil.nowhere.org> <4BB0DCF6.9020401@hp.com>
	 <20100329201431.GH20695@one.firstfloor.org>
	 <20100329205035.GA32656@laped.iglesias.mooo.com> <4BB11510.9000302@hp.com>
	 <1269898152.1958.86.camel@edumazet-laptop>
	 <E1829B60731D1740BB7A0626B4FAF0A649E05EAAB5@XCH-NW-01V.nw.nos.boeing.com>
	 <20100330052044.GJ20695@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Edgar E. Iglesias" <edgar.iglesias@gmail.com>,
	Glen Turner <gdt@gdt.id.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:46645 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755525Ab0C3GGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 02:06:12 -0400
Received: by mail-bw0-f209.google.com with SMTP id 1so4087215bwz.21
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 23:06:11 -0700 (PDT)
In-Reply-To: <20100330052044.GJ20695@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 mars 2010 =C3=A0 07:20 +0200, Andi Kleen a =C3=A9crit :
> On Mon, Mar 29, 2010 at 04:38:49PM -0700, Templin, Fred L wrote:
> > > 1) 4096 bytes UDP messages... well...
> > > 2) Using regular TCP for DNS servers... well...
> > >=20
> > > I believe some guys were pushing TCPCT (Cookie Transactions) for =
this
> > > case ( http://tools.ietf.org/html/draft-simpson-tcpct-00.html )
> > >=20
> > > (That is, using an enhanced TCP for long DNS queries... but not o=
nly for
> > > DNS...)
> >=20
> > IPv4 gets by this by setting DF=3D0 in the IP header, and
> > lets the network fragment the packet if necessary. IPv6 can
> > similarly get by this by having the sending host fragment
> > the large UDP packet into IPv6 fragments no longer than
> > 1280 bytes each.
>=20
> That's true -- in theory the UDP app unwilling/unable to do proper pt=
mudisc=20
> could set the path mtu to 1280 + header and still keep path mtu disco=
very off=20
> and then just fragment.=20
>=20
> Drawback would be of course suboptimal network use with too small MTU=
s
> in the common case.
>=20
> Right now there is no right socket option to set the path mtu. We
> have a IP_MTU option, but it only works for getting the MTU.
> That's because the PMTU is in the routing cache entry and shared
> by multiple sockets. Presumably one could add a special case
> with an MTU in the socket overriding the one in the destination entry=
=2E

We have IP_MTU_DISCOVER option with four existing values



/* IP_MTU_DISCOVER values */
#define IP_PMTUDISC_DONT                0       /* Never send DF frames=
 */
#define IP_PMTUDISC_WANT                1       /* Use per route hints =
 */
#define IP_PMTUDISC_DO                  2       /* Always DF           =
 */
#define IP_PMTUDISC_PROBE               3       /* Ignore dst pmtu     =
 */

We might add a fifth value (or open full range) and change=20

static inline int ip_skb_dst_mtu(struct sk_buff *skb)
{
        struct inet_sock *inet =3D skb->sk ? inet_sk(skb->sk) : NULL;

        return (inet && inet->pmtudisc =3D=3D IP_PMTUDISC_PROBE) ?
               skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
}

->

static inline int ip_skb_dst_mtu(struct sk_buff *skb)
{
	if (skb->sk) {
		struct inet_sock *inet =3D inet_sk(skb->sk);

		if (inet->pmtudisc > IP_PMTUDISC_PROBE)
			return inet->pmtudisc;
		if (inet->pmtudisc =3D=3D IP_PMTUDISC_PROBE)
			return skb_dst(skb)->dev->mtu;
	}
	return dst_mtu(skb_dst(skb));
}



