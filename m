From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [RESEND PATCH 5/7] net: qrtr: Clean up control packet handling
Date: Wed,  4 Oct 2017 20:51:03 -0700
Message-ID: <20171005035105.14677-6-bjorn.andersson@linaro.org>
References: <20171005035105.14677-1-bjorn.andersson@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, Chris Lew <clew@codeaurora.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005035105.14677-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As the message header generation is deferred the internal functions for
generating control packets can be simplified.

This patch modifies qrtr_alloc_ctrl_packet() to, in addition to the
sk_buff, return a reference to a struct qrtr_ctrl_pkt, which clarifies
and simplifies the helpers to the point that these functions can be
folded back into the callers.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 net/qrtr/qrtr.c | 93 ++++++++++++++++++---------------------------------------
 1 file changed, 29 insertions(+), 64 deletions(-)

diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index 82dc83789310..a84edba7b1ef 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -255,9 +255,18 @@ int qrtr_endpoint_post(struct qrtr_endpoint *ep, const void *data, size_t len)
 }
 EXPORT_SYMBOL_GPL(qrtr_endpoint_post);
 
-static struct sk_buff *qrtr_alloc_ctrl_packet(u32 type, size_t pkt_len,
-					      u32 src_node, u32 dst_node)
+/**
+ * qrtr_alloc_ctrl_packet() - allocate control packet skb
+ * @pkt: reference to qrtr_ctrl_pkt pointer
+ *
+ * Returns newly allocated sk_buff, or NULL on failure
+ *
+ * This function allocates a sk_buff large enough to carry a qrtr_ctrl_pkt and
+ * on success returns a reference to the control packet in @pkt.
+ */
+static struct sk_buff *qrtr_alloc_ctrl_packet(struct qrtr_ctrl_pkt **pkt)
 {
+	const int pkt_len = sizeof(struct qrtr_ctrl_pkt);
 	struct sk_buff *skb;
 
 	skb = alloc_skb(QRTR_HDR_SIZE + pkt_len, GFP_KERNEL);
@@ -265,64 +274,7 @@ static struct sk_buff *qrtr_alloc_ctrl_packet(u32 type, size_t pkt_len,
 		return NULL;
 
 	skb_reserve(skb, QRTR_HDR_SIZE);
-
-	return skb;
-}
-
-/* Allocate and construct a resume-tx packet. */
-static struct sk_buff *qrtr_alloc_resume_tx(u32 src_node,
-					    u32 dst_node, u32 port)
-{
-	const int pkt_len = 20;
-	struct sk_buff *skb;
-	__le32 *buf;
-
-	skb = qrtr_alloc_ctrl_packet(QRTR_TYPE_RESUME_TX, pkt_len,
-				     src_node, dst_node);
-	if (!skb)
-		return NULL;
-
-	buf = skb_put_zero(skb, pkt_len);
-	buf[0] = cpu_to_le32(QRTR_TYPE_RESUME_TX);
-	buf[1] = cpu_to_le32(src_node);
-	buf[2] = cpu_to_le32(port);
-
-	return skb;
-}
-
-/* Allocate and construct a BYE message to signal remote termination */
-static struct sk_buff *qrtr_alloc_local_bye(u32 src_node)
-{
-	const int pkt_len = 20;
-	struct sk_buff *skb;
-	__le32 *buf;
-
-	skb = qrtr_alloc_ctrl_packet(QRTR_TYPE_BYE, pkt_len,
-				     src_node, qrtr_local_nid);
-	if (!skb)
-		return NULL;
-
-	buf = skb_put_zero(skb, pkt_len);
-	buf[0] = cpu_to_le32(QRTR_TYPE_BYE);
-
-	return skb;
-}
-
-static struct sk_buff *qrtr_alloc_del_client(struct sockaddr_qrtr *sq)
-{
-	const int pkt_len = 20;
-	struct sk_buff *skb;
-	__le32 *buf;
-
-	skb = qrtr_alloc_ctrl_packet(QRTR_TYPE_DEL_CLIENT, pkt_len,
-				     sq->sq_node, QRTR_NODE_BCAST);
-	if (!skb)
-		return NULL;
-
-	buf = skb_put_zero(skb, pkt_len);
-	buf[0] = cpu_to_le32(QRTR_TYPE_DEL_CLIENT);
-	buf[1] = cpu_to_le32(sq->sq_node);
-	buf[2] = cpu_to_le32(sq->sq_port);
+	*pkt = skb_put_zero(skb, pkt_len);
 
 	return skb;
 }
@@ -337,6 +289,7 @@ static void qrtr_port_put(struct qrtr_sock *ipc);
 static void qrtr_node_rx_work(struct work_struct *work)
 {
 	struct qrtr_node *node = container_of(work, struct qrtr_node, work);
+	struct qrtr_ctrl_pkt *pkt;
 	struct sockaddr_qrtr dst;
 	struct sockaddr_qrtr src;
 	struct sk_buff *skb;
@@ -372,10 +325,14 @@ static void qrtr_node_rx_work(struct work_struct *work)
 		}
 
 		if (confirm) {
-			skb = qrtr_alloc_resume_tx(dst_node, node->nid, dst_port);
+			skb = qrtr_alloc_ctrl_packet(&pkt);
 			if (!skb)
 				break;
 
+			pkt->cmd = cpu_to_le32(QRTR_TYPE_RESUME_TX);
+			pkt->client.node = cpu_to_le32(dst.sq_node);
+			pkt->client.port = cpu_to_le32(dst.sq_port);
+
 			if (qrtr_node_enqueue(node, skb, QRTR_TYPE_RESUME_TX,
 					      &dst, &src))
 				break;
@@ -429,6 +386,7 @@ void qrtr_endpoint_unregister(struct qrtr_endpoint *ep)
 	struct qrtr_node *node = ep->node;
 	struct sockaddr_qrtr src = {AF_QIPCRTR, node->nid, QRTR_PORT_CTRL};
 	struct sockaddr_qrtr dst = {AF_QIPCRTR, qrtr_local_nid, QRTR_PORT_CTRL};
+	struct qrtr_ctrl_pkt *pkt;
 	struct sk_buff *skb;
 
 	mutex_lock(&node->ep_lock);
@@ -436,9 +394,11 @@ void qrtr_endpoint_unregister(struct qrtr_endpoint *ep)
 	mutex_unlock(&node->ep_lock);
 
 	/* Notify the local controller about the event */
-	skb = qrtr_alloc_local_bye(node->nid);
-	if (skb)
+	skb = qrtr_alloc_ctrl_packet(&pkt);
+	if (skb) {
+		pkt->cmd = cpu_to_le32(QRTR_TYPE_BYE);
 		qrtr_local_enqueue(NULL, skb, QRTR_TYPE_BYE, &src, &dst);
+	}
 
 	qrtr_node_release(node);
 	ep->node = NULL;
@@ -474,6 +434,7 @@ static void qrtr_port_put(struct qrtr_sock *ipc)
 /* Remove port assignment. */
 static void qrtr_port_remove(struct qrtr_sock *ipc)
 {
+	struct qrtr_ctrl_pkt *pkt;
 	struct sk_buff *skb;
 	int port = ipc->us.sq_port;
 	struct sockaddr_qrtr to;
@@ -482,8 +443,12 @@ static void qrtr_port_remove(struct qrtr_sock *ipc)
 	to.sq_node = QRTR_NODE_BCAST;
 	to.sq_port = QRTR_PORT_CTRL;
 
-	skb = qrtr_alloc_del_client(&ipc->us);
+	skb = qrtr_alloc_ctrl_packet(&pkt);
 	if (skb) {
+		pkt->cmd = cpu_to_le32(QRTR_TYPE_DEL_CLIENT);
+		pkt->client.node = cpu_to_le32(ipc->us.sq_node);
+		pkt->client.port = cpu_to_le32(ipc->us.sq_port);
+
 		skb_set_owner_w(skb, &ipc->sk);
 		qrtr_bcast_enqueue(NULL, skb, QRTR_TYPE_DEL_CLIENT, &ipc->us,
 				   &to);
-- 
2.12.0
