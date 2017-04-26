From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v9 3/3] net sched actions: add time filter for action dumping
Date: Wed, 26 Apr 2017 08:42:18 -0400
Message-ID: <1493210538-21716-4-git-send-email-jhs@emojatatu.com>
References: <1493210538-21716-1-git-send-email-jhs@emojatatu.com>
Cc: jiri@resnulli.us, xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, netdev@vger.kernel.org,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:32905 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2999880AbdDZMmx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 08:42:53 -0400
Received: by mail-it0-f68.google.com with SMTP id z67so334388itb.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 05:42:52 -0700 (PDT)
In-Reply-To: <1493210538-21716-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

This adds support for filtering based on time since last used.
When we are dumping a large number of actions it is useful to
have the option of filtering based on when the action was last
used to reduce the amount of data crossing to user space.

With this patch the user space app sets the TCA_ROOT_TIME_DELTA
attribute with the value in milliseconds with "time of interest
since now".  The kernel converts this to jiffies and does the
filtering comparison matching entries that have seen activity
since then and returns them to user space.
Old kernels and old tc continue to work in legacy mode since
they dont specify this attribute.

Some example (we have 400 actions bound to 400 filters); at
installation time using  hacked tc which sets the time of
interest to 120 seconds:
prompt$ hackedtc actions ls action gact | grep index | wc -l
400

go get some coffee and  wait for > 120 seconds and try again:

prompt$ hackedtc actions ls action gact | grep index | wc -l
0

Lets see a filter bound to one of these actions:
..
filter pref 10 u32
filter pref 10 u32 fh 800: ht divisor 1
filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 2 success 1)
  match 7f000002/ffffffff at 12 (success 1 )
    action order 1: gact action pass
     random type none pass val 0
     index 23 ref 2 bind 1 installed 1145 sec used 802 sec
    Action statistics:
    Sent 84 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
    backlog 0b 0p requeues 0
....

that coffee took long, no? It was good.

Now lets ping -c 1 127.0.0.2, then run the actions again:

prompt$ hackedtc actions ls action gact | grep index | wc -l
1

More details please:

prompt$ hackedtc -s actions ls action gact

    action order 0: gact action pass
     random type none pass val 0
     index 23 ref 2 bind 1 installed 1270 sec used 30 sec
    Action statistics:
    Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
    backlog 0b 0p requeues 0

And the filter?

filter pref 10 u32
filter pref 10 u32 fh 800: ht divisor 1
filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 4 success 2)
  match 7f000002/ffffffff at 12 (success 2 )
    action order 1: gact action pass
     random type none pass val 0
     index 23 ref 2 bind 1 installed 1324 sec used 84 sec
    Action statistics:
    Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
    backlog 0b 0p requeues 0

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/uapi/linux/rtnetlink.h |  1 +
 net/sched/act_api.c            | 22 ++++++++++++++++++++--
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 20c86c0..d89b358 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -681,6 +681,7 @@ enum {
 #define TCA_ACT_TAB TCA_ROOT_TAB
 	TCA_ROOT_FLAGS,
 	TCA_ROOT_COUNT,
+	TCA_ROOT_TIME_DELTA, /* in msecs */
 	__TCA_ROOT_MAX,
 #define	TCA_ROOT_MAX (__TCA_ROOT_MAX - 1)
 };
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index ccc333e..7eb4f7a 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -84,6 +84,7 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 {
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	u32 act_flags = cb->args[2];
+	unsigned long jiffy_since = cb->args[3];
 	struct nlattr *nest;
 
 	spin_lock_bh(&hinfo->lock);
@@ -101,6 +102,11 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 			if (index < s_i)
 				continue;
 
+			if (jiffy_since &&
+			    time_after(jiffy_since,
+				       (unsigned long)p->tcfa_tm.lastuse))
+				continue;
+
 			nest = nla_nest_start(skb, n_i);
 			if (nest == NULL)
 				goto nla_put_failure;
@@ -118,9 +124,11 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 		}
 	}
 done:
+	if (index > 0)
+		cb->args[0] = index + 1;
+
 	spin_unlock_bh(&hinfo->lock);
 	if (n_i) {
-		cb->args[0] += n_i;
 		if (act_flags & TCA_FLAG_LARGE_DUMP_ON)
 			cb->args[1] = n_i;
 	}
@@ -1033,7 +1041,8 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
 }
 
 static const struct nla_policy tcaa_policy[TCA_ROOT_MAX + 1] = {
-	[TCA_ROOT_FLAGS]      = { .type = NLA_U32 },
+	[TCA_ROOT_FLAGS]           = { .type = NLA_U32 },
+	[TCA_ROOT_TIME_DELTA]      = { .type = NLA_U32 },
 };
 
 static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
@@ -1134,7 +1143,9 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	struct tcamsg *t = (struct tcamsg *) nlmsg_data(cb->nlh);
 	struct nlattr *count_attr = NULL;
 	struct nlattr *tb[TCA_ROOT_MAX + 1];
+	unsigned long jiffy_since = 0;
 	struct nlattr *kind = NULL;
+	u32 msecs_since = 0;
 	u32 act_flags = 0;
 	u32 act_count = 0;
 
@@ -1159,12 +1170,19 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	if (act_flags && !tca_flags_valid(act_flags))
 		return -EINVAL;
 
+	if (tb[TCA_ROOT_TIME_DELTA])
+		msecs_since = nla_get_u32(tb[TCA_ROOT_TIME_DELTA]);
+
 	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			cb->nlh->nlmsg_type, sizeof(*t), 0);
 	if (!nlh)
 		goto out_module_put;
 
+	if (msecs_since)
+		jiffy_since = jiffies - msecs_to_jiffies(msecs_since);
+
 	cb->args[2] = act_flags;
+	cb->args[3] = jiffy_since;
 	t = nlmsg_data(nlh);
 	t->tca_family = AF_UNSPEC;
 	t->tca__pad1 = 0;
-- 
1.9.1
