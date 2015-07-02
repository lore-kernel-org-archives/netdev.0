From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/6] net_sched: act: read tcfg_ptype once
Date: Thu,  2 Jul 2015 06:07:34 -0700
Message-ID: <1435842455-30501-6-git-send-email-edumazet@google.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:35948 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582AbbGBNIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 09:08:53 -0400
Received: by iecvh10 with SMTP id vh10so56063292iec.3
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 06:08:52 -0700 (PDT)
In-Reply-To: <1435842455-30501-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Third step for gact RCU operation :

Following patch will get rid of spinlock protection,
so we need to read tcfg_ptype once.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.fastabend@gmail.com>
---
 net/sched/act_gact.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index e968290e8378..7c7e72e95943 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -121,16 +121,16 @@ static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
 		    struct tcf_result *res)
 {
 	struct tcf_gact *gact = a->priv;
-	int action = TC_ACT_SHOT;
+	int action = gact->tcf_action;
 
 	spin_lock(&gact->tcf_lock);
 #ifdef CONFIG_GACT_PROB
-	if (gact->tcfg_ptype)
-		action = gact_rand[gact->tcfg_ptype](gact);
-	else
-		action = gact->tcf_action;
-#else
-	action = gact->tcf_action;
+	{
+	u32 ptype = READ_ONCE(gact->tcfg_ptype);
+
+	if (ptype)
+		action = gact_rand[ptype](gact);
+	}
 #endif
 	gact->tcf_bstats.bytes += qdisc_pkt_len(skb);
 	gact->tcf_bstats.packets++;
-- 
2.4.3.573.g4eafbef
