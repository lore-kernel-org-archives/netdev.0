From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 12/14] vxlan: remove indirect call to vxlan_rcv() and vni member
Date: Mon,  1 Jun 2015 16:27:36 +0200
Message-ID: <92fb2f5faf82c1f773f009edfc16f7cfc81cf619.1433167296.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51058 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbbFAO1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:55 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the removal of the special treating of OVS VXLAN vports, the
indirect call to vxlan_rcv() can be avoided and the VNI member
in vxlan_metadata can be removed.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/vxlan.c | 225 +++++++++++++++++++++++++---------------------------
 include/net/vxlan.h |   7 --
 2 files changed, 107 insertions(+), 125 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index b696871..9cc7d5a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -75,7 +75,6 @@ static struct rtnl_link_ops vxlan_link_ops;
 static const u8 all_zeros_mac[ETH_ALEN];
 
 static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-					 vxlan_rcv_t *rcv, void *data,
 					 bool no_share, u32 flags);
 
 /* per-network namespace private data for this module */
@@ -1122,6 +1121,102 @@ static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
 	return vh;
 }
 
+static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
+		      struct vxlan_metadata *md, __u32 vni)
+{
+	struct ip_tunnel_info *tun_info = skb_shinfo(skb)->tun_info;
+	struct iphdr *oip = NULL;
+	struct ipv6hdr *oip6 = NULL;
+	struct vxlan_dev *vxlan;
+	struct pcpu_sw_netstats *stats;
+	union vxlan_addr saddr;
+	int err = 0;
+	union vxlan_addr *remote_ip;
+
+	/* For flow based devices, map all packets to VNI 0 */
+	if (vs->flags & VXLAN_F_FLOW_BASED)
+		vni = 0;
+
+	/* Is this VNI defined? */
+	vxlan = vxlan_vs_find_vni(vs, vni);
+	if (!vxlan)
+		goto drop;
+
+	remote_ip = &vxlan->default_dst.remote_ip;
+	skb_reset_mac_header(skb);
+	skb_scrub_packet(skb, !net_eq(vxlan->net, dev_net(vxlan->dev)));
+	skb->protocol = eth_type_trans(skb, vxlan->dev);
+	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
+
+	/* Ignore packet loops (and multicast echo) */
+	if (ether_addr_equal(eth_hdr(skb)->h_source, vxlan->dev->dev_addr))
+		goto drop;
+
+	/* Re-examine inner Ethernet packet */
+	if (remote_ip->sa.sa_family == AF_INET) {
+		oip = ip_hdr(skb);
+		saddr.sin.sin_addr.s_addr = oip->saddr;
+		saddr.sa.sa_family = AF_INET;
+
+		if (tun_info) {
+			tun_info->key.ipv4_src = oip->saddr;
+			tun_info->key.ipv4_dst = oip->daddr;
+			tun_info->key.ipv4_tos = oip->tos;
+			tun_info->key.ipv4_ttl = oip->ttl;
+		}
+#if IS_ENABLED(CONFIG_IPV6)
+	} else {
+		oip6 = ipv6_hdr(skb);
+		saddr.sin6.sin6_addr = oip6->saddr;
+		saddr.sa.sa_family = AF_INET6;
+
+		/* TODO : Fill IPv6 tunnel info */
+#endif
+	}
+
+	if ((vxlan->flags & VXLAN_F_LEARN) &&
+	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source))
+		goto drop;
+
+	skb_reset_network_header(skb);
+	if (!(vs->flags & VXLAN_F_FLOW_BASED))
+		skb->mark = md->gbp;
+
+	if (oip6)
+		err = IP6_ECN_decapsulate(oip6, skb);
+	if (oip)
+		err = IP_ECN_decapsulate(oip, skb);
+
+	if (unlikely(err)) {
+		if (log_ecn_error) {
+			if (oip6)
+				net_info_ratelimited("non-ECT from %pI6\n",
+						     &oip6->saddr);
+			if (oip)
+				net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
+						     &oip->saddr, oip->tos);
+		}
+		if (err > 1) {
+			++vxlan->dev->stats.rx_frame_errors;
+			++vxlan->dev->stats.rx_errors;
+			goto drop;
+		}
+	}
+
+	stats = this_cpu_ptr(vxlan->dev->tstats);
+	u64_stats_update_begin(&stats->syncp);
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+	u64_stats_update_end(&stats->syncp);
+
+	netif_rx(skb);
+
+	return;
+drop:
+	/* Consume bad packet */
+	kfree_skb(skb);
+}
+
 /* Callback from net/ipv4/udp.c to receive packets */
 static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
