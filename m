From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/16] i40evf: Update feature flags to reflect newly enabled features
Date: Thu, 18 Feb 2016 16:31:20 -0800
Message-ID: <1455841881-128892-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49646 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965677AbcBSAbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:38 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

Recent changes should have enabled support for IPv6 based tunnels and
support for TSO with outer UDP checksums.  As such we can update the
feature flags to reflect that.

In addition we can clean-up the flags that aren't needed such as SCTP and
RXCSUM since having the bits there doesn't add any value.

I also found one spot where we were setting the same flag twice.  It looks
like it was probably a git merge error that resulted in the line being
duplicated.  As such I have dropped it in this patch.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Acked-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 41369a3..3396fe3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2337,9 +2337,24 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 			    NETIF_F_IPV6_CSUM |
 			    NETIF_F_TSO |
 			    NETIF_F_TSO6 |
+			    NETIF_F_TSO_ECN |
+			    NETIF_F_GSO_GRE	       |
+			    NETIF_F_GSO_UDP_TUNNEL |
 			    NETIF_F_RXCSUM |
 			    NETIF_F_GRO;
 
+	netdev->hw_enc_features |= NETIF_F_IP_CSUM	       |
+				   NETIF_F_IPV6_CSUM	       |
+				   NETIF_F_TSO		       |
+				   NETIF_F_TSO6		       |
+				   NETIF_F_TSO_ECN	       |
+				   NETIF_F_GSO_GRE	       |
+				   NETIF_F_GSO_UDP_TUNNEL      |
+				   NETIF_F_GSO_UDP_TUNNEL_CSUM;
+
+	if (adapter->flags & I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE)
+		netdev->features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
+
 	/* copy netdev features into list of user selectable features */
 	netdev->hw_features |= netdev->features;
 	netdev->hw_features &= ~NETIF_F_RXCSUM;
@@ -2478,6 +2493,10 @@ static void i40evf_init_task(struct work_struct *work)
 	default:
 		goto err_alloc;
 	}
+
+	if (hw->mac.type == I40E_MAC_X722_VF)
+		adapter->flags |= I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE;
+
 	if (i40evf_process_config(adapter))
 		goto err_alloc;
 	adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
@@ -2519,10 +2538,6 @@ static void i40evf_init_task(struct work_struct *work)
 		goto err_sw_init;
 	i40evf_map_rings_to_vectors(adapter);
 	if (adapter->vf_res->vf_offload_flags &
-		    I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR)
-		adapter->flags |= I40EVF_FLAG_WB_ON_ITR_CAPABLE;
-
-	if (adapter->vf_res->vf_offload_flags &
 	    I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR)
 		adapter->flags |= I40EVF_FLAG_WB_ON_ITR_CAPABLE;
 
-- 
2.5.0
