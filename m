From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v2 6/9] nfc: nci: Introduce nci_core_cmd
Date: Tue,  1 Sep 2015 17:54:25 +0300
Message-ID: <1441119268-30654-7-git-send-email-robert.dolca@intel.com>
References: <1441119268-30654-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Christophe Ricard <christophe.ricard@gmail.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:28681 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755117AbbIAOzT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 10:55:19 -0400
In-Reply-To: <1441119268-30654-1-git-send-email-robert.dolca@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows sending core commands from the driver. The driver should be
able to send NCI core commands like CORE_GET_CONFIG_CMD.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 include/net/nfc/nci_core.h |  1 +
 net/nfc/nci/core.c         | 24 +++++++++++++++++++-----
 2 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index 30c1b21..d28b7a3 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -281,6 +281,7 @@ int nci_request(struct nci_dev *ndev,
 			    unsigned long opt),
 		unsigned long opt, __u32 timeout);
 int nci_prop_cmd(struct nci_dev *ndev, __u8 oid, size_t len, __u8 *payload);
+int nci_core_cmd(struct nci_dev *ndev, __u16 opcode, size_t len, __u8 *payload);
 int nci_core_reset(struct nci_dev *ndev);
 int nci_core_init(struct nci_dev *ndev);
 
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 29607f9..6f173cd 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -325,32 +325,46 @@ static void nci_rf_deactivate_req(struct nci_dev *ndev, unsigned long opt)
 		     sizeof(struct nci_rf_deactivate_cmd), &cmd);
 }
 
-struct nci_prop_cmd_param {
+struct nci_cmd_param {
 	__u16 opcode;
 	size_t len;
 	__u8 *payload;
 };
 
-static void nci_prop_cmd_req(struct nci_dev *ndev, unsigned long opt)
+static void nci_generic_req(struct nci_dev *ndev, unsigned long opt)
 {
-	struct nci_prop_cmd_param *param = (struct nci_prop_cmd_param *)opt;
+	struct nci_cmd_param *param =
+		(struct nci_cmd_param *)opt;
 
 	nci_send_cmd(ndev, param->opcode, param->len, param->payload);
 }
 
 int nci_prop_cmd(struct nci_dev *ndev, __u8 oid, size_t len, __u8 *payload)
 {
-	struct nci_prop_cmd_param param;
+	struct nci_cmd_param param;
 
 	param.opcode = nci_opcode_pack(NCI_GID_PROPRIETARY, oid);
 	param.len = len;
 	param.payload = payload;
 
-	return __nci_request(ndev, nci_prop_cmd_req, (unsigned long)&param,
+	return __nci_request(ndev, nci_generic_req, (unsigned long)&param,
 			     msecs_to_jiffies(NCI_CMD_TIMEOUT));
 }
 EXPORT_SYMBOL(nci_prop_cmd);
 
+int nci_core_cmd(struct nci_dev *ndev, __u16 opcode, size_t len, __u8 *payload)
+{
+	struct nci_cmd_param param;
+
+	param.opcode = opcode;
+	param.len = len;
+	param.payload = payload;
+
+	return __nci_request(ndev, nci_generic_req, (unsigned long)&param,
+			     msecs_to_jiffies(NCI_CMD_TIMEOUT));
+}
+EXPORT_SYMBOL(nci_core_cmd);
+
 int nci_core_reset(struct nci_dev *ndev)
 {
 	return __nci_request(ndev, nci_reset_req, 0,
-- 
1.9.1
