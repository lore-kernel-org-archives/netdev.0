From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/3] chelsio: more rx speedup
Date: Mon, 8 Jan 2007 11:26:12 -0800
Message-ID: <20070108112612.5f947357@dxpl.pdx.osdl.net>
References: <20061215190716.956791000@osdl.org>
	<4591912E.60402@pobox.com>
	<20070108112426.2a5e43fa@dxpl.pdx.osdl.net>
	<20070108112524.730e89f0@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37318 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030507AbXAHT04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 14:26:56 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20070108112524.730e89f0@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cleanup receive processing some more:
   * do the reserve padding of skb during setup
   * don't pass constants to get_packet
   * do smart prefetch of skb
   * make copybreak a module parameter

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/chelsio/sge.c |   87 +++++++++++++++++++++++-----------------------
 1 file changed, 45 insertions(+), 42 deletions(-)

--- netdev-2.6.orig/drivers/net/chelsio/sge.c
+++ netdev-2.6/drivers/net/chelsio/sge.c
@@ -71,12 +71,9 @@
 #define SGE_FREEL_REFILL_THRESH	16
 #define SGE_RESPQ_E_N		1024
 #define SGE_INTRTIMER_NRES	1000
-#define SGE_RX_COPY_THRES	256
 #define SGE_RX_SM_BUF_SIZE	1536
 #define SGE_TX_DESC_MAX_PLEN	16384
 
