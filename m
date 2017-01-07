From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 3/6] net-tc: extract skip classify bit from tc_verd
Date: Sat,  7 Jan 2017 17:06:35 -0500
Message-ID: <20170107220638.61314-4-willemdebruijn.kernel@gmail.com>
References: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com,
        eric.dumazet@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35212 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932794AbdAGWGp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 17:06:45 -0500
Received: by mail-qt0-f193.google.com with SMTP id f4so6982220qte.2
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 14:06:45 -0800 (PST)
In-Reply-To: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Packets sent by the IFB device skip subsequent tc classification.
A single bit governs this state. Move it out of tc_verd in
anticipation of removing that __u16 completely.

The new bitfield tc_skip_classify temporarily uses one bit of a
hole, until tc_verd is removed completely in a follow-up patch.

Remove the bit hole comment. It could be 2, 3, 4 or 5 bits long.
With that many options, little value in documenting it.

Introduce a helper function to deduplicate the logic in the two
sites that check this bit.

The field tc_skip_classify is set only in IFB on skbs cloned in
act_mirred, so original packet sources do not have to clear the
bit when reusing packets (notably, pktgen and octeon).

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ifb.c            |  2 +-
 include/linux/skbuff.h       |  5 ++++-
 include/net/sch_generic.h    | 11 +++++++++++
 include/uapi/linux/pkt_cls.h |  6 ------
 net/core/dev.c               | 10 +++-------
 net/sched/act_api.c          | 11 ++++-------
 6 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 66c0eeafcb5d..4299ac163376 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -81,7 +81,7 @@ static void ifb_ri_tasklet(unsigned long _txp)
 		u32 from = G_TC_FROM(skb->tc_verd);
 
 		skb->tc_verd = 0;
-		skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
+		skb->tc_skip_classify = 1;
 
 		u64_stats_update_begin(&txp->tsync);
 		txp->tx_packets++;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b53c0cfd417e..570f60ec6cb4 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -589,6 +589,7 @@ static inline bool skb_mstamp_after(const struct skb_mstamp *t1,
  *	@pkt_type: Packet class
  *	@fclone: skbuff clone status
  *	@ipvs_property: skbuff is owned by ipvs
+ *	@tc_skip_classify: do not classify packet. set by IFB device
  *	@peeked: this packet has been seen already, so stats have been
  *		done for it, don't do them again
  *	@nf_trace: netfilter packet trace flag
@@ -749,7 +750,9 @@ struct sk_buff {
 #ifdef CONFIG_NET_SWITCHDEV
 	__u8			offload_fwd_mark:1;
 #endif
-	/* 2, 4 or 5 bit hole */
+#ifdef CONFIG_NET_CLS_ACT
+	__u8			tc_skip_classify:1;
+#endif
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 498f81b229a4..857356f2d74b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -418,6 +418,17 @@ static inline bool skb_at_tc_ingress(const struct sk_buff *skb)
 #endif
 }
 
+static inline bool skb_skip_tc_classify(struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (skb->tc_skip_classify) {
+		skb->tc_skip_classify = 0;
+		return true;
+	}
+#endif
+	return false;
+}
+
 /* Reset all TX qdiscs greater then index of a device.  */
 static inline void qdisc_reset_all_tx_gt(struct net_device *dev, unsigned int i)
 {
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index bba23dbb3ab6..1eed5d7509bc 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -22,8 +22,6 @@ bit 6,7: Where this packet was last seen
 1: on the Ingress
 2: on the Egress
 
-bit 8: when set --> Request not to classify on ingress. 
-
  *
  * */
 
@@ -36,10 +34,6 @@ bit 8: when set --> Request not to classify on ingress.
 #define AT_INGRESS	0x1
 #define AT_EGRESS	0x2
 
-#define TC_NCLS          _TC_MAKEMASK1(8)
-#define SET_TC_NCLS(v)   ( TC_NCLS | (v & ~TC_NCLS))
-#define CLR_TC_NCLS(v)   ( v & ~TC_NCLS)
-
 #define S_TC_AT          _TC_MAKE32(12)
 #define M_TC_AT          _TC_MAKEMASK(2,S_TC_AT)
 #define G_TC_AT(x)       _TC_GETVALUE(x,S_TC_AT,M_TC_AT)
diff --git a/net/core/dev.c b/net/core/dev.c
index 56818f7eab2b..e39e35d2e082 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4093,12 +4093,8 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 			goto out;
 	}
 
-#ifdef CONFIG_NET_CLS_ACT
-	if (skb->tc_verd & TC_NCLS) {
-		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
-		goto ncls;
-	}
-#endif
+	if (skb_skip_tc_classify(skb))
+		goto skip_classify;
 
 	if (pfmemalloc)
 		goto skip_taps;
@@ -4128,8 +4124,8 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 #endif
 #ifdef CONFIG_NET_CLS_ACT
 	skb->tc_verd = 0;
-ncls:
 #endif
+skip_classify:
 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
 		goto drop;
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 2095c83ce773..f04715a57300 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -426,11 +426,9 @@ int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
 {
 	int ret = -1, i;
 
-	if (skb->tc_verd & TC_NCLS) {
-		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
-		ret = TC_ACT_OK;
-		goto exec_done;
-	}
+	if (skb_skip_tc_classify(skb))
+		return TC_ACT_OK;
+
 	for (i = 0; i < nr_actions; i++) {
 		const struct tc_action *a = actions[i];
 
@@ -439,9 +437,8 @@ int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
 		if (ret == TC_ACT_REPEAT)
 			goto repeat;	/* we need a ttl - JHS */
 		if (ret != TC_ACT_PIPE)
-			goto exec_done;
+			break;
 	}
-exec_done:
 	return ret;
 }
 EXPORT_SYMBOL(tcf_action_exec);
-- 
2.11.0.390.gc69c2f50cf-goog
