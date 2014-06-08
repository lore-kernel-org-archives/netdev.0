From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH v2 net-next] farsync: Fix confusion about DMA address and
 buffer offset types
Date: Sun, 08 Jun 2014 23:49:34 +0100
Message-ID: <1402267774.23860.44.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IutF22mOY/BkTcJl4lvZ"
Cc: netdev <netdev@vger.kernel.org>,
	Kevin Curtis <kevin.curtis@farsite.co.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41539 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753707AbaFHWts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 18:49:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IutF22mOY/BkTcJl4lvZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Use dma_addr_t for DMA address parameters and u32 for shared memory
offset parameters.

Do not assume that dma_addr_t is the same as unsigned long; it will
not be in PAE configurations.  Truncate DMA addresses to 32 bits when
printing them.  This is OK because the DMA mask for this device is
32-bit (per default).

Also rename the DMA address parameters from 'skb' to 'dma'.

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
v2: rename the DMA address parameters too

 drivers/net/wan/farsync.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index bcfff0d..a772e0e 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -886,20 +886,18 @@ fst_rx_dma_complete(struct fst_card_info *card, struc=
t fst_port_info *port,
  *      Receive a frame through the DMA
  */
 static inline void
-fst_rx_dma(struct fst_card_info *card, dma_addr_t skb,
-	   dma_addr_t mem, int len)
+fst_rx_dma(struct fst_card_info *card, dma_addr_t dma, u32 mem, int len)
 {
 	/*
 	 * This routine will setup the DMA and start it
 	 */
=20
-	dbg(DBG_RX, "In fst_rx_dma %lx %lx %d\n",
-	    (unsigned long) skb, (unsigned long) mem, len);
+	dbg(DBG_RX, "In fst_rx_dma %x %x %d\n", (u32)dma, mem, len);
 	if (card->dmarx_in_progress) {
 		dbg(DBG_ASS, "In fst_rx_dma while dma in progress\n");
 	}
=20
-	outl(skb, card->pci_conf + DMAPADR0);	/* Copy to here */
+	outl(dma, card->pci_conf + DMAPADR0);	/* Copy to here */
 	outl(mem, card->pci_conf + DMALADR0);	/* from here */
 	outl(len, card->pci_conf + DMASIZ0);	/* for this length */
 	outl(0x00000000c, card->pci_conf + DMADPR0);	/* In this direction */
@@ -915,20 +913,19 @@ fst_rx_dma(struct fst_card_info *card, dma_addr_t skb=
,
  *      Send a frame through the DMA
  */
 static inline void
-fst_tx_dma(struct fst_card_info *card, unsigned char *skb,
-	   unsigned char *mem, int len)
+fst_tx_dma(struct fst_card_info *card, dma_addr_t dma, u32 mem, int len)
 {
 	/*
 	 * This routine will setup the DMA and start it.
 	 */
=20
-	dbg(DBG_TX, "In fst_tx_dma %p %p %d\n", skb, mem, len);
+	dbg(DBG_TX, "In fst_tx_dma %x %x %d\n", (u32)dma, mem, len);
 	if (card->dmatx_in_progress) {
 		dbg(DBG_ASS, "In fst_tx_dma while dma in progress\n");
 	}
=20
-	outl((unsigned long) skb, card->pci_conf + DMAPADR1);	/* Copy from here *=
/
-	outl((unsigned long) mem, card->pci_conf + DMALADR1);	/* to here */
+	outl(dma, card->pci_conf + DMAPADR1);	/* Copy from here */
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
Ben Hutchings
Never attribute to conspiracy what can adequately be explained by stupidity=
.

--=-IutF22mOY/BkTcJl4lvZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU5Tohee/yOyVhhEJAQpgSw/+LUp62/AXc7LsVz/7QhvD5Ks3HJLYUUGO
ISNOoUgqccJsRwQg4yPFkjQQIvx8ICuaq8nxHbbrCzcRWmTkgHIw3CfQxJ60qwYb
8npPQ9lAM1U/igyqimAjtQ6Ez+mNHy+10ENGHZMUtu/i88Zo7XNur2TEV37iZvJq
s1GrIZRz+8+PciZp/RYmwzLcC4BKrEbJzg43W/klghYK8CzazIcc5yRa7yYOq8ok
BZOQU7HLPQYKA2LVPhlhxDS13VZ2EAWydWiqvZfCfPqu0k4CnGFREewUOdHzgS0P
pAwHcSPeS7jwfu8fqFgv7U5vr0/cXTtsWevAYh1ti4bkM8C2xlXrScYx2xJ8YOEj
T9Bj4Eahqn3UDziMn5ERk1Nk4bG+tMr8ywix3VbrWS86ssgVRs0p+MZwTyFMPO+y
XzNpGyNtzP6SBkIRFCNWvf7LBnIiJmIwzNiuCiAuAoKwz5AyW8KIldy33D8Npqsh
KuwVY6FyKvmPTg5VDZHb4tFawR6kXv1RZJ70hd32+OM4w46JUKVpuqP/F8CFRgnu
PNEE+h2OsWfNXTg3ID4xi2f6I091FSzPF8WTup/nIQe/JyUMS7WVWhbFfF74mS7i
bdIKA3Rh7uKm4gBP0VpIRt5Lrvn630tg3LPIqSyibx7qXXrDaeCytKJwptWMLdxq
j1+KdJrPIiM=
=damt
-----END PGP SIGNATURE-----

--=-IutF22mOY/BkTcJl4lvZ--
