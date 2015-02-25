From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: Add support for getlink, setlink ndo ops
Date: Wed, 25 Feb 2015 00:58:33 -0800
Message-ID: <1424854720-18825-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4721 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338AbbBYI6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 03:58:47 -0500
In-Reply-To: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

Add support for bridge offload ndo_ops getlink and setlink to
enable bridge hardware mode as per the mode set via IFLA_BRIDGE_MODE.
The support is only enabled in case of a PF VSI and not available for
any other VSI type.

By default the i40e driver inserts a bridge as part of the bring-up
when a FDIR type VSI and/or a FCoE VSI is created. This bridge is
created in VEB mode by default i.e. after creating the bridge using
"Add VEB" AQ command the loopback for the PF's default VSI is enabled.

The patch adds capability where all the VSIs created as downlink to
the bridge inherits the loopback property and enables loopback only
if the uplink bridge is operating in VEB mode.
Hence, there is no need to explicitly enable loopback as part of
allocating resources for SR-IOV VFs and call to do that has been
removed.

In case a user-request is made either via "bridge" utility or using
the bridge netlink interface that requires to change the hardware
bridge mode then that would require a PF reset and rebuild of the
switch hierarchy.

Also update the copyright year.

Change-ID: I4d78fc1c83158efda29ba7be92239b74f75d6d25
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-By: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |   3 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |  12 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 190 +++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   3 +-
 6 files changed, 196 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 2192587..71092a9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -50,6 +50,7 @@
 #include <net/ip6_checksum.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
+#include <linux/if_bridge.h>
 #include <linux/clocksource.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
@@ -410,6 +411,7 @@ struct i40e_veb {
 	u16 uplink_seid;
 	u16 stats_idx;           /* index of VEB parent */
 	u8  enabled_tc;
+	u16 bridge_mode;	/* Bridge Mode (VEB/VEPA) */
 	u16 flags;
 	u16 bw_limit;
 	u8  bw_max_quanta;
@@ -735,6 +737,7 @@ int i40e_ptp_set_ts_config(struct i40e_pf *pf, struct ifreq *ifr);
 int i40e_ptp_get_ts_config(struct i40e_pf *pf, struct ifreq *ifr);
 void i40e_ptp_init(struct i40e_pf *pf);
 void i40e_ptp_stop(struct i40e_pf *pf);
+int i40e_is_vsi_uplink_mode_veb(struct i40e_vsi *vsi);
 #if IS_ENABLED(CONFIG_CONFIGFS_FS)
 int i40e_configfs_init(void);
 void i40e_configfs_exit(void);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 43a6bf0..30cf0be 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -921,9 +921,10 @@ static void i40e_dbg_dump_veb_seid(struct i40e_pf *pf, int seid)
 		return;
 	}
 	dev_info(&pf->pdev->dev,
-		 "veb idx=%d,%d stats_ic=%d  seid=%d uplink=%d\n",
+		 "veb idx=%d,%d stats_ic=%d  seid=%d uplink=%d mode=%s\n",
 		 veb->idx, veb->veb_idx, veb->stats_idx, veb->seid,
-		 veb->uplink_seid);
+		 veb->uplink_seid,
+		 veb->bridge_mode == BRIDGE_MODE_VEPA ? "VEPA" : "VEB");
 	i40e_dbg_dump_eth_stats(pf, &veb->stats);
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 8b5bf16..cc11868 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -385,8 +385,7 @@ int i40e_fcoe_vsi_init(struct i40e_vsi *vsi, struct i40e_vsi_context *ctxt)
 	ctxt->flags = I40E_AQ_VSI_TYPE_PF;
 
 	/* FCoE VSI would need the following sections */
