From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: many sockets, slow sendto
Date: Tue, 01 May 2007 04:43:17 +0900 (JST)
Message-ID: <20070501.044317.47815539.yoshfuji@linux-ipv6.org>
References: <20070430.002643.68156452.davem@davemloft.net>
	<20070430.195604.26499662.yoshfuji@linux-ipv6.org>
	<20070430144715.b0c03c83.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zacco@fw.hu, baruch@ev-en.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dada1@cosmosbay.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33407 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946740AbXD3TnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 15:43:15 -0400
In-Reply-To: <20070430144715.b0c03c83.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070430144715.b0c03c83.dada1@cosmosbay.com> (at Mon, 30 Apr 2007 14:47:15 +0200), Eric Dumazet <dada1@cosmosbay.com> says:

> Also, I am not sure we need to use all 128 bits of IPV6 address, maybe the 64 low order bits are enough ?

Well, maybe, but in IPv6, auto-configured addresses on an interface have
the same 64-bit LSBs.  So, I'd keep as-is so far.

Here's the take 2, mainly for fixing UDP-Lite side.

Regards,

----
[IPV6]: Convert UDP(-Lite} to new 2-pass algos.

Some inputs from Eric Dumazet <dada1@cosmosbay.com>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--- 
diff --git a/include/net/udp.h b/include/net/udp.h
index 98755eb..2c06017 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -120,8 +120,12 @@ static inline void udp_lib_close(struct sock *sk, long timeout)
 
 
 /* net/ipv4/udp.c */
+extern unsigned int udp_hash_port_and_rcvaddr(__u16 port,
+					      const struct sock *sk);
 extern int	udp_get_port(struct sock *sk, unsigned short snum,
-			     int (*saddr_cmp)(const struct sock *, const struct sock *));
+			     int (*saddr_cmp)(const struct sock *, const struct sock *),
+			     unsigned int (*hash_port_rcvaddr)(__u16 port,
+				     			       const struct sock *sk));
 extern void	udp_err(struct sk_buff *, u32);
 
 extern int	udp_sendmsg(struct kiocb *iocb, struct sock *sk,
diff --git a/include/net/udplite.h b/include/net/udplite.h
index 635b0ea..6da0d41 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -120,5 +120,6 @@ static inline __wsum udplite_csum_outgoing(struct sock *sk, struct sk_buff *skb)
 
 extern void	udplite4_register(void);
 extern int 	udplite_get_port(struct sock *sk, unsigned short snum,
-			int (*scmp)(const struct sock *, const struct sock *));
+			int (*scmp)(const struct sock *, const struct sock *),
+			unsigned int (*uhash)(__u16, const struct sock *));
 #endif	/* _UDPLITE_H */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1449707..9d4293d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -125,6 +125,12 @@ static inline unsigned int hash_port_and_addr(__u16 port, __be32 addr)
 	return port ^ addr;
 }
 
