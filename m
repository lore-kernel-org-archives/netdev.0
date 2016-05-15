From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] i40e: Add vf-true-promisc-support priv flag
Date: Sat, 14 May 2016 21:57:26 -0700
Message-ID: <1463288255-1654-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57094 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752313AbcEOE5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:39 -0400
In-Reply-To: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch adds priv-flag knob to configure global true promisc
support. With this patch the user can decide the flavor of
promiscuous that the VFs will see when promiscuous mode is enabled
on the interface. Since this a global setting for the whole device,
the priv-flag is exposed only on the first PF of the device.

The default is true promisc support is off, which means the promisc
mode for the VF will be limited/defport mode.

For the PF, we still will be in limited promisc unless in MFP mode
irrespective of the flavor picked through this knob.

Usage:
On PF0
ethtool --show-priv-flags p261p1
Private flags for p261p1:
MFP                    : off
LinkPolling            : off
flow-director-atr      : on
veb-stats              : off
hw-atr-eviction        : off
vf-true-promisc-support: off

to enable setting true promisc
ethtool --set-priv-flags p261p1 vf-true-promisc-support on

At this point if the VF is set to trust and promisc is enabled
on the VF through
ip link set ... promisc on
The VF/VFs will be able to see ALL ingress traffic

Change-Id: I8fac4b6eb1af9ca77b5376b79c50bdce5055bd94
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             | 12 ++--
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  9 ++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 72 +++++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 30 ++++++++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  3 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  3 +-
 6 files changed, 111 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 01cc732..9c44739 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -97,11 +97,12 @@
 #define I40E_INT_NAME_STR_LEN        (IFNAMSIZ + 16)
 
 /* Ethtool Private Flags */
-#define I40E_PRIV_FLAGS_NPAR_FLAG	BIT(0)
-#define I40E_PRIV_FLAGS_LINKPOLL_FLAG	BIT(1)
-#define I40E_PRIV_FLAGS_FD_ATR		BIT(2)
-#define I40E_PRIV_FLAGS_VEB_STATS	BIT(3)
-#define I40E_PRIV_FLAGS_HW_ATR_EVICT	BIT(5)
+#define	I40E_PRIV_FLAGS_MFP_FLAG		BIT(0)
+#define	I40E_PRIV_FLAGS_LINKPOLL_FLAG		BIT(1)
+#define I40E_PRIV_FLAGS_FD_ATR			BIT(2)
+#define I40E_PRIV_FLAGS_VEB_STATS		BIT(3)
+#define I40E_PRIV_FLAGS_HW_ATR_EVICT		BIT(4)
+#define I40E_PRIV_FLAGS_TRUE_PROMISC_SUPPORT	BIT(5)
 
 #define I40E_NVM_VERSION_LO_SHIFT  0
 #define I40E_NVM_VERSION_LO_MASK   (0xff << I40E_NVM_VERSION_LO_SHIFT)