-	info->valid_sections |= cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID |
-					    I40E_AQ_VSI_PROP_QUEUE_OPT_VALID);
+	info->valid_sections |= cpu_to_le16(I40E_AQ_VSI_PROP_QUEUE_OPT_VALID);
 
 	/* FCoE VSI does not need these sections */
 	info->valid_sections &= cpu_to_le16(~(I40E_AQ_VSI_PROP_SECURITY_VALID |
@@ -395,7 +394,12 @@ int i40e_fcoe_vsi_init(struct i40e_vsi *vsi, struct i40e_vsi_context *ctxt)
 					    I40E_AQ_VSI_PROP_INGRESS_UP_VALID |
 					    I40E_AQ_VSI_PROP_EGRESS_UP_VALID));
 
-	info->switch_id = cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
+	if (i40e_is_vsi_uplink_mode_veb(vsi)) {
+		info->valid_sections |=
+				cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
+		info->switch_id =
+				cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
+	}
 	enabled_tc = i40e_get_fcoe_tc_map(pf);
 	i40e_vsi_setup_queue_map(vsi, ctxt, enabled_tc, true);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index eb2655f..97a759a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5872,6 +5872,26 @@ static void i40e_verify_eeprom(struct i40e_pf *pf)
 }
 
 /**
+ * i40e_config_bridge_mode - Configure the HW bridge mode
+ * @veb: pointer to the bridge instance
+ *
+ * Configure the loop back mode for the LAN VSI that is downlink to the
+ * specified HW bridge instance. It is expected this function is called
+ * when a new HW bridge is instantiated.
+ **/
+static void i40e_config_bridge_mode(struct i40e_veb *veb)
+{
+	struct i40e_pf *pf = veb->pf;
+
+	dev_info(&pf->pdev->dev, "enabling bridge mode: %s\n",
+		 veb->bridge_mode == BRIDGE_MODE_VEPA ? "VEPA" : "VEB");
+	if (veb->bridge_mode & BRIDGE_MODE_VEPA)
+		i40e_disable_pf_switch_lb(pf);
+	else
+		i40e_enable_pf_switch_lb(pf);
+}
+
+/**
  * i40e_reconstitute_veb - rebuild the VEB and anything connected to it
  * @veb: pointer to the VEB instance
  *
@@ -5917,8 +5937,7 @@ static int i40e_reconstitute_veb(struct i40e_veb *veb)
 	if (ret)
 		goto end_reconstitute;
 
-	/* Enable LB mode for the main VSI now that it is on a VEB */
-	i40e_enable_pf_switch_lb(pf);
+	i40e_config_bridge_mode(veb);
 
 	/* create the remaining VSIs attached to this VEB */
 	for (v = 0; v < pf->num_alloc_vsi; v++) {
@@ -7737,6 +7756,118 @@ static int i40e_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	return err;
 }
 
