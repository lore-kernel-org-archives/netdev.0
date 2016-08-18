From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: fix lookup table when RSS disabled/enabled
Date: Thu, 18 Aug 2016 14:57:31 -0700
Message-ID: <1471557456-136741-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9877 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754077AbcHSCqA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 22:46:00 -0400
In-Reply-To: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

This patch fixes the bug which causes RSS to continue to work
after being disabled.  After disabling RSS, traffic would continue
to be assigned to different queues instead of falling back to a
single queue. Without this patch, attempting to disable RSS would
not work as expected. This patch fixes the bug by clearing the
lookup table used by RSS such that all traffic is assigned to a
single queue.  This patch also addresses the issue of reinstating
 the lookup table should RSS then be re-enabled.

Change-ID: Ib20c7c6a7e9f1f772bb787370f8a8c664796b141
Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8c68ac1..704cd7d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8691,6 +8691,28 @@ bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features)
 }
 
 /**
+ * i40e_clear_rss_lut - clear the rx hash lookup table
+ * @vsi: the VSI being configured
+ **/
+static void i40e_clear_rss_lut(struct i40e_vsi *vsi)
+{
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	u16 vf_id = vsi->vf_id;
+	u8 i;
+
+	if (vsi->type == I40E_VSI_MAIN) {
+		for (i = 0; i <= I40E_PFQF_HLUT_MAX_INDEX; i++)
+			wr32(hw, I40E_PFQF_HLUT(i), 0);
+	} else if (vsi->type == I40E_VSI_SRIOV) {
+		for (i = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++)
+			i40e_write_rx_ctl(hw, I40E_VFQF_HLUT1(i, vf_id), 0);
+	} else {
+		dev_err(&pf->pdev->dev, "Cannot set RSS LUT - invalid VSI type\n");
+	}
+}
+
+/**
  * i40e_set_features - set the netdev feature flags
  * @netdev: ptr to the netdev being adjusted
  * @features: the feature set that the stack is suggesting
@@ -8703,6 +8725,12 @@ static int i40e_set_features(struct net_device *netdev,
 	struct i40e_pf *pf = vsi->back;
 	bool need_reset;
 
+	if (features & NETIF_F_RXHASH && !(netdev->features & NETIF_F_RXHASH))
+		i40e_pf_config_rss(pf);
+	else if (!(features & NETIF_F_RXHASH) &&
+		 netdev->features & NETIF_F_RXHASH)
+		i40e_clear_rss_lut(vsi);
+
 	if (features & NETIF_F_HW_VLAN_CTAG_RX)
 		i40e_vlan_stripping_enable(vsi);
 	else
-- 
2.7.4
