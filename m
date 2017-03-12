From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 24/27] afnetns: check afnetns user_ns in inet6_bind
Date: Mon, 13 Mar 2017 00:01:48 +0100
Message-ID: <20170312230151.5185-25-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39113 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935571AbdCLXCc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:32 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 9029220791
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:15 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 0ED41240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:14 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/af_inet6.c | 40 ++++++++++++++++++++++++++++++++--------
 1 file changed, 32 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 30aff01eba5be0..4aa221826e753c 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -273,6 +273,26 @@ static int inet6_create(struct net *net, struct socket *sock, int protocol,
 	goto out;
 }
 
+static int inet6_allow_bind(struct net *net, struct in6_addr *addr,
+			    unsigned short snum, struct net_device *dev)
+{
+	struct user_namespace *user_ns;
+#if IS_ENABLED(CONFIG_AFNETNS)
+	struct afnetns *afnetns;
+
+	afnetns = ipv6_get_ifaddr_afnetns_rcu(net, addr, dev);
+	user_ns = afnetns ? afnetns->user_ns : net->user_ns;
+#else
+	user_ns = net->user_ns;
+#endif
+
+	if (snum && snum < inet_prot_sock(net) &&
+	    !ns_capable(user_ns, CAP_NET_BIND_SERVICE))
+		return -EADDRNOTAVAIL;
+
+	return 0;
+}
+
 
 /* bind for INET6 API */
 int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
@@ -301,11 +321,6 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if ((addr_type & IPV6_ADDR_MULTICAST) && sock->type == SOCK_STREAM)
 		return -EINVAL;
 
-	snum = ntohs(addr->sin6_port);
-	if (snum && snum < inet_prot_sock(net) &&
-	    !ns_capable(net->user_ns, CAP_NET_BIND_SERVICE))
-		return -EACCES;
-
 	lock_sock(sk);
 
 	/* Check these errors (active socket, double bind). */
@@ -314,6 +329,8 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	}
 
+	snum = ntohs(addr->sin6_port);
+
 	/* Check if the address belongs to the host. */
 	if (addr_type == IPV6_ADDR_MAPPED) {
 		/* Binding to v4-mapped address on a v6-only socket
@@ -330,10 +347,12 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		else
 			err = 0;
 	} else {
+		struct net_device *dev = NULL;
+
+		rcu_read_lock();
+
 		if (addr_type != IPV6_ADDR_ANY) {
-			struct net_device *dev = NULL;
 
-			rcu_read_lock();
 			if (__ipv6_addr_needs_scope_id(addr_type)) {
 				if (addr_len >= sizeof(struct sockaddr_in6) &&
 				    addr->sin6_scope_id) {
@@ -371,8 +390,13 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 					goto out_unlock;
 				}
 			}
-			rcu_read_unlock();
 		}
+
+		err = inet6_allow_bind(net, &addr->sin6_addr, snum, dev);
+		if (err)
+			goto out_unlock;
+
+		rcu_read_unlock();
 	}
 
 	inet->inet_rcv_saddr = v4addr;
-- 
2.9.3
