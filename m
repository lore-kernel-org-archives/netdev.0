From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH v4] skbedit: allow the user to specify bitmask for mark
Date: Mon, 24 Oct 2016 20:32:57 +0800
Message-ID: <20161024123257.18228-1-a@unstable.cc>
References: <20140724.180708.1613882522982264262.davem@davemloft.net>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, eric.dumazet@gmail.com,
        sergei.shtylyov@cogentembedded.com, cwang@twopensource.com,
        Antonio Quartulli <a@unstable.cc>,
        Antonio Quartulli <antonio@open-mesh.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:43516 "EHLO s2.neomailbox.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934905AbcJXMxB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 08:53:01 -0400
In-Reply-To: <20140724.180708.1613882522982264262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The user may want to use only some bits of the skb mark in
his skbedit rules because the remaining part might be used by
something else.

Introduce the "mask" parameter to the skbedit actor in order
to implement such functionality.

When the mask is specified, only those bits selected by the
latter are altered really changed by the actor, while the
rest is left untouched.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

---

This patch has been sleeping for a while although it was basically ready for
being merged. I hope it can still be merged.

Checkpatch is now complaining about this:

CHECK: Comparison to NULL could be written "tb[TCA_SKBEDIT_MASK]"
#112: FILE: net/sched/act_skbedit.c:114:
+	if (tb[TCA_SKBEDIT_MASK] != NULL) {

However the surrounding code does not use this codestyle. Please, let me know if
I should rearrange this line.


Thanks!



Changes from v3:
- rebase on top of net-next
- fix syntax error in if statement

Changes from v2:
- remove useless comments
- use nla_put_u32() and fix typ0

Changes from v1:
- use '&=' tcf_skbedit() to clean the mark
- extend tcf_skbedit_dump() in order to send the mask as well

 include/net/tc_act/tc_skbedit.h        |  1 +
 include/uapi/linux/tc_act/tc_skbedit.h |  2 ++
 net/sched/act_skbedit.c                | 21 ++++++++++++++++++---
 3 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
index 5767e9dbcf92..19cd3d345804 100644
--- a/include/net/tc_act/tc_skbedit.h
+++ b/include/net/tc_act/tc_skbedit.h
@@ -27,6 +27,7 @@ struct tcf_skbedit {
 	u32		flags;
 	u32		priority;
 	u32		mark;
+	u32		mask;
 	u16		queue_mapping;
 	u16		ptype;
 };
diff --git a/include/uapi/linux/tc_act/tc_skbedit.h b/include/uapi/linux/tc_act/tc_skbedit.h
index a4d00c608d8f..2884425738ce 100644
--- a/include/uapi/linux/tc_act/tc_skbedit.h
+++ b/include/uapi/linux/tc_act/tc_skbedit.h
@@ -28,6 +28,7 @@
 #define SKBEDIT_F_QUEUE_MAPPING		0x2
 #define SKBEDIT_F_MARK			0x4
 #define SKBEDIT_F_PTYPE			0x8
+#define SKBEDIT_F_MASK			0x10
 
 struct tc_skbedit {
 	tc_gen;
@@ -42,6 +43,7 @@ enum {
 	TCA_SKBEDIT_MARK,
 	TCA_SKBEDIT_PAD,
 	TCA_SKBEDIT_PTYPE,
+	TCA_SKBEDIT_MASK,
 	__TCA_SKBEDIT_MAX
 };
 #define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index a133dcb82132..024f3a3afeff 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -46,8 +46,10 @@ static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
 	if (d->flags & SKBEDIT_F_QUEUE_MAPPING &&
 	    skb->dev->real_num_tx_queues > d->queue_mapping)
 		skb_set_queue_mapping(skb, d->queue_mapping);
-	if (d->flags & SKBEDIT_F_MARK)
-		skb->mark = d->mark;
+	if (d->flags & SKBEDIT_F_MARK) {
+		skb->mark &= ~d->mask;
+		skb->mark |= d->mark & d->mask;
+	}
 	if (d->flags & SKBEDIT_F_PTYPE)
 		skb->pkt_type = d->ptype;
 
@@ -61,6 +63,7 @@ static const struct nla_policy skbedit_policy[TCA_SKBEDIT_MAX + 1] = {
 	[TCA_SKBEDIT_QUEUE_MAPPING]	= { .len = sizeof(u16) },
 	[TCA_SKBEDIT_MARK]		= { .len = sizeof(u32) },
 	[TCA_SKBEDIT_PTYPE]		= { .len = sizeof(u16) },
+	[TCA_SKBEDIT_MASK]		= { .len = sizeof(u32) },
 };
 
 static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
@@ -71,7 +74,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	struct nlattr *tb[TCA_SKBEDIT_MAX + 1];
 	struct tc_skbedit *parm;
 	struct tcf_skbedit *d;
-	u32 flags = 0, *priority = NULL, *mark = NULL;
+	u32 flags = 0, *priority = NULL, *mark = NULL, *mask = NULL;
 	u16 *queue_mapping = NULL, *ptype = NULL;
 	bool exists = false;
 	int ret = 0, err;
@@ -108,6 +111,11 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		mark = nla_data(tb[TCA_SKBEDIT_MARK]);
 	}
 
+	if (tb[TCA_SKBEDIT_MASK] != NULL) {
+		flags |= SKBEDIT_F_MASK;
+		mask = nla_data(tb[TCA_SKBEDIT_MASK]);
+	}
+
 	parm = nla_data(tb[TCA_SKBEDIT_PARMS]);
 
 	exists = tcf_hash_check(tn, parm->index, a, bind);
@@ -145,6 +153,10 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		d->mark = *mark;
 	if (flags & SKBEDIT_F_PTYPE)
 		d->ptype = *ptype;
+	/* default behaviour is to use all the bits */
+	d->mask = 0xffffffff;
+	if (flags & SKBEDIT_F_MASK)
+		d->mask = *mask;
 
 	d->tcf_action = parm->action;
 
@@ -182,6 +194,9 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 	if ((d->flags & SKBEDIT_F_PTYPE) &&
 	    nla_put_u16(skb, TCA_SKBEDIT_PTYPE, d->ptype))
 		goto nla_put_failure;
+	if ((d->flags & SKBEDIT_F_MASK) &&
+	    nla_put_u32(skb, TCA_SKBEDIT_MASK, d->mask))
+		goto nla_put_failure;
 
 	tcf_tm_dump(&t, &d->tcf_tm);
 	if (nla_put_64bit(skb, TCA_SKBEDIT_TM, sizeof(t), &t, TCA_SKBEDIT_PAD))
-- 
2.10.1
