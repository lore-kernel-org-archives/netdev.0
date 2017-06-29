From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH 2/2] i40e/i40evf: add virtchnl flag to indicate trusted VF
Date: Thu, 29 Jun 2017 15:12:25 +0200
Message-ID: <20170629131225.9251-3-sassmann@kpanic.de>
References: <20170629131225.9251-1-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37688 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752807AbdF2NNT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 09:13:19 -0400
In-Reply-To: <20170629131225.9251-1-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Give the VF a hint whether it runs in trusted mode or not. This allows
the VF to decide if it should allow changing the MAC address.
Currently the VF returns -EPERM in i40evf_set_mac when an
administratively set MAC has been set. However this prevents overriding
the administratively set MAC in trusted mode. Simply removing the EPERM
check is not an option, as that would bring the VF in an inconsistent
state when the PF decides to deny adding the appropriate filter.

Due to the fact that the communication between PF and VF is async the VF
driver cannot decide whether to deny or allow a MAC address change
without the VF trust hint.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 3 +++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 3 ++-
 include/linux/avf/virtchnl.h                       | 1 +
 3 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 057c77b..9e872b1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1579,6 +1579,9 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 					VIRTCHNL_VF_OFFLOAD_WB_ON_ITR;
 	}
 
+	if (test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps))
+		vfres->vf_cap_flags |= VIRTCHNL_VF_TRUSTED;
+
 	vfres->num_vsis = num_vsis;
 	vfres->num_queue_pairs = vf->num_queue_pairs;
 	vfres->max_vectors = pf->hw.func_caps.num_msix_vectors_vf;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 21103bb..8822062 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2649,7 +2649,8 @@ static void i40evf_init_task(struct work_struct *work)
 		eth_hw_addr_random(netdev);
 		ether_addr_copy(adapter->hw.mac.addr, netdev->dev_addr);
 	} else {
-		adapter->flags |= I40EVF_FLAG_ADDR_SET_BY_PF;
+		if (!(adapter->vf_res->vf_cap_flags & VIRTCHNL_VF_TRUSTED))
+			adapter->flags |= I40EVF_FLAG_ADDR_SET_BY_PF;
 		ether_addr_copy(netdev->dev_addr, adapter->hw.mac.addr);
 		ether_addr_copy(netdev->perm_addr, adapter->hw.mac.addr);
 	}
diff --git a/include/linux/avf/virtchnl.h b/include/linux/avf/virtchnl.h
index becfca2..6d74453 100644
--- a/include/linux/avf/virtchnl.h
+++ b/include/linux/avf/virtchnl.h
@@ -240,6 +240,7 @@ VIRTCHNL_CHECK_STRUCT_LEN(16, virtchnl_vsi_resource);
 #define VIRTCHNL_VF_OFFLOAD_ENCAP		0X00100000
 #define VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM		0X00200000
 #define VIRTCHNL_VF_OFFLOAD_RX_ENCAP_CSUM	0X00400000
+#define VIRTCHNL_VF_TRUSTED			0X00800000
 
 #define VF_BASE_MODE_OFFLOADS (VIRTCHNL_VF_OFFLOAD_L2 | \
 			       VIRTCHNL_VF_OFFLOAD_VLAN | \
-- 
2.9.4
