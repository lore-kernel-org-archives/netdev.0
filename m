From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/12] netfilter: nfnetlink_queue: cleanup copy_range usage
Date: Wed,  5 Jun 2013 22:40:31 +0200
Message-ID: <1370464832-4216-11-git-send-email-pablo@netfilter.org>
References: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

For every packet queued, we check if configured copy_range
is 0, and treat that as 'copy entire packet'.

We can move this check to the queue configuration, and can
set copy_range appropriately.

Also, convert repetitive '0xffff - NLA_HDRLEN' to a macro.

[ queue initialization still used 0xffff, although its harmless
  since the initial setting is overwritten on queue config ]

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue_core.c |   22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index cff4449..3c42181 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -41,6 +41,14 @@
 
 #define NFQNL_QMAX_DEFAULT 1024
 
+/* We're using struct nlattr which has 16bit nla_len. Note that nla_len
+ * includes the header length. Thus, the maximum packet length that we
+ * support is 65531 bytes. We send truncated packets if the specified length
+ * is larger than that.  Userspace can check for presence of NFQA_CAP_LEN
+ * attribute to detect truncation.
+ */
+#define NFQNL_MAX_COPY_RANGE (0xffff - NLA_HDRLEN)
+
 struct nfqnl_instance {
 	struct hlist_node hlist;		/* global list of queues */
 	struct rcu_head rcu;
@@ -122,7 +130,7 @@ instance_create(struct nfnl_queue_net *q, u_int16_t queue_num,
 	inst->queue_num = queue_num;
 	inst->peer_portid = portid;
 	inst->queue_maxlen = NFQNL_QMAX_DEFAULT;
-	inst->copy_range = 0xffff;
+	inst->copy_range = NFQNL_MAX_COPY_RANGE;
 	inst->copy_mode = NFQNL_COPY_NONE;
 	spin_lock_init(&inst->lock);
 	INIT_LIST_HEAD(&inst->queue_list);
@@ -333,10 +341,9 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 			return NULL;
 
 		data_len = ACCESS_ONCE(queue->copy_range);
-		if (data_len == 0 || data_len > entskb->len)
+		if (data_len > entskb->len)
 			data_len = entskb->len;
 
-
 		if (!entskb->head_frag ||
 		    skb_headlen(entskb) < L1_CACHE_BYTES ||
 		    skb_shinfo(entskb)->nr_frags >= MAX_SKB_FRAGS)
@@ -727,13 +734,8 @@ nfqnl_set_mode(struct nfqnl_instance *queue,
 
 	case NFQNL_COPY_PACKET:
 		queue->copy_mode = mode;
-		/* We're using struct nlattr which has 16bit nla_len. Note that
-		 * nla_len includes the header length. Thus, the maximum packet
-		 * length that we support is 65531 bytes. We send truncated
-		 * packets if the specified length is larger than that.
-		 */
-		if (range > 0xffff - NLA_HDRLEN)
-			queue->copy_range = 0xffff - NLA_HDRLEN;
+		if (range == 0 || range > NFQNL_MAX_COPY_RANGE)
+			queue->copy_range = NFQNL_MAX_COPY_RANGE;
 		else
 			queue->copy_range = range;
 		break;
-- 
1.7.10.4

