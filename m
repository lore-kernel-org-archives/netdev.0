From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/18] netfilter: nfnetlink_queue: add skb info attribute
Date: Mon, 29 Apr 2013 20:22:22 +0200
Message-ID: <1367259744-8922-17-git-send-email-pablo@netfilter.org>
References: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Once we allow userspace to receive gso/gro packets, userspace
needs to be able to determine when checksums appear to be
broken, but are not.

NFQA_SKB_CSUMNOTREADY means 'checksums will be fixed in kernel
later, pretend they are ok'.

NFQA_SKB_GSO could be used for statistics, or to determine when
packet size exceeds mtu.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nfnetlink_queue.h |    7 +++++++
 net/netfilter/nfnetlink_queue_core.c           |   16 ++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/uapi/linux/netfilter/nfnetlink_queue.h b/include/uapi/linux/netfilter/nfnetlink_queue.h
index 70ec8c2..0069da3 100644
--- a/include/uapi/linux/netfilter/nfnetlink_queue.h
+++ b/include/uapi/linux/netfilter/nfnetlink_queue.h
@@ -45,6 +45,7 @@ enum nfqnl_attr_type {
 	NFQA_CT,			/* nf_conntrack_netlink.h */
 	NFQA_CT_INFO,			/* enum ip_conntrack_info */
 	NFQA_CAP_LEN,			/* __u32 length of captured packet */
+	NFQA_SKB_INFO,			/* __u32 skb meta information */
 
 	__NFQA_MAX
 };
@@ -98,4 +99,10 @@ enum nfqnl_attr_config {
 #define NFQA_CFG_F_CONNTRACK			(1 << 1)
 #define NFQA_CFG_F_MAX				(1 << 2)
 
+/* flags for NFQA_SKB_INFO */
+/* packet appears to have wrong checksums, but they are ok */
+#define NFQA_SKB_CSUMNOTREADY (1 << 0)
+/* packet is GSO (i.e., exceeds device mtu) */
+#define NFQA_SKB_GSO (1 << 1)
+
 #endif /* _NFNETLINK_QUEUE_H */
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index edbae4c..d052cd6 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -272,6 +272,18 @@ nfqnl_zcopy(struct sk_buff *to, const struct sk_buff *from, int len, int hlen)
 	skb_shinfo(to)->nr_frags = j;
 }
 
+static int nfqnl_put_packet_info(struct sk_buff *nlskb, struct sk_buff *packet)
+{
+	__u32 flags = 0;
+
+	if (packet->ip_summed == CHECKSUM_PARTIAL)
+		flags = NFQA_SKB_CSUMNOTREADY;
+	if (skb_is_gso(packet))
+		flags |= NFQA_SKB_GSO;
+
+	return flags ? nla_put_be32(nlskb, NFQA_SKB_INFO, htonl(flags)) : 0;
+}
+
 static struct sk_buff *
 nfqnl_build_packet_message(struct nfqnl_instance *queue,
 			   struct nf_queue_entry *entry,
@@ -301,6 +313,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 #endif
 		+ nla_total_size(sizeof(u_int32_t))	/* mark */
 		+ nla_total_size(sizeof(struct nfqnl_msg_packet_hw))
+		+ nla_total_size(sizeof(u_int32_t))	/* skbinfo */
 		+ nla_total_size(sizeof(u_int32_t));	/* cap_len */
 
 	if (entskb->tstamp.tv64)
@@ -454,6 +467,9 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	if (cap_len > 0 && nla_put_be32(skb, NFQA_CAP_LEN, htonl(cap_len)))
 		goto nla_put_failure;
 
+	if (nfqnl_put_packet_info(skb, entskb))
+		goto nla_put_failure;
+
 	if (data_len) {
 		struct nlattr *nla;
 
-- 
1.7.10.4

