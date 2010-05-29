From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-next-2.6 4/4] atm: [he] rewrite buffer handling in receive path
Date: Sat, 29 May 2010 15:05:33 -0400
Message-ID: <201005291905.o4TJ5XrX006431@thirdoffive.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:58760 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191Ab0E2TPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 15:15:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

Author: chas williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
Date:   Fri May 28 19:50:47 2010 -0400

    atm: [he] rewrite buffer handling in receive path
    
    Instead of a fixed list of buffers, use the buffer pool correctly and
    keep track of the outstanding buffer indexes using a fixed table.
    Resolves reported HBUF_ERR's -- failures due to lack of receive buffers.
    
    Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index c725494..ea9cbe5 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -67,6 +67,7 @@
 #include <linux/timer.h>
 #include <linux/interrupt.h>
 #include <linux/dma-mapping.h>
+#include <linux/bitmap.h>
 #include <linux/slab.h>
 #include <asm/io.h>
 #include <asm/byteorder.h>
@@ -778,6 +779,8 @@ he_init_cs_block_rcm(struct he_dev *he_dev)
 static int __devinit
 he_init_group(struct he_dev *he_dev, int group)
 {
+	struct he_buff *heb, *next;
+	dma_addr_t mapping;
 	int i;
 
 	he_writel(he_dev, 0x0, G0_RBPS_S + (group * 32));
@@ -786,12 +789,29 @@ he_init_group(struct he_dev *he_dev, int group)
 	he_writel(he_dev, RBP_THRESH(0x1) | RBP_QSIZE(0x0),
 		  G0_RBPS_BS + (group * 32));
 
+	/* bitmap table */
+	he_dev->rbpl_table = kmalloc(BITS_TO_LONGS(RBPL_TABLE_SIZE)
+				     * sizeof(unsigned long), GFP_KERNEL);
+	if (!he_dev->rbpl_table) {
+		hprintk("unable to allocate rbpl bitmap table\n");
+		return -ENOMEM;
+	}
+	bitmap_zero(he_dev->rbpl_table, RBPL_TABLE_SIZE);
+
+	/* rbpl_virt 64-bit pointers */
+	he_dev->rbpl_virt = kmalloc(RBPL_TABLE_SIZE
+				    * sizeof(struct he_buff *), GFP_KERNEL);
+	if (!he_dev->rbpl_virt) {
+		hprintk("unable to allocate rbpl virt table\n");
+		goto out_free_rbpl_table;
+	}
+
 	/* large buffer pool */
 	he_dev->rbpl_pool = pci_pool_create("rbpl", he_dev->pci_dev,
-			CONFIG_RBPL_BUFSIZE, 8, 0);
+					    CONFIG_RBPL_BUFSIZE, 64, 0);
 	if (he_dev->rbpl_pool == NULL) {
 		hprintk("unable to create rbpl pool\n");
-		return -ENOMEM;
+		goto out_free_rbpl_virt;
 	}
 
 	he_dev->rbpl_base = pci_alloc_consistent(he_dev->pci_dev,
@@ -801,30 +821,29 @@ he_init_group(struct he_dev *he_dev, int group)
 		goto out_destroy_rbpl_pool;
 	}
 	memset(he_dev->rbpl_base, 0, CONFIG_RBPL_SIZE * sizeof(struct he_rbp));
