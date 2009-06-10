From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 26/31: xt_NFQUEUE: queue balancing support
Date: Wed, 10 Jun 2009 21:46:55 +0200 (MEST)
Message-ID: <20090610194653.11112.92500.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33201 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761161AbZFJTqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:46:53 -0400
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 10662aa3083f869c645cc2abf5d66849001e2f5d
Author: Florian Westphal <fw@strlen.de>
Date:   Fri Jun 5 13:24:24 2009 +0200

    netfilter: xt_NFQUEUE: queue balancing support
    
    Adds support for specifying a range of queues instead of a single queue
    id. Flows will be distributed across the given range.
    
    This is useful for multicore systems: Instead of having a single
    application read packets from a queue, start multiple
    instances on queues x, x+1, .. x+n. Each instance can process
    flows independently.
    
    Packets for the same connection are put into the same queue.
    
    Signed-off-by: Holger Eitzenberger <heitzenberger@astaro.com>
    Signed-off-by: Florian Westphal <fwestphal@astaro.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/xt_NFQUEUE.h b/include/linux/netfilter/xt_NFQUEUE.h
index 982a89f..2584f4a 100644
--- a/include/linux/netfilter/xt_NFQUEUE.h
+++ b/include/linux/netfilter/xt_NFQUEUE.h
@@ -15,4 +15,9 @@ struct xt_NFQ_info {
 	__u16 queuenum;
 };
 
+struct xt_NFQ_info_v1 {
+	__u16 queuenum;
+	__u16 queues_total;
+};
+
 #endif /* _XT_NFQ_TARGET_H */
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 6e0f84d..498b451 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -11,6 +11,10 @@
 #include <linux/module.h>
 #include <linux/skbuff.h>
 
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/jhash.h>
+
 #include <linux/netfilter.h>
 #include <linux/netfilter_arp.h>
 #include <linux/netfilter/x_tables.h>
@@ -23,6 +27,8 @@ MODULE_ALIAS("ipt_NFQUEUE");
 MODULE_ALIAS("ip6t_NFQUEUE");
 MODULE_ALIAS("arpt_NFQUEUE");
 
+static u32 jhash_initval __read_mostly;
+
 static unsigned int
 nfqueue_tg(struct sk_buff *skb, const struct xt_target_param *par)
 {
@@ -31,6 +37,72 @@ nfqueue_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	return NF_QUEUE_NR(tinfo->queuenum);
 }
 
+static u32 hash_v4(const struct sk_buff *skb)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	u32 ipaddr;
+
+	/* packets in either direction go into same queue */
+	ipaddr = iph->saddr ^ iph->daddr;
+
+	return jhash_2words(ipaddr, iph->protocol, jhash_initval);
+}
+
+static unsigned int
+nfqueue_tg4_v1(struct sk_buff *skb, const struct xt_target_param *par)
+{
+	const struct xt_NFQ_info_v1 *info = par->targinfo;
+	u32 queue = info->queuenum;
+
+	if (info->queues_total > 1)
+		queue = hash_v4(skb) % info->queues_total + queue;
+	return NF_QUEUE_NR(queue);
+}
+
+#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
+static u32 hash_v6(const struct sk_buff *skb)
+{
+	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	u32 addr[4];
+
+	addr[0] = ip6h->saddr.s6_addr32[0] ^ ip6h->daddr.s6_addr32[0];
+	addr[1] = ip6h->saddr.s6_addr32[1] ^ ip6h->daddr.s6_addr32[1];
+	addr[2] = ip6h->saddr.s6_addr32[2] ^ ip6h->daddr.s6_addr32[2];
+	addr[3] = ip6h->saddr.s6_addr32[3] ^ ip6h->daddr.s6_addr32[3];
+
+	return jhash2(addr, ARRAY_SIZE(addr), jhash_initval);
+}
+
+static unsigned int
+nfqueue_tg6_v1(struct sk_buff *skb, const struct xt_target_param *par)
+{
+	const struct xt_NFQ_info_v1 *info = par->targinfo;
+	u32 queue = info->queuenum;
+
+	if (info->queues_total > 1)
+		queue = hash_v6(skb) % info->queues_total + queue;
+	return NF_QUEUE_NR(queue);
+}
+#endif
+
+static bool nfqueue_tg_v1_check(const struct xt_tgchk_param *par)
+{
+	const struct xt_NFQ_info_v1 *info = par->targinfo;
+	u32 maxid;
+
+	if (info->queues_total == 0) {
+		pr_err("NFQUEUE: number of total queues is 0\n");
+		return false;
+	}
+	maxid = info->queues_total - 1 + info->queuenum;
+	if (maxid > 0xffff) {
+		pr_err("NFQUEUE: number of queues (%u) out of range (got %u)\n",
+		       info->queues_total, maxid);
+		return false;
+	}
+	return true;
+}
+
 static struct xt_target nfqueue_tg_reg[] __read_mostly = {
 	{
 		.name		= "NFQUEUE",
@@ -39,10 +111,31 @@ static struct xt_target nfqueue_tg_reg[] __read_mostly = {
 		.targetsize	= sizeof(struct xt_NFQ_info),
 		.me		= THIS_MODULE,
 	},
+	{
+		.name		= "NFQUEUE",
+		.revision	= 1,
+		.family		= NFPROTO_IPV4,
+		.checkentry	= nfqueue_tg_v1_check,
+		.target		= nfqueue_tg4_v1,
+		.targetsize	= sizeof(struct xt_NFQ_info_v1),
+		.me		= THIS_MODULE,
+	},
+#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
+	{
+		.name		= "NFQUEUE",
+		.revision	= 1,
+		.family		= NFPROTO_IPV6,
+		.checkentry	= nfqueue_tg_v1_check,
+		.target		= nfqueue_tg6_v1,
+		.targetsize	= sizeof(struct xt_NFQ_info_v1),
+		.me		= THIS_MODULE,
+	},
+#endif
 };
 
 static int __init nfqueue_tg_init(void)
 {
+	get_random_bytes(&jhash_initval, sizeof(jhash_initval));
 	return xt_register_targets(nfqueue_tg_reg, ARRAY_SIZE(nfqueue_tg_reg));
 }
 
