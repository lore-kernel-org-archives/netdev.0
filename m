From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/3] e1000: drop lltx, remove unnecessary lock
Date: Wed, 21 Jan 2009 00:34:07 -0800
Message-ID: <20090121083407.538.47112.stgit@lost.foo-projects.org>
References: <20090121083329.538.67223.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:33592
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763284AbZAUIeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 03:34:24 -0500
In-Reply-To: <20090121083329.538.67223.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LLTX is deprecated, don't use it.  This completes the removal of LLTX from
the Intel Network drivers.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h      |    2 --
 drivers/net/e1000/e1000_main.c |   29 +++--------------------------
 2 files changed, 3 insertions(+), 28 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index f5581de..e9a416f 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -182,7 +182,6 @@ struct e1000_tx_ring {
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
 
-	spinlock_t tx_lock;
 	u16 tdh;
 	u16 tdt;
 	bool last_tx_tso;
@@ -238,7 +237,6 @@ struct e1000_adapter {
 	u16 link_speed;
 	u16 link_duplex;
 	spinlock_t stats_lock;
-	spinlock_t tx_queue_lock;
 	unsigned int total_tx_bytes;
 	unsigned int total_tx_packets;
 	unsigned int total_rx_bytes;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 26474c9..2e17ff4 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -31,7 +31,7 @@
 
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-#define DRV_VERSION "7.3.20-k3-NAPI"
+#define DRV_VERSION "7.3.21-k2-NAPI"
 const char e1000_driver_version[] = DRV_VERSION;
 static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
@@ -1048,8 +1048,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	netdev->features |= NETIF_F_LLTX;
-
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
 	netdev->vlan_features |= NETIF_F_HW_CSUM;
@@ -1368,8 +1366,6 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 		return -ENOMEM;
 	}
 
-	spin_lock_init(&adapter->tx_queue_lock);
-
 	/* Explicitly disable IRQ since the NIC can be in any state. */
 	e1000_irq_disable(adapter);
 
@@ -1624,7 +1620,6 @@ setup_tx_desc_die:
 
 	txdr->next_to_use = 0;
 	txdr->next_to_clean = 0;
-	spin_lock_init(&txdr->tx_lock);
 
 	return 0;
 }
@@ -3185,7 +3180,6 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
 	unsigned int len = skb->len - skb->data_len;
-	unsigned long flags;
 	unsigned int nr_frags;
 	unsigned int mss;
 	int count = 0;
@@ -3290,22 +3284,15 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	    (hw->mac_type == e1000_82573))
 		e1000_transfer_dhcp_info(adapter, skb);
 
-	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
-		/* Collision - tell upper layer to requeue */
-		return NETDEV_TX_LOCKED;
-
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
-	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, count + 2))) {
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, count + 2)))
 		return NETDEV_TX_BUSY;
-	}
 
 	if (unlikely(hw->mac_type == e1000_82547)) {
 		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
-			spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 			return NETDEV_TX_BUSY;
 		}
 	}
@@ -3320,7 +3307,6 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	tso = e1000_tso(adapter, tx_ring, skb);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 		return NETDEV_TX_OK;
 	}
 
@@ -3345,7 +3331,6 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	/* Make sure there is space in the ring for the next send. */
 	e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
 
-	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
 
@@ -3773,15 +3758,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 
 	adapter = netdev_priv(poll_dev);
 
-	/* e1000_clean is called per-cpu.  This lock protects
-	 * tx_ring[0] from being cleaned by multiple cpus
-	 * simultaneously.  A failure obtaining the lock means
-	 * tx_ring[0] is currently being cleaned anyway. */
-	if (spin_trylock(&adapter->tx_queue_lock)) {
-		tx_cleaned = e1000_clean_tx_irq(adapter,
-						&adapter->tx_ring[0]);
-		spin_unlock(&adapter->tx_queue_lock);
-	}
+	tx_cleaned = e1000_clean_tx_irq(adapter, &adapter->tx_ring[0]);
 
 	adapter->clean_rx(adapter, &adapter->rx_ring[0],
 	                  &work_done, budget);

