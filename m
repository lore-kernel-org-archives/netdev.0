From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: [PATCH net-next 3/3] vxlan: allow multiple VXLANs with same VNI
 for IPv6 link-local addresses
Date: Wed, 5 Apr 2017 18:58:29 +0200
Message-ID: <9756edcf-8c0c-fc49-04a0-09b7ffed4362@universe-factory.net>
References: <cover.1489184335.git.mschiffer@universe-factory.net>
 <5c74248483272110d0ca249b80b943b0ceb0b610.1489184335.git.mschiffer@universe-factory.net>
 <20170314162815.7aae9e94@griffin>
 <1542ef1a-4bc2-d142-1910-0583c3c543a6@universe-factory.net>
 <20170315162257.127b27d6@griffin>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="fmrBUi5djVfQt56qRw7Lud0xicof9fwp4"
Cc: davem@davemloft.net, hannes@stressinduktion.org, pshelar@ovn.org,
        aduyck@mirantis.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([37.72.148.22]:49094 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753544AbdDEQ6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 12:58:33 -0400
In-Reply-To: <20170315162257.127b27d6@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fmrBUi5djVfQt56qRw7Lud0xicof9fwp4
Content-Type: multipart/mixed; boundary="c2v6OqWcf0v1whbdfQaV0nPe3fPMljxj4";
 protected-headers="v1"
From: Matthias Schiffer <mschiffer@universe-factory.net>
To: Jiri Benc <jbenc@redhat.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org, pshelar@ovn.org,
 aduyck@mirantis.com, roopa@cumulusnetworks.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-ID: <9756edcf-8c0c-fc49-04a0-09b7ffed4362@universe-factory.net>
Subject: Re: [PATCH net-next 3/3] vxlan: allow multiple VXLANs with same VNI
 for IPv6 link-local addresses
References: <cover.1489184335.git.mschiffer@universe-factory.net>
 <5c74248483272110d0ca249b80b943b0ceb0b610.1489184335.git.mschiffer@universe-factory.net>
 <20170314162815.7aae9e94@griffin>
 <1542ef1a-4bc2-d142-1910-0583c3c543a6@universe-factory.net>
 <20170315162257.127b27d6@griffin>
In-Reply-To: <20170315162257.127b27d6@griffin>

--c2v6OqWcf0v1whbdfQaV0nPe3fPMljxj4
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 03/15/2017 04:22 PM, Jiri Benc wrote:
> On Wed, 15 Mar 2017 15:29:29 +0100, Matthias Schiffer wrote:
>> While ensuring that the destination address is link-local iff the sour=
ce
>> address is would also be an option, it didn't seem too useful as the
>> destination address will be a multicast address anyways in "normal" VX=
LAN
>> configurations. If we really want to check this, I guess the valid
>> combinations are:
>>
>> source link-local - destination link-local UC
>> source link-local - destination link-local MC
>> source global/... - destination global/... UC
>> source global/... - destination any MC
>>
>> Does this make sense?
>=20
> It does.
>=20
> Thanks!
>=20
>  Jiri
>=20

While trying to integrate the additional checks, I noticed that the
vxlan_dev_configure() function has some serious issues in the changelink
case. An (probably incomplete) list of things that can go wrong:

- vxlan_dev_configure may return with an error as late the "if (conf->mtu=
)"
branch, after some settings have already been applied to the vxlan_dev or=

net_device, leading to partial application in some error cases

- at the moment, changelink is allowed to change the address family of th=
e
source/destionation addresses, but VXLAN_F_IPV6 is never removed, and
sockets are not recreated; I think changing the AF should just be disallo=
wed

- conf->mtu will be re-applied in changelink even when the lowerdev has n=
ot
changed, possibly overwriting other MTU changes that have been made after=

device creation (having conf->mtu in addition to dev->mtu might be a bad
idea in general?)


Each of the issues could be fixed separately, but at the moment, I'm rath=
er
considering cleaning up the code by factoring out a vxlan_cfg_validate()
from vxlan_dev_configure(), to clearly separate validation and applicatio=
n
of the configuration. Is this the way to go, or do you have other suggest=
ions?

-- Matthias


--c2v6OqWcf0v1whbdfQaV0nPe3fPMljxj4--

--fmrBUi5djVfQt56qRw7Lud0xicof9fwp4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEZmTnvaa2aYgexS51Fu8/ZMsgHZwFAljlIjUACgkQFu8/ZMsg
HZzWOxAAolDne1EaI3lKPCYerYj7QGAIWbAoOXZ2J5RrTiBVNb7R5STl6eOIWvdu
gIftgDaZSo8jf25oSdUilWHgxgK0ewAZCC9ZmE6P7QfSPPhHyIz4S2HB0j4w7q/d
9Jx6EmqB0JKORbhWFo2ajeWgHo3YBKhXYU/m9uSCHGl4ZtKUJKNvUUO8/Ca98Gvf
O3sVIttnVWRPv0ydQ6yJP2WyBME2Ef4FNqA9s/7XQyOQ+D86xVhucb+QpkydWiQM
qlRmIYEYC5ZzphQvB9unbFEQSuvh9sSRqA0zeGlqr3Xncnryh8Ddo7lF9rszrRTJ
XkCVE9q4wuM5qKyvEzcYBgXa9+Max+ii4Fhyykq9ZdXiZwlGt2XX83nC5USgBHdt
UuW6WgtjnvLRbxDy70j0zVIhlj3GJxSYmj0z/p8K3ktDyN/EFY+kMO9xHioatkUs
e2u9Kgfvw24ZXFqXDpMOw1QyzVwxq3/AJUS4qOMNrr42ibfHFXaqY4cFEPUfzyyC
VFFc36b3u/i/BtcBW5a2W1iNYUSVQwqGb0dl5XXW7gUT5Zz/sxxo0GWSU95RgED5
nhyqrgziFP1iaO3y8NE0Ougpd4bNjpKsqy50XX1cXBzCy4+6/AJa0qSsX10UsDaj
NWNvJobrD2zXEtX/n6iNvyowlQ9+Bvpb0VTPSyTAq/h4EyXPegA=
=LfKy
-----END PGP SIGNATURE-----

--fmrBUi5djVfQt56qRw7Lud0xicof9fwp4--
