From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] ixgbe: PTP Fix hwtstamp mode settings
Date: Thu, 14 Jun 2012 03:18:08 -0700
Message-ID: <1339669089-27955-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1339669089-27955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54251 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755654Ab2FNKSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 06:18:15 -0400
In-Reply-To: <1339669089-27955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When enabling the hwtstamp mode for Rx timestamping the V2 ptp event type
specific modes (Delay Request and Sync) have been rolled into the V2 all event
packet modes, in order to more accurately represent what hardware is doing.
Hardware always timestamps the Path delay packets when a V2 mode is selected,
regardless of what type was selected (in order to always support Path delay
mode). However this means the user selected modes of timestamping only Sync or
Delay Request is not truly supported. This patch correctly sets the mode for
the hwtstamp config and returns to the user that all V2 event packets will be
timestamped.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |   23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 174f41f..5ed8cff 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -540,6 +540,11 @@ void ixgbe_ptp_rx_hwtstamp(struct ixgbe_q_vector *q_vector,
  * type has to be specified. Matching the kind of event packet is
  * not supported, with the exception of "all V2 events regardless of
  * level 2 or 4".
+ *
+ * Since hardware always timestamps Path delay packets when timestamping V2
+ * packets, regardless of the type specified in the register, only use V2
+ * Event mode. This more accurately tells the user what the hardware is going
+ * to do anyways.
  */
 int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 			     struct ifreq *ifr, int cmd)
@@ -583,27 +588,15 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 		tsync_rx_mtrl = IXGBE_RXMTRL_V1_DELAY_REQ_MSG;
 		is_l4 = true;
 		break;
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
-		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_L2_L4_V2;
-		tsync_rx_mtrl = IXGBE_RXMTRL_V2_SYNC_MSG;
-		is_l2 = true;
-		is_l4 = true;
-		config.rx_filter = HWTSTAMP_FILTER_SOME;
-		break;
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
 	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
 	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
-		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_L2_L4_V2;
-		tsync_rx_mtrl = IXGBE_RXMTRL_V2_DELAY_REQ_MSG;
-		is_l2 = true;
-		is_l4 = true;
-		config.rx_filter = HWTSTAMP_FILTER_SOME;
-		break;
-	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
-	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
-	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_EVENT_V2;
 		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 		is_l2 = true;
-- 
1.7.10.2
