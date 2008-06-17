From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-next-2.6 5/6] atm: [he] remove #ifdef clutter
Date: Tue, 17 Jun 2008 09:16:38 -0400
Message-ID: <200806171316.m5HDGcUo005908@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:53847 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757128AbYFQNQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 09:16:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 69681e6f82cfb3386a06dc3f8101daf936b12f22
Author: Chas Williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
Date:   Sat Jun 14 17:38:39 2008 -0400

    atm: [he] remove #ifdef clutter
    
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 320320e..88034d9 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -75,14 +75,8 @@
 #include <linux/atm.h>
 #include <linux/sonet.h>
 
-#define USE_TASKLET
 #undef USE_SCATTERGATHER
 #undef USE_CHECKSUM_HW			/* still confused about this */
-#define USE_RBPS
-#undef USE_RBPS_POOL			/* if memory is tight try this */
-#undef USE_RBPL_POOL			/* if memory is tight try this */
-#define USE_TPD_POOL
-/* #undef CONFIG_ATM_HE_USE_SUNI */
 /* #undef HE_DEBUG */
 
 #include "he.h"
@@ -388,9 +382,7 @@ he_init_one(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 	he_dev->atm_dev->dev_data = he_dev;
 	atm_dev->dev_data = he_dev;
 	he_dev->number = atm_dev->number;
-#ifdef USE_TASKLET
 	tasklet_init(&he_dev->tasklet, he_tasklet, (unsigned long) he_dev);
-#endif
 	spin_lock_init(&he_dev->global_lock);
 
 	if (he_start(atm_dev)) {
@@ -787,23 +779,13 @@ he_init_group(struct he_dev *he_dev, int group)
 {
 	int i;
 
-#ifdef USE_RBPS
 	/* small buffer pool */
-#ifdef USE_RBPS_POOL
 	he_dev->rbps_pool = pci_pool_create("rbps", he_dev->pci_dev,
 			CONFIG_RBPS_BUFSIZE, 8, 0);
 	if (he_dev->rbps_pool == NULL) {
 		hprintk("unable to create rbps pages\n");
 		return -ENOMEM;
 	}
-#else /* !USE_RBPS_POOL */
-	he_dev->rbps_pages = pci_alloc_consistent(he_dev->pci_dev,
-		CONFIG_RBPS_SIZE * CONFIG_RBPS_BUFSIZE, &he_dev->rbps_pages_phys);
-	if (he_dev->rbps_pages == NULL) {
-		hprintk("unable to create rbps page pool\n");
-		return -ENOMEM;
-	}
-#endif /* USE_RBPS_POOL */
 
 	he_dev->rbps_base = pci_alloc_consistent(he_dev->pci_dev,
 		CONFIG_RBPS_SIZE * sizeof(struct he_rbp), &he_dev->rbps_phys);
@@ -818,14 +800,9 @@ he_init_group(struct he_dev *he_dev, int group)
 		dma_addr_t dma_handle;
 		void *cpuaddr;
 
-#ifdef USE_RBPS_POOL 
 		cpuaddr = pci_pool_alloc(he_dev->rbps_pool, GFP_KERNEL|GFP_DMA, &dma_handle);
 		if (cpuaddr == NULL)
 			return -ENOMEM;
-#else
-		cpuaddr = he_dev->rbps_pages + (i * CONFIG_RBPS_BUFSIZE);
-		dma_handle = he_dev->rbps_pages_phys + (i * CONFIG_RBPS_BUFSIZE);
-#endif
 
 		he_dev->rbps_virt[i].virt = cpuaddr;
 		he_dev->rbps_base[i].status = RBP_LOANED | RBP_SMALLBUF | (i << RBP_INDEX_OFF);
@@ -844,30 +821,14 @@ he_init_group(struct he_dev *he_dev, int group)
 			RBP_QSIZE(CONFIG_RBPS_SIZE - 1) |
 			RBP_INT_ENB,
 						G0_RBPS_QI + (group * 32));
-#else /* !USE_RBPS */
-	he_writel(he_dev, 0x0, G0_RBPS_S + (group * 32));
-	he_writel(he_dev, 0x0, G0_RBPS_T + (group * 32));
-	he_writel(he_dev, 0x0, G0_RBPS_QI + (group * 32));
-	he_writel(he_dev, RBP_THRESH(0x1) | RBP_QSIZE(0x0),
-						G0_RBPS_BS + (group * 32));
-#endif /* USE_RBPS */
 
 	/* large buffer pool */
-#ifdef USE_RBPL_POOL
 	he_dev->rbpl_pool = pci_pool_create("rbpl", he_dev->pci_dev,
 			CONFIG_RBPL_BUFSIZE, 8, 0);
 	if (he_dev->rbpl_pool == NULL) {
 		hprintk("unable to create rbpl pool\n");
 		return -ENOMEM;
 	}
-#else /* !USE_RBPL_POOL */
-	he_dev->rbpl_pages = (void *) pci_alloc_consistent(he_dev->pci_dev,
-		CONFIG_RBPL_SIZE * CONFIG_RBPL_BUFSIZE, &he_dev->rbpl_pages_phys);
-	if (he_dev->rbpl_pages == NULL) {
-		hprintk("unable to create rbpl pages\n");
-		return -ENOMEM;
-	}
-#endif /* USE_RBPL_POOL */
 
 	he_dev->rbpl_base = pci_alloc_consistent(he_dev->pci_dev,
 		CONFIG_RBPL_SIZE * sizeof(struct he_rbp), &he_dev->rbpl_phys);
@@ -882,14 +843,9 @@ he_init_group(struct he_dev *he_dev, int group)
 		dma_addr_t dma_handle;
 		void *cpuaddr;
 
-#ifdef USE_RBPL_POOL
 		cpuaddr = pci_pool_alloc(he_dev->rbpl_pool, GFP_KERNEL|GFP_DMA, &dma_handle);
 		if (cpuaddr == NULL)
 			return -ENOMEM;
-#else
-		cpuaddr = he_dev->rbpl_pages + (i * CONFIG_RBPL_BUFSIZE);
-		dma_handle = he_dev->rbpl_pages_phys + (i * CONFIG_RBPL_BUFSIZE);
-#endif
 
 		he_dev->rbpl_virt[i].virt = cpuaddr;
 		he_dev->rbpl_base[i].status = RBP_LOANED | (i << RBP_INDEX_OFF);
@@ -1475,7 +1431,6 @@ he_start(struct atm_dev *dev)
 
 	he_init_tpdrq(he_dev);
 
-#ifdef USE_TPD_POOL
 	he_dev->tpd_pool = pci_pool_create("tpd", he_dev->pci_dev,
 		sizeof(struct he_tpd), TPD_ALIGNMENT, 0);
 	if (he_dev->tpd_pool == NULL) {
@@ -1484,20 +1439,6 @@ he_start(struct atm_dev *dev)
 	}
 
 	INIT_LIST_HEAD(&he_dev->outstanding_tpds);
-#else
-	he_dev->tpd_base = (void *) pci_alloc_consistent(he_dev->pci_dev,
-			CONFIG_NUMTPDS * sizeof(struct he_tpd), &he_dev->tpd_base_phys);
-	if (!he_dev->tpd_base)
-		return -ENOMEM;
-
-	for (i = 0; i < CONFIG_NUMTPDS; ++i) {
-		he_dev->tpd_base[i].status = (i << TPD_ADDR_SHIFT);
-		he_dev->tpd_base[i].inuse = 0;
-	}
-		
-	he_dev->tpd_head = he_dev->tpd_base;
-	he_dev->tpd_end = &he_dev->tpd_base[CONFIG_NUMTPDS - 1];
-#endif
 
 	if (he_init_group(he_dev, 0) != 0)
 		return -ENOMEM;
@@ -1605,9 +1546,7 @@ he_stop(struct he_dev *he_dev)
 		gen_cntl_0 &= ~(INT_PROC_ENBL | INIT_ENB);
 		pci_write_config_dword(pci_dev, GEN_CNTL_0, gen_cntl_0);
 
-#ifdef USE_TASKLET
 		tasklet_disable(&he_dev->tasklet);
-#endif
 
 		/* disable recv and transmit */
 
@@ -1637,7 +1576,6 @@ he_stop(struct he_dev *he_dev)
 						he_dev->hsp, he_dev->hsp_phys);
 
 	if (he_dev->rbpl_base) {
-#ifdef USE_RBPL_POOL
 		int i;
 
 		for (i = 0; i < CONFIG_RBPL_SIZE; ++i) {
@@ -1646,22 +1584,14 @@ he_stop(struct he_dev *he_dev)
 
 			pci_pool_free(he_dev->rbpl_pool, cpuaddr, dma_handle);
 		}
-#else
-		pci_free_consistent(he_dev->pci_dev, CONFIG_RBPL_SIZE
-			* CONFIG_RBPL_BUFSIZE, he_dev->rbpl_pages, he_dev->rbpl_pages_phys);
-#endif
 		pci_free_consistent(he_dev->pci_dev, CONFIG_RBPL_SIZE
 			* sizeof(struct he_rbp), he_dev->rbpl_base, he_dev->rbpl_phys);
 	}
 
-#ifdef USE_RBPL_POOL
 	if (he_dev->rbpl_pool)
 		pci_pool_destroy(he_dev->rbpl_pool);
-#endif
 
-#ifdef USE_RBPS
 	if (he_dev->rbps_base) {
-#ifdef USE_RBPS_POOL
 		int i;
 
 		for (i = 0; i < CONFIG_RBPS_SIZE; ++i) {
@@ -1670,20 +1600,12 @@ he_stop(struct he_dev *he_dev)
 
 			pci_pool_free(he_dev->rbps_pool, cpuaddr, dma_handle);
 		}
-#else
-		pci_free_consistent(he_dev->pci_dev, CONFIG_RBPS_SIZE
-			* CONFIG_RBPS_BUFSIZE, he_dev->rbps_pages, he_dev->rbps_pages_phys);
-#endif
 		pci_free_consistent(he_dev->pci_dev, CONFIG_RBPS_SIZE
 			* sizeof(struct he_rbp), he_dev->rbps_base, he_dev->rbps_phys);
 	}
 
-#ifdef USE_RBPS_POOL
 	if (he_dev->rbps_pool)
 		pci_pool_destroy(he_dev->rbps_pool);
-#endif
-
-#endif /* USE_RBPS */
 
 	if (he_dev->rbrq_base)
 		pci_free_consistent(he_dev->pci_dev, CONFIG_RBRQ_SIZE * sizeof(struct he_rbrq),
@@ -1697,14 +1619,8 @@ he_stop(struct he_dev *he_dev)
 		pci_free_consistent(he_dev->pci_dev, CONFIG_TBRQ_SIZE * sizeof(struct he_tbrq),
 							he_dev->tpdrq_base, he_dev->tpdrq_phys);
 
-#ifdef USE_TPD_POOL
 	if (he_dev->tpd_pool)
 		pci_pool_destroy(he_dev->tpd_pool);
-#else
-	if (he_dev->tpd_base)
-		pci_free_consistent(he_dev->pci_dev, CONFIG_NUMTPDS * sizeof(struct he_tpd),
-							he_dev->tpd_base, he_dev->tpd_base_phys);
-#endif
 
 	if (he_dev->pci_dev) {
 		pci_read_config_word(he_dev->pci_dev, PCI_COMMAND, &command);
@@ -1719,7 +1635,6 @@ he_stop(struct he_dev *he_dev)
 static struct he_tpd *
 __alloc_tpd(struct he_dev *he_dev)
 {
-#ifdef USE_TPD_POOL
 	struct he_tpd *tpd;
 	dma_addr_t dma_handle; 
 
@@ -1734,27 +1649,6 @@ __alloc_tpd(struct he_dev *he_dev)
 	tpd->iovec[2].addr = 0; tpd->iovec[2].len = 0;
 
 	return tpd;
-#else
-	int i;
-
-	for (i = 0; i < CONFIG_NUMTPDS; ++i) {
-		++he_dev->tpd_head;
-		if (he_dev->tpd_head > he_dev->tpd_end) {
-			he_dev->tpd_head = he_dev->tpd_base;
-		}
-
-		if (!he_dev->tpd_head->inuse) {
-			he_dev->tpd_head->inuse = 1;
-			he_dev->tpd_head->status &= TPD_MASK;
-			he_dev->tpd_head->iovec[0].addr = 0; he_dev->tpd_head->iovec[0].len = 0;
-			he_dev->tpd_head->iovec[1].addr = 0; he_dev->tpd_head->iovec[1].len = 0;
-			he_dev->tpd_head->iovec[2].addr = 0; he_dev->tpd_head->iovec[2].len = 0;
-			return he_dev->tpd_head;
-		}
-	}
-	hprintk("out of tpds -- increase CONFIG_NUMTPDS (%d)\n", CONFIG_NUMTPDS);
-	return NULL;
-#endif
 }
 
 #define AAL5_LEN(buf,len) 						\
@@ -1803,11 +1697,9 @@ he_service_rbrq(struct he_dev *he_dev, int group)
 			RBRQ_CON_CLOSED(he_dev->rbrq_head) ? " CON_CLOSED" : "",
 			RBRQ_HBUF_ERR(he_dev->rbrq_head) ? " HBUF_ERR" : "");
 
-#ifdef USE_RBPS
 		if (RBRQ_ADDR(he_dev->rbrq_head) & RBP_SMALLBUF)
 			rbp = &he_dev->rbps_base[RBP_INDEX(RBRQ_ADDR(he_dev->rbrq_head))];
 		else
-#endif
 			rbp = &he_dev->rbpl_base[RBP_INDEX(RBRQ_ADDR(he_dev->rbrq_head))];
 		
 		buf_len = RBRQ_BUFLEN(he_dev->rbrq_head) * 4;
@@ -1886,12 +1778,10 @@ he_service_rbrq(struct he_dev *he_dev, int group)
 
 		for (iov = he_vcc->iov_head;
 				iov < he_vcc->iov_tail; ++iov) {
-#ifdef USE_RBPS
 			if (iov->iov_base & RBP_SMALLBUF)
 				memcpy(skb_put(skb, iov->iov_len),
 					he_dev->rbps_virt[RBP_INDEX(iov->iov_base)].virt, iov->iov_len);
 			else
-#endif
 				memcpy(skb_put(skb, iov->iov_len),
 					he_dev->rbpl_virt[RBP_INDEX(iov->iov_base)].virt, iov->iov_len);
 		}
@@ -1936,11 +1826,9 @@ return_host_buffers:
 
 		for (iov = he_vcc->iov_head;
 				iov < he_vcc->iov_tail; ++iov) {
-#ifdef USE_RBPS
 			if (iov->iov_base & RBP_SMALLBUF)
 				rbp = &he_dev->rbps_base[RBP_INDEX(iov->iov_base)];
 			else
-#endif
 				rbp = &he_dev->rbpl_base[RBP_INDEX(iov->iov_base)];
 
 			rbp->status &= ~RBP_LOANED;
@@ -1976,9 +1864,7 @@ he_service_tbrq(struct he_dev *he_dev, int group)
 					he_dev->hsp->group[group].tbrq_tail);
 	struct he_tpd *tpd;
 	int slot, updated = 0;
-#ifdef USE_TPD_POOL
 	struct he_tpd *__tpd;
-#endif
 
 	/* 2.1.6 transmit buffer return queue */
 
@@ -1990,7 +1876,6 @@ he_service_tbrq(struct he_dev *he_dev, int group)
 			TBRQ_TPD(he_dev->tbrq_head), 
 			TBRQ_EOS(he_dev->tbrq_head) ? " EOS" : "",
 			TBRQ_MULTIPLE(he_dev->tbrq_head) ? " MULTIPLE" : "");
-#ifdef USE_TPD_POOL
 		tpd = NULL;
 		list_for_each_entry(__tpd, &he_dev->outstanding_tpds, entry) {
 			if (TPD_ADDR(__tpd->status) == TBRQ_TPD(he_dev->tbrq_head)) {
@@ -2005,9 +1890,6 @@ he_service_tbrq(struct he_dev *he_dev, int group)
 						TBRQ_TPD(he_dev->tbrq_head));
 			goto next_tbrq_entry;
 		}
-#else
-		tpd = &he_dev->tpd_base[ TPD_INDEX(TBRQ_TPD(he_dev->tbrq_head)) ];
-#endif
 
 		if (TBRQ_EOS(he_dev->tbrq_head)) {
 			HPRINTK("wake_up(tx_waitq) cid 0x%x\n",
@@ -2037,12 +1919,8 @@ he_service_tbrq(struct he_dev *he_dev, int group)
 		}
 
 next_tbrq_entry:
-#ifdef USE_TPD_POOL
 		if (tpd)
 			pci_pool_free(he_dev->tpd_pool, tpd, TPD_ADDR(tpd->status));
-#else
-		tpd->inuse = 0;
-#endif
 		he_dev->tbrq_head = (struct he_tbrq *)
 				((unsigned long) he_dev->tbrq_base |
 					TBRQ_MASK(++he_dev->tbrq_head));
@@ -2085,7 +1963,6 @@ he_service_rbpl(struct he_dev *he_dev, int group)
 		he_writel(he_dev, RBPL_MASK(he_dev->rbpl_tail), G0_RBPL_T);
 }
 
-#ifdef USE_RBPS
 static void
 he_service_rbps(struct he_dev *he_dev, int group)
 {
@@ -2112,7 +1989,6 @@ he_service_rbps(struct he_dev *he_dev, int group)
 	if (moved)
 		he_writel(he_dev, RBPS_MASK(he_dev->rbps_tail), G0_RBPS_T);
 }
-#endif /* USE_RBPS */
 
 static void
 he_tasklet(unsigned long data)
@@ -2123,9 +1999,7 @@ he_tasklet(unsigned long data)
 	int updated = 0;
 
 	HPRINTK("tasklet (0x%lx)\n", data);
-#ifdef USE_TASKLET
 	spin_lock_irqsave(&he_dev->global_lock, flags);
-#endif
 
 	while (he_dev->irq_head != he_dev->irq_tail) {
 		++updated;
@@ -2140,9 +2014,7 @@ he_tasklet(unsigned long data)
 			case ITYPE_RBRQ_TIMER:
 				if (he_service_rbrq(he_dev, group)) {
 					he_service_rbpl(he_dev, group);
-#ifdef USE_RBPS
 					he_service_rbps(he_dev, group);
-#endif /* USE_RBPS */
 				}
 				break;
 			case ITYPE_TBRQ_THRESH:
@@ -2155,9 +2027,7 @@ he_tasklet(unsigned long data)
 				he_service_rbpl(he_dev, group);
 				break;
 			case ITYPE_RBPS_THRESH:
-#ifdef USE_RBPS
 				he_service_rbps(he_dev, group);
-#endif /* USE_RBPS */
 				break;
 			case ITYPE_PHY:
 				HPRINTK("phy interrupt\n");
@@ -2185,9 +2055,7 @@ he_tasklet(unsigned long data)
 
 				he_service_rbrq(he_dev, 0);
 				he_service_rbpl(he_dev, 0);
-#ifdef USE_RBPS
 				he_service_rbps(he_dev, 0);
-#endif /* USE_RBPS */
 				he_service_tbrq(he_dev, 0);
 				break;
 			default:
@@ -2209,9 +2077,7 @@ he_tasklet(unsigned long data)
 			IRQ_TAIL(he_dev->irq_tail), IRQ0_HEAD);
 		(void) he_readl(he_dev, INT_FIFO); /* 8.1.2 controller errata; flush posted writes */
 	}
