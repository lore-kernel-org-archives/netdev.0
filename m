From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/8] ixgb: add explicit state checking
Date: Mon, 17 Mar 2008 09:29:46 -0700
Message-ID: <20080317162946.4861.84355.stgit@localhost.localdomain>
References: <20080317162939.4861.91040.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55054 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478AbYCQQaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 12:30:13 -0400
In-Reply-To: <20080317162939.4861.91040.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

In order to remove the irq_sem code we need to implement strict
adapter state checking to prevent accidental double up or downs
or resets. This code is largely copied from e1000/e1000e.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb.h      |    9 +++++++++
 drivers/net/ixgb/ixgb_main.c |   34 ++++++++++++++++++++++++----------
 2 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 3d2e721..0078136 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -195,6 +195,15 @@ struct ixgb_adapter {
 	struct ixgb_hw_stats stats;
 	uint32_t alloc_rx_buff_failed;
 	boolean_t have_msi;
+	unsigned long flags;
+};
+
+enum ixgb_state_t {
+	/* TBD
+	__IXGB_TESTING,
+	__IXGB_RESETTING,
+	*/
+	__IXGB_DOWN
 };
 
 /* Exported from other modules */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 269e6f8..548c248 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -283,13 +283,15 @@ ixgb_up(struct ixgb_adapter *adapter)
 		}
 	}
 
-	mod_timer(&adapter->watchdog_timer, jiffies);
+	clear_bit(__IXGB_DOWN, &adapter->flags);
 
 #ifdef CONFIG_IXGB_NAPI
 	napi_enable(&adapter->napi);
 #endif
 	ixgb_irq_enable(adapter);
 
+	mod_timer(&adapter->watchdog_timer, jiffies);
+
 	return 0;
 }
 
@@ -298,11 +300,14 @@ ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
 {
 	struct net_device *netdev = adapter->netdev;
 
+	/* prevent the interrupt handler from restarting watchdog */
+	set_bit(__IXGB_DOWN, &adapter->flags);
+
 #ifdef CONFIG_IXGB_NAPI
 	napi_disable(&adapter->napi);
 	atomic_set(&adapter->irq_sem, 0);
 #endif
-
+	/* waiting for NAPI to complete can re-enable interrupts */
 	ixgb_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
 
@@ -592,6 +597,7 @@ ixgb_sw_init(struct ixgb_adapter *adapter)
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->tx_lock);
 
+	set_bit(__IXGB_DOWN, &adapter->flags);
 	return 0;
 }
 
@@ -1464,14 +1470,18 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	int vlan_id = 0;
 	int tso;
 
+	if (test_bit(__IXGB_DOWN, &adapter->flags)) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
 	if(skb->len <= 0) {
 		dev_kfree_skb_any(skb);
 		return 0;
 	}
 
 #ifdef NETIF_F_LLTX
-	local_irq_save(flags);
-	if (!spin_trylock(&adapter->tx_lock)) {
+	if (!spin_trylock_irqsave(&adapter->tx_lock, flags)) {
 		/* Collision - tell upper layer to requeue */
 		local_irq_restore(flags);
 		return NETDEV_TX_LOCKED;
@@ -1753,9 +1763,9 @@ ixgb_intr(int irq, void *data)
 	if(unlikely(!icr))
 		return IRQ_NONE;  /* Not our interrupt */
 
-	if(unlikely(icr & (IXGB_INT_RXSEQ | IXGB_INT_LSC))) {
-		mod_timer(&adapter->watchdog_timer, jiffies);
-	}
+	if (unlikely(icr & (IXGB_INT_RXSEQ | IXGB_INT_LSC)))
+		if (!test_bit(__IXGB_DOWN, &adapter->flags))
+			mod_timer(&adapter->watchdog_timer, jiffies);
 
 #ifdef CONFIG_IXGB_NAPI
 	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
@@ -2195,7 +2205,9 @@ ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		IXGB_WRITE_REG(&adapter->hw, RCTL, rctl);
 	}
 
-	ixgb_irq_enable(adapter);
+	/* don't enable interrupts unless we are UP */
+	if (adapter->netdev->flags & IFF_UP)
+		ixgb_irq_enable(adapter);
 }
 
 static void
@@ -2222,9 +2234,11 @@ ixgb_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
 
 	vlan_group_set_device(adapter->vlgrp, vid, NULL);
 
-	ixgb_irq_enable(adapter);
+	/* don't enable interrupts unless we are UP */
+	if (adapter->netdev->flags & IFF_UP)
+		ixgb_irq_enable(adapter);
 
-	/* remove VID from filter table*/
+	/* remove VID from filter table */
 
 	index = (vid >> 5) & 0x7F;
 	vfta = IXGB_READ_REG_ARRAY(&adapter->hw, VFTA, index);

