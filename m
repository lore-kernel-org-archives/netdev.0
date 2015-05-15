From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 1/3] net: sched: remove FROM INGRESS/EGRESS
Date: Fri, 15 May 2015 10:50:48 +0200
Message-ID: <1431679850-31896-2-git-send-email-fw@strlen.de>
References: <1431679850-31896-1-git-send-email-fw@strlen.de>
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48178 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753875AbbEOIvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 04:51:00 -0400
In-Reply-To: <1431679850-31896-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal explains:
| Since tc can be applied only per netdev, redirecting to ifb from
| many netdevs allows us to provide illusion we can have groupings
| of netdevs.
| The role of ifb is, after completing processing, to return the packet
| the spot it found it in the code path before the redirect
| (i.e if it is on ingress, then it will show up back on ingress;
| likewise if it was on egress).

This ingress/egress information (FROM IN/EGRESS; not to be confused with
AT_INGRESS/EGRESS values returned by G_TC_AT) is set up by the 'mirred'
action to tell IFB at which spot we need to return the packet to.

This change introduces skb->skb_tc_state enum to track which traffic
control processing state this skb is in.

If the mirred action is called via classifiers on ingress (indicated
by G_TC_AT() returning AT_INGRESS) skb_tc_state enters TC_FROM_INGRESS.

If mirred is called from egress path (G_TC_AT returns AT_EGRESS), then
it will be in TC_FROM_EGRESS state.

INGRESS/EGRESS are mutually exclusive.

ifb uses this to decide if it needs to call netif_rx (TC_FROM_INGRESS),
dev_queue_xmit (TC_FROM_EGRESS) or if skb must be dropped (tc_state is 0).

tested via:

ip link set dev ifb0 up
ip link set dev eth1 up
ip addr add  192.168.42.1/24 dev eth1
tc qdisc add dev eth1 root handle 1: htb default 1
tc filter add dev eth1 parent 1: protocol all u32 match u32 0 0 action \
  mirred egress redirect dev ifb0

With help from Jamal Hadi Salim.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ifb.c                    | 18 +++++++++---------
 drivers/staging/octeon/ethernet-tx.c |  1 +
 include/linux/skbuff.h               |  4 +++-
 include/net/pkt_sched.h              |  6 ++++++
 include/uapi/linux/pkt_cls.h         |  2 +-
 net/sched/act_mirred.c               |  9 ++++++---
 net/sched/sch_netem.c                |  2 +-
 7 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 94570aa..bbce359 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -79,8 +79,6 @@ static void ri_tasklet(unsigned long dev)
 	}
 
 	while ((skb = __skb_dequeue(&dp->tq)) != NULL) {
-		u32 from = G_TC_FROM(skb->tc_verd);
-
 		skb->tc_verd = 0;
 		skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
 
@@ -102,13 +100,16 @@ static void ri_tasklet(unsigned long dev)
 		rcu_read_unlock();
 		skb->skb_iif = _dev->ifindex;
 
-		if (from & AT_EGRESS) {
-			dev_queue_xmit(skb);
-		} else if (from & AT_INGRESS) {
+		switch (skb->skb_tc_state) {
+		case TC_FROM_INGRESS:
 			skb_pull(skb, skb->mac_len);
 			netif_receive_skb(skb);
-		} else
-			BUG();
+			break;
+		case TC_FROM_EGRESS:
+			skb->skb_tc_state = 0;
+			dev_queue_xmit(skb);
+			break;
+		}
 	}
 
 	if (__netif_tx_trylock(txq)) {
@@ -193,14 +194,13 @@ static void ifb_setup(struct net_device *dev)
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
-	u32 from = G_TC_FROM(skb->tc_verd);
 
 	u64_stats_update_begin(&dp->rsync);
 	dp->rx_packets++;
 	dp->rx_bytes += skb->len;
 	u64_stats_update_end(&dp->rsync);
 
-	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->skb_iif) {
+	if (!skb->skb_tc_state || !skb->skb_iif) {
 		dev_kfree_skb(skb);
 		dev->stats.rx_dropped++;
 		return NETDEV_TX_OK;
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 5b9ac1f..4656af7 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -403,6 +403,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 #ifdef CONFIG_NET_SCHED
 	skb->tc_index = 0;
 #ifdef CONFIG_NET_CLS_ACT
+	skb->skb_tc_state = 0;
 	skb->tc_verd = 0;
 #endif /* CONFIG_NET_CLS_ACT */
 #endif /* CONFIG_NET_SCHED */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f83aa65..4a1367e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -487,6 +487,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@hash: the packet hash
  *	@queue_mapping: Queue mapping for multiqueue devices
  *	@xmit_more: More SKBs are pending for this queue
+ *	@skb_tc_state: was mirrored (act_mirred)
  *	@ndisc_nodetype: router type (from link layer)
  *	@ooo_okay: allow the mapping of a socket to a queue to be changed
  *	@l4_hash: indicate hash is a canonical 4-tuple hash over transport
@@ -614,7 +615,8 @@ struct sk_buff {
 	__u8			ipvs_property:1;
 	__u8			inner_protocol_type:1;
 	__u8			remcsum_offload:1;
-	/* 3 or 5 bit hole */
+	__u8			skb_tc_state:2;	/* traffic control state enum */
+	/* 1 or 3 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 2342bf1..a4c509d 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -134,4 +134,10 @@ static inline unsigned int psched_mtu(const struct net_device *dev)
 	return dev->mtu + dev->hard_header_len;
 }
 
+enum skb_tc_state {
+	/* set by act_mirred to tell IFB that skb needs to be ... */
+	TC_FROM_INGRESS = 1, /* ... re-injected to local stack */
+	TC_FROM_EGRESS = 2,  /* ... transmitted to device */
+};
+
 #endif
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 39fb53d..3308e89 100644
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
index a42a3b2..34d4320 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -161,9 +161,12 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	}
 
 	/* mirror is always swallowed */
-	if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
-		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
-
+	if (m->tcfm_eaction != TCA_EGRESS_MIRROR) {
+		if (at & AT_INGRESS)
+			skb2->skb_tc_state = TC_FROM_INGRESS;
+		else if (at & AT_EGRESS)
+			skb2->skb_tc_state = TC_FROM_EGRESS;
+	}
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
 	err = dev_queue_xmit(skb2);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 5abd1d9..760cf43 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -588,7 +588,7 @@ deliver:
 			 * If it's at ingress let's pretend the delay is
 			 * from the network (tstamp will be updated).
 			 */
-			if (G_TC_FROM(skb->tc_verd) & AT_INGRESS)
+			if (skb->skb_tc_state == TC_FROM_INGRESS)
 				skb->tstamp.tv64 = 0;
 #endif
 
-- 
2.0.5
