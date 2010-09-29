From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: __mkroute_output() speedup
Date: Wed, 29 Sep 2010 23:53:50 +0200
Message-ID: <1285797230.5211.173.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45337 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996Ab0I2Vx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 17:53:56 -0400
Received: by fxm4 with SMTP id 4so337964fxm.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 14:53:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While doing stress tests with a disabled IP route cache, I found
__mkroute_output() was touching three times in_device atomic refcount.

Use RCU to touch it once to reduce cache line ping pongs.

Before patch

time to perform the test
real	1m42.009s
user	0m12.545s
sys	25m0.726s

Profile :

16109.00 26.4% ip_route_output_slow   vmlinux              
 7434.00 12.2% dst_destroy            vmlinux              
 3280.00  5.4% fib_rules_lookup       vmlinux              
 3252.00  5.3% fib_semantic_match     vmlinux              
 2622.00  4.3% fib_table_lookup       vmlinux              
 2535.00  4.1% dst_alloc              vmlinux              
 1750.00  2.9% _raw_read_lock         vmlinux              
 1532.00  2.5% rt_set_nexthop         vmlinux   

After patch

real	1m36.503s
user	0m12.977s
sys	23m25.608s

14234.00 22.4% ip_route_output_slow   vmlinux              
 8717.00 13.7% dst_destroy            vmlinux              
 4052.00  6.4% fib_rules_lookup       vmlinux              
 3951.00  6.2% fib_semantic_match     vmlinux              
 3191.00  5.0% dst_alloc              vmlinux              
 1764.00  2.8% fib_table_lookup       vmlinux              
 1692.00  2.7% _raw_read_lock         vmlinux              
 1605.00  2.5% rt_set_nexthop         vmlinux              
 
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |   33 +++++++++++++++------------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 98beda4..ea89500 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2358,9 +2358,8 @@ static int __mkroute_output(struct rtable **result,
 	struct rtable *rth;
 	struct in_device *in_dev;
 	u32 tos = RT_FL_TOS(oldflp);
-	int err = 0;
 
-	if (ipv4_is_loopback(fl->fl4_src) && !(dev_out->flags&IFF_LOOPBACK))
+	if (ipv4_is_loopback(fl->fl4_src) && !(dev_out->flags & IFF_LOOPBACK))
 		return -EINVAL;
 
 	if (fl->fl4_dst == htonl(0xFFFFFFFF))
@@ -2373,11 +2372,12 @@ static int __mkroute_output(struct rtable **result,
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
-	/* get work reference to inet device */
-	in_dev = in_dev_get(dev_out);
-	if (!in_dev)
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(dev_out);
+	if (!in_dev) {
+		rcu_read_unlock();
 		return -EINVAL;
-
+	}
 	if (res->type == RTN_BROADCAST) {
 		flags |= RTCF_BROADCAST | RTCF_LOCAL;
 		if (res->fi) {
@@ -2385,13 +2385,13 @@ static int __mkroute_output(struct rtable **result,
 			res->fi = NULL;
 		}
 	} else if (res->type == RTN_MULTICAST) {
-		flags |= RTCF_MULTICAST|RTCF_LOCAL;
+		flags |= RTCF_MULTICAST | RTCF_LOCAL;
 		if (!ip_check_mc(in_dev, oldflp->fl4_dst, oldflp->fl4_src,
 				 oldflp->proto))
 			flags &= ~RTCF_LOCAL;
 		/* If multicast route do not exist use
-		   default one, but do not gateway in this case.
-		   Yes, it is hack.
+		 * default one, but do not gateway in this case.
+		 * Yes, it is hack.
 		 */
 		if (res->fi && res->prefixlen < 4) {
 			fib_info_put(res->fi);
@@ -2402,9 +2402,12 @@ static int __mkroute_output(struct rtable **result,
 
 	rth = dst_alloc(&ipv4_dst_ops);
 	if (!rth) {
-		err = -ENOBUFS;
-		goto cleanup;
+		rcu_read_unlock();
+		return -ENOBUFS;
 	}
+	in_dev_hold(in_dev);
+	rcu_read_unlock();
+	rth->idev = in_dev;
 
 	atomic_set(&rth->dst.__refcnt, 1);
 	rth->dst.flags= DST_HOST;
@@ -2425,7 +2428,6 @@ static int __mkroute_output(struct rtable **result,
 	   cache entry */
 	rth->dst.dev	= dev_out;
 	dev_hold(dev_out);
-	rth->idev	= in_dev_get(dev_out);
 	rth->rt_gateway = fl->fl4_dst;
 	rth->rt_spec_dst= fl->fl4_src;
 
@@ -2460,13 +2462,8 @@ static int __mkroute_output(struct rtable **result,
 	rt_set_nexthop(rth, res, 0);
 
 	rth->rt_flags = flags;
-
 	*result = rth;
- cleanup:
-	/* release work reference to inet device */
-	in_dev_put(in_dev);
-
-	return err;
+	return 0;
 }
 
 static int ip_mkroute_output(struct rtable **rp,


