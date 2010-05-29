From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-next-2.6 2/4] atm: [nicstar] remove virt_to_bus() and support 64-bit platforms
Date: Sat, 29 May 2010 15:04:25 -0400
Message-ID: <201005291904.o4TJ4Pgo005114@thirdoffive.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:58760 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351Ab0E2TPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 15:15:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

Author: chas williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
Date:   Fri May 28 18:48:16 2010 -0400

    atm: [nicstar] remove virt_to_bus() and support 64-bit platforms
    
    Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

diff --git a/drivers/atm/Kconfig b/drivers/atm/Kconfig
index f1a0a00..be7461c 100644
--- a/drivers/atm/Kconfig
+++ b/drivers/atm/Kconfig
@@ -177,7 +177,7 @@ config ATM_ZATM_DEBUG
 
 config ATM_NICSTAR
 	tristate "IDT 77201 (NICStAR) (ForeRunnerLE)"
-	depends on PCI && !64BIT && VIRT_TO_BUS
+	depends on PCI
 	help
 	  The NICStAR chipset family is used in a large number of ATM NICs for
 	  25 and for 155 Mbps, including IDT cards and the Fore ForeRunnerLE
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index a07b6b7..59876c6 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -38,6 +38,7 @@
 #include <linux/atmdev.h>
 #include <linux/atm.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/types.h>
 #include <linux/string.h>
 #include <linux/delay.h>
@@ -47,6 +48,7 @@
 #include <linux/interrupt.h>
 #include <linux/bitops.h>
 #include <linux/slab.h>
+#include <linux/idr.h>
 #include <asm/io.h>
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
@@ -58,10 +60,6 @@
 #include "idt77105.h"
 #endif /* CONFIG_ATM_NICSTAR_USE_IDT77105 */
 
-#if BITS_PER_LONG != 32
-# error FIXME: this driver requires a 32-bit platform
-#endif
-
 /* Additional code */
 
 #include "nicstarmac.c"
@@ -109,17 +107,15 @@
 
 #define NS_DELAY mdelay(1)
 
-#define ALIGN_BUS_ADDR(addr, alignment) \
-        ((((u32) (addr)) + (((u32) (alignment)) - 1)) & ~(((u32) (alignment)) - 1))
-#define ALIGN_ADDRESS(addr, alignment) \
-        bus_to_virt(ALIGN_BUS_ADDR(virt_to_bus(addr), alignment))
-
-#undef CEIL
+#define PTR_DIFF(a, b)	((u32)((unsigned long)(a) - (unsigned long)(b)))
 
 #ifndef ATM_SKB
 #define ATM_SKB(s) (&(s)->atm)
 #endif
 
+#define scq_virt_to_bus(scq, p) \
+		(scq->dma + ((unsigned long)(p) - (unsigned long)(scq)->org))
+
 /* Function declarations */
 
 static u32 ns_read_sram(ns_dev * card, u32 sram_address);
@@ -127,8 +123,8 @@ static void ns_write_sram(ns_dev * card, u32 sram_address, u32 * value,
 			  int count);
 static int __devinit ns_init_card(int i, struct pci_dev *pcidev);
 static void __devinit ns_init_card_error(ns_dev * card, int error);
-static scq_info *get_scq(int size, u32 scd);
-static void free_scq(scq_info * scq, struct atm_vcc *vcc);
+static scq_info *get_scq(ns_dev *card, int size, u32 scd);
+static void free_scq(ns_dev *card, scq_info * scq, struct atm_vcc *vcc);
 static void push_rxbufs(ns_dev *, struct sk_buff *);
 static irqreturn_t ns_irq_handler(int irq, void *dev_id);
 static int ns_open(struct atm_vcc *vcc);
@@ -153,7 +149,9 @@ static void dequeue_sm_buf(ns_dev * card, struct sk_buff *sb);
 static void dequeue_lg_buf(ns_dev * card, struct sk_buff *lb);
 static int ns_proc_read(struct atm_dev *dev, loff_t * pos, char *page);
 static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user * arg);
+#ifdef EXTRA_DEBUG
 static void which_list(ns_dev * card, struct sk_buff *skb);
+#endif
 static void ns_poll(unsigned long arg);
 static int ns_parse_mac(char *mac, unsigned char *esi);
 static short ns_h2i(char c);
@@ -249,13 +247,17 @@ static void __devexit nicstar_remove_one(struct pci_dev *pcidev)
 		dev_kfree_skb_any(lb);
 	while ((sb = skb_dequeue(&card->sbpool.queue)) != NULL)
 		dev_kfree_skb_any(sb);
-	free_scq(card->scq0, NULL);
+	free_scq(card, card->scq0, NULL);
 	for (j = 0; j < NS_FRSCD_NUM; j++) {
 		if (card->scd2vc[j] != NULL)
-			free_scq(card->scd2vc[j]->scq, card->scd2vc[j]->tx_vcc);
-	}
-	kfree(card->rsq.org);
-	kfree(card->tsq.org);
+			free_scq(card, card->scd2vc[j]->scq, card->scd2vc[j]->tx_vcc);
+	}
+	idr_remove_all(&card->idr);
+	idr_destroy(&card->idr);
+	pci_free_consistent(card->pcidev, NS_RSQSIZE + NS_RSQ_ALIGNMENT,
+			    card->rsq.org, card->rsq.dma);
+	pci_free_consistent(card->pcidev, NS_TSQSIZE + NS_TSQ_ALIGNMENT,
+			    card->tsq.org, card->tsq.dma);
 	free_irq(card->pcidev->irq, card);
 	iounmap(card->membase);
 	kfree(card);
@@ -371,6 +373,14 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 		ns_init_card_error(card, error);
 		return error;
 	}
+        if ((pci_set_dma_mask(pcidev, DMA_BIT_MASK(32)) != 0) ||
+	    (pci_set_consistent_dma_mask(pcidev, DMA_BIT_MASK(32)) != 0)) {
+                printk(KERN_WARNING
+		       "nicstar%d: No suitable DMA available.\n", i);
+		error = 2;
+		ns_init_card_error(card, error);
+		return error;
+        }
 
 	if ((card = kmalloc(sizeof(ns_dev), GFP_KERNEL)) == NULL) {
 		printk
@@ -397,7 +407,7 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 		ns_init_card_error(card, error);
 		return error;
 	}
-	PRINTK("nicstar%d: membase at 0x%x.\n", i, card->membase);
+	PRINTK("nicstar%d: membase at 0x%p.\n", i, card->membase);
 
 	pci_set_master(pcidev);
 
@@ -528,54 +538,54 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 	writel(0x00000000, card->membase + VPM);
 
 	/* Initialize TSQ */
-	card->tsq.org = kmalloc(NS_TSQSIZE + NS_TSQ_ALIGNMENT, GFP_KERNEL);
+	card->tsq.org = pci_alloc_consistent(card->pcidev,
+					     NS_TSQSIZE + NS_TSQ_ALIGNMENT,
+					     &card->tsq.dma);
 	if (card->tsq.org == NULL) {
 		printk("nicstar%d: can't allocate TSQ.\n", i);
 		error = 10;
 		ns_init_card_error(card, error);
 		return error;
 	}
