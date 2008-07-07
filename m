From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 2/7] INET: toss struct net initialization around
Date: Mon, 07 Jul 2008 14:47:16 +0400
Message-ID: <4871F434.3000104@openvz.org>
References: <4871F2D8.8030502@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44404 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752766AbYGGKts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 06:49:48 -0400
In-Reply-To: <4871F2D8.8030502@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some places, that deal with ICMP statistics already have where
to get a struct net from, but use it directly, without declaring
a separate variable on the stack.

Since I will need this net soon, I declare a struct net on the 
stack and use it in the existing places in a separate patch not 
to spoil the future ones.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/dccp/ipv4.c     |    3 ++-
 net/ipv4/icmp.c     |    4 +---
 net/ipv4/tcp_ipv4.c |    3 ++-
 net/ipv4/udp.c      |    3 ++-
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 37d27bc..cc4f334 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -205,13 +205,14 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	struct sock *sk;
 	__u64 seq;
 	int err;
+	struct net *net = dev_net(skb->dev);
 
 	if (skb->len < (iph->ihl << 2) + 8) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
 		return;
 	}
 
-	sk = inet_lookup(dev_net(skb->dev), &dccp_hashinfo,
+	sk = inet_lookup(net, &dccp_hashinfo,
 			iph->daddr, dh->dccph_dport,
 			iph->saddr, dh->dccph_sport, inet_iif(skb));
 	if (sk == NULL) {
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 1ffe7ad..56d6b94 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -973,6 +973,7 @@ int icmp_rcv(struct sk_buff *skb)
 {
 	struct icmphdr *icmph;
 	struct rtable *rt = skb->rtable;
+	struct net *net = dev_net(rt->u.dst.dev);
 
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 		int nh;
@@ -1027,9 +1028,6 @@ int icmp_rcv(struct sk_buff *skb)
 	 */
 
 	if (rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST)) {
-		struct net *net;
-
-		net = dev_net(rt->u.dst.dev);
 		/*
 		 *	RFC 1122: 3.2.2.6 An ICMP_ECHO to broadcast MAY be
 		 *	  silently ignored (we let user decide with a sysctl).
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4300bcf..ca41b77 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -343,13 +343,14 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
 	struct sock *sk;
 	__u32 seq;
 	int err;
+	struct net *net = dev_net(skb->dev);
 
 	if (skb->len < (iph->ihl << 2) + 8) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
 		return;
 	}
 
-	sk = inet_lookup(dev_net(skb->dev), &tcp_hashinfo, iph->daddr, th->dest,
+	sk = inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
 			iph->saddr, th->source, inet_iif(skb));
 	if (!sk) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7187121..9342cfd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -354,8 +354,9 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct hlist_head udptable[])
 	struct sock *sk;
 	int harderr;
 	int err;
+	struct net *net = dev_net(skb->dev);
 
-	sk = __udp4_lib_lookup(dev_net(skb->dev), iph->daddr, uh->dest,
+	sk = __udp4_lib_lookup(net, iph->daddr, uh->dest,
 			iph->saddr, uh->source, skb->dev->ifindex, udptable);
 	if (sk == NULL) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
-- 
1.5.3.4

