From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] Re: VIA "Velocity" Gigabit ethernet driver
Date: Tue, 1 Jun 2004 00:35:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040601003503.A19358@electric-eye.fr.zoreil.com>
References: <20040526174018.GA29119@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="FL5UXtIhxfXey3p5"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040526174018.GA29119@devserv.devel.redhat.com>; from alan@redhat.com on Wed, May 26, 2004 at 01:40:18PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Alan Cox <alan@redhat.com> :
> A cleaned up and 2.6 ported VIA velocity driver is now available on
> ftp://people/redhat.com/alan/Kernel/. This is an initial clean up and
> port to 2.6. It isn't by any means polished yet. Please send test results
> and patches to me (I don't currently read linux-kernel).

Some polish attached. I'll probably do the rx_copybreak thing as well as
some pci_dma_sync_single_for_{cpu/device} if nobody beats me.

Apparently there's no documentation available for the chipset, right ?

--
Ueimor

--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="via-velocity-00.patch"


- missing pci_disable_device() in the pci probe/remove functions;
- ioremap can fail;
- let's propagate the error codes instead of overriding these;
- velocity_free_info() removed.

Non void velocity_get_pci_info() probably deserves an explanation but I
do not have one :o)


 net/via-velocity.h         |    0 
 drivers/net/via-velocity.c |   81 ++++++++++++++++++---------------------------
 2 files changed, 34 insertions(+), 47 deletions(-)

