From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver fixes
Date: Mon, 4 Oct 2004 18:08:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004220837.GA2288@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Got a big queue waiting for 2.6.9 release...

Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/3c59x.c             |    7 ++++
 drivers/net/tokenring/Kconfig   |    3 +
 drivers/net/tokenring/olympic.c |   63 +++++++++++-----------------------------
 drivers/net/via-velocity.c      |   60 +++++++++++++++++++-------------------
 drivers/net/via-velocity.h      |    7 +---
 5 files changed, 60 insertions(+), 80 deletions(-)

through these ChangeSets:

<romieu@fr.zoreil.com> (04/10/04 1.2057)
   [PATCH] via-velocity: comment fixes
   
   Comment fixes.
   
   Signed-off-by: Tejun Heo <tj@home-tj.org>

<romieu@fr.zoreil.com> (04/10/04 1.2056)
   [PATCH] via-velocity: wrong buffer offset in velocity_init_td_ring()
   
   Buffer offset calculation was incorrect in velocity_init_td_ring().
   This didn't cause any trouble because we only use the first td ring.
   
   Signed-off-by: Tejun Heo <tj@home-tj.org>

<romieu@fr.zoreil.com> (04/10/04 1.2055)
   [PATCH] via-velocity: removal of incomplete endianness handling
   
   Removed cpu_to_le32 call on OWNED_BY_NIC. This will produce 0x01000000 on
   big endian machines while rdesc0.owner still evaluates to 0x00000000 or
   0x00000001. BTW, unless we reorder bit fields on big endian machines or
   use u32's and cpu_to_le32'd bit mask macros, current code won't work on big
   endian machines.
   
   Signed-off-by: Tejun Heo <tj@home-tj.org>

<romieu@fr.zoreil.com> (04/10/04 1.2054)
   [PATCH] via-velocity: early invocation of init_cam_filter()
   
   In velocity_init_registers(), init_cam_filter() clears mCAMmask which
   might have been set by set_multi() (not sure if this can ever occur).
   Modified to invoke init_cam_filter() first. Also, clear_isr() is called
   twice. Removed the first invocation.
   
   In velocity_found1(), there was a unneeded assignment from vptr to
   dev->priv.  Removed.
   
   Signed-off-by: Tejun Heo <tj@home-tj.org>

<romieu@fr.zoreil.com> (04/10/04 1.2053)
   [PATCH] via-velocity: received ring wrong index and missing barriers
   
   There were several receive ring related bugs.
   
   In velocity_give_many_rx_descs(), index calculation was incorrect.
   This and bugs in velocity_rx_srv() described in the following paragraph
   caused packet loss, truncation and infinite error interrupt generation.
   
   In velocity_rx_srv(), velocity_rx_refill() could be called without any
   dirty slot.  With proper timing, This can result in refilling yet
   unreceived packets and pushing dirty pointer ahead of the current pointer.
   And vptr->rd_curr which is used by velocity_rx_refill() was updated after
   calling velocity_rx_refill() thus screwing receive descriptor ring.
   Also, between checking owner and reading the packet, rmb() is missing.
   
   Signed-off-by: Tejun Heo <tj@home-tj.org>

<romieu@fr.zoreil.com> (04/10/04 1.2052)
   [PATCH] via-velocity: velocity_give_rx_desc() removal
   
   In velocity_give_rx_desc(), there should be a wmb() between resetting the
   first four bytes of rdesc0 and setting owner. As resetting the first four
   bytes isn't necessary, I just removed the function and directly set owner.
   Another rationale for removing the function:
   The function doesn't handle synchronization. We should do wmb() before
   calling the function.  So, I think using bare assignment makes the fact
   more explicit.
   
   Signed-off-by: Tejun Heo <tj@home-tj.org>

<romieu@fr.zoreil.com> (04/10/04 1.2051)
   [PATCH] via-velocity: removal of unused velocity_info.xmit_lock
   
   Removed unused velocity_info.xmit_lock.
   
   Signed-off-by: Tejun Heo <tj@home-tj.org>

