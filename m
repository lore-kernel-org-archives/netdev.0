From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/4] e1000: Redo netpoll fix to address community concerns
Date: Fri, 14 Jul 2006 16:29:43 -0700
Message-ID: <20060714232943.22378.74953.stgit@gitlost.site>
References: <20060714232452.22378.32866.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:8457 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1945908AbWGNXXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 19:23:00 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060714232452.22378.32866.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The original suggested fix for netpoll was found to be racy on SMP
kernels. While it is highly unlikely that this race would ever be seen
in the real world due to current netpoll usage models, we implemented
this updated fix to address concerns.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   39 ++++++++++++++++-----------------------
 1 files changed, 16 insertions(+), 23 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 6d3d419..1c6bcad 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3387,8 +3387,8 @@ e1000_intr(int irq, void *data, struct p
 		E1000_WRITE_REG(hw, IMC, ~0);
 		E1000_WRITE_FLUSH(hw);
 	}
-	if (likely(netif_rx_schedule_prep(&adapter->polling_netdev[0])))
-		__netif_rx_schedule(&adapter->polling_netdev[0]);
+	if (likely(netif_rx_schedule_prep(netdev)))
+		__netif_rx_schedule(netdev);
 	else
 		e1000_irq_enable(adapter);
 #else
@@ -3431,34 +3431,26 @@ e1000_clean(struct net_device *poll_dev,
 {
 	struct e1000_adapter *adapter;
 	int work_to_do = min(*budget, poll_dev->quota);
-	int tx_cleaned = 0, i = 0, work_done = 0;
+	int tx_cleaned = 0, work_done = 0;
 
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
 
 	/* Keep link state information with original netdev */
-	if (!netif_carrier_ok(adapter->netdev))
+	if (!netif_carrier_ok(poll_dev))
 		goto quit_polling;
 
-	while (poll_dev != &adapter->polling_netdev[i]) {
-		i++;
-		BUG_ON(i == adapter->num_rx_queues);
-	}
-
-	if (likely(adapter->num_tx_queues == 1)) {
-		/* e1000_clean is called per-cpu.  This lock protects
-		 * tx_ring[0] from being cleaned by multiple cpus
-		 * simultaneously.  A failure obtaining the lock means
-		 * tx_ring[0] is currently being cleaned anyway. */
-		if (spin_trylock(&adapter->tx_queue_lock)) {
-			tx_cleaned = e1000_clean_tx_irq(adapter,
-							&adapter->tx_ring[0]);
-			spin_unlock(&adapter->tx_queue_lock);
-		}
-	} else
-		tx_cleaned = e1000_clean_tx_irq(adapter, &adapter->tx_ring[i]);
+	/* e1000_clean is called per-cpu.  This lock protects
+	 * tx_ring[0] from being cleaned by multiple cpus
+	 * simultaneously.  A failure obtaining the lock means
+	 * tx_ring[0] is currently being cleaned anyway. */
+	if (spin_trylock(&adapter->tx_queue_lock)) {
+		tx_cleaned = e1000_clean_tx_irq(adapter,
+		                                &adapter->tx_ring[0]);
+		spin_unlock(&adapter->tx_queue_lock);
+	}
 
-	adapter->clean_rx(adapter, &adapter->rx_ring[i],
+	adapter->clean_rx(adapter, &adapter->rx_ring[0],
 	                  &work_done, work_to_do);
 
 	*budget -= work_done;
@@ -3466,7 +3458,7 @@ e1000_clean(struct net_device *poll_dev,
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
 	if ((!tx_cleaned && (work_done == 0)) ||
-	   !netif_running(adapter->netdev)) {
+	   !netif_running(poll_dev)) {
 quit_polling:
 		netif_rx_complete(poll_dev);
 		e1000_irq_enable(adapter);
@@ -4752,6 +4744,7 @@ static void
 e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+
 	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev, NULL);
 	e1000_clean_tx_irq(adapter, adapter->tx_ring);



--
Auke Kok <auke-jan.h.kok@intel.com>
