From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.18 2/3] tg3: Convert to non-LLTX
Date: Mon, 05 Jun 2006 12:47:32 -0700
Message-ID: <1149536852.13155.7.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:13580 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1750955AbWFEVaI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 17:30:08 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu pointed out that it is unsafe to call netif_tx_disable()
from LLTX drivers because it uses dev->xmit_lock to synchronize
whereas LLTX drivers use private locks.

Convert tg3 to non-LLTX to fix this issue. tg3 is a lockless driver
where hard_start_xmit and tx completion handling can run concurrently
under normal conditions. A tx_lock is only needed to prevent
netif_stop_queue and netif_wake_queue race condtions when the queue
is full.

So whether we use LLTX or non-LLTX, it makes practically no
difference.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4cda2af..f085890 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3759,14 +3759,11 @@ static int tg3_start_xmit(struct sk_buff
 
 	len = skb_headlen(skb);
 
-	/* No BH disabling for tx_lock here.  We are running in BH disabled
-	 * context and TX reclaim runs via tp->poll inside of a software
+	/* We are running in BH disabled context with netif_tx_lock
+	 * and TX reclaim runs via tp->poll inside of a software
 	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
 	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
-	if (!spin_trylock(&tp->tx_lock))
-		return NETDEV_TX_LOCKED;
-
 	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
@@ -3775,7 +3772,6 @@ static int tg3_start_xmit(struct sk_buff
 			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
 			       "queue awake!\n", dev->name);
 		}
-		spin_unlock(&tp->tx_lock);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -3858,15 +3854,16 @@ static int tg3_start_xmit(struct sk_buff
 	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
 
 	tp->tx_prod = entry;
-	if (TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1)) {
+	if (unlikely(TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1))) {
+		spin_lock(&tp->tx_lock);
 		netif_stop_queue(dev);
 		if (TX_BUFFS_AVAIL(tp) > TG3_TX_WAKEUP_THRESH)
 			netif_wake_queue(tp->dev);
+		spin_unlock(&tp->tx_lock);
 	}
 
 out_unlock:
     	mmiowb();
-	spin_unlock(&tp->tx_lock);
 
 	dev->trans_start = jiffies;
 
@@ -3885,14 +3882,11 @@ static int tg3_start_xmit_dma_bug(struct
 
 	len = skb_headlen(skb);
 
-	/* No BH disabling for tx_lock here.  We are running in BH disabled
-	 * context and TX reclaim runs via tp->poll inside of a software
+	/* We are running in BH disabled context with netif_tx_lock
+	 * and TX reclaim runs via tp->poll inside of a software
 	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
 	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
-	if (!spin_trylock(&tp->tx_lock))
-		return NETDEV_TX_LOCKED; 
-
 	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
@@ -3901,7 +3895,6 @@ static int tg3_start_xmit_dma_bug(struct
 			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
 			       "queue awake!\n", dev->name);
 		}
-		spin_unlock(&tp->tx_lock);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -4039,15 +4032,16 @@ static int tg3_start_xmit_dma_bug(struct
 	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
 
 	tp->tx_prod = entry;
-	if (TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1)) {
+	if (unlikely(TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1))) {
+		spin_lock(&tp->tx_lock);
 		netif_stop_queue(dev);
 		if (TX_BUFFS_AVAIL(tp) > TG3_TX_WAKEUP_THRESH)
 			netif_wake_queue(tp->dev);
+		spin_unlock(&tp->tx_lock);
 	}
 
 out_unlock:
     	mmiowb();
-	spin_unlock(&tp->tx_lock);
 
 	dev->trans_start = jiffies;
 
@@ -11332,7 +11326,6 @@ static int __devinit tg3_init_one(struct
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	dev->features |= NETIF_F_LLTX;
 #if TG3_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = tg3_vlan_rx_register;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 7f22559..6a067de 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2074,12 +2074,22 @@ struct tg3 {
 
 	/* SMP locking strategy:
 	 *
-	 * lock: Held during all operations except TX packet
-	 *       processing.
+	 * lock: Held during reset, PHY access, timer, and when
+	 *       updating tg3_flags and tg3_flags2.
 	 *
-	 * tx_lock: Held during tg3_start_xmit and tg3_tx
+	 * tx_lock: Held during tg3_start_xmit and tg3_tx only
+	 *          when calling netif_[start|stop]_queue.
+	 *          tg3_start_xmit is protected by netif_tx_lock.
 	 *
 	 * Both of these locks are to be held with BH safety.
+	 *
+	 * Because the IRQ handler, tg3_poll, and tg3_start_xmit
+	 * are running lockless, it is necessary to completely
+	 * quiesce the chip with tg3_netif_stop and tg3_full_lock
+	 * before reconfiguring the device.
+	 *
+	 * indirect_lock: Held when accessing registers indirectly
+	 *                with IRQ disabling.
 	 */
 	spinlock_t			lock;
 	spinlock_t			indirect_lock;


