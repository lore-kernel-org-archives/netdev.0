From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 5/5] net_sched: act_bpf: remove spinlock in fast path
Date: Tue, 25 Aug 2015 20:06:35 -0700
Message-ID: <1440558395-7765-6-git-send-email-ast@plumgrid.com>
References: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36659 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbHZDGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 23:06:46 -0400
Received: by pacgr6 with SMTP id gr6so11354764pac.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 20:06:46 -0700 (PDT)
In-Reply-To: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to act_gact/act_mirred, act_bpf can be lockless in packet processing
with extra care taken to free bpf programs after rcu grace period.
Replacement of existing act_bpf (very rare) is done with synchronize_rcu()
and final destruction is done from tc_action_ops->cleanup() callback that is
called from tcf_exts_destroy()->tcf_action_destroy()->__tcf_hash_release() when
bind and refcnt reach zero which is only possible when classifier is destroyed.
Previous two patches fixed the last two classifiers (tcindex and rsvp) to
call tcf_exts_destroy() from rcu callback.

Similar to gact/mirred there is a race between prog->filter and
prog->tcf_action. Meaning that the program being replaced may use
previous default action if it happened to return TC_ACT_UNSPEC.
act_mirred race betwen tcf_action and tcfm_dev is similar.
In all cases the race is harmless.
Long term we may want to improve the situation by replacing the whole
tc_action->priv as single pointer instead of updating inner fields one by one.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/net/tc_act/tc_bpf.h |    2 +-
 net/sched/act_bpf.c         |   36 +++++++++++++++++++-----------------
 2 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/include/net/tc_act/tc_bpf.h b/include/net/tc_act/tc_bpf.h
index a152e9858b2c..958d69cfb19c 100644
--- a/include/net/tc_act/tc_bpf.h
+++ b/include/net/tc_act/tc_bpf.h
@@ -15,7 +15,7 @@
 
 struct tcf_bpf {
 	struct tcf_common	common;
-	struct bpf_prog		*filter;
+	struct bpf_prog __rcu	*filter;
 	union {
 		u32		bpf_fd;
 		u16		bpf_num_ops;
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 458cf647e698..559bfa011bda 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -37,25 +37,24 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 		   struct tcf_result *res)
 {
 	struct tcf_bpf *prog = act->priv;
+	struct bpf_prog *filter;
 	int action, filter_res;
 	bool at_ingress = G_TC_AT(skb->tc_verd) & AT_INGRESS;
 
 	if (unlikely(!skb_mac_header_was_set(skb)))
 		return TC_ACT_UNSPEC;
 
-	spin_lock(&prog->tcf_lock);
-
-	prog->tcf_tm.lastuse = jiffies;
-	bstats_update(&prog->tcf_bstats, skb);
+	tcf_lastuse_update(&prog->tcf_tm);
+	bstats_cpu_update(this_cpu_ptr(prog->common.cpu_bstats), skb);
 
-	/* Needed here for accessing maps. */
 	rcu_read_lock();
+	filter = rcu_dereference(prog->filter);
 	if (at_ingress) {
 		__skb_push(skb, skb->mac_len);
-		filter_res = BPF_PROG_RUN(prog->filter, skb);
+		filter_res = BPF_PROG_RUN(filter, skb);
 		__skb_pull(skb, skb->mac_len);
 	} else {
-		filter_res = BPF_PROG_RUN(prog->filter, skb);
+		filter_res = BPF_PROG_RUN(filter, skb);
 	}
 	rcu_read_unlock();
 
@@ -77,7 +76,7 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 		break;
 	case TC_ACT_SHOT:
 		action = filter_res;
-		prog->tcf_qstats.drops++;
+		qstats_drop_inc(this_cpu_ptr(prog->common.cpu_qstats));
 		break;
 	case TC_ACT_UNSPEC:
 		action = prog->tcf_action;
@@ -87,7 +86,6 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 		break;
 	}
 
-	spin_unlock(&prog->tcf_lock);
 	return action;
 }
 
@@ -263,7 +261,10 @@ static void tcf_bpf_prog_fill_cfg(const struct tcf_bpf *prog,
 				  struct tcf_bpf_cfg *cfg)
 {
 	cfg->is_ebpf = tcf_bpf_is_ebpf(prog);
-	cfg->filter = prog->filter;
+	/* updates to prog->filter are prevented, since it's called either
+	 * with rtnl lock or during final cleanup in rcu callback
+	 */
+	cfg->filter = rcu_dereference_protected(prog->filter, 1);
 
 	cfg->bpf_ops = prog->bpf_ops;
 	cfg->bpf_name = prog->bpf_name;
@@ -294,7 +295,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 
 	if (!tcf_hash_check(parm->index, act, bind)) {
 		ret = tcf_hash_create(parm->index, est, act,
-				      sizeof(*prog), bind, false);
+				      sizeof(*prog), bind, true);
 		if (ret < 0)
 			return ret;
 
@@ -325,7 +326,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 		goto out;
 
 	prog = to_bpf(act);
-	spin_lock_bh(&prog->tcf_lock);
+	ASSERT_RTNL();
 
 	if (res != ACT_P_CREATED)
 		tcf_bpf_prog_fill_cfg(prog, &old);
@@ -339,14 +340,15 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 		prog->bpf_fd = cfg.bpf_fd;
 
 	prog->tcf_action = parm->action;
-	prog->filter = cfg.filter;
-
-	spin_unlock_bh(&prog->tcf_lock);
+	rcu_assign_pointer(prog->filter, cfg.filter);
 
-	if (res == ACT_P_CREATED)
+	if (res == ACT_P_CREATED) {
 		tcf_hash_insert(act);
-	else
+	} else {
+		/* make sure the program being replaced is no longer executing */
+		synchronize_rcu();
 		tcf_bpf_cfg_cleanup(&old);
+	}
 
 	return res;
 out:
-- 
1.7.9.5
