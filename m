From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: no more dev_put() in datagram_send_ctl()
Date: Mon, 02 Nov 2009 12:21:06 +0100
Message-ID: <4AEEC0A2.1070502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41521 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754638AbZKBLVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 06:21:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoids touching device refcount in datagram_send_ctl(), thanks to RCU

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/datagram.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 9f70452..e6f9cdf 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -537,12 +537,17 @@ int datagram_send_ctl(struct net *net,
 
 			addr_type = __ipv6_addr_type(&src_info->ipi6_addr);
 
+			rcu_read_lock();
 			if (fl->oif) {
-				dev = dev_get_by_index(net, fl->oif);
-				if (!dev)
+				dev = dev_get_by_index_rcu(net, fl->oif);
+				if (!dev) {
+					rcu_read_unlock();
 					return -ENODEV;
-			} else if (addr_type & IPV6_ADDR_LINKLOCAL)
+				}
+			} else if (addr_type & IPV6_ADDR_LINKLOCAL) {
+				rcu_read_unlock();
 				return -EINVAL;
+			}
 
 			if (addr_type != IPV6_ADDR_ANY) {
 				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
@@ -553,8 +558,7 @@ int datagram_send_ctl(struct net *net,
 					ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
 			}
 
-			if (dev)
-				dev_put(dev);
+			rcu_read_unlock();
 
 			if (err)
 				goto exit_f;
