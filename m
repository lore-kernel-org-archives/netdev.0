From: Tejun Heo <tj@home-tj.org>
Subject: [PATCHES] via-velocity fixes
Date: Mon, 13 Sep 2004 14:02:55 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913050255.GA32549@home-tj.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="h31gzZEtNLTqOjlF"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

 Hello, I've encountered some problems (packet loss, duplicate
truncated packets, hang) w/ recent rd ring related updates to
via-veolcity.  I'm attaching 8 patches to fix the problem and some
other bugs.  I'm attaching the following 8 patches.  Detailed
description is at the head of each patch file.

00velocity_nics.patch		: velocity_nics management fix
01velocity_xmit_lock.patch	: unused xmit_lock removed
02velocity_give_rx_desc.patch	: give_rx_desc removed
03velocity_rd_ring.patch	: rd ring fix (it was the offending bug)
04velocity_init.patch		: init related bug fix
05velocity_cpu_to_le32.patch	: removes cpu_to_le32(OWNED_BY_NIC)
06velocity_init_td_ring.patch	: init_td_ring index calculation fix
07velocity_comment.patch	: comment fixes

Thanks.

-- 
tejun


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="00velocity_nics.patch"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/13 12:47:24+09:00 tj@cl.aratech.co.kr 
#   velocity_nics wasn't managed properly.  Fixed.
# 
# drivers/net/via-velocity.c
#   2004/09/13 12:47:12+09:00 tj@cl.aratech.co.kr +5 -2
#   velocity_nics wasn't managed properly.  Fixed.
# 
diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2004-09-13 13:48:15 +09:00
+++ b/drivers/net/via-velocity.c	2004-09-13 13:48:15 +09:00
@@ -359,6 +359,8 @@
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
+
+	velocity_nics--;
 }
 
 /**
@@ -695,7 +697,7 @@
 	struct mac_regs * regs;
 	int ret = -ENOMEM;
 
-	if (velocity_nics++ >= MAX_UNITS) {
+	if (velocity_nics >= MAX_UNITS) {
 		printk(KERN_NOTICE VELOCITY_NAME ": already found %d NICs.\n", 
 				velocity_nics);
 		return -ENODEV;
@@ -762,7 +764,7 @@
 		dev->dev_addr[i] = readb(&regs->PAR[i]);
 
 
-	velocity_get_options(&vptr->options, velocity_nics - 1, dev->name);
+	velocity_get_options(&vptr->options, velocity_nics, dev->name);
 
 	/* 
 	 *	Mask out the options cannot be set to the chip
@@ -817,6 +819,7 @@
 		spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
 	}
 #endif
+	velocity_nics++;
 out:
 	return ret;
 

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="01velocity_xmit_lock.patch"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/13 12:49:36+09:00 tj@cl.aratech.co.kr 
#   removed unused velocity_info.xmit_lock
# 
# drivers/net/via-velocity.h
#   2004/09/13 12:49:25+09:00 tj@cl.aratech.co.kr +0 -1
#   removed unused velocity_info.xmit_lock
# 
# drivers/net/via-velocity.c
#   2004/09/13 12:49:25+09:00 tj@cl.aratech.co.kr +0 -3
#   removed unused velocity_info.xmit_lock
# 
diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2004-09-13 13:48:34 +09:00
+++ b/drivers/net/via-velocity.c	2004-09-13 13:48:34 +09:00
@@ -872,10 +872,7 @@
 	vptr->io_size = info->io_size;
 	vptr->num_txq = info->txqueue;
 	vptr->multicast_limit = MCAM_SIZE;
-
 	spin_lock_init(&vptr->lock);
-	spin_lock_init(&vptr->xmit_lock);
-
 	INIT_LIST_HEAD(&vptr->list);
 }
 
diff -Nru a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
--- a/drivers/net/via-velocity.h	2004-09-13 13:48:34 +09:00
+++ b/drivers/net/via-velocity.h	2004-09-13 13:48:34 +09:00
@@ -1792,7 +1792,6 @@
 	u8 mCAMmask[(MCAM_SIZE / 8)];
 
 	spinlock_t lock;
-	spinlock_t xmit_lock;
 
 	int wol_opts;
 	u8 wol_passwd[6];

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="02velocity_give_rx_desc.patch"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/13 12:55:57+09:00 tj@cl.aratech.co.kr 
#   In velocity_give_rx_desc(), there should be a wmb() between resetting
#   the first four bytes of rdesc0 and setting owner.  As resetting the
#   first four bytes isn't necessary, I just removed the function and
#   directly set owner.  Another rationale for removing the function:
#   The function doesn't handle synchronization.  We should do wmb()
#   before calling the function.  So, I think using bare assignment
#   makes the fact more explicit.
# 
# drivers/net/via-velocity.c
#   2004/09/13 12:55:46+09:00 tj@cl.aratech.co.kr +2 -8
#   In velocity_give_rx_desc(), there should be a wmb() between resetting
#   the first four bytes of rdesc0 and setting owner.  As resetting the
#   first four bytes isn't necessary, I just removed the function and
#   directly set owner.  Another rationale for removing the function:
#   The function doesn't handle synchronization.  We should do wmb()
#   before calling the function.  So, I think using bare assignment
#   makes the fact more explicit.
# 
diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2004-09-13 13:49:01 +09:00
+++ b/drivers/net/via-velocity.c	2004-09-13 13:49:01 +09:00
@@ -492,12 +492,6 @@
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
@@ -518,7 +512,7 @@
 	 *	Init state, all RD entries belong to the NIC
 	 */
 	for (i = 0; i < vptr->options.numrx; ++i)
