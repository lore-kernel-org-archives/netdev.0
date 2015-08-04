From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] net_sched: act_bpf: remove spinlock in fast path
Date: Mon,  3 Aug 2015 22:09:12 -0700
Message-ID: <1438664952-24712-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36834 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbbHDFJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:09:20 -0400
Received: by pacgq8 with SMTP id gq8so41511491pac.3
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 22:09:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to act_gact/act_mirred, act_bpf can be lockless in packet processing.

Also similar to gact/mirred there is a race between prog->filter and
prog->tcf_action. Meaning that the program being replaced may use
previous default action if it happened to return TC_ACT_UNSPEC.
act_mirred race betwen tcf_action and tcfm_dev is similar.
In all cases the race is harmless.
Long term we may want to improve the situation by replacing the whole
struct tc_action as single pointer instead of updating inner fields one by one.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/sched/act_bpf.c |   15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 1b97dabc621a..2b8c47200152 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -43,10 +43,8 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 	if (unlikely(!skb_mac_header_was_set(skb)))
 		return TC_ACT_UNSPEC;
 
-	spin_lock(&prog->tcf_lock);
-
-	prog->tcf_tm.lastuse = jiffies;
-	bstats_update(&prog->tcf_bstats, skb);
+	tcf_lastuse_update(&prog->tcf_tm);
+	bstats_cpu_update(this_cpu_ptr(prog->common.cpu_bstats), skb);
 
 	/* Needed here for accessing maps. */
 	rcu_read_lock();
@@ -77,7 +75,7 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 		break;
 	case TC_ACT_SHOT:
 		action = filter_res;
-		prog->tcf_qstats.drops++;
+		qstats_drop_inc(this_cpu_ptr(prog->common.cpu_qstats));
 		break;
 	case TC_ACT_UNSPEC:
 		action = prog->tcf_action;
@@ -87,7 +85,6 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 		break;
 	}
 
-	spin_unlock(&prog->tcf_lock);
 	return action;
 }
 
@@ -294,7 +291,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 
 	if (!tcf_hash_check(parm->index, act, bind)) {
 		ret = tcf_hash_create(parm->index, est, act,
-				      sizeof(*prog), bind, false);
+				      sizeof(*prog), bind, true);
 		if (ret < 0)
 			return ret;
 
@@ -325,7 +322,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 		goto out;
 
 	prog = to_bpf(act);
-	spin_lock_bh(&prog->tcf_lock);
+	ASSERT_RTNL();
 
 	if (ret != ACT_P_CREATED)
 		tcf_bpf_prog_fill_cfg(prog, &old);
@@ -341,8 +338,6 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 	prog->tcf_action = parm->action;
 	prog->filter = cfg.filter;
 
-	spin_unlock_bh(&prog->tcf_lock);
-
 	if (res == ACT_P_CREATED)
 		tcf_hash_insert(act);
 	else
-- 
1.7.9.5
