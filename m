From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 3/8] UDP: add struct net argument to udp_hashfn
Date: Mon, 16 Jun 2008 13:41:33 +0400
Message-ID: <4856354D.9040104@openvz.org>
References: <485633E4.10900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39311 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755722AbYFPJn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:43:57 -0400
In-Reply-To: <485633E4.10900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every caller already has this one. The new argument is currently 
unused, but this will be fixed shortly.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/linux/udp.h |    2 +-
 net/ipv4/udp.c      |   12 ++++++------
 net/ipv6/udp.c      |    4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 9c94312..3deccac 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -46,7 +46,7 @@ static inline struct udphdr *udp_hdr(const struct sk_buff *skb)
 
 #define UDP_HTABLE_SIZE		128
 
-static inline int udp_hashfn(const unsigned num)
+static inline int udp_hashfn(struct net *net, const unsigned num)
 {
 	return num & (UDP_HTABLE_SIZE - 1);
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 86755e0..8b96189 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -136,7 +136,7 @@ static inline int __udp_lib_lport_inuse(struct net *net, __u16 num,
 	struct sock *sk;
 	struct hlist_node *node;
 
-	sk_for_each(sk, node, &udptable[udp_hashfn(num)])
+	sk_for_each(sk, node, &udptable[udp_hashfn(net, num)])
 		if (net_eq(sock_net(sk), net) && sk->sk_hash == num)
 			return 1;
 	return 0;
@@ -176,7 +176,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		for (i = 0; i < UDP_HTABLE_SIZE; i++) {
 			int size = 0;
 
-			head = &udptable[udp_hashfn(rover)];
+			head = &udptable[udp_hashfn(net, rover)];
 			if (hlist_empty(head))
 				goto gotit;
 
@@ -213,7 +213,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 gotit:
 		snum = rover;
 	} else {
-		head = &udptable[udp_hashfn(snum)];
+		head = &udptable[udp_hashfn(net, snum)];
 
 		sk_for_each(sk2, node, head)
 			if (sk2->sk_hash == snum                             &&
@@ -229,7 +229,7 @@ gotit:
 	inet_sk(sk)->num = snum;
 	sk->sk_hash = snum;
 	if (sk_unhashed(sk)) {
-		head = &udptable[udp_hashfn(snum)];
+		head = &udptable[udp_hashfn(net, snum)];
 		sk_add_node(sk, head);
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	}
@@ -266,7 +266,7 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	int badness = -1;
 
 	read_lock(&udp_hash_lock);
-	sk_for_each(sk, node, &udptable[udp_hashfn(hnum)]) {
+	sk_for_each(sk, node, &udptable[udp_hashfn(net, hnum)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
 		if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
@@ -1070,7 +1070,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	int dif;
 
 	read_lock(&udp_hash_lock);
-	sk = sk_head(&udptable[udp_hashfn(ntohs(uh->dest))]);
+	sk = sk_head(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
 	dif = skb->dev->ifindex;
 	sk = udp_v4_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (sk) {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e25fe4b..6b962b0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -67,7 +67,7 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 	int badness = -1;
 
 	read_lock(&udp_hash_lock);
-	sk_for_each(sk, node, &udptable[udp_hashfn(hnum)]) {
+	sk_for_each(sk, node, &udptable[udp_hashfn(net, hnum)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
 		if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
@@ -364,7 +364,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	int dif;
 
 	read_lock(&udp_hash_lock);
-	sk = sk_head(&udptable[udp_hashfn(ntohs(uh->dest))]);
+	sk = sk_head(&udptable[udp_hashfn(net, ntohs(uh->dest))]);
 	dif = inet6_iif(skb);
 	sk = udp_v6_mcast_next(sk, uh->dest, daddr, uh->source, saddr, dif);
 	if (!sk) {
-- 
1.5.3.4

