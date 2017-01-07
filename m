From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 4/6] net-tc: convert tc_verd to integer bitfields
Date: Sat,  7 Jan 2017 17:06:36 -0500
Message-ID: <20170107220638.61314-5-willemdebruijn.kernel@gmail.com>
References: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com,
        eric.dumazet@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33804 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932798AbdAGWGq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 17:06:46 -0500
Received: by mail-qk0-f195.google.com with SMTP id e1so11295524qkh.1
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 14:06:46 -0800 (PST)
In-Reply-To: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Extract the remaining two fields from tc_verd and remove the __u16
completely. TC_AT and TC_FROM are converted to equivalent two-bit
integer fields tc_at and tc_from. Where possible, use existing
helper skb_at_tc_ingress when reading tc_at. Introduce helper
skb_reset_tc to clear fields.

Not documenting tc_from and tc_at, because they will be replaced
with single bit fields in follow-on patches.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ifb.c                    |  7 +++----
 drivers/staging/octeon/ethernet-tx.c |  5 ++---
 include/linux/skbuff.h               |  6 ++----
 include/net/sch_generic.h            | 10 +++++++++-
 include/uapi/linux/pkt_cls.h         | 31 -------------------------------
 net/core/dev.c                       | 10 ++++------
 net/core/pktgen.c                    |  4 +---
 net/core/skbuff.c                    |  3 ---
 net/sched/act_ife.c                  |  7 +++----
 net/sched/act_mirred.c               |  9 ++++-----
 net/sched/sch_netem.c                |  2 +-
 11 files changed, 29 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 4299ac163376..90ad8791bc99 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -78,9 +78,9 @@ static void ifb_ri_tasklet(unsigned long _txp)
 	}
 
 	while ((skb = __skb_dequeue(&txp->tq)) != NULL) {
-		u32 from = G_TC_FROM(skb->tc_verd);
+		u32 from = skb->tc_from;
 
-		skb->tc_verd = 0;
+		skb_reset_tc(skb);
 		skb->tc_skip_classify = 1;
 
 		u64_stats_update_begin(&txp->tsync);
@@ -241,7 +241,6 @@ static void ifb_setup(struct net_device *dev)
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ifb_dev_private *dp = netdev_priv(dev);
-	u32 from = G_TC_FROM(skb->tc_verd);
 	struct ifb_q_private *txp = dp->tx_private + skb_get_queue_mapping(skb);
 
 	u64_stats_update_begin(&txp->rsync);
@@ -249,7 +248,7 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 	txp->rx_bytes += skb->len;
 	u64_stats_update_end(&txp->rsync);
 
-	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->skb_iif) {
+	if (skb->tc_from == AT_STACK || !skb->skb_iif) {
 		dev_kfree_skb(skb);
 		dev->stats.rx_dropped++;
 		return NETDEV_TX_OK;
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 6b4c20872323..0b8053205091 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -23,6 +23,7 @@
 #endif /* CONFIG_XFRM */
 
 #include <linux/atomic.h>
+#include <net/sch_generic.h>
 
 #include <asm/octeon/octeon.h>
 
@@ -369,9 +370,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 
 #ifdef CONFIG_NET_SCHED
 	skb->tc_index = 0;
-#ifdef CONFIG_NET_CLS_ACT
-	skb->tc_verd = 0;
-#endif /* CONFIG_NET_CLS_ACT */
+	skb_reset_tc(skb);
 #endif /* CONFIG_NET_SCHED */
 #endif /* REUSE_SKBUFFS_WITHOUT_FREE */
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 570f60ec6cb4..f738d09947b2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -599,7 +599,6 @@ static inline bool skb_mstamp_after(const struct skb_mstamp *t1,
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
  *	@skb_iif: ifindex of device we arrived on
  *	@tc_index: Traffic control index
- *	@tc_verd: traffic control verdict
  *	@hash: the packet hash
  *	@queue_mapping: Queue mapping for multiqueue devices
  *	@xmit_more: More SKBs are pending for this queue
@@ -752,13 +751,12 @@ struct sk_buff {
 #endif
 #ifdef CONFIG_NET_CLS_ACT
 	__u8			tc_skip_classify:1;
+	__u8			tc_at:2;
+	__u8			tc_from:2;
 #endif
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
-#ifdef CONFIG_NET_CLS_ACT
-	__u16			tc_verd;	/* traffic control verdict */
-#endif
 #endif
 
 	union {
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 857356f2d74b..f80dba516964 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -409,10 +409,18 @@ bool tcf_destroy(struct tcf_proto *tp, bool force);
 void tcf_destroy_chain(struct tcf_proto __rcu **fl);
 int skb_do_redirect(struct sk_buff *);
 
+static inline void skb_reset_tc(struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	skb->tc_at = 0;
+	skb->tc_from = 0;
+#endif
+}
+
 static inline bool skb_at_tc_ingress(const struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	return G_TC_AT(skb->tc_verd) & AT_INGRESS;
+	return skb->tc_at & AT_INGRESS;
 #else
 	return false;
 #endif
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 1eed5d7509bc..cee753a7a40c 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -5,40 +5,9 @@
 #include <linux/pkt_sched.h>
 
 #ifdef __KERNEL__
-/* I think i could have done better macros ; for now this is stolen from
- * some arch/mips code - jhs
-*/
-#define _TC_MAKE32(x) ((x))
-
-#define _TC_MAKEMASK1(n) (_TC_MAKE32(1) << _TC_MAKE32(n))
-#define _TC_MAKEMASK(v,n) (_TC_MAKE32((_TC_MAKE32(1)<<(v))-1) << _TC_MAKE32(n))
-#define _TC_MAKEVALUE(v,n) (_TC_MAKE32(v) << _TC_MAKE32(n))
-#define _TC_GETVALUE(v,n,m) ((_TC_MAKE32(v) & _TC_MAKE32(m)) >> _TC_MAKE32(n))
-
-/* verdict bit breakdown 
- *
-bit 6,7: Where this packet was last seen 
-0: Above the transmit example at the socket level
-1: on the Ingress
-2: on the Egress
-
- *
- * */
-
-#define S_TC_FROM          _TC_MAKE32(6)
-#define M_TC_FROM          _TC_MAKEMASK(2,S_TC_FROM)
-#define G_TC_FROM(x)       _TC_GETVALUE(x,S_TC_FROM,M_TC_FROM)
-#define V_TC_FROM(x)       _TC_MAKEVALUE(x,S_TC_FROM)
-#define SET_TC_FROM(v,n)   ((V_TC_FROM(n)) | (v & ~M_TC_FROM))
 #define AT_STACK	0x0
 #define AT_INGRESS	0x1
 #define AT_EGRESS	0x2
-
-#define S_TC_AT          _TC_MAKE32(12)
-#define M_TC_AT          _TC_MAKEMASK(2,S_TC_AT)
-#define G_TC_AT(x)       _TC_GETVALUE(x,S_TC_AT,M_TC_AT)
-#define V_TC_AT(x)       _TC_MAKEVALUE(x,S_TC_AT)
-#define SET_TC_AT(v,n)   ((V_TC_AT(n)) | (v & ~M_TC_AT))
 #endif
 
 /* Action attributes */
diff --git a/net/core/dev.c b/net/core/dev.c
index e39e35d2e082..8b5d6d033473 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3153,7 +3153,7 @@ sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
 	if (!cl)
 		return skb;
 
-	/* skb->tc_verd and qdisc_skb_cb(skb)->pkt_len were already set
+	/* skb->tc_at and qdisc_skb_cb(skb)->pkt_len were already set
 	 * earlier by the caller.
 	 */
 	qdisc_bstats_cpu_update(cl->q, skb);
@@ -3320,7 +3320,7 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 	qdisc_pkt_len_init(skb);
 #ifdef CONFIG_NET_CLS_ACT
-	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
+	skb->tc_at = AT_EGRESS;
 # ifdef CONFIG_NET_EGRESS
 	if (static_key_false(&egress_needed)) {
 		skb = sch_handle_egress(skb, &rc, dev);
@@ -3920,7 +3920,7 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 	}
 
 	qdisc_skb_cb(skb)->pkt_len = skb->len;
-	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
+	skb->tc_at = AT_INGRESS;
 	qdisc_bstats_cpu_update(cl->q, skb);
 
 	switch (tc_classify(skb, cl, &cl_res, false)) {
@@ -4122,9 +4122,7 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 			goto out;
 	}
 #endif
-#ifdef CONFIG_NET_CLS_ACT
-	skb->tc_verd = 0;
-#endif
+	skb_reset_tc(skb);
 skip_classify:
 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
 		goto drop;
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8e69ce472236..96947f5d41e4 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3439,9 +3439,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 			/* skb was 'freed' by stack, so clean few
 			 * bits and reuse it
 			 */
-#ifdef CONFIG_NET_CLS_ACT
-			skb->tc_verd = 0; /* reset reclass/redir ttl */
-#endif
+			skb_reset_tc(skb);
 		} while (--burst > 0);
 		goto out; /* Skips xmit_mode M_START_XMIT */
 	} else if (pkt_dev->xmit_mode == M_QUEUE_XMIT) {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5a03730fbc1a..adec4bf807d8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -878,9 +878,6 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #endif
 #ifdef CONFIG_NET_SCHED
 	CHECK_SKB_FIELD(tc_index);
-#ifdef CONFIG_NET_CLS_ACT
-	CHECK_SKB_FIELD(tc_verd);
-#endif
 #endif
 
 }
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 80b848d3f096..921fb20eaa7c 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -736,12 +736,11 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 	u16 metalen = ife_get_sz(skb, ife);
 	int hdrm = metalen + skb->dev->hard_header_len + IFE_METAHDRLEN;
 	unsigned int skboff = skb->dev->hard_header_len;
-	u32 at = G_TC_AT(skb->tc_verd);
 	int new_len = skb->len + hdrm;
 	bool exceed_mtu = false;
 	int err;
 
-	if (at & AT_EGRESS) {
+	if (!skb_at_tc_ingress(skb)) {
 		if (new_len > skb->dev->mtu)
 			exceed_mtu = true;
 	}
@@ -773,7 +772,7 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 		return TC_ACT_SHOT;
 	}
 
-	if (!(at & AT_EGRESS))
+	if (skb_at_tc_ingress(skb))
 		skb_push(skb, skb->dev->hard_header_len);
 
 	iethh = (struct ethhdr *)skb->data;
@@ -816,7 +815,7 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 		ether_addr_copy(oethh->h_dest, iethh->h_dest);
 	oethh->h_proto = htons(ife->eth_type);
 
-	if (!(at & AT_EGRESS))
+	if (skb_at_tc_ingress(skb))
 		skb_pull(skb, skb->dev->hard_header_len);
 
 	spin_unlock(&ife->tcf_lock);
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 2d9fa6e0a1b4..8543279bba49 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -170,7 +170,6 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	int retval, err = 0;
 	int m_eaction;
 	int mac_len;
-	u32 at;
 
 	tcf_lastuse_update(&m->tcf_tm);
 	bstats_cpu_update(this_cpu_ptr(m->common.cpu_bstats), skb);
@@ -191,7 +190,6 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 		goto out;
 	}
 
-	at = G_TC_AT(skb->tc_verd);
 	skb2 = skb_clone(skb, GFP_ATOMIC);
 	if (!skb2)
 		goto out;
@@ -200,8 +198,9 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	 * and devices expect a mac header on xmit, then mac push/pull is
 	 * needed.
 	 */
-	if (at != tcf_mirred_act_direction(m_eaction) && m_mac_header_xmit) {
-		if (at & AT_EGRESS) {
+	if (skb->tc_at != tcf_mirred_act_direction(m_eaction) &&
+	    m_mac_header_xmit) {
+		if (!skb_at_tc_ingress(skb)) {
 			/* caught at egress, act ingress: pull mac */
 			mac_len = skb_network_header(skb) - skb_mac_header(skb);
 			skb_pull_rcsum(skb2, mac_len);
@@ -213,7 +212,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 
 	/* mirror is always swallowed */
 	if (tcf_mirred_is_act_redirect(m_eaction))
-		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
+		skb2->tc_from = skb2->tc_at;
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index bcfadfdea8e0..bb5c638b6852 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -626,7 +626,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 			 * If it's at ingress let's pretend the delay is
 			 * from the network (tstamp will be updated).
 			 */
-			if (G_TC_FROM(skb->tc_verd) & AT_INGRESS)
+			if (skb->tc_from & AT_INGRESS)
 				skb->tstamp = 0;
 #endif
 
-- 
2.11.0.390.gc69c2f50cf-goog
