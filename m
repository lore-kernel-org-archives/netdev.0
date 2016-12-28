From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next rfc 2/6] net-tc: make MAX_RECLASSIFY_LOOP local
Date: Wed, 28 Dec 2016 14:13:26 -0500
Message-ID: <1482952410-50003-3-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33931 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751916AbcL1TNe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 14:13:34 -0500
Received: by mail-qt0-f195.google.com with SMTP id p16so24897538qta.1
        for <netdev@vger.kernel.org>; Wed, 28 Dec 2016 11:13:34 -0800 (PST)
In-Reply-To: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
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
index c769f71..bba23db 100644
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
index d7b9342..ef53ede 100644
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
2.8.0.rc3.226.g39d4020
