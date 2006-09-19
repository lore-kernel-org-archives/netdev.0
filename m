From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 12/23] e1000: Maybe stop TX if not enough free
 descriptors
Date: Tue, 19 Sep 2006 12:50:19 -0700
Message-ID: <20060919125019.316d3790@localhost.localdomain>
References: <20060919172623.4605.56860.stgit@gitlost.site>
	<20060919172859.4605.60855.stgit@gitlost.site>
	<45104719.9080708@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:5765 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751075AbWISTus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 15:50:48 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <45104719.9080708@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My preference would be for drivers not to use LLTX (except loopback) and just
use the dev->xmit_lock via netif_tx_lock if possible.  Something like this for e1000.

Subject: [PATCH] e1000 no lltx

Get rid of lockless transmit for e1000. Use netif_tx_lock instead
of having to do locking in device. For NAPI this is trivial but
for the non-NAPI case it means scheduling a tasklet to do Tx
cleanup

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---

 drivers/net/e1000/e1000.h      |    7 +++--
 drivers/net/e1000/e1000_main.c |   53 ++++++++++++++++++++++------------------
 2 files changed, 33 insertions(+), 27 deletions(-)

87a7c62864818350ebb7da73f26e1dc49c5eb2e5
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 98afa9c..9de6519 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -190,7 +190,6 @@ struct e1000_tx_ring {
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
 
-	spinlock_t tx_lock;
 	uint16_t tdh;
 	uint16_t tdt;
 	boolean_t last_tx_tso;
@@ -251,9 +250,8 @@ struct e1000_adapter {
 	uint16_t link_speed;
 	uint16_t link_duplex;
 	spinlock_t stats_lock;
-#ifdef CONFIG_E1000_NAPI
 	spinlock_t tx_queue_lock;
-#endif
+
 	atomic_t irq_sem;
 	struct work_struct reset_task;
 	uint8_t fc_autoneg;
@@ -263,6 +261,9 @@ struct e1000_adapter {
 
 	/* TX */
 	struct e1000_tx_ring *tx_ring;      /* One per active queue */
+#ifndef CONFIG_E1000_NAPI
+	struct tasklet_struct tx_tasklet;
+#endif
 	unsigned long tx_queue_len;
 	uint32_t txd_cmd;
 	uint32_t tx_int_delay;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index acf818b..8eb38a7 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -158,6 +158,7 @@ static boolean_t e1000_clean_rx_irq_ps(s
                                        struct e1000_rx_ring *rx_ring,
                                        int *work_done, int work_to_do);
 #else
+static void e1000_tx_tasklet(unsigned long arg);
 static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter,
                                     struct e1000_rx_ring *rx_ring);
 static boolean_t e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
@@ -811,8 +812,6 @@ e1000_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	netdev->features |= NETIF_F_LLTX;
-
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
 	/* initialize eeprom parameters */
@@ -1155,8 +1154,11 @@ e1000_sw_init(struct e1000_adapter *adap
 		dev_hold(&adapter->polling_netdev[i]);
 		set_bit(__LINK_STATE_START, &adapter->polling_netdev[i].state);
 	}
-	spin_lock_init(&adapter->tx_queue_lock);
+#else
+	adapter->tx_tasklet.func = &e1000_tx_tasklet;
+	adapter->tx_tasklet.data = (unsigned long) adapter;
 #endif
+	spin_lock_init(&adapter->tx_queue_lock);
 
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->stats_lock);
@@ -1407,7 +1409,6 @@ setup_tx_desc_die:
 
 	txdr->next_to_use = 0;
 	txdr->next_to_clean = 0;
-	spin_lock_init(&txdr->tx_lock);
 
 	return 0;
 }
@@ -1991,6 +1992,23 @@ e1000_clean_tx_ring(struct e1000_adapter
 	writel(0, adapter->hw.hw_addr + tx_ring->tdt);
 }
 
+#ifndef CONFIG_E1000_NAPI
+static void
+e1000_tx_tasklet(unsigned long arg)
+{
+	struct e1000_adapter *adapter = (struct e1000_adapter *) arg;
+	int i;
+
+	if (!spin_trylock(&adapter->tx_queue_lock))
+		return;
+
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		e1000_clean_tx_irq(adapter, adapter->tx_ring);
+
+	spin_unlock(&adapter->tx_queue_lock);
+}
+#endif
+
 /**
  * e1000_clean_all_tx_rings - Free Tx Buffers for all queues
  * @adapter: board private structure
@@ -2902,7 +2920,6 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
 	unsigned int len = skb->len;
-	unsigned long flags;
 	unsigned int nr_frags = 0;
 	unsigned int mss = 0;
 	int count = 0;
@@ -2996,18 +3013,10 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	    (adapter->hw.mac_type == e1000_82573))
 		e1000_transfer_dhcp_info(adapter, skb);
 
-	local_irq_save(flags);
-	if (!spin_trylock(&tx_ring->tx_lock)) {
-		/* Collision - tell upper layer to requeue */
-		local_irq_restore(flags);
-		return NETDEV_TX_LOCKED;
-	}
-
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
 	if (unlikely(E1000_DESC_UNUSED(tx_ring) < count + 2)) {
 		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -3015,7 +3024,6 @@ e1000_xmit_frame(struct sk_buff *skb, st
 		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies);
-			spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 			return NETDEV_TX_BUSY;
 		}
 	}
@@ -3030,7 +3038,6 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	tso = e1000_tso(adapter, tx_ring, skb);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 		return NETDEV_TX_OK;
 	}
 
@@ -3056,7 +3063,6 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	if (unlikely(E1000_DESC_UNUSED(tx_ring) < MAX_SKB_FRAGS + 2))
 		netif_stop_queue(netdev);
 
-	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
 
@@ -3438,10 +3444,11 @@ e1000_intr(int irq, void *data, struct p
 	}
 
 	for (i = 0; i < E1000_MAX_INTR; i++)
-		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &
-		   !e1000_clean_tx_irq(adapter, adapter->tx_ring)))
+		if (!adapter->clean_rx(adapter, adapter->rx_ring))
 			break;
 
+	tasklet_schedule(&adapter->tx_tasklet);
+
 	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
 		e1000_irq_enable(adapter);
 
@@ -3546,13 +3553,11 @@ e1000_clean_tx_irq(struct e1000_adapter 
 	tx_ring->next_to_clean = i;
 
 #define TX_WAKE_THRESHOLD 32
-	if (unlikely(cleaned && netif_queue_stopped(netdev) &&
-	             netif_carrier_ok(netdev))) {
-		spin_lock(&tx_ring->tx_lock);
-		if (netif_queue_stopped(netdev) &&
-		    (E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))
+	if (unlikely(cleaned && netif_carrier_ok(netdev))) {
+		netif_tx_lock(netdev);
+		if (E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)
 			netif_wake_queue(netdev);
-		spin_unlock(&tx_ring->tx_lock);
+		netif_tx_unlock(netdev);
 	}
 
 	if (adapter->detect_tx_hung) {
-- 
1.1.3
