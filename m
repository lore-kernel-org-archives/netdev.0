From: David Miller <davem@davemloft.net>
Subject: [PATCH 36/39]: netdev: Fix multiqueue drivers to only operate on
 specific subqueue state.
Date: Thu, 03 Jul 2008 00:05:44 -0700 (PDT)
Message-ID: <20080703.000544.224905713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50744
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759330AbYGCHFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:05:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Multiqueue aware drivers should only start/stop/wake/schedule
specific TX queues, rather than using the backwards compat
non-multiqueue-aware interfaces.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/cpmac.c            |   20 ++++++----------
 drivers/net/ixgbe/ixgbe_main.c |   13 +++-------
 drivers/net/s2io.c             |   48 +++++++++++++++------------------------
 3 files changed, 31 insertions(+), 50 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 7c7b54e..6c05fe1 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -544,7 +544,7 @@ fatal_error:
 
 	spin_unlock(&priv->rx_lock);
 	netif_rx_complete(priv->dev, napi);
-	netif_stop_queue(priv->dev);
+	netif_stop_all_queues(priv->dev);
 	napi_disable(&priv->napi);
 
 	atomic_inc(&priv->reset_pending);
@@ -750,9 +750,7 @@ static void cpmac_hw_error(struct work_struct *work)
 	barrier();
 	atomic_dec(&priv->reset_pending);
 
-	for (i = 0; i < CPMAC_QUEUES; i++)
-		netif_wake_subqueue(priv->dev, i);
-	netif_wake_queue(priv->dev);
+	netif_wake_all_queues(priv->dev);
 	cpmac_write(priv->regs, CPMAC_MAC_INT_ENABLE, 3);
 }
 
@@ -781,7 +779,7 @@ static void cpmac_check_status(struct net_device *dev)
 				     dev->name, tx_code, tx_channel, macstatus);
 		}
 
-		netif_stop_queue(dev);
+		netif_stop_all_queues(dev);
 		cpmac_hw_stop(dev);
 		if (schedule_work(&priv->reset_work))
 			atomic_inc(&priv->reset_pending);
@@ -842,9 +840,7 @@ static void cpmac_tx_timeout(struct net_device *dev)
 	barrier();
 	atomic_dec(&priv->reset_pending);
 
-	netif_wake_queue(priv->dev);
-	for (i = 0; i < CPMAC_QUEUES; i++)
-		netif_wake_subqueue(dev, i);
+	netif_wake_all_queues(priv->dev);
 }
 
 static int cpmac_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -935,7 +931,7 @@ static void cpmac_adjust_link(struct net_device *dev)
 
 	spin_lock(&priv->lock);
 	if (priv->phy->link) {
-		netif_start_queue(dev);
+		netif_start_all_queues(dev);
 		if (priv->phy->duplex != priv->oldduplex) {
 			new_state = 1;
 			priv->oldduplex = priv->phy->duplex;
@@ -949,10 +945,10 @@ static void cpmac_adjust_link(struct net_device *dev)
 		if (!priv->oldlink) {
 			new_state = 1;
 			priv->oldlink = 1;
-			netif_schedule(dev);
+			netif_tx_schedule_all(dev);
 		}
 	} else if (priv->oldlink) {
-		netif_stop_queue(dev);
+		netif_stop_all_queues(dev);
 		new_state = 1;
 		priv->oldlink = 0;
 		priv->oldspeed = 0;
@@ -1072,7 +1068,7 @@ static int cpmac_stop(struct net_device *dev)
 	struct cpmac_priv *priv = netdev_priv(dev);
 	struct resource *mem;
 
-	netif_stop_queue(dev);
+	netif_stop_all_queues(dev);
 
 	cancel_work_sync(&priv->reset_work);
 	napi_disable(&priv->napi);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9a0bb4d..cb0909c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2009,7 +2009,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	del_timer_sync(&adapter->watchdog_timer);
 
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
+	netif_tx_stop_all_queues(netdev);
 
 	if (!pci_channel_offline(adapter->pdev))
 		ixgbe_reset(adapter);
@@ -2892,7 +2892,6 @@ static void ixgbe_watchdog(unsigned long data)
 	struct net_device *netdev = adapter->netdev;
 	bool link_up;
 	u32 link_speed = 0;
-	int i;
 
 	adapter->hw.mac.ops.check_link(&adapter->hw, &(link_speed), &link_up);
 
@@ -2913,9 +2912,7 @@ static void ixgbe_watchdog(unsigned long data)
 				 (FLOW_TX ? "TX" : "None"))));
 
 			netif_carrier_on(netdev);
