From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [BK PATCH] [IPV6] Merge Specification Conformity Improvements
Date: Tue, 14 Sep 2004 10:19:15 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914.101915.10604263.yoshfuji@linux-ipv6.org>
References: <20040913.231732.94153456.yoshfuji@linux-ipv6.org>
	<20040913155506.4c99d4c8.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, vnuorval@tcs.hut.fi, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20040913155506.4c99d4c8.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040913155506.4c99d4c8.davem@davemloft.net> (at Mon, 13 Sep 2004 15:55:06 -0700), "David S. Miller" <davem@davemloft.net> says:

> 2) rt6_dflt_{pointer,lock}
> 
>    Maybe it would be better to export a function that operates
>    on these objects rather than the objects themselves.  That
>    way we could keep them and their implementation static to
>    ip6_fib.c

Yes! I know it is silly, of course.

Well, I have a plan to remove rt6_dflt_{pointer,lock} shortly,
but anyway...

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== include/net/ip6_route.h 1.18 vs edited =====
--- 1.18/include/net/ip6_route.h	2004-09-11 23:50:37 +09:00
+++ edited/include/net/ip6_route.h	2004-09-14 10:01:50 +09:00
@@ -89,6 +89,8 @@
 
 extern void			rt6_purge_dflt_routers(int lst_resort);
 
+extern void			rt6_reset_dflt_pointer(struct rt6_info *rt);
+
 extern void			rt6_redirect(struct in6_addr *dest,
 					     struct in6_addr *saddr,
 					     struct neighbour *neigh,
===== net/ipv6/ip6_fib.c 1.30 vs edited =====
--- 1.30/net/ipv6/ip6_fib.c	2004-09-11 23:56:06 +09:00
+++ edited/net/ipv6/ip6_fib.c	2004-09-14 10:00:33 +09:00
@@ -49,9 +49,6 @@
 
 struct rt6_statistics	rt6_stats;
 
-extern struct rt6_info *rt6_dflt_pointer;
-extern spinlock_t rt6_dflt_lock;
-
 static kmem_cache_t * fib6_node_kmem;
 
 enum fib_walk_state_t
@@ -1187,10 +1184,7 @@
 	if (rt->rt6i_flags&RTF_EXPIRES && rt->rt6i_expires) {
 		if (time_after(now, rt->rt6i_expires)) {
 			RT6_TRACE("expiring %p\n", rt);
-			spin_lock_bh(&rt6_dflt_lock);
-			if (rt == rt6_dflt_pointer)
-				rt6_dflt_pointer = NULL;
-			spin_unlock_bh(&rt6_dflt_lock);
+			rt6_reset_dflt_pointer(rt);
 			return -1;
 		}
 		gc_args.more++;
===== net/ipv6/route.c 1.92 vs edited =====
--- 1.92/net/ipv6/route.c	2004-09-11 23:53:53 +09:00
+++ edited/net/ipv6/route.c	2004-09-14 10:10:25 +09:00
@@ -210,6 +210,16 @@
 struct rt6_info *rt6_dflt_pointer;
 spinlock_t rt6_dflt_lock = SPIN_LOCK_UNLOCKED;
 
+void rt6_reset_dflt_pointer(struct rt6_info *rt)
+{
+	spin_lock_bh(&rt6_dflt_lock);
+	if (rt == NULL || rt == rt6_dflt_pointer) {
+		RT6_TRACE("reset default router: %p->NULL\n", rt6_dflt_pointer);
+		rt6_dflt_pointer = NULL;
+	}
+	spin_unlock_bh(&rt6_dflt_lock);
+}
+
 /* Default Router Selection (RFC 2461 6.3.6) */
 static struct rt6_info *rt6_best_dflt(struct rt6_info *rt, int oif)
 {
@@ -959,9 +969,7 @@
 
 	write_lock_bh(&rt6_lock);
 
-	spin_lock_bh(&rt6_dflt_lock);
-	rt6_dflt_pointer = NULL;
-	spin_unlock_bh(&rt6_dflt_lock);
+	rt6_reset_dflt_pointer(NULL);
 
 	dst_release(&rt->u.dst);
 
@@ -1288,9 +1296,7 @@
 		if (rt->rt6i_flags & flags) {
 			dst_hold(&rt->u.dst);
 
-			spin_lock_bh(&rt6_dflt_lock);
-			rt6_dflt_pointer = NULL;
-			spin_unlock_bh(&rt6_dflt_lock);
+			rt6_reset_dflt_pointer(NULL);
 
 			read_unlock_bh(&rt6_lock);
 


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
