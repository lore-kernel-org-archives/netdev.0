From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 04/15] i40e: Patch to enable Ethtool/netdev feature flag for NTUPLE control
Date: Wed, 19 Mar 2014 20:29:54 -0700
Message-ID: <1395286205-9676-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395286205-9676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20420 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753375AbaCTDaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 23:30:20 -0400
In-Reply-To: <1395286205-9676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This enables option '-k/-K' in ethtool for NTUPLE control.
NTUPLE control requires a reset, to take effect. When the feature is
turned off, the SW list of stored FD SB filters gets cleaned up.

Change-ID: I9d564b67a10d4afa11de3b320d601c3d2e6edc1f
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 41 +++++++++++++++++++++++++++++
 2 files changed, 42 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index bd1b469..ac04112 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -558,6 +558,7 @@ int i40e_add_del_fdir(struct i40e_vsi *vsi,
 		      struct i40e_fdir_filter *input, bool add);
 void i40e_fdir_check_and_reenable(struct i40e_pf *pf);
 int i40e_get_current_fd_count(struct i40e_pf *pf);
+bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features);
 void i40e_set_ethtool_ops(struct net_device *netdev);
 struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 					u8 *macaddr, s16 vlan,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9c4f53e..5015dad 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6409,6 +6409,39 @@ sw_init_done:
 }
 
 /**
+ * i40e_set_ntuple - set the ntuple feature flag and take action
+ * @pf: board private structure to initialize
+ * @features: the feature set that the stack is suggesting
+ *
+ * returns a bool to indicate if reset needs to happen
+ **/
+bool i40e_set_ntuple(struct i40e_pf *pf, netdev_features_t features)
+{
+	bool need_reset = false;
+
+	/* Check if Flow Director n-tuple support was enabled or disabled.  If
+	 * the state changed, we need to reset.
+	 */
+	if (features & NETIF_F_NTUPLE) {
+		/* Enable filters and mark for reset */
+		if (!(pf->flags & I40E_FLAG_FD_SB_ENABLED))
+			need_reset = true;
+		pf->flags |= I40E_FLAG_FD_SB_ENABLED;
+	} else {
+		/* turn off filters, mark for reset and clear SW filter list */
+		if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
+			need_reset = true;
+			i40e_fdir_filter_exit(pf);
+		}
+		pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
+		/* if ATR was disabled it can be re-enabled. */
+		if (!(pf->flags & I40E_FLAG_FD_ATR_ENABLED))
+			pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
+	}
+	return need_reset;
+}
+
+/**
  * i40e_set_features - set the netdev feature flags
  * @netdev: ptr to the netdev being adjusted
  * @features: the feature set that the stack is suggesting
@@ -6418,12 +6451,19 @@ static int i40e_set_features(struct net_device *netdev,
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	bool need_reset;
 
 	if (features & NETIF_F_HW_VLAN_CTAG_RX)
 		i40e_vlan_stripping_enable(vsi);
 	else
 		i40e_vlan_stripping_disable(vsi);
 
+	need_reset = i40e_set_ntuple(pf, features);
+
+	if (need_reset)
+		i40e_do_reset(pf, (1 << __I40E_PF_RESET_REQUESTED));
+
 	return 0;
 }
 
@@ -6595,6 +6635,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 			   NETIF_F_TSO		       |
 			   NETIF_F_TSO6		       |
 			   NETIF_F_RXCSUM	       |
+			   NETIF_F_NTUPLE	       |
 			   NETIF_F_RXHASH	       |
 			   0;
 
-- 
1.8.3.1