<romieu@fr.zoreil.com> (04/10/04 1.2050)
   [PATCH] via-velocity: properly manage the count of adapters
   
   velocity_nics wasn't managed properly.
   
   Signed-off-by: Tejun Heo <tj@home-tj.org>

<nhorman@redhat.com> (04/10/04 1.2009.4.3)
   [PATCH] olympic driver: fix kernel oops on lobe fault
   
   Hey-
   	I had submitted this awhile ago and after it didn't appear to get
   accepted, I found that I had boned the submission format pretty bad.  So I'm
   making another pass at it.  Its the same patch, applies cleanly to 2.6.9-rc3,
   and it fixes the oops that olympic driver encounters when it gets a lobe fault.
   I've tested it, with good results.
   Thanks
   Neil
   
   Signed-off-by: Neil Horman <nhorman@redhat.com>

<alan@redhat.com> (04/09/30 1.2009.4.2)
   [PATCH] 3c59x: add invalid MAC address check

<bunk@fs.tum.de> (04/09/20 1.1923.1.6)
   [PATCH] TMS380TR must select FW_LOADER
   
   I got the following compile error with CONFIG_FW_LOADER=n:
   
   <--  snip  -->
   
   ...
     LD      .tmp_vmlinux1
   drivers/built-in.o(.text+0x297944): In function `tms380tr_reset_adapter':
   : undefined reference to `request_firmware'
   drivers/built-in.o(.text+0x297aaf): In function `tms380tr_reset_adapter':
   : undefined reference to `release_firmware'
   drivers/built-in.o(.text+0x297af9): In function `tms380tr_reset_adapter':
   : undefined reference to `release_firmware'
   make: *** [.tmp_vmlinux1] Error 1
   
   <--  snip  -->
   
   
   CONFIG_TMS380TR must select FW_LOADER (and therefore depend on HOTPLUG).
   
   
   Signed-off-by: Adrian Bunk <bunk@fs.tum.de>

diff -Nru a/drivers/net/3c59x.c b/drivers/net/3c59x.c
--- a/drivers/net/3c59x.c	2004-10-04 18:07:46 -04:00
+++ b/drivers/net/3c59x.c	2004-10-04 18:07:46 -04:00
@@ -1297,6 +1297,13 @@
 		for (i = 0; i < 6; i++)
 			printk("%c%2.2x", i ? ':' : ' ', dev->dev_addr[i]);
 	}
+	/* Unfortunately an all zero eeprom passes the checksum and this
+	   gets found in the wild in failure cases. Crypto is hard 8) */
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		retval = -EINVAL;
+		printk(KERN_ERR "*** EEPROM MAC address is invalid.\n");
+		goto free_ring;	/* With every pack */
+	}
 	EL3WINDOW(2);
 	for (i = 0; i < 6; i++)
 		outb(dev->dev_addr[i], ioaddr + i);
diff -Nru a/drivers/net/tokenring/Kconfig b/drivers/net/tokenring/Kconfig
--- a/drivers/net/tokenring/Kconfig	2004-10-04 18:07:46 -04:00
+++ b/drivers/net/tokenring/Kconfig	2004-10-04 18:07:46 -04:00
@@ -84,7 +84,8 @@
 
 config TMS380TR
 	tristate "Generic TMS380 Token Ring ISA/PCI adapter support"
-	depends on TR && (PCI || ISA)
+	depends on TR && (PCI || ISA) && HOTPLUG
+	select FW_LOADER
 	---help---
 	  This driver provides generic support for token ring adapters
 	  based on the Texas Instruments TMS380 series chipsets.  This
diff -Nru a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
--- a/drivers/net/tokenring/olympic.c	2004-10-04 18:07:46 -04:00
+++ b/drivers/net/tokenring/olympic.c	2004-10-04 18:07:46 -04:00
@@ -221,6 +221,8 @@
 
 	olympic_priv = dev->priv ;
 	
+	spin_lock_init(&olympic_priv->olympic_lock) ; 
+
 	init_waitqueue_head(&olympic_priv->srb_wait);
 	init_waitqueue_head(&olympic_priv->trb_wait);
 #if OLYMPIC_DEBUG  
@@ -311,7 +313,6 @@
 		}
 	}
 
