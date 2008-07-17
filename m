From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 14/31]: niu: Add TX multiqueue support.
Date: Thu, 17 Jul 2008 05:16:53 -0700 (PDT)
Message-ID: <20080717.051653.214436803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/net/niu.c |   45 +++++++++++++++++++++++++--------------------
 1 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index de2a8a3..8ee7d7b 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3236,10 +3236,14 @@ static int release_tx_packet(struct niu *np, struct tx_ring_info *rp, int idx)
 
 static void niu_tx_work(struct niu *np, struct tx_ring_info *rp)
 {
+	struct netdev_queue *txq;
 	u16 pkt_cnt, tmp;
-	int cons;
+	int cons, index;
 	u64 cs;
 
+	index = (rp - np->tx_rings);
+	txq = netdev_get_tx_queue(np->dev, index);
+
 	cs = rp->tx_cs;
 	if (unlikely(!(cs & (TX_CS_MK | TX_CS_MMK))))
 		goto out;
@@ -3262,13 +3266,13 @@ static void niu_tx_work(struct niu *np, struct tx_ring_info *rp)
 	smp_mb();
 
 out:
-	if (unlikely(netif_queue_stopped(np->dev) &&
+	if (unlikely(netif_tx_queue_stopped(txq) &&
 		     (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp)))) {
-		netif_tx_lock(np->dev);
-		if (netif_queue_stopped(np->dev) &&
+		__netif_tx_lock(txq, smp_processor_id());
+		if (netif_tx_queue_stopped(txq) &&
 		    (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp)))
-			netif_wake_queue(np->dev);
-		netif_tx_unlock(np->dev);
+			netif_tx_wake_queue(txq);
+		__netif_tx_unlock(txq);
 	}
 }
 
@@ -4061,6 +4065,8 @@ static int niu_alloc_channels(struct niu *np)
 	np->num_rx_rings = parent->rxchan_per_port[port];
 	np->num_tx_rings = parent->txchan_per_port[port];
 
+	np->dev->real_num_tx_queues = np->num_tx_rings;
+
 	np->rx_rings = kzalloc(np->num_rx_rings * sizeof(struct rx_ring_info),
 			       GFP_KERNEL);
 	err = -ENOMEM;
@@ -5686,7 +5692,7 @@ static int niu_open(struct net_device *dev)
 		goto out_free_irq;
 	}
 
-	netif_start_queue(dev);
+	netif_tx_start_all_queues(dev);
 
 	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
 		netif_carrier_on(dev);
@@ -5710,7 +5716,7 @@ static void niu_full_shutdown(struct niu *np, struct net_device *dev)
 	cancel_work_sync(&np->reset_task);
 
 	niu_disable_napi(np);
-	netif_stop_queue(dev);
+	netif_tx_stop_all_queues(dev);
 
 	del_timer_sync(&np->timer);
 
@@ -5971,7 +5977,7 @@ static void niu_netif_start(struct niu *np)
 	 * so long as all callers are assured to have free tx slots
 	 * (such as after niu_init_hw).
 	 */
-	netif_wake_queue(np->dev);
+	netif_tx_wake_all_queues(np->dev);
 
 	niu_enable_napi(np);
 
@@ -6097,15 +6103,11 @@ static u64 niu_compute_tx_flags(struct sk_buff *skb, struct ethhdr *ehdr,
 	return ret;
 }
 
-static struct tx_ring_info *tx_ring_select(struct niu *np, struct sk_buff *skb)
-{
-	return &np->tx_rings[0];
-}
-
 static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct niu *np = netdev_priv(dev);
 	unsigned long align, headroom;
+	struct netdev_queue *txq;
 	struct tx_ring_info *rp;
 	struct tx_pkt_hdr *tp;
 	unsigned int len, nfg;
@@ -6113,10 +6115,12 @@ static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int prod, i, tlen;
 	u64 mapping, mrk;
 
-	rp = tx_ring_select(np, skb);
+	i = skb_get_queue_mapping(skb);
+	rp = &np->tx_rings[i];
+	txq = netdev_get_tx_queue(dev, i);
 
 	if (niu_tx_avail(rp) <= (skb_shinfo(skb)->nr_frags + 1)) {
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(txq);
 		dev_err(np->device, PFX "%s: BUG! Tx ring full when "
 			"queue awake!\n", dev->name);
 		rp->tx_errors++;
@@ -6215,9 +6219,9 @@ static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	nw64(TX_RING_KICK(rp->tx_channel), rp->wrap_bit | (prod << 3));
 
 	if (unlikely(niu_tx_avail(rp) <= (MAX_SKB_FRAGS + 1))) {
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(txq);
 		if (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp))
-			netif_wake_queue(dev);
+			netif_tx_wake_queue(txq);
 	}
 
 	dev->trans_start = jiffies;
@@ -6275,7 +6279,7 @@ static int niu_change_mtu(struct net_device *dev, int new_mtu)
 	spin_unlock_irq(&np->lock);
 
 	if (!err) {
-		netif_start_queue(dev);
+		netif_tx_start_all_queues(dev);
 		if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
 			netif_carrier_on(dev);
 
@@ -8532,9 +8536,10 @@ static struct net_device * __devinit niu_alloc_and_init(
 	struct of_device *op, const struct niu_ops *ops,
 	u8 port)
 {
-	struct net_device *dev = alloc_etherdev(sizeof(struct niu));
+	struct net_device *dev;
 	struct niu *np;
 
+	dev = alloc_etherdev_mq(sizeof(struct niu), NIU_NUM_TXCHAN);
 	if (!dev) {
 		dev_err(gen_dev, PFX "Etherdev alloc failed, aborting.\n");
 		return NULL;
-- 
1.5.6.2.255.gbed62

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
