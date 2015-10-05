From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Mon,  5 Oct 2015 10:58:17 -0700
Message-ID: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34742 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553AbbJER7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:59:06 -0400
Received: by padhy16 with SMTP id hy16so43086687pad.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:59:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While transitioning to netdev based vport we broke OVS
feature which allows user to retrieve tunnel packet egress
information for lwtunnel devices.  Following patch fixes it
by introducing ndo operation to get the tunnel egress info.
Same ndo operation can be used for lwtunnel devices and compat
ovs-tnl-vport devices. After adding the device operation
There is no need for similar ovs-vport operation. So the vport
API is removed.

Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device").

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/geneve.c           |   27 ++++++++++++++++++
 drivers/net/vxlan.c            |   46 +++++++++++++++++++++++++++++++
 include/linux/netdevice.h      |   13 +++++++++
 include/net/ip_tunnels.h       |   11 +++++++
 net/core/dev.c                 |   30 ++++++++++++++++++++
 net/ipv4/ip_gre.c              |   51 +++++++++++++++++++++++++++++------
 net/ipv4/ip_tunnel_core.c      |   37 +++++++++++++++++++++++++
 net/openvswitch/actions.c      |    6 +++-
 net/openvswitch/vport-geneve.c |   13 ---------
 net/openvswitch/vport-gre.c    |    8 -----
 net/openvswitch/vport-vxlan.c  |   19 -------------
 net/openvswitch/vport.c        |   58 ----------------------------------------
 net/openvswitch/vport.h        |   35 ------------------------
 13 files changed, 210 insertions(+), 144 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 8f5c02e..97d5b33 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -703,6 +703,32 @@ err:
 	return NETDEV_TX_OK;
 }
 
+static int geneve_egress_tun_info(struct net_device *dev, struct sk_buff *skb,
+				  struct ip_tunnel_info *egress_tun_info,
+				  const void **egress_tun_opts)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	struct ip_tunnel_info *info;
+	struct rtable *rt;
+	struct flowi4 fl4;
+	__be16 sport;
+
+	info = skb_tunnel_info(skb);
+	if (ip_tunnel_info_af(info) != AF_INET)
+		return -EINVAL;
+
+	rt = geneve_get_rt(skb, dev, &fl4, info);
+	if (IS_ERR(rt))
+		return PTR_ERR(rt);
+
+	ip_rt_put(rt);
+
+	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
+	ipv4_egress_info_init(egress_tun_info, egress_tun_opts, info,
+			      fl4.saddr, sport, geneve->dst_port);
+	return 0;
+}
+
 static const struct net_device_ops geneve_netdev_ops = {
 	.ndo_init		= geneve_init,
 	.ndo_uninit		= geneve_uninit,
@@ -713,6 +739,7 @@ static const struct net_device_ops geneve_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_get_egress_info	= geneve_egress_tun_info,
 };
 
 static void geneve_get_drvinfo(struct net_device *dev,
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bbac1d3..17a2da0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2337,6 +2337,51 @@ static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+static int egress_ipv4_tun_info(struct net_device *dev, struct sk_buff *skb,
+				struct ip_tunnel_info *info,
+				__be16 sport, __be16 dport,
+				struct ip_tunnel_info *egress_tun_info,
+				const void **egress_tun_opts)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct rtable *rt;
+	struct flowi4 fl4;
+
+	memset(&fl4, 0, sizeof(fl4));
+	fl4.flowi4_tos = RT_TOS(info->key.tos);
+	fl4.flowi4_mark = skb->mark;
+	fl4.flowi4_proto = IPPROTO_UDP;
+	fl4.daddr = info->key.u.ipv4.dst;
+
+	rt = ip_route_output_key(vxlan->net, &fl4);
+	if (IS_ERR(rt))
+		return PTR_ERR(rt);
+	ip_rt_put(rt);
+
+	ipv4_egress_info_init(egress_tun_info, egress_tun_opts, info,
+			      fl4.saddr, sport, dport);
+	return 0;
+}
+
+static int vxlan_egress_tun_info(struct net_device *dev, struct sk_buff *skb,
+				 struct ip_tunnel_info *egress_tun_info,
+				 const void **egress_tun_opts)
+{
+	struct ip_tunnel_info *info = skb_tunnel_info(skb);
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	__be16 sport, dport;
+
+	sport = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
+				  vxlan->cfg.port_max, true);
+	dport = info->key.tp_dst ? : vxlan->cfg.dst_port;
+
+	if (ip_tunnel_info_af(info) == AF_INET)
+		return egress_ipv4_tun_info(dev, skb, info, sport, dport,
+					    egress_tun_info,
+					    egress_tun_opts);
+	return -EINVAL;
+}
+
 static const struct net_device_ops vxlan_netdev_ops = {
 	.ndo_init		= vxlan_init,
 	.ndo_uninit		= vxlan_uninit,
@@ -2351,6 +2396,7 @@ static const struct net_device_ops vxlan_netdev_ops = {
 	.ndo_fdb_add		= vxlan_fdb_add,
 	.ndo_fdb_del		= vxlan_fdb_delete,
 	.ndo_fdb_dump		= vxlan_fdb_dump,
+	.ndo_get_egress_info	= vxlan_egress_tun_info,
 };
 
 /* Info for udev, that this is a virtual tunnel endpoint */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2d15e38..e44c076 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -60,6 +60,7 @@ struct wireless_dev;
 /* 802.15.4 specific */
 struct wpan_dev;
 struct mpls_dev;
+struct ip_tunnel_info;
 
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops);
@@ -1054,6 +1055,11 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	This function is used to pass protocol port error state information
  *	to the switch driver. The switch driver can react to the proto_down
  *      by doing a phys down on the associated switch port.
