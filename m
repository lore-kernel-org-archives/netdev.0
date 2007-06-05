From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] UDP : bind() checks are not complete
Date: Tue, 05 Jun 2007 16:00:52 -0700 (PDT)
Message-ID: <20070605.160052.07641221.davem@davemloft.net>
References: <20070605.130219.35356925.davem@davemloft.net>
	<4665C60C.1000406@cosmosbay.com>
	<20070605.133717.08652520.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932705AbXFEXAi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 19:00:38 -0400
In-Reply-To: <20070605.133717.08652520.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: David Miller <davem@davemloft.net>
Date: Tue, 05 Jun 2007 13:37:17 -0700 (PDT)

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 05 Jun 2007 22:22:36 +0200
>=20
> > David Miller a =E9crit :
> > > Does checking for INADDR_ANY sockets really require a full scan?
> > > It should just need two hash probes as far as I can tell to see
> > > if there is "0.0.0.0:PORT" bound already.
> >=20
> > Well, we might have 1000 ip addresses on the machine (or not :) ), =
and
> >=20
> > 192.168.0.1:PORT ... 192.168.0.254:PORT already bound.
>=20
> That's pretty serious.
>=20
> Sadly, I think we'll have to revert.

Which I will do as follows:

commit 82c5fde20031375cd93fa5a247cf15603ea1f152
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Jun 5 15:18:43 2007 -0700

    [UDP]: Revert 2-pass hashing changes.
   =20
    This reverts changesets:
   =20
    6aaf47fa48d3c44280810b1b470261d340e4ed87
    b7b5f487ab39bc10ed0694af35651a03d9cb97ff
    de34ed91c4ffa4727964a832c46e624dd1495cf5
    fc038410b4b1643766f8033f4940bcdb1dace633
   =20
    There are still some correctness issues recently
    discovered which do not have a known fix that doesn't
    involve doing a full hash table scan on port bind.
   =20
    So revert for now.
   =20
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/udp.h b/include/net/udp.h
index 496f89d..98755eb 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -119,16 +119,9 @@ static inline void udp_lib_close(struct sock *sk, =
long timeout)
 }
=20
=20
-struct udp_get_port_ops {
-	int (*saddr_cmp)(const struct sock *sk1, const struct sock *sk2);
-	int (*saddr_any)(const struct sock *sk);
-	unsigned int (*hash_port_and_rcv_saddr)(__u16 port,
-						const struct sock *sk);
-};
-
 /* net/ipv4/udp.c */
 extern int	udp_get_port(struct sock *sk, unsigned short snum,
-			     const struct udp_get_port_ops *ops);
+			     int (*saddr_cmp)(const struct sock *, const struct sock *));
 extern void	udp_err(struct sk_buff *, u32);
=20
 extern int	udp_sendmsg(struct kiocb *iocb, struct sock *sk,
diff --git a/include/net/udplite.h b/include/net/udplite.h
index 50b4b42..635b0ea 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -120,5 +120,5 @@ static inline __wsum udplite_csum_outgoing(struct s=
ock *sk, struct sk_buff *skb)
=20
 extern void	udplite4_register(void);
 extern int 	udplite_get_port(struct sock *sk, unsigned short snum,
-				 const struct udp_get_port_ops *ops);
+			int (*scmp)(const struct sock *, const struct sock *));
 #endif	/* _UDPLITE_H */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5da703e..facb7e2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -114,36 +114,14 @@ DEFINE_RWLOCK(udp_hash_lock);
=20
 static int udp_port_rover;
=20
-/*
- * Note about this hash function :
- * Typical use is probably daddr =3D 0, only dport is going to vary ha=
sh
- */
-static inline unsigned int udp_hash_port(__u16 port)
-{
-	return port;
-}
-
-static inline int __udp_lib_port_inuse(unsigned int hash, int port,
-				       const struct sock *this_sk,
-				       struct hlist_head udptable[],
-				       const struct udp_get_port_ops *ops)
+static inline int __udp_lib_lport_inuse(__u16 num, struct hlist_head u=
dptable[])
 {
 	struct sock *sk;
 	struct hlist_node *node;
-	struct inet_sock *inet;
=20
-	sk_for_each(sk, node, &udptable[hash & (UDP_HTABLE_SIZE - 1)]) {
-		if (sk->sk_hash !=3D hash)
-			continue;
-		inet =3D inet_sk(sk);
-		if (inet->num !=3D port)
-			continue;
-		if (this_sk) {
-			if (ops->saddr_cmp(sk, this_sk))
-				return 1;
-		} else if (ops->saddr_any(sk))
+	sk_for_each(sk, node, &udptable[num & (UDP_HTABLE_SIZE - 1)])
+		if (sk->sk_hash =3D=3D num)
 			return 1;
-	}
 	return 0;
 }
