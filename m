From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix up AF-specific references in UDP
Date: Wed, 09 May 2007 17:23:30 -0700 (PDT)
Message-ID: <20070509.172330.21926847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, dada1@cosmosbay.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44396
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756522AbXEJAXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 20:23:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


As noticed we make some ipv4-specific references in the generic
UDP code, I've fixed that up completely below.

This should fix ipv6 and it should be fully functional.

There is enough infrastructure there to write up the
non-wildcard IPV6 hashing support.  Eric and Yoshifuji
had some ideas about how to hash the rcv_saddr so I
will leave those bits to them :-)

It is very easy, just add the appropriate hashing to
ipv6_hash_port_and_rcv_addr(), then add the lookup logic
to the ipv6 UDP socket demux for unicast and multicast
to match the ipv4 equivalent code.

Meanwhile I'll push this patch below to Linus so that
IPV6 isn't broken.

commit 30959ab670629ac857d04c7bc87df422fc941ec9
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed May 9 16:42:20 2007 -0700

    [UDP]: Fix AF-specific references in AF-agnostic code.
    
    __udp_lib_port_inuse() cannot make direct references to
    inet_sk(sk)->rcv_saddr as that is ipv4 specific state and
    this code is used by ipv6 too.
    
    Use an operations vector to solve this, and this also paves
    the way for ipv6 support for non-wild saddr hashing in UDP.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/udp.h b/include/net/udp.h
index 98755eb..496f89d 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -119,9 +119,16 @@ static inline void udp_lib_close(struct sock *sk, long timeout)
 }
 
 
+struct udp_get_port_ops {
+	int (*saddr_cmp)(const struct sock *sk1, const struct sock *sk2);
+	int (*saddr_any)(const struct sock *sk);
+	unsigned int (*hash_port_and_rcv_saddr)(__u16 port,
+						const struct sock *sk);
+};
+
 /* net/ipv4/udp.c */
 extern int	udp_get_port(struct sock *sk, unsigned short snum,
-			     int (*saddr_cmp)(const struct sock *, const struct sock *));
+			     const struct udp_get_port_ops *ops);
 extern void	udp_err(struct sk_buff *, u32);
 
 extern int	udp_sendmsg(struct kiocb *iocb, struct sock *sk,
diff --git a/include/net/udplite.h b/include/net/udplite.h
index 635b0ea..50b4b42 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -120,5 +120,5 @@ static inline __wsum udplite_csum_outgoing(struct sock *sk, struct sk_buff *skb)
 
 extern void	udplite4_register(void);
 extern int 	udplite_get_port(struct sock *sk, unsigned short snum,
-			int (*scmp)(const struct sock *, const struct sock *));
+				 const struct udp_get_port_ops *ops);
 #endif	/* _UDPLITE_H */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 113e0c4..f7c3b25 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -118,15 +118,15 @@ static int udp_port_rover;
  * Note about this hash function :
  * Typical use is probably daddr = 0, only dport is going to vary hash
  */
