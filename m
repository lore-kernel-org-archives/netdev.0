From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 07/18] igb: add NAPI Rx queue support
Date: Fri, 27 Jun 2008 11:00:39 -0700
Message-ID: <20080627180035.22428.73511.stgit@localhost.localdomain>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080627175921.22428.52767.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Update the NAPI implementation to use the new napi_struct infrstructure.
This removes the need of multiple net_device structs to implement a
multiqueue NAPI.

Signed-off-by: PJ Waskiewicz <peter.p.waskiewicz.jr.@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    2 +
 drivers/net/igb/igb_main.c |  148 ++++++++++++++++++--------------------------
 2 files changed, 61 insertions(+), 89 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 6b2e7d3..17eb84e 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -150,6 +150,7 @@ struct igb_ring {
 	u16 itr_register;
 	u16 cpu;
 
+	int queue_index;
 	unsigned int total_bytes;
 	unsigned int total_packets;
 
@@ -265,6 +266,7 @@ struct igb_adapter {
 	int msg_enable;
 	struct msix_entry *msix_entries;
 	u32 eims_enable_mask;
+	u32 eims_other;
 
 	/* to not mess up cache alignment, always add to the bottom */
 	unsigned long state;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index a43186e..1f0703d 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -227,12 +227,11 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *ring = &(adapter->rx_ring[i]);
 		ring->adapter = adapter;
+		ring->queue_index = i;
 		ring->itr_register = E1000_ITR;
 
-		if (!ring->napi.poll)
-			netif_napi_add(adapter->netdev, &ring->napi, igb_clean,
-				       adapter->napi.weight /
-				       adapter->num_rx_queues);
+		/* set a default napi handler for each rx_ring */
+		netif_napi_add(adapter->netdev, &ring->napi, igb_clean, 64);
 	}
 	return 0;
 }
@@ -300,9 +299,6 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 		array_wr32(E1000_MSIXBM(0), vector++,
 				      E1000_EIMS_OTHER);
 
-		/* disable IAM for ICR interrupt bits */
-		wr32(E1000_IAM, 0);
-
 		tmp = rd32(E1000_CTRL_EXT);
 		/* enable MSI-X PBA support*/
 		tmp |= E1000_CTRL_EXT_PBA_CLR;
@@ -313,6 +309,7 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 
 		wr32(E1000_CTRL_EXT, tmp);
 		adapter->eims_enable_mask |= E1000_EIMS_OTHER;
+		adapter->eims_other = E1000_EIMS_OTHER;
 
 	wrfl();
 }
@@ -355,6 +352,9 @@ static int igb_request_msix(struct igb_adapter *adapter)
 			goto out;
 		ring->itr_register = E1000_EITR(0) + (vector << 2);
 		ring->itr_val = adapter->itr;
+		/* overwrite the poll routine for MSIX, we've already done
+		 * netif_napi_add */
+		ring->napi.poll = &igb_clean_rx_ring_msix;
 		vector++;
 	}
 
@@ -363,9 +363,6 @@ static int igb_request_msix(struct igb_adapter *adapter)
 	if (err)
 		goto out;
 
-	adapter->napi.poll = igb_clean_rx_ring_msix;
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		adapter->rx_ring[i].napi.poll = adapter->napi.poll;
 	igb_configure_msix(adapter);
 	return 0;
 out:
@@ -434,12 +431,8 @@ static int igb_request_irq(struct igb_adapter *adapter)
 
 	if (adapter->msix_entries) {
 		err = igb_request_msix(adapter);
-		if (!err) {
-			/* enable IAM, auto-mask,
-			 * DO NOT USE EIAM or IAM in legacy mode */
-			wr32(E1000_IAM, IMS_ENABLE_MASK);
+		if (!err)
 			goto request_done;
-		}
 		/* fall back to MSI */
 		igb_reset_interrupt_capability(adapter);
 		if (!pci_enable_msi(adapter->pdev))
@@ -448,7 +441,11 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		igb_free_all_rx_resources(adapter);
 		adapter->num_rx_queues = 1;
 		igb_alloc_queues(adapter);
+	} else {
+		wr32(E1000_MSIXBM(0), (E1000_EICR_RX_QUEUE0 |
+		                       E1000_EIMS_OTHER));
 	}
