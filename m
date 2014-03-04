From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to
	KVM guest
Date: Tue, 4 Mar 2014 22:37:57 +0100
Message-ID: <20140304213757.GJ5090@Linus-Debian>
References: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com>
	<2107636851.12713862.1393876035292.JavaMail.zimbra@redhat.com>
	<20140303212759.GW5090@Linus-Debian>
	<1808019554.12748658.1393886749190.JavaMail.zimbra@redhat.com>
	<20140304000041.GY5090@Linus-Debian>
	<624414844.12834668.1393920156458.JavaMail.zimbra@redhat.com>
	<20140304105253.GC5090@Linus-Debian>
	<1663332249.12962360.1393931189285.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zu8lIfFVzXMVnfzp"
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org
To: Jan Stancek <jstancek@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1663332249.12962360.1393931189285.JavaMail.zimbra@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--zu8lIfFVzXMVnfzp
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 04, 2014 at 06:06:29AM -0500, Jan Stancek wrote:
>=20
>=20
> ----- Original Message -----
> > From: "Linus L=C3=BCssing" <linus.luessing@web.de>
> > To: "Jan Stancek" <jstancek@redhat.com>
> > Cc: netdev@vger.kernel.org, "Florian Westphal" <fwestpha@redhat.com>, b=
ridge@lists.linux-foundation.org
> > Sent: Tuesday, 4 March, 2014 11:52:54 AM
> > Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to KVM=
 guest
> >=20
> > Hi Jan,
> >=20
> > On Tue, Mar 04, 2014 at 03:02:36AM -0500, Jan Stancek wrote:
> > > > For the broken query, ok, it's your manually crafted query. But
> > > > did you see a query with such a bogus source address "in the
> > > > wild", too? (I'm curious how urgent this sanity check is)
> > >=20
> > > It's real packet I managed to capture during one such occurrence.
> > > I'm sending it with small C program over raw socket, but it's byte
> > > by byte exact copy of what I captured with tcpdump previously.
> > >=20
> > > I'm not sure how that packet came to existence. Based on IPv6 address
> > > it came from host B, but all host B was doing at the time
> > > was running RHEL6 with couple qemu-kvm instances. KVM guests were
> > > set up to use bridge, so I'm assuming if any of them crafted
> > > this packet, source IPv6 address would be different.
> > >=20
> >=20
> > Ah, okay. Can you check whether it maybe came from the querier
> > code in the Linux bridge on host B? Is
> > "cat /sys/class/net/br0/bridge/multicast_querier" 1?
>=20
> # cat /sys/class/net/br0/bridge/multicast_querier
> cat: /sys/class/net/br0/bridge/multicast_querier: No such file or directo=
ry

Ok, that's not present on such old kernels, there it is actually
enabled by default.

>=20
> > Can you isolate host B and disable any multicast router daemon on it? T=
hen
> > check again, if you still see these queries.
>=20
> Besides those cases where I sent it by myself, I haven't seen host B send
> that query for couple days now.
>=20
> > What kernel version is running on host B?
>=20
> 2.6.32-279.42.1.el6.x86_64
> It's a RHEL6.3.z kernel.
>=20
> > Where does Linux use :: for queries?
>=20
> I'm not sure if it's Linux (I'm trying to locate that system by MAC), but=
 I see
> packets like these on my network every ~125 seconds:
>=20
> No.     Time        Source                Destination           Protocol =
Length Info
>   22675 1334.751135 ::                    ff02::1               ICMPv6   =
86     Multicast Listener Query

It's probably the bridge on this ancient kernel, you might want to
backport the following patch:

"bridge: Use IPv6 link-local address for multicast listener queries"
(fe29ec41aaa51902aebd63658dfb04fe6fea8be5)

And it's follow-up fixes:

"bridge: Fix possibly wrong MLD queries' ethernet source address"
(a7bff75b087e7a355838a32efe61707cfa73c194)
"bridge: check return value of ipv6_dev_get_saddr()"
(d1d81d4c3dd886d5fa25a2c4fa1e39cb89613712)

If these patches on host B xor the sanity check I just submitted applied
on your host A / VM host fix your issue, then they might be worth
considering for the stable queue.

Cheers, Linus

--zu8lIfFVzXMVnfzp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTFke0AAoJELxyPiAAt6UvBHQQAKB12mQXGqpyVYNcfIEcXgAg
dCjZ+LlQt/lOG2Asei+Z+DSwecY0b0c+qlOezDeJ7klWUNFe3TjP2YzsvlgPq7TU
X1X7/+ztHdrh4sOaxuI5RNR/3Fq4Pb9vX88rRbTH7+nZh1+ZaSZw6rM3SKthQ6rQ
zFSRNQz5XUuqE4Ntfq7sqHXRnPJZrVSAycxrrNfdbLRexxiUVD3oevLNxs7UYwxB
48Du9JOFoVHpWpCM7qrw/nSQb8y067ciaVd4azpKyrUHiizUj8ARhILbWbFBfpW6
fYRrSum3c61ZV6nOkR9rWUieEbqysnIMkIWoPI/+tLxZRYMWnqz9Cxymj78MBJL2
1LwQf0jUiRl9P67ja52scHX+4XML8PFMtrztHhPDB2PlUyn7su7VpS33ytIPzmbN
pGHShVEa4xMML4tK06r9e3gPc9ECnrnVhiCnzoofT+mLDmhgQZFjAuhkTgSXC1s7
cwVjZbjyDHAK6YgYO7I90Jgh303guMgHDEq2qV6v0o3C+Wk8F4LU49ZbfGdi8mT/
xu9y4vGtwPsCgDSc0QJ2X5YOVVVphzsjH3JOcIdvhHC+EG6DzlbAcv7GihJqhgiU
DSNcSn9Rt/2mW5fINFEztcSJQDgfg1PiW4Qj70t+8orwMGBxrUYPZNOfRWAI218g
uKN1rSQogEQL82mUd2N8
=zND/
-----END PGP SIGNATURE-----

--zu8lIfFVzXMVnfzp--
