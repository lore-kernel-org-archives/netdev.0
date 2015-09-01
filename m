From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v2 4/9] nfc: nci: Allow the driver to set handler for core nci ops
Date: Tue,  1 Sep 2015 17:54:23 +0300
Message-ID: <1441119268-30654-5-git-send-email-robert.dolca@intel.com>
References: <1441119268-30654-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Christophe Ricard <christophe.ricard@gmail.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441119268-30654-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver may be required to act when some responses or notifications
arrive. For example the NCI core does not have a handler for
NCI_OP_CORE_GET_CONFIG_RSP. The NFCC can send a config response that has
to be read by the driver and the packet may contain vendor specific data.

The Fields Peak driver needs to take certain actions when a reset
notification arrives (packet also not handled by the nfc core).

The driver handlers do not interfere with the core and they are called
after the core processes the packet.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 include/net/nfc/nci_core.h | 13 +++++++++----
 net/nfc/nci/core.c         | 43 +++++++++++++++++++++++--------------------
 net/nfc/nci/ntf.c          |  6 +++++-
 net/nfc/nci/rsp.c          |  6 +++++-
 4 files changed, 42 insertions(+), 26 deletions(-)

diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index 8a4ab1e..30c1b21 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -96,6 +96,9 @@ struct nci_ops {
 
 	struct nci_prop_ops *prop_ops;
 	size_t n_prop_ops;
+
+	struct nci_prop_ops *core_ops;
+	size_t n_core_ops;
 };
 
 #define NCI_MAX_SUPPORTED_RF_INTERFACES		4
@@ -344,10 +347,12 @@ static inline int nci_set_vendor_cmds(struct nci_dev *ndev,
 
 void nci_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb);
 void nci_ntf_packet(struct nci_dev *ndev, struct sk_buff *skb);
-int nci_prop_rsp_packet(struct nci_dev *ndev, __u16 opcode,
-			struct sk_buff *skb);
-int nci_prop_ntf_packet(struct nci_dev *ndev, __u16 opcode,
-			struct sk_buff *skb);
+int nci_op_rsp_packet(struct nci_dev *ndev, __u16 rsp_opcode,
+		      struct sk_buff *skb, struct nci_prop_ops *ops,
+		      size_t n_ops);
+int nci_op_ntf_packet(struct nci_dev *ndev, __u16 ntf_opcode,
+		      struct sk_buff *skb, struct nci_prop_ops *ops,
+		      size_t n_ops);
 void nci_rx_data_packet(struct nci_dev *ndev, struct sk_buff *skb);
 int nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen, void *payload);
 int nci_send_data(struct nci_dev *ndev, __u8 conn_id, struct sk_buff *skb);
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 943889b..e2bd5f4 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -1228,46 +1228,49 @@ int nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen, void *payload)
 }
 
 /* Proprietary commands API */
