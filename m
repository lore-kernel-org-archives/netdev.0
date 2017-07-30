From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v12 4/4] net sched actions: add time filter for action dumping
Date: Sun, 30 Jul 2017 13:24:52 -0400
Message-ID: <1501435492-28301-5-git-send-email-jhs@emojatatu.com>
References: <1501435492-28301-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, horms@verge.net.au, dsahern@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34182 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754249AbdG3RZI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 13:25:08 -0400
Received: by mail-io0-f196.google.com with SMTP id m88so12989429iod.1
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 10:25:07 -0700 (PDT)
In-Reply-To: <1501435492-28301-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

This patch adds support for filtering based on time since last used.
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
installation time. Using updated when tc setting the time of
interest to 120 seconds earlier (we see 400 actions):
prompt$ hackedtc actions ls action gact since 120000| grep index | wc -l
400

go get some coffee and wait for > 120 seconds and try again:

prompt$ hackedtc actions ls action gact since 120000 | grep index | wc -l
0

Lets see a filter bound to one of these actions:
....
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
prompt$ hackedtc actions ls action gact since 120 | grep index | wc -l
1

More details please:
prompt$ hackedtc -s actions ls action gact since 120000

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
 net/sched/act_api.c            | 21 ++++++++++++++++++++-
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index bfa80a6..dab7dad 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -691,6 +691,7 @@ enum {
 #define TCAA_MAX TCA_ROOT_TAB
 	TCA_ROOT_FLAGS,
 	TCA_ROOT_COUNT,
+	TCA_ROOT_TIME_DELTA, /* in msecs */
 	__TCA_ROOT_MAX,
 #define	TCA_ROOT_MAX (__TCA_ROOT_MAX - 1)
 };
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index d53653a..f19b118 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -111,6 +111,7 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 {
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	u32 act_flags = cb->args[2];
+	unsigned long jiffy_since = cb->args[3];
 	struct nlattr *nest;
 
 	spin_lock_bh(&hinfo->lock);
@@ -128,6 +129,11 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
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
@@ -145,9 +151,11 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 		}
 	}
 done:
+	if (index >= 0)
+		cb->args[0] = index + 1;
+
 	spin_unlock_bh(&hinfo->lock);
 	if (n_i) {
-		cb->args[0] += n_i;
 		if (act_flags & TCA_FLAG_LARGE_DUMP_ON)
 			cb->args[1] = n_i;
 	}
@@ -1077,6 +1085,7 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
 static const struct nla_policy tcaa_policy[TCA_ROOT_MAX + 1] = {
 	[TCA_ROOT_FLAGS] = { .type = NLA_BITFIELD32,
 			     .validation_data = &tcaa_root_flags_allowed },
+	[TCA_ROOT_TIME_DELTA]      = { .type = NLA_U32 },
 };
 
 static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
@@ -1166,8 +1175,10 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	struct tcamsg *t = (struct tcamsg *) nlmsg_data(cb->nlh);
 	struct nlattr *tb[TCA_ROOT_MAX + 1];
 	struct nlattr *count_attr = NULL;
+	unsigned long jiffy_since = 0;
 	struct nlattr *kind = NULL;
 	struct nla_bitfield32 bf;
+	u32 msecs_since = 0;
 	u32 act_count = 0;
 
 	ret = nlmsg_parse(cb->nlh, sizeof(struct tcamsg), tb, TCA_ROOT_MAX,
@@ -1191,15 +1202,23 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 		cb->args[2] = bf.value;
 	}
 
+	if (tb[TCA_ROOT_TIME_DELTA]) {
+		msecs_since = nla_get_u32(tb[TCA_ROOT_TIME_DELTA]);
+	}
+
 	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			cb->nlh->nlmsg_type, sizeof(*t), 0);
 	if (!nlh)
 		goto out_module_put;
 
+	if (msecs_since)
+		jiffy_since = jiffies - msecs_to_jiffies(msecs_since);
+
 	t = nlmsg_data(nlh);
 	t->tca_family = AF_UNSPEC;
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
+	cb->args[3] = jiffy_since;
 	count_attr = nla_reserve(skb, TCA_ROOT_COUNT, sizeof(u32));
 	if (!count_attr)
 		goto out_module_put;
-- 
1.9.1
