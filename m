From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 net-next 2/3] net sched actions: introduce timestamp for firsttime use
Date: Mon,  6 Jun 2016 06:32:54 -0400
Message-ID: <1465209175-8002-3-git-send-email-jhs@emojatatu.com>
References: <1465209175-8002-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	daniel@iogearbox.net, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33767 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbcFFKfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 06:35:11 -0400
Received: by mail-it0-f66.google.com with SMTP id u203so5540347itc.0
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 03:35:11 -0700 (PDT)
In-Reply-To: <1465209175-8002-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Useful to know when the action was first used for accounting
(and debugging)

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/act_api.h        | 2 ++
 include/uapi/linux/pkt_cls.h | 1 +
 net/sched/act_api.c          | 1 +
 net/sched/act_bpf.c          | 1 +
 net/sched/act_connmark.c     | 1 +
 net/sched/act_csum.c         | 1 +
 net/sched/act_gact.c         | 1 +
 net/sched/act_ipt.c          | 1 +
 net/sched/act_mirred.c       | 1 +
 net/sched/act_nat.c          | 1 +
 net/sched/act_pedit.c        | 1 +
 net/sched/act_police.c       | 2 ++
 net/sched/act_simple.c       | 1 +
 net/sched/act_skbedit.c      | 1 +
 net/sched/act_vlan.c         | 1 +
 15 files changed, 17 insertions(+)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 9a9a8ed..8389c00 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -76,6 +76,8 @@ static inline void tcf_lastuse_update(struct tcf_t *tm)
 
 	if (tm->lastuse != now)
 		tm->lastuse = now;
