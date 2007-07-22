From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sun, 22 Jul 2007 00:36:01 -0700 (PDT)
Message-ID: <20070722.003601.47326980.davem@davemloft.net>
References: <1185071972.6344.61.camel@localhost.localdomain>
	<20070721.205425.61337743.davem@davemloft.net>
	<20070722.001818.82052713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56485
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754309AbXGVHgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 03:36:02 -0400
In-Reply-To: <20070722.001818.82052713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sun, 22 Jul 2007 00:18:18 -0700 (PDT)

> To facilitate discussion I converted the core and tg3, and include
> just that part of the patch below.

And for those for whom it makes it easier to play around with these
changes, here is the updated e1000 conversion below.

Making changes to e1000 is like visiting a crime scene. :-/

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 16a6edf..781ed99 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -300,6 +300,7 @@ struct e1000_adapter {
 				int cleaned_count);
 	struct e1000_rx_ring *rx_ring;      /* One per active queue */
 #ifdef CONFIG_E1000_NAPI
+	struct napi_struct napi;
 	struct net_device *polling_netdev;  /* One per active queue */
 #endif
 	int num_tx_queues;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f48b659..13c877c 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -162,7 +162,7 @@ static irqreturn_t e1000_intr_msi(int irq, void *data);
 static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter,
                                     struct e1000_tx_ring *tx_ring);
 #ifdef CONFIG_E1000_NAPI
-static int e1000_clean(struct net_device *poll_dev, int *budget);
+static int e1000_clean(struct napi_struct *napi, int budget);
 static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter,
                                     struct e1000_rx_ring *rx_ring,
                                     int *work_done, int work_to_do);
@@ -541,7 +541,7 @@ int e1000_up(struct e1000_adapter *adapter)
 	clear_bit(__E1000_DOWN, &adapter->flags);
 
 #ifdef CONFIG_E1000_NAPI
-	netif_poll_enable(adapter->netdev);
+	napi_enable(&adapter->napi);
 #endif
 	e1000_irq_enable(adapter);
 
@@ -630,7 +630,7 @@ e1000_down(struct e1000_adapter *adapter)
 	set_bit(__E1000_DOWN, &adapter->flags);
 
 #ifdef CONFIG_E1000_NAPI
-	netif_poll_disable(netdev);
+	napi_disable(&adapter->napi);
 #endif
 	e1000_irq_disable(adapter);
 
@@ -932,8 +932,8 @@ e1000_probe(struct pci_dev *pdev,
 	netdev->tx_timeout = &e1000_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
 #ifdef CONFIG_E1000_NAPI
-	netdev->poll = &e1000_clean;
-	netdev->weight = 64;
+	adapter->napi.poll = &e1000_clean;
+	adapter->napi.weight = 64;
 #endif
 	netdev->vlan_rx_register = e1000_vlan_rx_register;
 	netdev->vlan_rx_add_vid = e1000_vlan_rx_add_vid;
@@ -1146,7 +1146,7 @@ e1000_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 #ifdef CONFIG_E1000_NAPI
-	netif_poll_disable(netdev);
+	napi_disable(&adapter->napi);
 #endif
 
 	strcpy(netdev->name, "eth%d");
@@ -1319,8 +1319,6 @@ e1000_sw_init(struct e1000_adapter *adapter)
 #ifdef CONFIG_E1000_NAPI
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		adapter->polling_netdev[i].priv = adapter;
-		adapter->polling_netdev[i].poll = &e1000_clean;
-		adapter->polling_netdev[i].weight = 64;
 		dev_hold(&adapter->polling_netdev[i]);
 		set_bit(__LINK_STATE_START, &adapter->polling_netdev[i].state);
 	}
@@ -1437,7 +1435,7 @@ e1000_open(struct net_device *netdev)
 	clear_bit(__E1000_DOWN, &adapter->flags);
 
 #ifdef CONFIG_E1000_NAPI
-	netif_poll_enable(netdev);
+	napi_enable(&adapter->napi);
 #endif
 
 	e1000_irq_enable(adapter);
@@ -1476,6 +1474,10 @@ e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
+#ifdef CONFIG_E1000_NAPI
+	napi_disable(&adapter->napi);
+#endif
+
 	WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 	e1000_down(adapter);
 	e1000_power_down_phy(adapter);
@@ -3780,12 +3782,12 @@ e1000_intr_msi(int irq, void *data)
 	}
 
 #ifdef CONFIG_E1000_NAPI
-	if (likely(netif_rx_schedule_prep(netdev))) {
+	if (likely(netif_rx_schedule_prep(netdev, &adapter->napi))) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev);
+		__netif_rx_schedule(netdev, &adapter->napi);
 	} else
 		e1000_irq_enable(adapter);
 #else
@@ -3865,12 +3867,12 @@ e1000_intr(int irq, void *data)
 		E1000_WRITE_REG(hw, IMC, ~0);
 		E1000_WRITE_FLUSH(hw);
 	}
-	if (likely(netif_rx_schedule_prep(netdev))) {
+	if (likely(netif_rx_schedule_prep(netdev, &adapter->napi))) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev);
+		__netif_rx_schedule(netdev, &adapter->napi);
 	} else
 		/* this really should not happen! if it does it is basically a
 		 * bug, but not a hard error, so enable ints and continue */
@@ -3918,10 +3920,10 @@ e1000_intr(int irq, void *data)
  **/
 
 static int
-e1000_clean(struct net_device *poll_dev, int *budget)
+e1000_clean(struct napi_struct *napi, int budget)
 {
-	struct e1000_adapter *adapter;
-	int work_to_do = min(*budget, poll_dev->quota);
+	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
+	struct net_device *poll_dev = adapter->netdev;
 	int tx_cleaned = 0, work_done = 0;
 
 	/* Must NOT use netdev_priv macro here. */
@@ -3942,23 +3944,19 @@ e1000_clean(struct net_device *poll_dev, int *budget)
 	}
 
 	adapter->clean_rx(adapter, &adapter->rx_ring[0],
-	                  &work_done, work_to_do);
-
-	*budget -= work_done;
-	poll_dev->quota -= work_done;
+	                  &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done == 0)) ||
+	if ((tx_cleaned && (work_done < budget)) ||
 	   !netif_running(poll_dev)) {
 quit_polling:
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
-		netif_rx_complete(poll_dev);
+		netif_rx_complete(poll_dev, &adapter->napi);
 		e1000_irq_enable(adapter);
-		return 0;
 	}
 
-	return 1;
+	return work_done;
 }
 
 #endif

