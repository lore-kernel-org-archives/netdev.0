From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/3] ixgbe: fix memory leak when resizing rings while
	interface is down
Date: Mon, 26 Oct 2009 14:32:05 -0700
Message-ID: <20091026213205.9993.32014.stgit@localhost.localdomain>
References: <20091026213147.9993.9778.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:44113 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753482AbZJZVfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 17:35:41 -0400
In-Reply-To: <20091026213147.9993.9778.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch resolves a memory leak that occurs when you resize the rings via
the ethtool -G option while the interface is down.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index fa314cb..856c18c 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -798,7 +798,7 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *temp_tx_ring, *temp_rx_ring;
-	int i, err;
+	int i, err = 0;
 	u32 new_rx_count, new_tx_count;
 	bool need_update = false;
 
@@ -822,6 +822,16 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 		msleep(1);
 
+	if (!netif_running(adapter->netdev)) {
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			adapter->tx_ring[i].count = new_tx_count;
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			adapter->rx_ring[i].count = new_rx_count;
+		adapter->tx_ring_count = new_tx_count;
+		adapter->rx_ring_count = new_rx_count;
+		goto err_setup;
+	}
+
 	temp_tx_ring = kcalloc(adapter->num_tx_queues,
 	                       sizeof(struct ixgbe_ring), GFP_KERNEL);
 	if (!temp_tx_ring) {
@@ -879,8 +889,7 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 
 	/* if rings need to be updated, here's the place to do it in one shot */
 	if (need_update) {
-		if (netif_running(netdev))
-			ixgbe_down(adapter);
+		ixgbe_down(adapter);
 
 		/* tx */
 		if (new_tx_count != adapter->tx_ring_count) {
@@ -897,13 +906,8 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 			temp_rx_ring = NULL;
 			adapter->rx_ring_count = new_rx_count;
 		}
-	}
-
-	/* success! */
-	err = 0;
-	if (netif_running(netdev))
 		ixgbe_up(adapter);
-
+	}
 err_setup:
 	clear_bit(__IXGBE_RESETTING, &adapter->state);
 	return err;