+	if (unlikely(!tm->firstuse))
+		tm->firstuse = now;
 }
 
 struct tc_action {
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index f4297c8..9ba1410 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -124,6 +124,7 @@ struct tcf_t {
 	__u64   install;
 	__u64   lastuse;
 	__u64   expires;
+	__u64   firstuse;
 };
 
 struct tc_cnt {
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 336774a..5ebf6d6 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -283,6 +283,7 @@ err2:
 	p->tcfc_index = index ? index : tcf_hash_new_index(tn);
 	p->tcfc_tm.install = jiffies;
 	p->tcfc_tm.lastuse = jiffies;
+	p->tcfc_tm.firstuse = 0;
 	if (est) {
 		err = gen_new_estimator(&p->tcfc_bstats, p->cpu_bstats,
 					&p->tcfc_rate_est,
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index c7123e0..e4b877f 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -156,6 +156,7 @@ static int tcf_bpf_dump(struct sk_buff *skb, struct tc_action *act,
 
 	tm.install = jiffies_to_clock_t(jiffies - prog->tcf_tm.install);
 	tm.lastuse = jiffies_to_clock_t(jiffies - prog->tcf_tm.lastuse);
+	tm.firstuse = jiffies_to_clock_t(jiffies - prog->tcf_tm.firstuse);
 	tm.expires = jiffies_to_clock_t(prog->tcf_tm.expires);
 
 	if (nla_put_64bit(skb, TCA_ACT_BPF_TM, sizeof(tm), &tm,
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index e0e6c68..e3f64f2 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -163,6 +163,7 @@ static inline int tcf_connmark_dump(struct sk_buff *skb, struct tc_action *a,
 	t.install = jiffies_to_clock_t(jiffies - ci->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - ci->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(ci->tcf_tm.expires);
+	t.firstuse = jiffies_to_clock_t(jiffies - ci->tcf_tm.firstuse);
 	if (nla_put_64bit(skb, TCA_CONNMARK_TM, sizeof(t), &t,
 			  TCA_CONNMARK_PAD))
 		goto nla_put_failure;
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 065f716..7725eafb 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -548,6 +548,7 @@ static int tcf_csum_dump(struct sk_buff *skb,
 		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
+	t.firstuse = jiffies_to_clock_t(jiffies - p->tcf_tm.firstuse);
 	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
 	if (nla_put_64bit(skb, TCA_CSUM_TM, sizeof(t), &t, TCA_CSUM_PAD))
 		goto nla_put_failure;
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index ec5cc84..c9d59f3 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -190,6 +190,7 @@ static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 #endif
 	t.install = jiffies_to_clock_t(jiffies - gact->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - gact->tcf_tm.lastuse);
+	t.firstuse = jiffies_to_clock_t(jiffies - gact->tcf_tm.firstuse);
 	t.expires = jiffies_to_clock_t(gact->tcf_tm.expires);
 	if (nla_put_64bit(skb, TCA_GACT_TM, sizeof(t), &t, TCA_GACT_PAD))
 		goto nla_put_failure;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 30e9087..47525ee 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -279,6 +279,7 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 		goto nla_put_failure;
 	tm.install = jiffies_to_clock_t(jiffies - ipt->tcf_tm.install);
 	tm.lastuse = jiffies_to_clock_t(jiffies - ipt->tcf_tm.lastuse);
+	tm.firstuse = jiffies_to_clock_t(jiffies - ipt->tcf_tm.firstuse);
 	tm.expires = jiffies_to_clock_t(ipt->tcf_tm.expires);
 	if (nla_put_64bit(skb, TCA_IPT_TM, sizeof(tm), &tm, TCA_IPT_PAD))
 		goto nla_put_failure;
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index d3ac73e..1b06093 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -220,6 +220,7 @@ static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, i
 		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - m->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - m->tcf_tm.lastuse);
+	t.firstuse = jiffies_to_clock_t(jiffies - m->tcf_tm.firstuse);
 	t.expires = jiffies_to_clock_t(m->tcf_tm.expires);
 	if (nla_put_64bit(skb, TCA_MIRRED_TM, sizeof(t), &t, TCA_MIRRED_PAD))
 		goto nla_put_failure;
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 9135aa8..9fbf780 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -266,6 +266,7 @@ static int tcf_nat_dump(struct sk_buff *skb, struct tc_action *a,
 		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
+	t.firstuse = jiffies_to_clock_t(jiffies - p->tcf_tm.firstuse);
 	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
 	if (nla_put_64bit(skb, TCA_NAT_TM, sizeof(t), &t, TCA_NAT_PAD))
 		goto nla_put_failure;
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 67a1726..fb89275 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -202,6 +202,7 @@ static int tcf_pedit_dump(struct sk_buff *skb, struct tc_action *a,
 		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
+	t.firstuse = jiffies_to_clock_t(jiffies - p->tcf_tm.firstuse);
 	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
 	if (nla_put_64bit(skb, TCA_PEDIT_TM, sizeof(t), &t, TCA_PEDIT_PAD))
 		goto nla_put_failure;
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index b884dae..820b116 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -241,6 +241,7 @@ override:
 		tcf_hash_new_index(tn);
 	police->tcf_tm.install = jiffies;
 	police->tcf_tm.lastuse = jiffies;
+	police->tcf_tm.firstuse = 0;
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
 	spin_lock_bh(&hinfo->lock);
 	hlist_add_head(&police->tcf_head, &hinfo->htab[h]);
@@ -347,6 +348,7 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 
 	t.install = jiffies_to_clock_t(jiffies - police->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - police->tcf_tm.lastuse);
+	t.firstuse = jiffies_to_clock_t(jiffies - police->tcf_tm.firstuse);
 	t.expires = jiffies_to_clock_t(police->tcf_tm.expires);
 	if (nla_put_64bit(skb, TCA_POLICE_TM, sizeof(t), &t, TCA_POLICE_PAD))
 		goto nla_put_failure;
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index f95d1c5..81040f1 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -160,6 +160,7 @@ static int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
 		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
+	t.firstuse = jiffies_to_clock_t(jiffies - d->tcf_tm.firstuse);
 	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
 	if (nla_put_64bit(skb, TCA_DEF_TM, sizeof(t), &t, TCA_DEF_PAD))
 		goto nla_put_failure;
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 82105c8..cf34f31 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -170,6 +170,7 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 		goto nla_put_failure;
 	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
+	t.firstuse = jiffies_to_clock_t(jiffies - d->tcf_tm.firstuse);
 	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
 	if (nla_put_64bit(skb, TCA_SKBEDIT_TM, sizeof(t), &t, TCA_SKBEDIT_PAD))
 		goto nla_put_failure;
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index da5120f..978ec4c 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -184,6 +184,7 @@ static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
 
 	t.install = jiffies_to_clock_t(jiffies - v->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - v->tcf_tm.lastuse);
+	t.firstuse = jiffies_to_clock_t(jiffies - v->tcf_tm.firstuse);
 	t.expires = jiffies_to_clock_t(v->tcf_tm.expires);
 	if (nla_put_64bit(skb, TCA_VLAN_TM, sizeof(t), &t, TCA_VLAN_PAD))
 		goto nla_put_failure;
-- 
1.9.1
