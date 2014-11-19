From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2] enic: support skb->xmit_more
Date: Wed, 19 Nov 2014 12:59:32 +0530
Message-ID: <1416382172-28775-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com, eric.dumazet@gmail.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:58200 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932113AbaKSH3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 02:29:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check and update posted_index only when skb->xmit_more is 0 or tx queue is full.

v2:
use txq_map instead of skb_get_queue_mapping(skb)

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |  8 ++++++--
 drivers/net/ethernet/cisco/enic/vnic_wq.h   | 20 +++++++++++---------
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 5afe360..b9cda2f 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -533,6 +533,7 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
 	struct vnic_wq *wq;
 	unsigned long flags;
 	unsigned int txq_map;
+	struct netdev_queue *txq;
 
 	if (skb->len <= 0) {
 		dev_kfree_skb_any(skb);
@@ -541,6 +542,7 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
 
 	txq_map = skb_get_queue_mapping(skb) % enic->wq_count;
 	wq = &enic->wq[txq_map];
+	txq = netdev_get_tx_queue(netdev, txq_map);
 
 	/* Non-TSO sends must fit within ENIC_NON_TSO_MAX_DESC descs,
 	 * which is very likely.  In the off chance it's going to take
@@ -558,7 +560,7 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
 
 	if (vnic_wq_desc_avail(wq) <
 	    skb_shinfo(skb)->nr_frags + ENIC_DESC_MAX_SPLITS) {
-		netif_tx_stop_queue(netdev_get_tx_queue(netdev, txq_map));
+		netif_tx_stop_queue(txq);
 		/* This is a hard error, log it */
 		netdev_err(netdev, "BUG! Tx ring full when queue awake!\n");
 		spin_unlock_irqrestore(&enic->wq_lock[txq_map], flags);
@@ -568,7 +570,9 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
 	enic_queue_wq_skb(enic, wq, skb);
 
 	if (vnic_wq_desc_avail(wq) < MAX_SKB_FRAGS + ENIC_DESC_MAX_SPLITS)
-		netif_tx_stop_queue(netdev_get_tx_queue(netdev, txq_map));
+		netif_tx_stop_queue(txq);
+	if (!skb->xmit_more || netif_xmit_stopped(txq))
+		vnic_wq_doorbell(wq);
 
 	spin_unlock_irqrestore(&enic->wq_lock[txq_map], flags);
 
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.h b/drivers/net/ethernet/cisco/enic/vnic_wq.h
index 2c6c708..816f1ad 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.h
@@ -104,6 +104,17 @@ static inline void *vnic_wq_next_desc(struct vnic_wq *wq)
 	return wq->to_use->desc;
 }
 
+static inline void vnic_wq_doorbell(struct vnic_wq *wq)
+{
+	/* Adding write memory barrier prevents compiler and/or CPU
+	 * reordering, thus avoiding descriptor posting before
+	 * descriptor is initialized. Otherwise, hardware can read
+	 * stale descriptor fields.
+	 */
+	wmb();
+	iowrite32(wq->to_use->index, &wq->ctrl->posted_index);
+}
+
 static inline void vnic_wq_post(struct vnic_wq *wq,
 	void *os_buf, dma_addr_t dma_addr,
 	unsigned int len, int sop, int eop,
@@ -122,15 +133,6 @@ static inline void vnic_wq_post(struct vnic_wq *wq,
 	buf->wr_id = wrid;
 
 	buf = buf->next;
-	if (eop) {
-		/* Adding write memory barrier prevents compiler and/or CPU
-		 * reordering, thus avoiding descriptor posting before
-		 * descriptor is initialized. Otherwise, hardware can read
-		 * stale descriptor fields.
-		 */
-		wmb();
-		iowrite32(buf->index, &wq->ctrl->posted_index);
-	}
 	wq->to_use = buf;
 
 	wq->ring.desc_avail -= desc_skip_cnt;
-- 
2.1.3
