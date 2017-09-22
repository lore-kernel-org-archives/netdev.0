From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 09/11] route: add ipv4/6 helpers to do partial route lookup vs local dst
Date: Fri, 22 Sep 2017 23:06:33 +0200
Message-ID: <5aaba993111c3609b309e8a0edb6da2146b08c9c.1506114055.git.pabeni@redhat.com>
References: <cover.1506114055.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36352 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752747AbdIVVHP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 17:07:15 -0400
In-Reply-To: <cover.1506114055.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For ipv4 also implement the proper source address validation, even
against martian addresses and return an error code accordingly.

Will be used by later patches to perform dst lookup in early
demux for unconnected sockets.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/ip6_route.h |  1 +
 include/net/route.h     |  2 ++
 net/ipv4/route.c        | 43 +++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/route.c        | 13 +++++++++++++
 4 files changed, 59 insertions(+)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index ee96f402cb75..edb24456a609 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -65,6 +65,7 @@ static inline bool rt6_need_strict(const struct in6_addr *daddr)
 		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
 }
 
+void ip6_route_try_local_rcu_bh(struct net *net, struct sk_buff *skb);
 void ip6_route_input(struct sk_buff *skb);
 struct dst_entry *ip6_route_input_lookup(struct net *net,
 					 struct net_device *dev,
diff --git a/include/net/route.h b/include/net/route.h
index ec09c3d73581..21927231cc14 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -178,6 +178,8 @@ static inline struct rtable *ip_route_output_gre(struct net *net, struct flowi4
 
 struct rtable *ip_local_route_alloc(struct net_device *dev, unsigned int flags,
 				    u32 itag, unsigned char type, bool docache);
+int ip_route_try_local_rcu(struct net *net, struct sk_buff *skb,
+			   const struct iphdr *iph);
 int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 src,
 			 u8 tos, struct net_device *devin);
 int ip_route_input_rcu(struct sk_buff *skb, __be32 dst, __be32 src,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 515589f1b3d1..84248dd41da6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2079,6 +2079,49 @@ out:	return err;
 	goto out;
 }
 
+/* try to resolve and set the route for the ingress packet in the local
+ * destination, looking-up the destination address against the local ones
+ * and performing source validation
+ * return an error only if the local look up is successful and validation fails
+ * Called under RCU
+ */
+int ip_route_try_local_rcu(struct net *net, struct sk_buff *skb,
+			   const struct iphdr *iph)
+{
+	__be32 saddr = iph->saddr;
+	struct in_device *in_dev;
+	struct dst_entry *dst;
+	int err = -EINVAL;
+	u32 itag;
+
+	dst = inet_get_ifaddr_dst_rcu(net, iph->daddr);
+	if (!dst)
+		return 0;
+
+	in_dev = __in_dev_get_rcu(skb->dev);
+	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr))
+		goto martian_source;
+
+	/* check for zeronet only after successful lookup, so that we don't trip
+	 * over limited broadcast destination, see ip_route_input_slow()
+	 */
+	if (ipv4_is_zeronet(saddr) || (ipv4_is_loopback(saddr) &&
+				       !IN_DEV_NET_ROUTE_LOCALNET(in_dev, net)))
+		goto martian_source;
+
+	err = fib_validate_source(skb, saddr, iph->daddr, iph->tos, 0, skb->dev,
+				  in_dev, &itag);
+	if (err < 0)
+		goto martian_source;
+
+	skb_dst_set_noref(skb, dst);
+	return 0;
+
+martian_source:
+	ip_handle_martian_source(skb->dev, in_dev, skb, iph->daddr, iph->saddr);
+	return err;
+}
+
 int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			 u8 tos, struct net_device *dev)
 {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 26cc9f483b6d..d957e30b1cbe 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1283,6 +1283,19 @@ void ip6_route_input(struct sk_buff *skb)
 	skb_dst_set(skb, ip6_route_input_lookup(net, skb->dev, &fl6, flags));
 }
 
+/* try to resolve and set the route for the ingress packet in the local
+ * destination
+ * Called under RCU
+ */
+void ip6_route_try_local_rcu_bh(struct net *net, struct sk_buff *skb)
+{
+	struct dst_entry *dst;
+
+	dst = inet6_get_ifaddr_dst_rcu_bh(net, &ipv6_hdr(skb)->daddr);
+	if (dst)
+		skb_dst_set_noref(skb, dst);
+}
+
 static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
 					     struct flowi6 *fl6, int flags)
 {
-- 
2.13.5
