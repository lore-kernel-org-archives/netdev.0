From: akpm@linux-foundation.org
Subject: [patch 05/12] via-velocity: fix sleep-with-spinlock bug during MTU change
Date: Wed, 30 Jul 2008 12:38:58 -0700
Message-ID: <200807301938.m6UJcwrD012511@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	romieu@fr.zoreil.com, arjan@linux.intel.com,
	rseguier@e-teleport.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48610 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756177AbYG3Tkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:40:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

velocity_init_{rd/tx}_ring use kcalloc(..., GFP_KERNEL).

Allocate and free everyting outside of the locked section.

Spotted-by: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Fixed-by: Seguier Regis <rseguier@e-teleport.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/via-velocity.c |  132 ++++++++++++++++++++++-------------
 1 file changed, 86 insertions(+), 46 deletions(-)

diff -puN drivers/net/via-velocity.c~via-velocity-fix-sleep-with-spinlock-bug-during-mtu-change drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c~via-velocity-fix-sleep-with-spinlock-bug-during-mtu-change
+++ a/drivers/net/via-velocity.c
@@ -662,6 +662,10 @@ static void velocity_vlan_rx_kill_vid(st
         spin_unlock_irq(&vptr->lock);
 }
 
+static void velocity_init_rx_ring_indexes(struct velocity_info *vptr)
+{
+	vptr->rx.dirty = vptr->rx.filled = vptr->rx.curr = 0;
+}
 
 /**
  *	velocity_rx_reset	-	handle a receive reset
@@ -677,7 +681,7 @@ static void velocity_rx_reset(struct vel
 	struct mac_regs __iomem * regs = vptr->mac_regs;
 	int i;
 
-	vptr->rx.dirty = vptr->rx.filled = vptr->rx.curr = 0;
+	velocity_init_rx_ring_indexes(vptr);
 
 	/*
 	 *	Init state, all RD entries belong to the NIC
@@ -1093,14 +1097,14 @@ static int __devinit velocity_get_pci_in
 }
 
 /**
- *	velocity_init_rings	-	set up DMA rings
+ *	velocity_init_dma_rings	-	set up DMA rings
  *	@vptr: Velocity to set up
  *
  *	Allocate PCI mapped DMA rings for the receive and transmit layer
  *	to use.
  */
 
