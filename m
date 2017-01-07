From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 2/6] net-tc: make MAX_RECLASSIFY_LOOP local
Date: Sat,  7 Jan 2017 17:06:34 -0500
Message-ID: <20170107220638.61314-3-willemdebruijn.kernel@gmail.com>
References: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com,
        eric.dumazet@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36821 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932639AbdAGWGp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 17:06:45 -0500
Received: by mail-qk0-f193.google.com with SMTP id a20so14408785qkc.3
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 14:06:44 -0800 (PST)
In-Reply-To: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

This field is no longer kept in tc_verd. Remove it from the global
definition of that struct.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/uapi/linux/pkt_cls.h | 5 -----
 net/sched/sch_api.c          | 3 ++-
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index c769f71972f5..bba23dbb3ab6 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -17,9 +17,6 @@
 
 /* verdict bit breakdown 
  *
-bit 2,3,4,5: Reclassify counter - sort of reverse TTL - if exceeded
-assume loop
-
 bit 6,7: Where this packet was last seen 
 0: Above the transmit example at the socket level
 1: on the Ingress
@@ -48,8 +45,6 @@ bit 8: when set --> Request not to classify on ingress.
 #define G_TC_AT(x)       _TC_GETVALUE(x,S_TC_AT,M_TC_AT)
 #define V_TC_AT(x)       _TC_MAKEVALUE(x,S_TC_AT)
 #define SET_TC_AT(v,n)   ((V_TC_AT(n)) | (v & ~M_TC_AT))
-
-#define MAX_REC_LOOP 4
 #endif
 
 /* Action attributes */
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d7b93429f0cc..ef53ede11590 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1861,6 +1861,7 @@ int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 {
 	__be16 protocol = tc_skb_protocol(skb);
 #ifdef CONFIG_NET_CLS_ACT
+	const int max_reclassify_loop = 4;
 	const struct tcf_proto *old_tp = tp;
 	int limit = 0;
 
@@ -1885,7 +1886,7 @@ int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	return TC_ACT_UNSPEC; /* signal: continue lookup */
 #ifdef CONFIG_NET_CLS_ACT
 reset:
-	if (unlikely(limit++ >= MAX_REC_LOOP)) {
+	if (unlikely(limit++ >= max_reclassify_loop)) {
 		net_notice_ratelimited("%s: reclassify loop, rule prio %u, protocol %02x\n",
 				       tp->q->ops->id, tp->prio & 0xffff,
 				       ntohs(tp->protocol));
-- 
2.11.0.390.gc69c2f50cf-goog