+unsigned int udp4_hash_port_and_rcvaddr(__u16 port,
+					const struct sock *sk)
+{
+	return hash_port_and_addr(port, inet_sk(sk)->rcv_saddr);
+}
+
 static inline int __udp_lib_port_inuse(unsigned int hash, int port,
 	__be32 daddr, struct hlist_head udptable[])
 {
@@ -156,7 +162,9 @@ static inline int __udp_lib_port_inuse(unsigned int hash, int port,
 int __udp_lib_get_port(struct sock *sk, unsigned short snum,
 		       struct hlist_head udptable[], int *port_rover,
 		       int (*saddr_comp)(const struct sock *sk1,
-					 const struct sock *sk2 )    )
+					 const struct sock *sk2),
+		       unsigned int (*hash_port_rcvaddr)(__u16 port,
+							 const struct sock *sk))
 {
 	struct hlist_node *node;
 	struct hlist_head *head;
@@ -176,8 +184,7 @@ int __udp_lib_get_port(struct sock *sk, unsigned short snum,
 		for (i = 0; i < UDP_HTABLE_SIZE; i++, result++) {
 			int size;
 
-			hash = hash_port_and_addr(result,
-					inet_sk(sk)->rcv_saddr);
+			hash = hash_port_rcvaddr(result, sk);
 			head = &udptable[hash & (UDP_HTABLE_SIZE - 1)];
 			if (hlist_empty(head)) {
 				if (result > sysctl_local_port_range[1])
@@ -203,8 +210,7 @@ int __udp_lib_get_port(struct sock *sk, unsigned short snum,
 				result = sysctl_local_port_range[0]
 					+ ((result - sysctl_local_port_range[0]) &
 					   (UDP_HTABLE_SIZE - 1));
-			hash = hash_port_and_addr(result,
-					inet_sk(sk)->rcv_saddr);
+			hash = hash_port_rcvaddr(result, sk);
 			if (! __udp_lib_port_inuse(hash, result,
 				inet_sk(sk)->rcv_saddr, udptable))
 				break;
@@ -214,7 +220,7 @@ int __udp_lib_get_port(struct sock *sk, unsigned short snum,
 gotit:
 		*port_rover = snum = result;
 	} else {
-		hash = hash_port_and_addr(snum, inet_sk(sk)->rcv_saddr);
+		hash = hash_port_rcvaddr(snum, sk);
 		head = &udptable[hash & (UDP_HTABLE_SIZE - 1)];
 
 		sk_for_each(sk2, node, head)
@@ -241,9 +247,11 @@ fail:
 }
 
 int udp_get_port(struct sock *sk, unsigned short snum,
-			int (*scmp)(const struct sock *, const struct sock *))
+			int (*scmp)(const struct sock *, const struct sock *),
+			unsigned int (*uhash)(u16 port, const struct sock *))
 {
-	return  __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover, scmp);
+	return  __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover,
+				   scmp, uhash);
 }
 
 int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
@@ -257,7 +265,8 @@ int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 
 static inline int udp_v4_get_port(struct sock *sk, unsigned short snum)
 {
-	return udp_get_port(sk, snum, ipv4_rcv_saddr_equal);
+	return udp_get_port(sk, snum, ipv4_rcv_saddr_equal,
+			    udp4_hash_port_and_rcvaddr);
 }
 
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
@@ -328,8 +337,8 @@ found:
 }
 
 static inline struct sock *udp_v4_mcast_next(
-			struct sock *sk,
-			unsigned int hnum, __be16 loc_port, __be32 loc_addr,
+			struct sock *sk, unsigned int hnum,
+			__be16 loc_port, __be32 loc_addr,
 			__be16 rmt_port, __be32 rmt_addr,
 			int dif)
 {
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index 820a477..d7216c8 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -10,7 +10,8 @@ extern void 	__udp4_lib_err(struct sk_buff *, u32, struct hlist_head []);
 
 extern int	__udp_lib_get_port(struct sock *sk, unsigned short snum,
 				   struct hlist_head udptable[], int *port_rover,
-				   int (*)(const struct sock*,const struct sock*));
+				   int (*)(const struct sock*,const struct sock*),
+				   unsigned int (*)(__u16, const struct sock*));
 extern int	ipv4_rcv_saddr_equal(const struct sock *, const struct sock *);
 
 
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index f34fd68..4c4e0fd 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -18,15 +18,22 @@ DEFINE_SNMP_STAT(struct udp_mib, udplite_statistics)	__read_mostly;
 struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
 static int		udplite_port_rover;
 
+extern unsigned int udp4_hash_port_and_rcvaddr(__u16 port,
+					       const struct sock *sk);
+
 int udplite_get_port(struct sock *sk, unsigned short p,
-		     int (*c)(const struct sock *, const struct sock *))
+		     int (*c)(const struct sock *, const struct sock *),
+		     unsigned int (*h)(__u16, const struct sock *))
 {
-	return  __udp_lib_get_port(sk, p, udplite_hash, &udplite_port_rover, c);
+	return  __udp_lib_get_port(sk, p, udplite_hash, &udplite_port_rover,
+				   c, h);
 }
 
 static int udplite_v4_get_port(struct sock *sk, unsigned short snum)
 {
-	return udplite_get_port(sk, snum, ipv4_rcv_saddr_equal);
+	return udplite_get_port(sk, snum,
+				ipv4_rcv_saddr_equal,
+				udp4_hash_port_and_rcvaddr);
 }
 
 static int udplite_rcv(struct sk_buff *skb)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index b083c09..1d05a69 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -52,56 +52,95 @@
 
 DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6) __read_mostly;
 
