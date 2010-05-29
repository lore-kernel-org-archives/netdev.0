From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-next-2.6 3/4] atm: [he] remove small buffer allocation/handling code
Date: Sat, 29 May 2010 15:04:59 -0400
Message-ID: <201005291904.o4TJ4xEl006158@thirdoffive.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:58760 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab0E2TPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 15:15:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

Author: chas williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
Date:   Fri May 28 19:45:59 2010 -0400

    atm: [he] remove small buffer allocation/handling code
    
    Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 56c2e99..c725494 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -780,59 +780,18 @@ he_init_group(struct he_dev *he_dev, int group)
 {
 	int i;
 
-	/* small buffer pool */
-	he_dev->rbps_pool = pci_pool_create("rbps", he_dev->pci_dev,
-			CONFIG_RBPS_BUFSIZE, 8, 0);
-	if (he_dev->rbps_pool == NULL) {
-		hprintk("unable to create rbps pages\n");
-		return -ENOMEM;
-	}
-
-	he_dev->rbps_base = pci_alloc_consistent(he_dev->pci_dev,
-		CONFIG_RBPS_SIZE * sizeof(struct he_rbp), &he_dev->rbps_phys);
-	if (he_dev->rbps_base == NULL) {
-		hprintk("failed to alloc rbps_base\n");
-		goto out_destroy_rbps_pool;
-	}
-	memset(he_dev->rbps_base, 0, CONFIG_RBPS_SIZE * sizeof(struct he_rbp));
-	he_dev->rbps_virt = kmalloc(CONFIG_RBPS_SIZE * sizeof(struct he_virt), GFP_KERNEL);
-	if (he_dev->rbps_virt == NULL) {
-		hprintk("failed to alloc rbps_virt\n");
-		goto out_free_rbps_base;
-	}
-
-	for (i = 0; i < CONFIG_RBPS_SIZE; ++i) {
-		dma_addr_t dma_handle;
-		void *cpuaddr;
-
-		cpuaddr = pci_pool_alloc(he_dev->rbps_pool, GFP_KERNEL|GFP_DMA, &dma_handle);
-		if (cpuaddr == NULL)
-			goto out_free_rbps_virt;
-
-		he_dev->rbps_virt[i].virt = cpuaddr;
-		he_dev->rbps_base[i].status = RBP_LOANED | RBP_SMALLBUF | (i << RBP_INDEX_OFF);
-		he_dev->rbps_base[i].phys = dma_handle;
-
-	}
-	he_dev->rbps_tail = &he_dev->rbps_base[CONFIG_RBPS_SIZE - 1];
-
-	he_writel(he_dev, he_dev->rbps_phys, G0_RBPS_S + (group * 32));
-	he_writel(he_dev, RBPS_MASK(he_dev->rbps_tail),
-						G0_RBPS_T + (group * 32));
-	he_writel(he_dev, CONFIG_RBPS_BUFSIZE/4,
-						G0_RBPS_BS + (group * 32));
-	he_writel(he_dev,
-			RBP_THRESH(CONFIG_RBPS_THRESH) |
-			RBP_QSIZE(CONFIG_RBPS_SIZE - 1) |
-			RBP_INT_ENB,
-						G0_RBPS_QI + (group * 32));
+	he_writel(he_dev, 0x0, G0_RBPS_S + (group * 32));
+	he_writel(he_dev, 0x0, G0_RBPS_T + (group * 32));
+	he_writel(he_dev, 0x0, G0_RBPS_QI + (group * 32));
+	he_writel(he_dev, RBP_THRESH(0x1) | RBP_QSIZE(0x0),
+		  G0_RBPS_BS + (group * 32));
 
 	/* large buffer pool */
 	he_dev->rbpl_pool = pci_pool_create("rbpl", he_dev->pci_dev,
 			CONFIG_RBPL_BUFSIZE, 8, 0);
 	if (he_dev->rbpl_pool == NULL) {
 		hprintk("unable to create rbpl pool\n");
-		goto out_free_rbps_virt;
+		return -ENOMEM;
 	}
 
 	he_dev->rbpl_base = pci_alloc_consistent(he_dev->pci_dev,
@@ -934,19 +893,6 @@ out_free_rbpl_base:
 out_destroy_rbpl_pool:
 	pci_pool_destroy(he_dev->rbpl_pool);
 
-	i = CONFIG_RBPS_SIZE;
-out_free_rbps_virt:
-	while (i--)
-		pci_pool_free(he_dev->rbps_pool, he_dev->rbps_virt[i].virt,
-				he_dev->rbps_base[i].phys);
-	kfree(he_dev->rbps_virt);
-
-out_free_rbps_base:
-	pci_free_consistent(he_dev->pci_dev, CONFIG_RBPS_SIZE *
-			sizeof(struct he_rbp), he_dev->rbps_base,
-			he_dev->rbps_phys);
-out_destroy_rbps_pool:
-	pci_pool_destroy(he_dev->rbps_pool);
 	return -ENOMEM;
 }
 
@@ -1634,22 +1580,6 @@ he_stop(struct he_dev *he_dev)
 	if (he_dev->rbpl_pool)
 		pci_pool_destroy(he_dev->rbpl_pool);
 
-	if (he_dev->rbps_base) {
-		int i;
-
-		for (i = 0; i < CONFIG_RBPS_SIZE; ++i) {
-			void *cpuaddr = he_dev->rbps_virt[i].virt;
-			dma_addr_t dma_handle = he_dev->rbps_base[i].phys;
-
-			pci_pool_free(he_dev->rbps_pool, cpuaddr, dma_handle);
-		}
-		pci_free_consistent(he_dev->pci_dev, CONFIG_RBPS_SIZE
-			* sizeof(struct he_rbp), he_dev->rbps_base, he_dev->rbps_phys);
-	}
-
-	if (he_dev->rbps_pool)
-		pci_pool_destroy(he_dev->rbps_pool);
-
 	if (he_dev->rbrq_base)
 		pci_free_consistent(he_dev->pci_dev, CONFIG_RBRQ_SIZE * sizeof(struct he_rbrq),
 							he_dev->rbrq_base, he_dev->rbrq_phys);
@@ -1740,10 +1670,7 @@ he_service_rbrq(struct he_dev *he_dev, int group)
 			RBRQ_CON_CLOSED(he_dev->rbrq_head) ? " CON_CLOSED" : "",
 			RBRQ_HBUF_ERR(he_dev->rbrq_head) ? " HBUF_ERR" : "");
 
