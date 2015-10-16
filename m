From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/17] i40evf: correctly populate vlan_features
Date: Fri, 16 Oct 2015 05:10:21 -0700
Message-ID: <1444997425-3396-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:36264 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753810AbbJPMKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 08:10:32 -0400
In-Reply-To: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The vlan_features field was correctly being set to the same value as the
netdev features field. However, this was being done before the features
were actually being set up, leaving the vlan_features empty.

Also, after a reset, vlan_features will be incorrectly assigned the
previous netdev feature flags, which can contain VLAN feature bits. This
makes the VLAN code angry and will cause a stack dump.

To fix these issues, set up the netdev features first, then mask out the
VLAN feature bits when assigning vlan_features.

Change-ID: Ib0548869dc83cf6a841cb8697dd94c12359ba4d2
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 139801f..46af35f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2123,7 +2123,10 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 
 	if (adapter->vf_res->vf_offload_flags
 	    & I40E_VIRTCHNL_VF_OFFLOAD_VLAN) {
-		netdev->vlan_features = netdev->features;
+		netdev->vlan_features = netdev->features &
+					~(NETIF_F_HW_VLAN_CTAG_TX |
+					  NETIF_F_HW_VLAN_CTAG_RX |
+					  NETIF_F_HW_VLAN_CTAG_FILTER);
 		netdev->features |= NETIF_F_HW_VLAN_CTAG_TX |
 				    NETIF_F_HW_VLAN_CTAG_RX |
 				    NETIF_F_HW_VLAN_CTAG_FILTER;
-- 
2.4.3
