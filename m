From: Tom Herbert <therbert@google.com>
Subject: [PATCH 5/8] vxlan: Call udp_flow_src_port
Date: Tue, 1 Jul 2014 21:32:49 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406121554340.29740@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:49806 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbaGBEcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:32:50 -0400
Received: by mail-pd0-f201.google.com with SMTP id v10so1767825pde.2
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:32:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In vxlan and OVS vport-vxlan call common function to get source port
for a UDP tunnel. Removed vxlan_src_port since the functionality is
now in udp_flow_src_port.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c           | 26 ++------------------------
 include/net/vxlan.h           |  2 --
 net/openvswitch/vport-vxlan.c |  5 +----
 3 files changed, 3 insertions(+), 30 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ade33ef..c2d3601 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1570,25 +1570,6 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
-/* Compute source port for outgoing packet
- *   first choice to use L4 flow hash since it will spread
- *     better and maybe available from hardware
- *   secondary choice is to use jhash on the Ethernet header
- */
-__be16 vxlan_src_port(__u16 port_min, __u16 port_max, struct sk_buff *skb)
-{
-	unsigned int range = (port_max - port_min) + 1;
-	u32 hash;
-
-	hash = skb_get_hash(skb);
-	if (!hash)
-		hash = jhash(skb->data, 2 * ETH_ALEN,
-			     (__force u32) skb->protocol);
-
-	return htons((((u64) hash * range) >> 32) + port_min);
-}
-EXPORT_SYMBOL_GPL(vxlan_src_port);
-
 static inline struct sk_buff *vxlan_handle_offloads(struct sk_buff *skb,
 						    bool udp_csum)
 {
@@ -1807,7 +1788,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	if (tos == 1)
 		tos = ip_tunnel_get_dsfield(old_iph, skb);
 
-	src_port = vxlan_src_port(vxlan->port_min, vxlan->port_max, skb);
+	src_port = udp_flow_src_port(dev_net(dev), skb, vxlan->port_min,
+				     vxlan->port_max, true);
 
 	if (dst->sa.sa_family == AF_INET) {
 		memset(&fl4, 0, sizeof(fl4));
@@ -2235,7 +2217,6 @@ static void vxlan_setup(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	unsigned int h;
-	int low, high;
 
 	eth_hw_addr_random(dev);
 	ether_setup(dev);
@@ -2272,9 +2253,6 @@ static void vxlan_setup(struct net_device *dev)
 	vxlan->age_timer.function = vxlan_cleanup;
 	vxlan->age_timer.data = (unsigned long) vxlan;
 
-	inet_get_local_port_range(dev_net(dev), &low, &high);
-	vxlan->port_min = low;
-	vxlan->port_max = high;
 	vxlan->dst_port = htons(vxlan_port);
 
 	vxlan->dev = dev;
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 12196ce6..d5f59f3 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -45,8 +45,6 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
 		   __be16 src_port, __be16 dst_port, __be32 vni, bool xnet);
 
-__be16 vxlan_src_port(__u16 port_min, __u16 port_max, struct sk_buff *skb);
-
 /* IP header + UDP + VXLAN + Ethernet header */
 #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
 /* IPv6 header + UDP + VXLAN + Ethernet header */
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 0edbd95..d8b7e24 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -143,8 +143,6 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	struct rtable *rt;
 	struct flowi4 fl;
 	__be16 src_port;
-	int port_min;
-	int port_max;
 	__be16 df;
 	int err;
 
@@ -172,8 +170,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 
 	skb->ignore_df = 1;
 
-	inet_get_local_port_range(net, &port_min, &port_max);
-	src_port = vxlan_src_port(port_min, port_max, skb);
+	src_port = udp_flow_src_port(net, skb, 0, 0, true);
 
 	err = vxlan_xmit_skb(vxlan_port->vs, rt, skb,
 			     fl.saddr, OVS_CB(skb)->tun_key->ipv4_dst,
-- 
2.0.0.526.g5318336
