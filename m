From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 1/5] net: sched: replace NCLS macro with tc_nocls bit flag
Date: Mon,  4 May 2015 20:48:34 +0200
Message-ID: <1430765318-13788-2-git-send-email-fw@strlen.de>
References: <1430765318-13788-1-git-send-email-fw@strlen.de>
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46864 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751251AbbEDSsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 14:48:51 -0400
In-Reply-To: <1430765318-13788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ifb.c                    | 2 +-
 drivers/staging/octeon/ethernet-tx.c | 1 +
 include/linux/skbuff.h               | 5 ++++-
 include/uapi/linux/pkt_cls.h         | 2 ++
 net/core/dev.c                       | 4 ++--
 net/sched/act_api.c                  | 4 ++--
 6 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 94570aa..3ed70302 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -82,7 +82,7 @@ static void ri_tasklet(unsigned long dev)
 		u32 from = G_TC_FROM(skb->tc_verd);
 
 		skb->tc_verd = 0;
-		skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
+		skb->tc_nocls = 1;
 
 		u64_stats_update_begin(&dp->tsync);
 		dp->tx_packets++;
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 5b9ac1f..24e0ac6 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -403,6 +403,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 #ifdef CONFIG_NET_SCHED
 	skb->tc_index = 0;
 #ifdef CONFIG_NET_CLS_ACT
+	skb->tc_nocls = 0;
 	skb->tc_verd = 0;
 #endif /* CONFIG_NET_CLS_ACT */
 #endif /* CONFIG_NET_SCHED */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index acb83e2..c2112cd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -487,6 +487,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@hash: the packet hash
  *	@queue_mapping: Queue mapping for multiqueue devices
  *	@xmit_more: More SKBs are pending for this queue
+ *	@tc_nocls: skip classification on ingress
  *	@ndisc_nodetype: router type (from link layer)
  *	@ooo_okay: allow the mapping of a socket to a queue to be changed
  *	@l4_hash: indicate hash is a canonical 4-tuple hash over transport
@@ -566,8 +567,10 @@ struct sk_buff {
 				fclone:2,
 				peeked:1,
 				head_frag:1,
+#ifdef CONFIG_NET_CLS_ACT
+				tc_nocls:1,
+#endif
 				xmit_more:1;
-	/* one bit hole */
 	kmemcheck_bitfield_end(flags1);
 
 	/* fields enclosed in headers_start/headers_end are copied
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 596ffa0..ef8eb88 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -61,9 +61,11 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
 #define AT_INGRESS	0x1
 #define AT_EGRESS	0x2
 
+#ifndef __KERNEL__
 #define TC_NCLS          _TC_MAKEMASK1(8)
 #define SET_TC_NCLS(v)   ( TC_NCLS | (v & ~TC_NCLS))
 #define CLR_TC_NCLS(v)   ( v & ~TC_NCLS)
+#endif
 
 #ifndef __KERNEL__
 #define S_TC_RTTL          _TC_MAKE32(9)
diff --git a/net/core/dev.c b/net/core/dev.c
index 862875e..68bf73a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3678,8 +3678,8 @@ another_round:
 	}
 
 #ifdef CONFIG_NET_CLS_ACT
-	if (skb->tc_verd & TC_NCLS) {
-		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
+	if (skb->tc_nocls) {
+		skb->tc_nocls = 0;
 		goto ncls;
 	}
 #endif
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index af427a3..022ed23 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -384,8 +384,8 @@ int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
 	const struct tc_action *a;
 	int ret = -1;
 
-	if (skb->tc_verd & TC_NCLS) {
-		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
+	if (skb->tc_nocls) {
+		skb->tc_nocls = 0;
 		ret = TC_ACT_OK;
 		goto exec_done;
 	}
-- 
2.0.5
