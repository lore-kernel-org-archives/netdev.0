From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next] sfc: Use __iowrite64_copy instead of a slightly
 different local function
Date: Sun, 27 Jul 2014 03:14:39 +0100
Message-ID: <1406427279.29010.139.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-obP17U7VbImHg5CYSUez"
Cc: netdev <netdev@vger.kernel.org>
To: Shradha Shah <sshah@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57754 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751219AbaG0COy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2014 22:14:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-obP17U7VbImHg5CYSUez
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

__iowrite64_copy() isn't quite the same as efx_memcpy_64(), but
it looks close enough:

- The length is in units of qwords not bytes
- It never byte-swaps, but that doesn't make a difference now as PIO
  is only enabled for x86_64
- It doesn't include any memory barriers, but that's OK as there is a
  barrier just before pushing the doorbell
- mlx4_en uses it for the same purpose

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/ethernet/sfc/tx.c | 24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index ede8dcc..e03350e 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -189,18 +189,6 @@ struct efx_short_copy_buffer {
 	u8 buf[L1_CACHE_BYTES];
 };
=20
-/* Copy in explicit 64-bit writes. */
-static void efx_memcpy_64(void __iomem *dest, void *src, size_t len)
-{
-	u64 *src64 =3D src;
-	u64 __iomem *dest64 =3D dest;
-	size_t l64 =3D len / 8;
-	size_t i;
-
-	for (i =3D 0; i < l64; i++)
-		writeq(src64[i], &dest64[i]);
-}
-
 /* Copy to PIO, respecting that writes to PIO buffers must be dword aligne=
d.
  * Advances piobuf pointer. Leaves additional data in the copy buffer.
  */
@@ -210,7 +198,7 @@ static void efx_memcpy_toio_aligned(struct efx_nic *efx=
, u8 __iomem **piobuf,
 {
 	int block_len =3D len & ~(sizeof(copy_buf->buf) - 1);
=20
-	efx_memcpy_64(*piobuf, data, block_len);
+	__iowrite64_copy(*piobuf, data, block_len >> 3);
 	*piobuf +=3D block_len;
 	len -=3D block_len;
=20
@@ -242,7 +230,8 @@ static void efx_memcpy_toio_aligned_cb(struct efx_nic *=
efx, u8 __iomem **piobuf,
 		if (copy_buf->used < sizeof(copy_buf->buf))
 			return;
=20
-		efx_memcpy_64(*piobuf, copy_buf->buf, sizeof(copy_buf->buf));
+		__iowrite64_copy(*piobuf, copy_buf->buf,
+				 sizeof(copy_buf->buf) >> 3);
 		*piobuf +=3D sizeof(copy_buf->buf);
 		data +=3D copy_to_buf;
 		len -=3D copy_to_buf;
@@ -257,7 +246,8 @@ static void efx_flush_copy_buffer(struct efx_nic *efx, =
u8 __iomem *piobuf,
 {
 	/* if there's anything in it, write the whole buffer, including junk */
 	if (copy_buf->used)
-		efx_memcpy_64(piobuf, copy_buf->buf, sizeof(copy_buf->buf));
+		__iowrite64_copy(piobuf, copy_buf->buf,
+				 sizeof(copy_buf->buf) >> 3);
 }
=20
 /* Traverse skb structure and copy fragments in to PIO buffer.
@@ -316,8 +306,8 @@ efx_enqueue_skb_pio(struct efx_tx_queue *tx_queue, stru=
ct sk_buff *skb)
 		 */
 		BUILD_BUG_ON(L1_CACHE_BYTES >
 			     SKB_DATA_ALIGN(sizeof(struct skb_shared_info)));
-		efx_memcpy_64(tx_queue->piobuf, skb->data,
-			      ALIGN(skb->len, L1_CACHE_BYTES));
+		__iowrite64_copy(tx_queue->piobuf, skb->data,
+				 ALIGN(skb->len, L1_CACHE_BYTES) >> 3);
 	}
=20
 	EFX_POPULATE_QWORD_5(buffer->option,

--=20
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyo=
u

--=-obP17U7VbImHg5CYSUez
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU9RglOe/yOyVhhEJAQpoaBAAg+RmcQn6k+rDzAEdmnQ0i5LVYUREFGBE
wzMcqV4s2LqTwm8yEpxe0LTUsq0MGWyD7nJxwUVbeqsEHFfXGmx2nGly+lyUImG9
gDFaBdLl4RpUfaydLCbhjuEPPyAXD1+gHtFEDJIDCZi6cqHElry53pTc/0KeiBKt
YCeEnxbuIvH51+g8xlk2KG0jku4x5jki623kj2t6nSbqG84L+0RA988cm17goTX6
W5SEeK5BTc0UlB7Gw80sE7UhdNRYZDPKceoTGI9y+G3nyG7jghAMR8PJX/Hn/8+f
WFM+p5R+gyu5VujUVyvH+RtT8BHuBa7MtNGyP6uiGLmRvv04QGlUw8j+Dw6Q72ZL
bVoTTIJLJBkPVBsq8jqb8Cx6TeUoPz0XGhxSNJpgHypP0PWx7g9kEFmX7ZIsZk5I
Kea4aqIazkQjIq2Iwd0Dvs06Ehhr2qL97wUz8xuNSzQoAeOw2EMDBcbdhS71aylk
E5enCA9w4rlKgErt+OGc03sSqIcD8SVj1bXMkZs3Onstz1Ozb+ESQSRS/fBywMes
enG0XzLpcS+hDzCv56N07hQdS5V7jTMEdb+qkZh26zNo4wcQ99iebIbrb96lecAl
d2MTK+Ch6RoOAWg1yEqKIYTbGT73KyrvNQZYJzsYNgMpGaT728O7Z3v6ACMnYL6a
NIXj17ffoiU=
=Ksoi
-----END PGP SIGNATURE-----

--=-obP17U7VbImHg5CYSUez--
