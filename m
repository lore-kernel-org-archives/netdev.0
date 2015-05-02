From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] e1000e: Do not allow CRC stripping to be disabled on 82579 w/ jumbo frames
Date: Sat,  2 May 2015 03:42:31 -0700
Message-ID: <1430563358-113833-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:8026 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751786AbbEBKmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2015 06:42:46 -0400
In-Reply-To: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

 The driver wasn't allowing jumbo frames to be
 enabled when CRC stripping was disabled, however it was allowing CRC
 stripping to be disabled while jumbo frames were enabled.  This fixes that by
 making it so that the NETIF_F_RXFCS flag cannot be set when jumbo frames are
 enabled on 82579 and newer parts.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 68913d1..7dd2c11 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6676,6 +6676,19 @@ static void e1000_eeprom_checks(struct e1000_adapter *adapter)
 	}
 }
 
+static netdev_features_t e1000_fix_features(struct net_device *netdev,
+					    netdev_features_t features)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+
+	/* Jumbo frame workaround on 82579 and newer requires CRC be stripped */
+	if ((hw->mac.type >= e1000_pch2lan) && (netdev->mtu > ETH_DATA_LEN))
+		features &= ~NETIF_F_RXFCS;
+
+	return features;
+}
+
 static int e1000_set_features(struct net_device *netdev,
 			      netdev_features_t features)
 {
@@ -6732,6 +6745,7 @@ static const struct net_device_ops e1000e_netdev_ops = {
 	.ndo_poll_controller	= e1000_netpoll,
 #endif
 	.ndo_set_features = e1000_set_features,
+	.ndo_fix_features = e1000_fix_features,
 };
 
 /**
-- 
2.1.0
