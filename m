From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] netdevice: fix sparse warning for HARD_TX_LOCK
Date: Thu, 24 Nov 2016 07:04:08 +0200
Message-ID: <1479963754-24105-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sparse warns about context imbalance in any code
that uses HARD_TX_LOCK/UNLOCK - this is because it's
unable to determine that flags don't change so
lock and unlock are paired.

Seems easy enough to fix by adding __acquire/__release
calls.

With this patch af_packet.c is now sparse-clean,

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

compile-tested only.

 include/linux/netdevice.h | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 91ee364..0a58a50 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3539,6 +3539,17 @@ static inline void __netif_tx_lock(struct netdev_queue *txq, int cpu)
 	txq->xmit_lock_owner = cpu;
 }
 
+static inline bool __netif_tx_acquire(struct netdev_queue *txq)
+{
+	__acquire(&txq->_xmit_lock);
+	return true;
+}
+
+static inline void __netif_tx_release(struct netdev_queue *txq)
+{
+	__release(&txq->_xmit_lock);
+}
+
 static inline void __netif_tx_lock_bh(struct netdev_queue *txq)
 {
 	spin_lock_bh(&txq->_xmit_lock);
@@ -3640,17 +3651,21 @@ static inline void netif_tx_unlock_bh(struct net_device *dev)
 #define HARD_TX_LOCK(dev, txq, cpu) {			\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
 		__netif_tx_lock(txq, cpu);		\
+	} else {					\
+		__netif_tx_acquire(txq);		\
 	}						\
 }
 
 #define HARD_TX_TRYLOCK(dev, txq)			\
 	(((dev->features & NETIF_F_LLTX) == 0) ?	\
 		__netif_tx_trylock(txq) :		\
-		true )
+		__netif_tx_acquire(txq))
 
 #define HARD_TX_UNLOCK(dev, txq) {			\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
 		__netif_tx_unlock(txq);			\
+	} else {					\
+		__netif_tx_release(txq);		\
 	}						\
 }
 
-- 
MST
