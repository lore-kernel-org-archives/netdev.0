From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] ixgbe: remove needless queuing for L4 ptp packets
Date: Thu, 22 Nov 2012 02:11:12 -0800
Message-ID: <1353579077-12097-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1353579077-12097-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8499 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753989Ab2KVSfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 13:35:53 -0500
In-Reply-To: <1353579077-12097-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch removes the queuing that was previously done for L4 packets
as it is not needed. The filter does not provide functionality, and it
is possible that queue setup here could trample settings done else-where
in the driver. (for example it may use a queue which isn't setup.)
Setting of the queue is not required for hardware timestamping and could
have inadverdent side effects.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 34 ++--------------------------
 1 file changed, 2 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 29ca293..1a751c9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -633,8 +633,7 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 	struct hwtstamp_config config;
 	u32 tsync_tx_ctl = IXGBE_TSYNCTXCTL_ENABLED;
 	u32 tsync_rx_ctl = IXGBE_TSYNCRXCTL_ENABLED;
-	u32 tsync_rx_mtrl = 0;
-	bool is_l4 = false;
+	u32 tsync_rx_mtrl = PTP_EV_PORT << 16;
 	bool is_l2 = false;
 	u32 regval;
 
@@ -657,16 +656,15 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 	switch (config.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
 		tsync_rx_ctl = 0;
+		tsync_rx_mtrl = 0;
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_L4_V1;
 		tsync_rx_mtrl = IXGBE_RXMTRL_V1_SYNC_MSG;
-		is_l4 = true;
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
 		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_L4_V1;
 		tsync_rx_mtrl = IXGBE_RXMTRL_V1_DELAY_REQ_MSG;
-		is_l4 = true;
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
@@ -679,7 +677,6 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
 		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_EVENT_V2;
 		is_l2 = true;
-		is_l4 = true;
 		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
@@ -713,33 +710,6 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 	else
 		IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_1588), 0);
 
-#define PTP_PORT 319
-	/* L4 Queue Filter[3]: filter by destination port and protocol */
-	if (is_l4) {
-		u32 ftqf = (IXGBE_FTQF_PROTOCOL_UDP /* UDP */
-			    | IXGBE_FTQF_POOL_MASK_EN /* Pool not compared */
-			    | IXGBE_FTQF_QUEUE_ENABLE);
-
-		ftqf |= ((IXGBE_FTQF_PROTOCOL_COMP_MASK /* protocol check */
-			  & IXGBE_FTQF_DEST_PORT_MASK /* dest check */
-			  & IXGBE_FTQF_SOURCE_PORT_MASK) /* source check */
-			 << IXGBE_FTQF_5TUPLE_MASK_SHIFT);
-
-		IXGBE_WRITE_REG(hw, IXGBE_L34T_IMIR(3),
-				(3 << IXGBE_IMIR_RX_QUEUE_SHIFT_82599 |
-				 IXGBE_IMIR_SIZE_BP_82599));
-
-		/* enable port check */
-		IXGBE_WRITE_REG(hw, IXGBE_SDPQF(3),
-				(htons(PTP_PORT) |
-				 htons(PTP_PORT) << 16));
-
-		IXGBE_WRITE_REG(hw, IXGBE_FTQF(3), ftqf);
-
-		tsync_rx_mtrl |= PTP_PORT << 16;
-	} else {
-		IXGBE_WRITE_REG(hw, IXGBE_FTQF(3), 0);
-	}
 
 	/* enable/disable TX */
 	regval = IXGBE_READ_REG(hw, IXGBE_TSYNCTXCTL);
-- 
1.7.11.7
