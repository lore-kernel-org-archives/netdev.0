From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net] cxgb3: Fix length calculation in write_ofld_wr() on
 32-bit architectures
Date: Sun, 27 Oct 2013 21:02:39 +0000
Message-ID: <1382907759.2994.36.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-EXkzHj0frwEs8wiXLydX"
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59237 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753542Ab3J0VCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 17:02:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-EXkzHj0frwEs8wiXLydX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The length calculation here is now invalid on 32-bit architectures,
since sk_buff::tail is a pointer and sk_buff::transport_header is
an integer offset:

drivers/net/ethernet/chelsio/cxgb3/sge.c: In function 'write_ofld_wr':
drivers/net/ethernet/chelsio/cxgb3/sge.c:1603:9: warning: passing argument =
4 of 'make_sgl' makes integer from pointer without a cast [enabled by defau=
lt]
         adap->pdev);
         ^
drivers/net/ethernet/chelsio/cxgb3/sge.c:964:28: note: expected 'unsigned i=
nt' but argument is of type 'sk_buff_data_t'
 static inline unsigned int make_sgl(const struct sk_buff *skb,
                            ^

Use the appropriate skb accessor functions.

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Fixes: 1a37e412a022 ('net: Use 16bits for *_headers fields of struct skbuff=
')
---
This is needed for 3.11-stable.

Ben.

 drivers/net/ethernet/chelsio/cxgb3/sge.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/etherne=
t/chelsio/cxgb3/sge.c
index 9c89dc8..632b318 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -1599,7 +1599,8 @@ static void write_ofld_wr(struct adapter *adap, struc=
t sk_buff *skb,
 	flits =3D skb_transport_offset(skb) / 8;
 	sgp =3D ndesc =3D=3D 1 ? (struct sg_ent *)&d->flit[flits] : sgl;
 	sgl_flits =3D make_sgl(skb, sgp, skb_transport_header(skb),
-			     skb->tail - skb->transport_header,
+			     skb_tail_pointer(skb) -
+			     skb_transport_header(skb),
 			     adap->pdev);
 	if (need_skb_unmap()) {
 		setup_deferred_unmapping(skb, adap->pdev, sgp, sgl_flits);

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-EXkzHj0frwEs8wiXLydX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUm1/b+e/yOyVhhEJAQoVOA//S447LbmlSB3F71c5kp2SoiF8KvvgKQEZ
me6RmEuBCC90l6e43YnJjtmvHUUCv3DmTrSnk/nWkUm6L6GMJ3HDtkngMrhBJraP
ZegT0n/HGrjQS6ga6GMCkWiplq3YZMWMf1McknsPtyUF6gFyHqpyaEnzSMEfngae
89Zs01yQoshVvnXFWDz72uO2zfpoyWZwYbknZFclJnCcU85uSRBDLmTRPpk49SNF
T2+PC/JUczZ/9yawTfzG2LUbMXQoAi21eS4o7OhL6O1v1Kq5tmeolC+PG5TwYJep
SlJDXeXZ4x4NLOxZXHq5zcpvYyy7MlP2+ozw0ejnqMxgfF2W6fSGVGE3vfxGMxYd
UPlB+mtGSD3RJhdyQMxDMvqZROJG6P5g3saBU2ZdHZLn/nZpKzlHPAlukzsZANMB
e/k1RkNZ73O6+AMBf570jlX0Rnz+uhitbsDZbzFL24yFiC96A2hDa7Gy0fEVqdlv
TgyqKqgY8Mzuqy3X+87ZFocRgsvgDKLeeYOzAUA99XcaLAu/O5+M17ZXJMkXhZL2
K8One0ml9U1myYMWSQpTbEOm9EJfd+s442QVowE7bc34VsWyIM4f4SERyU+HWEiQ
9zBcBLTeJFCJgL1WUUqkYxEimftzTxXMZ3xZCyjASn+TruhQpPEstCddYI/ABQmu
nAi0jdrT4Nw=
=RQ9q
-----END PGP SIGNATURE-----

--=-EXkzHj0frwEs8wiXLydX--
