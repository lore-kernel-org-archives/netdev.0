From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 2/8] farsync: Fix confusion about DMA address and buffer
 offset types
Date: Sun, 27 Oct 2013 21:51:44 +0000
Message-ID: <1382910704.2994.46.camel@deadeye.wl.decadent.org.uk>
References: <1382910437.2994.43.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-fhJyZh9yBQReUAhbE0rs"
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Kevin Curtis <kevin.curtis@farsite.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382910437.2994.43.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-fhJyZh9yBQReUAhbE0rs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Use dma_addr_t for DMA address parameters and u32 for shared memory
offset parameters.

Do not assume that dma_addr_t is the same as unsigned long; it will
not be in PAE configurations.  Truncate DMA addresses to 32 bits when
printing them.  This is OK because the DMA mask for this device is
32-bit (per default).

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/wan/farsync.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 3f0c4f2..4b36676 100644
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
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-fhJyZh9yBQReUAhbE0rs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUm2K8Oe/yOyVhhEJAQrYrQ//Y2A/R3z6G3v2Ax8Z7beBdLSCahlP4MGZ
O/coBIneIqLHVnXniScHNxEon7g3gxUocfq9Iucmg6/LWW1Xmxbc0FqBmSiduT+m
dnUtEvWB+K/qZC00zLEylNTplyMBFIFbs6mXqwnbvf6ObJZYsB8+h/CAM83yZSGX
ZSl6xRbp/ZJM+q2a2b+sVfmppGkEXYpsGgd8uS1T5hj6B6SH+2mJ/DVo6C1zjMr9
C1IcMdzi3HimfdseevayC0dJEJl2P+0IhzKvBcyzHrq8WoSh83PXNRODzwA2xsAL
ixxpes7q2AiFPHm2rwu+eDn67rtnRMJJPldNBZP3kbePTEfrcNV+8bMsvtF9tptQ
uu5Vget3AqjEbVCVbHTb+oDC98BxMJvmc1BPDIsYS1MF5XJDfmTlmOUiKbcYmbjz
zTJGX+m9o321Ik4CAL1h8dtEIsvAGC6qVXrR2pTacHu3ODXtDs5Qm+a31JCFyMbQ
RSokxaDxO6btJOzdrw8XkluYrxoAgQOhOjwkKHRgYgivpCLU4iJK9MWyMxSPXA4b
r1DicdI5oeDpD1Vo5NWVV0Q+1lKYin9e1HkyoxrjvMrwPKzSBQvIdI0QWPLQc01N
y8b5GRjzLQAeffYJ6W+xobWNHJ+u9QulW0lhqkjkZk2TWo35Shjjgz5RIpw60Amf
y9f23m1sRRg=
=0VO4
-----END PGP SIGNATURE-----

--=-fhJyZh9yBQReUAhbE0rs--
