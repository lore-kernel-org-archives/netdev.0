From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCHv1] ipv6: Fix RTM_GETROUTE's interpretation of RTA_IIF to be
 consistent with ipv4
Date: Sun, 1 Apr 2012 17:03:45 +0300
Message-ID: <20120401170345.5ed75cab@pixies.home.jungo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:55696 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307Ab2DAOD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 10:03:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In IPv4, if an RTA_IIF attribute is specified within an RTM_GETROUTE
message, then a route is searched as if a packet was received on the
specified 'iif' interface.

However in IPv6, RTA_IIF is not interpreted in the same way:
'inet6_rtm_getroute()' always calls 'ip6_route_output()', regardless the
RTA_IIF attribute.

As a result, in IPv6 there's no way to use RTM_GETROUTE in order to look
for a route as if a packet was received on a specific interface.

Fix 'inet6_rtm_getroute()' so that RTA_IIF is interpreted as "lookup a
route as if a packet was received on the specified interface", similar
to IPv4's 'inet_rtm_getroute()' interpretation.

Reported-by: Ami Koren <amikoren@yahoo.com>
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---

Tested on v3.2.6. Patch applies to v3.3.

Few points to review:

1) An alternative: construction of an skb within 'inet6_rtm_getroute()'
   and then calling 'ip6_route_input()' with the skb as an argument.
   Thus, no need to split common code of 'ip6_route_input()'.
   Less elegant IMO.
 
2) Better name for the new common function 'ip6_route_input_lookup()'
   Will happily accept any better suggestions.

3) In IPv4 the 'ip_route_input()' call within 'inet_rtm_getroute()'is
   protected by a 'local_bh_disable()' since dawn of history.
   Not sure if similar protection needed within 'inet6_rtm_getroute()'.

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 22b7664..1178345 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -868,6 +868,16 @@ static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *
 	return ip6_pol_route(net, table, fl6->flowi6_iif, fl6, flags);
 }
 
+static struct dst_entry *ip6_route_input_lookup(struct net *net,
+						struct net_device *dev,
+						struct flowi6 *fl6, int flags)
+{
+	if (rt6_need_strict(&fl6->daddr) && dev->type != ARPHRD_PIMREG)
+		flags |= RT6_LOOKUP_F_IFACE;
+
+	return fib6_rule_lookup(net, fl6, flags, ip6_pol_route_input);
+}
+
 void ip6_route_input(struct sk_buff *skb)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
@@ -882,10 +892,7 @@ void ip6_route_input(struct sk_buff *skb)
 		.flowi6_proto = iph->nexthdr,
 	};
 
-	if (rt6_need_strict(&iph->daddr) && skb->dev->type != ARPHRD_PIMREG)
-		flags |= RT6_LOOKUP_F_IFACE;
-
-	skb_dst_set(skb, fib6_rule_lookup(net, &fl6, flags, ip6_pol_route_input));
+	skb_dst_set(skb, ip6_route_input_lookup(net, skb->dev, &fl6, flags));
 }
 
 static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
@@ -2520,7 +2527,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	struct sk_buff *skb;
 	struct rtmsg *rtm;
 	struct flowi6 fl6;
-	int err, iif = 0;
+	int err, iif = 0, oif = 0;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy);
 	if (err < 0)
@@ -2547,15 +2554,29 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 		iif = nla_get_u32(tb[RTA_IIF]);
 
 	if (tb[RTA_OIF])
-		fl6.flowi6_oif = nla_get_u32(tb[RTA_OIF]);
+		oif = nla_get_u32(tb[RTA_OIF]);
 
 	if (iif) {
 		struct net_device *dev;
+		int flags = 0;
+
 		dev = __dev_get_by_index(net, iif);
 		if (!dev) {
 			err = -ENODEV;
 			goto errout;
 		}
+
+		fl6.flowi6_iif = iif;
+
+		if (!ipv6_addr_any(&fl6.saddr))
+			flags |= RT6_LOOKUP_F_HAS_SADDR;
+
+		rt = (struct rt6_info *)ip6_route_input_lookup(net, dev, &fl6,
+							       flags);
+	} else {
+		fl6.flowi6_oif = oif;
+
+		rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
 	}
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
@@ -2570,7 +2591,6 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	skb_reset_mac_header(skb);
 	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
 
-	rt = (struct rt6_info*) ip6_route_output(net, NULL, &fl6);
 	skb_dst_set(skb, &rt->dst);
 
 	err = rt6_fill_node(net, skb, rt, &fl6.daddr, &fl6.saddr, iif,
