From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: revert misguided compiler warning fix on ipv6_exthdrs_len
Date: Sun, 15 Dec 2013 18:18:06 +0100
Message-ID: <20131215171806.GA1715@order.stressinduktion.org>
References: <1386824025-27413-1-git-send-email-hkchu@google.com> <20131214062929.GA23563@order.stressinduktion.org> <20131214.020211.969354536190248209.davem@davemloft.net> <CAPshTCj38XqrAMTKnGhw1bdWWrhHbzXpT8FNtDwd6_kJgLoeDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57075 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577Ab3LORSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 12:18:09 -0500
Content-Disposition: inline
In-Reply-To: <CAPshTCj38XqrAMTKnGhw1bdWWrhHbzXpT8FNtDwd6_kJgLoeDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This essentlally reverts commit f52d81dc27c3456c702e83183035142c222acdc=
7
("ipv6: fix compiler warning in ipv6_exthdrs_len") and silences the
warning with uninitialized_var.

Cc: Jerry Chu <hkchu@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

On Mon, Dec 16, 2013 at 12:20:22AM +0800, Jerry Chu wrote:
> On Sat, Dec 14, 2013 at 3:02 PM, David Miller <davem@davemloft.net> w=
rote:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Sat, 14 Dec 2013 07:29:29 +0100
> >
> >> Commit 299603e8370a93dd5d8e8d800f0dff1ce2c53d36 ("net-gro: Prepare=
 GRO
> >> stack for the upcoming tunneling support") used an uninitialized v=
ariable
> >> which leads to the following compiler warning:
> >>
> >> net/ipv6/ip6_offload.c: In function =E2=80=98ipv6_gro_complete=E2=80=
=99:
> >> net/ipv6/ip6_offload.c:178:24: warning: =E2=80=98optlen=E2=80=99 m=
ay be used uninitialized in this function [-Wmaybe-uninitialized]
> >>     opth =3D (void *)opth + optlen;
> >>                         ^
> >> net/ipv6/ip6_offload.c:164:22: note: =E2=80=98optlen=E2=80=99 was =
declared here
> >>   int len =3D 0, proto, optlen;
> >>                       ^
> >> Fix it up.
> >>
> >> Cc: Jerry Chu <hkchu@google.com>
> >> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >
> > Applied.
>=20
> Please back out the above "fix" - it actually breaks the original cod=
e because
> the fix will cause exthdrs_len to be one optlen short.
>
> There was no bug in the original code, just the compiler warning (and=
 I do not
> get any warning, although I admit I did not run with the -W flag).

Sorry, I see now, of course. Btw. I didn't use any special flags, just
a normal kernel build with gcc 4.8.2.

> In any case I will submit a revision shortly that will silent any
> warning if exists.

I hope you are ok with this.

Sorry,

  Hannes

 net/ipv6/ip6_offload.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 08861f1..0a578fc 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -161,7 +161,7 @@ static int ipv6_exthdrs_len(struct ipv6hdr *iph,
 			    const struct net_offload **opps)
 {
 	struct ipv6_opt_hdr *opth =3D NULL;
-	int len =3D 0, optlen =3D 0, proto;
+	int len =3D 0, proto, uninitialized_var(optlen);
=20
 	proto =3D iph->nexthdr;
 	for (;;) {
@@ -172,12 +172,11 @@ static int ipv6_exthdrs_len(struct ipv6hdr *iph,
 			if (!((*opps)->flags & INET6_PROTO_GSO_EXTHDR))
 				break;
 		}
-		if (opth =3D=3D NULL) {
+		if (opth =3D=3D NULL)
 			opth =3D (void *)(iph+1);
-		} else {
-			optlen =3D ipv6_optlen(opth);
+		else
 			opth =3D (void *)opth + optlen;
-		}
+		optlen =3D ipv6_optlen(opth);
 		len +=3D optlen;
 		proto =3D opth->nexthdr;
 	}
--=20
1.8.3.1