-static struct nci_prop_ops *prop_cmd_lookup(struct nci_dev *ndev,
-					    __u16 opcode)
+static struct nci_prop_ops *ops_cmd_lookup(struct nci_prop_ops *ops,
+					   size_t n_ops,
+					   __u16 opcode)
 {
 	size_t i;
-	struct nci_prop_ops *prop_op;
+	struct nci_prop_ops *op;
 
-	if (!ndev->ops->prop_ops || !ndev->ops->n_prop_ops)
+	if (!ops || !n_ops)
 		return NULL;
 
-	for (i = 0; i < ndev->ops->n_prop_ops; i++) {
-		prop_op = &ndev->ops->prop_ops[i];
-		if (prop_op->opcode == opcode)
-			return prop_op;
+	for (i = 0; i < n_ops; i++) {
+		op = &ops[i];
+		if (op->opcode == opcode)
+			return op;
 	}
 
 	return NULL;
 }
 
-int nci_prop_rsp_packet(struct nci_dev *ndev, __u16 rsp_opcode,
-			struct sk_buff *skb)
+int nci_op_rsp_packet(struct nci_dev *ndev, __u16 rsp_opcode,
+		      struct sk_buff *skb, struct nci_prop_ops *ops,
+		      size_t n_ops)
 {
-	struct nci_prop_ops *prop_op;
+	struct nci_prop_ops *op;
 
-	prop_op = prop_cmd_lookup(ndev, rsp_opcode);
-	if (!prop_op || !prop_op->rsp)
+	op = ops_cmd_lookup(ops, n_ops, rsp_opcode);
+	if (!op || !op->rsp)
 		return -ENOTSUPP;
 
-	return prop_op->rsp(ndev, skb);
+	return op->rsp(ndev, skb);
 }
 
-int nci_prop_ntf_packet(struct nci_dev *ndev, __u16 ntf_opcode,
-			struct sk_buff *skb)
+int nci_op_ntf_packet(struct nci_dev *ndev, __u16 ntf_opcode,
+		      struct sk_buff *skb, struct nci_prop_ops *ops,
+		      size_t n_ops)
 {
-	struct nci_prop_ops *prop_op;
+	struct nci_prop_ops *op;
 
-	prop_op = prop_cmd_lookup(ndev, ntf_opcode);
-	if (!prop_op || !prop_op->ntf)
+	op = ops_cmd_lookup(ops, n_ops, ntf_opcode);
+	if (!op || !op->ntf)
 		return -ENOTSUPP;
 
-	return prop_op->ntf(ndev, skb);
+	return op->ntf(ndev, skb);
 }
 
 /* ---- NCI TX Data worker thread ---- */
diff --git a/net/nfc/nci/ntf.c b/net/nfc/nci/ntf.c
index 5d1c2e3..8f6ed35 100644
--- a/net/nfc/nci/ntf.c
+++ b/net/nfc/nci/ntf.c
@@ -759,7 +759,9 @@ void nci_ntf_packet(struct nci_dev *ndev, struct sk_buff *skb)
 	skb_pull(skb, NCI_CTRL_HDR_SIZE);
 
 	if (nci_opcode_gid(ntf_opcode) == NCI_GID_PROPRIETARY) {
-		if (nci_prop_ntf_packet(ndev, ntf_opcode, skb)) {
+		if (nci_op_ntf_packet(ndev, ntf_opcode, skb,
+				      ndev->ops->prop_ops,
+				      ndev->ops->n_prop_ops) == -ENOTSUPP) {
 			pr_err("unsupported ntf opcode 0x%x\n",
 			       ntf_opcode);
 		}
@@ -805,6 +807,8 @@ void nci_ntf_packet(struct nci_dev *ndev, struct sk_buff *skb)
 		break;
 	}
 
+	nci_op_ntf_packet(ndev, ntf_opcode, skb, ndev->ops->core_ops,
+			  ndev->ops->n_core_ops);
 end:
 	kfree_skb(skb);
 }
diff --git a/net/nfc/nci/rsp.c b/net/nfc/nci/rsp.c
index 408bd8f..0efab0b 100644
--- a/net/nfc/nci/rsp.c
+++ b/net/nfc/nci/rsp.c
@@ -297,7 +297,9 @@ void nci_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
 	skb_pull(skb, NCI_CTRL_HDR_SIZE);
 
 	if (nci_opcode_gid(rsp_opcode) == NCI_GID_PROPRIETARY) {
-		if (nci_prop_rsp_packet(ndev, rsp_opcode, skb) == -ENOTSUPP) {
+		if (nci_op_rsp_packet(ndev, rsp_opcode, skb,
+				      ndev->ops->prop_ops,
+				      ndev->ops->n_prop_ops) == -ENOTSUPP) {
 			pr_err("unsupported rsp opcode 0x%x\n",
 			       rsp_opcode);
 		}
@@ -355,6 +357,8 @@ void nci_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
 		break;
 	}
 
+	nci_op_rsp_packet(ndev, rsp_opcode, skb, ndev->ops->core_ops,
+			  ndev->ops->n_core_ops);
 end:
 	kfree_skb(skb);
 
-- 
1.9.1
