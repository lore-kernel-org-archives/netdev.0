From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next 2/7] vxlan: simplify exception handling
Date: Fri,  4 Nov 2016 13:51:51 -0700
Message-ID: <1478292716-54649-3-git-send-email-pshelar@ovn.org>
References: <1478292716-54649-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:38162 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758838AbcKDUwD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 16:52:03 -0400
In-Reply-To: <1478292716-54649-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan egress path error handling has became complicated, it
need to handle IPv4 and IPv6 tunnel cases.
Earlier patch removes vlan handling from vxlan_build_skb(), so
vxlan_build_skb does not need to free skb and we can simplify
the xmit path by having single error handling for both type of
tunnels.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/vxlan.c | 28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 756d826..a1e707f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1789,7 +1789,7 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 	return 0;
 
 out_free:
-	kfree_skb(skb);
+	dst_release(dst);
 	return err;
 }
 
@@ -1927,7 +1927,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct ip_tunnel_info *info;
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct sock *sk;
-	struct rtable *rt = NULL;
 	const struct iphdr *old_iph;
 	union vxlan_addr *dst;
 	union vxlan_addr remote_ip, local_ip;
@@ -2009,6 +2008,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	if (dst->sa.sa_family == AF_INET) {
 		struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
+		struct rtable *rt;
 
 		if (!sock4)
 			goto drop;
@@ -2030,7 +2030,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			netdev_dbg(dev, "circular route to %pI4\n",
 				   &dst->sin.sin_addr.s_addr);
 			dev->stats.collisions++;
-			goto rt_tx_error;
+			ip_rt_put(rt);
+			goto tx_error;
 		}
 
 		/* Bypass encapsulation if the destination is local */
@@ -2058,7 +2059,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		err = vxlan_build_skb(skb, &rt->dst, sizeof(struct iphdr),
 				      vni, md, flags, udp_sum);
 		if (err < 0)
-			goto xmit_tx_error;
+			goto tx_error;
 
 		udp_tunnel_xmit_skb(rt, sk, skb, src->sin.sin_addr.s_addr,
 				    dst->sin.sin_addr.s_addr, tos, ttl, df,
@@ -2117,11 +2118,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		skb_scrub_packet(skb, xnet);
 		err = vxlan_build_skb(skb, ndst, sizeof(struct ipv6hdr),
 				      vni, md, flags, udp_sum);
-		if (err < 0) {
-			dst_release(ndst);
-			dev->stats.tx_errors++;
-			return;
-		}
+		if (err < 0)
+			goto tx_error;
+
 		udp_tunnel6_xmit_skb(ndst, sk, skb, dev,
 				     &src->sin6.sin6_addr,
 				     &dst->sin6.sin6_addr, tos, ttl,
@@ -2133,17 +2132,12 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 drop:
 	dev->stats.tx_dropped++;
-	goto tx_free;
+	dev_kfree_skb(skb);
+	return;
 
-xmit_tx_error:
-	/* skb is already freed. */
-	skb = NULL;
-rt_tx_error:
-	ip_rt_put(rt);
 tx_error:
 	dev->stats.tx_errors++;
-tx_free:
-	dev_kfree_skb(skb);
+	kfree_skb(skb);
 }
 
 /* Transmit local packets over Vxlan
-- 
1.9.1