-#ifdef USE_TASKLET
 	spin_unlock_irqrestore(&he_dev->global_lock, flags);
-#endif
 }
 
 static irqreturn_t
@@ -2243,11 +2109,7 @@ he_irq_handler(int irq, void *dev_id)
 
 	if (he_dev->irq_head != he_dev->irq_tail) {
 		handled = 1;
-#ifdef USE_TASKLET
 		tasklet_schedule(&he_dev->tasklet);
-#else
-		he_tasklet((unsigned long) he_dev);
-#endif
 		he_writel(he_dev, INT_CLEAR_A, INT_FIFO);	/* clear interrupt */
 		(void) he_readl(he_dev, INT_FIFO);		/* flush posted writes */
 	}
@@ -2304,23 +2166,14 @@ __enqueue_tpd(struct he_dev *he_dev, struct he_tpd *tpd, unsigned cid)
 					dev_kfree_skb_any(tpd->skb);
 				atomic_inc(&tpd->vcc->stats->tx_err);
 			}
-#ifdef USE_TPD_POOL
 			pci_pool_free(he_dev->tpd_pool, tpd, TPD_ADDR(tpd->status));
-#else
-			tpd->inuse = 0;
-#endif
 			return;
 		}
 	}
 
 	/* 2.1.5 transmit packet descriptor ready queue */
