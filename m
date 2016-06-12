From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 1/1] net sched actions: skbedit add support for mod-ing skb pkt_type
Date: Sun, 12 Jun 2016 17:12:22 -0400
Message-ID: <1465765942-24679-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	daniel@iogearbox.net, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35504 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045AbcFLVMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 17:12:35 -0400
Received: by mail-io0-f194.google.com with SMTP id n127so14658741iof.2
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 14:12:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Extremely useful for setting packet type to host so i dont
have to modify the dst mac address using pedit (which requires
that i know the mac address)

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/tc_act/tc_skbedit.h        | 10 +++++-----
 include/uapi/linux/tc_act/tc_skbedit.h |  2 ++
 net/sched/act_skbedit.c                | 17 ++++++++++++++++-
 3 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
index b496d5a..d01a5d4 100644
--- a/include/net/tc_act/tc_skbedit.h
+++ b/include/net/tc_act/tc_skbedit.h
@@ -24,11 +24,11 @@
 
 struct tcf_skbedit {
 	struct tcf_common	common;
-	u32			flags;
-	u32     		priority;
-	u32     		mark;
-	u16			queue_mapping;
-	/* XXX: 16-bit pad here? */
+	u32		flags;
+	u32		priority;
+	u32		mark;
+	u16		queue_mapping;
+	u16		ptype;
 };
 #define to_skbedit(a) \
 	container_of(a->priv, struct tcf_skbedit, common)
diff --git a/include/uapi/linux/tc_act/tc_skbedit.h b/include/uapi/linux/tc_act/tc_skbedit.h
index fecb5cc..a4d00c6 100644
--- a/include/uapi/linux/tc_act/tc_skbedit.h
+++ b/include/uapi/linux/tc_act/tc_skbedit.h
@@ -27,6 +27,7 @@
 #define SKBEDIT_F_PRIORITY		0x1
 #define SKBEDIT_F_QUEUE_MAPPING		0x2
 #define SKBEDIT_F_MARK			0x4
+#define SKBEDIT_F_PTYPE			0x8
 
 struct tc_skbedit {
 	tc_gen;
@@ -40,6 +41,7 @@ enum {
 	TCA_SKBEDIT_QUEUE_MAPPING,
 	TCA_SKBEDIT_MARK,
 	TCA_SKBEDIT_PAD,
+	TCA_SKBEDIT_PTYPE,
 	__TCA_SKBEDIT_MAX
 };
 #define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 8f235ff..8ab5d0c 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -47,6 +47,8 @@ static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
 		skb_set_queue_mapping(skb, d->queue_mapping);
 	if (d->flags & SKBEDIT_F_MARK)
 		skb->mark = d->mark;
+	if (d->flags & SKBEDIT_F_PTYPE)
+		skb->pkt_type = d->ptype;
 
 	spin_unlock(&d->tcf_lock);
 	return d->tcf_action;
@@ -57,6 +59,7 @@ static const struct nla_policy skbedit_policy[TCA_SKBEDIT_MAX + 1] = {
 	[TCA_SKBEDIT_PRIORITY]		= { .len = sizeof(u32) },
 	[TCA_SKBEDIT_QUEUE_MAPPING]	= { .len = sizeof(u16) },
 	[TCA_SKBEDIT_MARK]		= { .len = sizeof(u32) },
+	[TCA_SKBEDIT_PTYPE]		= { .len = sizeof(u16) },
 };
 
 static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
@@ -68,7 +71,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	struct tc_skbedit *parm;
 	struct tcf_skbedit *d;
 	u32 flags = 0, *priority = NULL, *mark = NULL;
-	u16 *queue_mapping = NULL;
+	u16 *queue_mapping = NULL, *ptype = NULL;
 	int ret = 0, err, aexists = 0;
 
 	if (nla == NULL)
@@ -91,6 +94,13 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		queue_mapping = nla_data(tb[TCA_SKBEDIT_QUEUE_MAPPING]);
 	}
 
+	if (tb[TCA_SKBEDIT_PTYPE] != NULL) {
+		flags |= SKBEDIT_F_PTYPE;
+		ptype = nla_data(tb[TCA_SKBEDIT_PTYPE]);
+		if (*ptype > PACKET_KERNEL)
+			return -EINVAL;
+	}
+
 	if (tb[TCA_SKBEDIT_MARK] != NULL) {
 		flags |= SKBEDIT_F_MARK;
 		mark = nla_data(tb[TCA_SKBEDIT_MARK]);
@@ -135,6 +145,8 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		d->queue_mapping = *queue_mapping;
 	if (flags & SKBEDIT_F_MARK)
 		d->mark = *mark;
+	if (flags & SKBEDIT_F_PTYPE)
+		d->ptype = *ptype;
 
 	d->tcf_action = parm->action;
 
@@ -171,6 +183,9 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 	if ((d->flags & SKBEDIT_F_MARK) &&
 	    nla_put(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
 		    &d->mark))
+	if ((d->flags & SKBEDIT_F_PTYPE) &&
+	    nla_put(skb, TCA_SKBEDIT_PTYPE, sizeof(d->ptype),
+		    &d->ptype))
 		goto nla_put_failure;
 
 	tcf_tm_dump(&t, &d->tcf_tm);
-- 
1.9.1
