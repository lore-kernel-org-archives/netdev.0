From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Wed, 16 Jan 2008 04:28:17 -0800 (PST)
Message-ID: <20080116.042817.143947133.davem@davemloft.net>
References: <200801150625.10823.elendil@planet.nl>
	<20080114.215317.38045859.davem@davemloft.net>
	<478DC824.4030600@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: elendil@planet.nl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: slavon@bigtelecom.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59849
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752085AbYAPM2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 07:28:18 -0500
In-Reply-To: <478DC824.4030600@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Date: Wed, 16 Jan 2008 12:02:28 +0300

> Also have regression after apply patch.

BTW, if you are using the e1000e driver then this initial
patch will not work.

My more recent patch posting for this problem, will.

I include it again below for you:

[NET]: Fix TX timeout regression in Intel drivers.

This fixes a regression added by changeset
53e52c729cc169db82a6105fac7a166e10c2ec36 ("[NET]: Make ->poll()
breakout consistent in Intel ethernet drivers.")

As pointed out by Jesse Brandeburg, for three of the drivers edited
above there is breakout logic in the *_clean_tx_irq() code to prevent
running TX reclaim forever.  If this occurs, we have to elide NAPI
poll completion or else those TX events will never be serviced.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 13d57b0..0c9a6f7 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3919,7 +3919,7 @@ e1000_clean(struct napi_struct *napi, int budget)
 {
 	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
 	struct net_device *poll_dev = adapter->netdev;
-	int work_done = 0;
+	int tx_cleaned = 0, work_done = 0;
 
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
@@ -3929,14 +3929,17 @@ e1000_clean(struct napi_struct *napi, int budget)
 	 * simultaneously.  A failure obtaining the lock means
 	 * tx_ring[0] is currently being cleaned anyway. */
 	if (spin_trylock(&adapter->tx_queue_lock)) {
-		e1000_clean_tx_irq(adapter,
-				   &adapter->tx_ring[0]);
+		tx_cleaned = e1000_clean_tx_irq(adapter,
+						&adapter->tx_ring[0]);
 		spin_unlock(&adapter->tx_queue_lock);
 	}
 
 	adapter->clean_rx(adapter, &adapter->rx_ring[0],
 	                  &work_done, budget);
 
+	if (tx_cleaned)
+		work_done = budget;
+
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		if (likely(adapter->itr_setting & 3))
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4a6fc74..2ab3bfb 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1384,7 +1384,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 {
 	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
 	struct net_device *poll_dev = adapter->netdev;
-	int work_done = 0;
+	int tx_cleaned = 0, work_done = 0;
 
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
@@ -1394,12 +1394,15 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	 * simultaneously.  A failure obtaining the lock means
 	 * tx_ring is currently being cleaned anyway. */
 	if (spin_trylock(&adapter->tx_queue_lock)) {
-		e1000_clean_tx_irq(adapter);
+		tx_cleaned = e1000_clean_tx_irq(adapter);
 		spin_unlock(&adapter->tx_queue_lock);
 	}
 
 	adapter->clean_rx(adapter, &work_done, budget);
 
+	if (tx_cleaned)
+		work_done = budget;
+
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		if (adapter->itr_setting & 3)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a564916..de3f45e 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1468,13 +1468,16 @@ static int ixgbe_clean(struct napi_struct *napi, int budget)
 	struct ixgbe_adapter *adapter = container_of(napi,
 					struct ixgbe_adapter, napi);
 	struct net_device *netdev = adapter->netdev;
-	int work_done = 0;
+	int tx_cleaned = 0, work_done = 0;
 
 	/* In non-MSIX case, there is no multi-Tx/Rx queue */
-	ixgbe_clean_tx_irq(adapter, adapter->tx_ring);
+	tx_cleaned = ixgbe_clean_tx_irq(adapter, adapter->tx_ring);
 	ixgbe_clean_rx_irq(adapter, &adapter->rx_ring[0], &work_done,
 			   budget);
 
+	if (tx_cleaned)
+		work_done = budget;
+
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		netif_rx_complete(netdev, napi);
