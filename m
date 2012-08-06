From: Eric Leblond <eric@regit.org>
Subject: [BUG] af_packet: loop at reception when using fanout
Date: Mon, 06 Aug 2012 16:21:58 +0200
Message-ID: <1344262918.8024.41.camel@tiger.regit.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-TNXQumEs0ximWQSXY5EA"
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ks28632.kimsufi.com ([91.121.96.152]:53602 "EHLO
	ks28632.kimsufi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074Ab2HFOpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 10:45:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TNXQumEs0ximWQSXY5EA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello,

When using fanout mode on a AF_PACKET socket, the packet sent via one of
the fanout socket are sent back to one of the socket in the fanout set.
I've read the code and the error seems to be in dev.c.
The code check if skb->sk is not equal to ptype->af_packet_priv but in
the fanout case, we should check that skb->sk is not in the sockets of
the fanout set.

Here's how could look a possible implementation of the fix:

diff --git a/net/core/dev.c b/net/core/dev.c
index 1cb0d8a..63d144f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1654,7 +1654,12 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, =
struct net_device *dev)
                 */
                if ((ptype->dev =3D=3D dev || !ptype->dev) &&
                    (ptype->af_packet_priv =3D=3D NULL ||
-                    (struct sock *)ptype->af_packet_priv !=3D skb->sk)) {
+                       (((struct sock *)ptype->af_packet_priv !=3D skb->sk=
)
+                       &&
+                        /* MISSING CHECK: af_packet_priv  skb->sk one of t=
he socket in fanout id of skb */
+                       ! packet_sk_in_fanout(ptype, skb->sk)
+                        )
+                       ) {
                        if (pt_prev) {
                                deliver_skb(skb2, pt_prev, skb->dev);
                                pt_prev =3D ptype;

If this is done, we will have to export one function from the af_packet
module and I don't like the idea. If it is correct way to do it I can
implement this and propose a patch.

BR,
--=20
Eric Leblond=20
Blog: http://home.regit.org/ - Portfolio: http://regit.500px.com/

--=-TNXQumEs0ximWQSXY5EA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEABECAAYFAlAf0wcACgkQnxA7CdMWjzLoeACeJsyNNg/oM68u4Y/YWQM5h/Kz
MX0Ani8r5MfevVPBJZOMVD59Xgirmf2L
=YLvU
-----END PGP SIGNATURE-----

--=-TNXQumEs0ximWQSXY5EA--