-		velocity_give_rx_desc(vptr->rd_ring + i);
+		vptr->rd_ring[i].rdesc0.owner = OWNED_BY_NIC;
 
 	writew(vptr->options.numrx, &regs->RBRDU);
 	writel(vptr->rd_pool_dma, &regs->RDBaseLo);
@@ -1028,7 +1022,7 @@
 	dirty = vptr->rd_dirty - unusable + 1;
 	for (avail = vptr->rd_filled & 0xfffc; avail; avail--) {
 		dirty = (dirty > 0) ? dirty - 1 : vptr->options.numrx - 1;
-		velocity_give_rx_desc(vptr->rd_ring + dirty);
+		vptr->rd_ring[dirty].rdesc0.owner = OWNED_BY_NIC;
 	}
 
 	writew(vptr->rd_filled & 0xfffc, &regs->RBRDU);

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="03velocity_rd_ring.patch"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/13 13:26:10+09:00 tj@cl.aratech.co.kr 
#   via-velocity receive ring related bugs fixed.
# 
# drivers/net/via-velocity.c
#   2004/09/13 13:25:54+09:00 tj@cl.aratech.co.kr +10 -7
#   There were several receive ring related bugs.
#   
#   In velocity_give_many_rx_descs(), index calculation was incorrect.
#   This and bugs in velocity_rx_srv() described in the following
#   paragraph caused packet loss, truncation and infinite error
#   interrupt generation.
#   
#   In velocity_rx_srv(), velocity_rx_refill() could be called without
#   any dirty slot.  With proper timing, This can result in refilling
#   yet unreceived packets and pushing dirty pointer ahead of the current
#   pointer.  And vptr->rd_curr which is used by velocity_rx_refill()
#   was updated after calling velocity_rx_refill() thus screwing
#   receive descriptor ring.  Also, between checking owner and reading
#   the packet, rmb() is missing.
# 
diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2004-09-13 13:49:15 +09:00
+++ b/drivers/net/via-velocity.c	2004-09-13 13:49:15 +09:00
@@ -1018,8 +1018,8 @@
 
 	wmb();
 
-	unusable = vptr->rd_filled | 0x0003;
-	dirty = vptr->rd_dirty - unusable + 1;
+	unusable = vptr->rd_filled & 0x0003;
+	dirty = vptr->rd_dirty - unusable;
 	for (avail = vptr->rd_filled & 0xfffc; avail; avail--) {
 		dirty = (dirty > 0) ? dirty - 1 : vptr->options.numrx - 1;
 		vptr->rd_ring[dirty].rdesc0.owner = OWNED_BY_NIC;
@@ -1232,15 +1232,17 @@
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
@@ -1263,14 +1265,15 @@
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

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="04velocity_init.patch"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/13 13:27:53+09:00 tj@cl.aratech.co.kr 
#   via-velocity init related bug fixes.
# 
# drivers/net/via-velocity.c
#   2004/09/13 13:27:36+09:00 tj@cl.aratech.co.kr +5 -4
#   In velocity_init_registers(), init_cam_filter() clears mCAMmask
#   which might have been set by set_multi() (not sure if this can ever
#   occur).  Modified to invoke init_cam_filter() first.  Also,
#   clear_isr() is called twice.  Removed the first invocation.
#   
#   In velocity_founc1(), there was a unneeded assignment from vptr to
#   dev->priv.  Removed.
# 
diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2004-09-13 13:49:37 +09:00
+++ b/drivers/net/via-velocity.c	2004-09-13 13:49:37 +09:00
@@ -592,6 +592,11 @@
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
@@ -615,8 +620,6 @@
 			mac_tx_queue_run(regs, i);
 		}
 