=20
@@ -154,16 +132,16 @@ static inline int __udp_lib_port_inuse(unsigned i=
nt hash, int port,
  *  @snum:        port number to look up
  *  @udptable:    hash list table, must be of UDP_HTABLE_SIZE
  *  @port_rover:  pointer to record of last unallocated port
- *  @ops:         AF-dependent address operations
+ *  @saddr_comp:  AF-dependent comparison of bound local IP addresses
  */
 int __udp_lib_get_port(struct sock *sk, unsigned short snum,
 		       struct hlist_head udptable[], int *port_rover,
-		       const struct udp_get_port_ops *ops)
+		       int (*saddr_comp)(const struct sock *sk1,
+					 const struct sock *sk2 )    )
 {
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct sock *sk2;
-	unsigned int hash;
 	int    error =3D 1;
=20
 	write_lock_bh(&udp_hash_lock);
@@ -178,8 +156,7 @@ int __udp_lib_get_port(struct sock *sk, unsigned sh=
ort snum,
 		for (i =3D 0; i < UDP_HTABLE_SIZE; i++, result++) {
 			int size;
=20
-			hash =3D ops->hash_port_and_rcv_saddr(result, sk);
-			head =3D &udptable[hash & (UDP_HTABLE_SIZE - 1)];
+			head =3D &udptable[result & (UDP_HTABLE_SIZE - 1)];
 			if (hlist_empty(head)) {
 				if (result > sysctl_local_port_range[1])
 					result =3D sysctl_local_port_range[0] +
@@ -204,16 +181,7 @@ int __udp_lib_get_port(struct sock *sk, unsigned s=
hort snum,
 				result =3D sysctl_local_port_range[0]
 					+ ((result - sysctl_local_port_range[0]) &
 					   (UDP_HTABLE_SIZE - 1));
-			hash =3D udp_hash_port(result);
-			if (__udp_lib_port_inuse(hash, result,
-						 NULL, udptable, ops))
-				continue;
-			if (ops->saddr_any(sk))
-				break;
-
-			hash =3D ops->hash_port_and_rcv_saddr(result, sk);
-			if (! __udp_lib_port_inuse(hash, result,
-						   sk, udptable, ops))
+			if (! __udp_lib_lport_inuse(result, udptable))
 				break;
 		}
 		if (i >=3D (1 << 16) / UDP_HTABLE_SIZE)
@@ -221,40 +189,21 @@ int __udp_lib_get_port(struct sock *sk, unsigned =
short snum,
 gotit:
 		*port_rover =3D snum =3D result;
 	} else {
-		hash =3D udp_hash_port(snum);
-		head =3D &udptable[hash & (UDP_HTABLE_SIZE - 1)];
+		head =3D &udptable[snum & (UDP_HTABLE_SIZE - 1)];
=20
 		sk_for_each(sk2, node, head)
-			if (sk2->sk_hash =3D=3D hash &&
-			    sk2 !=3D sk &&
-			    inet_sk(sk2)->num =3D=3D snum &&
-			    (!sk2->sk_reuse || !sk->sk_reuse) &&
-			    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
-			     sk2->sk_bound_dev_if =3D=3D sk->sk_bound_dev_if) &&
-			    ops->saddr_cmp(sk, sk2))
+			if (sk2->sk_hash =3D=3D snum                             &&
+			    sk2 !=3D sk                                        &&
+			    (!sk2->sk_reuse        || !sk->sk_reuse)         &&
+			    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
+			     || sk2->sk_bound_dev_if =3D=3D sk->sk_bound_dev_if) &&
+			    (*saddr_comp)(sk, sk2)                             )
 				goto fail;
-
-		if (!ops->saddr_any(sk)) {
-			hash =3D ops->hash_port_and_rcv_saddr(snum, sk);
-			head =3D &udptable[hash & (UDP_HTABLE_SIZE - 1)];
-
-			sk_for_each(sk2, node, head)
-				if (sk2->sk_hash =3D=3D hash &&
-				    sk2 !=3D sk &&
-				    inet_sk(sk2)->num =3D=3D snum &&
-				    (!sk2->sk_reuse || !sk->sk_reuse) &&
-				    (!sk2->sk_bound_dev_if ||
-				     !sk->sk_bound_dev_if ||
-				     sk2->sk_bound_dev_if =3D=3D
-				     sk->sk_bound_dev_if) &&
-				    ops->saddr_cmp(sk, sk2))
-					goto fail;
-		}
 	}
 	inet_sk(sk)->num =3D snum;
-	sk->sk_hash =3D hash;
+	sk->sk_hash =3D snum;
 	if (sk_unhashed(sk)) {
-		head =3D &udptable[hash & (UDP_HTABLE_SIZE - 1)];
+		head =3D &udptable[snum & (UDP_HTABLE_SIZE - 1)];
 		sk_add_node(sk, head);
 		sock_prot_inc_use(sk->sk_prot);
 	}
@@ -265,12 +214,12 @@ fail:
 }
=20
 int udp_get_port(struct sock *sk, unsigned short snum,
-		 const struct udp_get_port_ops *ops)
+			int (*scmp)(const struct sock *, const struct sock *))
 {
-	return  __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover, ops);
+	return  __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover, scmp)=
;
 }
