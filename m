From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [RESEND PATCH 4/7] net: qrtr: Pass source and destination to enqueue functions
Date: Wed,  4 Oct 2017 20:51:02 -0700
Message-ID: <20171005035105.14677-5-bjorn.andersson@linaro.org>
References: <20171005035105.14677-1-bjorn.andersson@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, Chris Lew <clew@codeaurora.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20171005035105.14677-1-bjorn.andersson@linaro.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Defer writing the message header to the skb until its time to enqueue
the packet. As the receive path is reworked to decode the message header
as it's received from the transport and only pass around the payload in
the skb this change means that we do not have to fill out the full
message header just to decode it immediately in qrtr_local_enqueue().

In the future this change also makes it possible to prepend message
headers based on the version of each link.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 net/qrtr/qrtr.c | 120 ++++++++++++++++++++++++++++++++------------------------
 1 file changed, 69 insertions(+), 51 deletions(-)

diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index d85ca7170b8f..82dc83789310 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -97,8 +97,12 @@ struct qrtr_node {
 	struct list_head item;
 };
 
-static int qrtr_local_enqueue(struct qrtr_node *node, struct sk_buff *skb);
-static int qrtr_bcast_enqueue(struct qrtr_node *node, struct sk_buff *skb);
+static int qrtr_local_enqueue(struct qrtr_node *node, struct sk_buff *skb,
+			      int type, struct sockaddr_qrtr *from,
+			      struct sockaddr_qrtr *to);
+static int qrtr_bcast_enqueue(struct qrtr_node *node, struct sk_buff *skb,
+			      int type, struct sockaddr_qrtr *from,
+			      struct sockaddr_qrtr *to);
 
 /* Release node resources and free the node.
  *
@@ -136,10 +140,27 @@ static void qrtr_node_release(struct qrtr_node *node)
 }
 
 /* Pass an outgoing packet socket buffer to the endpoint driver. */
