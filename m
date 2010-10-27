From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 1/1] netxen: fix kdump
Date: Wed, 27 Oct 2010 01:51:50 -0700
Message-ID: <1288169510-4655-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:15567 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754774Ab0J0Ivv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 04:51:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

Reset the whole hw instead of freeing hw resources
consumed by each pci function.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_ctx.c  |   15 ---------------
 drivers/net/netxen/netxen_nic_main.c |    7 +++++++
 2 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 1261212..f7d06cb 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -255,19 +255,6 @@ out_free_rq:
 }
 
 static void
-nx_fw_cmd_reset_ctx(struct netxen_adapter *adapter)
-{
-
-	netxen_issue_cmd(adapter, adapter->ahw.pci_func, NXHAL_VERSION,
-			adapter->ahw.pci_func, NX_DESTROY_CTX_RESET, 0,
-			NX_CDRP_CMD_DESTROY_RX_CTX);
-
-	netxen_issue_cmd(adapter, adapter->ahw.pci_func, NXHAL_VERSION,
-			adapter->ahw.pci_func, NX_DESTROY_CTX_RESET, 0,
-			NX_CDRP_CMD_DESTROY_TX_CTX);
-}
-
-static void
 nx_fw_cmd_destroy_rx_ctx(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
@@ -698,8 +685,6 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	if (!NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 		if (test_and_set_bit(__NX_FW_ATTACHED, &adapter->state))
 			goto done;
-		if (reset_devices)
-			nx_fw_cmd_reset_ctx(adapter);
 		err = nx_fw_cmd_create_rx_ctx(adapter);
 		if (err)
 			goto err_out_free;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 50820be..35ae1aa 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1356,6 +1356,13 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		break;
 	}
 
+	if (reset_devices) {
+		if (adapter->portnum == 0) {
+			NXWR32(adapter, NX_CRB_DEV_REF_COUNT, 0);
+			adapter->need_fw_reset = 1;
+		}
+	}
+
 	err = netxen_start_firmware(adapter);
 	if (err)
 		goto err_out_decr_ref;
-- 
1.6.0.2

