From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 2/8] net: ipv4: refactor ip_route_input_noref
Date: Wed, 24 May 2017 11:19:05 -0700
Message-ID: <1495649951-30417-3-git-send-email-roopa@cumulusnetworks.com>
References: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36181 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933780AbdEXSTS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 14:19:18 -0400
Received: by mail-pf0-f177.google.com with SMTP id m17so143161769pfg.3
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 11:19:18 -0700 (PDT)
In-Reply-To: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>

A later patch wants access to the fib result on an input route lookup
with the rcu lock held. Refactor ip_route_input_noref pushing the logic
between rcu_read_lock ... rcu_read_unlock into a new helper that takes
the fib_result as an input arg.

Signed-off-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/route.h |  3 +++
 net/ipv4/route.c    | 66 ++++++++++++++++++++++++++++++-----------------------
 2 files changed, 40 insertions(+), 29 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 5a92347..8d209ad 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -180,6 +180,9 @@ static inline struct rtable *ip_route_output_gre(struct net *net, struct flowi4
 
 int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 src,
 			 u8 tos, struct net_device *devin);
+int ip_route_input_rcu(struct sk_buff *skb, __be32 dst, __be32 src,
+		       u8 tos, struct net_device *devin,
+		       struct fib_result *res);
 
 static inline int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
 				 u8 tos, struct net_device *devin)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f787208..fe7b765 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1852,9 +1852,9 @@ static int ip_mkroute_input(struct sk_buff *skb,
  */
 
 static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-			       u8 tos, struct net_device *dev)
+			       u8 tos, struct net_device *dev,
+			       struct fib_result *res)
 {
-	struct fib_result res;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
 	struct ip_tunnel_info *tun_info;
 	struct flowi4	fl4;
@@ -1884,8 +1884,8 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr))
 		goto martian_source;
 
-	res.fi = NULL;
-	res.table = NULL;
+	res->fi = NULL;
+	res->table = NULL;
 	if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
 		goto brd_input;
 
@@ -1921,17 +1921,17 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
 	fl4.flowi4_uid = sock_net_uid(net, NULL);
-	err = fib_lookup(net, &fl4, &res, 0);
+	err = fib_lookup(net, &fl4, res, 0);
 	if (err != 0) {
 		if (!IN_DEV_FORWARD(in_dev))
 			err = -EHOSTUNREACH;
 		goto no_route;
 	}
 
-	if (res.type == RTN_BROADCAST)
+	if (res->type == RTN_BROADCAST)
 		goto brd_input;
 
-	if (res.type == RTN_LOCAL) {
+	if (res->type == RTN_LOCAL) {
 		err = fib_validate_source(skb, saddr, daddr, tos,
 					  0, dev, in_dev, &itag);
 		if (err < 0)
@@ -1943,10 +1943,10 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		err = -EHOSTUNREACH;
 		goto no_route;
 	}
-	if (res.type != RTN_UNICAST)
+	if (res->type != RTN_UNICAST)
 		goto martian_destination;
 
-	err = ip_mkroute_input(skb, &res, in_dev, daddr, saddr, tos);
+	err = ip_mkroute_input(skb, res, in_dev, daddr, saddr, tos);
 out:	return err;
 
 brd_input:
@@ -1960,14 +1960,14 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			goto martian_source;
 	}
 	flags |= RTCF_BROADCAST;
-	res.type = RTN_BROADCAST;
+	res->type = RTN_BROADCAST;
 	RT_CACHE_STAT_INC(in_brd);
 
 local_input:
 	do_cache = false;
-	if (res.fi) {
+	if (res->fi) {
 		if (!itag) {
-			rth = rcu_dereference(FIB_RES_NH(res).nh_rth_input);
+			rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_input);
 			if (rt_cache_valid(rth)) {
 				skb_dst_set_noref(skb, &rth->dst);
 				err = 0;
@@ -1978,7 +1978,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	}
 
 	rth = rt_dst_alloc(l3mdev_master_dev_rcu(dev) ? : net->loopback_dev,
-			   flags | RTCF_LOCAL, res.type,
+			   flags | RTCF_LOCAL, res->type,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
 	if (!rth)
 		goto e_nobufs;
@@ -1988,18 +1988,18 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->dst.tclassid = itag;
 #endif
 	rth->rt_is_input = 1;
-	if (res.table)
-		rth->rt_table_id = res.table->tb_id;
+	if (res->table)
+		rth->rt_table_id = res->table->tb_id;
 
 	RT_CACHE_STAT_INC(in_slow_tot);
-	if (res.type == RTN_UNREACHABLE) {
+	if (res->type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
 		rth->dst.error= -err;
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
 
 	if (do_cache) {
-		struct fib_nh *nh = &FIB_RES_NH(res);
+		struct fib_nh *nh = &FIB_RES_NH(*res);
 
 		rth->dst.lwtstate = lwtstate_get(nh->nh_lwtstate);
 		if (lwtunnel_input_redirect(rth->dst.lwtstate)) {
@@ -2019,9 +2019,9 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 no_route:
 	RT_CACHE_STAT_INC(in_no_route);
-	res.type = RTN_UNREACHABLE;
-	res.fi = NULL;
-	res.table = NULL;
+	res->type = RTN_UNREACHABLE;
+	res->fi = NULL;
+	res->table = NULL;
 	goto local_input;
 
 	/*
@@ -2051,11 +2051,22 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			 u8 tos, struct net_device *dev)
 {
-	int res;
+	struct fib_result res;
+	int err;
 
 	tos &= IPTOS_RT_MASK;
 	rcu_read_lock();
+	err = ip_route_input_rcu(skb, daddr, saddr, tos, dev, &res);
+	rcu_read_unlock();
 
+	return err;
+}
+EXPORT_SYMBOL(ip_route_input_noref);
+
+/* called with rcu_read_lock held */
+int ip_route_input_rcu(struct sk_buff *skb, __be32 daddr, __be32 saddr,
+		       u8 tos, struct net_device *dev, struct fib_result *res)
+{
 	/* Multicast recognition logic is moved from route cache to here.
 	   The problem was that too many Ethernet cards have broken/missing
 	   hardware multicast filters :-( As result the host on multicasting
@@ -2070,6 +2081,7 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (ipv4_is_multicast(daddr)) {
 		struct in_device *in_dev = __in_dev_get_rcu(dev);
 		int our = 0;
+		int err = -EINVAL;
 
 		if (in_dev)
 			our = ip_check_mc_rcu(in_dev, daddr, saddr,
@@ -2085,7 +2097,6 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 						      ip_hdr(skb)->protocol);
 		}
 
-		res = -EINVAL;
 		if (our
 #ifdef CONFIG_IP_MROUTE
 			||
@@ -2093,17 +2104,14 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		     IN_DEV_MFORWARD(in_dev))
 #endif
 		   ) {
-			res = ip_route_input_mc(skb, daddr, saddr,
+			err = ip_route_input_mc(skb, daddr, saddr,
 						tos, dev, our);
 		}
-		rcu_read_unlock();
-		return res;
+		return err;
 	}
-	res = ip_route_input_slow(skb, daddr, saddr, tos, dev);
-	rcu_read_unlock();
-	return res;
+
+	return ip_route_input_slow(skb, daddr, saddr, tos, dev, res);
 }
-EXPORT_SYMBOL(ip_route_input_noref);
 
 /* called with rcu_read_lock() */
 static struct rtable *__mkroute_output(const struct fib_result *res,
-- 
1.9.1
