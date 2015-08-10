From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 6/9] net: Fix up inet_addr_type checks
Date: Mon, 10 Aug 2015 11:50:33 -0600
Message-ID: <1439229037-79213-7-git-send-email-dsa@cumulusnetworks.com>
References: <1439229037-79213-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33107 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097AbbHJRwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 13:52:51 -0400
Received: by ioii16 with SMTP id i16so177203145ioi.0
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 10:52:51 -0700 (PDT)
In-Reply-To: <1439229037-79213-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently inet_addr_type and inet_dev_addr_type expect local addresses
to be in the local table. With the VRF device local routes for devices
associated with a VRF will be in the table associated with the VRF.
Provide an alternate inet_addr lookup to use a specific table rather
than defaulting to the local table.

inet_addr_type_dev_table keeps the same semantics as inet_addr_type but
if the passed in device is enslaved to a VRF then the table for that VRF
is used for the lookup.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/route.h      |  3 +++
 net/ipv4/af_inet.c       | 13 ++++++++++++-
 net/ipv4/arp.c           | 15 +++++++++------
 net/ipv4/fib_frontend.c  | 28 +++++++++++++++++++++++++---
 net/ipv4/fib_semantics.c |  6 ++++--
 net/ipv4/icmp.c          |  5 +++--
 6 files changed, 56 insertions(+), 14 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 6ba681f0b98d..6dda2c1bf8c6 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -192,6 +192,9 @@ unsigned int inet_addr_type(struct net *net, __be32 addr);
 unsigned int inet_addr_type_table(struct net *net, __be32 addr, int tb_id);
 unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 				__be32 addr);
+unsigned int inet_addr_type_dev_table(struct net *net,
+				      const struct net_device *dev,
+				      __be32 addr);
 void ip_rt_multicast_event(struct in_device *);
 int ip_rt_ioctl(struct net *, unsigned int cmd, void __user *arg);
 void ip_rt_get_source(u8 *src, struct sk_buff *skb, struct rtable *rt);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cc4e498a0ccf..96fba4f63454 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -119,6 +119,7 @@
 #ifdef CONFIG_IP_MROUTE
 #include <linux/mroute.h>
 #endif
+#include <net/vrf.h>
 
 
 /* The inetsw table contains everything that inet_create needs to
@@ -427,6 +428,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct net *net = sock_net(sk);
 	unsigned short snum;
 	int chk_addr_ret;
+	int tb_id = 0;
 	int err;
 
 	/* If the socket has its own bind function then use it. (RAW) */
@@ -448,7 +450,16 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out;
 	}
 
-	chk_addr_ret = inet_addr_type(net, addr->sin_addr.s_addr);
+	if (sk->sk_bound_dev_if) {
+		struct net_device *dev;
+
+		rcu_read_lock();
+		dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
+		if (dev)
+			tb_id = vrf_dev_table_rcu(dev);
+		rcu_read_unlock();
+	}
+	chk_addr_ret = inet_addr_type_table(net, addr->sin_addr.s_addr, tb_id);
 
 	/* Not specified by any standard per-se, however it breaks too
 	 * many applications when removed.  It is unfortunate since
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 34a308573f4b..30409b75e925 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -233,7 +233,7 @@ static int arp_constructor(struct neighbour *neigh)
 		return -EINVAL;
 	}
 
-	neigh->type = inet_addr_type(dev_net(dev), addr);
+	neigh->type = inet_addr_type_dev_table(dev_net(dev), dev, addr);
 
 	parms = in_dev->arp_parms;
 	__neigh_parms_put(neigh->parms);
@@ -343,7 +343,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	switch (IN_DEV_ARP_ANNOUNCE(in_dev)) {
 	default:
 	case 0:		/* By default announce any local IP */
