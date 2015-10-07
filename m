From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 4/4] net: Add VRF support to IPv6 stack
Date: Wed,  7 Oct 2015 15:02:17 -0700
Message-ID: <1444255337-36414-5-git-send-email-dsa@cumulusnetworks.com>
References: <1444255337-36414-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34501 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756638AbbJGWC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 18:02:29 -0400
Received: by padhy16 with SMTP id hy16so32858743pad.1
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 15:02:29 -0700 (PDT)
In-Reply-To: <1444255337-36414-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As with IPv4 support for VRFs added to IPv6 stack by replacing hardcoded
table ids with possibly device specific ones and manipulating the oif in
the flowi6. The flow flags are used to skip oif compare in nexthop lookups
if the device is enslaved to a VRF via the L3 master device.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/addrconf.c   | 12 +++++++++---
 net/ipv6/icmp.c       |  6 +++++-
 net/ipv6/ip6_output.c |  6 ++++--
 net/ipv6/ndisc.c      | 26 +++++++++++++++++++++++---
 net/ipv6/route.c      | 22 +++++++++++++++++-----
 5 files changed, 58 insertions(+), 14 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b2d6f2fc0fbd..e07b1fb52131 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -81,6 +81,7 @@
 #include <net/ip.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/l3mdev.h>
 #include <linux/if_tunnel.h>
 #include <linux/rtnetlink.h>
 #include <linux/netconf.h>
