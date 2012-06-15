From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Handle PMTU in all ICMP error handlers.
Date: Thu, 14 Jun 2012 22:28:33 -0700 (PDT)
Message-ID: <20120614.222833.1742032309433851016.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45935 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab2FOF2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 01:28:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With ip_rt_frag_needed() removed, we have to explicitly update PMTU
information in every ICMP error handler.

Create two helper functions to facilitate this.

1) ipv4_sk_update_pmtu()

   This updates the PMTU when we have a socket context to
   work with.

2) ipv4_update_pmtu()

   Raw version, used when no socket context is available.  For this
   interface, we essentially just pass in explicit arguments for
   the flow identity information we would have extracted from the
   socket.

   And you'll notice that ipv4_sk_update_pmtu() is simply implemented
   in terms of ipv4_update_pmtu()

Note that __ip_route_output_key() is used, rather than something like
ip_route_output_flow() or ip_route_output_key().  This is because we
absolutely do not want to end up with a route that does IPSEC
encapsulation and the like.  Instead, we only want the route that
would get us to the node described by the outermost IP header.

Reported-by: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---

Steffen, I've checked this patch into net-next, thanks for all of your
help.

I'm working on the ipv6 side of this problem next.

 include/net/route.h |    5 ++++-
 net/ipv4/ah4.c      |    1 +
 net/ipv4/esp4.c     |    1 +
 net/ipv4/ip_gre.c   |   14 ++++++++++----
 net/ipv4/ipcomp.c   |    1 +
 net/ipv4/ipip.c     |   15 +++++++++++----
 net/ipv4/ping.c     |    1 +
 net/ipv4/raw.c      |    3 +++
 net/ipv4/route.c    |   28 ++++++++++++++++++++++++++++
 net/ipv4/udp.c      |    1 +
 net/ipv6/sit.c      |   15 +++++++++++----
 11 files changed, 72 insertions(+), 13 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index a36ae42..47eb25a 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -215,7 +215,10 @@ static inline int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 s
 	return ip_route_input_common(skb, dst, src, tos, devin, true);
 }
 
-extern void		ip_rt_send_redirect(struct sk_buff *skb);
+extern void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
+			     int oif, u32 mark, u8 protocol, int flow_flags);
+extern void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu);
+extern void ip_rt_send_redirect(struct sk_buff *skb);
 
 extern unsigned int		inet_addr_type(struct net *net, __be32 addr);
 extern unsigned int		inet_dev_addr_type(struct net *net, const struct net_device *dev, __be32 addr);
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index e8f2617..916d5ec 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -408,6 +408,7 @@ static void ah4_err(struct sk_buff *skb, u32 info)
 		return;
 	pr_debug("pmtu discovery on SA AH/%08x/%08x\n",
 		 ntohl(ah->spi), ntohl(iph->daddr));
+	ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_AH, 0);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index cb982a6..7b95b49 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -494,6 +494,7 @@ static void esp4_err(struct sk_buff *skb, u32 info)
 		return;
 	NETDEBUG(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%08x\n",
 		 ntohl(esph->spi), ntohl(iph->daddr));
+	ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_ESP, 0);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f49047b..594cec3 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -516,9 +516,6 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 		case ICMP_PORT_UNREACH:
 			/* Impossible event. */
 			return;
-		case ICMP_FRAG_NEEDED:
-			/* Soft state for pmtu is maintained by IP core. */
-			return;
 		default:
 			/* All others are translated to HOST_UNREACH.
 			   rfc2003 contains "deep thoughts" about NET_UNREACH,
@@ -538,7 +535,16 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 				flags & GRE_KEY ?
 				*(((__be32 *)p) + (grehlen / 4) - 1) : 0,
 				p[1]);
-	if (t == NULL || t->parms.iph.daddr == 0 ||
+	if (t == NULL)
+		goto out;
+
+	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
+		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
+				 t->parms.link, 0, IPPROTO_GRE, 0);
+		goto out;
+	}
+
+	if (t->parms.iph.daddr == 0 ||
 	    ipv4_is_multicast(t->parms.iph.daddr))
 		goto out;
 
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 63b64c4..b913754 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -42,6 +42,7 @@ static void ipcomp4_err(struct sk_buff *skb, u32 info)
 		return;
 	NETDEBUG(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/%pI4\n",
 		 spi, &iph->daddr);
+	ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_COMP, 0);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 2d0f99b..715338a 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -348,9 +348,6 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 		case ICMP_PORT_UNREACH:
 			/* Impossible event. */
 			return 0;
