From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/4] qlcnic: eswitch config fixes
Date: Wed, 25 Aug 2010 07:03:02 -0700
Message-ID: <1282744985-31540-2-git-send-email-amit.salecha@qlogic.com>
References: <1282744985-31540-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:1148 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753115Ab0HYODG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 10:03:06 -0400
In-Reply-To: <1282744985-31540-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o remove validation before deleting vlan id
o Add missing 'break' while deleting vlan id.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ctx.c  |    1 +
 drivers/net/qlcnic/qlcnic_main.c |   26 ++++++++++++++------------
 2 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 315705b..bd4b06b 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -1160,6 +1160,7 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 	case QLCNIC_DEL_VLAN:
 			arg1 |= (BIT_3 | BIT_5);
 			arg1 &= ~(0x0ffff << 16);
+			break;
 	default:
 		return err;
 	}
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 46b9137..5d93b46 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -3301,8 +3301,6 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 				return QL_STATUS_INVALID_PARAM;
 			break;
 		case QLCNIC_DEL_VLAN:
-			if (!IS_VALID_VLAN(esw_cfg[i].vlan_id))
-				return QL_STATUS_INVALID_PARAM;
 			if (!esw_cfg[i].op_type)
 				return QL_STATUS_INVALID_PARAM;
 			break;
@@ -3338,21 +3336,25 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 		if (adapter->op_mode == QLCNIC_MGMT_FUNC)
 			if (qlcnic_config_switch_port(adapter, &esw_cfg[i]))
 				return QL_STATUS_INVALID_PARAM;
-		if (adapter->ahw.pci_func == esw_cfg[i].pci_func)
-			op_mode = esw_cfg[i].op_mode;
-			qlcnic_get_eswitch_port_config(adapter, &esw_cfg[i]);
-			esw_cfg[i].op_mode = op_mode;
-			esw_cfg[i].pci_func = adapter->ahw.pci_func;
-			switch (esw_cfg[i].op_mode) {
-			case QLCNIC_PORT_DEFAULTS:
-				qlcnic_set_eswitch_port_features(adapter,
-								&esw_cfg[i]);
-				break;
+
+		if (adapter->ahw.pci_func != esw_cfg[i].pci_func)
+			continue;
+
+		op_mode = esw_cfg[i].op_mode;
+		qlcnic_get_eswitch_port_config(adapter, &esw_cfg[i]);
+		esw_cfg[i].op_mode = op_mode;
+		esw_cfg[i].pci_func = adapter->ahw.pci_func;
+
+		switch (esw_cfg[i].op_mode) {
+		case QLCNIC_PORT_DEFAULTS:
+			qlcnic_set_eswitch_port_features(adapter, &esw_cfg[i]);
+			break;
 		}
 	}
 
 	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
 		goto out;
+
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
 		npar = &adapter->npars[pci_func];
-- 
1.6.0.2

