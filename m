From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/12] netfilter: nfnetlink_queue: add security context information
Date: Fri, 19 Jun 2015 19:17:38 +0200
Message-ID: <1434734269-4545-2-git-send-email-pablo@netfilter.org>
References: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roman Kubiak <r.kubiak@samsung.com>

This patch adds an additional attribute when sending
packet information via netlink in netfilter_queue module.
It will send additional security context data, so that
userspace applications can verify this context against
their own security databases.

Signed-off-by: Roman Kubiak <r.kubiak@samsung.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nfnetlink_queue.h |    4 ++-
 net/netfilter/nfnetlink_queue_core.c           |   35 +++++++++++++++++++++++-
 2 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter/nfnetlink_queue.h b/include/uapi/linux/netfilter/nfnetlink_queue.h
index 8dd819e..b67a853 100644
--- a/include/uapi/linux/netfilter/nfnetlink_queue.h
+++ b/include/uapi/linux/netfilter/nfnetlink_queue.h
@@ -49,6 +49,7 @@ enum nfqnl_attr_type {
 	NFQA_EXP,			/* nf_conntrack_netlink.h */
 	NFQA_UID,			/* __u32 sk uid */
 	NFQA_GID,			/* __u32 sk gid */
+	NFQA_SECCTX,			/* security context string */
 
 	__NFQA_MAX
 };
@@ -102,7 +103,8 @@ enum nfqnl_attr_config {
 #define NFQA_CFG_F_CONNTRACK			(1 << 1)
 #define NFQA_CFG_F_GSO				(1 << 2)
 #define NFQA_CFG_F_UID_GID			(1 << 3)
-#define NFQA_CFG_F_MAX				(1 << 4)
+#define NFQA_CFG_F_SECCTX			(1 << 4)
+#define NFQA_CFG_F_MAX				(1 << 5)
 
 /* flags for NFQA_SKB_INFO */
 /* packet appears to have wrong checksums, but they are ok */
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 22a5ac7..6eccf0f 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -278,6 +278,23 @@ nla_put_failure:
 	return -1;
 }
 
+static u32 nfqnl_get_sk_secctx(struct sk_buff *skb, char **secdata)
+{
+	u32 seclen = 0;
+#if IS_ENABLED(CONFIG_NETWORK_SECMARK)
+	if (!skb || !sk_fullsock(skb->sk))
+		return 0;
+
+	read_lock_bh(&skb->sk->sk_callback_lock);
+
+	if (skb->secmark)
+		security_secid_to_secctx(skb->secmark, secdata, &seclen);
+
+	read_unlock_bh(&skb->sk->sk_callback_lock);
+#endif
+	return seclen;
+}
+
 static struct sk_buff *
 nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			   struct nf_queue_entry *entry,
@@ -297,6 +314,8 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	struct nf_conn *ct = NULL;
 	enum ip_conntrack_info uninitialized_var(ctinfo);
 	bool csum_verify;
+	char *secdata = NULL;
+	u32 seclen = 0;
 
 	size =    nlmsg_total_size(sizeof(struct nfgenmsg))
 		+ nla_total_size(sizeof(struct nfqnl_msg_packet_hdr))
@@ -352,6 +371,12 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			+ nla_total_size(sizeof(u_int32_t)));	/* gid */
 	}
 
+	if ((queue->flags & NFQA_CFG_F_SECCTX) && entskb->sk) {
+		seclen = nfqnl_get_sk_secctx(entskb, &secdata);
+		if (seclen)
+			size += nla_total_size(seclen);
+	}
+
 	skb = nfnetlink_alloc_skb(net, size, queue->peer_portid,
 				  GFP_ATOMIC);
 	if (!skb) {
@@ -479,6 +504,9 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	    nfqnl_put_sk_uidgid(skb, entskb->sk) < 0)
 		goto nla_put_failure;
 
+	if (seclen && nla_put(skb, NFQA_SECCTX, seclen, secdata))
+		goto nla_put_failure;
+
 	if (ct && nfqnl_ct_put(skb, ct, ctinfo) < 0)
 		goto nla_put_failure;
 
@@ -1142,7 +1170,12 @@ nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 			ret = -EOPNOTSUPP;
 			goto err_out_unlock;
 		}
-
+#if !IS_ENABLED(CONFIG_NETWORK_SECMARK)
+		if (flags & mask & NFQA_CFG_F_SECCTX) {
+			ret = -EOPNOTSUPP;
+			goto err_out_unlock;
+		}
+#endif
 		spin_lock_bh(&queue->lock);
 		queue->flags &= ~mask;
 		queue->flags |= flags & mask;
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
