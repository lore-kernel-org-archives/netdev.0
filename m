From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v6 5/8] vxlan: Factor out vxlan send api.
Date: Thu,  1 Aug 2013 11:44:59 -0700
Message-ID: <1375382699-3305-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:49227 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756334Ab3HASpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 14:45:03 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp13so2440852pab.7
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 11:45:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch allows more code sharing between vxlan and ovs-vxlan.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v1-v2:
 - revert back to original names.
---
 drivers/net/vxlan.c |   91 ++++++++++++++++++++++++++++++---------------------
 include/net/vxlan.h |    8 ++++
 2 files changed, 62 insertions(+), 37 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 67a4716..55f4e4b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1060,11 +1060,8 @@ static void vxlan_sock_put(struct sk_buff *skb)
 }
 
 /* On transmit, associate with the tunnel socket */
-static void vxlan_set_owner(struct net_device *dev, struct sk_buff *skb)
+static void vxlan_set_owner(struct sock *sk, struct sk_buff *skb)
 {
-	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct sock *sk = vxlan->vn_sock->sock->sk;
-
 	skb_orphan(skb);
 	sock_hold(sk);
 	skb->sk = sk;
@@ -1076,9 +1073,9 @@ static void vxlan_set_owner(struct net_device *dev, struct sk_buff *skb)
  *     better and maybe available from hardware
  *   secondary choice is to use jhash on the Ethernet header
  */
-static __be16 vxlan_src_port(const struct vxlan_dev *vxlan, struct sk_buff *skb)
+__be16 vxlan_src_port(__u16 port_min, __u16 port_max, struct sk_buff *skb)
 {
-	unsigned int range = (vxlan->port_max - vxlan->port_min) + 1;
+	unsigned int range = (port_max - port_min) + 1;
 	u32 hash;
 
 	hash = skb_get_rxhash(skb);
@@ -1086,8 +1083,9 @@ static __be16 vxlan_src_port(const struct vxlan_dev *vxlan, struct sk_buff *skb)
 		hash = jhash(skb->data, 2 * ETH_ALEN,
 			     (__force u32) skb->protocol);
 
-	return htons((((u64) hash * range) >> 32) + vxlan->port_min);
+	return htons((((u64) hash * range) >> 32) + port_min);
 }
+EXPORT_SYMBOL_GPL(vxlan_src_port);
 
 static int handle_offloads(struct sk_buff *skb)
 {
@@ -1103,6 +1101,45 @@ static int handle_offloads(struct sk_buff *skb)
 	return 0;
 }
 
+int vxlan_xmit_skb(struct net *net, struct vxlan_sock *vs,
+		   struct rtable *rt, struct sk_buff *skb,
+		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
+		   __be16 src_port, __be16 dst_port, __be32 vni)
+{
+	struct vxlanhdr *vxh;
+	struct udphdr *uh;
+	int err;
+
+	if (!skb->encapsulation) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+
+	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
+	vxh->vx_flags = htonl(VXLAN_FLAGS);
+	vxh->vx_vni = vni;
+
+	__skb_push(skb, sizeof(*uh));
+	skb_reset_transport_header(skb);
+	uh = udp_hdr(skb);
+
+	uh->dest = dst_port;
+	uh->source = src_port;
+
+	uh->len = htons(skb->len);
+	uh->check = 0;
+
+	vxlan_set_owner(vs->sock->sk, skb);
+
+	err = handle_offloads(skb);
+	if (err)
+		return err;
+
+	return iptunnel_xmit(net, rt, skb, src, dst,
+			IPPROTO_UDP, tos, ttl, df);
+}
+EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
+
 /* Bypass encapsulation if the destination is local */
 static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 			       struct vxlan_dev *dst_vxlan)
@@ -1140,8 +1177,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct rtable *rt;
 	const struct iphdr *old_iph;
-	struct vxlanhdr *vxh;
-	struct udphdr *uh;
 	struct flowi4 fl4;
 	__be32 dst;
 	__be16 src_port, dst_port;
@@ -1163,11 +1198,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 	}
 
-	if (!skb->encapsulation) {
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
-	}
-
 	/* Need space for new headers (invalidates iph ptr) */
 	if (skb_cow_head(skb, VXLAN_HEADROOM))
 		goto drop;
@@ -1182,7 +1212,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	if (tos == 1)
 		tos = ip_tunnel_get_dsfield(old_iph, skb);
 
-	src_port = vxlan_src_port(vxlan, skb);
+	src_port = vxlan_src_port(vxlan->port_min, vxlan->port_max, skb);
 
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.flowi4_oif = rdst->remote_ifindex;
@@ -1199,9 +1229,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	if (rt->dst.dev == dev) {
 		netdev_dbg(dev, "circular route to %pI4\n", &dst);
-		ip_rt_put(rt);
 		dev->stats.collisions++;
-		goto tx_error;
+		goto rt_tx_error;
 	}
 
 	/* Bypass encapsulation if the destination is local */
@@ -1216,30 +1245,16 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		vxlan_encap_bypass(skb, vxlan, dst_vxlan);
 		return;
 	}
-	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
-	vxh->vx_flags = htonl(VXLAN_FLAGS);
-	vxh->vx_vni = htonl(vni << 8);
-
-	__skb_push(skb, sizeof(*uh));
-	skb_reset_transport_header(skb);
-	uh = udp_hdr(skb);
-
-	uh->dest = dst_port;
-	uh->source = src_port;
-
-	uh->len = htons(skb->len);
-	uh->check = 0;
-
-	vxlan_set_owner(dev, skb);
-
-	if (handle_offloads(skb))
-		goto drop;
 
 	tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 	ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 
-	err = iptunnel_xmit(dev_net(dev), rt, skb, fl4.saddr, dst,
-			    IPPROTO_UDP, tos, ttl, df);
+	err = vxlan_xmit_skb(dev_net(dev), vxlan->vn_sock, rt, skb,
+			     fl4.saddr, dst, tos, ttl, df,
+			     src_port, dst_port, htonl(vni << 8));
+
+	if (err < 0)
+		goto rt_tx_error;
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 
 	return;
@@ -1248,6 +1263,8 @@ drop:
 	dev->stats.tx_dropped++;
 	goto tx_free;
 
+rt_tx_error:
+	ip_rt_put(rt);
 tx_error:
 	dev->stats.tx_errors++;
 tx_free:
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 43de275..ad342e3 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -28,4 +28,12 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  bool no_share);
 
 void vxlan_sock_release(struct vxlan_sock *vs);
+
+int vxlan_xmit_skb(struct net *net, struct vxlan_sock *vs,
+		   struct rtable *rt, struct sk_buff *skb,
+		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
+		   __be16 src_port, __be16 dst_port, __be32 vni);
+
+__be16 vxlan_src_port(__u16 port_min, __u16 port_max, struct sk_buff *skb);
+
 #endif
-- 
1.7.1