-#ifdef USE_TPD_POOL
 	list_add_tail(&tpd->entry, &he_dev->outstanding_tpds);
 	he_dev->tpdrq_tail->tpd = TPD_ADDR(tpd->status);
-#else
-	he_dev->tpdrq_tail->tpd = he_dev->tpd_base_phys +
-				(TPD_INDEX(tpd->status) * sizeof(struct he_tpd));
-#endif
 	he_dev->tpdrq_tail->cid = cid;
 	wmb();
 
@@ -2510,13 +2363,8 @@ he_open(struct atm_vcc *vcc)
 			goto open_failed;
 		}
 
-#ifdef USE_RBPS
 		rsr1 = RSR1_GROUP(0);
 		rsr4 = RSR4_GROUP(0);
-#else /* !USE_RBPS */
-		rsr1 = RSR1_GROUP(0)|RSR1_RBPL_ONLY;
-		rsr4 = RSR4_GROUP(0)|RSR4_RBPL_ONLY;
-#endif /* USE_RBPS */
 		rsr0 = vcc->qos.rxtp.traffic_class == ATM_UBR ? 
 				(RSR0_EPD_ENABLE|RSR0_PPD_ENABLE) : 0;
 
diff --git a/drivers/atm/he.h b/drivers/atm/he.h
index a54d64f..07d40e7 100644
--- a/drivers/atm/he.h
+++ b/drivers/atm/he.h
@@ -51,8 +51,6 @@
 #define CONFIG_IRQ_SIZE		128
 #define CONFIG_IRQ_THRESH	(CONFIG_IRQ_SIZE/2)
 
