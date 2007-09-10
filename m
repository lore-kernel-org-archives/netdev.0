From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] [-MM,
	FIX V4] e1000e: incorporate napi_struct changes from net-2.6.24.git
Date: Mon, 10 Sep 2007 16:35:03 -0700
Message-ID: <20070910233503.19058.29051.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jirislaby@gmail.com, jeff@garzik.org, Robert.Olsson@data.slu.se
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
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

This incorporates the new napi_struct changes into e1000e. Included
bugfix for ifdown hang from Krishna Kumar for e1000.

Disabling polling is no longer needed at init time, so remove
napi_disable() call from _probe().

This also fixes an endless polling loop where the driver signalled
"polling done" improperly back to the stack.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/e1000.h  |    2 ++
 drivers/net/e1000e/netdev.c |   40 ++++++++++++++++------------------------
 2 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index c57e35a..d2499bb 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -187,6 +187,8 @@ struct e1000_adapter {
 	struct e1000_ring *tx_ring /* One per active queue */
 						____cacheline_aligned_in_smp;
 
+	struct napi_struct napi;
+
 	unsigned long tx_queue_len;
 	unsigned int restart_queue;
 	u32 txd_cmd;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 372da46..eeb40cc 100644
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
@@ -1662,10 +1662,10 @@ set_itr_now:
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
@@ -1684,25 +1684,19 @@ static int e1000_clean(struct net_device *poll_dev, int *budget)
 		spin_unlock(&adapter->tx_queue_lock);
 	}
 
-	adapter->clean_rx(adapter, &work_done, work_to_do);
-	*budget -= work_done;
-	poll_dev->quota -= work_done;
+	adapter->clean_rx(adapter, &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done == 0)) ||
+	if ((!tx_cleaned && (work_done < budget)) ||
 	   !netif_running(poll_dev)) {
 quit_polling:
 		if (adapter->itr_setting & 3)
 			e1000_set_itr(adapter);
-		netif_rx_complete(poll_dev);
-		if (test_bit(__E1000_DOWN, &adapter->state))
-			atomic_dec(&adapter->irq_sem);
-		else
-			e1000_irq_enable(adapter);
-		return 0;
+		netif_rx_complete(poll_dev, napi);
+		e1000_irq_enable(adapter);
 	}
 
-	return 1;
+	return work_done;
 }
 
 static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
@@ -2439,7 +2433,7 @@ int e1000e_up(struct e1000_adapter *adapter)
 
 	clear_bit(__E1000_DOWN, &adapter->state);
 
-	netif_poll_enable(adapter->netdev);
+	napi_enable(&adapter->napi);
 	e1000_irq_enable(adapter);
 
 	/* fire a link change interrupt to start the watchdog */
@@ -2472,7 +2466,7 @@ void e1000e_down(struct e1000_adapter *adapter)
 	e1e_flush();
 	msleep(10);
 
-	netif_poll_disable(netdev);
+	napi_disable(&adapter->napi);
 	e1000_irq_disable(adapter);
 
 	del_timer_sync(&adapter->watchdog_timer);
@@ -2605,7 +2599,7 @@ static int e1000_open(struct net_device *netdev)
 	/* From here on the code is the same as e1000e_up() */
 	clear_bit(__E1000_DOWN, &adapter->state);
 
-	netif_poll_enable(netdev);
+	napi_enable(&adapter->napi);
 
 	e1000_irq_enable(adapter);
 
@@ -4090,8 +4084,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	e1000e_set_ethtool_ops(netdev);
 	netdev->tx_timeout		= &e1000_tx_timeout;
 	netdev->watchdog_timeo		= 5 * HZ;
-	netdev->poll			= &e1000_clean;
-	netdev->weight			= 64;
+	netif_napi_add(netdev, &adapter->napi, e1000_clean, 64);
 	netdev->vlan_rx_register	= e1000_vlan_rx_register;
 	netdev->vlan_rx_add_vid		= e1000_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid	= e1000_vlan_rx_kill_vid;
@@ -4260,7 +4253,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	/* tell the stack to leave us alone until e1000_open() is called */
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
-	netif_poll_disable(netdev);
 
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
