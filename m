From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/6] net_sched: act: use a separate packet counters for gact_determ()
Date: Thu,  2 Jul 2015 06:07:33 -0700
Message-ID: <1435842455-30501-5-git-send-email-edumazet@google.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:32842 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812AbbGBNIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 09:08:42 -0400
Received: by ieqy10 with SMTP id y10so56147814ieq.0
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 06:08:41 -0700 (PDT)
In-Reply-To: <1435842455-30501-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Second step for gact RCU operation :

We want to get rid of the spinlock protecting gact operations.
Stats (packets/bytes) will soon be per cpu.

gact_determ() would not work without a central packet counter,
so lets add it for this mode.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.fastabend@gmail.com>
---
 include/net/tc_act/tc_gact.h | 7 ++++---
 net/sched/act_gact.c         | 4 +++-
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
index 9fc9b578908a..592a6bc02b0b 100644
--- a/include/net/tc_act/tc_gact.h
+++ b/include/net/tc_act/tc_gact.h
@@ -6,9 +6,10 @@
 struct tcf_gact {
 	struct tcf_common	common;
 #ifdef CONFIG_GACT_PROB
-        u16			tcfg_ptype;
-        u16			tcfg_pval;
-        int			tcfg_paction;
+	u16			tcfg_ptype;
+	u16			tcfg_pval;
+	int			tcfg_paction;
+	atomic_t		packets;
 #endif
 };
 #define to_gact(a) \
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 42284aad77dd..e968290e8378 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -35,7 +35,9 @@ static int gact_net_rand(struct tcf_gact *gact)
 
 static int gact_determ(struct tcf_gact *gact)
 {
-	if (gact->tcf_bstats.packets % gact->tcfg_pval)
+	u32 pack = atomic_inc_return(&gact->packets);
+
+	if (pack % gact->tcfg_pval)
 		return gact->tcf_action;
 	return gact->tcfg_paction;
 }
-- 
2.4.3.573.g4eafbef
