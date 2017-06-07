From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [RESEND PATCH 1/4] net: qrtr: Refactor packet allocation
Date: Wed,  7 Jun 2017 14:07:36 -0700
Message-ID: <20170607210739.27263-2-bjorn.andersson@linaro.org>
References: <20170607210739.27263-1-bjorn.andersson@linaro.org>
Cc: Arun Kumar Neelakantam <aneela@codeaurora.org>,
        netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        linux-kernel@vger.kernel.org, Courtney Cavin <ccavin@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607210739.27263-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extract the allocation and filling in the control message header fields
to a separate function in order to reuse this in subsequent patches.

Cc: Courtney Cavin <ccavin@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 net/qrtr/qrtr.c | 25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index a9a8c7d5a4a9..86d35ed50da9 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -245,14 +245,11 @@ int qrtr_endpoint_post(struct qrtr_endpoint *ep, const void *data, size_t len)
 }
 EXPORT_SYMBOL_GPL(qrtr_endpoint_post);
 
-/* Allocate and construct a resume-tx packet. */
-static struct sk_buff *qrtr_alloc_resume_tx(u32 src_node,
-					    u32 dst_node, u32 port)
+static struct sk_buff *qrtr_alloc_ctrl_packet(u32 type, size_t pkt_len,
+					      u32 src_node, u32 dst_node)
 {
-	const int pkt_len = 20;
 	struct qrtr_hdr *hdr;
 	struct sk_buff *skb;
-	__le32 *buf;
 
 	skb = alloc_skb(QRTR_HDR_SIZE + pkt_len, GFP_KERNEL);
 	if (!skb)
@@ -261,7 +258,7 @@ static struct sk_buff *qrtr_alloc_resume_tx(u32 src_node,
 
 	hdr = (struct qrtr_hdr *)skb_put(skb, QRTR_HDR_SIZE);
 	hdr->version = cpu_to_le32(QRTR_PROTO_VER);
-	hdr->type = cpu_to_le32(QRTR_TYPE_RESUME_TX);
+	hdr->type = cpu_to_le32(type);
 	hdr->src_node_id = cpu_to_le32(src_node);
 	hdr->src_port_id = cpu_to_le32(QRTR_PORT_CTRL);
 	hdr->confirm_rx = cpu_to_le32(0);
@@ -269,6 +266,22 @@ static struct sk_buff *qrtr_alloc_resume_tx(u32 src_node,
 	hdr->dst_node_id = cpu_to_le32(dst_node);
 	hdr->dst_port_id = cpu_to_le32(QRTR_PORT_CTRL);
 
+	return skb;
+}
+
+/* Allocate and construct a resume-tx packet. */
+static struct sk_buff *qrtr_alloc_resume_tx(u32 src_node,
+					    u32 dst_node, u32 port)
+{
+	const int pkt_len = 20;
+	struct sk_buff *skb;
+	__le32 *buf;
+
+	skb = qrtr_alloc_ctrl_packet(QRTR_TYPE_RESUME_TX, pkt_len,
+				     src_node, dst_node);
+	if (!skb)
+		return NULL;
+
 	buf = (__le32 *)skb_put(skb, pkt_len);
 	memset(buf, 0, pkt_len);
 	buf[0] = cpu_to_le32(QRTR_TYPE_RESUME_TX);
-- 
2.12.0
