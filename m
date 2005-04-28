From: folkert@vanheusden.com
Subject: Re: [PATCH] optimize check in port-allocation code
Date: Thu, 28 Apr 2005 23:24:53 +0200
Message-ID: <20050428212449.GC8774@vanheusden.com>
References: <20050420184419.GM20290@vanheusden.com>
	<20050424190427.11b4863e.davem@davemloft.net>
	<20050425061210.GB15167@vanheusden.com>
	<20050428120824.6cc9b345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="RUqJLqMNe5u4kDWT"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050428120824.6cc9b345.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--RUqJLqMNe5u4kDWT
Content-Type: multipart/mixed; boundary="3eH4Qcq5fItR5cpy"
Content-Disposition: inline


--3eH4Qcq5fItR5cpy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> > I'll resend it as an attachment (see attachment).
> It still has spaces where there should be tabs, even though
> you compressed the patch and used attachment.
> The diff itself must already be corrupt before you attach
> it.
> Please double check that the patch you submit actually apply,
> this will save me a lot of wasted time.

Ok, I've redone them and tested if they patch cleanly, they now do.
See them attached.

While looking at the code I also saw something else:

--- tcp_ipv4.c.org	2005-04-28 23:13:32.000000000 +0200
+++ tcp_ipv4.c	2005-04-28 23:19:18.000000000 +0200
@@ -222,11 +222,11 @@
 		int rover;
=20
 		spin_lock(&tcp_portalloc_lock);
-		rover =3D tcp_port_rover;
+		if (tcp_port_rover < low)
+			rover =3D low;
+		else
+			rover =3D tcp_port_rover;
 		do {
-			rover++;
-			if (rover < low || rover > high)
-				rover =3D low;
 			head =3D &tcp_bhash[tcp_bhashfn(rover)];
 			spin_lock(&head->lock);
 			tb_for_each(tb, node, &head->chain)
@@ -235,6 +235,10 @@
 			break;
 		next:
 			spin_unlock(&head->lock);
+
+			rover++;
+			if (rover > high)
+				rover =3D low;
 		} while (--remaining > 0);
 		tcp_port_rover =3D rover;
 		spin_unlock(&tcp_portalloc_lock);

as you can see I moved (here! not in the included patches as I wanted
to discuss this first!) the 'rover++' and its check to the end of the
while loop. I did this because if they are at the top of the wile-loop
the 'low' port number is never used as the first statement was a
rover++!


Folkert van Heusden

--=20
Auto te koop, zie: http://www.vanheusden.com/daihatsu.php
Op zoek naar een IT of Finance baan? Mail me voor de mogelijkheden.
--------------------------------------------------------------------
 UNIX admin? Then give MultiTail (http://vanheusden.com/multitail/)=20
 a try, it brings monitoring logfiles to a different level! See    =20
 http://vanheusden.com/multitail/features.html for a feature-list. =20
--------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE
Get your PGP/GPG key signed at www.biglumber.com!

--3eH4Qcq5fItR5cpy
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="tcp_ipv4.c.diff.gz"
Content-Transfer-Encoding: base64

H4sICJFScUICA3RjcF9pcHY0LmMuZGlmZgBlUNuOgjAUfC5fMU9G0i2prSYbVMJ/mA1hES2R
UAKEfVg/3l7EBbcvp2fOzJwLYwxD0WZVO26jItLdlQjOd4xvmfiEkPFGxlJEfHqg3NQDSulM
9i7ZxVL+k6QpmBDiY2MAFyXSNAAhVTOg02PZ7QPYvG+rJqt1cVuvbItWd0Nem9xh4T5ghDg6
jpjq2VNPjdsF6yWMA2r9E9riS2gAxy7rvlwU3h3NPGeNXxs9h1I3geszs8f97pdAAlVdlW/3
R5pQ67OcwiKqzM8md/t+q7xXp9fv0niH8MtTZ9exKpY8r/IAs1MhM8kBAAA=

--3eH4Qcq5fItR5cpy
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="tcp_ipv6.c.diff.gz"
Content-Transfer-Encoding: base64

H4sICB5TcUICA3RjcF9pcHY2LmMuZGlmZgBlUMtugzAQPJuvmFMEcoyMU9KEPMR/VBWiQGJU
hBGg5JB8fG1DIqC+2DuzM7Nexhj6rEnK5rb1M1+1VyI4Dxn/YGIHsYmCbRQKn78OKNe8Qymd
yJaSzygM/kniGCzY7Nd7UHMFAnHsgJCy7tGqW9EeHJi6a8o6qVT2665MQqPaPq10bTHv4DBC
bDtOePHJqKfa7QJ3DuOISt09Q76FGrDdRdUVM2LpqOfJFR4DT6lNtxnu1BvPJ0bgDFlepTfE
mcYZbPwWUxhEFmmua/vfH5l28uv9utSDg/c9tE62Y1TsPG7lDy7ZsfvIAQAA

--3eH4Qcq5fItR5cpy--

--RUqJLqMNe5u4kDWT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iIMEARECAEMFAkJxVKE8Gmh0dHA6Ly93d3cudmFuaGV1c2Rlbi5jb20vZGF0YS1z
aWduaW5nLXdpdGgtcGdwLXBvbGljeS5odG1sAAoJEDAZDowfKNiu0Y4AnR02cQST
QQKl/ovWjAIPNZb2BiTMAJ0fh3NZaSG4+BbpkHyWM4Tekg5IxA==
=01+F
-----END PGP SIGNATURE-----

--RUqJLqMNe5u4kDWT--
