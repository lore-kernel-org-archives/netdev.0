From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 3/4] ipv6: use newly introduced __ipv6_addr_needs_scope_id and ipv6_iface_scope_id
Date: Sat, 16 Feb 2013 20:10:17 +0100
Message-ID: <20130216191017.GA23363@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org, brian.haley@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39312 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031Ab3BPTKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 14:10:18 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch requires multicast interface-scoped addresses to supply a
sin6_scope_id. Because the sin6_scope_id is now also correctly used
in case of interface-scoped multicast traffic this enables one to use
interface scoped addresses over interfaces which are not targeted by the
default multicast route (the route has to be put there manually, though).

getsockname() and getpeername() now return the correct sin6_scope_id in
case of interface-local mc addresses.

v2:
a) rebased ontop of patch 1/4 (now uses ipv6_addr_props)

Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: Brian Haley <brian.haley@hp.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/af_inet6.c              | 25 +++++++++++++------------
 net/ipv6/datagram.c              | 31 +++++++++++++++++--------------
 net/ipv6/icmp.c                  | 14 +++++++-------
 net/ipv6/inet6_connection_sock.c |  6 ++----
 net/ipv6/raw.c                   | 21 ++++++++++-----------
 net/ipv6/udp.c                   | 14 ++++++++------
 6 files changed, 57 insertions(+), 54 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 6b793bf..fb92b0e 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -265,7 +265,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct net *net = sock_net(sk);
 	__be32 v4addr = 0;
 	unsigned short snum;
-	int addr_type = 0;
+	struct ipv6_addr_props addr_props;
 	int err = 0;
 
 	/* If the socket has its own bind function then use it. */
@@ -278,8 +278,9 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (addr->sin6_family != AF_INET6)
 		return -EAFNOSUPPORT;
 
-	addr_type = ipv6_addr_type(&addr->sin6_addr);
-	if ((addr_type & IPV6_ADDR_MULTICAST) && sock->type == SOCK_STREAM)
+	addr_props = __ipv6_addr_props(&addr->sin6_addr);
+	if (addr_props.type & IPV6_ADDR_MULTICAST &&
+	    sock->type == SOCK_STREAM)
 		return -EINVAL;
 
 	snum = ntohs(addr->sin6_port);
@@ -295,7 +296,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	}
 
 	/* Check if the address belongs to the host. */
