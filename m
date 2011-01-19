From: kaber@trash.net
Subject: [PATCH 75/79] netfilter: allow NFQUEUE bypass if no listener is available
Date: Wed, 19 Jan 2011 20:15:15 +0100
Message-ID: <1295464519-21763-76-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

If an skb is to be NF_QUEUE'd, but no program has opened the queue, the
packet is dropped.

This adds a v2 target revision of xt_NFQUEUE that allows packets to
continue through the ruleset instead.

Because the actual queueing happens outside of the target context, the
'bypass' flag has to be communicated back to the netfilter core.

Unfortunately the only choice to do this without adding a new function
argument is to use the target function return value (i.e. the verdict).

In the NF_QUEUE case, the upper 16bit already contain the queue number
to use.  The previous patch reduced NF_VERDICT_MASK to 0xff, i.e.
we now have extra room for a new flag.

If a hook issued a NF_QUEUE verdict, then the netfilter core will
continue packet processing if the queueing hook
returns -ESRCH (== "this queue does not exist") and the new
NF_VERDICT_FLAG_QUEUE_BYPASS flag is set in the verdict value.

Note: If the queue exists, but userspace does not consume packets fast
enough, the skb will still be dropped.

Signed-off-by: Florian Westphal <fwestphal@astaro.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter.h            |    1 +
 include/linux/netfilter/xt_NFQUEUE.h |    6 ++++++
 net/netfilter/core.c                 |    3 +++
 net/netfilter/nf_queue.c             |    7 ++++++-
 net/netfilter/xt_NFQUEUE.c           |   28 +++++++++++++++++++++++++---
 5 files changed, 41 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 78b73cc..eeec00a 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -29,6 +29,7 @@
 #define NF_VERDICT_MASK 0x000000ff
 
 /* extra verdict flags have mask 0x0000ff00 */
+#define NF_VERDICT_FLAG_QUEUE_BYPASS	0x00008000
 
 /* queue number (NF_QUEUE) or errno (NF_DROP) */
 #define NF_VERDICT_QMASK 0xffff0000
diff --git a/include/linux/netfilter/xt_NFQUEUE.h b/include/linux/netfilter/xt_NFQUEUE.h
index 2584f4a..9eafdbb 100644
--- a/include/linux/netfilter/xt_NFQUEUE.h
+++ b/include/linux/netfilter/xt_NFQUEUE.h
@@ -20,4 +20,10 @@ struct xt_NFQ_info_v1 {
 	__u16 queues_total;
 };
 
+struct xt_NFQ_info_v2 {
+	__u16 queuenum;
+	__u16 queues_total;
+	__u16 bypass;
+};
+
 #endif /* _XT_NFQ_TARGET_H */
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 4d88e45..1e00bf7 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -184,6 +184,9 @@ next_hook:
 		if (ret < 0) {
 			if (ret == -ECANCELED)
 				goto next_hook;
+			if (ret == -ESRCH &&
+			   (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS))
+				goto next_hook;
 			kfree_skb(skb);
 		}
 		ret = 0;
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index ce1150d4a..5ab22e2 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -138,8 +138,10 @@ static int __nf_queue(struct sk_buff *skb,
 	rcu_read_lock();
 
 	qh = rcu_dereference(queue_handler[pf]);
-	if (!qh)
+	if (!qh) {
+		status = -ESRCH;
 		goto err_unlock;
+	}
 
 	afinfo = nf_get_afinfo(pf);
 	if (!afinfo)
@@ -303,6 +305,9 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 		if (err < 0) {
 			if (err == -ECANCELED)
 				goto next_hook;
+			if (err == -ESRCH &&
+			   (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS))
+				goto next_hook;
 			kfree_skb(skb);
 		}
 		break;
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 3962770..d4f4b5d 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -83,9 +83,20 @@ nfqueue_tg_v1(struct sk_buff *skb, const struct xt_action_param *par)
 	return NF_QUEUE_NR(queue);
 }
 
-static int nfqueue_tg_v1_check(const struct xt_tgchk_param *par)
+static unsigned int
+nfqueue_tg_v2(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	const struct xt_NFQ_info_v1 *info = par->targinfo;
+	const struct xt_NFQ_info_v2 *info = par->targinfo;
+	unsigned int ret = nfqueue_tg_v1(skb, par);
+
+	if (info->bypass)
+		ret |= NF_VERDICT_FLAG_QUEUE_BYPASS;
+	return ret;
+}
+
+static int nfqueue_tg_check(const struct xt_tgchk_param *par)
+{
+	const struct xt_NFQ_info_v2 *info = par->targinfo;
 	u32 maxid;
 
 	if (unlikely(!rnd_inited)) {
@@ -102,6 +113,8 @@ static int nfqueue_tg_v1_check(const struct xt_tgchk_param *par)
 		       info->queues_total, maxid);
 		return -ERANGE;
 	}
+	if (par->target->revision == 2 && info->bypass > 1)
+		return -EINVAL;
 	return 0;
 }
 
@@ -117,11 +130,20 @@ static struct xt_target nfqueue_tg_reg[] __read_mostly = {
 		.name		= "NFQUEUE",
 		.revision	= 1,
 		.family		= NFPROTO_UNSPEC,
-		.checkentry	= nfqueue_tg_v1_check,
+		.checkentry	= nfqueue_tg_check,
 		.target		= nfqueue_tg_v1,
 		.targetsize	= sizeof(struct xt_NFQ_info_v1),
 		.me		= THIS_MODULE,
 	},
+	{
+		.name		= "NFQUEUE",
+		.revision	= 2,
+		.family		= NFPROTO_UNSPEC,
+		.checkentry	= nfqueue_tg_check,
+		.target		= nfqueue_tg_v2,
+		.targetsize	= sizeof(struct xt_NFQ_info_v2),
+		.me		= THIS_MODULE,
+	},
 };
 
 static int __init nfqueue_tg_init(void)
-- 
1.7.2.3

