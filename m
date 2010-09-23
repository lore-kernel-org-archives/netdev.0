From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbevf: Refactor ring parameter re-size
Date: Thu, 23 Sep 2010 15:46:25 -0700
Message-ID: <20100923224543.13046.68372.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:54577 "EHLO
	qmta02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751919Ab0IWWqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 18:46:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The function to resize the Tx/Rx rings had the potential to
dereference a NULL pointer and the code would attempt to resize
the Tx ring even if the Rx ring allocation had failed.  This
would cause some confusion in the return code semantics.  Fixed
up to just unwind the allocations if any of them fail and return
an error.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/ethtool.c |  153 +++++++++++++++++++++--------------------
 1 files changed, 79 insertions(+), 74 deletions(-)

diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtool.c
index 4680b06..4cc817a 100644
--- a/drivers/net/ixgbevf/ethtool.c
+++ b/drivers/net/ixgbevf/ethtool.c
@@ -330,10 +330,8 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbevf_ring *tx_ring = NULL, *rx_ring = NULL;
-	int i, err;
+	int i, err = 0;
 	u32 new_rx_count, new_tx_count;
-	bool need_tx_update = false;
-	bool need_rx_update = false;
 
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
@@ -355,89 +353,96 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 	while (test_and_set_bit(__IXGBEVF_RESETTING, &adapter->state))
 		msleep(1);
 
-	if (new_tx_count != adapter->tx_ring_count) {
-		tx_ring = kcalloc(adapter->num_tx_queues,
-				  sizeof(struct ixgbevf_ring), GFP_KERNEL);
-		if (!tx_ring) {
-			err = -ENOMEM;
-			goto err_setup;
-		}
-		memcpy(tx_ring, adapter->tx_ring,
-		       adapter->num_tx_queues * sizeof(struct ixgbevf_ring));
-		for (i = 0; i < adapter->num_tx_queues; i++) {
-			tx_ring[i].count = new_tx_count;
-			err = ixgbevf_setup_tx_resources(adapter,
-							 &tx_ring[i]);
-			if (err) {
-				while (i) {
-					i--;
-					ixgbevf_free_tx_resources(adapter,
-								  &tx_ring[i]);
-				}
-				kfree(tx_ring);
-				goto err_setup;
-			}
-			tx_ring[i].v_idx = adapter->tx_ring[i].v_idx;
-		}
-		need_tx_update = true;
+	/*
+	 * If the adapter isn't up and running then just set the
+	 * new parameters and scurry for the exits.
+	 */
+	if (!netif_running(adapter->netdev)) {
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			adapter->tx_ring[i].count = new_tx_count;
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			adapter->rx_ring[i].count = new_rx_count;
+		adapter->tx_ring_count = new_tx_count;
+		adapter->rx_ring_count = new_rx_count;
+		goto clear_reset;
 	}
 
-	if (new_rx_count != adapter->rx_ring_count) {
-		rx_ring = kcalloc(adapter->num_rx_queues,
-				  sizeof(struct ixgbevf_ring), GFP_KERNEL);
-		if ((!rx_ring) && (need_tx_update)) {
-			err = -ENOMEM;
-			goto err_rx_setup;
-		}
-		memcpy(rx_ring, adapter->rx_ring,
-		       adapter->num_rx_queues * sizeof(struct ixgbevf_ring));
-		for (i = 0; i < adapter->num_rx_queues; i++) {
-			rx_ring[i].count = new_rx_count;
-			err = ixgbevf_setup_rx_resources(adapter,
-							 &rx_ring[i]);
-			if (err) {
-				while (i) {
-					i--;
-					ixgbevf_free_rx_resources(adapter,
-								  &rx_ring[i]);
-				}
-				kfree(rx_ring);
-				goto err_rx_setup;
-			}
-			rx_ring[i].v_idx = adapter->rx_ring[i].v_idx;
-		}
-		need_rx_update = true;
+	tx_ring = kcalloc(adapter->num_tx_queues,
+			  sizeof(struct ixgbevf_ring), GFP_KERNEL);
+	if (!tx_ring) {
+		err = -ENOMEM;
+		goto clear_reset;
 	}
 
-err_rx_setup:
-	/* if rings need to be updated, here's the place to do it in one shot */
-	if (need_tx_update || need_rx_update) {
-		if (netif_running(netdev))
-			ixgbevf_down(adapter);
+	rx_ring = kcalloc(adapter->num_rx_queues,
+			  sizeof(struct ixgbevf_ring), GFP_KERNEL);
+	if (!rx_ring) {
+		err = -ENOMEM;
+		goto err_rx_setup;
 	}
 
-	/* tx */
-	if (need_tx_update) {
-		kfree(adapter->tx_ring);
-		adapter->tx_ring = tx_ring;
-		tx_ring = NULL;
-		adapter->tx_ring_count = new_tx_count;
+	ixgbevf_down(adapter);
+
+	memcpy(tx_ring, adapter->tx_ring,
+	       adapter->num_tx_queues * sizeof(struct ixgbevf_ring));
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		tx_ring[i].count = new_tx_count;
+		err = ixgbevf_setup_tx_resources(adapter, &tx_ring[i]);
+		if (err) {
+			while (i) {
+				i--;
+				ixgbevf_free_tx_resources(adapter,
+							  &tx_ring[i]);
+			}
+			goto err_tx_ring_setup;
+		}
+		tx_ring[i].v_idx = adapter->tx_ring[i].v_idx;
 	}
 
-	/* rx */
-	if (need_rx_update) {
-		kfree(adapter->rx_ring);
-		adapter->rx_ring = rx_ring;
-		rx_ring = NULL;
-		adapter->rx_ring_count = new_rx_count;
+	memcpy(rx_ring, adapter->rx_ring,
+	       adapter->num_rx_queues * sizeof(struct ixgbevf_ring));
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		rx_ring[i].count = new_rx_count;
+		err = ixgbevf_setup_rx_resources(adapter, &rx_ring[i]);
+		if (err) {
+			while (i) {
+				i--;
+				ixgbevf_free_rx_resources(adapter,
+							  &rx_ring[i]);
+			}
+				goto err_rx_ring_setup;
+		}
+		rx_ring[i].v_idx = adapter->rx_ring[i].v_idx;
 	}
 
+	/*
+	 * Only switch to new rings if all the prior allocations
+	 * and ring setups have succeeded.
+	 */
+	kfree(adapter->tx_ring);
+	adapter->tx_ring = tx_ring;
+	adapter->tx_ring_count = new_tx_count;
+
+	kfree(adapter->rx_ring);
+	adapter->rx_ring = rx_ring;
+	adapter->rx_ring_count = new_rx_count;
+
 	/* success! */
-	err = 0;
-	if (netif_running(netdev))
-		ixgbevf_up(adapter);
+	ixgbevf_up(adapter);
+
+	goto clear_reset;
+
+err_rx_ring_setup:
+	for(i = 0; i < adapter->num_tx_queues; i++)
+		ixgbevf_free_tx_resources(adapter, &tx_ring[i]);
+
+err_tx_ring_setup:
+	kfree(rx_ring);
+
+err_rx_setup:
+	kfree(tx_ring);
 
-err_setup:
+clear_reset:
 	clear_bit(__IXGBEVF_RESETTING, &adapter->state);
 	return err;
 }

