From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/7] net: ipv4: refactor ip_route_input_noref
Date: Mon,  9 Jan 2017 13:32:46 -0800
Message-ID: <1483997571-3964-3-git-send-email-dsa@cumulusnetworks.com>
References: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33417 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932800AbdAIVc6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:32:58 -0500
Received: by mail-pf0-f169.google.com with SMTP id y143so13067127pfb.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 13:32:58 -0800 (PST)
In-Reply-To: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A later patch wants access to the fib result on an input route lookup
with the rcu lock held. Refactor ip_route_input_noref pushing the logic
between rcu_read_lock ... rcu_read_unlock into a new helper that takes
the fib_result as an input arg.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/route.h |  3 +++
 net/ipv4/route.c    | 66 ++++++++++++++++++++++++++++++-----------------------
 2 files changed, 40 insertions(+), 29 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index bf4f7a98f753..4f3502a67203 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -178,6 +178,9 @@ static inline struct rtable *ip_route_output_gre(struct net *net, struct flowi4
 
 int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 src,
 			 u8 tos, struct net_device *devin);
+int ip_route_input_rcu(struct sk_buff *skb, __be32 dst, __be32 src,
+		       u8 tos, struct net_device *devin,
+		       struct fib_result *res);
 
 static inline int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
 				 u8 tos, struct net_device *devin)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index effd7f8e31f9..3142cd802e79 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1789,9 +1789,9 @@ static int ip_mkroute_input(struct sk_buff *skb,
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
@@ -1821,8 +1821,8 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr))
 		goto martian_source;
 
-	res.fi = NULL;
-	res.table = NULL;
+	res->fi = NULL;
+	res->table = NULL;
 	if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
 		goto brd_input;
 
@@ -1857,17 +1857,17 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	fl4.flowi4_flags = 0;
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
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
@@ -1879,10 +1879,10 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
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
@@ -1896,14 +1896,14 @@ out:	return err;
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
@@ -1914,7 +1914,7 @@ out:	return err;
 	}
 
 	rth = rt_dst_alloc(l3mdev_master_dev_rcu(dev) ? : net->loopback_dev,
-			   flags | RTCF_LOCAL, res.type,
+			   flags | RTCF_LOCAL, res->type,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
 	if (!rth)
 		goto e_nobufs;
@@ -1924,18 +1924,18 @@ out:	return err;
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
@@ -1955,9 +1955,9 @@ out:	return err;
 
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
@@ -1987,10 +1987,21 @@ out:	return err;
 int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			 u8 tos, struct net_device *dev)
 {
-	int res;
+	struct fib_result res;
+	int err;
 
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
@@ -2005,6 +2016,7 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (ipv4_is_multicast(daddr)) {
 		struct in_device *in_dev = __in_dev_get_rcu(dev);
 		int our = 0;
+		int err = -EINVAL;
 
 		if (in_dev)
 			our = ip_check_mc_rcu(in_dev, daddr, saddr,
@@ -2020,7 +2032,6 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 						      ip_hdr(skb)->protocol);
 		}
 
-		res = -EINVAL;
 		if (our
 #ifdef CONFIG_IP_MROUTE
 			||
@@ -2028,17 +2039,14 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
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
2.1.4
