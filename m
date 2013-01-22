From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] ipv4: Fix route refcount on pmtu discovery
Date: Tue, 22 Jan 2013 11:01:28 +0100
Message-ID: <20130122100128.GD9147@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35048 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752898Ab3AVKBv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 05:01:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

git commit 9cb3a50c (ipv4: Invalidate the socket cached route on
pmtu events if possible) introduced a refcount problem. We don't
get a refcount on the route if we get it from__sk_dst_get(), but
we need one if we want to reuse this route because __sk_dst_set()
releases the refcount of the old route. This patch adds proper
refcount handling for that case. We introduce a 'new' flag to
indicate that we are going to use a new route and we release the
old route only if we replace it by a new one.

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 132737a..a0fcc47 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -985,6 +985,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	struct flowi4 fl4;
 	struct rtable *rt;
 	struct dst_entry *dst;
+	bool new = false;
 
 	bh_lock_sock(sk);
 	rt = (struct rtable *) __sk_dst_get(sk);
@@ -1000,20 +1001,26 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
 		if (IS_ERR(rt))
 			goto out;
+
+		new = true;
 	}
 
 	__ip_rt_update_pmtu((struct rtable *) rt->dst.path, &fl4, mtu);
 
 	dst = dst_check(&rt->dst, 0);
 	if (!dst) {
+		if (new)
+			dst_release(&rt->dst);
+
 		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
 		if (IS_ERR(rt))
 			goto out;
 
-		dst = &rt->dst;
+		new = true;
 	}
 
-	 __sk_dst_set(sk, dst);
+	if (new)
+		__sk_dst_set(sk, &rt->dst);
 
 out:
 	bh_unlock_sock(sk);
-- 
1.7.9.5
