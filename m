From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/1] netxen: fix for kdump
Date: Tue, 13 Jul 2010 04:33:42 -0700
Message-ID: <1279020822-10419-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:58998 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751642Ab0GMLdn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jul 2010 07:33:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

When the crash kernel is loaded after crash, the device is in unknown state.
So reset the device contexts prior to its creation in case of kdump,
depending upon kernel parameter reset_devices.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/netxen/netxen_nic_ctx.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 3a41b6a..1261212 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -255,6 +255,19 @@ out_free_rq:
 }
 
 static void
+nx_fw_cmd_reset_ctx(struct netxen_adapter *adapter)
+{
+
+	netxen_issue_cmd(adapter, adapter->ahw.pci_func, NXHAL_VERSION,
+			adapter->ahw.pci_func, NX_DESTROY_CTX_RESET, 0,
+			NX_CDRP_CMD_DESTROY_RX_CTX);
+
+	netxen_issue_cmd(adapter, adapter->ahw.pci_func, NXHAL_VERSION,
+			adapter->ahw.pci_func, NX_DESTROY_CTX_RESET, 0,
+			NX_CDRP_CMD_DESTROY_TX_CTX);
+}
+
+static void
 nx_fw_cmd_destroy_rx_ctx(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
@@ -685,7 +698,8 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	if (!NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 		if (test_and_set_bit(__NX_FW_ATTACHED, &adapter->state))
 			goto done;
-
+		if (reset_devices)
+			nx_fw_cmd_reset_ctx(adapter);
 		err = nx_fw_cmd_create_rx_ctx(adapter);
 		if (err)
 			goto err_out_free;
-- 
1.6.0.2