-static inline unsigned int hash_port_and_addr(__u16 port, __be32 addr)
+static inline unsigned int udp_hash_port(__u16 port)
 {
-	addr ^= addr >> 16;
-	addr ^= addr >> 8;
-	return port ^ addr;
+	return port;
 }
 
 static inline int __udp_lib_port_inuse(unsigned int hash, int port,
-	__be32 daddr, struct hlist_head udptable[])
+				       const struct sock *this_sk,
+				       struct hlist_head udptable[],
+				       const struct udp_get_port_ops *ops)
 {
 	struct sock *sk;
 	struct hlist_node *node;
@@ -138,7 +138,10 @@ static inline int __udp_lib_port_inuse(unsigned int hash, int port,
 		inet = inet_sk(sk);
 		if (inet->num != port)
 			continue;
-		if (inet->rcv_saddr == daddr)
+		if (this_sk) {
+			if (ops->saddr_cmp(sk, this_sk))
+				return 1;
+		} else if (ops->saddr_any(sk))
 			return 1;
 	}
 	return 0;
@@ -151,12 +154,11 @@ static inline int __udp_lib_port_inuse(unsigned int hash, int port,
  *  @snum:        port number to look up
  *  @udptable:    hash list table, must be of UDP_HTABLE_SIZE
  *  @port_rover:  pointer to record of last unallocated port
- *  @saddr_comp:  AF-dependent comparison of bound local IP addresses
+ *  @ops:         AF-dependent address operations
  */
 int __udp_lib_get_port(struct sock *sk, unsigned short snum,
 		       struct hlist_head udptable[], int *port_rover,
-		       int (*saddr_comp)(const struct sock *sk1,
-					 const struct sock *sk2 )    )
+		       const struct udp_get_port_ops *ops)
 {
 	struct hlist_node *node;
 	struct hlist_head *head;
@@ -176,8 +178,7 @@ int __udp_lib_get_port(struct sock *sk, unsigned short snum,
 		for (i = 0; i < UDP_HTABLE_SIZE; i++, result++) {
 			int size;
 
-			hash = hash_port_and_addr(result,
-					inet_sk(sk)->rcv_saddr);
+			hash = ops->hash_port_and_rcv_saddr(result, sk);
 			head = &udptable[hash & (UDP_HTABLE_SIZE - 1)];
 			if (hlist_empty(head)) {
 				if (result > sysctl_local_port_range[1])
@@ -203,17 +204,16 @@ int __udp_lib_get_port(struct sock *sk, unsigned short snum,
 				result = sysctl_local_port_range[0]
 					+ ((result - sysctl_local_port_range[0]) &
 					   (UDP_HTABLE_SIZE - 1));
-			hash = hash_port_and_addr(result, 0);
+			hash = udp_hash_port(result);
 			if (__udp_lib_port_inuse(hash, result,
-						 0, udptable))
+						 NULL, udptable, ops))
 				continue;
-			if (!inet_sk(sk)->rcv_saddr)
+			if (ops->saddr_any(sk))
 				break;
 
-			hash = hash_port_and_addr(result,
-					inet_sk(sk)->rcv_saddr);
+			hash = ops->hash_port_and_rcv_saddr(result, sk);
 			if (! __udp_lib_port_inuse(hash, result,
-				inet_sk(sk)->rcv_saddr, udptable))
+						   sk, udptable, ops))
 				break;
 		}
 		if (i >= (1 << 16) / UDP_HTABLE_SIZE)
@@ -221,7 +221,7 @@ int __udp_lib_get_port(struct sock *sk, unsigned short snum,
 gotit:
 		*port_rover = snum = result;
 	} else {
-		hash = hash_port_and_addr(snum, 0);
+		hash = udp_hash_port(snum);
 		head = &udptable[hash & (UDP_HTABLE_SIZE - 1)];
 
 		sk_for_each(sk2, node, head)
@@ -231,12 +231,11 @@ gotit:
 			    (!sk2->sk_reuse || !sk->sk_reuse) &&
 			    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 			     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
-			    (*saddr_comp)(sk, sk2))
+			    ops->saddr_cmp(sk, sk2))
 				goto fail;
 
-		if (inet_sk(sk)->rcv_saddr) {
-			hash = hash_port_and_addr(snum,
-						  inet_sk(sk)->rcv_saddr);
+		if (!ops->saddr_any(sk)) {
+			hash = ops->hash_port_and_rcv_saddr(snum, sk);
 			head = &udptable[hash & (UDP_HTABLE_SIZE - 1)];
 
 			sk_for_each(sk2, node, head)
@@ -248,7 +247,7 @@ gotit:
 				     !sk->sk_bound_dev_if ||
 				     sk2->sk_bound_dev_if ==
 				     sk->sk_bound_dev_if) &&
-				    (*saddr_comp)(sk, sk2))
+				    ops->saddr_cmp(sk, sk2))
 					goto fail;
 		}
 	}
@@ -266,12 +265,12 @@ fail:
 }
 
 int udp_get_port(struct sock *sk, unsigned short snum,
-			int (*scmp)(const struct sock *, const struct sock *))
+		 const struct udp_get_port_ops *ops)
 {
-	return  __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover, scmp);
+	return  __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover, ops);
 }
 
-int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
+static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 {
 	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
 
@@ -280,9 +279,33 @@ int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 		   inet1->rcv_saddr == inet2->rcv_saddr      ));
 }
 
