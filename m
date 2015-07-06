From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 4/7] net_sched: act_gact: use a separate packet counters for gact_determ()
Date: Mon,  6 Jul 2015 05:18:06 -0700
Message-ID: <1436185089-18268-5-git-send-email-edumazet@google.com>
References: <1436185089-18268-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:34640 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755067AbbGFMSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 08:18:31 -0400
Received: by igcsj18 with SMTP id sj18so232352523igc.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 05:18:31 -0700 (PDT)
In-Reply-To: <1436185089-18268-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Second step for gact RCU operation :

We want to get rid of the spinlock protecting gact operations.
Stats (packets/bytes) will soon be per cpu.

gact_determ() would not work without a central packet counter,
so lets add it for this mode.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: John Fastabend <john.fastabend@gmail.com>
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
index 22a3a61aa090..2f9bec584b3f 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -36,8 +36,10 @@ static int gact_net_rand(struct tcf_gact *gact)
 
 static int gact_determ(struct tcf_gact *gact)
 {
+	u32 pack = atomic_inc_return(&gact->packets);
+
 	smp_rmb(); /* coupled with smp_wmb() in tcf_gact_init() */
-	if (gact->tcf_bstats.packets % gact->tcfg_pval)
+	if (pack % gact->tcfg_pval)
 		return gact->tcf_action;
 	return gact->tcfg_paction;
 }
-- 
2.4.3.573.g4eafbef