-		case ICMP_FRAG_NEEDED:
-			/* Soft state for pmtu is maintained by IP core. */
-			return 0;
 		default:
 			/* All others are translated to HOST_UNREACH.
 			   rfc2003 contains "deep thoughts" about NET_UNREACH,
@@ -369,7 +366,17 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 
 	rcu_read_lock();
 	t = ipip_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr);
-	if (t == NULL || t->parms.iph.daddr == 0)
+	if (t == NULL)
+		goto out;
+
+	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
+		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
+				 t->dev->ifindex, 0, IPPROTO_IPIP, 0);
+		err = 0;
+		goto out;
+	}
+
+	if (t->parms.iph.daddr == 0)
 		goto out;
 
 	err = 0;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 2c00e8b..340fcf2 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -371,6 +371,7 @@ void ping_err(struct sk_buff *skb, u32 info)
 		break;
 	case ICMP_DEST_UNREACH:
 		if (code == ICMP_FRAG_NEEDED) { /* Path MTU discovery */
+			ipv4_sk_update_pmtu(skb, sk, info);
 			if (inet_sock->pmtudisc != IP_PMTUDISC_DONT) {
 				err = EMSGSIZE;
 				harderr = 1;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 4032b81..659ddfb 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -216,6 +216,9 @@ static void raw_err(struct sock *sk, struct sk_buff *skb, u32 info)
 	int err = 0;
 	int harderr = 0;
 
+	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED)
+		ipv4_sk_update_pmtu(skb, sk, info);
+
 	/* Report error on raw socket, if:
 	   1. User requested ip_recverr.
 	   2. Socket is connected (otherwise the error indication
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 655506a..41df529 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1711,6 +1711,34 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 	}
 }
 
+void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
+		      int oif, u32 mark, u8 protocol, int flow_flags)
+{
+	const struct iphdr *iph = (const struct iphdr *)skb->data;
+	struct flowi4 fl4;
+	struct rtable *rt;
+
+	flowi4_init_output(&fl4, oif, mark, RT_TOS(iph->tos), RT_SCOPE_UNIVERSE,
+			   protocol, flow_flags | FLOWI_FLAG_PRECOW_METRICS,
+			   iph->daddr, iph->saddr, 0, 0);
+	rt = __ip_route_output_key(net, &fl4);
+	if (!IS_ERR(rt)) {
+		ip_rt_update_pmtu(&rt->dst, mtu);
+		ip_rt_put(rt);
+	}
+}
+EXPORT_SYMBOL_GPL(ipv4_update_pmtu);
+
+void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+
+	return ipv4_update_pmtu(skb, sock_net(sk), mtu,
+				sk->sk_bound_dev_if, sk->sk_mark,
+				inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
+				inet_sk_flowi_flags(sk));
+}
+EXPORT_SYMBOL_GPL(ipv4_sk_update_pmtu);
 
 static void ipv4_validate_peer(struct rtable *rt)
 {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index eaca736..db017ef 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -615,6 +615,7 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 		break;
 	case ICMP_DEST_UNREACH:
 		if (code == ICMP_FRAG_NEEDED) { /* Path MTU discovery */
+			ipv4_sk_update_pmtu(skb, sk, info);
 			if (inet->pmtudisc != IP_PMTUDISC_DONT) {
 				err = EMSGSIZE;
 				harderr = 1;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 6041571..49aea94 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -527,9 +527,6 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 		case ICMP_PORT_UNREACH:
 			/* Impossible event. */
 			return 0;
-		case ICMP_FRAG_NEEDED:
-			/* Soft state for pmtu is maintained by IP core. */
-			return 0;
 		default:
 			/* All others are translated to HOST_UNREACH.
 			   rfc2003 contains "deep thoughts" about NET_UNREACH,
@@ -551,7 +548,17 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 				skb->dev,
 				iph->daddr,
 				iph->saddr);
-	if (t == NULL || t->parms.iph.daddr == 0)
+	if (t == NULL)
+		goto out;
+
+	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
+		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
+				 t->dev->ifindex, 0, IPPROTO_IPV6, 0);
+		err = 0;
+		goto out;
+	}
+
+	if (t->parms.iph.daddr == 0)
 		goto out;
 
 	err = 0;
-- 
1.7.10