-	he_dev->rbpl_virt = kmalloc(CONFIG_RBPL_SIZE * sizeof(struct he_virt), GFP_KERNEL);
-	if (he_dev->rbpl_virt == NULL) {
-		hprintk("failed to alloc rbpl_virt\n");
-		goto out_free_rbpl_base;
-	}
+
+	INIT_LIST_HEAD(&he_dev->rbpl_outstanding);
 
 	for (i = 0; i < CONFIG_RBPL_SIZE; ++i) {
-		dma_addr_t dma_handle;
-		void *cpuaddr;
 
-		cpuaddr = pci_pool_alloc(he_dev->rbpl_pool, GFP_KERNEL|GFP_DMA, &dma_handle);
-		if (cpuaddr == NULL)
-			goto out_free_rbpl_virt;
+		heb = pci_pool_alloc(he_dev->rbpl_pool, GFP_KERNEL|GFP_DMA, &mapping);
+		if (!heb)
+			goto out_free_rbpl;
+		heb->mapping = mapping;
+		list_add(&heb->entry, &he_dev->rbpl_outstanding);
 
-		he_dev->rbpl_virt[i].virt = cpuaddr;
-		he_dev->rbpl_base[i].status = RBP_LOANED | (i << RBP_INDEX_OFF);
-		he_dev->rbpl_base[i].phys = dma_handle;
+		set_bit(i, he_dev->rbpl_table);
+		he_dev->rbpl_virt[i] = heb;
+		he_dev->rbpl_hint = i + 1;
+		he_dev->rbpl_base[i].idx =  i << RBP_IDX_OFFSET;
+		he_dev->rbpl_base[i].phys = mapping + offsetof(struct he_buff, data);
 	}
 	he_dev->rbpl_tail = &he_dev->rbpl_base[CONFIG_RBPL_SIZE - 1];
 
 	he_writel(he_dev, he_dev->rbpl_phys, G0_RBPL_S + (group * 32));
 	he_writel(he_dev, RBPL_MASK(he_dev->rbpl_tail),
 						G0_RBPL_T + (group * 32));
-	he_writel(he_dev, CONFIG_RBPL_BUFSIZE/4,
+	he_writel(he_dev, (CONFIG_RBPL_BUFSIZE - sizeof(struct he_buff))/4,
 						G0_RBPL_BS + (group * 32));
 	he_writel(he_dev,
 			RBP_THRESH(CONFIG_RBPL_THRESH) |
@@ -838,7 +857,7 @@ he_init_group(struct he_dev *he_dev, int group)
 		CONFIG_RBRQ_SIZE * sizeof(struct he_rbrq), &he_dev->rbrq_phys);
 	if (he_dev->rbrq_base == NULL) {
 		hprintk("failed to allocate rbrq\n");
-		goto out_free_rbpl_virt;
+		goto out_free_rbpl;
 	}
 	memset(he_dev->rbrq_base, 0, CONFIG_RBRQ_SIZE * sizeof(struct he_rbrq));
 
@@ -879,19 +898,19 @@ out_free_rbpq_base:
 	pci_free_consistent(he_dev->pci_dev, CONFIG_RBRQ_SIZE *
 			sizeof(struct he_rbrq), he_dev->rbrq_base,
 			he_dev->rbrq_phys);
-	i = CONFIG_RBPL_SIZE;
-out_free_rbpl_virt:
-	while (i--)
-		pci_pool_free(he_dev->rbpl_pool, he_dev->rbpl_virt[i].virt,
-				he_dev->rbpl_base[i].phys);
-	kfree(he_dev->rbpl_virt);
+out_free_rbpl:
+	list_for_each_entry_safe(heb, next, &he_dev->rbpl_outstanding, entry)
+		pci_pool_free(he_dev->rbpl_pool, heb, heb->mapping);
 
-out_free_rbpl_base:
 	pci_free_consistent(he_dev->pci_dev, CONFIG_RBPL_SIZE *
 			sizeof(struct he_rbp), he_dev->rbpl_base,
 			he_dev->rbpl_phys);
 out_destroy_rbpl_pool:
 	pci_pool_destroy(he_dev->rbpl_pool);
+out_free_rbpl_virt:
+	kfree(he_dev->rbpl_virt);
+out_free_rbpl_table:
+	kfree(he_dev->rbpl_table);
 
 	return -ENOMEM;
 }
@@ -1522,9 +1541,10 @@ he_start(struct atm_dev *dev)
 static void
 he_stop(struct he_dev *he_dev)
 {
-	u16 command;
-	u32 gen_cntl_0, reg;
+	struct he_buff *heb, *next;
 	struct pci_dev *pci_dev;
+	u32 gen_cntl_0, reg;
+	u16 command;
 
 	pci_dev = he_dev->pci_dev;
 
@@ -1565,18 +1585,16 @@ he_stop(struct he_dev *he_dev)
 						he_dev->hsp, he_dev->hsp_phys);
 
 	if (he_dev->rbpl_base) {
-		int i;
-
-		for (i = 0; i < CONFIG_RBPL_SIZE; ++i) {
-			void *cpuaddr = he_dev->rbpl_virt[i].virt;
-			dma_addr_t dma_handle = he_dev->rbpl_base[i].phys;
+		list_for_each_entry_safe(heb, next, &he_dev->rbpl_outstanding, entry)
+			pci_pool_free(he_dev->rbpl_pool, heb, heb->mapping);
 
-			pci_pool_free(he_dev->rbpl_pool, cpuaddr, dma_handle);
-		}
 		pci_free_consistent(he_dev->pci_dev, CONFIG_RBPL_SIZE
 			* sizeof(struct he_rbp), he_dev->rbpl_base, he_dev->rbpl_phys);
 	}
 
