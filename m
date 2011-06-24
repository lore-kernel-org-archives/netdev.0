From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] ixgbe: disable RSC when Rx checksum is off
Date: Thu, 23 Jun 2011 23:03:15 -0700
Message-ID: <1308895397-23133-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3424 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752785Ab1FXGDh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 02:03:37 -0400
In-Reply-To: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index bb8441e..596d794 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -458,17 +458,6 @@ static u32 ixgbe_get_rx_csum(struct net_device *netdev)
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
@@ -484,6 +473,39 @@ static void ixgbe_set_rsc(struct ixgbe_adapter *adapter)
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
1.7.5.4

