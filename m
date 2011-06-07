From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 33/40] ixgbe: move setting RSC into a separate function
Date: Tue,  7 Jun 2011 05:33:08 -0700
Message-ID: <1307449995-9458-34-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4748 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753352Ab1FGMdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:32 -0400
In-Reply-To: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Move setting RSC into a separate function
to allow for reuse in other parts of the code.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |   34 ++++++++++++++++++----------------
 1 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 552cb62..85a77ce 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -458,6 +458,21 @@ static int ixgbe_set_rx_csum(struct net_device *netdev, u32 data)
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
@@ -2280,25 +2295,12 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
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
1.7.5.2

