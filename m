From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCHv2 net-next 3/4] caif-shm: Bugfixes for caif_shmcore.c
Date: Tue,  6 Dec 2011 23:15:43 +0100
Message-ID: <1323209744-9718-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1323209744-9718-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:62580 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754813Ab1LFWP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 17:15:58 -0500
Received: by mail-lpp01m010-f46.google.com with SMTP id p5so1832667lag.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 14:15:58 -0800 (PST)
In-Reply-To: <1323209744-9718-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various bugfixes for caif_shmcore.c:
- fix deadlocks due to improper usage of spin-lock
- add missing spin-lock init
- don't call dev_kfree_skb() with irqs disabled,
  use dev_kfree_skb_irq() instead.
- fix potential skb null pointer de-reference.

Squashed original patches from:
Rabin Vincent <rabin.vincent@stericsson.com>
Durga Prasada Rao BATHINA <durgaprasadarao.b@stericcson.com>
Arun Murthy <arun.murthy@stericsson.com>
Bibek Basu <bibek.basu@stericsson.com>

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
Change since v1:=20
- s/dev_kfree_skb_any/dev_kfree_skb_irq/
- fixed two pointer cast warnings

 drivers/net/caif/caif_shmcore.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/caif/caif_shmcore.c b/drivers/net/caif/caif_sh=
mcore.c
index d4b26fb..fd59e37 100644
--- a/drivers/net/caif/caif_shmcore.c
+++ b/drivers/net/caif/caif_shmcore.c
@@ -238,11 +238,11 @@ int caif_shmdrv_rx_cb(u32 mbx_msg, void *priv)
 		if ((avail_emptybuff > HIGH_WATERMARK) &&
 					(!pshm_drv->tx_empty_available)) {
 			pshm_drv->tx_empty_available =3D 1;
+			spin_unlock_irqrestore(&pshm_drv->lock, flags);
 			pshm_drv->cfdev.flowctrl
 					(pshm_drv->pshm_dev->pshm_netdev,
 								CAIF_FLOW_ON);
=20
-			spin_unlock_irqrestore(&pshm_drv->lock, flags);
=20
 			/* Schedule the work queue. if required */
 			if (!work_pending(&pshm_drv->shm_tx_work))
@@ -285,6 +285,7 @@ static void shm_rx_work_func(struct work_struct *rx=
_work)
 			list_entry(pshm_drv->rx_full_list.next, struct buf_list,
 					list);
 		list_del_init(&pbuf->list);
+		spin_unlock_irqrestore(&pshm_drv->lock, flags);
=20
 		/* Retrieve pointer to start of the packet descriptor area. */
 		pck_desc =3D (struct shm_pck_desc *) pbuf->desc_vptr;
@@ -360,6 +361,7 @@ static void shm_rx_work_func(struct work_struct *rx=
_work)
 			pck_desc++;
 		}
=20
+		spin_lock_irqsave(&pshm_drv->lock, flags);
 		list_add_tail(&pbuf->list, &pshm_drv->rx_pend_list);
=20
 		spin_unlock_irqrestore(&pshm_drv->lock, flags);
@@ -412,7 +414,6 @@ static void shm_tx_work_func(struct work_struct *tx=
_work)
=20
 		if (skb =3D=3D NULL)
 			goto send_msg;
-
 		/* Check the available no. of buffers in the empty list */
 		list_for_each(pos, &pshm_drv->tx_empty_list)
 			avail_emptybuff++;
@@ -421,9 +422,11 @@ static void shm_tx_work_func(struct work_struct *t=
x_work)
 					pshm_drv->tx_empty_available) {
 			/* Update blocking condition. */
 			pshm_drv->tx_empty_available =3D 0;
+			spin_unlock_irqrestore(&pshm_drv->lock, flags);
 			pshm_drv->cfdev.flowctrl
 					(pshm_drv->pshm_dev->pshm_netdev,
 					CAIF_FLOW_OFF);
+			spin_lock_irqsave(&pshm_drv->lock, flags);
 		}
 		/*
 		 * We simply return back to the caller if we do not have space
@@ -469,6 +472,8 @@ static void shm_tx_work_func(struct work_struct *tx=
_work)
 			}
=20
 			skb =3D skb_dequeue(&pshm_drv->sk_qhead);
+			if (skb =3D=3D NULL)
+				break;
 			/* Copy in CAIF frame. */
 			skb_copy_bits(skb, 0, pbuf->desc_vptr +
 					pbuf->frm_ofs + SHM_HDR_LEN +
@@ -477,7 +482,7 @@ static void shm_tx_work_func(struct work_struct *tx=
_work)
 			pshm_drv->pshm_dev->pshm_netdev->stats.tx_packets++;
 			pshm_drv->pshm_dev->pshm_netdev->stats.tx_bytes +=3D
 									frmlen;
-			dev_kfree_skb(skb);
+			dev_kfree_skb_irq(skb);
=20
 			/* Fill in the shared memory packet descriptor area. */
 			pck_desc =3D (struct shm_pck_desc *) (pbuf->desc_vptr);
@@ -512,16 +517,11 @@ send_msg:
 static int shm_netdev_tx(struct sk_buff *skb, struct net_device *shm_n=
etdev)
 {
 	struct shmdrv_layer *pshm_drv;
-	unsigned long flags =3D 0;
=20
 	pshm_drv =3D netdev_priv(shm_netdev);
=20
-	spin_lock_irqsave(&pshm_drv->lock, flags);
-
 	skb_queue_tail(&pshm_drv->sk_qhead, skb);
=20
-	spin_unlock_irqrestore(&pshm_drv->lock, flags);
-
 	/* Schedule Tx work queue. for deferred processing of skbs*/
 	if (!work_pending(&pshm_drv->shm_tx_work))
 		queue_work(pshm_drv->pshm_tx_workqueue, &pshm_drv->shm_tx_work);
@@ -606,6 +606,7 @@ int caif_shmcore_probe(struct shmdev_layer *pshm_de=
v)
 		pshm_drv->shm_rx_addr =3D pshm_dev->shm_base_addr +
 						(NR_TX_BUF * TX_BUF_SZ);
=20
+	spin_lock_init(&pshm_drv->lock);
 	INIT_LIST_HEAD(&pshm_drv->tx_empty_list);
 	INIT_LIST_HEAD(&pshm_drv->tx_pend_list);
 	INIT_LIST_HEAD(&pshm_drv->tx_full_list);
@@ -640,7 +641,7 @@ int caif_shmcore_probe(struct shmdev_layer *pshm_de=
v)
 		tx_buf->frm_ofs =3D SHM_CAIF_FRM_OFS;
=20
 		if (pshm_dev->shm_loopback)
-			tx_buf->desc_vptr =3D (char *)tx_buf->phy_addr;
+			tx_buf->desc_vptr =3D (unsigned char *)tx_buf->phy_addr;
 		else
 			tx_buf->desc_vptr =3D
 					ioremap(tx_buf->phy_addr, TX_BUF_SZ);
@@ -664,7 +665,7 @@ int caif_shmcore_probe(struct shmdev_layer *pshm_de=
v)
 		rx_buf->len =3D RX_BUF_SZ;
=20
 		if (pshm_dev->shm_loopback)
-			rx_buf->desc_vptr =3D (char *)rx_buf->phy_addr;
+			rx_buf->desc_vptr =3D (unsigned char *)rx_buf->phy_addr;
 		else
 			rx_buf->desc_vptr =3D
 					ioremap(rx_buf->phy_addr, RX_BUF_SZ);
--=20
1.7.0.4
