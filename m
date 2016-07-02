From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 net-next 2/3] net sched actions: skbedit add support for mod-ing skb pkt_type
Date: Sat,  2 Jul 2016 06:43:15 -0400
Message-ID: <1467456196-25712-2-git-send-email-jhs@emojatatu.com>
References: <1467456196-25712-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, fw@strlen.de,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33436 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbcGBKnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 06:43:31 -0400
Received: by mail-it0-f66.google.com with SMTP id y93so4627530ita.0
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 03:43:30 -0700 (PDT)
In-Reply-To: <1467456196-25712-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Extremely useful for setting packet type to host so i dont
have to modify the dst mac address using pedit (which requires
that i know the mac address)

Example usage:
tc filter add dev eth0 parent ffff: protocol ip pref 9 u32 \
match ip src 5.5.5.5/32 \
flowid 1:5 action skbedit ptype host

This will tag all packets incoming from 5.5.5.5 with type
PACKET_HOST

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/tc_act/tc_skbedit.h        | 10 +++++-----
 include/uapi/linux/tc_act/tc_skbedit.h |  2 ++
 net/sched/act_skbedit.c                | 18 +++++++++++++++++-
 3 files changed, 24 insertions(+), 6 deletions(-)

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
index 53d1486..1c4c924 100644
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
 	bool exists = false;
 	int ret = 0, err;
 
@@ -92,6 +95,13 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		queue_mapping = nla_data(tb[TCA_SKBEDIT_QUEUE_MAPPING]);
 	}
 
+	if (tb[TCA_SKBEDIT_PTYPE] != NULL) {
+		ptype = nla_data(tb[TCA_SKBEDIT_PTYPE]);
+		if (!skb_pkt_type_ok(*ptype))
+			return -EINVAL;
+		flags |= SKBEDIT_F_PTYPE;
+	}
+
 	if (tb[TCA_SKBEDIT_MARK] != NULL) {
 		flags |= SKBEDIT_F_MARK;
 		mark = nla_data(tb[TCA_SKBEDIT_MARK]);
@@ -132,6 +142,8 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		d->queue_mapping = *queue_mapping;
 	if (flags & SKBEDIT_F_MARK)
 		d->mark = *mark;
+	if (flags & SKBEDIT_F_PTYPE)
+		d->ptype = *ptype;
 
 	d->tcf_action = parm->action;
 
@@ -169,6 +181,10 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 	    nla_put(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
 		    &d->mark))
 		goto nla_put_failure;
+	if ((d->flags & SKBEDIT_F_PTYPE) &&
+	    nla_put(skb, TCA_SKBEDIT_PTYPE, sizeof(d->ptype),
+		    &d->ptype))
+		goto nla_put_failure;
 
 	tcf_tm_dump(&t, &d->tcf_tm);
 	if (nla_put_64bit(skb, TCA_SKBEDIT_TM, sizeof(t), &t, TCA_SKBEDIT_PAD))
-- 
1.9.1
