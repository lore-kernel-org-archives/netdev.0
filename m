From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 6/6] via-velocity: fix sleep-with-spinlock bug during MTU
	change
Date: Fri, 11 Jul 2008 00:07:16 +0200
Message-ID: <20080710220716.GG29764@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?unknown-8bit?B?U8OpZ3VpZXIgUsOpZ2lz?= <rseguier@e-teleport.net>,
	akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33960 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752921AbYGJWIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:08:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

velocity_init_{rd/tx}_ring use kcalloc(..., GFP_KERNEL).

Allocate and free everyting outside of the locked section.

Spotted-by: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
=46ixed-by: S=C3=A9guier R=C3=A9gis <rseguier@e-teleport.net>
---
 drivers/net/via-velocity.c |  132 ++++++++++++++++++++++++++++--------=
-------
 1 files changed, 86 insertions(+), 46 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 66b32b5..265fbff 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -662,6 +662,10 @@ static void velocity_vlan_rx_kill_vid(struct net_d=
evice *dev, unsigned short vid
         spin_unlock_irq(&vptr->lock);
 }
=20
+static void velocity_init_rx_ring_indexes(struct velocity_info *vptr)
+{
+	vptr->rx.dirty =3D vptr->rx.filled =3D vptr->rx.curr =3D 0;
+}
=20
 /**
  *	velocity_rx_reset	-	handle a receive reset
@@ -677,7 +681,7 @@ static void velocity_rx_reset(struct velocity_info =
*vptr)
 	struct mac_regs __iomem * regs =3D vptr->mac_regs;
 	int i;
=20
-	vptr->rx.dirty =3D vptr->rx.filled =3D vptr->rx.curr =3D 0;
+	velocity_init_rx_ring_indexes(vptr);
=20
 	/*
 	 *	Init state, all RD entries belong to the NIC
@@ -1093,14 +1097,14 @@ static int __devinit velocity_get_pci_info(stru=
ct velocity_info *vptr, struct pc
 }
=20
 /**
- *	velocity_init_rings	-	set up DMA rings
+ *	velocity_init_dma_rings	-	set up DMA rings
  *	@vptr: Velocity to set up
  *
  *	Allocate PCI mapped DMA rings for the receive and transmit layer
  *	to use.
  */
=20
-static int velocity_init_rings(struct velocity_info *vptr)
+static int velocity_init_dma_rings(struct velocity_info *vptr)
 {
 	struct velocity_opt *opt =3D &vptr->options;
 	const unsigned int rx_ring_size =3D opt->numrx * sizeof(struct rx_des=
c);
@@ -1141,13 +1145,13 @@ static int velocity_init_rings(struct velocity_=
info *vptr)
 }
=20
 /**
- *	velocity_free_rings	-	free PCI ring pointers
+ *	velocity_free_dma_rings	-	free PCI ring pointers
  *	@vptr: Velocity to free from
  *
  *	Clean up the PCI ring buffers allocated to this velocity.
  */
