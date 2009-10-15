From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH] pkt_sched: skbedit add support for setting mark
Date: Thu, 15 Oct 2009 09:09:18 -0400
Message-ID: <1255612159.5033.1.camel@dogo.mojatatu.com>
References: <1255523114.21940.14.camel@dogo.mojatatu.com>
	 <20091014.150810.264613954.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-mKSjvrOz3lm1859dVr0i"
Cc: denys@visp.net.lb, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:50472 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756124AbZJONN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 09:13:29 -0400
Received: by qw-out-2122.google.com with SMTP id 9so255399qwb.37
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 06:12:22 -0700 (PDT)
In-Reply-To: <20091014.150810.264613954.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mKSjvrOz3lm1859dVr0i
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2009-10-14 at 15:08 -0700, David Miller wrote:

> This patch doesn't apply.

Ok, Ive tested this on a separate machine - it applies and compiles.

cheers,
jamal

--=-mKSjvrOz3lm1859dVr0i
Content-Disposition: attachment; filename=skbe-mark
Content-Type: text/plain; name=skbe-mark; charset=utf-8
Content-Transfer-Encoding: 7bit

commit 6da17c574694ad4c02268dd64e85792051946aab
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Wed Oct 14 08:16:23 2009 -0400

    [PATCH] pkt_sched: skbedit add support for setting mark
    
    This adds support for setting the skb mark.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/include/linux/tc_act/tc_skbedit.h b/include/linux/tc_act/tc_skbedit.h
index a14e461..7a2e910 100644
--- a/include/linux/tc_act/tc_skbedit.h
+++ b/include/linux/tc_act/tc_skbedit.h
@@ -26,6 +26,7 @@
 
 #define SKBEDIT_F_PRIORITY		0x1
 #define SKBEDIT_F_QUEUE_MAPPING		0x2
+#define SKBEDIT_F_MARK			0x4
 
 struct tc_skbedit {
 	tc_gen;
@@ -37,6 +38,7 @@ enum {
 	TCA_SKBEDIT_PARMS,
 	TCA_SKBEDIT_PRIORITY,
 	TCA_SKBEDIT_QUEUE_MAPPING,
+	TCA_SKBEDIT_MARK,
 	__TCA_SKBEDIT_MAX
 };
 #define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
index 6abb3ed..e103fe0 100644
--- a/include/net/tc_act/tc_skbedit.h
+++ b/include/net/tc_act/tc_skbedit.h
@@ -26,7 +26,9 @@ struct tcf_skbedit {
 	struct tcf_common	common;
 	u32			flags;
 	u32     		priority;
+	u32     		mark;
 	u16			queue_mapping;
+	/* XXX: 16-bit pad here? */
 };
 #define to_skbedit(pc) \
 	container_of(pc, struct tcf_skbedit, common)
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 4ab916b..e9607fe 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -54,6 +54,8 @@ static int tcf_skbedit(struct sk_buff *skb, struct tc_action *a,
 	if (d->flags & SKBEDIT_F_QUEUE_MAPPING &&
 	    skb->dev->real_num_tx_queues > d->queue_mapping)
 		skb_set_queue_mapping(skb, d->queue_mapping);
+	if (d->flags & SKBEDIT_F_MARK)
+		skb->mark = d->mark;
 
 	spin_unlock(&d->tcf_lock);
 	return d->tcf_action;
@@ -63,6 +65,7 @@ static const struct nla_policy skbedit_policy[TCA_SKBEDIT_MAX + 1] = {
 	[TCA_SKBEDIT_PARMS]		= { .len = sizeof(struct tc_skbedit) },
 	[TCA_SKBEDIT_PRIORITY]		= { .len = sizeof(u32) },
 	[TCA_SKBEDIT_QUEUE_MAPPING]	= { .len = sizeof(u16) },
+	[TCA_SKBEDIT_MARK]		= { .len = sizeof(u32) },
 };
 
 static int tcf_skbedit_init(struct nlattr *nla, struct nlattr *est,
@@ -72,7 +75,7 @@ static int tcf_skbedit_init(struct nlattr *nla, struct nlattr *est,
 	struct tc_skbedit *parm;
 	struct tcf_skbedit *d;
 	struct tcf_common *pc;
-	u32 flags = 0, *priority = NULL;
+	u32 flags = 0, *priority = NULL, *mark = NULL;
 	u16 *queue_mapping = NULL;
 	int ret = 0, err;
 
@@ -95,6 +98,12 @@ static int tcf_skbedit_init(struct nlattr *nla, struct nlattr *est,
 		flags |= SKBEDIT_F_QUEUE_MAPPING;
 		queue_mapping = nla_data(tb[TCA_SKBEDIT_QUEUE_MAPPING]);
 	}
+
+	if (tb[TCA_SKBEDIT_MARK] != NULL) {
+		flags |= SKBEDIT_F_MARK;
+		mark = nla_data(tb[TCA_SKBEDIT_MARK]);
+	}
+
 	if (!flags)
 		return -EINVAL;
 
@@ -124,6 +133,9 @@ static int tcf_skbedit_init(struct nlattr *nla, struct nlattr *est,
 		d->priority = *priority;
 	if (flags & SKBEDIT_F_QUEUE_MAPPING)
 		d->queue_mapping = *queue_mapping;
+	if (flags & SKBEDIT_F_MARK)
+		d->mark = *mark;
+
 	d->tcf_action = parm->action;
 
 	spin_unlock_bh(&d->tcf_lock);
@@ -161,6 +173,9 @@ static inline int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 	if (d->flags & SKBEDIT_F_QUEUE_MAPPING)
 		NLA_PUT(skb, TCA_SKBEDIT_QUEUE_MAPPING,
 			sizeof(d->queue_mapping), &d->queue_mapping);
+	if (d->flags & SKBEDIT_F_MARK)
+		NLA_PUT(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
+			&d->mark);
 	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);

--=-mKSjvrOz3lm1859dVr0i--