-	card->tsq.base =
-	    (ns_tsi *) ALIGN_ADDRESS(card->tsq.org, NS_TSQ_ALIGNMENT);
+	card->tsq.base = PTR_ALIGN(card->tsq.org, NS_TSQ_ALIGNMENT);
 	card->tsq.next = card->tsq.base;
 	card->tsq.last = card->tsq.base + (NS_TSQ_NUM_ENTRIES - 1);
 	for (j = 0; j < NS_TSQ_NUM_ENTRIES; j++)
 		ns_tsi_init(card->tsq.base + j);
 	writel(0x00000000, card->membase + TSQH);
-	writel((u32) virt_to_bus(card->tsq.base), card->membase + TSQB);
-	PRINTK("nicstar%d: TSQ base at 0x%x  0x%x  0x%x.\n", i,
-	       (u32) card->tsq.base, (u32) virt_to_bus(card->tsq.base),
-	       readl(card->membase + TSQB));
+	writel(ALIGN(card->tsq.dma, NS_TSQ_ALIGNMENT), card->membase + TSQB);
+	PRINTK("nicstar%d: TSQ base at 0x%p.\n", i, card->tsq.base);
 
 	/* Initialize RSQ */
-	card->rsq.org = kmalloc(NS_RSQSIZE + NS_RSQ_ALIGNMENT, GFP_KERNEL);
+	card->rsq.org = pci_alloc_consistent(card->pcidev,
+					     NS_RSQSIZE + NS_RSQ_ALIGNMENT,
+					     &card->rsq.dma);
 	if (card->rsq.org == NULL) {
 		printk("nicstar%d: can't allocate RSQ.\n", i);
 		error = 11;
 		ns_init_card_error(card, error);
 		return error;
 	}
-	card->rsq.base =
-	    (ns_rsqe *) ALIGN_ADDRESS(card->rsq.org, NS_RSQ_ALIGNMENT);
+	card->rsq.base = PTR_ALIGN(card->rsq.org, NS_RSQ_ALIGNMENT);
 	card->rsq.next = card->rsq.base;
 	card->rsq.last = card->rsq.base + (NS_RSQ_NUM_ENTRIES - 1);
 	for (j = 0; j < NS_RSQ_NUM_ENTRIES; j++)
 		ns_rsqe_init(card->rsq.base + j);
 	writel(0x00000000, card->membase + RSQH);
-	writel((u32) virt_to_bus(card->rsq.base), card->membase + RSQB);
-	PRINTK("nicstar%d: RSQ base at 0x%x.\n", i, (u32) card->rsq.base);
+	writel(ALIGN(card->rsq.dma, NS_RSQ_ALIGNMENT), card->membase + RSQB);
+	PRINTK("nicstar%d: RSQ base at 0x%p.\n", i, card->rsq.base);
 
 	/* Initialize SCQ0, the only VBR SCQ used */
 	card->scq1 = NULL;
 	card->scq2 = NULL;
-	card->scq0 = get_scq(VBR_SCQSIZE, NS_VRSCD0);
+	card->scq0 = get_scq(card, VBR_SCQSIZE, NS_VRSCD0);
 	if (card->scq0 == NULL) {
 		printk("nicstar%d: can't get SCQ0.\n", i);
 		error = 12;
 		ns_init_card_error(card, error);
 		return error;
 	}
-	u32d[0] = (u32) virt_to_bus(card->scq0->base);
+	u32d[0] = scq_virt_to_bus(card->scq0, card->scq0->base);
 	u32d[1] = (u32) 0x00000000;
 	u32d[2] = (u32) 0xffffffff;
 	u32d[3] = (u32) 0x00000000;
@@ -583,8 +593,7 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 	ns_write_sram(card, NS_VRSCD1, u32d, 4);	/* These last two won't be used */
 	ns_write_sram(card, NS_VRSCD2, u32d, 4);	/* but are initialized, just in case... */
 	card->scq0->scd = NS_VRSCD0;
-	PRINTK("nicstar%d: VBR-SCQ0 base at 0x%x.\n", i,
-	       (u32) card->scq0->base);
+	PRINTK("nicstar%d: VBR-SCQ0 base at 0x%p.\n", i, card->scq0->base);
 
 	/* Initialize TSTs */
 	card->tst_addr = NS_TST0;
@@ -640,6 +649,8 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 
 	card->efbie = 1;	/* To prevent push_rxbufs from enabling the interrupt */
 
+	idr_init(&card->idr);
+
 	/* Pre-allocate some huge buffers */
 	skb_queue_head_init(&card->hbpool.queue);
 	card->hbpool.count = 0;
@@ -654,7 +665,7 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 			ns_init_card_error(card, error);
 			return error;
 		}
-		NS_SKB_CB(hb)->buf_type = BUF_NONE;
+		NS_PRV_BUFTYPE(hb) = BUF_NONE;
 		skb_queue_tail(&card->hbpool.queue, hb);
 		card->hbpool.count++;
 	}
@@ -673,14 +684,15 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 			ns_init_card_error(card, error);
 			return error;
 		}
-		NS_SKB_CB(lb)->buf_type = BUF_LG;
+		NS_PRV_BUFTYPE(lb) = BUF_LG;
 		skb_queue_tail(&card->lbpool.queue, lb);
 		skb_reserve(lb, NS_SMBUFSIZE);
 		push_rxbufs(card, lb);
 		/* Due to the implementation of push_rxbufs() this is 1, not 0 */
 		if (j == 1) {
 			card->rcbuf = lb;
-			card->rawch = (u32) virt_to_bus(lb->data);
+			card->rawcell = (struct ns_rcqe *) lb->data;
+			card->rawch = NS_PRV_DMA(lb);
 		}
 	}
 	/* Test for strange behaviour which leads to crashes */
@@ -708,7 +720,7 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 			ns_init_card_error(card, error);
 			return error;
 		}
-		NS_SKB_CB(sb)->buf_type = BUF_SM;
+		NS_PRV_BUFTYPE(sb) = BUF_SM;
 		skb_queue_tail(&card->sbpool.queue, sb);
 		skb_reserve(sb, NS_AAL0_HEADER);
 		push_rxbufs(card, sb);
@@ -738,7 +750,7 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
 			ns_init_card_error(card, error);
 			return error;
 		}
-		NS_SKB_CB(iovb)->buf_type = BUF_NONE;
+		NS_PRV_BUFTYPE(iovb) = BUF_NONE;
 		skb_queue_tail(&card->iovpool.queue, iovb);
 		card->iovpool.count++;
 	}
@@ -825,7 +837,7 @@ static void __devinit ns_init_card_error(ns_dev * card, int error)
 		struct sk_buff *sb;
 		while ((sb = skb_dequeue(&card->sbpool.queue)) != NULL)
 			dev_kfree_skb_any(sb);
-		free_scq(card->scq0, NULL);
+		free_scq(card, card->scq0, NULL);
 	}
 	if (error >= 14) {
 		struct sk_buff *lb;
@@ -855,7 +867,7 @@ static void __devinit ns_init_card_error(ns_dev * card, int error)
 	}
 }
 
