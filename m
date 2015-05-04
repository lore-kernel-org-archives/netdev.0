From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 2/5] net: sched: use counter to break reclassify loops
Date: Mon,  4 May 2015 20:48:35 +0200
Message-ID: <1430765318-13788-3-git-send-email-fw@strlen.de>
References: <1430765318-13788-1-git-send-email-fw@strlen.de>
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46869 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751733AbbEDSs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 14:48:56 -0400
In-Reply-To: <1430765318-13788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems all we want here is to avoid endless 'goto reclassify' loop.
tc_classify_compat even resets this counter when something other
than TC_ACT_RECLASSIFY is returned, so this skb-counter doesn't
break hypothetical loops induced by something other than perpetual
TC_ACT_RECLASSIFY return values.

skb_act_clone is now identical to skb_clone, so just use that.

Tested with following (bogus) filter:
tc filter add dev eth0 parent ffff: \
 protocol ip u32 match u32 0 0 police rate 10Kbit burst \
 64000 mtu 1500 action reclassify

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Documentation/networking/tc-actions-env-rules.txt |  4 ----
 include/net/sch_generic.h                         | 15 ---------------
 include/uapi/linux/pkt_cls.h                      |  4 +---
 net/sched/act_mirred.c                            |  2 +-
 net/sched/sch_api.c                               | 12 +++---------
 5 files changed, 5 insertions(+), 32 deletions(-)

diff --git a/Documentation/networking/tc-actions-env-rules.txt b/Documentation/networking/tc-actions-env-rules.txt
index 95c7171..f378146 100644
--- a/Documentation/networking/tc-actions-env-rules.txt
+++ b/Documentation/networking/tc-actions-env-rules.txt
@@ -8,10 +8,6 @@ For example if your action queues a packet to be processed later,
 or intentionally branches by redirecting a packet, then you need to
 clone the packet.
 
-There are certain fields in the skb tc_verd that need to be reset so we
-avoid loops, etc.  A few are generic enough that skb_act_clone()
-resets them for you, so invoke skb_act_clone() rather than skb_clone().
-
 2) If you munge any packet thou shalt call pskb_expand_head in the case
 someone else is referencing the skb. After that you "own" the skb.
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 994b5a0..a611ed4 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -745,21 +745,6 @@ static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned int pktlen)
 	return rtab->data[slot];
 }
 
-#ifdef CONFIG_NET_CLS_ACT
-static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask,
-					    int action)
-{
-	struct sk_buff *n;
-
-	n = skb_clone(skb, gfp_mask);
-
-	if (n) {
-		n->tc_verd = SET_TC_VERD(n->tc_verd, 0);
-	}
-	return n;
-}
-#endif
-
 struct psched_ratecfg {
 	u64	rate_bytes_ps; /* bytes per second */
 	u32	mult;
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index ef8eb88..02dca42 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -44,13 +44,13 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
 #define TC_OK2MUNGE        _TC_MAKEMASK1(1)
 #define SET_TC_OK2MUNGE(v)   ( TC_OK2MUNGE | (v & ~TC_OK2MUNGE))
 #define CLR_TC_OK2MUNGE(v)   ( v & ~TC_OK2MUNGE)
-#endif
 
 #define S_TC_VERD          _TC_MAKE32(2)
 #define M_TC_VERD          _TC_MAKEMASK(4,S_TC_VERD)
 #define G_TC_VERD(x)       _TC_GETVALUE(x,S_TC_VERD,M_TC_VERD)
 #define V_TC_VERD(x)       _TC_MAKEVALUE(x,S_TC_VERD)
 #define SET_TC_VERD(v,n)   ((V_TC_VERD(n)) | (v & ~M_TC_VERD))
+#endif
 
 #define S_TC_FROM          _TC_MAKE32(6)
 #define M_TC_FROM          _TC_MAKEMASK(2,S_TC_FROM)
@@ -65,9 +65,7 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
 #define TC_NCLS          _TC_MAKEMASK1(8)
 #define SET_TC_NCLS(v)   ( TC_NCLS | (v & ~TC_NCLS))
 #define CLR_TC_NCLS(v)   ( v & ~TC_NCLS)
-#endif
 
-#ifndef __KERNEL__
 #define S_TC_RTTL          _TC_MAKE32(9)
 #define M_TC_RTTL          _TC_MAKEMASK(3,S_TC_RTTL)
 #define G_TC_RTTL(x)       _TC_GETVALUE(x,S_TC_RTTL,M_TC_RTTL)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 3f63cea..a42a3b2 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -151,7 +151,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	}
 
 	at = G_TC_AT(skb->tc_verd);
-	skb2 = skb_act_clone(skb, GFP_ATOMIC, m->tcf_action);
+	skb2 = skb_clone(skb, GFP_ATOMIC);
 	if (skb2 == NULL)
 		goto out;
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ad9eed7..0b74dc0 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1816,13 +1816,8 @@ int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
 			continue;
 		err = tp->classify(skb, tp, res);
 
-		if (err >= 0) {
-#ifdef CONFIG_NET_CLS_ACT
-			if (err != TC_ACT_RECLASSIFY && skb->tc_verd)
-				skb->tc_verd = SET_TC_VERD(skb->tc_verd, 0);
-#endif
+		if (err >= 0)
 			return err;
-		}
 	}
 	return -1;
 }
@@ -1834,23 +1829,22 @@ int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	int err = 0;
 #ifdef CONFIG_NET_CLS_ACT
 	const struct tcf_proto *otp = tp;
+	int limit = 0;
 reclassify:
 #endif
 
 	err = tc_classify_compat(skb, tp, res);
 #ifdef CONFIG_NET_CLS_ACT
 	if (err == TC_ACT_RECLASSIFY) {
-		u32 verd = G_TC_VERD(skb->tc_verd);
 		tp = otp;
 
-		if (verd++ >= MAX_REC_LOOP) {
+		if (unlikely(limit++ >= MAX_REC_LOOP)) {
 			net_notice_ratelimited("%s: packet reclassify loop rule prio %u protocol %02x\n",
 					       tp->q->ops->id,
 					       tp->prio & 0xffff,
 					       ntohs(tp->protocol));
 			return TC_ACT_SHOT;
 		}
-		skb->tc_verd = SET_TC_VERD(skb->tc_verd, verd);
 		goto reclassify;
 	}
 #endif
-- 
2.0.5
