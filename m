From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/5] [IPv6] route: Simplify ip6_del_rt()
Date: Thu, 17 Aug 2006 00:00:01 +0200
Message-ID: <20060816234342.443503114@postel.suug.ch>
References: <20060816234038.106537101@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:54689 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751256AbWHPXoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 19:44:54 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ip6_del_rt
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Provide a simple ip6_del_rt() for the majority of users and
an alternative for the exception via netlink. Avoids code
obfuscation.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/include/net/ip6_route.h
===================================================================
--- net-2.6.19.git.orig/include/net/ip6_route.h
+++ net-2.6.19.git/include/net/ip6_route.h
@@ -69,10 +69,7 @@ extern int			ip6_ins_rt(struct rt6_info 
 					   struct nlmsghdr *,
 					   void *rtattr,
 					   struct netlink_skb_parms *req);
-extern int			ip6_del_rt(struct rt6_info *,
-					   struct nlmsghdr *,
-					   void *rtattr,
-					   struct netlink_skb_parms *req);
+extern int			ip6_del_rt(struct rt6_info *);
 
 extern int			ip6_rt_addr_add(struct in6_addr *addr,
 						struct net_device *dev,
Index: net-2.6.19.git/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/addrconf.c
+++ net-2.6.19.git/net/ipv6/addrconf.c
@@ -736,7 +736,7 @@ static void ipv6_del_addr(struct inet6_i
 
 		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
 			if (onlink == 0) {
-				ip6_del_rt(rt, NULL, NULL, NULL);
+				ip6_del_rt(rt);
 				rt = NULL;
 			} else if (!(rt->rt6i_flags & RTF_EXPIRES)) {
 				rt->rt6i_expires = expires;
@@ -1662,7 +1662,7 @@ void addrconf_prefix_rcv(struct net_devi
 		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
 			if (rt->rt6i_flags&RTF_EXPIRES) {
 				if (valid_lft == 0) {
-					ip6_del_rt(rt, NULL, NULL, NULL);
+					ip6_del_rt(rt);
 					rt = NULL;
 				} else {
 					rt->rt6i_expires = jiffies + rt_expires;
@@ -3557,7 +3557,7 @@ static void __ipv6_ifa_notify(int event,
 			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
 		dst_hold(&ifp->rt->u.dst);
-		if (ip6_del_rt(ifp->rt, NULL, NULL, NULL))
+		if (ip6_del_rt(ifp->rt))
 			dst_free(&ifp->rt->u.dst);
 		break;
 	}
Index: net-2.6.19.git/net/ipv6/ndisc.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/ndisc.c
+++ net-2.6.19.git/net/ipv6/ndisc.c
@@ -961,7 +961,7 @@ static void ndisc_recv_na(struct sk_buff
 			struct rt6_info *rt;
 			rt = rt6_get_dflt_router(saddr, dev);
 			if (rt)
-				ip6_del_rt(rt, NULL, NULL, NULL);
+				ip6_del_rt(rt);
 		}
 
 out:
@@ -1114,7 +1114,7 @@ static void ndisc_router_discovery(struc
 
 	if (rt && lifetime == 0) {
 		neigh_clone(neigh);
-		ip6_del_rt(rt, NULL, NULL, NULL);
+		ip6_del_rt(rt);
 		rt = NULL;
 	}
 
Index: net-2.6.19.git/net/ipv6/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/route.c
+++ net-2.6.19.git/net/ipv6/route.c
@@ -457,7 +457,7 @@ int rt6_route_rcv(struct net_device *dev
 	rt = rt6_get_route_info(prefix, rinfo->prefix_len, gwaddr, dev->ifindex);
 
 	if (rt && !lifetime) {
-		ip6_del_rt(rt, NULL, NULL, NULL);
+		ip6_del_rt(rt);
 		rt = NULL;
 	}
 
@@ -813,7 +813,7 @@ static struct dst_entry *ip6_negative_ad
 
 	if (rt) {
 		if (rt->rt6i_flags & RTF_CACHE)
-			ip6_del_rt(rt, NULL, NULL, NULL);
+			ip6_del_rt(rt);
 		else
 			dst_release(dst);
 	}
@@ -1218,7 +1218,8 @@ out:
 	return err;
 }
 
-int ip6_del_rt(struct rt6_info *rt, struct nlmsghdr *nlh, void *_rtattr, struct netlink_skb_parms *req)
+static int __ip6_del_rt(struct rt6_info *rt, struct nlmsghdr *nlh,
+			void *_rtattr, struct netlink_skb_parms *req)
 {
 	int err;
 	struct fib6_table *table;
@@ -1237,6 +1238,11 @@ int ip6_del_rt(struct rt6_info *rt, stru
 	return err;
 }
 
+int ip6_del_rt(struct rt6_info *rt)
+{
+	return __ip6_del_rt(rt, NULL, NULL, NULL);
+}
+
 static int ip6_route_del(struct in6_rtmsg *rtmsg, struct nlmsghdr *nlh,
 			 void *_rtattr, struct netlink_skb_parms *req,
 			 u32 table_id)
@@ -1271,7 +1277,7 @@ static int ip6_route_del(struct in6_rtms
 			dst_hold(&rt->u.dst);
 			read_unlock_bh(&table->tb6_lock);
 
-			return ip6_del_rt(rt, nlh, _rtattr, req);
+			return __ip6_del_rt(rt, nlh, _rtattr, req);
 		}
 	}
 	read_unlock_bh(&table->tb6_lock);
@@ -1395,7 +1401,7 @@ restart:
 	call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
 
 	if (rt->rt6i_flags&RTF_CACHE) {
-		ip6_del_rt(rt, NULL, NULL, NULL);
+		ip6_del_rt(rt);
 		return;
 	}
 
@@ -1631,7 +1637,7 @@ restart:
 		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) {
 			dst_hold(&rt->u.dst);
 			read_unlock_bh(&table->tb6_lock);
-			ip6_del_rt(rt, NULL, NULL, NULL);
+			ip6_del_rt(rt);
 			goto restart;
 		}
 	}

