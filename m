From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 06/12] net: remove redundant l3mdev calls
Date: Tue, 30 Aug 2016 10:34:11 -0700
Message-ID: <1472578457-26722-7-git-send-email-dsa@cumulusnetworks.com>
References: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36178 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932964AbcH3Rek (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 13:34:40 -0400
Received: by mail-pa0-f42.google.com with SMTP id fu3so1753815pad.3
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 10:34:35 -0700 (PDT)
In-Reply-To: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A previous patch added l3mdev flow update making these hooks redundant.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/ip_output.c    |  3 +--
 net/ipv4/route.c        | 12 ++----------
 net/ipv4/xfrm4_policy.c |  2 +-
 net/ipv6/ip6_output.c   |  2 --
 net/ipv6/ndisc.c        | 11 ++---------
 net/ipv6/route.c        |  7 +------
 net/ipv6/tcp_ipv6.c     |  8 ++------
 net/ipv6/xfrm6_policy.c |  2 +-
 8 files changed, 10 insertions(+), 37 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3c727d4eaba9..75f8167615ba 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1574,8 +1574,7 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 	}
 
 	oif = arg->bound_dev_if;
-	if (!oif && netif_index_is_l3_master(net, skb->skb_iif))
-		oif = skb->skb_iif;
+	oif = oif ? : skb->skb_iif;
 
 	flowi4_init_output(&fl4, oif,
 			   IP4_REPLY_MARK(net, skb->mark),
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d9936f90a755..ec994380d354 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1829,7 +1829,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	 *	Now we are ready to route packet.
 	 */
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = l3mdev_fib_oif_rcu(dev);
+	fl4.flowi4_iif = dev->ifindex;
 	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
@@ -2148,7 +2148,6 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 	unsigned int flags = 0;
 	struct fib_result res;
 	struct rtable *rth;
-	int master_idx;
 	int orig_oif;
 	int err = -ENETUNREACH;
 
@@ -2158,9 +2157,6 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 
 	orig_oif = fl4->flowi4_oif;
 
-	master_idx = l3mdev_master_ifindex_by_index(net, fl4->flowi4_oif);
-	if (master_idx)
-		fl4->flowi4_oif = master_idx;
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
 	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
 	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
@@ -2261,8 +2257,7 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 	if (err) {
 		res.fi = NULL;
 		res.table = NULL;
-		if (fl4->flowi4_oif &&
-		    !netif_index_is_l3_master(net, fl4->flowi4_oif)) {
+		if (fl4->flowi4_oif) {
 			/* Apparently, routing tables are wrong. Assume,
 			   that the destination is on link.
 
@@ -2575,9 +2570,6 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	fl4.flowi4_oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0;
 	fl4.flowi4_mark = mark;
 
-	if (netif_index_is_l3_master(net, fl4.flowi4_oif))
-		fl4.flowi4_flags = FLOWI_FLAG_L3MDEV_SRC | FLOWI_FLAG_SKIP_NH_OIF;
-
 	if (iif) {
 		struct net_device *dev;
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index b644a23c3db0..3155ed73d3b3 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -112,7 +112,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 	int oif = 0;
 
 	if (skb_dst(skb))
-		oif = l3mdev_fib_oif(skb_dst(skb)->dev);
+		oif = skb_dst(skb)->dev->ifindex;
 
 	memset(fl4, 0, sizeof(struct flowi4));
 	fl4->flowi4_mark = skb->mark;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9711f32eedd7..84d1b3feaf2e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1067,8 +1067,6 @@ struct dst_entry *ip6_dst_lookup_flow(const struct sock *sk, struct flowi6 *fl6,
 		return ERR_PTR(err);
 	if (final_dst)
 		fl6->daddr = *final_dst;
-	if (!fl6->flowi6_oif)
-		fl6->flowi6_oif = l3mdev_fib_oif(dst->dev);
 
 	return xfrm_lookup_route(net, dst, flowi6_to_flowi(fl6), sk, 0);
 }
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index fe65cdc28a45..d8e671457d10 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -67,7 +67,6 @@
 #include <net/flow.h>
 #include <net/ip6_checksum.h>
 #include <net/inet_common.h>
-#include <net/l3mdev.h>
 #include <linux/proc_fs.h>
 
 #include <linux/netfilter.h>
@@ -457,11 +456,9 @@ static void ndisc_send_skb(struct sk_buff *skb,
 
 	if (!dst) {
 		struct flowi6 fl6;
-		int oif = l3mdev_fib_oif(skb->dev);
+		int oif = skb->dev->ifindex;
 
 		icmpv6_flow_init(sk, &fl6, type, saddr, daddr, oif);
-		if (oif != skb->dev->ifindex)
-			fl6.flowi6_flags |= FLOWI_FLAG_L3MDEV_SRC;
 		dst = icmp6_dst_alloc(skb->dev, &fl6);
 		if (IS_ERR(dst)) {
 			kfree_skb(skb);
@@ -1538,7 +1535,6 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	int rd_len;
 	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL,
 	   ops_data_buf[NDISC_OPS_REDIRECT_DATA_SPACE], *ops_data = NULL;
-	int oif = l3mdev_fib_oif(dev);
 	bool ret;
 
 	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
@@ -1555,10 +1551,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	}
 
 	icmpv6_flow_init(sk, &fl6, NDISC_REDIRECT,
-			 &saddr_buf, &ipv6_hdr(skb)->saddr, oif);
-
-	if (oif != skb->dev->ifindex)
-		fl6.flowi6_flags |= FLOWI_FLAG_L3MDEV_SRC;
+			 &saddr_buf, &ipv6_hdr(skb)->saddr, dev->ifindex);
 
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst->error) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 65ee42ad2afd..f21d85cc2e77 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1164,7 +1164,7 @@ void ip6_route_input(struct sk_buff *skb)
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
 	struct ip_tunnel_info *tun_info;
 	struct flowi6 fl6 = {
-		.flowi6_iif = l3mdev_fib_oif(skb->dev),
+		.flowi6_iif = skb->dev->ifindex,
 		.daddr = iph->daddr,
 		.saddr = iph->saddr,
 		.flowlabel = ip6_flowinfo(iph),
@@ -3339,11 +3339,6 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	} else {
 		fl6.flowi6_oif = oif;
 
-		if (netif_index_is_l3_master(net, oif)) {
-			fl6.flowi6_flags = FLOWI_FLAG_L3MDEV_SRC |
-					   FLOWI_FLAG_SKIP_NH_OIF;
-		}
-
 		rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
 	}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 04529a3d42cb..54cf7197c7ab 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -818,12 +818,8 @@ static void tcp_v6_send_response(const struct sock *sk, struct sk_buff *skb, u32
 	fl6.flowi6_proto = IPPROTO_TCP;
 	if (rt6_need_strict(&fl6.daddr) && !oif)
 		fl6.flowi6_oif = tcp_v6_iif(skb);
-	else {
-		if (!oif && netif_index_is_l3_master(net, skb->skb_iif))
-			oif = skb->skb_iif;
-
-		fl6.flowi6_oif = oif;
-	}
+	else
+		fl6.flowi6_oif = oif ? : skb->skb_iif;
 
 	fl6.flowi6_mark = IP6_REPLY_MARK(net, skb->mark);
 	fl6.fl6_dport = t1->dest;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 6cc97003e4a9..b7b7e863a2bb 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -134,7 +134,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	nexthdr = nh[nhoff];
 
 	if (skb_dst(skb))
-		oif = l3mdev_fib_oif(skb_dst(skb)->dev);
+		oif = skb_dst(skb)->dev->ifindex;
 
 	memset(fl6, 0, sizeof(struct flowi6));
 	fl6->flowi6_mark = skb->mark;
-- 
2.1.4
