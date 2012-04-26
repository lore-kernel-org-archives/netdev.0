From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Heavy spin_lock contention in __udp4_lib_mcast_deliver increase
Date: Thu, 26 Apr 2012 18:18:32 +0200
Message-ID: <1335457112.2775.50.camel@edumazet-glaptop>
References: <20120426151527.GA2479@BohrerMBP.rgmadvisors.com>
	 <1335455595.2775.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61712 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757718Ab2DZQSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 12:18:39 -0400
Received: by eekc41 with SMTP id c41so665616eek.19
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 09:18:38 -0700 (PDT)
In-Reply-To: <1335455595.2775.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 17:53 +0200, Eric Dumazet wrote:

> Let me understand
> 
> You have 300 sockets bound to the same port, so a single message must be
> copied 300 times and delivered to those sockets ?
> 
> 

Please try the following patch. It should allow up to 512 sockets (on
x86_64) to be stored in stack, and delivery performed out of the locked
section.

 net/ipv4/udp.c |   16 ++++++++++++----
 net/ipv6/udp.c |   15 +++++++++++----
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 279fd08..beb9ea6 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1539,13 +1539,20 @@ static void flush_stack(struct sock **stack, unsigned int count,
 static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 				    struct udphdr  *uh,
 				    __be32 saddr, __be32 daddr,
-				    struct udp_table *udptable)
+				    struct udp_table *udptable,
+				   int proto)
 {
-	struct sock *sk, *stack[256 / sizeof(struct sock *)];
+	struct sock *sk, **stack;
 	struct udp_hslot *hslot = udp_hashslot(udptable, net, ntohs(uh->dest));
 	int dif;
 	unsigned int i, count = 0;
 
+	stack = kmalloc(PAGE_SIZE, GFP_ATOMIC);
+	if (unlikely(!stack)) {
+		UDP_INC_STATS_BH(net, UDP_MIB_RCVBUFERRORS, proto == IPPROTO_UDPLITE);
+		kfree_skb(skb);
+		return 0;
+	}
 	spin_lock(&hslot->lock);
 	sk = sk_nulls_head(&hslot->head);
 	dif = skb->dev->ifindex;
@@ -1554,7 +1561,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		stack[count++] = sk;
 		sk = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
 				       daddr, uh->source, saddr, dif);
-		if (unlikely(count == ARRAY_SIZE(stack))) {
+		if (unlikely(count == PAGE_SIZE/sizeof(*sk))) {
 			if (!sk)
 				break;
 			flush_stack(stack, count, skb, ~0);
@@ -1580,6 +1587,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	} else {
 		kfree_skb(skb);
 	}
+	kfree(stack);
 	return 0;
 }
 
@@ -1661,7 +1669,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 
 	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return __udp4_lib_mcast_deliver(net, skb, uh,
-				saddr, daddr, udptable);
+				saddr, daddr, udptable, proto);
 
 	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d39bbc9..fc79b87 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -640,14 +640,20 @@ drop:
  */
 static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		const struct in6_addr *saddr, const struct in6_addr *daddr,
-		struct udp_table *udptable)
+		struct udp_table *udptable, int proto)
 {
-	struct sock *sk, *stack[256 / sizeof(struct sock *)];
+	struct sock *sk, **stack;
 	const struct udphdr *uh = udp_hdr(skb);
 	struct udp_hslot *hslot = udp_hashslot(udptable, net, ntohs(uh->dest));
 	int dif;
 	unsigned int i, count = 0;
 
+	stack = kmalloc(PAGE_SIZE, GFP_ATOMIC);
+	if (unlikely(!stack)) {
+		UDP6_INC_STATS_BH(net, UDP_MIB_RCVBUFERRORS, proto == IPPROTO_UDPLITE);
+		kfree_skb(skb);
+		return 0;
+	}
 	spin_lock(&hslot->lock);
 	sk = sk_nulls_head(&hslot->head);
 	dif = inet6_iif(skb);
@@ -656,7 +662,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		stack[count++] = sk;
 		sk = udp_v6_mcast_next(net, sk_nulls_next(sk), uh->dest, daddr,
 				       uh->source, saddr, dif);
-		if (unlikely(count == ARRAY_SIZE(stack))) {
+		if (unlikely(count == PAGE_SIZE/sizeof(*sk))) {
 			if (!sk)
 				break;
 			flush_stack(stack, count, skb, ~0);
@@ -679,6 +685,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	} else {
 		kfree_skb(skb);
 	}
+	kfree(stack);
 	return 0;
 }
 
@@ -763,7 +770,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	 */
 	if (ipv6_addr_is_multicast(daddr))
 		return __udp6_lib_mcast_deliver(net, skb,
-				saddr, daddr, udptable);
+				saddr, daddr, udptable, proto);
 
 	/* Unicast */
 
