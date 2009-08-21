From: DDD <Dongdong.deng@windriver.com>
Subject: [PATCH 2/2] drivers/net: fixed drivers that support netpoll use
	ndo_start_xmit()
Date: Fri, 21 Aug 2009 21:34:53 +0800
Message-ID: <1250861693.24178.22.camel@dengdd-desktop>
References: <1250861616.24178.20.camel@dengdd-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Jason Wessel <jason.wessel@windriver.com>
To: Matt Mackall <mpm@selenic.com>, David Miller <davem@davemloft.net>,
	Nicolas Pitre <nico@cam.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755426AbZHUNWj@vger.kernel.org>
In-Reply-To: <1250861616.24178.20.camel@dengdd-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The NETPOLL API requires that interrupts remain disabled in
netpoll_send_skb(). The use of "A functions set" in the NETPOLL API
callbacks causes the interrupts to get enabled and can lead to kernel
instability.

The solution is to use "B functions set" to prevent the irqs from
getting enabled while in netpoll_send_skb().

A functions set:
local_irq_disable()/local_irq_enable()
spin_lock_irq()/spin_unlock_irq()
spin_trylock_irq()/spin_unlock_irq()

B functions set:
local_irq_save()/local_irq_restore()
spin_lock_irqsave()/spin_unlock_irqrestore()
spin_trylock_irqsave()/spin_unlock_irqrestore()

Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
---
 drivers/net/fec_mpc52xx.c    |    5 +++--
 drivers/net/ixp2000/ixpdev.c |    5 +++--
 drivers/net/macb.c           |    7 ++++---
 drivers/net/mlx4/en_tx.c     |    5 +++--
 4 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index cc78633..c40113f 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -309,6 +309,7 @@ static int mpc52xx_fec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
 	struct bcom_fec_bd *bd;
+	unsigned long flags;
 
 	if (bcom_queue_full(priv->tx_dmatsk)) {
 		if (net_ratelimit())
@@ -316,7 +317,7 @@ static int mpc52xx_fec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	spin_lock_irq(&priv->lock);
+	spin_lock_irqsave(&priv->lock, flags);
 	dev->trans_start = jiffies;
 
 	bd = (struct bcom_fec_bd *)
@@ -332,7 +333,7 @@ static int mpc52xx_fec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 	}
 
-	spin_unlock_irq(&priv->lock);
+	spin_unlock_irqrestore(&priv->lock, flags);
 
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index 2a0174b..92fb823 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -41,6 +41,7 @@ static int ixpdev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct ixpdev_priv *ip = netdev_priv(dev);
 	struct ixpdev_tx_desc *desc;
 	int entry;
+	unsigned long flags;
 
 	if (unlikely(skb->len > PAGE_SIZE)) {
 		/* @@@ Count drops.  */
@@ -63,11 +64,11 @@ static int ixpdev_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
-	local_irq_disable();
+	local_irq_save(flags);
 	ip->tx_queue_entries++;
 	if (ip->tx_queue_entries == TX_BUF_COUNT_PER_CHAN)
 		netif_stop_queue(dev);
-	local_irq_enable();
+	local_irq_restore(flags);
 
 	return 0;
 }
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 5b5c253..e3601cf 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -620,6 +620,7 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dma_addr_t mapping;
 	unsigned int len, entry;
 	u32 ctrl;
+	unsigned long flags;
 
 #ifdef DEBUG
 	int i;
@@ -635,12 +636,12 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 
 	len = skb->len;
-	spin_lock_irq(&bp->lock);
+	spin_lock_irqsave(&bp->lock, flags);
 
 	/* This is a hard error, log it. */
 	if (TX_BUFFS_AVAIL(bp) < 1) {
 		netif_stop_queue(dev);
-		spin_unlock_irq(&bp->lock);
+		spin_unlock_irqrestore(&bp->lock, flags);
 		dev_err(&bp->pdev->dev,
 			"BUG! Tx Ring full when queue awake!\n");
 		dev_dbg(&bp->pdev->dev, "tx_head = %u, tx_tail = %u\n",
@@ -674,7 +675,7 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (TX_BUFFS_AVAIL(bp) < 1)
 		netif_stop_queue(dev);
 
-	spin_unlock_irq(&bp->lock);
+	spin_unlock_irqrestore(&bp->lock, flags);
 
 	dev->trans_start = jiffies;
 
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 5a88b3f..0077d37 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -435,6 +435,7 @@ static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
 
 static inline void mlx4_en_xmit_poll(struct mlx4_en_priv *priv, int tx_ind)
 {
+	unsigned long flags;
 	struct mlx4_en_cq *cq = &priv->tx_cq[tx_ind];
 	struct mlx4_en_tx_ring *ring = &priv->tx_ring[tx_ind];
 
@@ -445,9 +446,9 @@ static inline void mlx4_en_xmit_poll(struct mlx4_en_priv *priv, int tx_ind)
 
 	/* Poll the CQ every mlx4_en_TX_MODER_POLL packets */
 	if ((++ring->poll_cnt & (MLX4_EN_TX_POLL_MODER - 1)) == 0)
-		if (spin_trylock_irq(&ring->comp_lock)) {
+		if (spin_trylock_irqsave(&ring->comp_lock, flags)) {
 			mlx4_en_process_tx_cq(priv->dev, cq);
-			spin_unlock_irq(&ring->comp_lock);
+			spin_unlock_irqrestore(&ring->comp_lock, flags);
 		}
 }
 
-- 
1.6.0.4
