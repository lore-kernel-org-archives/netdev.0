From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/5] ipv6: Remove neigh argument from ndisc_send_redirect()
Date: Fri, 27 Jan 2012 21:03:45 -0500 (EST)
Message-ID: <20120127.210345.2194276401441397560.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418Ab2A1CDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 21:03:47 -0500
Received: from localhost (cpe-66-65-56-15.nyc.res.rr.com [66.65.56.15])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q0S23kKX009909
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 18:03:47 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead, compute it as-needed inside of that function using
dst_neigh_lookup().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ndisc.h   |    1 -
 net/ipv6/ip6_output.c |    2 +-
 net/ipv6/ndisc.c      |   12 ++++++++++--
 3 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index e3133c2..6f9c25a 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -133,7 +133,6 @@ extern void			ndisc_send_rs(struct net_device *dev,
 					      const struct in6_addr *daddr);
 
 extern void			ndisc_send_redirect(struct sk_buff *skb,
-						    struct neighbour *neigh,
 						    const struct in6_addr *target);
 
 extern int			ndisc_mc_map(const struct in6_addr *addr, char *buf,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d97e071..604809b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -486,7 +486,7 @@ int ip6_forward(struct sk_buff *skb)
 		   and by source (inside ndisc_send_redirect)
 		 */
 		if (inet_peer_xrlim_allow(rt->rt6i_peer, 1*HZ))
-			ndisc_send_redirect(skb, n, target);
+			ndisc_send_redirect(skb, target);
 	} else {
 		int addrtype = ipv6_addr_type(&hdr->saddr);
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index c574ebc..8d81701 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1512,8 +1512,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	}
 }
 
-void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
-			 const struct in6_addr *target)
+void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 {
 	struct net_device *dev = skb->dev;
 	struct net *net = dev_net(dev);
@@ -1571,6 +1570,13 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 		goto release;
 
 	if (dev->addr_len) {
+		struct neighbour *neigh = dst_neigh_lookup(skb_dst(skb), target);
+		if (!neigh) {
+			ND_PRINTK2(KERN_WARNING
+				   "ICMPv6 Redirect: no neigh for target address\n");
+			goto release;
+		}
+
 		read_lock_bh(&neigh->lock);
 		if (neigh->nud_state & NUD_VALID) {
 			memcpy(ha_buf, neigh->ha, dev->addr_len);
@@ -1579,6 +1585,8 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 			len += ndisc_opt_addr_space(dev);
 		} else
 			read_unlock_bh(&neigh->lock);
+
+		neigh_release(neigh);
 	}
 
 	rd_len = min_t(unsigned int,
-- 
1.7.7.5
