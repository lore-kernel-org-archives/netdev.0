From: David Held <drheld@google.com>
Subject: [PATCH net-next 2/2] udp: Use hash2 for long hash1 chains in __udp*_lib_mcast_deliver.
Date: Mon, 14 Jul 2014 18:30:39 -0400
Message-ID: <1405377039-10082-2-git-send-email-drheld@google.com>
References: <1405377039-10082-1-git-send-email-drheld@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, willemb@google.com,
	David Held <drheld@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:38807 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756976AbaGNWbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 18:31:01 -0400
Received: by mail-pd0-f201.google.com with SMTP id v10so1063002pde.0
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 15:31:01 -0700 (PDT)
In-Reply-To: <1405377039-10082-1-git-send-email-drheld@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many multicast sources can have the same port which can result in a very
large list when hashing by port only. Hash by address and port instead
if this is the case. This makes multicast more similar to unicast.

On a 24-core machine receiving from 500 multicast sockets on the same
port, before this patch 80% of system CPU was used up by spin locking
and only ~25% of packets were successfully delivered.

With this patch, all packets are delivered and kernel overhead is ~8%
system CPU on spinlocks.

Signed-off-by: David Held <drheld@google.com>
---
 include/net/sock.h | 14 ++++++++++++++
 net/ipv4/udp.c     | 30 ++++++++++++++++++++----------
 net/ipv6/udp.c     | 29 +++++++++++++++++++----------
 3 files changed, 53 insertions(+), 20 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index cb84b2f..6734cab 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -660,6 +660,20 @@ static inline void sk_add_bind_node(struct sock *sk,
 #define sk_for_each_bound(__sk, list) \
 	hlist_for_each_entry(__sk, list, sk_bind_node)
 
+/**
+ * sk_nulls_for_each_entry_offset - iterate over a list at a given struct offset
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @head:	the head for your list.
+ * @offset:	offset of hlist_node within the struct.
+ *
+ */
+#define sk_nulls_for_each_entry_offset(tpos, pos, head, offset)		       \
+	for (pos = (head)->first;					       \
+	     (!is_a_nulls(pos)) &&					       \
+		({ tpos = (typeof(*tpos) *)((void *)pos - offset); 1;});       \
+	     pos = pos->next)
+
 static inline struct user_namespace *sk_user_ns(struct sock *sk)
 {
 	/* Careful only use this in a context where these parameters
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8089ba2..b023a36 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1616,6 +1616,8 @@ static void flush_stack(struct sock **stack, unsigned int count,
 
 		if (skb1 && udp_queue_rcv_skb(sk, skb1) <= 0)
 			skb1 = NULL;
+
+		sock_put(sk);
 	}
 	if (unlikely(skb1))
 		kfree_skb(skb1);
@@ -1648,37 +1650,45 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	unsigned short hnum = ntohs(uh->dest);
 	struct udp_hslot *hslot = udp_hashslot(udptable, net, hnum);
 	int dif = skb->dev->ifindex;
-	unsigned int i, count = 0;
+	unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
+	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
+
+	if (use_hash2) {
+		hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum);
+		hash2 = udp4_portaddr_hash(net, daddr, hnum);
+start_lookup:
+		hslot = &udp_table.hash2[hash2 & udp_table.mask];
+		offset = offsetof(typeof(*sk), __sk_common.skc_portaddr_node);
+	}
 
 	spin_lock(&hslot->lock);
-	sk_nulls_for_each(sk, node, &hslot->head) {
+	sk_nulls_for_each_entry_offset(sk, node, &hslot->head, offset) {
 		if (__udp_is_mcast_sock(net, sk,
 					uh->dest, daddr,
 					uh->source, saddr,
 					dif, hnum)) {
 			stack[count++] = sk;
+			sock_hold(sk);
 			if (unlikely(count == ARRAY_SIZE(stack))) {
 				flush_stack(stack, count, skb, ~0);
 				count = 0;
 			}
 		}
 	}
-	/*
-	 * before releasing chain lock, we must take a reference on sockets
-	 */
-	for (i = 0; i < count; i++)
-		sock_hold(stack[i]);
 
 	spin_unlock(&hslot->lock);
 
+	/* Also lookup *:port if we are using hash2 and haven't done so yet. */
+	if (use_hash2 && hash2 != hash2_any) {
+		hash2 = hash2_any;
+		goto start_lookup;
+	}
+
 	/*
 	 * do the slow work with no lock held
 	 */
 	if (count) {
 		flush_stack(stack, count, skb, count - 1);
-
-		for (i = 0; i < count; i++)
-			sock_put(stack[i]);
 	} else {
 		kfree_skb(skb);
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index cade19b..d1c00c5 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -741,6 +741,7 @@ static void flush_stack(struct sock **stack, unsigned int count,
 
 		if (skb1 && udpv6_queue_rcv_skb(sk, skb1) <= 0)
 			skb1 = NULL;
+		sock_put(sk);
 	}
 	if (unlikely(skb1))
 		kfree_skb(skb1);
@@ -770,10 +771,19 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	unsigned short hnum = ntohs(uh->dest);
 	struct udp_hslot *hslot = udp_hashslot(udptable, net, hnum);
 	int dif = inet6_iif(skb);
-	unsigned int i, count = 0;
+	unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
+	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
+
+	if (use_hash2) {
+		hash2_any = udp6_portaddr_hash(net, &in6addr_any, hnum);
+		hash2 = udp6_portaddr_hash(net, daddr, hnum);
+start_lookup:
+		hslot = &udp_table.hash2[hash2 & udp_table.mask];
+		offset = offsetof(typeof(*sk), __sk_common.skc_portaddr_node);
+	}
 
 	spin_lock(&hslot->lock);
-	sk_nulls_for_each(sk, node, &hslot->head) {
+	sk_nulls_for_each_entry_offset(sk, node, &hslot->head, offset) {
 		if (__udp_v6_is_mcast_sock(net, sk,
 					   uh->dest, daddr,
 					   uh->source, saddr,
@@ -783,25 +793,24 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		     */
 		    (uh->check || udp_sk(sk)->no_check6_rx)) {
 			stack[count++] = sk;
+			sock_hold(sk);
 			if (unlikely(count == ARRAY_SIZE(stack))) {
 				flush_stack(stack, count, skb, ~0);
 				count = 0;
 			}
 		}
 	}
-	/*
-	 * before releasing the lock, we must take reference on sockets
-	 */
-	for (i = 0; i < count; i++)
-		sock_hold(stack[i]);
 
 	spin_unlock(&hslot->lock);
 
+	/* Also lookup *:port if we are using hash2 and haven't done so yet. */
+	if (use_hash2 && hash2 != hash2_any) {
+		hash2 = hash2_any;
+		goto start_lookup;
+	}
+
 	if (count) {
 		flush_stack(stack, count, skb, count - 1);
-
-		for (i = 0; i < count; i++)
-			sock_put(stack[i]);
 	} else {
 		kfree_skb(skb);
 	}
-- 
2.0.0.526.g5318336
