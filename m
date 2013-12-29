From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] ipv6: namespace cleanups
Date: Sun, 29 Dec 2013 14:03:31 -0800
Message-ID: <20131229140331.2bccc424@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:34149 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022Ab3L2WDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 17:03:34 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so10969141pbb.2
        for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 14:03:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running 'make namespacecheck' shows:
  net/ipv6/route.o
    ipv6_route_table_template
    rt6_bind_peer
  net/ipv6/icmp.o
    icmpv6_route_lookup
    ipv6_icmp_table_template

This addresses some of those warnings by:
 * make icmpv6_route_lookup static
 * move inline's out of ip6_route.h since only used into route.c
 * move rt6_bind_peer into route.c

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


---
 include/net/ip6_route.h |   20 ------------------
 include/net/ipv6.h      |    4 ---
 net/ipv6/icmp.c         |    8 ++++---
 net/ipv6/route.c        |   51 ++++++++++++++++++++++++++++++++----------------
 4 files changed, 40 insertions(+), 43 deletions(-)

--- a/include/net/ipv6.h	2013-12-24 15:15:26.617743229 -0800
+++ b/include/net/ipv6.h	2013-12-24 15:16:00.605286440 -0800
@@ -267,9 +267,6 @@ void icmpv6_notify(struct sk_buff *skb,
 int icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 			       struct icmp6hdr *thdr, int len);
 
-struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *skb,
-				      struct sock *sk, struct flowi6 *fl6);
-
 int ip6_ra_control(struct sock *sk, int sel);
 
 int ipv6_parse_hopopts(struct sk_buff *skb);
@@ -839,7 +836,6 @@ static inline int snmp6_unregister_dev(s
 
 #ifdef CONFIG_SYSCTL
 extern struct ctl_table ipv6_route_table_template[];
-extern struct ctl_table ipv6_icmp_table_template[];
 
 struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
 struct ctl_table *ipv6_route_sysctl_init(struct net *net);
--- a/net/ipv6/icmp.c	2013-12-24 15:15:26.617743229 -0800
+++ b/net/ipv6/icmp.c	2013-12-24 15:16:00.609286387 -0800
@@ -315,8 +315,10 @@ static void mip6_addr_swap(struct sk_buf
 static inline void mip6_addr_swap(struct sk_buff *skb) {}
 #endif
 
-struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *skb,
-				      struct sock *sk, struct flowi6 *fl6)
+static struct dst_entry *icmpv6_route_lookup(struct net *net,
+					     struct sk_buff *skb,
+					     struct sock *sk,
+					     struct flowi6 *fl6)
 {
 	struct dst_entry *dst, *dst2;
 	struct flowi6 fl2;
@@ -984,7 +986,7 @@ int icmpv6_err_convert(u8 type, u8 code,
 EXPORT_SYMBOL(icmpv6_err_convert);
 
 #ifdef CONFIG_SYSCTL
-struct ctl_table ipv6_icmp_table_template[] = {
+static struct ctl_table ipv6_icmp_table_template[] = {
 	{
 		.procname	= "ratelimit",
 		.data		= &init_net.ipv6.sysctl.icmpv6_time,
--- a/include/net/ip6_route.h	2013-12-24 15:15:26.617743229 -0800
+++ b/include/net/ip6_route.h	2013-12-24 15:16:00.609286387 -0800
@@ -51,26 +51,6 @@ static inline unsigned int rt6_flags2src
 	return (flags >> 3) & 7;
 }
 
-void rt6_bind_peer(struct rt6_info *rt, int create);
-
-static inline struct inet_peer *__rt6_get_peer(struct rt6_info *rt, int create)
-{
-	if (rt6_has_peer(rt))
-		return rt6_peer_ptr(rt);
-
-	rt6_bind_peer(rt, create);
-	return (rt6_has_peer(rt) ? rt6_peer_ptr(rt) : NULL);
-}
-
-static inline struct inet_peer *rt6_get_peer(struct rt6_info *rt)
-{
-	return __rt6_get_peer(rt, 0);
-}
-
-static inline struct inet_peer *rt6_get_peer_create(struct rt6_info *rt)
-{
-	return __rt6_get_peer(rt, 1);
-}
 
 void ip6_route_input(struct sk_buff *skb);
 
--- a/net/ipv6/route.c	2013-12-24 15:15:26.617743229 -0800
+++ b/net/ipv6/route.c	2013-12-24 15:21:36.784750846 -0800
@@ -104,6 +104,36 @@ static struct rt6_info *rt6_get_route_in
 					   const struct in6_addr *gwaddr, int ifindex);
 #endif
 
+static void rt6_bind_peer(struct rt6_info *rt, int create)
+{
+	struct inet_peer_base *base;
+	struct inet_peer *peer;
+
+	base = inetpeer_base_ptr(rt->_rt6i_peer);
+	if (!base)
+		return;
+
+	peer = inet_getpeer_v6(base, &rt->rt6i_dst.addr, create);
+	if (peer) {
+		if (!rt6_set_peer(rt, peer))
+			inet_putpeer(peer);
+	}
+}
+
+static struct inet_peer *__rt6_get_peer(struct rt6_info *rt, int create)
+{
+	if (rt6_has_peer(rt))
+		return rt6_peer_ptr(rt);
+
+	rt6_bind_peer(rt, create);
+	return (rt6_has_peer(rt) ? rt6_peer_ptr(rt) : NULL);
+}
+
+static struct inet_peer *rt6_get_peer_create(struct rt6_info *rt)
+{
+	return __rt6_get_peer(rt, 1);
+}
+
 static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
 	struct rt6_info *rt = (struct rt6_info *) dst;
@@ -312,22 +342,6 @@ static void ip6_dst_destroy(struct dst_e
 	}
 }
 
-void rt6_bind_peer(struct rt6_info *rt, int create)
-{
-	struct inet_peer_base *base;
-	struct inet_peer *peer;
-
-	base = inetpeer_base_ptr(rt->_rt6i_peer);
-	if (!base)
-		return;
-
-	peer = inet_getpeer_v6(base, &rt->rt6i_dst.addr, create);
-	if (peer) {
-		if (!rt6_set_peer(rt, peer))
-			inet_putpeer(peer);
-	}
-}
-
 static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 			   int how)
 {