+ * int (*ndo_get_egress_info)(struct net_device *dev, struct sk_buff *skb,
+ *			      __be32 *saddr, __be16 *sport, __be16 *dport);
+ *	This function is used to get egress tunnel information for given skb.
+ *	This is useful for retrieving outer tunnel header parameters while
+ *	sampling packet.
  *
  */
 struct net_device_ops {
@@ -1227,6 +1233,10 @@ struct net_device_ops {
 	int			(*ndo_get_iflink)(const struct net_device *dev);
 	int			(*ndo_change_proto_down)(struct net_device *dev,
 							 bool proto_down);
+	int			(*ndo_get_egress_info)(struct net_device *dev,
+						       struct sk_buff *skb,
+						       struct ip_tunnel_info *egress_tun_info,
+						       const void **egress_tun_opts);
 };
 
 /**
@@ -2203,6 +2213,9 @@ void dev_add_offload(struct packet_offload *po);
 void dev_remove_offload(struct packet_offload *po);
 
 int dev_get_iflink(const struct net_device *dev);
+int dev_get_egress_info(struct net_device *dev, struct sk_buff *skb,
+			struct ip_tunnel_info *egress_info,
+			const void **egress_opts);
 struct net_device *__dev_get_by_flags(struct net *net, unsigned short flags,
 				      unsigned short mask);
 struct net_device *dev_get_by_name(struct net *net, const char *name);
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index f6dafec..8e3f336 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -337,6 +337,11 @@ void __init ip_tunnel_core_init(void);
 void ip_tunnel_need_metadata(void);
 void ip_tunnel_unneed_metadata(void);
 
+void ipv4_egress_info_init(struct ip_tunnel_info *egress_tun_info,
+			   const void **egress_tun_opts,
+			   struct ip_tunnel_info *info, __be32 saddr,
+			   __be16 sport, __be16 dport);
+
 #else /* CONFIG_INET */
 
 static inline struct ip_tunnel_info *lwt_tun_info(struct lwtunnel_state *lwtstate)
@@ -351,6 +356,12 @@ static inline void ip_tunnel_need_metadata(void)
 static inline void ip_tunnel_unneed_metadata(void)
 {
 }
+static inline void ipv4_egress_info_init(struct ip_tunnel_info *egress_tun_info,
+					 const void **egress_tun_opts,
+					 struct ip_tunnel_info *info, __be32 saddr,
+					 __be16 sport, __be16 dport)
+{
+}
 
 #endif /* CONFIG_INET */
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 6bb6470..b764ffc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -99,6 +99,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/stat.h>
 #include <net/dst.h>
+#include <net/dst_metadata.h>
 #include <net/pkt_sched.h>
 #include <net/checksum.h>
 #include <net/xfrm.h>
@@ -682,6 +683,35 @@ int dev_get_iflink(const struct net_device *dev)
 EXPORT_SYMBOL(dev_get_iflink);
 
 /**
+ *	dev_egress_tun_info - Retrieve tunnel egress information.
+ *	@dev: targeted interface
+ *	@skb: The packet.
+ *	@egress_info: Storage for egress info.
+ *	@egress_opts: Storage for egress options.
+ *
+ *	For better visibility of tunnel traffic OVS needs to retrieve
+ *	egress tunnel information for a packet. Following API allows
+ *	user to get this info.
+ */
+int dev_get_egress_info(struct net_device *dev, struct sk_buff *skb,
+			struct ip_tunnel_info *egress_info,
+			const void **egress_opts)
+{
+	struct ip_tunnel_info *info;
+
+	if (!dev->netdev_ops  || !dev->netdev_ops->ndo_get_egress_info)
+		return -EINVAL;
+
+	info = skb_tunnel_info(skb);
+	if (unlikely(info && !(info->mode & IP_TUNNEL_INFO_TX)))
+		return -EINVAL;
+
+	return dev->netdev_ops->ndo_get_egress_info(dev, skb,
+						    egress_info, egress_opts);
+}
+EXPORT_SYMBOL_GPL(dev_get_egress_info);
+
+/**
  *	__dev_get_by_name	- find a device by its name
  *	@net: the applicable net namespace
  *	@name: name to find
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index bd0679d..f08370e 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -498,10 +498,26 @@ static struct sk_buff *gre_handle_offloads(struct sk_buff *skb,
 					csum ? SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
 }
 
+static struct rtable *gre_get_rt(struct sk_buff *skb,
+				 struct net_device *dev,
+				 struct flowi4 *fl,
+				 const struct ip_tunnel_key *key)
+{
+	struct net *net = dev_net(dev);
+
+	memset(fl, 0, sizeof(*fl));
+	fl->daddr = key->u.ipv4.dst;
+	fl->saddr = key->u.ipv4.src;
+	fl->flowi4_tos = RT_TOS(key->tos);
+	fl->flowi4_mark = skb->mark;
+	fl->flowi4_proto = IPPROTO_GRE;
+
+	return ip_route_output_key(net, fl);
+}
+
 static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel_info *tun_info;
-	struct net *net = dev_net(dev);
 	const struct ip_tunnel_key *key;
 	struct flowi4 fl;
 	struct rtable *rt;
@@ -516,14 +532,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto err_free_skb;
 
 	key = &tun_info->key;
-	memset(&fl, 0, sizeof(fl));
-	fl.daddr = key->u.ipv4.dst;
-	fl.saddr = key->u.ipv4.src;
-	fl.flowi4_tos = RT_TOS(key->tos);
-	fl.flowi4_mark = skb->mark;
-	fl.flowi4_proto = IPPROTO_GRE;
-
-	rt = ip_route_output_key(net, &fl);
+	rt = gre_get_rt(skb, dev, &fl, key);
 	if (IS_ERR(rt))
 		goto err_free_skb;
 
@@ -566,6 +575,29 @@ err_free_skb:
 	dev->stats.tx_dropped++;
 }
 
+static int gre_egress_tun_info(struct net_device *dev, struct sk_buff *skb,
+			       struct ip_tunnel_info *egress_tun_info,
+			       const void **egress_tun_opts)
+{
+	struct ip_tunnel_info *info;
+	struct rtable *rt;
+	struct flowi4 fl4;
+
+	info = skb_tunnel_info(skb);
+	if (ip_tunnel_info_af(info) != AF_INET)
+		return -EINVAL;
+
+	rt = gre_get_rt(skb, dev, &fl4, &info->key);
+	if (IS_ERR(rt))
+		return PTR_ERR(rt);
+
+	ip_rt_put(rt);
+
+	ipv4_egress_info_init(egress_tun_info, egress_tun_opts, info,
+			      fl4.saddr, 0, 0);
+	return 0;
+}
+
 static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 			      struct net_device *dev)
 {
@@ -1023,6 +1055,7 @@ static const struct net_device_ops gre_tap_netdev_ops = {
 	.ndo_change_mtu		= ip_tunnel_change_mtu,
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
 	.ndo_get_iflink		= ip_tunnel_get_iflink,
+	.ndo_get_egress_info	= gre_egress_tun_info,
 };
 
 static void ipgre_tap_setup(struct net_device *dev)
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 84dce6a..ac742de 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -424,3 +424,40 @@ void ip_tunnel_unneed_metadata(void)
 	static_key_slow_dec(&ip_tunnel_metadata_cnt);
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_unneed_metadata);
+
+static void tnl_egress_opts_init(struct ip_tunnel_info *egress_tun_info,
+				 const void **egress_tun_opts,
+				 struct ip_tunnel_info *info)
+{
+	egress_tun_info->options_len = info->options_len;
+	egress_tun_info->mode = info->mode;
+
+	/* Tunnel options. */
+	if (info->options_len)
+		*egress_tun_opts = ip_tunnel_info_opts(info);
+	else
+		*egress_tun_opts = NULL;
+}
+
+void ipv4_egress_info_init(struct ip_tunnel_info *egress_tun_info,
+			   const void **egress_tun_opts,
+			   struct ip_tunnel_info *info, __be32 saddr,
+			   __be16 sport, __be16 dport)
+{
+	const struct ip_tunnel_key *tun_key;
+
+	/* Generate egress_tun_info based on tun_info,
+	 * saddr, tp_src and tp_dst
+	 */
+	tun_key = &egress_tun_info->key;
+	ip_tunnel_key_init(&egress_tun_info->key,
+			   saddr, tun_key->u.ipv4.dst,
+			   tun_key->tos,
+			   tun_key->ttl,
+			   sport, dport,
+			   tun_key->tun_id,
+			   tun_key->tun_flags);
+
+	tnl_egress_opts_init(egress_tun_info, egress_tun_opts, info);
+}
+EXPORT_SYMBOL_GPL(ipv4_egress_info_init);
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e23a61c..17762ba 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -794,8 +794,10 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 				int err;
 
 				upcall.egress_tun_info = &info;
