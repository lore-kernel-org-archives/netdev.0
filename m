From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/3] igb: fix memory leak when setting ring size while
	interface is down
Date: Mon, 26 Oct 2009 14:31:47 -0700
Message-ID: <20091026213147.9993.9778.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:56906 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752801AbZJZVfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 17:35:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Changing ring sizes while the interface was down was causing a double
allocation of the receive and transmit rings.  This issue is amplified when
there are multiple rings enabled.  To prevent this we need to add an
additional check which will just update the ring counts when the interface
is not up and skip the allocation steps.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |   35 ++++++++++++++++++++++-------------
 1 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index d004c35..aab3d97 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -731,7 +731,7 @@ static int igb_set_ringparam(struct net_device *netdev,
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct igb_ring *temp_ring;
-	int i, err;
+	int i, err = 0;
 	u32 new_rx_count, new_tx_count;
 
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
@@ -751,18 +751,30 @@ static int igb_set_ringparam(struct net_device *netdev,
 		return 0;
 	}
 
+	while (test_and_set_bit(__IGB_RESETTING, &adapter->state))
+		msleep(1);
+
+	if (!netif_running(adapter->netdev)) {
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			adapter->tx_ring[i].count = new_tx_count;
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			adapter->rx_ring[i].count = new_rx_count;
+		adapter->tx_ring_count = new_tx_count;
+		adapter->rx_ring_count = new_rx_count;
+		goto clear_reset;
+	}
+
 	if (adapter->num_tx_queues > adapter->num_rx_queues)
 		temp_ring = vmalloc(adapter->num_tx_queues * sizeof(struct igb_ring));
 	else
 		temp_ring = vmalloc(adapter->num_rx_queues * sizeof(struct igb_ring));
-	if (!temp_ring)
-		return -ENOMEM;
 
-	while (test_and_set_bit(__IGB_RESETTING, &adapter->state))
-		msleep(1);
+	if (!temp_ring) {
+		err = -ENOMEM;
+		goto clear_reset;
+	}
 
-	if (netif_running(adapter->netdev))
-		igb_down(adapter);
+	igb_down(adapter);
 
 	/*
 	 * We can't just free everything and then setup again,
@@ -819,14 +831,11 @@ static int igb_set_ringparam(struct net_device *netdev,
 
 		adapter->rx_ring_count = new_rx_count;
 	}
-
-	err = 0;
 err_setup:
-	if (netif_running(adapter->netdev))
-		igb_up(adapter);
-
-	clear_bit(__IGB_RESETTING, &adapter->state);
+	igb_up(adapter);
 	vfree(temp_ring);
+clear_reset:
+	clear_bit(__IGB_RESETTING, &adapter->state);
 	return err;
 }
 

