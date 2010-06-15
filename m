From: kaber@trash.net
Subject: [PATCH 10/17] netfilter: nfnetlink_queue: some optimizations
Date: Tue, 15 Jun 2010 17:38:36 +0200
Message-ID: <1276616323-20880-11-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

- Use an atomic_t for id_sequence to avoid a spin_lock/spin_unlock pair

- Group highly modified struct nfqnl_instance fields together

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nfnetlink_queue.c |   33 ++++++++++++++-------------------
 1 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 12e1ab3..d05605b 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -46,17 +46,19 @@ struct nfqnl_instance {
 	int peer_pid;
 	unsigned int queue_maxlen;
 	unsigned int copy_range;
-	unsigned int queue_total;
 	unsigned int queue_dropped;
 	unsigned int queue_user_dropped;
 
-	unsigned int id_sequence;		/* 'sequence' of pkt ids */
 
 	u_int16_t queue_num;			/* number of this queue */
 	u_int8_t copy_mode;
-
-	spinlock_t lock;
-
+/*
+ * Following fields are dirtied for each queued packet,
+ * keep them in same cache line if possible.
+ */
+	spinlock_t	lock;
+	unsigned int	queue_total;
+	atomic_t	id_sequence;		/* 'sequence' of pkt ids */
 	struct list_head queue_list;		/* packets in queue */
 };
 
@@ -238,32 +240,24 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 
 	outdev = entry->outdev;
 
-	spin_lock_bh(&queue->lock);
-
-	switch ((enum nfqnl_config_mode)queue->copy_mode) {
+	switch ((enum nfqnl_config_mode)ACCESS_ONCE(queue->copy_mode)) {
 	case NFQNL_COPY_META:
 	case NFQNL_COPY_NONE:
 		break;
 
 	case NFQNL_COPY_PACKET:
 		if (entskb->ip_summed == CHECKSUM_PARTIAL &&
-		    skb_checksum_help(entskb)) {
-			spin_unlock_bh(&queue->lock);
+		    skb_checksum_help(entskb))
 			return NULL;
-		}
-		if (queue->copy_range == 0
-		    || queue->copy_range > entskb->len)
+
+		data_len = ACCESS_ONCE(queue->copy_range);
+		if (data_len == 0 || data_len > entskb->len)
 			data_len = entskb->len;
-		else
-			data_len = queue->copy_range;
 
 		size += nla_total_size(data_len);
 		break;
 	}
 
-	entry->id = queue->id_sequence++;
-
-	spin_unlock_bh(&queue->lock);
 
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb)
@@ -278,6 +272,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	nfmsg->version = NFNETLINK_V0;
 	nfmsg->res_id = htons(queue->queue_num);
 
+	entry->id = atomic_inc_return(&queue->id_sequence);
 	pmsg.packet_id 		= htonl(entry->id);
 	pmsg.hw_protocol	= entskb->protocol;
 	pmsg.hook		= entry->hook;
@@ -866,7 +861,7 @@ static int seq_show(struct seq_file *s, void *v)
 			  inst->peer_pid, inst->queue_total,
 			  inst->copy_mode, inst->copy_range,
 			  inst->queue_dropped, inst->queue_user_dropped,
-			  inst->id_sequence, 1);
+			  atomic_read(&inst->id_sequence), 1);
 }
 
 static const struct seq_operations nfqnl_seq_ops = {
-- 
1.7.0.4