=20
-static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct s=
ock *sk2)
+int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk=
2)
 {
 	struct inet_sock *inet1 =3D inet_sk(sk1), *inet2 =3D inet_sk(sk2);
=20
@@ -279,33 +228,9 @@ static int ipv4_rcv_saddr_equal(const struct sock =
*sk1, const struct sock *sk2)
 		   inet1->rcv_saddr =3D=3D inet2->rcv_saddr      ));
 }
=20
-static int ipv4_rcv_saddr_any(const struct sock *sk)
-{
-	return !inet_sk(sk)->rcv_saddr;
-}
-
-static inline unsigned int ipv4_hash_port_and_addr(__u16 port, __be32 =
addr)
-{
-	addr ^=3D addr >> 16;
-	addr ^=3D addr >> 8;
-	return port ^ addr;
-}
-
-static unsigned int ipv4_hash_port_and_rcv_saddr(__u16 port,
-						 const struct sock *sk)
-{
-	return ipv4_hash_port_and_addr(port, inet_sk(sk)->rcv_saddr);
-}
-
-const struct udp_get_port_ops udp_ipv4_ops =3D {
-	.saddr_cmp =3D ipv4_rcv_saddr_equal,
-	.saddr_any =3D ipv4_rcv_saddr_any,
-	.hash_port_and_rcv_saddr =3D ipv4_hash_port_and_rcv_saddr,
-};
-
 static inline int udp_v4_get_port(struct sock *sk, unsigned short snum=
)
 {
-	return udp_get_port(sk, snum, &udp_ipv4_ops);
+	return udp_get_port(sk, snum, ipv4_rcv_saddr_equal);
 }