-#define CONFIG_NUMTPDS		256
-
 #define CONFIG_TPDRQ_SIZE	512
 #define TPDRQ_MASK(x)		(((unsigned long)(x))&((CONFIG_TPDRQ_SIZE<<3)-1))
 
@@ -140,12 +138,7 @@ struct he_tpd {
 	struct sk_buff *skb;
 	struct atm_vcc *vcc;
 
-#ifdef USE_TPD_POOL
 	struct list_head entry;
-#else
-	u32 inuse;
-	char padding[32 - sizeof(u32) - (2*sizeof(void*))];
-#endif
 };
 
 #define TPD_ALIGNMENT	64
@@ -291,16 +284,9 @@ struct he_dev {
 	volatile unsigned *irq_tailoffset;
 	int irq_peak;
 
-#ifdef USE_TASKLET
 	struct tasklet_struct tasklet;
-#endif
-#ifdef USE_TPD_POOL
 	struct pci_pool *tpd_pool;
 	struct list_head outstanding_tpds;
-#else
-	struct he_tpd *tpd_head, *tpd_base, *tpd_end;
-	dma_addr_t tpd_base_phys;
-#endif
 
 	dma_addr_t tpdrq_phys;
 	struct he_tpdrq *tpdrq_base, *tpdrq_tail, *tpdrq_head;
@@ -311,25 +297,13 @@ struct he_dev {
 	struct he_rbrq *rbrq_base, *rbrq_head;
 	int rbrq_peak;
 
-#ifdef USE_RBPL_POOL
 	struct pci_pool *rbpl_pool;
-#else
-	void *rbpl_pages;
-	dma_addr_t rbpl_pages_phys;
-#endif
 	dma_addr_t rbpl_phys;
 	struct he_rbp *rbpl_base, *rbpl_tail;
 	struct he_virt *rbpl_virt;
 	int rbpl_peak;
 
-#ifdef USE_RBPS
-#ifdef USE_RBPS_POOL
 	struct pci_pool *rbps_pool;
-#else
-	void *rbps_pages;
-	dma_addr_t rbps_pages_phys;
-#endif
-#endif
 	dma_addr_t rbps_phys;
 	struct he_rbp *rbps_base, *rbps_tail;
 	struct he_virt *rbps_virt;
