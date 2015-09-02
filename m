From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/3] net: Add FIB table id to rtable
Date: Wed,  2 Sep 2015 09:40:33 -0700
Message-ID: <1441212034-37464-2-git-send-email-dsa@cumulusnetworks.com>
References: <1441212034-37464-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33214 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755525AbbIBQkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 12:40:42 -0400
Received: by pacex6 with SMTP id ex6so11769339pac.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 09:40:42 -0700 (PDT)
In-Reply-To: <1441212034-37464-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the FIB table id to rtable to make the information available for
IPv4 as it is for IPv6.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c       | 2 ++
 include/net/route.h     | 2 ++
 net/ipv4/route.c        | 8 ++++++++
 net/ipv4/xfrm4_policy.c | 1 +
 4 files changed, 13 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index e7094fbd7568..8c9ab5ebea23 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -320,6 +320,7 @@ static void vrf_rtable_destroy(struct net_vrf *vrf)
 
 static struct rtable *vrf_rtable_create(struct net_device *dev)
 {
+	struct net_vrf *vrf = netdev_priv(dev);
 	struct rtable *rth;
 
 	rth = dst_alloc(&vrf_dst_ops, dev, 2,
@@ -335,6 +336,7 @@ static struct rtable *vrf_rtable_create(struct net_device *dev)
 		rth->rt_pmtu	= 0;
 		rth->rt_gateway	= 0;
 		rth->rt_uses_gateway = 0;
+		rth->rt_table_id = vrf->tb_id;
 		INIT_LIST_HEAD(&rth->rt_uncached);
 		rth->rt_uncached_list = NULL;
 	}
diff --git a/include/net/route.h b/include/net/route.h
index cc61cb95f059..10a7d21a211c 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -64,6 +64,8 @@ struct rtable {
 	/* Miscellaneous cached information */
 	u32			rt_pmtu;
 
+	u32			rt_table_id;
+
 	struct list_head	rt_uncached;
 	struct uncached_list	*rt_uncached_list;
 };
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index eaefeadce07c..92acc95b7578 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1457,6 +1457,7 @@ static struct rtable *rt_dst_alloc(struct net_device *dev,
 		rt->rt_pmtu = 0;
 		rt->rt_gateway = 0;
 		rt->rt_uses_gateway = 0;
+		rt->rt_table_id = 0;
 		INIT_LIST_HEAD(&rt->rt_uncached);
 
 		rt->dst.output = ip_output;
@@ -1629,6 +1630,8 @@ static int __mkroute_input(struct sk_buff *skb,
 	}
 
 	rth->rt_is_input = 1;
+	if (res->table)
+		rth->rt_table_id = res->table->tb_id;
 	RT_CACHE_STAT_INC(in_slow_tot);
 
 	rth->dst.input = ip_forward;
@@ -1808,6 +1811,8 @@ out:	return err;
 	rth->dst.tclassid = itag;
 #endif
 	rth->rt_is_input = 1;
+	if (res.table)
+		rth->rt_table_id = res.table->tb_id;
 
 	RT_CACHE_STAT_INC(in_slow_tot);
 	if (res.type == RTN_UNREACHABLE) {
@@ -1988,6 +1993,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		return ERR_PTR(-ENOBUFS);
 
 	rth->rt_iif	= orig_oif ? : 0;
+	if (res->table)
+		rth->rt_table_id = res->table->tb_id;
+
 	RT_CACHE_STAT_INC(out_slow_tot);
 
 	if (flags & (RTCF_BROADCAST | RTCF_MULTICAST)) {
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index bb919b28619f..671011055ad5 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -95,6 +95,7 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	xdst->u.rt.rt_gateway = rt->rt_gateway;
 	xdst->u.rt.rt_uses_gateway = rt->rt_uses_gateway;
 	xdst->u.rt.rt_pmtu = rt->rt_pmtu;
+	xdst->u.rt.rt_table_id = rt->rt_table_id;
 	INIT_LIST_HEAD(&xdst->u.rt.rt_uncached);
 
 	return 0;
-- 
1.9.1
