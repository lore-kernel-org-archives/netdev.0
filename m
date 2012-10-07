From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 3/6] ipv4: add check if nh_pcpu_rth_output is allocated
Date: Sun,  7 Oct 2012 14:26:05 +0300
Message-ID: <1349609168-9848-4-git-send-email-ja@ssi.bg>
References: <1349609168-9848-1-git-send-email-ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50418 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661Ab2JGLU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2012 07:20:56 -0400
Received: from ja.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q97BQI8a009888
	for <netdev@vger.kernel.org>; Sun, 7 Oct 2012 14:26:18 +0300
Received: (from root@localhost)
	by ja.ssi.bg (8.14.4/8.14.4/Submit) id q97BQIb0009887
	for netdev@vger.kernel.org; Sun, 7 Oct 2012 14:26:18 +0300
In-Reply-To: <1349609168-9848-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Avoid NULL ptr dereference and caching if
nh_pcpu_rth_output is not allocated.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/route.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 488a8bb..0a600cc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1798,18 +1798,24 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	fnhe = NULL;
 	if (fi) {
 		struct rtable __rcu **prth;
+		struct fib_nh *nh = &FIB_RES_NH(*res);
 
-		fnhe = find_exception(&FIB_RES_NH(*res), fl4->daddr);
+		fnhe = find_exception(nh, fl4->daddr);
 		if (fnhe)
 			prth = &fnhe->fnhe_rth;
-		else
-			prth = __this_cpu_ptr(FIB_RES_NH(*res).nh_pcpu_rth_output);
+		else {
+			if (!nh->nh_pcpu_rth_output)
+				goto add;
+			prth = __this_cpu_ptr(nh->nh_pcpu_rth_output);
+		}
 		rth = rcu_dereference(*prth);
 		if (rt_cache_valid(rth)) {
 			dst_hold(&rth->dst);
 			return rth;
 		}
 	}
+
+add:
 	rth = rt_dst_alloc(dev_out,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
 			   IN_DEV_CONF_GET(in_dev, NOXFRM),
-- 
1.7.3.4
