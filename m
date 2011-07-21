From: kaber@trash.net
Subject: [PATCH 4/8] netfilter: nfnetlink_queue: assert monotonic packet ids
Date: Thu, 21 Jul 2011 12:17:52 +0200
Message-ID: <1311243476-18236-5-git-send-email-kaber@trash.net>
References: <1311243476-18236-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1311243476-18236-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

Packet identifier is currently setup in nfqnl_build_packet_message(),
using one atomic_inc_return().

Problem is that since several cpus might concurrently call
nfqnl_enqueue_packet() for the same queue, we can deliver packets to
consumer in non monotonic way (packet N+1 being delivered after packet
N)

This patch moves the packet id setup from nfqnl_build_packet_message()
to nfqnl_enqueue_packet() to guarantee correct delivery order.

This also removes one atomic operation.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Florian Westphal <fw@strlen.de>
CC: Pablo Neira Ayuso <pablo@netfilter.org>
CC: Eric Leblond <eric@regit.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nfnetlink_queue.c |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index c645b87..3b2af8c 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -58,7 +58,7 @@ struct nfqnl_instance {
  */
 	spinlock_t	lock;
 	unsigned int	queue_total;
-	atomic_t	id_sequence;		/* 'sequence' of pkt ids */
+	unsigned int	id_sequence;		/* 'sequence' of pkt ids */
 	struct list_head queue_list;		/* packets in queue */
 };
 
@@ -213,13 +213,15 @@ nfqnl_flush(struct nfqnl_instance *queue, nfqnl_cmpfn cmpfn, unsigned long data)
 
 static struct sk_buff *
 nfqnl_build_packet_message(struct nfqnl_instance *queue,
-			   struct nf_queue_entry *entry)
+			   struct nf_queue_entry *entry,
+			   __be32 **packet_id_ptr)
 {
 	sk_buff_data_t old_tail;
 	size_t size;
 	size_t data_len = 0;
 	struct sk_buff *skb;
-	struct nfqnl_msg_packet_hdr pmsg;
+	struct nlattr *nla;
+	struct nfqnl_msg_packet_hdr *pmsg;
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 	struct sk_buff *entskb = entry->skb;
@@ -272,12 +274,11 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	nfmsg->version = NFNETLINK_V0;
 	nfmsg->res_id = htons(queue->queue_num);
 
-	entry->id = atomic_inc_return(&queue->id_sequence);
-	pmsg.packet_id 		= htonl(entry->id);
-	pmsg.hw_protocol	= entskb->protocol;
-	pmsg.hook		= entry->hook;
-
-	NLA_PUT(skb, NFQA_PACKET_HDR, sizeof(pmsg), &pmsg);
+	nla = __nla_reserve(skb, NFQA_PACKET_HDR, sizeof(*pmsg));
+	pmsg = nla_data(nla);
+	pmsg->hw_protocol	= entskb->protocol;
+	pmsg->hook		= entry->hook;
+	*packet_id_ptr		= &pmsg->packet_id;
 
 	indev = entry->indev;
 	if (indev) {
@@ -388,6 +389,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	struct sk_buff *nskb;
 	struct nfqnl_instance *queue;
 	int err = -ENOBUFS;
+	__be32 *packet_id_ptr;
 
 	/* rcu_read_lock()ed by nf_hook_slow() */
 	queue = instance_lookup(queuenum);
@@ -401,7 +403,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 		goto err_out;
 	}
 
-	nskb = nfqnl_build_packet_message(queue, entry);
+	nskb = nfqnl_build_packet_message(queue, entry, &packet_id_ptr);
 	if (nskb == NULL) {
 		err = -ENOMEM;
 		goto err_out;
@@ -420,6 +422,8 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 				 queue->queue_total);
 		goto err_out_free_nskb;
 	}
+	entry->id = ++queue->id_sequence;
+	*packet_id_ptr = htonl(entry->id);
 
 	/* nfnetlink_unicast will either free the nskb or add it to a socket */
 	err = nfnetlink_unicast(nskb, &init_net, queue->peer_pid, MSG_DONTWAIT);
@@ -852,7 +856,7 @@ static int seq_show(struct seq_file *s, void *v)
 			  inst->peer_pid, inst->queue_total,
 			  inst->copy_mode, inst->copy_range,
 			  inst->queue_dropped, inst->queue_user_dropped,
-			  atomic_read(&inst->id_sequence), 1);
+			  inst->id_sequence, 1);
 }
 
 static const struct seq_operations nfqnl_seq_ops = {
-- 
1.7.2.3

