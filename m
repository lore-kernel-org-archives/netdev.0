From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 1/3] net: tilegx driver bugfix (be explicit about percpu queue number)
Date: Wed, 18 Jul 2012 12:52:50 -0400
Message-ID: <201207181653.q6IGra4J007620@lab-41.internal.tilera.com>
References: <201207181650.q6IGodZ7007565@lab-41.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201207181650.q6IGodZ7007565@lab-41.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid packets belonging to queue/cpu A trying to transmit on cpu B.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c |   23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 83b4b38..c7bde28 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -123,6 +123,7 @@ struct tile_net_comps {
 
 /* The transmit wake timer for a given cpu and echannel. */
 struct tile_net_tx_wake {
+	int tx_queue_idx;
 	struct hrtimer timer;
 	struct net_device *dev;
 };
@@ -573,12 +574,14 @@ static void add_comp(gxio_mpipe_equeue_t *equeue,
 	comps->comp_next++;
 }
 
-static void tile_net_schedule_tx_wake_timer(struct net_device *dev)
+static void tile_net_schedule_tx_wake_timer(struct net_device *dev,
+                                            int tx_queue_idx)
 {
-	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
+	struct tile_net_info *info = &per_cpu(per_cpu_info, tx_queue_idx);
 	struct tile_net_priv *priv = netdev_priv(dev);
+	struct tile_net_tx_wake *tx_wake = &info->tx_wake[priv->echannel];
 
-	hrtimer_start(&info->tx_wake[priv->echannel].timer,
+	hrtimer_start(&tx_wake->timer,
 		      ktime_set(0, TX_TIMER_DELAY_USEC * 1000UL),
 		      HRTIMER_MODE_REL_PINNED);
 }
@@ -587,7 +590,7 @@ static enum hrtimer_restart tile_net_handle_tx_wake_timer(struct hrtimer *t)
 {
 	struct tile_net_tx_wake *tx_wake =
 		container_of(t, struct tile_net_tx_wake, timer);
-	netif_wake_subqueue(tx_wake->dev, smp_processor_id());
+	netif_wake_subqueue(tx_wake->dev, tx_wake->tx_queue_idx);
 	return HRTIMER_NORESTART;
 }
 
@@ -1218,6 +1221,7 @@ static int tile_net_open(struct net_device *dev)
 
 		hrtimer_init(&tx_wake->timer, CLOCK_MONOTONIC,
 			     HRTIMER_MODE_REL);
+		tx_wake->tx_queue_idx = cpu;
 		tx_wake->timer.function = tile_net_handle_tx_wake_timer;
 		tx_wake->dev = dev;
 	}
@@ -1291,6 +1295,7 @@ static inline void *tile_net_frag_buf(skb_frag_t *f)
  * stop the queue and schedule the tx_wake timer.
  */
 static s64 tile_net_equeue_try_reserve(struct net_device *dev,
+				       int tx_queue_idx,
 				       struct tile_net_comps *comps,
 				       gxio_mpipe_equeue_t *equeue,
 				       int num_edescs)
@@ -1313,8 +1318,8 @@ static s64 tile_net_equeue_try_reserve(struct net_device *dev,
 	}
 
 	/* Still nothing; give up and stop the queue for a short while. */
-	netif_stop_subqueue(dev, smp_processor_id());
-	tile_net_schedule_tx_wake_timer(dev);
+	netif_stop_subqueue(dev, tx_queue_idx);
+	tile_net_schedule_tx_wake_timer(dev, tx_queue_idx);
 	return -1;
 }
 
@@ -1580,7 +1585,8 @@ static int tile_net_tx_tso(struct sk_buff *skb, struct net_device *dev)
 	local_irq_save(irqflags);
 
 	/* Try to acquire a completion entry and an egress slot. */
-	slot = tile_net_equeue_try_reserve(dev, comps, equeue, num_edescs);
+	slot = tile_net_equeue_try_reserve(dev, skb->queue_mapping, comps,
+					   equeue, num_edescs);
 	if (slot < 0) {
 		local_irq_restore(irqflags);
 		return NETDEV_TX_BUSY;
@@ -1674,7 +1680,8 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 	local_irq_save(irqflags);
 
 	/* Try to acquire a completion entry and an egress slot. */
-	slot = tile_net_equeue_try_reserve(dev, comps, equeue, num_edescs);
+	slot = tile_net_equeue_try_reserve(dev, skb->queue_mapping, comps,
+					   equeue, num_edescs);
 	if (slot < 0) {
 		local_irq_restore(irqflags);
 		return NETDEV_TX_BUSY;
-- 
1.7.10.3
