From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 net-next 3/3] net sched actions: aggregate dumping of actions timeinfo
Date: Mon,  6 Jun 2016 06:32:55 -0400
Message-ID: <1465209175-8002-4-git-send-email-jhs@emojatatu.com>
References: <1465209175-8002-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	daniel@iogearbox.net, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34519 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbcFFKfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 06:35:12 -0400
Received: by mail-io0-f195.google.com with SMTP id l9so18318811ioe.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 03:35:12 -0700 (PDT)
In-Reply-To: <1465209175-8002-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/act_api.h    | 8 ++++++++
 net/sched/act_bpf.c      | 6 +-----
 net/sched/act_connmark.c | 5 +----
 net/sched/act_csum.c     | 6 ++----
 net/sched/act_gact.c     | 5 +----
 net/sched/act_ife.c      | 4 +---
 net/sched/act_ipt.c      | 7 +++----
 net/sched/act_mirred.c   | 6 ++----
 net/sched/act_nat.c      | 6 ++----
 net/sched/act_pedit.c    | 7 +++----
 net/sched/act_simple.c   | 6 ++----
 net/sched/act_skbedit.c  | 6 ++----
 net/sched/act_vlan.c     | 5 +----
 13 files changed, 29 insertions(+), 48 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 8389c00..5453f52 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -80,6 +80,14 @@ static inline void tcf_lastuse_update(struct tcf_t *tm)
 		tm->firstuse = now;
 }
 
