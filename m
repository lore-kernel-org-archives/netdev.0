From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH 7/8] NFC: NCI: Adds a way to get the new connection ID
Date: Tue, 24 Feb 2015 12:01:51 +0200
Message-ID: <1424772112-27399-8-git-send-email-robert.dolca@intel.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nci_core_conn_create not has a new parameter so it can return
the ID of the new connection. Also not you can't call nci_core_conn_create
without waiting the answer for the previous call.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 drivers/nfc/st21nfcb/st21nfcb_se.c |  2 +-
 include/net/nfc/nci_core.h         | 11 ++++++++---
 net/nfc/nci/core.c                 | 13 ++++++++++---
 net/nfc/nci/rsp.c                  |  6 ++++++
 4 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/nfc/st21nfcb/st21nfcb_se.c b/drivers/nfc/st21nfcb/st21nfcb_se.c
index 7c82e9d..8694675 100644
--- a/drivers/nfc/st21nfcb/st21nfcb_se.c
+++ b/drivers/nfc/st21nfcb/st21nfcb_se.c
@@ -515,7 +515,7 @@ static int st21nfcb_hci_network_init(struct nci_dev *ndev)
 	r = nci_core_conn_create(ndev, NCI_DESTINATION_NFCEE, 1,
 				 sizeof(struct core_conn_create_dest_spec_params) +
 				 sizeof(struct dest_spec_params),
-				 dest_params);
+				 dest_params, NULL);
 	if (r != NCI_STATUS_OK)
 		goto free_dest_params;
 
diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index d79f90e..a331755 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -240,6 +240,11 @@ struct nci_dev {
 	/* Save RF Discovery ID or NFCEE ID under conn_create */
 	__u8			cur_id;
 
+	/* Pointer to the address where the next connection ID
+	 * will be stored */
+	__u8			*next_conn_id;
+	__u8			conn_busy;
+
 	/* stored during nci_data_exchange */
 	struct sk_buff		*rx_data_reassembly;
 
@@ -266,9 +271,9 @@ int nci_set_config(struct nci_dev *ndev, __u8 id, size_t len, __u8 *val);
 int nci_nfcee_discover(struct nci_dev *ndev, u8 action);
 int nci_nfcee_mode_set(struct nci_dev *ndev, u8 nfcee_id, u8 nfcee_mode);
 int nci_core_conn_create(struct nci_dev *ndev, u8 destination_type,
-			 u8 number_destination_params,
-			 size_t params_len,
-			 struct core_conn_create_dest_spec_params *params);
+			 u8 number_destination_params, size_t params_len,
+			 struct core_conn_create_dest_spec_params *params,
+			 u8 *conn_id);
 int nci_core_conn_close(struct nci_dev *ndev, u8 conn_id);
 
 struct nci_hci_dev *nci_hci_allocate(struct nci_dev *ndev);
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index d2e7adf..aaa56f1 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -554,14 +554,19 @@ static void nci_core_conn_create_req(struct nci_dev *ndev, unsigned long opt)
 }
 
 int nci_core_conn_create(struct nci_dev *ndev, u8 destination_type,
-			 u8 number_destination_params,
-			 size_t params_len,
-			 struct core_conn_create_dest_spec_params *params)
+			 u8 number_destination_params, size_t params_len,
+			 struct core_conn_create_dest_spec_params *params,
+			 u8 *conn_id)
 {
 	int r;
 	struct nci_core_conn_create_cmd *cmd;
 	struct core_conn_create_data data;
 
+	if (ndev->conn_busy)
+		return -EBUSY;
+
+	ndev->conn_busy = 1;
+
 	data.length = params_len + sizeof(struct nci_core_conn_create_cmd);
 	cmd = kzalloc(data.length, GFP_KERNEL);
 	if (!cmd)
@@ -573,11 +578,13 @@ int nci_core_conn_create(struct nci_dev *ndev, u8 destination_type,
 
 	data.cmd = cmd;
 	ndev->cur_id = params->value[DEST_SPEC_PARAMS_ID_INDEX];
+	ndev->next_conn_id = conn_id;
 
 	r = __nci_request(ndev, nci_core_conn_create_req,
 			  (unsigned long)&data,
 			  msecs_to_jiffies(NCI_CMD_TIMEOUT));
 	kfree(cmd);
+	ndev->conn_busy = 0;
 	return r;
 }
 EXPORT_SYMBOL(nci_core_conn_create);
diff --git a/net/nfc/nci/rsp.c b/net/nfc/nci/rsp.c
index 02486bc..9aa9de2 100644
--- a/net/nfc/nci/rsp.c
+++ b/net/nfc/nci/rsp.c
@@ -244,6 +244,12 @@ static void nci_core_conn_create_rsp_packet(struct nci_dev *ndev,
 		conn_info->id = ndev->cur_id;
 		conn_info->conn_id = rsp->conn_id;
 
+		/* Set the conn ID to the address provided by the caller */
+		if (ndev->next_conn_id) {
+			*ndev->next_conn_id = rsp->conn_id;
+			ndev->next_conn_id = NULL;
+		}
+
 		/* Note: data_exchange_cb and data_exchange_cb_context need to
 		 * be specify out of nci_core_conn_create_rsp_packet
 		 */
-- 
1.9.1
