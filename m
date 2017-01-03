From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/21] ixgbe: Fix incorrect bitwise operations of PTP Rx timestamp flags
Date: Tue,  3 Jan 2017 13:07:49 -0800
Message-ID: <20170103210757.38847-14-jeffrey.t.kirsher@intel.com>
References: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Cc: Yusuke Suzuki <yus-suzuki@uf.jp.nec.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25260 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966319AbdACVIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 16:08:16 -0500
In-Reply-To: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yusuke Suzuki <yus-suzuki@uf.jp.nec.com>

Rx timestamp does not work on 82599 and X540 because bitwise operation
of RX_HWTSTAMP flags is incorrect and ixgbe_ptp_rx_hwtstamp() is never
called. This patch fixes it to enable Rx timestamp on 82599 and X540.

Without this fix:
ptp4l[278.730]: selected /dev/ptp8 as PTP clock
ptp4l[278.733]: port 1: INITIALIZING to LISTENING on INITIALIZE
ptp4l[278.733]: port 0: INITIALIZING to LISTENING on INITIALIZE
ptp4l[278.834]: port 1: received SYNC without timestamp
ptp4l[278.835]: port 1: new foreign master 1c3947.fffe.60f9cc-1
ptp4l[279.834]: port 1: received SYNC without timestamp
ptp4l[280.834]: port 1: received SYNC without timestamp
ptp4l[281.834]: port 1: received SYNC without timestamp
ptp4l[282.834]: port 1: received SYNC without timestamp
ptp4l[282.835]: selected best master clock 1c3947.fffe.60f9cc
ptp4l[282.835]: port 1: LISTENING to UNCALIBRATED on RS_SLAVE
ptp4l[283.834]: port 1: received SYNC without timestamp

With this fix:
ptp4l[239.154]: selected /dev/ptp8 as PTP clock
ptp4l[239.157]: port 1: INITIALIZING to LISTENING on INITIALIZE
ptp4l[239.157]: port 0: INITIALIZING to LISTENING on INITIALIZE
ptp4l[240.989]: port 1: new foreign master 1c3947.fffe.60f9cc-1
ptp4l[244.989]: selected best master clock 1c3947.fffe.60f9cc
ptp4l[244.989]: port 1: LISTENING to UNCALIBRATED on RS_SLAVE
ptp4l[246.977]: master offset -899583339542096 s0 freq      +0 path delay     16222
ptp4l[247.977]: master offset -899583339617265 s1 freq  -75169 path delay     16177
ptp4l[248.977]: master offset       -130 s2 freq  -75299 path delay     16177
ptp4l[248.977]: port 1: UNCALIBRATED to SLAVE on MASTER_CLOCK_SELECTED
ptp4l[249.977]: master offset         -9 s2 freq  -75217 path delay     16177
ptp4l[250.977]: master offset         88 s2 freq  -75123 path delay     16132

Fixes: a9763f3cb54c ("ixgbe: Update PTP to support X550EM_x devices")
Signed-off-by: Yusuke Suzuki <yus-suzuki@uf.jp.nec.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 1efb404..ef0635e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -858,14 +858,14 @@ static int ixgbe_ptp_set_timestamp_mode(struct ixgbe_adapter *adapter,
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_L4_V1;
 		tsync_rx_mtrl |= IXGBE_RXMTRL_V1_SYNC_MSG;
-		adapter->flags &= ~(IXGBE_FLAG_RX_HWTSTAMP_ENABLED |
-				    IXGBE_FLAG_RX_HWTSTAMP_IN_REGISTER);
+		adapter->flags |= (IXGBE_FLAG_RX_HWTSTAMP_ENABLED |
+				   IXGBE_FLAG_RX_HWTSTAMP_IN_REGISTER);
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
 		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_L4_V1;
 		tsync_rx_mtrl |= IXGBE_RXMTRL_V1_DELAY_REQ_MSG;
-		adapter->flags &= ~(IXGBE_FLAG_RX_HWTSTAMP_ENABLED |
-				    IXGBE_FLAG_RX_HWTSTAMP_IN_REGISTER);
+		adapter->flags |= (IXGBE_FLAG_RX_HWTSTAMP_ENABLED |
+				   IXGBE_FLAG_RX_HWTSTAMP_IN_REGISTER);
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
@@ -879,8 +879,8 @@ static int ixgbe_ptp_set_timestamp_mode(struct ixgbe_adapter *adapter,
 		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_EVENT_V2;
 		is_l2 = true;
 		config->rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
-		adapter->flags &= ~(IXGBE_FLAG_RX_HWTSTAMP_ENABLED |
-				    IXGBE_FLAG_RX_HWTSTAMP_IN_REGISTER);
+		adapter->flags |= (IXGBE_FLAG_RX_HWTSTAMP_ENABLED |
+				   IXGBE_FLAG_RX_HWTSTAMP_IN_REGISTER);
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
 	case HWTSTAMP_FILTER_ALL:
-- 
2.9.3
