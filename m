From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC(v2) net-next 12/13] ipv6: Remove temporary dst for icmpv6.
Date: Wed, 16 Jan 2013 01:46:32 +0900
Message-ID: <50F587E8.1060308@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41328 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756413Ab3AOQqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 11:46:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ip6_fib.c |    2 +-
 net/ipv6/route.c   |   98 ----------------------------------------------------
 2 files changed, 1 insertion(+), 99 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 710cafd..1d7c448 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1643,7 +1643,7 @@ void fib6_run_gc(unsigned long expires, struct net *net)
 		gc_args.timeout = net->ipv6.sysctl.ip6_rt_gc_interval;
 	}
 
-	gc_args.more = icmp6_dst_gc();
+	gc_args.more = 0;
 
 	fib6_clean_all(net, fib6_age, 0, NULL);
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e30a2aa..9605658 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1252,103 +1252,6 @@ static unsigned int ip6_mtu(const struct dst_entry *dst)
 	return mtu;
 }
 
-static struct dst_entry *icmp6_dst_gc_list;
-static DEFINE_SPINLOCK(icmp6_dst_lock);
-
-struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
-				  struct neighbour *neigh,
-				  struct flowi6 *fl6)
-{
-	struct dst_entry *dst;
-	struct rt6_info *rt;
-	struct inet6_dev *idev = in6_dev_get(dev);
-	struct net *net = dev_net(dev);
-
-	if (unlikely(!idev))
-		return ERR_PTR(-ENODEV);
-
-	rt = ip6_dst_alloc(net, dev, 0, NULL);
-	if (unlikely(!rt)) {
-		in6_dev_put(idev);
-		dst = ERR_PTR(-ENOMEM);
-		goto out;
-	}
-
-	if (neigh)
-		neigh_hold(neigh);
-	else {
-		neigh = ip6_neigh_lookup(&rt->dst, NULL, &fl6->daddr);
-		if (IS_ERR(neigh)) {
-			in6_dev_put(idev);
-			dst_free(&rt->dst);
-			return ERR_CAST(neigh);
-		}
-	}
-
-	rt->dst.flags |= DST_HOST;
-	rt->dst.output  = ip6_output;
-	rt->n = neigh;
-	atomic_set(&rt->dst.__refcnt, 1);
-	rt->rt6i_dst.addr = fl6->daddr;
-	rt->rt6i_dst.plen = 128;
-	rt->rt6i_idev     = idev;
-	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 0);
-
-	spin_lock_bh(&icmp6_dst_lock);
-	rt->dst.next = icmp6_dst_gc_list;
-	icmp6_dst_gc_list = &rt->dst;
-	spin_unlock_bh(&icmp6_dst_lock);
-
-	fib6_force_start_gc(net);
-
-	dst = xfrm_lookup(net, &rt->dst, flowi6_to_flowi(fl6), NULL, 0);
-
-out:
-	return dst;
-}
-
-int icmp6_dst_gc(void)
-{
-	struct dst_entry *dst, **pprev;
-	int more = 0;
-
-	spin_lock_bh(&icmp6_dst_lock);
-	pprev = &icmp6_dst_gc_list;
-
-	while ((dst = *pprev) != NULL) {
-		if (!atomic_read(&dst->__refcnt)) {
-			*pprev = dst->next;
-			dst_free(dst);
-		} else {
-			pprev = &dst->next;
-			++more;
-		}
-	}
-
-	spin_unlock_bh(&icmp6_dst_lock);
-
-	return more;
-}
-
-static void icmp6_clean_all(int (*func)(struct rt6_info *rt, void *arg),
-			    void *arg)
-{
-	struct dst_entry *dst, **pprev;
-
-	spin_lock_bh(&icmp6_dst_lock);
-	pprev = &icmp6_dst_gc_list;
-	while ((dst = *pprev) != NULL) {
-		struct rt6_info *rt = (struct rt6_info *) dst;
-		if (func(rt, arg)) {
-			*pprev = dst->next;
-			dst_free(dst);
-		} else {
-			pprev = &dst->next;
-		}
-	}
-	spin_unlock_bh(&icmp6_dst_lock);
-}
-
 static int ip6_dst_gc(struct dst_ops *ops)
 {
 	unsigned long now = jiffies;
@@ -2235,7 +2138,6 @@ void rt6_ifdown(struct net *net, struct net_device *dev)
 	};
 
 	fib6_clean_all(net, fib6_ifdown, 0, &adn);
-	icmp6_clean_all(fib6_ifdown, &adn);
 }
 
 struct rt6_mtu_change_arg {
-- 
1.7.9.5
