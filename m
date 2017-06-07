From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 3/4] net: qrtr: Broadcast DEL_CLIENT message when endpoint is closed
Date: Wed,  7 Jun 2017 11:55:00 -0700
Message-ID: <20170607185501.6000-3-bjorn.andersson@linaro.org>
References: <20170607185501.6000-1-bjorn.andersson@linaro.org>
Cc: Arun Kumar Neelakantam <aneela@codeaurora.org>,
        netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        linux-kernel@vger.kernel.org, Courtney Cavin <ccavin@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607185501.6000-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Per the QMUXv2 protocol specificiation a DEL_CLIENT message should be
broadcasted when an endpoint is disconnected.

The protocol specification does suggest that the router can keep track
of which nodes the endpoint has been communicating with to not wake up
sleeping remotes unecessarily, but implementation of this suggestion is
left for the future.

Cc: Courtney Cavin <ccavin@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 net/qrtr/qrtr.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index e8cbab23d667..d7516098b5aa 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -112,6 +112,7 @@ struct qrtr_node {
 };
 
 static int qrtr_local_enqueue(struct qrtr_node *node, struct sk_buff *skb);
+static int qrtr_bcast_enqueue(struct qrtr_node *node, struct sk_buff *skb);
 
 /* Release node resources and free the node.
  *
@@ -312,6 +313,26 @@ static struct sk_buff *qrtr_alloc_local_bye(u32 src_node)
 	return skb;
 }
 
+static struct sk_buff *qrtr_alloc_del_client(struct sockaddr_qrtr *sq)
+{
+	const int pkt_len = 20;
+	struct sk_buff *skb;
+	__le32 *buf;
+
+	skb = qrtr_alloc_ctrl_packet(QRTR_TYPE_DEL_CLIENT, pkt_len,
+				     sq->sq_node, QRTR_NODE_BCAST);
+	if (!skb)
+		return NULL;
+
+	buf = (__le32 *)skb_put(skb, pkt_len);
+	memset(buf, 0, pkt_len);
+	buf[0] = cpu_to_le32(QRTR_TYPE_DEL_CLIENT);
+	buf[1] = cpu_to_le32(sq->sq_node);
+	buf[2] = cpu_to_le32(sq->sq_port);
+
+	return skb;
+}
+
 static struct qrtr_sock *qrtr_port_lookup(int port);
 static void qrtr_port_put(struct qrtr_sock *ipc);
 
@@ -448,8 +469,15 @@ static void qrtr_port_put(struct qrtr_sock *ipc)
 /* Remove port assignment. */
 static void qrtr_port_remove(struct qrtr_sock *ipc)
 {
+	struct sk_buff *skb;
 	int port = ipc->us.sq_port;
 
+	skb = qrtr_alloc_del_client(&ipc->us);
+	if (skb) {
+		skb_set_owner_w(skb, &ipc->sk);
+		qrtr_bcast_enqueue(NULL, skb);
+	}
+
 	if (port == QRTR_PORT_CTRL)
 		port = 0;
 
-- 
2.12.0
