From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/16] i40e/i40evf: Add EEE LPI stats
Date: Fri, 21 Mar 2014 05:09:51 -0700
Message-ID: <1395403806-29302-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Kevin Scott <kevin.c.scott@intel.com>,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45856 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965463AbaCUMKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:12 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Add 4 new stats to keep track of EEE LPI (Low Power Idle) state.

Change-ID: Id6316619bb0559789770288b694a54d17f8fac5c
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  5 +++++
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 15 +++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_type.h    |  5 +++++
 drivers/net/ethernet/intel/i40evf/i40e_type.h  |  5 +++++
 4 files changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 6049e63..28da412 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -114,6 +114,11 @@ static struct i40e_stats i40e_gstrings_stats[] = {
 	I40E_PF_STAT("VF_admin_queue_requests", vf_aq_requests),
 	I40E_PF_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
 	I40E_PF_STAT("rx_hwtstamp_cleared", rx_hwtstamp_cleared),
+	/* LPI stats */
+	I40E_PF_STAT("tx_lpi_status", stats.tx_lpi_status),
+	I40E_PF_STAT("rx_lpi_status", stats.rx_lpi_status),
+	I40E_PF_STAT("tx_lpi_count", stats.tx_lpi_count),
+	I40E_PF_STAT("rx_lpi_count", stats.rx_lpi_count),
 };
 
 #define I40E_QUEUE_STATS_LEN(n) \
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1133542..a1f3369 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -740,6 +740,7 @@ void i40e_update_stats(struct i40e_vsi *vsi)
 	u32 rx_page, rx_buf;
 	u64 rx_p, rx_b;
 	u64 tx_p, tx_b;
+	u32 val;
 	int i;
 	u16 q;
 
@@ -972,6 +973,20 @@ void i40e_update_stats(struct i40e_vsi *vsi)
 		i40e_stat_update32(hw, I40E_GLPRT_RJC(hw->port),
 				   pf->stat_offsets_loaded,
 				   &osd->rx_jabber, &nsd->rx_jabber);
+
+		val = rd32(hw, I40E_PRTPM_EEE_STAT);
+		nsd->tx_lpi_status =
+			       (val & I40E_PRTPM_EEE_STAT_TX_LPI_STATUS_MASK) >>
+				I40E_PRTPM_EEE_STAT_TX_LPI_STATUS_SHIFT;
+		nsd->rx_lpi_status =
+			       (val & I40E_PRTPM_EEE_STAT_RX_LPI_STATUS_MASK) >>
+				I40E_PRTPM_EEE_STAT_RX_LPI_STATUS_SHIFT;
+		i40e_stat_update32(hw, I40E_PRTPM_TLPIC,
+				   pf->stat_offsets_loaded,
+				   &osd->tx_lpi_count, &nsd->tx_lpi_count);
+		i40e_stat_update32(hw, I40E_PRTPM_RLPIC,
+				   pf->stat_offsets_loaded,
+				   &osd->rx_lpi_count, &nsd->rx_lpi_count);
 	}
 
 	pf->stat_offsets_loaded = true;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 5c902f4..d2f0b95 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -1014,6 +1014,11 @@ struct i40e_hw_port_stats {
 	u64 tx_size_big;		/* ptc9522 */
 	u64 mac_short_packet_dropped;	/* mspdc */
 	u64 checksum_error;		/* xec */
+	/* EEE LPI */
+	bool tx_lpi_status;
+	bool rx_lpi_status;
+	u64 tx_lpi_count;		/* etlpic */
+	u64 rx_lpi_count;		/* erlpic */
 };
 
 /* Checksum and Shadow RAM pointers */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 7189d6f..efe73ad 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -1020,6 +1020,11 @@ struct i40e_hw_port_stats {
 	u64 tx_size_big;		/* ptc9522 */
 	u64 mac_short_packet_dropped;	/* mspdc */
 	u64 checksum_error;		/* xec */
+	/* EEE LPI */
+	bool tx_lpi_status;
+	bool rx_lpi_status;
+	u64 tx_lpi_count;		/* etlpic */
+	u64 rx_lpi_count;		/* erlpic */
 };
 
 /* Checksum and Shadow RAM pointers */
-- 
1.8.3.1