-static scq_info *get_scq(int size, u32 scd)
+static scq_info *get_scq(ns_dev *card, int size, u32 scd)
 {
 	scq_info *scq;
 	int i;
@@ -864,22 +876,22 @@ static scq_info *get_scq(int size, u32 scd)
 		return NULL;
 
 	scq = kmalloc(sizeof(scq_info), GFP_KERNEL);
-	if (scq == NULL)
+	if (!scq)
 		return NULL;
-	scq->org = kmalloc(2 * size, GFP_KERNEL);
-	if (scq->org == NULL) {
+        scq->org = pci_alloc_consistent(card->pcidev, 2 * size, &scq->dma);
+	if (!scq->org) {
 		kfree(scq);
 		return NULL;
 	}
 	scq->skb = kmalloc(sizeof(struct sk_buff *) *
 			   (size / NS_SCQE_SIZE), GFP_KERNEL);
-	if (scq->skb == NULL) {
+	if (!scq->skb) {
 		kfree(scq->org);
 		kfree(scq);
 		return NULL;
 	}
 	scq->num_entries = size / NS_SCQE_SIZE;
-	scq->base = (ns_scqe *) ALIGN_ADDRESS(scq->org, size);
+	scq->base = PTR_ALIGN(scq->org, size);
 	scq->next = scq->base;
 	scq->last = scq->base + (scq->num_entries - 1);
 	scq->tail = scq->last;
@@ -897,7 +909,7 @@ static scq_info *get_scq(int size, u32 scd)
 }
 
 /* For variable rate SCQ vcc must be NULL */
-static void free_scq(scq_info * scq, struct atm_vcc *vcc)
+static void free_scq(ns_dev *card, scq_info *scq, struct atm_vcc *vcc)
 {
 	int i;
 
@@ -928,7 +940,10 @@ static void free_scq(scq_info * scq, struct atm_vcc *vcc)
 			}
 	}
 	kfree(scq->skb);
-	kfree(scq->org);
+	pci_free_consistent(card->pcidev,
+			    2 * (scq->num_entries == VBR_SCQ_NUM_ENTRIES ?
+				 VBR_SCQSIZE : CBR_SCQSIZE),
+			    scq->org, scq->dma);
 	kfree(scq);
 }
 
@@ -936,16 +951,23 @@ static void free_scq(scq_info * scq, struct atm_vcc *vcc)
    or large buffer(s) cast to u32. */
 static void push_rxbufs(ns_dev * card, struct sk_buff *skb)
 {
-	struct ns_skb_cb *cb = NS_SKB_CB(skb);
-	u32 handle1, addr1;
-	u32 handle2, addr2;
+	struct sk_buff *handle1, *handle2;
+	u32 id1 = 0, id2 = 0;
+	u32 addr1, addr2;
 	u32 stat;
 	unsigned long flags;
+	int err;
 
 	/* *BARF* */
-	handle2 = addr2 = 0;
-	handle1 = (u32) skb;
-	addr1 = (u32) virt_to_bus(skb->data);
+	handle2 = NULL;
+	addr2 = 0;
+	handle1 = skb;
+	addr1 = pci_map_single(card->pcidev,
+			       skb->data,
+			       (NS_PRV_BUFTYPE(skb) == BUF_SM
+				? NS_SMSKBSIZE : NS_LGSKBSIZE),
+			       PCI_DMA_TODEVICE);
+	NS_PRV_DMA(skb) = addr1; /* save so we can unmap later */
 
 #ifdef GENERAL_DEBUG
 	if (!addr1)
@@ -956,7 +978,7 @@ static void push_rxbufs(ns_dev * card, struct sk_buff *skb)
 	stat = readl(card->membase + STAT);
 	card->sbfqc = ns_stat_sfbqc_get(stat);
 	card->lbfqc = ns_stat_lfbqc_get(stat);
-	if (cb->buf_type == BUF_SM) {
+	if (NS_PRV_BUFTYPE(skb) == BUF_SM) {
 		if (!addr2) {
 			if (card->sm_addr) {
 				addr2 = card->sm_addr;
@@ -986,47 +1008,60 @@ static void push_rxbufs(ns_dev * card, struct sk_buff *skb)
 	}
 
 	if (addr2) {
-		if (cb->buf_type == BUF_SM) {
+		if (NS_PRV_BUFTYPE(skb) == BUF_SM) {
 			if (card->sbfqc >= card->sbnr.max) {
-				skb_unlink((struct sk_buff *)handle1,
-					   &card->sbpool.queue);
-				dev_kfree_skb_any((struct sk_buff *)handle1);
-				skb_unlink((struct sk_buff *)handle2,
-					   &card->sbpool.queue);
-				dev_kfree_skb_any((struct sk_buff *)handle2);
+				skb_unlink(handle1, &card->sbpool.queue);
+				dev_kfree_skb_any(handle1);
+				skb_unlink(handle2, &card->sbpool.queue);
+				dev_kfree_skb_any(handle2);
 				return;
 			} else
 				card->sbfqc += 2;
 		} else {	/* (buf_type == BUF_LG) */
 
 			if (card->lbfqc >= card->lbnr.max) {
-				skb_unlink((struct sk_buff *)handle1,
-					   &card->lbpool.queue);
-				dev_kfree_skb_any((struct sk_buff *)handle1);
-				skb_unlink((struct sk_buff *)handle2,
-					   &card->lbpool.queue);
-				dev_kfree_skb_any((struct sk_buff *)handle2);
+				skb_unlink(handle1, &card->lbpool.queue);
+				dev_kfree_skb_any(handle1);
+				skb_unlink(handle2, &card->lbpool.queue);
+				dev_kfree_skb_any(handle2);
 				return;
 			} else
 				card->lbfqc += 2;
 		}
 
-		spin_lock_irqsave(&card->res_lock, flags);
+		do {
+			if (!idr_pre_get(&card->idr, GFP_ATOMIC)) {
+				printk(KERN_ERR
+				       "nicstar%d: no free memory for idr\n",
+				       card->index);
+				goto out;
+			}
+
+			if (!id1)
+				err = idr_get_new_above(&card->idr, handle1, 0, &id1);
+
+			if (!id2 && err == 0)
+				err = idr_get_new_above(&card->idr, handle2, 0, &id2);
+
+		} while (err == -EAGAIN);
 
+		if (err)
+			goto out;
+
+		spin_lock_irqsave(&card->res_lock, flags);
 		while (CMD_BUSY(card)) ;
 		writel(addr2, card->membase + DR3);
-		writel(handle2, card->membase + DR2);
+		writel(id2, card->membase + DR2);
 		writel(addr1, card->membase + DR1);
-		writel(handle1, card->membase + DR0);
-		writel(NS_CMD_WRITE_FREEBUFQ | cb->buf_type,
+		writel(id1, card->membase + DR0);
+		writel(NS_CMD_WRITE_FREEBUFQ | NS_PRV_BUFTYPE(skb),
 		       card->membase + CMD);
-
 		spin_unlock_irqrestore(&card->res_lock, flags);
 
 		XPRINTK("nicstar%d: Pushing %s buffers at 0x%x and 0x%x.\n",
 			card->index,
-			(cb->buf_type == BUF_SM ? "small" : "large"), addr1,
-			addr2);
+			(NS_PRV_BUFTYPE(skb) == BUF_SM ? "small" : "large"),
+			addr1, addr2);
 	}
 
 	if (!card->efbie && card->sbfqc >= card->sbnr.min &&
@@ -1036,6 +1071,7 @@ static void push_rxbufs(ns_dev * card, struct sk_buff *skb)
 		       card->membase + CFG);
 	}
 
+out:
 	return;
 }
 
@@ -1131,21 +1167,21 @@ static irqreturn_t ns_irq_handler(int irq, void *dev_id)
 		   next interrupt. As this preliminary support is only meant to
 		   avoid buffer leakage, this is not an issue. */
 		while (readl(card->membase + RAWCT) != card->rawch) {
-			ns_rcqe *rawcell;
 
-			rawcell = (ns_rcqe *) bus_to_virt(card->rawch);
-			if (ns_rcqe_islast(rawcell)) {
+			if (ns_rcqe_islast(card->rawcell)) {
 				struct sk_buff *oldbuf;
 
 				oldbuf = card->rcbuf;
-				card->rcbuf =
-				    (struct sk_buff *)
-				    ns_rcqe_nextbufhandle(rawcell);
-				card->rawch =
-				    (u32) virt_to_bus(card->rcbuf->data);
+				card->rcbuf = idr_find(&card->idr,
+						       ns_rcqe_nextbufhandle(card->rawcell));
+				card->rawch = NS_PRV_DMA(card->rcbuf);
+				card->rawcell = (struct ns_rcqe *)
+						card->rcbuf->data;
 				recycle_rx_buf(card, oldbuf);
-			} else
+			} else {
 				card->rawch += NS_RCQE_SIZE;
+				card->rawcell++;
+			}
 		}
 	}
 
@@ -1165,7 +1201,7 @@ static irqreturn_t ns_irq_handler(int irq, void *dev_id)
 				card->efbie = 0;
 				break;
 			}
-			NS_SKB_CB(sb)->buf_type = BUF_SM;
+			NS_PRV_BUFTYPE(sb) = BUF_SM;
 			skb_queue_tail(&card->sbpool.queue, sb);
 			skb_reserve(sb, NS_AAL0_HEADER);
 			push_rxbufs(card, sb);
@@ -1190,7 +1226,7 @@ static irqreturn_t ns_irq_handler(int irq, void *dev_id)
 				card->efbie = 0;
 				break;
 			}