+static inline void tcf_tm_dump(struct tcf_t *dtm, const struct tcf_t *stm)
+{
+	dtm->install = jiffies_to_clock_t(jiffies - stm->install);
+	dtm->lastuse = jiffies_to_clock_t(jiffies - stm->lastuse);
+	dtm->firstuse = jiffies_to_clock_t(jiffies - stm->firstuse);
+	dtm->expires = jiffies_to_clock_t(stm->expires);
+}
+
 struct tc_action {
 	void			*priv;
 	const struct tc_action_ops	*ops;
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index e4b877f..ae0e7cb 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -154,11 +154,7 @@ static int tcf_bpf_dump(struct sk_buff *skb, struct tc_action *act,
 	if (ret)
 		goto nla_put_failure;
 
-	tm.install = jiffies_to_clock_t(jiffies - prog->tcf_tm.install);
-	tm.lastuse = jiffies_to_clock_t(jiffies - prog->tcf_tm.lastuse);
-	tm.firstuse = jiffies_to_clock_t(jiffies - prog->tcf_tm.firstuse);
-	tm.expires = jiffies_to_clock_t(prog->tcf_tm.expires);
-
+	tcf_tm_dump(&tm, &prog->tcf_tm);
 	if (nla_put_64bit(skb, TCA_ACT_BPF_TM, sizeof(tm), &tm,
 			  TCA_ACT_BPF_PAD))
 		goto nla_put_failure;
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index e3f64f2..35a5270 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -160,10 +160,7 @@ static inline int tcf_connmark_dump(struct sk_buff *skb, struct tc_action *a,
 	if (nla_put(skb, TCA_CONNMARK_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
 
-	t.install = jiffies_to_clock_t(jiffies - ci->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - ci->tcf_tm.lastuse);
-	t.expires = jiffies_to_clock_t(ci->tcf_tm.expires);
-	t.firstuse = jiffies_to_clock_t(jiffies - ci->tcf_tm.firstuse);
+	tcf_tm_dump(&t, &ci->tcf_tm);
 	if (nla_put_64bit(skb, TCA_CONNMARK_TM, sizeof(t), &t,
 			  TCA_CONNMARK_PAD))
 		goto nla_put_failure;
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 7725eafb..dcd9aba 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -546,10 +546,8 @@ static int tcf_csum_dump(struct sk_buff *skb,
 
 	if (nla_put(skb, TCA_CSUM_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
-	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
-	t.firstuse = jiffies_to_clock_t(jiffies - p->tcf_tm.firstuse);
-	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
+
+	tcf_tm_dump(&t, &p->tcf_tm);
 	if (nla_put_64bit(skb, TCA_CSUM_TM, sizeof(t), &t, TCA_CSUM_PAD))
 		goto nla_put_failure;
 
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index c9d59f3..4c6e008 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -188,10 +188,7 @@ static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 			goto nla_put_failure;
 	}
 #endif
-	t.install = jiffies_to_clock_t(jiffies - gact->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - gact->tcf_tm.lastuse);
-	t.firstuse = jiffies_to_clock_t(jiffies - gact->tcf_tm.firstuse);
-	t.expires = jiffies_to_clock_t(gact->tcf_tm.expires);
+	tcf_tm_dump(&t, &gact->tcf_tm);
 	if (nla_put_64bit(skb, TCA_GACT_TM, sizeof(t), &t, TCA_GACT_PAD))
 		goto nla_put_failure;
 	return skb->len;
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 6491576..02f5a8b 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -553,9 +553,7 @@ static int tcf_ife_dump(struct sk_buff *skb, struct tc_action *a, int bind,
 	if (nla_put(skb, TCA_IFE_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
 
-	t.install = jiffies_to_clock_t(jiffies - ife->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - ife->tcf_tm.lastuse);
-	t.expires = jiffies_to_clock_t(ife->tcf_tm.expires);
+	tcf_tm_dump(&t, &ife->tcf_tm);
 	if (nla_put_64bit(skb, TCA_IFE_TM, sizeof(t), &t, TCA_IFE_PAD))
 		goto nla_put_failure;
 
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 47525ee..3fcde44 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -277,12 +277,11 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 	    nla_put(skb, TCA_IPT_CNT, sizeof(struct tc_cnt), &c) ||
 	    nla_put_string(skb, TCA_IPT_TABLE, ipt->tcfi_tname))
 		goto nla_put_failure;
-	tm.install = jiffies_to_clock_t(jiffies - ipt->tcf_tm.install);
-	tm.lastuse = jiffies_to_clock_t(jiffies - ipt->tcf_tm.lastuse);
-	tm.firstuse = jiffies_to_clock_t(jiffies - ipt->tcf_tm.firstuse);
-	tm.expires = jiffies_to_clock_t(ipt->tcf_tm.expires);
+
+	tcf_tm_dump(&tm, &ipt->tcf_tm);
 	if (nla_put_64bit(skb, TCA_IPT_TM, sizeof(tm), &tm, TCA_IPT_PAD))
 		goto nla_put_failure;
+
 	kfree(t);
 	return skb->len;
 
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 1b06093..787751a 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -218,10 +218,8 @@ static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, i
 
 	if (nla_put(skb, TCA_MIRRED_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
-	t.install = jiffies_to_clock_t(jiffies - m->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - m->tcf_tm.lastuse);
-	t.firstuse = jiffies_to_clock_t(jiffies - m->tcf_tm.firstuse);
-	t.expires = jiffies_to_clock_t(m->tcf_tm.expires);
+
+	tcf_tm_dump(&t, &m->tcf_tm);
 	if (nla_put_64bit(skb, TCA_MIRRED_TM, sizeof(t), &t, TCA_MIRRED_PAD))
 		goto nla_put_failure;
 	return skb->len;
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 9fbf780..06ccb03 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -264,10 +264,8 @@ static int tcf_nat_dump(struct sk_buff *skb, struct tc_action *a,
 
 	if (nla_put(skb, TCA_NAT_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
-	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
-	t.firstuse = jiffies_to_clock_t(jiffies - p->tcf_tm.firstuse);
-	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
+
+	tcf_tm_dump(&t, &p->tcf_tm);
 	if (nla_put_64bit(skb, TCA_NAT_TM, sizeof(t), &t, TCA_NAT_PAD))
 		goto nla_put_failure;
 
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index fb89275..82d3c14 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -200,12 +200,11 @@ static int tcf_pedit_dump(struct sk_buff *skb, struct tc_action *a,
 
 	if (nla_put(skb, TCA_PEDIT_PARMS, s, opt))
 		goto nla_put_failure;
-	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
-	t.firstuse = jiffies_to_clock_t(jiffies - p->tcf_tm.firstuse);
-	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
+
+	tcf_tm_dump(&t, &p->tcf_tm);
 	if (nla_put_64bit(skb, TCA_PEDIT_TM, sizeof(t), &t, TCA_PEDIT_PAD))
 		goto nla_put_failure;
+
 	kfree(opt);
 	return skb->len;
 
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 81040f1..be5fbb5 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -158,10 +158,8 @@ static int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
 	if (nla_put(skb, TCA_DEF_PARMS, sizeof(opt), &opt) ||
 	    nla_put_string(skb, TCA_DEF_DATA, d->tcfd_defdata))
 		goto nla_put_failure;
-	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
-	t.firstuse = jiffies_to_clock_t(jiffies - d->tcf_tm.firstuse);
-	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
+
+	tcf_tm_dump(&t, &d->tcf_tm);
 	if (nla_put_64bit(skb, TCA_DEF_TM, sizeof(t), &t, TCA_DEF_PAD))
 		goto nla_put_failure;
 	return skb->len;
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index cf34f31..7e2bc3c 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -168,10 +168,8 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 	    nla_put(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
 		    &d->mark))
 		goto nla_put_failure;
-	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
-	t.firstuse = jiffies_to_clock_t(jiffies - d->tcf_tm.firstuse);
-	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
+
+	tcf_tm_dump(&t, &d->tcf_tm);
 	if (nla_put_64bit(skb, TCA_SKBEDIT_TM, sizeof(t), &t, TCA_SKBEDIT_PAD))
 		goto nla_put_failure;
 	return skb->len;
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index 978ec4c..f0a08a1 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -182,10 +182,7 @@ static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
 	     nla_put_be16(skb, TCA_VLAN_PUSH_VLAN_PROTOCOL, v->tcfv_push_proto)))
 		goto nla_put_failure;
 
-	t.install = jiffies_to_clock_t(jiffies - v->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - v->tcf_tm.lastuse);
-	t.firstuse = jiffies_to_clock_t(jiffies - v->tcf_tm.firstuse);
-	t.expires = jiffies_to_clock_t(v->tcf_tm.expires);
+	tcf_tm_dump(&t, &v->tcf_tm);
 	if (nla_put_64bit(skb, TCA_VLAN_TM, sizeof(t), &t, TCA_VLAN_PAD))
 		goto nla_put_failure;
 	return skb->len;
-- 
1.9.1