-		if (RBRQ_ADDR(he_dev->rbrq_head) & RBP_SMALLBUF)
-			rbp = &he_dev->rbps_base[RBP_INDEX(RBRQ_ADDR(he_dev->rbrq_head))];
-		else
-			rbp = &he_dev->rbpl_base[RBP_INDEX(RBRQ_ADDR(he_dev->rbrq_head))];
+		rbp = &he_dev->rbpl_base[RBP_INDEX(RBRQ_ADDR(he_dev->rbrq_head))];
 		
 		buf_len = RBRQ_BUFLEN(he_dev->rbrq_head) * 4;
 		cid = RBRQ_CID(he_dev->rbrq_head);
@@ -1819,15 +1746,9 @@ he_service_rbrq(struct he_dev *he_dev, int group)
 
 		__net_timestamp(skb);
 
-		for (iov = he_vcc->iov_head;
-				iov < he_vcc->iov_tail; ++iov) {
-			if (iov->iov_base & RBP_SMALLBUF)
-				memcpy(skb_put(skb, iov->iov_len),
-					he_dev->rbps_virt[RBP_INDEX(iov->iov_base)].virt, iov->iov_len);
-			else
-				memcpy(skb_put(skb, iov->iov_len),
-					he_dev->rbpl_virt[RBP_INDEX(iov->iov_base)].virt, iov->iov_len);
-		}
+		for (iov = he_vcc->iov_head; iov < he_vcc->iov_tail; ++iov)
+			memcpy(skb_put(skb, iov->iov_len),
+			       he_dev->rbpl_virt[RBP_INDEX(iov->iov_base)].virt, iov->iov_len);
 
 		switch (vcc->qos.aal) {
 			case ATM_AAL0:
@@ -1867,13 +1788,8 @@ he_service_rbrq(struct he_dev *he_dev, int group)
 return_host_buffers:
 		++pdus_assembled;
 
-		for (iov = he_vcc->iov_head;
-				iov < he_vcc->iov_tail; ++iov) {
-			if (iov->iov_base & RBP_SMALLBUF)
-				rbp = &he_dev->rbps_base[RBP_INDEX(iov->iov_base)];
-			else
-				rbp = &he_dev->rbpl_base[RBP_INDEX(iov->iov_base)];
-
+		for (iov = he_vcc->iov_head; iov < he_vcc->iov_tail; ++iov) {
+			rbp = &he_dev->rbpl_base[RBP_INDEX(iov->iov_base)];
 			rbp->status &= ~RBP_LOANED;
 		}
 
@@ -1978,7 +1894,6 @@ next_tbrq_entry:
 	}
 }
 
-
 static void
 he_service_rbpl(struct he_dev *he_dev, int group)
 {
@@ -2007,33 +1922,6 @@ he_service_rbpl(struct he_dev *he_dev, int group)
 }
 
 static void
