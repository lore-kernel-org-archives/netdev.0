From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 5/7] qlcnic: fix promiscous mode for VF
Date: Fri,  8 Oct 2010 02:46:09 -0700
Message-ID: <1286531171-21173-6-git-send-email-amit.salecha@qlogic.com>
References: <1286531171-21173-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:44662 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754804Ab0JHJqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 05:46:13 -0400
In-Reply-To: <1286531171-21173-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Allow promiscous mode setting for VF's depending upon the configuration.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 +
 drivers/net/qlcnic/qlcnic_hw.c   |    3 ++-
 drivers/net/qlcnic/qlcnic_main.c |    9 +++++++--
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 46a54b3..4025e20 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -920,6 +920,7 @@ struct qlcnic_ipaddr {
 #define QLCNIC_TAGGING_ENABLED		0x100
 #define QLCNIC_MACSPOOF			0x200
 #define QLCNIC_MAC_OVERRIDE_DISABLED	0x400
+#define QLCNIC_PROMISC_DISABLED		0x800
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 7f1f9b4..53e8053 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -442,7 +442,8 @@ void qlcnic_set_multi(struct net_device *netdev)
 	qlcnic_nic_add_mac(adapter, bcast_addr);
 
 	if (netdev->flags & IFF_PROMISC) {
-		mode = VPORT_MISS_MODE_ACCEPT_ALL;
+		if (!(adapter->flags & QLCNIC_PROMISC_DISABLED))
+			mode = VPORT_MISS_MODE_ACCEPT_ALL;
 		goto send_fw_cmd;
 	}
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index e3c1b80..4aada0b 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -718,8 +718,8 @@ static void
 qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
-	adapter->flags &= ~QLCNIC_MACSPOOF;
-	adapter->flags &= ~QLCNIC_MAC_OVERRIDE_DISABLED;
+	adapter->flags &= ~(QLCNIC_MACSPOOF | QLCNIC_MAC_OVERRIDE_DISABLED |
+				QLCNIC_PROMISC_DISABLED);
 
 	if (esw_cfg->mac_anti_spoof)
 		adapter->flags |= QLCNIC_MACSPOOF;
@@ -727,6 +727,9 @@ qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
 	if (!esw_cfg->mac_override)
 		adapter->flags |= QLCNIC_MAC_OVERRIDE_DISABLED;
 
+	if (!esw_cfg->promisc_mode)
+		adapter->flags |= QLCNIC_PROMISC_DISABLED;
+
 	qlcnic_set_netdev_features(adapter, esw_cfg);
 }
 
@@ -845,6 +848,7 @@ qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 		esw_cfg.pci_func = i;
 		esw_cfg.offload_flags = BIT_0;
 		esw_cfg.mac_override = BIT_0;
+		esw_cfg.promisc_mode = BIT_0;
 		if (adapter->capabilities  & QLCNIC_FW_CAPABILITY_TSO)
 			esw_cfg.offload_flags |= (BIT_1 | BIT_2);
 		if (qlcnic_config_switch_port(adapter, &esw_cfg))
@@ -3571,6 +3575,7 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 						QLCNIC_NON_PRIV_FUNC) {
 				esw_cfg[i].mac_anti_spoof = 0;
 				esw_cfg[i].mac_override = 1;
+				esw_cfg[i].promisc_mode = 1;
 			}
 			break;
 		case QLCNIC_ADD_VLAN:
-- 
1.6.0.2

