From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 36/51] netfilter: xt_NFQUEUE: coalesce IPv4 and IPv6 hashing
Date: Sat,  6 Apr 2013 14:17:35 +0200
Message-ID: <1365250670-14993-37-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39038 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422683Ab3DFMSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 08:18:44 -0400
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "holger@eitzenberger.org" <holger@eitzenberger.org>

Because rev1 and rev3 of the target share the same hashing
generalize it by introduing nfqueue_hash().

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_NFQUEUE.c |   42 ++++++++++++++++++++++--------------------
 1 file changed, 22 insertions(+), 20 deletions(-)

diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index a287ef2..1e2fae3 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -76,22 +76,31 @@ static u32 hash_v6(const struct sk_buff *skb)
 }
 #endif
 
-static unsigned int
-nfqueue_tg_v1(struct sk_buff *skb, const struct xt_action_param *par)
+static u32
+nfqueue_hash(const struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_NFQ_info_v1 *info = par->targinfo;
 	u32 queue = info->queuenum;
 
-	if (info->queues_total > 1) {
-		if (par->family == NFPROTO_IPV4)
-			queue = (((u64) hash_v4(skb) * info->queues_total) >>
-				 32) + queue;
+	if (par->family == NFPROTO_IPV4)
+		queue += ((u64) hash_v4(skb) * info->queues_total) >> 32;
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
-		else if (par->family == NFPROTO_IPV6)
-			queue = (((u64) hash_v6(skb) * info->queues_total) >>
-				 32) + queue;
+	else if (par->family == NFPROTO_IPV6)
+		queue += ((u64) hash_v6(skb) * info->queues_total) >> 32;
 #endif
-	}
+
+	return queue;
+}
+
+static unsigned int
+nfqueue_tg_v1(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_NFQ_info_v1 *info = par->targinfo;
+	u32 queue = info->queuenum;
+
+	if (info->queues_total > 1)
+		queue = nfqueue_hash(skb, par);
+
 	return NF_QUEUE_NR(queue);
 }
 
@@ -144,17 +153,10 @@ nfqueue_tg_v3(struct sk_buff *skb, const struct xt_action_param *par)
 			int cpu = smp_processor_id();
 
 			queue = info->queuenum + cpu % info->queues_total;
-		} else {
-			if (par->family == NFPROTO_IPV4)
-				queue = (((u64) hash_v4(skb) * info->queues_total) >>
-						 32) + queue;
-#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
-			else if (par->family == NFPROTO_IPV6)
-				queue = (((u64) hash_v6(skb) * info->queues_total) >>
-						 32) + queue;
-#endif
-		}
+		} else
+			queue = nfqueue_hash(skb, par);
 	}
+
 	return NF_QUEUE_NR(queue);
 }
 
-- 
1.7.10.4
