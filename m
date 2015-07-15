From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/16] i40e/i40evf: Add stats to track FD ATR and SB dynamic enable state
Date: Tue, 14 Jul 2015 18:30:26 -0700
Message-ID: <1436923840-24455-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55935 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752565AbbGOBap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 21:30:45 -0400
In-Reply-To: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Since the driver can dynamically enable/disable FD ATR and SB features,
these stats help keep track of the current state and along with
fd_flush count provide a means to debug what could be going on
with the flow director filters. This will take away the need for
being verbose in our debug logs with respect to FD.

Change-ID: I29224f750fe6602391043655d18996570720377d
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 12 ++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_type.h    |  2 ++
 drivers/net/ethernet/intel/i40evf/i40e_type.h  |  2 ++
 4 files changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 9a68c65..0b68f61 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -148,7 +148,9 @@ static struct i40e_stats i40e_gstrings_stats[] = {
 	I40E_PF_STAT("fdir_flush_cnt", fd_flush_cnt),
 	I40E_PF_STAT("fdir_atr_match", stats.fd_atr_match),
 	I40E_PF_STAT("fdir_atr_tunnel_match", stats.fd_atr_tunnel_match),
+	I40E_PF_STAT("fdir_atr_status", stats.fd_atr_status),
 	I40E_PF_STAT("fdir_sb_match", stats.fd_sb_match),
+	I40E_PF_STAT("fdir_sb_status", stats.fd_sb_status),
 
 	/* LPI stats */
 	I40E_PF_STAT("tx_lpi_status", stats.tx_lpi_status),
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b44eb35..b5fc654 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1123,6 +1123,18 @@ static void i40e_update_pf_stats(struct i40e_pf *pf)
 			   pf->stat_offsets_loaded,
 			   &osd->rx_lpi_count, &nsd->rx_lpi_count);
 
+	if (pf->flags & I40E_FLAG_FD_SB_ENABLED &&
+	    !(pf->auto_disable_flags & I40E_FLAG_FD_SB_ENABLED))
+		nsd->fd_sb_status = true;
+	else
+		nsd->fd_sb_status = false;
+
+	if (pf->flags & I40E_FLAG_FD_ATR_ENABLED &&
+	    !(pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED))
+		nsd->fd_atr_status = true;
+	else
+		nsd->fd_atr_status = false;
+
 	pf->stat_offsets_loaded = true;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 9a5a75b..350c5ee 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -1134,6 +1134,8 @@ struct i40e_hw_port_stats {
 	u64 fd_atr_match;
 	u64 fd_sb_match;
 	u64 fd_atr_tunnel_match;
+	u32 fd_atr_status;
+	u32 fd_sb_status;
 	/* EEE LPI */
 	u32 tx_lpi_status;
 	u32 rx_lpi_status;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index c463ec4..068813d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -1109,6 +1109,8 @@ struct i40e_hw_port_stats {
 	u64 fd_atr_match;
 	u64 fd_sb_match;
 	u64 fd_atr_tunnel_match;
+	u32 fd_atr_status;
+	u32 fd_sb_status;
 	/* EEE LPI */
 	u32 tx_lpi_status;
 	u32 rx_lpi_status;
-- 
2.4.3