+static inline unsigned int udp6_hash_port(__u16 port)
+{
+	return port;
+}
+
+static inline unsigned int udp6_hash_port_and_addr(__u16 port,
+						   const struct in6_addr *addr)
+{
+	u32 hash = 0;
+	hash = ((__force u32) addr->s6_addr32[0]) ^
+	       ((__force u32) addr->s6_addr32[1]) ^
+	       ((__force u32) addr->s6_addr32[2]) ^
+	       ((__force u32) addr->s6_addr32[3]);
+	hash ^= hash >> 16;
+	hash ^= hash >> 8;
+	return udp6_hash_port(port) ^ hash;
+}
+
+unsigned int udp6_hash_port_and_rcvaddr(__u16 port,
+					const struct sock *sk)
+{
+	return udp6_hash_port_and_addr(port, &inet6_sk(sk)->rcv_saddr);
+}
+
 static inline int udp_v6_get_port(struct sock *sk, unsigned short snum)
 {
-	return udp_get_port(sk, snum, ipv6_rcv_saddr_equal);
+	return udp_get_port(sk, snum,
+			    ipv6_rcv_saddr_equal,
+			    udp6_hash_port_and_rcvaddr);
 }
 
 static struct sock *__udp6_lib_lookup(struct in6_addr *saddr, __be16 sport,
 				      struct in6_addr *daddr, __be16 dport,
 				      int dif, struct hlist_head udptable[])
 {
-	struct sock *sk, *result = NULL;
+	struct sock *sk = NULL, *result = NULL;
 	struct hlist_node *node;
-	unsigned short hnum = ntohs(dport);
-	int badness = -1;
+	unsigned hash, hashwild;
+	int score, best = -1;
+
+	hash = udp6_hash_port_and_addr(ntohs(dport), saddr);
+	hashwild = udp6_hash_port(ntohs(dport));
 
 	read_lock(&udp_hash_lock);
-	sk_for_each(sk, node, &udptable[hnum & (UDP_HTABLE_SIZE - 1)]) {
+lookup:
+	sk_for_each(sk, node, &udptable[hash & (UDP_HTABLE_SIZE - 1)]) {
 		struct inet_sock *inet = inet_sk(sk);
+		struct ipv6_pinfo *np = inet6_sk(sk);
 
-		if (sk->sk_hash == hnum && sk->sk_family == PF_INET6) {
-			struct ipv6_pinfo *np = inet6_sk(sk);
-			int score = 0;
-			if (inet->dport) {
-				if (inet->dport != sport)
-					continue;
-				score++;
-			}
-			if (!ipv6_addr_any(&np->rcv_saddr)) {
-				if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
-					continue;
-				score++;
-			}
-			if (!ipv6_addr_any(&np->daddr)) {
-				if (!ipv6_addr_equal(&np->daddr, saddr))
-					continue;
-				score++;
-			}
-			if (sk->sk_bound_dev_if) {
-				if (sk->sk_bound_dev_if != dif)
-					continue;
-				score++;
-			}
-			if (score == 4) {
-				result = sk;
-				break;
-			} else if (score > badness) {
-				result = sk;
-				badness = score;
-			}
+		if (sk->sk_hash != hash || sk->sk_family != PF_INET6 ||
+		    inet->num != dport)
+			continue;
+
+		score = 0;
+
+		if (inet->dport) {
+			if (inet->dport != sport)
+				continue;
+			score++;
 		}
+		if (!ipv6_addr_any(&np->rcv_saddr)) {
+			if (!ipv6_addr_equal(&np->rcv_saddr, daddr))
+				continue;
+			score++;
+		}
+		if (!ipv6_addr_any(&np->daddr)) {
+			if (!ipv6_addr_equal(&np->daddr, saddr))
+				continue;
+			score++;
+		}
+		if (sk->sk_bound_dev_if) {
+			if (sk->sk_bound_dev_if != dif)
+				continue;
+			score++;
+		}
+		if (score == 4) {
+			result = sk;
+			goto found;
+		} else if (score > best) {
+			result = sk;
+			best = score;
+		}
+	}
+
+	if (hash != hashwild) {
+		hash = hashwild;
+		goto lookup;
 	}
+found:
 	if (result)
 		sock_hold(result);
 	read_unlock(&udp_hash_lock);
@@ -302,38 +341,41 @@ drop:
 }
 
 static struct sock *udp_v6_mcast_next(struct sock *sk,
+				      unsigned int hnum,
 				      __be16 loc_port, struct in6_addr *loc_addr,
 				      __be16 rmt_port, struct in6_addr *rmt_addr,
 				      int dif)
 {
 	struct hlist_node *node;
 	struct sock *s = sk;
-	unsigned short num = ntohs(loc_port);
 
 	sk_for_each_from(s, node) {
 		struct inet_sock *inet = inet_sk(s);
+		struct ipv6_pinfo *np = inet6_sk(s);
 
-		if (s->sk_hash == num && s->sk_family == PF_INET6) {
-			struct ipv6_pinfo *np = inet6_sk(s);
-			if (inet->dport) {
-				if (inet->dport != rmt_port)
-					continue;
-			}
-			if (!ipv6_addr_any(&np->daddr) &&
-			    !ipv6_addr_equal(&np->daddr, rmt_addr))
-				continue;
+		if (s->sk_hash != hnum || s->sk_family != PF_INET6 ||
+		    inet->num != loc_port)
+			continue;
 
-			if (s->sk_bound_dev_if && s->sk_bound_dev_if != dif)
+		if (inet->dport) {
+			if (inet->dport != rmt_port)
 				continue;
+		}
+		if (!ipv6_addr_any(&np->daddr) &&
+		    !ipv6_addr_equal(&np->daddr, rmt_addr))
+			continue;
 
-			if (!ipv6_addr_any(&np->rcv_saddr)) {
-				if (!ipv6_addr_equal(&np->rcv_saddr, loc_addr))
-					continue;
-			}
-			if (!inet6_mc_check(s, loc_addr, rmt_addr))
+		if (s->sk_bound_dev_if && s->sk_bound_dev_if != dif)
+			continue;
+
+		if (!ipv6_addr_any(&np->rcv_saddr)) {
+			if (!ipv6_addr_equal(&np->rcv_saddr, loc_addr))
 				continue;
-			return s;
 		}
+
+		if (!inet6_mc_check(s, loc_addr, rmt_addr))
+			continue;
+		return s;
 	}
 	return NULL;
 }
@@ -348,20 +390,42 @@ static int __udp6_lib_mcast_deliver(struct sk_buff *skb, struct in6_addr *saddr,
 	struct sock *sk, *sk2;
 	const struct udphdr *uh = udp_hdr(skb);
 	int dif;
+	int hport = ntohs(uh->dest);
+	unsigned int hash = udp6_hash_port_and_addr(ntohs(uh->dest), daddr);
+	unsigned int hashwild = udp6_hash_port(ntohs(uh->dest));
 
-	read_lock(&udp_hash_lock);
-	sk = sk_head(&udptable[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)]);
 	dif = inet6_iif(skb);
-	sk = udp_v6_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
+
+	read_lock(&udp_hash_lock);
+redo:
+	sk = sk_head(&udptable[hash & (UDP_HTABLE_SIZE - 1)]);
+	sk = udp_v6_mcast_next(sk, hash, uh->dest, daddr, uh->source, saddr, dif);
 	if (!sk) {
+		if (hash != hashwild) {
+			hash = hashwild;
+			goto redo;
+		}
 		kfree_skb(skb);
 		goto out;
 	}
 
 	sk2 = sk;
-	while ((sk2 = udp_v6_mcast_next(sk_next(sk2), uh->dest, daddr,
-					uh->source, saddr, dif))) {
-		struct sk_buff *buff = skb_clone(skb, GFP_ATOMIC);
+	while(1) {
+		struct sk_buff *buff;
+
+		sk2 = udp_v6_mcast_next(sk_next(sk2), hash, hport, daddr,
+					uh->source, saddr, dif);
+		if (!sk2) {
+			if (hash == hashwild)
+				break;
+			hash = hashwild;
+			sk2 = sk_head(&udptable[hash & (UDP_HTABLE_SIZE - 1)]);
+			sk2 = udp_v6_mcast_next(sk2, hash, uh->dest, daddr, uh->source, saddr, dif);
+			if (!sk2)
+				break;
+		}
+
+		buff = skb_clone(skb, GFP_ATOMIC);
 		if (buff)
 			udpv6_queue_rcv_skb(sk2, buff);
 	}
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index f54016a..797d76d 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -17,6 +17,9 @@
 
 DEFINE_SNMP_STAT(struct udp_mib, udplite_stats_in6) __read_mostly;
 
+extern unsigned int udp6_hash_port_and_rcvaddr(__u16 port,
+					       const struct sock *sk);
+
 static int udplitev6_rcv(struct sk_buff **pskb)
 {
 	return __udp6_lib_rcv(pskb, udplite_hash, IPPROTO_UDPLITE);
@@ -37,7 +40,9 @@ static struct inet6_protocol udplitev6_protocol = {
 
 static int udplite_v6_get_port(struct sock *sk, unsigned short snum)
 {
-	return udplite_get_port(sk, snum, ipv6_rcv_saddr_equal);
+	return udplite_get_port(sk, snum,
+				ipv6_rcv_saddr_equal,
+				udp6_hash_port_and_rcvaddr);
 }
 
 struct proto udplitev6_prot = {


--yoshfuji
