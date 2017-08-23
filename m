From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next] net_sched: kill u32_node pointer in Qdisc
Date: Wed, 23 Aug 2017 22:25:53 +0200
Message-ID: <20170823202553.GC2015@nanopsycho>
References: <20170823175854.21924-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:38125 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932407AbdHWUZ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 16:25:57 -0400
Received: by mail-wr0-f196.google.com with SMTP id 94so344077wri.5
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 13:25:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170823175854.21924-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 23, 2017 at 07:58:54PM CEST, xiyou.wangcong@gmail.com wrote:
>It is ugly to hide a u32-filter-specific pointer inside Qdisc,
>this breaks the TC layers:
>
>1. Qdisc is a generic representation, should not have any specific
>   data of any type
>
>2. Qdisc layer is above filter layer, should only save filters in
>   the list of struct tcf_proto.
>
>This pointer is used as the head of the chain of u32 hash tables,
>that is struct tc_u_hnode, because u32 filter is very special,
>it allows to create multiple hash tables within one qdisc and
>across multiple u32 filters.
>
>Instead of using this ugly pointer, we can just save it in a global
>hash table key'ed by (dev ifindex, qdisc handle), therefore we can
>still treat it as a per qdisc basis data structure conceptually.
>
>Of course, because of network namespaces, this key is not unique
>at all, but it is fine as we already have a pointer to Qdisc in
>struct tc_u_common, we can just compare the pointers when collision.
>
>And this only affects slow paths, has no impact to fast path,
>thanks to the pointer ->tp_c.

Thanks for taking care of this. Comments below.



>
>Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>Cc: Jiri Pirko <jiri@resnulli.us>
>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>---
> include/net/sch_generic.h |  1 -
> net/sched/cls_u32.c       | 55 +++++++++++++++++++++++++++++++++++++++++++----
> 2 files changed, 51 insertions(+), 5 deletions(-)
>
>diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
>index d817585aa5df..c30b634c5f82 100644
>--- a/include/net/sch_generic.h
>+++ b/include/net/sch_generic.h
>@@ -75,7 +75,6 @@ struct Qdisc {
> 	struct hlist_node       hash;
> 	u32			handle;
> 	u32			parent;
>-	void			*u32_node;
> 
> 	struct netdev_queue	*dev_queue;
> 
>diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
>index af22742d2847..816d8622df02 100644
>--- a/net/sched/cls_u32.c
>+++ b/net/sched/cls_u32.c
>@@ -40,6 +40,8 @@
> #include <linux/rtnetlink.h>
> #include <linux/skbuff.h>
> #include <linux/bitmap.h>
>+#include <linux/netdevice.h>
>+#include <linux/hash.h>
> #include <net/netlink.h>
> #include <net/act_api.h>
> #include <net/pkt_cls.h>
>@@ -92,6 +94,7 @@ struct tc_u_common {
> 	struct Qdisc		*q;
> 	int			refcnt;
> 	u32			hgenerator;
>+	struct hlist_node	hnode;
> 	struct rcu_head		rcu;
> };
> 
>@@ -323,12 +326,40 @@ static u32 gen_new_htid(struct tc_u_common *tp_c)
> 	return i > 0 ? (tp_c->hgenerator|0x800)<<20 : 0;
> }
> 
>+static struct hlist_head *tc_u_common_hash;

Why not use rhashtable?


>+
>+#define U32_HASH_SHIFT 10
>+#define U32_HASH_SIZE (1 << U32_HASH_SHIFT)
>+
>+static unsigned int tc_u_hash(const struct tcf_proto *tp)
>+{
>+	struct net_device *dev = tp->q->dev_queue->dev;
>+	u32 qhandle = tp->q->handle;
>+	int ifindex = dev->ifindex;
>+
>+	return hash_64((u64)ifindex << 32 | qhandle, U32_HASH_SHIFT);
>+}
>+
>+static struct tc_u_common *tc_u_common_find(const struct tcf_proto *tp)
>+{
>+	struct tc_u_common *tc;
>+	unsigned int h;
>+
>+	h = tc_u_hash(tp);
>+	hlist_for_each_entry(tc, &tc_u_common_hash[h], hnode) {
>+		if (tc->q == tp->q)
>+			return tc;
>+	}
>+	return NULL;
>+}
>+
> static int u32_init(struct tcf_proto *tp)
> {
> 	struct tc_u_hnode *root_ht;
> 	struct tc_u_common *tp_c;
>+	unsigned int h;
> 
>-	tp_c = tp->q->u32_node;
>+	tp_c = tc_u_common_find(tp);
> 
> 	root_ht = kzalloc(sizeof(*root_ht), GFP_KERNEL);
> 	if (root_ht == NULL)
>@@ -345,7 +376,10 @@ static int u32_init(struct tcf_proto *tp)
> 			return -ENOBUFS;
> 		}
> 		tp_c->q = tp->q;
>-		tp->q->u32_node = tp_c;
>+		INIT_HLIST_NODE(&tp_c->hnode);
>+
>+		h = tc_u_hash(tp);
>+		hlist_add_head(&tp_c->hnode, &tc_u_common_hash[h]);
> 	}
> 
> 	tp_c->refcnt++;
>@@ -585,7 +619,7 @@ static void u32_destroy(struct tcf_proto *tp)
> 	if (--tp_c->refcnt == 0) {
> 		struct tc_u_hnode *ht;
> 
>-		tp->q->u32_node = NULL;
>+		hlist_del(&tp_c->hnode);
> 
> 		for (ht = rtnl_dereference(tp_c->hlist);
> 		     ht;
>@@ -1213,6 +1247,8 @@ static struct tcf_proto_ops cls_u32_ops __read_mostly = {
> 
> static int __init init_u32(void)
> {
>+	int i, ret;
>+
> 	pr_info("u32 classifier\n");
> #ifdef CONFIG_CLS_U32_PERF
> 	pr_info("    Performance counters on\n");
>@@ -1223,12 +1259,23 @@ static int __init init_u32(void)
> #ifdef CONFIG_NET_CLS_ACT
> 	pr_info("    Actions configured\n");
> #endif
>-	return register_tcf_proto_ops(&cls_u32_ops);
>+	tc_u_common_hash = kvmalloc_array(U32_HASH_SIZE, sizeof(struct hlist_head), GFP_KERNEL);

This is over 80cols.


>+	if (!tc_u_common_hash)
>+		return -ENOMEM;
>+
>+	for (i = 0; i < U32_HASH_SIZE; i++)
>+		INIT_HLIST_HEAD(&tc_u_common_hash[i]);
>+
>+	ret = register_tcf_proto_ops(&cls_u32_ops);
>+	if (ret)
>+		kvfree(tc_u_common_hash);
>+	return ret;
> }
> 
> static void __exit exit_u32(void)
> {
> 	unregister_tcf_proto_ops(&cls_u32_ops);
>+	kvfree(tc_u_common_hash);
> }
> 
> module_init(init_u32)
>-- 
>2.13.0
>
