From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/12] ixgbe: move setting RSC into a separate function
Date: Wed, 22 Jun 2011 18:44:32 -0700
Message-ID: <1308793476-11596-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308793476-11596-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:60779 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932298Ab1FWBoo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 21:44:44 -0400
In-Reply-To: <1308793476-11596-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Move setting RSC into a separate function to allow for reuse in other
parts of the code.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |   34 ++++++++++++++++++----------------
 1 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index b20609f..791b388 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -459,6 +459,21 @@ static int ixgbe_set_rx_csum(struct net_device *netdev, u32 data)
 	return 0;
 }
 
+static void ixgbe_set_rsc(struct ixgbe_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		struct ixgbe_ring *ring = adapter->rx_ring[i];
+		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
+			set_ring_rsc_enabled(ring);
+			ixgbe_configure_rscctl(adapter, ring);
+		} else {
+			ixgbe_clear_rscctl(adapter, ring);
+		}
+	}
+}
+
 static u32 ixgbe_get_tx_csum(struct net_device *netdev)
 {
 	return (netdev->features & NETIF_F_IP_CSUM) != 0;
@@ -2281,25 +2296,12 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 		} else {
 			adapter->flags2 ^= IXGBE_FLAG2_RSC_ENABLED;
 			switch (adapter->hw.mac.type) {
+			case ixgbe_mac_X540:
+				ixgbe_set_rsc(adapter);
+				break;
 			case ixgbe_mac_82599EB:
 				need_reset = true;
 				break;
-			case ixgbe_mac_X540: {
-				int i;
-				for (i = 0; i < adapter->num_rx_queues; i++) {
-					struct ixgbe_ring *ring =
-					                  adapter->rx_ring[i];
-					if (adapter->flags2 &
-					    IXGBE_FLAG2_RSC_ENABLED) {
-						ixgbe_configure_rscctl(adapter,
-						                       ring);
-					} else {
-						ixgbe_clear_rscctl(adapter,
-						                   ring);
-					}
-				}
-			}
-				break;
 			default:
 				break;
 			}
-- 
1.7.5.4

