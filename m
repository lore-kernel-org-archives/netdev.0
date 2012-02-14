From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [RFC net-next 2/2] be2net: add support for VF privileges
Date: Tue, 14 Feb 2012 13:26:29 -0600
Message-ID: <20120214192629.GA14205@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:31047 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759949Ab2BNT1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:27:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    2 +
 drivers/net/ethernet/emulex/benet/be_cmds.c |   69 +++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |   45 ++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_main.c |   73 ++++++++++++++++++++++++++-
 4 files changed, 188 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 86f51de..e0a612a 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -301,6 +301,7 @@ struct be_vf_cfg {
 	int pmac_id;
 	u16 vlan_tag;
 	u32 tx_rate;
+	u32 privileges;
 };
 
 #define BE_FLAGS_LINK_STATUS_INIT		1
@@ -379,6 +380,7 @@ struct be_adapter {
 	struct completion flash_compl;
 
 	u32 num_vfs;
+	u32 privileges;
 	u8 is_virtfn;
 	struct be_vf_cfg *vf_cfg;
 	bool be3_native;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 6432efa..3c38f2f 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2293,6 +2293,75 @@ err:
 	return status;
 }
 
+/* Set privilege(s) for a function */
+int be_cmd_set_fn_privileges(struct be_adapter *adapter, u32 mask, u32 *prev,
+			u32 domain)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_set_fn_privileges *req;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+
+	req = embedded_payload(wrb);
+
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_SET_FN_PRIVILEGES, sizeof(*req), wrb,
+			NULL);
+
+	req->hdr.domain = domain;
+	req->privilege_mask = cpu_to_le32(mask);
+
+	status = be_mcc_notify_wait(adapter);
+
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
+/* Get privilege(s) for a function */
+int be_cmd_get_fn_privileges(struct be_adapter *adapter, u32 *privilege,
+			u32 domain)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_fn_privileges *req;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+
+	req = embedded_payload(wrb);
+
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_GET_FN_PRIVILEGES, sizeof(*req), wrb,
+			NULL);
+
+	req->hdr.domain = domain;
+
+	status = be_mcc_notify_wait(adapter);
+	if (!status) {
+		struct be_cmd_resp_get_fn_privileges *resp =
+						embedded_payload(wrb);
+		*privilege = le32_to_cpu(resp->privilege_mask);
+	} else
+		*privilege = 0;
+
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
 /* Uses synchronous MCCQ */
 int be_cmd_get_mac_from_list(struct be_adapter *adapter, u32 domain,
 			bool *pmac_id_active, u32 *pmac_id, u8 *mac)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 687c420..7fe0922 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -186,9 +186,11 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_ENABLE_DISABLE_BEACON		69
 #define OPCODE_COMMON_GET_BEACON_STATE			70
 #define OPCODE_COMMON_READ_TRANSRECV_DATA		73
+#define OPCODE_COMMON_SET_FN_PRIVILEGES			100
 #define OPCODE_COMMON_GET_PHY_DETAILS			102
 #define OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP		103
 #define OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES	121
+#define OPCODE_COMMON_GET_FN_PRIVILEGES			170
 #define OPCODE_COMMON_GET_MAC_LIST			147
 #define OPCODE_COMMON_SET_MAC_LIST			148
 #define OPCODE_COMMON_READ_OBJECT			171
@@ -1489,6 +1491,45 @@ static inline void *be_erx_stats_from_cmd(struct be_adapter *adapter)
 	}
 }
 
+/*********************** Function Privileges ***********************/
+enum {
+	BE_PRIV_DEFAULT = 0x1,
+	BE_PRIV_LNKQUERY = 0x2,
+	BE_PRIV_LNKSTATS = 0x4,
+	BE_PRIV_LNKMGMT = 0x8,
+	BE_PRIV_LNKDIAG = 0x10,
+	BE_PRIV_UTILQUERY = 0x20,
+	BE_PRIV_FILTMGMT = 0x40,
+	BE_PRIV_IFACEMGMT = 0x80,
+	BE_PRIV_VHADM = 0x100,
+	BE_PRIV_DEVCFG = 0x200,
+	BE_PRIV_DEVSEC = 0x400
+};
+
+#define BE_VF_DEFAULT_PRIV	(BE_PRIV_LNKQUERY |\
+				 BE_PRIV_IFACEMGMT |\
+				 BE_PRIV_LNKSTATS)
+
+struct be_cmd_req_get_fn_privileges {
+	struct be_cmd_req_hdr hdr;
+	u32 rsvd;
+};
+
+struct be_cmd_resp_get_fn_privileges {
+	struct be_cmd_resp_hdr hdr;
+	u32 privilege_mask;
+};
+
+struct be_cmd_req_set_fn_privileges {
+	struct be_cmd_req_hdr hdr;
+	u32 privilege_mask;
+};
+
+struct be_cmd_resp_set_fn_privileges {
+	struct be_cmd_resp_hdr hdr;
+	u32 prev_privilege_mask;
+};
+
 extern int be_pci_fnum_get(struct be_adapter *adapter);
 extern int be_cmd_POST(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
@@ -1586,6 +1627,10 @@ extern int be_cmd_get_cntl_attributes(struct be_adapter *adapter);
 extern int be_cmd_req_native_mode(struct be_adapter *adapter);
 extern int be_cmd_get_reg_len(struct be_adapter *adapter, u32 *log_size);
 extern void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf);
