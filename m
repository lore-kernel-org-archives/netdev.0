From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 5/6] drivers: net: remove NETDEV_TX_LOCKED
Date: Sun, 24 Apr 2016 21:38:13 +0200
Message-ID: <1461526694-11367-6-git-send-email-fw@strlen.de>
References: <1461526694-11367-1-git-send-email-fw@strlen.de>
Cc: linux-kernel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Jon Mason <jdmason@kudzu.us>,
	Andy Gospodarek <andy@greyhouse.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59120 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753342AbcDXTik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 15:38:40 -0400
In-Reply-To: <1461526694-11367-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace the trylock by a full spin_lock and remove TX_LOCKED return value.
Followup patch will remove TX_LOCKED from the kernel.

Cc: Jon Mason <jdmason@kudzu.us>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ethernet/chelsio/cxgb/sge.c              | 3 +--
 drivers/net/ethernet/neterion/s2io.c                 | 9 +--------
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 6 ++----
 drivers/net/ethernet/tehuti/tehuti.c                 | 8 +-------
 drivers/net/rionet.c                                 | 6 +-----
 5 files changed, 6 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 526ea74..86f467a 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -1664,8 +1664,7 @@ static int t1_sge_tx(struct sk_buff *skb, struct adapter *adapter,
 	struct cmdQ *q = &sge->cmdQ[qid];
 	unsigned int credits, pidx, genbit, count, use_sched_skb = 0;
 
-	if (!spin_trylock(&q->lock))
-		return NETDEV_TX_LOCKED;
+	spin_lock(&q->lock);
 
 	reclaim_completed_tx(sge, q);
 
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 9ba9758..2874dff 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -4021,7 +4021,6 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags = 0;
 	u16 vlan_tag = 0;
 	struct fifo_info *fifo = NULL;
-	int do_spin_lock = 1;
 	int offload_type;
 	int enable_per_list_interrupt = 0;
 	struct config_param *config = &sp->config;
@@ -4074,7 +4073,6 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 					queue += sp->udp_fifo_idx;
 					if (skb->len > 1024)
 						enable_per_list_interrupt = 1;
-					do_spin_lock = 0;
 				}
 			}
 		}
@@ -4084,12 +4082,7 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 			[skb->priority & (MAX_TX_FIFOS - 1)];
 	fifo = &mac_control->fifos[queue];
 
-	if (do_spin_lock)
-		spin_lock_irqsave(&fifo->tx_lock, flags);
-	else {
-		if (unlikely(!spin_trylock_irqsave(&fifo->tx_lock, flags)))
-			return NETDEV_TX_LOCKED;
-	}
+	spin_lock_irqsave(&fifo->tx_lock, flags);
 
 	if (sp->config.multiq) {
 		if (__netif_subqueue_stopped(dev, fifo->fifo_no)) {
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 3b98b263b..4475dcc 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2137,10 +2137,8 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
 	unsigned long flags;
 
-	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags)) {
-		/* Collision - tell upper layer to requeue */
-		return NETDEV_TX_LOCKED;
-	}
+	spin_trylock_irqsave(&tx_ring->tx_lock, flags);
+
 	if (unlikely(!PCH_GBE_DESC_UNUSED(tx_ring))) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 14c9d1b..2524a69 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1610,7 +1610,6 @@ static inline int bdx_tx_space(struct bdx_priv *priv)
  * o NETDEV_TX_BUSY Cannot transmit packet, try later
  *   Usually a bug, means queue start/stop flow control is broken in
  *   the driver. Note: the driver must NOT put the skb in its DMA ring.
- * o NETDEV_TX_LOCKED Locking failed, please retry quickly.
  */
 static netdev_tx_t bdx_tx_transmit(struct sk_buff *skb,
 				   struct net_device *ndev)
@@ -1630,12 +1629,7 @@ static netdev_tx_t bdx_tx_transmit(struct sk_buff *skb,
 
 	ENTER;
 	local_irq_save(flags);
-	if (!spin_trylock(&priv->tx_lock)) {
-		local_irq_restore(flags);
-		DBG("%s[%s]: TX locked, returning NETDEV_TX_LOCKED\n",
-		    BDX_DRV_NAME, ndev->name);
-		return NETDEV_TX_LOCKED;
-	}
+	spin_lock(&priv->tx_lock);
 
 	/* build tx descriptor */
 	BDX_ASSERT(f->m.wptr >= f->m.memsz);	/* started with valid wptr */
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index 9cfe6ae..a31f461 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -179,11 +179,7 @@ static int rionet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	unsigned long flags;
 	int add_num = 1;
 
-	local_irq_save(flags);
-	if (!spin_trylock(&rnet->tx_lock)) {
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED;
-	}
+	spin_lock_irqsave(&rnet->tx_lock, flags);
 
 	if (is_multicast_ether_addr(eth->h_dest))
 		add_num = nets[rnet->mport->id].nact;
-- 
2.7.3
