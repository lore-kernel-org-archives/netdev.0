From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 3/4] net: sched: cls_u32 add bit to specify
 software only rules
Date: Tue, 23 Feb 2016 11:03:21 -0800
Message-ID: <20160223190321.5970.58924.stgit@john-Precision-Tower-5810>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: jiri@resnulli.us, john.fastabend@gmail.com, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33054 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbcBWTDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 14:03:50 -0500
Received: by mail-pa0-f53.google.com with SMTP id fl4so114926042pad.0
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 11:03:49 -0800 (PST)
In-Reply-To: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the initial implementation the only way to stop a rule from being
inserted into the hardware table was via the device feature flag.
However this doesn't work well when working on an end host system
where packets are expect to hit both the hardware and software
datapaths.

For example we can imagine a rule that will match an IP address and
increment a field. If we install this rule in both hardware and
software we may increment the field twice. To date we have only
added support for the drop action so we have been able to ignore
these cases. But as we extend the action support we will hit this
example plus more such cases. Arguably these are not even corner
cases in many working systems these cases will be common.

To avoid forcing the driver to always abort (i.e. the above example)
this patch adds a flag to add a rule in software only. A careful
user can use this flag to build software and hardware datapaths
that work together. One example we have found particularly useful
is to use hardware resources to set the skb->mark on the skb when
the match may be expensive to run in software but a mark lookup
in a hash table is cheap. The idea here is hardware can do in one
lookup what the u32 classifier may need to traverse multiple lists
and hash tables to compute. The flag is only passed down on inserts
on deletion to avoid stale references in hardware we always try
to remove a rule if it exists.

