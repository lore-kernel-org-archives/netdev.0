From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 09/18] tg3: Add TSS support
Date: Tue, 1 Sep 2009 16:09:39 -0700
Message-ID: <1251867307.5938@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3690 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932135AbZIBEzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch exposes the additional transmit rings to the kernel and makes
the necessary modifications to transmit, open, and close paths.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   54 +++++++++++++++++++++++++++++++++++-----------------
 drivers/net/tg3.h |    1 +
 2 files changed, 37 insertions(+), 18 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5389654..2e0f4a5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -704,11 +704,13 @@ static inline void tg3_netif_stop(struct tg3 *tp)
 static inline void tg3_netif_start(struct tg3 *tp)
 {
 	struct tg3_napi *tnapi = &tp->napi[0];
-	netif_wake_queue(tp->dev);
-	/* NOTE: unconditional netif_wake_queue is only appropriate
-	 * so long as all callers are assured to have free tx slots
-	 * (such as after tg3_init_hw)
+
+	/* NOTE: unconditional netif_tx_wake_all_queues is only
+	 * appropriate so long as all callers are assured to
+	 * have free tx slots (such as after tg3_init_hw)
 	 */
+	netif_tx_wake_all_queues(tp->dev);
+
 	napi_enable(&tnapi->napi);
 	tnapi->hw_status->status |= SD_STATUS_UPDATED;
 	tg3_enable_ints(tp);
@@ -4294,6 +4296,13 @@ static void tg3_tx(struct tg3_napi *tnapi)
 	struct tg3 *tp = tnapi->tp;
 	u32 hw_idx = tnapi->hw_status->idx[0].tx_consumer;
 	u32 sw_idx = tnapi->tx_cons;
+	struct netdev_queue *txq;
+	int index = tnapi - tp->napi;
+
+	if (tp->tg3_flags2 & TG3_FLG2_USING_MSIX)
+		index--;
+
+	txq = netdev_get_tx_queue(tp->dev, index);
 
 	while (sw_idx != hw_idx) {
 		struct tx_ring_info *ri = &tnapi->tx_buffers[sw_idx];
@@ -4335,13 +4344,13 @@ static void tg3_tx(struct tg3_napi *tnapi)
 	 */
 	smp_mb();
 
-	if (unlikely(netif_queue_stopped(tp->dev) &&
+	if (unlikely(netif_tx_queue_stopped(txq) &&
 		     (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi)))) {
-		netif_tx_lock(tp->dev);
-		if (netif_queue_stopped(tp->dev) &&
+		__netif_tx_lock(txq, smp_processor_id());
+		if (netif_tx_queue_stopped(txq) &&
 		    (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi)))
-			netif_wake_queue(tp->dev);
-		netif_tx_unlock(tp->dev);
+			netif_tx_wake_queue(txq);
+		__netif_tx_unlock(txq);
 	}
 }
 
@@ -5156,9 +5165,13 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 	u32 len, entry, base_flags, mss;
 	struct skb_shared_info *sp;
 	dma_addr_t mapping;
-	struct tg3_napi *tnapi = &tp->napi[0];
+	struct tg3_napi *tnapi;
+	struct netdev_queue *txq;
 
-	len = skb_headlen(skb);
+	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+	tnapi = &tp->napi[skb_get_queue_mapping(skb)];
+	if (tp->tg3_flags2 & TG3_FLG2_USING_MSIX)
+		tnapi++;
 
 	/* We are running in BH disabled context with netif_tx_lock
 	 * and TX reclaim runs via tp->napi.poll inside of a software
@@ -5166,8 +5179,8 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
 	if (unlikely(tg3_tx_avail(tnapi) <= (skb_shinfo(skb)->nr_frags + 1))) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
+		if (!netif_tx_queue_stopped(txq)) {
+			netif_tx_stop_queue(txq);
 
 			/* This is a hard error, log it. */
 			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
@@ -5226,6 +5239,8 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 
 	tnapi->tx_buffers[entry].skb = skb;
 
+	len = skb_headlen(skb);
+
 	tg3_set_txd(tnapi, entry, mapping, len, base_flags,
 		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
 
@@ -5255,9 +5270,9 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 
 	tnapi->tx_prod = entry;
 	if (unlikely(tg3_tx_avail(tnapi) <= (MAX_SKB_FRAGS + 1))) {
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(txq);
 		if (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi))
-			netif_wake_queue(tp->dev);
+			netif_tx_wake_queue(txq);
 	}
 
 out_unlock:
@@ -8047,6 +8062,8 @@ static bool tg3_enable_msix(struct tg3 *tp)
 	for (i = 0; i < tp->irq_max; i++)
 		tp->napi[i].irq_vec = msix_ent[i].vector;
 
+	tp->dev->real_num_tx_queues = tp->irq_cnt - 1;
+
 	return true;
 }
 
@@ -8076,6 +8093,7 @@ defcfg:
 	if (!(tp->tg3_flags2 & TG3_FLG2_USING_MSIX)) {
 		tp->irq_cnt = 1;
 		tp->napi[0].irq_vec = tp->pdev->irq;
+		tp->dev->real_num_tx_queues = 1;
 	}
 }
 
@@ -8211,7 +8229,7 @@ static int tg3_open(struct net_device *dev)
 
 	tg3_full_unlock(tp);
 
-	netif_start_queue(dev);
+	netif_tx_start_all_queues(dev);
 
 	return 0;
 
@@ -8471,7 +8489,7 @@ static int tg3_close(struct net_device *dev)
 	napi_disable(&tp->napi[0].napi);
 	cancel_work_sync(&tp->reset_task);
 
-	netif_stop_queue(dev);
+	netif_tx_stop_all_queues(dev);
 
 	del_timer_sync(&tp->timer);
 
@@ -13560,7 +13578,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_free_res;
 	}
 
-	dev = alloc_etherdev(sizeof(*tp));
+	dev = alloc_etherdev_mq(sizeof(*tp), TG3_IRQ_MAX_VECS);
 	if (!dev) {
 		printk(KERN_ERR PFX "Etherdev alloc failed, aborting.\n");
 		err = -ENOMEM;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 6452d48..d1c7add 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -822,6 +822,7 @@
 #define  SNDBDI_MODE_RESET		 0x00000001
 #define  SNDBDI_MODE_ENABLE		 0x00000002
 #define  SNDBDI_MODE_ATTN_ENABLE	 0x00000004
+#define  SNDBDI_MODE_MULTI_TXQ_EN	 0x00000020
 #define SNDBDI_STATUS			0x00001804
 #define  SNDBDI_STATUS_ERROR_ATTN	 0x00000004
 #define SNDBDI_IN_PROD_IDX_0		0x00001808
-- 
1.6.3.3