+	kfree(he_dev->rbpl_virt);
+	kfree(he_dev->rbpl_table);
+
 	if (he_dev->rbpl_pool)
 		pci_pool_destroy(he_dev->rbpl_pool);
 
@@ -1609,13 +1627,13 @@ static struct he_tpd *
 __alloc_tpd(struct he_dev *he_dev)
 {
 	struct he_tpd *tpd;
-	dma_addr_t dma_handle; 
+	dma_addr_t mapping;
 
-	tpd = pci_pool_alloc(he_dev->tpd_pool, GFP_ATOMIC|GFP_DMA, &dma_handle);
+	tpd = pci_pool_alloc(he_dev->tpd_pool, GFP_ATOMIC|GFP_DMA, &mapping);
 	if (tpd == NULL)
 		return NULL;
 			
-	tpd->status = TPD_ADDR(dma_handle);
+	tpd->status = TPD_ADDR(mapping);
 	tpd->reserved = 0; 
 	tpd->iovec[0].addr = 0; tpd->iovec[0].len = 0;
 	tpd->iovec[1].addr = 0; tpd->iovec[1].len = 0;
@@ -1644,13 +1662,12 @@ he_service_rbrq(struct he_dev *he_dev, int group)
 	struct he_rbrq *rbrq_tail = (struct he_rbrq *)
 				((unsigned long)he_dev->rbrq_base |
 					he_dev->hsp->group[group].rbrq_tail);
-	struct he_rbp *rbp = NULL;
 	unsigned cid, lastcid = -1;
-	unsigned buf_len = 0;
 	struct sk_buff *skb;
 	struct atm_vcc *vcc = NULL;
 	struct he_vcc *he_vcc;
-	struct he_iovec *iov;
+	struct he_buff *heb, *next;
+	int i;
 	int pdus_assembled = 0;
 	int updated = 0;
 
@@ -1670,41 +1687,35 @@ he_service_rbrq(struct he_dev *he_dev, int group)
 			RBRQ_CON_CLOSED(he_dev->rbrq_head) ? " CON_CLOSED" : "",
 			RBRQ_HBUF_ERR(he_dev->rbrq_head) ? " HBUF_ERR" : "");
 
-		rbp = &he_dev->rbpl_base[RBP_INDEX(RBRQ_ADDR(he_dev->rbrq_head))];
-		
-		buf_len = RBRQ_BUFLEN(he_dev->rbrq_head) * 4;
-		cid = RBRQ_CID(he_dev->rbrq_head);
+		i = RBRQ_ADDR(he_dev->rbrq_head) >> RBP_IDX_OFFSET;
+		heb = he_dev->rbpl_virt[i];
 
+		cid = RBRQ_CID(he_dev->rbrq_head);
 		if (cid != lastcid)
 			vcc = __find_vcc(he_dev, cid);
 		lastcid = cid;
 
