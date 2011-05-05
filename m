From: David Miller <davem@davemloft.net>
Subject: [PATCH v6 BONUS 4/3] ipv4: Store rtable entries directly in FIB
Date: Thu, 05 May 2011 16:36:14 -0700 (PDT)
Message-ID: <20110505.163614.212671515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jpirko@redhat.com, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47515
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754252Ab1EEXgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 19:36:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, here is the fun patch showing the scheme I'm working on.  Two
things going on here.

First, we store pre-constructed rtable entries, on demand, inside of
the routing table objects themselves.

Second, we get rid of RT_TABLE_LOCAL and load all routes equally
into RT_TABLE_MAIN.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 10422ef..f3c9598 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -44,6 +44,7 @@ struct fib_config {
  };
 
 struct fib_info;
+struct rtable;
 
 struct fib_nh {
 	struct net_device	*nh_dev;
@@ -62,6 +63,7 @@ struct fib_nh {
 	__be32			nh_gw;
 	__be32			nh_saddr;
 	int			nh_saddr_genid;
+	struct rtable		*nh_rtable;
 };
 
 /*
@@ -200,10 +202,6 @@ static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
 {
 	struct fib_table *table;
 
-	table = fib_get_table(net, RT_TABLE_LOCAL);
-	if (!fib_table_lookup(table, flp, res, FIB_LOOKUP_NOREF))
-		return 0;
-
 	table = fib_get_table(net, RT_TABLE_MAIN);
 	if (!fib_table_lookup(table, flp, res, FIB_LOOKUP_NOREF))
 		return 0;
diff --git a/include/net/route.h b/include/net/route.h
index 70155fb..04e7197 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -109,6 +109,7 @@ extern int		ip_rt_init(void);
 extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
 				       __be32 src, struct net_device *dev);
 extern void		rt_cache_flush(struct net *net, int how);
+extern struct rtable *ip_route_output_new(struct net *, struct flowi4 *flp);
 extern struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp);
 extern struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
 					   struct sock *sk);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 33bbbda..24e67d8 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -155,7 +155,7 @@ static inline unsigned __inet_dev_addr_type(struct net *net,
 	res.r = NULL;
 #endif
 
-	local_table = fib_get_table(net, RT_TABLE_LOCAL);
+	local_table = fib_get_table(net, RT_TABLE_MAIN);
 	if (local_table) {
 		ret = RTN_UNICAST;
 		rcu_read_lock();
@@ -662,11 +662,7 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 		},
 	};
 
-	if (type == RTN_UNICAST)
-		tb = fib_new_table(net, RT_TABLE_MAIN);
-	else
-		tb = fib_new_table(net, RT_TABLE_LOCAL);
-
+	tb = fib_new_table(net, RT_TABLE_MAIN);
 	if (tb == NULL)
 		return;
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 641a5a2..c37ebd3 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -148,6 +148,10 @@ static void free_fib_info_rcu(struct rcu_head *head)
 {
 	struct fib_info *fi = container_of(head, struct fib_info, rcu);
 
+	change_nexthops(fi) {
+		ip_rt_put(nexthop_nh->nh_rtable);
+		nexthop_nh->nh_rtable = NULL;
+	} endfor_nexthops(fi);
 	if (fi->fib_metrics != (u32 *) dst_default_metrics)
 		kfree(fi->fib_metrics);
 	kfree(fi);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1e67624..2f77d28 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1861,6 +1861,68 @@ out:
 }
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
 
+struct rtable *ip_route_output_new(struct net *net, struct flowi4 *fl4)
+{
+	struct net_device *dev_out = NULL;
+	u32 tos	= RT_FL_TOS(fl4);
+	unsigned int flags = 0;
+	struct fib_result res;
+	struct rtable *rth;
+	int orig_oif;
+
+	res.fi = NULL;
+#ifdef CONFIG_IP_MULTIPLE_TABLES
+	res.r = NULL;
+#endif
+
+	orig_oif = fl4->flowi4_oif;
+
+	fl4->flowi4_iif = net->loopback_dev->ifindex;
+	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
+	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
+			 RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
+
+	rcu_read_lock();
+	if (fib_lookup(net, fl4, &res)) {
+		rth = ERR_PTR(-ENETUNREACH);
+		goto out;
+	}
+
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif == 0)
+		fib_select_multipath(&res);
+	else
+#endif
+	if (!res.prefixlen && res.table->tb_num_default > 1 &&
+	    res.type == RTN_UNICAST && !fl4->flowi4_oif)
+		fib_select_default(&res);
+
+	if (!fl4->saddr)
+		fl4->saddr = FIB_RES_PREFSRC(net, res);
+
+	dev_out = FIB_RES_DEV(res);
+	fl4->flowi4_oif = dev_out->ifindex;
+
+	rth = FIB_RES_NH(res).nh_rtable;
+	if (!rth) {
+		if (res.type == RTN_LOCAL)
+			flags |= RTCF_LOCAL;
+		rth = __mkroute_output(&res, fl4, orig_oif, dev_out, flags);
+		if (!IS_ERR(rth))
+			rth = rt_finalize(rth, NULL);
+		if (!IS_ERR(rth))
+			FIB_RES_NH(res).nh_rtable = rth;
+	}
+
+	if (!IS_ERR(rth))
+		atomic_inc(&rth->dst.__refcnt);
+
+out:
+	rcu_read_unlock();
+	return rth;
+}
+EXPORT_SYMBOL_GPL(ip_route_output_new);
+
 static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *dst, u32 cookie)
 {
 	return NULL;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 544f435..9bb827e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -929,7 +929,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				   faddr, saddr, dport, inet->inet_sport);
 
 		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
-		rt = ip_route_output_flow(net, &fl4, sk);
+		rt = ip_route_output_new(net, &fl4);
 		if (IS_ERR(rt)) {
 			err = PTR_ERR(rt);
 			rt = NULL;