-	spin_lock_init(&olympic_priv->olympic_lock) ; 
 
 	/* Needed for cardbus */
 	if(!(readl(olympic_mmio+BCTL) & BCTL_MODE_INDICATOR)) {
@@ -442,6 +443,8 @@
 
 	DECLARE_WAITQUEUE(wait,current) ; 
 
+	olympic_init(dev);
+
 	if(request_irq(dev->irq, &olympic_interrupt, SA_SHIRQ , "olympic", dev)) {
 		return -EAGAIN;
 	}
@@ -898,7 +901,10 @@
 	int i;
 			
 	for(i=0;i<OLYMPIC_RX_RING_SIZE;i++) {
-		dev_kfree_skb_irq(olympic_priv->rx_ring_skb[olympic_priv->rx_status_last_received]);
+		if (olympic_priv->rx_ring_skb[olympic_priv->rx_status_last_received] != NULL) {
+			dev_kfree_skb_irq(olympic_priv->rx_ring_skb[olympic_priv->rx_status_last_received]);
+			olympic_priv->rx_ring_skb[olympic_priv->rx_status_last_received] = NULL;
+		}
 		if (olympic_priv->olympic_rx_ring[olympic_priv->rx_status_last_received].buffer != 0xdeadbeef) {
 			pci_unmap_single(olympic_priv->pdev, 
 			le32_to_cpu(olympic_priv->olympic_rx_ring[olympic_priv->rx_status_last_received].buffer),
@@ -944,9 +950,6 @@
 	/* Hotswap gives us this on removal */
 	if (sisr == 0xffffffff) { 
 		printk(KERN_WARNING "%s: Hotswap adapter removal.\n",dev->name) ; 
-		olympic_freemem(dev) ; 
-		free_irq(dev->irq, dev) ;
-		dev->stop = NULL ;  
 		spin_unlock(&olympic_priv->olympic_lock) ; 
 		return IRQ_NONE;
 	} 
@@ -961,9 +964,7 @@
 			printk(KERN_ERR "The adapter must be reset to clear this condition.\n") ; 
 			printk(KERN_ERR "Please report this error to the driver maintainer and/\n") ; 
 			printk(KERN_ERR "or the linux-tr mailing list.\n") ; 
-			olympic_freemem(dev) ; 
-			free_irq(dev->irq, dev) ;
-			dev->stop = NULL ;  
+			wake_up_interruptible(&olympic_priv->srb_wait);
 			spin_unlock(&olympic_priv->olympic_lock) ; 
 			return IRQ_HANDLED;
 		} /* SISR_ERR */
@@ -1006,9 +1007,6 @@
 			writel(readl(olympic_mmio+LAPWWC),olympic_mmio+LAPA);
 			adapter_check_area = olympic_priv->olympic_lap + ((readl(olympic_mmio+LAPWWC)) & (~0xf800)) ;
 			printk(KERN_WARNING "%s: Bytes %02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x\n",dev->name, readb(adapter_check_area+0), readb(adapter_check_area+1), readb(adapter_check_area+2), readb(adapter_check_area+3), readb(adapter_check_area+4), readb(adapter_check_area+5), readb(adapter_check_area+6), readb(adapter_check_area+7)) ; 
-			olympic_freemem(dev) ;
-			free_irq(dev->irq, dev) ;
-			dev->stop = NULL ;  
 			spin_unlock(&olympic_priv->olympic_lock) ; 
 			return IRQ_HANDLED; 
 		} /* SISR_ADAPTER_CHECK */
@@ -1094,34 +1092,32 @@
 	writeb(0,srb+1);
 	writeb(OLYMPIC_CLEAR_RET_CODE,srb+2);
 
+	add_wait_queue(&olympic_priv->srb_wait,&wait) ;
+	set_current_state(TASK_INTERRUPTIBLE) ; 
+
 	spin_lock_irqsave(&olympic_priv->olympic_lock,flags);
 	olympic_priv->srb_queued=1;
 
 	writel(LISR_SRB_CMD,olympic_mmio+LISR_SUM);
 	spin_unlock_irqrestore(&olympic_priv->olympic_lock,flags);
-	
-	t = jiffies ; 
-
-	add_wait_queue(&olympic_priv->srb_wait,&wait) ;
-	set_current_state(TASK_INTERRUPTIBLE) ; 
 
 	while(olympic_priv->srb_queued) {
-		schedule() ; 
+
+		t = schedule_timeout(60*HZ); 
+
         	if(signal_pending(current))	{            
 			printk(KERN_WARNING "%s: SRB timed out.\n",dev->name);
             		printk(KERN_WARNING "SISR=%x MISR=%x\n",readl(olympic_mmio+SISR),readl(olympic_mmio+LISR));
             		olympic_priv->srb_queued=0;
             		break;
         	}
-		if ((jiffies-t) > 60*HZ) { 
+
+		if (t == 0) { 
 			printk(KERN_WARNING "%s: SRB timed out. May not be fatal. \n",dev->name) ; 
-			olympic_priv->srb_queued=0;
-			break ; 
 		} 
-		set_current_state(TASK_INTERRUPTIBLE) ; 
+		olympic_priv->srb_queued=0;
     	}
 	remove_wait_queue(&olympic_priv->srb_wait,&wait) ; 
-	set_current_state(TASK_RUNNING) ; 
 
 	olympic_priv->rx_status_last_received++;
 	olympic_priv->rx_status_last_received&=OLYMPIC_RX_RING_SIZE-1;
@@ -1513,29 +1509,6 @@
 			writel(readl(olympic_mmio+BCTL)&~(3<<13),olympic_mmio+BCTL);
 			netif_stop_queue(dev);
 			olympic_priv->srb = readw(olympic_priv->olympic_lap + LAPWWO) ; 
-			for(i=0;i<OLYMPIC_RX_RING_SIZE;i++) {
-				dev_kfree_skb_irq(olympic_priv->rx_ring_skb[olympic_priv->rx_status_last_received]);
-				if (olympic_priv->olympic_rx_ring[olympic_priv->rx_status_last_received].buffer != 0xdeadbeef) {
-					pci_unmap_single(olympic_priv->pdev, 
-						le32_to_cpu(olympic_priv->olympic_rx_ring[olympic_priv->rx_status_last_received].buffer),
-						olympic_priv->pkt_buf_sz, PCI_DMA_FROMDEVICE);
-				}
-				olympic_priv->rx_status_last_received++;
-				olympic_priv->rx_status_last_received&=OLYMPIC_RX_RING_SIZE-1;
-			}
-			/* unmap rings */
-			pci_unmap_single(olympic_priv->pdev, olympic_priv->rx_status_ring_dma_addr, 
-				sizeof(struct olympic_rx_status) * OLYMPIC_RX_RING_SIZE, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(olympic_priv->pdev, olympic_priv->rx_ring_dma_addr,
-				sizeof(struct olympic_rx_desc) * OLYMPIC_RX_RING_SIZE, PCI_DMA_TODEVICE);
-
-			pci_unmap_single(olympic_priv->pdev, olympic_priv->tx_status_ring_dma_addr, 
-				sizeof(struct olympic_tx_status) * OLYMPIC_TX_RING_SIZE, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(olympic_priv->pdev, olympic_priv->tx_ring_dma_addr, 
-				sizeof(struct olympic_tx_desc) * OLYMPIC_TX_RING_SIZE, PCI_DMA_TODEVICE);
-
-			free_irq(dev->irq,dev);
-			dev->stop=NULL;
 			printk(KERN_WARNING "%s: Adapter has been closed \n", dev->name) ; 
 		} /* If serious error */
 		
diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2004-10-04 18:07:46 -04:00
+++ b/drivers/net/via-velocity.c	2004-10-04 18:07:46 -04:00
@@ -359,6 +359,8 @@
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
+
+	velocity_nics--;
 }
 
 /**
@@ -462,7 +464,7 @@
 {
 	struct mac_regs * regs = vptr->mac_regs;
 
-	/* T urn on MCFG_PQEN, turn off MCFG_RTGOPT */
+	/* Turn on MCFG_PQEN, turn off MCFG_RTGOPT */
 	WORD_REG_BITS_SET(MCFG_PQEN, MCFG_RTGOPT, &regs->MCFG);
 	WORD_REG_BITS_ON(MCFG_VIDFR, &regs->MCFG);
 
@@ -490,12 +492,6 @@
 	}
 }
 
-static inline void velocity_give_rx_desc(struct rx_desc *rd)
-{
-	*(u32 *)&rd->rdesc0 = 0;
-	rd->rdesc0.owner = cpu_to_le32(OWNED_BY_NIC);
-}
-
 /**
  *	velocity_rx_reset	-	handle a receive reset
  *	@vptr: velocity we are resetting
@@ -516,7 +512,7 @@
 	 *	Init state, all RD entries belong to the NIC
 	 */
 	for (i = 0; i < vptr->options.numrx; ++i)
-		velocity_give_rx_desc(vptr->rd_ring + i);
+		vptr->rd_ring[i].rdesc0.owner = OWNED_BY_NIC;
 
 	writew(vptr->options.numrx, &regs->RBRDU);
 	writel(vptr->rd_pool_dma, &regs->RDBaseLo);
@@ -591,11 +587,16 @@
 
 		writeb(WOLCFG_SAM | WOLCFG_SAB, &regs->WOLCFGSet);
 		/*
-		 *	Bback off algorithm use original IEEE standard
+		 *	Back off algorithm use original IEEE standard
 		 */
 		BYTE_REG_BITS_SET(CFGB_OFSET, (CFGB_CRANDOM | CFGB_CAP | CFGB_MBA | CFGB_BAKOPT), &regs->CFGB);
 
 		/*
+		 *	Init CAM filter
+		 */
+		velocity_init_cam_filter(vptr);
+
+		/*
 		 *	Set packet filter: Receive directed and broadcast address
 		 */
 		velocity_set_multi(vptr->dev);
@@ -619,8 +620,6 @@
 			mac_tx_queue_run(regs, i);
 		}
 
