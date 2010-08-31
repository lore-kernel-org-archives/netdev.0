From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 05/10] qlcnic: fix mac anti spoof policy
Date: Tue, 31 Aug 2010 07:29:35 -0700
Message-ID: <1283264980-25881-6-git-send-email-amit.salecha@qlogic.com>
References: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45594 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757470Ab0HaO3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 10:29:41 -0400
In-Reply-To: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Allow enabling/disabling mac anti spoof policy only for
  Non privilege functions.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index e0c6811..9a3ebb8 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -741,9 +741,9 @@ qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	adapter->flags &= ~QLCNIC_MACSPOOF;
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
-		if (esw_cfg->mac_anti_spoof)
-			adapter->flags |= QLCNIC_MACSPOOF;
+
+	if (esw_cfg->mac_anti_spoof)
+		adapter->flags |= QLCNIC_MACSPOOF;
 
 	qlcnic_set_netdev_features(adapter, esw_cfg);
 }
@@ -3377,8 +3377,12 @@ static int
 validate_esw_config(struct qlcnic_adapter *adapter,
 	struct qlcnic_esw_func_cfg *esw_cfg, int count)
 {
+	u32 op_mode;
 	u8 pci_func;
 	int i;
+
+	op_mode = readl(adapter->ahw.pci_base0 + QLCNIC_DRV_OP_MODE);
+
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
 		if (pci_func >= QLCNIC_MAX_PCI_FUNC)
@@ -3390,6 +3394,9 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 
 		switch (esw_cfg[i].op_mode) {
 		case QLCNIC_PORT_DEFAULTS:
+			if (QLC_DEV_GET_DRV(op_mode, pci_func) !=
+						QLCNIC_NON_PRIV_FUNC)
+				esw_cfg[i].mac_anti_spoof = 0;
 			break;
 		case QLCNIC_ADD_VLAN:
 			if (!IS_VALID_VLAN(esw_cfg[i].vlan_id))
-- 
1.6.0.2