@@ -358,6 +359,7 @@ struct i40e_pf {
 #define I40E_FLAG_STOP_FW_LLDP			BIT_ULL(47)
 #define I40E_FLAG_HAVE_10GBASET_PHY		BIT_ULL(48)
 #define I40E_FLAG_PF_MAC			BIT_ULL(50)
+#define I40E_FLAG_TRUE_PROMISC_SUPPORT		BIT_ULL(51)
 
 	/* tracks features that get auto disabled by errors */
 	u64 auto_disable_flags;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 4739a9c..27c6f9d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1972,10 +1972,12 @@ aq_add_vsi_exit:
  * @seid: vsi number
  * @set: set unicast promiscuous enable/disable
  * @cmd_details: pointer to command details structure or NULL
+ * @rx_only_promisc: flag to decide if egress traffic gets mirrored in promisc
  **/
 i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
 				u16 seid, bool set,
-				struct i40e_asq_cmd_details *cmd_details)
+				struct i40e_asq_cmd_details *cmd_details,
+				bool rx_only_promisc)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_set_vsi_promiscuous_modes *cmd =
@@ -1988,8 +1990,9 @@ i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
 
 	if (set) {
 		flags |= I40E_AQC_SET_VSI_PROMISC_UNICAST;
-		if (((hw->aq.api_maj_ver == 1) && (hw->aq.api_min_ver >= 5)) ||
-		    (hw->aq.api_maj_ver > 1))
+		if (rx_only_promisc &&
+		    (((hw->aq.api_maj_ver == 1) && (hw->aq.api_min_ver >= 5)) ||
+		     (hw->aq.api_maj_ver > 1)))
 			flags |= I40E_AQC_SET_VSI_PROMISC_TX;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 6fa05c4..52b58e3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -230,6 +230,17 @@ static const char i40e_gstrings_test[][ETH_GSTRING_LEN] = {
 
 #define I40E_TEST_LEN (sizeof(i40e_gstrings_test) / ETH_GSTRING_LEN)
 
+static const char i40e_priv_flags_strings_gl[][ETH_GSTRING_LEN] = {
+	"MFP",
+	"LinkPolling",
+	"flow-director-atr",
+	"veb-stats",
+	"hw-atr-eviction",
+	"vf-true-promisc-support",
+};
+
+#define I40E_PRIV_FLAGS_GL_STR_LEN ARRAY_SIZE(i40e_priv_flags_strings_gl)
+
 static const char i40e_priv_flags_strings[][ETH_GSTRING_LEN] = {
 	"NPAR",
 	"LinkPolling",
@@ -1158,6 +1169,10 @@ static void i40e_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(pf->pdev),
 		sizeof(drvinfo->bus_info));
+	if (pf->hw.pf_id == 0)
+		drvinfo->n_priv_flags = I40E_PRIV_FLAGS_GL_STR_LEN;
+	else
+		drvinfo->n_priv_flags = I40E_PRIV_FLAGS_STR_LEN;
 }
 
 static void i40e_get_ringparam(struct net_device *netdev,
@@ -1385,7 +1400,10 @@ static int i40e_get_sset_count(struct net_device *netdev, int sset)
 			return I40E_VSI_STATS_LEN(netdev);
 		}
 	case ETH_SS_PRIV_FLAGS:
-		return I40E_PRIV_FLAGS_STR_LEN;
+		if (pf->hw.pf_id == 0)
+			return I40E_PRIV_FLAGS_GL_STR_LEN;
+		else
+			return I40E_PRIV_FLAGS_STR_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -1583,10 +1601,18 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 		/* BUG_ON(p - data != I40E_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
 	case ETH_SS_PRIV_FLAGS:
-		for (i = 0; i < I40E_PRIV_FLAGS_STR_LEN; i++) {
-			memcpy(data, i40e_priv_flags_strings[i],
-			       ETH_GSTRING_LEN);
-			data += ETH_GSTRING_LEN;
+		if (pf->hw.pf_id == 0) {
+			for (i = 0; i < I40E_PRIV_FLAGS_GL_STR_LEN; i++) {
+				memcpy(data, i40e_priv_flags_strings_gl[i],
+				       ETH_GSTRING_LEN);
+				data += ETH_GSTRING_LEN;
+			}
+		} else {
+			for (i = 0; i < I40E_PRIV_FLAGS_STR_LEN; i++) {
+				memcpy(data, i40e_priv_flags_strings[i],
+				       ETH_GSTRING_LEN);
+				data += ETH_GSTRING_LEN;
+			}
 		}
 		break;
 	default:
@@ -2848,8 +2874,6 @@ static u32 i40e_get_priv_flags(struct net_device *dev)
 	struct i40e_pf *pf = vsi->back;
 	u32 ret_flags = 0;
 
-	ret_flags |= pf->hw.func_caps.npar_enable ?
-		I40E_PRIV_FLAGS_NPAR_FLAG : 0;
 	ret_flags |= pf->flags & I40E_FLAG_LINK_POLLING_ENABLED ?
 		I40E_PRIV_FLAGS_LINKPOLL_FLAG : 0;
 	ret_flags |= pf->flags & I40E_FLAG_FD_ATR_ENABLED ?
@@ -2858,6 +2882,10 @@ static u32 i40e_get_priv_flags(struct net_device *dev)
 		I40E_PRIV_FLAGS_VEB_STATS : 0;
 	ret_flags |= pf->auto_disable_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE ?
 		0 : I40E_PRIV_FLAGS_HW_ATR_EVICT;
+	if (pf->hw.pf_id == 0) {
+		ret_flags |= pf->flags & I40E_FLAG_TRUE_PROMISC_SUPPORT ?
+			I40E_PRIV_FLAGS_TRUE_PROMISC_SUPPORT : 0;
+	}
 
 	return ret_flags;
 }
@@ -2872,7 +2900,10 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
+	u16 sw_flags = 0, valid_flags = 0;
 	bool reset_required = false;
+	bool promisc_change = false;
+	int ret;
 
 	/* NOTE: MFP is not settable */
 
@@ -2902,6 +2933,33 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 		reset_required = true;
 	}
 
