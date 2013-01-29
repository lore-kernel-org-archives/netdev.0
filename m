From: Jiri Bohac <jbohac@suse.cz>
Subject: [RFC] xfrm: fix pmtu discovery (kill xfrm6_update_pmtu)
Date: Tue, 29 Jan 2013 15:43:25 +0100
Message-ID: <20130129144325.GB23396@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59239 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756569Ab3A2Onf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 09:43:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

there is a problem in the xfrm PMTU discovery. This happens with
IPv6, I'm not sure if the same applies to IPv4:

Let's have e.g. an ESP transport-mode policy mode between
two endpoints: A and B. The ESP-encapsulated packets are sent
over a router R:
	A <----> R <----> B
and the R <----> B link has a small MTU of 1452.

R sends an ICMPV6_PKT_TOOBIG to A with MTU==1452.
This is what then happens on A:

icmpv6_rcv() -> icmpv6_notify() -> esp6_err() -> ip6_update_pmtu()

This looks up the non-xfrm dst entry to host B (dst_B) and
decreases its MTU to 1452

Next time a large TCP segment (len=1452 bytes including TCP/IP
headers in this example) from A to B is created:

tcp_sendmsg() -> ... -> inet6_csk_xmit() -> ... -> xfrm_bundle_ok()

dst->child and xdst->route now point to the dst_B with MTU==1452
xdst->route_mtu_cached and xdst->child_mtu_cached are both 1500,
so the MTU of the xfrm bundle's dst (dst_B_xfrm) is decreased to 
xfrm_state_mtu(dst_B_xfrm, 1452)==1414.

When the TCP segment reaches ip6_xmit:
	skb->len > dst_mtu(dst_B_xfrm)
	1452 > 1414
This generates an ICMPV6_PKT_TOOBIG to self with MTU==1414.
This is intended to reach the protocol error handler (decrease
the MSS in the TCP case):

icmpv6_rcv() -> icmpv6_notify() -> tcp_v6_err().

Then, tcp_v6_mtu_reduced() is either called directly or deferred
until the socket is unlocked.

Everything is fine until now. The problem starts here:

tcp_v6_mtu_reduced() -> inet6_csk_update_pmtu():
	
	dst = inet6_csk_route_socket().
	//dst == dst_B_xfrm
	dst->ops->update_pmtu(dst, sk, NULL, mtu);

dst->ops->update_pmtu == xfrm6_update_pmtu:

       struct dst_entry *path = xdst->route;
       path->ops->update_pmtu(path, sk, skb, mtu);

path == dst_B, so we have now decreased the non-xfrm route's MTU
to 1414

The next time xfrm_bundle_ok(dst_B_xfrm) is called, the MTU of
dst_B_xfrm is decreased again (!!) to 1366.

If there is a single TCP socket, the loop ends here with both
dst_B and dst_B_xfrm being unnecessarily low.

Otherwise this becomes a race between the MSS updates on the TCP
sockets and the xfrm6_update_pmtu() + xfrm_bundle_ok() loop
decreasing the MTU again and again, until the minimum MTU of 1280
is reached.

xfrm6_update_pmtu() has been doing this since ever. How was
this supposed to work? Why would it ever want to adjust the MTU
of the non-xfrm route that will be used to send the transformed
packets?

Replacing xfrm6_update_pmtu with ip6_rt_update_pmtu fixes the
problem for me. But perhaps I am overlooking something that gets
broken by this.

Also, the IPv4 version does the same. Perhaps it has the same
problems?


diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 27d8318..1e8cb91 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -134,6 +134,9 @@ extern void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 			    int oif, u32 mark);
 extern void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk,
 			       __be32 mtu);
+extern void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
+                               struct sk_buff *skb, u32 mtu);
+
 extern void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark);
 extern void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk);
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e229a3b..9d32702 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -79,7 +79,7 @@ static int		 ip6_dst_gc(struct dst_ops *ops);
 static int		ip6_pkt_discard(struct sk_buff *skb);
 static int		ip6_pkt_discard_out(struct sk_buff *skb);
 static void		ip6_link_failure(struct sk_buff *skb);
-static void		ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
+void		ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 					   struct sk_buff *skb, u32 mtu);
 static void		rt6_do_redirect(struct dst_entry *dst, struct sock *sk,
 					struct sk_buff *skb);
@@ -1125,7 +1125,7 @@ static void ip6_link_failure(struct sk_buff *skb)
 	}
 }
 
-static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
+void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 			       struct sk_buff *skb, u32 mtu)
 {
 	struct rt6_info *rt6 = (struct rt6_info*)dst;
@@ -1145,6 +1145,7 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 		rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
 	}
 }
+EXPORT_SYMBOL_GPL(ip6_rt_update_pmtu);
 
 void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 		     int oif, u32 mark)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index c984413..ad070c0 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -277,7 +277,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.family =		AF_INET6,
 	.protocol =		cpu_to_be16(ETH_P_IPV6),
 	.gc =			xfrm6_garbage_collect,
-	.update_pmtu =		xfrm6_update_pmtu,
+	.update_pmtu =		ip6_rt_update_pmtu,
 	.redirect =		xfrm6_redirect,
 	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		xfrm6_dst_destroy,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
