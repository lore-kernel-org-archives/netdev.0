From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH] ipv6: fix race condition regarding dst->expires and dst->from.
Date: Wed, 20 Feb 2013 19:17:29 +0900
Message-ID: <5124A2B9.9060806@linux-ipv6.org>
References: <51249F42.3030908@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:34958 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932912Ab3BTKRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 05:17:30 -0500
In-Reply-To: <51249F42.3030908@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
| Some strange crashes happen in rt6_check_expired(), with access
| to random addresses.
|
| At first glance, it looks like the RTF_EXPIRES and
| stuff added in commit 1716a96101c49186b
| (ipv6: fix problem with expired dst cache)
| are racy : same dst could be manipulated at the same time
| on different cpus.
|
| At some point, our stack believes rt->dst.from contains a dst pointer,
| while its really a jiffie value (as rt->dst.expires shares the same area
| of memory)
|
| rt6_update_expires() should be fixed, or am I missing something ?
|
| CC Neil because of https://bugzilla.redhat.com/show_bug.cgi?id=892060

Because we do not have any locks for dst_entry, we cannot change
essential structure in the entry; e.g., we cannot change reference
to other entities.

To fix this issue, split 'from' and 'expires' field in dst_entry
out of union.  Once it is 'from' is assigned in the constructor,
keep the reference until the very last stage of the life time of
the object.

Of course, it is unsafe to change 'from', so make rt6_set_from simple
just for fresh entries.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Reported-by: Neil Horman <nhorman@tuxdriver.com>
CC: Gao Feng <gaofeng@cn.fujitsu.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/dst.h     |    8 ++------
 include/net/ip6_fib.h |   38 +++++++++++---------------------------
 net/core/dst.c        |    1 +
 net/ipv6/route.c      |    8 +++-----
 4 files changed, 17 insertions(+), 38 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 3da47e0..853cda1 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -36,13 +36,9 @@ struct dst_entry {
 	struct net_device       *dev;
 	struct  dst_ops	        *ops;
 	unsigned long		_metrics;
-	union {
-		unsigned long           expires;
-		/* point to where the dst_entry copied from */
-		struct dst_entry        *from;
-	};
+	unsigned long           expires;
 	struct dst_entry	*path;
-	void			*__pad0;
+	struct dst_entry	*from;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
 #else
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 6919a50..6a3c8ab 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -164,50 +164,34 @@ static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
 
 static inline void rt6_clean_expires(struct rt6_info *rt)
 {
-	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
-		dst_release(rt->dst.from);
-
 	rt->rt6i_flags &= ~RTF_EXPIRES;
-	rt->dst.from = NULL;
 }
 
 static inline void rt6_set_expires(struct rt6_info *rt, unsigned long expires)
 {
-	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
-		dst_release(rt->dst.from);
-
-	rt->rt6i_flags |= RTF_EXPIRES;
 	rt->dst.expires = expires;
+	rt->rt6i_flags |= RTF_EXPIRES;
 }
 
-static inline void rt6_update_expires(struct rt6_info *rt, int timeout)
+static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
 {
-	if (!(rt->rt6i_flags & RTF_EXPIRES)) {
-		if (rt->dst.from)
-			dst_release(rt->dst.from);
-		/* dst_set_expires relies on expires == 0 
-		 * if it has not been set previously.
-		 */
-		rt->dst.expires = 0;
-	}
-
-	dst_set_expires(&rt->dst, timeout);
-	rt->rt6i_flags |= RTF_EXPIRES;
+	struct rt6_info *rt;
+
+	for (rt = rt0; rt && !(rt->rt6i_flags & RTF_EXPIRES); rt = rt->dst.from);
+	if (rt && rt != rt0)
+		rt0->dst.expires = rt->dst.expires;
+
+	dst_set_expires(&rt0->dst, timeout);
+	rt0->rt6i_flags |= RTF_EXPIRES;
 }
 
 static inline void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
 {
 	struct dst_entry *new = (struct dst_entry *) from;
 
-	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from) {
-		if (new == rt->dst.from)
-			return;
-		dst_release(rt->dst.from);
-	}
-
 	rt->rt6i_flags &= ~RTF_EXPIRES;
-	rt->dst.from = new;
 	dst_hold(new);
+	rt->dst.from = new;
 }
 
 static inline void ip6_rt_put(struct rt6_info *rt)
diff --git a/net/core/dst.c b/net/core/dst.c
index ee6153e..35fd12f 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -179,6 +179,7 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst_init_metrics(dst, dst_default_metrics, true);
 	dst->expires = 0UL;
 	dst->path = dst;
+	dst->from = NULL;
 #ifdef CONFIG_XFRM
 	dst->xfrm = NULL;
 #endif
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 515bb51..9db8622 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -287,6 +287,7 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 {
 	struct rt6_info *rt = (struct rt6_info *)dst;
 	struct inet6_dev *idev = rt->rt6i_idev;
+	struct dst_entry *from = dst->from;
 
 	if (!(rt->dst.flags & DST_HOST))
 		dst_destroy_metrics_generic(dst);
@@ -296,8 +297,8 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 		in6_dev_put(idev);
 	}
 
-	if (!(rt->rt6i_flags & RTF_EXPIRES) && dst->from)
-		dst_release(dst->from);
+	dst->from = NULL;
+	dst_release(dst->from);
 
 	if (rt6_has_peer(rt)) {
 		struct inet_peer *peer = rt6_peer_ptr(rt);
@@ -1010,7 +1011,6 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 
 		rt->rt6i_gateway = ort->rt6i_gateway;
 		rt->rt6i_flags = ort->rt6i_flags;
-		rt6_clean_expires(rt);
 		rt->rt6i_metric = 0;
 
 		memcpy(&rt->rt6i_dst, &ort->rt6i_dst, sizeof(struct rt6key));
@@ -1784,8 +1784,6 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 		if ((ort->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) ==
 		    (RTF_DEFAULT | RTF_ADDRCONF))
 			rt6_set_from(rt, ort);
-		else
-			rt6_clean_expires(rt);
 		rt->rt6i_metric = 0;
 
 #ifdef CONFIG_IPV6_SUBTREES
-- 
1.7.9.5
