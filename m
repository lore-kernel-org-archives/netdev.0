From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/16] i40e/i40evf: add VIRTCHNL_VF_OFFLOAD flag
Date: Wed, 19 Aug 2015 17:58:04 -0700
Message-ID: <1440032286-30054-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jingjing Wu <jingjing.wu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24462 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106AbbHTA6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 20:58:11 -0400
In-Reply-To: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Add virtual channel offload capability to support RX polling mode in the
VF.

Change-ID: Ib643ae2a7506dfc75fc489fc207493fabefa4832
Signed-off-by: Jingjing Wu <jingjing.wu@intel.com>
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_register.h    |  7 +++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |  1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 12 ++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |  1 +
 4 files changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_register.h b/drivers/net/ethernet/intel/i40e/i40e_register.h
index acae6c74..dc0402f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_register.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_register.h
@@ -873,6 +873,13 @@
 #define I40E_PFINT_CEQCTL_CAUSE_ENA_MASK I40E_MASK(0x1, I40E_PFINT_CEQCTL_CAUSE_ENA_SHIFT)
 #define I40E_PFINT_CEQCTL_INTEVENT_SHIFT 31
 #define I40E_PFINT_CEQCTL_INTEVENT_MASK I40E_MASK(0x1, I40E_PFINT_CEQCTL_INTEVENT_SHIFT)
+#define I40E_GLINT_CTL 0x0003F800 /* Reset: CORER */
+#define I40E_GLINT_CTL_DIS_AUTOMASK_PF0_SHIFT 0
+#define I40E_GLINT_CTL_DIS_AUTOMASK_PF0_MASK I40E_MASK(0x1, I40E_GLINT_CTL_DIS_AUTOMASK_PF0_SHIFT)
+#define I40E_GLINT_CTL_DIS_AUTOMASK_VF0_SHIFT 1
+#define I40E_GLINT_CTL_DIS_AUTOMASK_VF0_MASK I40E_MASK(0x1, I40E_GLINT_CTL_DIS_AUTOMASK_VF0_SHIFT)
+#define I40E_GLINT_CTL_DIS_AUTOMASK_N_SHIFT 2
+#define I40E_GLINT_CTL_DIS_AUTOMASK_N_MASK I40E_MASK(0x1, I40E_GLINT_CTL_DIS_AUTOMASK_N_SHIFT)
 #define I40E_PFINT_DYN_CTL0 0x00038480 /* Reset: PFR */
 #define I40E_PFINT_DYN_CTL0_INTENA_SHIFT 0
 #define I40E_PFINT_DYN_CTL0_INTENA_MASK I40E_MASK(0x1, I40E_PFINT_DYN_CTL0_INTENA_SHIFT)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
index a7ab463..0f8d415 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
@@ -152,6 +152,7 @@ struct i40e_virtchnl_vsi_resource {
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ		0x00000008
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG	0x00000010
 #define I40E_VIRTCHNL_VF_OFFLOAD_VLAN		0x00010000
+#define I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING	0x00020000
 
 struct i40e_virtchnl_vf_resource {
 	u16 num_vsis;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index ca7a568..d99c116 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -335,6 +335,18 @@ static void i40e_config_irq_link_list(struct i40e_vf *vf, u16 vsi_id,
 		wr32(hw, reg_idx, reg);
 	}
 
+	/* if the vf is running in polling mode and using interrupt zero,
+	 * need to disable auto-mask on enabling zero interrupt for VFs.
+	 */
+	if ((vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING) &&
+	    (vector_id == 0)) {
+		reg = rd32(hw, I40E_GLINT_CTL);
+		if (!(reg & I40E_GLINT_CTL_DIS_AUTOMASK_VF0_MASK)) {
+			reg |= I40E_GLINT_CTL_DIS_AUTOMASK_VF0_MASK;
+			wr32(hw, I40E_GLINT_CTL, reg);
+		}
+	}
+
 irq_list_done:
 	i40e_flush(hw);
 }
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index 1e89dea..e6db20e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -152,6 +152,7 @@ struct i40e_virtchnl_vsi_resource {
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ		0x00000008
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG	0x00000010
 #define I40E_VIRTCHNL_VF_OFFLOAD_VLAN		0x00010000
+#define I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING	0x00020000
 
 struct i40e_virtchnl_vf_resource {
 	u16 num_vsis;
-- 
2.4.3
