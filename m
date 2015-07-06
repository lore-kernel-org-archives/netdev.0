From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 3/7] net_sched: act_gact: make tcfg_pval non zero
Date: Sun,  5 Jul 2015 23:41:28 -0700
Message-ID: <1436164896-8243-4-git-send-email-edumazet@google.com>
References: <1436164896-8243-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:33014 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbbGFGrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 02:47:45 -0400
Received: by ieqy10 with SMTP id y10so107671457ieq.0
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 23:47:44 -0700 (PDT)
In-Reply-To: <1436164896-8243-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First step for gact RCU operation :

Instead of testing if tcfg_pval is zero or not, just make it 1.

No change in behavior, but slightly faster code.

The smp_rmb()/smp_wmb() barriers, while not strictly needed at this
stage are added for upcoming spinlock removal.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 net/sched/act_gact.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index a4f8af29ee30..22a3a61aa090 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -28,14 +28,16 @@
 #ifdef CONFIG_GACT_PROB
 static int gact_net_rand(struct tcf_gact *gact)
 {
-	if (!gact->tcfg_pval || prandom_u32() % gact->tcfg_pval)
+	smp_rmb(); /* coupled with smp_wmb() in tcf_gact_init() */
+	if (prandom_u32() % gact->tcfg_pval)
 		return gact->tcf_action;
 	return gact->tcfg_paction;
 }
 
 static int gact_determ(struct tcf_gact *gact)
 {
-	if (!gact->tcfg_pval || gact->tcf_bstats.packets % gact->tcfg_pval)
+	smp_rmb(); /* coupled with smp_wmb() in tcf_gact_init() */
+	if (gact->tcf_bstats.packets % gact->tcfg_pval)
 		return gact->tcf_action;
 	return gact->tcfg_paction;
 }
@@ -105,7 +107,11 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 #ifdef CONFIG_GACT_PROB
 	if (p_parm) {
 		gact->tcfg_paction = p_parm->paction;
-		gact->tcfg_pval    = p_parm->pval;
+		gact->tcfg_pval    = max_t(u16, 1, p_parm->pval);
+		/* Make sure tcfg_pval is written before tcfg_ptype
+		 * coupled with smp_rmb() in gact_net_rand() & gact_determ()
+		 */
+		smp_wmb();
 		gact->tcfg_ptype   = p_parm->ptype;
 	}
 #endif
-- 
2.4.3.573.g4eafbef
