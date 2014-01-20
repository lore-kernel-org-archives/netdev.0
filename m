From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: protect protocols not handling ipv4 from v4 connection/bind attempts
Date: Mon, 20 Jan 2014 05:16:39 +0100
Message-ID: <20140120041639.GA27055@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50655 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825AbaATEQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 23:16:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some ipv6 protocols cannot handle ipv4 addresses, so we must not allow
connecting and binding to them. sendmsg logic does already check msg->name
for this but must trust already connected sockets which could be set up
for connection to ipv4 address family.

Per-socket flag ipv6only is of no use here, as it is under users control
by setsockopt.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ipv6.h  |  2 ++
 net/ipv4/ping.c     |  3 +++
 net/ipv6/datagram.c | 10 ++++++++++
 net/ipv6/ping.c     |  2 +-
 net/ipv6/raw.c      |  6 +++++-
 net/l2tp/l2tp_ip6.c |  3 +++
 6 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 6d80f51..5b0f1d2 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -782,6 +782,8 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			   char __user *optval, int __user *optlen);
 
 int ip6_datagram_connect(struct sock *sk, struct sockaddr *addr, int addr_len);
+int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *addr,
+				 int addr_len);
 
 int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len,
 		    int *addr_len);
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index e09e883..ba59d6f 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -320,6 +320,9 @@ static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
 		if (addr_len < sizeof(*addr))
 			return -EINVAL;
 
+		if (addr->sin6_family != AF_INET6)
+			return -EINVAL;
+
 		pr_debug("ping_check_bind_addr(sk=%p,addr=%pI6c,port=%d)\n",
 			 sk, addr->sin6_addr.s6_addr, ntohs(addr->sin6_port));
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index bce73cb..86c705f 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -205,6 +205,16 @@ out:
 }
 EXPORT_SYMBOL_GPL(ip6_datagram_connect);
 
+int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *uaddr,
+				 int addr_len)
+{
+	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, uaddr);
+	if (sin6->sin6_family != AF_INET6)
+		return -EAFNOSUPPORT;
+	return ip6_datagram_connect(sk, uaddr, addr_len);
+}
+EXPORT_SYMBOL_GPL(ip6_datagram_connect_v6_only);
+
 void ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err,
 		     __be16 port, u32 info, u8 *payload)
 {
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index cd71f3a..b19214e 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -31,7 +31,7 @@ struct proto pingv6_prot = {
 	.owner =	THIS_MODULE,
 	.init =		ping_init_sock,
 	.close =	ping_close,
-	.connect =	ip6_datagram_connect,
+	.connect =	ip6_datagram_connect_v6_only,
 	.disconnect =	udp_disconnect,
 	.setsockopt =	ipv6_setsockopt,
 	.getsockopt =	ipv6_getsockopt,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index b452311..1f29996 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -250,6 +250,10 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	if (addr_len < SIN6_LEN_RFC2133)
 		return -EINVAL;
+
+	if (addr->sin6_family != AF_INET6)
+		return -EINVAL;
+
 	addr_type = ipv6_addr_type(&addr->sin6_addr);
 
 	/* Raw sockets are IPv6 only */
@@ -1209,7 +1213,7 @@ struct proto rawv6_prot = {
 	.owner		   = THIS_MODULE,
 	.close		   = rawv6_close,
 	.destroy	   = raw6_destroy,
-	.connect	   = ip6_datagram_connect,
+	.connect	   = ip6_datagram_connect_v6_only,
 	.disconnect	   = udp_disconnect,
 	.ioctl		   = rawv6_ioctl,
 	.init		   = rawv6_init_sk,
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index aab5f74..7704ea9 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -371,6 +371,9 @@ static int l2tp_ip6_connect(struct sock *sk, struct sockaddr *uaddr,
 	if (addr_len < sizeof(*lsa))
 		return -EINVAL;
 
+	if (usin->sin6_family != AF_INET6)
+		return -EINVAL;
+
 	addr_type = ipv6_addr_type(&usin->sin6_addr);
 	if (addr_type & IPV6_ADDR_MULTICAST)
 		return -EINVAL;
-- 
1.8.4.2
