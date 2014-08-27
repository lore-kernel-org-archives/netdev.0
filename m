From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] i40e: Add a FD flush counter to ethtool
Date: Wed, 27 Aug 2014 02:26:39 -0700
Message-ID: <1409131606-15011-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409131606-15011-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64375 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932797AbaH0J0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 05:26:53 -0400
In-Reply-To: <1409131606-15011-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This helps know how many times the interface had to flush and replay FD
filter table, which gives an indication on how often we are getting FD
table full situation.

Also check on certain pf states before proceeding to add or delete
filters since we can't add or delete filters if we are in those states.

Change-ID: I97f5bbbea7146833ea61af0e08ea794fccba1780
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 9 +++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 1 +
 3 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 0c6a9b9..8526950 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -252,6 +252,7 @@ struct i40e_pf {
 	u16 fd_sb_cnt_idx;
 	u16 fd_atr_cnt_idx;
 	unsigned long fd_flush_timestamp;
+	u32 fd_flush_cnt;
 	u32 fd_add_err;
 	u32 fd_atr_cnt;
 	u32 fd_tcp_rule;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 7204e29..571d527 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -145,6 +145,7 @@ static struct i40e_stats i40e_gstrings_stats[] = {
 	I40E_PF_STAT("rx_jabber", stats.rx_jabber),
 	I40E_PF_STAT("VF_admin_queue_requests", vf_aq_requests),
 	I40E_PF_STAT("rx_hwtstamp_cleared", rx_hwtstamp_cleared),
+	I40E_PF_STAT("fdir_flush_cnt", fd_flush_cnt),
 	I40E_PF_STAT("fdir_atr_match", stats.fd_atr_match),
 	I40E_PF_STAT("fdir_sb_match", stats.fd_sb_match),
 
@@ -1977,6 +1978,10 @@ static int i40e_del_fdir_entry(struct i40e_vsi *vsi,
 	struct i40e_pf *pf = vsi->back;
 	int ret = 0;
 
+	if (test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state) ||
+	    test_bit(__I40E_RESET_INTR_RECEIVED, &pf->state))
+		return -EBUSY;
+
 	if (test_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state))
 		return -EBUSY;
 
@@ -2013,6 +2018,10 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 	if (pf->auto_disable_flags & I40E_FLAG_FD_SB_ENABLED)
 		return -ENOSPC;
 
+	if (test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state) ||
+	    test_bit(__I40E_RESET_INTR_RECEIVED, &pf->state))
+		return -EBUSY;
+
 	if (test_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state))
 		return -EBUSY;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index cab9c9e..712a23b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5189,6 +5189,7 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 		wr32(&pf->hw, I40E_PFQF_CTL_1,
 		     I40E_PFQF_CTL_1_CLEARFDTABLE_MASK);
 		i40e_flush(&pf->hw);
+		pf->fd_flush_cnt++;
 		pf->fd_add_err = 0;
 		do {
 			/* Check FD flush status every 5-6msec */
-- 
1.9.3
