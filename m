From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-next-2.6 PATCH] be2net:Patch to perform function reset at
	initialization
Date: Wed, 5 Aug 2009 17:09:32 +0530
Message-ID: <20090805113923.GA15874@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:59644 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S933543AbZHELjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 07:39:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a bug fix to avoid system going into a bad state when driver
is loaded in context of kdump kernel. The patch fixes the issue by performing
a soft reset of pci function at probe time.

Signed-off-by: sarveshwarb <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   21 +++++++++++++++++++++
 drivers/net/benet/be_cmds.h |    2 ++
 drivers/net/benet/be_main.c |    4 ++++
 3 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index de10773..2547ee2 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1019,3 +1019,24 @@ int be_cmd_query_fw_cfg(struct be_adapte
 	spin_unlock(&adapter->mbox_lock);
 	return status;
 }
+
+int be_cmd_reset_function(struct be_adapter *adapter)
+{
+	struct be_mcc_wrb *wrb = wrb_from_mbox(&adapter->mbox_mem);
+	struct be_cmd_req_hdr *req = embedded_payload(wrb);
+	int status;
+
+	spin_lock(&adapter->mbox_lock);
+
+	memset(wrb, 0, sizeof(*wrb));
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+
+	be_cmd_hdr_prepare(req, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_FUNCTION_RESET, sizeof(*req));
+
+	status = be_mbox_notify(adapter);
+
+	spin_unlock(&adapter->mbox_lock);
+	return status;
+}
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 5c5de35..7061806 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -135,6 +135,7 @@ #define OPCODE_COMMON_EQ_DESTROY        
 #define OPCODE_COMMON_QUERY_FIRMWARE_CONFIG		58
 #define OPCODE_COMMON_NTWK_PMAC_ADD			59
 #define OPCODE_COMMON_NTWK_PMAC_DEL			60
+#define OPCODE_COMMON_FUNCTION_RESET			61
 
 #define OPCODE_ETH_ACPI_CONFIG				2
 #define OPCODE_ETH_PROMISCUOUS				3
@@ -744,4 +745,5 @@ extern int be_cmd_set_flow_control(struc
 extern int be_cmd_get_flow_control(struct be_adapter *adapter,
 			u32 *tx_fc, u32 *rx_fc);
 extern int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num);
+extern int be_cmd_reset_function(struct be_adapter *adapter);
 extern void be_process_mcc(struct be_adapter *adapter);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index ef82a52..d20235b 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1873,6 +1873,10 @@ static int __devinit be_probe(struct pci
 	if (status)
 		goto free_netdev;
 
+	status = be_cmd_reset_function(adapter);
+	if (status)
+		goto ctrl_clean;
+
 	status = be_stats_init(adapter);
 	if (status)
 		goto ctrl_clean;
-- 
1.4.0

