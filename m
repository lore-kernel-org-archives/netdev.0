From: Gregory CLEMENT <novexz@gmail.com>
Subject: [PATCH] MACB: clear transmit buffers properly on TX Underrun
Date: Thu, 13 Dec 2007 08:51:57 +0100
Message-ID: <4760E49D.5040406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: hskinnemoen@atmel.com, linux-arm-kernel@lists.arm.linux.org.uk,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:7558 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758666AbXLMHvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 02:51:40 -0500
Received: by nf-out-0910.google.com with SMTP id g13so466825nfb.21
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 23:51:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I generated this patch for linux 2.6.24-rc5 and test it on AT91SAM9263=20
with iperf.

=46rom: Gregory CLEMENT <gclement00@gmail.com>
Date: Wed, 12 Dec 2007 18:10:14 +0100
Subject: [PATCH] MACB: clear transmit buffers properly on TX Underrun

Initially transmit buffer pointers were only reset. But buffer descript=
ors
were possibly still set as ready, and buffer in upper layer was not
freed. This caused driver hang under big load.
Now reset clean properly the buffer descriptor and freed upper layer.

Signed-off-by: Gregory CLEMENT <gclement00@gmail.com>
---
 drivers/net/macb.c |   26 +++++++++++++++++++++++++-
 1 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 047ea7b..2ee1dab 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -307,9 +307,33 @@ static void macb_tx(struct macb *bp)
         (unsigned long)status);
=20
     if (status & MACB_BIT(UND)) {
+        int i;
         printk(KERN_ERR "%s: TX underrun, resetting buffers\n",
-               bp->dev->name);
+               bp->dev->name);
+
+        head =3D bp->tx_head;
+
+        /* free transmit buffer in upper layer*/
+        for (tail =3D bp->tx_tail; tail !=3D head; tail =3D NEXT_TX(ta=
il)) {
+            struct ring_info *rp =3D &bp->tx_skb[tail];
+            struct sk_buff *skb =3D rp->skb;
+
+            BUG_ON(skb =3D=3D NULL);
+
+            rmb();
+
+            dma_unmap_single(&bp->pdev->dev, rp->mapping, skb->len,
+                             DMA_TO_DEVICE);
+            rp->skb =3D NULL;
+            dev_kfree_skb_irq(skb);
+        }
+
+        /*Mark all the buffer as used to avoid sending a lost buffer*/
+        for (i =3D 0; i < RX_RING_SIZE; i++)
+            bp->tx_ring[i].ctrl =3D MACB_BIT(TX_USED);
+
         bp->tx_head =3D bp->tx_tail =3D 0;
+
     }
=20
     if (!(status & MACB_BIT(COMP)))
--=20
1.5.3.7


--=20
Gregory CLEMENT
Adeneo
Adetel Group
2, chemin du Ruisseau
69134 ECULLY - FRANCE
T=E9l. : +33 (0)4 72 18 08 40 - Fax : +33 (0)4 72 18 08 41

www.adetelgroup.com

