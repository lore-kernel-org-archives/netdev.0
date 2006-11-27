From: Thomas Graf <tgraf@suug.ch>
Subject: [RTNETLINK]: Add rtnl_put_cacheinfo() to unify some code
Date: Mon, 27 Nov 2006 10:13:20 +0100
Message-ID: <20061127091320.GW8693@postel.suug.ch>
References: <20061127090357.GV8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38359 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1757510AbWK0JNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 04:13:00 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061127090357.GV8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resend: Need to export rtnl_put_cacheinfo() for IPv6

IPv4, IPv6, and DECNet all use struct rta_cacheinfo in a similiar
way, therefore rtnl_put_cacheinfo() is added to reuse code.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/net/core/rtnetlink.c
===================================================================
--- net-2.6.20.orig/net/core/rtnetlink.c	2006-11-25 15:35:26.000000000 +0100
+++ net-2.6.20/net/core/rtnetlink.c	2006-11-27 10:04:27.000000000 +0100
@@ -212,6 +212,26 @@
 	return nla_nest_cancel(skb, mx);
 }
 
+int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
+		       u32 ts, u32 tsage, long expires, u32 error)
+{
+	struct rta_cacheinfo ci = {
+		.rta_lastuse = jiffies_to_clock_t(jiffies - dst->lastuse),
+		.rta_used = dst->__use,
+		.rta_clntref = atomic_read(&(dst->__refcnt)),
+		.rta_error = error,
+		.rta_id =  id,
+		.rta_ts = ts,
+		.rta_tsage = tsage,
+	};
+
+	if (expires)
+		ci.rta_expires = jiffies_to_clock_t(expires);
+
+	return nla_put(skb, RTA_CACHEINFO, sizeof(ci), &ci);
+}
+
+EXPORT_SYMBOL_GPL(rtnl_put_cacheinfo);
 
 static void set_operstate(struct net_device *dev, unsigned char transition)
 {
Index: net-2.6.20/include/linux/rtnetlink.h
===================================================================
--- net-2.6.20.orig/include/linux/rtnetlink.h	2006-11-25 15:35:26.000000000 +0100
+++ net-2.6.20/include/linux/rtnetlink.h	2006-11-25 16:09:50.000000000 +0100
@@ -585,6 +585,9 @@
 		       struct nlmsghdr *nlh, gfp_t flags);
 extern void rtnl_set_sk_err(u32 group, int error);
 extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
+extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
+			      u32 id, u32 ts, u32 tsage, long expires,
+			      u32 error);
 
 extern void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data);
 
Index: net-2.6.20/net/ipv4/route.c
===================================================================
--- net-2.6.20.orig/net/ipv4/route.c	2006-11-25 15:35:26.000000000 +0100
+++ net-2.6.20/net/ipv4/route.c	2006-11-25 16:09:50.000000000 +0100
@@ -2629,7 +2629,8 @@
 	struct rtable *rt = (struct rtable*)skb->dst;
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
-	struct rta_cacheinfo ci;
+	long expires;
+	u32 id = 0, ts = 0, tsage = 0, error;
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
 	if (nlh == NULL)
@@ -2676,20 +2677,13 @@
 	if (rtnetlink_put_metrics(skb, rt->u.dst.metrics) < 0)
 		goto nla_put_failure;
 
-	ci.rta_lastuse	= jiffies_to_clock_t(jiffies - rt->u.dst.lastuse);
-	ci.rta_used	= rt->u.dst.__use;
-	ci.rta_clntref	= atomic_read(&rt->u.dst.__refcnt);
-	if (rt->u.dst.expires)
-		ci.rta_expires = jiffies_to_clock_t(rt->u.dst.expires - jiffies);
-	else
-		ci.rta_expires = 0;
-	ci.rta_error	= rt->u.dst.error;
-	ci.rta_id	= ci.rta_ts = ci.rta_tsage = 0;
+	error = rt->u.dst.error;
+	expires = rt->u.dst.expires ? rt->u.dst.expires - jiffies : 0;
 	if (rt->peer) {
-		ci.rta_id = rt->peer->ip_id_count;
+		id = rt->peer->ip_id_count;
 		if (rt->peer->tcp_ts_stamp) {
-			ci.rta_ts = rt->peer->tcp_ts;
-			ci.rta_tsage = xtime.tv_sec - rt->peer->tcp_ts_stamp;
+			ts = rt->peer->tcp_ts;
+			tsage = xtime.tv_sec - rt->peer->tcp_ts_stamp;
 		}
 	}
 
