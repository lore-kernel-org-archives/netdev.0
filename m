From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next2.6] ipv6: avoid dev_hold()/dev_put() in rawv6_bind()
Date: Fri, 06 Nov 2009 11:53:22 +0100
Message-ID: <4AF40022.6050100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40097 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756413AbZKFKxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 05:53:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using RCU helps not touching device refcount in rawv6_bind()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/raw.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 818ef21..80f356a 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -249,7 +249,7 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	/* Raw sockets are IPv6 only */
 	if (addr_type == IPV6_ADDR_MAPPED)
-		return(-EADDRNOTAVAIL);
+		return -EADDRNOTAVAIL;
 
 	lock_sock(sk);
 
@@ -257,6 +257,7 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (sk->sk_state != TCP_CLOSE)
 		goto out;
 
+	rcu_read_unlock();
 	/* Check if the address belongs to the host. */
 	if (addr_type != IPV6_ADDR_ANY) {
 		struct net_device *dev = NULL;
@@ -272,13 +273,13 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 			/* Binding to link-local address requires an interface */
 			if (!sk->sk_bound_dev_if)
-				goto out;
+				goto out_unlock;
 
-			dev = dev_get_by_index(sock_net(sk), sk->sk_bound_dev_if);
-			if (!dev) {
-				err = -ENODEV;
-				goto out;
-			}
+			err = -ENODEV;
+			dev = dev_get_by_index_rcu(sock_net(sk),
+						   sk->sk_bound_dev_if);
+			if (!dev)
+				goto out_unlock;
 		}
 
 		/* ipv4 addr of the socket is invalid.  Only the
@@ -289,13 +290,9 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 			err = -EADDRNOTAVAIL;
 			if (!ipv6_chk_addr(sock_net(sk), &addr->sin6_addr,
 					   dev, 0)) {
-				if (dev)
-					dev_put(dev);
-				goto out;
+				goto out_unlock;
 			}
 		}
-		if (dev)
-			dev_put(dev);
 	}
 
 	inet->inet_rcv_saddr = inet->inet_saddr = v4addr;
@@ -303,6 +300,8 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (!(addr_type & IPV6_ADDR_MULTICAST))
 		ipv6_addr_copy(&np->saddr, &addr->sin6_addr);
 	err = 0;
+out_unlock:
+	rcu_read_unlock();
 out:
 	release_sock(sk);
 	return err;
