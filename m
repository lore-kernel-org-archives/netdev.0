From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net] Revert "net: fec: fix the warning found by dma debug"
Date: Fri, 13 Mar 2015 14:07:54 -0300
Message-ID: <1426266474-6018-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: b38611@freescale.com, netdev@vger.kernel.org, rockford@yandex.ru,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:45298 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489AbbCMRIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 13:08:20 -0400
Received: by qcwb13 with SMTP id b13so28128157qcw.12
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 10:08:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fabio Estevam <fabio.estevam@freescale.com>

This reverts commit 2b995f63987013bacde99168218f9c7b252bdcf1.

=D0=9F=D0=B0=D0=BD=D0=BE=D0=B2 =D0=90=D0=BD=D0=B4=D1=80=D0=B5=D0=B9 rep=
orted the following regression:

"Commit 2b995f63987013bacde99168218f9c7b252bdcf1 in 4.0.0-rc3 introduce=
s a
nasty bug in transmit, corrupting packets.

To reproduce:

$ dd if=3D/dev/zero of=3Dzeros bs=3D1M count=3D20
$ md5sum -b zeros
8f4e33f3dc3e414ff94e5fb6905cba8c *zeros

This checksum is correct.

Copy file "zeros" to another host with NFS, and it gets corrupted, chec=
ksum is
changed.
=46ile should be big, small amounts of transmit isn't affected.

I use an i.MX6 Quad board.

If this commit is reverted, all works fine."

Reported-by: =D0=9F=D0=B0=D0=BD=D0=BE=D0=B2 =D0=90=D0=BD=D0=B4=D1=80=D0=
=B5=D0=B9 <rockford@yandex.ru>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 34 ++++++++++-------------=
--------
 1 file changed, 11 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 787db50..78e1ce0 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1189,13 +1189,12 @@ static void
 fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
 {
 	struct	fec_enet_private *fep;
-	struct bufdesc *bdp, *bdp_t;
+	struct bufdesc *bdp;
 	unsigned short status;
 	struct	sk_buff	*skb;
 	struct fec_enet_priv_tx_q *txq;
 	struct netdev_queue *nq;
 	int	index =3D 0;
-	int	i, bdnum;
 	int	entries_free;
=20
 	fep =3D netdev_priv(ndev);
@@ -1216,29 +1215,18 @@ fec_enet_tx_queue(struct net_device *ndev, u16 =
queue_id)
 		if (bdp =3D=3D txq->cur_tx)
 			break;
=20
-		bdp_t =3D bdp;
-		bdnum =3D 1;
-		index =3D fec_enet_get_bd_index(txq->tx_bd_base, bdp_t, fep);
-		skb =3D txq->tx_skbuff[index];
-		while (!skb) {
-			bdp_t =3D fec_enet_get_nextdesc(bdp_t, fep, queue_id);
-			index =3D fec_enet_get_bd_index(txq->tx_bd_base, bdp_t, fep);
-			skb =3D txq->tx_skbuff[index];
-			bdnum++;
-		}
-		if (skb_shinfo(skb)->nr_frags &&
-		    (status =3D bdp_t->cbd_sc) & BD_ENET_TX_READY)
-			break;
+		index =3D fec_enet_get_bd_index(txq->tx_bd_base, bdp, fep);
=20
-		for (i =3D 0; i < bdnum; i++) {
-			if (!IS_TSO_HEADER(txq, bdp->cbd_bufaddr))
-				dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
-						 bdp->cbd_datlen, DMA_TO_DEVICE);
-			bdp->cbd_bufaddr =3D 0;
-			if (i < bdnum - 1)
-				bdp =3D fec_enet_get_nextdesc(bdp, fep, queue_id);
-		}
+		skb =3D txq->tx_skbuff[index];
 		txq->tx_skbuff[index] =3D NULL;
+		if (!IS_TSO_HEADER(txq, bdp->cbd_bufaddr))
+			dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
+					bdp->cbd_datlen, DMA_TO_DEVICE);
+		bdp->cbd_bufaddr =3D 0;
+		if (!skb) {
+			bdp =3D fec_enet_get_nextdesc(bdp, fep, queue_id);
+			continue;
+		}
=20
 		/* Check for errors. */
 		if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC |
--=20
1.9.1
