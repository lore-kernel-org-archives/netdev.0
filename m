From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Make rt->fl.iif tests lest obscure.
Date: Thu, 11 Nov 2010 16:28:14 -0800 (PST)
Message-ID: <20101111.162814.35035010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51496
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755099Ab0KLA1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 19:27:50 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B622024C089
	for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 16:28:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When we test rt->fl.iif against zero, we're seeing if it's
an output or an input route.

Make that explicit with some helper functions.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-next-2.6, this has bugged me for some
time. :-)

diff --git a/include/net/route.h b/include/net/route.h
index cea533e..5cd46d1 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -71,6 +71,16 @@ struct rtable {
 	struct inet_peer	*peer; /* long-living peer info */
 };
 
+static inline bool rt_is_input_route(struct rtable *rt)
+{
+	return rt->fl.iif != 0;
+}
+
+static inline bool rt_is_output_route(struct rtable *rt)
+{
+	return rt->fl.iif == 0;
+}
+
 struct ip_rt_acct {
 	__u32 	o_bytes;
 	__u32 	o_packets;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 94a9eb1..9aad1c0 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1181,7 +1181,7 @@ static int __dn_route_output_key(struct dst_entry **pprt, const struct flowi *fl
 			if ((flp->fld_dst == rt->fl.fld_dst) &&
 			    (flp->fld_src == rt->fl.fld_src) &&
 			    (flp->mark == rt->fl.mark) &&
-			    (rt->fl.iif == 0) &&
+			    rt_is_output_route(rt) &&
 			    (rt->fl.oif == flp->oif)) {
 				dst_use(&rt->dst, jiffies);
 				rcu_read_unlock_bh();
@@ -1512,7 +1512,7 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, 0, 0, expires,
 			       rt->dst.error) < 0)
 		goto rtattr_failure;
-	if (rt->fl.iif)
+	if (rt_is_input_route(rt))
 		RTA_PUT(skb, RTA_IIF, sizeof(int), &rt->fl.iif);
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 96bc7f9..c6e2aff 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -506,8 +506,8 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		struct net_device *dev = NULL;
 
 		rcu_read_lock();
-		if (rt->fl.iif &&
-			net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr)
+		if (rt_is_input_route(rt) &&
+		    net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr)
 			dev = dev_get_by_index_rcu(net, rt->fl.iif);
 
 		if (dev)
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index c8877c6..08d0d81 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -961,7 +961,7 @@ int igmp_rcv(struct sk_buff *skb)
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
 		/* Is it our report looped back? */
-		if (skb_rtable(skb)->fl.iif == 0)
+		if (rt_is_output_route(skb_rtable(skb)))
 			break;
 		/* don't rely on MC router hearing unicast reports */
 		if (skb->pkt_type == PACKET_MULTICAST ||
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 70ff77f..cab2057 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -634,7 +634,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 		if (ipv4_is_multicast(iph->daddr)) {
 			/* Looped back packet, drop it! */
-			if (skb_rtable(skb)->fl.iif == 0)
+			if (rt_is_output_route(skb_rtable(skb)))
 				goto drop;
 			tunnel->dev->stats.multicast++;
 			skb->pkt_type = PACKET_BROADCAST;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 86dd569..ef2b008 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1654,7 +1654,7 @@ static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 	if (mrt->vif_table[vif].dev != skb->dev) {
 		int true_vifi;
 
-		if (skb_rtable(skb)->fl.iif == 0) {
+		if (rt_is_output_route(skb_rtable(skb))) {
 			/* It is our own packet, looped back.
 			 * Very complicated situation...
 			 *
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5955965..66610ea 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -623,7 +623,7 @@ static inline int rt_fast_clean(struct rtable *rth)
 	/* Kill broadcast/multicast entries very aggresively, if they
 	   collide in hash table with more useful entries */
 	return (rth->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST)) &&
-		rth->fl.iif && rth->dst.rt_next;
+		rt_is_input_route(rth) && rth->dst.rt_next;
 }
 
 static inline int rt_valuable(struct rtable *rth)
@@ -668,7 +668,7 @@ static inline u32 rt_score(struct rtable *rt)
 	if (rt_valuable(rt))
 		score |= (1<<31);
 
-	if (!rt->fl.iif ||
+	if (rt_is_output_route(rt) ||
 	    !(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL)))
 		score |= (1<<30);
 
@@ -1126,7 +1126,7 @@ restart:
 		 */
 
 		rt->dst.flags |= DST_NOCACHE;
-		if (rt->rt_type == RTN_UNICAST || rt->fl.iif == 0) {
+		if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
 			int err = arp_bind_neighbour(&rt->dst);
 			if (err) {
 				if (net_ratelimit())
@@ -1224,7 +1224,7 @@ restart:
 	/* Try to bind route to arp only if it is output
 	   route or unicast forwarding path.
 	 */
-	if (rt->rt_type == RTN_UNICAST || rt->fl.iif == 0) {
+	if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
 		int err = arp_bind_neighbour(&rt->dst);
 		if (err) {
 			spin_unlock_bh(rt_hash_lock_addr(hash));
@@ -1406,7 +1406,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				if (rth->fl.fl4_dst != daddr ||
 				    rth->fl.fl4_src != skeys[i] ||
 				    rth->fl.oif != ikeys[k] ||
-				    rth->fl.iif != 0 ||
+				    rt_is_input_route(rth) ||
 				    rt_is_expired(rth) ||
 				    !net_eq(dev_net(rth->dst.dev), net)) {
 					rthp = &rth->dst.rt_next;
@@ -1666,7 +1666,7 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 				    rth->rt_dst != daddr ||
 				    rth->rt_src != iph->saddr ||
 				    rth->fl.oif != ikeys[k] ||
-				    rth->fl.iif != 0 ||
+				    rt_is_input_route(rth) ||
 				    dst_metric_locked(&rth->dst, RTAX_MTU) ||
 				    !net_eq(dev_net(rth->dst.dev), net) ||
 				    rt_is_expired(rth))
@@ -1770,7 +1770,7 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 	__be32 src;
 	struct fib_result res;
 
-	if (rt->fl.iif == 0)
+	if (rt_is_output_route(rt))
 		src = rt->rt_src;
 	else {
 		rcu_read_lock();
@@ -2669,7 +2669,7 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 		rth = rcu_dereference_bh(rth->dst.rt_next)) {
 		if (rth->fl.fl4_dst == flp->fl4_dst &&
 		    rth->fl.fl4_src == flp->fl4_src &&
-		    rth->fl.iif == 0 &&
+		    rt_is_output_route(rth) &&
 		    rth->fl.oif == flp->oif &&
 		    rth->fl.mark == flp->mark &&
 		    !((rth->fl.fl4_tos ^ flp->fl4_tos) &
@@ -2824,7 +2824,7 @@ static int rt_fill_info(struct net *net,
 	if (rt->dst.tclassid)
 		NLA_PUT_U32(skb, RTA_FLOW, rt->dst.tclassid);
 #endif
-	if (rt->fl.iif)
+	if (rt_is_input_route(rt))
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_spec_dst);
 	else if (rt->rt_src != rt->fl.fl4_src)
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_src);
@@ -2849,7 +2849,7 @@ static int rt_fill_info(struct net *net,
 		}
 	}
 
-	if (rt->fl.iif) {
+	if (rt_is_input_route(rt)) {
 #ifdef CONFIG_IP_MROUTE
 		__be32 dst = rt->rt_dst;
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index de04ea3..10bd39c 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -169,7 +169,7 @@ __ip_vs_reroute_locally(struct sk_buff *skb)
 	struct net *net = dev_net(dev);
 	struct iphdr *iph = ip_hdr(skb);
 
-	if (rt->fl.iif) {
+	if (rt_is_input_route(rt)) {
 		unsigned long orefdst = skb->_skb_refdst;
 
 		if (ip_route_input(skb, iph->daddr, iph->saddr,
@@ -552,7 +552,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #endif
 
 	/* From world but DNAT to loopback address? */
-	if (local && ipv4_is_loopback(rt->rt_dst) && skb_rtable(skb)->fl.iif) {
+	if (local && ipv4_is_loopback(rt->rt_dst) &&
+	    rt_is_input_route(skb_rtable(skb))) {
 		IP_VS_DBG_RL_PKT(1, AF_INET, pp, skb, 0, "ip_vs_nat_xmit(): "
 				 "stopping DNAT to loopback address");
 		goto tx_error_put;
@@ -1165,7 +1166,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #endif
 
 	/* From world but DNAT to loopback address? */
-	if (local && ipv4_is_loopback(rt->rt_dst) && skb_rtable(skb)->fl.iif) {
+	if (local && ipv4_is_loopback(rt->rt_dst) &&
+	    rt_is_input_route(skb_rtable(skb))) {
 		IP_VS_DBG(1, "%s(): "
 			  "stopping DNAT to loopback %pI4\n",
 			  __func__, &cp->daddr.ip);
