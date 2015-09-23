From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 4/9] net: Move rth handling from ip_route_input_slow to helper
Date: Wed, 23 Sep 2015 08:15:17 -0700
Message-ID: <1443021322-48621-5-git-send-email-dsa@cumulusnetworks.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35780 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249AbbIWPPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:15:40 -0400
Received: by pacfv12 with SMTP id fv12so43766495pac.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:15:40 -0700 (PDT)
In-Reply-To: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the rth lookup and allocation from ip_route_input_slow into a
helper function. Code move only; no operational change intended.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 102 +++++++++++++++++++++++++++++++------------------------
 1 file changed, 58 insertions(+), 44 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e3b18cc1952f..35a19d15232a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1667,6 +1667,62 @@ static int ip_mkroute_input(struct sk_buff *skb,
 	return __mkroute_input(skb, res, in_dev, daddr, saddr, tos);
 }
 
+static int ip_route_local_input(struct sk_buff *skb,
+				struct fib_result *res,
+				struct net *net,
+				struct in_device *in_dev,
+				unsigned int flags,
+				u32 itag,
+				int rth_err)
+{
+	bool do_cache = false;
+	struct rtable *rth;
+	int err = 0;
+
+	if (res->fi) {
+		if (!itag) {
+			rth = rcu_dereference(FIB_RES_NH(*res).nh_rth_input);
+			if (rt_cache_valid(rth)) {
+				skb_dst_set_noref(skb, &rth->dst);
+				goto out;
+			}
+			do_cache = true;
+		}
+	}
+
+	rth = rt_dst_alloc(net->loopback_dev, flags | RTCF_LOCAL, res->type,
+			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
+	err = -ENOBUFS;
+	if (!rth)
+		goto out;
+
+	err = 0;
+	rth->dst.output = ip_rt_bug;
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	rth->dst.tclassid = itag;
+#endif
+	rth->rt_is_input = 1;
+	if (res->table)
+		rth->rt_table_id = res->table->tb_id;
+
+	RT_CACHE_STAT_INC(in_slow_tot);
+	if (res->type == RTN_UNREACHABLE) {
+		rth->dst.input = ip_error;
+		rth->dst.error = -rth_err;
+		rth->rt_flags &= ~RTCF_LOCAL;
+	}
+
+	if (do_cache) {
+		if (unlikely(!rt_cache_route(&FIB_RES_NH(*res), rth))) {
+			rth->dst.flags |= DST_NOCACHE;
+			rt_add_uncached_list(rth);
+		}
+	}
+	skb_dst_set(skb, &rth->dst);
+out:
+	return err;
+}
+
 /*
  *	NOTE. We drop all the packets that has local source
  *	addresses, because every properly looped back packet
@@ -1687,10 +1743,8 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	struct flowi4	fl4;
 	unsigned int	flags = 0;
 	u32		itag = 0;
-	struct rtable	*rth;
 	int		err = -EINVAL;
 	struct net    *net = dev_net(dev);
-	bool do_cache;
 
 	/* IP on this device is disabled. */
 
@@ -1790,48 +1844,8 @@ out:	return err;
 	RT_CACHE_STAT_INC(in_brd);
 
 local_input:
-	do_cache = false;
-	if (res.fi) {
-		if (!itag) {
-			rth = rcu_dereference(FIB_RES_NH(res).nh_rth_input);
-			if (rt_cache_valid(rth)) {
-				skb_dst_set_noref(skb, &rth->dst);
-				err = 0;
-				goto out;
-			}
-			do_cache = true;
-		}
-	}
-
-	rth = rt_dst_alloc(net->loopback_dev, flags | RTCF_LOCAL, res.type,
-			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
-	if (!rth) {
-		err = -ENOBUFS;
-		goto out;
-	}
-
-	rth->dst.output= ip_rt_bug;
-#ifdef CONFIG_IP_ROUTE_CLASSID
-	rth->dst.tclassid = itag;
-#endif
-	rth->rt_is_input = 1;
-	if (res.table)
-		rth->rt_table_id = res.table->tb_id;
-
-	RT_CACHE_STAT_INC(in_slow_tot);
-	if (res.type == RTN_UNREACHABLE) {
-		rth->dst.input= ip_error;
-		rth->dst.error= -err;
-		rth->rt_flags 	&= ~RTCF_LOCAL;
-	}
-	if (do_cache) {
-		if (unlikely(!rt_cache_route(&FIB_RES_NH(res), rth))) {
-			rth->dst.flags |= DST_NOCACHE;
-			rt_add_uncached_list(rth);
-		}
-	}
-	skb_dst_set(skb, &rth->dst);
-	err = 0;
+	err = ip_route_local_input(skb, &res, net, in_dev,
+				   flags, itag, err);
 	goto out;
 
 no_route:
-- 
1.9.1
