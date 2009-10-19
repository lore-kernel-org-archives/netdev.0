From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: Fix IP_MULTICAST_IF
Date: Mon, 19 Oct 2009 18:41:58 +0200
Message-ID: <4ADC96D6.4000909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48417 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448AbZJSQl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 12:41:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv4/ipv6 setsockopt(IP_MULTICAST_IF) have dubious __dev_get_by_index() calls.

This function should be called only with RTNL or dev_base_lock held, or reader
could see a corrupt hash chain and eventually enter an endless loop.

Fix is to call dev_get_by_index()/dev_put().

If this happens to be performance critical, we could define a new dev_exist_by_index()
function to avoid touching dev refcount.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_sockglue.c   |    7 +++----
 net/ipv6/ipv6_sockglue.c |    6 +++++-
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 0c0b6e3..e982b5c 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -634,17 +634,16 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 				break;
 			}
 			dev = ip_dev_find(sock_net(sk), mreq.imr_address.s_addr);
-			if (dev) {
+			if (dev)
 				mreq.imr_ifindex = dev->ifindex;
-				dev_put(dev);
-			}
 		} else
-			dev = __dev_get_by_index(sock_net(sk), mreq.imr_ifindex);
+			dev = dev_get_by_index(sock_net(sk), mreq.imr_ifindex);
 
 
 		err = -EADDRNOTAVAIL;
 		if (!dev)
 			break;
+		dev_put(dev);
 
 		err = -EINVAL;
 		if (sk->sk_bound_dev_if &&
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 14f54eb..4f7aaf6 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -496,13 +496,17 @@ done:
 			goto e_inval;
 
 		if (val) {
+			struct net_device *dev;
+
 			if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != val)
 				goto e_inval;
 
-			if (__dev_get_by_index(net, val) == NULL) {
+			dev = dev_get_by_index(net, val);
+			if (!dev) {
 				retv = -ENODEV;
 				break;
 			}
+			dev_put(dev);
 		}
 		np->mcast_oif = val;
 		retv = 0;
