From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 2/2] ipv6: use newly introduced helper functions __ipv6_addr_needs_scope_id and ipv6_iface_scope_id
Date: Mon, 11 Feb 2013 12:13:47 +0100
Message-ID: <20130211111347.GB23991@order.stressinduktion.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <5112759E.90104@linux-ipv6.org> <20130206165415.GB19537@order.stressinduktion.org> <20130209121005.GB23281@order.stressinduktion.org> <5116595E.2080601@linux-ipv6.org> <20130210153230.GA21377@order.stressinduktion.org> <5117EA2D.1020106@linux-ipv6.org> <20130210184918.GB20897@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56727 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221Ab3BKLNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 06:13:48 -0500
Content-Disposition: inline
In-Reply-To: <20130210184918.GB20897@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is strictly an RFC (I also left out my signed-off). I intended
post it just to show the usage of the new helper functions.

With this patch applied my test programs reported that interface scoped
multicast finally works over loopback. :)

Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/af_inet6.c              |  6 +++---
 net/ipv6/datagram.c              | 12 ++++++------
 net/ipv6/icmp.c                  |  2 +-
 net/ipv6/inet6_connection_sock.c |  6 ++----
 net/ipv6/ip6_input.c             |  2 +-
 net/ipv6/udp.c                   |  6 +++---
 6 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 6b793bf..f56277f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -323,7 +323,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			struct net_device *dev = NULL;
 
 			rcu_read_lock();
-			if (addr_type & IPV6_ADDR_LINKLOCAL) {
+			if (__ipv6_addr_needs_scope_id(addr_type)) {
 				if (addr_len >= sizeof(struct sockaddr_in6) &&
 				    addr->sin6_scope_id) {
 					/* Override any existing binding, if another one
@@ -471,8 +471,8 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 
 		sin->sin6_port = inet->inet_sport;
 	}
-	if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		sin->sin6_scope_id = sk->sk_bound_dev_if;
+	sin->sin6_scope_id = ipv6_iface_scope_id(&sin->sin6_addr,
+						 sk->sk_bound_dev_if);
 	*uaddr_len = sizeof(*sin);
 	return 0;
 }
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index f5a5478..c05a2c9 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -124,7 +124,7 @@ ipv4_connected:
 		goto out;
 	}
 
-	if (addr_type&IPV6_ADDR_LINKLOCAL) {
+	if (__ipv6_addr_needs_scope_id(addr_type)) {
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    usin->sin6_scope_id) {
 			if (sk->sk_bound_dev_if &&
@@ -362,8 +362,8 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 			sin->sin6_addr = ip6h->daddr;
 			if (np->sndflow)
 				sin->sin6_flowinfo = ip6_flowinfo(ip6h);
-			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-				sin->sin6_scope_id = IP6CB(skb)->iif;
+			sin->sin6_scope_id = ipv6_iface_scope_id(&sin->sin6_addr,
+								 IP6CB(skb)->iif);
 		} else {
 			ipv6_addr_set_v4mapped(*(__be32 *)(nh + serr->addr_offset),
 					       &sin->sin6_addr);
@@ -381,8 +381,8 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 			sin->sin6_addr = ipv6_hdr(skb)->saddr;
 			if (np->rxopt.all)
 				ip6_datagram_recv_ctl(sk, msg, skb);
-			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-				sin->sin6_scope_id = IP6CB(skb)->iif;
+			sin->sin6_scope_id = ipv6_iface_scope_id(&sin->sin6_addr,
+								 IP6CB(skb)->iif);
 		} else {
 			struct inet_sock *inet = inet_sk(sk);
 
@@ -653,7 +653,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 					rcu_read_unlock();
 					return -ENODEV;
 				}
-			} else if (addr_type & IPV6_ADDR_LINKLOCAL) {
+			} else if (__ipv6_addr_needs_scope_id(addr_type)) {
 				rcu_read_unlock();
 				return -EINVAL;
 			}
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index fff5bdd..71b900c 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -434,7 +434,7 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	 *	Source addr check
 	 */
 
-	if (addr_type & IPV6_ADDR_LINKLOCAL)
+	if (__ipv6_addr_needs_scope_id(addr_type))
 		iif = skb->dev->ifindex;
 
 	/*
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index b386a2c..9f1020b 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -170,10 +170,8 @@ void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
 	sin6->sin6_port	= inet_sk(sk)->inet_dport;
 	/* We do not store received flowlabel for TCP */
 	sin6->sin6_flowinfo = 0;
-	sin6->sin6_scope_id = 0;
-	if (sk->sk_bound_dev_if &&
-	    ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		sin6->sin6_scope_id = sk->sk_bound_dev_if;
+	sin6->sin6_scope_id = ipv6_iface_scope_id(&sin6->sin6_addr,
+						  sk->sk_bound_dev_if);
 }
 
 EXPORT_SYMBOL_GPL(inet6_csk_addr2sockaddr);
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 521d9fd..f10bd9f 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -279,7 +279,7 @@ int ip6_mc_input(struct sk_buff *skb)
 	 *      IPv6 multicast router mode is now supported ;)
 	 */
 	if (dev_net(skb->dev)->ipv6.devconf_all->mc_forwarding &&
-	    !(ipv6_addr_type(&hdr->daddr) & IPV6_ADDR_LINKLOCAL) &&
+	    !__ipv6_addr_needs_scope_id(__ipv6_addr_type(&hdr->daddr)) &&
 	    likely(!(IP6CB(skb)->flags & IP6SKB_FORWARDED))) {
 		/*
 		 * Okay, we try to forward - split and duplicate
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 599e1ba6..97d5ad0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -457,8 +457,8 @@ try_again:
 					       &sin6->sin6_addr);
 		else {
 			sin6->sin6_addr = ipv6_hdr(skb)->saddr;
-			if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-				sin6->sin6_scope_id = IP6CB(skb)->iif;
+			sin6->sin6_scope_id = ipv6_iface_scope_id(&sin6->sin6_addr,
+								  IP6CB(skb)->iif);
 		}
 
 	}
@@ -1118,7 +1118,7 @@ do_udp_sendmsg:
 
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    sin6->sin6_scope_id &&
-		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
+		    __ipv6_addr_needs_scope_id(__ipv6_addr_type(daddr)))
 			fl6.flowi6_oif = sin6->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
-- 
1.8.1.2
