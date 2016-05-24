From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net PATCH v2 1/1] net sched actions: policer missing timestamp processing
Date: Mon, 23 May 2016 21:07:20 -0400
Message-ID: <1464052040-25783-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34795 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbcEXBHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 21:07:30 -0400
Received: by mail-io0-f194.google.com with SMTP id d197so526785ioe.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 18:07:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Policer was not dumping or updating timestamps

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/uapi/linux/pkt_cls.h |  4 +++-
 net/sched/act_police.c       | 11 +++++++++++
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index eba5914..f4297c8 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -145,6 +145,8 @@ enum {
 	TCA_POLICE_PEAKRATE,
 	TCA_POLICE_AVRATE,
 	TCA_POLICE_RESULT,
+	TCA_POLICE_TM,
+	TCA_POLICE_PAD,
 	__TCA_POLICE_MAX
 #define TCA_POLICE_RESULT TCA_POLICE_RESULT
 };
@@ -173,7 +175,7 @@ enum {
 	TCA_U32_DIVISOR,
 	TCA_U32_SEL,
 	TCA_U32_POLICE,
-	TCA_U32_ACT,   
+	TCA_U32_ACT,
 	TCA_U32_INDEV,
 	TCA_U32_PCNT,
 	TCA_U32_MARK,
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 330f14e..b884dae 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -239,6 +239,8 @@ override:
 	police->tcfp_t_c = ktime_get_ns();
 	police->tcf_index = parm->index ? parm->index :
 		tcf_hash_new_index(tn);
+	police->tcf_tm.install = jiffies;
+	police->tcf_tm.lastuse = jiffies;
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
 	spin_lock_bh(&hinfo->lock);
 	hlist_add_head(&police->tcf_head, &hinfo->htab[h]);
@@ -268,6 +270,7 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 	spin_lock(&police->tcf_lock);
 
 	bstats_update(&police->tcf_bstats, skb);
+	tcf_lastuse_update(&police->tcf_tm);
 
 	if (police->tcfp_ewma_rate &&
 	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
@@ -327,6 +330,7 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 		.refcnt = police->tcf_refcnt - ref,
 		.bindcnt = police->tcf_bindcnt - bind,
 	};
+	struct tcf_t t;
 
 	if (police->rate_present)
 		psched_ratecfg_getrate(&opt.rate, &police->rate);
@@ -340,6 +344,13 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	if (police->tcfp_ewma_rate &&
 	    nla_put_u32(skb, TCA_POLICE_AVRATE, police->tcfp_ewma_rate))
 		goto nla_put_failure;
+
+	t.install = jiffies_to_clock_t(jiffies - police->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - police->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(police->tcf_tm.expires);
+	if (nla_put_64bit(skb, TCA_POLICE_TM, sizeof(t), &t, TCA_POLICE_PAD))
+		goto nla_put_failure;
+
 	return skb->len;
 
 nla_put_failure:
-- 
1.9.1
