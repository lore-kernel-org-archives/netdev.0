From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/17] netfilter: nfnetlink_queue: validate dependencies to avoid breaking atomicity
Date: Fri,  8 Jan 2016 15:02:10 +0100
Message-ID: <1452261737-7475-11-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>

Check that dependencies are fulfilled before updating the queue
instance, otherwise we can leave things in intermediate state on errors
in nfqnl_recv_config().

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue.c | 72 ++++++++++++++++++-----------------------
 1 file changed, 32 insertions(+), 40 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 3d1f16c..fe360f7 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1113,6 +1113,7 @@ static int nfqnl_recv_config(struct net *net, struct sock *ctnl,
 	struct nfqnl_instance *queue;
 	struct nfqnl_msg_config_cmd *cmd = NULL;
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
+	__u32 flags = 0, mask = 0;
 	int ret = 0;
 
 	if (nfqa[NFQA_CFG_CMD]) {
@@ -1125,6 +1126,29 @@ static int nfqnl_recv_config(struct net *net, struct sock *ctnl,
 		}
 	}
 
+	/* Check if we support these flags in first place, dependencies should
+	 * be there too not to break atomicity.
+	 */
+	if (nfqa[NFQA_CFG_FLAGS]) {
+		if (!nfqa[NFQA_CFG_MASK]) {
+			/* A mask is needed to specify which flags are being
+			 * changed.
+			 */
+			return -EINVAL;
+		}
+
+		flags = ntohl(nla_get_be32(nfqa[NFQA_CFG_FLAGS]));
+		mask = ntohl(nla_get_be32(nfqa[NFQA_CFG_MASK]));
+
+		if (flags >= NFQA_CFG_F_MAX)
+			return -EOPNOTSUPP;
+
+#if !IS_ENABLED(CONFIG_NETWORK_SECMARK)
+		if (flags & mask & NFQA_CFG_F_SECCTX)
+			return -EOPNOTSUPP;
+#endif
+	}
+
 	rcu_read_lock();
 	queue = instance_lookup(q, queue_num);
 	if (queue && queue->peer_portid != NETLINK_CB(skb).portid) {
@@ -1162,60 +1186,28 @@ static int nfqnl_recv_config(struct net *net, struct sock *ctnl,
 		}
 	}
 
+	if (!queue) {
+		ret = -ENODEV;
+		goto err_out_unlock;
+	}
+
 	if (nfqa[NFQA_CFG_PARAMS]) {
-		struct nfqnl_msg_config_params *params;
+		struct nfqnl_msg_config_params *params =
+			nla_data(nfqa[NFQA_CFG_PARAMS]);
 
-		if (!queue) {
-			ret = -ENODEV;
-			goto err_out_unlock;
-		}
-		params = nla_data(nfqa[NFQA_CFG_PARAMS]);
 		nfqnl_set_mode(queue, params->copy_mode,
 				ntohl(params->copy_range));
 	}
 
 	if (nfqa[NFQA_CFG_QUEUE_MAXLEN]) {
-		__be32 *queue_maxlen;
+		__be32 *queue_maxlen = nla_data(nfqa[NFQA_CFG_QUEUE_MAXLEN]);
 
-		if (!queue) {
-			ret = -ENODEV;
-			goto err_out_unlock;
-		}
-		queue_maxlen = nla_data(nfqa[NFQA_CFG_QUEUE_MAXLEN]);
 		spin_lock_bh(&queue->lock);
 		queue->queue_maxlen = ntohl(*queue_maxlen);
 		spin_unlock_bh(&queue->lock);
 	}
 
 	if (nfqa[NFQA_CFG_FLAGS]) {
-		__u32 flags, mask;
-
-		if (!queue) {
-			ret = -ENODEV;
-			goto err_out_unlock;
-		}
-
-		if (!nfqa[NFQA_CFG_MASK]) {
-			/* A mask is needed to specify which flags are being
-			 * changed.
-			 */
-			ret = -EINVAL;
-			goto err_out_unlock;
-		}
-
-		flags = ntohl(nla_get_be32(nfqa[NFQA_CFG_FLAGS]));
-		mask = ntohl(nla_get_be32(nfqa[NFQA_CFG_MASK]));
-
-		if (flags >= NFQA_CFG_F_MAX) {
-			ret = -EOPNOTSUPP;
-			goto err_out_unlock;
-		}
-#if !IS_ENABLED(CONFIG_NETWORK_SECMARK)
-		if (flags & mask & NFQA_CFG_F_SECCTX) {
-			ret = -EOPNOTSUPP;
-			goto err_out_unlock;
-		}
-#endif
 		spin_lock_bh(&queue->lock);
 		queue->flags &= ~mask;
 		queue->flags |= flags & mask;
-- 
2.1.4

