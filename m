From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 35/40] ixgbe: disable RSC when Rx checksum is off
Date: Tue,  7 Jun 2011 05:33:10 -0700
Message-ID: <1307449995-9458-36-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16453 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753367Ab1FGMdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:32 -0400
In-Reply-To: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Disabling Rx checksumming leads to performance degradation due to
RSC causing packets to have incorrect checksums.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |   44 +++++++++++++++++++++++++++---------
 1 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 3dd0f82..f96193d 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -457,17 +457,6 @@ static u32 ixgbe_get_rx_csum(struct net_device *netdev)
 	return adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED;
 }
 
-static int ixgbe_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	if (data)
-		adapter->flags |= IXGBE_FLAG_RX_CSUM_ENABLED;
-	else
-		adapter->flags &= ~IXGBE_FLAG_RX_CSUM_ENABLED;
-
-	return 0;
-}
-
 static void ixgbe_set_rsc(struct ixgbe_adapter *adapter)
 {
 	int i;
@@ -483,6 +472,39 @@ static void ixgbe_set_rsc(struct ixgbe_adapter *adapter)
 	}
 }
 
+static int ixgbe_set_rx_csum(struct net_device *netdev, u32 data)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	bool need_reset = false;
+
+	if (data) {
+		adapter->flags |= IXGBE_FLAG_RX_CSUM_ENABLED;
+	} else {
+		adapter->flags &= ~IXGBE_FLAG_RX_CSUM_ENABLED;
+
+		if (adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) {
+			adapter->flags2 &= ~IXGBE_FLAG2_RSC_ENABLED;
+			netdev->features &= ~NETIF_F_LRO;
+		}
+
+		switch (adapter->hw.mac.type) {
+		case ixgbe_mac_X540:
+			ixgbe_set_rsc(adapter);
+			break;
+		case ixgbe_mac_82599EB:
+			need_reset = true;
+			break;
+		default:
+			break;
+		}
+	}
+
+	if (need_reset)
+		ixgbe_do_reset(netdev);
+
+	return 0;
+}
+
 static u32 ixgbe_get_tx_csum(struct net_device *netdev)
 {
 	return (netdev->features & NETIF_F_IP_CSUM) != 0;
-- 
1.7.5.2

