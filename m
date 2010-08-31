From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 07/10] qlcnic: fix mac override capability
Date: Tue, 31 Aug 2010 07:29:37 -0700
Message-ID: <1283264980-25881-8-git-send-email-amit.salecha@qlogic.com>
References: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:24406 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757477Ab0HaO3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 10:29:42 -0400
In-Reply-To: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Rename mac_learning to mac_override
o Added check in set_mac to return error if mac override is disabled.
o Disabling mac_override only supported for Non priviledged functions.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    5 +++--
 drivers/net/qlcnic/qlcnic_ctx.c  |   13 +++++++------
 drivers/net/qlcnic/qlcnic_main.c |   23 ++++++++++++++++++-----
 3 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9c87044..a7799df 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -905,6 +905,7 @@ struct qlcnic_mac_req {
 #define QLCNIC_ADAPTER_INITIALIZED	0x80
 #define QLCNIC_TAGGING_ENABLED		0x100
 #define QLCNIC_MACSPOOF			0x200
+#define QLCNIC_MAC_OVERRIDE_DISABLED	0x400
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
@@ -1060,7 +1061,7 @@ struct qlcnic_npar_info {
 	u8	enable_pm;
 	u8	dest_npar;
 	u8	discard_tagged;
-	u8	mac_learning;
+	u8	mac_override;
 	u8	mac_anti_spoof;
 	u8	promisc_mode;
 	u8	offload_flags;
@@ -1135,7 +1136,7 @@ struct qlcnic_esw_func_cfg {
 	u8	host_vlan_tag;
 	u8	promisc_mode;
 	u8	discard_tagged;
-	u8	mac_learning;
+	u8	mac_override;
 	u8	mac_anti_spoof;
 	u8	offload_flags;
 	u8	reserved[5];
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index bd4b06b..95a821e 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -1100,10 +1100,11 @@ __qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
 		*arg1 = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
 		*arg2 = QLCRD32(adapter, QLCNIC_ARG2_CRB_OFFSET);
 		dev_info(&adapter->pdev->dev,
-			"eSwitch port config for pci func%d\n",	pci_func);
+			"eSwitch port config for pci func %d\n", pci_func);
 	} else {
 		dev_err(&adapter->pdev->dev,
-			"Failed to get eswitch port config%d\n", pci_func);
+			"Failed to get eswitch port config for pci func %d\n",
+								pci_func);
 	}
 	return err;
 }
@@ -1142,7 +1143,7 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 			arg1 &= ~BIT_4;
 		if (!(esw_cfg->promisc_mode))
 			arg1 &= ~BIT_6;
-		if (!(esw_cfg->mac_learning))
+		if (!(esw_cfg->mac_override))
 			arg1 &= ~BIT_7;
 		if (!(esw_cfg->mac_anti_spoof))
 			arg2 &= ~BIT_0;
@@ -1175,10 +1176,10 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 
 	if (err != QLCNIC_RCODE_SUCCESS) {
 		dev_err(&adapter->pdev->dev,
-			"Failed to configure eswitch port%d\n", pci_func);
+			"Failed to configure eswitch pci func %d\n", pci_func);
 	} else {
 		dev_info(&adapter->pdev->dev,
-			"Configured eSwitch for port %d\n", pci_func);
+			"Configured eSwitch for pci func %d\n", pci_func);
 	}
 
 	return err;
@@ -1202,7 +1203,7 @@ qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
 	esw_cfg->discard_tagged = !!(arg1 & BIT_4);
 	esw_cfg->host_vlan_tag = !!(arg1 & BIT_5);
 	esw_cfg->promisc_mode = !!(arg1 & BIT_6);
-	esw_cfg->mac_learning = !!(arg1 & BIT_7);
+	esw_cfg->mac_override = !!(arg1 & BIT_7);
 	esw_cfg->vlan_id = LSW(arg1 >> 16);
 	esw_cfg->mac_anti_spoof = (arg2 & 0x1);
 	esw_cfg->offload_flags = ((arg2 >> 1) & 0x7);
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 789fe81..130f4db 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -343,6 +343,9 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 
+	if ((adapter->flags & QLCNIC_MAC_OVERRIDE_DISABLED))
+		return -EOPNOTSUPP;
+
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EINVAL;
 