-				err = ovs_vport_get_egress_tun_info(vport, skb,
-								    &upcall);
+				err = dev_get_egress_info(vport->dev, skb,
+							  upcall.egress_tun_info,
+							  &upcall.egress_tun_opts);
+
 				if (err)
 					upcall.egress_tun_info = NULL;
 			}
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 2735e9c..5f8aaaa 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -52,18 +52,6 @@ static int geneve_get_options(const struct vport *vport,
 	return 0;
 }
 
-static int geneve_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				      struct dp_upcall_info *upcall)
-{
-	struct geneve_port *geneve_port = geneve_vport(vport);
-	struct net *net = ovs_dp_get_net(vport->dp);
-	__be16 dport = htons(geneve_port->port_no);
-	__be16 sport = udp_flow_src_port(net, skb, 1, USHRT_MAX, true);
-
-	return ovs_tunnel_get_egress_info(upcall, ovs_dp_get_net(vport->dp),
-					  skb, IPPROTO_UDP, sport, dport);
-}
-
 static struct vport *geneve_tnl_create(const struct vport_parms *parms)
 {
 	struct net *net = ovs_dp_get_net(parms->dp);
@@ -130,7 +118,6 @@ static struct vport_ops ovs_geneve_vport_ops = {
 	.get_options	= geneve_get_options,
 	.send		= ovs_netdev_send,
 	.owner          = THIS_MODULE,
-	.get_egress_tun_info	= geneve_get_egress_tun_info,
 };
 
 static int __init ovs_geneve_tnl_init(void)
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 4d24481..64225bf 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -84,18 +84,10 @@ static struct vport *gre_create(const struct vport_parms *parms)
 	return ovs_netdev_link(vport, parms->name);
 }
 
