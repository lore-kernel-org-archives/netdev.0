From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [patch] d80211: fix WEP on big endian cpus
Date: Sun, 10 Sep 2006 17:47:16 -0400
Message-ID: <200609101747.21946.flamingice@sourmilk.net>
References: <20060910173649.GA6324@devicescape.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1361053.FBUUz01aru";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:12758 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S932099AbWIJVri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 17:47:38 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20060910173649.GA6324@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1361053.FBUUz01aru
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Huh. I assumed crc32_le gave us the result in little endian, but I guess=20
that's wrong.

I've attached another patch which basically does the same thing but adds so=
me=20
sparse bitwise annotations to make things clear. Also, it has a signed-off-=
by=20
line. :)

d80211: fix WEP on big endian cpus

This patch fixes the endian issues with the ICV in WEP, as pointed out by=20
David Kimdon <david.kimdon@devicescape.com>, and uses __le32 where=20
appropriate to make things clear.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>

=2D--

 net/d80211/wep.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/d80211/wep.c b/net/d80211/wep.c
index c3e4728..22c2e53 100644
=2D-- a/net/d80211/wep.c
+++ b/net/d80211/wep.c
@@ -120,10 +120,10 @@ void ieee80211_wep_encrypt_data(struct c
 				size_t klen, u8 *data, size_t data_len)
 {
 	struct scatterlist sg;
=2D	u32 *icv;
+	__le32 *icv;
=20
=2D	icv =3D (u32 *)(data + data_len);
=2D	*icv =3D ~crc32_le(~0, data, data_len);
+	icv =3D (__le32 *)(data + data_len);
+	*icv =3D cpu_to_le32(~crc32_le(~0, data, data_len));
=20
 	crypto_cipher_setkey(tfm, rc4key, klen);
 	sg.page =3D virt_to_page(data);
@@ -187,7 +187,7 @@ int ieee80211_wep_decrypt_data(struct cr
 			       size_t klen, u8 *data, size_t data_len)
 {
 	struct scatterlist sg;
=2D	u32 crc;
+	__le32 crc;
=20
 	crypto_cipher_setkey(tfm, rc4key, klen);
 	sg.page =3D virt_to_page(data);
@@ -195,7 +195,7 @@ int ieee80211_wep_decrypt_data(struct cr
 	sg.length =3D data_len + WEP_ICV_LEN;
 	crypto_cipher_decrypt(tfm, &sg, &sg, sg.length);
=20
=2D	crc =3D ~crc32_le(~0, data, data_len);
+	crc =3D cpu_to_le32(~crc32_le(~0, data, data_len));
 	if (memcmp(&crc, data + data_len, WEP_ICV_LEN) !=3D 0)
 		/* ICV mismatch */
 		return -1;

--nextPart1361053.FBUUz01aru
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFBIfpT3Oqt9AH4aERAtdYAJ4rXS0Hs5IPd0Rd3aQduu7gcp3XcgCfZagp
PdIZ+aUz3stEg4jcDZxCfJs=
=VukH
-----END PGP SIGNATURE-----

--nextPart1361053.FBUUz01aru--
