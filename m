From: <parav.pandit@emulex.com>
Subject: [RFC V1 1/2] be2net: Added function to issue mailbox cmd on MQ.
Date: Sun, 11 Mar 2012 16:19:29 +0530
Message-ID: <a0b67bb1-a460-49f1-81c2-8dc7c2a2d3b6@exht1.ad.emulex.com>
References: <1331462970-18690-1-git-send-email-parav.pandit@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parav.pandit@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:34479 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751084Ab2CKGkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 01:40:22 -0500
In-Reply-To: <1331462970-18690-1-git-send-email-parav.pandit@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parav Pandit <parav.pandit@emulex.com>

- Added generic function to issue mailbox cmd on MQ as export function.
- RoCE driver will use this before it setups its own MQ.

Signed-off-by: Parav Pandit <parav.pandit@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   39 +++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 0fcb456..19037b0 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -15,6 +15,7 @@
  * Costa Mesa, CA 92626
  */
 
+#include <linux/module.h>
 #include "be.h"
 #include "be_cmds.h"
 
@@ -2391,3 +2392,41 @@ err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
+
+int be_roce_mcc_cmd(void *netdev_handle, void *wrb_payload,
+			int wrb_payload_size, u16 *cmd_status, u16 *ext_status)
+{
+	struct be_adapter *adapter = netdev_priv(netdev_handle);
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_hdr *hdr = (struct be_cmd_req_hdr *) wrb_payload;
+	struct be_cmd_req_hdr *req;
+	struct be_cmd_resp_hdr *resp;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+	req = embedded_payload(wrb);
+	resp = embedded_payload(wrb);
+
+	be_wrb_cmd_hdr_prepare(req, hdr->subsystem,
+			       hdr->opcode, wrb_payload_size, wrb, NULL);
+	memcpy(req, wrb_payload, wrb_payload_size);
+	be_dws_cpu_to_le(req, wrb_payload_size);
+
+	status = be_mcc_notify_wait(adapter);
+	if (cmd_status)
+		*cmd_status = (status & 0xffff);
+	if (ext_status)
+		*ext_status = 0;
+	memcpy(wrb_payload, resp, sizeof(*resp) + resp->response_length);
+	be_dws_le_to_cpu(wrb_payload, sizeof(*resp) + resp->response_length);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+EXPORT_SYMBOL(be_roce_mcc_cmd);
-- 
1.6.0.2
