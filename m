From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH v3 net-next 11/13] vxlan: metadata based tunneling for IPv6
Date: Thu, 20 Aug 2015 13:56:30 +0200
Message-ID: <a2c9e91103f27d3cdbbbb3aa94f9e3a366627376.1440071726.git.jbenc@redhat.com>
References: <cover.1440071726.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363AbbHTL52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2015 07:57:28 -0400
In-Reply-To: <cover.1440071726.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support metadata based (formerly flow based) tunneling also for IPv6.
This complements commit ee122c79d422 ("vxlan: Flow based tunneling").

Signed-off-by: Jiri Benc <jbenc@redhat.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 drivers/net/vxlan.c | 69 +++++++++++++++++++++++++++++++----------------------
 1 file changed, 40 insertions(+), 29 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2c1abf95c17d..54615bb9d916 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1269,17 +1269,27 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	if (vxlan_collect_metadata(vs)) {
-		const struct iphdr *iph = ip_hdr(skb);
-
 		tun_dst = metadata_dst_alloc(sizeof(*md), GFP_ATOMIC);
 		if (!tun_dst)
 			goto drop;
 
 		info = &tun_dst->u.tun_info;
-		info->key.u.ipv4.src = iph->saddr;
-		info->key.u.ipv4.dst = iph->daddr;
-		info->key.tos = iph->tos;
-		info->key.ttl = iph->ttl;
+		if (vxlan_get_sk_family(vs) == AF_INET) {
+			const struct iphdr *iph = ip_hdr(skb);
+
+			info->key.u.ipv4.src = iph->saddr;
+			info->key.u.ipv4.dst = iph->daddr;
+			info->key.tos = iph->tos;
+			info->key.ttl = iph->ttl;
+		} else {
+			const struct ipv6hdr *ip6h = ipv6_hdr(skb);
+
+			info->key.u.ipv6.src = ip6h->saddr;
+			info->key.u.ipv6.dst = ip6h->daddr;
+			info->key.tos = ipv6_get_dsfield(ip6h);
+			info->key.ttl = ip6h->hop_limit;
+		}
+
 		info->key.tp_src = udp_hdr(skb)->source;
 		info->key.tp_dst = udp_hdr(skb)->dest;
 
@@ -1894,6 +1904,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct ip_tunnel_info *info;
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct sock *sk = vxlan->vn_sock->sock->sk;
+	unsigned short family = vxlan_get_sk_family(vxlan->vn_sock);
 	struct rtable *rt = NULL;
 	const struct iphdr *old_iph;
 	struct flowi4 fl4;
@@ -1908,7 +1919,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	int err;
 	u32 flags = vxlan->flags;
 
-	/* FIXME: Support IPv6 */
 	info = skb_tunnel_info(skb);
 
 	if (rdst) {
@@ -1924,8 +1934,11 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
 		vni = be64_to_cpu(info->key.tun_id);
-		remote_ip.sin.sin_family = AF_INET;
-		remote_ip.sin.sin_addr.s_addr = info->key.u.ipv4.dst;
+		remote_ip.sa.sa_family = family;
+		if (family == AF_INET)
+			remote_ip.sin.sin_addr.s_addr = info->key.u.ipv4.dst;
+		else
+			remote_ip.sin6.sin6_addr = info->key.u.ipv6.dst;
 		dst = &remote_ip;
 	}
 
@@ -1951,23 +1964,24 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	src_port = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
 				     vxlan->cfg.port_max, true);
 
+	if (info) {
+		if (info->key.tun_flags & TUNNEL_CSUM)
+			flags |= VXLAN_F_UDP_CSUM;
+		else
+			flags &= ~VXLAN_F_UDP_CSUM;
+
+		ttl = info->key.ttl;
+		tos = info->key.tos;
+
+		if (info->options_len)
+			md = ip_tunnel_info_opts(info, sizeof(*md));
+	} else {
+		md->gbp = skb->mark;
+	}
+
 	if (dst->sa.sa_family == AF_INET) {
-		if (info) {
-			if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT)
-				df = htons(IP_DF);
-			if (info->key.tun_flags & TUNNEL_CSUM)
-				flags |= VXLAN_F_UDP_CSUM;
-			else
-				flags &= ~VXLAN_F_UDP_CSUM;
-
-			ttl = info->key.ttl;
-			tos = info->key.tos;
-
-			if (info->options_len)
-				md = ip_tunnel_info_opts(info, sizeof(*md));
-		} else {
-			md->gbp = skb->mark;
-		}
+		if (info && (info->key.tun_flags & TUNNEL_DONT_FRAGMENT))
+			df = htons(IP_DF);
 
 		memset(&fl4, 0, sizeof(fl4));
 		fl4.flowi4_oif = rdst ? rdst->remote_ifindex : 0;
@@ -2066,12 +2080,10 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
-		md->gbp = skb->mark;
-
 		err = vxlan6_xmit_skb(ndst, sk, skb, dev, &fl6.saddr, &fl6.daddr,
 				      0, ttl, src_port, dst_port, htonl(vni << 8), md,
 				      !net_eq(vxlan->net, dev_net(vxlan->dev)),
-				      vxlan->flags);
+				      flags);
 #endif
 	}
 
@@ -2104,7 +2116,6 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct vxlan_rdst *rdst, *fdst = NULL;
 	struct vxlan_fdb *f;
 
-	/* FIXME: Support IPv6 */
 	info = skb_tunnel_info(skb);
 
 	skb_reset_mac_header(skb);
-- 
1.8.3.1
