From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v3 3/6] vxlan: Factor out vxlan send api.
Date: Wed, 24 Jul 2013 11:00:42 -0700
Message-ID: <1374688842-14313-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:60107 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752788Ab3GXSAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 14:00:45 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp16so10064445pbb.0
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 11:00:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch allows more code sharing between vxlan and ovs-vxlan.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v1-v2:
 - revert back to original names.
---
 drivers/net/vxlan.c |   91 ++++++++++++++++++++++++++++++---------------------
 include/net/vxlan.h |    7 ++++
 2 files changed, 61 insertions(+), 37 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9deb86e..f9364d2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1019,11 +1019,8 @@ static void vxlan_sock_put(struct sk_buff *skb)
 }
 
 /* On transmit, associate with the tunnel socket */
-static void vxlan_set_owner(struct net_device *dev, struct sk_buff *skb)
+static void vxlan_set_owner(struct sock *sk, struct sk_buff *skb)
 {
-	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct sock *sk = vxlan->vh->vs->sock->sk;
-
 	skb_orphan(skb);
 	sock_hold(sk);
 	skb->sk = sk;
@@ -1035,9 +1032,9 @@ static void vxlan_set_owner(struct net_device *dev, struct sk_buff *skb)
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
@@ -1045,8 +1042,9 @@ static __be16 vxlan_src_port(const struct vxlan_dev *vxlan, struct sk_buff *skb)
 		hash = jhash(skb->data, 2 * ETH_ALEN,
 			     (__force u32) skb->protocol);
 
-	return htons((((u64) hash * range) >> 32) + vxlan->port_min);
+	return htons((((u64) hash * range) >> 32) + port_min);
 }
+EXPORT_SYMBOL_GPL(vxlan_src_port);
 
 static int handle_offloads(struct sk_buff *skb)
 {
@@ -1062,6 +1060,45 @@ static int handle_offloads(struct sk_buff *skb)
 	return 0;
 }
 
+int vxlan_xmit_skb(struct net *net, struct vxlan_handler *vh,
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
+	vxlan_set_owner(vh->vs->sock->sk, skb);
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
@@ -1099,8 +1136,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct rtable *rt;
 	const struct iphdr *old_iph;
-	struct vxlanhdr *vxh;
-	struct udphdr *uh;
 	struct flowi4 fl4;
 	__be32 dst;
 	__be16 src_port, dst_port;
@@ -1122,11 +1157,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
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
@@ -1141,7 +1171,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	if (tos == 1)
 		tos = ip_tunnel_get_dsfield(old_iph, skb);
 
-	src_port = vxlan_src_port(vxlan, skb);
+	src_port = vxlan_src_port(vxlan->port_min, vxlan->port_max, skb);
 
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.flowi4_oif = rdst->remote_ifindex;
@@ -1158,9 +1188,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	if (rt->dst.dev == dev) {
 		netdev_dbg(dev, "circular route to %pI4\n", &dst);
-		ip_rt_put(rt);
 		dev->stats.collisions++;
-		goto tx_error;
+		goto rt_tx_error;
 	}
 
 	/* Bypass encapsulation if the destination is local */
@@ -1175,30 +1204,16 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
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
+	err = vxlan_xmit_skb(dev_net(dev), vxlan->vh, rt, skb,
+			     fl4.saddr, dst, tos, ttl, df,
+			     src_port, dst_port, htonl(vni << 8));
+
+	if (err < 0)
+		goto rt_tx_error;
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 
 	return;
@@ -1207,6 +1222,8 @@ drop:
 	dev->stats.tx_dropped++;
 	goto tx_free;
 
+rt_tx_error:
+	ip_rt_put(rt);
 tx_error:
 	dev->stats.tx_errors++;
 tx_free:
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 5794bf7..2c82c75 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -37,4 +37,11 @@ struct vxlan_handler *vxlan_handler_add(struct net *net,
 					__be16 portno, vxlan_rcv_t *rcv,
 					void *data, int priority, bool force_create);
 
+int vxlan_xmit_skb(struct net *net, struct vxlan_handler *vh,
+		   struct rtable *rt, struct sk_buff *skb,
+		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
+		   __be16 src_port, __be16 dst_port, __be32 vni);
+
+__be16 vxlan_src_port(__u16 port_min, __u16 port_max, struct sk_buff *skb);
+
 #endif
-- 
1.7.1
