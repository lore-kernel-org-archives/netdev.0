From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net] net_sched: gact: Fix potential panic in tcf_gact().
Date: Fri, 3 Aug 2012 19:57:52 +0900
Message-ID: <20120803195752.32410768d3d806cd241ac7a4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:51261 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110Ab2HCK54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 06:57:56 -0400
Received: by yenl2 with SMTP id l2so653502yen.19
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2012 03:57:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gact_rand array is accessed by gact->tcfg_ptype whose value
is assumed to less than MAX_RAND, but any range checks are
not performed.

So add a check in tcf_gact_init(). And in tcf_gact(), we can
reduce a branch.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
 net/sched/act_gact.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index f10fb82..05d60859 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -67,6 +67,9 @@ static int tcf_gact_init(struct nlattr *nla, struct nlattr *est,
 	struct tcf_common *pc;
 	int ret = 0;
 	int err;
+#ifdef CONFIG_GACT_PROB
+	struct tc_gact_p *p_parm = NULL;
+#endif
 
 	if (nla == NULL)
 		return -EINVAL;
@@ -82,6 +85,12 @@ static int tcf_gact_init(struct nlattr *nla, struct nlattr *est,
 #ifndef CONFIG_GACT_PROB
 	if (tb[TCA_GACT_PROB] != NULL)
 		return -EOPNOTSUPP;
+#else
+	if (tb[TCA_GACT_PROB]) {
+		p_parm = nla_data(tb[TCA_GACT_PROB]);
+		if (p_parm->ptype >= MAX_RAND)
+			return -EINVAL;
+	}
 #endif
 
 	pc = tcf_hash_check(parm->index, a, bind, &gact_hash_info);
@@ -103,8 +112,7 @@ static int tcf_gact_init(struct nlattr *nla, struct nlattr *est,
 	spin_lock_bh(&gact->tcf_lock);
 	gact->tcf_action = parm->action;
 #ifdef CONFIG_GACT_PROB
-	if (tb[TCA_GACT_PROB] != NULL) {
-		struct tc_gact_p *p_parm = nla_data(tb[TCA_GACT_PROB]);
+	if (p_parm) {
 		gact->tcfg_paction = p_parm->paction;
 		gact->tcfg_pval    = p_parm->pval;
 		gact->tcfg_ptype   = p_parm->ptype;
@@ -133,7 +141,7 @@ static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
 
 	spin_lock(&gact->tcf_lock);
 #ifdef CONFIG_GACT_PROB
-	if (gact->tcfg_ptype && gact_rand[gact->tcfg_ptype] != NULL)
+	if (gact->tcfg_ptype)
 		action = gact_rand[gact->tcfg_ptype](gact);
 	else
 		action = gact->tcf_action;
-- 
1.7.8.6
