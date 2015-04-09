From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH] e1000e: Do not allow CRC stripping to be disabled on 82579
 w/ jumbo frames
Date: Wed, 08 Apr 2015 18:37:07 -0700
Message-ID: <20150409013554.3231.10427.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932226AbbDIBhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 21:37:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver wasn't allowing jumbo frames to be enabled when CRC stripping
was disabled, however it was allowing CRC stripping to be disabled while
jumbo frames were enabled.  This fixes that by making it so that the
NETIF_F_RXFCS flag cannot be set when jumbo frames are enabled on 82579 and
newer parts.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index f77db9304060..5af46b8a9a16 100644
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