@@ -741,10 +744,14 @@ qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	adapter->flags &= ~QLCNIC_MACSPOOF;
+	adapter->flags &= ~QLCNIC_MAC_OVERRIDE_DISABLED;
 
 	if (esw_cfg->mac_anti_spoof)
 		adapter->flags |= QLCNIC_MACSPOOF;
 
+	if (!esw_cfg->mac_override)
+		adapter->flags |= QLCNIC_MAC_OVERRIDE_DISABLED;
+
 	qlcnic_set_netdev_features(adapter, esw_cfg);
 }
 
@@ -862,14 +869,14 @@ qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 		memset(&esw_cfg, 0, sizeof(struct qlcnic_esw_func_cfg));
 		esw_cfg.pci_func = i;
 		esw_cfg.offload_flags = BIT_0;
-		esw_cfg.mac_learning = BIT_0;
+		esw_cfg.mac_override = BIT_0;
 		if (adapter->capabilities  & QLCNIC_FW_CAPABILITY_TSO)
 			esw_cfg.offload_flags |= (BIT_1 | BIT_2);
 		if (qlcnic_config_switch_port(adapter, &esw_cfg))
 			return -EIO;
 		npar = &adapter->npars[i];
 		npar->pvid = esw_cfg.vlan_id;
-		npar->mac_learning = esw_cfg.offload_flags;
+		npar->mac_override = esw_cfg.mac_override;
 		npar->mac_anti_spoof = esw_cfg.mac_anti_spoof;
 		npar->discard_tagged = esw_cfg.discard_tagged;
 		npar->promisc_mode = esw_cfg.promisc_mode;
@@ -887,7 +894,7 @@ qlcnic_reset_eswitch_config(struct qlcnic_adapter *adapter,
 	esw_cfg.op_mode = QLCNIC_PORT_DEFAULTS;
 	esw_cfg.pci_func = pci_func;
 	esw_cfg.vlan_id = npar->pvid;
-	esw_cfg.mac_learning = npar->mac_learning;
+	esw_cfg.mac_override = npar->mac_override;
 	esw_cfg.discard_tagged = npar->discard_tagged;
 	esw_cfg.mac_anti_spoof = npar->mac_anti_spoof;
 	esw_cfg.offload_flags = npar->offload_flags;
@@ -3042,6 +3049,10 @@ qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
 
 	qlcnic_check_options(adapter);
 
+	err = qlcnic_set_eswitch_port_config(adapter);
+	if (err)
+		return err;
+
 	adapter->need_fw_reset = 0;
 
 	return err;
@@ -3397,8 +3408,10 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 		switch (esw_cfg[i].op_mode) {
 		case QLCNIC_PORT_DEFAULTS:
 			if (QLC_DEV_GET_DRV(op_mode, pci_func) !=
-						QLCNIC_NON_PRIV_FUNC)
+						QLCNIC_NON_PRIV_FUNC) {
 				esw_cfg[i].mac_anti_spoof = 0;
+				esw_cfg[i].mac_override = 1;
+			}
 			break;
 		case QLCNIC_ADD_VLAN:
 			if (!IS_VALID_VLAN(esw_cfg[i].vlan_id))
@@ -3474,7 +3487,7 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 		switch (esw_cfg[i].op_mode) {
 		case QLCNIC_PORT_DEFAULTS:
 			npar->promisc_mode = esw_cfg[i].promisc_mode;
-			npar->mac_learning = esw_cfg[i].mac_learning;
+			npar->mac_override = esw_cfg[i].mac_override;
 			npar->offload_flags = esw_cfg[i].offload_flags;
 			npar->mac_anti_spoof = esw_cfg[i].mac_anti_spoof;
 			npar->discard_tagged = esw_cfg[i].discard_tagged;
-- 
1.6.0.2