=20
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to =
try
@@ -317,77 +242,63 @@ static struct sock *__udp4_lib_lookup(__be32 sadd=
r, __be16 sport,
 {
 	struct sock *sk, *result =3D NULL;
 	struct hlist_node *node;
-	unsigned int hash, hashwild;
-	int score, best =3D -1, hport =3D ntohs(dport);
-
-	hash =3D ipv4_hash_port_and_addr(hport, daddr);
-	hashwild =3D udp_hash_port(hport);
+	unsigned short hnum =3D ntohs(dport);
+	int badness =3D -1;
=20
 	read_lock(&udp_hash_lock);
-
-lookup:
-
-	sk_for_each(sk, node, &udptable[hash & (UDP_HTABLE_SIZE - 1)]) {
+	sk_for_each(sk, node, &udptable[hnum & (UDP_HTABLE_SIZE - 1)]) {
 		struct inet_sock *inet =3D inet_sk(sk);
=20
-		if (sk->sk_hash !=3D hash || ipv6_only_sock(sk) ||
-			inet->num !=3D hport)
-			continue;
-
-		score =3D (sk->sk_family =3D=3D PF_INET ? 1 : 0);
-		if (inet->rcv_saddr) {
-			if (inet->rcv_saddr !=3D daddr)
-				continue;
-			score+=3D2;
-		}
-		if (inet->daddr) {
-			if (inet->daddr !=3D saddr)
-				continue;
-			score+=3D2;
-		}
-		if (inet->dport) {
-			if (inet->dport !=3D sport)
-				continue;
-			score+=3D2;
-		}
-		if (sk->sk_bound_dev_if) {
-			if (sk->sk_bound_dev_if !=3D dif)
-				continue;
-			score+=3D2;
-		}
-		if (score =3D=3D 9) {
-			result =3D sk;
-			goto found;
-		} else if (score > best) {
-			result =3D sk;
-			best =3D score;
+		if (sk->sk_hash =3D=3D hnum && !ipv6_only_sock(sk)) {
+			int score =3D (sk->sk_family =3D=3D PF_INET ? 1 : 0);
+			if (inet->rcv_saddr) {
+				if (inet->rcv_saddr !=3D daddr)
+					continue;
+				score+=3D2;
+			}
+			if (inet->daddr) {
+				if (inet->daddr !=3D saddr)
+					continue;
+				score+=3D2;
+			}
+			if (inet->dport) {
+				if (inet->dport !=3D sport)
+					continue;
+				score+=3D2;
+			}
+			if (sk->sk_bound_dev_if) {
+				if (sk->sk_bound_dev_if !=3D dif)
+					continue;
+				score+=3D2;
+			}
+			if (score =3D=3D 9) {
+				result =3D sk;
+				break;
+			} else if (score > badness) {
+				result =3D sk;
+				badness =3D score;
+			}
 		}
 	}
-
-	if (hash !=3D hashwild) {
-		hash =3D hashwild;
-		goto lookup;
-	}
-found:
 	if (result)
 		sock_hold(result);
 	read_unlock(&udp_hash_lock);
 	return result;
 }
=20
-static inline struct sock *udp_v4_mcast_next(struct sock *sk, unsigned=
 int hnum,
-					     int hport, __be32 loc_addr,
+static inline struct sock *udp_v4_mcast_next(struct sock *sk,
+					     __be16 loc_port, __be32 loc_addr,
 					     __be16 rmt_port, __be32 rmt_addr,
 					     int dif)
 {
 	struct hlist_node *node;
 	struct sock *s =3D sk;
+	unsigned short hnum =3D ntohs(loc_port);
=20
 	sk_for_each_from(s, node) {
 		struct inet_sock *inet =3D inet_sk(s);
=20
 		if (s->sk_hash !=3D hnum					||
-		    inet->num !=3D hport					||
 		    (inet->daddr && inet->daddr !=3D rmt_addr)		||
 		    (inet->dport !=3D rmt_port && inet->dport)		||
 		    (inet->rcv_saddr && inet->rcv_saddr !=3D loc_addr)	||
@@ -1221,45 +1132,29 @@ static int __udp4_lib_mcast_deliver(struct sk_b=
uff *skb,
 				    __be32 saddr, __be32 daddr,
 				    struct hlist_head udptable[])
 {
-	struct sock *sk, *skw, *sknext;
+	struct sock *sk;
 	int dif;
-	int hport =3D ntohs(uh->dest);
-	unsigned int hash =3D ipv4_hash_port_and_addr(hport, daddr);
-	unsigned int hashwild =3D udp_hash_port(hport);
-
-	dif =3D skb->dev->ifindex;
=20
 	read_lock(&udp_hash_lock);
-
-	sk =3D sk_head(&udptable[hash & (UDP_HTABLE_SIZE - 1)]);
-	skw =3D sk_head(&udptable[hashwild & (UDP_HTABLE_SIZE - 1)]);
-
-	sk =3D udp_v4_mcast_next(sk, hash, hport, daddr, uh->source, saddr, d=
if);
-	if (!sk) {
-		hash =3D hashwild;
-		sk =3D udp_v4_mcast_next(skw, hash, hport, daddr, uh->source,
-			saddr, dif);
-	}
+	sk =3D sk_head(&udptable[ntohs(uh->dest) & (UDP_HTABLE_SIZE - 1)]);
+	dif =3D skb->dev->ifindex;
+	sk =3D udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif)=
;
 	if (sk) {
+		struct sock *sknext =3D NULL;
+
 		do {
 			struct sk_buff *skb1 =3D skb;
-			sknext =3D udp_v4_mcast_next(sk_next(sk), hash, hport,
-						daddr, uh->source, saddr, dif);
-			if (!sknext && hash !=3D hashwild) {
-				hash =3D hashwild;
-				sknext =3D udp_v4_mcast_next(skw, hash, hport,
-					daddr, uh->source, saddr, dif);
-			}
+
+			sknext =3D udp_v4_mcast_next(sk_next(sk), uh->dest, daddr,
+						   uh->source, saddr, dif);
 			if (sknext)
 				skb1 =3D skb_clone(skb, GFP_ATOMIC);
=20
 			if (skb1) {
 				int ret =3D udp_queue_rcv_skb(sk, skb1);
 				if (ret > 0)
-					/*
-					 * we should probably re-process
-					 * instead of dropping packets here.
-					 */
+					/* we should probably re-process instead
+					 * of dropping packets here. */
 					kfree_skb(skb1);
 			}
 			sk =3D sknext;
@@ -1346,7 +1241,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hl=
ist_head udptable[],
 		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
=20
 	sk =3D __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
-			       skb->dev->ifindex, udptable);
+			       skb->dev->ifindex, udptable        );
=20
 	if (sk !=3D NULL) {
 		int ret =3D udp_queue_rcv_skb(sk, skb);
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index 06d9419..820a477 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -5,14 +5,14 @@
 #include <net/protocol.h>
 #include <net/inet_common.h>
=20
-extern const struct udp_get_port_ops udp_ipv4_ops;
-
 extern int  	__udp4_lib_rcv(struct sk_buff *, struct hlist_head [], in=
t );
 extern void 	__udp4_lib_err(struct sk_buff *, u32, struct hlist_head [=
]);
=20
 extern int	__udp_lib_get_port(struct sock *sk, unsigned short snum,
 				   struct hlist_head udptable[], int *port_rover,
-				   const struct udp_get_port_ops *ops);
+				   int (*)(const struct sock*,const struct sock*));
+extern int	ipv4_rcv_saddr_equal(const struct sock *, const struct sock=
 *);
+
=20
 extern int	udp_setsockopt(struct sock *sk, int level, int optname,
 			       char __user *optval, int optlen);
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 3653b32..f34fd68 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -19,15 +19,14 @@ struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
 static int		udplite_port_rover;
=20
 int udplite_get_port(struct sock *sk, unsigned short p,
-		     const struct udp_get_port_ops *ops)
+		     int (*c)(const struct sock *, const struct sock *))
 {
-	return  __udp_lib_get_port(sk, p, udplite_hash,
-				   &udplite_port_rover, ops);
+	return  __udp_lib_get_port(sk, p, udplite_hash, &udplite_port_rover, =
c);
 }
=20
 static int udplite_v4_get_port(struct sock *sk, unsigned short snum)
 {
-	return udplite_get_port(sk, snum, &udp_ipv4_ops);
+	return udplite_get_port(sk, snum, ipv4_rcv_saddr_equal);
 }
=20
 static int udplite_rcv(struct sk_buff *skb)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d1fbddd..4210951 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -52,28 +52,9 @@
=20
 DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6) __read_mostly;
=20
-static int ipv6_rcv_saddr_any(const struct sock *sk)
-{
-	struct ipv6_pinfo *np =3D inet6_sk(sk);
-
-	return ipv6_addr_any(&np->rcv_saddr);
-}
-
-static unsigned int ipv6_hash_port_and_rcv_saddr(__u16 port,
-						 const struct sock *sk)
-{
-	return port;
-}
-
-const struct udp_get_port_ops udp_ipv6_ops =3D {
-	.saddr_cmp =3D ipv6_rcv_saddr_equal,
-	.saddr_any =3D ipv6_rcv_saddr_any,
-	.hash_port_and_rcv_saddr =3D ipv6_hash_port_and_rcv_saddr,
-};
-
 static inline int udp_v6_get_port(struct sock *sk, unsigned short snum=
)
 {
-	return udp_get_port(sk, snum, &udp_ipv6_ops);
+	return udp_get_port(sk, snum, ipv6_rcv_saddr_equal);
 }
=20
 static struct sock *__udp6_lib_lookup(struct in6_addr *saddr, __be16 s=
port,
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index 36b0c11..6e252f3 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -6,8 +6,6 @@
 #include <net/addrconf.h>
 #include <net/inet_common.h>
=20
-extern const struct udp_get_port_ops udp_ipv6_ops;
-
 extern int  	__udp6_lib_rcv(struct sk_buff **, struct hlist_head [], i=
nt );
 extern void 	__udp6_lib_err(struct sk_buff *, struct inet6_skb_parm *,
 			       int , int , int , __be32 , struct hlist_head []);
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index c40a513..f54016a 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -37,7 +37,7 @@ static struct inet6_protocol udplitev6_protocol =3D {
=20
 static int udplite_v6_get_port(struct sock *sk, unsigned short snum)
 {
-	return udplite_get_port(sk, snum, &udp_ipv6_ops);
+	return udplite_get_port(sk, snum, ipv6_rcv_saddr_equal);
 }
=20
 struct proto udplitev6_prot =3D {
