From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 2/8] UDP: provide a struct net pointer for __udp[46]_lib_mcast_deliver
Date: Mon, 16 Jun 2008 13:40:07 +0400
Message-ID: <485634F7.5090600@openvz.org>
References: <485633E4.10900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39052 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755352AbYFPJme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:42:34 -0400
In-Reply-To: <485633E4.10900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They both calculate the hash chain, but currently do not have
a struct net pointer, so pass one there via additional argument,
all the more so their callers already have such.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/udp.c |    9 ++++++---
 net/ipv6/udp.c |   12 ++++++++----
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 34818c2..86755e0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1061,7 +1061,7 @@ drop:
  *	Note: called only from the BH handler context,
  *	so we don't need to lock the hashes.
  */
-static int __udp4_lib_mcast_deliver(struct sk_buff *skb,
+static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 				    struct udphdr  *uh,
 				    __be32 saddr, __be32 daddr,
 				    struct hlist_head udptable[])
@@ -1158,6 +1158,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	struct rtable *rt = (struct rtable*)skb->dst;
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
+	struct net *net;
 
 	/*
 	 *  Validate the packet.
@@ -1179,10 +1180,12 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	if (udp4_csum_init(skb, uh, proto))
 		goto csum_error;
 
+	net = dev_net(skb->dev);
 	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
-		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
+		return __udp4_lib_mcast_deliver(net, skb, uh,
+				saddr, daddr, udptable);
 
-	sk = __udp4_lib_lookup(dev_net(skb->dev), saddr, uh->source, daddr,
+	sk = __udp4_lib_lookup(net, saddr, uh->source, daddr,
 			uh->dest, inet_iif(skb), udptable);
 
 	if (sk != NULL) {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 61d3c99..e25fe4b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -355,8 +355,9 @@ static struct sock *udp_v6_mcast_next(struct sock *sk,
  * Note: called only from the BH handler context,
  * so we don't need to lock the hashes.
  */
-static int __udp6_lib_mcast_deliver(struct sk_buff *skb, struct in6_addr *saddr,
-			   struct in6_addr *daddr, struct hlist_head udptable[])
+static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
+		struct in6_addr *saddr, struct in6_addr *daddr,
+		struct hlist_head udptable[])
 {
 	struct sock *sk, *sk2;
 	const struct udphdr *uh = udp_hdr(skb);
@@ -437,6 +438,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	struct net_device *dev = skb->dev;
 	struct in6_addr *saddr, *daddr;
 	u32 ulen = 0;
+	struct net *net;
 
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
 		goto short_packet;
@@ -471,11 +473,13 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	if (udp6_csum_init(skb, uh, proto))
 		goto discard;
 
+	net = dev_net(skb->dev);
 	/*
 	 *	Multicast receive code
 	 */
 	if (ipv6_addr_is_multicast(daddr))
-		return __udp6_lib_mcast_deliver(skb, saddr, daddr, udptable);
+		return __udp6_lib_mcast_deliver(net, skb,
+				saddr, daddr, udptable);
 
 	/* Unicast */
 
@@ -483,7 +487,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	 * check socket cache ... must talk to Alan about his plans
 	 * for sock caches... i'll skip this for now.
 	 */
-	sk = __udp6_lib_lookup(dev_net(skb->dev), saddr, uh->source,
+	sk = __udp6_lib_lookup(net, saddr, uh->source,
 			       daddr, uh->dest, inet6_iif(skb), udptable);
 
 	if (sk == NULL) {
-- 
1.5.3.4

