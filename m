From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 7/7] chelsio: misc cleanups in sge
Date: Wed, 6 Dec 2006 01:17:39 +0100
Message-ID: <20061206001739.GG2377@electric-eye.fr.zoreil.com>
References: <20061206001007.GA27423@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39989 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758384AbWLFAU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 19:20:59 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206001007.GA27423@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- duplicated code in sge::free_cmdQ_buffers ;
- NET_IP_ALIGN is already defined in (included) <linux/skbuff.h> ;
- pci_alloc_consistent() returns void * ;
- pci_alloc_consistent() returns a zeroed chunk of memory ;
- early return in restart_tx_queues.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/chelsio/sge.c |   54 +++++++++++++++-----------------------------
 1 files changed, 19 insertions(+), 35 deletions(-)

diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index f8b40b2..095aba2 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -85,10 +85,6 @@
  */
 #define TX_RECLAIM_PERIOD (HZ / 4)
 
-#ifndef NET_IP_ALIGN
-# define NET_IP_ALIGN 2
-#endif
-
 #define M_CMD_LEN       0x7fffffff
 #define V_CMD_LEN(v)    (v)
 #define G_CMD_LEN(v)    ((v) & M_CMD_LEN)
@@ -575,11 +571,10 @@ static int alloc_rx_resources(struct sge
 		q->size = p->freelQ_size[i];
 		q->dma_offset = sge->rx_pkt_pad ? 0 : NET_IP_ALIGN;
 		size = sizeof(struct freelQ_e) * q->size;
-		q->entries = (struct freelQ_e *)
-			      pci_alloc_consistent(pdev, size, &q->dma_addr);
+		q->entries = pci_alloc_consistent(pdev, size, &q->dma_addr);
 		if (!q->entries)
 			goto err_no_mem;
-		memset(q->entries, 0, size);
+
 		size = sizeof(struct freelQ_ce) * q->size;
 		q->centries = kzalloc(size, GFP_KERNEL);
 		if (!q->centries)
@@ -613,11 +608,10 @@ static int alloc_rx_resources(struct sge
 	sge->respQ.size = SGE_RESPQ_E_N;
 	sge->respQ.credits = 0;
 	size = sizeof(struct respQ_e) * sge->respQ.size;
-	sge->respQ.entries = (struct respQ_e *)
+	sge->respQ.entries =
 		pci_alloc_consistent(pdev, size, &sge->respQ.dma_addr);
 	if (!sge->respQ.entries)
 		goto err_no_mem;
-	memset(sge->respQ.entries, 0, size);
 	return 0;
 
 err_no_mem:
@@ -637,20 +631,12 @@ static void free_cmdQ_buffers(struct sge
 	q->in_use -= n;
 	ce = &q->centries[cidx];
 	while (n--) {
-		if (q->sop) {
-			if (likely(pci_unmap_len(ce, dma_len))) {
-				pci_unmap_single(pdev,
-						 pci_unmap_addr(ce, dma_addr),
-						 pci_unmap_len(ce, dma_len),
-						 PCI_DMA_TODEVICE);
+		if (likely(pci_unmap_len(ce, dma_len))) {
+			pci_unmap_single(pdev, pci_unmap_addr(ce, dma_addr),
+					 pci_unmap_len(ce, dma_len),
+					 PCI_DMA_TODEVICE);
+			if (q->sop)
 				q->sop = 0;
-			}
-		} else {
-			if (likely(pci_unmap_len(ce, dma_len))) {
-				pci_unmap_page(pdev, pci_unmap_addr(ce, dma_addr),
-					       pci_unmap_len(ce, dma_len),
-					       PCI_DMA_TODEVICE);
-			}
 		}
 		if (ce->skb) {
 			dev_kfree_skb_any(ce->skb);
@@ -711,11 +697,10 @@ static int alloc_tx_resources(struct sge
 		q->stop_thres = 0;
 		spin_lock_init(&q->lock);
 		size = sizeof(struct cmdQ_e) * q->size;
-		q->entries = (struct cmdQ_e *)
-			      pci_alloc_consistent(pdev, size, &q->dma_addr);
+		q->entries = pci_alloc_consistent(pdev, size, &q->dma_addr);
 		if (!q->entries)
 			goto err_no_mem;
-		memset(q->entries, 0, size);
+
 		size = sizeof(struct cmdQ_ce) * q->size;
 		q->centries = kzalloc(size, GFP_KERNEL);
 		if (!q->centries)
@@ -1443,19 +1428,18 @@ static inline int enough_free_Tx_descs(c
 static void restart_tx_queues(struct sge *sge)
 {
 	struct adapter *adap = sge->adapter;
+	int i;
 
-	if (enough_free_Tx_descs(&sge->cmdQ[0])) {
-		int i;
+	if (!enough_free_Tx_descs(&sge->cmdQ[0]))
+		return;
 
-		for_each_port(adap, i) {
-			struct net_device *nd = adap->port[i].dev;
+	for_each_port(adap, i) {
+		struct net_device *nd = adap->port[i].dev;
 
-			if (test_and_clear_bit(nd->if_port,
-					       &sge->stopped_tx_queues) &&
-			    netif_running(nd)) {
-				sge->stats.cmdQ_restarted[2]++;
-				netif_wake_queue(nd);
-			}
+		if (test_and_clear_bit(nd->if_port, &sge->stopped_tx_queues) &&
+		    netif_running(nd)) {
+			sge->stats.cmdQ_restarted[2]++;
+			netif_wake_queue(nd);
 		}
 	}
 }
-- 
1.4.4.1