-static int gre_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				   struct dp_upcall_info *upcall)
-{
-	return ovs_tunnel_get_egress_info(upcall, ovs_dp_get_net(vport->dp),
-					  skb, IPPROTO_GRE, 0, 0);
-}
-
 static struct vport_ops ovs_gre_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GRE,
 	.create		= gre_create,
 	.send		= ovs_netdev_send,
-	.get_egress_tun_info	= gre_get_egress_tun_info,
 	.destroy	= ovs_netdev_tunnel_destroy,
 	.owner		= THIS_MODULE,
 };
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index c11413d..e1c9c08 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -146,31 +146,12 @@ static struct vport *vxlan_create(const struct vport_parms *parms)
 	return ovs_netdev_link(vport, parms->name);
 }
 
-static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				     struct dp_upcall_info *upcall)
-{
-	struct vxlan_dev *vxlan = netdev_priv(vport->dev);
-	struct net *net = ovs_dp_get_net(vport->dp);
-	__be16 dst_port = vxlan_dev_dst_port(vxlan);
-	__be16 src_port;
-	int port_min;
-	int port_max;
-
-	inet_get_local_port_range(net, &port_min, &port_max);
-	src_port = udp_flow_src_port(net, skb, 0, 0, true);
-
-	return ovs_tunnel_get_egress_info(upcall, net,
-					  skb, IPPROTO_UDP,
-					  src_port, dst_port);
-}
-
 static struct vport_ops ovs_vxlan_netdev_vport_ops = {
 	.type			= OVS_VPORT_TYPE_VXLAN,
 	.create			= vxlan_create,
 	.destroy		= ovs_netdev_tunnel_destroy,
 	.get_options		= vxlan_get_options,
 	.send			= ovs_netdev_send,
-	.get_egress_tun_info	= vxlan_get_egress_tun_info,
 };
 
 static int __init ovs_vxlan_tnl_init(void)
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index fc5c0b9..0ddbc2e 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -470,61 +470,3 @@ void ovs_vport_deferred_free(struct vport *vport)
 	call_rcu(&vport->rcu, free_vport_rcu);
 }
 EXPORT_SYMBOL_GPL(ovs_vport_deferred_free);