+#ifdef HAVE_BRIDGE_ATTRIBS
+/**
+ * i40e_ndo_bridge_setlink - Set the hardware bridge mode
+ * @dev: the netdev being configured
+ * @nlh: RTNL message
+ *
+ * Inserts a new hardware bridge if not already created and
+ * enables the bridging mode requested (VEB or VEPA). If the
+ * hardware bridge has already been inserted and the request
+ * is to change the mode then that requires a PF reset to
+ * allow rebuild of the components with required hardware
+ * bridge mode enabled.
+ **/
+static int i40e_ndo_bridge_setlink(struct net_device *dev,
+				   struct nlmsghdr *nlh)
+{
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_veb *veb = NULL;
+	struct nlattr *attr, *br_spec;
+	int i, rem;
+
+	/* Only for PF VSI for now */
+	if (vsi->seid != pf->vsi[pf->lan_vsi]->seid)
+		return -EOPNOTSUPP;
+
+	/* Find the HW bridge for PF VSI */
+	for (i = 0; i < I40E_MAX_VEB && !veb; i++) {
+		if (pf->veb[i] && pf->veb[i]->seid == vsi->uplink_seid)
+			veb = pf->veb[i];
+	}
+
+	br_spec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
+
+	nla_for_each_nested(attr, br_spec, rem) {
+		__u16 mode;
+
+		if (nla_type(attr) != IFLA_BRIDGE_MODE)
+			continue;
+
+		mode = nla_get_u16(attr);
+		if ((mode != BRIDGE_MODE_VEPA) &&
+		    (mode != BRIDGE_MODE_VEB))
+			return -EINVAL;
+
+		/* Insert a new HW bridge */
+		if (!veb) {
+			veb = i40e_veb_setup(pf, 0, vsi->uplink_seid, vsi->seid,
+					     vsi->tc_config.enabled_tc);
+			if (veb) {
+				veb->bridge_mode = mode;
+				i40e_config_bridge_mode(veb);
+			} else {
+				/* No Bridge HW offload available */
+				return -ENOENT;
+			}
+			break;
+		} else if (mode != veb->bridge_mode) {
+			/* Existing HW bridge but different mode needs reset */
+			veb->bridge_mode = mode;
+			i40e_do_reset(pf, (1 << __I40E_PF_RESET_REQUESTED));
+			break;
+		}
+	}
+
+	return 0;
+}
+
+/**
+ * i40e_ndo_bridge_getlink - Get the hardware bridge mode
+ * @skb: skb buff
+ * @pid: process id
+ * @seq: RTNL message seq #
+ * @dev: the netdev being configured
+ * @filter_mask: unused
+ *
+ * Return the mode in which the hardware bridge is operating in
+ * i.e VEB or VEPA.
+ **/
+#ifdef HAVE_BRIDGE_FILTER
+static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+				   struct net_device *dev,
+				   u32 __always_unused filter_mask)
+#else
+static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+				   struct net_device *dev)
+#endif /* HAVE_BRIDGE_FILTER */
+{
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_veb *veb = NULL;
+	int i;
+
+	/* Only for PF VSI for now */
+	if (vsi->seid != pf->vsi[pf->lan_vsi]->seid)
+		return -EOPNOTSUPP;
+
+	/* Find the HW bridge for the PF VSI */
+	for (i = 0; i < I40E_MAX_VEB && !veb; i++) {
+		if (pf->veb[i] && pf->veb[i]->seid == vsi->uplink_seid)
+			veb = pf->veb[i];
+	}
+
+	if (!veb)
+		return 0;
+
+	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, veb->bridge_mode);
+}
+#endif /* HAVE_BRIDGE_ATTRIBS */
+
 const struct net_device_ops i40e_netdev_ops = {
 	.ndo_open		= i40e_open,
 	.ndo_stop		= i40e_close,
@@ -7771,6 +7902,10 @@ const struct net_device_ops i40e_netdev_ops = {
 #endif
 	.ndo_get_phys_port_id	= i40e_get_phys_port_id,
 	.ndo_fdb_add		= i40e_ndo_fdb_add,
+#ifdef HAVE_BRIDGE_ATTRIBS
+	.ndo_bridge_getlink	= i40e_ndo_bridge_getlink,
+	.ndo_bridge_setlink	= i40e_ndo_bridge_setlink,
+#endif /* HAVE_BRIDGE_ATTRIBS */
 };
 
 /**
@@ -7883,6 +8018,30 @@ static void i40e_vsi_delete(struct i40e_vsi *vsi)
 }
 
 /**
+ * i40e_is_vsi_uplink_mode_veb - Check if the VSI's uplink bridge mode is VEB
+ * @vsi: the VSI being queried
+ *
+ * Returns 1 if HW bridge mode is VEB and return 0 in case of VEPA mode
+ **/
+int i40e_is_vsi_uplink_mode_veb(struct i40e_vsi *vsi)
+{
+	struct i40e_veb *veb;
+	struct i40e_pf *pf = vsi->back;
+
+	/* Uplink is not a bridge so default to VEB */
+	if (vsi->veb_idx == I40E_NO_VEB)
+		return 1;
+
+	veb = pf->veb[vsi->veb_idx];
+	/* Uplink is a bridge in VEPA mode */
+	if (veb && (veb->bridge_mode & BRIDGE_MODE_VEPA))
+		return 0;
+
+	/* Uplink is a bridge in VEB mode */
+	return 1;
+}
+
+/**
  * i40e_add_vsi - Add a VSI to the switch
  * @vsi: the VSI being configured
  *
@@ -7969,10 +8128,12 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 		ctxt.uplink_seid = vsi->uplink_seid;
 		ctxt.connection_type = I40E_AQ_VSI_CONN_TYPE_NORMAL;
 		ctxt.flags = I40E_AQ_VSI_TYPE_PF;
-		ctxt.info.valid_sections |=
+		if (i40e_is_vsi_uplink_mode_veb(vsi)) {
+			ctxt.info.valid_sections |=
 				cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
-		ctxt.info.switch_id =
+			ctxt.info.switch_id =
 				cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
+		}
 		i40e_vsi_setup_queue_map(vsi, &ctxt, enabled_tc, true);
 		break;
 
@@ -7983,13 +8144,15 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 		ctxt.connection_type = I40E_AQ_VSI_CONN_TYPE_NORMAL;
 		ctxt.flags = I40E_AQ_VSI_TYPE_VMDQ2;
 
-		ctxt.info.valid_sections |= cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
-
 		/* This VSI is connected to VEB so the switch_id
 		 * should be set to zero by default.
 		 */
-		ctxt.info.switch_id = 0;
-		ctxt.info.switch_id |= cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
+		if (i40e_is_vsi_uplink_mode_veb(vsi)) {
+			ctxt.info.valid_sections |=
+				cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
+			ctxt.info.switch_id =
+				cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
+		}
 
 		/* Setup the VSI tx/rx queue map for TC0 only for now */
 		i40e_vsi_setup_queue_map(vsi, &ctxt, enabled_tc, true);
@@ -8002,12 +8165,15 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 		ctxt.connection_type = I40E_AQ_VSI_CONN_TYPE_NORMAL;
 		ctxt.flags = I40E_AQ_VSI_TYPE_VF;
 
-		ctxt.info.valid_sections |= cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
-
 		/* This VSI is connected to VEB so the switch_id
 		 * should be set to zero by default.
 		 */
-		ctxt.info.switch_id = cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
+		if (i40e_is_vsi_uplink_mode_veb(vsi)) {
+			ctxt.info.valid_sections |=
+				cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
+			ctxt.info.switch_id =
+				cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_ALLOW_LB);
+		}
 
 		ctxt.info.valid_sections |= cpu_to_le16(I40E_AQ_VSI_PROP_VLAN_VALID);
 		ctxt.info.port_vlan_flags |= I40E_AQ_VSI_PVLAN_MODE_ALL;
