From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/5] [IPv6] route: Simplify ip6_ins_rt()
Date: Thu, 17 Aug 2006 00:00:02 +0200
Message-ID: <20060816234342.775348069@postel.suug.ch>
References: <20060816234038.106537101@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56225 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751258AbWHPXo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 19:44:59 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ip6_ins_rt
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Provide a simple ip6_ins_rt() for the majority of users and
an alternative for the exception via netlink. Avoids code
obfuscation.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/include/net/ip6_route.h
===================================================================
--- net-2.6.19.git.orig/include/net/ip6_route.h
+++ net-2.6.19.git/include/net/ip6_route.h
@@ -65,10 +65,7 @@ extern int			ip6_route_add(struct in6_rt
 					      void *rtattr,
 					      struct netlink_skb_parms *req,
 					      u32 table_id);
-extern int			ip6_ins_rt(struct rt6_info *,
-					   struct nlmsghdr *,
-					   void *rtattr,
-					   struct netlink_skb_parms *req);
+extern int			ip6_ins_rt(struct rt6_info *);
 extern int			ip6_del_rt(struct rt6_info *);
 
 extern int			ip6_rt_addr_add(struct in6_addr *addr,
Index: net-2.6.19.git/net/ipv6/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/route.c
+++ net-2.6.19.git/net/ipv6/route.c
@@ -546,8 +546,8 @@ struct rt6_info *rt6_lookup(struct in6_a
    be destroyed.
  */
 
-int ip6_ins_rt(struct rt6_info *rt, struct nlmsghdr *nlh,
-		void *_rtattr, struct netlink_skb_parms *req)
+static int __ip6_ins_rt(struct rt6_info *rt, struct nlmsghdr *nlh,
+			void *_rtattr, struct netlink_skb_parms *req)
 {
 	int err;
 	struct fib6_table *table;
@@ -560,6 +560,11 @@ int ip6_ins_rt(struct rt6_info *rt, stru
 	return err;
 }
 
+int ip6_ins_rt(struct rt6_info *rt)
+{
+	return __ip6_ins_rt(rt, NULL, NULL, NULL);
+}
+
 static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, struct in6_addr *daddr,
 				      struct in6_addr *saddr)
 {
@@ -657,7 +662,7 @@ restart:
 
 	dst_hold(&rt->u.dst);
 	if (nrt) {
-		err = ip6_ins_rt(nrt, NULL, NULL, NULL);
+		err = ip6_ins_rt(nrt);
 		if (!err)
 			goto out2;
 	}
@@ -752,7 +757,7 @@ restart:
 
 	dst_hold(&rt->u.dst);
 	if (nrt) {
-		err = ip6_ins_rt(nrt, NULL, NULL, NULL);
+		err = ip6_ins_rt(nrt);
 		if (!err)
 			goto out2;
 	}
@@ -1206,7 +1211,7 @@ install_route:
 	rt->u.dst.dev = dev;
 	rt->rt6i_idev = idev;
 	rt->rt6i_table = table;
-	return ip6_ins_rt(rt, nlh, _rtattr, req);
+	return __ip6_ins_rt(rt, nlh, _rtattr, req);
 
 out:
 	if (dev)
@@ -1393,7 +1398,7 @@ restart:
 	nrt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(neigh->dev);
 	nrt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&nrt->u.dst));
 
-	if (ip6_ins_rt(nrt, NULL, NULL, NULL))
+	if (ip6_ins_rt(nrt))
 		goto out;
 
 	netevent.old = &rt->u.dst;
@@ -1483,7 +1488,7 @@ void rt6_pmtu_discovery(struct in6_addr 
 		dst_set_expires(&nrt->u.dst, ip6_rt_mtu_expires);
 		nrt->rt6i_flags |= RTF_DYNAMIC|RTF_EXPIRES;
 
-		ip6_ins_rt(nrt, NULL, NULL, NULL);
+		ip6_ins_rt(nrt);
 	}
 out:
 	dst_release(&rt->u.dst);
Index: net-2.6.19.git/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/addrconf.c
+++ net-2.6.19.git/net/ipv6/addrconf.c
@@ -3548,7 +3548,7 @@ static void __ipv6_ifa_notify(int event,
 
 	switch (event) {
 	case RTM_NEWADDR:
-		ip6_ins_rt(ifp->rt, NULL, NULL, NULL);
+		ip6_ins_rt(ifp->rt);
 		if (ifp->idev->cnf.forwarding)
 			addrconf_join_anycast(ifp);
 		break;
Index: net-2.6.19.git/net/ipv6/anycast.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/anycast.c
+++ net-2.6.19.git/net/ipv6/anycast.c
@@ -335,7 +335,7 @@ int ipv6_dev_ac_inc(struct net_device *d
 	write_unlock_bh(&idev->lock);
 
 	dst_hold(&rt->u.dst);
-	if (ip6_ins_rt(rt, NULL, NULL, NULL))
+	if (ip6_ins_rt(rt))
 		dst_release(&rt->u.dst);
 
 	addrconf_join_solict(dev, &aca->aca_addr);

