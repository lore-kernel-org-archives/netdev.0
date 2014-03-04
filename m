From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to KVM guest
Date: Tue, 4 Mar 2014 01:00:41 +0100
Message-ID: <20140304000041.GY5090@Linus-Debian>
References: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com>
 <2107636851.12713862.1393876035292.JavaMail.zimbra@redhat.com>
 <20140303212759.GW5090@Linus-Debian>
 <1808019554.12748658.1393886749190.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Ll0BBk1HBk/f94B0"
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org
To: Jan Stancek <jstancek@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:56611 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755301AbaCDAAq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2014 19:00:46 -0500
Content-Disposition: inline
In-Reply-To: <1808019554.12748658.1393886749190.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Ll0BBk1HBk/f94B0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jan,

On Mon, Mar 03, 2014 at 05:45:49PM -0500, Jan Stancek wrote:
> There is also bridge on host B. I assume that doesn't matter
> but I could set up host B without bridge if needed.

It can matter, but in this case it doesn't :).

> > What I'm curious about is, whether the guest receives
> > the MLD query and responds with an MLD report. I suspect that
> > either the bridge doesn't get an MLD report and therefore is
> > shutting down the according port or there's a bug in parsing the
> > MLD report in the bridge code.
>=20
> I'm no expert in this area, but shouldn't neigh. solicit packets
> be forwarded to all ports regardless of any/no MLD reports?

That's the beauty of IPv6 Neighbor Discovery using these neat
solicited-node multicast addresses :). With IPv4 and ARP
requests there's no other way than flooding. But for IPv6 we know
in advance behind which bridge port someone interested in the
neighbor solicitation message might be (assuming MLD is working,
properly), allowing us to save bandwidth.

In this case, MLD is not working properly, the main issue is the
following:

Host B sends broken MLD queries, the source address should be an
IPv6 link-local one, not "100:0:600:0:78fb:100::". MLDv2 mandates
this (see RFC3810, section 5.1.14.: "Source Addresses for
Queries").

Though I couldn't find that requirement for MLDv1, Linux ignores
MLDv1 queries with a non-link-local source address, too (see
net/ipv6/mcast.c, igmp6_event_query() ). So Linux never sends an
MLD report in reply to these broken queries.


The second "minor" but in this case fatal issue is, that the
bridge code doesn't have this link-local-src check, therefore
kicking the snooping into gear even though it shouldn't because we
don't have a _working_ querier.

I'm going to make a patch for the bridge code adding this sanity
check.


For the broken query, ok, it's your manually crafted query. But
did you see a query with such a bogus source address "in the
wild", too? (I'm curious how urgent this sanity check is)

Cheers, Linus

--Ll0BBk1HBk/f94B0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTFReoAAoJELxyPiAAt6Uvr0AQAJ1dGExt5XCiDg/8YpoLZgag
EAwtyQ/keUVURNCfAle+i8izoLdLKal1Kc6xCJYYYS5I/Rpteg/9PD3WJVVURwcQ
c7+8Zes7civq/fXFyuka49K1hyQSy1G0u/kf+gbNrjlYhgU1VrR3tA/oacYLxIoI
0Hfhi5+ncnZyvtvowmmKjsf+SbdOxR12mBYXEFp76rDRilAmyQZLV2H1nCDI59yD
n6AQ1XdcUqL5LIjcXVm+sLBJw+1Q0R9dqDAT1FZ1vxhYd/0Krmw1zP4JuEPmkn4B
b0Wtmp02AL5VEs3J/VRy4nZq+keODC5NNQBXTHC47miYfsErMxFz1zIuQ66HSSBM
qnKgTdsx/pJPRC7v2hNQXRaLc/2/cyTX9KysXsgubtGMfZUzVWqH4r0sazFfjX74
k/NsTc8epo3Z2BBtXrWozwTF6PL/EKLe/A1N7br0+5Wt9XMchTDyl0wRG3JQcPZ5
2mPujWXW7mwDbam52V7qj+b/MeP2yUhPkG6Tuo42EVeKEm/F6HWmDgigKuxFJn1J
cPP5dpad8e0FewD6c1nBVpJTzu4BnWnZ+MlbpvQ2g7WeD7gEtlYK+QUL7tAg7Z6M
/qx8BxD3zljs71GnSxMZes8kF0dKkWjjRXMbvMTQSGbGEjXbjtadUjnJG61YhAaE
rUY5L0G4sJhcstW/lWpv
=odPM
-----END PGP SIGNATURE-----

--Ll0BBk1HBk/f94B0--