+static int ipv4_rcv_saddr_any(const struct sock *sk)
+{
+	return !inet_sk(sk)->rcv_saddr;
+}
+
+static inline unsigned int ipv4_hash_port_and_addr(__u16 port, __be32 addr)
+{
+	addr ^= addr >> 16;
+	addr ^= addr >> 8;
+	return port ^ addr;
+}
+
+static unsigned int ipv4_hash_port_and_rcv_saddr(__u16 port,
+						 const struct sock *sk)
+{
+	return ipv4_hash_port_and_addr(port, inet_sk(sk)->rcv_saddr);
+}
+
+const struct udp_get_port_ops udp_ipv4_ops = {
+	.saddr_cmp = ipv4_rcv_saddr_equal,
+	.saddr_any = ipv4_rcv_saddr_any,
+	.hash_port_and_rcv_saddr = ipv4_hash_port_and_rcv_saddr,
+};
+
 static inline int udp_v4_get_port(struct sock *sk, unsigned short snum)
 {
-	return udp_get_port(sk, snum, ipv4_rcv_saddr_equal);
+	return udp_get_port(sk, snum, &udp_ipv4_ops);
 }
 
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
@@ -297,8 +320,8 @@ static struct sock *__udp4_lib_lookup(__be32 saddr, __be16 sport,
 	unsigned int hash, hashwild;
 	int score, best = -1, hport = ntohs(dport);
 
- 	hash = hash_port_and_addr(hport, daddr);
- 	hashwild = hash_port_and_addr(hport, 0);
+ 	hash = ipv4_hash_port_and_addr(hport, daddr);
+ 	hashwild = udp_hash_port(hport);
 
 	read_lock(&udp_hash_lock);
 
@@ -1198,8 +1221,8 @@ static int __udp4_lib_mcast_deliver(struct sk_buff *skb,
 	struct sock *sk, *skw, *sknext;
 	int dif;
 	int hport = ntohs(uh->dest);
-	unsigned int hash = hash_port_and_addr(hport, daddr);
-	unsigned int hashwild = hash_port_and_addr(hport, 0);
+	unsigned int hash = ipv4_hash_port_and_addr(hport, daddr);
+	unsigned int hashwild = udp_hash_port(hport);
 
 	dif = skb->dev->ifindex;
 
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index 820a477..06d9419 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -5,14 +5,14 @@
 #include <net/protocol.h>
 #include <net/inet_common.h>
 
+extern const struct udp_get_port_ops udp_ipv4_ops;
+
 extern int  	__udp4_lib_rcv(struct sk_buff *, struct hlist_head [], int );
 extern void 	__udp4_lib_err(struct sk_buff *, u32, struct hlist_head []);
 
 extern int	__udp_lib_get_port(struct sock *sk, unsigned short snum,
 				   struct hlist_head udptable[], int *port_rover,
-				   int (*)(const struct sock*,const struct sock*));
-extern int	ipv4_rcv_saddr_equal(const struct sock *, const struct sock *);
-
+				   const struct udp_get_port_ops *ops);
 
 extern int	udp_setsockopt(struct sock *sk, int level, int optname,
 			       char __user *optval, int optlen);
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index f34fd68..3653b32 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -19,14 +19,15 @@ struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
 static int		udplite_port_rover;
 
 int udplite_get_port(struct sock *sk, unsigned short p,
-		     int (*c)(const struct sock *, const struct sock *))
+		     const struct udp_get_port_ops *ops)
 {
-	return  __udp_lib_get_port(sk, p, udplite_hash, &udplite_port_rover, c);
+	return  __udp_lib_get_port(sk, p, udplite_hash,
+				   &udplite_port_rover, ops);
 }
 
 static int udplite_v4_get_port(struct sock *sk, unsigned short snum)
 {
-	return udplite_get_port(sk, snum, ipv4_rcv_saddr_equal);
+	return udplite_get_port(sk, snum, &udp_ipv4_ops);
 }
 
 static int udplite_rcv(struct sk_buff *skb)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index b083c09..a7ae59c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -52,9 +52,28 @@
 
 DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6) __read_mostly;
 
+static int ipv6_rcv_saddr_any(const struct sock *sk)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+
+	return ipv6_addr_any(&np->rcv_saddr);
+}
+
+static unsigned int ipv6_hash_port_and_rcv_saddr(__u16 port,
+						 const struct sock *sk)
+{
+	return port;
+}
+
+const struct udp_get_port_ops udp_ipv6_ops = {
+	.saddr_cmp = ipv6_rcv_saddr_equal,
+	.saddr_any = ipv6_rcv_saddr_any,
+	.hash_port_and_rcv_saddr = ipv6_hash_port_and_rcv_saddr,
+};
+
 static inline int udp_v6_get_port(struct sock *sk, unsigned short snum)
 {
-	return udp_get_port(sk, snum, ipv6_rcv_saddr_equal);
+	return udp_get_port(sk, snum, &udp_ipv6_ops);
 }
 
 static struct sock *__udp6_lib_lookup(struct in6_addr *saddr, __be16 sport,
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index 6e252f3..36b0c11 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -6,6 +6,8 @@
 #include <net/addrconf.h>
 #include <net/inet_common.h>
 
+extern const struct udp_get_port_ops udp_ipv6_ops;
+
 extern int  	__udp6_lib_rcv(struct sk_buff **, struct hlist_head [], int );
 extern void 	__udp6_lib_err(struct sk_buff *, struct inet6_skb_parm *,
 			       int , int , int , __be32 , struct hlist_head []);
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index f54016a..c40a513 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -37,7 +37,7 @@ static struct inet6_protocol udplitev6_protocol = {
 
 static int udplite_v6_get_port(struct sock *sk, unsigned short snum)
 {
-	return udplite_get_port(sk, snum, ipv6_rcv_saddr_equal);
+	return udplite_get_port(sk, snum, &udp_ipv6_ops);
 }
 
 struct proto udplitev6_prot = {
