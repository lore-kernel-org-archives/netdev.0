From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: no more dev_put() in inet6_bind()
Date: Mon, 02 Nov 2009 12:10:39 +0100
Message-ID: <4AEEBE2F.4020005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54314 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065AbZKBLKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 06:10:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoids touching device refcount in inet6_bind(), thanks to RCU

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/af_inet6.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index b6d0588..9105b25 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -314,6 +314,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		if (addr_type != IPV6_ADDR_ANY) {
 			struct net_device *dev = NULL;
 
+			rcu_read_lock();
 			if (addr_type & IPV6_ADDR_LINKLOCAL) {
 				if (addr_len >= sizeof(struct sockaddr_in6) &&
 				    addr->sin6_scope_id) {
@@ -326,12 +327,12 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 				/* Binding to link-local address requires an interface */
 				if (!sk->sk_bound_dev_if) {
 					err = -EINVAL;
-					goto out;
+					goto out_unlock;
 				}
-				dev = dev_get_by_index(net, sk->sk_bound_dev_if);
+				dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
 				if (!dev) {
 					err = -ENODEV;
-					goto out;
+					goto out_unlock;
 				}
 			}
 
@@ -342,14 +343,11 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
 				if (!ipv6_chk_addr(net, &addr->sin6_addr,
 						   dev, 0)) {
-					if (dev)
-						dev_put(dev);
 					err = -EADDRNOTAVAIL;
-					goto out;
+					goto out_unlock;
 				}
 			}
-			if (dev)
-				dev_put(dev);
+			rcu_read_unlock();
 		}
 	}
 
@@ -381,6 +379,9 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 out:
 	release_sock(sk);
 	return err;
+out_unlock:
+	rcu_read_unlock();
+	goto out;
 }
 
 EXPORT_SYMBOL(inet6_bind);
