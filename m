From: DDD <Dongdong.deng@windriver.com>
Subject: [PATCH] [net] smc91x: let smc91x work well under netpoll
Date: Mon, 24 Aug 2009 11:42:31 +0800
Message-ID: <1251085351.6588.21.camel@dengdd-desktop>
References: <1250861616.24178.20.camel@dengdd-desktop>
	 <1250862005.24178.28.camel@dengdd-desktop>
	 <alpine.LFD.2.00.0908211304000.6044@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Jason Wessel <jason.wessel@windriver.com>
To: Nicolas Pitre <nico@cam.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40816 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbZHXDaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2009 23:30:17 -0400
In-Reply-To: <alpine.LFD.2.00.0908211304000.6044@xanadu.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NETPOLL requires that interrupts remain disabled in its callbacks.

Using *_irq_save()/irq_restore() to replace *_irq_disable()/irq_enable()
functions in NETPOLL's callbacks of smc91x, so that it doesn't enable
interrupts when already disabled, and kgdboe/netconsole would work
properly over smc91x.

Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
Acked-by: Nicolas Pitre <nico@cam.org>
---
 drivers/net/smc91x.c |   40 ++++++++++++++++++++++------------------
 1 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 1c70e99..9da1fa1 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -196,21 +196,23 @@ static void PRINT_PKT(u_char *buf, int length)
 /* this enables an interrupt in the interrupt mask register */
 #define SMC_ENABLE_INT(lp, x) do {					\
 	unsigned char mask;						\
-	spin_lock_irq(&lp->lock);					\
+	unsigned long smc_enable_flags;					\
+	spin_lock_irqsave(&lp->lock, smc_enable_flags);			\
 	mask = SMC_GET_INT_MASK(lp);					\
 	mask |= (x);							\
 	SMC_SET_INT_MASK(lp, mask);					\
-	spin_unlock_irq(&lp->lock);					\
+	spin_unlock_irqrestore(&lp->lock, smc_enable_flags);		\
 } while (0)
 
 /* this disables an interrupt from the interrupt mask register */
 #define SMC_DISABLE_INT(lp, x) do {					\
 	unsigned char mask;						\
-	spin_lock_irq(&lp->lock);					\
+	unsigned long smc_disable_flags;				\
+	spin_lock_irqsave(&lp->lock, smc_disable_flags);		\
 	mask = SMC_GET_INT_MASK(lp);					\
 	mask &= ~(x);							\
 	SMC_SET_INT_MASK(lp, mask);					\
-	spin_unlock_irq(&lp->lock);					\
+	spin_unlock_irqrestore(&lp->lock, smc_disable_flags);		\
 } while (0)
 
 /*
@@ -520,21 +522,21 @@ static inline void  smc_rcv(struct net_device *dev)
  * any other concurrent access and C would always interrupt B. But life
  * isn't that easy in a SMP world...
  */
-#define smc_special_trylock(lock)					\
+#define smc_special_trylock(lock, flags)				\
 ({									\
 	int __ret;							\
-	local_irq_disable();						\
+	local_irq_save(flags);						\
 	__ret = spin_trylock(lock);					\
 	if (!__ret)							\
-		local_irq_enable();					\
+		local_irq_restore(flags);				\
 	__ret;								\
 })
-#define smc_special_lock(lock)		spin_lock_irq(lock)
-#define smc_special_unlock(lock)	spin_unlock_irq(lock)
+#define smc_special_lock(lock, flags)		spin_lock_irq(lock, flags)
+#define smc_special_unlock(lock, flags) 	spin_unlock_irqrestore(lock, flags)
 #else
-#define smc_special_trylock(lock)	(1)
-#define smc_special_lock(lock)		do { } while (0)
-#define smc_special_unlock(lock)	do { } while (0)
+#define smc_special_trylock(lock, flags)	(1)
+#define smc_special_lock(lock, flags)   	do { } while (0)
+#define smc_special_unlock(lock, flags)	do { } while (0)
 #endif
 
 /*
@@ -548,10 +550,11 @@ static void smc_hardware_send_pkt(unsigned long data)
 	struct sk_buff *skb;
 	unsigned int packet_no, len;
 	unsigned char *buf;
+	unsigned long flags;
 
 	DBG(3, "%s: %s\n", dev->name, __func__);
 
-	if (!smc_special_trylock(&lp->lock)) {
+	if (!smc_special_trylock(&lp->lock, flags)) {
 		netif_stop_queue(dev);
 		tasklet_schedule(&lp->tx_task);
 		return;
@@ -559,7 +562,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 
 	skb = lp->pending_tx_skb;
 	if (unlikely(!skb)) {
-		smc_special_unlock(&lp->lock);
+		smc_special_unlock(&lp->lock, flags);
 		return;
 	}
 	lp->pending_tx_skb = NULL;
@@ -569,7 +572,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 		printk("%s: Memory allocation failed.\n", dev->name);
 		dev->stats.tx_errors++;
 		dev->stats.tx_fifo_errors++;
-		smc_special_unlock(&lp->lock);
+		smc_special_unlock(&lp->lock, flags);
 		goto done;
 	}
 
@@ -608,7 +611,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 
 	/* queue the packet for TX */
 	SMC_SET_MMU_CMD(lp, MC_ENQUEUE);
-	smc_special_unlock(&lp->lock);
+	smc_special_unlock(&lp->lock, flags);
 
 	dev->trans_start = jiffies;
 	dev->stats.tx_packets++;
@@ -633,6 +636,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct smc_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	unsigned int numPages, poll_count, status;
+	unsigned long flags;
 
 	DBG(3, "%s: %s\n", dev->name, __func__);
 
@@ -658,7 +662,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return 0;
 	}
 
-	smc_special_lock(&lp->lock);
+	smc_special_lock(&lp->lock, flags);
 
 	/* now, try to allocate the memory */
 	SMC_SET_MMU_CMD(lp, MC_ALLOC | numPages);
@@ -676,7 +680,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
    	} while (--poll_count);
 
-	smc_special_unlock(&lp->lock);
+	smc_special_unlock(&lp->lock, flags);
 
 	lp->pending_tx_skb = skb;
    	if (!poll_count) {
-- 
1.6.0.4


