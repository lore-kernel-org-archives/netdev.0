From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 01/10] be2net: add support for spoofchk setting
Date: Mon,  4 May 2015 02:47:13 -0400
Message-ID: <1430722042-26449-2-git-send-email-sathya.perla@emulex.com>
References: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63199 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752163AbbEDG7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 02:59:19 -0400
In-Reply-To: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This patch adds support for spoofchk configuration for VFs.
When it is enabled, "spoof checking" is done for both MAC-address and VLAN.
This feature is supported in Skyhawk FW version 10.6.31.0 and above.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c | 16 +++++++--
 drivers/net/ethernet/emulex/benet/be_cmds.h | 24 +++++++++-----
 drivers/net/ethernet/emulex/benet/be_main.c | 51 ++++++++++++++++++++++++++---
 4 files changed, 78 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 1bf1cdc..bbfbbb3 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -366,6 +366,7 @@ struct be_vf_cfg {
 	u32 tx_rate;
 	u32 plink_tracking;
 	u32 privileges;
+	bool spoofchk;
 };
 
 enum vf_state {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index fb140fa..e630fe0 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3153,7 +3153,7 @@ int be_cmd_set_mac(struct be_adapter *adapter, u8 *mac, int if_id, u32 dom)
 }
 
 int be_cmd_set_hsw_config(struct be_adapter *adapter, u16 pvid,
-			  u32 domain, u16 intf_id, u16 hsw_mode)
+			  u32 domain, u16 intf_id, u16 hsw_mode, u8 spoofchk)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_set_hsw_config *req;
@@ -3189,6 +3189,14 @@ int be_cmd_set_hsw_config(struct be_adapter *adapter, u16 pvid,
 			      ctxt, hsw_mode);
 	}
 
+	/* Enable/disable both mac and vlan spoof checking */
+	if (!BEx_chip(adapter) && spoofchk) {
+		AMAP_SET_BITS(struct amap_set_hsw_context, mac_spoofchk,
+			      ctxt, spoofchk);
+		AMAP_SET_BITS(struct amap_set_hsw_context, vlan_spoofchk,
+			      ctxt, spoofchk);
+	}
+
 	be_dws_cpu_to_le(req->context, sizeof(req->context));
 	status = be_mcc_notify_wait(adapter);
 
