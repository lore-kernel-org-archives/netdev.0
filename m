From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: rfs: add hash collision detection
Date: Fri, 06 Feb 2015 12:59:01 -0800
Message-ID: <1423256341.31870.160.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:45388 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755368AbbBFU7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 15:59:04 -0500
Received: by iecrd18 with SMTP id rd18so4343376iec.12
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 12:59:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Receive Flow Steering is a nice solution but suffers from
hash collisions when a mix of connected and unconnected traffic
is received on the host, when flow hash table is populated.

Also, clearing flow in inet_release() makes RFS not very good
for short lived flows, as many packets can follow close().
(FIN , ACK packets, ...)

This patch extends the information stored into global hash table
to not only include cpu number, but upper part of the hash value.

I use a 32bit value, and dynamically split it in two parts.

For host with less than 64 possible cpus, this gives 6 bits for the
cpu number, and 26 (32-6) bits for the upper part of the hash.

Since hash bucket selection use low order bits of the hash, we have
a full hash match, if /proc/sys/net/core/rps_sock_flow_entries is big
enough.

If the hash found in flow table does not match, we fallback to RPS (if
it is enabled for the rxqueue).

This means that a packet for an non connected flow can avoid the
IPI through a unrelated/victim CPU.

This also means we no longer have to clear the table at socket
close time, and this helps short lived flows performance.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/tun.c          |    5 ---
 include/linux/netdevice.h  |   34 ++++++++++++------------
 include/net/sock.h         |   24 -----------------
 net/core/dev.c             |   48 +++++++++++++++++++----------------
 net/core/sysctl_net_core.c |    2 -
 net/ipv4/af_inet.c         |    2 -
 6 files changed, 47 insertions(+), 68 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ad7d3d5f3ee5..857dca47bf80 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -256,7 +256,6 @@ static void tun_flow_delete(struct tun_struct *tun, struct tun_flow_entry *e)
 {
 	tun_debug(KERN_INFO, tun, "delete flow: hash %u index %u\n",
 		  e->rxhash, e->queue_index);
-	sock_rps_reset_flow_hash(e->rps_rxhash);
 	hlist_del_rcu(&e->hash_link);
 	kfree_rcu(e, rcu);
 	--tun->flow_count;
@@ -373,10 +372,8 @@ unlock:
  */
 static inline void tun_flow_save_rps_rxhash(struct tun_flow_entry *e, u32 hash)
 {
-	if (unlikely(e->rps_rxhash != hash)) {
-		sock_rps_reset_flow_hash(e->rps_rxhash);
+	if (unlikely(e->rps_rxhash != hash))
 		e->rps_rxhash = hash;
-	}
 }
 
 /* We try to identify a flow through its rxhash first. The reason that
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ce784d5018e0..ab3b7cef4638 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -644,39 +644,39 @@ struct rps_dev_flow_table {
 /*
  * The rps_sock_flow_table contains mappings of flows to the last CPU
  * on which they were processed by the application (set in recvmsg).
+ * Each entry is a 32bit value. Upper part is the high order bits
+ * of flow hash, lower part is cpu number.
+ * rps_cpu_mask is used to partition the space, depending on number of
+ * possible cpus : rps_cpu_mask = roundup_pow_of_two(nr_cpu_ids) - 1
+ * For example, if 64 cpus are possible, rps_cpu_mask = 0x3f,
+ * meaning we use 32-6=26 bits for the hash.
  */
 struct rps_sock_flow_table {
-	unsigned int mask;
-	u16 ents[0];
+	u32	mask;
+	u32	ents[0];
 };
-#define	RPS_SOCK_FLOW_TABLE_SIZE(_num) (sizeof(struct rps_sock_flow_table) + \
-    ((_num) * sizeof(u16)))
+#define	RPS_SOCK_FLOW_TABLE_SIZE(_num) (offsetof(struct rps_sock_flow_table, ents[_num]))
 
 #define RPS_NO_CPU 0xffff
 
+extern u32 rps_cpu_mask;
+extern struct rps_sock_flow_table __rcu *rps_sock_flow_table;
+
 static inline void rps_record_sock_flow(struct rps_sock_flow_table *table,
 					u32 hash)
 {
 	if (table && hash) {
-		unsigned int cpu, index = hash & table->mask;
+		unsigned int index = hash & table->mask;
+		u32 val = hash & ~rps_cpu_mask;
 
 		/* We only give a hint, preemption can change cpu under us */
-		cpu = raw_smp_processor_id();
+		val |= raw_smp_processor_id();
 
-		if (table->ents[index] != cpu)
-			table->ents[index] = cpu;
+		if (table->ents[index] != val)
+			table->ents[index] = val;
 	}
 }
 
-static inline void rps_reset_sock_flow(struct rps_sock_flow_table *table,
-				       u32 hash)
-{
-	if (table && hash)
-		table->ents[hash & table->mask] = RPS_NO_CPU;
-}
-
-extern struct rps_sock_flow_table __rcu *rps_sock_flow_table;
-
 #ifdef CONFIG_RFS_ACCEL
 bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index, u32 flow_id,
 			 u16 filter_id);
diff --git a/include/net/sock.h b/include/net/sock.h
index d28b8fededd6..e13824570b0f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -857,18 +857,6 @@ static inline void sock_rps_record_flow_hash(__u32 hash)
 #endif
 }
 
