From: William Tu <u9012063@gmail.com>
Subject: [PATCH net-next] openvswitch: Add erspan tunnel support.
Date: Wed,  4 Oct 2017 05:02:39 -0700
Message-ID: <1507118559-13774-1-git-send-email-u9012063@gmail.com>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37101 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752277AbdJDMCw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 08:02:52 -0400
Received: by mail-pg0-f68.google.com with SMTP id o1so11814300pga.4
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 05:02:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add type II erspan vport implementation.  Since erspan protocol is
on top of the GRE header, the implementation is extended from the
existing gre implementation.

Signed-off-by: William Tu <u9012063@gmail.com>
Cc: Pravin B Shelar <pshelar@ovn.org>
---
 include/net/gre.h                |  2 ++
 include/uapi/linux/openvswitch.h |  2 ++
 net/ipv4/ip_gre.c                | 45 ++++++++++++++++++++++++++
 net/openvswitch/flow_netlink.c   | 55 +++++++++++++++++++++++++++++++-
 net/openvswitch/vport-gre.c      | 68 ++++++++++++++++++++++++++++++++++++++--
 5 files changed, 169 insertions(+), 3 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index d25d836c129b..6aa213a5502b 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -33,6 +33,8 @@ int gre_del_protocol(const struct gre_protocol *proto, u8 version);
 
 struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 				       u8 name_assign_type);
+struct net_device *erspan_fb_dev_create(struct net *net, const char *name,
+					u8 name_assign_type);
 int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 		     bool *csum_err, __be16 proto, int nhs);
 
diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 156ee4cab82e..2ebe0013ecfb 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -213,6 +213,7 @@ enum ovs_vport_type {
 	OVS_VPORT_TYPE_GRE,      /* GRE tunnel. */
 	OVS_VPORT_TYPE_VXLAN,	 /* VXLAN tunnel. */
 	OVS_VPORT_TYPE_GENEVE,	 /* Geneve tunnel. */
+	OVS_VPORT_TYPE_ERSPAN,   /* ERSPAN tunnel. */
 	__OVS_VPORT_TYPE_MAX
 };
 
@@ -359,6 +360,7 @@ enum ovs_tunnel_key_attr {
 	OVS_TUNNEL_KEY_ATTR_IPV6_SRC,		/* struct in6_addr src IPv6 address. */
 	OVS_TUNNEL_KEY_ATTR_IPV6_DST,		/* struct in6_addr dst IPv6 address. */
 	OVS_TUNNEL_KEY_ATTR_PAD,
+	OVS_TUNNEL_KEY_ATTR_ERSPAN_OPTS,	/* be32 ERSPAN index. */
 	__OVS_TUNNEL_KEY_ATTR_MAX
 };
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index b279c325c7f6..9adba017268d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1552,6 +1552,51 @@ static struct pernet_operations ipgre_tap_net_ops = {
 	.size = sizeof(struct ip_tunnel_net),
 };
 
