From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 6/6] vxlan: Fix double free of skb.
Date: Tue, 23 Dec 2014 16:20:36 -0800
Message-ID: <1419380436-1695-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:50561 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755294AbaLXAUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 19:20:38 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so8842936pdb.10
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 16:20:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of error vxlan_xmit_one() can free already freed skb.
Also fixes memory leak of dst-entry.

Fixes: acbf74a7630 ("vxlan: Refactor vxlan driver to make use
of the common UDP tunnel functions").

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   34 ++++++++++++++++++++++++----------
 1 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 49d9f22..7fbd89f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1579,8 +1579,10 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	bool udp_sum = !udp_get_no_check6_tx(vs->sock->sk);
 
 	skb = udp_tunnel_handle_offloads(skb, udp_sum);
-	if (IS_ERR(skb))
-		return -EINVAL;
+	if (IS_ERR(skb)) {
+		err = -EINVAL;
+		goto err;
+	}
 
 	skb_scrub_packet(skb, xnet);
 
@@ -1590,12 +1592,16 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 
 	/* Need space for new headers (invalidates iph ptr) */
 	err = skb_cow_head(skb, min_headroom);
-	if (unlikely(err))
-		return err;
+	if (unlikely(err)) {
+		kfree_skb(skb);
+		goto err;
+	}
 
 	skb = vlan_hwaccel_push_inside(skb);
-	if (WARN_ON(!skb))
-		return -ENOMEM;
+	if (WARN_ON(!skb)) {
+		err = -ENOMEM;
+		goto err;
+	}
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
@@ -1606,6 +1612,9 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	udp_tunnel6_xmit_skb(vs->sock, dst, skb, dev, saddr, daddr, prio,
 			     ttl, src_port, dst_port);
 	return 0;
+err:
+	dst_release(dst);
+	return err;
 }
 #endif
 
@@ -1621,7 +1630,7 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 
 	skb = udp_tunnel_handle_offloads(skb, udp_sum);
 	if (IS_ERR(skb))
-		return -EINVAL;
+		return PTR_ERR(skb);
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ VXLAN_HLEN + sizeof(struct iphdr)
@@ -1629,8 +1638,10 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 
 	/* Need space for new headers (invalidates iph ptr) */
 	err = skb_cow_head(skb, min_headroom);
-	if (unlikely(err))
+	if (unlikely(err)) {
+		kfree_skb(skb);
 		return err;
+	}
 
 	skb = vlan_hwaccel_push_inside(skb);
 	if (WARN_ON(!skb))
@@ -1776,9 +1787,12 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				     tos, ttl, df, src_port, dst_port,
 				     htonl(vni << 8),
 				     !net_eq(vxlan->net, dev_net(vxlan->dev)));
-
-		if (err < 0)
+		if (err < 0) {
+			/* skb is already freed. */
+			skb = NULL;
 			goto rt_tx_error;
+		}
+
 		iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
-- 
1.7.1
