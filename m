From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: [PATCH] ipv6: Fixed source specific default route handling.
Date: Sun, 21 Jun 2015 19:18:48 +0200
Message-ID: <5586F1F8.1070800@universe-factory.net>
References: <7922B483-7EA7-4B50-BF1C-7681EB7CC454@iki.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Ww2F0AqLrN2xwUd2Kxp26jG1LbtwK1mvu"
To: Markus Stenberg <markus.stenberg@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Steven Barth <steven@midlink.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7922B483-7EA7-4B50-BF1C-7681EB7CC454@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Ww2F0AqLrN2xwUd2Kxp26jG1LbtwK1mvu
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/05/2015 12:36 PM, Markus Stenberg wrote:
> If there are only IPv6 source specific default routes present, the
> host gets -ENETUNREACH on e.g. connect() because ip6_dst_lookup_tail
> calls ip6_route_output first, and given source address any, it fails,
> and ip6_route_get_saddr is never called.
>=20
> The change is to use the ip6_route_get_saddr, even if the initial
> ip6_route_output fails, and then doing ip6_route_output _again_ after
> we have appropriate source address available.
>=20
> Note that this is '99% fix' to the problem; a correct fix would be to
> do route lookups only within addrconf.c when picking a source address,
> and never call ip6_route_output before source address has been
> populated.
>=20
> Signed-off-by: Markus Stenberg <markus.stenberg@iki.fi>
> ---
>  net/ipv6/ip6_output.c | 39 +++++++++++++++++++++++++++++++--------
>  net/ipv6/route.c      |  5 +++--
>  2 files changed, 34 insertions(+), 10 deletions(-)
>=20
=2E..

So... how does ip6_route_get_saddr() select the source address when no
route is given? OpenWrt has recently started relying on this patch and
I'm seeing quite weird source address selection behaviour (@Steven:
especially since OpenWrt commit r45941).

Steps to reproduce:

  ip l add test link eth0 type macvlan
  ip l set test up
  ip a add fd00::20/64 dev eth0
  ip a add fd00::1/128 dev test

Upto here everything is okay,

  ping6 fd00::10

will use the correct source address fd00::20.

Now I add an additional source-specific route:

  ip r add fd00::/64 from fd00::/64 dev eth0

(this certainly looks like a contrived example, but the configuration
OpenWrt's netifd/odhcp6c creates is similar)

Without this patch, the ping will fail with 'network unreachable' (which
is weird by itself - why does the source-specific route shadow the
generic route even though no source address has been chosen?). But after
applying this patch, the kernel will now choose the address with the
longest common prefix with the destination, which is fd00::1 - even
though this address is assigned as /128.

Adding a prefsrc attribute to the source-specific route doesn't have an
effect as ip6_route_get_saddr() doesn't even get the route when the
non-source-specific ip6_route_output() has failed. Thus, there's
currently no way (to my knowledge) to specify the source address to use
when source-specific routes are involved...

Matthias


--Ww2F0AqLrN2xwUd2Kxp26jG1LbtwK1mvu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVhvH4AAoJEBbvP2TLIB2cMMcP/18s11K/nnnytVCwH4KQxcyB
gUDps81MnJsdS+ITB1r2eTdx0yDLQL9n+abSrH/3ESnZLpmJ1Ecy4olfsE3dIy2i
SbNjZtWuOt+KRk+0O0/7UgSNFZnXLPLiCEhip+vJHTEJzhVUEW02ZLigHKrJ5tfB
K3jkTornHwfSnxQKHb3HGZhoQkB9e3YmTD0moABdgbA3x4Cg6PQs/XGBZw/uX2xP
4qRN0wfxIX7pkegkkTnPr4qs4PvwgqiVW/CA10MAKp/9MdGCAIEq+SfCrHYQI5Kb
PbkgF4kVnCyM4u+Pkvjn7+JR9HnbA3eQsOeqL05vERGWzVx83dleN2CuRtCsYDvj
Ce+sMJ7GSZsJp1wcvrJjrVzBsZHOJJAQTTfmHU4C4pPgBiqme0dn56e9QQo2HpfI
L2lvM85jw8iU+rmbzw3H818Pm7MUYd9hJiCiqJCsognZc3qXnImK9/mOHF5sHuO+
o6lARsC1+884aBkLHGg/AVhCOsEpFyjS+7QNIkF2QJbmm38chK4xc9DU1utFOi0K
Gnb/N9k1IaMBipJJKdC5KhnUr5/L3HXIW3HN74ytLnXwxAtAMV3ql645WjsE59Jp
iCKmCpa1V0c+HMLBOZpQeI5W9FmgJ0h4wwZRVxMRzMlrX9BaFfQ8kR+CNApn4Nuy
a2pI938c528HcWqwmsTQ
=U0tc
-----END PGP SIGNATURE-----

--Ww2F0AqLrN2xwUd2Kxp26jG1LbtwK1mvu--
