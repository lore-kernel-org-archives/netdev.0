From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/18] i40e: Fix RSS size at init since default num queue calculation has changed
Date: Sat, 28 Feb 2015 03:29:45 -0800
Message-ID: <1425122989-354-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50492 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751388AbbB1LaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:30:00 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index 7ce9f43c..32ab097 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -474,6 +474,7 @@ struct i40e_vsi {
 	u16 tx_itr_setting;
 
 	u16 rss_table_size;
+	u16 rss_size;
 
 	u16 max_frame;
 	u16 rx_hdr_len;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ffc2261..c9936cc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7233,6 +7233,7 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
 static int i40e_config_rss(struct i40e_pf *pf)
 {
 	u32 rss_key[I40E_PFQF_HKEY_MAX_INDEX + 1];
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
 	struct i40e_hw *hw = &pf->hw;
 	u32 lut = 0;
 	int i, j;
@@ -7250,6 +7251,8 @@ static int i40e_config_rss(struct i40e_pf *pf)
 	wr32(hw, I40E_PFQF_HENA(0), (u32)hena);
 	wr32(hw, I40E_PFQF_HENA(1), (u32)(hena >> 32));
 
+	vsi->rss_size = min_t(int, pf->rss_size, vsi->num_queue_pairs);
+
 	/* Check capability and Set table size and register per hw expectation*/
 	reg_val = rd32(hw, I40E_PFQF_CTL_0);
 	if (hw->func_caps.rss_table_size == 512) {
@@ -7271,7 +7274,7 @@ static int i40e_config_rss(struct i40e_pf *pf)
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
