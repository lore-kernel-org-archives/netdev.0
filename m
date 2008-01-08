From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/7]: [NET]: Make ->poll() breakout consistent in Intel
 ethernet drivers.
Date: Mon, 07 Jan 2008 21:41:10 -0800 (PST)
Message-ID: <20080107.214110.257940011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32890
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752539AbYAHFlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:41:11 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 01124C8C217
	for <netdev@vger.kernel.org>; Mon,  7 Jan 2008 21:41:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[NET]: Make ->poll() breakout consistent in Intel ethernet drivers.

This makes the ->poll() routines of the E100, E1000, E1000E, IXGB, and
IXGBE drivers complete ->poll() consistently.

Now they will all break out when the amount of RX work done is less
than 'budget'.

At a later time, we may want put back code to include the TX work as
well (as at least one other NAPI driver does, but by in large NAPI
drivers do not do this).  But if so, it should be done consistently
across the board to all of these drivers.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/e100.c             |    7 +++----
 drivers/net/e1000/e1000_main.c |   10 +++++-----
 drivers/net/e1000e/netdev.c    |    8 ++++----
 drivers/net/ixgb/ixgb_main.c   |    7 +++----
 drivers/net/ixgbe/ixgbe_main.c |    8 ++++----
 5 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 68316f1..b87402b 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1991,13 +1991,12 @@ static int e100_poll(struct napi_struct *napi, int budget)
 	struct nic *nic = container_of(napi, struct nic, napi);
 	struct net_device *netdev = nic->netdev;
 	unsigned int work_done = 0;
-	int tx_cleaned;
 
 	e100_rx_clean(nic, &work_done, budget);
-	tx_cleaned = e100_tx_clean(nic);
+	e100_tx_clean(nic);
 
-	/* If no Rx and Tx cleanup work was done, exit polling mode. */
-	if((!tx_cleaned && (work_done == 0))) {
+	/* If budget not fully consumed, exit the polling mode */
+	if (work_done < budget) {
 		netif_rx_complete(netdev, napi);
 		e100_enable_irq(nic);
 	}
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 9de7144..13d57b0 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3919,7 +3919,7 @@ e1000_clean(struct napi_struct *napi, int budget)
 {
 	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
 	struct net_device *poll_dev = adapter->netdev;
-	int tx_cleaned = 0, work_done = 0;
+	int work_done = 0;
 
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
@@ -3929,16 +3929,16 @@ e1000_clean(struct napi_struct *napi, int budget)
 	 * simultaneously.  A failure obtaining the lock means
 	 * tx_ring[0] is currently being cleaned anyway. */
 	if (spin_trylock(&adapter->tx_queue_lock)) {
-		tx_cleaned = e1000_clean_tx_irq(adapter,
-		                                &adapter->tx_ring[0]);
+		e1000_clean_tx_irq(adapter,
+				   &adapter->tx_ring[0]);
 		spin_unlock(&adapter->tx_queue_lock);
 	}
 
 	adapter->clean_rx(adapter, &adapter->rx_ring[0],
 	                  &work_done, budget);
 
-	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done == 0))) {
+	/* If budget not fully consumed, exit the polling mode */
+	if (work_done < budget) {
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
 		netif_rx_complete(poll_dev, napi);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index dd9698c..4a6fc74 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1384,7 +1384,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 {
 	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
 	struct net_device *poll_dev = adapter->netdev;
-	int tx_cleaned = 0, work_done = 0;
+	int work_done = 0;
 
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
@@ -1394,14 +1394,14 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	 * simultaneously.  A failure obtaining the lock means
 	 * tx_ring is currently being cleaned anyway. */
 	if (spin_trylock(&adapter->tx_queue_lock)) {
-		tx_cleaned = e1000_clean_tx_irq(adapter);
+		e1000_clean_tx_irq(adapter);
 		spin_unlock(&adapter->tx_queue_lock);
 	}
 
 	adapter->clean_rx(adapter, &work_done, budget);
 
-	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done < budget))) {
+	/* If budget not fully consumed, exit the polling mode */
+	if (work_done < budget) {
 		if (adapter->itr_setting & 3)
 			e1000_set_itr(adapter);
 		netif_rx_complete(poll_dev, napi);
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index a8bef52..d2fb88d 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1787,14 +1787,13 @@ ixgb_clean(struct napi_struct *napi, int budget)
 {
 	struct ixgb_adapter *adapter = container_of(napi, struct ixgb_adapter, napi);
 	struct net_device *netdev = adapter->netdev;
-	int tx_cleaned;
 	int work_done = 0;
 
-	tx_cleaned = ixgb_clean_tx_irq(adapter);
+	ixgb_clean_tx_irq(adapter);
 	ixgb_clean_rx_irq(adapter, &work_done, budget);
 
-	/* if no Tx and not enough Rx work done, exit the polling mode */
-	if((!tx_cleaned && (work_done == 0))) {
+	/* If budget not fully consumed, exit the polling mode */
+	if (work_done < budget) {
 		netif_rx_complete(netdev, napi);
 		ixgb_irq_enable(adapter);
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7c31930..a564916 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1468,15 +1468,15 @@ static int ixgbe_clean(struct napi_struct *napi, int budget)
 	struct ixgbe_adapter *adapter = container_of(napi,
 					struct ixgbe_adapter, napi);
 	struct net_device *netdev = adapter->netdev;
-	int tx_cleaned = 0, work_done = 0;
+	int work_done = 0;
 
 	/* In non-MSIX case, there is no multi-Tx/Rx queue */
-	tx_cleaned = ixgbe_clean_tx_irq(adapter, adapter->tx_ring);
+	ixgbe_clean_tx_irq(adapter, adapter->tx_ring);
 	ixgbe_clean_rx_irq(adapter, &adapter->rx_ring[0], &work_done,
 			   budget);
 
-	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done < budget))) {
+	/* If budget not fully consumed, exit the polling mode */
+	if (work_done < budget) {
 		netif_rx_complete(netdev, napi);
 		ixgbe_irq_enable(adapter);
 	}
-- 
1.5.4.rc2.38.gd6da3

