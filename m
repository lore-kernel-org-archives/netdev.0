From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ip6tnl: less dev_put() calls
Date: Mon, 02 Nov 2009 11:21:37 +0100
Message-ID: <4AEEB2B1.9070302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48982 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754130AbZKBKVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 05:21:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using dev_get_by_index_rcu() in ip6_tnl_rcv_ctl() & ip6_tnl_xmit_ctl()
avoids touching device refcount.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/ip6_tunnel.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 6c1b5c9..1d61411 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -658,6 +658,7 @@ static void ip6ip6_dscp_ecn_decapsulate(struct ip6_tnl *t,
 		IP6_ECN_set_ce(ipv6_hdr(skb));
 }
 
+/* called with rcu_read_lock() */
 static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t)
 {
 	struct ip6_tnl_parm *p = &t->parms;
@@ -668,15 +669,13 @@ static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t)
 		struct net_device *ldev = NULL;
 
 		if (p->link)
-			ldev = dev_get_by_index(net, p->link);
+			ldev = dev_get_by_index_rcu(net, p->link);
 
 		if ((ipv6_addr_is_multicast(&p->laddr) ||
 		     likely(ipv6_chk_addr(net, &p->laddr, ldev, 0))) &&
 		    likely(!ipv6_chk_addr(net, &p->raddr, NULL, 0)))
 			ret = 1;
 
-		if (ldev)
-			dev_put(ldev);
 	}
 	return ret;
 }
@@ -804,8 +803,9 @@ static inline int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
 	if (p->flags & IP6_TNL_F_CAP_XMIT) {
 		struct net_device *ldev = NULL;
 
+		rcu_read_lock();
 		if (p->link)
-			ldev = dev_get_by_index(net, p->link);
+			ldev = dev_get_by_index_rcu(net, p->link);
 
 		if (unlikely(!ipv6_chk_addr(net, &p->laddr, ldev, 0)))
 			printk(KERN_WARNING
@@ -819,8 +819,7 @@ static inline int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
 			       p->name);
 		else
 			ret = 1;
-		if (ldev)
-			dev_put(ldev);
+		rcu_read_unlock();
 	}
 	return ret;
 }
