From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/19] netfilter: nf_queue: relax NFQA_CT attribute check
Date: Tue, 20 Aug 2013 12:54:37 +0200
Message-ID: <1376996091-3964-6-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60070 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010Ab3HTKzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:55:09 -0400
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Allow modifying attributes of the conntrack associated with a packet
without first requesting ct data via CFG_F_CONNTRACK or extra
nfnetlink_conntrack socket.

Also remove unneded rcu_read_lock; the entire function is already
protected by rcu.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue_core.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 971ea14..ec9de12 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -987,8 +987,7 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	if (entry == NULL)
 		return -ENOENT;
 
-	rcu_read_lock();
-	if (nfqa[NFQA_CT] && (queue->flags & NFQA_CFG_F_CONNTRACK))
+	if (nfqa[NFQA_CT])
 		ct = nfqnl_ct_parse(entry->skb, nfqa[NFQA_CT], &ctinfo);
 
 	if (nfqa[NFQA_PAYLOAD]) {
@@ -1002,7 +1001,6 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 		if (ct)
 			nfqnl_ct_seq_adjust(skb, ct, ctinfo, diff);
 	}
-	rcu_read_unlock();
 
 	if (nfqa[NFQA_MARK])
 		entry->skb->mark = ntohl(nla_get_be32(nfqa[NFQA_MARK]));
-- 
1.7.10.4
