From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 6/6] net-tc: convert tc_from to tc_from_ingress and tc_redirected
Date: Sat,  7 Jan 2017 17:06:38 -0500
Message-ID: <20170107220638.61314-7-willemdebruijn.kernel@gmail.com>
References: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com,
        eric.dumazet@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35646 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932839AbdAGWGx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 17:06:53 -0500
Received: by mail-qk0-f193.google.com with SMTP id u25so66744003qki.2
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 14:06:48 -0800 (PST)
In-Reply-To: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The tc_from field fulfills two roles. It encodes whether a packet was
redirected by an act_mirred device and, if so, whether act_mirred was
called on ingress or egress. Split it into separate fields.

The information is needed by the special IFB loop, where packets are
taken out of the normal path by act_mirred, forwarded to IFB, then
reinjected at their original location (ingress or egress) by IFB.

The IFB device cannot use skb->tc_at_ingress, because that may have
been overwritten as the packet travels from act_mirred to ifb_xmit,
when it passes through tc_classify on the IFB egress path. Cache this
value in skb->tc_from_ingress.

That field is valid only if a packet arriving at ifb_xmit came from
act_mirred. Other packets can be crafted to reach ifb_xmit. These
must be dropped. Set tc_redirected on redirection and drop all packets
that do not have this bit set.

Both fields are set only on cloned skbs in tc actions, so original
packet sources do not have to clear the bit when reusing packets
(notably, pktgen and octeon).

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ifb.c            | 13 +++++--------
 include/linux/skbuff.h       |  5 ++++-
 include/net/sch_generic.h    |  2 +-
 include/uapi/linux/pkt_cls.h |  6 ------
 net/sched/act_mirred.c       |  6 ++++--
 net/sched/sch_netem.c        |  2 +-
 6 files changed, 15 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 90ad8791bc99..193af7483bb0 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -78,9 +78,7 @@ static void ifb_ri_tasklet(unsigned long _txp)
 	}
 
 	while ((skb = __skb_dequeue(&txp->tq)) != NULL) {
-		u32 from = skb->tc_from;
-
-		skb_reset_tc(skb);
+		skb->tc_redirected = 0;
 		skb->tc_skip_classify = 1;
 
 		u64_stats_update_begin(&txp->tsync);
@@ -101,13 +99,12 @@ static void ifb_ri_tasklet(unsigned long _txp)
 		rcu_read_unlock();
 		skb->skb_iif = txp->dev->ifindex;
 
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
@@ -248,7 +245,7 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 	txp->rx_bytes += skb->len;
 	u64_stats_update_end(&txp->rsync);
 
-	if (skb->tc_from == AT_STACK || !skb->skb_iif) {
+	if (!skb->tc_redirected || !skb->skb_iif) {
 		dev_kfree_skb(skb);
 		dev->stats.rx_dropped++;
 		return NETDEV_TX_OK;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index fab3f87e9bd1..3149a88de548 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -591,6 +591,8 @@ static inline bool skb_mstamp_after(const struct skb_mstamp *t1,
  *	@ipvs_property: skbuff is owned by ipvs
  *	@tc_skip_classify: do not classify packet. set by IFB device
  *	@tc_at_ingress: used within tc_classify to distinguish in/egress
+ *	@tc_redirected: packet was redirected by a tc action
+ *	@tc_from_ingress: if tc_redirected, tc_at_ingress at time of redirect
  *	@peeked: this packet has been seen already, so stats have been
  *		done for it, don't do them again
  *	@nf_trace: netfilter packet trace flag
@@ -753,7 +755,8 @@ struct sk_buff {
 #ifdef CONFIG_NET_CLS_ACT
 	__u8			tc_skip_classify:1;
 	__u8			tc_at_ingress:1;
-	__u8			tc_from:2;
+	__u8			tc_redirected:1;
+	__u8			tc_from_ingress:1;
 #endif
 
 #ifdef CONFIG_NET_SCHED
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4bd6d5387209..e2f426f6d62f 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -412,7 +412,7 @@ int skb_do_redirect(struct sk_buff *);
 static inline void skb_reset_tc(struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	skb->tc_from = 0;
+	skb->tc_redirected = 0;
 #endif
 }
 
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index cee753a7a40c..a081efbd61a2 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -4,12 +4,6 @@
 #include <linux/types.h>
 #include <linux/pkt_sched.h>
 
-#ifdef __KERNEL__
-#define AT_STACK	0x0
-#define AT_INGRESS	0x1
-#define AT_EGRESS	0x2
-#endif
-
 /* Action attributes */
 enum {
 	TCA_ACT_UNSPEC,
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index e832c62fd705..84682f02b611 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -211,8 +211,10 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	}
 
 	/* mirror is always swallowed */
-	if (tcf_mirred_is_act_redirect(m_eaction))
-		skb2->tc_from = skb_at_tc_ingress(skb) ? AT_INGRESS : AT_EGRESS;
+	if (tcf_mirred_is_act_redirect(m_eaction)) {
+		skb2->tc_redirected = 1;
+		skb2->tc_from_ingress = skb2->tc_at_ingress;
+	}
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index bb5c638b6852..c8bb62a1e744 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -626,7 +626,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 			 * If it's at ingress let's pretend the delay is
 			 * from the network (tstamp will be updated).
 			 */
-			if (skb->tc_from & AT_INGRESS)
+			if (skb->tc_redirected && skb->tc_from_ingress)
 				skb->tstamp = 0;
 #endif
 
-- 
2.11.0.390.gc69c2f50cf-goog
