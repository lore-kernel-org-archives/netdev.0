From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v4 08/10] nfc: nci: fix possible crash in nci_core_conn_create
Date: Thu, 22 Oct 2015 12:11:40 +0300
Message-ID: <1445505102-16639-9-git-send-email-robert.dolca@intel.com>
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

If the number of destination speific parameters supplied is 0 the call
will fail. If the first destination specific parameter does not have a
value, curr_id will be set to 0.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 net/nfc/nci/core.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index f66a5da..9d5f7a2 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -602,12 +602,19 @@ int nci_core_conn_create(struct nci_dev *ndev, u8 destination_type,
 	if (!cmd)
 		return -ENOMEM;
 
+	if (!number_destination_params)
+		return -EINVAL;
+
 	cmd->destination_type = destination_type;
 	cmd->number_destination_params = number_destination_params;
 	memcpy(cmd->params, params, params_len);
 
 	data.cmd = cmd;
-	ndev->cur_id = params->value[DEST_SPEC_PARAMS_ID_INDEX];
+
+	if (params->length > 0)
+		ndev->cur_id = params->value[DEST_SPEC_PARAMS_ID_INDEX];
+	else
+		ndev->cur_id = 0;
 
 	r = __nci_request(ndev, nci_core_conn_create_req,
 			  (unsigned long)&data,
-- 
1.9.1
