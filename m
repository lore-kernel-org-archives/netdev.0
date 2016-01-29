From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net v2 1/2] ipv6: enforce flowi6_oif usage in ip6_dst_lookup_tail()
Date: Fri, 29 Jan 2016 12:30:19 +0100
Message-ID: <f7809ccbe430587d183d9679b8fbea4b61a9af7e.1454066754.git.pabeni@redhat.com>
References: <cover.1454066754.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39170 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754525AbcA2Lam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2016 06:30:42 -0500
In-Reply-To: <cover.1454066754.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implementation of ip6_dst_lookup_tail basically
ignore the egress ifindex match: if the saddr is set,
ip6_route_output() purposefully ignores flowi6_oif, due
to the commit d46a9d678e4c ("net: ipv6: Dont add RT6_LOOKUP_F_IFACE
flag if saddr set"), if the saddr is 'any' the first route lookup
in ip6_dst_lookup_tail fails, but upon failure a second lookup will
be performed with saddr set, thus ignoring the ifindex constraint.

This commit adds an output route lookup function variant, which
allows the caller to specify lookup flags, and modify
ip6_dst_lookup_tail() to enforce the ifindex match on the second
lookup via said helper.

ip6_route_output() becames now a static inline function build on
top of ip6_route_output_flags(); as a side effect, out-of-tree
modules need now a GPL license to access the output route lookup
functionality.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
--
v1 -> v2 move the ip6_route_output() implementation into the header
---
 include/net/ip6_route.h | 12 ++++++++++--
 net/ipv6/ip6_output.c   |  6 +++++-
 net/ipv6/route.c        |  7 +++----
 3 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 877f682..295d291 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -64,8 +64,16 @@ static inline bool rt6_need_strict(const struct in6_addr *daddr)
 
 void ip6_route_input(struct sk_buff *skb);
 
-struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
-				   struct flowi6 *fl6);
+struct dst_entry *ip6_route_output_flags(struct net *net, const struct sock *sk,
+					 struct flowi6 *fl6, int flags);
+
+static inline struct dst_entry *ip6_route_output(struct net *net,
+						 const struct sock *sk,
+						 struct flowi6 *fl6)
+{
+	return ip6_route_output_flags(net, sk, fl6, 0);
+}
+
 struct dst_entry *ip6_route_lookup(struct net *net, struct flowi6 *fl6,
 				   int flags);
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 23de98f..a163102 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -909,6 +909,7 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 	struct rt6_info *rt;
 #endif
 	int err;
+	int flags = 0;
 
 	/* The correct way to handle this would be to do
 	 * ip6_route_get_saddr, and then ip6_route_output; however,
@@ -940,10 +941,13 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 			dst_release(*dst);
 			*dst = NULL;
 		}
+
+		if (fl6->flowi6_oif)
+			flags |= RT6_LOOKUP_F_IFACE;
 	}
 
 	if (!*dst)
-		*dst = ip6_route_output(net, sk, fl6);
+		*dst = ip6_route_output_flags(net, sk, fl6, flags);
 
 	err = (*dst)->error;
 	if (err)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3c8834b..ed44663 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1183,11 +1183,10 @@ static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table
 	return ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags);
 }
 
-struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
-				    struct flowi6 *fl6)
+struct dst_entry *ip6_route_output_flags(struct net *net, const struct sock *sk,
+					 struct flowi6 *fl6, int flags)
 {
 	struct dst_entry *dst;
-	int flags = 0;
 	bool any_src;
 
 	dst = l3mdev_rt6_dst_by_oif(net, fl6);
@@ -1208,7 +1207,7 @@ struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
 
 	return fib6_rule_lookup(net, fl6, flags, ip6_pol_route_output);
 }
-EXPORT_SYMBOL(ip6_route_output);
+EXPORT_SYMBOL_GPL(ip6_route_output_flags);
 
 struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_orig)
 {
-- 
1.8.3.1