@@ -8365,7 +8531,7 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 					 __func__);
 				return NULL;
 			}
-			i40e_enable_pf_switch_lb(pf);
+			i40e_config_bridge_mode(veb);
 		}
 		for (i = 0; i < I40E_MAX_VEB && !veb; i++) {
 			if (pf->veb[i] && pf->veb[i]->seid == vsi->uplink_seid)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 5450b9f..493335c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -752,7 +752,7 @@ void i40e_enable_pf_switch_lb(struct i40e_pf *pf)
  *
  * disable switch loop back or die - no point in a return value
  **/
-static void i40e_disable_pf_switch_lb(struct i40e_pf *pf)
+void i40e_disable_pf_switch_lb(struct i40e_pf *pf)
 {
 	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
 	struct i40e_vsi_context ctxt;
@@ -891,7 +891,6 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 	}
 	pf->num_alloc_vfs = num_alloc_vfs;
 
-	i40e_enable_pf_switch_lb(pf);
 err_alloc:
 	if (ret)
 		i40e_free_vfs(pf);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 9452f52..ef777a6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -127,5 +127,6 @@ int i40e_ndo_set_vf_spoofchk(struct net_device *netdev, int vf_id, bool enable);
 void i40e_vc_notify_link_state(struct i40e_pf *pf);
 void i40e_vc_notify_reset(struct i40e_pf *pf);
 void i40e_enable_pf_switch_lb(struct i40e_pf *pf);
+void i40e_disable_pf_switch_lb(struct i40e_pf *pf);
 
 #endif /* _I40E_VIRTCHNL_PF_H_ */
-- 
1.9.3