-		velocity_init_cam_filter(vptr);
-
 		init_flow_control_register(vptr);
 
 		writel(CR0_STOP, &regs->CR0Clr);
@@ -628,7 +627,6 @@
 
 		mii_status = velocity_get_opt_media_mode(vptr);
 		netif_stop_queue(vptr->dev);
-		mac_clear_isr(regs);
 
 		mii_init(vptr, mii_status);
 
@@ -695,7 +693,7 @@
 	struct mac_regs * regs;
 	int ret = -ENOMEM;
 
-	if (velocity_nics++ >= MAX_UNITS) {
+	if (velocity_nics >= MAX_UNITS) {
 		printk(KERN_NOTICE VELOCITY_NAME ": already found %d NICs.\n", 
 				velocity_nics);
 		return -ENODEV;
@@ -727,7 +725,6 @@
 
 	vptr->dev = dev;
 
-	dev->priv = vptr;
 	dev->irq = pdev->irq;
 
 	ret = pci_enable_device(pdev);
@@ -762,7 +759,7 @@
 		dev->dev_addr[i] = readb(&regs->PAR[i]);
 
 
-	velocity_get_options(&vptr->options, velocity_nics - 1, dev->name);
+	velocity_get_options(&vptr->options, velocity_nics, dev->name);
 
 	/* 
 	 *	Mask out the options cannot be set to the chip
@@ -817,6 +814,7 @@
 		spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
 	}
 #endif
+	velocity_nics++;
 out:
 	return ret;
 
@@ -869,10 +867,7 @@
 	vptr->io_size = info->io_size;
 	vptr->num_txq = info->txqueue;
 	vptr->multicast_limit = MCAM_SIZE;
-
 	spin_lock_init(&vptr->lock);
-	spin_lock_init(&vptr->xmit_lock);
-
 	INIT_LIST_HEAD(&vptr->list);
 }
 
@@ -1024,11 +1019,11 @@
 
 	wmb();
 
-	unusable = vptr->rd_filled | 0x0003;
-	dirty = vptr->rd_dirty - unusable + 1;
+	unusable = vptr->rd_filled & 0x0003;
+	dirty = vptr->rd_dirty - unusable;
 	for (avail = vptr->rd_filled & 0xfffc; avail; avail--) {
 		dirty = (dirty > 0) ? dirty - 1 : vptr->options.numrx - 1;
-		velocity_give_rx_desc(vptr->rd_ring + dirty);
+		vptr->rd_ring[dirty].rdesc0.owner = OWNED_BY_NIC;
 	}
 
 	writew(vptr->rd_filled & 0xfffc, &regs->RBRDU);
@@ -1043,7 +1038,7 @@
 		struct rx_desc *rd = vptr->rd_ring + dirty;
 
 		/* Fine for an all zero Rx desc at init time as well */
-		if (rd->rdesc0.owner == cpu_to_le32(OWNED_BY_NIC))
+		if (rd->rdesc0.owner == OWNED_BY_NIC)
 			break;
 
 		if (!vptr->rd_info[dirty].skb) {
@@ -1096,7 +1091,7 @@
 }
 
 /**
- *	velocity_free_rd_ring	-	set up receive ring
+ *	velocity_free_rd_ring	-	free receive ring
  *	@vptr: velocity to clean up
  *
  *	Free the receive buffers for each ring slot and any
@@ -1161,8 +1156,10 @@
 		for (i = 0; i < vptr->options.numtx; i++, curr += sizeof(struct tx_desc)) {
 			td = &(vptr->td_rings[j][i]);
 			td_info = &(vptr->td_infos[j][i]);
-			td_info->buf = vptr->tx_bufs + (i + j) * PKT_BUF_SZ;
-			td_info->buf_dma = vptr->tx_bufs_dma + (i + j) * PKT_BUF_SZ;
+			td_info->buf = vptr->tx_bufs +
+				(j * vptr->options.numtx + i) * PKT_BUF_SZ;
+			td_info->buf_dma = vptr->tx_bufs_dma +
+				(j * vptr->options.numtx + i) * PKT_BUF_SZ;
 		}
 		vptr->td_tail[j] = vptr->td_curr[j] = vptr->td_used[j] = 0;
 	}
@@ -1238,15 +1235,17 @@
 	int rd_curr = vptr->rd_curr;
 	int works = 0;
 
-	while (1) {
+	do {
 		struct rx_desc *rd = vptr->rd_ring + rd_curr;
 
-		if (!vptr->rd_info[rd_curr].skb || (works++ > 15))
+		if (!vptr->rd_info[rd_curr].skb)
 			break;
 
 		if (rd->rdesc0.owner == OWNED_BY_NIC)
 			break;
 
+		rmb();
+
 		/*
 		 *	Don't drop CE or RL error frame although RXOK is off
 		 */
@@ -1269,14 +1268,15 @@
 		rd_curr++;
 		if (rd_curr >= vptr->options.numrx)
 			rd_curr = 0;
-	}
+	} while (++works <= 15);
 
