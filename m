From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 03:47:41 +0100
Message-ID: <49BF0F4D.7000409@cosmosbay.com>
References: <20090316233934.GD32111@codeblau.de> <49BF0A5A.2040501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felix von Leitner <felix-kernel@fefe.de>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45648 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbZCQCsN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 22:48:13 -0400
In-Reply-To: <49BF0A5A.2040501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley a =E9crit :
> Felix von Leitner wrote:
>> Here's an strace:
>>
>> socket(PF_INET6, SOCK_STREAM, IPPROTO_IP) =3D 3
>> fcntl(3, F_GETFL)                       =3D 0x2 (flags O_RDWR)
>> fcntl(3, F_SETFL, O_RDWR|O_NONBLOCK)    =3D 0
>> setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
>> bind(3, {sa_family=3DAF_INET6, sin6_port=3Dhtons(6969), inet_pton(AF=
_INET6, "::ffff:0.0.0.0", &sin6_addr), sin6_flowinfo=3D0, sin6_scope_id=
=3D0}, 28) =3D -1 EADDRNOTAVAIL (Cannot assign requested address)
>>
>> This is supposed to work, and it works on other operating systems, e=
ven
>> on Mac OS X.
>>
>> I think it used to work on Linux, too.
>>
>> I'm using 2.6.29-rc7 right now, but others have reported this not
>> working on distro kernels, too.
>=20
> I don't think this ever worked on Linux, from the very beginning of i=
net6_bind():
>=20
>         /* Check if the address belongs to the host. */
>         if (addr_type =3D=3D IPV6_ADDR_MAPPED) {
>                 v4addr =3D addr->sin6_addr.s6_addr32[3];
>                 if (inet_addr_type(net, v4addr) !=3D RTN_LOCAL) {
>                         err =3D -EADDRNOTAVAIL;
>                         goto out;
>                 }
>         } else {
>=20
> So if it's a mapped address, the lower 32-bits must contain a local a=
ddress.
> RFC 3493 doesn't specifically mention what to do with ::ffff:0.0.0.0,=
 so this
> looks like a gray area to me.
>=20
> So are you trying to get IPv4-only behavior out of this socket?  Seem=
s like the
> wrong way to go about it.

To me, section 3.7 of RFC 3493 is not gray. It is only refering to inte=
roperate
with IPV4 applications.=20
Ie *sending* UDP messages to IPV4 nodes, or *connect* to TCP IPV4 nodes=
=2E

So "::ffff:0.0.0.0" has no meaning to contact an IPV4 node, since 0.0.0=
=2E0 is not
a valid IPV4 address.

RFC 2373 is also clear

Part of RFC 3493 :

   Applications may use AF_INET6 sockets to open TCP connections to IPv=
4
   nodes, or send UDP packets to IPv4 nodes, by simply encoding the
   destination's IPv4 address as an IPv4-mapped IPv6 address, and
   passing that address, within a sockaddr_in6 structure, in the
   connect() or sendto() call.  When applications use AF_INET6 sockets
   to accept TCP connections from IPv4 nodes, or receive UDP packets
   from IPv4 nodes, the system returns the peer's address to the
   application in the accept(), recvfrom(), or getpeername() call using
   a sockaddr_in6 structure encoded this way.



RFC 2373 states :

 The IPv6 transition mechanisms [TRAN] include a technique for hosts
 and routers to dynamically tunnel IPv6 packets over IPv4 routing
 infrastructure.  IPv6 nodes that utilize this technique are assigned
 special IPv6 unicast addresses that carry an IPv4 address in the low-
 order 32-bits.  This type of address is termed an "IPv4-compatible
 IPv6 address" and has the format:

   |                80 bits               | 16 |      32 bits        |
   +--------------------------------------+--------------------------+
   |0000..............................0000|0000|    IPv4 address     |
   +--------------------------------------+----+---------------------+

 A second type of IPv6 address which holds an embedded IPv4 address is
 also defined.  This address is used to represent the addresses of
 IPv4-only nodes (those that *do not* support IPv6) as IPv6 addresses.
 This type of address is termed an "IPv4-mapped IPv6 address" and has
 the format:

   |                80 bits               | 16 |      32 bits        |
   +--------------------------------------+--------------------------+
   |0000..............................0000|FFFF|    IPv4 address     |
   +--------------------------------------+----+---------------------+



So using the "::ffff:0.0.0.0" as a local address for an=20
IPv6 socket is a paradox, since "IPv4-mapped IPV6 address"
are for IPV4-only nodes.

If you want to accept only IPV4 connections, why use AF_INET6 in the fi=
rst
place ?

Check how is implemented sctp_v6_cmp_addr() to see how expensive it
is to handle extensive ipv6 address comparisons...


/* Compare addresses exactly.
 * v4-mapped-v6 is also in consideration.
 */
static int sctp_v6_cmp_addr(const union sctp_addr *addr1,
                            const union sctp_addr *addr2)
{
        if (addr1->sa.sa_family !=3D addr2->sa.sa_family) {
                if (addr1->sa.sa_family =3D=3D AF_INET &&
                    addr2->sa.sa_family =3D=3D AF_INET6 &&
                    ipv6_addr_v4mapped(&addr2->v6.sin6_addr)) {
                        if (addr2->v6.sin6_port =3D=3D addr1->v4.sin_po=
rt &&
                            addr2->v6.sin6_addr.s6_addr32[3] =3D=3D
                            addr1->v4.sin_addr.s_addr)
                                return 1;
                }
                if (addr2->sa.sa_family =3D=3D AF_INET &&
                    addr1->sa.sa_family =3D=3D AF_INET6 &&
                    ipv6_addr_v4mapped(&addr1->v6.sin6_addr)) {
                        if (addr1->v6.sin6_port =3D=3D addr2->v4.sin_po=
rt &&
                            addr1->v6.sin6_addr.s6_addr32[3] =3D=3D
                            addr2->v4.sin_addr.s_addr)
                                return 1;
                }
                return 0;
        }
        if (!ipv6_addr_equal(&addr1->v6.sin6_addr, &addr2->v6.sin6_addr=
))
                return 0;
        /* If this is a linklocal address, compare the scope_id. */
        if (ipv6_addr_type(&addr1->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)=
 {
                if (addr1->v6.sin6_scope_id && addr2->v6.sin6_scope_id =
&&
                    (addr1->v6.sin6_scope_id !=3D addr2->v6.sin6_scope_=
id)) {
                        return 0;
                }
        }

        return 1;
}

