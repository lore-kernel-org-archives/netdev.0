From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/17] i40e/i40evf: Add WB_ON_ITR offload support
Date: Thu, 15 Oct 2015 02:39:54 -0700
Message-ID: <1444902004-14433-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31273 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752373AbbJOJm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:27 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

X722 has a way to work around the descriptor WB issue,
this offload helps turn that feature on.

Change-ID: I7ffa67622426bfca5a651417b63e3afcfeb60412
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h     | 1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c  | 4 ++++
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h   | 1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c     | 5 +++++
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 3 ++-
 5 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
index 95d0f8c..ae87982 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
@@ -150,6 +150,7 @@ struct i40e_virtchnl_vsi_resource {
 #define I40E_VIRTCHNL_VF_OFFLOAD_FCOE		0x00000004
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ		0x00000008
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG	0x00000010
+#define I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR	0x00000020
 #define I40E_VIRTCHNL_VF_OFFLOAD_VLAN		0x00010000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING	0x00020000
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index ae7548a..fd99cd2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1203,6 +1203,10 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 	} else {
 		vfres->vf_offload_flags |= I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG;
 	}
+
+	if (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING)
+		vfres->vf_offload_flags |= I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING;
+
 	vfres->num_vsis = num_vsis;
 	vfres->num_queue_pairs = vf->num_queue_pairs;
 	vfres->max_vectors = pf->hw.func_caps.num_msix_vectors_vf;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index cadda64..9f7b279 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -150,6 +150,7 @@ struct i40e_virtchnl_vsi_resource {
 #define I40E_VIRTCHNL_VF_OFFLOAD_FCOE		0x00000004
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ		0x00000008
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG	0x00000010
+#define I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR	0x00000020
 #define I40E_VIRTCHNL_VF_OFFLOAD_VLAN		0x00010000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING	0x00020000
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 69767c0..feb9ad5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1123,6 +1123,8 @@ static int i40evf_alloc_queues(struct i40evf_adapter *adapter)
 		tx_ring->netdev = adapter->netdev;
 		tx_ring->dev = &adapter->pdev->dev;
 		tx_ring->count = adapter->tx_desc_count;
+		if (adapter->flags & I40E_FLAG_WB_ON_ITR_CAPABLE)
+			tx_ring->flags |= I40E_TXR_FLAGS_WB_ON_ITR;
 		adapter->tx_rings[i] = tx_ring;
 
 		rx_ring = &tx_ring[1];
@@ -2275,6 +2277,9 @@ static void i40evf_init_task(struct work_struct *work)
 	if (err)
 		goto err_sw_init;
 	i40evf_map_rings_to_vectors(adapter);
+	if (adapter->vf_res->vf_offload_flags &
+		    I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR)
+		adapter->flags |= I40EVF_FLAG_WB_ON_ITR_CAPABLE;
 	if (!RSS_AQ(adapter))
 		i40evf_configure_rss(adapter);
 	err = i40evf_request_misc_irq(adapter);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 4f056ef..32e620e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -156,7 +156,8 @@ int i40evf_send_vf_config_msg(struct i40evf_adapter *adapter)
 	caps = I40E_VIRTCHNL_VF_OFFLOAD_L2 |
 	       I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ |
 	       I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG |
-	       I40E_VIRTCHNL_VF_OFFLOAD_VLAN;
+	       I40E_VIRTCHNL_VF_OFFLOAD_VLAN |
+	       I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR;
 	adapter->current_op = I40E_VIRTCHNL_OP_GET_VF_RESOURCES;
 	adapter->aq_required &= ~I40EVF_FLAG_AQ_GET_CONFIG;
 	if (PF_IS_V11(adapter))
-- 
2.4.3
