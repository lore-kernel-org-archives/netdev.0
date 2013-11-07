From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Using HTB over MultiQ
Date: Thu, 7 Nov 2013 07:17:32 -0800
Message-ID: <20131107151727.GA31116@nitbit.x32>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
 <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>
 <527BA63F.7040900@intel.com>
 <1383836068.9412.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <527BAC8E.1090005@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:46001 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618Ab3KGPSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 10:18:52 -0500
Received: by mail-oa0-f44.google.com with SMTP id i7so1144467oag.3
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 07:18:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <527BAC8E.1090005@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 07:06:54AM -0800, John Fastabend wrote:
> On 11/7/2013 6:54 AM, Eric Dumazet wrote:
> >On Thu, 2013-11-07 at 06:39 -0800, John Fastabend wrote:
> >
> >>
> >>With the multiq qdisc you could attach filter to the root qdisc and use
> >>skbedit to set the queue_mapping field,
> >>
> >>#tc filter add dev eth0 parent 1: protocol ip prio 1 u32 \
> >>	match ip dst 192.168.0.3 \
> >>	action skbedit queue_mapping 3
> >>
> >
> >Oh right, this is the way ;)
> >
> >I wonder if we can have 'action skbedit rxhash 34' ?
> >
> 
> Sure, it should easy enough.

I think this is all it would take I only compile tested this for now.
If its useful I could send out a real (tested) patch later today.

diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
index e103fe0..3951f7d 100644
--- a/include/net/tc_act/tc_skbedit.h
+++ b/include/net/tc_act/tc_skbedit.h
@@ -27,6 +27,7 @@ struct tcf_skbedit {
 	u32			flags;
 	u32     		priority;
 	u32     		mark;
+	u32			rxhash;
 	u16			queue_mapping;
 	/* XXX: 16-bit pad here? */
 };
diff --git a/include/uapi/linux/tc_act/tc_skbedit.h b/include/uapi/linux/tc_act/tc_skbedit.h
index 7a2e910..d5a1d55 100644
--- a/include/uapi/linux/tc_act/tc_skbedit.h
+++ b/include/uapi/linux/tc_act/tc_skbedit.h
@@ -27,6 +27,7 @@
 #define SKBEDIT_F_PRIORITY		0x1
 #define SKBEDIT_F_QUEUE_MAPPING		0x2
 #define SKBEDIT_F_MARK			0x4
+#define SKBEDIT_F_RXHASH		0x8
 
 struct tc_skbedit {
 	tc_gen;
@@ -39,6 +40,7 @@ enum {
 	TCA_SKBEDIT_PRIORITY,
 	TCA_SKBEDIT_QUEUE_MAPPING,
 	TCA_SKBEDIT_MARK,
+	TCA_SKBEDIT_RXHASH,
 	__TCA_SKBEDIT_MAX
 };
 #define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index cb42211..f6b6820 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -55,6 +55,8 @@ static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
 		skb_set_queue_mapping(skb, d->queue_mapping);
 	if (d->flags & SKBEDIT_F_MARK)
 		skb->mark = d->mark;
+	if (d->flags & SKBEDIT_F_RXHASH)
+		skb->rxhash = d->rxhash;
 
 	spin_unlock(&d->tcf_lock);
 	return d->tcf_action;
@@ -65,6 +67,7 @@ static const struct nla_policy skbedit_policy[TCA_SKBEDIT_MAX + 1] = {
 	[TCA_SKBEDIT_PRIORITY]		= { .len = sizeof(u32) },
 	[TCA_SKBEDIT_QUEUE_MAPPING]	= { .len = sizeof(u16) },
 	[TCA_SKBEDIT_MARK]		= { .len = sizeof(u32) },
+	[TCA_SKBEDIT_RXHASH]		= { .len = sizeof(u32) },
 };
 
 static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
@@ -75,7 +78,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	struct tc_skbedit *parm;
 	struct tcf_skbedit *d;
 	struct tcf_common *pc;
-	u32 flags = 0, *priority = NULL, *mark = NULL;
+	u32 flags = 0, *priority = NULL, *mark = NULL, *rxhash = NULL;
 	u16 *queue_mapping = NULL;
 	int ret = 0, err;
 
@@ -104,6 +107,11 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		mark = nla_data(tb[TCA_SKBEDIT_MARK]);
 	}
 
+	if (tb[TCA_SKBEDIT_RXHASH] != NULL) {
+		flags |= SKBEDIT_F_RXHASH;
+		rxhash = nla_data(tb[TCA_SKBEDIT_RXHASH]);
+	}
+
 	if (!flags)
 		return -EINVAL;
 
@@ -135,6 +143,8 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		d->queue_mapping = *queue_mapping;
 	if (flags & SKBEDIT_F_MARK)
 		d->mark = *mark;
+	if (flags & SKBEDIT_F_RXHASH)
+		d->rxhash = *rxhash;
 
 	d->tcf_action = parm->action;
 
@@ -181,6 +191,9 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 	    nla_put(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
 		    &d->mark))
 		goto nla_put_failure;
+	if ((d->flags & SKBEDIT_F_RXHASH) &&
+	    nla_put(skb, TCA_SKBEDIT_RXHASH, sizeof(d->rxhash),
+		    &d->rxhash))
 	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
