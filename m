From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/16] i40e: write HENA for VFs
Date: Tue, 28 Jun 2016 21:40:49 -0700
Message-ID: <1467175262-54719-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22102 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750995AbcF2EnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:16 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Now that VF RSS is configured by the PF driver, it needs to set the RSS
Hash Enable registers by default. Without this, no packets will be
hashed and they'll all end up on queue 0.

Change-ID: I38e425f40ddb81e3b19a951cfbb939fa5b1123f1
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 1fcafcf..6fcbf76 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -665,6 +665,8 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 		goto error_alloc_vsi_res;
 	}
 	if (type == I40E_VSI_SRIOV) {
+		u64 hena = i40e_pf_get_default_rss_hena(pf);
+
 		vf->lan_vsi_idx = vsi->idx;
 		vf->lan_vsi_id = vsi->id;
 		/* If the port VLAN has been configured and then the
@@ -687,6 +689,10 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 					vf->default_lan_addr.addr, vf->vf_id);
 		}
 		spin_unlock_bh(&vsi->mac_filter_list_lock);
+		i40e_write_rx_ctl(&pf->hw, I40E_VFQF_HENA1(0, vf->vf_id),
+				  (u32)hena);
+		i40e_write_rx_ctl(&pf->hw, I40E_VFQF_HENA1(1, vf->vf_id),
+				  (u32)(hena >> 32));
 	}
 
 	/* program mac filter */
-- 
2.5.5