-	if (velocity_rx_refill(vptr) < 0) {
+	vptr->rd_curr = rd_curr;
+
+	if (works > 0 && velocity_rx_refill(vptr) < 0) {
 		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
 			"%s: rx buf allocation failure\n", vptr->dev->name);
 	}
 
-	vptr->rd_curr = rd_curr;
 	VAR_USED(stats);
 	return works;
 }
diff -Nru a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
--- a/drivers/net/via-velocity.h	2004-10-04 18:07:46 -04:00
+++ b/drivers/net/via-velocity.h	2004-10-04 18:07:46 -04:00
@@ -1319,7 +1319,7 @@
 	/* disable CAMEN */
 	writeb(0, &regs->CAMADDR);
 
-	/* Select CAM mask */
+	/* Select mar */
 	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
 }
 
@@ -1360,7 +1360,7 @@
 
 	writeb(0, &regs->CAMADDR);
 
-	/* Select CAM mask */
+	/* Select mar */
 	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
 }
 
@@ -1401,7 +1401,7 @@
 
 	writeb(0, &regs->CAMADDR);
 
-	/* Select CAM mask */
+	/* Select mar */
 	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
 }
 
@@ -1792,7 +1792,6 @@
 	u8 mCAMmask[(MCAM_SIZE / 8)];
 
 	spinlock_t lock;
-	spinlock_t xmit_lock;
 
 	int wol_opts;
 	u8 wol_passwd[6];
