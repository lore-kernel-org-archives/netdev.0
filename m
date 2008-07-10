From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/6] via-velocity: remove the bounce buffers
Date: Fri, 11 Jul 2008 00:03:44 +0200
Message-ID: <20080710220344.GB29764@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?unknown-8bit?B?U8OpZ3VpZXIgUsOpZ2lz?= <rseguier@e-teleport.net>,
	akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38107 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752919AbYGJWE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:04:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Executive summary: the bounce buffers are in my way

- they use something like a 64 * 1500 bytes area of PCI
  consistent area
- they are not resized when the MTU changes
- they are used
  - to hand-pad undersized packets. skb_pad anyone ?
  - to linearize fragmented skbs whose fragment count
    goes beyond the 7 fragments hardware limit in order
    to claim scatter-gather support

Actually the SG code is commented out and I wonder if it
could not be implemented (ab-)using the large send feature
of the chipset since the latter should support some
multi-descriptor packet transmitting.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
=46ixed-by: S=C3=A9guier R=C3=A9gis <rseguier@e-teleport.net>
---
 drivers/net/via-velocity.c |   72 +++++++++++-------------------------=
--------
 drivers/net/via-velocity.h |    5 ---
 2 files changed, 18 insertions(+), 59 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 6b8d882..117dbea 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1104,7 +1104,6 @@ static int velocity_init_rings(struct velocity_in=
fo *vptr)
 {
 	int i;
 	unsigned int psize;
-	unsigned int tsize;
 	dma_addr_t pool_dma;
 	u8 *pool;
=20
@@ -1133,19 +1132,6 @@ static int velocity_init_rings(struct velocity_i=
nfo *vptr)
=20
 	vptr->rd_pool_dma =3D pool_dma;
=20
-	tsize =3D vptr->options.numtx * PKT_BUF_SZ * vptr->num_txq;
-	vptr->tx_bufs =3D pci_alloc_consistent(vptr->pdev, tsize,
-						&vptr->tx_bufs_dma);
-
-	if (vptr->tx_bufs =3D=3D NULL) {
-		printk(KERN_ERR "%s: DMA memory allocation failed.\n",
-					vptr->dev->name);
-		pci_free_consistent(vptr->pdev, psize, pool, pool_dma);
-		return -ENOMEM;
-	}
-
-	memset(vptr->tx_bufs, 0, vptr->options.numtx * PKT_BUF_SZ * vptr->num=
_txq);
-
 	i =3D vptr->options.numrx * sizeof(struct rx_desc);
 	pool +=3D i;
 	pool_dma +=3D i;
@@ -1169,16 +1155,10 @@ static int velocity_init_rings(struct velocity_=
info *vptr)
=20
 static void velocity_free_rings(struct velocity_info *vptr)
 {
-	int size;
-
-	size =3D vptr->options.numrx * sizeof(struct rx_desc) +
-	       vptr->options.numtx * sizeof(struct tx_desc) * vptr->num_txq;
+	const int size =3D vptr->options.numrx * sizeof(struct rx_desc) +
+		vptr->options.numtx * sizeof(struct tx_desc) * vptr->num_txq;
=20
 	pci_free_consistent(vptr->pdev, size, vptr->rd_ring, vptr->rd_pool_dm=
a);
-
-	size =3D vptr->options.numtx * PKT_BUF_SZ * vptr->num_txq;
-
-	pci_free_consistent(vptr->pdev, size, vptr->tx_bufs, vptr->tx_bufs_dm=
a);
 }
=20
 static inline void velocity_give_many_rx_descs(struct velocity_info *v=
ptr)
@@ -1313,10 +1293,8 @@ static void velocity_free_rd_ring(struct velocit=
y_info *vptr)
=20
 static int velocity_init_td_ring(struct velocity_info *vptr)
 {
-	int i, j;
 	dma_addr_t curr;
-	struct tx_desc *td;
-	struct velocity_td_info *td_info;
+	unsigned int j;
=20
 	/* Init the TD ring entries */
 	for (j =3D 0; j < vptr->num_txq; j++) {
@@ -1331,14 +1309,6 @@ static int velocity_init_td_ring(struct velocity=
_info *vptr)
 			return -ENOMEM;
 		}
=20
-		for (i =3D 0; i < vptr->options.numtx; i++, curr +=3D sizeof(struct =
tx_desc)) {
-			td =3D &(vptr->td_rings[j][i]);
-			td_info =3D &(vptr->td_infos[j][i]);
-			td_info->buf =3D vptr->tx_bufs +
-				(j * vptr->options.numtx + i) * PKT_BUF_SZ;
-			td_info->buf_dma =3D vptr->tx_bufs_dma +
-				(j * vptr->options.numtx + i) * PKT_BUF_SZ;
-		}
 		vptr->td_tail[j] =3D vptr->td_curr[j] =3D vptr->td_used[j] =3D 0;
 	}
 	return 0;
@@ -1878,7 +1848,7 @@ static void velocity_free_tx_buf(struct velocity_=
info *vptr, struct velocity_td_
 	/*
 	 *	Don't unmap the pre-allocated tx_bufs
 	 */
-	if (tdinfo->skb_dma && (tdinfo->skb_dma[0] !=3D tdinfo->buf_dma)) {
+	if (tdinfo->skb_dma) {
=20
 		for (i =3D 0; i < tdinfo->nskb_dma; i++) {
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
@@ -2074,9 +2044,19 @@ static int velocity_xmit(struct sk_buff *skb, st=
ruct net_device *dev)
 	struct tx_desc *td_ptr;
 	struct velocity_td_info *tdinfo;
 	unsigned long flags;
-	int index;
 	int pktlen =3D skb->len;
-	__le16 len =3D cpu_to_le16(pktlen);
+	__le16 len;
+	int index;
+
+
+
+	if (skb->len < ETH_ZLEN) {
+		if (skb_padto(skb, ETH_ZLEN))
+			goto out;
+		pktlen =3D ETH_ZLEN;
+	}
+
+	len =3D cpu_to_le16(pktlen);
=20
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
 	if (skb_shinfo(skb)->nr_frags > 6 && __skb_linearize(skb)) {
@@ -2094,23 +2074,6 @@ static int velocity_xmit(struct sk_buff *skb, st=
ruct net_device *dev)
 	td_ptr->tdesc1.TCR =3D TCR0_TIC;
 	td_ptr->td_buf[0].size &=3D ~TD_QUEUE;
=20
-	/*
-	 *	Pad short frames.
-	 */
-	if (pktlen < ETH_ZLEN) {
-		/* Cannot occur until ZC support */
-		pktlen =3D ETH_ZLEN;
-		len =3D cpu_to_le16(ETH_ZLEN);
-		skb_copy_from_linear_data(skb, tdinfo->buf, skb->len);
-		memset(tdinfo->buf + skb->len, 0, ETH_ZLEN - skb->len);
-		tdinfo->skb =3D skb;
-		tdinfo->skb_dma[0] =3D tdinfo->buf_dma;
-		td_ptr->tdesc0.len =3D len;
-		td_ptr->td_buf[0].pa_low =3D cpu_to_le32(tdinfo->skb_dma[0]);
-		td_ptr->td_buf[0].pa_high =3D 0;
-		td_ptr->td_buf[0].size =3D len;	/* queue is 0 anyway */
-		tdinfo->nskb_dma =3D 1;
-	} else
 #ifdef VELOCITY_ZERO_COPY_SUPPORT
 	if (skb_shinfo(skb)->nr_frags > 0) {
 		int nfrags =3D skb_shinfo(skb)->nr_frags;
@@ -2202,7 +2165,8 @@ static int velocity_xmit(struct sk_buff *skb, str=
uct net_device *dev)
 	}
 	dev->trans_start =3D jiffies;
 	spin_unlock_irqrestore(&vptr->lock, flags);
-	return 0;
+out:
+	return NETDEV_TX_OK;
 }
=20
 /**
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 7387be4..8644614 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -236,10 +236,8 @@ struct velocity_rd_info {
=20
 struct velocity_td_info {
 	struct sk_buff *skb;
-	u8 *buf;
 	int nskb_dma;
 	dma_addr_t skb_dma[7];
-	dma_addr_t buf_dma;
 };
=20
 enum  velocity_owner {
@@ -1506,9 +1504,6 @@ struct velocity_info {
 	dma_addr_t rd_pool_dma;
 	dma_addr_t td_pool_dma[TX_QUEUE_NO];
=20
-	dma_addr_t tx_bufs_dma;
-	u8 *tx_bufs;
-
 	struct vlan_group    *vlgrp;
 	u8 ip_addr[4];
 	enum chip_type chip_id;
--=20
1.5.3.3