-
-int ovs_tunnel_get_egress_info(struct dp_upcall_info *upcall,
-			       struct net *net,
-			       struct sk_buff *skb,
-			       u8 ipproto,
-			       __be16 tp_src,
-			       __be16 tp_dst)
-{
-	struct ip_tunnel_info *egress_tun_info = upcall->egress_tun_info;
-	const struct ip_tunnel_info *tun_info = skb_tunnel_info(skb);
-	const struct ip_tunnel_key *tun_key;
-	u32 skb_mark = skb->mark;
-	struct rtable *rt;
-	struct flowi4 fl;
-
-	if (unlikely(!tun_info))
-		return -EINVAL;
-	if (ip_tunnel_info_af(tun_info) != AF_INET)
-		return -EINVAL;
-
-	tun_key = &tun_info->key;
-
-	/* Route lookup to get srouce IP address.
-	 * The process may need to be changed if the corresponding process
-	 * in vports ops changed.
-	 */
-	rt = ovs_tunnel_route_lookup(net, tun_key, skb_mark, &fl, ipproto);
-	if (IS_ERR(rt))
-		return PTR_ERR(rt);
-
-	ip_rt_put(rt);
-
-	/* Generate egress_tun_info based on tun_info,
-	 * saddr, tp_src and tp_dst
-	 */
-	ip_tunnel_key_init(&egress_tun_info->key,
-			   fl.saddr, tun_key->u.ipv4.dst,
-			   tun_key->tos,
-			   tun_key->ttl,
-			   tp_src, tp_dst,
-			   tun_key->tun_id,
-			   tun_key->tun_flags);
-	egress_tun_info->options_len = tun_info->options_len;
-	egress_tun_info->mode = tun_info->mode;
-	upcall->egress_tun_opts = ip_tunnel_info_opts(egress_tun_info);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(ovs_tunnel_get_egress_info);
-
-int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				  struct dp_upcall_info *upcall)
-{
-	/* get_egress_tun_info() is only implemented on tunnel ports. */
-	if (unlikely(!vport->ops->get_egress_tun_info))
-		return -EINVAL;
-
-	return vport->ops->get_egress_tun_info(vport, skb, upcall);
-}
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index a413f3a..d341ad6 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -27,7 +27,6 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/u64_stats_sync.h>
-#include <net/route.h>
 
 #include "datapath.h"
 
