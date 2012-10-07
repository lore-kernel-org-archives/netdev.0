From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 5/6] ipv4: Add FLOWI_FLAG_KNOWN_NH
Date: Sun,  7 Oct 2012 14:26:07 +0300
Message-ID: <1349609168-9848-6-git-send-email-ja@ssi.bg>
References: <1349609168-9848-1-git-send-email-ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50422 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752705Ab2JGLU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2012 07:20:57 -0400
Received: from ja.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q97BQJ54009896
	for <netdev@vger.kernel.org>; Sun, 7 Oct 2012 14:26:19 +0300
Received: (from root@localhost)
	by ja.ssi.bg (8.14.4/8.14.4/Submit) id q97BQJZf009895
	for netdev@vger.kernel.org; Sun, 7 Oct 2012 14:26:19 +0300
In-Reply-To: <1349609168-9848-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Add flag to request that output route should be
returned with known rt_gateway, in case we want to use
it as nexthop for neighbour resolving.

	The returned route can be cached as follows:

- in NH exception: because the cached routes are not shared
	with other destinations
- in FIB NH: when using gateway because all destinations for
	NH share same gateway

	As last option, to return rt_gateway!=0 we have to
set DST_NOCACHE.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/flow.h |    1 +
 net/ipv4/route.c   |   11 ++++++++++-
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index e1dd508..628e11b 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -21,6 +21,7 @@ struct flowi_common {
 	__u8	flowic_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_CAN_SLEEP		0x02
+#define FLOWI_FLAG_KNOWN_NH		0x04
 	__u32	flowic_secid;
 };
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index eaf9575..7f20b6e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1763,6 +1763,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	struct in_device *in_dev;
 	u16 type = res->type;
 	struct rtable *rth;
+	bool do_cache;
 
 	in_dev = __in_dev_get_rcu(dev_out);
 	if (!in_dev)
@@ -1799,6 +1800,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	}
 
 	fnhe = NULL;
+	do_cache = fi != NULL;
 	if (fi) {
 		struct rtable __rcu **prth;
 		struct fib_nh *nh = &FIB_RES_NH(*res);
@@ -1807,6 +1809,13 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		if (fnhe)
 			prth = &fnhe->fnhe_rth;
 		else {
+			if (unlikely(fl4->flowi4_flags &
+				     FLOWI_FLAG_KNOWN_NH &&
+				     !(nh->nh_gw &&
+				       nh->nh_scope == RT_SCOPE_LINK))) {
+				do_cache = false;
+				goto add;
+			}
 			if (!nh->nh_pcpu_rth_output)
 				goto add;
 			prth = __this_cpu_ptr(nh->nh_pcpu_rth_output);
@@ -1822,7 +1831,7 @@ add:
 	rth = rt_dst_alloc(dev_out,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
 			   IN_DEV_CONF_GET(in_dev, NOXFRM),
-			   fi);
+			   do_cache);
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
 
-- 
1.7.3.4