+struct net_device *erspan_fb_dev_create(struct net *net, const char *name,
+					u8 name_assign_type)
+{
+	struct nlattr *tb[IFLA_MAX + 1];
+	struct net_device *dev;
+	LIST_HEAD(list_kill);
+	struct ip_tunnel *t;
+	int err;
+
+	memset(&tb, 0, sizeof(tb));
+
+	dev = rtnl_create_link(net, name, name_assign_type,
+			       &erspan_link_ops, tb);
+	if (IS_ERR(dev))
+		return dev;
+
+	/* Configure flow based ERSPAN device. */
+	t = netdev_priv(dev);
+	t->collect_md = true;
+
+	err = ipgre_newlink(net, dev, tb, NULL, NULL);
+	if (err < 0) {
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
+
+	/* openvswitch users expect packet sizes to be unrestricted,
+	 * so set the largest MTU we can.
+	 */
+	err = __ip_tunnel_change_mtu(dev, IP_MAX_MTU, false);
+	if (err)
+		goto out;
+
+	err = rtnl_configure_link(dev, NULL);
+	if (err < 0)
+		goto out;
+
+	return dev;
+out:
+	ip_tunnel_dellink(dev, &list_kill);
+	unregister_netdevice_many(&list_kill);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL_GPL(erspan_fb_dev_create);
+
 static int __net_init erspan_init_net(struct net *net)
 {
 	return ip_tunnel_init_net(net, erspan_net_id,
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index e8eb427ce6d1..e0c7e28710f0 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -48,6 +48,7 @@
 #include <net/ndisc.h>
 #include <net/mpls.h>
 #include <net/vxlan.h>
+#include <net/erspan.h>
 
 #include "flow_netlink.h"
 
@@ -319,7 +320,8 @@ size_t ovs_tun_key_attr_size(void)
 		 * OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS and covered by it.
 		 */
 		+ nla_total_size(2)    /* OVS_TUNNEL_KEY_ATTR_TP_SRC */
-		+ nla_total_size(2);   /* OVS_TUNNEL_KEY_ATTR_TP_DST */
+		+ nla_total_size(2)    /* OVS_TUNNEL_KEY_ATTR_TP_DST */
+		+ nla_total_size(4);   /* OVS_TUNNEL_KEY_ATTR_ERSPAN_OPTS */
 }
 
 size_t ovs_key_attr_size(void)
@@ -371,6 +373,7 @@ static const struct ovs_len_tbl ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1]
 						.next = ovs_vxlan_ext_key_lens },
 	[OVS_TUNNEL_KEY_ATTR_IPV6_SRC]      = { .len = sizeof(struct in6_addr) },
 	[OVS_TUNNEL_KEY_ATTR_IPV6_DST]      = { .len = sizeof(struct in6_addr) },
+	[OVS_TUNNEL_KEY_ATTR_ERSPAN_OPTS]   = { .len = sizeof(u32) },
 };
 
 /* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
@@ -593,6 +596,37 @@ static int vxlan_tun_opt_from_nlattr(const struct nlattr *attr,
 	return 0;
 }
 
+static int erspan_tun_opt_from_nlattr(const struct nlattr *attr,
+				      struct sw_flow_match *match, bool is_mask,
+				      bool log)
+{
+	unsigned long opt_key_offset;
+	struct erspan_metadata opts;
+
+	BUILD_BUG_ON(sizeof(opts) > sizeof(match->key->tun_opts));
+
+	memset(&opts, 0, sizeof(opts));
+	opts.index = nla_get_be32(attr);
+
+	/* Index has only 20-bit */
+	if (ntohl(opts.index) & ~INDEX_MASK) {
+		OVS_NLERR(log, "ERSPAN index number %x too large.",
+			  ntohl(opts.index));
+		return -EINVAL;
+	}
+
+	if (!is_mask)
+		SW_FLOW_KEY_PUT(match, tun_opts_len, sizeof(opts), false);
+	else
+		SW_FLOW_KEY_PUT(match, tun_opts_len, 0xff, true);
+
+	opt_key_offset = TUN_METADATA_OFFSET(sizeof(opts));
+	SW_FLOW_KEY_MEMCPY_OFFSET(match, opt_key_offset, &opts, sizeof(opts),
+				  is_mask);
+
+	return 0;
+}
+
 static int ip_tun_from_nlattr(const struct nlattr *attr,
 			      struct sw_flow_match *match, bool is_mask,
 			      bool log)