-he_service_rbps(struct he_dev *he_dev, int group)
-{
-	struct he_rbp *newtail;
-	struct he_rbp *rbps_head;
-	int moved = 0;
-
-	rbps_head = (struct he_rbp *) ((unsigned long)he_dev->rbps_base |
-					RBPS_MASK(he_readl(he_dev, G0_RBPS_S)));
-
-	for (;;) {
-		newtail = (struct he_rbp *) ((unsigned long)he_dev->rbps_base |
-						RBPS_MASK(he_dev->rbps_tail+1));
-
-		/* table 3.42 -- rbps_tail should never be set to rbps_head */
-		if ((newtail == rbps_head) || (newtail->status & RBP_LOANED))
-			break;
-
-		newtail->status |= RBP_LOANED;
-		he_dev->rbps_tail = newtail;
-		++moved;
-	} 
-
-	if (moved)
-		he_writel(he_dev, RBPS_MASK(he_dev->rbps_tail), G0_RBPS_T);
-}
-
-static void
 he_tasklet(unsigned long data)
 {
 	unsigned long flags;
@@ -2055,10 +1943,8 @@ he_tasklet(unsigned long data)
 				HPRINTK("rbrq%d threshold\n", group);
 				/* fall through */
 			case ITYPE_RBRQ_TIMER:
-				if (he_service_rbrq(he_dev, group)) {
+				if (he_service_rbrq(he_dev, group))
 					he_service_rbpl(he_dev, group);
-					he_service_rbps(he_dev, group);
-				}
 				break;
 			case ITYPE_TBRQ_THRESH:
 				HPRINTK("tbrq%d threshold\n", group);
@@ -2070,7 +1956,7 @@ he_tasklet(unsigned long data)
 				he_service_rbpl(he_dev, group);
 				break;
 			case ITYPE_RBPS_THRESH:
-				he_service_rbps(he_dev, group);
+				/* shouldn't happen unless small buffers enabled */
 				break;
 			case ITYPE_PHY:
 				HPRINTK("phy interrupt\n");
@@ -2098,7 +1984,6 @@ he_tasklet(unsigned long data)
 
 				he_service_rbrq(he_dev, 0);
 				he_service_rbpl(he_dev, 0);
-				he_service_rbps(he_dev, 0);
 				he_service_tbrq(he_dev, 0);
 				break;
 			default:
@@ -2406,8 +2291,8 @@ he_open(struct atm_vcc *vcc)
 			goto open_failed;
 		}
 
-		rsr1 = RSR1_GROUP(0);
-		rsr4 = RSR4_GROUP(0);
+		rsr1 = RSR1_GROUP(0) | RSR1_RBPL_ONLY;
+		rsr4 = RSR4_GROUP(0) | RSR4_RBPL_ONLY;
 		rsr0 = vcc->qos.rxtp.traffic_class == ATM_UBR ? 
 				(RSR0_EPD_ENABLE|RSR0_PPD_ENABLE) : 0;
 
diff --git a/drivers/atm/he.h b/drivers/atm/he.h
index c2983e0..8bf3264 100644
--- a/drivers/atm/he.h
+++ b/drivers/atm/he.h
@@ -67,11 +67,6 @@
 #define CONFIG_RBPL_BUFSIZE	4096
 #define RBPL_MASK(x)		(((unsigned long)(x))&((CONFIG_RBPL_SIZE<<3)-1))
 
-#define CONFIG_RBPS_SIZE	1024
-#define CONFIG_RBPS_THRESH	64
-#define CONFIG_RBPS_BUFSIZE	128
-#define RBPS_MASK(x)		(((unsigned long)(x))&((CONFIG_RBPS_SIZE<<3)-1))
-
 /* 5.1.3 initialize connection memory */
 
 #define CONFIG_RSRA		0x00000
@@ -225,14 +220,8 @@ struct he_virt {
 	void *virt;
 };
 
-#define RBPL_ALIGNMENT CONFIG_RBPL_SIZE
-#define RBPS_ALIGNMENT CONFIG_RBPS_SIZE
-
 #ifdef notyet
 struct he_group {
-	u32 rpbs_size, rpbs_qsize;
-	struct he_rbp rbps_ba;
-
 	u32 rpbl_size, rpbl_qsize;
 	struct he_rpb_entry *rbpl_ba;
 };
@@ -303,12 +292,6 @@ struct he_dev {
 	struct he_virt *rbpl_virt;
 	int rbpl_peak;
 
-	struct pci_pool *rbps_pool;
-	dma_addr_t rbps_phys;
-	struct he_rbp *rbps_base, *rbps_tail;
-	struct he_virt *rbps_virt;
-	int rbps_peak;
-
 	dma_addr_t tbrq_phys;
 	struct he_tbrq *tbrq_base, *tbrq_head;
 	int tbrq_peak;
