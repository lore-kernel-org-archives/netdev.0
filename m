From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IP header identification field is zero, why?
Date: Wed, 07 Oct 2009 16:55:28 +0200
Message-ID: <4ACCABE0.2070804@gmail.com>
References: <f4f837ab0910070704k7a193be9i285573b423b96ba2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46185 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753394AbZJGO4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 10:56:07 -0400
In-Reply-To: <f4f837ab0910070704k7a193be9i285573b423b96ba2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thomas yang a =A8=A6crit :
> This is captured on my PC (Fedora 11, Linux=A3=A9
>=20
> [root@localhost ~]# tcpdump -i eth1 icmp -n -x
> tcpdump: verbose output suppressed, use -v or -vv for full protocol d=
ecode
> listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
> 17:02:39.025882 IP 192.168.1.64 > 192.168.1.1: ICMP echo request, id
> 25096, seq 1, length 64
> 	0x0000:  4500 0054 0000 4000 4001 b717 c0a8 0140
> ......
> 17:02:39.027866 IP 192.168.1.64 > 192.168.1.1: ICMP echo request, id
> 25096, seq 2, length 64
> 	0x0000:  4500 0054 0000 4000
>=20
> The  IP header 'identification' field is zero, why?
>=20
> I wrote a simple UDP server and UDP client programs, and captured som=
e
> packets, the IP identification is also zero.
>=20
> Should the host increase this field for each packet it sends?
>=20
>=20
> I captured some TCP packets, all of the IP identification are
> different, not zero.
>=20

Very good questions, this bothered me too.


ping sends "echo request" datagrams with DF set (Dont Fragment),
and ID=3D0, this is a user program building a packet from scratch.

When linux replies with a "echo reply", DF is not set and an ID is incl=
uded
in the answer, increasing at each packet.

About your UDP tests, DF is automatically set, and
I believe ID on DF frames is generated only for connected sockets.

cf include/net/ip.h

static inline void ip_select_ident(struct iphdr *iph, struct dst_entry =
*dst, struct sock *sk)
{
        if (iph->frag_off & htons(IP_DF)) {
                /* This is only to work around buggy Windows95/2000
                 * VJ compression implementations.  If the ID field
                 * does not change, they drop every other packet in
                 * a TCP stream using header compression.
                 */
                iph->id =3D (sk && inet_sk(sk)->daddr) ?
                                        htons(inet_sk(sk)->id++) : 0;
        } else
                __ip_select_ident(iph, dst, 0);
}

