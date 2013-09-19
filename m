From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/2] net_sched: htb: support of 64bit rates
Date: Thu, 19 Sep 2013 09:10:20 -0700
Message-ID: <1379607020.3282.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f48.google.com ([209.85.212.48]:61461 "EHLO
	mail-vb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072Ab3ISQKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 12:10:22 -0400
Received: by mail-vb0-f48.google.com with SMTP id w16so6611336vbf.35
        for <netdev@vger.kernel.org>; Thu, 19 Sep 2013 09:10:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

HTB already can deal with 64bit rates, we only have to add two new
attributes so that tc can use them to break the current 32bit ABI
barrier.

TCA_HTB_RATE64 : class rate  (in bytes per second)
TCA_HTB_CEIL64 : class ceil  (in bytes per second)

This allows us to setup HTB on 40Gbps links, as 32bit limit is
actually ~34Gbps

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/pkt_sched.h |    2 ++
 net/sched/sch_htb.c            |   17 +++++++++++++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 9b82913..f2624b5 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -357,6 +357,8 @@ enum {
 	TCA_HTB_CTAB,
 	TCA_HTB_RTAB,
 	TCA_HTB_DIRECT_QLEN,
+	TCA_HTB_RATE64,
+	TCA_HTB_CEIL64,
 	__TCA_HTB_MAX,
 };
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 6b126f6..0e1e38b 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -997,6 +997,8 @@ static const struct nla_policy htb_policy[TCA_HTB_MAX + 1] = {
 	[TCA_HTB_CTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
 	[TCA_HTB_RTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
 	[TCA_HTB_DIRECT_QLEN] = { .type = NLA_U32 },
+	[TCA_HTB_RATE64] = { .type = NLA_U64 },
+	[TCA_HTB_CEIL64] = { .type = NLA_U64 },
 };
 
 static void htb_work_func(struct work_struct *work)
@@ -1114,6 +1116,12 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	opt.level = cl->level;
 	if (nla_put(skb, TCA_HTB_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
+	if ((cl->rate.rate_bytes_ps >= (1ULL << 32)) &&
+	    nla_put_u64(skb, TCA_HTB_RATE64, cl->rate.rate_bytes_ps))
+		goto nla_put_failure;
+	if ((cl->ceil.rate_bytes_ps >= (1ULL << 32)) &&
+	    nla_put_u64(skb, TCA_HTB_CEIL64, cl->ceil.rate_bytes_ps))
+		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 	spin_unlock_bh(root_lock);
@@ -1332,6 +1340,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	struct qdisc_rate_table *rtab = NULL, *ctab = NULL;
 	struct nlattr *tb[TCA_HTB_MAX + 1];
 	struct tc_htb_opt *hopt;
+	u64 rate64, ceil64;
 
 	/* extract all subattrs from opt attr */
 	if (!opt)
@@ -1491,8 +1500,12 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			cl->prio = TC_HTB_NUMPRIO - 1;
 	}
 
-	psched_ratecfg_precompute(&cl->rate, &hopt->rate, 0);
-	psched_ratecfg_precompute(&cl->ceil, &hopt->ceil, 0);
+	rate64 = tb[TCA_HTB_RATE64] ? nla_get_u64(tb[TCA_HTB_RATE64]) : 0;
+
+	ceil64 = tb[TCA_HTB_CEIL64] ? nla_get_u64(tb[TCA_HTB_CEIL64]) : 0;
+
+	psched_ratecfg_precompute(&cl->rate, &hopt->rate, rate64);
+	psched_ratecfg_precompute(&cl->ceil, &hopt->ceil, ceil64);
 
 	cl->buffer = PSCHED_TICKS2NS(hopt->buffer);
 	cl->cbuffer = PSCHED_TICKS2NS(hopt->cbuffer);
