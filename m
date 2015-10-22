From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v4 05/10] nfc: nci: Introduce nci_core_cmd
Date: Thu, 22 Oct 2015 12:11:37 +0300
Message-ID: <1445505102-16639-6-git-send-email-robert.dolca@intel.com>
References: <1445505102-16639-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Christophe Ricard <christophe.ricard@gmail.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Robert Dolca <robert.dolca@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445505102-16639-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This allows sending core commands from the driver. The driver should be
able to send NCI core commands like CORE_GET_CONFIG_CMD.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 include/net/nfc/nci_core.h |  1 +
 net/nfc/nci/core.c         | 24 +++++++++++++++++++-----
 2 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index aaada20..4ca1b6d 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -278,6 +278,7 @@ int nci_request(struct nci_dev *ndev,
 			    unsigned long opt),
 		unsigned long opt, __u32 timeout);
 int nci_prop_cmd(struct nci_dev *ndev, __u8 oid, size_t len, __u8 *payload);
+int nci_core_cmd(struct nci_dev *ndev, __u16 opcode, size_t len, __u8 *payload);
 int nci_core_reset(struct nci_dev *ndev);
 int nci_core_init(struct nci_dev *ndev);
 
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 5362d8f..5b4f48a 100644
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
