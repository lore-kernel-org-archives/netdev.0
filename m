From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC PATCH 1/3] ipv4: Invalidate the socket cached route on pmtu
 events if possible
Date: Fri, 18 Jan 2013 09:14:20 +0100
Message-ID: <20130118081419.GC24987@secunet.com>
References: <50D1BCC0.2000208@oktetlabs.ru>
 <1355924119.2676.6.camel@bwh-desktop.uk.solarflarecom.com>
 <50D1CECE.7090706@oktetlabs.ru>
 <1355945864.2676.21.camel@bwh-desktop.uk.solarflarecom.com>
 <20121220073445.GM18940@secunet.com>
 <50D2F4E5.4050904@oktetlabs.ru>
 <20121220123535.GN18940@secunet.com>
 <20121221102253.GO18940@secunet.com>
 <50F3C153.9030204@oktetlabs.ru>
 <20130118081145.GB24987@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44898 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750750Ab3ARIOW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 03:14:22 -0500
Content-Disposition: inline
In-Reply-To: <20130118081145.GB24987@secunet.com>
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

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |   40 +++++++++++++++++++++++++++++++++++++++-
 1 file changed, 39 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 259cbee..e59541b 100644
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
@@ -978,6 +978,44 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 		ip_rt_put(rt);
 	}
 }
+
+void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
+{
+	const struct iphdr *iph = (const struct iphdr *) skb->data;
+	struct flowi4 fl4;
+	struct rtable *rt = (struct rtable *) __sk_dst_get(sk);
+	struct dst_entry *dst;
+
+	bh_lock_sock(sk);
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
