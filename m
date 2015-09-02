From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/19] ixgbe: Add support for reporting 2.5G link speed
Date: Tue,  1 Sep 2015 18:14:01 -0700
Message-ID: <1441156443-33381-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59488 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754620AbbIBBOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 21:14:14 -0400
In-Reply-To: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Now that we can do 2.5G link speed, we need to be able to report it.
Also change the nested triadic involved in creating the log message
to instead use a simpler switch statement to set a string pointer.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  7 ++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 27 +++++++++++++++++-------
 2 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index b0cc439..ab2edc8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -166,6 +166,8 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	/* set the supported link speeds */
 	if (supported_link & IXGBE_LINK_SPEED_10GB_FULL)
 		ecmd->supported |= SUPPORTED_10000baseT_Full;
+	if (supported_link & IXGBE_LINK_SPEED_2_5GB_FULL)
+		ecmd->supported |= SUPPORTED_2500baseX_Full;
 	if (supported_link & IXGBE_LINK_SPEED_1GB_FULL)
 		ecmd->supported |= SUPPORTED_1000baseT_Full;
 	if (supported_link & IXGBE_LINK_SPEED_100_FULL)
@@ -177,6 +179,8 @@ static int ixgbe_get_settings(struct net_device *netdev,
 			ecmd->advertising |= ADVERTISED_100baseT_Full;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
 			ecmd->advertising |= ADVERTISED_10000baseT_Full;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_2_5GB_FULL)
+			ecmd->advertising |= ADVERTISED_2500baseX_Full;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
 			ecmd->advertising |= ADVERTISED_1000baseT_Full;
 	} else {
@@ -286,6 +290,9 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		case IXGBE_LINK_SPEED_10GB_FULL:
 			ethtool_cmd_speed_set(ecmd, SPEED_10000);
 			break;
+		case IXGBE_LINK_SPEED_2_5GB_FULL:
+			ethtool_cmd_speed_set(ecmd, SPEED_2500);
+			break;
 		case IXGBE_LINK_SPEED_1GB_FULL:
 			ethtool_cmd_speed_set(ecmd, SPEED_1000);
 			break;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0853cf0..54dfad9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6380,6 +6380,7 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	struct net_device *upper;
 	struct list_head *iter;
 	u32 link_speed = adapter->link_speed;
+	const char *speed_str;
 	bool flow_rx, flow_tx;
 
 	/* only continue if link was previously down */
@@ -6417,14 +6418,24 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	if (test_bit(__IXGBE_PTP_RUNNING, &adapter->state))
 		ixgbe_ptp_start_cyclecounter(adapter);
 
-	e_info(drv, "NIC Link is Up %s, Flow Control: %s\n",
-	       (link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
-	       "10 Gbps" :
-	       (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
-	       "1 Gbps" :
-	       (link_speed == IXGBE_LINK_SPEED_100_FULL ?
-	       "100 Mbps" :
-	       "unknown speed"))),
+	switch (link_speed) {
+	case IXGBE_LINK_SPEED_10GB_FULL:
+		speed_str = "10 Gbps";
+		break;
+	case IXGBE_LINK_SPEED_2_5GB_FULL:
+		speed_str = "2.5 Gbps";
+		break;
+	case IXGBE_LINK_SPEED_1GB_FULL:
+		speed_str = "1 Gbps";
+		break;
+	case IXGBE_LINK_SPEED_100_FULL:
+		speed_str = "100 Mbps";
+		break;
+	default:
+		speed_str = "unknown speed";
+		break;
+	}
+	e_info(drv, "NIC Link is Up %s, Flow Control: %s\n", speed_str,
 	       ((flow_rx && flow_tx) ? "RX/TX" :
 	       (flow_rx ? "RX" :
 	       (flow_tx ? "TX" : "None"))));
-- 
2.4.3
