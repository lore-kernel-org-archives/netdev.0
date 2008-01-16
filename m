From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Tue, 15 Jan 2008 21:02:14 -0800 (PST)
Message-ID: <20080115.210214.170759690.davem@davemloft.net>
References: <200801151504.10047.elendil@planet.nl>
	<20080115190458.rxt3yhb2o8o404kc@mail.bigtelecom.ru>
	<36D9DB17C6DE9E40B059440DB8D95F52042FA541@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: slavon@bigtelecom.ru, elendil@planet.nl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33649
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750910AbYAPFCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 00:02:15 -0500
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52042FA541@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Tue, 15 Jan 2008 13:53:43 -0800

> The tx code has an "early exit" that tries to limit the amount of tx
> packets handled in a single poll loop and requires napi or interrupt
> rescheduling based on the return value from e1000_clean_tx_irq.

That explains everything, thanks Jesse.

Ok, here is the patch I'll propose to fix this.  The goal is to make
it as simple as possible without regressing the thing we were trying
to fix.

Something more sophisticated can be done later.

Three of the 5 Intel drivers had the TX breakout logic.  e1000,
e1000e, and ixgbe.  e100 and ixgb did not, so they don't have any
problems we need to fix here.

What the fix does is behave as if the budget was fully consumed if
*_clean_tx_irq() returns true.

The only valid way to return from ->poll() without copleting the NAPI
poll is by returning work_done == budget.  That signals to the caller
that the NAPI instance has not been descheduled and therefore the
caller fully owns the NAPI context.

This does mean that for these drivers any time TX work is done, we'll
loop at least one extra time in the ->poll() loop of net_rx_work() but
that is historically what these drivers have caused to happen for
years.

For 2.6.25 or similar I would suggest investigating courses of action
to bring closure and consistency to this:

1) Determine whether the loop breakout is actually necessary.
   Jesse explained to me that they had seen a case where a
   thread on one cpu feeding the TX ring could keep a thread
   on another cpu constantly running the *_clean_tx_irq() code
   in a loop.

   I find this hard to believe since even the slowest CPU should be
   able to free up TX entries faster than they can be transmitted on
   gigabit links :-)

2) If the investigation in #1 deems the breakout logic is necessary,
   then consistently amongst all the 5 drivers a policy should be
   implemented which is integrated with the NAPI budgetting logic.
   For example, the simplest thing to do is to pass the budget and the
   "work_done" thing down into *_clean_tx_irq() and break out if it is
   exceeded.

   As a further refinement we can say that TX work is about 1/4 the
   expense of RX work and adjust the budget checking logic to match
   that.

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
