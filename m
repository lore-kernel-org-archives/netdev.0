From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/4 v3] net: Change skb_get_rxhash to skb_get_hash
Date: Sun, 15 Dec 2013 22:12:06 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312152207080.20516@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:47758 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714Ab3LPGMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 01:12:09 -0500
Received: by mail-qa0-f73.google.com with SMTP id o15so164467qap.4
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 22:12:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing name of function as part of making the hash in skbuff to be
generic property, not just for receive path.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/macvtap.c     | 2 +-
 drivers/net/tun.c         | 4 ++--
 drivers/net/vxlan.c       | 2 +-
 include/linux/skbuff.h    | 6 +++---
 net/core/dev.c            | 4 ++--
 net/core/flow_dissector.c | 6 +++---
 net/packet/af_packet.c    | 4 ++--
 net/sched/cls_flow.c      | 2 +-
 net/sched/em_meta.c       | 2 +-
 net/sched/sch_fq.c        | 2 +-
 10 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 64409af..431f58c 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -224,7 +224,7 @@ static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
 		goto out;
 
 	/* Check if we can use flow to select a queue */
-	rxq = skb_get_rxhash(skb);
+	rxq = skb_get_hash(skb);
 	if (rxq) {
 		tap = rcu_dereference(vlan->taps[rxq % numvtaps]);
 		goto out;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3c5a8d8..8569da2 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -358,7 +358,7 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
 	rcu_read_lock();
 	numqueues = ACCESS_ONCE(tun->numqueues);
 
-	txq = skb_get_rxhash(skb);
+	txq = skb_get_hash(skb);
 	if (txq) {
 		e = tun_flow_find(&tun->flows[tun_hashfn(txq)], txq);
 		if (e)
@@ -1146,7 +1146,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	skb_reset_network_header(skb);
 	skb_probe_transport_header(skb, 0);
 
-	rxhash = skb_get_rxhash(skb);
+	rxhash = skb_get_hash(skb);
 	netif_rx_ni(skb);
 
 	tun->dev->stats.rx_packets++;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 58f6a0c..b247a7a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1405,7 +1405,7 @@ __be16 vxlan_src_port(__u16 port_min, __u16 port_max, struct sk_buff *skb)
 	unsigned int range = (port_max - port_min) + 1;
 	u32 hash;
 
-	hash = skb_get_rxhash(skb);
+	hash = skb_get_hash(skb);
 	if (!hash)
 		hash = jhash(skb->data, 2 * ETH_ALEN,
 			     (__force u32) skb->protocol);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 77c7aae..4725b95 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -703,11 +703,11 @@ unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
 			   unsigned int to, struct ts_config *config,
 			   struct ts_state *state);
 
-void __skb_get_rxhash(struct sk_buff *skb);
-static inline __u32 skb_get_rxhash(struct sk_buff *skb)
+void __skb_get_hash(struct sk_buff *skb);
+static inline __u32 skb_get_hash(struct sk_buff *skb)
 {
 	if (!skb->l4_rxhash)
-		__skb_get_rxhash(skb);
+		__skb_get_hash(skb);
 
 	return skb->rxhash;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 9d4369e..c482fe8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3006,7 +3006,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	}
 
 	skb_reset_network_header(skb);
-	if (!skb_get_rxhash(skb))
+	if (!skb_get_hash(skb))
 		goto done;
 
 	flow_table = rcu_dereference(rxqueue->rps_flow_table);
@@ -3151,7 +3151,7 @@ static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen)
 	rcu_read_lock();
 	fl = rcu_dereference(sd->flow_limit);
 	if (fl) {
-		new_flow = skb_get_rxhash(skb) & (fl->num_buckets - 1);
+		new_flow = skb_get_hash(skb) & (fl->num_buckets - 1);
 		old_flow = fl->history[fl->history_head];
 		fl->history[fl->history_head] = new_flow;
 
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index d6ef173..b324bfa 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -202,12 +202,12 @@ static __always_inline u32 __flow_hash_1word(u32 a)
 }
 
 /*
- * __skb_get_rxhash: calculate a flow hash based on src/dst addresses
+ * __skb_get_hash: calculate a flow hash based on src/dst addresses
  * and src/dst port numbers.  Sets rxhash in skb to non-zero hash value
  * on success, zero indicates no valid hash.  Also, sets l4_rxhash in skb
  * if hash is a canonical 4-tuple hash over transport ports.
  */
-void __skb_get_rxhash(struct sk_buff *skb)
+void __skb_get_hash(struct sk_buff *skb)
 {
 	struct flow_keys keys;
 	u32 hash;
@@ -234,7 +234,7 @@ void __skb_get_rxhash(struct sk_buff *skb)
 
 	skb->rxhash = hash;
 }
-EXPORT_SYMBOL(__skb_get_rxhash);
+EXPORT_SYMBOL(__skb_get_hash);
 
 /*
  * Returns a Tx hash based on the given packet descriptor a Tx queues' number
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index cc803c6..24675f0 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -963,7 +963,7 @@ static void prb_clear_blk_fill_status(struct packet_ring_buffer *rb)
 static void prb_fill_rxhash(struct tpacket_kbdq_core *pkc,
 			struct tpacket3_hdr *ppd)
 {
-	ppd->hv1.tp_rxhash = skb_get_rxhash(pkc->skb);
+	ppd->hv1.tp_rxhash = skb_get_hash(pkc->skb);
 }
 
 static void prb_clear_rxhash(struct tpacket_kbdq_core *pkc,
@@ -1295,7 +1295,7 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 			if (!skb)
 				return 0;
 		}
-		skb_get_rxhash(skb);
+		skb_get_hash(skb);
 		idx = fanout_demux_hash(f, skb, num);
 		break;
 	case PACKET_FANOUT_LB:
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 7881e2f..83a6322 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -220,7 +220,7 @@ static u32 flow_get_vlan_tag(const struct sk_buff *skb)
 
 static u32 flow_get_rxhash(struct sk_buff *skb)
 {
-	return skb_get_rxhash(skb);
+	return skb_get_hash(skb);
 }
 
 static u32 flow_key_get(struct sk_buff *skb, int key, struct flow_keys *flow)
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 382519a..9b8c0b0 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -222,7 +222,7 @@ META_COLLECTOR(int_maclen)
 
 META_COLLECTOR(int_rxhash)
 {
-	dst->value = skb_get_rxhash(skb);
+	dst->value = skb_get_hash(skb);
 }
 
 /**************************************************************************
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 95d8439..95ca82e 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -225,7 +225,7 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
 		/* By forcing low order bit to 1, we make sure to not
 		 * collide with a local flow (socket pointers are word aligned)
 		 */
-		sk = (struct sock *)(skb_get_rxhash(skb) | 1L);
+		sk = (struct sock *)(skb_get_hash(skb) | 1L);
 	}
 
 	root = &q->fq_root[hash_32((u32)(long)sk, q->fq_trees_log)];
-- 
1.8.5.1