-			netif_wake_queue(netdev);
-			for (i = 0; i < adapter->num_tx_queues; i++)
-				netif_wake_subqueue(netdev, i);
+			netif_tx_wake_all_queues(netdev);
 		} else {
 			/* Force detection of hung controller */
 			adapter->detect_tx_hung = true;
@@ -2924,7 +2921,7 @@ static void ixgbe_watchdog(unsigned long data)
 		if (netif_carrier_ok(netdev)) {
 			DPRINTK(LINK, INFO, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
+			netif_tx_stop_all_queues(netdev);
 		}
 	}
 
@@ -3627,9 +3624,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	ixgbe_start_hw(hw);
 
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		netif_stop_subqueue(netdev, i);
+	netif_tx_stop_all_queues(netdev);
 
 	ixgbe_napi_add_all(adapter);
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 6acbfbc..1d8433f 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -545,63 +545,53 @@ static struct pci_driver s2io_driver = {
 /* netqueue manipulation helper functions */
 static inline void s2io_stop_all_tx_queue(struct s2io_nic *sp)
 {
-	int i;
-	if (sp->config.multiq) {
-		for (i = 0; i < sp->config.tx_fifo_num; i++)
-			netif_stop_subqueue(sp->dev, i);
-	} else {
+	if (!sp->config.multiq) {
+		int i;
+
 		for (i = 0; i < sp->config.tx_fifo_num; i++)
 			sp->mac_control.fifos[i].queue_state = FIFO_QUEUE_STOP;
-		netif_stop_queue(sp->dev);
 	}
+	netif_tx_stop_all_queues(sp->dev);
 }
 
 static inline void s2io_stop_tx_queue(struct s2io_nic *sp, int fifo_no)
 {
-	if (sp->config.multiq)
-		netif_stop_subqueue(sp->dev, fifo_no);
-	else {
+	if (!sp->config.multiq)
 		sp->mac_control.fifos[fifo_no].queue_state =
 			FIFO_QUEUE_STOP;
-		netif_stop_queue(sp->dev);
-	}
+
+	netif_tx_stop_all_queues(sp->dev);
 }
 
 static inline void s2io_start_all_tx_queue(struct s2io_nic *sp)
 {
-	int i;
-	if (sp->config.multiq) {
-		for (i = 0; i < sp->config.tx_fifo_num; i++)
-			netif_start_subqueue(sp->dev, i);
-	} else {
+	if (!sp->config.multiq) {
+		int i;
+
 		for (i = 0; i < sp->config.tx_fifo_num; i++)
 			sp->mac_control.fifos[i].queue_state = FIFO_QUEUE_START;
-		netif_start_queue(sp->dev);
 	}
+	netif_tx_start_all_queues(sp->dev);
 }
 
 static inline void s2io_start_tx_queue(struct s2io_nic *sp, int fifo_no)
 {
-	if (sp->config.multiq)
-		netif_start_subqueue(sp->dev, fifo_no);
-	else {
+	if (!sp->config.multiq)
 		sp->mac_control.fifos[fifo_no].queue_state =
 			FIFO_QUEUE_START;
-		netif_start_queue(sp->dev);
-	}
+
+	netif_tx_start_all_queues(sp->dev);
 }
 
 static inline void s2io_wake_all_tx_queue(struct s2io_nic *sp)
 {
-	int i;
-	if (sp->config.multiq) {
-		for (i = 0; i < sp->config.tx_fifo_num; i++)
-			netif_wake_subqueue(sp->dev, i);
-	} else {
+	if (!sp->config.multiq) {
+		int i;
+
 		for (i = 0; i < sp->config.tx_fifo_num; i++)
 			sp->mac_control.fifos[i].queue_state = FIFO_QUEUE_START;
-		netif_wake_queue(sp->dev);
 	}
+	netif_tx_wake_all_queues(sp->dev);
 }
 
 static inline void s2io_wake_tx_queue(
@@ -8675,5 +8665,5 @@ static void s2io_io_resume(struct pci_dev *pdev)
 	}
 
 	netif_device_attach(netdev);
-	netif_wake_queue(netdev);
+	netif_tx_wake_all_queues(netdev);
 }
-- 
1.5.6

