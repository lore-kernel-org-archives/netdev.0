From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 9/9] ixgbe: Fix potential memory leak/driver panic issue while
	setting up Tx & Rx ring parameters
Date: Wed, 01 Apr 2009 00:35:24 -0700
Message-ID: <20090401073524.3749.21708.stgit@lost.foo-projects.org>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:59516
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760196AbZDAHfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 03:35:48 -0400
In-Reply-To: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

While setting up the ring parameters using ethtool the driver can
panic or leak memory as ixgbe_open tries to setup tx & rx resources.
The updated logic will use ixgbe_down/up after successful allocation of
tx & rx resources

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: stable@kernel.org
---

 drivers/net/ixgbe/ixgbe_ethtool.c |  101 +++++++++++++++++++++----------------
 1 files changed, 58 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 55970ec..aafc120 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -734,9 +734,10 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
                                struct ethtool_ringparam *ring)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_ring *temp_ring;
+	struct ixgbe_ring *temp_tx_ring, *temp_rx_ring;
 	int i, err;
 	u32 new_rx_count, new_tx_count;
+	bool need_update = false;
 
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
@@ -755,80 +756,94 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 		return 0;
 	}
 
-	temp_ring = kcalloc(adapter->num_tx_queues,
-	                    sizeof(struct ixgbe_ring), GFP_KERNEL);
-	if (!temp_ring)
-		return -ENOMEM;
-
 	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 		msleep(1);
 
-	if (new_tx_count != adapter->tx_ring->count) {
+	temp_tx_ring = kcalloc(adapter->num_tx_queues,
+	                       sizeof(struct ixgbe_ring), GFP_KERNEL);
+	if (!temp_tx_ring) {
+		err = -ENOMEM;
+		goto err_setup;
+	}
+
+	if (new_tx_count != adapter->tx_ring_count) {
+		memcpy(temp_tx_ring, adapter->tx_ring,
+		       adapter->num_tx_queues * sizeof(struct ixgbe_ring));
 		for (i = 0; i < adapter->num_tx_queues; i++) {
-			temp_ring[i].count = new_tx_count;
-			err = ixgbe_setup_tx_resources(adapter, &temp_ring[i]);
+			temp_tx_ring[i].count = new_tx_count;
+			err = ixgbe_setup_tx_resources(adapter,
+			                               &temp_tx_ring[i]);
 			if (err) {
 				while (i) {
 					i--;
 					ixgbe_free_tx_resources(adapter,
-					                        &temp_ring[i]);
+					                        &temp_tx_ring[i]);
 				}
 				goto err_setup;
 			}
-			temp_ring[i].v_idx = adapter->tx_ring[i].v_idx;
+			temp_tx_ring[i].v_idx = adapter->tx_ring[i].v_idx;
 		}
-		if (netif_running(netdev))
-			netdev->netdev_ops->ndo_stop(netdev);
-		ixgbe_reset_interrupt_capability(adapter);
-		ixgbe_napi_del_all(adapter);
-		INIT_LIST_HEAD(&netdev->napi_list);
-		kfree(adapter->tx_ring);
-		adapter->tx_ring = temp_ring;
-		temp_ring = NULL;
-		adapter->tx_ring_count = new_tx_count;
+		need_update = true;
 	}
 
-	temp_ring = kcalloc(adapter->num_rx_queues,
-	                    sizeof(struct ixgbe_ring), GFP_KERNEL);
-	if (!temp_ring) {
-		if (netif_running(netdev))
-			netdev->netdev_ops->ndo_open(netdev);
-		return -ENOMEM;
+	temp_rx_ring = kcalloc(adapter->num_rx_queues,
+	                       sizeof(struct ixgbe_ring), GFP_KERNEL);
+	if ((!temp_rx_ring) && (need_update)) {
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			ixgbe_free_tx_resources(adapter, &temp_tx_ring[i]);
+		kfree(temp_tx_ring);
+		err = -ENOMEM;
+		goto err_setup;
 	}
 
-	if (new_rx_count != adapter->rx_ring->count) {
+	if (new_rx_count != adapter->rx_ring_count) {
+		memcpy(temp_rx_ring, adapter->rx_ring,
+		       adapter->num_rx_queues * sizeof(struct ixgbe_ring));
 		for (i = 0; i < adapter->num_rx_queues; i++) {
-			temp_ring[i].count = new_rx_count;
-			err = ixgbe_setup_rx_resources(adapter, &temp_ring[i]);
+			temp_rx_ring[i].count = new_rx_count;
+			err = ixgbe_setup_rx_resources(adapter,
+			                               &temp_rx_ring[i]);
 			if (err) {
 				while (i) {
 					i--;
 					ixgbe_free_rx_resources(adapter,
-					                        &temp_ring[i]);
+					                      &temp_rx_ring[i]);
 				}
 				goto err_setup;
 			}
-			temp_ring[i].v_idx = adapter->rx_ring[i].v_idx;
+			temp_rx_ring[i].v_idx = adapter->rx_ring[i].v_idx;
 		}
+		need_update = true;
+	}
+
+	/* if rings need to be updated, here's the place to do it in one shot */
+	if (need_update) {
 		if (netif_running(netdev))
-			netdev->netdev_ops->ndo_stop(netdev);
-		ixgbe_reset_interrupt_capability(adapter);
-		ixgbe_napi_del_all(adapter);
-		INIT_LIST_HEAD(&netdev->napi_list);
-		kfree(adapter->rx_ring);
-		adapter->rx_ring = temp_ring;
-		temp_ring = NULL;
-
-		adapter->rx_ring_count = new_rx_count;
+			ixgbe_down(adapter);
+
+		/* tx */
+		if (new_tx_count != adapter->tx_ring_count) {
+			kfree(adapter->tx_ring);
+			adapter->tx_ring = temp_tx_ring;
+			temp_tx_ring = NULL;
+			adapter->tx_ring_count = new_tx_count;
+		}
+
+		/* rx */
+		if (new_rx_count != adapter->rx_ring_count) {
+			kfree(adapter->rx_ring);
+			adapter->rx_ring = temp_rx_ring;
+			temp_rx_ring = NULL;
+			adapter->rx_ring_count = new_rx_count;
+		}
 	}
 
 	/* success! */
 	err = 0;
-err_setup:
-	ixgbe_init_interrupt_scheme(adapter);
 	if (netif_running(netdev))
-		netdev->netdev_ops->ndo_open(netdev);
+		ixgbe_up(adapter);
 
+err_setup:
 	clear_bit(__IXGBE_RESETTING, &adapter->state);
 	return err;
 }

