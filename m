From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH v2] tg3: Fix tx race condition
Date: Mon, 07 Aug 2006 21:10:14 -0700
Message-ID: <1155010214.5328.27.camel@rh4>
References: <1155005186.5328.13.camel@rh4>
 <20060808025117.GA13077@gondor.apana.org.au>
 <1155006336.5328.24.camel@rh4>
 <20060807.200556.40833596.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:51716 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932452AbWHHEJT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 00:09:19 -0400
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060807.200556.40833596.davem@davemloft.net>
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

4. Change TX_BUFFS_AVAIL to an inline function with a memory barrier.
Herbert and David suggested using the memory barrier instead of
volatile.

5. Check for the full wake queue condition before getting
netif_tx_lock in tg3_tx().  This reduces the number of unnecessary
spinlocks when the tx ring is full in a steady-state condition.

6. Update version to 3.65.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6f97962..b72c138 100644
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
@@ -123,9 +123,6 @@
 			           TG3_RX_RCB_RING_SIZE(tp))
 #define TG3_TX_RING_BYTES	(sizeof(struct tg3_tx_buffer_desc) * \
 				 TG3_TX_RING_SIZE)
-#define TX_BUFFS_AVAIL(TP)						\
-	((TP)->tx_pending -						\
-	 (((TP)->tx_prod - (TP)->tx_cons) & (TG3_TX_RING_SIZE - 1)))
 #define NEXT_TX(N)		(((N) + 1) & (TG3_TX_RING_SIZE - 1))
 
 #define RX_PKT_BUF_SZ		(1536 + tp->rx_offset + 64)
@@ -2987,6 +2984,13 @@ static void tg3_tx_recover(struct tg3 *t
 	spin_unlock(&tp->lock);
 }
 
+static inline u32 tg3_tx_avail(struct tg3 *tp)
+{
+	smp_mb();
+	return (tp->tx_pending -
+		((tp->tx_prod - tp->tx_cons) & (TG3_TX_RING_SIZE - 1)));
+}
+
 /* Tigon3 never reports partial packet sends.  So we do not
  * need special logic to handle SKBs that have not had all
  * of their frags sent yet, like SunGEM does.
@@ -3038,12 +3042,20 @@ static void tg3_tx(struct tg3 *tp)
 
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
+		     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH))) {
+		netif_tx_lock(tp->dev);
 		if (netif_queue_stopped(tp->dev) &&
-		    (TX_BUFFS_AVAIL(tp) > TG3_TX_WAKEUP_THRESH))
+		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH))
 			netif_wake_queue(tp->dev);
-		spin_unlock(&tp->tx_lock);
+		netif_tx_unlock(tp->dev);
 	}
 }
 
@@ -3797,7 +3809,7 @@ static int tg3_start_xmit(struct sk_buff
 	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
 	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
-	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
 
@@ -3893,12 +3905,10 @@ static int tg3_start_xmit(struct sk_buff
 	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
 
 	tp->tx_prod = entry;
-	if (unlikely(TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1))) {
-		spin_lock(&tp->tx_lock);
+	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
 		netif_stop_queue(dev);
-		if (TX_BUFFS_AVAIL(tp) > TG3_TX_WAKEUP_THRESH)
+		if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH)
 			netif_wake_queue(tp->dev);
-		spin_unlock(&tp->tx_lock);
 	}
 
 out_unlock:
@@ -3920,7 +3930,7 @@ static int tg3_tso_bug(struct tg3 *tp, s
 	struct sk_buff *segs, *nskb;
 
 	/* Estimate the number of fragments in the worst case */
-	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->gso_segs * 3))) {
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))) {
 		netif_stop_queue(tp->dev);
 		return NETDEV_TX_BUSY;
 	}
@@ -3960,7 +3970,7 @@ static int tg3_start_xmit_dma_bug(struct
 	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
 	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
-	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
 
@@ -4110,12 +4120,10 @@ static int tg3_start_xmit_dma_bug(struct
 	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
 
 	tp->tx_prod = entry;
-	if (unlikely(TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1))) {
-		spin_lock(&tp->tx_lock);
+	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
 		netif_stop_queue(dev);
-		if (TX_BUFFS_AVAIL(tp) > TG3_TX_WAKEUP_THRESH)
+		if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH)
 			netif_wake_queue(tp->dev);
-		spin_unlock(&tp->tx_lock);
 	}
 
 out_unlock:
@@ -11474,7 +11482,6 @@ static int __devinit tg3_init_one(struct
 	tp->grc_mode |= GRC_MODE_BSWAP_NONFRM_DATA;
 #endif
 	spin_lock_init(&tp->lock);
-	spin_lock_init(&tp->tx_lock);
 	spin_lock_init(&tp->indirect_lock);
 	INIT_WORK(&tp->reset_task, tg3_reset_task, tp);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index ba2c987..3ecf356 100644
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
@@ -2118,8 +2118,6 @@ struct tg3 {
 	u32				tx_cons;
 	u32				tx_pending;
 
-	spinlock_t			tx_lock;
-
 	struct tg3_tx_buffer_desc	*tx_ring;
 	struct tx_ring_info		*tx_buffers;
 	dma_addr_t			tx_desc_mapping;