-# define SGE_RX_DROP_THRES 2
-
 #define SGE_RESPQ_REPLENISH_THRES (SGE_RESPQ_E_N / 4)
 
 /*
@@ -846,6 +843,8 @@ static void refill_free_list(struct sge 
 		skb_reserve(skb, q->dma_offset);
 		mapping = pci_map_single(pdev, skb->data, dma_len,
 					 PCI_DMA_FROMDEVICE);
+		skb_reserve(skb, sge->rx_pkt_pad);
+
 		ce->skb = skb;
 		pci_unmap_addr_set(ce, dma_addr, mapping);
 		pci_unmap_len_set(ce, dma_len, dma_len);
@@ -1024,6 +1023,10 @@ static void recycle_fl_buf(struct freelQ
 	}
 }
 
+static int copybreak __read_mostly = 256;
+module_param(copybreak, int, 0);
+MODULE_PARM_DESC(copybreak, "Receive copy threshold");
+
 /**
  *	get_packet - return the next ingress packet buffer
  *	@pdev: the PCI device that received the packet
@@ -1043,45 +1046,42 @@ static void recycle_fl_buf(struct freelQ
  *	be copied but there is no memory for the copy.
  */
 static inline struct sk_buff *get_packet(struct pci_dev *pdev,
-					 struct freelQ *fl, unsigned int len,
-					 int dma_pad, int skb_pad,
-					 unsigned int copy_thres,
-					 unsigned int drop_thres)
+					 struct freelQ *fl, unsigned int len)
 {
 	struct sk_buff *skb;
-	struct freelQ_ce *ce = &fl->centries[fl->cidx];
+	const struct freelQ_ce *ce = &fl->centries[fl->cidx];
 
-	if (len < copy_thres) {
-		skb = alloc_skb(len + skb_pad, GFP_ATOMIC);
-		if (likely(skb != NULL)) {
-			skb_reserve(skb, skb_pad);
-			skb_put(skb, len);
-			pci_dma_sync_single_for_cpu(pdev,
-					    pci_unmap_addr(ce, dma_addr),
-					    pci_unmap_len(ce, dma_len),
-					    PCI_DMA_FROMDEVICE);
-			memcpy(skb->data, ce->skb->data + dma_pad, len);
-			pci_dma_sync_single_for_device(pdev,
+	if (len < copybreak) {
+		skb = alloc_skb(len + 2, GFP_ATOMIC);
+		if (!skb)
+			goto use_orig_buf;
+
+		skb_reserve(skb, 2);	/* align IP header */
+		skb_put(skb, len);
+		pci_dma_sync_single_for_cpu(pdev,
 					    pci_unmap_addr(ce, dma_addr),
 					    pci_unmap_len(ce, dma_len),
 					    PCI_DMA_FROMDEVICE);
-		} else if (!drop_thres)
-			goto use_orig_buf;
-
+		memcpy(skb->data, ce->skb->data, len);
+		pci_dma_sync_single_for_device(pdev,
+					       pci_unmap_addr(ce, dma_addr),
+					       pci_unmap_len(ce, dma_len),
+					       PCI_DMA_FROMDEVICE);
 		recycle_fl_buf(fl, fl->cidx);
 		return skb;
 	}
 
-	if (fl->credits < drop_thres) {
+use_orig_buf:
+	if (fl->credits < 2) {
 		recycle_fl_buf(fl, fl->cidx);
 		return NULL;
 	}
 
-use_orig_buf:
 	pci_unmap_single(pdev, pci_unmap_addr(ce, dma_addr),
 			 pci_unmap_len(ce, dma_len), PCI_DMA_FROMDEVICE);
 	skb = ce->skb;
-	skb_reserve(skb, dma_pad);
+	prefetch(skb->data);
+
 	skb_put(skb, len);
 	return skb;
 }
@@ -1359,27 +1359,25 @@ static void restart_sched(unsigned long 
  *
  *	Process an ingress ethernet pakcet and deliver it to the stack.
  */
-static int sge_rx(struct sge *sge, struct freelQ *fl, unsigned int len)
+static void sge_rx(struct sge *sge, struct freelQ *fl, unsigned int len)
 {
 	struct sk_buff *skb;
-	struct cpl_rx_pkt *p;
+	const struct cpl_rx_pkt *p;
 	struct adapter *adapter = sge->adapter;
 	struct sge_port_stats *st;
 
-	skb = get_packet(adapter->pdev, fl, len - sge->rx_pkt_pad,
-			 sge->rx_pkt_pad, 2, SGE_RX_COPY_THRES,
-			 SGE_RX_DROP_THRES);
+	skb = get_packet(adapter->pdev, fl, len - sge->rx_pkt_pad);
 	if (unlikely(!skb)) {
 		sge->stats.rx_drops++;
-		return 0;
+		return;
 	}
 
-	p = (struct cpl_rx_pkt *)skb->data;
-	skb_pull(skb, sizeof(*p));
+	p = (const struct cpl_rx_pkt *) skb->data;
 	if (p->iff >= adapter->params.nports) {
 		kfree_skb(skb);
-		return 0;
+		return;
 	}
+	__skb_pull(skb, sizeof(*p));
 
 	skb->dev = adapter->port[p->iff].dev;
 	skb->dev->last_rx = jiffies;
@@ -1411,7 +1409,6 @@ static int sge_rx(struct sge *sge, struc
 		netif_rx(skb);
 #endif
 	}
-	return 0;
 }
 
 /*
@@ -1493,12 +1490,11 @@ static int process_responses(struct adap
 	struct sge *sge = adapter->sge;
 	struct respQ *q = &sge->respQ;
 	struct respQ_e *e = &q->entries[q->cidx];
-	int budget_left = budget;
+	int done = 0;
 	unsigned int flags = 0;
 	unsigned int cmdq_processed[SGE_CMDQ_N] = {0, 0};
 
-
-	while (likely(budget_left && e->GenerationBit == q->genbit)) {
+	while (done < budget && e->GenerationBit == q->genbit) {
 		flags |= e->Qsleeping;
 
 		cmdq_processed[0] += e->Cmdq0CreditReturn;
@@ -1508,14 +1504,16 @@ static int process_responses(struct adap
 		 * ping-pong of TX state information on MP where the sender
 		 * might run on a different CPU than this function...
 		 */
-		if (unlikely(flags & F_CMDQ0_ENABLE || cmdq_processed[0] > 64)) {
+		if (unlikely((flags & F_CMDQ0_ENABLE) || cmdq_processed[0] > 64)) {
 			flags = update_tx_info(adapter, flags, cmdq_processed[0]);
 			cmdq_processed[0] = 0;
 		}
+
 		if (unlikely(cmdq_processed[1] > 16)) {
 			sge->cmdQ[1].processed += cmdq_processed[1];
 			cmdq_processed[1] = 0;
 		}
+
 		if (likely(e->DataValid)) {
 			struct freelQ *fl = &sge->freelQ[e->FreelistQid];
 
@@ -1525,12 +1523,16 @@ static int process_responses(struct adap
 			else
 				sge_rx(sge, fl, e->BufferLength);
 
+			++done;
+
 			/*
 			 * Note: this depends on each packet consuming a
 			 * single free-list buffer; cf. the BUG above.
 			 */
 			if (++fl->cidx == fl->size)
 				fl->cidx = 0;
+			prefetch(fl->centries[fl->cidx].skb);
+
 			if (unlikely(--fl->credits <
 				     fl->size - SGE_FREEL_REFILL_THRESH))
 				refill_free_list(sge, fl);
@@ -1549,14 +1551,12 @@ static int process_responses(struct adap
 			writel(q->credits, adapter->regs + A_SG_RSPQUEUECREDIT);
 			q->credits = 0;
 		}
-		--budget_left;
 	}
 
 	flags = update_tx_info(adapter, flags, cmdq_processed[0]);
 	sge->cmdQ[1].processed += cmdq_processed[1];
 
-	budget -= budget_left;
-	return budget;
+	return done;
 }
 
 static inline int responses_pending(const struct adapter *adapter)
@@ -1581,11 +1581,14 @@ static int process_pure_responses(struct
 	struct sge *sge = adapter->sge;
 	struct respQ *q = &sge->respQ;
 	struct respQ_e *e = &q->entries[q->cidx];
+	const struct freelQ *fl = &sge->freelQ[e->FreelistQid];
 	unsigned int flags = 0;
 	unsigned int cmdq_processed[SGE_CMDQ_N] = {0, 0};
 
+	prefetch(fl->centries[fl->cidx].skb);
 	if (e->DataValid)
 		return 1;
+
 	do {
 		flags |= e->Qsleeping;
 