@@ -2149,7 +2150,7 @@ addrconf_prefix_route(struct in6_addr *pfx, int plen, struct net_device *dev,
 		      unsigned long expires, u32 flags)
 {
 	struct fib6_config cfg = {
-		.fc_table = RT6_TABLE_PREFIX,
+		.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_PREFIX,
 		.fc_metric = IP6_RT_PRIO_ADDRCONF,
 		.fc_ifindex = dev->ifindex,
 		.fc_expires = expires,
@@ -2182,8 +2183,9 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 	struct fib6_node *fn;
 	struct rt6_info *rt = NULL;
 	struct fib6_table *table;
+	u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_PREFIX;
 
-	table = fib6_get_table(dev_net(dev), RT6_TABLE_PREFIX);
+	table = fib6_get_table(dev_net(dev), tb_id);
 	if (!table)
 		return NULL;
 
@@ -2214,7 +2216,7 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 static void addrconf_add_mroute(struct net_device *dev)
 {
 	struct fib6_config cfg = {
-		.fc_table = RT6_TABLE_LOCAL,
+		.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_LOCAL,
 		.fc_metric = IP6_RT_PRIO_ADDRCONF,
 		.fc_ifindex = dev->ifindex,
 		.fc_dst_len = 8,
@@ -3035,6 +3037,10 @@ static void addrconf_addr_gen(struct inet6_dev *idev, bool prefix_route)
 {
 	struct in6_addr addr;
 
+	/* no link local addresses on L3 master devices */
+	if (netif_is_l3_master(idev->dev))
+		return;
+
 	ipv6_addr_set(&addr, htonl(0xFE800000), 0, 0, 0);
 
 	if (idev->addr_gen_mode == IN6_ADDR_GEN_MODE_STABLE_PRIVACY) {
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 6c2b2132c8d3..efb1c00f2270 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -68,6 +68,7 @@
 #include <net/xfrm.h>
 #include <net/inet_common.h>
 #include <net/dsfield.h>
+#include <net/l3mdev.h>
 
 #include <asm/uaccess.h>
 
@@ -496,6 +497,9 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	else if (!fl6.flowi6_oif)
 		fl6.flowi6_oif = np->ucast_oif;
 
+	if (!fl6.flowi6_oif)
+		fl6.flowi6_oif = l3mdev_master_ifindex(skb->dev);
+
 	dst = icmpv6_route_lookup(net, skb, sk, &fl6);
 	if (IS_ERR(dst))
 		goto out;
@@ -575,7 +579,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	fl6.daddr = ipv6_hdr(skb)->saddr;
 	if (saddr)
 		fl6.saddr = *saddr;
-	fl6.flowi6_oif = skb->dev->ifindex;
+	fl6.flowi6_oif = l3mdev_fib_oif(skb->dev);
 	fl6.fl6_icmp_type = ICMPV6_ECHO_REPLY;
 	fl6.flowi6_mark = mark;
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index caf7d14a1bdd..527870ccf5c1 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -55,6 +55,7 @@
 #include <net/xfrm.h>
 #include <net/checksum.h>
 #include <linux/mroute6.h>
+#include <net/l3mdev.h>
 
 static int ip6_finish_output2(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
@@ -886,7 +887,8 @@ static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
 #ifdef CONFIG_IPV6_SUBTREES
 	    ip6_rt_check(&rt->rt6i_src, &fl6->saddr, np->saddr_cache) ||
 #endif
-	    (fl6->flowi6_oif && fl6->flowi6_oif != dst->dev->ifindex)) {
+	   (!(fl6->flowi6_flags & FLOWI_FLAG_SKIP_NH_OIF) &&
+	      (fl6->flowi6_oif && fl6->flowi6_oif != dst->dev->ifindex))) {
 		dst_release(dst);
 		dst = NULL;
 	}
@@ -1038,7 +1040,7 @@ struct dst_entry *ip6_dst_lookup_flow(const struct sock *sk, struct flowi6 *fl6,
 	if (final_dst)
 		fl6->daddr = *final_dst;
 	if (!fl6->flowi6_oif)
-		fl6->flowi6_oif = dst->dev->ifindex;
+		fl6->flowi6_oif = l3mdev_fib_oif(dst->dev);
 
 	return xfrm_lookup_route(sock_net(sk), dst, flowi6_to_flowi(fl6), sk, 0);
 }
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index b3292db05198..0b85242d8469 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -67,6 +67,7 @@
 #include <net/flow.h>
 #include <net/ip6_checksum.h>
 #include <net/inet_common.h>
+#include <net/l3mdev.h>
 #include <linux/proc_fs.h>
 
 #include <linux/netfilter.h>
@@ -442,8 +443,11 @@ static void ndisc_send_skb(struct sk_buff *skb,
 
 	if (!dst) {
 		struct flowi6 fl6;
+		int oif = l3mdev_fib_oif(skb->dev);
 
-		icmpv6_flow_init(sk, &fl6, type, saddr, daddr, skb->dev->ifindex);
+		icmpv6_flow_init(sk, &fl6, type, saddr, daddr, oif);
+		if (oif != skb->dev->ifindex)
+			fl6.flowi6_flags |= FLOWI_FLAG_L3MDEV_SRC;
 		dst = icmp6_dst_alloc(skb->dev, &fl6);
 		if (IS_ERR(dst)) {
 			kfree_skb(skb);
@@ -767,7 +771,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 
 	ifp = ipv6_get_ifaddr(dev_net(dev), &msg->target, dev, 1);
 	if (ifp) {
-
+have_ifp:
 		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
 			if (dad) {
 				/*
@@ -793,6 +797,18 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	} else {
 		struct net *net = dev_net(dev);
 
+		/* perhaps an address on the master device */
+		if (netif_is_l3_slave(dev)) {
+			struct net_device *mdev;
+
+			mdev = netdev_master_upper_dev_get_rcu(dev);
+			if (mdev) {
+				ifp = ipv6_get_ifaddr(net, &msg->target, mdev, 1);
+				if (ifp)
+					goto have_ifp;
+			}
+		}
+
 		idev = in6_dev_get(dev);
 		if (!idev) {
 			/* XXX: count this drop? */
@@ -1484,6 +1500,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	struct flowi6 fl6;
 	int rd_len;
 	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
+	int oif = l3mdev_fib_oif(dev);
 	bool ret;
 
 	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
@@ -1500,7 +1517,10 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	}
 
 	icmpv6_flow_init(sk, &fl6, NDISC_REDIRECT,
-			 &saddr_buf, &ipv6_hdr(skb)->saddr, dev->ifindex);
+			 &saddr_buf, &ipv6_hdr(skb)->saddr, oif);
+
+	if (oif != skb->dev->ifindex)
+		fl6.flowi6_flags |= FLOWI_FLAG_L3MDEV_SRC;
 
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst->error) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d3d946773a3e..63446bae7f5f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -61,6 +61,7 @@
 #include <net/nexthop.h>
 #include <net/lwtunnel.h>
 #include <net/ip_tunnels.h>
+#include <net/l3mdev.h>
 
 #include <asm/uaccess.h>
 
@@ -1044,6 +1045,9 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
 	saved_fn = fn;
 
+	if (fl6->flowi6_flags & FLOWI_FLAG_SKIP_NH_OIF)
+		oif = 0;
+
 redo_rt6_select:
 	rt = rt6_select(fn, oif, strict);
 	if (rt->rt6i_nsiblings)
@@ -1141,7 +1145,7 @@ void ip6_route_input(struct sk_buff *skb)
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
 	struct ip_tunnel_info *tun_info;
 	struct flowi6 fl6 = {
-		.flowi6_iif = skb->dev->ifindex,
+		.flowi6_iif = l3mdev_fib_oif(skb->dev),
 		.daddr = iph->daddr,
 		.saddr = iph->saddr,
 		.flowlabel = ip6_flowinfo(iph),
@@ -1165,8 +1169,13 @@ static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table
 struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
 				    struct flowi6 *fl6)
 {
+	struct dst_entry *dst;
 	int flags = 0;
 
+	dst = l3mdev_rt6_dst_by_oif(net, fl6);
+	if (dst)
+		return dst;
+
 	fl6->flowi6_iif = LOOPBACK_IFINDEX;
 
 	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl6->daddr) ||
@@ -2264,7 +2273,6 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 					   unsigned int pref)
 {
 	struct fib6_config cfg = {
-		.fc_table	= RT6_TABLE_INFO,
 		.fc_metric	= IP6_RT_PRIO_USER,
 		.fc_ifindex	= ifindex,
 		.fc_dst_len	= prefixlen,
@@ -2275,6 +2283,7 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 		.fc_nlinfo.nl_net = net,
 	};
 
+	cfg.fc_table = l3mdev_fib_table_by_index(net, ifindex) ? : RT6_TABLE_INFO;
 	cfg.fc_dst = *prefix;
 	cfg.fc_gateway = *gwaddr;
 
@@ -2315,7 +2324,7 @@ struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
 				     unsigned int pref)
 {
 	struct fib6_config cfg = {
-		.fc_table	= RT6_TABLE_DFLT,
+		.fc_table	= l3mdev_fib_table(dev) ? : RT6_TABLE_DFLT,
 		.fc_metric	= IP6_RT_PRIO_USER,
 		.fc_ifindex	= dev->ifindex,
 		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT |
@@ -2362,7 +2371,8 @@ static void rtmsg_to_fib6_config(struct net *net,
 {
 	memset(cfg, 0, sizeof(*cfg));
 
-	cfg->fc_table = RT6_TABLE_MAIN;
+	cfg->fc_table = l3mdev_fib_table_by_index(net, rtmsg->rtmsg_ifindex) ?
+			 : RT6_TABLE_MAIN;
 	cfg->fc_ifindex = rtmsg->rtmsg_ifindex;
 	cfg->fc_metric = rtmsg->rtmsg_metric;
 	cfg->fc_expires = rtmsg->rtmsg_info;
@@ -2471,6 +2481,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    const struct in6_addr *addr,
 				    bool anycast)
 {
+	u32 tb_id;
 	struct net *net = dev_net(idev->dev);
 	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev,
 					    DST_NOCOUNT);
@@ -2493,7 +2504,8 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->rt6i_gateway  = *addr;
 	rt->rt6i_dst.addr = *addr;
 	rt->rt6i_dst.plen = 128;
-	rt->rt6i_table = fib6_get_table(net, RT6_TABLE_LOCAL);
+	tb_id = l3mdev_fib_table(idev->dev) ? : RT6_TABLE_LOCAL;
+	rt->rt6i_table = fib6_get_table(net, tb_id);
 	rt->dst.flags |= DST_NOCACHE;
 
 	atomic_set(&rt->dst.__refcnt, 1);
-- 
1.9.1
