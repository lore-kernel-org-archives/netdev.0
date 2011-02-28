From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: ICMP reply uses wrong source address as destination
Date: Mon, 28 Feb 2011 17:33:48 +0100 (CET)
Message-ID: <alpine.LRH.2.00.1102281733070.4359@twin.jikos.cz>
References: <AANLkTi=2hEK9rR2h1hzWtud0DdJU5A4d9rBYD6aTLFx-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Anders Nilsson Plymoth <lml@telhoc.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=2hEK9rR2h1hzWtud0DdJU5A4d9rBYD6aTLFx-@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[ adding netdev@ to CC ]

On Mon, 28 Feb 2011, Anders Nilsson Plymoth wrote:

> Dear linux kernel enthusiasts,
>=20
> I came upon an issue where ICMP reply packets were issued towards the
> IP address of the=A0receiving interface, rather than the source IP
> address.
> Looking at the kernel code, I saw that this is caused by the followin=
g
> line in net/ipv4/icmp.c function icmp_reply:
>=20
> daddr =3D ipc.addr =3D rt->rt_src;
>=20
> For most cases the=A0original=A0line of code is ok, but in some situa=
tions
> doesn't arrive to the kernel from the network device, but through som=
e
> other mechanism such as a userspace application. In these cases the
> receiving=A0device in the skb appears to be the loopback interface, n=
ot
> a physical device. icmp_reply will thus issue the reply to the
> loopback IP address, rather than the source IP address as it should.
>=20
> While googling to see if this issue have been submitted, I found this
> two threads that address the same problem:
>=20
> ([PATCH] 2.6.22.6 NETWORKING [IPV4]: Always use source addr in skb to
> reply packet) on 17 sep 2007
> AND
> ([PATCH RESEND] 2.6.22.6 networking [ipv4]: fix wrong destination whe=
n
> reply packetes) on 20 sep 2007).
>=20
> Nothing came out of these threads, and some of the questions there ar=
e
> easy to answer; such as this doesn't affect DNAT, and if source IP
> address is not set then you should not issue a reply for echo and
> timestamp anyway.
>=20
> As to the statement:
> "... which IP address should be used as the source
> 1. the destination address of the packet that generated the message
>=20
> or.
>=20
> 2. the IP address that the machine would use by default if the machin=
e
> were to generate a new connection to the destination."
> These may be relevant questions, but the ICMP RFC clearly states the
> answer is 1. 2. may seem relevant to=A0multi-homing, but its not the
> role of the ICMP reply to resolve multi-homing issues.
> The following code will correct the issue.
> {
> =A0=A0 struct iphdr *ip =3D ip_hdr(skb);
> =A0=A0 daddr =3D ipc.addr =3D ip->saddr;
> }
> The only functions that use icmp_reply are icmp_echo and
> icmp_timestamp, and this change do not modify their=A0behavior. After
> extensive testing, in regular setups and DNATed situations, I can
> verify this change works as intended.
> Thanks,

--=20
Jiri Kosina
SUSE Labs, Novell Inc.
