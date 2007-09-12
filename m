From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] [-MM,
	FIX] ixgbe: incorporate napi_struct changes from net-2.6.24.git
Date: Wed, 12 Sep 2007 11:13:07 -0700
Message-ID: <20070912181307.13189.33476.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, jesse.brandeburg@intel.com
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30328 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764868AbXILSNN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 14:13:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This incorporates the new napi_struct changes into ixgbe.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    1 +
 drivers/net/ixgbe/ixgbe_main.c |   62 +++++++++++++++++-----------------------
 2 files changed, 27 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index b24803f..c160a7d 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -179,6 +179,7 @@ struct ixgbe_adapter {
 
 	/* TX */
 	struct ixgbe_ring *tx_ring;	/* One per active queue */
+	struct napi_struct napi;
 	u64 restart_queue;
 	u64 lsc_int;
 	u64 hw_tso_ctxt;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 23fb1ed..a08a462 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -557,14 +557,15 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 	struct ixgbe_adapter *adapter = rxr->adapter;
 
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rxr->eims_value);
-	netif_rx_schedule(adapter->netdev);
+	netif_rx_schedule(adapter->netdev, &adapter->napi);
 	return IRQ_HANDLED;
 }
 
-static int ixgbe_clean_rxonly(struct net_device *netdev, int *budget)
+static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 {
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	int work_to_do = min(*budget, netdev->quota);
+	struct ixgbe_adapter *adapter = container_of(napi,
+					struct ixgbe_adapter, napi);
+	struct net_device *netdev = adapter->netdev;
 	int work_done = 0;
 	struct ixgbe_ring *rxr = adapter->rx_ring;
 
@@ -572,22 +573,18 @@ static int ixgbe_clean_rxonly(struct net_device *netdev, int *budget)
 	if (!netif_carrier_ok(netdev))
 		goto quit_polling;
 
-	ixgbe_clean_rx_irq(adapter, rxr, &work_done, work_to_do);
-
-	*budget -= work_done;
-	netdev->quota -= work_done;
+	ixgbe_clean_rx_irq(adapter, rxr, &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((work_done == 0) || !netif_running(netdev)) {
+	if ((work_done < budget) || !netif_running(netdev)) {
 quit_polling:
-		netif_rx_complete(netdev);
+		netif_rx_complete(netdev, napi);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS,
 					rxr->eims_value);
-		return 0;
 	}
 
-	return 1;
+	return work_done;
 }
 
 /**
@@ -669,7 +666,8 @@ static int ixgbe_setup_msix(struct ixgbe_adapter *adapter)
 		goto release_irqs;
 	}
 
-	adapter->netdev->poll = ixgbe_clean_rxonly;
+	/* FIXME: implement netif_napi_remove() instead */
+	adapter->napi.poll = ixgbe_clean_rxonly;
 	adapter->flags |= IXGBE_FLAG_MSIX_ENABLED;
 	return 0;
 
@@ -713,12 +711,12 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			mod_timer(&adapter->watchdog_timer, jiffies);
 	}
-	if (netif_rx_schedule_prep(netdev)) {
+	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
 		/* Disable interrupts and register for poll. The flush of the
 		 * posted write is intentionally left out. */
 		atomic_inc(&adapter->irq_sem);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
-		__netif_rx_schedule(netdev);
+		__netif_rx_schedule(netdev, &adapter->napi);
 	}
 
 	return IRQ_HANDLED;
@@ -1218,7 +1216,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		ixgbe_configure_msi_and_legacy(adapter);
 
 	clear_bit(__IXGBE_DOWN, &adapter->state);
-	netif_poll_enable(netdev);
+	napi_enable(&adapter->napi);
 	ixgbe_irq_enable(adapter);
 
 	/* bring the link up in the watchdog, this could race with our first
@@ -1412,7 +1410,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	ixgbe_irq_disable(adapter);
 
-	netif_poll_disable(netdev);
+	napi_disable(&adapter->napi);
 	del_timer_sync(&adapter->watchdog_timer);
 
 	netif_carrier_off(netdev);
@@ -1464,11 +1462,12 @@ static void ixgbe_shutdown(struct pci_dev *pdev)
  * ixgbe_clean - NAPI Rx polling callback
  * @adapter: board private structure
  **/
-static int ixgbe_clean(struct net_device *netdev, int *budget)
+static int ixgbe_clean(struct napi_struct *napi, int budget)
 {
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	int work_to_do = min(*budget, netdev->quota);
-	int tx_cleaned, work_done = 0;
+	struct ixgbe_adapter *adapter = container_of(napi,
+					struct ixgbe_adapter, napi);
+	struct net_device *netdev = adapter->netdev;
+	int tx_cleaned = 0, work_done = 0;
 
 	/* Keep link state information with original netdev */
 	if (!netif_carrier_ok(adapter->netdev))
@@ -1477,24 +1476,17 @@ static int ixgbe_clean(struct net_device *netdev, int *budget)
 	/* In non-MSIX case, there is no multi-Tx/Rx queue */
 	tx_cleaned = ixgbe_clean_tx_irq(adapter, adapter->tx_ring);
 	ixgbe_clean_rx_irq(adapter, &adapter->rx_ring[0], &work_done,
-			   work_to_do);
-
-	*budget -= work_done;
-	netdev->quota -= work_done;
+			   budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done == 0)) ||
+	if ((!tx_cleaned && (work_done < budget)) ||
 	    !netif_running(adapter->netdev)) {
 quit_polling:
-		netif_rx_complete(netdev);
-		if (test_bit(__IXGBE_DOWN, &adapter->state))
-			atomic_dec(&adapter->irq_sem);
-		else
-			ixgbe_irq_enable(adapter);
-		return 0;
+		netif_rx_complete(netdev, napi);
+		ixgbe_irq_enable(adapter);
 	}
 
-	return 1;
+	return work_done;
 }
 
 /**
@@ -2592,8 +2584,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	ixgbe_set_ethtool_ops(netdev);
 	netdev->tx_timeout = &ixgbe_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
-	netdev->poll = &ixgbe_clean;
-	netdev->weight = 64;
+	netif_napi_add(netdev, &adapter->napi, ixgbe_clean, 64);
 	netdev->vlan_rx_register = ixgbe_vlan_rx_register;
 	netdev->vlan_rx_add_vid = ixgbe_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid = ixgbe_vlan_rx_kill_vid;
@@ -2698,7 +2689,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
-	netif_poll_disable(netdev);
 
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
