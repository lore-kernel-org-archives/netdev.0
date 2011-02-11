From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 03/15] be2net: Use domain id when
 be_cmd_if_destroy is called.
Date: Fri, 11 Feb 2011 17:34:46 -0600
Message-ID: <20110211233445.GA18320@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51162 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757392Ab1BKXfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:35:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_cmds.c |    3 ++-
 drivers/net/benet/be_cmds.h |    3 ++-
 drivers/net/benet/be_main.c |    7 ++++---
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index d3b671d..be2981a 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -995,7 +995,7 @@ int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags, u32 en_flags,
 }
 
 /* Uses mbox */
-int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id)
+int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id, u32 domain)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_if_destroy *req;
@@ -1016,6 +1016,7 @@ int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id)
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_INTERFACE_DESTROY, sizeof(*req));
 
+	req->hdr.domain = domain;
 	req->interface_id = cpu_to_le32(interface_id);
 
 	status = be_mbox_notify_wait(adapter);
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 83d15c8..02540bd 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -1004,7 +1004,8 @@ extern int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id, u32 pmac_id);
 extern int be_cmd_if_create(struct be_adapter *adapter, u32 cap_flags,
 			u32 en_flags, u8 *mac, bool pmac_invalid,
 			u32 *if_handle, u32 *pmac_id, u32 domain);
-extern int be_cmd_if_destroy(struct be_adapter *adapter, u32 if_handle);
+extern int be_cmd_if_destroy(struct be_adapter *adapter, u32 if_handle,
+			u32 domain);
 extern int be_cmd_eq_create(struct be_adapter *adapter,
 			struct be_queue_info *eq, int eq_delay);
 extern int be_cmd_cq_create(struct be_adapter *adapter,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 4c73dce..aab464d 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2335,8 +2335,9 @@ if_destroy:
 	for (vf = 0; vf < num_vfs; vf++)
 		if (adapter->vf_cfg[vf].vf_if_handle)
 			be_cmd_if_destroy(adapter,
-					adapter->vf_cfg[vf].vf_if_handle);
-	be_cmd_if_destroy(adapter, adapter->if_handle);
+					adapter->vf_cfg[vf].vf_if_handle,
+					vf + 1);
+	be_cmd_if_destroy(adapter, adapter->if_handle, 0);
 do_none:
 	return status;
 }
@@ -2350,7 +2351,7 @@ static int be_clear(struct be_adapter *adapter)
 	be_rx_queues_destroy(adapter);
 	be_tx_queues_destroy(adapter);
 
-	be_cmd_if_destroy(adapter, adapter->if_handle);
+	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
 
 	/* tell fw we're done with firing cmds */
 	be_cmd_fw_clean(adapter);
-- 
1.7.1

