From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/9] sched: use nla_put_u64_64bit()
Date: Mon, 25 Apr 2016 10:25:15 +0200
Message-ID: <1461572722-6029-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, jhs@mojatatu.com, stephen@networkplumber.org,
	pshelar@nicira.com, aar@pengutronix.de, linux-wpan@vger.kernel.org,
	wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:54423 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860AbcDYIZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 04:25:46 -0400
In-Reply-To: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/pkt_sched.h | 3 +++
 net/sched/sch_htb.c            | 6 ++++--
 net/sched/sch_netem.c          | 3 ++-
 net/sched/sch_tbf.c            | 6 ++++--
 4 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 8cb18b44968e..1c78c7454c7c 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -179,6 +179,7 @@ enum {
 	TCA_TBF_PRATE64,
 	TCA_TBF_BURST,
 	TCA_TBF_PBURST,
+	TCA_TBF_PAD,
 	__TCA_TBF_MAX,
 };
 
@@ -368,6 +369,7 @@ enum {
 	TCA_HTB_DIRECT_QLEN,
 	TCA_HTB_RATE64,
 	TCA_HTB_CEIL64,
+	TCA_HTB_PAD,
 	__TCA_HTB_MAX,
 };
 
@@ -531,6 +533,7 @@ enum {
 	TCA_NETEM_RATE,
 	TCA_NETEM_ECN,
 	TCA_NETEM_RATE64,
+	TCA_NETEM_PAD,
 	__TCA_NETEM_MAX,
 };
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 87b02ed3d5f2..f6bf5818ed4d 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1122,10 +1122,12 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	if (nla_put(skb, TCA_HTB_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
 	if ((cl->rate.rate_bytes_ps >= (1ULL << 32)) &&
-	    nla_put_u64(skb, TCA_HTB_RATE64, cl->rate.rate_bytes_ps))
+	    nla_put_u64_64bit(skb, TCA_HTB_RATE64, cl->rate.rate_bytes_ps,
+			      TCA_HTB_PAD))
 		goto nla_put_failure;
 	if ((cl->ceil.rate_bytes_ps >= (1ULL << 32)) &&
-	    nla_put_u64(skb, TCA_HTB_CEIL64, cl->ceil.rate_bytes_ps))
+	    nla_put_u64_64bit(skb, TCA_HTB_CEIL64, cl->ceil.rate_bytes_ps,
+			      TCA_HTB_PAD))
 		goto nla_put_failure;
 
 	return nla_nest_end(skb, nest);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 9640bb39a5d2..491d6fd6430c 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -994,7 +994,8 @@ static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 		goto nla_put_failure;
 
 	if (q->rate >= (1ULL << 32)) {
-		if (nla_put_u64(skb, TCA_NETEM_RATE64, q->rate))
+		if (nla_put_u64_64bit(skb, TCA_NETEM_RATE64, q->rate,
+				      TCA_NETEM_PAD))
 			goto nla_put_failure;
 		rate.rate = ~0U;
 	} else {
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index c2fbde742f37..83b90b584fae 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -472,11 +472,13 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (nla_put(skb, TCA_TBF_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
 	if (q->rate.rate_bytes_ps >= (1ULL << 32) &&
-	    nla_put_u64(skb, TCA_TBF_RATE64, q->rate.rate_bytes_ps))
+	    nla_put_u64_64bit(skb, TCA_TBF_RATE64, q->rate.rate_bytes_ps,
+			      TCA_TBF_PAD))
 		goto nla_put_failure;
 	if (tbf_peak_present(q) &&
 	    q->peak.rate_bytes_ps >= (1ULL << 32) &&
-	    nla_put_u64(skb, TCA_TBF_PRATE64, q->peak.rate_bytes_ps))
+	    nla_put_u64_64bit(skb, TCA_TBF_PRATE64, q->peak.rate_bytes_ps,
+			      TCA_TBF_PAD))
 		goto nla_put_failure;
 
 	return nla_nest_end(skb, nest);
-- 
2.8.1