@@ -1226,8 +1321,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto bad_flags;
 	}
 
-	md->vni = vxh->vx_vni;
-	vs->rcv(vs, skb, md);
+	vxlan_rcv(vs, skb, md, vni >> 8);
 	return 0;
 
 drop:
@@ -1244,105 +1338,6 @@ error:
 	return 1;
 }
 
-static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
-		      struct vxlan_metadata *md)
-{
-	struct ip_tunnel_info *tun_info = skb_shinfo(skb)->tun_info;
-	struct iphdr *oip = NULL;
-	struct ipv6hdr *oip6 = NULL;
-	struct vxlan_dev *vxlan;
-	struct pcpu_sw_netstats *stats;
-	union vxlan_addr saddr;
-	__u32 vni;
-	int err = 0;
-	union vxlan_addr *remote_ip;
-
-	/* For flow based devices, map all packets to VNI 0 */
-	if (vs->flags & VXLAN_F_FLOW_BASED)
-		vni = 0;
-	else
-		vni = ntohl(md->vni) >> 8;
-
-	/* Is this VNI defined? */
-	vxlan = vxlan_vs_find_vni(vs, vni);
-	if (!vxlan)
-		goto drop;
-
-	remote_ip = &vxlan->default_dst.remote_ip;
-	skb_reset_mac_header(skb);
-	skb_scrub_packet(skb, !net_eq(vxlan->net, dev_net(vxlan->dev)));
-	skb->protocol = eth_type_trans(skb, vxlan->dev);
-	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
-
-	/* Ignore packet loops (and multicast echo) */
-	if (ether_addr_equal(eth_hdr(skb)->h_source, vxlan->dev->dev_addr))
-		goto drop;
-
-	/* Re-examine inner Ethernet packet */
-	if (remote_ip->sa.sa_family == AF_INET) {
-		oip = ip_hdr(skb);
-		saddr.sin.sin_addr.s_addr = oip->saddr;
-		saddr.sa.sa_family = AF_INET;
-
-		if (tun_info) {
-			tun_info->key.ipv4_src = oip->saddr;
-			tun_info->key.ipv4_dst = oip->daddr;
-			tun_info->key.ipv4_tos = oip->tos;
-			tun_info->key.ipv4_ttl = oip->ttl;
-		}
-#if IS_ENABLED(CONFIG_IPV6)
-	} else {
-		oip6 = ipv6_hdr(skb);
-		saddr.sin6.sin6_addr = oip6->saddr;
-		saddr.sa.sa_family = AF_INET6;
-
-		/* TODO : Fill IPv6 tunnel info */
-#endif
-	}
-
-	if ((vxlan->flags & VXLAN_F_LEARN) &&
-	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source))
-		goto drop;
-
-	skb_reset_network_header(skb);
-	if (!(vs->flags & VXLAN_F_FLOW_BASED))
-		skb->mark = md->gbp;
-
-	if (oip6)
-		err = IP6_ECN_decapsulate(oip6, skb);
-	if (oip)
-		err = IP_ECN_decapsulate(oip, skb);
-
-	if (unlikely(err)) {
-		if (log_ecn_error) {
-			if (oip6)
-				net_info_ratelimited("non-ECT from %pI6\n",
-						     &oip6->saddr);
-			if (oip)
-				net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
-						     &oip->saddr, oip->tos);
-		}
-		if (err > 1) {
-			++vxlan->dev->stats.rx_frame_errors;
-			++vxlan->dev->stats.rx_errors;
-			goto drop;
-		}
-	}
-
-	stats = this_cpu_ptr(vxlan->dev->tstats);
-	u64_stats_update_begin(&stats->syncp);
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
-	u64_stats_update_end(&stats->syncp);
-
-	netif_rx(skb);
-
-	return;
-drop:
-	/* Consume bad packet */
-	kfree_skb(skb);
-}
-
 static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
@@ -1681,7 +1676,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 			   struct sk_buff *skb,
 			   struct net_device *dev, struct in6_addr *saddr,
 			   struct in6_addr *daddr, __u8 prio, __u8 ttl,