-		velocity_init_cam_filter(vptr);
-
 		init_flow_control_register(vptr);
 
 		writel(CR0_STOP, &regs->CR0Clr);
@@ -624,7 +627,6 @@
 
 		mii_status = velocity_get_opt_media_mode(vptr);
 		netif_stop_queue(vptr->dev);
-		mac_clear_isr(regs);
 
 		mii_init(vptr, mii_status);
 
@@ -723,7 +725,6 @@
 
 	vptr->dev = dev;
 
-	dev->priv = vptr;
 	dev->irq = pdev->irq;
 
 	ret = pci_enable_device(pdev);

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="05velocity_cpu_to_le32.patch"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/13 13:31:48+09:00 tj@cl.aratech.co.kr 
#   via-velocity minor fix.
# 
# drivers/net/via-velocity.c
#   2004/09/13 13:31:37+09:00 tj@cl.aratech.co.kr +1 -1
#   Removed cpu_to_le32 call on OWNED_BY_NIC.  This will produce
#   0x01000000 on big endian machines while rdesc0.owner still evaluates
#   to 0x00000000 or 0x00000001.  BTW, unless we reorder bit fields on
#   big endian machines or use u32's and cpu_to_le32'd bit mask macros,
#   current code won't work on big endian machines.
# 
diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2004-09-13 13:51:04 +09:00
+++ b/drivers/net/via-velocity.c	2004-09-13 13:51:04 +09:00
@@ -1038,7 +1038,7 @@
 		struct rx_desc *rd = vptr->rd_ring + dirty;
 
 		/* Fine for an all zero Rx desc at init time as well */
-		if (rd->rdesc0.owner == cpu_to_le32(OWNED_BY_NIC))
+		if (rd->rdesc0.owner == OWNED_BY_NIC)
 			break;
 
 		if (!vptr->rd_info[dirty].skb) {

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="06velocity_init_td_ring.patch"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/13 13:33:21+09:00 tj@cl.aratech.co.kr 
#   via-velocity another init bug fixed.
# 
# drivers/net/via-velocity.c
#   2004/09/13 13:33:10+09:00 tj@cl.aratech.co.kr +4 -2
#   Buffer offset calculation was incorrect in velocity_init_td_ring().
#   This didn't cause any trouble because we only use the first td ring.
# 
diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2004-09-13 13:51:26 +09:00
+++ b/drivers/net/via-velocity.c	2004-09-13 13:51:26 +09:00
@@ -1156,8 +1156,10 @@
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

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="07velocity_comment.patch"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/13 13:37:46+09:00 tj@cl.aratech.co.kr 
#   via-velocity comment fixes.
# 
# drivers/net/via-velocity.h
#   2004/09/13 13:37:35+09:00 tj@cl.aratech.co.kr +3 -3
#   Comment fixes.
# 
# drivers/net/via-velocity.c
#   2004/09/13 13:37:35+09:00 tj@cl.aratech.co.kr +3 -3
#   Comment fixes.
# 
diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2004-09-13 13:51:42 +09:00
+++ b/drivers/net/via-velocity.c	2004-09-13 13:51:42 +09:00
@@ -464,7 +464,7 @@
 {
 	struct mac_regs * regs = vptr->mac_regs;
 
-	/* T urn on MCFG_PQEN, turn off MCFG_RTGOPT */
+	/* Turn on MCFG_PQEN, turn off MCFG_RTGOPT */
 	WORD_REG_BITS_SET(MCFG_PQEN, MCFG_RTGOPT, &regs->MCFG);
 	WORD_REG_BITS_ON(MCFG_VIDFR, &regs->MCFG);
 
@@ -587,7 +587,7 @@
 
 		writeb(WOLCFG_SAM | WOLCFG_SAB, &regs->WOLCFGSet);
 		/*
-		 *	Bback off algorithm use original IEEE standard
+		 *	Back off algorithm use original IEEE standard
 		 */
 		BYTE_REG_BITS_SET(CFGB_OFSET, (CFGB_CRANDOM | CFGB_CAP | CFGB_MBA | CFGB_BAKOPT), &regs->CFGB);
 
@@ -1091,7 +1091,7 @@
 }
 
 /**
- *	velocity_free_rd_ring	-	set up receive ring
+ *	velocity_free_rd_ring	-	free receive ring
  *	@vptr: velocity to clean up
  *
  *	Free the receive buffers for each ring slot and any
diff -Nru a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
--- a/drivers/net/via-velocity.h	2004-09-13 13:51:42 +09:00
+++ b/drivers/net/via-velocity.h	2004-09-13 13:51:42 +09:00
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
 

--h31gzZEtNLTqOjlF--
