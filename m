From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: cleanup some rcu_dereference_raw
Date: Fri, 12 Aug 2011 07:30:52 +0200
Message-ID: <1313127052.2669.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39558 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100Ab1HLFa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 01:30:57 -0400
Received: by wyg24 with SMTP id 24so1873026wyg.19
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 22:30:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RCU api had been completed and rcu_access_pointer() or
rcu_dereference_protected() are better than generic
rcu_dereference_raw()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c              |   10 +++++-----
 net/core/fib_rules.c        |    2 +-
 net/core/net-sysfs.c        |    4 ++--
 net/ipv4/ipmr.c             |    4 ++--
 net/ipv4/route.c            |    6 +++---
 net/ipv4/udp.c              |    7 +++----
 net/ipv6/raw.c              |    4 ++--
 net/ipv6/udp.c              |    2 +-
 net/mac80211/mesh_pathtbl.c |    4 ++--
 net/netlink/af_netlink.c    |    2 +-
 10 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9428766..d22ffd7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2673,13 +2673,13 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	map = rcu_dereference(rxqueue->rps_map);
 	if (map) {
 		if (map->len == 1 &&
-		    !rcu_dereference_raw(rxqueue->rps_flow_table)) {
+		    !rcu_access_pointer(rxqueue->rps_flow_table)) {
 			tcpu = map->cpus[0];
 			if (cpu_online(tcpu))
 				cpu = tcpu;
 			goto done;
 		}
-	} else if (!rcu_dereference_raw(rxqueue->rps_flow_table)) {
+	} else if (!rcu_access_pointer(rxqueue->rps_flow_table)) {
 		goto done;
 	}
 
@@ -5727,8 +5727,8 @@ void netdev_run_todo(void)
 
 		/* paranoia */
 		BUG_ON(netdev_refcnt_read(dev));
-		WARN_ON(rcu_dereference_raw(dev->ip_ptr));
-		WARN_ON(rcu_dereference_raw(dev->ip6_ptr));
+		WARN_ON(rcu_access_pointer(dev->ip_ptr));
+		WARN_ON(rcu_access_pointer(dev->ip6_ptr));
 		WARN_ON(dev->dn_ptr);
 
 		if (dev->destructor)
@@ -5932,7 +5932,7 @@ void free_netdev(struct net_device *dev)
 	kfree(dev->_rx);
 #endif
 
