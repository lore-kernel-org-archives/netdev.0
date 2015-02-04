From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] xps: fix xps for stacked devices
Date: Tue, 03 Feb 2015 23:48:24 -0800
Message-ID: <1423036104.907.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:61204 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbbBDHs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 02:48:26 -0500
Received: by mail-ie0-f169.google.com with SMTP id rl12so172640iec.0
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 23:48:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

A typical qdisc setup is the following :

bond0 : bonding device, using HTB hierarchy
eth1/eth2 : slaves, multiqueue NIC, using MQ + FQ qdisc

XPS allows to spread packets on specific tx queues, based on the cpu
doing the send.

Problem is that dequeues from bond0 qdisc can happen on random cpus,
due to the fact that qdisc_run() can dequeue a batch of packets.

CPUA -> queue packet P1 on bond0 qdisc, P1->ooo_okay=1
CPUA -> queue packet P2 on bond0 qdisc, P2->ooo_okay=0

CPUB -> dequeue packet P1 from bond0
        enqueue packet on eth1/eth2
CPUC -> dequeue packet P2 from bond0
        enqueue packet on eth1/eth2 using sk cache (ooo_okay is 0)

get_xps_queue() then might select wrong queue for P1, since current cpu
might be different than CPUA.

P2 might be sent on the old queue (stored in sk->sk_tx_queue_mapping),
if CPUC runs a bit faster (or CPUB spins a bit on qdisc lock)

Effect of this bug is TCP reorders, and more generally not optimal
TX queue placement. (A victim bulk flow can be migrated to the wrong TX
queue for a while)

To fix this, we have to record sender cpu number the first time
dev_queue_xmit() is called for one tx skb.

We can union napi_id (used on receive path) and sender_cpu,
granted we clear sender_cpu in skb_scrub_packet() (credit to Willem for
this union idea)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/linux/skbuff.h    |    7 +++++--
 net/core/flow_dissector.c |    7 ++++++-
 net/core/skbuff.c         |    4 ++++
 3 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85ab7d72b54c2f269812015b19544674bc6dcd72..2748ff63914438268458246adb165e61ed892656 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -626,8 +626,11 @@ struct sk_buff {
 	__u32			hash;
 	__be16			vlan_proto;
 	__u16			vlan_tci;
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	unsigned int	napi_id;
+#if defined(CONFIG_NET_RX_BUSY_POLL) || defined(CONFIG_XPS)
+	union {
+		unsigned int	napi_id;
+		unsigned int	sender_cpu;
+	};
 #endif
 #ifdef CONFIG_NETWORK_SECMARK
 	__u32			secmark;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index beb83d1ac1c688d7b593a5cad85236b6d94c3106..2c35c02a931e227fa368cd346873596d4b037a3d 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -422,7 +422,7 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 	dev_maps = rcu_dereference(dev->xps_maps);
 	if (dev_maps) {
 		map = rcu_dereference(
-		    dev_maps->cpu_map[raw_smp_processor_id()]);
+		    dev_maps->cpu_map[skb->sender_cpu - 1]);
 		if (map) {
 			if (map->len == 1)
 				queue_index = map->queues[0];
@@ -468,6 +468,11 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 {
 	int queue_index = 0;
 
+#ifdef CONFIG_XPS
+	if (skb->sender_cpu == 0)
+		skb->sender_cpu = raw_smp_processor_id() + 1;
+#endif
+
 	if (dev->real_num_tx_queues != 1) {
 		const struct net_device_ops *ops = dev->netdev_ops;
 		if (ops->ndo_select_queue)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a5bff2767f15abe09b5f0d0a3bfecfb5775a4e64..88c613eab142962dc44f2075378fce0b94349e8e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -825,6 +825,9 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	CHECK_SKB_FIELD(napi_id);
 #endif
+#ifdef CONFIG_XPS
+	CHECK_SKB_FIELD(sender_cpu);
+#endif
 #ifdef CONFIG_NET_SCHED
 	CHECK_SKB_FIELD(tc_index);
 #ifdef CONFIG_NET_CLS_ACT
@@ -4169,6 +4172,7 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet)
 	skb->ignore_df = 0;
 	skb_dst_drop(skb);
 	skb->mark = 0;
+	skb->sender_cpu = 0;
 	skb_init_secmark(skb);
 	secpath_reset(skb);
 	nf_reset(skb);
