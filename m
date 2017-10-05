From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [RESEND PATCH 6/7] net: qrtr: Use sk_buff->cb in receive path
Date: Wed,  4 Oct 2017 20:51:04 -0700
Message-ID: <20171005035105.14677-7-bjorn.andersson@linaro.org>
References: <20171005035105.14677-1-bjorn.andersson@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, Chris Lew <clew@codeaurora.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:51932 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751774AbdJEDvR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 23:51:17 -0400
Received: by mail-pf0-f169.google.com with SMTP id n14so5426522pfh.8
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 20:51:17 -0700 (PDT)
In-Reply-To: <20171005035105.14677-1-bjorn.andersson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than parsing the header of incoming messages throughout the
implementation do it once when we retrieve the message and store the
relevant information in the "cb" member of the sk_buff.

This allows us to, in a later commit, decode version 2 messages into
this same structure.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 net/qrtr/qrtr.c | 70 ++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 40 insertions(+), 30 deletions(-)

diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index a84edba7b1ef..7bca6ec892a5 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -48,6 +48,16 @@ struct qrtr_hdr {
 	__le32 dst_port_id;
 } __packed;
 
+struct qrtr_cb {
+	u32 src_node;
+	u32 src_port;
+	u32 dst_node;
+	u32 dst_port;
+
+	u8 type;
+	u8 confirm_rx;
+};
+
 #define QRTR_HDR_SIZE sizeof(struct qrtr_hdr)
 
 struct qrtr_sock {
@@ -216,6 +226,7 @@ int qrtr_endpoint_post(struct qrtr_endpoint *ep, const void *data, size_t len)
 	struct qrtr_node *node = ep->node;
 	const struct qrtr_hdr *phdr = data;
 	struct sk_buff *skb;
+	struct qrtr_cb *cb;
 	unsigned int psize;
 	unsigned int size;
 	unsigned int type;
@@ -245,8 +256,15 @@ int qrtr_endpoint_post(struct qrtr_endpoint *ep, const void *data, size_t len)
 	if (!skb)
 		return -ENOMEM;
 
-	skb_reset_transport_header(skb);
-	skb_put_data(skb, data, len);
+	cb = (struct qrtr_cb *)skb->cb;
+	cb->src_node = le32_to_cpu(phdr->src_node_id);
+	cb->src_port = le32_to_cpu(phdr->src_port_id);
+	cb->dst_node = le32_to_cpu(phdr->dst_node_id);
+	cb->dst_port = le32_to_cpu(phdr->dst_port_id);
+	cb->type = type;
+	cb->confirm_rx = !!phdr->confirm_rx;
+
+	skb_put_data(skb, data + QRTR_HDR_SIZE, size);
 
 	skb_queue_tail(&node->rx_queue, skb);
 	schedule_work(&node->work);
@@ -295,26 +313,20 @@ static void qrtr_node_rx_work(struct work_struct *work)
 	struct sk_buff *skb;
 
 	while ((skb = skb_dequeue(&node->rx_queue)) != NULL) {
-		const struct qrtr_hdr *phdr;
-		u32 dst_node, dst_port;
 		struct qrtr_sock *ipc;
-		u32 src_node;
+		struct qrtr_cb *cb;
 		int confirm;
 
-		phdr = (const struct qrtr_hdr *)skb_transport_header(skb);
-		src_node = le32_to_cpu(phdr->src_node_id);
-		dst_node = le32_to_cpu(phdr->dst_node_id);
-		dst_port = le32_to_cpu(phdr->dst_port_id);
-		confirm = !!phdr->confirm_rx;
+		cb = (struct qrtr_cb *)skb->cb;
+		src.sq_node = cb->src_node;
+		src.sq_port = cb->src_port;
+		dst.sq_node = cb->dst_node;
+		dst.sq_port = cb->dst_port;
+		confirm = !!cb->confirm_rx;
 
-		src.sq_node = src_node;
-		src.sq_port = le32_to_cpu(phdr->src_port_id);
-		dst.sq_node = dst_node;
-		dst.sq_port = dst_port;
+		qrtr_node_assign(node, cb->src_node);
 
-		qrtr_node_assign(node, src_node);
-
-		ipc = qrtr_port_lookup(dst_port);
+		ipc = qrtr_port_lookup(cb->dst_port);
 		if (!ipc) {
 			kfree_skb(skb);
 		} else {
@@ -604,7 +616,7 @@ static int qrtr_local_enqueue(struct qrtr_node *node, struct sk_buff *skb,
 			      struct sockaddr_qrtr *to)
 {
 	struct qrtr_sock *ipc;
-	struct qrtr_hdr *phdr;
+	struct qrtr_cb *cb;
 
 	ipc = qrtr_port_lookup(to->sq_port);
 	if (!ipc || &ipc->sk == skb->sk) { /* do not send to self */
@@ -612,11 +624,9 @@ static int qrtr_local_enqueue(struct qrtr_node *node, struct sk_buff *skb,
 		return -ENODEV;
 	}
 
-	phdr = skb_push(skb, QRTR_HDR_SIZE);
-	skb_reset_transport_header(skb);
-
-	phdr->src_node_id = cpu_to_le32(from->sq_node);
-	phdr->src_port_id = cpu_to_le32(from->sq_port);
+	cb = (struct qrtr_cb *)skb->cb;
+	cb->src_node = from->sq_node;
+	cb->src_port = from->sq_port;
 
 	if (sock_queue_rcv_skb(&ipc->sk, skb)) {
 		qrtr_port_put(ipc);
@@ -750,9 +760,9 @@ static int qrtr_recvmsg(struct socket *sock, struct msghdr *msg,
 			size_t size, int flags)
 {
 	DECLARE_SOCKADDR(struct sockaddr_qrtr *, addr, msg->msg_name);
-	const struct qrtr_hdr *phdr;
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
+	struct qrtr_cb *cb;
 	int copied, rc;
 
 	lock_sock(sk);
@@ -769,22 +779,22 @@ static int qrtr_recvmsg(struct socket *sock, struct msghdr *msg,
 		return rc;
 	}
 
-	phdr = (const struct qrtr_hdr *)skb_transport_header(skb);
-	copied = le32_to_cpu(phdr->size);
+	copied = skb->len;
 	if (copied > size) {
 		copied = size;
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	rc = skb_copy_datagram_msg(skb, QRTR_HDR_SIZE, msg, copied);
+	rc = skb_copy_datagram_msg(skb, 0, msg, copied);
 	if (rc < 0)
 		goto out;
 	rc = copied;
 
 	if (addr) {
+		cb = (struct qrtr_cb *)skb->cb;
 		addr->sq_family = AF_QIPCRTR;
-		addr->sq_node = le32_to_cpu(phdr->src_node_id);
-		addr->sq_port = le32_to_cpu(phdr->src_port_id);
+		addr->sq_node = cb->src_node;
+		addr->sq_port = cb->src_port;
 		msg->msg_namelen = sizeof(*addr);
 	}
 
@@ -877,7 +887,7 @@ static int qrtr_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	case TIOCINQ:
 		skb = skb_peek(&sk->sk_receive_queue);
 		if (skb)
-			len = skb->len - QRTR_HDR_SIZE;
+			len = skb->len;
 		rc = put_user(len, (int __user *)argp);
 		break;
 	case SIOCGIFADDR:
-- 
2.12.0