-	kfree(rcu_dereference_raw(dev->ingress_queue));
+	kfree(rcu_dereference_protected(dev->ingress_queue, 1));
 
 	/* Flush device addresses */
 	dev_addr_flush(dev);
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 0657b57..67c5c28 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -545,7 +545,7 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	frh->flags = rule->flags;
 
 	if (rule->action == FR_ACT_GOTO &&
-	    rcu_dereference_raw(rule->ctarget) == NULL)
+	    rcu_access_pointer(rule->ctarget) == NULL)
 		frh->flags |= FIB_RULE_UNRESOLVED;
 
 	if (rule->iifname[0]) {
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b1ab887..56e42ab 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -712,13 +712,13 @@ static void rx_queue_release(struct kobject *kobj)
 	struct rps_dev_flow_table *flow_table;
 
 
-	map = rcu_dereference_raw(queue->rps_map);
+	map = rcu_dereference_protected(queue->rps_map, 1);
 	if (map) {
 		RCU_INIT_POINTER(queue->rps_map, NULL);
 		kfree_rcu(map, rcu);
 	}
 
-	flow_table = rcu_dereference_raw(queue->rps_flow_table);
+	flow_table = rcu_dereference_protected(queue->rps_flow_table, 1);
 	if (flow_table) {
 		RCU_INIT_POINTER(queue->rps_flow_table, NULL);
 		call_rcu(&flow_table->rcu, rps_dev_flow_table_release);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index f550285..6164e98 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1203,7 +1203,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		return -ENOENT;
 
 	if (optname != MRT_INIT) {
-		if (sk != rcu_dereference_raw(mrt->mroute_sk) &&
+		if (sk != rcu_access_pointer(mrt->mroute_sk) &&
 		    !capable(CAP_NET_ADMIN))
 			return -EACCES;
 	}
@@ -1230,7 +1230,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		rtnl_unlock();
 		return ret;
 	case MRT_DONE:
-		if (sk != rcu_dereference_raw(mrt->mroute_sk))
+		if (sk != rcu_access_pointer(mrt->mroute_sk))
 			return -EACCES;
 		return ip_ra_control(sk, 0, NULL);
 	case MRT_ADD_VIF:
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index cb7efe0..d6e3213 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -324,7 +324,7 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
 	struct rtable *r = NULL;
 
 	for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
-		if (!rcu_dereference_raw(rt_hash_table[st->bucket].chain))
+		if (!rcu_access_pointer(rt_hash_table[st->bucket].chain))
 			continue;
 		rcu_read_lock_bh();
 		r = rcu_dereference_bh(rt_hash_table[st->bucket].chain);
@@ -350,7 +350,7 @@ static struct rtable *__rt_cache_get_next(struct seq_file *seq,
 		do {
 			if (--st->bucket < 0)
 				return NULL;
-		} while (!rcu_dereference_raw(rt_hash_table[st->bucket].chain));
+		} while (!rcu_access_pointer(rt_hash_table[st->bucket].chain));
 		rcu_read_lock_bh();
 		r = rcu_dereference_bh(rt_hash_table[st->bucket].chain);
 	}
@@ -762,7 +762,7 @@ static void rt_do_flush(struct net *net, int process_context)
 
 		if (process_context && need_resched())
 			cond_resched();
-		rth = rcu_dereference_raw(rt_hash_table[i].chain);
+		rth = rcu_access_pointer(rt_hash_table[i].chain);
 		if (!rth)
 			continue;
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1b5a193..c1d5fac 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1461,10 +1461,9 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
-	if (rcu_dereference_raw(sk->sk_filter)) {
-		if (udp_lib_checksum_complete(skb))
-			goto drop;
-	}
+	if (rcu_access_pointer(sk->sk_filter) &&
+	    udp_lib_checksum_complete(skb))
+		goto drop;
 
 
 	if (sk_rcvqueues_full(sk, skb))
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 4f45dc9..f34902f 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -372,9 +372,9 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 	read_unlock(&raw_v6_hashinfo.lock);
 }
 
-static inline int rawv6_rcv_skb(struct sock * sk, struct sk_buff * skb)
+static inline int rawv6_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
-	if ((raw6_sk(sk)->checksum || rcu_dereference_raw(sk->sk_filter)) &&
+	if ((raw6_sk(sk)->checksum || rcu_access_pointer(sk->sk_filter)) &&
 	    skb_checksum_complete(skb)) {
 		atomic_inc(&sk->sk_drops);
 		kfree_skb(skb);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 29213b5..97e47f0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -533,7 +533,7 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 		}
 	}
 
-	if (rcu_dereference_raw(sk->sk_filter)) {
+	if (rcu_access_pointer(sk->sk_filter)) {
 		if (udp_lib_checksum_complete(skb))
 			goto drop;
 	}
diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 068ee65..dc7ae8d 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -843,6 +843,6 @@ void mesh_path_expire(struct ieee80211_sub_if_data *sdata)
 void mesh_pathtbl_unregister(void)
 {
 	/* no need for locking during exit path */
-	mesh_table_free(rcu_dereference_raw(mesh_paths), true);
-	mesh_table_free(rcu_dereference_raw(mpp_paths), true);
+	mesh_table_free(rcu_dereference_protected(mesh_paths, 1), true);
+	mesh_table_free(rcu_dereference_protected(mpp_paths, 1), true);
 }
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 0a4db02..4330db9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1578,7 +1578,7 @@ int __netlink_change_ngroups(struct sock *sk, unsigned int groups)
 		new = kzalloc(sizeof(*new) + NLGRPSZ(groups), GFP_ATOMIC);
 		if (!new)
 			return -ENOMEM;
-		old = rcu_dereference_raw(tbl->listeners);
+		old = rcu_dereference_protected(tbl->listeners, 1);
 		memcpy(new->masks, old->masks, NLGRPSZ(tbl->groups));
 		rcu_assign_pointer(tbl->listeners, new);
 


