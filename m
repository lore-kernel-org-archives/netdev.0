From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/5] ixgbe: incorrect XDP ring accounting in ethtool tx_frame param
Date: Mon,  9 Oct 2017 08:12:51 -0700
Message-ID: <20171009151251.53939-6-jeffrey.t.kirsher@intel.com>
References: <20171009151251.53939-1-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:48022 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754295AbdJIPNP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 11:13:15 -0400
In-Reply-To: <20171009151251.53939-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>

Changing the TX ring parameters with an XDP program attached may
cause the XDP queues to be cleared and the TX rings to be incorrectly
configured.

Fix by doing correct ring accounting in setup call.

Fixes: 33fdc82f0883 ("ixgbe: add support for XDP_TX action")
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 72c565712a5f..c3e7a8191128 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1048,7 +1048,7 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *temp_ring;
-	int i, err = 0;
+	int i, j, err = 0;
 	u32 new_rx_count, new_tx_count;
 
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
@@ -1085,8 +1085,8 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 	}
 
 	/* allocate temporary buffer to store rings in */
-	i = max_t(int, adapter->num_tx_queues, adapter->num_rx_queues);
-	i = max_t(int, i, adapter->num_xdp_queues);
+	i = max_t(int, adapter->num_tx_queues + adapter->num_xdp_queues,
+		  adapter->num_rx_queues);
 	temp_ring = vmalloc(i * sizeof(struct ixgbe_ring));
 
 	if (!temp_ring) {
@@ -1118,8 +1118,8 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 			}
 		}
 
-		for (i = 0; i < adapter->num_xdp_queues; i++) {
-			memcpy(&temp_ring[i], adapter->xdp_ring[i],
+		for (j = 0; j < adapter->num_xdp_queues; j++, i++) {
+			memcpy(&temp_ring[i], adapter->xdp_ring[j],
 			       sizeof(struct ixgbe_ring));
 
 			temp_ring[i].count = new_tx_count;
@@ -1139,10 +1139,10 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 			memcpy(adapter->tx_ring[i], &temp_ring[i],
 			       sizeof(struct ixgbe_ring));
 		}
-		for (i = 0; i < adapter->num_xdp_queues; i++) {
-			ixgbe_free_tx_resources(adapter->xdp_ring[i]);
+		for (j = 0; j < adapter->num_xdp_queues; j++, i++) {
+			ixgbe_free_tx_resources(adapter->xdp_ring[j]);
 
-			memcpy(adapter->xdp_ring[i], &temp_ring[i],
+			memcpy(adapter->xdp_ring[j], &temp_ring[i],
 			       sizeof(struct ixgbe_ring));
 		}
 
-- 
2.14.2
