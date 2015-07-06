From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 5/7] net_sched: act_gact: read tcfg_ptype once
Date: Mon,  6 Jul 2015 05:18:07 -0700
Message-ID: <1436185089-18268-6-git-send-email-edumazet@google.com>
References: <1436185089-18268-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34863 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755045AbbGFMSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 08:18:35 -0400
Received: by igcqs7 with SMTP id qs7so8487101igc.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 05:18:35 -0700 (PDT)
In-Reply-To: <1436185089-18268-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Third step for gact RCU operation :

Following patch will get rid of spinlock protection,
so we need to read tcfg_ptype once.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 net/sched/act_gact.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 2f9bec584b3f..e4eb88d3d8dc 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -127,16 +127,16 @@ static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
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