+extern int be_cmd_get_fn_privileges(struct be_adapter *adapter,
+				u32 *privilege, u32 domain);
+extern int be_cmd_set_fn_privileges(struct be_adapter *adapter,
+				u32 mask, u32 *prev, u32 domain);
 extern int be_cmd_get_mac_from_list(struct be_adapter *adapter, u32 domain,
 				bool *pmac_id_active, u32 *pmac_id, u8 *mac);
 extern int be_cmd_set_mac_list(struct be_adapter *adapter, u8 *mac_array,
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 28f2b25..8d1b6cc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -919,6 +919,24 @@ static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	return status;
 }
 
+static u32 to_ip_privilege(u32 privileges)
+{
+	u32 priv = IFLA_VF_PRIVILEGE_DEFAULT;
+
+	if (privileges & BE_PRIV_FILTMGMT)
+		priv |= IFLA_VF_PRIVILEGE_MAC | IFLA_VF_PRIVILEGE_VLAN;
+	if (privileges & BE_PRIV_LNKDIAG)
+		priv |= IFLA_VF_PRIVILEGE_DIAG;
+	if (privileges & BE_PRIV_DEVCFG)
+		priv |= IFLA_VF_PRIVILEGE_DEV_CFG;
+	if (privileges & BE_PRIV_DEVSEC)
+		priv |= IFLA_VF_PRIVILEGE_SECURE;
+	if (privileges & BE_PRIV_LNKMGMT)
+		priv |= IFLA_VF_PRIVILEGE_LNK_MGMT;
+
+	return priv;
+}
+
 static int be_get_vf_config(struct net_device *netdev, int vf,
 			struct ifla_vf_info *vi)
 {
@@ -935,11 +953,56 @@ static int be_get_vf_config(struct net_device *netdev, int vf,
 	vi->tx_rate = vf_cfg->tx_rate;
 	vi->vlan = vf_cfg->vlan_tag;
 	vi->qos = 0;
+	vi->privilege = to_ip_privilege(vf_cfg->privileges);
 	memcpy(&vi->mac, vf_cfg->mac_addr, ETH_ALEN);
 
 	return 0;
 }
 
+static u32 to_be_privilege(struct be_adapter *adapter, u32 privilege)
+{
+	u32 priv = BE_VF_DEFAULT_PRIV;
+
+	if ((privilege & IFLA_VF_PRIVILEGE_MAC) ||
+	    (privilege & IFLA_VF_PRIVILEGE_VLAN))
+		priv |= BE_PRIV_FILTMGMT;
+	if (privilege & IFLA_VF_PRIVILEGE_DIAG)
+		priv |= BE_PRIV_LNKDIAG;
+	if (privilege & IFLA_VF_PRIVILEGE_DEV_CFG)
+		priv |= BE_PRIV_DEVCFG;
+	if (privilege & IFLA_VF_PRIVILEGE_LNK_MGMT)
+		priv |= BE_PRIV_LNKMGMT;
+	if (privilege & IFLA_VF_PRIVILEGE_SECURE)
+		priv |= BE_PRIV_DEVSEC;
+
+	return priv;
+}
+
+static int be_set_vf_privilege(struct net_device *netdev, int vf, u32 privilege)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	int status = 0;
+	u32 priv;
+
+	if (!sriov_enabled(adapter))
+		return -EPERM;
+
+	if (vf >= adapter->num_vfs)
+		return -EINVAL;
+
+	/* Convert OS priv type to BE priv type. */
+	priv = to_be_privilege(adapter, privilege);
+	status = be_cmd_set_fn_privileges(adapter, priv, NULL, vf + 1);
+
+	if (status)
+		dev_err(&adapter->pdev->dev,
+			"set privilege on VF %d failed\n", vf);
+	else
+		dev_info(&adapter->pdev->dev,
+			 "set privilege %x on VF %d succeeded\n", priv, vf);
+	return status;
+}
+
 static int be_set_vf_vlan(struct net_device *netdev,
 			int vf, u16 vlan, u8 qos)
 {
@@ -2478,7 +2541,7 @@ static void be_vf_setup_init(struct be_adapter *adapter)
 static int be_vf_setup(struct be_adapter *adapter)
 {
 	struct be_vf_cfg *vf_cfg;
-	u32 cap_flags, en_flags, vf;
+	u32 cap_flags, en_flags, vf, privileges;
 	u16 lnk_speed;
 	int status;
 
@@ -2504,6 +2567,12 @@ static int be_vf_setup(struct be_adapter *adapter)
 			goto err;
 		vf_cfg->tx_rate = lnk_speed * 10;
 	}
+
+	for_all_vfs(adapter, vf_cfg, vf) {
+		status = be_cmd_get_fn_privileges(adapter, &privileges, vf + 1);
+		if (!status)
+			vf_cfg->privileges = privileges;
+	}
 	return 0;
 err:
 	return status;
@@ -2648,6 +2717,7 @@ static int be_setup(struct be_adapter *adapter)
 			goto err;
 	}
 
+	be_cmd_get_fn_privileges(adapter, &adapter->privileges, 0);
 	return 0;
 err:
 	be_clear(adapter);
@@ -3016,6 +3086,7 @@ static const struct net_device_ops be_netdev_ops = {
 	.ndo_set_vf_mac		= be_set_vf_mac,
 	.ndo_set_vf_vlan	= be_set_vf_vlan,
 	.ndo_set_vf_tx_rate	= be_set_vf_tx_rate,
+	.ndo_set_vf_privilege	= be_set_vf_privilege,
 	.ndo_get_vf_config	= be_get_vf_config,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= be_netpoll,
-- 
1.7.1
