From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 10/25] ixgb: remove lltx support and update tx routine
Date: Tue, 08 Jul 2008 15:51:52 -0700
Message-ID: <20080708225152.6925.18633.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54022 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753866AbYGHWvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:51:53 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

a) kernel developers suggest LLTX is broken and unsafe to use, remove it.
b) remember to pre-stop the queue if we won't have room
c) removing lltx means we can remove our tx lock

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb.h      |    1 -
 drivers/net/ixgb/ixgb_main.c |   32 +-------------------------------
 2 files changed, 1 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 16f9c75..3cec7b9 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -157,7 +157,6 @@ struct ixgb_adapter {
 	u32 part_num;
 	u16 link_speed;
 	u16 link_duplex;
-	spinlock_t tx_lock;
 	struct work_struct tx_timeout_task;
 
 	struct timer_list blink_timer;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 79082eb..bd08e19 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -448,9 +448,6 @@ ixgb_probe(struct pci_dev *pdev,
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
 	netdev->features |= NETIF_F_TSO;
-#ifdef NETIF_F_LLTX
-	netdev->features |= NETIF_F_LLTX;
-#endif
 
 	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
@@ -577,8 +574,6 @@ ixgb_sw_init(struct ixgb_adapter *adapter)
 	/* enable flow control to be programmed */
 	hw->fc.send_xon = 1;
 
-	spin_lock_init(&adapter->tx_lock);
-
 	set_bit(__IXGB_DOWN, &adapter->flags);
 	return 0;
 }
@@ -1441,7 +1436,6 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	unsigned int first;
 	unsigned int tx_flags = 0;
-	unsigned long flags;
 	int vlan_id = 0;
 	int tso;
 
@@ -1455,26 +1449,9 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return 0;
 	}
 
-#ifdef NETIF_F_LLTX
-	if (!spin_trylock_irqsave(&adapter->tx_lock, flags)) {
-		/* Collision - tell upper layer to requeue */
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED;
-	}
-#else
-	spin_lock_irqsave(&adapter->tx_lock, flags);
-#endif
-
 	if (unlikely(ixgb_maybe_stop_tx(netdev, &adapter->tx_ring,
-                     DESC_NEEDED))) {
-		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
+                     DESC_NEEDED)))
 		return NETDEV_TX_BUSY;
-	}
-
-#ifndef NETIF_F_LLTX
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
-#endif
 
 	if(adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |= IXGB_TX_FLAGS_VLAN;
@@ -1486,9 +1463,6 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	tso = ixgb_tso(adapter, skb);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
-#ifdef NETIF_F_LLTX
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
-#endif
 		return NETDEV_TX_OK;
 	}
 
@@ -1502,13 +1476,9 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	netdev->trans_start = jiffies;
 
-#ifdef NETIF_F_LLTX
 	/* Make sure there is space in the ring for the next send. */
 	ixgb_maybe_stop_tx(netdev, &adapter->tx_ring, DESC_NEEDED);
 
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
-
-#endif
 	return NETDEV_TX_OK;
 }
 