-static int qrtr_node_enqueue(struct qrtr_node *node, struct sk_buff *skb)
+static int qrtr_node_enqueue(struct qrtr_node *node, struct sk_buff *skb,
+			     int type, struct sockaddr_qrtr *from,
+			     struct sockaddr_qrtr *to)
 {
+	struct qrtr_hdr *hdr;
+	size_t len = skb->len;
 	int rc = -ENODEV;
 
+	hdr = skb_push(skb, QRTR_HDR_SIZE);
+	hdr->version = cpu_to_le32(QRTR_PROTO_VER);
+	hdr->type = cpu_to_le32(type);
+	hdr->src_node_id = cpu_to_le32(from->sq_node);
+	hdr->src_port_id = cpu_to_le32(from->sq_port);
+	hdr->dst_node_id = cpu_to_le32(to->sq_node);
+	hdr->dst_port_id = cpu_to_le32(to->sq_port);
+
+	hdr->size = cpu_to_le32(len);
+	hdr->confirm_rx = 0;
+
+	skb_put_padto(skb, ALIGN(len, 4));
+
 	mutex_lock(&node->ep_lock);
 	if (node->ep)
 		rc = node->ep->xmit(node->ep, skb);
@@ -237,23 +258,13 @@ EXPORT_SYMBOL_GPL(qrtr_endpoint_post);
 static struct sk_buff *qrtr_alloc_ctrl_packet(u32 type, size_t pkt_len,
 					      u32 src_node, u32 dst_node)
 {
-	struct qrtr_hdr *hdr;
 	struct sk_buff *skb;
 
 	skb = alloc_skb(QRTR_HDR_SIZE + pkt_len, GFP_KERNEL);
 	if (!skb)
 		return NULL;
-	skb_reset_transport_header(skb);
 
-	hdr = skb_put(skb, QRTR_HDR_SIZE);
-	hdr->version = cpu_to_le32(QRTR_PROTO_VER);
-	hdr->type = cpu_to_le32(type);
-	hdr->src_node_id = cpu_to_le32(src_node);
-	hdr->src_port_id = cpu_to_le32(QRTR_PORT_CTRL);
-	hdr->confirm_rx = cpu_to_le32(0);
-	hdr->size = cpu_to_le32(pkt_len);
-	hdr->dst_node_id = cpu_to_le32(dst_node);
-	hdr->dst_port_id = cpu_to_le32(QRTR_PORT_CTRL);
+	skb_reserve(skb, QRTR_HDR_SIZE);
 
 	return skb;
 }
@@ -326,6 +337,8 @@ static void qrtr_port_put(struct qrtr_sock *ipc);
 static void qrtr_node_rx_work(struct work_struct *work)
 {
 	struct qrtr_node *node = container_of(work, struct qrtr_node, work);
+	struct sockaddr_qrtr dst;
+	struct sockaddr_qrtr src;
 	struct sk_buff *skb;
 
 	while ((skb = skb_dequeue(&node->rx_queue)) != NULL) {
@@ -341,6 +354,11 @@ static void qrtr_node_rx_work(struct work_struct *work)
 		dst_port = le32_to_cpu(phdr->dst_port_id);
 		confirm = !!phdr->confirm_rx;
 
+		src.sq_node = src_node;
+		src.sq_port = le32_to_cpu(phdr->src_port_id);
+		dst.sq_node = dst_node;
+		dst.sq_port = dst_port;
+
 		qrtr_node_assign(node, src_node);
 
 		ipc = qrtr_port_lookup(dst_port);
@@ -357,7 +375,9 @@ static void qrtr_node_rx_work(struct work_struct *work)
 			skb = qrtr_alloc_resume_tx(dst_node, node->nid, dst_port);
 			if (!skb)
 				break;
-			if (qrtr_node_enqueue(node, skb))
+
+			if (qrtr_node_enqueue(node, skb, QRTR_TYPE_RESUME_TX,
+					      &dst, &src))
 				break;
 		}
 	}
@@ -407,6 +427,8 @@ EXPORT_SYMBOL_GPL(qrtr_endpoint_register);
 void qrtr_endpoint_unregister(struct qrtr_endpoint *ep)
 {
 	struct qrtr_node *node = ep->node;
+	struct sockaddr_qrtr src = {AF_QIPCRTR, node->nid, QRTR_PORT_CTRL};
+	struct sockaddr_qrtr dst = {AF_QIPCRTR, qrtr_local_nid, QRTR_PORT_CTRL};
 	struct sk_buff *skb;
 
 	mutex_lock(&node->ep_lock);
@@ -416,7 +438,7 @@ void qrtr_endpoint_unregister(struct qrtr_endpoint *ep)
 	/* Notify the local controller about the event */
 	skb = qrtr_alloc_local_bye(node->nid);
 	if (skb)
-		qrtr_local_enqueue(NULL, skb);
+		qrtr_local_enqueue(NULL, skb, QRTR_TYPE_BYE, &src, &dst);
 
 	qrtr_node_release(node);
 	ep->node = NULL;
@@ -454,11 +476,17 @@ static void qrtr_port_remove(struct qrtr_sock *ipc)
 {
 	struct sk_buff *skb;
 	int port = ipc->us.sq_port;
+	struct sockaddr_qrtr to;
+
+	to.sq_family = AF_QIPCRTR;
+	to.sq_node = QRTR_NODE_BCAST;
+	to.sq_port = QRTR_PORT_CTRL;
 
 	skb = qrtr_alloc_del_client(&ipc->us);
 	if (skb) {
 		skb_set_owner_w(skb, &ipc->sk);
-		qrtr_bcast_enqueue(NULL, skb);
+		qrtr_bcast_enqueue(NULL, skb, QRTR_TYPE_DEL_CLIENT, &ipc->us,
+				   &to);
 	}
 
 	if (port == QRTR_PORT_CTRL)
@@ -606,19 +634,25 @@ static int qrtr_bind(struct socket *sock, struct sockaddr *saddr, int len)
 }
 
 /* Queue packet to local peer socket. */
-static int qrtr_local_enqueue(struct qrtr_node *node, struct sk_buff *skb)
+static int qrtr_local_enqueue(struct qrtr_node *node, struct sk_buff *skb,
+			      int type, struct sockaddr_qrtr *from,
+			      struct sockaddr_qrtr *to)
 {
-	const struct qrtr_hdr *phdr;
 	struct qrtr_sock *ipc;
+	struct qrtr_hdr *phdr;
 
-	phdr = (const struct qrtr_hdr *)skb_transport_header(skb);
-
-	ipc = qrtr_port_lookup(le32_to_cpu(phdr->dst_port_id));
+	ipc = qrtr_port_lookup(to->sq_port);
 	if (!ipc || &ipc->sk == skb->sk) { /* do not send to self */
 		kfree_skb(skb);
 		return -ENODEV;
 	}
 
+	phdr = skb_push(skb, QRTR_HDR_SIZE);
+	skb_reset_transport_header(skb);
+
+	phdr->src_node_id = cpu_to_le32(from->sq_node);
+	phdr->src_port_id = cpu_to_le32(from->sq_port);
+
 	if (sock_queue_rcv_skb(&ipc->sk, skb)) {
 		qrtr_port_put(ipc);
 		kfree_skb(skb);
@@ -631,7 +665,9 @@ static int qrtr_local_enqueue(struct qrtr_node *node, struct sk_buff *skb)
 }
 
 /* Queue packet for broadcast. */
-static int qrtr_bcast_enqueue(struct qrtr_node *node, struct sk_buff *skb)
+static int qrtr_bcast_enqueue(struct qrtr_node *node, struct sk_buff *skb,
+			      int type, struct sockaddr_qrtr *from,
+			      struct sockaddr_qrtr *to)
 {
 	struct sk_buff *skbn;
 
@@ -641,11 +677,11 @@ static int qrtr_bcast_enqueue(struct qrtr_node *node, struct sk_buff *skb)
 		if (!skbn)
 			break;
 		skb_set_owner_w(skbn, skb->sk);
-		qrtr_node_enqueue(node, skbn);
+		qrtr_node_enqueue(node, skbn, type, from, to);
 	}
 	mutex_unlock(&qrtr_node_lock);
 
-	qrtr_local_enqueue(node, skb);
+	qrtr_local_enqueue(node, skb, type, from, to);
 
 	return 0;
 }
@@ -653,13 +689,14 @@ static int qrtr_bcast_enqueue(struct qrtr_node *node, struct sk_buff *skb)
 static int qrtr_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	DECLARE_SOCKADDR(struct sockaddr_qrtr *, addr, msg->msg_name);
-	int (*enqueue_fn)(struct qrtr_node *, struct sk_buff *);
+	int (*enqueue_fn)(struct qrtr_node *, struct sk_buff *, int,
+			  struct sockaddr_qrtr *, struct sockaddr_qrtr *);
 	struct qrtr_sock *ipc = qrtr_sk(sock->sk);
 	struct sock *sk = sock->sk;
 	struct qrtr_node *node;
-	struct qrtr_hdr *hdr;
 	struct sk_buff *skb;
 	size_t plen;
+	u32 type = QRTR_TYPE_DATA;
 	int rc;
 
 	if (msg->msg_flags & ~(MSG_DONTWAIT))
@@ -713,32 +750,14 @@ static int qrtr_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	if (!skb)
 		goto out_node;
 
-	skb_reset_transport_header(skb);
-	skb_put(skb, len + QRTR_HDR_SIZE);
-
-	hdr = (struct qrtr_hdr *)skb_transport_header(skb);
-	hdr->version = cpu_to_le32(QRTR_PROTO_VER);
-	hdr->src_node_id = cpu_to_le32(ipc->us.sq_node);
-	hdr->src_port_id = cpu_to_le32(ipc->us.sq_port);
-	hdr->confirm_rx = cpu_to_le32(0);
-	hdr->size = cpu_to_le32(len);
-	hdr->dst_node_id = cpu_to_le32(addr->sq_node);
-	hdr->dst_port_id = cpu_to_le32(addr->sq_port);
+	skb_reserve(skb, QRTR_HDR_SIZE);
 
-	rc = skb_copy_datagram_from_iter(skb, QRTR_HDR_SIZE,
-					 &msg->msg_iter, len);
+	rc = memcpy_from_msg(skb_put(skb, len), msg, len);
 	if (rc) {
 		kfree_skb(skb);
 		goto out_node;
 	}
 
-	if (plen != len) {
-		rc = skb_pad(skb, plen - len);
-		if (rc)
-			goto out_node;
-		skb_put(skb, plen - len);
-	}
-
 	if (ipc->us.sq_port == QRTR_PORT_CTRL) {
 		if (len < 4) {
 			rc = -EINVAL;
@@ -747,12 +766,11 @@ static int qrtr_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 		}
 
 		/* control messages already require the type as 'command' */
-		skb_copy_bits(skb, QRTR_HDR_SIZE, &hdr->type, 4);
-	} else {
-		hdr->type = cpu_to_le32(QRTR_TYPE_DATA);
+		skb_copy_bits(skb, 0, &type, 4);
+		type = le32_to_cpu(type);
 	}
 
-	rc = enqueue_fn(node, skb);
+	rc = enqueue_fn(node, skb, type, &ipc->us, addr);
 	if (rc >= 0)
 		rc = len;
 
-- 
2.12.0
