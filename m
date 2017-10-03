From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] fm10k: fix mis-ordered parameters in declaration for .ndo_set_vf_bw
Date: Tue,  3 Oct 2017 09:31:38 -0700
Message-ID: <20171003163138.47569-10-jeffrey.t.kirsher@intel.com>
References: <20171003163138.47569-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:17001 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752139AbdJCQcB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 12:32:01 -0400
In-Reply-To: <20171003163138.47569-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We've had support for setting both a minimum and maximum bandwidth via
.ndo_set_vf_bw since commit 883a9ccbae56 ("fm10k: Add support for SR-IOV
to driver", 2014-09-20).

Likely because we do not support minimum rates, the declaration
mis-ordered the "unused" parameter, which causes warnings when analyzed
with cppcheck.

Fix this warning by properly declaring the min_rate and max_rate
variables in the declaration and definition (rather than using
"unused"). Also rename "rate" to max_rate so as to clarify that we only
support setting the maximum rate.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h     | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c | 9 +++++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 40856bc0f3b9..46973fb234c5 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -562,8 +562,8 @@ s32 fm10k_iov_update_pvid(struct fm10k_intfc *interface, u16 glort, u16 pvid);
 int fm10k_ndo_set_vf_mac(struct net_device *netdev, int vf_idx, u8 *mac);
 int fm10k_ndo_set_vf_vlan(struct net_device *netdev,
 			  int vf_idx, u16 vid, u8 qos, __be16 vlan_proto);
-int fm10k_ndo_set_vf_bw(struct net_device *netdev, int vf_idx, int rate,
-			int unused);
+int fm10k_ndo_set_vf_bw(struct net_device *netdev, int vf_idx,
+			int __always_unused min_rate, int max_rate);
 int fm10k_ndo_get_vf_config(struct net_device *netdev,
 			    int vf_idx, struct ifla_vf_info *ivi);
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index 4a17cc903eed..ea3ab24265ee 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -613,7 +613,7 @@ int fm10k_ndo_set_vf_vlan(struct net_device *netdev, int vf_idx, u16 vid,
 }
 
 int fm10k_ndo_set_vf_bw(struct net_device *netdev, int vf_idx,
-			int __always_unused unused, int rate)
+			int __always_unused min_rate, int max_rate)
 {
 	struct fm10k_intfc *interface = netdev_priv(netdev);
 	struct fm10k_iov_data *iov_data = interface->iov_data;
@@ -624,14 +624,15 @@ int fm10k_ndo_set_vf_bw(struct net_device *netdev, int vf_idx,
 		return -EINVAL;
 
 	/* rate limit cannot be less than 10Mbs or greater than link speed */
-	if (rate && ((rate < FM10K_VF_TC_MIN) || rate > FM10K_VF_TC_MAX))
+	if (max_rate &&
+	    (max_rate < FM10K_VF_TC_MIN || max_rate > FM10K_VF_TC_MAX))
 		return -EINVAL;
 
 	/* store values */
-	iov_data->vf_info[vf_idx].rate = rate;
+	iov_data->vf_info[vf_idx].rate = max_rate;
 
 	/* update hardware configuration */
-	hw->iov.ops.configure_tc(hw, vf_idx, rate);
+	hw->iov.ops.configure_tc(hw, vf_idx, max_rate);
 
 	return 0;
 }
-- 
2.14.2
