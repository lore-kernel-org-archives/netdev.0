From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 08/21] ipv4: call dst_hold_safe() properly
Date: Fri, 16 Jun 2017 10:47:31 -0700
Message-ID: <20170616174744.139688-9-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33397 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752420AbdFPRs0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:26 -0400
Received: by mail-pf0-f193.google.com with SMTP id w12so7568114pfk.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:26 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

This patch checks all the calls to
dst_hold()/skb_dst_force()/dst_clone()/dst_use() to see if
dst_hold_safe() is needed to avoid double free issue if dst
gc is removed and dst_release() directly destroys dst when
dst->__refcnt drops to 0.

In tx path, TCP hold sk->sk_rx_dst ref count and also hold sock_lock().
UDP and other similar protocols always hold refcount for
skb->_skb_refdst. So both paths seem to be safe.

In rx path, as it is lockless and skb_dst_set_noref() is likely to be
used, dst_hold_safe() should always be used when trying to hold dst.

In the routing code, if dst is held during an rcu protected session, it
is necessary to call dst_hold_safe() as the current dst might be in its
rcu grace period.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/route.h | 4 +++-
 net/ipv4/route.c    | 4 +---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 08e689f23365..cb0a76d9dde1 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -190,7 +190,9 @@ static inline int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
 	rcu_read_lock();
 	err = ip_route_input_noref(skb, dst, src, tos, devin);
 	if (!err)
-		skb_dst_force(skb);
+		skb_dst_force_safe(skb);
+	if (!skb_dst(skb))
+		err = -EINVAL;
 	rcu_read_unlock();
 
 	return err;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d986d80258d2..903a12c601ac 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2234,10 +2234,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		rth = rcu_dereference(*prth);
 
 rt_cache:
-		if (rt_cache_valid(rth)) {
-			dst_hold(&rth->dst);
+		if (rt_cache_valid(rth) && dst_hold_safe(&rth->dst))
 			return rth;
-		}
 	}
 
 add:
-- 
2.13.1.518.g3df882009-goog