-		if (skb && inet_addr_type(dev_net(dev),
+		if (skb && inet_addr_type_dev_table(dev_net(dev), dev,
 					  ip_hdr(skb)->saddr) == RTN_LOCAL)
 			saddr = ip_hdr(skb)->saddr;
 		break;
@@ -351,7 +351,8 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 		if (!skb)
 			break;
 		saddr = ip_hdr(skb)->saddr;
-		if (inet_addr_type(dev_net(dev), saddr) == RTN_LOCAL) {
+		if (inet_addr_type_dev_table(dev_net(dev), dev,
+					     saddr) == RTN_LOCAL) {
 			/* saddr should be known to target */
 			if (inet_addr_onlink(in_dev, target, saddr))
 				break;
@@ -751,7 +752,7 @@ static int arp_process(struct sock *sk, struct sk_buff *skb)
 	/* Special case: IPv4 duplicate address detection packet (RFC2131) */
 	if (sip == 0) {
 		if (arp->ar_op == htons(ARPOP_REQUEST) &&
-		    inet_addr_type(net, tip) == RTN_LOCAL &&
+		    inet_addr_type_dev_table(net, dev, tip) == RTN_LOCAL &&
 		    !arp_ignore(in_dev, sip, tip))
 			arp_send(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha,
 				 dev->dev_addr, sha);
@@ -811,16 +812,18 @@ static int arp_process(struct sock *sk, struct sk_buff *skb)
 	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
 
 	if (IN_DEV_ARP_ACCEPT(in_dev)) {
+		unsigned int addr_type = inet_addr_type_dev_table(net, dev, sip);
+
 		/* Unsolicited ARP is not accepted by default.
 		   It is possible, that this option should be enabled for some
 		   devices (strip is candidate)
 		 */
 		is_garp = arp->ar_op == htons(ARPOP_REQUEST) && tip == sip &&
-			  inet_addr_type(net, sip) == RTN_UNICAST;
+			  addr_type == RTN_UNICAST;
 
 		if (!n &&
 		    ((arp->ar_op == htons(ARPOP_REPLY)  &&
-		      inet_addr_type(net, sip) == RTN_UNICAST) || is_garp))
+				addr_type == RTN_UNICAST) || is_garp))
 			n = __neigh_lookup(&arp_tbl, &sip, dev, 1);
 	}
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index b11321a8e58d..d84ae0e30369 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -226,6 +226,9 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 
 	rcu_read_lock();
 
+	if (!tb_id)
+		tb_id = RT_TABLE_LOCAL;
+
 	table = fib_get_table(net, tb_id);
 	if (table) {
 		ret = RTN_UNICAST;
@@ -260,6 +263,19 @@ unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 }
 EXPORT_SYMBOL(inet_dev_addr_type);
 
+/* inet_addr_type with dev == NULL but using the table from a dev
+ * if one is associated
+ */
+unsigned int inet_addr_type_dev_table(struct net *net,
+				      const struct net_device *dev,
+				      __be32 addr)
+{
+	int rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
+
+	return __inet_dev_addr_type(net, NULL, addr, rt_table);
+}
+EXPORT_SYMBOL(inet_addr_type_dev_table);
+
 __be32 fib_compute_spec_dst(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
@@ -510,9 +526,12 @@ static int rtentry_to_fib_config(struct net *net, int cmd, struct rtentry *rt,
 
 	addr = sk_extract_addr(&rt->rt_gateway);
 	if (rt->rt_gateway.sa_family == AF_INET && addr) {
+		unsigned int addr_type;
+
 		cfg->fc_gw = addr;
+		addr_type = inet_addr_type_table(net, cfg->fc_table, addr);
 		if (rt->rt_flags & RTF_GATEWAY &&
-		    inet_addr_type(net, addr) == RTN_UNICAST)
+		    addr_type == RTN_UNICAST)
 			cfg->fc_scope = RT_SCOPE_UNIVERSE;
 	}
 
@@ -984,11 +1003,14 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 			fib_magic(RTM_DELROUTE, RTN_BROADCAST, any, 32, prim);
 	}
 	if (!(ok & LOCAL_OK)) {
+		unsigned int addr_type;
+
 		fib_magic(RTM_DELROUTE, RTN_LOCAL, ifa->ifa_local, 32, prim);
 
 		/* Check, that this local address finally disappeared. */
-		if (gone &&
-		    inet_addr_type(dev_net(dev), ifa->ifa_local) != RTN_LOCAL) {
+		addr_type = inet_addr_type_dev_table(dev_net(dev), dev,
+						     ifa->ifa_local);
+		if (gone && addr_type != RTN_LOCAL) {
 			/* And the last, but not the least thing.
 			 * We must flush stray FIB entries.
 			 *
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 558e196bae0f..410ddb67221e 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -670,16 +670,18 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 		struct fib_result res;
 
 		if (nh->nh_flags & RTNH_F_ONLINK) {
+			unsigned int addr_type;
 
 			if (cfg->fc_scope >= RT_SCOPE_LINK)
 				return -EINVAL;
-			if (inet_addr_type(net, nh->nh_gw) != RTN_UNICAST)
-				return -EINVAL;
 			dev = __dev_get_by_index(net, nh->nh_oif);
 			if (!dev)
 				return -ENODEV;
 			if (!(dev->flags & IFF_UP))
 				return -ENETDOWN;
+			addr_type = inet_addr_type_dev_table(net, dev, nh->nh_gw);
+			if (addr_type != RTN_UNICAST)
+				return -EINVAL;
 			if (!netif_carrier_ok(dev))
 				nh->nh_flags |= RTNH_F_LINKDOWN;
 			nh->nh_dev = dev;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 1164fc4ce3bc..c6f1ce149ffb 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -484,7 +484,8 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	if (err)
 		goto relookup_failed;
 
-	if (inet_addr_type(net, fl4_dec.saddr) == RTN_LOCAL) {
+	if (inet_addr_type_dev_table(net, skb_in->dev,
+				     fl4_dec.saddr) == RTN_LOCAL) {
 		rt2 = __ip_route_output_key(net, &fl4_dec);
 		if (IS_ERR(rt2))
 			err = PTR_ERR(rt2);
@@ -833,7 +834,7 @@ static bool icmp_unreach(struct sk_buff *skb)
 	 */
 
 	if (!net->ipv4.sysctl_icmp_ignore_bogus_error_responses &&
-	    inet_addr_type(net, iph->daddr) == RTN_BROADCAST) {
+	    inet_addr_type_dev_table(net, skb->dev, iph->daddr) == RTN_BROADCAST) {
 		net_warn_ratelimited("%pI4 sent an invalid ICMP type %u, code %u error to a broadcast: %pI4 on %s\n",
 				     &ip_hdr(skb)->saddr,
 				     icmph->type, icmph->code,
-- 
2.3.2 (Apple Git-55)