-static int velocity_init_rings(struct velocity_info *vptr)
+static int velocity_init_dma_rings(struct velocity_info *vptr)
 {
 	struct velocity_opt *opt = &vptr->options;
 	const unsigned int rx_ring_size = opt->numrx * sizeof(struct rx_desc);
@@ -1141,13 +1145,13 @@ static int velocity_init_rings(struct ve
 }
 
 /**
- *	velocity_free_rings	-	free PCI ring pointers
+ *	velocity_free_dma_rings	-	free PCI ring pointers
  *	@vptr: Velocity to free from
  *
  *	Clean up the PCI ring buffers allocated to this velocity.
  */
 
-static void velocity_free_rings(struct velocity_info *vptr)
+static void velocity_free_dma_rings(struct velocity_info *vptr)
 {
 	const int size = vptr->options.numrx * sizeof(struct rx_desc) +
 		vptr->options.numtx * sizeof(struct tx_desc) * vptr->tx.numq;
@@ -1229,7 +1233,7 @@ static int velocity_init_rd_ring(struct 
 	if (!vptr->rx.info)
 		goto out;
 
-	vptr->rx.filled = vptr->rx.dirty = vptr->rx.curr = 0;
+	velocity_init_rx_ring_indexes(vptr);
 
 	if (velocity_rx_refill(vptr) != vptr->options.numrx) {
 		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
@@ -1847,6 +1851,40 @@ static void velocity_free_tx_buf(struct 
 	tdinfo->skb = NULL;
 }
 
+static int velocity_init_rings(struct velocity_info *vptr, int mtu)
+{
+	int ret;
+
+	velocity_set_rxbufsize(vptr, mtu);
+
+	ret = velocity_init_dma_rings(vptr);
+	if (ret < 0)
+		goto out;
+
+	ret = velocity_init_rd_ring(vptr);
+	if (ret < 0)
+		goto err_free_dma_rings_0;
+
+	ret = velocity_init_td_ring(vptr);
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
@@ -1863,20 +1901,10 @@ static int velocity_open(struct net_devi
 	struct velocity_info *vptr = netdev_priv(dev);
 	int ret;
 
-	velocity_set_rxbufsize(vptr, dev->mtu);
-
-	ret = velocity_init_rings(vptr);
+	ret = velocity_init_rings(vptr, dev->mtu);
 	if (ret < 0)
 		goto out;
 
-	ret = velocity_init_rd_ring(vptr);
-	if (ret < 0)
-		goto err_free_desc_rings;
-
-	ret = velocity_init_td_ring(vptr);
-	if (ret < 0)
-		goto err_free_rd_ring;
-
 	/* Ensure chip is running */
 	pci_set_power_state(vptr->pdev, PCI_D0);
 
@@ -1889,7 +1917,8 @@ static int velocity_open(struct net_devi
 	if (ret < 0) {
 		/* Power down the chip */
 		pci_set_power_state(vptr->pdev, PCI_D3hot);
-		goto err_free_td_ring;
+		velocity_free_rings(vptr);
+		goto out;
 	}
 
 	mac_enable_int(vptr->mac_regs);
@@ -1897,14 +1926,6 @@ static int velocity_open(struct net_devi
 	vptr->flags |= VELOCITY_FLAGS_OPENED;
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
 
 /**
@@ -1920,50 +1941,72 @@ err_free_desc_rings:
 static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
-	unsigned long flags;
-	int oldmtu = dev->mtu;
 	int ret = 0;
 
 	if ((new_mtu < VELOCITY_MIN_MTU) || new_mtu > (VELOCITY_MAX_MTU)) {
 		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_NOTICE "%s: Invalid MTU.\n",
 				vptr->dev->name);
-		return -EINVAL;
+		ret = -EINVAL;
+		goto out_0;
 	}
 
 	if (!netif_running(dev)) {
 		dev->mtu = new_mtu;
-		return 0;
+		goto out_0;
 	}
 
-	if (new_mtu != oldmtu) {
+	if (dev->mtu != new_mtu) {
+		struct velocity_info *tmp_vptr;
+		unsigned long flags;
+		struct rx_info rx;
+		struct tx_info tx;
+
+		tmp_vptr = kzalloc(sizeof(*tmp_vptr), GFP_KERNEL);
+		if (!tmp_vptr) {
+			ret = -ENOMEM;
+			goto out_0;
+		}
+
+		tmp_vptr->dev = dev;
+		tmp_vptr->pdev = vptr->pdev;
+		tmp_vptr->options = vptr->options;
+		tmp_vptr->tx.numq = vptr->tx.numq;
+
+		ret = velocity_init_rings(tmp_vptr, new_mtu);
+		if (ret < 0)
+			goto out_free_tmp_vptr_1;
+
 		spin_lock_irqsave(&vptr->lock, flags);
 
 		netif_stop_queue(dev);
 		velocity_shutdown(vptr);
 
-		velocity_free_td_ring(vptr);
-		velocity_free_rd_ring(vptr);
+		rx = vptr->rx;
+		tx = vptr->tx;
 
-		dev->mtu = new_mtu;
+		vptr->rx = tmp_vptr->rx;
+		vptr->tx = tmp_vptr->tx;
 
-		velocity_set_rxbufsize(vptr, new_mtu);
+		tmp_vptr->rx = rx;
+		tmp_vptr->tx = tx;
 
-		ret = velocity_init_rd_ring(vptr);
-		if (ret < 0)
-			goto out_unlock;
+		dev->mtu = new_mtu;
 
-		ret = velocity_init_td_ring(vptr);
-		if (ret < 0)
-			goto out_unlock;
+		velocity_give_many_rx_descs(vptr);
 
 		velocity_init_registers(vptr, VELOCITY_INIT_COLD);
 
 		mac_enable_int(vptr->mac_regs);
 		netif_start_queue(dev);
-out_unlock:
+
 		spin_unlock_irqrestore(&vptr->lock, flags);
-	}
 
+		velocity_free_rings(tmp_vptr);
+
+out_free_tmp_vptr_1:
+		kfree(tmp_vptr);
+	}
+out_0:
 	return ret;
 }
 
@@ -2009,9 +2052,6 @@ static int velocity_close(struct net_dev
 	/* Power down the chip */
 	pci_set_power_state(vptr->pdev, PCI_D3hot);
 
-	/* Free the resources */
-	velocity_free_td_ring(vptr);
-	velocity_free_rd_ring(vptr);
 	velocity_free_rings(vptr);
 
 	vptr->flags &= (~VELOCITY_FLAGS_OPENED);
_
