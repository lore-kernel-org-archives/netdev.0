From: "Benjamin Li" <benli@broadcom.com>
Subject: [PATCH 2/4] bnx2: Add TX multiqueue support.
Date: Fri, 18 Jul 2008 14:20:48 -0700
Message-ID: <1216416050-10572-3-git-send-email-benli@broadcom.com>
References: <1216416050-10572-1-git-send-email-benli@broadcom.com>
 <1216416050-10572-2-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com, "Michael Chan" <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1874 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755776AbYGRVVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 17:21:05 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id D4A012B1 for
 <netdev@vger.kernel.org>; Fri, 18 Jul 2008 14:20:51 -0700 (PDT)
In-Reply-To: <1216416050-10572-2-git-send-email-benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   53 ++++++++++++++++++++++++++++++++++-----------------
 drivers/net/bnx2.h |    3 ++
 2 files changed, 38 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 9ce30fc..dc6f261 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -47,6 +47,7 @@
 #include <linux/prefetch.h>
 #include <linux/cache.h>
 #include <linux/zlib.h>
+#include <linux/log2.h>
 
 #include "bnx2.h"
 #include "bnx2_fw.h"
@@ -492,7 +493,7 @@ bnx2_netif_start(struct bnx2 *bp)
 {
 	if (atomic_dec_and_test(&bp->intr_sem)) {
 		if (netif_running(bp->dev)) {
-			netif_wake_queue(bp->dev);
+			netif_tx_wake_all_queues(bp->dev);
 			bnx2_napi_enable(bp);
 			bnx2_enable_int(bp);
 		}
@@ -2584,7 +2585,11 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 {
 	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
 	u16 hw_cons, sw_cons, sw_ring_cons;
-	int tx_pkt = 0;
+	int tx_pkt = 0, index;
+	struct netdev_queue *txq;
+
+	index = (bnapi - bp->bnx2_napi);
+	txq = netdev_get_tx_queue(bp->dev, index);
 
 	hw_cons = bnx2_get_hw_tx_cons(bnapi);
 	sw_cons = txr->tx_cons;
@@ -2644,21 +2649,23 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 	txr->hw_tx_cons = hw_cons;
 	txr->tx_cons = sw_cons;
+
 	/* Need to make the tx_cons update visible to bnx2_start_xmit()
-	 * before checking for netif_queue_stopped().  Without the
+	 * before checking for netif_tx_queue_stopped().  Without the
 	 * memory barrier, there is a small possibility that bnx2_start_xmit()
 	 * will miss it and cause the queue to be stopped forever.
 	 */
 	smp_mb();
 
-	if (unlikely(netif_queue_stopped(bp->dev)) &&
+	if (unlikely(netif_tx_queue_stopped(txq)) &&
 		     (bnx2_tx_avail(bp, txr) > bp->tx_wake_thresh)) {
-		netif_tx_lock(bp->dev);
-		if ((netif_queue_stopped(bp->dev)) &&
+		__netif_tx_lock(txq, smp_processor_id());
+		if ((netif_tx_queue_stopped(txq)) &&
 		    (bnx2_tx_avail(bp, txr) > bp->tx_wake_thresh))
-			netif_wake_queue(bp->dev);
-		netif_tx_unlock(bp->dev);
+			netif_tx_wake_queue(txq);
+		__netif_tx_unlock(txq);
 	}
+
 	return tx_pkt;
 }
 
@@ -5766,7 +5773,7 @@ static void
 bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 {
 	int cpus = num_online_cpus();
-	int msix_vecs = min(cpus + 1, RX_MAX_RSS_RINGS);
+	int msix_vecs = min(cpus + 1, RX_MAX_RINGS);
 
 	bp->irq_tbl[0].handler = bnx2_interrupt;
 	strcpy(bp->irq_tbl[0].name, bp->dev->name);
@@ -5789,7 +5796,10 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 			bp->irq_tbl[0].vector = bp->pdev->irq;
 		}
 	}
-	bp->num_tx_rings = 1;
+
+	bp->num_tx_rings = rounddown_pow_of_two(bp->irq_nvecs);
+	bp->dev->real_num_tx_queues = bp->num_tx_rings;
+
 	bp->num_rx_rings = bp->irq_nvecs;
 }
 
@@ -5858,7 +5868,7 @@ bnx2_open(struct net_device *dev)
 	else if (bp->flags & BNX2_FLAG_USING_MSIX)
 		printk(KERN_INFO PFX "%s: using MSIX\n", dev->name);
 
-	netif_start_queue(dev);
+	netif_tx_start_all_queues(dev);
 
 	return 0;
 
@@ -5927,12 +5937,19 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 len, vlan_tag_flags, last_frag, mss;
 	u16 prod, ring_prod;
 	int i;
-	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
-	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
+	struct bnx2_napi *bnapi;
+	struct bnx2_tx_ring_info *txr;
+	struct netdev_queue *txq;
+
+	/*  Determine which tx ring we will be placed on */
+	i = skb_get_queue_mapping(skb);
+	bnapi = &bp->bnx2_napi[i];
+	txr = &bnapi->tx_ring;
+	txq = netdev_get_tx_queue(dev, i);
 
 	if (unlikely(bnx2_tx_avail(bp, txr) <
 	    (skb_shinfo(skb)->nr_frags + 1))) {
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(txq);
 		printk(KERN_ERR PFX "%s: BUG! Tx ring full when queue awake!\n",
 			dev->name);
 
@@ -6047,9 +6064,9 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 
 	if (unlikely(bnx2_tx_avail(bp, txr) <= MAX_SKB_FRAGS)) {
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(txq);
 		if (bnx2_tx_avail(bp, txr) > bp->tx_wake_thresh)
-			netif_wake_queue(dev);
+			netif_tx_wake_queue(txq);
 	}
 
 	return NETDEV_TX_OK;
@@ -7294,7 +7311,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	INIT_WORK(&bp->reset_task, bnx2_reset_task);
 
 	dev->base_addr = dev->mem_start = pci_resource_start(pdev, 0);
-	mem_len = MB_GET_CID_ADDR(TX_TSS_CID + 1);
+	mem_len = MB_GET_CID_ADDR(TX_TSS_CID + TX_MAX_TSS_RINGS);
 	dev->mem_end = dev->mem_start + mem_len;
 	dev->irq = pdev->irq;
 
@@ -7647,7 +7664,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		printk(KERN_INFO "%s", version);
 
 	/* dev zeroed in init_etherdev */
-	dev = alloc_etherdev(sizeof(*bp));
+	dev = alloc_etherdev_mq(sizeof(*bp), TX_MAX_RINGS);
 
 	if (!dev)
 		return -ENOMEM;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index bb7b5d5..c3c579f 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6509,6 +6509,9 @@ struct l2_fhdr {
 #define RX_CID		0
 #define RX_RSS_CID	4
 #define RX_MAX_RSS_RINGS	7
+#define RX_MAX_RINGS		(RX_MAX_RSS_RINGS + 1)
+#define TX_MAX_TSS_RINGS	7
+#define TX_MAX_RINGS		(TX_MAX_TSS_RINGS + 1)
 
 #define MB_TX_CID_ADDR	MB_GET_CID_ADDR(TX_CID)
 #define MB_RX_CID_ADDR	MB_GET_CID_ADDR(RX_CID)
-- 
1.5.6.1