+	if (pf->hw.pf_id == 0) {
+		if ((flags & I40E_PRIV_FLAGS_TRUE_PROMISC_SUPPORT) &&
+		    !(pf->flags & I40E_FLAG_TRUE_PROMISC_SUPPORT)) {
+			pf->flags |= I40E_FLAG_TRUE_PROMISC_SUPPORT;
+			promisc_change = true;
+		} else if (!(flags & I40E_PRIV_FLAGS_TRUE_PROMISC_SUPPORT) &&
+			   (pf->flags & I40E_FLAG_TRUE_PROMISC_SUPPORT)) {
+			pf->flags &= ~I40E_FLAG_TRUE_PROMISC_SUPPORT;
+			promisc_change = true;
+		}
+	}
+	if (promisc_change) {
+		if (!(pf->flags & I40E_FLAG_TRUE_PROMISC_SUPPORT))
+			sw_flags = I40E_AQ_SET_SWITCH_CFG_PROMISC;
+		valid_flags = I40E_AQ_SET_SWITCH_CFG_PROMISC;
+		ret = i40e_aq_set_switch_config(&pf->hw, sw_flags, valid_flags,
+						NULL);
+		if (ret && pf->hw.aq.asq_last_status != I40E_AQ_RC_ESRCH) {
+			dev_info(&pf->pdev->dev,
+				 "couldn't set switch config bits, err %s aq_err %s\n",
+				 i40e_stat_str(&pf->hw, ret),
+				 i40e_aq_str(&pf->hw,
+					     pf->hw.aq.asq_last_status));
+			/* not a fatal problem, just keep going */
+		}
+	}
+
 	if ((flags & I40E_PRIV_FLAGS_HW_ATR_EVICT) &&
 	    (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE))
 		pf->auto_disable_flags &= ~I40E_FLAG_HW_ATR_EVICT_CAPABLE;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 46a3a67..f8038d0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2128,7 +2128,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			aq_ret = i40e_aq_set_vsi_unicast_promiscuous(
 							  &vsi->back->hw,
 							  vsi->seid,
-							  cur_promisc, NULL);
+							  cur_promisc, NULL,
+							  true);
 			if (aq_ret) {
 				retval =
 				i40e_aq_rc_to_posix(aq_ret,
@@ -10407,6 +10408,7 @@ int i40e_fetch_switch_configuration(struct i40e_pf *pf, bool printconfig)
  **/
 static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 {
+	u16 flags = 0;
 	int ret;
 
 	/* find out what's out there already */
@@ -10420,6 +10422,32 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 	}
 	i40e_pf_reset_stats(pf);
 
+	/* set the switch config bit for the whole device to
+	 * support limited promisc or true promisc
+	 * when user requests promisc. The default is limited
+	 * promisc.
+	*/
+
+	if ((pf->hw.pf_id == 0) &&
+	    !(pf->flags & I40E_FLAG_TRUE_PROMISC_SUPPORT))
+		flags = I40E_AQ_SET_SWITCH_CFG_PROMISC;
+
+	if (pf->hw.pf_id == 0) {
+		u16 valid_flags;
+
+		valid_flags = I40E_AQ_SET_SWITCH_CFG_PROMISC;
+		ret = i40e_aq_set_switch_config(&pf->hw, flags, valid_flags,
+						NULL);
+		if (ret && pf->hw.aq.asq_last_status != I40E_AQ_RC_ESRCH) {
+			dev_info(&pf->pdev->dev,
+				 "couldn't set switch config bits, err %s aq_err %s\n",
+				 i40e_stat_str(&pf->hw, ret),
+				 i40e_aq_str(&pf->hw,
+					     pf->hw.aq.asq_last_status));
+			/* not a fatal problem, just keep going */
+		}
+	}
+
 	/* first time setup */
 	if (pf->lan_vsi == I40E_NO_VSI || reinit) {
 		struct i40e_vsi *vsi = NULL;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index b76b158..80403c6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -130,7 +130,8 @@ i40e_status i40e_aq_set_vsi_broadcast(struct i40e_hw *hw,
 				u16 vsi_id, bool set_filter,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
-		u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
+		u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details,
+		bool rx_only_promisc);
 i40e_status i40e_aq_set_vsi_multicast_promiscuous(struct i40e_hw *hw,
 		u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
 enum i40e_status_code i40e_aq_set_vsi_mc_promisc_on_vlan(struct i40e_hw *hw,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index a9b04e7..6430933 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1562,7 +1562,8 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 		}
 	} else {
 		aq_ret = i40e_aq_set_vsi_unicast_promiscuous(hw, vsi->seid,
-							     allmulti, NULL);
+							     allmulti, NULL,
+							     true);
 		aq_err = pf->hw.aq.asq_last_status;
 		if (aq_ret)
 			dev_err(&pf->pdev->dev,
-- 
2.5.5
