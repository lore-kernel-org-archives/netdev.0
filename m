From: pablo@netfilter.org
Subject: [PATCH 03/25] netfilter: Add fail-open support
Date: Mon, 11 Jun 2012 16:43:39 +0200
Message-ID: <1339425841-24171-4-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar <krkumar2@in.ibm.com>

Implement a new "fail-open" mode where packets are not dropped
upon queue-full condition. This mode can be enabled/disabled per
queue using netlink NFQA_CFG_FLAGS & NFQA_CFG_MASK attributes.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Signed-off-by: Vivek Kashyap <vivk@us.ibm.com>
Signed-off-by: Sridhar Samudrala <samudrala@us.ibm.com>
---
 include/linux/netfilter/nfnetlink_queue.h |    5 ++++
 net/netfilter/nfnetlink_queue.c           |   40 ++++++++++++++++++++++++++---
 2 files changed, 42 insertions(+), 3 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netfilter/nfnetlink_queue.h
index 24b32e6..a6c1dda 100644
--- a/include/linux/netfilter/nfnetlink_queue.h
+++ b/include/linux/netfilter/nfnetlink_queue.h
@@ -84,8 +84,13 @@ enum nfqnl_attr_config {
 	NFQA_CFG_CMD,			/* nfqnl_msg_config_cmd */
 	NFQA_CFG_PARAMS,		/* nfqnl_msg_config_params */
 	NFQA_CFG_QUEUE_MAXLEN,		/* __u32 */
+	NFQA_CFG_MASK,			/* identify which flags to change */
+	NFQA_CFG_FLAGS,			/* value of these flags (__u32) */
 	__NFQA_CFG_MAX
 };
 #define NFQA_CFG_MAX (__NFQA_CFG_MAX-1)
 
+/* Flags for NFQA_CFG_FLAGS */
+#define NFQA_CFG_F_FAIL_OPEN			(1 << 0)
+
 #endif /* _NFNETLINK_QUEUE_H */
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 4162437..630da3d 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -52,6 +52,7 @@ struct nfqnl_instance {
 
 	u_int16_t queue_num;			/* number of this queue */
 	u_int8_t copy_mode;
+	u_int32_t flags;			/* Set using NFQA_CFG_FLAGS */
 /*
  * Following fields are dirtied for each queued packet,
  * keep them in same cache line if possible.
@@ -406,6 +407,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	struct nfqnl_instance *queue;
 	int err = -ENOBUFS;
 	__be32 *packet_id_ptr;
+	int failopen = 0;
 
 	/* rcu_read_lock()ed by nf_hook_slow() */
 	queue = instance_lookup(queuenum);
@@ -431,9 +433,14 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 		goto err_out_free_nskb;
 	}
 	if (queue->queue_total >= queue->queue_maxlen) {
-		queue->queue_dropped++;
-		net_warn_ratelimited("nf_queue: full at %d entries, dropping packets(s)\n",
-				     queue->queue_total);
+		if (queue->flags & NFQA_CFG_F_FAIL_OPEN) {
+			failopen = 1;
+			err = 0;
+		} else {
+			queue->queue_dropped++;
+			net_warn_ratelimited("nf_queue: full at %d entries, dropping packets(s)\n",
+					     queue->queue_total);
+		}
 		goto err_out_free_nskb;
 	}
 	entry->id = ++queue->id_sequence;
@@ -455,6 +462,8 @@ err_out_free_nskb:
 	kfree_skb(nskb);
 err_out_unlock:
 	spin_unlock_bh(&queue->lock);
+	if (failopen)
+		nf_reinject(entry, NF_ACCEPT);
 err_out:
 	return err;
 }
@@ -858,6 +867,31 @@ nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 		spin_unlock_bh(&queue->lock);
 	}
 
+	if (nfqa[NFQA_CFG_FLAGS]) {
+		__u32 flags, mask;
+
+		if (!queue) {
+			ret = -ENODEV;
+			goto err_out_unlock;
+		}
+
+		if (!nfqa[NFQA_CFG_MASK]) {
+			/* A mask is needed to specify which flags are being
+			 * changed.
+			 */
+			ret = -EINVAL;
+			goto err_out_unlock;
+		}
+
+		flags = ntohl(nla_get_be32(nfqa[NFQA_CFG_FLAGS]));
+		mask = ntohl(nla_get_be32(nfqa[NFQA_CFG_MASK]));
+
+		spin_lock_bh(&queue->lock);
+		queue->flags &= ~mask;
+		queue->flags |= flags & mask;
+		spin_unlock_bh(&queue->lock);
+	}
+
 err_out_unlock:
 	rcu_read_unlock();
 	return ret;
-- 
1.7.10

