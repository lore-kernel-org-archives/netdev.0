From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [RFC, PATCH] udp: complete port availability checking
Date: Thu, 09 Oct 2008 00:31:32 +0200
Message-ID: <48ED34C4.3080203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070700060504020209090500"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.150]:49396 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755339AbYJHWcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 18:32:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070700060504020209090500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

While looking at UDP port randomization, I noticed it
was litle bit pessimistic, not looking at type of sockets
(IPV6/IPV4) and not looking at bound addresses if any.

We should perform same tests than when binding to a
specific port.

This permits a cleanup of udp_lib_get_port()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------070700060504020209090500
Content-Type: text/plain;
 name="udp_inuse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp_inuse.patch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 67d8430..eacf4cf 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -122,14 +122,23 @@ EXPORT_SYMBOL(sysctl_udp_wmem_min);
 atomic_t udp_memory_allocated;
 EXPORT_SYMBOL(udp_memory_allocated);
 
-static inline int __udp_lib_lport_inuse(struct net *net, __u16 num,
-					const struct hlist_head udptable[])
+static int udp_lib_lport_inuse(struct net *net, __u16 num,
+			       const struct hlist_head udptable[],
+			       struct sock *sk,
+			       int (*saddr_comp)(const struct sock *sk1,
+						 const struct sock *sk2))
 {
-	struct sock *sk;
+	struct sock *sk2;
 	struct hlist_node *node;
 
-	sk_for_each(sk, node, &udptable[udp_hashfn(net, num)])
-		if (net_eq(sock_net(sk), net) && sk->sk_hash == num)
+	sk_for_each(sk2, node, &udptable[udp_hashfn(net, num)])
+		if (net_eq(sock_net(sk2), net)			&&
+		    sk2 != sk					&&
+		    sk2->sk_hash == num				&&
+		    (!sk2->sk_reuse || !sk->sk_reuse)		&&
+		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
+			|| sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
+		    (*saddr_comp)(sk, sk2))
 			return 1;
 	return 0;
 }
@@ -146,9 +155,6 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 					 const struct sock *sk2 )    )
 {
 	struct hlist_head *udptable = sk->sk_prot->h.udp_hash;
-	struct hlist_node *node;
-	struct hlist_head *head;
-	struct sock *sk2;
 	int    error = 1;
 	struct net *net = sock_net(sk);
 
@@ -165,32 +171,21 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		rand = net_random();
 		snum = first = rand % remaining + low;
 		rand |= 1;
-		while (__udp_lib_lport_inuse(net, snum, udptable)) {
+		while (udp_lib_lport_inuse(net, snum, udptable, sk,
+					   saddr_comp)) {
 			do {
 				snum = snum + rand;
 			} while (snum < low || snum > high);
 			if (snum == first)
 				goto fail;
 		}
-	} else {
-		head = &udptable[udp_hashfn(net, snum)];
-
-		sk_for_each(sk2, node, head)
-			if (sk2->sk_hash == snum                             &&
-			    sk2 != sk                                        &&
-			    net_eq(sock_net(sk2), net)			     &&
-			    (!sk2->sk_reuse        || !sk->sk_reuse)         &&
-			    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
-			     || sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
-			    (*saddr_comp)(sk, sk2)                             )
-				goto fail;
-	}
+	} else if (udp_lib_lport_inuse(net, snum, udptable, sk, saddr_comp))
+		goto fail;
 
 	inet_sk(sk)->num = snum;
 	sk->sk_hash = snum;
 	if (sk_unhashed(sk)) {
-		head = &udptable[udp_hashfn(net, snum)];
-		sk_add_node(sk, head);
+		sk_add_node(sk, &udptable[udp_hashfn(net, snum)]);
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	}
 	error = 0;

--------------070700060504020209090500--


