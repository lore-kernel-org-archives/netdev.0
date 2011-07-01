From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/2] nfnetlink_queue: provide rcu enabled callbacks
Date: Fri, 01 Jul 2011 17:29:02 +0200
Message-ID: <1309534142.2599.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sclark46@earthlink.net, Eric Leblond <eric@regit.org>,
	Kuzin Andrey <kuzinandrey@yandex.ru>,
	Anders Nilsson Plymoth <lanilsson@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>, Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nenetlink_queue operations on SMP are not efficent if several queues are
used, because of nfnl_mutex contention when applications give packet
verdict.

Use new call_rcu field in struct nfnl_callback to advertize a callback
that is called under rcu_read_lock instead of nfnl_mutex.

On my 2x4x2 machine, I was able to reach 2.000.000 pps going through
user land returning NF_ACCEPT verdicts without losses, instead of less
than 500.000 pps before patch.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Florian Westphal <fw@strlen.de>
CC: Eric Leblond <eric@regit.org>
CC: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nfnetlink_queue.c |   41 ++++++++----------------------
 1 files changed, 12 insertions(+), 29 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index fdd2faf..d3692fc 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -620,39 +620,26 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	struct nfqnl_instance *queue;
 	unsigned int verdict;
 	struct nf_queue_entry *entry;
-	int err;
 
-	rcu_read_lock();
 	queue = instance_lookup(queue_num);
-	if (!queue) {
-		err = -ENODEV;
-		goto err_out_unlock;
-	}
+	if (!queue)
+		return -ENODEV;
 
-	if (queue->peer_pid != NETLINK_CB(skb).pid) {
-		err = -EPERM;
-		goto err_out_unlock;
-	}
+	if (queue->peer_pid != NETLINK_CB(skb).pid)
+		return -EPERM;
 
-	if (!nfqa[NFQA_VERDICT_HDR]) {
-		err = -EINVAL;
-		goto err_out_unlock;
-	}
+	if (!nfqa[NFQA_VERDICT_HDR])
+		return -EINVAL;
 
 	vhdr = nla_data(nfqa[NFQA_VERDICT_HDR]);
 	verdict = ntohl(vhdr->verdict);
 
-	if ((verdict & NF_VERDICT_MASK) > NF_MAX_VERDICT) {
-		err = -EINVAL;
-		goto err_out_unlock;
-	}
+	if ((verdict & NF_VERDICT_MASK) > NF_MAX_VERDICT)
+		return -EINVAL;
 
 	entry = find_dequeue_entry(queue, ntohl(vhdr->id));
-	if (entry == NULL) {
-		err = -ENOENT;
-		goto err_out_unlock;
-	}
-	rcu_read_unlock();
+	if (entry == NULL)
+		return -ENOENT;
 
 	if (nfqa[NFQA_PAYLOAD]) {
 		if (nfqnl_mangle(nla_data(nfqa[NFQA_PAYLOAD]),
@@ -665,10 +652,6 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 
 	nf_reinject(entry, verdict);
 	return 0;
-
-err_out_unlock:
-	rcu_read_unlock();
-	return err;
 }
 
 static int
@@ -781,9 +764,9 @@ err_out_unlock:
 }
 
 static const struct nfnl_callback nfqnl_cb[NFQNL_MSG_MAX] = {
-	[NFQNL_MSG_PACKET]	= { .call = nfqnl_recv_unsupp,
+	[NFQNL_MSG_PACKET]	= { .call_rcu = nfqnl_recv_unsupp,
 				    .attr_count = NFQA_MAX, },
-	[NFQNL_MSG_VERDICT]	= { .call = nfqnl_recv_verdict,
+	[NFQNL_MSG_VERDICT]	= { .call_rcu = nfqnl_recv_verdict,
 				    .attr_count = NFQA_MAX,
 				    .policy = nfqa_verdict_policy },
 	[NFQNL_MSG_CONFIG]	= { .call = nfqnl_recv_config,


