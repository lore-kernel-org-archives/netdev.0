From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 3/3] ixgbe: Fix set_ringparam in ixgbe to use the
	same memory pools.
Date: Thu, 25 Dec 2008 01:02:41 -0800
Message-ID: <20081225090241.13754.31673.stgit@lost.foo-projects.org>
References: <20081225090204.13754.25244.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:42068 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751595AbYLYJC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 04:02:59 -0500
In-Reply-To: <20081225090204.13754.25244.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

The adapter rings are kcalloc()'d, but in set_ringparam() in ixgbe_ethtool,
we replace that memory from the vmalloc() pool.  This can result in a NULL
pointer reference when trying to modify the rings at a later time, or on
device removal.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   64 +++++++++++++++++--------------------
 1 files changed, 30 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 849c1fe..67f87a7 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -712,30 +712,15 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 		return 0;
 	}
 
-	if (adapter->num_tx_queues > adapter->num_rx_queues)
-		temp_ring = vmalloc(adapter->num_tx_queues *
-		                    sizeof(struct ixgbe_ring));
-	else
-		temp_ring = vmalloc(adapter->num_rx_queues *
-		                    sizeof(struct ixgbe_ring));
+	temp_ring = kcalloc(adapter->num_tx_queues,
+	                    sizeof(struct ixgbe_ring), GFP_KERNEL);
 	if (!temp_ring)
 		return -ENOMEM;
 
 	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 		msleep(1);
 
-	if (netif_running(netdev))
-		ixgbe_down(adapter);
-
-	/*
-	 * We can't just free everything and then setup again,
-	 * because the ISRs in MSI-X mode get passed pointers
-	 * to the tx and rx ring structs.
-	 */
 	if (new_tx_count != adapter->tx_ring->count) {
-		memcpy(temp_ring, adapter->tx_ring,
-		       adapter->num_tx_queues * sizeof(struct ixgbe_ring));
-
 		for (i = 0; i < adapter->num_tx_queues; i++) {
 			temp_ring[i].count = new_tx_count;
 			err = ixgbe_setup_tx_resources(adapter, &temp_ring[i]);
@@ -747,21 +732,28 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 				}
 				goto err_setup;
 			}
+			temp_ring[i].v_idx = adapter->tx_ring[i].v_idx;
 		}
-
-		for (i = 0; i < adapter->num_tx_queues; i++)
-			ixgbe_free_tx_resources(adapter, &adapter->tx_ring[i]);
-
-		memcpy(adapter->tx_ring, temp_ring,
-		       adapter->num_tx_queues * sizeof(struct ixgbe_ring));
-
+		if (netif_running(netdev))
+			netdev->netdev_ops->ndo_stop(netdev);
+		ixgbe_reset_interrupt_capability(adapter);
+		ixgbe_napi_del_all(adapter);
+		INIT_LIST_HEAD(&netdev->napi_list);
+		kfree(adapter->tx_ring);
+		adapter->tx_ring = temp_ring;
+		temp_ring = NULL;
 		adapter->tx_ring_count = new_tx_count;
 	}
 
-	if (new_rx_count != adapter->rx_ring->count) {
-		memcpy(temp_ring, adapter->rx_ring,
-		       adapter->num_rx_queues * sizeof(struct ixgbe_ring));
+	temp_ring = kcalloc(adapter->num_rx_queues,
+	                    sizeof(struct ixgbe_ring), GFP_KERNEL);
+	if (!temp_ring) {
+		if (netif_running(netdev))
+			netdev->netdev_ops->ndo_open(netdev);
+		return -ENOMEM;
+	}
 
+	if (new_rx_count != adapter->rx_ring->count) {
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			temp_ring[i].count = new_rx_count;
 			err = ixgbe_setup_rx_resources(adapter, &temp_ring[i]);
@@ -773,13 +765,16 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 				}
 				goto err_setup;
 			}
+			temp_ring[i].v_idx = adapter->rx_ring[i].v_idx;
 		}
-
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			ixgbe_free_rx_resources(adapter, &adapter->rx_ring[i]);
-
-		memcpy(adapter->rx_ring, temp_ring,
-		       adapter->num_rx_queues * sizeof(struct ixgbe_ring));
+		if (netif_running(netdev))
+			netdev->netdev_ops->ndo_stop(netdev);
+		ixgbe_reset_interrupt_capability(adapter);
+		ixgbe_napi_del_all(adapter);
+		INIT_LIST_HEAD(&netdev->napi_list);
+		kfree(adapter->rx_ring);
+		adapter->rx_ring = temp_ring;
+		temp_ring = NULL;
 
 		adapter->rx_ring_count = new_rx_count;
 	}
@@ -787,8 +782,9 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 	/* success! */
 	err = 0;
 err_setup:
+	ixgbe_init_interrupt_scheme(adapter);
 	if (netif_running(netdev))
-		ixgbe_up(adapter);
+		netdev->netdev_ops->ndo_open(netdev);
 
 	clear_bit(__IXGBE_RESETTING, &adapter->state);
 	return err;

