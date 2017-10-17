From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 43/58] net: ethernet: apple: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:27 -0700
Message-ID: <1508200182-104605-44-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Jarod Wilson <jarod@redhat.com>, Rob Herring <robh@kernel.org>,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Rob Herring <robh@kernel.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/apple/bmac.c | 12 +++++-------
 drivers/net/ethernet/apple/mace.c | 12 +++++-------
 2 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index eac740c476ce..5a655d289dd5 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -157,7 +157,7 @@ static irqreturn_t bmac_misc_intr(int irq, void *dev_id);
 static irqreturn_t bmac_txdma_intr(int irq, void *dev_id);
 static irqreturn_t bmac_rxdma_intr(int irq, void *dev_id);
 static void bmac_set_timeout(struct net_device *dev);
-static void bmac_tx_timeout(unsigned long data);
+static void bmac_tx_timeout(struct timer_list *t);
 static int bmac_output(struct sk_buff *skb, struct net_device *dev);
 static void bmac_start(struct net_device *dev);
 
@@ -555,8 +555,6 @@ static inline void bmac_set_timeout(struct net_device *dev)
 	if (bp->timeout_active)
 		del_timer(&bp->tx_timeout);
 	bp->tx_timeout.expires = jiffies + TX_TIMEOUT;
-	bp->tx_timeout.function = bmac_tx_timeout;
-	bp->tx_timeout.data = (unsigned long) dev;
 	add_timer(&bp->tx_timeout);
 	bp->timeout_active = 1;
 	spin_unlock_irqrestore(&bp->lock, flags);
@@ -1321,7 +1319,7 @@ static int bmac_probe(struct macio_dev *mdev, const struct of_device_id *match)
 	bp->queue = (struct sk_buff_head *)(bp->rx_cmds + N_RX_RING + 1);
 	skb_queue_head_init(bp->queue);
 
-	init_timer(&bp->tx_timeout);
+	timer_setup(&bp->tx_timeout, bmac_tx_timeout, 0);
 
 	ret = request_irq(dev->irq, bmac_misc_intr, 0, "BMAC-misc", dev);
 	if (ret) {
@@ -1471,10 +1469,10 @@ bmac_output(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static void bmac_tx_timeout(unsigned long data)
+static void bmac_tx_timeout(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct bmac_data *bp = netdev_priv(dev);
+	struct bmac_data *bp = from_timer(bp, t, tx_timeout);
+	struct net_device *dev = macio_get_drvdata(bp->mdev);
 	volatile struct dbdma_regs __iomem *td = bp->tx_dma;
 	volatile struct dbdma_regs __iomem *rd = bp->rx_dma;
 	volatile struct dbdma_cmd *cp;
diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index e58b157b7d7c..0b5429d76bcf 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -86,7 +86,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id);
 static irqreturn_t mace_txdma_intr(int irq, void *dev_id);
 static irqreturn_t mace_rxdma_intr(int irq, void *dev_id);
 static void mace_set_timeout(struct net_device *dev);
-static void mace_tx_timeout(unsigned long data);
+static void mace_tx_timeout(struct timer_list *t);
 static inline void dbdma_reset(volatile struct dbdma_regs __iomem *dma);
 static inline void mace_clean_rings(struct mace_data *mp);
 static void __mace_set_address(struct net_device *dev, void *addr);
@@ -196,7 +196,7 @@ static int mace_probe(struct macio_dev *mdev, const struct of_device_id *match)
 
 	memset((char *) mp->tx_cmds, 0,
 	       (NCMDS_TX*N_TX_RING + N_RX_RING + 2) * sizeof(struct dbdma_cmd));
-	init_timer(&mp->tx_timeout);
+	timer_setup(&mp->tx_timeout, mace_tx_timeout, 0);
 	spin_lock_init(&mp->lock);
 	mp->timeout_active = 0;
 
@@ -521,8 +521,6 @@ static inline void mace_set_timeout(struct net_device *dev)
     if (mp->timeout_active)
 	del_timer(&mp->tx_timeout);
     mp->tx_timeout.expires = jiffies + TX_TIMEOUT;
-    mp->tx_timeout.function = mace_tx_timeout;
-    mp->tx_timeout.data = (unsigned long) dev;
     add_timer(&mp->tx_timeout);
     mp->timeout_active = 1;
 }
@@ -801,10 +799,10 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
     return IRQ_HANDLED;
 }
 
-static void mace_tx_timeout(unsigned long data)
+static void mace_tx_timeout(struct timer_list *t)
 {
-    struct net_device *dev = (struct net_device *) data;
-    struct mace_data *mp = netdev_priv(dev);
+    struct mace_data *mp = from_timer(mp, t, tx_timeout);
+    struct net_device *dev = macio_get_drvdata(mp->mdev);
     volatile struct mace __iomem *mb = mp->mace;
     volatile struct dbdma_regs __iomem *td = mp->tx_dma;
     volatile struct dbdma_regs __iomem *rd = mp->rx_dma;
-- 
2.7.4