Notice we do not add a hardware only case here. If you were to
add a hardware only case then you are stuck with the problem
of where to stick the software representation of that filter
rule. If its stuck on the same filter list as the software only and
software/hardware rules it then has to be walked over and ignored
in the classify path. The overhead is not huge but is measurable.
And with so much work being invested in speeding up rx/tx of
pkt processing this is unacceptable IMO. The other option is to
have a special hook just for hardware only resources. This is
implemented in the next patch.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/uapi/linux/pkt_cls.h |    3 +++
 net/sched/cls_u32.c          |   43 ++++++++++++++++++++++++++++++------------
 2 files changed, 34 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 4398737..143ea21 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -160,6 +160,8 @@ enum {
 #define TC_U32_UNSPEC	0
 #define TC_U32_ROOT	(0xFFF00000)
 
+#define TCA_U32_FLAGS_SOFTWARE 1
+
 enum {
 	TCA_U32_UNSPEC,
 	TCA_U32_CLASSID,
@@ -172,6 +174,7 @@ enum {
 	TCA_U32_INDEV,
 	TCA_U32_PCNT,
 	TCA_U32_MARK,
+	TCA_U32_FLAGS,
 	__TCA_U32_MAX
 };
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index f766bcb..c509fc8 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -59,6 +59,7 @@ struct tc_u_knode {
 #ifdef CONFIG_CLS_U32_PERF
 	struct tc_u32_pcnt __percpu *pf;
 #endif
+	u32			flags;
 #ifdef CONFIG_CLS_U32_MARK
 	u32			val;
 	u32			mask;
@@ -425,12 +426,18 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 	return 0;
 }
 
-static bool u32_should_offload(struct net_device *dev)
+static bool u32_should_offload(struct net_device *dev, u32 flags)
 {
 	if (!(dev->features & NETIF_F_HW_TC))
 		return false;
 
-	return dev->netdev_ops->ndo_setup_tc;
+	if (flags & TCA_U32_FLAGS_SOFTWARE)
+		return false;
+
+	if (!dev->netdev_ops->ndo_setup_tc)
+		return false;
+
+	return true;
 }
 
 static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
@@ -442,7 +449,7 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (u32_should_offload(dev)) {
+	if (u32_should_offload(dev, 0)) {
 		offload.cls_u32->command = TC_CLSU32_DELETE_KNODE;
 		offload.cls_u32->knode.handle = handle;
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
@@ -450,7 +457,9 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	}
 }
 
-static void u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
+static void u32_replace_hw_hnode(struct tcf_proto *tp,
+				 struct tc_u_hnode *h,
+				 u32 flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload u32_offload = {0};
@@ -459,7 +468,7 @@ static void u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (u32_should_offload(dev)) {
+	if (u32_should_offload(dev, flags)) {
 		offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
 		offload.cls_u32->hnode.divisor = h->divisor;
 		offload.cls_u32->hnode.handle = h->handle;
@@ -479,7 +488,7 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (u32_should_offload(dev)) {
+	if (u32_should_offload(dev, 0)) {
 		offload.cls_u32->command = TC_CLSU32_DELETE_HNODE;
 		offload.cls_u32->hnode.divisor = h->divisor;
 		offload.cls_u32->hnode.handle = h->handle;
@@ -490,7 +499,9 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	}
 }
 
-static void u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n)
+static void u32_replace_hw_knode(struct tcf_proto *tp,
+				 struct tc_u_knode *n,
+				 u32 flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload u32_offload = {0};
@@ -499,7 +510,7 @@ static void u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n)
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (u32_should_offload(dev)) {
+	if (u32_should_offload(dev, flags)) {
 		offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
 		offload.cls_u32->knode.handle = n->handle;
 		offload.cls_u32->knode.fshift = n->fshift;
@@ -687,6 +698,7 @@ static const struct nla_policy u32_policy[TCA_U32_MAX + 1] = {
 	[TCA_U32_SEL]		= { .len = sizeof(struct tc_u32_sel) },
 	[TCA_U32_INDEV]		= { .type = NLA_STRING, .len = IFNAMSIZ },
 	[TCA_U32_MARK]		= { .len = sizeof(struct tc_u32_mark) },
+	[TCA_U32_FLAGS]		= { .type = NLA_U32 },
 };
 
 static int u32_set_parms(struct net *net, struct tcf_proto *tp,
@@ -833,7 +845,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	struct tc_u32_sel *s;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_U32_MAX + 1];
-	u32 htid;
+	u32 htid, flags = 0;
 	int err;
 #ifdef CONFIG_CLS_U32_PERF
 	size_t size;
@@ -846,6 +858,9 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
+	if (tb[TCA_U32_FLAGS])
+		flags = nla_get_u32(tb[TCA_U32_FLAGS]);
+
 	n = (struct tc_u_knode *)*arg;
 	if (n) {
 		struct tc_u_knode *new;
@@ -869,7 +884,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		u32_replace_knode(tp, tp_c, new);
 		tcf_unbind_filter(tp, &n->res);
 		call_rcu(&n->rcu, u32_delete_key_rcu);
-		u32_replace_hw_knode(tp, new);
+		u32_replace_hw_knode(tp, new, flags);
 		return 0;
 	}
 
@@ -897,7 +912,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		rcu_assign_pointer(tp_c->hlist, ht);
 		*arg = (unsigned long)ht;
 
-		u32_replace_hw_hnode(tp, ht);
+		u32_replace_hw_hnode(tp, ht, flags);
 		return 0;
 	}
 
@@ -948,6 +963,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	RCU_INIT_POINTER(n->ht_up, ht);
 	n->handle = handle;
 	n->fshift = s->hmask ? ffs(ntohl(s->hmask)) - 1 : 0;
+	n->flags = flags;
 	tcf_exts_init(&n->exts, TCA_U32_ACT, TCA_U32_POLICE);
 	n->tp = tp;
 
@@ -980,7 +996,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 
 		RCU_INIT_POINTER(n->next, pins);
 		rcu_assign_pointer(*ins, n);
-		u32_replace_hw_knode(tp, n);
+		u32_replace_hw_knode(tp, n, flags);
 		*arg = (unsigned long)n;
 		return 0;
 	}
@@ -1085,6 +1101,9 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		    nla_put_u32(skb, TCA_U32_LINK, ht_down->handle))
 			goto nla_put_failure;
 
+		if (n->flags && nla_put_u32(skb, TCA_U32_FLAGS, n->flags))
+			goto nla_put_failure;
+
 #ifdef CONFIG_CLS_U32_MARK
 		if ((n->val || n->mask)) {
 			struct tc_u32_mark mark = {.val = n->val,
