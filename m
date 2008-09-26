From: Kevin Hao <kexin.hao@windriver.com>
Subject: [PATCH] net: remove LLTX in atl2 driver
Date: Fri, 26 Sep 2008 10:20:11 +0800
Message-ID: <1222395611-3400-1-git-send-email-kexin.hao@windriver.com>
References: <48DC39D3.3090400@redhat.com>
Cc: Jay Cliburn <jacliburn@bellsouth.net>,
	Jeff Garzik <jeff@garzik.org>,
	Jeff Garzik <jgarzik@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35917 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919AbYIZCVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 22:21:01 -0400
In-Reply-To: <48DC39D3.3090400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When NETIF_F_LLTX is set, the atlx driver will use a private lock.
But in recent kernels this implementation seems redundant and
can cause problems where AF_PACKET sees things twice. Since
NETIF_F_LLTX is marked as deprecated and shouldn't be used in
new driver, this patch removes NETIF_F_LLTX and adds a mmiowb
before sending packet. I have tested this driver on a Eee PC.
It works well.

Signed-off-by: Kevin Hao <kexin.hao@windriver.com>
Acked-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl2.c |   24 +-----------------------
 drivers/net/atlx/atl2.h |    1 -
 2 files changed, 1 insertions(+), 24 deletions(-)

diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index b2995ac..3df4ee1 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -116,7 +116,6 @@ static int __devinit atl2_sw_init(struct atl2_adapter *adapter)
 	hw->max_frame_size = adapter->netdev->mtu;
 
 	spin_lock_init(&adapter->stats_lock);
-	spin_lock_init(&adapter->tx_lock);
 
 	set_bit(__ATL2_DOWN, &adapter->flags);
 
@@ -749,11 +748,7 @@ static void atl2_down(struct atl2_adapter *adapter)
 	 * reschedule our watchdog timer */
 	set_bit(__ATL2_DOWN, &adapter->flags);
 
-#ifdef NETIF_F_LLTX
-	netif_stop_queue(netdev);
-#else
 	netif_tx_disable(netdev);
-#endif
 
 	/* reset MAC to disable all RX/TX */
 	atl2_reset_hw(&adapter->hw);
@@ -829,7 +824,6 @@ static inline int TxdFreeBytes(struct atl2_adapter *adapter)
 static int atl2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct atl2_adapter *adapter = netdev_priv(netdev);
-	unsigned long flags;
 	struct tx_pkt_header *txph;
 	u32 offset, copy_len;
 	int txs_unused;
@@ -845,16 +839,6 @@ static int atl2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 
-#ifdef NETIF_F_LLTX
-	local_irq_save(flags);
-	if (!spin_trylock(&adapter->tx_lock)) {
-		/* Collision - tell upper layer to requeue */
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED;
-	}
-#else
-	spin_lock_irqsave(&adapter->tx_lock, flags);
-#endif
 	txs_unused = TxsFreeUnit(adapter);
 	txbuf_unused = TxdFreeBytes(adapter);
 
@@ -862,7 +846,6 @@ static int atl2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		txs_unused < 1) {
 		/* not enough resources */
 		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -908,8 +891,7 @@ static int atl2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	ATL2_WRITE_REGW(&adapter->hw, REG_MB_TXD_WR_IDX,
 		(adapter->txd_write_ptr >> 2));
 
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
-
+	mmiowb();
 	netdev->trans_start = jiffies;
 	dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
@@ -1447,10 +1429,6 @@ static int __devinit atl2_probe(struct pci_dev *pdev,
 	netdev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
 #endif
 
-#ifdef NETIF_F_LLTX
-	netdev->features |= NETIF_F_LLTX;
-#endif
-
 	/* Init PHY as early as possible due to power saving issue  */
 	atl2_phy_init(&adapter->hw);
 
diff --git a/drivers/net/atlx/atl2.h b/drivers/net/atlx/atl2.h
index 6e1f28f..09974df 100644
--- a/drivers/net/atlx/atl2.h
+++ b/drivers/net/atlx/atl2.h
@@ -462,7 +462,6 @@ struct atl2_adapter {
 	u16 link_duplex;
 
 	spinlock_t stats_lock;
-	spinlock_t tx_lock;
 
 	struct work_struct reset_task;
 	struct work_struct link_chg_task;
-- 
1.5.6.2.220.g44701