-			   __be16 src_port, __be16 dst_port,
+			   __be16 src_port, __be16 dst_port, __u32 vni,
 			   struct vxlan_metadata *md, bool xnet, u32 vxflags)
 {
 	struct vxlanhdr *vxh;
@@ -1731,7 +1726,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_HF_VNI);
-	vxh->vx_vni = md->vni;
+	vxh->vx_vni = vni;
 
 	if (type & SKB_GSO_TUNNEL_REMCSUM) {
 		u32 data = (skb_checksum_start_offset(skb) - hdrlen) >>
@@ -1766,7 +1761,7 @@ err:
 
 static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 			  __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
-			  __be16 src_port, __be16 dst_port,
+			  __be16 src_port, __be16 dst_port, __u32 vni,
 			  struct vxlan_metadata *md, bool xnet, u32 vxflags)
 {
 	struct vxlanhdr *vxh;
@@ -1810,7 +1805,7 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_HF_VNI);
-	vxh->vx_vni = md->vni;
+	vxh->vx_vni = vni;
 
 	if (type & SKB_GSO_TUNNEL_REMCSUM) {
 		u32 data = (skb_checksum_start_offset(skb) - hdrlen) >>
@@ -2002,10 +1997,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
-		md->vni = htonl(vni << 8);
 		err = vxlan_xmit_skb(rt, sk, skb, fl4.saddr,
 				     dst->sin.sin_addr.s_addr, tos, ttl, df,
-				     src_port, dst_port, md,
+				     src_port, dst_port, htonl(vni << 8), md,
 				     !net_eq(vxlan->net, dev_net(vxlan->dev)),
 				     flags);
 		if (err < 0) {
@@ -2060,11 +2054,10 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
-		md->vni = htonl(vni << 8);
 		md->gbp = skb->mark;
 
 		err = vxlan6_xmit_skb(ndst, sk, skb, dev, &fl6.saddr, &fl6.daddr,
-				      0, ttl, src_port, dst_port, md,
+				      0, ttl, src_port, dst_port, htonl(vni << 8), md,
 				      !net_eq(vxlan->net, dev_net(vxlan->dev)),
 				      vxlan->flags);
 #endif
@@ -2257,8 +2250,8 @@ static int vxlan_open(struct net_device *dev)
 	struct vxlan_sock *vs;
 	int ret = 0;
 
-	vs = vxlan_sock_add(vxlan->net, vxlan->cfg.dst_port, vxlan_rcv,
-			    NULL, vxlan->cfg.no_share, vxlan->flags);
+	vs = vxlan_sock_add(vxlan->net, vxlan->cfg.dst_port,
+			    vxlan->cfg.no_share, vxlan->flags);
 	if (IS_ERR(vs))
 		return PTR_ERR(vs);
 
@@ -2557,7 +2550,6 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 
 /* Create new listen socket if needed */
 static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
-					      vxlan_rcv_t *rcv, void *data,
 					      u32 flags)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
@@ -2586,8 +2578,6 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 
 	vs->sock = sock;
 	atomic_set(&vs->refcnt, 1);
-	vs->rcv = rcv;
-	vs->data = data;
 	vs->flags = (flags & VXLAN_F_RCV_FLAGS);
 
 	/* Initialize the vxlan udp offloads structure */
@@ -2612,7 +2602,6 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 }
 
 static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-					 vxlan_rcv_t *rcv, void *data,
 					 bool no_share, u32 flags)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
@@ -2623,7 +2612,7 @@ static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 		spin_lock(&vn->sock_lock);
 		vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port,
 				     flags);
-		if (vs && vs->rcv == rcv) {
+		if (vs) {
 			if (!atomic_add_unless(&vs->refcnt, 1, 0))
 				vs = ERR_PTR(-EBUSY);
 			spin_unlock(&vn->sock_lock);
@@ -2632,7 +2621,7 @@ static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 		spin_unlock(&vn->sock_lock);
 	}
 
-	return vxlan_socket_create(net, port, rcv, data, flags);
+	return vxlan_socket_create(net, port, flags);
 }
 
 static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index d3ce81f..c157c5d 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -100,19 +100,12 @@ struct vxlanhdr {
 #define FDB_HASH_SIZE	(1<<FDB_HASH_BITS)
 
 struct vxlan_metadata {
-	__be32		vni;
 	u32		gbp;
 };
 
-struct vxlan_sock;
-typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb,
-			   struct vxlan_metadata *md);
-
 /* per UDP socket information */
 struct vxlan_sock {
 	struct hlist_node hlist;
-	vxlan_rcv_t	 *rcv;
-	void		 *data;
 	struct work_struct del_work;
 	struct socket	 *sock;
 	struct rcu_head	  rcu;
-- 
2.3.5
