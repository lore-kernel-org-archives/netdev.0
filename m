From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 22 Jun 2015 12:58:33 +1000
Message-ID: <20150622125833.451c4440@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/pRgzmiSgBDipHIcHo3udMUq"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/pRgzmiSgBDipHIcHo3udMUq
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/packet/af_packet.c

between commit:

  468479e6043c ("packet: avoid out of bounds read in round robin fanout")

from the net tree and commit:

  3b3a5b0aab5b ("packet: rollover huge flows before small flows")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/packet/af_packet.c
index fe1610ddeacf,20e8c40da90d..000000000000
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@@ -1272,6 -1326,30 +1326,20 @@@ static void packet_sock_destruct(struc
  	sk_refcnt_debug_dec(sk);
  }
 =20
 -static int fanout_rr_next(struct packet_fanout *f, unsigned int num)
 -{
 -	int x =3D atomic_read(&f->rr_cur) + 1;
 -
 -	if (x >=3D num)
 -		x =3D 0;
 -
 -	return x;
 -}
 -
+ static bool fanout_flow_is_huge(struct packet_sock *po, struct sk_buff *s=
kb)
+ {
+ 	u32 rxhash;
+ 	int i, count =3D 0;
+=20
+ 	rxhash =3D skb_get_hash(skb);
+ 	for (i =3D 0; i < ROLLOVER_HLEN; i++)
+ 		if (po->rollover->history[i] =3D=3D rxhash)
+ 			count++;
+=20
+ 	po->rollover->history[prandom_u32() % ROLLOVER_HLEN] =3D rxhash;
+ 	return count > (ROLLOVER_HLEN >> 1);
+ }
+=20
  static unsigned int fanout_demux_hash(struct packet_fanout *f,
  				      struct sk_buff *skb,
  				      unsigned int num)

--Sig_/pRgzmiSgBDipHIcHo3udMUq
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVh3ndAAoJEMDTa8Ir7ZwVuhkP/RnaaYphj2IxKJDsLXwK1Y3S
CklCKWMam1jWe/LiKORgv5qxLon0ki5Cdcb067jNbOtw2LxcBjmLbVD3m8CpgIB4
+LkX05pvVnZCxiPpPRPMogXG6EyiplBOHKtfQc/iiZvhQ0KVJUVMl/tboGCqPAhk
Vi1FWqLaO5p0MBYIklGrpoC8+diLqRxD1znv2UyZ6QU+SRvS1nZbp0qmXby3Uroe
5cBzXWKAi9VgszKJjihgAeKE68lzepEXwMADr9QVGPRxt3gAoWwGIBeYQFlxIyW7
CyYVe8WE41o/2Tcdte0bb+r6/csOllRCX65M25uMd5AxW+l9zGGl7y80UUKPxSod
7YPqUbRhxbU9BWl3cKupUZJhuSiHZk9aD9PcDjFdk5R3kkD27LxwOmkQov2X7lJ4
ux/bkb0D4zyPasmXU/aR9b2EotngRUk89zcKY2hG2sfru1uHIg4iMU0CCRQURkeK
GQTD0V12ikibivrLRjsNssP6s8aGH2FGr34bUZy4aBUvS1eJ6ekxMp/agoLHqtTZ
fL8ELsJkd7WJku2kJx4qoRt7q3MPAScUbth4vY9knMueTn05Cf40SZcZZz3ycKK+
+3ljnIdRVWh9zTggDzpaofve/Sz+oOlg+PLnCXUV/hyVua8FyMODqzoHIppwY5JP
Hi+ZfvnRJXCBRIJodnZn
=9Ud1
-----END PGP SIGNATURE-----

--Sig_/pRgzmiSgBDipHIcHo3udMUq--
