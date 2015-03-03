From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/17] i40e: Fix RSS size at init since default num queue calculation has changed
Date: Tue,  3 Mar 2015 01:44:20 -0800
Message-ID: <1425375864-25117-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425375864-25117-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:63685 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755967AbbCCJoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 04:44:37 -0500
In-Reply-To: <1425375864-25117-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

With changes to default number of queue pairs that the interface comes up with
from 1 per online CPU to 1 per lan_msix, we need to make sure we recalculate
rss_size. We will now recalculate rss_size based on number of queues enabled in
the VSI.

Without this fix if the max_lan_msix < num_online_cpu we will be coming up
with fewer queues but will be populating rss_size based on num_online_cpus.
This will result in packets getting silently dropped because RSS LUT has queues
that are not enabled.

Change-ID: Ifac8796ce1be1758bb0c34f38dbf4a3a76621e76
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index e7ceae8..cfc1d8a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -472,6 +472,7 @@ struct i40e_vsi {
 	u16 tx_itr_setting;
 
 	u16 rss_table_size;
+	u16 rss_size;
 
 	u16 max_frame;
 	u16 rx_hdr_len;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d6d8c30..f9da8e8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7207,6 +7207,7 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
 static int i40e_config_rss(struct i40e_pf *pf)
 {
 	u32 rss_key[I40E_PFQF_HKEY_MAX_INDEX + 1];
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
 	struct i40e_hw *hw = &pf->hw;
 	u32 lut = 0;
 	int i, j;
@@ -7224,6 +7225,8 @@ static int i40e_config_rss(struct i40e_pf *pf)
 	wr32(hw, I40E_PFQF_HENA(0), (u32)hena);
 	wr32(hw, I40E_PFQF_HENA(1), (u32)(hena >> 32));
 
+	vsi->rss_size = min_t(int, pf->rss_size, vsi->num_queue_pairs);
+
 	/* Check capability and Set table size and register per hw expectation*/
 	reg_val = rd32(hw, I40E_PFQF_CTL_0);
 	if (hw->func_caps.rss_table_size == 512) {
@@ -7245,7 +7248,7 @@ static int i40e_config_rss(struct i40e_pf *pf)
 		 * If LAN VSI is the only consumer for RSS then this requirement
 		 * is not necessary.
 		 */
-		if (j == pf->rss_size)
+		if (j == vsi->rss_size)
 			j = 0;
 		/* lut = 4-byte sliding window of 4 lut entries */
 		lut = (lut << 8) | (j &
-- 
1.9.3
