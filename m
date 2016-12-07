From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/19] i40e: defeature support for PTP L4 frame detection on XL710
Date: Wed,  7 Dec 2016 14:19:12 -0800
Message-ID: <20161207221918.57932-14-jeffrey.t.kirsher@intel.com>
References: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:28873 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933444AbcLGWUT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 17:20:19 -0500
In-Reply-To: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A product decision has been made to defeature detection of PTP frames
over L4 (UDP) on the XL710 MAC. Do not advertise support for L4
timestamping.

Change-ID: I41fbb0f84ebb27c43e23098c08156f2625c6ee06
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 15 +++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  3 ++-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c     | 21 +++++++++++++++------
 4 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index b8f2978..f1d838f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -360,6 +360,7 @@ struct i40e_pf {
 #define I40E_FLAG_PF_MAC			BIT_ULL(50)
 #define I40E_FLAG_TRUE_PROMISC_SUPPORT		BIT_ULL(51)
 #define I40E_FLAG_HAVE_CRT_RETIMER		BIT_ULL(52)
+#define I40E_FLAG_PTP_L4_CAPABLE		BIT_ULL(53)
 
 	/* tracks features that get auto disabled by errors */
 	u64 auto_disable_flags;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 935160a..cc1465a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1681,8 +1681,19 @@ static int i40e_get_ts_info(struct net_device *dev,
 	info->tx_types = BIT(HWTSTAMP_TX_OFF) | BIT(HWTSTAMP_TX_ON);
 
 	info->rx_filters = BIT(HWTSTAMP_FILTER_NONE) |
-			   BIT(HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
-			   BIT(HWTSTAMP_FILTER_PTP_V2_EVENT);
+			   BIT(HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
+			   BIT(HWTSTAMP_FILTER_PTP_V2_L2_SYNC) |
+			   BIT(HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ);
+
+	if (pf->flags & I40E_FLAG_PTP_L4_CAPABLE)
+		info->rx_filters |= BIT(HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+				    BIT(HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+				    BIT(HWTSTAMP_FILTER_PTP_V2_EVENT) |
+				    BIT(HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
+				    BIT(HWTSTAMP_FILTER_PTP_V2_SYNC) |
+				    BIT(HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
+				    BIT(HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
+				    BIT(HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c47e9c5..806fd56 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8699,7 +8699,8 @@ static int i40e_sw_init(struct i40e_pf *pf)
 			     I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE |
 			     I40E_FLAG_NO_PCI_LINK_CHECK |
 			     I40E_FLAG_USE_SET_LLDP_MIB |
-			     I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
+			     I40E_FLAG_GENEVE_OFFLOAD_CAPABLE |
+			     I40E_FLAG_PTP_L4_CAPABLE;
 	} else if ((pf->hw.aq.api_maj_ver > 1) ||
 		   ((pf->hw.aq.api_maj_ver == 1) &&
 		    (pf->hw.aq.api_min_ver > 4))) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 5e2272c..9e49ffa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -521,6 +521,8 @@ static int i40e_ptp_set_timestamp_mode(struct i40e_pf *pf,
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+		if (!(pf->flags & I40E_FLAG_PTP_L4_CAPABLE))
+			return -ERANGE;
 		pf->ptp_rx = true;
 		tsyntype = I40E_PRTTSYN_CTL1_V1MESSTYPE0_MASK |
 			   I40E_PRTTSYN_CTL1_TSYNTYPE_V1 |
@@ -528,19 +530,26 @@ static int i40e_ptp_set_timestamp_mode(struct i40e_pf *pf,
 		config->rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
-	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
-	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
-	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
 	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		if (!(pf->flags & I40E_FLAG_PTP_L4_CAPABLE))
+			return -ERANGE;
+		/* fall through */
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
 		pf->ptp_rx = true;
 		tsyntype = I40E_PRTTSYN_CTL1_V2MESSTYPE0_MASK |
-			   I40E_PRTTSYN_CTL1_TSYNTYPE_V2 |
-			   I40E_PRTTSYN_CTL1_UDP_ENA_MASK;
-		config->rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+			   I40E_PRTTSYN_CTL1_TSYNTYPE_V2;
+		if (pf->flags & I40E_FLAG_PTP_L4_CAPABLE) {
+			tsyntype |= I40E_PRTTSYN_CTL1_UDP_ENA_MASK;
+			config->rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		} else {
+			config->rx_filter = HWTSTAMP_FILTER_PTP_V2_L2_EVENT;
+		}
 		break;
 	case HWTSTAMP_FILTER_ALL:
 	default:
-- 
2.9.3
