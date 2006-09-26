From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 6/8] sky2: use netif_tx_lock instead of LLTX
Date: Tue, 26 Sep 2006 16:13:36 -0700
Message-ID: <20060926161336.266ebc86@freekitty>
References: <20060926160814.79750148@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:46003 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965143AbWIZXRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 19:17:53 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k8QNHInW026369
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:20 -0700
Received: from freekitty (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k8QNHIT1006577
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:18 -0700
To: netdev@vger.kernel.org
In-Reply-To: <20060926160814.79750148@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the netdevice transmit lock via netif_tx_lock rather than putting
lock in device specific code and using lockless transmit.  The code is
cleaner using netif_tx_lock, and the performance is same.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |   57 +++++++++++++++--------------------------------------
 drivers/net/sky2.h |    1 
 2 files changed, 17 insertions(+), 41 deletions(-)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-09-25 15:23:23.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.c	2006-09-25 15:23:25.000000000 -0700
@@ -942,13 +942,13 @@
 	struct sky2_hw *hw = sky2->hw;
 	u16 port = sky2->port;
 
-	spin_lock_bh(&sky2->tx_lock);
+	netif_tx_lock_bh(dev);
 
 	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), RX_VLAN_STRIP_ON);
 	sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_VLAN_TAG_ON);
 	sky2->vlgrp = grp;
 
-	spin_unlock_bh(&sky2->tx_lock);
+	netif_tx_unlock_bh(dev);
 }
 
 static void sky2_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
@@ -957,14 +957,14 @@
 	struct sky2_hw *hw = sky2->hw;
 	u16 port = sky2->port;
 
-	spin_lock_bh(&sky2->tx_lock);
+	netif_tx_lock_bh(dev);
 
 	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), RX_VLAN_STRIP_OFF);
 	sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_VLAN_TAG_OFF);
 	if (sky2->vlgrp)
 		sky2->vlgrp->vlan_devices[vid] = NULL;
 
-	spin_unlock_bh(&sky2->tx_lock);
+	netif_tx_unlock_bh(dev);
 }
 #endif
 
@@ -1202,8 +1202,6 @@
  * A single packet can generate multiple list elements, and
  * the number of ring elements will probably be less than the number
  * of list elements used.
- *
- * No BH disabling for tx_lock here (like tg3)
  */
 static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 {
@@ -1217,27 +1215,8 @@
 	u16 mss;
 	u8 ctrl;
 
-	/* No BH disabling for tx_lock here.  We are running in BH disabled
-	 * context and TX reclaim runs via poll inside of a software
-	 * interrupt, and no related locks in IRQ processing.
-	 */
-	if (!spin_trylock(&sky2->tx_lock))
-		return NETDEV_TX_LOCKED;
-
-	if (unlikely(tx_avail(sky2) < tx_le_req(skb))) {
-		/* There is a known but harmless race with lockless tx
-		 * and netif_stop_queue.
-		 */
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
-			if (net_ratelimit())
-				printk(KERN_WARNING PFX "%s: ring full when queue awake!\n",
-				       dev->name);
-		}
-		spin_unlock(&sky2->tx_lock);
-
-		return NETDEV_TX_BUSY;
-	}
+ 	if (unlikely(tx_avail(sky2) < tx_le_req(skb)))
+  		return NETDEV_TX_BUSY;
 
 	if (unlikely(netif_msg_tx_queued(sky2)))
 		printk(KERN_DEBUG "%s: tx queued, slot %u, len %d\n",
@@ -1352,8 +1331,6 @@
 
 	sky2_put_idx(hw, txqaddr[sky2->port], sky2->tx_prod);
 
-	spin_unlock(&sky2->tx_lock);
-
 	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
@@ -1408,11 +1385,13 @@
 }
 
 /* Cleanup all untransmitted buffers, assume transmitter not running */
-static void sky2_tx_clean(struct sky2_port *sky2)
+static void sky2_tx_clean(struct net_device *dev)
 {
-	spin_lock_bh(&sky2->tx_lock);
+	struct sky2_port *sky2 = netdev_priv(dev);
+
+	netif_tx_lock_bh(dev);
 	sky2_tx_complete(sky2, sky2->tx_prod);
-	spin_unlock_bh(&sky2->tx_lock);
+	netif_tx_unlock_bh(dev);
 }
 
 /* Network shutdown */
@@ -1496,7 +1475,7 @@
 
 	synchronize_irq(hw->pdev->irq);
 
-	sky2_tx_clean(sky2);
+	sky2_tx_clean(dev);
 	sky2_rx_clean(sky2);
 
 	pci_free_consistent(hw->pdev, RX_LE_BYTES,
@@ -1748,16 +1727,16 @@
 	} else if (report != sky2->tx_cons) {
 		printk(KERN_INFO PFX "status report lost?\n");
 
-		spin_lock_bh(&sky2->tx_lock);
+		netif_tx_lock_bh(dev);
 		sky2_tx_complete(sky2, report);
-		spin_unlock_bh(&sky2->tx_lock);
+		netif_tx_unlock_bh(dev);
 	} else {
 		printk(KERN_INFO PFX "hardware hung? flushing\n");
 
 		sky2_write32(hw, Q_ADDR(txq, Q_CSR), BMU_STOP);
 		sky2_write32(hw, Y2_QADDR(txq, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
 
-		sky2_tx_clean(sky2);
+		sky2_tx_clean(dev);
 
 		sky2_qset(hw, txq);
 		sky2_prefetch_init(hw, txq, sky2->tx_le_map, TX_RING_SIZE - 1);
@@ -1927,9 +1906,9 @@
 	struct sky2_port *sky2 = netdev_priv(dev);
 
 	if (netif_running(dev)) {
-		spin_lock(&sky2->tx_lock);
+		netif_tx_lock(dev);
 		sky2_tx_complete(sky2, last);
-		spin_unlock(&sky2->tx_lock);
+		netif_tx_unlock(dev);
 	}
 }
 
@@ -3134,7 +3113,6 @@
 	sky2->hw = hw;
 	sky2->msg_enable = netif_msg_init(debug, default_msg);
 
-	spin_lock_init(&sky2->tx_lock);
 	/* Auto speed and flow control */
 	sky2->autoneg = AUTONEG_ENABLE;
 	sky2->tx_pause = 1;
@@ -3153,7 +3131,6 @@
 
 	sky2->port = port;
 
-	dev->features |= NETIF_F_LLTX;
 	if (hw->chip_id != CHIP_ID_YUKON_EC_U)
 		dev->features |= NETIF_F_TSO;
 	if (highmem)
--- netdev-2.6.orig/drivers/net/sky2.h	2006-09-25 15:23:23.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.h	2006-09-25 15:23:25.000000000 -0700
@@ -1789,7 +1789,6 @@
 	u32		     msg_enable;
 	spinlock_t	     phy_lock;
 
-	spinlock_t	     tx_lock  ____cacheline_aligned_in_smp;
 	struct tx_ring_info  *tx_ring;
 	struct sky2_tx_le    *tx_le;
 	u16		     tx_cons;		/* next le to check */
