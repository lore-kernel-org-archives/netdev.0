From: kaber@trash.net
Subject: [PATCH 06/84] netfilter: xt_NFQUEUE: consolidate v4/v6 targets into one
Date: Mon, 10 May 2010 22:17:37 +0200
Message-ID: <1273522735-24672-7-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_NFQUEUE.c |   40 ++++++++++++----------------------------
 1 files changed, 12 insertions(+), 28 deletions(-)

diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 12dcd70..a37e216 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -49,17 +49,6 @@ static u32 hash_v4(const struct sk_buff *skb)
 	return jhash_2words((__force u32)ipaddr, iph->protocol, jhash_initval);
 }
 
-static unsigned int
-nfqueue_tg4_v1(struct sk_buff *skb, const struct xt_target_param *par)
-{
-	const struct xt_NFQ_info_v1 *info = par->targinfo;
-	u32 queue = info->queuenum;
-
-	if (info->queues_total > 1)
-		queue = hash_v4(skb) % info->queues_total + queue;
-	return NF_QUEUE_NR(queue);
-}
-
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 static u32 hash_v6(const struct sk_buff *skb)
 {
@@ -73,18 +62,24 @@ static u32 hash_v6(const struct sk_buff *skb)
 
 	return jhash2((__force u32 *)addr, ARRAY_SIZE(addr), jhash_initval);
 }
+#endif
 
 static unsigned int
-nfqueue_tg6_v1(struct sk_buff *skb, const struct xt_target_param *par)
+nfqueue_tg_v1(struct sk_buff *skb, const struct xt_target_param *par)
 {
 	const struct xt_NFQ_info_v1 *info = par->targinfo;
 	u32 queue = info->queuenum;
 
-	if (info->queues_total > 1)
-		queue = hash_v6(skb) % info->queues_total + queue;
+	if (info->queues_total > 1) {
+		if (par->target->family == NFPROTO_IPV4)
+			queue = hash_v4(skb) % info->queues_total + queue;
+#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
+		else if (par->target->family == NFPROTO_IPV6)
+			queue = hash_v6(skb) % info->queues_total + queue;
+#endif
+	}
 	return NF_QUEUE_NR(queue);
 }
-#endif
 
 static bool nfqueue_tg_v1_check(const struct xt_tgchk_param *par)
 {
@@ -119,23 +114,12 @@ static struct xt_target nfqueue_tg_reg[] __read_mostly = {
 	{
 		.name		= "NFQUEUE",
 		.revision	= 1,
-		.family		= NFPROTO_IPV4,
-		.checkentry	= nfqueue_tg_v1_check,
-		.target		= nfqueue_tg4_v1,
-		.targetsize	= sizeof(struct xt_NFQ_info_v1),
-		.me		= THIS_MODULE,
-	},
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
-	{
-		.name		= "NFQUEUE",
-		.revision	= 1,
-		.family		= NFPROTO_IPV6,
+		.family		= NFPROTO_UNSPEC,
 		.checkentry	= nfqueue_tg_v1_check,
-		.target		= nfqueue_tg6_v1,
+		.target		= nfqueue_tg_v1,
 		.targetsize	= sizeof(struct xt_NFQ_info_v1),
 		.me		= THIS_MODULE,
 	},
-#endif
 };
 
 static int __init nfqueue_tg_init(void)
-- 
1.7.0.4