diff -puN drivers/net/via-velocity.c~via-velocity-00 drivers/net/via-velocity.c
--- linux-2.6.6-mm4/drivers/net/via-velocity.c~via-velocity-00	2004-05-31 21:07:14.000000000 +0200
+++ linux-2.6.6-mm4-fr/drivers/net/via-velocity.c	2004-05-31 21:31:16.000000000 +0200
@@ -244,7 +244,6 @@ VELOCITY_PARAM(int_works, "Number of pac
 
 static int velocity_found1(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void velocity_init_info(struct pci_dev *pdev, struct velocity_info *vptr, struct velocity_info_tbl *info);
-static void velocity_free_info(struct velocity_info *vptr);
 static int velocity_get_pci_info(struct velocity_info *, struct pci_dev *pdev);
 static void velocity_print_info(struct velocity_info *vptr);
 static int velocity_open(struct net_device *dev);
@@ -341,11 +340,13 @@ static void __devexit velocity_remove1(s
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct velocity_info *vptr = dev->priv;
+
 	unregister_netdev(dev);
-	velocity_free_info(vptr);
+	iounmap(vptr->mac_regs);
 	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
-
 }
 
 /**
@@ -674,6 +675,7 @@ static int velocity_found1(struct pci_de
 	struct velocity_info_tbl *info = (struct velocity_info_tbl *) ent->driver_data;
 	struct velocity_info *vptr;
 	struct mac_regs * regs;
+	int ret = -ENOMEM;
 
 	if (velocity_nics++ >= MAX_UNITS) {
 		printk(KERN_NOTICE VELOCITY_NAME ": already found %d NICs.\n", 
@@ -685,7 +687,7 @@ static int velocity_found1(struct pci_de
 
 	if (dev == NULL) {
 		printk(KERN_ERR VELOCITY_NAME ": allocate net device failed.\n");
-		return -ENODEV;
+		goto out;
 	}
 	
 	/* Chain it all together */
@@ -710,28 +712,28 @@ static int velocity_found1(struct pci_de
 	dev->priv = vptr;
 	dev->irq = pdev->irq;
 
-	if (pci_enable_device(pdev)) {
-		velocity_free_info(vptr);
-		free_netdev(dev);
-		return -ENODEV;
-	}
+	ret = pci_enable_device(pdev);
+	if (ret < 0) 
+		goto err_free_dev;
 
-	if (velocity_get_pci_info(vptr, pdev) < 0) {
+	ret = velocity_get_pci_info(vptr, pdev);
+	if (ret < 0) {
 		printk(KERN_ERR VELOCITY_NAME ": Failed to find PCI device.\n");
-		velocity_free_info(vptr);
-		free_netdev(dev);
-		return -ENODEV;
+		goto err_disable;
 	}
 
-	if ((i = pci_request_regions(pdev, VELOCITY_NAME)) < 0) {
+	ret = pci_request_regions(pdev, VELOCITY_NAME);
+	if (ret < 0) {
 		printk(KERN_ERR VELOCITY_NAME ": Failed to find PCI device.\n");
-		vptr->ioaddr = 0;
-		velocity_free_info(vptr);
-		free_netdev(dev);
-		return i;
+		goto err_disable;
 	}
 
 	regs = ioremap(vptr->memaddr, vptr->io_size);
+	if (regs == NULL) {
+		ret = -EIO;
+		goto err_release_res;
+	}
+
 	vptr->mac_regs = regs;
 
 	mac_wol_reset(regs);
@@ -778,14 +780,9 @@ static int velocity_found1(struct pci_de
 		dev->features |= NETIF_F_HW_CSUM;
 	}
 
-	i = register_netdev (dev);
-	if (i)
-	{
-		pci_release_regions(pdev);
-		velocity_free_info(vptr);
-		free_netdev(dev);
-		return i;
-	}
+	ret = register_netdev(dev);
+	if (ret < 0)
+		goto err_iounmap;
 
 	velocity_print_info(vptr);
 	pci_set_drvdata(pdev, dev);
@@ -793,8 +790,18 @@ static int velocity_found1(struct pci_de
 	/* and leave the chip powered down */
 	
 	pci_set_power_state(pdev, 3);
+out:
+	return ret;
 
-	return 0;
+err_iounmap:
+	iounmap(regs);
+err_release_res:
+	pci_release_regions(pdev);
+err_disable:
+	pci_disable_device(pdev);
+err_free_dev:
+	free_netdev(dev);
+	goto out;
 }
 
 /**
@@ -864,26 +871,6 @@ static int velocity_get_pci_info(struct 
 }
 
 /**
- *	velocity_free_info	-	free velocity data
- *	@vptr: velocity
- *
- *	Free up the data structures for the velocity hardware
- *	that we are unloading. Relies on the PCI layer threading/locking
- *	rather than its own locks. Must not be called until the device
- *	is unplugged from the network layer
- */
- 
-static void velocity_free_info(struct velocity_info *vptr)
-{
-	ASSERT(vptr);
-	if (vptr->mac_regs)
-		iounmap(vptr->mac_regs);
-	if (vptr->pdev) {
-		pci_set_drvdata(vptr->pdev, NULL);
-	}
-}
-
-/**
  *	velocity_init_rings	-	set up DMA rings
  *	@vptr: Velocity to set up
  *
diff -puN drivers/net/via-velocity.h~via-velocity-00 drivers/net/via-velocity.h

_

--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="via-velocity-01.patch"


1 - velocity_init_rings: no need to build an aligned memory buffer by hand
    as pci_alloc_consistent() does this part of the job;
2 - velocity_info.{pool/pool_dma} are not needed any more (see 1);
3 - vptr->{td_rings/td_pool_dma} init: 178 cols is a bit high...;
4 - velocity_free_rings(): let's balance the 64 bytes reduction of the
    Rx/Tx desc pool (see 1);
5 - velocity_free_rings(): vptr->tx_bufs == 0 can not happen;
6 - velocity_init_rd_ring(): fix leak when it has been called from dev->open()
    and fails;
7 - velocity_free_rd_ring(): ok, this one is a bit cosmetic but I could not
    resist when I noticed that vptr->rd_info was tested against NULL two
    times in the same function. The hunk can be safely removed if this is
    frowned upon;
8 - velocity_open(): fix leak and power down the device if something fails
    and it has been enabled;
9 - velocity_change_mtu: stop returning with spinlock_irq taken when memory
    allocation fails. 


 drivers/net/via-velocity.c |  144 +++++++++++++++++++++++++++++----------------
 drivers/net/via-velocity.h |    2 
 2 files changed, 94 insertions(+), 52 deletions(-)

diff -puN drivers/net/via-velocity.c~via-velocity-01 drivers/net/via-velocity.c
--- linux-2.6.6-mm4/drivers/net/via-velocity.c~via-velocity-01	2004-05-31 21:43:36.000000000 +0200
+++ linux-2.6.6-mm4-fr/drivers/net/via-velocity.c	2004-05-31 23:05:07.000000000 +0200
@@ -258,6 +258,7 @@ static int velocity_rx_srv(struct veloci
 static int velocity_receive_frame(struct velocity_info *, int idx);
 static int velocity_alloc_rx_buf(struct velocity_info *, int idx);
 static void velocity_init_registers(struct velocity_info *vptr, enum velocity_init_type type);
+static void velocity_free_rd_ring(struct velocity_info *vptr);
 static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_info *);
 static int velocity_soft_reset(struct velocity_info *vptr);
 static void mii_init(struct velocity_info *vptr, u32 mii_status);
@@ -883,28 +884,33 @@ static int velocity_init_rings(struct ve
 	int i;
 	unsigned int psize;
 	unsigned int tsize;
+	dma_addr_t pool_dma;
+	u8 *pool;
 
 	/*
 	 *	Allocate all RD/TD rings a single pool 
 	 */
 	 
-	psize = vptr->options.numrx * sizeof(struct rx_desc) + 64 + 
+	psize = vptr->options.numrx * sizeof(struct rx_desc) + 
 		vptr->options.numtx * sizeof(struct tx_desc) * vptr->num_txq;
-	
-	vptr->pool = pci_alloc_consistent(vptr->pdev, psize, &vptr->pool_dma);
 
-	if (vptr->pool == NULL) {
+	/*
+	 * pci_alloc_consistent() fulfills the requirement for 64 bytes
+	 * alignment
+	 */
+	pool = pci_alloc_consistent(vptr->pdev, psize, &pool_dma);
+
+	if (pool == NULL) {
 		printk(KERN_ERR "%s : DMA memory allocation failed.\n", 
 					vptr->dev->name);
 		return -ENOMEM;
 	}
 
-	memset(vptr->pool, 0, psize);
+	memset(pool, 0, psize);
 
-	vptr->rd_ring = (struct rx_desc *) (((unsigned long) 
-					(((u8 *) vptr->pool) + 63)) & ~63);
+	vptr->rd_ring = (struct rx_desc *) pool;
 
-	vptr->rd_pool_dma = vptr->pool_dma;
+	vptr->rd_pool_dma = pool_dma;
 
 	tsize = vptr->options.numtx * PKT_BUF_SZ * vptr->num_txq;
 	vptr->tx_bufs = pci_alloc_consistent(vptr->pdev, tsize, 
@@ -913,16 +919,22 @@ static int velocity_init_rings(struct ve
 	if (vptr->tx_bufs == NULL) {
 		printk(KERN_ERR "%s: DMA memory allocation failed.\n", 
 					vptr->dev->name);
-		pci_free_consistent(vptr->pdev, psize, vptr->pool, 
-						vptr->pool_dma);
+		pci_free_consistent(vptr->pdev, psize, pool, pool_dma);
 		return -ENOMEM;
 	}
 
 	memset(vptr->tx_bufs, 0, vptr->options.numtx * PKT_BUF_SZ * vptr->num_txq);
 
+	i = vptr->options.numrx * sizeof(struct rx_desc);
+	pool += i;
+	pool_dma += i;
 	for (i = 0; i < vptr->num_txq; i++) {
-		vptr->td_pool_dma[i] = vptr->rd_pool_dma + vptr->options.numrx * sizeof(struct rx_desc) + vptr->options.numtx * sizeof(struct tx_desc) * i;
-		vptr->td_rings[i] = (struct tx_desc *) (((u8 *) vptr->rd_ring) + vptr->options.numrx * sizeof(struct rx_desc) + vptr->options.numtx * sizeof(struct tx_desc) * i);
+		int offset = vptr->options.numtx * sizeof(struct tx_desc);
+
+		vptr->td_pool_dma[i] = pool_dma;
+		vptr->td_rings[i] = (struct tx_desc *) pool;
+		pool += offset;
+		pool_dma += offset;
 	}
 	return 0;
 }
@@ -936,11 +948,16 @@ static int velocity_init_rings(struct ve
 
 static void velocity_free_rings(struct velocity_info *vptr)
 {
-	pci_free_consistent(vptr->pdev, vptr->options.numrx * sizeof(struct rx_desc) + 64 + vptr->options.numtx * sizeof(struct tx_desc) * vptr->num_txq, vptr->pool, vptr->pool_dma);
+	int size;
+
+	size = vptr->options.numrx * sizeof(struct rx_desc) + 
+	       vptr->options.numtx * sizeof(struct tx_desc) * vptr->num_txq;
+
+	pci_free_consistent(vptr->pdev, size, vptr->rd_ring, vptr->rd_pool_dma);
 
-	if (vptr->tx_bufs)
-		pci_free_consistent(vptr->pdev, vptr->options.numtx * PKT_BUF_SZ * vptr->num_txq, vptr->tx_bufs, vptr->tx_bufs_dma);
+	size = vptr->options.numtx * PKT_BUF_SZ * vptr->num_txq;
 
+	pci_free_consistent(vptr->pdev, size, vptr->tx_bufs, vptr->tx_bufs_dma);
 }
 
 /**
@@ -953,7 +970,7 @@ static void velocity_free_rings(struct v
 
 static int velocity_init_rd_ring(struct velocity_info *vptr)
 {
-	int i;
+	int i, ret = -ENOMEM;
 	struct rx_desc *rd;
 	struct velocity_rd_info *rd_info;
 	unsigned int rsize = sizeof(struct velocity_rd_info) * 
@@ -961,7 +978,7 @@ static int velocity_init_rd_ring(struct 
 
 	vptr->rd_info = kmalloc(rsize, GFP_KERNEL);
 	if(vptr->rd_info == NULL)
-		return -ENOMEM;
+		goto out;
 	memset(vptr->rd_info, 0, rsize);
 
 	/* Init the RD ring entries */
@@ -969,15 +986,19 @@ static int velocity_init_rd_ring(struct 
 		rd = &(vptr->rd_ring[i]);
 		rd_info = &(vptr->rd_info[i]);
 
-		if (velocity_alloc_rx_buf(vptr, i) < 0) {
-			VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR "%s: failed to allocate RX buffer.\n", 
-							vptr->dev->name);
-			return -ENOMEM;
+		ret = velocity_alloc_rx_buf(vptr, i);
+		if (ret < 0) {
+			VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
+				"%s: failed to allocate RX buffer.\n", 
+				vptr->dev->name);
+			velocity_free_rd_ring(vptr);
+			goto out;
 		}
 		rd->rdesc0.owner = OWNED_BY_NIC;
 	}
 	vptr->rd_used = vptr->rd_curr = 0;
-	return 0;
+out:
+	return ret;
 }
 
 /**
@@ -991,23 +1012,24 @@ static int velocity_init_rd_ring(struct 
 static void velocity_free_rd_ring(struct velocity_info *vptr)
 {
 	int i;
+
 	if (vptr->rd_info == NULL)
 		return;
 
 	for (i = 0; i < vptr->options.numrx; i++) {
 		struct velocity_rd_info *rd_info = &(vptr->rd_info[i]);
-		if (rd_info->skb_dma) {
-			pci_unmap_single(vptr->pdev, rd_info->skb_dma, 
-					vptr->rx_buf_sz, PCI_DMA_FROMDEVICE);
-			rd_info->skb_dma = (dma_addr_t) NULL;
-		}
-		if (rd_info->skb) {
-			dev_kfree_skb(rd_info->skb);
-			rd_info->skb = NULL;
-		}
+
+		if (!rd_info->skb_dma)
+			continue;
+		pci_unmap_single(vptr->pdev, rd_info->skb_dma, vptr->rx_buf_sz,
+				 PCI_DMA_FROMDEVICE);
+		rd_info->skb_dma = (dma_addr_t) NULL;
+
+		dev_kfree_skb(rd_info->skb);
+		rd_info->skb = NULL;
 	}
-	if (vptr->rd_info)
-		kfree(vptr->rd_info);
+
+	kfree(vptr->rd_info);
 	vptr->rd_info = NULL;
 }
 
@@ -1574,30 +1596,48 @@ static void velocity_free_tx_buf(struct 
 static int velocity_open(struct net_device *dev)
 {
 	struct velocity_info *vptr = dev->priv;
-	int i;
+	int ret;
 
 	vptr->rx_buf_sz = (dev->mtu <= 1504 ? PKT_BUF_SZ : dev->mtu + 32);
 
-	if (velocity_init_rings(vptr) < 0)
-		return -ENOMEM;
-	if (velocity_init_rd_ring(vptr) < 0)
-		return -ENOMEM;
-	if (velocity_init_td_ring(vptr) < 0)
-		return -ENOMEM;
+	ret = velocity_init_rings(vptr);
+	if (ret < 0)
+		goto out;
+
+	ret = velocity_init_rd_ring(vptr);
+	if (ret < 0)
+		goto err_free_desc_rings;
+
+	ret = velocity_init_td_ring(vptr);
+	if (ret < 0)
+		goto err_free_rd_ring;
 	
 	/* Ensure chip is running */	
 	pci_set_power_state(vptr->pdev, 0);
 	
 	velocity_init_registers(vptr, VELOCITY_INIT_COLD);
 
-	i = request_irq(vptr->pdev->irq, &velocity_intr, SA_SHIRQ, dev->name, dev);
-	if (i < 0)
-		return i;
+	ret = request_irq(vptr->pdev->irq, &velocity_intr, SA_SHIRQ,
+			  dev->name, dev);
+	if (ret < 0) {
+		/* Power down the chip */
+		pci_set_power_state(vptr->pdev, 3);
+		goto err_free_td_ring;
+	}
 
 	mac_enable_int(vptr->mac_regs);
 	netif_start_queue(dev);
 	vptr->flags |= VELOCITY_FLAGS_OPENED;
-	return 0;
+out:
+	return ret;
+
+err_free_td_ring:
+	velocity_free_td_ring(vptr);
+err_free_rd_ring:
+	velocity_free_rd_ring(vptr);
+err_free_desc_rings:
+	velocity_free_rings(vptr);
+	goto out;
 }
 
 /** 
@@ -1615,6 +1655,7 @@ static int velocity_change_mtu(struct ne
 	struct velocity_info *vptr = dev->priv;
 	unsigned long flags;
 	int oldmtu = dev->mtu;
+	int ret = 0;
 
 	if ((new_mtu < VELOCITY_MIN_MTU) || new_mtu > (VELOCITY_MAX_MTU)) {
 		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_NOTICE "%s: Invalid MTU.\n", 
@@ -1639,20 +1680,23 @@ static int velocity_change_mtu(struct ne
 		else
 			vptr->rx_buf_sz = 4 * 1024;
 
-		if (velocity_init_rd_ring(vptr) < 0)
-			return -ENOMEM;
-
-		if (velocity_init_td_ring(vptr) < 0)
-			return -ENOMEM;
+		ret = velocity_init_rd_ring(vptr);
+		if (ret < 0)
+			goto out_unlock;
+
+		ret = velocity_init_td_ring(vptr);
+		if (ret < 0)
+			goto out_unlock;
 
 		velocity_init_registers(vptr, VELOCITY_INIT_COLD);
 
 		mac_enable_int(vptr->mac_regs);
 		netif_start_queue(dev);
+out_unlock:
 		spin_unlock_irqrestore(&vptr->lock, flags);
 	}
 
-	return 0;
+	return ret;
 }
 
 /**
diff -puN drivers/net/via-velocity.h~via-velocity-01 drivers/net/via-velocity.h
--- linux-2.6.6-mm4/drivers/net/via-velocity.h~via-velocity-01	2004-05-31 21:43:38.000000000 +0200
+++ linux-2.6.6-mm4-fr/drivers/net/via-velocity.h	2004-05-31 22:00:35.000000000 +0200
@@ -1751,8 +1751,6 @@ struct velocity_info {
 	u32 pci_state[16];
 #endif
 
-	void *pool;
-	dma_addr_t pool_dma;
 	dma_addr_t rd_pool_dma;
 	dma_addr_t td_pool_dma[TX_QUEUE_NO];
 

_

--FL5UXtIhxfXey3p5--