@@ -3199,7 +3207,7 @@ err:
 
 /* Get Hyper switch config */
 int be_cmd_get_hsw_config(struct be_adapter *adapter, u16 *pvid,
-			  u32 domain, u16 intf_id, u8 *mode)
+			  u32 domain, u16 intf_id, u8 *mode, bool *spoofchk)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_hsw_config *req;
@@ -3247,6 +3255,10 @@ int be_cmd_get_hsw_config(struct be_adapter *adapter, u16 *pvid,
 		if (mode)
 			*mode = AMAP_GET_BITS(struct amap_get_hsw_resp_context,
 					      port_fwd_type, &resp->context);
+		if (spoofchk)
+			*spoofchk =
+				AMAP_GET_BITS(struct amap_get_hsw_resp_context,
+					      spoofchk, &resp->context);
 	}
 
 err:
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 1ec2230..cf5f855 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1745,18 +1745,24 @@ struct be_cmd_req_set_mac_list {
 #define PORT_FWD_TYPE_VEPA		0x3
 #define PORT_FWD_TYPE_VEB		0x2
 
+#define ENABLE_MAC_SPOOFCHK		0x2
+#define DISABLE_MAC_SPOOFCHK		0x3
+
 struct amap_set_hsw_context {
 	u8 interface_id[16];
-	u8 rsvd0[14];
+	u8 rsvd0[8];
+	u8 mac_spoofchk[2];
+	u8 rsvd1[4];
 	u8 pvid_valid;
 	u8 pport;
-	u8 rsvd1[6];
+	u8 rsvd2[6];
 	u8 port_fwd_type[3];
-	u8 rsvd2[7];
+	u8 rsvd3[5];
+	u8 vlan_spoofchk[2];
 	u8 pvid[16];
-	u8 rsvd3[32];
 	u8 rsvd4[32];
 	u8 rsvd5[32];
+	u8 rsvd6[32];
 } __packed;
 
 struct be_cmd_req_set_hsw_config {
@@ -1774,11 +1780,13 @@ struct amap_get_hsw_req_context {
 struct amap_get_hsw_resp_context {
 	u8 rsvd0[6];
 	u8 port_fwd_type[3];
-	u8 rsvd1[7];
+	u8 rsvd1[5];
+	u8 spoofchk;
+	u8 rsvd2;
 	u8 pvid[16];
-	u8 rsvd2[32];
 	u8 rsvd3[32];
 	u8 rsvd4[32];
+	u8 rsvd5[32];
 } __packed;
 
 struct be_cmd_req_get_hsw_config {
@@ -2334,9 +2342,9 @@ int be_cmd_set_mac_list(struct be_adapter *adapter, u8 *mac_array, u8 mac_count,
 			u32 domain);
 int be_cmd_set_mac(struct be_adapter *adapter, u8 *mac, int if_id, u32 dom);
 int be_cmd_set_hsw_config(struct be_adapter *adapter, u16 pvid, u32 domain,
-			  u16 intf_id, u16 hsw_mode);
+			  u16 intf_id, u16 hsw_mode, u8 spoofchk);
 int be_cmd_get_hsw_config(struct be_adapter *adapter, u16 *pvid, u32 domain,
-			  u16 intf_id, u8 *mode);
+			  u16 intf_id, u8 *mode, bool *spoofchk);
 int be_cmd_get_acpi_wol_cap(struct be_adapter *adapter);
 int be_cmd_set_fw_log_level(struct be_adapter *adapter, u32 level);
 int be_cmd_get_fw_log_level(struct be_adapter *adapter);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index fb0bc3c..352ba95 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1466,6 +1466,7 @@ static int be_get_vf_config(struct net_device *netdev, int vf,
 	vi->qos = vf_cfg->vlan_tag >> VLAN_PRIO_SHIFT;
 	memcpy(&vi->mac, vf_cfg->mac_addr, ETH_ALEN);
 	vi->linkstate = adapter->vf_cfg[vf].plink_tracking;
+	vi->spoofchk = adapter->vf_cfg[vf].spoofchk;
 
 	return 0;
 }
@@ -1478,7 +1479,7 @@ static int be_set_vf_tvt(struct be_adapter *adapter, int vf, u16 vlan)
 	int status;
 
 	/* Enable Transparent VLAN Tagging */
-	status = be_cmd_set_hsw_config(adapter, vlan, vf + 1, vf_if_id, 0);
+	status = be_cmd_set_hsw_config(adapter, vlan, vf + 1, vf_if_id, 0, 0);
 	if (status)
 		return status;
 
@@ -1507,7 +1508,7 @@ static int be_clear_vf_tvt(struct be_adapter *adapter, int vf)
 
 	/* Reset Transparent VLAN Tagging. */
 	status = be_cmd_set_hsw_config(adapter, BE_RESET_VLAN_TAG_ID, vf + 1,
-				       vf_cfg->if_handle, 0);
+				       vf_cfg->if_handle, 0, 0);
 	if (status)
 		return status;
 
@@ -1642,6 +1643,39 @@ static int be_set_vf_link_state(struct net_device *netdev, int vf,
 	return 0;
 }
 
+static int be_set_vf_spoofchk(struct net_device *netdev, int vf, bool enable)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_vf_cfg *vf_cfg = &adapter->vf_cfg[vf];
+	u8 spoofchk;
+	int status;
+
+	if (!sriov_enabled(adapter))
+		return -EPERM;
+
+	if (vf >= adapter->num_vfs)
+		return -EINVAL;
+
+	if (BEx_chip(adapter))
+		return -EOPNOTSUPP;
+
+	if (enable == vf_cfg->spoofchk)
+		return 0;
+
+	spoofchk = enable ? ENABLE_MAC_SPOOFCHK : DISABLE_MAC_SPOOFCHK;
+
+	status = be_cmd_set_hsw_config(adapter, 0, vf + 1, vf_cfg->if_handle,
+				       0, spoofchk);
+	if (status) {
+		dev_err(&adapter->pdev->dev,
+			"Spoofchk change on VF %d failed: %#x\n", vf, status);
+		return be_cmd_status(status);
+	}
+
+	vf_cfg->spoofchk = enable;
+	return 0;
+}
+
 static void be_aic_update(struct be_aic_obj *aic, u64 rx_pkts, u64 tx_pkts,
 			  ulong now)
 {
@@ -3610,6 +3644,7 @@ static int be_vf_setup(struct be_adapter *adapter)
 	struct device *dev = &adapter->pdev->dev;
 	struct be_vf_cfg *vf_cfg;
 	int status, old_vfs, vf;
+	bool spoofchk;
 
 	old_vfs = pci_num_vf(adapter->pdev);
 
@@ -3657,6 +3692,12 @@ static int be_vf_setup(struct be_adapter *adapter)
 		if (!old_vfs)
 			be_cmd_config_qos(adapter, 0, 0, vf + 1);
 
+		status = be_cmd_get_hsw_config(adapter, NULL, vf + 1,
+					       vf_cfg->if_handle, NULL,
+					       &spoofchk);
+		if (!status)
+			vf_cfg->spoofchk = spoofchk;
+
 		if (!old_vfs) {
 			be_cmd_enable_vf(adapter, vf + 1);
 			be_cmd_set_logical_link_config(adapter,
@@ -4829,7 +4870,7 @@ static int be_ndo_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
 					       adapter->if_handle,
 					       mode == BRIDGE_MODE_VEPA ?
 					       PORT_FWD_TYPE_VEPA :
-					       PORT_FWD_TYPE_VEB);
+					       PORT_FWD_TYPE_VEB, 0);
 		if (status)
 			goto err;
 
@@ -4860,7 +4901,8 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 		hsw_mode = PORT_FWD_TYPE_VEB;
 	} else {
 		status = be_cmd_get_hsw_config(adapter, NULL, 0,
-					       adapter->if_handle, &hsw_mode);
+					       adapter->if_handle, &hsw_mode,
+					       NULL);
 		if (status)
 			return 0;
 	}
@@ -5013,6 +5055,7 @@ static const struct net_device_ops be_netdev_ops = {
 	.ndo_set_vf_rate	= be_set_vf_tx_rate,
 	.ndo_get_vf_config	= be_get_vf_config,
 	.ndo_set_vf_link_state  = be_set_vf_link_state,
+	.ndo_set_vf_spoofchk    = be_set_vf_spoofchk,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= be_netpoll,
 #endif
-- 
2.2.0
