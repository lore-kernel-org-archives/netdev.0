From: DDD <Dongdong.deng@windriver.com>
Subject: [PATCH] drivers/net: fixed drivers that support netpoll use
	ndo_start_xmit()
Date: Fri, 14 Aug 2009 13:12:31 +0800
Message-ID: <1250226751.29401.82.camel@dengdd-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Ashfield, Bruce" <Bruce.Ashfield@windriver.com>,
	jason.wessel@windriver.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755108AbZHNFAV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The NETPOLL API requires that interrupts remain disabled in
netpoll_send_skb(). The use of spin_lock_irq() and spin_unlock_irq()
in the NETPOLL API callbacks causes the interrupts to get enabled and
can lead to kernel instability.

The solution is to use spin_lock_irqsave() and spin_unlock_restore()
to prevent the irqs from getting enabled while in netpoll_send_skb().

Call trace:
netpoll_send_skb()
{
   -> local_irq_save(flags)
     ---> dev->ndo_start_xmit(skb, dev)
         ---> spin_lock_irq()
         ---> spin_unlock_irq() *******here would enable the interrupt.
              ...
   -> local_irq_restore(flags)
}

Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
Signed-off-by: Jason Wessel <jason.wessel@windriver.com>
Acked-by: Bruce Ashfield <bruce.ashfield@windriver.com>
---
 drivers/net/b44.c              |    5 +++--
 drivers/net/tulip/tulip_core.c |    5 +++--
 drivers/net/ucc_geth.c         |    5 +++--
 drivers/net/via-rhine.c        |    5 +++--
 4 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 36d4d37..bafca67 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -952,9 +952,10 @@ static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int rc = NETDEV_TX_OK;
 	dma_addr_t mapping;
 	u32 len, entry, ctrl;
+	unsigned long flags;
 
 	len = skb->len;
-	spin_lock_irq(&bp->lock);
+	spin_lock_irqsave(&bp->lock, flags);
 
 	/* This is a hard error, log it. */
 	if (unlikely(TX_BUFFS_AVAIL(bp) < 1)) {
@@ -1027,7 +1028,7 @@ static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 
 out_unlock:
-	spin_unlock_irq(&bp->lock);
+	spin_unlock_irqrestore(&bp->lock, flags);
 
 	return rc;
 
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 99a6364..4cf9a65 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -652,8 +652,9 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int entry;
 	u32 flag;
 	dma_addr_t mapping;
+	unsigned long flags;
 
-	spin_lock_irq(&tp->lock);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	/* Calculate the next Tx descriptor entry. */
 	entry = tp->cur_tx % TX_RING_SIZE;
@@ -688,7 +689,7 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Trigger an immediate transmit demand. */
 	iowrite32(0, tp->base_addr + CSR1);
 
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
 
 	dev->trans_start = jiffies;
 
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 3b957e6..8a7b8c7 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3111,10 +3111,11 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u8 __iomem *bd;			/* BD pointer */
 	u32 bd_status;
 	u8 txQ = 0;
+	unsigned long flags;
 
 	ugeth_vdbg("%s: IN", __func__);
 
-	spin_lock_irq(&ugeth->lock);
+	spin_lock_irqsave(&ugeth->lock, flags);
 
 	dev->stats.tx_bytes += skb->len;
 
@@ -3171,7 +3172,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	uccf = ugeth->uccf;
 	out_be16(uccf->p_utodr, UCC_FAST_TOD);
 #endif
-	spin_unlock_irq(&ugeth->lock);
+	spin_unlock_irqrestore(&ugeth->lock, flags);
 
 	return 0;
 }
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 88c30a5..934f767 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1218,6 +1218,7 @@ static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 	unsigned entry;
+	unsigned long flags;
 
 	/* Caution: the write order is important here, set the field
 	   with the "ownership" bits last. */
@@ -1261,7 +1262,7 @@ static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
 		cpu_to_le32(TXDESC | (skb->len >= ETH_ZLEN ? skb->len : ETH_ZLEN));
 
 	/* lock eth irq */
-	spin_lock_irq(&rp->lock);
+	spin_lock_irqsave(&rp->lock, flags);
 	wmb();
 	rp->tx_ring[entry].tx_status = cpu_to_le32(DescOwn);
 	wmb();
@@ -1280,7 +1281,7 @@ static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
-	spin_unlock_irq(&rp->lock);
+	spin_unlock_irqrestore(&rp->lock, flags);
 
 	if (debug > 4) {
 		printk(KERN_DEBUG "%s: Transmit frame #%d queued in slot %d.\n",
-- 
1.6.0.4
