From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] [-MM,
	FIX] e1000e: incorporate napi_struct changes from net-2.6.24.git
Date: Thu, 23 Aug 2007 07:59:11 -0700
Message-ID: <20070823145911.2467.42136.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeff@garzik.org,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	krkumar2@in.ibm.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62461 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761703AbXHWO7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 10:59:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This incorporates the new napi_struct changes into e1000e. Included
bugfix for ifdown hang from Krishna Kumar for e1000.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/e1000.h  |    2 ++
 drivers/net/e1000e/netdev.c |   35 ++++++++++++++++-------------------
 2 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index e3cd877..ea6a9fe 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -196,6 +196,8 @@ struct e1000_adapter {
 	struct e1000_ring *tx_ring /* One per active queue */
 						____cacheline_aligned_in_smp;
 
+	struct napi_struct napi;
+
 	unsigned long tx_queue_len;
 	unsigned int restart_queue;
 	u32 txd_cmd;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 8ebe238..0e35d0a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1149,12 +1149,12 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (netif_rx_schedule_prep(netdev)) {
+	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev);
+		__netif_rx_schedule(netdev, &adapter->napi);
 	} else {
 		atomic_dec(&adapter->irq_sem);
 	}
@@ -1212,12 +1212,12 @@ static irqreturn_t e1000_intr(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (netif_rx_schedule_prep(netdev)) {
+	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev);
+		__netif_rx_schedule(netdev, &adapter->napi);
 	} else {
 		atomic_dec(&adapter->irq_sem);
 	}
@@ -1663,10 +1663,10 @@ set_itr_now:
  * e1000_clean - NAPI Rx polling callback
  * @adapter: board private structure
  **/
-static int e1000_clean(struct net_device *poll_dev, int *budget)
+static int e1000_clean(struct napi_struct *napi, int budget)
 {
-	struct e1000_adapter *adapter;
-	int work_to_do = min(*budget, poll_dev->quota);
+	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
+	struct net_device *poll_dev = adapter->netdev;
 	int tx_cleaned = 0, work_done = 0;
 
 	/* Must NOT use netdev_priv macro here. */
@@ -1685,17 +1685,15 @@ static int e1000_clean(struct net_device *poll_dev, int *budget)
 		spin_unlock(&adapter->tx_queue_lock);
 	}
 
-	adapter->clean_rx(adapter, &work_done, work_to_do);
-	*budget -= work_done;
-	poll_dev->quota -= work_done;
+	adapter->clean_rx(adapter, &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done == 0)) ||
+	if ((tx_cleaned && (work_done < budget)) ||
 	   !netif_running(poll_dev)) {
 quit_polling:
 		if (adapter->itr_setting & 3)
 			e1000_set_itr(adapter);
-		netif_rx_complete(poll_dev);
+		netif_rx_complete(poll_dev, napi);
 		if (test_bit(__E1000_DOWN, &adapter->state))
 			atomic_dec(&adapter->irq_sem);
 		else
@@ -1703,7 +1701,7 @@ quit_polling:
 		return 0;
 	}
 
-	return 1;
+	return work_done;
 }
 
 static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
@@ -2441,7 +2439,7 @@ int e1000e_up(struct e1000_adapter *adapter)
 
 	clear_bit(__E1000_DOWN, &adapter->state);
 
-	netif_poll_enable(adapter->netdev);
+	napi_enable(&adapter->napi);
 	e1000_irq_enable(adapter);
 
 	/* fire a link change interrupt to start the watchdog */
@@ -2474,7 +2472,7 @@ void e1000e_down(struct e1000_adapter *adapter)
 	e1e_flush();
 	msleep(10);
 
-	netif_poll_disable(netdev);
+	napi_disable(&adapter->napi);
 	e1000_irq_disable(adapter);
 
 	del_timer_sync(&adapter->watchdog_timer);
@@ -2607,7 +2605,7 @@ static int e1000_open(struct net_device *netdev)
 	/* From here on the code is the same as e1000e_up() */
 	clear_bit(__E1000_DOWN, &adapter->state);
 
-	netif_poll_enable(netdev);
+	napi_enable(&adapter->napi);
 
 	e1000_irq_enable(adapter);
 
@@ -4102,8 +4100,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	e1000e_set_ethtool_ops(netdev);
 	netdev->tx_timeout		= &e1000_tx_timeout;
 	netdev->watchdog_timeo		= 5 * HZ;
-	netdev->poll			= &e1000_clean;
-	netdev->weight			= 64;
+	netif_napi_add(netdev, &adapter->napi, e1000_clean, 64);
 	netdev->vlan_rx_register	= e1000_vlan_rx_register;
 	netdev->vlan_rx_add_vid		= e1000_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid	= e1000_vlan_rx_kill_vid;
@@ -4272,7 +4269,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	/* tell the stack to leave us alone until e1000_open() is called */
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
-	netif_poll_disable(netdev);
+	napi_disable(&adapter->napi);
 
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
