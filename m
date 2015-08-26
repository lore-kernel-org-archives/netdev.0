From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v4 net-next 6/8] openvswitch: Use Geneve device.
Date: Wed, 26 Aug 2015 14:54:37 -0700
Message-ID: <1440626079-11689-7-git-send-email-pshelar@nicira.com>
References: <1440626079-11689-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:32801 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754757AbbHZVyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 17:54:52 -0400
Received: by pacti10 with SMTP id ti10so886911pac.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 14:54:51 -0700 (PDT)
In-Reply-To: <1440626079-11689-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With help of tunnel metadata mode OVS can directly use
Geneve devices to implement Geneve tunnels.
This patch removes all of the OVS specific Geneve code
and make OVS use a Geneve net_device. Basic geneve vport
is still there to handle compatibility with current
userspace application.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Reviewed-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/Kconfig        |    2 +-
 net/openvswitch/vport-geneve.c |  179 +++++++--------------------------------
 2 files changed, 33 insertions(+), 148 deletions(-)

diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 422dc05..87b98c0 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -59,7 +59,7 @@ config OPENVSWITCH_VXLAN
 config OPENVSWITCH_GENEVE
 	tristate "Open vSwitch Geneve tunneling support"
 	depends on OPENVSWITCH
-	depends on GENEVE_CORE
+	depends on GENEVE
 	default OPENVSWITCH
 	---help---
 	  If you say Y here, then the Open vSwitch will be able create geneve vport.
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index d01bd63..fa37c95 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -26,95 +26,44 @@
 
 #include "datapath.h"
 #include "vport.h"
+#include "vport-netdev.h"
 
 static struct vport_ops ovs_geneve_vport_ops;
-
 /**
  * struct geneve_port - Keeps track of open UDP ports
- * @gs: The socket created for this port number.
- * @name: vport name.
+ * @dst_port: destination port.
  */
 struct geneve_port {
-	struct geneve_sock *gs;
-	char name[IFNAMSIZ];
+	u16 port_no;
 };
 
-static LIST_HEAD(geneve_ports);
-
 static inline struct geneve_port *geneve_vport(const struct vport *vport)
 {
 	return vport_priv(vport);
 }
 
-/* Convert 64 bit tunnel ID to 24 bit VNI. */
-static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
-{
-#ifdef __BIG_ENDIAN
-	vni[0] = (__force __u8)(tun_id >> 16);
-	vni[1] = (__force __u8)(tun_id >> 8);
-	vni[2] = (__force __u8)tun_id;
-#else
-	vni[0] = (__force __u8)((__force u64)tun_id >> 40);
-	vni[1] = (__force __u8)((__force u64)tun_id >> 48);
-	vni[2] = (__force __u8)((__force u64)tun_id >> 56);
-#endif
-}
-
-/* Convert 24 bit VNI to 64 bit tunnel ID. */
-static __be64 vni_to_tunnel_id(const __u8 *vni)
-{
-#ifdef __BIG_ENDIAN
-	return (vni[0] << 16) | (vni[1] << 8) | vni[2];
-#else
-	return (__force __be64)(((__force u64)vni[0] << 40) |
-				((__force u64)vni[1] << 48) |
-				((__force u64)vni[2] << 56));
-#endif
-}
-
-static void geneve_rcv(struct geneve_sock *gs, struct sk_buff *skb)
-{
-	struct vport *vport = gs->rcv_data;
-	struct genevehdr *geneveh = geneve_hdr(skb);
-	int opts_len;
-	struct ip_tunnel_info tun_info;
-	__be64 key;
-	__be16 flags;
-
-	opts_len = geneveh->opt_len * 4;
-
-	flags = TUNNEL_KEY | TUNNEL_GENEVE_OPT |
-		(udp_hdr(skb)->check != 0 ? TUNNEL_CSUM : 0) |
-		(geneveh->oam ? TUNNEL_OAM : 0) |
-		(geneveh->critical ? TUNNEL_CRIT_OPT : 0);
-
-	key = vni_to_tunnel_id(geneveh->vni);
-
-	ip_tunnel_info_init(&tun_info, ip_hdr(skb),
-			    udp_hdr(skb)->source, udp_hdr(skb)->dest,
-			    key, flags, geneveh->options, opts_len);
-
-	ovs_vport_receive(vport, skb, &tun_info);
-}
-
 static int geneve_get_options(const struct vport *vport,
 			      struct sk_buff *skb)
 {
 	struct geneve_port *geneve_port = geneve_vport(vport);
-	struct inet_sock *sk = inet_sk(geneve_port->gs->sock->sk);
 
-	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(sk->inet_sport)))
+	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, geneve_port->port_no))
 		return -EMSGSIZE;
 	return 0;
 }
 
-static void geneve_tnl_destroy(struct vport *vport)
+static int geneve_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
+				      struct ip_tunnel_info *egress_tun_info)
 {
 	struct geneve_port *geneve_port = geneve_vport(vport);
+	struct net *net = ovs_dp_get_net(vport->dp);
+	__be16 dport = htons(geneve_port->port_no);
+	__be16 sport = udp_flow_src_port(net, skb, 1, USHRT_MAX, true);
 
-	geneve_sock_release(geneve_port->gs);
-
-	ovs_vport_deferred_free(vport);
+	return ovs_tunnel_get_egress_info(egress_tun_info,
+					  ovs_dp_get_net(vport->dp),
+					  OVS_CB(skb)->egress_tun_info,
+					  IPPROTO_UDP, skb->mark, sport, dport);
 }
 
 static struct vport *geneve_tnl_create(const struct vport_parms *parms)
