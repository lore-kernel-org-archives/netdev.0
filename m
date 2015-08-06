From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v4 3/4] openvswitch: Use regular GRE net_device instead of vport
Date: Wed,  5 Aug 2015 20:12:40 -0700
Message-ID: <1438830760-6572-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35109 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537AbbHFE14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 00:27:56 -0400
Received: by pdrg1 with SMTP id g1so27336387pdr.2
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 21:27:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using flow based tunneling, we can implement
OVS GRE vport. This patch removes all of the OVS
specific GRE code and make OVS use a ip_gre net_device.
Minimal GRE vport is kept to handle compatibility with
current userspace application.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/gre.h           |  12 +--
 net/ipv4/gre_demux.c        |  34 -------
 net/ipv4/ip_gre.c           |  36 +++++++
 net/openvswitch/Kconfig     |   1 -
 net/openvswitch/vport-gre.c | 237 ++++----------------------------------------
 5 files changed, 60 insertions(+), 260 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index b531820..e3e0845 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -33,16 +33,8 @@ struct gre_cisco_protocol {
 int gre_cisco_register(struct gre_cisco_protocol *proto);
 int gre_cisco_unregister(struct gre_cisco_protocol *proto);
 
-void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
-		      int hdr_len);
-
-static inline struct sk_buff *gre_handle_offloads(struct sk_buff *skb,
-						  bool csum)
-{
-	return iptunnel_handle_offloads(skb, csum,
-					csum ? SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
-}
-
+struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
+				       u8 name_assign_type);
 
 static inline int ip_gre_calc_hlen(__be16 o_flags)
 {
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 4a7b5b2..77562e0 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -61,40 +61,6 @@ int gre_del_protocol(const struct gre_protocol *proto, u8 version)
 }
 EXPORT_SYMBOL_GPL(gre_del_protocol);
 
-void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
-		      int hdr_len)
-{
-	struct gre_base_hdr *greh;
-
-	skb_push(skb, hdr_len);
-
-	skb_reset_transport_header(skb);
-	greh = (struct gre_base_hdr *)skb->data;
-	greh->flags = tnl_flags_to_gre_flags(tpi->flags);
-	greh->protocol = tpi->proto;
-
-	if (tpi->flags&(TUNNEL_KEY|TUNNEL_CSUM|TUNNEL_SEQ)) {
-		__be32 *ptr = (__be32 *)(((u8 *)greh) + hdr_len - 4);
-
-		if (tpi->flags&TUNNEL_SEQ) {
-			*ptr = tpi->seq;
-			ptr--;
-		}
-		if (tpi->flags&TUNNEL_KEY) {
-			*ptr = tpi->key;
-			ptr--;
-		}
-		if (tpi->flags&TUNNEL_CSUM &&
-		    !(skb_shinfo(skb)->gso_type &
-		      (SKB_GSO_GRE|SKB_GSO_GRE_CSUM))) {
-			*ptr = 0;
-			*(__sum16 *)ptr = csum_fold(skb_checksum(skb, 0,
-								 skb->len, 0));
-		}
-	}
-}
-EXPORT_SYMBOL_GPL(gre_build_header);
-
 static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 			    bool *csum_err)
 {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 554a760..49d1402 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -318,6 +318,13 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
 }
 
+static struct sk_buff *gre_handle_offloads(struct sk_buff *skb,
+					   bool csum)
+{
+	return iptunnel_handle_offloads(skb, csum,
+					csum ? SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
+}
+
 static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel_info *tun_info;
@@ -1012,6 +1019,35 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 	.get_link_net	= ip_tunnel_get_link_net,
 };
 
+struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
+					u8 name_assign_type)
+{
+	struct nlattr *tb[IFLA_MAX + 1];
+	struct net_device *dev;
+	struct ip_tunnel *t;
+	int err;
+
+	memset(&tb, 0, sizeof(tb));
+
+	dev = rtnl_create_link(net, name, name_assign_type,
+			       &ipgre_tap_ops, tb);
+	if (IS_ERR(dev))
+		return dev;
+
+	/* Configure flow based GRE device. */
+	t = netdev_priv(dev);
+	t->collect_md = true;
+
+	err = ipgre_newlink(net, dev, tb, NULL);
+	if (err < 0)
+		goto out;
+	return dev;
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL_GPL(gretap_fb_dev_create);
+
 static int __net_init ipgre_tap_init_net(struct net *net)
 {
 	return ip_tunnel_init_net(net, gre_tap_net_id, &ipgre_tap_ops, "gretap0");
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 1584040..c56f4d4 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -34,7 +34,6 @@ config OPENVSWITCH
 config OPENVSWITCH_GRE
 	tristate "Open vSwitch GRE tunneling support"
 	depends on OPENVSWITCH
-	depends on NET_IPGRE_DEMUX
 	default OPENVSWITCH
 	---help---
 	  If you say Y here, then the Open vSwitch will be able create GRE
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index b87656c..871801d 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -45,235 +45,43 @@
 
 #include "datapath.h"
 #include "vport.h"
+#include "vport-netdev.h"
 
 static struct vport_ops ovs_gre_vport_ops;
 
-/* Returns the least-significant 32 bits of a __be64. */
-static __be32 be64_get_low32(__be64 x)
+static struct vport *gre_tnl_create(const struct vport_parms *parms)
 {
-#ifdef __BIG_ENDIAN
-	return (__force __be32)x;
-#else
-	return (__force __be32)((__force u64)x >> 32);
-#endif
-}
-
-static __be16 filter_tnl_flags(__be16 flags)
-{
-	return flags & (TUNNEL_CSUM | TUNNEL_KEY);
-}
-
-static struct sk_buff *__build_header(struct sk_buff *skb,
-				      int tunnel_hlen)
-{
-	struct tnl_ptk_info tpi;
-	const struct ip_tunnel_key *tun_key;
-
-	tun_key = &OVS_CB(skb)->egress_tun_info->key;
-
-	skb = gre_handle_offloads(skb, !!(tun_key->tun_flags & TUNNEL_CSUM));
-	if (IS_ERR(skb))
-		return skb;
-
-	tpi.flags = filter_tnl_flags(tun_key->tun_flags);
-	tpi.proto = htons(ETH_P_TEB);
-	tpi.key = be64_get_low32(tun_key->tun_id);
-	tpi.seq = 0;
-	gre_build_header(skb, &tpi, tunnel_hlen);
-
-	return skb;
-}
-
-static __be64 key_to_tunnel_id(__be32 key, __be32 seq)
-{
-#ifdef __BIG_ENDIAN
-	return (__force __be64)((__force u64)seq << 32 | (__force u32)key);
-#else
-	return (__force __be64)((__force u64)key << 32 | (__force u32)seq);
-#endif
-}
-
-/* Called with rcu_read_lock and BH disabled. */
-static int gre_rcv(struct sk_buff *skb,
-		   const struct tnl_ptk_info *tpi)
-{
-	struct ip_tunnel_info tun_info;
-	struct ovs_net *ovs_net;
-	struct vport *vport;
-	__be64 key;
-
-	ovs_net = net_generic(dev_net(skb->dev), ovs_net_id);
-	vport = rcu_dereference(ovs_net->vport_net.gre_vport);
-	if (unlikely(!vport))
-		return PACKET_REJECT;
-
-	key = key_to_tunnel_id(tpi->key, tpi->seq);
-	ip_tunnel_info_init(&tun_info, ip_hdr(skb), 0, 0, key,
-			    filter_tnl_flags(tpi->flags), NULL, 0);
-
-	ovs_vport_receive(vport, skb, &tun_info);
-	return PACKET_RCVD;
-}
-
-/* Called with rcu_read_lock and BH disabled. */
-static int gre_err(struct sk_buff *skb, u32 info,
-		   const struct tnl_ptk_info *tpi)
-{
-	struct ovs_net *ovs_net;
+	struct net *net = ovs_dp_get_net(parms->dp);
+	struct net_device *dev;
 	struct vport *vport;
 
-	ovs_net = net_generic(dev_net(skb->dev), ovs_net_id);
-	vport = rcu_dereference(ovs_net->vport_net.gre_vport);
-
-	if (unlikely(!vport))
-		return PACKET_REJECT;
-	else
-		return PACKET_RCVD;
-}
-
-static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
-{
-	struct net *net = ovs_dp_get_net(vport->dp);
-	const struct ip_tunnel_key *tun_key;
-	struct flowi4 fl;
-	struct rtable *rt;
-	int min_headroom;
-	int tunnel_hlen;
-	__be16 df;
-	int err;
-
-	if (unlikely(!OVS_CB(skb)->egress_tun_info)) {
-		err = -EINVAL;
-		goto err_free_skb;
-	}
-
-	tun_key = &OVS_CB(skb)->egress_tun_info->key;
-	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_GRE);
-	if (IS_ERR(rt)) {
-		err = PTR_ERR(rt);
-		goto err_free_skb;
-	}
-
-	tunnel_hlen = ip_gre_calc_hlen(tun_key->tun_flags);
-
-	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
-			+ tunnel_hlen + sizeof(struct iphdr)
-			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
-	if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
-		int head_delta = SKB_DATA_ALIGN(min_headroom -
-						skb_headroom(skb) +
-						16);
-		err = pskb_expand_head(skb, max_t(int, head_delta, 0),
-					0, GFP_ATOMIC);
-		if (unlikely(err))
-			goto err_free_rt;
-	}
-
-	skb = vlan_hwaccel_push_inside(skb);
-	if (unlikely(!skb)) {
-		err = -ENOMEM;
-		goto err_free_rt;
-	}
-
-	/* Push Tunnel header. */
-	skb = __build_header(skb, tunnel_hlen);
-	if (IS_ERR(skb)) {
-		err = PTR_ERR(skb);
-		skb = NULL;
-		goto err_free_rt;
+	vport = ovs_vport_alloc(0, &ovs_gre_vport_ops, parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	rtnl_lock();
+	dev = gretap_fb_dev_create(net, parms->name, NET_NAME_USER);
+	if (IS_ERR(dev)) {
+		rtnl_unlock();
+		ovs_vport_free(vport);
+		return ERR_CAST(dev);
 	}
 
-	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
-		htons(IP_DF) : 0;
-
-	skb->ignore_df = 1;
-
-	return iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
-			     tun_key->ipv4_dst, IPPROTO_GRE,
-			     tun_key->ipv4_tos, tun_key->ipv4_ttl, df, false);
-err_free_rt:
-	ip_rt_put(rt);
-err_free_skb:
-	kfree_skb(skb);
-	return err;
-}
-
-static struct gre_cisco_protocol gre_protocol = {
-	.handler        = gre_rcv,
-	.err_handler    = gre_err,
-	.priority       = 1,
-};
-
-static int gre_ports;
-static int gre_init(void)
-{
-	int err;
-
-	gre_ports++;
-	if (gre_ports > 1)
-		return 0;
-
-	err = gre_cisco_register(&gre_protocol);
-	if (err)
-		pr_warn("cannot register gre protocol handler\n");
-
-	return err;
-}
-
-static void gre_exit(void)
-{
-	gre_ports--;
-	if (gre_ports > 0)
-		return;
-
-	gre_cisco_unregister(&gre_protocol);
-}
+	dev_change_flags(dev, dev->flags | IFF_UP);
+	rtnl_unlock();
 
-static const char *gre_get_name(const struct vport *vport)
-{
-	return vport_priv(vport);
+	return vport;
 }
 
 static struct vport *gre_create(const struct vport_parms *parms)
 {
-	struct net *net = ovs_dp_get_net(parms->dp);
-	struct ovs_net *ovs_net;
 	struct vport *vport;
-	int err;
-
-	err = gre_init();
-	if (err)
-		return ERR_PTR(err);
-
-	ovs_net = net_generic(net, ovs_net_id);
-	if (ovsl_dereference(ovs_net->vport_net.gre_vport)) {
-		vport = ERR_PTR(-EEXIST);
-		goto error;
-	}
 
-	vport = ovs_vport_alloc(IFNAMSIZ, &ovs_gre_vport_ops, parms);
+	vport = gre_tnl_create(parms);
 	if (IS_ERR(vport))
-		goto error;
-
-	strncpy(vport_priv(vport), parms->name, IFNAMSIZ);
-	rcu_assign_pointer(ovs_net->vport_net.gre_vport, vport);
-	return vport;
-
-error:
-	gre_exit();
-	return vport;
-}
-
-static void gre_tnl_destroy(struct vport *vport)
-{
-	struct net *net = ovs_dp_get_net(vport->dp);
-	struct ovs_net *ovs_net;
-
-	ovs_net = net_generic(net, ovs_net_id);
+		return vport;
 
-	RCU_INIT_POINTER(ovs_net->vport_net.gre_vport, NULL);
-	ovs_vport_deferred_free(vport);
-	gre_exit();
+	return ovs_netdev_link(vport, parms->name);
 }
 
 static int gre_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
@@ -288,10 +96,9 @@ static int gre_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 static struct vport_ops ovs_gre_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GRE,
 	.create		= gre_create,
-	.destroy	= gre_tnl_destroy,
-	.get_name	= gre_get_name,
-	.send		= gre_tnl_send,
+	.send		= ovs_netdev_send,
 	.get_egress_tun_info	= gre_get_egress_tun_info,
+	.destroy	= ovs_netdev_tunnel_destroy,
 	.owner		= THIS_MODULE,
 };
 
-- 
1.8.3.1
