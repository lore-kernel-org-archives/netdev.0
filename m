From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/6] atl1c: remove private tx lock
Date: Sun, 24 Apr 2016 21:38:10 +0200
Message-ID: <1461526694-11367-3-git-send-email-fw@strlen.de>
References: <1461526694-11367-1-git-send-email-fw@strlen.de>
Cc: linux-kernel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461526694-11367-1-git-send-email-fw@strlen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

AFAICS this is safe: the lock is only used in the .ndo_start_xmit
function and this driver does not set LLTX.

Gets rid of TX_LOCKED return value, followup patches will remove it.

Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h      |  3 +--
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 11 -----------
 2 files changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index b9203d9..c46b489 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -488,7 +488,7 @@ struct atl1c_tpd_ring {
 	dma_addr_t dma;		/* descriptor ring physical address */
 	u16 size;		/* descriptor ring length in bytes */
 	u16 count;		/* number of descriptors in the ring */
-	u16 next_to_use; 	/* this is protectd by adapter->tx_lock */
+	u16 next_to_use;
 	atomic_t next_to_clean;
 	struct atl1c_buffer *buffer_info;
 };
@@ -542,7 +542,6 @@ struct atl1c_adapter {
 	u16 link_duplex;
 
 	spinlock_t mdio_lock;
-	spinlock_t tx_lock;
 	atomic_t irq_sem;
 
 	struct work_struct common_task;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index d0084d4..a3200ea 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -821,7 +821,6 @@ static int atl1c_sw_init(struct atl1c_adapter *adapter)
 	atl1c_set_rxbufsize(adapter, adapter->netdev);
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->mdio_lock);
-	spin_lock_init(&adapter->tx_lock);
 	set_bit(__AT_DOWN, &adapter->flags);
 
 	return 0;
@@ -2206,7 +2205,6 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 					  struct net_device *netdev)
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
-	unsigned long flags;
 	u16 tpd_req = 1;
 	struct atl1c_tpd_desc *tpd;
 	enum atl1c_trans_queue type = atl1c_trans_normal;
@@ -2217,16 +2215,10 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 	}
 
 	tpd_req = atl1c_cal_tpd_req(skb);
-	if (!spin_trylock_irqsave(&adapter->tx_lock, flags)) {
-		if (netif_msg_pktdata(adapter))
-			dev_info(&adapter->pdev->dev, "tx locked\n");
-		return NETDEV_TX_LOCKED;
-	}
 
 	if (atl1c_tpd_avail(adapter, type) < tpd_req) {
 		/* no enough descriptor, just stop queue */
 		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -2234,7 +2226,6 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 
 	/* do TSO and check sum */
 	if (atl1c_tso_csum(adapter, skb, &tpd, type) != 0) {
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
@@ -2257,12 +2248,10 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 			   "tx-skb droppted due to dma error\n");
 		/* roll back tpd/buffer */
 		atl1c_tx_rollback(adapter, tpd, type);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		dev_kfree_skb_any(skb);
 	} else {
 		netdev_sent_queue(adapter->netdev, skb->len);
 		atl1c_tx_queue(adapter, skb, tpd, type);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	}
 
 	return NETDEV_TX_OK;
-- 
2.7.3