@@ -122,11 +71,11 @@ static struct vport *geneve_tnl_create(const struct vport_parms *parms)
 	struct net *net = ovs_dp_get_net(parms->dp);
 	struct nlattr *options = parms->options;
 	struct geneve_port *geneve_port;
-	struct geneve_sock *gs;
+	struct net_device *dev;
 	struct vport *vport;
 	struct nlattr *a;
-	int err;
 	u16 dst_port;
+	int err;
 
 	if (!options) {
 		err = -EINVAL;
@@ -148,104 +97,40 @@ static struct vport *geneve_tnl_create(const struct vport_parms *parms)
 		return vport;
 
 	geneve_port = geneve_vport(vport);
-	strncpy(geneve_port->name, parms->name, IFNAMSIZ);
+	geneve_port->port_no = dst_port;
 
-	gs = geneve_sock_add(net, htons(dst_port), geneve_rcv, vport, true, 0);
-	if (IS_ERR(gs)) {
+	rtnl_lock();
+	dev = geneve_dev_create_fb(net, parms->name, NET_NAME_USER, dst_port);
+	if (IS_ERR(dev)) {
+		rtnl_unlock();
 		ovs_vport_free(vport);
-		return (void *)gs;
+		return ERR_CAST(dev);
 	}
-	geneve_port->gs = gs;
 
+	dev_change_flags(dev, dev->flags | IFF_UP);
+	rtnl_unlock();
 	return vport;
 error:
 	return ERR_PTR(err);
 }
 
-static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
+static struct vport *geneve_create(const struct vport_parms *parms)
 {
-	const struct ip_tunnel_key *tun_key;
-	struct ip_tunnel_info *tun_info;
-	struct net *net = ovs_dp_get_net(vport->dp);
-	struct geneve_port *geneve_port = geneve_vport(vport);
-	__be16 dport = inet_sk(geneve_port->gs->sock->sk)->inet_sport;
-	__be16 sport;
-	struct rtable *rt;
-	struct flowi4 fl;
-	u8 vni[3], opts_len, *opts;
-	__be16 df;
-	int err;
-
-	tun_info = OVS_CB(skb)->egress_tun_info;
-	if (unlikely(!tun_info)) {
-		err = -EINVAL;
-		goto error;
-	}
-
-	tun_key = &tun_info->key;
-	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_UDP);
-	if (IS_ERR(rt)) {
-		err = PTR_ERR(rt);
-		goto error;
-	}
-
-	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
-	sport = udp_flow_src_port(net, skb, 1, USHRT_MAX, true);
-	tunnel_id_to_vni(tun_key->tun_id, vni);
-	skb->ignore_df = 1;
-
-	if (tun_key->tun_flags & TUNNEL_GENEVE_OPT) {
-		opts = (u8 *)tun_info->options;
-		opts_len = tun_info->options_len;
-	} else {
-		opts = NULL;
-		opts_len = 0;
-	}
-
-	err = geneve_xmit_skb(geneve_port->gs, rt, skb, fl.saddr,
-			      tun_key->u.ipv4.dst, tun_key->tos,
-			      tun_key->ttl, df, sport, dport,
-			      tun_key->tun_flags, vni, opts_len, opts,
-			      !!(tun_key->tun_flags & TUNNEL_CSUM), false);
-	if (err < 0)
-		ip_rt_put(rt);
-	return err;
-
-error:
-	kfree_skb(skb);
-	return err;
-}
-
-static const char *geneve_get_name(const struct vport *vport)
-{
-	struct geneve_port *geneve_port = geneve_vport(vport);
-
-	return geneve_port->name;
-}
+	struct vport *vport;
 
-static int geneve_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				      struct ip_tunnel_info *egress_tun_info)
-{
-	struct geneve_port *geneve_port = geneve_vport(vport);
-	struct net *net = ovs_dp_get_net(vport->dp);
-	__be16 dport = inet_sk(geneve_port->gs->sock->sk)->inet_sport;
-	__be16 sport = udp_flow_src_port(net, skb, 1, USHRT_MAX, true);
+	vport = geneve_tnl_create(parms);
+	if (IS_ERR(vport))
+		return vport;
 
-	/* Get tp_src and tp_dst, refert to geneve_build_header().
-	 */
-	return ovs_tunnel_get_egress_info(egress_tun_info,
-					  ovs_dp_get_net(vport->dp),
-					  OVS_CB(skb)->egress_tun_info,
-					  IPPROTO_UDP, skb->mark, sport, dport);
+	return ovs_netdev_link(vport, parms->name);
 }
 
 static struct vport_ops ovs_geneve_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GENEVE,
-	.create		= geneve_tnl_create,
-	.destroy	= geneve_tnl_destroy,
-	.get_name	= geneve_get_name,
+	.create		= geneve_create,
+	.destroy	= ovs_netdev_tunnel_destroy,
 	.get_options	= geneve_get_options,
-	.send		= geneve_tnl_send,
+	.send		= ovs_netdev_send,
 	.owner          = THIS_MODULE,
 	.get_egress_tun_info	= geneve_get_egress_tun_info,
 };
-- 
1.7.1
