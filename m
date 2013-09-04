From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  8/9] igb: Implementation to report advertised/supported link on i354 devices
Date: Wed,  4 Sep 2013 06:08:55 -0700
Message-ID: <1378300136-26003-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56125 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934439Ab3IDNJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 09:09:03 -0400
In-Reply-To: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

This patch changes the way we report supported/advertised link for i354
devices, especially for 2.5 GB. Instead of reporting 2.5 GB for all i354
devices erroneously, check first, if it is 2.5 GB capable.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index ce9b5a9..48cbc83 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -172,10 +172,7 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 				   SUPPORTED_Autoneg |
 				   SUPPORTED_Pause);
 		ecmd->advertising = ADVERTISED_FIBRE;
-		if (hw->mac.type == e1000_i354) {
-			ecmd->supported |= SUPPORTED_2500baseX_Full;
-			ecmd->advertising |= ADVERTISED_2500baseX_Full;
-		}
+
 		if ((eth_flags->e1000_base_lx) || (eth_flags->e1000_base_sx)) {
 			ecmd->supported |= SUPPORTED_1000baseT_Full;
 			ecmd->advertising |= ADVERTISED_1000baseT_Full;
@@ -209,16 +206,23 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	status = rd32(E1000_STATUS);
 
 	if (status & E1000_STATUS_LU) {
-		if ((hw->mac.type == e1000_i354) &&
-		    (status & E1000_STATUS_2P5_SKU) &&
-		    !(status & E1000_STATUS_2P5_SKU_OVER))
-			ecmd->speed = SPEED_2500;
-		else if (status & E1000_STATUS_SPEED_1000)
+		if (hw->mac.type == e1000_i354) {
+			if ((status & E1000_STATUS_2P5_SKU) &&
+			    !(status & E1000_STATUS_2P5_SKU_OVER)) {
+				ecmd->supported = SUPPORTED_2500baseX_Full;
+				ecmd->advertising = ADVERTISED_2500baseX_Full;
+				ecmd->speed = SPEED_2500;
+			} else {
+				ecmd->supported = SUPPORTED_1000baseT_Full;
+				ecmd->advertising = ADVERTISED_1000baseT_Full;
+			}
+		} else if (status & E1000_STATUS_SPEED_1000) {
 			ecmd->speed = SPEED_1000;
-		else if (status & E1000_STATUS_SPEED_100)
+		} else if (status & E1000_STATUS_SPEED_100) {
 			ecmd->speed = SPEED_100;
-		else
+		} else {
 			ecmd->speed = SPEED_10;
+		}
 		if ((status & E1000_STATUS_FD) ||
 		    hw->phy.media_type != e1000_media_type_copper)
 			ecmd->duplex = DUPLEX_FULL;
-- 
1.8.3.1
