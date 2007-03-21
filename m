From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: many sockets, slow sendto
Date: Wed, 21 Mar 2007 23:12:40 +0100
Message-ID: <4601ADD8.8040500@cosmosbay.com>
References: <E1HObHK-0000WB-00@osiris.swi.hu>	<20070306182039.GJ25760@galon.ev-en.org>	<45FF185B.4070007@fw.hu> <20070319.161611.70218081.davem@davemloft.net> <4600592E.80605@fw.hu> <460064C6.5030302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010101000501080902050108"
Cc: David Miller <davem@davemloft.net>, baruch@ev-en.org,
	netdev@vger.kernel.org
To: Zacco <zacco@fw.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.cosmosbay.com ([86.65.150.131]:44630 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S933868AbXCUWNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 18:13:18 -0400
In-Reply-To: <460064C6.5030302@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010101000501080902050108
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit

Eric Dumazet a écrit :
> Currently, udp_hash[UDP_HTABLE_SIZE] is using a hash function based on 
> dport number only.
> 
> In your case, as you use a single port value, all sockets are in a 
> single slot of this hash table :
> To find the good socket, __udp4_lib_lookup() has to search in a list 
> with thousands of elements. Not that good, isnt it ? :(

In case you want to try, here is a patch that could help you :)

[PATCH] INET : IPV4 UDP lookups converted to a 2 pass algo

Some people want to have many UDP sockets, binded to a single port but many 
different addresses. We currently hash all those sockets into a single chain. 
Processing of incoming packets is very expensive, because the whole chain must 
be examined to find the best match.

I chose in this patch to hash UDP sockets with a hash function that take into 
account both their port number and address : This has a drawback because we 
need two lookups : one with a given address, one with a wildcard (null) address.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------010101000501080902050108
Content-Type: text/plain;
 name="udp_2pass_lookups.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp_2pass_lookups.patch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 71b0b60..27437e7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -114,14 +114,33 @@ DEFINE_RWLOCK(udp_hash_lock);
 
 static int udp_port_rover;
 
-static inline int __udp_lib_lport_inuse(__u16 num, struct hlist_head udptable[])
+/*
+ * Note about this hash function :
+ * Typical use is probably daddr = 0, only dport is going to vary hash
+ */
+static inline unsigned int hash_port_and_addr(__u16 port, __be32 addr)
+{
+	addr ^= addr >> 16;
+	addr ^= addr >> 8;
+	return port ^ addr;
+}
+
+static inline int __udp_lib_port_inuse(unsigned int hash, int port,
+	__be32 daddr, struct hlist_head udptable[])
 {
 	struct sock *sk;
 	struct hlist_node *node;
+	struct inet_sock *inet;
 
-	sk_for_each(sk, node, &udptable[num & (UDP_HTABLE_SIZE - 1)])
-		if (sk->sk_hash == num)
+	sk_for_each(sk, node, &udptable[hash & (UDP_HTABLE_SIZE - 1)]) {
+		if (sk->sk_hash != hash)
+			continue;
+		inet = inet_sk(sk);
+		if (inet->num != port)
+			continue;
+		if (inet->rcv_saddr == daddr)
 			return 1;
+	}
 	return 0;
 }
 
@@ -142,6 +161,7 @@ int __udp_lib_get_port(struct sock *sk, 
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct sock *sk2;
+	unsigned int hash;
 	int    error = 1;
 
 	write_lock_bh(&udp_hash_lock);
@@ -156,7 +176,9 @@ int __udp_lib_get_port(struct sock *sk, 
 		for (i = 0; i < UDP_HTABLE_SIZE; i++, result++) {
 			int size;
 
-			head = &udptable[result & (UDP_HTABLE_SIZE - 1)];
+			hash = hash_port_and_addr(result,
+					inet_sk(sk)->rcv_saddr);
+			head = &udptable[hash & (UDP_HTABLE_SIZE - 1)];
 			if (hlist_empty(head)) {
 				if (result > sysctl_local_port_range[1])
 					result = sysctl_local_port_range[0] +
@@ -181,7 +203,10 @@ int __udp_lib_get_port(struct sock *sk, 
 				result = sysctl_local_port_range[0]
 					+ ((result - sysctl_local_port_range[0]) &
 					   (UDP_HTABLE_SIZE - 1));
-			if (! __udp_lib_lport_inuse(result, udptable))
+			hash = hash_port_and_addr(result,
+					inet_sk(sk)->rcv_saddr);
+			if (! __udp_lib_port_inuse(hash, result,
+				inet_sk(sk)->rcv_saddr, udptable))
 				break;
 		}
 		if (i >= (1 << 16) / UDP_HTABLE_SIZE)
@@ -189,11 +214,13 @@ int __udp_lib_get_port(struct sock *sk, 
 gotit:
 		*port_rover = snum = result;
 	} else {
-		head = &udptable[snum & (UDP_HTABLE_SIZE - 1)];
+		hash = hash_port_and_addr(snum, inet_sk(sk)->rcv_saddr);
+		head = &udptable[hash & (UDP_HTABLE_SIZE - 1)];
 
 		sk_for_each(sk2, node, head)
-			if (sk2->sk_hash == snum                             &&
+			if (sk2->sk_hash == hash                             &&
 			    sk2 != sk                                        &&
+			    inet_sk(sk2)->num == snum	                     &&
 			    (!sk2->sk_reuse        || !sk->sk_reuse)         &&
 			    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
 			     || sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
@@ -201,9 +228,9 @@ gotit:
 				goto fail;
 	}
 	inet_sk(sk)->num = snum;
-	sk->sk_hash = snum;
+	sk->sk_hash = hash;
 	if (sk_unhashed(sk)) {
-		head = &udptable[snum & (UDP_HTABLE_SIZE - 1)];
+		head = &udptable[hash & (UDP_HTABLE_SIZE - 1)];
 		sk_add_node(sk, head);
 		sock_prot_inc_use(sk->sk_prot);
 	}
@@ -242,63 +269,78 @@ static struct sock *__udp4_lib_lookup(__
 {
 	struct sock *sk, *result = NULL;
 	struct hlist_node *node;
-	unsigned short hnum = ntohs(dport);
-	int badness = -1;
+	unsigned int hash, hashwild;
+	int score, best = -1;
+
+	hash = hash_port_and_addr(ntohs(dport), daddr);
+	hashwild = hash_port_and_addr(ntohs(dport), 0);
 
 	read_lock(&udp_hash_lock);
-	sk_for_each(sk, node, &udptable[hnum & (UDP_HTABLE_SIZE - 1)]) {
+
+lookup:
+
+	sk_for_each(sk, node, &udptable[hash & (UDP_HTABLE_SIZE - 1)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		if (sk->sk_hash == hnum && !ipv6_only_sock(sk)) {
-			int score = (sk->sk_family == PF_INET ? 1 : 0);
-			if (inet->rcv_saddr) {
-				if (inet->rcv_saddr != daddr)
-					continue;
-				score+=2;
-			}
-			if (inet->daddr) {
-				if (inet->daddr != saddr)
-					continue;
-				score+=2;
-			}
-			if (inet->dport) {
-				if (inet->dport != sport)
-					continue;
-				score+=2;
-			}
-			if (sk->sk_bound_dev_if) {
-				if (sk->sk_bound_dev_if != dif)
-					continue;
-				score+=2;
-			}
-			if (score == 9) {
-				result = sk;
-				break;
-			} else if (score > badness) {
-				result = sk;
-				badness = score;
-			}
+		if (sk->sk_hash != hash || ipv6_only_sock(sk) ||
+			inet->num != dport)
+			continue;
+
+		score = (sk->sk_family == PF_INET ? 1 : 0);
+		if (inet->rcv_saddr) {
+			if (inet->rcv_saddr != daddr)
+				continue;
+			score+=2;
+		}
+		if (inet->daddr) {
+			if (inet->daddr != saddr)
+				continue;
+			score+=2;
+		}
+		if (inet->dport) {
+			if (inet->dport != sport)
+				continue;
+			score+=2;
+		}
+		if (sk->sk_bound_dev_if) {
+			if (sk->sk_bound_dev_if != dif)
+				continue;
+			score+=2;
+		}
+		if (score == 9) {
+			result = sk;
+			goto found;
+		} else if (score > best) {
+			result = sk;
+			best = score;
 		}
 	}
+
+	if (hash != hashwild) {
+		hash = hashwild;
+		goto lookup;
+	}
+found:
 	if (result)
 		sock_hold(result);
 	read_unlock(&udp_hash_lock);
 	return result;
 }
 
-static inline struct sock *udp_v4_mcast_next(struct sock *sk,
-					     __be16 loc_port, __be32 loc_addr,
-					     __be16 rmt_port, __be32 rmt_addr,
-					     int dif)
+static inline struct sock *udp_v4_mcast_next(
+			struct sock *sk,
+			unsigned int hnum, __be16 loc_port, __be32 loc_addr,
+			__be16 rmt_port, __be32 rmt_addr,
+			int dif)
 {
 	struct hlist_node *node;
 	struct sock *s = sk;
-	unsigned short hnum = ntohs(loc_port);
 
 	sk_for_each_from(s, node) {
 		struct inet_sock *inet = inet_sk(s);
 
 		if (s->sk_hash != hnum					||
+		    inet->num != loc_port				||
 		    (inet->daddr && inet->daddr != rmt_addr)		||
 		    (inet->dport != rmt_port && inet->dport)		||
 		    (inet->rcv_saddr && inet->rcv_saddr != loc_addr)	||
@@ -1128,29 +1170,44 @@ static int __udp4_lib_mcast_deliver(stru
 				    __be32 saddr, __be32 daddr,
 				    struct hlist_head udptable[])
 {
-	struct sock *sk;
+	struct sock *sk, *skw, *sknext;
 	int dif;
+	unsigned int hash = hash_port_and_addr(ntohs(uh->dest), daddr);
+	unsigned int hashwild = hash_port_and_addr(ntohs(uh->dest), 0);
 
-	read_lock(&udp_hash_lock);
-	sk = sk_head(&udptable[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)]);
 	dif = skb->dev->ifindex;
-	sk = udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
-	if (sk) {
-		struct sock *sknext = NULL;
 
+	read_lock(&udp_hash_lock);
+
+	sk = sk_head(&udptable[hash & (UDP_HTABLE_SIZE - 1)]);
+	skw = sk_head(&udptable[hashwild & (UDP_HTABLE_SIZE - 1)]);
+
+	sk = udp_v4_mcast_next(sk, hash, uh->dest, daddr, uh->source, saddr, dif);
+	if (!sk) {
+		hash = hashwild;
+		sk = udp_v4_mcast_next(skw, hash, uh->dest, daddr, uh->source,
+			saddr, dif);
+	}
+	if (sk) {
 		do {
 			struct sk_buff *skb1 = skb;
-
-			sknext = udp_v4_mcast_next(sk_next(sk), uh->dest, daddr,
-						   uh->source, saddr, dif);
+			sknext = udp_v4_mcast_next(sk_next(sk), hash, uh->dest,
+				daddr, uh->source, saddr, dif);
+			if (!sknext && hash != hashwild) {
+				hash = hashwild;
+				sknext = udp_v4_mcast_next(skw, hash, uh->dest,
+					daddr, uh->source, saddr, dif);
+			}
 			if (sknext)
 				skb1 = skb_clone(skb, GFP_ATOMIC);
 
 			if (skb1) {
 				int ret = udp_queue_rcv_skb(sk, skb1);
 				if (ret > 0)
-					/* we should probably re-process instead
-					 * of dropping packets here. */
+					/*
+					 * we should probably re-process
+					 * instead of dropping packets here.
+					 */
 					kfree_skb(skb1);
 			}
 			sk = sknext;

--------------010101000501080902050108--
