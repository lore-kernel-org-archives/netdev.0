From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] caif: fix endian conversion in cffrml_transmit()
Date: Mon, 21 Nov 2011 22:50:57 +0300
Message-ID: <20111121195056.GM29436@mwanda>
References: <20111121061722.GD7354@elgon.mountain>
 <20111121063356.GH2203@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KSyhVCl2eeZHT0Rn"
Cc: Sjur Braendeland <sjur.brandeland@stericsson.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:64653 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab1KUTtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 14:49:39 -0500
Content-Disposition: inline
In-Reply-To: <20111121063356.GH2203@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--KSyhVCl2eeZHT0Rn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

The "tmp" variable here is used to store the result of cpu_to_le16()
so it should be an __le16 instead of an int.  We want the high bits
set and the current code works on little endian systems but not on
big endian systems.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2:  In v1 I used a u16 instead of an __le16.  Also I've changed the
name to "data" instead of "tmp".

diff --git a/net/caif/cffrml.c b/net/caif/cffrml.c
index f399211..d3ca87b 100644
--- a/net/caif/cffrml.c
+++ b/net/caif/cffrml.c
@@ -136,20 +136,21 @@ static int cffrml_receive(struct cflayer *layr, struc=
t cfpkt *pkt)
=20
 static int cffrml_transmit(struct cflayer *layr, struct cfpkt *pkt)
 {
-	int tmp;
 	u16 chks;
 	u16 len;
+	__le16 data;
+
 	struct cffrml *this =3D container_obj(layr);
 	if (this->dofcs) {
 		chks =3D cfpkt_iterate(pkt, cffrml_checksum, 0xffff);
-		tmp =3D cpu_to_le16(chks);
-		cfpkt_add_trail(pkt, &tmp, 2);
+		data =3D cpu_to_le16(chks);
+		cfpkt_add_trail(pkt, &data, 2);
 	} else {
 		cfpkt_pad_trail(pkt, 2);
 	}
 	len =3D cfpkt_getlen(pkt);
-	tmp =3D cpu_to_le16(len);
-	cfpkt_add_head(pkt, &tmp, 2);
+	data =3D cpu_to_le16(len);
+	cfpkt_add_head(pkt, &data, 2);
 	cfpkt_info(pkt)->hdr_len +=3D 2;
 	if (cfpkt_erroneous(pkt)) {
 		pr_err("Packet is erroneous!\n");

--KSyhVCl2eeZHT0Rn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOyqugAAoJEOnZkXI/YHqRpXIQALA7WxogODSixuZ+sSY72S3D
R1Oi75DmT7OSpKznyLnON00RWhMhOFjz52mgF4N4EaLR6QV+plDhZZWD16WCsOi+
U3bMuNsTx6DvansInDejpchIp+x55C2uaiwKwSbDqGNJtkg+RlwW9PgtIqpsissQ
vGv0Gq/G5Zigl0h0NkqW5ruy34RQxEIPAIDc2IcUF97ytMLI1GIQcDh/e0/2k0ml
s8JvoEbRi3LJBgg9XvGTADLlbKlqn6QNE217k7GMKHRUVhy/sG9JrIEogPVzqpa6
ajJmiVi1DiAIAHDHKRR71+XHbFUrHXGELJrFeRYSqgsCNf5Zq/ncsQA49HEWqzxI
FAPlxHtmrgQW1eJFjuryq/24kWFEzUeKXSTEY5zcQMsRVagNPFG6n01p50amI5xT
wQYQm8Xw0gAUk1wXynkT1B/2YLruxNHBB2b0kyNELsesJBelyjtZsgv+4mPdtlEL
CobFlko6I8HwvtzZmoYj2uzOy6QJ80E8avWMMmEvru9K9mH/O3lR+0mjBlVip/O2
mokx5JrIcqKAJ2MMeI+6jiJqpbmlZ+jo43n1DVA9NPLxiBqpwKGwMT4dvwReGr6w
NfS17zTUxmsmjce00NuOquGkQz+RMpnlAPwQ10tr1d1AYrRTcB4Ug5YTjc551/Jn
AnwTEzz1XOpYm8t3bGnO
=DD1a
-----END PGP SIGNATURE-----

--KSyhVCl2eeZHT0Rn--