+
 	if (adapter->msi_enabled) {
 		err = request_irq(adapter->pdev->irq, &igb_intr_msi, 0,
 				  netdev->name, netdev);
@@ -500,9 +497,12 @@ static void igb_irq_disable(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 
 	if (adapter->msix_entries) {
+		wr32(E1000_EIAM, 0);
 		wr32(E1000_EIMC, ~0);
 		wr32(E1000_EIAC, 0);
 	}
+
+	wr32(E1000_IAM, 0);
 	wr32(E1000_IMC, ~0);
 	wrfl();
 	synchronize_irq(adapter->pdev->irq);
@@ -517,13 +517,14 @@ static void igb_irq_enable(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 
 	if (adapter->msix_entries) {
-		wr32(E1000_EIMS,
-				adapter->eims_enable_mask);
-		wr32(E1000_EIAC,
-				adapter->eims_enable_mask);
+		wr32(E1000_EIAC, adapter->eims_enable_mask);
+		wr32(E1000_EIAM, adapter->eims_enable_mask);
+		wr32(E1000_EIMS, adapter->eims_enable_mask);
 		wr32(E1000_IMS, E1000_IMS_LSC);
-	} else
-	wr32(E1000_IMS, IMS_ENABLE_MASK);
+	} else {
+		wr32(E1000_IMS, IMS_ENABLE_MASK);
+		wr32(E1000_IAM, IMS_ENABLE_MASK);
+	}
 }
 
 static void igb_update_mng_vlan(struct igb_adapter *adapter)
@@ -661,13 +662,10 @@ int igb_up(struct igb_adapter *adapter)
 
 	clear_bit(__IGB_DOWN, &adapter->state);
 
-	napi_enable(&adapter->napi);
-
-	if (adapter->msix_entries) {
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			napi_enable(&adapter->rx_ring[i].napi);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		napi_enable(&adapter->rx_ring[i].napi);
+	if (adapter->msix_entries)
 		igb_configure_msix(adapter);
-	}
 
 	/* Clear any pending interrupts. */
 	rd32(E1000_ICR);
@@ -704,11 +702,9 @@ void igb_down(struct igb_adapter *adapter)
 	wrfl();
 	msleep(10);
 
-	napi_disable(&adapter->napi);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		napi_disable(&adapter->rx_ring[i].napi);
 
-	if (adapter->msix_entries)
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			napi_disable(&adapter->rx_ring[i].napi);
 	igb_irq_disable(adapter);
 
 	del_timer_sync(&adapter->watchdog_timer);
@@ -906,7 +902,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	igb_set_ethtool_ops(netdev);
 	netdev->tx_timeout = &igb_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
-	netif_napi_add(netdev, &adapter->napi, igb_clean, 64);
 	netdev->vlan_rx_register = igb_vlan_rx_register;
 	netdev->vlan_rx_add_vid = igb_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid = igb_vlan_rx_kill_vid;
@@ -1271,15 +1266,14 @@ static int igb_open(struct net_device *netdev)
 	/* From here on the code is the same as igb_up() */
 	clear_bit(__IGB_DOWN, &adapter->state);
 
-	napi_enable(&adapter->napi);
-	if (adapter->msix_entries)
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			napi_enable(&adapter->rx_ring[i].napi);
-
-	igb_irq_enable(adapter);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		napi_enable(&adapter->rx_ring[i].napi);
 
 	/* Clear any pending interrupts. */
 	rd32(E1000_ICR);
+
+	igb_irq_enable(adapter);
+
 	/* Fire a link status change interrupt to start the watchdog. */
 	wr32(E1000_ICS, E1000_ICS_LSC);
 
@@ -1507,8 +1501,6 @@ int igb_setup_rx_resources(struct igb_adapter *adapter,
 	rx_ring->pending_skb = NULL;
 
 	rx_ring->adapter = adapter;
-	/* FIXME: do we want to setup ring->napi->poll here? */
-	rx_ring->napi.poll = adapter->napi.poll;
 
 	return 0;
 
@@ -3007,26 +2999,19 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 	struct net_device *netdev = data;
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 eicr;
-	/* disable interrupts from the "other" bit, avoid re-entry */
-	wr32(E1000_EIMC, E1000_EIMS_OTHER);
-
-	eicr = rd32(E1000_EICR);
+	u32 icr = rd32(E1000_ICR);
 
-	if (eicr & E1000_EIMS_OTHER) {
-		u32 icr = rd32(E1000_ICR);
-		/* reading ICR causes bit 31 of EICR to be cleared */
-		if (!(icr & E1000_ICR_LSC))
-			goto no_link_interrupt;
-		hw->mac.get_link_status = 1;
-		/* guard against interrupt when we're going down */
-		if (!test_bit(__IGB_DOWN, &adapter->state))
-			mod_timer(&adapter->watchdog_timer, jiffies + 1);
-	}
+	/* reading ICR causes bit 31 of EICR to be cleared */
+	if (!(icr & E1000_ICR_LSC))
+		goto no_link_interrupt;
+	hw->mac.get_link_status = 1;
+	/* guard against interrupt when we're going down */
+	if (!test_bit(__IGB_DOWN, &adapter->state))
+		mod_timer(&adapter->watchdog_timer, jiffies + 1);
 
 no_link_interrupt:
 	wr32(E1000_IMS, E1000_IMS_LSC);
-	wr32(E1000_EIMS, E1000_EIMS_OTHER);
+	wr32(E1000_EIMS, adapter->eims_other);
 
 	return IRQ_HANDLED;
 }
@@ -3057,21 +3042,19 @@ static irqreturn_t igb_msix_rx(int irq, void *data)
 	struct igb_adapter *adapter = rx_ring->adapter;
 	struct e1000_hw *hw = &adapter->hw;
 
-	if (!rx_ring->itr_val)
-		wr32(E1000_EIMC, rx_ring->eims_value);
+	/* Write the ITR value calculated at the end of the
+	 * previous interrupt.
+	 */
 
-	if (netif_rx_schedule_prep(adapter->netdev, &rx_ring->napi)) {
-		rx_ring->total_bytes = 0;
-		rx_ring->total_packets = 0;
-		rx_ring->no_itr_adjust = 0;
-		__netif_rx_schedule(adapter->netdev, &rx_ring->napi);
-	} else {
-		if (!rx_ring->no_itr_adjust) {
-			igb_lower_rx_eitr(adapter, rx_ring);
-			rx_ring->no_itr_adjust = 1;
-		}
+	if (adapter->set_itr) {
+		wr32(rx_ring->itr_register,
+		     1000000000 / (rx_ring->itr_val * 256));
+		adapter->set_itr = 0;
 	}
 
+	if (netif_rx_schedule_prep(adapter->netdev, &rx_ring->napi))
+		__netif_rx_schedule(adapter->netdev, &rx_ring->napi);
+
 	return IRQ_HANDLED;
 }
 
@@ -3085,7 +3068,6 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	struct napi_struct *napi = &adapter->napi;
 	struct e1000_hw *hw = &adapter->hw;
 	/* read ICR disables interrupts using IAM */
 	u32 icr = rd32(E1000_ICR);
@@ -3094,25 +3076,17 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 	 * previous interrupt.
 	 */
 	if (adapter->set_itr) {
-		wr32(E1000_ITR,
-			1000000000 / (adapter->itr * 256));
+		wr32(E1000_ITR, 1000000000 / (adapter->itr * 256));
 		adapter->set_itr = 0;
 	}
 
-	/* read ICR disables interrupts using IAM */
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->mac.get_link_status = 1;
 		if (!test_bit(__IGB_DOWN, &adapter->state))
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (netif_rx_schedule_prep(netdev, napi)) {
-		adapter->tx_ring->total_bytes = 0;
-		adapter->tx_ring->total_packets = 0;
-		adapter->rx_ring->total_bytes = 0;
-		adapter->rx_ring->total_packets = 0;
-		__netif_rx_schedule(netdev, napi);
-	}
+	netif_rx_schedule(netdev, &adapter->rx_ring[0].napi);
 
 	return IRQ_HANDLED;
 }