@@ -53,16 +52,6 @@ int ovs_vport_set_upcall_portids(struct vport *, const struct nlattr *pids);
 int ovs_vport_get_upcall_portids(const struct vport *, struct sk_buff *);
 u32 ovs_vport_find_upcall_portid(const struct vport *, struct sk_buff *);
 
-int ovs_tunnel_get_egress_info(struct dp_upcall_info *upcall,
-			       struct net *net,
-			       struct sk_buff *,
-			       u8 ipproto,
-			       __be16 tp_src,
-			       __be16 tp_dst);
-
-int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				  struct dp_upcall_info *upcall);
-
 /**
  * struct vport_portids - array of netlink portids of a vport.
  *                        must be protected by rcu.
@@ -140,8 +129,6 @@ struct vport_parms {
  * have any configuration.
  * @send: Send a packet on the device.
  * zero for dropped packets or negative for error.
- * @get_egress_tun_info: Get the egress tunnel 5-tuple and other info for
- * a packet.
  */
 struct vport_ops {
 	enum ovs_vport_type type;
@@ -154,9 +141,6 @@ struct vport_ops {
 	int (*get_options)(const struct vport *, struct sk_buff *);
 
 	void (*send)(struct vport *, struct sk_buff *);
-	int (*get_egress_tun_info)(struct vport *, struct sk_buff *,
-				   struct dp_upcall_info *upcall);
-
 	struct module *owner;
 	struct list_head list;
 };
@@ -215,25 +199,6 @@ static inline const char *ovs_vport_name(struct vport *vport)
 int ovs_vport_ops_register(struct vport_ops *ops);
 void ovs_vport_ops_unregister(struct vport_ops *ops);
 
-static inline struct rtable *ovs_tunnel_route_lookup(struct net *net,
-						     const struct ip_tunnel_key *key,
-						     u32 mark,
-						     struct flowi4 *fl,
-						     u8 protocol)
-{
-	struct rtable *rt;
-
-	memset(fl, 0, sizeof(*fl));
-	fl->daddr = key->u.ipv4.dst;
-	fl->saddr = key->u.ipv4.src;
-	fl->flowi4_tos = RT_TOS(key->tos);
-	fl->flowi4_mark = mark;
-	fl->flowi4_proto = protocol;
-
-	rt = ip_route_output_key(net, fl);
-	return rt;
-}
-
 static inline void ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 {
 	vport->ops->send(vport, skb);
-- 
1.7.1