@@ -2708,7 +2702,7 @@
 				} else {
 					if (err == -EMSGSIZE)
 						goto nla_put_failure;
-					ci.rta_error = err;
+					error = err;
 				}
 			}
 		} else
@@ -2716,7 +2710,9 @@
 			NLA_PUT_U32(skb, RTA_IIF, rt->fl.iif);
 	}
 
-	NLA_PUT(skb, RTA_CACHEINFO, sizeof(ci), &ci);
+	if (rtnl_put_cacheinfo(skb, &rt->u.dst, id, ts, tsage,
+			       expires, error) < 0)
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
Index: net-2.6.20/net/ipv6/route.c
===================================================================
--- net-2.6.20.orig/net/ipv6/route.c	2006-11-25 15:35:26.000000000 +0100
+++ net-2.6.20/net/ipv6/route.c	2006-11-26 14:58:57.000000000 +0100
@@ -2026,7 +2026,7 @@
 {
 	struct rtmsg *rtm;
 	struct nlmsghdr *nlh;
-	struct rta_cacheinfo ci;
+	long expires;
 	u32 table;
 
 	if (prefix) {	/* user wants prefix routes only */
@@ -2100,18 +2100,11 @@
 		NLA_PUT_U32(skb, RTA_OIF, rt->rt6i_dev->ifindex);
 
 	NLA_PUT_U32(skb, RTA_PRIORITY, rt->rt6i_metric);
-	ci.rta_lastuse = jiffies_to_clock_t(jiffies - rt->u.dst.lastuse);
-	if (rt->rt6i_expires)
-		ci.rta_expires = jiffies_to_clock_t(rt->rt6i_expires - jiffies);
-	else
-		ci.rta_expires = 0;
-	ci.rta_used = rt->u.dst.__use;
-	ci.rta_clntref = atomic_read(&rt->u.dst.__refcnt);
-	ci.rta_error = rt->u.dst.error;
-	ci.rta_id = 0;
-	ci.rta_ts = 0;
-	ci.rta_tsage = 0;
-	NLA_PUT(skb, RTA_CACHEINFO, sizeof(ci), &ci);
+
+	expires = rt->rt6i_expires ? rt->rt6i_expires - jiffies : 0;
+	if (rtnl_put_cacheinfo(skb, &rt->u.dst, 0, 0, 0,
+			       expires, rt->u.dst.error) < 0)
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
Index: net-2.6.20/net/decnet/dn_route.c
===================================================================
--- net-2.6.20.orig/net/decnet/dn_route.c	2006-11-25 15:59:14.000000000 +0100
+++ net-2.6.20/net/decnet/dn_route.c	2006-11-27 09:56:35.000000000 +0100
@@ -1469,7 +1469,7 @@
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb->tail;
-	struct rta_cacheinfo ci;
+	long expires;
 
 	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*r), flags);
 	r = NLMSG_DATA(nlh);
@@ -1502,16 +1502,10 @@
 		RTA_PUT(skb, RTA_GATEWAY, 2, &rt->rt_gateway);
 	if (rtnetlink_put_metrics(skb, rt->u.dst.metrics) < 0)
 		goto rtattr_failure;
-	ci.rta_lastuse = jiffies_to_clock_t(jiffies - rt->u.dst.lastuse);
-	ci.rta_used     = rt->u.dst.__use;
-	ci.rta_clntref  = atomic_read(&rt->u.dst.__refcnt);
-	if (rt->u.dst.expires)
-		ci.rta_expires = jiffies_to_clock_t(rt->u.dst.expires - jiffies);
-	else
-		ci.rta_expires = 0;
-	ci.rta_error    = rt->u.dst.error;
-	ci.rta_id       = ci.rta_ts = ci.rta_tsage = 0;
-	RTA_PUT(skb, RTA_CACHEINFO, sizeof(ci), &ci);
+	expires = rt->u.dst.expires ? rt->u.dst.expires - jiffies : 0;
+	if (rtnl_put_cacheinfo(skb, &rt->u.dst, 0, 0, 0, expires,
+			       rt->u.dst.error) < 0)
+		goto rtattr_failure;
 	if (rt->fl.iif)
 		RTA_PUT(skb, RTA_IIF, sizeof(int), &rt->fl.iif);
 
