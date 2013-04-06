From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 35/51] netfilter: xt_NFQUEUE: introduce CPU fanout
Date: Sat,  6 Apr 2013 14:17:34 +0200
Message-ID: <1365250670-14993-36-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "holger@eitzenberger.org" <holger@eitzenberger.org>

Current NFQUEUE target uses a hash, computed over source and
destination address (and other parameters), for steering the packet
to the actual NFQUEUE. This, however forgets about the fact that the
packet eventually is handled by a particular CPU on user request.

If E. g.

  1) IRQ affinity is used to handle packets on a particular CPU already
     (both single-queue or multi-queue case)

and/or

  2) RPS is used to steer packets to a specific softirq

the target easily chooses an NFQUEUE which is not handled by a process
pinned to the same CPU.

The idea is therefore to use the CPU index for determining the
NFQUEUE handling the packet.

E. g. when having a system with 4 CPUs, 4 MQ queues and 4 NFQUEUEs it
looks like this:

 +-----+  +-----+  +-----+  +-----+
 |NFQ#0|  |NFQ#1|  |NFQ#2|  |NFQ#3|
 +-----+  +-----+  +-----+  +-----+
    ^        ^        ^        ^
    |        |NFQUEUE |        |
    +        +        +        +
 +-----+  +-----+  +-----+  +-----+
 |rx-0 |  |rx-1 |  |rx-2 |  |rx-3 |
 +-----+  +-----+  +-----+  +-----+

The NFQUEUEs not necessarily have to start with number 0, setups with
less NFQUEUEs than packet-handling CPUs are not a problem as well.

This patch extends the NFQUEUE target to accept a new
NFQ_FLAG_CPU_FANOUT flag. If this is specified the target uses the
CPU index for determining the NFQUEUE being used. I have to introduce
rev3 for this. The 'flags' are folded into _v2 'bypass'.

By changing the way which queue is assigned, I'm able to improve the
performance if the processes reading on the NFQUEUs are pinned
correctly.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/xt_NFQUEUE.h |    9 +++++++
 net/netfilter/xt_NFQUEUE.c                |   41 +++++++++++++++++++++++++++--
 2 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter/xt_NFQUEUE.h b/include/uapi/linux/netfilter/xt_NFQUEUE.h
index 9eafdbb..8bb5fe6 100644
--- a/include/uapi/linux/netfilter/xt_NFQUEUE.h
+++ b/include/uapi/linux/netfilter/xt_NFQUEUE.h
@@ -26,4 +26,13 @@ struct xt_NFQ_info_v2 {
 	__u16 bypass;
 };
 
+struct xt_NFQ_info_v3 {
+	__u16 queuenum;
+	__u16 queues_total;
+	__u16 flags;
+#define NFQ_FLAG_BYPASS		0x01 /* for compatibility with v2 */
+#define NFQ_FLAG_CPU_FANOUT	0x02 /* use current CPU (no hashing) */
+#define NFQ_FLAG_MASK		0x03
+};
+
 #endif /* _XT_NFQ_TARGET_H */
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 817f9e9..a287ef2 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -108,7 +108,7 @@ nfqueue_tg_v2(struct sk_buff *skb, const struct xt_action_param *par)
 
 static int nfqueue_tg_check(const struct xt_tgchk_param *par)
 {
-	const struct xt_NFQ_info_v2 *info = par->targinfo;
+	const struct xt_NFQ_info_v3 *info = par->targinfo;
 	u32 maxid;
 
 	if (unlikely(!rnd_inited)) {
@@ -125,11 +125,39 @@ static int nfqueue_tg_check(const struct xt_tgchk_param *par)
 		       info->queues_total, maxid);
 		return -ERANGE;
 	}
-	if (par->target->revision == 2 && info->bypass > 1)
+	if (par->target->revision == 2 && info->flags > 1)
+		return -EINVAL;
+	if (par->target->revision == 3 && info->flags & ~NFQ_FLAG_MASK)
 		return -EINVAL;
+
 	return 0;
 }
 
+static unsigned int
+nfqueue_tg_v3(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_NFQ_info_v3 *info = par->targinfo;
+	u32 queue = info->queuenum;
+
+	if (info->queues_total > 1) {
+		if (info->flags & NFQ_FLAG_CPU_FANOUT) {
+			int cpu = smp_processor_id();
+
+			queue = info->queuenum + cpu % info->queues_total;
+		} else {
+			if (par->family == NFPROTO_IPV4)
+				queue = (((u64) hash_v4(skb) * info->queues_total) >>
+						 32) + queue;
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
+			else if (par->family == NFPROTO_IPV6)
+				queue = (((u64) hash_v6(skb) * info->queues_total) >>
+						 32) + queue;
+#endif
+		}
+	}
+	return NF_QUEUE_NR(queue);
+}
+
 static struct xt_target nfqueue_tg_reg[] __read_mostly = {
 	{
 		.name		= "NFQUEUE",
@@ -156,6 +184,15 @@ static struct xt_target nfqueue_tg_reg[] __read_mostly = {
 		.targetsize	= sizeof(struct xt_NFQ_info_v2),
 		.me		= THIS_MODULE,
 	},
+	{
+		.name		= "NFQUEUE",
+		.revision	= 3,
+		.family		= NFPROTO_UNSPEC,
+		.checkentry	= nfqueue_tg_check,
+		.target		= nfqueue_tg_v3,
+		.targetsize	= sizeof(struct xt_NFQ_info_v3),
+		.me		= THIS_MODULE,
+	},
 };
 
 static int __init nfqueue_tg_init(void)
-- 
1.7.10.4

