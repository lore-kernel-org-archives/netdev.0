From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/2] [BNX2]: Fix tx race condition
Date: Thu, 10 Aug 2006 17:14:36 -0700
Message-ID: <1155255276.11815.3.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:16 "EHLO mms1.broadcom.com")
	by vger.kernel.org with ESMTP id S932368AbWHKAOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 20:14:02 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix tx race condition.

Fix a subtle race condition between bnx2_start_xmit() and bnx2_tx_int()
similar to the one in tg3 discovered by Herbert Xu:

CPU0					CPU1
bnx2_start_xmit()
	if (tx_ring_full) {
		tx_lock
					bnx2_tx()
						if (!netif_queue_stopped)
		netif_stop_queue()
		if (!tx_ring_full)
						update_tx_ring 
			netif_wake_queue()
		tx_unlock
	}

Even though tx_ring is updated before the if statement in bnx2_tx_int() in
program order, it can be re-ordered by the CPU as shown above.  This
scenario can cause the tx queue to be stopped forever if bnx2_tx_int() has
just freed up the entire tx_ring.  The possibility of this happening
should be very rare though.

The following changes are made, very much identical to the tg3 fix:

1. Add memory barrier to fix the above race condition.

2. Eliminate the private tx_lock altogether and rely solely on
netif_tx_lock.  This eliminates one spinlock in bnx2_start_xmit()
when the ring is full.

3. Because of 2, use netif_tx_lock in bnx2_tx_int() before calling
netif_wake_queue().

4. Add memory barrier to bnx2_tx_avail().

5. Add bp->tx_wake_thresh which is set to half the tx ring size.

6. Check for the full wake queue condition before getting
netif_tx_lock in tg3_tx().  This reduces the number of unnecessary
spinlocks when the tx ring is full in a steady-state condition.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index db73de0..2099edb 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -209,8 +209,10 @@ MODULE_DEVICE_TABLE(pci, bnx2_pci_tbl);
 
 static inline u32 bnx2_tx_avail(struct bnx2 *bp)
 {
-	u32 diff = TX_RING_IDX(bp->tx_prod) - TX_RING_IDX(bp->tx_cons);
+	u32 diff;
 
+	smp_mb();
+	diff = TX_RING_IDX(bp->tx_prod) - TX_RING_IDX(bp->tx_cons);
 	if (diff > MAX_TX_DESC_CNT)
 		diff = (diff & MAX_TX_DESC_CNT) - 1;
 	return (bp->tx_ring_size - diff);
@@ -1686,15 +1688,20 @@ bnx2_tx_int(struct bnx2 *bp)
 	}
 
 	bp->tx_cons = sw_cons;
+	/* Need to make the tx_cons update visible to bnx2_start_xmit()
+	 * before checking for netif_queue_stopped().  Without the
+	 * memory barrier, there is a small possibility that bnx2_start_xmit()
+	 * will miss it and cause the queue to be stopped forever.
+	 */
+	smp_mb();
 
-	if (unlikely(netif_queue_stopped(bp->dev))) {
-		spin_lock(&bp->tx_lock);
+	if (unlikely(netif_queue_stopped(bp->dev)) &&
+		     (bnx2_tx_avail(bp) > bp->tx_wake_thresh)) {
+		netif_tx_lock(bp->dev);
 		if ((netif_queue_stopped(bp->dev)) &&
-		    (bnx2_tx_avail(bp) > MAX_SKB_FRAGS)) {
-
+		    (bnx2_tx_avail(bp) > bp->tx_wake_thresh))
 			netif_wake_queue(bp->dev);
-		}
-		spin_unlock(&bp->tx_lock);
+		netif_tx_unlock(bp->dev);
 	}
 }
 
@@ -3503,6 +3510,8 @@ bnx2_init_tx_ring(struct bnx2 *bp)
 	struct tx_bd *txbd;
 	u32 val;
 
+	bp->tx_wake_thresh = bp->tx_ring_size / 2;
+
 	txbd = &bp->tx_desc_ring[MAX_TX_DESC_CNT];
 		
 	txbd->tx_bd_haddr_hi = (u64) bp->tx_desc_mapping >> 32;
@@ -4390,10 +4399,8 @@ bnx2_vlan_rx_kill_vid(struct net_device 
 #endif
 
 /* Called with netif_tx_lock.
- * hard_start_xmit is pseudo-lockless - a lock is only required when
- * the tx queue is full. This way, we get the benefit of lockless
- * operations most of the time without the complexities to handle
- * netif_stop_queue/wake_queue race conditions.
+ * bnx2_tx_int() runs without netif_tx_lock unless it needs to call
+ * netif_wake_queue().
  */
 static int
 bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -4512,12 +4519,9 @@ bnx2_start_xmit(struct sk_buff *skb, str
 	dev->trans_start = jiffies;
 
 	if (unlikely(bnx2_tx_avail(bp) <= MAX_SKB_FRAGS)) {
-		spin_lock(&bp->tx_lock);
 		netif_stop_queue(dev);
-		
-		if (bnx2_tx_avail(bp) > MAX_SKB_FRAGS)
+		if (bnx2_tx_avail(bp) > bp->tx_wake_thresh)
 			netif_wake_queue(dev);
-		spin_unlock(&bp->tx_lock);
 	}
 
 	return NETDEV_TX_OK;
@@ -5628,7 +5632,6 @@ bnx2_init_board(struct pci_dev *pdev, st
 	bp->pdev = pdev;
 
 	spin_lock_init(&bp->phy_lock);
-	spin_lock_init(&bp->tx_lock);
 	INIT_WORK(&bp->reset_task, bnx2_reset_task, bp);
 
 	dev->base_addr = dev->mem_start = pci_resource_start(pdev, 0);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 658c5ee..fe80476 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -3890,10 +3890,6 @@ struct bnx2 {
 	u32		tx_prod_bseq __attribute__((aligned(L1_CACHE_BYTES)));
 	u16		tx_prod;
 
-	struct tx_bd	*tx_desc_ring;
-	struct sw_bd	*tx_buf_ring;
-	int		tx_ring_size;
-
 	u16		tx_cons __attribute__((aligned(L1_CACHE_BYTES)));
 	u16		hw_tx_cons;
 
@@ -3916,9 +3912,11 @@ struct bnx2 {
 	struct sw_bd		*rx_buf_ring;
 	struct rx_bd		*rx_desc_ring[MAX_RX_RINGS];
 
-	/* Only used to synchronize netif_stop_queue/wake_queue when tx */
-	/* ring is full */
-	spinlock_t		tx_lock;
+	/* TX constants */
+	struct tx_bd	*tx_desc_ring;
+	struct sw_bd	*tx_buf_ring;
+	int		tx_ring_size;
+	u32		tx_wake_thresh;
 
 	/* End of fields used in the performance code paths. */
 