=20
-static void velocity_free_rings(struct velocity_info *vptr)
+static void velocity_free_dma_rings(struct velocity_info *vptr)
 {
 	const int size =3D vptr->options.numrx * sizeof(struct rx_desc) +
 		vptr->options.numtx * sizeof(struct tx_desc) * vptr->tx.numq;
@@ -1229,7 +1233,7 @@ static int velocity_init_rd_ring(struct velocity_=
info *vptr)
 	if (!vptr->rx.info)
 		goto out;
=20
-	vptr->rx.filled =3D vptr->rx.dirty =3D vptr->rx.curr =3D 0;
+	velocity_init_rx_ring_indexes(vptr);
=20
 	if (velocity_rx_refill(vptr) !=3D vptr->options.numrx) {
 		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
@@ -1857,6 +1861,40 @@ static void velocity_free_tx_buf(struct velocity=
_info *vptr, struct velocity_td_
 	tdinfo->skb =3D NULL;
 }
=20
+static int velocity_init_rings(struct velocity_info *vptr, int mtu)
+{
+	int ret;
+
+	velocity_set_rxbufsize(vptr, mtu);
+
+	ret =3D velocity_init_dma_rings(vptr);
+	if (ret < 0)
+		goto out;
+
+	ret =3D velocity_init_rd_ring(vptr);
+	if (ret < 0)
+		goto err_free_dma_rings_0;
+
+	ret =3D velocity_init_td_ring(vptr);
+	if (ret < 0)
+		goto err_free_rd_ring_1;
+out:
+	return ret;
+
+err_free_rd_ring_1:
+	velocity_free_rd_ring(vptr);
+err_free_dma_rings_0:
+	velocity_free_dma_rings(vptr);
+	goto out;
+}
+
+static void velocity_free_rings(struct velocity_info *vptr)
+{
+	velocity_free_td_ring(vptr);
+	velocity_free_rd_ring(vptr);
+	velocity_free_dma_rings(vptr);
+}
+
 /**
  *	velocity_open		-	interface activation callback
  *	@dev: network layer device to open
@@ -1873,20 +1911,10 @@ static int velocity_open(struct net_device *dev=
)
 	struct velocity_info *vptr =3D netdev_priv(dev);
 	int ret;
=20
-	velocity_set_rxbufsize(vptr, dev->mtu);
-
-	ret =3D velocity_init_rings(vptr);
+	ret =3D velocity_init_rings(vptr, dev->mtu);
 	if (ret < 0)
 		goto out;
=20
-	ret =3D velocity_init_rd_ring(vptr);
-	if (ret < 0)
-		goto err_free_desc_rings;
-
-	ret =3D velocity_init_td_ring(vptr);
-	if (ret < 0)
-		goto err_free_rd_ring;
-
 	/* Ensure chip is running */
 	pci_set_power_state(vptr->pdev, PCI_D0);
=20
@@ -1899,7 +1927,8 @@ static int velocity_open(struct net_device *dev)
 	if (ret < 0) {
 		/* Power down the chip */
 		pci_set_power_state(vptr->pdev, PCI_D3hot);
-		goto err_free_td_ring;
+		velocity_free_rings(vptr);
+		goto out;
 	}
=20
 	mac_enable_int(vptr->mac_regs);
@@ -1907,14 +1936,6 @@ static int velocity_open(struct net_device *dev)
 	vptr->flags |=3D VELOCITY_FLAGS_OPENED;
 out:
 	return ret;
-
-err_free_td_ring:
-	velocity_free_td_ring(vptr);
-err_free_rd_ring:
-	velocity_free_rd_ring(vptr);
-err_free_desc_rings:
-	velocity_free_rings(vptr);
-	goto out;
 }
=20
 /**
@@ -1930,50 +1951,72 @@ err_free_desc_rings:
 static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct velocity_info *vptr =3D netdev_priv(dev);
-	unsigned long flags;
-	int oldmtu =3D dev->mtu;
 	int ret =3D 0;
=20
 	if ((new_mtu < VELOCITY_MIN_MTU) || new_mtu > (VELOCITY_MAX_MTU)) {
 		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_NOTICE "%s: Invalid MTU.\n",
 				vptr->dev->name);
-		return -EINVAL;
+		ret =3D -EINVAL;
+		goto out_0;
 	}
=20
 	if (!netif_running(dev)) {
 		dev->mtu =3D new_mtu;
-		return 0;
+		goto out_0;
 	}
=20
-	if (new_mtu !=3D oldmtu) {
+	if (dev->mtu !=3D new_mtu) {
+		struct velocity_info *tmp_vptr;
+		unsigned long flags;
+		struct rx_info rx;
+		struct tx_info tx;
+
+		tmp_vptr =3D kzalloc(sizeof(*tmp_vptr), GFP_KERNEL);
+		if (!tmp_vptr) {
+			ret =3D -ENOMEM;
+			goto out_0;
+		}
+
+		tmp_vptr->dev =3D dev;
+		tmp_vptr->pdev =3D vptr->pdev;
+		tmp_vptr->options =3D vptr->options;
+		tmp_vptr->tx.numq =3D vptr->tx.numq;
+
+		ret =3D velocity_init_rings(tmp_vptr, new_mtu);
+		if (ret < 0)
+			goto out_free_tmp_vptr_1;
+
 		spin_lock_irqsave(&vptr->lock, flags);
=20
 		netif_stop_queue(dev);
 		velocity_shutdown(vptr);
=20
-		velocity_free_td_ring(vptr);
-		velocity_free_rd_ring(vptr);
+		rx =3D vptr->rx;
+		tx =3D vptr->tx;
=20
-		dev->mtu =3D new_mtu;
+		vptr->rx =3D tmp_vptr->rx;
+		vptr->tx =3D tmp_vptr->tx;
=20
-		velocity_set_rxbufsize(vptr, new_mtu);
+		tmp_vptr->rx =3D rx;
+		tmp_vptr->tx =3D tx;
=20
-		ret =3D velocity_init_rd_ring(vptr);
-		if (ret < 0)
-			goto out_unlock;
+		dev->mtu =3D new_mtu;
=20
-		ret =3D velocity_init_td_ring(vptr);
-		if (ret < 0)
-			goto out_unlock;
+		velocity_give_many_rx_descs(vptr);
=20
 		velocity_init_registers(vptr, VELOCITY_INIT_COLD);
=20
 		mac_enable_int(vptr->mac_regs);
 		netif_start_queue(dev);
-out_unlock:
+
 		spin_unlock_irqrestore(&vptr->lock, flags);
-	}
=20
+		velocity_free_rings(tmp_vptr);
+
+out_free_tmp_vptr_1:
+		kfree(tmp_vptr);
+	}
+out_0:
 	return ret;
 }
=20
@@ -2019,9 +2062,6 @@ static int velocity_close(struct net_device *dev)
 	/* Power down the chip */
 	pci_set_power_state(vptr->pdev, PCI_D3hot);
=20
-	/* Free the resources */
-	velocity_free_td_ring(vptr);
-	velocity_free_rd_ring(vptr);
 	velocity_free_rings(vptr);
=20
 	vptr->flags &=3D (~VELOCITY_FLAGS_OPENED);
--=20
1.5.3.3