-static inline void sock_rps_reset_flow_hash(__u32 hash)
-{
-#ifdef CONFIG_RPS
-	struct rps_sock_flow_table *sock_flow_table;
-
-	rcu_read_lock();
-	sock_flow_table = rcu_dereference(rps_sock_flow_table);
-	rps_reset_sock_flow(sock_flow_table, hash);
-	rcu_read_unlock();
-#endif
-}
-
 static inline void sock_rps_record_flow(const struct sock *sk)
 {
 #ifdef CONFIG_RPS
@@ -876,28 +864,18 @@ static inline void sock_rps_record_flow(const struct sock *sk)
 #endif
 }
 
-static inline void sock_rps_reset_flow(const struct sock *sk)
-{
-#ifdef CONFIG_RPS
-	sock_rps_reset_flow_hash(sk->sk_rxhash);
-#endif
-}
-
 static inline void sock_rps_save_rxhash(struct sock *sk,
 					const struct sk_buff *skb)
 {
 #ifdef CONFIG_RPS
-	if (unlikely(sk->sk_rxhash != skb->hash)) {
-		sock_rps_reset_flow(sk);
+	if (unlikely(sk->sk_rxhash != skb->hash))
 		sk->sk_rxhash = skb->hash;
-	}
 #endif
 }
 
 static inline void sock_rps_reset_rxhash(struct sock *sk)
 {
 #ifdef CONFIG_RPS
-	sock_rps_reset_flow(sk);
 	sk->sk_rxhash = 0;
 #endif
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index a3a96ffc67f4..8be38675e1a8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3030,6 +3030,8 @@ static inline void ____napi_schedule(struct softnet_data *sd,
 /* One global table that all flow-based protocols share. */
 struct rps_sock_flow_table __rcu *rps_sock_flow_table __read_mostly;
 EXPORT_SYMBOL(rps_sock_flow_table);
+u32 rps_cpu_mask __read_mostly;
+EXPORT_SYMBOL(rps_cpu_mask);
 
 struct static_key rps_needed __read_mostly;
 
@@ -3086,16 +3088,17 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		       struct rps_dev_flow **rflowp)
 {
-	struct netdev_rx_queue *rxqueue;
-	struct rps_map *map;
+	const struct rps_sock_flow_table *sock_flow_table;
+	struct netdev_rx_queue *rxqueue = dev->_rx;
 	struct rps_dev_flow_table *flow_table;
-	struct rps_sock_flow_table *sock_flow_table;
+	struct rps_map *map;
 	int cpu = -1;
-	u16 tcpu;
+	u32 tcpu;
 	u32 hash;
 
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index = skb_get_rx_queue(skb);
+
 		if (unlikely(index >= dev->real_num_rx_queues)) {
 			WARN_ONCE(dev->real_num_rx_queues > 1,
 				  "%s received packet on queue %u, but number "
@@ -3103,39 +3106,40 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 				  dev->name, index, dev->real_num_rx_queues);
 			goto done;
 		}
-		rxqueue = dev->_rx + index;
-	} else
-		rxqueue = dev->_rx;
+		rxqueue += index;
+	}
 
+	/* Avoid computing hash if RFS/RPS is not active for this rxqueue */
+
+	flow_table = rcu_dereference(rxqueue->rps_flow_table);
 	map = rcu_dereference(rxqueue->rps_map);
-	if (map) {
-		if (map->len == 1 &&
-		    !rcu_access_pointer(rxqueue->rps_flow_table)) {
-			tcpu = map->cpus[0];
-			if (cpu_online(tcpu))
-				cpu = tcpu;
-			goto done;
-		}
-	} else if (!rcu_access_pointer(rxqueue->rps_flow_table)) {
+	if (!flow_table && !map)
 		goto done;
-	}
 
 	skb_reset_network_header(skb);
 	hash = skb_get_hash(skb);
 	if (!hash)
 		goto done;
 
-	flow_table = rcu_dereference(rxqueue->rps_flow_table);
 	sock_flow_table = rcu_dereference(rps_sock_flow_table);
 	if (flow_table && sock_flow_table) {
-		u16 next_cpu;
 		struct rps_dev_flow *rflow;
+		u32 next_cpu;
+		u32 ident;
+
+		/* First check into global flow table if there is a match */
+		ident = sock_flow_table->ents[hash & sock_flow_table->mask];
+		if ((ident ^ hash) & ~rps_cpu_mask)
+			goto try_rps;
 
+		next_cpu = ident & rps_cpu_mask;
+
+		/* OK, now we know there is a match,
+		 * we can look at the local (per receive queue) flow table
+		 */
 		rflow = &flow_table->flows[hash & flow_table->mask];
 		tcpu = rflow->cpu;
 
-		next_cpu = sock_flow_table->ents[hash & sock_flow_table->mask];
-
 		/*
 		 * If the desired CPU (where last recvmsg was done) is
 		 * different from current CPU (one in the rx-queue flow
@@ -3162,6 +3166,8 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		}
 	}
 
+try_rps:
+
 	if (map) {
 		tcpu = map->cpus[reciprocal_scale(hash, map->len)];
 		if (cpu_online(tcpu)) {
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index fde21d19e61b..7a31be5e361f 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -65,7 +65,7 @@ static int rps_sock_flow_sysctl(struct ctl_table *table, int write,
 					mutex_unlock(&sock_flow_mutex);
 					return -ENOMEM;
 				}
-
+				rps_cpu_mask = roundup_pow_of_two(nr_cpu_ids) - 1;
 				sock_table->mask = size - 1;
 			} else
 				sock_table = orig_sock_table;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index a44773c8346c..d2e49baaff63 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -395,8 +395,6 @@ int inet_release(struct socket *sock)
 	if (sk) {
 		long timeout;
 
-		sock_rps_reset_flow(sk);
-
 		/* Applications forget to leave groups before exiting */
 		ip_mc_drop_socket(sk);
 