-	if (addr_type == IPV6_ADDR_MAPPED) {
+	if (addr_props.type == IPV6_ADDR_MAPPED) {
 		int chk_addr_ret;
 
 		/* Binding to v4-mapped address on a v6-only socket
@@ -319,11 +320,11 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out;
 		}
 	} else {
-		if (addr_type != IPV6_ADDR_ANY) {
+		if (addr_props.type != IPV6_ADDR_ANY) {
 			struct net_device *dev = NULL;
 
 			rcu_read_lock();
-			if (addr_type & IPV6_ADDR_LINKLOCAL) {
+			if (__ipv6_addr_needs_scope_id(addr_props)) {
 				if (addr_len >= sizeof(struct sockaddr_in6) &&
 				    addr->sin6_scope_id) {
 					/* Override any existing binding, if another one
@@ -348,7 +349,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			 * unspecified and mapped address have a v4 equivalent.
 			 */
 			v4addr = LOOPBACK4_IPV6;
-			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
+			if (!(addr_props.type & IPV6_ADDR_MULTICAST))	{
 				if (!(inet->freebind || inet->transparent) &&
 				    !ipv6_chk_addr(net, &addr->sin6_addr,
 						   dev, 0)) {
@@ -365,7 +366,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	np->rcv_saddr = addr->sin6_addr;
 
-	if (!(addr_type & IPV6_ADDR_MULTICAST))
+	if (!(addr_props.type & IPV6_ADDR_MULTICAST))
 		np->saddr = addr->sin6_addr;
 
 	/* Make sure we are allowed to bind here. */
@@ -375,9 +376,9 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	}
 
-	if (addr_type != IPV6_ADDR_ANY) {
+	if (addr_props.type != IPV6_ADDR_ANY) {
 		sk->sk_userlocks |= SOCK_BINDADDR_LOCK;
-		if (addr_type != IPV6_ADDR_MAPPED)
+		if (addr_props.type != IPV6_ADDR_MAPPED)
 			np->ipv6only = 1;
 	}
 	if (snum)
@@ -471,8 +472,8 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 
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
index 05f0889..bf30989 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -50,7 +50,7 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	struct flowi6		fl6;
 	struct ip6_flowlabel	*flowlabel = NULL;
 	struct ipv6_txoptions   *opt;
-	int			addr_type;
+	struct ipv6_addr_props	addr_props;
 	int			err;
 
 	if (usin->sin6_family == AF_INET) {
@@ -77,9 +77,9 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		}
 	}
 
-	addr_type = ipv6_addr_type(&usin->sin6_addr);
+	addr_props = __ipv6_addr_props(&usin->sin6_addr);
 
-	if (addr_type == IPV6_ADDR_ANY) {
+	if (addr_props.type == IPV6_ADDR_ANY) {
 		/*
 		 *	connect to self
 		 */
@@ -88,7 +88,7 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	daddr = &usin->sin6_addr;
 
-	if (addr_type == IPV6_ADDR_MAPPED) {
+	if (addr_props.type == IPV6_ADDR_MAPPED) {
 		struct sockaddr_in sin;
 
 		if (__ipv6_only_sock(sk)) {
@@ -124,7 +124,7 @@ ipv4_connected:
 		goto out;
 	}
 
-	if (addr_type&IPV6_ADDR_LINKLOCAL) {
+	if (__ipv6_addr_needs_scope_id(addr_props)) {
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    usin->sin6_scope_id) {
 			if (sk->sk_bound_dev_if &&
@@ -135,7 +135,8 @@ ipv4_connected:
 			sk->sk_bound_dev_if = usin->sin6_scope_id;
 		}
 
-		if (!sk->sk_bound_dev_if && (addr_type & IPV6_ADDR_MULTICAST))
+		if (!sk->sk_bound_dev_if &&
+		    addr_props.type & IPV6_ADDR_MULTICAST)
 			sk->sk_bound_dev_if = np->mcast_oif;
 
 		/* Connect to link-local address requires an interface */
@@ -163,7 +164,7 @@ ipv4_connected:
 	fl6.fl6_dport = inet->inet_dport;
 	fl6.fl6_sport = inet->inet_sport;
 
-	if (!fl6.flowi6_oif && (addr_type&IPV6_ADDR_MULTICAST))
+	if (!fl6.flowi6_oif && (addr_props.type & IPV6_ADDR_MULTICAST))
 		fl6.flowi6_oif = np->mcast_oif;
 
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
@@ -355,18 +356,19 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
 		sin->sin6_port = serr->port;
-		sin->sin6_scope_id = 0;
 		if (skb->protocol == htons(ETH_P_IPV6)) {
 			const struct ipv6hdr *ip6h = container_of((struct in6_addr *)(nh + serr->addr_offset),
 								  struct ipv6hdr, daddr);
 			sin->sin6_addr = ip6h->daddr;
 			if (np->sndflow)
 				sin->sin6_flowinfo = ip6_flowinfo(ip6h);
-			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-				sin->sin6_scope_id = IP6CB(skb)->iif;
+			sin->sin6_scope_id =
+				ipv6_iface_scope_id(&sin->sin6_addr,
+						    IP6CB(skb)->iif);
 		} else {
 			ipv6_addr_set_v4mapped(*(__be32 *)(nh + serr->addr_offset),
 					       &sin->sin6_addr);
+			sin->sin6_scope_id = 0;
 		}
 	}
 
@@ -376,18 +378,19 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 	if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL) {
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
-		sin->sin6_scope_id = 0;
 		if (skb->protocol == htons(ETH_P_IPV6)) {
 			sin->sin6_addr = ipv6_hdr(skb)->saddr;
 			if (np->rxopt.all)
 				ip6_datagram_recv_ctl(sk, msg, skb);
-			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-				sin->sin6_scope_id = IP6CB(skb)->iif;
+			sin->sin6_scope_id =
+				ipv6_iface_scope_id(&sin->sin6_addr,
+						    IP6CB(skb)->iif);
 		} else {
 			struct inet_sock *inet = inet_sk(sk);
 
 			ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr,
 					       &sin->sin6_addr);
+			sin->sin6_scope_id = 0;
 			if (inet->cmsg_flags)
 				ip_cmsg_recv(msg, skb);
 		}
@@ -653,7 +656,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 					rcu_read_unlock();
 					return -ENODEV;
 				}
-			} else if (addr_props.type & IPV6_ADDR_LINKLOCAL) {
+			} else if (__ipv6_addr_needs_scope_id(addr_props)) {
 				rcu_read_unlock();
 				return -EINVAL;
 			}
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index fff5bdd..2a9e00e 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -394,7 +394,7 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	struct flowi6 fl6;
 	struct icmpv6_msg msg;
 	int iif = 0;
-	int addr_type = 0;
+	struct ipv6_addr_props addr_props;
 	int len;
 	int hlimit;
 	int err = 0;
@@ -409,8 +409,6 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	 *	Rule (e.1) is enforced by not using icmpv6_send
 	 *	in any code that processes icmp errors.
 	 */
-	addr_type = ipv6_addr_type(&hdr->daddr);
-
 	if (ipv6_chk_addr(net, &hdr->daddr, skb->dev, 0))
 		saddr = &hdr->daddr;
 
@@ -418,7 +416,8 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	 *	Dest addr check
 	 */
 
-	if ((addr_type & IPV6_ADDR_MULTICAST || skb->pkt_type != PACKET_HOST)) {
+	if (ipv6_addr_type(&hdr->daddr) & IPV6_ADDR_MULTICAST ||
+	    skb->pkt_type != PACKET_HOST) {
 		if (type != ICMPV6_PKT_TOOBIG &&
 		    !(type == ICMPV6_PARAMPROB &&
 		      code == ICMPV6_UNK_OPTION &&
@@ -428,13 +427,13 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 		saddr = NULL;
 	}
 
-	addr_type = ipv6_addr_type(&hdr->saddr);
+	addr_props = __ipv6_addr_props(&hdr->saddr);
 
 	/*
 	 *	Source addr check
 	 */
 
-	if (addr_type & IPV6_ADDR_LINKLOCAL)
+	if (__ipv6_addr_needs_scope_id(addr_props))
 		iif = skb->dev->ifindex;
 
 	/*
@@ -443,7 +442,8 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	 *	We check unspecified / multicast addresses here,
 	 *	and anycast addresses will be checked later.
 	 */
-	if ((addr_type == IPV6_ADDR_ANY) || (addr_type & IPV6_ADDR_MULTICAST)) {
+	if (addr_props.type == IPV6_ADDR_ANY ||
+	    addr_props.type & IPV6_ADDR_MULTICAST) {
 		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6_send: addr_any/mcast source\n");
 		return;
 	}
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
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 70fa814..04ff39d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -242,15 +242,15 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_in6 *addr = (struct sockaddr_in6 *) uaddr;
 	__be32 v4addr = 0;
-	int addr_type;
+	struct ipv6_addr_props addr_props;
 	int err;
 
 	if (addr_len < SIN6_LEN_RFC2133)
 		return -EINVAL;
-	addr_type = ipv6_addr_type(&addr->sin6_addr);
+	addr_props = __ipv6_addr_props(&addr->sin6_addr);
 
 	/* Raw sockets are IPv6 only */
-	if (addr_type == IPV6_ADDR_MAPPED)
+	if (addr_props.type == IPV6_ADDR_MAPPED)
 		return -EADDRNOTAVAIL;
 
 	lock_sock(sk);
@@ -261,10 +261,10 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	rcu_read_lock();
 	/* Check if the address belongs to the host. */
-	if (addr_type != IPV6_ADDR_ANY) {
+	if (addr_props.type != IPV6_ADDR_ANY) {
 		struct net_device *dev = NULL;
 
-		if (addr_type & IPV6_ADDR_LINKLOCAL) {
+		if (__ipv6_addr_needs_scope_id(addr_props)) {
 			if (addr_len >= sizeof(struct sockaddr_in6) &&
 			    addr->sin6_scope_id) {
 				/* Override any existing binding, if another
@@ -288,7 +288,7 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		 * unspecified and mapped address have a v4 equivalent.
 		 */
 		v4addr = LOOPBACK4_IPV6;
-		if (!(addr_type & IPV6_ADDR_MULTICAST))	{
+		if (!(addr_props.type & IPV6_ADDR_MULTICAST))	{
 			err = -EADDRNOTAVAIL;
 			if (!ipv6_chk_addr(sock_net(sk), &addr->sin6_addr,
 					   dev, 0)) {
@@ -299,7 +299,7 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	inet->inet_rcv_saddr = inet->inet_saddr = v4addr;
 	np->rcv_saddr = addr->sin6_addr;
-	if (!(addr_type & IPV6_ADDR_MULTICAST))
+	if (!(addr_props.type & IPV6_ADDR_MULTICAST))
 		np->saddr = addr->sin6_addr;
 	err = 0;
 out_unlock:
@@ -499,9 +499,8 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 		sin6->sin6_port = 0;
 		sin6->sin6_addr = ipv6_hdr(skb)->saddr;
 		sin6->sin6_flowinfo = 0;
-		sin6->sin6_scope_id = 0;
-		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-			sin6->sin6_scope_id = IP6CB(skb)->iif;
+		sin6->sin6_scope_id = ipv6_iface_scope_id(&sin6->sin6_addr,
+							  IP6CB(skb)->iif);
 	}
 
 	sock_recv_ts_and_drops(msg, sk, skb);
@@ -803,7 +802,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    sin6->sin6_scope_id &&
-		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
+		    __ipv6_addr_needs_scope_id(__ipv6_addr_props(daddr)))
 			fl6.flowi6_oif = sin6->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 599e1ba6..0b98698 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -450,15 +450,16 @@ try_again:
 		sin6->sin6_family = AF_INET6;
 		sin6->sin6_port = udp_hdr(skb)->source;
 		sin6->sin6_flowinfo = 0;
-		sin6->sin6_scope_id = 0;
 
-		if (is_udp4)
+		if (is_udp4) {
 			ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr,
 					       &sin6->sin6_addr);
-		else {
+			sin6->sin6_scope_id = 0;
+		} else {
 			sin6->sin6_addr = ipv6_hdr(skb)->saddr;
-			if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-				sin6->sin6_scope_id = IP6CB(skb)->iif;
+			sin6->sin6_scope_id =
+				ipv6_iface_scope_id(&sin6->sin6_addr,
+						    IP6CB(skb)->iif);
 		}
 
 	}
@@ -1118,7 +1119,8 @@ do_udp_sendmsg:
 
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    sin6->sin6_scope_id &&
-		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
+		    __ipv6_addr_needs_scope_id(
+			    __ipv6_addr_props(&sin6->sin6_addr)))
 			fl6.flowi6_oif = sin6->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
-- 
1.8.1.2