-		if (vcc == NULL) {
-			hprintk("vcc == NULL  (cid 0x%x)\n", cid);
-			if (!RBRQ_HBUF_ERR(he_dev->rbrq_head))
-					rbp->status &= ~RBP_LOANED;
+		if (vcc == NULL || (he_vcc = HE_VCC(vcc)) == NULL) {
+			hprintk("vcc/he_vcc == NULL  (cid 0x%x)\n", cid);
+			if (!RBRQ_HBUF_ERR(he_dev->rbrq_head)) {
+				clear_bit(i, he_dev->rbpl_table);
+				list_del(&heb->entry);
+				pci_pool_free(he_dev->rbpl_pool, heb, heb->mapping);
+			}
 					
 			goto next_rbrq_entry;
 		}
 
-		he_vcc = HE_VCC(vcc);
-		if (he_vcc == NULL) {
-			hprintk("he_vcc == NULL  (cid 0x%x)\n", cid);
-			if (!RBRQ_HBUF_ERR(he_dev->rbrq_head))
-					rbp->status &= ~RBP_LOANED;
-			goto next_rbrq_entry;
-		}
-
 		if (RBRQ_HBUF_ERR(he_dev->rbrq_head)) {
 			hprintk("HBUF_ERR!  (cid 0x%x)\n", cid);
 				atomic_inc(&vcc->stats->rx_drop);
 			goto return_host_buffers;
 		}
 
-		he_vcc->iov_tail->iov_base = RBRQ_ADDR(he_dev->rbrq_head);
-		he_vcc->iov_tail->iov_len = buf_len;
-		he_vcc->pdu_len += buf_len;
-		++he_vcc->iov_tail;
+		heb->len = RBRQ_BUFLEN(he_dev->rbrq_head) * 4;
+		clear_bit(i, he_dev->rbpl_table);
+		list_move_tail(&heb->entry, &he_vcc->buffers);
+		he_vcc->pdu_len += heb->len;
 
 		if (RBRQ_CON_CLOSED(he_dev->rbrq_head)) {
 			lastcid = -1;
@@ -1713,12 +1724,6 @@ he_service_rbrq(struct he_dev *he_dev, int group)
 			goto return_host_buffers;
 		}
 
-#ifdef notdef
-		if ((he_vcc->iov_tail - he_vcc->iov_head) > HE_MAXIOV) {
-			hprintk("iovec full!  cid 0x%x\n", cid);
-			goto return_host_buffers;
-		}
-#endif
 		if (!RBRQ_END_PDU(he_dev->rbrq_head))
 			goto next_rbrq_entry;
 
@@ -1746,9 +1751,8 @@ he_service_rbrq(struct he_dev *he_dev, int group)
 
 		__net_timestamp(skb);
 
-		for (iov = he_vcc->iov_head; iov < he_vcc->iov_tail; ++iov)
-			memcpy(skb_put(skb, iov->iov_len),
-			       he_dev->rbpl_virt[RBP_INDEX(iov->iov_base)].virt, iov->iov_len);
+		list_for_each_entry(heb, &he_vcc->buffers, entry)
+			memcpy(skb_put(skb, heb->len), &heb->data, heb->len);
 
 		switch (vcc->qos.aal) {
 			case ATM_AAL0:
@@ -1788,12 +1792,9 @@ he_service_rbrq(struct he_dev *he_dev, int group)
 return_host_buffers:
 		++pdus_assembled;
 
-		for (iov = he_vcc->iov_head; iov < he_vcc->iov_tail; ++iov) {
-			rbp = &he_dev->rbpl_base[RBP_INDEX(iov->iov_base)];
-			rbp->status &= ~RBP_LOANED;
-		}
-
-		he_vcc->iov_tail = he_vcc->iov_head;
+		list_for_each_entry_safe(heb, next, &he_vcc->buffers, entry)
+			pci_pool_free(he_dev->rbpl_pool, heb, heb->mapping);
+		INIT_LIST_HEAD(&he_vcc->buffers);
 		he_vcc->pdu_len = 0;
 
 next_rbrq_entry:
@@ -1897,23 +1898,43 @@ next_tbrq_entry:
 static void
 he_service_rbpl(struct he_dev *he_dev, int group)
 {
-	struct he_rbp *newtail;
+	struct he_rbp *new_tail;
 	struct he_rbp *rbpl_head;
+	struct he_buff *heb;
+	dma_addr_t mapping;
+	int i;
 	int moved = 0;
 
 	rbpl_head = (struct he_rbp *) ((unsigned long)he_dev->rbpl_base |
 					RBPL_MASK(he_readl(he_dev, G0_RBPL_S)));
 
 	for (;;) {
-		newtail = (struct he_rbp *) ((unsigned long)he_dev->rbpl_base |
+		new_tail = (struct he_rbp *) ((unsigned long)he_dev->rbpl_base |
 						RBPL_MASK(he_dev->rbpl_tail+1));
 
 		/* table 3.42 -- rbpl_tail should never be set to rbpl_head */
-		if ((newtail == rbpl_head) || (newtail->status & RBP_LOANED))
+		if (new_tail == rbpl_head)
 			break;
 
-		newtail->status |= RBP_LOANED;
-		he_dev->rbpl_tail = newtail;
+		i = find_next_zero_bit(he_dev->rbpl_table, RBPL_TABLE_SIZE, he_dev->rbpl_hint);
+		if (i > (RBPL_TABLE_SIZE - 1)) {
+			i = find_first_zero_bit(he_dev->rbpl_table, RBPL_TABLE_SIZE);
+			if (i > (RBPL_TABLE_SIZE - 1))
+				break;
+		}
+		he_dev->rbpl_hint = i + 1;
+
+		heb = pci_pool_alloc(he_dev->rbpl_pool, GFP_ATOMIC|GFP_DMA, &mapping);
+		if (!heb)
+			break;
+		heb->mapping = mapping;
+		list_add(&heb->entry, &he_dev->rbpl_outstanding);
+		he_dev->rbpl_virt[i] = heb;
+		set_bit(i, he_dev->rbpl_table);
+		new_tail->idx = i << RBP_IDX_OFFSET;
+		new_tail->phys = mapping + offsetof(struct he_buff, data);
+
+		he_dev->rbpl_tail = new_tail;
 		++moved;
 	} 
 
@@ -2137,7 +2158,7 @@ he_open(struct atm_vcc *vcc)
 		return -ENOMEM;
 	}
 
-	he_vcc->iov_tail = he_vcc->iov_head;
+	INIT_LIST_HEAD(&he_vcc->buffers);
 	he_vcc->pdu_len = 0;
 	he_vcc->rc_index = -1;
 
diff --git a/drivers/atm/he.h b/drivers/atm/he.h
index 8bf3264..110a27d 100644
--- a/drivers/atm/he.h
+++ b/drivers/atm/he.h
@@ -198,26 +198,33 @@ struct he_hsp {
 	} group[HE_NUM_GROUPS];
 };
 
-/* figure 2.9 receive buffer pools */
+/*
+ * figure 2.9 receive buffer pools
+ *
+ * since a virtual address might be more than 32 bits, we store an index
+ * in the virt member of he_rbp.  NOTE: the lower six bits in the  rbrq
+ * addr member are used for buffer status further limiting us to 26 bits.
+ */
 
 struct he_rbp {
 	volatile u32 phys;
-	volatile u32 status;
+	volatile u32 idx;	/* virt */
 };
 
-/* NOTE: it is suggested that virt be the virtual address of the host
-   buffer.  on a 64-bit machine, this would not work.  Instead, we
-   store the real virtual address in another list, and store an index
-   (and buffer status) in the virt member.
-*/
+#define RBP_IDX_OFFSET 6
+
+/*
+ * the he dma engine will try to hold an extra 16 buffers in its local
+ * caches.  and add a couple buffers for safety.
+ */
 
-#define RBP_INDEX_OFF	6
-#define RBP_INDEX(x)	(((long)(x) >> RBP_INDEX_OFF) & 0xffff)
-#define RBP_LOANED	0x80000000
-#define RBP_SMALLBUF	0x40000000
+#define RBPL_TABLE_SIZE (CONFIG_RBPL_SIZE + 16 + 2)
 
-struct he_virt {
-	void *virt;
+struct he_buff {
+	struct list_head entry;
+	dma_addr_t mapping;
+	unsigned long len;
+	u8 data[];
 };
 
 #ifdef notyet
@@ -286,10 +293,13 @@ struct he_dev {
 	struct he_rbrq *rbrq_base, *rbrq_head;
 	int rbrq_peak;
 
+	struct he_buff **rbpl_virt;
+	unsigned long *rbpl_table;
+	unsigned long rbpl_hint;
 	struct pci_pool *rbpl_pool;
 	dma_addr_t rbpl_phys;
 	struct he_rbp *rbpl_base, *rbpl_tail;
-	struct he_virt *rbpl_virt;
+	struct list_head rbpl_outstanding;
 	int rbpl_peak;
 
 	dma_addr_t tbrq_phys;
@@ -304,20 +314,12 @@ struct he_dev {
 	struct he_dev *next;
 };
 
-struct he_iovec
-{
-	u32 iov_base;
-	u32 iov_len;
-};
-
 #define HE_MAXIOV 20
 
 struct he_vcc
 {
-	struct he_iovec iov_head[HE_MAXIOV];
-	struct he_iovec *iov_tail;
+	struct list_head buffers;
 	int pdu_len;
-
 	int rc_index;
 
 	wait_queue_head_t rx_waitq;
