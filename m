From: Kevin Hilman <khilman@mvista.com>
Subject: [PATCH] SMC91x: Use IRQ save and restore versions of spinlocks
Date: Thu, 24 Jan 2008 15:29:07 -0800
Message-ID: <1201217347-26488-1-git-send-email-khilman@mvista.com>
Cc: Nicolas Pitre <nico@cam.org>, Kevin Hilman <khilman@mvista.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deeprooted.net ([216.254.16.51]:53158 "EHLO paris.hilman.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755926AbYAXXhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 18:37:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under certain circumstances (e.g. kgdb over ethernet), the TX code may
be called with interrupts disabled.  The spin_unlock_irq() calls in
the driver unconditionally re-enable interrupts, which may trigger the
netdev softirq to run and cause spinlock recursion in the net stack.

For example, here's an example path with interrupts disabled:

kgdb exception
  eth_flush_buf
    netpoll_send_udp
      netpoll_send_skb  [ takes netdevice->xmit_lock via netif_tx_trylock() ]
        smc_hard_start_xmit
          smc_hardware_send_pkt
            SMC_ENABLE_INT()
              spin_unlock_irq(&lp->lock)

That spin_unlock_irq() will re-enable interrupts, even if they wer
disabled, thus triggering the netdev softirq to run.  The
dev_watchdog() will try to take the netdevice->xmit_lock which is
currently locked by netpoll_send_skb() and then BUG!

Also, use spin_trylock_irqsave() instead of a wrapped version of
spin_trylock.

Signed-off-by: Kevin Hilman <khilman@mvista.com>
Acked-by: Nicolas Pitre <nico@cam.org>

---
 drivers/net/smc91x.c |   42 ++++++++++++++++++------------------------
 1 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 7da7589..475de0f 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -222,21 +222,21 @@ static void PRINT_PKT(u_char *buf, int length)
 /* this enables an interrupt in the interrupt mask register */
 #define SMC_ENABLE_INT(x) do {						\
 	unsigned char mask;						\
-	spin_lock_irq(&lp->lock);					\
+	spin_lock_irqsave(&lp->lock, flags);				\
 	mask = SMC_GET_INT_MASK();					\
 	mask |= (x);							\
 	SMC_SET_INT_MASK(mask);						\
-	spin_unlock_irq(&lp->lock);					\
+	spin_unlock_irqrestore(&lp->lock, flags);			\
 } while (0)
 
 /* this disables an interrupt from the interrupt mask register */
 #define SMC_DISABLE_INT(x) do {						\
 	unsigned char mask;						\
-	spin_lock_irq(&lp->lock);					\
+	spin_lock_irqsave(&lp->lock, flags);				\
 	mask = SMC_GET_INT_MASK();					\
 	mask &= ~(x);							\
 	SMC_SET_INT_MASK(mask);						\
-	spin_unlock_irq(&lp->lock);					\
+	spin_unlock_irqrestore(&lp->lock, flags);			\
 } while (0)
 
 /*
@@ -547,21 +547,13 @@ static inline void  smc_rcv(struct net_device *dev)
  * any other concurrent access and C would always interrupt B. But life
  * isn't that easy in a SMP world...
  */
-#define smc_special_trylock(lock)					\
-({									\
-	int __ret;							\
-	local_irq_disable();						\
-	__ret = spin_trylock(lock);					\
-	if (!__ret)							\
-		local_irq_enable();					\
-	__ret;								\
-})
-#define smc_special_lock(lock)		spin_lock_irq(lock)
-#define smc_special_unlock(lock)	spin_unlock_irq(lock)
+#define smc_special_trylock(lock, flags) spin_trylock_irqsave(lock, flags)
+#define smc_special_lock(lock, flags)	spin_lock_irqsave(lock, flags)
+#define smc_special_unlock(lock, flags)	spin_unlock_irqrestore(lock, flags)
 #else
-#define smc_special_trylock(lock)	(1)
-#define smc_special_lock(lock)		do { } while (0)
-#define smc_special_unlock(lock)	do { } while (0)
+#define smc_special_trylock(lock,flags)	(1)
+#define smc_special_lock(lock,flags)	do { } while (0)
+#define smc_special_unlock(lock,flags)	do { } while (0)
 #endif
 
 /*
@@ -575,10 +567,11 @@ static void smc_hardware_send_pkt(unsigned long data)
 	struct sk_buff *skb;
 	unsigned int packet_no, len;
 	unsigned char *buf;
+	unsigned long flags;
 
 	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
 
-	if (!smc_special_trylock(&lp->lock)) {
+	if (!smc_special_trylock(&lp->lock, flags)) {
 		netif_stop_queue(dev);
 		tasklet_schedule(&lp->tx_task);
 		return;
@@ -586,7 +579,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 
 	skb = lp->pending_tx_skb;
 	if (unlikely(!skb)) {
-		smc_special_unlock(&lp->lock);
+		smc_special_unlock(&lp->lock, flags);
 		return;
 	}
 	lp->pending_tx_skb = NULL;
@@ -596,7 +589,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 		printk("%s: Memory allocation failed.\n", dev->name);
 		dev->stats.tx_errors++;
 		dev->stats.tx_fifo_errors++;
-		smc_special_unlock(&lp->lock);
+		smc_special_unlock(&lp->lock, flags);
 		goto done;
 	}
 
@@ -635,7 +628,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 
 	/* queue the packet for TX */
 	SMC_SET_MMU_CMD(MC_ENQUEUE);
-	smc_special_unlock(&lp->lock);
+	smc_special_unlock(&lp->lock, flags);
 
 	dev->trans_start = jiffies;
 	dev->stats.tx_packets++;
@@ -660,6 +653,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct smc_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	unsigned int numPages, poll_count, status;
+	unsigned long flags;
 
 	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
 
@@ -685,7 +679,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return 0;
 	}
 
-	smc_special_lock(&lp->lock);
+	smc_special_lock(&lp->lock, flags);
 
 	/* now, try to allocate the memory */
 	SMC_SET_MMU_CMD(MC_ALLOC | numPages);
@@ -703,7 +697,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
    	} while (--poll_count);
 
-	smc_special_unlock(&lp->lock);
+	smc_special_unlock(&lp->lock, flags);
 
 	lp->pending_tx_skb = skb;
    	if (!poll_count) {
-- 
1.5.3.7

