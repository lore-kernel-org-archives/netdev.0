From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6 3/3] net sched actions: add time filter for
 action dumping
Date: Fri, 21 Apr 2017 15:13:47 +0200
Message-ID: <20170421131347.GD1874@nanopsycho.orion>
References: <1492772132-16559-1-git-send-email-jhs@emojatatu.com>
 <1492772132-16559-4-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34166 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1039487AbdDUNNu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 09:13:50 -0400
Received: by mail-wm0-f67.google.com with SMTP id z129so4838897wmb.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 06:13:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492772132-16559-4-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 21, 2017 at 12:55:32PM CEST, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>This adds support for filtering based on time since last used.
>When we are dumping a large number of actions it is useful to
>have the option of filtering based on when the action was last
>used to reduce the amount of data crossing to user space.
>
>With this patch the user space app sets the TCA_ROOT_TIME_DELTA
>attribute with the value in milliseconds with "time of interest
>since now".  The kernel converts this to jiffies and does the
>filtering comparison matching entries that have seen activity
>since then and returns them to user space.
>Old kernels and old tc continue to work in legacy mode since
>they dont specify this attribute.
>
>Some example (we have 400 actions bound to 400 filters); at
>installation time using  hacked tc which sets the time of
>interest to 120 seconds:
>
>prompt$ hackedtc actions ls action gact | grep index | wc -l
>400
>
>go get some coffee and  wait for > 120 seconds and try again:
>
>prompt$ hackedtc actions ls action gact | grep index | wc -l
>0
>
>Lets see a filter bound to one of these actions:
>..
>filter pref 10 u32
>filter pref 10 u32 fh 800: ht divisor 1
>filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 2 success 1)
>  match 7f000002/ffffffff at 12 (success 1 )
>    action order 1: gact action pass
>     random type none pass val 0
>     index 23 ref 2 bind 1 installed 1145 sec used 802 sec
>    Action statistics:
>    Sent 84 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
>    backlog 0b 0p requeues 0
>....
>
>that coffee took long, no? It was good.
>
>Now lets ping -c 1 127.0.0.2, then run the actions again:
>
>prompt$ hackedtc actions ls action gact | grep index | wc -l
>1
>
>More details please:
>
>prompt$ hackedtc -s actions ls action gact
>
>    action order 0: gact action pass
>     random type none pass val 0
>     index 23 ref 2 bind 1 installed 1270 sec used 30 sec
>    Action statistics:
>    Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>    backlog 0b 0p requeues 0
>
>And the filter?
>
>filter pref 10 u32
>filter pref 10 u32 fh 800: ht divisor 1
>filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 4 success 2)
>  match 7f000002/ffffffff at 12 (success 2 )
>    action order 1: gact action pass
>     random type none pass val 0
>     index 23 ref 2 bind 1 installed 1324 sec used 84 sec
>    Action statistics:
>    Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>    backlog 0b 0p requeues 0
>
>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>---
> include/uapi/linux/rtnetlink.h |  1 +
> net/sched/act_api.c            | 20 +++++++++++++++++++-
> 2 files changed, 20 insertions(+), 1 deletion(-)
>
>diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
>index 09e7b22d..54db916 100644
>--- a/include/uapi/linux/rtnetlink.h
>+++ b/include/uapi/linux/rtnetlink.h
>@@ -681,6 +681,7 @@ enum {
> #define TCA_ACT_TAB TCA_ROOT_TAB
> 	TCA_ROOT_FLAGS,
> 	TCA_ROOT_COUNT,
>+	TCA_ROOT_TIME_DELTA, /* in msecs */
> 	__TCA_ROOT_MAX,
> #define	TCA_ROOT_MAX (__TCA_ROOT_MAX - 1)
> };
>diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>index cfb3548..b97d5f0 100644
>--- a/net/sched/act_api.c
>+++ b/net/sched/act_api.c
>@@ -84,6 +84,7 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
> {
> 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
> 	u32 act_flags = cb->args[2];
>+	unsigned long jiffy_since = cb->args[3];
> 	struct nlattr *nest;
> 
> 	spin_lock_bh(&hinfo->lock);
>@@ -101,6 +102,11 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
> 			if (index < s_i)
> 				continue;
> 
>+			if (jiffy_since &&
>+			    time_after(jiffy_since,
>+				       (unsigned long)p->tcfa_tm.lastuse))
>+				continue;
>+
> 			nest = nla_nest_start(skb, n_i);
> 			if (nest == NULL)
> 				goto nla_put_failure;
>@@ -118,9 +124,11 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
> 		}
> 	}
> done:
>+	if (index > 0)
>+		cb->args[0] = index + 1;
>+
> 	spin_unlock_bh(&hinfo->lock);
> 	if (n_i) {
>-		cb->args[0] += n_i;
> 		if (act_flags & TCA_FLAG_LARGE_DUMP_ON)
> 			cb->args[1] = n_i;
> 	}
>@@ -1000,6 +1008,7 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
> 
> static const struct nla_policy tcaa_policy[TCA_ROOT_MAX + 1] = {
> 	[TCA_ROOT_FLAGS]      = { .type = NLA_U32 },
>+	[TCA_ROOT_TIME_DELTA]      = { .type = NLA_U32 },

Align these assignments please.
