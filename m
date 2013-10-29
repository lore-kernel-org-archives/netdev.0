From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] netfilter: xt_NFQUEUE: fix --queue-bypass regression
Date: Tue, 29 Oct 2013 13:13:16 +0100
Message-ID: <1383048796-7964-2-git-send-email-pablo@netfilter.org>
References: <1383048796-7964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35379 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754513Ab3J2MNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 08:13:31 -0400
In-Reply-To: <1383048796-7964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Eitzenberger <holger@eitzenberger.org>

V3 of the NFQUEUE target ignores the --queue-bypass flag,
causing packets to be dropped when the userspace listener
isn't running.

Regression is in since 8746ddcf12bb26 ("netfilter: xt_NFQUEUE:
introduce CPU fanout").

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_NFQUEUE.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 1e2fae3..ed00fef 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -147,6 +147,7 @@ nfqueue_tg_v3(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_NFQ_info_v3 *info = par->targinfo;
 	u32 queue = info->queuenum;
+	int ret;
 
 	if (info->queues_total > 1) {
 		if (info->flags & NFQ_FLAG_CPU_FANOUT) {
@@ -157,7 +158,11 @@ nfqueue_tg_v3(struct sk_buff *skb, const struct xt_action_param *par)
 			queue = nfqueue_hash(skb, par);
 	}
 
-	return NF_QUEUE_NR(queue);
+	ret = NF_QUEUE_NR(queue);
+	if (info->flags & NFQ_FLAG_BYPASS)
+		ret |= NF_VERDICT_FLAG_QUEUE_BYPASS;
+
+	return ret;
 }
 
 static struct xt_target nfqueue_tg_reg[] __read_mostly = {
-- 
1.7.10.4