@@ -700,6 +734,19 @@ static int ip_tun_from_nlattr(const struct nlattr *attr,
 			break;
 		case OVS_TUNNEL_KEY_ATTR_PAD:
 			break;
+		case OVS_TUNNEL_KEY_ATTR_ERSPAN_OPTS:
+			if (opts_type) {
+				OVS_NLERR(log, "Multiple metadata blocks provided");
+				return -EINVAL;
+			}
+
+			err = erspan_tun_opt_from_nlattr(a, match, is_mask, log);
+			if (err)
+				return err;
+
+			tun_flags |= TUNNEL_ERSPAN_OPT;
+			opts_type = type;
+			break;
 		default:
 			OVS_NLERR(log, "Unknown IP tunnel attribute %d",
 				  type);
@@ -824,6 +871,10 @@ static int __ip_tun_to_nlattr(struct sk_buff *skb,
 		else if (output->tun_flags & TUNNEL_VXLAN_OPT &&
 			 vxlan_opt_to_nlattr(skb, tun_opts, swkey_tun_opts_len))
 			return -EMSGSIZE;
+		else if (output->tun_flags & TUNNEL_ERSPAN_OPT &&
+			 nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_ERSPAN_OPTS,
+				      ((struct erspan_metadata *)tun_opts)->index))
+			return -EMSGSIZE;
 	}
 
 	return 0;
@@ -2195,6 +2246,8 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 			break;
 		case OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS:
 			break;
+		case OVS_TUNNEL_KEY_ATTR_ERSPAN_OPTS:
+			break;
 		}
 	};
 
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 0e72d95b0e8f..bd4e3b4ec2ec 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -48,6 +48,49 @@
 #include "vport-netdev.h"
 
 static struct vport_ops ovs_gre_vport_ops;
+static struct vport_ops ovs_erspan_vport_ops;
+
+static struct vport *erspan_tnl_create(const struct vport_parms *parms)
+{
+	struct net *net = ovs_dp_get_net(parms->dp);
+	struct net_device *dev;
+	struct vport *vport;
+	int err;
+
+	vport = ovs_vport_alloc(0, &ovs_erspan_vport_ops, parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	rtnl_lock();
+	dev = erspan_fb_dev_create(net, parms->name, NET_NAME_USER);
+	if (IS_ERR(dev)) {
+		rtnl_unlock();
+		ovs_vport_free(vport);
+		return ERR_CAST(dev);
+	}
+
+	err = dev_change_flags(dev, dev->flags | IFF_UP);
+	if (err < 0) {
+		rtnl_delete_link(dev);
+		rtnl_unlock();
+		ovs_vport_free(vport);
+		return ERR_PTR(err);
+	}
+
+	rtnl_unlock();
+	return vport;
+}
+
+static struct vport *erspan_create(const struct vport_parms *parms)
+{
+	struct vport *vport;
+
+	vport = erspan_tnl_create(parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	return ovs_netdev_link(vport, parms->name);
+}
 
 static struct vport *gre_tnl_create(const struct vport_parms *parms)
 {
@@ -98,19 +141,40 @@ static struct vport_ops ovs_gre_vport_ops = {
 	.destroy	= ovs_netdev_tunnel_destroy,
 };
 
+static struct vport_ops ovs_erspan_vport_ops = {
+	.type		= OVS_VPORT_TYPE_ERSPAN,
+	.create		= erspan_create,
+	.send		= dev_queue_xmit,
+	.destroy	= ovs_netdev_tunnel_destroy,
+};
+
 static int __init ovs_gre_tnl_init(void)
 {
-	return ovs_vport_ops_register(&ovs_gre_vport_ops);
+	int ret;
+
+	ret = ovs_vport_ops_register(&ovs_gre_vport_ops);
+	if (ret)
+		return ret;
+
+	ret = ovs_vport_ops_register(&ovs_erspan_vport_ops);
+	if (ret) {
+		ovs_vport_ops_unregister(&ovs_gre_vport_ops);
+		return ret;
+	}
+
+	return ret;
 }
 
 static void __exit ovs_gre_tnl_exit(void)
 {
 	ovs_vport_ops_unregister(&ovs_gre_vport_ops);
+	ovs_vport_ops_unregister(&ovs_erspan_vport_ops);
 }
 
 module_init(ovs_gre_tnl_init);
 module_exit(ovs_gre_tnl_exit);
 
-MODULE_DESCRIPTION("OVS: GRE switching port");
+MODULE_DESCRIPTION("OVS: GRE/ERSPAN switching port");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("vport-type-3");
+MODULE_ALIAS("vport-type-6");
-- 
2.7.4
