From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCHv3] skbedit: allow the user to specify bitmask for mark
Date: Wed, 23 Jul 2014 21:13:35 +0200
Message-ID: <1406142815-25537-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	eric.dumazet@gmail.com, cwang@twopensource.com,
	Antonio Quartulli <antonio@open-mesh.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:47140 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932514AbaGWTOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 15:14:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

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
index 0df9a0d..a385c68 100644
--- a/include/net/tc_act/tc_skbedit.h
+++ b/include/net/tc_act/tc_skbedit.h
@@ -26,6 +26,7 @@ struct tcf_skbedit {
 	u32			flags;
 	u32     		priority;
 	u32     		mark;
+	u32			mask;
 	u16			queue_mapping;
 	/* XXX: 16-bit pad here? */
 };
diff --git a/include/uapi/linux/tc_act/tc_skbedit.h b/include/uapi/linux/tc_act/tc_skbedit.h
index 7a2e910..c7c8c5f 100644
--- a/include/uapi/linux/tc_act/tc_skbedit.h
+++ b/include/uapi/linux/tc_act/tc_skbedit.h
@@ -27,6 +27,7 @@
 #define SKBEDIT_F_PRIORITY		0x1
 #define SKBEDIT_F_QUEUE_MAPPING		0x2
 #define SKBEDIT_F_MARK			0x4
+#define SKBEDIT_F_MASK			0x8
 
 struct tc_skbedit {
 	tc_gen;
@@ -39,6 +40,7 @@ enum {
 	TCA_SKBEDIT_PRIORITY,
 	TCA_SKBEDIT_QUEUE_MAPPING,
 	TCA_SKBEDIT_MARK,
+	TCA_SKBEDIT_MASK,
 	__TCA_SKBEDIT_MAX
 };
 #define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index fcfeeaf..4409bdb 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -43,8 +43,10 @@ static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
 	if (d->flags & SKBEDIT_F_QUEUE_MAPPING &&
 	    skb->dev->real_num_tx_queues > d->queue_mapping)
 		skb_set_queue_mapping(skb, d->queue_mapping);
-	if (d->flags & SKBEDIT_F_MARK)
-		skb->mark = d->mark;
+	if (d->flags & SKBEDIT_F_MARK) {
+		skb->mark &= ~d->mask;
+		skb->mark |= d->mark & d->mask;
+	}
 
 	spin_unlock(&d->tcf_lock);
 	return d->tcf_action;
@@ -55,6 +57,7 @@ static const struct nla_policy skbedit_policy[TCA_SKBEDIT_MAX + 1] = {
 	[TCA_SKBEDIT_PRIORITY]		= { .len = sizeof(u32) },
 	[TCA_SKBEDIT_QUEUE_MAPPING]	= { .len = sizeof(u16) },
 	[TCA_SKBEDIT_MARK]		= { .len = sizeof(u32) },
+	[TCA_SKBEDIT_MASK]		= { .len = sizeof(u32) },
 };
 
 static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
@@ -64,7 +67,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	struct nlattr *tb[TCA_SKBEDIT_MAX + 1];
 	struct tc_skbedit *parm;
 	struct tcf_skbedit *d;
-	u32 flags = 0, *priority = NULL, *mark = NULL;
+	u32 flags = 0, *priority = NULL, *mark = NULL, *mask = NULL;
 	u16 *queue_mapping = NULL;
 	int ret = 0, err;
 
@@ -93,6 +96,11 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		mark = nla_data(tb[TCA_SKBEDIT_MARK]);
 	}
 
+	if (tb[TCA_SKBEDIT_MASK] != NULL) {
+		flags |= SKBEDIT_F_MASK;
+		mask = nla_data(tb[TCA_SKBEDIT_MASK]);
+	}
+
 	if (!flags)
 		return -EINVAL;
 
@@ -123,6 +131,10 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		d->queue_mapping = *queue_mapping;
 	if (flags & SKBEDIT_F_MARK)
 		d->mark = *mark;
+	/* default behaviour is to use all the bits */
+	d->mask = 0xffffffff;
+	if (flags & SKBEDIT_F_MASK)
+		d->mask = *mask;
 
 	d->tcf_action = parm->action;
 
@@ -160,6 +172,9 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 	    nla_put(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
 		    &d->mark))
 		goto nla_put_failure;
+	if ((d->flags & SKBEDIT_F_MASK) &&
+	    nla_put_u32(skb, TCA_SKBEDIT_MASK, d->mask);
+		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
-- 
1.8.5.5
