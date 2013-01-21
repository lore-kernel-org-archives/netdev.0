From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] ipv4: Invalidate the socket cached route on pmtu events
 if possible
Date: Mon, 21 Jan 2013 12:59:11 +0100
Message-ID: <20130121115911.GE30530@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47265 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752403Ab3AUL7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 06:59:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The route lookup in ipv4_sk_update_pmtu() might return a route
different from the route we cached at the socket. This is because
standart routes are per cpu, so each cpu has it's own struct rtable.
This means that we do not invalidate the socket cached route if the
NET_RX_SOFTIRQ is not served by the same cpu that the sending socket
uses. As a result, the cached route reused until we disconnect.

With this patch we invalidate the socket cached route if possible.
If the socket is owened by the user, we can't update the cached
route directly. A followup patch will implement socket release
callback functions for datagram sockets to handle this case.

Reported-by: Yurij M. Plotnikov <Yurij.Plotnikov@oktetlabs.ru>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |   42 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 41 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 259cbee..132737a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -965,7 +965,7 @@ void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
 }
 EXPORT_SYMBOL_GPL(ipv4_update_pmtu);
 
-void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
+static void __ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 {
 	const struct iphdr *iph = (const struct iphdr *) skb->data;
 	struct flowi4 fl4;
@@ -978,6 +978,46 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 		ip_rt_put(rt);
 	}
 }
+
+void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
+{
+	const struct iphdr *iph = (const struct iphdr *) skb->data;
+	struct flowi4 fl4;
+	struct rtable *rt;
+	struct dst_entry *dst;
+
+	bh_lock_sock(sk);
+	rt = (struct rtable *) __sk_dst_get(sk);
+
+	if (sock_owned_by_user(sk) || !rt) {
+		__ipv4_sk_update_pmtu(skb, sk, mtu);
+		goto out;
+	}
+
+	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
+
+	if (!__sk_dst_check(sk, 0)) {
+		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
+		if (IS_ERR(rt))
+			goto out;
+	}
+
+	__ip_rt_update_pmtu((struct rtable *) rt->dst.path, &fl4, mtu);
+
+	dst = dst_check(&rt->dst, 0);
+	if (!dst) {
+		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
+		if (IS_ERR(rt))
+			goto out;
+
+		dst = &rt->dst;
+	}
+
+	 __sk_dst_set(sk, dst);
+
+out:
+	bh_unlock_sock(sk);
+}
 EXPORT_SYMBOL_GPL(ipv4_sk_update_pmtu);
 
 void ipv4_redirect(struct sk_buff *skb, struct net *net,
-- 
1.7.9.5