-			NS_SKB_CB(lb)->buf_type = BUF_LG;
+			NS_PRV_BUFTYPE(lb) = BUF_LG;
 			skb_queue_tail(&card->lbpool.queue, lb);
 			skb_reserve(lb, NS_SMBUFSIZE);
 			push_rxbufs(card, lb);
@@ -1338,7 +1374,7 @@ static int ns_open(struct atm_vcc *vcc)
 
 			vc->cbr_scd = NS_FRSCD + frscdi * NS_FRSCD_SIZE;
 
-			scq = get_scq(CBR_SCQSIZE, vc->cbr_scd);
+			scq = get_scq(card, CBR_SCQSIZE, vc->cbr_scd);
 			if (scq == NULL) {
 				PRINTK("nicstar%d: can't get fixed rate SCQ.\n",
 				       card->index);
@@ -1349,7 +1385,7 @@ static int ns_open(struct atm_vcc *vcc)
 				return -ENOMEM;
 			}
 			vc->scq = scq;
-			u32d[0] = (u32) virt_to_bus(scq->base);
+			u32d[0] = scq_virt_to_bus(scq, scq->base);
 			u32d[1] = (u32) 0x00000000;
 			u32d[2] = (u32) 0xffffffff;
 			u32d[3] = (u32) 0x00000000;
@@ -1434,9 +1470,8 @@ static void ns_close(struct atm_vcc *vcc)
 			     card->index);
 			iovb = vc->rx_iov;
 			recycle_iovec_rx_bufs(card, (struct iovec *)iovb->data,
-					      NS_SKB(iovb)->iovcnt);
-			NS_SKB(iovb)->iovcnt = 0;
-			NS_SKB(iovb)->vcc = NULL;
+					      NS_PRV_IOVCNT(iovb));
+			NS_PRV_IOVCNT(iovb) = 0;
 			spin_lock_irqsave(&card->int_lock, flags);
 			recycle_iov_buf(card, iovb);
 			spin_unlock_irqrestore(&card->int_lock, flags);
@@ -1487,7 +1522,7 @@ static void ns_close(struct atm_vcc *vcc)
 					scq->next = scq->base;
 				else
 					scq->next++;
-				data = (u32) virt_to_bus(scq->next);
+				data = scq_virt_to_bus(scq, scq->next);
 				ns_write_sram(card, scq->scd, &data, 1);
 			}
 			spin_unlock_irqrestore(&scq->lock, flags);
@@ -1506,7 +1541,7 @@ static void ns_close(struct atm_vcc *vcc)
 		}
 
 		card->scd2vc[(vc->cbr_scd - NS_FRSCD) / NS_FRSCD_SIZE] = NULL;
-		free_scq(vc->scq, vcc);
+		free_scq(card, vc->scq, vcc);
 	}
 
 	/* remove all references to vcc before deleting it */
@@ -1539,13 +1574,13 @@ static void ns_close(struct atm_vcc *vcc)
 		cfg = readl(card->membase + CFG);
 		printk("STAT = 0x%08X  CFG = 0x%08X  \n", stat, cfg);
 		printk
-		    ("TSQ: base = 0x%08X  next = 0x%08X  last = 0x%08X  TSQT = 0x%08X \n",
-		     (u32) card->tsq.base, (u32) card->tsq.next,
-		     (u32) card->tsq.last, readl(card->membase + TSQT));
+		    ("TSQ: base = 0x%p  next = 0x%p  last = 0x%p  TSQT = 0x%08X \n",
+		     card->tsq.base, card->tsq.next,
+		     card->tsq.last, readl(card->membase + TSQT));
 		printk
