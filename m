From: kaber@trash.net
Subject: [PATCH 5/8] netfilter: nfnetlink_queue: batch verdict support
Date: Thu, 21 Jul 2011 12:17:53 +0200
Message-ID: <1311243476-18236-6-git-send-email-kaber@trash.net>
References: <1311243476-18236-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34523 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088Ab1GUKSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 06:18:03 -0400
In-Reply-To: <1311243476-18236-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Introduces a new nfnetlink type that applies a given
verdict to all queued packets with an id <= the id in the verdict
message.

If a mark is provided it is applied to all matched packets.

This reduces the number of verdicts that have to be sent.
Applications that make use of this feature need to maintain
a timeout to send a batchverdict periodically to avoid starvation.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nfnetlink_queue.h |    1 +
 net/netfilter/nfnetlink_queue.c           |  115 ++++++++++++++++++++++++++---
 2 files changed, 104 insertions(+), 12 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netfilter/nfnetlink_queue.h
index af94e00..24b32e6 100644
--- a/include/linux/netfilter/nfnetlink_queue.h
+++ b/include/linux/netfilter/nfnetlink_queue.h
@@ -8,6 +8,7 @@ enum nfqnl_msg_types {
 	NFQNL_MSG_PACKET,		/* packet from kernel to userspace */
 	NFQNL_MSG_VERDICT,		/* verdict from userspace to kernel */
 	NFQNL_MSG_CONFIG,		/* connect to a particular queue */
+	NFQNL_MSG_VERDICT_BATCH,	/* batchv from userspace to kernel */
 
 	NFQNL_MSG_MAX
 };
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 3b2af8c..fbfcd83 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -171,6 +171,13 @@ __enqueue_entry(struct nfqnl_instance *queue, struct nf_queue_entry *entry)
        queue->queue_total++;
 }
 
+static void
+__dequeue_entry(struct nfqnl_instance *queue, struct nf_queue_entry *entry)
+{
+	list_del(&entry->list);
+	queue->queue_total--;
+}
+
 static struct nf_queue_entry *
 find_dequeue_entry(struct nfqnl_instance *queue, unsigned int id)
 {
@@ -185,10 +192,8 @@ find_dequeue_entry(struct nfqnl_instance *queue, unsigned int id)
 		}
 	}
 
-	if (entry) {
-		list_del(&entry->list);
-		queue->queue_total--;
-	}
+	if (entry)
+		__dequeue_entry(queue, entry);
 
 	spin_unlock_bh(&queue->lock);
 
@@ -611,6 +616,92 @@ static const struct nla_policy nfqa_verdict_policy[NFQA_MAX+1] = {
 	[NFQA_PAYLOAD]		= { .type = NLA_UNSPEC },
 };
 
+static const struct nla_policy nfqa_verdict_batch_policy[NFQA_MAX+1] = {
+	[NFQA_VERDICT_HDR]	= { .len = sizeof(struct nfqnl_msg_verdict_hdr) },
+	[NFQA_MARK]		= { .type = NLA_U32 },
+};
+
+static struct nfqnl_instance *verdict_instance_lookup(u16 queue_num, int nlpid)
+{
+	struct nfqnl_instance *queue;
+
+	queue = instance_lookup(queue_num);
+	if (!queue)
+		return ERR_PTR(-ENODEV);
+
+	if (queue->peer_pid != nlpid)
+		return ERR_PTR(-EPERM);
+
+	return queue;
+}
+
+static struct nfqnl_msg_verdict_hdr*
+verdicthdr_get(const struct nlattr * const nfqa[])
+{
+	struct nfqnl_msg_verdict_hdr *vhdr;
+	unsigned int verdict;
+
+	if (!nfqa[NFQA_VERDICT_HDR])
+		return NULL;
+
+	vhdr = nla_data(nfqa[NFQA_VERDICT_HDR]);
+	verdict = ntohl(vhdr->verdict);
+	if ((verdict & NF_VERDICT_MASK) > NF_MAX_VERDICT)
+		return NULL;
+	return vhdr;
+}
+
+static int nfq_id_after(unsigned int id, unsigned int max)
+{
+	return (int)(id - max) > 0;
+}
+
+static int
+nfqnl_recv_verdict_batch(struct sock *ctnl, struct sk_buff *skb,
+		   const struct nlmsghdr *nlh,
+		   const struct nlattr * const nfqa[])
+{
+	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
+	struct nf_queue_entry *entry, *tmp;
+	unsigned int verdict, maxid;
+	struct nfqnl_msg_verdict_hdr *vhdr;
+	struct nfqnl_instance *queue;
+	LIST_HEAD(batch_list);
+	u16 queue_num = ntohs(nfmsg->res_id);
+
+	queue = verdict_instance_lookup(queue_num, NETLINK_CB(skb).pid);
+	if (IS_ERR(queue))
+		return PTR_ERR(queue);
+
+	vhdr = verdicthdr_get(nfqa);
+	if (!vhdr)
+		return -EINVAL;
+
+	verdict = ntohl(vhdr->verdict);
+	maxid = ntohl(vhdr->id);
+
+	spin_lock_bh(&queue->lock);
+
+	list_for_each_entry_safe(entry, tmp, &queue->queue_list, list) {
+		if (nfq_id_after(entry->id, maxid))
+			break;
+		__dequeue_entry(queue, entry);
+		list_add_tail(&entry->list, &batch_list);
+	}
+
+	spin_unlock_bh(&queue->lock);
+
+	if (list_empty(&batch_list))
+		return -ENOENT;
+
+	list_for_each_entry_safe(entry, tmp, &batch_list, list) {
+		if (nfqa[NFQA_MARK])
+			entry->skb->mark = ntohl(nla_get_be32(nfqa[NFQA_MARK]));
+		nf_reinject(entry, verdict);
+	}
+	return 0;
+}
+
 static int
 nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 		   const struct nlmsghdr *nlh,
@@ -626,20 +717,17 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 
 	queue = instance_lookup(queue_num);
 	if (!queue)
-		return -ENODEV;
 
-	if (queue->peer_pid != NETLINK_CB(skb).pid)
-		return -EPERM;
+	queue = verdict_instance_lookup(queue_num, NETLINK_CB(skb).pid);
+	if (IS_ERR(queue))
+		return PTR_ERR(queue);
 
-	if (!nfqa[NFQA_VERDICT_HDR])
+	vhdr = verdicthdr_get(nfqa);
+	if (!vhdr)
 		return -EINVAL;
 
-	vhdr = nla_data(nfqa[NFQA_VERDICT_HDR]);
 	verdict = ntohl(vhdr->verdict);
 
-	if ((verdict & NF_VERDICT_MASK) > NF_MAX_VERDICT)
-		return -EINVAL;
-
 	entry = find_dequeue_entry(queue, ntohl(vhdr->id));
 	if (entry == NULL)
 		return -ENOENT;
@@ -775,6 +863,9 @@ static const struct nfnl_callback nfqnl_cb[NFQNL_MSG_MAX] = {
 	[NFQNL_MSG_CONFIG]	= { .call = nfqnl_recv_config,
 				    .attr_count = NFQA_CFG_MAX,
 				    .policy = nfqa_cfg_policy },
+	[NFQNL_MSG_VERDICT_BATCH]={ .call_rcu = nfqnl_recv_verdict_batch,
+				    .attr_count = NFQA_MAX,
+				    .policy = nfqa_verdict_batch_policy },
 };
 
 static const struct nfnetlink_subsystem nfqnl_subsys = {
-- 
1.7.2.3

