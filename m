From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: many sockets, slow sendto
Date: Fri, 30 Mar 2007 15:10:21 +0200
Message-ID: <20070330151021.d067d837.dada1@cosmosbay.com>
References: <E1HObHK-0000WB-00@osiris.swi.hu>
	<20070306182039.GJ25760@galon.ev-en.org>
	<45FF185B.4070007@fw.hu>
	<20070319.161611.70218081.davem@davemloft.net>
	<4600592E.80605@fw.hu>
	<460064C6.5030302@cosmosbay.com>
	<4601ADD8.8040500@cosmosbay.com>
	<460C126F.7050303@fw.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, baruch@ev-en.org,
	netdev@vger.kernel.org
To: Zacco <zacco@fw.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([80.12.242.27]:33535 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbXC3NOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 09:14:20 -0400
In-Reply-To: <460C126F.7050303@fw.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Mar 2007 21:24:31 +0200
Zacco <zacco@fw.hu> wrote:

> Hi,
> 
> Thanks for the patch. I almost dare not confess that I don't know which 
> version to apply to. I tried 3 different ones (2.6.19-r5-gentoo, 
> 2.6.20.1 and 2.6.21-rc4), but in the best case at least two hunks 
> failed. Nevertheless, I applied the patches manually. In each case, UDP 
> stopped working. I guess, you checked the patch and worked. I don't 
> think I made a mistake in the manual copy, and it seems unlikely that 
> your patch interfered with other parallel changes in the kernel - but, 
> I'm just guessing ...
> I think, I'd better send you the spec and code, as you suggested that 
> first we have a common understanding of the issue. I must have failed in 
> passing the point. I'm removing irrelevant stuff, and I send it to you 
> as soon as I can (sorry for my long delays).
> 
> thx a lot,
> Zacco

Hum, please find a (working) patch against linux-2.6.21-rc5

(first patch was against net-2.6.22 git tree and had one bug)

Hope this helps

--- linux-2.6.21-rc5/net/ipv4/udp.c
+++ linux-2.6.21-rc5-ed/net/ipv4/udp.c
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
@@ -180,7 +202,10 @@ int __udp_lib_get_port(struct sock *sk, 
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
@@ -188,11 +213,13 @@ int __udp_lib_get_port(struct sock *sk, 
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
@@ -200,9 +227,9 @@ gotit:
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
@@ -241,63 +268,76 @@ static struct sock *__udp4_lib_lookup(__
 {
 	struct sock *sk, *result = NULL;
 	struct hlist_node *node;
-	unsigned short hnum = ntohs(dport);
-	int badness = -1;
+	unsigned int hash, hashwild;
+	int score, best = -1, hport = ntohs(dport);
+
+ 	hash = hash_port_and_addr(hport, daddr);
+ 	hashwild = hash_port_and_addr(hport, 0);
 
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
-			if(score == 9) {
-				result = sk;
-				break;
-			} else if(score > badness) {
-				result = sk;
-				badness = score;
-			}
+		if (sk->sk_hash != hash || ipv6_only_sock(sk) ||
+			inet->num != hport)
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
 		}
+		if(score == 9) {
+			result = sk;
+			goto found;
+		} else if(score > best) {
+			result = sk;
+			best = score;
+		}
+	}
+	if (hash != hashwild) {
+		hash = hashwild;
+		goto lookup;
 	}
+found:
 	if (result)
 		sock_hold(result);
 	read_unlock(&udp_hash_lock);
 	return result;
 }
 
-static inline struct sock *udp_v4_mcast_next(struct sock *sk,
-					     __be16 loc_port, __be32 loc_addr,
+static inline struct sock *udp_v4_mcast_next(struct sock *sk, unsigned int hnum,
+					     int hport, __be32 loc_addr,
 					     __be16 rmt_port, __be32 rmt_addr,
 					     int dif)
 {
 	struct hlist_node *node;
 	struct sock *s = sk;
-	unsigned short hnum = ntohs(loc_port);
 
 	sk_for_each_from(s, node) {
 		struct inet_sock *inet = inet_sk(s);
 
 		if (s->sk_hash != hnum					||
+		    inet->num != hport					||
 		    (inet->daddr && inet->daddr != rmt_addr)		||
 		    (inet->dport != rmt_port && inet->dport)		||
 		    (inet->rcv_saddr && inet->rcv_saddr != loc_addr)	||
@@ -1128,25 +1168,39 @@ static int __udp4_lib_mcast_deliver(stru
 				    __be32 saddr, __be32 daddr,
 				    struct hlist_head udptable[])
 {
-	struct sock *sk;
+	struct sock *sk, *skw, *sknext;
 	int dif;
+	int hport = ntohs(uh->dest);
+	unsigned int hash = hash_port_and_addr(hport, daddr);
+	unsigned int hashwild = hash_port_and_addr(hport, 0);
 
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
+	sk = udp_v4_mcast_next(sk, hash, hport, daddr, uh->source, saddr, dif);
+	if (!sk) {
+		hash = hashwild;
+		sk = udp_v4_mcast_next(skw, hash, hport, daddr, uh->source,
+			saddr, dif);
+	}
+	if (sk) {
 		do {
 			struct sk_buff *skb1 = skb;
-
-			sknext = udp_v4_mcast_next(sk_next(sk), uh->dest, daddr,
-						   uh->source, saddr, dif);
-			if(sknext)
+			sknext = udp_v4_mcast_next(sk_next(sk), hash, hport,
+						daddr, uh->source, saddr, dif);
+			if (!sknext && hash != hashwild) {
+				hash = hashwild;
+				sknext = udp_v4_mcast_next(skw, hash, hport,
+					daddr, uh->source, saddr, dif);
+			}
+			if (sknext)
 				skb1 = skb_clone(skb, GFP_ATOMIC);
 
-			if(skb1) {
+			if (skb1) {
 				int ret = udp_queue_rcv_skb(sk, skb1);
 				if (ret > 0)
 					/* we should probably re-process instead
@@ -1228,7 +1282,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, 
 		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
 
 	sk = __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
-			       skb->dev->ifindex, udptable        );
+			       skb->dev->ifindex, udptable);
 
 	if (sk != NULL) {
 		int ret = udp_queue_rcv_skb(sk, skb);
-- 
Eric Dumazet <dada1@cosmosbay.com>

