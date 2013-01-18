From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC PATCH 2/3] ipv4: Add a socket release callback for datagram
 sockets
Date: Fri, 18 Jan 2013 09:15:14 +0100
Message-ID: <20130118081514.GD24987@secunet.com>
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
Received: from a.mx.secunet.com ([195.81.216.161]:44929 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761Ab3ARIPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 03:15:17 -0500
Content-Disposition: inline
In-Reply-To: <20130118081145.GB24987@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements a socket release callback function to check
if the socket cached route got invalid during the time
we owned the socket. The function is used from udp, raw
and ping sockets.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/ip.h    |    2 ++
 net/ipv4/datagram.c |   25 +++++++++++++++++++++++++
 net/ipv4/ping.c     |    1 +
 net/ipv4/raw.c      |    1 +
 net/ipv4/udp.c      |    1 +
 5 files changed, 30 insertions(+)

diff --git a/include/net/ip.h b/include/net/ip.h
index 0707fb9..a68f838 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -143,6 +143,8 @@ static inline struct sk_buff *ip_finish_skb(struct sock *sk, struct flowi4 *fl4)
 extern int		ip4_datagram_connect(struct sock *sk, 
 					     struct sockaddr *uaddr, int addr_len);
 
+extern void ip4_datagram_release_cb(struct sock *sk);
+
 struct ip_reply_arg {
 	struct kvec iov[1];   
 	int	    flags;
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 424fafb..b28e863 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -85,3 +85,28 @@ out:
 	return err;
 }
 EXPORT_SYMBOL(ip4_datagram_connect);
+
+void ip4_datagram_release_cb(struct sock *sk)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+	const struct ip_options_rcu *inet_opt;
+	__be32 daddr = inet->inet_daddr;
+	struct flowi4 fl4;
+	struct rtable *rt;
+
+	if (! __sk_dst_get(sk) || __sk_dst_check(sk, 0))
+		return;
+
+	rcu_read_lock();
+	inet_opt = rcu_dereference(inet->inet_opt);
+	if (inet_opt && inet_opt->opt.srr)
+		daddr = inet_opt->opt.faddr;
+	rt = ip_route_output_ports(sock_net(sk), &fl4, sk, daddr,
+				   inet->inet_saddr, inet->inet_dport,
+				   inet->inet_sport, sk->sk_protocol,
+				   RT_CONN_FLAGS(sk), sk->sk_bound_dev_if);
+	if (!IS_ERR(rt))
+		__sk_dst_set(sk, &rt->dst);
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(ip4_datagram_release_cb);
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 8f3d054..6f9c072 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -738,6 +738,7 @@ struct proto ping_prot = {
 	.recvmsg =	ping_recvmsg,
 	.bind =		ping_bind,
 	.backlog_rcv =	ping_queue_rcv_skb,
+	.release_cb =	ip4_datagram_release_cb,
 	.hash =		ping_v4_hash,
 	.unhash =	ping_v4_unhash,
 	.get_port =	ping_v4_get_port,
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 73d1e4d..6f08991 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -894,6 +894,7 @@ struct proto raw_prot = {
 	.recvmsg	   = raw_recvmsg,
 	.bind		   = raw_bind,
 	.backlog_rcv	   = raw_rcv_skb,
+	.release_cb	   = ip4_datagram_release_cb,
 	.hash		   = raw_hash_sk,
 	.unhash		   = raw_unhash_sk,
 	.obj_size	   = sizeof(struct raw_sock),
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 79c8dbe..1f4d405 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1952,6 +1952,7 @@ struct proto udp_prot = {
 	.recvmsg	   = udp_recvmsg,
 	.sendpage	   = udp_sendpage,
 	.backlog_rcv	   = __udp_queue_rcv_skb,
+	.release_cb	   = ip4_datagram_release_cb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.rehash		   = udp_v4_rehash,
-- 
1.7.9.5
