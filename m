From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 3/6] atle1: remove LLTX support and TX_UNLOCKED
Date: Sun, 24 Apr 2016 21:38:11 +0200
Message-ID: <1461526694-11367-4-git-send-email-fw@strlen.de>
References: <1461526694-11367-1-git-send-email-fw@strlen.de>
Cc: linux-kernel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461526694-11367-1-git-send-email-fw@strlen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

similar to atl1c: lock is only used in ndo_start_xmit, but we also
advertised LLTX, so remove that as well and let core stack handle
tx locking.

Allows to remove the TX_LOCKED return value from the driver.

Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ethernet/atheros/atl1e/atl1e.h      |  1 -
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 12 +-----------
 2 files changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e.h b/drivers/net/ethernet/atheros/atl1e/atl1e.h
index 0212dac..632bb84 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e.h
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e.h
@@ -442,7 +442,6 @@ struct atl1e_adapter {
 	u16 link_duplex;
 
 	spinlock_t mdio_lock;
-	spinlock_t tx_lock;
 	atomic_t irq_sem;
 
 	struct work_struct reset_task;
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 59a03a1..974713b 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -648,7 +648,6 @@ static int atl1e_sw_init(struct atl1e_adapter *adapter)
 
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->mdio_lock);
-	spin_lock_init(&adapter->tx_lock);
 
 	set_bit(__AT_DOWN, &adapter->flags);
 
@@ -1866,7 +1865,6 @@ static netdev_tx_t atl1e_xmit_frame(struct sk_buff *skb,
 					  struct net_device *netdev)
 {
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
-	unsigned long flags;
 	u16 tpd_req = 1;
 	struct atl1e_tpd_desc *tpd;
 
@@ -1880,13 +1878,10 @@ static netdev_tx_t atl1e_xmit_frame(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 	tpd_req = atl1e_cal_tdp_req(skb);
-	if (!spin_trylock_irqsave(&adapter->tx_lock, flags))
-		return NETDEV_TX_LOCKED;
 
 	if (atl1e_tpd_avail(adapter) < tpd_req) {
 		/* no enough descriptor, just stop queue */
 		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1910,7 +1905,6 @@ static netdev_tx_t atl1e_xmit_frame(struct sk_buff *skb,
 
 	/* do TSO and check sum */
 	if (atl1e_tso_csum(adapter, skb, tpd) != 0) {
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
@@ -1921,10 +1915,7 @@ static netdev_tx_t atl1e_xmit_frame(struct sk_buff *skb,
 	}
 
 	atl1e_tx_queue(adapter, tpd_req, tpd);
-
-	netdev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
 out:
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
 
@@ -2285,8 +2276,7 @@ static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 
 	netdev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO |
 			      NETIF_F_HW_VLAN_CTAG_RX;
-	netdev->features = netdev->hw_features | NETIF_F_LLTX |
-			   NETIF_F_HW_VLAN_CTAG_TX;
+	netdev->features = netdev->hw_features | NETIF_F_HW_VLAN_CTAG_TX;
 	/* not enabled by default */
 	netdev->hw_features |= NETIF_F_RXALL | NETIF_F_RXFCS;
 	return 0;
-- 
2.7.3
