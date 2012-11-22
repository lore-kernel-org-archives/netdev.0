From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] igb: Update PTP Rx filters
Date: Thu, 22 Nov 2012 02:11:15 -0800
Message-ID: <1353579077-12097-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1353579077-12097-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26845 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752408Ab2KVSen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 13:34:43 -0500
In-Reply-To: <1353579077-12097-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Update the filters to be more consistent with what the driver wants to do.
For example, for devices that timestamp all packets, report that the filter
is set for timestamping all packets.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 47 ++++++++++++++------------------
 1 file changed, 20 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index aa10f69..ab34297 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -553,18 +553,6 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 	case HWTSTAMP_FILTER_NONE:
 		tsync_rx_ctl = 0;
 		break;
-	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
-	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
-	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
-	case HWTSTAMP_FILTER_ALL:
-		/*
-		 * register TSYNCRXCFG must be set, therefore it is not
-		 * possible to time stamp both Sync and Delay_Req messages
-		 * => fall back to time stamping all packets
-		 */
-		tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_ALL;
-		config.rx_filter = HWTSTAMP_FILTER_ALL;
-		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 		tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_L4_V1;
 		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V1_SYNC_MESSAGE;
@@ -575,31 +563,33 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V1_DELAY_REQ_MESSAGE;
 		is_l4 = true;
 		break;
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
-		tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_L2_L4_V2;
-		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V2_SYNC_MESSAGE;
-		is_l2 = true;
-		is_l4 = true;
-		config.rx_filter = HWTSTAMP_FILTER_SOME;
-		break;
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
 	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
 	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
-		tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_L2_L4_V2;
-		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V2_DELAY_REQ_MESSAGE;
-		is_l2 = true;
-		is_l4 = true;
-		config.rx_filter = HWTSTAMP_FILTER_SOME;
-		break;
-	case HWTSTAMP_FILTER_PTP_V2_EVENT:
-	case HWTSTAMP_FILTER_PTP_V2_SYNC:
-	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
 		tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_EVENT_V2;
 		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 		is_l2 = true;
 		is_l4 = true;
 		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_ALL:
+		/* 82576 cannot timestamp all packets, which it needs to do to
+		 * support both V1 Sync and Delay_Req messages
+		 */
+		if (hw->mac.type != e1000_82576) {
+			tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_ALL;
+			config.rx_filter = HWTSTAMP_FILTER_ALL;
+			break;
+		}
+		/* fall through */
 	default:
+		config.rx_filter = HWTSTAMP_FILTER_NONE;
 		return -ERANGE;
 	}
 
@@ -617,6 +607,9 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 	if ((hw->mac.type >= e1000_82580) && tsync_rx_ctl) {
 		tsync_rx_ctl = E1000_TSYNCRXCTL_ENABLED;
 		tsync_rx_ctl |= E1000_TSYNCRXCTL_TYPE_ALL;
+		config.rx_filter = HWTSTAMP_FILTER_ALL;
+		is_l2 = true;
+		is_l4 = true;
 
 		if ((hw->mac.type == e1000_i210) ||
 		    (hw->mac.type == e1000_i211)) {
-- 
1.7.11.7