@@ -3126,7 +3100,6 @@ static irqreturn_t igb_intr(int irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	struct napi_struct *napi = &adapter->napi;
 	struct e1000_hw *hw = &adapter->hw;
 	/* Interrupt Auto-Mask...upon reading ICR, interrupts are masked.  No
 	 * need for the IMC write */
@@ -3139,8 +3112,7 @@ static irqreturn_t igb_intr(int irq, void *data)
 	 * previous interrupt.
 	 */
 	if (adapter->set_itr) {
-		wr32(E1000_ITR,
-			1000000000 / (adapter->itr * 256));
+		wr32(E1000_ITR, 1000000000 / (adapter->itr * 256));
 		adapter->set_itr = 0;
 	}
 
@@ -3158,13 +3130,7 @@ static irqreturn_t igb_intr(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (netif_rx_schedule_prep(netdev, napi)) {
-		adapter->tx_ring->total_bytes = 0;
-		adapter->rx_ring->total_bytes = 0;
-		adapter->tx_ring->total_packets = 0;
-		adapter->rx_ring->total_packets = 0;
-		__netif_rx_schedule(netdev, napi);
-	}
+	netif_rx_schedule(netdev, &adapter->rx_ring[0].napi);
 
 	return IRQ_HANDLED;
 }
@@ -3247,6 +3213,10 @@ quit_polling:
 			else if (mean_size > IGB_DYN_ITR_LENGTH_HIGH)
 				igb_lower_rx_eitr(adapter, rx_ring);
 		}
+
+		if (!test_bit(__IGB_DOWN, &adapter->state))
+			wr32(E1000_EIMS, rx_ring->eims_value);
+
 		return 0;
 	}
 


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
