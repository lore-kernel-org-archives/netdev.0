From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 2/8] farsync: Fix confusion about DMA address and buffer
 offset types
Date: Wed, 21 Dec 2011 01:32:52 +0000
Message-ID: <1324431172.2844.147.camel@deadeye>
References: <1324430940.2844.144.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ea7sVFMPsswuSiiPROlZ"
Cc: LKML <linux-kernel@vger.kernel.org>
To: Kevin Curtis <kevin.curtis@farsite.co.uk>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324430940.2844.144.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ea7sVFMPsswuSiiPROlZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Consistently use dma_addr_t for DMA addresses, except in
fst_{rx,tx}_dma where we truncate them to 32 bits.  (We know this is
OK because that's the default DMA mask for PCI devices.)

Consistently use u32 for buffer offsets within shared memory.

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/wan/farsync.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index ebb9f24..98c04c6 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -886,15 +886,13 @@ fst_rx_dma_complete(struct fst_card_info *card, struc=
t fst_port_info *port,
  *      Receive a frame through the DMA
  */
 static inline void
-fst_rx_dma(struct fst_card_info *card, dma_addr_t skb,
-	   dma_addr_t mem, int len)
+fst_rx_dma(struct fst_card_info *card, dma_addr_t skb, u32 mem, int len)
 {
 	/*
 	 * This routine will setup the DMA and start it
 	 */
=20
-	dbg(DBG_RX, "In fst_rx_dma %lx %lx %d\n",
-	    (unsigned long) skb, (unsigned long) mem, len);
+	dbg(DBG_RX, "In fst_rx_dma %x %x %d\n", (u32)skb, mem, len);
 	if (card->dmarx_in_progress) {
 		dbg(DBG_ASS, "In fst_rx_dma while dma in progress\n");
 	}
@@ -915,20 +913,19 @@ fst_rx_dma(struct fst_card_info *card, dma_addr_t skb=
,
  *      Send a frame through the DMA
  */
 static inline void
-fst_tx_dma(struct fst_card_info *card, unsigned char *skb,
-	   unsigned char *mem, int len)
+fst_tx_dma(struct fst_card_info *card, dma_addr_t skb, u32 mem, int len)
 {
 	/*
 	 * This routine will setup the DMA and start it.
 	 */
=20
-	dbg(DBG_TX, "In fst_tx_dma %p %p %d\n", skb, mem, len);
+	dbg(DBG_TX, "In fst_tx_dma %x %x %d\n", (u32)skb, mem, len);
 	if (card->dmatx_in_progress) {
 		dbg(DBG_ASS, "In fst_tx_dma while dma in progress\n");
 	}
=20
-	outl((unsigned long) skb, card->pci_conf + DMAPADR1);	/* Copy from here *=
/
-	outl((unsigned long) mem, card->pci_conf + DMALADR1);	/* to here */
+	outl(skb, card->pci_conf + DMAPADR1);	/* Copy from here */
+	outl(mem, card->pci_conf + DMALADR1);	/* to here */
 	outl(len, card->pci_conf + DMASIZ1);	/* for this length */
 	outl(0x000000004, card->pci_conf + DMADPR1);	/* In this direction */
=20
@@ -1405,9 +1402,7 @@ do_bottom_half_tx(struct fst_card_info *card)
 					card->dma_len_tx =3D skb->len;
 					card->dma_txpos =3D port->txpos;
 					fst_tx_dma(card,
-						   (char *) card->
-						   tx_dma_handle_card,
-						   (char *)
+						   card->tx_dma_handle_card,
 						   BUF_OFFSET(txBuffer[pi]
 							      [port->txpos][0]),
 						   skb->len);
--=20
1.7.7.3




--=-ea7sVFMPsswuSiiPROlZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATvE3ROe/yOyVhhEJAQq5UBAApGAMHnAosLKRWvXAKg1lgnzYWxTLrAgj
XlAbV2820p796oa6PEZo/7JNQ1SAEYwF6VihzMIYV06oRyqoJ1bYvHg0iOQioSwM
nFFpq63T8Zmvm8TU7VPOoPRRPXGyCC8sLDa9Wg0cBF6x+WB7NZesbnb2nJ92cEm0
oiabEIQMdzamHxLcZ5hCDPC+iUSErfTOSO/xpWcRTLH7TN9e2bBexnggdIRuwJht
zraoU+Y+86tA7Ljp7yB0vdxmilcemon12l4rGoGvGIWQuw90W//Iu1C0vxqefxp0
cL4HwroiYDCo/6oaDtEoVWOAJyQyZOMxUD+i01/k0WLxcdf6x7BYeVZsJrODYFnI
+Xq9mc9dDb1kZMWKxtj6e/iCisKEVr8SxNdyAlrpiZGDNRf/40KLlGIMlRSq2OI1
bAA/tHiDLxV473aEwitFcHn2aWOcxfp4r5l3NZkzKmV6BZUxfWVZW6g0Memv39rc
kvCQbUA4z5j4Ke070C/7qgdU/BK9+aYu7dfGPw5VhCfFBNgRaF41zXTzEWA0MFJC
avQIcT0UEfxyVtv/0i5TZ61ZaPOO87fZI+zsjv6nlfGjH4dnrG0GDVLTyPVC5VWU
Q3YoGLnuvv0Zekz/0wOVi4isGFlfrN/H2yJVgLpPQl/0NbfUxF3rkY5Pp/rFWdnV
WAMZYJLAOyo=
=E8g0
-----END PGP SIGNATURE-----

--=-ea7sVFMPsswuSiiPROlZ--
