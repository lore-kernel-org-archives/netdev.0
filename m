From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/12] i40e: fix RSS queues only operating on PF0
Date: Wed, 15 Mar 2017 02:25:40 -0700
Message-ID: <20170315092545.63654-8-jeffrey.t.kirsher@intel.com>
References: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Cc: Lihong Yang <lihong.yang@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55547 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752479AbdCOJ0A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 05:26:00 -0400
In-Reply-To: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lihong Yang <lihong.yang@intel.com>

This patch fixes the issue that RSS offloading only works on PF0 by
using the direct register writing of the hash keys for the VFs instead
of using the admin queue command to do so.

Change-ID: Ia02cda7dbaa23def342e8786097a2c03db6f580b
Signed-off-by: Lihong Yang <lihong.yang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 11 +++--------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  6 ++----
 2 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index cb678ed7a2ad..e577ff8a9c76 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8394,13 +8394,10 @@ static int i40e_config_rss_reg(struct i40e_vsi *vsi, const u8 *seed,
 
 		if (vsi->type == I40E_VSI_MAIN) {
 			for (i = 0; i <= I40E_PFQF_HKEY_MAX_INDEX; i++)
-				i40e_write_rx_ctl(hw, I40E_PFQF_HKEY(i),
-						  seed_dw[i]);
+				wr32(hw, I40E_PFQF_HKEY(i), seed_dw[i]);
 		} else if (vsi->type == I40E_VSI_SRIOV) {
 			for (i = 0; i <= I40E_VFQF_HKEY1_MAX_INDEX; i++)
-				i40e_write_rx_ctl(hw,
-						  I40E_VFQF_HKEY1(i, vf_id),
-						  seed_dw[i]);
+				wr32(hw, I40E_VFQF_HKEY1(i, vf_id), seed_dw[i]);
 		} else {
 			dev_err(&pf->pdev->dev, "Cannot set RSS seed - invalid VSI type\n");
 		}
@@ -8418,9 +8415,7 @@ static int i40e_config_rss_reg(struct i40e_vsi *vsi, const u8 *seed,
 			if (lut_size != I40E_VF_HLUT_ARRAY_SIZE)
 				return -EINVAL;
 			for (i = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++)
-				i40e_write_rx_ctl(hw,
-						  I40E_VFQF_HLUT1(i, vf_id),
-						  lut_dw[i]);
+				wr32(hw, I40E_VFQF_HLUT1(i, vf_id), lut_dw[i]);
 		} else {
 			dev_err(&pf->pdev->dev, "Cannot set RSS LUT - invalid VSI type\n");
 		}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 25ee5af2d136..115a7286ab8f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -702,10 +702,8 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 			dev_info(&pf->pdev->dev,
 				 "Could not allocate VF broadcast filter\n");
 		spin_unlock_bh(&vsi->mac_filter_hash_lock);
-		i40e_write_rx_ctl(&pf->hw, I40E_VFQF_HENA1(0, vf->vf_id),
-				  (u32)hena);
-		i40e_write_rx_ctl(&pf->hw, I40E_VFQF_HENA1(1, vf->vf_id),
-				  (u32)(hena >> 32));
+		wr32(&pf->hw, I40E_VFQF_HENA1(0, vf->vf_id), (u32)hena);
+		wr32(&pf->hw, I40E_VFQF_HENA1(1, vf->vf_id), (u32)(hena >> 32));
 	}
 
 	/* program mac filter */
-- 
2.12.0
