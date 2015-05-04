From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 3/5] net: sched: remove FROM INGRESS/EGRESS
Date: Mon,  4 May 2015 20:48:36 +0200
Message-ID: <1430765318-13788-4-git-send-email-fw@strlen.de>
References: <1430765318-13788-1-git-send-email-fw@strlen.de>
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46872 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751930AbbEDSs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 14:48:57 -0400
In-Reply-To: <1430765318-13788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use a single bit marker to indicate if skb originates from rx path.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ifb.c                    | 12 ++++--------
 drivers/staging/octeon/ethernet-tx.c |  1 +
 include/linux/skbuff.h               |  6 +++++-
 include/uapi/linux/pkt_cls.h         |  2 +-
 net/sched/act_mirred.c               |  2 +-
 net/sched/sch_netem.c                |  2 +-
 6 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 3ed70302..5ec6797 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -79,8 +79,6 @@ static void ri_tasklet(unsigned long dev)
 	}
 
 	while ((skb = __skb_dequeue(&dp->tq)) != NULL) {
-		u32 from = G_TC_FROM(skb->tc_verd);
-
 		skb->tc_verd = 0;
 		skb->tc_nocls = 1;
 
@@ -102,13 +100,12 @@ static void ri_tasklet(unsigned long dev)
 		rcu_read_unlock();
 		skb->skb_iif = _dev->ifindex;
 
-		if (from & AT_EGRESS) {
+		if (!skb->tc_from_ingress) {
 			dev_queue_xmit(skb);
-		} else if (from & AT_INGRESS) {
+		} else {
 			skb_pull(skb, skb->mac_len);
 			netif_receive_skb(skb);
-		} else
-			BUG();
+		}
 	}
 
 	if (__netif_tx_trylock(txq)) {
@@ -193,14 +190,13 @@ static void ifb_setup(struct net_device *dev)
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
-	u32 from = G_TC_FROM(skb->tc_verd);
 
 	u64_stats_update_begin(&dp->rsync);
 	dp->rx_packets++;
 	dp->rx_bytes += skb->len;
 	u64_stats_update_end(&dp->rsync);
 
-	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->skb_iif) {
+	if (!skb->skb_iif) {
 		dev_kfree_skb(skb);
 		dev->stats.rx_dropped++;
 		return NETDEV_TX_OK;
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 24e0ac6..bcefebd 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -404,6 +404,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb->tc_index = 0;
 #ifdef CONFIG_NET_CLS_ACT
 	skb->tc_nocls = 0;
+	skb->tc_from_ingress = 0;
 	skb->tc_verd = 0;
 #endif /* CONFIG_NET_CLS_ACT */
 #endif /* CONFIG_NET_SCHED */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c2112cd..911d84e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -487,6 +487,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@hash: the packet hash
  *	@queue_mapping: Queue mapping for multiqueue devices
  *	@xmit_more: More SKBs are pending for this queue
+ *	@tc_from_ingress: skb is processed during rx, not transmit
  *	@tc_nocls: skip classification on ingress
  *	@ndisc_nodetype: router type (from link layer)
  *	@ooo_okay: allow the mapping of a socket to a queue to be changed
@@ -617,7 +618,10 @@ struct sk_buff {
 	__u8			ipvs_property:1;
 	__u8			inner_protocol_type:1;
 	__u8			remcsum_offload:1;
-	/* 3 or 5 bit hole */
+#ifdef CONFIG_NET_CLS_ACT
+	__u8			tc_from_ingress:1;
+#endif
+	/* 2 or 4 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 02dca42..ac88cbb 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -50,13 +50,13 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
 #define G_TC_VERD(x)       _TC_GETVALUE(x,S_TC_VERD,M_TC_VERD)
 #define V_TC_VERD(x)       _TC_MAKEVALUE(x,S_TC_VERD)
 #define SET_TC_VERD(v,n)   ((V_TC_VERD(n)) | (v & ~M_TC_VERD))
-#endif
 
 #define S_TC_FROM          _TC_MAKE32(6)
 #define M_TC_FROM          _TC_MAKEMASK(2,S_TC_FROM)
 #define G_TC_FROM(x)       _TC_GETVALUE(x,S_TC_FROM,M_TC_FROM)
 #define V_TC_FROM(x)       _TC_MAKEVALUE(x,S_TC_FROM)
 #define SET_TC_FROM(v,n)   ((V_TC_FROM(n)) | (v & ~M_TC_FROM))
+#endif
 #define AT_STACK	0x0
 #define AT_INGRESS	0x1
 #define AT_EGRESS	0x2
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index a42a3b2..9d51baa 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -162,7 +162,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 
 	/* mirror is always swallowed */
 	if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
-		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
+		skb2->tc_from_ingress = at & AT_INGRESS ? 1 : 0;
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 956ead2..b5e4396 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -588,7 +588,7 @@ deliver:
 			 * If it's at ingress let's pretend the delay is
 			 * from the network (tstamp will be updated).
 			 */
-			if (G_TC_FROM(skb->tc_verd) & AT_INGRESS)
+			if (skb->tc_from_ingress)
 				skb->tstamp.tv64 = 0;
 #endif
 
-- 
2.0.5
