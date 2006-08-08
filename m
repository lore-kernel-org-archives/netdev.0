From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] tg3: Fix tx race condition
Date: Mon, 07 Aug 2006 19:46:26 -0700
Message-ID: <1155005186.5328.13.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:12817 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751212AbWHHCp0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 22:45:26 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a subtle race condition between tg3_start_xmit() and tg3_tx()
discovered by Herbert Xu <herbert@gondor.apana.org.au>:

CPU0					CPU1
tg3_start_xmit()
	if (tx_ring_full) {
		tx_lock
					tg3_tx()
						if (!netif_queue_stopped)
		netif_stop_queue()
		if (!tx_ring_full)
						update_tx_ring 
			netif_wake_queue()
		tx_unlock
	}

Even though tx_ring is updated before the if statement in tg3_tx() in
program order, it can be re-ordered by the CPU as shown above.  This
scenario can cause the tx queue to be stopped forever if tg3_tx() has
just freed up the entire tx_ring.  The possibility of this happening
should be very rare though.

The following changes are made:

1. Add memory barrier to fix the above race condition.

2. Eliminate the private tx_lock altogether and rely solely on
netif_tx_lock.  This eliminates one spinlock in tg3_start_xmit()
when the ring is full.

3. Because of 2, use netif_tx_lock in tg3_tx() before calling
netif_wake_queue().

4. Make tx_cons and tx_prod volatile to guarantee that
tg3_start_xmit() and tg3_tx() will see the latest ring indices.

5. Check for the full wake queue condition before getting
netif_tx_lock in tg3_tx().  This reduces the number of unnecessary
spinlocks when the tx ring is full in a steady-state condition.

6. Update version to 3.65.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6f97962..0eece29 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -68,8 +68,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.64"
-#define DRV_MODULE_RELDATE	"July 31, 2006"
+#define DRV_MODULE_VERSION	"3.65"
+#define DRV_MODULE_RELDATE	"August 07, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -3038,12 +3038,20 @@ static void tg3_tx(struct tg3 *tp)
 
 	tp->tx_cons = sw_idx;
 
-	if (unlikely(netif_queue_stopped(tp->dev))) {
-		spin_lock(&tp->tx_lock);
+	/* Need to make the tx_cons update visible to tg3_start_xmit()
+	 * before checking for netif_queue_stopped().  Without the
+	 * memory barrier, there is a small possibility that tg3_start_xmit()
+	 * will miss it and cause the queue to be stopped forever.
+	 */
+	smp_mb();
+
+	if (unlikely(netif_queue_stopped(tp->dev) &&
+		     (TX_BUFFS_AVAIL(tp) > TG3_TX_WAKEUP_THRESH))) {
+		netif_tx_lock(tp->dev);
 		if (netif_queue_stopped(tp->dev) &&
 		    (TX_BUFFS_AVAIL(tp) > TG3_TX_WAKEUP_THRESH))
 			netif_wake_queue(tp->dev);
-		spin_unlock(&tp->tx_lock);
+		netif_tx_unlock(tp->dev);
 	}
 }
 
@@ -3894,11 +3902,9 @@ static int tg3_start_xmit(struct sk_buff
 
 	tp->tx_prod = entry;
 	if (unlikely(TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1))) {
-		spin_lock(&tp->tx_lock);
 		netif_stop_queue(dev);
 		if (TX_BUFFS_AVAIL(tp) > TG3_TX_WAKEUP_THRESH)
 			netif_wake_queue(tp->dev);
-		spin_unlock(&tp->tx_lock);
 	}
 
 out_unlock:
@@ -4111,11 +4117,9 @@ static int tg3_start_xmit_dma_bug(struct
 
 	tp->tx_prod = entry;
 	if (unlikely(TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1))) {
-		spin_lock(&tp->tx_lock);
 		netif_stop_queue(dev);
 		if (TX_BUFFS_AVAIL(tp) > TG3_TX_WAKEUP_THRESH)
 			netif_wake_queue(tp->dev);
-		spin_unlock(&tp->tx_lock);
 	}
 
 out_unlock:
@@ -11474,7 +11478,6 @@ static int __devinit tg3_init_one(struct
 	tp->grc_mode |= GRC_MODE_BSWAP_NONFRM_DATA;
 #endif
 	spin_lock_init(&tp->lock);
-	spin_lock_init(&tp->tx_lock);
 	spin_lock_init(&tp->indirect_lock);
 	INIT_WORK(&tp->reset_task, tg3_reset_task, tp);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index ba2c987..ee33ac2 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2079,9 +2079,9 @@ struct tg3 {
 	 * lock: Held during reset, PHY access, timer, and when
 	 *       updating tg3_flags and tg3_flags2.
 	 *
-	 * tx_lock: Held during tg3_start_xmit and tg3_tx only
-	 *          when calling netif_[start|stop]_queue.
-	 *          tg3_start_xmit is protected by netif_tx_lock.
+	 * netif_tx_lock: Held during tg3_start_xmit. tg3_tx holds
+	 *                netif_tx_lock when it needs to call
+	 *                netif_wake_queue.
 	 *
 	 * Both of these locks are to be held with BH safety.
 	 *
@@ -2114,12 +2114,10 @@ struct tg3 {
 	/* begin "tx thread" cacheline section */
 	void				(*write32_tx_mbox) (struct tg3 *, u32,
 							    u32);
-	u32				tx_prod;
-	u32				tx_cons;
+	volatile u32			tx_prod;
+	volatile u32			tx_cons;
 	u32				tx_pending;
 
-	spinlock_t			tx_lock;
-
 	struct tg3_tx_buffer_desc	*tx_ring;
 	struct tx_ring_info		*tx_buffers;
 	dma_addr_t			tx_desc_mapping;