-		    ("RSQ: base = 0x%08X  next = 0x%08X  last = 0x%08X  RSQT = 0x%08X \n",
-		     (u32) card->rsq.base, (u32) card->rsq.next,
-		     (u32) card->rsq.last, readl(card->membase + RSQT));
+		    ("RSQ: base = 0x%p  next = 0x%p  last = 0x%p  RSQT = 0x%08X \n",
+		     card->rsq.base, card->rsq.next,
+		     card->rsq.last, readl(card->membase + RSQT));
 		printk("Empty free buffer queue interrupt %s \n",
 		       card->efbie ? "enabled" : "disabled");
 		printk("SBCNT = %d  count = %d   LBCNT = %d count = %d \n",
@@ -1651,11 +1686,14 @@ static int ns_send(struct atm_vcc *vcc, struct sk_buff *skb)
 
 	ATM_SKB(skb)->vcc = vcc;
 
+	NS_PRV_DMA(skb) = pci_map_single(card->pcidev, skb->data,
+					 skb->len, PCI_DMA_TODEVICE);
+
 	if (vcc->qos.aal == ATM_AAL5) {
 		buflen = (skb->len + 47 + 8) / 48 * 48;	/* Multiple of 48 */
 		flags = NS_TBD_AAL5;
-		scqe.word_2 = cpu_to_le32((u32) virt_to_bus(skb->data));
-		scqe.word_3 = cpu_to_le32((u32) skb->len);
+		scqe.word_2 = cpu_to_le32(NS_PRV_DMA(skb));
+		scqe.word_3 = cpu_to_le32(skb->len);
 		scqe.word_4 =
 		    ns_tbd_mkword_4(0, (u32) vcc->vpi, (u32) vcc->vci, 0,
 				    ATM_SKB(skb)->
@@ -1665,8 +1703,7 @@ static int ns_send(struct atm_vcc *vcc, struct sk_buff *skb)
 
 		buflen = ATM_CELL_PAYLOAD;	/* i.e., 48 bytes */
 		flags = NS_TBD_AAL0;
-		scqe.word_2 =
-		    cpu_to_le32((u32) virt_to_bus(skb->data) + NS_AAL0_HEADER);
+		scqe.word_2 = cpu_to_le32(NS_PRV_DMA(skb) + NS_AAL0_HEADER);
 		scqe.word_3 = cpu_to_le32(0x00000000);
 		if (*skb->data & 0x02)	/* Payload type 1 - end of pdu */
 			flags |= NS_TBD_EOPDU;
@@ -1733,12 +1770,12 @@ static int push_scqe(ns_dev * card, vc_map * vc, scq_info * scq, ns_scqe * tbd,
 	*scq->next = *tbd;
 	index = (int)(scq->next - scq->base);
 	scq->skb[index] = skb;
-	XPRINTK("nicstar%d: sending skb at 0x%x (pos %d).\n",
-		card->index, (u32) skb, index);
-	XPRINTK("nicstar%d: TBD written:\n0x%x\n0x%x\n0x%x\n0x%x\n at 0x%x.\n",
+	XPRINTK("nicstar%d: sending skb at 0x%p (pos %d).\n",
+		card->index, skb, index);
+	XPRINTK("nicstar%d: TBD written:\n0x%x\n0x%x\n0x%x\n0x%x\n at 0x%p.\n",
 		card->index, le32_to_cpu(tbd->word_1), le32_to_cpu(tbd->word_2),
 		le32_to_cpu(tbd->word_3), le32_to_cpu(tbd->word_4),
-		(u32) scq->next);
+		scq->next);
 	if (scq->next == scq->last)
 		scq->next = scq->base;
 	else
@@ -1757,7 +1794,7 @@ static int push_scqe(ns_dev * card, vc_map * vc, scq_info * scq, ns_scqe * tbd,
 
 		while (scq->tail == scq->next) {
 			if (in_interrupt()) {
-				data = (u32) virt_to_bus(scq->next);
+				data = scq_virt_to_bus(scq, scq->next);
 				ns_write_sram(card, scq->scd, &data, 1);
 				spin_unlock_irqrestore(&scq->lock, flags);
 				printk("nicstar%d: Error pushing TSR.\n",
@@ -1789,10 +1826,10 @@ static int push_scqe(ns_dev * card, vc_map * vc, scq_info * scq, ns_scqe * tbd,
 			index = (int)scqi;
 			scq->skb[index] = NULL;
 			XPRINTK
-			    ("nicstar%d: TSR written:\n0x%x\n0x%x\n0x%x\n0x%x\n at 0x%x.\n",
+			    ("nicstar%d: TSR written:\n0x%x\n0x%x\n0x%x\n0x%x\n at 0x%p.\n",
 			     card->index, le32_to_cpu(tsr.word_1),
 			     le32_to_cpu(tsr.word_2), le32_to_cpu(tsr.word_3),
-			     le32_to_cpu(tsr.word_4), (u32) scq->next);
+			     le32_to_cpu(tsr.word_4), scq->next);
 			if (scq->next == scq->last)
 				scq->next = scq->base;
 			else
@@ -1803,7 +1840,7 @@ static int push_scqe(ns_dev * card, vc_map * vc, scq_info * scq, ns_scqe * tbd,
 			PRINTK("nicstar%d: Timeout pushing TSR.\n",
 			       card->index);
 	}
-	data = (u32) virt_to_bus(scq->next);
+	data = scq_virt_to_bus(scq, scq->next);
 	ns_write_sram(card, scq->scd, &data, 1);
 
 	spin_unlock_irqrestore(&scq->lock, flags);
@@ -1881,10 +1918,9 @@ static void process_tsq(ns_dev * card)
 			two_ahead = one_ahead + 1;
 	}
 
-	if (serviced_entries) {
-		writel((((u32) previous) - ((u32) card->tsq.base)),
+	if (serviced_entries)
+		writel(PTR_DIFF(previous, card->tsq.base),
 		       card->membase + TSQH);
-	}
 }
 
 static void drain_scq(ns_dev * card, scq_info * scq, int pos)
@@ -1894,8 +1930,8 @@ static void drain_scq(ns_dev * card, scq_info * scq, int pos)
 	int i;
 	unsigned long flags;
 
-	XPRINTK("nicstar%d: drain_scq() called, scq at 0x%x, pos %d.\n",
-		card->index, (u32) scq, pos);
+	XPRINTK("nicstar%d: drain_scq() called, scq at 0x%p, pos %d.\n",
+		card->index, scq, pos);
 	if (pos >= scq->num_entries) {
 		printk("nicstar%d: Bad index on drain_scq().\n", card->index);
 		return;
@@ -1907,9 +1943,13 @@ static void drain_scq(ns_dev * card, scq_info * scq, int pos)
 		i = 0;
 	while (i != pos) {
 		skb = scq->skb[i];
-		XPRINTK("nicstar%d: freeing skb at 0x%x (index %d).\n",
-			card->index, (u32) skb, i);
+		XPRINTK("nicstar%d: freeing skb at 0x%p (index %d).\n",
+			card->index, skb, i);
 		if (skb != NULL) {
+			pci_unmap_single(card->pcidev,
+					 NS_PRV_DMA(skb),
+					 skb->len,
+					 PCI_DMA_TODEVICE);
 			vcc = ATM_SKB(skb)->vcc;
 			if (vcc && vcc->pop != NULL) {
 				vcc->pop(vcc, skb);
@@ -1940,8 +1980,7 @@ static void process_rsq(ns_dev * card)
 		else
 			card->rsq.next++;
 	} while (ns_rsqe_valid(card->rsq.next));
-	writel((((u32) previous) - ((u32) card->rsq.base)),
-	       card->membase + RSQH);
+	writel(PTR_DIFF(previous, card->rsq.base), card->membase + RSQH);
 }
 
 static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
@@ -1955,12 +1994,30 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 	unsigned short aal5_len;
 	int len;
 	u32 stat;
+	u32 id;
 
 	stat = readl(card->membase + STAT);
 	card->sbfqc = ns_stat_sfbqc_get(stat);
 	card->lbfqc = ns_stat_lfbqc_get(stat);
 
-	skb = (struct sk_buff *)le32_to_cpu(rsqe->buffer_handle);
+	id = le32_to_cpu(rsqe->buffer_handle);
+	skb = idr_find(&card->idr, id);
+	if (!skb) {
+		RXPRINTK(KERN_ERR
+			 "nicstar%d: idr_find() failed!\n", card->index);
+		return;
+	}
+	idr_remove(&card->idr, id);
+        pci_dma_sync_single_for_cpu(card->pcidev,
+				    NS_PRV_DMA(skb),
+				    (NS_PRV_BUFTYPE(skb) == BUF_SM
+				     ? NS_SMSKBSIZE : NS_LGSKBSIZE),
+				    PCI_DMA_FROMDEVICE);
+	pci_unmap_single(card->pcidev,
+			 NS_PRV_DMA(skb),
+			 (NS_PRV_BUFTYPE(skb) == BUF_SM
+			  ? NS_SMSKBSIZE : NS_LGSKBSIZE),
+			 PCI_DMA_FROMDEVICE);
 	vpi = ns_rsqe_vpi(rsqe);
 	vci = ns_rsqe_vci(rsqe);
 	if (vpi >= 1UL << card->vpibits || vci >= 1UL << card->vcibits) {
@@ -2034,43 +2091,42 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 				recycle_rx_buf(card, skb);
 				return;
 			}
-			NS_SKB_CB(iovb)->buf_type = BUF_NONE;
+			NS_PRV_BUFTYPE(iovb) = BUF_NONE;
 		} else if (--card->iovpool.count < card->iovnr.min) {
 			struct sk_buff *new_iovb;
 			if ((new_iovb =
 			     alloc_skb(NS_IOVBUFSIZE, GFP_ATOMIC)) != NULL) {
-				NS_SKB_CB(iovb)->buf_type = BUF_NONE;
+				NS_PRV_BUFTYPE(iovb) = BUF_NONE;
 				skb_queue_tail(&card->iovpool.queue, new_iovb);
 				card->iovpool.count++;
 			}
 		}
 		vc->rx_iov = iovb;
-		NS_SKB(iovb)->iovcnt = 0;
+		NS_PRV_IOVCNT(iovb) = 0;
 		iovb->len = 0;
 		iovb->data = iovb->head;
 		skb_reset_tail_pointer(iovb);
-		NS_SKB(iovb)->vcc = vcc;
 		/* IMPORTANT: a pointer to the sk_buff containing the small or large
 		   buffer is stored as iovec base, NOT a pointer to the
 		   small or large buffer itself. */
-	} else if (NS_SKB(iovb)->iovcnt >= NS_MAX_IOVECS) {
+	} else if (NS_PRV_IOVCNT(iovb) >= NS_MAX_IOVECS) {
 		printk("nicstar%d: received too big AAL5 SDU.\n", card->index);
 		atomic_inc(&vcc->stats->rx_err);
 		recycle_iovec_rx_bufs(card, (struct iovec *)iovb->data,
 				      NS_MAX_IOVECS);
-		NS_SKB(iovb)->iovcnt = 0;
+		NS_PRV_IOVCNT(iovb) = 0;
 		iovb->len = 0;
 		iovb->data = iovb->head;
 		skb_reset_tail_pointer(iovb);
-		NS_SKB(iovb)->vcc = vcc;
 	}
-	iov = &((struct iovec *)iovb->data)[NS_SKB(iovb)->iovcnt++];
+	iov = &((struct iovec *)iovb->data)[NS_PRV_IOVCNT(iovb)++];
 	iov->iov_base = (void *)skb;
 	iov->iov_len = ns_rsqe_cellcount(rsqe) * 48;
 	iovb->len += iov->iov_len;
 
-	if (NS_SKB(iovb)->iovcnt == 1) {
-		if (NS_SKB_CB(skb)->buf_type != BUF_SM) {
+#ifdef EXTRA_DEBUG
+	if (NS_PRV_IOVCNT(iovb) == 1) {
+		if (NS_PRV_BUFTYPE(skb) != BUF_SM) {
 			printk
 			    ("nicstar%d: Expected a small buffer, and this is not one.\n",
 			     card->index);
@@ -2081,26 +2137,27 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 			recycle_iov_buf(card, iovb);
 			return;
 		}
-	} else {		/* NS_SKB(iovb)->iovcnt >= 2 */
+	} else {		/* NS_PRV_IOVCNT(iovb) >= 2 */
 
-		if (NS_SKB_CB(skb)->buf_type != BUF_LG) {
+		if (NS_PRV_BUFTYPE(skb) != BUF_LG) {
 			printk
 			    ("nicstar%d: Expected a large buffer, and this is not one.\n",
 			     card->index);
 			which_list(card, skb);
 			atomic_inc(&vcc->stats->rx_err);
 			recycle_iovec_rx_bufs(card, (struct iovec *)iovb->data,
-					      NS_SKB(iovb)->iovcnt);
+					      NS_PRV_IOVCNT(iovb));
 			vc->rx_iov = NULL;
 			recycle_iov_buf(card, iovb);
 			return;
 		}
 	}
+#endif /* EXTRA_DEBUG */
 
 	if (ns_rsqe_eopdu(rsqe)) {
 		/* This works correctly regardless of the endianness of the host */
-		unsigned char *L1L2 = (unsigned char *)((u32) skb->data +
-							iov->iov_len - 6);
+		unsigned char *L1L2 = (unsigned char *)
+						(skb->data + iov->iov_len - 6);
 		aal5_len = L1L2[0] << 8 | L1L2[1];
 		len = (aal5_len == 0x0000) ? 0x10000 : aal5_len;
 		if (ns_rsqe_crcerr(rsqe) ||
@@ -2112,7 +2169,7 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 				printk(".\n");
 			atomic_inc(&vcc->stats->rx_err);
 			recycle_iovec_rx_bufs(card, (struct iovec *)iovb->data,
-					      NS_SKB(iovb)->iovcnt);
+					      NS_PRV_IOVCNT(iovb));
 			vc->rx_iov = NULL;
 			recycle_iov_buf(card, iovb);
 			return;
@@ -2120,7 +2177,7 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 
 		/* By this point we (hopefully) have a complete SDU without errors. */
 
-		if (NS_SKB(iovb)->iovcnt == 1) {	/* Just a small buffer */
+		if (NS_PRV_IOVCNT(iovb) == 1) {	/* Just a small buffer */
 			/* skb points to a small buffer */
 			if (!atm_charge(vcc, skb->truesize)) {
 				push_rxbufs(card, skb);
@@ -2136,7 +2193,7 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 				vcc->push(vcc, skb);
 				atomic_inc(&vcc->stats->rx);
 			}
-		} else if (NS_SKB(iovb)->iovcnt == 2) {	/* One small plus one large buffer */
+		} else if (NS_PRV_IOVCNT(iovb) == 2) {	/* One small plus one large buffer */
 			struct sk_buff *sb;
 
 			sb = (struct sk_buff *)(iov - 1)->iov_base;
@@ -2202,8 +2259,7 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 					recycle_iovec_rx_bufs(card,
 							      (struct iovec *)
 							      iovb->data,
-							      NS_SKB(iovb)->
-							      iovcnt);
+							      NS_PRV_IOVCNT(iovb));
 					vc->rx_iov = NULL;
 					recycle_iov_buf(card, iovb);
 					return;
@@ -2217,12 +2273,12 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 						card->hbpool.count++;
 					}
 				}
-				NS_SKB_CB(hb)->buf_type = BUF_NONE;
+				NS_PRV_BUFTYPE(hb) = BUF_NONE;
 			} else if (--card->hbpool.count < card->hbnr.min) {
 				struct sk_buff *new_hb;
 				if ((new_hb =
 				     dev_alloc_skb(NS_HBUFSIZE)) != NULL) {
-					NS_SKB_CB(new_hb)->buf_type = BUF_NONE;
+					NS_PRV_BUFTYPE(new_hb) = BUF_NONE;
 					skb_queue_tail(&card->hbpool.queue,
 						       new_hb);
 					card->hbpool.count++;
@@ -2231,7 +2287,7 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 					if ((new_hb =
 					     dev_alloc_skb(NS_HBUFSIZE)) !=
 					    NULL) {
-						NS_SKB_CB(new_hb)->buf_type =
+						NS_PRV_BUFTYPE(new_hb) =
 						    BUF_NONE;
 						skb_queue_tail(&card->hbpool.
 							       queue, new_hb);
@@ -2244,7 +2300,7 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 
 			if (!atm_charge(vcc, hb->truesize)) {
 				recycle_iovec_rx_bufs(card, iov,
-						      NS_SKB(iovb)->iovcnt);
+						      NS_PRV_IOVCNT(iovb));
 				if (card->hbpool.count < card->hbnr.max) {
 					skb_queue_tail(&card->hbpool.queue, hb);
 					card->hbpool.count++;
@@ -2263,7 +2319,7 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 				push_rxbufs(card, sb);
 
 				/* Copy all large buffers to the huge buffer and free them */
-				for (j = 1; j < NS_SKB(iovb)->iovcnt; j++) {
+				for (j = 1; j < NS_PRV_IOVCNT(iovb); j++) {
 					lb = (struct sk_buff *)iov->iov_base;
 					tocopy =
 					    min_t(int, remaining, iov->iov_len);
@@ -2313,7 +2369,7 @@ static void ns_sb_destructor(struct sk_buff *sb)
 		sb = __dev_alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
 		if (sb == NULL)
 			break;
-		NS_SKB_CB(sb)->buf_type = BUF_SM;
+		NS_PRV_BUFTYPE(sb) = BUF_SM;
 		skb_queue_tail(&card->sbpool.queue, sb);
 		skb_reserve(sb, NS_AAL0_HEADER);
 		push_rxbufs(card, sb);
@@ -2334,7 +2390,7 @@ static void ns_lb_destructor(struct sk_buff *lb)
 		lb = __dev_alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
 		if (lb == NULL)
 			break;
-		NS_SKB_CB(lb)->buf_type = BUF_LG;
+		NS_PRV_BUFTYPE(lb) = BUF_LG;
 		skb_queue_tail(&card->lbpool.queue, lb);
 		skb_reserve(lb, NS_SMBUFSIZE);
 		push_rxbufs(card, lb);
@@ -2351,7 +2407,7 @@ static void ns_hb_destructor(struct sk_buff *hb)
 		hb = __dev_alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
 		if (hb == NULL)
 			break;
-		NS_SKB_CB(hb)->buf_type = BUF_NONE;
+		NS_PRV_BUFTYPE(hb) = BUF_NONE;
 		skb_queue_tail(&card->hbpool.queue, hb);
 		card->hbpool.count++;
 	}
@@ -2361,9 +2417,7 @@ static void ns_hb_destructor(struct sk_buff *hb)
 
 static void recycle_rx_buf(ns_dev * card, struct sk_buff *skb)
 {
-	struct ns_skb_cb *cb = NS_SKB_CB(skb);
-
-	if (unlikely(cb->buf_type == BUF_NONE)) {
+	if (unlikely(NS_PRV_BUFTYPE(skb) == BUF_NONE)) {
 		printk("nicstar%d: What kind of rx buffer is this?\n",
 		       card->index);
 		dev_kfree_skb_any(skb);
@@ -2395,7 +2449,7 @@ static void dequeue_sm_buf(ns_dev * card, struct sk_buff *sb)
 	if (card->sbfqc < card->sbnr.init) {
 		struct sk_buff *new_sb;
 		if ((new_sb = dev_alloc_skb(NS_SMSKBSIZE)) != NULL) {
-			NS_SKB_CB(new_sb)->buf_type = BUF_SM;
+			NS_PRV_BUFTYPE(new_sb) = BUF_SM;
 			skb_queue_tail(&card->sbpool.queue, new_sb);
 			skb_reserve(new_sb, NS_AAL0_HEADER);
 			push_rxbufs(card, new_sb);
@@ -2406,7 +2460,7 @@ static void dequeue_sm_buf(ns_dev * card, struct sk_buff *sb)
 	{
 		struct sk_buff *new_sb;
 		if ((new_sb = dev_alloc_skb(NS_SMSKBSIZE)) != NULL) {
-			NS_SKB_CB(new_sb)->buf_type = BUF_SM;
+			NS_PRV_BUFTYPE(new_sb) = BUF_SM;
 			skb_queue_tail(&card->sbpool.queue, new_sb);
 			skb_reserve(new_sb, NS_AAL0_HEADER);
 			push_rxbufs(card, new_sb);
@@ -2423,7 +2477,7 @@ static void dequeue_lg_buf(ns_dev * card, struct sk_buff *lb)
 	if (card->lbfqc < card->lbnr.init) {
 		struct sk_buff *new_lb;
 		if ((new_lb = dev_alloc_skb(NS_LGSKBSIZE)) != NULL) {
-			NS_SKB_CB(new_lb)->buf_type = BUF_LG;
+			NS_PRV_BUFTYPE(new_lb) = BUF_LG;
 			skb_queue_tail(&card->lbpool.queue, new_lb);
 			skb_reserve(new_lb, NS_SMBUFSIZE);
 			push_rxbufs(card, new_lb);
@@ -2434,7 +2488,7 @@ static void dequeue_lg_buf(ns_dev * card, struct sk_buff *lb)
 	{
 		struct sk_buff *new_lb;
 		if ((new_lb = dev_alloc_skb(NS_LGSKBSIZE)) != NULL) {
-			NS_SKB_CB(new_lb)->buf_type = BUF_LG;
+			NS_PRV_BUFTYPE(new_lb) = BUF_LG;
 			skb_queue_tail(&card->lbpool.queue, new_lb);
 			skb_reserve(new_lb, NS_SMBUFSIZE);
 			push_rxbufs(card, new_lb);
@@ -2625,7 +2679,7 @@ static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user * arg)
 				sb = __dev_alloc_skb(NS_SMSKBSIZE, GFP_KERNEL);
 				if (sb == NULL)
 					return -ENOMEM;
-				NS_SKB_CB(sb)->buf_type = BUF_SM;
+				NS_PRV_BUFTYPE(sb) = BUF_SM;
 				skb_queue_tail(&card->sbpool.queue, sb);
 				skb_reserve(sb, NS_AAL0_HEADER);
 				push_rxbufs(card, sb);
@@ -2639,7 +2693,7 @@ static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user * arg)
 				lb = __dev_alloc_skb(NS_LGSKBSIZE, GFP_KERNEL);
 				if (lb == NULL)
 					return -ENOMEM;
-				NS_SKB_CB(lb)->buf_type = BUF_LG;
+				NS_PRV_BUFTYPE(lb) = BUF_LG;
 				skb_queue_tail(&card->lbpool.queue, lb);
 				skb_reserve(lb, NS_SMBUFSIZE);
 				push_rxbufs(card, lb);
@@ -2668,7 +2722,7 @@ static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user * arg)
 				hb = __dev_alloc_skb(NS_HBUFSIZE, GFP_KERNEL);
 				if (hb == NULL)
 					return -ENOMEM;
-				NS_SKB_CB(hb)->buf_type = BUF_NONE;
+				NS_PRV_BUFTYPE(hb) = BUF_NONE;
 				spin_lock_irqsave(&card->int_lock, flags);
 				skb_queue_tail(&card->hbpool.queue, hb);
 				card->hbpool.count++;
@@ -2698,7 +2752,7 @@ static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user * arg)
 				iovb = alloc_skb(NS_IOVBUFSIZE, GFP_KERNEL);
 				if (iovb == NULL)
 					return -ENOMEM;
-				NS_SKB_CB(iovb)->buf_type = BUF_NONE;
+				NS_PRV_BUFTYPE(iovb) = BUF_NONE;
 				spin_lock_irqsave(&card->int_lock, flags);
 				skb_queue_tail(&card->iovpool.queue, iovb);
 				card->iovpool.count++;
@@ -2723,10 +2777,12 @@ static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user * arg)
 	}
 }
 
+#ifdef EXTRA_DEBUG
 static void which_list(ns_dev * card, struct sk_buff *skb)
 {
-	printk("skb buf_type: 0x%08x\n", NS_SKB_CB(skb)->buf_type);
+	printk("skb buf_type: 0x%08x\n", NS_PRV_BUFTYPE(skb));
 }
+#endif /* EXTRA_DEBUG */
 
 static void ns_poll(unsigned long arg)
 {
@@ -2803,7 +2859,7 @@ static void ns_phy_put(struct atm_dev *dev, unsigned char value,
 	card = dev->dev_data;
 	spin_lock_irqsave(&card->res_lock, flags);
 	while (CMD_BUSY(card)) ;
-	writel((unsigned long)value, card->membase + DR0);
+	writel((u32) value, card->membase + DR0);
 	writel(NS_CMD_WRITE_UTILITY | 0x00000200 | (addr & 0x000000FF),
 	       card->membase + CMD);
 	spin_unlock_irqrestore(&card->res_lock, flags);
@@ -2813,7 +2869,7 @@ static unsigned char ns_phy_get(struct atm_dev *dev, unsigned long addr)
 {
 	ns_dev *card;
 	unsigned long flags;
-	unsigned long data;
+	u32 data;
 
 	card = dev->dev_data;
 	spin_lock_irqsave(&card->res_lock, flags);
diff --git a/drivers/atm/nicstar.h b/drivers/atm/nicstar.h
index 43eb2db..9bc27ea 100644
--- a/drivers/atm/nicstar.h
+++ b/drivers/atm/nicstar.h
@@ -16,6 +16,7 @@
 
 #include <linux/types.h>
 #include <linux/pci.h>
+#include <linux/idr.h>
 #include <linux/uio.h>
 #include <linux/skbuff.h>
 #include <linux/atmdev.h>
@@ -636,14 +637,22 @@ enum ns_regs {
 
 /* Device driver structures */
 
-struct ns_skb_cb {
+struct ns_skb_prv {
 	u32 buf_type;		/* BUF_SM/BUF_LG/BUF_NONE */
+	u32 dma;
+	int iovcnt;
 };
 
-#define NS_SKB_CB(skb)	((struct ns_skb_cb *)((skb)->cb))
+#define NS_PRV_BUFTYPE(skb)   \
+        (((struct ns_skb_prv *)(ATM_SKB(skb)+1))->buf_type)
+#define NS_PRV_DMA(skb) \
+        (((struct ns_skb_prv *)(ATM_SKB(skb)+1))->dma)
+#define NS_PRV_IOVCNT(skb) \
+        (((struct ns_skb_prv *)(ATM_SKB(skb)+1))->iovcnt)
 
 typedef struct tsq_info {
 	void *org;
+        dma_addr_t dma;
 	ns_tsi *base;
 	ns_tsi *next;
 	ns_tsi *last;
@@ -651,6 +660,7 @@ typedef struct tsq_info {
 
 typedef struct scq_info {
 	void *org;
+	dma_addr_t dma;
 	ns_scqe *base;
 	ns_scqe *last;
 	ns_scqe *next;
@@ -668,6 +678,7 @@ typedef struct scq_info {
 
 typedef struct rsq_info {
 	void *org;
+        dma_addr_t dma;
 	ns_rsqe *base;
 	ns_rsqe *next;
 	ns_rsqe *last;
@@ -693,13 +704,6 @@ typedef struct vc_map {
 	int tbd_count;
 } vc_map;
 
-struct ns_skb_data {
-	struct atm_vcc *vcc;
-	int iovcnt;
-};
-
-#define NS_SKB(skb) (((struct ns_skb_data *) (skb)->cb))
-
 typedef struct ns_dev {
 	int index;		/* Card ID to the device driver */
 	int sram_size;		/* In k x 32bit words. 32 or 128 */
@@ -709,6 +713,7 @@ typedef struct ns_dev {
 	int vpibits;
 	int vcibits;
 	struct pci_dev *pcidev;
+	struct idr idr;
 	struct atm_dev *atmdev;
 	tsq_info tsq;
 	rsq_info rsq;
@@ -729,11 +734,12 @@ typedef struct ns_dev {
 	buf_nr iovnr;
 	int sbfqc;
 	int lbfqc;
-	u32 sm_handle;
+	struct sk_buff *sm_handle;
 	u32 sm_addr;
-	u32 lg_handle;
+	struct sk_buff *lg_handle;
 	u32 lg_addr;
 	struct sk_buff *rcbuf;	/* Current raw cell buffer */
+        struct ns_rcqe *rawcell;
 	u32 rawch;		/* Raw cell queue head */
 	unsigned intcnt;	/* Interrupt counter */
 	spinlock_t int_lock;	/* Interrupt lock */
